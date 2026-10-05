#!/usr/bin/env python3
"""
build-sap-architecture.py
Genera portal/sap-architecture.html — arquitectura SAP AS-IS descubierta
del análisis de código fuente (Módulo de Importaciones ZIM).

Ejecutar desde liverpool-brain/:
    python generators/build-sap-architecture.py
"""
import sqlite3
from pathlib import Path
from datetime import datetime

BRAIN_DIR = Path(__file__).parent.parent
DB_PATH   = BRAIN_DIR / "liverpool-brain.db"
OUTPUT    = BRAIN_DIR / "portal" / "sap-architecture.html"

# ── Datos estáticos de arquitectura (extraídos del análisis de código) ────────

SAP_MODULES = [
    {
        "id": "MM-PUR",
        "name": "MM-PUR — Compras",
        "desc": "Motor central del módulo. Pedidos de compra de importación (EKKO/EKPO). Tipos IM, IP, TIM, TIP. Grupos de compras.",
        "tables": ["EKKO", "EKPO", "EKET"],
        "z_tables": ["ZIM_RVPO", "ZRT_LEKPO"],
        "programs": 9,
        "color": "sap",
    },
    {
        "id": "MM-MAT",
        "name": "MM-MAT — Materiales",
        "desc": "Maestro de materiales importados. Unidades de medida, clasificación, datos por centro.",
        "tables": ["MARA", "MAKT", "MARC"],
        "z_tables": [],
        "programs": 5,
        "color": "sap",
    },
    {
        "id": "LE-SHP",
        "name": "LE-SHP — Logística Entregas",
        "desc": "Entregas parciales por pedimento. Tipo ZOIM. Pool WF30. Centros CDT (0090/L090/T090).",
        "tables": ["LIKP", "LIPS"],
        "z_tables": ["ZIM_LICH", "ZIM_RCBP"],
        "programs": 4,
        "color": "sap",
    },
    {
        "id": "FI-GL",
        "name": "FI-GL — General Ledger",
        "desc": "Documentos contables de pago de importación. Anticipos, gastos conceptos 003/008/016.",
        "tables": ["BKPF", "BSEG"],
        "z_tables": ["ZIM_LIPG", "ZIM_LDPG"],
        "programs": 2,
        "color": "fi",
    },
    {
        "id": "FI-AP",
        "name": "FI-AP — Cuentas por Pagar",
        "desc": "Saldos pendientes y pagados a proveedores internacionales. Retenciones IVA. TC fijo. Duty Free.",
        "tables": ["BSIK", "BSAK"],
        "z_tables": ["ZIM_LICK", "ZIM_LPPG"],
        "programs": 2,
        "color": "fi",
    },
    {
        "id": "FI-MC",
        "name": "FI — Multi-Sociedad",
        "desc": "Operación en 3 sociedades: LIV (El Puerto de Liverpool) + SBB (Suburbia) + Sfera Moda Joven (150).",
        "tables": ["T001"],
        "z_tables": [],
        "programs": 3,
        "color": "fi",
    },
    {
        "id": "MM-VEN",
        "name": "MM/FI — Maestro Proveedores",
        "desc": "Datos de importadores, brokers y agentes aduanales. Extensión Z con datos específicos de importación.",
        "tables": ["LFA1", "LFB1", "LFM1"],
        "z_tables": ["ZIM_LFA1", "ZIM_AGAD"],
        "programs": 4,
        "color": "sap",
    },
    {
        "id": "SD-COND",
        "name": "SD — Condiciones/Precio",
        "desc": "Incoterms por grupo de compras. Cálculo de costo total de importación con aranceles.",
        "tables": ["KONV"],
        "z_tables": ["ZOLLS_IMP", "ZTASA_IGI"],
        "programs": 2,
        "color": "sd",
    },
    {
        "id": "BASIS",
        "name": "Basis — Técnico",
        "desc": "Procesamiento paralelo RFC (STARTING NEW TASK). Grupos de trabajo p_group. Gestión de Work Processes.",
        "tables": [""],
        "z_tables": ["ZRTPOF079N"],
        "programs": 2,
        "color": "basis",
    },
]

