"""
build-portal.py — Genera santander-brain/portal/index.html
Diseño: Santander Design Studio v1.0 (dark, red aurora, glass cards)
NUNCA editar portal/*.html a mano — este script es la fuente de verdad.

Uso:
    python build-portal.py
"""
import sqlite3
import sys
import os
from pathlib import Path
from datetime import datetime

BASE_DIR    = Path(__file__).parent.parent
BRAIN_DB    = BASE_DIR / "santander-brain.db"
PORTAL_DIR  = BASE_DIR / "portal"
OUTPUT_HTML = PORTAL_DIR / "index.html"
LOGO_PATH   = "../../design-studio/logos/Banco_Santander_Logotipo.svg.webp"

PORTAL_DIR.mkdir(exist_ok=True)


def load_data() -> dict:
    if not BRAIN_DB.exists():
        raise FileNotFoundError(f"Brain DB no encontrado: {BRAIN_DB}\nEjecuta: python build-santander-brain.py")
    conn = sqlite3.connect(BRAIN_DB)
    conn.row_factory = sqlite3.Row
    meta    = {r["key"]: r["value"] for r in conn.execute("SELECT key, value FROM brain_meta")}
    systems = [dict(r) for r in conn.execute(
        "SELECT slug, display_name, real_name, category, status, brain_attached, note FROM systems ORDER BY category, slug")]
    vocab   = [dict(r) for r in conn.execute("SELECT term, domain, en FROM vocab ORDER BY domain, term")]
    market  = [dict(r) for r in conn.execute("SELECT category, date, title, body FROM market_intel ORDER BY category")]
    opps    = [dict(r) for r in conn.execute("SELECT area, title, description, priority FROM opportunities ORDER BY priority")]
    conn.close()
    return {"meta": meta, "systems": systems, "vocab": vocab, "market": market, "opportunities": opps}


CAT_LABELS = {
    "core": "Core Banking", "processors": "Processors",
    "channels": "Canales", "integration": "Integración",
    "data": "Datos y Analítica", "compliance": "Compliance y Corporativo",
}
CAT_ICONS = {
    "core": "🏦", "processors": "⚙️", "channels": "📱",
    "integration": "🔗", "data": "📊", "compliance": "🛡️",
}
STATUS_CSS = {
    "confirmed": "ok", "confirmed-name": "ok",
    "scaffold": "", "partial": "warn", "deprecated": "crit",
}
STATUS_LABEL = {
    "confirmed": "Confirmado", "confirmed-name": "Confirmado",
    "scaffold": "Scaffold", "partial": "Parcial", "deprecated": "Deprecado",
}
PRIO_CSS = {"ALTA": "red", "MEDIA": "yellow", "BAJA": "green"}


