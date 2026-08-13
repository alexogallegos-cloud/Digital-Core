# D02 · Integración y Autenticación — Baseline de Performance

> **Componente:** Informix · SPE-AM-001 · TEST Phase
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 POWER-AIX → Aurora PostgreSQL
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
-- Instrumentar el SP que llama a bdinteg:sp_nombre() para registrar:
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
| `sp_cnsif_confirmaejecutivo` | 2,400 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_cnsif_permisosejecutivo` | 621 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_valida_perfil_usuario` | 388 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_desc_ret` | 358 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |
| `sp_cuentadoctos_soc` | 354 | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] ms | [SME-PENDING] TPS |

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

| Patrón | Impacto en `bdinteg` | Preparación |
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
  let res = http.post('https://api.target/bdinteg/v1/endpoint', payload);
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

**Total llamadas dominio:** 789,544 · **Total errores:** 34,519 · **Error rate global:** 4.37%
**Hora pico:** 19:00 CDMX (420 llamadas)

### Top SPs por volumen

| SP | Llamadas/día | Errores/día | Error% | Códigos respuesta frecuentes |
|----|-------------|-------------|--------|------------------------------|
| `sp_consulta_huella_actual` | 206,338 | 136 | 0.07% | `00000`=14, `00115`=1 |
| `sp_conhuella` | 59,984 | 49 | 0.08% | — |
| `sp_obtparamsorteo` | 47,058 | 1 | 0.0% | — |
| `consnumcte` | 46,370 | 0 | 0.0% | — |
| `sp_validar_rostro_cliente` | 43,538 | 1 | 0.0% | — |
| `sp_consulta_cte_huella` | 40,079 | 78 | 0.19% | `0000`=3, `00000`=1 |
| `sp_adm_consulta_suc` | 39,710 | 0 | 0.0% | — |
| `sp_consulta_datos_cte_coppel` | 39,497 | 1,580 | 4.0% | — |
| `val_fechas_web` | 33,364 | 355 | 1.06% | — |
| `sp_consultacten2` | 29,221 | 29,166 | 99.81% | — |
| `valor_divisa_pesos` | 23,719 | 0 | 0.0% | — |
| `sp_ws_valida_cotel` | 20,974 | 377 | 1.8% | `00000`=4 |
| `sp_ws_obtiene_prod` | 18,281 | 0 | 0.0% | `0000`=18182 |
| `sp_adm_cons_ejecutivo` | 13,869 | 22 | 0.16% | — |
| `sp_validactehuella` | 10,262 | 0 | 0.0% | — |
| `sp_valida_folio_sms_coppel_web` | 10,066 | 0 | 0.0% | — |
| `sp_valida_huellacte_dec` | 9,379 | 290 | 3.09% | — |
| `sp_valida_huellaine_cte` | 9,367 | 59 | 0.63% | — |
| `sp_obtenernaccliente` | 9,181 | 20 | 0.22% | — |
| `consedadcte_web` | 9,099 | 0 | 0.0% | — |

### Distribución horaria (llamadas con dominio mapeado)

| Hora CDMX | Llamadas |
|-----------|----------|
| 00:00 | 61 |
| 01:00 | 27 |
| 02:00 | 36 |
| 03:00 | 19 |
| 04:00 | 8 |
| 05:00 | 23 |
| 06:00 | 27 |
| 07:00 | 60 |
| 08:00 | 88 |
| 09:00 | 143 |
| 10:00 | 207 |
| 11:00 | 163 |
| 12:00 | 167 |
| 13:00 | 181 |
| 14:00 | 183 |
| 15:00 | 196 |
| 16:00 | 230 |
| 17:00 | 131 |
| 19:00 | 420 |
| 20:00 | 292 |
| 21:00 | 129 |
| 22:00 | 144 |
| 23:00 | 74 |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