PROGRAMS = [
    {"name": "ZIMPOC001", "phase": "Reserva PO",          "active": False, "complexity": "high"},
    {"name": "ZIMPOC002", "phase": "Datos logísticos",    "active": False, "complexity": "very-high"},
    {"name": "ZIMPOC003", "phase": "Generación PO",       "active": False, "complexity": "high"},
    {"name": "ZIMPOC005", "phase": "Pre-embarque",        "active": False, "complexity": "medium"},
    {"name": "ZIMPOC007", "phase": "Reserva extendida",   "active": False, "complexity": "high"},
    {"name": "ZIMPOB010B","phase": "Pedimentos batch",    "active": False, "complexity": "low"},
    {"name": "ZIMPOC023", "phase": "Faltantes/sobrantes", "active": False, "complexity": "medium"},
    {"name": "ZIMPOC024", "phase": "Mantenimiento PO",    "active": False, "complexity": "high"},
    {"name": "ZIMFIC001", "phase": "Pre-embarque portal", "active": False, "complexity": "medium"},
    {"name": "ZIMFIC002", "phase": "Contabilización",     "active": False, "complexity": "very-high"},
    {"name": "ZRTPOC079", "phase": "Traslado tipo 7",     "active": False, "complexity": "medium"},
    {"name": "ZRTPOC079N","phase": "Reporte pedidos",     "active": True,  "complexity": "medium"},  # abr-2025
    {"name": "ZRT_PO_REP_EPI_BD", "phase": "Interface POS", "active": True, "complexity": "medium"}, # oct-2025
]

INTEGRATIONS = [
    {"from": "SAP ECC LIV", "to": "POS / Bridgecore",   "via": "IBM IIB",  "program": "ZRT_PO_REP_EPI_BD", "data": "Pedimentos 16 dígitos", "active": True},
    {"from": "SAP ECC LIV", "to": "SAT / Aduana",        "via": "IBM IIB",  "program": "ZIMPOB010B",         "data": "Datos de pedimentos",   "active": False},
    {"from": "SAP ECC LIV", "to": "SAP S/4HANA SBB",    "via": "RFC/IDOC", "program": "—",                  "data": "Replicación datos",     "active": False},
    {"from": "SAP ECC LIV", "to": "Proveedor Internacional", "via": "ZIMFIC001 (portal)", "program": "ZIMFIC001", "data": "Pre-embarques", "active": False},
    {"from": "SAP ECC LIV", "to": "Event Manager (EM)", "via": "RFC interno", "program": "ZIMPOC001/002/003", "data": "Eventos de importación", "active": False},
    {"from": "SAP ECC LIV", "to": "SAP BW / Analytics", "via": "BW extractors", "program": "—", "data": "Datos de POs y contabilidad", "active": False},
]


def module_card(m):
    color_map = {
        "sap":   ("#60a5fa", "rgba(28,127,211,0.08)", "rgba(28,127,211,0.3)"),
        "fi":    ("#f87171", "rgba(185,28,28,0.08)",  "rgba(185,28,28,0.3)"),
        "sd":    ("#a78bfa", "rgba(124,58,237,0.08)", "rgba(124,58,237,0.3)"),
        "basis": ("#94a3b8", "rgba(100,116,139,0.08)","rgba(100,116,139,0.3)"),
    }
    txt, bg, brd = color_map.get(m["color"], color_map["sap"])
    tables_std = " · ".join(t for t in m["tables"] if t)
    tables_z   = " · ".join(m["z_tables"]) if m["z_tables"] else ""
    return f"""
      <div style="background:{bg};border:1px solid {brd};border-radius:6px;padding:12px;">
        <div style="font-size:.72rem;font-weight:700;color:{txt};margin-bottom:6px;">{m['name']}</div>
        <div style="font-size:.64rem;color:#94a3b8;line-height:1.5;margin-bottom:8px;">{m['desc']}</div>
        {'<div style="font-family:Consolas,monospace;font-size:.62rem;color:#6ee7b7;margin-bottom:2px;">' + tables_std + '</div>' if tables_std else ''}
        {'<div style="font-family:Consolas,monospace;font-size:.60rem;color:#fcd34d;">' + tables_z + '</div>' if tables_z else ''}
        <div style="font-size:.60rem;color:#64748b;margin-top:6px;">{m['programs']} programa(s)</div>
      </div>"""


def program_chip(p):
    phase = p["phase"]
    name  = p["name"]
    if p["active"]:
        title = f"{phase} — Activo en 2025"
        return (f'<span style="font-size:.6rem;font-family:Consolas,monospace;'
                f'background:rgba(52,211,153,.15);border:1px solid rgba(52,211,153,.5);'
                f'border-radius:3px;padding:3px 7px;color:#34d399;" title="{title}">'
                f'{name} &#9679;</span>')
    else:
        return (f'<span style="font-size:.6rem;font-family:Consolas,monospace;'
                f'background:rgba(240,160,0,.08);border:1px solid rgba(240,160,0,.25);'
                f'border-radius:3px;padding:3px 7px;color:#fcd34d;" title="{phase}">'
                f'{name}</span>')


