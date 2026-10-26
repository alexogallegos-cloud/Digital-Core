#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-test-catalog.py — Materializa el catálogo de casos de prueba del gemelo.

La vista de aceleración (build-test-acceleration.py) muestra la cuenta y el método;
este generador escribe los casos uno por uno, con su trazabilidad al código fuente,
para que el equipo de pruebas los pueda revisar, filtrar e importar a su ALM.

Derivación (misma que declara la vista, aquí ejecutada):
  VALIDACIÓN  ×2  camino verdadero y camino falso
  UMBRAL      ×3  límite inferior, valor exacto, límite superior
  FÓRMULA     ×1  golden master contra el legacy
  ESTADO      ×2  transición válida e inválida
  codret      ×1  prueba negativa por código de retorno catalogado
  journey     ×1  escenario de extremo a extremo

Salidas por marca:
  portal/test-catalog-bcop.html        + portal/data/test-cases.json     + .csv
  sanitized/test-catalog-legacy.html   + sanitized/data/test-cases.json  + .csv

El HTML carga el JSON vía fetch(): requiere servirse por HTTP, no abrirse con file://

Uso:
  python generators/build-test-catalog.py
  python generators/build-test-catalog.py --brand bcop

SPE-AM-001 · Specialist Informix SPL · QE shift-left
"""

import sys, re, csv, json, html, sqlite3, argparse
from pathlib import Path
from collections import Counter

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent
DB   = BASE / "digital-brain" / "brain.db"

# Las marcas replican las de build-test-acceleration.py. No se importan porque el
# nombre de ese módulo lleva guiones y no es importable; al tocar la paleta o los
# tokens de saneado hay que cambiar ambos archivos.
BRANDS = {
    "bcop": {
        "html":  BASE / "portal" / "test-catalog-bcop.html",
        "data":  BASE / "portal" / "data" / "test-cases.json",
        "csv":   BASE / "portal" / "data" / "test-cases.csv",
        "back":  "index-bcop-v2.html", "vista": "test-acceleration-bcop.html",
        "datos": "test-data-bcop.html",
        "logo":  "bancoppel-logo.png", "alt": "BanCoppel",
        "crumb": "BCOPCORE", "sys": "Informix",
        "accent": "#F0D224", "accent2": "#f6e27a", "blue": "#3D5FCD", "blued": "#122FB1",
        "bg": "#060a1a", "glow": "240,210,36", "scrub": False,
    },
    "legacy": {
        "html":  BASE / "sanitized" / "test-catalog-legacy.html",
        "data":  BASE / "sanitized" / "data" / "test-cases.json",
        "csv":   BASE / "sanitized" / "data" / "test-cases.csv",
        "back":  "index-legacy.html", "vista": "test-acceleration-legacy.html",
        "datos": "test-data-legacy.html",
        "logo":  "accenture-logo.png", "alt": "Accenture",
        "crumb": "LEGACYCORE", "sys": "LegacyCore",
        "accent": "#A100FF", "accent2": "#c77dff", "blue": "#7C4DCF", "blued": "#6B21A8",
        "bg": "#14142b", "glow": "161,0,255", "scrub": True,
    },
}

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


def scrub(txt, on):
    if not on or not txt:
        return txt
    for rx, rep in SCRUB:
        txt = rx.sub(rep, str(txt))
    return txt


def jlist(raw):
    if not raw:
        return []
    try:
        v = json.loads(raw)
        return [x for x in v if x] if isinstance(v, list) else ([v] if v else [])
    except Exception:
        return [p.strip() for p in str(raw).split(";") if p.strip()]


def regs_de(raw):
    out = []
    for x in jlist(raw):
        out += [p.strip() for p in str(x).split(";") if p.strip()]
    return sorted(set(out))


def cap(s):
    s = (s or "").strip()
    return s[0].upper() + s[1:] if s else s


def corto(s, n=150):
    s = re.sub(r"\s+", " ", (s or "").strip())
    return s if len(s) <= n else s[: n - 1] + "…"


# ═════════════════════════════════════════════════════════════════════════════
# Derivación de casos
# ═════════════════════════════════════════════════════════════════════════════
CMP = re.compile(r"(>=|<=|<>|!=|>|<|=)\s*'?([\d]+(?:[.,]\d+)?)'?")

TECNICAS = {
    "EQ":  "Partición de equivalencia",
    "BVA": "Valores límite",
    "GM":  "Golden master",
    "ST":  "Transición de estado",
    "NEG": "Prueba negativa",
    "E2E": "Extremo a extremo",
}


def prioridad(riesgo, regs, calls):
    """P1 lo que no se puede negociar con la fecha; P2 lo que el volumen vuelve visible."""
    if riesgo:
        return "P1"
    if regs:
        return "P1"
    if calls and calls >= 10000:
        return "P2"
    return "P3"


def casos_de_regla(r, calls):
    """Devuelve la lista de casos que derivan de una regla, según su tipo."""
    rid   = r["id"]
    nom   = cap(r["business_name"] or f"Regla {rid}")
    tipo  = r["tipo"]
    code  = re.sub(r"\s+", " ", (r["code"] or "").strip())
    regs  = regs_de(r["reg"])
    riesg = jlist(r["riesgo"])
    pri   = prioridad(riesg, regs, calls)
    base  = {"regla": rid, "sp": r["sp"], "db": r["db"], "dom": r["domain"],
             "linea": r["line"], "code": code, "reg": regs, "riesgo": riesg,
             "sub": r["sub_tipo"] or "", "pri": pri, "calls": calls or 0}
    out = []

    def add(seq, tec, clase, titulo, dado, cuando, entonces):
        out.append(dict(base, id=f"TC-{rid}-{seq:02d}", tec=tec, clase=clase,
                        titulo=titulo, dado=dado, cuando=cuando, entonces=entonces))

    if tipo == "VALIDACIÓN":
        add(1, "EQ", "positivo", f"{nom} — la condición se cumple",
            "Un caso cuyos datos satisfacen la condición de la regla",
            f"se ejecuta la validación {rid}",
            "la operación continúa su flujo normal y no se registra rechazo")
        add(2, "EQ", "negativo", f"{nom} — la condición no se cumple",
            "Un caso cuyos datos incumplen la condición de la regla",
            f"se ejecuta la validación {rid}",
            "la operación se rechaza con el mismo código y mensaje que devuelve el legacy")

    elif tipo == "UMBRAL":
        m = CMP.search(code)
        op = m.group(1) if m else ">="
        try:
            v = float((m.group(2) if m else "0").replace(",", ""))
            lo, ex, hi = f"{v - 0.01:,.2f}", f"{v:,.2f}", f"{v + 0.01:,.2f}"
        except (AttributeError, ValueError):
            lo, ex, hi = "límite menos delta", "el límite exacto", "límite más delta"
        incl = op in (">=", "<=", "=")
        cumple_ex = "sí" if incl else "no"
        add(1, "BVA", "límite", f"{nom} — valor por debajo del límite",
            f"Un caso cuyo valor evaluado es {lo}",
            f"se aplica el umbral {rid} ({op} {ex})",
            "la condición del umbral no se cumple")
        add(2, "BVA", "límite", f"{nom} — valor exacto en el límite",
            f"Un caso cuyo valor evaluado es exactamente {ex}",
            f"se aplica el umbral {rid} ({op} {ex})",
            f"la condición del umbral se cumple: {cumple_ex} — el operador es inclusivo"
            if incl else
            "la condición del umbral no se cumple: el operador es estricto")
        add(3, "BVA", "límite", f"{nom} — valor por encima del límite",
            f"Un caso cuyo valor evaluado es {hi}",
            f"se aplica el umbral {rid} ({op} {ex})",
            "la condición del umbral se cumple")

    elif tipo == "FÓRMULA":
        det = f" Divergencia a vigilar: {'; '.join(riesg)}." if riesg else ""
        add(1, "GM", "equivalencia", f"{nom} — equivalencia de cálculo",
            "Un lote de insumos reales capturado del parallel-run",
            f"se calcula la fórmula {rid} en el legacy y en el componente nuevo",
            f"ambos resultados coinciden hasta el último centavo.{det}")

    elif tipo == "ESTADO":
        add(1, "ST", "positivo", f"{nom} — transición válida",
            "Un registro en el estado de origen que admite la transición",
            f"se aplica el cambio de estado {rid}",
            "el registro queda en el estado destino y se escribe la bitácora correspondiente")
        add(2, "ST", "negativo", f"{nom} — transición inválida",
            "Un registro en un estado que no admite la transición",
            f"se aplica el cambio de estado {rid}",
            "el cambio se rechaza y el estado original permanece sin cambios")

    return out


def casos_de_codret(c):
    code = str(c["code"])
    desc = cap(c["description_es"] or f"Código de retorno {code}")
    return {
        "id": f"TC-RC-{code}", "regla": f"codret:{code}", "sp": "", "db": "",
        "dom": "", "linea": None, "code": corto(c["evidence"] or "", 120),
        "reg": [], "riesgo": [], "sub": c["category"] or "", "pri": "P2", "calls": 0,
        "tec": "NEG", "clase": "negativo",
        "titulo": f"Código de retorno {code} — {desc}",
        "dado": "Las condiciones que el legacy traduce en este código de retorno",
        "cuando": f"se provoca el escenario de error asociado al código {code}",
        "entonces": f"el componente nuevo devuelve el mismo código {code} y un mensaje equivalente",
    }


def casos_de_journey(j):
    nom = cap(j["biz"] or j["sp"])
    regs = regs_de(j["reg"])
    return {
        "id": f"TC-J-{j['id']}", "regla": f"journey:{j['sp']}", "sp": j["sp"],
        "db": j["db"], "dom": j["domain"], "linea": None, "code": "",
        "reg": regs, "riesgo": [], "sub": j["journey_type"] or "",
        "pri": "P1" if regs else "P2", "calls": 0,
        "tec": "E2E", "clase": "flujo",
        "titulo": f"{nom} — recorrido completo",
        "dado": f"Los datos de entrada del journey en el dominio {j['domain']}",
        "cuando": f"se ejecuta el flujo completo de {j['sp']} con sus {j['fan_out'] or 0} llamadas encadenadas",
        "entonces": "cada paso produce el mismo resultado que el legacy y el flujo termina en el mismo estado",
    }


def derivar(con):
    con.row_factory = sqlite3.Row
    calls = {f"{r['db']}:{r['name']}": (r["prod_calls_day"] or 0)
             for r in con.execute("SELECT db, name, prod_calls_day FROM sps")}

    casos = []
    for r in con.execute("""SELECT id, tipo, sub_tipo, clase, sp, db, domain, line,
                                   code, reg, riesgo, business_name FROM rules"""):
        casos += casos_de_regla(r, calls.get(r["sp"], 0))
    for c in con.execute("SELECT code, category, description_es, evidence FROM codret_dictionary"):
        casos.append(casos_de_codret(c))
    for j in con.execute("""SELECT id, sp, db, domain, biz, reg, journey_type, fan_out
                            FROM journeys"""):
        casos.append(casos_de_journey(j))
    return casos


# ═════════════════════════════════════════════════════════════════════════════
# Salidas
# ═════════════════════════════════════════════════════════════════════════════
CAMPOS_CSV = ["id", "titulo", "tecnica", "clase", "prioridad", "dominio", "procedimiento",
              "linea", "regla", "regulador", "riesgo_equivalencia", "dado", "cuando",
              "entonces", "evidencia_codigo", "llamadas_dia"]


def escribir(casos, b):
    on = b["scrub"]
    slim, filas = [], []
    for c in casos:
        s = {
            "i": scrub(c["id"], on), "t": scrub(c["titulo"], on), "tc": c["tec"],
            "cl": c["clase"], "p": c["pri"], "d": c["dom"] or "",
            "sp": scrub(c["sp"], on), "l": c["linea"], "rl": scrub(c["regla"], on),
            "r": c["reg"], "k": [scrub(x, on) for x in c["riesgo"]],
            "sb": c["sub"], "cd": scrub(corto(c["code"]), on), "cn": c["calls"],
            "g": [scrub(c["dado"], on), scrub(c["cuando"], on), scrub(c["entonces"], on)],
        }
        slim.append(s)
        filas.append({
            "id": s["i"], "titulo": s["t"], "tecnica": TECNICAS[c["tec"]], "clase": c["clase"],
            "prioridad": c["pri"], "dominio": s["d"], "procedimiento": s["sp"],
            "linea": c["linea"] or "", "regla": s["rl"], "regulador": "; ".join(c["reg"]),
            "riesgo_equivalencia": "; ".join(s["k"]), "dado": s["g"][0], "cuando": s["g"][1],
            "entonces": s["g"][2], "evidencia_codigo": s["cd"], "llamadas_dia": c["calls"],
        })

    meta = {
        "total": len(slim),
        "por_tecnica": dict(Counter(TECNICAS[c["tec"]] for c in casos)),
        "por_prioridad": dict(Counter(c["pri"] for c in casos)),
        "por_clase": dict(Counter(c["clase"] for c in casos)),
        "dominios": sorted({c["dom"] for c in casos if c["dom"]}),
        "reguladores": dict(Counter(x for c in casos for x in c["reg"])),
        "con_riesgo": sum(1 for c in casos if c["riesgo"]),
        "tecnicas": TECNICAS,
    }

    b["data"].parent.mkdir(parents=True, exist_ok=True)
    b["data"].write_text(json.dumps({"meta": meta, "casos": slim}, ensure_ascii=False,
                                    separators=(",", ":")), encoding="utf-8")
    with open(b["csv"], "w", encoding="utf-8-sig", newline="") as fh:
        w = csv.DictWriter(fh, fieldnames=CAMPOS_CSV, delimiter=";")
        w.writeheader()
        w.writerows(filas)
    return meta


def render(meta, b):
    pri = meta["por_prioridad"]
    tec_rows = "".join(
        f'<div class="legend-item"><b>{html.escape(k)}</b><span>{v:,}</span></div>'
        for k, v in sorted(meta["por_tecnica"].items(), key=lambda x: -x[1]))
    doms = "".join(f'<option value="{d}">{d}</option>' for d in meta["dominios"])
    regs = "".join(f'<option value="{r}">{r}</option>'
                   for r in sorted(meta["reguladores"], key=lambda k: -meta["reguladores"][k]))
    T = {
        "__TITLE__": f"{b['sys']} · Catálogo de Casos de Prueba",
        "__LOGO__": b["logo"], "__ALT__": b["alt"], "__CRUMB__": b["crumb"],
        "__BACK__": b["back"], "__VISTA__": b["vista"], "__DATOS__": b["datos"],
        "__DATA__": b["data"].name, "__CSV__": b["csv"].name,
        "__ACCENT__": b["accent"], "__ACCENT2__": b["accent2"], "__BLUE__": b["blue"],
        "__BLUED__": b["blued"], "__BG__": b["bg"], "__GLOW__": b["glow"],
        "__TOTAL__": f"{meta['total']:,}", "__P1__": f"{pri.get('P1', 0):,}",
        "__P2__": f"{pri.get('P2', 0):,}", "__P3__": f"{pri.get('P3', 0):,}",
        "__RIESGO__": f"{meta['con_riesgo']:,}", "__LEGEND__": tec_rows,
        "__DOMS__": doms, "__REGS__": regs,
    }
    out = PAGE
    for k, v in T.items():
        out = out.replace(k, str(v))
    return out


# ═════════════════════════════════════════════════════════════════════════════
PAGE = r"""<!DOCTYPE html>
<html lang="es"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>__TITLE__</title>
<style>
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
</style></head><body>
<div class="aurora"></div>

