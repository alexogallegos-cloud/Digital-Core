#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-rules.py v2.0 — GENCore · Extractor de reglas de negocio ABAP

Modos:
  gemini  — Vertex AI Gemini 2.0 Flash (motor principal, producción)
  regex   — extractor de patrones (sin dependencias GCP, backwards-compat)
  hybrid  — gemini primero; regex como fallback si falla o no hay credenciales

Diseñado para escala:
  - Cache por hash MD5 del archivo (evita re-procesar en re-ejecuciones)
  - Checkpointing: reanuda desde el último archivo completado
  - Semáforo de concurrencia (default: 20 llamadas paralelas a Gemini)
  - asyncio.to_thread: no bloquea el loop con llamadas síncronas de vertexai
  - Cost tracking: tokens consumidos y estimado USD al final

Uso:
  python extract-rules.py
  python extract-rules.py --mode gemini --project gentera-gemcog --concurrency 30
  python extract-rules.py --mode regex
  python extract-rules.py --mode gemini --no-cache   # forzar re-proceso

Requisitos para modo gemini:
  pip install google-cloud-aiplatform
  gcloud auth application-default login   (local)
  — o — Service Account con roles/aiplatform.user  (Cloud Run)

GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""

import argparse
import asyncio
import hashlib
import json
import re
import sys
import time
from collections import Counter
from pathlib import Path

if hasattr(sys.stdout, 'reconfigure'):
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ── Rutas ─────────────────────────────────────────────────────────────────────

BASE       = Path(__file__).parent
SOURCE     = BASE / 'source'
OUT        = BASE / 'rules-gentera.json'
CACHE_DIR  = BASE / '.rule-cache'
CKPT_FILE  = CACHE_DIR / 'checkpoint.json'
INV_FILE   = BASE / 'objects-inventory.json'

# ── Gemini ────────────────────────────────────────────────────────────────────

GEMINI_MODEL    = 'gemini-2.0-flash-001'
GEMINI_LOCATION = 'us-central1'

# Schema OpenAPI para structured output
RULE_SCHEMA = {
    'type': 'array',
    'items': {
        'type': 'object',
        'properties': {
            'metodo':        {'type': 'string'},
            'linea':         {'type': 'integer'},
            'tipo':          {'type': 'string',
                              'enum': ['VALIDACION', 'FLUJO', 'MANEJO_ERROR',
                                       'CALCULO', 'REGULATORIO', 'AUTORIZACION']},
            'condicion':     {'type': 'string'},
            'business_name': {'type': 'string'},
            'reg':           {'type': 'string', 'nullable': True},
            'riesgo':        {'type': 'string',
                              'enum': ['ALTO', 'MEDIO', 'BAJO']},
        },
        'required': ['metodo', 'linea', 'tipo', 'condicion', 'business_name', 'riesgo'],
    },
}

PROMPT_TMPL = """\
Eres un experto en SAP ABAP y lógica de negocio de microfinanzas en México.
Sistema: Gentera (Compartamos Banco) — crédito grupal e individual, CNBV, IFRS 9.

Extrae TODAS las reglas de negocio del código ABAP siguiente.
Una regla es cualquier fragmento que:
  - Valida datos o estado del sistema (IF, CHECK, CASE/WHEN con significado funcional)
  - Bifurca el flujo por razones de negocio (no puramente técnicas)
  - Maneja errores funcionales (MESSAGE tipo E/A/X, RAISE EXCEPTION TYPE)
  - Calcula o transforma valores financieros (montos, tasas, cuotas, intereses, mora)
  - Controla autorización SAP (AUTHORITY-CHECK)
  - Implementa o referencia regulación (CNBV, IFRS, SAT, CONDUSEF, PLD, Banxico, IPAB)

Objeto SAP: {obj_id}  |  Tipo: {obj_tipo}

--- INICIO CÓDIGO ---
{code}
--- FIN CÓDIGO ---

Para cada regla:
  metodo        — nombre exacto del METHOD o FORM ABAP donde aparece; prefija "FORM_" para subroutinas
                  (string vacío si es INITIALIZATION/TOP-INCLUDE)
  linea         — número de línea donde está la expresión clave (entero)
  tipo          — VALIDACION | FLUJO | MANEJO_ERROR | CALCULO | REGULATORIO | AUTORIZACION
  condicion     — expresión ABAP exacta, máx 300 chars
  business_name — qué hace esta regla en términos de negocio de microfinanzas (español, máx 120 chars)
  reg           — CNBV | IFRS | SAT | CONDUSEF | PLD | BANXICO | IPAB  — o null si no es regulatorio
  riesgo        — ALTO si afecta cálculos financieros/montos/tasas/comisiones
                  MEDIO si afecta fechas/estados/ciclos/vigencias
                  BAJO si es técnico/estructural/logging

Responde ÚNICAMENTE con el array JSON. Sin texto adicional.\
"""

