#!/usr/bin/env python3
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
"""
Banamex Gemelo Cognitivo — Mapa de las Almas (Capa 2)
Lee gemelo-{sistema}.json → produce souls-{sistema}.json + souls-{sistema}.html

Code Stylometry + Software Forensics:
  - Autoría declarada (headers, tickets MTP/FSW, INI-FIN comments)
  - Cálculo de bus factor por dominio (concentración de conocimiento)
  - Programas huérfanos (sin autor declarado)
  - Ley de Conway: ¿la organización del equipo fosilizó la arquitectura?

Uso:
  python build-souls.py S500
  python build-souls.py S151
  python build-souls.py S500 S151
"""

import json
import re
import sys
import math
import argparse
from pathlib import Path
from collections import Counter, defaultdict

DATA_DIR = Path(__file__).parent / "data"

# ─── Helpers ──────────────────────────────────────────────────────────────────

def hhi(shares: list[float]) -> float:
    """Herfindahl-Hirschman Index: 0 = dispersed, 1 = monopoly."""
    if not shares:
        return 0.0
    total = sum(shares)
    if total == 0:
        return 0.0
    return sum((s / total) ** 2 for s in shares)

def bus_factor_approx(author_counts: dict[str, int]) -> float:
    """
    Approximate bus factor from HHI.
    bus_factor ≈ 1 / HHI; saturate at 10.
    """
    h = hhi(list(author_counts.values()))
    if h == 0:
        return 10.0
    return min(round(1 / h, 1), 10.0)


