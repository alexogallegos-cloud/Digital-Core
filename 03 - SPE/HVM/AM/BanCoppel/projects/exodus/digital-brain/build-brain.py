#!/usr/bin/env python3
"""build-brain.py — Programa Exodus (BanCoppel)

Construye `brain.db` parseando las fichas técnicas de ola desde `source/docs/`.

Las fichas tienen extensión `.doc` pero son HTML con BOM UTF-8, no binario de Word.
Cada ficha contiene una "FICHA MAYOR DE LA OLA" y N "FICHAS ESPECÍFICAS DE APLICACIONES"
con un assessment APO por aplicativo.

Uso:  python build-brain.py [--dry-run]

v1.0.0 · 2026-08-19 · Estructura canónica AM (ADR-SPE-AM-008), reglas B1/B2/B11/B12
"""
from __future__ import annotations

import argparse
import html
import json
import pathlib
import re
import sqlite3
import sys

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parent
DOCS = ROOT / "source" / "docs" / "Analisis de olas"
DB_PATH = HERE / "brain.db"
SEEDS = HERE / "seeds"

VERSION = "1.0.0"


# ─────────────────────────────────────────── parsing helpers

def read_ficha(path: pathlib.Path) -> str:
    """Las fichas son HTML con BOM. Devuelve texto plano preservando saltos de bloque."""
    raw = path.read_text(encoding="utf-8-sig", errors="replace")
    t = re.sub(r"(?is)<(script|style|head)[^>]*>.*?</\1>", " ", raw)
    t = re.sub(r"(?i)</(tr|p|h[1-6]|div|li)>", "\n", t)
    t = re.sub(r"(?i)</t[dh]>", " | ", t)
    t = re.sub(r"(?i)<br\s*/?>", "\n", t)
    t = re.sub(r"<[^>]+>", "", t)
    t = html.unescape(t)
    t = re.sub(r"[ \t\xa0]+", " ", t)
    return re.sub(r"\n\s*\n+", "\n", t).strip()


def field(block: str, label: str) -> str | None:
    """Extrae `label | valor |` de una tabla de la ficha."""
    m = re.search(rf"^\s*{re.escape(label)}\s*\|\s*(.+?)\s*\|?\s*$", block, re.M | re.I)
    return m.group(1).strip() if m else None


def labelled(block: str, label: str) -> str | None:
    """Extrae `Label: valor` (párrafos, no tablas)."""
    m = re.search(rf"{re.escape(label)}\s*:\s*(.+?)\s*$", block, re.M | re.I)
    return m.group(1).strip() if m else None


def first_int(s: str | None) -> int | None:
    if not s:
        return None
    m = re.search(r"([\d,\.]+)", s.replace(",", ""))
    if not m:
        return None
    try:
        return int(float(m.group(1)))
    except ValueError:
        return None


def parse_ops(s: str | None) -> int | None:
    """'2,000,000 Ops/Día' -> 2000000 ; '4.55M Operaciones/Día' -> 4550000"""
    if not s:
        return None
    m = re.search(r"([\d\.,]+)\s*M\b", s, re.I)
    if m:
        try:
            return int(float(m.group(1).replace(",", "")) * 1_000_000)
        except ValueError:
            return None
    return first_int(s)


def split_list(s: str | None) -> list[str]:
    if not s:
        return []
    parts = re.split(r",\s*|\s*·\s*|\n", s)
    return [p.strip(" .") for p in parts if p and p.strip(" .")]


# ─────────────────────────────────────────── schema

DDL = """
DROP TABLE IF EXISTS program_info;
CREATE TABLE program_info (
    slug TEXT PRIMARY KEY, display_name TEXT, objective TEXT,
    horizon_start TEXT, horizon_end TEXT, deadline TEXT,
    waves INTEGER, hosts_off INTEGER, spls_refactored INTEGER,
    core_apps INTEGER, ops_per_day_total TEXT,
    target_coverage TEXT, strategy TEXT, target_stack TEXT,
    brain_version TEXT, built_at TEXT
);

DROP TABLE IF EXISTS waves;
CREATE TABLE waves (
    id TEXT PRIMARY KEY,            -- W0..W6
    seq INTEGER,
    title TEXT,
    horizon TEXT,
    objective TEXT,
    executive_summary TEXT,
    core_impact TEXT,
    app_count INTEGER,
    hosts_off INTEGER,
    ops_per_day INTEGER,
    spls_removed INTEGER,
    cdc_scope TEXT,                 -- JSON array
    risks TEXT,                     -- JSON array
    source_doc TEXT
);

DROP TABLE IF EXISTS applications;
CREATE TABLE applications (
    id TEXT PRIMARY KEY,            -- {wave}::{app_id}
    app_id TEXT,                    -- ID-11
    name TEXT,
    wave_id TEXT REFERENCES waves(id),
    app_group TEXT,
    is_core INTEGER,
    criticality TEXT,
    hosting TEXT,
    os TEXT,
    hosts_released INTEGER,
    ops_per_day INTEGER,
    lang_frontend TEXT,
    lang_backend TEXT,
    lang_legacy TEXT,
    dbms TEXT,
    middleware TEXT,
    spl_count INTEGER,
    description TEXT,
    business_functions TEXT,        -- JSON array
    apo_class TEXT,
    apo_rationale TEXT,
    complexity TEXT,
    complexity_rationale TEXT,
    obsolescence_score INTEGER,
    obsolescence_drivers TEXT,
    wave_rationale TEXT,
    target_apis TEXT,               -- JSON array
    golden_records TEXT,            -- JSON array
    interop_capabilities TEXT,      -- JSON array
    yugabyte_entities TEXT,         -- JSON array
    source_doc TEXT
);

DROP TABLE IF EXISTS cross_dependencies;
CREATE TABLE cross_dependencies (
    id TEXT PRIMARY KEY,
    other_system TEXT,
    relationship TEXT,              -- feeds/calls/orchestrates/reads/writes/notifies
    direction TEXT,                 -- inbound/outbound DESDE Exodus
    volume INTEGER DEFAULT 0,
    description TEXT,
    criticality TEXT,
    origin_artifact TEXT
);

DROP TABLE IF EXISTS open_questions;
CREATE TABLE open_questions (
    id TEXT PRIMARY KEY, question TEXT, kind TEXT, evidence TEXT
);

DROP TABLE IF EXISTS risks;
CREATE TABLE risks (
    id          TEXT PRIMARY KEY,
    title       TEXT NOT NULL,
    category    TEXT,
    severity    TEXT,
    description TEXT,
    related     TEXT,
    status      TEXT DEFAULT 'open'
);

DROP TABLE IF EXISTS applications_fts;
CREATE VIRTUAL TABLE applications_fts USING fts5(
    id, app_id, name, description, apo_class, apo_rationale, obsolescence_drivers
);

DROP TABLE IF EXISTS ey_rfp_structure;
CREATE TABLE ey_rfp_structure (
    rfp_id        TEXT PRIMARY KEY,
    label         TEXT,
    apps          TEXT,
    criticality   TEXT,
    close_date    TEXT,
    rfp_type      TEXT,
    responsible   TEXT,
    notes         TEXT
);

DROP TABLE IF EXISTS ey_app_inventory;
CREATE TABLE ey_app_inventory (
    app_id_ey       INTEGER PRIMARY KEY,
    name            TEXT,
    short_name      TEXT,
    rfp_id          TEXT REFERENCES ey_rfp_structure(rfp_id),
    lang_frontend   TEXT,
    lang_backend    TEXT,
    app_server      TEXT,
    os              TEXT,
    hosting         TEXT,
    sp_count_raw    TEXT,
    sp_count_int    INTEGER,
    dbms            TEXT,
    batch_jobs      INTEGER,
    middleware      TEXT,
    vendor          TEXT,
    criticality     TEXT,
    concurrent_users TEXT,
    arch_design     TEXT,
    monitoring      TEXT,
    manager         TEXT,
    notes           TEXT
);

DROP TABLE IF EXISTS ams_support_proposal;
CREATE TABLE ams_support_proposal (
    id                    TEXT PRIMARY KEY,
    exodus_app_id         TEXT,
    exodus_wave           TEXT,
    ola1_priority         INTEGER,
    app_name              TEXT,
    spl_count_pptx        INTEGER,
    criticality_biz       TEXT,
    complexity_tech       TEXT,
    migration_approach    TEXT,
    ams_coverage_level    TEXT,
    ams_service_type      TEXT,
    knowledge_source      TEXT,
    brain_sp_count        INTEGER,
    migration_description TEXT,
    ola1_advantage        TEXT,
    ola1_feasibility      TEXT,
    proposed_roles        TEXT,
    team_size_fte         REAL,
    effort_months         INTEGER,
    key_risks             TEXT,
    source_artifact       TEXT
);
"""


