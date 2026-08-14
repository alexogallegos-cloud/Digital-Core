#!/usr/bin/env python3
import sys, io
sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding="utf-8", errors="replace")
"""
Banamex Gemelo Cognitivo — Vocabulario (Capa 1)
Lee gemelo-{sistema}.json → produce vocab-{sistema}.json + .md + .html

Tres capas de enriquecimiento (en orden de precedencia):
  1. BCOP_CROSS_REF    — coincidencia exacta con vocabulario BanCoppel (SPL/Informix)
                         evidencia="bcop-cruzada"  → confianza elevada a ALTA automáticamente
  2. DOMAIN_ENRICHMENT — términos Banamex/Unisys conocidos por dominio bancario CNBV
                         evidencia="dominio"
  3. UNISYS_PATTERNS   — reglas de patrón del stack Unisys ClearPath MCP
                         (P### = programa COBOL, L### = librería ALGOL, etc.)
                         evidencia="patron-unisys"

Uso:
  python build-vocab.py S500
  python build-vocab.py S151
  python build-vocab.py S500 S151
"""

import json
import re
import sys
import argparse
from pathlib import Path
from collections import Counter, defaultdict

DATA_DIR = Path(__file__).parent / "data"

# ─── Canonicalización de aliases ──────────────────────────────────────────────
CANONICAL_MAP = {
    "CTO": "CONTRATO", "CTOS": "CONTRATO", "CTROS": "CONTRATO",
    "NUMCTO": "NUMCONTRATO", "NUMCTE": "NUMCLIENTE",
    "CLIENTE": "CLIENTE", "CTE": "CLIENTE", "CLTE": "CLIENTE",
    "MOV": "MOVIMIENTO", "MOVTO": "MOVIMIENTO", "MOVTOS": "MOVIMIENTO",
    "MOVIMIENTO": "MOVIMIENTO",
    "SALDO": "SALDO", "SDO": "SALDO", "SALDOS": "SALDO",
    "FEC": "FECHA", "FECHA": "FECHA", "FECHAS": "FECHA",
    "MONTO": "MONTO",
    "IMP": "IMPORTE", "IMPORTE": "IMPORTE", "IMPORTES": "IMPORTE",
    "CHEQUE": "CHEQUE", "CHQUE": "CHEQUE", "CHQ": "CHEQUE",
    "STS": "STATUS", "STAT": "STATUS", "STATUS": "STATUS",
    "ESTATUS": "STATUS", "ESTADO": "ESTADO",
    "ASIENTO": "ASIENTO", "ASTOS": "ASIENTO",
    "CTA": "CUENTA", "CUENTA": "CUENTA", "CUENTAS": "CUENTA",
    "COD": "CODIGO", "CODIGO": "CODIGO",
    "CLAVE": "CLAVE", "CLVE": "CLAVE",
    "TPO": "TIPO", "TIPO": "TIPO",
    "NUM": "NUMERO", "NUMERO": "NUMERO",
    "NOM": "NOMBRE", "NOMBRE": "NOMBRE",
    "PGM": "PROGRAMA", "PROG": "PROGRAMA", "PROGRAMA": "PROGRAMA",
    "ERR": "ERROR", "ERROR": "ERROR",
    "RC": "RETURN_CODE", "RETORNO": "RETURN_CODE",
    "JOB": "JOB", "WFL": "JOB",
    "REG": "REGISTRO", "REGISTRO": "REGISTRO",
    "BNX": "BANAMEX", "BANAMEX": "BANAMEX",
    "S500": "SISTEMA_S500", "S151": "SISTEMA_S151",
}

CATEGORY_MAP = {
    "CONTRATO": "CUENTA", "NUMCONTRATO": "CUENTA",
    "NUMCLIENTE": "CLIENTE", "CLIENTE": "CLIENTE",
    "MOVIMIENTO": "TRANSACCION",
    "SALDO": "FINANCIERO", "MONTO": "FINANCIERO", "IMPORTE": "FINANCIERO",
    "FECHA": "TEMPORAL",
    "CHEQUE": "INSTRUMENTO",
    "STATUS": "CONTROL", "ESTADO": "CONTROL", "ERROR": "CONTROL",
    "RETURN_CODE": "CONTROL",
    "ASIENTO": "CONTABILIDAD", "CUENTA": "CONTABILIDAD",
    "CODIGO": "IDENTIFICACION", "CLAVE": "IDENTIFICACION",
    "NUMERO": "IDENTIFICACION", "NOMBRE": "IDENTIFICACION",
    "TIPO": "CLASIFICACION",
    "PROGRAMA": "TECNICO", "JOB": "TECNICO",
    "SISTEMA_S500": "TECNICO", "SISTEMA_S151": "TECNICO",
    "REGISTRO": "DATOS",
    "BANAMEX": "ORGANIZACION",
}

NOISE_TOKENS = {
    "WKS", "WS", "LS", "REC", "IN", "OUT", "FD", "SD", "PIC",
    "COPY", "DATA", "PROC", "HDR", "FTR", "CTL", "AUX",
    "R00", "R01", "R02", "R03", "R04", "R05",
    "V00", "V01", "V02", "V03", "V04",
    "MTP", "FSW", "INI", "FIN",
}

