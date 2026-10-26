# -*- coding: utf-8 -*-
"""
load-portfolio-2027.py
Carga el portafolio de iniciativas 2027 de AXA México y lo cruza con el landscape.

Fuente: source/Roles Description_Team 2027 portfolio.xlsx
  hoja 'Portafolio' -> 13 iniciativas, todas en estado "Discovery no iniciado"
  hoja 'Roles'      -> 8 roles del equipo objetivo 2027

Este portafolio es el eje CHANGE: transformación de infraestructura y deuda técnica.
No se solapa con el eje de negocio que ya vive en el brain (suscripción de Daños),
salvo en seis puntos de contacto que este script deja explícitos en initiative_systems.

AVISO DE CONFIDENCIALIDAD
  La columna responsable_axa contiene nombres de personas del cliente. Es de uso
  interno del brain. No debe salir a ningún portal, deck ni artefacto compartible.
  Lo mismo aplica a opp_acn y winability, que son pipeline comercial y cuyo dueño
  es Solutioning, no Digital Core.

Uso:
    python generators/load-portfolio-2027.py
    python generators/load-portfolio-2027.py --dry-run
"""

import os
import sqlite3
import sys
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE_DIR, "axa-brain.db")
SOURCE = "Roles Description_Team 2027 portfolio.xlsx"

DDL = """
CREATE TABLE IF NOT EXISTS initiatives (
    id               TEXT PRIMARY KEY,
    clave_cliente    TEXT,
    nombre           TEXT,
    programa         TEXT,
    estado           TEXT,
    responsable_axa  TEXT,   -- INTERNO: nunca exponer en portal
    contexto         TEXT,
    siguientes_pasos TEXT,
    horizonte        TEXT,
    opp_acn          TEXT,   -- INTERNO: pipeline, dueño es Solutioning
    winability       REAL,   -- INTERNO: pipeline, dueño es Solutioning
    source           TEXT
);

CREATE TABLE IF NOT EXISTS initiative_systems (
    initiative_id   TEXT,
    system_slug     TEXT,
    relation        TEXT,
    evidence        TEXT,
    PRIMARY KEY (initiative_id, system_slug)
);

CREATE TABLE IF NOT EXISTS initiative_dependencies (
    initiative_a    TEXT,
    initiative_b    TEXT,
    note            TEXT,
    PRIMARY KEY (initiative_a, initiative_b)
);

CREATE TABLE IF NOT EXISTS portfolio_roles (
    id              TEXT PRIMARY KEY,
    assigned_for    TEXT,
    role            TEXT,
    activities      TEXT,
    skills          TEXT,
    source          TEXT
);
"""

