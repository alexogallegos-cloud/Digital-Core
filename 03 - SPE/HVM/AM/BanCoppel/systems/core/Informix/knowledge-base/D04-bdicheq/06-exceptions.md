# D04 · Cheques / Cuentas — Excepciones y Manejo de Errores

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdicheq` extraídas del análisis estático de 1535 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 930 |
| Códigos de excepción capturados únicos | 15 |

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
| `-535` | 141 SPs | [SME-PENDING] |
| `-668` | 27 SPs | [SME-PENDING] |
| `-243` | 12 SPs | [SME-PENDING] |
| `-255` | 11 SPs | [SME-PENDING] |
| `-244` | 6 SPs | [SME-PENDING] |
| `-211` | 5 SPs | [SME-PENDING] |
| `-242` | 5 SPs | [SME-PENDING] |
| `-311` | 5 SPs | [SME-PENDING] |
| `-239` | 4 SPs | [SME-PENDING] |
| `-696` | 3 SPs | [SME-PENDING] |
| `-235` | 2 SPs | [SME-PENDING] |
| `-268` | 2 SPs | [SME-PENDING] |
| `-1207` | 2 SPs | [SME-PENDING] |
| `-100` | 2 SPs | [SME-PENDING] |
| `-284` | 1 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `ischar` | 232 bloque(s) | [SME-PENDING] |
| `sp_nom_gen_mov_mes` | 18 bloque(s) | [SME-PENDING] |
| `sp_bloqdesbloqcta` | 17 bloque(s) | [SME-PENDING] |
| `cargo_ref_pos` | 16 bloque(s) | [SME-PENDING] |
| `sp_nom_gendata_disp` | 16 bloque(s) | [SME-PENDING] |
| `cargon_ref` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhis` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhiscomp1` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhiscomp2` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhiscomp3` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhiscomp4` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhiscomp5` | 15 bloque(s) | [SME-PENDING] |
| `pasecheqhisfinal` | 15 bloque(s) | [SME-PENDING] |
| `reversion_web` | 15 bloque(s) | [SME-PENDING] |
| `sp_blqconsclavebloq` | 15 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdicheq_*.sql*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total errores del dominio:** 767 · **Códigos distintos:** 3

| Código | Descripción | Volumen/día | Servicios afectados |
|--------|-------------|-------------|---------------------|
| `4395` | Unhandled exception en plugin IIB — NullPointerException en  | 517 | Cheques, SobresDigitales |
| `4394` | Unhandled exception en plugin IIB — MbUserException genérica | 208 | Cheques, Tarjeta |
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sistema  | 42 | Tarjeta |

### SPs con mayor tasa de error

| SP | Llamadas/día | Errores/día | Error% |
|----|-------------|-------------|--------|
| `sp_whatscoppel_consdos` | 32,975 | 16,048 | 48.67% |
| `consnomtit` | 4,001 | 375 | 9.37% |
| `sp_consmov_sd` | 2,260 | 127 | 5.62% |
| `sp_insertarespuestacuestionario` | 2,831 | 110 | 3.89% |
| `sp_retiro_sd` | 41,546 | 703 | 1.69% |
| `ConsNomTitTar_web` | 1,719 | 28 | 1.63% |
| `cons_sdos2_web` | 85,881 | 1,104 | 1.29% |
| `cargo_ref` | 23,053 | 239 | 1.04% |
| `sp_abono_sd` | 25,414 | 220 | 0.87% |
| `sp_crea_sd` | 6,394 | 51 | 0.8% |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
