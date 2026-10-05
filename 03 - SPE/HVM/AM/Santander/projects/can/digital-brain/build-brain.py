"""
CAN Brain — Santander México
Pipeline de construcción del brain de cumplimiento CAN.

Ejecutar: python build-brain.py
Portal:   python ../generators/build-portal.py
"""

import sqlite3
import os
from datetime import datetime

DB_PATH = os.path.join(os.path.dirname(__file__), "brain.db")

# ---------------------------------------------------------------------------
# Schema
# ---------------------------------------------------------------------------

DDL = """
CREATE TABLE IF NOT EXISTS brain_meta (
    key   TEXT PRIMARY KEY,
    value TEXT
);

CREATE TABLE IF NOT EXISTS microservices (
    id              TEXT PRIMARY KEY,   -- MS-CAN-001 …
    nombre          TEXT,               -- nombre del artifact Maven
    version         TEXT,               -- versión del pom.xml
    java_version    TEXT,
    spring_boot     TEXT,
    rol             TEXT,               -- NEGOCIO | INFRAESTRUCTURA
    descripcion     TEXT,
    responsabilidad TEXT,               -- qué hace en el dominio CAN
    sistemas_llama  TEXT,               -- sistemas externos que invoca
    endpoints_count INTEGER,
    bd              TEXT,               -- base de datos
    etb_capabilities TEXT              -- ETB L2 capabilities que cubre (JSON array)
);

CREATE TABLE IF NOT EXISTS etb_capabilities (
    id              TEXT PRIMARY KEY,   -- ETB-CAN-001 …
    etb_l1          TEXT,               -- Retail Banking | Payments | Digital Channels | Compliance
    etb_l2          TEXT,               -- nombre de la capability L2
    descripcion     TEXT,
    estado_can      TEXT,               -- CUBIERTO | PARCIAL | BRECHA
    microservicios  TEXT,               -- MS-CAN-xxx que la implementan
    obligaciones    TEXT,               -- CAN-OBL-xxx relacionadas
    nota_gap        TEXT
);

CREATE TABLE IF NOT EXISTS obligation_coverage (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    obligation_id   TEXT,
    microservicio_id TEXT,
    cobertura       TEXT,               -- CUBIERTO | PARCIAL | NO_CUBIERTO
    evidencia       TEXT,               -- qué endpoint / clase / campo lo implementa
    gap_detectado   TEXT,               -- qué falta para cumplimiento completo
    FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

CREATE TABLE IF NOT EXISTS cecoban_integration (
    id          TEXT PRIMARY KEY,
    categoria   TEXT,   -- auth | api_rest | kafka | simulador | errores | timeouts
    nombre      TEXT,
    valor       TEXT,
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS can_flows (
    id            TEXT PRIMARY KEY,   -- FLOW-CAN-001 …
    numero        INTEGER,
    nombre        TEXT,
    descripcion   TEXT,
    rol           TEXT,               -- ACREEDORA | DEPOSITARIA | AMBAS
    sla           TEXT,               -- SLA clave del flujo
    pasos         TEXT,               -- JSON array [{code, path, desc}]
    user_stories  TEXT                -- JSON array de US relacionados
);

CREATE TABLE IF NOT EXISTS arch_components (
    id          TEXT PRIMARY KEY,   -- ARCH-XXX
    nombre      TEXT,               -- nombre funcional (oficial por confirmar)
    tipo        TEXT,               -- canal | onefinancial | gateway | core | externo
    capa        TEXT,               -- misma que tipo (banda vertical)
    pos_x       INTEGER,            -- anclaje horizontal 0-1200 para el layout
    descripcion TEXT
);

CREATE TABLE IF NOT EXISTS arch_integrations (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    origen      TEXT,               -- id componente origen
    destino     TEXT,               -- id componente destino
    etiqueta    TEXT,               -- qué fluye
    tipo        TEXT                -- sync | async | internal
);

CREATE TABLE IF NOT EXISTS roadmap_phases (
    id            TEXT PRIMARY KEY,   -- PHASE-CAN-0 …
    numero        INTEGER,
    nombre        TEXT,
    objetivo      TEXT,
    duracion      TEXT,               -- sprints / semanas relativas
    user_stories  TEXT,               -- JSON array de US
    entregable    TEXT,
    gate          TEXT,
    escenario     TEXT DEFAULT 'baseline'  -- baseline | optimizado
);

CREATE TABLE IF NOT EXISTS team_roles (
    id             TEXT PRIMARY KEY,  -- TEAM-CAN-XX
    squad          TEXT,              -- squad / tribu
    rol            TEXT,
    career_level   TEXT,              -- ACN MX: L4 MD … L9 Analyst
    fte            REAL,              -- headcount asignado
    responsabilidad TEXT,
    sme_fuente     TEXT,              -- SME de Solutioning/SME/ que respalda
    owner          TEXT               -- Accenture | Banco | Mixto
);

CREATE TABLE IF NOT EXISTS team_summary (
    id             TEXT PRIMARY KEY,
    squad          TEXT,
    owner          TEXT,              -- Accenture | Banco | Mixto
    fte_baseline   INTEGER,
    fte_optimizado INTEGER,
    cambio         TEXT
);

CREATE TABLE IF NOT EXISTS optimization_levers (
    id          TEXT PRIMARY KEY,
    palanca     TEXT,
    activo_brain TEXT,
    impacto     TEXT
);

CREATE TABLE IF NOT EXISTS obligations (
    id              TEXT PRIMARY KEY,   -- CAN-OBL-001 … CAN-OBL-023
    articulo        TEXT,
    circular_origen TEXT,
    descripcion     TEXT,
    tipo            TEXT,               -- control | limite | reporte | disclosure
    frecuencia      TEXT,               -- evento | continuo | diario
    riesgo_sancion  TEXT,               -- critico | alto | medio | bajo
    plazo_dhb       INTEGER,            -- días hábiles bancarios si aplica
    rol_aplicable   TEXT,               -- ACREEDORA | DEPOSITARIA | AMBAS
    estado          TEXT DEFAULT 'PENDIENTE'  -- PENDIENTE | EN_PROGRESO | CUMPLIDA
);

CREATE TABLE IF NOT EXISTS systems_impact (
    id              INTEGER PRIMARY KEY AUTOINCREMENT,
    sistema_slug    TEXT,               -- loans | core-banking | payments-engine | etc.
    obligation_id   TEXT,
    tipo_impacto    TEXT,               -- NUEVO_CAMPO | NUEVA_TABLA | NUEVA_LOGICA | NUEVA_PANTALLA | NUEVO_REPORTE
    descripcion     TEXT,
    estimacion_us   TEXT,               -- S | M | L | XL
    estado          TEXT DEFAULT 'PENDIENTE',
    FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

CREATE TABLE IF NOT EXISTS brechas (
    id              TEXT PRIMARY KEY,   -- BRECHA-SANT-CAN-001 …
    obligation_id   TEXT,
    criticidad      TEXT,               -- CRITICA | ALTA | MEDIA | BAJA
    descripcion     TEXT,
    sistema_afectado TEXT,
    capacidad_faltante TEXT,
    user_story_id   TEXT,
    estado          TEXT DEFAULT 'ABIERTA',  -- ABIERTA | EN_PROGRESO | CERRADA
    FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

CREATE TABLE IF NOT EXISTS user_stories (
    id              TEXT PRIMARY KEY,   -- US-SANT-CAN-001 …
    titulo          TEXT,
    obligation_id   TEXT,
    sistema_slug    TEXT,
    como            TEXT,
    quiero          TEXT,
    para            TEXT,
    estimacion      TEXT,               -- S | M | L | XL
    brecha_id       TEXT,
    estado          TEXT DEFAULT 'BACKLOG',  -- BACKLOG | EN_PROGRESO | DONE
    FOREIGN KEY (obligation_id) REFERENCES obligations(id)
);

CREATE TABLE IF NOT EXISTS adrs (
    id              TEXT PRIMARY KEY,   -- ADR-SANT-CAN-001 …
    titulo          TEXT,
    contexto        TEXT,
    decision        TEXT,
    consecuencias   TEXT,
    estado          TEXT DEFAULT 'PROPUESTO'  -- PROPUESTO | ACEPTADO | DEPRECADO
);

CREATE VIRTUAL TABLE IF NOT EXISTS obligations_fts USING fts5(
    id, articulo, descripcion, tipo, rol_aplicable
);
CREATE VIRTUAL TABLE IF NOT EXISTS brechas_fts USING fts5(
    id, descripcion, capacidad_faltante, sistema_afectado
);
"""

# ---------------------------------------------------------------------------
# Seed data — 23 obligaciones CAN
# ---------------------------------------------------------------------------

OBLIGATIONS_SEED = [
    ("CAN-OBL-001", "Art. 63 Bis (párrafo 1)", "Circular 15/2018, mod. 6/2025",
     "Solicitar info Cuenta Ordenante vía Mecanismo Art. 63 Bis 3 antes de ofrecer CAN en cuenta de otra institución",
     "control", "evento", "alto", 1, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-002", "Art. 63 Bis (párrafo 2)", "Circular 15/2018, mod. 6/2025",
     "Amortizaciones periódicas no pueden exceder el porcentaje límite que determine el Comité de Riesgos",
     "limite", "continuo", "critico", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-003", "Art. 63 Bis (párrafo 2, último)", "Circular 15/2018",
     "Notificar límite del Comité de Riesgos a Banxico dentro de los 10 DHB siguientes a su aprobación",
     "reporte", "evento", "alto", 10, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-004", "Art. 63 Bis (párrafo 3)", "Circular 15/2018, mod. 6/2025",
     "Verificar identidad del cliente antes de solicitar info de la Cuenta Ordenante",
     "control", "evento", "medio", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-005", "Art. 63 Bis (párrafo 4)", "Circular 15/2018, mod. 6/2025",
     "Obtener mandato del acreditado con autorización expresa CAN antes de celebrar el crédito",
     "control", "evento", "critico", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-006", "Art. 63 Bis (párrafo 5)", "Circular 15/2018, mod. 6/2025",
     "Liquidar créditos anteriores vía SPEI usando la Clave Básica Estandarizada si el CAN es de refinanciamiento",
     "control", "evento", "alto", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-007", "Art. 63 Bis (penúltimo párrafo)", "Circular 15/2018, mod. 6/2025",
     "Presentar comparativo CAN vs. crédito no-CAN al cliente antes de contratar",
     "disclosure", "evento", "alto", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-008", "Art. 63 Bis (anteúltimo párrafo)", "Circular 15/2018",
     "Reportar a sociedad de información crediticia (buró) el carácter CAN del crédito",
     "reporte", "evento", "medio", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-009", "Art. 63 Bis (último párrafo)", "Circular 15/2018, mod. 6/2025",
     "Asignar Clave Básica Estandarizada (Reglas SPEI Circular 14/2017) a cada CAN otorgado",
     "control", "evento", "medio", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-010", "Art. 63 Bis 1 (párrafo 1)", "Circular 15/2018, mod. 6/2025",
     "Gestionar Domiciliación ante la institución depositaria mediante solicitud Art. 64",
     "control", "evento", "alto", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-011", "Art. 63 Bis 1 (párrafo 2)", "Circular 15/2018, mod. 6/2025",
     "Ajustar pagos periódicos por prepago o reducción de monto conforme a Circular 16/2007",
     "control", "evento", "alto", None, "ACREEDORA", "PENDIENTE"),
    ("CAN-OBL-012", "Art. 63 Bis 3", "Circular 15/2018, mod. 6/2025",
     "Usar mecanismos de comunicación transparentes y notificar a Banxico de manera previa a su implementación",
     "control", "evento", "alto", None, "AMBAS", "PENDIENTE"),
    ("CAN-OBL-013", "Art. 22 Bis (mod. Circular 6/2025)", "Circular 15/2018, mod. 6/2025",
     "Identificar como Cuentas Ordenantes las cuentas que reciben Prestaciones Laborales",
     "control", "continuo", "critico", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-014", "Art. 22 Bis 1, fracción I (párrafo 1)", "Circular 15/2018, mod. 6/2025",
     "Ofrecer al cuentahabiente el derecho de designar créditos como CANs en su Cuenta Ordenante",
     "control", "evento", "critico", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-015", "Art. 22 Bis 1, fracción I, inciso b)", "Circular 15/2018, mod. 6/2025",
     "Comunicar info de Cuenta Ordenante (confirmación + saldos + abonos 6 meses) en máximo 1 DHB",
     "reporte", "evento", "critico", 1, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-016", "Art. 22 Bis 1, fracción I, inciso e)", "Circular 15/2018, mod. 6/2025",
     "Respetar prelación de cargos: no-CAN previos → CANs por fecha designación → domiciliaciones",
     "control", "diario", "critico", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-017", "Art. 22 Bis 1, fracción I, inciso f)", "Circular 15/2018, mod. 6/2025",
     "Al abrir nueva Cuenta Ordenante con CANs previos de otras instituciones, efectuar cargos en prelación",
     "control", "evento", "alto", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-018", "Art. 22 Bis 1, fracción II", "Circular 15/2018, mod. 6/2025",
     "Obtener mandato del cuentahabiente para consultar e informar CANs vía Mecanismo Art. 63 Bis 3",
     "control", "evento", "critico", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-019", "Art. 22 Bis 1, fracción II (párrafos 2-4)", "Circular 15/2018, mod. 6/2025",
     "Comunicar datos de nueva Cuenta Ordenante (nombre banco, CLABE, RFC, CURP, nombre) a instituciones con CANs previos",
     "reporte", "evento", "alto", None, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-020", "Art. 65", "Circular 7/2019, mod. 6/2025",
     "Notificar cancelación de Domiciliación CAN a institución acreedora vía Art. 63 Bis 3 en máximo 1 DHB",
     "control", "evento", "alto", 1, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-021", "Art. 68 (párrafo 2)", "Circular 15/2018, mod. 6/2025",
     "Resolver objeción de cargos CAN en máximo 5 DHB (no aplica plazo de 60 días)",
     "control", "evento", "alto", 5, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-022", "Art. 68 (párrafo 3)", "Circular 7/2019, mod. 6/2025",
     "Remitir copia de objeción CAN a institución acreedora en máximo 2 DHB; acreedora responde en 3 DHB adicionales",
     "control", "evento", "alto", 2, "DEPOSITARIA", "PENDIENTE"),
    ("CAN-OBL-023", "Art. 75", "Circular 7/2015, mod. 15/2018 y 7/2019",
     "Transferir Prestaciones Laborales: mismo DHB si llegan antes 17:00:00, DHB siguiente si llegan después",
     "control", "diario", "critico", None, "DEPOSITARIA", "PENDIENTE"),
]

