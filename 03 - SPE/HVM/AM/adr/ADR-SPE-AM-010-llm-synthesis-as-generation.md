# ADR-SPE-AM-010 — Síntesis LLM como Generación Primaria del business_name

**Estado**: Aceptado  
**Fecha**: 2026-08-14  
**Aplica a**: Todos los proyectos de Application Modernization con extracción de reglas de negocio desde código legacy (Informix SPL, COBOL, PL/SQL, ABAP, T-SQL, y cualquier lenguaje procedural legacy)  
**Complementa**: ADR-SPE-AM-009 (estándar de calidad del business_name)  
**Origen**: Lección aprendida BanCoppel — detección de business names que eran fragmentos SQL literales (`"And num_vencidos_diaant in(1,2)"`) generados por el extractor de reglas en lugar de un nombre de negocio real

---

## Contexto

Durante el análisis del core bancario de BanCoppel (Informix SPL, 49 BDs, 11,571 reglas) se detectó un patrón de degradación sistemática: el extractor de reglas (script Python/regex) generaba un `business_name` inicial tomando literalmente fragmentos del código fuente (echo strings, condiciones SQL en raw, variables SPL con prefijo húngaro). Ese nombre inicial se tomaba como "suficiente" para reglas no-NEGOCIO, y el paso de síntesis LLM cubría solo las reglas NEGOCIO.

El resultado fue que reglas de clase INFRAESTRUCTURA, ENSAMBLAJE_REPORTE y PRESENTACION quedaron con nombres como:
- `"And num_vencidos_diaant in(1,2)"` — fragmento SQL del content de un `echo`
- `"Calcular vsql: bdiburo ÷ resplogifx"` — variable de shell command tratada como fórmula financiera
- `"cSql = '/usr/bin/echo SET IS...'"` — asignación de variable copiada como nombre

Estos nombres son inútiles para el arquitecto de negocio, el QA de equivalencia funcional, y la documentación de migración. El intento de corregirlos con passes adicionales de síntesis (parches) produce deuda acumulada y cobertura inconsistente.

---

## Decisión

### D1 — El extractor identifica, la síntesis LLM genera

La responsabilidad del extractor (script regex/heurística) se limita estrictamente a:

1. **Identificar** la existencia de la regla en el código fuente (línea, tipo de patrón, fragmento de código)
2. **Capturar** el código fuente crudo de la regla (`code`) y los metadatos estructurales (`tipo`, `sub_tipo`, `sp`, `db`, `clase`, `reg`, `riesgo`)
3. **Dejar `business_name = null`** (o cadena vacía `""`) — nunca intentar derivar un nombre directamente del código

El `business_name` es responsabilidad exclusiva de la síntesis LLM. No hay "nombre provisional" ni "nombre inicial": solo existe el nombre generado por LLM, o null.

### D2 — La síntesis LLM cubre TODAS las clases de reglas

La síntesis se aplica a **toda regla** independientemente de su `clase`:

| Clase | Fuentes para síntesis | Formato de business_name |
|-------|----------------------|--------------------------|
| `NEGOCIO` | código + comentarios SP + vocabulario del sistema + KB dominio + regulación | `[Decisión/Validación/Cálculo] de [concepto de negocio]: [condición en lenguaje natural]` |
| `INFRAESTRUCTURA` | código (tipo de operación shell) + propósito del SP + archivo/base de datos destino | `[Operación OS] [qué datos/archivos]: [propósito del proceso]` |
| `ENSAMBLAJE_REPORTE` | código (SQL dinámico) + propósito del SP + tablas involucradas | `[Qué reporte/consulta] se construye: [dimensiones o filtros clave]` |
| `PRESENTACION` | código (formato/padding) + propósito del SP + campo formateado | `[Formato/presentación] de [campo de negocio]: [condición o regla de formato]` |

**Ejemplos para INFRAESTRUCTURA:**

| Código fuente | business_name INCORRECTO | business_name CORRECTO |
|---------------|--------------------------|-------------------------|
| `cSql = 'echo "AND num_vencidos_diaant IN(1,2)" >> /respaldos/pp_caida_1_mora.sql'` | `"And num_vencidos_diaant in(1,2)"` | `"Segmentar cartera: añade filtro de 1–2 días vencidos al archivo de campaña de mora"` |
| `LET vsql = 'dbaccess bdiburo < /resplogifx/...'` | `"Calcular vsql: bdiburo ÷ resplogifx"` | `"Ejecutar script de conciliación de buró de crédito contra respaldo diario"` |
| `LET vsql = 'gzip -f /respaldos/saldo_' \|\| vfecha \|\| '.dat'` | `"vsql = gzip /respaldos/saldo_"` | `"Comprimir archivo de saldos del día para respaldo nocturno"` |

### D3 — La síntesis LLM es un paso obligatorio del pipeline, no una mejora opcional

El pipeline de extracción de reglas **no termina** hasta que cada regla tiene un `business_name` sintetizado por LLM. Esto es una precondición de entrega, no una mejora de calidad posterior.

```
extractor (regex/heurística)
  → reglas con code, tipo, clase, sp, db — business_name = null
        ↓
síntesis LLM (swarm de agentes)
  → lee: code + comentarios SP + vocabulario + KB dominio + regulación
  → genera: business_name de primera y única calidad
  → registra: rule_enrichment_log (provenance, confidence, swarm_id)
        ↓
quality gate: COUNT(*) WHERE business_name IS NULL = 0
        ↓
brain.db / portal listo para uso
```

### D4 — `rule_enrichment_log` es provenance, no log de parches

El `rule_enrichment_log` registra la **síntesis inicial** de cada regla (generación primaria), no correcciones de nombres malos pre-existentes. Cada entrada documenta qué swarm sintetizó la regla, con qué fuentes y con qué nivel de confianza.