def generate_html(data: dict) -> str:
    now  = datetime.now().strftime("%Y-%m-%d %H:%M")
    meta = data["meta"]
    ver  = meta.get("version", "1.0")

    total   = len(data["systems"])
    conf    = sum(1 for s in data["systems"] if "confirmed" in s["status"])
    scaff   = sum(1 for s in data["systems"] if s["status"] == "scaffold")
    vocab_n = len(data["vocab"])

    # Landscape — cardgrid por categoría
    cat_order = ["core", "processors", "channels", "integration", "data", "compliance"]
    systems_by_cat = {}
    for s in data["systems"]:
        systems_by_cat.setdefault(s["category"], []).append(s)

    landscape_html = ""
    for cat in cat_order:
        rows = systems_by_cat.get(cat, [])
        if not rows:
            continue
        cards = ""
        for s in rows:
            css   = STATUS_CSS.get(s["status"], "")
            slbl  = STATUS_LABEL.get(s["status"], s["status"])
            brain = "● Brain activo" if s["brain_attached"] else "○ Sin brain"
            nota  = s["note"][:90] + ("…" if len(s["note"]) > 90 else "")
            cards += f"""
            <div class="vcard glass {css}" style="display:flex;gap:15px;padding:20px;text-decoration:none">
              <div class="ico" style="font-size:20px;width:46px;height:46px;display:flex;align-items:center;justify-content:center;border-radius:12px;flex-shrink:0;background:rgba(255,255,255,.08);border:1px solid rgba(255,255,255,.10)">{CAT_ICONS.get(cat,'○')}</div>
              <div>
                <div class="vtag {css}">{slbl}</div>
                <div class="vt">{s['display_name']}</div>
                <div class="vd">{nota}</div>
                <div style="font-size:10.5px;color:var(--muted2)">{s['real_name']} &nbsp;·&nbsp; {brain}</div>
              </div>
            </div>"""
        landscape_html += f"""
        <div class="group reveal">
          <div class="ghead">
            <h3>{CAT_ICONS.get(cat,'')} {CAT_LABELS.get(cat, cat)}</h3>
            <span>{len(rows)} sistemas</span>
          </div>
          <div class="cardgrid">{cards}</div>
        </div>"""

    # Inteligencia de mercado
    market_html = ""
    for m in data["market"][:8]:
        market_html += f"""
        <div class="xcard glass">
          <div class="xkick">{m['category']} · {m['date']}</div>
          <div class="xt">{m['title'][:60]}{'…' if len(m['title'])>60 else ''}</div>
          <div class="xd">{m['body'][:140]}{'…' if len(m['body'])>140 else ''}</div>
        </div>"""

    # Oportunidades
    opp_html = ""
    for o in data["opportunities"]:
        css = PRIO_CSS.get(o["priority"], "")
        opp_html += f"""
        <div class="mcard glass">
          <h4>{o['area']} <span class="chip {css}" style="vertical-align:middle">{o['priority']}</span></h4>
          <p><b style="color:#fff">{o['title']}</b></p>
          <p style="margin-top:6px">{o['description'][:110]}{'…' if len(o['description'])>110 else ''}</p>
        </div>"""

    # Vocab muestra
    dom_vocab = {}
    for v in data["vocab"]:
        dom_vocab.setdefault(v["domain"], []).append(v["term"])
    vocab_chips = "".join(
        f'<span class="chip">{t}</span>'
        for terms in list(dom_vocab.values())[:10]
        for t in terms[:3]
    )

    return f"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Santander México — Digital Brain</title>
<style>
*{{box-sizing:border-box;margin:0;padding:0}}
:root{{--red:#EC0000;--redd:#CC0000;--reddd:#9A0000;--redglow:rgba(236,0,0,.55);
  --ink:#FFF5F5;--muted:#d4aaaa;--muted2:#a07878;
  --glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.09)}}
