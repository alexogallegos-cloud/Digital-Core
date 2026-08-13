"""Genera knowledge-base/batch-taxonomy.md desde brain.db tabla batch_analysis."""
import sqlite3, sys, os
sys.stdout.reconfigure(encoding='utf-8')

BASE    = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
DB_PATH = os.path.join(BASE, 'digital-brain', 'brain.db')
OUT     = os.path.join(BASE, 'knowledge-base', 'batch-taxonomy.md')

conn = sqlite3.connect(DB_PATH)
conn.row_factory = sqlite3.Row
def q(sql, *args): return conn.execute(sql, args).fetchall()

lines = []
def p(s=''): lines.append(s)

p('# Informix — Taxonomía Batch: Sub-arquetipos de SPs')
p()
p('> **Componente:** Informix · SPE-AM-001 · Etapa 1')
p('> **Generado:** 2026-08-09 · digital-brain/classify-batch.py')
p('> **Fuente:** brain.db tabla `batch_analysis` · 6,861 candidatos (fan_in=0 · role=internal · biz≠null · loc>100)')
p('> **SME responsable:** Specialist — Informix SPL Analysis · DBA IBM Informix')
p()
p('---')
p()
p('## Por qué los SPs batch son invisibles al call graph')
p()
p('Los SPs batch son invocados por un **scheduler externo** (cron AIX / UC4 / Control-M) — ningún otro SP los llama.')
p('Su `fan_in=0` los hace indistinguibles del código muerto en análisis estático.')
p('La diferencia es crítica: **código muerto = no migrar · batch = migrar como job**.')
p('El trigger NO es un SP — es el scheduler. Equivalente AWS: **EventBridge Scheduler**.')
p()
p('**Acción pendiente [SME-PENDING — DBA BanCoppel]:**')
p('```bash')
p('crontab -u informix -l   # inventario cron AIX')
p('grep -r "bdicred\|bdicnweb\|bdispei" /var/spool/cron/ 2>/dev/null')
p('```')
p()
p('---')
p()
p('## Distribución global L1')
p()
p('| Sub-arquetipo L1 | n | Confianza batch | Señal principal |')
p('|-----------------|---|----------------|-----------------|')
desc_l1 = {
    'FILE_LOADER':       ('ALTA',  'Usa `LOAD FROM filename` (Informix ETL desde filesystem AIX)'),
    'REPORT_AGGREGATOR': ('MEDIA', 'FOREACH masivo → escribe tablas de reporte, 0 calls externos'),
    'MASS_OPERATION':    ('ALTA',  'FOREACH ≥10 con cross-DB calls'),
    'DATA_MAINT':        ('MEDIA', 'Escribe tablas sin calls externos, loops moderados'),
    'ORCHESTRATOR':      ('MEDIA', 'Llama ≥2 SPs distintos'),
    'SINGLE_CALL':       ('MEDIA', 'Delega a exactamente 1 SP'),
    'PURGE_JOB':         ('ALTA',  'DELETE + INSERT a `_hist`'),
    'ACCOUNTING_JOB':    ('ALTA',  'Escribe a sx_contproc/sd_contproc + recibe pEmpresa'),
    'CONCILIACION':      ('MEDIA', 'Nombre contiene concilia/reconcil'),
    'CIERRE_CORTE':      ('ALTA',  'Nombre contiene cierre/corte + escrituras contables'),
    'NO_SOURCE':         ('—',     'Sin archivo SQL (D17-D49 o naming sin prefijo sp_)'),
    'UNKNOWN':           ('—',     'Señales insuficientes para clasificar'),
}
for r in q('SELECT archetype, COUNT(*) n FROM batch_analysis GROUP BY archetype ORDER BY n DESC'):
    conf, sig = desc_l1.get(r['archetype'], ('—', '—'))
    p(f'| `{r["archetype"]}` | {r["n"]} | {conf} | {sig} |')
