# SP Profile: `spei_devcodi`

> **Base de datos**: `bdispei` · Dominio D08 — SPEI / CoDi
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `spei_devcodi` implementa la logica de devolución · CoDi — Cobro Digital en el dominio SPEI / CoDi (base de datos `bdispei`). Comprende 4,054 lineas de codigo, 21 tablas consultadas. Delega logica a: `spei_recerrorescodi`, `sp_validaspei_bpi`, `spei_validaoperacion`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D08 | [../D08-bdispei/07-dependencies.md](../D08-bdispei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-spei_devcodi.html](../../portal/sp-detail/sp-detail-spei_devcodi.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **10** |
| Callees principales | `spei_recerrorescodi`, `sp_validaspei_bpi`, `spei_validaoperacion` |
| LOC | **4,054** |
| Tablas consultadas | 21 |
| Reglas de negocio activas | **3** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: spei_devcodi"]
    N1{"pvchrnombreord is null or pvchrnom."}
    A --> N1
    N2["CALL: recepción error · CoDi — Cobro Dig."]
    N1 --> N2
    N3{"pvchrnombrebenef is null or pvchrn."}
    A --> N3
    N4["CALL: recepción error · CoDi — Cobro Dig."]
    N3 --> N4
    N5{"pinttipoctaord = 3"}
    A --> N5
    N6{"vchrtarjeta is null) or (vchrtarje."}
    N5 --> N6
    N7["CALL: recepción error · CoDi — Cobro Dig."]
    N6 --> N7
    N8{"pvchrcuentaord is null or pvchrcue."}
    N6 --> N8
    N9{"pinttipoctaord = 40"}
    A --> N9
    Y["Aplica reglas (3 reglas)"]
    N9 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D08 SPEI / CoDi
    participant SP as spei_devcodi
    participant C1 as spei_recerrorescodi
    participant C2 as sp_validaspei_bpi
    participant C3 as spei_validaoperacion
    CL->>SP: invoca spei_devcodi
    SP->>C1: delega a spei_recerrorescodi
    C1-->>SP: resultado
    SP->>C2: delega a sp_validaspei_bpi
    C2-->>SP: resultado
    Note over SP: BR-V2-7021 REGULATORIO: SPEI Reglas técnicas
    Note over SP: BR-V2-7022 REGULATORIO: Ya se aplico una devolucion
    Note over SP: BR-V2-7023 REGULATORIO: SPEI Reglas técnicas
    Note over SP,CL: vocab: spei, codi
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-7021 | FÓRMULA | REGULATORIO | 571 | `intBancoOrd = (vchrparametro * 1)` | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s |
| BR-V2-7022 | VALIDACIÓN | REGULATORIO | 1046 | `LET vchrcodret = '444'; --Ya se aplico una devolucion` | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s |
| BR-V2-7023 | UMBRAL | REGULATORIO | 1152 | `IF pdecImporte > 100000.00 THEN` | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `spei` | PREFIJO | ALTA | familia SPEI (pagos interbancarios) |
| `codi` | REG | ALTA | CoDi — Cobro Digital (Banxico) |

---

## Nota de Migracion

Las 3 reglas con categoria REGULATORIO son las mas sensibles en la migracion y deben ser validadas por el SME de Industry Banking Accounting contra el CUB vigente.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
