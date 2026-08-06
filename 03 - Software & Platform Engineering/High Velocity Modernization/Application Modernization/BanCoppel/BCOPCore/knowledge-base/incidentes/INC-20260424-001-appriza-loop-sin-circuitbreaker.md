# INC-20260424-001 — Remesa Internacional Atascada: Loop APPRIZA sin Circuit Breaker

**ID:** INC-20260424-001  
**Fecha captura:** 2026-04-24  
**Portal:** [inc-001-d05-appriza.html](../../portal/incidents/inc-001-d05-appriza.html)  
**Hora de actividad:** 18:00–20:00 CST concentrado (115 + 297 errores); disperso durante el día  
**Sistemas afectados:** `bdisac` (D05) → ESB `RemesasAPPRIZAAutomaticas` → servicio externo APPRIZA  
**Severidad:** N3 — riesgo regulatorio Banxico Circular 14/2017 (plazo 2 días hábiles para notificar al cliente)  
**Fuentes analizadas:** `errores_bus_20260424_*.txt` (24 archivos) · `sp_app_confirmpayment.sql` · runbook INC-D05-04  
**Estado:** DEFECTO ACTIVO — batch de reintento sin max_retries ni circuit breaker  
**Runbook origen:** INC-D05-04 en `knowledge-base/D05-bdisac/21-observability-runbook.md`

---

## 1. Síntesis del incidente

El 24 de abril de 2026, el servicio de remesas internacionales automáticas (`RemesasAPPRIZAAutomaticas`) generó **447 errores ESB** contra el proveedor APPRIZA, concentrados principalmente en el horario nocturno (18:00–20:00 CST: 412 de 447 errores). El SP central `sp_app_confirmpayment` registra una tasa de error del 8.7% (5,163 fallos/día de 61,280 llamadas/día según runbook), con `codRetorno=9999` indicando falla en la confirmación del pago.

El problema no es la tasa de error en sí, sino la ausencia de un circuit breaker: el batch de reintentos (`RemesasAPPRIZAAutomaticas`) reintenta indefinidamente remesas fallidas sin límite de intentos. Remesas únicas (~400/día) pueden acumular hasta 13 reintentos, manteniendo el estado `PENDIENTE` hasta que un agente humano intervenga. El plazo regulatorio de Banxico para notificar al cliente es de 2 días hábiles (Circular 14/2017).

---

## 2. Evidencia cuantitativa de los logs 2026-04-24

### 2.1 Errores por hora — REM_AUT_APZ / RemesasAPPRIZAAutomaticas

| Hora CST | Errores APPRIZA |
|----------|----------------|
| 07:00 | 2 |
| 08:00 | 1 |
| 09:00 | 6 |
| 10:00 | 2 |
| 11:00 | 2 |
| 13:00 | 9 |
| 14:00 | 9 |
| 15:00 | 5 |
| 16:00 | 3 |
| 17:00 | 7 |
| **18:00** | **115** |
| **19:00** | **297** |
| **Total** | **447** |

El pico nocturno (18:00–19:00) correlaciona con la ejecución del batch `RemesasAPPRIZAAutomaticas` que reprocesa las remesas pendientes del día — confirmando el patrón de loop sin límite de reintentos.

### 2.2 Distribución de códigos de error APPRIZA

| Código ESB | Errores | Descripción |
|-----------|---------|-------------|
| 4395 | 335 | Sin descripción disponible (ver INC-20260424-004/005/006) |
| 4394 | 143 | IBM MQ MbUserException |
| 6233 | 70 | Sin descripción disponible |
| 3166 | 6 | SSL-related |
| **Total** | **447** | — |

> **Nota:** El código `codRetorno=9999` reportado en el runbook (tasa 8.7%) corresponde al código de retorno interno del SP APPRIZA, no al código de error del ESB. Los 5,163 fallos/día del runbook provienen de `sp_app_confirmpayment` vía canal directo y no todos generan entrada en `errores_bus_*.txt`.

### 2.3 SPs afectados (desde runbook y brain.db)

| SP | Llamadas/día | Tasa de error |
|----|-------------|---------------|
| `sp_app_confirmpayment` | 61,280 | 8.7% (5,163 con codRetorno=9999) |
| `sp_app_recordorder` | ~61,280 | 0% (registra la orden — falla en confirm) |
| `sp_app_queryorder` | ~18,000 | <1% (consulta de estado) |

Sesión UUID conocida: `22e4e9ee-32ea-484e-b89f-2573549bc625` — si APPRIZA expira el token, TODOS los reintentos del batch fallarán.

