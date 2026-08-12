"""seed-swarm-5.py — Grupo 5 swarm extracción estratégica Bank Brain BanCoppel

Fuentes procesadas (marzo-abril 2026):
  - 27 Mar: Sesión introductoria de diagnóstico con Arquitectura BCP
  - 31 Mar: Kreios/Alondra (Change Mgmt) + Tere González (follow-up arquitectura)
  - 15-16 Abr: Impacto Migración y ATLAS en Plan E2E
  - 20 Abr: Roster + Planeación próximas 3 semanas (interna ACN)
  - 24 Abr: Revisión roadmap SmartVista (R3/R4 strategy)
  - 28 Abr: Alineación Christian Zazueta - ACN (Atlas, Golden Record, TCC ID4900)
  - 29 Abr: Alineación semanal Transact (dependencias legado, arquitectura)
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent / "bank-brain.db"

# (id, date, topic, decision_text, driver_id_or_None, confidence)
DECISIONS = [
    # --- Diagnóstico y gobierno del programa ---
    ("SW5-DEC-001", "2026-03-27", "Diagnóstico-Alcance",
     "Diagnóstico Accenture definido como 6 semanas de assessment sin ejecución de remediación; semanas 7+ para recomendaciones y posible fase activa de acompañamiento",
     "juan-manuel", 0.95),

    ("SW5-DEC-002", "2026-03-27", "Arquitectura-Prioridad",
     "Arquitectura declarada como el frente prioritario del diagnóstico tecnológico de Unity por encima de todos los demás ejes",
     "lukasz-pietrzyk", 0.92),

    ("SW5-DEC-003", "2026-03-27", "Assessment-Enfoque",
     "Enfoque del assessment: hechos, evidencia y entrevistas; ausencia de documentación es hallazgo en sí mismo que se cubre con sesiones de reconstrucción",
     "lukasz-pietrzyk", 0.90),

    ("SW5-DEC-004", "2026-03-27", "MuleSoft-Objetivo",
     "MuleSoft declarado como capa de exposición e integración empresarial objetivo por estrategia corporativa de arquitectura; Unity no está alineado todavía a esa dirección",
     "arcadio", 0.85),

    ("SW5-DEC-005", "2026-03-27", "API-Transición",
     "Contrato de capa de exposición actual (APG/APIL) vigente hasta 2028 sin intención de renovación; la transición a MuleSoft debe planificarse explícitamente en el roadmap y caso de negocio",
     None, 0.88),

    ("SW5-DEC-006", "2026-03-31", "Change-Mgmt-Complementario",
     "Gestión del cambio: enfoque factual, complementario y no disruptivo entre equipo ACN (Karina) y firma Kreios (Leticia); evitar traslapes y coordinar actividades en paralelo",
     "pablo-lorenzo", 0.85),

    # --- Plan E2E y metodología ---
    ("SW5-DEC-007", "2026-04-15", "Plan-E2E-Urgente",
     "Plan integral E2E con cronograma requerido urgentemente para presentación al consejo de accionistas el 24 de abril; planes existentes demasiado fragmentados por stream",
     "juan-manuel", 0.95),

    ("SW5-DEC-008", "2026-04-16", "Migración-UAT-Gate",
     "No proceder con migración a producción hasta que UAT esté completamente terminado; gate explícito y no negociable",
     None, 0.95),

    ("SW5-DEC-009", "2026-04-16", "Dry-Runs-ETL",
     "Incorporar dry runs/mock runs de ETL integral previos a UAT para iterar y estabilizar la migración antes de pruebas de aceptación; paso que no existía en el proceso actual",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-010", "2026-04-16", "Dress-Rehearsal",
     "Incorporar 2-3 simulacros de producción (Dress Rehearsals) antes del go-live para afinar el runbook en ambiente pre-productivo; involucra negocio, operaciones, IT y QA",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-011", "2026-04-20", "Advisory-Assurance",
     "Accenture asume rol dual Advisory y Assurance; el programa requiere significativamente más Advisory que Assurance en las dimensiones técnicas críticas: testing, integración, DRP, Transition-to-Run",
     "pablo-lorenzo", 0.92),

    ("SW5-DEC-012", "2026-04-20", "Gobernanza-Condicionada",
     "Gobernanza de Accenture condicionada a compromiso de BCP de cerrar brechas fundacionales; no es viable asumir gobierno sin que el cliente cierre los mínimos fundacionales identificados",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-013", "2026-04-20", "Roster-Rediseño",
     "Roster del programa Unity debe ser rediseñado y formalizado alineado al modelo operativo objetivo y a la estructura de gobierno; el roster actual no refleja roles, dedicación ni accountability reales",
     None, 0.82),

    ("SW5-DEC-014", "2026-04-24", "Testing-Transversal",
     "Metodología de pruebas transversal adoptada: SIT 3 meses + UAT 3 meses con ciclos mensuales y testing no funcional (performance + seguridad) en paralelo; aplicar a partir de R4",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-015", "2026-04-24", "SmartVista-R3",
     "R3 SmartVista se libera de forma independiente y separada según compromisos previos con el negocio; agrupación con R4 rechazada porque el negocio no aceptará más retrasos",
     None, 0.92),

    ("SW5-DEC-016", "2026-04-24", "SmartVista-R4",
     "R4 SmartVista adopta nueva estrategia de pruebas integrales exhaustivas; liberación estimada pasa a inicios de febrero (originalmente diciembre) por extensión del ciclo de testing",
     "pablo-lorenzo", 0.88),

    ("SW5-DEC-017", "2026-04-24", "Roadmap-Decisores",
     "Sergio del Valle y Juan Manuel son los decisores finales de roadmap y producto SmartVista; plan debe validarse con Sergio del Valle antes de comunicar a Juan Manuel",
     None, 0.90),

    ("SW5-DEC-018", "2026-04-24", "Integración-En-Desarrollo",
     "Integración debe tratarse como parte integral de la fase de desarrollo (Análisis-Diseño-Implementación), no como fase separada posterior al desarrollo; decisión metodológica para R4 en adelante",
     "lukasz-pietrzyk", 0.85),

    # --- Atlas, Golden Record, Migración ---
    ("SW5-DEC-019", "2026-04-16", "Atlas-Estructura",
     "Atlas estructurado en 4 fases Crawl-Walk-Run-Fly de 6 meses cada una, horizonte 2 años; Fase 3 incluye migración de clientes desde PISA y visión 360 de más de 25 millones de clientes",
     None, 0.95),

    ("SW5-DEC-020", "2026-04-16", "Atlas-Fase1",
     "Atlas Fase 1 (Crawl): infraestructura GCP, MDM v1, reglas de matching, pipelines y golden record básico de clientes para BanCoppel; objetivo agosto 2026",
     None, 0.92),

    ("SW5-DEC-021", "2026-04-28", "Atlas-Fase2-Dependencia-Crítica",
     "Atlas Fase 2: MDM/Golden Record en producción a fines de septiembre 2026; dependencia crítica que debe cumplirse antes de la migración de Tarjeta de Crédito Clásica en SmartVista planificada para diciembre 2026",
     None, 0.93),

    ("SW5-DEC-022", "2026-04-28", "TCC-ID4900",
     "Proceder con migración de Tarjeta de Crédito Clásica al ID 4900 en SmartVista aceptando riesgo regulatorio de no-declaración ante Banxico; esfuerzo adicional no mapeado en reportes actuales",
     None, 0.85),

    ("SW5-DEC-023", "2026-04-28", "Migración-Transversal",
     "Equipo de migración debe ser transversal al portafolio Unity con ambiente propio para ejecutar mock runs y MOs estabilizadores en ambiente integrado; actualmente en fase de fortalecimiento de capacidad",
     None, 0.82),

    ("SW5-DEC-024", "2026-04-28", "Metodología-Migración-Transact",
     "Metodología de migración SmartVista/IWI (Tarjeta de Crédito Clásica) usada como habilitador y modelo de continuidad para la migración de Transact (minorista); Transact en etapas muy iniciales",
     None, 0.82),
]

# (stakeholder_id, topic, stance_text, sentiment, date)
POSITIONS = [
    ("pablo-lorenzo", "Testing-Transversal",
     "El programa necesita SIT 3m + UAT 3m + dress rehearsals; el enfoque actual produce fases planificadas de 4 semanas que se extienden a 4 meses por deficiencias estructurales",
     "concerned", "2026-04-28"),

    ("juan-manuel", "Plan-E2E",
     "Se requiere urgentemente un plan integral E2E con cronograma para el consejo; los planes existentes están demasiado fragmentados por stream y carecen de una capa de integración que los unifique",
     "urgent", "2026-04-15"),

    ("lukasz-pietrzyk", "Golden-Record-Latencia",
     "Existe preocupación real por la latencia entre consumidores en AWS y on-prem con el Golden Record alojado en GCP; el diseño de integración actual no contempla ese diferencial de red",
     "concerned", "2026-04-28"),

    ("lukasz-pietrzyk", "Documentación-Arquitectura",
     "La documentación disponible de arquitectura es parcial e insuficiente; el conocimiento quedó tácito y disperso porque el equipo operativo ejecutó más que documentar",
     "concerned", "2026-03-27"),

    ("lukasz-pietrzyk", "Arquitectura-Reactiva",
     "La arquitectura hoy reacciona en lugar de guiar; el Design Authority llega tarde y no influye realmente en las decisiones; los NFRs de seguridad, performance y picos no están bien definidos",
     "concerned", "2026-03-27"),

    ("arturo-perez", "Documentación-Histórica",
     "Muchas estrategias se definieron al inicio del proyecto; el equipo operativo ejecutó más que documentar y la arquitectura evolucionó sobre la marcha; hay lineamientos vigentes pero no documento maestro",
     "neutral", "2026-03-27"),

    ("arcadio", "Participación-Arquitectura",
     "Solicitó ser incluido en TODAS las invitaciones de sesiones de arquitectura y propone incluir también a Mercedes; manifestó interés en participar activamente y buscar espacio en agenda",
     "positive", "2026-03-31"),

    ("arcadio", "MuleSoft-Transición",
     "La estrategia corporativa de arquitectura apunta a MuleSoft pero Unity no está alineado todavía; el contrato actual vigente hasta 2028 requiere planificar una transición explícita en el roadmap",
     "concerned", "2026-03-27"),

    ("rodrigo", "Change-Mgmt-Alineación",
     "Ambos equipos de gestión del cambio deben converger; es indispensable coordinar para evitar traslapes y choques de actividades; enfoque debe ser factual y complementario, no confrontacional",
     "neutral", "2026-03-31"),

    ("rodrigo", "Unity-Caso-Piloto",
     "Existe la oportunidad de usar Unity como caso piloto para fortalecer capacidades de banking en México dentro de Accenture; visión estratégica de largo plazo más allá del contrato actual",
     "positive", "2026-04-20"),

    ("pablo-lorenzo", "Negocio-Golden-Record",
     "El área de Negocio está evadiendo su responsabilidad en la definición del Golden Record de Atlas; esto es riesgo crítico porque Negocio debe definir reglas de matching y proporcionar definiciones clave",
     "concerned", "2026-04-28"),

    ("pablo-lorenzo", "Legado-Caja-Gris",
     "El legado es una caja gris que bloquea la construcción del roadmap integrado; no hay una persona unificada con conocimiento de fechas, desarrollos y dependencias del sistema legacy",
     "concerned", "2026-04-29"),

    ("pablo-lorenzo", "Gobernanza-Con-Mínimos",
     "Accenture no puede prometer ejecuciones que no pueda cumplir en capacidad o perfiles; el takeover del programa debe ir acompañado de remediación real de brechas fundacionales, no solo governance formal",
     "cautious", "2026-04-20"),

    ("pablo-lorenzo", "North-Star-Ausente",
     "No existe un North Star de negocio claro traducido en journeys end-to-end, funcionalidades y prioridades cross-producto; las decisiones se toman por plataforma y silo sin lógica integrada de negocio",
     "concerned", "2026-04-20"),

    ("lukasz-pietrzyk", "R3-R4-Agrupación",
     "La propuesta de agrupar R3 y R4 tiene sentido conceptualmente pero el negocio la rechazará porque ya hubo retrasos previos y Sergio del Valle necesita ver R3 liberado según lo comprometido",
     "neutral", "2026-04-24"),

    ("karina-zepeda", "Assessment-Estado",
     "El equipo de change management está en fase de entrevistas y acercamiento inicial; aún no hay entregable formal porque se está construyendo el diagnóstico base; requiere coordinación con Kreios",
     "neutral", "2026-03-31"),

    ("pablo-lorenzo", "Metodología-Migración-Brecha",
     "Las metodologías de migración de SmartVista y Transact están completamente aisladas; Transact en etapas muy iniciales con fechas aspiracionales; brecha significativa que debe cerrarse",
     "concerned", "2026-04-28"),

    ("arturo-perez", "Certificación-Arquitectura",
     "El proceso de certificación de arquitectura de 9 capas existe y genera backlog técnico real con observaciones concretas; es una fuente útil de estado actual aunque no sustituye el documento maestro",
     "neutral", "2026-03-27"),
]

# (id, date, item_text, owner_id_or_None, priority, systems_json)
OPEN_ITEMS = [
    ("SW5-OI-001", "2026-04-15",
     "Plan integral E2E con cronograma para presentación al consejo de accionistas del 24 de abril; integrar Transact, Apolo, SmartVista, Atlas y Legacy en una sola vista temporal con dependencias",
     "pablo-lorenzo", "critical", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-002", "2026-04-16",
     "Plan detallado del Proyecto Atlas generado con el equipo de Arquitectura; cerrar fechas reales de fases 2-4 y mapear dependencias críticas con el roadmap integrado",
     None, "critical", '["Atlas"]'),

    ("SW5-OI-003", "2026-04-24",
     "Validar supuestos y plan integral con Sergio del Valle antes de presentar a Juan Manuel; él es sponsor clave de roadmap y decisiones de producto junto con Juan Manuel",
     "pablo-lorenzo", "high", '["SmartVista","Apolo"]'),

    ("SW5-OI-004", "2026-04-24",
     "Definir fechas y cronograma de Copel Pay con David Estrada; confirmar si SmartVista onboardeará vía Apolo o frente de promotoría propio; producto encolado sin fechas cerradas",
     None, "high", '["SmartVista"]'),

    ("SW5-OI-005", "2026-04-24",
     "Aclarar estrategia de onboarding N4 con Araceli Barcena (PM Transact): confirmar si utilizará Apolo o back de sucursal legacy para la creación de cuentas en el punto de lanzamiento",
     None, "high", '["Transact","Apolo"]'),

    ("SW5-OI-006", "2026-04-29",
     "Mapeo de capacidades de arquitectura empresarial de Transact con estados intermedios por release (no solo estado final End State); pendiente con Angélica Tolosa para entrega jueves",
     None, "high", '["Transact"]'),

    ("SW5-OI-007", "2026-04-29",
     "Documentar dependencias críticas entre Transact y legado (Western Union, recargas, banca empresarial) para despejar incertidumbre técnica que bloquea la construcción del roadmap",
     None, "high", '["Transact"]'),

    ("SW5-OI-008", "2026-04-28",
     "Diseñar integración MDM-SmartVista post-septiembre: definir APIs y conexiones para que el Golden Record en GCP sea consumible por SmartVista, Apolo y otros; September scope = solo carga de datos, no integración",
     None, "critical", '["Atlas","SmartVista"]'),

    ("SW5-OI-009", "2026-04-28",
     "Registrar ID de producto 4900 (Tarjeta Crédito Clásica en SmartVista) ante Banxico antes de la migración; actualmente no declarado, riesgo de observaciones o multas CNBV",
     None, "critical", '["SmartVista"]'),

    ("SW5-OI-010", "2026-04-28",
     "Identificar SPOC (punto de contacto único) para coexistencia del legado en Unity; hoy disperso entre muchas personas; solo Martín Alejandro López (Control Operativo) se ha acercado para banca empresarial",
     "luis-barragan", "high", '["PISA"]'),

    ("SW5-OI-011", "2026-04-28",
     "Involucrar formalmente al área de Negocio en el comité de definición del Golden Record de Atlas; Negocio debe proporcionar reglas de matching y definiciones; actualmente evade responsabilidad",
     "juan-manuel", "critical", '["Atlas"]'),

    ("SW5-OI-012", "2026-04-28",
     "Cerrar cronograma de migración de SmartVista con fechas reales acordadas con IWI; actualmente sin fechas confirmadas y aislado de la metodología de Transact",
     None, "high", '["SmartVista"]'),

    ("SW5-OI-013", "2026-04-28",
     "Desarrollar metodología de migración de Transact (hoy en etapas muy iniciales con fechas aspiracionales); usar SmartVista/IWI como modelo base y habilitador",
     None, "high", '["Transact"]'),

    ("SW5-OI-014", "2026-04-20",
     "Formalizar roster del programa Unity: roles, responsabilidades, dedicación full-time vs parcial y alineación al modelo operativo objetivo; el roster actual es incompleto como herramienta de gestión",
     "pablo-lorenzo", "high", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-015", "2026-03-27",
     "Asegurar transferencia de conocimiento de Lenin Mesa (arquitecto clave de Apolo) antes de su salida el 30 de abril; es consultor con conocimiento histórico crítico en proceso de transición",
     None, "critical", '["Apolo"]'),

    ("SW5-OI-016", "2026-03-31",
     "Sesión de convergencia entre plan de gestión del cambio ACN (Karina) y firma Kreios (Leticia) para identificar coincidencias, diferencias y coordinar tareas en paralelo sin traslapes",
     "karina-zepeda", "high", '["SmartVista","Apolo","Transact"]'),

    ("SW5-OI-017", "2026-04-29",
     "Preparar versión estabilizada del roadmap integrado con riesgos e hipótesis documentadas para presentar a Juan Manuel la siguiente semana; incluir diapositivas que justifiquen las decisiones de timing",
     "pablo-lorenzo", "high", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-018", "2026-04-28",
     "Definir número y configuración de ambientes requeridos para pruebas: SIT (1-2 ambientes), UAT (1-2 ambientes), NFT-performance+seguridad (preproductivo separado) y migración (ambiente propio)",
     None, "high", '["SmartVista","Apolo","Transact"]'),

    ("SW5-OI-019", "2026-03-27",
     "Definir estrategia de transición de capa de exposición APG/APIL actual a MuleSoft; contrato actual vigente hasta 2028 sin renovación; transición debe incorporarse explícitamente al roadmap y caso de negocio",
     "arcadio", "medium", '["MuleSoft"]'),

    ("SW5-OI-020", "2026-03-27",
     "Compartir documentación de arquitectura de Temenos/Transact y SmartVista/BPC al equipo ACN; documentación actual es parcial e insuficiente; si no existe, declarar ausencia como hallazgo",
     "arturo-perez", "high", '["Transact","SmartVista"]'),
]


def run():
    db = sqlite3.connect(str(DB))
    db.execute("PRAGMA foreign_keys=ON")
    n_dec = n_pos = n_oi = 0
    for row in DECISIONS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO decisions "
                "(id,date,topic,decision,driver_id,systems,doc_id,confidence) "
                "VALUES (?,?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[3], row[4], f'["{row[2]}"]', row[5]),
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception:
            pass
    for row in POSITIONS:
        try:
            db.execute(
                "INSERT INTO positions "
                "(stakeholder_id,topic,stance,quote,date,doc_id,sentiment) "
                "VALUES (?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[2][:100], row[4], row[3]),
            )
            n_pos += 1
        except Exception:
            pass
    for row in OPEN_ITEMS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO open_items "
                "(id,date,item,owner_id,priority,systems,doc_id,status) "
                "VALUES (?,?,?,?,?,?,NULL,'open')",
                (row[0], row[1], row[2], row[3], row[4], row[5]),
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_oi += 1
        except Exception:
            pass
    db.commit()
    print(f"Swarm G5: {n_dec} decisiones · {n_pos} posiciones · {n_oi} open items insertados")
    db.close()


if __name__ == "__main__":
    run()