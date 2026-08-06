# SP Profile: `sp_consulta_sdo_apoyo`

> **Base de datos**: `bdicred` · Dominio D03 — Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 203 callers en produccion

---

## Historia Funcional

El SP `sp_consulta_sdo_apoyo` implementa la logica de consulta saldo en el dominio Credito (base de datos `bdicred`). Comprende 1,030 lineas de codigo, 3 tablas consultadas. Es invocado por 203 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D03 | [../D03-bdicred/07-dependencies.md](../D03-bdicred/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_consulta_sdo_apoyo.html](../../portal/sp-detail/sp-detail-sp_consulta_sdo_apoyo.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **203** |
| Fan-out (callees) | **4** |
| Callees principales | — |
| LOC | **1,030** |
| Tablas consultadas | 3 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_consulta_sdo_apoyo"]
    B["Proceso principal"]
    A --> B
    Z["Salida"]
    B --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D03 Credito
    participant SP as sp_consulta_sdo_apoyo
    CL->>SP: invoca sp_consulta_sdo_apoyo
    Note over SP,CL: vocab: consulta, sdo, cons
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `consulta` | ACCION | ALTA | consulta / lee |
| `sdo` | ENTIDAD | ALTA | saldo |
| `cons` | ACCION | ALTA | consulta |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_apoyo`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
