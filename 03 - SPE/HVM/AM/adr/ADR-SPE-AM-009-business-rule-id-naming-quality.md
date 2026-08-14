# ADR-SPE-AM-009 — Esquema de IDs y Calidad de Nombres en Reglas de Negocio Extraídas

**Estado**: Aceptado  
**Fecha**: 2026-08-14  
**Aplica a**: Todos los proyectos de Application Modernization con extracción de reglas de negocio desde código legacy (Informix SPL, COBOL, PL/SQL, ABAP, T-SQL)  
**Origen**: Lección aprendida BanCoppel — Informix SPL · 11,571 reglas · 49 bases de datos  

---

## Contexto

Durante la extracción de reglas de negocio del core bancario de BanCoppel (Informix SPL, 49 BDs, 10,144 SPs) se identificaron dos problemas sistemáticos que degradan la utilidad del catálogo de reglas para el proceso de modernización:

**Problema 1 — IDs ilegibles**: El esquema inicial usó secuenciales (`BR-V2-0001`) o hashes criptográficos (`BRB-unk-1c4c46-12`). Ambos son opacos: no rastrean al artefacto fuente, no comunican dominio ni SP de origen, y generan 222+ referencias en cascada que hacen el rename posterior extremadamente costoso.

**Problema 2 — Nombres que replican la implementación**: Los business names generados describían la expresión técnica en lugar del concepto de negocio. "Abono vencido por unidad precal: iAbonoVencidototal = iTotalVencido / iAbonoTotal" repite lo que ya está en la columna Expresión. Un arquitecto de negocio o un QA no puede usar ese nombre para validar equivalencia funcional en el sistema target.

---

## Decisión

### D1 — Esquema canónico de IDs de reglas de negocio

El formato de ID para reglas extraídas de código legacy es:

```
{PREFIX}-{db}-{sp_short}-{line}
```

| Campo | Definición | Ejemplo |
|-------|-----------|---------|
| `PREFIX` | Tipo de regla: `BRA` (Grupo A, lógica de negocio principal), `BRB` (Grupo B, validaciones estructurales) | `BRA`, `BRB` |
| `db` | Nombre de la base de datos tal como aparece en el sistema fuente | `bdisac`, `bdmis`, `bdcre` |
| `sp_short` | Nombre del SP sin prefijo `sp_`, máximo 14 caracteres | `actualizavigen`, `bcpl_acumpsmes` |
| `line` | Número de línea en el archivo fuente | `42`, `134` |

**Ejemplo**: `BRA-bdisac-actualizavigen-42`, `BRB-bdmis-bcpl_acumpsmes-34`

**Reglas adicionales**:
- Nunca usar el número de versión del pipeline de extracción en el ID (`V2`, `V3`). La versión va en el `rule_enrichment_log`, no en el ID.
- Nunca usar hashes criptográficos (SHA, MD5, etc.) en el ID. Un ID debe ser legible por humanos.
- Si hay colisión (mismo db+sp_short+line en SPs diferentes), agregar sufijo `-2`, `-3`.
- Nunca usar `unk` como db. Si el campo db es vacío en la fuente, investigar antes de continuar.

**Por qué importa la estabilidad del ID**: El ID es la clave primaria que une reglas con flujos de proceso, mapas de capacidades, casos de prueba, ADRs y la risk register de migración. Un rename posterior en un proyecto real puede afectar 200+ archivos y ~23,000 referencias (caso BanCoppel). Establecer el esquema correcto en la primera extracción es parte de la DoR del pipeline.

---

### D2 — Estándar de calidad para business names

El business name de una regla de negocio describe el **concepto funcional** que la regla encarna, no su implementación técnica.

#### Dos capas de enriquecimiento requeridas

**Capa 1 — Sintáctica** (automatizable con swarm, confianza ~0.75):
- Deriva el nombre del contexto del SP (`sps.biz`), el patrón de la condición y el vocabulario del proyecto.
- Suficiente para reglas de validación de campo, control de flujo y manejo de excepciones.
- El nombre sigue la fórmula: `[verbo de proceso] de [sujeto de negocio]: [condición en lenguaje natural]`

**Capa 2 — Semántica** (requiere conocimiento de dominio, confianza ~0.90+):
- Deriva el nombre del significado del indicador o métrica en el contexto del proceso de negocio y la regulación aplicable.
- Obligatoria para reglas tipo `FÓRMULA` y `UMBRAL` donde el resultado no es una validación sino un cálculo con significado regulatorio o de negocio.
- El nombre describe **qué mide o controla la regla** y **por qué existe**, no cómo se calcula.

#### Criterios de calidad de un business name

