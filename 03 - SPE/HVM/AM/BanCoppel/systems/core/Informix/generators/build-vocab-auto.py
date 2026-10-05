#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-vocab-auto.py — Extractor automático de candidatos de vocabulario.

Replica la metodología del Specialist Informix SPL:
  1. Lee todos los nombres de SPs del callgraph (12,812 nodos)
  2. Fragmenta por '_', elimina prefijos técnicos (sp_, fn_)
  3. Cuenta frecuencia y posición relativa de cada token
  4. Lee nombres de parámetros de los .sql (dehungarianización)
  5. Infiere categoría (PREFIJO / ACCION / ENTIDAD / MODIF) por heurísticas
  6. Compara contra sp_vocab.py para separar: known / new / gap

Output: knowledge-base/vocab-candidates.json
  {
    "meta":  {...},
    "known": [{token, cat, mean, estado, freq, inferred_cat, cat_match, sample_sps}],
    "new":   [{token, freq, inferred_cat, sample_sps}],   ← candidatos LLM
    "gap":   [{token, freq, inferred_cat, sample_sps}]    ← baja frecuencia
  }

Siguiente: enrich-vocab-llm.py → lee los SPs de contexto → genera campo 'mean'

SPE-AM-001 · Specialist Informix SPL · 2026-08-25
"""
# Fuentes de señal (4 capas):
#   1. Nombres de SP        → tokens del nombre (señal limpia → candidatos)
#   2. Parámetros           → dehungarización de la firma (señal limpia → candidatos)
#   3. Tablas SQL           → FROM/INTO/UPDATE/JOIN (modelo de datos canónico → candidatos)
#   4. Columnas SQL         → WHERE/SET/AND (atributos finos de entidad → solo cobertura)
#   5. Variables DEFINE     → solo para verificar cobertura de sp_vocab.py (no candidatos)
import json, re, sys, importlib.util, argparse
from collections import Counter, defaultdict
from pathlib import Path
from datetime import date

sys.stdout.reconfigure(encoding="utf-8", errors="replace")

BASE = Path(__file__).resolve().parent.parent

_parser = argparse.ArgumentParser(description="Extractor de candidatos de vocabulario Informix")
_parser.add_argument("--test-universe", action="store_true",
                     help="Filtra corpus a los SPs del test-universe.json (lee source/Informix/ siempre)")
_parser.add_argument("--src", type=str, default=None,
                     help="Ruta alternativa al corpus (override explícito)")
_args = _parser.parse_args()

# Fuente siempre es source/Informix/ — el corpus canónico nunca se duplica.
# --test-universe filtra qué SPs se procesan usando el manifiesto de brain.db.
SRC = Path(_args.src) if _args.src else BASE / "source" / "Informix"

TU_FILTER: set[str] | None = None   # None = sin filtro (corpus completo)
if _args.test_universe:
    _tu_path = BASE / "digital-brain" / "test-universe.json"
    if not _tu_path.exists():
        print(f"ERROR: {_tu_path} no existe. Ejecuta define-test-universe.py primero.")
        sys.exit(1)
    _tu = json.loads(_tu_path.read_text(encoding="utf-8"))
    # stem del archivo = {db}_{sp_name}  (mismo naming que source/Informix/)
    TU_FILTER = {f"{sp['db']}_{sp['name']}" for sp in _tu.get("sps", [])}
    OUT = BASE / "knowledge-base" / "vocab-candidates-tu.json"
    print(f"Modo TEST UNIVERSE — {len(TU_FILTER)} SPs desde brain.db · fuente: {SRC}")
else:
    OUT = BASE / "knowledge-base" / "vocab-candidates.json"

# ── Cargar sp_vocab.py existente (para comparación) ──────────────────────────
spec = importlib.util.spec_from_file_location(
    "sp_vocab", Path(__file__).parent / "sp_vocab.py")
mod = importlib.util.module_from_spec(spec)
spec.loader.exec_module(mod)
EXISTING: dict = mod.CAT   # token → (cat, mean, estado)
print(f"sp_vocab.py cargado: {len(EXISTING)} términos existentes")

# Claves para longest-match greedy (≥3 chars, mayor a menor) — usado en fully_covered()
VOCAB_KEYS_LONG: list = sorted((k for k in EXISTING if len(k) >= 3), key=len, reverse=True)

# ── Heurísticas de categoría ──────────────────────────────────────────────────

# Verbos bancarios en español + abreviaturas comunes de acción
VERBOS = {
    "consulta","cons","obtiene","obt","actualiza","act","inserta","ins",
    "elimina","eli","genera","gen","carga","carg","valida","val",
    "calcula","calc","procesa","proc","registra","reg","aplica","apl",
    "verifica","ver","crea","modifica","mod","cancela","canc",
    "asigna","asig","marca","ejecuta","ejec","busca","bsc","limpia",
    "envía","envia","env","reporta","rep","exporta","exp","importa",
    "migra","sincroniza","bloquea","desbloquea","activa","desactiva",
    "reinicia","cierra","abre","cobra","paga","transfiere","trf",
    "autoriza","aut","rechaza","aprueba","revisa","audita","califica",
    "notifica","alerta","monitorea","clasifica","libera","reserva",
    "concilia","liquida","dispersa","acredita","debita","abona",
    "evalua","determina","construye","arma","prepara","formatea",
    "agrupa","filtra","ordena","pagina","resume","detalla",
    # Formas adicionales detectadas en corpus BanCoppel
    "amortiza","mapea","clona","homologa","depura","compensa",
    "recalcula","captura","mueve","agrupa","sella","imprime",
    "programa","archiva","respalda","restaura","emite","convierte",
}

# Sufijos morfológicos de verbos españoles — usados en infer_cat como señal secundaria
_VERB_SUFFIX_RELIABLE = ('ando', 'iendo', 'ificar', 'izar', 'ecer')
_VERB_ADJ_EXCLUSIONS  = ('ular', 'ilar', 'olar', 'itar', 'alar', 'iar', 'uar')

def _is_spanish_verb(tok: str) -> bool:
    """Detecta verbos españoles por morfología. Conservadora para evitar falsos positivos."""
    if len(tok) < 6:
        return False
    # Gerundios y sufijos verbalizadores — muy confiables
    for s in _VERB_SUFFIX_RELIABLE:
        if tok.endswith(s) and len(tok) >= len(s) + 3:
            return True
    # Infinitivos -ar/-er/-ir: len ≥ 7, sin patrón de compuesto (xPALABRA) ni adjetivo
    if len(tok) >= 7:
        for e in ('ar', 'er', 'ir'):
            if tok.endswith(e):
                for adj in _VERB_ADJ_EXCLUSIONS:
                    if tok.endswith(adj):
                        return False
                # Excluir compuestos de tabla tipo ctasxprocesar (x intermedia)
                if 'x' in tok[2:-2]:
                    return False
                return True
    return False

# Modificadores típicos de SP (posición final, calificativos)
MODIFS = {
    "gen","general","generales","tot","totales","det","detalle","detalles",
    "hist","historico","historicos","historica","historicas",
    "tmp","temp","temporal","temporales","ext","externo","externos",
    "int","interno","internos","act","activo","activos","activa",
    "prev","previo","ant","anterior","anteriores","nvo","nuevo","nuevos",
    "vig","vigente","vigentes","vdo","vencido","vencidos",
    "canc","cancelado","cancelados","pend","pendiente","pendientes",
    "proc","procesado","procesados","comp","completo","incompleto",
    "ok","err","error","errores","lim","limite","limites",
    "min","max","prom","promedio","acum","acumulado","acumulados",
    "alto","bajo","medio","lto","bjo","med","calc",
    "masivo","masiva","batch","diario","mensual","semanal","anual",
    "inicial","final","parcial","total","neto","bruto",
    "numero","num","monto","cantidad","fecha","folio","clave","codigo",
}

# Tokens técnicos a ignorar (no son vocabulario de negocio)
# ── prefijos de nombres y numerales romanos ──
SKIP = {"sp","fn","v","p","c","i","n","b","f","a","e","o","s","l",
        "x","z","ii","iii","iv","vi","vii","viii","ix","xi","xii"}

# ── Keywords SQL (DML/DDL/funciones de agregado) ──
SKIP |= {
    "select","insert","update","delete","merge","upsert",
    "from","where","join","inner","outer","left","right","full","cross","on",
    "into","values","set","table","view","index","sequence",
    "create","drop","alter","truncate","grant","revoke",
    "and","or","not","in","is","null","like","between","exists","any","all",
    "order","group","having","by","distinct","union","except","intersect",
    "count","sum","max","min","avg","nvl","coalesce","cast","decode",
    "begin","end","commit","rollback","savepoint","transaction",
    "case","when","then","else","true","false",
    "sql","par","flag",
    "fky","pky","idx","seq",
    "statistics","intercard",
    "rowid","fechainsert",
    # Informix/SQL internos que no son vocabulario de negocio
    "informix","public","trim","old","describe","catalog",
    "dirty","middle","element","log",
}

# ── Keywords Informix SPL ──
SKIP |= {
    "define","let","return","returning","foreach","fetch","exit","continue",
    "procedure","function","call","execute","raise","exception","on","of",
    "cursor","prepare","declare","open","close","put","flush","free",
    "char","int","integer","smallint","bigint","decimal","money","float",
    "double","varchar","nvarchar","lvarchar","text","byte","blob","clob",
    "datetime","date","time","interval","serial","boolean","list","multiset",
    "row","record","array","like","matches","units","year","month","day",
    "hour","minute","second","fraction","first","skip","limit","page",
    "system","current","today","user","sitename","dbinfo",
}


# ── Filtros de candidatos nuevos ─────────────────────────────────────────────
RE_DIGIT_SUFFIX   = re.compile(r'\d+$')            # nombre1, nombre2, cta3...
RE_NAMING_PREFIX  = re.compile(r'^(?:tbl|tmp|mae|cat|bd)(?=[a-z])', re.I)  # naming DB: tbl*/tmp*/mae*/cat*/bd*

# Tokens técnicos que escapan los filtros de extracción (p.ej. col_freq no tiene SKIP check)
TECHNICAL_EXTRA = (
    {"call", "cron", "idrow", "row"}                       # infraestructura SPL/scheduler
    | {"dba", "wsdl", "parametroswsdl"}                    # roles/protocolos técnicos
    | {"assign", "service", "username", "sign",            # inglés técnico — infraestructura/API
       "timestamp", "currency", "file", "core", "usr",
       "caccessmethod", "accessmethod",
       "counter", "code", "device", "flex",
       "macadress"}
    | {"juan", "pedro", "maria", "jose"}                   # nombres propios hardcoded en SPs de prueba
    | {"movhiswhere", "cadaxdia", "casocuatro",            # literales de código hardcoded
       "casocinco", "pasoambos", "diezmil",
       "svrremoto"}
)

def fully_covered(tok: str) -> bool:
    """True si el token es completamente descomponible en términos ya curados."""
    if tok in EXISTING:
        return True
    i, n = 0, len(tok)
    while i < n:
        matched = False
        for key in VOCAB_KEYS_LONG:
            if tok[i:i + len(key)] == key:
                i += len(key)
                matched = True
                break
        if not matched:
            return False
    return i == n


def is_abbrev_of_vocab(tok: str) -> bool:
    """True si tok es prefijo de un término ya curado — sinónimo/abreviación, no término nuevo."""
    if len(tok) < 3:
        return False
    for key in EXISTING:
        if len(key) > len(tok) + 1 and key.startswith(tok):
            return True
    return False


def is_hung_derivative(tok: str, surface_tokens) -> bool:
    """True si tok es derivado por prefijo húngaro residual o strip incorrecto.

    Caso 1 — prefijo residual de 1 char (susuario → s + usuario):
      Quita el primer char; si la base existe en corpus o vocab, es un duplicado.
    Caso 1b — prefijo residual de 2 chars (dtfechaini → dt + fechaini):
      Quita 'dt' o 'arr'; si la base existe en corpus o vocab, es un duplicado.
    Caso 2 — strip incorrecto (echa ← dehung('fecha') quitó 'f'):
      Añade cada posible prefijo húngaro al frente; si el resultado está en
      el vocab curado, el token es un fragmento producido por dehung erróneo.
    """
    if len(tok) < 3:
        return False
    # Caso 1 — prefijo de 1 char
    if len(tok) >= 4:
        base = tok[1:]
        if len(base) >= 3 and (base in surface_tokens or base in EXISTING):
            return True
        # Base no aparece directamente → puede ser compuesto (movmontocashback → mov+monto+cashback)
        if len(base) >= 8 and fully_covered_broad(base):
            return True
    # Caso 1b — prefijos de 2 chars (dt = DateTime, arr = array)
    for pre in ('dt', 'arr'):
        if tok.startswith(pre) and len(tok) > len(pre) + 2:
            base = tok[len(pre):]
            if len(base) >= 3 and (base in surface_tokens or base in EXISTING):
                return True
    # Caso 2 — strip incorrecto: recuperar original añadiendo prefijo al frente
    for p in 'spcivnbfdolmw':
        if (p + tok) in EXISTING:
            return True
    return False


def is_plural_derivative(tok: str, surface_tokens) -> bool:
    """True si tok es plural y su forma base (singular) ya existe en el corpus.
    El vocabulario canónico usa la forma base; el plural es un derivado redundante.
      tramites   → tramite   (quitar 's')
      sucursales → sucursal  (quitar 'es')
      cancelados → cancelado (quitar 's')
    """
    if len(tok) < 4:
        return False
    # Plural simple: tramites → tramite, cancelados → cancelado
    if tok.endswith('s') and not tok.endswith('es'):
        if tok[:-1] in surface_tokens:
            return True
    # Plural con -es: sucursales → sucursal, cancelaciones → cancelacion
    if tok.endswith('es') and len(tok) > 4:
        if tok[:-2] in surface_tokens:   # sucursales → sucursal
            return True
        if tok[:-1] in surface_tokens:   # tramites → tramite (termina en 'es' pero base en 'e')
            return True
    return False


def is_suffix_derivative(tok: str) -> bool:
    """True si tok es un derivado por sufijo de 1 char de un término curado.
    Patrón: archivo + c → archivoc (sufijo de tipo en nombres de tabla SPL).

    Guards para evitar falsos positivos:
    - Excluye sufijo 'r': infinitivos españoles (cobrar, generar) no son derivados técnicos
    - Base debe tener ≥ 4 chars: evita filtrar abreviaturas cortas (tarj→tar, calc→cal)
    - Solo chequea contra EXISTING (vocab curado)
    """
    if len(tok) < 5:
        return False
    suffix = tok[-1]
    if suffix == 'r':          # infinitivo español: cobrar/enviar/generar/validar
        return False
    base = tok[:-1]
    # base >= 5: evita que abreviaturas cortas (camp, tipo) filtren la palabra completa.
    return len(base) >= 5 and base in EXISTING


# Códigos de tipo SPL usados en BanCoppel como sufijo de 1 char en nombres de tabla:
# c = corriente/actual, h = histórico, t = temporal
_SPL_TYPE_CODES: set = {'c', 'h', 't'}
_compound_type_cache: dict = {}  # memoize base decompositions (base → bool)

def is_compound_plus_type_code(tok: str) -> bool:
    """True si tok = {compuesto_descomponible} + {código_tipo_SPL de 1 char}.
    Captura: sdomensualc = (sdo+mensual) + c, sdodiarioc = (sdo+diario) + c.
    Solo activa cuando el sufijo está en _SPL_TYPE_CODES (whitelist explícita).
    """
    if len(tok) < 9:  # base mínima de 8 chars + 1 char sufijo
        return False
    if tok[-1] not in _SPL_TYPE_CODES:
        return False
    base = tok[:-1]
    if len(base) < 8:
        return False
    # Memoize: el DP es idempotente para la misma base
    if base not in _compound_type_cache:
        _compound_type_cache[base] = fully_covered_broad(base)
    return _compound_type_cache[base]


def infer_cat(token: str, avg_rel_pos: float) -> str:
    """
    Infiere categoría por heurística.
    avg_rel_pos: posición promedio relativa al total de tokens del SP (0.0–1.0)
    """
    t = token.lower()
    if t in SKIP:
        return "PREFIJO"
    if t in VERBOS or _is_spanish_verb(t):
        return "ACCION"
    if t in MODIFS:
        return "MODIF"
    # Por posición relativa
    if avg_rel_pos < 0.20:
        return "PREFIJO"
    if avg_rel_pos > 0.72:
        return "MODIF"
    return "ENTIDAD"


# ── Escanear corpus: source/Informix/*.sql ─────────────────────────────────
# Fuente siempre = source/Informix/ (corpus canónico).
# TU_FILTER (set de stems) restringe el escaneo al test universe cuando se activa.
_scope = f"test-universe ({len(TU_FILTER)} SPs)" if TU_FILTER is not None else "corpus completo"
print(f"Escaneando {_scope}: {SRC}")
sp_files_found = 0

# ── Extraer tokens de nombres de SP ──────────────────────────────────────────
token_freq:     Counter                       = Counter()
token_sps:      defaultdict[str, list[str]]  = defaultdict(list)
token_rel_pos:  defaultdict[str, list[float]] = defaultdict(list)

if SRC.exists():
    for f in SRC.iterdir():
        if f.suffix != ".sql":
            continue
        stem  = f.stem                          # e.g. "bdiaclaracion_sp_acl_foo"
        if TU_FILTER is not None and stem not in TU_FILTER:
            continue                             # fuera del test universe — saltar
        segs  = stem.split("_")
        if len(segs) < 2:
            continue
        db       = segs[0]                      # "bdiaclaracion"
        sp_name  = "_".join(segs[1:])          # "sp_acl_foo"
        sp_files_found += 1
        clean = re.sub(r"^(sps|sp|fn)_", "", sp_name)  # strip sps_/sp_/fn_ (underscore requerido)
        parts = [p.lower() for p in clean.split("_") if p and len(p) >= 2]
        total = len(parts)
        if total == 0:
            continue
        for pos, tok in enumerate(parts):
            if tok in SKIP:
                continue
            token_freq[tok] += 1
            token_rel_pos[tok].append(pos / total)
            if len(token_sps[tok]) < 6:
                token_sps[tok].append(f"{db}:{sp_name}")

print(f"  {sp_files_found} SPs escaneados desde source/")

# ── Extraer tokens de parámetros + DEFINE del cuerpo (corpus 100%) ───────────
print("Leyendo parámetros y variables DEFINE de .sql...")
RE_SIG    = re.compile(
    r"CREATE\s+(?:PROCEDURE|FUNCTION)\s+[^\(]*\(([^;]*?)\)\s*RETURNING", re.I | re.S)
RE_PARAM  = re.compile(r"\s*([a-zA-Z][a-zA-Z0-9_]*)\s+\w")
# DEFINE varname TYPE  — variable declarations en cuerpo SPL
RE_DEFINE = re.compile(r"\bDEFINE\s+([a-zA-Z][a-zA-Z0-9_]*)\s+", re.I)
# Tablas: FROM/INSERT INTO/UPDATE/JOIN tabla  (prefijo de DB opcional: bdinteg:tabla)
# EXCLUYE bare INTO (usado para cursores: FETCH cur INTO var) — solo INSERT INTO
RE_TABLE  = re.compile(
    r"\b(?:FROM|INSERT\s+INTO|UPDATE|JOIN)\s+(?:[a-z][a-z0-9]{0,8}:)?([a-z][a-z0-9_]{2,})",
    re.I)
# Nombres de BD de BanCoppel (bdi*) y tablas de sistema Informix — no son vocabulario
TABLE_SKIP_PAT = re.compile(r"^bdi[a-z]|^sys|^outer$|^temp$|^tmp$", re.I)
# Columnas en cláusulas WHERE/SET/AND — atributos de negocio finos
RE_COL    = re.compile(
    r"(?:WHERE|AND|OR|SET)\s+([a-z][a-z0-9_]{2,})\s*(?:[=<>!]|IS\b|LIKE\b|IN\b)",
    re.I)
# Prefijos húngaros SPL lowercase
HUNG_PRE_LC = re.compile(r"^(p|v|c|i|n|b|f|dt|arr|l|s|w|m|d|o)((?:[a-z])[a-z0-9]+)")

def dehung(raw: str) -> list[str]:
    """Elimina prefijo húngaro lowercase y fragmenta por '_'."""
    m = HUNG_PRE_LC.match(raw)
    core = m.group(2) if m else raw
    parts = [p for p in core.split("_") if len(p) >= 3]
    return parts if parts else ([core] if len(core) >= 3 else [])

param_freq:  Counter = Counter()
define_freq: Counter = Counter()
table_freq:  Counter = Counter()   # nombres de tabla — modelo de datos canónico
col_freq:    Counter = Counter()   # columnas en WHERE/SET — atributos finos
sql_files_read = 0

if SRC.exists():
    for f in SRC.iterdir():
        if not f.suffix == ".sql":
            continue
        if TU_FILTER is not None and f.stem not in TU_FILTER:
            continue  # fuera del test universe — saltar
        sql_files_read += 1
        try:
            body = f.read_text(encoding="utf-8", errors="replace")
        except Exception:
            continue
        # 1. Parámetros (firma)
        m = RE_SIG.search(body[:3000])
        if m:
            for chunk in m.group(1).split(","):
                pm = RE_PARAM.match(chunk)
                if not pm:
                    continue
                for tok in dehung(pm.group(1).lower()):
                    if tok not in SKIP:
                        param_freq[tok] += 1
        # 2. Variables locales DEFINE del cuerpo
        for dm in RE_DEFINE.finditer(body):
            for tok in dehung(dm.group(1).lower()):
                define_freq[tok] += 1
        # 3. Nombres de tabla (modelo de datos canónico del banco)
        for tm in RE_TABLE.finditer(body):
            raw = tm.group(1).lower()
            parts = [p for p in raw.split("_") if len(p) >= 3]
            for tok in parts:
                if not TABLE_SKIP_PAT.match(tok) and tok not in SKIP:
                    table_freq[tok] += 1
                    # Rescatar sufijo de negocio de tablas con prefijo de convención:
                    # catzonas→zona, tblclientes→cliente, maetipo→tipo
                    nm = RE_NAMING_PREFIX.match(tok)
                    if nm:
                        suffix = tok[nm.end():]
                        if len(suffix) >= 3 and suffix not in SKIP:
                            table_freq[suffix] += 1
                            # Añadir también la forma base singular para que pase el filtro plural
                            if suffix.endswith('s') and not suffix.endswith('es') and len(suffix) > 3:
                                base = suffix[:-1]
                                if len(base) >= 3:
                                    table_freq[base] += 1
                            elif suffix.endswith('es') and len(suffix) > 4:
                                base = suffix[:-2]
                                if len(base) >= 3:
                                    table_freq[base] += 1
        # 4. Columnas en WHERE/SET (atributos finos de entidades de negocio)
        for cm in RE_COL.finditer(body):
            raw = cm.group(1).lower()
            parts = [p for p in raw.split("_") if len(p) >= 3]
            for tok in parts:
                col_freq[tok] += 1
    print(f"  {sql_files_read} archivos .sql leídos · {len(param_freq)} tokens params · "
          f"{len(table_freq)} tokens tabla · {len(col_freq)} tokens columna · "
          f"{len(define_freq)} tokens DEFINE")
else:
    print("  source/ no disponible — solo tokens de nombres")

# ── Cuatro frecuencias, dos niveles ──────────────────────────────────────────
# combined_surface: nombres + params + tablas → candidatos LLM (señal limpia de negocio)
# combined_full:    + columnas + DEFINE        → cobertura máxima para validar sp_vocab.py
#
# Tablas van a surface: los nombres de tabla son el vocabulario canónico del modelo de datos.
# Columnas y DEFINE van solo a full: pueden incluir ruido técnico (codret, sqlerr, etc.)
combined_surface: Counter = Counter()  # nombres + params + tablas
for tok, f in token_freq.items():
    combined_surface[tok] = f
for tok, f in param_freq.items():
    combined_surface[tok] = combined_surface.get(tok, 0) + f
for tok, f in table_freq.items():
    combined_surface[tok] = combined_surface.get(tok, 0) + f

combined_full: Counter = Counter(combined_surface)  # + columnas + DEFINE
for tok, f in col_freq.items():
    combined_full[tok] = combined_full.get(tok, 0) + f
for tok, f in define_freq.items():
    combined_full[tok] = combined_full.get(tok, 0) + f

# ── Vocabulario ampliado para detección de compuestos ─────────────────────────
# Compuestos: table names que concatenan dos conceptos sin guion bajo, e.g.:
#   registrosolicitud = registro + solicitud
#   movimientoshistorial = movimientos + historial
#   billetesfalsos = billetes + falsos
# Se descomponen en partes simples y el compuesto se filtra — las partes llegan
# como candidatos independientes desde token_freq / param_freq / table_freq.
MIN_FREQ = 3   # mínimo para ser candidato "new" (no gap)

_broad_vocab: set = set(k for k in EXISTING if len(k) >= 3)   # curado: desde 3 chars (mov, num, cod…)
_broad_vocab |= {t for t, f in combined_surface.items() if f >= MIN_FREQ and len(t) >= 4}  # corpus: desde 4
BROAD_KEYS_LONG: list = sorted(_broad_vocab, key=len, reverse=True)


def fully_covered_broad(tok: str) -> bool:
    """True si tok (≥8 chars) es descomponible en ≥2 partes (cada una ≥4)
    usando el vocabulario ampliado (curado + corpus de alta frecuencia).

    Usa DP bidireccional para evitar el fallo del greedy cuando un plural
    (registros, len=9) bloquea al singular (registro, len=8):
      forward[i]  = True si la posición i es alcanzable desde 0
      backward[i] = True si la posición n es alcanzable desde i
    Hay descomposición válida si existe un punto de corte s en [4, n-4]
    donde forward[s] y backward[s] son ambos True.
    """
    if len(tok) < 8:
        return False
    if tok in EXISTING:
        return True
    n = len(tok)

    # Paso 1 — alcanzabilidad hacia adelante desde posición 0
    forward = [False] * (n + 1)
    forward[0] = True
    for i in range(n):
        if not forward[i]:
            continue
        for key in BROAD_KEYS_LONG:
            if key == tok:
                continue
            j = i + len(key)
            if j <= n and tok[i:j] == key:
                forward[j] = True

    if not forward[n]:
        return False

    # Paso 2 — alcanzabilidad hacia atrás desde posición n
    backward = [False] * (n + 1)
    backward[n] = True
    for i in range(n - 1, -1, -1):
        for key in BROAD_KEYS_LONG:
            if key == tok:
                continue
            j = i + len(key)
            if j <= n and tok[i:j] == key and backward[j]:
                backward[i] = True

    # Paso 3 — existe punto de corte con ≥2 partes (mínimo 3 chars por parte)
    # range(3, n-2): permite primera parte de 3 chars (sdo+mensual, mov+monto+...)
    # El mínimo de 8 chars del token garantiza que ambas partes sean significativas.
    for s in range(3, n - 2):
        if forward[s] and backward[s]:
            return True
    return False


# ── Clasificar tokens ─────────────────────────────────────────────────────────

known, new_list, gap = [], [], []

# Candidatos nuevos vienen de combined_surface (sin ruido de DEFINE)
# known usa combined_full (máxima cobertura para recuperar sp_vocab.py existentes)
all_tokens: set = set(combined_surface.keys()) | set(
    tok for tok in (define_freq.keys() | col_freq.keys()) if tok in EXISTING)

for tok in sorted(all_tokens, key=lambda t: combined_full.get(t, 0), reverse=True):
    freq_surface = combined_surface.get(tok, 0)
    freq_full    = combined_full.get(tok, 0)
    avg_rp = (sum(token_rel_pos[tok]) / len(token_rel_pos[tok])
               if token_rel_pos[tok] else 0.5)
    inf_cat = infer_cat(tok, avg_rp)
    samples = token_sps[tok][:5]

    if tok in EXISTING:
        cat_e, mean_e, est_e = EXISTING[tok][:3]
        known.append({
            "token":        tok,
            "freq":         freq_full,
            "freq_sp_name": freq_surface,
            "cat":          cat_e,
            "mean":         mean_e,
            "estado":       est_e,
            "inferred_cat": inf_cat,
            "cat_match":    cat_e == inf_cat,
            "sample_sps":   samples,
        })
    elif freq_surface >= MIN_FREQ:
        # ── Filtros: tokens que no aportan vocabulario nuevo ──────────────────
        skip_reason = None
        if RE_DIGIT_SUFFIX.search(tok):
            skip_reason = "digit_suffix"       # nombre1, nombre2
        elif len(tok) < 3:
            skip_reason = "too_short"           # 1-2 chars no cubiertos por SKIP
        elif RE_NAMING_PREFIX.search(tok):
            skip_reason = "naming_convention"  # tbl*/tmp*/mae* = artifacts de naming DB
        elif is_plural_derivative(tok, combined_surface):
            skip_reason = "plural_derivative"  # tramites→tramite, sucursales→sucursal
        elif is_hung_derivative(tok, combined_surface):
            skip_reason = "hung_derivative"    # susuario→usuario, echa←fecha
        elif tok in TECHNICAL_EXTRA:
            skip_reason = "technical_extra"    # call/cron/idrow — técnicos que escapan SKIP
        elif is_suffix_derivative(tok):
            skip_reason = "suffix_derivative"  # archivoc→archivo (sufijo tipo 1-char en vocab)
        elif is_compound_plus_type_code(tok):
            skip_reason = "compound_type_code" # sdomensualc=(sdo+mensual)+c
        elif is_abbrev_of_vocab(tok):
            skip_reason = "abbrev_vocab"       # 'dom'→'domicilio', 'cli'→'cliente' (sinónimo)
        elif fully_covered(tok):
            skip_reason = "covered_compound"   # numcliente = num+cliente
        elif fully_covered_broad(tok):
            skip_reason = "compound_decomposed" # registrosolicitud = registro+solicitud

        if skip_reason:
            gap.append({
                "token":       tok,
                "freq":        freq_surface,
                "skip_reason": skip_reason,
            })
        else:
            new_list.append({
                "token":        tok,
                "freq":         freq_surface,
                "inferred_cat": inf_cat,
                "mean":         "",
                "estado":       "gap",
                "sample_sps":   samples,
                "origen":       (
                    "sp_name+table" if tok in token_freq and tok in table_freq else
                    "table_name"    if tok in table_freq else
                    "sp_name"       if tok in token_freq else
                    "param_only"
                ),
            })
    elif freq_surface > 0:
        gap.append({
            "token":        tok,
            "freq":         freq_surface,
            "inferred_cat": inf_cat,
            "sample_sps":   samples[:3],
        })

# ── Reporte ───────────────────────────────────────────────────────────────────
cat_match = sum(1 for k in known if k["cat_match"])
pct_match = cat_match * 100 // len(known) if known else 0

n_digit    = sum(1 for g in gap if g.get("skip_reason") == "digit_suffix")
n_short    = sum(1 for g in gap if g.get("skip_reason") == "too_short")
n_naming   = sum(1 for g in gap if g.get("skip_reason") == "naming_convention")
n_plural   = sum(1 for g in gap if g.get("skip_reason") == "plural_derivative")
n_hung     = sum(1 for g in gap if g.get("skip_reason") == "hung_derivative")
n_technical= sum(1 for g in gap if g.get("skip_reason") == "technical_extra")
n_suffix   = sum(1 for g in gap if g.get("skip_reason") == "suffix_derivative")
n_comptype = sum(1 for g in gap if g.get("skip_reason") == "compound_type_code")
n_abbrev   = sum(1 for g in gap if g.get("skip_reason") == "abbrev_vocab")
n_covered  = sum(1 for g in gap if g.get("skip_reason") == "covered_compound")
n_compound = sum(1 for g in gap if g.get("skip_reason") == "compound_decomposed")

print(f"\nResumen:")
print(f"  Tokens únicos (surface — nombres+params+tablas): {len(combined_surface)}")
print(f"  Tokens únicos (full — +columnas+DEFINE):         {len(combined_full)}")
print(f"  Ya en sp_vocab.py (known):               {len(known)}")
print(f"    Categoría coincide con heurística:     {cat_match}/{len(known)} ({pct_match}%)")
print(f"  Candidatos LLM (freq≥{MIN_FREQ}):                {len(new_list)}")
print(f"  Filtrados (→ gap):")
print(f"    sufijo numérico:                       {n_digit}")
print(f"    longitud < 3:                          {n_short}")
print(f"    naming convention (tbl/tmp/mae):       {n_naming}")
print(f"    plural (derivado de forma base):       {n_plural}")
print(f"    derivado húngaro (susuario→usuario):   {n_hung}")
print(f"    técnico extra (call/cron/idrow):       {n_technical}")
print(f"    derivado sufijo (archivoc→archivo):    {n_suffix}")
print(f"    compuesto+código tipo (sdomensualc):  {n_comptype}")
print(f"    abreviación de vocab (sinónimo):       {n_abbrev}")
print(f"    compuesto cubierto por vocab:          {n_covered}")
print(f"    compuesto descomponible (corpus):      {n_compound}")
print(f"  Gap (freq<{MIN_FREQ} o filtrado):                {len(gap)}")

print(f"\nTop 20 tokens nuevos (freq≥{MIN_FREQ}):")
for t in new_list[:20]:
    print(f"  [{t['inferred_cat']:8}] {t['token']:25} freq={t['freq']:4}  ej: {t['sample_sps'][0] if t['sample_sps'] else '-'}")

# Tokens conocidos donde la heurística discrepa
discrepancias = [k for k in known if not k["cat_match"]]
if discrepancias:
    print(f"\nDiscrepancias heurística vs sp_vocab.py ({len(discrepancias)}):")
    for d in discrepancias[:10]:
        print(f"  {d['token']:20} sp_vocab={d['cat']:8} heurística={d['inferred_cat']}")

# ── Guardar ───────────────────────────────────────────────────────────────────
out = {
    "meta": {
        "generated":     str(date.today()),
        "tool":          "build-vocab-auto.py",
        "sp_count":      sp_files_found,
        "sql_read":      sql_files_read,
        "min_freq":      MIN_FREQ,
        "total_tokens_surface": len(combined_surface),
        "total_tokens_full":    len(combined_full),
        "sources": {
            "sp_names":  len(token_freq),
            "params":    len(param_freq),
            "tables":    len(table_freq),
            "columns":   len(col_freq),
            "defines":   len(define_freq),
        },
        "total_known":   len(known),
        "total_new":     len(new_list),
        "total_gap":     len(gap),
        "cat_match_pct": pct_match,
    },
    "known": known,
    "new":   new_list,
    "gap":   gap,
}

OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2), encoding="utf-8")
print(f"\nvocab-candidates.json → {OUT}")
print(f"Siguiente: enrich-vocab-llm.py — genera campo 'mean' para {len(new_list)} tokens nuevos")
