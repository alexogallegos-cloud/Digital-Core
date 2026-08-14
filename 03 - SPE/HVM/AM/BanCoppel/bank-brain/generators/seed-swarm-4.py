"""seed-swarm-4.py â€” Grupo 4 swarm extraccion estrategica Bank Brain BanCoppel

Fuentes: minutas de marzo-abril 2026
  - 19.Mar.26 Juan Manuel Fernandez (manana + tarde)
  - 23.Mar.26 Tere Gonzalez
  - 26.Mar.26 Jose Jaimes / Maria Mercedes / Alondra Cardenas
  - 28.Abr.26 Atlas-Migracion-Deployment + Alineacion Arquitectura UNITY
  - 30.Mar.26 Arcadio Delgado (EY)
  - 9.Abr.26 Gobierno: Estructura y Direccion
  - 15.Abr.26 Migracion follow-up / Business Case Captacion / Legado Dependencias
"""
import sqlite3
from pathlib import Path

DB = Path(__file__).parent.parent / "digital-brain" / "bank-brain.db"

# (id, date, topic, decision_text, driver_id_or_None, confidence)
DECISIONS = [
    # --- 19 Marzo: Juan Manuel establece el mapa de roles entre proveedores ---
    (
        "SW4-DEC-001",
        "2026-03-19",
        "gobierno",
        "Accenture lidera el plan director de interoperabilidad y arquitectura del programa; EY lleva el core bancario (Temenos/Transact). La integracion y el programa completo son responsabilidad de ACN.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-002",
        "2026-03-19",
        "cronograma",
        "El deadline para presentar el plan director al consejo de administracion es inamovible: 24 de abril de 2026. Juan Manuel quiere certeza y narrativa, no conversacion de dinero.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-003",
        "2026-03-19",
        "alcance",
        "No se moveran los requerimientos del programa. El programa debe salir en las fechas acordadas con lo que exista desarrollado; no se abriran nuevos frentes que dilaten la entrega.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-004",
        "2026-03-19",
        "pisa",
        "El problema de PISA no es la capacidad del sistema sino su arquitectura y codificacion. Implicacion implicita: el legacy puede seguir operando en paralelo durante la transicion a Unity.",
        "juan-manuel",
        "medium",
    ),
    (
        "SW4-DEC-005",
        "2026-03-19",
        "gobierno",
        "Pablo Medinaveitia designado como nuevo Director de Transformacion de Unity, con incorporacion el 6 de abril de 2026. Reemplaza al director colombiano anterior que abandono el proyecto.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-006",
        "2026-03-19",
        "gobierno",
        "Accenture absorbe tres roles simultaneos en Unity: plan director integral, AMS/IMS, y takeover formal de la aplicacion. La logica es que el mismo proveedor en delivery y AMS garantiza continuidad sin cobro adicional.",
        "juan-manuel",
        "high",
    ),
    # --- 23 Marzo: Business case y gobierno ---
    (
        "SW4-DEC-007",
        "2026-03-23",
        "business-case",
        "No existe un business case integral para Unity como programa. Se decide construir la logica de negocio producto por producto: tarjeta de credito, captacion y prestamo personal son los tres criticos para los proximos tres anos.",
        None,
        "high",
    ),
    (
        "SW4-DEC-008",
        "2026-03-23",
        "cronograma",
        "Los compromisos ante el consejo del 24 de abril se limitaran al ano en curso. Los anos 2027 en adelante se dejan sujetos a validacion posterior para no repetir el error historico de comprometer sin sustento.",
        None,
        "medium",
    ),
    (
        "SW4-DEC-009",
        "2026-03-23",
        "gobierno",
        "Tere Gonzalez asume como unico punto de contacto integral para el equipo externo mientras se mapean los responsables reales del programa. Cubre negocio y tecnologia, no solo negocio.",
        None,
        "high",
    ),
    # --- 26 Marzo: Arquitectura y SmartVista ---
    (
        "SW4-DEC-010",
        "2026-03-26",
        "arquitectura",
        "La validacion de arquitectura de TI que realiza ACN sera a nivel funcional y de requerimientos (cobertura de capacidades), no al detalle tecnico minimo. El objetivo es alinear capacidades de negocio con tecnologia.",
        "lukasz-pietrzyk",
        "high",
    ),
    (
        "SW4-DEC-011",
        "2026-03-26",
        "arquitectura",
        "Se incorpora la figura de arquitecto de soluciÃ³n en las celulas de desarrollo de Unity (tres arquitectos internos identificados inicialmente) para asegurar cumplimiento de estandares desde la fase de diseno.",
        "arcadio",
        "high",
    ),
    (
        "SW4-DEC-012",
        "2026-03-26",
        "deuda-tecnica",
        "La resolucion de los 135 hallazgos de arquitectura (levantados en julio 2025: cifrado, obsolescencia, CNBV) queda subordinada a las prioridades de release. Los equipos no los han incorporado a sus backlogs formalmente.",
        None,
        "high",
    ),
    (
        "SW4-DEC-013",
        "2026-03-26",
        "smartvista",
        "SmartVista tiene una brecha: no todos los modulos estan contratados. El modulo autorizador esta en proceso de verificacion. Primera version del analisis esperada a mediados de mayo 2026.",
        None,
        "high",
    ),
    # --- 30 Marzo: Arcadio Delgado / Transact arquitectura ---
    (
        "SW4-DEC-014",
        "2026-03-30",
        "transact",
        "Los lineamientos arquitectonicos de Transact Empresas son entre un 70 y 80 porciento reutilizables para banca minorista. No se anticipa un cambio mayor en los lineamientos base; la validacion detallada queda pendiente.",
        "arcadio",
        "medium",
    ),
    (
        "SW4-DEC-015",
        "2026-03-30",
        "atlas",
        "El MDM (proyecto Atlas) aplica exclusivamente al golden record de clientes. La migracion de productos y cuentas es un frente independiente que no desaparece por la sola existencia del MDM.",
        "arcadio",
        "high",
    ),
    (
        "SW4-DEC-016",
        "2026-03-30",
        "arquitectura",
        "Arcadio inicia analisis arquitectonico comparativo entre el diseno original de Unity y la construccion real por stream. Orden: SmartVista primero; Transact no antes de julio de 2026 por capacidad limitada (equipo de seis personas).",
        "arcadio",
        "high",
    ),
    (
        "SW4-DEC-017",
        "2026-03-30",
        "integracion",
        "MuleSoft se confirma como integrador principal para Transact minorista, siguiendo los mismos lineamientos de arquitectura establecidos para Transact Empresas.",
        "arcadio",
        "medium",
    ),
    # --- 9 Abril: Gobierno y diagnostico del programa ---
    (
        "SW4-DEC-018",
        "2026-04-09",
        "cronograma",
        "El objetivo open market en diciembre de 2026 se mantiene como mandato ejecutivo aunque su factibilidad tecnica no esta validada de forma robusta. Existe un alto componente de acto de fe en que la parte tecnica estara en orden.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-019",
        "2026-04-09",
        "gobierno",
        "Daniel Angeles Baltazar queda limitado a un subtrack de infraestructura, ambientes e IMS. No lidera ni participa en conversaciones de estrategia, interoperabilidad o arquitectura futura del banco.",
        "juan-manuel",
        "high",
    ),
    (
        "SW4-DEC-020",
        "2026-04-09",
        "gobierno",
        "El equipo de Estrategia (Rodrigo / Tere) adopta posicion neutral entre negocio y tecnologia para proteger el proyecto, no personas. El diagnostico estructural y la operacion diaria son roles deliberadamente separados.",
        "rodrigo",
        "high",
    ),
    (
        "SW4-DEC-021",
        "2026-04-09",
        "gobierno",
        "Unity ha operado mas de dos anos y medio sin una capa integradora del programa ni en el plano tecnico ni en el de management. El diagnostico concluye que se gestiona como suma de proyectos individuales, no como transformacion integral.",
        None,
        "high",
    ),
    # --- 15 Abril: Migracion, Business Case, Legado ---
    (
        "SW4-DEC-022",
        "2026-04-15",
        "business-case",
        "El business case de captacion se ajusta en timeline, no en cuantificacion de valor. El retraso en el roadmap de Unity implica recalcular el impacto temporal de beneficios sin modificar la logica de saldos proyectados.",
        None,
        "medium",
    ),
    (
        "SW4-DEC-023",
        "2026-04-15",
        "alcance",
        "Ninguna iniciativa nueva de captacion sera desarrollada en el core legacy (PISA). Las iniciativas de fases 2 y 3 de la estrategia 2030 (nuevos productos, segmentos C y C+) dependen completamente de Unity.",
        None,
        "high",
    ),
    (
        "SW4-DEC-024",
        "2026-04-15",
        "atlas",
        "El cronograma de Atlas se reajusta: inicio real en abril 2026. Fase 1 (crawl) cierra en agosto 2026. El plan original no se cumplio. Las fechas definitivas de Fase 2 estan aun en construccion.",
        None,
        "high",
    ),
    (
        "SW4-DEC-025",
        "2026-04-15",
        "migracion",
        "El plan integrado de Unity se define como version inicial iterativa, no como garantia de ejecucion. El equipo de legado no puede completar inputs en 24 horas; se acuerda replantear la estrategia de colaboracion.",
        "pablo-lorenzo",
        "medium",
    ),
]

