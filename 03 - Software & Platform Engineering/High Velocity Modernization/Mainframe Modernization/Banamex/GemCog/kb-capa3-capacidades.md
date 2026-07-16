# KB: Capa 3-5 — Capacidades, Tareas y Flujos · Banamex GemCog

> Base de conocimiento para la construcción de archivos `cap-{slug}.md`
> Metodología: Gemelo Cognitivo del Sistema · Capas 3, 4 y 5
> Sistemas: S500 (Cargos/Abonos — Captación) + S151 (Movimientos Contables — GL)
> Catálogo de reglas: `rules-catalog/` · Vocabulario: `vocab-s151.md` + `vocab-s500.md`

---

## Jerarquía

```
Dominio → Subdominio → Capacidad → Proceso → Tarea → Regla de Negocio
                                                  ↕
                                            Casuística (secuencia de tareas)
                                                  ↕
                                            Diagrama Mermaid (flujo/secuencia)
```

---

## Modelo de datos por Capacidad

### Tarea (unidad atómica)

| Campo | Descripción |
|-------|-------------|
| ID | `T-{SLUG}-{NNN}` — slug de la capacidad (3-5 caracteres, mayúsculas) |
| Nombre | Descripción imperativa ("Validar saldo disponible", "Generar asiento débito") |
| Sistema | `S151` / `S500` / `compartida` |
| Programa | Nombre corto del programa: `P010`, `P630`, `L030`, `S151REGISTRA`, etc. |
| Componente fuente | Nombre del archivo físico en el source: `COBOL_P010.txt`, `ALGOL_P021.txt`, `DASDL_BD10.txt`, etc. |
| Tipo | `validación` / `consulta` / `escritura` / `contable` / `control` |
| Reglas vinculadas | Lista de `RN-S151/S500-NNN` vinculadas a esta tarea |

**Nota sobre el Tipo:**
- `validación` — verifica una condición (saldo, límite, vigencia) antes de continuar
- `consulta` — lee datos sin modificarlos
- `escritura` — persiste o actualiza un campo en la BD
- `contable` — genera un asiento o movimiento de libro mayor (GL)
- `control` — maneja flujo de batch (restart, punteo, llave de control, cierre)

### Casuística

| Campo | Descripción |
|-------|-------------|
| ID | `CS-{SLUG}-{NN}` |
| Nombre | Nombre del escenario ("Cargo exitoso", "Saldo insuficiente", "Cuenta cancelada") |
| Tipo | `happy-path` / `error` / `edge-case` |
| Condición de entrada | Precondición del escenario (estado de cuenta, tipo de movimiento, etc.) |
| Secuencia | Lista ordenada de IDs de tarea: `T-{X}-001 → T-{X}-002 → T-{X}-003` |
| Resultado | Postcondición / efecto del escenario (campo actualizado, asiento generado, rechazo, etc.) |

**Convención de orden:** construir primero el happy-path (CS-01), luego errores de validación (CS-02, CS-03...), luego edge cases (CS-0N...).

---

## Plantilla `cap-{slug}.md`

```markdown
# Capacidad: {Nombre completo} [{S500 / S151 / compartida}]
> Dominio: {X} · Subdominio: {Y} · Cobertura: S500 / S151 / compartida / gap
> Programas principales: {lista} · Reglas vinculadas: RN-{S}-{NNN}..{NNN}

## Inventario de Tareas

| ID | Tarea | Programa | Componente fuente | Tipo |
|----|-------|----------|-------------------|------|
| T-{SLUG}-001 | {descripción imperativa} | P010 | COBOL_P010.txt | validación |
| T-{SLUG}-002 | {descripción imperativa} | P630 | COBOL_P630.txt | escritura |
| T-{SLUG}-003 | {descripción imperativa} | S151REGISTRA | ALGOL_L002R2.txt | contable |

## Casuísticas

### CS-{SLUG}-01: {Nombre — happy path}
**Tipo:** happy-path
**Condición de entrada:** {precondición}
**Resultado:** {postcondición / efecto}
**Secuencia:** T-{SLUG}-001 → T-{SLUG}-002 → T-{SLUG}-003

### CS-{SLUG}-02: {Nombre — error}
**Tipo:** error
**Condición de entrada:** {precondición de error}
**Resultado:** {rechazo / reversión / log de error}
**Secuencia:** T-{SLUG}-001 → T-{SLUG}-004

### CS-{SLUG}-03: {Nombre — edge case}
**Tipo:** edge-case
**Condición de entrada:** {condición límite}
**Resultado:** {comportamiento especial}
**Secuencia:** T-{SLUG}-001 → T-{SLUG}-002 → T-{SLUG}-005

## Diagrama

\`\`\`mermaid
sequenceDiagram
  participant C as Cliente/Batch
  participant S500 as S500 (Captación)
  participant S151 as S151 (GL)
  C->>S500: {acción}
  S500->>S500: T-{SLUG}-001 Validar {X}
  S500->>S151: T-{SLUG}-002 Generar asiento
  S151-->>S500: Confirmación
  S500-->>C: Resultado
\`\`\`

## Reglas vinculadas

| Tarea | Regla | Componente fuente | Descripción |
|-------|-------|-------------------|-------------|
| T-{SLUG}-001 | RN-S151-NNN | COBOL_P010.txt | {descripción de la regla} |
| T-{SLUG}-002 | RN-S500-NNN | COBOL_P630.txt | {descripción de la regla} |
```