# ─────────────────────────────────────────── extraction

def parse_wave(path: pathlib.Path) -> tuple[dict, list[dict]]:
    txt = read_ficha(path)
    seq_m = re.search(r"WAVE-(\d)", path.name)
    seq = int(seq_m.group(1)) if seq_m else -1
    wid = f"W{seq}"

    title_m = re.search(r"FICHA MAYOR DE LA OLA:\s*(.+?)\s*$", txt, re.M)
    title = title_m.group(1).strip() if title_m else path.stem

    # Bloque de la ficha mayor: hasta el encabezado de fichas específicas
    split_at = txt.find("FICHAS ESPECÍFICAS DE APLICACIONES")
    head = txt[: split_at if split_at > 0 else len(txt)]

    # Ámbito CDC y riesgos son listas sueltas entre encabezados
    def between(start: str, end: str | None) -> list[str]:
        s = head.find(start)
        if s < 0:
            return []
        s += len(start)
        e = head.find(end, s) if end else len(head)
        chunk = head[s : e if e > 0 else len(head)]
        return [ln.strip() for ln in chunk.split("\n") if ln.strip() and "|" not in ln]

    wave = {
        "id": wid,
        "seq": seq,
        "title": title,
        "horizon": field(head, "Horizonte Temporal"),
        "objective": field(head, "Objetivo Principal"),
        "executive_summary": field(head, "Descripción Ejecutiva"),
        "core_impact": field(head, "Impacto en Core Bancario"),
        "app_count": first_int(field(head, "Total Aplicaciones en Ola")),
        "hosts_off": first_int(field(head, "Servidores a Desactivar (Off)")),
        "ops_per_day": parse_ops(field(head, "Volumetría Transaccional Diaria")),
        "spls_removed": first_int(field(head, "SPLs Informix Eliminados")),
        "cdc_scope": json.dumps(
            between("Ámbito de Réplica YugabyteDB & CDC", "Riesgos Clave"), ensure_ascii=False),
        "risks": json.dumps(
            between("Riesgos Clave & Factores de Mitigación", "FICHAS ESPECÍFICAS"), ensure_ascii=False),
        "source_doc": path.name,
    }

    # ── fichas específicas de aplicación
    apps: list[dict] = []
    if split_at < 0:
        return wave, apps

    body = txt[split_at:]
    chunks = re.split(r"\n\s*\d+\.\s*FICHA ESPECÍFICA:\s*", body)[1:]
    for ch in chunks:
        name = ch.split("\n", 1)[0].strip()
        # Las fichas repiten el calificativo final: "Interact Switch (Autorizador) (Autorizador)".
        # Se elimina el paréntesis de cola cuando su contenido ya aparece antes en el nombre.
        m_dup = re.match(r"^(.*?)\s*\(([^()]+)\)\s*$", name)
        if m_dup and m_dup.group(2).strip().lower() in m_dup.group(1).lower():
            name = m_dup.group(1).strip()
        app_id = field(ch, "ID Aplicativo")
        if not app_id:
            continue

        fe = be = None
        langs = field(ch, "Lenguaje Frontend / Backend")
        if langs:
            fe_m = re.search(r"FE:\s*([^|]+)", langs)
            be_m = re.search(r"BE:\s*([^|]+)", langs)
            fe = fe_m.group(1).strip() if fe_m else None
            be = be_m.group(1).strip() if be_m else None

        dbms = mid = None
        dm = field(ch, "DBMS & Middleware")
        if dm:
            d_m = re.search(r"DBMS:\s*([^|]+)", dm)
            m_m = re.search(r"Mid:\s*([^|]+)", dm)
            dbms = d_m.group(1).strip() if d_m else None
            mid = m_m.group(1).strip() if m_m else None

        core_raw = (field(ch, "Pertenece a Core") or "")
        apps.append({
            "id": f"{wid}::{app_id}",
            "app_id": app_id,
            "name": name,
            "wave_id": wid,
            "app_group": field(ch, "Grupo"),
            "is_core": 1 if core_raw.upper().startswith("S") else 0,
            "criticality": field(ch, "Criticidad"),
            "hosting": field(ch, "Hosting Actual"),
            "os": field(ch, "Sistema Operativo"),
            "hosts_released": first_int(field(ch, "Hosts a Liberar")),
            "ops_per_day": parse_ops(field(ch, "Operaciones Diarias")),
            "lang_frontend": fe,
            "lang_backend": be,
            "lang_legacy": field(ch, "Lenguaje Tradicional"),
            "dbms": dbms,
            "middleware": mid,
            "spl_count": first_int(field(ch, "Stored Procedures (SPLs)")),
            "description": labelled(ch, "Descripción Funcional"),
            "business_functions": json.dumps(
                split_list(labelled(ch, "Funciones de Negocio Principales")), ensure_ascii=False),
            "apo_class": labelled(ch, "Clasificación APO"),
            "apo_rationale": labelled(ch, "Racional APO"),
            "complexity": labelled(ch, "Complejidad Técnica"),
            "complexity_rationale": labelled(ch, "Racional de Complejidad"),
            "obsolescence_score": first_int(labelled(ch, "Puntaje de Obsolescencia")),
            "obsolescence_drivers": labelled(ch, "Drivers de Obsolescencia"),
            "wave_rationale": (labelled(ch, "Racional de Asignación a la Ola")
                               or field(ch, "Racional de Asignación a la Ola")),
            "target_apis": json.dumps(
                split_list(labelled(ch, "APIs Objetivos Sugeridas")), ensure_ascii=False),
            "golden_records": json.dumps(
                split_list(labelled(ch, "Golden Records Relacionados")), ensure_ascii=False),
            "interop_capabilities": json.dumps(
                split_list(labelled(ch, "Capacidades de Interoperabilidad")), ensure_ascii=False),
            "yugabyte_entities": json.dumps(
                split_list(labelled(ch, "Entidades de Datos YugabyteDB")), ensure_ascii=False),
            "source_doc": path.name,
        })
    return wave, apps


