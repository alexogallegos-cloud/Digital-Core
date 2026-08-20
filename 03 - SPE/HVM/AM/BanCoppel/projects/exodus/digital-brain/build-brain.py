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
    con.commit()

    n_apps = con.execute("SELECT COUNT(*) FROM applications").fetchone()[0]
    n_core = con.execute("SELECT COUNT(*) FROM applications WHERE is_core=1").fetchone()[0]
    spl = con.execute("SELECT COALESCE(SUM(spl_count),0) FROM applications").fetchone()[0]
    hosts = con.execute("SELECT COALESCE(SUM(hosts_released),0) FROM applications").fetchone()[0]
    n_risks = con.execute("SELECT COUNT(*) FROM risks").fetchone()[0]
    n_critical = con.execute("SELECT COUNT(*) FROM risks WHERE severity='critical'").fetchone()[0]
    print(f"\nbrain.db escrito en {DB_PATH}")
    print(f"  aplicaciones={n_apps} (core={n_core}) · SPLs declarados={spl} · hosts={hosts}")
    print(f"  cross_dependencies={len(CROSS_DEPS)} · open_questions={len(OPEN_QUESTIONS)} · "
          f"risks={n_risks} (critical={n_critical})")
    con.close()


if __name__ == "__main__":
    ap = argparse.ArgumentParser()
    ap.add_argument("--dry-run", action="store_true")
    build(**vars(ap.parse_args()))
