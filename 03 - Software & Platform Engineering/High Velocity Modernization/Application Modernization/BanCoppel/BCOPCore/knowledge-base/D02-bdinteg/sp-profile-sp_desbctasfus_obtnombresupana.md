# SP Profile: `sp_desbctasfus_obtnombresupana`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 214 callers en produccion

---

## Historia Funcional

El SP `sp_desbctasfus_obtnombresupana` implementa la logica de desbloqueo cuentas y nombre en el dominio Integracion Core (base de datos `bdinteg`). Comprende 1,882 lineas de codigo, 1 tablas consultadas. Es invocado por 214 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_desbctasfus_obtnombresupana.html](../../portal/sp-detail/sp-detail-sp_desbctasfus_obtnombresupana.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **214** |
| Fan-out (callees) | **4** |
| Callees principales | — |
| LOC | **1,882** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_desbctasfus_obtnombresupana"]
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
    participant CL as D02 Integracion Core
    participant SP as sp_desbctasfus_obtnombresup.
    CL->>SP: invoca sp_desbctasfus_obtnombresup.
    Note over SP,CL: vocab: ctas, nombre, desb
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `ctas` | ENTIDAD | ALTA | cuentas |
| `nombre` | ENTIDAD | ALTA | nombre |
| `desb` | ACCION | MEDIA | desbloqueo |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?supana`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