# ── Señales regulatorias y de riesgo (usadas por regex + validación Gemini) ──

_REG_PATTERNS = [
    (re.compile(r'\b(cnbv|circular\s*\d+|portafolio|cartera\s*regulat)', re.I), 'CNBV'),
    (re.compile(r'\b(ifrs|niif|nif\b)',                                  re.I), 'IFRS'),
    (re.compile(r'\b(sat\b|isr\b|iva\b|cfdi|rfc\b)',                    re.I), 'SAT'),
    (re.compile(r'\b(condusef|queja|reclamo)',                           re.I), 'CONDUSEF'),
    (re.compile(r'\b(pld\b|lavado|lfpiorpi|sospechosa)',                 re.I), 'PLD'),
    (re.compile(r'\b(banxico|spei|siac|codi\b)',                         re.I), 'BANXICO'),
    (re.compile(r'\b(ipab\b|seguro_?de_?deposito)',                      re.I), 'IPAB'),
]

_RISK_HIGH = re.compile(
    r'\b(monto|saldo|importe|interes|tasa|comision|amortiza|'
    r'pago|cargo|abono|capital|deuda|mora|penaliz|cuota|'
    r'redondeo|round|truncat|ceil|floor|division|multiplic)', re.I
)
_RISK_MED = re.compile(
    r'\b(fecha|dia|mes|año|plazo|vencim|vigencia|ciclo|periodo|'
    r'estatus|estado|activo|inactivo|bloqueado|cancelado)', re.I
)

_VALID_TIPOS  = {'VALIDACION','FLUJO','MANEJO_ERROR','CALCULO','REGULATORIO','AUTORIZACION'}
_VALID_RIESGO = {'ALTO','MEDIO','BAJO'}
_VALID_REG    = {None,'CNBV','IFRS','SAT','CONDUSEF','PLD','BANXICO','IPAB'}


# ── Utilidades ────────────────────────────────────────────────────────────────

def _file_hash(path: Path) -> str:
    return hashlib.md5(path.read_bytes()).hexdigest()


def _detect_obj_id(text: str, stem: str) -> str:
    m = re.search(r'^\s*class\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)\s+definition', text, re.I | re.M)
    if m:
        return m.group(1).upper()
    m = re.search(r'^\s*(?:PROGRAM|REPORT)\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)', text, re.I | re.M)
    if m:
        return m.group(1).upper()
    m = re.search(r'^\s*FUNCTION-POOL\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)', text, re.I | re.M)
    if m:
        return m.group(1).upper()
    raw = stem.lstrip('_')
    parts = raw.split('_', 1)
    return f"/{parts[0]}/{parts[1]}" if len(parts) == 2 else raw.upper()


def _detect_tipo_abap(path: Path) -> str:
    tipo_map = {'CLASS': 'class', 'PROG': 'program', 'FUGR': 'function_group', 'INTF': 'interface'}
    return tipo_map.get(path.parent.name.upper(), 'unknown')


_BLOCK_START = re.compile(r'^\s*(?:METHOD|FORM)\s+', re.I)


