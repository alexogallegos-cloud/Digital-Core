# D14 · Banca Electrónica Institucional (BEI) — Baseline de Performance

> **Componente:** BCOPCore · SPE-AM-001 · TEST Phase
> **Base de datos:** bdibei → Aurora PostgreSQL
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- DBA — IBM Informix IDS (métricas de producción Informix — Etapa 2) ← FUENTE DE VERDAD
- QA Lead — Equivalencia Funcional (definición de umbrales SLO target)
- Cloud Architect — AWS Banking (sizing del target Aurora + ECS)
- SRE & AIOps (configuración de CloudWatch dashboards y alarmas)
- Specialist — Informix SPL Analysis (análisis de volúmenes desde logs)

> **Estado:** baseline parcial. Los 42 SPs del callgraph no tienen métricas directas de bdibei en los logs del 2026-04-24 (los logs no muestran DSN=bdibei). Los 294 SPs aislados — especialmente el batch de nómina — requieren análisis específico de logs en período quincenal.
---

## Propósito

Sin un baseline de performance del sistema Informix en bdibei, no hay criterio objetivo para declarar que el target cumple los SLOs. El riesgo principal es el batch de nómina: si el target es más lento que el legacy, el batch puede no completar en la ventana nocturna disponible.

---

## Volúmenes de producción — estado actual

Los logs del 2026-04-24 corresponden a un día de operación regular. El dominio `bdibei` no aparece con DSN explícito en los logs disponibles, lo que es consistente con la anomalía de los 294 SPs aislados.

| Fuente de métricas | Estado | Acción requerida |
|-------------------|--------|-----------------|
| Logs ESB 2026-04-24 | Sin DSN explícito bdibei | `[SME-PENDING]` — filtrar logs por servicio ESB que llama a bdibei |
| `onstat -g all` Informix | `[DATO-REQUERIDO]` | DBA debe ejecutar durante ventana quincenal |
| Scheduler AIX — logs de job | `[DATO-REQUERIDO]` | Obtener duración histórica del batch de nómina |
| Canal empresa (portal BEI) | `[DATO-REQUERIDO]` | Instrumentar con APM en Informix legacy antes del cutover |

---

## Baseline estimado — operaciones en línea BEI

> `[SME-PENDING]` — todos los valores marcados requieren instrumentación en producción Informix.

| Operación | SP involucrado | Calls/día estimados | p50 (ms) | p95 (ms) | TPS pico |
|-----------|---------------|--------------------|----|----|----|
| Consulta convenio empresa | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` |
| Alta beneficiario | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` |
| Consulta estado dispersión | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` |
| Autenticación empresa (OTP) | `getrandomcode` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` |
| Consulta límite convenio | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` | `[SME-PENDING]` |

---

## Baseline crítico — Batch de Nómina

El batch de nómina es el proceso de mayor riesgo de performance en el dominio BEI. Requiere métricas específicas:

| Métrica | Valor actual (Informix) | Valor objetivo (Aurora) | Acción si no se cumple |
|---------|------------------------|------------------------|----------------------|
| Duración total del batch | `[DATO-REQUERIDO]` | ≤ duración Informix × 1.2 | Optimizar Step Functions + conexiones pool |
| Registros procesados por minuto | `[DATO-REQUERIDO]` | ≥ throughput Informix | Aumentar concurrencia (MaxConcurrency Step Functions) |
| Tiempo de confirmación SPEI por beneficiario | `[DATO-REQUERIDO]` | `[SME-PENDING]` | Circuit breaker más agresivo |
| Tiempo de recovery ante error ESB | Sin medición | ≤ 30 segundos (retry + checkpoint) | Ajustar backoff exponencial |
| Completitud del batch (beneficiarios OK / total) | `[DATO-REQUERIDO]` | ≥ 99.9% de beneficiarios acreditados | Fix urgente si < 99.9% |

**Metodología de captura del baseline batch en Informix:**

```bash
# En el servidor AIX, durante la próxima quincena, capturar:
# 1. Hora de inicio del job
grep "bei_nomina\|dispersion_nomina" /var/log/scheduler_*.log | grep "START\|END"

# 2. Performance del motor Informix durante el batch
onstat -g ses -r 60 > /tmp/bei_batch_session_$(date +%Y%m%d%H%M).log &

