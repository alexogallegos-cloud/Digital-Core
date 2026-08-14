#!/usr/bin/env python3
"""
generators/build-creacion-perfil.py
Genera portal/taxonomia-creacion-perfil.html
ETB L3 7.1.1 — Customer Establishment (Creación de Perfil)
"""
import sqlite3
import json
import html as html_lib
import os
from collections import defaultdict

DB_PATH  = os.path.join(os.path.dirname(__file__), '..', 'digital-brain', 'brain.db')
OUT_PATH = os.path.join(os.path.dirname(__file__), '..', 'portal', 'taxonomia-creacion-perfil.html')

L3_ID = '7.1.1'

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
cur = conn.cursor()

# ── ETB hierarchy ─────────────────────────────────────────────────────────────
cur.execute("SELECT id, l2_id, l1_id, name, definition, bcop_status, sp_n, esb_n, soul_n, sp_fine_n FROM etb_l3 WHERE id=?", (L3_ID,))
l3 = dict(cur.fetchone())

cur.execute("SELECT id, name FROM etb_l2 WHERE id=?", (l3['l2_id'],))
l2 = dict(cur.fetchone())

cur.execute("SELECT id, name FROM etb_l1 WHERE id=?", (l3['l1_id'],))
l1 = dict(cur.fetchone())

# ── Domain names ──────────────────────────────────────────────────────────────
cur.execute("SELECT id, db, name, color FROM domains ORDER BY id")
domain_map = {r['id']: dict(r) for r in cur.fetchall()}

# ── SPs for this L3 ───────────────────────────────────────────────────────────
cur.execute("""
    SELECT id, name, db, domain, fan_in, fan_out, biz, sp_role,
           is_soul, soul_rank, primary_l3_confidence,
           loc, complexity, weaknesses, prod_calls_day, prod_p99_s
    FROM sps
    WHERE primary_l3 = ?
    ORDER BY domain, fan_in DESC, name
""", (L3_ID,))
sps_raw = [dict(r) for r in cur.fetchall()]

# ── Domain distribution ───────────────────────────────────────────────────────
domain_dist = defaultdict(lambda: {'count': 0, 'souls': 0, 'esb': 0})
for sp in sps_raw:
    d = sp['domain']
    domain_dist[d]['count'] += 1
    if sp['is_soul']:
        domain_dist[d]['souls'] += 1
    if sp['sp_role'] == 'esb_exposed':
        domain_dist[d]['esb'] += 1

domains_present = sorted(domain_dist.keys())

# ── Internal call graph ────────────────────────────────────────────────────────
sp_ids_set = {sp['id'] for sp in sps_raw}
cur.execute("""
    SELECT c.from_sp, c.to_sp, c.cross_db
    FROM sp_calls c
    WHERE c.from_sp IN (SELECT id FROM sps WHERE primary_l3 = ?)
      AND c.to_sp   IN (SELECT id FROM sps WHERE primary_l3 = ?)
""", (L3_ID, L3_ID))
internal_calls = [dict(r) for r in cur.fetchall()]

# Top callers-within for top 15 fan_in SPs
top_fan_in = sorted(sps_raw, key=lambda x: x['fan_in'], reverse=True)[:15]
top_ids = {sp['id'] for sp in top_fan_in}

# For those top SPs get external callers
callers_map = defaultdict(list)
callees_map = defaultdict(list)
for sp in top_fan_in:
    cur.execute("""
        SELECT c.from_sp, s.name, s.domain, s.fan_in
        FROM sp_calls c
        JOIN sps s ON s.id = c.from_sp
        WHERE c.to_sp = ?
        ORDER BY s.fan_in DESC
        LIMIT 5
    """, (sp['id'],))
    callers_map[sp['id']] = [dict(r) for r in cur.fetchall()]

    cur.execute("""
        SELECT c.to_sp, s.name, s.domain, s.fan_in
        FROM sp_calls c
        JOIN sps s ON s.id = c.to_sp
        WHERE c.from_sp = ?
        ORDER BY s.fan_in DESC
        LIMIT 5
    """, (sp['id'],))
    callees_map[sp['id']] = [dict(r) for r in cur.fetchall()]