# ─── Capa 1: Cross-referencia con BanCoppel (Informix/SPL) ────────────────────
# Términos confirmados en ambos sistemas bancarios → evidencia cruzada
# Derivados del análisis vocabulary-inventory.json de BCOPCore (2026-07-10)
BCOP_CROSS_REF = {
    # termino_canonico → (categoria_bcop, significado_bcop)
    "LOTE":       ("ENTIDAD",  "lote de procesamiento batch"),
    "SALDO":      ("ENTIDAD",  "saldo de cuenta"),
    "TARJETAS":   ("ENTIDAD",  "tarjetas (plural)"),
    "LINEA":      ("ENTIDAD",  "linea de credito"),
    "MOVIMIENTOS":("ENTIDAD",  "movimientos"),
    "REPORTES":   ("ENTIDAD",  "reportes regulatorios/operativos"),
    "MOVIMIENTO": ("ENTIDAD",  "movimiento contable"),
    "MENSAJE":    ("ENTIDAD",  "mensaje — comunicacion entre procesos"),
    "COMISION":   ("REG",      "comision (CONDUSEF — debe estar en RECO)"),
    "DATOS":      ("ENTIDAD",  "datos"),
    "MONITOREO":  ("ENTIDAD",  "monitor"),
}

# ─── Capa 2: Términos Banamex/Unisys conocidos por dominio CNBV ───────────────
DOMAIN_ENRICHMENT = {
    # dominio CAPTACION (S500)
    "CAPTACION":   ("ENTIDAD", "Captacion — dominio de cuentas de cheque Banamex"),
    "CONTROL":     ("ENTIDAD", "modulo de control de proceso batch"),
    "LOTE":        ("ENTIDAD", "lote de procesamiento batch nocturno"),
    "ASINCRONA":   ("MODIF",   "modo de procesamiento asincrono"),
    "TELETON":     ("ENTIDAD", "modulo de comunicacion Teleton"),
    "LIGAS":       ("ENTIDAD", "ligas entre registros DASDL (punteros)"),
    "MAPLI":       ("ENTIDAD", "mapa de libreria — estructura de acceso a datos"),
    "ACCESOBD04":  ("ENTIDAD", "acceso a esquema BDB04 (CAPTACION core)"),
    "CONSULFOR":   ("ACCION",  "consulta de formato — lectura de plantilla"),
    "CTLVER":      ("ENTIDAD", "control de version del sistema S500"),
    "USAGE":       ("MODIF",   "indicador de uso / utilizacion de recurso"),
    "AUXILIAR":    ("MODIF",   "proceso o tabla de soporte auxiliar"),
    "ATRIBUCTA":   ("ENTIDAD", "atributos de cuenta"),
    "MSGAAPLI":    ("ENTIDAD", "mensaje de aplicacion — interfaz de mensajeria"),
    "FORZA":       ("MODIF",   "procesamiento forzado — override de regla de negocio"),
    "LIBLJ":       ("ENTIDAD", "libreria LJ — utilitarios internos Unisys"),
    "SCRAMBLING":  ("ACCION",  "scrambling de datos — enmascaramiento PII"),
    "TARINTERCAM": ("ENTIDAD", "tarjeta de intercambio — transaccion interbancaria"),
    "CARGABD06":   ("ACCION",  "carga al esquema BDB06 (TARJETAS)"),
    "REVOCA":      ("ACCION",  "revocacion de operacion / bloqueo"),
    "TIEMPOS":     ("ENTIDAD", "tiempos de proceso — SLA batch"),
    "SALDOS":      ("ENTIDAD", "saldos de cuentas (plural)"),
    # dominio CONTABILIDAD (S151)
    "CONTABILIDAD":("ENTIDAD", "Contabilidad — dominio GL / asientos contables"),
    "BOOK":        ("ENTIDAD", "libro contable (GL book) DMSII"),
    "PD":          ("ACCION",  "proceso diario — batch de cierre diario"),
    "LIBCONTROL":  ("ENTIDAD", "libreria de control de proceso GL"),
    "DISPLAY":     ("ACCION",  "despliegue / impresion de datos"),
    "DMSII":       ("ENTIDAD", "Unisys DMSII — sistema gestor de BD nativo MCP"),
    "SOPORTE":     ("ENTIDAD", "modulo de soporte tecnico / mantenimiento"),
    "MOVDB":       ("ACCION",  "movimiento en base de datos DMSII"),
    "BIFINDB":     ("ENTIDAD", "bifurcacion en base de datos — estructura de control"),
    "LOCSUP":      ("ENTIDAD", "local de soporte — estructura de datos auxiliar"),
    "CVETRA":      ("ENTIDAD", "clave de transaccion contable"),
    "DATOSADIC":   ("ENTIDAD", "datos adicionales del movimiento"),
    "ACC":         ("ACCION",  "acceso / accion sobre registro (abreviatura)"),
    "MONITOREO":   ("ENTIDAD", "monitor de proceso — observabilidad batch"),
    "S080L710":    ("PREFIJO", "identificador de job WFL S080/L710"),
    "CTLVERS":     ("ENTIDAD", "control de versiones del sistema S151"),
    "AJUSTES":     ("ENTIDAD", "ajustes contables — asientos de cuadratura"),
    # compartidos
    "REORG":       ("ACCION",  "reorganizacion de base de datos DMSII"),
    "GARBAGE":     ("ACCION",  "liberacion de espacio (garbage collect) DMSII"),
    "TARJETAS":    ("ENTIDAD", "Tarjetas — dominio de tarjetas de credito/debito"),
    "LINEA":       ("ENTIDAD", "linea de credito"),
}