<div class="hero-bar">
  <img src="__LOGO__" alt="__ALT__">
  <div class="hb-sep"></div>
  <span class="crumb">__CRUMB__ &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; <em>CATÁLOGO DE CASOS DE PRUEBA</em></span>
  <span class="hb-sp"></span>
  <a href="__DATOS__" class="back">Datos sintéticos</a>
  <a href="__VISTA__" class="back">Ver el método</a>
  <a href="__BACK__" class="back">Portal</a>
</div>

<div class="wrap">
  <div class="head">
    <div class="kick">Quality Engineering · Shift-left</div>
    <h1>__TOTAL__ casos de prueba<br>derivados del gemelo</h1>
    <p>Cada caso trae su trazabilidad al código fuente: el procedimiento, la línea y el fragmento que lo sustenta.
      Ninguno está validado todavía: son <b>casos candidatos</b>. El resultado esperado lo confirma el SME de dominio,
      y el QA Lead consolida los que se repiten entre procedimientos. Clic en cualquier caso para ver su evidencia.</p>
    <div class="stats">
      <div class="sb"><div class="sn">__TOTAL__</div><div class="sl">Casos</div></div>
      <div class="sb"><div class="sn">__P1__</div><div class="sl">P1 · no negociables</div></div>
      <div class="sb b"><div class="sn">__P2__</div><div class="sl">P2 · por volumen</div></div>
      <div class="sb b"><div class="sn">__P3__</div><div class="sl">P3 · resto</div></div>
      <div class="sb"><div class="sn">__RIESGO__</div><div class="sl">Con riesgo de equivalencia</div></div>
    </div>
    <div class="legend">__LEGEND__</div>
  </div>

  <div class="bar">
    <input type="search" id="q" placeholder="Buscar por título, caso, regla o procedimiento…">
    <select id="f-tec"><option value="">Toda técnica</option></select>
    <select id="f-dom"><option value="">Todo dominio</option>__DOMS__</select>
    <select id="f-reg"><option value="">Todo regulador</option>__REGS__</select>
    <span class="chip" data-p="P1">P1</span>
    <span class="chip" data-p="P2">P2</span>
    <span class="chip" data-p="P3">P3</span>
    <span class="chip" id="c-risk">Con riesgo</span>
    <a class="dl" href="data/__CSV__" download>Descargar CSV</a>
  </div>
  <div class="count" id="count">Cargando el catálogo…</div>
  <div id="list"></div>
  <div class="pager" id="pager"></div>
