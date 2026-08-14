# D10 · Sucursales — Baseline de Performance

> **Componente:** Informix · SPE-AM-001 · TEST Phase
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 POWER-AIX → Aurora PostgreSQL
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
-- Instrumentar el SP que llama a bdisuc:sp_nombre() para registrar:
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
| `sp_consultadatospiezas_bym3` | 381 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_consutacat_dictamen_bym` | 378 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_consultadatospiezas_bym3_totales` | 376 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_consultadatospiezas_bym2` | 376 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_consultacat_estatus_bym` | 375 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |

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

| Patrón | Impacto en `bdisuc` | Preparación |
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
  let res = http.post('https://api.target/bdisuc/v1/endpoint', payload);
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

**Total llamadas dominio:** 11,184 · **Total errores:** 188 · **Error rate global:** 1.68%

### Top SPs por volumen

| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |
|----|-------------|-------------|--------|------------------------------|
| `pasecont_web` | 4,173 | 0 | 0.0% | — |
| `sp_atms_web` | 1,491 | 0 | 0.0% | — |
| `sp_valfcfs_web` | 964 | 0 | 0.0% | — |
| `cambio_perfil_web` | 728 | 0 | 0.0% | — |
| `sp_faltsob_atm_ofi_web` | 706 | 78 | 11.05% | — |
| `sp_guardabitacora_atm` | 648 | 0 | 0.0% | — |
| `sp_reversafaltsob_web` | 639 | 1 | 0.16% | — |
| `sp_limiteperfil_web` | 369 | 0 | 0.0% | — |
| `sp_valida_oper_atm` | 323 | 4 | 1.24% | — |
| `sp_arqueossuc_atm_web` | 286 | 0 | 0.0% | — |
| `sp_obtieneultimadotacion_atm` | 274 | 0 | 0.0% | — |
| `Sp_validadotaatm_web` | 112 | 95 | 84.82% | — |
| `sp_validahora` | 111 | 3 | 2.7% | — |
| `sp_monitor_atm_admin_ofi_web` | 89 | 0 | 0.0% | — |
| `sp_guardar_bitacora_cajeros` | 69 | 0 | 0.0% | — |
| `sp_soldocta_atm_ofi_web` | 68 | 1 | 1.47% | — |
| `sp_dotatm_web` | 22 | 0 | 0.0% | — |
| `sp_traefolios` | 21 | 5 | 23.81% | — |
| `sp_sesioncaja_web` | 21 | 0 | 0.0% | — |
| `sp_traemontosdota_web` | 20 | 0 | 0.0% | — |

### Distribución horaria (llamadas con dominio mapeado)

| Hora CDMX | Llamadas |
|-----------|----------|

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