# ─── Capa 3: Patrones del stack Unisys ClearPath MCP ─────────────────────────
# (pattern, categoria, significado_template)
UNISYS_PATTERNS = [
    (re.compile(r'^\d{2}MTP\d{3,}', re.I),
     "PREFIJO", "ticket de mantenimiento MTP — identificador de release Unisys"),
    (re.compile(r'^P\d{3,}(_|$)', re.I),
     "PREFIJO", "programa COBOL (identificador canonico Unisys MCP)"),
    (re.compile(r'^P\d{3,}$', re.I),
     "PREFIJO", "programa COBOL (identificador canonico Unisys MCP)"),
    (re.compile(r'^L\d{3,}$', re.I),
     "PREFIJO", "libreria ALGOL (identificador canonico Unisys MCP)"),
    (re.compile(r'\bON\s+\w+', re.I),
     "ENTIDAD", "entidad DASDL — miembro de SET (acceso relacional nativo MCP)"),
    (re.compile(r'^COPY_', re.I),
     "PREFIJO", "COPYBOOK COBOL — fragmento de codigo compartido"),
    (re.compile(r'BD\d{2}$', re.I),
     "ENTIDAD", "base de datos DMSII (esquema BDB)"),
]


def _apply_enrichment(v: dict) -> dict:
    """Enrich a vocab entry with category, meaning and evidence. Mutates in place."""
    t = v["termino_canonico"].upper()

    # Priority 1: BCOP exact match
    if t in BCOP_CROSS_REF:
        cat, mean = BCOP_CROSS_REF[t]
        v["categoria"]  = cat
        v["significado"] = mean
        v["evidencia"]   = "bcop-cruzada"
        v["confianza"]   = "alta"    # evidencia cruzada eleva automaticamente
        return v

    # Priority 2: Domain knowledge (known Banamex/Unisys terms)
    if t in DOMAIN_ENRICHMENT:
        cat, mean = DOMAIN_ENRICHMENT[t]
        v["categoria"]  = cat
        v["significado"] = mean
        v["evidencia"]   = "dominio"
        return v

    # Priority 3: Unisys pattern rules
    for pat, cat, mean in UNISYS_PATTERNS:
        if pat.search(v["termino_canonico"]):
            v["categoria"]  = cat
            v["significado"] = mean
            v["evidencia"]   = "patron-unisys"
            return v

    # Default: frequency only
    if "evidencia" not in v:
        v["evidencia"]   = "frecuencia"
    if "significado" not in v:
        v["significado"] = ""
    return v


def canonicalize(token: str) -> str:
    return CANONICAL_MAP.get(token.upper(), token.upper())


def is_noise(token: str) -> bool:
    t = token.upper()
    if t in NOISE_TOKENS:
        return True
    if re.match(r"^\d+$", t):
        return True
    if len(t) <= 1:
        return True
    if re.match(r"^(BDB|S500|S151|BD|WKS|WS)", t):
        return True
    return False


