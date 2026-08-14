# Ground Truth — Inventario Maestro · SISTEMA-CREDITO-LATAM

> Verdad plantada. Espeja el "Inventario Maestro" (Etapa 0) del Specialist - Reverse Engineering.
> En un test ciego, NO entregar este archivo a RE; usarlo solo para scoring.

| ID | Nombre | Tipo | Plataforma | LOC aprox | Descripción | Copybooks | Llamado por | Llama a | Estado |
|----|--------|------|------------|-----------|-------------|-----------|-------------|---------|--------|
| P001 | CREDVAL | COBOL | z/OS | 175 | Validación de crédito (orquestador) | CLICPY, CREDCPY | PROCREDI/STEP010 | LIMCHK, SCOVAL | ✓ fuente |
| P002 | LIMCHK | COBOL | z/OS | 45 | Límite máximo por producto | LIMCPY | CREDVAL | — | ✓ fuente |
| P003 | SCOVAL | COBOL | z/OS | 40 | Obtiene score de buró | — | CREDVAL | (dinámico) BUROEXT1 | ✓ fuente |
| P004 | CREDALT | COBOL | z/OS | 50 | Alta de crédito aprobado | CREDCPY | PROCREDI/STEP020 | — | ✓ fuente |
| P005 | RPTGEN | COBOL | z/OS | 50 | Reporte mensual de créditos | CREDCPY, CLICPY | PROCREDI/STEP030 | — | ✓ fuente |
| P006 | OLDVAL | COBOL | z/OS | 35 | Validación legacy (reemplazada) | CREDCPY | **NADIE** | — | ✓ fuente · **DEAD CODE** |
| X001 | BCKPUTI | COBOL | z/OS | — | Backup de master | — | PROCREDI/STEP040 | — | ✗ **SHADOW (sin fuente)** |
| J001 | PROCREDI | JCL | z/OS | 40 | Job nocturno de originación | — | Scheduler | CREDVAL, CREDALT, RPTGEN, BCKPUTI | ✓ fuente |

## Recuento esperado
- Programas COBOL con fuente: **6** (CREDVAL, LIMCHK, SCOVAL, CREDALT, RPTGEN, OLDVAL)
- Programas referenciados sin fuente (shadow): **1** (BCKPUTI)
- JCL jobs: **1** (PROCREDI)
- Dead code: **1** (OLDVAL — sin llamada entrante de programa ni JCL)
- Copybooks: **3** (CREDCPY, CLICPY, LIMCPY)
- Tablas DB2: **4** (CLIENTES, CREDITOS, LIMITES_CREDITO, HISTORIAL_PAGOS)