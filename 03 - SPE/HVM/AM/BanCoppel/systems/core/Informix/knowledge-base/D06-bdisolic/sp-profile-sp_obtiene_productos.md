# SP Profile: `sp_obtiene_productos`

> **Base de datos**: `bdisolic` · Dominio D06 — Solicitudes de Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_obtiene_productos` implementa la logica de obtiene productos en el dominio Solicitudes de Credito (base de datos `bdisolic`). Comprende 1,800 lineas de codigo, 52 tablas consultadas. Delega logica a: `bdisolic`, `bdinteg`, `bdicred`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D06 | [../D06-bdisolic/07-dependencies.md](../D06-bdisolic/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtiene_productos.html](../../portal/sp-detail/sp-detail-sp_obtiene_productos.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **9** |
| Callees principales | `bdisolic`, `bdinteg`, `bdicred` |
| LOC | **1,800** |
| Tablas consultadas | 52 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obtiene_productos"]
    N1{"psucursal  '8503' and itotsolweb."}
    A --> N1
    N2(["Iteracion"])
    N1 --> N2
    N3["CALL: solicitud"]
    N2 --> N3
    N4{"itotsolweb0"}
    A --> N4
    N5(["Iteracion"])
    N4 --> N5
    N6["CALL: solicitud"]
    N5 --> N6
    N7{"bprospecto = '0'"}
    A --> N7
    N8["CALL: interés"]
    N7 --> N8
    N9{"cdigidom = '1'"}
    N7 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D06 Solicitudes de Credi.
    participant SP as sp_obtiene_productos
    participant C1 as bdisolic
    participant C2 as bdinteg
    participant C3 as bdicred
    CL->>SP: invoca sp_obtiene_productos
    SP->>C1: delega a bdisolic
    C1-->>SP: resultado
    SP->>C2: delega a bdinteg
    C2-->>SP: resultado
    Note over SP,CL: vocab: obtiene, productos, producto, prod
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `obtiene` | ACCION | ALTA | obtiene / recupera |
| `productos` | ENTIDAD | ALTA | productos |
| `producto` | ENTIDAD | ALTA | producto |
| `prod` | ENTIDAD | MEDIA | producto |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
