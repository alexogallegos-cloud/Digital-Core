# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.2.0 (evolución quincenal) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), sobre **ventanas promedio de 5 minutos**
(carga sostenida, no el pico de 1 min del que el sistema se restablece). Tanto los **umbrales
P70/P90** como la **capacidad demostrada** (top-10) usan esa misma ventana de 5 min. **Todos los
días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 13–22h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés. (Ventana prom. 5 min.)
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-10 de concurrencia sin caída, en ventanas promedio de 5 min** = capacidad sostenida demostrada
  por canal (el nivel de cada canal en las 10 mayores ventanas de 5 min de concurrencia sin caída).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (última quincena 2026-07 Q2) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-10, ventana prom. 5 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,240 | 2,564 | 3,073 |
| Autorizador | 3,129 | 3,271 | 3,282 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **19.9%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.613**.

## Evolución quincenal — P70/P90 por canal (txn/min)

| Quincena | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|----------|----------|----------|---------|---------|-------------|---------|
| 2025-01 Q1 | 1,645 | 2,075 | 2,552 | 2,653 | 17.2% | 0.547 |
| 2025-01 Q2 | 1,699 | 2,033 | 2,623 | 2,735 | 17.7% | 0.577 |
| 2025-02 Q1 | 1,653 | 2,217 | 2,642 | 2,830 | 20.3% | 0.624 |
| 2025-02 Q2 | 1,600 | 2,143 | 2,679 | 2,840 | 17.6% | 0.593 |
| 2025-03 Q1 | 1,697 | 2,329 | 2,715 | 2,890 | 20.9% | 0.554 |
| 2025-03 Q2 | 1,639 | 2,211 | 2,767 | 2,920 | 19.5% | 0.551 |
| 2025-04 Q1 | 1,691 | 2,205 | 2,918 | 3,044 | 15.0% | 0.379 |
| 2025-04 Q2 | 1,670 | 2,249 | 2,934 | 3,161 | 17.6% | 0.376 |
| 2025-05 Q1 | 1,710 | 2,267 | 2,802 | 2,971 | 20.2% | 0.582 |
| 2025-05 Q2 | 1,808 | 2,238 | 2,798 | 2,967 | 21.6% | 0.613 |
| 2025-06 Q1 | 1,713 | 2,261 | 2,748 | 2,918 | 20.7% | 0.567 |
| 2025-06 Q2 | 1,818 | 2,252 | 2,736 | 2,881 | 22.8% | 0.62 |
| 2025-07 Q1 | 1,878 | 2,133 | 2,691 | 2,792 | 20.2% | 0.597 |
| 2025-07 Q2 | 1,847 | 2,122 | 2,724 | 2,844 | 17.9% | 0.504 |
| 2025-08 Q1 | 1,893 | 2,362 | 2,735 | 2,911 | 21.8% | 0.65 |
| 2025-08 Q2 | 1,850 | 2,385 | 2,890 | 3,085 | 20.5% | 0.545 |
| 2025-09 Q1 | 1,931 | 2,432 | 2,798 | 2,963 | 20.2% | 0.487 |
| 2025-09 Q2 | 1,906 | 2,433 | 2,856 | 3,001 | 18.1% | 0.481 |
| 2025-10 Q1 | 1,997 | 2,441 | 2,855 | 2,986 | 18.0% | 0.569 |
| 2025-10 Q2 | 2,035 | 2,487 | 2,920 | 3,056 | 18.5% | 0.58 |
| 2025-11 Q1 | 2,085 | 2,811 | 2,903 | 3,153 | 21.2% | 0.708 |
| 2025-11 Q2 | 1,985 | 2,530 | 3,067 | 3,332 | 16.9% | 0.524 |
| 2025-12 Q1 | 2,206 | 2,786 | 2,957 | 3,146 | 16.5% | 0.452 |
| 2025-12 Q2 | 2,269 | 2,799 | 3,094 | 3,424 | 11.8% | 0.291 |
| 2026-01 Q1 | 1,952 | 2,524 | 2,691 | 2,839 | 20.1% | 0.678 |
| 2026-01 Q2 | 2,060 | 2,597 | 2,828 | 2,967 | 20.3% | 0.581 |
| 2026-02 Q1 | 1,986 | 2,542 | 2,841 | 3,022 | 18.5% | 0.589 |
| 2026-02 Q2 | 2,095 | 2,806 | 2,958 | 3,254 | 20.9% | 0.67 |
| 2026-03 Q1 | 2,001 | 2,518 | 2,990 | 3,154 | 19.7% | 0.508 |
| 2026-03 Q2 | 2,055 | 2,465 | 3,021 | 3,168 | 18.8% | 0.553 |
| 2026-04 Q1 | 1,979 | 2,443 | 2,930 | 3,089 | 21.3% | 0.612 |
| 2026-04 Q2 | 2,140 | 2,622 | 3,034 | 3,172 | 18.5% | 0.46 |
| 2026-05 Q1 | 2,126 | 2,618 | 3,025 | 3,220 | 20.6% | 0.594 |
| 2026-05 Q2 | 2,114 | 2,665 | 3,078 | 3,258 | 20.7% | 0.582 |
| 2026-06 Q1 | 2,086 | 2,600 | 3,021 | 3,189 | 20.1% | 0.466 |
| 2026-06 Q2 | 2,165 | 2,526 | 3,122 | 3,318 | 18.9% | 0.519 |
| 2026-07 Q1 | 2,193 | 2,550 | 3,052 | 3,218 | 20.9% | 0.362 |
| 2026-07 Q2 | 2,240 | 2,564 | 3,129 | 3,271 | 19.9% | 0.613 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución quincenal (Q1 días 1-15, Q2 días 16-fin) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