def _chunk_by_method(text: str, max_lines: int = 450) -> list[tuple[str, int]]:
    """Divide texto ABAP en chunks por METHOD/FORM para archivos grandes (OO + ECC classic)."""
    lines = text.splitlines()
    if len(lines) <= max_lines:
        return [(text, 0)]

    chunks: list[tuple[str, int]] = []
    chunk_start  = 0
    chunk_lines: list[str] = []
    # Incluir cabecera (hasta primer METHOD o FORM) en cada chunk para contexto
    header_end = 0
    for i, line in enumerate(lines):
        if _BLOCK_START.match(line):
            header_end = i
            break
    header = '\n'.join(lines[:header_end])

    for i, line in enumerate(lines):
        if _BLOCK_START.match(line) and len(chunk_lines) >= max_lines:
            full_chunk = header + '\n' + '\n'.join(chunk_lines) if header else '\n'.join(chunk_lines)
            chunks.append((full_chunk, chunk_start))
            chunk_start = i
            chunk_lines = [line]
        else:
            chunk_lines.append(line)

    if chunk_lines:
        full_chunk = header + '\n' + '\n'.join(chunk_lines) if header else '\n'.join(chunk_lines)
        chunks.append((full_chunk, chunk_start))

    return chunks or [(text, 0)]


def _validate_rules(raw: list, obj_id: str, fuente: str) -> list[dict]:
    """Limpia y valida reglas retornadas por Gemini."""
    clean = []
    for r in raw:
        if not isinstance(r, dict):
            continue
        tipo   = str(r.get('tipo', 'VALIDACION')).upper()
        riesgo = str(r.get('riesgo', 'BAJO')).upper()
        reg    = r.get('reg')
        if isinstance(reg, str):
            reg = reg.upper() if reg.upper() in _VALID_REG else None

        if tipo   not in _VALID_TIPOS:  tipo   = 'VALIDACION'
        if riesgo not in _VALID_RIESGO: riesgo = 'BAJO'

        clean.append({
            'obj_id'       : obj_id,
            'metodo'       : str(r.get('metodo', 'UNKNOWN'))[:80],
            'linea'        : int(r.get('linea', 0)),
            'tipo'         : tipo,
            'condicion'    : str(r.get('condicion', ''))[:300],
            'business_name': str(r.get('business_name', ''))[:120],
            'reg'          : reg,
            'riesgo'       : riesgo,
            'fuente'       : fuente,
        })
    return clean


# ── Extractor Regex (v1, sin dependencias) ───────────────────────────────────

def _detect_reg(text: str):
    for pat, tag in _REG_PATTERNS:
        if pat.search(text):
            return tag
    return None


def _detect_risk(cond: str) -> str:
    if _RISK_HIGH.search(cond): return 'ALTO'
    if _RISK_MED.search(cond):  return 'MEDIO'
    return 'BAJO'


def _clean_var(v: str) -> str:
    v = v.strip().lstrip('!')
    m = re.match(r'^[ilegrc][tvsorwcoxng]_(.+)', v.lower())
    return m.group(1).replace('_', ' ') if m else v.lower().replace('_', ' ')


def _humanize(cond: str, metodo: str) -> str:
    c = cond.strip().rstrip('.')
    if re.search(r'IS\s+INITIAL', c, re.I):
        return f"{_clean_var(re.sub(r'\\s+IS\\s+INITIAL.*', '', c, flags=re.I))} es requerido"
    if re.search(r'IS\s+NOT\s+INITIAL', c, re.I):
        return f"Solo procesa si {_clean_var(re.sub(r'\\s+IS\\s+NOT\\s+INITIAL.*', '', c, flags=re.I))} tiene valor"
    if re.search(r'IS\s+(NOT\s+)?BOUND', c, re.I):
        return f"Patrón singleton: verifica instancia de {_clean_var(re.sub(r'\\s+IS.*', '', c, flags=re.I))}"
    if re.search(r'sy-subrc\s*(NE|<>)\s*0', c, re.I):
        return "Error si la operación anterior no encontró registros"
    if re.search(r'sy-subrc\s*=\s*0', c, re.I):
        return "Continúa solo si la operación anterior tuvo éxito"
    if re.search(r'NOT\s+sy-subrc\s+IS\s+INITIAL', c, re.I):
        return "Error si la operación anterior no encontró registros"
    return f"Condición en {metodo.lower().replace('_',' ')}: {c[:80]}"


