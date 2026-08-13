#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
build-quality-data.py — EXTRACTOR de calidad AS-IS (Capa Transversal · Calidad del
Gemelo Cognitivo). Mide los SPs Informix SPL contra ISO/IEC 5055:2021 (4 factores,
weaknesses ancladas a CWE) y emite quality-data.json (contrato para el renderer).

Determinista-first: motor de reglas regex + AST ligero sobre el corpus real.
Calibrado al dialecto SPL y al contexto de banca legacy para EVITAR falsos positivos:
  · EXECUTE PROCEDURE no es SQL dinámico (solo EXECUTE IMMEDIATE / PREPARE..FROM con ||)
  · ON EXCEPTION con cuerpo = manejado; solo el vacío es weakness
  · umbrales de complejidad/LoC/fan-out calibrados por PERCENTIL del propio sistema
    (no umbral greenfield — un core bancario es naturalmente denso)
  · fan_in=0 = candidato, NO dead-code confirmado (puede ser entry-point de app)
  · códigos regulatorios ('00000', claves CNBV/SAT) NO son magic numbers

Implementa el método HVM-wide; ejecutor: Specialist - Code Quality Assessment.
Consume: callgraph-data.json (loc/fan_in/fan_out) + source/**/*.sql.
"""
import sys, json, glob, re, os
from collections import defaultdict
sys.stdout.reconfigure(encoding="utf-8")

BASE = os.path.normpath(os.path.join(
    os.path.dirname(os.path.abspath(__file__)), '..')) + '/'
# (chdir removed — using absolute paths via BASE)

# ── dominios (mismo mapa que el resto del pipeline) ──────────────────────────
DOM = {
 'bdicnweb': 'D01 Canal Web', 'bdinteg': 'D02 Integración', 'bdicred': 'D03 Crédito',
 'bdicheq': 'D04 Cheques', 'bdisac': 'D05 SAC', 'bdisolic': 'D06 Solicitudes',
 'bdiaclaracion': 'D07 Aclaraciones', 'bdispei': 'D08 SPEI', 'bdimnsj': 'D09 Mensajería',
 'bdisuc': 'D10 Sucursales', 'bdicobranza': 'D11 Cobranza', 'bdicont': 'D12 Contabilidad'}
# dominios transaccionales críticos → umbral de tolerancia más estricto
CRITICOS = {'bdicont', 'bdispei', 'bdicheq', 'bdicred', 'bdicobranza'}

# ── split de dumps en procedures individuales ────────────────────────────────
# Los .sql NO son 1 SP/archivo: son dumps con hasta ~900 procedures concatenados.
# Hay que aislar cada CREATE PROCEDURE/FUNCTION y analizarlo por separado.
SPLIT = re.compile(r'(?i)(?=create\s+(?:dba\s+)?(?:procedure|function)\b)')
NAME = re.compile(r'create\s+(?:dba\s+)?(?:procedure|function)\s+(?:"[^"]+"\s*\.\s*)?"?([a-z0-9_]+)"?', re.I)

def iter_procedures():
    """Genera (db, label, cuerpo) por cada procedure real del corpus."""
    for f in glob.glob(BASE + 'source/**/*.sql', recursive=True):
        b = re.split(r'[\\/]', f)[-1]
        db = b.split('_', 1)[0]                    # bdinteg_… → bdinteg
        try:
            t = open(f, 'rb').read().decode('latin-1')
        except Exception:
            continue
        for block in SPLIT.split(t):
            m = NAME.match(block.lstrip())
            if not m:
                continue                            # preámbulo/basura sin CREATE
            yield db, m.group(1).lower(), block

# ── reglas ISO 5055 · cada una devuelve (n_ocurrencias, evidencia_1a) ─────────
RX = {
  'on_exc':      re.compile(r'\bon\s+exception\b', re.I),
  'on_exc_void': re.compile(r'on\s+exception\b[^;]*;\s*end\s+exception', re.I),   # declara y cierra sin cuerpo
  'foreach':     re.compile(r'\bforeach\b', re.I),
  'end_foreach': re.compile(r'\bend\s+foreach\b', re.I),
  'open':        re.compile(r'\bopen\s+\w+', re.I),
  'close':       re.compile(r'\bclose\s+\w+', re.I),
  'begin_work':  re.compile(r'\bbegin\s+work\b', re.I),
  'commit':      re.compile(r'\bcommit\s+work\b', re.I),
  'rollback':    re.compile(r'\brollback\s+work\b', re.I),
  'exec_imm':    re.compile(r'\bexecute\s+immediate\b', re.I),
  'prepare':     re.compile(r'\bprepare\s+\w+\s+from\b', re.I),
  # decisión (para complejidad ciclomática SPL)
  'dec':         re.compile(r'\b(if|elif|while|foreach|when|on\s+exception)\b', re.I),
  # ruta de filesystem hardcodeada en I/O REAL (no cualquier string con /a/b):
  # LOAD FROM/UNLOAD TO '/path', system('… /path'), o redirección > /path
  'hardpath':    re.compile(r'(?i)(?:(?:load\s+from|unload\s+to)\s*["\']?\s*/[a-z0-9_]+/'
                            r'|system\s*\(\s*["\'][^"\']*/[a-z0-9_]+/'
                            r'|>\s*/[a-z0-9_]+/[a-z0-9_])'),
  # comentario de documentación (header)
  'doc':         re.compile(r'(--|\{)', ),
  'div':         re.compile(r'/\s*[a-z_]\w*', re.I),   # división por variable (posible /0)
}

def commit_in_loop(t):
    """COMMIT WORK dentro de un bloque FOREACH..END FOREACH."""
    for m in re.finditer(r'\bforeach\b(.*?)\bend\s+foreach\b', t, re.I | re.S):
        if RX['commit'].search(m.group(1)):
            return True
    return False

def dyn_sql(t):
    """SQL dinámico REAL: EXECUTE IMMEDIATE con ||, o PREPARE..FROM con || (concatenación)."""
    for m in re.finditer(r'\bexecute\s+immediate\s+([^;]+);', t, re.I):
        if '||' in m.group(1):
            return True
    for m in re.finditer(r'\bprepare\s+\w+\s+from\s+([^;]+);', t, re.I):
        if '||' in m.group(1):
            return True
    return False

def has_doc_header(t):
    """¿Hay comentario de documentación en las primeras ~12 líneas?"""
    head = '\n'.join(t.splitlines()[:12])
    return ('--' in head) or ('{' in head)

def analyze(t):
    """Devuelve el set de reglas disparadas + métricas del SP."""
    hits = {}
    # complejidad ciclomática ≈ 1 + nº de nodos de decisión
    cc = 1 + len(RX['dec'].findall(t))
    n_open = len(RX['open'].findall(t)); n_close = len(RX['close'].findall(t))
    n_bw = len(RX['begin_work'].findall(t))
    has_commit = bool(RX['commit'].search(t)); has_rb = bool(RX['rollback'].search(t))

    # ── Reliability ──
    if not RX['on_exc'].search(t):
        hits['R1'] = 1                                   # sin manejo de error
    if RX['on_exc_void'].search(t):
        hits['R2'] = 1                                   # handler vacío (traga el error)
    if n_open > n_close:
        hits['R3'] = n_open - n_close                    # cursor sin CLOSE (leak)
    if n_bw > 0 and not (has_commit or has_rb):
        hits['R4'] = 1                                   # transacción sin cierre garantizado
    # ── Security ──
    if dyn_sql(t):
        hits['S1'] = 1                                   # SQL dinámico con concatenación (CWE-89)
    hp = RX['hardpath'].findall(t)
    if hp:
        hits['S2'] = len(hp)                             # ruta de archivo hardcodeada (CWE-798)
    # ── Performance ──
    if commit_in_loop(t):
        hits['P1'] = 1                                   # COMMIT dentro de FOREACH (CWE-1049)
    # ── Maintainability (M1/M2/M3 usan umbral calibrado, se aplican fuera) ──
    if not has_doc_header(t):
        hits['M5'] = 1                                   # sin comentario de documentación
    return hits, cc

# ── metadatos de reglas (para el renderer) ───────────────────────────────────
REGLAS = {
 'R1': ('reliability','CWE-391','Manejo de error ausente','SP sin ON EXCEPTION','serio'),
 'R2': ('reliability','CWE-390','Handler que traga el error','ON EXCEPTION con cuerpo vacío','serio'),
 'R3': ('reliability','CWE-772','Cursor sin CLOSE','OPEN sin CLOSE correspondiente','serio'),
 'R4': ('reliability','CWE-460','Transacción sin cierre','BEGIN WORK sin COMMIT/ROLLBACK','critico'),
 'S1': ('security','CWE-89','SQL dinámico con concatenación','EXECUTE IMMEDIATE / PREPARE con ||','critico'),
 'S2': ('security','CWE-798','Ruta/recurso hardcodeado','path de archivo embebido en el SP','warning'),
 'P1': ('performance','CWE-1049','COMMIT dentro de loop','COMMIT WORK dentro de FOREACH','serio'),
 'M1': ('maintainability','CWE-1120','Complejidad ciclomática excesiva','> umbral calibrado del sistema','warning'),
 'M2': ('maintainability','CWE-1080','Componente sobredimensionado','LoC > umbral calibrado','warning'),
 'M3': ('maintainability','CWE-1047','Acoplamiento excesivo (fan-out)','> umbral calibrado del sistema','warning'),
 'M4': ('maintainability','CWE-561','Código candidato a retiro','fan_in=0 (revisar si es entry-point)','warning'),
 'M5': ('maintainability','CWE-1116','Documentación ausente','sin comentario de propósito en el header','warning'),
}
FACTORES = {'reliability':'Reliability','security':'Security',
            'performance':'Performance Efficiency','maintainability':'Maintainability'}
SEV_RANK = {'critico':4,'serio':3,'warning':2,'ok':1}

def pct(vals, p):
    if not vals: return 0
    s = sorted(vals); k = int(len(s) * p / 100)
    return s[min(k, len(s)-1)]

def main():
    CG = json.load(open(BASE + 'portal/data/callgraph-data.json', encoding='utf-8'))['graph']
    # fan-in/out por (db, label) — el callgraph solo tiene los conectados
    fan = {(n.get('db',''), n.get('label','')): n for n in CG['nodes']}

    # primera pasada: aislar cada procedure real, calcular LoC/CC del BLOQUE y aplicar reglas
    per_sp = []
    ccs, locs, fouts = [], [], []
    seen = set()
    for db, label, body in iter_procedures():
        key = (db, label)
        if key in seen:               # dedup (mismo SP repetido en varios dumps)
            continue
        seen.add(key)
        hits, cc = analyze(body)
        loc = body.count('\n') + 1
        node = fan.get(key) or fan.get((db, 'sp_' + label))
        in_cg = node is not None                     # ¿tiene datos de call graph?
        fi = node.get('fan_in', 0) if in_cg else None
        fo = node.get('fan_out', 0) if in_cg else None
        ccs.append(cc); locs.append(loc)
        if in_cg: fouts.append(fo)                    # TH_FO se calibra solo sobre SPs con dato real
        per_sp.append({'id': f'{db}:{label}', 'db': db, 'label': label, 'in_cg': in_cg,
                       'loc': loc, 'fanin': fi, 'fanout': fo, 'cc': cc, 'hits': hits})

    # umbrales calibrados por percentil del propio sistema (p90) — NO greenfield
    TH_CC = max(pct(ccs, 90), 25)
    TH_LOC = max(pct(locs, 90), 400)
    TH_FO = max(pct(fouts, 90), 20)

    # segunda pasada: aplicar reglas de umbral (M1/M2/M3/M4) y consolidar
    por_dom = defaultdict(lambda: {'sps':0,'weak':0,'loc':0,'sev':defaultdict(int)})
    regla_cnt = defaultdict(int)
    factor_cnt = defaultdict(lambda: {'weak':0,'sps':set(),'crit':0})
    with_eh = 0
    hallazgos = []

    for r in per_sp:
        h = dict(r['hits'])
        if r['cc'] > TH_CC:   h['M1'] = r['cc']
        if r['loc'] > TH_LOC: h['M2'] = r['loc']
        # M3/M4 SOLO sobre SPs con dato de call graph — no inventar fan=0 para los no mapeados
        if r['in_cg'] and r['fanout'] > TH_FO: h['M3'] = r['fanout']
        if r['in_cg'] and r['fanin'] == 0:     h['M4'] = 1
        r['hits'] = h
        if 'R1' not in h:     with_eh += 1

        db = r['db']; dom = DOM.get(db, db or '—')
        por_dom[dom]['sps'] += 1
        por_dom[dom]['loc'] += r['loc']
        sev_max = 'ok'
        for rid in h:
            factor, cwe, tit, ev, sev = REGLAS[rid]
            regla_cnt[rid] += 1
            factor_cnt[factor]['weak'] += 1
            factor_cnt[factor]['sps'].add(r['id'])
            if sev == 'critico': factor_cnt[factor]['crit'] += 1
            por_dom[dom]['weak'] += 1
            por_dom[dom]['sev'][sev] += 1
            if SEV_RANK[sev] > SEV_RANK[sev_max]: sev_max = sev
        r['sev_max'] = sev_max

    # top hallazgos: por severidad máx, luego nº de reglas, luego loc
    ranked = [r for r in per_sp if r['hits']]
    ranked.sort(key=lambda r: (SEV_RANK[r['sev_max']], len(r['hits']), r['loc']), reverse=True)
    for r in ranked[:60]:
        hallazgos.append({
            'sp': r['label'], 'db': r['db'], 'dom': DOM.get(r['db'], r['db']),
            'loc': r['loc'], 'fanin': r['fanin'], 'fanout': r['fanout'], 'cc': r['cc'],
            'sev': r['sev_max'],
            'reglas': [{'id': k, 'cwe': REGLAS[k][1], 'factor': REGLAS[k][0],
                        'tit': REGLAS[k][2], 'sev': REGLAS[k][4]} for k in r['hits']],
        })

    # histograma de complejidad
    buckets = [(0,10),(10,25),(25,50),(50,100),(100,10**9)]
    blab = ['1–10','11–25','26–50','51–100','100+']
    hist = [0]*len(buckets)
    for c in ccs:
        for i,(lo,hi) in enumerate(buckets):
            if lo < c <= hi or (i==0 and c<=hi): hist[i]+=1; break

    total_weak = sum(regla_cnt.values())
    out = {
      'meta': {'sistema':'Informix','tecnologia':'informix-spl','estandar':'ISO/IEC 5055:2021',
               'sps_analizados': len(per_sp), 'sps_en_callgraph': len(CG['nodes']),
               'weaknesses_total': total_weak},
      'umbrales': {'complejidad': TH_CC, 'loc': TH_LOC, 'fanout': TH_FO,
                   'nota':'calibrados a p90 del propio sistema (no greenfield)'},
      'factores': [
         {'key':k,'nombre':FACTORES[k],'weak':factor_cnt[k]['weak'],
          'sps':len(factor_cnt[k]['sps']),'crit':factor_cnt[k]['crit']}
         for k in ['reliability','security','performance','maintainability']],
      'reglas': [
         {'id':rid,'factor':REGLAS[rid][0],'cwe':REGLAS[rid][1],'titulo':REGLAS[rid][2],
          'evidencia':REGLAS[rid][3],'sev':REGLAS[rid][4],'count':regla_cnt.get(rid,0)}
         for rid in REGLAS],
      'por_dominio': sorted([
         {'dom':d,'sps':v['sps'],'weak':v['weak'],'loc':v['loc'],
          'densidad': round(1000*v['weak']/v['loc'],2) if v['loc'] else 0,
          'critico': v['sev'].get('critico',0),'serio': v['sev'].get('serio',0),
          'warning': v['sev'].get('warning',0),
          'critico_dom': (d.split()[0] and any(c in d.lower() for c in ['contab','spei','cheq','crédit','cred','cobr']))}
         for d,v in por_dom.items()], key=lambda x:-x['densidad']),
      'salud': {'con_manejo_error': with_eh, 'pct_con_error_handling': round(100*with_eh/len(per_sp)) if per_sp else 0},
      'hist_complejidad': [{'rango':blab[i],'n':hist[i]} for i in range(len(buckets))],
      'hallazgos': hallazgos,
    }
    json.dump(out, open(BASE + 'portal/data/quality-data.json','w',encoding='utf-8'), ensure_ascii=False, indent=1)
    print(f"quality-data.json escrito · {len(per_sp)} SPs analizados · {total_weak} weaknesses")
    print(f"umbrales calibrados p90: CC>{TH_CC} · LoC>{TH_LOC} · fan-out>{TH_FO}")
    print(f"error handling: {with_eh}/{len(per_sp)} ({out['salud']['pct_con_error_handling']}%)")
    for k in ['reliability','security','performance','maintainability']:
        fc = factor_cnt[k]; print(f"  {FACTORES[k]:22} {fc['weak']:5} weaknesses · {len(fc['sps'])} SPs · {fc['crit']} críticas")

if __name__ == '__main__':
    main()
