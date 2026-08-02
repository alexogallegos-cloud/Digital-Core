#!/usr/bin/env python3
"""
enrich-dependency-graphs.py  ·  GemCog Banamex  ·  2026-07-20
-----------------------------------------------------------------
Agrega a cada nodo de los dependency graphs:
  cap        — BIAN ID de la capacidad asignada
  cap_name   — nombre de la capacidad
  rule_count — número de reglas de la capacidad (de traceability-matrix)
  max_risk   — riesgo máximo encontrado en el cap file
  transpilable — False para ALGOLs marcados ⚠️ NO-TRANSPILABLE en S151

Fuentes:
  bian-mapping-s500.md  (tabla detallada "Programa | BIAN ID | ...")
  bian-mapping-s151.md  (tabla "| **P109** ⚠️... | ... | 7.1.1 | ...")
  traceability-matrix.md
  capacidades/cap-*.md  (busca emojis de riesgo en todo el archivo)

Salidas:
  data/S500/enriched-dependency-graph-s500.json
  data/S151/enriched-dependency-graph-s151.json
  enrichment-report.md
"""

import json
import re
from datetime import date
from pathlib import Path

BASE = Path(__file__).parent

# ── PRIORIDAD DE RIESGO ───────────────────────────────────────────────────────
RISK_ORDER = {
    'DEFECTO-PROD': 5,
    'CRÍTICO':      4,
    'ALTO':         3,
    'MEDIO':        2,
    'BAJO':         1,
    'SIN-DATOS':    0,
}

def risk_max(a: str, b: str) -> str:
    return a if RISK_ORDER.get(a, 0) >= RISK_ORDER.get(b, 0) else b


# ── PARSE BIAN MAPPING: tabla detallada (S500 y S151) ────────────────────────
# Formato S500: | Programa | Tipo | LOC  | Dominio S500 | BIAN ID | Capacidad BIAN | ...
# Formato S151: | **P109** | COBOL | 19,381 | CONTABILIDAD | 7.1.1 | Finance GL | ...
# Con posible prefijo "⚠️ NO-TRANSPILABLE" en S151

_TABLE_ROW = re.compile(
    r'^\|'
    r'\s*\*?\*?'
    r'([A-Z][A-Z0-9_]+)'                 # grupo 1: id del programa
    r'\*?\*?\s*'
    r'([^|]*?)\s*\|'                     # grupo 2: resto celda (flag NO-TRANSPILABLE si existe)
    r'\s*[A-Z]+\s*\|'                   # tipo (COBOL, ALGOL, WFL, ...)
    r'\s*[\d.,]+\s*\|'                  # LOC (. o , como separador de miles)
    r'\s*\w[\w\s]*?\|'                  # dominio
    r'\s*(T?[\d.]+)\s*\|'              # grupo 3: BIAN ID
    r'\s*([^|]+?)\s*\|',               # grupo 4: nombre capacidad
    re.MULTILINE,
)

def parse_bian_mapping(filepath: Path) -> dict:
    """Retorna {prog_id: {'cap', 'cap_name', 'transpilable'}}"""
    text = filepath.read_text(encoding='utf-8')
    result = {}
    for m in _TABLE_ROW.finditer(text):
        prog_id      = m.group(1).strip()
        rest_cell    = m.group(2).strip()  # contiene flag NO-TRANSPILABLE si aplica
        cap_id       = m.group(3).strip()
        cap_name     = m.group(4).strip()
        if cap_id in {'BIAN', 'ID', 'Capacidad', '---', 'BIAN ID'}:
            continue
        no_transpile = 'NO-TRANSPILABLE' in rest_cell
        result[prog_id] = {
            'cap':          cap_id,
            'cap_name':     cap_name,
            'transpilable': not no_transpile,
        }
    return result


# ── PARSE TRACEABILITY MATRIX ─────────────────────────────────────────────────
_TRACE_ROW = re.compile(
    r'^\|\s*(T?[\d.]+)\s*\|\s*[^|]+\|\s*(\d+)\s*\|',
    re.MULTILINE,
)

def parse_traceability() -> dict:
    """Retorna {'7.1.1': 635, 'T.3.4': 124, ...}"""
    text = (BASE / 'traceability-matrix.md').read_text(encoding='utf-8')
    result = {}
    for m in _TRACE_ROW.finditer(text):
        cap_id = m.group(1).strip()
        try:
            result[cap_id] = int(m.group(2))
        except ValueError:
            pass
    return result


