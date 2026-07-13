# D03 · Créditos — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdicred` extraídas del análisis estático de 1650 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 1,387 |
| Códigos de excepción capturados únicos | 11 |

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
| `-535` | 274 SPs | [SME-PENDING] |
| `-268` | 57 SPs | [SME-PENDING] |
| `-668` | 56 SPs | [SME-PENDING] |
| `-255` | 24 SPs | [SME-PENDING] |
| `-691` | 23 SPs | [SME-PENDING] |
| `-206` | 23 SPs | [SME-PENDING] |
| `-1207` | 22 SPs | [SME-PENDING] |
| `-391` | 9 SPs | [SME-PENDING] |
| `-214` | 9 SPs | [SME-PENDING] |
| `-846` | 6 SPs | [SME-PENDING] |
| `-1267` | 2 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sp_reversioncrd_ofi` | 16 bloque(s) | [SME-PENDING] |
| `sp_consctaligada` | 15 bloque(s) | [SME-PENDING] |
| `sp_consultagralstatusaumlincred` | 15 bloque(s) | [SME-PENDING] |
| `detalle_edoctacrd_sif` | 14 bloque(s) | [SME-PENDING] |
| `sp_adn_tramite_aut` | 14 bloque(s) | [SME-PENDING] |
| `sp_ofi_validacred` | 14 bloque(s) | [SME-PENDING] |
| `aclaraciones_edoctacrd_sif` | 13 bloque(s) | [SME-PENDING] |
| `sp_consprestamocte` | 13 bloque(s) | [SME-PENDING] |
| `sp_muestreo_edoctacorte` | 13 bloque(s) | [SME-PENDING] |
| `sp_pago_anticipado_pp` | 13 bloque(s) | [SME-PENDING] |
| `altatarcred_v_1` | 12 bloque(s) | [SME-PENDING] |
| `sp_cac_obtencausastatusaumlincred` | 12 bloque(s) | [SME-PENDING] |
| `sp_clona_tdc_upgrade_sc` | 12 bloque(s) | [SME-PENDING] |
| `sp_consultacredbloqfallecimiento` | 12 bloque(s) | [SME-PENDING] |
| `sp_consultas_cac_central_cte` | 12 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicred_*.sql*
