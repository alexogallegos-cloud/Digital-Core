"""
kg-query.py — Knowledge Graph Query CLI
Banamex GemCog · S500 + S151 · Unisys ClearPath MCP

Usage
-----
  python kg-query.py --summary
  python kg-query.py --cap 7.1.1
  python kg-query.py --risk CRITICO
  python kg-query.py --path P109 P108
  python kg-query.py --waves
  python kg-query.py --transpilable false --system S151

Options
  --system S500|S151|ALL    default: ALL
  --cap    <BIAN_ID>        list nodes for a capability
  --risk   <level>          list nodes at or above risk level
  --path   <from> <to>      shortest dependency path between nodes
  --waves                   suggest migration wave groupings
  --summary                 high-level stats across both graphs
  --transpilable true|false filter by transpilable flag
"""
from __future__ import annotations

import argparse
import json
import sys
from collections import deque
from pathlib import Path

BASE = Path(__file__).parent

GRAPHS = {
    'S500': BASE / 'data/S500/enriched-dependency-graph-s500.json',
    'S151': BASE / 'data/S151/enriched-dependency-graph-s151.json',
}

RISK_ORDER = ['SIN-DATOS', 'BAJO', 'MEDIO', 'ALTO', 'CRITICO', 'DEFECTO-PROD']
# Accept both accented and unaccented versions
RISK_ALIASES = {
    'CRÍTICO': 'CRITICO',
    'DEFECTO-PRODUCCIÓN': 'DEFECTO-PROD',
}


def _normalize_risk(r: str) -> str:
    return RISK_ALIASES.get(r.upper(), r.upper())


def _risk_rank(r: str) -> int:
    return RISK_ORDER.index(_normalize_risk(r)) if _normalize_risk(r) in RISK_ORDER else -1


def load_graph(system: str) -> dict:
    path = GRAPHS[system]
    if not path.exists():
        print(f'[ERROR] Grafo no encontrado: {path}')
        print('        Ejecuta enrich-dependency-graphs.py primero.')
        sys.exit(1)
    with open(path, encoding='utf-8') as f:
        return json.load(f)


def load_graphs(system_arg: str) -> list[dict]:
    systems = list(GRAPHS.keys()) if system_arg == 'ALL' else [system_arg.upper()]
    return [load_graph(s) for s in systems]


# ── FORMATTERS ────────────────────────────────────────────────────────────────

def _risk_badge(r: str) -> str:
    badges = {
        'DEFECTO-PROD': '[DEF-PROD]',
        'CRITICO':      '[CRITICO ]',
        'ALTO':         '[ALTO    ]',
        'MEDIO':        '[MEDIO   ]',
        'BAJO':         '[BAJO    ]',
        'SIN-DATOS':    '[---     ]',
    }
    return badges.get(_normalize_risk(r), f'[{r[:8]:8s}]')


def _node_row(node: dict, system: str) -> str:
    tid = f"{system}/{node['id']:<12}"
    cap = node.get('cap', '?')
    cap_name = node.get('cap_name', '')[:30]
    layer = node.get('layer', '?')
    loc = node.get('loc', 0)
    rules = node.get('rule_count', 0)
    risk = _risk_badge(node.get('max_risk', 'SIN-DATOS'))
    xp = '' if node.get('transpilable', True) else ' NO-XP'
    return f"  {risk} {tid}  {layer:<5}  LOC={loc:>6,}  rules={rules:>4}  {cap:<7}  {cap_name}{xp}"


def _sep(char: str = '-', width: int = 90) -> str:
    return char * width


# ── COMMANDS ──────────────────────────────────────────────────────────────────

