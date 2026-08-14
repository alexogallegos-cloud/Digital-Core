# SP Profile: `sp_obtienecompingresos_mc`

> **Base de datos**: `bdisolic` · Dominio D06 — Solicitudes de Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 139 callers en produccion

---

## Historia Funcional

El SP `sp_obtienecompingresos_mc` implementa la logica de obtiene ingreso (complemento) en el dominio Solicitudes de Credito (base de datos `bdisolic`). Comprende 45 lineas de codigo, 1 tablas consultadas. Es invocado por 139 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D06 | [../D06-bdisolic/07-dependencies.md](../D06-bdisolic/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtienecompingresos_mc.html](../../portal/sp-detail/sp-detail-sp_obtienecompingresos_mc.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **139** |
| Fan-out (callees) | **139** |
| Callees principales | — |
| LOC | **45** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obtienecompingresos_mc"]
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
    participant CL as D06 Solicitudes de Credi.
    participant SP as sp_obtienecompingresos_mc
    CL->>SP: invoca sp_obtienecompingresos_mc
    Note over SP,CL: vocab: obtiene, comp, ingreso
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `obtiene` | ACCION | ALTA | obtiene / recupera |
| `comp` | MODIF | ALTA | complemento |
| `ingreso` | ENTIDAD | ALTA | ingreso (del solicitante) |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?s_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