def _parse_method_ranges(text: str) -> list[tuple[int, int, str]]:
    """Mapea rangos de líneas a nombres de METHOD (OO) y FORM subroutinas (ECC classic)."""
    lines = text.splitlines()
    ranges, current = [], None
    for i, line in enumerate(lines, 1):
        # OO ABAP: METHOD / ENDMETHOD
        m = re.match(r'^\s*METHOD\s+(\S+)', line, re.I)
        if m:
            if current:
                ranges.append((current[0], i - 1, current[1]))
            current = (i, m.group(1).upper())
            continue
        if re.match(r'^\s*ENDMETHOD', line, re.I) and current:
            ranges.append((current[0], i, current[1]))
            current = None
            continue
        # Classic ECC ABAP: FORM / ENDFORM
        fm = re.match(r'^\s*FORM\s+([A-Z_][A-Z0-9_]*)', line, re.I)
        if fm:
            if current:
                ranges.append((current[0], i - 1, current[1]))
            current = (i, 'FORM_' + fm.group(1).upper())
            continue
        if re.match(r'^\s*ENDFORM', line, re.I) and current:
            ranges.append((current[0], i, current[1]))
            current = None
    if current:
        ranges.append((current[0], len(lines), current[1]))
    return ranges


def _method_at(lineno: int, ranges: list) -> str:
    for start, end, name in ranges:
        if start <= lineno <= end:
            return name
    return 'UNKNOWN'


def extract_rules_regex(path: Path) -> list[dict]:
    text  = path.read_text(encoding='utf-8', errors='replace')
    lines = text.splitlines()
    obj_id = _detect_obj_id(text, path.stem)
    mranges = _parse_method_ranges(text)
    rules, seen = [], set()

    def push(lineno: int, tipo: str, cond: str):
        key = (lineno, cond[:60])
        if key in seen:
            return
        seen.add(key)
        metodo = _method_at(lineno, mranges)
        rules.append({
            'obj_id'       : obj_id,
            'metodo'       : metodo,
            'linea'        : lineno,
            'tipo'         : tipo,
            'condicion'    : cond.strip()[:300],
            'business_name': _humanize(cond, metodo),
            'reg'          : _detect_reg(cond),
            'riesgo'       : _detect_risk(cond),
            'fuente'       : 'REGEX',
        })

    for i, line in enumerate(lines, 1):
        if m := re.match(r'^\s+(?:ELSEIF|IF)\s+(.+?)\.?\s*$', line, re.I):
            cond = m.group(1).strip()
            tipo = 'FLUJO' if re.search(r'(IS\s+BOUND|cache|singleton)', cond, re.I) else 'VALIDACION'
            push(i, tipo, cond)
        elif m := re.match(r'^\s+CHECK\s+(.+?)\.?\s*$', line, re.I):
            push(i, 'VALIDACION', m.group(1).strip())
        elif m := re.match(r"^\s+AUTHORITY-CHECK\s+OBJECT\s+['\"]?(\w+)['\"]?", line, re.I):
            push(i, 'AUTORIZACION', f"AUTHORITY-CHECK OBJECT {m.group(1)}")
        elif m := re.match(r"^\s+MESSAGE\s+(\S+)(?:\s+(?:TYPE\s+)?['\"]([EAX])['\"])?", line, re.I):
            typ = (m.group(2) or 'E').upper()
            if typ in ('E', 'A', 'X') or 'ifrs' in m.group(1).lower() or 'msg' in m.group(1).lower():
                push(i, 'MANEJO_ERROR', f"MESSAGE {m.group(1)} TYPE '{typ}'")
        elif m := re.match(r'^\s+RAISE\s+EXCEPTION\s+TYPE\s+(\S+)', line, re.I):
            push(i, 'MANEJO_ERROR', f"RAISE EXCEPTION TYPE {m.group(1)}")
        elif m := re.match(r'^\s+CATCH\s+(.+?)\.?\s*$', line, re.I):
            exc = m.group(1).strip()
            if not re.search(r'\bINTO\b', exc, re.I):
                push(i, 'MANEJO_ERROR', f"CATCH {exc}")
        elif m := re.match(r'^\s{3,}WHERE\s+(.+?)\.?\s*$', line, re.I):
            cond = m.group(1).strip()
            if len(cond) > 3:
                push(i, 'FLUJO', f"WHERE {cond}")
        elif m := re.match(r'^\s+UPDATE\s+(\w+)\s+SET\s+(.+?)\.?\s*$', line, re.I):
            push(i, 'CALCULO', f"UPDATE {m.group(1)} SET {m.group(2).strip()}")

    return rules