html{{scroll-behavior:smooth}}
body{{background:#0d0202;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',Calibri,sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}}
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden}}
.aurora::before,.aurora::after,.aurora .blob{{content:"";position:absolute;border-radius:50%;filter:blur(90px)}}
.aurora::before{{width:62vw;height:62vw;left:-12vw;top:-16vw;background:radial-gradient(circle,rgba(200,0,0,.50),transparent 70%);animation:f1 24s ease-in-out infinite}}
.aurora::after{{width:56vw;height:56vw;right:-14vw;top:6vw;background:radial-gradient(circle,rgba(130,0,0,.55),transparent 70%);animation:f2 28s ease-in-out infinite}}
.aurora .blob{{width:40vw;height:40vw;left:34vw;bottom:-14vw;background:radial-gradient(circle,rgba(236,0,0,.18),transparent 70%);animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}
#prog{{position:fixed;top:0;left:0;height:3px;width:0;z-index:100;background:linear-gradient(90deg,var(--red),#ff8888);box-shadow:0 0 12px var(--redglow)}}
nav{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:14px;padding:15px 30px;backdrop-filter:blur(18px) saturate(150%);-webkit-backdrop-filter:blur(18px) saturate(150%);background:rgba(13,2,2,.60);border-bottom:1px solid rgba(255,255,255,.06)}}
nav img{{height:22px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
nav .nt{{font-size:12.5px;font-weight:600;color:var(--muted);letter-spacing:.01em}}
nav .sp{{flex:1}}
nav a{{font-size:12.5px;color:var(--muted);padding:7px 13px;border-radius:20px;transition:.22s;text-decoration:none}}
nav a:hover{{color:var(--ink);background:rgba(255,255,255,.07)}}
nav a.ext{{color:var(--red)}}nav a.ext:hover{{color:#ff8888}}
.glass{{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.40),inset 0 1px 0 rgba(255,255,255,.08)}}
.wrap{{max-width:1160px;margin:0 auto;padding:0 30px}}
section{{padding:76px 0;scroll-margin-top:70px}}
.hero{{min-height:52vh;display:flex;flex-direction:column;justify-content:center;position:relative;padding:110px 0 20px}}
.eyebrow{{display:inline-flex;align-items:center;gap:9px;align-self:flex-start;padding:8px 16px;border-radius:30px;font-size:12px;font-weight:600;letter-spacing:.03em;color:#ffd5d5;margin-bottom:28px;background:rgba(236,0,0,.08);border:1px solid rgba(236,0,0,.20);backdrop-filter:blur(10px)}}
.eyebrow .dot{{width:7px;height:7px;border-radius:50%;background:var(--red);box-shadow:0 0 12px var(--redglow);animation:pulse 2.4s infinite}}
@keyframes pulse{{50%{{opacity:.4}}}}
.hero h1{{font-size:clamp(38px,6vw,76px);font-weight:800;line-height:1.0;letter-spacing:-.035em;max-width:20ch;background:linear-gradient(176deg,#fff 34%,#ff9999);-webkit-background-clip:text;background-clip:text;color:transparent}}
.hero .sub{{font-size:clamp(15px,1.7vw,19px);color:var(--muted);margin-top:22px;max-width:66ch;line-height:1.55}}
.hero .sub b{{color:#ffe0e0;font-weight:600}}
.stats{{display:grid;grid-template-columns:repeat(4,1fr);gap:13px;margin-top:36px}}
.stat{{padding:20px 14px;text-align:center}}
.statn{{font-size:clamp(22px,2.7vw,32px);font-weight:800;letter-spacing:-.02em;font-variant-numeric:tabular-nums;background:linear-gradient(180deg,#fff,#ffb0b0);-webkit-background-clip:text;background-clip:text;color:transparent}}
.statl{{font-size:10px;color:var(--muted2);margin-top:8px;text-transform:uppercase;letter-spacing:.06em;font-weight:600}}
.shead{{margin-bottom:36px}}
.kick{{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--red);margin-bottom:14px}}
.shead h2{{font-size:clamp(26px,3.8vw,42px);font-weight:800;letter-spacing:-.025em;line-height:1.06}}
.shead p{{color:var(--muted);font-size:15px;margin-top:14px;max-width:72ch;line-height:1.55}}
.group{{margin-top:46px}}
.ghead{{display:flex;align-items:baseline;gap:14px;margin-bottom:18px}}
.ghead h3{{font-size:20px;font-weight:800;letter-spacing:-.02em}}
.ghead span{{font-size:13px;color:var(--muted2)}}
.cardgrid{{display:grid;grid-template-columns:repeat(3,1fr);gap:16px}}
@media(max-width:960px){{.cardgrid{{grid-template-columns:repeat(2,1fr)}}}}
@media(max-width:600px){{.cardgrid{{grid-template-columns:1fr}}}}
.vcard{{transition:transform .34s cubic-bezier(.16,1,.3,1),border-color .34s,box-shadow .34s}}
.vcard:hover{{transform:translateY(-5px);box-shadow:0 22px 56px rgba(0,0,0,.5)}}
.vcard .vt{{font-size:15px;font-weight:800;letter-spacing:-.01em;margin-top:4px}}
.vcard .vd{{font-size:12.5px;color:var(--muted);margin:5px 0 8px;line-height:1.5}}
.vcard .vtag{{display:inline-block;font-size:9.5px;font-weight:700;letter-spacing:.09em;text-transform:uppercase;padding:2px 7px;border-radius:10px;background:rgba(236,0,0,.12);border:1px solid rgba(236,0,0,.28);color:var(--red);margin-bottom:6px}}
.vcard.crit{{border-left:3px solid #E8400A}}.vcard.crit .vtag{{color:#E8400A;background:rgba(232,64,10,.12);border-color:rgba(232,64,10,.3)}}
.vcard.warn{{border-left:3px solid var(--red)}}
.vcard.ok{{border-left:3px solid #22c55e}}.vcard.ok .vtag{{color:#22c55e;background:rgba(34,197,94,.12);border-color:rgba(34,197,94,.3)}}
.xrow{{display:grid;grid-template-columns:1fr 1fr;gap:15px}}
@media(max-width:760px){{.xrow{{grid-template-columns:1fr}}}}
.xcard{{padding:20px 24px;border-left:3px solid var(--red)}}
.xkick{{font-size:10px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;color:var(--red);margin-bottom:8px}}
.xt{{font-size:15px;font-weight:800}}
.xd{{font-size:12.5px;color:var(--muted);margin-top:7px;line-height:1.6}}
.mgrid{{display:grid;grid-template-columns:1fr 1fr;gap:15px}}
@media(max-width:860px){{.mgrid{{grid-template-columns:1fr}}}}
.mcard{{padding:22px 24px}}
.mcard h4{{font-size:11px;color:var(--red);text-transform:uppercase;letter-spacing:.1em;margin-bottom:10px;font-weight:700}}
.mcard p{{font-size:13px;color:var(--muted);line-height:1.6}}
.chip{{display:inline-block;font-size:10px;font-weight:700;padding:3px 9px;border-radius:12px;border:1px solid rgba(255,255,255,.12);background:rgba(255,255,255,.06);color:var(--muted);margin:2px 3px 2px 0;letter-spacing:.04em}}
.chip.red{{border-color:rgba(236,0,0,.35);color:#ff8888;background:rgba(236,0,0,.10)}}
.chip.yellow{{border-color:rgba(255,180,0,.35);color:#ffd666;background:rgba(255,180,0,.09)}}
.chip.green{{border-color:rgba(34,197,94,.35);color:#86efac;background:rgba(34,197,94,.09)}}
.reveal{{opacity:0;transform:translateY(32px);transition:opacity .9s cubic-bezier(.16,1,.3,1),transform .9s cubic-bezier(.16,1,.3,1)}}
.reveal.in{{opacity:1;transform:none}}
footer{{padding:44px 30px 64px;text-align:center;color:var(--muted2);font-size:12px;border-top:1px solid rgba(255,255,255,.06);margin-top:50px;line-height:1.7}}
code{{background:rgba(236,0,0,.10);border:1px solid rgba(236,0,0,.20);border-radius:5px;padding:2px 7px;font-size:11px;font-family:'SF Mono',ui-monospace,monospace;color:#ffaaaa}}
@media(max-width:1100px){{.stats{{grid-template-columns:repeat(2,1fr)}}}}
@media(max-width:560px){{nav .nt{{display:none}}}}
@media(prefers-reduced-motion:reduce){{.reveal{{transition:none;opacity:1;transform:none}}.aurora *{{animation:none}}}}
</style></head><body>
<div class="aurora"><div class="blob"></div></div><div class="grain"></div>
<div id="prog"></div>

<nav>
  <img src="{LOGO_PATH}" alt="Santander" onerror="this.style.display='none'">
  <span class="nt">Santander México · Digital Brain</span>
  <span class="sp"></span>
  <a href="#landscape">Landscape</a>
  <a href="#mercado">Mercado</a>
  <a href="#oportunidades">Oportunidades</a>
  <a class="ext" href="../projects/can/portal/index.html">CAN Compliance →</a>
</nav>

<div class="wrap">

  <header class="hero">
    <div class="eyebrow reveal"><span class="dot"></span> Santander México · Cerebro Federado · v{ver} · {datetime.now().strftime('%Y-%m-%d')}</div>
    <h1 class="reveal">Digital Brain<br>Santander México</h1>
    <p class="sub reveal">Mapa vivo del landscape tecnológico de <b>Banco Santander México</b>. Top 5 por activos (~$1.5T MXN), ~17M clientes, regulación CNBV, Banxico y UIF. Fase DISCOVER activa — proyecto <b>CAN</b> en curso.</p>
    <div class="stats reveal">
      <div class="stat glass"><div class="statn" data-target="{total}">0</div><div class="statl">Sistemas registrados</div></div>
      <div class="stat glass"><div class="statn" data-target="{conf}">0</div><div class="statl">Confirmados</div></div>
      <div class="stat glass"><div class="statn" data-target="{scaff}">0</div><div class="statl">Scaffold</div></div>
      <div class="stat glass"><div class="statn" data-target="{vocab_n}">0</div><div class="statl">Términos vocab</div></div>
    </div>
  </header>

  <section id="landscape">
    <div class="shead reveal">
      <div class="kick">Landscape Tecnológico</div>
      <h2>Sistemas de Santander México</h2>
      <p>Mapa TOGAF del estado tecnológico AS-IS. Los sistemas <span class="chip green">Confirmados</span> tienen fuente pública verificada. Los <span class="chip">Scaffold</span> son hipótesis técnicas basadas en el patrón de un banco global de esta escala — requieren confirmación en discovery.</p>
    </div>
    {landscape_html}
  </section>

  <section id="mercado">
    <div class="shead reveal">
      <div class="kick">Inteligencia de Mercado</div>
      <h2>Contexto bancario México</h2>
      <p>Señales de mercado, regulación y competencia relevantes para el programa de modernización Santander.</p>
    </div>
    <div class="xrow reveal">
      {market_html}
    </div>
  </section>

  <section id="oportunidades">
    <div class="shead reveal">
      <div class="kick">Pipeline Accenture</div>
      <h2>Oportunidades identificadas</h2>
      <p>Áreas de intervención Accenture derivadas del landscape actual y del proyecto CAN.</p>
    </div>
    <div class="mgrid reveal">
      {opp_html}
    </div>

    <div class="shead reveal" style="margin-top:60px">
      <div class="kick">Proyectos Activos</div>
      <h2>Change portfolio en curso</h2>
    </div>
    <div class="cardgrid reveal">
      <a class="vcard glass warn" href="../projects/can/portal/index.html" style="text-decoration:none">
        <div style="font-size:24px;width:50px;height:50px;display:flex;align-items:center;justify-content:center;border-radius:14px;flex-shrink:0;background:rgba(236,0,0,.12);border:1px solid rgba(236,0,0,.25)">⚖️</div>
        <div>
          <div class="vtag">DISCOVER + DESIGN</div>
          <div class="vt">CAN — Créditos Asociados a Nómina</div>
          <div class="vd">Cumplimiento regulatorio Banxico. 23 obligaciones, 7 brechas críticas, arquitectura CECOBAN REST+Kafka confirmada.</div>
          <div style="font-size:12px;font-weight:700;color:var(--red)">Ver dashboard CAN <span style="display:inline-block;transition:transform .3s">→</span></div>
        </div>
      </a>
    </div>
  </section>

  <footer>
    Santander Digital Brain · Accenture Application Modernization · <code>v{ver}</code> · {now}<br>
    Generado automáticamente desde <code>santander-brain.db</code> · No editar este archivo directamente
  </footer>

</div>

<script>
window.addEventListener('scroll',()=>{{
  const d=document.documentElement;
  document.getElementById('prog').style.width=(d.scrollTop/(d.scrollHeight-d.clientHeight)*100)+'%';
}});
const statEls=document.querySelectorAll('.statn[data-target]');
const sObs=new IntersectionObserver(entries=>{{
  entries.forEach(e=>{{
    if(!e.isIntersecting)return;
    const el=e.target,target=+el.dataset.target;
    let v=0;const step=Math.max(1,target/60);
    const t=setInterval(()=>{{v=Math.min(v+step,target);el.textContent=Math.floor(v).toLocaleString('es-MX');if(v>=target)clearInterval(t);}},16);
    sObs.unobserve(el);
  }});
}},{{threshold:.3}});
statEls.forEach(s=>sObs.observe(s));
const revs=document.querySelectorAll('.reveal');
const rObs=new IntersectionObserver(entries=>{{
  entries.forEach(e=>{{if(e.isIntersecting){{e.target.classList.add('in');rObs.unobserve(e.target);}}}});
}},{{threshold:.08}});
revs.forEach(r=>rObs.observe(r));
</script>
</body></html>"""


def main():
    print("[build-portal] Generando santander-brain/portal/index.html...")
    data = load_data()
    html = generate_html(data)
    OUTPUT_HTML.write_text(html, encoding="utf-8")
    print(f"[build-portal] OK → {OUTPUT_HTML}")
    if "--open" in sys.argv:
        import webbrowser
        webbrowser.open(OUTPUT_HTML.as_uri())


if __name__ == "__main__":
    main()
