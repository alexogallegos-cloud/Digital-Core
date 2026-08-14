# Metodología de Identificación de Reglas de Negocio — Informix SPL

> **Artefacto de KB · Capa 3 (Biografía) del Gemelo Cognitivo**
> Owner: DT-Reglas · Proyecto: BanCoppel Informix · SPE-AM-001
> Creado: 2026-08-13

## Por qué necesitamos una metodología

El brain-builder extrae mecánicamente sentencias SPL que contienen lógica (LET, IF, RAISE EXCEPTION). Pero una **regla de negocio** no es una sentencia: es una intención. La metodología define cómo ir de la sentencia cruda al significado de negocio, usando las señales que el propio código deja.

---

## Señal 1 — El código de retorno como firma de capacidad

### Principio

`LET cCodRet = "101"` no es un número arbitrario. Es la **firma de capacidad** del SP: declara explícitamente qué sabe manejar. El conjunto completo de códigos de retorno de un SP es su catálogo de casos de fallo — y por lo tanto, un mapa de qué capacidades implementa.

### Catálogo de patrones conocidos en BanCoppel

| Código | Semántica documentada | Capacidad implícita | Patrón de migración |
|--------|----------------------|---------------------|---------------------|
| `'101'` | No se encontró información | Query + resultado opcional | `Optional<T>` / `Result<T, NotFound>` |
| `'102'` | Registro duplicado | Insert con unicidad | `ConflictException` / `409` |
| `'103'` | Operación no permitida | Validación de estado | `ValidationException` |
| `'207'` | Cuenta no existe | Validación de cuenta | `EntityNotFoundException` |
| `'000'` | Éxito | — | `200 OK` |

> El catálogo completo se deriva del brain: `SELECT code, business_name, COUNT(*) FROM rules WHERE sub_tipo = 'CÓDIGO_RETORNO' GROUP BY code, business_name ORDER BY COUNT(*) DESC`.

### Regla de descubrimiento

> Cuando el mismo código aparece en múltiples SPs del mismo dominio con el mismo mensaje, es una **capacidad transversal** — candidata a repositorio compartido o microservicio de query en la arquitectura target.

**Ejemplo confirmado:** Código `'101'` = "No se encontró información" aparece en `sp_consulta_instruccioninversioncreciente`, `sp_consulta_instruccionvencimiento` y `sp_consultainversioncreciente` (dominio `bdicheq`). Los tres implementan el mismo patrón de consulta. En Java target: un único `InstruccionRepository.findById()` que retorna `Optional<Instruccion>`.

---

## Señal 2 — El mensaje del código de retorno revela el flujo previo

### Principio

El comentario inline en la sentencia `LET cCodRet = "101"; -- No se encontró información` no es documentación pasiva: es una **pista de flujo**. "No se encontró información" implica que antes hubo una búsqueda. La regla de retorno solo es posible si existe una operación de lectura que puede retornar cero filas.

### Patrón en Informix SPL

```sql
-- Siempre hay un bloque de búsqueda antes del código 101:

FOREACH SELECT campo1, campo2
        INTO   vCampo1, vCampo2
        FROM   tabla
        WHERE  condicion
    -- aquí se procesa el registro encontrado
    LET vEncontrado = 1
END FOREACH

IF vEncontrado = 0 THEN
    LET cCodRet = '101'   -- No se encontró información
    RETURN
END IF
```

O la variante con SELECT INTO + SQLCODE:

```sql
SELECT campo INTO vCampo FROM tabla WHERE condicion

IF SQLCODE = 100 THEN   -- NOTFOUND en Informix
    LET cCodRet = '101'
    RETURN
END IF
```

### Qué buscar en el código fuente

Cuando se detecte `LET cCodRet = '101'` en un SP, revisar en el mismo SP:
1. ¿Hay un `FOREACH SELECT ... END FOREACH`? → capacidad de query múltiple
2. ¿Hay un `SELECT ... INTO ...`? → capacidad de query single-row
3. ¿Cuáles son las tablas en el FROM? → dato de qué entidad se consulta
4. ¿Cuáles son las condiciones WHERE? → parámetros de búsqueda → API params del microservicio

### Implicación de migración

| Hallazgo | Implicación |
|----------|-------------|
| `FOREACH SELECT` + `'101'` | Método de repositorio retorna `List<T>`, `'101'` = lista vacía (no error) |
| `SELECT INTO` + `'101'` | Método retorna `Optional<T>`, `'101'` = `Optional.empty()` |
| Mismo `'101'` en N SPs del mismo dominio | Un solo `findBy*()` puede reemplazar N SPs |

