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
operativo 13–23h.

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
| SPEI | 2,156 | 2,583 | 4,673 |
| Autorizador | 3,110 | 3,268 | 3,325 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **19.4%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.64**.

## Evolución quincenal — P70/P90 por canal (txn/min)

| Quincena | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|----------|----------|----------|---------|---------|-------------|---------|
| 2025-01 Q1 | 1,625 | 2,160 | 2,535 | 2,659 | 16.0% | 0.549 |
| 2025-01 Q2 | 1,629 | 2,202 | 2,610 | 2,744 | 16.4% | 0.543 |
| 2025-02 Q1 | 1,626 | 2,355 | 2,626 | 2,820 | 16.2% | 0.457 |
| 2025-02 Q2 | 1,682 | 2,553 | 2,658 | 2,841 | 14.5% | 0.396 |
| 2025-03 Q1 | 1,733 | 2,590 | 2,697 | 2,881 | 15.2% | 0.399 |
| 2025-03 Q2 | 1,718 | 2,455 | 2,743 | 2,920 | 14.1% | 0.395 |
| 2025-04 Q1 | 1,806 | 2,512 | 2,901 | 3,052 | 13.3% | 0.348 |
| 2025-04 Q2 | 1,688 | 2,478 | 2,913 | 3,154 | 15.5% | 0.333 |
| 2025-05 Q1 | 1,745 | 2,500 | 2,787 | 2,962 | 15.9% | 0.473 |
| 2025-05 Q2 | 1,834 | 2,341 | 2,780 | 2,960 | 18.4% | 0.581 |
| 2025-06 Q1 | 1,797 | 2,282 | 2,723 | 2,914 | 17.3% | 0.565 |
| 2025-06 Q2 | 1,815 | 2,302 | 2,715 | 2,879 | 19.3% | 0.589 |
| 2025-07 Q1 | 1,854 | 2,238 | 2,676 | 2,797 | 17.7% | 0.594 |
| 2025-07 Q2 | 1,848 | 2,221 | 2,715 | 2,845 | 16.3% | 0.554 |
| 2025-08 Q1 | 1,889 | 2,392 | 2,727 | 2,901 | 19.0% | 0.599 |
| 2025-08 Q2 | 1,896 | 2,397 | 2,867 | 3,077 | 18.2% | 0.541 |
| 2025-09 Q1 | 1,918 | 2,449 | 2,777 | 2,959 | 17.6% | 0.528 |
| 2025-09 Q2 | 1,893 | 2,511 | 2,842 | 3,010 | 16.4% | 0.552 |
| 2025-10 Q1 | 1,936 | 2,539 | 2,832 | 2,985 | 16.7% | 0.606 |
| 2025-10 Q2 | 1,973 | 2,641 | 2,901 | 3,053 | 16.9% | 0.606 |
| 2025-11 Q1 | 2,018 | 3,016 | 2,880 | 3,130 | 19.7% | 0.66 |
| 2025-11 Q2 | 1,916 | 2,931 | 3,038 | 3,308 | 16.7% | 0.524 |
| 2025-12 Q1 | 2,143 | 3,070 | 2,948 | 3,144 | 15.1% | 0.475 |
| 2025-12 Q2 | 2,163 | 3,044 | 3,068 | 3,398 | 13.5% | 0.275 |
| 2026-01 Q1 | 1,857 | 2,779 | 2,681 | 2,839 | 17.1% | 0.594 |
| 2026-01 Q2 | 1,895 | 2,895 | 2,814 | 2,964 | 18.2% | 0.554 |
| 2026-02 Q1 | 1,889 | 2,883 | 2,819 | 3,008 | 16.7% | 0.552 |
| 2026-02 Q2 | 1,968 | 3,027 | 2,942 | 3,228 | 18.9% | 0.602 |
| 2026-03 Q1 | 1,944 | 2,706 | 2,970 | 3,149 | 17.7% | 0.49 |
| 2026-03 Q2 | 2,048 | 2,522 | 3,003 | 3,168 | 17.2% | 0.564 |
| 2026-04 Q1 | 1,930 | 2,510 | 2,914 | 3,081 | 18.5% | 0.554 |
| 2026-04 Q2 | 2,083 | 2,715 | 3,020 | 3,172 | 16.2% | 0.448 |
| 2026-05 Q1 | 2,075 | 2,689 | 2,999 | 3,216 | 18.5% | 0.51 |
| 2026-05 Q2 | 2,083 | 2,711 | 3,061 | 3,250 | 18.9% | 0.55 |
| 2026-06 Q1 | 2,069 | 2,612 | 3,001 | 3,190 | 18.2% | 0.492 |
| 2026-06 Q2 | 2,131 | 2,537 | 3,105 | 3,313 | 17.9% | 0.592 |
| 2026-07 Q1 | 2,165 | 2,554 | 3,037 | 3,216 | 18.8% | 0.503 |
| 2026-07 Q2 | 2,156 | 2,583 | 3,110 | 3,268 | 19.4% | 0.64 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución quincenal (Q1 días 1-15, Q2 días 16-fin) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
