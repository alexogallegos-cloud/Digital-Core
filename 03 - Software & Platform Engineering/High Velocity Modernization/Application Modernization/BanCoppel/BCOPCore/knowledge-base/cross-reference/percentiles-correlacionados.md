# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.1.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 5 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). Días
hábiles, horario operativo 07–23h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés.
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-5 de concurrencia sin caída, en ventanas de 5 min** = capacidad sostenida demostrada por
  canal (el nivel de cada canal en las 5 mayores ventanas de concurrencia sin caída de servicio).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana 5 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,093 | 2,459 | 3,850 |
| Autorizador | 2,990 | 3,172 | 3,240 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.4%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.822**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,556 | 1,961 | 2,481 | 2,650 | 18.8% | 0.781 |
| 2025-02 | 1,517 | 2,010 | 2,526 | 2,739 | 18.6% | 0.784 |
| 2025-03 | 1,554 | 2,061 | 2,579 | 2,818 | 18.9% | 0.752 |
| 2025-04 | 1,644 | 2,184 | 2,855 | 3,046 | 17.4% | 0.656 |
| 2025-05 | 1,664 | 2,178 | 2,701 | 2,899 | 19.0% | 0.745 |
| 2025-06 | 1,664 | 2,104 | 2,601 | 2,815 | 19.2% | 0.77 |
| 2025-07 | 1,776 | 2,073 | 2,634 | 2,784 | 18.5% | 0.782 |
| 2025-08 | 1,753 | 2,170 | 2,697 | 2,916 | 19.5% | 0.773 |
| 2025-09 | 1,783 | 2,300 | 2,677 | 2,902 | 19.2% | 0.734 |
| 2025-10 | 1,885 | 2,372 | 2,735 | 2,953 | 18.9% | 0.782 |
| 2025-11 | 1,857 | 2,354 | 2,778 | 3,001 | 18.6% | 0.804 |
| 2025-12 | 2,130 | 2,663 | 2,912 | 3,203 | 17.3% | 0.646 |
| 2026-01 | 1,859 | 2,440 | 2,661 | 2,866 | 18.4% | 0.754 |
| 2026-02 | 1,885 | 2,384 | 2,752 | 2,976 | 18.0% | 0.785 |
| 2026-03 | 1,908 | 2,423 | 2,878 | 3,076 | 18.9% | 0.697 |
| 2026-04 | 2,022 | 2,475 | 2,910 | 3,096 | 19.1% | 0.714 |
| 2026-05 | 1,962 | 2,413 | 2,901 | 3,132 | 18.9% | 0.74 |
| 2026-06 | 2,009 | 2,478 | 2,955 | 3,162 | 18.7% | 0.69 |
| 2026-07 | 2,093 | 2,459 | 2,990 | 3,172 | 20.4% | 0.822 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
