# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.3.0 (percentiles OFICIALES del canal = máx histórico de P70/P90) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman (la suma combinada no es la métrica de
interés). **Todos los días** (SPEI y el Autorizador operan también el fin de semana), horario
operativo **13–22h**. Evolución **mensual**; el rango de meses se **auto-detecta** de los datos
(meses con ≥15 días completos), así que se extiende solo al cargar datos nuevos.

Los tres umbrales se calculan sobre el **pico diario**: para cada día se toma su **hora de mayor
carga sostenida** (mayor ventana de 1 h, promedio txn/min sobre 60 min, 13–22h), y los percentiles
se sacan sobre esos picos diarios del mes. Así los tres viven en el **régimen de carga alta** (no
diluidos por las horas medias del día):

- **P99 — techo**: el pico diario se supera solo **1% de los días** (el día peor); no se debe
  alcanzar de forma nominal. Es el ancla de dimensionamiento del target.
- **P90 — incidente**: superado **10% de los días**. **P70 — alerta**: superado **30% de los días**.

El **P99 solo se muestra desde el leak-fix de mar-2026** (régimen confiable): antes, el pico diario
está contaminado por los encolamientos y el connection leak (INC-20251223), así que su cola alta no
es confiable. Los P70/P90 (más robustos) se muestran en toda la serie.

> La **correlación** es lo que hace correlacionado al método: los picos de ambos canales coinciden
> en el tiempo (mismo perfil intradía, r≈0.99), no se diversifican y la carga se apila sobre Informix.
> **Zona de riesgo** = ambos canales ≥ su P70 a la vez.

## Percentiles OFICIALES por canal (máx histórico) — umbrales de referencia

Son la cifra oficial del canal: el **máximo histórico** de cada umbral sobre la evolución (el mismo
valor que dibuja curvas intradía como líneas de referencia). El P70 (alerta) y el P90 (incidente)
son los **percentiles oficiales** para operación; el P99 es el techo de dimensionamiento.

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 2,547 | 2,982 | 3,815 |
| Autorizador | 3,319 | 3,601 | 3,513 |

> Autorizador: su P90 y P99 quedan al mismo nivel (~3,600) porque **topa un techo real** y su carga
> está censurada en los picos (ver DT-Autorizador y `growth-forecast-autorizador-spei.md`).

Último mes (2026-07), como referencia de la tendencia: SPEI P70/P90 2,464/2,633,
Autorizador 3,319/3,391.

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
| 2026-03 | 2,443 | 2,730 | 3,074 | 3,176 | 3,293 | 3,393 |
| 2026-04 | 2,376 | 2,951 | 3,815 | 3,162 | 3,281 | 3,350 |
| 2026-05 | 2,443 | 2,911 | 3,462 | 3,237 | 3,334 | 3,386 |
| 2026-06 | 2,469 | 2,727 | 3,579 | 3,261 | 3,429 | 3,513 |
| 2026-07 | 2,464 | 2,633 | 3,193 | 3,319 | 3,391 | 3,440 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal
sobre el **pico diario** (hora de mayor carga sostenida de cada día; P99 = techo del día peor) ·
evolución mensual · gráfica en `percentiles-correlacionados-evolucion.html`.*