# (stakeholder_id, topic, stance_text, sentiment, date)
POSITIONS = [
    (
        "juan-manuel",
        "operacion-post-produccion",
        "Apolo y Tarjeta ya estan en produccion real pero el soporte esta roto porque nadie los trata como servicios productivos formales. Exige flujo minimo: N1/N2/N3, mesa de control, observabilidad y takeover formal.",
        "negative",
        "2026-03-19",
    ),
    (
        "juan-manuel",
        "pisa",
        "El problema de PISA no es la maquina sino que esta mal utilizado, mal tuneado, mal codificado y sin arquitectura. Implication: el sistema legacy tiene capacidad no aprovechada y no debe ser el chivo expiatorio del retraso.",
        "critical",
        "2026-03-19",
    ),
    (
        "juan-manuel",
        "resultados-vs-presentaciones",
        "Quiere resultados, no presentaciones bonitas. El hito del 24 de abril es para llevar certeza y narrativa al consejo, no una conversacion de dinero.",
        "pragmatic",
        "2026-03-19",
    ),
    (
        "juan-manuel",
        "daniel-angeles",
        "No ve a Daniel Angeles como el perfil correcto para liderar la estrategia del programa. Lo circunscribe a infraestructura, ambientes e IMS. Postura implicita de desconfianza en su capacidad estrategica.",
        "negative",
        "2026-03-19",
    ),
    (
        "juan-manuel",
        "gobierno-programa",
        "Demasiadas decisiones han descansado en una sola perspectiva. Reconoce que la complejidad del esfuerzo exige mas que una sola cabeza operando con informacion fragmentada, aunque el mismo ha sido ese punto unico.",
        "self-critical",
        "2026-04-09",
    ),
    (
        "arcadio",
        "transact-minorista",
        "La arquitectura de Transact minorista no esta cerrada completamente. Hay definiciones pendientes a nivel de requerimientos y funcionalidades, no solo a nivel arquitectonico. El negocio pidio muchas cosas y el reto es acomodarlas.",
        "concerned",
        "2026-03-30",
    ),
    (
        "arcadio",
        "atlas-mdm",
        "Los procesos regulatorios, contractuales y administrativos van a impactar el calendario de Atlas mucho mas que lo tecnico. La habilitacion tecnica podria ser rapida, pero la adquisicion y contratos son el cuello de botella.",
        "cautious",
        "2026-03-30",
    ),
    (
        "rodrigo",
        "roles-responsabilidades",
        "El primer gran hallazgo al entrar al programa fue un desastre en roles y responsabilidades. Personas con cargos que no reflejan lo que hacen, responsabilidad operativa dispersa y gobierno fragmentado heredado de esfuerzos anteriores.",
        "critical",
        "2026-03-23",
    ),
    (
        "lukasz-pietrzyk",
        "atlas-latencia",
        "Preocupacion tecnica explicita por la latencia en la integracion del Golden Record con los consumidores, tanto en la nube (AWS) como onprem, dado que el MDM vivira en Google Cloud y SmartVista/Transact en AWS.",
        "concerned",
        "2026-04-28",
    ),
    (
        "pablo-lorenzo",
        "programa-unity",
        "Unity se ha gestionado como suma de proyectos individuales sin capa de integracion, control y gobierno end-to-end. El programa nunca tuvo una funcion integradora real ni tecnica ni de management en mas de dos anos y medio.",
        "critical",
        "2026-04-09",
    ),
    (
        "brenda",
        "contratos-proveedores",
        "Referida como responsable central de la relacion con proveedores de tecnologia de servicios financieros y de temas regulatorios y presupuestarios de Unity. Interlocutora clave para negociaciones de atlas y presupuesto MDM.",
        "neutral",
        "2026-03-19",
    ),
    (
        "erica-mata",
        "compliance-unity",
        "Incluida en reuniones de arquitectura y plan director por su vision sobre temas de compliance ISO y CNBV. Posicion de soporte: valida que los temas regulatorios y de cifrado esten cubiertos en el diseno de Unity.",
        "supportive",
        "2026-03-26",
    ),
    (
        "arturo-perez",
        "responsabilidad-legado",
        "El legado no tiene un responsable unico: esta fragmentado por dominio (canales, PISA, reporting, app). Arturo Perez aparece como responsable de Office y canales, pero la vision integral del legacy no tiene un owner centralizado.",
        "negative",
        "2026-04-15",
    ),
    (
        "luis-barragan",
        "arquitectura-proveedores",
        "Identificado como coordinador natural entre el equipo de arquitectura y los proveedores, pero estuvo ausente en reuniones criticas de marzo por vacaciones. Su disponibilidad tardÃ­a es un riesgo para la definicion arquitectonica.",
        "neutral",
        "2026-03-23",
    ),
    (
        "emmy",
        "apoyo-negocio",
        "Rol de apoyo de negocio asignado al esfuerzo Unity. Participacion en steering como contraparte de negocio de apoyo. Posicion pasiva de soporte sin toma de decisiones estrategicas visible en las minutas.",
        "neutral",
        "2026-04-09",
    ),
    (
        "gabriela-maximiliano",
        "takeover-operacion",
        "Tomo los assets y plantillas para estructurar el pre y post produccion de Apolo. Liderando la construccion del plan de takeover junto con Alfredo Garcia, aunque Juan Manuel expreso molestia por la lentitud del avance.",
        "neutral",
        "2026-03-19",
    ),
    (
        "salomon-monroy",
        "fase-0-arranque",
        "Debe alinearse con Pablo Medinaveitia en la fase 0 y el arranque del plan director. Posicion activa de delivery en etapa inicial del diagnostico.",
        "neutral",
        "2026-03-19",
    ),
]

