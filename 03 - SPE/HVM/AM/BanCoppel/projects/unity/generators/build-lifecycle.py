"""
generators/build-lifecycle.py
Genera portal/lifecycle-p4900.html canónicamente desde brain.db lifecycle_* tables.
Invocación: cd .../unity && python generators/build-lifecycle.py
Fuente de verdad: digital-brain/brain.db (tablas lifecycle_*)
"""
import sqlite3, json, os, sys
from datetime import date

# ─── Paths ────────────────────────────────────────────────────────────────────
_SCRIPT  = os.path.abspath(__file__)
_GEN_DIR = os.path.dirname(_SCRIPT)
BASE     = os.path.dirname(_GEN_DIR)
DB       = os.path.join(BASE, "digital-brain", "brain.db")
OUT      = os.path.join(BASE, "portal", "lifecycle-p4900.html")
TODAY    = date.today()
GOLIVE   = date(2027, 1, 15)
DAYS     = (GOLIVE - TODAY).days

def q(con, sql, *args):
    return [dict(r) for r in con.execute(sql, args).fetchall()]

# ─── Static domain config ─────────────────────────────────────────────────────

PHASE_ORDER = ["originacion","emision","activacion","autorizacion",
               "transacciones","pagos","contabilidad","cobranza"]

# Metadata canónica por fase (colores y nombres del original)
PHASE_META = {
    "originacion":   {"num":"01","name":"Originación",         "icon":"📝","color":"#9C27B0","light":"rgba(156,39,176,.18)",  "track":"apolo",                         "userStories":22},
    "emision":       {"num":"02","name":"Emisión y maquila",   "icon":"🏭","color":"#00838F","light":"rgba(0,131,143,.18)",    "track":"smartvista",                    "userStories":8},
    "activacion":    {"num":"03","name":"Activación",          "icon":"✅","color":"#1565C0","light":"rgba(21,101,192,.18)",   "track":"app",                           "userStories":2},
    "autorizacion":  {"num":"04","name":"Autorización",        "icon":"🔐","color":"#2E7D32","light":"rgba(46,125,50,.18)",    "track":"smartvista",                    "userStories":1},
    "transacciones": {"num":"05","name":"Transacciones",       "icon":"💳","color":"#0277BD","light":"rgba(2,119,189,.18)",    "track":"smartvista, app, cat, siweb",   "userStories":17},
    "pagos":         {"num":"06","name":"Pagos",               "icon":"💰","color":"#00695C","light":"rgba(0,105,92,.18)",     "track":"smartvista, app",               "userStories":14},
    "contabilidad":  {"num":"07","name":"Contabilidad",        "icon":"📒","color":"#6A1B9A","light":"rgba(106,27,154,.18)",   "track":"smartvista, apificación",       "userStories":None},
    "cobranza":      {"num":"08","name":"Cobranza",            "icon":"📊","color":"#B71C1C","light":"rgba(183,28,28,.18)",    "track":"informix, smartvista",          "userStories":None},
}

# Flujos canónicos por fase (hand-crafted, fuente de verdad visual)
PHASE_FLOWS = {
    "originacion": [
        {"nodes":["Cliente"]},
        {"nodes":["APOLO"],                  "arrow":"solicitud digital"},
        {"nodes":["PLD","Buró","KYC","CES"], "arrow":"validaciones paralelas"},
        {"nodes":["SmartVista"],             "arrow":"alta de cuenta"},
    ],
    "emision": [
        {"nodes":["SVBO"]},
        {"nodes":["OCG"],            "arrow":"archivo de solicitudes aprobadas"},
        {"nodes":["Cargen"],         "arrow":"filtros y layout de maquila"},
        {"nodes":["Connect-Direct"], "arrow":"cifrado PGP", "pending":True},
        {"nodes":["Maquilador"],     "arrow":"archivo de realce"},
    ],
    "activacion": [
        {"nodes":["App Móvil"]},
        {"nodes":["CES"],        "arrow":"verificar identidad"},
        {"nodes":["SmartVista"], "arrow":"activar tarjeta"},
    ],
    "autorizacion": [
        {"nodes":["Comercio"]},
        {"nodes":["E-Global"], "arrow":"ISO 8583 (200)"},
        {"nodes":["SVFE"],     "arrow":"88 reglas"},
        {"nodes":["HSM"],      "arrow":"CVV2 en e-commerce"},
        {"nodes":["E-Global"], "arrow":"respuesta ISO (210)"},
        {"nodes":["Comercio"], "arrow":"aprobación o rechazo"},
    ],
    "transacciones": [
        {"nodes":["App Móvil","SIWEB","CAT/IVR"]},
        {"nodes":["SmartVista"], "arrow":"consulta de movimientos y saldos"},
    ],
    "pagos": [
        {"nodes":["App Móvil","SIWEB"]},
        {"nodes":["SmartVista"], "arrow":"aplicar pago"},
    ],
    "contabilidad": [
        {"nodes":["SVBO"]},
        {"nodes":["SVXP"],    "arrow":"archivo XML contable",        "pending":True},
        {"nodes":["Informix"],"arrow":"la contabilidad permanece en PISA"},
        {"nodes":["SOC"],     "arrow":"nuevo tipo de conciliación",  "pending":True},
    ],
    "cobranza": [
        {"nodes":["SmartVista"]},
        {"nodes":["Informix"],       "arrow":"agingPeriod batch"},
        {"nodes":["Connect-Direct"], "arrow":"archivo cobranza"},
        {"nodes":["CAT/IVR"],        "arrow":"gestión cliente"},
    ],
}

PHASE_DESC = {
    "originacion":   "Solicitud y evaluación crediticia del cliente para la Tarjeta de Crédito.",
    "emision":       "Generación del plástico. SmartVista SVBO arma el lote, OCG genera el archivo de solicitudes aprobadas, Cargen aplica filtros y prepara el layout, se cifra con PGP y Connect-Direct lo deposita en la carpeta del maquilador.",
    "activacion":    "El cliente activa su tarjeta desde la App Móvil validando identidad en tiempo real.",
    "autorizacion":  "Autorización en tiempo real de compras. E-Global entrega el mensaje ISO 8583 a SmartVista BPC, que resuelve con sus 88 reglas y devuelve la respuesta al comercio.",
    "transacciones": "Consulta de movimientos, saldos y estado de cuenta. Los canales consultan a SmartVista BPC, que es el libro de saldos del producto.",
    "pagos":         "Pago de la tarjeta desde App o SIWEB. SPEI sin User Story ni integración documentada en R4.",
    "contabilidad":  "SmartVista SVBO es el libro de registro del crédito. La interfaz SmartVista SVXP transfiere asientos contables a Informix (PISA). Prioridad PreGame pendiente de construcción.",
    "cobranza":      "Gestión de cartera vencida — aging en SmartVista BPC, batch a Informix, gestión via CAT/IVR.",
}

