# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.4.0 (mensual + umbrales con mejoras) · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), sobre **ventanas promedio de 5 minutos**
(carga sostenida). Los **umbrales P70/P90** son percentiles sobre **todas las ventanas de 5 min**
del periodo. **Todos los días** (hábiles y no hábiles — SPEI y el Autorizador operan también el fin
de semana), horario operativo 13–22h.

- **P70/P90 por canal, por separado** — cada canal conserva su propio umbral. El P70 es alerta,
  el P90 es incidencia. No se suman: la suma combinada no es la métrica de interés. (Ventana prom. 5 min.)
- **Zona de riesgo** = ambos canales ≥ su P70 **a la vez**.
- **Incidencia inminente** = ambos ≥ su P90 a la vez.

La **correlación** es lo que importa: los picos de ambos canales coinciden en el tiempo (mismo
perfil intradía, r≈0.99), así que no se diversifican y la carga se apila sobre Informix. Por eso
la alerta se mide por co-ocurrencia (ambos altos), no sumando percentiles independientes.

## Umbrales actuales vs con mejoras (último mes 2026-07) — por canal

Umbrales **con mejoras** = umbral actual × factor de capacidad demostrado sin incidentes
(SPEI ×3.18, Autorizador ×1.23; ver Derivación abajo). Se calculan **mes a mes**.

| Canal | P70 actual | P90 actual | k | P70 con mejoras | P90 con mejoras |
|-------|-----------|-----------|---|-----------------|-----------------|
| SPEI | 2,214 | 2,558 | ×3.18 | 7,041 | 8,134 |
| Autorizador | 3,090 | 3,249 | ×1.23 | 3,801 | 3,996 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.4%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.431**.

### Derivación del factor con mejoras

En **diciembre 2025** el sistema entraba en incidente al llegar a P90 (SPEI 2,799 / Autorizador 3,266,
ventana 5 min). Tras las mejoras (**leak-fix** mar-2026 + **Power 10** jun-2026) sostuvo, **sin un solo
incidente**, hasta **SPEI 8,889 / Autorizador 4,007 txn/min** (máx 5 min, abr–ago 2026). El factor
demostrado es `k = máx_sostenido_post ÷ P90_dic` → **SPEI ×3.18, Autorizador ×1.23**. Son **cotas
inferiores** (aún no tocamos el nuevo techo). El ×1.23 de Autorizador es conservador (canal estable,
no se ha estresado más allá de ~4,000). Los umbrales con mejoras = P70/P90 × k, aplicado **mes a mes**.

## Evolución mensual — P70/P90 por canal (txn/min)

| Mes | SPEI P70 | SPEI P90 | Aut P70 | Aut P90 | Zona riesgo | Correl. |
|-----|----------|----------|---------|---------|-------------|---------|
| 2025-01 | 1,672 | 2,054 | 2,588 | 2,704 | 17.2% | 0.559 |
| 2025-02 | 1,625 | 2,203 | 2,659 | 2,834 | 19.0% | 0.605 |
| 2025-03 | 1,672 | 2,265 | 2,743 | 2,908 | 19.8% | 0.547 |
| 2025-04 | 1,683 | 2,225 | 2,926 | 3,096 | 16.3% | 0.373 |
| 2025-05 | 1,753 | 2,257 | 2,800 | 2,968 | 20.7% | 0.596 |
| 2025-06 | 1,762 | 2,257 | 2,742 | 2,896 | 21.8% | 0.596 |
| 2025-07 | 1,863 | 2,127 | 2,708 | 2,816 | 18.7% | 0.544 |
| 2025-08 | 1,869 | 2,378 | 2,815 | 3,022 | 20.0% | 0.576 |
| 2025-09 | 1,916 | 2,433 | 2,832 | 2,983 | 18.7% | 0.478 |
| 2025-10 | 2,014 | 2,458 | 2,887 | 3,022 | 18.1% | 0.576 |
| 2025-11 | 2,024 | 2,716 | 2,989 | 3,263 | 18.4% | 0.585 |
| 2025-12 | 2,237 | 2,789 | 3,019 | 3,306 | 14.9% | 0.336 |
| 2026-01 | 1,992 | 2,565 | 2,769 | 2,925 | 19.2% | 0.642 |
| 2026-02 | 2,034 | 2,667 | 2,889 | 3,127 | 19.9% | 0.63 |
| 2026-03 | 2,033 | 2,482 | 3,007 | 3,160 | 19.1% | 0.528 |
| 2026-04 | 2,055 | 2,538 | 2,989 | 3,140 | 19.7% | 0.52 |
| 2026-05 | 2,121 | 2,643 | 3,060 | 3,238 | 20.5% | 0.582 |
| 2026-06 | 2,139 | 2,556 | 3,078 | 3,248 | 19.6% | 0.481 |
| 2026-07 | 2,214 | 2,558 | 3,090 | 3,249 | 20.4% | 0.431 |

> Los umbrales de cada canal suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador
> ~+9%/año): cada canal cruza su P70/P90 cada vez más seguido y la zona de riesgo (co-ocurrencia)
> se ensancha, comiéndose el margen del Informix actual. Es el argumento cuantitativo de capacidad
> para la migración.

---

*v1.2.0 · Generado por generators/build-percentiles-correlacionados.py · P70/P90 por canal (sin
combinado) · evolución mensual · gráfica en
`percentiles-correlacionados-evolucion.html`.*