p()
p('---')
p()
p('## FILE_LOADER — Segundo nivel (L2)')
p()
p('Usan `LOAD FROM /ruta/archivo ... INSERT INTO tabla` (ETL desde filesystem AIX).')
p()
p('| L2 | n | Riesgo | Descripción | Target AWS |')
p('|----|---|--------|-------------|------------|')
l2_fl = {
    'FL_REGULATORY':     ('ALTO',  'SPEI, CNBV, FATCA, Art.61 LIC, SAR, CONDUSEF', 'AWS Glue + S3 + EventBridge · SLA regulatorio'),
    'FL_CORRESPONDENT':  ('ALTO',  'CoDi, STP, Prosa, CoppelPay, redes de cobro',  'AWS Glue + S3 + SQS · coordinación proveedor'),
    'FL_PAYROLL':        ('MEDIO', 'Nómina, dispersión de pagos a empleados',        'AWS Glue + S3 + Step Function'),
    'FL_CATALOG':        ('MEDIO', 'Tasas, tarifas, parámetros, catálogos',          'Lambda + S3 staging · idempotente'),
    'FL_RECONCILIATION': ('MEDIO', 'Arqueo, conciliación de archivos, cuadre',       'Step Function · checkpoint por lote'),
    'FL_ACCOUNTS':       ('MEDIO', 'Cuentas, cheques, caja, efectivo',               'Lambda / ECS Fargate · bloqueo optimista'),
    'FL_CREDIT':         ('MEDIO', 'Crédito, cobranza, cartera, provisiones',        'Step Function · equivalencia exacta en montos'),
    'FL_OPERATIONAL':    ('—',     'Bucket residual — sin patrón específico',        'Revisar contra scheduler AIX'),
}
for r in q("SELECT l2_archetype, COUNT(*) n FROM batch_analysis WHERE archetype='FILE_LOADER' GROUP BY l2_archetype ORDER BY n DESC"):
    k = r['l2_archetype']
    rsk, d, t = l2_fl.get(k, ('—', '—', '—'))
    p(f'| `{k}` | {r["n"]} | {rsk} | {d} | {t} |')
p()
p('### FL_OPERATIONAL — Tercer nivel (L3)')
p()
p('| L3 | n | Descripción |')
p('|----|---|-------------|')
l3_flo = {
    'FLO_CREDIT_SCORING': 'Línea de crédito, scoring, buró',
    'FLO_ACTIVATION':     'Activación/desactivación de productos y servicios',
    'FLO_WORKFLOW':       'Solicitudes, flujos, mesa de control',
    'FLO_VALIDATION':     'Validación y verificación de datos',
    'FLO_CCL':            'Centro de llamadas / cobranza CCL',
    'FLO_NOTIFICATION':   'Notificaciones, SMS, correo electrónico',
    'FLO_CUSTOMER':       'Datos de cliente, domicilio, actualización',
    'FLO_ATM_POS':        'ATMs, terminales POS, cajeros',
    'FLO_TRANSFER':       'TEF, transferencias internas',
    'FLO_CAMPAIGN':       'Campañas de marketing y cobranza',
    'FLO_ONBOARDING':     'Apertura / alta de productos',
    'FLO_GENERIC':        'Sin patrón identificado — requiere scheduler AIX',
}
for r in q("SELECT l3_archetype, COUNT(*) n FROM batch_analysis WHERE l2_archetype='FL_OPERATIONAL' GROUP BY l3_archetype ORDER BY n DESC"):
    p(f'| `{r["l3_archetype"]}` | {r["n"]} | {l3_flo.get(r["l3_archetype"], "—")} |')
p()
p('---')
p()
p('## REPORT_AGGREGATOR — Segundo nivel (L2)')
p()
p('| L2 | n | Descripción | Target AWS |')
p('|----|---|-------------|------------|')
l2_ra = {
    'RA_REGULATORY':  ('Indicadores SPEI, cuentas PEI, regulación Banxico', 'Lambda + S3 + QuickSight · SLA regulatorio'),
    'RA_AUDIT':       ('Bitácora, log de operaciones, audit trail',          'Lambda + CloudWatch Logs · retención CNBV'),
    'RA_BRANCH':      ('Sucursales, cajeros, ATM, punto de venta',           'AWS Glue + S3 + QuickSight'),
    'RA_COLLECTION':  ('Cartera vencida, morosidad, cobranza',               'AWS Glue + S3 · Compliance CNBV'),
    'RA_CREDIT':      ('Crédito, líneas, FATCA, credenciales',               'AWS Glue + S3 · equivalencia exacta'),
    'RA_OPERATIONAL': ('Bucket residual',                                    'Revisar contra scheduler AIX'),
}
for r in q("SELECT l2_archetype, COUNT(*) n FROM batch_analysis WHERE archetype='REPORT_AGGREGATOR' GROUP BY l2_archetype ORDER BY n DESC"):
    k = r['l2_archetype']
    d, t = l2_ra.get(k, ('—', '—'))
    p(f'| `{k}` | {r["n"]} | {d} | {t} |')
