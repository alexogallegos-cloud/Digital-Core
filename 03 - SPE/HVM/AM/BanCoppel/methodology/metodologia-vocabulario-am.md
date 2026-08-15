# Metodología de Identificación de Vocabulario — Application Modernization
> **Ecosistema**: BanCoppel Digital Brain · SPE-AM-001
> **Versión**: 1.0.0 · 2026-08-14
> **Aplica a**: cualquier sistema analizado dentro del Gemelo Cognitivo (Informix SPL, Java/Spring, COBOL, AS/400...)
> **Implementación de referencia**: `systems/core/Informix/generators/sp_vocab.py`

---

## 1. Por qué existe esta metodología

El vocabulario es la **Capa 1 del Gemelo Cognitivo** — la lengua que el sistema habla. Sin vocabulario preciso, las Almas, los Journeys y las Reglas no tienen nombres estables. Cuando un equipo de modernización no entiende el vocabulario del sistema legacy, comete errores de semántica que no se detectan en pruebas y aparecen en producción.

El objetivo de la identificación de vocabulario es construir un **glosario bilingüe** (código ↔ negocio) que:
- Permite que el equipo de modernización hable el mismo idioma que el sistema legacy
- Da nombre estable a las entidades, acciones y reglas que se documentan en los otros DTs
- Alimenta el AppMovil Brain como capa semántica del Knowledge Graph

---

## 2. Fuentes de minería

El vocabulario se extrae de **cuatro fuentes**, en orden de confiabilidad:

| Fuente | Qué aporta | Sistema Informix | Sistema Java/Spring |
|--------|-----------|-----------------|---------------------|
| **F1 · Identificadores del código** | Términos de negocio fosilizados en el naming | Nombres de SPs, tablas, columnas | Nombres de MSAs, clases, métodos, constantes |
| **F2 · Parámetros y firmas** | Entidades y atributos operacionales | Parámetros de SPs (CHAR/MONEY/DATE) | Campos de DTOs, `@RequestParam`, properties |
| **F3 · Configuración** | Dominios funcionales, contratos de integración | `informix.ini`, CTL files | `application-dev.properties`, `Constants.java`, `EntityConstants.java` |
| **F4 · Documentación embebida** | Intención declarada por el equipo original | Comentarios en SPL | Javadoc, READMEs de MSA |

**Regla de prioridad**: un término confirmado en F1 > F2 > F3 > F4. Un término solo en F4 se marca `inf` hasta que se confirme en otra fuente.

---

## 3. Taxonomía de categorías

Todo término se clasifica en una de seis categorías canónicas:

| Categoría | Qué captura | Pregunta de clasificación | Ejemplos |
|-----------|-------------|--------------------------|----------|
| `PREFIJO` | Familia, subsistema, canal o dominio | ¿Es un namespace o identificador de grupo? | `spei`, `msa`, `BEX`, `bdicheq` |
| `ACCION` | Verbos de negocio — qué hace el sistema | ¿Es un verbo que opera sobre una entidad? | `consulta`, `valida`, `registra`, `decodifica` |
| `ENTIDAD` | Objetos de negocio — sobre qué opera el sistema | ¿Es un sustantivo de dominio bancario? | `cuenta`, `saldo`, `MTU`, `amortización` |
| `MODIF` | Modificadores de contexto o alcance | ¿Califica a una entidad o acción sin ser ninguna? | `diario`, `multicanal`, `automático` |
| `REG` | Términos regulatorios con ente normativo claro | ¿Hay un regulador (Banxico, CNBV, SAT, PCI-DSS) detrás? | `CoDi`, `SPEI`, `CLABE`, `CFDI`, `ISR` |
| `AMBIGUO` | Polisemia confirmada o token desconocido | ¿El mismo token tiene dos significados distintos en el sistema? | `desc` (descripción / descarga), `seg` (seguridad / seguro) |

**Regla de ambigüedad**: cuando un token tiene dos significados frecuentes en el mismo sistema, se documenta como AMBIGUO con ambos contextos. No se simplifica — la polisemia es información valiosa.

---

## 4. Estados de evidencia

Cada término lleva un estado que declara cuánta certeza tiene la definición:

| Estado | Criterio | Acción requerida |
|--------|----------|-----------------|
| `conf` | Confirmado en código fuente (F1-F3) o validado explícitamente por un SME del equipo BanCoppel | Publicar en el vocabulario |
| `inf` | Inferido por contexto — coherente con el dominio pero no encontrado directamente en código | Incluir pero marcar; escalar a SME en la siguiente sesión |
| `gap` | Ambiguo o contradictorio — múltiples interpretaciones posibles sin evidencia que las resuelva | No publicar sin resolución; registrar en worklist de SME |

---

## 5. Clasificación de scope

El scope determina si el término pertenece al banco o al sistema específico:

| Scope | Criterio | Reutilización |
|-------|----------|---------------|
| `enterprise` | Palabra española ≥4 chars en categoría ENTIDAD/ACCION/REG; el concepto existe en otros sistemas BanCoppel | Entra al `vocab-bancoppel.json` y al `bank-brain.db` — disponible cross-sistema |
| `system` | Prefijo técnico ≤3 chars, sigla de infraestructura o acrónimo de un sistema específico | Solo disponible en el vocabulario del sistema analizado |
| `review` | No se puede clasificar sin más contexto — pendiente de curación manual | No publicar hasta resolver |

**Herramienta de clasificación rápida**: si el término aparece con frecuencia en los SPs/clases de múltiples dominios del sistema, es `enterprise`. Si solo aparece en un dominio o es un nombre de tabla/SP, es `system`.

---

## 6. Motor de extracción — Segmentación greedy longest-match

El motor descompone cada identificador en tokens conocidos usando **coincidencia más larga primero**:

