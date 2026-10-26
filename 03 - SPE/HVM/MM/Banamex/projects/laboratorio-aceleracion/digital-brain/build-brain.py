#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
build-brain.py — Digital Brain del Laboratorio de Aceleracion (Banamex).

Construye lab-brain.db desde las fuentes del proyecto:
  - Anexo B firmado          -> capa contractual
  - Diseno de solucion v8    -> capa de laboratorio
  - plan-setup.md            -> capa de setup
  - brain.db del core        -> federacion por referencia (NO se duplica el corpus)

Uso:  python build-brain.py
"""
import sqlite3
import sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
DB = BASE / "lab-brain.db"

# El brain del core se federa por referencia. Ruta relativa al arbol de Banamex.
CORE_BRAIN = BASE.parents[2] / "systems" / "core" / "unisys" / "digital-brain" / "brain.db"


# --------------------------------------------------------------------------
# Esquema
# --------------------------------------------------------------------------

SCHEMA = """
-- ---------- Capa 1: contrato (Anexo B) ----------
CREATE TABLE contrato (
    clave        TEXT PRIMARY KEY,
    valor        TEXT NOT NULL,
    fuente       TEXT
);

CREATE TABLE entregables_contractuales (
    num              INTEGER PRIMARY KEY,
    nombre           TEXT NOT NULL,
    contenido_minimo TEXT,
    criterio         TEXT,
    frecuencia       TEXT,
    formato          TEXT,
    vence            TEXT,
    estado           TEXT
);

CREATE TABLE compromisos_servicio (
    id           INTEGER PRIMARY KEY,
    requerimiento TEXT NOT NULL,
    aprobador    TEXT,
    tiempo       TEXT,
    nivel        TEXT,
    pct_pena     REAL
);

CREATE TABLE tallas (
    talla           TEXT PRIMARY KEY,
    orden           INTEGER,
    consumo_desde   INTEGER,
    consumo_hasta   INTEGER,
    pct_servicio    REAL,
    arquetipos_cupo INTEGER,
    usuarios        INTEGER,
    pipelines_mes   INTEGER,
    dominios_core   INTEGER,
    refrescos_datos INTEGER,
    ventanas_prueba INTEGER,
    restauraciones  INTEGER
);

CREATE TABLE penas (
    nivel     TEXT PRIMARY KEY,
    casos     TEXT,
    pct_evento REAL,
    tope      REAL
);

CREATE TABLE criterios_arranque (
    num       INTEGER PRIMARY KEY,
    criterio  TEXT NOT NULL,
    como_se_acredita TEXT,
    estado    TEXT
);

-- ---------- Capa 2: laboratorio ----------
CREATE TABLE arquetipos (
    id            TEXT PRIMARY KEY,
    nombre        TEXT NOT NULL,
    descripcion   TEXT,
    consumo_aws   INTEGER,
    corridas_mes  INTEGER,
    componentes   TEXT,
    estado        TEXT
);

CREATE TABLE capas_lab (
    num        INTEGER PRIMARY KEY,
    nombre     TEXT NOT NULL,
    proposito  TEXT,
    control    TEXT
);

CREATE TABLE compuertas (
    id        TEXT PRIMARY KEY,
    orden     INTEGER,
    de_etapa  TEXT,
    a_etapa   TEXT,
    evidencia TEXT
);

CREATE TABLE stack (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    categoria   TEXT NOT NULL,
    componente  TEXT NOT NULL,
    rol         TEXT
);

CREATE TABLE rutas_codigo (
    id           TEXT PRIMARY KEY,
    nombre       TEXT NOT NULL,
    quien_dispara TEXT,
    credenciales TEXT,
    donde_vive   TEXT,
    recomendada  INTEGER
);

-- ---------- Capa 3: setup ----------
CREATE TABLE fases (
    id        TEXT PRIMARY KEY,
    orden     INTEGER,
    nombre    TEXT NOT NULL,
    ventana   TEXT,
    estado    TEXT,
    inicio    TEXT,
    fin       TEXT,
    critica   INTEGER,
    en_sow    INTEGER,
    clausula  TEXT
);

CREATE TABLE semanas (
    num     INTEGER PRIMARY KEY,
    inicio  TEXT NOT NULL,
    fin     TEXT NOT NULL,
    foco    TEXT,
    riesgo  TEXT
);

CREATE TABLE hitos (
    id        TEXT PRIMARY KEY,
    fecha     TEXT NOT NULL,
    nombre    TEXT NOT NULL,
    tipo      TEXT,
    nota      TEXT
);

-- ---------- Capa 6: equipo (guidelines IMS y Solution Architect) ----------
CREATE TABLE roles (
    id           TEXT PRIMARY KEY,
    rol          TEXT NOT NULL,
    bc           TEXT,
    nivel        TEXT,
    tier         TEXT,
    ubicacion    TEXT,
    frente       TEXT,
    reporta_a    TEXT,
    fte_setup    REAL,
    fte_steady   REAL,
    responsabilidad TEXT,
    origen       TEXT,
    fte_ia_setup  REAL,
    fte_ia_steady REAL,
    palanca_ia    TEXT
);

CREATE TABLE limites_ia (
    id        TEXT PRIMARY KEY,
    limite    TEXT NOT NULL,
    por_que   TEXT,
    piso      TEXT
);

CREATE TABLE supuestos (
    id          TEXT PRIMARY KEY,
    supuesto    TEXT NOT NULL,
    sustento    TEXT,
    si_cae      TEXT,
    impacto_fte TEXT,
    estado      TEXT
);

CREATE TABLE raci (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    entregable  TEXT NOT NULL,
    rol_id      TEXT NOT NULL,
    letra       TEXT NOT NULL,
    FOREIGN KEY (rol_id) REFERENCES roles(id)
);

CREATE TABLE actividades (
    id          TEXT PRIMARY KEY,
    fase        TEXT NOT NULL,
    workstream  TEXT,
    actividad   TEXT NOT NULL,
    entregable  TEXT,
    depende_de  TEXT,
    estado      TEXT,
    semana      INTEGER,
    en_sow      INTEGER,
    FOREIGN KEY (fase) REFERENCES fases(id)
);

CREATE TABLE entregables_setup (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    nombre      TEXT NOT NULL,
    fase        TEXT,
    contractual INTEGER,
    nota        TEXT
);

-- ---------- Capa 4: iniciativas estrategicas ----------
CREATE TABLE iniciativas (
    id            TEXT PRIMARY KEY,
    nombre        TEXT NOT NULL,
    descripcion   TEXT,
    en_anexo_b    INTEGER,
    vehiculo      TEXT,
    estado        TEXT
);

CREATE TABLE habilitadores (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    iniciativa  TEXT NOT NULL,
    tipo        TEXT,
    que_aporta  TEXT,
    origen      TEXT,
    FOREIGN KEY (iniciativa) REFERENCES iniciativas(id)
);

CREATE TABLE brechas (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    iniciativa  TEXT NOT NULL,
    brecha      TEXT NOT NULL,
    impacto     TEXT,
    quien_resuelve TEXT,
    estado      TEXT,
    FOREIGN KEY (iniciativa) REFERENCES iniciativas(id)
);

-- ---------- Capa 5: federacion y gobierno ----------
CREATE TABLE brains_federados (
    nombre     TEXT PRIMARY KEY,
    ruta       TEXT NOT NULL,
    api        TEXT,
    que_aporta TEXT,
    disponible INTEGER
);

CREATE TABLE core_snapshot (
    tabla   TEXT PRIMARY KEY,
    filas   INTEGER,
    que_es  TEXT
);

CREATE TABLE decisiones_abiertas (
    id            TEXT PRIMARY KEY,
    decision      TEXT NOT NULL,
    por_que_bloquea TEXT,
    quien_decide  TEXT,
    estado        TEXT
);

CREATE TABLE stats (
    clave TEXT PRIMARY KEY,
    valor INTEGER
);

