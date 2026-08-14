"""
fix_brb_quality.py — Corrige IDs y business names de reglas BRB-* en dos pasadas.

Pasada 1 — IDs:
  Nuevo esquema: BRB-{db_abbr}-{seq:05d}
  db_abbr = mapa de abreviaciones controlado (máx 7 chars, legible)
  seq     = secuencial por db, ordenado por sp + line

Pasada 2 — Business names:
  Para reglas cuyo nombre contiene el nombre crudo del SP (sin biz en sps),
  parsea el nombre del SP usando segmentación de palabras bancarias en español
  y reemplaza el sujeto por algo legible.
"""
import sqlite3, re
from pathlib import Path
from datetime import datetime
from collections import defaultdict
import sys
sys.stdout.reconfigure(encoding="utf-8", errors="replace")

DB  = Path(r"C:\Users\alejandro.gallegos\OneDrive - Accenture\Documents\Digital Core\03 - SPE\HVM\AM\BanCoppel\systems\core\Informix\digital-brain\brain.db")
con = sqlite3.connect(str(DB))
cur = con.cursor()
NOW = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN A — Mapa de abreviaciones de DB
# ─────────────────────────────────────────────────────────────────────────────
DB_ABBR = {
    'bdiaclaracion':  'bdacl',
    'bdiadminnomina': 'bdnom',
    'bdiauditor':     'bdaud',
    'bdibei':         'bdbei',
    'bdibi':          'bdbi',
    'bdibpi':         'bdbpi',
    'bdiburo':        'bdbur',
    'bdicat':         'bdcat',
    'bdicheq':        'bdchq',
    'bdicntchq':      'bdcch',
    'bdicnweb':       'bdcnw',
    'bdicobranza':    'bdcob',
    'bdicont':        'bdcnt',
    'bdicorresp':     'bdcor',
    'bdicred':        'bdcre',
    'bdidigital':     'bddgt',
    'bdidomi':        'bddom',
    'bdiedoelec':     'bdedo',
    'bdigaran':       'bdgar',
    'bdilide':        'bdlid',
    'bdimnsj':        'bdmsj',
    'bdimonitorcob':  'bdmcb',
    'bdinteg':        'bdntg',
    'bdinvers':       'bdinv',
    'bdiofi':         'bdofi',
    'bdiprem':        'bdprm',
    'bdiprog':        'bdprg',
    'bdiprospectos':  'bdprs',
    'bdirech':        'bdrch',
    'bdirepaut':      'bdrpa',
    'bdireports':     'bdrpt',
    'bdiresp':        'bdrsp',
    'bdiriesgos':     'bdrie',
    'bdirst':         'bdrst',
    'bdisac':         'bdisac',
    'bdisitesp':      'bdste',
    'bdisolic':       'bdsol',
    'bdispei':        'bdspei',
    'bdisuc':         'bdsuc',
    'bditarjcop':     'bdtjc',
    'bditarjeta':     'bdtjt',
    'bditef':         'bdtef',
    'bditrans':       'bdtrs',
    'bditransfer':    'bdtrf',
    'bditrapres':     'bdtpr',
    'bdivr':          'bdvr',
    'bdmis':          'bdmis',
    'intercard':      'icrd',
    'intercardbpi':   'icrdbpi',
}

def db_abbr(db_name):
    return DB_ABBR.get((db_name or '').lower(), (db_name or 'unk')[:7])

# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN B — Segmentador de nombres de SP para cuando biz está vacío
# ─────────────────────────────────────────────────────────────────────────────
# Palabras bancarias españolas ordenadas por longitud desc (greedy)
SP_WORDS = sorted([
    ('inscripcion','inscripción'), ('calificacion','calificación'),
    ('autorizacion','autorización'), ('transaccion','transacción'),
    ('operacion','operación'), ('contrato','contrato'),
    ('solicitud','solicitud'), ('producto','producto'),
    ('reporte','reporte'), ('proceso','proceso'),
    ('empresa','empresa'), ('usuario','usuario'),
    ('sucursal','sucursal'), ('empleado','empleado'),
    ('tarjeta','tarjeta'), ('digital','canal digital'),
    ('apertura','apertura'), ('cierre','cierre'),
    ('vigencia','vigencia'), ('etapa','etapa'),
    ('estado','estado'), ('cuenta','cuenta'),
    ('credito','crédito'), ('cliente','cliente'),
    ('numero','número'), ('nombre','nombre'),
    ('monto','monto'), ('saldo','saldo'),
    ('fecha','fecha'), ('banco','banco'),
    ('pago','pago'), ('cargo','cargo'),
    ('envio','envío'), ('firma','firma'),
    ('carga','carga'), ('datos','datos'),
    ('folio','folio'), ('clave','clave'),
    ('tipo','tipo'), ('dato','dato'),
    ('baja','baja'), ('alta','alta'),
    ('spei','SPEI'), ('codi','CoDi'),
    ('rech','rechazo'), ('aut','autorización'),
    ('ofi','oficina'), ('rec','récord'),
    ('rpt','reporte'), ('cnt','contrato'),
    ('cte','cliente'), ('num','número'),
    ('cta','cuenta'),
], key=lambda x: len(x[0]), reverse=True)