# ── Extractor Gemini (v2, async) ──────────────────────────────────────────────

async def extract_rules_gemini(
    path: Path,
    model,
    semaphore: asyncio.Semaphore,
    token_counter: list,
    use_cache: bool = True,
) -> list[dict]:
    """Extrae reglas de un archivo .abap via Gemini con cache y reintentos."""
    from vertexai.generative_models import GenerationConfig  # noqa — import lazy

    text   = path.read_text(encoding='utf-8', errors='replace')
    fhash  = _file_hash(path)
    cfile  = CACHE_DIR / f"{fhash}.json"

    if use_cache and cfile.exists():
        cached = json.loads(cfile.read_text(encoding='utf-8'))
        token_counter[0] += cached.get('_tokens', 0)
        return cached.get('rules', [])

    obj_id   = _detect_obj_id(text, path.stem)
    obj_tipo = _detect_tipo_abap(path)
    chunks   = _chunk_by_method(text)
    all_rules: list[dict] = []

    for chunk_text, line_offset in chunks:
        prompt = PROMPT_TMPL.format(
            obj_id   = obj_id,
            obj_tipo = obj_tipo,
            code     = chunk_text[:28000],    # ~7K tokens safety margin
        )

        for attempt in range(3):
            async with semaphore:
                try:
                    response = await asyncio.to_thread(
                        model.generate_content,
                        prompt,
                        generation_config=GenerationConfig(
                            response_mime_type='application/json',
                            response_schema=RULE_SCHEMA,
                            temperature=0.1,
                            max_output_tokens=8192,
                        ),
                    )
                    raw  = json.loads(response.text)
                    toks = getattr(response.usage_metadata, 'total_token_count', 0) or 0
                    token_counter[0] += toks

                    rules_chunk = _validate_rules(raw, obj_id, 'GEMINI')
                    # Ajustar números de línea al offset del chunk
                    for r in rules_chunk:
                        r['linea'] += line_offset
                    all_rules.extend(rules_chunk)
                    break  # éxito

                except Exception as exc:
                    wait = 2 ** attempt
                    if attempt < 2:
                        await asyncio.sleep(wait)
                    else:
                        print(f"  WARN {path.name} · Gemini falló tras 3 intentos ({exc}) — regex fallback")
                        all_rules = extract_rules_regex(path)

    # Guardar en cache
    CACHE_DIR.mkdir(exist_ok=True)
    cfile.write_text(
        json.dumps({'rules': all_rules, '_tokens': token_counter[0]}, ensure_ascii=False),
        encoding='utf-8'
    )
    return all_rules


# ── Checkpoint ────────────────────────────────────────────────────────────────

def _load_checkpoint() -> set[str]:
    if CKPT_FILE.exists():
        data = json.loads(CKPT_FILE.read_text(encoding='utf-8'))
        return set(data.get('done', []))
    return set()


def _save_checkpoint(done: set[str]) -> None:
    CKPT_FILE.write_text(
        json.dumps({'done': sorted(done)}, ensure_ascii=False),
        encoding='utf-8'
    )


