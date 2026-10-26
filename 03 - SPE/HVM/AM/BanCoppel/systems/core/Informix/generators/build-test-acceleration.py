#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-test-acceleration.py — Vista "Aceleración de Pruebas con el Gemelo Cognitivo".

Deriva de brain.db el universo de casos de prueba, los escenarios funcionales y los
perfiles de carga, y los renderiza como vista del portal. Dos marcas:

  portal/test-acceleration-bcop.html       · identidad BanCoppel (azul + dorado)
  sanitized/test-acceleration-legacy.html  · identidad Accenture (morado), cliente anonimizado

Además inyecta — idempotente, entre marcadores HTML — la tarjeta de la vista en la
sección de inventario de ambos portales, justo después del grupo Capa 4 · Intención.

Fuente de verdad: digital-brain/brain.db. Nada de cifras hardcodeadas.

Uso:
  python generators/build-test-acceleration.py
  python generators/build-test-acceleration.py --no-inject   # solo escribe las vistas

SPE-AM-001 · Specialist Informix SPL · QE shift-left
"""

import sys, re, json, math, html, sqlite3, argparse
from pathlib import Path
from collections import defaultdict

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
DB   = BASE / "digital-brain" / "brain.db"

# ── multiplicadores de diseño de prueba ──────────────────────────────────────
# Cada técnica es estándar ISTQB; el multiplicador se declara en la vista para
# que el caso derivado sea defendible frente al QA Lead, no un número mágico.
MULT = {
    "VALIDACIÓN": (2, "Partición de equivalencia: camino verdadero y camino falso"),
    "UMBRAL":     (3, "Valores límite: por debajo, en el límite y por encima"),
    "FÓRMULA":    (1, "Golden master: mismo insumo contra legacy y target"),
    "ESTADO":     (2, "Transición de estado: válida e inválida"),
}


# ═════════════════════════════════════════════════════════════════════════════
# Extracción desde el brain
# ═════════════════════════════════════════════════════════════════════════════
def jlist(raw):
    """reg y riesgo se guardan como JSON array o como texto plano."""
    if not raw:
        return []
    try:
        v = json.loads(raw)
        return [x for x in v if x] if isinstance(v, list) else ([v] if v else [])
    except Exception:
        return [p.strip() for p in str(raw).split(";") if p.strip()]


def collect(con):
    con.row_factory = sqlite3.Row
    q = lambda s, *a: con.execute(s, a).fetchall()
    d = {}

    # ── reglas: el universo de casos candidatos ──────────────────────────────
    d["rules_total"] = q("SELECT COUNT(*) n FROM rules")[0]["n"]
    d["by_tipo"] = {r["tipo"]: r["n"] for r in
                    q("SELECT tipo, COUNT(*) n FROM rules GROUP BY tipo")}
    d["by_clase"] = {r["clase"]: r["n"] for r in
                     q("SELECT clase, COUNT(*) n FROM rules GROUP BY clase")}
    d["negocio"] = d["by_clase"].get("NEGOCIO", 0)

    n_reg = n_riesgo = 0
    reg_count = defaultdict(int)
    riesgo_count = defaultdict(int)
    for r in q("SELECT reg, riesgo FROM rules"):
        regs = jlist(r["reg"])
        if regs:
            n_reg += 1
            for x in regs:
                for parte in str(x).split(";"):
                    if parte.strip():
                        reg_count[parte.strip()] += 1
        rs = jlist(r["riesgo"])
        if rs:
            n_riesgo += 1
            for x in rs:
                riesgo_count[str(x).split("—")[0].strip()] += 1
    d["rules_reg"] = n_reg
    d["rules_riesgo"] = n_riesgo
    d["reg_count"] = dict(sorted(reg_count.items(), key=lambda x: -x[1]))
    d["riesgo_count"] = dict(sorted(riesgo_count.items(), key=lambda x: -x[1]))

    d["sub_tipo"] = {r["sub_tipo"]: r["n"] for r in
                     q("""SELECT sub_tipo, COUNT(*) n FROM rules
                          WHERE sub_tipo IS NOT NULL GROUP BY sub_tipo
                          ORDER BY n DESC LIMIT 6""")}

    # ── journeys, códigos de retorno, malla batch ────────────────────────────
    d["journeys"] = q("SELECT COUNT(*) n FROM journeys")[0]["n"]
    d["journeys_orq"] = q("SELECT COUNT(*) n FROM journeys WHERE journey_type='orchestrator'")[0]["n"]
    d["journeys_exp"] = q("SELECT COUNT(*) n FROM journeys WHERE journey_type='exposed'")[0]["n"]
    d["codret"] = q("SELECT COUNT(*) n FROM codret_dictionary")[0]["n"]
    d["ctm_jobs"] = q("SELECT COUNT(*) n FROM ctm_jobs")[0]["n"]
    d["ctm_folders"] = q("SELECT COUNT(DISTINCT folder) n FROM ctm_jobs")[0]["n"]
    d["ctm_sp"] = q("SELECT COUNT(*) n FROM ctm_jobs WHERE sp_id IS NOT NULL")[0]["n"]
    d["sps_total"] = q("SELECT COUNT(*) n FROM sps")[0]["n"]

    # ── casos candidatos por técnica ─────────────────────────────────────────
    casos = []
    for tipo, (mult, tecnica) in MULT.items():
        n = d["by_tipo"].get(tipo, 0)
        casos.append({"origen": f"Reglas tipo {tipo.lower()}", "n": n, "mult": mult,
                      "tecnica": tecnica, "casos": n * mult})
    casos.append({"origen": "Códigos de retorno catalogados", "n": d["codret"], "mult": 1,
                  "tecnica": "Prueba negativa: provocar el error y verificar el código devuelto",
                  "casos": d["codret"]})
    casos.append({"origen": "Journeys de negocio", "n": d["journeys"], "mult": 1,
                  "tecnica": "Escenario de extremo a extremo sobre el flujo real de llamadas",
                  "casos": d["journeys"]})
    d["casos"] = casos
    d["casos_total"] = sum(c["casos"] for c in casos)

    # ── producción: la evidencia que convierte supuestos en perfiles de carga ─
    d["sps_prod"] = q("SELECT COUNT(*) n FROM sps WHERE COALESCE(prod_calls_day,0)>0")[0]["n"]
    d["calls_day"] = q("SELECT SUM(prod_calls_day) n FROM sps")[0]["n"] or 0
    d["sps_p95"] = q("SELECT COUNT(*) n FROM sps WHERE prod_p95_s IS NOT NULL")[0]["n"]
    d["evidence_date"] = (q("""SELECT prod_evidence_date d FROM sps
                               WHERE prod_evidence_date IS NOT NULL LIMIT 1""") or [{"d": "—"}])[0]["d"]

    canales = set()
    for r in q("SELECT prod_calling_systems c FROM sps WHERE prod_calling_systems IS NOT NULL"):
        for x in jlist(r["c"]):
            canales.add(str(x))
    d["canales"] = len(canales)

    # ── reglas agregadas por SP: casos derivados por componente ──────────────
    per_sp = defaultdict(lambda: {"val": 0, "form": 0, "umb": 0, "est": 0,
                                  "riesgo": 0, "reg": set()})
    for r in q("SELECT sp, tipo, reg, riesgo FROM rules"):
        s = per_sp[r["sp"]]
        s["val"] += r["tipo"] == "VALIDACIÓN"
        s["form"] += r["tipo"] == "FÓRMULA"
        s["umb"] += r["tipo"] == "UMBRAL"
        s["est"] += r["tipo"] == "ESTADO"
        if jlist(r["riesgo"]):
            s["riesgo"] += 1
        for x in jlist(r["reg"]):
            for parte in str(x).split(";"):
                if parte.strip():
                    s["reg"].add(parte.strip())

    # ── ranking de prioridad: casos derivados ponderados por tráfico real ────
    # El conteo de reglas sale del propio catálogo del brain, no de sps.rules_n: esa
    # columna se alimenta de otro corpus y mostrar ambas juntas descuadra la tabla.
    ranking = []
    for r in q("""SELECT db, name, domain, biz, loc, prod_calls_day, prod_p95_s,
                         prod_error_rate, prod_channels_n
                  FROM sps WHERE COALESCE(rules_n,0)>0 OR COALESCE(prod_calls_day,0)>0"""):
        key = f"{r['db']}:{r['name']}"
        s = per_sp.get(key, {"val": 0, "form": 0, "umb": 0, "est": 0, "riesgo": 0, "reg": set()})
        reglas = s["val"] + s["form"] + s["umb"] + s["est"]
        derivados = (s["val"] * MULT["VALIDACIÓN"][0] + s["umb"] * MULT["UMBRAL"][0]
                     + s["form"] * MULT["FÓRMULA"][0] + s["est"] * MULT["ESTADO"][0])
        calls = r["prod_calls_day"] or 0
        if not derivados and not calls:
            continue
        ranking.append({
            "sp": key, "db": r["db"], "name": r["name"], "domain": r["domain"],
            "biz": r["biz"] or "", "reglas": reglas, "derivados": derivados,
            "calls": calls, "p95": r["prod_p95_s"], "err": r["prod_error_rate"],
            "canales": r["prod_channels_n"] or 0, "riesgo": s["riesgo"],
            "reg": sorted(s["reg"]),
            "score": derivados * math.log10(1 + calls) if derivados else 0.0,
        })
    ranking.sort(key=lambda x: -x["score"])
    d["ranking"] = ranking[:12]

    # ── escenarios de carga: lo que ya está medido en producción ─────────────
    d["carga"] = [dict(r) for r in q("""
        SELECT db, name, domain, biz, prod_calls_day, prod_calls_sec, prod_p50_s,
               prod_p95_s, prod_p99_s, prod_error_rate, prod_channels_n
        FROM sps WHERE prod_p95_s IS NOT NULL AND COALESCE(prod_calls_day,0)>0
        ORDER BY prod_calls_day DESC LIMIT 8""")]

    # ── SPs con error rate que ya duele hoy: casos de resiliencia ────────────
    d["errores"] = [dict(r) for r in q("""
        SELECT db, name, domain, biz, prod_calls_day, prod_error_rate
        FROM sps WHERE COALESCE(prod_error_rate,0) > 1 AND COALESCE(prod_calls_day,0) > 10000
        ORDER BY prod_error_rate DESC LIMIT 5""")]

    # ── ejemplos reales: una regla por técnica, con su código fuente ─────────
    def ejemplo(where, order="LENGTH(business_name) DESC"):
        rows = q(f"""SELECT id, tipo, sub_tipo, sp, db, domain, line, code, reg, riesgo,
                            business_name FROM rules WHERE {where}
                     ORDER BY {order} LIMIT 1""")
        return dict(rows[0]) if rows else None

    # Para el ejemplo de valores límite conviene un umbral monetario: se elige, de entre
    # los candidatos, el de mayor valor numérico (los umbrales pequeños suelen ser días
    # o contadores y hacen confuso el escenario).
    cand = q("""SELECT id, tipo, sub_tipo, sp, db, domain, line, code, reg, riesgo,
                       business_name FROM rules
                WHERE tipo='UMBRAL' AND code LIKE '%>=%' AND LENGTH(business_name)>40
                ORDER BY LENGTH(code) ASC LIMIT 200""")
    mejor, mejor_v = None, -1.0
    for r in cand:
        m = re.search(r">=\s*([\d]+(?:\.\d+)?)", r["code"] or "")
        if m and float(m.group(1)) > mejor_v:
            mejor, mejor_v = dict(r), float(m.group(1))
    d["ej_umbral"] = mejor
    d["ej_formula"] = ejemplo("tipo='FÓRMULA' AND riesgo LIKE '%ROUND%' AND reg<>'[]' "
                              "AND LENGTH(business_name)>30", "LENGTH(code) ASC")
    d["ej_validacion"] = ejemplo("tipo='VALIDACIÓN' AND reg<>'[]' AND LENGTH(business_name)>40",
                                 "LENGTH(code) ASC")
    return d


# ═════════════════════════════════════════════════════════════════════════════
# Marcas: BanCoppel y versión sanitizada
# ═════════════════════════════════════════════════════════════════════════════
BRANDS = {
    "bcop": {
        "out":    BASE / "portal" / "test-acceleration-bcop.html",
        "index":  BASE / "portal" / "index-bcop-v2.html",
        "href":   "test-acceleration-bcop.html",
        "catalogo": "test-catalog-bcop.html",
        "datos":  "test-data-bcop.html",
        "back":   "index-bcop-v2.html",
        "logo":   "bancoppel-logo.png",
        "alt":    "BanCoppel",
        "sys":    "Informix",
        "crumb":  "BCOPCORE",
        "cliente": "BanCoppel",
        "accent": "#F0D224", "accent2": "#f6e27a",
        "blue": "#3D5FCD", "blued": "#122FB1",
        "bg": "#060a1a", "glow": "240,210,36",
        "scrub": False,
    },
    "legacy": {
        "out":    BASE / "sanitized" / "test-acceleration-legacy.html",
        "index":  BASE / "sanitized" / "index-legacy.html",
        "href":   "test-acceleration-legacy.html",
        "catalogo": "test-catalog-legacy.html",
        "datos":  "test-data-legacy.html",
        "back":   "index-legacy.html",
        "logo":   "accenture-logo.png",
        "alt":    "Accenture",
        "sys":    "LegacyCore",
        "crumb":  "LEGACYCORE",
        "cliente": "el banco",
        "accent": "#A100FF", "accent2": "#c77dff",
        "blue": "#7C4DCF", "blued": "#6B21A8",
        "bg": "#14142b", "glow": "161,0,255",
        "scrub": True,
    },
}

# tokens que delatan al cliente en los datos que vienen del brain
SCRUB = [
    (re.compile(r"BanCoppel", re.I), "LegacyCore"),
    (re.compile(r"\bAPPCOPPEL\b", re.I), "APP_GRUPO"),
    (re.compile(r"\bCoppel\b", re.I), "el grupo"),
    (re.compile(r"COPPEL", re.I), "GRUPO"),
    # Sin \b: dentro de identificadores (sp_ws_..._bcpl_tar, sp_ctbcpl_gen_...) el
    # guion bajo es carácter de palabra y el límite nunca coincide.
    (re.compile(r"bcpl", re.I), "lgc"),
    (re.compile(r"_CPL\b", re.I), "_GRP"),
    (re.compile(r"bcop", re.I), "lgc"),
    (re.compile(r"Informix", re.I), "LegacyCore"),
]


def scrub(txt, brand):
    if not brand["scrub"] or not txt:
        return txt
    for rx, rep in SCRUB:
        txt = rx.sub(rep, str(txt))
    return txt


def esc(x, brand=None):
    s = "" if x is None else str(x)
    if brand:
        s = scrub(s, brand)
    return html.escape(s)


def cap(s):
    """Toda descripción visible arranca con mayúscula."""
    s = (s or "").strip()
    return s[0].upper() + s[1:] if s else s


def fmt(n):
    return f"{n:,}".replace(",", ",") if isinstance(n, int) else str(n)


# ═════════════════════════════════════════════════════════════════════════════
# Fragmentos de contenido derivados de los datos
# ═════════════════════════════════════════════════════════════════════════════
def tabla_derivacion(d, b):
    filas = ""
    for c in d["casos"]:
        filas += (f'<tr><td class="strong">{esc(c["origen"])}</td>'
                  f'<td class="num">{fmt(c["n"])}</td>'
                  f'<td>{esc(c["tecnica"])}</td>'
                  f'<td class="num">×{c["mult"]}</td>'
                  f'<td class="num hot">{fmt(c["casos"])}</td></tr>')
    filas += (f'<tr class="total"><td class="strong">Universo candidato</td><td></td>'
              f'<td>Antes de consolidar duplicados y de la poda del QA Lead</td>'
              f'<td></td><td class="num hot">{fmt(d["casos_total"])}</td></tr>')
    return filas


def tabla_ranking(d, b):
    filas = ""
    for r in d["ranking"]:
        reg = ", ".join(r["reg"][:2]) if r["reg"] else "—"
        riesgo = (f'<span class="pill risk">{r["riesgo"]}</span>' if r["riesgo"]
                  else '<span class="pill mute">0</span>')
        p95 = f'{r["p95"]:.1f} s' if r["p95"] is not None else "—"
        filas += (f'<tr><td class="mono">{esc(r["sp"], b)}</td>'
                  f'<td class="mono dim">{esc(r["domain"])}</td>'
                  f'<td>{esc(cap(r["biz"]), b) or "—"}</td>'
                  f'<td class="num">{fmt(r["reglas"])}</td>'
                  f'<td class="num hot">{fmt(r["derivados"])}</td>'
                  f'<td class="num">{fmt(r["calls"])}</td>'
                  f'<td class="num">{p95}</td>'
                  f'<td class="num">{riesgo}</td>'
                  f'<td class="dim">{esc(reg)}</td></tr>')
    return filas


def tabla_carga(d, b):
    filas = ""
    for r in d["carga"]:
        rps = r["prod_calls_sec"] or 0
        filas += (f'<tr><td class="mono">{esc(r["db"] + ":" + r["name"], b)}</td>'
                  f'<td>{esc(cap(r["biz"]), b)}</td>'
                  f'<td class="num">{fmt(r["prod_calls_day"])}</td>'
                  f'<td class="num">{rps:.2f}</td>'
                  f'<td class="num">{(r["prod_p50_s"] or 0):.1f} s</td>'
                  f'<td class="num hot">{(r["prod_p95_s"] or 0):.1f} s</td>'
                  f'<td class="num">{(r["prod_p99_s"] or 0):.1f} s</td>'
                  f'<td class="num">{(r["prod_error_rate"] or 0):.2f}%</td>'
                  f'<td class="num dim">{r["prod_channels_n"]}</td></tr>')
    return filas


def bloque_gherkin(d, b):
    """Un caso de valores límite construido con la regla real del brain."""
    r = d["ej_umbral"]
    if not r:
        return "<p class='dim'>Sin regla de umbral disponible en el brain.</p>"
    m = re.search(r">=\s*([\d_]+(?:\.\d+)?)", r["code"] or "")
    try:
        v = float(m.group(1))
        bajo, exacto, alto = f"{v - 0.01:,.2f}", f"{v:,.2f}", f"{v + 0.01:,.2f}"
    except (AttributeError, ValueError):
        bajo, exacto, alto = "límite − δ", "límite", "límite + δ"
    nombre = scrub(r["business_name"], b)
    code = scrub((r["code"] or "").strip(), b)
    return f"""<span class="c">Regla {esc(r['id'])} · {esc(r['sp'], b)} línea {esc(r['line'])}</span>
