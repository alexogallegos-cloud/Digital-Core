# Performance Baseline — Autorizador de Pagos + SPEI Entrantes · BanCoppel
> **Fuente**: Análisis cuantitativo de dos datasets Excel:
>   - `Master_Transacciones minxmin_01-01-25 a 4-mar-26.xlsx` (615,619 filas E-Global; 610,681 filas SPEI; 2025-01-01 a 2026-03-04)
>   - `Transacciones_maestro_Medios_de_Pago.xlsx` (8 hojas; 2026-01-01 a 2026-08-04)
> **Versión**: 1.0.0 · 2026-08-07

---

## 1. Baseline de volumetría diaria (2025)

### E-Global (Autorizador de Pagos)

| Métrica | Valor | Período |
|---------|-------|---------|
| Total anual 2025 estimado | ~930M transacciones | 2025-01-01 a 2025-12-31 |
| Promedio diario | 2,465,419 txn/día | año completo |
| Máximo diario observado | 2,780,709 txn (23-DIC-2025) | p95 |
| Mínimo diario (días con carga) | ~1.6M txn/día | fines de semana |
| Pico por minuto observado | 5,147 txn/min | valor máximo absoluto 2025 |
| P99 por minuto | 3,400 txn/min | percentil de cola |
| P95 por minuto | ~3,100 txn/min | — |
| Capacidad declarada del Autorizador | 3,240 txn/min | según diagnóstico arquitectónico |

**Nota crítica**: el P99 por minuto (3,400) supera la capacidad declarada del Autorizador (3,240). Esto significa que en el 1% del tiempo el sistema operaba por encima de su capacidad teórica — lo que explica por qué los incidentes ocurrían en días de alta concurrencia.

### SPEI Entrantes

| Métrica | Valor | Período |
|---------|-------|---------|
| Total acumulado (2025-01-01 a 2026-03-04) | 660,793,298 txn | 425 días |
| Promedio diario | 1,554,808 txn/día | — |
| Máximo diario | ~2,543,037 txn (15-DIC-2025, p99) | quincena diciembre |
| Pico por minuto absoluto | 32,801 txn/min | 18-DIC-2025 (anomalía aguinaldo) |
| P99 por minuto | 3,272 txn/min | percentil de cola |
| P95 por minuto | ~2,800 txn/min | — |

**Nota sobre el pico de 32,801 txn/min (18-DIC)**: anomalía de aguinaldo — volumen 10x sobre el P99. Este pico es el que provocó el forking a 72 procesos SPEI en AIX.

---

## 2. Baseline de volumetría diaria (2026 — enero a agosto)

### E-Global (2026)

| Métrica | Valor | Período |
|---------|-------|---------|
| Promedio diario enero 2026 | ~2,443,000 txn/día | enero 2026 |
| Promedio diario julio 2026 | ~2,647,000 txn/día | julio 2026 |
| Crecimiento enero→julio 2026 | **+12%** | 7 meses |
| P99 por minuto (2026) | 3,400 txn/min | consistente con 2025 |
| Pico máximo absoluto (2026) | 4,346 txn/min | — |

**Tendencia**: E-Global creció ~12% en 7 meses (enero-julio 2026). A esta tasa, para enero 2027 el promedio diario superará los 2.7M txn/día, lo que elevaría el P99 por minuto por encima de los 3,600 txn/min — superando la capacidad del Autorizador en más de un 10%.

### SPEI (2026)

| Canal | Promedio diario 2026 | Ratio |
|-------|---------------------|-------|
| SPEI Entradas | 1,732,125 txn/día | — |
| SPEI Salidas | 1,439,320 txn/día | — |
| Balance neto | +292,805 txn/día entrantes | BanCoppel es receptor neto |
| Ratio entradas/salidas | **1.197x** | consistente en todo 2026 |

BanCoppel recibe consistentemente un 20% más de SPEI del que envía — es un banco receptor neto de pagos, lo que tiene implicaciones para el dimensionamiento del target: el flujo entrante siempre será mayor que el saliente.

---

## 3. Días de máximo riesgo (ventanas sin cutover)

Estos días y períodos deben excluirse del calendario de cutover y parallel-run por riesgo de saturación:

| Tipo de día | Descripción | Riesgo |
|-------------|-------------|--------|
| **Quincena** (días 15 y último de cada mes) | Pago de nómina — pico SPEI p85-p99 | CRÍTICO — ventana prohibida para cutover |
| **Aguinaldo** (7-20 diciembre) | Pago de prima vacacional + aguinaldo | CRÍTICO — semana más peligrosa del año |
| **Fin de mes de diciembre** (31-DIC) | Cierre de año + servicios + liquidaciones | CRÍTICO |
| **Semana Santa** (martes-jueves) | Liquidaciones pre-vacacional | ALTO |
| **Día de pago del IMSS** (días 17 y 2) | Pagos de seguridad social | ALTO |
| Primer día hábil tras días festivos | Cola de transacciones represadas | MEDIO-ALTO |

**Ventana recomendada para cutover**: semanas del día 5 al 12 de cualquier mes no festivo, fuera de diciembre y semana santa. Martes o miércoles son días de menor riesgo dentro de la semana.

---

## 4. Comparativa de los 7 incidentes contra percentiles

| Fecha | E-Global pct | SPEI pct | Duración | Causa dominante |
|-------|-------------|---------|----------|-----------------|
| 29-NOV-2025 | p94 | p93 | 4.5 h | Saturación concurrente |
| 15-DIC-2025 | p87 | **p99** | 7.5 h | hdisk3 + saturación total |
| 17-DIC-2025 | p64 | p28 | 5.7 h | Estado degradado residual |
| 21-DIC-2025 | p59 | p35 | 1.5 h | Carga moderada + leak inicial |
| 23-DIC-2025 | p95 | p78 | 23 min | Connection leak (identificado) |
| 31-DIC-2025 | p89 | p81 | 3.9 h | Connection leak sistémico (5 episodios) |
| 12-ENE-2026 | **p15** | p48 | 6.58 h | Connection leak permanente |

La correlación entre percentil y duración se rompe en el 12-ENE: con el menor percentil de la serie, la duración fue la segunda más larga. Esto confirma que el sistema pasó de un problema de capacidad (Nov-Dic) a un problema de deuda técnica acumulada (enero).

---

## 5. ATM / Cajeros propios (contexto)

| Métrica | Valor | Período |
|---------|-------|---------|
| Promedio diario | 866,634 txn/día | mayo-julio 2026 |
| Rango operacional | ~300K – 1.8M txn/día | — |
| Relevancia para incidentes | Bajo — no comparte el path de autorización E-Global/SPEI |

Los cajeros propios compiten por recursos Informix en la capa de OLTP, pero no pasan por el Autorizador E-Global. Su impacto en los incidentes documentados es marginal comparado con SPEI y E-Global.

---

## 6. Dimensionamiento del target

Con base en la volumetría actual y la tendencia de crecimiento, el target debe dimensionarse para:

| Parámetro | Baseline 2025 | Proyección 2027 (+24%) | Recomendación target |
|-----------|--------------|------------------------|----------------------|
| E-Global txn/min P99 | 3,400 | ~4,200 | Pool de conexiones ≥ 50 · escalamiento automático hasta 100 |
| SPEI entrantes txn/min P99 | 3,272 | ~4,050 | Instancias de microservicio SPEI con autoscaling HPA |
| Concurrencia total (SPEI + E-Global + ATM) | ~6,700 txn/min P99 | ~8,300 txn/min | Connection pool agregado ≥ 100 conexiones al backend BD |
| Latencia máxima E-Global SLA | 8 segundos (actual) | 8 segundos (SLA vigente) | Target debe responder en ≤ 4s en P95 para mantener margen 50% |

---

## 7. Criterios go/no-go del parallel-run (basados en este baseline)

El parallel-run del Autorizador y SPEI modernizados debe superar los siguientes criterios:

| Criterio | Umbral | Justificación |
|----------|--------|---------------|
| Sin degradación funcional en E-Global P99 | 0 transacciones canceladas por timeout en sesión sostenida de 4h con carga P99 | Réplica del escenario de los incidentes |
| Sin connection leak en 72h sostenidas | 0 reinicios manuales necesarios | Criterio derivado del INC-20260112 |
| Latencia P95 E-Global ≤ 4 segundos | 4s en P95 | Mitad del SLA de 8s para margen de seguridad |
| Equivalencia funcional SPEI ≥ 99.99% | Derivado de Banxico regulatorio | Más estricto que el 99.95% general AM |
| Recuperación post-pico < 60 segundos | Queue vacía en < 60s después del pico | Contrasta con los 6.58h del INC-20260112 |

---

*v1.0.0 · 2026-08-07 · Fuente: Master_Transacciones (2025-01-01 a 2026-03-04) + Medios_de_Pago (2026-01-01 a 2026-08-04) · Período analizado: 428 días E-Global + 425 días SPEI + 215 días E-Global 2026*