Los campos relevantes:

| Campo | Significado |
|-------|-------------|
| `swarm` | ID del swarm de síntesis (ej. `swarm_negocio_v1`, `swarm_infra_v1`) |
| `method` | Siempre `'llm_synthesis'` — no `'regex_patch'`, no `'heuristic'` |
| `confidence` | 0.85–0.97 según clase y fuentes disponibles |
| `notes` | Fuentes usadas y contexto del SP |

### D5 — Señales de detección de clase INFRAESTRUCTURA en síntesis

Para que el agente de síntesis genere nombres correctos para reglas INFRAESTRUCTURA, debe reconocer estas señales antes de generar el nombre:

| Señal en `code` | Interpretación | Patrón de business_name |
|-----------------|----------------|--------------------------|
| `vsql`, `cSql`, `cCmd` con `echo "..."` | Construcción de SQL dinámico por concatenación shell | `"[Qué segmentación/filtro] se añade a [archivo/tabla]"` |
| `vsql` con `dbaccess [db] [script]` | Ejecución de script SQL vía OS | `"Ejecutar [proceso] sobre [base de datos]: [propósito]"` |
| `vsql` con `gzip`, `tar`, `UNLOAD TO` | Compresión / exportación de archivos | `"[Comprimir/Exportar] [qué datos] para [propósito]"` |
| `vsql` con `echo "AND/OR/WHERE"` | Fragmento WHERE para query dinámico | `"Segmentar [entidad]: [condición de negocio del filtro]"` |
| `cNombreArchivo`, `cPath` con `/respaldos/` o `/resplogifx/` | Ruta de archivo de respaldo o log | `"[Generar/Registrar] [qué] en [tipo de repositorio]"` |

**Regla crítica**: el `business_name` de una regla INFRAESTRUCTURA describe el **propósito del proceso**, nunca el comando técnico ni el contenido del string literal.

---

## Alternativas Consideradas

| Alternativa | Razón de rechazo |
|-------------|-----------------|
| Extractor genera nombre heurístico + LLM lo "mejora" | Produce parches acumulados. El nombre heurístico se cuela cuando la "mejora" no corre o falla silenciosamente. Genera inconsistencia de cobertura por clase. |
| Síntesis LLM solo para clase NEGOCIO | Las 2,136 reglas no-NEGOCIO (INFRAESTRUCTURA + ENSAMBLAJE + PRESENTACION) son parte del modelo del sistema AS-IS. El arquitecto de modernización necesita entender qué hace el plumbing, no solo la lógica de negocio. |
| Síntesis manual para reglas de clase INFRAESTRUCTURA | No escala a proyectos con miles de reglas. El swarm con contexto correcto produce calidad equivalente a la revisión manual para reglas de infraestructura. |
| Dejar `business_name = null` para no-NEGOCIO | Hace el portal incompleto y el catálogo inutilizable para auditoría regulatoria — INFRAESTRUCTURA incluye procesos de carga de reportes CNBV, compresión de respaldos requeridos por regulación, etc. |

---

## Consecuencias

**Positivo**:
- Cobertura 100% del catálogo de reglas — toda regla tiene nombre de negocio sintetizado, independientemente de su clase.
- No hay nombres provisionales ni "suficientemente buenos" que se quedan permanentes por inercia.
- El pipeline es predecible: extractor + síntesis LLM, siempre, para todos los sistemas AM.
- La síntesis de INFRAESTRUCTURA revela procesos operativos no documentados (cargas batch regulatorias, esquemas de respaldo, flujos de exportación a entidades externas) que el arquitecto de migración necesita mapear al sistema target.

**Negativo / Trade-off**:
- El tiempo de síntesis aumenta ~25% al cubrir todas las clases (no solo NEGOCIO). Mitigado con swarms paralelos por clase.
- Requiere prompt diferenciado por clase — el agente necesita contexto adicional para saber que `vsql = 'echo "AND..."'` es INFRAESTRUCTURA, no una fórmula financiera.

---

## Implementación — Orden canónico del pipeline de extracción + síntesis

```
1. Extractor identifica reglas → business_name = null en todos los registros
2. Swarm NEGOCIO     → sintetiza class=NEGOCIO     (prompt: código + vocabulario + KB dominio + regulación)
3. Swarm INFRA       → sintetiza class=INFRAESTRUCTURA (prompt: código + tipo de operación shell + propósito SP)
4. Swarm ENSAMBLAJE  → sintetiza class=ENSAMBLAJE_REPORTE (prompt: SQL dinámico + tablas + propósito SP)
5. Swarm PRESENTACION → sintetiza class=PRESENTACION (prompt: formato + campo + SP)
6. Quality gate: SELECT COUNT(*) FROM rules WHERE business_name IS NULL = 0
7. rebuild_from_brain.py → portal actualizado
```

Los swarms 2-5 pueden correr en paralelo si hay slots disponibles.

---

## Referencias

- ADR-SPE-AM-009: Esquema de IDs y calidad de nombres en reglas de negocio extraídas
- Lección aprendida BanCoppel: `BR-V2-3245` y `BR-V2-3242` — business names que eran fragmentos SQL raw (`"And num_vencidos_diaant in(1,2)"`) generados por el extractor sin síntesis LLM
- Lección aprendida BanCoppel: reglas `vsql` = comando shell con `business_name = "Calcular vsql: bdiburo ÷ resplogifx"` — swarm de síntesis excluía clase INFRAESTRUCTURA
- Specialist - Informix SPL: `AM/Fase 0 - Discover/Specialist - Informix SPL/CLAUDE.md`
- brain.db schema: `Informix/digital-brain/build-brain.py`
- rebuild canónico: `Informix/digital-brain/rebuild_from_brain.py`