<span class="c">Evidencia en el código: {esc(code)}</span>
<span class="c">Regulador: {esc(', '.join(jlist(r['reg'])) or 'sin regulador asociado')}</span>

<span class="k">Característica:</span> {esc(cap(nombre))}

  <span class="k">Esquema del escenario:</span> Comportamiento en el valor límite
    <span class="k">Dado</span> una operación cuyo valor evaluado es &lt;valor&gt;
    <span class="k">Cuando</span> se aplica la regla {esc(r['id'])}
    <span class="k">Entonces</span> la condición del umbral se cumple: &lt;se_cumple&gt;

    <span class="k">Ejemplos:</span>
      | valor         | se_cumple | técnica         |
      | {bajo:<13} | no        | límite inferior |
      | {exacto:<13} | sí        | valor exacto    |
      | {alto:<13} | sí        | límite superior |"""


def bloque_golden(d, b):
    """Comparador de equivalencia construido con la fórmula real del brain."""
    r = d["ej_formula"]
    if not r:
        return "<p class='dim'>Sin fórmula con riesgo de redondeo en el brain.</p>"
    riesgos = "; ".join(jlist(r["riesgo"])) or "sin riesgo declarado"
    reg = ", ".join(jlist(r["reg"])) or "sin regulador"
    sp = scrub(r["sp"], b)
    return f"""<span class="c"># Regla {esc(r['id'])} · {esc(sp, b)} línea {esc(r['line'])} · regulador {esc(reg)}</span>
