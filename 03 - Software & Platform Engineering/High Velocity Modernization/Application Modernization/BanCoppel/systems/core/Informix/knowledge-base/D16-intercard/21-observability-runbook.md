# D16 · Intercard (Tarjetas) — Observabilidad y Runbook

> **Componente:** Informix · SPE-AM-001 · OPERATE Phase
> **Microservicio target:** TarjetasService
> **Wave:** Wave 4 · Riesgo: **MEDIO-ALTO**
> **Última actualización:** 2026-08-03
> **Inventario:** 394 SPs · DB: intercard
> **SP más llamado:** `sp_cancelacion_tarjeta` (fan_in=28) · caller: `bdicred:reversion` (D03)
> **Batch críticos:** `sp_carga_ctes_enrola` (1,778 LOC) · `sp_contacto_vencimiento_credito` (49 reglas) · `sp_contacto_vencimiento_debito` (46 reglas)
> **Dependencia externa crítica:** ICCAT/BPI (canal sucursal)

---

**SME responsable:**
- SRE & AIOps (observabilidad y runbooks)
- Industry Banking (validación funcional de tarjetas)
- DBA — IBM Informix IDS (schema y volúmenes producción)
- Cybersecurity (PCI-DSS plásticos, CNBV, LFPDPPP)
- Core Banking Transformation (ACL design y API contracts Wave 4)

---

## Arquitectura de observabilidad (target Wave 4)

```
[Canal ICCAT/BPI]       [D03 bdicred: reversion]    [Scheduler batch]
        │                         │                         │
        ▼                         ▼                         ▼
[TarjetasService (Lambda/ECS)]
        │  structured logs (JSON)
        ▼
[CloudWatch Logs]  →  [CloudWatch Insights]  →  [Dashboard D16]
        │
        ├─ [X-Ray traces]  →  [Service Map ICCAT↔TarjetasService]
        │
        └─ [CloudWatch Metrics]  →  [Alarms]  →  [SNS → PagerDuty]

Namespace custom: bancoppel.intercard.*
Cross-domain monitoreado: D16 → D09 (mensajería) · D03 → D16 (cancelación)
```

---

## Incidentes activos

> No hay incidentes activos documentados con diagnóstico completo para D16.
> Los riesgos identificados son preventivos (pre-migración), no incidentes de producción.

### Riesgos preventivos activos (pre-Wave 4)

| ID | Riesgo | Severidad | Estado |
|----|--------|:---------:|--------|
| R-D16-01 | 49+46 reglas de contacto vencimiento sin documentar — incumplimiento CONDUSEF en target | N3 | Abierto |
| R-D16-02 | Dependencia ICCAT/BPI sin protocolo documentado — 3 SPs expuestos sin ACL diseñada | N3 | Abierto |
| R-D16-03 | `sp_cancelacion_tarjeta` invocada por D03 (Wave 1) — D16 (Wave 4) aún no migrado | N2 | Abierto |
| R-D16-04 | Batch `sp_carga_ctes_enrola` con `UNLOAD`/`LOAD` Informix — sin equivalente directo AWS | N2 | Abierto |

---

## Runbook · `sp_cancelacion_tarjeta` (BP-D16-01)

**Cuándo:** Este SP es invocado por `bdicred:reversion` (D03 Crédito) durante la reversión de una operación de crédito. Si falla, la reversión en D03 puede quedar incompleta.

**Síntomas de falla:**
- Error en logs de D03: CALL `intercard:sp_cancelacion_tarjeta` → código de error no `0000`
- Tarjeta permanece ACTIVA después de una reversión exitosa de crédito

**Diagnóstico:**
1. Verificar conectividad cross-DB `bdicred` → `intercard`
2. Verificar que la tarjeta existe en catálogo intercard (SELECT por número de tarjeta)
3. Verificar status actual de la tarjeta — puede estar ya CANCELADA (idempotencia)
4. Revisar logs de `sp_cancelacion_tarjeta` en CloudWatch Logs (namespace `bancoppel.intercard.*`)

**Mitigación:**
- Si la tarjeta existe y está ACTIVA: ejecutar UPDATE manual con autorización supervisor
- Si hay error de conectividad: escalar a DBA IBM Informix / SRE

---

## Runbook · Batch de contacto vencimiento (BP-D16-02/03)

**Cuándo:** `sp_contacto_vencimiento_credito` y `sp_contacto_vencimiento_debito` corren diariamente (horario `[SME-PENDING]`). Si fallan, los clientes próximos a vencer no reciben recordatorio.

**Síntomas de falla:**
- Batch completa en 0 registros procesados (cursor vacío o error de selección)
- Falla parcial: algunos clientes contactados, otros no
- Error en canal de notificación (D09 Mensajería inaccesible)

**Diagnóstico:**
1. Verificar logs de ejecución batch en CloudWatch Logs
2. Contar registros en tabla de vencimientos para la fecha en cuestión
3. Verificar disponibilidad de D09 (bdimnsj — Mensajería)
4. Revisar los 49/46 criterios de elegibilidad — puede haber cambio en datos que deja la selección vacía

**Mitigación:**
- Re-ejecución del batch en ventana de corrección (coordinar con Operaciones para no duplicar contactos)
- Si D09 no disponible: batch queda pendiente — registrar para re-ejecución cuando D09 restablezca

---

## Runbook · Batch enrolamiento (`sp_carga_ctes_enrola`)

**Cuándo:** Corre en ventana nocturna (`[SME-PENDING]`). Si falla, los clientes del día no quedan enrolados en intercard.

**Síntomas de falla:**
- 0 registros insertados/actualizados en intercard
- Errores de validación en log (de las 16 reglas de elegibilidad)

**Diagnóstico:**
1. Revisar tabla/archivo de entrada — puede estar vacío o mal formateado
2. Identificar qué regla de las 16 está fallando (requiere traza de error en log)
3. Verificar disponibilidad de DBs cross-domain que consulta (probable D03 bdicred o D04 bdicheq)

**Mitigación:**
- Corregir datos de entrada y re-ejecutar batch
- Si error en regla de negocio: escalar a Industry Banking para validación

---

## Alertas recomendadas (target AWS)

| Alerta | Métrica | Umbral | Acción |
|--------|---------|--------|--------|
| D16-ALERT-01 | Error rate `sp_cancelacion_tarjeta` | > 1% | PagerDuty P2 — afecta reversiones D03 |
| D16-ALERT-02 | Batch contacto vencimiento — 0 registros procesados | = 0 en corrida esperada | PagerDuty P2 |
| D16-ALERT-03 | Latencia P95 ICCAT calls | > 2,000ms | CloudWatch Alarm — degradación ICCAT |
| D16-ALERT-04 | Batch enrolamiento fallido | exit_code ≠ 0 | PagerDuty P1 — alta de clientes bloqueada |
| D16-ALERT-05 | Error de conectividad D16 → D09 | timeout > 30s | PagerDuty P2 — notificaciones fallando |

---
*Generado: 2026-08-03 · base: análisis estático brain.db + patrones de riesgo cross-domain · métricas de producción `[DATO-REQUERIDO]` desde logs AIX*
