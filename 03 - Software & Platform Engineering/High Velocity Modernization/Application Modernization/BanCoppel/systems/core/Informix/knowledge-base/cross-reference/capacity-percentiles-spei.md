# Capacidad de Carga — SPEI Entradas (txn/min, mes a mes)
> **Fuente**: pipeline `generators/forecast/capacity.py` sobre datos minuto-a-minuto
> **Versión**: 1.0.0 · 2026-08-07 · regenerable con datos nuevos
> **Proyecto**: BanCoppel Informix · SPE-AM-001

## Método

Percentiles de txn/min sobre la **ventana operativa inferida** (07:00–23:59,
donde el promedio por minuto supera el 25% del pico). No se usa la convención del cliente
(percentil sobre 1440 min) porque la madrugada muerta subvalúa el P70. Cada celda mensual es
la **mediana de los valores diarios** del mes; el "Pico del mes" es el minuto más alto observado.

## Carga mes a mes

| Mes | días | P70 | P90 | P99 | Máx diario (med) | Pico del mes |
|---|---|---|---|---|---|---|
| 2025-01 | 28 | 1,511 | 1,766 | 2,483 | 3,830 | 5,913 |
| 2025-02 | 28 | 1,495 | 1,929 | 2,603 | 3,935 | 5,634 |
| 2025-03 | 31 | 1,572 | 2,143 | 2,832 | 4,347 | 5,504 |
| 2025-04 | 29 | 1,735 | 2,197 | 2,966 | 4,824 | 7,690 |
| 2025-05 | 31 | 1,684 | 2,057 | 2,560 | 3,921 | 4,852 |
| 2025-06 | 29 | 1,618 | 1,902 | 2,349 | 4,031 | 6,761 |
| 2025-07 | 29 | 1,716 | 2,005 | 2,426 | 3,798 | 20,848 |
| 2025-08 | 30 | 1,732 | 2,070 | 2,501 | 3,546 | 4,481 |
| 2025-09 | 30 | 1,737 | 2,050 | 2,881 | 3,632 | 16,193 |
| 2025-10 | 30 | 1,815 | 2,252 | 2,982 | 3,606 | 3,688 |
| 2025-11 | 29 | 1,803 | 2,170 | 3,225 | 3,632 | 3,773 |
| 2025-12 | 28 | 1,980 | 2,921 | 3,289 | 3,639 | 32,153 |
| 2026-01 | 31 | 1,689 | 2,130 | 3,099 | 3,302 | 4,740 |
| 2026-02 | 28 | 1,754 | 2,056 | 3,066 | 3,379 | 6,242 |
| 2026-03 | 31 | 1,835 | 2,124 | 2,965 | 3,663 | 32,801 |
| 2026-04 | 30 | 1,906 | 2,154 | 3,006 | 3,615 | 8,932 |
| 2026-05 | 31 | 1,891 | 2,134 | 2,845 | 3,670 | 9,056 |
| 2026-06 | 30 | 1,918 | 2,179 | 2,836 | 3,491 | 11,318 |
| 2026-07 | 30 | 2,025 | 2,245 | 2,771 | 3,282 | 8,660 |
| 2026-08 | 4 | 1,986 | 2,225 | 2,988 | 3,690 | 6,398 |

**Crecimiento:** P70 +31% total (~+19%/año) · P90 +26% total (~+16%/año).

## Lectura

- La **carga típica (P70) y el pico típico (P90)** crecen ~+20%/año, en línea con el
  crecimiento orgánico de volumen — es **demanda**, no capacidad liberada por las mejoras.
- El **pico máximo diario típico** se mantiene plano (~3,300–3,900 txn/min): el día normal no
  demanda más en su pico. Como sí hay ráfagas muy por encima, **no hay techo duro** — hay headroom.
- Las **ráfagas** (abajo) son minutos aislados muy por encima del P99. El análisis muestra que
  son mayoritariamente **dispersiones masivas de entrada** (lotes de nómina/pagos que un
  originador envía en 1-2 minutos), no recuperación de colas: solo una minoría tiene valle
  previo. Son carga real instantánea que el target debe absorber, no artefactos.

## Ráfagas detectadas (minutos > 2.5× P99 del día)

| Fecha / hora | txn/min | × P99 | ¿recuperación? | ¿cerca de incidente? | calendario |
|---|---|---|---|---|---|
| 2026-03-03 Mar 17:04 | 32,801 | 10.2× | no | no | - |
| 2025-07-16 Mie 11:33 | 20,848 | 5.5× | no | no | - |
| 2026-03-03 Mar 17:03 | 18,570 | 5.8× | no | no | - |
| 2025-09-01 Lun 12:33 | 16,193 | 4.0× | no | no | - |
| 2025-12-05 Vie 10:59 | 12,730 | 3.5× | sí | no | - |
| 2026-06-08 Lun 13:24 | 11,318 | 4.3× | no | no | - |
| 2026-06-08 Lun 13:14 | 10,762 | 4.1× | no | no | - |
| 2025-12-19 Vie 14:55 | 9,409 | 2.6× | no | no | - |
| 2025-04-23 Mie 14:30 | 7,690 | 3.6× | no | no | - |
| 2026-03-18 Mie 19:18 | 7,429 | 2.8× | sí | no | - |
| 2026-03-24 Mar 19:07 | 7,227 | 3.2× | no | no | - |
| 2026-03-09 Lun 18:59 | 7,214 | 2.7× | no | no | - |
| 2026-03-18 Mie 19:19 | 6,793 | 2.6× | sí | no | - |
| 2026-03-18 Mie 19:20 | 6,793 | 2.6× | no | no | - |
| 2025-06-23 Lun 22:11 | 6,761 | 2.6× | no | no | - |
| 2025-01-29 Mie 19:13 | 5,538 | 2.5× | no | no | - |

## Implicación para la migración

Dimensionar el target por el **pico/min de día normal proyectado** (hoy ~3,690,
~+20%/año → H2-2027) **más** capacidad de absorber ráfagas de **entrada masiva** (dispersiones
de nómina/lotes, hasta ~32,801 txn/min observado ≈ 10× el P99). Las
mejoras del sistema se reflejan en *fiabilidad* (menos minutos en caída), no en el pico/min.

---

*v1.0.0 · 2026-08-07 · Generado por generators/build-capacity-spei.py.*