# ── PARSE CAP FILES PARA RIESGO ──────────────────────────────────────────────
# Mapeo fijo cap-slug → BIAN ID (leído de las cabeceras de cada cap file)
CAP_SLUG_TO_BIAN: dict[str, str] = {
    'cap-adj': '6.7.1',   # P312→6.7.1; P330/P360→6.7.2 — usamos el principal
    'cap-cfr': 'T.4.1',
    'cap-cmp': '6.5.2',
    'cap-dep': '5.1.1',
    'cap-gl':  '7.1.1',
    'cap-hld': '4.1.2',
    'cap-int': '6.1.5',
    'cap-mq':  'T.2.3',
    'cap-ods': '9.1.1',
    'cap-orc': '6.7.2',
    'cap-pay': '6.1.3',
    'cap-rec': '6.7.1',
    'cap-rpt': 'T.3.4',
    'cap-sch': '8.1.1',
    'cap-sec': 'T.3.5',
    'cap-sta': '6.1.4',
    'cap-tar': '2.2.6',
    'cap-tel': '2.1.1',
}

_RISK_PATTERNS: list[tuple[str, str]] = [
    (r'🔴|DEFECTO-PROD|DEFECTO-PRODUCCIÓN',   'DEFECTO-PROD'),
    (r'🟠\s*CRÍTICO|(?<!\w)CRITICAL(?!\w)',    'CRÍTICO'),
    (r'🟡\s*ALTO|(?<!\w)HIGH(?!\w)',            'ALTO'),
    (r'🟡\s*MEDIO|(?<!\w)MEDIUM(?!\w)',         'MEDIO'),
    (r'🟢\s*BAJO|(?<!\w)LOW(?!\w)',             'BAJO'),
]

def parse_cap_risks() -> dict:
    """Retorna {'7.1.1': 'CRÍTICO', 'T.4.1': 'ALTO', ...}"""
    cap_dir = BASE / 'capacidades'
    result: dict[str, str] = {}

    for cap_file in sorted(cap_dir.glob('cap-*.md')):
        slug   = cap_file.stem
        cap_id = CAP_SLUG_TO_BIAN.get(slug)
        if not cap_id:
            print(f'  [WARN] sin BIAN ID para {slug} — omitido')
            continue

        text     = cap_file.read_text(encoding='utf-8', errors='ignore')
        max_risk = 'SIN-DATOS'
        for pattern, level in _RISK_PATTERNS:
            if re.search(pattern, text):
                max_risk = risk_max(max_risk, level)

        # cap-adj tiene doble mapeo; también registrar en 6.7.2
        if slug == 'cap-adj':
            result.setdefault('6.7.2', max_risk)

        result[cap_id] = max_risk

    return result


# ── ENRIQUECER UN GRAFO ───────────────────────────────────────────────────────
def enrich_graph(
    graph_path: Path,
    prog_map: dict,
    rule_counts: dict,
    cap_risks: dict,
) -> tuple[Path, dict]:

    with open(graph_path, encoding='utf-8') as f:
        graph = json.load(f)

    unmapped: list[str] = []
    enriched_count = 0

    for node in graph['nodes']:
        pid      = node['id'].strip()
        info     = prog_map.get(pid, {})
        cap_id   = info.get('cap', 'UNMAPPED')

        node['cap']        = cap_id
        node['cap_name']   = info.get('cap_name', '')
        node['rule_count'] = rule_counts.get(cap_id, 0)
        node['max_risk']   = cap_risks.get(cap_id, 'SIN-DATOS')

        if 'transpilable' in info:
            node['transpilable'] = info['transpilable']

        if cap_id != 'UNMAPPED':
            enriched_count += 1
        else:
            unmapped.append(pid)

    graph['_enriched'] = {
        'date':           str(date.today()),
        'script':         'enrich-dependency-graphs.py',
        'nodes_enriched': enriched_count,
        'nodes_total':    len(graph['nodes']),
    }

    out = graph_path.parent / graph_path.name.replace(
        'dependency-graph', 'enriched-dependency-graph'
    )
    with open(out, 'w', encoding='utf-8') as f:
        json.dump(graph, f, ensure_ascii=False, indent=2)

    stats = {
        'total':    len(graph['nodes']),
        'enriched': enriched_count,
        'unmapped': unmapped,
    }
    return out, stats