---

## Señal 3 — Reglas compuestas (multi-fragmento)

### Principio

Una regla de negocio con cálculo complejo se expresa en SPL como N sentencias `LET` consecutivas que **comparten variables**. El brain-builder las captura como N reglas independientes con el mismo `business_name`. Semánticamente son UNA sola regla con sub-pasos ordenados.

### Criterios de identificación

Un grupo de reglas es **compuesto** (una sola regla de negocio) cuando:

1. Mismo SP y mismo `business_name`
2. Dispersión de líneas ≤ 80 (los pasos están cerca en el código)
3. Comparten ≥ 1 variable no-trivial entre fragmentos (dependencia de datos)

### Ejemplo confirmado — Provisión de intereses (CNBV + GAT)

```sql
-- Tres fragmentos, una regla: ajuste de provisión de intereses
-- Regla: Criterios contables CNBV + GAT

-- Paso 1: interés acumulado al día de corte
LET vInteres = vInteres * (DAY(vFecha) - 1)

-- Paso 2: provisión = interés × días de alta
LET vProvision = vInteres * DAY(vAlta)

-- Paso 3: interés ajustado por el diferencial de días
LET vInteres = vInteres * ((DAY(vFecha) - DAY(vAlta)) - 1)
```

`vInteres` se actualiza en paso 1, alimenta el paso 2 (produce `vProvision`), y se recalcula en paso 3. Son inseparables: migrar uno sin los otros produce un error silencioso en el cálculo de provisiones al cierre de mes.

### Qué detecta el pipeline

`generators/group-compound-rules.py` detecta estos grupos y asigna un `compound_group_id` (ej. `CG-bdicheq-ajusteprovision-001`). El coherence scorer (`validate-rules-vs-code.py`) unifica los contextos del grupo para calcular el score sobre la expresión completa, no sobre cada fragmento aislado.

**Resultado en BanCoppel:** 279 grupos compuestos, 730 reglas agrupadas (12% del total NEGOCIO).

### Implicación de migración

> Un grupo compuesto es una **unidad atómica de migración**. Todos sus fragmentos deben moverse juntos en el mismo sprint, al mismo microservicio, y cubrirse por el mismo caso de prueba.

---

## Señal 4 — Constantes literales embebidas (LET var = literal)

### Principio

`LET vValIva = 0.16` no es una variable ordinaria: es una **constante de negocio** codificada como assignment. Su valor tiene significado regulatorio o financiero conocido.

Ver el artefacto de notación húngara: [notacion-hungara-spl.md](../vocabulary/notacion-hungara-spl.md) §"Propagación de constantes".

### Constantes fiscales y regulatorias identificadas en BanCoppel

| Patrón en código | Significado | Regulación | Tipo de migración |
|-----------------|-------------|------------|-------------------|
| `= 0.16` / `* 16/100` | Tasa IVA México | LIVA Art.1 | Config: `tax.iva.rate` |
| `= 0.08` | Tasa IVA frontera | LIVA zona libre | Config: `tax.iva.border.rate` |
| `= 10000` / `= 10,000` | Umbral reporte PLD | GAFI / UIF | Config: `compliance.pld.threshold` |
| `= 0.0090` | Tasa ISR intereses 2026 | LISR Art.54/135 | Config: `tax.isr.interest.rate` (varía anual) |
| `= 90` (días) | Cartera vencida | CUB B-5 CNBV | Config: `credit.past_due.days` |
| `= 400000` (UDIs) | Cobertura máx IPAB | LPAB Art.22 | Config: `deposit.ipab.max_udis` |

> **Regla universal de migración:** Toda constante con significado regulatorio o financiero en un `LET var = literal` debe migrarse como **parámetro de configuración externalizado**, nunca como valor hardcodeado en el target. Un cambio de tasa (frecuente en regulación MX) debe ejecutarse sin redeployment.

---

## Señal 5 — El comentario inline como fuente de semántica

### Principio

En BanCoppel, el desarrollador pone el significado de la sentencia como comentario inline:

```sql
LET cCodRet = '101'   -- No se encontró información
LET cCodRet = '207'   -- La cuenta no existe en el sistema
LET vIVA = TRUNC(vMonto * vValIva, 2)   -- Cálculo IVA 16% redondeado a 2 decimales
```

El comentario es muchas veces más informativo que el nombre de la variable. El coherence scorer normaliza los acentos del texto de los comentarios para que los tokens del comment (`encontró` → `encontro`) hagan match con el `business_name`.

