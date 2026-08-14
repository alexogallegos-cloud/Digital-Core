# Propuesta — Schema Canónico de Regla de Negocio (GemCog)
**Fecha:** 2026-07-24 · **Autor:** Legacy Validation Lead · **Base:** `Analisis_MANIFEST_GemCog.docx` (23-Jul) + formatos reales de `rules-catalog/` + lecciones de la sesión de validación 24-Jul.
**Objetivo:** cerrar el gap identificado en el análisis ("no hay schema declarado para la regla de negocio") con un template único, defendible ante CIO y auditable, que unifique las 3 variantes heterogéneas del catálogo actual.

---

## 1. Diagnóstico de partida (por qué hace falta)

**Del análisis del MANIFEST:** el manifiesto es sólido pero **no declara el formato de la regla**; la consistencia entre los 33 archivos depende del autor. Gaps concretos:
- Sin schema de regla (campos obligatorios, condición/consecuencia, granularidad) → riesgo de heterogeneidad.
- Sin **clasificación de tipo de regla** (SBVR: restricción / derivación / cálculo / habilitación).
- Sin **versionado ni fecha de validación SME** por regla → sin auditoría de qué se validó y cuándo (crítico en sistema regulado).
- ~730 reglas sin tarea asignada → trazabilidad rota.

**De los formatos reales observados** (heterogeneidad confirmada):
| Variante | Dónde | Campos de programa | Traza de código |
|---|---|---|---|
| A (base) | `rules-s151.md` | `Programa(s)` | bloque "Traza de código" con párrafo + línea ~aprox |
| B (simple) | `rules-s500.md` 056-078 | `Programa` (singular) | `Fórmula` + `Estado` |
| C (enriquecida) | `rules-s500-*p103fraude/p310/p010`… | `Programa(s) fuente` (a veces copybook + líneas) | `Fórmula/pseudocódigo` |
| HTML | `validacion-flujos-*.html` | `prog` (a veces archivo/copybook, a veces con sufijo " S500") | `fer_traza` |

**Lecciones de la sesión 24-Jul (deben quedar en el schema):**
- La **evidencia debe ser `archivo:línea` exacta** y NO citarse del artefacto *expandido* cuando la lógica viene de copybooks compartidos (da ubicaciones engañosas). Ver caso RN-S500-162/163.
- **`programa` = el/los ejecutor(es)**, no el copybook. Un copybook PROCEDURE compartido va en un campo de *fuente* + la lista de programas que hacen `COPY` (ej. `S500/INC/PRO/CAN` → P010/P130/P168).
- El **título/etiqueta puede mentir**: la verdad es el `desc`/código (caso títulos 208/209/217 intercambiados).
- **Fuente de la verdad:** oráculo GemCog (vocab) → código. La evidencia ancla contra código.

---

## 2. Principios del schema

1. **La descripción es el atributo principal, en lenguaje de negocio** — qué hace la regla y por qué importa, sin jerga COBOL. La mecánica técnica va en un sub-bloque aparte (`formula`/`traza`), no mezclada.
2. **Separación SBVR:** distinguir la *definición de negocio* (qué es) de la *regla operativa* (qué se hace), y clasificar el **tipo de regla**.
3. **Toda regla ancla a evidencia** `archivo:línea` verificable contra el código fuente (regla del proyecto). Sin ancla → estado `INFERIDO` o `PENDIENTE`.
4. **Ciclo de vida y auditoría:** versión + veredicto + quién validó (SME/Lead) + fecha. Obligatorio en sistema regulado.
5. **Trazabilidad end-to-end:** regla ↔ vocabulario ↔ tarea / flujo de actividades ↔ capacidad BIAN.
6. **Programa = ejecutor**; copybook/archivo fuente = campo separado.

---

## 3. Schema propuesto (campos)

Obligatoriedad: **M** = obligatorio · **R** = recomendado · **O** = opcional.

### A. Identidad y ciclo de vida
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| `id` | M | Identificador único `RN-S{sys}-{nnn}` | `RN-S151-034` |
| `nombre` | M | Título corto de negocio (no el ID, no jerga) | "SPEI en pesos sin dimensión de banco" |
| `version` | M | Versión de la regla (semver simple o entero) | `v2` |
| `estado_ciclo` | M | Borrador / En validación / Validado / Obsoleto | `Validado` |
| `fecha_actualizacion` | M | Última modificación (ISO) | `2026-07-24` |

### B. Contenido de negocio (SBVR — núcleo)
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| **`descripcion`** | **M** | **Atributo principal, en LENGUAJE DE NEGOCIO**: qué hace la regla y por qué importa. Sin código. | "En transferencias SPEI en pesos, el asiento contable no se asocia a un banco específico, para consolidar la posición del sistema de pagos sin fragmentarla por institución." |
| `tipo_regla` | M | Clasificación SBVR: **Restricción · Derivación · Cálculo · Habilitación/Autorización · Clasificación/Mapeo** | `Derivación` |
| `condicion` | R | Disparador / cuándo aplica (lenguaje de negocio) | "Cuando el movimiento es SPEI (S264) y la moneda es pesos (MXN)." |
| `consecuencia` | R | Acción / resultado | "El campo banco del asiento se pone en cero." |
| `excepciones` | O | Casos donde no aplica o cambia | "En divisas sí se usa el banco real de la contraparte." |

