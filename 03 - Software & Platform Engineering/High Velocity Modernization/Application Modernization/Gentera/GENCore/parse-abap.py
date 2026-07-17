#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
parse-abap.py — Extrae inventario de objetos ABAP desde GENCore/source/
Emite objects-inventory.json (contrato JSON normalizado §6 del Gemelo Cognitivo).

Consume: source/CLASS/*.abap  source/PROG/*.abap  source/FUGR/*.abap  (recursivo)
Produce: objects-inventory.json

Etapa 0 · GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""
import json
import re
from pathlib import Path

BASE   = Path(__file__).parent
SOURCE = BASE / "source"
OUT    = BASE / "objects-inventory.json"

NS_RE       = re.compile(r'^(/[A-Z0-9]+/)', re.I)
OBJ_PFX_RE  = re.compile(r'^(CL|IF|CX|TY|TT|AL|ZCL|ZIF|ZCX|ZTY|ZTT)_', re.I)
VAR_PFX_RE  = re.compile(r'^(l[tvsorwcoxn]|g[tvsorwcoxn]|i[tvsorwcoxn]|e[tvsorwcoxn]|r[tvsorwcoxn]|c[tvsorwcoxn])_', re.I)

SAP_STD_TABLES = {
    'TVARVC','TVARV','BAPIRET2','T000','MARC','MARA','BKPF','BSEG',
    'KNA1','LFA1','KNVV','VBAK','VBAP','EKKO','EKPO','MCHB','MSEG',
    'RBKP','RSEG','COAS','COSP','COSS','AFKO','AFPO','QMEL','QMFE',
    'MAKT','AUFK','PA0001','PA0002','PA0007','PA0008','T001','T001L',
}


def strip_ns(name: str) -> str:
    return NS_RE.sub('', name)


def parse_file(path: Path) -> dict:
    text  = path.read_text(encoding='utf-8', errors='replace')
    lines = text.splitlines()

    obj_type = path.parent.name.upper()   # CLASS, PROG, FUGR, INTF, …
    obj_name = _extract_obj_name(text, obj_type, path.stem)

    result = {
        'id'          : obj_name,
        'nombre'      : strip_ns(obj_name),
        'tipo'        : obj_type.lower(),
        'loc'         : len(lines),
        'dominio'     : '',
        'params'      : 0,
        'metodos'     : [],
        'atributos'   : [],
        'tipos'       : [],
        'dependencias': [],
        'acceso_sql'  : [],
        'headers'     : [],
        'archivo'     : str(path.relative_to(SOURCE)),
    }

    _extract_methods(text, result)
    _extract_attributes(text, result)
    _extract_types(text, result)
    _extract_dependencies(text, result)
    _extract_sql_access(text, result)
    _extract_author_headers(text, obj_name, result)

    result['params'] = len(result['metodos'])
    return result


# ── extractores internos ──────────────────────────────────────────────────────

def _extract_obj_name(text: str, obj_type: str, stem: str) -> str:
    # CLASS definition
    m = re.search(r'^\s*class\s+(/[A-Z0-9]+/)?([A-Z0-9_]+)\s+definition', text, re.I | re.M)
    if m:
        ns = (m.group(1) or '').strip('/')
        nm = m.group(2)
        return f"/{ns}/{nm}" if ns else nm

    # PROGRAM / REPORT
    m = re.search(r'^\s*(?:PROGRAM|REPORT)\s+(/[A-Z0-9]+/)?([A-Z0-9_]+)', text, re.I | re.M)
    if m:
        ns = (m.group(1) or '').strip('/')
        nm = m.group(2)
        return f"/{ns}/{nm}" if ns else nm

    # FUNCTION-POOL (function group)
    m = re.search(r'^\s*FUNCTION-POOL\s+(/[A-Z0-9]+/)?([A-Z0-9_]+)', text, re.I | re.M)
    if m:
        ns = (m.group(1) or '').strip('/')
        nm = m.group(2)
        return f"/{ns}/{nm}" if ns else nm

    # Fallback: derivar del nombre de archivo (_CBB_CL_DB_TVARVC → /CBB/CL_DB_TVARVC)
    raw = stem.lstrip('_')
    parts = raw.split('_', 1)
    if len(parts) == 2:
        return f"/{parts[0]}/{parts[1]}"
    return raw


def _extract_methods(text: str, result: dict) -> None:
    SKIP = {'CONSTRUCTOR','DESTRUCTOR','CLASS_CONSTRUCTOR','DEFINITION','IMPLEMENTATION','FOR'}
    for m in re.finditer(r'^\s*(?:class-)?methods?\s+([A-Z_][A-Z0-9_]*)', text, re.I | re.M):
        nm = m.group(1).upper()
        if nm not in SKIP and len(nm) > 1:
            result['metodos'].append(nm)
    result['metodos'] = list(dict.fromkeys(result['metodos']))    # dedup preserving order


def _extract_attributes(text: str, result: dict) -> None:
    for m in re.finditer(r'^\s*(?:class-)?data\s+([A-Z_][A-Z0-9_]*)\s+type', text, re.I | re.M):
        nm = m.group(1).upper()
        if len(nm) > 2:
            result['atributos'].append(nm)
    result['atributos'] = list(dict.fromkeys(result['atributos']))


def _extract_types(text: str, result: dict) -> None:
    for m in re.finditer(r'BEGIN\s+OF\s+([A-Z_][A-Z0-9_]*)', text, re.I):
        nm = m.group(1).upper()
        result['tipos'].append(nm)
    result['tipos'] = list(dict.fromkeys(result['tipos']))


def _extract_dependencies(text: str, result: dict) -> None:
    deps = []

    # CALL FUNCTION 'FNAME'
    for m in re.finditer(r"CALL\s+FUNCTION\s+'(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)'", text, re.I):
        target = m.group(1)
        tipo   = 'call_function_rfc' if _is_rfc_call(text, m.start()) else 'call_function'
        deps.append({'tipo': tipo, 'target': target})

    # CREATE OBJECT ... TYPE ClassName
    for m in re.finditer(r'CREATE\s+OBJECT\s+\w+\s+TYPE\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)', text, re.I):
        deps.append({'tipo': 'instantiate', 'target': m.group(1)})

    # lo = NEW ClassName(...)
    for m in re.finditer(r'\bNEW\s+(/[A-Z0-9]+/[A-Z0-9_]+|[A-Z0-9_]+)\s*\(', text, re.I):
        deps.append({'tipo': 'instantiate', 'target': m.group(1)})

    # CATCH cx_xxx / /ns/cx_xxx
    for m in re.finditer(r'\bCATCH\b((?:\s+(?:/[A-Z0-9]+/[A-Z0-9_]+|[A-Z][A-Z0-9_]*))+)', text, re.I):
        for tok in m.group(1).split():
            if tok.upper() not in ('INTO', 'BEFORE', 'AFTER') and len(tok) > 2:
                deps.append({'tipo': 'catch', 'target': tok})

    # TYPE /ns/typename  (custom types only — skip SAP prefixes like BAPIRET2_T)
    for m in re.finditer(r'\bTYPE\s+(/[A-Z0-9]+/[A-Z0-9_]+)', text, re.I):
        deps.append({'tipo': 'type_ref', 'target': m.group(1)})

    # /ns/msg_class usage in MESSAGE statements
    for m in re.finditer(r'MESSAGE\s+\w+\s*\((/[A-Z0-9]+/[A-Z0-9_]+)\)', text, re.I):
        deps.append({'tipo': 'message_class', 'target': m.group(1)})

    # Normalizar targets a uppercase + dedup
    seen = set()
    for d in deps:
        d['target'] = d['target'].upper()
        k = (d['tipo'], d['target'])
        if k not in seen:
            seen.add(k)
            result['dependencias'].append(d)


def _is_rfc_call(text: str, pos: int) -> bool:
    """Detecta si CALL FUNCTION tiene DESTINATION (= RFC externo)."""
    window = text[pos:pos+300]
    return bool(re.search(r'\bDESTINATION\b', window, re.I))


def _extract_sql_access(text: str, result: dict) -> None:
    sql_accesses = []

    # SELECT FROM table
    for m in re.finditer(r'\bFROM\s+([A-Z][A-Z0-9_]*)', text, re.I):
        tbl = m.group(1).upper()
        ctx = text[max(0, m.start()-150):m.start()].upper()
        if 'SELECT' in ctx:
            sql_accesses.append({'entidad': tbl, 'modo': 'R'})

    # UPDATE table SET / UPDATE table
    for m in re.finditer(r'\bUPDATE\s+([A-Z][A-Z0-9_]*)\b(?!\s+SET\s+DBNO)', text, re.I):
        tbl = m.group(1).upper()
        if tbl not in ('EXCEPTION', 'TABLE', 'SET', 'THE', 'ALL'):
            sql_accesses.append({'entidad': tbl, 'modo': 'W'})

    # INSERT INTO table
    for m in re.finditer(r'\bINSERT\s+(?:INTO\s+)?([A-Z][A-Z0-9_]*)', text, re.I):
        tbl = m.group(1).upper()
        if tbl not in ('INITIAL', 'REPORT', 'INTO'):
            sql_accesses.append({'entidad': tbl, 'modo': 'W'})

    # DELETE FROM table
    for m in re.finditer(r'\bDELETE\s+FROM\s+([A-Z][A-Z0-9_]*)', text, re.I):
        sql_accesses.append({'entidad': m.group(1).upper(), 'modo': 'W'})

    # Dedup (tabla + modo)
    seen = set()
    for s in sql_accesses:
        k = (s['entidad'], s['modo'])
        if k not in seen:
            seen.add(k)
            result['acceso_sql'].append({'entidad': s['entidad'], 'modo': s['modo'],
                                          'es_std': s['entidad'] in SAP_STD_TABLES})


def _extract_author_headers(text: str, obj_name: str, result: dict) -> None:
    """
    Extrae bloques de autoría de la forma:
    * Fecha Creación : DD.MM.YYYY
    * Autor          : Nombre
    * Usuario SAP    : USERID
    * OT y Tarea     : BSDK-XXXXX
    * ...
    """
    # Encontrar todos los bloques posibles (puede haber varios por método)
    blocks = list(re.finditer(
        r'(?:\*\s*Fecha Creaci[oó]n\s*:.*?(?=\*\*\*\*|\Z|\n\n|\bMETHOD\b|\bENDMETHOD\b))',
        text, re.I | re.S
    ))

    def _clean(s):
        return s.strip().rstrip('*').strip() if s else ''

    if not blocks:
        # intento más simple: buscar la primera aparición
        autor_m   = re.search(r'\*\s*Autor\s*:\s*(.+)',                  text, re.I)
        fecha_m   = re.search(r'\*\s*Fecha Creaci[oó]n\s*:\s*([0-9./]+)', text, re.I)
        usuario_m = re.search(r'\*\s*Usuario SAP\s*:\s*(\S+)',            text, re.I)
        proyecto_m= re.search(r'\*\s*(?:Desc\.\s*Solicitud|Proyecto)\s*:\s*(.+)', text, re.I)
        ot_m      = re.search(r'\*\s*OT y Tarea\s*:\s*(.+)',              text, re.I)
        sol_m     = re.search(r'\*\s*Solicitante\s*:\s*(.+)',             text, re.I)
        if autor_m or fecha_m:
            result['headers'].append({
                'objeto'     : obj_name,
                'autor'      : _clean(autor_m.group(1))    if autor_m    else '',
                'usuario_sap': _clean(usuario_m.group(1))  if usuario_m  else '',
                'fecha'      : _clean(fecha_m.group(1))    if fecha_m    else '',
                'proyecto'   : _clean(proyecto_m.group(1)) if proyecto_m else '',
                'ticket'     : _clean(ot_m.group(1))       if ot_m       else '',
                'solicitante': _clean(sol_m.group(1))      if sol_m      else '',
            })
        return

    # Si hay bloques por método, registrar el primero (suele ser el más rico)
    block = blocks[0].group(0)
    autor_m   = re.search(r'\*\s*Autor\s*:\s*(.+)',                  block, re.I)
    fecha_m   = re.search(r'\*\s*Fecha Creaci[oó]n\s*:\s*([0-9./]+)', block, re.I)
    usuario_m = re.search(r'\*\s*Usuario SAP\s*:\s*(\S+)',            block, re.I)
    proyecto_m= re.search(r'\*\s*(?:Desc\.\s*Solicitud|Proyecto)\s*:\s*(.+)', block, re.I)
    ot_m      = re.search(r'\*\s*OT y Tarea\s*:\s*(.+)',              block, re.I)
    sol_m     = re.search(r'\*\s*Solicitante\s*:\s*(.+)',             block, re.I)
    result['headers'].append({
        'objeto'     : obj_name,
        'autor'      : _clean(autor_m.group(1))    if autor_m    else '',
        'usuario_sap': _clean(usuario_m.group(1))  if usuario_m  else '',
        'fecha'      : _clean(fecha_m.group(1))    if fecha_m    else '',
        'proyecto'   : _clean(proyecto_m.group(1)) if proyecto_m else '',
        'ticket'     : _clean(ot_m.group(1))       if ot_m       else '',
        'solicitante': _clean(sol_m.group(1))      if sol_m      else '',
    })


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    objects = []
    abap_files = sorted(SOURCE.rglob('*.abap'))
    if not abap_files:
        print("WARN: No se encontraron archivos .abap en source/")
        print("   Carga los exports de SAP en source/CLASS/, source/PROG/, source/FUGR/")
        return

    print(f"Procesando {len(abap_files)} archivo(s) ABAP...\n")
    for path in abap_files:
        rel = path.relative_to(SOURCE)
        print(f"  >> {rel}")
        obj = parse_file(path)
        objects.append(obj)
        print(f"     {obj['tipo'].upper():8} {obj['id']:<40}  {obj['loc']:5} LOC  "
              f"{len(obj['metodos'])} métodos  {len(obj['dependencias'])} deps")

    # Construir contrato JSON normalizado (§6 metodologia-gemelo-cognitivo.md)
    callgraph = []
    acceso    = []
    headers   = []
    for obj in objects:
        for dep in obj['dependencias']:
            callgraph.append({'from': obj['id'], 'to': dep['target'], 'tipo': dep['tipo']})
        for sql in obj['acceso_sql']:
            acceso.append({'objeto': obj['id'], 'entidad': sql['entidad'],
                           'modo': sql['modo'], 'es_std': sql.get('es_std', False)})
        headers.extend(obj['headers'])

    connected = {e['from'] for e in callgraph} | {e['to'] for e in callgraph if any(
        o['id'] == e['to'] for o in objects)}

    output = {
        'meta': {
            'sistema'         : 'gentera-sap',
            'tecnologia'      : 'sap-abap',
            'namespace'       : '/CBB/',
            'objetos'         : len(objects),
            'conectados'      : len([o for o in objects if o['id'] in connected]),
            'fuente_evidencia': 'fuentes',
            'fecha_extraccion': '2026-07-16',
        },
        'objetos': [
            {
                'id'       : o['id'],
                'nombre'   : o['nombre'],
                'tipo'     : o['tipo'],
                'loc'      : o['loc'],
                'dominio'  : o['dominio'],
                'params'   : o['params'],
                'metodos'  : o['metodos'],
                'atributos': o['atributos'],
                'tipos'    : o['tipos'],
            }
            for o in objects
        ],
        'callgraph'   : callgraph,
        'acceso'      : acceso,
        'headers'     : headers,
        'hitos'       : [],
        'riesgos_tipo': [],
    }

    OUT.write_text(json.dumps(output, ensure_ascii=False, indent=2), encoding='utf-8')
    print(f"\nOK  objects-inventory.json  =>  {len(objects)} objetos | {len(callgraph)} deps | {len(headers)} headers de autoria")

    if headers:
        print("\nAutoria detectada:")
        for h in headers:
            print(f"  {h['objeto']}: {h['autor']} ({h['usuario_sap']}) | {h['fecha']} | {h['ticket']}")

    print(f"\nSiguiente paso: python3 extract-vocabulary.py")


if __name__ == '__main__':
    main()