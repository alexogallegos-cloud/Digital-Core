# Percentiles Correlacionados — SPEI y Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.6.0 (mensual · ventana 10 min · mejora medida por incidentes 7→0) · regenerable con `python generators/build-percentiles-correlacionados.py`

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

## Umbrales actuales (último mes 2026-07) — por canal

| Canal | P70 (alerta) | P90 (incidencia) |
|-------|-------------|------------------|
| SPEI | 2,217 | 2,542 |
| Autorizador | 3,090 | 3,246 |

- Zona de riesgo (ambos ≥ su P70 a la vez): **20.5%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.453**.

## Mejora demostrada (medida, no derivada de un factor)

Ver `knowledge-base/autorizador/mejoras-2026.md`. **No** se expresa como un multiplicador de capacidad:
el minxmin mide throughput (txn servidas/min), no latencia ni utilización, así que no contiene
limpiamente la señal que cambiaron las mejoras. Se mide con datos duros:

- **Encolamientos**: 7 incidentes (29-nov-2025 → 12-ene-2026) → **0** después
  (feb-2026 = primer mes limpio, tras el balanceo automático de colas SPEI del 15-feb).
- **Duración de incidente**: 1.5–7.5 h (nov-dic 2025) → **18.5 min** post-Power10
  (−93% de impacto económico por evento: $663 MDP del INC-20251129 → ~$46 MDP equivalente).
- **Capacidad de cómputo**: Power 8 → Power 10 (activo 7-jun-2026). El ratio rPerf/CPW exacto para
  dimensionar el target es `[DATO-REQUERIDO]` del SME DBA/Mainframe (modelos exactos Power 8 y Power 10).

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
combinado) · ventana 10 min · evolución mensual · mejora medida (encolamientos 7→0, duración −93%) · gráfica en
`percentiles-correlacionados-evolucion.html`.*
