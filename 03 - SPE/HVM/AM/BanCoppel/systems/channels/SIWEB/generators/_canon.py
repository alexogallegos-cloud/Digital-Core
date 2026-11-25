#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
_canon.py — chrome canónico del portal SIWEB.

El formato lo define el portal de Informix (`systems/core/Informix/portal/`), que
es el canon del proyecto. La hoja de estilos de abajo está tomada literal de
`Informix/generators/build-test-catalog.py` para que ambos portales se vean
iguales de verdad y no "parecido".

Dos arquetipos de página:
  landing  — barra `nav`, aurora animada, secciones y tarjetas (index)
  catálogo — `hero-bar` con logo, migaja y volver, luego `head` con métricas,
             barra de filtros pegajosa, lista y pie con procedencia

Este módulo sirve el arquetipo de catálogo, que es el de las páginas de
contenido. Lo usan build-core-portal.py, build-endpoints-portal.py y
build-views-portal.py.

El nombre empieza con guion bajo para que sea importable: los generadores
llevan guiones en el nombre y no se pueden importar entre sí.
"""
from pathlib import Path

BASE = Path(__file__).resolve().parent.parent
DB = BASE / "digital-brain" / "brain.db"
PORTAL = BASE / "portal"
DATA = PORTAL / "data"
KB = BASE / "knowledge-base"

# Paleta BanCoppel del Design Studio, idéntica a la del portal Informix y
# a la del portal AppMovil. No se toca aquí: se toca en design-studio/.
MARCA = {
    "logo": "bancoppel-logo.png",
    "alt": "BanCoppel",
    "crumb": "SIWEB",
    "sys": "SIWEB",
    "back": "index.html",
    "accent": "#F0D224",
    "accent2": "#f6e27a",
    "blue": "#3D5FCD",
    "blued": "#122FB1",
    "bg": "#060a1a",
    "glow": "240,210,36",
}

CSS = r"""
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:__BLUE__;--blued:__BLUED__;--yellow:__ACCENT__;--yellow2:__ACCENT2__;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}
body{background:__BG__;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.45),transparent 70%)}
.aurora::after{content:"";position:absolute;width:40vw;height:40vw;right:-10vw;bottom:-12vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(__GLOW__,.16),transparent 70%)}
.hero-bar{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:18px;padding:14px 32px;
 backdrop-filter:blur(20px) saturate(150%);-webkit-backdrop-filter:blur(20px) saturate(150%);
 background:rgba(6,10,26,.6);border-bottom:1px solid rgba(255,255,255,.06)}
