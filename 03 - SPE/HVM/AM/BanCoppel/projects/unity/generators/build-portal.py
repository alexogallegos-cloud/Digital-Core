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

# ── IT Capabilities (cara verde del cubo) ─────────────────────────────────────
# No hay tabla dedicada en el brain aún → config estática en el generador.
# Cuando se agregue la tabla `it_capabilities` al brain, leer de ahí.
IT_CAPS = {
    "Engineering": ["QE", "DevOps"],
    "Delivery":    ["Arquitectura", "Interoperabilidad", "Ambientación", "Seguridad"],
    "Operations":  ["Observabilidad", "Change", "Release", "Vendor Mgmt", "Compliance"],
    "Data":        ["Data / Migración"],
}

# ── Digital Twins config (no hay tabla en el brain aún) ───────────────────────
DT_GROUPS = [
    {
        "label": "Programa y Gestión",
        "twins": [
            {"ico": "📋", "ver": "v1.0.0", "name": "Plan Director",
             "desc": "Visión transversal del programa, KPI framework, dashboard RAG cruzado, 8 acciones críticas, anti-silos.",
             "chips": [("yellow","KPIs"),("blue","RAG"),("blue","76 User Stories")],
             "link": "plan-director.html", "warn": True},
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
             "desc": "58 HDUs, 14 DTMs, cobertura PreGame, gaps críticos DPP, BYU0039 y OCG manual.",
             "chips": [("blue","58 HDUs"),("red","5 gaps críticos")], "warn": True},
            {"ico": "🚀", "ver": "v1.1.0", "name": "APOLO",
             "desc": "37 HDUs originación digital, 10 fases, 13 sprints backend, integración crítica con SmartVista (HDU-20).",
             "chips": [("blue","37 HDUs"),("yellow","Tensión fechas")], "warn": True},
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
        "SELECT * FROM product_releases ORDER BY product_id, id"
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
        "SELECT COUNT(*) FROM risks WHERE probability='high' AND status='open'"
    ).fetchone()[0]

    # Riesgos (alta prioridad abiertos primero)
    risks = con.execute("""
        SELECT r.*, pc.name AS component_name
        FROM risks r
        LEFT JOIN program_components pc ON r.component_id = pc.id
        WHERE r.status IN ('open','escalated')
        ORDER BY
            CASE r.probability WHEN 'high' THEN 0 WHEN 'medium' THEN 1 ELSE 2 END,
            CASE r.impact WHEN 'critical' THEN 0 WHEN 'high' THEN 1 WHEN 'medium' THEN 2 ELSE 3 END
        LIMIT 9
    """).fetchall()

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

    con.close()
    return {
        "products":    products,
        "releases":    releases,
        "components":  components,
        "track_rags":  track_rags,
        "total_hus":   total_hus,
        "high_risks":  high_risks,
        "risks":       risks,
        "milestones":  milestones,
        "phase_steps": phase_steps,
    }

# ── Render parciales ──────────────────────────────────────────────────────────

EXCLUDED_STATUSES = {"sin-definir", "undefined", "tbd", "backlog", "planned"}

def _static_cube(variant, top="", front="", right=""):
    """Cubo decorativo estático con contenido real en la cara destacada (p=top, s=front, c=right)."""
    return f"""<div class="vw-scene">
          <div class="cube3d vw-static vw-static-{variant}">
            <div class="cf cf-top"><div class="cf-title">Productos</div>{top}</div>
            <div class="cf cf-front"><div class="cf-title">Sistemas</div>{front}</div>
            <div class="cf cf-right"><div class="cf-title">Capacidades IT</div>{right}</div>
            <div class="cf cf-back"><div class="cf-title">Unity R4</div></div>
            <div class="cf cf-left"></div>
            <div class="cf cf-bot"></div>
          </div>
        </div>"""


def render_view_productos(products, releases, cube_top_content="", cube_img=None):
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

    # KPIs
    kpis_html = ""
    for kpi in KPIS_VP:
        gap_cls = " gap" if kpi["gap"] else ""
        kpis_html += (
            f'<div class="vp-kpi{gap_cls}">'
            f'<div class="vp-kval">{h(kpi["value"])}</div>'
            f'<div class="vp-klabel">{h(kpi["label"])}</div>'
            f'<div class="vp-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # Bloqueos
    blocks_html = ""
    for blk in BLOCKERS_VP:
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
    "smartvista": {"name": "SmartVista BPC",       "type": "Core · Procesador de tarjetas", "note": "5 DTMs con gap crítico — DPP, BYU0039 y OCG sin plan de cierre"},
    "apolo":      {"name": "APOLO",                "type": "Core · Originación digital",    "note": "Tensión de fechas — backend cierra 15-oct, go-live 15-ene"},
    "app":        {"name": "App / Canal Digital",  "type": "Channel · AppMóvil",            "note": "6 User Stories Must cierran en noviembre, posterior al inicio de SIT"},
    "cat":        {"name": "CAT — Contact Center", "type": "Channel · IBR + ICAT",          "note": "Proveedor sin contratar — 12 User Stories Must sin owner técnico"},
    "siweb":      {"name": "SIWEB — Sucursales",   "type": "Channel · Ventanilla",          "note": "Bloqueado por APIs de SmartVista sin fecha de entrega confirmada"},
}

KPIS_VS = [
    {"value": "79",     "label": "User Stories",           "sub": "46 Must Have · 33 Should / Could",  "gap": False},
    {"value": "18",     "label": "Integraciones",          "sub": "9 nuevas · 9 modificadas",           "gap": False},
    {"value": "58",     "label": "HDUs de diseño",         "sub": "SmartVista · App · CAT · SIWEB",    "gap": False},
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
        "diseno":        ("green",  "37 HDUs completos · 17 BBs"),
        "integraciones": ("yellow", "HDU-20 integración crítica con SV"),
        "riesgos":       ("yellow", "Tensión fechas: 15-ene vs 22-ene"),
        "pruebas":       ("yellow", "8 critical breakers ADP por cerrar"),
    },
    "app": {
        "avance":        ("yellow", "18 USs · 6 Must cierran noviembre"),
        "diseno":        ("green",  "20 HDUs cubiertos"),
        "integraciones": ("yellow", "4 integraciones · 2 nuevas"),
        "riesgos":       ("yellow", "6 USs Must posteriores al inicio SIT"),
        "pruebas":       ("yellow", "Pentest nov 15-20 en conflicto SIT"),
    },
    "cat": {
        "avance":        ("red",    "12 USs Must sin owner técnico"),
        "diseno":        ("red",    "12 HDUs sin proveedor que los entregue"),
        "integraciones": ("red",    "7 integraciones sin responsable"),
        "riesgos":       ("red",    "RISK-001 · proveedor sin contratar"),
        "pruebas":       ("red",    "Sin plan de pruebas posible"),
    },
    "siweb": {
        "avance":        ("yellow", "5 USs · bloqueadas por APIs SV"),
        "diseno":        ("green",  "5 HDUs cubiertos"),
        "integraciones": ("red",    "Bloqueado por APIs SmartVista BPC"),
        "riesgos":       ("yellow", "Dependencia crítica sin resolver"),
        "pruebas":       ("yellow", "Sin fecha de inicio confirmada"),
    },
}


