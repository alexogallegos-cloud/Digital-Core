# SP Profile: `sp_dicta_modificaciondictamen`

> **Base de datos**: `bdinteg` · Dominio D02 — Integracion Core
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 196 callers en produccion

---

## Historia Funcional

El SP `sp_dicta_modificaciondictamen` implementa la logica de modificación dictamen en el dominio Integracion Core (base de datos `bdinteg`). Comprende 952 lineas de codigo, 2 tablas consultadas. Es invocado por 196 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D02 | [../D02-bdinteg/07-dependencies.md](../D02-bdinteg/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_dicta_modificaciondictamen.html](../../portal/sp-detail/sp-detail-sp_dicta_modificaciondictamen.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **196** |
| Fan-out (callees) | **2** |
| Callees principales | — |
| LOC | **952** |
| Tablas consultadas | 2 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_dicta_modificaciondictamen"]
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
    participant SP as sp_dicta_modificaciondictam.
    CL->>SP: invoca sp_dicta_modificaciondictam.
    Note over SP,CL: vocab: dicta, dictamen, modificacion, modifica
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `dicta` | ENTIDAD | MEDIA | dicta — dictamen / subsistema de dictaminación (sp_dicta_* — bdinteg fan_in=268+) |
| `dictamen` | ENTIDAD | ALTA | dictamen |
| `modificacion` | ACCION | ALTA | modificación |
| `modifica` | ACCION | ALTA | modifica |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