# (id, date, item_text, owner_id_or_None, priority, systems_json)
OPEN_ITEMS = [
    (
        "SW4-OI-001",
        "2026-03-19",
        "Formalizar plan de takeover y soporte post-produccion para Apolo y Tarjeta: N1/N2/N3, mesa de control, observabilidad, resiliencia e integracion con AMS. Debe reflejarse en el plan director como fechas de salida y handover.",
        "gabriela-maximiliano",
        "high",
        '["Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-002",
        "2026-03-23",
        "Construir el business case integral de Unity como programa (hoy solo existen business cases por producto). La ausencia de un BC integral debilita la narrativa ante el consejo y la priorizaciÃ³n de inversiones.",
        "pablo-lorenzo",
        "critical",
        '["Transact", "Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-003",
        "2026-03-23",
        "Validar el roadmap 2027 en adelante con sustento tecnico antes de comprometer ante el consejo de administracion. No repetir el patron historico de comprometer fechas sin calculo real de esfuerzo.",
        "pablo-lorenzo",
        "critical",
        '["Transact", "Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-004",
        "2026-03-26",
        "Solicitar formalmente por correo electronico el informe de 135 hallazgos de arquitectura (julio 2025: cifrado, obsolescencia, CNBV) a Maria Mercedes Espinosa para iniciar plan de remediacion.",
        "pablo-lorenzo",
        "medium",
        '["Transact", "Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-005",
        "2026-03-26",
        "Resolver urgentemente el reemplazo del arquitecto de solucion Lenin en Apolo (sale el 31 de mayo). Contactar a Miguel Bucio para revisar opciones y garantizar transferencia de conocimiento antes de su salida.",
        "lukasz-pietrzyk",
        "critical",
        '["Apolo"]',
    ),
    (
        "SW4-OI-006",
        "2026-03-26",
        "Verificar inventario completo de modulos de SmartVista contratados por BanCoppel, incluyendo el modulo autorizador. Primera version del analisis esperada a mediados de mayo 2026.",
        None,
        "high",
        '["SmartVista/BPC"]',
    ),
    (
        "SW4-OI-007",
        "2026-03-30",
        "Arcadio Delgado debe entregar el analisis arquitectonico comparativo entre diseno original y construccion real: SmartVista primero (pronto), Transact hasta julio 2026. Coordinar con Alonso para apalancar trabajo ya realizado por ACN.",
        "arcadio",
        "high",
        '["SmartVista/BPC", "Transact"]',
    ),
    (
        "SW4-OI-008",
        "2026-03-30",
        "Definir las arquitecturas de transicion para Transact minorista (8 productos: 4 captacion, 4 colocacion) antes de iniciar desarrollo. Incluye analisis de convivencia con PISA y esquema de integracion con MDM.",
        "arcadio",
        "high",
        '["Transact", "PISA/Informix", "Atlas"]',
    ),
    (
        "SW4-OI-009",
        "2026-03-30",
        "Determinar timeline definitivo del MDM (Atlas) para decidir si Transact minorista se integra al MDM o directamente a PISA en la primera fase. Sin esta fecha, el diseno de integraciones queda en el aire.",
        None,
        "critical",
        '["Atlas", "Transact", "PISA/Informix"]',
    ),
    (
        "SW4-OI-010",
        "2026-04-09",
        "Formalizar estructura de gobierno de Unity con roles adicionales y accountability claro. Hoy existen solo cinco personas en la capa neutral de gobernanza para un programa de 500 a 700 involucrados. Dotacion claramente insuficiente.",
        "pablo-lorenzo",
        "critical",
        '["Transact", "Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-011",
        "2026-04-09",
        "Construir plan maestro integrado con planes detallados por stream (SmartVista, Transact, Apolo, onboarding), con hitos, dependencias y trazabilidad plan maestro - planes detallados. Hoy esta disciplina no existe de forma madura.",
        "pablo-lorenzo",
        "critical",
        '["Transact", "Apolo", "SmartVista/BPC", "Atlas"]',
    ),
    (
        "SW4-OI-012",
        "2026-04-09",
        "Resolver la crisis de talento en Unity: burnout, rotacion, miedo, desgaste y mala asignacion de incentivos. Cambiar el discurso: el problema no son las personas sino la ausencia de estructura, roles claros y modelo operativo.",
        "luis-barragan",
        "high",
        '["Transact", "Apolo", "SmartVista/BPC"]',
    ),
    (
        "SW4-OI-013",
        "2026-04-09",
        "Identificar y asignar un responsable unico del ecosistema legacy (canales, PISA, reporting, app) para coordinar dependencias con Unity. Hoy el legado esta fragmentado entre multiples equipos sin un owner central.",
        "arturo-perez",
        "high",
        '["PISA/Informix"]',
    ),
    (
        "SW4-OI-014",
        "2026-04-15",
        "Recalcular el impacto temporal del business case de captacion ante retrasos en el roadmap de Unity (N4 y funcionalidades de captacion). El ajuste es en timeline, no en cuantificacion; validar sensibilidad de saldos proyectados.",
        None,
        "medium",
        '["Transact", "Apolo"]',
    ),
    (
        "SW4-OI-015",
        "2026-04-15",
        "Completar el plan integrado end-to-end con inputs de Transact, Apolo y SmartVista (fechas por fase, dependencias, riesgos) para la presentacion al board del 24 de abril. El equipo de legado no puede completarlo en 24 horas; requiere sesiones de entendimiento previas.",
        "pablo-lorenzo",
        "critical",
        '["Transact", "Apolo", "SmartVista/BPC", "PISA/Informix"]',
    ),
    (
        "SW4-OI-016",
        "2026-04-15",
        "Disenar y documentar un modelo robusto de migracion con testing integral, rehearsals (simulacros de produccion) y runbooks detallados antes del go-live. Hoy no existe una fase formal de testing integral ni simulacros.",
        None,
        "high",
        '["Atlas", "SmartVista/BPC", "Transact", "PISA/Informix"]',
    ),
    (
        "SW4-OI-017",
        "2026-04-28",
        "Agendar sesion de onboarding de gobierno de API con Gabriel Alejandro Maldonado Hernandez y Anayeli Ortiz para revisar el proceso de validacion, homologacion y reutilizacion de APIs en Unity.",
        "pablo-lorenzo",
        "medium",
        '["Apolo", "MuleSoft"]',
    ),
    (
        "SW4-OI-018",
        "2026-04-15",
        "Robustecer el proceso de migracion de Atlas integrando metodologia de Operational Readiness existente con vision de simulacros de produccion. El marco actual es muy tecnico, aspiracional y parcial.",
        None,
        "high",
        '["Atlas", "SmartVista/BPC", "Transact"]',
    ),
]


