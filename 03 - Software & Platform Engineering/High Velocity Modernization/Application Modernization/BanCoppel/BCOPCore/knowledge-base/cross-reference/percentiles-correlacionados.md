# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.1.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 2 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). **Todos
los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 07–23h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés.
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-5 de concurrencia sin caída, en ventanas de 2 min** = capacidad sostenida demostrada por
  canal (el nivel de cada canal en las 5 mayores ventanas de concurrencia sin caída de servicio).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana 2 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,062 | 2,459 | 5,258 |
| Autorizador | 2,983 | 3,190 | 3,216 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **19.9%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.748**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,535 | 1,922 | 2,490 | 2,658 | 17.9% | 0.745 |
| 2025-02 | 1,540 | 2,045 | 2,547 | 2,757 | 18.4% | 0.738 |
| 2025-03 | 1,554 | 2,126 | 2,625 | 2,846 | 18.9% | 0.717 |
| 2025-04 | 1,570 | 2,148 | 2,816 | 3,020 | 18.5% | 0.671 |
| 2025-05 | 1,662 | 2,153 | 2,703 | 2,902 | 18.5% | 0.723 |
| 2025-06 | 1,674 | 2,122 | 2,623 | 2,838 | 18.4% | 0.732 |
| 2025-07 | 1,745 | 2,065 | 2,626 | 2,777 | 18.4% | 0.747 |
| 2025-08 | 1,766 | 2,192 | 2,712 | 2,944 | 18.9% | 0.731 |
| 2025-09 | 1,768 | 2,261 | 2,710 | 2,927 | 18.2% | 0.714 |
| 2025-10 | 1,826 | 2,398 | 2,762 | 2,970 | 18.2% | 0.743 |
| 2025-11 | 1,834 | 2,554 | 2,834 | 3,140 | 18.6% | 0.731 |
| 2025-12 | 2,094 | 2,693 | 2,894 | 3,172 | 16.7% | 0.594 |
| 2026-01 | 1,756 | 2,446 | 2,652 | 2,860 | 18.1% | 0.727 |
| 2026-02 | 1,828 | 2,549 | 2,773 | 3,021 | 17.9% | 0.742 |
| 2026-03 | 1,904 | 2,414 | 2,899 | 3,110 | 18.3% | 0.683 |
| 2026-04 | 1,942 | 2,405 | 2,889 | 3,082 | 18.3% | 0.681 |
| 2026-05 | 2,009 | 2,533 | 2,941 | 3,176 | 18.6% | 0.693 |
| 2026-06 | 2,007 | 2,465 | 2,970 | 3,184 | 18.3% | 0.673 |
| 2026-07 | 2,062 | 2,459 | 2,983 | 3,190 | 19.9% | 0.748 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