def parse_executive(path: pathlib.Path) -> dict:
    txt = read_ficha(path)
    return {
        "slug": "exodus",
        "display_name": "Programa Exodus — BanCoppel",
        "objective": "Estrategia de migración de los datacenters de México a la nube (2026-2030) "
                     "con apagado de Informix y desmantelamiento físico on-premise.",
        "horizon_start": "2026-Q3",
        "horizon_end": "2029-H2",
        "deadline": "2030 (meta interna diciembre 2029, 12 meses de margen)",
        "waves": first_int(field(txt, "Oleadas Operativas")) or 6,
        "hosts_off": first_int(field(txt, "Reducción de Servidores On-Premise")),
        "spls_refactored": first_int(field(txt, "Eliminación de SPLs Informix")),
        "core_apps": first_int(field(txt, "Sistemas Core Involucrados")),
        "ops_per_day_total": "31.2M (declarado como riesgo agregado; la suma por ola da 21.46M)",
        "target_coverage": "68% con plataformas core objetivo (Temenos Transact, SmartVista, Apolo)",
        "strategy": "Strangler Fig: exponer APIs sobre réplica YugabyteDB con CDC Debezium "
                    "antes de reemplazar el backend.",
        "target_stack": "Java 21 + Spring Boot 3 sobre EKS; YugabyteDB; Kafka/Debezium CDC; "
                        "MuleSoft/Apigee con OpenAPI 3.0; Snowflake/Databricks para DWH.",
        "brain_version": VERSION,
        "built_at": "2026-08-19",
    }


# ─────────────────────────────────────────── conocimiento verificado en el barrido

CROSS_DEPS = [
    ("exodus-informix-decommission", "informix", "reads", "outbound", 7480,
     "Exodus es el programa que ejecuta el apagado de Informix. Ola 6 (2029-H2) cierra el "
     "datacenter. Refactoriza 7,480 stored procedures a microservicios Java 21.",
     "critical", "source/docs/Analisis de olas/Informe_Ejecutivo_Programa_Exodus_2026.doc"),
    ("exodus-unity-target", "unity", "feeds", "outbound", 0,
     "Exodus asume el TO-BE de Unity como destino: 68% de cobertura con Temenos Transact, "
     "SmartVista y Apolo. Ningún documento de Exodus menciona Unity por nombre; los hallazgos "
     "de Unity tratan a Exodus como tercero al que alinearse.",
     "high", "source/docs/Analisis de olas/Informe_Ejecutivo_Programa_Exodus_2026.doc"),
    ("exodus-app-movil-ola1", "app-movil", "reads", "outbound", 57,
     "App BanCoppel Móvil migra en Ola 1 (2027-H1): 57 hosts, 12,650 ops/día.",
     "high", "source/docs/Analisis de olas/Ficha_Tecnica_WAVE-1_EXODUS.doc"),
    ("exodus-spei-ola1", "spei", "reads", "outbound", 19,
     "SPEI Enlace Financiero migra en Ola 1: 19 hosts, 1,800,000 ops/día. Es el sistema de "
     "mayor volumetría de la ola.",
     "critical", "source/docs/Analisis de olas/Ficha_Tecnica_WAVE-1_EXODUS.doc"),
    ("exodus-eglobal-ola3", "eglobal", "reads", "outbound", 0,
     "El autorizador transaccional de E-Global/MasterCard migra en Ola 3 (2028-H1) a "
     "microservicios en EKS.",
     "critical", "source/docs/Analisis de olas/Ficha_Tecnica_WAVE-3_EXODUS.doc"),
    ("exodus-datastage-ola6", "datastage", "reads", "outbound", 0,
     "DWH y DataStage migran en Ola 6 hacia Snowflake/Databricks. Conecta con el gap IC-83: "
     "los pipelines se rompen cuando Informix deja de ser fuente.",
     "high", "source/docs/Analisis de olas/Ficha_Tecnica_WAVE-6_EXODUS.doc"),
    ("exodus-contabilidad-ola6", "contabilidad", "reads", "outbound", 1,
     "Contabilidad Core migra en Ola 6. Está declarada como Core Bancario con host dedicado.",
     "critical", "source/docs/Analisis de olas/Ficha_Tecnica_WAVE-6_EXODUS.doc"),
    ("exodus-acdc-peer", "acdc", "notifies", "outbound", 0,
     "ACDC es una tercera iniciativa corporativa de migración a la nube, par de Exodus. Los "
     "hallazgos de Unity piden evaluar alineamiento con ambas. No tenemos documentación de ACDC.",
     "medium", "unity/source/docs/.../Unity-ConcentradoHallazgos-VF.xlsx"),
]