</div>

<footer>
  __CRUMB__ · SPE-AM-001 · Catálogo generado por <code>build-test-catalog.py</code> desde <code>brain.db</code>.<br>
  El CSV usa punto y coma como separador y codificación UTF-8 con BOM, listo para importar a un ALM.
</footer>

<script>
const PAGE_SIZE = 60;
const TEC = {};
let ALL = [], VIS = [], page = 0, openId = null;
let pris = new Set(), soloRiesgo = false;
let DATOS = null;   // sets sintéticos, se cargan aparte y en segundo plano

const $ = s => document.querySelector(s);
const esc = s => String(s == null ? '' : s).replace(/[&<>"]/g, c =>
  ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[c]));

fetch('data/__DATA__')
  .then(r => r.json())
  .then(d => {
    ALL = d.casos;
    Object.assign(TEC, d.meta.tecnicas);
    const sel = $('#f-tec');
    Object.entries(TEC).forEach(([k, v]) => {
      const o = document.createElement('option'); o.value = k; o.textContent = v; sel.appendChild(o);
    });
    apply();
    // Los datos sintéticos no bloquean el catálogo: si llegan, el detalle los muestra.
    fetch('data/test-data.json')
      .then(r => r.ok ? r.json() : null)
      .then(d2 => { if (d2) { DATOS = d2.sets; if (openId) render(); } })
      .catch(() => {});
  })
  .catch(() => {
    $('#count').innerHTML = 'No se pudo cargar <code>data/__DATA__</code>. ' +
      'Esta página necesita servirse por HTTP: abrirla como archivo local bloquea la carga de datos.';
  });