# ── Orquestador principal ─────────────────────────────────────────────────────

async def run_gemini(
    abap_files: list[Path],
    project: str,
    location: str,
    concurrency: int,
    use_cache: bool,
) -> list[dict]:
    try:
        import vertexai
        from vertexai.generative_models import GenerativeModel
    except ImportError:
        print("ERROR: google-cloud-aiplatform no instalado.")
        print("       pip install google-cloud-aiplatform")
        sys.exit(1)

    vertexai.init(project=project, location=location)
    model     = GenerativeModel(GEMINI_MODEL)
    semaphore = asyncio.Semaphore(concurrency)
    token_counter = [0]
    done_set  = _load_checkpoint() if use_cache else set()

    CACHE_DIR.mkdir(exist_ok=True)

    # Separar pendientes de ya procesados
    pending = [f for f in abap_files if str(f) not in done_set]
    print(f"  {len(abap_files)} archivos total · {len(pending)} pendientes · "
          f"{len(done_set)} en checkpoint\n")

    all_rules: list[dict] = []

    # Cargar resultados ya en cache para los que están en checkpoint
    for f in abap_files:
        if str(f) in done_set:
            fhash = _file_hash(f)
            cfile = CACHE_DIR / f"{fhash}.json"
            if cfile.exists():
                cached = json.loads(cfile.read_text(encoding='utf-8'))
                all_rules.extend(cached.get('rules', []))

    # Procesar pendientes en lotes
    BATCH = 50
    start_ts = time.monotonic()

    for batch_start in range(0, len(pending), BATCH):
        batch = pending[batch_start : batch_start + BATCH]
        tasks = [
            extract_rules_gemini(f, model, semaphore, token_counter, use_cache)
            for f in batch
        ]
        results = await asyncio.gather(*tasks, return_exceptions=True)

        for f, result in zip(batch, results):
            rel = f.relative_to(SOURCE)
            if isinstance(result, Exception):
                print(f"  ERR  {rel}  →  {result}")
            else:
                all_rules.extend(result)
                done_set.add(str(f))
                n = len(result)
                print(f"  OK   {rel:<50}  {n:>4} reglas")

        _save_checkpoint(done_set)

        # Log de progreso
        elapsed  = time.monotonic() - start_ts
        done_n   = batch_start + len(batch)
        rate     = done_n / elapsed if elapsed > 0 else 0
        eta_s    = (len(pending) - done_n) / rate if rate > 0 else 0
        est_usd  = token_counter[0] * 0.0000001  # ~$0.10 / 1M tokens flash
        print(f"  ── {done_n}/{len(pending)} · {token_counter[0]:,} tokens · "
              f"~${est_usd:.3f} USD · ETA {eta_s/60:.1f} min\n")

    return all_rules


def run_regex(abap_files: list[Path]) -> list[dict]:
    all_rules: list[dict] = []
    for path in abap_files:
        rel   = path.relative_to(SOURCE)
        rules = extract_rules_regex(path)
        all_rules.extend(rules)
        print(f"  {rel:<50}  {len(rules):>4} reglas")
    return all_rules


# ── Asignación de IDs globales ─────────────────────────────────────────────────

def _assign_ids(rules: list[dict]) -> None:
    for i, r in enumerate(rules, 1):
        r['id'] = f'GENREG-{i:04d}'


# ── CLI ───────────────────────────────────────────────────────────────────────

