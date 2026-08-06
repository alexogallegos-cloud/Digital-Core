# SP Profile: `sp_consultacredbloqfallecimiento`

> **Base de datos**: `bdicred` · Dominio D03 — Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 248 callers en produccion

---

## Historia Funcional

El SP `sp_consultacredbloqfallecimiento` implementa la logica de consulta crédito (por fallecimiento) en el dominio Credito (base de datos `bdicred`). Comprende 2,378 lineas de codigo, 5 tablas consultadas. Es invocado por 248 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D03 | [../D03-bdicred/07-dependencies.md](../D03-bdicred/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_consultacredbloqfallecimiento.html](../../portal/sp-detail/sp-detail-sp_consultacredbloqfallecimiento.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **248** |
| Fan-out (callees) | **3** |
| Callees principales | — |
| LOC | **2,378** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **3** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_consultacredbloqfallecimie."]
    B["Proceso principal"]
    A --> B
    Y["Aplica reglas (3 reglas)"]
    B --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D03 Credito
    participant SP as sp_consultacredbloqfallecim.
    CL->>SP: invoca sp_consultacredbloqfallecim.
    Note over SP: BR-V2-4481 PARAMETRIA: -control de errores en caso que no se proporcione.
    Note over SP: BR-V2-4482 PARAMETRIA: Retorna código de error 433
    Note over SP: BR-V2-4483 PARAMETRIA: Retorna código de error 432
    Note over SP,CL: vocab: consulta, cons, cred, bloq
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-4481 | VALIDACIÓN | PARAMETRIA | 86 | `LET cCodret = '110'` | — |
| BR-V2-4482 | VALIDACIÓN | PARAMETRIA | 148 | `LET cCodret = '433'` | — |
| BR-V2-4483 | VALIDACIÓN | PARAMETRIA | 169 | `LET cCodret= '432'` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `consulta` | ACCION | ALTA | consulta / lee |
| `cons` | ACCION | ALTA | consulta |
| `cred` | ENTIDAD | ALTA | crédito |
| `bloq` | ACCION | MEDIA | bloqueo |
| `fallecimiento` | MODIF | ALTA | por fallecimiento |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
