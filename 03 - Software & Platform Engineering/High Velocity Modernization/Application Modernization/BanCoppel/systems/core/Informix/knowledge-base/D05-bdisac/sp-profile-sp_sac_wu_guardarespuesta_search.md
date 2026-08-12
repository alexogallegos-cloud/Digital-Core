# SP Profile: `sp_sac_wu_guardarespuesta_search`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 162 callers en produccion

---

## Historia Funcional

El SP `sp_sac_wu_guardarespuesta_search` implementa la logica de guarda respuesta y archivo en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 288 lineas de codigo, 6 tablas consultadas. Es invocado por 162 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdisac`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_sac_wu_guardarespuesta_search.html](../../portal/sp-detail/sp-detail-sp_sac_wu_guardarespuesta_search.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **162** |
| Fan-out (callees) | **3** |
| Callees principales | `bdisac` |
| LOC | **288** |
| Tablas consultadas | 6 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_sac_wu_guardarespuesta_sea."]
    N1{"isql_err  0"}
    A --> N1
    N2["CALL: bdisac"]
    N1 --> N2
    N3["CALL: bdisac"]
    A --> N3
    N4{"pretcode = '00000'"}
    A --> N4
    N5["CALL: bdisac"]
    N4 --> N5
    Z["Salida"]
    N5 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D05 SAC / Transferencias
    participant SP as sp_sac_wu_guardarespuesta_s.
    participant C1 as bdisac
    CL->>SP: invoca sp_sac_wu_guardarespuesta_s.
    SP->>C1: delega a bdisac
    C1-->>SP: resultado
    Note over SP,CL: vocab: sac, guarda, arch, respuesta
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `sac` | ENTIDAD | ALTA | Servicios de Atención al Cliente — subsistema de atención en sucursal (ventanilla, domiciliación, abonos ATM, remesas WU); base de datos propia bdisac: con tabla sac_movimientoshistorial; confirmado por SME (2026-08-02) |
| `guarda` | ACCION | ALTA | guarda / almacena |
| `arch` | ENTIDAD | MEDIA | archivo |
| `respuesta` | ENTIDAD | ALTA | respuesta |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_se`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
