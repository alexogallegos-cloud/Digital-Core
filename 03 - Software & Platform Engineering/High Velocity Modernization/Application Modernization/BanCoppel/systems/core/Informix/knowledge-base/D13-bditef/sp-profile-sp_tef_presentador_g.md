# SP Profile: `sp_tef_presentador_g`

> **Base de datos**: `bditef` · Dominio D13 — TEF / Nomina
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 34 callers en produccion

---

## Historia Funcional

El SP `sp_tef_presentador_g` implementa la logica de transferencia electrónica de fondos (presentado) en el dominio TEF / Nomina (base de datos `bditef`). Comprende 4,892 lineas de codigo, 12 tablas consultadas, 2 autores historicos. Es invocado por 34 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D13 | [../D13-bditef/07-dependencies.md](../D13-bditef/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_tef_presentador_g.html](../../portal/sp-detail/sp-detail-sp_tef_presentador_g.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **34** |
| Fan-out (callees) | **23** |
| Callees principales | — |
| LOC | **4,892** |
| Tablas consultadas | 12 |
| Reglas de negocio activas | **0** |
| Autores historicos | 2 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_tef_presentador_g\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    Z["Retorna resultado"]
    N1 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D13 TEF / Nomina
    participant SP as sp_tef_presentador_g
    CL->>SP: invoca sp_tef_presentador_g
    Note over SP,CL: vocab: tef, presentado, presenta
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `tef` | ENTIDAD | ALTA | TEF — transferencia electrónica de fondos |
| `presentado` | MODIF | ALTA | presentado (a cobro) |
| `presenta` | ACCION | ALTA | presenta |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?r_g`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
