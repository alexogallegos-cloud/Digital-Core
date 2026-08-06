# SP Profile: `cargon_ref`

> **Base de datos**: `bdicheq` · Dominio D04 — Chequera / Debito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 70 callers en produccion

---

## Historia Funcional

El SP `cargon_ref` implementa la logica de cargo en el dominio Chequera / Debito (base de datos `bdicheq`). Comprende 8,587 lineas de codigo, 22 tablas consultadas. Es invocado por 70 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdispei`, `cargo_comisiones`, `gencomdev`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D04 | [../D04-bdicheq/07-dependencies.md](../D04-bdicheq/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-cargon_ref.html](../../portal/sp-detail/sp-detail-cargon_ref.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **70** |
| Fan-out (callees) | **24** |
| Callees principales | `bdispei`, `cargo_comisiones`, `gencomdev` |
| LOC | **8,587** |
| Tablas consultadas | 22 |
| Reglas de negocio activas | **5** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: cargon_ref"]
    N1{"ptransacc in('0274', '0447'"}
    A --> N1
    N2{"current hour to fraction  '17:58:."}
    N1 --> N2
    N3["CALL: bdispei"]
    N2 --> N3
    N4(["Iteracion"])
    A --> N4
    N5{"vsobregira = 's' and pmonto  vdis."}
    N4 --> N5
    N6{"vvaldoc = 's'"}
    N5 --> N6
    N7{"pmonto  vdisponible"}
    N4 --> N7
    N8{"vvaldoc = 's'"}
    N7 --> N8
    N9{"vvaldoc = 's'"}
    N7 --> N9
    Y["Aplica reglas (5 reglas)"]
    N9 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D04 Chequera / Debito
    participant SP as cargon_ref
    participant C1 as bdispei
    participant C2 as cargo_comisiones
    participant C3 as gencomdev
    CL->>SP: invoca cargon_ref
    SP->>C1: delega a bdispei
    C1-->>SP: resultado
    SP->>C2: delega a cargo_comisiones
    C2-->>SP: resultado
    Note over SP: BR-V2-0644 OPERACIONAL: Retorna código de error 110
    Note over SP: BR-V2-0645 OPERACIONAL: Retorna código de error 106
    Note over SP: BR-V2-0646 OPERACIONAL: Retorna código de error 300
    Note over SP: BR-V2-0647 OPERACIONAL: Pagado
    Note over SP,CL: vocab: ref, cargo
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0644 | VALIDACIÓN | OPERACIONAL | 264 | `let vcodret = '110'` | — |
| BR-V2-0645 | VALIDACIÓN | OPERACIONAL | 275 | `let vcodret = "106"` | — |
| BR-V2-0646 | VALIDACIÓN | OPERACIONAL | 422 | `LET vcodret = "300"` | — |
| BR-V2-0647 | VALIDACIÓN | OPERACIONAL | 579 | `LET vcodret = '600'` | — |
| BR-V2-0648 | VALIDACIÓN | OPERACIONAL | 764 | `LET vcodret = "400"; --//Debe retornar forndos insuficientes` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `ref` | AMBIGUO | AMBIGUA | referencia |
| `cargo` | ENTIDAD | ALTA | cargo / débito |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?n_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