# ──────────────────────────────────────────────────────────────────────
# INICIATIVAS — hoja 'Portafolio', filas 2 a 14
# El cliente tiene todas con clave PDP-000, que es un marcador sin asignar.
# El id INI-NNN es interno del brain y sigue el orden de la hoja.
# ──────────────────────────────────────────────────────────────────────
INITIATIVES = [
    ("INI-001", "PDP-000", "Transformación TI", "Transformación TI", "Discovery no iniciado",
     "Por definir",
     "Retomar el RFI de 2026. Requieren adaptar el modelo operativo de AXA GO y el uso de la nube, "
     "separar los recursos de AXA Seguros en Run y Transform para atender BAU y proyectos, e implementar "
     "un nuevo proceso de ciclo de vida de desarrollo de aplicaciones.",
     "Adaptar modelo operativo AXA GO y nube; separar recursos en Run y Transform; "
     "implementar nuevo ciclo de vida de desarrollo.",
     "Sin fecha declarada", "si", 0.2),

    ("INI-002", "PDP-000", "Exit Run Off Zone", "Exit RoZ", "Discovery no iniciado",
     "Isaac Soto",
     "Sacar las aplicaciones de la Run Off Zone antes del Q4 2028. En etapa de preparación para formalizar "
     "discovery, a presentar en CoMex del 28 de octubre.",
     "De octubre a diciembre, discovery para definir estrategias de migración, mapeo de aplicaciones por "
     "complejidad y estimaciones detalladas. En enero se suman el resto de recursos y fábricas para "
     "discoveries detallados. Montar la estructura de gobierno de la oficina de transformación, incluyendo "
     "el nuevo rol de arquitectura y gestión de dependencias.",
     "Discovery Q4 2026, ejecución desde Q1 2027, cierre antes de Q4 2028", "si", 0.8),

    ("INI-003", "PDP-000", "Upgrade SAN", "Exit RoZ relacionado", "Discovery no iniciado",
     "Por definir",
     "El SAN actual vive en infraestructura fuera de soporte (HPUX) y solo funciona en uno de los nodos "
     "porque el de Swanne está dañado. Riesgo de pérdida de información, particularmente en aplicaciones "
     "transversales. Vida y Daños tienen habilitado un respaldo temporal.",
     "Incluir en la estrategia de Exit RoZ.",
     "Sin fecha declarada", None, None),

    ("INI-004", "PDP-000", "Decomiso Datapower", "Exit RoZ relacionado", "Discovery no iniciado",
     "Victor Reyna",
     "Cerca del 95% de las aplicaciones de AXA Seguros pasan hoy por Datapower. Los ambientes de desarrollo "
     "y QA están en MPI, pero por complejidad de la red el de producción se llevó a la Run Off Zone. La "
     "directriz global es construir las APIs en Mulesoft: el producto ya está instalado y los estándares y "
     "políticas ya están definidos.",
     "Que cada célula de transformación se haga responsable de crear sus APIs. Resolver las dependencias "
     "cruzadas con el decomiso de VIPs y el cambio de ECM.",
     "Sin fecha declarada", "si", 0.2),

    ("INI-005", "PDP-000", "One workplace", "Skyline", "Discovery no iniciado",
     "Dulce Jaret Vargas (solo discovery)",
     "En 2026 instalaron monitoreo de endpoint (Nexthink) para un problema específico de red y hoy no usan "
     "la funcionalidad completa. Requieren analizar el valor de la herramienta y adoptar otras dentro del "
     "programa de grupo Skyline. Hoy están en 900 de 4 mil equipos, y no se requiere para todos.",
     "Asignar PM para crear el material del CoMex de noviembre e iniciar la fase de ejecución. Definir el "
     "modelo operativo y el modelo de costeo para la adopción.",
     "Termina en Q4 2027", None, None),

    ("INI-006", "PDP-000", "Windows Edition", "Skyline", "Discovery no iniciado",
     "Dulce Jaret Vargas",
     "Proyecto retomado en octubre para piloto. Estaba en pausa por 42 aplicaciones remediadas y 22 "
     "desmanteladas. Implica validar que las dependencias se hayan eliminado o remediar las aplicaciones "
     "incompatibles, cambio de hardware de usuario final, cambio de imagen de equipos y adopción de "
     "herramientas de seguridad adicionales.",
     "Sesión de alineación para conocer dependencias y, en función de eso, pedir el discovery.",
     "Estimación de Q1 2027 a Q1 2029", "si", 0.1),

    ("INI-007", "PDP-000", "Exit JAVA", "Sin programa asignado", "Discovery no iniciado",
     "Por definir",
     "Iniciativa declarada sin contexto desarrollado en la fuente. El alcance real está por definir.",
     "Alinear con Exit RoZ. La propia fuente marca esta alineación con interrogante.",
     "Sin fecha declarada", None, None),

    ("INI-008", "PDP-000", "Estabilidad", "Sin programa asignado", "Discovery no iniciado",
     "Memo Torres",
     "Estabilizar la operación de aplicaciones críticas: SIGAME, Orbeon, Portal y MFA. En Liferay no "
     "quitaron las referencias a servidores de Core IT.",
     "Definir objetivos por aplicación e incluir en el discovery la definición de métricas para poder "
     "cerrar puntualmente, con manejo en fases. Para la adopción de MFA deben actualizar WSO2 y luego "
     "clasificar las liberaciones por impacto bajo, medio y alto. Las liberaciones de impacto alto "
     "iniciarán hasta 2027.",
     "Liberaciones de impacto alto desde 2027", None, None),

    ("INI-009", "PDP-000", "Decomiso VIPS", "Sin programa asignado", "Discovery no iniciado",
     "Gaby Calleja (solo para piloto 2026)",
     "Decomiso de equipos a final de 2026 por obsolescencia de los F5 Viprion. Los balanceadores "
     "virtualizados en POD y en la Run Off Zone agregan elementos adicionales de seguridad (MPI Application "
     "Gateway, Apache Reverse Proxy y Akamai Internet Shield), lo que obliga a adoptar nuevos estándares de "
     "arquitectura.",
     "En 2026, definir los casos de uso existentes y armar el playbook para migrar cada caso, más la "
     "ejecución de una aplicación por cada caso de uso. En 2027, el cambio en todas las aplicaciones que "
     "utilicen F5.",
     "Playbook y piloto en 2026, despliegue en 2027", None, None),

    ("INI-010", "PDP-000", "Adopción de productos de Seguridad LISA", "Sin programa asignado",
     "Discovery no iniciado",
     "Efraín",
     "Implementación de Identity and Access Management con los productos LISA.",
     "Empezar desde discovery.",
     "Programado para todo 2027", None, None),

    ("INI-011", "PDP-000", "Gestión de deuda técnica en la Nube", "Transformación TI relacionado",
     "Discovery no iniciado",
     "Directores de dominio",
     "Arranque con recursos de las fábricas para Autos y otras células.",
     "Posiblemente pueda juntarse con el modelo operativo para el ciclo de vida de las aplicaciones.",
     "Inicio en 2027", None, None),

    ("INI-012", "PDP-000", "Documentación de aplicaciones", "Sin programa asignado",
     "Discovery no iniciado",
     "Memo Torres",
     "Documentación del parque aplicativo.",
     "No es prioridad por el momento.",
     "Inicio en 2027", None, None),

    ("INI-013", "PDP-000", "CMX Adoption", "Exit RoZ relacionado", "Discovery no iniciado",
     "JJ",
     "En 2026 se descartó usar el producto global por el costo asociado. La decisión actual es que el equipo "
     "de CTO haga la instalación de la plataforma, y que la migración y depuración de archivos sea "
     "responsabilidad de las células. La fuente anticipa que este enfoque no garantiza dejar de usar los "
     "servidores de la Run Off Zone antes de 2028.",
     "Se requiere un enfoque transversal para definir nuevas políticas de guardado y retención, además de "
     "un equipo dedicado que empuje las migraciones.",
     "Debe cerrar antes de 2028 para habilitar Exit RoZ", "si", 0.1),
]

