# SP Profile: `sp_cilocgenerarpttotalmarcas`

> **Base de datos**: `bdicobranza` · Dominio D11 — Cobranza
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_cilocgenerarpttotalmarcas` implementa la logica de genera reporte y marcas de cuenta (total) en el dominio Cobranza (base de datos `bdicobranza`). Comprende 897 lineas de codigo, 1 tablas consultadas. Delega logica a: `bdinteg`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D11 | [../D11-bdicobranza/07-dependencies.md](../D11-bdicobranza/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_cilocgenerarpttotalmarcas.html](../../portal/sp-detail/sp-detail-sp_cilocgenerarpttotalmarcas.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **6** |
| Callees principales | `bdinteg` |
| LOC | **897** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_cilocgenerarpttotalmarcas"]
    N1{"ptipo = 2"}
    A --> N1
    N2{"length (pfechaini) = 7 and length ."}
    N1 --> N2
    N3["CALL: interés"]
    N2 --> N3
    N4["CALL: interés"]
    N2 --> N4
    N5{"length (pfechaini) = 7 and length ."}
    N1 --> N5
    N6["CALL: interés"]
    N5 --> N6
    N7["CALL: interés"]
    N5 --> N7
    Z["Salida"]
    N7 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D11 Cobranza
    participant SP as sp_cilocgenerarpttotalmarcas
    participant C1 as bdinteg
    CL->>SP: invoca sp_cilocgenerarpttotalmarcas
    SP->>C1: delega a bdinteg
    C1-->>SP: resultado
    Note over SP,CL: vocab: genera, generar, total, marca
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `genera` | ACCION | ALTA | genera / produce |
| `generar` | ACCION | MEDIA | generar (infinitivo — sp_generarbalanza*) |
| `total` | MODIF | ALTA | total |
| `marca` | ENTIDAD | ALTA | marca |
| `ciloc` | PREFIJO | MEDIA | consulta local de cobranza |
| `marcas` | ENTIDAD | ALTA | marcas de cuenta |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?pt`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
