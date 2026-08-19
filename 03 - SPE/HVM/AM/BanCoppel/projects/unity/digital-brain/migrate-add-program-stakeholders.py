"""
migrate-add-program-stakeholders.py  --  Unity brain.db · migración v1.1.0
Agrega tabla program_stakeholders y la puebla con el roster completo del programa.

Uso:
    python migrate-add-program-stakeholders.py
    python migrate-add-program-stakeholders.py --dry-run   # muestra SQL sin ejecutar
"""

import sqlite3, argparse
from pathlib import Path
from datetime import datetime

DB_PATH = Path(__file__).parent / "brain.db"

DDL_STAKEHOLDERS = """
CREATE TABLE IF NOT EXISTS program_stakeholders (
    id              TEXT PRIMARY KEY,
    full_name       TEXT NOT NULL,
    organization    TEXT NOT NULL
        CHECK(organization IN ('bancoppel','grupo_coppel','accenture','ey','deloitte','bpc','appwhere','vendor','unknown')),
    role_title      TEXT,
    program_role    TEXT NOT NULL
        CHECK(program_role IN (
            'executive_sponsor','program_director','program_manager',
            'track_owner','product_owner','delivery_lead','pmo','pmo_financial',
            'architect','internal_consultant','vendor_lead','vendor_team',
            'acn_lead','acn_team','acn_ams','acn_global_expert',
            'operations','stakeholder','former_vendor','delivery','unknown'
        )),
    raci            TEXT CHECK(raci IN ('responsible','accountable','consulted','informed','tbd')),
    seniority       TEXT CHECK(seniority IN ('executive','director','manager','specialist','coordinator','support','unknown')),
    confidence      TEXT CHECK(confidence IN ('confirmed','inferred','assumed')) DEFAULT 'confirmed',
    alert           TEXT,
    relevant_notes  TEXT,
    source_docs     TEXT,
    active          INTEGER DEFAULT 1,
    updated_at      TEXT DEFAULT (datetime('now'))
);

CREATE VIRTUAL TABLE IF NOT EXISTS program_stakeholders_fts USING fts5(
    id, full_name, organization, role_title, program_role, relevant_notes,
    content='program_stakeholders', content_rowid='rowid'
);
"""

