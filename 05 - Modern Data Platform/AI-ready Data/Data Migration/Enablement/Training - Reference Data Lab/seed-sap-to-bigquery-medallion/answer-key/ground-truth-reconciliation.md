# Ground Truth - Reconciliation (por capa)

> Conteos y sumas computados de los datos emitidos. seed=42.

## Conteo de filas por capa
| Capa | Tabla | # filas |
|------|-------|---------|
| bronze | kna1 | 200 |
| bronze | mara | 150 |
| bronze | makt | 257 |
| bronze | vbak | 1000 |
| bronze | vbap | 3550 |
| silver | customer | 185 |
| silver | material | 140 |
| silver | sales_order_header (limpio) | 986 |
| silver |   header en cuarentena | 14 |
| silver | sales_order_item (limpio) | 3517 |
| silver |   item en cuarentena | 28 |
| silver |   item duplicados removidos | 5 |
| gold | fact_sales_order_item | 3259 |

**Derivacion silver:**
- customer = bronze.kna1 - LOEKZ='X' (200 - 15 = 185)
- material = bronze.mara - LVORM='X' (150 - 10 = 140)
- sales_order_header limpio = bronze.vbak - (KUNNR nulo + KUNNR huerfano) (1000 - 14 = 986)
- sales_order_item limpio = bronze.vbap - duplicados - cuarentena FK/nulos (3550 - 5 - 28 = 3517)

## Reconciliacion de montos en GOLD (aplicando TCURX)
> net_amount_real = SUM(NETWR)/10^TCURX(moneda). La columna "naive (/100)" es lo que
> produce un pipeline que asume 2 decimales para TODAS las monedas: corrompe JPY/CLP.

| Moneda | TCURX dec | SUM real | SUM naive (/100) | Estado |
|--------|-----------|----------|-------------------|--------|
| CLP | 0 | 339082433.00 | 3390824.33 | TRAP x100 |
| EUR | 2 | 6572287.12 | 6572287.12 | OK |
| JPY | 0 | 590209104.00 | 5902091.04 | TRAP x100 |
| MXN | 2 | 30050674133.18 | 30050674133.18 | OK |
| USD | 2 | 19953195.18 | 19953195.18 | OK |

`[BENCHMARK]` El revelador: filas JPY/CLP pasan todos los DQ estructurales pero el
monto sale x100 si el pipeline no consulta TCURX. Solo se detecta en esta reconciliacion.