# ──────────────────────────────────────────────────────────────────────
# CRUCE CON EL LANDSCAPE — solo donde hay evidencia textual en la fuente
# relation: decommission | migrate-to | remediate | stabilize | depends-on
# ──────────────────────────────────────────────────────────────────────
INITIATIVE_SYSTEMS = [
    ("INI-002", "api-gateway", "depends-on",
     "El Datapower de producción se llevó a la Run Off Zone por complejidad de red, así que sacarlo de RoZ "
     "es parte del alcance"),

    ("INI-003", "policy-admin-vida", "depends-on",
     "Vida tiene habilitado un respaldo temporal frente al riesgo de pérdida de información del SAN"),
    ("INI-003", "policy-admin-danos", "depends-on",
     "Daños tiene habilitado un respaldo temporal frente al riesgo de pérdida de información del SAN"),

    ("INI-004", "api-gateway", "decommission",
     "Decomiso de Datapower, por donde pasa hoy cerca del 95% de las aplicaciones de AXA Seguros"),
    ("INI-004", "esb", "migrate-to",
     "La directriz global es construir las APIs en Mulesoft, ya instalado y con estándares y políticas "
     "definidos"),

    ("INI-007", "app-servers", "remediate",
     "Las aplicaciones a migrar incluyen Java 6 a 21 según la descripción del rol de Enterprise and "
     "Integration Architect"),

    ("INI-008", "claims-salud", "stabilize",
     "SIGAME es una de las cuatro aplicaciones críticas a estabilizar, y es componente de claims-salud"),
    ("INI-008", "wso2", "remediate",
     "La adopción de MFA exige actualizar WSO2 antes de clasificar las liberaciones por impacto"),

    ("INI-009", "perimeter", "decommission",
     "Decomiso de los F5 Viprion por obsolescencia a final de 2026, con cambio en 2027 de todas las "
     "aplicaciones que usen F5"),
    ("INI-009", "waf", "migrate-to",
     "Los balanceadores virtualizados agregan MPI Application Gateway, Apache Reverse Proxy y Akamai "
     "Internet Shield como nuevos estándares de arquitectura"),

    ("INI-010", "iam", "migrate-to",
     "Implementación de Identity and Access Management con productos LISA"),
    ("INI-010", "iam-legacy", "decommission",
     "La adopción de LISA es el destino de la migración desde el directorio local LDAP"),
    ("INI-010", "iga-sailpoint", "depends-on",
     "SailPoint es el IGA del estado TO BE que acompaña la adopción de LISA"),

    ("INI-011", "cloud-backbone", "remediate",
     "Gestión de deuda técnica en la nube con recursos de las fábricas"),

    ("INI-013", "ecm-ridd", "migrate-to",
     "Adopción de CMX con instalación por el equipo de CTO y migración y depuración de archivos a cargo de "
     "las células"),
]