| Criterio | Correcto | Incorrecto |
|----------|----------|------------|
| No replica la expresión | "Tasa de mora por unidad en precalificación crediticia" | "iAbonoVencidototal = iTotalVencido / iAbonoTotal" |
| No duplica la columna Expresión | "Validación de presencia de cuenta origen en SPEI" | "pcuenta IS NOT NULL" |
| Usa vocabulario de negocio del dominio | "Período de corte de cartera vencida" | "fecha_corte mayor a current" |
| Refiere al proceso o capacidad que gobierna | "Control de autorización en canal corresponsal" | "validar accion corresponsal" |
| Incluye contexto regulatorio cuando aplica | "Clasificación CNBV de cartera emproblemada — criterio A" | "criterio clasificacion = A" |

#### Fuentes de conocimiento para Capa 2

Para cada sistema legacy en modernización, el pipeline de enriquecimiento semántico debe consumir:

1. **Vocabulario propio del sistema** (`terms` table en brain.db) — construido en Etapa 1 del GemCog
2. **Knowledge base del dominio** — KB del SME Industry correspondiente (Banking, Insurance, etc.)
3. **Marco regulatorio aplicable** — CNBV Circular Única de Bancos, Anexos 33-36 (cartera), DORA, IFRS 17, etc.
4. **Contexto del SP** — propósito del stored procedure (`sps.biz`) como ancla semántica

Sin estas cuatro fuentes, los names generados serán sintácticos en el mejor caso, y ruido en el peor.

---

### D3 — brain.db como única fuente de verdad para el portal de reglas

Toda corrección de nombres, IDs o metadatos se aplica **primero en brain.db**, nunca directamente en el portal JSON o el HTML. El script `rebuild_from_brain.py` (o su equivalente por sistema) regenera el portal completo desde brain.db.

Corolario: el pipeline de extracción no termina cuando el código está parseado — termina cuando `brain.db` tiene IDs estables, business names de Capa 2 validados, y el portal refleja esa calidad.

---

### D4 — Auditoría de referencias antes de cualquier rename masivo

Antes de renombrar un esquema de IDs ya en producción (portal vivo, documentos entregados), ejecutar:

```bash
grep -r "OLD-PATTERN" --include="*.json" --include="*.html" \
     --include="*.md" --include="*.py" -l | wc -l
```

Si el resultado supera 50 archivos, el rename requiere un script de migración y un plan de rollout, no un sed en línea. En BanCoppel, renombrar `BR-V2-*` afectaría 222 archivos con ~23,000 ocurrencias — costo de migración desproporcionado al valor. En ese caso, la deuda se acepta y el esquema correcto se aplica desde cero en sistemas nuevos.

---

## Alternativas Consideradas

| Alternativa | Razón de rechazo |
|-------------|-----------------|
| IDs secuenciales (`BR-0001`) | No traza al artefacto fuente. Un `BR-0001` en sistema A y otro en sistema B son indistinguibles. |
| IDs con hash (`BRB-unk-1c4c46`) | Ilegibles. El `unk` revela un bug en la extracción (campo db no resuelto). |
| IDs con versión de pipeline (`BR-V2-`) | La versión del extractor no es un atributo del negocio. Rota con cada refactor del pipeline. |
| Nombres automáticos solo con contexto del SP | Insuficiente para FÓRMULA/UMBRAL. Produce nombres que replican la expresión algebraica. |

---

## Consecuencias

**Positivo**:
- IDs trazables al artefacto fuente sin necesidad de búsqueda en diccionarios.
- Business names utilizables directamente para definir casos de prueba de equivalencia funcional en el sistema target.
- Flujos de proceso, capacity maps y risk registers referencian reglas con IDs estables y legibles.
- El estándar es replicable en Banamex S500/S151, Gentera SAP ABAP, y cualquier sistema futuro.

**Negativo / Trade-off**:
- Los IDs son más largos que los secuenciales (`BRA-bdisac-actualizavigen-42` vs `BR-0001`). Aceptado: legibilidad supera brevedad en artefactos de análisis.
- La Capa 2 de enriquecimiento requiere invocación explícita del SME de dominio. No es automatizable sin conocimiento del sector.

---

## Referencias

- GemCog — Metodología de extracción BanCoppel: `Informix/knowledge_base/reglas-estadisticas.md`
- Swarm K (CÓDIGO_RETORNO): `Informix/digital-brain/swarm_k_enrichment.py`  
- Swarm L (Grupo B IDs): `Informix/digital-brain/swarm_l_grupob.py`
- Fix IDs legibles: `Informix/digital-brain/fix_brb_ids.py`
- Portal rebuild canónico: `Informix/digital-brain/rebuild_from_brain.py`
- SME Industry Banking: `SME/Industry/Industry Banking/`
- SME Industry Banking Accounting (CNBV): `SME/Industry/Industry Banking Accounting/`
