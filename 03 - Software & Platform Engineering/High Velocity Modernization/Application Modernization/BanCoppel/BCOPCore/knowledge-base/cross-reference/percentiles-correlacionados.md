# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.0.0 (P70/P90/P99 sobre ventanas de 1 h en régimen confiable; P99 = techo, P70/P90 derivados) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman (la suma combinada no es la métrica de
interés). **Todos los días** (SPEI y el Autorizador operan también el fin de semana), horario
operativo **13–22h**. Evolución **mensual**; el rango de meses se **auto-detecta** de los datos
(meses con ≥15 días completos), así que se extiende solo al cargar datos nuevos.

Tres umbrales por canal:

- **P99 — techo**: carga sostenida que solo se supera **1% del tiempo**; no se debe alcanzar de
  forma nominal. Es el ancla de dimensionamiento del target.
- **P90 — incidente** y **P70 — alerta**.

En el **régimen confiable** (desde el **leak-fix de mar-2026**) los tres salen de la **misma
distribución de ventanas de 1 hora sostenida** (promedio txn/min sobre 60 min): el P99 es el techo
y de esa distribución se **derivan** P70 y P90. **Antes** del fix, P70/P90 provienen de ventanas de
10 min (demanda histórica) y **no hay P99**: los encolamientos y el connection leak (INC-20251223)
distorsionaban el throughput medido, así que la cola alta de la distribución no es confiable.

> La **correlación** es lo que hace correlacionado al método: los picos de ambos canales coinciden
> en el tiempo (mismo perfil intradía, r≈0.99), no se diversifican y la carga se apila sobre Informix.
> **Zona de riesgo** = ambos canales ≥ su P70 a la vez.

## Umbrales actuales (último mes 2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 2,222 | 2,509 | 2,972 |
| Autorizador | 3,075 | 3,235 | 3,393 |

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
| 2025-01 | 1,675 | 2,038 | — | 2,590 | 2,698 | — |
| 2025-02 | 1,604 | 2,162 | — | 2,663 | 2,832 | — |
| 2025-03 | 1,668 | 2,218 | — | 2,746 | 2,906 | — |
| 2025-04 | 1,691 | 2,159 | — | 2,931 | 3,100 | — |
| 2025-05 | 1,754 | 2,274 | — | 2,798 | 2,967 | — |
| 2025-06 | 1,754 | 2,252 | — | 2,742 | 2,897 | — |
| 2025-07 | 1,849 | 2,153 | — | 2,706 | 2,816 | — |
| 2025-08 | 1,866 | 2,384 | — | 2,812 | 3,024 | — |
| 2025-09 | 1,913 | 2,405 | — | 2,832 | 2,982 | — |
| 2025-10 | 2,024 | 2,412 | — | 2,888 | 3,021 | — |
| 2025-11 | 1,998 | 2,645 | — | 2,983 | 3,255 | — |
| 2025-12 | 2,237 | 2,712 | — | 3,016 | 3,301 | — |
| 2026-01 | 1,975 | 2,508 | — | 2,766 | 2,920 | — |
| 2026-02 | 1,994 | 2,604 | — | 2,886 | 3,139 | — |
| 2026-03 | 1,994 | 2,422 | 2,973 | 3,002 | 3,152 | 3,308 |
| 2026-04 | 2,054 | 2,464 | 3,190 | 2,987 | 3,131 | 3,284 |
| 2026-05 | 2,125 | 2,578 | 3,153 | 3,069 | 3,230 | 3,336 |
| 2026-06 | 2,142 | 2,488 | 2,764 | 3,059 | 3,210 | 3,437 |
| 2026-07 | 2,222 | 2,509 | 2,972 | 3,075 | 3,235 | 3,393 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.0.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal ·
régimen confiable sobre ventanas de 1 h (P99 techo, P70/P90 derivados) · evolución mensual · gráfica
en `percentiles-correlacionados-evolucion.html`.*