function apply() {
  const q = $('#q').value.trim().toLowerCase();
  const tec = $('#f-tec').value, dom = $('#f-dom').value, reg = $('#f-reg').value;
  VIS = ALL.filter(c => {
    if (tec && c.tc !== tec) return false;
    if (dom && c.d !== dom) return false;
    if (reg && !(c.r || []).includes(reg)) return false;
    if (pris.size && !pris.has(c.p)) return false;
    if (soloRiesgo && !(c.k && c.k.length)) return false;
    if (q && !(c.t + ' ' + c.i + ' ' + c.rl + ' ' + c.sp).toLowerCase().includes(q)) return false;
    return true;
  });
  page = 0;
  render();
}

function render() {
  const total = VIS.length, pages = Math.max(1, Math.ceil(total / PAGE_SIZE));
  if (page >= pages) page = pages - 1;
  const slice = VIS.slice(page * PAGE_SIZE, page * PAGE_SIZE + PAGE_SIZE);

  $('#count').innerHTML = '<b>' + total.toLocaleString('es-MX') + '</b> casos' +
    (total !== ALL.length ? ' de ' + ALL.length.toLocaleString('es-MX') : '');

  $('#list').innerHTML = slice.length ? slice.map(fila).join('') :
    '<div class="empty">Ningún caso cumple el filtro.</div>';

  $('#pager').innerHTML = pages > 1 ?
    '<button id="prev"' + (page === 0 ? ' disabled' : '') + '>Anterior</button>' +
    '<span class="pg">' + (page + 1) + ' de ' + pages + '</span>' +
    '<button id="next"' + (page >= pages - 1 ? ' disabled' : '') + '>Siguiente</button>' : '';
  if (pages > 1) {
    $('#prev').onclick = () => { page--; render(); scrollTo({top: 260, behavior: 'smooth'}); };
    $('#next').onclick = () => { page++; render(); scrollTo({top: 260, behavior: 'smooth'}); };
  }
  document.querySelectorAll('.tch').forEach(el => {
    el.onclick = () => { openId = (openId === el.dataset.id) ? null : el.dataset.id; render(); };
  });
}