.hero-bar img{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}
.hero-bar .hb-sep{width:1px;height:28px;background:rgba(255,255,255,.15)}
.hero-bar .crumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}
.hero-bar .crumb em{color:var(--yellow);font-style:normal}
.hero-bar .hb-sp{flex:1}
.hero-bar a.back{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s;white-space:nowrap}
.hero-bar a.back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.wrap{max-width:1260px;margin:0 auto;padding:0 30px}
.head{padding:96px 0 26px}
.kick{font-size:11px;font-weight:800;letter-spacing:.18em;text-transform:uppercase;color:var(--yellow);margin-bottom:11px}
.head h1{font-size:clamp(26px,4vw,42px);font-weight:900;letter-spacing:-.03em;line-height:1.05;
 background:linear-gradient(176deg,#fff 36%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.head p{color:var(--muted);font-size:14px;margin-top:14px;max-width:84ch;line-height:1.7}
.head p b{color:#e4eaff;font-weight:600}
.stats{display:flex;gap:10px;flex-wrap:wrap;margin-top:22px}
.sb{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:14px 20px;min-width:96px}
.sb .sn{font-size:24px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;line-height:1;
 background:linear-gradient(135deg,var(--yellow),var(--yellow2));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.sb.b .sn{background:linear-gradient(135deg,#93c5fd,#6f8ce6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.sb .sl{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2);margin-top:5px}
.legend{display:flex;gap:8px;flex-wrap:wrap;margin-top:16px}
.legend-item{font-size:11px;color:var(--muted2);background:rgba(255,255,255,.035);border:1px solid rgba(255,255,255,.07);
 border-radius:10px;padding:6px 11px;display:flex;gap:8px;align-items:baseline}
.legend-item b{color:#c9d3f5;font-weight:600}
.legend-item span{font-variant-numeric:tabular-nums;color:var(--yellow);font-weight:700}
.bar{position:sticky;top:62px;z-index:40;display:flex;gap:9px;flex-wrap:wrap;align-items:center;padding:14px 0;
 background:linear-gradient(180deg,__BG__ 72%,transparent)}
input[type=search],select{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:10px;
 color:var(--ink);font-size:12.5px;padding:9px 12px;font-family:inherit;outline:none;transition:.2s}
input[type=search]{flex:1;min-width:230px}
input[type=search]:focus,select:focus{border-color:rgba(__GLOW__,.5);background:rgba(255,255,255,.08)}
select option{background:#101733;color:#fff}
.chip{font-size:11.5px;font-weight:600;color:var(--muted);background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1);
 border-radius:20px;padding:8px 14px;cursor:pointer;transition:.2s;user-select:none}
.chip:hover{color:var(--ink);background:rgba(255,255,255,.09)}
.chip.on{color:#10101e;background:var(--yellow);border-color:var(--yellow);font-weight:700}
a.dl{font-size:11.5px;font-weight:700;color:var(--yellow);text-decoration:none;border:1px solid rgba(__GLOW__,.35);
 background:rgba(__GLOW__,.08);border-radius:20px;padding:8px 14px;white-space:nowrap}
a.dl:hover{background:rgba(__GLOW__,.16)}
.count{font-size:12px;color:var(--muted2);padding:4px 0 14px;font-variant-numeric:tabular-nums}
.count b{color:var(--yellow);font-weight:700}
.tc{border:1px solid rgba(255,255,255,.07);border-left-width:3px;border-radius:13px;background:rgba(255,255,255,.028);
 margin-bottom:9px;transition:.18s}
.tc:hover{background:rgba(255,255,255,.055)}
.tc.p1{border-left-color:#ff8787}.tc.p2{border-left-color:#74c0fc}.tc.p3{border-left-color:rgba(255,255,255,.14)}
.tch{display:flex;gap:14px;align-items:center;padding:14px 18px;cursor:pointer}
.tcid{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11px;color:var(--muted2);min-width:148px;flex-shrink:0}
.tct{flex:1;font-size:13.5px;color:#e4eaff;font-weight:600;line-height:1.45}
.tags{display:flex;gap:6px;flex-shrink:0;flex-wrap:wrap;justify-content:flex-end}
.tag{font-size:9.5px;font-weight:700;letter-spacing:.05em;padding:3px 8px;border-radius:8px;white-space:nowrap}
.t-tec{color:#c9d3f5;background:rgba(255,255,255,.07);border:1px solid rgba(255,255,255,.12)}
.t-dom{color:var(--muted2);background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);font-family:'SF Mono',ui-monospace,monospace}
.t-reg{color:#8fd3a0;background:rgba(143,211,160,.1);border:1px solid rgba(143,211,160,.28)}
.t-risk{color:#ffa94d;background:rgba(255,169,77,.12);border:1px solid rgba(255,169,77,.3)}
.t-p1{color:#ff8787;background:rgba(255,135,135,.12);border:1px solid rgba(255,135,135,.3)}
.t-p2{color:#74c0fc;background:rgba(116,192,252,.1);border:1px solid rgba(116,192,252,.26)}
.t-p3{color:var(--muted2);background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.1)}
.det{padding:4px 18px 18px 18px;border-top:1px solid rgba(255,255,255,.06);margin-top:2px}
.gw{display:grid;grid-template-columns:70px 1fr;gap:7px 14px;margin-top:14px}
.gk{font-size:10px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--yellow);padding-top:3px}
.gv{font-size:13px;color:var(--muted);line-height:1.6}
.ev{margin-top:14px;padding:12px 15px;border-radius:10px;background:rgba(0,0,0,.3);border:1px solid rgba(255,255,255,.07)}
.evk{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);margin-bottom:7px}
.evv{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11.5px;color:#c9d3f5;line-height:1.6;word-break:break-word}
.evm{font-size:11.5px;color:var(--muted2);margin-top:9px;display:flex;gap:16px;flex-wrap:wrap}
.evm b{color:#c9d3f5;font-weight:600}
table.dt{width:100%;border-collapse:collapse;font-size:12px;margin-top:4px}
table.dt th{text-align:left;font-size:9px;font-weight:800;letter-spacing:.09em;text-transform:uppercase;
 color:var(--muted2);padding:7px 10px 7px 0;border-bottom:1px solid rgba(255,255,255,.1)}
table.dt td{padding:8px 10px 8px 0;border-bottom:1px solid rgba(255,255,255,.05);color:var(--muted);vertical-align:top}
table.dt tr:last-child td{border-bottom:none}
table.dt td.val{color:var(--yellow);font-weight:700}
.mono{font-family:'SF Mono',ui-monospace,Menlo,monospace;font-size:11.5px;color:#c9d3f5}
.pager{display:flex;gap:9px;align-items:center;justify-content:center;padding:26px 0 60px}
.pager button{background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.12);border-radius:10px;color:var(--ink);
 font-size:12.5px;font-family:inherit;padding:9px 16px;cursor:pointer;transition:.2s}
.pager button:hover:not(:disabled){background:rgba(255,255,255,.1)}
.pager button:disabled{opacity:.3;cursor:default}
.pager .pg{font-size:12px;color:var(--muted2);font-variant-numeric:tabular-nums;min-width:132px;text-align:center}
.empty{text-align:center;padding:60px 0;color:var(--muted2);font-size:14px}
footer{text-align:center;padding:36px 30px 60px;font-size:11.5px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);line-height:1.8}
footer code{font-family:'SF Mono',ui-monospace,monospace}
"""


def _tokens(css_o_html: str, marca: dict) -> str:
    """Sustituye los tokens de paleta del canon."""
    for k, v in (("__BLUE__", marca["blue"]), ("__BLUED__", marca["blued"]),
                 ("__ACCENT__", marca["accent"]), ("__ACCENT2__", marca["accent2"]),
                 ("__BG__", marca["bg"]), ("__GLOW__", marca["glow"])):
        css_o_html = css_o_html.replace(k, v)
    return css_o_html


def pagina(titulo: str, vista: str, kick: str, h1: str, intro: str,
           metricas: str, cuerpo: str, pie: str, script: str = "",
           css_extra: str = "", leyenda: str = "", enlaces: str = "",
           marca: dict = None) -> str:
    """
    Arma una página de catálogo en el canon.

    titulo   — <title> del documento
    vista    — nombre de la vista para la migaja, en versalitas
    kick     — ante-título amarillo
    h1       — titular
    intro    — párrafo de entrada, admite <b>
    metricas — bloques .sb ya renderizados
    leyenda  — ítems .legend-item ya renderizados
    enlaces  — anclas .back extra para la barra superior
    cuerpo   — el contenido de la vista
    pie      — la línea de procedencia, admite <code>
    """
    m = marca or MARCA
    html = PLANTILLA
    html = html.replace("__CSS__", CSS + css_extra)
    for k, v in (("__TITLE__", titulo), ("__VISTA__", vista), ("__KICK__", kick),
                 ("__H1__", h1), ("__INTRO__", intro), ("__METRICAS__", metricas),
                 ("__LEYENDA__", leyenda), ("__ENLACES__", enlaces),
                 ("__CUERPO__", cuerpo), ("__PIE__", pie), ("__SCRIPT__", script),
                 ("__LOGO__", m["logo"]), ("__ALT__", m["alt"]),
                 ("__CRUMB__", m["crumb"]), ("__BACK__", m["back"])):
        html = html.replace(k, v)
    return _tokens(html, m)


PLANTILLA = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>__TITLE__</title>
<style>__CSS__</style></head><body>
<div class="aurora"></div>

<div class="hero-bar">
  <img src="__LOGO__" alt="__ALT__">
  <div class="hb-sep"></div>
  <span class="crumb">__CRUMB__ &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; <em>__VISTA__</em></span>
  <span class="hb-sp"></span>
  __ENLACES__
  <a href="__BACK__" class="back">Portal</a>
</div>

<div class="wrap">
  <div class="head">
    <div class="kick">__KICK__</div>
    <h1>__H1__</h1>
    <p>__INTRO__</p>
    <div class="stats">__METRICAS__</div>
    <div class="legend">__LEYENDA__</div>
  </div>
__CUERPO__
</div>

<footer>
  __PIE__
</footer>

<script>__SCRIPT__</script>
</body></html>"""


def sb(n, etiqueta: str, azul: bool = False) -> str:
    """Un bloque de métrica del encabezado."""
    valor = f"{n:,}".replace(",", ",") if isinstance(n, int) else str(n)
    return (f'<div class="sb{" b" if azul else ""}">'
            f'<div class="sn">{valor}</div><div class="sl">{etiqueta}</div></div>')


def item_leyenda(etiqueta: str, valor) -> str:
    v = f"{valor:,}" if isinstance(valor, int) else str(valor)
    return f'<div class="legend-item"><b>{etiqueta}</b><span>{v}</span></div>'
