# D13 · bditef (TEF — Transferencias Electrónicas de Fondos) — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Base de datos:** bditef (Transferencias Electrónicas de Fondos)
> **Wave:** [SME-PENDING]
> **Última actualización:** 2026-08-03
> **Inventario:** 139 SPs analizados (68 en callgraph · 71 aislados — ver sp-specs-bditef.md)

---

**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional TEF)
- Cybersecurity (PII, CNBV, LFPDPPP)
- SRE & AIOps (observabilidad y runbooks)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.

---

## Perfil del dominio

| Atributo | Valor |
|----------|-------|
| SPs totales | 139 |
| SPs en callgraph | 68 |
| SPs aislados | 71 |
| Función | Transferencias Electrónicas de Fondos entre cuentas |
| Riesgo migration | WARN — P655-R005 (ESB error codes no documentados) |

---

## Arquitectura de observabilidad

```
[TEFService (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard bancoppel.bditef]
        │
        ├─ [X-Ray traces]  →  [Service Map]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty/Teams]

Namespace raíz: bancoppel.bditef.*
```

---

## Métricas clave (Golden Signals)

> [SME-PENDING] — Baseline de métricas requiere análisis de logs de producción del dominio bditef.

| Métrica | Namespace | Descripción |
|---------|-----------|-------------|
| `Invocations` | `AWS/Lambda` | Número total de invocaciones al servicio bditef |
| `bancoppel.bditef.requests.total` | Custom | Total de transferencias procesadas |
| `bancoppel.bditef.errors.total` | Custom | Errores totales |
| `bancoppel.bditef.errors.l4` | Custom | Divergencias financieras MONEY — cero tolerancia |

---

## Incidentes operativos

---

### INC-D13-01 — Códigos de error ESB no documentados (N3)

> **Diagnóstico completo**: [inc-005-d13-esb-tef.html](../../portal/incidents/inc-005-d13-esb-tef.html)

> **Ver risk register:** `migration-risk-register.md` · P655-R005

**Impacto funcional:** 5 códigos de error ESB activos en producción no están documentados en los runbooks del dominio bditef. Bloquean avance a RELEASE de la Wave D13. En el target, estos errores del middleware pueden manifestarse diferente y requerir mapeo explícito en MSK/Lambda.

**Causa raíz (desde risk register P655-R005):**
Los logs del ESB del 2026-04-24 revelan errores no documentados en las integraciones externas vía ESB — afectan todas las integraciones, incluyendo el dominio TEF (bditef):

| Código | Frecuencia/día (total sistema) | Descripción |
|--------|-------------------------------|-------------|
| 4394 | 2,452 | IBM MQ MbUserException — fallo de mensajería interna |
| 3743 | 761 | SOAP Handle Timed-out (~30s) |
| 3701 | 356 | JNI/Axis2 non-SOAP call error |
| 3165 | 320 | SSL socket error on connect |
| 6233 | 264 | Sin descripción disponible |

Ninguno de estos códigos está documentado en `06-exceptions.md` del dominio.

**SPs afectados:** los SPs de integración ESB de bditef activos en producción. Pendiente de identificar qué proporción del volumen ESB corresponde a este dominio.

**Acción requerida antes de cutover Wave D13:**
1. Analizar los logs de producción de bditef para identificar cuáles de los 5 códigos ESB afectan a este dominio y con qué frecuencia.
2. Documentar los códigos relevantes en `knowledge-base/D13-bditef/06-exceptions.md`.
3. Mapear cada código ESB a su excepción equivalente en el target middleware (MSK/Lambda).
4. Agregar los códigos al CloudWatch filter de ruido de fondo o crear alarmas según corresponda.

---

## Logs estructurados — formato obligatorio

```json
{
  "timestamp": "2026-08-03T10:00:00.000-06:00",
  "level": "INFO",
  "service": "bditef-service",
  "traceId": "1-xxx-xxx",
  "spanId": "xxx",
  "operation": "sp_tef_nombre",
  "domain": "bditef",
  "wave": "[SME-PENDING]",
  "durationMs": 45,
  "outcome": "SUCCESS",
  "requestId": "uuid"
}
```

> **Nota:** Nunca loguear datos PII (num_cte, num_tarjeta, monto exacto). Solo loguear identificadores anonimizados.

---

*Generado por: DT-Riesgos · 2026-08-03 · Runbook mínimo creado a partir de P655-R005 (risk register). [SME-PENDING] perfil completo del dominio requiere análisis de logs de producción bditef y sesión de validación con DBA IBM Informix IDS.*