function fila(c) {
  const abierto = openId === c.i;
  const tags = [
    '<span class="tag t-tec">' + esc(TEC[c.tc] || c.tc) + '</span>',
    c.d ? '<span class="tag t-dom">' + esc(c.d) + '</span>' : '',
    (c.r || []).length ? '<span class="tag t-reg">' + esc(c.r.join(' · ')) + '</span>' : '',
    (c.k || []).length ? '<span class="tag t-risk">equivalencia</span>' : '',
    '<span class="tag t-' + c.p.toLowerCase() + '">' + c.p + '</span>',
  ].join('');
  return '<div class="tc ' + c.p.toLowerCase() + '">' +
    '<div class="tch" data-id="' + esc(c.i) + '">' +
      '<span class="tcid">' + esc(c.i) + '</span>' +
      '<span class="tct">' + esc(c.t) + '</span>' +
      '<span class="tags">' + tags + '</span>' +
    '</div>' + (abierto ? detalle(c) : '') + '</div>';
}

function detalle(c) {
  const g = c.g || ['', '', ''];
  let ev = '';
  if (c.cd) {
    ev = '<div class="ev"><div class="evk">Evidencia en el código fuente</div>' +
         '<div class="evv">' + esc(c.cd) + '</div><div class="evm">' +
         (c.sp ? '<span>Procedimiento <b>' + esc(c.sp) + '</b></span>' : '') +
         (c.l ? '<span>Línea <b>' + esc(c.l) + '</b></span>' : '') +
         '<span>Origen <b>' + esc(c.rl) + '</b></span>' +
         (c.cn ? '<span>Tráfico <b>' + Number(c.cn).toLocaleString('es-MX') + '</b> llamadas/día</span>' : '') +
         '</div></div>';
  }
  const riesgo = (c.k || []).length ?
    '<div class="ev" style="border-color:rgba(255,169,77,.28)"><div class="evk">Riesgo de equivalencia declarado</div>' +
    '<div class="gv">' + esc(c.k.join(' · ')) + '</div></div>' : '';
  return '<div class="det"><div class="gw">' +
    '<div class="gk">Dado</div><div class="gv">' + esc(g[0]) + '</div>' +
    '<div class="gk">Cuando</div><div class="gv">' + esc(g[1]) + '</div>' +
    '<div class="gk">Entonces</div><div class="gv">' + esc(g[2]) + '</div>' +
    '</div>' + ev + riesgo + datos(c) + '</div>';
}