def render_view_sistemas(components, cube_front_content="", cube_img=None,
                          track_rags=None, us_must_by_track=None):
    """Vista Sistemas: semáforo por track, KPIs técnicos y bloqueos activos."""
    track_rags       = track_rags or []
    us_must_by_track = us_must_by_track or {}

    # ── Bloque 1: semáforo por sistema ───────────────────────────────────────
    rag_map = {r["track"]: dict(r) for r in track_rags}
    tracks_html = ""
    for track_id, meta in SYSTEM_META_VS.items():
        rag   = rag_map.get(track_id, {})
        color = rag.get("rag_color") or "yellow"
        dot   = {"red": "🔴", "yellow": "🟡", "green": "🟢"}.get(color, "⚪")
        css   = {"red": "r", "yellow": "y", "green": "g"}.get(color, "")
        total = rag.get("hu_total") or 0
        must  = us_must_by_track.get(track_id, 0)
        us_lbl = f"{must} Must · {total} total" if total else ""
        tracks_html += (
            f'<div class="vs-track {css}">'
            f'<div class="vs-tname">{dot} {h(meta["name"])}</div>'
            f'<div class="vs-ttype">{h(meta["type"])}</div>'
            f'{"<div class=vs-tus>" + h(us_lbl) + "</div>" if us_lbl else ""}'
            f'<div class="vs-tnote">{h(meta["note"])}</div>'
            f'</div>'
        )

    # ── Bloque 2: KPIs técnicos ───────────────────────────────────────────────
    kpis_html = ""
    for kpi in KPIS_VS:
        gap_cls = " gap" if kpi["gap"] else ""
        kpis_html += (
            f'<div class="vs-kpi{gap_cls}">'
            f'<div class="vs-kval">{h(kpi["value"])}</div>'
            f'<div class="vs-klabel">{h(kpi["label"])}</div>'
            f'<div class="vs-ksub">{h(kpi["sub"])}</div>'
            f'</div>'
        )

    # ── Bloque 3: bloqueos por sistema ────────────────────────────────────────
    blocks_html = ""
    for blk in BLOCKERS_VS:
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
            <h2 class="vw-h2 vwc-s">Habilitadores del Proceso</h2>
            <p class="vw-desc">Estado de los sistemas que ejecutan el producto end-to-end. Cada stack tiene su propio SDLC y plan de entrega — SmartVista, Apolo, canales digitales. Esta vista gobierna los planes individuales y los alimenta al gobierno de la Vista de Producto.</p>
            <div class="vs-section-label">Estado por Sistema</div>
            <div class="vs-tracks">{tracks_html}</div>
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


def render_view_capacidades(cube_right_content="", cube_img=None):
    """Sección Vista Capacidades IT: cubo izquierda orientado a cara derecha (verde), contenido derecha."""
    lines = []
    for group, items in IT_CAPS.items():
        lines.append(f'<div class="fgl">{group}</div>')
        for i in range(0, len(items), 2):
            pair = items[i:i+2]
            if len(pair) == 2:
                lines.append('<div class="fpair">')
                for it in pair:
                    lines.append(f'  <div class="frow"><span class="fname">{h(it)}</span></div>')
                lines.append('</div>')
            else:
                lines.append(f'<div class="frow"><span class="fname">{h(pair[0])}</span></div>')
    content = "\n          ".join(lines)

    return f"""
        <div class="wrap">
        <div class="vw-grid reveal">
          <div class="vw-cube-wrap">
            {(f'<img src="{cube_img}" alt="Capacidades IT" class="vw-cube-img">' if cube_img else _static_cube("c", right=cube_right_content))}
          </div>
          <div class="vw-body">
            <div class="kick">Vista · Capacidades IT</div>
            <h2 class="vw-h2 vwc-c">Capacidades Transversales de TI</h2>
            <p class="vw-desc">Capacidades institucionales del banco — no exclusivas de este proyecto. Proveen servicios de implementación y operación a cualquier iniciativa, midiendo su capacidad y madurez de entrega. Gestionan la demanda, los proveedores y la evolución del SDLC, estableciendo las bases fundacionales de operación y resiliencia operativa que soportan a la Vista de Sistemas y la Vista de Producto.</p>
          </div>
        </div>
        </div>"""


