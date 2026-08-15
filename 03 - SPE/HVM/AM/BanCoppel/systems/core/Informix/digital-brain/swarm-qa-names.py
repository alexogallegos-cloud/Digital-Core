"""
swarm-qa-names.py — QA de business_name: detecta falta de claridad y re-sintetiza.

Cubre TODAS las clases (NEGOCIO · INFRAESTRUCTURA · ENSAMBLAJE_REPORTE · PRESENTACION)
conforme a ADR-SPE-AM-010.

Casos detectados como "falta de claridad":
  1. Vacío / NULL
  2. Patrones genéricos que sobrevivieron a la limpieza:
       "Cálculo con umbral…", "Fórmula: …", "Validación: …", "Fórmula en …"
  3. Fragmentos SQL/SPL filtrados: "And …", "Or …", variables con _ _ _
  4. Demasiado corto (< 8 chars)
  5. Contiene token de código: num_, cSql, vsql, vres, arr_

Para cada SP con reglas incompletas, llama a Claude con el código fuente
y sintetiza nombres en términos de negocio BanCoppel.

Uso:
  python digital-brain/swarm-qa-names.py              # Todo
  python digital-brain/swarm-qa-names.py --pilot 20  # 20 SPs
  python digital-brain/swarm-qa-names.py --clase INFRAESTRUCTURA
  python digital-brain/swarm-qa-names.py --sp bdiofi:sp_pagos
  python digital-brain/swarm-qa-names.py --dry-run   # Solo imprime prompts

API key: ANTHROPIC_API_KEY env var, o ~/.claude/.credentials.json (OAuth Claude Code)

ADR-SPE-AM-010 · SPE-AM-001 · BanCoppel Application Modernization
"""

import sqlite3, json, os, re, sys, time, argparse
from datetime import datetime
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

DB = r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db"
MODEL   = "claude-sonnet-4-6"
BATCH   = 15          # reglas por llamada API
SWARM   = "swarm_qa_v1"
CONF    = 0.93

# ─── Filtro de claridad ───────────────────────────────────────────────────────
# Reglas cuyo business_name indica "falta de claridad":
CLARITY_SQL = """(
    business_name IS NULL
    OR business_name = ''
    OR business_name LIKE 'Cálculo con umbral%'
    OR business_name LIKE 'Calculo con umbral%'
    OR business_name LIKE 'Fórmula:%'
    OR business_name LIKE 'Formula:%'
    OR business_name LIKE 'Fórmula en %'
    OR business_name LIKE 'Validación:%'
    OR business_name LIKE 'Validacion:%'
    OR business_name LIKE 'And %'
    OR business_name LIKE 'Or %'
    OR business_name LIKE 'Regla de %'
    OR business_name LIKE 'Umbral en %'
    OR business_name LIKE 'Cálculo en %'
    OR (LENGTH(TRIM(business_name)) < 8 AND business_name IS NOT NULL AND business_name != '')
    OR business_name GLOB '*cSql*'
    OR business_name GLOB '*vsql*'
    OR business_name GLOB '*_*_*_*'
)"""

# ─── Auth ─────────────────────────────────────────────────────────────────────
def get_api_key():
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    if key: return key
    env_file = Path(__file__).parent / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if line.startswith("ANTHROPIC_API_KEY="):
                key = line.split("=", 1)[1].strip().strip('"\'')
                if key: return key
    cred_file = Path.home() / ".claude" / ".credentials.json"
    if cred_file.exists():
        try:
            data = json.loads(cred_file.read_text())
            token = data.get("claudeAiOauth", {}).get("accessToken", "")
            if token: return token
        except Exception:
            pass
    return None

