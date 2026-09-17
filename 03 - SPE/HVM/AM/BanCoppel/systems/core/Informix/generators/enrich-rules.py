#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
enrich-rules.py — Silver Layer: Enriquecimiento de reglas Bronze.

Medallion Architecture:
  Bronze (extract-rules.py → rules-bronze.json)
    → Silver (enrich-rules.py → business-rules-v3.json)  ← este script
      → Gold  (build-brain.py --reset → brain.db)

Input:  portal/data/rules-bronze.json
Output: portal/data/business-rules-v3.json

Aplica:
  1. Clasificación de naturaleza (clase):
       NEGOCIO           — regla de negocio genuina
       INFRAESTRUCTURA   — shell/dbaccess/UNLOAD/paths AIX
       ENSAMBLAJE_REPORTE — construcción de SQL dinámico para reportes
       PRESENTACION      — formato/padding/mensajes display

  2. Triaje regulatorio por dominio:
       Para reglas con reg=[], aplica defaults basados en el dominio D17-D49
       (conversión de moneda D41, reservas D48, buró D24, serie-R D36, etc.)

  3. Normalización de business_name:
       business_name permanece "" (la síntesis LLM es la única fuente — ADR-SPE-AM-010)
       Si brain.db existe, copia los business_name enriquecidos que ya están ahí.

  4. Formato canónico v3:
       {"meta": {...}, "rules": [...], "stats": {...}}
       Compatible con build-brain.py load_rules().

