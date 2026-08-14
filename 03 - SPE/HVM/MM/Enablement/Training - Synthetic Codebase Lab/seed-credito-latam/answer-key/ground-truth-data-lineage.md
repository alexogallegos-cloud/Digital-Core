# Ground Truth — Data Lineage · SISTEMA-CREDITO-LATAM

> Espeja el "Data Lineage Map" (Etapa 2) del Specialist - Reverse Engineering.

## Tabla CLIENTES
- **Lee:** CREDVAL (SELECT por CLI_ID en 2000-VALIDA-CLIENTE)
- **Escribe:** ninguno en este subsistema

## Tabla CREDITOS
- **Lee:** RPTGEN (cursor C1, status AP)
- **Escribe:** CREDALT (INSERT en 0000-PRINCIPAL)

## Tabla LIMITES_CREDITO
- **Lee:** LIMCHK (vía copybook LIMCPY — acceso lógico al límite por producto)
- **Escribe:** ninguno

## Tabla HISTORIAL_PAGOS
- **Lee:** ninguno en el código emitido `[AMBIGUO esperado]` — tabla referenciada por el modelo pero sin lector en este subset; un RE honesto debe marcarla como acceso no documentado.
- **Escribe:** ninguno

## Matriz CRUD
| Tabla | C | R | U | D | Programas |
|-------|:-:|:-:|:-:|:-:|-----------|
| CLIENTES | | ✓ | | | CREDVAL |
| CREDITOS | ✓ | ✓ | | | CREDALT (C), RPTGEN (R) |
| LIMITES_CREDITO | | ✓ | | | LIMCHK |
| HISTORIAL_PAGOS | | | | | (sin acceso en el subset) |