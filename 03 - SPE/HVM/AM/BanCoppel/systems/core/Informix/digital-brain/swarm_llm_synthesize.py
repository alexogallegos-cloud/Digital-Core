"""
swarm_llm_synthesize.py — Síntesis LLM de business names para reglas de negocio.

Enfoque: entendimiento profundo del código SPL + contexto del SP + dominio BanCoppel
→ derivar business_name desde cero, en términos de negocio, sin copiar comentarios.

Uso:
  python swarm_llm_synthesize.py                  # Procesa todo (puede tomar horas)
  python swarm_llm_synthesize.py --pilot 30       # Piloto: 30 SPs
  python swarm_llm_synthesize.py --sp bdiofi:sp_x # SP específico
  python swarm_llm_synthesize.py --db bdiofi       # Solo una base de datos
  python swarm_llm_synthesize.py --tipo UMBRAL     # Solo un tipo de regla

API key: ANTHROPIC_API_KEY env var, o ~/.claude/.credentials.json (OAuth Claude Code)
"""

import sqlite3, json, os, re, sys, time, argparse
from datetime import datetime
from pathlib import Path

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ─── Config ───────────────────────────────────────────────────────────────────
DB = r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db"
MODEL = "claude-sonnet-4-6"
MAX_RULES_PER_CALL = 18        # máx reglas por llamada API
SWARM_ID = "swarm_llm_v1"
CONFIDENCE = 0.96

# ─── Autenticación ────────────────────────────────────────────────────────────
def get_api_key():
    """Lee API key: env var > .env > Claude Code OAuth credentials."""
    # 1. Variable de entorno
    key = os.environ.get("ANTHROPIC_API_KEY", "")
    if key: return key
    # 2. Archivo .env en el directorio del script
    env_file = Path(__file__).parent / ".env"
    if env_file.exists():
        for line in env_file.read_text().splitlines():
            if line.startswith("ANTHROPIC_API_KEY="):
                key = line.split("=", 1)[1].strip().strip('"\'')
                if key: return key
    # 3. Claude Code OAuth token (fallback)
    cred_file = Path.home() / ".claude" / ".credentials.json"
    if cred_file.exists():
        try:
            data = json.loads(cred_file.read_text())
            token = data.get("claudeAiOauth", {}).get("accessToken", "")
            if token: return token
        except Exception:
            pass
    return None

# ─── Prompt ───────────────────────────────────────────────────────────────────
SYSTEM_PROMPT = """Eres un experto en el sistema core bancario de BanCoppel, construido sobre IBM Informix IDS 14.10 en AIX/POWER. Entiendes SPL (Stored Procedure Language de Informix) con profundidad y conoces el dominio bancario mexicano: créditos, cuentas de ahorro, cheques, dispersión de nómina, SPEI, TPV, autorizaciones, PLD, cobranza.

Tu tarea: dado un stored procedure y sus reglas extraídas, escribe un `business_name` para cada regla que capture el SIGNIFICADO DE NEGOCIO — sintetizado desde la comprensión del código, contexto y dominio.

REGLA FUNDAMENTAL: Nunca copies ni parafrasees comentarios o código SPL. Sintetiza desde el entendimiento.

FORMATOS CANÓNICOS (obligatorios según tipo):
- VALIDACIÓN_CAMPO: "Valida que [qué condición de negocio se verifica — propósito, no la condición técnica]"
- CÓDIGO_RETORNO:   "[Operación del SP en términos de negocio]: [resultado o razón de negocio]"
- UMBRAL:           "[Concepto de negocio]: [rango/límite] — fuera de rango: [consecuencia]" (si hay consecuencia clara)
- EXCEPCIÓN:        "Excepción cuando [condición de negocio que causó el error — no el código de error]"
- LOGICA:           "[Decisión o camino de negocio] cuando [condición de negocio]"
- FÓRMULA:          "Cálculo de [concepto]: [variables en español] → [resultado]"
- PROCESO:          "[Qué paso del proceso de negocio ocurre]"

EJEMPLOS — MALO vs BUENO:
❌ "Valida que ejecutivo no fue proporcionado o fecha no fue proporcionado"
✅ "Valida que la solicitud tenga ejecutivo y fecha de operación antes de proceder"

❌ "ccodret='110': parámetro de entrada no recibido en la llamada"
✅ "Dispersión de nómina BPI: fecha de proceso requerida para ejecutar el lote"

❌ "Umbral de: Arrpagoint 18082010"
✅ "Arreglo de pago con interés: saldo promedio entre $200 y $5,000 — aplica tasa nivel 1"

❌ "Bifurcación en Cierre cheque inversión: vdiasinact >= 1060"
✅ "Cuenta inactiva 3 años o más: activa cierre automático de cheque de inversión"

❌ "Excepción cuando ccodret <> 0"
✅ "Excepción cuando el servicio externo de autorización no responde"

INSTRUCCIONES:
- Máximo 120 caracteres por business_name
- En español, terminología bancaria correcta
- Si una regla es técnicamente ambigua, usa el contexto del SP para inferir el propósito
- Responde EXACTAMENTE en el formato: [RULE_ID]: business_name
- Un rule_id por línea, sin explicaciones adicionales"""