---

## 3. Causa raíz

El SP `sp_app_confirmpayment` llama al proveedor externo APPRIZA vía ESB. Cuando APPRIZA devuelve `codRetorno=9999`, el SP registra la remesa como `PENDIENTE` sin consumir el reintento ni notificar al cliente. El batch `RemesasAPPRIZAAutomaticas` recoge todas las remesas `PENDIENTE` y las reintenta sin configuración de `max_retries`, creando un loop potencialmente infinito.

**Cadena causal:**
```
1. sp_app_confirmpayment recibe codRetorno=9999 de APPRIZA
2. Estado remesa → PENDIENTE en bdisac
3. Batch RemesasAPPRIZAAutomaticas recoge remesas PENDIENTE
4. Reintento → mismo 9999 (si APPRIZA sigue degradado)
5. Estado sigue PENDIENTE → siguiente ejecución del batch → reintento #2... #13
6. Sin alerta de max_retries → incidente invisible hasta análisis de logs
7. Si supera 2 días hábiles sin resolución → Banxico Circular 14/2017 incumplida
```

**Escenario de riesgo máximo:** expiración del UUID de sesión APPRIZA (`22e4e9ee-32ea-484e-b89f-2573549bc625`). Cuando el token expira, todos los intentos del batch fallan simultáneamente con el mismo error, acelerando el agotamiento del plazo regulatorio para múltiples remesas en paralelo.

---

## 4. Defectos identificados

| ID | SP / Componente | Descripción |
|----|----------------|-------------|
| D1 | `sp_app_confirmpayment` | Sin lógica de max_retries — registra PENDIENTE indefinidamente |
| D2 | `RemesasAPPRIZAAutomaticas` (batch ESB) | Sin circuit breaker — reintenta all-or-nothing sin threshold |
| D3 | Gestión de sesión APPRIZA | UUID hardcodeado sin renovación automática al expirar |
| D4 | Monitoreo | Sin alerta sobre `remesas.PENDIENTE > 2 horas` ni sobre `codRetorno=9999 > umbral` |

---

## 5. Riesgo regulatorio

**Banxico Circular 14/2017:** plazo máximo de 2 días hábiles para notificar errores en transferencias al exterior al cliente. Con el loop activo, remesas en estado PENDIENTE pueden superar este plazo sin que el cliente ni el área de cumplimiento sean notificados.

---

## 6. Patrones de riesgo para la migración

### Patrón 1 — Batch de reintento sin límite
En el target (Aurora PostgreSQL + Lambda), el batch equivalente debe implementar: `max_retries=3`, backoff exponencial (1 min → 5 min → 30 min), estado `MAX_RETRIES_EXCEEDED` como terminal con alerta y notificación al cliente.

### Patrón 2 — Token de sesión externo hardcodeado
La gestión del UUID de sesión APPRIZA debe migrarse a AWS Secrets Manager con lógica de renovación automática ante expiración. En la arquitectura Informix actual no hay capa de gestión de credenciales externas.

### Patrón 3 — Integración síncrona con proveedor externo sin timeout explícito
`sp_app_confirmpayment` realiza una llamada síncrona al ESB sin timeout explícito en SPL. En el target, implementar `Connection Timeout=5s · Read Timeout=10s` en el cliente HTTP, con fallback a estado `TIMEOUT_EXTERNO`.

---

## 7. Acciones correctivas

**Inmediato (producción actual Informix/ESB):**
1. Identificar remesas en estado PENDIENTE > 2 días hábiles → notificación manual al cliente.
2. Verificar si el UUID `22e4e9ee-32ea-484e-b89f-2573549bc625` sigue válido.
3. Configurar alerta: `bancoppel.bdisac.confirmpayment.errors.appriza_9999 > 500 en 1h`.

**Pre-cutover (target):**
1. Circuit breaker Resilience4j: threshold 50% errores/60s → OPEN.
2. `max_retries=3` con backoff exponencial; estado terminal `MAX_RETRIES_EXCEEDED`.
3. On max_retries: INSERT en tabla `reconciliacion_remesas` + notificación cliente + flag CNBV.
4. Gestión de token de sesión en Secrets Manager con renovación automática.

---

*Fuentes: `source/logs/2026-04-24/errores_bus_*.txt` · runbook INC-D05-04 · `source/BCOPCore/informix/sp_app_confirmpayment.sql`.*  
*Creado: 2026-08-06 | BCOPCore Gemelo Cognitivo — DISCOVER Etapa 1*
