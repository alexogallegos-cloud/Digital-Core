#!/usr/bin/env python3
"""
build-sap-modular.py
Diagrama modular SAP ECC LIV — estilo Estructura Modular R/3.
Módulos confirmados del análisis de código fuente (12 programas ABAP ZIM).
Genera portal/sap-modular.html

Ejecutar desde liverpool-brain/:
    python generators/build-sap-modular.py
"""
from pathlib import Path
from datetime import datetime

BRAIN_DIR = Path(__file__).parent.parent
OUTPUT    = BRAIN_DIR / "portal" / "sap-modular.html"

# ── Geometría ──────────────────────────────────────────────────────────────────
W, H   = 1500, 1000
CX, CY = 750, 500   # centro del diagrama

# ── Liverpool brand palette ─────────────────────────────────────────────────
LIV_DARK     = "#07070d"   # fondo principal
LIV_NAVY     = "#0d0e1a"   # superficies
LIV_GOLD     = "#C9A130"   # brand gold primario
LIV_GOLD_L   = "#E8C84A"   # gold claro
LIV_GOLD_DIM = "#6B550F"   # gold oscuro/muted
LIV_BORDER   = "#1C1810"   # borde cálido oscuro
LIV_TEXT     = "#EDE5D0"   # texto primario (cálido blanco)
LIV_TEXT_DIM = "#7A6E58"   # texto secundario

def dmd(cx, cy, hw, hh):
    """Puntos SVG de un diamante centrado en (cx, cy)."""
    return f"{cx},{cy-hh} {cx+hw},{cy} {cx},{cy+hh} {cx-hw},{cy}"

# ── Módulos SAP confirmados (posición hexagonal alrededor del centro) ──────────
# Seis módulos a ~185 px del centro en disposición hexagonal
M_HW, M_HH = 84, 68   # half-width / half-height del diamante de módulo

MODS = [
    # id    cod      nombre                 tablas clave              cx   cy     fill       stroke     tcolor
    ("MM",  "MM",   "Materials\nManagement","EKKO·EKPO·MARA·MARC",   750, 300, "#062010", "#22c55e", "#4ade80"),
    ("FI",  "FI",   "Financial\nAccounting","BKPF·BSEG·BSIK·BSAK",  940, 395, "#1e0e02", "#f59e0b", "#fcd34d"),
    ("LE",  "LE",   "Logistics\nExecution", "LIKP·LIPS·ZOIM·WF30",   940, 585, "#051e14", "#10b981", "#34d399"),
    ("SD",  "SD",   "Sales &\nPricing",     "KONV·Incoterms",         750, 680, "#04101e", "#38bdf8", "#87C3D3"),
    ("HCM", "HCM",  "Human Capital\nMgmt",  "SAP HCM·Nómina",        560, 585, "#1e0414", "#E00198", "#f472b6"),
    ("CO",  "CO/BW","Controlling &\nAnalytics","BW LIV·BW PDM·BW4",  560, 395, "#0e0624", "#8b5cf6", "#c4b5fd"),
]

# Sub-módulos / detalle que aparece en tooltip (data-tip)
MOD_DETAIL = {
    "MM":  "MM-PUR (Compras) | MM-MAT (Materiales) | Grupos de compra | Tipos IM/IP/TIM/TIP",
    "FI":  "FI-GL (General Ledger) | FI-AP (Cuentas por Pagar) | Multi-sociedad: LIV·SBB·Sfera",
    "LE":  "LE-SHP (Entregas parciales) | Tipo ZOIM | Pool WF30 | Centros CDT",
    "SD":  "Condiciones de precio (Pricing) | Incoterms por grupo compra | KONV",
    "HCM": "Recursos Humanos | Nómina Liverpool | Administración personal",
    "CO":  "Controlling (CO) | BW LIV (on-prem) | BW PDM | BW4 SBB (Azure)",
}

# ── Sistemas externos (integraciones) ─────────────────────────────────────────
# 8 posiciones en anillo exterior
EW, EH = 148, 46    # ancho/alto caja externa

SKY = "#87C3D3"   # color para integraciones confirmadas en Dashboard AS-IS