<span class="c"># {esc(cap(scrub(r['business_name'], b)))}</span>
<span class="c"># Código legacy: {esc(scrub((r['code'] or '').strip(), b))}</span>
<span class="c"># Riesgo declarado por el gemelo: {esc(riesgos)}</span>

<span class="k">import</span> pytest
<span class="k">from</span> decimal <span class="k">import</span> Decimal, ROUND_HALF_UP, ROUND_HALF_EVEN

CASOS = cargar_golden_master(<span class="s">"{esc(r['id'])}"</span>)  <span class="c"># insumos reales del parallel-run</span>

<span class="d">@pytest.mark.equivalencia</span>
<span class="d">@pytest.mark.regulatorio</span>
<span class="k">@pytest.mark.parametrize</span>(<span class="s">"caso"</span>, CASOS)
<span class="k">def</span> <span class="f">test_equivalencia</span>(caso):
    legacy = caso[<span class="s">"salida_legacy"</span>]              <span class="c"># capturada del motor actual</span>
    target = servicio_target.calcular(**caso[<span class="s">"entrada"</span>])

    <span class="c"># El modo de redondeo es la divergencia que el gemelo marcó: se prueba explícito</span>
    <span class="k">assert</span> target == legacy, (
        <span class="s">f"Divergencia {{caso['id']}}: legacy={{legacy}} target={{target}}"</span>
    )

<span class="k">def</span> <span class="f">test_modo_de_redondeo_declarado</span>():
    <span class="c"># El target debe declarar el modo; heredarlo por omisión es el defecto típico</span>
    <span class="k">assert</span> servicio_target.MODO_REDONDEO <span class="k">in</span> (ROUND_HALF_UP, ROUND_HALF_EVEN)"""


def bloque_k6(d, b):
    """Script de carga con las tasas de llegada y los umbrales medidos en producción."""
    filas, vistos = [], set()
    for r in d["carga"]:
        if r["name"] in vistos:          # el mismo SP replicado en otra BD no aporta escenario
            continue
        vistos.add(r["name"])
        key = re.sub(r"[^a-z0-9]+", "_", f"{r['db']}_{r['name']}".lower())
        rps = r["prod_calls_sec"] or 0.0
        p95 = r["prod_p95_s"] or 0.1
        p99 = r["prod_p99_s"] or p95
        # Ley de Little: concurrencia = tasa × tiempo de servicio, con holgura para el pico
        vus = max(10, math.ceil(rps * p95 * 2) + 10)
        filas.append({"key": key, "rpm": max(1, round(rps * 60)), "vus": vus,
                      "p95": p95, "p99": p99, "lento": p95 > 5,
                      "sp": scrub(f"{r['db']}:{r['name']}", b), "day": r["prod_calls_day"]})
        if len(filas) == 4:
            break

    escenarios = ""
    for f in filas:
        escenarios += f"""    <span class="f">{f['key']}</span>: {{
      executor: <span class="s">'constant-arrival-rate'</span>,
      rate: {f['rpm']}, timeUnit: <span class="s">'1m'</span>, duration: <span class="s">'30m'</span>,
      preAllocatedVUs: {f['vus']},   <span class="c">// concurrencia = tasa × P95 observado, con holgura</span>
      exec: <span class="s">'{f['key']}'</span>,   <span class="c">// {esc(f['sp'])} · {fmt(f['day'])} llamadas/día medidas</span>
    }},