**Definición de los valores de `tipo_regla` (SBVR):**
- **Restricción / Obligación** — limita, obliga o prohíbe un estado o acción; expresa qué *debe* o *no debe* ocurrir. Ej.: una cuenta con bloqueo no puede operar; el disponible no puede exceder el saldo menos lo comprometido.
- **Derivación** — infiere un hecho nuevo a partir de otros ya conocidos (asignación condicional), sin fórmula aritmética. Ej.: SPEI en pesos → banco = 0; instrumento 10 → sector CNBV 31.
- **Cálculo** — computa un valor numérico mediante una fórmula. Ej.: rendimiento CPE, ISR retenido, saldo disponible del cajero, devoluciones mensuales.
- **Habilitación / Autorización** — permite o niega una acción según condiciones, facultades o estado. Ej.: facultades 1/2/3 autorizan operaciones de sucursal; fail-open aprueba si el antifraude no responde.
- **Clasificación / Mapeo** — asigna una categoría, código o cuenta a una entidad según reglas de correspondencia. Ej.: tipo de persona → régimen de retención ISR; CVETRAN → cuenta contable vía ESQCON.

### C. Clasificación y contexto
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| `sistema` | M | S500 / S151 | `S151` |
| `capacidad_bian` | R | Capacidad BIAN v12 (del `bian-mapping`) — **fuente autoritativa del flujo de actividades** | `6.1.5 Interest & Fees` |
| `flujo_actividades` | R | Flujo de actividades (journey) funcional, derivado de la capacidad — NO un bucket por defecto | `GL / Contabilidad SPEI` |
| `tipo_tecnico` | O | Etiqueta técnica/riesgo (multi-valor): `HARDCODE-SOSPECHOSO`, `REGLA-CNBV`, `LÓGICA-CONTABLE`… | `[LÓGICA-CONTABLE]` |
| `regulador` | R | Regulador aplicable | `Banxico (SPEI)` |
| `base_regulatoria` | O | Norma/artículo específico | `—` |

### D. Evidencia y trazabilidad al código (⭐ no omitir)
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| `programa_ejecutor` | M | Programa(s) **que ejecuta(n)** la regla en runtime (no el copybook) | `P109` |
| **`evidencia_codigo`** | **M** | **Referencia(s) `archivo:línea` EXACTAS de la fuente sin expandir**, con párrafo/sección | `COBOL_P109.txt:10748-10753 (párr. 21115-VERIFICA-SISTEMA)` |
| `copybook_fuente` | **M si aplica** | **Cuando el código se extrajo de un COPY (copybook): indicar SIEMPRE (a) el copybook de origen con su `archivo:línea` y (b) el/los programa(s) que lo LLAMAN (hacen `COPY`).** Un copybook no ejecuta solo; hay que saber desde qué programa(s) corre. | `S500/INC/PRO/CAN` (líneas 3399-3408) · llamado por: P010, P130, P168 |
| `campos_cobol` | R | Campos/estructuras COBOL involucrados (para forward eng.) | `A00-R01-MONEDA`, `RMS-BANCO` |
| `vocab_ref` | R | Términos del vocabulario controlado (Capa 1) que usa la regla | `SPEI`, `MOVIMIENTO`, `BANCO` |
| `sistemas_downstream` | O | Sistemas/archivos que reciben el resultado | `S151 (asiento GL)` |
| `pseudocodigo` | O | Fragmento de pseudocódigo/fórmula (bloque técnico, NO en la descripción) | `IF SISTEMA=264 AND MONEDA=1 → MOVE ZEROS TO RMS-BANCO` |

### E. Validación y gobernanza (HITL — cierra el gap de auditoría)
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| `veredicto` | M | Vocabulario cerrado: **VALIDADO · DRIFT · RECHAZADO · INFERIDO · PENDIENTE SME · DUDOSO** | `VALIDADO` |
| `confianza` | M | alta / media / baja | `alta` |
| `validado_por_lead` | R | Legacy Validation Lead + fecha | `MLC · 2026-07-24` |
| `validado_por_sme` | R | SME de negocio + fecha (auditoría) | `Cristian Dueñas · pendiente` |
| `nota_lead` | O | Nota de validación del Lead (incluye la referencia de código) | "Confirmado contra fuente; ver evidencia." |
| `nota_sme` | O | Respuesta del SME en sesión | — |

### F. Trazabilidad de proceso (cierra el gap de ~730 reglas huérfanas)
| Campo | M/R/O | Descripción | Ejemplo |
|---|---|---|---|
| `tarea_flujo` | R | Tarea del mapa de flujos de actividades (Capa 4) a la que pertenece | `T.x — cierre GL nocturno` |
| `br_relacionada` | O | Correspondencia con el HITL validation set | `—` |
| `reglas_relacionadas` | O | IDs de reglas ligadas / dependientes | `RN-S151-037` |

---

## 4. Ejemplo completo (RN-S151-034 con el schema)

