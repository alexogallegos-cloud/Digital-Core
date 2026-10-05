# Capa 4 — Intención: Las Reglas de Negocio

> Capa 4 del Gemelo Cognitivo del Sistema. Metodología Enterprise Brain · Digital Core.

## Objetivo

Extraer las decisiones de negocio del sistema — qué valida, qué calcula, qué transforma, bajo qué condiciones y con qué consecuencias — para que el equipo de modernización sepa exactamente qué comportamiento debe preservar y qué riesgo de equivalencia asume si no lo preserva.

## Pipeline: extracción, enriquecimiento y carga

> Bronze, Silver y Gold designan la calidad del conocimiento (Regla B37), no estas etapas. Ver al final de esta sección cómo queda cada campo.

### Etapa 1 — Extracción cruda

El extractor lee el código fuente completo de cada SP (no fragmentos) y produce un JSON de reglas candidatas. Cada regla tiene:

| Campo | Descripción |
|-------|-------------|
| `id` | Identificador canónico: `{PREFIX}-{db}-{sp_short}-{line}` |
| `tipo` | FÓRMULA, VALIDACIÓN, UMBRAL o TRANSFORMACIÓN |
| `fragmento` | Fragmento de código que originó la regla |
| `source_file` | Ruta relativa al archivo fuente |
| `component_id` | ID canónico del SP (`db:sp_name`) |

En la extracción no se filtra. Toda señal de lógica de negocio entra, incluyendo construcciones de infraestructura; se clasificarán en el enriquecimiento.

### Etapa 2 — Enriquecimiento

| Campo | Fuente | Descripción |
|-------------|--------|-------------|
| `clase` | Clasificador automático | NEGOCIO, INFRAESTRUCTURA, ENSAMBLAJE, PRESENTACION |
| `reg` | Triaje regulatorio | CNBV, Banxico, CONSAR, PLD, ninguna — o lista combinada |
| `riesgo` | Detector de patrones | MONEY, DIV, ROUND, FX, UDI — riesgo de equivalencia financiera |
| `business_name` | Síntesis LLM source-read (ADR-EB-004) | Nombre de negocio — inferido del SP completo, nunca transcrito |

### Etapa 3 — Carga a brain.db

Reglas con todos los campos enriquecidos, cargadas en la tabla `rules` con FTS5 para búsqueda fulltext.

### Nivel de calidad de cada campo (Regla B37)

La carga no convierte nada en gold. Cada campo conserva el nivel que su fuente sostiene:

| Campo | Nivel al cargar | Por qué |
|-------|----------------|---------|
| `fragmento`, `linea`, `source_file`, `condicion` | Gold por origen | Es el código productivo, con ubicación exacta y versión del fuente |
| `tipo`, `clase`, `riesgo` | Silver | Salen de un clasificador; son interpretación del código |
| `business_name` | Silver | Síntesis LLM (ADR-EB-004); sube a gold cuando el SME del dominio lo valida |
| `reg` | Silver | Triaje regulatorio; sube a gold cuando el Industry SME confirma la obligación contra el instrumento publicado |

Cada nivel se registra en `knowledge_lineage`, por campo, con la versión del SP. Si el SP cambia en un nuevo deploy, sus campos gold bajan a silver hasta reverificarse.

## Clasificación de naturaleza (campo `clase`)

| Clase | Qué es | Cuenta como regla de negocio real |
|-------|--------|-----------------------------------|
| NEGOCIO | Fórmulas financieras, validaciones de dominio, umbrales de negocio | SÍ |
| INFRAESTRUCTURA | Comandos shell, dbaccess, paths AIX, UNLOAD, echo, awk, gzip | NO — plumbing técnico |
| ENSAMBLAJE | Construcción de SQL dinámico para reportes con concatenación (`\|\|`) | NO — técnico |
| PRESENTACION | Formato de salida, padding, mensajes de interfaz de usuario | NO — UI |