def run():
    db = sqlite3.connect(str(DB))
    db.execute("PRAGMA foreign_keys=ON")
    n_dec = n_pos = n_oi = 0

    for row in DECISIONS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO decisions (id,date,topic,decision,driver_id,systems,doc_id,confidence) VALUES (?,?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[3], row[4], f'["{row[2]}"]', row[5]),
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_dec += 1
        except Exception as e:
            print(f"  [WARN decisions] {row[0]}: {e}")

    for row in POSITIONS:
        try:
            db.execute(
                "INSERT INTO positions (stakeholder_id,topic,stance,quote,date,doc_id,sentiment) VALUES (?,?,?,?,?,NULL,?)",
                (row[0], row[1], row[2], row[2][:100], row[4], row[3]),
            )
            n_pos += 1
        except Exception as e:
            print(f"  [WARN positions] {row[0]}/{row[1]}: {e}")

    for row in OPEN_ITEMS:
        try:
            db.execute(
                "INSERT OR IGNORE INTO open_items (id,date,item,owner_id,priority,systems,doc_id,status) VALUES (?,?,?,?,?,?,NULL,'open')",
                (row[0], row[1], row[2], row[3], row[4], row[5]),
            )
            if db.execute("SELECT changes()").fetchone()[0]:
                n_oi += 1
        except Exception as e:
            print(f"  [WARN open_items] {row[0]}: {e}")

    db.commit()
    print(
        f"Swarm G4: {n_dec} decisiones . {n_pos} posiciones . {n_oi} open items insertados"
    )
    db.close()


if __name__ == "__main__":
    run()