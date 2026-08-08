# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.2.0 (evolución quincenal) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido). Los **umbrales P70/P90** se calculan en
**ventanas de 1 minuto** (resolución cruda: el pico instantáneo por minuto, sin suavizado); la
**capacidad demostrada** (top-5) en **ventanas promedio de 5 minutos** (carga sostenida, no el pico
del que el sistema se restablece). **Todos los días** (hábiles y no hábiles — SPEI y el Autorizador
operan también el fin de semana), horario operativo 13–22h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés. (Ventana 1 min.)
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez** (esta es la lente correlacionada).
- **Incidencia inminente** = ambos ≥ su P90 a la vez.
- **Top-5 de concurrencia sin caída, en ventanas promedio de 5 min** = capacidad sostenida demostrada
  por canal (el nivel de cada canal en las 5 mayores ventanas de 5 min de concurrencia sin caída).

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales (última quincena 2026-07 Q2) — por canal

| Canal | P70 (alerta) | P90 (incidencia) | Capacidad demostrada (top-5, ventana prom. 5 min) |
|-------|-------------|------------------|---------------------------------------------|
| SPEI | 2,208 | 2,619 | 3,594 |
| Autorizador | 3,130 | 3,279 | 3,296 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **18.3%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.538**.

## Evolución quincenal — P70/P90 por canal (txn/min)

| Quincena | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|----------|----------|----------|---------|---------|-------------|---------|
| 2025-01 Q1 | 1,678 | 2,206 | 2,550 | 2,668 | 15.0% | 0.422 |
| 2025-01 Q2 | 1,679 | 2,248 | 2,626 | 2,754 | 16.0% | 0.44 |
| 2025-02 Q1 | 1,676 | 2,440 | 2,647 | 2,836 | 15.7% | 0.379 |
| 2025-02 Q2 | 1,762 | 2,632 | 2,679 | 2,863 | 13.8% | 0.322 |
| 2025-03 Q1 | 1,797 | 2,677 | 2,717 | 2,897 | 14.4% | 0.318 |
| 2025-03 Q2 | 1,806 | 2,564 | 2,766 | 2,932 | 13.2% | 0.305 |
| 2025-04 Q1 | 1,888 | 2,602 | 2,919 | 3,065 | 11.9% | 0.21 |
| 2025-04 Q2 | 1,761 | 2,589 | 2,936 | 3,182 | 14.5% | 0.223 |
| 2025-05 Q1 | 1,798 | 2,553 | 2,808 | 2,977 | 15.1% | 0.374 |
| 2025-05 Q2 | 1,890 | 2,372 | 2,802 | 2,970 | 18.2% | 0.495 |
| 2025-06 Q1 | 1,841 | 2,315 | 2,747 | 2,925 | 17.2% | 0.457 |
| 2025-06 Q2 | 1,867 | 2,329 | 2,736 | 2,892 | 19.0% | 0.493 |
| 2025-07 Q1 | 1,900 | 2,263 | 2,692 | 2,804 | 16.8% | 0.469 |
| 2025-07 Q2 | 1,890 | 2,247 | 2,730 | 2,853 | 15.7% | 0.389 |
| 2025-08 Q1 | 1,943 | 2,437 | 2,745 | 2,917 | 18.7% | 0.528 |
| 2025-08 Q2 | 1,948 | 2,446 | 2,892 | 3,092 | 17.5% | 0.416 |
| 2025-09 Q1 | 1,977 | 2,503 | 2,801 | 2,970 | 16.9% | 0.379 |
| 2025-09 Q2 | 1,938 | 2,565 | 2,863 | 3,025 | 15.6% | 0.375 |
| 2025-10 Q1 | 1,992 | 2,576 | 2,852 | 2,996 | 16.1% | 0.458 |
| 2025-10 Q2 | 2,029 | 2,694 | 2,919 | 3,063 | 16.3% | 0.481 |
| 2025-11 Q1 | 2,086 | 3,068 | 2,908 | 3,155 | 19.4% | 0.582 |
| 2025-11 Q2 | 1,969 | 3,012 | 3,069 | 3,327 | 16.0% | 0.386 |
| 2025-12 Q1 | 2,288 | 3,115 | 2,968 | 3,168 | 14.2% | 0.309 |
| 2025-12 Q2 | 2,300 | 3,073 | 3,101 | 3,434 | 12.3% | 0.173 |
| 2026-01 Q1 | 1,906 | 2,837 | 2,698 | 2,851 | 16.4% | 0.578 |
| 2026-01 Q2 | 1,962 | 2,927 | 2,833 | 2,976 | 18.0% | 0.456 |
| 2026-02 Q1 | 1,941 | 2,914 | 2,839 | 3,027 | 16.5% | 0.448 |
| 2026-02 Q2 | 2,042 | 3,063 | 2,969 | 3,248 | 18.8% | 0.529 |
| 2026-03 Q1 | 1,998 | 2,754 | 2,992 | 3,162 | 17.5% | 0.376 |
| 2026-03 Q2 | 2,096 | 2,556 | 3,024 | 3,181 | 16.3% | 0.428 |
| 2026-04 Q1 | 1,981 | 2,558 | 2,934 | 3,094 | 18.0% | 0.45 |
| 2026-04 Q2 | 2,137 | 2,780 | 3,038 | 3,183 | 15.7% | 0.355 |
| 2026-05 Q1 | 2,123 | 2,748 | 3,030 | 3,231 | 18.3% | 0.43 |
| 2026-05 Q2 | 2,147 | 2,766 | 3,084 | 3,263 | 18.6% | 0.453 |
| 2026-06 Q1 | 2,123 | 2,647 | 3,023 | 3,203 | 18.3% | 0.389 |
| 2026-06 Q2 | 2,179 | 2,566 | 3,125 | 3,334 | 17.3% | 0.454 |
| 2026-07 Q1 | 2,202 | 2,585 | 3,057 | 3,229 | 18.4% | 0.33 |
| 2026-07 Q2 | 2,208 | 2,619 | 3,130 | 3,279 | 18.3% | 0.538 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución quincenal (Q1 días 1-15, Q2 días 16-fin) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
