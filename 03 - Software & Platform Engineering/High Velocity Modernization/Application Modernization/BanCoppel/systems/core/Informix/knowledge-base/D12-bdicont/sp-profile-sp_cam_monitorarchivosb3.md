# SP Profile: `sp_cam_monitorarchivosb3`

> **Base de datos**: `bdicont` · Dominio D12 — Contabilidad
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_cam_monitorarchivosb3` implementa la logica de monitor y archivo en el dominio Contabilidad (base de datos `bdicont`). Comprende 2,660 lineas de codigo. Delega logica a: `bdicnweb`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D12 | [../D12-bdicont/07-dependencies.md](../D12-bdicont/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_cam_monitorarchivosb3.html](../../portal/sp-detail/sp-detail-sp_cam_monitorarchivosb3.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **37** |
| Callees principales | `bdicnweb` |
| LOC | **2,660** |
| Tablas consultadas | 0 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_cam_monitorarchivosb3"]
    N1{"pbandera = 1"}
    A --> N1
    N2(["Iteracion"])
    N1 --> N2
    N3["CALL: (canal web)"]
    N2 --> N3
    N4["CALL: (canal web)"]
    N1 --> N4
    N5(["Iteracion"])
    N1 --> N5
    N6["CALL: (canal web)"]
    N5 --> N6
    N7["CALL: (canal web)"]
    N1 --> N7
    N8(["Iteracion"])
    N1 --> N8
    N9["CALL: (canal web)"]
    N8 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D12 Contabilidad
    participant SP as sp_cam_monitorarchivosb3
    participant C1 as bdicnweb
    CL->>SP: invoca sp_cam_monitorarchivosb3
    SP->>C1: delega a bdicnweb
    C1-->>SP: resultado
    Note over SP,CL: vocab: cam, archivo, arch, archivos
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cam` | PREFIJO | MEDIA | cámara / captura contable |
| `archivo` | ENTIDAD | ALTA | archivo |
| `arch` | ENTIDAD | MEDIA | archivo |
| `archivos` | ENTIDAD | ALTA | archivos |
| `monitor` | ENTIDAD | ALTA | monitor |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
