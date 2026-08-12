# D01 · Canal Digital Web — Excepciones y Manejo de Errores

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático, extracción de código)
- Domain Expert — LegacyCore (validación funcional y de negocio)
- Data Architect (modelado target PostgreSQL / Aurora)
- Risk Officer — Modernización (clasificación regulatoria CNBV)

> Toda sección marcada `[SME-PENDING]` requiere sesión de validación con el Domain Expert de LegacyCore antes de pasar a Etapa 2.
---


## Descripción

Catálogo de excepciones del dominio `bdicnweb` extraídas del análisis estático de 2184 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 2,148 |
| Códigos de excepción capturados únicos | 19 |

## RAISE EXCEPTION — excepciones lanzadas

Cada `RAISE EXCEPTION` representa una **regla de negocio violada** o un **error del sistema**. Los códigos negativos son errores de Informix; los positivos son errores de aplicación definidos por LegacyCore.

| Código | Frecuencia | SP origen | Mensaje extraído |
|--------|-----------|-----------|-----------------|
| [SME-PENDING] | | | |

> **[SME-PENDING]** Para cada código: (1) ¿es error de motor (-NNN) o de aplicación (+NNN)? (2) ¿Qué proceso de negocio lo genera? (3) ¿Cómo lo maneja el canal que invoca el SP? (4) ¿Qué debe hacer el target cuando ocurre?

## ON EXCEPTION — excepciones capturadas

Códigos de excepción que el dominio captura y maneja internamente:

| Código capturado | SPs que lo capturan | Comportamiento esperado |
|-----------------|--------------------|-----------------------|
| `-535` | 9,918 SPs | [SME-PENDING] |
| `-255` | 7,263 SPs | [SME-PENDING] |
| `-668` | 6,856 SPs | [SME-PENDING] |
| `-958` | 898 SPs | [SME-PENDING] |
| `-691` | 612 SPs | [SME-PENDING] |
| `-206` | 493 SPs | [SME-PENDING] |
| `-239` | 343 SPs | [SME-PENDING] |
| `-268` | 220 SPs | [SME-PENDING] |
| `-703` | 85 SPs | [SME-PENDING] |
| `-1206` | 53 SPs | [SME-PENDING] |
| `-1205` | 51 SPs | [SME-PENDING] |
| `-1263` | 40 SPs | [SME-PENDING] |
| `688` | 32 SPs | [SME-PENDING] |
| `255` | 32 SPs | [SME-PENDING] |
| `-1204` | 23 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sp_consultainforeportebc_detalleconsultas` | 400 bloque(s) | [SME-PENDING] |
| `sp_cedulacontablenombre` | 399 bloque(s) | [SME-PENDING] |
| `sp_conscedulasusuariosccl` | 399 bloque(s) | [SME-PENDING] |
| `sp_consreportesctasinactivasart61` | 398 bloque(s) | [SME-PENDING] |
| `sp_usuariocedulacons` | 398 bloque(s) | [SME-PENDING] |
| `sp_usuarioscedulasmantto` | 398 bloque(s) | [SME-PENDING] |
| `sp_consreportesctasinactivasart61_totales` | 397 bloque(s) | [SME-PENDING] |
| `sp_consultafechasart61` | 396 bloque(s) | [SME-PENDING] |
| `sp_verificastatusconsultafechasart61` | 395 bloque(s) | [SME-PENDING] |
| `sp_reportebloqueoctasmasivocre` | 394 bloque(s) | [SME-PENDING] |
| `sp_reportedesbloqueoctasmasivocre` | 393 bloque(s) | [SME-PENDING] |
| `sp_obtieneultimasimagenesdigicte` | 392 bloque(s) | [SME-PENDING] |
| `sp_verificastatusconsrepexcepciones` | 391 bloque(s) | [SME-PENDING] |
| `sp_verificastatusconsrepgralaut` | 389 bloque(s) | [SME-PENDING] |
| `sp_verificastatusconsrepperfilusuario` | 387 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/LegacyCore/informix/bdicnweb_*.sql*