```yaml
id: RN-S151-034
nombre: "SPEI en pesos sin dimensión de banco"
version: v2
estado_ciclo: Validado
fecha_actualizacion: 2026-07-24
# --- Negocio (SBVR) ---
descripcion: >
  En las transferencias SPEI en pesos, el asiento contable no se asocia a un
  banco específico; el campo banco se deja en cero para consolidar la posición
  del sistema de pagos ante Banxico sin fragmentarla por institución. En divisas
  sí se registra el banco real de la contraparte.
tipo_regla: Derivación
condicion: "Movimiento SPEI (sistema S264) con moneda = pesos (MXN)."
consecuencia: "El banco del registro contable se pone en ZEROS."
excepciones: "En divisas (moneda ≠ 1) se usa el banco real (A00-R01-BCOS)."
# --- Clasificación ---
sistema: S151
capacidad_bian: "6.x GL / Payments"
flujo_actividades: "GL — Contabilidad SPEI"
tipo_tecnico: ["LÓGICA-CONTABLE"]
regulador: "Banxico (SPEI — liquidación interbancaria)"
# --- Evidencia (⭐) ---
programa_ejecutor: P109
evidencia_codigo: "COBOL_P109.txt:10748-10753 (MOVE ZEROS TO RMS-BANCO en :10750; párr. 21115-VERIFICA-SISTEMA)"
copybook_fuente: null
campos_cobol: [A00-R01-MONEDA, RMS-BANCO, A00-R01-BCOS]
vocab_ref: [SPEI, MOVIMIENTO, BANCO]
sistemas_downstream: ["reportes Banxico SPEI"]
# --- Gobernanza HITL ---
veredicto: VALIDADO
confianza: alta
validado_por_lead: "MLC · 2026-07-24"
validado_por_sme: "Cristian Dueñas · pendiente confirmación de requerimiento Banxico"
# --- Trazabilidad de proceso ---
tarea_flujo: "Cierre GL — posteo de movimientos SPEI"
br_relacionada: "—"
```

---

## 5. Cómo cada gap del análisis queda cerrado

| Gap del análisis (23-Jul) | Campo(s) que lo cierra |
|---|---|
| Sin schema declarado | Este template (secciones A–F) |
| Sin clasificación de tipo de regla (SBVR) | `tipo_regla` (Restricción/Derivación/Cálculo/Habilitación/Clasificación) |
| Sin versionado ni fecha de validación SME | `version`, `estado_ciclo`, `validado_por_sme` (+fecha), `validado_por_lead` |
| Condición/consecuencia no separadas | `condicion` + `consecuencia` (además de `descripcion`) |
| ~730 reglas sin tarea | `tarea_flujo` obligatorio-recomendado → métrica de completitud |
| (Sesión 24-Jul) Evidencia engañosa del expandido | `evidencia_codigo` = fuente sin expandir; `copybook_fuente` para copybooks compartidos |
| (Sesión) programa vs copybook | `programa_ejecutor` ≠ `copybook_fuente` |

---

## 6. Convenciones de llenado (obligatorias)

1. **`descripcion` en lenguaje de negocio** — nada de nombres de párrafo/campos COBOL ahí; eso va en `pseudocodigo`/`campos_cobol`/`evidencia_codigo`.
2. **`evidencia_codigo` siempre `archivo:línea`** de la fuente **sin expandir** (`Fuentes_Extraidas/` S500, o los `.txt` de S151).
3. **Cuando el código proviene de un COPY (copybook), es OBLIGATORIO indicar las dos cosas:** (a) el **copybook** de donde se extrajo (con `archivo:línea`) y (b) el/los **programa(s) que lo llaman** (hacen `COPY`) → van en `copybook_fuente` (el copybook) y en `programa_ejecutor` (los que lo invocan). Un copybook no se ejecuta solo: sin el programa que lo llama, la regla no es trazable a un punto de ejecución. Verificar los includers en las fuentes **sin expandir** (`COPY "S500/INC/PRO/..."`), no en el artefacto expandido.
4. **`programa_ejecutor`** = el/los programa(s) que corren la regla; nunca un copybook ni el nombre de archivo del volcado.
5. **`veredicto`** solo del vocabulario cerrado de 6 estados; sin ancla de código el máximo es `INFERIDO`.
6. **`flujo_actividades`/`capacidad_bian`** derivados del `bian-mapping-*`, no un bucket por defecto (evitar el problema "todo Cuenta Global").
7. Toda edición incrementa `version` y actualiza `fecha_actualizacion`.

---

## 7. Adopción sugerida (no bloqueante ahora)

1. Ratificar este schema como parte del **Manifiesto del Validador del GemCog** (ya encolado).
2. Migrar las 3 variantes del `rules-catalog` a este template (empezar por las reglas ya validadas contra fuente en la sesión 24-Jul, que ya tienen `evidencia_codigo`).
3. Reflejar los campos nuevos (`version`, `veredicto`, `validado_por_sme`+fecha, `evidencia_codigo`) en los HTML de validación.
4. Medir completitud: % de reglas con `evidencia_codigo`, con `tarea_flujo`, y con `validado_por_sme`.
