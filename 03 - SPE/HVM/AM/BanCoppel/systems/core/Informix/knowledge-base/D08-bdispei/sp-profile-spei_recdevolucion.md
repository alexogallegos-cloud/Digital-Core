# SP Profile: `spei_recdevolucion`

> **Base de datos**: `bdispei` · Dominio D08 — SPEI / CoDi
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 2 callers en produccion

---

## Historia Funcional

El SP `spei_recdevolucion` implementa la logica de recibe devolución en el dominio SPEI / CoDi (base de datos `bdispei`). Comprende 3,954 lineas de codigo, 5 tablas consultadas. Es invocado por 2 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `sp_obtfoliosuc`, `bdicheq`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D08 | [../D08-bdispei/07-dependencies.md](../D08-bdispei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-spei_recdevolucion.html](../../portal/sp-detail/sp-detail-spei_recdevolucion.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **2** |
| Fan-out (callees) | **14** |
| Callees principales | `sp_obtfoliosuc`, `bdicheq` |
| LOC | **3,954** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: spei_recdevolucion"]
    N1{"codretfirma = 0"}
    A --> N1
    N2["CALL: obtiene folio (sucursal)"]
    N1 --> N2
    N3["CALL: bdicheq"]
    N1 --> N3
    Z["Salida"]
    N3 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D08 SPEI / CoDi
    participant SP as spei_recdevolucion
    participant C1 as sp_obtfoliosuc
    participant C2 as bdicheq
    CL->>SP: invoca spei_recdevolucion
    SP->>C1: delega a sp_obtfoliosuc
    C1-->>SP: resultado
    SP->>C2: delega a bdicheq
    C2-->>SP: resultado
    Note over SP,CL: vocab: spei, recdevolucion, devolucion
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
| `recdevolucion` | ACCION | ALTA | recibe devolución |
| `devolucion` | ACCION | ALTA | devuelve |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
