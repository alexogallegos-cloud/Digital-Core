# SP Profile: `spei_recextemporanea`

> **Base de datos**: `bdispei` · Dominio D08 — SPEI / CoDi
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 2 callers en produccion

---

## Historia Funcional

El SP `spei_recextemporanea` implementa la logica de recibe orden extemporánea en el dominio SPEI / CoDi (base de datos `bdispei`). Comprende 3,733 lineas de codigo, 8 tablas consultadas. Es invocado por 2 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdicheq`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D08 | [../D08-bdispei/07-dependencies.md](../D08-bdispei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-spei_recextemporanea.html](../../portal/sp-detail/sp-detail-spei_recextemporanea.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **2** |
| Fan-out (callees) | **14** |
| Callees principales | `bdicheq` |
| LOC | **3,733** |
| Tablas consultadas | 8 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: spei_recextemporanea"]
    N1{"codretfirma = 0"}
    A --> N1
    N2["CALL: bdicheq"]
    N1 --> N2
    N3(["Mientras: icodret  0 and ivueltas = 3"])
    N1 --> N3
    N4["CALL: bdicheq"]
    N3 --> N4
    N5{"icodret = 0"}
    N1 --> N5
    N6["CALL: bdicheq"]
    N5 --> N6
    Z["Salida"]
    N6 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D08 SPEI / CoDi
    participant SP as spei_recextemporanea
    participant C1 as bdicheq
    CL->>SP: invoca spei_recextemporanea
    SP->>C1: delega a bdicheq
    C1-->>SP: resultado
    Note over SP,CL: vocab: spei, recextemporanea, temp, extemporanea
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
| `recextemporanea` | ACCION | ALTA | recibe orden extemporánea |
| `temp` | MODIF | ALTA | temporal |
| `extemporanea` | MODIF | ALTA | extemporánea |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
