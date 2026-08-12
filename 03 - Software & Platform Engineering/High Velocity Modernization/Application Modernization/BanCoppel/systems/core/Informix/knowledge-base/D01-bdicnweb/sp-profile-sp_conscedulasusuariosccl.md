# SP Profile: `sp_conscedulasusuariosccl`

> **Base de datos**: `bdicnweb` · Dominio D01 — Canal Digital Web
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_conscedulasusuariosccl` implementa la logica de consulta cédulas usuarios en el dominio Canal Digital Web (base de datos `bdicnweb`). Comprende 50,344 lineas de codigo, 1 tablas consultadas. Delega logica a: `bdinteg`, `bdicnweb`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D01 | [../D01-bdicnweb/07-dependencies.md](../D01-bdicnweb/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_conscedulasusuariosccl.html](../../portal/sp-detail/sp-detail-sp_conscedulasusuariosccl.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **124** |
| Callees principales | `bdinteg`, `bdicnweb` |
| LOC | **50,344** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **1** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_conscedulasusuariosccl"]
    N1["CALL: interés"]
    A --> N1
    N2(["Iteracion"])
    A --> N2
    N3["CALL: (canal web)"]
    N2 --> N3
    Y["Aplica reglas (1 reglas)"]
    N3 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D01 Canal Digital Web
    participant SP as sp_conscedulasusuariosccl
    participant C1 as bdinteg
    participant C2 as bdicnweb
    CL->>SP: invoca sp_conscedulasusuariosccl
    SP->>C1: delega a bdinteg
    C1-->>SP: resultado
    SP->>C2: delega a bdicnweb
    C2-->>SP: resultado
    Note over SP: BR-V2-2184 PARAMETRIA: Error en la ejecucion del sp bdicnweb:sp_usuarios.
    Note over SP,CL: vocab: usuario, cons, usuarios, cedula
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-2184 | VALIDACIÓN | PARAMETRIA | 63 | `RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP ` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `usuario` | ENTIDAD | ALTA | usuario |
| `cons` | ACCION | ALTA | consulta |
| `usuarios` | ENTIDAD | ALTA | usuarios |
| `cedula` | ENTIDAD | ALTA | cédula de identificación |
| `cedulas` | ENTIDAD | ALTA | cédulas |
| `conscedulas` | ACCION | ALTA | consulta cédulas |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
