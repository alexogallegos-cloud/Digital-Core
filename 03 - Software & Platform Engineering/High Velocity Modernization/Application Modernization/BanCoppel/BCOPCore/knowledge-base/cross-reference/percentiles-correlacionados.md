# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.1.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 4 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). **Todos
los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 07–23h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés.
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-5 de concurrencia sin caída, en ventanas de 4 min** = capacidad sostenida demostrada por
  canal (el nivel de cada canal en las 5 mayores ventanas de concurrencia sin caída de servicio).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana 4 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,051 | 2,445 | 4,031 |
| Autorizador | 2,984 | 3,184 | 3,276 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.1%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.767**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,526 | 1,912 | 2,492 | 2,656 | 18.3% | 0.772 |
| 2025-02 | 1,526 | 2,023 | 2,548 | 2,756 | 18.7% | 0.768 |
| 2025-03 | 1,540 | 2,096 | 2,626 | 2,845 | 19.2% | 0.742 |
| 2025-04 | 1,564 | 2,070 | 2,818 | 3,016 | 18.9% | 0.696 |
| 2025-05 | 1,651 | 2,126 | 2,704 | 2,901 | 19.0% | 0.747 |
| 2025-06 | 1,662 | 2,118 | 2,623 | 2,838 | 18.9% | 0.761 |
| 2025-07 | 1,737 | 2,053 | 2,626 | 2,775 | 18.8% | 0.778 |
| 2025-08 | 1,749 | 2,187 | 2,712 | 2,941 | 19.5% | 0.762 |
| 2025-09 | 1,757 | 2,235 | 2,711 | 2,924 | 18.7% | 0.75 |
| 2025-10 | 1,838 | 2,355 | 2,761 | 2,965 | 18.5% | 0.777 |
| 2025-11 | 1,869 | 2,456 | 2,834 | 3,130 | 18.9% | 0.766 |
| 2025-12 | 2,091 | 2,607 | 2,896 | 3,165 | 17.6% | 0.675 |
| 2026-01 | 1,807 | 2,364 | 2,654 | 2,861 | 18.4% | 0.759 |
| 2026-02 | 1,890 | 2,454 | 2,770 | 3,022 | 18.3% | 0.783 |
| 2026-03 | 1,908 | 2,392 | 2,899 | 3,106 | 18.7% | 0.72 |
| 2026-04 | 1,937 | 2,396 | 2,890 | 3,081 | 18.9% | 0.726 |
| 2026-05 | 2,000 | 2,506 | 2,940 | 3,176 | 19.4% | 0.746 |
| 2026-06 | 1,993 | 2,454 | 2,968 | 3,182 | 18.7% | 0.704 |
| 2026-07 | 2,051 | 2,445 | 2,984 | 3,184 | 20.1% | 0.767 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
