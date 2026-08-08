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
operativo 07–23h.

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
| SPEI | 2,068 | 2,485 | 5,638 |
| Autorizador | 2,984 | 3,195 | 3,256 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **19.0%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.721**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,527 | 2,053 | 2,487 | 2,662 | 16.7% | 0.663 |
| 2025-02 | 1,549 | 2,277 | 2,546 | 2,765 | 15.6% | 0.525 |
| 2025-03 | 1,615 | 2,347 | 2,623 | 2,851 | 15.3% | 0.486 |
| 2025-04 | 1,633 | 2,334 | 2,816 | 3,028 | 15.3% | 0.462 |
| 2025-05 | 1,711 | 2,322 | 2,702 | 2,904 | 16.8% | 0.599 |
| 2025-06 | 1,727 | 2,213 | 2,624 | 2,840 | 17.5% | 0.667 |
| 2025-07 | 1,763 | 2,164 | 2,624 | 2,783 | 17.4% | 0.673 |
| 2025-08 | 1,806 | 2,307 | 2,710 | 2,948 | 17.8% | 0.655 |
| 2025-09 | 1,807 | 2,337 | 2,708 | 2,932 | 16.7% | 0.639 |
| 2025-10 | 1,859 | 2,482 | 2,759 | 2,976 | 17.1% | 0.687 |
| 2025-11 | 1,862 | 2,816 | 2,837 | 3,146 | 17.4% | 0.669 |
| 2025-12 | 2,001 | 2,976 | 2,892 | 3,179 | 16.3% | 0.497 |
| 2026-01 | 1,765 | 2,694 | 2,652 | 2,864 | 17.0% | 0.678 |
| 2026-02 | 1,816 | 2,842 | 2,771 | 3,027 | 17.5% | 0.689 |
| 2026-03 | 1,908 | 2,476 | 2,897 | 3,111 | 17.6% | 0.635 |
| 2026-04 | 1,937 | 2,476 | 2,888 | 3,086 | 17.3% | 0.613 |
| 2026-05 | 2,009 | 2,605 | 2,941 | 3,178 | 17.9% | 0.629 |
| 2026-06 | 2,023 | 2,485 | 2,970 | 3,192 | 17.7% | 0.64 |
| 2026-07 | 2,068 | 2,485 | 2,984 | 3,195 | 19.0% | 0.721 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.1.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · gráfica de evolución en `percentiles-correlacionados-evolucion.html`.*