PHASE_NOTES = {
    "originacion": [
        "Conteo verificado: 22 User Stories, todo el track Apolo del inventario. Es el único caso donde una fase equivale a un track completo.",
        "Flujo interno APOLO esquemático — pantallas intermedias de solicitud pendientes de mapeo detallado.",
    ],
    "emision": [
        "Conteo verificado: 8 User Stories de la funcionalidad 'Automatización de Maquila' en el track SmartVista.",
        "BLOQUEANTE: el depósito automático en Connect-Direct no está en producción y hoy se hace manual por tickets.",
        "Cuatro maquiladores según el FSD0107 de BPC: Thales, G+D, TGS (Thomas Greg and Son) y Forza Form. Estrategia acordada: un solo proveedor, pendiente de definir con Negocio.",
        "El HSM Thales payShield 10K asegura PIN y CVV2 en la personalización.",
    ],
    "activacion": [
        "Conteo verificado: 2 User Stories en App para tarjeta digital. Rutas ATM y SIWEB documentadas como Customer Journey (CJ_ATM_01, CJ_OFI_22) pero sin User Story propia en R4.",
        "Provisión de token digital (Apple Pay / Google Pay): no mencionada en R4.",
    ],
    "autorizacion": [
        "Conteo verificado: 1 User Story — 'Reglas del autorizador (88 reglas)'. Única historia que sostiene 88 reglas; cierra análisis el 16-oct-2026.",
        "La autorización es de ida y vuelta: no llega a Temenos Transact ni a Informix. Cita FSD0107 v5.5: 'PISA (CBS) no será responsable de esta actividad'.",
        "CORRECCIÓN: PayTrue NO está en la ruta sincrónica. Se alimenta por archivo en carpeta con ciclos de 3 minutos (SmartVista SVIP a carpeta SV).",
        "CONTRADICCIÓN ABIERTA sobre SmartVista SVFM: PreGame 28-jul dice no licenciado; Plan de Trabajo 12-ago dice binario instalado y conectividad SVFM-SVFE probada.",
        "Las 88 reglas se pueden reordenar pero no ampliar ni recortar.",
        "Dos rutas de entrada según canal: e-Global a SmartVista SVBO para e-commerce; e-Global a GlobalPOSe para POS físico.",
        "Segundo autorizador en paralelo: Interact Switch de Syndein, legado, para POS y ATM de terceros.",
    ],
    "transacciones": [
        "Conteo parcial: 4 User Stories de convivencia App. Las consultas de CAT (4 integraciones) y SIWEB no se cuentan aquí.",
        "CORRECCIÓN: los canales consultan a SmartVista BPC — la flecha va de los canales hacia SmartVista, no al revés.",
        "CAT es el canal con más integraciones de consulta: cuatro.",
        "Inconsistencia en la fuente: IAPP02 e IAPP03 registrados con origen SmartVista y destino App — probable error de captura en el inventario.",
    ],
    "pagos": [],
    "contabilidad": [
        "SIN User Stories propias en el inventario. La fase se materializa en entregables: guía contable formal y definición de tipos de transacción (TRNT) del Producto 4900.",
        "La frontera contable canónica es SmartVista BPC → SmartVista SVXP → Informix (PISA).",
        "Temenos Transact no participa en el ciclo del Producto 4900.",
        "CORRECCIÓN: TRNT no es un sistema — es el tipo de transacción contable de SmartVista BPC.",
        "Para el BIN 42680711 la conciliación en PISA es solo informativa: registra y marca como conciliada sin generar cargo ni abono.",
        "Bloqueador abierto: PP-TRNT-PAGOS reporta definición de TRNTs de Pagos al 0% contra 100% esperado; owner BPC.",
    ],
    "cobranza": [
        "SIN User Stories en el inventario de R4. Cobranza Direccionada es una iniciativa preexistente con 37-50 User Stories en refinamiento, pendiente de incorporar al inventario unificado.",
    ],
}

PHASE_NARRATIVES = {
  "originacion": {
    "industria": "La originación es el primer momento de relación del cliente con el producto. En México, la CONDUSEF exige entregar el Resumen de Contrato con el CAT (Costo Anual Total) calculado conforme a la Circular 9/2019 de Banxico, y el banco debe registrar el contrato de adhesión en el RECA antes de usarlo. El flujo incluye validación KYC, consulta al Buró de Crédito, scoring crediticio (CES) y alta en el sistema de gestión de tarjetas. La LFPIORPI exige que el banco aplique controles PLD desde la solicitud.",
    "kpis": [{"k":"Tasa de aprobación","v":"30-55% (varía por segmento)"},{"k":"Tiempo de resolución digital","v":"< 5 minutos"},{"k":"Activación a 30 días","v":"> 70%"},{"k":"CAT comunicado correctamente","v":"100% (CONDUSEF)"}],
    "brechas": [{"txt":"Pantallas intermedias del flujo de solicitud APOLO sin mapear","level":"warn"},{"txt":"Clientes objetivo (volumen / segmento) sin definir — GAP-VP-001","level":"crit"},{"txt":"Latencia 9 seg en producción — sin plan de mejora confirmado","level":"crit"},{"txt":"Contrato CONDUSEF (RECA): fecha de registro no confirmada","level":"warn"}],
  },
  "emision": {
    "industria": "La emisión convierte una cuenta aprobada en un instrumento de pago. El sistema de gestión de tarjetas arma el lote de personalización, un módulo generador produce el archivo cifrado con PGP y lo transfiere al maquilador vía protocolo seguro (Connect-Direct o SFTP). El HSM (Hardware Security Module) genera y custodia las llaves por tarjeta — control mandatorio PCI-DSS Req. 3.6. El maquilador embosa el plástico, instala el chip y envía la tarjeta al cliente. Tiempo estándar en México: 5-10 días hábiles desde aprobación.",
    "kpis": [{"k":"Aprobación → tarjeta en mano","v":"5-10 días hábiles"},{"k":"Tasa de defectos de maquila","v":"< 0.1%"},{"k":"Activación post-maquila 30d","v":"> 70%"},{"k":"Integridad de lote (PCI-DSS)","v":"100%"}],
    "brechas": [{"txt":"Connect-Direct no en producción — depósito manual por tickets","level":"crit"},{"txt":"Maquilador único no definido formalmente — riesgo de capacidad","level":"warn"},{"txt":"Inconsistencia de maquiladores en documentación (3-5 proveedores)","level":"warn"},{"txt":"SLA de tiempo aprobación→tarjeta en mano: sin definir — GAP-VP-002","level":"warn"}],
  },
  "activacion": {
    "industria": "La CONDUSEF exige que ninguna tarjeta esté activa al momento de entregarse al cliente: el portador debe activarla explícitamente, lo que constituye una segunda confirmación del consentimiento. La industria ofrece cuatro canales: App móvil (preferente en productos digitales), IVR, sucursal y ATM. Para tarjeta digital, la activación incluye la provisión del token de pago en billeteras digitales (Apple Pay / Google Pay) mediante el protocolo EMVCo 3DS del emisor.",
    "kpis": [{"k":"Tasa de activación a 30 días","v":"> 70%"},{"k":"Tasa de activación a 7 días","v":"> 40% (digital-first)"},{"k":"Tiempo al primer uso","v":"< 48 horas"},{"k":"Intentos fallidos","v":"< 5%"}],
    "brechas": [{"txt":"Activación por ATM: Customer Journey documentado pero sin User Story en R4","level":"warn"},{"txt":"Activación por sucursal (SIWEB): Customer Journey documentado pero sin User Story en R4","level":"warn"},{"txt":"Provisión de token digital (Apple Pay / Google Pay): no mencionada en R4","level":"warn"}],
  },
  "autorizacion": {
    "industria": "La autorización ocurre en tiempo real para cada intento de compra. El flujo ISO 8583 lleva el mensaje del POS o e-commerce al emisor vía la red adquirente. El motor de autorización (SmartVista SVFE) aplica las reglas del producto — límite disponible, validez de tarjeta, CVV2, control de fraude — y devuelve aprobación o rechazo en milisegundos. Visa penaliza emisores con alta tasa de declinación injustificada. La CNBV exige reportar eventos de fraude y mantener controles activos de riesgo transaccional.",
    "kpis": [{"k":"Tasa de autorización","v":"> 85% (Visa: > 90% para emisores maduros)"},{"k":"Latencia P99","v":"< 2,000 ms"},{"k":"Tasa de fraude","v":"< 0.05% (benchmark CNBV)"},{"k":"Disponibilidad 24×7","v":"> 99.9%"}],
    "brechas": [{"txt":"Contradicción abierta sobre SmartVista SVFM (módulo fraude): licenciado vs. no licenciado","level":"crit"},{"txt":"SLA de autorización (latencia P99): sin definir en contrato R4 — GAP-VP-002","level":"warn"},{"txt":"3DS v2 para e-commerce: sin evidencia de implementación en R4","level":"warn"},{"txt":"Segunda User Story de cierre de análisis: 16-oct — overlap con inicio SIT 15-oct","level":"warn"}],
  },
  "transacciones": {
    "industria": "Esta fase cubre toda la operación del portador sobre el producto activo: consultas de saldo, movimientos y estado de cuenta. La CONDUSEF exige estado de cuenta gratuito en formato regulatorio, con al menos 45 días entre fecha de corte y fecha límite de pago. Los emisores deben habilitar al menos App, IVR y sucursal. Las compras diferidas (MSI/MCI — Meses Sin/Con Intereses) son reguladas: el estado de cuenta debe mostrar el desglose de parcializaciones activas, el cargo mensual y el saldo pendiente.",
    "kpis": [{"k":"Adopción canal digital","v":"> 60% portadores con consulta digital/mes"},{"k":"Latencia consulta P95","v":"< 2 segundos"},{"k":"Entrega estado de cuenta a tiempo","v":"100% (CONDUSEF)"},{"k":"Reclamaciones por estado de cuenta","v":"< 0.1% de cuentas"}],
    "brechas": [{"txt":"Estado de cuenta formato CONDUSEF: sin evidencia de validación en R4","level":"warn"},{"txt":"MSI/MCI en estado de cuenta digital: sin User Story específica confirmada","level":"warn"},{"txt":"Consulta via ATM: no en scope R4","level":"warn"}],
  },
  "pagos": {
    "industria": "El pago es la fase de mayor impacto en la relación cliente-banco y la principal causa de reclamaciones CONDUSEF si falla. El regulador exige al menos dos mecanismos de pago sin costo, fecha límite ≥ 45 días después del corte, y que el pago mínimo esté claramente definido. Los canales estándar en México incluyen: SPEI, ventanilla de sucursal, domiciliación / cargo automático, CoDi, tiendas de conveniencia y banca en línea. La acreditación del pago debe reflejarse en el saldo disponible en minutos (SPEI).",
    "kpis": [{"k":"Tasa de pago a tiempo","v":"> 80%"},{"k":"Acreditación SPEI","v":"< 5 minutos"},{"k":"Portadores con domiciliación","v":"> 20%"},{"k":"Reclamaciones CONDUSEF por pagos","v":"< 0.05% de cuentas"}],
    "brechas": [{"txt":"Pago en ventanilla: bloqueado por dependencia de SIWEB — sin alternativa confirmada","level":"crit"},{"txt":"Domiciliación / cargo automático: sin User Story en R4","level":"warn"},{"txt":"Pago CoDi: sin cobertura en R4 (canal Banxico en crecimiento)","level":"warn"},{"txt":"SLA de acreditación SPEI: sin definir en R4 — GAP-VP-002","level":"warn"}],
  },
  "contabilidad": {
    "industria": "La contabilidad y conciliación es invisible para el cliente pero crítica para el regulador. La CNBV — vía la Circular Única de Bancos, Anexos 33 y 36 — exige que cada transacción del portador quede registrada en el libro contable central (core bancario) el mismo día. El posting diario genera los asientos contables en el procesador de tarjetas (SmartVista BPC), que se transfieren al core vía archivo SmartVista SVXP. La conciliación garantiza que el total de transacciones autorizadas coincida con los movimientos contabilizados. La NIF C-16 exige estimar y registrar mensualmente la provisión por pérdida esperada sobre la cartera.",
    "kpis": [{"k":"Conciliación D+0","v":"> 99.5%"},{"k":"Breaks sin resolver > 24h","v":"0 (objetivo CNBV)"},{"k":"Latencia de posting","v":"< 4 horas post-cierre"},{"k":"Compliance reportería CNBV","v":"100% — multas automáticas"}],
    "brechas": [{"txt":"Interfaz SmartVista SVXP→Informix (PISA) no construida — prioridad PreGame pendiente","level":"crit"},{"txt":"Guía contable formal (TRNTs del Producto 4900) no entregada","level":"crit"},{"txt":"Nuevo tipo conciliación SOC (req. 16-nov-2023): sin plan en R4","level":"warn"},{"txt":"Provisión NIF C-16: sin evidencia de diseño en R4","level":"warn"}],
  },
  "cobranza": {
    "industria": "La cobranza cierra el ciclo de crédito y determina la salud de la cartera. La CONDUSEF prohíbe llamadas fuera de 8am-9pm y exige ofrecer reestructura antes de reportar al Buró. La CNBV requiere reportar cartera vencida al SISEC mensualmente y registrar la provisión contable (NIF C-16). La gestión opera en cuatro capas de aging: preventiva (1-29 días), temprana (30-60), cartera vencida (61-120) y litigio/castigo (> 120 días). El reporte al Buró se activa al día 30 de atraso.",
    "kpis": [{"k":"NPL ratio (cartera vencida > 90d)","v":"< 4% (TDC masiva)"},{"k":"Recuperación temprana","v":"> 60% en < 30 días de contacto"},{"k":"Contactabilidad digital","v":"> 40%"},{"k":"Reclamaciones CONDUSEF cobranza","v":"Tolerancia cero"}],
    "brechas": [{"txt":"37-50 User Stories de Cobranza Direccionada no incorporadas al inventario R4","level":"crit"},{"txt":"Pentest nov 15-20 congela el único ambiente SIT de Cobranza","level":"crit"},{"txt":"Reporte al Buró de Crédito (SISEC): sin evidencia de diseño en R4","level":"warn"},{"txt":"Proceso de reestructura de deuda: sin alcance en R4 (CONDUSEF lo exige)","level":"warn"}],
  },
}

