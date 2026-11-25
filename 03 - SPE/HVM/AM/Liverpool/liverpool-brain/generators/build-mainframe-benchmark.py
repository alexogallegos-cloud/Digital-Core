#!/usr/bin/env python3
"""
Liverpool — Vista del benchmark de modernización del mainframe.

Renderiza portal/benchmark-mainframe-liv.html desde las tablas mf_benchmark_*.
La vista no contiene datos: todo sale del brain.

    PYTHONUTF8=1 python generators/build-mainframe-benchmark.py
"""
import sqlite3
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from _liv_shared import hero, page, stat  # noqa: E402

BRAIN = Path(__file__).parent.parent / "liverpool-brain.db"
OUT = Path(__file__).parent.parent / "portal" / "benchmark-mainframe-liv.html"

AXIS_MAX = 120.0  # USD M — eje común para unidades y costos de programa

CSS = """
#wrap{flex:1;overflow-y:auto;padding:22px 28px 60px}
.sec{margin-bottom:34px}
.sec-h{font-size:11px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--sky);margin-bottom:6px}
.sec-sub{font-size:12.5px;color:var(--muted);line-height:1.65;max-width:860px;margin-bottom:18px}
.sec-sub strong{color:var(--ink);font-weight:700}
.lede{background:rgba(224,1,152,.05);border:1px solid var(--line);border-left:3px solid var(--pink);
border-radius:10px;padding:16px 20px;margin-bottom:28px}
.lede p{font-size:13px;color:#d8c4d4;line-height:1.7;max-width:900px}
.lede p+p{margin-top:11px}
.lede strong{color:var(--ink);font-weight:700}

/* ---- barras de rango ---- */
.bands{display:flex;flex-direction:column;gap:2px}
.row{display:grid;grid-template-columns:230px 1fr 92px;align-items:center;gap:14px;
padding:9px 10px;border-radius:8px;transition:.12s}
.row:hover{background:rgba(255,255,255,.035)}
.row .lbl{text-align:right}
.row .lbl .ln{font-size:12.5px;font-weight:700;color:var(--txt);line-height:1.25}
.row .lbl .lf{font-size:9.5px;font-weight:700;letter-spacing:.07em;text-transform:uppercase;color:var(--muted2);margin-top:3px}
.track{position:relative;height:22px;background:rgba(255,255,255,.04);border-radius:4px}
.ext{position:absolute;top:0;height:22px;border-radius:4px;
background:linear-gradient(90deg,rgba(135,195,211,.30),rgba(135,195,211,.52));
border:1px solid rgba(135,195,211,.45)}
.base{position:absolute;top:-2px;height:26px;width:3px;border-radius:2px;background:var(--pink);
box-shadow:0 0 0 2px var(--bg)}
.row.prog .ext{background:linear-gradient(90deg,rgba(218,122,176,.22),rgba(218,122,176,.40));
border-color:rgba(218,122,176,.38)}
.row.prog .base{background:var(--rose)}
.row .amt{font-size:13px;font-weight:800;font-variant-numeric:tabular-nums;color:var(--ink);text-align:right}
.row .amt span{display:block;font-size:9.5px;font-weight:600;color:var(--muted2);margin-top:2px}
.axis{display:grid;grid-template-columns:230px 1fr 92px;gap:14px;margin-top:6px;padding:0 10px}
.axis .ticks{position:relative;height:18px;border-top:1px solid rgba(255,255,255,.08)}
.axis .tk{position:absolute;top:3px;font-size:9.5px;color:var(--muted2);transform:translateX(-50%);font-variant-numeric:tabular-nums}
.key{display:flex;gap:18px;align-items:center;margin-bottom:14px;font-size:10.5px;color:var(--muted)}
.key i{display:inline-block;vertical-align:middle;margin-right:6px}
.key .k1 i{width:22px;height:10px;border-radius:3px;background:linear-gradient(90deg,rgba(135,195,211,.30),rgba(135,195,211,.52));border:1px solid rgba(135,195,211,.45)}
.key .k2 i{width:3px;height:14px;border-radius:2px;background:var(--pink)}
.key .k3 i{width:22px;height:10px;border-radius:3px;background:linear-gradient(90deg,rgba(218,122,176,.22),rgba(218,122,176,.40));border:1px solid rgba(218,122,176,.38)}

/* ---- tarjetas de unidad ---- */
.units{display:grid;grid-template-columns:repeat(auto-fill,minmax(420px,1fr));gap:14px}
.u{background:var(--panel);border:1px solid var(--line);border-radius:12px;padding:16px 18px}
.u.hi{border-color:rgba(224,1,152,.42);background:linear-gradient(160deg,rgba(224,1,152,.07),var(--panel) 55%)}
.u-top{display:flex;align-items:baseline;gap:10px;margin-bottom:3px;flex-wrap:wrap}
.u-id{font-size:9.5px;font-weight:800;letter-spacing:.1em;color:#0d0408;background:var(--sky);padding:2px 7px;border-radius:20px}
.u-app{font-size:15px;font-weight:800;color:var(--ink);letter-spacing:-.01em}
.u-fate{font-size:10px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:var(--pink);
border:1px solid rgba(224,1,152,.3);padding:2px 8px;border-radius:20px}
.u-vendor{font-size:11px;color:var(--muted2);margin-bottom:12px}
.u-mt{display:flex;gap:7px;flex-wrap:wrap;margin-bottom:12px}
.mt{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.07);border-radius:8px;padding:7px 11px;min-width:76px}
.mt .v{font-size:14px;font-weight:800;color:var(--ink);font-variant-numeric:tabular-nums;line-height:1.1}
.mt .k{font-size:8.5px;font-weight:600;letter-spacing:.07em;text-transform:uppercase;color:var(--muted2);margin-top:3px}
.u-r{font-size:12px;color:#cdb6c8;line-height:1.68}

/* ---- tablas ---- */
table{width:100%;border-collapse:collapse;font-size:12px}
th{text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;
color:var(--muted2);padding:8px 12px;border-bottom:1px solid var(--line);white-space:nowrap}
td{padding:9px 12px;border-bottom:1px solid rgba(255,255,255,.045);color:#cdb6c8;line-height:1.55;vertical-align:top}
tr:hover td{background:rgba(255,255,255,.025)}
td.n{font-variant-numeric:tabular-nums;white-space:nowrap;color:var(--ink);font-weight:700}
td.name{color:var(--txt);font-weight:600}
td a{color:var(--sky);text-decoration:none;border-bottom:1px solid rgba(135,195,211,.3)}
td a:hover{border-bottom-color:var(--sky)}
.tag{display:inline-block;font-size:9px;font-weight:800;letter-spacing:.06em;text-transform:uppercase;
padding:2px 7px;border-radius:20px;white-space:nowrap}
.tag.req{background:rgba(248,113,113,.14);color:#fca5a5;border:1px solid rgba(248,113,113,.3)}
.tag.val{background:rgba(251,191,36,.12);color:#fcd34d;border:1px solid rgba(251,191,36,.28)}
.tag.ok{background:rgba(135,195,211,.12);color:var(--sky);border:1px solid rgba(135,195,211,.3)}
.tag.vendor{background:rgba(255,255,255,.05);color:var(--muted);border:1px solid rgba(255,255,255,.1)}
.tag.acad{background:rgba(167,139,250,.12);color:#c4b5fd;border:1px solid rgba(167,139,250,.3)}
.panel{background:var(--panel);border:1px solid var(--line);border-radius:12px;overflow:hidden}
.note{font-size:11.5px;color:var(--muted2);line-height:1.65;margin-top:12px;max-width:880px;font-style:italic}
"""