### Implicación de metodología

> Antes de declarar que una regla tiene "baja coherencia semántica", verificar si el significado está en el comentario inline. El pipeline lo captura; si el score sigue bajo, la descripción del business_name es genuinamente incompleta y necesita enriquecimiento manual.

---

## Señal 6 — Reglas replicadas cross-SP (misma regla en múltiples SPs)

### Principio

Una misma regla de negocio (`business_name` + fragmento de código idéntico o semánticamente equivalente) puede aparecer en **múltiples SPs distintos**. Esto no son N reglas — es **una sola regla de negocio** replicada porque en el legacy cada SP reimplementa la misma lógica en lugar de llamar a un componente compartido.

### Diferencia con regla compuesta

| Dimensión | Regla compuesta (Señal 3) | Regla replicada (Señal 6) |
|-----------|--------------------------|--------------------------|
| Alcance | Un solo SP | Múltiples SPs distintos |
| Fragmentos | Pasos interdependientes (comparten variables) | Copias independientes del mismo código |
| Causa raíz | Cálculo complejo en N pasos | Copy-paste de capacidad sin abstracción |
| Migración | Mover los N pasos atómicamente | Consolidar en un solo método/servicio |

### Ejemplo confirmado — Código 101 "No se encontró información" en bdicheq

```
BR-V2-1258  bdicheq:sp_consulta_instruccioninversioncreciente  LET cCodRet = '101'
BR-V2-1262  bdicheq:sp_consulta_instruccionvencimiento         LET cCodRet = '101'
BR-V2-1282  bdicheq:sp_consultainversioncreciente              LET cCodRet = '101'
```

Tres SPs distintos, misma regla: "si la consulta no retorna filas, retornar código 101". En la arquitectura target esto es **un solo método de repositorio** con retorno `Optional<Instruccion>`.

### Impacto en el inventario de reglas

Las reglas replicadas inflan el conteo total y ocultan el nivel de consolidación real:

- **Total bruto**: N reglas en la base de datos
- **Total único** (deduplicado por `business_name` + semántica de código): N − réplicas
- **Índice de replicación** = Total bruto / Total único → mide el technical debt de copy-paste

El índice de replicación también indica cuántos microservicios/métodos del target realmente se necesitan vs. cuántos SPs existen hoy.

**Resultado medido en BanCoppel (2026-08-13):**

| Métrica | Valor |
|---------|-------|
| Total reglas NEGOCIO en brain | 6,067 |
| Grupos cross-SP identificados | 875 |
| Instancias redundantes | 2,560 (42%) |
| **Reglas únicas reales** | **3,507** |

Top réplicas: `'1001'` 447×, `'110'` ~150×, `'99999'` 19×. El código `'1001'` —error genérico del sistema— aparece en casi todos los SPs y se convierte en un único `GlobalExceptionHandler` en el target.

### Qué detecta el pipeline

```sql
-- Candidatos a regla replicada:
SELECT business_name, code, COUNT(DISTINCT sp) AS sp_count
FROM rules
WHERE clase = 'NEGOCIO'
GROUP BY business_name, code
HAVING sp_count > 1
ORDER BY sp_count DESC;
```

El campo `cross_sp_replica_id` (por implementar en brain.db) agrupará estas réplicas, permitiendo:
1. Reportar el conteo real de reglas únicas (vs. instancias)
2. Identificar qué capacidades tienen mayor replicación (candidatas prioritarias a consolidación)
3. Mapear N SPs → 1 método en el target

### Implicación de migración

> Cada grupo de reglas replicadas cross-SP mapea a exactamente **un** método o componente en la arquitectura target. El número de grupos únicos (no el número total de instancias) es el tamaño real del backlog de migración de lógica de negocio.

---

## Secuencia de aplicación de las 6 señales

```
1. CÓDIGO_RETORNO presente
   → ¿Cuál es el código y su semántica?
   → ¿Aparece en otros SPs del dominio? (→ Señal 6: regla replicada → candidata a consolidación)

2. Mensaje del código (comentario / business_name)
   → ¿Dice "no se encontró"? → hay SELECT/FOREACH previo → mapear a Optional<T>
   → ¿Dice "duplicado"?     → hay INSERT previo → mapear a ConflictException
   → ¿Dice "no permitido"?  → hay validación de estado → mapear a ValidationException

3. Mismo business_name, mismo SP, múltiples sentencias
   → ¿Comparten variables? → regla compuesta (Señal 3) → migrar atómicamente como unidad

4. Mismo business_name + mismo código, múltiples SPs
   → Regla replicada (Señal 6) → un solo método en el target → calcular índice de replicación

5. LET var = literal numérico
   → ¿Es un valor regulatorio conocido? → externalizar como config → documentar en vocabulario

6. Comentario inline
   → Si el business_name es vago, el comentario puede tener el significado real
   → Ambos forman juntos el contexto semántico completo de la regla
```

