#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
extract-vocabulary.py — Tokeniza identificadores ABAP y produce vocab-gentera.json
para el Gemelo Cognitivo Capa 1 (Lenguaje) de Gentera SAP.

Consume: objects-inventory.json (de parse-abap.py)
Produce: vocab-gentera.json

El JSON resultante es input directo para build-vocab-report.py.

Etapa 1-3 · GENCore · SPE-AM-002 · Gemelo Cognitivo SAP ABAP
"""
import json
import re
from collections import Counter
from pathlib import Path

BASE = Path(__file__).parent
INV_FILE  = BASE / "objects-inventory.json"
OUT_FILE  = BASE / "vocab-gentera.json"

# ── Reglas de clasificación ABAP ──────────────────────────────────────────────

# Tokens que son ACCIONES (verbos del dominio)
VERBS = {
    'GET','SET','IS','HAS','CAN','LOAD','SAVE','DELETE','UPDATE','INSERT','FETCH',
    'FIND','SEARCH','PROCESS','EXECUTE','RUN','INIT','RESET','CLEAR','COPY',
    'CONVERT','FORMAT','CALCULATE','COMPUTE','GENERATE','PARSE','READ','WRITE',
    'SEND','RECEIVE','HANDLE','MANAGE','MAINTAIN','CHECK','VALIDATE','CREATE',
    'BUILD','REFRESH','APPLY','ACTIVATE','DEACTIVATE','ENABLE','DISABLE',
    'OPEN','CLOSE','START','STOP','BEGIN','END','COMMIT','ROLLBACK',
}

# Tokens REGULATORIOS
REG = {
    'IFRS','CNBV','ISR','IVA','CONDUSEF','BANXICO','TESOFE','IPAB','SAT',
    'CNSF','PLD','AML','GDPR','PCI','SOX','BASEL','DORA','SBS','SIB',
    'CIRCULAR','REGULATORY','COMPLIANCE','AUDIT',
}

# Tokens PREFIJO (técnicos, no dominio de negocio)
PREFIJOS = {
    'DB','UI','BO','SRV','MDL','CTL','MSG','HELPER','EXCEPTION','INSTANCE','INST',
    'UTIL','UTILS','BASE','CORE','IMPL','FACTORY','SINGLETON','ABSTRACT',
    'SERVICE','MANAGER','HANDLER','PROXY','ADAPTER','BRIDGE','FACADE','STRATEGY',
    'INTERFACE','CALLBACK','LISTENER','OBSERVER','BUILDER','REGISTRY',
    'DISPATCHER','COORDINATOR','EXECUTOR','EVALUATOR','RESOLVER','PROVIDER',
    'CACHE','BUFFER','QUEUE','POOL','REPOSITORY','DAO','DTO','VO','PO',
    'API','RPC','HTTP','REST','SOAP','RFC',
}

# Tokens MODIFICADORES (modifican otros conceptos, no son entidades en sí mismos)
MODIFS = {
    'ALL','BY','NOT','FOUND','RANGE','HIGH','LOW','SINGLE','FIRST','LAST',
    'NEW','OLD','PREV','NEXT','MAIN','SUB','MASTER','DETAIL','HEADER',
    'ITEM','LINE','ENTRY','VALUE','TYPE','STATUS','FLAG','MODE','LEVEL',
    'KEY','CODE','NUM','NR','ID','ACTIVE','RESULT','MAIN','GLOBAL','LOCAL',
    'INTERNAL','EXTERNAL','PUBLIC','PRIVATE','PROTECTED','STATIC',
    'CURRENT','DEFAULT','INITIAL','EMPTY','NULL','VALID','INVALID',
    'SUCCESS','ERROR','FAIL','PENDING','DONE','OPEN','CLOSED','LOCKED',
    'SHORT','LONG','MAX','MIN','COUNT','SUM','AVG','TOTAL','PARTIAL',
}

# Tablas SAP estándar — no son vocabulario de dominio del cliente
SAP_STD_TABLES = {
    'TVARVC','TVARV','BAPIRET2','T000','MARC','MARA','BKPF','BSEG',
    'KNA1','LFA1','KNVV','VBAK','VBAP','EKKO','EKPO','MCHB','MSEG',
    'RBKP','RSEG','COAS','COSP','COSS','AFKO','AFPO','QMEL','QMFE',
    'MAKT','AUFK','PA0001','PA0002','PA0007','PA0008','T001','T001L',
    'DD02L','DD03L','TRDIR','TADIR','TFDIR','SXS_INTER','SXC_EXIT',
    'E070','E071','AGR_1251','USR02',
}

# Tokens SAP técnicos que no son vocabulario de negocio
SAP_TECHNICAL = {
    'TVARVC','TVARV','BAPIRET','BAPIRET2','BAPI','CLAS','PROG','FUGR','INTF',
    'DTEL','DOMA','TABL','METH','PROG','DEVC','MSAG','ENHA','SY','ABAP',
}


def strip_ns(name: str) -> str:
    return re.sub(r'^/[A-Z0-9]+/', '', name, flags=re.I)


def strip_obj_prefix(name: str) -> str:
    return re.sub(r'^(CL|IF|CX|TY|TT|AL|ZCL|ZIF|ZCX|ZTY|ZTT|MSG|CT)_', '', name, flags=re.I)


def strip_var_prefix(name: str) -> str:
    return re.sub(r'^(l[tvsorwcoxn]|g[tvsorwcoxn]|i[tvsorwcoxn]|e[tvsorwcoxn]|r[tvsorwcoxn]|c[tvsorwcoxn])_',
                  '', name, flags=re.I)


def tokenize(ident: str) -> list[str]:
    """
    Devuelve lista de tokens (partes) de un identificador ABAP.
    Aplica: strip namespace → strip var/obj prefix → split on _ → filtrar ruido.
    """
    s = strip_ns(ident)
    s = strip_obj_prefix(s)
    s = strip_var_prefix(s)
    parts = [p.upper() for p in s.split('_') if p]
    # Filtrar tokens muy cortos o puramente numéricos
    filtered = [p for p in parts if len(p) > 1 and not p.isdigit()]
    return filtered


def classify_token(tok: str) -> str:
    if tok in VERBS:    return 'ACCION'
    if tok in REG:      return 'REG'
    if tok in PREFIJOS: return 'PREFIJO'
    if tok in MODIFS:   return 'MODIF'
    if tok in SAP_TECHNICAL: return 'PREFIJO'
    if len(tok) <= 2:   return 'AMBIGUO'
    return 'ENTIDAD'


def classify_compound(tokens: list[str]) -> str:
    """Clasifica un término compuesto por la clase del primer token significativo."""
    for t in tokens:
        c = classify_token(t)
        if c != 'AMBIGUO':
            return c
    return 'AMBIGUO'


def confidence_from_cat(cat: str) -> tuple[str, str]:
    """(est, nivel) según categoría."""
    if cat == 'REG':     return 'conf', 'ALTA'
    if cat == 'ACCION':  return 'conf', 'ALTA'
    if cat == 'ENTIDAD': return 'inf',  'MEDIA'
    if cat == 'PREFIJO': return 'conf', 'MEDIA'
    if cat == 'MODIF':   return 'conf', 'MEDIA'
    return 'inf', 'AMBIGUA'


# ── extractor principal ───────────────────────────────────────────────────────

def extract(inv: dict) -> dict:
    # Contadores de frecuencia por token (en nombres/métodos/attrs/tipos/deps)
    fn_counter: Counter = Counter()   # frecuencia en nombres de identificador
    fp_counter: Counter = Counter()   # frecuencia en nombres de parámetros (futuro)

    # Identificadores compuestos (tokens > 1 parte)
    compounds_seen: dict[str, Counter] = {}  # nombre → counter de orígenes

    # Candidatos crudos (tablas SQL custom, tokens sin clasificar)
    candidatos_counter: Counter = Counter()

    for obj in inv.get('objetos', []):
        # Nombre de objeto
        bare = strip_ns(obj['nombre'])
        bare = strip_obj_prefix(bare)
        toks = tokenize(obj['nombre'])
        for t in toks:
            fn_counter[t] += 1
        if len(toks) > 1:
            key = '_'.join(toks)
            compounds_seen.setdefault(key, {'label': bare, 'toks': toks, 'count': 0})
            compounds_seen[key]['count'] += 1

        # Métodos
        for meth in obj.get('metodos', []):
            toks = tokenize(meth)
            for t in toks:
                fn_counter[t] += 1
            if len(toks) > 1:
                compounds_seen.setdefault(meth, {'label': meth, 'toks': toks, 'count': 0})
                compounds_seen[meth]['count'] += 1

        # Atributos
        for attr in obj.get('atributos', []):
            bare_attr = strip_var_prefix(attr)
            toks = tokenize(attr)
            for t in toks:
                fn_counter[t] += 1
            if len(toks) > 1:
                compounds_seen.setdefault(bare_attr, {'label': bare_attr, 'toks': toks, 'count': 0})
                compounds_seen[bare_attr]['count'] += 1

        # Tipos definidos
        for typ in obj.get('tipos', []):
            toks = tokenize(typ)
            for t in toks:
                fn_counter[t] += 1

    # Dependencias (targets de CALL FUNCTION, instantiate, catch, type_ref)
    for dep in inv.get('callgraph', []):
        target = dep.get('to', '')
        bare = strip_ns(target)
        bare = strip_obj_prefix(bare)
        toks = tokenize(target)
        for t in toks:
            fn_counter[t] += 1
        if len(toks) > 1:
            compounds_seen.setdefault(bare, {'label': bare, 'toks': toks, 'count': 0})
            compounds_seen[bare]['count'] += 1

    # Acceso SQL — tablas custom como candidatos, estándar SAP no
    for acc in inv.get('acceso', []):
        ent = acc.get('entidad', '').upper()
        if ent not in SAP_STD_TABLES and len(ent) > 2:
            candidatos_counter[ent] += 1
        elif ent in SAP_STD_TABLES:
            # Tabla SAP estándar referenciada → token con frecuencia pero en SAP_TECHNICAL
            fn_counter[ent] += 2  # peso extra porque es acceso real a DB

    # ── construir atomos ──────────────────────────────────────────────────────
    atomos = []
    for tok, cnt in fn_counter.most_common():
        if len(tok) <= 1 or tok.isdigit():
            continue
        cat = classify_token(tok)
        est, nivel = confidence_from_cat(cat)
        mean = _auto_meaning(tok, cat)
        atomos.append({
            'term' : tok,
            'cat'  : cat,
            'mean' : mean,
            'est'  : est,
            'nivel': nivel,
            'fn'   : cnt,
            'fp'   : fp_counter.get(tok, 0),
            'deco' : '',
            'scope': '—',
        })

    # ── construir compuestos ──────────────────────────────────────────────────
    compuestos = []
    seen_compound_terms = set()
    for key, info in sorted(compounds_seen.items(), key=lambda x: -x[1]['count']):
        label = info['label']
        if label in seen_compound_terms:
            continue
        seen_compound_terms.add(label)
        toks = info['toks']
        cat  = classify_compound(toks)
        est, nivel = confidence_from_cat(cat)
        deco = ' + '.join(toks)
        mean = _auto_meaning_compound(label, toks, cat)
        compuestos.append({
            'term' : label,
            'cat'  : cat,
            'mean' : mean,
            'est'  : est,
            'nivel': nivel,
            'fn'   : info['count'],
            'fp'   : 0,
            'deco' : deco,
            'scope': '—',
        })

    # ── construir candidatos ──────────────────────────────────────────────────
    candidatos = [{'frag': frag, 'frec': cnt}
                  for frag, cnt in candidatos_counter.most_common()
                  if cnt > 0]

    total_objetos = len(inv.get('objetos', []))
    return {
        'meta': {
            'sistema'   : inv['meta']['sistema'],
            'tecnologia': inv['meta']['tecnologia'],
            'namespace' : inv['meta'].get('namespace', '/CBB/'),
            'objetos'   : total_objetos,
            'sps'       : total_objetos,   # alias para compatibilidad con renderer
            'fecha'     : inv['meta'].get('fecha_extraccion', '2026-07-16'),
        },
        'atomos'    : atomos,
        'compuestos': compuestos,
        'candidatos': candidatos,
    }


def _auto_meaning(tok: str, cat: str) -> str:
    """Significado automático basado en token conocido o categoría."""
    KNOWN = {
        # Acciones
        'GET'       : 'obtener / recuperar',
        'SET'       : 'establecer / asignar',
        'IS'        : 'verificar si (booleano)',
        'HAS'       : 'verificar existencia de',
        'LOAD'      : 'cargar en memoria / inicializar',
        'SAVE'      : 'persistir en base de datos',
        'CREATE'    : 'crear nueva instancia',
        'DELETE'    : 'eliminar registro',
        'UPDATE'    : 'actualizar registro',
        'INSERT'    : 'insertar registro nuevo',
        'CHECK'     : 'validar / verificar condición',
        'VALIDATE'  : 'validar regla de negocio',
        'FIND'      : 'buscar / localizar',
        'PROCESS'   : 'procesar / ejecutar lógica de negocio',
        'EXECUTE'   : 'ejecutar operación',
        'CALCULATE' : 'calcular valor',
        'CONVERT'   : 'convertir / transformar',
        'BUILD'     : 'construir / ensamblar',
        'REFRESH'   : 'refrescar / recargar',
        # Entidades
        'EVENT'     : 'evento de negocio controlable (feature flag)',
        'NAME'      : 'nombre / identificador textual',
        'RANGE'     : 'rango de selección ABAP (SELECT-OPTIONS)',
        'RESULT'    : 'resultado de operación',
        'INSTANCE'  : 'instancia de objeto (patrón singleton)',
        'MESSAGE'   : 'mensaje de sistema / error',
        'EXCEPTION' : 'excepción / error manejado',
        # Modificadores
        'ALL'       : 'todos los registros (sin filtro)',
        'HIGH'      : 'valor límite superior (en rango de selección)',
        'LOW'       : 'valor límite inferior (en rango de selección)',
        'ACTIVE'    : 'activo / habilitado',
        'NOT'       : 'negación lógica',
        'FOUND'     : 'encontrado (o no encontrado como excepción)',
        'BY'        : 'filtrado / agrupado por criterio',
        # Técnicos SAP
        'DB'        : 'capa de acceso a base de datos (Database Access Object)',
        'TVARVC'    : 'tabla SAP estándar de criterios de selección variables',
        'TVARV'     : 'tabla SAP de variables de selección',
        'IFRS'      : 'IFRS 9 — International Financial Reporting Standards (regulatorio)',
        'CNBV'      : 'Comisión Nacional Bancaria y de Valores (regulatorio MX)',
        'SAT'       : 'Servicio de Administración Tributaria (regulatorio MX)',
        'CONDUSEF'  : 'Comisión Nacional para la Protección y Defensa de los Usuarios de Servicios Financieros',
        'INST'      : 'instancia (abreviatura técnica)',
        'HELPER'    : 'clase auxiliar de utilidad',
        'CN'        : '(abreviatura por confirmar — posiblemente "Contable Nueva" en contexto IFRS)',
    }
    if tok in KNOWN:
        return KNOWN[tok]
    if cat == 'ACCION':
        return f'(acción — confirmar semántica con SME)'
    if cat == 'ENTIDAD':
        return f'(entidad de negocio — confirmar significado con SME)'
    if cat == 'PREFIJO':
        return f'(prefijo técnico / patrón estructural)'
    if cat == 'MODIF':
        return f'(modificador — califica otra entidad o acción)'
    if cat == 'REG':
        return f'(término regulatorio — confirmar alcance con SME)'
    return '(sin clasificar)'


def _auto_meaning_compound(label: str, toks: list[str], cat: str) -> str:
    """Significado automático para un término compuesto."""
    KNOWN_COMPOUNDS = {
        'DB_TVARVC'          : 'Acceso a tabla TVARVC (DAO — Data Access Object sobre criterios de selección SAP)',
        'GET_ALL'            : 'Obtener todos los registros sin filtro',
        'GET_ALL_BY_NAME'    : 'Obtener todos los registros filtrados por nombre',
        'GET_BY_NAME_RANGE'  : 'Obtener registros cuyo nombre cae dentro de un rango de selección',
        'GET_BY_NAME'        : 'Obtener registro por nombre exacto',
        'IS_EVENT_ACTIVE'    : 'Verifica si un evento/proceso de negocio está activo (feature flag sobre TVARVC)',
        'IS_EVENT_ACTIVE_HIGH': 'Verifica si un evento de negocio está activo en su estado HIGH (nivel alto de activación)',
        'SET_ALL_BY_NAME'    : 'Establece/actualiza todos los valores filtrados por nombre',
        'LOAD_TVARVC'        : 'Carga la tabla TVARVC completa en cache de instancia',
        'S_GET_INSTANCE'     : 'Método estático que devuelve la instancia singleton (patrón Singleton)',
        'CX_DB_NOT_FOUND'    : 'Excepción: registro no encontrado en base de datos',
        'CL_EXCEPTION_HELPER': 'Clase auxiliar para gestión estandarizada de excepciones',
        'TY_TVARVC_RESULT'   : 'Tipo de datos resultado para operaciones sobre TVARVC',
        'TT_RANGE_NAME'      : 'Tipo tabla de rangos de selección por nombre (SELECT-OPTIONS)',
        'MSG_IFRS_CN'        : 'Clase de mensajes para módulo IFRS (International Financial Reporting Standards)',
        'GT_TVARVC'          : 'Tabla interna global con registros TVARVC',
        'GT_TVARVC_INST'     : 'Tabla interna global con instancia de registros TVARVC',
        'OG_INSTANCE'        : 'Referencia global a la instancia singleton de este DAO',
    }
    clean_label = re.sub(r'^(CL|IF|CX|TY|TT|CT|MSG|AL|GT|GV|GS|OG|LT|LV|LS)_', '', label)
    if label in KNOWN_COMPOUNDS:
        return KNOWN_COMPOUNDS[label]
    if clean_label in KNOWN_COMPOUNDS:
        return KNOWN_COMPOUNDS[clean_label]
    return f'({cat.lower()} — confirmar significado con SME)'


# ── main ──────────────────────────────────────────────────────────────────────

def main():
    if not INV_FILE.exists():
        print("WARN: objects-inventory.json no encontrado. Corre primero: python3 parse-abap.py")
        return

    inv = json.loads(INV_FILE.read_text(encoding='utf-8'))
    vocab = extract(inv)

    OUT_FILE.write_text(json.dumps(vocab, ensure_ascii=False, indent=2), encoding='utf-8')

    n_a = len(vocab['atomos'])
    n_c = len(vocab['compuestos'])
    n_k = len(vocab['candidatos'])
    print(f"OK  vocab-gentera.json  =>  {n_a} atomos | {n_c} compuestos | {n_k} candidatos")

    # Desglose por categoría
    from collections import Counter
    cat_count = Counter(r['cat'] for r in vocab['atomos'] + vocab['compuestos'])
    print(f"\nCategorias: {dict(cat_count)}")

    # Preview de REG tokens (regulatorio = alta sensibilidad)
    reg = [r for r in vocab['atomos'] if r['cat'] == 'REG']
    if reg:
        print(f"\nREGULATORIO detectado: {[r['term'] for r in reg]}")

    print(f"\nSiguiente paso: python3 build-vocab-report.py")


if __name__ == '__main__':
    main()