USER_STORIES_SEED = [
    # ===== ACREEDORA (Santander otorga el CAN — originación en OneFinancial) =====
    ("US-SANT-CAN-001", "Generación de Clave Básica Estandarizada",
     "CAN-OBL-009", "loans",
     "el sistema de créditos",
     "generar y asignar una Clave Básica Estandarizada única a cada CAN otorgado, conforme a Circular 14/2017",
     "identificar el crédito en liquidaciones SPEI y en el hub Banxico (OBL-009)",
     "L", "BRECHA-SANT-CAN-001", "BACKLOG"),
    ("US-SANT-CAN-002", "CECOBAN Gateway — Mecanismo Art. 63 Bis 3",
     "CAN-OBL-012", "can-cecoban-gateway",
     "la capa de integración regulatoria de Santander",
     "conectarse al hub CECOBAN vía REST (POST /api/can/v1/operaciones) + Kafka (SASL/OAUTHBEARER), construir y consumir los códigos C50-C58, gestionar JWT, timeouts, idempotencia por UUID y el catálogo de errores CAN",
     "ser la puerta única al Mecanismo Art. 63 Bis 3 para los flujos ACREEDORA y DEPOSITARIA (OBL-012)",
     "XL", "BRECHA-SANT-CAN-002", "BACKLOG"),
    ("US-SANT-CAN-008", "Prehabilitación interbancaria — consulta de Cuenta Ordenante",
     "CAN-OBL-001", "onefinancial",
     "la plataforma de originación OneFinancial",
     "solicitar la información de la Cuenta Ordenante a otra institución vía el CECOBAN Gateway antes de ofrecer un CAN sobre una cuenta de nómina externa",
     "cumplir OBL-001 y habilitar la originación cuando la nómina no está en Santander",
     "L", "BRECHA-SANT-CAN-008", "BACKLOG"),
    ("US-SANT-CAN-009", "Liquidación SPEI de refinanciamiento con Clave Básica",
     "CAN-OBL-006", "payments-engine",
     "el motor de pagos",
     "liquidar créditos anteriores vía SPEI incluyendo la Clave Básica Estandarizada en la instrucción cuando el CAN sea de refinanciamiento",
     "cumplir OBL-006 sin construir capacidad SPEI nueva — solo extender el campo",
     "M", "BRECHA-SANT-CAN-009", "BACKLOG"),
    ("US-SANT-CAN-010", "Comparativo CAN vs. no-CAN antes de contratar",
     "CAN-OBL-007", "onefinancial",
     "la plataforma de originación OneFinancial",
     "presentar al cliente un comparativo lado a lado del crédito CAN vs. crédito sin CAN (tasa, plazo, pagos) antes de la contratación",
     "cumplir la obligación de disclosure OBL-007",
     "M", "BRECHA-SANT-CAN-010", "BACKLOG"),
    ("US-SANT-CAN-011", "Mandato con autorización expresa CAN",
     "CAN-OBL-005", "onefinancial",
     "el servicio de formalización",
     "incluir en el texto del mandato la autorización expresa CAN (Art. 63 Bis párrafo 4) y registrarla con trazabilidad (timestamp, canal, versión del texto, hash)",
     "cumplir OBL-005 ajustando el template legal del mandato existente",
     "S", "BRECHA-SANT-CAN-011", "BACKLOG"),
    ("US-SANT-CAN-012", "Notificación del límite del Comité de Riesgos a Banxico",
     "CAN-OBL-003", "cnbv-reporting",
     "el sistema de reportería regulatoria",
     "notificar a Banxico el porcentaje límite de amortización aprobado por el Comité de Riesgos dentro de los 10 DHB siguientes",
     "cumplir OBL-003 con un reporte nuevo sobre el canal Banxico existente",
     "M", "BRECHA-SANT-CAN-012", "BACKLOG"),
    ("US-SANT-CAN-013", "Reporte de carácter CAN al buró de crédito",
     "CAN-OBL-008", "cnbv-reporting",
     "el sistema de reportería regulatoria",
     "marcar y reportar el carácter CAN de cada crédito a la sociedad de información crediticia",
     "cumplir OBL-008 con un campo nuevo en el reporte al buró existente",
     "S", "BRECHA-SANT-CAN-013", "BACKLOG"),
    ("US-SANT-CAN-014", "Domiciliación interbancaria vía Art. 64",
     "CAN-OBL-010", "can-cecoban-gateway",
     "la capa de integración regulatoria",
     "gestionar la solicitud de Domiciliación ante la institución depositaria vía el Mecanismo CAN (Art. 64) cuando la nómina está en otra institución",
     "cumplir OBL-010 para nóminas fuera de Santander",
     "L", "BRECHA-SANT-CAN-014", "BACKLOG"),
    ("US-SANT-CAN-021", "Motor de capacidad de pago CAN (límite de amortización)",
     "CAN-OBL-002", "onefinancial",
     "el motor de riesgo de originación",
     "validar que la suma de las amortizaciones periódicas de TODOS los CANs del acreditado no exceda el porcentaje límite del Comité de Riesgos sobre el promedio de abonos de 6 meses de la Cuenta Ordenante, consumiendo la respuesta C-51 interbancaria",
     "cumplir OBL-002 — el scoring interno no ve los CANs del acreditado en otras instituciones",
     "L", "BRECHA-SANT-CAN-021", "BACKLOG"),
    ("US-SANT-CAN-022", "Recepción reactiva ACREEDORA (mensajes entrantes de Cecoban)",
     "CAN-OBL-022", "onefinancial",
     "la orquestación ACREEDORA",
     "consumir del CECOBAN Gateway los mensajes que Cecoban dirige a Santander como acreedora — C-53 (mi posición de prelación), C-54/C-55 (cancelación/baja de domiciliación por el nominado), C-57 (info de créditos en portabilidad) — actualizar el estado del CAN y responder las objeciones remitidas en máximo 3 DHB",
     "cerrar el lado reactivo de la acreedora: hoy solo se modeló el envío, no la recepción ni la respuesta a objeciones",
     "M", "BRECHA-SANT-CAN-022", "BACKLOG"),

    # ===== DEPOSITARIA (Santander recibe la nómina — orquestación en el core) =====
    ("US-SANT-CAN-003", "Aplicación de prelación de cargos CAN",
     "CAN-OBL-016", "core-banking",
     "el sistema de cuentas",
     "aplicar el orden de CANs que calcula y transmite Cecoban (C-53), intercalando los cargos no-CAN previos de Santander que Cecoban no conoce (Art. 22 Bis 1 fracción I inciso e), y resolviendo saldo insuficiente con cargo parcial y arrastre — sin recalcular el orden interbancario",
     "cumplir OBL-016 respetando la frontera: Cecoban ordena los CANs, el banco los aplica y los fusiona con sus obligaciones no-CAN",
     "L", "BRECHA-SANT-CAN-003", "BACKLOG"),
    ("US-SANT-CAN-004", "Monitor SLA 17:00 DHB — transferencia de prestaciones",
     "CAN-OBL-023", "core-banking",
     "el scheduler de nómina",
     "transferir las Prestaciones Laborales el mismo DHB si el abono llega antes de las 17:00:00, o el DHB siguiente si llega después, con alertas operativas",
     "cumplir OBL-023 sin incurrir en sanciones Banxico por timing incorrecto",
     "S", "BRECHA-SANT-CAN-004", "BACKLOG"),
    ("US-SANT-CAN-005", "Nómina Interbancaria — Institución Ordenante",
     "CAN-OBL-019", "core-banking",
     "el sistema de cuentas",
     "notificar a instituciones acreedoras con CANs previos, vía el CECOBAN Gateway, cuando se abre o designa una nueva Cuenta Ordenante (nombre del banco, CLABE, RFC, CURP, nombre)",
     "cumplir OBL-019 y Art. 81 Bis 1 (Servicio de Nómina Interbancaria)",
     "L", "BRECHA-SANT-CAN-005", "BACKLOG"),
    ("US-SANT-CAN-006", "Nómina Interbancaria — Institución Receptora",
     "CAN-OBL-017", "core-banking",
     "el sistema de cuentas",
     "al abrir una nueva Cuenta Ordenante, consultar CANs previos del cuentahabiente en otras instituciones vía el Gateway y registrar la prelación correspondiente",
     "cumplir OBL-017 y Art. 81 Bis 2 cuando Santander recibe nómina portada",
     "L", "BRECHA-SANT-CAN-006", "BACKLOG"),
    ("US-SANT-CAN-007", "Disclosure digital del derecho a designar CAN",
     "CAN-OBL-014", "supermovil",
     "el canal digital SuperMóvil / Santander Online",
     "mostrar al cuentahabiente su derecho a designar CANs y el estado actual de prelación en su Cuenta Ordenante",
     "cumplir OBL-014 con una experiencia digital clara",
     "S", "BRECHA-SANT-CAN-007", "BACKLOG"),
    ("US-SANT-CAN-015", "Identificación de Cuentas Ordenantes (Prestaciones Laborales)",
     "CAN-OBL-013", "core-banking",
     "el sistema de cuentas",
     "identificar y marcar las cuentas que reciben Prestaciones Laborales como Cuentas Ordenantes elegibles para CAN",
     "cumplir OBL-013 — prerequisito de todos los flujos DEPOSITARIA",
     "M", "BRECHA-SANT-CAN-015", "BACKLOG"),
    ("US-SANT-CAN-016", "Comunicación de info de Cuenta Ordenante en 1 DHB",
     "CAN-OBL-015", "core-banking",
     "el sistema de cuentas",
     "responder vía el Gateway, en máximo 1 DHB, la confirmación de la Cuenta Ordenante más saldos y abonos de los últimos 6 meses",
     "cumplir OBL-015 (SLA regulatorio de 1 DHB)",
     "L", "BRECHA-SANT-CAN-016", "BACKLOG"),
    ("US-SANT-CAN-017", "Mandato de consulta de CANs — depositaria",
     "CAN-OBL-018", "supermovil",
     "el canal digital",
     "obtener del cuentahabiente el mandato para consultar e informar sus CANs vía el Mecanismo Art. 63 Bis 3",
     "cumplir OBL-018 antes de cualquier intercambio interbancario de sus datos",
     "S", "BRECHA-SANT-CAN-017", "BACKLOG"),
    ("US-SANT-CAN-018", "Cancelación de Domiciliación CAN en 1 DHB",
     "CAN-OBL-020", "core-banking",
     "el sistema de cuentas",
     "notificar la cancelación de la Domiciliación CAN a la institución acreedora vía el Gateway en máximo 1 DHB",
     "cumplir OBL-020 (SLA regulatorio de 1 DHB)",
     "M", "BRECHA-SANT-CAN-018", "BACKLOG"),
    ("US-SANT-CAN-019", "Resolución de objeción de cargos CAN en 5 DHB",
     "CAN-OBL-021", "core-banking",
     "el sistema de cuentas",
     "resolver la objeción de cargos CAN del cuentahabiente en máximo 5 DHB (sin aplicar el plazo de 60 días)",
     "cumplir OBL-021",
     "M", "BRECHA-SANT-CAN-019", "BACKLOG"),
    ("US-SANT-CAN-020", "Remisión de objeción a institución acreedora en 2 DHB",
     "CAN-OBL-022", "can-cecoban-gateway",
     "la capa de integración regulatoria",
     "remitir copia de la objeción CAN a la institución acreedora vía el Gateway en máximo 2 DHB y recibir su respuesta en 3 DHB adicionales",
     "cumplir OBL-022",
     "S", "BRECHA-SANT-CAN-020", "BACKLOG"),
]