def build_vocab(sistema: str) -> None:
    gemelo_path = DATA_DIR / sistema / f"gemelo-{sistema.lower()}.json"
    if not gemelo_path.exists():
        print(f"[ERROR] No encontrado: {gemelo_path}  (ejecuta extract.py primero)")
        return

    with open(gemelo_path, encoding="utf-8") as f:
        gemelo = json.load(f)

    print(f"\n{'='*60}")
    print(f"  Capa 1 · Lenguaje — {sistema}")
    print(f"{'='*60}")

    raw_tokens = Counter()
    for obj in gemelo["objetos"]:
        for tok in _tokenize(obj["nombre"]):
            raw_tokens[tok] += 3
        for tok in _tokenize(obj.get("dominio", "")):
            raw_tokens[tok] += 1
    for edge in gemelo["callgraph"]:
        for tok in _tokenize(edge["from"]):
            raw_tokens[tok] += 1
        for tok in _tokenize(edge["to"]):
            raw_tokens[tok] += 1
    for acc in gemelo["acceso"]:
        for tok in _tokenize(acc["entidad"]):
            raw_tokens[tok] += 2

    canonical_counts = Counter()
    alias_map = defaultdict(set)
    for token, count in raw_tokens.items():
        if is_noise(token):
            continue
        canonical = canonicalize(token)
        canonical_counts[canonical] += count
        if token != canonical:
            alias_map[canonical].add(token)

    vocab_entries = []
    for canonical, freq in canonical_counts.most_common():
        if freq < 2:
            continue
        base_category = CATEGORY_MAP.get(canonical, "GENERAL")
        aliases = sorted(alias_map[canonical])
        confidence = "alta" if freq >= 10 else "media" if freq >= 4 else "baja"
        entry = {
            "termino_canonico": canonical,
            "frecuencia": freq,
            "categoria": base_category,
            "aliases": aliases,
            "confianza": confidence,
            "significado": "",
            "evidencia": "frecuencia",
            "pendiente_validacion_sme": True,
        }
        _apply_enrichment(entry)
        # Mark as no longer pending if BCOP-confirmed
        if entry["evidencia"] == "bcop-cruzada":
            entry["pendiente_validacion_sme"] = False
        vocab_entries.append(entry)

    # ── Estadísticas de enriquecimiento ────────────────────────────────────
    ev_counts = Counter(v["evidencia"] for v in vocab_entries)
    cat_counts = Counter(v["categoria"] for v in vocab_entries)
    general_pct = round(100 * cat_counts.get("GENERAL", 0) / len(vocab_entries)) if vocab_entries else 0

    print(f"  Terminos unicos (canonicos): {len(vocab_entries)}")
    print(f"\n  Enriquecimiento aplicado:")
    for ev, c in ev_counts.most_common():
        print(f"    {ev:<20}: {c:>3} terminos")
    print(f"\n  Distribucion por categoria:")
    for cat, c in cat_counts.most_common():
        print(f"    {cat:<20}: {c:>3}")
    print(f"\n  GENERAL residual: {cat_counts.get('GENERAL',0)} ({general_pct}%)")
    print(f"\n  Top 20 por frecuencia (con enriquecimiento):")
    for v in vocab_entries[:20]:
        ev_tag = f"[{v['evidencia'][:4]}]"
        print(f"    {v['termino_canonico']:<25} f={v['frecuencia']:>4}  "
              f"cat={v['categoria']:<15} {ev_tag}  {v['significado'][:40]}")

    # ── Write JSON ──────────────────────────────────────────────────────────
    out = {
        "meta": {
            "sistema": sistema,
            "capa": 1,
            "descripcion": "Lenguaje — vocabulario controlado del sistema legacy",
            "total_terminos": len(vocab_entries),
            "enriquecimiento": {
                "capas": ["bcop-cruzada", "dominio", "patron-unisys", "frecuencia"],
                "bcop_matches": ev_counts.get("bcop-cruzada", 0),
                "dominio_matches": ev_counts.get("dominio", 0),
                "patron_matches": ev_counts.get("patron-unisys", 0),
                "general_residual": ev_counts.get("frecuencia", 0),
            },
            "nota": "Terminos con evidencia='bcop-cruzada' validados contra vocabulario BanCoppel Informix/SPL",
        },
        "vocabulario": vocab_entries,
    }

    out_dir = DATA_DIR / sistema
    vocab_json = out_dir / f"vocab-{sistema.lower()}.json"
    with open(vocab_json, "w", encoding="utf-8") as f:
        json.dump(out, f, ensure_ascii=False, indent=2)
    print(f"\n  [OUTPUT] {vocab_json.name}")

    _write_vocab_md(sistema, vocab_entries, out_dir)
    _write_vocab_html(sistema, vocab_entries, out)


def _tokenize(name: str) -> list[str]:
    name = name.upper()
    parts = re.split(r"[-_/.]", name)
    return [p for p in parts if len(p) >= 2]


def _write_vocab_md(sistema: str, vocab_entries: list[dict], out_dir: Path) -> None:
    lines = [
        f"# Vocabulario Controlado — {sistema}",
        "> Gemelo Cognitivo · Capa 1 · Lenguaje",
        "",
        "| # | Termino | Frecuencia | Categoria | Confianza | Evidencia | Significado |",
        "|---|---------|-----------|-----------|-----------|-----------|-------------|",
    ]
    for i, v in enumerate(vocab_entries, 1):
        lines.append(
            f"| {i} | `{v['termino_canonico']}` | {v['frecuencia']} "
            f"| {v['categoria']} | {v['confianza']} | {v['evidencia']} "
            f"| {v.get('significado','')} |"
        )
    vocab_md = out_dir / f"vocab-{sistema.lower()}.md"
    vocab_md.write_text("\n".join(lines), encoding="utf-8")
    print(f"  [OUTPUT] {vocab_md.name}")


# ──────────────────────────────────────────────────────────────────────────────
# HTML visual — formato BanCoppel con enriquecimiento
# ──────────────────────────────────────────────────────────────────────────────

_CAT_COLORS = {
    "ENTIDAD":        ("#0a1a2a", "#7dd3fc"),
    "ACCION":         ("#2a1800", "#fb923c"),
    "MODIF":          ("#1a0a2a", "#c084fc"),
    "PREFIJO":        ("#181818", "#a8a8a8"),
    "REG":            ("#0a2a0a", "#86efac"),
    "REGULATORIO":    ("#0a2a0a", "#86efac"),
    "AMBIGUO":        ("#2a1a00", "#d4c060"),
    "GENERAL":        ("#1a2028", "#64748b"),
    "FINANCIERO":     ("#0f2a0f", "#86efac"),
    "TRANSACCION":    ("#2a1800", "#fb923c"),
    "CONTABILIDAD":   ("#2a0808", "#fca5a5"),
    "CONTROL":        ("#1a0a2a", "#c084fc"),
    "CLIENTE":        ("#0a1a2a", "#7dd3fc"),
    "CUENTA":         ("#0a0f2a", "#93c5fd"),
    "IDENTIFICACION": ("#1a1a08", "#d4d468"),
    "TEMPORAL":       ("#081a14", "#6ee7b7"),
    "TECNICO":        ("#0a1018", "#60a5fa"),
    "INSTRUMENTO":    ("#1a0f08", "#fdba74"),
    "ORGANIZACION":   ("#1a0808", "#f9a8a8"),
    "CLASIFICACION":  ("#181818", "#a8a8a8"),
    "DATOS":          ("#081418", "#67e8f9"),
}

