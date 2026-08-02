# D03 · Créditos — Baseline de Performance

> **Componente:** BCOPCore · SPE-AM-001 · TEST Phase
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 POWER-AIX → Aurora PostgreSQL
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
-- Instrumentar el SP que llama a bdicred:sp_nombre() para registrar:
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
| `sp_consulta_saldos_general` | 435 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_mon_buro_conssolcredlincred2` | 325 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_inserta_productos` | 305 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_consulta_frecpago` | 303 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_conspoliticacreditoprod` | 303 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |

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

| Patrón | Impacto en `bdicred` | Preparación |
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
  let res = http.post('https://api.target/bdicred/v1/endpoint', payload);
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

**Total llamadas dominio:** 128,566 · **Total errores:** 43,706 · **Error rate global:** 33.99%

### Top SPs por volumen

| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |
|----|-------------|-------------|--------|------------------------------|
| `sp_cons_param_banderaprod_web` | 42,060 | 0 | 0.0% | `00000`=3, `0000`=1 |
| `sp_consulta_pre_aprobado` | 38,210 | 29,946 | 78.37% | `00008`=6094, `00000`=1413, `00005`=415 |
| `obt_datos_caratula` | 10,621 | 8,235 | 77.54% | — |
| `sp_buscarctesamigrar_web` | 6,631 | 839 | 12.65% | — |
| `sp_consulta_saldos_cobranza_sucs_web` | 6,047 | 0 | 0.0% | — |
| `sp_tdcoro_web` | 2,273 | 1,719 | 75.63% | — |
| `sp_guarda_resp_pre_aprobado` | 2,225 | 46 | 2.07% | `00000`=1536, `00002`=22 |
| `cons_cta_o_tar_per_web` | 2,112 | 11 | 0.52% | `00000`=1 |
| `sp_constiporepostar` | 2,087 | 163 | 7.81% | — |
| `sp_consultafechavenc` | 1,883 | 3 | 0.16% | `00000`=1 |
| `altatarrepos_n_web` | 1,536 | 0 | 0.0% | — |
| `sp_actestatustarjeta` | 1,441 | 11 | 0.76% | — |
| `sp_principal_suc_rr` | 1,390 | 32 | 2.3% | — |
| `sp_borrardigi` | 1,319 | 1,308 | 99.17% | — |
| `sp_registradatos_motor_pp` | 655 | 1 | 0.15% | — |
| `sp_evaldispefec_cred` | 650 | 51 | 7.85% | — |
| `sp_grababitacoraact` | 650 | 0 | 0.0% | — |
| `consfircredper2` | 631 | 0 | 0.0% | — |
| `sp_val_datos_promo` | 516 | 435 | 84.3% | — |
| `sp_consulta_incremento_linea_tc` | 486 | 303 | 62.35% | — |

### Distribución horaria (llamadas con dominio mapeado)

| Hora CDMX | Llamadas |
|-----------|----------|

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