# User Story queries per phase: list of (node_label, sql)
PHASE_STORY_QUERIES = {
    "originacion": [
        ("APOLO", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='apolo' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "emision": [
        ("SmartVista BPC", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='smartvista' AND (lower(funcionalidad) LIKE '%maquila%' OR lower(funcionalidad) LIKE '%abasto%' OR lower(funcionalidad) LIKE '%lote%') ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "activacion": [
        ("App Móvil", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track IN ('app','smartvista') AND lower(funcionalidad) LIKE '%activac%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "autorizacion": [
        ("SmartVista SVFE", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='smartvista' AND lower(funcionalidad) LIKE '%autorizador%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "transacciones": [
        ("App Móvil", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='app' AND lower(funcionalidad) NOT LIKE '%pago%' AND lower(funcionalidad) NOT LIKE '%activac%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
        ("CAT/IVR",   "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='cat' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
        ("SIWEB",     "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='siweb' AND lower(funcionalidad) LIKE '%saldo a favor%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "pagos": [
        ("SmartVista BPC", "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='smartvista' AND (lower(funcionalidad) LIKE '%pago%' OR lower(funcionalidad) LIKE '%saldo a favor%' OR lower(funcionalidad) LIKE '%liquidar%') ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
        ("App Móvil",      "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='app' AND lower(funcionalidad) LIKE '%pago%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
        ("SIWEB",          "SELECT id,title,moscow,complejidad FROM user_stories_inventory WHERE track='siweb' AND lower(funcionalidad) NOT LIKE '%saldo a favor%' ORDER BY CASE moscow WHEN 'must' THEN 1 WHEN 'should' THEN 2 WHEN 'could' THEN 3 ELSE 4 END,id"),
    ],
    "contabilidad": [],
    "cobranza":     [],
}

# ─── Brain queries ─────────────────────────────────────────────────────────────

def _build_phases_from_constants():
    result = []
    for pid in PHASE_ORDER:
        m = PHASE_META[pid]
        result.append({
            "id":          pid,
            "num":         m["num"],
            "name":        m["name"],
            "icon":        m["icon"],
            "color":       m["color"],
            "light":       m["light"],
            "desc":        PHASE_DESC.get(pid, ""),
            "userStories": m["userStories"],
            "track":       m["track"],
            "coverage":    "completa",
            "steps":       PHASE_FLOWS[pid],
            "notes":       PHASE_NOTES.get(pid, []),
        })
    return result


def build_phases(con=None):
    """Lee fases de brain.db lifecycle_phases + flow_nodes + flow_arrows.
    Fallback a constantes Python si las tablas están vacías.
    """
    import json as _json
    if con is None:
        return _build_phases_from_constants()

    rows = q(con, "SELECT * FROM lifecycle_phases ORDER BY num")
    if not rows:
        return _build_phases_from_constants()

    result = []
    for p in rows:
        pid = p["phase_id"]
        node_rows  = q(con, "SELECT * FROM lifecycle_flow_nodes  WHERE phase_id=? ORDER BY step_order, id", pid)
        arrow_rows = q(con, "SELECT * FROM lifecycle_flow_arrows WHERE phase_id=? ORDER BY step_order", pid)

        # Agrupar nodos por step_order
        steps_nodes = {}
        for n in node_rows:
            steps_nodes.setdefault(n["step_order"], []).append(n["node_name"])

        # Flechas indexadas por step_order
        steps_arrows = {a["step_order"]: a for a in arrow_rows}

        steps = []
        for so in sorted(steps_nodes.keys()):
            step = {"nodes": steps_nodes[so]}
            if so in steps_arrows:
                step["arrow"] = steps_arrows[so]["label"]
                if steps_arrows[so]["pending"]:
                    step["pending"] = True
            steps.append(step)

        result.append({
            "id":          pid,
            "num":         p["num"],
            "name":        p["name"],
            "icon":        p["icon"] or "",
            "color":       p["color"] or "#3D5FCD",
            "light":       "",
            "desc":        p["description"] or "",
            "userStories": p["us_count"],
            "track":       p["track"] or "",
            "coverage":    p["coverage"] or "completa",
            "steps":       steps,
            "notes":       _json.loads(p["notes"]) if p.get("notes") else [],
        })
    return result


def build_narratives(con=None):
    """Lee narrativas de brain.db lifecycle_phases. Fallback a PHASE_NARRATIVES."""
    import json as _json
    if con is not None:
        rows = q(con, "SELECT * FROM lifecycle_phases ORDER BY num")
        if rows:
            result = {}
            for p in rows:
                pid  = p["phase_id"]
                narr = {}
                if p.get("narrative_industry"):
                    narr["industria"] = p["narrative_industry"]
                if p.get("narrative_kpis"):
                    narr["kpis"] = _json.loads(p["narrative_kpis"])
                if p.get("narrative_brechas"):
                    narr["brechas"] = _json.loads(p["narrative_brechas"])
                if narr:
                    result[pid] = narr
            if result:
                return result
    return PHASE_NARRATIVES


def build_phase_steps(con):
    result = {}
    for pid in PHASE_ORDER:
        rows = q(con, "SELECT * FROM lifecycle_steps WHERE phase_id=? ORDER BY step_n", pid)
        if not rows:
            # fallback to legacy table
            rows = q(con, "SELECT step_n, paso AS description, sistema, us_id, us_title, NULL AS protocol, 0 AS gap_flag, NULL AS gap_notes FROM lifecycle_phase_steps WHERE phase_id=? ORDER BY step_n", pid)
        if not rows:
            continue
        steps = []
        for r in rows:
            desc = (r.get("description") or r.get("paso") or "")[:110]
            if len(r.get("description") or r.get("paso") or "") > 110:
                desc += "…"
            step = {
                "n":     r["step_n"],
                "paso":  desc,
                "sis":   (r["sistema"] or "")[:60],
                "us":    r["us_id"] if r["us_id"] else None,
                "ust":   (r["us_title"] or "")[:80] if r["us_title"] else None,
            }
            if r["protocol"]:
                step["proto"] = r["protocol"][:50]
            if r["gap_flag"]:
                step["gap"] = True
            steps.append(step)
        result[pid] = steps
    return result


def build_phase_stories(con):
    result = {}
    for pid, queries in PHASE_STORY_QUERIES.items():
        if not queries:
            continue
        groups = []
        for (node_label, sql) in queries:
            try:
                rows = q(con, sql)
            except Exception:
                rows = []
            if not rows:
                continue
            items = [{"id": r["id"], "t": r["title"], "m": r["moscow"] or "could", "c": r["complejidad"] or "Media"} for r in rows]
            groups.append({"node": node_label, "items": items})
        if groups:
            result[pid] = groups
    return result


def build_test_cases(con):
    result = {}
    for pid in PHASE_ORDER:
        rows = q(con, "SELECT * FROM lifecycle_test_cases WHERE phase_id=? ORDER BY tc_id", pid)
        if rows:
            result[pid] = [{
                "tc_id":   r["tc_id"] or "",
                "tc_title":r["tc_title"] or "",
                "test_type": r["test_type"] or "",
                "priority": r["priority"] or "",
                "expected_result": (r["expected_result"] or "")[:140],
                "linked_us": r["linked_us_id"] or "",
            } for r in rows]
    return result


def build_integ_gaps(con):
    result = {}
    for pid in PHASE_ORDER:
        rows = q(con, "SELECT * FROM lifecycle_integrations WHERE phase_id=? AND gap_flag=1 ORDER BY id", pid)
        if rows:
            result[pid] = [{
                "ref":      r["integration_ref"] or "",
                "from_sys": r["from_system"] or "",
                "to_sys":   r["to_system"] or "",
                "api":      r["api_name"] or "",
                "proto":    r["protocol"] or "",
                "notes":    (r["gap_notes"] or "")[:160],
            } for r in rows]
    return result


def build_stats(con):
    us_cnt   = con.execute("SELECT COUNT(*) FROM user_stories_inventory").fetchone()[0]
    must_cnt = con.execute("SELECT COUNT(*) FROM user_stories_inventory WHERE moscow='must'").fetchone()[0]
    int_cnt  = con.execute("SELECT COUNT(*) FROM r4_integrations").fetchone()[0] if \
               con.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='r4_integrations'").fetchone() else 18
    return {"days": DAYS, "us": us_cnt, "must": must_cnt, "int": int_cnt}

# ─── HTML Template ─────────────────────────────────────────────────────────────
# Sentinels: __DAYS__, __US__, __MUST__, __INT__, __TODAY__
# JSON sentinels (unquoted):  __PHASE_NARRATIVES__  __PHASE_STEPS__  __PHASES__
#                             __PHASE_STORIES__  __PHASE_TEST_CASES__  __PHASE_INTEG_GAPS__

HTML_TEMPLATE = r"""<!DOCTYPE html>
<!-- Unity R4 · Cadena de Valor TDC · BanCoppel
     SPE-AM-001 · generado por generators/build-lifecycle.py · __TODAY__ -->
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Cadena de Valor — Tarjeta de Crédito — Unity R4</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:#3D5FCD;--blued:#122FB1;--yellow:#F0D224;
  --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10);
  --red:#E8400A;--green:#22c55e;--text:#e8edff}
html{scroll-behavior:smooth}
body{background:#060a1a;color:var(--ink);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;min-height:100vh}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden}
.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(27,63,208,.55),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:50vw;height:50vw;right:-10vw;top:10vw;border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(13,33,133,.65),transparent 70%);animation:f2 28s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.12)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.10)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
#prog{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;
  background:linear-gradient(90deg,var(--yellow),#fff);box-shadow:0 0 12px rgba(240,210,36,.6)}
nav{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:13px 28px;
  backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);
  background:rgba(6,10,26,.55);border-bottom:1px solid rgba(255,255,255,.06)}
nav img{height:18px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}
nav .nt{font-size:12px;font-weight:600;color:var(--muted)}
nav .sp{flex:1}
nav a{font-size:12px;color:var(--muted);padding:5px 12px;border-radius:20px;transition:.2s;text-decoration:none}
nav a:hover{color:var(--ink);background:rgba(255,255,255,.07)}
nav a.hl{color:var(--yellow)}
.wrap{max-width:1240px;margin:0 auto;padding:0 28px}
.hero{padding:100px 0 36px}
.eyebrow{display:inline-flex;align-items:center;gap:8px;padding:7px 14px;border-radius:30px;font-size:11px;font-weight:700;
  letter-spacing:.05em;color:#dfe6ff;margin-bottom:20px;background:rgba(255,255,255,.05);
  border:1px solid var(--glassb);backdrop-filter:blur(10px)}
.eyebrow .dot{width:6px;height:6px;border-radius:50%;background:var(--yellow);
  box-shadow:0 0 10px var(--yellow);animation:pulse 2.4s infinite}
@keyframes pulse{50%{opacity:.35}}
h1{font-size:clamp(32px,4.5vw,58px);font-weight:800;line-height:1.05;letter-spacing:-.03em;
  background:linear-gradient(175deg,#fff 30%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.sub{font-size:15px;color:var(--muted);margin-top:14px;max-width:70ch;line-height:1.6}
.sub b{color:#e4eaff;font-weight:600}
.stats{display:flex;gap:12px;margin-top:28px;flex-wrap:wrap}
.stat{padding:14px 20px;border-radius:16px;background:var(--glass);border:1px solid var(--glassb);
  backdrop-filter:blur(16px);display:flex;flex-direction:column;gap:4px;min-width:130px}
.stn{font-size:22px;font-weight:800;letter-spacing:-.02em;
  background:linear-gradient(180deg,#fff,#c4d0ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.stl{font-size:10px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}
.stat.warn{border-color:rgba(240,210,36,.35);background:rgba(240,210,36,.06)}.stat.warn .stn{background:linear-gradient(180deg,var(--yellow),#e0b800);-webkit-background-clip:text;background-clip:text}
.stepper-wrap{margin-top:44px;margin-bottom:0}
.stepper{display:flex;gap:0;position:relative;overflow-x:auto;padding-bottom:4px}
.stepper::after{display:none}
.ptab{
  display:flex;flex-direction:column;align-items:center;justify-content:center;gap:5px;
  padding:14px 40px 14px 20px;
  cursor:pointer;border:none;
  background:rgb(18,30,68);
  color:var(--muted);position:relative;flex:1;min-width:118px;
  transition:background .22s,color .22s;
  font-family:inherit;white-space:nowrap;
  clip-path:polygon(0 0,calc(100% - 24px) 0,100% 50%,calc(100% - 24px) 100%,0 100%,24px 50%);
  margin-right:-24px;
  filter:drop-shadow(3px 0 5px rgba(0,0,0,.7))}
.ptab:first-child{
  clip-path:polygon(0 0,calc(100% - 24px) 0,100% 50%,calc(100% - 24px) 100%,0 100%);
  padding-left:22px}
.ptab:last-child{
  clip-path:polygon(0 0,100% 0,100% 100%,0 100%,24px 50%);
  margin-right:0;padding-right:22px}
.ptab::after{display:none}
.ptab:hover{background:rgb(28,44,100);color:var(--ink)}
.ptab.active{color:#fff;filter:drop-shadow(3px 0 5px rgba(0,0,0,.7)) drop-shadow(0 0 10px rgba(61,95,205,.35))}
.ptab .pnum{font-size:9px;font-weight:700;letter-spacing:.12em;opacity:.5;text-transform:uppercase}
.ptab .pname{font-size:12px;font-weight:700;letter-spacing:-.01em}
.ptab .pus{font-size:9.5px;font-weight:600;padding:2px 7px;border-radius:8px;
  background:rgba(0,0,0,.30);border:1px solid rgba(255,255,255,.10)}
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

.phase-content{margin-top:2px;padding:28px 0 28px}
.pmeta{display:flex;flex-wrap:wrap;align-items:center;gap:6px 20px;
  padding:14px 20px;margin-bottom:20px;
  background:var(--glass);border:1px solid var(--glassb);border-radius:14px;
  backdrop-filter:blur(18px)}
.pmeta-title{font-size:9px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;
  color:var(--muted2);white-space:nowrap}
.pmeta-phase{font-size:18px;font-weight:800;letter-spacing:-.02em;margin-right:4px}
.pmeta-desc{font-size:12px;color:var(--muted);line-height:1.4;flex:1 1 300px}
.pmeta-row{display:flex;align-items:center;gap:6px;white-space:nowrap}
.pmeta-label{font-size:9px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2)}
.pmeta-val{font-size:11.5px;font-weight:600}
.pmeta-sep{width:1px;height:18px;background:rgba(255,255,255,.10);align-self:center}
.cov-badge{display:inline-flex;align-items:center;font-size:9px;font-weight:700;
  padding:3px 9px;border-radius:10px;letter-spacing:.05em}
.cov-full{background:rgba(34,197,94,.12);color:#86efac;border:1px solid rgba(34,197,94,.25)}
.cov-part{background:rgba(240,210,36,.10);color:var(--yellow);border:1px solid rgba(240,210,36,.28)}
.note-box{background:rgba(240,210,36,.06);border:1px solid rgba(240,210,36,.20);border-radius:10px;padding:10px 12px}
.note-box p{font-size:11.5px;color:rgba(240,210,36,.75);line-height:1.5}
.note-box p::before{content:"\26A0 ";font-size:11px}
.flow-wrap{background:var(--glass);border:1px solid var(--glassb);border-radius:20px;
  padding:32px 28px;backdrop-filter:blur(18px);overflow-x:auto;min-height:160px}
.flow{display:flex;align-items:center;gap:0;min-width:min-content;padding:4px 0}
.fstep{display:flex;flex-direction:column;align-items:center;gap:8px}
.fnodes{display:flex;flex-direction:column;gap:10px;align-items:center}
.farrow{display:flex;flex-direction:column;align-items:center;min-width:80px;flex-shrink:0;gap:5px}
.farrow svg{width:100%;overflow:visible}
.farrow-lbl{font-size:9px;font-weight:600;color:var(--muted2);text-align:center;
  letter-spacing:.02em;padding:0 4px;max-width:90px;line-height:1.35}
.farrow-lbl.pend{color:rgba(240,210,36,.85)}
.farrow-lbl.pend::after{content:" — por definir";display:block;color:rgba(240,210,36,.5);font-weight:500}
.snode{padding:11px 18px;border-radius:13px;font-size:12px;font-weight:700;white-space:nowrap;
  border:1px solid transparent;cursor:default;
  transition:transform .2s,box-shadow .2s,filter .2s;
  position:relative;overflow:hidden}
.snode::before{content:"";position:absolute;top:0;left:0;right:0;height:1px;
  background:rgba(255,255,255,.18);pointer-events:none}
.snode:hover{transform:translateY(-3px);filter:brightness(1.12)}
.sn-external{background:linear-gradient(145deg,rgba(55,71,79,.65),rgba(84,110,122,.40));
  border-color:rgba(144,164,174,.35);color:#CFD8DC;
  box-shadow:0 4px 18px rgba(0,0,0,.35),inset 0 1px 0 rgba(207,216,220,.08)}
.sn-channel{background:linear-gradient(145deg,rgba(26,35,126,.65),rgba(61,95,205,.40));
  border-color:rgba(61,95,205,.55);color:#90CAF9;
  box-shadow:0 4px 18px rgba(26,35,126,.5),inset 0 1px 0 rgba(144,202,249,.10)}
.sn-processor{background:linear-gradient(145deg,rgba(27,94,32,.65),rgba(56,142,60,.40));
  border-color:rgba(76,175,80,.50);color:#A5D6A7;
  box-shadow:0 4px 18px rgba(27,94,32,.5),inset 0 1px 0 rgba(165,214,167,.10)}
.sn-core{background:linear-gradient(145deg,rgba(13,33,133,.75),rgba(21,101,192,.45));
  border-color:rgba(25,118,210,.55);color:#82B1FF;
  box-shadow:0 4px 20px rgba(13,33,133,.55),inset 0 1px 0 rgba(130,177,255,.12)}
.sn-compliance{background:linear-gradient(145deg,rgba(136,14,79,.55),rgba(183,28,28,.35));
  border-color:rgba(239,83,80,.40);color:#FFAB91;
  box-shadow:0 4px 18px rgba(136,14,79,.45),inset 0 1px 0 rgba(255,171,145,.08)}
.sn-integration{background:linear-gradient(145deg,rgba(74,20,140,.60),rgba(106,27,154,.35));
  border-color:rgba(149,117,205,.50);color:#CE93D8;
  box-shadow:0 4px 18px rgba(74,20,140,.5),inset 0 1px 0 rgba(206,147,216,.10)}
.us-block{margin-top:26px;padding-top:20px;border-top:1px solid rgba(255,255,255,.10)}
.us-head{font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:14px;display:flex;align-items:center;gap:8px}
.us-count{font-size:9px;font-weight:700;padding:2px 7px;border-radius:9px;letter-spacing:0;
  background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);color:var(--ink)}
.us-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(280px,1fr));gap:16px}
.us-col{display:flex;flex-direction:column;gap:5px}
.us-node{font-size:10.5px;font-weight:700;padding:5px 10px;border-radius:8px;margin-bottom:3px;
  background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.14)}
.us-item{display:flex;align-items:baseline;gap:7px;padding:4px 2px;font-size:11px;line-height:1.45}
.us-id{font-family:'SF Mono',ui-monospace,monospace;font-size:9.5px;color:var(--muted2);
  flex-shrink:0;min-width:96px}
.us-t{color:var(--muted);flex:1}
.us-m{font-size:8px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;
  padding:1px 5px;border-radius:7px;flex-shrink:0}
.m-must{background:rgba(239,68,68,.15);color:#fca5a5}
.m-should{background:rgba(240,210,36,.12);color:var(--yellow)}
.m-could{background:rgba(61,95,205,.20);color:#90CAF9}
.m-wont{background:rgba(255,255,255,.07);color:var(--muted2);text-decoration:line-through}
.notes-toggle{display:flex;align-items:center;gap:8px;margin-top:28px;padding:10px 16px;
  width:100%;text-align:left;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);
  border-radius:10px;cursor:pointer;font-family:inherit;color:var(--muted);font-size:11px;
  font-weight:700;letter-spacing:.06em;text-transform:uppercase;transition:background .2s}
.notes-toggle:hover{background:rgba(255,255,255,.07);color:var(--ink)}
.notes-toggle .nt-arrow{font-size:10px;transition:transform .25s;margin-left:auto}
.notes-toggle.open .nt-arrow{transform:rotate(180deg)}
.notes-body{display:none;margin-top:8px;display:flex;flex-direction:column;gap:8px}
.notes-body.open{display:flex}
.flow-title{font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);margin-bottom:20px}
/* Tabla paso a paso — compacta */
.ps-wrap{margin-top:22px;padding-top:16px;border-top:1px solid rgba(255,255,255,.07)}
.ps-title{font-size:9px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;color:var(--muted2);margin-bottom:10px}
.ps-table{width:100%;border-collapse:collapse;font-size:12px}
.ps-table thead tr{border-bottom:1px solid rgba(255,255,255,.08)}
.ps-table th{text-align:left;padding:5px 8px;color:var(--muted2);font-size:9px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;white-space:nowrap}
.ps-table td{padding:7px 8px;border-bottom:1px solid rgba(255,255,255,.04);vertical-align:middle;line-height:1.35}
.ps-table tr:last-child td{border-bottom:none}
.ps-n{color:var(--muted2);font-size:10px;font-variant-numeric:tabular-nums;width:24px;text-align:right;padding-right:10px!important}
.ps-paso{color:var(--text);max-width:340px}
.ps-gap-ic{color:var(--yellow);font-size:10px;margin-right:3px;cursor:help}
.ps-sis{white-space:nowrap}
.ps-sis-badge{display:inline-block;font-size:10px;font-weight:600;padding:2px 8px;border-radius:6px;background:rgba(61,95,205,.18);border:1px solid rgba(61,95,205,.35);color:#90CAF9}
.ps-proto{display:inline-block;font-family:'SF Mono',ui-monospace,monospace;font-size:8.5px;padding:1px 5px;border-radius:4px;background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.09);color:var(--muted2);margin-top:3px}
.ps-us{white-space:nowrap}
.ps-us-id{font-family:'SF Mono',ui-monospace,monospace;font-size:9.5px;font-weight:600;padding:2px 7px;border-radius:5px;background:rgba(100,180,255,.12);border:1px solid rgba(100,180,255,.25);color:#7bb3f0;cursor:default}
.ps-us-none{color:var(--muted2);font-size:11px}
/* Test cases panel */
.tc-block{margin-top:24px;padding-top:18px;border-top:1px solid rgba(255,255,255,.08)}
.tc-head,.ig-head{font-size:10px;font-weight:700;letter-spacing:.12em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:12px;display:flex;align-items:center;gap:8px}
.tc-count{font-size:9px;font-weight:700;padding:2px 7px;border-radius:9px;
  background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.14);color:var(--ink)}
.tc-list{display:grid;grid-template-columns:repeat(auto-fill,minmax(300px,1fr));gap:10px}
.tc-item{background:rgba(255,255,255,.03);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:12px 14px;display:flex;flex-direction:column;gap:5px}
.tc-row1{display:flex;align-items:center;gap:6px;flex-wrap:wrap}
.tc-id{font-family:'SF Mono',ui-monospace,monospace;font-size:9px;color:var(--muted2)}
.tc-type-badge,.tc-prio-badge{font-size:8px;font-weight:700;text-transform:uppercase;letter-spacing:.05em;padding:2px 6px;border-radius:6px}
.tc-type-badge{background:rgba(61,95,205,.20);color:#90CAF9}
.tc-prio-high{background:rgba(239,68,68,.15);color:#fca5a5}
.tc-prio-med{background:rgba(240,210,36,.12);color:var(--yellow)}
.tc-prio-low{background:rgba(255,255,255,.07);color:var(--muted2)}
.tc-title{font-size:11.5px;color:var(--ink);line-height:1.4}
.tc-exp{font-size:10.5px;color:var(--muted);line-height:1.35}
/* Integration gaps panel */
.ig-block{margin-top:16px}
.ig-list{display:flex;flex-direction:column;gap:8px}
.ig-item{background:rgba(232,64,10,.06);border:1px solid rgba(232,64,10,.20);border-radius:10px;padding:10px 14px}
.ig-row1{display:flex;align-items:center;gap:8px;margin-bottom:4px}
.ig-flow{font-size:11.5px;font-weight:600;color:#ff9e7b}
.ig-proto{font-size:9px;font-weight:700;text-transform:uppercase;padding:2px 6px;border-radius:5px;
  background:rgba(255,158,123,.15);color:#ff9e7b}
.ig-api{font-size:11px;color:var(--muted);font-style:italic}
.ig-notes{font-size:10.5px;color:rgba(255,158,123,.75);line-height:1.4;margin-top:4px}
footer{padding:36px 0 52px;text-align:center;color:var(--muted2);font-size:12px;
  border-top:1px solid rgba(255,255,255,.05);line-height:1.8}
footer code{color:var(--muted);background:rgba(240,210,36,.09);border:1px solid rgba(240,210,36,.22);
  border-radius:4px;padding:1px 6px;font-size:11px;font-family:'SF Mono',ui-monospace,monospace}
</style></head>
<body>
<div class="aurora"></div>
<div class="grain"></div>
<div id="prog"></div>
<nav>
  <img src="../../../design-studio/logos/BanCoppel_logo.png" alt="BanCoppel" onerror="this.style.display='none'">
  <span class="nt">Unity R4 — Cadena de Valor</span>
  <span class="sp"></span>
  <a class="jump hl" href="index.html">← Plan Director</a>
</nav>
<div class="wrap">
  <div class="hero">
    <div class="eyebrow"><span class="dot"></span>&nbsp; Tarjeta de Crédito · Unity R4</div>
    <h1>Cadena de Valor<br>Tarjeta de Crédito</h1>
    <p class="sub">Flujo de vida completo de la <b>Tarjeta de Crédito</b> —
      desde la originación hasta la cobranza.</p>
    <div class="stats">
      <div class="stat warn"><div class="stn">__DAYS__</div><div class="stl">Días al Go-Live · 15 Ene 2027</div></div>
      <div class="stat"><div class="stn">8</div><div class="stl">Fases del lifecycle</div></div>
      <div class="stat"><div class="stn">__US__ · __MUST__ Must</div><div class="stl">User Stories</div></div>
      <div class="stat"><div class="stn">__INT__</div><div class="stl">Integraciones R4</div></div>
    </div>
  </div>
  <div class="stepper-wrap">
    <div class="stepper" id="stepper"></div>
  </div>
  <div class="phase-content">
    <div class="pmeta" id="pmeta"></div>
    <div class="flow-wrap" id="flow-wrap"></div>
    <div id="phase-notes"></div>
  </div>
</div>
<footer>
  <code>Unity R4 — Tarjeta de Crédito</code> — BanCoppel — Accenture México<br>
  Generado por <code>generators/build-lifecycle.py</code> · __TODAY__
</footer>
<script>
window.addEventListener('scroll',()=>{
  const p=(window.scrollY/(document.body.scrollHeight-window.innerHeight))*100;
  document.getElementById('prog').style.width=p+'%';
});

function escHtml(s){
  return String(s||'').replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');
}

const SYS = {
  'Cliente':         {type:'external',   label:'Cliente'},
  'Comercio':        {type:'external',   label:'Comercio / Terminal'},
  'App Móvil':       {type:'channel',    label:'App Móvil'},
  'SIWEB':           {type:'channel',    label:'SIWEB'},
  'APOLO':           {type:'channel',    label:'APOLO'},
  'CAT/IVR':         {type:'channel',    label:'CAT / IVR'},
  'SmartVista':      {type:'processor',  label:'SmartVista BPC'},
  'SmartVista BPC':  {type:'processor',  label:'SmartVista BPC'},
  'E-Global':        {type:'processor',  label:'E-Global'},
  'Cargen':          {type:'processor',  label:'SmartVista SVCG (Cargen)'},
  'OCG':             {type:'processor',  label:'OCG'},
  'Maquilador':      {type:'external',   label:'Maquilador'},
  'Informix':        {type:'core',       label:'Informix (PISA)'},
  'SVBO':            {type:'processor',  label:'SmartVista SVBO'},
  'SVFE':            {type:'processor',  label:'SmartVista SVFE'},
  'SVXP':            {type:'integration',label:'SmartVista SVXP'},
  'SOC':             {type:'core',       label:'SOC (Sistema Operativo Central)'},
  'HSM':             {type:'compliance', label:'HSM Thales payShield'},
  'PLD':             {type:'compliance', label:'PLD / Minds'},
  'Buró':            {type:'compliance', label:'Buró de Crédito'},
  'KYC':             {type:'compliance', label:'KYC'},
  'CES':             {type:'compliance', label:'CES (Score)'},
  'PayTrue':         {type:'compliance', label:'PayTrue (Fraude)'},
  'Transact':        {type:'integration',label:'Temenos Transact'},
  'SPEI':            {type:'integration',label:'SPEI / Banxico'},
  'Connect-Direct':  {type:'integration',label:'Connect-Direct'},
};

const PHASE_NARRATIVES = __PHASE_NARRATIVES__;
const PHASE_STEPS      = __PHASE_STEPS__;
const PHASES           = __PHASES__;
const PHASE_STORIES    = __PHASE_STORIES__;
const PHASE_TEST_CASES = __PHASE_TEST_CASES__;
const PHASE_INTEG_GAPS = __PHASE_INTEG_GAPS__;

/* ── Render stepper ── */
const stepper = document.getElementById('stepper');
PHASES.forEach((p,i)=>{
  const btn = document.createElement('button');
  btn.className = 'ptab';
  btn.id = 'ptab-'+p.id;
  btn.style.zIndex = PHASES.length - i;
  const usLabel = p.userStories ? `${p.userStories} USs` : 'routing';
  btn.innerHTML = `<span class="pnum">${p.num}</span><span class="pname">${p.name}</span><span class="pus">${usLabel}</span>`;
  btn.onclick = ()=>activate(p.id);
  stepper.appendChild(btn);
});

/* ── Render phase ── */
function activate(id){
  const p = PHASES.find(x=>x.id===id);
  if(!p) return;

  document.querySelectorAll('.ptab').forEach(t=>t.classList.remove('active'));
  const activeTab = document.getElementById('ptab-'+id);
  activeTab.classList.add('active');

  let st = document.getElementById('tab-style');
  if(!st){st=document.createElement('style');st.id='tab-style';document.head.appendChild(st);}
  st.textContent=`#ptab-${id}{background:${p.color}33!important;color:${p.color}!important;filter:drop-shadow(3px 0 5px rgba(0,0,0,.7)) drop-shadow(0 0 12px ${p.color}55)!important}#ptab-${id} .pus{background:${p.color}25!important;border-color:${p.color}66!important}`;

  const narr    = PHASE_NARRATIVES[id];
  const meta    = document.getElementById('pmeta');
  const covClass = p.coverage==='completa' ? 'cov-full' : 'cov-part';
  const covLabel = p.coverage==='completa' ? 'OK Cobertura completa' : '⚠ Cobertura parcial';
  meta.innerHTML = `
    <div class="pmeta-title">Fase ${p.num}/8</div>
    <div class="pmeta-phase" style="color:${p.color}">${escHtml(p.name)}</div>
    <div class="pmeta-sep"></div>
    <div class="pmeta-desc">${escHtml(p.desc)}</div>
    <div class="pmeta-sep"></div>
    <div class="pmeta-row"><span class="pmeta-label">User Stories&nbsp;</span><span class="pmeta-val">${p.userStories ?? '—'}</span></div>
    <div class="pmeta-row"><span class="pmeta-label">Track&nbsp;</span><span class="pmeta-val">${escHtml(p.track)}</span></div>
    <div class="pmeta-sep"></div>
    <span class="cov-badge ${covClass}">${covLabel}</span>
  `;

  const fw = document.getElementById('flow-wrap');
  fw.style.borderColor = p.color + '55';

  let html = `<div class="flow-title">Flujo de sistemas — ${escHtml(p.name)}</div><div class="flow">`;
  p.steps.forEach((step,si)=>{
    if(si>0){
      const pend   = step.pending ? ' pend' : '';
      const stroke = step.pending ? 'rgba(240,210,36,.70)' : p.color+'bb';
      const fill   = step.pending ? 'rgba(240,210,36,.80)' : p.color+'dd';
      const dash   = step.pending ? 'stroke-dasharray="6 4"' : '';
      const ahId   = 'ah'+p.id+si;
      html += `<div class="farrow">
        <svg viewBox="0 0 90 14" preserveAspectRatio="none" style="height:14px" aria-hidden="true">
          <defs><marker id="${ahId}" markerWidth="6" markerHeight="6" refX="5" refY="3" orient="auto">
            <polyline points="0,0.5 5,3 0,5.5" fill="none" stroke="${fill}" stroke-width="1.6" stroke-linejoin="round"/>
          </marker></defs>
          <line x1="2" y1="7" x2="82" y2="7" stroke="${stroke}" stroke-width="1.5" ${dash} marker-end="url(#${ahId})"/>
        </svg>
        <div class="farrow-lbl${pend}">${escHtml(step.arrow||'')}</div>
      </div>`;
    }
    html += `<div class="fstep"><div class="fnodes">`;
    step.nodes.forEach(n=>{
      const sys = SYS[n]||{type:'external',label:n};
      html += `<div class="snode sn-${sys.type}" title="${escHtml(sys.label)}">${escHtml(sys.label)}</div>`;
    });
    html += `</div></div>`;
  });
  html += `</div>`;

  /* User Stories de la fase */
  const groups = PHASE_STORIES[p.id];
  if(groups && groups.length){
    const total = groups.reduce((a,g)=>a+g.items.length,0);
    html += `<div class="us-block"><div class="us-head">User Stories de la fase <span class="us-count">${total}</span></div><div class="us-grid">`;
    groups.forEach(g=>{
      html += `<div class="us-col"><div class="us-node" style="border-color:${p.color}66">${escHtml(g.node)}</div>`;
      g.items.forEach(it=>{
        html += `<div class="us-item"><span class="us-id">${escHtml(it.id)}</span><span class="us-t">${escHtml(it.t)}</span><span class="us-m m-${it.m}">${it.m}</span></div>`;
      });
      html += `</div>`;
    });
    html += `</div></div>`;
  }
  fw.innerHTML = html;

  /* Narrativa funcional */
  if(narr){
    const _kHtml = narr.kpis.map(r=>`<div class="ph-narr-kpi-row"><span class="ph-narr-kpi-k">${escHtml(r.k)}</span><span class="ph-narr-kpi-v">${escHtml(r.v)}</span></div>`).join('');
    const _bHtml = narr.brechas.map(b=>`<div class="ph-narr-brecha"><span class="ph-narr-brecha-dot ${b.level}"></span><span class="ph-narr-brecha-txt">${escHtml(b.txt)}</span></div>`).join('');
    const _nd = document.createElement('div');
    _nd.innerHTML = `<div class="ph-narr"><div class="ph-narr-eyebrow">Proceso de industria · Marco regulatorio MX</div><p class="ph-narr-industry">${escHtml(narr.industria)}</p><div class="ph-narr-cols"><div class="ph-narr-block"><div class="ph-narr-block-title">KPIs de referencia</div>${_kHtml}</div><div class="ph-narr-block"><div class="ph-narr-block-title">Brechas identificadas en R4</div>${_bHtml}</div></div></div>`;
    const _us = fw.querySelector('.us-block');
    if(_us) fw.insertBefore(_nd.firstElementChild, _us);
    else fw.appendChild(_nd.firstElementChild);
  }

  /* Tabla paso a paso con User Story */
  const psteps = PHASE_STEPS[id];
  if(psteps && psteps.length){
    let rows = psteps.map(s=>{
      const gap = s.gap ? `<span class="ps-gap-ic" title="Brecha detectada">⚠</span>` : '';
      const proto = s.proto ? `<span class="ps-proto">${escHtml(s.proto)}</span>` : '';
      const usMark = s.us
        ? `<span class="ps-us-id" title="${escHtml(s.ust||'')}">${escHtml(s.us)}</span>`
        : `<span class="ps-us-none">—</span>`;
      return `<tr>
        <td class="ps-n">${s.n}</td>
        <td class="ps-paso">${gap}${escHtml(s.paso)}</td>
        <td class="ps-sis"><span class="ps-sis-badge">${escHtml(s.sis)}</span>${proto?'<br>'+proto:''}</td>
        <td class="ps-us">${usMark}</td>
      </tr>`;
    }).join('');
    const psEl = document.createElement('div');
    psEl.innerHTML = `<div class="ps-wrap"><div class="ps-title">Paso a paso · User Story R4</div><table class="ps-table"><thead><tr><th>#</th><th>Paso</th><th>Sistema</th><th>User Story</th></tr></thead><tbody>${rows}</tbody></table></div>`;
    const _usPs = fw.querySelector('.us-block');
    if(_usPs) fw.insertBefore(psEl.firstElementChild, _usPs);
    else fw.appendChild(psEl.firstElementChild);
  }

  /* Test cases (desde lifecycle_test_cases) */
  const ptcData = PHASE_TEST_CASES[id];
  if(ptcData && ptcData.length){
    let tcHtml = `<div class="tc-block"><div class="tc-head">Casos de Prueba (Swarm) <span class="tc-count">${ptcData.length}</span></div><div class="tc-list">`;
    ptcData.forEach(tc=>{
      const prio = (tc.priority||'').toLowerCase();
      const prioClass = (prio==='alta'||prio==='high') ? 'tc-prio-high' : (prio==='baja'||prio==='low') ? 'tc-prio-low' : 'tc-prio-med';
      tcHtml += `<div class="tc-item"><div class="tc-row1"><span class="tc-id">${escHtml(tc.tc_id)}</span>${tc.test_type?`<span class="tc-type-badge">${escHtml(tc.test_type)}</span>`:''} ${tc.priority?`<span class="tc-prio-badge ${prioClass}">${escHtml(tc.priority)}</span>`:''}</div><div class="tc-title">${escHtml(tc.tc_title)}</div>${tc.expected_result?`<div class="tc-exp">→ ${escHtml(tc.expected_result)}</div>`:''}</div>`;
    });
    tcHtml += '</div></div>';
    fw.insertAdjacentHTML('beforeend', tcHtml);
  }

  /* Integration gaps (desde lifecycle_integrations WHERE gap_flag=1) */
  const integGaps = PHASE_INTEG_GAPS[id];
  if(integGaps && integGaps.length){
    let igHtml = `<div class="ig-block"><div class="ig-head">Brechas de Integración <span class="tc-count">${integGaps.length}</span></div><div class="ig-list">`;
    integGaps.forEach(g=>{
      igHtml += `<div class="ig-item"><div class="ig-row1"><span class="ig-flow">${escHtml(g.from_sys)} → ${escHtml(g.to_sys)}</span>${g.proto?`<span class="ig-proto">${escHtml(g.proto)}</span>`:''}</div>${g.api?`<div class="ig-api">${escHtml(g.api)}</div>`:''} ${g.notes?`<div class="ig-notes">${escHtml(g.notes)}</div>`:''}</div>`;
    });
    igHtml += '</div></div>';
    fw.insertAdjacentHTML('beforeend', igHtml);
  }

  /* Notes accordion */
  const noteEl = document.getElementById('phase-notes');
  if(noteEl){
    const notes = p.notes||[];
    if(notes.length){
      const bodyId = 'notes-body-'+p.id;
      noteEl.innerHTML = `<button class="notes-toggle" onclick="this.classList.toggle('open');document.getElementById('${bodyId}').classList.toggle('open')"><span>Notas técnicas de validación</span><span class="nt-arrow">▾</span></button><div class="notes-body" id="${bodyId}">${notes.map(n=>`<div class="note-box"><p>${escHtml(n)}</p></div>`).join('')}</div>`;
    } else {
      noteEl.innerHTML = '';
    }
  }
}

activate('originacion');
</script>
</body></html>"""

# ─── Main ─────────────────────────────────────────────────────────────────────

def main():
    if not os.path.exists(DB):
        print(f"ERROR: brain.db no encontrado en {DB}", file=sys.stderr)
        sys.exit(1)

    con = sqlite3.connect(DB)
    con.row_factory = sqlite3.Row

    print("Leyendo brain.db...")
    phases     = build_phases(con)
    narratives = build_narratives(con)
    psteps     = build_phase_steps(con)
    pstories   = build_phase_stories(con)
    ptc        = build_test_cases(con)
    pinteg     = build_integ_gaps(con)
    stats      = build_stats(con)
    con.close()

    def js(obj):
        return json.dumps(obj, ensure_ascii=False, indent=None, separators=(",", ":"))

    html = HTML_TEMPLATE
    html = html.replace("__DAYS__",    str(stats["days"]))
    html = html.replace("__US__",      str(stats["us"]))
    html = html.replace("__MUST__",    str(stats["must"]))
    html = html.replace("__INT__",     str(stats["int"]))
    html = html.replace("__TODAY__",   TODAY.strftime("%Y-%m-%d"))
    html = html.replace("__PHASE_NARRATIVES__",  js(narratives))
    html = html.replace("__PHASE_STEPS__",       js(psteps))
    html = html.replace("__PHASES__",            js(phases))
    html = html.replace("__PHASE_STORIES__",     js(pstories))
    html = html.replace("__PHASE_TEST_CASES__",  js(ptc))
    html = html.replace("__PHASE_INTEG_GAPS__",  js(pinteg))

    os.makedirs(os.path.dirname(OUT), exist_ok=True)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(html)

    total_tc  = sum(len(v) for v in ptc.values())
    total_ig  = sum(len(v) for v in pinteg.values())
    total_us  = sum(len(g["items"]) for glist in pstories.values() for g in glist)
    print(f"OK Generado: {OUT}")
    print(f"  {len(phases)} fases · {total_us} User Stories")
    print(f"  {total_tc} test cases · {total_ig} integration gaps")
    print(f"  Stats: {stats['days']} días al Go-Live · {stats['us']} USs · {stats['int']} integraciones")

if __name__ == "__main__":
    main()