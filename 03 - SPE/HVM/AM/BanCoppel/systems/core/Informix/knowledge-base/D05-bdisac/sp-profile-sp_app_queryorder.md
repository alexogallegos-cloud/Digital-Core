# SP Profile: `sp_app_queryorder`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 154 callers en produccion

---

## Historia Funcional

El SP `sp_app_queryorder` implementa la logica de ordenante (canal app) en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 711 lineas de codigo, 5 tablas consultadas. Es invocado por 154 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdisac`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_app_queryorder.html](../../portal/sp-detail/sp-detail-sp_app_queryorder.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **154** |
| Fan-out (callees) | **14** |
| Callees principales | `bdisac` |
| LOC | **711** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_app_queryorder"]
    N1{"ptxn_status = '' or punirefnum = '."}
    A --> N1
    N2["CALL: bdisac"]
    N1 --> N2
    Z["Salida"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D05 SAC / Transferencias
    participant SP as sp_app_queryorder
    participant C1 as bdisac
    CL->>SP: invoca sp_app_queryorder
    SP->>C1: delega a bdisac
    C1-->>SP: resultado
    Note over SP,CL: vocab: app
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `app` | MODIF | ALTA | canal app |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_query`, `?er`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