def integ_row(itg):
    active_style = "color:#34d399" if itg["active"] else "color:#64748b"
    return f"""<tr>
      <td style="padding:5px 10px;font-family:Consolas,monospace;font-size:.65rem;color:#60a5fa;">{itg['from']}</td>
      <td style="padding:5px 10px;font-size:.65rem;color:#94a3b8;">→</td>
      <td style="padding:5px 10px;font-size:.65rem;color:#c9d1d9;">{itg['to']}</td>
      <td style="padding:5px 10px;font-size:.65rem;color:#a78bfa;">{itg['via']}</td>
      <td style="padding:5px 10px;font-family:Consolas,monospace;font-size:.62rem;color:#fcd34d;">{itg['program']}</td>
      <td style="padding:5px 10px;font-size:.63rem;color:#94a3b8;">{itg['data']}</td>
      <td style="padding:5px 10px;font-size:.63rem;{active_style}">{'● Activo 2025' if itg['active'] else '○'}</td>
    </tr>"""


def render(programs, total_z_tables=213, total_fm=33):
    active_count = sum(1 for p in programs if p["active"])
    prog_chips   = "\n        ".join(program_chip(p) for p in programs)
    module_cards = "\n".join(module_card(m) for m in SAP_MODULES)
    integ_rows   = "\n".join(integ_row(i) for i in INTEGRATIONS)
    now = datetime.now().strftime("%Y-%m-%d %H:%M")

    return f"""<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width,initial-scale=1.0"/>
  <title>Liverpool — Arquitectura SAP AS-IS · Módulo ZIM</title>
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
    a{{color:var(--sky);text-decoration:none}}
    a:hover{{text-decoration:underline}}
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
    .wrap{{max-width:1160px;margin:0 auto;padding:0 30px}}
    .hero{{padding:110px 0 28px;display:flex;flex-direction:column}}
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
    .hero .sub{{font-size:clamp(14px,1.4vw,16px);color:var(--muted);max-width:64ch;line-height:1.55;margin-bottom:28px}}
    .hero .sub b{{color:#f0dce8;font-weight:600}}
    .layer-lbl{{font-size:10px;font-weight:800;letter-spacing:.18em;text-transform:uppercase;
      color:var(--cerise);margin-bottom:10px;padding-left:2px}}
    .row{{display:flex;gap:12px;margin-bottom:12px;align-items:stretch}}
    .box{{background:rgba(20,6,16,.65);backdrop-filter:blur(14px);
      border:1px solid rgba(255,255,255,.08);border-radius:10px;padding:14px 16px;flex:1}}
    .box h3{{font-size:.74rem;font-weight:700;margin-bottom:6px}}
    .box ul{{list-style:none;font-size:.66rem;color:var(--muted);line-height:1.65}}
    .box ul li::before{{content:"· ";color:var(--cerise)}}
    .tbl{{font-family:Consolas,monospace;font-size:.62rem;color:#6ee7b7}}
    .conn{{display:flex;align-items:center;justify-content:center;gap:8px;height:28px;
      color:var(--muted2);font-size:.68rem;margin:2px 0}}
    .arrow-line{{flex:1;height:1px;background:linear-gradient(to right,transparent,rgba(255,255,255,.1),transparent)}}
    .sap-wrap{{background:rgba(135,195,211,.04);border:2px solid rgba(135,195,211,.4);
      border-radius:12px;padding:18px;margin-bottom:12px}}
    .sap-hdr{{display:flex;justify-content:space-between;align-items:center;margin-bottom:14px}}
    .sap-title{{font-size:.8rem;font-weight:700;color:var(--sky)}}
    .sap-badge{{font-size:.6rem;background:rgba(135,195,211,.12);color:var(--sky);
      border:1px solid rgba(135,195,211,.3);border-radius:4px;padding:2px 10px}}
    .zim-wrap{{background:rgba(224,1,152,.04);border:2px dashed rgba(224,1,152,.4);
      border-radius:8px;padding:14px;margin-bottom:16px}}
    .zim-title{{font-size:.72rem;font-weight:700;color:var(--cerise);margin-bottom:10px}}
    .chips{{display:flex;flex-wrap:wrap;gap:5px;margin-bottom:10px}}
    .stats{{display:flex;gap:20px;font-size:.62rem;color:var(--muted2)}}
    .stats strong{{color:var(--cerise)}}
    .mods{{display:grid;grid-template-columns:repeat(3,1fr);gap:10px;margin-bottom:14px}}
    .sigs{{display:flex;flex-wrap:wrap;gap:7px;margin-top:4px}}
    .sig{{font-size:.62rem;padding:3px 10px;border-radius:4px;border:1px solid}}
    .sig-g{{background:rgba(52,211,153,.08);border-color:rgba(52,211,153,.35);color:#34d399}}
    .sig-y{{background:rgba(224,1,152,.08);border-color:rgba(224,1,152,.35);color:var(--cerise)}}
    .sig-b{{background:rgba(135,195,211,.08);border-color:rgba(135,195,211,.35);color:var(--sky)}}
    table{{width:100%;border-collapse:collapse;font-size:.65rem}}
    th{{text-align:left;padding:6px 10px;border-bottom:1px solid rgba(255,255,255,.07);
      color:var(--muted2);font-weight:600;font-size:.62rem;letter-spacing:.05em;text-transform:uppercase}}
    td{{padding:5px 10px;border-bottom:1px solid rgba(255,255,255,.04);color:var(--muted)}}
    tr:hover td{{background:rgba(255,255,255,.03)}}
    .footer{{margin-top:24px;font-size:.6rem;color:var(--muted2);text-align:center;
      padding-top:14px;border-top:1px solid rgba(255,255,255,.06)}}
    .chip{{display:inline-block;font-size:10px;font-weight:700;padding:3px 9px;border-radius:12px;
      border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.06);
      color:var(--muted);margin:3px 3px 0 0;letter-spacing:.04em}}
    .chip.cerise{{border-color:rgba(224,1,152,.35);color:var(--cerise);background:rgba(224,1,152,.09)}}
    .chip.sky{{border-color:rgba(135,195,211,.35);color:var(--sky);background:rgba(135,195,211,.09)}}
    .chip.gold{{border-color:rgba(201,161,48,.35);color:#fcd34d;background:rgba(201,161,48,.09)}}
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
  <a href="sap-architecture.html" class="jump ext">Arquitectura SAP</a>
  <a href="sap-modular.html" class="jump">Estructura Modular</a>
</nav>

<div class="wrap">
<header class="hero">
  <div class="eyebrow"><span class="dot"></span> SPE-AM-003 · SAP ECC 6.0 LIV · AS-IS · {now}</div>
  <h1>Arquitectura SAP<br>AS-IS</h1>
  <p class="sub"><b>Módulo de Importaciones ZIM</b> — descubierto del análisis de 12 programas ABAP. SAP ECC 6.0 LIV on-premise con capas de sistemas externos, integración IBM IIB y módulos estándar confirmados por código fuente.</p>
</header>

<!-- EXTERNOS -->
<div class="layer-lbl">Actores y Sistemas Externos</div>
<div class="row">
  <div class="box" style="border-left:3px solid #22c55e">
    <h3 style="color:#4ade80">Proveedor Internacional</h3>
    <ul>
      <li>Importadores, brokers, agentes aduanales</li>
      <li>Accede al portal de pre-embarques (ZIMFIC001)</li>
      <li>Confirmación o rechazo del envío antes de embarcar</li>
      <li class="tbl">LFA1 · LFB1 · LFM1 · ZIM_LFA1 · ZIM_AGAD</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #22c55e">
    <h3 style="color:#4ade80">SAT / Aduana México</h3>
    <ul>
      <li>Pedimento aduanal — campo extendido a 16 dígitos (oct-2025)</li>
      <li>Tasas: IGI, IVA, IEPS, DFC, ISAN, ITV, PRV, REC</li>
      <li>Clasificación arancelaria por fracción</li>
      <li class="tbl">ZIM_PEDI · ZIM_PEDIC · ZTASA* · ZOLLS_IMP</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #22c55e">
    <h3 style="color:#4ade80">POS / Tiendas Liverpool</h3>
    <ul>
      <li>Receptor de pedimentos ECC via Bridgecore</li>
      <li>Interface ZRT_PO_REP_EPI_BD activa en producción (oct-2025)</li>
      <li>Destino final del pedimento 16 dígitos</li>
      <li class="tbl">EKKO · EKPO → POS (via IBM IIB)</li>
    </ul>
  </div>
</div>

<!-- ARROW -->
<div class="conn">
  <div class="arrow-line"></div>
  <span>↕ &nbsp; IBM IIB — Bus Corporativo Central &nbsp; ↕</span>
  <div class="arrow-line"></div>
</div>

<!-- INTEGRACIÓN -->
<div class="layer-lbl">Capa de Integración</div>
<div class="row">
  <div class="box" style="border-left:3px solid #8b5cf6;flex:2">
    <h3 style="color:#a78bfa">IBM Integration Bus (IIB) 10</h3>
    <ul>
      <li>Bus corporativo central — 15+ sistemas integrados</li>
      <li>SAP ECC ↔ POS/Bridgecore (pedimentos de importación)</li>
      <li>SAP ECC ↔ SAT / Aduana (transmisión datos aduanales)</li>
      <li>Orquesta el procesamiento paralelo RFC por grupos de trabajo</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #8b5cf6;flex:1">
    <h3 style="color:#a78bfa">Event Manager (EM) SAP</h3>
    <ul>
      <li>Notificaciones inter-módulo dentro del ECC</li>
      <li>Activado por: ZIMPOC001, ZIMPOC002, ZIMPOC003</li>
      <li>Log de eventos de importación (trazabilidad completa)</li>
      <li class="tbl">ZIM_EMLG · ZIM_SYLOG</li>
    </ul>
  </div>
</div>

<!-- ARROW -->
<div class="conn">
  <div class="arrow-line"></div>
  <span>↕ &nbsp; RFC / BAPI / Direct DB &nbsp; ↕</span>
  <div class="arrow-line"></div>
</div>

<!-- SAP ECC CONTAINER -->
<div class="layer-lbl">Capa Aplicativa — SAP ECC 6.0 LIV</div>
<div class="sap-wrap">
  <div class="sap-hdr">
    <span class="sap-title">SAP ECC 6.0 — Landscape LIV (On-Premise)</span>
    <span class="sap-badge">Multi-sociedad: LIV · SBB · Sfera (150)</span>
  </div>

  <!-- ZIM Layer -->
  <div class="zim-wrap">
    <div class="zim-title">Z — Módulo de Importaciones (ZIM) · Capa de Personalización Liverpool</div>
    <div class="chips">
      {prog_chips}
    </div>
    <div class="stats">
      <span><strong>{total_z_tables}</strong> tablas Z</span>
      <span><strong>{total_fm}</strong> function modules Z propios</span>
      <span><strong>{active_count}</strong> programas activos en 2025</span>
      <span><strong>7</strong> fases del proceso cubiertas</span>
    </div>
  </div>

  <!-- Módulos SAP estándar -->
  <div style="font-size:.62rem;color:#8b949e;margin-bottom:8px;letter-spacing:.08em;text-transform:uppercase;">Módulos SAP Estándar Activados</div>
  <div class="mods">
    {module_cards}
  </div>

  <!-- Señales AS-IS -->
  <div class="sigs">
    <span class="sig sig-g">● ZRTPOC079N activo abr-2025</span>
    <span class="sig sig-g">● ZRT_PO_REP_EPI_BD activo oct-2025</span>
    <span class="sig sig-y">⚠ Pedimento 14→16 dígitos absorto en código (oct-2025)</span>
    <span class="sig sig-y">⚠ 33 Function Modules Z propios — sin BAPIs estándar SAP</span>
    <span class="sig sig-b">ℹ 3 sociedades (LIV·SBB·Sfera) comparten el módulo</span>
    <span class="sig sig-b">ℹ Procesamiento paralelo RFC (STARTING NEW TASK)</span>
  </div>
</div>

<!-- ARROW -->
<div class="conn">
  <div class="arrow-line"></div>
  <span>↕ &nbsp; RFC / IDOC / BW Extractors &nbsp; ↕</span>
  <div class="arrow-line"></div>
</div>

<!-- DOWNSTREAM -->
<div class="layer-lbl">Downstream / Destino</div>
<div class="row">
  <div class="box" style="border-left:3px solid #1c7fd3">
    <h3 style="color:#60a5fa">SAP S/4HANA SBB (Azure Cloud)</h3>
    <ul>
      <li>Landscape separado (Suburbia + SBB)</li>
      <li>EWM warehouse management cloud</li>
      <li>BW4HANA analytics (Azure)</li>
      <li>Destino de migración brownfield del ECC LIV</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #1c7fd3">
    <h3 style="color:#60a5fa">SAP BW / Analytics</h3>
    <ul>
      <li>BW LIV (on-prem) + BW PDM</li>
      <li>BW Híbrido (Presidencia)</li>
      <li>Datos de importaciones para reportería ejecutiva</li>
      <li>BW4HANA SBB (Azure) — landscape nuevo</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #1c7fd3">
    <h3 style="color:#60a5fa">SAP EWM / Almacenes</h3>
    <ul>
      <li>Warehouse Management (CD Liverpool)</li>
      <li>Integrado vía MM-PUR (recepción de mercancía)</li>
      <li>Faltantes/sobrantes (ZIMPOC023)</li>
      <li>Entregas parciales ZIM_LICH</li>
    </ul>
  </div>
</div>

<!-- MAPA DE INTEGRACIONES -->
<div style="margin-top:20px;margin-bottom:20px;">
  <div class="layer-lbl">Mapa de Integraciones Descubiertas del Código</div>
  <div style="background:#161b22;border:1px solid #30363d;border-radius:6px;overflow:hidden">
    <table>
      <thead>
        <tr style="background:#0d1117">
          <th>Origen</th>
          <th></th>
          <th>Destino</th>
          <th>Mecanismo</th>
          <th>Programa</th>
          <th>Dato</th>
          <th>Estado</th>
        </tr>
      </thead>
      <tbody>
        {integ_rows}
      </tbody>
    </table>
  </div>
</div>

<!-- HIPÓTESIS 7R -->
<div class="layer-lbl">Hipótesis de Modernización (Framework 7R)</div>
<div class="row">
  <div class="box" style="border-left:3px solid #22c55e">
    <h3 style="color:#4ade80">Replatform — Brownfield S/4HANA</h3>
    <ul>
      <li>Menor riesgo — 213 tablas Z migran como están</li>
      <li>Deuda técnica persiste · Costo y tiempo mínimos</li>
      <li>SAP moderniza MM, FI, LE en S/4HANA automáticamente</li>
      <li style="color:#64748b">Señal: ZIM_CNST y ZZSTATUS_MI requieren revisión</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #f59e0b">
    <h3 style="color:#fbbf24">Repurchase — SAP GTS</h3>
    <ul>
      <li>Global Trade Services — estándar SAP para pedimentos</li>
      <li>Elimina las 213 tablas Z del módulo ZIM</li>
      <li>Mayor beneficio · Mayor complejidad de migración</li>
      <li style="color:#fcd34d">Señal clave: cambio 14→16 dígitos SAT (oct-2025) manejado manualmente — GTS lo haría estándar</li>
    </ul>
  </div>
  <div class="box" style="border-left:3px solid #8b5cf6">
    <h3 style="color:#a78bfa">Refactor — Microservicio</h3>
    <ul>
      <li>Extraer lógica ZIM como servicio independiente</li>
      <li>Consume API MM-PUR de S/4HANA</li>
      <li>Mayor flexibilidad · Requiere re-engineering completo</li>
      <li style="color:#64748b">Señal: los 33 FMs Z propios son la API interna candidata</li>
    </ul>
  </div>
</div>

<div class="footer">
  Liverpool AM · SPE-AM-003 · Análisis de código fuente: 12 programas ABAP (ZIMPOC* · ZIMFIC* · ZRTPOC* · ZRT_*) · Generado {now}
</div>

</div><!-- /wrap -->
</body>
</html>"""


def main():
    if not DB_PATH.exists():
        print(f"ERROR: brain no encontrado — {DB_PATH}")
        return

    conn = sqlite3.connect(str(DB_PATH))
    programs_db = conn.execute(
        "SELECT name, description FROM components WHERE source_system='SAP' ORDER BY name"
    ).fetchall()
    conn.close()

    # Actualizar active flags desde db si están disponibles
    active_names = {r[0] for r in programs_db if r[1] and '2025' in r[1]}
    for p in PROGRAMS:
        if p["name"] in active_names:
            p["active"] = True

    html = render(PROGRAMS)
    OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    OUTPUT.write_text(html, encoding="utf-8")
    print(f"Generado: {OUTPUT}")
    print(f"  {len(PROGRAMS)} programas ZIM")
    print(f"  {len(SAP_MODULES)} módulos SAP estándar")
    print(f"  {len(INTEGRATIONS)} integraciones documentadas")
    print(f"\nPortal: http://localhost:8002/sap-architecture.html")


if __name__ == "__main__":
    main()
