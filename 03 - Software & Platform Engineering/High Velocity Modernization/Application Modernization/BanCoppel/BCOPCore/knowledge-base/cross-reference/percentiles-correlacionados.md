# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.1.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 1 minuto** (resolución
cruda: el pico instantáneo por minuto, sin suavizado ni buffer de restablecimiento — es la máxima
resolución, la que el usuario originalmente evitó por no dar tiempo de recuperación). **Todos
los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 12–23h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés.
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-5 de concurrencia sin caída, en ventanas de 1 min** = capacidad sostenida demostrada por
  canal (el nivel de cada canal en las 5 mayores ventanas de concurrencia sin caída de servicio).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana 1 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,174 | 2,571 | 5,468 |
| Autorizador | 3,068 | 3,238 | 3,344 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **18.8%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.548**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,639 | 2,187 | 2,561 | 2,701 | 15.5% | 0.526 |
| 2025-02 | 1,663 | 2,450 | 2,627 | 2,821 | 15.1% | 0.409 |
| 2025-03 | 1,738 | 2,555 | 2,713 | 2,900 | 14.3% | 0.382 |
| 2025-04 | 1,768 | 2,518 | 2,897 | 3,083 | 14.2% | 0.329 |
| 2025-05 | 1,811 | 2,419 | 2,783 | 2,958 | 17.0% | 0.506 |
| 2025-06 | 1,820 | 2,299 | 2,712 | 2,889 | 18.0% | 0.564 |
| 2025-07 | 1,866 | 2,238 | 2,689 | 2,816 | 16.2% | 0.555 |
| 2025-08 | 1,909 | 2,403 | 2,795 | 3,010 | 17.8% | 0.539 |
| 2025-09 | 1,914 | 2,489 | 2,800 | 2,977 | 16.3% | 0.522 |
| 2025-10 | 1,969 | 2,595 | 2,854 | 3,014 | 16.1% | 0.585 |
| 2025-11 | 1,969 | 2,969 | 2,948 | 3,227 | 17.0% | 0.565 |
| 2025-12 | 2,195 | 3,066 | 2,991 | 3,275 | 14.2% | 0.324 |
| 2026-01 | 1,887 | 2,855 | 2,732 | 2,911 | 16.5% | 0.57 |
| 2026-02 | 1,933 | 2,949 | 2,862 | 3,107 | 17.4% | 0.561 |
| 2026-03 | 2,016 | 2,601 | 2,980 | 3,153 | 17.5% | 0.507 |
| 2026-04 | 2,027 | 2,611 | 2,966 | 3,130 | 17.0% | 0.484 |
| 2026-05 | 2,097 | 2,727 | 3,032 | 3,226 | 18.6% | 0.518 |
| 2026-06 | 2,120 | 2,578 | 3,056 | 3,248 | 17.9% | 0.511 |
| 2026-07 | 2,174 | 2,571 | 3,068 | 3,238 | 18.8% | 0.548 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