# ── REPORTE MARKDOWN ──────────────────────────────────────────────────────────
def write_report(all_stats: dict, rule_counts: dict, cap_risks: dict) -> None:
    lines = [
        '# Reporte de Enriquecimiento — Dependency Graphs',
        f'> Generado: {date.today()} · enrich-dependency-graphs.py\n',
        '## Cobertura de nodos\n',
        '| Sistema | Total | Enriquecidos | Sin cap | Cobertura |',
        '|---------|-------|--------------|---------|-----------|',
    ]
    for system, stats in all_stats.items():
        pct = round(stats['enriched'] / stats['total'] * 100, 1) if stats['total'] else 0
        lines.append(
            f"| {system} | {stats['total']} | {stats['enriched']} "
            f"| {len(stats['unmapped'])} | {pct}% |"
        )

    lines += [
        '',
        '## Capacidades — reglas y riesgo máximo\n',
        '| BIAN ID | Reglas | Riesgo Máx |',
        '|---------|--------|------------|',
    ]
    # Ordenar por riesgo desc, luego por reglas desc
    sorted_caps = sorted(
        rule_counts.items(),
        key=lambda x: (RISK_ORDER.get(cap_risks.get(x[0], 'SIN-DATOS'), 0), x[1]),
        reverse=True,
    )
    for cap_id, count in sorted_caps:
        risk = cap_risks.get(cap_id, 'SIN-DATOS')
        lines.append(f'| {cap_id} | {count} | {risk} |')

    for system, stats in all_stats.items():
        if stats['unmapped']:
            lines += [
                f'\n## Nodos sin capacidad BIAN — {system}\n',
                '> Estos programas no aparecen en las tablas de mapeo BIAN.',
                '> Candidatos a: WFL internos, stubs, librerías auxiliares.\n',
                '| Programa | Acción sugerida |',
                '|----------|-----------------|',
            ]
            for p in stats['unmapped']:
                lines.append(f'| `{p}` | Revisar en bian-mapping · posible WFL o stub |')

    (BASE / 'enrichment-report.md').write_text(
        '\n'.join(lines) + '\n', encoding='utf-8'
    )


# ── MAIN ──────────────────────────────────────────────────────────────────────
def main() -> None:
    print('=== enrich-dependency-graphs.py ================================')

    print('\n[1/4] Parseando BIAN mappings...')
    map_s500 = parse_bian_mapping(BASE / 'bian-mapping-s500.md')
    map_s151 = parse_bian_mapping(BASE / 'bian-mapping-s151.md')
    print(f'  S500: {len(map_s500)} programas')
    print(f'  S151: {len(map_s151)} programas')

    # Mostrar muestra de parseo para verificar
    sample_ids = list(map_s500.keys())[:3] + list(map_s151.keys())[:3]
    manual_overrides = {
        'P138': {'cap': '4.1.2', 'cap_name': 'Holdings', 'transpilable': True},
    }
    combined = {**map_s500, **map_s151, **manual_overrides}
    for pid in sample_ids:
        info = combined.get(pid, {})
        print(f'  {pid:30s} -> cap={info.get("cap","?"):8s} transpilable={info.get("transpilable","?")}')

    print('\n[2/4] Parseando traceability matrix...')
    rule_counts = parse_traceability()
    for cap_id, count in sorted(rule_counts.items()):
        print(f'  {cap_id:10s}: {count:4d} reglas')

    print('\n[3/4] Parseando riesgo máximo de cap files...')
    cap_risks = parse_cap_risks()
    for cap_id, risk in sorted(cap_risks.items()):
        print(f'  {cap_id:10s}: {risk}')

    print('\n[4/4] Enriqueciendo grafos...')

    out500, stats500 = enrich_graph(
        BASE / 'data/S500/dependency-graph-s500.json',
        combined, rule_counts, cap_risks,
    )
    pct500 = round(stats500['enriched'] / stats500['total'] * 100, 1)
    print(f'\n  S500: {stats500["enriched"]}/{stats500["total"]} nodos ({pct500}%) -> {out500.name}')
    if stats500['unmapped']:
        print(f'  Sin cap ({len(stats500["unmapped"])}): {", ".join(stats500["unmapped"][:8])}')

    out151, stats151 = enrich_graph(
        BASE / 'data/S151/dependency-graph-s151.json',
        combined, rule_counts, cap_risks,
    )
    pct151 = round(stats151['enriched'] / stats151['total'] * 100, 1)
    print(f'\n  S151: {stats151["enriched"]}/{stats151["total"]} nodos ({pct151}%) -> {out151.name}')
    if stats151['unmapped']:
        print(f'  Sin cap ({len(stats151["unmapped"])}): {", ".join(stats151["unmapped"][:8])}')

    write_report({'S500': stats500, 'S151': stats151}, rule_counts, cap_risks)
    print('\n  -> enrichment-report.md')
    print('\nListo.\n')


if __name__ == '__main__':
    main()