**Regla ontológica**: el conteo de "reglas de negocio" del sistema = subconjunto NEGOCIO. Nunca reportar el total como si fueran todas de negocio.

**Señal clave `vsql`**: en SPL, la variable `vsql` (y variantes `cSql`, `cCmd`) frecuentemente contiene comandos de sistema operativo (`dbaccess`, `gzip`, `tar`, `UNLOAD TO`, `echo`, `awk`, `grep`). Este patrón marca `clase=INFRAESTRUCTURA`. El `business_name` debe describir el **propósito del proceso shell** (ej. "Exportar tabla de cartera vencida a archivo plano para reporte CNBV"), no una fórmula financiera.

## Síntesis del business_name (ADR-EB-004)

**El extractor emite `business_name = ""`**. El nombre se infiere leyendo el código fuente completo del SP, nunca se transcribe la fórmula ni el identificador.

**Método scatter-gather (canónico)**:

1. Exportar reglas con business_name débil/vacío a lotes de ~70-80 con su `source_file`.
2. Por lote: un agente Lee el SP completo (Read tool — nunca el fragmento), sintetiza el nombre desde el contexto completo, escribe JSON `{id: name}`.
3. Colectar todos los JSON, deduplicar, aplicar guardia anti-genérico.
4. Cargar en brain.db con `method='llm_synthesis_source_read'`.
5. Verificar con detector: 0 nombres vacíos, 0 genéricos, 0 tokens de código fuente.

**Gotchas documentados (lecciones de BanCoppel)**:

- Fragmentos truncados tienen errores FACTUALES: código 439 = crédito cancelado (no "error genérico"), `ctemoral` = persona moral, `cteppes` = PEP (Persona Expuesta Políticamente). Siempre leer el SP completo.
- `vsql` no es una fórmula financiera — es un comando shell. business_name describe el proceso, no la expresión.
- Prefijos de código (`bdiburo`, `sp_xxx`, `lincred`) no son nombres de negocio — son identificadores técnicos.

## Estructura en brain.db

```sql
CREATE TABLE rules (
    id TEXT PRIMARY KEY,           -- "{PREFIX}-{db}-{sp_short}-{line}"
    component_id TEXT NOT NULL,    -- "db:sp_name" (FK a components)
    tipo TEXT,                     -- FÓRMULA | VALIDACIÓN | UMBRAL | TRANSFORMACIÓN
    clase TEXT,                    -- NEGOCIO | INFRAESTRUCTURA | ENSAMBLAJE | PRESENTACION
    fragmento TEXT,                -- fragmento de código original
    business_name TEXT,            -- nombre de negocio sintetizado (LLM source-read)
    description TEXT,              -- descripción detallada (opcional)
    reg TEXT,                      -- regulación aplicable (JSON array o string)
    riesgo TEXT,                   -- MONEY | DIV | ROUND | FX | UDI (JSON array o NULL)
    source_file TEXT,              -- ruta al archivo fuente
    enrichment_method TEXT,        -- "llm_synthesis_source_read" | "heuristic" | etc.
    domain TEXT                    -- dominio de negocio
);
CREATE VIRTUAL TABLE rules_fts USING fts5(id, business_name, description, fragmento);
```

## Instancias de referencia

- **BanCoppel Informix**: 8,955 reglas totales (6,819 NEGOCIO 76%, 1,958 INFRAESTRUCTURA, 101 ENSAMBLAJE, 77 PRESENTACION). Pipeline de extracción, enriquecimiento y carga activo con `extract-rules.py` y `enrich-rules.py`.
- **Banamex GemCog S151**: 1,550 reglas extraídas con 3 capas de conocimiento (KB) y trazabilidad completa (build-traceability.py).
- **BanCoppel D17-D49**: 1,216 reglas vocab-anchored (797 FÓRMULA, 389 VALIDACIÓN, 30 UMBRAL) — reemplazaron 25,165 reglas crudas IF/THEN de la primera extracción, que eran ruido de control-flow técnico.