EXTS = [
    # ── Confirmados en código fuente ZIM (gold) ──────────────────────────────
    # id          nombre               detalle                      cx    cy     color
    ("SAT",     "SAT / Aduana",    "Pedimentos 16 dígitos",        750,   45, "#C9A130"),
    ("S4",      "SAP S/4HANA SBB", "Azure Cloud (Suburbia)",      1345,  200, "#C9A130"),
    ("POS",     "POS / Bridgecore","Tiendas Liverpool",            1345,  400, "#C9A130"),
    ("BWEXT",   "SAP BW",          "DWH / Analytics",             1345,  820, "#C9A130"),
    ("IIB",     "IBM IIB",         "Bus Corporativo (15+ sist.)",  750,  955, "#C9A130"),
    ("PROV",    "Proveedores Intl","Portal pre-embarque",           155,  800, "#C9A130"),
    ("EM",      "Event Manager",   "ZIM_EMLG (log EM SAP)",         155,  500, "#C9A130"),
    ("PMR",     "PMR / PDM",       "Datos Maestros SAP",            155,  200, "#C9A130"),
    # ── Confirmados en Dashboard AS-IS (sky) ─────────────────────────────────
    ("PIMSTEP", "PIM / STEP",      "Maestro materiales ↔ SAP",    490,   45,  SKY),
    ("OMS",     "Sterling OMS",    "Órdenes → EWM fulfillment",  1010,   45,  SKY),
    ("ATG",     "ATG / Endeca",    "Precios y disponibilidad",   1345,  610,  SKY),
    ("ORACLE",  "Oracle PL-SQL",   "Size Scaling (MARA/MARC)",   1010,  955,  SKY),
    ("TUMBLEWEED","Tumbleweed",    "MFT Pagos → Bancos/SAT",      490,  955,  SKY),
]

# ── Conexiones (de/hacia módulos y externos) ──────────────────────────────────
# (from, to, etiqueta, color, dashed)
CONNS = [
    # ── Confirmados en código fuente ZIM (gold) ──
    ("SAT",       "MM",  "ZIMPOB010B\nPedimentos",          "#C9A130", True),
    ("S4",        "FI",  "RFC / IDOC\nReplicación",          "#C9A130", False),
    ("POS",       "LE",  "ZRT_PO_REP_EPI_BD\n● oct-2025",   "#C9A130", True),
    ("BWEXT",     "CO",  "BW Extractors",                   "#C9A130", False),
    ("IIB",       "SD",  "Bus SAP↔POS\n↔SAT",               "#C9A130", True),
    ("PROV",      "MM",  "ZIMFIC001\nPortal proveedor",      "#C9A130", True),
    ("EM",        "MM",  "Eventos ZIM\nZIMPOC001/002/003",   "#C9A130", True),
    ("PMR",       "CO",  "Maestros IDOC",                   "#C9A130", False),
    # ── Confirmados en Dashboard AS-IS (sky) ──
    ("PIMSTEP",   "MM",  "MARA/MAKT\nSync",                  SKY, False),
    ("OMS",       "LE",  "Órdenes EWM\nFulfillment",         SKY, True),
    ("ATG",       "SD",  "Precios\nDisponibilidad",           SKY, True),
    ("ORACLE",    "MM",  "MARA/MARC\nSize Scaling",           SKY, False),
    ("TUMBLEWEED","FI",  "MFT Pagos\nBancos·SAT",            SKY, True),
]

# ── Helpers de posición ────────────────────────────────────────────────────────
def mod_center(mid):
    for m in MODS:
        if m[0] == mid:
            return m[4], m[5]   # cx, cy
    return None

def ext_center(eid):
    for e in EXTS:
        if e[0] == eid:
            return e[3], e[4]   # cx, cy  (tuple: id,name,detail,cx,cy,color)
    return None

def midpoint_label(x1, y1, x2, y2, offset=12):
    mx = (x1 + x2) / 2
    my = (y1 + y2) / 2
    # Perpendicular offset
    dx, dy = x2 - x1, y2 - y1
    length = (dx**2 + dy**2) ** 0.5
    if length == 0:
        return mx, my
    nx, ny = -dy / length, dx / length
    return mx + nx * offset, my + ny * offset

# ── SVG arrows marker ─────────────────────────────────────────────────────────
ARROW_DEFS = f"""
<defs>
  <marker id="arr-gold" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="{LIV_GOLD}"/>
  </marker>
  <marker id="arr-sky" markerWidth="8" markerHeight="8" refX="6" refY="3" orient="auto">
    <path d="M0,0 L0,6 L8,3 z" fill="#87C3D3"/>
  </marker>
  <linearGradient id="grad-center" x1="0%" y1="0%" x2="100%" y2="100%">
    <stop offset="0%" stop-color="#0d0f20"/>
    <stop offset="100%" stop-color="#070810"/>
  </linearGradient>
  <filter id="glow-gold">
    <feGaussianBlur stdDeviation="4" result="blur"/>
    <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
  </filter>
</defs>
"""

def color_arrow(color):
    return "arr-sky" if color == SKY else "arr-gold"

# ── Vendor badges: (label, bg_color) para cada sistema externo ───────────────
EXT_BADGES = {
    "SAT":        ("SAT",  "#006847"),   # México verde oscuro
    "S4":         ("S/4",  "#1B77C8"),   # SAP azul
    "POS":        ("POS",  "#E00198"),   # Liverpool cerise
    "BWEXT":      ("BW",   "#1B77C8"),   # SAP azul
    "IIB":        ("IIB",  "#1F70C1"),   # IBM azul
    "PROV":       ("PRV",  "#C9A130"),   # Gold
    "EM":         ("EM",   "#1B77C8"),   # SAP azul (Event Manager)
    "PMR":        ("PMR",  "#5A5040"),   # Gris cálido
    "PIMSTEP":    ("PIM",  "#00875A"),   # Stibo verde
    "OMS":        ("OMS",  "#1F70C1"),   # IBM azul (Sterling)
    "ATG":        ("ATG",  "#C74634"),   # Oracle rojo
    "ORACLE":     ("ORA",  "#C74634"),   # Oracle rojo
    "TUMBLEWEED": ("MFT",  "#8B1A1A"),   # Broadcom rojo oscuro
}

