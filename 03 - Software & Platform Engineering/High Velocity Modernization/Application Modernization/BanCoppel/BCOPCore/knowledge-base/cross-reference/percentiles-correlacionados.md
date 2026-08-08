# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.2.0 (P99 = techo medido sobre el pico diario; P90/P70 derivados proporcionalmente) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman (la suma combinada no es la métrica de
interés). **Todos los días** (SPEI y el Autorizador operan también el fin de semana), horario
operativo **13–22h**. Evolución **mensual**; el rango de meses se **auto-detecta** de los datos
(meses con ≥15 días completos), así que se extiende solo al cargar datos nuevos.

**El P99 es el techo medido**, y **P90/P70 se derivan proporcionalmente de él**:

- **P99 — techo**: el **pico diario** — la **hora de mayor carga sostenida** de cada día (mayor
  ventana de 1 h, promedio txn/min sobre 60 min, 13–22h) — superado solo **1% de los días** (el día
  peor). No se debe alcanzar de forma nominal. Es el ancla de dimensionamiento del target.
- **P90 — incidente** = **P99 × 90/99**. **P70 — alerta** = **P99 × 70/99**. Band uniforme y
  predecible bajo el techo, independiente de la forma real de la distribución.

El **techo (P99) solo se muestra desde el leak-fix de mar-2026** (régimen confiable): antes, el pico
diario está contaminado por los encolamientos y el connection leak (INC-20251223), así que no es
confiable. En pre-fix se muestran los P70/P90 **medidos** del pico diario como contexto (sin techo).

> La **correlación** es lo que hace correlacionado al método: los picos de ambos canales coinciden
> en el tiempo (mismo perfil intradía, r≈0.99), no se diversifican y la carga se apila sobre Informix.
> **Zona de riesgo** = ambos canales ≥ su P70 a la vez.

## Umbrales actuales (último mes 2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 2,258 | 2,903 | 3,193 |
| Autorizador | 2,432 | 3,127 | 3,440 |

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
| 2025-01 | 1,865 | 2,222 | — | 2,708 | 2,818 | — |
| 2025-02 | 1,862 | 2,347 | — | 2,817 | 2,913 | — |
| 2025-03 | 1,985 | 2,464 | — | 2,900 | 3,046 | — |
| 2025-04 | 1,958 | 2,280 | — | 3,068 | 3,266 | — |
| 2025-05 | 2,078 | 2,497 | — | 3,020 | 3,114 | — |
| 2025-06 | 2,081 | 2,489 | — | 2,889 | 3,013 | — |
| 2025-07 | 2,073 | 2,258 | — | 2,824 | 2,908 | — |
| 2025-08 | 2,136 | 2,702 | — | 2,965 | 3,095 | — |
| 2025-09 | 2,314 | 2,685 | — | 2,985 | 3,122 | — |
| 2025-10 | 2,295 | 2,448 | — | 3,041 | 3,119 | — |
| 2025-11 | 2,288 | 2,982 | — | 3,165 | 3,393 | — |
| 2025-12 | 2,547 | 2,870 | — | 3,148 | 3,601 | — |
| 2026-01 | 2,207 | 2,843 | — | 2,916 | 3,018 | — |
| 2026-02 | 2,276 | 2,914 | — | 3,014 | 3,254 | — |
| 2026-03 | 2,174 | 2,795 | 3,074 | 2,399 | 3,085 | 3,393 |
| 2026-04 | 2,697 | 3,468 | 3,815 | 2,369 | 3,045 | 3,350 |
| 2026-05 | 2,448 | 3,147 | 3,462 | 2,394 | 3,078 | 3,386 |
| 2026-06 | 2,531 | 3,254 | 3,579 | 2,484 | 3,194 | 3,513 |
| 2026-07 | 2,258 | 2,903 | 3,193 | 2,432 | 3,127 | 3,440 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.2.0 · Generado por generators/build-percentiles-correlacionados.py · P99 = techo medido (pico
diario, día peor); P90 = P99×90/99, P70 = P99×70/99 · por canal · evolución mensual · gráfica en
`percentiles-correlacionados-evolucion.html`.*
