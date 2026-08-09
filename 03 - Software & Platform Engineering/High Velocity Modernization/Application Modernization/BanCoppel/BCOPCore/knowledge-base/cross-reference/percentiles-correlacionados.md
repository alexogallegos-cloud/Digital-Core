# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/build-percentiles-correlacionados.py` (+ `forecast/capacity.py`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 2.6.0 (pico POR MINUTO diario · ventana por canal Aut 1min/SPEI 3min · oficiales = percentil agrupado, calibrado vs. cifras del cliente) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

Mide la carga que SPEI y el Autorizador ejercen **simultáneamente** sobre Informix (recurso
compartido). **Por canal, por separado** — no se suman. **Todos los días** (ambos operan también el
fin de semana), horario operativo **13–22h**.

Para cada día se toma su **pico por minuto** (máx txn/min). La **ventana del pico es por canal**,
calibrada contra las métricas validadas del cliente (Aut P70/P90 ≈ 3,400/4,000; SPEI P90 ≈ 3,850):

- **Autorizador — 1 min**: su carga es un **plató**, el pico por minuto ES el sostenido.
- **SPEI — 3 min**: su pico por minuto lo dominan **dumps batch de dispersión de nómina** (hasta
  ~32,000 txn/min en un solo minuto, p.ej. 18-dic y 3-mar) que NO son carga sostenida; la ventana de
  3 min los promedia y aterriza en el pico sostenido real.

Los **percentiles oficiales** (P70 alerta, P90 incidente, P99 techo) son el **percentil agrupado
sobre TODOS los picos diarios del histórico** (no el máximo de los percentiles mensuales) — la misma
definición que usa el cliente. La evolución mensual (gráfica) es el percentil por mes.

El **P99 solo se muestra desde el leak-fix de mar-2026** (antes el pico está contaminado por los
encolamientos y el connection leak, INC-20251223).

> **Correlación**: los picos de ambos canales coinciden en el tiempo (perfil intradía r≈0.99), no se
> diversifican y la carga se apila sobre Informix. **Zona de riesgo** = ambos ≥ su P70 a la vez.

## Percentiles OFICIALES por canal (percentil agrupado, todo el histórico) — umbrales de referencia

Son la cifra oficial del canal: el **percentil sobre todos los picos diarios** del histórico (el mismo
valor que dibuja curvas intradía como líneas de referencia). El P70 (alerta) y el P90 (incidente)
son los **percentiles oficiales** para operación; el P99 es el techo de dimensionamiento.
**Holgura de dimensionamiento por canal** — REGLA: solo se asigna holgura a un canal con margen real;
un canal que **topa su techo** NO recibe holgura hasta que haya remediación. **SPEI: +10%** (tiene
margen). **Autorizador: +0%** (topa su techo ~4,300 txn/min; cuello = pool de conexiones/BD/HSM).

| Canal | P70 (alerta) | P90 (incidente) | P99 (techo) |
|-------|-------------|------------------|-------------|
| SPEI | 3,629 | 4,382 | 8,473 |
| Autorizador | 3,394 | 3,986 | 4,568 |

> Autorizador: su P90 y P99 quedan al mismo nivel (~3,600) porque **topa un techo real** y su carga
> está censurada en los picos (ver DT-Autorizador y `growth-forecast-autorizador-spei.md`).

Último mes (2026-07), como referencia de la tendencia: SPEI P70/P90 3,633/4,253,
Autorizador 3,539/3,754.

El Informix/Aurora target se dimensiona contra el **P99** de cada canal (el techo sostenido), no
contra el promedio. El pico absoluto puntual (p.ej. aguinaldo) es un outlier P100 por encima del P99.

## Evolución mensual — por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | SPEI P99 | Aut P70 | Aut P90 | Aut P99 |
|-----|----------|----------|----------|---------|---------|---------|
| 2025-01 | 3,456 | 3,812 | — | 3,024 | 3,971 | — |
| 2025-02 | 3,418 | 3,889 | — | 3,131 | 4,047 | — |
| 2025-03 | 3,594 | 3,865 | — | 3,252 | 3,768 | — |
| 2025-04 | 3,649 | 3,859 | — | 3,431 | 4,548 | — |
| 2025-05 | 3,650 | 4,148 | — | 4,018 | 4,416 | — |
| 2025-06 | 4,024 | 4,380 | — | 3,200 | 3,592 | — |
| 2025-07 | 3,496 | 4,096 | — | 3,070 | 3,182 | — |
| 2025-08 | 3,805 | 4,305 | — | 3,265 | 4,183 | — |
| 2025-09 | 3,724 | 4,414 | — | 3,249 | 3,891 | — |
| 2025-10 | 3,411 | 3,559 | — | 3,283 | 3,475 | — |
| 2025-11 | 3,648 | 3,711 | — | 3,398 | 3,728 | — |
| 2025-12 | 3,694 | 4,486 | — | 3,867 | 3,986 | — |
| 2026-01 | 3,560 | 3,618 | — | 3,190 | 3,632 | — |
| 2026-02 | 3,566 | 3,710 | — | 3,366 | 3,867 | — |
| 2026-03 | 3,733 | 5,400 | 15,881 | 3,405 | 3,912 | 4,252 |
| 2026-04 | 3,926 | 6,116 | 9,292 | 3,469 | 3,773 | 4,085 |
| 2026-05 | 4,076 | 6,786 | 8,146 | 3,509 | 3,997 | 4,214 |
| 2026-06 | 4,466 | 8,434 | 8,809 | 3,594 | 3,840 | 3,989 |
| 2026-07 | 3,633 | 4,253 | 7,808 | 3,539 | 3,754 | 4,132 |

> Los umbrales de cada canal suben con el crecimiento orgánico; cada canal cruza sus umbrales cada
> vez más seguido y se come el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración. (P99 solo desde mar-2026 — régimen confiable.)

---

*v2.6.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90/P99 por canal sobre el
**pico por minuto diario** (ventana Aut 1 min / SPEI 3 min) · oficiales = percentil agrupado del histórico ·
calibrado vs. cifras validadas del cliente · gráfica en `percentiles-correlacionados-evolucion.html`.*
