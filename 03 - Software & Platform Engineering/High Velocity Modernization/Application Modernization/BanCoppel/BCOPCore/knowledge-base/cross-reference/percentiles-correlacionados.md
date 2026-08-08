# Percentiles Correlacionados — SPEI + Autorizador sobre Informix
> **Fuente**: pipeline `generators/forecast/capacity.py` (funcion `correlated_percentiles`)
> **DT dueño**: `dt/dt-autorizador-pagos/` · co-ref `dt/dt-spei/`, `dt/dt-riesgos/`
> **Versión**: 1.0.0 · regenerable con `python generators/build-percentiles-correlacionados.py`

## Metodología

**Cálculo de percentiles correlacionados**: mide la carga que SPEI y el Autorizador ejercen
**simultáneamente** sobre Informix (recurso compartido), en **ventanas de 5 minutos** (carga
sostenida — suaviza las ráfagas de 1 min de las que el sistema se restablece con buffer). Días
hábiles, horario operativo 07–23h.

- **P70 por canal** = umbral de alerta.
- **Zona de riesgo** = ambos canales ≥ su P70 a la vez.
- **Incidencia inminente** = ambos ≥ su P90.
- **Top-N de concurrencia sin caída** = capacidad sostenida demostrada.

A diferencia de sumar percentiles individuales (que asume independencia), esto respeta la
**correlación temporal**: los picos de ambos canales coinciden (mismo perfil intradía), por lo
que no se diversifican y la carga se apila sobre Informix.

## Umbrales actuales (2026-07)

| Canal | P70 (alerta) | P90 (incidencia) |
|-------|-------------|------------------|
| Autorizador | 2,990 | 3,172 |
| SPEI | 2,093 | 2,459 |
| **Combinado (Informix)** | **5,083** | **5,631** |

- Zona de riesgo (ambos ≥ P70): **20.4%** del tiempo operativo.
- Correlación intra-ventana: **r = 0.822**.
- Capacidad sostenida demostrada (top-5 concurrencia): **7,089 txn/min**
  (Autorizador 3,240 + SPEI 3,850).

## Evolución mensual (txn/min)

| Mes | P70 comb | P90 comb | Zona riesgo | Top-5 comb | Correl. |
|-----|----------|----------|-------------|------------|---------|
| 2025-01 | 4,036 | 4,610 | 18.8% | 6,403 | 0.781 |
| 2025-02 | 4,043 | 4,749 | 18.6% | 5,944 | 0.784 |
| 2025-03 | 4,133 | 4,880 | 18.9% | 6,192 | 0.752 |
| 2025-04 | 4,499 | 5,230 | 17.4% | 6,507 | 0.656 |
| 2025-05 | 4,366 | 5,077 | 19.0% | 6,732 | 0.745 |
| 2025-06 | 4,265 | 4,919 | 19.2% | 6,691 | 0.77 |
| 2025-07 | 4,410 | 4,857 | 18.5% | 6,439 | 0.782 |
| 2025-08 | 4,450 | 5,086 | 19.5% | 6,790 | 0.773 |
| 2025-09 | 4,461 | 5,202 | 19.2% | 6,863 | 0.734 |
| 2025-10 | 4,620 | 5,325 | 18.9% | 6,305 | 0.782 |
| 2025-11 | 4,635 | 5,355 | 18.6% | 6,513 | 0.804 |
| 2025-12 | 5,042 | 5,866 | 17.3% | 8,341 | 0.646 |
| 2026-01 | 4,520 | 5,306 | 18.4% | 6,494 | 0.754 |
| 2026-02 | 4,637 | 5,360 | 18.0% | 6,369 | 0.785 |
| 2026-03 | 4,786 | 5,499 | 18.9% | 7,551 | 0.697 |
| 2026-04 | 4,932 | 5,571 | 19.1% | 8,068 | 0.714 |
| 2026-05 | 4,862 | 5,546 | 18.9% | 8,444 | 0.74 |
| 2026-06 | 4,964 | 5,639 | 18.7% | 8,620 | 0.69 |
| 2026-07 | 5,083 | 5,631 | 20.4% | 7,089 | 0.822 |

> Los umbrales suben con el crecimiento orgánico (SPEI ~+20%/año, Autorizador ~+9%/año): la
> carga combinada cruza el P70/P90 cada vez más seguido, comiéndose el margen del Informix
> actual. Es el argumento cuantitativo de capacidad para la migración.

---

*v1.0.0 · Generado por generators/build-percentiles-correlacionados.py · gráfica de evolución en
`percentiles-correlacionados-evolucion.html`.*