# ──────────────────────────────────────────────────────────────────────
# DEPENDENCIAS ENTRE INICIATIVAS — declaradas en la fuente
# ──────────────────────────────────────────────────────────────────────
INITIATIVE_DEPENDENCIES = [
    ("INI-004", "INI-009", "La fuente declara dependencias cruzadas entre el decomiso de Datapower y el de VIPs"),
    ("INI-004", "INI-013", "La fuente declara dependencia cruzada entre el decomiso de Datapower y el cambio de ECM"),
    ("INI-003", "INI-002", "El Upgrade SAN debe incluirse en la estrategia de Exit RoZ"),
    ("INI-004", "INI-002", "Marcada como Exit RoZ relacionado: el Datapower de producción vive en la Run Off Zone"),
    ("INI-013", "INI-002", "Marcada como Exit RoZ relacionado: CMX condiciona dejar los servidores de RoZ antes de 2028"),
    ("INI-007", "INI-002", "La fuente indica alinear Exit JAVA con Exit RoZ, con interrogante"),
    ("INI-011", "INI-001", "Marcada como Transformación TI relacionado, posiblemente se junte con el modelo operativo"),
    ("INI-005", "INI-006", "Ambas pertenecen al programa de grupo Skyline y comparten el parque de usuario final"),
]

