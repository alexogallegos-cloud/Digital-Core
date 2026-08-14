# SP Profile: `sp_contacto_vencimiento_credito`

> **Base de datos**: `intercard` · Dominio D16 — Intercard
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_contacto_vencimiento_credito` implementa la logica de batch de contacto por vencimiento de crédito — actualiza fechas y envía notificaciones en el dominio Intercard (base de datos `intercard`). Comprende 1,011 lineas de codigo, 39 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D16 | [../D16-intercard/07-dependencies.md](../D16-intercard/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_contacto_vencimiento_credito.html](../../portal/sp-detail/sp-detail-sp_contacto_vencimiento_credito.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **2** |
| Callees principales | — |
| LOC | **1,011** |
| Tablas consultadas | 39 |
| Reglas de negocio activas | **4** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_contacto_vencimiento_credito\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-7523 · BR-V2-7524 +2 reglas"]
    N1 --> N2
    Z["Retorna resultado"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D16 Intercard
    participant SP as sp_contacto_vencimiento_cre.
    CL->>SP: invoca sp_contacto_vencimiento_cre.
    Note over SP: BR-V2-7523 CALCULO_FINANCIERO: Dbaccess intercard /resplogifx/vip_alta.sql
    Note over SP: BR-V2-7524 CALCULO_FINANCIERO: Dbaccess intercard /resplogifx/vip_credito1.sql
    Note over SP: BR-V2-7525 CALCULO_FINANCIERO: Dbaccess intercard /resplogifx/alta_transacc_cred.
    Note over SP: BR-V2-7526 CALCULO_FINANCIERO: Dbaccess intercard /resplogifx/vip_credito.sql
    Note over SP,CL: vocab: vencimiento, credito, cred, cont
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-7523 | FÓRMULA | CALCULO_FINANCIERO | 634 | `vsql = 'dbaccess intercard /resplogifx/vip_alta.sql'` | — |
| BR-V2-7524 | FÓRMULA | CALCULO_FINANCIERO | 668 | `vsql = 'dbaccess intercard /resplogifx/vip_credito1.sql'` | — |
| BR-V2-7525 | FÓRMULA | CALCULO_FINANCIERO | 693 | `vsql = 'dbaccess intercard /resplogifx/Alta_transacc_credito` | — |
| BR-V2-7526 | FÓRMULA | CALCULO_FINANCIERO | 773 | `vsql = 'dbaccess intercard /resplogifx/vip_credito.sql'` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `vencimiento` | ENTIDAD | ALTA | vencimiento |
| `credito` | ENTIDAD | ALTA | crédito |
| `cred` | ENTIDAD | ALTA | crédito |
| `cont` | PREFIJO | ALTA | familia contabilidad |
| `venc` | ENTIDAD | MEDIA | vencimiento |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?o_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