def build_user_prompt(sp_id, biz, rules, codret_dict):
    """Construye el prompt del usuario para un grupo de reglas de un SP."""
    lines = []
    db_name = sp_id.split(':')[0] if ':' in sp_id else ''
    sp_name = sp_id.split(':')[-1]

    lines.append(f"SP: {sp_id}")
    if biz and biz.strip():
        biz_clean = re.sub(r'[ã\x81\x93\x8d\x9a]', '', biz)  # limpia encoding corrupto para contexto
        lines.append(f"Operación: {biz_clean}")
    lines.append(f"Base de datos: {db_name}")
    lines.append("")
    lines.append("Reglas a sintetizar:")
    lines.append("─" * 60)

    for rule in rules:
        rid, tipo, sub_tipo, code, bn_actual = rule
        lines.append(f"[{rid}] {tipo}/{sub_tipo}")

        if code:
            code_clean = code.strip()[:300]
            lines.append(f"Código SPL: {code_clean}")

        if tipo == 'UMBRAL' and code:
            lines.append("(Este es un umbral/límite — describe qué concepto de negocio limita y la consecuencia)")

        if sub_tipo == 'CÓDIGO_RETORNO' and code:
            # Extraer código de retorno y buscar en diccionario
            m = re.search(r"""(?:LET|let)\s+\w*codret\w*\s*=\s*['"](\d+)['"]""", code, re.I)
            if m:
                code_val = m.group(1)
                dict_desc = codret_dict.get(code_val, '')
                if dict_desc:
                    lines.append(f"(Referencia: código {code_val} = \"{dict_desc}\" — usa como contexto, NO copies)")

        lines.append("")

    lines.append("─" * 60)
    lines.append("Responde una línea por regla: [RULE_ID]: business_name sintetizado")
    return '\n'.join(lines)

# ─── Parseo de respuesta ──────────────────────────────────────────────────────
RULE_ID_RE = re.compile(r'^\[?(BR-V2-\d+)\]?\s*:\s*(.+)$', re.I)

def parse_response(text, expected_ids):
    """Extrae {rule_id: business_name} del texto de respuesta."""
    results = {}
    for line in text.splitlines():
        line = line.strip()
        m = RULE_ID_RE.match(line)
        if m:
            rule_id = m.group(1).strip()
            name = m.group(2).strip()
            # Limpiar cualquier asterisco o markdown
            name = re.sub(r'\*{1,2}', '', name).strip()
            if rule_id in expected_ids and name:
                results[rule_id] = name
    return results

# ─── Llamada al API ──────────────────────────────────────────────────────────
def call_claude(client, user_prompt, sp_id):
    """Llama al API de Claude y retorna el texto de respuesta."""
    try:
        msg = client.messages.create(
            model=MODEL,
            max_tokens=2048,
            system=SYSTEM_PROMPT,
            messages=[{"role": "user", "content": user_prompt}]
        )
        return msg.content[0].text
    except Exception as e:
        print(f"  ⚠ Error en API para {sp_id}: {e}")
        return None

# ─── Escritura en DB ─────────────────────────────────────────────────────────
def write_results(cur, results_map, rules_map, now):
    """Graba los business_names sintetizados en brain.db."""
    updates = []
    log_rows = []
    for rule_id, new_bn in results_map.items():
        old_bn = rules_map.get(rule_id, {}).get('bn', '')
        if new_bn == old_bn: continue
        updates.append((new_bn, rule_id))
        log_rows.append((
            rule_id, SWARM_ID, 'business_name', old_bn, new_bn, now,
            CONFIDENCE, 'llm_synthesis',
            f'Síntesis LLM {MODEL}: entendimiento profundo SP+código+dominio'
        ))
    if updates:
        cur.executemany("UPDATE rules SET business_name=? WHERE id=?", updates)
        cur.executemany("""
            INSERT INTO rule_enrichment_log
              (rule_id, swarm, field, old_value, new_value, timestamp, confidence, method, notes)
            VALUES (?,?,?,?,?,?,?,?,?)
        """, log_rows)
    return len(updates)

