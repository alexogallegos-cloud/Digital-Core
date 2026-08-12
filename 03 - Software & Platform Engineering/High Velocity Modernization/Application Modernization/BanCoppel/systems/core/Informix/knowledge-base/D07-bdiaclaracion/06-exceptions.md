# D07 · Aclaraciones — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdiaclaracion` extraídas del análisis estático de 232 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 184 |
| Códigos de excepción capturados únicos | 8 |

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
| `-535` | 47 SPs | [SME-PENDING] |
| `-668` | 19 SPs | [SME-PENDING] |
| `-255` | 3 SPs | [SME-PENDING] |
| `-310` | 3 SPs | [SME-PENDING] |
| `-111` | 3 SPs | [SME-PENDING] |
| `-206` | 3 SPs | [SME-PENDING] |
| `-319` | 3 SPs | [SME-PENDING] |
| `-328` | 3 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sp_registra_notificacion` | 15 bloque(s) | [SME-PENDING] |
| `sp_crea_folio_aclaracion` | 14 bloque(s) | [SME-PENDING] |
| `sp_cargoxajuste_debcred` | 13 bloque(s) | [SME-PENDING] |
| `sp_fal_busca_beneficiarios_por_cuenta` | 13 bloque(s) | [SME-PENDING] |
| `sp_fal_busca_documentos_faltantes` | 13 bloque(s) | [SME-PENDING] |
| `sp_obten_cat_tipo_flujo` | 13 bloque(s) | [SME-PENDING] |
| `sp_registra_comentario_cliente` | 13 bloque(s) | [SME-PENDING] |
| `sp_acl_consulta_ciudades` | 12 bloque(s) | [SME-PENDING] |
| `sp_buscaempleadohuella_alta` | 12 bloque(s) | [SME-PENDING] |
| `sp_buscarclientesportarjeta` | 12 bloque(s) | [SME-PENDING] |
| `sp_busca_producto_cred_cliente` | 12 bloque(s) | [SME-PENDING] |
| `sp_busca_producto_cred_tarjeta` | 12 bloque(s) | [SME-PENDING] |
| `sp_consulta_cat_motivo_bloqueo_deb` | 12 bloque(s) | [SME-PENDING] |
| `sp_consulta_estatus_cuenta_cred` | 12 bloque(s) | [SME-PENDING] |
| `sp_fal_busca_pagares_cliente` | 12 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdiaclaracion_*.sql*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total errores del dominio:** 2 · **Códigos distintos:** 1

| Código | Descripción | Volumen/día | Servicios afectados |
|--------|-------------|-------------|---------------------|
| `3170` | Can't find SOAP body — mensaje de entrada sin estructura SOA | 2 | CambioDeInstruccion |

### SPs con mayor tasa de error

| SP | Llamadas/día | Errores/día | Error% |
|----|-------------|-------------|--------|
| `consctesfirminv` | 1 | 1 | 100.0% |
| `sp_registra_cte_domiciliacion` | 54 | 38 | 70.37% |
| `sp_verifica_aclaracion` | 82 | 1 | 1.22% |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
