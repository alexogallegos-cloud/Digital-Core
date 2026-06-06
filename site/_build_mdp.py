# -*- coding: utf-8 -*-
"""Build del staging del sitio Digital Core para 05 Modern Data Platform / AI-ready Data /
Data Migration (caso SAP core banking + CRM -> BigQuery medallion).
Copia los deliverables (Fase 1 Discover + Fase 2 Target Design + grafo a escala), convierte
el sign-off del SME a HTML, autora la landing del caso y marca la tarjeta 05 del root como LIVE.
Re-ejecutable. NO hace deploy a AWS (eso es paso aparte).
"""
import os, re, base64, html, shutil, pathlib

ROOT = pathlib.Path(__file__).resolve().parent
DCROOT = pathlib.Path(r"c:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core")
DM = DCROOT / "05 - Modern Data Platform" / "AI-ready Data" / "Data Migration"
F1 = DM / "Fase 1 - Discover & Source Profiling"
F2 = DM / "Fase 2 - Target Design & Data Contracts"
SCALE = DM / "Enablement" / "Training - Reference Data Lab" / "seed-sap-banking-ecc-scale-graph"
LOGO_PNG = DCROOT / "03 - Software & Platform Engineering" / "High Velocity Modernization" / "Mainframe Modernization" / "Fase 1 - Discover" / "Specialist - Reverse Engineering" / "graph-viz" / "vendor" / "Accenture_logo_white_letters.png"

DST = ROOT / "05-modern-data-platform" / "ai-ready-data" / "data-migration"
DST.mkdir(parents=True, exist_ok=True)
LOGO = "data:image/png;base64," + base64.b64encode(LOGO_PNG.read_bytes()).decode()

# 1) copiar deliverables HTML (standalone)
copies = [
    (F1 / "discovery-assessment-scale.html", "discovery-scale.html"),
    (F1 / "discovery-assessment.html",        "discovery-data.html"),
    (F2 / "target-design.html",               "target-design.html"),
    (SCALE / "graph-view.html",               "graph-scale.html"),
    (F1 / "graph-view.html",                  "graph-data.html"),
]
for src, dst in copies:
    if src.exists():
        shutil.copyfile(src, DST / dst)

# 2) sign-off MD -> HTML
def md_inline(s):
    s = html.escape(s)
    s = re.sub(r'`([^`]+)`', r'<code>\1</code>', s)
    s = re.sub(r'\*\*([^*]+)\*\*', r'<strong>\1</strong>', s)
    s = re.sub(r'\[([^\]]+)\]\(([^)]+)\)', r'<a href="\2">\1</a>', s)
    return s

def md_to_html(md):
    out, i, lines = [], 0, md.split("\n")
    while i < len(lines):
        ln = lines[i]
        if re.match(r'^#{1,6}\s', ln):
            n = len(ln) - len(ln.lstrip("#")); out.append("<h%d>%s</h%d>" % (n, md_inline(ln.lstrip('# ').rstrip()), n)); i += 1; continue
        if ln.strip().startswith("|") and i + 1 < len(lines) and re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[i + 1]):
            header = [c.strip() for c in ln.strip().strip("|").split("|")]; i += 2; rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")]); i += 1
            th = "".join("<th>%s</th>" % md_inline(c) for c in header)
            trs = "".join("<tr>" + "".join("<td>%s</td>" % md_inline(c) for c in r) + "</tr>" for r in rows)
            out.append("<table><thead><tr>%s</tr></thead><tbody>%s</tbody></table>" % (th, trs)); continue
        if re.match(r'^\s*[-*]\s', ln):
            items = []
            while i < len(lines) and re.match(r'^\s*[-*]\s', lines[i]):
                items.append("<li>%s</li>" % md_inline(re.sub(r'^\s*[-*]\s', '', lines[i]))); i += 1
            out.append("<ul>" + "".join(items) + "</ul>"); continue
        if ln.startswith(">"):
            out.append("<blockquote>%s</blockquote>" % md_inline(ln.lstrip('> ').rstrip())); i += 1; continue
        if ln.strip() == "---":
            out.append("<hr>"); i += 1; continue
        if ln.strip() == "":
            i += 1; continue
        para = [ln]; i += 1
        while i < len(lines) and lines[i].strip() and not re.match(r'^(#{1,6}\s|\s*\||\s*[-*]\s|>|---)', lines[i]):
            para.append(lines[i]); i += 1
        out.append("<p>%s</p>" % md_inline(" ".join(para)))
    return "\n".join(out)

