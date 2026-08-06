# SP Profile: `sp_fal_busca_documentos_faltantes`

> **Base de datos**: `bdiaclaracion` · Dominio D07 — Aclaraciones
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_fal_busca_documentos_faltantes` implementa la logica de busca documentos (faltantes) en el dominio Aclaraciones (base de datos `bdiaclaracion`). Comprende 12,110 lineas de codigo, 1 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D07 | [../D07-bdiaclaracion/07-dependencies.md](../D07-bdiaclaracion/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_fal_busca_documentos_faltantes.html](../../portal/sp-detail/sp-detail-sp_fal_busca_documentos_faltantes.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **20** |
| Callees principales | — |
| LOC | **12,110** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_fal_busca_documentos_falta."]
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
    participant CL as D07 Aclaraciones
    participant SP as sp_fal_busca_documentos_fal.
    CL->>SP: invoca sp_fal_busca_documentos_fal.
    Note over SP,CL: vocab: fal, busca, documentos, faltantes
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `fal` | ENTIDAD | ALTA | fal — fallo/disputa (prefijo sp_fal_* — aclaraciones bancarias — bdiaclaracion) |
| `busca` | ACCION | ALTA | busca / localiza |
| `documentos` | ENTIDAD | ALTA | documentos |
| `faltantes` | MODIF | ALTA | faltantes |
| `alta` | ACCION | ALTA | da de alta / registra |
| `documento` | ENTIDAD | ALTA | documento |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
