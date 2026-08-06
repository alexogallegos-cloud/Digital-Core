# D13 · Transferencias Electrónicas de Fondos (TEF) — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático)
- Domain Expert — BanCoppel (validación funcional)
- SME — Core Banking Transformation (impacto en migración)
- SME — DBA IBM Informix (comportamiento de motor Informix)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con Domain Expert de BanCoppel antes de pasar a BUILD.
---

## Descripción

Catálogo de excepciones del dominio `bditef`. Incluye:
- Códigos de error ESB activos en producción (INC-005) con impacto directo en transferencias
- Excepciones Informix capturadas en los SPs del dominio
- Patrones de manejo de errores identificados en el análisis estático

---

## SECCIÓN 1 — Errores ESB activos en producción (INC-005)

> **Fuente de evidencia:** Logs de producción ESB BanCoppel. Incidente activo INC-005.
> **Impacto directo:** Estos códigos afectan el flujo de transferencias TEF. No tienen runbook ni mapeo en el target actual.

| Código ESB | Frecuencia estimada/día | Descripción técnica | Causa raíz | Estado del runbook |
|------------|------------------------|---------------------|------------|-------------------|
| `4394` | ~2,452 | IBM MQ MbUserException — fallo de mensajería interna en el plugin IIB | Plugin Java lanza `MbUserException` al no poder conectar al queue manager de MQ | **Sin runbook** |
| `3743` | ~761 | SOAP Handle Timed-out — timeout en conexión SOAP/JNI (~30 segundos) | El sistema externo TEF no responde dentro del SLA definido en el bus | **Sin runbook** |
| `3701` | ~356 | JNI/Axis2 non-SOAP call error — Axis2Invoker falla en la llamada JNI | Incompatibilidad de versión o error de inicialización del cliente Axis2 | **Sin runbook** |
| `3165` | ~320 | SSL socket error on connect — error en el handshake TLS con endpoint externo | Certificado expirado, cipher suite incompatible o error de red | **Sin runbook** |
| `6233` | ~264 | Sin descripción disponible en los logs actuales | Origen desconocido — posiblemente código de aplicación BanCoppel | `[SME-PENDING]` |

**Total combinado estimado:** ~4,153 errores/día relacionados con TEF en el bus ESB.

### Impacto en el target

Ninguno de estos códigos tiene mapeo en el microservicio `TransferenciasService` objetivo. Antes del cutover debe definirse:

1. **Contrato de errores:** Cada código ESB debe tener un equivalente tipado en la API REST del target (ej. `TransferError`, `TimeoutError`, `ConnectivityError`).
2. **Circuit breaker:** El código ESB 3743 (timeout) indica que el sistema externo TEF puede no responder. El target debe implementar circuit breaker con retry exponencial.
3. **Alerta operativa:** Los 5 códigos deben generar alertas en el runbook de operaciones. Ver `21-observability-runbook.md`.
4. **Código 6233:** Requiere identificación urgente antes de BUILD — clasificar si es error de motor o de aplicación.

---

## SECCIÓN 2 — Excepciones Informix en SPs del dominio

> **Fuente:** Análisis estático de los 139 SPs del dominio `bditef`.

### Excepciones capturadas con `ON EXCEPTION`

| Código Informix | Descripción del motor | SPs que lo capturan | Comportamiento esperado |
|----------------|----------------------|---------------------|------------------------|
| `-535` | Unique constraint violation (en algunos contextos de Informix) | `[DATO-REQUERIDO]` | `[SME-PENDING]` |
| `-284` | Object not found / no existe el objeto | `[DATO-REQUERIDO]` | `[SME-PENDING]` |
| `-255` | Transaction not started / no hay transacción activa | `[DATO-REQUERIDO]` | `[SME-PENDING]` |
| `-668` | Null value in NOT NULL column | `[DATO-REQUERIDO]` | `[SME-PENDING]` |
| `-1204` | Database server error | `[DATO-REQUERIDO]` | `[SME-PENDING]` |