def render_cube_productos(products, releases):
    lines = []
    rel_by_product = {}
    for r in releases:
        rel_by_product.setdefault(r["product_id"], []).append(r)

    for prod in products:
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
    days   = days_to_golive()
    hus    = data["total_hus"] or 79
    risks_n = data["high_risks"] or 9

    cube_imgs  = cube_imgs or {}
    cube_prod  = render_cube_productos(data["products"], data["releases"])
    cube_sis   = render_cube_sistemas(data["components"])
    cube_cap   = render_cube_capacidades()
    view_prod  = render_view_productos(data["products"], data["releases"], cube_prod,
                                       cube_img=cube_imgs.get("productos"))
    view_sis   = render_view_sistemas(data["components"], cube_sis,
                                      cube_img=cube_imgs.get("sistemas"),
                                      track_rags=data.get("track_rags", []),
                                      us_must_by_track=data.get("us_must_by_track", {}))
    view_cap   = render_view_capacidades(cube_cap,
                                         cube_img=cube_imgs.get("capacidades"))
    rag_html   = render_rag(data["track_rags"])
    risk_html  = render_risks(data["risks"])
    mile_html  = render_milestones(data["milestones"])
    dt_html    = render_dt_groups()
    generated  = datetime.now().strftime("%Y-%m-%d %H:%M")

    return f"""<!DOCTYPE html>
<!-- Unity R4 — Plan Director · Portal de Programa · BanCoppel
     SPE-AM-001 · Generado por generators/build-portal.py · {generated} -->
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Unity R4 — Plan Director — BanCoppel</title>
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
  overflow-y:auto;padding:8px;border-radius:4px}}
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
</style></head>
<body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
<div id="prog"></div>

<nav>
  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display='none'">
  <span class="nt">Unity R4 — Plan Director</span>
  <span class="sp"></span>
  <span class="nav-links" style="display:contents">
    <a class="jump" href="#view-productos">Alcance</a>
    <a class="jump" href="#estado">Estado</a>
    <a class="jump" href="#twins">Digital Twins</a>
    <a class="jump" href="#cronograma">Cronograma</a>
    <a class="jump" href="#riesgos">Riesgos</a>
    <a class="jump ext" href="apolo-itcaps.html">APOLO IT Caps ↗</a>
    <a class="jump ext" href="duplicidad-informix-unity.html">Duplicidad ↗</a>
    <a class="jump ext" href="plan-director.html">Plan Director ↗</a>
  </span>
</nav>

<div class="wrap">

  <header class="hero">
    <div>
      <div class="eyebrow reveal">
        <span class="dot"></span>&nbsp; SPE-AM-001, Unity R4, BUILD, ago 2026
      </div>
      <h1 class="reveal">Plan Director<br>Unity R4</h1>
      <p class="sub reveal">
        Programa de modernización del core bancario BanCoppel.<br>
        <b>Tarjeta de Crédito — Producto P4900.</b><br>
        SmartVista BPC, APOLO, Temenos Transact.
      </p>
      <div class="countdown glass reveal">
        <div class="cdays" id="cdays">{days}</div>
        <div class="clabel">días al Go-Live — 15 enero 2027</div>
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
          <div class="cf cf-back"><div class="cf-title">Unity R4</div></div>
          <div class="cf cf-left"></div>
          <div class="cf cf-bot"></div>
        </div>
      </div>
    </div>
  </header>

  <div class="stats reveal" style="margin:0 0 60px">
    <div class="stat glass">
      <div class="statn" id="s-days">{days}</div>
      <div class="statl">Días al Go-Live — 15 Enero 2027</div>
    </div>
    <div class="stat glass warn">
      <div class="statn">21.19%</div>
      <div class="statl">Avance R4 TDC, 60.58% esperado al 17-ago</div>
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
      <div class="statn" data-target="10">0</div>
      <div class="statl">Decisiones pendientes del Design Authority</div>
    </div>
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

  <section id="estado">
    <div class="stats reveal">
      <div class="stat glass">
        <div class="statn" id="s-days">{days}</div>
        <div class="statl">Días al Go-Live</div>
      </div>
      <div class="stat glass warn">
        <div class="statn">21.19%</div>
        <div class="statl">Avance R4 TDC, 60.58% esperado al 17-ago</div>
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
        <div class="statn" data-target="10">0</div>
        <div class="statl">Decisiones pendientes del Design Authority</div>
      </div>
    </div>

    <div style="margin-top:52px">
      <div class="shead reveal">
        <div class="kick">Semáforo del Programa</div>
        <h2>Estado por Track</h2>
        <p>Fuente: Roadmap Accenture 11-ago-2026 y Plan de Trabajo con corte 17-ago-2026</p>
      </div>
      <div class="rag-grid reveal">
        {rag_html}
      </div>
    </div>
  </section>

  <section id="twins">
    <div class="shead reveal">
      <div class="kick">Gemelos Digitales</div>
      <h2>Plan Director — 14 Digital Twins</h2>
      <p>Cobertura end-to-end del programa Unity R4 — desde gobernanza hasta operaciones.</p>
    </div>
    {dt_html}
  </section>

  <section id="riesgos">
    <div class="shead reveal">
      <div class="kick">Registro de Riesgos</div>
      <h2>Riesgos de Alta Prioridad</h2>
      <p>9 riesgos de probabilidad alta, RAID v2.0 con corte 03-ago-2026, responsable Ma. Fernanda Barbosa</p>
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
  <code>Unity R4, Plan Director, SPE-AM-001</code>, BanCoppel, Accenture México<br>
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

# KPIs técnicos para Vista Sistemas
KPIS_VS = [
    {"label": "Sistemas R4",      "value": "7",       "sub": "En el alcance de entrega",       "gap": False},
    {"label": "User Stories",     "value": "79",      "sub": "46 Must · 28 Should",            "gap": False},
    {"label": "Avance global",    "value": "21.19%",  "sub": "vs 60.58% esperado al 17-ago",   "gap": False},
    {"label": "Sistemas en riesgo","value": "2 / 7",  "sub": "CAT crítico · SIWEB bloqueado",  "gap": False},
    {"label": "Integración ATLAS","value": "—",       "sub": "Golden Record pendiente sep-2026","gap": True},
    {"label": "Pentest",          "value": "—",       "sub": "Conflicto ventana nov 15-20",    "gap": True},
]

# Bloqueos activos por sistema
BLOCKERS_VS = [
    {"text": "CAT: proveedor de contact center sin contratar",         "sys": "CAT",       "owner": "BanCoppel",  "level": "crit"},
    {"text": "SIWEB: bloqueado por dependencias de APIs pendientes",   "sys": "SIWEB",     "owner": "Accenture",  "level": "warn"},
    {"text": "Apolo: 6 User Stories Must cierran en noviembre",        "sys": "APOLO",     "owner": "Appwhere",   "level": "warn"},
    {"text": "SmartVista: DTMs abiertos sin fecha de resolución",      "sys": "SmartVista","owner": "BPC / ACN",  "level": "warn"},
]

# Metadata editorial para Vista Sistemas (semáforo de tracks en index.html)
SYSTEM_META_VS = {
    "smartvista": {"name": "SmartVista (BPC)", "type": "Processors / CMS", "note": "Gestión ciclo de vida TDC"},
    "apolo":      {"name": "APOLO — Originación", "type": "Channels / Onboarding", "note": "Originación digital TDC"},
    "app":        {"name": "APP / AppMovil", "type": "Channels / Digital", "note": "Canal digital BanCoppel"},
    "cat":        {"name": "CAT — Contact Center", "type": "Channels / IBR+ICAT", "note": "Atención y soporte TDC"},
    "siweb":      {"name": "SIWEB — Sucursales", "type": "Channels / Sucursales", "note": "Canal sucursal físico"},
    "cobranza":   {"name": "Cobranza Direccionada", "type": "Enabler / Cobranza", "note": "Gestión de cobranza"},
    "apificacion":{"name": "Apificación (ACN)", "type": "Integration / APIs", "note": "Capa de integración R4"},
}

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
        "sdlc_phase": "BUILD", "sdlc_progress": 35, "sdlc_status": "yellow",
        "summary": "Plataforma core bancario destino (Temenos Transact). Recibe la migracion de cuentas, originacion y contabilidad GL desde Informix. Plataforma target de Unity R4.",
        "milestones": [
            {"label": "Contrato Temenos firmado",              "date": "2026-01",   "status": "done"},
            {"label": "Configuracion productos TDC P4900",     "date": "2026-08",   "status": "done"},
            {"label": "SIT Transact-SmartVista-eGlobal",       "date": "2026-10",   "status": "pending"},
            {"label": "UAT contabilidad GL end-to-end",        "date": "2026-11",   "status": "pending"},
            {"label": "GoLive R4",                             "date": "2026-12",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-ONBOARDING-DIGITAL","CAP-BALANCE-STATEMENT","CAP-FEE-COMMISSION","CAP-ERROR-CATALOG","CAP-CUSTOMER-PROFILE","CAP-COLLECTIONS-ENGINE"],
    },
    "smartvista": {
        "sdlc_phase": "BUILD", "sdlc_progress": 55, "sdlc_status": "yellow",
        "summary": "Motor de gestion de tarjetas TDC P4900 (BPC Banking Technologies). Maneja autorizacion, ciclo de vida de tarjeta y MDM. Reemplaza CMS/Intercard/Macweb post-GoLive.",
        "milestones": [
            {"label": "Contrato BPC firmado",                  "date": "2026-01",   "status": "done"},
            {"label": "Catalogo 37 HDUs SmartVista",           "date": "2026-08-01","status": "done"},
            {"label": "Correccion macro APP-MF-02 (QA)",       "date": "2026-08-20","status": "done"},
            {"label": "SIT SmartVista-Transact-eGlobal",       "date": "2026-09",   "status": "pending"},
            {"label": "UAT tarjeta de credito end-to-end",     "date": "2026-10",   "status": "pending"},
            {"label": "GoLive — CMS/Intercard a DEPRECATE",   "date": "2026-12",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-CREDIT-LIMIT","CAP-PAYMENT","CAP-DEFERRED-PURCHASE","CAP-CARD-MANUFACTURING"],
    },
    "apolo": {
        "sdlc_phase": "BUILD", "sdlc_progress": 45, "sdlc_status": "yellow",
        "summary": "Canal digital (Appwhere) para oferta y originacion de TDC. Primer punto de contacto del cliente para solicitud de tarjeta. Bridge de datos hacia Transact.",
        "milestones": [
            {"label": "37 HDUs APOLO catalogados",             "date": "2026-08-01","status": "done"},
            {"label": "Integracion Apolo-Transact (API)",      "date": "2026-09",   "status": "pending"},
            {"label": "SIT originacion TDC completa",          "date": "2026-10",   "status": "pending"},
            {"label": "GoLive canal Apolo",                    "date": "2026-12",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-ONBOARDING-DIGITAL","CAP-DEFERRED-PURCHASE","CAP-CUSTOMER-PROFILE"],
    },
    "app-movil": {
        "sdlc_phase": "BUILD", "sdlc_progress": 42, "sdlc_status": "yellow",
        "summary": "Canal movil BanCoppel (Nova). Canal principal del cliente digital: activacion de tarjeta, autorizacion TDC, pagos, consultas de saldo y compras diferidas.",
        "milestones": [
            {"label": "79 HUs inventariadas (App TDC R4)",     "date": "2026-08-19","status": "done"},
            {"label": "Encendido/Apagado TDC (+3 HUs)",        "date": "2026-08-19","status": "done"},
            {"label": "SIT App-SmartVista-Transact",           "date": "2026-10",   "status": "pending"},
            {"label": "UAT cliente digital",                   "date": "2026-11",   "status": "pending"},
            {"label": "GoLive App Movil TDC",                  "date": "2026-12",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-PAYMENT","CAP-BALANCE-STATEMENT","CAP-DEFERRED-PURCHASE","CAP-COLLECTIONS-AGING","CAP-CARD-LIFECYCLE","CAP-ONBOARDING-DIGITAL"],
    },
    "siweb": {
        "exclude": True, "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "summary": "Canal web de sucursal (interno BanCoppel). Operaciones de ventanilla y soporte al cliente. Sistema baseline; candidato a refactor post-R4.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Adaptacion flujos TDC P4900",           "date": "2026-Q4",   "status": "pending"},
            {"label": "Revision roadmap post-GoLive",          "date": "2027-Q1",   "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-PAYMENT","CAP-BALANCE-STATEMENT","CAP-CARD-LIFECYCLE"],
    },
    "cat": {
        "sdlc_phase": "DISCOVER", "sdlc_progress": 20, "sdlc_status": "red",
        "summary": "Canales Alternativos de Pago — TPV, corresponsales, kioscos. Proveedor sin contratar al 2026-08-31. Riesgo RISK-UNITY-R27 activo.",
        "milestones": [
            {"label": "Requerimientos funcionales definidos",  "date": "2026-07",   "status": "done"},
            {"label": "RFP / seleccion de proveedor",         "date": "2026-08-31","status": "pending"},
            {"label": "Contrato y kickoff",                    "date": "2026-09",   "status": "planned"},
            {"label": "GoLive CAT",                           "date": "TBD",        "status": "planned"},
        ],
        "capabilities_impacted": ["CAP-PAYMENT"],
    },
    "atlas": {
        "sdlc_phase": "DESIGN", "sdlc_progress": 60, "sdlc_status": "green",
        "summary": "Plataforma de datos analiticos en GCP (BigQuery + Dataflow). Recibe feeds desde Informix y Transact. Soporte a reportes regulatorios CNBV y analitica de negocio.",
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
        "sdlc_phase": "OPERATE", "sdlc_progress": 100, "sdlc_status": "green",
        "summary": "Switch ISO 8583 interno BanCoppel. Valida 88 reglas de transacciones TDC contra SmartVista. Frontera critica de autorizacion en tiempo real.",
        "milestones": [
            {"label": "Sistema en produccion (baseline)",      "date": "< 2024",    "status": "done"},
            {"label": "Validacion 88 reglas vs SmartVista",    "date": "2026-08",   "status": "done"},
            {"label": "SIT eGlobal-SmartVista-Transact",       "date": "2026-09",   "status": "pending"},
            {"label": "Pruebas de carga ISO 8583 P4900",       "date": "2026-10",   "status": "pending"},
        ],
        "capabilities_impacted": ["CAP-CARD-LIFECYCLE","CAP-PAYMENT"],
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



def build_systems_page(brain_path: str, out_dir) -> None:
    """Genera portal/systems-p4900.html — drill-down Vista Sistemas."""
    import json as _json
    import sqlite3 as _sq

    con = _sq.connect(brain_path)
    systems = [
        r for r in con.execute(
            "SELECT id, name, vendor, togaf_type, togaf_state, togaf_abb, role_in_r4, status, notes "
            "FROM program_systems ORDER BY togaf_type, id"
        ).fetchall()
        if not SYSTEM_SDLC.get(r[0], {}).get('exclude', False)
    ]
    caps = {r[0]: {'name': r[1], 'status': r[2]} for r in con.execute(
        "SELECT id, name, coverage_status FROM program_capabilities"
    ).fetchall()}
    systems_js = {}
    for row in systems:
        sid, name, vendor, ttype, tstate, tabb, role, st, notes = row
        sdlc = SYSTEM_SDLC.get(sid, {})
        systems_js[sid] = {
            "id": sid, "name": name, "vendor": vendor or "",
            "togaf_type": ttype, "togaf_state": tstate, "togaf_abb": tabb or "",
            "role_in_r4": role or "", "status": st,
            "color": TOGAF_TYPE_COLOR.get(ttype, "#666"),
            "state_label": TOGAF_STATE_LABEL.get(tstate, tstate.upper()),
            "sdlc_phase": sdlc.get("sdlc_phase", "DISCOVER"),
            "sdlc_progress": sdlc.get("sdlc_progress", 0),
            "sdlc_status": sdlc.get("sdlc_status", "yellow"),
            "summary": sdlc.get("summary", role or ""),
            "milestones": sdlc.get("milestones", []),
            "capabilities_impacted": [
                {"id": cid, "name": caps.get(cid, {}).get("name", cid),
                 "coverage": caps.get(cid, {}).get("status", "unknown")}
                for cid in sdlc.get("capabilities_impacted", [])
            ],
        }

    systems_json = _json.dumps(systems_js, ensure_ascii=False, indent=2)

    by_type = {}
    for row in systems:
        sid, name, _, ttype, tstate, *_ = row
        sdlc = SYSTEM_SDLC.get(sid, {})
        sts = sdlc.get("sdlc_status", "yellow")
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

    html_parts = []
    html_parts.append('<!DOCTYPE html>')
    html_parts.append('<html lang="es">')
    html_parts.append('<head>')
    html_parts.append('<meta charset="UTF-8">')
    html_parts.append('<meta name="viewport" content="width=device-width,initial-scale=1">')
    html_parts.append('<title>Habilitadores del Proceso — Unity R4 | BanCoppel</title>')
    html_parts.append('<style>')
    html_parts.append('''
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
  --red:#E8400A;--green:#22c55e}
html{scroll-behavior:smooth}
body{background:#060a1a;color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;min-height:100vh;display:flex;flex-direction:column}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(27,63,208,.45),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:50vw;height:50vw;right:-10vw;top:10vw;border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(13,33,133,.55),transparent 70%);animation:f2 28s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.12)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.10)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
nav{position:relative;z-index:50;display:flex;align-items:center;gap:14px;padding:13px 28px;
  backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);
  background:rgba(6,10,26,.65);border-bottom:1px solid rgba(255,255,255,.07)}
.nav-back{font-size:.78rem;font-weight:600;color:var(--muted);padding:5px 12px;border-radius:20px;
  transition:.2s;text-decoration:none;border:1px solid rgba(255,255,255,.08)}
.nav-back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.nav-sep{color:rgba(255,255,255,.18);margin:0 2px;font-size:.8rem}
.nav-title{font-size:.82rem;letter-spacing:.1em;color:var(--yellow);font-weight:700;text-transform:uppercase}
.nav-right{margin-left:auto;font-size:.72rem;color:var(--muted2);letter-spacing:.04em}
.layout{display:flex;flex:1;overflow:hidden;height:calc(100vh - 50px)}
.sidebar{width:252px;min-width:252px;background:rgba(10,20,50,.7);backdrop-filter:blur(12px);
  border-right:1px solid rgba(255,255,255,.07);overflow-y:auto;padding:14px 0}
.sb-title{font-size:.6rem;letter-spacing:.16em;color:rgba(255,255,255,.28);padding:0 16px 10px;text-transform:uppercase}
.sb-group{margin-bottom:6px}
.sb-group-label{font-size:.58rem;letter-spacing:.13em;text-transform:uppercase;font-weight:700;padding:8px 16px 4px;opacity:.7}
.sb-item{display:flex;align-items:center;gap:8px;padding:8px 16px;cursor:pointer;transition:.15s;border-left:3px solid transparent}
.sb-item:hover{background:rgba(255,255,255,.04)}
.sb-item.active{background:rgba(123,159,255,.1);border-left-color:#7B9FFF}
.sb-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}
.sb-name{font-size:.78rem;flex:1;color:var(--muted)}
.sb-state{font-size:.56rem;color:rgba(255,255,255,.28);letter-spacing:.06em;text-transform:uppercase;flex-shrink:0}
.main{flex:1;overflow-y:auto;padding:32px 40px}
.placeholder{display:flex;flex-direction:column;align-items:center;justify-content:center;height:100%;opacity:.3;gap:8px}
.placeholder p{font-size:.85rem;color:#7B9FFF}
.sys-panel{display:none}
.sys-panel.visible{display:block}
.sys-hdr{display:flex;align-items:flex-start;gap:20px;margin-bottom:28px}
.sys-abb{width:64px;height:64px;border-radius:14px;display:flex;align-items:center;justify-content:center;
  font-size:1.05rem;font-weight:800;color:#fff;flex-shrink:0;letter-spacing:.05em}
.sys-meta{flex:1}
.sys-name{font-size:1.55rem;font-weight:800;color:#fff;margin-bottom:4px;letter-spacing:-.02em}
.sys-vendor{font-size:.78rem;color:var(--muted2);margin-bottom:10px}
.sys-chips{display:flex;gap:8px;flex-wrap:wrap}
.chip{display:inline-block;padding:3px 10px;border-radius:20px;font-size:.63rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase}
.chip-baseline{background:rgba(255,255,255,.08);color:rgba(255,255,255,.55)}
.chip-transitional{background:rgba(123,159,255,.18);color:#7B9FFF}
.chip-target{background:rgba(240,210,36,.18);color:var(--yellow)}
.chip-active{background:rgba(76,175,80,.18);color:#4CAF50}
.chip-at_risk{background:rgba(255,82,82,.18);color:#FF5252}
.sys-role{font-size:.82rem;color:var(--muted);margin-top:4px;line-height:1.5;max-width:680px}
.section{margin-bottom:28px}
.sec-title{font-size:.62rem;letter-spacing:.16em;text-transform:uppercase;color:rgba(255,255,255,.28);
  margin-bottom:12px;padding-bottom:6px;border-bottom:1px solid rgba(255,255,255,.06)}
.sdlc-wrap{background:var(--glass);border:1px solid rgba(255,255,255,.06);border-radius:12px;padding:18px 20px}
.sdlc-phases{display:flex;gap:3px;margin-bottom:14px}
.sdlc-ph{flex:1;text-align:center;font-size:.58rem;letter-spacing:.05em;text-transform:uppercase;
  padding:8px 4px;border-radius:6px;color:rgba(255,255,255,.25);background:rgba(255,255,255,.03)}
.sdlc-ph.done{background:rgba(76,175,80,.13);color:#4CAF50}
.sdlc-ph.planned{background:rgba(255,255,255,.02);color:rgba(255,255,255,.12)}
.sdlc-bar-wrap{display:flex;align-items:center;gap:10px}
.sdlc-bar-bg{flex:1;height:6px;background:rgba(255,255,255,.07);border-radius:3px;overflow:hidden}
.sdlc-bar-fill{height:100%;border-radius:3px;transition:width .7s ease}
.sdlc-pct{font-size:.75rem;font-weight:700;min-width:36px;text-align:right}
.milestones{display:flex;flex-direction:column;gap:0}
.ms-row{display:flex;align-items:center;gap:12px;padding:9px 0;border-bottom:1px solid rgba(255,255,255,.04)}
.ms-row:last-child{border-bottom:none}
.ms-icon{width:18px;height:18px;border-radius:50%;display:flex;align-items:center;justify-content:center;flex-shrink:0;font-size:.7rem}
.ms-done{background:rgba(76,175,80,.22);color:#4CAF50}
.ms-pending{background:rgba(255,193,7,.18);color:#FFC107}
.ms-planned{background:rgba(255,255,255,.06);color:rgba(255,255,255,.28)}
.ms-label{flex:1;font-size:.8rem;color:var(--muted)}
.ms-date{font-size:.72rem;color:rgba(255,255,255,.3);min-width:70px;text-align:right}
.caps-grid{display:flex;flex-wrap:wrap;gap:8px}
.cap-chip{display:flex;align-items:center;gap:6px;padding:6px 12px;border-radius:20px;font-size:.72rem;
  background:var(--glass);border:1px solid rgba(255,255,255,.07);color:var(--muted)}
.cap-dot{width:7px;height:7px;border-radius:50%;flex-shrink:0}
.cov-full{background:#4CAF50}.cov-partial{background:#FFC107}.cov-not_covered{background:#FF5252}
.cov-not_applicable{background:#666}.cov-unknown{background:#888}
.summary-box{background:var(--glass);border-left:3px solid #7B9FFF;border-radius:0 10px 10px 0;
  padding:14px 18px;font-size:.82rem;color:var(--muted);line-height:1.65}
.impact-empty{font-size:.78rem;color:rgba(255,255,255,.22);font-style:italic}
''')
    html_parts.append('''
.sb-divider{height:1px;background:rgba(255,255,255,.06);margin:12px 8px}
.sb-section-title{font-size:.6rem;letter-spacing:.15em;color:rgba(255,255,255,.22);padding:12px 16px 4px;text-transform:uppercase}
.sb-view-toggle{display:flex;gap:4px;padding:8px 10px 4px}
.sv-btn{flex:1;padding:6px 0;border:none;border-radius:6px;font-size:.65rem;letter-spacing:.08em;text-transform:uppercase;font-weight:700;cursor:pointer;transition:.15s}
.sv-btn.active{background:#7B9FFF;color:#0a1628}
.sv-btn:not(.active){background:rgba(255,255,255,.06);color:rgba(255,255,255,.4)}
.legacy-view{display:none}
.r4-view{}
.legacy-panel{display:none}
.legacy-panel.visible{display:block}
.legacy-hdr{display:flex;align-items:flex-start;gap:16px;margin-bottom:24px}
.legacy-abb{width:56px;height:56px;border-radius:10px;display:flex;align-items:center;justify-content:center;font-size:.9rem;font-weight:800;color:#fff;flex-shrink:0;background:#444;letter-spacing:.04em}
.fate-chip{display:inline-block;padding:3px 10px;border-radius:20px;font-size:.65rem;font-weight:700;letter-spacing:.08em;text-transform:uppercase}
.fate-to-replace{background:rgba(255,82,82,.2);color:#FF5252}
.fate-to-decommission{background:rgba(255,82,82,.15);color:#FF7043}
.fate-coexists{background:rgba(255,193,7,.15);color:#FFC107}
.fate-complementary{background:rgba(76,175,80,.15);color:#4CAF50}
.fate-data-source{background:rgba(123,159,255,.15);color:#7B9FFF}
.fate-unknown{background:rgba(255,255,255,.08);color:rgba(255,255,255,.4)}
.legacy-notes{background:rgba(255,255,255,.04);border-left:3px solid #444;border-radius:0 8px 8px 0;padding:12px 16px;font-size:.8rem;color:#9fa8da;line-height:1.6;margin-top:12px}
.legacy-meta-grid{display:grid;grid-template-columns:1fr 1fr;gap:8px;margin-bottom:16px}
.legacy-meta-item{background:rgba(255,255,255,.03);border-radius:6px;padding:10px 12px}
.lmi-label{font-size:.6rem;letter-spacing:.1em;text-transform:uppercase;color:rgba(255,255,255,.3);margin-bottom:3px}
.lmi-value{font-size:.8rem;color:#c5cae9}
''')
    html_parts.append('</style>')
    html_parts.append('</head>')
    html_parts.append('<body>')
    html_parts.append('<div class="aurora"></div><div class="grain"></div>')
    html_parts.append('<nav>')
    html_parts.append('  <a class="nav-back" href="index.html">&#8592; Portal Unity R4</a>')
    html_parts.append('  <span class="nav-sep">&middot;</span>')
    html_parts.append('  <span class="nav-title">Habilitadores del Proceso</span>')
    html_parts.append('  <span class="nav-right">BanCoppel &middot; Programa Unity R4 &middot; TDC P4900</span>')
    html_parts.append('</nav>')
    html_parts.append('<div class="layout">')
    html_parts.append('  <div class="sidebar">')
    html_parts.append('    <div class="sb-title">Ecosistema Tecnologico</div>')
    html_parts.append(sidebar_html)
    html_parts.append('  </div>')
    html_parts.append('  <div class="main" id="main">')
    html_parts.append('    <div class="placeholder" id="placeholder">')
    html_parts.append('      <p>Selecciona un sistema del menu lateral</p>')
    html_parts.append('    </div>')
    html_parts.append('    <div class="sys-panel" id="sys-panel"></div>')
    html_parts.append('  </div>')
    html_parts.append('</div>')

    js_block = '''<script>
const SYSTEMS = ''' + sys_json_str + ''';
const SDLC_PHASES = ''' + sdlc_phases_js + ''';
const COV_DOT = {full:'cov-full',partial:'cov-partial',not_covered:'cov-not_covered',not_applicable:'cov-not_applicable',unknown:'cov-unknown'};
const MS_ICON = {done:'&#10003;',pending:'&#9658;',planned:'&#9675;'};
function selectSys(id) {
  document.querySelectorAll('.sb-item').forEach(el => el.classList.toggle('active', el.dataset.sys === id));
  const s = SYSTEMS[id]; if (!s) return;
  document.getElementById('placeholder').style.display = 'none';
  const panel = document.getElementById('sys-panel');
  panel.classList.add('visible');
  const phIdx = SDLC_PHASES.indexOf(s.sdlc_phase);
  const phasesH = SDLC_PHASES.map((ph,i) => {
    const cls = i < phIdx ? 'done' : i === phIdx ? 'current' : 'planned';
    const style = i === phIdx ? 'style="background:'+s.color+';color:#fff;font-weight:700"' : '';
    return '<div class="sdlc-ph '+cls+'" '+style+'>'+ph+'</div>';
  }).join('');
  const barColor = {green:'#4CAF50',yellow:'#FFC107',red:'#FF5252'}[s.sdlc_status]||'#7B9FFF';
  const msH = (s.milestones||[]).map(m =>
    '<div class="ms-row"><div class="ms-icon ms-'+m.status+'">'+(MS_ICON[m.status]||'?')+'</div>'
    +'<div class="ms-label">'+m.label+'</div><div class="ms-date">'+m.date+'</div></div>'
  ).join('');
  const capsH = (s.capabilities_impacted||[]).map(c => {
    const dc = COV_DOT[c.coverage]||'cov-unknown';
    return '<div class="cap-chip"><span class="cap-dot '+dc+'"></span>'+c.name+'</div>';
  }).join('') || '<span class="impact-empty">Sin capabilities mapeadas</span>';
  const stCls = s.togaf_state;
  const stLbl = s.state_label;
  const actCls = s.status==='at_risk'?'chip-at_risk':'chip-active';
  const actLbl = s.status==='at_risk'?'&#9888; En riesgo':'&#9679; Activo';
  panel.innerHTML = '<div class="sys-hdr">'
    +'<div class="sys-abb" style="background:'+s.color+'">'+(s.togaf_abb||s.id.slice(0,3).toUpperCase())+'</div>'
    +'<div class="sys-meta">'
    +'<div class="sys-name">'+s.name+'</div>'
    +'<div class="sys-vendor">'+s.vendor+'</div>'
    +'<div class="sys-chips">'
    +'<span class="chip" style="background:'+s.color+'22;color:'+s.color+'">'+s.togaf_type.toUpperCase()+'</span>'
    +(stLbl ? '<span class="chip chip-'+stCls+'">'+stLbl+'</span>' : '')
    +'<span class="chip '+actCls+'">'+actLbl+'</span>'
    +'</div></div></div>'
    +'<div class="section"><div class="sec-title">Rol en el Programa</div>'
    +'<div class="summary-box">'+s.summary+'</div></div>'
    +'<div class="section"><div class="sec-title">Plan de Entrega &mdash; SDLC</div>'
    +'<div class="sdlc-wrap">'
    +'<div class="sdlc-phases">'+phasesH+'</div>'
    +'<div class="sdlc-bar-wrap">'
    +'<div class="sdlc-bar-bg"><div class="sdlc-bar-fill" style="width:'+s.sdlc_progress+'%;background:'+barColor+'"></div></div>'
    +'<div class="sdlc-pct" style="color:'+barColor+'">'+s.sdlc_progress+'%</div>'
    +'</div></div></div>'
    +'<div class="section"><div class="sec-title">Hitos del Sistema</div>'
    +'<div class="milestones">'+msH+'</div></div>'
    +'<div class="section"><div class="sec-title">Impacto en Vista de Producto &mdash; Capabilities</div>'
    +'<div class="caps-grid">'+capsH+'</div></div>';
}
const LEGACY = ''' + leg_json_str + ''';
const FATE_CLS = {
  'to-replace':'fate-to-replace','to-decommission':'fate-to-decommission',
  'coexists':'fate-coexists','complementary':'fate-complementary',
  'data-source':'fate-data-source','unknown':'fate-unknown'
};
function setView(v) {
  document.getElementById('view-r4').style.display = v==='r4'?'block':'none';
  document.getElementById('view-leg').style.display = v==='legacy'?'block':'none';
  document.getElementById('btn-r4').classList.toggle('active', v==='r4');
  document.getElementById('btn-leg').classList.toggle('active', v==='legacy');
  document.getElementById('placeholder').style.display = 'flex';
  document.getElementById('sys-panel').classList.remove('visible');
  const lp = document.getElementById('legacy-panel');
  if (lp) { lp.style.display='none'; lp.innerHTML=''; }
}
function selectLegacy(id) {
  document.querySelectorAll('.sb-item').forEach(el => el.classList.toggle('active', el.dataset.leg === id));
  const l = LEGACY[id]; if (!l) return;
  document.getElementById('placeholder').style.display = 'none';
  document.getElementById('sys-panel').classList.remove('visible');
  let lp = document.getElementById('legacy-panel');
  if (!lp) { lp = document.createElement('div'); lp.id='legacy-panel'; document.getElementById('main').appendChild(lp); }
  const fc = FATE_CLS[l.fate] || 'fate-unknown';
  lp.innerHTML = '<div class="sys-hdr">'
    + '<div class="legacy-abb">'+l.acronym+'</div>'
    + '<div class="sys-meta">'
    + '<div class="sys-name">'+l.name+'</div>'
    + '<div class="sys-vendor">'+l.provider+'</div>'
    + '<div class="sys-chips">'
    + '<span class="chip" style="background:rgba(158,158,158,.15);color:#9e9e9e">'+l.type.toUpperCase()+'</span>'
    + '<span class="fate-chip '+fc+'">'+l.fate_label+'</span>'
    + '</div></div></div>'
    + '<div class="legacy-meta-grid">'
    + '<div class="legacy-meta-item"><div class="lmi-label">Tipo de sistema</div><div class="lmi-value">'+l.type+'</div></div>'
    + '<div class="legacy-meta-item"><div class="lmi-label">Proveedor</div><div class="lmi-value">'+l.provider+'</div></div>'
    + '<div class="legacy-meta-item"><div class="lmi-label">Destino en R4</div><div class="lmi-value">'+l.fate_label+'</div></div>'
    + '<div class="legacy-meta-item"><div class="lmi-label">ID</div><div class="lmi-value">'+l.id+'</div></div>'
    + '</div>'
    + (l.notes ? '<div class="section"><div class="sec-title">Contexto y Notas</div><div class="legacy-notes">'+l.notes+'</div></div>' : '');
  lp.style.display = 'block';
}
const firstKey = Object.keys(SYSTEMS)[0];
if (firstKey) setTimeout(() => selectSys(firstKey), 100);
</script>'''
    html_parts.append(js_block)
    html_parts.append('</body></html>')

    out_path = out_dir / 'systems-p4900.html'
    out_path.write_text('\n'.join(html_parts), encoding='utf-8')
    print(f'[build-portal] systems-p4900.html generado OK — {len(systems)} sistemas')
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
            '  <a href="plan-director.html">Plan Director</a>\n'
            '  <a href="apolo-itcaps.html">APOLO IT Caps</a>\n'
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

    print(f"[build-portal] OK — {out_path}")
    print(f"  Productos : {len(data['products'])} | Releases: {len(data['releases'])}")
    print(f"  Sistemas  : {len(data['components'])}")
    print(f"  RAG tracks: {len(data['track_rags'])}")
    print(f"  Riesgos   : {len(data['risks'])}")
    print(f"  Hitos     : {len(data['milestones'])}")
    print(f"  Días al Go-Live: {days_to_golive()}")


if __name__ == "__main__":
    main()