# ── Vendor SVG logos (SimpleIcons path data via jsDelivr) ─────────────────────
_SAP_PATH = (
    "M0 6.064v11.872h12.13L24 6.064zm3.264 2.208h.005c.863.001 1.915.245 2.676.633l-.82 1.43"
    "c-.835-.404-1.255-.442-1.73-.467-.708-.038-1.064.215-1.069.488-.007.332.669.633 1.305.838"
    ".964.306 2.19.715 2.377 1.9L7.77 8.437h2.046l2.064 5.576-.007-5.575h2.37c2.257 0 3.318"
    ".764 3.318 2.519 0 1.575-1.09 2.514-2.936 2.514h-.763l-.01 2.094-3.588-.003-.25-.908c"
    "-.37.122-.787.189-1.23.189-.456 0-.885-.071-1.263-.2l-.358.919-2 .006.09-.462c-.029.025"
    "-.057.05-.087.074-.535.43-1.208.629-2.037.644l-.213.002a5.075 5.075 0 0 1-2.581-.675l"
    ".73-1.448c.79.467 1.286.572 1.956.558.347-.007.598-.07.761-.239a.557.557 0 0 0 .156-.369"
    "c.007-.376-.53-.553-1.185-.756-.531-.164-1.135-.389-1.606-.735-.559-.41-.825-.924-.812"
    "-1.65a1.99 1.99 0 0 1 .566-1.377c.519-.537 1.357-.863 2.363-.863zm10.597 1.67v1.904h.521"
    "c.694 0 1.247-.23 1.248-.964 0-.709-.554-.94-1.248-.94zm-5.087.767l-.748 2.362c.223.085"
    ".481.133.757.133.268 0 .52-.047.742-.126l-.736-2.37z"
)
_IBM_PATH = (
    "M16.21 8.13l-.216-.624h-3.56v.624zm.413 1.19l-.216-.623h-3.973v.624zm2.65 7.147h3.107v"
    "-.624h-3.108zm0-1.192h3.107v-.623h-3.108zm0-1.19h1.864v-.624h-1.865zm0-1.191h1.864v"
    "-.624h-1.865zm0-1.191h1.864v-.624h-3.555l-.175.504-.175-.504h-3.555v.624h1.865v-.574l"
    ".2.574h3.33l.2-.574zm1.864-1.815h-3.142l-.217.624h3.359zm-7.46 3.006h1.865v-.624h-1.865"
    "zm0 1.19h1.865v-.623h-1.865zm-1.243 1.191h3.108v-.623h-3.108zm0 1.192h3.108v-.624h-3.108"
    "zm6.386-8.961l-.216.624h3.776v-.624zm-.629 1.815h4.19v-.624h-3.974zm-4.514 1.19h3.359l"
    "-.216-.623h-3.143zm2.482 2.383h2.496l.218-.624h-2.932zm.417 1.19h1.662l.218-.623h-2.098"
    "zm.416 1.191h.83l.218-.623h-1.266zm.414 1.192l.217-.624h-.432zm-12.433-.006l4.578.006c"
    ".622 0 1.18-.237 1.602-.624h-6.18zm4.86-3v.624h2.092c0-.216-.03-.425-.083-.624zm-3.616"
    ".624h1.865v-.624H6.217zm3.617-3.573h2.008c.053-.199.083-.408.083-.624H9.834zm-3.617 0h"
    "1.865v-.624H6.217zM9.55 7.507H4.973v.624h6.18a2.36 2.36 0 00-1.602-.624zm2.056 1.191H4"
    ".973v.624h6.884a2.382 2.382 0 00-.25-.624zm-5.39 2.382v.624h4.87c.207-.176.382-.387.519"
    "-.624zm4.87 1.191h-4.87v.624h5.389a2.39 2.39 0 00-.519-.624zm-6.114 3.006h6.634c.11-.193"
    ".196-.402.25-.624H4.973zM0 8.13h4.352v-.624H0zm0 1.191h4.352v-.624H0zm1.243 1.191h1.865"
    "v-.624H1.243zm0 1.191h1.865v-.624H1.243zm0 1.19h1.865v-.623H1.243zm0 1.192h1.865v-.624"
    "H1.243zM0 15.276h4.352v-.623H0zm0 1.192h4.352v-.624H0Z"
)
_ORACLE_PATH = (
    "M16.412 4.412h-8.82a7.588 7.588 0 0 0-.008 15.176h8.828a7.588 7.588 0 0 0 0-15.176zm"
    "-.193 12.502H7.786a4.915 4.915 0 0 1 0-9.828h8.433a4.914 4.914 0 1 1 0 9.828z"
)
_BROADCOM_PATH = (
    "M12 0c6.628 0 12 5.372 12 12a12 12 0 0 1-.56 3.63 13.641 13.641 0 0 0-.867-.388c-1.372"
    "-.546-2.629-.363-3.888.4 0 0-.459.28-.597.366-.586.37-1.14.717-1.672.717-.508 0-1.007"
    "-.135-1.218-1.117-.33-1.533-1.135-5.298-1.486-7.162-.206-1.097-.319-1.688-.436-2.088"
    "-.208-.706-.586-1.09-1.124-1.15 0 0-.084-.013-.152-.013-.068 0-.162.014-.162.014-.531"
    ".064-.907.447-1.114 1.15-.117.4-.23.99-.436 2.087-.351 1.864-1.156 5.63-1.486 7.162"
    "-.21.982-.71 1.117-1.218 1.117-.531 0-1.086-.348-1.672-.717-.138-.086-.597-.366-.597"
    "-.366-1.259-.763-2.516-.946-3.888-.4-.301.12-.586.251-.867.387A11.995 11.995 0 0 1 0"
    " 12C0 5.372 5.372 0 12 0m8.375 16.976c-.453.152-.855.42-1.256.672-.756.475-1.613 1.014"
    "-2.704 1.014-1.614 0-2.749-.964-3.112-2.647C13.023 14.712 12 9.793 12 9.793a496.28"
    " 496.28 0 0 1-1.303 6.222c-.362 1.683-1.497 2.647-3.112 2.647-1.09 0-1.946-.539-2.703"
    "-1.014-.401-.252-.804-.52-1.256-.672a2.319 2.319 0 0 0-1.414-.01c-.33.097-.644.234-.951"
    ".386C3.227 21.292 7.207 24 11.91 24s8.863-2.708 10.83-6.648a5.958 5.958 0 0 0-.95-.386"
    " 2.322 2.322 0 0 0-1.415.01"
)

