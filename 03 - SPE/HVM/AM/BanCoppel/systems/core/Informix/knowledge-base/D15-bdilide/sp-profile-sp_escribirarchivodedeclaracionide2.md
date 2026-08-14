# SP Profile: `sp_escribirarchivodedeclaracionide2`

> **Base de datos**: `bdilide` · Dominio D15 — LIDE / Dispersion
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 360 callers en produccion

---

## Historia Funcional

El SP `sp_escribirarchivodedeclaracionide2` implementa la logica de archivo, declaración y identificador en el dominio LIDE / Dispersion (base de datos `bdilide`). Comprende 95 lineas de codigo, 2 tablas consultadas. Es invocado por 360 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D15 | [../D15-bdilide/07-dependencies.md](../D15-bdilide/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_escribirarchivodedeclaracionide2.html](../../portal/sp-detail/sp-detail-sp_escribirarchivodedeclaracionide2.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **360** |
| Fan-out (callees) | **360** |
| Callees principales | — |
| LOC | **95** |
| Tablas consultadas | 2 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_escribirarchivodedeclaracionid.\nRecibe parámetros de entrada"]
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
    participant SP as sp_escribirarchivodedeclara.
    CL->>SP: invoca sp_escribirarchivodedeclara.
    Note over SP,CL: vocab: archivo, arch, declaracion
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `archivo` | ENTIDAD | ALTA | archivo |
| `arch` | ENTIDAD | ALTA | archivo |
| `declaracion` | ENTIDAD | ALTA | declaración |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_escribir`, `?de`, `?e2`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