_EV_STYLE = {
    "bcop-cruzada":  ("background:#0a2a14", "color:#4ade80",  "border:1px solid #1a6a2a",
                      "BCOP"),
    "dominio":       ("background:#1a1400", "color:#fbbf24",  "border:1px solid #5a4a00",
                      "Dominio"),
    "patron-unisys": ("background:#0a0f1a", "color:#60a5fa",  "border:1px solid #1a2a4a",
                      "Patrón MCP"),
    "frecuencia":    ("background:#1a1a1a", "color:#64748b",  "border:1px solid #2a2a2a",
                      "Frecuencia"),
}

_TIPO_STYLE = {
    "atomico":   ("background:#0d1f33", "color:#7ab8f5"),
    "compuesto": ("background:#1a0d33", "color:#c4a8f5"),
    "candidato": ("background:#2a2800", "color:#d4c060"),
}

_CONF_STYLE = {
    "alta":  ("background:#0a1f0a", "color:#4ade80", "border:1px solid #1a5a1a"),
    "media": ("background:#2a1800", "color:#fb923c", "border:1px solid #5a3a0a"),
    "baja":  ("background:#2a0808", "color:#f87171", "border:1px solid #5a1a1a"),
}

_CSS = """\
:root{--bg:#0d0406;--panel:#1a0608;--line:#4a1a1e;--red:#C1272D;--redd:#8B1520;--gold:#D4A017;--txt:#F0E8E8;--muted:#c4aeb0;--muted2:#9a8082}
*{box-sizing:border-box;margin:0;padding:0}
body{background:var(--bg);color:var(--txt);font-family:'Inter',system-ui,Calibri,sans-serif;min-height:100vh;font-size:13px}
header{background:linear-gradient(135deg,var(--redd),#5a0d13);border-bottom:3px solid var(--gold);padding:12px 28px;display:flex;align-items:center;gap:14px;position:sticky;top:0;z-index:30}
header img{height:22px;filter:drop-shadow(0 1px 3px rgba(0,0,0,.6))}
header h1{font-size:15px;font-weight:800}
header .sub{font-size:10px;color:#f0c8cc;margin-top:1px}
.stats{background:#130407;border-bottom:1px solid var(--line);padding:9px 28px;display:flex;gap:8px;flex-wrap:wrap;align-items:center}
.sc{display:inline-flex;align-items:center;gap:8px;padding:5px 14px;border-radius:8px;background:#1a0608;border:1px solid var(--line)}
.sc .num{font-size:20px;font-weight:800;color:#fff;font-variant-numeric:tabular-nums}
.sc .lbl{font-size:9px;color:var(--muted2);text-transform:uppercase;letter-spacing:.06em;line-height:1.35}
.sc .sub2{font-size:9px;color:var(--muted2)}
.dot{width:8px;height:8px;border-radius:50%;flex-shrink:0}
.dot-g{background:#4ade80}.dot-o{background:#fb923c}.dot-r{background:#f87171}.dot-b{background:#60a5fa}
.cats{background:#100305;border-bottom:1px solid var(--line);padding:7px 28px;display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.cats .clbl{font-size:10px;color:var(--muted2);font-weight:700;text-transform:uppercase;letter-spacing:.08em;margin-right:4px}
.cpill{display:inline-flex;align-items:center;gap:5px;padding:3px 11px;border-radius:20px;font-size:11px;font-weight:600}
.cpill b{font-variant-numeric:tabular-nums}
.evrow{background:#0c0204;border-bottom:1px solid var(--line);padding:7px 28px;display:flex;gap:6px;flex-wrap:wrap;align-items:center}
.evrow .clbl{font-size:10px;color:var(--muted2);font-weight:700;text-transform:uppercase;letter-spacing:.08em;margin-right:4px}
.fbar{background:#0d0406;border-bottom:2px solid var(--line);padding:8px 28px;display:flex;flex-wrap:wrap;gap:5px;align-items:center;position:sticky;top:52px;z-index:25}
.fbar input{background:#1a0608;border:1px solid var(--line);border-radius:8px;padding:5px 12px;color:var(--txt);font-size:12px;width:200px;outline:none}
.fbar input:focus{border-color:var(--gold)}
.flbl{font-size:10px;color:var(--muted2);font-weight:700;text-transform:uppercase;letter-spacing:.08em;margin:0 2px 0 8px}
.ftag{background:#1a0608;border:1px solid var(--line);border-radius:20px;padding:3px 11px;font-size:11px;color:var(--muted);cursor:pointer;transition:.13s}
.ftag:hover{border-color:var(--gold);color:var(--txt)}
.ftag.active{background:var(--gold);color:#0d0406;border-color:var(--gold);font-weight:700}
.wrap{padding-bottom:60px}
.tbar{display:flex;align-items:center;justify-content:space-between;padding:7px 28px;font-size:11px;color:var(--muted2);border-bottom:1px solid var(--line)}
table{width:100%;border-collapse:collapse}
thead th{background:#150508;color:var(--muted2);padding:7px 12px;text-align:left;font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;border-bottom:2px solid var(--line);white-space:nowrap}
th[data-sort]{cursor:pointer;user-select:none}
th[data-sort]:hover{color:var(--gold)}
th.sort-asc::after{content:" ↑";color:var(--gold)}
th.sort-desc::after{content:" ↓";color:var(--gold)}
tbody tr{border-bottom:1px solid var(--line);transition:.1s}
tbody tr:hover{background:#1a0608}
td{padding:6px 12px;vertical-align:middle}
.td-t{font-weight:700;color:#f0e0e0;font-size:13.5px;letter-spacing:-.01em;white-space:nowrap}
.td-sig{font-size:11.5px;color:var(--muted);max-width:280px;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
.tag{display:inline-block;padding:2px 9px;border-radius:12px;font-size:11px;font-weight:600}
.ap{display:inline-block;background:#2a0810;border:1px solid var(--line);border-radius:12px;padding:2px 8px;font-size:11px;color:var(--muted);margin:1px 2px}
.no-a{color:var(--muted2);font-size:11px}
.td-fr{font-variant-numeric:tabular-nums;font-weight:700;color:var(--muted);text-align:right;padding-right:20px}
.td-al{max-width:200px}
"""

