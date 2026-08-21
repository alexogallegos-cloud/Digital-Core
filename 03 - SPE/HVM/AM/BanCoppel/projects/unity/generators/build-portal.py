#!/usr/bin/env python3
"""
Unity R4 — Portal Generator
Genera portal/index.html desde digital-brain/brain.db
SPE-AM-001 · BanCoppel · Regla AM-8: portal/*.html siempre generado, nunca hand-authored

Uso:
    python generators/build-portal.py
    python generators/build-portal.py --brain path/to/brain.db --out portal/index.html
"""

import sqlite3, json, argparse, html, math
from datetime import date, datetime
from pathlib import Path

# Orientaciones del cubo hero para cada vista (face hacia la cámara)
CUBE_ORIENTATIONS = [
    ("productos",   "rotateX(-70deg) rotateY(-20deg)"),
    ("sistemas",    "rotateX(-10deg) rotateY(-5deg)"),
    ("capacidades", "rotateX(-10deg) rotateY(-80deg)"),
]

ROOT   = Path(__file__).parent.parent
BRAIN  = ROOT / "digital-brain" / "brain.db"
OUTPUT = ROOT / "portal" / "index.html"

GOLIVE = date(2027, 1, 15)

KNOWN_STATUSES = {"productivo", "live", "building", "backlog", "planned", "retired", "sin-definir", "retracted"}

# ── Vista Producto — Capabilities de Negocio (DT-Productos v1.1.0 · 2026-08-20) ─
# Fuente autoritativa: dt/dt-productos.md § "Capacidades de Negocio (ETB)"
# sem: "crit" = 🔴 crítico, "warn" = 🟡 at risk, "ok" = 🟢
CAPABILITIES_VP = [
    {"label": "Emisión TDC",        "system": "SmartVista",            "sem": "warn", "note": "Brechas funcionales pendientes de cierre"},
    {"label": "Originación Digital","system": "APOLO",                 "sem": "warn", "note": "Rendimiento en producción por confirmar"},
    {"label": "Canal Digital",      "system": "App / Sucursal / Contact Center", "sem": "crit", "note": "Dos canales sin plan de entrega confirmado"},
    {"label": "Cobranza",           "system": "Cobranza Direccionada", "sem": "warn", "note": "Conflicto en ventana de pruebas de noviembre"},
    {"label": "Integración",        "system": "Integraciones",         "sem": "warn", "note": "Mapa de dependencias entre sistemas incompleto"},
    {"label": "Reportes Regulatorios", "system": "CNBV / Banxico",     "sem": "warn", "note": "Alcance regulatorio pendiente de validación"},
]

# KPIs de la Vista Producto — disponibles ahora desde brain.db o DT; gaps marcados
KPIS_VP = [
    {"label": "Funcionalidades",  "value": "~116-129",  "sub": "Requerimientos comprometidos",     "gap": False},
    {"label": "Críticas",         "value": "46",         "sub": "De entrega obligatoria",           "gap": False},
    {"label": "Áreas en riesgo",  "value": "5 / 6",      "sub": "1 crítica · 4 en seguimiento",    "gap": False},
    {"label": "Avance",           "value": "21.19%",     "sub": "vs 60.58% esperado al 17-ago",    "gap": False},
    {"label": "Clientes objetivo","value": "—",          "sub": "Pendiente de confirmar",           "gap": True},
    {"label": "SLA servicio",     "value": "—",          "sub": "Pendiente de confirmar",           "gap": True},
]

# Bloqueos de negocio activos — perspectiva de valor al cliente, sin jerga técnica
BLOCKERS_VP = [
    {"text": "Contact center sin proveedor contratado",                          "cap": "Canal Digital",        "owner": "BanCoppel",    "level": "crit"},
    {"text": "Sistema de sucursales bloqueado por dependencia de integraciones", "cap": "Canal Digital",        "owner": "Accenture",    "level": "warn"},
    {"text": "Rendimiento de originación digital sin plan de mejora firmado",    "cap": "Originación Digital",  "owner": "Appwhere",     "level": "warn"},
    {"text": "Mapa de dependencias entre sistemas sin consolidar",               "cap": "Integración",          "owner": "Accenture",    "level": "warn"},
    {"text": "Pruebas de seguridad programadas en ventana crítica de integración","cap": "Cobranza",            "owner": "BanCoppel",    "level": "warn"},
]

# ── Narrativas funcionales por fase — Cadena de Valor TDC ────────────────────
# Fuente: DT-Productos v1.2.0 · DT-Compliance · Marco regulatorio MX
# Cada entrada: industria (texto), kpis (lista de {k,v}), brechas (lista de {txt,level})
PHASE_NARRATIVES = {
    "originacion": {
        "industria": (
            "La originación es el primer momento de relación del cliente con el producto. "
            "En México, la CONDUSEF exige entregar el Resumen de Contrato con el CAT (Costo Anual Total) "
            "calculado conforme a la Circular 9/2019 de Banxico, y el banco debe registrar el contrato "
            "de adhesión en el RECA antes de usarlo. El flujo incluye validación KYC, consulta al Buró de "
            "Crédito, scoring crediticio (CES) y alta en el sistema de gestión de tarjetas. "
            "La LFPIORPI exige que el banco aplique controles PLD desde la solicitud."
        ),
        "kpis": [
            {"k": "Tasa de aprobación",         "v": "30-55% (varía por segmento)"},
            {"k": "Tiempo de resolución digital","v": "< 5 minutos"},
            {"k": "Activación a 30 días",        "v": "> 70%"},
            {"k": "CAT comunicado correctamente","v": "100% (CONDUSEF)"},
        ],
        "brechas": [
            {"txt": "Pantallas intermedias del flujo de solicitud APOLO sin mapear", "level": "warn"},
            {"txt": "Clientes objetivo (volumen / segmento) sin definir — GAP-VP-001", "level": "crit"},
            {"txt": "Latencia 9 seg en producción — sin plan de mejora confirmado",  "level": "crit"},
            {"txt": "Contrato CONDUSEF (RECA): fecha de registro no confirmada",      "level": "warn"},
        ],
    },
    "emision": {
        "industria": (
            "La emisión convierte una cuenta aprobada en un instrumento de pago. El sistema de gestión "
            "de tarjetas arma el lote de personalización, un módulo generador produce el archivo cifrado "
            "con PGP y lo transfiere al maquilador vía protocolo seguro (Connect-Direct o SFTP). "
            "El HSM (Hardware Security Module) genera y custodia las llaves por tarjeta — control "
            "mandatorio PCI-DSS Req. 3.6. El maquilador embosa el plástico, instala el chip y envía "
            "la tarjeta al cliente. Tiempo estándar en México: 5-10 días hábiles desde aprobación."
        ),
        "kpis": [
            {"k": "Aprobación → tarjeta en mano", "v": "5-10 días hábiles"},
            {"k": "Tasa de defectos de maquila",  "v": "< 0.1%"},
            {"k": "Activación post-maquila 30d",  "v": "> 70%"},
            {"k": "Integridad de lote (PCI)",      "v": "100%"},
        ],
        "brechas": [
            {"txt": "Connect-Direct no en producción — depósito manual por tickets",    "level": "crit"},
            {"txt": "Maquilador único no definido formalmente — riesgo de capacidad",  "level": "warn"},
            {"txt": "Inconsistencia de maquiladores en documentación (3-5 proveedores)","level": "warn"},
            {"txt": "SLA de tiempo aprobación→tarjeta en mano: sin definir — GAP-VP-002","level": "warn"},
        ],
    },
    "activacion": {
        "industria": (
            "La CONDUSEF exige que ninguna tarjeta esté activa al momento de entregarse al cliente: "
            "el portador debe activarla explícitamente, lo que constituye una segunda confirmación "
            "del consentimiento. La industria ofrece cuatro canales: App móvil (preferente en productos "
            "digitales), IVR, sucursal y ATM. Para tarjeta digital, la activación incluye la provisión "
            "del token de pago en billeteras digitales (Apple Pay / Google Pay) mediante el protocolo "
            "EMVCo 3DS del emisor."
        ),
        "kpis": [
            {"k": "Tasa de activación a 30 días", "v": "> 70%"},
            {"k": "Tasa de activación a 7 días",  "v": "> 40% (digital-first)"},
            {"k": "Tiempo al primer uso",          "v": "< 48 horas"},
            {"k": "Intentos fallidos",             "v": "< 5%"},
        ],
        "brechas": [
            {"txt": "Activación por ATM: Customer Journey documentado pero sin User Story en R4",    "level": "warn"},
            {"txt": "Activación por sucursal (SIWEB): Journey documentado pero sin User Story en R4","level": "warn"},
            {"txt": "Provisión de token digital (Apple Pay / Google Pay): no mencionada en R4",      "level": "warn"},
        ],
    },
    "autorizacion": {
        "industria": (
            "La autorización ocurre en tiempo real para cada intento de compra. El flujo ISO 8583 "
            "lleva el mensaje del POS o e-commerce al emisor vía la red adquirente. El motor de "
            "autorización (SmartVista SVFE) aplica las reglas del producto — límite disponible, "
            "validez de tarjeta, CVV2, control de fraude — y devuelve aprobación o rechazo en "
            "milisegundos. Visa penaliza emisores con alta tasa de declinación injustificada. "
            "La CNBV exige reportar eventos de fraude y mantener controles activos de riesgo "
            "transaccional (3DS v2 para e-commerce es estándar de mercado)."
        ),
        "kpis": [
            {"k": "Tasa de autorización",      "v": "> 85% (Visa: > 90% para emisores maduros)"},
            {"k": "Latencia P99",              "v": "< 2,000 ms"},
            {"k": "Tasa de fraude",            "v": "< 0.05% (benchmark CNBV)"},
            {"k": "Disponibilidad 24×7",       "v": "> 99.9%"},
        ],
        "brechas": [
            {"txt": "Contradicción abierta sobre SVFM (módulo fraude): licenciado vs. no licenciado", "level": "crit"},
            {"txt": "SLA de autorización (latencia P99): sin definir en contrato R4 — GAP-VP-002",    "level": "warn"},
            {"txt": "3DS v2 para e-commerce: sin evidencia de implementación en R4",                  "level": "warn"},
            {"txt": "Segunda US de cierre de análisis: 16-oct — overlap con inicio SIT 15-oct",       "level": "warn"},
        ],
    },
    "transacciones": {
        "industria": (
            "Esta fase cubre toda la operación del portador sobre el producto activo: consultas de "
            "saldo, movimientos y estado de cuenta. La CONDUSEF exige estado de cuenta gratuito en "
            "formato regulatorio, con al menos 45 días entre fecha de corte y fecha límite de pago. "
            "Los emisores deben habilitar al menos App, IVR y sucursal. Las compras diferidas "
            "(MSI/MCI — Meses Sin/Con Intereses) son reguladas: el estado de cuenta debe mostrar "
            "el desglose de parcializaciones activas, el cargo mensual y el saldo pendiente."
        ),
        "kpis": [
            {"k": "Adopción canal digital",          "v": "> 60% portadores con consulta digital/mes"},
            {"k": "Latencia consulta P95",           "v": "< 2 segundos"},
            {"k": "Entrega estado de cuenta a tiempo","v": "100% (CONDUSEF)"},
            {"k": "Reclamaciones por estado de cuenta","v": "< 0.1% de cuentas"},
        ],
        "brechas": [
            {"txt": "Estado de cuenta formato CONDUSEF: sin evidencia de validación en R4",   "level": "warn"},
            {"txt": "MSI/MCI en estado de cuenta digital: sin User Story específica confirmada","level": "warn"},
            {"txt": "Consulta via ATM: no en scope R4",                                        "level": "warn"},
        ],
    },
    "pagos": {
        "industria": (
            "El pago es la fase de mayor impacto en la relación cliente-banco y la principal causa "
            "de reclamaciones CONDUSEF si falla. El regulador exige al menos dos mecanismos de pago "
            "sin costo, fecha límite ≥ 45 días después del corte, y que el pago mínimo esté "
            "claramente definido. Los canales estándar en México incluyen: SPEI, ventanilla de sucursal, "
            "domiciliación / cargo automático, CoDi, tiendas de conveniencia y banca en línea. "
            "La acreditación del pago debe reflejarse en el saldo disponible en minutos (SPEI)."
        ),
        "kpis": [
            {"k": "Tasa de pago a tiempo",           "v": "> 80%"},
            {"k": "Acreditación SPEI",               "v": "< 5 minutos"},
            {"k": "Portadores con domiciliación",    "v": "> 20%"},
            {"k": "Reclamaciones CONDUSEF por pagos","v": "< 0.05% de cuentas"},
        ],
        "brechas": [
            {"txt": "Pago en ventanilla: bloqueado por dependencia de SIWEB — sin alternativa confirmada","level": "crit"},
            {"txt": "Domiciliación / cargo automático: sin User Story en R4",                             "level": "warn"},
            {"txt": "Pago CoDi: sin cobertura en R4 (canal Banxico en crecimiento)",                      "level": "warn"},
            {"txt": "SLA de acreditación SPEI: sin definir en R4 — GAP-VP-002",                           "level": "warn"},
        ],
    },
    "contabilidad": {
        "industria": (
            "La contabilidad y conciliación es invisible para el cliente pero crítica para el regulador. "
            "La CNBV — vía la Circular Única de Bancos, Anexos 33 y 36 — exige que cada transacción "
            "del portador quede registrada en el libro contable central (core bancario) el mismo día. "
            "El posting diario genera los asientos contables en el procesador de tarjetas (SmartVista), "
            "que se transfieren al core vía archivo SVXP. La conciliación garantiza que el total de "
            "transacciones autorizadas coincida con los movimientos contabilizados. La NIF C-16 exige "
            "estimar y registrar mensualmente la provisión por pérdida esperada sobre la cartera."
        ),
        "kpis": [
            {"k": "Conciliación D+0",              "v": "> 99.5%"},
            {"k": "Breaks sin resolver > 24h",     "v": "0 (objetivo CNBV)"},
            {"k": "Latencia de posting",           "v": "< 4 horas post-cierre"},
            {"k": "Compliance reportería CNBV",    "v": "100% — multas automáticas"},
        ],
        "brechas": [
            {"txt": "Interfaz SVXP→PISA no construida — prioridad PreGame pendiente",                 "level": "crit"},
            {"txt": "Guía contable formal (TRNTs del Producto 4900) no entregada",                    "level": "crit"},
            {"txt": "Nuevo tipo conciliación SOC (req. 16-nov-2023): sin plan en R4",                 "level": "warn"},
            {"txt": "Provisión NIF C-16: sin evidencia de diseño en R4",                              "level": "warn"},
        ],
    },
    "cobranza": {
        "industria": (
            "La cobranza cierra el ciclo de crédito y determina la salud de la cartera. "
            "La CONDUSEF prohíbe llamadas fuera de 8am-9pm y exige ofrecer reestructura antes de "
            "reportar al Buró. La CNBV requiere reportar cartera vencida al SISEC mensualmente y "
            "registrar la provisión contable (NIF C-16). La gestión opera en cuatro capas de aging: "
            "preventiva (1-29 días), temprana (30-60), cartera vencida (61-120) y litigio/castigo "
            "(> 120 días). El reporte al Buró se activa al día 30 de atraso — el Producto 4900 "
            "tendrá sus primeros reportes al Buró dentro de los primeros 60 días post go-live."
        ),
        "kpis": [
            {"k": "NPL ratio (cartera vencida > 90d)","v": "< 4% (TDC masiva)"},
            {"k": "Recuperación temprana",             "v": "> 60% en < 30 días de contacto"},
            {"k": "Contactabilidad digital",           "v": "> 40%"},
            {"k": "Reclamaciones CONDUSEF cobranza",   "v": "Tolerancia cero"},
        ],
        "brechas": [
            {"txt": "37-50 User Stories de Cobranza Direccionada no incorporadas al inventario R4","level": "crit"},
            {"txt": "Pentest nov 15-20 congela el único ambiente de SIT de Cobranza",              "level": "crit"},
            {"txt": "Reporte al Buró de Crédito (SISEC): sin evidencia de diseño en R4",           "level": "warn"},
            {"txt": "Proceso de reestructura de deuda: sin alcance en R4 (CONDUSEF lo exige)",     "level": "warn"},
        ],
    },
}

# ── IT Capabilities — Vista Capacidades IT (3 bloques ejecutivos) ──────────────────
# Fuente: dt-plan-director.md § Capacidades IT + RAID + minutas (corte 2026-08-20)
IT_CAP_META = {
    "testing":        {"name": "Testing y QA",         "group": "Engineering",  "sem": "warn", "note": "Conflicto pentest nov 15–20 con ventana SIT · CAT sin plan de pruebas posible", "mat_cur": 2, "mat_tgt": 4, "owner": "BanCoppel QA Lead",              "next_action": "Resolver conflicto ventana pentest vs SIT",              "next_due": "05-sep"},
    "devops":         {"name": "DevOps / CI-CD",        "group": "Engineering",  "sem": "warn", "note": "Pipelines en configuración · ambientación SIT pendiente de confirmar", "mat_cur": 2, "mat_tgt": 4, "owner": "ACN DevOps Lead",                "next_action": "Confirmar ambientación SIT con BanCoppel Infra",         "next_due": "15-sep"},
    "arquitectura":   {"name": "Arquitectura",          "group": "Delivery",     "sem": "warn", "note": "Mapa de dependencias entre sistemas sin consolidar · APIs sin inventario completo", "mat_cur": 2, "mat_tgt": 4, "owner": "Ramses Santos",                  "next_action": "Completar inventario APIs e integraciones R4",              "next_due": "15-sep"},
    "interop":        {"name": "Interoperabilidad",     "group": "Delivery",     "sem": "crit", "note": "APIs SmartVista sin fecha bloquean SIWEB · 18 integraciones sin mapa validado", "mat_cur": 1, "mat_tgt": 4, "owner": "J.A. Valverde / BPC",            "next_action": "Obtener fecha entrega APIs SmartVista de BPC",              "next_due": "29-ago"},
    "ambientacion":   {"name": "Ambientación",          "group": "Delivery",     "sem": "warn", "note": "Entorno SIT al 15-oct por confirmar · deuda de configuración canal CAT", "mat_cur": 2, "mat_tgt": 4, "owner": "BanCoppel Infra",                "next_action": "Confirmar entorno SIT listo al 15-oct",                    "next_due": "15-sep"},
    "seguridad":      {"name": "Seguridad",             "group": "Delivery",     "sem": "warn", "note": "Pentest nov 15–20 en conflicto con SIT · PCI-DSS v4.0 en scope SmartVista", "mat_cur": 2, "mat_tgt": 4, "owner": "Mercedes Espinosa",              "next_action": "Definir ventana pentest no conflictiva con SIT",            "next_due": "05-sep"},
    "observabilidad": {"name": "Observabilidad",        "group": "Operations",   "sem": "warn", "note": "SLOs definidos por capability · alerting y dashboards pendientes de activar", "mat_cur": 2, "mat_tgt": 4, "owner": "ACN SRE Lead",                   "next_action": "Activar alerting y dashboards en Dynatrace",                "next_due": "15-oct"},
    "change":         {"name": "Change Management",     "group": "Operations",   "sem": "warn", "note": "Plan de change para 3M tarjetahabientes sin ejecutar · comunicación pendiente", "mat_cur": 1, "mat_tgt": 3, "owner": "BanCoppel PMO",                  "next_action": "Ejecutar plan comunicación 3M tarjetahabientes",          "next_due": "31-oct"},
    "release":        {"name": "Release Management",    "group": "Operations",   "sem": "warn", "note": "Go-Live 15-ene-2027 con margen mínimo — SIT debe cerrar el 15-dic", "mat_cur": 2, "mat_tgt": 4, "owner": "BanCoppel PMO / ACN",            "next_action": "Confirmar fecha cierre SIT 15-dic en CAB",                 "next_due": "01-sep"},
    "vendor":         {"name": "Vendor / SIAM",         "group": "Operations",   "sem": "crit", "note": "CAT sin proveedor contratado (RISK-001) · DPP y BYU0039 abiertos con BPC", "mat_cur": 1, "mat_tgt": 4, "owner": "BanCoppel Adquisiciones",        "next_action": "Contratar proveedor CAT — RISK-001 crítico",                "next_due": "31-ago"},
    "compliance":     {"name": "Compliance",            "group": "Operations",   "sem": "warn", "note": "CNBV Art.76 LIC · hallazgos APO_F01 y SMA_F01 abiertos · Bajaware en decomiso", "mat_cur": 2, "mat_tgt": 4, "owner": "Mercedes Espinosa / Legal",      "next_action": "Cerrar hallazgos APO_F01 y SMA_F01 CNBV",                  "next_due": "30-sep"},
    "data":           {"name": "Data / Migración",      "group": "Data",         "sem": "warn", "note": "Golden Record en Informix sin plan de carga inicial a ATLAS · Exodus Ola 6 en 2029", "mat_cur": 1, "mat_tgt": 3, "owner": "BanCoppel Data / ACN MDP",       "next_action": "Definir plan carga inicial Golden Record a ATLAS",          "next_due": "30-sep"},
}

# Para la cara del cubo (lista agrupada sin semáforo)
IT_CAPS = {
    "Engineering": ["Testing", "DevOps"],
    "Delivery":    ["Arquitectura", "Interoperabilidad", "Ambientación", "Seguridad"],
    "Operations":  ["Observabilidad", "Change", "Release", "Vendor Mgmt", "Compliance"],
    "Data":        ["Data / Migración"],
}

KPIS_VC = [
    {"value": "13",      "label": "Capacidades IT",         "sub": "2 críticas · 11 en seguimiento",      "gap": False},
    {"value": "2",       "label": "Capacidades críticas",    "sub": "Interoperabilidad · Vendor / SIAM",   "gap": True},
    {"value": "18",      "label": "Integraciones R4",        "sub": "9 nuevas · 9 modificadas",               "gap": False},
    {"value": "1",       "label": "Proveedor sin contratar", "sub": "CAT / ICAT — RISK-001",                  "gap": True},
    {"value": "~ene-27", "label": "Go-Live objetivo",        "sub": "15-ene-2027 · margen mínimo",        "gap": False},
]

BLOCKERS_VC = [
    {"level": "crit", "text": "Vendor SIAM: CAT sin proveedor — 12 User Stories Must sin owner técnico",       "sys": "Vendor / SIAM",      "owner": "BanCoppel · Due: 31-ago-2026"},
    {"level": "crit", "text": "Interoperabilidad: APIs SmartVista BPC sin fecha de entrega bloquean SIWEB",              "sys": "Interoperabilidad",  "owner": "Accenture"},
    {"level": "warn", "text": "Testing: pentest nov 15–20 en conflicto con ventana SIT · CAT sin plan posible", "sys": "Testing y QA",       "owner": "BanCoppel"},
    {"level": "warn", "text": "Compliance: hallazgos APO_F01 y SMA_F01 — documentación CNBV desactualizada",   "sys": "Compliance",         "owner": "BanCoppel · Mercedes Espinosa"},
    {"level": "warn", "text": "Data: Golden Record en Informix sin plan de carga inicial a ATLAS (sep-2026 target)",     "sys": "Data / Migración",  "owner": "BanCoppel"},
]

# ── Digital Twins config (no hay tabla en el brain aún) ───────────────────────
DT_GROUPS = [
    {
        "label": "Programa y Gestión",
        "twins": [
            {"ico": "📋", "ver": "v1.0.0", "name": "Plan Director",
             "desc": "Visión transversal del programa, KPI framework, dashboard RAG cruzado, 8 acciones críticas, anti-silos.",
             "chips": [("yellow","KPIs"),("blue","RAG"),("blue","76 User Stories")],
             "warn": True},
            {"ico": "🏛️", "ver": "v1.0.0", "name": "Gobierno",
             "desc": "Estructura de comités, RACI del programa, protocolo de escalación, RAID owners y frecuencias.",
             "chips": [("blue","Comités"),("blue","RACI"),("blue","RAID")]},
            {"ico": "👥", "ver": "v2.0.0", "name": "Equipo",
             "desc": "Roster por componente, rotación crítica dic-ene, capacidad vs demanda, plan de Change Management.",
             "chips": [("yellow","Change Mgmt"),("red","Vacante Lead")], "warn": True},
            {"ico": "⚠️", "ver": "v1.0.0", "name": "Riesgos",
             "desc": "18 riesgos RAID, 9 alta prioridad, mitigaciones y owners, RISK-001 CAT sin contrato.",
             "chips": [("red","9 Alta"),("yellow","8 Media"),("blue","RAID")], "crit": True},
            {"ico": "📅", "ver": "v1.1.0", "name": "Cronograma",
             "desc": "Hitos R4 con semáforo, SIT oct, Code Freeze dic, Go-Live 15-ene-2027, fechas en riesgo.",
             "chips": [("yellow","At Risk"),("blue","Go-Live ene-2027")], "warn": True},
            {"ico": "🏪", "ver": "v1.0.0", "name": "Vendors",
             "desc": "8 vendors, modelo SIAM, CAT sin contratar, BYU0039, DPP, maquiladores AppWhere.",
             "chips": [("red","CAT urgente"),("blue","SIAM"),("blue","8 vendors")], "crit": True},
        ],
    },
    {
        "label": "Delivery Técnico",
        "twins": [
            {"ico": "💳", "ver": "v1.0.0", "name": "SmartVista BPC",
             "desc": "58 User Stories de diseño, 14 DTMs, cobertura PreGame, gaps críticos DPP, BYU0039 y OCG manual.",
             "chips": [("blue","58 User Stories"),("red","5 gaps críticos")], "warn": True},
            {"ico": "🚀", "ver": "v1.1.0", "name": "APOLO",
             "desc": "37 User Stories de originación digital, 10 fases, 13 sprints backend, integración crítica con SmartVista (HDU-20).",
             "chips": [("blue","37 User Stories"),("yellow","Tensión fechas")], "warn": True},
            {"ico": "🧪", "ver": "v1.0.0", "name": "SIT / UAT",
             "desc": "Plan de pruebas por capability, conflicto pentest nov 15-20, triage, criterios entrada y salida.",
             "chips": [("yellow","Conflicto pentest"),("blue","14 caps")]},
            {"ico": "📦", "ver": "v1.0.0", "name": "Productos",
             "desc": "Catálogo P4900, componentes R4 por track, alcance confirmado, User Stories por canal.",
             "chips": [("blue","P4900"),("blue","5 tracks"),("blue","76 USs")]},
        ],
    },
    {
        "label": "Arquitectura y Operación",
        "twins": [
            {"ico": "🔀", "ver": "v1.0.0", "name": "Coexistencia",
             "desc": "Routing Informix ↔ Unity por canal y producto, tipos MONEY, migration fate, parallel run.",
             "chips": [("blue","Informix"),("blue","Transact"),("blue","11 rutas")]},
            {"ico": "📊", "ver": "v1.0.0", "name": "SLO y Observabilidad",
             "desc": "SLIs y SLOs por capability, criterios cuantitativos de cutover, business observability, trazabilidad.",
             "chips": [("blue","SLOs"),("blue","Cutover criteria")]},
            {"ico": "⚖️", "ver": "v1.0.0", "name": "Compliance",
             "desc": "CNBV Art.76 LIC, PCI-DSS v4.0 scope SmartVista, CONDUSEF, timeline regulatorio R4.",
             "chips": [("blue","CNBV"),("blue","PCI-DSS v4.0"),("blue","CONDUSEF")]},
            {"ico": "🛡️", "ver": "v1.0.0", "name": "Ops Readiness",
             "desc": "PRR por capability, runbooks, modelo on-call, DRP, rollback plan, handoff AMS Reinvention.",
             "chips": [("blue","PRR"),("blue","Runbooks"),("blue","DRP")]},
        ],
    },
]

