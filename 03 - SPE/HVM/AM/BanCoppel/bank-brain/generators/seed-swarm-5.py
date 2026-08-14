"""seed-swarm-5.py â€” Grupo 5 swarm extracciÃ³n estratÃ©gica Bank Brain BanCoppel

Fuentes procesadas (marzo-abril 2026):
  - 27 Mar: SesiÃ³n introductoria de diagnÃ³stico con Arquitectura BCP
  - 31 Mar: Kreios/Alondra (Change Mgmt) + Tere GonzÃ¡lez (follow-up arquitectura)
  - 15-16 Abr: Impacto MigraciÃ³n y ATLAS en Plan E2E
  - 20 Abr: Roster + PlaneaciÃ³n prÃ³ximas 3 semanas (interna ACN)
  - 24 Abr: RevisiÃ³n roadmap SmartVista (R3/R4 strategy)
  - 28 Abr: AlineaciÃ³n Christian Zazueta - ACN (Atlas, Golden Record, TCC ID4900)
  - 29 Abr: AlineaciÃ³n semanal Transact (dependencias legado, arquitectura)
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"

# (id, date, topic, decision_text, driver_id_or_None, confidence)
DECISIONS = [
    # --- DiagnÃ³stico y gobierno del programa ---
    ("SW5-DEC-001", "2026-03-27", "DiagnÃ³stico-Alcance",
     "DiagnÃ³stico Accenture definido como 6 semanas de assessment sin ejecuciÃ³n de remediaciÃ³n; semanas 7+ para recomendaciones y posible fase activa de acompaÃ±amiento",
     "juan-manuel", 0.95),

    ("SW5-DEC-002", "2026-03-27", "Arquitectura-Prioridad",
     "Arquitectura declarada como el frente prioritario del diagnÃ³stico tecnolÃ³gico de Unity por encima de todos los demÃ¡s ejes",
     "lukasz-pietrzyk", 0.92),

    ("SW5-DEC-003", "2026-03-27", "Assessment-Enfoque",
     "Enfoque del assessment: hechos, evidencia y entrevistas; ausencia de documentaciÃ³n es hallazgo en sÃ­ mismo que se cubre con sesiones de reconstrucciÃ³n",
     "lukasz-pietrzyk", 0.90),

    ("SW5-DEC-004", "2026-03-27", "MuleSoft-Objetivo",
     "MuleSoft declarado como capa de exposiciÃ³n e integraciÃ³n empresarial objetivo por estrategia corporativa de arquitectura; Unity no estÃ¡ alineado todavÃ­a a esa direcciÃ³n",
     "arcadio", 0.85),

    ("SW5-DEC-005", "2026-03-27", "API-TransiciÃ³n",
     "Contrato de capa de exposiciÃ³n actual (APG/APIL) vigente hasta 2028 sin intenciÃ³n de renovaciÃ³n; la transiciÃ³n a MuleSoft debe planificarse explÃ­citamente en el roadmap y caso de negocio",
     None, 0.88),

    ("SW5-DEC-006", "2026-03-31", "Change-Mgmt-Complementario",
     "GestiÃ³n del cambio: enfoque factual, complementario y no disruptivo entre equipo ACN (Karina) y firma Kreios (Leticia); evitar traslapes y coordinar actividades en paralelo",
     "pablo-lorenzo", 0.85),

    # --- Plan E2E y metodologÃ­a ---
    ("SW5-DEC-007", "2026-04-15", "Plan-E2E-Urgente",
     "Plan integral E2E con cronograma requerido urgentemente para presentaciÃ³n al consejo de accionistas el 24 de abril; planes existentes demasiado fragmentados por stream",
     "juan-manuel", 0.95),

    ("SW5-DEC-008", "2026-04-16", "MigraciÃ³n-UAT-Gate",
     "No proceder con migraciÃ³n a producciÃ³n hasta que UAT estÃ© completamente terminado; gate explÃ­cito y no negociable",
     None, 0.95),

    ("SW5-DEC-009", "2026-04-16", "Dry-Runs-ETL",
     "Incorporar dry runs/mock runs de ETL integral previos a UAT para iterar y estabilizar la migraciÃ³n antes de pruebas de aceptaciÃ³n; paso que no existÃ­a en el proceso actual",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-010", "2026-04-16", "Dress-Rehearsal",
     "Incorporar 2-3 simulacros de producciÃ³n (Dress Rehearsals) antes del go-live para afinar el runbook en ambiente pre-productivo; involucra negocio, operaciones, IT y QA",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-011", "2026-04-20", "Advisory-Assurance",
     "Accenture asume rol dual Advisory y Assurance; el programa requiere significativamente mÃ¡s Advisory que Assurance en las dimensiones tÃ©cnicas crÃ­ticas: testing, integraciÃ³n, DRP, Transition-to-Run",
     "pablo-lorenzo", 0.92),

    ("SW5-DEC-012", "2026-04-20", "Gobernanza-Condicionada",
     "Gobernanza de Accenture condicionada a compromiso de BCP de cerrar brechas fundacionales; no es viable asumir gobierno sin que el cliente cierre los mÃ­nimos fundacionales identificados",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-013", "2026-04-20", "Roster-RediseÃ±o",
     "Roster del programa Unity debe ser rediseÃ±ado y formalizado alineado al modelo operativo objetivo y a la estructura de gobierno; el roster actual no refleja roles, dedicaciÃ³n ni accountability reales",
     None, 0.82),

    ("SW5-DEC-014", "2026-04-24", "Testing-Transversal",
     "MetodologÃ­a de pruebas transversal adoptada: SIT 3 meses + UAT 3 meses con ciclos mensuales y testing no funcional (performance + seguridad) en paralelo; aplicar a partir de R4",
     "pablo-lorenzo", 0.90),

    ("SW5-DEC-015", "2026-04-24", "SmartVista-R3",
     "R3 SmartVista se libera de forma independiente y separada segÃºn compromisos previos con el negocio; agrupaciÃ³n con R4 rechazada porque el negocio no aceptarÃ¡ mÃ¡s retrasos",
     None, 0.92),

    ("SW5-DEC-016", "2026-04-24", "SmartVista-R4",
     "R4 SmartVista adopta nueva estrategia de pruebas integrales exhaustivas; liberaciÃ³n estimada pasa a inicios de febrero (originalmente diciembre) por extensiÃ³n del ciclo de testing",
     "pablo-lorenzo", 0.88),

    ("SW5-DEC-017", "2026-04-24", "Roadmap-Decisores",
     "Sergio del Valle y Juan Manuel son los decisores finales de roadmap y producto SmartVista; plan debe validarse con Sergio del Valle antes de comunicar a Juan Manuel",
     None, 0.90),

    ("SW5-DEC-018", "2026-04-24", "IntegraciÃ³n-En-Desarrollo",
     "IntegraciÃ³n debe tratarse como parte integral de la fase de desarrollo (AnÃ¡lisis-DiseÃ±o-ImplementaciÃ³n), no como fase separada posterior al desarrollo; decisiÃ³n metodolÃ³gica para R4 en adelante",
     "lukasz-pietrzyk", 0.85),

    # --- Atlas, Golden Record, MigraciÃ³n ---
    ("SW5-DEC-019", "2026-04-16", "Atlas-Estructura",
     "Atlas estructurado en 4 fases Crawl-Walk-Run-Fly de 6 meses cada una, horizonte 2 aÃ±os; Fase 3 incluye migraciÃ³n de clientes desde PISA y visiÃ³n 360 de mÃ¡s de 25 millones de clientes",
     None, 0.95),

    ("SW5-DEC-020", "2026-04-16", "Atlas-Fase1",
     "Atlas Fase 1 (Crawl): infraestructura GCP, MDM v1, reglas de matching, pipelines y golden record bÃ¡sico de clientes para BanCoppel; objetivo agosto 2026",
     None, 0.92),

    ("SW5-DEC-021", "2026-04-28", "Atlas-Fase2-Dependencia-CrÃ­tica",
     "Atlas Fase 2: MDM/Golden Record en producciÃ³n a fines de septiembre 2026; dependencia crÃ­tica que debe cumplirse antes de la migraciÃ³n de Tarjeta de CrÃ©dito ClÃ¡sica en SmartVista planificada para diciembre 2026",
     None, 0.93),

    ("SW5-DEC-022", "2026-04-28", "TCC-ID4900",
     "Proceder con migraciÃ³n de Tarjeta de CrÃ©dito ClÃ¡sica al ID 4900 en SmartVista aceptando riesgo regulatorio de no-declaraciÃ³n ante Banxico; esfuerzo adicional no mapeado en reportes actuales",
     None, 0.85),

    ("SW5-DEC-023", "2026-04-28", "MigraciÃ³n-Transversal",
     "Equipo de migraciÃ³n debe ser transversal al portafolio Unity con ambiente propio para ejecutar mock runs y MOs estabilizadores en ambiente integrado; actualmente en fase de fortalecimiento de capacidad",
     None, 0.82),

    ("SW5-DEC-024", "2026-04-28", "MetodologÃ­a-MigraciÃ³n-Transact",
     "MetodologÃ­a de migraciÃ³n SmartVista/IWI (Tarjeta de CrÃ©dito ClÃ¡sica) usada como habilitador y modelo de continuidad para la migraciÃ³n de Transact (minorista); Transact en etapas muy iniciales",
     None, 0.82),
]

# (stakeholder_id, topic, stance_text, sentiment, date)
POSITIONS = [
    ("pablo-lorenzo", "Testing-Transversal",
     "El programa necesita SIT 3m + UAT 3m + dress rehearsals; el enfoque actual produce fases planificadas de 4 semanas que se extienden a 4 meses por deficiencias estructurales",
     "concerned", "2026-04-28"),

    ("juan-manuel", "Plan-E2E",
     "Se requiere urgentemente un plan integral E2E con cronograma para el consejo; los planes existentes estÃ¡n demasiado fragmentados por stream y carecen de una capa de integraciÃ³n que los unifique",
     "urgent", "2026-04-15"),

    ("lukasz-pietrzyk", "Golden-Record-Latencia",
     "Existe preocupaciÃ³n real por la latencia entre consumidores en AWS y on-prem con el Golden Record alojado en GCP; el diseÃ±o de integraciÃ³n actual no contempla ese diferencial de red",
     "concerned", "2026-04-28"),

    ("lukasz-pietrzyk", "DocumentaciÃ³n-Arquitectura",
     "La documentaciÃ³n disponible de arquitectura es parcial e insuficiente; el conocimiento quedÃ³ tÃ¡cito y disperso porque el equipo operativo ejecutÃ³ mÃ¡s que documentar",
     "concerned", "2026-03-27"),

    ("lukasz-pietrzyk", "Arquitectura-Reactiva",
     "La arquitectura hoy reacciona en lugar de guiar; el Design Authority llega tarde y no influye realmente en las decisiones; los NFRs de seguridad, performance y picos no estÃ¡n bien definidos",
     "concerned", "2026-03-27"),

    ("arturo-perez", "DocumentaciÃ³n-HistÃ³rica",
     "Muchas estrategias se definieron al inicio del proyecto; el equipo operativo ejecutÃ³ mÃ¡s que documentar y la arquitectura evolucionÃ³ sobre la marcha; hay lineamientos vigentes pero no documento maestro",
     "neutral", "2026-03-27"),

    ("arcadio", "ParticipaciÃ³n-Arquitectura",
     "SolicitÃ³ ser incluido en TODAS las invitaciones de sesiones de arquitectura y propone incluir tambiÃ©n a Mercedes; manifestÃ³ interÃ©s en participar activamente y buscar espacio en agenda",
     "positive", "2026-03-31"),

    ("arcadio", "MuleSoft-TransiciÃ³n",
     "La estrategia corporativa de arquitectura apunta a MuleSoft pero Unity no estÃ¡ alineado todavÃ­a; el contrato actual vigente hasta 2028 requiere planificar una transiciÃ³n explÃ­cita en el roadmap",
     "concerned", "2026-03-27"),

    ("rodrigo", "Change-Mgmt-AlineaciÃ³n",
     "Ambos equipos de gestiÃ³n del cambio deben converger; es indispensable coordinar para evitar traslapes y choques de actividades; enfoque debe ser factual y complementario, no confrontacional",
     "neutral", "2026-03-31"),

    ("rodrigo", "Unity-Caso-Piloto",
     "Existe la oportunidad de usar Unity como caso piloto para fortalecer capacidades de banking en MÃ©xico dentro de Accenture; visiÃ³n estratÃ©gica de largo plazo mÃ¡s allÃ¡ del contrato actual",
     "positive", "2026-04-20"),

    ("pablo-lorenzo", "Negocio-Golden-Record",
     "El Ã¡rea de Negocio estÃ¡ evadiendo su responsabilidad en la definiciÃ³n del Golden Record de Atlas; esto es riesgo crÃ­tico porque Negocio debe definir reglas de matching y proporcionar definiciones clave",
     "concerned", "2026-04-28"),

    ("pablo-lorenzo", "Legado-Caja-Gris",
     "El legado es una caja gris que bloquea la construcciÃ³n del roadmap integrado; no hay una persona unificada con conocimiento de fechas, desarrollos y dependencias del sistema legacy",
     "concerned", "2026-04-29"),

    ("pablo-lorenzo", "Gobernanza-Con-MÃ­nimos",
     "Accenture no puede prometer ejecuciones que no pueda cumplir en capacidad o perfiles; el takeover del programa debe ir acompaÃ±ado de remediaciÃ³n real de brechas fundacionales, no solo governance formal",
     "cautious", "2026-04-20"),

    ("pablo-lorenzo", "North-Star-Ausente",
     "No existe un North Star de negocio claro traducido en journeys end-to-end, funcionalidades y prioridades cross-producto; las decisiones se toman por plataforma y silo sin lÃ³gica integrada de negocio",
     "concerned", "2026-04-20"),

    ("lukasz-pietrzyk", "R3-R4-AgrupaciÃ³n",
     "La propuesta de agrupar R3 y R4 tiene sentido conceptualmente pero el negocio la rechazarÃ¡ porque ya hubo retrasos previos y Sergio del Valle necesita ver R3 liberado segÃºn lo comprometido",
     "neutral", "2026-04-24"),

    ("karina-zepeda", "Assessment-Estado",
     "El equipo de change management estÃ¡ en fase de entrevistas y acercamiento inicial; aÃºn no hay entregable formal porque se estÃ¡ construyendo el diagnÃ³stico base; requiere coordinaciÃ³n con Kreios",
     "neutral", "2026-03-31"),

    ("pablo-lorenzo", "MetodologÃ­a-MigraciÃ³n-Brecha",
     "Las metodologÃ­as de migraciÃ³n de SmartVista y Transact estÃ¡n completamente aisladas; Transact en etapas muy iniciales con fechas aspiracionales; brecha significativa que debe cerrarse",
     "concerned", "2026-04-28"),

    ("arturo-perez", "CertificaciÃ³n-Arquitectura",
     "El proceso de certificaciÃ³n de arquitectura de 9 capas existe y genera backlog tÃ©cnico real con observaciones concretas; es una fuente Ãºtil de estado actual aunque no sustituye el documento maestro",
     "neutral", "2026-03-27"),
]

# (id, date, item_text, owner_id_or_None, priority, systems_json)
OPEN_ITEMS = [
    ("SW5-OI-001", "2026-04-15",
     "Plan integral E2E con cronograma para presentaciÃ³n al consejo de accionistas del 24 de abril; integrar Transact, Apolo, SmartVista, Atlas y Legacy en una sola vista temporal con dependencias",
     "pablo-lorenzo", "critical", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-002", "2026-04-16",
     "Plan detallado del Proyecto Atlas generado con el equipo de Arquitectura; cerrar fechas reales de fases 2-4 y mapear dependencias crÃ­ticas con el roadmap integrado",
     None, "critical", '["Atlas"]'),

    ("SW5-OI-003", "2026-04-24",
     "Validar supuestos y plan integral con Sergio del Valle antes de presentar a Juan Manuel; Ã©l es sponsor clave de roadmap y decisiones de producto junto con Juan Manuel",
     "pablo-lorenzo", "high", '["SmartVista","Apolo"]'),

    ("SW5-OI-004", "2026-04-24",
     "Definir fechas y cronograma de Copel Pay con David Estrada; confirmar si SmartVista onboardearÃ¡ vÃ­a Apolo o frente de promotorÃ­a propio; producto encolado sin fechas cerradas",
     None, "high", '["SmartVista"]'),

    ("SW5-OI-005", "2026-04-24",
     "Aclarar estrategia de onboarding N4 con Araceli Barcena (PM Transact): confirmar si utilizarÃ¡ Apolo o back de sucursal legacy para la creaciÃ³n de cuentas en el punto de lanzamiento",
     None, "high", '["Transact","Apolo"]'),

    ("SW5-OI-006", "2026-04-29",
     "Mapeo de capacidades de arquitectura empresarial de Transact con estados intermedios por release (no solo estado final End State); pendiente con AngÃ©lica Tolosa para entrega jueves",
     None, "high", '["Transact"]'),

    ("SW5-OI-007", "2026-04-29",
     "Documentar dependencias crÃ­ticas entre Transact y legado (Western Union, recargas, banca empresarial) para despejar incertidumbre tÃ©cnica que bloquea la construcciÃ³n del roadmap",
     None, "high", '["Transact"]'),

    ("SW5-OI-008", "2026-04-28",
     "DiseÃ±ar integraciÃ³n MDM-SmartVista post-septiembre: definir APIs y conexiones para que el Golden Record en GCP sea consumible por SmartVista, Apolo y otros; September scope = solo carga de datos, no integraciÃ³n",
     None, "critical", '["Atlas","SmartVista"]'),

    ("SW5-OI-009", "2026-04-28",
     "Registrar ID de producto 4900 (Tarjeta CrÃ©dito ClÃ¡sica en SmartVista) ante Banxico antes de la migraciÃ³n; actualmente no declarado, riesgo de observaciones o multas CNBV",
     None, "critical", '["SmartVista"]'),

    ("SW5-OI-010", "2026-04-28",
     "Identificar SPOC (punto de contacto Ãºnico) para coexistencia del legado en Unity; hoy disperso entre muchas personas; solo MartÃ­n Alejandro LÃ³pez (Control Operativo) se ha acercado para banca empresarial",
     "luis-barragan", "high", '["PISA"]'),

    ("SW5-OI-011", "2026-04-28",
     "Involucrar formalmente al Ã¡rea de Negocio en el comitÃ© de definiciÃ³n del Golden Record de Atlas; Negocio debe proporcionar reglas de matching y definiciones; actualmente evade responsabilidad",
     "juan-manuel", "critical", '["Atlas"]'),

    ("SW5-OI-012", "2026-04-28",
     "Cerrar cronograma de migraciÃ³n de SmartVista con fechas reales acordadas con IWI; actualmente sin fechas confirmadas y aislado de la metodologÃ­a de Transact",
     None, "high", '["SmartVista"]'),

    ("SW5-OI-013", "2026-04-28",
     "Desarrollar metodologÃ­a de migraciÃ³n de Transact (hoy en etapas muy iniciales con fechas aspiracionales); usar SmartVista/IWI como modelo base y habilitador",
     None, "high", '["Transact"]'),

    ("SW5-OI-014", "2026-04-20",
     "Formalizar roster del programa Unity: roles, responsabilidades, dedicaciÃ³n full-time vs parcial y alineaciÃ³n al modelo operativo objetivo; el roster actual es incompleto como herramienta de gestiÃ³n",
     "pablo-lorenzo", "high", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-015", "2026-03-27",
     "Asegurar transferencia de conocimiento de Lenin Mesa (arquitecto clave de Apolo) antes de su salida el 30 de abril; es consultor con conocimiento histÃ³rico crÃ­tico en proceso de transiciÃ³n",
     None, "critical", '["Apolo"]'),

    ("SW5-OI-016", "2026-03-31",
     "SesiÃ³n de convergencia entre plan de gestiÃ³n del cambio ACN (Karina) y firma Kreios (Leticia) para identificar coincidencias, diferencias y coordinar tareas en paralelo sin traslapes",
     "karina-zepeda", "high", '["SmartVista","Apolo","Transact"]'),

    ("SW5-OI-017", "2026-04-29",
     "Preparar versiÃ³n estabilizada del roadmap integrado con riesgos e hipÃ³tesis documentadas para presentar a Juan Manuel la siguiente semana; incluir diapositivas que justifiquen las decisiones de timing",
     "pablo-lorenzo", "high", '["SmartVista","Apolo","Transact","Atlas"]'),

    ("SW5-OI-018", "2026-04-28",
     "Definir nÃºmero y configuraciÃ³n de ambientes requeridos para pruebas: SIT (1-2 ambientes), UAT (1-2 ambientes), NFT-performance+seguridad (preproductivo separado) y migraciÃ³n (ambiente propio)",
     None, "high", '["SmartVista","Apolo","Transact"]'),

    ("SW5-OI-019", "2026-03-27",
     "Definir estrategia de transiciÃ³n de capa de exposiciÃ³n APG/APIL actual a MuleSoft; contrato actual vigente hasta 2028 sin renovaciÃ³n; transiciÃ³n debe incorporarse explÃ­citamente al roadmap y caso de negocio",
     "arcadio", "medium", '["MuleSoft"]'),

    ("SW5-OI-020", "2026-03-27",
     "Compartir documentaciÃ³n de arquitectura de Temenos/Transact y SmartVista/BPC al equipo ACN; documentaciÃ³n actual es parcial e insuficiente; si no existe, declarar ausencia como hallazgo",
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
    print(f"Swarm G5: {n_dec} decisiones Â· {n_pos} posiciones Â· {n_oi} open items insertados")
    db.close()


if __name__ == "__main__":
    run()