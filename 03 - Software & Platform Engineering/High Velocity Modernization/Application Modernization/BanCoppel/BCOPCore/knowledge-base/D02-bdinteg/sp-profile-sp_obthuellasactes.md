# SP Profile: `sp_obthuellasactes`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 228 callers en produccion

---

## Historia Funcional

El SP `sp_obthuellasactes` implementa la logica de obtiene huellas biométricas en el dominio Integracion Core (base de datos `bdinteg`). Comprende 2,026 lineas de codigo, 6 tablas consultadas. Es invocado por 228 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obthuellasactes.html](../../portal/sp-detail/sp-detail-sp_obthuellasactes.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **228** |
| Fan-out (callees) | **2** |
| Callees principales | — |
| LOC | **2,026** |
| Tablas consultadas | 6 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obthuellasactes"]
    B["Proceso principal"]
    A --> B
    Z["Salida"]
    B --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D02 Integracion Core
    participant SP as sp_obthuellasactes
    CL->>SP: invoca sp_obthuellasactes
    Note over SP,CL: vocab: ctes, huella, huellas
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `ctes` | ENTIDAD | ALTA | clientes |
| `huella` | ENTIDAD | ALTA | huella biométrica |
| `huellas` | ENTIDAD | ALTA | huellas biométricas |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?es`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
