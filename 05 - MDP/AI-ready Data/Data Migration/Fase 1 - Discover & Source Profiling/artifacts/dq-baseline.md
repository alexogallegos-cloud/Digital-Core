# Data Quality Baseline (descubierto)

> Issues DESCUBIERTOS por profiling, sin answer key (como en un engagement real).

| Hallazgo | # filas | Accion en target |
|---|---|---|
| Huerfanos bkkit.ACCT -> bkk_acct | 15 | FK; cuarentena en Silver |
| Huerfanos vdarl.PARTNER -> but000 | 3 | FK; cuarentena |
| Claves duplicadas bkkit | 8 | Dedup en Silver |
| Fechas invalidas '00000000' | 8 | DATS->NULL |
| Flags de borrado (XDELE/LOEVM) | 25 | Filtrar en Silver |
| bkk_acct.PARTNER nulo | 10 | Completeness; cuarentena |
| bkkit.AMOUNT nulo | 10 | Completeness; cuarentena |
| Filas en moneda 0-decimales CLP,JPY (trampa TCURX) | 530 | Conversion /10^TCURX; NUNCA /100 fijo |
| Pais CRM no-ISO (8 valores distintos) | 204 | Normalizar a ISO-2 |

**Valores de pais no-ISO encontrados:** `México` (41), `CHL` (20), `Mexico` (58), `Chile` (22), `United States` (14), `Estados Unidos` (11), `MEX` (24), `USA` (14)