function datos(c) {
  if (!DATOS) return '';
  const s = DATOS[c.i];
  if (!s) return '';
  const filas = s.c.map(f =>
    '<tr><td class="mono">' + esc(f.n) + '</td><td class="dim">' + esc(f.t) + '</td>' +
    '<td class="mono val">' + esc(f.v) + '</td><td class="dim">' + esc(f.d) + '</td></tr>').join('');
  return '<div class="ev" style="border-color:rgba(__GLOW__,.26)">' +
    '<div class="evk">Datos sintéticos del caso · cliente ' + esc(s.p) + '</div>' +
    '<table class="dt"><thead><tr><th>Campo</th><th>Tipo</th><th>Valor</th><th>Por qué</th></tr></thead>' +
    '<tbody>' + filas + '</tbody></table>' +
    (s.n ? '<div class="gv" style="margin-top:10px">' + esc(s.n) + '</div>' : '') + '</div>';
}

$('#q').oninput = apply;
['#f-tec', '#f-dom', '#f-reg'].forEach(s => { $(s).onchange = apply; });
document.querySelectorAll('.chip[data-p]').forEach(ch => {
  ch.onclick = () => {
    const p = ch.dataset.p;
    if (pris.has(p)) { pris.delete(p); ch.classList.remove('on'); }
    else { pris.add(p); ch.classList.add('on'); }
    apply();
  };
});
$('#c-risk').onclick = () => {
  soloRiesgo = !soloRiesgo;
  $('#c-risk').classList.toggle('on', soloRiesgo);
  apply();
};
</script>
</body></html>"""


# ═════════════════════════════════════════════════════════════════════════════
def main():
    ap = argparse.ArgumentParser(description="Catálogo de casos de prueba desde el brain")
    ap.add_argument("--brand", choices=list(BRANDS) + ["all"], default="all")
    args = ap.parse_args()

    con = sqlite3.connect(str(DB))
    casos = derivar(con)
    con.close()

    print(f"Casos derivados: {len(casos):,}")
    for k, v in Counter(TECNICAS[c['tec']] for c in casos).most_common():
        print(f"  {k:26s} {v:>6,}")
    for k, v in sorted(Counter(c['pri'] for c in casos).items()):
        print(f"  {k:26s} {v:>6,}")

    for key in (list(BRANDS) if args.brand == "all" else [args.brand]):
        b = BRANDS[key]
        meta = escribir(casos, b)
        b["html"].parent.mkdir(parents=True, exist_ok=True)
        page = render(meta, b)
        b["html"].write_text(page, encoding="utf-8")
        print(f"\n[{key}] {b['html'].relative_to(BASE)} · {len(page):,} bytes")
        print(f"       {b['data'].relative_to(BASE)} · {b['data'].stat().st_size:,} bytes")
        print(f"       {b['csv'].relative_to(BASE)} · {b['csv'].stat().st_size:,} bytes")


if __name__ == "__main__":
    main()