p()
p('### RA_OPERATIONAL — Tercer nivel (L3)')
p()
p('| L3 | n | Descripción |')
p('|----|---|-------------|')
l3_rao = {
    'RAO_CCL':       'Call center / cobranza CCL / horarios / asesores',
    'RAO_CUSTOMER':  'Reportes de cliente, KYC, perfil',
    'RAO_PROCESS':   'Reportes de procesos y workflows',
    'RAO_PRODUCT':   'Reportes de productos financieros',
    'RAO_PARAMETER': 'Parámetros del sistema, configuración',
    'RAO_SYNC':      'Sincronización, integración, replicación',
    'RAO_WORKFORCE': 'Fuerza laboral, ejecutivos, empleados',
    'RAO_GENERIC':   'Sin patrón identificado — requiere scheduler AIX',
}
for r in q("SELECT l3_archetype, COUNT(*) n FROM batch_analysis WHERE l2_archetype='RA_OPERATIONAL' GROUP BY l3_archetype ORDER BY n DESC"):
    p(f'| `{r["l3_archetype"]}` | {r["n"]} | {l3_rao.get(r["l3_archetype"], "—")} |')
p()
p('---')
p()
p('## MASS_OPERATION — Segundo nivel (L2)')
p()
p('| L2 | n | Descripción | Target AWS |')
p('|----|---|-------------|------------|')
l2_mo = {
    'MO_PAYMENT':      ('Cargo/abono/cobro masivo de cuentas',     'Step Function · MONEY equivalencia exacta · DLQ'),
    'MO_BLOCK_CANCEL': ('Bloqueo/cancelación masiva de productos', 'Step Function · reversibilidad por lote'),
    'MO_NOTIFICATION': ('Alertas, SMS, correo masivo',             'Lambda + SNS/SES · idempotencia por mensaje'),
    'MO_ASSIGNMENT':   ('Asignación/reasignación de solicitudes',  'Lambda + SQS FIFO'),
    'MO_UPDATE':       ('Actualización masiva de registros',       'Lambda / ECS Fargate · checkpoint'),
    'MO_OTHER':        ('Bucket residual',                         'Revisar contra scheduler AIX'),
}
for r in q("SELECT l2_archetype, COUNT(*) n FROM batch_analysis WHERE archetype='MASS_OPERATION' GROUP BY l2_archetype ORDER BY n DESC"):
    k = r['l2_archetype']
    d, t = l2_mo.get(k, ('—', '—'))
    p(f'| `{k}` | {r["n"]} | {d} | {t} |')
p()
p('---')
p()
p('## Otros sub-arquetipos L1')
p()
p('| Sub-arquetipo | n | Descripción | Target AWS |')
p('|--------------|---|-------------|------------|')
others = [
    ('ACCOUNTING_JOB', 'Escribe a sx_contproc/sd_contproc + pEmpresa · cierre contable diario',  'Step Function secuencial · ventana exclusiva sobre sx_contproc'),
    ('PURGE_JOB',      'DELETE + INSERT a _hist · purga y archivado de datos históricos',         'Lambda paginada + DLQ · backup pre-purge en S3'),
    ('CIERRE_CORTE',   'Cierre/corte de período · escrituras contables finales del día',          'Step Function · ventana exclusiva nocturna'),
    ('CONCILIACION',   'Conciliación standalone · verifica cuadre entre tablas',                  'AWS Glue + S3 · comparador checksums'),
    ('DATA_MAINT',     'Mantiene tablas sin calls externos · loops moderados · validar scheduler', 'Lambda + EventBridge · idempotente'),
    ('ORCHESTRATOR',   'Llama ≥2 SPs distintos · puede ser online también · validar scheduler',   'Step Function o Lambda orquestadora'),
    ('SINGLE_CALL',    'Delega a exactamente 1 SP · posible wrapper batch sobre SP online',        'Lambda thin wrapper'),
]
for name, d, t in others:
    n = conn.execute(f"SELECT COUNT(*) n FROM batch_analysis WHERE archetype='{name}'").fetchone()['n']
    p(f'| `{name}` | {n} | {d} | {t} |')