STAKEHOLDERS = [
    # ── BanCoppel / Grupo Coppel ──────────────────────────────────────────────
    {
        "id": "STK-001",
        "full_name": "Juan Manuel Fernández Islas",
        "organization": "bancoppel",
        "role_title": "CIO de Servicios Financieros, Grupo Coppel",
        "program_role": "executive_sponsor",
        "raci": "accountable",
        "seniority": "executive",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Sponsor ejecutivo del programa Unity. En BanCoppel desde noviembre 2022. "
            "Responsable del presupuesto y de la narrativa ante el Consejo de Administración "
            "(sesión crítica 24-abr-2026). También lleva el programa Carteras. "
            "Identificó los 16 productos, 3 tracks, horizonte 36 meses. "
            "Tomó decisiones de salidas de talento por performance. "
            "Principal punto de escalación ejecutiva. Quiere resultados, no presentaciones bonitas."
        ),
        "source_docs": "19 Marzo - Minutas.docx; 23 Marzo - Minutas.docx; dt-gobierno.md"
    },
    {
        "id": "STK-002",
        "full_name": "Carlos López Moctezuma",
        "organization": "grupo_coppel",
        "role_title": "Director de Servicios Financieros, Grupo Coppel",
        "program_role": "executive_sponsor",
        "raci": "accountable",
        "seniority": "executive",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Responsable a nivel Grupo de todos los servicios financieros: banco, crédito Coppel "
            "y Personal Coppel. Involucró a Rodrigo Kennedy en Unity por instrucción propia. "
            "Scope estratégico más allá del banco."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-003",
        "full_name": "Pablo Madinaveitia",
        "organization": "bancoppel",
        "role_title": "Director de Transformación Unity",
        "program_role": "program_director",
        "raci": "accountable",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Nuevo director; se incorpora el 6 de abril 2026. Luis Barragán le reportará. "
            "Debe contratar subdirectores (Apolo, Transact, SmartVista). "
            "17 posiciones evaluadas, 46 personas mapeadas a su estructura, 11 vacantes abiertas, "
            "universo de 117 personas. Requiere plan de onboarding de 60-90 días. "
            "También transcrito como Medinaveitia y Mandinaveidia (errores de transcripción)."
        ),
        "source_docs": "23 Marzo - Minutas.docx; dt-gobierno.md"
    },
    {
        "id": "STK-004",
        "full_name": "Teresa (Tere) González",
        "organization": "bancoppel",
        "role_title": "Líder de Programa / Alineación Estratégica",
        "program_role": "program_manager",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "10 años en Coppel. En el proyecto formalmente desde diciembre 2025. "
            "Punto de contacto integral para negocio y tecnología durante el diagnóstico. "
            "Traduce planeación estratégica a nivel tecnológico. Coordina reuniones con Juan Manuel, "
            "dirección general y PMs. Le reportan PMs de Transact, SmartVista y Apolo. "
            "Trabaja junto a Rodrigo Kennedy (él en assessment; ella en apagar fuegos). "
            "Primer hallazgo al entrar: desastre en roles y responsabilidades."
        ),
        "source_docs": "23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-005",
        "full_name": "Luis Barragán",
        "organization": "bancoppel",
        "role_title": "Líder de Tecnología — Apolo y SmartVista / TDC",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Coordina relación entre arquitectura y proveedores. Reportará a Pablo Madinaveitia. "
            "Debe decidir si Leonardo Hernández continúa como responsable de Apolo. "
            "Estaba ausente por vacaciones en la primera semana de diagnóstico."
        ),
        "source_docs": "19 Marzo - Minutas.docx; dt-gobierno.md; dt-cronograma.md"
    },
    {
        "id": "STK-006",
        "full_name": "Sergio del Valle",
        "organization": "bancoppel",
        "role_title": "Líder de Negocio (sustituyendo a Stephany Ley)",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Lidera la parte de negocio en ausencia de Stephany Ley (licencia de maternidad). "
            "Colaboró con Juan Manuel en el roadmap actualizado de 16 productos. "
            "Candidato para sesión de estrategia / North Star."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-007",
        "full_name": "Stephany Ley",
        "organization": "bancoppel",
        "role_title": "Responsable General de Productos y Canales",
        "program_role": "track_owner",
        "raci": "accountable",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Actualmente en licencia de maternidad. Rol cubierto temporalmente por Sergio del Valle.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-008",
        "full_name": "Brenda Abril Pichardo Ramírez",
        "organization": "bancoppel",
        "role_title": "Subdirectora RMO (en transición)",
        "program_role": "pmo_financial",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": "Nunca han aplicado penalizaciones a proveedores — riesgo de exigibilidad contractual.",
        "relevant_notes": (
            "En transición para tomar la Subdirección de la RMO. Desde el nacimiento de Unity. "
            "Maneja 100% el control financiero (Excel + Dynamics). "
            "Gestiona contratos, contratación y pago de ~25-40 proveedores. "
            "Araceli Bárcenas le reporta. Conocimiento histórico invaluable. "
            "Debe alinear todas las áreas de seguridad e integrar requerimientos en desarrollos."
        ),
        "source_docs": "23 Marzo - Minutas.docx; dt-gobierno.md"
    },
    {
        "id": "STK-009",
        "full_name": "Fernanda Barbosa",
        "organization": "bancoppel",
        "role_title": "PMO — SmartVista y Apolo (reemplazo de Ana Rosa Cruz)",
        "program_role": "pmo",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": "No puede integrarse plenamente antes del 16 de abril 2026 por proceso de transferencia.",
        "relevant_notes": (
            "Reemplazo de Ana Rosa Cruz. También identificada como Ma. Fernanda Barbosa. "
            "Owners del P4900 en el DT de gobierno."
        ),
        "source_docs": "23 Marzo - Minutas.docx; dt-gobierno.md; dt-cronograma.md"
    },
    {
        "id": "STK-010",
        "full_name": "Araceli Bárcenas",
        "organization": "bancoppel",
        "role_title": "PMO — Transact (Captación y Préstamo Personal)",
        "program_role": "pmo",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "PMO para el track de Transact. Forma parte de la RMO y ya reporta a Brenda Pichardo. "
            "Referida como Ara en notas informales. Con ella el plan director tomó más forma."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-011",
        "full_name": "Ana Rosa Cruz",
        "organization": "bancoppel",
        "role_title": "PMO SmartVista y Apolo (saliente ~abril 2026)",
        "program_role": "pmo",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "confirmed",
        "active": 0,
        "alert": None,
        "relevant_notes": "PMO hasta ~abril 2026. Visibilidad de roadmap hasta 2026. Reemplazada por Fernanda Barbosa.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-012",
        "full_name": "Armando Riveros",
        "organization": "bancoppel",
        "role_title": "Owner Apificación",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Owner del equipo transversal de Apificación que habilita las integraciones de todos los tracks.",
        "source_docs": "dt-gobierno.md; capability_stakeholders"
    },
    {
        "id": "STK-013",
        "full_name": "Sergio Arellano",
        "organization": "bancoppel",
        "role_title": "Product Manager — Tarjeta de Crédito",
        "program_role": "product_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Responsable del roadmap tecnológico de la Tarjeta de Crédito. "
            "Debe congelar la versión del estado de cuenta y entregar definiciones completas "
            "del alcance R3 para liberación oportuna."
        ),
        "source_docs": "25 Marzo - Minutas.docx; dt-cronograma.md"
    },
    {
        "id": "STK-014",
        "full_name": "Arturo Valdivia / Luis Arturo Valdivieso Cruz",
        "organization": "bancoppel",
        "role_title": "Product Manager — Onboarding / Apolo",
        "program_role": "product_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "inferred",
        "alert": "Nombre con variantes (Alfredo Valdivieso en una transcripción) — confirmar nombre exacto.",
        "relevant_notes": (
            "Responsable del roadmap tecnológico del producto Onboarding/Apolo. "
            "Juan Manuel solicitó sesión con él para definir estrategia de originación (pantalla única)."
        ),
        "source_docs": "23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-015",
        "full_name": "Leonardo (Leo) Hernández",
        "organization": "bancoppel",
        "role_title": "Delivery Lead — Apolo y SmartVista",
        "program_role": "delivery_lead",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Responsable de la ejecución/delivery de Apolo y TDC. "
            "Fue movido desde cobranza para ayudar en tarjetas. "
            "Luis Barragán debe decidir si Leo continúa como responsable de Apolo."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-016",
        "full_name": "Sandra Figueroa",
        "organization": "bancoppel",
        "role_title": "Tech Lead — Transact",
        "program_role": "delivery_lead",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Equivalente de Leonardo Hernández para el track de Transact. "
            "Tiene fortaleza técnica pero faltaba complementar con capa funcional. "
            "Recibe solicitudes de negocio sin priorización clara."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-017",
        "full_name": "Armando Garcia",
        "organization": "bancoppel",
        "role_title": "PM SmartVista",
        "program_role": "delivery_lead",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "PM de SmartVista en BanCoppel. Identificado en capability_stakeholders del brain.",
        "source_docs": "capability_stakeholders"
    },
    {
        "id": "STK-018",
        "full_name": "David Ruelas",
        "organization": "bancoppel",
        "role_title": "Responsable de Crédito",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "La evaluación y administración del crédito pasará a ser su responsabilidad. Referido como Ruedas en algunas notas.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-019",
        "full_name": "Iván de la O",
        "organization": "bancoppel",
        "role_title": "Responsable de Cobranza",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Responsable del frente de cobranza. Referenciado en la estructura del programa.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-020",
        "full_name": "Alondra Bastidas",
        "organization": "bancoppel",
        "role_title": "Responsable de Integración e Interoperabilidad",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": "Diferente de Alondra Cárdenas (Change Management).",
        "relevant_notes": "Responsable del frente de integración e interoperabilidad. Referida como Londra Bastidas en una minuta.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-021",
        "full_name": "Alondra Cárdenas",
        "organization": "bancoppel",
        "role_title": "Responsable de Change Management",
        "program_role": "stakeholder",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Organizativamente con Brenda Pichardo. Ha hecho capacitaciones de change management. "
            "Change Management actual es táctico (manuales, capacitación), no estratégico."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-022",
        "full_name": "Arcadio",
        "organization": "bancoppel",
        "role_title": "Arquitecto Empresarial de Grupo / Líder de Datos",
        "program_role": "architect",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "inferred",
        "alert": "Apellido no confirmado en fuentes.",
        "relevant_notes": (
            "Responsable de arquitectura empresarial a nivel de grupo y del proyecto Atlas (Golden Record / MDM). "
            "Su scope impacta banco y tienda."
        ),
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-023",
        "full_name": "Mercedes Espinosa (María Mercedes)",
        "organization": "bancoppel",
        "role_title": "Líder de Arquitectura — Grupo y Servicios Financieros",
        "program_role": "architect",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "inferred",
        "alert": None,
        "relevant_notes": (
            "Establece lineamientos arquitectónicos a nivel grupo. "
            "Rol más de validación/proceso arquitectónico (compliance/certificación) que de definición estratégica."
        ),
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-024",
        "full_name": "Miguel Bucio",
        "organization": "bancoppel",
        "role_title": "Responsable Interno de Arquitectura / Proceso Arquitectónico Unity",
        "program_role": "architect",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Lleva la gestión del proceso de arquitectura. Trabaja con Luis Barragán. "
            "Tiene conocimiento de la arquitectura documentada para las carpetas CNBV. "
            "Con él el track interno de arquitectura reemplaza a Rino Inside."
        ),
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-025",
        "full_name": "Raúl Goycolea",
        "organization": "bancoppel",
        "role_title": "Arquitecto Senior",
        "program_role": "architect",
        "raci": "consulted",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Referente técnico senior a mantener cercano. Mencionado junto con Alex como referentes técnicos clave.",
        "source_docs": "19 Marzo - Minutas.docx"
    },
    {
        "id": "STK-026",
        "full_name": "Erika Mata",
        "organization": "bancoppel",
        "role_title": "CISO / Cabeza de OSI (Oficina de Seguridad de la Información)",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": "Agenda muy saturada — conseguir 30 minutos ya sería un logro. Involucrar desde el inicio de decisiones de arquitectura.",
        "relevant_notes": "CISO del banco. Responsable del frente de seguridad transversal. Delegará parte del trabajo en Frank Eduardo Ortiz Iglesias.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-027",
        "full_name": "Frank Eduardo Ortiz Iglesias",
        "organization": "bancoppel",
        "role_title": "Gerente de Seguridad — OSI",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Contacto operativo de apoyo en temas de seguridad e integración con OSI. Reporta a Erika Mata.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-028",
        "full_name": "Cristóbal Iturbe",
        "organization": "bancoppel",
        "role_title": "Responsable de Estrategia 2030 — Servicios Financieros",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Lleva la estrategia 2030 para servicios financieros. Frente de negocio más que tecnología. Interlocutor clave para el North Star.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-029",
        "full_name": "Cristian Sasueta",
        "organization": "bancoppel",
        "role_title": "Responsable de Datos, Migración y Atlas (temporal)",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Cubre temporalmente por Carolina. Responsable del track de datos/migración y del programa Atlas.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-030",
        "full_name": "Daniel Ángeles Baltazar",
        "organization": "bancoppel",
        "role_title": "Responsable de Infraestructura / IMS / Ambientes",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Juan Manuel no lo ve como el perfil correcto para liderar la estrategia; lo ubica en un subtrack de infraestructura o IMS. Coordinó la entrega de la tabla de responsables de Legacy.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-031",
        "full_name": "Arturo Pérez",
        "organization": "bancoppel",
        "role_title": "Coordinador / Líder del Frente Legacy",
        "program_role": "track_owner",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Coordina al grupo de responsables de sistemas legacy. Fungirá como referente principal del frente Legacy. Karina Zepeda lo conoce.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-032",
        "full_name": "José Luis Bueno",
        "organization": "bancoppel",
        "role_title": "Responsable del Programa Carteras",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Programa Carteras tiene dependencias relevantes con Unity. Al menos 3 proyectos: desacoplamiento de reglas, modernización de infraestructura, capacidades flexibles.",
        "source_docs": "23 Marzo - Minutas.docx; dt-cronograma.md"
    },
    {
        "id": "STK-033",
        "full_name": "Leticia Díaz",
        "organization": "bancoppel",
        "role_title": "Portfolio Manager (demanda TI-Negocio)",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Enlace entre negocio y TI para gestión de demanda, asignación de células y disponibilidad de equipos.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-034",
        "full_name": "Itzel Vargas",
        "organization": "bancoppel",
        "role_title": "Responsable de Priorización y Asignación de Recursos",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Operación organizada en Value Streams / Portafolios.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-035",
        "full_name": "Cinthia Ramírez",
        "organization": "bancoppel",
        "role_title": "HRBP — Tecnología SSFF",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "HRBP para todo el ámbito de tecnología de servicios financieros.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-036",
        "full_name": "Octavio Vázquez",
        "organization": "bancoppel",
        "role_title": "Director de Operaciones (Transact)",
        "program_role": "stakeholder",
        "raci": "consulted",
        "seniority": "director",
        "confidence": "inferred",
        "alert": None,
        "relevant_notes": "Firmó compromisos de validación funcional canal App el 12-jun-2026. Referido como Octavio en minutas.",
        "source_docs": "23 Marzo - Minutas.docx; dt-cronograma.md"
    },
    {
        "id": "STK-037",
        "full_name": "José Emiliano Palma",
        "organization": "bancoppel",
        "role_title": "TBD — Gobierno o Negocio",
        "program_role": "stakeholder",
        "raci": "tbd",
        "seniority": "unknown",
        "confidence": "assumed",
        "alert": "Rol no confirmado — preguntar a Tere para definir su ubicación.",
        "relevant_notes": "Aún no queda claro si se integrará del lado de gobierno o permanecerá del lado de negocio.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-038",
        "full_name": "Rodrigo Kennedy",
        "organization": "grupo_coppel",
        "role_title": "Especialista en Estrategia y Assessment — Change Management",
        "program_role": "internal_consultant",
        "raci": "consulted",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": (
            "Reporta a Gaby Lozada. Involucrado por instrucción de Carlos López-Moctezuma. "
            "3 años en BanCoppel, 20 años previos de consultor. "
            "Realizó diagnóstico de Unity (dic 2025 – ene 2026): 61-65 stakeholders entrevistados, "
            "200+ hallazgos. Conclusión: 75% de los problemas son de gobierno y personas, no tecnológicos. "
            "Identificó 60% de rotación del equipo."
        ),
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-039",
        "full_name": "Gabriela (Gaby) Lozada",
        "organization": "grupo_coppel",
        "role_title": "Líder del Equipo de Estrategia Grupo (ex-Bain)",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "director",
        "confidence": "inferred",
        "alert": "También referida como Daniela Lozada en una sección — confirmar.",
        "relevant_notes": "Lidera el área de Estrategia a nivel Grupo. Rodrigo Kennedy le reporta. Ex-Bain.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-040",
        "full_name": "Carelli",
        "organization": "bancoppel",
        "role_title": "Chief of Staff (Juan Manuel Fernández Islas)",
        "program_role": "operations",
        "raci": "informed",
        "seniority": "coordinator",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Punto de contacto con stakeholders para Juan Manuel. Apoyo para coordinación de reuniones y agendas.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    {
        "id": "STK-041",
        "full_name": "Lisbeth",
        "organization": "bancoppel",
        "role_title": "Asistente Administrativa / Logística",
        "program_role": "operations",
        "raci": "informed",
        "seniority": "support",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Gestión de espacios y logística de sesiones. Referida como Lis en algunas minutas.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-042",
        "full_name": "Sharon",
        "organization": "bancoppel",
        "role_title": "Directora de Talento",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "director",
        "confidence": "inferred",
        "alert": "Apellido no confirmado.",
        "relevant_notes": "Comunicó la cifra de 60% de rotación del equipo Unity.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-043",
        "full_name": "Ricardo",
        "organization": "bancoppel",
        "role_title": "Control Financiero / Presupuestal",
        "program_role": "stakeholder",
        "raci": "informed",
        "seniority": "manager",
        "confidence": "assumed",
        "alert": "Apellido no confirmado.",
        "relevant_notes": "Junto con Brenda Pichardo lleva las cifras de desviación presupuestal.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
    # ── Accenture ─────────────────────────────────────────────────────────────
    {
        "id": "STK-050",
        "full_name": "Pablo Lorenzo Díaz",
        "organization": "accenture",
        "role_title": "Lead del Equipo ACN en el Engagement",
        "program_role": "acn_lead",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Lead visible del equipo Accenture. Vino de España para el engagement. Asignado al plan director y gobierno del programa.",
        "source_docs": "19 Marzo - Minutas.docx; 25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-051",
        "full_name": "Karina Nayeli Zepeda Arroyo",
        "organization": "accenture",
        "role_title": "Delivery Lead ACN",
        "program_role": "acn_lead",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "inferred",
        "alert": None,
        "relevant_notes": "Participante en todas las sesiones clave. Conoce bien a Arturo Pérez — puede facilitar el contacto con el frente Legacy.",
        "source_docs": "dt-gobierno.md"
    },
    {
        "id": "STK-052",
        "full_name": "Salomón Monroy",
        "organization": "accenture",
        "role_title": "Especialista ACN — Delivery",
        "program_role": "acn_team",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Participante ACN en sesiones de diagnóstico. Debe alinearse con Pablo Madinaveitia en fase 0.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-053",
        "full_name": "Joaquín Navajas Helguero",
        "organization": "accenture",
        "role_title": "Especialista ACN — Delivery / Gobierno",
        "program_role": "acn_team",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Gestiona la agenda de las 12 sesiones introductorias con stakeholders del cliente.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-054",
        "full_name": "Alejandro Alonso García",
        "organization": "accenture",
        "role_title": "Especialista ACN — Delivery",
        "program_role": "acn_team",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Participante ACN en todas las sesiones principales.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-055",
        "full_name": "Omar Patrón",
        "organization": "accenture",
        "role_title": "Especialista ACN — Gobierno y Control Técnico",
        "program_role": "acn_team",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Relevante por los temas de governance y control técnico.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-056",
        "full_name": "Lukasz Pietrzyk",
        "organization": "accenture",
        "role_title": "Especialista Global ACN — Core Banking",
        "program_role": "acn_global_expert",
        "raci": "consulted",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Global specialist de Accenture con expertise en core banking. Refuerza el trabajo en sitio. Referido como Lucas Pietres en notas por transcripción.",
        "source_docs": "23 Marzo - Minutas.docx; 25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-057",
        "full_name": "José Luis Navas",
        "organization": "accenture",
        "role_title": "Especialista Global ACN",
        "program_role": "acn_global_expert",
        "raci": "consulted",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Apoya para armar el outline/board del readout del 24 de abril.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-058",
        "full_name": "Pavel Vilosski",
        "organization": "accenture",
        "role_title": "Especialista Global ACN",
        "program_role": "acn_global_expert",
        "raci": "consulted",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Global specialist. Referenciado junto con Navas y Lukasz para el readout del 24 de abril.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-059",
        "full_name": "Joaquín Pichardo",
        "organization": "accenture",
        "role_title": "Especialista ACN — AMS / Operación",
        "program_role": "acn_ams",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Expuso el enfoque de takeover formal desde el release 3 (junio 2026).",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-060",
        "full_name": "Gabriela (Gaby) Maximiliano",
        "organization": "accenture",
        "role_title": "AMS / Takeover Lead — ACN",
        "program_role": "acn_ams",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Vinculada al frente de AMS/takeover/soporte. Tomó assets y plantillas para estructurar el pre y post del takeover.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-061",
        "full_name": "Alfredo García",
        "organization": "accenture",
        "role_title": "Responsable del Plan de Takeover / Soporte — ACN",
        "program_role": "acn_ams",
        "raci": "responsible",
        "seniority": "manager",
        "confidence": "confirmed",
        "alert": "Juan Manuel expresó molestia porque llevaba 3 semanas en el plan sin avanzar suficientemente.",
        "relevant_notes": "Responsable de armar el plan de takeover/soporte postproducción.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    # ── EY (incumbente Transact — COMPETIDOR) ─────────────────────────────────
    {
        "id": "STK-070",
        "full_name": "Angélica María Tolosa Bravo",
        "organization": "ey",
        "role_title": "Líder del Track Core Bancario / Transact — EY",
        "program_role": "vendor_lead",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": "COMPETIDOR: EY es incumbente en Transact. NUNCA compartir análisis de arquitectura con EY. Validaciones van a BanCoppel, no a EY.",
        "relevant_notes": (
            "Líder de EY en el frente de Temenos Transact. Construye el plan director de Transact. "
            "Actúa como puente entre negocio y tecnología para Transact."
        ),
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-071",
        "full_name": "Gloria Cecilia Coll Peña",
        "organization": "ey",
        "role_title": "Plan Director Transact — EY",
        "program_role": "vendor_team",
        "raci": "informed",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": "COMPETIDOR: EY.",
        "relevant_notes": "Levantamientos, riesgos, dependencias y armado del plan director de Transact. Equipo EY suma 4 personas total.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-072",
        "full_name": "Miguel Medina",
        "organization": "ey",
        "role_title": "Arquitectura Aplicativa e Integraciones — EY",
        "program_role": "vendor_team",
        "raci": "informed",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": "COMPETIDOR: EY.",
        "relevant_notes": "Concentrado en arquitectura aplicativa, integraciones y arquitectura transitoria/objetivo para Transact.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-073",
        "full_name": "Miguel Romo",
        "organization": "ey",
        "role_title": "Consolidación y Análisis — EY",
        "program_role": "vendor_team",
        "raci": "informed",
        "seniority": "specialist",
        "confidence": "confirmed",
        "alert": "COMPETIDOR: EY.",
        "relevant_notes": "Apoya en consolidación y análisis dentro del equipo de EY para el plan director de Transact.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    # ── BPC / SmartVista ──────────────────────────────────────────────────────
    {
        "id": "STK-080",
        "full_name": "Alfredo Aguilar",
        "organization": "appwhere",
        "role_title": "Lead Appwhere",
        "program_role": "vendor_lead",
        "raci": "responsible",
        "seniority": "director",
        "confidence": "confirmed",
        "alert": None,
        "relevant_notes": "Proveedor de App Móvil. Familiarizado con el DUD (Documento Único de Datos).",
        "source_docs": "capability_stakeholders; 23 Marzo - Minutas.docx"
    },
    # ── Deloitte / Ex-vendors ─────────────────────────────────────────────────
    {
        "id": "STK-090",
        "full_name": "Daniela (apellido no confirmado)",
        "organization": "deloitte",
        "role_title": "Gobierno del Programa (ex-encargada)",
        "program_role": "former_vendor",
        "raci": "informed",
        "seniority": "unknown",
        "confidence": "assumed",
        "active": 0,
        "alert": None,
        "relevant_notes": "Anteriormente llevaba el gobierno del programa. Deloitte se enfocó en remediación de tarjeta de crédito (salió en marzo). Nombre exacto no confirmado.",
        "source_docs": "25 Marzo - Minutas.docx"
    },
    {
        "id": "STK-091",
        "full_name": "Rino (Rino Inside)",
        "organization": "vendor",
        "role_title": "Consultor de Arquitectura — Apolo (saliente)",
        "program_role": "former_vendor",
        "raci": "informed",
        "seniority": "specialist",
        "confidence": "confirmed",
        "active": 0,
        "alert": None,
        "relevant_notes": "Consultoría de arquitectura para Apolo. Sale en abril 2026 porque Miguel Bucio trae un track interno de arquitectura.",
        "source_docs": "23 Marzo - Minutas.docx"
    },
]


def main(dry_run: bool = False) -> None:
    if not DB_PATH.exists():
        print(f"ERROR: brain.db no encontrado en {DB_PATH}")
        return

    print(f"Conectando a {DB_PATH}")
    con = sqlite3.connect(str(DB_PATH))
    cur = con.cursor()

    # Verificar si la tabla ya existe
    cur.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='program_stakeholders'")
    already_exists = cur.fetchone() is not None

    if dry_run:
        print("[DRY-RUN] Generando DDL y datos sin ejecutar...\n")
        print(DDL_STAKEHOLDERS)
        print(f"\n-- {len(STAKEHOLDERS)} stakeholders a insertar --")
        for s in STAKEHOLDERS:
            print(f"  {s['id']} | {s['full_name']} | {s['organization']} | {s['program_role']}")
        return

    # Crear tabla si no existe
    if not already_exists:
        print("Creando tabla program_stakeholders y FTS...")
        for stmt in DDL_STAKEHOLDERS.strip().split(";"):
            stmt = stmt.strip()
            if stmt:
                cur.execute(stmt)
        print("OK: tabla creada.")
    else:
        print("INFO: tabla program_stakeholders ya existe — sincronizando datos.")

    # Insertar / actualizar stakeholders
    now = datetime.now().strftime("%Y-%m-%dT%H:%M:%S")
    inserted = 0
    updated = 0

    for s in STAKEHOLDERS:
        cur.execute("SELECT id FROM program_stakeholders WHERE id = ?", (s["id"],))
        exists = cur.fetchone()

        row = (
            s["id"],
            s["full_name"],
            s["organization"],
            s.get("role_title"),
            s["program_role"],
            s.get("raci", "tbd"),
            s.get("seniority", "unknown"),
            s.get("confidence", "confirmed"),
            s.get("alert"),
            s.get("relevant_notes"),
            s.get("source_docs"),
            s.get("active", 1),
            now,
        )

        if exists:
            cur.execute("""
                UPDATE program_stakeholders SET
                    full_name=?, organization=?, role_title=?, program_role=?,
                    raci=?, seniority=?, confidence=?, alert=?,
                    relevant_notes=?, source_docs=?, active=?, updated_at=?
                WHERE id=?
            """, row[1:] + (s["id"],))
            updated += 1
        else:
            cur.execute("""
                INSERT INTO program_stakeholders
                    (id, full_name, organization, role_title, program_role,
                     raci, seniority, confidence, alert, relevant_notes,
                     source_docs, active, updated_at)
                VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)
            """, row)
            inserted += 1

    # Reconstruir FTS
    print("Reconstruyendo FTS...")
    try:
        cur.execute("INSERT INTO program_stakeholders_fts(program_stakeholders_fts) VALUES('rebuild')")
    except Exception as e:
        print(f"  FTS rebuild warning: {e}")

    con.commit()
    con.close()

    total = len(STAKEHOLDERS)
    print(f"\nSUCCESS: {inserted} nuevos + {updated} actualizados = {total} stakeholders en brain.db")

    # Resumen por organización
    from collections import Counter
    orgs = Counter(s["organization"] for s in STAKEHOLDERS)
    for org, n in sorted(orgs.items(), key=lambda x: -x[1]):
        print(f"  {org:20s} {n}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Migra program_stakeholders a Unity brain.db")
    parser.add_argument("--dry-run", action="store_true", help="Solo muestra SQL sin ejecutar")
    args = parser.parse_args()
    main(dry_run=args.dry_run)