def cmd_summary(graphs: list[dict]) -> None:
    print(_sep('='))
    print('  GEMCOG KNOWLEDGE GRAPH — SUMMARY')
    print(_sep('='))
    total_nodes = 0
    total_loc = 0
    cap_agg: dict[str, dict] = {}

    for g in graphs:
        sys_name = g['system']
        nodes = g['nodes']
        n = len(nodes)
        loc = sum(nd.get('loc', 0) for nd in nodes)
        edges = len(g.get('edges', []))
        unmapped = [nd for nd in nodes if nd.get('cap') == 'UNMAPPED']
        total_nodes += n
        total_loc += loc
        print(f'\n  {sys_name}: {n} nodos | {edges} edges | {loc:,} LOC total'
              f' | {len(unmapped)} sin cap')
        for nd in nodes:
            cap = nd.get('cap', '?')
            if cap not in cap_agg:
                cap_agg[cap] = {
                    'cap_name': nd.get('cap_name', ''),
                    'nodes': 0, 'loc': 0,
                    'rules': nd.get('rule_count', 0),
                    'max_risk': nd.get('max_risk', 'SIN-DATOS'),
                }
            cap_agg[cap]['nodes'] += 1
            cap_agg[cap]['loc'] += nd.get('loc', 0)
            # escalate risk
            if _risk_rank(nd.get('max_risk', 'SIN-DATOS')) > _risk_rank(cap_agg[cap]['max_risk']):
                cap_agg[cap]['max_risk'] = nd.get('max_risk', 'SIN-DATOS')

    print(f'\n  TOTAL: {total_nodes} nodos | {total_loc:,} LOC\n')
    print(_sep())
    print(f"  {'BIAN ID':<8}  {'RIESGO MAX':<12}  {'NODOS':>5}  {'LOC':>8}  {'REGLAS':>6}  CAPACIDAD")
    print(_sep())
    for cap_id, info in sorted(cap_agg.items(), key=lambda x: -_risk_rank(x[1]['max_risk'])):
        print(f"  {cap_id:<8}  {_risk_badge(info['max_risk']):<12}  "
              f"{info['nodes']:>5}  {info['loc']:>8,}  {info['rules']:>6}  {info['cap_name']}")
    print(_sep('='))


def cmd_cap(graphs: list[dict], cap_id: str) -> None:
    cap_id = cap_id.upper()
    found: list[tuple[str, dict]] = []
    for g in graphs:
        for nd in g['nodes']:
            if nd.get('cap', '').upper() == cap_id:
                found.append((g['system'], nd))

    if not found:
        print(f'[WARN] No hay nodos para cap={cap_id}')
        return

    cap_name = found[0][1].get('cap_name', '')
    print(_sep('='))
    print(f'  CAPACIDAD {cap_id}  —  {cap_name}')
    print(f'  {len(found)} nodos  |  rules={found[0][1].get("rule_count",0)}')
    print(_sep('='))
    for sys_name, nd in sorted(found, key=lambda x: -_risk_rank(x[1].get('max_risk', 'SIN-DATOS'))):
        print(_node_row(nd, sys_name))
    print(_sep())
    total_loc = sum(nd.get('loc', 0) for _, nd in found)
    nt = sum(1 for _, nd in found if not nd.get('transpilable', True))
    print(f'  Total LOC: {total_loc:,}  |  NO-transpilable: {nt}')
    print(_sep('='))


def cmd_risk(graphs: list[dict], level: str) -> None:
    norm = _normalize_risk(level)
    if norm not in RISK_ORDER:
        print(f'[ERROR] Nivel desconocido: {level}')
        print(f'        Opciones: {", ".join(RISK_ORDER)}')
        sys.exit(1)
    threshold = _risk_rank(norm)
    found: list[tuple[str, dict]] = []
    for g in graphs:
        for nd in g['nodes']:
            if _risk_rank(nd.get('max_risk', 'SIN-DATOS')) >= threshold:
                found.append((g['system'], nd))

    print(_sep('='))
    print(f'  NODOS CON RIESGO >= {norm}  ({len(found)} total)')
    print(_sep('='))
    for sys_name, nd in sorted(
        found,
        key=lambda x: (-_risk_rank(x[1].get('max_risk', 'SIN-DATOS')), x[1].get('cap', ''))
    ):
        print(_node_row(nd, sys_name))
    print(_sep('='))


