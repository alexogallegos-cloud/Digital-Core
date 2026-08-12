# SP Profile: `spei_recordenpago`

> **Base de datos**: `bdispei` · Dominio D08 — SPEI / CoDi
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 2 callers en produccion

---

## Historia Funcional

El SP `spei_recordenpago` implementa la logica de recibe orden de pago en el dominio SPEI / CoDi (base de datos `bdispei`). Comprende 3,415 lineas de codigo, 22 tablas consultadas. Es invocado por 2 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `spei_recerrorescodi`, `sp_inserta_credspei`, `bdicred`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D08 | [../D08-bdispei/07-dependencies.md](../D08-bdispei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-spei_recordenpago.html](../../portal/sp-detail/sp-detail-spei_recordenpago.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **2** |
| Fan-out (callees) | **14** |
| Callees principales | `spei_recerrorescodi`, `sp_inserta_credspei`, `bdicred` |
| LOC | **3,415** |
| Tablas consultadas | 22 |
| Reglas de negocio activas | **2** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: spei_recordenpago"]
    N1{"pchrstatus = 'l'"}
    A --> N1
    N2{"pchartipopago in('19', '20', '21',."}
    N1 --> N2
    N3["CALL: recepción error · CoDi — Cobro Dig."]
    N2 --> N3
    N4{"length(trim(pvchrcuentabenef)) = 11"}
    A --> N4
    N5{"wes_credito  0"}
    N4 --> N5
    N6{"wtpo_credito = '03'"}
    N5 --> N6
    N7{"wcodret_credcomer = '000' or wcodr."}
    N5 --> N7
    N8{"wtransacc = '04446' or vproducto =."}
    A --> N8
    N9{"vproducto = '2900'"}
    N8 --> N9
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
    participant CL as D08 SPEI / CoDi
    participant SP as spei_recordenpago
    participant C1 as spei_recerrorescodi
    participant C2 as sp_inserta_credspei
    participant C3 as bdicred
    CL->>SP: invoca spei_recordenpago
    SP->>C1: delega a spei_recerrorescodi
    C1-->>SP: resultado
    SP->>C2: delega a sp_inserta_credspei
    C2-->>SP: resultado
    Note over SP: BR-V2-7035 REGULATORIO: SPEI Reglas técnicas
    Note over SP: BR-V2-7036 REGULATORIO: SPEI Reglas técnicas
    Note over SP,CL: vocab: spei, recordenpago, pago, orden
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-7035 | FÓRMULA | REGULATORIO | 602 | `vmonto_udi = pmnyimporte / vprecio_udi` | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s |
| BR-V2-7036 | FÓRMULA | REGULATORIO | 605 | `vmtopagosudi = vmtoacumcta / vprecio_udi` | SPEI Reglas técnicas — irrevocabilidad, clave rastreo, ventana 07:00-17:30, SLA < 20 s |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `spei` | PREFIJO | ALTA | familia SPEI (pagos interbancarios) |
| `recordenpago` | ACCION | ALTA | recibe orden de pago |
| `pago` | ENTIDAD | ALTA | pago |
| `orden` | ENTIDAD | ALTA | orden |
| `ordenpago` | ENTIDAD | ALTA | orden de pago |

---

## Nota de Migracion

Las 2 reglas con categoria REGULATORIO son las mas sensibles en la migracion y deben ser validadas por el SME de Industry Banking Accounting contra el CUB vigente.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
