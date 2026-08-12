# SP Profile: `spei_reccancelacion`

> **Base de datos**: `bdispei` · Dominio D08 — SPEI / CoDi
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `spei_reccancelacion` implementa la logica de recibe cancelación en el dominio SPEI / CoDi (base de datos `bdispei`). Comprende 4,240 lineas de codigo, 5 tablas consultadas. Delega logica a: `sp_obtfoliosuc`, `bdicheq`, `spei_recerrorescodi`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D08 | [../D08-bdispei/07-dependencies.md](../D08-bdispei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-spei_reccancelacion.html](../../portal/sp-detail/sp-detail-spei_reccancelacion.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **14** |
| Callees principales | `sp_obtfoliosuc`, `bdicheq`, `spei_recerrorescodi` |
| LOC | **4,240** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: spei_reccancelacion"]
    N1{"codretfirma = 0"}
    A --> N1
    N2["CALL: obtiene folio (sucursal)"]
    N1 --> N2
    N3["CALL: bdicheq"]
    N1 --> N3
    N4{"vcodret1 = '000'"}
    N1 --> N4
    N5{"pchartipopago in('19', '20', '21',."}
    N4 --> N5
    N6{"pchartipopago in('19', '20', '21',."}
    N1 --> N6
    N7["CALL: recepción error · CoDi — Cobro Dig."]
    N6 --> N7
    Z["Salida"]
    N7 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D08 SPEI / CoDi
    participant SP as spei_reccancelacion
    participant C1 as sp_obtfoliosuc
    participant C2 as bdicheq
    participant C3 as spei_recerrorescodi
    CL->>SP: invoca spei_reccancelacion
    SP->>C1: delega a sp_obtfoliosuc
    C1-->>SP: resultado
    SP->>C2: delega a bdicheq
    C2-->>SP: resultado
    Note over SP,CL: vocab: spei, reccancelacion, cancela, cancelacion
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `spei` | PREFIJO | ALTA | familia SPEI (pagos interbancarios) |
| `reccancelacion` | ACCION | ALTA | recibe cancelación |
| `cancela` | ACCION | ALTA | cancela |
| `cancelacion` | ACCION | ALTA | cancela |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
