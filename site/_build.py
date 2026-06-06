# -*- coding: utf-8 -*-
"""Build del staging del sitio Digital Core a partir de los entregables del RE specialist.
Mecánica: crea estructura, copia grafos, reescribe enlaces relativos, convierte MD->HTML, copia CSV.
Las landing pages (DC root, MM hub) se escriben aparte. Re-ejecutable."""
import os, re, base64, html, shutil, pathlib, subprocess, sys

ROOT = pathlib.Path(__file__).resolve().parent                      # .../Digital Core/site
SRC  = pathlib.Path(r"c:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - Software & Platform Engineering\High Velocity Modernization\Mainframe Modernization\Fase 1 - Discover\Specialist - Reverse Engineering")
RE   = ROOT / "03-software-platform-engineering" / "high-velocity-modernization" / "mainframe-modernization" / "reverse-engineering"
GRAPHS = RE / "graphs"
GRAPHS.mkdir(parents=True, exist_ok=True)

LOGO = "data:image/png;base64," + base64.b64encode((SRC/"graph-viz"/"vendor"/"Accenture_logo_white_letters.png").read_bytes()).decode()

# --- mapa de reescritura de enlaces (rutas viejas -> rutas del sitio) ---
LINKS = {
  "../../Enablement/Training%20-%20Synthetic%20Codebase%20Lab/seed-corebank-unisys/graph-view.html": "graphs/truth.html",
  "benchmark/benchmark-corebank-unisys.md": "benchmark.html",
  "benchmark/reconstructed/graph-view.augmented.html": "graphs/augmented.html",
  "benchmark/reconstructed/graph-view.reconstructed.html": "graphs/blind.html",
  "benchmark/reconstructed/hitl-adjudicacion.csv": "hitl-adjudication.csv",
  "discovery-assessment-corebank-unisys.html": "discovery-assessment.html",
  "handoff-discover-to-regulatory.md": "handoff-discover-to-regulatory.html",
  "metodologia-reverse-engineering.html": "methodology.html",
}

# 1) grafos (standalone, sin enlaces internos) -> graphs/
MM = SRC.parent.parent   # .../Mainframe Modernization
shutil.copyfile(MM / "Enablement" / "Training - Synthetic Codebase Lab" / "seed-corebank-unisys" / "graph-view.html", GRAPHS/"truth.html")
shutil.copyfile(SRC/"benchmark"/"reconstructed"/"graph-view.reconstructed.html", GRAPHS/"blind.html")
shutil.copyfile(SRC/"benchmark"/"reconstructed"/"graph-view.augmented.html", GRAPHS/"augmented.html")

# 1b) inyectar el FILTRO POR WAVE DE MIGRACION (mismo patrón que el grafo de datos).
# Las waves se computan del grafo canónico (corebank: domain/access/layer reales) y se
# inyectan en los 3 grafos (comparten node ids). NO edita el renderer.
CANON = MM / "Enablement" / "Training - Synthetic Codebase Lab" / "seed-corebank-unisys" / "graph" / "dependency-graph.json"
INJ   = SRC / "graph-viz" / "inject_waves.py"
for h in ["truth.html", "blind.html", "augmented.html"]:
    subprocess.run([sys.executable, str(INJ), str(CANON), str(GRAPHS / h)], check=True)

# 2) HTMLs con enlaces -> reescribir
def rewrite(text):
    for old, new in LINKS.items():
        text = text.replace('href="'+old+'"', 'href="'+new+'"')
    return text
for src_name, dst_name in [("index.html","index.html"),
                           ("metodologia-reverse-engineering.html","methodology.html"),
                           ("discovery-assessment-corebank-unisys.html","discovery-assessment.html")]:
    (RE/dst_name).write_text(rewrite((SRC/src_name).read_text(encoding="utf-8")), encoding="utf-8")

# 3) CSV
shutil.copyfile(SRC/"benchmark"/"reconstructed"/"hitl-adjudicacion.csv", RE/"hitl-adjudication.csv")

