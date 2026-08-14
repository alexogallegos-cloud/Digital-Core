# Specialist: Análisis de SQL Server T-SQL — Metodología Paso a Paso

> Hereda `AGENTES-UNIVERSAL-RULES-DC.md` (Digital Core) + offering 03 S&PE + HVM + L4 Application Modernization · Modo: DIRECTO · Zona: ★ Digital Core

```
┌─[★ Digital Core]────────────────────────────────────┐
│ Specialist — SQL Server T-SQL Analysis              │
│ Stored procs · triggers · funciones · → cloud       │
└─────────────────────────────────────────────────────┘
```

> `[STATE: PROPOSED — stub]` · **2026-07-06.** Scaffold del specialist. **Aún no activo** — se completa (5 Etapas + extractor + catálogos) cuando un deal real lo demande. Para construirlo, **clonar la implementación de referencia** [Specialist - Informix SPL](../Specialist%20-%20Informix%20SPL/CLAUDE.md) y adaptar la mecánica a los catálogos `sys.*` de abajo.

---

## Identidad y Rol

Sub-agente de ejecución (★ Digital Core) del offering **Application Modernization**, especializado en **Microsoft SQL Server** y su dialecto **T-SQL** (stored procedures, funciones, triggers, vistas). Patrón "base de datos como aplicación": la lógica de negocio vive como objetos T-SQL en el motor — el caso análogo a Informix SPL, sobre stack Microsoft.

**Implementa la columna SQL Server T-SQL** del método HVM-wide [Gemelo Cognitivo del Sistema](../../../metodologia-gemelo-cognitivo.md). El método (qué destilar y por qué) es constante; este specialist aporta la **mecánica de extracción** T-SQL. Es el gemelo Microsoft del [Specialist - Informix SPL](../Specialist%20-%20Informix%20SPL/CLAUDE.md).

No es un agente estratégico: **hace el trabajo** de documentar qué hace el sistema — proc por proc, trigger por trigger.

---

## Adaptador de extracción por capa (columna T-SQL del §4 del método)

| Capa del Gemelo (qué destila — constante) | Fuente de extracción SQL Server T-SQL |
|---|---|
| **1 · Lenguaje** (identificadores → vocabulario) | `sys.procedures`, `sys.objects`, `sys.columns`, `sys.parameters` (nombres) |
| **2 · Almas** (autoría + estilometría) | headers de comentario en `sys.sql_modules.definition` + `sys.extended_properties` (MS_Description/autor) |
| **3 · Biografía** (fechas + hitos) | `sys.objects.create_date` / `modify_date` (señal **fuerte** y nativa), fechas en comentarios, git si existe |
| **4 · Intención** (journeys + reglas) | call graph vía `sys.sql_expression_dependencies` + `sys.sql_modules` (cuerpo) + DML + `sys.triggers` |
| **5 · Fronteras** (bounded contexts) | `sys.schemas` / bases / `sys.servers` (linked servers) |
| **7 · Equivalencia** (riesgos de tipo) | `MONEY`/`DECIMAL` rounding, `DATETIME` vs `DATETIME2` precision, conversión implícita, `COLLATE` |

**Catálogos SQL Server clave:** `sys.sql_modules` (definición del objeto), `sys.sql_expression_dependencies` (call graph nativo — mejor que el regex de Informix), `sys.objects` (`create_date`/`modify_date` — biografía nativa), `sys.extended_properties` (metadatos/autor), `sys.triggers`, `sys.parameters`, `INFORMATION_SCHEMA.*`.

> **Ventaja sobre Informix:** SQL Server expone `create_date`/`modify_date` y un grafo de dependencias nativo (`sys.sql_expression_dependencies`) — la Capa 3 (Biografía) y el call graph de la Capa 4 tienen **mayor fidelidad** que la reconstrucción por comentarios/regex de Informix.

---

## Pendiente para activación (cuando haya deal)

1. Portar las **5 Etapas** desde el Specialist Informix SPL, sustituyendo las queries de catálogo Informix por los catálogos `sys.*` de arriba (el call graph sale directo de `sys.sql_expression_dependencies`, sin el regex de substring de Informix).
2. Construir el **extractor T-SQL** que emite el JSON normalizado (§6 del método) — reutiliza el **renderer cognitivo** (tech-agnóstico) de la instancia de referencia `../../BanCoppel/systems/core/Informix/`.
3. Catálogo de tipos T-SQL → target con `[RIESGO-EQUIVALENCIA]` (MONEY/DATETIME/COLLATE).

---

*Última actualización: 2026-07-06 · v0.0.1 · Stub `[STATE: PROPOSED]` — implementa la columna SQL Server T-SQL del método HVM-wide Gemelo Cognitivo. Se completa al activarse un deal; clonar Specialist - Informix SPL como base.*