"""
    umbrales = ""
    for f in filas:
        nota = ("   <span class=\"c\">// baseline ya degradado: es techo, no objetivo</span>"
                if f["lento"] else "")
        umbrales += (f"""    <span class="s">'http_req_duration{{scenario:{f['key']}}}'</span>: ["""
                     f"""<span class="s">'p(95)&lt;{int(f['p95'] * 1000)}'</span>, """
                     f"""<span class="s">'p(99)&lt;{int(f['p99'] * 1000)}'</span>],{nota}\n""")
    return f"""<span class="c">// Perfil de carga derivado de la telemetría de producción del gemelo</span>
<span class="c">// Evidencia: {esc(d['evidence_date'])} · {fmt(d['sps_prod'])} SPs con tráfico medido · {fmt(d['calls_day'])} llamadas/día</span>
<span class="c">// La tasa de llegada NO es un supuesto: es la medición del legacy.</span>

<span class="k">import</span> http <span class="k">from</span> <span class="s">'k6/http'</span>;
<span class="k">import</span> {{ check }} <span class="k">from</span> <span class="s">'k6'</span>;

<span class="k">export const</span> options = {{
  scenarios: {{
{escenarios}  }},
  <span class="c">// El umbral del target es el percentil que el legacy ya entrega hoy: no se negocia a la baja</span>
  thresholds: {{
{umbrales}    <span class="s">'http_req_failed'</span>: [<span class="s">'rate&lt;0.01'</span>],
  }},
}};"""


# ═════════════════════════════════════════════════════════════════════════════
# Render
# ═════════════════════════════════════════════════════════════════════════════
def render(d, b):
    reg_top = " · ".join(f"{k} {v:,}" for k, v in list(d["reg_count"].items())[:5])
    riesgo_top = "".join(
        f'<li><b>{esc(k)}</b> <span class="dim">{v:,} reglas</span></li>'
        for k, v in list(d["riesgo_count"].items())[:5])
    sub_top = "".join(
        f'<li><b>{esc(k.replace("_", " ").title())}</b> <span class="dim">{v:,}</span></li>'
        for k, v in d["sub_tipo"].items())
    err_rows = "".join(
        f'<tr><td class="mono">{esc(r["db"] + ":" + r["name"], b)}</td>'
        f'<td>{esc(cap(r["biz"]), b)}</td>'
        f'<td class="num">{fmt(r["prod_calls_day"])}</td>'
        f'<td class="num hot">{r["prod_error_rate"]:.2f}%</td></tr>'
        for r in d["errores"])

    T = {
        "__TITLE__": f"{b['sys']} · Aceleración de Pruebas",
        "__LOGO__": b["logo"], "__ALT__": b["alt"], "__CRUMB__": b["crumb"],
        "__BACK__": b["back"], "__SYS__": b["sys"], "__CLIENTE__": b["cliente"],
        "__ACCENT__": b["accent"], "__ACCENT2__": b["accent2"],
        "__BLUE__": b["blue"], "__BLUED__": b["blued"], "__BG__": b["bg"], "__GLOW__": b["glow"],
        "__CATALOGO__": b["catalogo"],
        "__CASOS_TOTAL__": fmt(d["casos_total"]),
        "__REGLAS__": fmt(d["rules_total"]),
        "__NEGOCIO__": fmt(d["negocio"]),
        "__JOURNEYS__": fmt(d["journeys"]),
        "__JOURNEYS_ORQ__": fmt(d["journeys_orq"]),
        "__JOURNEYS_EXP__": fmt(d["journeys_exp"]),
        "__CODRET__": fmt(d["codret"]),
        "__RULES_REG__": fmt(d["rules_reg"]),
        "__RULES_RIESGO__": fmt(d["rules_riesgo"]),
        "__SPS_PROD__": fmt(d["sps_prod"]),
        "__SPS_TOTAL__": fmt(d["sps_total"]),
        "__CALLS_DAY__": fmt(d["calls_day"]),
        "__CANALES__": fmt(d["canales"]),
        "__EVIDENCE__": esc(d["evidence_date"]),
        "__CTM_JOBS__": fmt(d["ctm_jobs"]),
        "__CTM_FOLDERS__": fmt(d["ctm_folders"]),
        "__CTM_SP__": fmt(d["ctm_sp"]),
        "__REG_TOP__": esc(reg_top),
        "__RIESGO_TOP__": riesgo_top,
        "__SUB_TOP__": sub_top,
        "__TBL_DERIVACION__": tabla_derivacion(d, b),
        "__TBL_RANKING__": tabla_ranking(d, b),
        "__TBL_CARGA__": tabla_carga(d, b),
        "__TBL_ERRORES__": err_rows,
        "__GHERKIN__": bloque_gherkin(d, b),
        "__GOLDEN__": bloque_golden(d, b),
        "__K6__": bloque_k6(d, b),
    }
    out = PAGE
    for k, v in T.items():
        out = out.replace(k, str(v))
    return out


# ═════════════════════════════════════════════════════════════════════════════
# Inyección de la tarjeta en el portal (idempotente, entre marcadores)
# ═════════════════════════════════════════════════════════════════════════════
MARK_A = "<!-- QE · aceleración de pruebas · generado por build-test-acceleration.py -->"
MARK_B = "<!-- /QE · aceleración de pruebas -->"


def card_group(d, b):
    casos = fmt(d["casos_total"])
    return f"""{MARK_A}
    <div class="group">
      <div class="ghead reveal">
        <h3>Quality Engineering · Aceleración de pruebas</h3>
        <span>El corpus que se extrajo para entender el legacy es, sin trabajo adicional, la especificación de prueba del target.</span>
      </div>
      <div class="cardgrid">
        <a class="vcard glass reveal" href="{b['href']}">
          <div class="ico">🧪</div>
          <div>
            <div class="vtag">Shift-left · Casos · Scripts</div>
            <div class="vt">Aceleración de Pruebas</div>
            <div class="vd">Cómo el gemelo deriva {casos} casos candidatos de las {fmt(d['rules_total'])} reglas, los {fmt(d['journeys'])} journeys y los {fmt(d['codret'])} códigos de retorno; y cómo genera los scripts funcionales de equivalencia y los de performance con las tasas de llegada reales de {fmt(d['sps_prod'])} SPs medidos en producción.</div>
            <div class="go">Abrir la vista <span class="arr">→</span></div>
          </div>
        </a>
        <a class="vcard glass reveal" href="{b['catalogo']}">
          <div class="ico">📋</div>
          <div>
            <div class="vtag">Catálogo · Filtrable · CSV</div>
            <div class="vt">Casos de Prueba Derivados</div>
            <div class="vd">Los {casos} casos materializados uno por uno, con su técnica, prioridad, regulador y el fragmento de código fuente que los sustenta. Filtro por dominio, regulador y riesgo de equivalencia, y descarga en CSV para importar al ALM.</div>
            <div class="go">Abrir el catálogo <span class="arr">→</span></div>
          </div>
        </a>
        <a class="vcard glass reveal" href="{b['datos']}">
          <div class="ico">🧬</div>
          <div>
            <div class="vtag">Datos sintéticos · Sin PII</div>
            <div class="vt">Datos de Prueba Generados</div>
            <div class="vd">Un set de datos por cada uno de los {casos} casos, construido desde el fragmento de código de la regla en lugar de extraerse de producción. CLABE y tarjeta con dígito verificador válido sobre rangos no asignados, y generación determinista: el mismo caso produce siempre los mismos valores.</div>
            <div class="go">Abrir la vista <span class="arr">→</span></div>
          </div>
        </a>
      </div>
    </div>
    {MARK_B}"""


# Anclas del punto de inserción, por portal. El flag indica si hay que retroceder
# hasta el </section> previo: en el portal v2 el ancla vive fuera de la sección de
# vistas, y el grupo debe quedar dentro de ella.
ANCLAS = [
    ('<div class="group"><div class="ghead reveal"><h3>HVM · Modernización', False),
    ("<!-- ─── RIESGOS &amp; DIAGNÓSTICOS ─── -->", True),
    ("<!-- ─── RIESGOS & DIAGNÓSTICOS ─── -->", True),
]


def inject(d, b):
    """Inserta o actualiza el grupo justo después del grupo Capa 4 · Intención.

    Siempre elimina el bloque previo antes de reinsertar: así una corrida posterior
    corrige la posición aunque el ancla haya cambiado.
    """
    path = b["index"]
    if not path.exists():
        print(f"  [saltado] no existe {path.name}")
        return False

    src = path.read_text(encoding="utf-8")
    existia = MARK_A in src
    if existia:
        src = re.sub(r"\s*" + re.escape(MARK_A) + r".*?" + re.escape(MARK_B),
                     "", src, flags=re.S)

    block = card_group(d, b)
    for ancla, antes_de_cierre in ANCLAS:
        i = src.find(ancla)
        if i == -1:
            continue
        if antes_de_cierre:
            j = src.rfind("</section>", 0, i)
            if j == -1:
                continue
            i = j
        nuevo = src[:i] + block + "\n\n  " + src[i:]
        path.write_text(nuevo, encoding="utf-8")
        print(f"  [{'actualizado' if existia else 'inyectado'}] {path.name} "
              f"(ancla: {ancla[:44]}…)")
        return True

    print(f"  [sin ancla] {path.name} — revisar manualmente")
    return False


# ═════════════════════════════════════════════════════════════════════════════
PAGE = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>__TITLE__</title>
<style>
*{box-sizing:border-box;margin:0;padding:0}
:root{--blue:__BLUE__;--blued:__BLUED__;--yellow:__ACCENT__;--yellow2:__ACCENT2__;
 --ink:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;--glass:rgba(255,255,255,.055);--glassb:rgba(255,255,255,.10)}
html{scroll-behavior:smooth}
body{background:__BG__;color:var(--ink);font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;-webkit-font-smoothing:antialiased;overflow-x:hidden}
.aurora{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}
.aurora::before{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(27,63,208,.5),transparent 70%);animation:f1 24s ease-in-out infinite}
.aurora::after{content:"";position:absolute;width:56vw;height:56vw;right:-14vw;top:6vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(13,33,133,.55),transparent 70%);animation:f2 28s ease-in-out infinite}
.aurora .blob{position:absolute;width:40vw;height:40vw;left:34vw;bottom:-14vw;border-radius:50%;filter:blur(90px);background:radial-gradient(circle,rgba(__GLOW__,.2),transparent 70%);animation:f3 32s ease-in-out infinite}
@keyframes f1{50%{transform:translate(6vw,8vh) scale(1.15)}}
@keyframes f2{50%{transform:translate(-7vw,10vh) scale(1.12)}}
@keyframes f3{50%{transform:translate(-9vw,-9vh) scale(1.22)}}
.grain{position:fixed;inset:0;z-index:-1;opacity:.045;pointer-events:none;background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}
.hero-bar{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:18px;padding:14px 32px;
 backdrop-filter:blur(20px) saturate(150%);-webkit-backdrop-filter:blur(20px) saturate(150%);
 background:rgba(6,10,26,.6);border-bottom:1px solid rgba(255,255,255,.06)}
.hero-bar img{height:34px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}
.hero-bar .hb-sep{width:1px;height:28px;background:rgba(255,255,255,.15);flex-shrink:0}
.hero-bar .crumb{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}
.hero-bar .crumb em{color:var(--yellow);font-style:normal}
.hero-bar .hb-sp{flex:1}
.hero-bar a.back{font-size:12px;color:var(--muted);padding:6px 13px;border-radius:20px;border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s}
.hero-bar a.back:hover{color:var(--ink);background:rgba(255,255,255,.07)}
.glass{background:var(--glass);backdrop-filter:blur(22px) saturate(155%);-webkit-backdrop-filter:blur(22px) saturate(155%);
 border:1px solid var(--glassb);border-radius:22px;box-shadow:0 12px 44px rgba(0,0,0,.36),inset 0 1px 0 rgba(255,255,255,.10)}
.wrap{max-width:1200px;margin:0 auto;padding:0 30px}
section{padding:64px 0;scroll-margin-top:70px}
.hero{padding:88px 0 28px}
.hero-body{display:flex;align-items:flex-end;gap:48px;flex-wrap:wrap;margin-top:30px}
.hero-title{flex:1;min-width:300px}
.hero-label{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}
.hero-h1{font-size:clamp(30px,5vw,54px);font-weight:900;letter-spacing:-.035em;line-height:1.02;
 background:linear-gradient(176deg,#fff 34%,#9fb4ff);-webkit-background-clip:text;background-clip:text;color:transparent}
.hero-sub{margin-top:16px;font-size:14px;color:var(--muted);line-height:1.68;max-width:62ch}
.hero-sub b{color:#e4eaff;font-weight:600}
.hero-stats{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end;padding-bottom:4px}
.stat-block{background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08);border-radius:14px;padding:16px 22px;min-width:104px}
.stat-block .sn{font-size:28px;font-weight:900;letter-spacing:-.03em;font-variant-numeric:tabular-nums;line-height:1;
 background:linear-gradient(135deg,var(--yellow),var(--yellow2));-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.stat-block.blue .sn{background:linear-gradient(135deg,#93c5fd,#6f8ce6);-webkit-background-clip:text;-webkit-text-fill-color:transparent;background-clip:text}
.stat-block .sl{font-size:9px;font-weight:600;letter-spacing:.08em;text-transform:uppercase;color:var(--muted2);margin-top:5px}
.shead{margin-bottom:30px}
.kick{font-size:12px;font-weight:700;letter-spacing:.2em;text-transform:uppercase;color:var(--yellow);margin-bottom:12px}
.shead h2{font-size:clamp(23px,3.2vw,38px);font-weight:800;letter-spacing:-.025em;line-height:1.08}
.shead p{color:var(--muted);font-size:14px;margin-top:14px;max-width:78ch;line-height:1.68}
.shead p b{color:#e4eaff;font-weight:600}
.prose{color:var(--muted);font-size:14px;line-height:1.75;max-width:80ch}
.prose + .prose{margin-top:14px}
.prose b{color:#e4eaff;font-weight:600}
.cols3{display:grid;grid-template-columns:repeat(3,1fr);gap:16px;margin-top:8px}
@media(max-width:900px){.cols3{grid-template-columns:1fr}}
.cols2{display:grid;grid-template-columns:1fr 1fr;gap:16px}
@media(max-width:900px){.cols2{grid-template-columns:1fr}}
.card{padding:24px 26px}
.card h4{font-size:12px;color:var(--yellow);text-transform:uppercase;letter-spacing:.09em;margin-bottom:10px;font-weight:700}
.card p{font-size:13.5px;color:var(--muted);line-height:1.68}
.card p b{color:#fff;font-weight:600}
.card ul{list-style:none;margin-top:10px}
.card li{font-size:13px;color:var(--muted);padding:6px 0;border-bottom:1px solid rgba(255,255,255,.05);display:flex;justify-content:space-between;gap:12px}
.card li:last-child{border-bottom:none}
.card li b{color:#e4eaff;font-weight:600}
table{width:100%;border-collapse:collapse;font-size:12.5px}
.tblwrap{overflow-x:auto;padding:6px;border-radius:22px}
th{text-align:left;font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--muted2);
 padding:12px 12px;border-bottom:1px solid rgba(255,255,255,.12);white-space:nowrap}
td{padding:11px 12px;border-bottom:1px solid rgba(255,255,255,.055);color:var(--muted);vertical-align:top}
tr:last-child td{border-bottom:none}
tbody tr:hover td{background:rgba(255,255,255,.03)}
td.num,th.num{text-align:right;font-variant-numeric:tabular-nums;white-space:nowrap}
td.strong{color:#e8edff;font-weight:600}
td.hot{color:var(--yellow);font-weight:700}
td.mono,.mono{font-family:'SF Mono',ui-monospace,SFMono-Regular,Menlo,monospace;font-size:11.5px;color:#c9d3f5}
td.dim,.dim{color:var(--muted2)}
tr.total td{border-top:1px solid rgba(255,255,255,.14);background:rgba(255,255,255,.03);font-weight:700;color:#e8edff}
.pill{display:inline-block;padding:2px 9px;border-radius:9px;font-size:10px;font-weight:700}
.pill.risk{color:#ffa94d;background:rgba(255,169,77,.12);border:1px solid rgba(255,169,77,.3)}
.pill.mute{color:var(--muted2);background:rgba(255,255,255,.05);border:1px solid rgba(255,255,255,.1)}
pre{font-family:'SF Mono',ui-monospace,SFMono-Regular,Menlo,monospace;font-size:11.8px;line-height:1.72;color:#dbe3ff;
 padding:24px 26px;overflow-x:auto;white-space:pre;border-radius:18px;background:rgba(0,0,0,.34);border:1px solid rgba(255,255,255,.08)}
pre .c{color:#6f7aa3;font-style:italic}
pre .k{color:var(--yellow);font-weight:600}
pre .s{color:#8fd3a0}
pre .f{color:#93c5fd}
pre .d{color:#c9a2ff}
.codehead{display:flex;align-items:center;gap:10px;margin-bottom:12px}
.codehead .tag{font-size:9.5px;font-weight:800;letter-spacing:.1em;text-transform:uppercase;color:var(--yellow);
 padding:4px 10px;border-radius:8px;background:rgba(__GLOW__,.09);border:1px solid rgba(__GLOW__,.25)}
.codehead .nm{font-size:13px;font-weight:700;color:#e8edff}
.hero-bar a.cta-bar{color:#10101e;background:var(--yellow);border-color:var(--yellow);font-weight:700}
.hero-bar a.cta-bar:hover{background:var(--yellow2);color:#10101e}
.cta{display:flex;align-items:center;gap:26px;margin-top:22px;padding:26px 30px;border-radius:20px;text-decoration:none;
 background:linear-gradient(120deg,rgba(__GLOW__,.13),rgba(255,255,255,.04));border:1px solid rgba(__GLOW__,.32);
 transition:transform .3s cubic-bezier(.16,1,.3,1),border-color .3s,box-shadow .3s}
.cta:hover{transform:translateY(-3px);border-color:rgba(__GLOW__,.6);box-shadow:0 20px 50px rgba(0,0,0,.42)}
.cta-k{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:9px}
.cta-t{font-size:21px;font-weight:800;letter-spacing:-.02em;color:#fff}
.cta-d{font-size:13px;color:var(--muted);line-height:1.65;margin-top:9px;max-width:74ch}
.cta-arr{font-size:30px;color:var(--yellow);flex-shrink:0;transition:transform .3s}
.cta:hover .cta-arr{transform:translateX(7px)}
.note{margin-top:20px;padding:18px 22px;border-radius:16px;font-size:13px;color:var(--muted);line-height:1.68;
 background:rgba(255,255,255,.04);border:1px solid rgba(__GLOW__,.18)}
.note b{color:#e4eaff}
.flow{display:grid;grid-template-columns:repeat(5,1fr);gap:12px;margin-top:10px}
@media(max-width:940px){.flow{grid-template-columns:1fr 1fr}}
.step{padding:20px 20px;border-radius:16px;background:rgba(255,255,255,.04);border:1px solid rgba(255,255,255,.08)}
.step .n{font-size:10px;font-weight:800;color:var(--yellow);letter-spacing:.12em;margin-bottom:9px}
.step h5{font-size:13.5px;font-weight:800;margin-bottom:7px;letter-spacing:-.01em}
.step p{font-size:12px;color:var(--muted2);line-height:1.6}
footer{text-align:center;padding:44px 30px 60px;font-size:11.5px;color:var(--muted2);border-top:1px solid rgba(255,255,255,.06);line-height:1.8}
footer code{color:var(--muted);font-family:'SF Mono',ui-monospace,monospace}
</style></head><body>
<div class="aurora"><div class="blob"></div></div><div class="grain"></div>

<div class="hero-bar">
  <img src="__LOGO__" alt="__ALT__">
  <div class="hb-sep"></div>
  <span class="crumb">__CRUMB__ &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>ACELERACIÓN DE PRUEBAS</em></span>
  <span class="hb-sp"></span>
  <a href="__CATALOGO__" class="back cta-bar">Ver los __CASOS_TOTAL__ casos</a>
  <a href="__BACK__" class="back">Volver al portal</a>
</div>

<section class="hero wrap">
  <div class="hero-body">
    <div class="hero-title">
      <div class="hero-label">Quality Engineering · Shift-left</div>
      <h1 class="hero-h1">El gemelo como<br>fábrica de pruebas</h1>
      <p class="hero-sub">El mismo corpus que se extrajo para <b>entender</b> el legacy es, sin trabajo adicional, la
        <b>especificación de prueba</b> del target. Cada regla de negocio es un caso candidato con su técnica de diseño,
        cada journey es un escenario de extremo a extremo, y cada procedimiento con tráfico medido en producción es un
        perfil de carga que ya trae su propio umbral de latencia.</p>
    </div>
    <div class="hero-stats">
      <div class="stat-block"><div class="sn">__CASOS_TOTAL__</div><div class="sl">Casos candidatos</div></div>
      <div class="stat-block blue"><div class="sn">__JOURNEYS__</div><div class="sl">Escenarios E2E</div></div>
      <div class="stat-block blue"><div class="sn">__SPS_PROD__</div><div class="sl">Perfiles de carga</div></div>
      <div class="stat-block"><div class="sn">__RULES_RIESGO__</div><div class="sl">Reglas con riesgo</div></div>
    </div>
  </div>
</section>

<!-- ═══ POR QUÉ CAMBIA EL ORDEN DEL TRABAJO ═══ -->
<section class="wrap" id="porque">
  <div class="shead">
    <div class="kick">El problema</div>
    <h2>Las pruebas no se diseñan tarde<br>por falta de tiempo, sino por falta de insumo</h2>
    <p>En una modernización, el equipo de pruebas suele entrar cuando ya hay código que probar. Para entonces nadie
      sabe cuántos casos hacen falta, la documentación funcional del legacy no existe o está desactualizada, y el
      comportamiento esperado se reconstruye preguntando. El gate de <b>equivalencia funcional</b> llega sin corpus de
      regresión y la fecha de cutover empieza a negociarse contra la calidad.</p>
  </div>
  <div class="cols3">
    <div class="card glass">
      <h4>Sin gemelo</h4>
      <p>El alcance de prueba se estima por analogía. Los casos se escriben leyendo código, procedimiento por
        procedimiento, y cada uno cuesta horas de un analista que además debe entender el dominio. El resultado
        es <b>cobertura desconocida</b>: nadie puede decir qué porcentaje del comportamiento quedó cubierto.</p>
    </div>
    <div class="card glass">
      <h4>Con gemelo</h4>
      <p>El alcance es un dato: <b>__REGLAS__ reglas</b> extraídas y validadas contra el código fuente, cada una con su
        tipo, su dominio, su regulador y su riesgo de equivalencia. El caso de prueba se deriva de la regla con una
        técnica declarada, y la cobertura se mide contra el corpus completo.</p>
    </div>
    <div class="card glass">
      <h4>Lo que se gana</h4>
      <p>El diseño de pruebas se adelanta a <b>DISCOVER</b>, antes de que exista una línea de código del target. La
        Definition of Ready del componente incluye los casos ya identificados, y el corpus de regresión está listo
        cuando arranca el parallel-run, no después.</p>
    </div>
  </div>
</section>

<!-- ═══ CADENA DE DERIVACIÓN ═══ -->
<section class="wrap" id="derivacion">
  <div class="shead">
    <div class="kick">Cómo se derivan</div>
    <h2>De artefacto del gemelo<br>a caso de prueba</h2>
    <p>Cada artefacto del gemelo mapea a una técnica estándar de diseño de pruebas. El multiplicador está a la vista
      para que el número sea defendible frente al QA Lead: no es una estimación, es una cuenta con su regla de
      derivación explícita. El total es el <b>universo candidato</b>, antes de consolidar reglas repetidas entre
      procedimientos y antes de la poda que decide el QA Lead.</p>
  </div>
  <div class="tblwrap glass">
    <table>
      <thead><tr><th>Artefacto del gemelo</th><th class="num">Volumen</th><th>Técnica de diseño de prueba</th><th class="num">Casos por unidad</th><th class="num">Casos derivados</th></tr></thead>
      <tbody>__TBL_DERIVACION__</tbody>
    </table>
  </div>
  <div class="cols2" style="margin-top:18px">
    <div class="card glass">
      <h4>Riesgo de equivalencia declarado</h4>
      <p>__RULES_RIESGO__ reglas traen marcado el motivo por el que el target puede divergir del legacy. Cada una es un
        caso de prueba obligatorio del parallel-run, no opcional.</p>
      <ul>__RIESGO_TOP__</ul>
    </div>
    <div class="card glass">
      <h4>Obligación regulatoria</h4>
      <p>__RULES_REG__ reglas están ligadas a un regulador. Esos casos no se negocian con la fecha: su evidencia de
        ejecución es insumo de auditoría.</p>
      <ul>__SUB_TOP__</ul>
    </div>
  </div>
  <div class="note">Reguladores presentes en el corpus: __REG_TOP__.</div>

  <a class="cta" href="__CATALOGO__">
    <div>
      <div class="cta-k">El catálogo no es una promesa</div>
      <div class="cta-t">Ver los __CASOS_TOTAL__ casos, uno por uno</div>
      <div class="cta-d">Cada caso con su técnica, su prioridad, su regulador y el fragmento de código que lo
        sustenta. Filtrable por dominio, por regulador y por riesgo de equivalencia, y descargable en CSV para
        importarlo al ALM del equipo de pruebas.</div>
    </div>
    <span class="cta-arr">→</span>
  </a>
</section>

<!-- ═══ PRIORIZACIÓN ═══ -->
<section class="wrap" id="prioridad">
  <div class="shead">
    <div class="kick">Qué se prueba primero</div>
    <h2>No se prueban __SPS_TOTAL__ procedimientos.<br>Se prueba donde se concentra el riesgo</h2>
    <p>El orden lo decide el cruce de dos evidencias que el gemelo ya tiene: cuántos casos derivan de cada componente y
      cuánto tráfico real soporta en producción. El puntaje es <b>casos derivados × log₁₀(1 + llamadas por día)</b>,
      visible y discutible. El logaritmo es deliberado: manda la densidad de reglas y el tráfico solo modula. Por eso
      sube un procedimiento de crédito con veintidós reglas y poco volumen, donde una divergencia de centavos se
      convierte en un hallazgo regulatorio, y no una consulta con cientos de miles de llamadas y ninguna regla
      financiera. Esa consulta importa, pero importa en la prueba de carga, que es la sección siguiente.</p>
  </div>
  <div class="tblwrap glass">
    <table>
      <thead><tr><th>Procedimiento</th><th>Dominio</th><th>Qué hace</th><th class="num">Reglas</th><th class="num">Casos</th><th class="num">Llamadas/día</th><th class="num">P95</th><th class="num">Riesgo</th><th>Regulador</th></tr></thead>
      <tbody>__TBL_RANKING__</tbody>
    </table>
  </div>
  <div class="note">Telemetría de producción con fecha de evidencia <b>__EVIDENCE__</b>. La columna de riesgo cuenta
    las reglas del componente con divergencia declarada entre el motor legacy y el target.</div>
</section>

<!-- ═══ CASOS FUNCIONALES ═══ -->
<section class="wrap" id="funcional">
  <div class="shead">
    <div class="kick">Scripts funcionales</div>
    <h2>De la regla al caso ejecutable</h2>
    <p>El gemelo guarda, por cada regla, el procedimiento, la línea y el fragmento de código que la sustenta. Con eso
      el caso de prueba se genera con su trazabilidad incluida: quien lo revise puede ir al código fuente y verificar
      que el caso corresponde al comportamiento real, no a una interpretación.</p>
  </div>
  <div class="codehead"><span class="tag">Valores límite</span><span class="nm">Regla de umbral generada como escenario Gherkin</span></div>
  <pre>__GHERKIN__</pre>
  <div class="note">Un umbral produce siempre tres casos. El del medio es el que normalmente se olvida al escribir
    pruebas a mano, y es justo donde aparecen las divergencias de comparación entre el motor legacy y el target.</div>
</section>

<!-- ═══ EQUIVALENCIA ═══ -->
<section class="wrap" id="equivalencia">
  <div class="shead">
    <div class="kick">Equivalencia funcional</div>
    <h2>El comparador nace<br>con el riesgo ya identificado</h2>
    <p>Las fórmulas financieras son el caso donde la equivalencia se rompe en silencio: el resultado se parece, pero
      difiere en centavos. El gemelo marca el motivo concreto de la divergencia (modo de redondeo, truncamiento, base
      del año) y el comparador se genera probando exactamente eso, en lugar de confiar en que el target heredó el
      comportamiento correcto.</p>
  </div>
  <div class="codehead"><span class="tag">Golden master</span><span class="nm">Comparador generado desde una fórmula con riesgo declarado</span></div>
  <pre>__GOLDEN__</pre>
  <div class="note">El gate <b>EQUIVALENCE-CHECK</b> del pipeline de CI bloquea la promoción cuando la diferencia
    supera el umbral acordado. El corpus de insumos sale del parallel-run; el resultado esperado sale del legacy
    ejecutando en paralelo, no de una especificación escrita a mano.</div>
</section>

<!-- ═══ PERFORMANCE ═══ -->
<section class="wrap" id="performance">
  <div class="shead">
    <div class="kick">Scripts de performance</div>
    <h2>La tasa de llegada no es un supuesto:<br>está medida</h2>
    <p>El error habitual de una prueba de carga es inventar el escenario. Aquí la mezcla de transacciones, la tasa de
      llegada y el umbral de latencia salen de la telemetría de producción que el gemelo ya incorporó:
      <b>__SPS_PROD__ procedimientos</b> con tráfico medido, <b>__CALLS_DAY__ llamadas al día</b> y
      <b>__CANALES__ sistemas llamadores</b> distintos identificados. El umbral del target se fija en el percentil
      que el legacy ya entrega hoy, de modo que la prueba falla si la modernización degrada el servicio.</p>
  </div>
  <div class="tblwrap glass">
    <table>
      <thead><tr><th>Procedimiento</th><th>Qué hace</th><th class="num">Llamadas/día</th><th class="num">Llamadas/s</th><th class="num">P50</th><th class="num">P95</th><th class="num">P99</th><th class="num">Error</th><th class="num">Llamadores</th></tr></thead>
      <tbody>__TBL_CARGA__</tbody>
    </table>
  </div>
  <div class="codehead" style="margin-top:28px"><span class="tag">k6</span><span class="nm">Perfil de carga generado desde la telemetría</span></div>
  <pre>__K6__</pre>
  <div class="note"><b>Sobre el perfil plano:</b> la tasa por segundo de la tabla es el promedio del día. El pico real
    se toma de las curvas intradía del portal, que trabajan en ventanas de cinco minutos, y de los percentiles
    correlacionados que muestran cuándo coinciden las cargas de pagos y de autorización. Un escenario de carga que
    use el promedio diario subestima el pico y aprueba un target que después se cae en la hora crítica.</div>
</section>

<!-- ═══ RESILIENCIA Y BATCH ═══ -->
<section class="wrap" id="resiliencia">
  <div class="shead">
    <div class="kick">Dos frentes que se olvidan</div>
    <h2>Resiliencia y ventana batch</h2>
  </div>
  <div class="cols2">
    <div class="card glass">
      <h4>Casos de resiliencia con evidencia</h4>
      <p>El legacy ya falla en producción con una tasa conocida. Esos componentes necesitan prueba de degradación y de
        reintento en el target, con el comportamiento de error como criterio de aceptación explícito.</p>
      <div class="tblwrap" style="margin-top:12px">
        <table>
          <thead><tr><th>Procedimiento</th><th>Qué hace</th><th class="num">Llamadas/día</th><th class="num">Error</th></tr></thead>
          <tbody>__TBL_ERRORES__</tbody>
        </table>
      </div>
    </div>
    <div class="card glass">
      <h4>La ventana batch es el requisito</h4>
      <p>El gemelo tiene la malla de orquestación: <b>__CTM_JOBS__ jobs</b> en <b>__CTM_FOLDERS__ carpetas</b>, con
        <b>__CTM_SP__ procedimientos</b> confirmados como punto de entrada de un job. Para un proceso batch, la prueba
        de performance no es la latencia por transacción sino que el proceso completo quepa en su ventana.</p>
      <p style="margin-top:12px">El criterio de aceptación se escribe desde ahí: volumen del día de mayor carga,
        tiempo máximo de ejecución y dependencia con el job siguiente. Es el mismo dato que se usa para dimensionar
        el target, de modo que la prueba y el sizing no se contradicen.</p>
    </div>
  </div>
</section>

<!-- ═══ PIPELINE ═══ -->
<section class="wrap" id="pipeline">
  <div class="shead">
    <div class="kick">Cómo se opera</div>
    <h2>Un pipeline, no un entregable</h2>
    <p>Los casos y los scripts no son un documento que envejece: son salida de un generador que lee el brain. Cuando
      el conocimiento del legacy mejora, la suite se regenera y la trazabilidad hasta el código fuente se mantiene.</p>
  </div>
  <div class="flow">
    <div class="step"><div class="n">01</div><h5>Brain</h5><p>Reglas, journeys, códigos de retorno y telemetría, validados contra el código fuente.</p></div>
    <div class="step"><div class="n">02</div><h5>Derivación</h5><p>Cada regla produce sus casos según la técnica que le corresponde, con trazabilidad al procedimiento y la línea.</p></div>
    <div class="step"><div class="n">03</div><h5>Priorización</h5><p>El orden sale del cruce entre casos derivados, riesgo de equivalencia y tráfico real.</p></div>
    <div class="step"><div class="n">04</div><h5>Generación</h5><p>Escenarios funcionales, comparadores de equivalencia y perfiles de carga listos para el repositorio de pruebas.</p></div>
    <div class="step"><div class="n">05</div><h5>Gate en CI</h5><p>La equivalencia bloquea la promoción; la carga valida que el target no degrada el servicio actual.</p></div>
  </div>
  <div class="note">Encaje con el lifecycle: la identificación de casos ocurre en <b>DISCOVER</b> y entra a la
    Definition of Ready del componente; los comparadores se construyen en <b>BUILD</b>; el gate de equivalencia y el
    parallel-run se ejecutan en <b>TEST</b>, antes del cutover por capability.</div>
</section>

<footer>
  __CRUMB__ · SPE-AM-001 · Vista generada por <code>build-test-acceleration.py</code> desde <code>brain.db</code>.<br>
  __REGLAS__ reglas · __JOURNEYS__ journeys (__JOURNEYS_ORQ__ orquestadores y __JOURNEYS_EXP__ servicios expuestos) ·
  __CODRET__ códigos de retorno · telemetría de producción con evidencia __EVIDENCE__.
</footer>
</body></html>"""


