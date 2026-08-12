# SP Profile: `sp_fustraspasotelefonos_soc`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 239 callers en produccion

---

## Historia Funcional

El SP `sp_fustraspasotelefonos_soc` implementa la logica de fusión de cuentas teléfonos y Sistema Operativo Central en el dominio Integracion Core (base de datos `bdinteg`). Comprende 1,693 lineas de codigo, 15 tablas consultadas. Es invocado por 239 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_fustraspasotelefonos_soc.html](../../portal/sp-detail/sp-detail-sp_fustraspasotelefonos_soc.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **239** |
| Fan-out (callees) | **239** |
| Callees principales | — |
| LOC | **1,693** |
| Tablas consultadas | 15 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_fustraspasotelefonos_soc"]
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
    participant SP as sp_fustraspasotelefonos_soc
    CL->>SP: invoca sp_fustraspasotelefonos_soc
    Note over SP,CL: vocab: soc, telefono, traspaso, telefonos
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `soc` | ENTIDAD | ALTA | Sistema Operativo Central (SOC) — confirmado SME |
| `telefono` | ENTIDAD | ALTA | teléfono |
| `traspaso` | ACCION | ALTA | traspaso entre cuentas |
| `telefonos` | ENTIDAD | ALTA | teléfonos |
| `traspas` | ACCION | MEDIA | traspaso |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