VENDOR_LOGOS = {
    "sap":      (_SAP_PATH,      "#FFFFFF", "#1B77C8"),
    "ibm":      (_IBM_PATH,      "#FFFFFF", "#1F70C1"),
    "oracle":   (_ORACLE_PATH,   "#FFFFFF", "#C74634"),
    "broadcom": (_BROADCOM_PATH, "#FFFFFF", "#CC0000"),
}

EXT_LOGO_MAP = {
    "S4":         "sap",
    "BWEXT":      "sap",
    "EM":         "sap",
    "PMR":        "sap",
    "IIB":        "ibm",
    "OMS":        "ibm",
    "ATG":        "oracle",
    "ORACLE":     "oracle",
    "TUMBLEWEED": "broadcom",
}

# ── Generación SVG ────────────────────────────────────────────────────────────
def build_svg():
    parts = []
    parts.append(f'<svg id="sap-diagram" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 {W} {H}" width="{W}" height="{H}" style="cursor:default">')
    parts.append(ARROW_DEFS)

    # Background
    parts.append(f'<rect width="{W}" height="{H}" fill="{LIV_DARK}" rx="12"/>')

    # Rejilla diagonal isométrica
    grid_color = "#100E08"
    step = 60
    for i in range(0, W + H, step):
        parts.append(f'<line x1="{i}" y1="0" x2="0" y2="{i}" stroke="{grid_color}" stroke-width="0.6"/>')
        parts.append(f'<line x1="{i}" y1="{H}" x2="{W}" y2="{i-H}" stroke="{grid_color}" stroke-width="0.6"/>')

    # Borde decorativo
    parts.append(f'<rect x="6" y="6" width="{W-12}" height="{H-12}" fill="none" stroke="{LIV_GOLD}" stroke-width="0.6" rx="10" opacity="0.35"/>')

    # ── PASO 1: Líneas de conexión (dibujadas primero = bajo los módulos) ──────
    # Opacity baja por defecto; JS la sube al seleccionar
    for frm, to, label, color, dashed in CONNS:
        x1, y1 = ext_center(frm) or (0, 0)
        x2, y2 = mod_center(to) or (0, 0)
        dash = 'stroke-dasharray="6,3"' if dashed else ""
        parts.append(
            f'<line class="conn" data-from="{frm}" data-to="{to}" '
            f'x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" '
            f'stroke="{color}" stroke-width="1.5" opacity="0.38" {dash} '
            f'marker-end="url(#{color_arrow(color)})"/>'
        )

    # ── ZIM overlay ──────────────────────────────────────────────────────────
    zim_hw, zim_hh = 155, 155
    parts.append(
        f'<polygon points="{dmd(CX, CY, zim_hw, zim_hh)}" '
        f'fill="rgba(201,161,48,0.04)" stroke="{LIV_GOLD}" stroke-width="1.5" stroke-dasharray="10,5"/>'
    )
    parts.append(
        f'<text x="{CX + 62}" y="{CY - zim_hh + 20}" font-size="9" fill="{LIV_GOLD}" '
        f'font-family="Consolas,monospace" font-weight="bold">Z — Módulo Importaciones</text>'
    )
    parts.append(
        f'<text x="{CX + 62}" y="{CY - zim_hh + 34}" font-size="8" fill="{LIV_GOLD_DIM}" '
        f'font-family="Consolas,monospace">213 tablas Z · 33 FM propios</text>'
    )

    # ── SAP ECC Center diamond ────────────────────────────────────────────────
    ecc_hw, ecc_hh = 130, 130
    parts.append(
        f'<polygon points="{dmd(CX, CY, ecc_hw, ecc_hh)}" '
        f'fill="url(#grad-center)" stroke="{LIV_GOLD}" stroke-width="2.5" filter="url(#glow-gold)"/>'
    )
    parts.append(
        f'<polygon points="{dmd(CX, CY, 115, 115)}" '
        f'fill="none" stroke="{LIV_GOLD}" stroke-width="0.5" opacity="0.3"/>'
    )
    parts.append(f'<text x="{CX}" y="{CY - 48}" text-anchor="middle" font-size="9" fill="{LIV_GOLD_DIM}" font-family="Consolas,monospace" letter-spacing="3">SAP ECC 6.0</text>')
    # Logo Liverpool centrado en el diamante
    _liv_w, _liv_h = 90, 32
    parts.append(
        f'<image href="Liverpool_logo.png" '
        f'x="{CX - _liv_w//2}" y="{CY - 38}" '
        f'width="{_liv_w}" height="{_liv_h}" preserveAspectRatio="xMidYMid meet"/>'
    )
    parts.append(f'<text x="{CX}" y="{CY + 8}" text-anchor="middle" font-size="11" fill="{LIV_GOLD}" font-family="Segoe UI,sans-serif">ERP Core (LIV)</text>')
    parts.append(f'<text x="{CX}" y="{CY + 26}" text-anchor="middle" font-size="9" fill="{LIV_TEXT_DIM}" font-family="Segoe UI,sans-serif">On-Premise</text>')
    parts.append(f'<text x="{CX}" y="{CY + 48}" text-anchor="middle" font-size="8" fill="{LIV_GOLD_DIM}" font-family="Consolas,monospace">LIV · SBB · Sfera (150)</text>')

    # ── PASO 2: Módulos SAP con <g> para interactividad ──────────────────────
    for mid, cod, name, tables, cx, cy, fill, stroke, tcolor in MODS:
        parts.append(f'<g class="mod-node" data-mod="{mid}" style="cursor:pointer">')
        parts.append(f'<polygon points="{dmd(cx, cy, M_HW, M_HH)}" fill="{fill}" stroke="{stroke}" stroke-width="1.5"/>')
        parts.append(f'<text x="{cx}" y="{cy - 8}" text-anchor="middle" font-size="13" font-weight="bold" fill="{stroke}" font-family="Segoe UI,sans-serif">{cod}</text>')
        for k, ln in enumerate(name.split("\n")):
            parts.append(f'<text x="{cx}" y="{cy + 10 + k*13}" text-anchor="middle" font-size="9" fill="{tcolor}" font-family="Segoe UI,sans-serif">{ln}</text>')
        parts.append(f'<text x="{cx}" y="{cy + M_HH + 16}" text-anchor="middle" font-size="7.5" fill="{stroke}" opacity="0.7" font-family="Consolas,monospace">{tables}</text>')
        parts.append('</g>')

    # ── PASO 3: Cajas externas con badge de vendor y <g> interactivo ─────────
    for eid, name, detail, cx, cy, color in EXTS:
        ex, ey = cx - EW // 2, cy - EH // 2
        is_sky = (color == SKY)
        dash_attr = 'stroke-dasharray="6,3"' if is_sky else ""
        badge_lbl, badge_col = EXT_BADGES.get(eid, ("?", "#555"))
        vec_key = EXT_LOGO_MAP.get(eid) if EXT_LOGO_MAP.get(eid) in VENDOR_LOGOS else None
        bw = 22 if vec_key else max(len(badge_lbl) * 5 + 10, 22)
        name_cx = ex + 4 + bw + 4 + (EW - 4 - bw - 8) // 2

        parts.append(f'<g class="ext-sys" data-sys="{eid}" style="cursor:pointer">')
        # Caja principal
        parts.append(f'<rect x="{ex}" y="{ey}" width="{EW}" height="{EH}" rx="4" fill="{LIV_NAVY}" stroke="{color}" stroke-width="1.2" {dash_attr}/>')
        # Línea superior decorativa
        parts.append(f'<line x1="{ex+4}" y1="{ey}" x2="{ex+EW-4}" y2="{ey}" stroke="{color}" stroke-width="1.5" opacity="0.55"/>')
        # Badge de vendor: logo SVG inline o texto
        if vec_key:
            logo_d, logo_fill, logo_bg = VENDOR_LOGOS[vec_key]
            parts.append(
                f'<svg x="{ex+4}" y="{ey+7}" width="{bw}" height="14" viewBox="0 0 24 24">'
                f'<rect width="24" height="24" rx="3" fill="{logo_bg}"/>'
                f'<path d="{logo_d}" fill="{logo_fill}"/>'
                f'</svg>'
            )
        else:
            parts.append(f'<rect x="{ex+4}" y="{ey+7}" width="{bw}" height="14" rx="2" fill="{badge_col}" opacity="0.9"/>')
            parts.append(f'<text x="{ex+4+bw//2}" y="{ey+18}" text-anchor="middle" font-size="6.5" font-weight="bold" fill="white" font-family="Consolas,monospace">{badge_lbl}</text>')
        # Nombre del sistema (a la derecha del badge)
        parts.append(f'<text x="{name_cx}" y="{ey + 18}" text-anchor="middle" font-size="10" font-weight="bold" fill="{color}" font-family="Segoe UI,sans-serif">{name}</text>')
        # Detalle (línea completa)
        parts.append(f'<text x="{cx}" y="{ey + 32}" text-anchor="middle" font-size="8" fill="{LIV_TEXT_DIM}" font-family="Segoe UI,sans-serif">{detail}</text>')
        parts.append('</g>')

    # ── PASO 4: Etiquetas de conexión (dibujadas al final = siempre encima) ──
    # Ocultas por defecto; JS las muestra al seleccionar un sistema
    for frm, to, label, color, dashed in CONNS:
        x1, y1 = ext_center(frm) or (0, 0)
        x2, y2 = mod_center(to) or (0, 0)
        lx, ly = midpoint_label(x1, y1, x2, y2)
        lines_text = label.split("\n")
        max_len = max(len(ln) for ln in lines_text)
        bw_lbl = max_len * 5 + 10
        bh_lbl = len(lines_text) * 11 + 6
        parts.append(f'<g class="conn-lbl" data-from="{frm}" data-to="{to}" opacity="0">')
        parts.append(f'<rect x="{lx - bw_lbl//2:.0f}" y="{ly - 10:.0f}" width="{bw_lbl}" height="{bh_lbl}" rx="2" fill="{LIV_DARK}" fill-opacity="0.82"/>')
        for k, ln in enumerate(lines_text):
            parts.append(
                f'<text x="{lx:.0f}" y="{ly + k*11:.0f}" text-anchor="middle" '
                f'font-size="8" fill="{color}" font-family="Consolas,monospace">{ln}</text>'
            )
        parts.append('</g>')

    # ── Leyenda ──────────────────────────────────────────────────────────────
    legend = [
        ("#22c55e", "MM — Materials Management"),
        ("#f59e0b", "FI — Financial Accounting"),
        ("#10b981", "LE — Logistics Execution"),
        ("#38bdf8", "SD — Sales & Pricing"),
        ("#E00198", "HCM — Human Capital Mgmt"),
        ("#8b5cf6", "CO/BW — Controlling & Analytics"),
        ("#C9A130", "Integración confirmada — código fuente ZIM  /  Z overlay: 213 tablas · 33 FM"),
        ("#87C3D3", "Integración confirmada — Dashboard AS-IS  (OMS · PIM/STEP · ATG · Oracle · Tumbleweed)"),
    ]
    lx0, ly0 = 22, H - 18 - len(legend) * 17
    for i, (col, lbl) in enumerate(legend):
        lx, ly = lx0, ly0 + i * 17
        parts.append(f'<rect x="{lx}" y="{ly - 8}" width="10" height="10" fill="{col}" rx="1.5" opacity="0.8"/>')
        parts.append(f'<text x="{lx + 15}" y="{ly}" font-size="8.5" fill="{LIV_TEXT_DIM}" font-family="Segoe UI,sans-serif">{lbl}</text>')
    parts.append(f'<line x1="22" y1="{ly0 - 16}" x2="520" y2="{ly0 - 16}" stroke="{LIV_GOLD}" stroke-width="0.7" opacity="0.3"/>')

    # Hint de interactividad
    parts.append(
        f'<text x="{W - 16}" y="{H - 10}" text-anchor="end" font-size="7.5" '
        f'fill="{LIV_TEXT_DIM}" opacity="0.55" font-family="Segoe UI,sans-serif">'
        f'Clic en módulo o sistema externo · clic nuevamente para deseleccionar</text>'
    )

    parts.append("</svg>")
    return "\n".join(parts)


