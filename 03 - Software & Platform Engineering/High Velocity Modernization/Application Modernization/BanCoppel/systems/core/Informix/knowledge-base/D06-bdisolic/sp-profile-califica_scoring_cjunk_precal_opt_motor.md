# SP Profile: `califica_scoring_cjunk_precal_opt_motor`

> **Base de datos**: `bdisolic` · Dominio D06 — Solicitudes de Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `califica_scoring_cjunk_precal_opt_motor` implementa la logica de califica scoring crediticio y motor de decisión en el dominio Solicitudes de Credito (base de datos `bdisolic`). Comprende 2,278 lineas de codigo, 54 tablas consultadas, 5 autores historicos. Delega logica a: `bdisolic`, `bdimnsj`, `bdinteg`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D06 | [../D06-bdisolic/07-dependencies.md](../D06-bdisolic/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-califica_scoring_cjunk_precal_opt_motor.html](../../portal/sp-detail/sp-detail-califica_scoring_cjunk_precal_opt_motor.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **15** |
| Callees principales | `bdisolic`, `bdimnsj`, `bdinteg` |
| LOC | **2,278** |
| Tablas consultadas | 54 |
| Reglas de negocio activas | **0** |
| Autores historicos | 5 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: califica_scoring_cjunk_precal."]
    N1["CALL: solicitud"]
    A --> N1
    N2{"snum_producto ='7800'"}
    A --> N2
    N3{"o_ingreso  dmontomin"}
    N2 --> N3
    N4["CALL: bdimnsj"]
    N3 --> N4
    N5{"snum_producto ='6500'"}
    A --> N5
    N6{"v_cuantos is null or v_cuantos = 0."}
    N5 --> N6
    N7["CALL: interés"]
    N6 --> N7
    N8{"v_cuantos is null or v_cuantos = 0."}
    N5 --> N8
    N9["CALL: interés"]
    N8 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D06 Solicitudes de Credi.
    participant SP as califica_scoring_cjunk_prec.
    participant C1 as bdisolic
    participant C2 as bdimnsj
    participant C3 as bdinteg
    CL->>SP: invoca califica_scoring_cjunk_prec.
    SP->>C1: delega a bdisolic
    C1-->>SP: resultado
    SP->>C2: delega a bdimnsj
    C2-->>SP: resultado
    Note over SP,CL: vocab: califica, scoring, cjunk, motor
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `califica` | ACCION | ALTA | califica / evalúa (scoring) |
| `scoring` | ENTIDAD | ALTA | scoring crediticio |
| `cjunk` | AMBIGUO | AMBIGUA | variable temporal (ruido de código, se ignora) |
| `motor` | ENTIDAD | ALTA | motor de decisión |
| `calif` | ENTIDAD | MEDIA | calificación |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`cjunk`, `?_p`, `?al_opt_`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