BRECHAS_SEED = [
    # ===== ACREEDORA =====
    ("BRECHA-SANT-CAN-001", "CAN-OBL-009", "CRITICA",
     "No existe generación de Clave Básica Estandarizada en el sistema de créditos",
     "loans", "Generación y asignación de Clave Básica Estandarizada per Circular 14/2017",
     "US-SANT-CAN-001", "ABIERTA"),
    ("BRECHA-SANT-CAN-002", "CAN-OBL-012", "CRITICA",
     "No existe integración con el Mecanismo Art. 63 Bis 3 (hub CECOBAN) — brecha universal a todos los IBMs",
     "can-cecoban-gateway", "CECOBAN Gateway: REST + Kafka, C50-C58, JWT, idempotencia, catálogo de errores CAN",
     "US-SANT-CAN-002", "ABIERTA"),
    ("BRECHA-SANT-CAN-008", "CAN-OBL-001", "ALTA",
     "La prehabilitación solo consulta nóminas internas Santander; falta la consulta interbancaria vía el Gateway",
     "onefinancial", "Prehabilitación interbancaria vía CECOBAN Gateway antes de ofrecer CAN externo",
     "US-SANT-CAN-008", "ABIERTA"),
    ("BRECHA-SANT-CAN-009", "CAN-OBL-006", "ALTA",
     "SPEI existe pero la instrucción de refinanciamiento no incluye la Clave Básica Estandarizada",
     "payments-engine", "Extensión de la instrucción SPEI con Clave Básica en refinanciamientos",
     "US-SANT-CAN-009", "ABIERTA"),
    ("BRECHA-SANT-CAN-010", "CAN-OBL-007", "MEDIA",
     "La originación no genera el comparativo CAN vs. crédito sin CAN exigido antes de contratar",
     "onefinancial", "Pantalla comparativa CAN vs. no-CAN lado a lado",
     "US-SANT-CAN-010", "ABIERTA"),
    ("BRECHA-SANT-CAN-011", "CAN-OBL-005", "ALTA",
     "El texto del mandato no confirma la autorización expresa CAN requerida por Art. 63 Bis párrafo 4",
     "onefinancial", "Template de mandato con autorización expresa CAN + trazabilidad",
     "US-SANT-CAN-011", "ABIERTA"),
    ("BRECHA-SANT-CAN-012", "CAN-OBL-003", "MEDIA",
     "No existe reporte de notificación del límite del Comité de Riesgos a Banxico (10 DHB)",
     "cnbv-reporting", "Reporte regulatorio nuevo del % límite a Banxico",
     "US-SANT-CAN-012", "ABIERTA"),
    ("BRECHA-SANT-CAN-013", "CAN-OBL-008", "MEDIA",
     "El reporte al buró no marca el carácter CAN del crédito",
     "cnbv-reporting", "Campo/marcador CAN en el reporte al buró de crédito",
     "US-SANT-CAN-013", "ABIERTA"),
    ("BRECHA-SANT-CAN-014", "CAN-OBL-010", "ALTA",
     "La domiciliación interbancaria vía Art. 64 no existe — solo funciona para nóminas en Santander",
     "can-cecoban-gateway", "Gestión de Domiciliación interbancaria vía Mecanismo CAN (Art. 64)",
     "US-SANT-CAN-014", "ABIERTA"),
    ("BRECHA-SANT-CAN-021", "CAN-OBL-002", "CRITICA",
     "El scoring interno no evalúa la capacidad de pago agregada de todos los CANs del acreditado ni consume los abonos de 6 meses del C-51 interbancario; no hay motor que aplique el % límite del Comité de Riesgos regulatorio",
     "onefinancial", "Motor de capacidad de pago CAN (% límite sobre promedio de abonos 6 meses, consumiendo C-51)",
     "US-SANT-CAN-021", "ABIERTA"),
    ("BRECHA-SANT-CAN-022", "CAN-OBL-022", "ALTA",
     "Solo se modeló el envío de mensajes a Cecoban; falta el lado ACREEDORA reactivo (recepción de C-53/C-54/C-55/C-57) y la respuesta a objeciones en 3 DHB",
     "onefinancial", "Consumidor de mensajes entrantes de la acreedora + respuesta a objeción (SLA 3 DHB)",
     "US-SANT-CAN-022", "ABIERTA"),

    # ===== DEPOSITARIA =====
    ("BRECHA-SANT-CAN-003", "CAN-OBL-016", "CRITICA",
     "El motor de cargos no implementa la prelación regulatoria CAN (no-CAN previos → CANs por fecha → domiciliaciones)",
     "core-banking", "Motor de prelación de cargos conforme a Art. 22 Bis 1 fracción I inciso e)",
     "US-SANT-CAN-003", "ABIERTA"),
    ("BRECHA-SANT-CAN-004", "CAN-OBL-023", "ALTA",
     "No existe monitor de SLA para la transferencia de Prestaciones Laborales con corte 17:00 DHB",
     "core-banking", "Scheduler con cutoff 17:00 DHB y alertas operativas",
     "US-SANT-CAN-004", "ABIERTA"),
    ("BRECHA-SANT-CAN-005", "CAN-OBL-019", "ALTA",
     "No se notifica a instituciones acreedoras al abrir/designar nuevas Cuentas Ordenantes",
     "core-banking", "Flujo de notificación inter-IBM vía CECOBAN Gateway",
     "US-SANT-CAN-005", "ABIERTA"),
    ("BRECHA-SANT-CAN-006", "CAN-OBL-017", "ALTA",
     "Al recibir nómina portada, no se consultan ni registran CANs previos del cuentahabiente",
     "core-banking", "Consulta de CANs previos vía Gateway al abrir Cuenta Ordenante",
     "US-SANT-CAN-006", "ABIERTA"),
    ("BRECHA-SANT-CAN-007", "CAN-OBL-014", "CRITICA",
     "Los canales digitales no muestran el derecho a designar CANs ni el estado de prelación",
     "supermovil", "Pantallas de disclosure del derecho a designar CAN (OBL-014)",
     "US-SANT-CAN-007", "ABIERTA"),
    ("BRECHA-SANT-CAN-015", "CAN-OBL-013", "CRITICA",
     "No se identifican ni marcan las cuentas que reciben Prestaciones Laborales como Cuentas Ordenantes",
     "core-banking", "Identificación/marcado de Cuentas Ordenantes — prerequisito DEPOSITARIA",
     "US-SANT-CAN-015", "ABIERTA"),
    ("BRECHA-SANT-CAN-016", "CAN-OBL-015", "CRITICA",
     "No existe respuesta en 1 DHB con confirmación de Cuenta Ordenante + saldos + abonos de 6 meses",
     "core-banking", "Servicio de comunicación de info de Cuenta Ordenante (SLA 1 DHB)",
     "US-SANT-CAN-016", "ABIERTA"),
    ("BRECHA-SANT-CAN-017", "CAN-OBL-018", "CRITICA",
     "No se obtiene el mandato del cuentahabiente para consultar e informar sus CANs",
     "supermovil", "Captura de mandato de consulta CANs (depositaria)",
     "US-SANT-CAN-017", "ABIERTA"),
    ("BRECHA-SANT-CAN-018", "CAN-OBL-020", "ALTA",
     "No se notifica la cancelación de Domiciliación CAN a la acreedora en 1 DHB",
     "core-banking", "Notificación de cancelación de Domiciliación CAN (SLA 1 DHB)",
     "US-SANT-CAN-018", "ABIERTA"),
    ("BRECHA-SANT-CAN-019", "CAN-OBL-021", "ALTA",
     "No existe flujo de resolución de objeción de cargos CAN en 5 DHB",
     "core-banking", "Workflow de objeción de cargos CAN (SLA 5 DHB)",
     "US-SANT-CAN-019", "ABIERTA"),
    ("BRECHA-SANT-CAN-020", "CAN-OBL-022", "ALTA",
     "No se remite copia de la objeción CAN a la institución acreedora en 2 DHB",
     "can-cecoban-gateway", "Remisión de objeción a acreedora vía Gateway (SLA 2 DHB)",
     "US-SANT-CAN-020", "ABIERTA"),
]

MICROSERVICES_SEED = [
    # id, nombre, version, java_version, spring_boot, rol, descripcion, responsabilidad,
    # sistemas_llama, endpoints_count, bd, etb_capabilities
    ("MS-CAN-001", "products-service", "1.0.33-SNAPSHOT", "Java 21", "Spring Boot 3.5.8",
     "NEGOCIO",
     "Orquestador central del flujo de originación de CAN. Coordina scoring (risks-service), gateway de ofertas (offers-service) y formalización. Gestiona el SmartFolio (folio único de propuesta) y el ciclo de vida de la oferta crédito + TDC.",
     "Otorgamiento CAN: prehabilitación, scoring RDT (3 rondas), simulador de condiciones, re-evaluación post-30 días (flagRDT3Dispersion), cancelación y cleanup.",
     '["risks-service", "offers-service", "formalization-service", "log-service", "Redis", "Eureka", "SQL Server OptimusNominaTST"]',
     12, "SQL Server OptimusNominaTST @192.168.122.200:1433",
     '["ETB-CAN-001","ETB-CAN-003","ETB-CAN-011"]'),

    ("MS-CAN-002", "offers-service", "1.0.17-SNAPSHOT", "Java 17", "Spring Boot 3.2.0",
     "NEGOCIO",
     "Gateway de integración con los sistemas externos de Santander. Consume Offers API (preclasificación), Payroll API (validación nómina), Payroll OTP (autenticación NEO/nómina) y RTF (Solicitudes de Vuelo folio scoring).",
     "Prehabilitación CAN: consulta cuenta de nómina del acreditado en sistemas Santander (NO en CECOBAN). Orquesta el flujo OAuth + preclass v1/v2. Gestiona domiciliación interna vía Payroll API.",
     '["api18.pre.mx.corp:8989 (Offers API)", "payrollsrvc-payroll-services.caas.pre.mx.corp:8989 (Payroll API)", "nominaotp.caas.pre.mx.corp:8989 (Payroll OTP/NEO)", "solvuelocaas.pre.mx.corp:8989 (RTF)", "Eureka", "SQL Server OptimusNominaTST"]',
     8, "SQL Server OptimusNominaTST @192.168.122.200:1433",
     '["ETB-CAN-001","ETB-CAN-003","ETB-CAN-004","ETB-CAN-007"]'),

    ("MS-CAN-003", "risks-service", "1.0.13-SNAPSHOT", "Java 17", "Spring Boot 3.2.0",
     "NEGOCIO",
     "Motor de evaluación crediticia. Invoca el motor de scoring RDT de Santander (3 rondas). Gestiona el RTF (folio de solicitud de vuelo). El campo flagRDT3Dispersion determina si la nómina se dispersa por Santander (crédito inmediato) o por otra institución (oferta condicional 30 días).",
     "Scoring CAN: invoca ndrdtcaas.pre.mx.corp:8989/bw6/Starter-IG (RDT). Gestiona RTF via solvuelocaas. flagRDT3Dispersion es el pivot regulatorio CAN: true=dispersión Santander, false=institución depositaria (30 días).",
     '["ndrdtcaas.pre.mx.corp:8989/bw6/Starter-IG (RDT Santander)", "solvuelocaas.pre.mx.corp:8989 (RTF)", "Eureka", "SQL Server OptimusNominaTST"]',
     6, "SQL Server OptimusNominaTST @192.168.122.200:1433",
     '["ETB-CAN-002","ETB-CAN-010"]'),

    ("MS-CAN-004", "formalization-service", "1.0.17-SNAPSHOT", "Java 17", "Spring Boot 3.2.0",
     "NEGOCIO",
     "Cierre del ciclo de originación: confirma la oferta CAN al acreditado, valida FAD (Firma Autógrafa Digital) y registra el canal de contratación (SUCURSAL/DIGITAL/CALL_CENTER).",
     "Formalización CAN: validación FAD, confirmación por canal, registro del mandato de pago en SmartFolio. Último paso antes de la activación del crédito.",
     '["Eureka", "SQL Server OptimusNominaTST"]',
     5, "SQL Server OptimusNominaTST @192.168.122.200:1433",
     '["ETB-CAN-001","ETB-CAN-005","ETB-CAN-008"]'),

    ("MS-CAN-005", "products-utils-service", "1.0.11-SNAPSHOT", "Java 17", "Spring Boot 3.2.0",
     "INFRAESTRUCTURA",
     "Librería compartida de catálogos, mensajes de error y configuración técnica. No expone endpoints propios — es una dependencia Maven de los demás micros.",
     "Proporciona: catálogos de tipos de crédito, mapas de mensajes de error, constantes de canales (SUCURSAL/DIGITAL/CALL_CENTER), DTOs compartidos.",
     '[]', 0, "N/A",
     '["ETB-CAN-012"]'),

    ("MS-CAN-006", "log-service", "1.0.0-SNAPSHOT", "Java 8", "Spring Boot 2.7.1",
     "INFRAESTRUCTURA",
     "Auditoría asíncrona vía Kafka. Recibe eventos de los demás micros y los persiste en la tabla ISBAN_LOG de SQL Server. Garantiza trazabilidad regulatoria de todas las operaciones.",
     "Auditoría CAN: consume topic Kafka, escribe en ISBAN_LOG. Soporte para trazabilidad obligatoria de flujos regulatorios (todo evento de originación CAN queda registrado).",
     '["Kafka", "SQL Server OptimusNominaTST (ISBAN_LOG)"]',
     1, "SQL Server OptimusNominaTST @192.168.122.200:1433 (tabla ISBAN_LOG)",
     '["ETB-CAN-011"]'),

    ("MS-CAN-007", "products-config-service", "1.0.2-SNAPSHOT", "Java 8", "Spring Boot 1.5.1",
     "INFRAESTRUCTURA",
     "Spring Cloud Config Server — centraliza la configuración de los demás micros. Package residual: com.viverebrasil.financeira (origen Brasil, heredado). Versiones obsoletas: Spring Boot 1.5.1 + Java 8.",
     "Configuración centralizada: sirve application.yml a los demás micros. Riesgo técnico: Spring Boot 1.5.1 EOL desde 2019; Java 8 EOL comercial. Requiere upgrade urgente.",
     '[]', 1, "N/A (config files solo)",
     '["ETB-CAN-012"]'),
]

