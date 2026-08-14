#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
assign-scope.py — Asigna scope a los 83 términos con scope='—' en brain.db.
Lógica: distribución de dominios en sps.name + correcciones manuales de edge cases.
"""
import sqlite3, sys, re
sys.stdout.reconfigure(encoding='utf-8')
from collections import Counter

BASE = ("c:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Digital Core/"
        "03 - SPE/HVM/AM/BanCoppel/Informix/")
DB = BASE + "digital-brain/brain.db"

conn = sqlite3.connect(DB)
c = conn.cursor()

# Terms to SKIP (Ola A candidates — will be deleted, don't assign scope)
OLA_A_SKIP = {
    'consuta',       # typo of consulta
    'decodificar',   # infinitive duplicate of decodifica
    'inicializar',   # infinitive duplicate of inicializa
    'aplicar',       # infinitive duplicate of aplica
    'calcular',      # infinitive duplicate of calcula
    'consultar',     # infinitive duplicate of consulta
    'cobrar',        # infinitive duplicate of cobra
    'ejecutar',      # infinitive duplicate of ejecuta
    'generar',       # infinitive duplicate of genera
}

# Manual overrides (edge cases the algorithm gets wrong)
MANUAL = {
    'sp':           'TRANSVERSAL',   # prefix sp_ is used in all 49 databases
    'fn':           'TRANSVERSAL',   # SQL function prefix, global
    'ciloc':        'DOMINIO-D11',   # "consulta local de cobranza" — cobranza domain
    'fatca':        'TRANSVERSAL',   # US tax regulation affecting all account types
    'ivasart61':    'TRANSVERSAL',   # IVA Art.61 LIC — regulatory, all credit domains
    'mc':           'TRANSVERSAL',   # Mesa de Control appears in 8 domains
    'pp':           'TRANSVERSAL',   # Pago Programado in 9 domains
    'consreportes': 'DOMINIO-D01',   # compound: consulta+reportes, portal web
    'asiento':      'DOMINIO-D12',   # contabilidad domain
    'auditoria':    'TRANSVERSAL',   # audit crosses all domains by definition
    'autenticacion':'DOMINIO-D02',   # authn lives in integration domain
    'biometrico':   'DOMINIO-D02',   # biometric auth — integration
    'cedulas':      'DOMINIO-D02',   # cédulas de identificación — integration
    'codificacion': 'MIXTO',         # encoding utility, no clear domain
    'cjunk':        'TRANSVERSAL',   # temp var pattern found in 5+ domains
}

DB_DOM = {
    'bdicnweb':'D01','bdinteg':'D02','bdicred':'D03','bdicheq':'D04',
    'bdisac':'D05','bdisolic':'D06','bdiaclaracion':'D07','bdispei':'D08',
    'bdimnsj':'D09','bdisuc':'D10','bdicobranza':'D11','bdicont':'D12',
    'bditef':'D13','bdibei':'D14','bdilide':'D15','intercard':'D16',
    'bdibpi':'D17','intercardbpi':'D18','bditarjeta':'D19','bdiprog':'D20',
    'bdidomi':'D21','bditransfer':'D22','bdmis':'D23','bdiburo':'D24',
    'bdisitesp':'D25','bdiprospectos':'D26','bdiauditor':'D27','bdinvers':'D28',
    'bdiedoelec':'D29','bditarjcop':'D30','bdicntchq':'D31','bdireports':'D32',
    'bdimonitorcob':'D33','bdiresp':'D34','bdidigital':'D35','bdirepaut':'D36',
    'bdiadminnomina':'D37','bdicplbot':'D38','bdiservicios':'D39','bdibi':'D40',
    'bdicorresp':'D41','bdivr':'D42','bditrapres':'D43','bdirech':'D44',
    'bdiprem':'D45','bdiofi':'D46','bdigaran':'D47','bdiriesgos':'D48','bdirst':'D49',
}

c.execute("SELECT term, cat, meaning, est FROM terms WHERE scope='—' ORDER BY cat, term")
no_scope = [(r[0], r[1], r[2] or '', r[3]) for r in c.fetchall()]

c.execute('SELECT name, db FROM sps')
sps = c.fetchall()
tok_doms = {}
for sp_name, db in sps:
    parts = sp_name.lower().split('_')
    dom = DB_DOM.get(db, db)
    for p in parts:
        if len(p) >= 2:
            tok_doms.setdefault(p, set()).add(dom)

assignments = []
skipped = []
for term, cat, mean, est in no_scope:
    if term in OLA_A_SKIP:
        skipped.append(term)
        continue
    if term in MANUAL:
        scope = MANUAL[term]
    else:
        doms = tok_doms.get(term.lower(), set())
        n = len(doms)
        if cat == 'PREFIJO':
            scope = 'TRANSVERSAL'
        elif n >= 8:
            scope = 'TRANSVERSAL'
        elif n >= 3:
            scope = 'MIXTO'
        elif n == 2:
            scope = 'MIXTO'
        elif n == 1:
            dom = list(doms)[0]
            scope = f'DOMINIO-{dom}'
        else:
            if cat == 'REG':
                scope = 'TRANSVERSAL'
            elif cat in ('ACCION', 'MODIF'):
                scope = 'MIXTO'
            else:
                scope = 'MIXTO'
    assignments.append((term, scope, cat, mean[:60]))

# Print dry-run
print(f"\nDRY-RUN — {len(assignments)} asignaciones, {len(skipped)} skipped (Ola-A)\n")
by_scope = {}
for term, scope, cat, mean in assignments:
    by_scope.setdefault(scope, []).append((term, cat, mean))

for scope in sorted(by_scope.keys()):
    terms = by_scope[scope]
    print(f"\n{'='*60}")
    print(f"{scope} ({len(terms)} términos)")
    print(f"{'='*60}")
    for term, cat, mean in terms:
        print(f"  {term:25} [{cat:6}] {mean[:50]}")

print(f"\nSkipped (Ola-A): {skipped}")

# Apply to brain.db
print("\nAplicando a brain.db...")
updated = 0
for term, scope, cat, mean in assignments:
    c.execute("UPDATE terms SET scope=? WHERE term=? AND scope='—'", (scope, term))
    updated += c.rowcount
conn.commit()
conn.close()
print(f"Actualizados: {updated} términos")

# Scope distribution after
conn2 = sqlite3.connect(DB)
c2 = conn2.cursor()
c2.execute("SELECT scope, COUNT(*) FROM terms GROUP BY scope ORDER BY COUNT(*) DESC")
print("\nDistribucion final de scopes:")
for r in c2.fetchall():
    print(f"  {r[0]}: {r[1]}")
remaining = c2.execute("SELECT COUNT(*) FROM terms WHERE scope='—'").fetchone()[0]
print(f"\nTerminos restantes con scope='—': {remaining} (son los Ola-A que se eliminaran)")
conn2.close()
