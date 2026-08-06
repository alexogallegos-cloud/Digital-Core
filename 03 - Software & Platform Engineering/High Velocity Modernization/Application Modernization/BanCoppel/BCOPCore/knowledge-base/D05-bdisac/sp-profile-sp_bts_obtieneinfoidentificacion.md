# SP Profile: `sp_bts_obtieneinfoidentificacion`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 152 callers en produccion

---

## Historia Funcional

El SP `sp_bts_obtieneinfoidentificacion` implementa la logica de obtiene beneficiarios, información y identificación en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 1,303 lineas de codigo, 1 tablas consultadas. Es invocado por 152 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_bts_obtieneinfoidentificacion.html](../../portal/sp-detail/sp-detail-sp_bts_obtieneinfoidentificacion.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **152** |
| Fan-out (callees) | **2** |
| Callees principales | — |
| LOC | **1,303** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_bts_obtieneinfoidentificac."]
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
    participant CL as D05 SAC / Transferencias
    participant SP as sp_bts_obtieneinfoidentific.
    CL->>SP: invoca sp_bts_obtieneinfoidentific.
    Note over SP,CL: vocab: bts, obtiene, info, identificacion
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `bts` | ENTIDAD | ALTA | Bancomer Transfer Services — canal de transferencias BBVA; base de datos propia bdibts; confirmado por SME (2026-08-02) |
| `obtiene` | ACCION | ALTA | obtiene / recupera |
| `info` | ENTIDAD | ALTA | información |
| `identificacion` | ENTIDAD | ALTA | identificación |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