ETB_CAPABILITIES_SEED = [
    # id, etb_l1, etb_l2, descripcion, estado_can, sistemas_santander, obligaciones, nota_gap
    # NOTA: estado_can refleja capacidades reales del banco Santander vs. requisitos específicos de CAN.
    # Las capacidades marcadas CUBIERTO existen en producción; CAN no requiere desarrollo nuevo en ellas.
    # PARCIAL = la capacidad existe pero CAN añade requisitos específicos (campo nuevo, pantalla, reporte).
    # BRECHA = capacidad completamente nueva exigida por la regulación CAN.

    ("ETB-CAN-001", "Retail Banking", "Loan Origination",
     "Proceso completo de originación de crédito: solicitud, evaluación, oferta, aprobación y desembolso.",
     "PARCIAL",
     '["loans", "core-banking"]',
     '["CAN-OBL-001","CAN-OBL-004","CAN-OBL-005","CAN-OBL-007"]',
     "Santander tiene originación de crédito de nómina madura en sistema loans. CAN exige build nuevo: prehabilitación interbancaria vía CECOBAN (OBL-001), mandato con autorización expresa CAN (OBL-005) y comparativo CAN vs. no-CAN antes de contratar (OBL-007)."),

    ("ETB-CAN-002", "Retail Banking", "Credit Assessment & Underwriting",
     "Evaluación del riesgo crediticio: scoring, validación de límites, políticas de crédito.",
     "PARCIAL",
     '["loans", "core-banking"]',
     '["CAN-OBL-002","CAN-OBL-004"]',
     "Santander tiene scoring y Comité de Riesgos. CAN exige un motor de capacidad de pago nuevo (OBL-002): validar que la suma de amortizaciones de TODOS los CANs del acreditado no exceda el % límite sobre el promedio de abonos de 6 meses — consumiendo el C-51 interbancario que el scoring interno no ve."),

    ("ETB-CAN-003", "Retail Banking", "Payroll Credit Management",
     "Gestión del crédito asociado a nómina: consulta cuenta ordenante, condiciones especiales, reevaluación periódica.",
     "PARCIAL",
     '["loans", "payments-engine"]',
     '["CAN-OBL-001","CAN-OBL-002","CAN-OBL-011","CAN-OBL-013","CAN-OBL-016"]',
     "Santander gestiona crédito de nómina internamente. CAN añade: prehabilitación interbancaria vía CECOBAN, flujo de reevaluación post-30 días para nóminas en otras instituciones, prelación regulatoria de cargos."),

    ("ETB-CAN-004", "Retail Banking", "Account Domiciliation",
     "Registro y gestión de domiciliaciones: instrucciones de cargo automático a cuenta de nómina.",
     "PARCIAL",
     '["core-banking", "payments-engine"]',
     '["CAN-OBL-010","CAN-OBL-020"]',
     "Santander tiene domiciliación interna. CAN exige domiciliación interbancaria vía Art. 64 CECOBAN cuando la nómina está en otra institución depositaria. Requiere adaptador Art. 63 Bis 3."),

    ("ETB-CAN-005", "Payments", "SPEI Processing",
     "Liquidación de pagos via SPEI: transferencias, instrucciones de pago, reconciliación.",
     "PARCIAL",
     '["banxico-spei", "payments-engine"]',
     '["CAN-OBL-006","CAN-OBL-009"]',
     "Santander tiene SPEI productivo (banxico-spei CONFIRMED). CAN exige generar la Clave Básica Estandarizada (Circular 14/2017) e incluirla en la instrucción de refinanciamiento (OBL-006/009) — campo nuevo en loans + extensión de la instrucción SPEI."),

    ("ETB-CAN-006", "Payments", "Interbank Messaging (CECOBAN CAN)",
     "Integración al Mecanismo Art. 63 Bis 3 (hub centralizado Banxico): mensajería interbancaria C50-C58.",
     "BRECHA",
     '["can-cecoban-gateway"]',
     '["CAN-OBL-001","CAN-OBL-003","CAN-OBL-006","CAN-OBL-009","CAN-OBL-010","CAN-OBL-012","CAN-OBL-015","CAN-OBL-017","CAN-OBL-019","CAN-OBL-020","CAN-OBL-022"]',
     "ÚNICA BRECHA CRÍTICA: ningún banco tiene esta integración pre-implementada — es infraestructura nueva exigida por la circular. Se implementa como CECOBAN Gateway (puerta única bajo identidad regulatoria Santander), consumido por OneFinancial (ACREEDORA) y core-banking (DEPOSITARIA). Ver ADR-SANT-CAN-001."),

    ("ETB-CAN-007", "Payments", "Payroll Disbursement Integration",
     "Integración con el sistema de dispersión de nómina del empleador y de la institución depositaria.",
     "PARCIAL",
     '["payments-engine", "core-banking"]',
     '["CAN-OBL-010","CAN-OBL-013","CAN-OBL-023"]',
     "Santander integra con empleadores para dispersión de nómina propia. CAN requiere coordinación interbancaria vía CECOBAN cuando la nómina cambia de institución depositaria."),

    ("ETB-CAN-008", "Digital Banking", "Digital Signature & Consent Management",
     "Captura del consentimiento digital del acreditado: firma digital, mandatos, autorización expresa.",
     "PARCIAL",
     '["supermovil", "santander-online"]',
     '["CAN-OBL-005","CAN-OBL-014","CAN-OBL-018"]',
     "Santander tiene FAD (Firma Autógrafa Digital) en canales digitales. CAN requiere que el texto del mandato incluya la autorización expresa CAN (Art. 63 Bis párrafo 4) — ajuste de template legal."),

    ("ETB-CAN-009", "Compliance", "Regulatory Reporting",
     "Reporte a reguladores: buró de crédito (carácter CAN), Banxico (límite Comité de Riesgos).",
     "PARCIAL",
     '["cnbv-reporting"]',
     '["CAN-OBL-003","CAN-OBL-008"]',
     "Santander tiene reportería CNBV/Banxico madura. CAN añade dos reportes nuevos: notificación del límite Comité de Riesgos a Banxico (OBL-003) y carácter CAN al buró de crédito (OBL-008)."),

    ("ETB-CAN-010", "Compliance", "Credit Risk Governance",
     "Gestión del riesgo crediticio bajo políticas internas: límites Comité de Riesgos, parámetros de dispersión.",
     "CUBIERTO",
     '["core-banking", "loans"]',
     '["CAN-OBL-002","CAN-OBL-003"]',
     "Santander tiene Comité de Riesgos activo y gobierno de crédito establecido. CAN formaliza la notificación del % límite a Banxico — cambio de proceso, no de capacidad técnica."),

    ("ETB-CAN-011", "Compliance", "Audit & Compliance Logging",
     "Registro de auditoría de todas las operaciones: trazabilidad regulatoria, trail de decisiones.",
     "CUBIERTO",
     '["core-banking"]',
     '["CAN-OBL-005","CAN-OBL-007","CAN-OBL-021"]',
     "Santander tiene auditoría transaccional completa. Cuando se implemente CECOBAN, los eventos del Mecanismo se trazarán naturalmente sobre la infraestructura de logging existente."),

    ("ETB-CAN-012", "Operations", "Configuration Management",
     "Gestión centralizada de configuración: parámetros de servicio, catálogos, feature flags.",
     "CUBIERTO",
     '["azure-backbone"]',
     '[]',
     "Azure App Configuration / Key Vault disponibles. Sin cambios requeridos por CAN en esta capacidad."),
]

OBLIGATION_COVERAGE_SEED = [
    # id(auto), obligation_id, sistema_slug, cobertura, evidencia, gap_detectado
    # Evaluación contra sistemas SANTANDER existentes (no OneFinancial).

    # OBL-001: Solicitar info Cuenta Ordenante vía Mecanismo CAN
    (None, "CAN-OBL-001", "loans", "PARCIAL",
     "Sistema loans puede consultar créditos de nómina del acreditado para clientes Santander existentes.",
     "La prehabilitación de nóminas en otras instituciones requiere el Mecanismo Art. 63 Bis 3. Sin integración CECOBAN, solo funciona para acreditados que ya tienen cuenta en Santander."),

    # OBL-002: Amortizaciones ≤ límite Comité Riesgos
    (None, "CAN-OBL-002", "loans", "CUBIERTO",
     "Sistema loans aplica políticas de riesgo del Comité de Riesgos de Santander. Límites de monto y amortización parametrizados en el motor de crédito.",
     "CAN formaliza que el % límite debe notificarse a Banxico (OBL-003), pero la capacidad de gobernar el límite ya existe."),

    # OBL-003: Notificar límite Comité Riesgos a Banxico (10 DHB)
    (None, "CAN-OBL-003", "cnbv-reporting", "PARCIAL",
     "cnbv-reporting tiene infraestructura de comunicación regulatoria con Banxico. El canal técnico existe.",
     "Requiere nuevo tipo de mensaje CAN: notificación formal del % límite aprobado por el Comité. Cambio en catálogo de reportes regulatorios."),

    # OBL-004: Verificar identidad antes de solicitar info
    (None, "CAN-OBL-004", "core-banking", "CUBIERTO",
     "core-banking establece identidad completa del acreditado en todos los flujos (KYC regulatorio CNBV completo).",
     "Cumplimiento natural. Para no-clientes que solicitan CAN, aplica el flujo estándar de KYC de onboarding."),

    # OBL-005: Obtener mandato CAN con autorización expresa
    (None, "CAN-OBL-005", "loans", "PARCIAL",
     "Santander captura consentimiento en el proceso de originación de crédito. FAD disponible en canales digitales y sucursal.",
     "El texto del mandato debe incluir la autorización expresa CAN específica (Art. 63 Bis párrafo 4). Ajuste de template legal, no nueva capacidad."),

    # OBL-006: Liquidar créditos vía SPEI + Clave Básica
    (None, "CAN-OBL-006", "banxico-spei", "PARCIAL",
     "banxico-spei procesa SPEI productivamente. Santander puede liquidar créditos anteriores vía SPEI sin problemas.",
     "La Clave Básica Estandarizada (Circular 14/2017) es un campo nuevo que debe generarse en loans y enviarse en la instrucción SPEI. Cambio mínimo de campo."),

    # OBL-007: Comparativo CAN vs. no-CAN antes de contratar
    (None, "CAN-OBL-007", "supermovil", "PARCIAL",
     "SuperMóvil y Santander Online tienen capacidad de presentar información de productos crediticios al cliente.",
     "Se requiere nueva pantalla comparativa CAN vs. crédito sin CAN (dos columnas). Cambio de UX/UI, no nueva capacidad de canal."),

    # OBL-008: Reportar carácter CAN a buró
    (None, "CAN-OBL-008", "cnbv-reporting", "PARCIAL",
     "cnbv-reporting integra con sociedades de información crediticia para reportes regulatorios estándar.",
     "Se requiere nuevo campo 'carácter CAN' en el reporte al buró. Cambio de catálogo de reporte."),

    # OBL-009: Asignar Clave Básica Estandarizada
    (None, "CAN-OBL-009", "loans", "PARCIAL",
     "Sistema loans puede generar identificadores únicos de crédito. La infraestructura de generación de IDs existe.",
     "La Clave Básica Estandarizada sigue el formato específico de Circular 14/2017. Requiere nuevo generador conforme al estándar Banxico + campo en la tabla de créditos."),

    # OBL-010: Domiciliación interbancaria Art. 64
    (None, "CAN-OBL-010", "payments-engine", "NO_CUBIERTO",
     "Santander puede instruir domiciliaciones para cuentas propias (interno).",
     "La domiciliación interbancaria vía Art. 64 requiere el Mecanismo CECOBAN para instrucciones a otras instituciones depositarias. Capacidad nueva, no existente."),

    # OBL-011: Ajustar pagos por prepago (Circular 16/2007)
    (None, "CAN-OBL-011", "loans", "CUBIERTO",
     "Sistema loans implementa ajustes por prepago y reducción de monto conforme a Circular 16/2007. Capacidad estándar del ciclo de vida de crédito en Santander.",
     "Sin gap específico de CAN — obligación ya cubierta por el ciclo estándar del crédito."),

    # OBL-012: Mecanismo Art. 63 Bis 3 (hub CECOBAN)
    (None, "CAN-OBL-012", "payments-engine", "NO_CUBIERTO",
     "No existe adaptador al Mecanismo CAN. Ningún sistema Santander actual conecta al hub Art. 63 Bis 3.",
     "BRECHA CRÍTICA: requiere nuevo componente de integración. Candidato para implementación en OneFinancial como orquestador CAN."),

    # ===== DEPOSITARIA (OBL-013..023) =====
    # OBL-013: Identificar Cuentas Ordenantes (Prestaciones Laborales)
    (None, "CAN-OBL-013", "core-banking", "PARCIAL",
     "core-banking identifica cuentas y abonos de nómina de empleadores registrados.",
     "Falta marcar explícitamente la cuenta como 'Cuenta Ordenante' elegible CAN y distinguir Prestaciones Laborales de otros abonos. Prerequisito de todos los flujos depositaria."),

    # OBL-014: Ofrecer derecho a designar CANs
    (None, "CAN-OBL-014", "supermovil", "NO_CUBIERTO",
     "Los canales digitales muestran productos, pero no el derecho a designar CANs.",
     "Pantalla nueva de disclosure del derecho a designar CAN + vista del estado de prelación. Cambio de UX en SuperMóvil / Santander Online."),

    # OBL-015: Comunicar info Cuenta Ordenante en 1 DHB
    (None, "CAN-OBL-015", "core-banking", "NO_CUBIERTO",
     "No existe servicio que responda confirmación + saldos + abonos de 6 meses en 1 DHB (30 s por mensaje).",
     "Requiere el read-model C-51 (ADR-007) + el CECOBAN Gateway. Es el SLA técnico más exigente."),

    # OBL-016: Prelación de cargos
    (None, "CAN-OBL-016", "core-banking", "NO_CUBIERTO",
     "El motor de cargos no aplica el orden de prelación CAN que transmite Cecoban (C-53).",
     "Componente de aplicación de prelación: aplica el orden de Cecoban, intercala no-CAN previos y resuelve saldo insuficiente (ADR-002). No recalcula."),

    # OBL-017: Nueva Cuenta Ordenante con CANs previos
    (None, "CAN-OBL-017", "core-banking", "NO_CUBIERTO",
     "Al abrir una cuenta que recibe nómina portada, no se consultan CANs previos del cuentahabiente.",
     "Requiere consulta vía Gateway (C-56/C-57) y registro de la prelación recibida (C-53). Art. 81 Bis 2."),

    # OBL-018: Mandato de consulta CANs
    (None, "CAN-OBL-018", "supermovil", "NO_CUBIERTO",
     "No se captura el mandato del cuentahabiente para consultar e informar sus CANs vía el Mecanismo.",
     "Captura de mandato nuevo (entidad mandatos, ADR-006) antes de cualquier intercambio interbancario de sus datos."),

    # OBL-019: Comunicar datos de nueva Cuenta Ordenante a acreedoras
    (None, "CAN-OBL-019", "core-banking", "NO_CUBIERTO",
     "No se notifica a instituciones acreedoras al abrir/designar una nueva Cuenta Ordenante.",
     "Flujo de notificación inter-IBM vía Gateway (nombre banco, CLABE, RFC, CURP, nombre). Art. 81 Bis 1."),

    # OBL-020: Cancelación de Domiciliación en 1 DHB
    (None, "CAN-OBL-020", "core-banking", "NO_CUBIERTO",
     "No se notifica la cancelación de la Domiciliación CAN a la acreedora en el SLA de 1 DHB.",
     "Requiere el flujo C-54 (estatus 04) vía Gateway + calendario DHB (ADR-006)."),

    # OBL-021: Resolver objeción de cargos CAN en 5 DHB
    (None, "CAN-OBL-021", "core-banking", "PARCIAL",
     "Santander tiene gestión estándar de aclaraciones/objeciones de cargos.",
     "Falta el flujo específico CAN con SLA de 5 DHB (sin el plazo de 60 días) y su enlace con la remisión a la acreedora."),

    # OBL-022: Remitir objeción a la acreedora en 2 DHB
    (None, "CAN-OBL-022", "can-cecoban-gateway", "NO_CUBIERTO",
     "No existe la remisión de la objeción a la institución acreedora vía el Mecanismo.",
     "Requiere el Gateway (SLA 2 DHB) + el lado acreedora reactivo que responde en 3 DHB adicionales (US-022)."),

    # OBL-023: Transferir Prestaciones Laborales (corte 17:00 DHB)
    (None, "CAN-OBL-023", "core-banking", "PARCIAL",
     "Santander dispersa nómina; la mecánica de abono a la cuenta existe.",
     "Falta el monitor con corte 17:00:00 (mismo DHB / DHB siguiente), la excepción Art. 75 (cargar CANs antes de transferir el remanente) y el calendario DHB."),
]