VERB_MAP = {
    'actualiza':  'Actualización',
    'consulta':   'Consulta',
    'inserta':    'Inserción',
    'obtiene':    'Obtención',
    'borra':      'Eliminación',
    'elimina':    'Eliminación',
    'valida':     'Validación',
    'genera':     'Generación',
    'calcula':    'Cálculo',
    'procesa':    'Procesamiento',
    'carga':      'Carga',
    'registra':   'Registro',
    'cancela':    'Cancelación',
    'modifica':   'Modificación',
    'consultar':  'Consulta',
    'actualizar': 'Actualización',
}

SP_PREFIXES = re.compile(r'^(sp_|dg|bc|mi|wl|bd|fn|rpt|pr|sr)+', re.I)

def parse_sp_name(sp_raw):
    """Convierte un nombre crudo de SP a descripción de negocio legible."""
    sp = re.sub(r'^sp_', '', (sp_raw or '').split(':')[-1]).lower()
    # Eliminar prefijos no semánticos
    sp_clean = SP_PREFIXES.sub('', sp)
    # Si tiene underscores, separar por ellos primero
    if '_' in sp_clean:
        parts = sp_clean.split('_')
    else:
        parts = [sp_clean]

    # Para cada parte, intentar segmentar por palabras conocidas
    all_tokens = []
    for part in parts:
        rest = part
        tokens = []
        while rest:
            matched = False
            for word, label in SP_WORDS:
                if rest.startswith(word):
                    tokens.append(label)
                    rest = rest[len(word):]
                    matched = True
                    break
            if not matched:
                # Avanzar un char (letra no reconocida)
                rest = rest[1:]
        if tokens:
            all_tokens.extend(tokens)

    if not all_tokens:
        # fallback: usar la primera parte del SP name limpio
        return re.sub(r'^(sp_|dg|bc)', '', sp_raw.split(':')[-1])[:40].replace('_', ' ')

    # Detectar verbo al inicio
    verb = None
    nouns = []
    for i, tok in enumerate(all_tokens):
        if tok in VERB_MAP.values() or tok.lower() in VERB_MAP:
            if verb is None:
                verb = tok
        else:
            nouns.append(tok)

    # Deduplicar nouns
    seen = set()
    nouns_dedup = []
    for n in nouns:
        if n not in seen:
            seen.add(n)
            nouns_dedup.append(n)

    if verb and nouns_dedup:
        return f"{verb} de {' de '.join(nouns_dedup[:3])}"
    elif nouns_dedup:
        return ' de '.join(nouns_dedup[:3])
    elif verb:
        return verb
    return sp_clean[:40]

# ─────────────────────────────────────────────────────────────────────────────
# PASADA 1 — Nuevos IDs: BRB-{seq:05d}  (global sequential, mismo patrón que BR-V2-*)
# ─────────────────────────────────────────────────────────────────────────────
cur.execute("""
    SELECT rowid, id, db, sp, line
    FROM rules WHERE id LIKE 'BRB-%'
    ORDER BY db, sp, line
""")
brb_rows = cur.fetchall()
print(f"BRB-* a reasignar: {len(brb_rows)}")

id_updates  = []
log_id      = []

cur.execute("SELECT id FROM rules WHERE id IS NOT NULL AND id NOT LIKE 'BRB-%'")
reserved = {r[0] for r in cur.fetchall()}
seen_ids = set(reserved)

seq = 0
for rowid, old_id, db, sp, line in brb_rows:
    seq += 1
    new_id = f"BRB-{seq:05d}"
    while new_id in seen_ids:
        seq += 1
        new_id = f"BRB-{seq:05d}"
    seen_ids.add(new_id)
    id_updates.append((new_id, rowid))
    log_id.append((new_id, 'fix_brb_quality', 'id', old_id, new_id, NOW, 1.0, 'sequential_global', ''))

