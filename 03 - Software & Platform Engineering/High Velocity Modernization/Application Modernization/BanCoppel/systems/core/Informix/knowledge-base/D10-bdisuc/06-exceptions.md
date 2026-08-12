# D10 · Sucursales — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdisuc` extraídas del análisis estático de 293 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 266 |
| Códigos de excepción capturados únicos | 4 |

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
| `-535` | 98 SPs | [SME-PENDING] |
| `-668` | 2 SPs | [SME-PENDING] |
| `-255` | 2 SPs | [SME-PENDING] |
| `-958` | 2 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sp_consulta_sucxcg2` | 22 bloque(s) | [SME-PENDING] |
| `sp_catsecciones_oemn` | 21 bloque(s) | [SME-PENDING] |
| `sp_ope_actualizacuentas` | 20 bloque(s) | [SME-PENDING] |
| `sp_monitor_caja2` | 19 bloque(s) | [SME-PENDING] |
| `sp_ope_actualizanivcuentas` | 19 bloque(s) | [SME-PENDING] |
| `sp_consul_dotacion2` | 18 bloque(s) | [SME-PENDING] |
| `sp_guarda_reclamo_bym` | 18 bloque(s) | [SME-PENDING] |
| `sp_ope_actualizatransportadora` | 18 bloque(s) | [SME-PENDING] |
| `reversion_sobrante` | 17 bloque(s) | [SME-PENDING] |
| `sp_ope_catestadomunicipio` | 17 bloque(s) | [SME-PENDING] |
| `sp_ope_consdetallecontrapartes` | 16 bloque(s) | [SME-PENDING] |
| `sp_validafecha_concensuc` | 16 bloque(s) | [SME-PENDING] |
| `sp_actestatuscajacap` | 15 bloque(s) | [SME-PENDING] |
| `sp_guardasobrantes` | 14 bloque(s) | [SME-PENDING] |
| `sp_ope_consdetallecuentas` | 14 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdisuc_*.sql*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total errores del dominio:** 37 · **Códigos distintos:** 2

| Código | Descripción | Volumen/día | Servicios afectados |
|--------|-------------|-------------|---------------------|
| `4394` | Unhandled exception en plugin IIB — MbUserException genérica | 19 | AdmonSuC |
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sistema  | 18 | AdmonSuC |

### SPs con mayor tasa de error

| SP | Llamadas/día | Errores/día | Error% |
|----|-------------|-------------|--------|
| `Sp_validadotaatm_web` | 112 | 95 | 84.82% |
| `sp_cancelar_solicitud_dota` | 4 | 1 | 25.0% |
| `sp_traefolios` | 21 | 5 | 23.81% |
| `sp_faltsob_atm_ofi_web` | 706 | 78 | 11.05% |
| `sp_validahora` | 111 | 3 | 2.7% |
| `sp_soldocta_atm_ofi_web` | 68 | 1 | 1.47% |
| `sp_valida_oper_atm` | 323 | 4 | 1.24% |
| `sp_reversafaltsob_web` | 639 | 1 | 0.16% |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