-- ---------- Busqueda ----------
CREATE VIRTUAL TABLE actividades_fts USING fts5(
    id UNINDEXED, actividad, entregable, workstream,
    content='actividades', content_rowid='rowid'
);
"""


# --------------------------------------------------------------------------
# Datos: capa contractual (Anexo B firmado, source/sow/)
# --------------------------------------------------------------------------

CONTRATO = [
    ("instrumento", "Anexo B del Contrato Maestro de Prestación de Servicios 2022.021519", "Anexo B, encabezado"),
    ("servicio", "CMO, Accenture Cloud Manager and Optimizer", "Anexo B, cláusula segunda"),
    ("vigencia_inicio", "2026-10-12", "Anexo B, cláusula primera"),
    ("vigencia_fin", "2029-10-11", "Anexo B, cláusula primera"),
    ("vigencia_anios", "3", "Anexo B, cláusula primera"),
    ("alcance", "Habilitación, activación y operación de un laboratorio Cloud aislado para construir, "
                "integrar y probar productos digitales contra servicios de Core emulados y datos sintéticos, "
                "prestado como servicio administrado", "Anexo B, cláusula tercera"),
    ("exclusion_critica", "La conexión con entornos productivos o con el Core real no forma parte del alcance",
     "Anexo B, cláusula tercera"),
    ("componentes", "Habilitación inicial, Activación, Operación y Soporte", "Anexo B, cláusula cuarta"),
    ("ubicación", "Remota", "Anexo B, cláusula cuarta"),
    ("horario", "Lunes a viernes, 9 a 18 horas, hora Centro de Ciudad de México", "Anexo B, cláusula cuarta"),
    ("region_aws", "mx-central-1, México Central, Querétaro", "Diseño de solución v8"),
    ("cuota_arranque_usd", "30000", "Anexo B, cláusula sexta"),
    ("aceptacion_dias_habiles", "10", "Anexo B, proceso de aceptación"),
    ("aceptacion_silencio", "El silencio equivale a aceptación pasados 10 días habiles", "Anexo B"),
    ("propiedad_intelectual", "Todos los Entregables son propiedad exclusiva de Banamex. Accenture no puede "
                              "reutilizarlos, comercializarlos ni usarlos para entrenar modelos de IA", "Anexo B, premisas"),
    ("subcontratación", "Prohibida", "Anexo B, cláusula decima primera"),
    ("terminacion_aviso_dias", "90", "Anexo B, vigencia y terminación"),
    ("pena_tope_mensual_pct", "5", "Anexo B, cláusula octava"),
    ("escalamiento_acn", "Nivel A Responsable Cloud, Nivel B Responsable Servicio Laboratorio", "Anexo B"),
    ("escalamiento_cliente", "Nivel A Technology Architecture, Nivel B Head of Architecture", "Anexo B"),
    ("salida", "Al cierre se entrega código, evidencia y datos en formatos abiertos, con certificación de borrado "
               "a los 30 días", "Anexo B, cláusula decima"),
]

ENTREGABLES_CONTRACTUALES = [
    (1, "Diseño de arquitectura y seguridad",
     "Arquitectura lógica, segmentación, identidad, cifrado, trazabilidad, conectividad permitida y guardrails",
     "Revisión conjunta con Arquitectura y Seguridad; observaciones criticas resueltas o aceptadas",
     "Única, primer mes", "Presentacion ejecutiva", "2026-11-11", "PENDIENTE"),
    (2, "Laboratorio base habilitado",
     "Cuentas, red, identidad, auditoría, repositorios, pipeline, catálogo y sandbox inicial",
     "Ejecución satisfactoria de pruebas de conectividad, acceso, despliegue, auditoría y aislamiento",
     "Única, primer mes", "Presentacion ejecutiva", "2026-11-11", "PENDIENTE"),
    (3, "Reporte de consumo de infraestructura y soporte",
     "Desglose de elementos por infraestructura y servicios",
     "Desglose entregado", "Mensual", "Presentacion ejecutiva", "", "PENDIENTE"),
    (4, "Reporte de actividades realizadas por el equipo de SDLC",
     "Detalle de las actividades realizadas por el equipo de SDLC",
     "Detalle entregado", "Mensual", "Presentacion ejecutiva", "", "PENDIENTE"),
    (5, "Módulos de código para plantillas de arquetipos",
     "Evidencia de código en repositorios",
     "Evidencia en repositorio", "Mensual", "Terraform", "", "PENDIENTE"),
]

COMPROMISOS = [
    (1, "Activar un arquetipo del catálogo", "Owner de Banamex", "3 días habiles", "B", 1.0),
    (2, "Crear un producto en un arquetipo vigente", "Lider del equipo", "1 dia habil", "B", 1.0),
    (3, "Cambiar cuotas, escenarios o presupuestos", "Operación de Accenture", "1 dia habil", "B", 1.0),
    (4, "Alta de una persona", "Owner de Banamex", "2 días habiles", "B", 1.0),
    (5, "Baja de una persona", "Owner de Banamex", "1 dia habil", "A", 3.0),
    (6, "Diseñar un arquetipo nuevo a la medida, sin cargo dentro del cupo", "Owner de Banamex", "10 días habiles", "B", 1.0),
    (7, "Integrar una herramienta fuera del catálogo", "Comite de la iniciativa", "Estimación en 5 días", "B", 1.0),
    (8, "Incidente de severidad 1", "No aplica", "Atención en 30 minutos", "A", 3.0),
    (9, "Incidente de severidad 2", "No aplica", "Atención en 2 horas", "A", 3.0),
    (10, "Incidentes de severidad 3 y 4", "No aplica", "Mismo dia y siguiente dia habil", "B", 1.0),
]

# consumo, pct servicio y cupo: Anexo B cláusula sexta. Volumenes: Anexo B cláusula cuarta.
TALLAS = [
    ("xSmall", 1, 0, 20000, 45.0, 2, 10, 500, 2, 2, 1, 1),
    ("Small", 2, 20000, 30000, 45.0, 3, 20, 1500, 3, 4, 2, 2),
    ("Medium", 3, 30000, 60000, 45.0, 4, 40, 4000, 5, 8, 4, 3),
    ("Large", 4, 60000, 100000, 40.0, 8, 60, 8000, 8, 12, 6, 4),
    ("XL", 5, 100000, None, 37.0, 15, 80, 15000, 12, 20, 8, 6),
]

PENAS = [
    ("A", "Incidente de severidad 1 o 2 fuera de tiempo; laboratorio base no disponible más alla del tiempo de "
          "restablecimiento; incidente de seguridad, incluida una baja de persona atrasada que deje un acceso abierto",
     3.0, 5.0),
    ("B", "Solicitudes de la tabla de requerimientos fuera de tiempo; incidentes de severidad 3 y 4 por encima del "
          "umbral; reportes mensuales atrasados", 1.0, 3.0),
    ("Combinado", "Nivel A más Nivel B en el mismo mes", None, 5.0),
]

CRITERIOS_ARRANQUE = [
    (1, "Alta de usuarios: los usuarios designados por Banamex cuentan con acceso habilitado al Laboratorio",
     "Sesión en vivo con usuarios de Banamex sobre el laboratorio en funcionamiento", "PENDIENTE"),
    (2, "Accesos probados: dichos usuarios ingresan por si mismos al Laboratorio y a sus herramientas",
     "Sesión en vivo, no mediante entrega de documentos", "PENDIENTE"),
    (3, "Vista de entornos: los usuarios visualizan y pueden utilizar los entornos del Laboratorio contratados",
     "Sesión en vivo", "PENDIENTE"),
    (4, "Acceso a pipelines: los usuarios ejecutan con exito, de punta a punta, al menos un pipeline de "
        "construcción y despliegue dentro del Laboratorio",
     "Sesión en vivo; la cuota es exigible cuando Banamex confirma por escrito", "PENDIENTE"),
]


# --------------------------------------------------------------------------
# Datos: capa de laboratorio (diseño de solución v8, source/docs/)
# --------------------------------------------------------------------------

ARQUETIPOS = [
    ("A", "Certificar APIs",
     "Certifica APIs que el banco ya tiene contra el core emulado: contrato, escenarios de error y evidencia. "
     "Sin desarrollo nuevo.",
     933, 200,
     "Hasta 10 APIs por mes con pruebas de contrato; escenarios de timeout, rechazo y caos; agentes con evidencia "
     "firmada por API; 3 perfiles de QA con acceso; sin computo permanente",
     "PROPUESTO"),
    ("B", "Producto digital",
     "Un canal y su BFF en contenedores sobre un dominio del core simulado, con pipeline y compuertas G1 a G3.",
     2507, 400,
     "1 producto, 2 sandboxes (desarrollo y certificación); gateway y BFF en contenedores; agentes del dominio; "
     "base de datos relacional, cache y NoSQL para estado y sesiones; 4 usuarios con escritorio virtual y MFA",
     "PROPUESTO"),
    ("C", "Plataforma multi-equipo",
     "Tres productos integrados por eventos, fábrica de datos sintéticos por sprint y pipelines por producto.",
     6396, 1500,
     "3 productos, 5 sandboxes, 4 pipelines con compuertas por producto; bus de eventos entre dominios; "
     "fábrica de datos sintéticos con validación de calidad; agentes de 4 dominios; 10 usuarios",
     "PROPUESTO"),
    ("D", "IA intensiva",
     "Asistente con agentes sobre el core simulado o modelos de scoring propios, con evaluación automática.",
     8101, 600,
     "Asistente bancario con agentes sobre el core simulado o modelos propios de scoring; dos familias de modelos; "
     "agente evaluador; orquestación serverless; 6 usuarios; evaluaciones en cada build",
     "PROPUESTO"),
]

CAPAS_LAB = [
    (1, "Experiencia y entrada", "Los canales entran por una sola puerta de APIs",
     "Todo el trafico cifrado y con cuotas"),
    (2, "Core simulado", "Responde como el core sin tocar el core",
     "Aislado por diseño: no existe ruta al core real hasta que la Zona D lo autorice"),
    (3, "Datos sintéticos", "Cero datos reales de clientes",
     "Sin información personal ni extractos de producción"),
    (4, "Ciclo de desarrollo (SDLC)", "De la idea a producción con controles automáticos",
     "Ningun cambio pasa sin controles y aprobación humana; todo queda registrado"),
    (5, "Modelos de IA", "Un solo acceso gobernado a los modelos",
     "Sin datos reales en las consultas; cada llamada registrada y con tope de gasto"),
    (6, "Laboratorio aislado", "Seguridad, compliance y operación embebida",
     "Controles del Landing Zone, auditoría completa, acceso federado y MFA para terceros"),
]

COMPUERTAS = [
    ("G0", 0, "Idea", "Sandbox", "Evidencia automática de la compuerta"),
    ("G1", 1, "Sandbox", "Desarrollo", "Evidencia automática de la compuerta"),
    ("G2", 2, "Desarrollo", "Integración", "Evidencia automática de la compuerta"),
    ("G3", 3, "Integración", "Certificación", "Evidencia del agente evaluador contra contrato y reglas"),
    ("G4", 4, "Certificación", "Zona D", "Evidencia completa; depende de que la Zona D exista"),
]

STACK = [
    ("Experiencia", "Plataforma de experiencia digital composable", "Micro frontends, CMS headless, originacion"),
    ("Experiencia", "BFF propio en contenedores", "Alternativa recomendada por control y transferibilidad"),
    ("Integración", "API Gateway", "Contrato único de APIs, cuotas, mTLS, enrutamiento"),
    ("Integración", "Gateway de APIs open source", "Puerta de entrada a servicios de dominio"),
    ("Integración", "Bus de eventos gestionado", "Eventos entre dominios del core simulado"),
    ("Core simulado", "Agentes de IA gestionados", "Un agente por dominio: clientes, cuentas, pagos, tarjetas"),
    ("Core simulado", "Agente evaluador", "Puntua contra contrato y reglas; firma evidencia"),
    ("Core simulado", "Enrutador de escenarios serverless", "Decide quien responde: feliz, latencia, error, caos"),
    ("Core simulado", "Orquestación de flujos largos", "Flujos de pagos y originacion"),
    ("Core simulado", "Contratos OpenAPI", "Fuente de verdad versionada"),
    ("Datos", "Fábrica de datos sintéticos", "Genera, valida, versiona, carga y refresca"),
    ("Datos", "Validación de calidad de datos", "Integridad, cuadre y distancia a datos reales"),
    ("Datos", "Base relacional, NoSQL y cache", "Estado y sesiones del core simulado"),
    ("SDLC", "IDE agentico", "Desarrollo asistido por agentes"),
    ("SDLC", "Pipeline de integración y despliegue", "Orquesta build, prueba y despliegue"),
    ("SDLC", "Registro de artefactos y contenedores", "Artefactos versionados"),
    ("SDLC", "Infraestructura como código en Terraform", "Base y arquetipos como plantillas"),
    ("SDLC", "Pruebas de contrato", "Verifica el producto contra el contrato OpenAPI"),
    ("Plataforma", "Catálogo de autoservicio", "Sandboxes y arquetipos por catálogo"),
    ("Plataforma", "Contenedores gestionados", "Ambientes de sandbox, desarrollo, integración y certificación"),
    ("Identidad", "Identidad federada con MFA", "Acceso federado del banco, MFA obligatorio para terceros"),
    ("Identidad", "Gestión de secretos y cifrado", "Llave de cifrado del banco, sin llaves de larga vida"),
    ("Seguridad", "Detección de amenazas y postura", "Hallazgos con dueno y remediación"),
    ("Seguridad", "Gestión de postura cloud y CIEM", "Permisos excesivos y quien podria acceder"),
    ("Seguridad", "Centro de operaciones de seguridad", "Escalamiento de incidentes"),
    ("Observabilidad", "Metricas, trazas y logs por sandbox", "Observabilidad por producto"),
    ("Observabilidad", "SIEM y tableros", "Tableros por repositorio y usuario, detección y alertas"),
    ("Auditoría", "Registro de actividad inmutable", "Retención larga, exportación firmada para auditoría"),
    ("Operación", "Gestión de servicio", "Eventos, incidentes, solicitudes, problemas y cambios"),
    ("Operación", "Automatizacion de operaciones", "Parcheo, configuración deseada y respaldos"),
]

RUTAS_CODIGO = [
    ("A", "Push desde el CI del banco con identidad federada OIDC", "Banamex, desde su repositorio corporativo",
     "Ninguna guardada: identidad federada por repositorio y rama", "Repositorios mirror y work en la cuenta del banco", 1),
    ("B", "Conexión gestionada del proveedor cloud al repositorio", "El proveedor cloud, via aplicacion instalada por el banco",
     "Ninguna: la aplicacion gestiona el acceso", "Solo pasa por el pipeline; no hay repositorio en el laboratorio", 0),
    ("C", "Paquete firmado por transferencia segura", "Banamex, entrega por entrega",
     "Llave del banco en el servicio de transferencia; ninguna de Accenture",
     "Paquete inmutable en almacenamiento de objetos y repositorios mirror y work", 0),
]


# --------------------------------------------------------------------------
# Datos: capa de setup (plan-setup.md)
# --------------------------------------------------------------------------

FASES = [
    ("HAB", 0, "Habilitación inicial",
     "Semanas 1 y 2, dentro de la fase de on-boarding", "POR VERIFICAR",
     "2026-10-12", "2026-10-23", 1, 1, "Cláusula Cuarta, componente (i)"),
    ("ACT", 1, "Activación de capacidades de emulación, SDLC y automatización",
     "Semanas 2 a 4, cierre el 6 de noviembre de 2026", "POR EJECUTAR",
     "2026-10-19", "2026-11-06", 1, 1, "Cláusula Cuarta, componente (ii)"),
    ("OPE", 2, "Operación y Soporte",
     "Desde el 9 de noviembre de 2026 hasta el 11 de octubre de 2029", "POR EJECUTAR",
     "2026-11-09", "2027-03-31", 0, 1, "Cláusula Cuarta, componente (iii)"),
    ("EXT", 3, "Trabajo de apoyo fuera del Anexo B",
     "En paralelo a la implementación", "EN CURSO",
     "2026-10-19", "2026-11-06", 0, 0, "No contratado"),
]


SEMANAS = [
    (1, "2026-10-12", "2026-10-16", "Habilitación: cuentas, red aislada, controles base y catálogo",
     "Ya transcurrió. El estado real está sin verificar y es la primera actividad del plan"),
    (2, "2026-10-19", "2026-10-23", "Verificación, decisiones de seguridad, identidad y repositorio",
     "Las decisiones y la designación de usuarios son del banco. Si no salen esta semana, "
     "no hay forma de recuperar dentro de la ventana"),
    (3, "2026-10-26", "2026-10-30", "Núcleo de la activación: core emulado, datos sintéticos y pipeline",
     "Depende de que los contratos de interfaz hayan llegado en la semana 2"),
    (4, "2026-11-02", "2026-11-06", "Compuertas, pilotos, ensayo y sesión de acreditación",
     "No hay holgura: la entrega formal de los entregables 1 y 2 es el 11 de noviembre"),
]

# Hitos del Gantt. Rombo en color Señal segun el design system.
HITOS = [
    ("H1", "2026-10-12", "Inicio de vigencia del Anexo B", "CONTRACTUAL",
     "Cláusula Primera. Tres años, hasta el 11 de octubre de 2029"),
    ("H3", "2026-11-11", "Cierre del primer mes del proyecto", "CONTRACTUAL",
     "Vence la fase de on-boarding. Entregables 1 y 2, única vez"),
    ("H4", "2026-11-11", "Acreditación de los cuatro criterios", "FINANCIERO",
     "Cláusula Sexta. Se verifica en sesión en vivo y vuelve exigible la cuota de arranque. "
     "El Anexo no le fija fecha: esta es la que proponemos"),
    ("H2", "2026-11-09", "Arranque de Operación y Soporte", "CONTRACTUAL",
     "Cláusula Cuarta, componente (iii). Comienzan los reportes mensuales"),
]


ACTIVIDADES = [
    ("ACT-01", "HAB", "Base Laboratorio", "Inventariar el estado real de la habilitación contra lo comprometido",
     "Reporte de desfase con decisión de recuperar o replantear", "", "PENDIENTE", 2, 0),
    ("ACT-02", "HAB", "Base Laboratorio", "Confirmar la talla esperada del servicio y la demanda que la justifica",
     "Nota de dimensionamiento con la talla y su sustento", "ACT-01", "PENDIENTE", 2, 1),
    ("ACT-03", "HAB", "Base Laboratorio", "Pedir a Banamex la designación de usuarios para el gate de arranque",
     "Lista de usuarios designados con rol y disponibilidad", "", "PENDIENTE", 2, 1),
    ("ACT-04", "HAB", "Base Laboratorio", "Agendar la revisión conjunta con Arquitectura y Seguridad del banco",
     "Fecha en firme en calendario de ambas partes", "", "PENDIENTE", 2, 1),
    ("ACT-05", "HAB", "Base Laboratorio", "Cerrar las tres decisiones de seguridad abiertas",
     "Tres decisiones documentadas y firmadas", "ACT-04", "PENDIENTE", 2, 0),
    ("ACT-06", "HAB", "Base Laboratorio", "Levantar el registro de decisiones, riesgos y datos requeridos",
     "Registro vivo en knowledge-base", "", "PENDIENTE", 2, 0),
    ("ACT-07", "EXT", "SDLC", "Pedir la línea base del SDLC actual del banco: tiempo de ciclo, costo, equipos",
     "Línea base documentada o DATO-REQUERIDO formal", "", "PENDIENTE", 2, 0),

    ("ACT-08", "HAB", "Base Laboratorio", "Organización cloud, cuentas hijas, unidades organizativas y políticas de control",
     "Estructura de cuentas desplegada en Terraform", "ACT-01", "PENDIENTE", 1, 1),
    ("ACT-09", "HAB", "Base Laboratorio", "Red aislada, endpoints privados y verificación de que no hay ruta al core real",
     "Diagrama de red y evidencia de aislamiento", "ACT-08", "PENDIENTE", 1, 1),
    ("ACT-10", "HAB", "Base Laboratorio", "Identidad federada con MFA obligatorio para terceros y proveedores",
     "Flujo de alta, cambio y baja operando", "ACT-05", "PENDIENTE", 2, 1),
    ("ACT-11", "HAB", "Base Laboratorio", "Controles base: cifrado con llave del banco, registro de actividad, postura",
     "Tablero de postura con hallazgos y duenos", "ACT-08", "PENDIENTE", 1, 1),
    ("ACT-12", "HAB", "SDLC", "Repositorio y ruta de ingreso de código según la decisión de ACT-05",
     "Repositorios mirror y work operando con su control de acceso", "ACT-05,ACT-10", "PENDIENTE", 2, 1),
    ("ACT-13", "HAB", "SDLC", "Pipeline de integración y despliegue continuos",
     "Pipeline ejecutando de punta a punta", "ACT-12", "PENDIENTE", 2, 1),
    ("ACT-14", "HAB", "Base Laboratorio", "Catálogo de aprovisionamiento de autoservicio",
     "Catálogo publicado con sus productos", "ACT-08", "PENDIENTE", 1, 1),
    ("ACT-15", "HAB", "Base Laboratorio", "Sandbox inicial operado",
     "Sandbox disponible y monitoreado", "ACT-13,ACT-14", "PENDIENTE", 2, 1),
    ("ACT-16", "HAB", "Base Laboratorio", "Despliegue de los arquetipos de arranque como plantillas de Terraform",
     "Arquetipos activos en el repositorio de infraestructura", "ACT-14", "PENDIENTE", 2, 1),
    ("ACT-17", "HAB", "Base Laboratorio", "Automatizar el vencimiento y la revocación de accesos",
     "Baja automática por vencimiento, verificada", "ACT-10", "PENDIENTE", 2, 0),

    ("ACT-18", "ACT", "Base Laboratorio", "Acordar el marco de controles con Seguridad del banco e integrarlo a su estándar",
     "Marco de controles firmado", "ACT-05,ACT-11", "PENDIENTE", 3, 0),
    ("ACT-19", "ACT", "Base Laboratorio", "Recibir del banco contratos de interfaz, esquemas de mensajes y reglas de negocio",
     "Contratos OpenAPI versionados en el repositorio", "", "PENDIENTE", 2, 1),
    ("ACT-20", "ACT", "Base Laboratorio", "Modelar escenarios por dominio: normal, excepción, latencia, rechazo y caos",
     "Catálogo de escenarios por dominio", "ACT-19", "PENDIENTE", 3, 1),
    ("ACT-21", "ACT", "Base Laboratorio", "Construir el core emulado por dominio con agentes y enrutador de escenarios",
     "Core emulado respondiendo según contrato", "ACT-20", "PENDIENTE", 3, 1),
    ("ACT-22", "ACT", "Base Laboratorio", "Montar la fábrica de datos sintéticos con validación, versionado y firma",
     "Fábrica operando, con aprobación previa al uso", "ACT-18", "PENDIENTE", 3, 1),
    ("ACT-23", "ACT", "SDLC", "Implementar las compuertas de control con evidencia automática",
     "Compuertas G0 a G4 operando con evidencia firmada", "ACT-13,ACT-21", "PENDIENTE", 4, 1),
    ("ACT-24", "ACT", "Base Laboratorio", "Levantar dos sandboxes piloto y el primer micro frontend en pruebas",
     "Dos pilotos funcionando contra el core emulado", "ACT-15,ACT-21", "PENDIENTE", 4, 0),
    ("ACT-25", "OPE", "Base Laboratorio", "Conectar observabilidad, centro de operaciones de seguridad, gestión de servicio y parcheo",
     "Operación con monitoreo, incidentes y parcheo activos", "ACT-11", "PENDIENTE", 3, 1),
    ("ACT-26", "ACT", "Base Laboratorio", "Activar las capacidades por catálogo según la talla contratada",
     "Catálogo alineado al cupo de la talla", "ACT-02,ACT-14", "PENDIENTE", 4, 1),

    ("ACT-27", "ACT", "Base Laboratorio", "Ensayar internamente los cuatro criterios de extremo a extremo",
     "Ensayo completado sin incidencias", "ACT-15,ACT-17", "PENDIENTE", 4, 0),
    ("ACT-28", "HAB", "Base Laboratorio", "Entregar el diseño de arquitectura y seguridad y conseguir la revisión conjunta",
     "Entregable 1 del Anexo, aceptado o con observaciones resueltas", "ACT-04,ACT-09,ACT-11", "PENDIENTE", 2, 1),
    ("ACT-29", "ACT", "Base Laboratorio", "Ejecutar la sesión de verificación con usuarios reales de Banamex",
     "Acta de la sesión con los cuatro criterios acreditados", "ACT-03,ACT-27", "PENDIENTE", 4, 1),
    ("ACT-30", "ACT", "Base Laboratorio", "Obtener la confirmación por escrito del cumplimiento",
     "Confirmación escrita, que vuelve exigible la cuota de arranque", "ACT-29", "PENDIENTE", 4, 1),

    ("ACT-31", "EXT", "Digital Brain", "Montar el brain del laboratorio con su esquema y su cargador",
     "build-brain.py y brain.py", "", "HECHO", 2, 0),
    ("ACT-32", "EXT", "Digital Brain", "Cargar la capa contractual desde el Anexo B",
     "Entregables, compromisos, tallas, penas y criterios consultables", "ACT-31", "HECHO", 2, 0),
    ("ACT-33", "EXT", "Digital Brain", "Cargar la capa de laboratorio desde el diseño de solución",
     "Arquetipos, capas, compuertas y stack consultables", "ACT-31", "HECHO", 2, 0),
    ("ACT-34", "EXT", "Digital Brain", "Cargar la capa de setup con las actividades y entregables del plan",
     "Avance del setup consultable por fase y workstream", "ACT-31", "HECHO", 2, 0),
    ("ACT-35", "EXT", "Digital Brain", "Federar el brain del core por referencia, sin duplicar el corpus",
     "Consulta cruzada entre laboratorio y core", "ACT-31", "HECHO", 2, 0),
    ("ACT-36", "EXT", "Digital Brain", "Modelar las cuatro iniciativas estratégicas con sus habilitadores y brechas",
     "Tablero de preparación por iniciativa", "ACT-32,ACT-35", "HECHO", 2, 0),
    ("ACT-37", "EXT", "Digital Brain", "Derivar contratos de interfaz candidatos desde las reglas del core",
     "Insumo para ACT-19, con trazabilidad a la regla de origen", "ACT-35", "PENDIENTE", 2, 0),
    ("ACT-38", "EXT", "SDLC", "Levantar el estado actual del SDLC del banco como capa del brain",
     "Línea base del SDLC consultable", "ACT-07", "PENDIENTE", 4, 0),
]

ENTREGABLES_SETUP = [
    ("Reporte de desfase de habilitación", "F0", 0, "Control interno"),
    ("Nota de dimensionamiento de talla", "F0", 0, "Insumo comercial"),
    ("Tres decisiones de seguridad documentadas", "F0", 0, "Prerrequisito de los entregables 1 y 2"),
    ("Diseño de arquitectura y seguridad", "F3", 1, "Entregable 1 del Anexo, vence el 11 de noviembre de 2026"),
    ("Laboratorio base habilitado", "F1", 1, "Entregable 2 del Anexo, vence el 11 de noviembre de 2026"),
    ("Acta de acreditacion de los cuatro criterios", "F3", 0, "Condición de exigibilidad de la cuota de arranque"),
    ("Core emulado por dominio", "F2", 0, "Parte del componente de Activación"),
    ("Fábrica de datos sintéticos", "F2", 0, "Parte del componente de Activación"),
    ("Compuertas con evidencia automática", "F2", 0, "Parte del componente de Activación"),
    ("Plantillas de arquetipos en Terraform", "F1", 1, "Entregable 5 del Anexo, mensual"),
    ("Reporte de consumo de infraestructura y soporte", "F4", 1, "Entregable 3 del Anexo, mensual"),
    ("Reporte de actividades del equipo de SDLC", "F4", 1, "Entregable 4 del Anexo, mensual"),
    ("Digital Brain del laboratorio operando", "FB", 0, "Habilitador de las cuatro iniciativas"),
    ("Tablero de preparación de las cuatro iniciativas", "FB", 0, "Insumo de la Fase 4"),
]


# --------------------------------------------------------------------------
# Datos: capa de iniciativas estratégicas
# --------------------------------------------------------------------------

INICIATIVAS = [
    ("INI-01", "Modernización del Core Bancario",
     "Modernización de S500 y S151 en Unisys ClearPath. El laboratorio da el lugar para certificar APIs contra el "
     "core emulado sin tocar el core real.",
     0, "Requiere orden de servicio o control de cambio", "HABILITABLE"),
    ("INI-02", "TSA Exit",
     "Salida de los servicios heredados bajo acuerdo de transicion. El laboratorio permite construir y probar los "
     "reemplazos sin depender del calendario de la Zona D.",
     0, "Requiere orden de servicio o control de cambio", "BLOQUEADA POR DATO"),
    ("INI-03", "Iniciativas de negocio (Future Bank)",
     "Cartera de iniciativas del banco futuro. El laboratorio da sandboxes por producto con pipeline, compuertas y "
     "un core que responde.",
     0, "Requiere orden de servicio o control de cambio", "BLOQUEADA POR DATO"),
    ("INI-04", "Transformación del SDLC del banco",
     "Transformación del ciclo de desarrollo de TODO el banco, no solo del laboratorio. El laboratorio es la "
     "implementacion de referencia donde el modelo se incuba y se prueba con productos reales.",
     0, "Requiere orden de servicio o control de cambio", "BLOQUEADA POR DATO"),
]

HABILITADORES = [
    ("INI-01", "Laboratorio", "Arquetipo A de certificación de APIs contra el core emulado, con evidencia firmada por compuerta", "Diseño de solución v8"),
    ("INI-01", "Brain", "1,583 reglas de negocio extraidas del código del legado", "brain.db del core, tabla rules"),
    ("INI-01", "Brain", "26 capacidades de negocio modeladas", "brain.db del core, tabla capacidades"),
    ("INI-01", "Brain", "181 riesgos de migración catalogados", "brain.db del core, tabla riesgos_migracion"),
    ("INI-01", "Brain", "5 decisiones de disposición 7R ya tomadas, todas ENCAPSULATE", "brain.db del core, tabla sevenr_decisions"),
    ("INI-01", "Brain", "Inventario de 218 piezas y 152 programas con su trazabilidad", "brain.db del core"),

    ("INI-02", "Laboratorio", "Lugar para construir y probar reemplazos sin depender de la Zona D", "Diseño de solución v8"),
    ("INI-02", "Brain", "Evidencia en código del acoplamiento heredado, incluida la clave de institucion fijada en duro", "brain.db del core, riesgos_migracion"),
    ("INI-02", "Brain", "Dependencias cruzadas entre sistemas y capacidades", "brain.db del core, cross_dependencies"),

    ("INI-03", "Laboratorio", "Sandboxes por producto con pipeline y compuertas G1 a G3 (arquetipos B y D)", "Diseño de solución v8"),
    ("INI-03", "Brain", "Capacidades del core que toca cada iniciativa y riesgos asociados", "brain.db del core"),

    ("INI-04", "Laboratorio", "SDLC agentico de referencia con compuertas G0 a G4 y evidencia automática", "Diseño de solución v8"),
    ("INI-04", "Brain", "Trazabilidad de la evidencia por compuerta y por producto", "lab-brain.db, tabla compuertas"),
]

BRECHAS = [
    ("INI-01", "Las decisiones de disposición cubren 5 programas de 152",
     "El 3R inicial no se puede sustentar completo sin extender la clasificación", "Accenture con el brain", "ABIERTA"),
    ("INI-01", "No existe roadmap de modernización del core",
     "Es entregable del workstream y depende de la clasificación extendida", "Accenture", "ABIERTA"),
    ("INI-02", "No existe inventario de TSAs aplicables en ningun artefacto del proyecto",
     "Sin el inventario no hay análisis ni roadmap de salida", "Banamex", "DATO-REQUERIDO"),
    ("INI-03", "No existe la cartera de iniciativas con su hipótesis de valor",
     "Sin cartera la talla del laboratorio se estima a ciegas y la Fase 4 arranca con descubrimiento", "Banamex", "DATO-REQUERIDO"),
    ("INI-04", "No existe línea base del SDLC actual del banco: tiempo de ciclo, costo por entrega, número de equipos",
     "Sin línea base no hay business case ni medida de la transformación", "Banamex", "DATO-REQUERIDO"),
    ("INI-04", "No esta definido el alcance de la transformación: que equipos, en que orden, con que meta",
     "Determina si el laboratorio es piloto o plataforma de despliegue", "Conjunta", "DATO-REQUERIDO"),
]

DECISIONES = [
    ("DEC-01", "Talla esperada del servicio",
     "Define cupo de arquetipos, usuarios, dominios de core emulado y pipelines. Sin ella no se dimensiona el setup",
     "Banamex, sobre la cartera de iniciativas", "ABIERTA"),
    ("DEC-02", "Federacion de identidad: invitado externo contra cuenta en dominio Accenture",
     "Determina si las altas dependen del tenant del banco. La opción federada exige integrar el directorio de Banamex",
     "Seguridad de Banamex", "ABIERTA"),
    ("DEC-03", "Ruta de ingreso de código: identidad federada OIDC, conexión gestionada o paquete firmado",
     "Cambia la arquitectura del entregable 1 y el diseño del repositorio", "Seguridad de Banamex", "ABIERTA"),
    ("DEC-04", "Capa de experiencia: plataforma gestionada del proveedor contra BFF propio en el laboratorio",
     "Marcada como decision de Fase 0 en el diseño; se recomienda el BFF propio por control y transferibilidad",
     "Arquitectura de Banamex", "ABIERTA"),
    ("DEC-05", "Cuales de los cuatro arquetipos iniciales aplican y con que personalizacion",
     "Es el primer entregable del workstream Base Laboratorio", "Conjunta", "ABIERTA"),
    ("DEC-06", "Alcance del workstream BAU",
     "Hueco de alcance: la tabla de origen lo deja sin entregables", "Conjunta", "ABIERTA"),
    ("DEC-07", "Vehiculo contractual de las cuatro iniciativas estratégicas",
     "Ninguna esta cubierta por el Anexo B; define si se entregan y bajo que condiciones", "Account Lead", "ABIERTA"),
]


# --------------------------------------------------------------------------
# Datos: equipo
# --------------------------------------------------------------------------
# Patron base: "IMS — Datacenter + Cloud Híbrido — Gran empresa/Banco" del
# Specialist - IMS Staffing Plan. Ajustes obligados por sus propias tablas de riesgo:
#   - Regulación estricta CNBV: SecOps T3 y Compliance Engineer dedicado
#   - AIOps y GenAI en alcance: perfiles T3 para diseño del harness de agentes
#   - FinOps desde el mes 1: aquí es crítico porque el servicio se cobra como
#     porcentaje del consumo, de modo que el control de consumo es control de margen
# El rol de Solution Architect sigue la definición de Solutioning - Solution Architect:
# es el dueño de CÓMO se entrega la solución, y firma el entregable 1 del Anexo.
#
# Las fracciones de FTE en L8 a L12 son válidas porque este es un deal IMS. En SI
# estarían prohibidas (regla de dedicación del Solution Architect, excepción AMS/IMS).
#
# ADVERTENCIA: estos FTE son un patrón de referencia para dimensionar, NO el headcount
# definitivo. El cálculo formal lo produce IMS Estimation (SME) y alimenta el SP-11.

ROLES = [
    ("R01", "Delivery Executive", "BC-89", "L4", "Gobierno", "Onshore", "Gobierno", "",
     0.05, 0.05,
     "Patrocinio ejecutivo y escalamiento final",
     "Nominal. Un laboratorio no productivo no sostiene más",
     0.05, 0.05,
     "Ninguna. La rendición de cuentas ejecutiva no se automatiza"),
    ("R02", "Service Delivery Lead", "BC-62", "L7", "T3", "Onshore", "Gobierno", "R01",
     0.50, 0.50,
     "Gobierno del contrato, cumplimiento de los compromisos de servicio, reportes mensuales "
     "y punto de escalamiento del servicio del laboratorio",
     "Media dedicación: un solo cliente, ventana 9 a 18, sin guardia",
     0.5, 0.4,
     "Los dos reportes mensuales se redactan asistidos desde el brain, con revisión humana"),
    ("R03", "Solution Architect", "BC-62", "L7", "T3", "Nearshore", "Arquitectura", "R02",
     1.00, 0.25,
     "Dueño de cómo se entrega. Firma el diseño de arquitectura y seguridad, resuelve las "
     "decisiones abiertas y diseña los arquetipos nuevos a la medida",
     "Absorbe la arquitectura de infraestructura. En operación solo sostiene el "
     "compromiso de 10 días hábiles para arquetipo nuevo",
     0.85, 0.25,
     "Generación asistida de documentos de diseño y de arquetipos nuevos"),
    ("R04", "SDLC y DevSecOps Architect", "BC-57", "L8", "T3", "Nearshore", "SDLC", "R03",
     1.00, 0.50,
     "Diseño del SDLC agéntico, compuertas con evidencia automática y el modelo extensible "
     "que después se lleva al resto del banco",
     "El SDLC es el producto del laboratorio, no un soporte. Se sostiene",
     0.9, 0.5,
     "Poca. Este rol construye el stack agéntico: no se recorta al constructor"),
    ("R05", "Cloud Engineer Senior", "BC-57", "L8", "T2", "Nearshore", "Plataforma", "R03",
     1.00, 1.00,
     "Landing zone, cuentas, red aislada, contenedores y servicios gestionados. Absorbe la "
     "ingeniería de red, que en un entorno aislado es trabajo de una sola vez",
     "Sustituye al Cloud Infrastructure Architect y al Network Engineer",
     0.8, 0.75,
     "Infraestructura como código asistida y diagnóstico asistido de incidentes"),
    ("R06", "Platform Engineer, infraestructura como código", "BC-51", "L9", "T2", "Nearshore",
     "Plataforma", "R05", 2.00, 1.00,
     "Plantillas de Terraform de la base y de los arquetipos. Produce el entregable 5, que es "
     "mensual y contractual",
     "SUBE respecto del dimensionamiento anterior. Aquí está el producto",
     1.4, 0.6,
     "La más alta del equipo. Generación de plantillas de Terraform desde el catálogo"),
    ("R07", "Harness y Agent Engineer", "BC-51", "L9", "T2", "Nearshore", "SDLC", "R04",
     1.00, 0.50,
     "Core emulado por dominio, agentes simuladores, enrutador de escenarios y agente evaluador",
     "En operación baja porque el brain ya tiene 21 capacidades modeladas y la talla "
     "máxima solo pide 12 dominios",
     0.75, 0.35,
     "El harness ya son agentes. Generación de escenarios desde los riesgos del brain"),
    ("R08", "Synthetic Data Engineer", "BC-51", "L9", "T2", "Nearshore", "SDLC", "R04",
     0.50, 0.25,
     "Fábrica de datos sintéticos y sus refrescos, entre 2 y 20 al mes según la talla",
     "El brain aporta 849 campos con tipo y 150 datasets con población real",
     0.3, 0.1,
     "La generación ya es por modelo. El brain aporta esquema y volumetría reales"),
    ("R09", "IAM Engineer", "BC-51", "L9", "T2", "Nearshore", "Seguridad", "R03",
     0.50, 0.25,
     "Identidad federada, altas, cambios y bajas. Automatiza el vencimiento de accesos",
     "Se sostiene pese al recorte: la baja atrasada es la pena de nivel A más fácil de incurrir",
     0.4, 0.25,
     "Alta y baja ya automatizadas. El piso no es esfuerzo, es disponibilidad diaria"),
    ("R10", "SecOps Engineer", "BC-51", "L9", "T2", "Nearshore", "Seguridad", "R03",
     0.50, 0.25,
     "Postura de seguridad, evidencia de parcheo y atención de hallazgos de la plataforma",
     "BAJA de líder T3 a ingeniero T2: sin datos reales ni ruta al core, no hay superficie "
     "productiva que proteger. Absorbe el cumplimiento de la plataforma",
     0.4, 0.2,
     "Triage asistido de hallazgos y evidencia de parcheo"),
    ("R11", "FinOps Analyst", "BC-51", "L9", "T2", "Nearshore", "Gobierno", "R02",
     0.25, 0.25,
     "Presupuestos, etiquetado, reporte mensual de consumo y vigilancia de la talla",
     "Se sostiene porque el servicio se cobra como porcentaje del consumo",
     0.25, 0.2,
     "Detección de anomalías de consumo y borrador del reporte mensual"),
    ("R12", "Operations Engineer", "BC-37", "L10", "T2", "Nearshore", "Operación", "R02",
     0.00, 1.00,
     "Monitoreo, incidentes, solicitudes, parcheo y respaldos dentro de la ventana de servicio",
     "Cubre el monitoreo que antes se asignaba a un NOC. La ventana es 9 a 18, no 24 por 7",
     0.0, 0.55,
     "AIOps clásico: clasificación de incidentes y ejecución de runbooks"),
]

LIMITES_IA = [
    ("L1", "Rendición de cuentas contractual",
     "El Anexo nombra un Responsable del Servicio en la tabla de escalamiento y exige que quien "
     "acepta entregables tenga autoridad formal. Eso es una persona, no un agente",
     "0.45 FTE entre patrocinio y liderazgo de servicio"),
    ("L2", "Disponibilidad, no esfuerzo",
     "Cinco compromisos tienen reloj de 1 a 3 días hábiles y dos de 30 minutos y 2 horas. Un "
     "perfil a 0.20 de dedicación está disponible una jornada por semana: no puede sostener un "
     "compromiso de un día hábil todos los días hábiles durante tres años",
     "El piso lo fija la cobertura del calendario, no las horas de trabajo"),
    ("L3", "Continuidad y riesgo de persona única",
     "Tres años con vacaciones, incapacidades y rotación. Un rol crítico por debajo de 0.25 sin "
     "respaldo es un punto único de falla, y la baja de persona atrasada cuesta 3 por ciento del "
     "monto mensual por evento",
     "Los roles de operación e identidad necesitan traslape entre dos personas"),
    ("L4", "La automatización se construye antes de cobrarse",
     "El guideline sitúa el beneficio de GenAI en los años 2 y 3, no en el primero. En el año 1 "
     "se paga construir la automatización",
     "El ahorro no aplica a las cuatro semanas de implementación"),
    ("L5", "El ahorro de nivel 1 ya se gastó",
     "El guideline proyecta una reducción de 30 a 50 por ciento en nivel 1 cuando hay GenAI en "
     "alcance. Ese nivel ya se eliminó del equipo por no haber operación continua, así que no se "
     "puede contar dos veces",
     "No hay segundo recorte del monitoreo"),
]

# Supuestos que sostienen el dimensionamiento. Si alguno cae, el equipo vuelve a crecer.
SUPUESTOS = [
    ("S1", "El reloj de severidad 1 y 2 corre dentro de la ventana de 9 a 18 horas",
     "El Anexo fija la ventana en la Cláusula Cuarta y no menciona 24 por 7 en ningún lugar",
     "Vuelve el turno de monitoreo fuera de ventana, con su multiplicador de cobertura",
     "+1.00 FTE o más", "POR CONFIRMAR POR ESCRITO"),
    ("S2", "El laboratorio no produce artefactos regulatorios ni maneja datos reales",
     "El alcance excluye la conexión con entornos productivos y con el Core real, y toda la "
     "operación es contra datos sintéticos",
     "Regresa un perfil de cumplimiento dedicado y sube el nivel de seguridad",
     "+0.75 FTE", "SOSTENIDO POR EL ANEXO"),
    ("S3", "No hay recuperación ante desastres en el alcance",
     "El Anexo no menciona recuperación ante desastres ni segunda región. Solo pide entre 1 y 6 "
     "restauraciones de respaldo por trimestre, que es cadencia de prueba",
     "Se agrega ingeniería de respaldo y recuperación y pruebas formales",
     "+0.50 FTE", "SOSTENIDO POR EL ANEXO"),
    ("S4", "La conectividad es aislada, sin enlace híbrido con la red del banco",
     "El diseño aprobado usa endpoints privados y no contempla enlace dedicado",
     "Regresa el ingeniero de red como perfil propio",
     "+0.50 FTE", "DEPENDE DE LA DECISIÓN DE RUTA DE CÓDIGO"),
]


# RACI sobre los entregables y los hitos que mueven dinero o riesgo.
RACI = [
    ("Diseño de arquitectura y seguridad", "R03", "A"),
    ("Diseño de arquitectura y seguridad", "R05", "R"),
    ("Diseño de arquitectura y seguridad", "R10", "C"),
    ("Diseño de arquitectura y seguridad", "R04", "C"),
    ("Diseño de arquitectura y seguridad", "R02", "I"),

    ("Laboratorio base habilitado", "R05", "A"),
    ("Laboratorio base habilitado", "R06", "R"),
    ("Laboratorio base habilitado", "R09", "R"),
    ("Laboratorio base habilitado", "R03", "C"),
    ("Laboratorio base habilitado", "R02", "I"),

    ("Acreditación de los cuatro criterios", "R02", "A"),
    ("Acreditación de los cuatro criterios", "R09", "R"),
    ("Acreditación de los cuatro criterios", "R06", "R"),
    ("Acreditación de los cuatro criterios", "R05", "C"),
    ("Acreditación de los cuatro criterios", "R01", "I"),

    ("Core emulado y harness de agentes", "R04", "A"),
    ("Core emulado y harness de agentes", "R07", "R"),
    ("Core emulado y harness de agentes", "R08", "R"),
    ("Core emulado y harness de agentes", "R03", "C"),

    ("Fábrica de datos sintéticos", "R04", "A"),
    ("Fábrica de datos sintéticos", "R08", "R"),
    ("Fábrica de datos sintéticos", "R10", "C"),

    ("Compuertas con evidencia automática", "R04", "A"),
    ("Compuertas con evidencia automática", "R06", "R"),
    ("Compuertas con evidencia automática", "R07", "R"),

    ("Plantillas de arquetipos en Terraform", "R06", "A"),
    ("Plantillas de arquetipos en Terraform", "R05", "R"),
    ("Plantillas de arquetipos en Terraform", "R03", "C"),
    ("Plantillas de arquetipos en Terraform", "R11", "C"),

    ("Reporte mensual de consumo y soporte", "R11", "A"),
    ("Reporte mensual de consumo y soporte", "R02", "R"),
    ("Reporte mensual de consumo y soporte", "R12", "C"),

    ("Reporte mensual de actividades de SDLC", "R02", "A"),
    ("Reporte mensual de actividades de SDLC", "R04", "R"),
    ("Reporte mensual de actividades de SDLC", "R06", "C"),

    ("Cumplimiento de los compromisos de servicio", "R02", "A"),
    ("Cumplimiento de los compromisos de servicio", "R12", "R"),
    ("Cumplimiento de los compromisos de servicio", "R09", "R"),
    ("Cumplimiento de los compromisos de servicio", "R10", "C"),

    ("Arquetipo nuevo a la medida, 10 días hábiles", "R03", "A"),
    ("Arquetipo nuevo a la medida, 10 días hábiles", "R06", "R"),
    ("Arquetipo nuevo a la medida, 10 días hábiles", "R11", "C"),
    ("Arquetipo nuevo a la medida, 10 días hábiles", "R02", "I"),
]



# --------------------------------------------------------------------------
# Construccion
# --------------------------------------------------------------------------

def core_snapshot(conn):
    """Lee contadores del brain del core. Federacion por referencia: NO copia el corpus."""
    interes = {
        "rules": "Reglas de negocio extraidas del codigo del legado",
        "capacidades": "Capacidades de negocio modeladas",
        "programs": "Programas del inventario con su trazabilidad",
        "riesgos_migracion": "Riesgos de migracion catalogados",
        "hallazgos": "Hallazgos de migracion por capacidad",
        "sevenr_decisions": "Decisiones de disposicion 7R tomadas",
        "inventario": "Piezas del inventario de ambos sistemas",
        "vocab_terms": "Terminos del vocabulario curado",
        "cross_dependencies": "Dependencias cruzadas entre sistemas",
        "bounded_contexts": "Contextos acotados identificados",
        "regulatory_reports": "Reportes regulatorios mapeados",
        "datasets": "Datasets fisicos del legado",
    }
    if not CORE_BRAIN.exists():
        conn.execute(
            "INSERT INTO brains_federados VALUES (?,?,?,?,?)",
            ("core-unisys", str(CORE_BRAIN), "GemCogBrain",
             "Reglas de negocio, capacidades, riesgos y 7R del core S500 y S151", 0))
        return 0

    src = sqlite3.connect(f"file:{CORE_BRAIN}?mode=ro", uri=True)
    total = 0
    for tabla, que_es in interes.items():
        try:
            n = src.execute(f"SELECT COUNT(*) FROM [{tabla}]").fetchone()[0]
        except sqlite3.Error:
            continue
        conn.execute("INSERT INTO core_snapshot VALUES (?,?,?)", (tabla, n, que_es))
        total += 1
    src.close()

    conn.execute(
        "INSERT INTO brains_federados VALUES (?,?,?,?,?)",
        ("core-unisys", str(CORE_BRAIN), "GemCogBrain",
         "Reglas de negocio, capacidades, riesgos y 7R del core S500 y S151", 1))
    return total


def main():
    if DB.exists():
        DB.unlink()
    conn = sqlite3.connect(DB)
    conn.executescript(SCHEMA)

    conn.executemany("INSERT INTO contrato VALUES (?,?,?)", CONTRATO)
    conn.executemany("INSERT INTO entregables_contractuales VALUES (?,?,?,?,?,?,?,?)", ENTREGABLES_CONTRACTUALES)
    conn.executemany("INSERT INTO compromisos_servicio VALUES (?,?,?,?,?,?)", COMPROMISOS)
    conn.executemany("INSERT INTO tallas VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", TALLAS)
    conn.executemany("INSERT INTO penas VALUES (?,?,?,?)", PENAS)
    conn.executemany("INSERT INTO criterios_arranque VALUES (?,?,?,?)", CRITERIOS_ARRANQUE)

    conn.executemany("INSERT INTO arquetipos VALUES (?,?,?,?,?,?,?)", ARQUETIPOS)
    conn.executemany("INSERT INTO capas_lab VALUES (?,?,?,?)", CAPAS_LAB)
    conn.executemany("INSERT INTO compuertas VALUES (?,?,?,?,?)", COMPUERTAS)
    conn.executemany("INSERT INTO stack (categoria, componente, rol) VALUES (?,?,?)", STACK)
    conn.executemany("INSERT INTO rutas_codigo VALUES (?,?,?,?,?,?)", RUTAS_CODIGO)

    conn.executemany("INSERT INTO fases VALUES (?,?,?,?,?,?,?,?,?,?)", FASES)
    conn.executemany("INSERT INTO hitos VALUES (?,?,?,?,?)", HITOS)
    conn.executemany("INSERT INTO actividades VALUES (?,?,?,?,?,?,?,?,?)", ACTIVIDADES)
    conn.executemany("INSERT INTO semanas VALUES (?,?,?,?,?)", SEMANAS)
    conn.executemany("INSERT INTO entregables_setup (nombre, fase, contractual, nota) VALUES (?,?,?,?)",
                     ENTREGABLES_SETUP)

    conn.executemany("INSERT INTO iniciativas VALUES (?,?,?,?,?,?)", INICIATIVAS)
    conn.executemany("INSERT INTO habilitadores (iniciativa, tipo, que_aporta, origen) VALUES (?,?,?,?)",
                     HABILITADORES)
    conn.executemany("INSERT INTO brechas (iniciativa, brecha, impacto, quien_resuelve, estado) VALUES (?,?,?,?,?)",
                     BRECHAS)
    conn.executemany("INSERT INTO decisiones_abiertas VALUES (?,?,?,?,?)", DECISIONES)
    conn.executemany("INSERT INTO roles VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", ROLES)
    conn.executemany("INSERT INTO limites_ia VALUES (?,?,?,?)", LIMITES_IA)
    conn.executemany("INSERT INTO raci (entregable, rol_id, letra) VALUES (?,?,?)", RACI)
    conn.executemany("INSERT INTO supuestos VALUES (?,?,?,?,?,?)", SUPUESTOS)

    n_core = core_snapshot(conn)

    conn.execute("INSERT INTO actividades_fts(actividades_fts) VALUES('rebuild')")

    for clave, sql in [
        ("entregables_contractuales", "SELECT COUNT(*) FROM entregables_contractuales"),
        ("compromisos_servicio", "SELECT COUNT(*) FROM compromisos_servicio"),
        ("actividades", "SELECT COUNT(*) FROM actividades"),
        ("actividades_en_sow", "SELECT COUNT(*) FROM actividades WHERE en_sow=1"),
        ("actividades_apoyo", "SELECT COUNT(*) FROM actividades WHERE en_sow=0"),
        ("actividades_pendientes", "SELECT COUNT(*) FROM actividades WHERE estado='PENDIENTE'"),
        ("entregables_setup", "SELECT COUNT(*) FROM entregables_setup"),
        ("entregables_setup_contractuales", "SELECT COUNT(*) FROM entregables_setup WHERE contractual=1"),
        ("arquetipos", "SELECT COUNT(*) FROM arquetipos"),
        ("iniciativas", "SELECT COUNT(*) FROM iniciativas"),
        ("brechas_abiertas", "SELECT COUNT(*) FROM brechas WHERE estado!='CERRADA'"),
        ("decisiones_abiertas", "SELECT COUNT(*) FROM decisiones_abiertas WHERE estado='ABIERTA'"),
        ("stack_componentes", "SELECT COUNT(*) FROM stack"),
        ("roles", "SELECT COUNT(*) FROM roles"),
        ("supuestos_dimensionamiento", "SELECT COUNT(*) FROM supuestos"),
        ("limites_ia", "SELECT COUNT(*) FROM limites_ia"),
        ("semanas_implementacion", "SELECT COUNT(*) FROM semanas"),
        ("hitos", "SELECT COUNT(*) FROM hitos"),
        ("raci_asignaciones", "SELECT COUNT(*) FROM raci"),
    ]:
        conn.execute("INSERT INTO stats VALUES (?,?)", (clave, conn.execute(sql).fetchone()[0]))

    conn.commit()

    out = sys.stdout
    out.write("lab-brain.db construido\n")
    out.write(f"  ruta: {DB}\n")
    for clave, valor in conn.execute("SELECT clave, valor FROM stats ORDER BY clave"):
        out.write(f"  {clave:36s} {valor:>6}\n")
    if n_core:
        total_core = conn.execute("SELECT SUM(filas) FROM core_snapshot").fetchone()[0]
        out.write(f"  brain del core federado: {n_core} tablas, {total_core:,} filas por referencia\n")
    else:
        out.write("  AVISO: brain del core NO disponible en la ruta esperada\n")
    conn.close()


if __name__ == "__main__":
    main()
