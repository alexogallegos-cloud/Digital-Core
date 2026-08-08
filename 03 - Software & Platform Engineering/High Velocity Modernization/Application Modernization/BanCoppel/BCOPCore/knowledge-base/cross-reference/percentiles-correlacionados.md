# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.5.0 (mensual · ventana 10 min · umbrales con mejoras) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), sobre **ventanas promedio de 10 minutos**
(carga sostenida). Los **umbrales P70/P90** son percentiles sobre **todas las ventanas de 10 min**
del periodo. **Todos los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin
de semana), horario operativo 13–22h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés. (Ventana prom. 10 min.)
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez**.
- **Incidencia inminente** = ambos ≥ su P90 a la vez.

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales vs con mejoras (último mes 2026-07) — por canal

Umbrales **con mejoras** = umbral actual × factor de capacidad demostrado sin incidentes
(SPEI ×2.92, Autorizador ×1.18; ver Derivación abajo). Se calculan **mes a mes**.

| Canal | P70 actual | P90 actual | k | P70 con mejoras | P90 con mejoras |
|-------|-----------|-----------|---|-----------------|-----------------|
| SPEI | 2,217 | 2,542 | ×2.92 | 6,474 | 7,423 |
| Autorizador | 3,090 | 3,246 | ×1.18 | 3,646 | 3,830 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.5%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.453**.

### Derivación del factor con mejoras

En **diciembre 2025** el sistema entraba en incidente al llegar a P90 (SPEI 2,725 / Autorizador 3,259,
ventana 10 min). Tras las mejoras (**leak-fix** mar-2026 + **Power 10** jun-2026) sostuvo, **sin un solo
incidente**, hasta **SPEI 7,950 / Autorizador 3,850 txn/min** (máx sostenido 10 min, abr–ago 2026). El
factor demostrado es `k = máx_sostenido_post ÷ P90_dic` → **SPEI ×2.92, Autorizador ×1.18**. Son **cotas
inferiores** (aún no tocamos el nuevo techo). El ×1.18 de Autorizador es conservador (canal estable,
no se ha estresado más allá de ~4,000). Los umbrales con mejoras = P70/P90 × k, aplicado **mes a mes**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,675 | 2,038 | 2,590 | 2,698 | 17.9% | 0.595 |
| 2025-02 | 1,604 | 2,162 | 2,663 | 2,832 | 20.0% | 0.659 |
| 2025-03 | 1,668 | 2,218 | 2,746 | 2,906 | 21.4% | 0.604 |
| 2025-04 | 1,691 | 2,159 | 2,931 | 3,100 | 16.6% | 0.405 |
| 2025-05 | 1,754 | 2,274 | 2,798 | 2,967 | 20.8% | 0.637 |
| 2025-06 | 1,754 | 2,252 | 2,742 | 2,897 | 22.4% | 0.637 |
| 2025-07 | 1,849 | 2,153 | 2,706 | 2,816 | 19.2% | 0.571 |
| 2025-08 | 1,866 | 2,384 | 2,812 | 3,024 | 20.1% | 0.624 |
| 2025-09 | 1,913 | 2,405 | 2,832 | 2,982 | 19.0% | 0.527 |
| 2025-10 | 2,024 | 2,412 | 2,888 | 3,021 | 18.1% | 0.61 |
| 2025-11 | 1,998 | 2,645 | 2,983 | 3,255 | 18.5% | 0.625 |
| 2025-12 | 2,237 | 2,712 | 3,016 | 3,301 | 15.4% | 0.38 |
| 2026-01 | 1,975 | 2,508 | 2,766 | 2,920 | 20.1% | 0.67 |
| 2026-02 | 1,994 | 2,604 | 2,886 | 3,139 | 20.5% | 0.674 |
| 2026-03 | 2,023 | 2,475 | 3,006 | 3,161 | 19.7% | 0.586 |
| 2026-04 | 2,055 | 2,497 | 2,989 | 3,131 | 20.2% | 0.551 |
| 2026-05 | 2,122 | 2,618 | 3,059 | 3,234 | 21.3% | 0.632 |
| 2026-06 | 2,130 | 2,541 | 3,077 | 3,240 | 19.6% | 0.518 |
| 2026-07 | 2,217 | 2,542 | 3,090 | 3,246 | 20.5% | 0.453 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.5.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · ventana 10 min · evolución mensual · umbrales con mejoras (×k) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
