# SP Profile: `sp_horasazules_obtener_tdc_clientes`

> **Base de datos**: `intercard` · Dominio D16 — Intercard
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_horasazules_obtener_tdc_clientes` implementa la logica de obtiene tarjetas de crédito activas de clientes para el programa de lealtad Horas Azules en el dominio Intercard (base de datos `intercard`). Comprende 1,333 lineas de codigo, 9 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D16 | [../D16-intercard/07-dependencies.md](../D16-intercard/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_horasazules_obtener_tdc_clientes.html](../../portal/sp-detail/sp-detail-sp_horasazules_obtener_tdc_clientes.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **2** |
| Callees principales | — |
| LOC | **1,333** |
| Tablas consultadas | 9 |
| Reglas de negocio activas | **0** |
| Autores historicos | 1 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_horasazules_obtener_tdc_client.\nRecibe parámetros de entrada"]
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
    participant CL as D16 Intercard
    participant SP as sp_horasazules_obtener_tdc_.
    CL->>SP: invoca sp_horasazules_obtener_tdc_.
    Note over SP,CL: vocab: obtener, tdc, clientes, cliente
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `obtener` | ACCION | ALTA | obtiene / recupera |
| `tdc` | ENTIDAD | ALTA | tarjeta de crédito (TDC) |
| `clientes` | ENTIDAD | ALTA | clientes (plural) |
| `cliente` | ENTIDAD | ALTA | cliente |
| `obten` | ACCION | ALTA | obtiene / recupera |
| `hora` | ENTIDAD | ALTA | hora |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?sazules_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
