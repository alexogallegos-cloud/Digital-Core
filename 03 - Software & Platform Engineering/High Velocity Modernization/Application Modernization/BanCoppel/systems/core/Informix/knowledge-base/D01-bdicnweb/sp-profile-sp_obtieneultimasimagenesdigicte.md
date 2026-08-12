# SP Profile: `sp_obtieneultimasimagenesdigicte`

> **Base de datos**: `bdicnweb` · Dominio D01 — Canal Digital Web
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_obtieneultimasimagenesdigicte` implementa la logica de obtiene imágenes y cliente (últimas) en el dominio Canal Digital Web (base de datos `bdicnweb`). Comprende 49,331 lineas de codigo. Delega logica a: `bdinteg`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D01 | [../D01-bdicnweb/07-dependencies.md](../D01-bdicnweb/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtieneultimasimagenesdigicte.html](../../portal/sp-detail/sp-detail-sp_obtieneultimasimagenesdigicte.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **124** |
| Callees principales | `bdinteg` |
| LOC | **49,331** |
| Tablas consultadas | 0 |
| Reglas de negocio activas | **1** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obtieneultimasimagenesdigi."]
    N1["CALL: interés"]
    A --> N1
    N2["CALL: interés"]
    A --> N2
    Y["Aplica reglas (1 reglas)"]
    N2 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D01 Canal Digital Web
    participant SP as sp_obtieneultimasimagenesdi.
    participant C1 as bdinteg
    CL->>SP: invoca sp_obtieneultimasimagenesdi.
    SP->>C1: delega a bdinteg
    C1-->>SP: resultado
    Note over SP: BR-V2-2843 PARAMETRIA: Error en la ejecucion del sp sp_obtiene_ultimas_i.
    Note over SP,CL: vocab: obtiene, imagen, imagenes, digi
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-2843 | VALIDACIÓN | PARAMETRIA | 68 | `RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP ` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `obtiene` | ACCION | ALTA | obtiene / recupera |
| `imagen` | ENTIDAD | ALTA | imagen digital |
| `imagenes` | ENTIDAD | ALTA | imágenes / documentos digitales |
| `digi` | ACCION | MEDIA | digitalización |
| `ultimas` | MODIF | MEDIA | últimas |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
