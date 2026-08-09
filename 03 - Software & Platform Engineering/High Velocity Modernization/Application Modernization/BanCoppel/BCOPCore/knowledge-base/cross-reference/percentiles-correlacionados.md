# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.4.0 (percentiles OFICIALES = máx histórico de P70/P90 · **todos los umbrales con +10% de holgura**) · regenerable con `python generators/build-percentiles-correlacionados.py`

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
**Todos los valores incluyen un 10% de holgura** de dimensionamiento sobre la demanda observada.

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 2,802 | 3,280 | 4,196 |
| Autorizador | 3,651 | 3,961 | 3,864 |

> Autorizador: su P90 y P99 quedan al mismo nivel (~3,600) porque **topa un techo real** y su carga
> está censurada en los picos (ver DT-Autorizador y `growth-forecast-autorizador-spei.md`).

Último mes (2026-07), como referencia de la tendencia: SPEI P70/P90 2,710/2,896,
Autorizador 3,651/3,730.

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
| 2025-01 | 2,052 | 2,444 | — | 2,979 | 3,100 | — |
| 2025-02 | 2,048 | 2,582 | — | 3,099 | 3,204 | — |
| 2025-03 | 2,184 | 2,710 | — | 3,190 | 3,351 | — |
| 2025-04 | 2,154 | 2,508 | — | 3,375 | 3,593 | — |
| 2025-05 | 2,286 | 2,747 | — | 3,322 | 3,425 | — |
| 2025-06 | 2,289 | 2,738 | — | 3,178 | 3,314 | — |
| 2025-07 | 2,280 | 2,484 | — | 3,106 | 3,199 | — |
| 2025-08 | 2,350 | 2,972 | — | 3,262 | 3,405 | — |
| 2025-09 | 2,545 | 2,954 | — | 3,284 | 3,434 | — |
| 2025-10 | 2,524 | 2,693 | — | 3,345 | 3,431 | — |
| 2025-11 | 2,517 | 3,280 | — | 3,482 | 3,732 | — |
| 2025-12 | 2,802 | 3,157 | — | 3,463 | 3,961 | — |
| 2026-01 | 2,428 | 3,127 | — | 3,208 | 3,320 | — |
| 2026-02 | 2,504 | 3,205 | — | 3,315 | 3,579 | — |
| 2026-03 | 2,687 | 3,003 | 3,381 | 3,494 | 3,622 | 3,732 |
| 2026-04 | 2,614 | 3,246 | 4,196 | 3,478 | 3,609 | 3,685 |
| 2026-05 | 2,687 | 3,202 | 3,808 | 3,561 | 3,667 | 3,725 |
| 2026-06 | 2,716 | 3,000 | 3,937 | 3,587 | 3,772 | 3,864 |
| 2026-07 | 2,710 | 2,896 | 3,512 | 3,651 | 3,730 | 3,784 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal
sobre el **pico diario** (hora de mayor carga sostenida de cada día; P99 = techo del día peor) ·
evolución mensual · gráfica en `percentiles-correlacionados-evolucion.html`.*