conn.close()

# ── Helpers ───────────────────────────────────────────────────────────────────
def esc(s):
    return html_lib.escape(str(s or ''))

def role_badge(role):
    if role == 'esb_exposed':
        return '<span class="badge-esb">ESB</span>'
    return '<span class="badge-int">INT</span>'

def conf_bar(val):
    if val is None:
        return '<span class="conf-na">—</span>'
    pct = int(round(val * 100))
    cls = 'high' if pct >= 80 else ('mid' if pct >= 50 else 'low')
    return f'<span class="conf-bar conf-{cls}" style="--pct:{pct}%">{pct}%</span>'

def fan_cell(n):
    if n is None or n == 0:
        return '<span class="fan-zero">0</span>'
    cls = 'fan-high' if n >= 100 else ('fan-mid' if n >= 20 else 'fan-low')
    return f'<span class="{cls}">{n:,}</span>'

def soul_star(is_soul, rank):
    if is_soul:
        r = f' #{rank}' if rank else ''
        return f'<span class="soul-star" title="Alma del sistema{r}">★</span>'
    return ''

def domain_label(d):
    info = domain_map.get(d, {})
    name = info.get('name') or info.get('db') or d
    return f'{d} – {name}'

def truncate(s, n=80):
    if not s:
        return ''
    s = str(s)
    return s[:n] + '…' if len(s) > n else s

# ── Build SP rows grouped by domain ───────────────────────────────────────────
grouped = defaultdict(list)
for sp in sps_raw:
    grouped[sp['domain']].append(sp)

# ── Stats ─────────────────────────────────────────────────────────────────────
total_sps   = len(sps_raw)
total_esb   = sum(1 for s in sps_raw if s['sp_role'] == 'esb_exposed')
total_souls = sum(1 for s in sps_raw if s['is_soul'])
total_calls = len(internal_calls)

# ── Domain tiles HTML ─────────────────────────────────────────────────────────
domain_tiles_html = ''
for d in domains_present:
    info   = domain_map.get(d, {})
    dname  = info.get('name') or d
    cnt    = domain_dist[d]['count']
    esb_n  = domain_dist[d]['esb']
    pct    = int(round(cnt / total_sps * 100)) if total_sps else 0
    domain_tiles_html += f'''
    <div class="d-tile" onclick="scrollToDomain('{d}')">
      <div class="d-tile-id">{esc(d)}</div>
      <div class="d-tile-name">{esc(dname)}</div>
      <div class="d-tile-count">{cnt}</div>
      <div class="d-tile-pct">
        <div class="d-pct-bar" style="width:{pct}%"></div>
      </div>
      <div class="d-tile-meta">{pct}% · {esb_n} ESB</div>
    </div>'''

# ── Internal call edges table ─────────────────────────────────────────────────
# Deduplicate self-calls
real_edges = [c for c in internal_calls if c['from_sp'] != c['to_sp']]
# Sort by cross_db desc, then alphabetically
real_edges.sort(key=lambda x: (-x['cross_db'], x['from_sp']))

call_rows_html = ''
for e in real_edges[:50]:
    src_name  = e['from_sp'].split(':')[-1] if ':' in e['from_sp'] else e['from_sp']
    src_db    = e['from_sp'].split(':')[0]  if ':' in e['from_sp'] else ''
    dst_name  = e['to_sp'].split(':')[-1]   if ':' in e['to_sp']   else e['to_sp']
    dst_db    = e['to_sp'].split(':')[0]    if ':' in e['to_sp']    else ''
    cross_cls = 'cross-yes' if e['cross_db'] else 'cross-no'
    cross_lbl = 'cross-DB' if e['cross_db'] else 'same-DB'
    call_rows_html += f'''
    <tr>
      <td class="mono"><span class="db-tag">{esc(src_db)}</span> {esc(src_name)}</td>
      <td class="arr-cell">→</td>
      <td class="mono"><span class="db-tag">{esc(dst_db)}</span> {esc(dst_name)}</td>
      <td><span class="cross-badge {cross_cls}">{cross_lbl}</span></td>
    </tr>'''