_JS = """\
(function(){
  var flt={tipo:'all',conf:'all',cat:'all',ev:'all',search:''};
  var sCol=null,sDir=1;
  var tbody=document.querySelector('#vt tbody');
  var rows=Array.from(tbody.querySelectorAll('tr'));
  var cnt=document.getElementById('cnt');
  function apply(){
    var n=0,s=flt.search;
    rows.forEach(function(r){
      var ok=true;
      if(flt.tipo!=='all'&&r.dataset.tipo!==flt.tipo)ok=false;
      if(flt.conf!=='all'&&r.dataset.conf!==flt.conf)ok=false;
      if(flt.cat!=='all'&&r.dataset.cat!==flt.cat)ok=false;
      if(flt.ev!=='all'&&r.dataset.ev!==flt.ev)ok=false;
      if(s&&!r.dataset.term.includes(s)&&!r.dataset.al.includes(s)&&!r.dataset.sig.includes(s))ok=false;
      r.style.display=ok?'':'none';
      if(ok)n++;
    });
    cnt.textContent=n+' de '+rows.length+' términos';
  }
  document.getElementById('srch').addEventListener('input',function(e){flt.search=e.target.value.toLowerCase();apply();});
  document.querySelectorAll('.ftag').forEach(function(b){
    b.addEventListener('click',function(){
      var f=b.dataset.filter,v=b.dataset.val;
      flt[f]=v;
      document.querySelectorAll('.ftag[data-filter="'+f+'"]').forEach(function(x){x.classList.remove('active');});
      b.classList.add('active');
      apply();
    });
  });
  document.querySelectorAll('th[data-sort]').forEach(function(th){
    th.addEventListener('click',function(){
      var c=th.dataset.sort;
      if(sCol===c)sDir*=-1;else{sCol=c;sDir=1;}
      var sorted=rows.slice().sort(function(a,b){
        var va,vb;
        if(c==='freq'){va=+a.querySelector('.td-fr').dataset.f;vb=+b.querySelector('.td-fr').dataset.f;}
        else{va=a.dataset.term;vb=b.dataset.term;}
        return va<vb?-sDir:va>vb?sDir:0;
      });
      sorted.forEach(function(r){tbody.appendChild(r);});
      document.querySelectorAll('th[data-sort]').forEach(function(t){t.classList.remove('sort-asc','sort-desc');});
      th.classList.add(sDir===1?'sort-asc':'sort-desc');
    });
  });
  apply();
})();
"""