---

## Señal 7 — Condición IF como semántica de retorno y excepción

### Principio

Un `CÓDIGO_RETORNO` o `EXCEPCIÓN` sin contexto visible tiene su significado en la condición IF que lo dispara, típicamente en las ±30 líneas anteriores. El extractor backward-IF (`find_trigger_condition()` en `enrich-return-codes.py`) busca hacia atrás el primer IF/ELIF/ELSE y extrae la condición como parte del business_name.

### Patrón
```
-- backward-IF context: IF v_estado = 'P'
LET cCodRet = '600'   →   "código 600 — cheque pagado (vestado='P')"
```

**Resultado:** CÓDIGO_RETORNO: 95% HIGH (desde <70%). EXCEPCIÓN: 95% HIGH. La condición IF es la semántica principal, no el número de código.

---

## Señal 8 — Swarm de expertos dominio para fórmulas CNBV/fiscal

### Principio

Fórmulas financieras con label genérico ("Calcular X") se envían a agentes expertos por dominio (CNBV+GAT, LTOSF+CAT, bdicheq, bdinvers, bdicred, multi-dominio). Cada agente produce un `enriched_name` específico con tokens del código fuente (no metadatos en español).

**Regla crítica de coherencia:** los tokens añadidos al business_name deben existir en el código SPL. Tokens de metadatos en español (e.g. "centavos", "compartida", "pesos") que no están en el código REDUCEN el score de coherencia.

**Resultado swarm MEDIUM (4 agentes · 2026-08-13):**
- Agent 1 (bdicred+bdicont): 189 enrichments — cuota francesa PMT, CNBV B-5 PI, reserva pesos 30.42
- Agent 2 (bdicheq): 148 enrichments — GAT, ISR, saldo promedio, tipo de cambio
- Agent 3 (bdinvers+bdinteg+23 dominios): 221 enrichments — provisión diaria pagaré, ISR IPAB, scoring AML PLD
- Agent 4 (programático): 755 enrichments — 701 automáticas + 54 manuales CNBV/GAT/ISR/CAT
- **Total: 1,313 enrichments. HIGH MEDIUM: de 79% a 84.4%.**

---

## Señal 9 — Inversión de signo × -1: doble semántica contable

### Principio

`LET var = var * -1` tiene dos significados distintos en BanCoppel:

1. **Polaridad contable debe→haber**: `sdo_ret * -1` en bdicheq — convierte saldo positivo a negativo para presentar como débito en extracto.
2. **Valor absoluto en aritmética de fechas**: `iDiastranscurridos = iDiastranscurridos * -1` en `sp_obtienefechapago_creditos` — cuando la fecha de pago del ciclo ya pasó, el resultado de la resta es negativo; `* -1` convierte a valor absoluto para comparar contra umbral de días (≥8 → avanzar mes).

**Regla de discriminación:** el contexto de la variable objetivo (tipo MONEY/INTEGER + dominio bdicheq vs. bdicred) distingue el caso. En migración: transformer de presentación (caso 1) vs. `Math.abs()` + lógica de ciclo (caso 2).

---

## Señal 10 — Bloque comentado /* */ — falso positivo del brain-builder

### Principio

El brain-builder captura líneas dentro de bloques `/* ... */` como reglas de negocio activas. Síntoma diagnóstico: el código de la regla termina con `*/`. Estas son reglas de código muerto (código desactivado, no borrado). En migración: clasificar como `clase = INACTIVO` y excluir del inventario activo.

**Ejemplo confirmado:** BR-V2-6771 en bdicred, código termina en `*/`. El nombre le asignó coherencia baja hasta que el análisis de código fuente confirmó que era dead code comentado.

---

## Señal 11 — Algoritmo dígito verificador: Luhn mod-10

### Principio

El patrón `digito × peso (1 ó 2)` dentro de un bucle FOR, acumulado en `iSuma` y verificado con `MOD(iSuma, 10)`, implementa el algoritmo de Luhn. BanCoppel lo usa en tres contextos:
- **BTS** (11 dígitos, posiciones 4-10): `sp_validabts` — número de confirmación de pago
- **CLABE** (18 dígitos): `sp_validadv` — Clave Bancaria Estandarizada  
- **CCC** (11 dígitos): `sp_validadv` — Clave de Cliente Coppel