def fmt(v):
    return f"{v:,.1f}".rstrip("0").rstrip(".") if v else "0"


def bar(cmin, cbase, cmax, cls=""):
    """Barra de rango: extensión min a max, con marcador del caso base."""
    left = 100.0 * cmin / AXIS_MAX
    width = max(100.0 * (cmax - cmin) / AXIS_MAX, 0.6)
    bpos = 100.0 * cbase / AXIS_MAX
    tip = (f"Conservadora {fmt(cmax)}, base {fmt(cbase)}, agresiva {fmt(cmin)} "
           f"millones de dólares")
    return (f'<div class="track" data-tip="{tip}">'
            f'<div class="ext" style="left:{left:.2f}%;width:{width:.2f}%"></div>'
            f'<div class="base" style="left:calc({bpos:.2f}% - 1.5px)"></div></div>')


def main():
    con = sqlite3.connect(BRAIN)
    con.row_factory = sqlite3.Row
    cur = con.cursor()

    units = cur.execute("SELECT * FROM mf_benchmark_units ORDER BY cost_base DESC").fetchall()
    prog = cur.execute("SELECT * FROM mf_benchmark_program ORDER BY cost_base DESC").fetchall()
    anchors = cur.execute("SELECT * FROM mf_benchmark_anchors ORDER BY source_quality, anchor_key").fetchall()
    drivers = cur.execute("""SELECT * FROM mf_benchmark_drivers
        ORDER BY CASE status WHEN 'DATO-REQUERIDO' THEN 0 WHEN 'VALIDAR' THEN 1 ELSE 2 END,
        driver_key""").fetchall()
    meta = dict(cur.execute("SELECT key, value FROM brain_meta WHERE key LIKE 'mf_bench%'").fetchall())

    t_min = float(meta["mf_bench_total_min"])
    t_base = float(meta["mf_bench_total_base"])
    t_max = float(meta["mf_bench_total_max"])
    vpl_share = meta["mf_bench_vpl_share_base"]
    java_share = meta["mf_bench_java_share_base"]
    n_req = sum(1 for d in drivers if d["status"] == "DATO-REQUERIDO")

    stats = (stat(f"{t_base:,.0f}", "USD M caso base", "pink")
             + stat(f"{t_min:,.0f}–{t_max:,.0f}", "Banda completa")
             + stat(f"{vpl_share}%", "Peso de VisionPLUS", "pink")
             + stat(f"{java_share}%", "Migración real a Java")
             + stat(str(n_req), "Datos requeridos", "red"))

    h = hero(
        "Benchmark de modernización",
        "Salida del mainframe segmentada por ruta 7R",
        "Orden de magnitud para la conversación de inversión, no un estimado de propuesta. "
        "Cada banda se deriva de drivers explícitos y de anclas de industria citadas, de modo "
        "que una cifra discutible se puede rebatir contra su fuente.",
        "SPE-AM-003 › Liverpool › Benchmark mainframe",
        "ORDEN DE MAGNITUD", stats)

    # ---- lede: el replanteamiento ----
    body = ['<div id="wrap">']
    body.append(f"""<div class="lede">
<p>La pregunta llega casi siempre como <strong>migrar el mainframe a Java</strong>, y el inventario
muestra que esa no es la forma del problema. El mainframe de Liverpool son cuatro aplicaciones con
economías distintas, y solo una de ellas constituye una migración de COBOL a Java.</p>
<p><strong>VisionPLUS concentra {vpl_share}% del caso base y no se puede migrar.</strong> Es producto
empaquetado, de modo que el código pertenece al proveedor y la decisión real es reemplazar la
plataforma de tarjetas o encapsularla. La migración genuina a Java, que es la contabilidad de
clientes, pesa {java_share}% del total. Presentar el programa como un ejercicio de reescritura de
código desplaza la conversación hacia donde no está ni el costo ni el riesgo.</p>
<p>La banda es ancha a propósito: va de {t_min:,.0f} a {t_max:,.0f} millones de dólares porque hoy
<strong>no hay una sola línea de código del mainframe en el brain</strong>, ni inventario de
programas, ni MIPS. Ninguno de los 55 documentos de toma de control cubre el mainframe. El primer
gasto del programa es el que angosta todos los demás.</p>
</div>""")

    # ---- barras de rango ----
    body.append('<div class="sec"><div class="sec-h">Dónde está el dinero</div>')
    body.append('<div class="sec-sub">Cada barra abarca de la banda agresiva a la conservadora, '
                'sobre un eje común en millones de dólares. La marca vertical señala el caso base. '
                'Las unidades de alcance y los costos de programa comparten escala, porque miden '
                'lo mismo y la comparación directa es justamente el punto.</div>')
    body.append('<div class="key"><span class="k1"><i></i>Rango de la unidad</span>'
                '<span class="k2"><i></i>Caso base</span>'
                '<span class="k3"><i></i>Costo de programa</span></div>')
    body.append('<div class="panel" style="padding:14px 8px 8px"><div class="bands">')

    for u in units:
        body.append(
            f'<div class="row"><div class="lbl"><div class="ln">{u["app"]}</div>'
            f'<div class="lf">{u["unit_id"]}, {u["fate_label"]}</div></div>'
            f'{bar(u["cost_min"], u["cost_base"], u["cost_max"])}'
            f'<div class="amt">{fmt(u["cost_base"])}<span>USD M</span></div></div>')

    for p in prog:
        if p["cost_max"] == 0:
            continue
        body.append(
            f'<div class="row prog"><div class="lbl"><div class="ln">{p["item"]}</div>'
            f'<div class="lf">Costo de programa</div></div>'
            f'{bar(p["cost_min"], p["cost_base"], p["cost_max"], "prog")}'
            f'<div class="amt">{fmt(p["cost_base"])}<span>USD M</span></div></div>')

    ticks = "".join(
        f'<div class="tk" style="left:{100.0 * t / AXIS_MAX:.2f}%">{t:,.0f}</div>'
        for t in (0, 20, 40, 60, 80, 100, 120))
    body.append(f'</div><div class="axis"><div></div><div class="ticks">{ticks}</div>'
                f'<div></div></div></div>')
    body.append('<div class="note">El run del mainframe durante la transición no aparece en la '
                'gráfica porque es función de los MIPS instalados, que es dato requerido. Con la '
                'banda de industria de 840 a 4,500 dólares por MIPS al año, cada 1,000 MIPS suman '
                'entre 0.8 y 4.5 millones de dólares anuales que siguen corriendo hasta el '
                'decomiso.</div></div>')

    # ---- unidades de alcance ----
    body.append('<div class="sec"><div class="sec-h">Las cinco unidades de alcance</div>')
    body.append('<div class="sec-sub">Cada aplicación lleva su propia ruta 7R y su propia unidad '
                'de medida. Mezclarlas en un solo número por línea de código es el error que este '
                'benchmark evita.</div><div class="units">')
    for u in units:
        fp = (f'{u["fp_min"]:,}–{u["fp_max"]:,}' if u["fp_min"] else "No aplica")
        mt = (f'<div class="mt"><div class="v">{fmt(u["cost_base"])}</div><div class="k">USD M base</div></div>'
              f'<div class="mt"><div class="v">{u["months_base"]}</div><div class="k">Meses base</div></div>'
              f'<div class="mt"><div class="v">{fp}</div><div class="k">Puntos de función</div></div>'
              f'<div class="mt"><div class="v">{u["services"]}</div><div class="k">Servicios</div></div>')
        if u["tickets"]:
            mt += (f'<div class="mt"><div class="v">{u["tickets"]:,}</div>'
                   f'<div class="k">Tickets al año</div></div>')
        hi = " hi" if u["unit_id"] == "U1" else ""
        body.append(
            f'<div class="u{hi}"><div class="u-top"><span class="u-id">{u["unit_id"]}</span>'
            f'<span class="u-app">{u["app"]}</span>'
            f'<span class="u-fate">{u["fate_label"]}</span></div>'
            f'<div class="u-vendor">{u["vendor"]} — {u["criticality"]} — '
            f'Se dimensiona por: {u["uom"].lower()}</div>'
            f'<div class="u-mt">{mt}</div><div class="u-r">{u["rationale"]}</div></div>')
    body.append('</div></div>')

    # ---- costos de programa ----
    body.append('<div class="sec"><div class="sec-h">Costos de programa</div>')
    body.append('<div class="sec-sub">No son atribuibles a una sola aplicación y se omiten con '
                'frecuencia en los estimados por unidad, que es la razón más común de que un '
                'programa de mainframe rebase su presupuesto.</div><div class="panel"><table>')
    body.append('<tr><th>Concepto</th><th>Agresiva</th><th>Base</th><th>Conservadora</th>'
                '<th>Meses</th><th>Sustento</th></tr>')
    for p in prog:
        months = f'{p["months_base"]}' if p["months_base"] else "Transversal"
        vals = ("Función de MIPS" if p["cost_max"] == 0 else None)
        if vals:
            cells = f'<td class="n" colspan="3">{vals}</td>'
        else:
            cells = (f'<td class="n">{fmt(p["cost_min"])}</td>'
                     f'<td class="n">{fmt(p["cost_base"])}</td>'
                     f'<td class="n">{fmt(p["cost_max"])}</td>')
        body.append(f'<tr><td class="name">{p["item"]}</td>{cells}'
                    f'<td class="n">{months}</td><td>{p["note"]}</td></tr>')
    body.append('</table></div></div>')

    # ---- anclas ----
    qmap = {"vendor": ("vendor", "Vendor"), "academico": ("acad", "Académico"),
            "prensa": ("vendor", "Prensa")}
    body.append('<div class="sec"><div class="sec-h">Anclas de industria</div>')
    body.append('<div class="sec-sub">No existe un benchmark estándar y auditado de líneas por '
                'persona-mes para COBOL a Java. Lo que circula son cifras de proveedor y el '
                '<strong>backfiring</strong> de puntos de función, que el propio Capers Jones '
                'advierte que varía más de 500% entre organizaciones. Por eso cada ancla lleva su '
                'fuente y la calidad de esa fuente a la vista, y por eso el entregable es una '
                'banda y no un número.</div><div class="panel"><table>')
    body.append('<tr><th>Concepto</th><th>Mínimo</th><th>Máximo</th><th>Unidad</th>'
                '<th>Fuente</th><th>Calidad</th></tr>')
    for a in anchors:
        cls, lbl = qmap.get(a["source_quality"], ("vendor", a["source_quality"]))
        vmin = f'{a["val_min"]:,.1f}'.rstrip("0").rstrip(".")
        vmax = f'{a["val_max"]:,.1f}'.rstrip("0").rstrip(".")
        body.append(f'<tr><td class="name">{a["concept"]}</td><td class="n">{vmin}</td>'
                    f'<td class="n">{vmax}</td><td>{a["unit"]}</td>'
                    f'<td><a href="{a["url"]}" target="_blank" rel="noopener">{a["source"]}</a></td>'
                    f'<td><span class="tag {cls}">{lbl}</span></td></tr>')
    body.append('</table></div></div>')

    # ---- drivers ----
    body.append('<div class="sec"><div class="sec-h">Drivers de escala y datos faltantes</div>')
    body.append('<div class="sec-sub">El modelo es paramétrico: al llegar un dato real se edita el '
                'driver y el benchmark se recalcula. Los cuatro marcados como dato requerido son '
                'los que hoy mantienen la banda abierta.</div><div class="panel"><table>')
    body.append('<tr><th>Driver</th><th>Valor</th><th>Unidad</th><th>Estado</th><th>Lectura</th></tr>')
    tmap = {"DATO-REQUERIDO": "req", "VALIDAR": "val", "CONFIRMADO": "ok"}
    for d in drivers:
        val = d["value"] if d["value"] else "Sin dato"
        body.append(f'<tr><td class="name">{d["driver_key"]}</td><td class="n">{val}</td>'
                    f'<td>{d["unit"]}</td>'
                    f'<td><span class="tag {tmap.get(d["status"], "vendor")}">{d["status"]}</span></td>'
                    f'<td>{d["note"]}<br><span style="color:var(--muted2);font-size:10.5px">'
                    f'Fuente: {d["source"]}</span></td></tr>')
    body.append('</table></div></div>')

    # ---- cómo se angosta ----
    body.append("""<div class="sec"><div class="sec-h">Qué angosta la banda</div>
<div class="sec-sub">El benchmark sirve para decidir la primera inversión, no para firmar un
precio. Estos cuatro insumos son los que convierten el rango en un estimado defendible.</div>
<div class="panel"><table>
<tr><th>Insumo</th><th>Qué colapsa</th><th>Cómo se obtiene</th></tr>
<tr><td class="name">Inventario de código del mainframe</td>
<td>La banda de refactor de Mainframe Clientes, que hoy va de 2.2 a 15.8 millones de dólares</td>
<td>Extracción de programas, copybooks y JCL hacia el brain, con el mismo pipeline que ya corre
para los programas de SAP</td></tr>
<tr><td class="name">MIPS instalados y su costo</td>
<td>El costo de no hacer nada, que es el contrafactual de toda la conversación de inversión</td>
<td>Factura del mainframe y reporte de capacidad, que es un dato administrativo y no técnico</td></tr>
<tr><td class="name">Capa de desarrollo propio sobre VisionPLUS</td>
<td>Si el reemplazo de plataforma arrastra una migración de user exits y satélites, que es la
diferencia entre la banda base y la conservadora de la unidad más cara</td>
<td>El grupo de tickets que atiende los satélites ya prueba que esa capa existe, de modo que el
siguiente paso es inventariarla con el equipo que la opera</td></tr>
<tr><td class="name">Respuestas de proveedor de plataforma de tarjetas</td>
<td>La licencia y la razón de implementación, que son los dos términos de mayor peso del caso base</td>
<td>Sondeo de mercado a plataformas modernas de emisión, sin comprometer todavía una decisión de
arquitectura</td></tr>
</table></div>
<div class="note">Las cifras son totales de programa tomados de anclas de industria, no cálculos de
tarifa. Cualquier conversión a horas o a precio por recurso debe pasar por el Pricing and Commercial
Modeler, porque la tarifa promedio es un marcador de posición y no un dato de este modelo.</div>
</div>""")

    body.append("</div>")

    html = page("Liverpool — Benchmark de modernización del mainframe", h, "\n".join(body), CSS)
    OUT.write_text(html, encoding="utf-8")
    print(f"escrito: {OUT.name}  ({len(html):,} bytes)")
    print(f"unidades {len(units)}, programa {len(prog)}, anclas {len(anchors)}, drivers {len(drivers)}")
    print(f"banda total: {t_min:,.0f} / {t_base:,.0f} / {t_max:,.0f} USD M")
    con.close()


if __name__ == "__main__":
    main()
