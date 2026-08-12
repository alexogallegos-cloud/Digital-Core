# D05 · Saldos y Cuentas — Baseline de Performance

> **Componente:** BCOPCore · SPE-AM-001 · TEST Phase
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 POWER-AIX → Aurora PostgreSQL
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Propósito

Sin un baseline de performance del sistema Informix, no hay criterio objetivo para declarar que el target cumple los SLOs. Este documento captura las métricas de producción antes del cutover y define los umbrales que el target debe igualar o superar.

## Metodología de captura

```sql
-- En Informix, durante 7 días de producción normal:
-- Capturar via sysmaster o instrumento el SP wrapper:

-- Opción A: Medir desde el canal (bdicnweb)
-- Instrumentar el SP que llama a bdisac:sp_nombre() para registrar:
--   tiempo_inicio DATETIME YEAR TO FRACTION(5)
--   tiempo_fin    DATETIME YEAR TO FRACTION(5)
--   duracion_ms = (tiempo_fin - tiempo_inicio) * 1000

-- Opción B: IBM Informix Performance Monitor (onstat -g all)
-- onstat -g ses    -- sesiones activas y tiempos
-- onstat -g sql    -- queries SQL activos
```

## Volúmenes de producción confirmados desde logs (2026-04-24)

> **Fuente:** `source/logs/transacciones_bus_20260424_*.log` · Incorporado: 2026-08-01
> Estos son volúmenes reales de un día de producción — usar como baseline de throughput para pruebas de carga.

| SP | Llamadas confirmadas/día | Tasa de error | Fuente | Notas |
|----|--------------------------|---------------|--------|-------|
| `sp_app_confirmpayment` | 61,280 | 8.7% (5,163 fallidas) | Logs bus 2026-04-24 | Integración APPRIZA; errores = codRetorno 9999 |
| `sp_app_recordorder` | 56,626 | — | Logs bus 2026-04-24 | Registra PENDIENTE en fallos; dominio `???` sin DSN |
| `sp_app_getorder` | 55,126 | — | Logs bus 2026-04-24 | Consulta estado de orden; dominio `???` sin DSN |

**Nota sobre SPs con dominio `???`:** `sp_app_recordorder` y `sp_app_getorder` no tienen prefijo DSN en los logs — no están mapeados al esquema de 12 dominios actuales. Ver P655-R008 en migration-risk-register.md.

**Tiempo de transacción observado (APPRIZA):**
- Flujo exitoso: inicio → confirmación APPRIZA → ~1 minuto total
- Flujo fallido: primera excepción → estado PENDIENTE → 5+ horas de reintentos sin resolución

## Baseline por SP (latencias — [SME-PENDING] requeiren instrumentación en producción)

| SP | Fan-in (callers) | p50 (ms) | p95 (ms) | p99 (ms) | TPS pico |
|----|-----------------|---------|---------|---------|---------|
| `sp_app_confirmpayment` | — | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | ~71 TPS (61,280/día) |
| `sp_app_recordorder` | — | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | ~66 TPS |
| `sp_app_getorder` | — | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | ~64 TPS |
| `sp_sac_guardamensajeerror` | 321 | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] |
| `sp_validanombenefbts` | 243 | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] |
| `sp_sac_consucursales` | 195 | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] |
| `sp_validabts` | 182 | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] |
| `sp_obtieneparametro` | 176 | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] | [SME-PENDING] |

## SLOs del sistema target

Una vez capturado el baseline Informix, el target debe cumplir:

| Métrica | Criterio | Verificación |
|---------|----------|-------------|
| Latencia p50 | ≤ baseline Informix p50 + 10% | Prueba de carga con datos reales |
| Latencia p99 | ≤ baseline Informix p99 + 20% | Prueba de carga sostenida 1 hora |
| Throughput pico | ≥ 100% del baseline | Prueba de stress en ambiente pre-prod |
| Error rate | < 0.01% | Parallel-run 72 horas |
| Disponibilidad | ≥ 99.9% mensual | CloudWatch SLO alarms |
| Tiempo de recovery (RTO) | < 30 min | Failover test Aurora Multi-AZ |

## Patrones de carga específicos de BanCoppel

| Patrón | Impacto en `bdisac` | Preparación |
|--------|-------------------|------------|
| Ciclo quincenal (día 15 y último hábil) | Pico de hasta 3x el volumen normal | Prueba de carga con 3x baseline |
| Cierre nocturno (22:00-02:00 CDMX) | Batch jobs + transacciones diurnas finales | Prueba de carga nocturna |
| Inicio de mes (día 1) | Alto volumen de pagos y transferencias | Prueba de carga específica |
| Incidente en canal digital | Tráfico concentrado en SPs de error/recuperación | Prueba de chaos engineering |

## Herramientas de prueba de carga

```javascript
// k6 script ejemplo — adaptar para el SP de mayor fan-in de este dominio
// import http from 'k6/http';
// import { check } from 'k6';

export let options = {
  stages: [
    { duration: '5m', target: 100 },   # ramp-up
    { duration: '30m', target: 1404 }, # pico (fan-in del SP principal)
    { duration: '5m', target: 0 },     # ramp-down
  ],
};

export default function() {
  // [SME-PENDING] Completar con el contrato API del 16-api-contract.md
  let res = http.post('https://api.target/bdisac/v1/endpoint', payload);
  check(res, { 'status 200': (r) => r.status === 200 });
}
```

## Acciones requeridas