def build_souls(sistema: str) -> None:
    gemelo_path = DATA_DIR / sistema / f"gemelo-{sistema.lower()}.json"
    if not gemelo_path.exists():
        print(f"[ERROR] No encontrado: {gemelo_path}  (ejecuta extract.py primero)")
        return

    with open(gemelo_path, encoding="utf-8") as f:
        gemelo = json.load(f)

    print(f"\n{'='*60}")
    print(f"  Capa 2 · Almas — {sistema}")
    print(f"{'='*60}")

    headers = gemelo.get("headers", [])
    objetos = {o["id"]: o for o in gemelo["objetos"]}
    total_objects = len(objetos)

    # ─── Parse authorship ─────────────────────────────────────────────────────
    # author → set of programs they touched
    author_programs: dict[str, set] = defaultdict(set)
    # program → set of authors
    program_authors: dict[str, set] = defaultdict(set)
    # ticket → {author, programa, proyecto}
    ticket_records: list[dict] = []

    for h in headers:
        prog = h.get("objeto", "")
        author = (h.get("autor") or "").strip().upper()
        ticket = (h.get("ticket") or "").strip()
        proyecto = (h.get("proyecto") or "").strip()

        if not author or len(author) < 2:
            continue
        # Filter out non-author strings (COBOL keywords, etc.)
        if re.match(r"^(AUTOR|INI|FIN|FSW|MTP|WFL|BDB|S500|S151)$", author, re.I):
            continue

        author_programs[author].add(prog)
        if prog:
            program_authors[prog].add(author)
        if ticket:
            ticket_records.append({
                "ticket": ticket,
                "autor": author,
                "programa": prog,
                "proyecto": proyecto,
            })

    # ─── Orphans: programs without declared author ─────────────────────────
    authored = set(program_authors.keys())
    orphans = [oid for oid in objetos if oid not in authored
               and objetos[oid]["tipo"] in ("cobol", "algol")]

    print(f"\n  Autoría declarada:")
    print(f"    Autores únicos:           {len(author_programs)}")
    print(f"    Programas con autor:      {len(authored)}")
    print(f"    Programas huérfanos:      {len(orphans)} "
          f"({len(orphans)/total_objects*100:.0f}%)")
    print(f"    Tickets de modificación:  {len(ticket_records)}")

    # ─── Bus factor global ────────────────────────────────────────────────────
    global_author_counts = {a: len(progs) for a, progs in author_programs.items()}
    global_bf = bus_factor_approx(global_author_counts)

    print(f"\n  Bus Factor Global: {global_bf:.1f}")
    print(f"  Top autores por alcance (# programas tocados):")
    for author, progs in sorted(global_author_counts.items(),
                                 key=lambda x: -x[1])[:15]:
        pct = len(author_programs[author]) / total_objects * 100
        print(f"    {author:<20} {len(author_programs[author]):>3} pgms ({pct:.0f}%)")

    # ─── Bus factor por dominio ────────────────────────────────────────────────
    domain_authors: dict[str, Counter] = defaultdict(Counter)
    for prog_id, authors in program_authors.items():
        domain = objetos.get(prog_id, {}).get("dominio", "?")
        for a in authors:
            domain_authors[domain][a] += 1

    print(f"\n  Bus Factor por dominio:")
    domain_bf: dict[str, float] = {}
    for domain, author_cnt in sorted(domain_authors.items()):
        bf = bus_factor_approx(dict(author_cnt))
        domain_bf[domain] = bf
        top = author_cnt.most_common(3)
        top_str = ", ".join(f"{a}({c})" for a, c in top)
        risk = "🔴 ALTO" if bf < 2 else "🟡 MEDIO" if bf < 4 else "🟢 BAJO"
        print(f"    {domain:<20} BF={bf:>4.1f}  {risk}  top: {top_str}")

    # ─── Ticket timeline (Capa 3 signal) ──────────────────────────────────────
    # Deduplicate and sort by ticket number (first 2 digits = year YY)
    if ticket_records:
        print(f"\n  Tickets únicos: {len(set(t['ticket'] for t in ticket_records))}")
        # S151 MTP ticket format: NNMTPxxx → NN = year (relative)
        mtp_tickets = [t for t in ticket_records
                       if re.match(r"\d{2}MTP\d{3}", t["ticket"])]
        if mtp_tickets:
            # Group by YY prefix
            year_groups = defaultdict(list)
            for t in mtp_tickets:
                yy = int(t["ticket"][:2])
                year_groups[yy].append(t)
            print(f"  Épocas de modificación (por prefijo MTP):")
            for yy in sorted(year_groups.keys()):
                n = len(year_groups[yy])
                authors_in_year = {t["autor"] for t in year_groups[yy] if t["autor"]}
                print(f"    '{yy:02d}MTP': {n:>3} tickets  autores: {', '.join(sorted(authors_in_year)[:5])}")

    # ─── Build souls JSON ─────────────────────────────────────────────────────
    souls_data = {
        "meta": {
            "sistema": sistema,
            "capa": 2,
            "descripcion": "Almas — autoría declarada, bus factor, huérfanos",
            "total_autores": len(author_programs),
            "total_programas": total_objects,
            "programas_con_autor": len(authored),
            "programas_huerfanos": len(orphans),
            "bus_factor_global": global_bf,
        },
        "autores": [
            {
                "nombre": a,
                "programas": sorted(author_programs[a]),
                "alcance": len(author_programs[a]),
                "pct_del_sistema": round(len(author_programs[a]) / total_objects * 100, 1),
            }
            for a in sorted(global_author_counts, key=lambda x: -global_author_counts[x])
        ],
        "dominios": [
            {
                "dominio": d,
                "bus_factor": domain_bf.get(d, 0),
                "riesgo": "alto" if domain_bf.get(d, 10) < 2 else
                          "medio" if domain_bf.get(d, 10) < 4 else "bajo",
                "autores": dict(domain_authors[d].most_common()),
            }
            for d in sorted(domain_authors.keys())
        ],
        "huerfanos": sorted(orphans),
        "tickets": ticket_records[:500],  # cap for readability
    }

    # ─── Write JSON ────────────────────────────────────────────────────────────
    out_dir = DATA_DIR / sistema
    souls_json = out_dir / f"souls-{sistema.lower()}.json"
    with open(souls_json, "w", encoding="utf-8") as f:
        json.dump(souls_data, f, ensure_ascii=False, indent=2)
    print(f"\n  [OUTPUT] {souls_json.name}")

    # ─── Write HTML visualization ──────────────────────────────────────────────
    _write_souls_html(sistema, souls_data, out_dir)