OPEN_QUESTIONS = [
    ("EXO-Q01", "¿Quién patrocina Exodus a nivel ejecutivo y con qué presupuesto aprobado?",
     "gobierno",
     "Solo se documenta que Edgar Mejía (jefe de arquitectura de TI) 'está iniciando' el programa. "
     "Cero menciones de sponsor C-level, presupuesto, integrador contratado o estructura de gobierno "
     "en las 7 fichas."),
    ("EXO-Q02", "¿El decomiso de Informix pertenece a Exodus o a Unity?", "alcance",
     "El business case de Unity declara que 'el decomiso de PISA es parte central del ahorro "
     "proyectado', pero el apagado está planeado en Exodus Ola 6 (2029-H2). Si pertenece a Exodus, "
     "el business case de Unity descansa sobre el roadmap de otro programa sin dueño compartido."),
    ("EXO-Q03", "¿Cuántos stored procedures hay realmente en Informix?", "dato",
     "Cuatro fuentes irreconciliables: brain Informix parsea 11,391 SPs del código fuente real "
     "(53 DBs, 2026-08-20) — es la unica cifra empirica. Exodus cabecera declara 7,480. "
     "Xlsx banco (Inventario_bdanalisis) suma 41,778 declarados (32,000 son estimaciones redondas "
     "de 5 apps). Design Authority dice 13,000-14,000 sin fuente. "
     "PENDIENTE: confirmar si el campo '# SPL' del xlsx incluye stored procedures de DB2/Oracle "
     "ademas de Informix (EXO-Q08)."),
    ("EXO-Q04", "¿Por qué Exodus consolida en Apigee si el Plan Director lo declara EOL 2027?",
     "contradiccion",
     "Ola 1 dice 'Mantener y migrar su gateway a Apigee'. El Plan Director de Unity declara Apigee "
     "EOL 2027 con migración a MuleSoft. Los Lineamientos StackTech del 11-ago listan una tercera "
     "opción: Apigee o WSO2. Tres direcciones incompatibles."),
    ("EXO-Q05", "¿Exodus cubre solo un subconjunto del legado?", "alcance",
     "Las olas 1 a 6 suman ~30 sistemas contra 116-129 del Anexo 5, es decir ~24% del inventario. "
     "Qué pasa con el resto no está documentado."),
    ("EXO-Q06", "¿Cuál es la volumetría total real?", "dato",
     "El informe declara 31.2M ops/día como riesgo agregado, pero la suma por ola da 21.46M."),
    ("EXO-Q07", "¿Dónde caen los reportes regulatorios en las olas?", "alcance",
     "Ola 6 declara migrar 'Reportes Regulatorios CNBV' pero su lista es de 3 sistemas: Intranet, "
     "Contabilidad y DWH. Las aplicaciones 96, 97 y 100 (Reportes Autoridades, VISA, IPAB) no "
     "aparecen en ninguna ficha de ola."),
    ("EXO-Q08", "¿El campo '# SPL' del xlsx incluye SPs de DB2/Oracle además de Informix?", "dato",
     "SPL es el lenguaje de stored procedures exclusivo de Informix. Apps como Bus IBM (DB2) y "
     "Fiduciario (Oracle) declaran '# SPL' en el inventario del banco, lo cual es una contradiccion "
     "tecnica. Hipotesis: (1) el banco usa 'SPL' genericamente para cualquier SP de cualquier DBMS; "
     "(2) esas apps tienen una capa Informix no documentada; (3) el campo esta mal llenado. "
     "Hasta confirmar, los 41,778 del xlsx no son comparables con los 11,391 del brain."),
]

RISKS = [
    ("EXO-R001",
     "Subestimacion del universo SPL en el plan de migracion",
     "alcance", "critical",
     "Exodus planea migrar 7,480 SPLs (cabecera informe ejecutivo) pero el brain de Informix "
     "registra 11,391 SPs por parseo real del codigo fuente (53 bases de datos, 2026-08-20). "
     "Delta: ~3,911 SPs sin asignar a ninguna ola ni a decommission. Si el roadmap se compromete "
     "con 7,480, hay un 34% del codigo que queda fuera de scope y se descubre en ejecucion, "
     "no en planeacion.",
     "informix", "open"),
    ("EXO-R002",
     "Unidad del campo SPL en el inventario del banco sin confirmar para apps no-Informix",
     "dato", "medium",
     "El xlsx del banco (Inventario_bdanalisis.xlsx) tiene un campo '# SPL' para todas las apps, "
     "incluyendo Bus IBM (DB2) y Fiduciario (Oracle). SPL es el lenguaje exclusivo de Informix; "
     "DB2 y Oracle no tienen SPLs. Si el banco usa el termino genericamente para cualquier SP de "
     "cualquier DBMS, los 41,778 declarados no son comparables con los 11,391 del brain. "
     "Requiere confirmacion con el DBA IBM Informix o con los app owners.",
     "inventario", "open"),
    ("EXO-R003",
     "SIWEB: inversion activa en un activo clasificado para decomiso",
     "contradiccion", "critical",
     "SIWEB (ID-060) esta clasificado 'Eliminar (Deprecar)' en el assessment APO de Exodus "
     "con 10,000 SPLs declarados y puntaje de obsolescencia alto. Al mismo tiempo, Unity R4 "
     "tiene a SIWEB como uno de sus cinco tracks de desarrollo activo con HDUs propias "
     "(HDU-SIWEB-R4-01 a HDU-SIWEB-R4-05). BanCoppel esta invirtiendo en desarrollo nuevo "
     "sobre un aplicativo que Exodus planea decomisionar. La contradiccion no esta documentada "
     "ni escalada en ningun artefacto de gobierno.",
     "unity", "open"),
    ("EXO-R004",
     "76% del inventario de legado sin plan de migracion declarado",
     "alcance", "high",
     "Las 6 olas de Exodus cubren aproximadamente 30 sistemas de los 116-129 aplicaciones "
     "del Anexo 5, es decir el 24% del inventario (EXO-Q05). El 76% restante no tiene "
     "asignacion a ninguna ola ni plan de decommission documentado. Si esas apps tienen "
     "dependencias de Informix, el apagado declarado en Ola 6 no es ejecutable tal como "
     "esta planeado.",
     "inventario", "open"),
    ("EXO-R005",
     "Volumetria subestimada en 9.74M ops/dia",
     "dato", "medium",
     "El informe ejecutivo declara 31.2M operaciones/dia como total del programa. La suma "
     "de la volumetria declarada por ola da 21.46M. El delta de 9.74M ops/dia no esta "
     "asignado a ninguna ola. Si esa carga no mapeada tambien vive en Informix, las pruebas "
     "de stress y la capacidad del nuevo stack (YugabyteDB + EKS) estan subdimensionadas.",
     "volumetria", "open"),
    ("EXO-R006",
     "Decomiso de Informix sin ownership compartido entre Exodus y Unity",
     "gobierno", "critical",
     "Unity incluye el decomiso de PISA (Informix) como parte central de su business case "
     "de ahorro. Exodus ejecuta ese decomiso en Ola 6 (2029-H2). Los dos programas no "
     "comparten sponsor ejecutivo documentado ni governance formal. Si Exodus se retrasa, "
     "reduce scope o se cancela, el business case de Unity pierde su pilar principal de "
     "ahorro sin que nadie lo detecte en el proceso formal de gobierno.",
     "cross", "open"),
    ("EXO-R007",
     "Sin governance formal documentado en un programa de 6 olas y 636 servidores",
     "gobierno", "high",
     "El informe ejecutivo solo indica que Edgar Mejia (jefe de arquitectura de TI) 'esta "
     "iniciando' el programa. No hay mencion de sponsor C-level, presupuesto aprobado, "
     "integrador contratado, PMO ni estructura de gobierno en ninguna de las 7 fichas. "
     "Un programa de esta magnitud sin governance documentado tiene riesgo alto de drift "
     "silencioso o cancelacion sin escalacion formal.",
     "gobierno", "open"),
    ("EXO-R008",
     "Inversion en Apigee en Ola 1 cuando Unity lo declara EOL en 2027",
     "contradiccion", "high",
     "La ficha de Ola 1 especifica 'Mantener y migrar su gateway a Apigee'. El Plan Director "
     "de Unity declara Apigee EOL en 2027 con migracion a MuleSoft. Los Lineamientos StackTech "
     "del 11-ago ofrecen una tercera opcion. Tres direcciones incompatibles para el mismo "
     "componente. Consolidar en Apigee en Ola 1 (2027-H1) seria invertir en una plataforma "
     "con fecha de muerte declarada ese mismo ano.",
     "unity", "open"),
    ("EXO-R009",
     "Cifras de SPLs inconsistentes dentro del mismo informe ejecutivo de Exodus",
     "dato", "medium",
     "El cuadro de metricas del informe ejecutivo dice 7,480 SPLs a refactorizar. La seccion "
     "de riesgos del mismo documento dice '10,000+ SPLs a Reemplazar'. La suma por fichas de "
     "ola da 34,728 (inflado por tres apps con 10K estimados). El brain de Informix registra "
     "11,391 por parseo de codigo real. Cuatro cifras distintas en los mismos documentos de "
     "Exodus, ninguna con metodologia documentada. Riesgo: cualquier estimacion derivada de "
     "estas cifras tiene un rango de error del 40-80%.",
     "dato", "open"),
]


