# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.2.0 (evolución quincenal) · regenerable con `python generators/build-percentiles-correlacionados.py`

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

## Umbrales actuales (última quincena 2026-07 Q2) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana 1 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,173 | 2,585 | 4,715 |
| Autorizador | 3,100 | 3,261 | 3,312 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **18.9%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.634**.

## Evolución quincenal — P70/P90 por canal (txn/min)

| Quincena | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|----------|----------|----------|---------|---------|-------------|---------|
| 2025-01 Q1 | 1,636 | 2,169 | 2,522 | 2,653 | 15.6% | 0.526 |
| 2025-01 Q2 | 1,640 | 2,202 | 2,597 | 2,734 | 15.9% | 0.528 |
| 2025-02 Q1 | 1,644 | 2,370 | 2,614 | 2,811 | 15.7% | 0.436 |
| 2025-02 Q2 | 1,696 | 2,544 | 2,644 | 2,833 | 14.2% | 0.384 |
| 2025-03 Q1 | 1,742 | 2,626 | 2,687 | 2,877 | 14.8% | 0.386 |
| 2025-03 Q2 | 1,730 | 2,483 | 2,739 | 2,917 | 14.0% | 0.383 |
| 2025-04 Q1 | 1,829 | 2,530 | 2,892 | 3,044 | 13.0% | 0.336 |
| 2025-04 Q2 | 1,705 | 2,499 | 2,908 | 3,136 | 15.4% | 0.326 |
| 2025-05 Q1 | 1,762 | 2,522 | 2,787 | 2,965 | 15.7% | 0.455 |
| 2025-05 Q2 | 1,853 | 2,356 | 2,780 | 2,952 | 18.4% | 0.567 |
| 2025-06 Q1 | 1,810 | 2,286 | 2,718 | 2,909 | 17.0% | 0.549 |
| 2025-06 Q2 | 1,828 | 2,311 | 2,705 | 2,871 | 18.8% | 0.576 |
| 2025-07 Q1 | 1,869 | 2,245 | 2,668 | 2,791 | 17.2% | 0.58 |
| 2025-07 Q2 | 1,864 | 2,229 | 2,708 | 2,840 | 15.7% | 0.535 |
| 2025-08 Q1 | 1,906 | 2,399 | 2,721 | 2,897 | 18.8% | 0.589 |
| 2025-08 Q2 | 1,910 | 2,411 | 2,861 | 3,074 | 17.8% | 0.51 |
| 2025-09 Q1 | 1,935 | 2,468 | 2,768 | 2,951 | 17.3% | 0.512 |
| 2025-09 Q2 | 1,899 | 2,507 | 2,827 | 2,999 | 15.8% | 0.54 |
| 2025-10 Q1 | 1,956 | 2,555 | 2,819 | 2,978 | 16.0% | 0.575 |
| 2025-10 Q2 | 1,984 | 2,642 | 2,889 | 3,043 | 16.4% | 0.593 |
| 2025-11 Q1 | 2,022 | 3,015 | 2,868 | 3,113 | 19.5% | 0.648 |
| 2025-11 Q2 | 1,927 | 2,930 | 3,019 | 3,291 | 16.1% | 0.512 |
| 2025-12 Q1 | 2,179 | 3,081 | 2,933 | 3,128 | 14.6% | 0.461 |
| 2025-12 Q2 | 2,209 | 3,053 | 3,067 | 3,407 | 13.3% | 0.274 |
| 2026-01 Q1 | 1,868 | 2,782 | 2,666 | 2,831 | 16.3% | 0.589 |
| 2026-01 Q2 | 1,913 | 2,902 | 2,797 | 2,957 | 17.4% | 0.541 |
| 2026-02 Q1 | 1,903 | 2,890 | 2,806 | 2,995 | 16.1% | 0.536 |
| 2026-02 Q2 | 1,974 | 3,028 | 2,936 | 3,222 | 18.7% | 0.588 |
| 2026-03 Q1 | 1,959 | 2,713 | 2,959 | 3,137 | 17.3% | 0.484 |
| 2026-03 Q2 | 2,062 | 2,533 | 2,998 | 3,163 | 16.8% | 0.533 |
| 2026-04 Q1 | 1,954 | 2,517 | 2,908 | 3,076 | 18.1% | 0.546 |
| 2026-04 Q2 | 2,096 | 2,710 | 3,011 | 3,163 | 16.0% | 0.44 |
| 2026-05 Q1 | 2,094 | 2,722 | 2,999 | 3,208 | 18.5% | 0.502 |
| 2026-05 Q2 | 2,099 | 2,733 | 3,056 | 3,242 | 18.9% | 0.541 |
| 2026-06 Q1 | 2,090 | 2,617 | 3,001 | 3,194 | 18.0% | 0.487 |
| 2026-06 Q2 | 2,146 | 2,546 | 3,098 | 3,302 | 17.3% | 0.556 |
| 2026-07 Q1 | 2,175 | 2,560 | 3,035 | 3,209 | 18.7% | 0.497 |
| 2026-07 Q2 | 2,173 | 2,585 | 3,100 | 3,261 | 18.9% | 0.634 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución quincenal (Q1 días 1-15, Q2 días 16-fin) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