CECOBAN_INTEGRATION_SEED = [
    # Auth
    ("cecoban-auth-endpoint", "auth", "Endpoint autenticación", "/security/token", "POST · devuelve JWT · Content-Type: application/json"),
    ("cecoban-auth-method", "auth", "Método autenticación", "POST /security/token {clientId, clientSecret}", "Credenciales entregadas por CECOBAN via KeyPass"),
    ("cecoban-jwt-expiry", "auth", "Vigencia JWT", "900 segundos (15 min)", "La institución debe renovar antes de expiración"),
    ("cecoban-jwt-header", "auth", "Header JWT en REST", "Authorization: Bearer {accessToken}", "Nunca incluir JWT en logs"),
    ("cecoban-jwt-kafka", "auth", "JWT en Kafka", "SASL/OAUTHBEARER — mismo token de /security/token", "Se renueva automáticamente por el adaptador"),
    ("cecoban-credentials-channel", "auth", "Canal entrega credenciales", "KeyPass (canal seguro CECOBAN)", "Client ID + Client Secret por ambiente: Simulador y Producción"),
    # API REST
    ("cecoban-api-endpoint", "api_rest", "Endpoint API único", "POST /api/can/v1/operaciones", "Único endpoint — código de op identificado por contenido JSON"),
    ("cecoban-api-port", "api_rest", "Puerto HTTPS", "TCP/443", "TLS 1.3 obligatorio"),
    ("cecoban-api-tls", "api_rest", "Versión TLS", "TLS 1.3", "Aplica a HTTPS y a Kafka"),
    ("cecoban-api-format", "api_rest", "Formato de mensajes", "JSON / UTF-8", "ISO 8601 CDMX para fechas — sin zona horaria ni offset UTC"),
    ("cecoban-api-docs", "api_rest", "Documentación", "/api-docs (Scalar/OpenAPI)", "Acceso vía browser con JWT"),
    ("cecoban-ack-format", "api_rest", "Formato ACK", "{ uuid, timestamp, status: ACCEPTED|REJECTED|ERROR, errors: [] }", "ACK síncrono — confirma recepción técnica, no conclusión funcional"),
    ("cecoban-codes-bank-sends", "api_rest", "Códigos que envía el banco via REST", "C50 C51 C52 C54 C55 C56 C58", "C53 y C57 son generados por CECOBAN — nunca enviados por la institución"),
    ("cecoban-codes-cecoban-generates", "api_rest", "Códigos generados por CECOBAN", "C53 C57", "Entregados exclusivamente via Kafka a las instituciones"),
    # Kafka
    ("cecoban-kafka-port", "kafka", "Puerto Kafka", "TCP/9093", "TLS 1.3 + SASL/OAUTHBEARER"),
    ("cecoban-kafka-security-protocol", "kafka", "Protocolo seguridad Kafka", "SASL_SSL", "bootstrap.servers en puerto 9093"),
    ("cecoban-kafka-sasl-mechanism", "kafka", "Mecanismo SASL Kafka", "OAUTHBEARER", "Presenta JWT obtenido de /security/token"),
    ("cecoban-kafka-auto-commit", "kafka", "Auto commit Kafka", "enable.auto.commit=false", "Commit MANUAL al completar procesamiento exitoso — crítico para trazabilidad regulatoria"),
    ("cecoban-kafka-offset-reset", "kafka", "Offset reset Kafka", "auto.offset.reset=earliest", "Garantiza que no se pierdan mensajes al reconectar"),
    ("cecoban-kafka-topic-format", "kafka", "Formato de topics", "can.<ambiente>.<institucion>.<tipo>", "Ejemplo: can.produccion.40014.c50"),
    ("cecoban-kafka-topic-notifications", "kafka", "Topic de notificaciones", "can.<ambiente>.<institucion>.notifications", "MESSAGE_RESPONSE_TIMEOUT — timeouts entre C50→C51 (30s) y C51→C52 (48h)"),
    ("cecoban-kafka-consumer-group", "kafka", "Consumer Group", "can.<ambiente>.<institucion>", "Debe mantenerse estable para conservar offsets"),
    ("cecoban-kafka-ambientes", "kafka", "Ambientes disponibles", "simulador | produccion", "Topics usan el ambiente en la segunda posición"),
    ("cecoban-kafka-processing-flow", "kafka", "Flujo de procesamiento", "RECEIVED → PROCESSING → PROCESSED → COMMIT", "No commitear si hay error — el mensaje permanece para reprocesamiento"),
    # Simulador
    ("cecoban-simulador-ip", "simulador", "IP Simulador CAN", "148.250.112.14", "IP fija — confirmar con CECOBAN si cambia para producción"),
    ("cecoban-simulador-https-port", "simulador", "Puerto HTTPS Simulador", "443/TCP", "Firewall: IP_NAT_BANCO → 148.250.112.14:443"),
    ("cecoban-simulador-kafka-port", "simulador", "Puerto Kafka Simulador", "9093/TCP", "Firewall: IP_NAT_BANCO → 148.250.112.14:9093"),
    ("cecoban-simulador-ambiente", "simulador", "Ambiente en topics Simulador", "simulador", "can.simulador.40014.c50 — etc."),
    ("cecoban-simulador-prereq", "simulador", "Prerequisito conectividad", "IP pública de salida debe estar en lista blanca CECOBAN antes de conectar", "Registrar IPs NAT con CECOBAN — sin lista blanca se rechaza aunque las credenciales sean correctas"),
    # Timeouts
    ("cecoban-timeout-c50-c51", "timeouts", "Timeout C50 → C51", "30 segundos (configuredDurationSeconds: 30)", "CECOBAN publica MESSAGE_RESPONSE_TIMEOUT en .notifications si el Banco Ordenante no responde en 30s"),
    ("cecoban-timeout-c51-c52", "timeouts", "Timeout C51 → C52", "48 horas (configuredDurationSeconds: 172800)", "Si el Banco Otorgante no envía C52 en 48h tras recibir C51"),
    ("cecoban-timeout-event-type", "timeouts", "Tipo de notificación timeout", "MESSAGE_RESPONSE_TIMEOUT", "Campo: notificationType en JSON del topic .notifications"),
    ("cecoban-timeout-status", "timeouts", "Status de timeout", "EXPIRED · reasonCode: EXPECTED_MESSAGE_NOT_RECEIVED", "Junto con originMessageCode y expectedMessageCode"),
    # Errores
    ("cecoban-error-can001", "errores", "CAN-001 (HTTP 400)", "El mensaje no contiene un JSON válido.", "Validación de formato JSON"),
    ("cecoban-error-can002", "errores", "CAN-002 (HTTP 400)", "El mensaje no cumple con el JSON Schema.", "Validar contra schema oficial de CECOBAN"),
    ("cecoban-error-can003", "errores", "CAN-003 (HTTP 400)", "El código de operación no está soportado.", "Solo C50-C58 — no C53, no C57"),
    ("cecoban-error-can004", "errores", "CAN-004 (HTTP 400)", "Faltan campos obligatorios.", "Revisar el JSON Schema del código de operación"),
    ("cecoban-error-can005", "errores", "CAN-005 (HTTP 400)", "Uno o más campos contienen un formato inválido.", "Fechas, UUIDs, CLABEs"),
    ("cecoban-error-can006", "errores", "CAN-006 (HTTP 400)", "La estructura del mensaje no corresponde al código de operación indicado.", "El JSON no aplica al código enviado"),
    ("cecoban-error-can007", "errores", "CAN-007 (HTTP 400)", "No fue posible identificar la Institución Participante.", "Verificar código de institución en el mensaje"),
    ("cecoban-error-can008", "errores", "CAN-008 (HTTP 400)", "El UUID es inválido.", "Formato UUID v4 requerido"),
    ("cecoban-error-can101", "errores", "CAN-101 (HTTP 401)", "Token de autenticación no proporcionado.", "Falta header Authorization: Bearer"),
    ("cecoban-error-can102", "errores", "CAN-102 (HTTP 401)", "Token de autenticación inválido.", "JWT corrupto o firma incorrecta"),
    ("cecoban-error-can103", "errores", "CAN-103 (HTTP 401)", "Token de autenticación expirado.", "Renovar JWT antes de expiresIn — renovar con ≥60s de anticipación"),
    ("cecoban-error-can201", "errores", "CAN-201 (HTTP 403)", "Institución no autorizada.", "La institución no está habilitada en CECOBAN"),
    ("cecoban-error-can202", "errores", "CAN-202 (HTTP 403)", "La Institución no tiene permisos para enviar ese código de operación.", "Verificar rol (Acreedora/Depositaria) y permisos"),
    ("cecoban-error-can203", "errores", "CAN-203 (HTTP 403)", "La Institución autenticada no corresponde con la indicada en el mensaje.", "Institución en JWT ≠ institución en el body"),
    ("cecoban-error-can301", "errores", "CAN-301 (HTTP 404)", "Recurso solicitado no encontrado.", "Verificar ruta y recurso"),
    ("cecoban-error-can501", "errores", "CAN-501 (HTTP 500)", "Error interno durante el procesamiento de la solicitud.", "Reintentar con backoff — alertar si persiste"),
    ("cecoban-error-can502", "errores", "CAN-502 (HTTP 500)", "No fue posible generar el acuse de recepción.", "Reintentar — si persiste, abrir incidente con CECOBAN"),
]

CAN_FLOWS_SEED = [
    # id, numero, nombre, descripcion, rol, sla, pasos(JSON), user_stories(JSON)
    ("FLOW-CAN-001", 1, "Solicitud CAN Interbancario (nuevo)",
     "Santander otorga un CAN a un nominado cuya cuenta de nómina está en otro banco.",
     "ACREEDORA", "C-51 ≤ 30 s · C-52 ≤ 48 h",
     '[{"code":"C-50","path":"Acreedora → Cecoban","desc":"Solicita info de la Cuenta Ordenante (CURP, RFC, CLABE)"},'
     '{"code":"C-50","path":"Cecoban → Ordenante","desc":"Asigna UUID y retransmite la solicitud"},'
     '{"code":"C-51","path":"Ordenante → Cecoban","desc":"Responde info del nominado + abonos 6 meses"},'
     '{"code":"C-51","path":"Cecoban → Acreedora","desc":"Retransmite la respuesta al otorgante"},'
     '{"code":"C-52","path":"Acreedora → Cecoban","desc":"Otorgamiento: monto, tasa, plazo (mismo UUID)"},'
     '{"code":"C-53","path":"Cecoban → Ordenante","desc":"Transmite la prelación completa de CANs"}]',
     '["US-SANT-CAN-008","US-SANT-CAN-002","US-SANT-CAN-001"]'),

    ("FLOW-CAN-002", 2, "Actualización de crédito CAN",
     "Santander modifica las condiciones de un CAN existente (nuevo monto, baja, etc.).",
     "ACREEDORA", "—",
     '[{"code":"C-55","path":"Acreedora → Cecoban","desc":"Actualización con nuevo estatus (02 baja liq, 06 condiciones)"},'
     '{"code":"C-53","path":"Cecoban → Ordenante","desc":"Nueva prelación si el crédito sale del orden (estatus 02/03)"}]',
     '["US-SANT-CAN-002"]'),

    ("FLOW-CAN-003", 3, "Cancelación de domiciliación por el nominado",
     "El nominado en Santander pide que ya no se descuenten los CANs de su nómina.",
     "DEPOSITARIA", "1 DHB",
     '[{"code":"C-54","path":"Depositaria → Cecoban","desc":"Estatus 04: cancelación de domiciliación (CURP)"},'
     '{"code":"C-55","path":"Cecoban → Otorgante(s)","desc":"Notifica a bancos otorgantes con CANs activos"}]',
     '["US-SANT-CAN-018"]'),

    ("FLOW-CAN-004", 4, "Cuenta Ordenante bloqueada o cerrada",
     "Santander detecta un evento sobre la cuenta de nómina del nominado y lo reporta.",
     "DEPOSITARIA", "mismo día",
     '[{"code":"C-54 · est. 08","path":"Depositaria → Cecoban","desc":"Cuenta bloqueada"},'
     '{"code":"C-54 · est. 07","path":"Depositaria → Cecoban","desc":"Cuenta cerrada"},'
     '{"code":"C-54 · est. 05","path":"Depositaria → Cecoban","desc":"Sin depósitos de nómina ≥ 2 meses"}]',
     '["US-SANT-CAN-015"]'),

    ("FLOW-CAN-005", 5, "Cambio de Banco Ordenante (portabilidad)",
     "Un nominado con CANs activos cambia su cuenta de nómina a Santander.",
     "DEPOSITARIA", "—",
     '[{"code":"C-56","path":"Nueva Depositaria → Cecoban","desc":"Cambio de banco (CLABE anterior/nueva, RFC patrón)"},'
     '{"code":"C-57","path":"Cecoban → Otorgantes","desc":"Info de todos los CANs activos a cada banco otorgante"},'
     '{"code":"C-57","path":"Cecoban → Depositaria","desc":"Santander recibe los CANs para registrarlos"},'
     '{"code":"C-53","path":"Cecoban → Depositaria","desc":"Nueva prelación con la CLABE de Santander"}]',
     '["US-SANT-CAN-006","US-SANT-CAN-005"]'),

    ("FLOW-CAN-006", 6, "CAN Propio (misma institución)",
     "Santander otorga un CAN a un nominado que también tiene su nómina en Santander.",
     "AMBAS", "—",
     '[{"code":"C-58","path":"Santander → Cecoban","desc":"CAN propio: CURP, crédito, monto, CLABE crédito + ordenante"},'
     '{"code":"C-53","path":"Cecoban → Santander","desc":"Prelación actualizada si hay otros CANs del nominado"}]',
     '["US-SANT-CAN-001","US-SANT-CAN-003"]'),

    ("FLOW-CAN-007", 7, "Reconsulta de información del nominado",
     "Si los datos del C-51 son insuficientes o cambiaron, el otorgante vuelve a consultar (ventana 48 h).",
     "ACREEDORA", "ventana 48 h",
     '[{"code":"C-50","path":"Acreedora → Cecoban","desc":"Reconsulta: mismo CURP, nuevo folio"},'
     '{"code":"C-50","path":"Cecoban → Ordenante","desc":"Retransmite la reconsulta"},'
     '{"code":"C-51","path":"Ordenante → Cecoban","desc":"Responde con información nueva"},'
     '{"code":"C-51","path":"Cecoban → Acreedora","desc":"Retransmite la respuesta"}]',
     '["US-SANT-CAN-008"]'),
]

