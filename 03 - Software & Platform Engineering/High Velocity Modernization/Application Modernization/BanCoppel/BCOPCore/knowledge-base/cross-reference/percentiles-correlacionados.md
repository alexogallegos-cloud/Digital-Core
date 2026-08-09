# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.7.0 (percentil sobre TODOS los minutos 13-22h · oficiales = valores CONFIRMADOS por el cliente) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman. **Todos los días** (ambos operan también el
fin de semana), horario operativo **13–22h**.

Los umbrales son el **percentil sobre TODOS los minutos** de la ventana operativa (la base que usa
el cliente): **P70 = carga típica** (el 70% de los minutos está por debajo), **P90 = carga alta**,
**P99 = pico**. La evolución mensual es el percentil por mes; el pooled (agrupado sobre todo el
histórico) da la referencia. Esta base reproduce las cifras confirmadas por el cliente.

El **P99 solo se muestra desde el leak-fix de mar-2026** (antes está contaminado por los encolamientos
y el connection leak, INC-20251223).

> **Correlación**: los picos de ambos canales coinciden en el tiempo (perfil intradía r≈0.99), no se
> diversifican y la carga se apila sobre Informix. **Zona de riesgo** = ambos ≥ su P70 a la vez.

## Percentiles OFICIALES por canal — valores CONFIRMADOS por el cliente

Los umbrales oficiales son los **valores confirmados por el cliente** (baseline **dic-2025 a feb-2026**,
base all-minutes 13–22h): **P70 = carga típica** (alerta), **P90 = carga alta** (incidente). El P99
(techo de dimensionamiento) es el percentil 99 agrupado del histórico. Son las **líneas de referencia**
de curvas intradía y el **umbral de detección** del calendario de riesgo. (Holgura de dimensionamiento
del target, si se requiere, se aplica aparte — no se infla el dato confirmado.)

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 2,080 | 3,240 | 3,798 |
| Autorizador | 3,000 | 3,500 | 3,500 |

> Autorizador: su P90 y P99 quedan casi al mismo nivel (~3,500) porque **topa un techo real** y su
> carga está censurada en los picos (ver DT-Autorizador y `growth-forecast-autorizador-spei.md`).

Último mes (2026-07), como referencia de la tendencia: SPEI P70/P90 2,205/2,606,
Autorizador 3,096/3,260.

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
| 2025-01 | 1,678 | 2,229 | — | 2,577 | 2,710 | — |
| 2025-02 | 1,709 | 2,509 | — | 2,662 | 2,847 | — |
| 2025-03 | 1,801 | 2,631 | — | 2,743 | 2,918 | — |
| 2025-04 | 1,833 | 2,595 | — | 2,927 | 3,113 | — |
| 2025-05 | 1,848 | 2,443 | — | 2,805 | 2,973 | — |
| 2025-06 | 1,844 | 2,309 | — | 2,735 | 2,904 | — |
| 2025-07 | 1,894 | 2,253 | — | 2,715 | 2,833 | — |
| 2025-08 | 1,944 | 2,444 | — | 2,817 | 3,026 | — |
| 2025-09 | 1,958 | 2,533 | — | 2,835 | 2,999 | — |
| 2025-10 | 2,010 | 2,630 | — | 2,892 | 3,036 | — |
| 2025-11 | 2,021 | 3,038 | — | 2,984 | 3,256 | — |
| 2025-12 | 2,302 | 3,094 | — | 3,007 | 3,283 | — |
| 2026-01 | 1,933 | 2,895 | — | 2,772 | 2,934 | — |
| 2026-02 | 1,982 | 2,979 | — | 2,896 | 3,135 | — |
| 2026-03 | 2,056 | 2,638 | 3,452 | 3,009 | 3,171 | 3,388 |
| 2026-04 | 2,057 | 2,667 | 4,593 | 2,994 | 3,149 | 3,375 |
| 2026-05 | 2,133 | 2,760 | 4,446 | 3,061 | 3,248 | 3,449 |
| 2026-06 | 2,154 | 2,597 | 3,828 | 3,081 | 3,264 | 3,564 |
| 2026-07 | 2,205 | 2,606 | 3,344 | 3,096 | 3,260 | 3,492 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.7.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal =
**percentil sobre todos los minutos** (13–22h) · oficiales = valores confirmados por el cliente
(Aut 3,000/3,500, SPEI 2,080/3,240) · gráfica en `percentiles-correlacionados-evolucion.html`.*