# ─── Main ─────────────────────────────────────────────────────────────────────
def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--pilot', type=int, metavar='N',
                        help='Procesar solo los primeros N stored procedures')
    parser.add_argument('--sp', help='SP específico (ej: bdiofi:sp_pagos)')
    parser.add_argument('--db', help='Solo una base de datos (ej: bdiofi)')
    parser.add_argument('--tipo', help='Solo un tipo (ej: UMBRAL, CÓDIGO_RETORNO)')
    parser.add_argument('--dry-run', action='store_true',
                        help='Mostrar prompts sin llamar al API')
    args = parser.parse_args()

    # Autenticación
    api_key = get_api_key()
    if not api_key:
        print("ERROR: No se encontró API key.")
        print("  Solución: set ANTHROPIC_API_KEY=sk-ant-...")
        sys.exit(1)

    import anthropic
    client = anthropic.Anthropic(api_key=api_key)
    print(f"✓ Anthropic SDK {anthropic.__version__} conectado")

    con = sqlite3.connect(DB)
    cur = con.cursor()
    NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    # Cargar codret_dictionary
    cur.execute("SELECT code, description_es FROM codret_dictionary WHERE description_es IS NOT NULL")
    CODRET = {str(r[0]).strip(): r[1] for r in cur.fetchall()}

    # Query de reglas
    where_parts = ["r.clase = 'NEGOCIO'"]
    if args.sp:
        where_parts.append(f"r.sp = '{args.sp}'")
    if args.db:
        where_parts.append(f"r.sp LIKE '{args.db}:%'")
    if args.tipo:
        where_parts.append(f"r.tipo = '{args.tipo}'")
    where_sql = ' AND '.join(where_parts)

    cur.execute(f"""
        SELECT r.id, r.sp, r.tipo, r.sub_tipo, r.code, r.business_name, s.biz
        FROM rules r
        LEFT JOIN sps s ON s.id = r.sp
        WHERE {where_sql}
        ORDER BY r.sp, r.id
    """)
    all_rules = cur.fetchall()
    print(f"Reglas NEGOCIO: {len(all_rules)}")

    # Agrupar por SP
    from itertools import groupby
    from operator import itemgetter

    sp_groups = {}
    for row in all_rules:
        rid, sp, tipo, sub_tipo, code, bn, biz = row
        if sp not in sp_groups:
            sp_groups[sp] = {'biz': biz, 'rules': []}
        sp_groups[sp]['rules'].append((rid, tipo, sub_tipo, code, bn))

    sp_list = list(sp_groups.items())
    if args.pilot:
        sp_list = sp_list[:args.pilot]
        print(f"Modo piloto: {len(sp_list)} SPs")

    total_sps = len(sp_list)
    total_updated = 0
    total_called = 0

    print(f"\nProcesando {total_sps} SPs...")
    print("─" * 60)

    for sp_idx, (sp_id, sp_data) in enumerate(sp_list):
        biz = sp_data['biz'] or ''
        rules = sp_data['rules']

        print(f"\n[{sp_idx+1}/{total_sps}] {sp_id} ({len(rules)} reglas)")
        print(f"  Biz: {biz[:60]}" if biz else "  Biz: (sin descripción)")

        # Dividir en lotes si hay muchas reglas
        batches = []
        for i in range(0, len(rules), MAX_RULES_PER_CALL):
            batches.append(rules[i:i + MAX_RULES_PER_CALL])

        rules_map = {r[0]: {'bn': r[4]} for r in rules}
        sp_results = {}

        for batch_idx, batch in enumerate(batches):
            if len(batches) > 1:
                print(f"  Lote {batch_idx+1}/{len(batches)} ({len(batch)} reglas)")

            user_prompt = build_user_prompt(sp_id, biz, batch, CODRET)
            expected_ids = {r[0] for r in batch}

            if args.dry_run:
                print("\n  --- PROMPT PREVIEW ---")
                print(user_prompt[:600])
                print("  --- (dry-run, no API call) ---")
                continue

            response_text = call_claude(client, user_prompt, sp_id)
            total_called += 1

            if not response_text:
                print(f"  ⚠ Sin respuesta para lote {batch_idx+1}")
                continue

            parsed = parse_response(response_text, expected_ids)
            missing = expected_ids - set(parsed.keys())
            if missing:
                print(f"  ⚠ Sin síntesis para {len(missing)} reglas: {list(missing)[:3]}")

            sp_results.update(parsed)

            # Mostrar muestra
            for rid, new_bn in list(parsed.items())[:3]:
                old_bn = rules_map.get(rid, {}).get('bn', '')
                print(f"    {rid}: {new_bn[:80]}")

            # Pausa corta para no saturar el API
            if total_called > 1:
                time.sleep(0.5)

        if not args.dry_run and sp_results:
            n = write_results(cur, sp_results, rules_map, NOW)
            con.commit()
            total_updated += n
            print(f"  ✓ {n}/{len(rules)} reglas actualizadas")

    print(f"\n{'='*60}")
    print(f"Síntesis LLM completada:")
    print(f"  SPs procesados:    {total_sps}")
    print(f"  Llamadas API:      {total_called}")
    print(f"  Reglas generadas:  {total_updated}")

    if not args.dry_run:
        try:
            cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
        except Exception:
            pass
        con.commit()

    con.close()

if __name__ == '__main__':
    main()