# ═════════════════════════════════════════════════════════════════════════════
def main():
    ap = argparse.ArgumentParser(description="Vista de aceleración de pruebas desde el brain")
    ap.add_argument("--no-inject", action="store_true", help="Solo escribe las vistas")
    ap.add_argument("--brand", choices=list(BRANDS) + ["all"], default="all")
    args = ap.parse_args()

    con = sqlite3.connect(str(DB))
    d = collect(con)
    con.close()

    print(f"Brain: {DB.name}")
    print(f"  reglas {d['rules_total']:,} · negocio {d['negocio']:,} · "
          f"reg {d['rules_reg']:,} · riesgo {d['rules_riesgo']:,}")
    print(f"  journeys {d['journeys']} · códigos de retorno {d['codret']} · "
          f"casos candidatos {d['casos_total']:,}")
    print(f"  producción: {d['sps_prod']} SPs · {d['calls_day']:,} llamadas/día · "
          f"{d['canales']} canales · evidencia {d['evidence_date']}")

    marcas = list(BRANDS) if args.brand == "all" else [args.brand]
    for key in marcas:
        b = BRANDS[key]
        b["out"].parent.mkdir(parents=True, exist_ok=True)
        htmlout = render(d, b)
        b["out"].write_text(htmlout, encoding="utf-8")
        print(f"\n[{key}] {b['out'].relative_to(BASE)} · {len(htmlout):,} bytes")
        if not args.no_inject:
            inject(d, b)


if __name__ == "__main__":
    main()
