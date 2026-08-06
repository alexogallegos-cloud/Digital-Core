# SP Profile: `sp_registra_evento`

> **Base de datos**: `bdimnsj` · Dominio D09 — Mensajeria
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 1404 callers en produccion

---

## Historia Funcional

El SP `sp_registra_evento` implementa la logica de registra evento/notificación en el dominio Mensajeria (base de datos `bdimnsj`). Comprende 446 lineas de codigo, 12 tablas consultadas, 14 autores historicos. Es invocado por 1404 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D09 | [../D09-bdimnsj/07-dependencies.md](../D09-bdimnsj/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_registra_evento.html](../../portal/sp-detail/sp-detail-sp_registra_evento.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **1404** |
| Fan-out (callees) | **1398** |
| Callees principales | — |
| LOC | **446** |
| Tablas consultadas | 12 |
| Reglas de negocio activas | **0** |
| Autores historicos | 14 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_registra_evento"]
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
    participant CL as D09 Mensajeria
    participant SP as sp_registra_evento
    CL->>SP: invoca sp_registra_evento
    Note over SP,CL: vocab: registra, evento
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `registra` | ACCION | ALTA | registra |
| `evento` | ENTIDAD | ALTA | evento/notificación |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