---

## Flujo de construcción (orden obligatorio)

```
1. Inventario de tareas
   ↓ (del código fuente + reglas RN-NNN ya extraídas)
2. Casuísticas
   ↓ (agrupar tareas en secuencias por escenario)
3. Diagrama Mermaid
   ↓ (derivado mecánicamente de la secuencia de cada casuística)
4. Vincular reglas
   (cruzar cada tarea contra rules-catalog/rules-s151.md + rules-s500.md)
```

No construir el diagrama antes de tener las casuísticas. No vincular reglas antes de tener el inventario de tareas. El orden garantiza trazabilidad completa: código → tarea → casuística → diagrama → regla.

---

## Catálogo de Capacidades — Estado de Cobertura (20/104)

Ver `rules-catalog/INDEX.md` para la lista completa con reglas vinculadas por capacidad.

El número total de capacidades (104) corresponde al modelo de capacidades bancarias del portal GemCog (`rules-report-gemcog.html`).

### Capacidades con cobertura prioritaria (S151 — GL)

Los archivos `cap-{slug}.md` ya existentes viven en `rules-catalog/` o en una subcarpeta `capacidades/` (crear si no existe).

| Prioridad | Capacidad | Slug | Reglas S151 | Reglas S500 |
|-----------|-----------|------|-------------|-------------|
| P0 | Generación de asientos (partida doble) | `GAS` | RN-S151-001..NNN | — |
| P0 | Conciliación diaria S500↔S151 | `CON` | RN-S151-NNN.. | — |
| P0 | Cierre de período contable | `CIE` | RN-S151-NNN.. | — |
| P0 | Generación reportes CNBV (Serie B) | `RPT` | RN-S151-NNN.. | — |
| P1 | Cálculo de intereses (saldo promedio diario) | `INT` | — | RN-S500-NNN.. |
| P1 | Retención ISR | `ISR` | — | RN-S500-NNN.. |
| P1 | Comisiones (mantenimiento, disposición ATM) | `COM` | — | RN-S500-NNN.. |
| P2 | Control de NACs / depósitos en tránsito | `NAC` | — | RN-S500-NNN.. |
| P2 | Tipos de movimiento (catálogo → R10) | `TMV` | — | RN-S500-NNN.. |

*(Completar las referencias NNN de reglas cruzando contra `rules-catalog/rules-s151.md` y `rules-catalog/rules-s500.md`)*

---

## Relación con otros artefactos del GemCog Banamex

| Artefacto | Relación con este KB |
|-----------|---------------------|
| `vocab-s151.md` + `vocab-s500.md` | Los nombres de Tareas usan el término canónico del vocabulario |
| `rules-catalog/rules-s151.md` | Fuente de `RN-S151-NNN` para la columna "Reglas vinculadas" |
| `rules-catalog/rules-s500.md` | Fuente de `RN-S500-NNN` para la columna "Reglas vinculadas" |
| `rules-catalog/INDEX.md` | Estado de cobertura por capacidad (% de reglas cubiertas por `cap-{slug}.md`) |
| `rules-report-gemcog.html` | Portal navegable — visualización de capacidades y reglas |
| `kb-capa5-fronteras.md` | Bounded contexts derivados de las Capacidades de este KB |

---

## Notas de honestidad

- Los IDs de Tarea (`T-{SLUG}-NNN`) son nuevos (no existían antes de este KB). Asignar secuencialmente por capacidad.
- Las Casuísticas son una construcción analítica — se derivan del código, no del código directamente. Marcar como `[INFERIDA]` si no hay evidencia directa en el fuente.
- Un Diagrama Mermaid solo es tan fiel como la Casuística que lo origina. Si la casuística es parcial, el diagrama es parcial — declararlo explícitamente.
- La cobertura 20/104 puede cambiar cuando se descubran capacidades adicionales o cuando el modelo de capacidades bancarias se refine.

---

*kb-capa3-capacidades.md · v1.0 · 2026-07-16 · Creación inicial. Base de conocimiento para la construcción de archivos cap-{slug}.md del Gemelo Cognitivo Banamex S500/S151. Complementa kb-capa5-fronteras.md.*