def _parse_args():
    ap = argparse.ArgumentParser(
        description='GENCore extract-rules v2.0 — Gemini + regex extractor',
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    ap.add_argument('--mode', choices=['gemini','regex','hybrid'], default='gemini',
                    help='Motor de extracción (default: gemini)')
    ap.add_argument('--project', default='',
                    help='GCP project ID (requerido para --mode gemini)')
    ap.add_argument('--location', default=GEMINI_LOCATION,
                    help=f'Región Vertex AI (default: {GEMINI_LOCATION})')
    ap.add_argument('--concurrency', type=int, default=20,
                    help='Llamadas paralelas a Gemini (default: 20)')
    ap.add_argument('--no-cache', action='store_true',
                    help='Forzar re-proceso ignorando cache')
    ap.add_argument('--no-checkpoint', action='store_true',
                    help='No usar ni guardar checkpoint de progreso')
    return ap.parse_args()


def main():
    args = _parse_args()

    abap_files = sorted(SOURCE.rglob('*.abap'))
    if not abap_files:
        print("WARN: No se encontraron archivos .abap en source/")
        print("      Carga los exports de SAP en source/CLASS/, source/PROG/, source/FUGR/")
        return

    use_cache = not args.no_cache
    mode      = args.mode

    # Detectar si hay credenciales GCP disponibles cuando se pide gemini
    if mode in ('gemini', 'hybrid'):
        try:
            import vertexai  # noqa
        except ImportError:
            if mode == 'gemini':
                print("ERROR: google-cloud-aiplatform no instalado. Usa --mode regex o instala:")
                print("       pip install google-cloud-aiplatform")
                sys.exit(1)
            print("WARN: google-cloud-aiplatform no disponible — usando modo regex como fallback")
            mode = 'regex'

        if not args.project and mode != 'regex':
            print("ERROR: --project requerido para modo gemini")
            print("       python extract-rules.py --mode gemini --project tu-proyecto-gcp")
            sys.exit(1)

    print(f"GENCore extract-rules v2.0")
    print(f"  Modo       : {mode.upper()}")
    print(f"  Archivos   : {len(abap_files)}")
    if mode != 'regex':
        print(f"  Modelo     : {GEMINI_MODEL}")
        print(f"  Proyecto   : {args.project}")
        print(f"  Región     : {args.location}")
        print(f"  Concurrencia: {args.concurrency} paralelas")
        print(f"  Cache      : {'OFF (--no-cache)' if not use_cache else 'ON (.rule-cache/)'}")
    print()

    t0 = time.monotonic()

    if mode == 'regex':
        all_rules = run_regex(abap_files)
    else:
        all_rules = asyncio.run(run_gemini(
            abap_files,
            project     = args.project,
            location    = args.location,
            concurrency = args.concurrency,
            use_cache   = use_cache,
        ))

    _assign_ids(all_rules)

    # Estadísticas
    by_tipo   = Counter(r['tipo']   for r in all_rules)
    by_riesgo = Counter(r['riesgo'] for r in all_rules)
    by_reg    = Counter(r['reg']    for r in all_rules if r['reg'])
    by_fuente = Counter(r['fuente'] for r in all_rules)

    output = {
        'meta': {
            'sistema'          : 'gentera-sap',
            'tecnologia'       : 'sap-abap',
            'total_reglas'     : len(all_rules),
            'archivos_fuente'  : len(abap_files),
            'modo_extraccion'  : mode,
            'modelo'           : GEMINI_MODEL if mode != 'regex' else 'regex',
            'by_tipo'          : dict(by_tipo),
            'by_riesgo'        : dict(by_riesgo),
            'by_reg'           : dict(by_reg),
            'by_fuente'        : dict(by_fuente),
            'fecha_extraccion' : time.strftime('%Y-%m-%d'),
            'version_extractor': '2.0.0',
        },
        'reglas': all_rules,
    }

    OUT.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding='utf-8')

    elapsed = time.monotonic() - t0
    print(f"\n{'─'*60}")
    print(f"OK  rules-gentera.json  →  {len(all_rules):,} reglas  ({elapsed:.1f}s)")
    print(f"    Tipo  : {dict(by_tipo)}")
    print(f"    Riesgo: {dict(by_riesgo)}")
    if by_reg:
        print(f"    Reg   : {dict(by_reg)}")
    if mode != 'regex':
        print(f"    Fuente: {dict(by_fuente)}")
    print(f"\nSiguiente paso: python digital-brain/build-brain.py")


if __name__ == '__main__':
    main()