# ── Helpers ───────────────────────────────────────────────────────────────────

def h(s):
    return html.escape(str(s)) if s else ""

def days_to_golive():
    return (GOLIVE - date.today()).days

def badge_status(status):
    map_ = {
        "productivo": ("b-tg", "prod"),
        "live":       ("b-tg", "prod"),
        "building":   ("b-tr", "build"),
        "backlog":    ("b-bl", "backlog"),
        "planned":    ("b-bl", "backlog"),
        "retired":    ("b-vc", "ret"),
    }
    cls, label = map_.get(status, ("b-bl", status or ""))
    return f'<span class="cfbadge {cls}">{label}</span>'

def rag_dot(color):
    return {"red": "🔴", "yellow": "🟡", "green": "🟢"}.get(color, "⚪")

def rag_css(color):
    return {"red": "r", "yellow": "y", "green": "g"}.get(color, "")

def risk_severity_css(impact, probability):
    if impact in ("critical", "high") and probability == "high":
        return ""          # rcard default (rojo)
    return "med"           # rcard med (amarillo)

def milestone_tag(status):
    map_ = {
        "pending":  ("pend", "Pendiente"),
        "at_risk":  ("risk", "At Risk"),
        "achieved": ("ok",   "Logrado"),
        "missed":   ("risk", "Vencido"),
    }
    cls, label = map_.get(status, ("pend", status or ""))
    return f'<span class="ntag {cls}">{label}</span>'

# ── Queries ───────────────────────────────────────────────────────────────────

def load_data(db_path):
    con = sqlite3.connect(db_path)
    con.row_factory = sqlite3.Row

    # Productos + releases
    products = con.execute(
        "SELECT * FROM products ORDER BY id"
    ).fetchall()
    releases = con.execute(
        "SELECT * FROM product_releases ORDER BY release_label, id"
    ).fetchall()

    # Sistemas (program_components)
    components = con.execute(
        "SELECT * FROM program_components ORDER BY type, name"
    ).fetchall()

    # RAG por track
    track_rags = con.execute(
        "SELECT * FROM track_rag ORDER BY rag_color, track"
    ).fetchall()

    # KPIs dinámicos
    total_hus = con.execute(
        "SELECT COALESCE(SUM(hu_total),0) FROM track_rag"
    ).fetchone()[0]
    high_risks = con.execute(
        "SELECT COUNT(*) FROM risks WHERE probability='high' AND status='open' AND id IS NOT NULL"
    ).fetchone()[0]

    # Riesgos (alta prioridad abiertos primero — excluye filas con id NULL)
    risks = con.execute("""
        SELECT r.*, pc.name AS component_name
        FROM risks r
        LEFT JOIN program_components pc ON r.component_id = pc.id
        WHERE r.status IN ('open','escalated') AND r.id IS NOT NULL
        ORDER BY
            CASE r.impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END,
            CASE r.probability WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END
        LIMIT 9
    """).fetchall()

    # Acciones abiertas del Plan Director (raid_issues)
    actions = []
    try:
        actions = con.execute("""
            SELECT * FROM raid_issues
            WHERE status IN ('open','in_progress')
            ORDER BY
                COALESCE(breach, 0) DESC,
                CASE severity WHEN 'critical' THEN 0 WHEN 'high' THEN 1 ELSE 2 END,
                due_date
        """).fetchall()
    except Exception:
        pass

    # Milestones
    milestones = con.execute(
        "SELECT * FROM milestones ORDER BY target_date"
    ).fetchall()

    # Pasos de la cadena de valor (lifecycle_phase_steps) — para lifecycle-p4900.html
    phase_steps_raw = []
    try:
        phase_steps_raw = con.execute(
            "SELECT phase_id, step_n, paso, sistema, us_id, us_title FROM lifecycle_phase_steps ORDER BY phase_id, step_n"
        ).fetchall()
    except Exception:
        pass  # tabla aún no existe en brains viejos
    phase_steps = {}
    for r in phase_steps_raw:
        pid = r["phase_id"]
        if pid not in phase_steps:
            phase_steps[pid] = []
        phase_steps[pid].append({
            "n": r["step_n"], "paso": r["paso"],
            "sistema": r["sistema"], "us": r["us_id"] or "—",
            "us_title": r["us_title"] or ""
        })

    # Derivar blockers y KPIs desde brain.db antes de cerrar la conexión
    derived_blockers, derived_kpis = derive_blockers_and_kpis(con)

    con.close()
    return {
        "products":         products,
        "releases":         releases,
        "components":       components,
        "track_rags":       track_rags,
        "total_hus":        total_hus,
        "high_risks":       high_risks,
        "risks":            risks,
        "actions":          actions,
        "milestones":       milestones,
        "phase_steps":      phase_steps,
        "derived_blockers": derived_blockers,
        "derived_kpis":     derived_kpis,
    }

# ── Derivación dinámica desde brain.db ───────────────────────────────────────

def derive_blockers_and_kpis(con):
    """Deriva blockers y KPIs desde brain.db en tiempo de generación.

    Retorna (blockers, kpis) donde:
    - blockers: lista de dicts con level, text, sys, cap, owner, raid_id, mitigation
      (tanto 'sys' como 'cap' apuntan al nombre del sistema para compatibilidad con las 3 vistas)
    - kpis: dict con conteos del programa (total_us, must, should, could, etc.)
    """
    # ── Mapa system_id → nombre legible ─────────────────────────────────────
    try:
        sys_names = {r[0]: r[1] for r in con.execute(
            "SELECT id, name FROM program_systems"
        ).fetchall()}
    except Exception:
        sys_names = {}

    # ── Blockers — riesgos critical/high abiertos ────────────────────────────
    blockers = []
    try:
        for r in con.execute("""
            SELECT raid_id, system_id, impact, description, mitigation, owner, status
            FROM risks
            WHERE impact IN ('critical', 'high') AND status != 'closed'
            ORDER BY
                CASE impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 END,
                system_id
        """).fetchall():
            raid_id, system_id, impact, description, mitigation, owner, status = r
            sys_name = sys_names.get(system_id, system_id or "Programa")
            blockers.append({
                "level":      "crit" if impact == "critical" else "warn",
                "text":       description or raid_id or "",
                "sys":        sys_name,
                "cap":        sys_name,   # alias para render_view_productos (usa blk["cap"])
                "owner":      owner or "Sin asignar",
                "raid_id":    raid_id or "",
                "mitigation": mitigation or "",
            })
    except Exception:
        pass

    # ── KPIs — conteos del programa ──────────────────────────────────────────
    total_us, must, should, could, wont = 0, 0, 0, 0, 0
    try:
        total_us = con.execute("SELECT COUNT(*) FROM user_stories_inventory").fetchone()[0]
        for moscow, cnt in con.execute(
            "SELECT moscow, COUNT(*) FROM user_stories_inventory GROUP BY moscow"
        ).fetchall():
            if moscow == "must":     must   = cnt
            elif moscow == "should": should = cnt
            elif moscow == "could":  could  = cnt
            elif moscow == "wont":   wont   = cnt
    except Exception:
        pass

    total_risks, critical_risks, high_risks_cnt = 0, 0, 0
    try:
        total_risks = con.execute(
            "SELECT COUNT(*) FROM risks WHERE status != 'closed' AND id IS NOT NULL"
        ).fetchone()[0]
        for impact, cnt in con.execute(
            "SELECT impact, COUNT(*) FROM risks WHERE status != 'closed' AND id IS NOT NULL GROUP BY impact"
        ).fetchall():
            if impact == "critical": critical_risks = cnt
            elif impact == "high":   high_risks_cnt = cnt
    except Exception:
        pass

    red_sys, yellow_sys, green_sys, total_sys = 0, 0, 0, 0
    try:
        total_sys = con.execute(
            "SELECT COUNT(*) FROM program_systems WHERE exclude_from_portal=0"
        ).fetchone()[0]
        for sts, cnt in con.execute(
            "SELECT sdlc_status, COUNT(*) FROM program_systems WHERE exclude_from_portal=0 GROUP BY sdlc_status"
        ).fetchall():
            if sts == "red":     red_sys    = cnt
            elif sts == "yellow": yellow_sys = cnt
            elif sts == "green":  green_sys  = cnt
    except Exception:
        pass

    total_integrations = 0
    try:
        total_integrations = con.execute(
            "SELECT COUNT(*) FROM r4_integrations"
        ).fetchone()[0]
    except Exception:
        pass

    total_itcaps, crit_itcaps = 0, 0
    try:
        total_itcaps = con.execute("SELECT COUNT(*) FROM it_capabilities").fetchone()[0]
        crit_itcaps  = con.execute(
            "SELECT COUNT(*) FROM it_capabilities WHERE sem='crit'"
        ).fetchone()[0]
    except Exception:
        pass

    breach_count = 0
    try:
        breach_count = con.execute(
            "SELECT COUNT(*) FROM raid_issues WHERE breach=1"
        ).fetchone()[0]
    except Exception:
        pass

    kpis = {
        "total_us": total_us, "must": must, "should": should,
        "could": could, "wont": wont,
        "total_risks": total_risks,
        "critical_risks": critical_risks, "high_risks": high_risks_cnt,
        "red_sys": red_sys, "yellow_sys": yellow_sys, "green_sys": green_sys,
        "total_sys": total_sys,
        "total_integrations": total_integrations,
        "total_itcaps": total_itcaps, "crit_itcaps": crit_itcaps,
        "breach_count": breach_count,
    }

    return blockers, kpis


# ── Render parciales ──────────────────────────────────────────────────────────

EXCLUDED_STATUSES = {"sin-definir", "undefined", "tbd", "backlog", "planned", "retracted"}

def _static_cube(variant, top="", front="", right=""):
    """Cubo decorativo estático con contenido real en la cara destacada (p=top, s=front, c=right)."""
    return f"""<div class="vw-scene">
          <div class="cube3d vw-static vw-static-{variant}">
            <div class="cf cf-top"><div class="cf-title">Productos</div>{top}</div>
            <div class="cf cf-front"><div class="cf-title">Sistemas</div>{front}</div>
            <div class="cf cf-right"><div class="cf-title">Capacidades IT</div>{right}</div>
            <div class="cf cf-back"><div class="cf-title">Unity</div></div>
            <div class="cf cf-left"></div>
            <div class="cf cf-bot"></div>
          </div>
        </div>"""