ARCH_COMPONENTS_SEED = [
    # id, nombre, tipo, capa, pos_x, descripcion  (nombres funcionales — oficiales por confirmar)
    ("ARCH-CH1", "Canales Digitales", "canal", "canal", 250,
     "SuperMóvil / Santander Online — solicitud, disclosure y mandato del cliente"),
    ("ARCH-CH2", "Sucursal / Call Center", "canal", "canal", 520,
     "Canales asistidos de originación y atención al cuentahabiente"),

    ("ARCH-OF1", "Orquestador Originación CAN", "onefinancial", "onefinancial", 250,
     "OneFinancial — ciclo SmartFolio, rol ACREEDORA"),
    ("ARCH-OF2", "Motor de Scoring / RDT", "onefinancial", "onefinancial", 470,
     "Evaluación crediticia (3 rondas RDT)"),
    ("ARCH-OF3", "Formalización / Firma Digital", "onefinancial", "onefinancial", 690,
     "FAD y mandato con autorización expresa CAN"),

    ("ARCH-GW", "CECOBAN Gateway", "gateway", "gateway", 300,
     "Puerta única al hub — REST + Kafka, identidad regulatoria Santander (institución 40014)"),
    ("ARCH-IDEM", "Idempotency Store (UUID)", "gateway", "gateway", 120,
     "Deduplicación por UUID+código de operación para el reprocesamiento Kafka (ADR-008)"),
    ("ARCH-VAULT", "Bóveda de Certificados / Secretos", "gateway", "gateway", 480,
     "Certificados TLS 1.3 + credenciales JWT por 5 ambientes (KeyPass)"),
    ("ARCH-RULES", "Motor de Reglas CAN", "gateway", "gateway", 660,
     "BRMS: elegibilidad, límite Comité de Riesgos, transiciones de estatus, timers de SLA, validación de mandato"),
    ("ARCH-OD", "Orquestador DEPOSITARIA", "gateway", "gateway", 900,
     "Coordina los flujos depositaria sobre el core (prelación, transferencias, objeciones)"),

    ("ARCH-CR1", "Sistema de Crédito", "core", "core", 170,
     "Alta del CAN y Clave Básica Estandarizada"),
    ("ARCH-CR2", "Motor de Pagos", "core", "core", 380,
     "SPEI y domiciliación"),
    ("ARCH-CR3", "Core Bancario", "core", "core", 610,
     "Cuentas ordenantes, saldos y movimientos"),
    ("ARCH-RM", "Read-model C-51 (CQRS)", "core", "core", 400,
     "Proyección CURP → payload C-51 precalculado para responder el SLA de 30 s (ADR-007)"),
    ("ARCH-CR4", "Aplicación de Prelación", "core", "core", 830,
     "Aplica el orden de CANs de Cecoban (C-53) e intercala los cargos no-CAN previos de Santander; resuelve saldo insuficiente (cargo parcial + arrastre). No recalcula el orden interbancario"),
    ("ARCH-CR5", "Reportería Regulatoria", "core", "core", 1060,
     "Reportes a Banxico y buró de crédito"),

    ("ARCH-EX1", "Cecoban Hub (Art. 63 Bis 3)", "externo", "externo", 470,
     "Único intermediario interbancario CAN — calcula la prelación"),
    ("ARCH-EX2", "Banxico SPEI", "externo", "externo", 250,
     "Liquidación de refinanciamiento con Clave Básica"),
    ("ARCH-EX3", "Otros Bancos (IBMs)", "externo", "externo", 720,
     "Acreedoras / depositarias que participan vía Cecoban"),
    ("ARCH-EX4", "Buró de Crédito", "externo", "externo", 1060,
     "Recibe el reporte de carácter CAN"),
]

ARCH_INTEGRATIONS_SEED = [
    # origen, destino, etiqueta, tipo (sync | async | internal)
    ("ARCH-CH1", "ARCH-OF1", "Solicitud CAN", "sync"),
    ("ARCH-CH1", "ARCH-OD", "Mandato y disclosure", "sync"),
    ("ARCH-OF1", "ARCH-OF2", "Evaluación", "internal"),
    ("ARCH-OF1", "ARCH-OF3", "Cierre y FAD", "internal"),
    ("ARCH-OF1", "ARCH-RULES", "Elegibilidad y límite", "sync"),
    ("ARCH-OF1", "ARCH-GW", "Prehabilitación C-50", "sync"),
    ("ARCH-OF1", "ARCH-CR1", "Alta CAN y Clave Básica", "sync"),
    ("ARCH-GW", "ARCH-EX1", "REST C-50/52 y Kafka C-51/53/57", "async"),
    ("ARCH-OD", "ARCH-GW", "C-51, C-54, C-56", "sync"),
    ("ARCH-OD", "ARCH-RULES", "Prelación, estatus y SLA", "sync"),
    ("ARCH-OD", "ARCH-CR3", "Cuentas ordenantes y saldos", "internal"),
    ("ARCH-OD", "ARCH-RM", "Lee payload C-51 (≤30 s)", "internal"),
    ("ARCH-RM", "ARCH-CR3", "Proyecta saldos + abonos 6m", "internal"),
    ("ARCH-GW", "ARCH-IDEM", "Dedup por UUID", "internal"),
    ("ARCH-GW", "ARCH-VAULT", "Certificados TLS + JWT", "internal"),
    ("ARCH-OD", "ARCH-CR4", "Aplicar orden de prelación", "internal"),
    ("ARCH-CR4", "ARCH-CR3", "Ejecuta cargos", "internal"),
    ("ARCH-CR1", "ARCH-CR2", "Liquidación refinanciamiento", "internal"),
    ("ARCH-CR2", "ARCH-EX2", "SPEI y Clave Básica", "sync"),
    ("ARCH-CR1", "ARCH-CR5", "Carácter CAN", "internal"),
    ("ARCH-CR5", "ARCH-EX4", "Reporte buró", "sync"),
    ("ARCH-EX1", "ARCH-EX3", "Interbancario", "async"),
]

ROADMAP_PHASES_SEED = [
    # id, numero, nombre, objetivo, duracion, user_stories(JSON), entregable, gate, escenario
    # Escenario único: optimizado con IA / Digital Brain (~17 sprints, squads en paralelo)

    ("PHASE-CAN-0-OPT", 0, "Fundaciones aceleradas",
     "DISCOVER ya resuelto por el brain (23 obligaciones + 7 flujos + spec CECOBAN reutilizados). Solo confirmar stack real del core y contrato de integración; Gateway MVP con scaffolding generado desde la spec.",
     "Sprints 1-2 (~3 sem)",
     '["US-SANT-CAN-002"]',
     "Gateway scaffolded conectado al Simulador + reglas base derivadas del brain",
     "Conexión C-50/C-51 contra el Simulador Cecoban", "optimizado"),

    ("PHASE-CAN-1-OPT", 1, "ACREEDORA — Originación (en paralelo)",
     "Originación CAN sobre OneFinancial. Corre EN PARALELO con DEPOSITARIA tras congelar el contrato del Gateway (explícito en el brain).",
     "Sprints 3-7 · paralelo con DEPOSITARIA",
     '["US-SANT-CAN-001","US-SANT-CAN-008","US-SANT-CAN-011","US-SANT-CAN-010","US-SANT-CAN-009","US-SANT-CAN-021"]',
     "Flujos 1 y 7 en QA con Clave Básica y SPEI de refinanciamiento",
     "Flujos 1 y 7 verdes · equivalence-check de originación", "optimizado"),

    ("PHASE-CAN-2-OPT", 2, "DEPOSITARIA — Recepción (en paralelo)",
     "Obligaciones depositaria sobre el core. Corre EN PARALELO con ACREEDORA; ruta crítica por su mayor carga (9 US).",
     "Sprints 3-8 · paralelo con ACREEDORA",
     '["US-SANT-CAN-015","US-SANT-CAN-016","US-SANT-CAN-003","US-SANT-CAN-004","US-SANT-CAN-007","US-SANT-CAN-017"]',
     "Identificación de cuentas + comunicación 1 DHB + prelación + SLA 17:00 + disclosure",
     "Flujos 3 y 4 + SLAs de 1 DHB validados", "optimizado"),

    ("PHASE-CAN-3-OPT", 3, "Portabilidad, objeciones y reportería",
     "Flujos interbancarios complejos y reportería. Casos de prueba generados desde el brain (QE shift-left).",
     "Sprints 8-11 (~7 sem)",
     '["US-SANT-CAN-005","US-SANT-CAN-006","US-SANT-CAN-014","US-SANT-CAN-018","US-SANT-CAN-019","US-SANT-CAN-020","US-SANT-CAN-022","US-SANT-CAN-012","US-SANT-CAN-013"]',
     "Flujos 2, 5 y 6 + lado ACREEDORA reactivo + reportes a Banxico y buró",
     "7 flujos completos + reportería certificada", "optimizado"),

    ("PHASE-CAN-4-OPT", 4, "Certificación y go-live",
     "Parallel-run y certificación con Cecoban. PISO FIJO: depende del calendario externo de Cecoban y del sign-off CNBV/Banxico — el brain no lo comprime.",
     "Sprints 12-14 (~5 sem)",
     '[]',
     "Certificación Cecoban PROD + cutover con rollback probado",
     "Certificación Cecoban PROD + sign-off regulatorio (CNBV/Banxico)", "optimizado"),

    ("PHASE-CAN-5-OPT", 5, "Hypercare y estabilización",
     "Coexistencia vigilada tras go-live: reconciliación diaria, doble on-call, monitor 17:00 y ajuste del BRMS. No se comprime por debajo de una ventana segura.",
     "Sprints 15-17 (~5 sem)",
     '[]',
     "Comparator + reconciliation dashboard activo + hypercare cerrado",
     "≥ 4-5 semanas sin P1/P2 + SLAs sostenidos", "optimizado"),
]