# 4) MD -> HTML (convertidor mínimo: headings, tablas, code fences, listas, bold, inline code, links, hr, blockquote)
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
        if ln.startswith("```"):
            i += 1; buf = []
            while i < len(lines) and not lines[i].startswith("```"):
                buf.append(html.escape(lines[i])); i += 1
            i += 1; out.append("<pre class='code'>"+"\n".join(buf)+"</pre>"); continue
        if re.match(r'^#{1,6}\s', ln):
            n = len(ln) - len(ln.lstrip("#")); out.append(f"<h{n}>{md_inline(ln.lstrip('# ').rstrip())}</h{n}>"); i += 1; continue
        if ln.strip().startswith("|") and i+1 < len(lines) and re.match(r'^\s*\|[\s:|-]+\|\s*$', lines[i+1]):
            header = [c.strip() for c in ln.strip().strip("|").split("|")]
            i += 2; rows = []
            while i < len(lines) and lines[i].strip().startswith("|"):
                rows.append([c.strip() for c in lines[i].strip().strip("|").split("|")]); i += 1
            th = "".join(f"<th>{md_inline(c)}</th>" for c in header)
            trs = "".join("<tr>"+"".join(f"<td>{md_inline(c)}</td>" for c in r)+"</tr>" for r in rows)
            out.append(f"<table><thead><tr>{th}</tr></thead><tbody>{trs}</tbody></table>"); continue
        if re.match(r'^\s*[-*]\s', ln):
            items = []
            while i < len(lines) and re.match(r'^\s*[-*]\s', lines[i]):
                items.append(f"<li>{md_inline(re.sub(r'^\\s*[-*]\\s','',lines[i]))}</li>"); i += 1
            out.append("<ul>"+"".join(items)+"</ul>"); continue
        if re.match(r'^\s*\d+\.\s', ln):
            items = []
            while i < len(lines) and re.match(r'^\s*\d+\.\s', lines[i]):
                items.append(f"<li>{md_inline(re.sub(r'^\\s*\\d+\\.\\s','',lines[i]))}</li>"); i += 1
            out.append("<ol>"+"".join(items)+"</ol>"); continue
        if ln.startswith(">"):
            out.append(f"<blockquote>{md_inline(ln.lstrip('> ').rstrip())}</blockquote>"); i += 1; continue
        if ln.strip() == "---":
            out.append("<hr>"); i += 1; continue
        if ln.strip() == "":
            i += 1; continue
        para = [ln]; i += 1
        while i < len(lines) and lines[i].strip() and not re.match(r'^(#{1,6}\s|```|\s*\||\s*[-*]\s|\s*\d+\.\s|>|---)', lines[i]):
            para.append(lines[i]); i += 1
        out.append("<p>"+md_inline(" ".join(para))+"</p>")
    return "\n".join(out)

PAGE = """<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0"><title>{title}</title>
<style>
 :root{{--purple:#6B21A8;--ink:#1A1A2E;--bg:#f4f4f6;--card:#fff;--line:#dcdce4;--txt:#22222e;--muted:#63636f;--green:#2e7d4f}}
 *{{box-sizing:border-box}} body{{margin:0;font-family:'Segoe UI',Roboto,Arial,sans-serif;background:var(--bg);color:var(--txt);line-height:1.55;font-size:15px}}
 header{{background:var(--ink);color:#fff;padding:18px 34px;display:flex;align-items:center;gap:18px;border-bottom:3px solid var(--purple)}}
 header img{{height:26px}} header .t{{font-size:16px;font-weight:600}}
 header a{{margin-left:auto;color:#fff;text-decoration:none;border:1px solid rgba(255,255,255,.45);border-radius:4px;padding:5px 11px;font-size:12px;font-weight:600}}
 main{{max-width:1000px;margin:0 auto;padding:28px 30px 70px}}
 h1{{font-size:22px;color:var(--ink)}} h2{{font-size:18px;color:var(--ink);border-bottom:2px solid var(--line);padding-bottom:6px;margin-top:30px}}
 h3{{font-size:14px;color:var(--purple);text-transform:uppercase;letter-spacing:.4px;margin-top:22px}}
 table{{width:100%;border-collapse:collapse;margin:10px 0;font-size:13.2px;background:var(--card);border:1px solid var(--line)}}
 th,td{{text-align:left;padding:8px 11px;border-bottom:1px solid var(--line);vertical-align:top}} th{{background:#eeeef2;font-size:11.5px;text-transform:uppercase;letter-spacing:.3px}}
 code{{background:#eeeaf3;color:var(--purple);padding:1px 5px;border-radius:3px;font-size:12.5px;font-family:Consolas,monospace}}
 pre.code{{background:#0b0b16;color:#cfe3ff;padding:14px 16px;border-radius:8px;overflow:auto;font-family:Consolas,monospace;font-size:12.5px;line-height:1.45}}
 pre.code code{{background:none;color:inherit;padding:0}}
 blockquote{{border-left:3px solid var(--purple);background:#faf7ff;margin:12px 0;padding:8px 14px;color:var(--muted);font-size:13.5px}}
 a{{color:var(--purple)}} hr{{border:none;border-top:1px solid var(--line);margin:24px 0}}
 footer{{text-align:center;color:var(--muted);font-size:11.5px;padding:20px;border-top:1px solid var(--line)}}
</style></head><body>
<header><img src="{logo}" alt="Accenture"><span class="t">{title}</span><a href="index.html">Home</a></header>
<main>{body}</main>
<footer>Digital Core · Reverse Engineering · internal use</footer></body></html>"""

for md_name, out_name, title in [("benchmark/benchmark-corebank-unisys.md","benchmark.html","Benchmark — SISTEMA-CORE-UNISYS"),
                                 ("handoff-discover-to-regulatory.md","handoff-discover-to-regulatory.html","Handoff — Discover → Regulatory")]:
    body = md_to_html((SRC/md_name).read_text(encoding="utf-8"))
    (RE/out_name).write_text(PAGE.format(title=title, logo=LOGO, body=body), encoding="utf-8")

# crear carpetas vacías de los otros offerings (para que crezca)
for off in ["01-ts-t","02-ai-enabled-enterprise","04-intelligent-infrastructure","05-modern-data-platform","06-innovation","07-ams-reinvention"]:
    (ROOT/off).mkdir(exist_ok=True)
(ROOT/"03-software-platform-engineering").mkdir(exist_ok=True)

print("staging construido en:", ROOT)
print("archivos en reverse-engineering/:")
for p in sorted(RE.rglob("*")):
    if p.is_file(): print("  ", p.relative_to(ROOT))