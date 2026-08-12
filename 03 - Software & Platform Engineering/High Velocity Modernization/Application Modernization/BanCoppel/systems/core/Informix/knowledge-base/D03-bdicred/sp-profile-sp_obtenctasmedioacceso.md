# SP Profile: `sp_obtenctasmedioacceso`

> **Base de datos**: `bdicred` · Dominio D03 — Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 285 callers en produccion

---

## Historia Funcional

El SP `sp_obtenctasmedioacceso` implementa la logica de obtiene cuentas y medio de acceso en el dominio Credito (base de datos `bdicred`). Comprende 490 lineas de codigo, 5 tablas consultadas. Es invocado por 285 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D03 | [../D03-bdicred/07-dependencies.md](../D03-bdicred/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtenctasmedioacceso.html](../../portal/sp-detail/sp-detail-sp_obtenctasmedioacceso.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **285** |
| Fan-out (callees) | **285** |
| Callees principales | — |
| LOC | **490** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obtenctasmedioacceso"]
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
    participant CL as D03 Credito
    participant SP as sp_obtenctasmedioacceso
    CL->>SP: invoca sp_obtenctasmedioacceso
    Note over SP,CL: vocab: ctas, obten, acceso, medioacceso
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `ctas` | ENTIDAD | ALTA | cuentas |
| `obten` | ACCION | ALTA | obtiene / recupera |
| `acceso` | ENTIDAD | MEDIA | acceso |
| `medioacceso` | ENTIDAD | ALTA | medio de acceso |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
