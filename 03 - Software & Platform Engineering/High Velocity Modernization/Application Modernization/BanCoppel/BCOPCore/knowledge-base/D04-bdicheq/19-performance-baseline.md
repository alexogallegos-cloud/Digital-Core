# D04 · Cheques / Cuentas — Baseline de Performance

> **Componente:** BCOPCore · SPE-AM-001 · TEST Phase
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 POWER-AIX → Aurora PostgreSQL
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
-- Instrumentar el SP que llama a bdicheq:sp_nombre() para registrar:
--   tiempo_inicio DATETIME YEAR TO FRACTION(5)
--   tiempo_fin    DATETIME YEAR TO FRACTION(5)
--   duracion_ms = (tiempo_fin - tiempo_inicio) * 1000

-- Opción B: IBM Informix Performance Monitor (onstat -g all)
-- onstat -g ses    -- sesiones activas y tiempos
-- onstat -g sql    -- queries SQL activos
```

## Baseline por SP (a capturar — todos [SME-PENDING])

| SP | Fan-in (callers) | p50 (ms) | p95 (ms) | p99 (ms) | TPS pico |
|----|-----------------|---------|---------|---------|---------|
| `cargo_ref` | 561 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `abono_ref` | 520 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `reversion` | 377 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_generafolionomina` | 253 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `bloqueo_cta` | 184 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |

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

| Patrón | Impacto en `bdicheq` | Preparación |
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
  let res = http.post('https://api.target/bdicheq/v1/endpoint', payload);
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

**Total llamadas dominio:** 409,248 · **Total errores:** 19,345 · **Error rate global:** 4.73%

### Top SPs por volumen

| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |
|----|-------------|-------------|--------|------------------------------|
| `cons_sdos2_web` | 85,881 | 1,104 | 1.29% | `0000`=1 |
| `sp_notif_cub_vent_upd` | 69,971 | 4 | 0.01% | `00000`=69544, `0000`=1, `00008`=1 |
| `sp_retiro_sd` | 41,546 | 703 | 1.69% | `00000`=40663, `00009`=124, `00010`=60 |
| `sp_consultavalorparametro` | 40,501 | 0 | 0.0% | — |
| `sp_whatscoppel_consdos` | 32,975 | 16,048 | 48.67% | `00000`=16745, `00115`=14270, `00111`=1851 |
| `abono_ref_web` | 27,669 | 121 | 0.44% | `00000`=1 |
| `sp_abono_sd` | 25,414 | 220 | 0.87% | `00000`=25113, `00009`=214, `00027`=4 |
| `cargo_ref` | 23,053 | 239 | 1.04% | `000`=1 |
| `sp_notif_cub_vent_cons` | 8,661 | 1 | 0.01% | `00000`=5910, `11111`=2723 |
| `sp_crea_sd` | 6,394 | 51 | 0.8% | `00000`=6305, `00020`=8, `00017`=1 |
| `consctesfirxnumctaper2` | 6,006 | 0 | 0.0% | — |
| `consnomtit` | 4,001 | 375 | 9.37% | — |
| `sp_confirmapinoffline` | 3,489 | 19 | 0.54% | — |
| `consfirmantes_web` | 3,079 | 0 | 0.0% | — |
| `sp_insertarespuestacuestionario` | 2,831 | 110 | 3.89% | `00000`=1 |
| `sp_consultapreguntas` | 2,774 | 0 | 0.0% | — |
| `sp_consmov_sd` | 2,260 | 127 | 5.62% | `00000`=2127, `00019`=126 |
| `sp_validatarrepos_web` | 2,106 | 0 | 0.0% | `00000`=1 |
| `sp_mini21` | 1,985 | 0 | 0.0% | — |
| `sp_confirma_prestamo_cpl` | 1,858 | 0 | 0.0% | — |

### Distribución horaria (llamadas con dominio mapeado)

| Hora CDMX | Llamadas |
|-----------|----------|

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