def render_view_productos(products, releases, cube_top_content="", cube_img=None,
                          _blockers=None, _kpis=None):
    """Vista Productos: capabilities de negocio con semáforo, KPIs y bloqueos activos. Fuente: DT-Productos."""
    # Capabilities semáforo
    sem_icon = {"crit": "🔴", "warn": "🟡", "ok": "🟢"}
    caps_html = ""
    for cap in CAPABILITIES_VP:
        icon = sem_icon.get(cap["sem"], "⚪")
        caps_html += (
            f'<div class="vp-cap {cap["sem"]}">'
            f'<div class="vp-caplabel">{icon} {h(cap["label"])}</div>'
            f'<div class="vp-capsys">{h(cap["system"])}</div>'
            f'<div class="vp-capnote">{h(cap["note"])}</div>'
            f'</div>'
        )

    # KPIs — derivados de brain.db si están disponibles, fallback a constante
    if _kpis is not None:
        _must   = _kpis["must"]
        _should = _kpis["should"]
        _could  = _kpis["could"]
        _risks  = _kpis["total_risks"]
        _crit   = _kpis["critical_risks"]
        _high   = _kpis["high_risks"]
        kpis_list = [
            {"label": "User Stories",      "value": str(_kpis["total_us"]),
             "sub": f"{_must} Must Have · {_should + _could} Should/Could", "gap": False},
            {"label": "Must Have",         "value": str(_must),
             "sub": "De entrega obligatoria",                                "gap": False},
            {"label": "Riesgos abiertos",  "value": str(_risks),
             "sub": f"{_crit} críticos · {_high} altos",                    "gap": False},
            {"label": "Avance",            "value": "21.19%",
             "sub": "vs 60.58% esperado al 17-ago",                         "gap": False},
            {"label": "Clientes objetivo", "value": "—",
             "sub": "Pendiente de confirmar",                                "gap": True},
            {"label": "SLA servicio",      "value": "—",
             "sub": "Pendiente de confirmar",                                "gap": True},
        ]
    else:
        kpis_list = KPIS_VP

    kpis_html = ""
    for kpi in kpis_list:
        gap_cls = " gap" if kpi["gap"] else ""
        kpis_html += (
            f'<div class="vp-kpi{gap_cls}">'
            f'<div class="vp-kval">{h(kpi["value"])}</div>'
            f'<div class="vp-klabel">{h(kpi["label"])}</div>'
            f'<div class="vp-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # Bloqueos — derivados de brain.db si están disponibles, fallback a constante
    blockers_src = _blockers[:5] if _blockers is not None else BLOCKERS_VP
    blocks_html = ""
    for blk in blockers_src:
        blocks_html += (
            f'<div class="vp-block {blk["level"]}">'
            f'<div style="flex:1">'
            f'<div class="vp-btext">{h(blk["text"])}</div>'
            f'<div class="vp-bsub">{h(blk["cap"])} · {h(blk["owner"])}</div>'
            f'</div>'
            f'</div>'
        )

    cube_el = (f'<img src="{cube_img}" alt="Productos" class="vw-cube-img">'
               if cube_img else _static_cube("p", top=cube_top_content))
    return f"""
        <div class="wrap">
        <div class="vw-grid reveal">
          <div class="vw-cube-wrap">
            {cube_el}
          </div>
          <div class="vw-body">
            <div class="kick">Vista · Productos</div>
            <div class="vp-h2-row">
              <h2 class="vw-h2 vwc-p">Eje Rector del Programa</h2>
              <a href="lifecycle-p4900.html" class="vp-h2-link">Ver cadena de valor <span class="vp-arr">→</span></a>
            </div>
            <p class="vw-desc">Visión integral de la Tarjeta de Crédito desde el negocio. Consolida el estado de madurez por capacidad, los indicadores de avance y los bloqueos que hoy frenan el valor al cliente.</p>
            <div class="vp-section-label">Capacidades de Negocio</div>
            <div class="vp-caps">{caps_html}</div>
            <div class="vp-section-label">KPIs del Programa</div>
            <div class="vp-kpis">{kpis_html}</div>
            <div class="vp-section-label">Bloqueos Activos al Valor</div>
            <div class="vp-blocks">{blocks_html}</div>
          </div>
        </div>
        </div>"""


# ── Vista Sistemas — constantes ejecutivas ────────────────────────────────────
SYSTEM_META_VS = {
    "smartvista": {"name": "SmartVista BPC",        "type": "Core · Procesador de tarjetas", "note": "5 DTMs con gap crítico — DPP, BYU0039 y OCG sin plan de cierre"},
    "apolo":      {"name": "APOLO",                 "type": "Core · Originación digital",    "note": "Tensión de fechas — backend cierra 15-oct, go-live 15-ene"},
    "app":        {"name": "App / Canal Digital",   "type": "Channel · AppMóvil",            "note": "6 User Stories Must cierran en noviembre, posterior al inicio de SIT"},
    "cat":        {"name": "CAT — Contact Center",  "type": "Channel · IBR + ICAT",          "note": "Proveedor sin contratar — 12 User Stories Must sin owner técnico"},
    "siweb":      {"name": "SIWEB — Sucursales",    "type": "Channel · Ventanilla",          "note": "Bloqueado por APIs de SmartVista sin fecha de entrega confirmada"},
    "cobranza":   {"name": "Cobranza Direccionada", "type": "Enabler · Cross-canal",         "note": "Track opaco — 45 User Stories sin compartir · RISK-UNITY-R06 VENCIDO · ACT-005 en breach"},
}

KPIS_VS = [
    {"value": "79",     "label": "User Stories",           "sub": "46 Must Have · 33 Should / Could",  "gap": False},
    {"value": "18",     "label": "Integraciones",          "sub": "9 nuevas · 9 modificadas",           "gap": False},
    {"value": "58",     "label": "User Stories de diseño",         "sub": "SmartVista · App · CAT · SIWEB",    "gap": False},
    {"value": "5",      "label": "DTMs con gap crítico",   "sub": "DPP · BYU0039 · OCG y 2 más",      "gap": True},
    {"value": "21.19%", "label": "Avance de desarrollo",   "sub": "vs 60.58% esperado al 17-ago",      "gap": True},
]

BLOCKERS_VS = [
    {"level": "crit", "text": "CAT sin proveedor contratado — 12 User Stories Must sin owner técnico",            "sys": "CAT",              "owner": "BanCoppel · Due: 31-ago-2026"},
    {"level": "warn", "text": "App: 6 User Stories Must cierran en noviembre, posterior al inicio de SIT",        "sys": "App / Canal Digital", "owner": "Accenture · Due: 01-oct-2026"},
    {"level": "warn", "text": "SIWEB bloqueado por APIs de SmartVista BPC sin fecha de entrega confirmada",        "sys": "SIWEB",            "owner": "Accenture"},
    {"level": "warn", "text": "5 DTMs SmartVista sin plan de cierre — DPP, BYU0039 y OCG en estado Gap",          "sys": "SmartVista BPC",   "owner": "BPC Banking Technologies"},
]

RAG_MATRIX_VS = {
    "smartvista": {
        "avance":        ("yellow", "22 USs · plan ajustado a oct"),
        "diseno":        ("red",    "5 DTMs con gap: DPP, BYU0039, OCG"),
        "integraciones": ("yellow", "7 integraciones, 4 nuevas"),
        "riesgos":       ("yellow", "BYU0039 severity High abierto"),
        "pruebas":       ("yellow", "SIT 15-oct · sin plan pentest propio"),
    },
    "apolo": {
        "avance":        ("yellow", "22 USs · 13 sprints backend"),
        "diseno":        ("green",  "37 User Stories completas · 17 BBs"),
        "integraciones": ("yellow", "HDU-20 integración crítica con SV"),
        "riesgos":       ("yellow", "Tensión fechas: 15-ene vs 22-ene"),
        "pruebas":       ("yellow", "8 critical breakers ADP por cerrar"),
    },
    "app": {
        "avance":        ("yellow", "18 USs · 6 Must cierran noviembre"),
        "diseno":        ("green",  "20 User Stories cubiertas"),
        "integraciones": ("yellow", "4 integraciones · 2 nuevas"),
        "riesgos":       ("yellow", "6 USs Must posteriores al inicio SIT"),
        "pruebas":       ("yellow", "Pentest nov 15-20 en conflicto SIT"),
    },
    "cat": {
        "avance":        ("red",    "12 USs Must sin owner técnico"),
        "diseno":        ("red",    "12 User Stories sin proveedor asignado"),
        "integraciones": ("red",    "7 integraciones sin responsable"),
        "riesgos":       ("red",    "RISK-001 · proveedor sin contratar"),
        "pruebas":       ("red",    "Sin plan de pruebas posible"),
    },
    "siweb": {
        "avance":        ("yellow", "5 USs · bloqueadas por APIs SV"),
        "diseno":        ("green",  "5 User Stories cubiertas"),
        "integraciones": ("red",    "Bloqueado por APIs SmartVista BPC"),
        "riesgos":       ("yellow", "Dependencia crítica sin resolver"),
        "pruebas":       ("yellow", "Sin fecha de inicio confirmada"),
    },
}


def render_view_sistemas(components, cube_front_content="", cube_img=None,
                          track_rags=None, us_must_by_track=None,
                          _blockers=None, _kpis=None):
    """Vista Sistemas: semáforo por track, KPIs técnicos y bloqueos activos."""
    track_rags       = track_rags or []
    us_must_by_track = us_must_by_track or {}

    # ── Bloque 1: semáforo por sistema — mismo card format que Vista Productos ─
    rag_map = {r["track"]: dict(r) for r in track_rags}
    sem_map = {"red": "crit", "yellow": "warn", "green": "ok"}
    dot_map = {"red": "🔴", "yellow": "🟡", "green": "🟢"}
    tracks_html = ""
    for track_id, meta in SYSTEM_META_VS.items():
        rag   = rag_map.get(track_id, {})
        color = rag.get("rag_color") or "yellow"
        sem   = sem_map.get(color, "warn")
        dot   = dot_map.get(color, "⚪")
        total = rag.get("hu_total") or 0
        must  = rag.get("hu_must") or 0
        us_lbl = f"{must} Must · {total} total" if total else meta["type"]
        tracks_html += (
            f'<div class="vp-cap {sem}">'
            f'<div class="vp-caplabel">{dot} {h(meta["name"])}</div>'
            f'<div class="vp-capsys">{h(us_lbl)}</div>'
            f'<div class="vp-capnote">{h(meta["note"])}</div>'
            f'</div>'
        )

    # ── Bloque 2: KPIs técnicos — derivados de brain.db si están disponibles ─
    if _kpis is not None:
        _must   = _kpis["must"]
        _should = _kpis["should"]
        _could  = _kpis["could"]
        _integ  = _kpis["total_integrations"] or 18
        kpis_list = [
            {"value": str(_kpis["total_us"]), "label": "User Stories",
             "sub": f"{_must} Must Have · {_should + _could} Should/Could", "gap": False},
            {"value": str(_integ), "label": "Integraciones",
             "sub": "9 nuevas · 9 modificadas",                              "gap": False},
            {"value": "58", "label": "User Stories de diseño",
             "sub": "SmartVista · App · CAT · SIWEB",                       "gap": False},
            {"value": "5",  "label": "DTMs con gap crítico",
             "sub": "DPP · BYU0039 · OCG y 2 más",                         "gap": True},
            {"value": "21.19%", "label": "Avance de desarrollo",
             "sub": "vs 60.58% esperado al 17-ago",                         "gap": True},
        ]
    else:
        kpis_list = KPIS_VS

    kpis_html = ""
    for kpi in kpis_list:
        gap_cls = " gap" if kpi["gap"] else ""
        kpis_html += (
            f'<div class="vs-kpi{gap_cls}">'
            f'<div class="vs-kval">{h(kpi["value"])}</div>'
            f'<div class="vs-klabel">{h(kpi["label"])}</div>'
            f'<div class="vs-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # ── Bloque 3: bloqueos por sistema — derivados de brain.db si disponibles ─
    blockers_src = _blockers[:5] if _blockers is not None else BLOCKERS_VS
    blocks_html = ""
    for blk in blockers_src:
        blocks_html += (
            f'<div class="vs-block {blk["level"]}">'
            f'<div style="flex:1">'
            f'<div class="vs-btext">{h(blk["text"])}</div>'
            f'<div class="vs-bsub">{h(blk["sys"])} · {h(blk["owner"])}</div>'
            f'</div>'
            f'</div>'
        )

    return f"""
        <div class="wrap">
        <div class="vw-grid vw-rev reveal">
          <div class="vw-body">
            <div class="kick">Vista · Sistemas</div>
            <div class="vp-h2-row">
              <h2 class="vw-h2 vwc-s">Habilitadores del Proceso</h2>
              <a href="systems-p4900.html" class="vp-h2-link">Ver ecosistema tecnológico <span class="vp-arr">→</span></a>
            </div>
            <p class="vw-desc">Estado de los sistemas que ejecutan el producto end-to-end. Cada stack tiene su propio SDLC y plan de entrega — SmartVista, Apolo, canales digitales. Esta vista gobierna los planes individuales y los alimenta al gobierno de la Vista de Producto.</p>
            <div class="vs-section-label">Estado por Sistema</div>
            <div class="vp-caps">{tracks_html}</div>
            <div class="vs-section-label">KPIs Técnicos</div>
            <div class="vs-kpis">{kpis_html}</div>
            <div class="vs-section-label">Bloqueos Activos por Sistema</div>
            <div class="vs-blocks">{blocks_html}</div>
          </div>
          <div class="vw-cube-wrap">
            {(f'<img src="{cube_img}" alt="Sistemas" class="vw-cube-img">' if cube_img else _static_cube("s", front=cube_front_content))}
          </div>
        </div>
        </div>"""


def render_view_capacidades(cube_right_content="", cube_img=None,
                             _blockers=None, _kpis=None):
    """Vista Capacidades IT: semáforo por capacidad, KPIs IT y bloqueos activos."""
    dot_map = {"crit": "🔴", "warn": "🟡", "ok": "🟢"}

    # ── Bloque 1: tarjetas semáforo por capacidad
    mat_color = {1: "#ef4444", 2: "#f59e0b", 3: "#84cc16", 4: "#22c55e"}
    mat_pct   = {1: 0, 2: 33, 3: 66, 4: 100}

    def _mat_bar(cur: int, tgt: int) -> str:
        cp = mat_pct.get(cur, 0)
        tp = mat_pct.get(tgt, 100)
        fc = mat_color.get(cur, "#f59e0b")
        tgt_dot = f'<div class="mat-dot tgt" style="left:{tp}%"></div>' if tgt != cur else ""
        return (
            f'<div class="mat-wrap">'
            f'<div class="mat-track">'
            f'<div class="mat-rail"></div>'
            f'<div class="mat-fill" style="width:{cp}%;background:{fc}"></div>'
            f'<div class="mat-dot cur" style="left:{cp}%"></div>'
            f'{tgt_dot}'
            f'</div>'
            f'<div class="mat-ticks"><span>1</span><span>2</span><span>3</span><span>4</span></div>'
            f'</div>'
        )

    caps_html = ""
    for cap_id, meta in IT_CAP_META.items():
        sem     = meta["sem"]
        dot     = dot_map.get(sem, "⚪")
        mat_cur = meta.get("mat_cur", 2)
        mat_tgt = meta.get("mat_tgt", 4)
        owner   = meta.get("owner", "")
        nxt     = meta.get("next_action", "")
        due     = meta.get("next_due", "")
        mat_html  = _mat_bar(mat_cur, mat_tgt)
        next_html = (f'<div class="vp-capnext">↗ {h(nxt)} · <span class="due">{h(due)}</span></div>' if nxt else "")
        caps_html += (
            f'<div class="vp-cap {sem}">'
            f'<div class="vp-caplabel">{dot} {h(meta["name"])}</div>'
            f'<div class="vp-capsys">{h(meta["group"])}</div>'
            f'{mat_html}'
            f'<div class="vp-capnote">{h(meta["note"])}</div>'
            f'<div class="vp-capowner">👤 {h(owner)}</div>'
            f'{next_html}'
            f'</div>'
        )

    # ── Bloque 2: KPIs IT — derivados de brain.db si están disponibles ─────────
    if _kpis is not None:
        _itcaps  = _kpis["total_itcaps"] or 13
        _crit_it = _kpis["crit_itcaps"]  or 2
        _integ   = _kpis["total_integrations"] or 18
        kpis_vc_list = [
            {"value": str(_itcaps),  "label": "Capacidades IT",
             "sub": f"{_crit_it} críticas · {max(0, _itcaps - _crit_it)} en seguimiento", "gap": False},
            {"value": str(_crit_it), "label": "Capacidades críticas",
             "sub": "Interoperabilidad · Vendor / SIAM",                                    "gap": True},
            {"value": str(_integ),   "label": "Integraciones R4",
             "sub": "9 nuevas · 9 modificadas",                                             "gap": False},
            {"value": "1",           "label": "Proveedor sin contratar",
             "sub": "CAT / ICAT — RISK-001",                                                "gap": True},
            {"value": "~ene-27",     "label": "Go-Live objetivo",
             "sub": "15-ene-2027 · margen mínimo",                                         "gap": False},
        ]
    else:
        kpis_vc_list = KPIS_VC

    kpis_html = ""
    for kpi in kpis_vc_list:
        gap_cls = " gap" if kpi.get("gap") else ""
        kpis_html += (
            f'<div class="vs-kpi{gap_cls}">'
            f'<div class="vs-kval">{h(kpi["value"])}</div>'
            f'<div class="vs-klabel">{h(kpi["label"])}</div>'
            f'<div class="vs-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # ── Bloque 3: bloqueos activos — derivados de brain.db si disponibles ────
    blockers_vc_src = _blockers[:5] if _blockers is not None else BLOCKERS_VC
    blocks_html = ""
    for bl in blockers_vc_src:
        lvl_icon = "\U0001f534" if bl["level"] == "crit" else "\U0001f7e1"
        blocks_html += (
            f'<div class="vs-block {bl["level"]}">'
            f'<div style="flex:1">'
            f'<div class="vs-btext">{lvl_icon} {h(bl["text"])}</div>'
            f'<div class="vs-bsub">{h(bl["sys"])} · {h(bl["owner"])}</div>'
            f'</div>'
            f'</div>'
        )

    return (
        '<div class="wrap">\n'
        '<div class="vw-grid vw-rev reveal">\n'
        '  <div class="vw-body">\n'
        '    <div class="kick">Vista · Capacidades IT</div>\n'
        '    <div class="vp-h2-row">\n'
        '      <h2 class="vw-h2 vwc-c">Capacidades Transversales de TI</h2>\n'
        '      <a href="capacidades-it.html" class="vp-h2-link">Ver gobernanza <span class="vp-arr">→</span></a>\n'
        '    </div>\n'
        '    <p class="vw-desc">Capacidades institucionales que proveen servicios de '
        'implementación y operación al programa. Gobiernan el SDLC, la demanda de proveedores, '
        'la seguridad, el testing y la resiliencia operativa del Go-Live.</p>\n'
        f'    <div class="vs-section-label">Estado por Capacidad</div>\n'
        f'    <div class="vp-caps">{caps_html}</div>\n'
        f'    <div class="vs-section-label">KPIs de Entrega IT</div>\n'
        f'    <div class="vs-kpis">{kpis_html}</div>\n'
        f'    <div class="vs-section-label">Bloqueos Activos por Capacidad</div>\n'
        f'    <div class="vs-blocks">{blocks_html}</div>\n'
        '  </div>\n'
        '  <div class="vw-cube-wrap">\n'
        + (f'    <img src="{cube_img}" alt="Capacidades IT" class="vw-cube-img">\n'
           if cube_img
           else _static_cube("c", right=cube_right_content) + "\n")
        + '  </div>\n</div>\n</div>'
    )


def render_cube_productos(products, releases):
    lines = []
    rel_by_product = {}
    for r in releases:
        rel_by_product.setdefault(r["product_id"], []).append(r)

    def _prod_order(p):
        lbls = [r["release_label"] for r in rel_by_product.get(p["id"], [])
                if r["status"] not in EXCLUDED_STATUSES]
        return min(lbls) if lbls else "Z"

    for prod in sorted(products, key=_prod_order):
        prod_lines = []
        for rel in rel_by_product.get(prod["id"], []):
            if rel["status"] in EXCLUDED_STATUSES:
                continue
            hl = ' hl' if rel["status"] == "building" else ""
            scope = rel["scope"] or ""
            scope_line = f'<div class="pcs">{h(scope)}</div>' if scope else ""
            prod_lines.append(
                f'<div class="pcard{hl}">'
                f'<div class="pcn">{h(rel["release_label"])} {badge_status(rel["status"])}</div>'
                f'{scope_line}'
                f'</div>'
            )
        if prod_lines:
            lines.append(f'<div class="cf-gl">{h(prod["name"])}</div>')
            lines.extend(prod_lines)

    if not lines:
        lines.append('<div class="cf-gl">Sin datos en brain.db</div>')
    return "\n            ".join(lines)


def render_cube_sistemas(components):
    groups = {"channel": ("Channels", []), "core": ("Core", []),
              "enabler": ("Processors", []), "transversal": ("Data, Integration", [])}
    order  = ["channel", "core", "enabler", "transversal"]

    for c in components:
        t = c["type"] if c["type"] in groups else "transversal"
        groups[t][1].append(c)

    lines = []
    for key in order:
        label, items = groups[key]
        if not items:
            continue
        lines.append(f'<div class="cf-gl">{label}</div>')
        # pares de items
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="cfc-pair">')
                for it in pair:
                    badge = ""
                    if it["provider_status"] == "live":
                        badge = '<span class="cfbadge b-tg">target</span>'
                    elif it["provider_status"] == "legacy":
                        badge = '<span class="cfbadge b-bl">base</span>'
                    elif it["provider_status"] == "transitional":
                        badge = '<span class="cfbadge b-tr">trans</span>'
                    lines.append(
                        f'  <div class="cfc"><span class="cfcn">{h(it["name"])}</span>{badge}</div>'
                    )
                lines.append('</div>')
            else:
                it = pair[0]
                lines.append(
                    f'<div class="cfc"><span class="cfcn">{h(it["name"])}</span></div>'
                )
    return "\n            ".join(lines)


def render_cube_capacidades():
    lines = []
    for group, items in IT_CAPS.items():
        lines.append(f'<div class="cf-gl">{group}</div>')
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="cfc-pair">')
                for it in pair:
                    lines.append(f'  <div class="cfc"><span class="cfcn">{h(it)}</span></div>')
                lines.append('</div>')
            else:
                lines.append(f'<div class="cfc"><span class="cfcn">{h(pair[0])}</span></div>')
    return "\n            ".join(lines)


def render_rag(track_rags):
    lines = []
    for tr in track_rags:
        color   = tr["rag_color"] or "yellow"
        css     = rag_css(color)
        dot     = rag_dot(color)
        label   = {"red":"Rojo, bloqueado","yellow":"Amarillo","green":"Verde"}.get(color, color)
        summary = h(tr["rag_general"] or "")
        reasons = []
        if tr["tipo_solucion_detail"]:
            reasons.append(f'<b>Tipo de solución.</b> {h(tr["tipo_solucion_detail"])}')
        if tr["impacto_solucion_detail"]:
            reasons.append(f'<b>Impacto.</b> {h(tr["impacto_solucion_detail"])}')
        if tr["complejidad_detail"]:
            reasons.append(f'<b>Complejidad.</b> {h(tr["complejidad_detail"])}')
        if tr["rag_integraciones"]:
            reasons.append(f'<b>Integraciones.</b> {h(tr["rag_integraciones"])}')

        bullets = "".join(f'<li>{r}</li>' for r in reasons)
        rag_why = f'<ul class="rag-why">{bullets}</ul>' if bullets else ""

        lines.append(f"""
        <div class="rag-card {css}">
          <div class="rag-dot">{dot}</div>
          <div class="rag-name">{h(tr["track"].upper() if tr["track"] else "")}</div>
          <div class="rag-sub">{summary}</div>
          {rag_why}
          <div class="rag-label {css}">{label}</div>
        </div>""")
    return "".join(lines)


def render_risks(risks):
    lines = []
    for r in risks:
        med_cls  = risk_severity_css(r["impact"], r["probability"])
        comp     = h(r["component_name"] or r["component_id"] or "")
        prob_lbl = {"high":"Alta","medium":"Media","low":"Baja"}.get(r["probability"],"")
        imp_lbl  = {"critical":"Impacto Crítico","high":"Impacto Alto","medium":"Impacto Medio","low":"Impacto Bajo"}.get(r["impact"],"")
        kick     = f'{h(r["raid_id"])}, {prob_lbl} e {imp_lbl}, {comp}'.strip(", ")
        desc     = h(r["description"])
        mitigation = f' <b>{h(r["mitigation"])}</b>' if r["mitigation"] else ""
        due = f' <b>Fecha objetivo {h(r["due_date"])}.</b>' if r["due_date"] else ""

        lines.append(f"""
      <div class="rcard {med_cls} glass">
        <div class="rkick">{kick}</div>
        <div class="rtitle">{desc}</div>
        <div class="rdesc">{h(r["notes"] or "")}{mitigation}{due}</div>
      </div>""")
    return "".join(lines)


def render_actions(actions):
    if not actions:
        return '<p style="color:var(--muted);font-size:13px">Sin acciones cargadas — ejecutar migrate-add-program-actions.py</p>'
    lines = []
    for i, a in enumerate(actions, 1):
        sev     = a["severity"] or "high"
        css     = "r" if sev == "critical" else "y"
        sev_lbl = "Crítica" if sev == "critical" else "Alta"
        breach  = int(a["breach"] or 0)
        breach_html = '<span class="act-breach">BREACH</span>' if breach else ""
        tracks  = h(a["tracks"] or "—")
        owner   = h(a["owner"] or "—")
        due     = h(a["due_date"] or "—")
        desc    = h(a["description"] or "")
        rem     = h(a["remediation"] or "")
        lines.append(f"""
      <div class="act-card {css} reveal">
        <div class="act-num">{i}</div>
        <div class="act-body">
          <div class="act-top">
            <span class="act-sev {css}">{sev_lbl}</span>
            {breach_html}
            <span class="act-tracks">{tracks}</span>
          </div>
          <div class="act-title">{desc}</div>
          <div class="act-rem">{rem}</div>
          <div class="act-meta"><span class="act-owner">{owner}</span> · {due}</div>
        </div>
      </div>""")
    return "".join(lines)


def render_milestones(milestones):
    lines = []
    for m in milestones:
        risk_cls = ' risk' if m["status"] == "at_risk" else ""
        tag      = milestone_tag(m["status"])
        note     = f'<p>{h(m["notes"])}</p>' if m["notes"] else ""
        date_str = h(m["target_date"] or "")
        lines.append(f"""
        <div class="node{risk_cls}">
          <h4>{h(m["name"])}</h4>
          <div class="ndate">{date_str}</div>
          {note}
          {tag}
        </div>""")
    return "".join(lines)


def render_dt_groups():
    lines = []
    for group in DT_GROUPS:
        lines.append(f"""
    <div class="dt-group reveal">
      <div class="dt-group-label">{h(group["label"])}</div>
      <div class="dt-grid">""")
        for dt in group["twins"]:
            border = ""
            if dt.get("crit"):  border = " crit"
            elif dt.get("warn"): border = " warn"
            link_cls = " link" if dt.get("link") else ""
            onclick  = f' onclick="window.location=\'{dt["link"]}\'"' if dt.get("link") else ""
            chips    = "".join(
                f'<span class="chip {c}">{h(t)}</span>'
                for c, t in dt.get("chips", [])
            )
            go = f'<div class="dt-go">Abrir portal <span class="arr">→</span></div>' if dt.get("link") else ""
            lines.append(f"""
        <div class="dtcard glass{border}{link_cls}"{onclick}>
          <div class="dt-top">
            <div class="dt-ico">{dt["ico"]}</div>
            <span class="dt-ver">{h(dt["ver"])}</span>
          </div>
          <div class="dt-name">{h(dt["name"])}</div>
          <div class="dt-desc">{h(dt["desc"])}</div>
          <div class="dt-chips">{chips}</div>
          {go}
        </div>""")
        lines.append("\n      </div>\n    </div>")
    return "".join(lines)


# ── Template principal ────────────────────────────────────────────────────────

def capture_cube_screenshots(html_path, img_dir):
    """Abre el HTML con Playwright, rota el cubo a cada orientación canónica y guarda PNGs."""
    try:
        from playwright.sync_api import sync_playwright
    except ImportError:
        print("[build-portal] playwright no instalado — cubos CSS como fallback")
        print("               pip install playwright && playwright install chromium")
        return {}

    img_dir.mkdir(parents=True, exist_ok=True)
    imgs = {}

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(viewport={"width": 1400, "height": 900})
        page.goto(html_path.resolve().as_uri())
        page.wait_for_timeout(900)  # aurora + fonts + primer frame

        # Detener el loop requestAnimationFrame para que no sobreescriba el transform
        page.evaluate("window.requestAnimationFrame = function() { return 0; };")
        page.wait_for_timeout(100)

        for name, transform in CUBE_ORIENTATIONS:
            page.evaluate(f"""
                var c = document.getElementById('cube3d');
                c.style.setProperty('transform', '{transform}', 'important');
                c.style.setProperty('transition', 'none', 'important');
            """)
            page.wait_for_timeout(200)
            out = img_dir / f"cube-{name}.png"
            page.query_selector('#scene3d').screenshot(path=str(out))
            imgs[name] = f"img/cube-{name}.png"
            print(f"[build-portal]   screenshot cube-{name}.png ✓")

        browser.close()

    return imgs


def render(data, cube_imgs=None):
    days    = days_to_golive()
    hus     = data["total_hus"] or 79
    risks_n = data["high_risks"] or 9
    _kpis   = data.get("derived_kpis") or {}
    breach_n = _kpis.get("breach_count", 0)

    cube_imgs  = cube_imgs or {}
    cube_prod  = render_cube_productos(data["products"], data["releases"])
    cube_sis   = render_cube_sistemas(data["components"])
    cube_cap   = render_cube_capacidades()

    # Datos derivados de brain.db (None si load_data no los pudo computar)
    _db_blockers = data.get("derived_blockers")
    _db_kpis     = data.get("derived_kpis")

    view_prod  = render_view_productos(data["products"], data["releases"], cube_prod,
                                       cube_img=cube_imgs.get("productos"),
                                       _blockers=_db_blockers, _kpis=_db_kpis)
    view_sis   = render_view_sistemas(data["components"], cube_sis,
                                      cube_img=cube_imgs.get("sistemas"),
                                      track_rags=data.get("track_rags", []),
                                      us_must_by_track=data.get("us_must_by_track", {}),
                                      _blockers=_db_blockers, _kpis=_db_kpis)
    view_cap   = render_view_capacidades(cube_cap,
                                         cube_img=cube_imgs.get("capacidades"),
                                         _blockers=_db_blockers, _kpis=_db_kpis)
    rag_html    = render_rag(data["track_rags"])
    risk_html   = render_risks(data["risks"])
    action_html = render_actions(data.get("actions", []))
    mile_html   = render_milestones(data["milestones"])
    generated  = datetime.now().strftime("%Y-%m-%d %H:%M")

    return f"""<!DOCTYPE html>
<!-- Unity — Plan Director · Portal de Programa · BanCoppel
     SPE-AM-001 · Generado por generators/build-portal.py · {generated} -->
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Unity — Plan Director — BanCoppel</title>
<style>
/* ─── Reset y tokens ─── */
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--blue:#3D5FCD;--blued:#122FB1;--bluedd:#0d2185;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
  --red:#E8400A;--green:#22c55e}}
html{{scroll-behavior:smooth}}
body{{background:#060a1a;color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
.aurora::before,.aurora::after,.aurora .blob{{content:"";position:absolute;border-radius:50%;filter:blur(90px)}}
.aurora::before{{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(27,63,208,.65),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(13,33,133,.7),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(240,210,36,.22),transparent 70%);animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
#prog{{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;
  background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}}
nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:14px 30px;
  backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);
  background:rgba(6,10,26,.55);border-bottom:1px solid rgba(255,255,255,.06)}}
nav img{{height:20px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
nav .nt{{font-size:12px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
nav .sp{{flex:1}}
nav a.jump{{font-size:12px;color:var(--muted);padding:6px 12px;border-radius:20px;transition:.22s;text-decoration:none}}
nav a.jump:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
nav a.jump.ext{{color:var(--yellow)}}
nav a.jump.ext:hover{{color:#fff}}
@media(max-width:700px){{nav .nt,.nav-links{{display:none}}}}
.glass{{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);
  border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}}
.wrap{{max-width:1200px;margin:0 auto;padding:0 30px}}
section{{padding:72px 0;scroll-margin-top:70px}}
#view-productos,#view-sistemas,#view-capacidades{{padding:44px 0}}
.hero{{min-height:100vh;display:grid;grid-template-columns:1fr 1fr;gap:40px;align-items:center;padding:110px 0 60px}}
@media(max-width:900px){{.hero{{grid-template-columns:1fr;min-height:auto;padding-top:90px}}}}
.eyebrow{{display:inline-flex;align-items:center;gap:9px;padding:8px 16px;border-radius:30px;
  font-size:12px;font-weight:600;letter-spacing:.03em;color:#dfe6ff;margin-bottom:24px;
  background:rgba(255,255,255,.05);border:1px solid var(--glassb);
  backdrop-filter:blur(10px);-webkit-backdrop-filter:blur(10px)}}
.eyebrow .dot{{width:7px;height:7px;border-radius:50%;background:var(--yellow);
  box-shadow:0 0 12px var(--yellow);animation:pulse 2.4s infinite}}
@keyframes pulse{{50%{{opacity:.4}}}}
.hero h1{{font-size:clamp(40px,5.5vw,72px);font-weight:800;line-height:1.0;letter-spacing:-.035em;
  background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.hero .sub{{font-size:16px;color:var(--muted);margin-top:18px;max-width:50ch;line-height:1.6}}
.hero .sub b{{color:#e4eaff;font-weight:600}}
.countdown{{display:inline-flex;flex-direction:column;align-items:center;padding:20px 36px;
  border-radius:18px;margin-top:28px;gap:4px}}
.cdays{{font-size:48px;font-weight:900;letter-spacing:-.04em;
  background:linear-gradient(170deg,#fff 40%,var(--yellow));-webkit-background-clip:text;background-clip:text;color:transparent;
  font-variant-numeric:tabular-nums}}
.clabel{{font-size:11px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2)}}
.hero-cube-zone{{display:flex;flex-direction:column;align-items:center;gap:18px;position:relative}}
.cube-hint{{font-size:10px;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);font-weight:600}}
.scene3d{{width:380px;height:380px;perspective:840px;cursor:grab;user-select:none}}
.scene3d:active{{cursor:grabbing}}
.cube3d{{width:280px;height:280px;position:relative;transform-style:preserve-3d;
  transform:rotateX(-30deg) rotateY(-30deg);
  transition:transform .65s cubic-bezier(.25,.46,.45,.94);margin:50px auto}}
.cube3d.dragging{{transition:none}}
.cf{{position:absolute;width:280px;height:280px;border:1px solid rgba(255,255,255,.18);
  overflow-y:auto;padding:8px;border-radius:4px;display:flex;flex-direction:column;box-sizing:border-box}}
.cf::-webkit-scrollbar{{width:3px}}
.cf::-webkit-scrollbar-thumb{{background:rgba(255,255,255,.25);border-radius:2px}}
.cf-top   {{transform:rotateX(90deg) translateZ(140px);background:linear-gradient(135deg,#AB47BC,#4A148C)}}
.cf-front {{transform:translateZ(140px);background:linear-gradient(135deg,#1976D2,#0D47A1)}}
.cf-right {{transform:rotateY(90deg) translateZ(140px);background:linear-gradient(135deg,#43A047,#1B5E20)}}
.cf-back  {{transform:translateZ(-140px) rotateY(180deg);background:linear-gradient(135deg,#1a237e,#0d1421)}}
.cf-left  {{transform:rotateY(-90deg) translateZ(140px);background:linear-gradient(135deg,#AB47BC,#4A148C)}}
.cf-bot   {{transform:rotateX(-90deg) translateZ(140px);background:linear-gradient(135deg,#1a237e,#0d1421)}}
.cf-title{{font-size:9px;font-weight:700;letter-spacing:2px;text-transform:uppercase;color:#fff;
  margin-bottom:9px;padding-bottom:5px;border-bottom:1px solid rgba(255,255,255,.22)}}
.cf-gl{{font-size:7px;font-weight:600;letter-spacing:2px;text-transform:uppercase;
  color:rgba(255,255,255,.45);margin-top:8px;margin-bottom:3px}}
.cfc{{background:rgba(255,255,255,.11);border:1px solid rgba(255,255,255,.14);border-radius:4px;
  padding:2px 6px;margin-bottom:2px;display:flex;align-items:center;justify-content:flex-start;
  gap:5px;min-height:18px}}
.cfcn{{font-size:10px;color:rgba(255,255,255,.9);font-weight:500;flex:1}}
.cfbadge{{font-size:7.5px;font-weight:700;padding:1px 4px;border-radius:6px;white-space:nowrap;flex-shrink:0}}
.b-bl{{background:rgba(21,101,192,.65);color:#90CAF9}}
.b-tg{{background:rgba(46,125,50,.65);color:#A5D6A7}}
.b-vc{{background:rgba(183,28,28,.55);color:#EF9A9A}}
.b-tr{{background:rgba(245,124,0,.55);color:#FFCC80}}
.pcard{{background:rgba(255,255,255,.10);border:1px solid rgba(255,255,255,.16);border-radius:5px;padding:6px 9px;margin-bottom:4px}}
.pcard.hl{{background:rgba(255,255,255,.20);border-color:rgba(255,255,255,.50)}}
.pcn{{font-size:9.5px;font-weight:700;color:#fff;display:flex;align-items:center;justify-content:flex-start;gap:5px;line-height:1}}
.pcs{{font-size:8.5px;color:rgba(255,255,255,.65);line-height:1.3;margin-top:3px}}
.cf-pgrid{{display:grid;grid-template-columns:1fr 1fr;gap:4px;margin-top:4px;flex:1;min-height:0;grid-auto-rows:1fr;align-content:stretch}}
.cf-pcell{{background:rgba(255,255,255,.11);border:1px solid rgba(255,255,255,.16);border-radius:5px;padding:5px 7px}}
.cf-pcell.hl{{background:rgba(255,255,255,.22);border-color:rgba(255,255,255,.48)}}
.cf-pname{{font-size:7.5px;color:rgba(255,255,255,.72);line-height:1.35;margin-top:3px}}
.cfc-pair{{display:flex;gap:3px;margin-bottom:3px}}
.cfc-pair .cfc{{flex:1;margin-bottom:0}}
.vw-grid{{display:grid;grid-template-columns:260px 1fr;gap:52px;align-items:start}}
.vw-rev{{grid-template-columns:1fr 260px}}
.vw-rev .vw-cube-wrap{{order:2}}
.vw-rev .vw-body{{order:1}}
@media(max-width:900px){{.vw-grid{{grid-template-columns:1fr}}.vw-rev .vw-cube-wrap,.vw-rev .vw-body{{order:unset}}}}
.vw-scene{{width:260px;height:260px;perspective:600px;margin:0 auto}}
.vw-cube-img{{width:100%;max-width:380px;border-radius:16px;box-shadow:0 12px 48px rgba(0,0,0,.55);display:block;margin:0 auto}}
.vw-static{{width:220px;height:220px;position:relative;transform-style:preserve-3d;margin:20px auto;transition:none!important}}
.vw-static-p{{transform:rotateX(-70deg) rotateY(-20deg)!important}}
.vw-static-s{{transform:rotateX(-15deg) rotateY(-5deg)!important}}
.vw-static-c{{transform:rotateX(-15deg) rotateY(-80deg)!important}}
.vw-static .cf{{width:220px;height:220px;font-size:8.5px}}
.vw-static .cf-top{{transform:rotateX(90deg) translateZ(110px)!important}}
.vw-static .cf-front{{transform:translateZ(110px)!important}}
.vw-static .cf-right{{transform:rotateY(90deg) translateZ(110px)!important}}
.vw-static .cf-back{{transform:translateZ(-110px) rotateY(180deg)!important}}
.vw-static .cf-left{{transform:rotateY(-90deg) translateZ(110px)!important}}
.vw-static .cf-bot{{transform:rotateX(-90deg) translateZ(110px)!important}}
.vw-h2{{font-size:clamp(22px,2.8vw,34px);font-weight:800;letter-spacing:-.025em;line-height:1.06;margin:14px 0 10px}}
.vwc-p{{color:#CE93D8}}
.vwc-s{{color:#90CAF9}}
.vwc-c{{color:#A5D6A7}}
.vw-desc{{font-size:14px;color:var(--muted);line-height:1.6;max-width:60ch;margin-bottom:14px}}
#view-productos{{border-top:2px solid rgba(171,71,188,.25)}}
#view-sistemas{{border-top:2px solid rgba(25,118,210,.25)}}
#view-capacidades{{border-top:2px solid rgba(67,160,71,.25)}}
.fgl{{font-size:9px;font-weight:700;letter-spacing:.15em;text-transform:uppercase;
  color:rgba(255,255,255,.35);margin:12px 0 6px}}
.frow{{display:flex;align-items:center;justify-content:space-between;gap:8px;
  padding:5px 9px;border-radius:6px;margin-bottom:4px;background:rgba(255,255,255,.055)}}
.fname{{font-size:11px;font-weight:600;color:rgba(255,255,255,.88);flex:1}}
.fpair{{display:flex;gap:6px;margin-bottom:4px}}
.fpair .frow{{flex:1;margin-bottom:0}}
.fbadge{{font-size:8px;font-weight:700;padding:1px 6px;border-radius:8px;white-space:nowrap}}
.fbadge.tg{{background:rgba(46,125,50,.65);color:#A5D6A7}}
.fbadge.bl{{background:rgba(21,101,192,.65);color:#90CAF9}}
.fbadge.tr{{background:rgba(245,124,0,.55);color:#FFCC80}}
.fpcard{{padding:7px 10px;border-radius:8px;margin-bottom:5px;
  background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12)}}
.fpcard.hl{{background:rgba(255,255,255,.15);border-color:rgba(255,255,255,.35)}}
.fpcn{{font-size:11px;font-weight:600;color:#fff;display:flex;align-items:flex-start;justify-content:space-between;gap:8px;flex-wrap:wrap;line-height:1.45}}
.stats{{display:grid;grid-template-columns:repeat(5,1fr);gap:13px;margin-top:0}}
@media(max-width:1000px){{.stats{{grid-template-columns:repeat(3,1fr)}}}}
@media(max-width:600px){{.stats{{grid-template-columns:repeat(2,1fr)}}}}
.stat{{padding:20px 14px;text-align:center}}
.statn{{font-size:clamp(20px,2.5vw,30px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;
  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}}
.statl{{font-size:10px;color:var(--muted2);margin-top:8px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}}
.stat.danger .statn{{background:linear-gradient(180deg,#fca5a5,#ef4444);-webkit-background-clip:text;background-clip:text}}
.stat.warn .statn{{background:linear-gradient(180deg,#fde68a,var(--yellow));-webkit-background-clip:text;background-clip:text}}
.shead{{margin-bottom:36px}}
.kick{{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:14px}}
.shead h2{{font-size:clamp(26px,3.5vw,40px);font-weight:800;letter-spacing:-.025em;line-height:1.06}}
.shead p{{color:var(--muted);font-size:15px;margin-top:12px;max-width:72ch;line-height:1.55}}
.rag-grid{{display:grid;grid-template-columns:repeat(auto-fit,minmax(310px,1fr));gap:14px;align-items:start}}
@media(max-width:900px){{.rag-grid{{grid-template-columns:repeat(3,1fr)}}}}
@media(max-width:560px){{.rag-grid{{grid-template-columns:1fr 1fr}}}}
.rag-card{{padding:20px 18px;border-radius:18px;border-left:4px solid transparent}}
.rag-card.r{{border-left-color:#ef4444;background:rgba(239,68,68,.07);border:1px solid rgba(239,68,68,.18);border-left:4px solid #ef4444}}
.rag-card.y{{border-left-color:var(--yellow);background:rgba(240,210,36,.05);border:1px solid rgba(240,210,36,.18);border-left:4px solid var(--yellow)}}
.rag-card.g{{border-left-color:var(--green);background:rgba(34,197,94,.05);border:1px solid rgba(34,197,94,.18);border-left:4px solid var(--green)}}
.rag-dot{{font-size:20px;margin-bottom:8px}}
.rag-name{{font-size:13.5px;font-weight:700;margin-bottom:4px}}
.rag-sub{{font-size:11px;color:var(--muted2);line-height:1.4}}
.rag-why{{list-style:none;margin:12px 0 0;padding:0;display:flex;flex-direction:column;gap:8px}}
.rag-why li{{font-size:10.5px;line-height:1.5;color:var(--muted);padding-left:12px;position:relative}}
.rag-why li::before{{content:"";position:absolute;left:0;top:6px;width:4px;height:4px;border-radius:50%;
  background:currentColor;opacity:.5}}
.rag-why li b{{color:#e4eaff;font-weight:600}}
.rag-card.r .rag-why li::before{{background:#ef4444;opacity:.85}}
.rag-card.y .rag-why li::before{{background:var(--yellow);opacity:.85}}
.rag-label{{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;
  padding:2px 7px;border-radius:8px;margin-top:8px}}
.rag-label.r{{background:rgba(239,68,68,.15);color:#fca5a5;border:1px solid rgba(239,68,68,.3)}}
.rag-label.y{{background:rgba(240,210,36,.1);color:var(--yellow);border:1px solid rgba(240,210,36,.3)}}
.dt-grid{{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}}
@media(max-width:960px){{.dt-grid{{grid-template-columns:repeat(2,1fr)}}}}
@media(max-width:560px){{.dt-grid{{grid-template-columns:1fr}}}}
.dt-group{{margin-bottom:44px}}
.dt-group-label{{font-size:11px;font-weight:700;letter-spacing:.15em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:16px;padding-bottom:8px;border-bottom:1px solid rgba(255,255,255,.07)}}
.dtcard{{display:flex;flex-direction:column;gap:10px;padding:22px;color:inherit;text-decoration:none;
  border-radius:20px;transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s;cursor:default}}
.dtcard.link{{cursor:pointer}}
.dtcard.link:hover{{transform:translateY(-5px);border-color:rgba(240,210,36,.42);box-shadow:0 20px 52px rgba(0,0,0,.5)}}
.dtcard.crit{{border-left:3px solid var(--red)!important}}
.dtcard.warn{{border-left:3px solid var(--yellow)!important}}
.dt-top{{display:flex;align-items:flex-start;justify-content:space-between;gap:8px}}
.dt-ico{{font-size:22px;width:46px;height:46px;display:flex;align-items:center;justify-content:center;
  border-radius:14px;flex-shrink:0;background:linear-gradient(150deg,rgba(255,255,255,.13),rgba(255,255,255,.02));
  border:1px solid rgba(255,255,255,.11)}}
.dt-ver{{font-size:9px;font-weight:700;color:var(--muted2);letter-spacing:.06em;padding:2px 7px;
  border-radius:8px;border:1px solid rgba(255,255,255,.10);background:rgba(255,255,255,.05);white-space:nowrap}}
.dt-name{{font-size:15px;font-weight:800;letter-spacing:-.01em;margin-top:4px}}
.dt-desc{{font-size:12.5px;color:var(--muted);line-height:1.55;flex:1}}
.dt-chips{{display:flex;flex-wrap:wrap;gap:4px}}
.chip{{display:inline-block;font-size:9.5px;font-weight:700;padding:2px 8px;border-radius:10px;letter-spacing:.04em}}
.chip.blue{{border:1px solid rgba(100,140,255,.35);color:#9db8ff;background:rgba(61,95,205,.15)}}
.chip.yellow{{border:1px solid rgba(240,210,36,.35);color:var(--yellow);background:rgba(240,210,36,.09)}}
.chip.red{{border:1px solid rgba(232,64,10,.35);color:#f87171;background:rgba(232,64,10,.10)}}
.chip.green{{border:1px solid rgba(34,197,94,.35);color:#86efac;background:rgba(34,197,94,.09)}}
.dt-go{{font-size:11px;font-weight:700;color:var(--yellow);display:inline-flex;align-items:center;gap:5px;margin-top:4px}}
.arr{{transition:transform .3s}}.dtcard.link:hover .arr{{transform:translateX(5px)}}
.risk-grid{{display:grid;grid-template-columns:1fr 1fr;gap:14px}}
@media(max-width:760px){{.risk-grid{{grid-template-columns:1fr}}}}
.rcard{{padding:22px 24px;border-left:3px solid var(--red);border-radius:0 14px 14px 0}}
.rcard.med{{border-left-color:var(--yellow)}}
.rkick{{font-size:9.5px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;color:#f87171;margin-bottom:6px}}
.rcard.med .rkick{{color:var(--yellow)}}
.rtitle{{font-size:15px;font-weight:700;margin-bottom:8px;letter-spacing:-.01em}}
.rdesc{{font-size:12.5px;color:var(--muted);line-height:1.55}}
.rdesc b{{color:#e4eaff}}
.tl{{position:relative;padding-left:36px;max-width:680px}}
.tl::before{{content:"";position:absolute;left:5px;top:8px;bottom:8px;width:2px;
  background:linear-gradient(180deg,var(--yellow),var(--blue) 60%,transparent)}}
.node{{position:relative;padding-bottom:22px}}
.node:last-child{{padding-bottom:0}}
.node::before{{content:"";position:absolute;left:-36px;top:3px;width:12px;height:12px;border-radius:50%;
  background:var(--yellow);border:3px solid #060a1a;box-shadow:0 0 0 2px rgba(240,210,36,.55),0 0 14px rgba(240,210,36,.5)}}
.node.risk::before{{background:var(--red);box-shadow:0 0 0 2px rgba(232,64,10,.55),0 0 14px rgba(232,64,10,.5)}}
.node h4{{font-size:14.5px;font-weight:700;letter-spacing:-.01em}}
.node .ndate{{font-size:11.5px;color:var(--muted2);margin-top:2px}}
.node p{{font-size:12.5px;color:var(--muted);margin-top:5px;line-height:1.5}}
.node .ntag{{display:inline-block;font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;
  padding:2px 7px;border-radius:8px;margin-top:5px}}
.ntag.ok{{background:rgba(34,197,94,.12);color:#86efac;border:1px solid rgba(34,197,94,.25)}}
.ntag.risk{{background:rgba(239,68,68,.12);color:#fca5a5;border:1px solid rgba(239,68,68,.25)}}
.ntag.pend{{background:rgba(170,179,212,.1);color:var(--muted);border:1px solid rgba(255,255,255,.12)}}
.reveal{{opacity:0;transform:translateY(28px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}}
.reveal.in{{opacity:1;transform:none}}
footer{{padding:40px 30px 60px;text-align:center;color:var(--muted2);font-size:12px;
  border-top:1px solid rgba(255,255,255,.06);margin-top:50px;line-height:1.8}}
footer code{{color:var(--muted);background:rgba(240,210,36,.10);border:1px solid rgba(240,210,36,.25);
  border-radius:5px;padding:1px 6px;font-size:11px;font-family:'SF Mono',ui-monospace,monospace}}
@media(prefers-reduced-motion:reduce){{.reveal{{transition:none;opacity:1;transform:none}}.aurora *{{animation:none}}}}
/* ── Vista Producto — Capabilities, KPIs, Bloqueadores ── */
.vp-section-label{{font-size:9px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:rgba(255,255,255,.35);margin:14px 0 6px}}
.vp-caps{{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}}
@media(max-width:700px){{.vp-caps{{grid-template-columns:repeat(2,1fr)}}}}
.vp-cap{{padding:9px 11px;border-radius:9px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-left:3px solid rgba(255,255,255,.15)}}
.vp-cap.warn{{border-left-color:var(--yellow)}}
.vp-cap.crit{{border-left-color:var(--red)}}
.vp-cap.ok{{border-left-color:var(--green)}}
.vp-caplabel{{font-size:10.5px;font-weight:700;color:#e4eaff;margin-bottom:2px;line-height:1.3}}
.vp-capsys{{font-size:8.5px;color:var(--muted2)}}
.vp-capnote{{font-size:8px;color:var(--muted);margin-top:3px;line-height:1.35}}
.mat-wrap{{margin-top:6px}}
.mat-track{{position:relative;height:14px;display:flex;align-items:center;margin-bottom:2px}}
.mat-rail{{position:absolute;left:0;right:0;height:2px;background:rgba(255,255,255,.1);border-radius:2px}}
.mat-fill{{position:absolute;left:0;height:2px;border-radius:2px}}
.mat-dot{{position:absolute;width:8px;height:8px;border-radius:50%;top:50%;transform:translate(-50%,-50%)}}
.mat-dot.cur{{background:#fff;border:1.5px solid rgba(255,255,255,.8);box-shadow:0 0 4px rgba(255,255,255,.3)}}
.mat-dot.tgt{{background:transparent;border:1.5px solid rgba(255,255,255,.3)}}
.mat-ticks{{display:flex;justify-content:space-between;font-size:7.5px;color:rgba(255,255,255,.2);line-height:1;padding:0 4px}}
.vp-capowner{{font-size:8px;color:rgba(255,255,255,.45);margin-top:5px}}
.vp-capnext{{font-size:7.5px;color:rgba(255,255,255,.3);margin-top:2px;line-height:1.35}}
.vp-capnext .due{{color:var(--yellow);font-weight:600}}
.vp-kpis{{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}}
@media(max-width:700px){{.vp-kpis{{grid-template-columns:repeat(2,1fr)}}}}
.vp-kpi{{padding:10px 11px;border-radius:9px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.09);text-align:center}}
.vp-kpi.gap{{background:rgba(255,255,255,.02);border-style:dashed;opacity:.55}}
.vp-kval{{font-size:15px;font-weight:800;letter-spacing:-.02em;color:#fff}}
.vp-kpi.gap .vp-kval{{font-size:11px;color:var(--muted2)}}
.vp-klabel{{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--muted2);margin-top:3px}}
.vp-ksub{{font-size:7.5px;color:var(--muted2);margin-top:1px;opacity:.7}}
.vp-blocks{{display:flex;flex-direction:column;gap:5px}}
.vp-block{{display:flex;align-items:flex-start;gap:10px;padding:8px 10px;border-radius:8px;
  background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);border-left:3px solid rgba(255,255,255,.15)}}
.vp-block.crit{{border-left-color:var(--red)}}
.vp-block.warn{{border-left-color:var(--yellow)}}
.vp-btext{{font-size:11px;font-weight:600;color:#e4eaff;line-height:1.4}}
.vp-bsub{{font-size:8.5px;color:var(--muted2);margin-top:2px}}
.vp-h2-row{{display:flex;align-items:baseline;justify-content:space-between;gap:16px;flex-wrap:wrap}}
.vp-h2-link{{font-size:11px;font-weight:600;text-decoration:none;color:var(--muted2);
  white-space:nowrap;transition:color .2s;letter-spacing:.01em}}
.vp-h2-link:hover{{color:var(--yellow)}}
.vp-arr{{display:inline-block;transition:transform .2s}}.vp-h2-link:hover .vp-arr{{transform:translateX(3px)}}
/* ── Acciones Plan Director ── */
.act-grid{{display:flex;flex-direction:column;gap:8px}}
.act-card{{display:flex;align-items:flex-start;gap:14px;padding:14px 16px;border-radius:12px;
  background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-left:3px solid rgba(255,255,255,.15)}}
.act-card.r{{border-left:3px solid var(--red);background:rgba(239,68,68,.06);border-color:rgba(239,68,68,.16)}}
.act-card.y{{border-left:3px solid var(--yellow);background:rgba(240,210,36,.04);border-color:rgba(240,210,36,.13)}}
.act-num{{font-size:22px;font-weight:900;color:rgba(255,255,255,.12);min-width:28px;line-height:1;padding-top:2px;flex-shrink:0}}
.act-card.r .act-num{{color:rgba(239,68,68,.3)}}
.act-card.y .act-num{{color:rgba(240,210,36,.3)}}
.act-body{{flex:1;display:flex;flex-direction:column;gap:4px}}
.act-top{{display:flex;align-items:center;gap:6px;flex-wrap:wrap;margin-bottom:2px}}
.act-sev{{font-size:8.5px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;padding:2px 7px;border-radius:8px}}
.act-sev.r{{background:rgba(239,68,68,.18);color:#fca5a5;border:1px solid rgba(239,68,68,.3)}}
.act-sev.y{{background:rgba(240,210,36,.12);color:var(--yellow);border:1px solid rgba(240,210,36,.3)}}
.act-breach{{font-size:8px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;padding:2px 6px;
  border-radius:6px;background:rgba(239,68,68,.25);color:#fca5a5;border:1px solid rgba(239,68,68,.5)}}
.act-tracks{{font-size:9px;color:var(--muted2);font-weight:600}}
.act-title{{font-size:12.5px;font-weight:700;color:#e4eaff;line-height:1.4}}
.act-rem{{font-size:11px;color:var(--muted);line-height:1.45;margin-top:1px}}
.act-meta{{font-size:9.5px;color:var(--muted2);margin-top:3px}}
.act-owner{{font-weight:700;color:rgba(255,255,255,.55)}}
/* ── Vista Sistemas — tracks, KPIs, blockers ── */
.vs-section-label{{font-size:9px;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:rgba(255,255,255,.35);margin:14px 0 6px}}
.vs-tracks{{display:flex;flex-direction:column;gap:6px}}
.vs-track{{padding:10px 12px;border-radius:10px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-left:3px solid rgba(255,255,255,.15)}}
.vs-track.r{{border-left:3px solid var(--red);background:rgba(239,68,68,.06);border-color:rgba(239,68,68,.18)}}
.vs-track.y{{border-left:3px solid var(--yellow);background:rgba(240,210,36,.04);border-color:rgba(240,210,36,.15)}}
.vs-track.g{{border-left:3px solid var(--green);background:rgba(34,197,94,.04);border-color:rgba(34,197,94,.15)}}
.vs-tname{{font-size:12px;font-weight:700;color:#e4eaff;margin-bottom:1px;line-height:1.3}}
.vs-ttype{{font-size:9px;color:var(--muted2);text-transform:uppercase;letter-spacing:.06em;margin-bottom:3px}}
.vs-tus{{font-size:9px;color:var(--muted2);margin-bottom:3px}}
.vs-tnote{{font-size:10.5px;color:var(--muted);line-height:1.4}}
.vs-kpis{{display:grid;grid-template-columns:repeat(3,1fr);gap:7px}}
@media(max-width:700px){{.vs-kpis{{grid-template-columns:repeat(2,1fr)}}}}
.vs-kpi{{padding:10px 11px;border-radius:9px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.09);text-align:center}}
.vs-kpi.gap{{background:rgba(255,100,60,.07);border-color:rgba(255,100,60,.28);border-style:dashed}}
.vs-kval{{font-size:15px;font-weight:800;letter-spacing:-.02em;color:#fff}}
.vs-kpi.gap .vs-kval{{color:#ffb07a}}
.vs-klabel{{font-size:8.5px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;color:var(--muted2);margin-top:3px}}
.vs-ksub{{font-size:7.5px;color:var(--muted2);margin-top:1px;opacity:.7}}
.vs-blocks{{display:flex;flex-direction:column;gap:5px}}
.vs-block{{display:flex;align-items:flex-start;gap:10px;padding:8px 10px;border-radius:8px;background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);border-left:3px solid rgba(255,255,255,.15)}}
.vs-block.crit{{border-left-color:var(--red)}}
.vs-block.warn{{border-left-color:var(--yellow)}}
.vs-btext{{font-size:11px;font-weight:600;color:#e4eaff;line-height:1.4}}
.vs-bsub{{font-size:8.5px;color:var(--muted2);margin-top:2px}}
/* ── E1 hero RAG badge ── */
.prog-rag-badge{{display:inline-block;padding:7px 16px;border-radius:8px;font-size:11px;font-weight:800;
  letter-spacing:.08em;text-transform:uppercase;background:rgba(232,64,10,.18);color:#fca5a5;
  border:1px solid rgba(232,64,10,.45);margin-bottom:16px}}
/* ── E5 track chips ── */
.track-chips{{padding:10px 20px;margin:0 0 48px;border-radius:10px;
  background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);
  font-size:12px;color:var(--muted);display:flex;align-items:center;gap:14px;flex-wrap:wrap}}
.tc-label{{font-size:9px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);white-space:nowrap}}
.tc-chip{{font-size:11px;font-weight:600;display:inline-flex;align-items:center;gap:4px}}
/* ── E7 R4.1 gate ── */
.r41-gate{{padding:20px 24px;margin-top:28px;border-radius:14px;
  background:rgba(240,210,36,.06);border:1px solid rgba(240,210,36,.22)}}
.r41-label{{font-size:9px;font-weight:700;letter-spacing:.15em;text-transform:uppercase;color:var(--yellow);margin-bottom:6px}}
.r41-title{{font-size:15px;font-weight:700;color:#e4eaff;margin-bottom:6px}}
.r41-desc{{font-size:12px;color:var(--muted);line-height:1.55}}
</style></head>
<body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div id="prog"></div>

<nav>
  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display='none'">
  <span class="nt">Unity — Plan Director</span>
  <span class="sp"></span>
  <span class="nav-links" style="display:contents">
    <a class="jump" href="#view-productos">Alcance</a>
    <a class="jump" href="#acciones">Acciones</a>
    <a class="jump" href="#riesgos">Riesgos</a>
    <a class="jump" href="#cronograma">Cronograma</a>
  </span>
</nav>

<div class="wrap">

  <header class="hero">
    <div>
      <div class="eyebrow reveal">
        <span class="dot"></span>&nbsp; SPE-AM-001, Unity, BUILD, ago 2026
      </div>
      <div class="prog-rag-badge reveal">🔴 Programa en Riesgo · corte 2026-08-20</div>
      <h1 class="reveal">Plan Director<br>Unity</h1>
      <p class="sub reveal">
        Programa de modernización del core bancario BanCoppel.<br>
        Tarjeta de Crédito · Crédito Simple Empresarial.<br>
        SmartVista BPC, APOLO, Temenos Transact.
      </p>
      <div class="countdown glass reveal">
        <div class="cdays" id="cdays">{days}</div>
        <div class="clabel">días al Go-Live — 15 enero 2027</div>
        <div class="clabel" style="color:#fca5a5;margin-top:4px">⚠ Rezago −39.4pp vs baseline</div>
      </div>
    </div>

    <div class="hero-cube-zone reveal">
      <div class="cube-hint">Marco de referencia 3D — Arrastra para explorar</div>
      <div class="scene3d" id="scene3d">
        <div class="cube3d" id="cube3d">
          <div class="cf cf-top">
            <div class="cf-title">Productos</div>
            {cube_prod}
          </div>
          <div class="cf cf-front">
            <div class="cf-title">Sistemas</div>
            {cube_sis}
          </div>
          <div class="cf cf-right">
            <div class="cf-title">Capacidades IT</div>
            {cube_cap}
          </div>
          <div class="cf cf-back"><div class="cf-title">Unity</div></div>
          <div class="cf cf-left"></div>
          <div class="cf cf-bot"></div>
        </div>
      </div>
    </div>
  </header>

  <div class="stats reveal" style="margin:0 0 16px">
    <div class="stat glass">
      <div class="statn" id="s-days">{days}</div>
      <div class="statl">Días al Go-Live — 15 Enero 2027</div>
    </div>
    <div class="stat glass warn">
      <div class="statn">21.19%</div>
      <div class="statl">Avance Global Unity R4 · −39.4pp vs baseline 60.58%</div>
    </div>
    <div class="stat glass">
      <div class="statn" data-target="{hus}">0</div>
      <div class="statl">User Stories, 46 Must</div>
    </div>
    <div class="stat glass danger">
      <div class="statn" data-target="{risks_n}">0</div>
      <div class="statl">Riesgos Alta Prioridad</div>
    </div>
    <div class="stat glass danger">
      <div class="statn" data-target="{breach_n}">0</div>
      <div class="statl">Acciones en BREACH — fecha vencida</div>
    </div>
  </div>

  <div class="track-chips reveal" style="margin-bottom:52px">
    <span class="tc-label">RAG por track</span>
    <span class="tc-chip">🔴 CAT</span>
    <span class="tc-chip">🔴 Cobranza</span>
    <span class="tc-chip">🟡 SmartVista</span>
    <span class="tc-chip">🟡 APP</span>
    <span class="tc-chip">🟡 APOLO</span>
    <span class="tc-chip">🟡 SIWEB</span>
  </div>

  <section id="view-productos">
    {view_prod}
  </section>

  <section id="view-sistemas">
    {view_sis}
  </section>

  <section id="view-capacidades">
    {view_cap}
  </section>

  <section id="acciones">
    <div class="shead reveal">
      <div class="kick">Plan Director · Acciones Abiertas</div>
      <h2>{len(data.get("actions", []))} Acciones Críticas y Altas al Go-Live</h2>
      <p>Acciones abiertas del RAID — corte 14-ago-2026. Las marcadas BREACH tienen fecha vencida al 20-ago-2026.</p>
    </div>
    <div class="act-grid">
      {action_html}
    </div>
    <div class="wrap">
      <div class="r41-gate glass reveal">
        <div class="r41-label">Gate de Decisión · R4.1</div>
        <div class="r41-title">9 User Stories candidatas a diferir a R4.1</div>
        <p class="r41-desc">El Roadmap Accenture (11-ago-2026) identifica 9 User Stories que pueden simplificarse o diferirse sin impacto crítico en el go-live de enero 2027. Decisión de alcance requerida antes del inicio de SIT (15-oct-2026) para liberar capacidad de desarrollo y pruebas.</p>
      </div>
    </div>
  </section>

  <section id="riesgos">
    <div class="shead reveal">
      <div class="kick">Registro de Riesgos</div>
      <h2>Riesgos de Alta Prioridad</h2>
      <p>{risks_n} riesgos de probabilidad alta, RAID v2.0 con corte 03-ago-2026, responsable Ma. Fernanda Barbosa</p>
    </div>
    <div class="risk-grid reveal">
      {risk_html}
    </div>
  </section>

  <section id="cronograma">
    <div class="shead reveal">
      <div class="kick">Hitos R4</div>
      <h2>Cronograma al Go-Live</h2>
      <p>Fechas clave, Inicio SIT octubre, Code Freeze diciembre, Go-Live 15-ene-2027</p>
    </div>
    <div class="reveal">
      <div class="tl">
        {mile_html}
      </div>
    </div>
  </section>

</div>

<footer>
  <code>Unity, Plan Director, SPE-AM-001</code>, BanCoppel, Accenture México<br>
  Generado desde brain.db el {generated} · Gemelo Cognitivo — Capa Estratégica
</footer>

<script>
  document.querySelectorAll('nav a.jump[href^="#"]').forEach(a=>{{
    a.addEventListener('click',e=>{{
      e.preventDefault();
      const el=document.querySelector(a.getAttribute('href'));
      if(el)el.scrollIntoView({{behavior:'smooth'}});
    }});
  }});
  window.addEventListener('scroll',()=>{{
    const p=(window.scrollY/(document.body.scrollHeight-window.innerHeight))*100;
    document.getElementById('prog').style.width=p+'%';
  }});
  (function(){{
    const goLive=new Date('2027-01-15');
    const today=new Date();today.setHours(0,0,0,0);
    const days=Math.ceil((goLive-today)/(1000*60*60*24));
    ['cdays','s-days'].forEach(id=>{{const el=document.getElementById(id);if(el)el.textContent=days;}});
  }})();
  function animateCounter(el){{
    const target=parseInt(el.getAttribute('data-target'));
    if(!target)return;
    let start=0;const duration=1200;const step=target/duration*16;
    const tick=()=>{{start=Math.min(start+step,target);el.textContent=Math.round(start);if(start<target)requestAnimationFrame(tick);}};
    requestAnimationFrame(tick);
  }}
  const ro=new IntersectionObserver(entries=>{{
    entries.forEach(e=>{{
      if(e.isIntersecting){{
        e.target.classList.add('in');
        if(e.target.classList.contains('stats'))
          e.target.querySelectorAll('[data-target]').forEach(animateCounter);
      }}
    }});
  }},{{threshold:.12}});
  document.querySelectorAll('.reveal').forEach(el=>ro.observe(el));

  const cube=document.getElementById('cube3d');
  const scene=document.getElementById('scene3d');
  let rotX=-30,rotY=-30,isDragging=false,startX=0,startY=0;
  let isAuto=true,lastT=0,autoDir=1;
  function clamp(){{rotX=Math.max(-90,Math.min(5,rotX));rotY=Math.max(-90,Math.min(5,rotY));}}
  function apply(){{cube.style.transform=`rotateX(${{rotX}}deg) rotateY(${{rotY}}deg)`;}}
  (function loop(now){{
    if(isAuto&&!isDragging){{
      const dt=Math.min((now-lastT)/1000,.05);
      rotY+=dt*12*autoDir;
      if(rotY>5){{rotY=5;autoDir=-1;}}
      if(rotY<-90){{rotY=-90;autoDir=1;}}
      apply();
    }}
    lastT=now;requestAnimationFrame(loop);
  }})(0);
  scene.addEventListener('mouseenter',()=>{{isAuto=false;}});
  scene.addEventListener('mouseleave',()=>{{if(!isDragging)isAuto=true;}});
  scene.addEventListener('mousedown',e=>{{
    isDragging=true;startX=e.clientX;startY=e.clientY;
    cube.classList.add('dragging');isAuto=false;
  }});
  window.addEventListener('mousemove',e=>{{
    if(!isDragging)return;
    rotY+=(e.clientX-startX)*.4;rotX-=(e.clientY-startY)*.4;
    clamp();startX=e.clientX;startY=e.clientY;apply();
  }});
  window.addEventListener('mouseup',()=>{{isDragging=false;cube.classList.remove('dragging');}});
  let tx=0,ty=0;
  scene.addEventListener('touchstart',e=>{{e.preventDefault();tx=e.touches[0].clientX;ty=e.touches[0].clientY;cube.classList.add('dragging');isAuto=false;}},{{passive:false}});
  scene.addEventListener('touchmove',e=>{{
    e.preventDefault();
    rotY+=(e.touches[0].clientX-tx)*.4;rotX-=(e.touches[0].clientY-ty)*.4;
    clamp();tx=e.touches[0].clientX;ty=e.touches[0].clientY;apply();
  }},{{passive:false}});
  scene.addEventListener('touchend',()=>cube.classList.remove('dragging'));
</script>
</body></html>
"""


# ── Main ──────────────────────────────────────────────────────────────────────


# ── v1.5.0 Vista Sistemas — datos editoriales del plan de entrega ─────────────

TOGAF_TYPE_COLOR = {
    "core":        "#7B61FF",
    "processors":  "#FF6B35",
    "channels":    "#00C4CC",
    "data":        "#FFC107",
    "integration": "#4CAF50",
    "compliance":  "#9C27B0",
}

TOGAF_STATE_LABEL = {
    "baseline":     "",
    "transitional": "EN MIGRACIÓN",
    "target":       "TO-BE",
}

SDLC_PHASES_LIST = ["DISCOVER", "DESIGN", "BUILD", "TEST", "RELEASE", "OPERATE"]

SYSTEM_SDLC = {
    "informix": {
        "exclude": True, "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "summary": "Core bancario actual (AIX/POWER). Sistema de registro hasta el cutover. Fuente de 10,144 SPs y 11,391 reglas de negocio a migrar a Transact.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Extraccion reglas GemCog v1.5.0",       "date": "2026-08-20","status": "done"},
            {"label": "Parallel-run Informix + Transact",      "date": "2026-Q4",   "status": "pending"},
            {"label": "Cutover final — Informix a DEPRECATE",  "date": "2027-Q1",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-CREDIT-LIMIT","CAP-PAYMENT","CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION","CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE","CAP-CUSTOMER-PROFILE","CAP-ONBOARDING-DIGITAL","CAP-DEFERRED-PURCHASE"],
    },
    "transact": {
        "sdlc_phase": "BUILD", "sdlc_progress": 40, "sdlc_status": "yellow",
        "summary": "Plataforma core bancario destino (Temenos Transact). Configuracion TDC P4900 completa. Pendiente SIT integrado con SmartVista y UAT de contabilidad GL.",
        "milestones": [
            {"label": "Contrato Temenos firmado",              "date": "2026-01",   "status": "done"},
            {"label": "Configuracion productos TDC P4900",     "date": "2026-08",   "status": "done"},
            {"label": "SIT Transact-SmartVista-eGlobal",       "date": "2026-10",   "status": "pending"},
            {"label": "UAT contabilidad GL end-to-end",        "date": "2026-11",   "status": "pending"},
            {"label": "GoLive R4",                             "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-ONBOARDING-DIGITAL","CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION","CAP-ERROR-CATALOG","CAP-CUSTOMER-PROFILE","CAP-COLLECTIONS-ENGINE"],
    },
    "smartvista": {
        "sdlc_phase": "BUILD", "sdlc_progress": 55, "sdlc_status": "red",
        "summary": "Motor de gestion de tarjetas TDC P4900 (BPC Banking Technologies). 2 DTMs sin cobertura: DPP modulo no contratado (sin decision de remediacion) y BYU0039 abierto en investigacion.",
        "milestones": [
            {"label": "Contrato BPC firmado",                  "date": "2026-01",   "status": "done"},
            {"label": "22 User Stories SmartVista catalogados",        "date": "2026-08-01","status": "done"},
            {"label": "Correccion macro APP-MF-02 (QA)",       "date": "2026-08-20","status": "done"},
            {"label": "SIT SmartVista-Transact-eGlobal",       "date": "2026-10",   "status": "pending"},
            {"label": "UAT tarjeta de credito end-to-end",     "date": "2026-11",   "status": "pending"},
            {"label": "GoLive — CMS/Intercard a DEPRECATE",   "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-PAYMENT","CAP-DEFERRED-PURCHASE","CAP-CARD-MANUFACTURING","CAP-OVERPAYMENT","CAP-AUTHORIZATION","CAP-FEE-COMMISSION","CAP-ERROR-CATALOG"],
    },
    "apolo": {
        "sdlc_phase": "BUILD", "sdlc_progress": 45, "sdlc_status": "red",
        "summary": "Canal digital (Appwhere) para oferta y originacion de TDC. Issue I03: celula sin contratar (abierto 3+ meses, impacto sistemico critico). R05: latencia en PROD sin plan de mejora firmado.",
        "milestones": [
            {"label": "37 User Stories APOLO catalogadas",     "date": "2026-08-01","status": "done"},
            {"label": "Integracion Apolo-Transact (API)",      "date": "2026-09",   "status": "pending"},
            {"label": "SIT originacion TDC completa",          "date": "2026-10",   "status": "pending"},
            {"label": "GoLive canal Apolo",                    "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-ONBOARDING-DIGITAL","CAP-DEFERRED-PURCHASE","CAP-CUSTOMER-PROFILE"],
    },
    "app-movil": {
        "sdlc_phase": "BUILD", "sdlc_progress": 42, "sdlc_status": "yellow",
        "summary": "Canal movil BanCoppel (Nova). Canal principal del cliente digital: activacion de tarjeta, autorizacion TDC, pagos, consultas de saldo y compras diferidas.",
        "milestones": [
            {"label": "18 User Stories canal App TDC R4",       "date": "2026-08-19","status": "done"},
            {"label": "Encendido/Apagado TDC (+3 User Stories)","date": "2026-08-19","status": "done"},
            {"label": "SIT App-SmartVista-Transact",           "date": "2026-10",   "status": "pending"},
            {"label": "UAT cliente digital",                   "date": "2026-11",   "status": "pending"},
            {"label": "GoLive App Movil TDC",                  "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-PAYMENT","CAP-BALANCE-STATEMENT","CAP-DEFERRED-PURCHASE","CAP-COLLECTIONS-AGING","CAP-CARD-LIFECYCLE","CAP-ONBOARDING-DIGITAL"],
    },
    "siweb": {
        "sdlc_phase": "DISCOVER", "sdlc_progress": 15, "sdlc_status": "red",
        "summary": "Canal web de sucursal (ventanilla interna BanCoppel). 5 User Stories Must Have. Bloqueado: APIs SmartVista BPC sin fecha de entrega confirmada.",
        "milestones": [
            {"label": "5 User Stories definidas (requerimientos)",     "date": "2026-07",   "status": "done"},
            {"label": "APIs SmartVista disponibles",           "date": "TBD",       "status": "pending"},
            {"label": "Desarrollo e integracion SIWEB",        "date": "TBD",       "status": "planned"},
            {"label": "SIT canal sucursal",                    "date": "TBD",       "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-BALANCE-STATEMENT","CAP-DEFERRED-PURCHASE","CAP-ACCOUNTING-INTEGRATION","CAP-OVERPAYMENT"],
    },
    "cat": {
        "sdlc_phase": "DISCOVER", "sdlc_progress": 20, "sdlc_status": "red",
        "summary": "Contact Center (IVR + agentes). 12 User Stories Must Have. Proveedor sin contratar al 2026-08-31 — sin owner tecnico ni plan de pruebas posible. RISK-001 activo.",
        "milestones": [
            {"label": "12 User Stories CAT definidas",         "date": "2026-07",   "status": "done"},
            {"label": "RFP / seleccion de proveedor",          "date": "2026-08-31","status": "pending"},
            {"label": "Contrato y kickoff proveedor",          "date": "2026-09",   "status": "planned"},
            {"label": "SIT Contact Center (IVR-SVIP)",         "date": "TBD",       "status": "planned"},
            {"label": "GoLive CAT",                            "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-CHANNEL-SELFSERVICE","CAP-AUTHENTICATION","CAP-BALANCE-STATEMENT","CAP-CUSTOMER-PROFILE","CAP-CARD-LIFECYCLE","CAP-COLLECTIONS-AGING"],
    },
    "atlas": {
        "sdlc_phase": "BUILD", "sdlc_progress": 25, "sdlc_status": "yellow",
        "summary": "Plataforma de datos analiticos en GCP (BigQuery + Dataflow). Landing zone aprovisionada. Pendiente: pipelines Informix→Atlas y reportes CNBV. R09: Golden Record Fase 2 sin confirmar alcance.",
        "milestones": [
            {"label": "Landing zone GCP aprovisionada",        "date": "2026-07",   "status": "done"},
            {"label": "Pipelines Informix a Atlas (Dataflow)", "date": "2026-09",   "status": "pending"},
            {"label": "Integracion reportes CNBV Anexos",      "date": "2026-10",   "status": "pending"},
            {"label": "GoLive Atlas (analitica + regulatorio)","date": "2026-11",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-BALANCE-STATEMENT","CAP-COLLECTIONS-AGING","CAP-FEE-COMMISSION"],
    },
    "controlm": {
        "exclude": True, "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "summary": "Orquestador de batch BMC Control-M. Jobs criticos: cierre de dia, comisiones, cobranza, estados de cuenta nocturnos. Permanece como baseline en R4.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Nuevos jobs TDC P4900 (cierre dia)",    "date": "2026-Q4",   "status": "pending"},
            {"label": "Validacion SLA batch post-GoLive",      "date": "2027-Q1",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION","CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE"],
    },
    "eglobal": {
        "exclude": True, "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "summary": "Switch ISO 8583 interno BanCoppel. Valida 88 reglas de transacciones TDC contra SmartVista. Frontera critica de autorizacion en tiempo real.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Validacion 88 reglas vs SmartVista",    "date": "2026-08",   "status": "done"},
            {"label": "SIT eGlobal-SmartVista-Transact",       "date": "2026-09",   "status": "pending"},
            {"label": "Pruebas de carga ISO 8583 P4900",       "date": "2026-10",   "status": "pending"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-PAYMENT"],
    },
    "cobranza": {
        "sdlc_phase": "BUILD", "sdlc_progress": 30, "sdlc_status": "yellow",
        "summary": "Cobranza Direccionada — gestión de cartera vencida TDC P4900. 37-50 User Stories pendientes de incorporar al inventario R4. Riesgo: pentest nov 15-20 congela el unico ambiente de SIT.",
        "milestones": [
            {"label": "37-50 USs identificadas (Cobranza Dir.)", "date": "2026-07",   "status": "done"},
            {"label": "Incorporacion al inventario R4 formal",   "date": "2026-09",   "status": "pending"},
            {"label": "SIT Cobranza (fuera de ventana pentest)", "date": "2026-11",   "status": "pending"},
            {"label": "UAT cobranza + Buró de Crédito",          "date": "2026-11",   "status": "planned"},
            {"label": "GoLive Cobranza Direccionada",            "date": "2027-01",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-COLLECTIONS-AGING","CAP-COLLECTIONS-ENGINE","CAP-PAYMENT"],
    },
    "connect-direct": {
        "exclude": True, "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "yellow",
        "summary": "Transferencia segura de archivos batch (IBM Sterling). Mueve archivos entre sistemas internos y redes VISA/MC. Licencia a revisar — alternativa MFT en evaluacion.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Evaluacion alternativa MFT",            "date": "2026-09",   "status": "pending"},
            {"label": "Decision de renovacion / migracion",    "date": "2026-10",   "status": "pending"},
            {"label": "Resolucion de riesgo de licencia",      "date": "2026-11",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-CARD-MANUFACTURING"],
    },
}




ITCAP_RISKS = {
    "testing":        [{"level":"warn","text":"Pentest nov 15-20 en conflicto directo con ventana SIT — sin resolución confirmada"},
                       {"level":"warn","text":"CAT sin plan de pruebas — 12 User Stories Must sin cobertura QE"}],
    "devops":         [{"level":"warn","text":"Pipelines SIT sin ambiente confirmado al 15-oct"}],
    "arquitectura":   [{"level":"warn","text":"18 integraciones R4 sin mapa de dependencias validado"}],
    "interop":        [{"level":"crit","text":"APIs SmartVista BPC sin fecha — bloquea 6 User Stories SIWEB (HDU-SWEB-R4-01…06)"},
                       {"level":"warn","text":"18 integraciones R4 sin contrato de API firmado"}],
    "ambientacion":   [{"level":"warn","text":"Entorno SIT al 15-oct sin confirmar — deuda configuración canal CAT"}],
    "seguridad":      [{"level":"warn","text":"PCI-DSS v4.0 en scope SmartVista — sin plan de remediación documentado"},
                       {"level":"warn","text":"Pentest conflicto nov 15-20 con SIT — riesgo de slip SIT a dic"}],
    "observabilidad": [{"level":"warn","text":"Alerting y dashboards Dynatrace sin activar — go-live sin observabilidad"}],
    "change":         [{"level":"warn","text":"Plan cambio organizacional 3M tarjetahabientes sin ejecutar — riesgo de baja adopción"}],
    "release":        [{"level":"warn","text":"Go-Live 15-ene-2027 con margen mínimo — SIT debe cerrar el 15-dic"}],
    "vendor":         [{"level":"crit","text":"RISK-001: CAT sin proveedor contratado — 12 User Stories Must sin owner técnico"},
                       {"level":"warn","text":"DPP y BYU0039 abiertos con BPC sin fecha de cierre"}],
    "compliance":     [{"level":"warn","text":"Hallazgos APO_F01 y SMA_F01 CNBV abiertos — documentación desactualizada"},
                       {"level":"warn","text":"Bajaware en proceso de decomiso — riesgo regulatorio pendiente"}],
    "data":           [{"level":"warn","text":"Golden Record en Informix sin plan de carga inicial a ATLAS (target sep-2026)"},
                       {"level":"warn","text":"Exodus Ola 6 en 2029 — riesgo de datos duplicados durante migración"}],
}


def build_capacidades_it_page(brain_path: str, out_dir) -> None:
    """Genera portal/capacidades-it.html — drill-down Vista Capacidades IT."""
    from datetime import date as _date
    from pathlib import Path as _Path

    _MONTH_ES = {"ene":1,"feb":2,"mar":3,"abr":4,"may":5,"jun":6,
                 "jul":7,"ago":8,"sep":9,"oct":10,"nov":11,"dic":12}

    def _parse_due(s):
        if not s: return None
        parts = s.strip().split("-")
        if len(parts) == 2:
            day, mon = parts
            m = _MONTH_ES.get(mon.lower())
            if m:
                try: return _date(2026, m, int(day))
                except: return None
        return None

    URGENT_THRESHOLD = _date(2026, 9, 10)

    # ── Stats para el hero ───────────────────────────────────────────────────────
    n_caps   = len(IT_CAP_META)
    n_level1 = sum(1 for m in IT_CAP_META.values() if m.get("mat_cur",2) == 1)
    n_urgent = sum(1 for m in IT_CAP_META.values()
                   if (d := _parse_due(m.get("next_due",""))) and d <= URGENT_THRESHOLD)
    n_owners = len(set(m.get("owner","") for m in IT_CAP_META.values() if m.get("owner","")))
    n_days   = days_to_golive()

    mat_color = {1: "#ef4444", 2: "#f59e0b", 3: "#84cc16", 4: "#22c55e"}
    mat_pct   = {1: 0, 2: 33, 3: 66, 4: 100}
    sem_dot_color = {"crit": "#ef4444", "warn": "#f59e0b", "ok": "#22c55e"}

    # ── Tarjetas ──────────────────────────────────────────────────────────────────
    cards_html = ""
    for cap_id, meta in IT_CAP_META.items():
        sem       = meta["sem"]
        dot_color = sem_dot_color.get(sem, "#888")
        mat_cur   = meta.get("mat_cur", 2)
        mat_tgt   = meta.get("mat_tgt", 4)
        cp        = mat_pct.get(mat_cur, 0)
        tp        = mat_pct.get(mat_tgt, 100)
        fc        = mat_color.get(mat_cur, "#f59e0b")
        owner     = meta.get("owner", "")
        nxt       = meta.get("next_action", "")
        due_str   = meta.get("next_due", "")
        due_date  = _parse_due(due_str)
        is_urgent = bool(due_date and due_date <= URGENT_THRESHOLD)
        group     = meta.get("group", "")
        note      = meta.get("note", "")

        # barra de madurez expandida
        tgt_dot = ""
        if mat_tgt != mat_cur:
            tgt_dot = '<div class="mat-dot-tgt" style="left:' + str(tp) + '%"></div>'
        mat_bar = (
            '<div class="mat-wrap-ex">'
            '<div class="mat-track-ex">'
            '<div class="mat-fill-ex" style="width:' + str(cp) + '%;background:' + fc + '"></div>'
            '<div class="mat-dot-cur-ex" style="left:' + str(cp) + '%"></div>'
            + tgt_dot +
            '</div>'
            '<div class="mat-labels-ex">'
            '<div class="mat-label-ex" style="left:0%">'
            '<span>1</span><span class="mat-level-ex">Inexistente</span></div>'
            '<div class="mat-label-ex" style="left:33%;transform:translateX(-50%)">'
            '<span>2</span><span class="mat-level-ex">Inicial</span></div>'
            '<div class="mat-label-ex" style="left:66%;transform:translateX(-50%)">'
            '<span>3</span><span class="mat-level-ex">Definido</span></div>'
            '<div class="mat-label-ex" style="left:100%;transform:translateX(-100%)">'
            '<span>4</span><span class="mat-level-ex">Operado</span></div>'
            '</div>'
            '</div>'
        )

        owner_html = '<div class="card-owner">&#128100;&nbsp;' + h(owner) + '</div>' if owner else ""

        if nxt:
            urgency = ' <span class="badge-urgente">URGENTE</span>' if is_urgent else ""
            next_html = (
                '<div class="card-next">&#8599;&nbsp;' + h(nxt)
                + '&nbsp;<span class="due-date">' + h(due_str) + '</span>' + urgency + '</div>'
            )
        else:
            next_html = ""

        note_html = (
            '<div class="card-note">' + h(note) + '</div>' if note else ""
        )

        risks = ITCAP_RISKS.get(cap_id, [])
        risks_html = ""
        if risks:
            risk_items = ""
            for r in risks:
                dot_icon = "&#9679;" if r["level"] == "crit" else "&#9650;"
                risk_items += (
                    '<div class="risk-item ' + r["level"] + '">'
                    + '<span class="risk-dot">' + dot_icon + '</span>'
                    + '<span>' + h(r["text"]) + '</span></div>'
                )
            risks_html = (
                '<div class="risks-section">'
                + '<div class="risks-title">Riesgos vinculados</div>'
                + risk_items
                + '</div>'
            )

        grp_slug = group.lower().replace(" ", "-")
        group_badge = '<span class="group-badge group-' + grp_slug + '">' + h(group) + '</span>'

        cards_html += (
            '<div class="it-card ' + sem + '">'
            + '<div class="card-header">'
            + '<span class="sem-dot" style="background:' + dot_color + '"></span>'
            + '<span class="card-name">' + h(meta["name"]) + '</span>'
            + group_badge
            + '</div>'
            + mat_bar
            + owner_html
            + next_html
            + note_html
            + risks_html
            + '</div>\n'
        )

    # ── Tabla resumen ───────────────────────────────────────────────────────────
    table_rows = ""
    for cap_id, meta in IT_CAP_META.items():
        mc        = meta.get("mat_cur", 2)
        mt        = meta.get("mat_tgt", 4)
        sem       = meta["sem"]
        dot_color = sem_dot_color.get(sem, "#888")
        due_str   = meta.get("next_due", "")
        due_date  = _parse_due(due_str)
        is_urgent = bool(due_date and due_date <= URGENT_THRESHOLD)
        urgency   = ' <span class="badge-urgente">URGENTE</span>' if is_urgent else ""
        grp_slug  = meta.get("group","").lower().replace(" ","-")
        table_rows += (
            '<tr>'
            + '<td><span class="sem-dot-sm" style="background:' + dot_color + '"></span>'
            + h(meta["name"]) + '</td>'
            + '<td><span class="group-badge group-' + grp_slug + '">'
            + h(meta.get("group","")) + '</span></td>'
            + '<td class="mat-cell">' + str(mc) + ' <span class="mat-arr">&rarr;</span> ' + str(mt) + '</td>'
            + '<td>' + h(meta.get("owner","")) + '</td>'
            + '<td>' + h(meta.get("next_action","")) + '</td>'
            + '<td>' + h(due_str) + urgency + '</td>'
            + '</tr>\n'
        )

    # ── CSS embebido ──────────────────────────────────────────────────────────────
    _CSS_LINES = [
        '*{box-sizing:border-box;margin:0;padding:0}',
        ':root{',
        '  --bg:#0a1628;--bg2:#0d1d35;--blue:#122FB1;--yellow:#F0D224;',
        '  --red:#ef4444;--green:#22c55e;--text:#e4eaff;',
        '  --muted:rgba(228,234,255,.45);--muted2:rgba(228,234,255,.25);',
        '  --glass:rgba(255,255,255,.04);--glassb:rgba(255,255,255,.08)}',
        'html{scroll-behavior:smooth}',
        'body{background:var(--bg);color:var(--text);font-family:\'SF Pro Display\',-apple-system,BlinkMacSystemFont,\'Inter\',\'Segoe UI\',Calibri,sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}',
        '.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}',
        '.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.55),transparent 70%);animation:f1 24s ease-in-out infinite}',
        '.aurora::after{content:"";position:absolute;width:50vw;height:50vw;right:-10vw;top:10vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.65),transparent 70%);animation:f2 28s ease-in-out infinite}',
        '@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.12)}}',
        '@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.10)}}',
        '.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns=\'http://www.w3.org/2000/svg\' width=\'140\' height=\'140\'%3E%3Cfilter id=\'n\'%3E%3CfeTurbulence type=\'fractalNoise\' baseFrequency=\'.85\' numOctaves=\'2\' stitchTiles=\'stitch\'/%3E%3C/filter%3E%3Crect width=\'100%25\' height=\'100%25\' filter=\'url(%23n)\'/%3E%3C/svg%3E")}',
        '#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}',
        'nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:13px 28px;backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);background:rgba(10,22,40,.7);border-bottom:1px solid rgba(255,255,255,.06)}',
        'nav img{height:18px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}',
        'nav .nt{font-size:12px;font-weight:600;color:var(--muted)}',
        '.sp{flex:1}',
        'nav a{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:20px;transition:.2s;text-decoration:none}',
        'nav a:hover{color:var(--text);background:rgba(255,255,255,.07)}',
        'nav a.hl{color:var(--yellow)}',
        'main{padding-top:56px}',
        '.wrap{max-width:1240px;margin:0 auto;padding:0 28px}',
        '.hero{padding:80px 0 44px}',
        '.eyebrow{display:inline-flex;align-items:center;gap:8px;padding:7px 14px;border-radius:30px;font-size:11px;font-weight:700;letter-spacing:.05em;color:#dfe6ff;margin-bottom:20px;background:rgba(255,255,255,.05);border:1px solid var(--glassb);backdrop-filter:blur(10px)}',
        '.eyebrow .dot{width:6px;height:6px;border-radius:50%;background:var(--yellow);box-shadow:0 0 10px var(--yellow);animation:pulse 2.4s infinite}',
        '@keyframes pulse{50%{opacity:.35}}',
        'h1{font-size:clamp(26px,3.8vw,50px);font-weight:800;line-height:1.08;letter-spacing:-.03em;background:linear-gradient(175deg,#fff 30%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}',
        '.sub{font-size:14px;color:var(--muted);margin-top:14px;max-width:72ch;line-height:1.6}',
        '.sub b{color:#e4eaff;font-weight:600}',
        '.stats{display:flex;gap:12px;margin-top:28px;flex-wrap:wrap}',
        '.stat{padding:14px 20px;border-radius:16px;background:var(--glass);border:1px solid var(--glassb);backdrop-filter:blur(16px);display:flex;flex-direction:column;gap:4px;min-width:110px}',
        '.stn{font-size:22px;font-weight:800;letter-spacing:-.02em;background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}',
        '.stl{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}',
        '.stat.warn{border-color:rgba(240,210,36,.35);background:rgba(240,210,36,.06)}',
        '.stat.warn .stn{background:linear-gradient(180deg,var(--yellow),#e0b800);-webkit-background-clip:text;background-clip:text}',
        '.section-hdr{display:flex;align-items:center;justify-content:space-between;margin:44px 0 20px}',
        '.section-kick{font-size:.68rem;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--yellow)}',
        '.caps-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin:0 0 64px}',
        '@media(max-width:900px){.caps-grid{grid-template-columns:1fr}}',
        '.it-card{background:var(--glass);border:1px solid var(--glassb);border-radius:18px;padding:22px;display:flex;flex-direction:column;gap:14px}',
        '.it-card.crit{border-color:rgba(239,68,68,.35);background:rgba(239,68,68,.04)}',
        '.it-card.warn{border-color:rgba(245,158,11,.22);background:rgba(245,158,11,.025)}',
        '.it-card.ok{border-color:rgba(34,197,94,.22);background:rgba(34,197,94,.02)}',
        '.card-header{display:flex;align-items:center;gap:10px}',
        '.sem-dot{width:10px;height:10px;border-radius:50%;flex-shrink:0}',
        '.card-name{font-size:15px;font-weight:700;color:#fff;flex:1}',
        '.group-badge{padding:3px 10px;border-radius:20px;font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;flex-shrink:0}',
        '.group-engineering{background:rgba(99,102,241,.22);color:#a5b4fc}',
        '.group-delivery{background:rgba(14,165,233,.22);color:#7dd3fc}',
        '.group-operations{background:rgba(34,197,94,.18);color:#86efac}',
        '.group-data{background:rgba(251,191,36,.18);color:#fcd34d}',
        '.mat-wrap-ex{position:relative;margin:2px 0 34px}',
        '.mat-track-ex{position:relative;height:20px;background:rgba(255,255,255,.08);border-radius:10px;overflow:hidden}',
        '.mat-fill-ex{position:absolute;top:0;left:0;height:100%;border-radius:10px}',
        '.mat-dot-cur-ex{position:absolute;top:50%;transform:translate(-50%,-50%);width:14px;height:14px;border-radius:50%;background:#fff;border:2px solid rgba(0,0,0,.4);box-shadow:0 0 8px rgba(255,255,255,.6);z-index:3;overflow:visible}',
        '.mat-dot-tgt{position:absolute;top:50%;transform:translate(-50%,-50%);width:14px;height:14px;border-radius:50%;background:transparent;border:2px solid rgba(255,255,255,.65);box-shadow:0 0 6px rgba(255,255,255,.3);z-index:3;overflow:visible}',
        '.mat-labels-ex{position:absolute;top:24px;left:0;right:0;height:28px}',
        '.mat-label-ex{position:absolute;display:flex;flex-direction:column;align-items:center;gap:2px}',
        '.mat-label-ex>span:first-child{font-size:9px;font-weight:700;color:rgba(228,234,255,.55);letter-spacing:.04em}',
        '.mat-level-ex{font-size:7.5px;color:rgba(228,234,255,.3);white-space:nowrap;letter-spacing:.02em}',
        '.card-owner{font-size:12px;color:var(--muted)}',
        '.card-next{font-size:12px;color:var(--text);display:flex;align-items:center;gap:6px;flex-wrap:wrap;line-height:1.5}',
        '.due-date{color:var(--yellow);font-weight:700;font-size:11px}',
        '.badge-urgente{padding:2px 7px;border-radius:9px;font-size:8px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;background:rgba(239,68,68,.22);color:#fca5a5;border:1px solid rgba(239,68,68,.3)}',
        '.card-note{font-size:11px;color:var(--muted);line-height:1.55;background:rgba(255,255,255,.028);border-radius:8px;padding:8px 11px;border:1px solid rgba(255,255,255,.05)}',
        '.risks-section{border-top:1px solid rgba(255,255,255,.06);padding-top:10px}',
        '.risks-title{font-size:8px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:rgba(228,234,255,.28);margin-bottom:8px}',
        '.risk-item{display:flex;align-items:flex-start;gap:8px;padding:5px 0;border-bottom:1px solid rgba(255,255,255,.04);font-size:11px;color:var(--muted);line-height:1.4}',
        '.risk-item:last-child{border-bottom:none}',
        '.risk-dot{font-size:8px;flex-shrink:0;margin-top:2px;line-height:1}',
        '.risk-item.crit .risk-dot{color:var(--red)}',
        '.risk-item.warn .risk-dot{color:#f59e0b}',
        '.summary-section{margin:0 0 80px}',
        '.summary-label{font-size:10px;font-weight:700;color:rgba(228,234,255,.5);letter-spacing:.14em;text-transform:uppercase;margin-bottom:16px}',
        '.table-scroll{overflow-x:auto;border-radius:14px;border:1px solid var(--glassb)}',
        '.summary-table{width:100%;border-collapse:collapse;font-size:12px;min-width:720px}',
        '.summary-table th{text-align:left;padding:10px 14px;color:rgba(228,234,255,.38);font-size:8px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;border-bottom:1px solid rgba(255,255,255,.08);background:rgba(255,255,255,.03)}',
        '.summary-table td{padding:10px 14px;border-bottom:1px solid rgba(255,255,255,.04);color:var(--muted);vertical-align:middle;line-height:1.4}',
        '.summary-table tr:last-child td{border-bottom:none}',
        '.summary-table tr:hover td{background:rgba(255,255,255,.02)}',
        '.sem-dot-sm{display:inline-block;width:7px;height:7px;border-radius:50%;margin-right:5px;vertical-align:middle}',
        '.mat-cell{font-weight:600;color:#fff;white-space:nowrap}',
        '.mat-arr{color:var(--muted2);margin:0 3px}',
    ]
    _CSS = '\n'.join(_CSS_LINES)

    # ── HTML final ───────────────────────────────────────────────────────────────
    _html = (
        '<!DOCTYPE html>\n'
        '<html lang="es"><head><meta charset="UTF-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1.0">\n'
        '<title>Capacidades IT — Unity R4 — BanCoppel</title>\n'
        '<style>\n' + _CSS + '\n</style></head>\n'
        '<body>\n'
        '<div class="aurora"></div><div class="grain"></div><div id="prog"></div>\n'
        '<nav>\n'
        '  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display=\'none\'">\n'
        '  <span class="nt">Unity R4 — Gobernanza</span>\n'
        '  <span class="sp"></span>\n'
        '  <a class="hl" href="index.html">&#8592; Portal</a>\n'
        '  <a class="hl" href="#">Capacidades IT</a>\n'
        '</nav>\n'
        '<main>\n'
        '<div class="wrap">\n'
        '<div class="hero">\n'
        '  <div class="eyebrow"><span class="dot"></span>SPE-AM-001 &middot; Unity R4 &middot; Capacidades Transversales</div>\n'
        '  <h1>Gobernanza de Capacidades<br>Transversales de TI</h1>\n'
        '  <p class="sub">Estado de las ' + str(n_caps) + ' capacidades institucionales que habilitan el delivery del programa. '
        '<b>Gobiernan el SDLC, la demanda de proveedores, la seguridad y la resiliencia operativa del Go-Live.</b></p>\n'
        '  <div class="stats">\n'
        '    <div class="stat"><div class="stn">' + str(n_caps) + '</div><div class="stl">Capacidades IT</div></div>\n'
        '    <div class="stat warn"><div class="stn">' + str(n_level1) + '</div><div class="stl">En nivel 1 &middot; Inexistente</div></div>\n'
        '    <div class="stat warn"><div class="stn">' + str(n_urgent) + '</div><div class="stl">Acciones urgentes</div></div>\n'
        '    <div class="stat"><div class="stn">' + str(n_owners) + '</div><div class="stl">Propietarios</div></div>\n'
        '    <div class="stat warn"><div class="stn">' + str(n_days) + '</div><div class="stl">Días al Go-Live</div></div>\n'
        '  </div>\n'
        '</div>\n'
        '<div class="section-hdr">\n'
        '  <div class="section-kick">Estado por Capacidad</div>\n'
        '</div>\n'
        '<div class="caps-grid">\n' + cards_html + '</div>\n'
        '<div class="summary-section">\n'
        '  <div class="summary-label">Resumen de capacidades</div>\n'
        '  <div class="table-scroll">\n'
        '  <table class="summary-table">\n'
        '    <thead><tr>'
        '<th>Capacidad</th>'
        '<th>Grupo</th>'
        '<th>Madurez actual&rarr;objetivo</th>'
        '<th>Owner</th>'
        '<th>Próxima acción</th>'
        '<th>Fecha</th>'
        '</tr></thead>\n'
        '    <tbody>\n' + table_rows + '    </tbody>\n'
        '  </table>\n'
        '  </div>\n'
        '</div>\n'
        '</div></main>\n'
        '<script>\n'
        'window.addEventListener("scroll",function(){\n'
        '  var p=document.documentElement.scrollTop/(document.documentElement.scrollHeight-window.innerHeight)||0;\n'
        '  document.getElementById("prog").style.width=Math.round(p*100)+"%";\n'
        '});\n'
        '</script>\n'
        '</body></html>'
    )

    _out = _Path(out_dir) / "capacidades-it.html"
    _out.write_text(_html, encoding="utf-8")
    print(f"[build-portal] capacidades-it.html generado \u2713 ({len(_html):,} chars)")


def build_systems_page(brain_path: str, out_dir) -> None:
    """Genera portal/systems-p4900.html — drill-down Vista Sistemas."""
    import json as _json
    import sqlite3 as _sq

    con = _sq.connect(brain_path)

    # ── Cargar datos SDLC desde brain.db (v1.5.0) ────────────────────────────
    # Reemplaza el uso del diccionario SYSTEM_SDLC hardcodeado.
    # Fuente de verdad: tablas program_systems, program_system_milestones,
    # program_system_caps cargadas por build-brain.py::load_system_sdlc().
    _sdlc_db = {}
    for _r in con.execute(
        "SELECT id, sdlc_phase, sdlc_progress, sdlc_status, sdlc_summary, exclude_from_portal "
        "FROM program_systems"
    ).fetchall():
        _sdlc_db[_r[0]] = {
            "sdlc_phase":          _r[1] or "DISCOVER",
            "sdlc_progress":       _r[2] if _r[2] is not None else 0,
            "sdlc_status":         _r[3] or "yellow",
            "sdlc_summary":        _r[4] or "",
            "exclude_from_portal": bool(_r[5]),
        }

    _milestones_db = {}
    for _r in con.execute(
        "SELECT system_id, label, target_date, status "
        "FROM program_system_milestones ORDER BY system_id, seq"
    ).fetchall():
        _milestones_db.setdefault(_r[0], []).append(
            {"label": _r[1], "date": _r[2], "status": _r[3]}
        )

    _caps_db = {}
    for _r in con.execute(
        "SELECT system_id, capability_id FROM program_system_caps"
    ).fetchall():
        _caps_db.setdefault(_r[0], []).append(_r[1])

    # ── track_rag: RAG por track (normalizar 'app' → 'app-movil') ─────────────
    _track_rag = {}
    for _r in con.execute(
        "SELECT track, rag_color, hu_total, hu_must, hu_should, hu_could, hu_wont, "
        "integraciones_count, rag_general, rag_solucion, rag_integraciones, source_date "
        "FROM track_rag"
    ).fetchall():
        _key = "app-movil" if _r[0] == "app" else _r[0]
        _track_rag[_key] = {
            "rag_color": _r[1], "hu_total": _r[2], "hu_must": _r[3],
            "hu_should": _r[4], "hu_could": _r[5], "hu_wont": _r[6],
            "integraciones_count": _r[7], "rag_general": _r[8],
            "rag_solucion": _r[9], "rag_integraciones": _r[10], "source_date": _r[11],
        }

    # ── risks_by_system: riesgos abiertos por sistema e impacto ──────────────
    _risks_by_sys = {}
    for _r in con.execute(
        "SELECT system_id, impact, COUNT(*) FROM risks "
        "WHERE status != 'closed' GROUP BY system_id, impact"
    ).fetchall():
        _sid2, _imp, _n = _r
        if _sid2 not in _risks_by_sys:
            _risks_by_sys[_sid2] = {}
        _risks_by_sys[_sid2][_imp] = _n
    # ─────────────────────────────────────────────────────────────────────────

    systems = [
        r for r in con.execute(
            "SELECT id, name, vendor, togaf_type, togaf_state, togaf_abb, role_in_r4, status, notes "
            "FROM program_systems ORDER BY togaf_type, id"
        ).fetchall()
        if not _sdlc_db.get(r[0], {}).get('exclude_from_portal', False)
    ]
    caps = {r[0]: {'name': r[1], 'status': r[2]} for r in con.execute(
        "SELECT id, name, coverage_status FROM program_capabilities"
    ).fetchall()}
    systems_js = {}
    for row in systems:
        sid, name, vendor, ttype, tstate, tabb, role, st, notes = row
        sdlc = _sdlc_db.get(sid, {})
        _trag = _track_rag.get(sid, {})
        _rsys = _risks_by_sys.get(sid, {})
        systems_js[sid] = {
            "id": sid, "name": name, "vendor": vendor or "",
            "togaf_type": ttype, "togaf_state": tstate, "togaf_abb": tabb or "",
            "role_in_r4": role or "", "status": st,
            "color": TOGAF_TYPE_COLOR.get(ttype, "#666"),
            "state_label": TOGAF_STATE_LABEL.get(tstate, tstate.upper()),
            "sdlc_phase":    sdlc.get("sdlc_phase", "DISCOVER"),
            "sdlc_progress": sdlc.get("sdlc_progress", 0),
            "sdlc_status":   sdlc.get("sdlc_status", "yellow"),
            "summary":       sdlc.get("sdlc_summary", role or ""),
            "milestones":    _milestones_db.get(sid, []),
            "capabilities_impacted": [
                {"id": cid, "name": caps.get(cid, {}).get("name", cid),
                 "coverage": caps.get(cid, {}).get("status", "unknown")}
                for cid in _caps_db.get(sid, [])
            ],
            # ── track_rag fields (desde brain.db, None si el track no existe) ──
            "track_rag_color":         _trag.get("rag_color"),
            "hu_must":                 _trag.get("hu_must"),
            "hu_should":               _trag.get("hu_should"),
            "hu_total":                _trag.get("hu_total"),
            "rag_general":             _trag.get("rag_general"),
            "rag_solucion":            _trag.get("rag_solucion"),
            "rag_integraciones":       _trag.get("rag_integraciones"),
            "integraciones_count":     _trag.get("integraciones_count"),
            "track_rag_source_date":   _trag.get("source_date"),
            # ── risks fields ────────────────────────────────────────────────────
            "critical_risks": _rsys.get("critical", 0),
            "high_risks":     _rsys.get("high", 0),
        }

    systems_json = _json.dumps(systems_js, ensure_ascii=False, indent=2)

    by_type = {}
    for row in systems:
        sid, name, _, ttype, tstate, *_ = row
        sts = _sdlc_db.get(sid, {}).get("sdlc_status", "yellow")
        by_type.setdefault(ttype, []).append((sid, name, tstate, sts))

    type_order = ["core", "processors", "channels", "data", "integration", "compliance"]
    type_labels = {"core": "Core Bancario", "processors": "Procesadores",
                   "channels": "Canales", "data": "Datos", "integration": "Integracion",
                   "compliance": "Compliance"}

    # --- R4 sidebar ---
    sidebar_r4 = ""
    for ttype in type_order:
        items = by_type.get(ttype, [])
        if not items:
            continue
        color = TOGAF_TYPE_COLOR.get(ttype, "#666")
        lbl = type_labels.get(ttype, ttype.upper())
        sidebar_r4 += '<div class="sb-group">'
        sidebar_r4 += f'<div class="sb-group-label" style="color:{color}">{lbl}</div>'
        for sid, name, tstate, sts in items:
            dot_color = {"green": "#4CAF50", "yellow": "#FFC107", "red": "#FF5252"}.get(sts, "#888")
            state_chip = TOGAF_STATE_LABEL.get(tstate, tstate)
            oc = "selectSys('" + sid + "')"
            sidebar_r4 += f'<div class="sb-item" data-sys="{sid}" onclick="{oc}">'
            sidebar_r4 += f'<span class="sb-dot" style="background:{dot_color}"></span>'
            sidebar_r4 += f'<span class="sb-name">{name}</span>'
            if state_chip:
                sidebar_r4 += f'<span class="sb-state">{state_chip}</span>'
            sidebar_r4 += '</div>'
        sidebar_r4 += '</div>'

    # --- Legacy sidebar ---
    legacy_rows = con.execute(
        "SELECT id, name, acronym, type, provider, unity_relation, notes FROM legacy_systems ORDER BY unity_relation, name"
    ).fetchall()
    con.close()

    FATE_LABEL = {
        "to-replace": "A reemplazar", "to-decommission": "A decommissionar",
        "coexists": "Coexiste", "complementary": "Complementario",
        "data-source": "Fuente de datos", "unknown": "Por confirmar",
    }
    FATE_DOT = {
        "to-replace": "#FF5252", "to-decommission": "#FF7043",
        "coexists": "#FFC107", "complementary": "#4CAF50",
        "data-source": "#7B9FFF", "unknown": "#888",
    }
    sidebar_leg = '<div class="sb-group">'
    sidebar_leg += '<div class="sb-group-label" style="color:#9e9e9e">Ecosistema AS-IS</div>'
    for lid, lname, lacronym, ltype, lprov, lfate, lnotes in legacy_rows:
        dot = FATE_DOT.get(lfate, "#888")
        oc2 = "selectLegacy('" + lid + "')"
        sidebar_leg += f'<div class="sb-item" data-leg="{lid}" onclick="{oc2}">'
        sidebar_leg += f'<span class="sb-dot" style="background:{dot}"></span>'
        sidebar_leg += f'<span class="sb-name">{lname}</span>'
        sidebar_leg += '</div>'
    sidebar_leg += '</div>'

    legacy_json = _json.dumps({
        r[0]: {"id": r[0], "name": r[1], "acronym": r[2] or r[0],
               "type": r[3], "provider": r[4] or "—", "fate": r[5],
               "fate_label": FATE_LABEL.get(r[5], r[5]),
               "notes": r[6] or ""}
        for r in legacy_rows
    }, ensure_ascii=False, indent=2)

    _oc_r4  = "setView('r4')"
    _oc_leg = "setView('legacy')"
    sidebar_html = (
        '<div class="sb-view-toggle">'
        f'<button class="sv-btn active" id="btn-r4" onclick="{_oc_r4}">R4 Delivery</button>'
        f'<button class="sv-btn" id="btn-leg" onclick="{_oc_leg}">Legados</button>'
        '</div>'
        '<div class="r4-view" id="view-r4">' + sidebar_r4 + '</div>'
        '<div class="legacy-view" id="view-leg">' + sidebar_leg + '</div>'
    )

    sdlc_phases_js = _json.dumps(SDLC_PHASES_LIST)
    leg_json_str = legacy_json
    sys_json_str = systems_json

    # ── HTML lifecycle-style ─────────────────────────────────────────────────
    from datetime import datetime as _dts
    _gen = _dts.now().strftime("%Y-%m-%d")

    # Stepper tabs HTML
    _status_colors = {"green":"#4CAF50","yellow":"#FFC107","red":"#FF5252","gray":"#888"}
    _tabs = ""
    for _i, (_sid, _sd) in enumerate(systems_js.items()):
        _dc  = _status_colors.get(_sd.get("sdlc_status",""),"#888")
        _oc  = "selectSys('" + _sid + "')"
        _fcl = " first" if _i == 0 else ""
        _hu_must_val     = _sd.get("hu_must") or ""
        _rag_general_val = _sd.get("rag_general") or ""
        _crit_risks_val  = _sd.get("critical_risks") or 0
        _tabs += (
            '<button class="ptab' + _fcl + '" data-id="' + _sid + '" onclick="' + _oc + '"'
            + ' data-hu-must="' + str(_hu_must_val) + '"'
            + ' data-rag-general="' + html.escape(str(_rag_general_val)) + '"'
            + ' data-critical-risks="' + str(_crit_risks_val) + '">'
            + '<span class="ptab-dot" style="background:' + _dc + '"></span>'
            + '<span class="ptab-name">' + _sd["name"] + '</span>'
            + '<span class="ptab-type">' + _sd["togaf_type"].upper() + '</span>'
            + '</button>'
        )

    # Legacy cards HTML
    _FD = {
        "to-replace":      ("#FF5252","rgba(255,82,82,.15)"),
        "to-decommission": ("#FF7043","rgba(255,112,67,.15)"),
        "coexists":        ("#FFC107","rgba(255,193,7,.15)"),
        "complementary":   ("#4CAF50","rgba(76,175,80,.15)"),
        "data-source":     ("#7B9FFF","rgba(123,159,255,.15)"),
        "unknown":         ("#888",   "rgba(255,255,255,.08)"),
    }
    _FL = {
        "to-replace":"A reemplazar","to-decommission":"A decommissionar",
        "coexists":"Coexiste","complementary":"Complementario",
        "data-source":"Fuente de datos","unknown":"Por confirmar",
    }
    _lp = _json.loads(legacy_json)
    _cards = ""
    for _lid, _ld in _lp.items():
        _fate = _ld.get("fate","unknown")
        _fc, _fbg = _FD.get(_fate,("#888","rgba(255,255,255,.08)"))
        _fl  = _FL.get(_fate, _fate)
        _acr = (_ld.get("acronym") or _lid.upper()[:4])
        _oc2 = "selectLegacy('" + _lid + "')"
        _cards += (
            '<div class="leg-card" data-id="' + _lid + '" onclick="' + _oc2 + '">'
            + '<div class="leg-card-top">'
            + '<span class="fate-chip" style="background:' + _fbg + ';color:' + _fc + '">' + _fl + '</span>'
            + '</div>'
            + '<div class="leg-card-name">' + _ld["name"] + '</div>'
            + '<div class="leg-card-type">' + (_ld.get("type") or "") + '</div>'
            + '</div>'
        )

    _ns = len(systems_js)

    _CSS = (
        '*{box-sizing:border-box;margin:0;padding:0}\n'
        ':root{--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;\n'
        '  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;\n'
        '  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}\n'
        'html{scroll-behavior:smooth}\n'
        'body{background:#060a1a;color:var(--ink);\n'
        "  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;\n"
        '  -webkit-font-smoothing:antialiased;overflow-x:hidden}\n'
        '.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}\n'
        '.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;\n'
        '  filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.55),transparent 70%);\n'
        '  animation:f1 24s ease-in-out infinite}\n'
        '.aurora::after{content:"";position:absolute;width:50vw;height:50vw;right:-10vw;top:10vw;border-radius:50%;\n'
        '  filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.65),transparent 70%);\n'
        '  animation:f2 28s ease-in-out infinite}\n'
        '@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.12)}}\n'
        '@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.10)}}\n'
        ".grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;\n"
        "  background-image:url(\"data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E\")}\n"
        '#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;\n'
        '  background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}\n'
        'nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:13px 28px;\n'
        '  backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);\n'
        '  background:rgba(6,10,26,.55);border-bottom:1px solid rgba(255,255,255,.06)}\n'
        'nav img{height:18px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}\n'
        'nav .nt{font-size:12px;font-weight:600;color:var(--muted)}\n'
        '.sp{flex:1}\n'
        'nav a{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:20px;transition:.2s;text-decoration:none}\n'
        'nav a:hover{color:var(--ink);background:rgba(255,255,255,.07)}\n'
        'nav a.hl{color:var(--yellow)}\n'
        'main{padding-top:52px}\n'
        '.wrap{max-width:1240px;margin:0 auto;padding:0 28px}\n'
        '.hero{padding:100px 0 32px}\n'
        '.eyebrow{display:inline-flex;align-items:center;gap:8px;padding:7px 14px;border-radius:30px;\n'
        '  font-size:11px;font-weight:700;letter-spacing:.05em;color:#dfe6ff;margin-bottom:20px;\n'
        '  background:rgba(255,255,255,.05);border:1px solid var(--glassb);backdrop-filter:blur(10px)}\n'
        '.eyebrow .dot{width:6px;height:6px;border-radius:50%;background:var(--yellow);\n'
        '  box-shadow:0 0 10px var(--yellow);animation:pulse 2.4s infinite}\n'
        '@keyframes pulse{50%{opacity:.35}}\n'
        'h1{font-size:clamp(32px,4.5vw,58px);font-weight:800;line-height:1.05;letter-spacing:-.03em;\n'
        '  background:linear-gradient(175deg,#fff 30%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}\n'
        '.sub{font-size:15px;color:var(--muted);margin-top:14px;max-width:70ch;line-height:1.6}\n'
        '.sub b{color:#e4eaff;font-weight:600}\n'
        '.stats{display:flex;gap:12px;margin-top:28px;flex-wrap:wrap}\n'
        '.stat{padding:14px 20px;border-radius:16px;background:var(--glass);border:1px solid var(--glassb);\n'
        '  backdrop-filter:blur(16px);display:flex;flex-direction:column;gap:4px;min-width:130px}\n'
        '.stn{font-size:22px;font-weight:800;letter-spacing:-.02em;\n'
        '  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}\n'
        '.stl{font-size:10px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}\n'
        '.stat.warn{border-color:rgba(240,210,36,.35);background:rgba(240,210,36,.06)}\n'
        '.stat.warn .stn{background:linear-gradient(180deg,var(--yellow),#e0b800);-webkit-background-clip:text;background-clip:text}\n'
        '.stepper-wrap{margin-top:44px}\n'
        '.stepper{display:flex;gap:8px;overflow-x:auto;padding-bottom:4px}\n'
        '.ptab{display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;\n'
        '  padding:14px 22px;cursor:pointer;border:1px solid rgba(255,255,255,.07);\n'
        '  background:rgba(255,255,255,.04);color:var(--muted);\n'
        '  flex:1;min-width:110px;border-radius:12px;\n'
        '  transition:background .22s,color .22s,border-color .22s;font-family:inherit;white-space:nowrap}\n'
        '.ptab:hover{background:rgba(255,255,255,.08);color:var(--ink);border-color:rgba(255,255,255,.14)}\n'
        '.ptab.active{background:rgba(61,95,205,.25);color:#fff;border-color:#3D5FCD;\n'
        '  box-shadow:0 0 22px rgba(61,95,205,.35),inset 0 0 14px rgba(61,95,205,.12)}\n'
        '.ptab-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}\n'
        '.ptab-name{font-size:.68rem;font-weight:700;letter-spacing:.03em}\n'
        '.ptab-type{font-size:.55rem;letter-spacing:.1em;text-transform:uppercase;opacity:.6}\n'
        '.detail-wrap{margin-top:2px;background:rgba(255,255,255,.025);border-radius:0 0 16px 16px;\n'
        '  border:1px solid rgba(255,255,255,.06);border-top:none;padding:32px 36px;min-height:280px}\n'
        '.detail-hdr{display:flex;align-items:flex-start;gap:20px;margin-bottom:28px}\n'
        '.d-abbr{width:64px;height:64px;border-radius:14px;display:flex;align-items:center;justify-content:center;\n'
        '  font-size:1.05rem;font-weight:800;color:#fff;flex-shrink:0;letter-spacing:.05em}\n'
        '.d-meta{flex:1}\n'
        '.d-name{font-size:1.6rem;font-weight:800;color:#fff;letter-spacing:-.02em;margin-bottom:4px}\n'
        '.d-vendor{font-size:.78rem;color:var(--muted2);margin-bottom:10px}\n'
        '.d-chips{display:flex;gap:8px;flex-wrap:wrap}\n'
        '.chip{display:inline-block;padding:3px 10px;border-radius:20px;font-size:.63rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase}\n'
        '.chip-transitional{background:rgba(123,159,255,.18);color:#7B9FFF}\n'
        '.chip-at_risk{background:rgba(255,82,82,.18);color:#FF5252}\n'
        '.chip-active{background:rgba(76,175,80,.18);color:#4CAF50}\n'
        '.detail-grid{display:grid;grid-template-columns:1fr 1fr;gap:24px}\n'
        '@media(max-width:800px){.detail-grid{grid-template-columns:1fr}}\n'
        '.sec-title{font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:rgba(255,255,255,.28);\n'
        '  margin-bottom:12px;padding-bottom:6px;border-bottom:1px solid rgba(255,255,255,.06)}\n'
        '.summary-box{background:var(--glass);border-left:3px solid #7B9FFF;border-radius:0 10px 10px 0;\n'
        '  padding:14px 18px;font-size:.82rem;color:var(--muted);line-height:1.65;margin-bottom:24px}\n'
        '.sdlc-wrap{background:var(--glass);border:1px solid rgba(255,255,255,.06);border-radius:12px;padding:16px 18px}\n'
        '.sdlc-phases{display:flex;gap:3px;margin-bottom:12px;flex-wrap:wrap}\n'
        '.sdlc-ph{flex:1;text-align:center;font-size:.57rem;letter-spacing:.05em;text-transform:uppercase;\n'
        '  padding:7px 2px;border-radius:5px;color:rgba(255,255,255,.22);background:rgba(255,255,255,.03)}\n'
        '.sdlc-ph.done{background:rgba(76,175,80,.13);color:#4CAF50}\n'
        '.sdlc-ph.cur{font-weight:800}\n'
        '.sdlc-bar-wrap{display:flex;align-items:center;gap:10px}\n'
        '.sdlc-bar-bg{flex:1;height:6px;background:rgba(255,255,255,.07);border-radius:3px;overflow:hidden}\n'
        '.sdlc-bar-fill{height:100%;border-radius:3px;transition:width .7s ease}\n'
        '.sdlc-pct{font-size:.75rem;font-weight:700;min-width:36px;text-align:right}\n'
        '.milestones{display:flex;flex-direction:column;gap:0}\n'
        '.ms-row{display:flex;align-items:center;gap:12px;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.04)}\n'
        '.ms-row:last-child{border-bottom:none}\n'
        '.ms-icon{width:18px;height:18px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.7rem}\n'
        '.ms-done{background:rgba(76,175,80,.22);color:#4CAF50}\n'
        '.ms-pending{background:rgba(255,193,7,.18);color:#FFC107}\n'
        '.ms-planned{background:rgba(255,255,255,.06);color:rgba(255,255,255,.28)}\n'
        '.ms-label{flex:1;font-size:.8rem;color:var(--muted)}\n'
        '.ms-date{font-size:.72rem;color:rgba(255,255,255,.3);min-width:70px;text-align:right}\n'
        '.caps-grid{display:flex;flex-wrap:wrap;gap:8px}\n'
        '.cap-chip{display:flex;align-items:center;gap:6px;padding:6px 12px;border-radius:20px;font-size:.72rem;\n'
        '  background:var(--glass);border:1px solid rgba(255,255,255,.07);color:var(--muted)}\n'
        '.cap-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}\n'
        '.cov-full{background:#4CAF50}.cov-partial{background:#FFC107}.cov-not_covered{background:#FF5252}\n'
        '.cov-not_applicable{background:#666}.cov-unknown{background:#888}\n'
        '.impact-empty{font-size:.78rem;color:rgba(255,255,255,.22);font-style:italic}\n'
        '.dia-wrap{margin-top:64px;background:rgba(255,255,255,.018);border:1px solid rgba(255,255,255,.07);border-radius:16px;padding:32px 20px 24px;overflow:hidden;position:relative}\n'
        '.dia-label{font-size:.62rem;font-weight:700;letter-spacing:.18em;text-transform:uppercase;color:var(--yellow);margin-bottom:16px}\n'
        '.dia-controls{position:absolute;top:16px;right:16px;display:flex;gap:6px;z-index:10}\n'
        '.dia-btn{background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12);border-radius:8px;\n'
        '  color:var(--muted);cursor:pointer;font-size:.9rem;width:32px;height:32px;\n'
        '  display:flex;align-items:center;justify-content:center;transition:.18s;font-family:inherit;padding:0}\n'
        '.dia-btn:hover{background:rgba(255,255,255,.15);color:#fff;border-color:rgba(255,255,255,.25)}\n'
        '.mermaid svg{width:100%!important;height:auto!important;max-width:100%}\n'
        '.leg-section{margin-top:80px;padding-bottom:80px}\n'
        '.kick{font-size:.7rem;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:10px}\n'
        '.vw-h2{font-size:clamp(22px,3vw,36px);font-weight:800;letter-spacing:-.02em;\n'
        '  background:linear-gradient(175deg,#fff 30%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent;\n'
        '  margin-bottom:10px}\n'
        '.leg-desc{font-size:.9rem;color:var(--muted);max-width:60ch;line-height:1.6;margin-bottom:28px}\n'
        '.leg-grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(200px,1fr));gap:14px}\n'
        '.leg-card{background:var(--glass);border:1px solid rgba(255,255,255,.07);border-radius:14px;\n'
        '  padding:18px;cursor:pointer;transition:.2s;display:flex;flex-direction:column;gap:10px}\n'
        '.leg-card:hover{background:rgba(255,255,255,.06);border-color:rgba(255,255,255,.12)}\n'
        '.leg-card.active{border-color:#7B9FFF;background:rgba(123,159,255,.08)}\n'
        '.leg-card-top{display:flex;align-items:center;gap:10px}\n'
        '.leg-abbr{font-size:.7rem;font-weight:800;color:#fff;padding:6px 10px;border-radius:8px;\n'
        '  background:rgba(255,255,255,.08);letter-spacing:.06em}\n'
        '.fate-chip{display:inline-block;padding:3px 8px;border-radius:20px;font-size:.58rem;font-weight:700;\n'
        '  letter-spacing:.07em;text-transform:uppercase}\n'
        '.leg-card-name{font-size:.8rem;font-weight:600;color:var(--ink);line-height:1.3}\n'
        '.leg-card-type{font-size:.65rem;color:var(--muted2);letter-spacing:.06em}\n'
        '.leg-modal{display:none;position:fixed;inset:0;z-index:200;\n'
        '  background:rgba(0,0,0,.6);backdrop-filter:blur(8px);align-items:center;justify-content:center}\n'
        '.leg-modal.open{display:flex}\n'
        '.leg-modal-box{background:#0d1f3c;border:1px solid rgba(255,255,255,.1);border-radius:20px;\n'
        '  padding:36px;max-width:520px;width:90%;position:relative;max-height:80vh;overflow-y:auto}\n'
        '.leg-modal-close{position:absolute;top:16px;right:20px;background:none;border:none;color:var(--muted);\n'
        '  font-size:1.4rem;cursor:pointer;line-height:1}\n'
        '.leg-modal-name{font-size:1.3rem;font-weight:800;color:#fff;margin-bottom:4px}\n'
        '.leg-modal-vendor{font-size:.78rem;color:var(--muted2);margin-bottom:14px}\n'
        '.leg-meta-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:16px}\n'
        '.leg-meta-item{background:rgba(255,255,255,.03);border-radius:8px;padding:10px 12px}\n'
        '.lmi-label{font-size:.6rem;letter-spacing:.1em;text-transform:uppercase;color:rgba(255,255,255,.3);margin-bottom:3px}\n'
        '.lmi-value{font-size:.8rem;color:#c5cae9}\n'
        '.leg-notes{background:rgba(255,255,255,.04);border-left:3px solid #444;border-radius:0 8px 8px 0;\n'
        '  padding:12px 16px;font-size:.8rem;color:#9fa8da;line-height:1.6}\n'
    )

    _JS = (
        "const SYSTEMS="  + sys_json_str  + ";\n"
        "const SDLC_PHASES=" + sdlc_phases_js + ";\n"
        "const LEGACY="   + leg_json_str  + ";\n"
        "const COV_DOT={full:'cov-full',partial:'cov-partial',not_covered:'cov-not_covered',not_applicable:'cov-not_applicable',unknown:'cov-unknown'};\n"
        "const MS_ICON={done:'\u2713',pending:'\u25ba',planned:'\u25cb'};\n"
        "const FATE_LABEL={'to-replace':'A reemplazar','to-decommission':'A decommissionar',\n"
        "  coexists:'Coexiste',complementary:'Complementario','data-source':'Fuente de datos',unknown:'Por confirmar'};\n"
        "const FATE_COLOR={'to-replace':'#FF5252','to-decommission':'#FF7043',coexists:'#FFC107',\n"
        "  complementary:'#4CAF50','data-source':'#7B9FFF',unknown:'#888'};\n"
        "const FATE_BG={'to-replace':'rgba(255,82,82,.15)','to-decommission':'rgba(255,112,67,.15)',\n"
        "  coexists:'rgba(255,193,7,.15)',complementary:'rgba(76,175,80,.15)',\n"
        "  'data-source':'rgba(123,159,255,.15)',unknown:'rgba(255,255,255,.08)'};\n"
        "function selectSys(id){\n"
        "  document.querySelectorAll('.ptab').forEach(t=>t.classList.toggle('active',t.dataset.id===id));\n"
        "  const s=SYSTEMS[id];if(!s)return;\n"
        "  const phIdx=SDLC_PHASES.indexOf(s.sdlc_phase);\n"
        "  const phasesH=SDLC_PHASES.map((ph,i)=>{\n"
        "    const cls=i<phIdx?'done':i===phIdx?'cur':'';\n"
        "    const st=i===phIdx?'style=\"background:'+s.color+';color:#fff\"':'';\n"
        "    return '<div class=\"sdlc-ph '+cls+'\" '+st+'>'+ph+'</div>';\n"
        "  }).join('');\n"
        "  const barC={green:'#4CAF50',yellow:'#FFC107',red:'#FF5252'}[s.sdlc_status]||'#7B9FFF';\n"
        "  const msH=(s.milestones||[]).map(m=>\n"
        "    '<div class=\"ms-row\"><div class=\"ms-icon ms-'+m.status+'\">'+(MS_ICON[m.status]||'?')+'</div>'\n"
        "    +'<div class=\"ms-label\">'+m.label+'</div><div class=\"ms-date\">'+m.date+'</div></div>'\n"
        "  ).join('');\n"
        "  const capsH=(s.capabilities_impacted||[]).map(c=>\n"
        "    '<div class=\"cap-chip\"><span class=\"cap-dot '+(COV_DOT[c.coverage]||'cov-unknown')+'\"></span>'+c.name+'</div>'\n"
        "  ).join('')||'<span class=\"impact-empty\">Sin capabilities mapeadas</span>';\n"
        "  const actCls=s.status==='at_risk'?'chip-at_risk':'chip-active';\n"
        "  const actLbl=s.status==='at_risk'?'\u26a0 En riesgo':'\u25cf Activo';\n"
        "  document.getElementById('detail-wrap').innerHTML=\n"
        "    '<div class=\"detail-hdr\">'\n"
        "    +'<div class=\"d-meta\"><div class=\"d-name\">'+s.name+'</div>'\n"
        "    +'<div class=\"d-vendor\">'+s.vendor+'</div>'\n"
        "    +'<div class=\"d-chips\">'\n"
        "    +'<span class=\"chip\" style=\"background:'+s.color+'22;color:'+s.color+'\">'+s.togaf_type.toUpperCase()+'</span>'\n"
        "    +(s.state_label?'<span class=\"chip chip-transitional\">'+s.state_label+'</span>':'')\n"
        "    +'<span class=\"chip '+actCls+'\">'+actLbl+'</span>'\n"
        "    +'</div></div></div>'\n"
        "    +'<div class=\"summary-box\">'+s.summary+'</div>'\n"
        "    +'<div class=\"detail-grid\">'\n"
        "    +'<div><div class=\"sec-title\">Plan SDLC</div>'\n"
        "    +'<div class=\"sdlc-wrap\"><div class=\"sdlc-phases\">'+phasesH+'</div>'\n"
        "    +'<div class=\"sdlc-bar-wrap\"><div class=\"sdlc-bar-bg\">'\n"
        "    +'<div class=\"sdlc-bar-fill\" style=\"width:'+s.sdlc_progress+'%;background:'+barC+'\"></div></div>'\n"
        "    +'<div class=\"sdlc-pct\" style=\"color:'+barC+'\">'+s.sdlc_progress+'%</div>'\n"
        "    +'</div></div></div>'\n"
        "    +'<div><div class=\"sec-title\">Hitos</div><div class=\"milestones\">'+msH+'</div></div>'\n"
        "    +'</div>'\n"
        "    +'<div style=\"margin-top:24px\"><div class=\"sec-title\">Capabilities impactadas</div>'\n"
        "    +'<div class=\"caps-grid\">'+capsH+'</div></div>'\n"
        "    +(s.rag_general?(function(){\n"
        "        const rc={red:'#FF5252',yellow:'#FFC107',green:'#4CAF50'}[s.track_rag_color]||'#888';\n"
        "        const rb={red:'rgba(255,82,82,.1)',yellow:'rgba(255,193,7,.08)',green:'rgba(76,175,80,.08)'}[s.track_rag_color]||'rgba(255,255,255,.05)';\n"
        "        const rl={red:'🔴 Rojo — Bloqueado',yellow:'🟡 Amarillo — En seguimiento',green:'🟢 Verde — En control'}[s.track_rag_color]||'';\n"
        "        let h='<div style=\"margin-top:28px\"><div class=\"sec-title\">Estado del Track</div>'\n"
        "          +'<div style=\"background:'+rb+';border:1px solid '+rc+'44;border-radius:10px;padding:14px 18px;margin-top:8px\">'\n"
        "          +'<div style=\"font-size:11px;font-weight:700;letter-spacing:.08em;color:'+rc+';margin-bottom:6px\">'+rl+'</div>'\n"
        "          +'<div style=\"font-size:13px;color:#c8d0e0;line-height:1.5;margin-bottom:10px\">'+s.rag_general+'</div>';\n"
        "        if(s.rag_solucion)h+='<div style=\"font-size:12px;color:#8a94a8;margin-bottom:4px\"><b style=\"color:#a0abc0\">Solución.</b> '+s.rag_solucion+'</div>';\n"
        "        if(s.rag_integraciones)h+='<div style=\"font-size:12px;color:#8a94a8;margin-bottom:10px\"><b style=\"color:#a0abc0\">Integraciones.</b> '+s.rag_integraciones+'</div>';\n"
        "        if(s.hu_total)h+='<div style=\"display:flex;gap:12px;margin-top:8px\">'\n"
        "          +'<span style=\"font-size:11px;background:rgba(255,255,255,.06);border-radius:6px;padding:3px 9px;color:#a0abc0\">Must: <b style=\"color:#e8eaf0\">'+s.hu_must+'</b></span>'\n"
        "          +'<span style=\"font-size:11px;background:rgba(255,255,255,.06);border-radius:6px;padding:3px 9px;color:#a0abc0\">Should: <b style=\"color:#e8eaf0\">'+(s.hu_should||0)+'</b></span>'\n"
        "          +'<span style=\"font-size:11px;background:rgba(255,255,255,.06);border-radius:6px;padding:3px 9px;color:#a0abc0\">Total: <b style=\"color:#e8eaf0\">'+(s.hu_total||0)+'</b></span>'\n"
        "          +(s.integraciones_count?'<span style=\"font-size:11px;background:rgba(255,255,255,.06);border-radius:6px;padding:3px 9px;color:#a0abc0\">Integraciones: <b style=\"color:#e8eaf0\">'+s.integraciones_count+'</b></span>':'')\n"
        "          +'</div>';\n"
        "        return h+'</div></div>';\n"
        "      })():'');\n"
        "}\n"
        "function selectLegacy(id){\n"
        "  document.querySelectorAll('.leg-card').forEach(c=>c.classList.toggle('active',c.dataset.id===id));\n"
        "  const l=LEGACY[id];if(!l)return;\n"
        "  const fl=FATE_LABEL[l.fate]||l.fate;\n"
        "  const fc=FATE_COLOR[l.fate]||'#888';\n"
        "  const fb=FATE_BG[l.fate]||'rgba(255,255,255,.08)';\n"
        "  const box=document.getElementById('leg-modal-box');\n"
        "  box.innerHTML='<button class=\"leg-modal-close\" onclick=\"closeLegModal()\">\u00d7</button>'\n"
        "    +'<div style=\"margin-bottom:6px\"><span class=\"fate-chip\" style=\"background:'+fb+';color:'+fc+'\">'+fl+'</span></div>'\n"
        "    +'<div class=\"leg-modal-name\">'+l.name+'</div>'\n"
        "    +'<div class=\"leg-modal-vendor\">'+l.provider+'</div>'\n"
        "    +'<div class=\"leg-meta-grid\">'\n"
        "    +'<div class=\"leg-meta-item\"><div class=\"lmi-label\">Tipo</div><div class=\"lmi-value\">'+l.type+'</div></div>'\n"
        "    +'<div class=\"leg-meta-item\"><div class=\"lmi-label\">Proveedor</div><div class=\"lmi-value\">'+l.provider+'</div></div>'\n"
        "    +'<div class=\"leg-meta-item\"><div class=\"lmi-label\">Destino R4</div><div class=\"lmi-value\">'+fl+'</div></div>'\n"
        "    +(l.notes?'<div class=\"leg-notes\">'+l.notes+'</div>':'');\n"
        "  document.getElementById('leg-modal').classList.add('open');\n"
        "}\n"
        "function closeLegModal(){document.getElementById('leg-modal').classList.remove('open');}\n"
        "document.getElementById('leg-modal').addEventListener('click',function(e){if(e.target===this)closeLegModal();});\n"
        "window.addEventListener('scroll',function(){\n"
        "  const p=document.documentElement.scrollTop/(document.documentElement.scrollHeight-window.innerHeight)||0;\n"
        "  document.getElementById('prog').style.width=Math.round(p*100)+'%';\n"
        "});\n"
        "const firstKey=Object.keys(SYSTEMS)[0];\n"
        "if(firstKey)selectSys(firstKey);\n"
    )

    _MERMAID_DIAG = (
        'flowchart TB\n'
        '    subgraph CLI["Clientes"]\n'
        '        CLT_D["Digital"]\n'
        '        CLT_S["Sucursal / ATM"]\n'
        '        CLT_C["Contact Center"]\n'
        '    end\n'
        '    subgraph CAN["Canales R4"]\n'
        '        APP["App M\u00f3vil<br/>(AppWhere)"]\n'
        '        APO["Apolo<br/>(Onboarding Digital)"]\n'
        '        SIW["SIWEB<br/>(Banca Internet)"]\n'
        '        subgraph CAT_GRP["CAT \u2014 Canales Adicionales"]\n'
        '            IVR["IVR"]\n'
        '            ICT["ICCAT \u26a0<br/>(sin proveedor \u00b7 deadline 31-ago)"]\n'
        '        end\n'
        '    end\n'
        '    subgraph PROC["Procesadores Unity R4"]\n'
        '        SV["SmartVista / BPC<br/>22 User Stories \u00b7 7 integraciones R4"]\n'
        '        TRN["Temenos Transact<br/>Cr\u00e9dito Simple Empresarial \u00b7 live"]\n'
        '    end\n'
        '    subgraph MID["Middleware \u2014 API / Integraci\u00f3n"]\n'
        '        APG["Apigee<br/>(API Gateway \u00b7 EOL 2027)"]\n'
        '        MUL["MuleSoft<br/>(ESB target)"]\n'
        '        IBUS["IBM BUS / IIB<br/>(ODBC \u2192 Core)"]\n'
        '        IACT["InterAct / Syndein<br/>(ISO-8583 \u2192 Core)"]\n'
        '        CDR["Connect:Direct<br/>(Batch PGP)"]\n'
        '        CTM["Control-M<br/>(Orquestador Batch)"]\n'
        '    end\n'
        '    subgraph DAT["Datos"]\n'
        '        ATL["Atlas / AlloyDB<br/>(GCP \u00b7 Golden Record)"]\n'
        '        TDH["Temenos Data Hub<br/>(near-realtime)"]\n'
        '        DWH["DataStage \u2192 DWH<br/>(Reportes CNBV \u00b7 RiskLogic)"]\n'
        '    end\n'
        '    subgraph LEG["Core Legado \u2014 baseline"]\n'
        '        INF["Informix IDS 14.10 / AIX<br/>SIF \u00b7 PISA \u00b7 10,144 SPs<br/>Exodus Ola 6 \u2192 2029"]\n'
        '    end\n'
        '    subgraph EXT["Entidades Externas"]\n'
        '        EGL["eGlobal<br/>(ISO 8583)"]\n'
        '        VMC["VISA / MC / PROSA"]\n'
        '        BNX["Banxico<br/>(SPEI \u00b7 CoDi)"]\n'
        '        BUR["Bur\u00f3 / C\u00edrculo"]\n'
        '        AWS["AWS Transfer Family<br/>(SFTP \u00b7 PGP)"]\n'
        '    end\n'
        '\n'
        '    CLT_D --> APP\n'
        '    CLT_D --> APO\n'
        '    CLT_S --> SIW\n'
        '    CLT_C --> IVR\n'
        '    CLT_C --> ICT\n'
        '\n'
        '    APP -->|"API \u00b7 Autorizaciones<br/>ISV-APP-001"| SV\n'
        '    IVR -->|"API \u00b7 Consulta / Pago<br/>ISV-CAT-001/002"| SV\n'
        '    ICT -->|"API \u00b7 Transacciones<br/>ISV-CAT-005/006/007"| SV\n'
        '    SIW -->|"API \u00b7 Pagos TDC<br/>ISV-CAT-003/004"| SV\n'
        '    SV  -->|"API \u00b7 Comisiones<br/>ISV-APP-002"| APP\n'
        '    SV  -->|"API \u00b7 DPP<br/>ISV-APP-003/004"| APP\n'
        '    APO -->|"Onboarding digital<br/>ISV-APP-005"| TRN\n'
        '    APO -->|"Post-originaci\u00f3n<br/>ISV-CAT-008"| SV\n'
        '\n'
        '    APP -->|"API Gateway"| APG\n'
        '    APO -->|"API Gateway"| APG\n'
        '    SIW -->|"API Gateway"| APG\n'
        '    APG -->|"routing"| SV\n'
        '    APG -.->|"migraci\u00f3n 2027"| MUL\n'
        '    MUL -.->|"reemplaza"| IBUS\n'
        '    MUL -.->|"reemplaza"| IACT\n'
        '    AWS -->|"Batch PGP \u2192 INF<br/>ISV-01"| INF\n'
        '    INF -->|"Batch PGP \u2192 CDR<br/>ISV-02"| CDR\n'
        '    CTM --> INF\n'
        '    IBUS --> INF\n'
        '    IACT --> INF\n'
        '\n'
        '    TRN --> TDH\n'
        '    TDH --> DWH\n'
        '    INF --> DWH\n'
        '    DWH -->|"R-04-C \u00b7 cartera"| BNX\n'
        '    INF -->|"SPEI \u00b7 CoDi batch"| BNX\n'
        '    INF --> BUR\n'
        '    SV  --> EGL\n'
        '    EGL --> VMC\n'
        '    CDR --> VMC\n'
        '    ATL -.->|"Golden Record"| APO\n'
        '    ATL -.->|"Golden Record"| SV\n'
        '\n'
        '    classDef newR4   fill:#122FB1,stroke:#3D5FCD,color:#e4eaff\n'
        '    classDef channel fill:#0d4a2e,stroke:#1a7a4a,color:#b8f5d0\n'
        '    classDef riesgo  fill:#5a1a1a,stroke:#cc3333,color:#ffb3b3\n'
        '    classDef legacy  fill:#3d2b00,stroke:#8b6914,color:#f5d78e\n'
        '    classDef mid     fill:#1a2a3d,stroke:#3a5a7d,color:#a8c4e0\n'
        '    classDef apigee  fill:#4a3200,stroke:#c87800,color:#ffd580\n'
        '    classDef target  fill:#0d3320,stroke:#1a7a4a,color:#7affc4\n'
        '    classDef data    fill:#0d1a33,stroke:#2a4a8a,color:#7b9fd4\n'
        '    classDef ext     fill:#1a1a2e,stroke:#444466,color:#aaaacc\n'
        '    class SV,TRN newR4\n'
        '    class APP,APO,SIW,IVR channel\n'
        '    class ICT riesgo\n'
        '    class INF legacy\n'
        '    class IBUS,IACT,CDR,CTM mid\n'
        '    class APG apigee\n'
        '    class MUL target\n'
        '    class ATL,TDH,DWH data\n'
        '    class EGL,VMC,BNX,BUR,AWS ext\n'
    )

    _html = (
        '<!DOCTYPE html>\n'
        '<html lang="es"><head><meta charset="UTF-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1.0">\n'
        '<title>Habilitadores del Proceso \u2014 Unity | BanCoppel</title>\n'
        '<style>\n' + _CSS + '</style></head>\n'
        '<body>\n'
        '<div class="aurora"></div><div class="grain"></div><div id="prog"></div>\n'
        '<nav>\n'
        '  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display=\'none\'">\n'
        '  <span class="nt">Unity R4 \u2014 Ecosistema Tecnol\u00f3gico</span>\n'
        '  <span class="sp"></span>\n'
        '  <a class="hl" href="index.html">&#8592; Plan Director</a>\n'
        '  <a href="lifecycle-p4900.html">Cadena de Valor &#8599;</a>\n'
        '</nav>\n'
        '<main><div class="wrap">\n'
        '<div class="hero">\n'
        '  <div class="eyebrow"><span class="dot"></span>SPE-AM-001 &middot; Unity &middot; BUILD &middot; ago 2026</div>\n'
        '  <h1>Ecosistema<br>Tecnol&oacute;gico</h1>\n'
        '  <p class="sub">Estado de los sistemas que ejecutan el producto end-to-end. <b>Esta vista gobierna los planes individuales</b> y los alimenta al gobierno de la Vista de Producto.</p>\n'
        '  <div class="stats">\n'
        '    <div class="stat"><div class="stn">' + str(_ns) + '</div><div class="stl">Sistemas R4</div></div>\n'
        '    <div class="stat warn"><div class="stn">2&thinsp;/&thinsp;7</div><div class="stl">En riesgo</div></div>\n'
        '    <div class="stat"><div class="stn">46</div><div class="stl">Must Have stories</div></div>\n'
        '    <div class="stat"><div class="stn">18</div><div class="stl">Integraciones R4</div></div>\n'
        '  </div>\n'
        '</div>\n'
        '<div class="stepper-wrap"><div class="stepper">' + _tabs + '</div></div>\n'
        '<div class="detail-wrap" id="detail-wrap">\n'
        '  <p style="opacity:.3;font-size:.85rem;text-align:center;padding:40px 0">Selecciona un sistema</p>\n'
        '</div>\n'
        '<div class="leg-section">\n'
        '  <div class="kick">Coexistencia &middot; Unity R4</div>\n'
        '  <h2 class="vw-h2">Arquitectura de Sistemas e Integraciones</h2>\n'
        '  <div class="dia-wrap">\n'
        '    <div class="dia-label">Canales R4 &middot; Procesadores &middot; Middleware &middot; Datos &middot; Core Legado &middot; Entidades Externas</div>\n'
        '    <div class="dia-controls">\n'
        '      <button class="dia-btn" id="dia-zin"  title="Zoom in">+</button>\n'
        '      <button class="dia-btn" id="dia-zout" title="Zoom out">−</button>\n'
        '      <button class="dia-btn" id="dia-zrst" title="Reset">↺</button>\n'
        '    </div>\n'
        '    <div class="mermaid" id="dia-mermaid">\n'
        + _MERMAID_DIAG +
        '    </div>\n'
        '  </div>\n'
        '</div>\n'
        '</div></main>\n'
        '<div class="leg-modal" id="leg-modal">\n'
        '  <div class="leg-modal-box" id="leg-modal-box">\n'
        '    <button class="leg-modal-close" onclick="closeLegModal()">\u00d7</button>\n'
        '  </div>\n'
        '</div>\n'
        '<script src="https://cdn.jsdelivr.net/npm/mermaid@10/dist/mermaid.min.js"></script>\n'
        '<script src="https://cdn.jsdelivr.net/npm/svg-pan-zoom@3.6.1/dist/svg-pan-zoom.min.js"></script>\n'
        '<script>\n'
        'mermaid.initialize({startOnLoad:true,theme:"dark",flowchart:{useMaxWidth:false,htmlLabels:true},\n'
        'themeVariables:{background:"transparent",primaryColor:"#122FB1",primaryTextColor:"#e4eaff",\n'
        'primaryBorderColor:"#3D5FCD",lineColor:"#4a6aaa",secondaryColor:"#0d1a40",\n'
        'edgeLabelBackground:"rgba(6,10,26,0.92)",clusterBkg:"rgba(61,95,205,0.04)",\n'
        'clusterBorder:"rgba(255,255,255,0.09)",titleColor:"#dfe6ff"}});\n'
        '(function initDiaZoom(){\n'
        '  function tryInit(){\n'
        '    const svg=document.querySelector("#dia-mermaid svg");\n'
        '    if(!svg||!window.svgPanZoom){setTimeout(tryInit,200);return;}\n'
        '    svg.style.width="100%";svg.style.height="620px";\n'
        '    const pz=svgPanZoom(svg,{zoomEnabled:true,controlIconsEnabled:false,\n'
        '      fit:true,center:true,minZoom:0.2,maxZoom:8,zoomScaleSensitivity:0.3});\n'
        '    document.getElementById("dia-zin").onclick=function(){pz.zoomIn();};\n'
        '    document.getElementById("dia-zout").onclick=function(){pz.zoomOut();};\n'
        '    document.getElementById("dia-zrst").onclick=function(){pz.resetZoom();pz.resetPan();pz.fit();pz.center();};\n'
        '  }\n'
        '  if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",function(){setTimeout(tryInit,400);});\n'
        '  else setTimeout(tryInit,400);\n'
        '})();\n'
        + _JS +
        '</script>\n'
        '</body></html>'
    )

    out_path = out_dir / 'systems-p4900.html'
    out_path.write_text(_html, encoding='utf-8')
    print(f'[build-portal] systems-p4900.html generado OK \u2014 {_ns} sistemas')


def main():
    parser = argparse.ArgumentParser(description="Genera portal/index.html desde brain.db")
    parser.add_argument("--brain", default=str(BRAIN), help="Ruta al brain.db")
    parser.add_argument("--out",   default=str(OUTPUT), help="Ruta de salida del HTML")
    args = parser.parse_args()

    brain_path = Path(args.brain)
    out_path   = Path(args.out)

    if not brain_path.exists():
        print(f"[ERROR] brain.db no encontrado: {brain_path}")
        raise SystemExit(1)

    print(f"[build-portal] Leyendo {brain_path} ...")
    data = load_data(str(brain_path))

    print(f"[build-portal] Generando {out_path} ...")
    out_path.parent.mkdir(parents=True, exist_ok=True)

    # Pasada 1 — HTML con cubos CSS (necesario para que Playwright lo abra)
    out_path.write_text(render(data), encoding="utf-8")

    # Pasada 2 — Screenshots con Playwright → reemplaza cubos CSS por imágenes
    img_dir = out_path.parent / "img"
    cube_imgs = capture_cube_screenshots(out_path, img_dir)
    if cube_imgs:
        out_path.write_text(render(data, cube_imgs=cube_imgs), encoding="utf-8")
        print(f"[build-portal] Screenshots embebidos ✓")

    # Parcheo de títulos en lifecycle-p4900.html (no tiene generador propio aún)
    lifecycle_path = out_path.parent / "lifecycle-p4900.html"
    if lifecycle_path.exists():
        lc = lifecycle_path.read_text(encoding="utf-8")
        replacements = {
            "Lifecycle TDC P4900 — Unity R4 — BanCoppel": "Cadena de Valor — Tarjeta de Crédito — Unity R4",
            "<!-- Unity R4 · Lifecycle TDC P4900": "<!-- Unity R4 · Cadena de Valor TDC",
            "Unity R4 — Lifecycle TDC P4900": "Unity R4 — Cadena de Valor",
            "<h1>Lifecycle<br>TDC P4900</h1>": "<h1>Cadena de Valor<br>Tarjeta de Crédito</h1>",
            "SPE-AM-001 — Unity R4 — BUILD": "Tarjeta de Crédito · Unity R4",
            '<p class="sub">Flujo de vida completo de la <b>Tarjeta de Crédito</b> —\n    desde la originación hasta la cobranza. Mapeado desde el Digital Brain de Unity R4.</p>':
                '<p class="sub">Ocho etapas conforman la experiencia completa del cliente con la <b>Tarjeta de Crédito</b> —'
                ' desde que solicita hasta que realiza su pago. Esta vista muestra el estado de entrega de cada etapa del programa R4 y los sistemas que la habilitan.</p>',
            "lifecycle-p4900.html — Unity R4 — SPE-AM-001": "Unity R4 — Tarjeta de Crédito",
            "Fuente: Digital Brain Unity R4 — 2026-08-19 — v1.0.0": "",
            # Revert: restaurar flex:1 (igual ancho todos los chevrons)
            "color:var(--muted);position:relative;flex:0 0 auto;min-width:118px;":
                "color:var(--muted);position:relative;flex:1;min-width:118px;",
            # Acortar nombre largo que desborda el chevron con flex:1
            "name:'Contabilidad y conciliación'": "name:'Contabilidad'",
            # "USs" → "User Stories" en el panel de detalle de fase
            "<span class=\"pmeta-label\">USs&nbsp;</span>": "<span class=\"pmeta-label\">User Stories&nbsp;</span>",
            # Ocultar badge "Cobertura completa/parcial" — jerga interna, no ejecutiva
            ".cov-badge{display:inline-flex;": ".cov-badge{display:none;",
        }
        for old, new in replacements.items():
            lc = lc.replace(old, new)

        # ── Formato visual: logo, nav, hero ───────────────────────────────────
        _lc_days = days_to_golive()

        # 1. Logo path correcto
        lc = lc.replace(
            'src="../../../design-studio/bancoppel-logo.png"',
            'src="../../../design-studio/logos/BanCoppel_logo.png"'
        )

        # 2. Nav: links limpios alineados al Plan Director
        old_nav_links = (
            '  <a href="index.html">Portal ←</a>\n'
            '  <a href="arquitectura.html" class="hl">Arquitectura ↗</a>'
        )
        new_nav_links = (
            '  <a class="jump hl" href="index.html">← Plan Director</a>\n'
            '  <a class="jump" href="arquitectura.html">Arquitectura ↗</a>'
        )
        if old_nav_links in lc:
            lc = lc.replace(old_nav_links, new_nav_links)

        # 3. Stats: añadir días al go-live (primera posición) y corregir USs
        old_stats_block = (
            '    <div class="stats">\n'
            '      <div class="stat"><div class="stn">8</div><div class="stl">Fases del lifecycle</div></div>\n'
            '      <div class="stat"><div class="stn">33+</div><div class="stl">User Stories mapeadas</div></div>'
        )
        new_stats_block = (
            '    <div class="stats">\n'
            f'      <div class="stat warn"><div class="stn">{_lc_days}</div><div class="stl">Días al Go-Live · 15 Ene 2027</div></div>\n'
            '      <div class="stat"><div class="stn">8</div><div class="stl">Fases del lifecycle</div></div>\n'
            '      <div class="stat"><div class="stn">79</div><div class="stl">User Stories — 46 Must</div></div>'
        )
        if old_stats_block in lc:
            lc = lc.replace(old_stats_block, new_stats_block)

        # 4. CSS: añadir .stat.warn si no existe
        if '.stat.warn' not in lc:
            lc = lc.replace(
                '.stl{font-size:10px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}',
                '.stl{font-size:10px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}\n'
                '.stat.warn{border-color:rgba(240,210,36,.35);background:rgba(240,210,36,.06)}'
                '.stat.warn .stn{background:linear-gradient(180deg,var(--yellow),#e0b800);-webkit-background-clip:text;background-clip:text}'
            )

        # ── Eliminar bloque pnEl legado (doble render) ───────────────────────
        import re as _re
        if "const pnEl = document.getElementById('phase-narrative')" in lc:
            lc = _re.sub(
                r"\s*const pnEl = document\.getElementById\('phase-narrative'\);[\s\S]*?} else if\(pnEl\)\{ pnEl\.innerHTML=''; \}",
                "",
                lc
            )

        # ── Inyectar narrativas funcionales de DT-Productos ──────────────────
        # 1. CSS para la sección de narrativa
        narrative_css = """
/* Narrativa funcional por fase — DT-Productos */
.ph-narr{margin-top:28px;border-radius:20px;background:var(--glass);border:1px solid var(--glassb);
  backdrop-filter:blur(18px);padding:28px 28px 20px;animation:fadeUp .35s ease}
@keyframes fadeUp{from{opacity:0;transform:translateY(8px)}to{opacity:1;transform:translateY(0)}}
.ph-narr-eyebrow{font-size:9px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:10px}
.ph-narr-industry{font-size:13px;color:var(--muted);line-height:1.65;margin-bottom:20px}
.ph-narr-cols{display:grid;grid-template-columns:1fr 1fr;gap:20px}
@media(max-width:700px){.ph-narr-cols{grid-template-columns:1fr}}
.ph-narr-block{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);
  border-radius:14px;padding:14px 16px}
.ph-narr-block-title{font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:10px}
.ph-narr-kpi-row{display:flex;justify-content:space-between;align-items:baseline;
  padding:5px 0;border-bottom:1px solid rgba(255,255,255,.05);gap:8px}
.ph-narr-kpi-row:last-child{border-bottom:none}
.ph-narr-kpi-k{font-size:11px;color:var(--muted)}
.ph-narr-kpi-v{font-size:11px;font-weight:600;color:#fff;text-align:right}
.ph-narr-brecha{display:flex;align-items:flex-start;gap:8px;padding:5px 0;
  border-bottom:1px solid rgba(255,255,255,.05)}
.ph-narr-brecha:last-child{border-bottom:none}
.ph-narr-brecha-dot{width:6px;height:6px;border-radius:50%;flex-shrink:0;margin-top:5px}
.ph-narr-brecha-dot.crit{background:#ff4d4d}
.ph-narr-brecha-dot.warn{background:var(--yellow)}
.ph-narr-brecha-txt{font-size:11px;color:var(--muted);line-height:1.45}
"""
        if "ph-narr{margin-top" not in lc:
            lc = lc.replace("/* Phase content */", narrative_css + "\n/* Phase content */")

        # 2. Placeholder div — inmediatamente después del flow-wrap (antes de notes)
        if 'id="phase-narrative"' not in lc:
            lc = lc.replace(
                '<div class="flow-wrap" id="flow-wrap"></div>',
                '<div class="flow-wrap" id="flow-wrap"></div>\n    <div id="phase-narrative"></div>'
            )
        # Si quedó en la posición vieja (después de phase-notes), moverlo
        elif '<div id="phase-notes"></div>\n    <div id="phase-narrative"></div>' in lc:
            lc = lc.replace(
                '<div class="flow-wrap" id="flow-wrap"></div>\n    <div id="phase-notes"></div>\n    <div id="phase-narrative"></div>',
                '<div class="flow-wrap" id="flow-wrap"></div>\n    <div id="phase-narrative"></div>\n    <div id="phase-notes"></div>'
            )

        # 3. JS: datos de narrativa como constante global
        import json as _json
        narr_js_lines = ["const PHASE_NARRATIVES = {"]
        for pid, nd in PHASE_NARRATIVES.items():
            kpis_json  = _json.dumps(nd["kpis"],    ensure_ascii=False)
            brech_json = _json.dumps(nd["brechas"], ensure_ascii=False)
            industria  = nd["industria"].replace("\\", "\\\\").replace("`", "\\`").replace("${", "\\${")
            narr_js_lines.append(f"  {_json.dumps(pid)}: {{")
            narr_js_lines.append(f"    industria: `{industria}`,")
            narr_js_lines.append(f"    kpis: {kpis_json},")
            narr_js_lines.append(f"    brechas: {brech_json},")
            narr_js_lines.append("  },")
        narr_js_lines.append("};")
        narr_js = "\n".join(narr_js_lines)

        if "const PHASE_NARRATIVES" not in lc:
            lc = lc.replace("const PHASES = [", narr_js + "\n\nconst PHASES = [")

        # 4. JS: actualizar #phase-narrative al activar una fase
        # JS que inyecta la narrativa dentro de flow-wrap, antes del us-block
        narr_update_js = r"""
  /* Narrativa funcional — se inserta en fw antes del us-block */
  const narr = PHASE_NARRATIVES[id];
"""
        narr_insert_js = r"""
  if(narr){
    const _kHtml = narr.kpis.map(r=>`<div class="ph-narr-kpi-row"><span class="ph-narr-kpi-k">${r.k}</span><span class="ph-narr-kpi-v">${r.v}</span></div>`).join('');
    const _bHtml = narr.brechas.map(b=>`<div class="ph-narr-brecha"><span class="ph-narr-brecha-dot ${b.level}"></span><span class="ph-narr-brecha-txt">${b.txt}</span></div>`).join('');
    const _nd = document.createElement('div');
    _nd.innerHTML = `<div class="ph-narr"><div class="ph-narr-eyebrow">Proceso de industria · Marco regulatorio MX</div><p class="ph-narr-industry">${narr.industria}</p><div class="ph-narr-cols"><div class="ph-narr-block"><div class="ph-narr-block-title">KPIs de referencia</div>${_kHtml}</div><div class="ph-narr-block"><div class="ph-narr-block-title">Brechas identificadas en R4</div>${_bHtml}</div></div></div>`;
    const _us = fw.querySelector('.us-block');
    if(_us) fw.insertBefore(_nd.firstElementChild, _us);
    else fw.appendChild(_nd.firstElementChild);
  }
"""
        if "PHASE_NARRATIVES[id]" not in lc:
            lc = lc.replace("  /* Meta panel */", narr_update_js + "\n  /* Meta panel */")
        if "fw.querySelector('.us-block')" not in lc:
            lc = lc.replace("  fw.innerHTML = html;", "  fw.innerHTML = html;\n" + narr_insert_js)

        # ── Tabla paso-a-paso (PHASE_STEPS — desde brain.db) ─────────────────
        phase_steps = data.get("phase_steps", {})

        # CSS de la tabla de pasos (guard: 'pns-scroll')
        steps_css = """
/* Tabla paso a paso por fase — brain.db lifecycle_phase_steps */
.ph-narr-steps-wrap{margin:4px 0 20px}
.ph-narr-steps-title{font-size:9px;font-weight:700;letter-spacing:.1em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:8px}
.pns-scroll{overflow-x:auto}
.pns-table{width:100%;border-collapse:collapse;font-size:12px}
.pns-table th{text-align:left;padding:6px 10px;color:var(--muted2);font-weight:700;
  font-size:9px;letter-spacing:.08em;text-transform:uppercase;
  border-bottom:1px solid rgba(255,255,255,.08)}
.pns-table td{padding:7px 10px;border-bottom:1px solid rgba(255,255,255,.04);vertical-align:top;line-height:1.4}
.pns-table tr:last-child td{border-bottom:none}
.pns-table tr:hover td{background:rgba(255,255,255,.03)}
.pns-n{color:var(--muted2);font-variant-numeric:tabular-nums;width:20px;text-align:center}
.pns-paso{color:var(--text)}
.pns-sis{color:#7bb3f0;white-space:nowrap;font-size:11px}
.pns-us-id{font-family:monospace;font-size:10px;background:rgba(100,180,255,.12);
  color:#7bb3f0;padding:2px 7px;border-radius:4px;white-space:nowrap}
.pns-us-none{color:var(--muted2);font-size:11px}
"""
        if "pns-scroll" not in lc:
            lc = lc.replace("/* Phase content */", steps_css + "\n/* Phase content */")

        # JS: constante PHASE_STEPS serializada desde brain
        import json as _json2
        steps_js_lines = ["const PHASE_STEPS = {"]
        for pid, slist in phase_steps.items():
            steps_js_lines.append(f"  {_json2.dumps(pid)}: {_json2.dumps(slist, ensure_ascii=False)},")
        steps_js_lines.append("};")
        steps_js = "\n".join(steps_js_lines)
        if "const PHASE_STEPS" not in lc:
            lc = lc.replace("const PHASES = [", steps_js + "\n\nconst PHASES = [")

        # JS: insertar tabla de pasos dentro de .ph-narr, antes de .ph-narr-cols
        steps_render_js = r"""
  const psteps = PHASE_STEPS[id];
  const narrEl = fw.querySelector('.ph-narr');
  if(narrEl && psteps && psteps.length){
    const stHtml = psteps.map(s=>`<tr>
      <td class="pns-n">${s.n}</td>
      <td class="pns-paso">${s.paso}</td>
      <td class="pns-sis">${s.sistema}</td>
      <td class="pns-us">${s.us !== '—' ? `<span class="pns-us-id">${s.us}</span>` : `<span class="pns-us-none">—</span>`}</td>
    </tr>`).join('');
    const _sd = document.createElement('div');
    _sd.innerHTML = `<div class="ph-narr-steps-wrap"><div class="ph-narr-steps-title">Proceso paso a paso · Sistema · User Story R4</div><div class="pns-scroll"><table class="pns-table"><thead><tr><th>#</th><th>Paso del proceso</th><th>Sistema</th><th>User Story</th></tr></thead><tbody>${stHtml}</tbody></table></div></div>`;
    const _cols = narrEl.querySelector('.ph-narr-cols');
    if(_cols) narrEl.insertBefore(_sd.firstElementChild, _cols);
    else narrEl.appendChild(_sd.firstElementChild);
  }
"""
        if "PHASE_STEPS[id]" not in lc:
            lc = lc.replace("  fw.innerHTML = html;\n" + narr_insert_js,
                            "  fw.innerHTML = html;\n" + narr_insert_js + steps_render_js)

        lifecycle_path.write_text(lc, encoding="utf-8")
        print(f"[build-portal] lifecycle-p4900.html títulos actualizados ✓")

    # Drill-down Vista Sistemas
    build_systems_page(str(brain_path), out_path.parent)

    # Drill-down Vista Capacidades IT
    build_capacidades_it_page(str(brain_path), out_path.parent)

    print(f"[build-portal] OK — {out_path}")
    print(f"  Productos : {len(data['products'])} | Releases: {len(data['releases'])}")
    print(f"  Sistemas  : {len(data['components'])}")
    print(f"  RAG tracks: {len(data['track_rags'])}")
    print(f"  Riesgos   : {len(data['risks'])}")
    print(f"  Hitos     : {len(data['milestones'])}")
    print(f"  Días al Go-Live: {days_to_golive()}")


if __name__ == "__main__":
    main()