# ──────────────────────────────────────────────────────────────────────
# ROLES — hoja 'Roles', filas 1 a 8
# ──────────────────────────────────────────────────────────────────────
ROLES = [
    ("ROL-1", "Central team", "Enterprise and Integration Architect",
     "Desarrollar el entendimiento extremo a extremo del landscape aplicativo. Guiar y consultar a los "
     "equipos de proyecto en temas de arquitectura. Identificar dependencias técnicas entre iniciativas del "
     "portafolio y asesorar su remediación. Apoyar a los equipos en decisiones de diseño y en la creación "
     "de DCS.",
     "Aplicaciones a migrar o transformar, lista no exhaustiva: Java 6 a 21, Linux Red Hat 5.11 a 9.8, "
     "Progress 9.x a 11.7, WAS 7 a 8.5, Windows 2008 a 2022 R2"),

    ("ROL-2", "VIPs decom", "Network Architect",
     "Consultar y asesorar a los equipos de aplicaciones sobre la nueva arquitectura de red con F5 y Akamai "
     "WAF. Analizar y desarrollar patrones de diseño.",
     "Indispensable: F5. Deseable: MPI Application Gateway, Apache Reverse Proxy, Akamai Internet Shield"),

    ("ROL-3", "Central team", "PMO",
     "Creación de reportes de estatus. Apoyo en reportes y presentaciones de dirección. Preparación y "
     "organización de reuniones. Análisis financiero, planeación y seguimiento de presupuesto.",
     "Indispensable: certificación PMP o equivalente. Deseable: Jira, ServiceNow"),

    ("ROL-4", "PM Pool", "Monitoring lead",
     "Desarrollar la estrategia y el marco de monitoreo y observabilidad de aplicaciones para Seguros. "
     "Gestionar la implementación y el despliegue de la estrategia de monitoreo.",
     "Experiencia de varios años en monitoreo y observabilidad de aplicaciones. Experiencia con Dynatrace. "
     "Trayectoria sólida en gestión de proyectos"),

    ("ROL-5", "PM Pool", "Workplace expert",
     "Coordinar el proyecto de actualización del sistema operativo en equipo de usuario final y el refresh "
     "de hardware. Entender, comunicar y gestionar dependencias, por ejemplo que una aplicación no sea "
     "soportada en el nuevo sistema operativo y requiera remediación.",
     "Experiencia de varios años en despliegues complejos de workplace incluyendo hardware. Conocimiento "
     "técnico sólido en tecnologías de workplace. Trayectoria sólida en gestión de proyectos"),

    ("ROL-6", "PM Pool", "Migration lead (Legacy)",
     "Dirigir una fábrica de migración de cerca de 15 personas y liderar varias migraciones de aplicaciones "
     "en paralelo. Gestión extremo a extremo de los proyectos de migración en todo el ciclo: diseño, "
     "aprovisionamiento, despliegues, pruebas, cutover, hypercare y entrega a BAU, conforme a la "
     "metodología de migración de AXA. Planear y coordinar las actividades de remediación necesarias, como "
     "actualizaciones de librerías o frameworks. Coordinar equipos locales y globales.",
     "Trayectoria liderando proyectos de migración a la nube, a IaaS y PaaS. Experiencia en tecnologías "
     "cloud, en especial Azure. Buen conocimiento del stack tecnológico: arquitectura de red y middleware"),

    ("ROL-7", "Datapower decom", "Mulesoft lead",
     "Revisar y ajustar las políticas y guías acordadas para el uso de Mulesoft, y definirlas si no "
     "existen. Coordinar la creación de APIs en Mulesoft para decomisar Datapower.",
     "Indispensable: Mulesoft, Datapower"),

    ("ROL-8", "Eng. Team", "Major incidents coordinator",
     "Coordinar la resolución y el troubleshooting de incidentes mayores. Gestionar el involucramiento de "
     "los interesados clave durante los incidentes para la resolución y la toma de decisiones.",
     "Deseable: uso de ServiceNow"),
]


def validate(conn):
    errors = []
    ids = {i[0] for i in INITIATIVES}
    if len(ids) != len(INITIATIVES):
        errors.append("Ids de iniciativa duplicados")
    known_systems = {r[0] for r in conn.execute("SELECT slug FROM systems")}
    if not known_systems:
        errors.append("La tabla systems está vacía. Ejecuta build-landscape-v2.py primero")
    for iid, slug, _rel, _ev in INITIATIVE_SYSTEMS:
        if iid not in ids:
            errors.append(f"Cruce apunta a iniciativa inexistente: {iid}")
        if slug not in known_systems:
            errors.append(f"Cruce apunta a sistema fuera del landscape: {slug}")
    for a, b, _n in INITIATIVE_DEPENDENCIES:
        for side in (a, b):
            if side not in ids:
                errors.append(f"Dependencia apunta a iniciativa inexistente: {side}")
    if errors:
        for e in errors:
            print(f"  [ERROR] {e}")
        raise SystemExit("[ABORT] El portafolio no es coherente. No se escribió nada.")
    print(f"  [OK] {len(INITIATIVES)} iniciativas, {len(INITIATIVE_SYSTEMS)} cruces con el landscape, "
          f"{len(INITIATIVE_DEPENDENCIES)} dependencias entre iniciativas, {len(ROLES)} roles")