# 3. Número de registros procesados (si hay log en bei_bitacora)
# [SME-PENDING] consulta exacta depende de la estructura del log BEI
```

---

## Patrones de carga específicos del dominio BEI

| Patrón | Descripción | Impacto en `bdibei` | Preparación para test |
|--------|-------------|--------------------|-----------------------|
| **Quincena activa** (días 1–3 y 15–18) | Ejecución del batch de nómina | Pico de carga nocturna · batch + operaciones en línea simultáneas | Prueba de carga específica en ventana nocturna |
| Día de pago de proveedores | Dispersiones masivas adicionales | Segundo pico de carga en el día | Prueba de carga con dispersiones simultáneas |
| Fin de mes | Cierre contable + comisiones + reportes CNBV | Triple carga: batch + reportes + comisiones | Prueba de carga de cierre mensual |
| Onboarding masivo de empresa grande | Alta de miles de beneficiarios en `bei_beneficiarios` | Carga puntual alta en INSERT | Prueba de carga de inserción masiva |
| Error ESB (INC-006 escenario) | 4394/3743 causan reintentos | Carga extra por reintentos del circuit breaker | Chaos engineering con inyección de errores ESB |

---

## SLOs del sistema target

| Métrica | Criterio | Fuente de medición |
|---------|----------|--------------------|
| Latencia p50 (operaciones en línea) | ≤ baseline Informix p50 + 10% | CloudWatch / X-Ray |
| Latencia p95 (operaciones en línea) | ≤ baseline Informix p95 + 20% | CloudWatch |
| Latencia p99 (operaciones en línea) | ≤ 500ms (SLO-SPE-02) | CloudWatch |
| Disponibilidad mensual | ≥ 99.9% (SLO-SPE-01) | CloudWatch SLO alarms |
| Error rate | < 0.1% (excluye rechazos de negocio esperados) | CloudWatch |
| Throughput batch nómina | ≥ baseline Informix (registros/minuto) | Step Functions metrics |
| Duración batch nómina | ≤ baseline Informix × 1.2 | Step Functions ExecutionTime |
| Disponibilidad batch | ≥ 99.9% (no puede fallar en quincena) | CloudWatch alarms |
| RTO (recovery ante fallo) | < 30 minutos | DR drill |
| RPO (datos recuperables) | < 5 minutos (Multi-AZ Aurora) | Aurora backup config |

---

## Herramienta de prueba de carga — esquema k6

```javascript
// k6 load test — batch de nómina BEI simulation
import http from 'k6/http';
import { check, sleep } from 'k6';

export let options = {
  stages: [
    { duration: '5m', target: 50 },    // ramp-up
    { duration: '30m', target: 500 },  // carga normal BEI
    { duration: '10m', target: 2000 }, // pico de quincena (estimado)
    { duration: '5m', target: 0 },     // ramp-down
  ],
  thresholds: {
    http_req_duration: ['p(95)<500'],  // SLO-SPE-02
    http_req_failed: ['rate<0.001'],   // SLO-SPE-03
  },
};

export default function() {
  // Dispersión de nómina (principal operación)
  let res = http.post(
    'https://api-stg.bancoppel.com/bei/v1/dispersiones',
    JSON.stringify({
      numConvenio: __ENV.TEST_CONVENIO,
      tipoDispersion: 'NM',
      beneficiarios: generarBeneficiariosTest(100) // lote de 100
    }),
    { headers: { 'Content-Type': 'application/json',
                 'Authorization': `Bearer ${__ENV.TEST_TOKEN}` } }
  );
  check(res, {
    'status 202': (r) => r.status === 202,
    'folio presente': (r) => JSON.parse(r.body).folio !== undefined,
  });
  sleep(1);
}
```

---

## Acciones requeridas para completar el baseline

- [ ] `[DATO-REQUERIDO]` DBA IBM Informix — instrumentar el batch de nómina con `onstat -g ses` en la próxima quincena.
- [ ] `[SME-PENDING]` Domain Expert BanCoppel — confirmar duración esperada del batch de nómina actual.
- [ ] `[SME-PENDING]` Domain Expert — confirmar número típico de beneficiarios por lote de nómina.
- [ ] Cloud Architect AWS — provisionar ambiente de prueba de carga con mismas specs que producción.
- [ ] SRE & AIOps — configurar CloudWatch dashboards con métricas BEI antes del parallel-run.
- [ ] QA Lead — ejecutar prueba de carga de batch nocturno antes de go/no-go de RELEASE.

---
*Generado por: QA Lead — Equivalencia Funcional + SRE & AIOps · 2026-08-03 · Fuente: sp-specs-bdibei.md + patrón de carga BEI inferido + SLOs BCOPCore. Baseline real PENDIENTE instrumentación DBA Etapa 2.*
