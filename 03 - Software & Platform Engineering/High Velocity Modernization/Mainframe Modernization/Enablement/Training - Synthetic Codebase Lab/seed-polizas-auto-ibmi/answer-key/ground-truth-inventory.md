# Ground Truth — Inventario Maestro · SISTEMA-POLIZAS-AUTO (IBM i / RPG)

> Verdad plantada. En test ciego NO entregar a RE; usar solo para scoring.

| ID | Nombre | Tipo | Atributo | LOC aprox | Descripción | Llamado por | Llama a | Estado |
|----|--------|------|----------|-----------|-------------|-------------|---------|--------|
| P101 | POLVAL | *PGM | RPGLE | 90 | Validación/autorización de póliza (orquestador) | PROCNOC | PRIMCALC, RIESGOEV | ✓ fuente |
| P102 | PRIMCALC | *PGM | RPGLE | 40 | Cálculo de prima | POLVAL | — | ✓ fuente |
| P103 | RIESGOEV | *PGM | RPGLE | 50 | Factor de riesgo | POLVAL | (dinámico) SCOREXT | ✓ fuente |
| P104 | POLALT | *PGM | SQLRPGLE | 35 | Alta de póliza | PROCNOC | — | ✓ fuente |
| P105 | RPTSIN | *PGM | RPG (fixed) | 40 | Reporte de siniestros | PROCNOC | — | ✓ fuente · indicadores |
| P106 | OLDPRIM | *PGM | RPGLE | 35 | Prima legacy (reemplazada) | **NADIE** | — | ✓ fuente · **DEAD CODE** |
| X101 | BCKPOL | *PGM | ? | — | Backup de POLMAST | PROCNOC | — | ✗ **SHADOW (sin fuente)** |
| C101 | PROCNOC | *PGM | CLLE | 30 | Proceso nocturno (orquestador CL) | Scheduler | POLVAL, POLALT, RPTSIN, BCKPOL | ✓ fuente |

## Objetos de base de datos
| Objeto | Tipo | Notas |
|--------|------|-------|
| POLMAST | *FILE PF | Maestro de pólizas |
| CLIMAST | *FILE PF | Maestro de clientes |
| TARIFA | *FILE PF | Tarifas por cobertura |
| SINIEST | *FILE PF | Siniestros |
| POLACT | *FILE LF | **Pólizas activas — SELECT/OMIT con regla de negocio (RN-108)** |

## Recuento esperado
- Programas RPG/SQLRPGLE/RPG-fixed con fuente: **6**
- CL con fuente: **1** (PROCNOC)
- Shadow (sin fuente): **1** (BCKPOL)
- Dead code: **1** (OLDPRIM)
- Physical Files: **4** · Logical Files: **1** (POLACT, con lógica implícita)