# ── Main SP sections ───────────────────────────────────────────────────────────
sections_html = ''
for d in domains_present:
    sps_d = grouped[d]
    info  = domain_map.get(d, {})
    dname = info.get('name') or d
    esb_d = sum(1 for s in sps_d if s['sp_role'] == 'esb_exposed')

    rows_html = ''
    for sp in sps_d:
        sp_id_safe = esc(sp['id'])
        biz_text   = esc(truncate(sp['biz'], 90))
        detail_url = f"sp-{sp['name'].replace('_','-')}.html"
        name_cell  = f'<a href="{esc(detail_url)}" class="sp-link" title="Detalle SP">{esc(sp["name"])}</a>'

        rows_html += f'''
        <tr>
          <td class="mono">{name_cell}{soul_star(sp["is_soul"], sp["soul_rank"])}</td>
          <td class="center">{role_badge(sp["sp_role"])}</td>
          <td class="right">{fan_cell(sp["fan_in"])}</td>
          <td class="right">{fan_cell(sp["fan_out"])}</td>
          <td class="right">{sp["loc"] or 0:,}</td>
          <td>{conf_bar(sp["primary_l3_confidence"])}</td>
          <td class="biz-cell">{biz_text}</td>
        </tr>'''

    sections_html += f'''
  <section class="domain-section" id="domain-{d}">
    <div class="domain-header">
      <span class="domain-id">{esc(d)}</span>
      <span class="domain-name">{esc(dname)}</span>
      <span class="domain-count">{len(sps_d)} SPs</span>
      <span class="domain-esb">{esb_d} ESB</span>
    </div>
    <div class="table-wrap">
      <table class="sp-table">
        <thead>
          <tr>
            <th>Stored Procedure</th>
            <th>Rol</th>
            <th class="right">Fan-in</th>
            <th class="right">Fan-out</th>
            <th class="right">LOC</th>
            <th>Confianza</th>
            <th>Descripción de negocio</th>
          </tr>
        </thead>
        <tbody>
          {rows_html}
        </tbody>
      </table>
    </div>
  </section>'''

# ── Top SPs detail cards ───────────────────────────────────────────────────────
top_cards_html = ''
for sp in top_fan_in[:10]:
    callers = callers_map[sp['id']]
    callees = callees_map[sp['id']]

    def sp_pill(name, domain):
        return f'<span class="sp-pill" title="{esc(domain)}">{esc(name)}</span>'

    callers_html = ' '.join(sp_pill(c['name'], c['domain']) for c in callers) or '<span class="muted">—</span>'
    callees_html = ' '.join(sp_pill(c['name'], c['domain']) for c in callees) or '<span class="muted">—</span>'

    top_cards_html += f'''
    <div class="top-card">
      <div class="top-card-head">
        <span class="mono top-name">{esc(sp["name"])}</span>
        <span class="db-badge">{esc(sp["db"])}</span>
        {role_badge(sp["sp_role"])}
        {soul_star(sp["is_soul"], sp["soul_rank"])}
      </div>
      <div class="top-card-biz">{esc(sp["biz"] or "—")}</div>
      <div class="top-card-stats">
        <span><b>{sp["fan_in"] or 0:,}</b> callers</span>
        <span><b>{sp["fan_out"] or 0:,}</b> callees</span>
        <span><b>{sp["loc"] or 0:,}</b> LOC</span>
        <span>conf <b>{int((sp["primary_l3_confidence"] or 0)*100)}%</b></span>
      </div>
      <div class="top-card-links">
        <div class="flow-section">
          <div class="flow-label">Llamado por</div>
          <div class="flow-pills">{callers_html}</div>
        </div>
        <div class="flow-section">
          <div class="flow-label">Llama a</div>
          <div class="flow-pills">{callees_html}</div>
        </div>
      </div>
    </div>'''