PAGE = """<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0"><title>{title}</title><style>
 :root{{--purple:#6B21A8;--ink:#1A1A2E;--bg:#f4f4f6;--card:#fff;--line:#dcdce4;--txt:#22222e;--muted:#63636f;--green:#2e7d4f}}
 *{{box-sizing:border-box}}body{{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);line-height:1.55;font-size:15px}}
 header{{background:var(--ink);color:#fff;padding:18px 34px;display:flex;align-items:center;gap:18px;border-bottom:3px solid var(--purple)}}
 header img{{height:26px}}header .t{{font-size:16px;font-weight:600}}
 header a{{margin-left:auto;color:#fff;text-decoration:none;border:1px solid rgba(255,255,255,.45);border-radius:4px;padding:5px 11px;font-size:12px;font-weight:600}}
 main{{max-width:1000px;margin:0 auto;padding:28px 30px 70px}}
 h1{{font-size:22px;color:var(--ink)}}h2{{font-size:18px;color:var(--ink);border-bottom:2px solid var(--line);padding-bottom:6px;margin-top:30px}}
 h3{{font-size:14px;color:var(--purple);text-transform:uppercase;letter-spacing:.4px;margin-top:22px}}
 table{{width:100%;border-collapse:collapse;margin:10px 0;font-size:13.2px;background:var(--card);border:1px solid var(--line)}}
 th,td{{text-align:left;padding:8px 11px;border-bottom:1px solid var(--line);vertical-align:top}}th{{background:#eeeef2;font-size:11.5px;text-transform:uppercase}}
 code{{background:#eeeaf3;color:var(--purple);padding:1px 5px;border-radius:3px;font-size:12.5px;font-family:Consolas,monospace}}
 blockquote{{border-left:3px solid var(--purple);background:#faf7ff;margin:12px 0;padding:8px 14px;color:var(--muted);font-size:13.5px}}
 a{{color:var(--purple)}}hr{{border:none;border-top:1px solid var(--line);margin:24px 0}}
 footer{{text-align:center;color:var(--muted);font-size:11.5px;padding:20px;border-top:1px solid var(--line)}}
</style></head><body>
<header><img src="{logo}" alt="Accenture"><span class="t">{title}</span><a href="index.html">Volver</a></header>
<main>{body}</main>
<footer>Digital Core · Modern Data Platform · AI-ready Data · internal use</footer></body></html>"""

signoff = SCALE / "validation" / "validation-sap-core-banking-signoff.md"
if signoff.exists():
    (DST / "validation-signoff.html").write_text(
        PAGE.format(title="Validación SME — SAP Core Banking", logo=LOGO,
                    body=md_to_html(signoff.read_text(encoding="utf-8"))), encoding="utf-8")