def load(conn):
    cur = conn.cursor()
    cur.executescript(DDL)

    cur.execute("DELETE FROM initiatives")
    for row in INITIATIVES:
        cur.execute("""
            INSERT INTO initiatives
              (id, clave_cliente, nombre, programa, estado, responsable_axa,
               contexto, siguientes_pasos, horizonte, opp_acn, winability, source)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?)
        """, (*row, SOURCE))
    print(f"  [OK] initiatives: {len(INITIATIVES)}")

    cur.execute("DELETE FROM initiative_systems")
    cur.executemany(
        "INSERT INTO initiative_systems (initiative_id, system_slug, relation, evidence) VALUES (?,?,?,?)",
        INITIATIVE_SYSTEMS)
    print(f"  [OK] initiative_systems: {len(INITIATIVE_SYSTEMS)}")

    cur.execute("DELETE FROM initiative_dependencies")
    cur.executemany(
        "INSERT INTO initiative_dependencies (initiative_a, initiative_b, note) VALUES (?,?,?)",
        INITIATIVE_DEPENDENCIES)
    print(f"  [OK] initiative_dependencies: {len(INITIATIVE_DEPENDENCIES)}")

    cur.execute("DELETE FROM portfolio_roles")
    for row in ROLES:
        cur.execute(
            "INSERT INTO portfolio_roles (id, assigned_for, role, activities, skills, source) "
            "VALUES (?,?,?,?,?,?)", (*row, SOURCE))
    print(f"  [OK] portfolio_roles: {len(ROLES)}")

    cur.executemany("INSERT OR REPLACE INTO brain_meta (key, value) VALUES (?,?)", [
        ("portfolio_version", "2027"),
        ("portfolio_loaded_at", datetime.now().strftime("%Y-%m-%d %H:%M")),
        ("initiatives_count", str(len(INITIATIVES))),
        ("source_portfolio", SOURCE),
    ])
    conn.commit()


def report(conn):
    print("\n[SISTEMAS DEL LANDSCAPE TOCADOS POR EL PORTAFOLIO]")
    q = """
        SELECT s.slug, s.real_name, COUNT(*) n,
               GROUP_CONCAT(i.nombre || ' (' || isy.relation || ')', ' | ')
        FROM initiative_systems isy
        JOIN systems s ON s.slug = isy.system_slug
        JOIN initiatives i ON i.id = isy.initiative_id
        GROUP BY s.slug ORDER BY n DESC, s.slug
    """
    for slug, real, n, inis in conn.execute(q):
        print(f"  {slug:<22} {real}")
        print(f"      {inis}")

    print("\n[INICIATIVAS SIN CRUCE CON EL LANDSCAPE]")
    q2 = """
        SELECT i.id, i.nombre FROM initiatives i
        LEFT JOIN initiative_systems isy ON isy.initiative_id = i.id
        WHERE isy.initiative_id IS NULL ORDER BY i.id
    """
    for iid, nombre in conn.execute(q2):
        print(f"  {iid}  {nombre}")


def main():
    dry = "--dry-run" in sys.argv
    print("[PORTFOLIO] AXA México 2027")
    conn = sqlite3.connect(DB_PATH)
    conn.executescript(DDL)
    print("[VALIDATE]")
    validate(conn)
    if dry:
        print("[DRY-RUN] Nada escrito.")
        return
    print("[LOAD]")
    load(conn)
    report(conn)
    conn.close()


if __name__ == "__main__":
    main()
