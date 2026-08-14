# SP Profile: `cargo_ref_pos`

> **Base de datos**: `bdicheq` · Dominio D04 — Chequera / Debito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 4 callers en produccion

---

## Historia Funcional

El SP `cargo_ref_pos` implementa la logica de cargo y punto de venta en el dominio Chequera / Debito (base de datos `bdicheq`). Comprende 8,933 lineas de codigo, 10 tablas consultadas. Es invocado por 4 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdinteg`, `gen_protsdo_pos`, `protsdo_pos`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D04 | [../D04-bdicheq/07-dependencies.md](../D04-bdicheq/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-cargo_ref_pos.html](../../portal/sp-detail/sp-detail-cargo_ref_pos.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **4** |
| Fan-out (callees) | **28** |
| Callees principales | `bdinteg`, `gen_protsdo_pos`, `protsdo_pos` |
| LOC | **8,933** |
| Tablas consultadas | 10 |
| Reglas de negocio activas | **2** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: cargo_ref_pos"]
    N1{"vuser_limit is not null or vuser_l."}
    A --> N1
    N2{"vtran_limit is not null or vtran_l."}
    N1 --> N2
    N3["CALL: interés"]
    N2 --> N3
    N4{"vtiptran = '20' and vtiptran = '."}
    A --> N4
    N5["CALL: genera saldo y punto de venta"]
    N4 --> N5
    N6{"vtiptran = '30' and vtiptran = '."}
    N4 --> N6
    N7["CALL: saldo y punto de venta"]
    N6 --> N7
    N8["CALL: cargo y punto de venta"]
    N6 --> N8
    N9{"vcompend  0 and vsdodisp  0"}
    A --> N9
    Y["Aplica reglas (2 reglas)"]
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
    participant SP as cargo_ref_pos
    participant C1 as bdinteg
    participant C2 as gen_protsdo_pos
    participant C3 as protsdo_pos
    CL->>SP: invoca cargo_ref_pos
    SP->>C1: delega a bdinteg
    C1-->>SP: resultado
    SP->>C2: delega a gen_protsdo_pos
    C2-->>SP: resultado
    Note over SP: BR-V2-0628 OPERACIONAL: Retorna código de error 962
    Note over SP: BR-V2-0629 OPERACIONAL: Retorna código de error 777
    Note over SP,CL: vocab: cargo, ref, pos
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0628 | VALIDACIÓN | OPERACIONAL | 104 | `let vcodret = "962"` | — |
| BR-V2-0629 | VALIDACIÓN | OPERACIONAL | 189 | `let vcodret = "777"` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cargo` | ENTIDAD | ALTA | cargo / débito |
| `ref` | AMBIGUO | AMBIGUA | referencia |
| `pos` | ENTIDAD | ALTA | punto de venta (POS) |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
