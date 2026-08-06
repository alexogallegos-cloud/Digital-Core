# D14 · bdibei (BEI — Banca Electrónica Institucional) — Observabilidad y Runbook

> **Componente:** BCOPCore · SPE-AM-001 · OPERATE Phase
> **Base de datos:** bdibei (Banca Electrónica Institucional / Pagos y Dispersiones Masivas)
> **Wave:** [SME-PENDING]
> **Última actualización:** 2026-08-03
> **Inventario:** 336 SPs analizados (42 en callgraph · 294 aislados — ver sp-specs-bdibei.md)

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional BEI — pagos masivos, dispersiones)
- Cybersecurity (PII, CNBV, LFPDPPP)
- SRE & AIOps (observabilidad y runbooks)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Perfil del dominio

| Atributo | Valor |
|----------|-------|
| SPs totales | 336 |
| SPs en callgraph | 42 |
| SPs aislados | 294 |
| Función | Banca Electrónica Institucional — pagos masivos, dispersiones, acceso empresarial |
| Riesgo migration | WARN — P655-R005 (ESB error codes no documentados) |

> **Nota:** Con 294 SPs aislados (87% del total), este dominio tiene la mayor proporción de SPs no incluidos en el callgraph de ningún dominio analizado. Estos SPs representan lógica que no fue observada en los logs de producción y puede estar asociada a funcionalidades empresariales de uso infrecuente o batch.

---

## Arquitectura de observabilidad

```
[BEIService (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard bancoppel.bdibei]
        │
        ├─ [X-Ray traces]  →  [Service Map]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace raíz: bancoppel.bdibei.*
```

---

## Métricas clave (Golden Signals)

> [SME-PENDING] — Baseline de métricas requiere análisis de logs de producción del dominio bdibei.

| Métrica | Namespace | Descripción |
|---------|-----------|-------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones al servicio bdibei |
| `bancoppel.bdibei.requests.total` | Custom | Total de operaciones BEI procesadas |
| `bancoppel.bdibei.errors.total` | Custom | Errores totales |
| `bancoppel.bdibei.errors.l4` | Custom | Divergencias financieras MONEY — cero tolerancia |
| `bancoppel.bdibei.dispersiones.pendientes` | Custom | Dispersiones masivas en cola — debe ser 0 al final de cada batch |

---

## Incidentes operativos

---

### INC-D14-01 — Códigos de error ESB no documentados (N3)

> **Diagnóstico completo**: [inc-006-d14-esb-bei.html](../../portal/incidents/inc-006-d14-esb-bei.html)

> **Ver risk register:** `migration-risk-register.md` · P655-R005

**Impacto funcional:** 5 códigos de error ESB activos en producción no están documentados en los runbooks del dominio bdibei. Bloquean avance a RELEASE de la Wave D14. Los pagos masivos y dispersiones institucionales pueden verse afectados silenciosamente si estos errores no son mapeados antes del cutover.

**Causa raíz (desde risk register P655-R005):**
Los logs del ESB del 2026-04-24 revelan errores no documentados en las integraciones externas vía ESB — afectan todas las integraciones, incluyendo el dominio BEI (bdibei):

| Código | Frecuencia/día (total sistema) | Descripción |
|--------|-------------------------------|-------------|
| 4394 | 2,452 | IBM MQ MbUserException — fallo de mensajería interna |
| 3743 | 761 | SOAP Handle Timed-out (~30s) |
| 3701 | 356 | JNI/Axis2 non-SOAP call error |
| 3165 | 320 | SSL socket error on connect |
| 6233 | 264 | Sin descripción disponible |

Ninguno de estos códigos está documentado en `06-exceptions.md` del dominio.

**SPs afectados:** los SPs de integración ESB de bdibei activos en producción. Con 294 SPs aislados, el análisis de logs de este dominio es especialmente importante para identificar qué proporción del volumen ESB les corresponde.

**Acción requerida antes de cutover Wave D14:**
1. Analizar los logs de producción de bdibei para identificar cuáles de los 5 códigos ESB afectan a este dominio y con qué frecuencia.
2. Documentar los códigos relevantes en `knowledge-base/D14-bdibei/06-exceptions.md`.
3. Mapear cada código ESB a su excepción equivalente en el target middleware (MSK/Lambda).
4. Revisar si las dispersiones masivas (pagos institucionales en batch) tienen exposición a los errores 4394 (IBM MQ) dado su naturaleza asíncrona — este es el escenario de mayor riesgo para este dominio.

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-08-03T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bdibei-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_bei_nombre",
  "domain": "bdibei",
  "wave": "[SME-PENDING]",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, datos de empresa, monto exacto). Solo loguear identificadores anonimizados.

---

*Generado por: DT-Riesgos · 2026-08-03 · Runbook mínimo creado a partir de P655-R005 (risk register). [SME-PENDING] perfil completo del dominio requiere análisis de logs de producción bdibei y sesión de validación con DBA IBM Informix IDS. Los 294 SPs aislados requieren análisis específico de journeys antes de diseñar umbrales definitivos.*
