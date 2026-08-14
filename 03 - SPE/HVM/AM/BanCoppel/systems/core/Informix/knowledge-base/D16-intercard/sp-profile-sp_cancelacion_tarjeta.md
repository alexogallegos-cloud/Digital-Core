# SP Profile: `sp_cancelacion_tarjeta`

> **Base de datos**: `intercard` · Dominio D16 — Intercard
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 28 callers en produccion

---

## Historia Funcional

El SP `sp_cancelacion_tarjeta` implementa la logica de cancela tarjeta de débito o crédito del cliente en el dominio Intercard (base de datos `intercard`). Comprende 57 lineas de codigo, 3 tablas consultadas. Es invocado por 28 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Indice regulatorio | [../cross-reference/regulatory-sp-index.md](../cross-reference/regulatory-sp-index.md) |
| Dependencias del dominio D16 | [../D16-intercard/07-dependencies.md](../D16-intercard/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_cancelacion_tarjeta.html](../../portal/sp-detail/sp-detail-sp_cancelacion_tarjeta.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **28** |
| Fan-out (callees) | **0** |
| Callees principales | — |
| LOC | **57** |
| Tablas consultadas | 3 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_cancelacion_tarjeta\nRecibe parámetros de entrada"]
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
    participant SP as sp_cancelacion_tarjeta
    CL->>SP: invoca sp_cancelacion_tarjeta
    Note over SP,CL: vocab: cancelacion, tarjeta, cancela
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cancelacion` | ACCION | ALTA | cancela |
| `tarjeta` | ENTIDAD | ALTA | tarjeta |
| `cancela` | ACCION | ALTA | cancela |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