def cmd_path(graphs: list[dict], src: str, dst: str) -> None:
    # Build adjacency from all loaded graphs
    adj: dict[str, list[str]] = {}
    node_info: dict[str, dict] = {}

    for g in graphs:
        sys_name = g['system']
        for nd in g['nodes']:
            key = f"{sys_name}/{nd['id'].strip()}"
            node_info[key] = {**nd, '_system': sys_name}
            adj.setdefault(key, [])
        for e in g.get('edges', []):
            frm = f"{sys_name}/{e['from'].strip()}"
            to  = f"{sys_name}/{e['to'].strip()}"
            adj.setdefault(frm, []).append(to)
            adj.setdefault(to, [])  # ensure target exists

    # Resolve src / dst — allow bare id (ambiguous) or SYSTEM/id
    def resolve(name: str) -> list[str]:
        name = name.strip()
        if '/' in name:
            return [name] if name in node_info else []
        return [k for k in node_info if k.split('/', 1)[1] == name]

    srcs = resolve(src)
    dsts = resolve(dst)
    if not srcs:
        print(f'[ERROR] Nodo no encontrado: {src}')
        sys.exit(1)
    if not dsts:
        print(f'[ERROR] Nodo no encontrado: {dst}')
        sys.exit(1)

    dst_set = set(dsts)

    # BFS from first matching source
    start = srcs[0]
    queue: deque[list[str]] = deque([[start]])
    visited: set[str] = {start}
    path: list[str] | None = None

    while queue:
        current_path = queue.popleft()
        node = current_path[-1]
        if node in dst_set:
            path = current_path
            break
        for neighbor in adj.get(node, []):
            if neighbor not in visited:
                visited.add(neighbor)
                queue.append(current_path + [neighbor])

    print(_sep('='))
    if path is None:
        print(f'  No hay ruta entre {src} y {dst}')
    else:
        print(f'  RUTA: {src} -> {dst}  ({len(path)} saltos)')
        print(_sep())
        for step in path:
            nd = node_info.get(step, {})
            cap = nd.get('cap', '?')
            risk = _risk_badge(nd.get('max_risk', 'SIN-DATOS'))
            layer = nd.get('layer', '?')
            print(f"  {risk}  {step:<25}  {layer:<5}  cap={cap}")
    print(_sep('='))


