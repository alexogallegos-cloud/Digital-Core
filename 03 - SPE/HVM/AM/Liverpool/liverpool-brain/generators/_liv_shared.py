"""
Liverpool portal — hero + page shell compartido.
Garantiza que TODA vista lleve el HERO con el logo real Liverpool_logo.png
(regla: portal/*.html siempre hero + logo; fix en generador, no en HTML).
"""

LOGO_SRC = "Liverpool_logo.png"

# CSS base común: paleta + reset + hero + stat-blocks + toolbar + tooltip
BASE_CSS = """
:root{--pink:#E00198;--sky:#87C3D3;--rose:#DA7AB0;--ink:#FFF0F8;--muted:#c09ab8;--muted2:#9070a0;
--bg:#0d0408;--bg2:#130610;--panel:#1a0814;--txt:#f0e6ef;--line:rgba(224,1,152,.18)}
*{box-sizing:border-box;margin:0;padding:0}html,body{height:100%}
body{background:var(--bg);color:var(--txt);font-family:'SF Pro Display',-apple-system,'Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;overflow:hidden}
.hero{position:relative;overflow:hidden;background:linear-gradient(135deg,#0d0408,#200412 40%,#360820 65%,#200412);flex-shrink:0}
.hero-grid{position:absolute;inset:0;background-image:linear-gradient(rgba(224,1,152,.10) 1px,transparent 1px),linear-gradient(90deg,rgba(224,1,152,.10) 1px,transparent 1px);background-size:48px 48px;mask-image:linear-gradient(to bottom,transparent,rgba(0,0,0,.5) 30%,rgba(0,0,0,.3) 70%,transparent)}
.hero-glow{position:absolute;top:-120px;left:50%;transform:translateX(-50%);width:600px;height:300px;background:radial-gradient(ellipse,rgba(224,1,152,.28),transparent 70%)}
.hero-bar{position:relative;z-index:1;display:flex;align-items:center;gap:18px;padding:14px 28px 16px;border-bottom:1px solid rgba(224,1,152,.12)}
.hero-logo{height:30px;width:auto;flex-shrink:0}
.hero-bar .crumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}
.hero-bar .crumb em{color:var(--sky);font-style:normal}.hero-bar .sp{flex:1}
.hero-bar .badge{font-size:9px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);padding:2px 8px;border-radius:20px}
.hero-bar a.back{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none}
.hero-bar a.back:hover{color:var(--txt);background:rgba(255,255,255,.07)}
.hero-body{position:relative;z-index:1;padding:18px 28px 22px;display:flex;align-items:flex-end;gap:32px;flex-wrap:wrap}
.hero-title{flex:1;min-width:240px}
.hero-label{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--sky);margin-bottom:8px}
.hero-h1{font-size:clamp(22px,4vw,32px);font-weight:900;letter-spacing:-.03em;line-height:1.1;background:linear-gradient(135deg,#fff 40%,rgba(224,1,152,.8));-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.hero-sub{font-size:12.5px;color:var(--muted);line-height:1.55;margin-top:10px;max-width:700px}
.hero-stats{display:flex;gap:4px;flex-wrap:wrap;align-items:flex-end}
.stat-block{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:12px;padding:11px 16px;min-width:84px}
.stat-block .sn{font-size:24px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;background:linear-gradient(135deg,var(--sky),#b8e0ea);-webkit-background-clip:text;-webkit-text-fill-color:transparent;line-height:1}
.stat-block.pink .sn{background:linear-gradient(135deg,var(--pink),var(--rose));-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.stat-block.red .sn{background:linear-gradient(135deg,#fca5a5,#f87171);-webkit-background-clip:text;-webkit-text-fill-color:transparent}
.stat-block .sl{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted);margin-top:4px}
#fbar{display:flex;gap:8px;align-items:center;flex-wrap:wrap;padding:10px 24px;background:var(--bg2);border-bottom:1px solid var(--line);flex-shrink:0}
#q{background:var(--panel);border:1px solid rgba(224,1,152,.4);border-radius:7px;color:var(--txt);padding:5px 10px;font-size:12px;width:210px;outline:none}
#q:focus{border-color:var(--sky)}
.sep{width:1px;height:18px;background:rgba(255,255,255,.08)}
.pill{border-radius:5px;padding:3px 9px;font-size:9.5px;font-weight:700;cursor:pointer;user-select:none;border:1px solid rgba(224,1,152,.25);color:var(--muted);background:rgba(224,1,152,.06);white-space:nowrap;transition:.15s}
.pill.on{border-color:var(--sky);color:var(--sky);background:rgba(135,195,211,.12)}
#info{margin-left:auto;font-size:9.5px;color:var(--muted)}
#tip{position:fixed;z-index:99;max-width:360px;pointer-events:none;display:none;background:#0d0408;color:#e2d0df;border:1px solid rgba(224,1,152,.3);border-radius:7px;padding:8px 12px;font-size:11px;line-height:1.5;white-space:pre-wrap;box-shadow:0 12px 34px rgba(0,0,0,.6)}
"""

TIP_JS = """
const _tip=document.createElement('div');_tip.id='tip';document.body.appendChild(_tip);
document.addEventListener('mouseover',e=>{const el=e.target.closest('[data-tip]');if(el){_tip.textContent=el.getAttribute('data-tip');_tip.style.display='block';}});
document.addEventListener('mousemove',e=>{if(_tip.style.display==='block'){let x=e.clientX+14,y=e.clientY+14;const r=_tip.getBoundingClientRect();if(x+r.width>innerWidth-8)x=e.clientX-r.width-14;if(y+r.height>innerHeight-8)y=e.clientY-r.height-14;_tip.style.left=x+'px';_tip.style.top=y+'px';}});
document.addEventListener('mouseout',e=>{if(e.target.closest('[data-tip]'))_tip.style.display='none';});
"""


def stat(sn, sl, cls=""):
    return f'<div class="stat-block {cls}"><div class="sn">{sn}</div><div class="sl">{sl}</div></div>'


def hero(label, h1, sub, crumb, badge, stats_html):
    return f"""<div class="hero"><div class="hero-grid"></div><div class="hero-glow"></div>
  <div class="hero-bar"><img class="hero-logo" src="{LOGO_SRC}" alt="Liverpool" onerror="this.style.display='none'">
    <span class="crumb">{crumb}</span><span class="sp"></span>
    <span class="badge">{badge}</span><a class="back" href="index.html">← Inicio</a></div>
  <div class="hero-body"><div class="hero-title">
    <div class="hero-label">{label}</div><h1 class="hero-h1">{h1}</h1>
    <div class="hero-sub">{sub}</div></div>
  <div class="hero-stats">{stats_html}</div></div></div>"""


def page(title, hero_html, body_html, extra_css="", script=""):
    return f"""<!DOCTYPE html><html lang="es"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>{title}</title><style>{BASE_CSS}{extra_css}</style></head><body>
{hero_html}
{body_html}
<script>{script}
{TIP_JS}</script></body></html>"""
