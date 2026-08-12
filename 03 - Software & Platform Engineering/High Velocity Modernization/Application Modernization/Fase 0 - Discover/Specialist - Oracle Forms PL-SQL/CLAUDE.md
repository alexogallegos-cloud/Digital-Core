# Specialist: Análisis de Oracle Forms + PL/SQL — Metodología Paso a Paso

> Hereda `AGENTES-UNIVERSAL-RULES-DC.md` (Digital Core) + offering 03 S&PE + HVM + L4 Application Modernization · Modo: DIRECTO · Zona: ★ Digital Core

```
┌─[★ Digital Core]────────────────────────────────────┐
│ Specialist — Oracle Forms + PL/SQL Analysis         │
│ Forms/Reports · PL/SQL packages · → cloud-native    │
└─────────────────────────────────────────────────────┘
```

> `[STATE: PROPOSED — stub]` · **2026-07-06.** Scaffold del specialist. **Aún no activo** — se completa (5 Etapas + extractor + catálogos) cuando un deal real lo demande. Para construirlo, **clonar la implementación de referencia** [Specialist - Informix SPL](../Specialist%20-%20Informix%20SPL/CLAUDE.md) (misma estructura de 5 Etapas + alineación al Gemelo) y adaptar la mecánica a los catálogos Oracle de abajo.

---

## Identidad y Rol

Sub-agente de ejecución (★ Digital Core) del offering **Application Modernization**, especializado en **Oracle Forms/Reports** (client-server 6i/10g/11g/12c) y su lógica en **PL/SQL** (packages, procedures, functions, triggers de base de datos). Patrón "aplicación en el datastore + Forms": la lógica de negocio vive repartida entre triggers de Forms (`.fmb`/`.pll`) y paquetes PL/SQL del esquema.

**Implementa la columna Oracle Forms + PL/SQL** del método HVM-wide [Gemelo Cognitivo del Sistema](../../../metodologia-gemelo-cognitivo.md). El método (qué destilar y por qué) es constante; este specialist aporta la **mecánica de extracción** Oracle. Es el equivalente Oracle del [Specialist - Informix SPL](../Specialist%20-%20Informix%20SPL/CLAUDE.md).

No es un agente estratégico: **hace el trabajo** de documentar qué hace el sistema — módulo por módulo, paquete por paquete, trigger por trigger.

---

## Adaptador de extracción por capa (columna Oracle del §4 del método)

| Capa del Gemelo (qué destila — constante) | Fuente de extracción Oracle Forms + PL/SQL |
|---|---|
| **1 · Lenguaje** (identificadores → vocabulario) | nombres de items de bloque (`.fmb`→XML vía Forms2XML), `ALL_PROCEDURES`, `ALL_SOURCE`, `ALL_IDENTIFIERS` (PL/Scope), `ALL_TAB_COLUMNS` |
| **2 · Almas** (autoría + estilometría) | headers de comentario en `.fmb`/`.pll`/*package spec* + `ALL_SOURCE` (comentarios), *banner* de módulo |
| **3 · Biografía** (fechas + hitos) | `ALL_OBJECTS.CREATED` / `LAST_DDL_TIME`, fechas en comentarios, versión de módulo Forms |
| **4 · Intención** (journeys + reglas) | triggers de Forms (`WHEN-BUTTON-PRESSED`, `WHEN-VALIDATE-ITEM`…) + call graph PL/SQL (`ALL_DEPENDENCIES`) + DML |
| **5 · Fronteras** (bounded contexts) | módulos Forms + esquemas/paquetes PL/SQL + `ALL_DEPENDENCIES` cross-schema |
| **7 · Equivalencia** (riesgos de tipo) | `NUMBER` rounding, `DATE`/`TIMESTAMP` semántica, `%ROWTYPE`, secuencias, `NLS` settings |

**Catálogos Oracle clave:** `ALL_SOURCE` (cuerpo de packages/procs), `ALL_PROCEDURES`, `ALL_ARGUMENTS`, `ALL_DEPENDENCIES` (call graph), `ALL_OBJECTS` (fechas), `ALL_TRIGGERS`, `ALL_IDENTIFIERS` (PL/Scope — nombres de identificadores para vocabulario). Forms: `.fmb`/`.mmb`/`.pll` convertidos a XML con `frmf2xml` / Forms2XML.

> **Nota de fidelidad:** la lógica repartida entre Forms (UI + triggers) y PL/SQL (datastore) exige extraer **ambos** — un análisis solo-PL/SQL pierde las reglas embebidas en los triggers de Forms.

---

## Pendiente para activación (cuando haya deal)

1. Portar las **5 Etapas** (Setup & Inventory · Static Analysis · Data RE · Business Logic Extraction · Domain Decomposition) desde el Specialist Informix SPL, sustituyendo las queries de catálogo Informix por los catálogos Oracle de arriba.
2. Construir el **extractor Oracle** que emite el JSON normalizado (§6 del método) — reutiliza el **renderer cognitivo** (tech-agnóstico) de la instancia de referencia `../../BanCoppel/systems/core/Informix/`.
3. Catálogo de tipos Oracle → target con `[RIESGO-EQUIVALENCIA]` (NUMBER/DATE/secuencias).

---

*Última actualización: 2026-07-06 · v0.0.1 · Stub `[STATE: PROPOSED]` — implementa la columna Oracle Forms + PL/SQL del método HVM-wide Gemelo Cognitivo. Se completa al activarse un deal; clonar Specialist - Informix SPL como base.*