# ─── System prompt ────────────────────────────────────────────────────────────
SYSTEM = """Eres experto en el core bancario BanCoppel, construido sobre IBM Informix IDS 14.10 / AIX-POWER.
Dominas SPL (Stored Procedure Language Informix) y el dominio bancario mexicano: créditos, ahorro, SPEI, TPV, cobranza, dispersión nómina, PLD, tesorería.

Tu tarea: dado un SP y sus reglas, genera un business_name para cada una que capture el SIGNIFICADO DE NEGOCIO.
Sintetiza desde código + contexto + dominio. NUNCA copies comentarios ni código SPL literal.

FORMATOS POR TIPO:
  FÓRMULA/CÁLCULO   → "Cálculo de [concepto]: [descripción resultado]"
  VALIDACIÓN         → "Valida que [condición de negocio — propósito, no la condición técnica]"
  UMBRAL             → "[Concepto]: [rango/límite] — consecuencia si aplica"
  CÓDIGO_RETORNO     → "[Operación SP en términos biz]: [resultado/razón biz]"
  EXCEPCIÓN          → "Excepción cuando [condición biz que causó el error]"
  ESTADO/LÓGICA      → "[Decisión de negocio] cuando [condición biz]"
  INFRAESTRUCTURA    → "[Qué operación del sistema ejecuta]: [sobre qué recurso/archivo/BD]"
  ENSAMBLAJE_REPORTE → "[Qué consulta/reporte construye]: [criterios clave]"
  PRESENTACIÓN       → "[Qué dato formatea/prepara]: [para qué salida]"

REGLAS:
  - Máximo 120 caracteres
  - En español, terminología bancaria MX correcta
  - Para INFRAESTRUCTURA: el nombre puede ser técnico pero debe indicar el PROPÓSITO (no solo "echo" o "dbaccess")
  - Si la regla es ambigua, infiere del contexto del SP
  - Responde EXACTAMENTE: [RULE_ID]: business_name_sintetizado
  - Una línea por regla, sin explicaciones"""

# ─── Prompt de usuario ────────────────────────────────────────────────────────
def build_prompt(sp_id, sp_biz, domain, rules, codret_dict):
    lines = [
        f"SP: {sp_id}",
        f"Operación: {sp_biz or '(sin descripción)'}",
        f"Dominio: {domain or '(desconocido)'}",
        "",
        "Reglas a sintetizar:",
        "─" * 50,
    ]
    for rid, tipo, sub_tipo, clase, code, bn_actual in rules:
        clase_tag = f"/{clase}" if clase and clase != "NEGOCIO" else ""
        lines.append(f"[{rid}] {tipo}/{sub_tipo or '—'}{clase_tag}")
        if bn_actual:
            lines.append(f"  Nombre actual (INSUFICIENTE): {bn_actual}")
        if code:
            lines.append(f"  Código SPL: {code.strip()[:280]}")
        if sub_tipo == 'CÓDIGO_RETORNO' and code:
            m = re.search(r"""(?:LET|let)\s+\w*codret\w*\s*=\s*['"](\d+)['"]""", code, re.I)
            if m:
                desc = codret_dict.get(m.group(1).strip(), "")
                if desc:
                    lines.append(f"  (Ref código {m.group(1)}: \"{desc}\" — usa como contexto, no copies)")
        lines.append("")
    lines.append("─" * 50)
    lines.append("Responde una línea por regla: [RULE_ID]: business_name sintetizado")
    return "\n".join(lines)

# ─── Parse respuesta ──────────────────────────────────────────────────────────
_RULE_RE = re.compile(r'^\[?(BR-[A-Z0-9]+-\d+|BR-V2-\d+)\]?\s*:\s*(.+)$', re.I)

def parse_response(text, expected):
    out = {}
    for line in text.splitlines():
        m = _RULE_RE.match(line.strip())
        if m:
            rid, name = m.group(1).strip(), m.group(2).strip()
            name = re.sub(r'\*{1,2}', '', name).strip()
            if rid in expected and name:
                out[rid] = name[:120]
    return out

# ─── Llamada API ──────────────────────────────────────────────────────────────
def call_claude(client, prompt, sp_id, dry_run):
    if dry_run:
        print(f"\n{'='*60}")
        print(f"[DRY-RUN] SP: {sp_id}")
        print(prompt[:600])
        print("...")
        return None
    try:
        msg = client.messages.create(
            model=MODEL, max_tokens=2048,
            system=SYSTEM,
            messages=[{"role": "user", "content": prompt}]
        )
        return msg.content[0].text
    except Exception as e:
        print(f"  ERROR API {sp_id}: {e}")
        time.sleep(3)
        return None

