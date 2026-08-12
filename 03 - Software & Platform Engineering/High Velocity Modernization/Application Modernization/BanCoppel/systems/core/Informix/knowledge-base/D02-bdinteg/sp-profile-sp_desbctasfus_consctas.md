# SP Profile: `sp_desbctasfus_consctas`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 219 callers en produccion

---

## Historia Funcional

El SP `sp_desbctasfus_consctas` implementa la logica de desbloqueo cuentas en el dominio Integracion Core (base de datos `bdinteg`). Comprende 1,693 lineas de codigo, 7 tablas consultadas. Es invocado por 219 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdicheq`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_desbctasfus_consctas.html](../../portal/sp-detail/sp-detail-sp_desbctasfus_consctas.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **219** |
| Fan-out (callees) | **4** |
| Callees principales | `bdicheq` |
| LOC | **1,693** |
| Tablas consultadas | 7 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_desbctasfus_consctas"]
    N1{"inumrows = 0"}
    A --> N1
    N2{"inumrows = 0"}
    N1 --> N2
    N3{"inumrows  0"}
    N2 --> N3
    N4{"inumrows  0"}
    A --> N4
    N5(["Iteracion"])
    N4 --> N5
    N6["CALL: bdicheq"]
    N5 --> N6
    N7{"inumrows  0"}
    N4 --> N7
    N8(["Iteracion"])
    N7 --> N8
    N9(["Iteracion"])
    N4 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D02 Integracion Core
    participant SP as sp_desbctasfus_consctas
    participant C1 as bdicheq
    CL->>SP: invoca sp_desbctasfus_consctas
    SP->>C1: delega a bdicheq
    C1-->>SP: resultado
    Note over SP,CL: vocab: cons, ctas, desb
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cons` | ACCION | ALTA | consulta |
| `ctas` | ENTIDAD | ALTA | cuentas |
| `desb` | ACCION | MEDIA | desbloqueo |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