def cmd_waves(graphs: list[dict]) -> None:
    """
    Sugiere agrupación de nodos en migration waves.

    Wave logic (heurística):
      W1 — NO-transpilable (RETAIN/ENCAPSULATE): se encapsulan, no se transpilan
      W2 — cap con riesgo DEFECTO-PROD o CRÍTICO: migrar al final, máxima validación
      W3 — cap con riesgo ALTO o MEDIO
      W4 — cap con riesgo BAJO o SIN-DATOS (más seguros para pilotar)

    Dentro de cada wave se agrupa por capacidad BIAN.
    """
    buckets: dict[str, list[tuple[str, dict]]] = {
        'W1-RETAIN': [], 'W2-HIGH-RISK': [], 'W3-MED-RISK': [], 'W4-LOW-RISK': []
    }

    for g in graphs:
        sys_name = g['system']
        for nd in g['nodes']:
            if not nd.get('transpilable', True):
                buckets['W1-RETAIN'].append((sys_name, nd))
            else:
                risk_rank = _risk_rank(nd.get('max_risk', 'SIN-DATOS'))
                if risk_rank >= _risk_rank('CRITICO'):
                    buckets['W2-HIGH-RISK'].append((sys_name, nd))
                elif risk_rank >= _risk_rank('MEDIO'):
                    buckets['W3-MED-RISK'].append((sys_name, nd))
                else:
                    buckets['W4-LOW-RISK'].append((sys_name, nd))

    descriptions = {
        'W1-RETAIN':   'Encapsular / RETAIN (no transpilable)',
        'W2-HIGH-RISK': 'Alta complejidad — transpilación con revisión exhaustiva',
        'W3-MED-RISK':  'Riesgo medio — transpilación asistida + equivalencia standard',
        'W4-LOW-RISK':  'Piloto — menor riesgo, primer bloque de transpilación',
    }

    print(_sep('='))
    print('  MIGRATION WAVES — sugerencia por riesgo y transpilabilidad')
    print(_sep('='))

    for wave_key, entries in buckets.items():
        if not entries:
            continue
        by_cap: dict[str, list] = {}
        for sys_name, nd in entries:
            cap = nd.get('cap', 'UNMAPPED')
            by_cap.setdefault(cap, []).append((sys_name, nd))

        total_loc = sum(nd.get('loc', 0) for _, nd in entries)
        print(f'\n  {wave_key}  —  {descriptions[wave_key]}')
        print(f'  {len(entries)} nodos | {total_loc:,} LOC')
        print(_sep('-', 70))
        for cap_id, cap_nodes in sorted(by_cap.items(), key=lambda x: x[0]):
            cap_name = cap_nodes[0][1].get('cap_name', '')
            cap_loc = sum(nd.get('loc', 0) for _, nd in cap_nodes)
            max_risk = max(cap_nodes, key=lambda x: _risk_rank(x[1].get('max_risk','')))[1].get('max_risk','?')
            ids = ', '.join(f"{s}/{nd['id'].strip()}" for s, nd in cap_nodes[:6])
            suffix = f'... +{len(cap_nodes)-6}' if len(cap_nodes) > 6 else ''
            print(f"    {cap_id:<8}  {_risk_badge(max_risk)}  {len(cap_nodes):>3} nodos  "
                  f"{cap_loc:>7,} LOC  {cap_name[:28]}")
            print(f"             {ids}{suffix}")
    print(_sep('='))


def cmd_transpilable(graphs: list[dict], value: bool) -> None:
    found: list[tuple[str, dict]] = []
    for g in graphs:
        for nd in g['nodes']:
            if nd.get('transpilable', True) == value:
                found.append((g['system'], nd))

    label = 'transpilables' if value else 'NO-transpilables'
    print(_sep('='))
    print(f'  NODOS {label.upper()}  ({len(found)} total)')
    print(_sep('='))
    for sys_name, nd in sorted(found, key=lambda x: x[1].get('cap', '')):
        print(_node_row(nd, sys_name))
    print(_sep('='))


# ── MAIN ──────────────────────────────────────────────────────────────────────

def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description='kg-query.py — Banamex GemCog Knowledge Graph CLI',
        formatter_class=argparse.RawTextHelpFormatter,
    )
    p.add_argument('--system', default='ALL', choices=['S500', 'S151', 'ALL'])
    p.add_argument('--cap',  metavar='BIAN_ID', help='Nodos de una capacidad BIAN')
    p.add_argument('--risk', metavar='LEVEL',   help='Nodos con riesgo >= nivel dado')
    p.add_argument('--path', nargs=2, metavar=('FROM', 'TO'), help='Ruta entre dos nodos')
    p.add_argument('--waves', action='store_true', help='Sugerir migration waves')
    p.add_argument('--summary', action='store_true', help='Stats generales')
    p.add_argument('--transpilable', metavar='true|false', help='Filtrar por transpilabilidad')
    return p.parse_args()


def main() -> None:
    args = parse_args()

    if not any([args.cap, args.risk, args.path, args.waves, args.summary, args.transpilable]):
        print(__doc__)
        sys.exit(0)

    graphs = load_graphs(args.system)

    if args.summary:
        cmd_summary(graphs)
    if args.cap:
        cmd_cap(graphs, args.cap)
    if args.risk:
        cmd_risk(graphs, args.risk)
    if args.path:
        cmd_path(graphs, args.path[0], args.path[1])
    if args.waves:
        cmd_waves(graphs)
    if args.transpilable:
        val = args.transpilable.strip().lower() in ('true', '1', 'yes')
        cmd_transpilable(graphs, val)


if __name__ == '__main__':
    main()