```
1. Dividir por "_" (underscore) → partes
2. Para cada parte: buscar el token más largo conocido desde la posición actual
3. Si ningún token conocido matchea: capturar el fragmento como "desconocido" → candidato a nuevo término
4. Componer el objetivo en lenguaje natural: ACCION + ENTIDAD + (MODIF) + [REG]
```

**Ejemplo — Java/Spring:**
```
msapy-d-domain-codi-payment
  → [msa][py][-d-][codi][payment]
  → PREFIJO:msa · PREFIJO:py(pagos) · CAPA:d(dominio) · REG:CoDi · ACCION:payment(pago)
  → "Microservicio de dominio — pago CoDi"
```

**Ejemplo — SP Informix:**
```
sp_consulta_saldos_general
  → [sp][consulta][saldos][general]
  → PREFIJO:sp · ACCION:consulta · ENTIDAD:saldos · MODIF:general
  → "Consulta saldos (general)"
```

**Regla de fragmento desconocido**: todo fragmento que no matchea ningún token conocido es un **candidato a vocabulario nuevo** — se registra en la worklist. Si aparece en ≥3 identificadores distintos, se incorpora al diccionario con estado `inf`.

---

## 7. Regla crítica — Validación de prefijos húngaros (legacy)

> **En sistemas legacy (Informix SPL, COBOL, AS/400), el significado de un prefijo de variable NUNCA se asume: se valida contra la declaración de tipo en el código.**

Para Informix: validar contra `DEFINE <var> <TIPO>;`
Para Java: validar contra la declaración del campo (`private String`, `private BigDecimal`, `private Boolean`)

El tipo declarado es doble información:
1. Resuelve la ambigüedad del prefijo
2. Es señal de riesgo: `MONEY/BigDecimal` → riesgo de redondeo; `CHAR(1)` con dominio {S/N, 0/1} → bandera de estado

**Esta regla no aplica a Java moderno** — los nombres de variables en Java son palabras completas, no húngaras. Sí aplica al mapeo de parámetros de SPs que se llaman desde Java.

---

## 8. Adaptación para sistemas Java/Spring

Los sistemas Java aportan fuentes adicionales que Informix SPL no tiene:

| Fuente Java | Vocabulario que genera |
|-------------|----------------------|
| Nombres de MSAs (`msa{dom}-{capa}-{funcion}`) | Prefijos de dominio (`py`, `cm`, `dp`, `cr`, `lo`, `sr`) y capas (`b`, `d`, `p`, `o`) |
| Nombres de clases (`CoDiPaymentService`, `SpeiOrderRepository`) | Entidades y acciones del dominio |
| `@RequestMapping` / `@GetMapping` paths (`/api/pay/codi/intrabank`) | Capacidades expuestas — mapa de funcionalidad |
| Property keys (`constants.api.name.spMtu=bdicheq:sp_validacionmtu_bpi`) | Términos técnicos y sus valores reales |
| Javadoc / READMEs | Términos validados por el equipo (F4 — confirmar con F1-F3) |

**Diferencia clave con Informix**: en Java el vocabulario de negocio está en los nombres de **clases y métodos**, no en los nombres de SPs. Los SPs heredados son ventanas al vocabulario del sistema Informix subyacente.

---

## 9. Pipeline de ejecución

```
Paso 1 — MINE        Extraer identificadores de todas las fuentes F1-F4
Paso 2 — SEGMENT     Segmentar con greedy longest-match → tokens conocidos + fragmentos desconocidos
Paso 3 — CLASSIFY    Asignar categoría (PREFIJO/ACCION/ENTIDAD/MODIF/REG/AMBIGUO) y estado (conf/inf/gap)
Paso 4 — SCOPE       Clasificar scope (enterprise/system/review) por criterio de reutilización
Paso 5 — PUBLISH     Actualizar vocabulario-{sistema}.md · sincronizar al bank-brain.db (solo enterprise)
```

El pipeline se re-ejecuta en cada etapa de análisis del Gemelo Cognitivo — el vocabulario es vivo, no un artefacto de una sola vez.

---

## 10. Reglas de calidad del vocabulario

1. **Sin duplicados**: si el término ya existe con definición equivalente, consolidar; no crear sinónimos sueltos.
2. **Definición en español de negocio, no técnica**: `amortización` = "tabla de pagos programados del préstamo"; no "resultado del SP `sp_obtiene_tabla_amortizacion_pp`".
3. **Evidencia explícita**: todo término documenta su fuente (archivo, línea o constante donde se encontró).
4. **Cross-reference**: los términos que aparecen en múltiples sistemas se marcan con `informix_ref` o `cross_ref` para visibilizar la equivalencia.
5. **Polisemia documentada**: no resolver artificialmente la polisemia — documentar ambos contextos y escalar al SME.
6. **Actualización incremental**: cuando se descubre un nuevo término durante el análisis de otro DT (Almas, Journeys, Reglas), se incorpora al vocabulario en la misma sesión.

---

## 11. Worklist de SME — cuándo escalar

Escalar al **SME del dominio** (Industry Banking o DBA IBM Informix) cuando:
- Un término tiene estado `gap` y aparece en flujos críticos (pagos, crédito)
- Un prefijo húngaro no puede resolverse desde el tipo declarado
- Un término AMBIGUO afecta la semántica de una regla de negocio documentada

Formato de worklist: tabla en `dt/dt-vocabulario/sme-worklist-{sistema}.md` con columnas: `term | contexto | pregunta | dominio | prioridad`.

---

*v1.0.0 · 2026-08-14 · BanCoppel AM · Extraída de implementación de referencia Informix SPL (sp_vocab.py + DT-Vocabulario v1.4.0) · Adaptada para sistemas Java/Spring*