# ──────────────────────────────────────── Ola 1 — propuesta soporte AMS/IMS
# Derivado del Reporte Ejecutivo Exodus 02Sep2026.pptx.
# Coverage AMS/IMS derivado del brain de Informix (11,391 SPs / 53 DBs) y
# AppMovil brain (49 SPs mapeados, 216 microservicios Spring Boot).
# Columnas: id, exodus_app_id, exodus_wave, ola1_priority, app_name,
#   spl_count_pptx, criticality_biz, complexity_tech, migration_approach,
#   ams_coverage_level, ams_service_type, knowledge_source, brain_sp_count,
#   migration_description, ola1_advantage, ola1_feasibility,
#   proposed_roles (JSON), team_size_fte, effort_months,
#   key_risks (JSON), source_artifact

AMS_SUPPORT_PROPOSAL = [
    (
        "AMS-OLA1-ID62",
        "ID-62",
        "W1",
        1,
        "App BanCoppel Móvil",
        80,
        "Alta / Muy Alta",
        "Muy Alta",
        "strangler-fig",
        "full",
        "AMS-dev",
        "appmovil-brain,informix-brain",
        49,
        "Migración parcialmente iniciada. Estrangular Informix y migrar a MuleSoft/EKS 2027. "
        "Apagado On-Prem pendiente de fecha.",
        "Migración parcialmente iniciada, issues de performance conocidos. "
        "AMS tiene cobertura total del canal digital móvil.",
        "El esfuerzo se concentra en estrangular Informix y migrar a MuleSoft/EKS en 2027.",
        json.dumps([
            {"role": "App Móvil SME", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Informix DBA", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Java/Spring Boot Engineer", "level": "L9-Analyst", "fte": 2, "stream": "delivery"},
            {"role": "Mobile QA", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        5.0,
        12,
        json.dumps([
            "Apagado On-Prem pendiente de fecha confirmada",
            "49 SPs Informix mapeados en AppMovil brain — impacto real conocido pero no trivial",
            "216 microservicios Spring Boot requieren inventario completo de dependencias Informix",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID71",
        "ID-71",
        "W1",
        2,
        "SPEI Enlace Financiero",
        30,
        "Alta / Alta",
        "Alta",
        "invertir-innovar",
        "high",
        "AMS-ops",
        "informix-brain,exodus-brain",
        30,
        "PoC en Cloud ya implementada (adapter). Evolucionar a producción con certificación "
        "Banxico/CNBV. 1.8M ops/día.",
        "PoC implementada en Cloud. AMS opera SPEI en producción y conoce el flujo completo.",
        "Con validación de PoC es factible ir a producción. "
        "Riesgo: certificación Banxico/CNBV con plazo no controlado.",
        json.dumps([
            {"role": "Integration Architect", "level": "L7-Manager", "fte": 1, "stream": "delivery"},
            {"role": "SPEI / Banxico Specialist", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Java Backend Engineer", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
            {"role": "Compliance QA", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        4.0,
        18,
        json.dumps([
            "Requiere certificación Banxico/CNBV — plazo no controlado por Accenture",
            "1.8M ops/día — mayor volumetría de Ola 1; riesgo operacional en transición",
            "SPEI es sistema nacional crítico — cualquier incidente tiene impacto regulatorio",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID58",
        "ID-58",
        "W1",
        3,
        "Oficina Financiera Integral (OFI)",
        10000,
        "Alta / Muy Alta",
        "Muy Alta",
        "eliminar-reemplazar",
        "high",
        "AMS-dev",
        "informix-brain,exodus-brain",
        None,
        "Mayor carga de SPLs del banco. Análisis de Front/Back/BD disponible. "
        "Deprecar VB6 legacy; back sin plan de movimiento definido.",
        "Análisis detallado de Front/Back/BD disponible. Eliminaría la mayor carga de SPLs. "
        "AMS conoce OFI en producción.",
        "Análisis previo de evolución del front disponible. "
        "Falta definir movimiento del back (Deprecación VB6 legacy).",
        json.dumps([
            {"role": "OFI Migration Lead (SM)", "level": "L6-SM", "fte": 1, "stream": "AMS"},
            {"role": "VB6 / Legacy Tech Lead", "level": "L7-Manager", "fte": 1, "stream": "delivery"},
            {"role": "Java/Spring Boot Engineer", "level": "L9-Analyst", "fte": 3, "stream": "delivery"},
            {"role": "Informix DBA", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "QA Engineer", "level": "L9-Analyst", "fte": 2, "stream": "delivery"},
        ], ensure_ascii=False),
        8.0,
        18,
        json.dumps([
            "10,000 SPLs declarados — conteo redondo; real desconocido hasta inventario formal",
            "Deprecación VB6 legacy sin arquitectura de back definida",
            "Mayor carga de SPLs del banco — riesgo de alcance más alto de Ola 1",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID2",
        "ID-2",
        "W1",
        4,
        "Administrador de token (CAS)",
        10,
        "Alta / Alta",
        "Alta",
        "lift-shift-modernize",
        "partial",
        "AMS-ops",
        "informix-brain,exodus-brain",
        70,
        "Lift and shift. Modernizar Java 7 a Java 21. Funcionalidades básicas de autenticación.",
        "Lift and shift factible. Tecnología se adapta a la nube sin rediseño complejo.",
        "Modernizar Java 7 a Java 21; funcionalidades básicas adaptables a la nube.",
        json.dumps([
            {"role": "IAM / Security Specialist", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Java Backend Engineer", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        2.0,
        6,
        json.dumps([
            "Discrepancia SPL: PPTX declara 10, brain de Exodus registra 70 — validar con DBA",
            "Java 7 → Java 21: posibles incompatibilidades de API",
            "CAS es dependencia transversal — impacto en múltiples canales al modificarlo",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID30",
        "ID-30",
        "W1",
        5,
        "Latinia",
        50,
        "Media / Alta",
        "Alta",
        "tolerar-migrar",
        "partial",
        "AMS-ops",
        "informix-brain,exodus-brain",
        50,
        "SNS en AWS ya existe. Complejidad en mapeo de campañas dependientes. Migrar a AWS SNS.",
        "SNS en AWS ya disponible. Migración técnica sencilla.",
        "Sencillo de utilizar en la nube. Complejidad en identificar todas las aplicaciones "
        "(campañas) dependientes.",
        json.dumps([
            {"role": "Integration Specialist", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Notification Platform Developer", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        2.0,
        6,
        json.dumps([
            "Mapeo de campañas y aplicaciones dependientes no documentado — alcance subestimado",
            "50 SPLs Informix pendientes de inventario detallado",
            "Riesgo de miss de campañas no mapeadas en producción",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ARES",
        "ARES",
        "W1-PROP",
        6,
        "ARES (EmpresaNet 2.0)",
        400,
        "Alta / Muy Alta",
        "Muy Alta",
        "cloud-native-2027",
        "high",
        "AMS-dev",
        "ams-knowledge",
        None,
        "Cloud native en 2027. Estrangular Informix migrando a la nueva BD.",
        "Liberación cloud native en 2027. AMS conoce ARES en operación.",
        "El esfuerzo se concentra en estrangular Informix migrando a la nueva BD.",
        json.dumps([
            {"role": "ARES Migration Lead", "level": "L7-Manager", "fte": 1, "stream": "delivery"},
            {"role": "Java / Spring Boot Engineer", "level": "L8-Consultant", "fte": 1, "stream": "delivery"},
            {"role": "Informix DBA", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "QA Engineer", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        4.0,
        12,
        json.dumps([
            "ARES no tiene ficha técnica formal en Exodus — sin inventario validado de SPLs",
            "400 SPLs declarados en PPTX sin respaldo en brain de Informix",
            "Cloud native 2027 puede implicar dependencias de plataforma no documentadas",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID9",
        "ID-9",
        "W1",
        7,
        "Monitor de Operaciones BPI",
        4,
        "Baja / Media",
        "Media",
        "tolerar-reemplazar",
        "full",
        "AMS-ops",
        "exodus-brain,ams-knowledge",
        0,
        "Portal de consulta de operaciones. Tecnología vieja pero sencilla de reemplazar.",
        "Tecnología vieja pero sencilla de reemplazar por lenguaje de desarrollo.",
        "Alta factibilidad por simplicidad — es un portal de consulta.",
        json.dumps([
            {"role": "AMS Ops Developer", "level": "L9-Analyst", "fte": 1, "stream": "AMS"},
        ], ensure_ascii=False),
        1.0,
        3,
        json.dumps([
            "4 SPLs declarados en PPTX vs 0 en brain de Exodus — validar con DBA",
            "Monitor BPI es herramienta operativa AMS 24x7 — migración requiere ventana cuidadosa",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
    (
        "AMS-OLA1-ID13",
        "ID-13",
        "W3",
        8,
        "Conciliación Automática ATM / POS",
        10,
        "Media / Media",
        "Media",
        "validar-smartvista",
        "partial",
        "AMS-ops",
        "informix-brain,exodus-brain",
        30,
        "Validar que SmartVista cubra el 100% de la funcionalidad. 30 SPLs en brain (W3).",
        "SmartVista puede absorber la funcionalidad. AMS conoce el proceso ATM/POS.",
        "Validar roadmap de SmartVista para absorción de funcionalidad de conciliación.",
        json.dumps([
            {"role": "Payments / SmartVista SME", "level": "L8-Consultant", "fte": 1, "stream": "AMS"},
            {"role": "Reconciliation Developer", "level": "L9-Analyst", "fte": 1, "stream": "delivery"},
        ], ensure_ascii=False),
        2.0,
        6,
        json.dumps([
            "Roadmap SmartVista no validado — puede no absorber toda la funcionalidad",
            "10 SPLs en PPTX vs 30 en brain de Exodus (W3) — discrepancia a validar",
            "App en W3 original (2028-H1) — aceleración a Ola 1 requiere alineación con governance",
        ], ensure_ascii=False),
        "Reporte Ejecutivo Exodus 02Sep2026.pptx",
    ),
]


# ──────────────────────────────────────── EY Data — RFP structure & app inventory
# Fuente: Reporte Ejecutivo Exodus 18Sep2026.pptx + Exodus_Roadmap_V1.xlsx
#         + Inventario aplicativos_versióncorta.xlsx
# Compartido por EY a Alejandro Gallegos — 2026-09

# Columnas: rfp_id, label, apps, criticality, close_date, rfp_type, responsible, notes
EY_RFP_STRUCTURE = [
    ("RFP-1", "SPEI Enlace Financiero (individual)",
     "SPEI Enlace Financiero",
     "Nivel 0 — Crítico regulatorio (Banxico)", "19-dic-2026", "Individual",
     "Arquitectura / Cumplimiento",
     "Mayor volumetría de Ola 1 (1.8M ops/día). Requiere certificación Banxico. "
     "Umbral técnico de evaluación elevado a 75 pts. Peso seguridad = 25 %."),
    ("RFP-2", "Empresa Net Ares (individual)",
     "ARES (EmpresaNet 2.0)",
     "Nivel 1", "21-nov-2026", "Individual",
     "Arquitectura / Negocio",
     "Cloud native 2027. 200 SPs app + 200 reuso en Informix 12. Java 7 con backlog a Java 21."),
    ("RFP-3", "Oficina Financiera Integral (individual)",
     "Oficina Financiera Integral (OFI)",
     "Nivel 1", "21-nov-2026", "Individual",
     "Arquitectura / Negocio",
     "Mayor carga de SPLs (~10,000 estimados, sin validar). Frontend VB6 legacy en Windows. "
     "Múltiples DBs Informix (bdinteg, bdisolic, bdiburo, bdicred, bdicheq, bdinvers, bdidigital)."),
    ("RFP-4", "App BanCoppel Móvil (individual)",
     "App BanCoppel Móvil",
     "Nivel 1", "19-dic-2026", "Individual",
     "Arquitectura / Canales",
     "Canal digital principal. Java 8→21 multi-versión. "
     "Middleware: IBM BUS + SPL + Servicios Intermedios JBoss. AMS Accenture activo."),
    ("RFP-5", "Satélites — consolidado (4 aplicativos)",
     "Administrador Token (CAS) · Monitor BPI · Latinia · Conciliación ATM/POS",
     "Nivel 0 (CAS) · Nivel 2 (BPI, Latinia, Conciliación)", "05-dic-2026", "Consolidado",
     "Arquitectura / Seguridad",
     "CAS es habilitador transversal — su indisponibilidad afecta autenticación de todos los canales. "
     "El RFP-5 debe exigir objetivos de recuperación diferenciados para CAS."),
]

# Columnas: app_id_ey, name, short_name, rfp_id,
#   lang_frontend, lang_backend, app_server, os, hosting,
#   sp_count_raw, sp_count_int, dbms, batch_jobs, middleware,
#   vendor, criticality, concurrent_users, arch_design, monitoring, manager, notes
EY_APP_INVENTORY = [
    (62, "App BanCoppel Móvil", "APP BanCoppel", "RFP-4",
     "N/A (native Android/iOS)", "Java 8/11/17/21",
     "JBoss EAP 8.01 + microservicios Spring Boot", "Android 6+ / iOS 11+", "On-Premise",
     "70-80", 75,
     "Informix 12 · MongoDB (bitácora) · PostgreSQL (SSO)",
     0, "IBM BUS · SPL · Servicios Intermedios JBoss",
     "Accenture AMS (mantenimiento)", "Alta",
     "12,650 transacciones/día (declarado Exodus); app store: millones de usuarios",
     "Microservicios + MVC legacy",
     "Dynatrace",
     "Gustavo Valdez / Edgar Martinez",
     "216 microservicios Spring Boot activos. "
     "AMS Accenture opera canal móvil. Strangler Fig propuesto hacia MuleSoft/EKS."),
    (71, "SPEI Enlace Financiero", "SPEI", "RFP-1",
     "N/A", "Java",
     "JBoss / servidor propio", "Linux RH8", "On-Premise",
     "20-30", 25,
     "Informix · PostgreSQL",
     22, "BUS · IHS (balanceador de cargas)",
     "Desarrollo In-House", "Alta",
     "1,800,000 ops/día",
     "Client-Server / integración mensajería",
     "Dynatrace",
     "Arturo Pérez / Juan Carlos Argudín",
     "22 jobs batch activos. PoC en cloud implementada. "
     "Requiere certificación Banxico/CNBV como gate formal de Ola 1."),
    (58, "Oficina Financiera Integral (OFI)", "OFI", "RFP-3",
     "Visual Basic 6 (frontend legacy)", "Visual Basic 6 / backend sin definir",
     "Servidor Windows legacy", "Windows", "On-Premise",
     "10,000 (estimado — sin validar)", 10000,
     "Informix (bdinteg · bdisolic · bdiburo · bdicred · bdicheq · bdinvers · bdidigital) · PostgreSQL",
     None, "INTERACT · Bus",
     "Desarrollo In-House", "Alta / Muy Alta",
     "Usuarios de sucursales (volumen sin declarar)",
     "MVC legacy / monolito",
     "N/A",
     "Patricia Tovar / Jesús Montoya",
     "Conteo 10,000 SPLs es redondo y sin metodología. "
     "Mayor riesgo de alcance de toda Ola 1. "
     "Múltiples DBs Informix especializadas por dominio. VB6 requiere reescritura completa."),
    (2, "Administrador de Token (CAS)", "Admon Token", "RFP-5",
     "JSP", "Java 7",
     "JBoss EAP 7.2", "Linux RH8", "On-Premise",
     "50 app + 20 reuso (validar)", 50,
     "Informix 12 · PostgreSQL 9 (en actualización a 17)",
     2, "InterAct",
     "COPPEL", "Alta",
     "2 usuarios operativos (inventario interno)",
     "MVC",
     "Nagios",
     "Pamela Cárdenas / Gabriela Aguilar",
     "Habilitador transversal de autenticación — impacta todos los canales. "
     "Java 7 → Java 21 es deuda técnica confirmada. "
     "RFP-5 requiere SLA de recuperación diferenciado para CAS."),
    (3, "Empresa Net (ARES / EmpresaNet 2.0)", "Empresa Net", "RFP-2",
     "JSP", "Java 7 (backlog → Java 21)",
     "JBoss EAP 7.2 (backlog → 8.x)", "Linux RH8", "On-Premise",
     "200 app + 200 reuso (validar)", 200,
     "Informix 12",
     6, "InterAct",
     "SOLSER", "Alta",
     "2,800 usuarios concurrentes",
     "MVC · Spring Boot · Spring Security",
     "Dynatrace",
     "Pamela Cárdenas / Gutberto Gómez",
     "Portal banca empresas (personas morales): SPEI, dispersión de nómina, consultas. "
     "Cierre de expediente 21-nov-2026 — uno de los más tempranos de Ola 1."),
    (9, "Monitor de Operaciones BPI", "Monitor BPI", "RFP-5",
     "JSP", "Java 7",
     "JBoss EAP 7.2", "Linux RH8", "On-Premise",
     "Validar (funciones PostgreSQL)", 0,
     "PostgreSQL 17 (sin Informix)",
     0, "N/A",
     "SOLSER", "Media",
     "5 usuarios AMS / operación BPI",
     "Client-Server",
     "Dynatrace",
     "Pamela Cárdenas / Gabriela Aguilar",
     "Portal de monitoreo de operaciones BPI — trazas de auditoría sin datos sensibles. "
     "Sin SPLs Informix confirmados (solo funciones PostgreSQL). Lift & shift sencillo."),
    (13, "Conciliación Automática ATM / POS", "Conciliación ATM", "RFP-5",
     "N/A", "SPL (puro Informix)",
     "Informix IDS en AIX", "AIX", "On-Premise",
     "> 30 (estimado)", 30,
     "Informix",
     10, "N/A (Control-M)",
     "Desarrollo In-House", "Media",
     "5 usuarios operativos (soporte)",
     "BD / batch puro",
     "N/A",
     "José Alberto Bautista / Roberto Guzmán",
     "10 jobs Control-M activos. "
     "Puro SPL sin frontend — absorción candidata por SmartVista. "
     "Validar roadmap SmartVista antes de comprometer alcance."),
    (30, "Latinia", "Latinia", "RFP-5",
     "N/A", "Java 7",
     "Servidor propio", "Linux / AIX", "On-Premise",
     "40-50", 45,
     "Informix Core · PostgreSQL · Informix Latinia (propia)",
     2, "N/A",
     "Latinia (producto comercial)", "Media / Alta",
     "Uso masivo por canales y apps back (notificaciones)",
     "Microservicios / API",
     "N/A",
     "Gabriel Maldonado / Óscar Melo",
     "Producto comercial con BD Informix propia. "
     "Migración a AWS SNS candidata pero requiere mapeo de todas las campañas dependientes. "
     "Riesgo: notificaciones no mapeadas se pierden en producción."),
]

# ─────────────────────────────────────────── build

def build(dry_run: bool = False) -> None:
    if not DOCS.is_dir():
        sys.exit(f"No existe {DOCS}")

    fichas = sorted(DOCS.glob("Ficha_Tecnica_WAVE-*.doc"))
    exec_doc = next(DOCS.glob("Informe_Ejecutivo*.doc"), None)
    if not fichas:
        sys.exit(f"No se encontraron fichas de ola en {DOCS}")

    waves, apps = [], []
    for f in fichas:
        w, a = parse_wave(f)
        waves.append(w)
        apps.extend(a)

    program = parse_executive(exec_doc) if exec_doc else {}

    print(f"parseadas {len(waves)} olas y {len(apps)} aplicaciones")
    for w in waves:
        print(f"  {w['id']} seq={w['seq']} apps={w['app_count']} hosts={w['hosts_off']} "
              f"spls={w['spls_removed']} :: {str(w['title'])[:58]}")

    if dry_run:
        print("\n--dry-run: no se escribió brain.db")
        return

    con = sqlite3.connect(DB_PATH)
    con.executescript(DDL)

    if program:
        cols = ", ".join(program)
        con.execute(f"INSERT INTO program_info ({cols}) VALUES ({', '.join('?' * len(program))})",
                    tuple(program.values()))

    for w in waves:
        con.execute(f"INSERT INTO waves ({', '.join(w)}) VALUES ({', '.join('?' * len(w))})",
                    tuple(w.values()))
    for a in apps:
        con.execute(f"INSERT INTO applications ({', '.join(a)}) VALUES ({', '.join('?' * len(a))})",
                    tuple(a.values()))
        con.execute(
            "INSERT INTO applications_fts (id, app_id, name, description, apo_class, "
            "apo_rationale, obsolescence_drivers) VALUES (?,?,?,?,?,?,?)",
            (a["id"], a["app_id"], a["name"], a["description"], a["apo_class"],
             a["apo_rationale"], a["obsolescence_drivers"]))

    con.executemany("INSERT INTO cross_dependencies VALUES (?,?,?,?,?,?,?,?)", CROSS_DEPS)
    con.executemany("INSERT INTO open_questions VALUES (?,?,?,?)", OPEN_QUESTIONS)
    con.executemany("INSERT INTO risks VALUES (?,?,?,?,?,?,?)", RISKS)
    con.executemany(
        "INSERT INTO ams_support_proposal VALUES "
        "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        AMS_SUPPORT_PROPOSAL)

    con.executemany(
        "INSERT INTO ey_rfp_structure VALUES (?,?,?,?,?,?,?,?)",
        EY_RFP_STRUCTURE)
    con.executemany(
        "INSERT INTO ey_app_inventory VALUES "
        "(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
        EY_APP_INVENTORY)

    con.commit()

    n_apps = con.execute("SELECT COUNT(*) FROM applications").fetchone()[0]
    n_core = con.execute("SELECT COUNT(*) FROM applications WHERE is_core=1").fetchone()[0]
    spl = con.execute("SELECT COALESCE(SUM(spl_count),0) FROM applications").fetchone()[0]
    hosts = con.execute("SELECT COALESCE(SUM(hosts_released),0) FROM applications").fetchone()[0]
    n_risks = con.execute("SELECT COUNT(*) FROM risks").fetchone()[0]
    n_critical = con.execute("SELECT COUNT(*) FROM risks WHERE severity='critical'").fetchone()[0]
    n_rfps = con.execute("SELECT COUNT(*) FROM ey_rfp_structure").fetchone()[0]
    n_ey_apps = con.execute("SELECT COUNT(*) FROM ey_app_inventory").fetchone()[0]
    print(f"\nbrain.db escrito en {DB_PATH}")
    print(f"  aplicaciones={n_apps} (core={n_core}) · SPLs declarados={spl} · hosts={hosts}")
    print(f"  cross_dependencies={len(CROSS_DEPS)} · open_questions={len(OPEN_QUESTIONS)} · "
          f"risks={n_risks} (critical={n_critical})")
    n_support = con.execute("SELECT COUNT(*) FROM ams_support_proposal").fetchone()[0]
    n_fte = con.execute(
        "SELECT COALESCE(SUM(team_size_fte),0) FROM ams_support_proposal").fetchone()[0]
    print(f"  ams_support_proposals={n_support} · total_fte_propuesto={int(n_fte)}")
    print(f"  ey_rfp_structure={n_rfps} RFPs · ey_app_inventory={n_ey_apps} aplicativos")
    con.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    build(**vars(ap.parse_args()))
