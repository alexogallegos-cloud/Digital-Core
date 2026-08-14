# SP Profile: `sp_retdialide_esp`

> **Base de datos**: `bdilide` · Dominio D15 — LIDE / Dispersion
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_retdialide_esp` implementa la logica de identificador (del día, especial) en el dominio LIDE / Dispersion (base de datos `bdilide`). Comprende 790 lineas de codigo, 16 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D15 | [../D15-bdilide/07-dependencies.md](../D15-bdilide/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_retdialide_esp.html](../../portal/sp-detail/sp-detail-sp_retdialide_esp.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **5** |
| Callees principales | — |
| LOC | **790** |
| Tablas consultadas | 16 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_retdialide_esp\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    Z["Retorna resultado"]
    N1 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D15 LIDE / Dispersion
    participant SP as sp_retdialide_esp
    CL->>SP: invoca sp_retdialide_esp
    Note over SP,CL: vocab: esp
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `esp` | MODIF | ALTA | especial |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_ret`, `?l`, `?e_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
