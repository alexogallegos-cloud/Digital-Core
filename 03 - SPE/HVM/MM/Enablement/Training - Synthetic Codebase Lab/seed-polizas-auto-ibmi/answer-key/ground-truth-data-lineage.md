# Ground Truth — Data Lineage · SISTEMA-POLIZAS-AUTO

## POLMAST (Physical File)
- **Lee:** RPTSIN (indirecto vía SINIEST, no directo); POLACT (LF lo proyecta)
- **Escribe:** POLALT (INSERT vía embedded SQL)

## CLIMAST
- **Lee:** POLVAL (CHAIN por CLIID)
- **Escribe:** ninguno

## TARIFA
- **Lee:** PRIMCALC (CHAIN por TARTIPO)
- **Escribe:** ninguno

## SINIEST
- **Lee:** RPTSIN (READ secuencial)
- **Escribe:** ninguno en este subset

## POLACT (Logical File sobre POLMAST)
- **Acceso:** ningún programa del subset lo abre explícitamente. Existe como vista filtrada (RN-108). `[AMBIGUO esperado]` — RE debe notar que el LF define lógica pero no hay lector aún.

## Matriz CRUD
| Objeto | C | R | U | D | Programas |
|--------|:-:|:-:|:-:|:-:|-----------|
| POLMAST | ✓ | ✓ | | | POLALT (C), POLACT/RPTSIN (R) |
| CLIMAST | | ✓ | | | POLVAL |
| TARIFA | | ✓ | | | PRIMCALC |
| SINIEST | | ✓ | | | RPTSIN |