- [ ] **QA Lead — Equivalencia Funcional** — instrumentar los SPs críticos para captura de latencias
- [ ] **DBA IBM Informix** — ejecutar `onstat -g ses` durante 7 días en producción
- [ ] **Cloud Architect AWS** — provisionar ambiente de prueba de carga (misma spec que producción)
- [ ] **SRE & AIOps** — configurar CloudWatch dashboards para métricas de performance

---
*Generado por: QA Lead — Equivalencia Funcional · 2026-07-03 · [SME-PENDING] baseline real requerido de DBA Informix*

<!-- LOG-DATA-BEGIN -->
## Volúmenes de producción confirmados — Logs 2026-04-24
> Fuente: `source/logs/transacciones_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total llamadas dominio:** 945,217 · **Total errores:** 38,490 · **Error rate global:** 4.07%

### Top SPs por volumen

| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |
|----|-------------|-------------|--------|------------------------------|
| `sp_consflagretarj` | 93,228 | 0 | 0.0% | — |
| `sp_bitacorawstae` | 81,189 | 571 | 0.7% | `00000`=80368, `00001`=414, `00002`=97 |
| `sp_aplica_pago_con_cargo_msw` | 80,959 | 297 | 0.37% | `00000`=80401, `00320`=189, `00305`=61 |
| `sp_confpagoservicio_hs` | 77,786 | 0 | 0.0% | `00000`=77410 |
| `sp_app_confirmpayment` | 61,686 | 5,331 | 8.64% | `00000`=55932, `1100`=5166 |
| `sp_app_recordorder` | 56,951 | 11 | 0.02% | `00000`=2 |
| `sp_val_clubproteccion_web` | 56,818 | 1 | 0.0% | — |
| `sp_app_getorder` | 55,492 | 0 | 0.0% | `00000`=1 |
| `sp_obtengrupocliente` | 51,599 | 0 | 0.0% | — |
| `sp_obtenerparametro` | 42,980 | 0 | 0.0% | — |
| `valida_abono_ref_web` | 23,295 | 0 | 0.0% | — |
| `sp_sorteobancoppel_web` | 18,118 | 0 | 0.0% | — |
| `sp_inser_alerta_exlimblo` | 14,820 | 0 | 0.0% | — |
| `sp_conssdogen` | 14,670 | 0 | 0.0% | — |
| `sp_consulta_producto` | 11,843 | 0 | 0.0% | — |
| `sp_consulta_cardif` | 11,736 | 1,031 | 8.78% | `00003`=749, `00002`=286, `00005`=6 |
| `sp_consulta_appriza_web` | 11,697 | 2 | 0.02% | `0000`=1, `00000`=1 |
| `cons_sdos2_web` | 11,383 | 0 | 0.0% | — |
| `sp_conssdoticket_web` | 9,294 | 0 | 0.0% | — |
| `totcomp2_web` | 8,569 | 0 | 0.0% | — |

### SPs con alta tasa de error — Mecanismo verificado (errores_bus · 2026-08-01)

> Fuente complementaria: `source/logs/errores_bus_2026-04-24_*.txt` · Estos SPs no aparecen en el top de volumen porque son accedidos por canales de error o por otros dominios; sus tasas y mecanismos se documentan en `D05/06-exceptions.md` LOG-DATA. Se incluyen aquí por su implicación directa en los SLOs del target.

| SP | Llamadas/día | Error% | Mecanismo | Clasificación | Evidencia |
|----|-------------|--------|-----------|---------------|-----------|
| `sp_consultasaldocortemin` | 6,651 | 99.85% | CWE-390: ON EXCEPTION convierte fallo cross-DB en código numérico; `top_resp_codes: {}` vacío | Defecto de código | bdicred_sp_consultasaldocortemin_mx2.sql:42-44 |
| `sp_consultaregtarjeta` | 6,560 | 97.29% | Gating query — `00002` = "tarjeta/lote no encontrado" es respuesta de negocio esperada | Diseño de negocio | intercard_sp_consultaregtarjeta.sql:29-34 |
| `sp_cat_carac_tae` | 7,330 | 96.77% | [SME-PENDING] mecanismo no verificado en código fuente | Pendiente DBA | — |
| `sp_reverso_msw` | 8,034 | 69.22% | Restricción de fecha: `cFechaFormat <> pFecha → '00400'` (reverso solo mismo día) | Restricción de negocio | bdisac_sp_reverso_msw.sql:60 |

**Implicación para los SLOs del target:**
- `sp_consultasaldocortemin`: el 99.85% es el baseline Informix **con defecto activo**. El SLO `Error rate < 0.01%` aplica al target post-fix, no al Informix actual. Recalibrar a `< 5%` post-corrección.
- `sp_consultaregtarjeta` y `sp_reverso_msw`: las tasas son diseño de negocio. El target debe replicar los mismos códigos de retorno — no aplicar SLO de `< 0.01%` a estos SPs.
- `sp_cat_carac_tae`: requiere verificación de código fuente antes de definir umbral SLO.

### Distribución horaria (llamadas con dominio mapeado)

| Hora CDMX | Llamadas |
|-----------|----------|

*Generado por generate-kb-from-logs.py · 2026-08-01*
*Actualizado: DT-Riesgos · 2026-08-01 · Mecanismo verificado en código para sp_consultasaldocortemin (CWE-390), sp_consultaregtarjeta (gating), sp_reverso_msw (restricción de fecha)*
<!-- LOG-DATA-END -->
