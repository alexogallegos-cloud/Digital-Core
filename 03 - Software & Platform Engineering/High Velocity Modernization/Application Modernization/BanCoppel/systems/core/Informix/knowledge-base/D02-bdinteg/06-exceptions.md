# D02 · Integración y Autenticación — Excepciones y Manejo de Errores

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdinteg` extraídas del análisis estático de 2034 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 1,621 |
| Códigos de excepción capturados únicos | 9 |

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
| `-535` | 111 SPs | [SME-PENDING] |
| `100` | 47 SPs | [SME-PENDING] |
| `-255` | 24 SPs | [SME-PENDING] |
| `-668` | 22 SPs | [SME-PENDING] |
| `-1267` | 10 SPs | [SME-PENDING] |
| `-239` | 6 SPs | [SME-PENDING] |
| `-243` | 1 SPs | [SME-PENDING] |
| `-242` | 1 SPs | [SME-PENDING] |
| `1` | 1 SPs | [SME-PENDING] |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `sysbldsqltextin` | 614 bloque(s) | [SME-PENDING] |
| `sp_concurso_renueva2012` | 24 bloque(s) | [SME-PENDING] |
| `sp_cnsif_actbloqueo` | 22 bloque(s) | [SME-PENDING] |
| `sp_cnsif_actualizamodulo` | 21 bloque(s) | [SME-PENDING] |
| `sp_cnsif_actualizaperfil` | 20 bloque(s) | [SME-PENDING] |
| `sp_cnsif_actualizaperfilfuncion` | 19 bloque(s) | [SME-PENDING] |
| `sp_cnsif_actualizausuario` | 18 bloque(s) | [SME-PENDING] |
| `act_encab` | 17 bloque(s) | [SME-PENDING] |
| `sp_repaltaunicaidbox` | 17 bloque(s) | [SME-PENDING] |
| `actividad` | 16 bloque(s) | [SME-PENDING] |
| `sp_desblcta_por_activ_subact` | 16 bloque(s) | [SME-PENDING] |
| `alta_nip` | 15 bloque(s) | [SME-PENDING] |
| `cambio_nip` | 15 bloque(s) | [SME-PENDING] |
| `cambio_status_nip` | 15 bloque(s) | [SME-PENDING] |
| `carga_div` | 15 bloque(s) | [SME-PENDING] |

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
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/informix/bdinteg_*.sql*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

**Total errores del dominio:** 4,307 · **Códigos distintos:** 6

| Código | Descripción | Volumen/día | Servicios afectados |
|--------|-------------|-------------|---------------------|
| `3381` | Fallo en lectura de imagen por SFTP — postActualizaImagen Po | 3,244 | PrestamoNominaExpedienteDigital |
| `4395` | Unhandled exception en plugin IIB — NullPointerException en  | 524 | CoppelBot, CoppelCom, CuentaN2 |
| `4394` | Unhandled exception en plugin IIB — MbUserException genérica | 314 | Cliente, Cliente2, CoppelCom |
| `3743` | Handle Timed-out — timeout en conexión SOAP/JNI con sistema  | 154 | Cliente, Cliente2 |
| `5004` | XML parsing error — trama de respuesta malformada | 65 | Nip |
| `3701` | Error en JNI Call — Axis2Invoker fallo de comunicación SOAP  | 6 | Cliente, Cliente2 |

### SPs con mayor tasa de error

| SP | Llamadas/día | Errores/día | Error% |
|----|-------------|-------------|--------|
| `sp_consultacten2` | 29,221 | 29,166 | 99.81% |
| `sp_consulta_datos_cte_coppel` | 39,497 | 1,580 | 4.0% |
| `sp_valida_huellacte_dec` | 9,379 | 290 | 3.09% |
| `sp_guardar_bitacora_rostro` | 2,596 | 80 | 3.08% |
| `sp_ws_valida_cotel` | 20,974 | 377 | 1.8% |
| `sp_obtenerctas_cte2_web` | 6,710 | 112 | 1.67% |
| `sp_grabacomparacionhuelladec` | 4,008 | 64 | 1.6% |
| `val_fechas_web` | 33,364 | 355 | 1.06% |
| `sp_obtclavetarjeta` | 8,332 | 88 | 1.06% |
| `sp_obtieneinfprod2` | 5,952 | 41 | 0.69% |

*Generado por generate-kb-from-logs.py · 2026-08-01*
<!-- LOG-DATA-END -->
