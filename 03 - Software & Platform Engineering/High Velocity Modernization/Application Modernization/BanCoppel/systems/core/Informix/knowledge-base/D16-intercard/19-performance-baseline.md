# D16 · Intercard (Tarjetas) — Performance Baseline

> **Componente:** Informix · SPE-AM-001
> **Base de datos:** `intercard`
> **Última actualización:** 2026-08-03
> **Nota:** Métricas de producción `[SME-PENDING]` — pendiente carga de logs de producción de `intercard`.

---

## Inventario de SPs por volumen de LOC

| SP | LOC | Rules | Fan_in | Fan_out | Clasificación |
|----|----:|------:|-------:|--------:|---------------|
| `sp_carga_ctes_enrola` | 1,778 | 16 | 0 | 3 | God-proc batch |
| `sp_horasazules_obtener_tdc_clientes` | 1,333 | 6 | 0 | 2 | Alto LOC |
| `sp_consultartarjetas_debcred_can_iccat` | 1,226 | 1 | 2 | 1 | Alto LOC |
| `sp_contacto_vencimiento_credito` | 1,011 | 49 | 0 | 2 | God-proc batch |
| `sp_contacto_vencimiento_debito` | 998 | 46 | 0 | 2 | God-proc batch |
| `sp_activatarjeta_iccat` | 941 | 0 | 0 | 3 | Medio-alto LOC |
| `sp_limpiatarjeta_bloqueada_iccat` | 898 | 0 | 0 | 3 | Medio LOC |
| `sp_cancelacion_tarjeta` | 57 | 0 | 28 | 0 | Micro-SP (wrapper) |

**Total LOC D16:** `[SME-PENDING]` — pendiente suma completa de los 394 SPs.

---

## SP más invocado: `sp_cancelacion_tarjeta`

- **fan_in registrado en brain.db:** 28
- **Caller cross-domain confirmado:** `bdicred:reversion` (D03 Crédito)
- **LOC:** 57 — SP muy pequeño, probablemente un wrapper de UPDATE
- **Implicación:** alta frecuencia de invocación en escenarios de devolución de crédito. Su latencia en el target debe mantenerse baja (< 10ms P95) para no afectar el flujo de reversión en D03.

---

## Métricas de producción `[SME-PENDING]`

Los siguientes campos requieren carga de logs de producción de `intercard` (archivo: `source/logs/intercard_*.log`):

| Métrica | SP | Estado |
|---------|-----|--------|
| Llamadas/día | `sp_cancelacion_tarjeta` | `[DATO-REQUERIDO]` |
| Tasa de error | `sp_cancelacion_tarjeta` | `[DATO-REQUERIDO]` |
| Tiempo de ejecución P95 | `sp_cancelacion_tarjeta` | `[DATO-REQUERIDO]` |
| Frecuencia de ejecución batch | `sp_contacto_vencimiento_credito` | `[DATO-REQUERIDO]` |
| Registros procesados por ejecución | `sp_contacto_vencimiento_credito` | `[DATO-REQUERIDO]` |
| Frecuencia de ejecución batch | `sp_carga_ctes_enrola` | `[DATO-REQUERIDO]` |

---

## Benchmark de complejidad vs. dominio

| Dominio | SP más llamado | Fan_in | LOC God-proc | Rules máx |
|---------|---------------|-------:|-------------:|----------:|
| D05 bdisac | `sp_reportebts_edocta` | — | 10,152 | — |
| D11 bdicobranza | `sp_obtener_datos_cv_web` | — | — | — |
| **D16 intercard** | `sp_cancelacion_tarjeta` | 28 | 1,778 | 49 |
| D01 bdicnweb | — | — | — | — |

D16 tiene baja complejidad individual por SP (el god-proc más largo son 1,778 LOC vs. 10,152 en D05) pero alta densidad de reglas en los batch de contacto. El riesgo técnico está en la lógica de negocio, no en el volumen de código.

---

## SLO target para Wave 4

| SLO | Métrica | Objetivo |
|-----|---------|---------|
| SLO-D16-01 | Latencia P95 `sp_cancelacion_tarjeta` | < 10ms (actualmente SP de 57 LOC — muy rápido) |
| SLO-D16-02 | Completion rate batch contacto vencimiento | ≥ 99.9% de registros procesados por corrida |
| SLO-D16-03 | Availability servicio tarjetas (ICCAT) | ≥ 99.5% en horario de atención |
| SLO-D16-04 | Equivalencia funcional batch (golden master) | ≥ 99.99% de outputs idénticos |

---
*Generado: 2026-08-03 · métricas estructurales de brain.db · métricas de producción pendientes de carga de logs*