p()
p('---')
p()
p('## SPs de alta confianza batch (388 SPs)')
p()
p('ACCOUNTING_JOB + PURGE_JOB + CIERRE_CORTE + CONCILIACION + FL_REGULATORY + FL_CORRESPONDENT +')
p('FL_PAYROLL + FL_RECONCILIATION + RA_REGULATORY + MO_PAYMENT + MO_BLOCK_CANCEL.')
p('Estos son los que más urgentemente requieren validación contra scheduler AIX.')
p()
p('| Arquetipo | L2 | Dominio | SP | LOC |')
p('|-----------|----|---------|----|-----|')
hc = q("""
    SELECT archetype, l2_archetype, domain, sp_name, loc
    FROM batch_analysis
    WHERE archetype IN ('ACCOUNTING_JOB','PURGE_JOB','CIERRE_CORTE','CONCILIACION')
       OR l2_archetype IN ('FL_REGULATORY','FL_CORRESPONDENT','FL_PAYROLL','FL_RECONCILIATION',
                           'RA_REGULATORY','MO_PAYMENT','MO_BLOCK_CANCEL')
    ORDER BY archetype, domain, sp_name
""")
for r in hc:
    l2 = r['l2_archetype'] or r['archetype']
    p(f'| `{r["archetype"]}` | `{l2}` | {r["domain"]} | `{r["sp_name"]}` | {r["loc"]} |')
p()
p('---')
p()
p('## Grupos funcionales conocidos (11 SPs validados en KB)')
p()
p('| Grupo | SPs | Arquetipo | Dominio | Riesgo |')
p('|-------|-----|-----------|---------|--------|')
known = [
    ('G1 Tasas/Admin',      'sp_adminitasas_cargarchivo, sp_admintasas_bitacoraerror, sp_admintasas_consultabitacora', 'FL_CATALOG',    'D01', 'MEDIO'),
    ('G2 Bitácora usuarios','sp_adm_consultabitacora_usuarios, sp_adm_consultabitacora_usuarios_totales',              'REPORT_AGGREGATOR','D01','MEDIO'),
    ('G3 Reportes sucursal','sp_actualizareportespendientesarqueosuc, sp_actualizareportespendientesentradasalida',     'FL_RECONCILIATION','D01','BAJO'),
    ('G4 Abono masivo',     'sp_abono_ref_masivo',                                                                     'FL_OPERATIONAL', 'D01','MEDIO'),
    ('G5 Reservas crédito', 'sp_actualiza_reserva_cierre, sp_adn_res_general',                                         'ACCOUNTING_JOB', 'D03','ALTO'),
    ('G6 Depuración SPEI',  'sp_depura_tbl_registro_msj',                                                              'PURGE_JOB',      'D08','ALTO'),
]
for grp, sps, arch, dom, risk in known:
    p(f'| {grp} | {sps} | `{arch}` | {dom} | {risk} |')
p()
p('---')
p()
p('## Pendientes críticos')
p()
p('- **[SME-PENDING — DBA BanCoppel]** Inventario scheduler AIX — sin este dato no se distingue batch real de código muerto.')
p('- **NO_SOURCE (1,092)** — SPs sin SQL encontrado: mayormente D17-D49 o naming sin prefijo `sp_`.')
p('- **FLO_GENERIC (1,248) + RAO_GENERIC (502) + MO_OTHER (401)** — buckets residuales, requieren scheduler AIX.')
p('- **D17-D49** — mapear en `DB_TO_DOMAIN` de build-brain.py para resolver NO_SOURCE y sp_capabilities gap.')
p()
p('---')
p()
p('## Cómo consultar en brain.db')
p()
p('```python')
p('from digital_brain.brain import BCOPBrain')
p('# O directamente:')
p('conn.execute("""')
p('    SELECT domain, db, sp_name, loc, archetype, l2_archetype, l3_archetype,')
p('           n_foreach, n_writes, n_calls, has_contproc, has_hist')
p('    FROM batch_analysis')
p('    WHERE archetype = \'ACCOUNTING_JOB\'')
p('    ORDER BY domain, sp_name')
p('""").fetchall()')
p('```')
p()
p('*Generado 2026-08-09 · classify-batch.py v1.0 · Signals: LOAD stmt · FOREACH count · cross-DB calls · write targets · name patterns*')

output = '\n'.join(lines)
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(output)
print(f'Escrito: {OUT}')
print(f'  {len(lines)} lineas · {len(output):,} chars')
conn.close()
