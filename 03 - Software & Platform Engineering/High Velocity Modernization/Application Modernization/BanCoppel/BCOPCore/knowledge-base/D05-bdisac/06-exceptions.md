# D05 · Saldos y Cuentas — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — BanCoppel (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de BanCoppel antes de pasar a Etapa 2.
---


## Descripción

Catálogo de excepciones del dominio `bdisac` extraídas del análisis estático de 563 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 473 |
| Códigos de excepción capturados únicos | 5 |

## RAISE EXCEPTION — excepciones lanzadas

Cada `RAISE EXCEPTION` representa una **regla de negocio violada** o un **error del sistema**. Los códigos negativos son errores de Informix; los positivos son errores de aplicación definidos por BanCoppel.

| Código | Frecuencia | SP origen | Mensaje extraído |
|--------|-----------|-----------|-----------------|
| [SME-PENDING] | | | |

> **[SME-PENDING]** Para cada código: (1) ¿es error de motor (-NNN) o de aplicación (+NNN)? (2) ¿Qué proceso de negocio lo genera? (3) ¿Cómo lo maneja el canal que invoca el SP? (4) ¿Qué debe hacer el target cuando ocurre?

## ON EXCEPTION — excepciones capturadas

Códigos de excepción que el dominio captura y maneja internamente:

| Código capturado | SPs que lo capturan | Comportamiento esperado |
|-----------------|--------------------|-----------------------|
| `-535` | 96 SPs | [SME-PENDING] |
| `-284` | 12 SPs | [SME-PENDING] |
| `-255` | 4 SPs | [SME-PENDING] |
| `-668` | 3 SPs | [SME-PENDING] |
| `-1204` | 1 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sp_reportebts_edocta` | 33 bloque(s) | [SME-PENDING] |
| `sp_dinya_calcularcomisioniva_pba` | 32 bloque(s) | [SME-PENDING] |
| `sp_sac_eliminamovsbtspayi` | 32 bloque(s) | [SME-PENDING] |
| `sp_sac_eliminamovsbtsqryi` | 31 bloque(s) | [SME-PENDING] |
| `sp_sac_conciliadeta_pba` | 29 bloque(s) | [SME-PENDING] |
| `sp_bts_confirmapayc` | 28 bloque(s) | [SME-PENDING] |
| `sp_consremcambiost` | 28 bloque(s) | [SME-PENDING] |
| `sp_genreporbenefrem` | 28 bloque(s) | [SME-PENDING] |
| `sp_validarembtsensac` | 28 bloque(s) | [SME-PENDING] |
| `sp_bitacoragdf` | 27 bloque(s) | [SME-PENDING] |
| `sp_confirmacionbitacorapgdf` | 27 bloque(s) | [SME-PENDING] |
| `sp_consdatosticketpgdf` | 26 bloque(s) | [SME-PENDING] |
| `sp_sacreportemensualgdf` | 25 bloque(s) | [SME-PENDING] |
| `sp_sacreportesemanalgdf` | 24 bloque(s) | [SME-PENDING] |
| `sp_validadvgdf` | 24 bloque(s) | [SME-PENDING] |

## Códigos de excepción Informix comunes

| Código | Descripción | Contexto típico |
|--------|-------------|----------------|
| `-206` | Tabla o columna no existe | Error de schema |
| `-261` | No existe la BD/tabla | Schema incorrecto |
| `-268` | Unique constraint violation | Inserción duplicada |
| `-271` | NOT NULL constraint | Campo requerido nulo |
| `-407` | Null value not allowed | Similar a -271 |
| `-691` | Deadlock | Contención de recursos |
| `-243` | Could not lock record | Timeout de lock |
| `100` | Not found (SQLNOTFOUND) | SELECT sin resultados |

## Mapeo de excepciones al target

```
[SME-PENDING + Architect Target] Definir:

1. Excepciones de motor Informix (-NNN) → excepciones JDBC PostgreSQL equivalentes
   Ejemplo: Informix -268 (unique) → PostgreSQL SQLState 23505

2. Excepciones de aplicación (+NNN) → excepciones tipadas en Java/Kotlin
   Ejemplo: RAISE EXCEPTION 100 → throw NotFoundException("cliente no encontrado")

3. Bloques ON EXCEPTION → try/catch en la capa de servicio
   Ejemplo: ON EXCEPTION IN (-691) ROLLBACK → retry con backoff exponencial

4. Excepciones regulatorias → AlertService + audit log
   Ejemplo: RAISE EXCEPTION 403 → throw Regulatory Exception → notify CNBV endpoint