SPE-AM-001 · Specialist Informix SPL · 2026-08-25
"""
import json, re, sys, sqlite3
from pathlib import Path
from collections import Counter
from datetime import date

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE    = Path(__file__).resolve().parent.parent
BRONZE  = BASE / "portal" / "data" / "rules-bronze.json"
SILVER  = BASE / "portal" / "data" / "business-rules-v3.json"
BRAIN   = BASE / "digital-brain" / "brain.db"

# ── 1. Leer Bronze ─────────────────────────────────────────────────────────────
print("Leyendo rules-bronze.json...")
brz   = json.loads(BRONZE.read_text(encoding="utf-8"))
rules = brz["rules"]
print(f"  {len(rules)} reglas Bronze cargadas")

# ── 2. Clasificación de naturaleza (clase) ────────────────────────────────────
# Detectores en orden de prioridad:
#   INFRAESTRUCTURA → ENSAMBLAJE_REPORTE → PRESENTACION → NEGOCIO

# Señales INFRAESTRUCTURA: shell/OS execution patterns
_RE_INFRA = re.compile(
    r"vsql\s*=|vcmd\s*=|vstmt\s*=|cCmd\s*=|cSql\s*=.*\bdbaccess\b"
    r"|dbaccess\b"
    r"|unload\s+to\b"
    r"|/resplogifx/|/ifxsif01/|/informix/|\.sh\b"
    r"|\bgzip\b|\btar\b\s+-[czxf]|\becho\b\s+[\"']"
    r"|\bawk\b|\bgrep\b|\brm\s+-f|\bcp\s+/|\bmv\s+/"
    r"|\bvsql\s*\|\||vcmd\s*\|\|",
    re.I)

# Señales ENSAMBLAJE_REPORTE: construcción dinámica de SQL para reportes
_RE_ENSAM = re.compile(
    r"execute\s+immediate\b"
    r"|let\s+\w+\s*=\s*[\"']select\b"
    r"|let\s+\w+\s*=\s*[\"']insert\b"
    r"|let\s+\w+\s*=\s*[\"']update\b"
    r"|let\s+\w*sql\w*\s*=.*\|\|"
    r"|let\s+\w*stmt\w*\s*=.*\|\|"
    r"|let\s+\w*query\w*\s*=.*\|\|",
    re.I)

# Señales PRESENTACION: format/padding/display (sin contenido financiero)
_RE_PRES = re.compile(
    r"\bspaces\s*\("
    r"|\bsubstr\s*\(.*,\s*\d+\s*,\s*\d+"  # padding/truncation
    r"|\busing\s+['\"][,#\$]"              # USING format clause
    r"|\blpad\s*\(|\brpad\s*\("
    r"|\btrim\s*\(",
    re.I)

# Señales financieras: si el código tiene contenido financiero genuino, no es PRESENTACION
_RE_FIN_SIGNAL = re.compile(
    r"\b(?:let|set)\s+\w+\s*=.*[*/].*(?:tasa|saldo|monto|interes|iva|isr|cuota|comis|mora)"
    r"|\b(?:tasa|saldo|monto|interes|iva|isr|cuota|comis|mora)\b.*[*/]",
    re.I)


def clasifica_naturaleza(code: str, tipo: str) -> str:
    cl = code.lower()

    # INFRAESTRUCTURA: explícito shell/dbaccess
    if _RE_INFRA.search(cl):
        return "INFRAESTRUCTURA"

    # ENSAMBLAJE_REPORTE: SQL dinámico para reportes
    if _RE_ENSAM.search(cl):
        return "ENSAMBLAJE_REPORTE"

    # PRESENTACION: solo formato/display (sin señal financiera real)
    if _RE_PRES.search(cl) and not _RE_FIN_SIGNAL.search(cl):
        return "PRESENTACION"

    # FÓRMULA que en realidad es concatenación de strings (ensamblaje)
    # Detectar: LET x = "texto" || variable || ... sin operadores aritméticos reales
    if tipo == "FÓRMULA" and "||" in cl and not re.search(r"[*/]", code):
        return "ENSAMBLAJE_REPORTE"

    return "NEGOCIO"


# ── 3. Triaje regulatorio por dominio D17-D49 ─────────────────────────────────
# Para reglas con reg=[], se asigna el default regulatorio del dominio.
# Aplica solo a reglas cuyos DB están en D17-D49.

DOMAIN_REG_DEFAULTS = {
    # Corresponsalía: conversión UDI (Factor UDI Banxico)
    "D41": [["Banxico", "Circular Banxico — Corresponsalía; conversión UDI (Factor UDI Banxico)"]],
    # Riesgos de Crédito: gestión integral de riesgos CNBV
    "D48": [["CNBV", "CUB Circular B-5 — gestión integral de riesgos (crédito, mercado, operativo)"]],
    # Buró de Crédito: LRSIC consulta crediticia
    "D24": [["CNBV", "LRSIC — Buró de Crédito; evaluación crediticia (consentimiento LFPDPPP)"]],
    # Reportería CNBV: Serie R
    "D36": [["CNBV", "CUB Anexo 36 — Serie R; reportes mensuales R01-A/B R04-A/B R12 R22 R24"]],
    # Auditoría: conservación de información
    "D27": [["CNBV", "Art.78 LIC — conservación de información 5 años (bitácoras y movimientos)"]],
    # Programas (D20): incluye AFORE/CONSAR en algunos SPs
    "D20": [["CONSAR", "SAR — Ahorro para el Retiro; administración de fondos AFORE/CONSAR"]],
    # Reportes Visa/MC: tarjetas bajo CUB
    "D32": [["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"]],
    # Tarjetas Coppel: CUB
    "D30": [["CNBV", "Disposiciones Únicas de Bancos — tarjetas de crédito y débito (Capítulo XI CUB)"]],
    # Garantías: CNBV Circular B-6
    "D47": [["CNBV", "Disposiciones Únicas de Bancos — garantías en operaciones de crédito (Circular B-6)"]],
    # Domiciliación: Banxico SPEI
    "D21": [["Banxico", "SPEI/Domiciliación Reglas técnicas — irrevocabilidad, clave rastreo, ventanas"]],
    # Monitor de Cobranza: CONDUSEF cobranza
    "D33": [["CONDUSEF", "RECA/SAC — Reclamaciones y cobranza; protección al usuario"]],
    # Administración Nómina: IMSS/SAT
    "D37": [["IMSS", "IMSS/SAT — obligaciones de nómina, CFDI nómina y SUA"]],
    # Transferencias Presenciales: Banxico
    "D43": [["Banxico", "SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30"]],
}

# Set de dominios D17-D49 para filtro rápido
D17_D49_CODES = {f"D{n}" for n in range(17, 50)}


def apply_domain_defaults(rule: dict) -> dict:
    dom_code = rule.get("dom_code", "")
    if not rule.get("reg") and dom_code in D17_D49_CODES:
        defaults = DOMAIN_REG_DEFAULTS.get(dom_code)
        if defaults:
            rule = dict(rule)
            rule["reg"] = defaults
    return rule


# ── 4. Lookup business_name desde brain.db (opcional) ─────────────────────────
# Si brain.db existe, copia los business_name ya enriquecidos por síntesis LLM.
# Match por (db, sp_name, line) — más robusto que por ID cuando los IDs cambian.
# No agrega dependencia hard: si no existe, business_name permanece "".
bn_map: dict[tuple, str] = {}
if BRAIN.exists():
    try:
        con = sqlite3.connect(BRAIN)
        cur = con.cursor()
        cur.execute("""
            SELECT sp, db, line, business_name FROM rules
            WHERE business_name IS NOT NULL AND business_name != ''
        """)
        for sp_col, db_col, line_col, bn in cur.fetchall():
            # sp puede ser "sp_name" o "db:sp_name" — normalizar a sp_name
            sp_name = sp_col.split(":", 1)[-1] if ":" in sp_col else sp_col
            key = (db_col, sp_name, line_col)
            bn_map[key] = bn
        con.close()
        print(f"  brain.db: {len(bn_map)} business_names cargados (lookup por db+sp+line)")
    except Exception as e:
        print(f"  brain.db no disponible: {e}")


# ── 5. Aplicar enrichments a cada regla ───────────────────────────────────────
enriched = []
n_clase_neg = n_clase_inf = n_clase_ens = n_clase_pre = 0
n_default_reg = 0

for r in rules:
    r = dict(r)

    # Clase
    clase = clasifica_naturaleza(r["code"], r["tipo"])
    r["clase"] = clase
    if clase == "NEGOCIO":           n_clase_neg += 1
    elif clase == "INFRAESTRUCTURA": n_clase_inf += 1
    elif clase == "ENSAMBLAJE_REPORTE": n_clase_ens += 1
    else:                            n_clase_pre += 1

    # Triaje regulatorio
    if not r.get("reg"):
        r = apply_domain_defaults(r)
        if r.get("reg"):
            n_default_reg += 1

    # business_name desde brain.db por (db, sp, line)
    if bn_map and not r.get("business_name"):
        key = (r["db"], r["sp"], r["line"])
        r["business_name"] = bn_map.get(key, "")

    enriched.append(r)

print(f"\nEnriquecimiento aplicado:")
print(f"  NEGOCIO:            {n_clase_neg}")
print(f"  INFRAESTRUCTURA:    {n_clase_inf}")
print(f"  ENSAMBLAJE_REPORTE: {n_clase_ens}")
print(f"  PRESENTACION:       {n_clase_pre}")
print(f"  Triaje reg defaults: {n_default_reg}")
print(f"  business_name cargados desde brain.db: {sum(1 for r in enriched if r.get('business_name'))}")

# ── 6. Estadísticas Silver ────────────────────────────────────────────────────
by_tipo   = Counter(r["tipo"]      for r in enriched)
by_cat    = Counter(r["categoria"] for r in enriched)
by_dom    = Counter(r["dominio"]   for r in enriched)
by_clase  = Counter(r["clase"]     for r in enriched)
n_reg     = sum(1 for r in enriched if r.get("reg"))
n_ries    = sum(1 for r in enriched if r.get("riesgo"))
n_bn      = sum(1 for r in enriched if r.get("business_name"))

# Estadística de reg: agrupa por str(reg) para coincidir con formato legacy
by_reg = Counter(str(r.get("reg", [])) for r in enriched)

# ── 7. Output business-rules-v3.json ─────────────────────────────────────────
clase_taxonomy = [k for k, _ in by_clase.most_common()]

out = {
    "meta": {
        "version": "3.0",
        "generated": str(date.today()),
        "tool": "enrich-rules.py",
        "layer": "silver",
        "source": "rules-bronze.json",
        "sp_scanned": brz["meta"].get("sp_scanned", 0),
        "total": len(enriched),
        "total_rules": len(enriched),
        "business_name_coverage": n_bn,
        "clase_taxonomy": clase_taxonomy,
    },
    "rules": enriched,
    "stats": {
        "by_tipo":  dict(by_tipo),
        "by_cat":   dict(by_cat.most_common()),
        "by_reg":   dict(by_reg.most_common(50)),
        "by_dom":   dict(by_dom.most_common()),
        "by_clase": dict(by_clase),
        "n_reg":    n_reg,
        "n_riesgo": n_ries,
        "n_business_name": n_bn,
    },
}

SILVER.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")

print(f"\nbusiness-rules-v3.json escrito: {len(enriched)} reglas · {len(by_dom)} dominios")
print(f"  Negocio genuinas: {n_clase_neg} ({n_clase_neg*100//len(enriched) if enriched else 0}%)")
print(f"  Con reg:   {n_reg} ({n_reg*100//len(enriched) if enriched else 0}%)")
print(f"  Con biz:   {n_bn} ({n_bn*100//len(enriched) if enriched else 0}%)")
print("\nSiguiente: python digital-brain/build-brain.py --reset")