# ─── Escritura DB ─────────────────────────────────────────────────────────────
def write_results(cur, results, rules_index, now):
    updates, logs = [], []
    for rid, new_bn in results.items():
        old_bn = rules_index.get(rid, {}).get("bn", "")
        if new_bn == old_bn:
            continue
        updates.append((new_bn, rid))
        logs.append((
            rid, SWARM, "business_name", old_bn, new_bn, now,
            CONF, "llm_synthesis",
            f"QA síntesis {MODEL} — falta de claridad detectada automáticamente"
        ))
    if updates:
        cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
        cur.executemany("""
            INSERT INTO rule_enrichment_log
              (rule_id, swarm, field, old_value, new_value, timestamp, confidence, method, notes)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, logs)
    return len(updates)

# ─── Main ─────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser(description="QA de business_name — síntesis LLM")
    parser.add_argument("--pilot", type=int, metavar="N",
                        help="Solo los primeros N stored procedures")
    parser.add_argument("--sp", help="SP específico (ej: bdicobranza:sp_envio_camp)")
    parser.add_argument("--db", help="Solo una BD (ej: bdicobranza)")
    parser.add_argument("--clase", help="Solo una clase: NEGOCIO | INFRAESTRUCTURA | ENSAMBLAJE_REPORTE | PRESENTACION")
    parser.add_argument("--dry-run", action="store_true",
                        help="Imprime prompts sin llamar al API")
    parser.add_argument("--force", action="store_true",
                        help="Re-sintetiza TODOS (incluso con business_name ya claro)")
    args = parser.parse_args()

    api_key = get_api_key()
    if not api_key and not args.dry_run:
        print("ERROR: No se encontró ANTHROPIC_API_KEY.")
        sys.exit(1)

    client = None
    if not args.dry_run:
        import anthropic
        client = anthropic.Anthropic(api_key=api_key)
        print(f"Anthropic SDK conectado — modelo: {MODEL}")

    con = sqlite3.connect(DB)
    cur = con.cursor()
    NOW = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    cur.execute("SELECT code, description_es FROM codret_dictionary WHERE description_es IS NOT NULL")
    CODRET = {str(r[0]).strip(): r[1] for r in cur.fetchall()}

    # Construir WHERE
    where_parts = []
    if not args.force:
        where_parts.append(CLARITY_SQL)
    if args.sp:
        where_parts.append(f"r.sp = '{args.sp}'")
    if args.db:
        where_parts.append(f"r.sp LIKE '{args.db}:%'")
    if args.clase:
        where_parts.append(f"r.clase = '{args.clase}'")
    where_sql = " AND ".join(where_parts) if where_parts else "1=1"

    cur.execute(f"""
        SELECT r.id, r.sp, r.tipo, r.sub_tipo, r.clase, r.code, r.business_name,
               s.biz, s.domain
        FROM rules r
        LEFT JOIN sps s ON s.id = r.sp
        WHERE {where_sql}
        ORDER BY r.sp, r.id
    """)
    all_rules = cur.fetchall()

    # Agrupar por SP
    sp_groups: dict[str, list] = {}
    sp_meta: dict[str, tuple] = {}
    rules_index: dict[str, dict] = {}

    for rid, sp, tipo, sub_tipo, clase, code, bn, sp_biz, domain in all_rules:
        sp_groups.setdefault(sp, []).append((rid, tipo, sub_tipo, clase, code, bn))
        sp_meta[sp] = (sp_biz or "", domain or "")
        rules_index[rid] = {"bn": bn or ""}

    sp_list = list(sp_groups.keys())
    if args.pilot:
        sp_list = sp_list[: args.pilot]

    total_rules = sum(len(sp_groups[sp]) for sp in sp_list)
    print(f"SPs con reglas a revisar: {len(sp_list)}")
    print(f"Reglas con falta de claridad: {total_rules}")
    if args.dry_run:
        print("[DRY-RUN] Sin llamadas al API\n")

    total_updated = 0
    total_calls   = 0
    total_failed  = 0

    for i, sp_id in enumerate(sp_list, 1):
        rules = sp_groups[sp_id]
        sp_biz, domain = sp_meta[sp_id]

        # Dividir en batches de BATCH reglas
        for batch_start in range(0, len(rules), BATCH):
            batch = rules[batch_start: batch_start + BATCH]
            expected = {r[0] for r in batch}

            prompt = build_prompt(sp_id, sp_biz, domain, batch, CODRET)
            raw = call_claude(client, prompt, sp_id, args.dry_run)

            if raw is None:
                if not args.dry_run:
                    total_failed += 1
                continue

            total_calls += 1
            parsed = parse_response(raw, expected)
            missed = expected - set(parsed.keys())

            n = write_results(cur, parsed, rules_index, NOW)
            total_updated += n
            con.commit()

            print(f"[{i}/{len(sp_list)}] {sp_id} — batch {batch_start//BATCH+1}: "
                  f"{n} actualizados, {len(missed)} sin respuesta")
            if missed and len(missed) <= 5:
                print(f"  Sin respuesta: {missed}")

            # Rate-limit suave
            if not args.dry_run and total_calls % 10 == 0:
                time.sleep(1)

    print(f"\n{'='*50}")
    print(f"SPs procesados     : {len(sp_list)}")
    print(f"Llamadas API       : {total_calls}")
    print(f"Errores API        : {total_failed}")
    print(f"business_name act. : {total_updated}")
    print(f"Swarm ID           : {SWARM}")
    con.close()


if __name__ == "__main__":
    main()
