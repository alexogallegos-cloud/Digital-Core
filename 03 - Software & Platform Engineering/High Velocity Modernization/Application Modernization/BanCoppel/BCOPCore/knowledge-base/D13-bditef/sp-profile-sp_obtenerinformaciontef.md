# SP Profile: `sp_obtenerinformaciontef`

> **Base de datos**: `bditef` · Dominio D13 — TEF / Nomina
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_obtenerinformaciontef` implementa la logica de obtiene información, dirección MAC y transferencia electrónica de fondos en el dominio TEF / Nomina (base de datos `bditef`). Comprende 7,105 lineas de codigo, 9 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D13 | [../D13-bditef/07-dependencies.md](../D13-bditef/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtenerinformaciontef.html](../../portal/sp-detail/sp-detail-sp_obtenerinformaciontef.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **25** |
| Callees principales | — |
| LOC | **7,105** |
| Tablas consultadas | 9 |
| Reglas de negocio activas | **1** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_obtenerinformaciontef\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-7244: Cálculo con umbral/factor 01"]
    N1 --> N2
    Z["Retorna resultado"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D13 TEF / Nomina
    participant SP as sp_obtenerinformaciontef
    CL->>SP: invoca sp_obtenerinformaciontef
    Note over SP: BR-V2-7244 CALCULO_FINANCIERO: Cálculo con umbral/factor 01
    Note over SP,CL: vocab: info, obtener, obten, forma
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-7244 | FÓRMULA | CALCULO_FINANCIERO | 68 | `dFechaInicial = "01/01/1900"` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `info` | ENTIDAD | ALTA | información |
| `obtener` | ACCION | ALTA | obtiene / recupera |
| `obten` | ACCION | ALTA | obtiene / recupera |
| `forma` | ACCION | MEDIA | construye / arma |
| `inform` | ABREVIATURA | MEDIA | información |
| `informa` | ABREVIATURA | MEDIA | información |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?r`, `?ion`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