def _write_vocab_html(sistema: str, vocab_entries: list[dict], meta_out: dict) -> None:
    out_dir   = DATA_DIR / sistema
    meta      = meta_out["meta"]
    enrichment= meta.get("enriquecimiento", {})

    total     = len(vocab_entries)
    con_alias = sum(1 for v in vocab_entries if v["aliases"])
    alta      = sum(1 for v in vocab_entries if v["confianza"] == "alta")
    media     = sum(1 for v in vocab_entries if v["confianza"] == "media")
    baja_cand = sum(1 for v in vocab_entries if v["confianza"] == "baja")

    ev_counts = Counter(v["evidencia"] for v in vocab_entries)
    cats      = Counter(v["categoria"] for v in vocab_entries)

    def _tipo(v):
        if v["aliases"]:             return "compuesto"
        if v["confianza"] == "baja": return "candidato"
        return "atomico"

    atomicos   = sum(1 for v in vocab_entries if _tipo(v) == "atomico")
    compuestos = sum(1 for v in vocab_entries if _tipo(v) == "compuesto")

    label_map = {
        "S500": ("Cargos y Abonos de Cheque", "SPE-MM-001"),
        "S151": ("Movimientos Contables GL",   "SPE-MM-002"),
    }
    label, spec_id = label_map.get(sistema, (sistema, "SPE-MM"))

    # Category pills
    cat_pills = ""
    for cat, count in cats.most_common():
        bg, tx = _CAT_COLORS.get(cat, ("#1a1a1a", "#aaaaaa"))
        cat_pills += (
            f'<span class="cpill" style="background:{bg};color:{tx}">'
            f'{cat} <b>{count}</b></span>'
        )

    # Evidence pills
    ev_pills = ""
    for ev, count in ev_counts.most_common():
        st = _EV_STYLE.get(ev, ("background:#1a1a1a", "color:#aaaaaa", "", ev))
        bg, tx, br, label_ev = st
        ev_pills += (
            f'<span class="cpill" style="{bg};{tx};{br}">'
            f'{label_ev} <b>{count}</b></span>'
        )

    # Category filter buttons
    cat_btns = ""
    for cat in [c for c, _ in cats.most_common()]:
        bg, tx = _CAT_COLORS.get(cat, ("#1a1a1a", "#aaaaaa"))
        cat_btns += (
            f'<button class="ftag" data-filter="cat" data-val="{cat}" '
            f'style="background:{bg};color:{tx};border-color:{tx}40">{cat}</button>'
        )

    # Evidence filter buttons
    ev_btns = ""
    for ev in [e for e, _ in ev_counts.most_common()]:
        st = _EV_STYLE.get(ev, ("background:#1a1a1a", "color:#aaaaaa", "", ev))
        bg, tx, br, lbl = st
        ev_btns += (
            f'<button class="ftag" data-filter="ev" data-val="{ev}" '
            f'style="{bg};{tx};{br}">{lbl}</button>'
        )

    # Table rows
    rows_html = ""
    for v in vocab_entries:
        t      = _tipo(v)
        tbg, ttx = _TIPO_STYLE.get(t, ("background:#1a1a1a", "color:#aaaaaa"))
        cbg, ctx, cbr = _CONF_STYLE.get(v["confianza"],
                                         ("background:#1a1a1a", "color:#aaaaaa", ""))
        cat_bg, cat_tx = _CAT_COLORS.get(v["categoria"], ("#1a1a1a", "#aaaaaa"))
        ev     = v.get("evidencia", "frecuencia")
        ev_st  = _EV_STYLE.get(ev, ("background:#1a1a1a", "color:#aaaaaa", "", ev))
        ev_bg, ev_tx, ev_br, ev_lbl = ev_st
        alias_html = (
            "".join(f'<span class="ap">{a}</span>' for a in v["aliases"])
            if v["aliases"] else '<span class="no-a">—</span>'
        )
        sig  = v.get("significado", "")
        tterm  = v["termino_canonico"].lower()
        talias = " ".join(v["aliases"]).lower()
        tsig   = sig.lower()
        frq    = v["frecuencia"]
        tconf  = v["confianza"]
        tcat   = v["categoria"]
        tlabel = {"atomico": "atómico", "compuesto": "compuesto",
                  "candidato": "candidato"}.get(t, t)
        conf_cap = tconf.capitalize()
        rows_html += (
            f'<tr data-tipo="{t}" data-conf="{tconf}" data-cat="{tcat}" '
            f'data-ev="{ev}" data-term="{tterm}" data-al="{talias}" data-sig="{tsig}">'
            f'<td class="td-t">{v["termino_canonico"]}</td>'
            f'<td><span class="tag" style="{tbg};{ttx}">{tlabel}</span></td>'
            f'<td><span class="tag" style="background:{cat_bg};color:{cat_tx}">'
            f'{tcat}</span></td>'
            f'<td><span class="tag" style="{cbg};{ctx};{cbr}">{conf_cap}</span></td>'
            f'<td><span class="tag" style="{ev_bg};{ev_tx};{ev_br}">{ev_lbl}</span></td>'
            f'<td class="td-sig" title="{sig}">{sig}</td>'
            f'<td class="td-al">{alias_html}</td>'
            f'<td class="td-fr" data-f="{frq}">{frq}</td>'
            f'</tr>\n'
        )

    bcop_n  = enrichment.get("bcop_matches", 0)
    dom_n   = enrichment.get("dominio_matches", 0)
    pat_n   = enrichment.get("patron_matches", 0)
    gen_n   = enrichment.get("general_residual", 0)

    html = (
        '<!DOCTYPE html><html lang="es"><head><meta charset="UTF-8">'
        '<meta name="viewport" content="width=device-width,initial-scale=1.0">'
        f'<title>Banamex {sistema} · Vocabulario Controlado · Capa 1</title>'
        f'<style>{_CSS}</style>'
        '</head><body>'
        '<header>'
        '<img src="../../banamex-logo.png" alt="Banamex">'
        f'<div><h1>Vocabulario Controlado &mdash; {sistema}</h1>'
        f'<div class="sub">Gemelo Cognitivo &middot; Capa 1 (lenguaje) &middot; '
        f'{spec_id} &middot; {label} &middot; '
        f'BCOP:{bcop_n} validados · dominio:{dom_n} · patr&oacute;n:{pat_n} · GENERAL:{gen_n}'
        f'</div></div>'
        '</header>'
        '<div class="stats">'
        f'<div class="sc"><div class="num">{total}</div>'
        f'<div class="lbl">T&eacute;rminos &uacute;nicos<div class="sub2">{con_alias} con alias</div></div></div>'
        f'<div class="sc"><div class="num">{atomicos}</div><div class="lbl">At&oacute;micos</div></div>'
        f'<div class="sc"><div class="num">{compuestos}</div><div class="lbl">Compuestos</div></div>'
        f'<div class="sc"><div class="dot dot-g"></div>'
        f'<div class="num">{alta}</div><div class="lbl">Alta<div class="sub2">confianza</div></div></div>'
        f'<div class="sc"><div class="dot dot-o"></div>'
        f'<div class="num">{media}</div><div class="lbl">Media</div></div>'
        f'<div class="sc"><div class="dot dot-r"></div>'
        f'<div class="num">{baja_cand}</div><div class="lbl">Baja/Candidato</div></div>'
        f'<div class="sc"><div class="dot dot-b"></div>'
        f'<div class="num">{bcop_n}</div>'
        f'<div class="lbl">BCOP<div class="sub2">evidencia cruzada</div></div></div>'
        '</div>'
        '<div class="cats">'
        '<span class="clbl">Categor&iacute;as:</span>'
        f'{cat_pills}'
        '</div>'
        '<div class="evrow">'
        '<span class="clbl">Evidencia:</span>'
        f'{ev_pills}'
        '</div>'
        '<div class="fbar">'
        '<input id="srch" placeholder="Buscar t&eacute;rmino, alias o significado&hellip;">'
        '<span class="flbl">TIPO:</span>'
        '<button class="ftag active" data-filter="tipo" data-val="all">todos</button>'
        '<button class="ftag" data-filter="tipo" data-val="atomico"'
        ' style="background:#0d1f33;color:#7ab8f5;border-color:#1a3f6640">at&oacute;mico</button>'
        '<button class="ftag" data-filter="tipo" data-val="compuesto"'
        ' style="background:#1a0d33;color:#c4a8f5;border-color:#3a1a6640">compuesto</button>'
        '<button class="ftag" data-filter="tipo" data-val="candidato"'
        ' style="background:#2a2800;color:#d4c060;border-color:#5a5000">candidato</button>'
        '<span class="flbl">CONFIANZA:</span>'
        '<button class="ftag active" data-filter="conf" data-val="all">todas</button>'
        '<button class="ftag" data-filter="conf" data-val="alta"'
        ' style="background:#0a1f0a;color:#4ade80;border-color:#1a5a1a">Alta</button>'
        '<button class="ftag" data-filter="conf" data-val="media"'
        ' style="background:#2a1800;color:#fb923c;border-color:#5a3a0a">Media</button>'
        '<button class="ftag" data-filter="conf" data-val="baja"'
        ' style="background:#2a0808;color:#f87171;border-color:#5a1a1a">Baja</button>'
        '<span class="flbl">EVIDENCIA:</span>'
        '<button class="ftag active" data-filter="ev" data-val="all">todas</button>'
        f'{ev_btns}'
        '<span class="flbl">CATEGOR&Iacute;A:</span>'
        '<button class="ftag active" data-filter="cat" data-val="all">todas</button>'
        f'{cat_btns}'
        '</div>'
        '<div class="wrap">'
        '<div class="tbar">'
        f'Banamex {sistema} &middot; Unisys ClearPath MCP &middot; '
        't&eacute;rminos con evidencia=frecuencia requieren firma del SME &middot; '
        '<span id="cnt"></span>'
        '</div>'
        '<table id="vt"><thead><tr>'
        '<th data-sort="term">T&Eacute;RMINO</th>'
        '<th>TIPO</th>'
        '<th>CATEGOR&Iacute;A</th>'
        '<th>CONFIANZA</th>'
        '<th>EVIDENCIA</th>'
        '<th>SIGNIFICADO</th>'
        '<th>ALIAS / SIN&Oacute;NIMOS</th>'
        '<th data-sort="freq" style="text-align:right">FREQ</th>'
        f'</tr></thead><tbody>{rows_html}</tbody></table>'
        '</div>'
        f'<script>{_JS}</script>'
        '</body></html>'
    )

    out_path = out_dir / f"vocab-{sistema.lower()}.html"
    out_path.write_text(html, encoding="utf-8")
    print(f"  [OUTPUT] {out_path.name}")


def main():
    parser = argparse.ArgumentParser(
        description="Banamex Gemelo Cognitivo — Vocabulario Capa 1 con enriquecimiento"
    )
    parser.add_argument("sistemas", nargs="+", choices=["S500", "S151"])
    args = parser.parse_args()
    for s in args.sistemas:
        build_vocab(s)


if __name__ == "__main__":
    main()