En migración: un único `DigitVerifier.validateLuhn(number, positions)` reemplaza los tres SPs. No son reglas de negocio — son validaciones de integridad de dato.

---

## Señales emergentes S12–S15 (observaciones del swarm, 2026-08-13)

Estas señales fueron observadas durante el swarm de enriquecimiento MEDIUM pero no implementadas como cambios en brain.db, ya que no pasan la regla de S8: sus tokens de semántica no aparecen en el código SPL de la regla individual.

### S12 — Fórmula canónica compartida cross-SP → candidato de extracción

`detect-shared-formulas.py` normaliza la RHS de asignaciones de cálculo y agrupa por fingerprint. Con umbral ≥3 SPs y ≥3 tokens VAR, encontró 59 fórmulas compartidas en 391 reglas:

| Fórmula (normalizada) | SPs | Capacidad a extraer |
|----------------------|-----|---------------------|
| `(VAR * (VAR/100)) * VAR / VAR` | 19 | ISR retención sobre base IPAB |
| `(VAR * (VAR/100) * VAR) / 360` | 16 | Interés diario base 360 |
| `((NVL(VAR,0) + VAR/2) / VAR)::SMALLINT` | 15 | Redondeo bancario entero Coppel |
| `TRUNC(((VAR/100) * VAR) / VAR, 6)` | 12 | ISR 6 decimales retención |
| `1/(1 + EXP(coefs + VAR * coefs + ...))` | 8 | PI logística CNBV B-5 |
| `VAR / (POW(1+VAR, -VAR) ...)` | 7 | Anualidad PMT (pago mensual crédito) |
| `(VAR + VAR) / VAR` | 7 | Provisión diaria pagaré (vprovdia) |

**En migración:** cada cluster es candidato a un único servicio compartido. El número de clusters (59) es la lista de extracción de lógica financiera transversal, independiente del número de SPs.

### S13 — Centavos÷100 en archivos de medios de pago

`importe::MONEY / 100` en bditarjeta: archivos INTERCARD y MasterCard almacenan montos en centavos (INTEGER). La conversión `::MONEY / 100` es una conversión de unidad, no aritmética genérica. En migración: el adapter de medio de pago debe declarar la unidad canónica (pesos vs. centavos) en su boundary.

Afecta ~12 SPs en bditarjeta. El token `MONEY` sí aparece en el código y mejora coherencia cuando el business_name lo incluye.

### S14 — Función logística PI CNBV B-5 (probabilidad de incumplimiento)

`dPI = 1/(1 + EXP(β₀ + β₁×iACT + β₂×iHIST + β₃×dPorUt ...))` — modelo regulatorio CNBV CUB B-5 para cartera de consumo. Los parámetros `2.1859`, `0.7864`, `0.3978` son los coeficientes del modelo. Aparece en 8 SPs de bdicred. Ya enriquecido por el swarm con tokens del código fuente (`dPI`, `iACT`, `iHIST`, `gencartconsumo`).

### S15 — Acumulador saldo ponderado × días (base de saldo promedio)

`vgacum_sdo_pos = vgacum_sdo_pos + vgsdo_actual * pdias` — acumulador de saldo positivo ponderado por días, base del cálculo de intereses y GAT. Aparece en 7 SPs de bdicheq (cierre_diario, cierre_mensual). Ya enriquecido por el swarm con tokens `sdo_pos`, `pdias`, `cierre`.

---

## Relación con otros artefactos

- **Notación húngara SPL**: [notacion-hungara-spl.md](../vocabulary/notacion-hungara-spl.md) — señales 4 y 5 (tipo declarado, CamelCase, constantes)
- **Coherence check**: `generators/validate-rules-vs-code.py` — implementa señales 3, 4 y 5
- **Compound grouper**: `generators/group-compound-rules.py` — implementa señal 3
- **Detector de fórmulas compartidas**: `generators/detect-shared-formulas.py` — implementa señal S12 (sólo reporte, no modifica brain.db)
- **Catálogo de reglas**: `business-rules-bcop.md` — output enriquecido aplicando esta metodología

---

*v2.0 · 2026-08-13 · DT-Reglas · Metodología ampliada a 11 señales implementadas + S12-S15 emergentes. Swarm MEDIUM: 1,313 enrichments. HIGH final: 84.4% (5,123 / 6,067). LOW: 0.*