> **Nota:** El número exacto de SPs por código y la frecuencia específica en `bditef` requieren el análisis estático completo del dominio. Las cifras de D05-bdisac (473 SPs con ON EXCEPTION) son del dominio de saldos y no son directamente aplicables a `bditef`. El análisis completo queda como `[DATO-REQUERIDO]` del DBA IBM Informix.

---

## SECCIÓN 3 — Códigos de retorno de negocio

Los SPs del dominio retornan un `char(5)` como primer valor de retorno. Los códigos identificados en el código son:

| Código | Descripción | SP origen | Tipo |
|--------|-------------|-----------|------|
| `00000` | Operación exitosa | Todos los SPs | Normal |
| `00001` | Registro no encontrado | SPs de consulta | Normal |
| `00400` | Error de validación (múltiples causas) | Validaciones de entrada | Error de negocio |
| `09999` | Error interno | SPs de registro | Error de sistema |

Códigos adicionales específicos de TEF/CECOBAN: `[DATO-REQUERIDO]` — requiere análisis completo con DBA.

---

## SECCIÓN 4 — Patrones de manejo de errores identificados

### Patrón 1 — Conversión silenciosa de error (CWE-390 potencial)

Evidenciado en `cargo_cta` y otros SPs de registro:

```sql
ON EXCEPTION SET vsqlerr
    LET vcodret = vsqlerr;   -- convierte error Informix a código de retorno
    RETURN vcodret, vmsg;    -- retorna sin log explícito
END EXCEPTION;
```

**Riesgo:** Igual al detectado en D05-bdisac (`sp_consultasaldocortemin_mx2`). Los errores cross-DB hacia `bdicheq` pueden convertirse silenciosamente en códigos numéricos que el ESB no interpreta correctamente.

**Impacto en target:** El microservicio `TransferenciasService` debe lanzar excepciones tipadas, no retornar códigos numéricos genéricos. Ver `16-api-contract.md`.

### Patrón 2 — Retorno de estado con código de devolución CECOBAN

```sql
LET vmotdevol = "09"; -- cuenta bloqueada
```

Los códigos de devolución CECOBAN son parte del contrato regulatorio. No son errores de sistema sino respuestas de negocio normalizadas. En el target deben representarse como `enum DevolcionCECOBAN` con valores documentados.

---

## SECCIÓN 5 — Referencia de códigos Informix comunes

| Código | Descripción | Contexto típico en TEF |
|--------|-------------|----------------------|
| `-206` | Tabla o columna no existe | Error de schema — indica problema en migración |
| `-261` | No existe la BD/tabla | Cross-DB fallido — `bdicheq` o `bdinteg` no disponible |
| `-268` | Unique constraint violation | Folio duplicado en `tef_operaciones` |
| `-271` | NOT NULL constraint | Parámetro requerido nulo en llamada al SP |
| `-691` | Deadlock | Alta concurrencia en `cargo_cta` / `abono_cta` |
| `-243` | Could not lock record | Timeout de lock en operación TEF |
| `100` | Not found (SQLNOTFOUND) | Cuenta no existe en `sc_maechq` |

---

## Mapeo de excepciones al target

```
[Architect Target · SME Core Banking — PENDIENTE]

1. Informix ON EXCEPTION (-NNN) → Spring @ExceptionHandler en TransferenciasService
   Ejemplo: -268 (unique) → throw DuplicateFolioException("folio ya existe")

2. Códigos de retorno de negocio (char 5) → ResponseEntity<TransferResponse>
   Ejemplo: "00400" → HTTP 422 Unprocessable Entity + cuerpo con ValidationError

3. ESB codes 4394/3743/3701/3165/6233 → ErrorCode enum en TransferenciasService
   Ejemplo: 3743 (timeout) → CircuitBreakerException con retry policy

4. Devoluciones CECOBAN (vmotdevol) → enum DevolucionCECOBAN { CUENTA_BLOQUEADA_09, ... }
   Requires: catálogo completo de motivos CECOBAN vigente

5. Excepciones regulatorias → AuditLogService + alerta en runbook
   Ejemplo: cuenta bloqueada → notificación a supervisor + registro en tef_bitacora
```

---
*Generado por: análisis de sp-specs-bditef.md + INC-005 + referencia D05-bdisac · 2026-08-03*