# ── HTML wrapper — Liverpool Brain format (aurora + glassmorphism) ─────────────
def build_html(now):
    svg = build_svg()
    return f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Estructura Modular SAP — Liverpool Brain</title>
  <style>
    *{{box-sizing:border-box;margin:0;padding:0}}
    :root{{
      --cerise:#E00198;--sky:#87C3D3;--sky-l:#96CCEE;--rose:#DA7AB0;
      --ink:#F8F0F5;--muted:#c4a8bc;--muted2:#9a7d92;
      --bg:#0d0408;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.09)
    }}
    html{{scroll-behavior:smooth}}
    body{{background:var(--bg);color:var(--ink);
      font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;
      -webkit-font-smoothing:antialiased;padding-bottom:80px}}
    .aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
    .aurora::before{{content:"";position:absolute;width:55vw;height:55vw;left:-10vw;top:-14vw;
      border-radius:50%;filter:blur(90px);
      background:radial-gradient(circle,rgba(224,1,152,.22),transparent 70%);
      animation:f1 28s ease-in-out infinite}}
    .aurora::after{{content:"";position:absolute;width:45vw;height:45vw;right:-8vw;top:6vw;
      border-radius:50%;filter:blur(90px);
      background:radial-gradient(circle,rgba(135,195,211,.15),transparent 70%);
      animation:f2 34s ease-in-out infinite}}
    @keyframes f1{{50%{{transform:translate(4vw,6vh) scale(1.1)}}}}
    @keyframes f2{{50%{{transform:translate(-5vw,8vh) scale(1.08)}}}}
    .grain{{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
      background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
    nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;
      padding:15px 30px;backdrop-filter:blur(18px) saturate(150%);
      -webkit-backdrop-filter:blur(18px) saturate(150%);
      background:rgba(13,4,8,.55);border-bottom:1px solid rgba(255,255,255,.06)}}
    nav img{{height:21px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
    nav .nt{{font-size:12.5px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
    nav .sp{{flex:1}}
    nav a.jump{{font-size:12.5px;color:var(--muted);padding:7px 13px;border-radius:20px;transition:.22s;text-decoration:none}}
    nav a.jump:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
    nav a.jump.ext{{color:var(--cerise)}}
    nav a.jump.ext:hover{{color:#fff}}
    .wrap{{max-width:1280px;margin:0 auto;padding:0 30px}}
    .hero{{padding:110px 0 28px;display:flex;flex-direction:column;justify-content:center}}
    .eyebrow{{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;
      padding:8px 16px;border-radius:30px;font-size:12px;font-weight:600;letter-spacing:.03em;
      color:#f0dce8;margin-bottom:28px;background:rgba(255,255,255,.05);
      border:1px solid var(--glassb);backdrop-filter:blur(10px)}}
    .eyebrow .dot{{width:7px;height:7px;border-radius:50%;background:var(--cerise);
      box-shadow:0 0 12px var(--cerise);animation:pulse 2.4s infinite}}
    @keyframes pulse{{50%{{opacity:.4}}}}
    .hero h1{{font-size:clamp(38px,5vw,68px);font-weight:800;line-height:1.0;letter-spacing:-.035em;
      background:linear-gradient(176deg,#fff 34%,#e8b0d4);-webkit-background-clip:text;
      background-clip:text;color:transparent;margin-bottom:18px}}
    .hero .sub{{font-size:clamp(14px,1.5vw,17px);color:var(--muted);max-width:64ch;line-height:1.55;margin-bottom:0}}
    .hero .sub b{{color:#f0dce8;font-weight:600}}
    .diagram-wrap{{
      background:rgba(20,6,16,.6);backdrop-filter:blur(12px);
      border:1px solid rgba(255,255,255,.08);border-radius:14px;
      overflow:hidden;margin-bottom:20px}}
    svg{{display:block;max-width:100%;height:auto}}
    .info{{display:grid;grid-template-columns:repeat(3,1fr);gap:14px;margin-bottom:24px}}
    @media(max-width:780px){{.info{{grid-template-columns:1fr}}}}
    .card{{
      background:rgba(20,6,16,.65);backdrop-filter:blur(18px);
      border:1px solid rgba(255,255,255,.08);border-radius:14px;
      padding:18px 20px;
    }}
    .card h3{{
      font-size:11px;font-weight:700;letter-spacing:.12em;
      text-transform:uppercase;color:var(--cerise);margin-bottom:10px}}
    .card ul{{list-style:none;font-size:12.5px;color:var(--muted);line-height:1.75}}
    .card ul li::before{{content:"· ";color:var(--cerise)}}
    .card ul li strong{{color:var(--ink);font-weight:600}}
    .footer{{font-size:11px;color:var(--muted2);text-align:center;padding-top:12px;
      border-top:1px solid rgba(255,255,255,.06)}}
  </style>
</head>
<body>
<div class="aurora"></div>
<div class="grain"></div>

<nav>
  <img src="Liverpool_logo.png" alt="Liverpool" onerror="this.style.display='none'">
  <span class="nt">Liverpool Brain · Arquitectura SAP</span>
  <div class="sp"></div>
  <a href="index.html" class="jump">Brain</a>
  <a href="cadena-valor.html" class="jump">Cadena de Valor</a>
  <a href="mapa-capacidades.html" class="jump">Capacidades RTL</a>
  <a href="sap-architecture.html" class="jump">Arquitectura SAP</a>
  <a href="sap-modular.html" class="jump ext">Estructura Modular</a>
</nav>

<div class="wrap">
  <header class="hero">
    <div class="eyebrow"><span class="dot"></span> SPE-AM-003 · SAP ECC · AS-IS · Módulo de Importaciones ZIM</div>
    <h1>Estructura Modular<br>SAP ECC</h1>
    <p class="sub"><b>13 sistemas integrados</b> — 8 confirmados por código fuente ABAP (dorado) y 5 confirmados por Dashboard AS-IS (azul). Módulos SAP en disposición hexagonal con el Módulo Z de Importaciones como overlay.</p>
  </header>

  <div class="diagram-wrap">
    {svg}
  </div>

  <div class="info">
    <div class="card">
      <h3>Logística</h3>
      <ul>
        <li><strong>MM-PUR</strong> Compras — motor del módulo ZIM (EKKO/EKPO)</li>
        <li><strong>MM-MAT</strong> Maestro de materiales (MARA/MAKT/MARC)</li>
        <li><strong>LE-SHP</strong> Entregas parciales (LIKP/LIPS)</li>
        <li><strong>SD</strong> Condiciones y Incoterms (KONV)</li>
        <li><strong>EWM</strong> Warehouse Management (CD)</li>
      </ul>
    </div>
    <div class="card">
      <h3>Finanzas y Analítica</h3>
      <ul>
        <li><strong>FI-GL</strong> General Ledger (BKPF/BSEG)</li>
        <li><strong>FI-AP</strong> Cuentas por Pagar (BSIK/BSAK)</li>
        <li><strong>Multi-sociedad</strong> LIV, SBB y Sfera Moda Joven (150)</li>
        <li><strong>CO</strong> Controlling</li>
        <li><strong>BW</strong> Analytics — BW LIV, PDM y BW4 SBB (Azure)</li>
      </ul>
    </div>
    <div class="card">
      <h3>Capa Z — Módulo Importaciones</h3>
      <ul>
        <li><strong>213</strong> tablas Z propias del módulo ZIM</li>
        <li><strong>33</strong> function modules Z sin BAPIs estándar SAP</li>
        <li><strong>12</strong> programas ABAP (ZIMPOC*, ZIMFIC*, ZRT*)</li>
        <li><strong>2</strong> programas activos en 2025 (abr y oct)</li>
        <li>Pedimento 14→16 dígitos absorbido en código (oct-2025)</li>
      </ul>
    </div>
  </div>

  <div class="footer">Liverpool AM · SPE-AM-003 · Análisis de código fuente ABAP · {now}</div>
</div>

<script>
(function(){{
  const svg = document.getElementById('sap-diagram');
  if (!svg) return;
  let sel = null;

  function resetAll() {{
    svg.querySelectorAll('.conn').forEach(el => {{
      el.setAttribute('opacity', '0.38');
      el.setAttribute('stroke-width', '1.5');
    }});
    svg.querySelectorAll('.conn-lbl').forEach(el => el.setAttribute('opacity', '0'));
    svg.querySelectorAll('.mod-node, .ext-sys').forEach(el => el.setAttribute('opacity', '1'));
    sel = null;
  }}

  function highlight(type, id) {{
    if (sel && sel.type === type && sel.id === id) {{ resetAll(); return; }}
    sel = {{ type, id }};
    const connected = new Set([id]);

    svg.querySelectorAll('.conn').forEach(el => {{
      const from = el.dataset.from, to = el.dataset.to;
      const hit = (type === 'ext' && from === id) || (type === 'mod' && to === id);
      if (hit) {{
        el.setAttribute('opacity', '0.95');
        el.setAttribute('stroke-width', '2.5');
        connected.add(from); connected.add(to);
      }} else {{
        el.setAttribute('opacity', '0.04');
        el.setAttribute('stroke-width', '1.5');
      }}
    }});

    svg.querySelectorAll('.conn-lbl').forEach(el => {{
      const from = el.dataset.from, to = el.dataset.to;
      const hit = (type === 'ext' && from === id) || (type === 'mod' && to === id);
      el.setAttribute('opacity', hit ? '1' : '0');
    }});

    svg.querySelectorAll('.mod-node').forEach(el =>
      el.setAttribute('opacity', connected.has(el.dataset.mod) ? '1' : '0.15'));
    svg.querySelectorAll('.ext-sys').forEach(el =>
      el.setAttribute('opacity', connected.has(el.dataset.sys) ? '1' : '0.15'));
  }}

  svg.querySelectorAll('.ext-sys').forEach(el =>
    el.addEventListener('click', e => {{ e.stopPropagation(); highlight('ext', el.dataset.sys); }}));
  svg.querySelectorAll('.mod-node').forEach(el =>
    el.addEventListener('click', e => {{ e.stopPropagation(); highlight('mod', el.dataset.mod); }}));
  svg.addEventListener('click', () => resetAll());
}})();
</script>
</body>
</html>"""


def main():
    now = datetime.now().strftime("%Y-%m-%d %H:%M")
    html = build_html(now)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(html, encoding="utf-8")
    print(f"Generado: {OUTPUT}")
    print(f"Portal:   http://localhost:8002/sap-modular.html")


if __name__ == "__main__":
    main()