TEAM_ROLES_SEED = [
    # id, squad, rol, career_level, fte, responsabilidad, sme_fuente, owner
    # --- Gobierno del programa (Mixto) ---
    ("TEAM-CAN-01", "Gobierno", "Delivery Lead / Engagement Manager", "L6 Senior Manager", 1,
     "Dueño del roadmap, gates y riesgos; interfaz con el sponsor Santander y con Cecoban.",
     "IT Operating Model", "Accenture"),
    ("TEAM-CAN-02", "Gobierno", "Solution / Integration Architect", "L6 Senior Manager", 1,
     "Arquitectura maestra (ADR-001..005), diseño del Mecanismo Art. 63 Bis 3 y del Gateway.",
     "Framework — Integration Architecture", "Accenture"),
    ("TEAM-CAN-03", "Gobierno", "Product Owner / Business Analyst", "L7 Manager", 1,
     "Validación de las User Stories (el brain ya las trae con criterios), priorización por fase.",
     "Industry Banking", "Mixto"),
    ("TEAM-CAN-04", "Gobierno", "Regulatory / Banxico SME", "Advisory", 1,
     "Interpretación de las 23 obligaciones y validación regulatoria de cada solución.",
     "Regulatory/Banxico", "Banco"),

    # --- Squad Integración & Gateway (Accenture) ---
    ("TEAM-CAN-05", "Squad Integración & Gateway", "Tech Lead Integración", "L7 Manager", 1,
     "Diseño y build del CECOBAN Gateway (REST + Kafka, C-50 a C-58, JWT, idempotencia).",
     "Software Engineering", "Accenture"),
    ("TEAM-CAN-06", "Squad Integración & Gateway", "Backend Engineer (Gateway)", "L8 Consultant", 2,
     "Implementación del adaptador Cecoban (scaffolding generado desde la spec del brain), catálogo de errores y timeouts.",
     "Software Engineering", "Accenture"),

    # --- Squad ACREEDORA / OneFinancial (Accenture) ---
    ("TEAM-CAN-07", "Squad ACREEDORA (OneFinancial)", "Tech Lead OneFinancial", "L7 Manager", 1,
     "Extensión del flujo de originación (SmartFolio) para CAN interbancario.",
     "Software Engineering", "Accenture"),
    ("TEAM-CAN-08", "Squad ACREEDORA (OneFinancial)", "Backend Engineer (Java/Spring)", "L8 Consultant", 2,
     "Prehabilitación, comparativo, mandato, Clave Básica, capacidad de pago y SPEI de refinanciamiento.",
     "Software Engineering", "Accenture"),

    # --- Squad DEPOSITARIA / Core (Banco) ---
    ("TEAM-CAN-09", "Squad DEPOSITARIA (Core)", "Core Banking Lead", "L6 Senior Manager", 1,
     "Cambios en el core: cuentas ordenantes, aplicación de prelación, transferencias 17:00.",
     "Core Banking Transformation", "Banco"),
    ("TEAM-CAN-10", "Squad DEPOSITARIA (Core)", "Core Engineer", "L8 Consultant", 3,
     "Identificación de cuentas, comunicación 1 DHB, objeciones y cancelaciones.",
     "Core Banking Transformation", "Banco"),

    # --- Squad Reglas & Datos (Mixto) ---
    ("TEAM-CAN-11", "Squad Reglas & Datos", "BRMS Engineer (Motor de Reglas)", "L8 Consultant", 1,
     "Reglas de elegibilidad, límite Comité de Riesgos, estatus, timers de SLA y mandato (ya documentadas en el brain).",
     "Software Engineering", "Accenture"),
    ("TEAM-CAN-12", "Squad Reglas & Datos", "Data Engineer", "L8 Consultant", 1,
     "Modelo de datos CAN: Clave Básica, cuentas ordenantes, registro de prelación.",
     "Modern Data Platform", "Banco"),

    # --- Calidad y operación (Mixto) ---
    ("TEAM-CAN-13", "Calidad & Operación", "QE / Test Lead", "L7 Manager", 1,
     "Estrategia de pruebas, equivalence-check y parallel-run contra el Simulador Cecoban (shift-left).",
     "Quality Engineering", "Accenture"),
    ("TEAM-CAN-14", "Calidad & Operación", "Ingeniero de Automatización de Pruebas (SDET)", "L8 Consultant", 1,
     "Automatización de casos por obligación y por flujo (C-50 a C-58) generados desde el brain, pruebas de SLA.",
     "Quality Engineering", "Accenture"),
    ("TEAM-CAN-15", "Calidad & Operación", "DevOps / SRE", "L8 Consultant", 2,
     "CI/CD, observabilidad, monitor del corte 17:00 DHB y alertas de timeouts Cecoban.",
     "SRE & AIOps", "Mixto"),
    ("TEAM-CAN-16", "Calidad & Operación", "Cybersecurity", "L7 Manager", 1,
     "TLS 1.3, JWT/OAUTHBEARER, protección de PII de nómina y hardening del Gateway.",
     "Cybersecurity", "Banco"),

    # --- Roles añadidos tras la revisión de los DT ---
    ("TEAM-CAN-17", "Gobierno", "Cecoban Liaison", "L7 Manager", 1,
     "Relación con Cecoban: contrato de adhesión, certificados y whitelisting de IP por 5 ambientes, calendario de UAT y certificación. Ruta crítica externa.",
     "Framework — Integration Architecture", "Mixto"),
    ("TEAM-CAN-18", "Gobierno", "Data Privacy / Legal", "L7 Manager", 1,
     "Secreto bancario (Art. 142 LIC), LFPDPPP, validación de mandatos y del intercambio de PII de nómina (ADR-009).",
     "Cybersecurity", "Banco"),
    ("TEAM-CAN-19", "Gobierno", "PMO / Scrum Master", "L8 Consultant", 1,
     "Coordinación de los 6 squads, gestión de dependencias, ceremonias ágiles y reporte de avance.",
     "IT Operating Model", "Accenture"),
    ("TEAM-CAN-20", "Adopción & Cambio", "Business Change / Adoption Lead", "L7 Manager", 1,
     "Comunicación, capacitación de sucursal y call-center, y alineación con CONDUSEF para la adopción del CAN.",
     "Industry Banking", "Banco"),
]

TEAM_SUMMARY_SEED = [
    # id, squad, owner, fte_baseline, fte_optimizado, cambio
    ("TS-1", "Gobierno", "Mixto", 8, 7,
     "PO/BA de 2 a 1: el brain ya trae las User Stories con criterios. Incluye Cecoban Liaison, Data Privacy/Legal y PMO añadidos tras la revisión de los DT."),
    ("TS-2", "Squad Integración & Gateway", "Accenture", 4, 3,
     "Backend de 3 a 2: el Gateway arranca con scaffolding generado desde la spec CECOBAN del brain."),
    ("TS-3", "Squad ACREEDORA (OneFinancial)", "Accenture", 4, 3,
     "Backend de 3 a 2: patrón de originación reutilizado; menos build desde cero."),
    ("TS-4", "Squad DEPOSITARIA (Core)", "Banco", 4, 4,
     "Se mantiene: es la ruta crítica (9 US) y los cambios al core del banco no los acelera el brain."),
    ("TS-5", "Squad Reglas & Datos", "Mixto", 3, 2,
     "BRMS de 2 a 1: las reglas (límite, estatus, SLA, mandato) ya están documentadas en el brain."),
    ("TS-6", "Calidad & Operación", "Mixto", 6, 5,
     "SDET de 2 a 1: los casos de prueba se generan desde el brain (obligación × flujo × código de error)."),
    ("TS-7", "Adopción & Cambio", "Banco", 1, 1,
     "Se mantiene: comunicación, capacitación de sucursal/call-center y alineación CONDUSEF no las acelera el brain."),
]

OPTIMIZATION_LEVERS_SEED = [
    # id, palanca, activo_brain, impacto
    ("LEV-1", "DISCOVER ya resuelto",
     "23 obligaciones + 7 flujos + spec CECOBAN (50 params) reutilizados de un análisis previo del mismo marco CAN (Banxico)",
     "Fase 0 de ~6 a ~3 semanas; Regulatory SME pasa a spot-advisory"),
    ("LEV-2", "User Stories pre-construidas",
     "20 User Stories con brecha, sistema, gate y trazabilidad a obligación",
     "PO/BA validan en vez de redactar (2 a 1 FTE)"),
    ("LEV-3", "Scaffolding del Gateway",
     "Contrato técnico completo: endpoints, JWT, topics Kafka, mensajes C-50 a C-58, catálogo de errores",
     "El componente XL (US-002) arranca con esqueleto generado; Backend 3 a 2"),
    ("LEV-4", "Generación de pruebas (QE shift-left)",
     "Matriz obligación × flujo × código de error ya modelada",
     "Suites de prueba generadas desde el brain; SDET 2 a 1"),
    ("LEV-5", "Squads en paralelo",
     "Contrato del Gateway explícito congela el punto de integración temprano",
     "ACREEDORA y DEPOSITARIA corren concurrentes tras Fase 0"),
    ("LEV-6", "Trazabilidad de auditoría viva",
     "Obligación → brecha → US → componente → fase enlazados en el brain",
     "Elimina la matriz de cumplimiento manual para CNBV/Banxico"),
    ("LEV-7", "Reuso cross-cliente",
     "Patrón ACREEDORA / DEPOSITARIA / Gateway como activo reutilizable",
     "El 2º y 3er banco (mismo marco CAN) cuestan una fracción"),
]

ADRS_SEED = [
    ("ADR-SANT-CAN-001", "Dónde vive el orquestador CAN — arquitectura de 3 capas",
     "El cumplimiento CAN exige conectarse al Mecanismo Art. 63 Bis 3 (hub CECOBAN) tanto como institución ACREEDORA (12 obligaciones, originación en OneFinancial) como DEPOSITARIA (11 obligaciones, tocan saldos y cargos del core). La conexión al hub usa la identidad regulatoria de Santander (institución 40014, credenciales KeyPass). OneFinancial es SaaS Accenture de originación — no es sistema Santander.",
     "Separar en 3 capas: (1) CECOBAN Gateway — puerta única al hub, componente dedicado bajo identidad e operación regulatoria de Santander, construido sobre el stack OneFinancial (Spring Boot 3.x + Kafka SASL/OAUTHBEARER) por velocidad de delivery pero desplegado en el perímetro Santander; (2) Orquestación ACREEDORA — en OneFinancial, que ya coordina el ciclo SmartFolio de originación; (3) Orquestación DEPOSITARIA — en core-banking/payments-engine, porque prelación (OBL-016), transferencia 17:00 DHB (OBL-023) y comunicación de saldos en 1 DHB (OBL-015) tocan saldos directamente y tienen SLAs regulatorios que no pueden vivir fuera del core.",
     "El Gateway como puerta única evita que OneFinancial retenga credenciales regulatorias de Santander y permite intercambiar OneFinancial sin perder conectividad CECOBAN. El costo es un componente más y un contrato claro Gateway↔consumidores. Rechazado 'todo en OneFinancial': acoplaría los flujos depositaria (que no tienen que ver con originación) a la plataforma de originación y pondría la identidad regulatoria de Santander en manos del SaaS. Rechazado 'todo en payments-engine': está en SCAFFOLD (stack/extensibilidad desconocidos) y forzaría a OneFinancial a llamar al core en cada consulta CAN.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-002", "Frontera y ubicación de la prelación de cargos (OBL-016)",
     "Riesgo de duplicar o contradecir el cálculo de prelación de Cecoban. La prelación de cargos requiere acceso a saldos de la Cuenta Ordenante y al registro de CANs.",
     "FRONTERA: Cecoban CALCULA y transmite el orden de los CANs entre bancos (C-53) — el banco NUNCA lo recalcula. El banco DEPOSITARIA APLICA ese orden e (a) intercala sus propios cargos no-CAN previos que Cecoban no conoce (Art. 22 Bis 1 I-e), y (b) resuelve la ejecución ante saldo insuficiente (cargo parcial + arrastre). Vive en core-banking por acceso directo a saldos; el orden de Cecoban se persiste en la entidad can_prelacion (ADR-006).",
     "Elimina la contradicción 'banco calcula vs. Cecoban calcula': el orden interbancario es de Cecoban; la fusión con no-CAN y la ejecución son del banco. Acopla la aplicación al SoR (aceptable por acceso a saldos).",
     "PROPUESTO"),
    ("ADR-SANT-CAN-003", "Generación y almacenamiento de Clave Básica Estandarizada",
     "La Clave Básica Estandarizada (OBL-009) debe asignarse al originar el CAN y usarse en SPEI. Formato per Circular 14/2017.",
     "[DATO-REQUERIDO] — Generar en loans al momento de originar el CAN. Almacenar como campo nuevo en tabla de créditos.",
     "Inmutable una vez asignada. Debe ser transmitida al Mecanismo CAN y al payments-engine para SPEI.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-004", "Persistencia del Mandato Digital OBL-005 y OBL-018",
     "Los mandatos digitales deben tener trazabilidad regulatoria (timestamp, canal, versión del texto, hash del PDF).",
     "[DATO-REQUERIDO] — Confirmar si Santander tiene infraestructura de firma electrónica regulatoria existente.",
     "Sin infraestructura existente: requiere nueva. Con infraestructura existente: integrar y añadir campos CAN.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-005", "Motor de Reglas CAN (BRMS) como servicio de decisión compartido",
     "CAN es regulación viva — la circular se actualiza (vigente: compilado 6/2025). Las reglas de decisión del banco (elegibilidad para ofrecer CAN, límite del Comité de Riesgos %, transiciones de estatus 01-08, timers de SLA 1/2/5 DHB y corte 17:00, validación del mandato) están hoy dispersas o embebidas en cada sistema. Cambiar una regla implicaría redesplegar core.",
     "Centralizar las reglas de decisión del banco en un Motor de Reglas CAN (BRMS) consultado por el Orquestador ACREEDORA (OneFinancial) y el Orquestador DEPOSITARIA (core). NO incluye la prelación: el orden de cargos lo calcula exclusivamente Cecoban (C-53) y el banco solo lo aplica en 'Aplicación de Prelación'.",
     "Reglas auditables y modificables sin redesplegar core cuando cambie la circular; separación clara entre 'qué decide el banco' (BRMS) y 'qué calcula Cecoban' (prelación). Costo: un componente de decisión más y gobierno de versionado de reglas. Frontera crítica: no duplicar el cálculo de prelación de Cecoban.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-006", "Modelo de datos CAN",
     "CAN exige persistir estructuras que hoy no existen: el orden de prelación que transmite Cecoban (C-53), la marca de Cuenta Ordenante, los mandatos con trazabilidad y el calendario de días hábiles bancarios. Sin ellas, ARCH-CR4 aplica un orden que no persiste y los SLA en DHB se calculan mal.",
     "Crear: (1) can_prelacion — persiste el C-53 (num_prelación, banco_otorgante, num_crédito, tipo, monto_periódico, CLABE_crédito, CLABE_ordenante), llave CURP+CLABE, con uuid/timestamp/versión del último C-53. (2) cuentas_ordenantes — marca de cuenta que recibe Prestaciones Laborales. (3) mandatos — tipo, medio (escrito/electrónico/huella), hash, versión de texto, timestamp, revocable. (4) calendario_dhb — días inhábiles Banxico + zona CDMX para todos los SLA. Aclaración: la Clave Básica Estandarizada (Circular 14/2017) es un identificador distinto de la CLABE de la cuenta del crédito (C-52 campo 20).",
     "El canal puede mostrar la prelación (US-007); los SLA en DHB se calculan bien; los mandatos son auditables y revocables. Requiere modelado de datos en core Santander (por confirmar en discovery técnico).",
     "PROPUESTO"),
    ("ADR-SANT-CAN-007", "Read-model C-51 para el SLA de 30 segundos",
     "Como DEPOSITARIA, Santander debe responder el C-51 (confirmación de Cuenta Ordenante + saldos + abonos de 6 meses + CANs vigentes + periodicidad) en 30 segundos. Consultar el core en vivo bajo ese SLA produce rechazos por timeout (causa 36). Era el riesgo técnico principal del análisis original y se había perdido.",
     "Construir una proyección CQRS (read-model) con clave CURP → payload C-51 precalculado, actualizada por eventos del core (abonos de nómina, alta/baja de CANs). El Gateway/Orquestador DEPOSITARIA lee del read-model, no del core transaccional.",
     "Cumple el SLA de 30 s de forma sostenida bajo carga. Costo: consistencia eventual (definir ventana máxima de rezago) y un componente de proyección + su reconciliación.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-008", "Resiliencia del canal Kafka CECOBAN",
     "El canal asíncrono (C-53, C-57 solo llegan por Kafka; auto.commit=false con reprocesamiento) exige garantías que hoy no están modeladas: idempotencia, manejo de mensajes envenenados, reintentos y consumo de las notificaciones de timeout.",
     "Componentes obligatorios: (1) idempotency store por UUID+código de operación (evita doble procesamiento al reprocesar). (2) Dead-letter queue para poison-messages tras N reintentos. (3) Circuit breaker + reintentos con backoff exponencial para errores CAN-501/502. (4) Consumidor del topic .notifications para MESSAGE_RESPONSE_TIMEOUT (C-50→C-51 30s, C-51→C-52 48h) que dispara abandono/reintento.",
     "Trazabilidad regulatoria garantizada (ningún mensaje se pierde ni se procesa dos veces). Costo: infraestructura de idempotencia + DLQ + monitoreo.",
     "PROPUESTO"),
    ("ADR-SANT-CAN-009", "Soberanía y PII de nómina en OneFinancial",
     "La orquestación ACREEDORA en OneFinancial (SaaS Accenture) procesa el payload C-51 con PII sensible de clientes de OTRO banco (CURP, RFC, 6 meses de ingresos). Esto toca el secreto bancario (Art. 142 LIC) y la LFPDPPP. El ADR-001 protegió la identidad regulatoria pero no la residencia del dato.",
     "Definir residencia y perímetro: el payload C-51 con PII se procesa dentro del perímetro regulatorio de Santander, no en infraestructura multi-tenant del SaaS. Minimización (solo los campos necesarios para el scoring), cifrado en tránsito y reposo, y retención acotada. Aclarar en el contrato OneFinancial ↔ Santander la frontera de despliegue del Gateway.",
     "Cumplimiento Art. 142 LIC + LFPDPPP y menor riesgo de exfiltración. Costo: posible despliegue dedicado del componente ACREEDORA en perímetro Santander en vez de SaaS puro.",
     "PROPUESTO"),
]


# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

def build_brain():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    cur.executescript(DDL)

    # Meta
    meta = [
        ("brain_name", "CAN Brain — Santander México"),
        ("project", "can"),
        ("client", "Santander México"),
        ("version", "0.4.0"),
        ("built_at", datetime.now().isoformat()),
        ("obligations_total", "23"),
        ("regulatory_source", "Circular 3/2012 Banxico compilado 6/2025"),
        ("phase", "DISCOVER + DESIGN"),
        ("onefinancial_platform", "SaaS Accenture de originación de nómina — 7 micros Spring Boot analizados"),
        ("onefinancial_stack", "Spring Boot 3.x + Java 17/21 + SQL Server + Kafka + Redis + Eureka"),
        ("onefinancial_risk", "products-config-service: Spring Boot 1.5.1 + Java 8 (EOL) — requiere upgrade"),
        ("onefinancial_micros_negocio", "4 (products, offers, risks, formalization)"),
        ("onefinancial_micros_infra", "3 (utils, log, config)"),
        ("etb_capabilities_total", "12"),
        ("etb_cubierto", "3"),
        ("etb_parcial", "8"),
        ("etb_brecha", "1"),
        ("gap_critico", "CECOBAN: ningún banco tiene implementado el Mecanismo Art. 63 Bis 3 — capacidad nueva universal"),
        ("user_stories_total", "22"),
        ("brechas_total", "22"),
        ("orquestador_decision", "3 capas: CECOBAN Gateway (Santander) + orquestación ACREEDORA (OneFinancial) + orquestación DEPOSITARIA (core-banking) — ADR-SANT-CAN-001"),
        ("cecoban_gateway", "Puerta única al hub bajo identidad regulatoria Santander (institución 40014), stack OneFinancial"),
        ("can_flows_total", "7"),
        ("can_flows_source", "Documento de Entendimiento CAN v4.2 (GT de CAN - ABM · Cecoban)"),
        ("arch_components_total", "20"),
        ("arch_rules_engine", "Motor de Reglas CAN (BRMS) — decisión compartida ACREEDORA + DEPOSITARIA; ADR-SANT-CAN-005"),
        ("roadmap_phases_total", "6"),
        ("roadmap_escenario", "optimizado con IA / Digital Brain (escenario único)"),
        ("roadmap_duracion", "~17 sprints (~34 semanas · ~8 meses) · squads en paralelo · incluye hypercare"),
        ("roadmap_deadline", "[DATO-REQUERIDO] — extraer de la circular"),
        ("team_fte_total", "25"),
        ("team_ahr", "[PLACEHOLDER] — tarifas y costeo vía Pricing & Commercial Modeler, no en este brain"),
        ("cecoban_api_endpoint", "POST /api/can/v1/operaciones"),
        ("cecoban_auth_endpoint", "POST /security/token"),
        ("cecoban_https_port", "TCP/443"),
        ("cecoban_kafka_port", "TCP/9093"),
        ("cecoban_topic_format", "can.<ambiente>.<institucion>.<tipo>"),
        ("cecoban_consumer_group_format", "can.<ambiente>.<institucion>"),
        ("cecoban_jwt_expiry_seconds", "900"),
        ("cecoban_tls_version", "TLS 1.3"),
        ("cecoban_kafka_auth", "SASL/OAUTHBEARER"),
        ("cecoban_simulador_ip", "148.250.112.14"),
        ("cecoban_error_catalog_count", "16"),
        ("cecoban_spec_source", "DET-430801-CANO v1.2 + DE CAN v4.2 + Guía Simulador CAN v1.2"),
        ("arquitectura_canal", "dual: REST (banco→CECOBAN) + Kafka (CECOBAN→banco)"),
    ]
    cur.executemany("INSERT OR REPLACE INTO brain_meta VALUES (?,?)", meta)

    # Obligations
    cur.executemany(
        "INSERT OR REPLACE INTO obligations VALUES (?,?,?,?,?,?,?,?,?,?)",
        OBLIGATIONS_SEED
    )
    cur.executemany(
        "INSERT INTO obligations_fts(id,articulo,descripcion,tipo,rol_aplicable) VALUES (?,?,?,?,?)",
        [(r[0], r[1], r[3], r[4], r[8]) for r in OBLIGATIONS_SEED]
    )

    # Brechas
    cur.executemany(
        "INSERT OR REPLACE INTO brechas VALUES (?,?,?,?,?,?,?,?)",
        BRECHAS_SEED
    )
    cur.executemany(
        "INSERT INTO brechas_fts(id,descripcion,capacidad_faltante,sistema_afectado) VALUES (?,?,?,?)",
        [(r[0], r[3], r[5], r[4]) for r in BRECHAS_SEED]
    )

    # User Stories
    cur.executemany(
        "INSERT OR REPLACE INTO user_stories VALUES (?,?,?,?,?,?,?,?,?,?)",
        USER_STORIES_SEED
    )

    # ADRs
    cur.executemany(
        "INSERT OR REPLACE INTO adrs VALUES (?,?,?,?,?,?)",
        ADRS_SEED
    )

    # CECOBAN Integration technical spec
    cur.executemany(
        "INSERT OR REPLACE INTO cecoban_integration VALUES (?,?,?,?,?)",
        CECOBAN_INTEGRATION_SEED
    )

    # CAN end-to-end flows (DE CAN v4.2)
    cur.executemany(
        "INSERT OR REPLACE INTO can_flows VALUES (?,?,?,?,?,?,?,?)",
        CAN_FLOWS_SEED
    )

    # Architecture — functional components + integrations
    cur.executemany(
        "INSERT OR REPLACE INTO arch_components VALUES (?,?,?,?,?,?)",
        ARCH_COMPONENTS_SEED
    )
    cur.executemany(
        "INSERT INTO arch_integrations (origen, destino, etiqueta, tipo) VALUES (?,?,?,?)",
        ARCH_INTEGRATIONS_SEED
    )

    # Roadmap de implementación + equipo de trabajo (baseline + optimizado)
    cur.executemany(
        "INSERT OR REPLACE INTO roadmap_phases VALUES (?,?,?,?,?,?,?,?,?)",
        ROADMAP_PHASES_SEED
    )
    cur.executemany(
        "INSERT OR REPLACE INTO team_roles VALUES (?,?,?,?,?,?,?,?)",
        TEAM_ROLES_SEED
    )
    cur.executemany(
        "INSERT OR REPLACE INTO team_summary VALUES (?,?,?,?,?,?)",
        TEAM_SUMMARY_SEED
    )
    cur.executemany(
        "INSERT OR REPLACE INTO optimization_levers VALUES (?,?,?,?)",
        OPTIMIZATION_LEVERS_SEED
    )

    # Microservices (7 Spring Boot micros analizados)
    cur.executemany(
        "INSERT OR REPLACE INTO microservices VALUES (?,?,?,?,?,?,?,?,?,?,?,?)",
        MICROSERVICES_SEED
    )

    # ETB Banking capabilities CAN
    cur.executemany(
        "INSERT OR REPLACE INTO etb_capabilities VALUES (?,?,?,?,?,?,?,?)",
        ETB_CAPABILITIES_SEED
    )

    # Obligation coverage matrix
    for row in OBLIGATION_COVERAGE_SEED:
        cur.execute(
            "INSERT INTO obligation_coverage (obligation_id, microservicio_id, cobertura, evidencia, gap_detectado) VALUES (?,?,?,?,?)",
            (row[1], row[2], row[3], row[4], row[5])
        )

    con.commit()
    con.close()
    print(f"CAN Brain construido: {DB_PATH}")
    show_status()


def show_status():
    con = sqlite3.connect(DB_PATH)
    cur = con.cursor()
    print("\n=== CAN Brain — Santander México ===")
    for row in cur.execute("SELECT key, value FROM brain_meta ORDER BY key"):
        print(f"  {row[0]}: {row[1]}")
    obl_total = cur.execute("SELECT COUNT(*) FROM obligations").fetchone()[0]
    obl_criticas = cur.execute("SELECT COUNT(*) FROM obligations WHERE riesgo_sancion='critico'").fetchone()[0]
    brechas_abiertas = cur.execute("SELECT COUNT(*) FROM brechas WHERE estado='ABIERTA'").fetchone()[0]
    brechas_criticas = cur.execute("SELECT COUNT(*) FROM brechas WHERE criticidad='CRITICA' AND estado='ABIERTA'").fetchone()[0]
    us_total = cur.execute("SELECT COUNT(*) FROM user_stories").fetchone()[0]
    adrs_total = cur.execute("SELECT COUNT(*) FROM adrs").fetchone()[0]
    cecoban_total = cur.execute("SELECT COUNT(*) FROM cecoban_integration").fetchone()[0]
    flows_total = cur.execute("SELECT COUNT(*) FROM can_flows").fetchone()[0]
    arch_c = cur.execute("SELECT COUNT(*) FROM arch_components").fetchone()[0]
    arch_i = cur.execute("SELECT COUNT(*) FROM arch_integrations").fetchone()[0]
    phases = cur.execute("SELECT COUNT(*) FROM roadmap_phases").fetchone()[0]
    team_fte = cur.execute("SELECT COALESCE(SUM(fte),0) FROM team_roles").fetchone()[0]
    team_n = cur.execute("SELECT COUNT(*) FROM team_roles").fetchone()[0]
    ms_total = cur.execute("SELECT COUNT(*) FROM microservices").fetchone()[0]
    ms_negocio = cur.execute("SELECT COUNT(*) FROM microservices WHERE rol='NEGOCIO'").fetchone()[0]
    ms_infra = cur.execute("SELECT COUNT(*) FROM microservices WHERE rol='INFRAESTRUCTURA'").fetchone()[0]
    etb_total = cur.execute("SELECT COUNT(*) FROM etb_capabilities").fetchone()[0]
    etb_cubierto = cur.execute("SELECT COUNT(*) FROM etb_capabilities WHERE estado_can='CUBIERTO'").fetchone()[0]
    etb_parcial = cur.execute("SELECT COUNT(*) FROM etb_capabilities WHERE estado_can='PARCIAL'").fetchone()[0]
    etb_brecha = cur.execute("SELECT COUNT(*) FROM etb_capabilities WHERE estado_can='BRECHA'").fetchone()[0]
    cov_cubierto = cur.execute("SELECT COUNT(*) FROM obligation_coverage WHERE cobertura='CUBIERTO'").fetchone()[0]
    cov_parcial = cur.execute("SELECT COUNT(*) FROM obligation_coverage WHERE cobertura='PARCIAL'").fetchone()[0]
    cov_no_cubierto = cur.execute("SELECT COUNT(*) FROM obligation_coverage WHERE cobertura='NO_CUBIERTO'").fetchone()[0]
    cecoban_cats = cur.execute("SELECT categoria, COUNT(*) FROM cecoban_integration GROUP BY categoria ORDER BY categoria").fetchall()
    print(f"\n  Obligaciones: {obl_total} total · {obl_criticas} críticas")
    print(f"  Brechas abiertas: {brechas_abiertas} · {brechas_criticas} críticas")
    print(f"  User Stories: {us_total}")
    print(f"  ADRs: {adrs_total}")
    print(f"\n  Microservicios analizados: {ms_total} ({ms_negocio} negocio · {ms_infra} infraestructura)")
    print(f"  ETB Banking capabilities: {etb_total} total · {etb_cubierto} CUBIERTO · {etb_parcial} PARCIAL · {etb_brecha} BRECHA")
    print(f"  Obligation coverage: {cov_cubierto} CUBIERTO · {cov_parcial} PARCIAL · {cov_no_cubierto} NO_CUBIERTO")
    print(f"\n  Flujos end-to-end (DE CAN v4.2): {flows_total}")
    print(f"  Arquitectura: {arch_c} componentes · {arch_i} integraciones")
    print(f"  Roadmap: {phases} fases · Equipo: {team_n} roles · {team_fte:.0f} FTE")
    print(f"\n  CECOBAN Integration: {cecoban_total} parámetros técnicos")
    for cat, n in cecoban_cats:
        print(f"    · {cat}: {n}")
    con.close()


if __name__ == "__main__":
    import sys
    if len(sys.argv) > 1 and sys.argv[1] == "status":
        show_status()
    else:
        build_brain()
