# SP Profile: `sp_bloqueactas`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 210 callers en produccion

---

## Historia Funcional

El SP `sp_bloqueactas` implementa la logica de bloquea cuenta cuentas en el dominio Integracion Core (base de datos `bdinteg`). Comprende 1,251 lineas de codigo, 3 tablas consultadas. Es invocado por 210 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdicheq`, `bdicred`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_bloqueactas.html](../../portal/sp-detail/sp-detail-sp_bloqueactas.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **210** |
| Fan-out (callees) | **3** |
| Callees principales | `bdicheq`, `bdicred` |
| LOC | **1,251** |
| Tablas consultadas | 3 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_bloqueactas"]
    N1(["Iteracion"])
    A --> N1
    N2{"cstatuscta = '1'"}
    N1 --> N2
    N3["CALL: bdicheq"]
    N2 --> N3
    N4(["Iteracion"])
    A --> N4
    N5{"istatuscred is null"}
    N4 --> N5
    N6["CALL: bdicred"]
    N5 --> N6
    Z["Salida"]
    N6 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D02 Integracion Core
    participant SP as sp_bloqueactas
    participant C1 as bdicheq
    participant C2 as bdicred
    CL->>SP: invoca sp_bloqueactas
    SP->>C1: delega a bdicheq
    C1-->>SP: resultado
    SP->>C2: delega a bdicred
    C2-->>SP: resultado
    Note over SP,CL: vocab: ctas, bloquea, bloq
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `ctas` | ENTIDAD | ALTA | cuentas |
| `bloquea` | ACCION | ALTA | bloquea cuenta |
| `bloq` | ACCION | MEDIA | bloqueo |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