# Preview IDs
print("\nPREVIEW IDs (10):")
for new_id, rowid in id_updates[:10]:
    old = next(r[1] for r in brb_rows if r[0] == rowid)
    print(f"  {old:40s} → {new_id}")

# Aplicar IDs
cur.execute("UPDATE rules SET id=NULL WHERE id LIKE 'BRB-%'")
cur.executemany("UPDATE rules SET id=? WHERE rowid=?", id_updates)
print(f"\n✓ IDs actualizados: {len(id_updates)}")

# ─────────────────────────────────────────────────────────────────────────────
# PASADA 2 — Business names: reemplazar sujeto que es nombre crudo de SP
# ─────────────────────────────────────────────────────────────────────────────
# Reconstruir el mapa rowid → new_id para los logs de nombres
rowid_to_newid = {rowid: new_id for new_id, rowid in id_updates}

# Cargar reglas BRB con biz vacío (el problema está ahí)
cur.execute("""
    SELECT r.rowid, r.business_name, r.sp, s.biz
    FROM rules r
    LEFT JOIN sps s ON s.id = r.sp
    WHERE r.id LIKE 'BRB-%'
      AND (s.biz IS NULL OR s.biz = '')
    ORDER BY r.sp, r.line
""")
no_biz_rows = cur.fetchall()
print(f"\nBRB sin biz en sps: {len(no_biz_rows)}")

# Detectar nombres que contienen fragmento de SP crudo
# El síntoma: el subject del nombre contiene caracteres de SP (letras sin espacio > 12 chars)
SP_LEAK_PAT = re.compile(r'\b([a-z]{13,})\b')  # palabra concatenada larga

bn_updates  = []
log_bn      = []

for rowid, bn, sp, biz in no_biz_rows:
    if not bn:
        continue
    # ¿Hay un token largo (>12 chars) sin espacios que luzca como nombre de SP?
    if not SP_LEAK_PAT.search(bn or ''):
        continue
    new_subject = parse_sp_name(sp)
    if not new_subject:
        continue
    # Reconstruir el nombre reemplazando el subject (la parte antes del primer ':')
    if ':' in bn:
        _, rest = bn.split(':', 1)
        new_bn = f"{new_subject}: {rest.strip()}"
    else:
        new_bn = bn  # no hay ':' — no tocar

    new_bn = re.sub(r'\s+', ' ', new_bn).strip()[:220]
    if new_bn != bn:
        new_id = rowid_to_newid.get(rowid, '')
        bn_updates.append((new_bn, rowid))
        log_bn.append((new_id, 'fix_brb_quality', 'business_name', bn, new_bn, NOW, 0.75, 'sp_name_parse', ''))

print(f"Business names con SP leak a corregir: {len(bn_updates)}")

# Preview
print("\nPREVIEW business names (10):")
for new_bn, rowid in bn_updates[:10]:
    old = next(r[1] for r in no_biz_rows if r[0] == rowid)
    print(f"  OLD: {(old or '')[:100]}")
    print(f"  NEW: {new_bn[:100]}")
    print()

cur.executemany("UPDATE rules SET business_name=? WHERE rowid=?", bn_updates)

# Log todo
cur.executemany("""
    INSERT INTO rule_enrichment_log (rule_id,swarm,field,old_value,new_value,timestamp,confidence,method,notes)
    VALUES (?,?,?,?,?,?,?,?,?)
""", log_id + log_bn)
cur.execute("INSERT INTO rules_fts(rules_fts) VALUES('rebuild')")
con.commit()

# Verificar
cur.execute("SELECT COUNT(*) FROM rules WHERE id LIKE 'BRB-unk-%'")
unk = cur.fetchone()[0]
cur.execute("SELECT COUNT(*) FROM rules WHERE id LIKE 'BRB-%'")
total = cur.fetchone()[0]
print(f"\n✓ BRB total: {total}  BRB-unk restantes: {unk}")

cur.execute("SELECT id, sp FROM rules WHERE id LIKE 'BRB-%' LIMIT 8")
print("\nMuestra IDs finales:")
for r in cur.fetchall():
    print(f"  {r[0]}")

con.close()
print("\nCorre: python digital-brain/rebuild_from_brain.py")
