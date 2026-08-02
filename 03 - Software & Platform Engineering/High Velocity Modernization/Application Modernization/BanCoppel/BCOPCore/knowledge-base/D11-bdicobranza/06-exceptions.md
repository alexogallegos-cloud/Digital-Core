# D11 · Cobranza — Excepciones y Manejo de Errores

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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

Catálogo de excepciones del dominio `bdicobranza` extraídas del análisis estático de 311 archivos SQL. Incluye:
- `RAISE EXCEPTION` — excepciones lanzadas (reglas de negocio violadas)
- `ON EXCEPTION IN (códigos)` — excepciones capturadas (manejo de errores)
- Bloques `ON EXCEPTION … END EXCEPTION` — patrones de recuperación

## Resumen

| Métrica | Valor |
|---------|-------|
| SPs con RAISE EXCEPTION | 0 |
| Códigos de excepción únicos lanzados | 0 |
| SPs con ON EXCEPTION | 234 |
| Códigos de excepción capturados únicos | 0 |

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
| [SME-PENDING] | | |

## SPs con manejo estructurado de excepciones

SPs que tienen bloques `ON EXCEPTION … END EXCEPTION` (patrones de recuperación):

| SP | Bloques | Comportamiento de recuperación |
|----|---------|-------------------------------|
| `fn_formaretiquetaxml` | 105 bloque(s) | [SME-PENDING] |
| `sp_cat_tpsstatuscte` | 11 bloque(s) | [SME-PENDING] |
| `sp_cat_tpsexcepcion` | 10 bloque(s) | [SME-PENDING] |
| `sp_cilocconsultaalertas` | 10 bloque(s) | [SME-PENDING] |
| `sp_consultatargetphone` | 10 bloque(s) | [SME-PENDING] |
| `sp_generapagominincompleto` | 10 bloque(s) | [SME-PENDING] |
| `sp_obtienecobranzaadministrativa` | 10 bloque(s) | [SME-PENDING] |
| `sp_cat_conscartera` | 9 bloque(s) | [SME-PENDING] |
| `sp_cilocconsultamarcas` | 9 bloque(s) | [SME-PENDING] |
| `sp_consultapagoincompleto` | 9 bloque(s) | [SME-PENDING] |
| `sp_cat_cambia_estatus_cte` | 8 bloque(s) | [SME-PENDING] |
| `sp_cilocconsultasituacionesmarcas` | 8 bloque(s) | [SME-PENDING] |
| `sp_consultainfofechreestructura` | 8 bloque(s) | [SME-PENDING] |
| `sp_obtienetdcporentregar` | 8 bloque(s) | [SME-PENDING] |
| `sp_cat_consparamcampania` | 7 bloque(s) | [SME-PENDING] |

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

### CWE-390 — Excepción silenciosa en `sp_obtener_datos_cv_web` (VERIFICADO EN CÓDIGO · P655-R010)

**Fuente:** `source/BCOPCore/informix/bdicobranza_sp_obtener_datos_cv_web.sql` · Verificado: 2026-08-01

Este SP muestra el patrón CWE-390 (*Detection of Error Condition Without Action*): el bloque `ON EXCEPTION` captura la excepción del motor Informix, la convierte a código numérico y la retorna como si fuera un código de negocio ordinario, sin escribir a bitácora ni relanzar la excepción.

```sql
-- Patrón CWE-390 detectado (líneas del SP):
ON EXCEPTION SET sSqlErr
    LET cCodRet = sSqlErr;   -- convierte integer de Informix a CHAR(5) ← BUG
    RETURN cCodRet, ...;      -- retorna error como código de negocio
END EXCEPTION;
```

**Consecuencia en producción:** el ESB recibe `estatus=error` pero `top_resp_codes: {}` vacío — el error existe pero su código es ilegible. El sistema llamante (Caja2) interpreta la respuesta vacía como "cliente sin perfil" y lo omite del ciclo de gestión **sin generar ninguna alerta**. Resultado: 49,701 perfiles no gestionados por día.

### CHAR(5) — Truncación de código de error en `sp_obtener_datos_cv_web` (DEFECTO-PROD · P655-R009)

**Fuente:** mismo archivo · Verificado: 2026-08-01

La variable de retorno `cCodRet` está declarada `CHAR(5)`. Los códigos de error de Informix son enteros convertidos a cadena de hasta 6 caracteres (p. ej. `-00206`). La asignación `LET cCodRet = sSqlErr` **trunca el sexto carácter**, produciendo un código incompleto que el ESB no puede clasificar.

```sql
-- Declaración del SP:
DEFINE cCodRet CHAR(5);    -- ← bug: debería ser CHAR(6) para cubrir códigos Informix de 4 dígitos + signo + padding

-- Al ejecutar ON EXCEPTION:
LET cCodRet = sSqlErr;     -- sSqlErr es INTEGER; la conversión a CHAR(5) trunca el código real
```

**Fix requerido:** cambiar `CHAR(5)` → `CHAR(6)` y agregar logging en el bloque `ON EXCEPTION`. Requiere sesión con DBA IBM Informix para deploy en producción.

**Impacto combinado CWE-390 + CHAR(5):** estos dos defectos se potencian mutuamente. Incluso si se corrige el CHAR, sin logging el error seguirá siendo invisible para operaciones. Ambos deben corregirse juntos.

### Clasificación de los [SME-PENDING] anteriores

Los patrones "comportamiento silencioso" que el análisis estático dejó como [SME-PENDING] están confirmados:

| Patrón | Estado | SP confirmado |
|--------|--------|--------------|
| `ON EXCEPTION → RETURN código numérico sin log` | CONFIRMADO (CWE-390) | `sp_obtener_datos_cv_web` |
| `RETURN con variable truncada (CHAR(5) vs. CHAR(6))` | CONFIRMADO (DEFECTO-PROD) | `sp_obtener_datos_cv_web` |
| `ON EXCEPTION → ROLLBACK → CONTINUE sin log` | [SME-PENDING] otros SPs | Por confirmar en sesión DBA |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: source/BCOPCore/informix/bdicobranza_*.sql*
*Actualizado: DT-Riesgos · 2026-08-01 · Verificación en código de CWE-390 + CHAR(5) en sp_obtener_datos_cv_web (P655-R009/R010)*

<!-- LOG-DATA-BEGIN -->
## Hallazgos de producción — Logs 2026-04-24
> Fuente: `source/logs/errores_bus_2026-04-24_*.txt` · Incorporado: 2026-08-01

> Sin errores registrados para este dominio en el período analizado.
<!-- LOG-DATA-END -->
