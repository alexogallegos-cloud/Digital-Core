# SP Profile: `abono_ref`

> **Base de datos**: `bdicheq` · Dominio D04 — Chequera / Debito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 520 callers en produccion

---

## Historia Funcional

El SP `abono_ref` implementa la logica de abono en el dominio Chequera / Debito (base de datos `bdicheq`). Comprende 1,654 lineas de codigo, 39 tablas consultadas. Es invocado por 520 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `sp_transfer_online_abonospei`, `sp_transfer_online_setsvabalance`, `sp_transfer_online_abono`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D04 | [../D04-bdicheq/07-dependencies.md](../D04-bdicheq/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-abono_ref.html](../../portal/sp-detail/sp-detail-abono_ref.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **520** |
| Fan-out (callees) | **7** |
| Callees principales | `sp_transfer_online_abonospei`, `sp_transfer_online_setsvabalance`, `sp_transfer_online_abono` |
| LOC | **1,654** |
| Tablas consultadas | 39 |
| Reglas de negocio activas | **4** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: abono_ref"]
    N1{"substr(pcuenta, 1, 2) = '80'"}
    A --> N1
    N2{"ptransacc in('0273','0276','0277'"}
    N1 --> N2
    N3{"ptransacc = '0273'"}
    N2 --> N3
    N4{"ptransacc in('0276','0277'"}
    N2 --> N4
    N5["CALL: línea y abono"]
    N2 --> N5
    N6{"cstatus is null or cstatus = '' or."}
    N1 --> N6
    N7["CALL: línea"]
    N6 --> N7
    N8{"ptransacc = '1193' or ptransacc = ."}
    N1 --> N8
    N9["CALL: bdicheq"]
    N8 --> N9
    Y["Aplica reglas (4 reglas)"]
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
    participant SP as abono_ref
    participant C1 as sp_transfer_online_abono.
    participant C2 as sp_transfer_online_setsv.
    participant C3 as sp_transfer_online_abono
    CL->>SP: invoca abono_ref
    SP->>C1: delega a sp_transfer_online_abono.
    C1-->>SP: resultado
    SP->>C2: delega a sp_transfer_online_setsv.
    C2-->>SP: resultado
    Note over SP: BR-V2-0470 OPERACIONAL: Retorna código de error 999
    Note over SP: BR-V2-0471 OPERACIONAL: Retorna código de error 420
    Note over SP,CL: vocab: abono, ref
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0470 | VALIDACIÓN | OPERACIONAL | 307 | `LET vcodret = '999'` | — |
| BR-V2-0471 | VALIDACIÓN | OPERACIONAL | 516 | `LET vcodret = "420"` | — |
| BR-V2-0472 | FÓRMULA | CALCULO_FINANCIERO | 792 | `vmonto_udi = pmto_tot / vprecio_udi` | — |
| BR-V2-0473 | FÓRMULA | CALCULO_FINANCIERO | 795 | `vmtopagosudi = vmtoacumcta / vprecio_udi` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `abono` | ENTIDAD | ALTA | abono / crédito |
| `ref` | AMBIGUO | AMBIGUA | referencia |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
