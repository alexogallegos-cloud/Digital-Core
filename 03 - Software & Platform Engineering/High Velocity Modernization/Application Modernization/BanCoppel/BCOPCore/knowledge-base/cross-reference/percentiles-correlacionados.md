# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.1.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 5 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). **Todos
los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin de semana), horario
operativo 07–23h.

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
| SPEI | 2,055 | 2,440 | 3,833 |
| Autorizador | 2,983 | 3,184 | 3,262 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.6%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.771**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,529 | 1,910 | 2,491 | 2,654 | 18.5% | 0.782 |
| 2025-02 | 1,514 | 2,022 | 2,548 | 2,756 | 18.1% | 0.764 |
| 2025-03 | 1,551 | 2,075 | 2,626 | 2,844 | 18.3% | 0.734 |
| 2025-04 | 1,584 | 2,075 | 2,819 | 3,013 | 18.2% | 0.691 |
| 2025-05 | 1,653 | 2,143 | 2,702 | 2,896 | 19.2% | 0.749 |
| 2025-06 | 1,660 | 2,112 | 2,624 | 2,835 | 19.0% | 0.77 |
| 2025-07 | 1,733 | 2,051 | 2,628 | 2,777 | 19.0% | 0.787 |
| 2025-08 | 1,747 | 2,183 | 2,710 | 2,943 | 19.6% | 0.771 |
| 2025-09 | 1,753 | 2,231 | 2,709 | 2,924 | 18.9% | 0.756 |
| 2025-10 | 1,849 | 2,334 | 2,763 | 2,966 | 18.8% | 0.785 |
| 2025-11 | 1,884 | 2,440 | 2,837 | 3,135 | 19.1% | 0.776 |
| 2025-12 | 2,078 | 2,583 | 2,897 | 3,160 | 18.0% | 0.682 |
| 2026-01 | 1,819 | 2,349 | 2,655 | 2,859 | 18.5% | 0.766 |
| 2026-02 | 1,894 | 2,441 | 2,768 | 3,015 | 18.5% | 0.796 |
| 2026-03 | 1,908 | 2,387 | 2,899 | 3,104 | 19.1% | 0.726 |
| 2026-04 | 1,935 | 2,382 | 2,891 | 3,083 | 19.2% | 0.737 |
| 2026-05 | 1,993 | 2,497 | 2,941 | 3,173 | 19.5% | 0.755 |
| 2026-06 | 1,993 | 2,461 | 2,968 | 3,180 | 18.9% | 0.718 |
| 2026-07 | 2,055 | 2,440 | 2,983 | 3,184 | 20.6% | 0.771 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