# ── Full HTML ─────────────────────────────────────────────────────────────────
html = f'''<!DOCTYPE html>
<html lang="es">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>BanCoppel · Taxonomía de SPs · Creación de Perfil</title>
<style>
/* ── Reset & tokens ─────────────────────────────────── */
:root{{
  --bg:#060a1a;--bg2:#0d1533;--panel:#111c47;--line:#26317c;
  --txt:#F4F6FF;--muted:#aab3d4;--muted2:#818ab0;
  --on:#2E52C8;--on-sh:rgba(46,82,200,.55);
  --acc:#F0D224;--yellow:#F0D224;
  --head1:#0d2185;--head2:#122FB1;
  --esb:#0ea5e9;--int:#6366f1;
  --glass:rgba(255,255,255,.055);
  --radius:8px;
}}
*{{box-sizing:border-box;margin:0;padding:0}}
body{{background:var(--bg);color:var(--txt);
  font-family:'SF Pro Display',-apple-system,BlinkMacSystemFont,'Inter','Segoe UI',sans-serif;
  -webkit-font-smoothing:antialiased;overflow-x:hidden;font-size:13px}}

/* ── Aurora & grain ─────────────────────────────────── */
.aurora{{position:fixed;inset:0;z-index:-2;overflow:hidden;pointer-events:none}}
.aurora::before{{content:"";position:absolute;width:62vw;height:62vw;left:-12vw;top:-16vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(27,63,208,.55),transparent 70%);
  animation:f1 24s ease-in-out infinite}}
.aurora::after{{content:"";position:absolute;width:56vw;height:56vw;right:-14vw;top:6vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(13,33,133,.6),transparent 70%);
  animation:f2 28s ease-in-out infinite}}
.aurora .blob{{position:absolute;width:40vw;height:40vw;left:34vw;bottom:-14vw;
  border-radius:50%;filter:blur(90px);
  background:radial-gradient(circle,rgba(240,210,36,.15),transparent 70%);
  animation:f3 32s ease-in-out infinite}}
@keyframes f1{{50%{{transform:translate(6vw,8vh) scale(1.15)}}}}
@keyframes f2{{50%{{transform:translate(-7vw,10vh) scale(1.12)}}}}
@keyframes f3{{50%{{transform:translate(-9vw,-9vh) scale(1.22)}}}}
.grain{{position:fixed;inset:0;z-index:-1;opacity:.04;pointer-events:none;
  background-image:url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='140' height='140'%3E%3Cfilter id='n'%3E%3CfeTurbulence type='fractalNoise' baseFrequency='.85' numOctaves='2' stitchTiles='stitch'/%3E%3C/filter%3E%3Crect width='100%25' height='100%25' filter='url(%23n)'/%3E%3C/svg%3E")}}

/* ── Nav bar ─────────────────────────────────────────── */
.hero-bar{{position:fixed;top:0;left:0;right:0;z-index:50;display:flex;align-items:center;gap:16px;
  padding:13px 28px;
  -webkit-backdrop-filter:blur(20px) saturate(150%);backdrop-filter:blur(20px) saturate(150%);
  background:rgba(6,10,26,.65);border-bottom:1px solid rgba(255,255,255,.07)}}
.hero-bar img{{height:32px;object-fit:contain;filter:drop-shadow(0 2px 6px rgba(0,0,0,.6))}}
.hb-sep{{width:1px;height:26px;background:rgba(255,255,255,.15);flex-shrink:0}}
.crumb{{font-size:10px;font-weight:600;letter-spacing:.12em;text-transform:uppercase;color:rgba(255,255,255,.35)}}
.crumb em{{color:var(--yellow);font-style:normal}}
.hb-sp{{flex:1}}
.hero-bar a.back{{font-size:11px;color:var(--muted);padding:5px 12px;border-radius:20px;
  border:1px solid rgba(255,255,255,.09);text-decoration:none;transition:.22s}}
.hero-bar a.back:hover{{color:var(--txt);background:rgba(255,255,255,.07)}}

/* ── Hero intro ─────────────────────────────────────── */
#intro{{padding:76px 28px 0;max-width:1400px;margin:0 auto}}
.breadcrumb{{font-size:10px;color:var(--muted);margin-bottom:10px;display:flex;align-items:center;gap:6px;flex-wrap:wrap}}
.breadcrumb a{{color:var(--muted);text-decoration:none;transition:.2s}}
.breadcrumb a:hover{{color:var(--txt)}}
.breadcrumb .sep{{opacity:.4}}
.breadcrumb .cur{{color:var(--yellow);font-weight:700}}
.hero-label{{font-size:10px;font-weight:800;letter-spacing:.14em;text-transform:uppercase;color:var(--yellow);margin-bottom:10px}}
.hero-h1{{font-size:clamp(22px,3vw,38px);font-weight:900;letter-spacing:-.03em;line-height:1.05;
  background:linear-gradient(176deg,#fff 30%,#9fb4ff);-webkit-background-clip:text;background-clip:text;
  color:transparent;margin-bottom:6px}}
.hero-def{{font-size:12px;color:var(--muted);line-height:1.55;max-width:88ch;margin-bottom:16px;
  border-left:3px solid var(--on);padding-left:10px;font-style:italic}}
.stat-row{{display:flex;gap:10px;flex-wrap:wrap;margin-bottom:20px}}
.stat{{background:var(--panel);border-radius:var(--radius);padding:7px 14px;border-left:3px solid var(--acc)}}
.stat .n{{font-size:20px;font-weight:800;line-height:1}}
.stat .l{{font-size:8px;color:var(--muted);text-transform:uppercase;letter-spacing:.07em;margin-top:2px}}
.status-tag{{display:inline-block;font-size:9px;font-weight:800;letter-spacing:.08em;text-transform:uppercase;
  padding:2px 9px;border-radius:20px;margin-left:10px;vertical-align:middle}}
.status-covered{{background:rgba(46,82,200,.25);color:#93c5fd;border:1px solid rgba(46,82,200,.4)}}

/* ── Domain grid ─────────────────────────────────────── */
#domain-grid{{display:flex;gap:8px;flex-wrap:wrap;margin:0 28px 24px;max-width:1400px;padding-top:8px}}
.d-tile{{background:var(--panel);border:1px solid var(--line);border-radius:var(--radius);
  padding:10px 14px;min-width:130px;cursor:pointer;transition:.2s;flex:1;min-width:110px;max-width:180px}}
.d-tile:hover{{border-color:var(--acc);background:#1a2660}}
.d-tile-id{{font-size:10px;font-weight:800;color:var(--yellow);letter-spacing:.07em}}
.d-tile-name{{font-size:11px;font-weight:700;margin:2px 0;color:var(--txt)}}
.d-tile-count{{font-size:22px;font-weight:900;color:#fff;line-height:1}}
.d-tile-pct{{height:3px;background:rgba(255,255,255,.1);border-radius:2px;margin:5px 0 4px;overflow:hidden}}
.d-pct-bar{{height:100%;background:var(--acc);border-radius:2px;transition:width .5s}}
.d-tile-meta{{font-size:8px;color:var(--muted)}}

/* ── Section headers ─────────────────────────────────── */
.section-title{{font-size:10px;font-weight:800;letter-spacing:.12em;text-transform:uppercase;
  color:var(--yellow);margin:28px 28px 12px;max-width:1400px}}

/* ── Domain section ──────────────────────────────────── */
.domain-section{{max-width:1400px;margin:0 auto 24px;padding:0 28px}}
.domain-header{{display:flex;align-items:center;gap:12px;background:var(--head1);
  border-radius:var(--radius) var(--radius) 0 0;padding:9px 16px;border-left:4px solid var(--acc)}}
.domain-id{{font-size:11px;font-weight:900;color:var(--yellow);letter-spacing:.06em;min-width:36px}}
.domain-name{{font-size:13px;font-weight:700;flex:1}}
.domain-count{{font-size:11px;color:var(--muted);background:rgba(255,255,255,.07);
  padding:2px 9px;border-radius:12px}}
.domain-esb{{font-size:10px;color:var(--esb);background:rgba(14,165,233,.12);
  padding:2px 9px;border-radius:12px}}
.table-wrap{{overflow-x:auto;background:var(--bg2);border:1px solid var(--line);
  border-top:none;border-radius:0 0 var(--radius) var(--radius)}}
.sp-table{{width:100%;border-collapse:collapse;font-size:11.5px}}
.sp-table thead tr{{background:rgba(255,255,255,.04)}}
.sp-table th{{padding:7px 10px;text-align:left;font-size:9px;font-weight:700;
  letter-spacing:.07em;text-transform:uppercase;color:var(--muted);
  border-bottom:1px solid var(--line);white-space:nowrap}}
.sp-table th.right{{text-align:right}}
.sp-table td{{padding:6px 10px;border-bottom:1px solid rgba(255,255,255,.04);vertical-align:top}}
.sp-table tr:last-child td{{border-bottom:none}}
.sp-table tr:hover td{{background:rgba(255,255,255,.025)}}
.sp-table td.right{{text-align:right}}
.sp-table td.center{{text-align:center}}
.sp-table td.biz-cell{{color:var(--muted);font-size:11px;max-width:320px}}
.mono{{font-family:'Cascadia Code','Consolas',monospace;font-size:10.5px}}

/* ── SP link ─────────────────────────────────────────── */
.sp-link{{color:#93c5fd;text-decoration:none;transition:.15s}}
.sp-link:hover{{color:#fff;text-decoration:underline}}

/* ── Badges ──────────────────────────────────────────── */
.badge-esb{{background:rgba(14,165,233,.2);color:var(--esb);
  border:1px solid rgba(14,165,233,.35);border-radius:4px;padding:1px 6px;
  font-size:9px;font-weight:800;letter-spacing:.05em;white-space:nowrap}}
.badge-int{{background:rgba(99,102,241,.18);color:#a5b4fc;
  border:1px solid rgba(99,102,241,.3);border-radius:4px;padding:1px 6px;
  font-size:9px;font-weight:800;letter-spacing:.05em;white-space:nowrap}}
.soul-star{{color:var(--yellow);font-size:11px;margin-left:4px}}

/* ── Confidence bar ──────────────────────────────────── */
.conf-bar{{display:inline-block;position:relative;padding:1px 7px 1px 24px;
  border-radius:4px;font-size:9px;font-weight:700}}
.conf-bar::before{{content:"";position:absolute;left:4px;top:50%;transform:translateY(-50%);
  width:14px;height:5px;border-radius:3px;background:currentColor;opacity:.3}}
.conf-bar::after{{content:"";position:absolute;left:4px;top:50%;transform:translateY(-50%);
  width:calc(var(--pct, 0%) * 0.14);height:5px;border-radius:3px;background:currentColor;opacity:.9}}
.conf-high{{color:#4ade80;background:rgba(74,222,128,.1)}}
.conf-mid {{color:#facc15;background:rgba(250,204,21,.1)}}
.conf-low {{color:#f87171;background:rgba(248,113,113,.1)}}
.conf-na  {{color:var(--muted2);font-size:10px}}

/* ── Fan numbers ─────────────────────────────────────── */
.fan-high{{color:#4ade80;font-weight:700}}
.fan-mid {{color:#facc15;font-weight:600}}
.fan-low {{color:var(--muted)}}
.fan-zero{{color:var(--muted2);opacity:.5}}

/* ── DB tag ──────────────────────────────────────────── */
.db-tag{{display:inline-block;font-size:8px;font-weight:700;color:var(--muted2);
  background:rgba(255,255,255,.06);border-radius:3px;padding:0 4px;margin-right:2px;
  letter-spacing:.03em;vertical-align:middle}}

/* ── Call graph table ────────────────────────────────── */
.calls-wrap{{max-width:1400px;margin:0 auto;padding:0 28px 28px}}
.calls-table{{width:100%;max-width:900px;border-collapse:collapse;font-size:11.5px}}
.calls-table th{{padding:6px 10px;font-size:9px;font-weight:700;letter-spacing:.07em;
  text-transform:uppercase;color:var(--muted);border-bottom:1px solid var(--line);text-align:left}}
.calls-table td{{padding:5px 10px;border-bottom:1px solid rgba(255,255,255,.04)}}
.calls-table tr:hover td{{background:rgba(255,255,255,.025)}}
.arr-cell{{color:var(--acc);font-weight:800;text-align:center;font-size:14px}}
.cross-badge{{font-size:8px;font-weight:700;padding:1px 7px;border-radius:10px}}
.cross-yes{{background:rgba(240,210,36,.15);color:var(--yellow);border:1px solid rgba(240,210,36,.3)}}
.cross-no {{background:rgba(255,255,255,.06);color:var(--muted2);border:1px solid rgba(255,255,255,.1)}}

/* ── Top SPs cards ───────────────────────────────────── */
.top-cards{{max-width:1400px;margin:0 auto;padding:0 28px 32px;
  display:grid;grid-template-columns:repeat(auto-fill,minmax(340px,1fr));gap:14px}}
.top-card{{background:var(--panel);border:1px solid var(--line);border-radius:var(--radius);padding:14px 16px}}
.top-card-head{{display:flex;align-items:center;gap:8px;flex-wrap:wrap;margin-bottom:6px}}
.top-name{{font-size:11.5px;color:#93c5fd;flex:1;word-break:break-all}}
.db-badge{{font-size:8px;font-weight:800;background:rgba(255,255,255,.08);
  color:var(--muted);padding:1px 7px;border-radius:10px;letter-spacing:.05em}}
.top-card-biz{{font-size:11px;color:var(--muted);line-height:1.45;margin-bottom:8px;
  border-left:2px solid rgba(255,255,255,.1);padding-left:8px;font-style:italic}}
.top-card-stats{{display:flex;gap:14px;font-size:10px;color:var(--muted);margin-bottom:10px}}
.top-card-stats b{{color:var(--txt)}}
.top-card-links{{display:flex;flex-direction:column;gap:8px}}
.flow-section{{}}
.flow-label{{font-size:8px;font-weight:700;letter-spacing:.08em;text-transform:uppercase;
  color:var(--muted2);margin-bottom:4px}}
.flow-pills{{display:flex;flex-wrap:wrap;gap:4px}}
.sp-pill{{background:rgba(255,255,255,.06);border:1px solid rgba(255,255,255,.1);
  border-radius:4px;padding:2px 7px;font-family:monospace;font-size:9px;
  color:var(--muted);white-space:nowrap}}
.muted{{color:var(--muted2);font-size:10px}}

/* ── Filter bar ──────────────────────────────────────── */
.filter-bar{{max-width:1400px;margin:0 auto 16px;padding:0 28px;
  display:flex;align-items:center;gap:10px;flex-wrap:wrap}}
.filter-input{{background:var(--panel);border:1px solid var(--line);border-radius:20px;
  padding:6px 16px;color:var(--txt);font-size:12px;outline:none;width:260px;transition:.2s}}
.filter-input:focus{{border-color:var(--acc)}}
.filter-label{{font-size:10px;color:var(--muted)}}
#sp-count-live{{font-weight:700;color:var(--yellow)}}

/* ── Footer ──────────────────────────────────────────── */
footer{{text-align:center;padding:32px 0 10px;font-size:10px;color:var(--muted2);
  border-top:1px solid rgba(255,255,255,.06);margin-top:20px}}
</style>
</head>
<body>
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>

<!-- ── Nav bar ──────────────────────────────────────── -->
<div class="hero-bar">
  <img src="bancoppel-logo.png" alt="BanCoppel">
  <div class="hb-sep"></div>
  <span class="crumb">BCOPCORE &nbsp;·&nbsp; SPE-AM-001 &nbsp;·&nbsp; GEMELO COGNITIVO &nbsp;·&nbsp; <em>CREACIÓN DE PERFIL</em></span>
  <span class="hb-sp"></span>
  <a href="capability-model-bcop-v2.html" class="back">← Capacidades</a>
  &nbsp;
  <a href="sp-inventory-bcop-v2.html" class="back">Inventario SPs</a>
</div>

<!-- ── Intro ─────────────────────────────────────────── -->
<div id="intro">
  <div class="breadcrumb">
    <a href="index-bcop-v2.html">Informix</a>
    <span class="sep">›</span>
    <a href="capability-model-bcop-v2.html">Capacidades ETB</a>
    <span class="sep">›</span>
    <span>{esc(l1["name"])}</span>
    <span class="sep">›</span>
    <span>{esc(l2["name"])}</span>
    <span class="sep">›</span>
    <span class="cur">{esc(l3["name"])} — Creación de Perfil</span>
  </div>

  <div class="hero-label">ETB {esc(L3_ID)} · {esc(l3["name"])}</div>
  <h1 class="hero-h1">Creación de Perfil
    <span class="status-tag status-covered">{esc(l3["bcop_status"])}</span>
  </h1>
  <p class="hero-def">{esc(l3["definition"])}</p>

  <div class="stat-row">
    <div class="stat"><div class="n">{total_sps:,}</div><div class="l">Stored Procedures</div></div>
    <div class="stat"><div class="n">{total_esb}</div><div class="l">Expuestos ESB</div></div>
    <div class="stat"><div class="n">{total_souls}</div><div class="l">Almas del sistema</div></div>
    <div class="stat"><div class="n">{len(domains_present)}</div><div class="l">Dominios activos</div></div>
    <div class="stat"><div class="n">{total_calls}</div><div class="l">Llamadas internas</div></div>
  </div>
</div>

<!-- ── Domain grid ────────────────────────────────────── -->
<div id="domain-grid">
  {domain_tiles_html}
</div>

<!-- ── Filter bar ─────────────────────────────────────── -->
<div class="filter-bar">
  <input class="filter-input" type="text" id="filter-input"
         placeholder="Filtrar por nombre de SP…" oninput="filterSPs(this.value)">
  <span class="filter-label">Mostrando <span id="sp-count-live">{total_sps}</span> / {total_sps} SPs</span>
</div>

<!-- ── Top SPs section ────────────────────────────────── -->
<div class="section-title">Top 10 SPs por Fan-in — Conexiones de llamadas</div>
<div class="top-cards">
  {top_cards_html}
</div>

<!-- ── Call graph ─────────────────────────────────────── -->
<div class="section-title">Grafo de llamadas internas ({len(real_edges)} aristas entre SPs de esta capacidad)</div>
<div class="calls-wrap">
  <table class="calls-table">
    <thead>
      <tr>
        <th>SP Origen</th>
        <th></th>
        <th>SP Destino</th>
        <th>Tipo</th>
      </tr>
    </thead>
    <tbody id="calls-tbody">
      {call_rows_html}
    </tbody>
  </table>
</div>

<!-- ── Domain sections ────────────────────────────────── -->
<div class="section-title">Detalle completo por dominio</div>
{sections_html}

<footer>
  BanCoppel · Gemelo Cognitivo · SPE-AM-001 · ETB {esc(L3_ID)} Creación de Perfil ·
  {total_sps:,} SPs en {len(domains_present)} dominios ·
  Generado 2026-08-09
</footer>

<script>
function scrollToDomain(id) {{
  const el = document.getElementById('domain-' + id);
  if (el) el.scrollIntoView({{behavior: 'smooth', block: 'start'}});
}}

function filterSPs(q) {{
  const val = q.toLowerCase().trim();
  let visible = 0;
  document.querySelectorAll('.sp-table tbody tr').forEach(tr => {{
    const text = tr.textContent.toLowerCase();
    const show = !val || text.includes(val);
    tr.style.display = show ? '' : 'none';
    if (show) visible++;
  }});
  document.querySelectorAll('.domain-section').forEach(sec => {{
    const rows = sec.querySelectorAll('tbody tr');
    const anyVisible = Array.from(rows).some(r => r.style.display !== 'none');
    sec.style.display = anyVisible ? '' : 'none';
  }});
  document.getElementById('sp-count-live').textContent = visible;
}}
</script>
</body>
</html>'''

os.makedirs(os.path.dirname(OUT_PATH), exist_ok=True)
with open(OUT_PATH, 'w', encoding='utf-8') as f:
    f.write(html)

print(f"ETB L3 ID:   {L3_ID}")
print(f"L3 name:     {l3['name']} (Creación de Perfil)")
print(f"Total SPs:   {total_sps}")
print(f"Domain dist: {dict(domain_dist)}")
print(f"Output:      {OUT_PATH}")
print("Done.")