# 3) landing/hub del caso (autorada)
HUB = """<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Data Migration — AI-ready Data — Digital Core</title><style>
 :root{--purple:#6B21A8;--magenta:#A100FF;--ink:#1A1A2E;--bg:#f4f4f6;--card:#fff;--line:#dcdce4;--txt:#22222e;--muted:#63636f;--green:#2e7d4f}
 *{box-sizing:border-box}body{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);line-height:1.55;font-size:15px}
 header{background:var(--ink);color:#fff;padding:22px 38px;display:flex;align-items:center;gap:20px;border-bottom:3px solid var(--purple)}
 header img{height:28px}header .ht h1{margin:0;font-size:20px}header .ht p{margin:3px 0 0;font-size:12px;opacity:.8}
 header .ht{border-left:1px solid rgba(255,255,255,.3);padding-left:20px}
 header a.home{margin-left:auto;color:#fff;text-decoration:none;border:1px solid rgba(255,255,255,.45);border-radius:4px;padding:5px 11px;font-size:12px;font-weight:600}
 main{max-width:1040px;margin:0 auto;padding:30px 30px 70px}
 .intro{color:var(--muted);font-size:14.5px;max-width:840px;margin:0 0 10px}.intro b{color:var(--purple)}
 .note{background:#f3effa;border-left:4px solid var(--magenta);padding:11px 15px;border-radius:6px;font-size:13px;color:var(--txt);margin:14px 0}
 h2{font-size:13px;text-transform:uppercase;letter-spacing:.6px;color:var(--purple);margin:30px 0 12px;border-bottom:1px solid var(--line);padding-bottom:6px}
 .grid{display:grid;gap:16px;grid-template-columns:1fr 1fr}@media(max-width:760px){.grid{grid-template-columns:1fr}}
 a.card{display:block;text-decoration:none;color:inherit;background:var(--card);border:1px solid var(--line);border-left:4px solid var(--magenta);border-radius:5px;padding:16px 18px;transition:.15s}
 a.card:hover{transform:translateY(-2px);box-shadow:0 6px 16px rgba(107,33,168,.12)}
 .card .t{font-size:15.5px;font-weight:600;color:var(--ink);margin:0 0 4px}.card .d{font-size:13px;color:var(--muted);margin:0}
 .phases{display:flex;flex-wrap:wrap;gap:7px;margin:10px 0}
 .ph{font-size:11.5px;padding:4px 10px;border-radius:14px;background:#eee;color:var(--muted)}.ph.live{background:#e3f3ea;color:var(--green);font-weight:600}
 footer{text-align:center;color:var(--muted);font-size:11.5px;padding:22px;border-top:1px solid var(--line)}
</style></head><body>
<header><img src="__LOGO__" alt="Accenture">
<div class="ht"><h1>Data Migration &mdash; SAP Core Banking &rarr; BigQuery</h1><p>05 Modern Data Platform &middot; AI-ready Data &middot; &#9733; Digital Core</p></div>
<a class="home" href="../../../index.html">Digital Core</a></header>
<main>
<p class="intro">Migración de un <b>core bancario sobre SAP ECC</b> (Business Partner, FS-AM Deposits, FS-CML Loans, FI/CO) más un <b>CRM</b>, hacia <b>GCP BigQuery</b> en modelo <b>medallion</b>. El reto estrella: <b>resolución de entidad SAP&harr;CRM</b> (el cliente es la misma entidad en ambos y ningún FK lo declara) y la <b>trampa de decimales por moneda</b> (TCURX).</p>
<div class="note"><b>Datos de referencia, sin IP de cliente.</b> El modelo (~1,500 tablas) fue generado y <b>validado en fidelidad por el SME SAP Banking Services</b> (APROBADO). Material de capacidad / uso interno.</div>

<h2>Ciclo de migración — 8 fases</h2>
<div class="phases">
<span class="ph live">1 · Discover &amp; Source Profiling ✓</span>
<span class="ph live">2 · Target Design &amp; Data Contracts ✓</span>
<span class="ph">3 · Mapping &amp; Transformation Rules</span>
<span class="ph">4 · Ingest &amp; Bronze</span>
<span class="ph">5 · Conform &amp; Silver</span>
<span class="ph">6 · Curate &amp; Gold</span>
<span class="ph">7 · Reconcile &amp; DQ Certification</span>
<span class="ph">8 · Cutover &amp; Decommission</span>
</div>

<h2>Entregables publicados</h2>
<div class="grid">
<a class="card" href="discovery-scale.html"><div class="t">Discovery Assessment &mdash; a escala (~1,500 tablas)</div><div class="d">Topología del data estate: hubs (blast-radius), comunidades por módulo, dead clusters, acoplamiento oculto, wave plan. Fase 1.</div></a>
<a class="card" href="graph-scale.html"><div class="t">Grafo de dependencias &mdash; interactivo</div><div class="d">El hairball de ~1,500 tablas SAP. Click en una tabla &rarr; vecinos y esquema (DDL). Hub T001 con 925 referencias.</div></a>
<a class="card" href="discovery-data.html"><div class="t">Discovery &mdash; nivel dato (DQ + entity resolution)</div><div class="d">DQ baseline, integridad referencial, trampa de moneda, y el crosswalk SAP&harr;CRM sobre datos con filas. Fase 1.</div></a>
<a class="card" href="target-design.html"><div class="t">Target Design &amp; Data Contracts</div><div class="d">Medallion Bronze/Silver/Gold + 5 data contracts por dominio + 4 ADRs (plataforma, patrón, entity resolution, PII). Fase 2.</div></a>
<a class="card" href="validation-signoff.html"><div class="t">Validación de fidelidad &mdash; SME SAP Banking</div><div class="d">Sign-off del SME SAP Banking Services sobre el modelo de referencia (cobertura, hubs, semántica FK, nomenclatura). APROBADO.</div></a>
</div>
</main>
<footer>Digital Core · Modern Data Platform · AI-ready Data · Data Migration · internal use</footer>
</body></html>""".replace("__LOGO__", LOGO)
(DST / "index.html").write_text(HUB, encoding="utf-8")

# 4) marcar tarjeta 05 del root index como LIVE
root_index = ROOT / "index.html"
txt = root_index.read_text(encoding="utf-8")
old_card = '<div class="card soon"><div class="n">05</div><div class="t">Modern Data Platform</div><div class="d">Pipelines · data marts · contracts · semantic layer.</div><span class="badge b-soon">Coming soon</span></div>'
new_card = ('<a class="card" href="05-modern-data-platform/ai-ready-data/data-migration/index.html">'
            '<div class="n">05</div><div class="t">Modern Data Platform</div>'
            '<div class="d">AI-ready Data · Data Migration: SAP core banking + CRM &rarr; BigQuery medallion.</div>'
            '<span class="badge b-live">LIVE — Data Migration</span></a>')
if old_card in txt:
    root_index.write_text(txt.replace(old_card, new_card), encoding="utf-8")
    print("root index.html: tarjeta 05 -> LIVE")
else:
    print("AVISO: tarjeta 05 no encontrada literal (revisar root index.html)")

print("staging MDP construido en:", DST)
for p in sorted(DST.rglob("*")):
    if p.is_file():
        print("  ", p.relative_to(ROOT))