def _risk_class(riesgo: str) -> str:
    return {"alto": "r-alta", "medio": "r-media", "bajo": "r-baja"}.get(riesgo, "r-baja")


def _write_souls_html(sistema: str, souls: dict, out_dir: Path) -> None:
    """Generate souls HTML in BanCoppel souls-bcop.html format with Banamex red/gold palette."""
    meta = souls["meta"]
    autores = souls["autores"]
    dominios = souls["dominios"]
    orphans = souls["huerfanos"]

    total = meta["total_programas"]
    con_autor = meta["programas_con_autor"]
    huerfanos_n = meta["programas_huerfanos"]
    bf_global = meta["bus_factor_global"]
    pct_autor = round(con_autor / total * 100) if total else 0
    pct_huerfano = round(huerfanos_n / total * 100) if total else 0

    # ── Autor rows (bar chart style) ─────────────────────────────────────────
    max_alcance = autores[0]["alcance"] if autores else 1
    autor_rows = ""
    for a in autores[:24]:
        pct_bar = round(a["alcance"] / max_alcance * 100)
        autor_rows += (
            f'<div class="row">'
            f'<div class="rn">{a["nombre"]}</div>'
            f'<div class="bar"><i style="width:{pct_bar}%"></i></div>'
            f'<div class="rv">{a["alcance"]}<span> pgms · {a["pct_del_sistema"]:.0f}%</span></div>'
            f'</div>\n'
        )

    # ── Bus factor rows ───────────────────────────────────────────────────────
    dom_rows = ""
    for d in sorted(dominios, key=lambda x: -x["bus_factor"]):
        bf = d["bus_factor"]
        pct_top = 0
        top_str = ""
        if d["autores"]:
            top_items = sorted(d["autores"].items(), key=lambda x: -x[1])
            top_a, top_c = top_items[0]
            total_dom = sum(d["autores"].values())
            pct_top = round(top_c / total_dom * 100) if total_dom else 0
            top_str = f' · {top_a} ({top_c}/{len(d["autores"])} almas)'
        dom_rows += (
            f'<div class="row">'
            f'<div class="rn">{d["dominio"]}</div>'
            f'<div class="bar"><i class="{_risk_class(d["riesgo"])}" style="width:{pct_top}%"></i></div>'
            f'<div class="rv">{bf:.1f} BF<span>{top_str}</span></div>'
            f'</div>\n'
        )

    # ── Orphan chips ──────────────────────────────────────────────────────────
    orphan_chips = "".join(
        f'<span class="chip">{o}</span>' for o in sorted(orphans)
    )

    html = f"""<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>Banamex {sistema} · Mapa de las Almas (Gemelo Cognitivo · Capa 2)</title>
<style>
:root{{--bg:#130407;--bg2:#1a0608;--panel:#220b0e;--line:#4a1a1e;--red:#C1272D;--redd:#8B1520;--gold:#D4A017;--txt:#F0E8E8;--muted:#c4aeb0;--muted2:#9a8082}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,Calibri,sans-serif;line-height:1.5}}
header{{background:linear-gradient(135deg,var(--redd),#5a0d13);border-bottom:3px solid var(--gold);padding:15px 30px;display:flex;align-items:center;gap:14px;position:sticky;top:0;z-index:10}}
header img{{height:24px;filter:drop-shadow(0 1px 2px rgba(0,0,0,.5))}}
header h1{{font-size:16px;font-weight:800}} header .sub{{font-size:10.5px;color:#f0c8cc;margin-top:1px}}
.wrap{{max-width:1080px;margin:0 auto;padding:26px 30px 60px}}
.tiles{{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-bottom:30px}}
@media(max-width:760px){{.tiles{{grid-template-columns:repeat(2,1fr)}}}}
.tile{{background:var(--panel);border:1px solid var(--line);border-top:3px solid var(--gold);border-radius:11px;padding:15px 14px;text-align:center;position:relative}}
.tile[data-tip]{{cursor:help}}
.tile[data-tip]:hover::after{{content:attr(data-tip);position:absolute;left:50%;top:calc(100% + 9px);transform:translateX(-50%);width:240px;background:rgba(13,3,4,.98);border:1px solid var(--line);border-radius:10px;padding:11px 13px;font-size:11px;color:var(--muted);line-height:1.5;z-index:30;box-shadow:0 10px 30px rgba(0,0,0,.6);text-transform:none;letter-spacing:normal;font-weight:400}}
.tile .n{{font-size:26px;font-weight:800;color:#fff}} .tile .l{{font-size:9.5px;color:var(--muted2);margin-top:6px;text-transform:uppercase;letter-spacing:.05em}}
section{{margin-top:28px}}
h2{{font-size:17px;font-weight:800;letter-spacing:-.01em;margin-bottom:4px}}
h2 .k{{font-size:11px;font-weight:700;color:var(--gold);letter-spacing:.14em;text-transform:uppercase;display:block;margin-bottom:5px}}
.sd{{font-size:12.5px;color:var(--muted);margin-bottom:14px;max-width:80ch}}
.panel{{background:var(--panel);border:1px solid var(--line);border-radius:14px;padding:18px 20px}}
.row{{display:grid;grid-template-columns:200px 1fr auto;gap:12px;align-items:center;padding:4px 0;font-size:12.5px}}
@media(max-width:640px){{.row{{grid-template-columns:1fr}}}}
.rn{{color:#f0e0e0;font-weight:600;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}}
.bar{{background:#2a0810;border-radius:6px;height:15px;overflow:hidden}}
.bar i{{display:block;height:100%;background:linear-gradient(90deg,var(--red),#e05060);border-radius:6px}}
.bar i.r-alta{{background:linear-gradient(90deg,var(--gold),#f6d27a)}}
.bar i.r-media{{background:linear-gradient(90deg,#c85040,#e07060)}}
.bar i.r-baja{{background:linear-gradient(90deg,var(--red),#e05060)}}
.rv{{color:var(--muted);font-variant-numeric:tabular-nums;text-align:right;white-space:nowrap}} .rv span{{font-size:10px;color:var(--muted2)}}
.chip{{display:inline-block;background:#2a0810;border:1px solid var(--line);border-radius:20px;padding:5px 12px;font-size:12px;color:var(--muted);margin:0 6px 8px 0}}
.note{{margin-top:22px;padding:15px 18px;font-size:12.5px;color:var(--muted);border-radius:14px;background:rgba(255,255,255,.04);-webkit-backdrop-filter:blur(15px) saturate(140%);backdrop-filter:blur(15px) saturate(140%);box-shadow:0 8px 28px rgba(0,0,0,.3),inset 0 1px 0 rgba(255,255,255,.08);border:1px solid rgba(212,160,23,.18)}} .note b{{color:#f0e0e0}}
.leg{{font-size:11px;color:var(--muted2);margin-top:10px}} .leg i{{display:inline-block;width:10px;height:10px;border-radius:3px;vertical-align:middle;margin:0 4px 0 10px}}
footer{{margin-top:36px;font-size:11px;color:var(--muted2);text-align:center;border-top:1px solid var(--line);padding-top:16px}}
</style></head><body>
<header>
  <img src="../../banamex-logo.svg" alt="Banamex">
  <div><h1>Mapa de las Almas — {sistema}</h1>
  <div class="sub">Gemelo Cognitivo · Capa 2 (memoria social) · SPE-MM-00{"1" if sistema=="S500" else "2"} · quién pensó el código</div></div>
</header>
<div class="wrap">
  <div class="tiles">
    <div class="tile" data-tip="Personas cuyo nombre o código de empleado aparece como autor en los headers del código."><div class="n">{meta['total_autores']}</div><div class="l">Autores identificados</div></div>
    <div class="tile" data-tip="% de programas COBOL/ALGOL cuyo header declara quién lo escribió. El resto es código huérfano."><div class="n">{pct_autor}%</div><div class="l">Autoría declarada</div></div>
    <div class="tile" data-tip="Bus Factor global: cuántas personas habría que perder para que el conocimiento del sistema quede en riesgo crítico. Calculado via HHI."><div class="n">{bf_global:.1f}</div><div class="l">Bus Factor global</div></div>
    <div class="tile" data-tip="Programas con al menos un autor declarado en el header del código."><div class="n">{con_autor}</div><div class="l">Pgms con autor</div></div>
    <div class="tile" data-tip="% de programas SIN autor declarado. No es sin dueño — es sin dueño declarado: máximo riesgo de pérdida de conocimiento."><div class="n">{pct_huerfano}%</div><div class="l">Programas huérfanos</div></div>
  </div>

  <section><h2><span class="k">Censo</span>Las almas que tocaron el código</h2>
    <div class="sd">Autores con más programas firmados en los headers. Cada barra = número relativo de programas con su huella.</div>
    <div class="panel">{autor_rows}</div>
  </section>

  <section><h2><span class="k">Bus factor</span>Concentración de conocimiento por dominio</h2>
    <div class="sd">Qué tan concentrado está el conocimiento: bus factor por dominio. Dorado = alta concentración (riesgo si esa persona ya no está).</div>
    <div class="panel">{dom_rows}
      <div class="leg"><i style="background:#f6d27a"></i>alta conc.<i style="background:#e07060"></i>media<i style="background:#e05060"></i>baja (BF alto)</div></div>
  </section>

  <section><h2><span class="k">Huérfanos ({len(orphans)})</span>Programas sin autor declarado</h2>
    <div class="sd">Programas COBOL/ALGOL sin dueño declarado en el código. No significa sin dueño — significa máximo riesgo de pérdida de conocimiento tácito.</div>
    <div class="panel">{orphan_chips or '<span class="chip">Ninguno detectado</span>'}</div>
  </section>

  <div class="note"><b>Honestidad de la capa.</b> Reconstruida de <b>autoría declarada</b> en headers del código fuente — no de historia de Git (inexistente para este mainframe). {"S500 usa iniciales de autor (ABARBOSA, JEP, PCB…)." if sistema=="S500" else "S151 usa códigos de empleado de 6 dígitos (148210, 265520…) — rastro del proceso de cambio formal bancario auditado."} El código huérfano no significa sin dueño: significa <b>sin dueño declarado</b> — máximo riesgo de pérdida de conocimiento tácito.</div>
  <footer>Gemelo Cognitivo · Capa 2 · Mapa de las Almas · generado por <code>build-souls.py</code> desde {meta['total_programas']} archivos fuente · Banamex {sistema} · Unisys ClearPath MCP</footer>
</div></body></html>"""

    souls_html = out_dir / f"souls-{sistema.lower()}.html"
    souls_html.write_text(html, encoding="utf-8")
    print(f"  [OUTPUT] {souls_html.name}")


def main():
    parser = argparse.ArgumentParser(
        description="Banamex Gemelo Cognitivo — Mapa de las Almas Capa 2"
    )
    parser.add_argument("sistemas", nargs="+", choices=["S500", "S151"])
    args = parser.parse_args()
    for s in args.sistemas:
        build_souls(s)


if __name__ == "__main__":
    main()