```

## Patrones de excepción críticos

```
[SME-PENDING] ¿Existen patrones de excepción con comportamiento silencioso?
Por ejemplo:
- ON EXCEPTION → ROLLBACK → CONTINUE (sin log = error invisible)
- Bucles con excepciones ignoradas
- RAISE EXCEPTION sin mensaje legible
```

---

## Errores de sistemas externos y ESB — evidencia de logs de producción

> **Fuente:** `source/logs/transacciones_bus_20260424_*.log` y `errores_bus_20260424_*.log`
> **Fecha de evidencia:** 2026-04-24 · **Incorporado:** 2026-08-01

### APPRIZA — Confirmación CFPA (Remesas Internacionales)

| Código | Descripción | Frecuencia/día | SP afectado |
|--------|-------------|---------------|-------------|
| `0000` | Operación completada — CFPA confirmada | ~56,117 | `sp_app_confirmpayment` |
| `9999` | "La operación ha terminado de manera incorrecta debido a un error inesperado" | 5,163 | `sp_app_confirmpayment` |

**Hallazgo:** `codRetorno=9999` deja la remesa en estado `PENDIENTE` en `sp_app_recordorder`. El job de reconciliación reintenta indefinidamente sin circuit breaker ni `max_retries` (ver `11-batch-processes.md` y P655-R003).
**UUID de sesión fijo:** `22e4e9ee-32ea-484e-b89f-2573549bc625` es idéntico en todas las llamadas automáticas — token de sesión compartido en el proceso batch. Riesgo de idempotencia si APPRIZA invalida o expira el token.

### Excepción Java en plugin ESB

| Excepción | Clase · línea | Causa raíz |
|-----------|--------------|-----------|
| `UndeclaredThrowableException` wrapping `NullPointerException` | `com.bancoppel.ConfirmPayment.evaluate():179` | Llamada a APPRIZA falla con NPE no manejada en el plugin Java |

El ESB no tiene circuit breaker — la excepción no cerrada propaga el estado `PENDIENTE` al batch de reconciliación.

### ESB BanCoppel — códigos no documentados en runbooks actuales (P655-R005)

| Código ESB | Frecuencia/día | Descripción técnica | Estado |
|------------|---------------|---------------------|--------|
| `4394` | 2,452 | IBM MQ MbUserException — fallo de mensajería interna | Sin runbook |
| `3743` | 761 | SOAP Handle Timed-out (~30s) | Sin runbook |
| `3701` | 356 | JNI/Axis2 non-SOAP call error | Sin runbook |
| `3165` | 320 | SSL socket error on connect | Sin runbook |
| `6233` | 264 | Sin descripción disponible | [SME-PENDING] |
| `4395` | ~3,979 | NullPointerException — `Huellas442` (`postg_huellasemps`, ya migrado a PSQL) | P655-R004 |
| `3381` | 3,244 | SFTP password invalid — `sysportabnominaapp` (servicio ACEPTPORTA) | P655-R007 |

> Ninguno de estos códigos tiene mapeo en el target. Requieren definición explícita en el contrato de errores del microservicio antes del cutover.

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisac_*.sql*
*Actualizado: DT-Riesgos · 2026-08-01 · Incorporación de errores externos desde source/logs/20260424*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total errores del dominio:** 2,494 · **Códigos distintos:** 5

| Código | Descripción | Volumen/día | Servicios afectados |
|--------|-------------|-------------|---------------------|
| `4395` | Unhandled exception en plugin IIB — NullPointerException en  | 1,102 | Caja, ConsultaRemesas, FabricaPagoServicios… |
| `4394` | Unhandled exception en plugin IIB — MbUserException genérica | 714 | Caja, Caja2, Caja3… |
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sistema  | 340 | Caja, Caja2, Caja3… |
| `3701` | Error en JNI Call — Axis2Invoker fallo de comunicación SOAP  | 331 | Caja, Caja2, CajaCliente… |
| `3166` | SSL timeout — timeout durante operación TLS con endpoint ext | 7 | RemesasAPPRIZA, RemesasAPPRIZACanalesExternos |

### SPs con mayor tasa de error

| SP | Llamadas/día | Errores/día | Error% |
|----|-------------|-------------|--------|
| `sp_consultasaldocortemin` | 6,651 | 6,641 | 99.85% |
| `sp_consultaregtarjeta` | 6,560 | 6,382 | 97.29% |
| `sp_cat_carac_tae` | 7,330 | 7,093 | 96.77% |
| `sp_reverso_msw` | 8,034 | 5,561 | 69.22% |
| `sp_app_recuperapayment` | 7,724 | 1,787 | 23.14% |
| `sp_consulta_cardif` | 11,736 | 1,031 | 8.78% |
| `sp_app_confirmpayment` | 61,686 | 5,331 | 8.64% |
| `sp_guarda_autorizacion_grandata` | 5,599 | 62 | 1.11% |
| `sp_bitacorawstae` | 81,189 | 571 | 0.7% |
| `sp_aplica_pago_con_cargo_msw` | 80,959 | 297 | 0.37% |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
