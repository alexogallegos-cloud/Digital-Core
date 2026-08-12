"""Export SP inventory from brain.db → portal/data/sp-inventory.json"""
import sqlite3, json
from pathlib import Path

BASE   = Path(__file__).parent.parent
DB     = BASE / 'digital-brain' / 'brain.db'
OUT    = Path(__file__).parent / 'data' / 'sp-inventory.json'

conn = sqlite3.connect(DB)
conn.row_factory = sqlite3.Row

rows = conn.execute("""
SELECT
  s.id,
  s.name,
  s.db,
  s.domain,
  s.biz,
  s.sp_role,
  s.is_soul,
  s.soul_pattern,
  s.complexity,
  s.loc,
  s.fan_in,
  s.fan_out,
  s.calls_n,
  s.prod_calls_day,
  s.prod_calls_hour,
  s.prod_calls_sec,
  s.prod_errors_day,
  s.prod_error_rate,
  s.prod_channels_n,
  s.prod_p50_s,
  s.prod_p95_s,
  s.prod_p99_s,
  s.prod_evidence_date,
  s.prod_calling_systems,
  b.archetype
FROM sps s
LEFT JOIN batch_analysis b ON s.name = b.sp_name AND s.db = b.db
ORDER BY
  CASE s.sp_role
    WHEN 'entry_point'          THEN 1
    WHEN 'cross_domain_primitive' THEN 2
    WHEN 'shared_service'       THEN 3
    WHEN 'esb_exposed'          THEN 4
    ELSE 5
  END,
  COALESCE(s.prod_calls_day, 0) DESC
""").fetchall()

records = []
for r in rows:
    rec = dict(r)
    # Parse calling_systems JSON string
    cs = rec.get('prod_calling_systems')
    if cs:
        try:
            rec['prod_calling_systems'] = json.loads(cs)
        except Exception:
            rec['prod_calling_systems'] = []
    else:
        rec['prod_calling_systems'] = []
    records.append(rec)

conn.close()

OUT.parent.mkdir(parents=True, exist_ok=True)
with open(OUT, 'w', encoding='utf-8') as f:
    json.dump(records, f, ensure_ascii=False)

print(f"Exported {len(records)} SPs → {OUT}")

# Summary by role
from collections import Counter
roles = Counter(r['sp_role'] for r in records if r['sp_role'])
for role, n in sorted(roles.items(), key=lambda x: -x[1]):
    with_vol = sum(1 for r in records if r['sp_role']==role and r['prod_calls_day'])
    with_lat = sum(1 for r in records if r['sp_role']==role and r['prod_p95_s'])
    print(f"  {role:30s}: {n:4d} total  {with_vol:4d} con volumen  {with_lat:4d} con latencia")
