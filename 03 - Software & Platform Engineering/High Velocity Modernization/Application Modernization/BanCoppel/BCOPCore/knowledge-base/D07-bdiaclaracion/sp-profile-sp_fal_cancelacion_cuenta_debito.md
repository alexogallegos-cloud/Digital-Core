# SP Profile: `sp_fal_cancelacion_cuenta_debito`

> **Base de datos**: `bdiaclaracion` · Dominio D07 — Aclaraciones
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 40 callers en produccion

---

## Historia Funcional

El SP `sp_fal_cancelacion_cuenta_debito` implementa la logica de cancela cuenta (débito) en el dominio Aclaraciones (base de datos `bdiaclaracion`). Comprende 11,516 lineas de codigo, 3 tablas consultadas. Es invocado por 40 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdicheq`, `bdibpi`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D07 | [../D07-bdiaclaracion/07-dependencies.md](../D07-bdiaclaracion/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_fal_cancelacion_cuenta_debito.html](../../portal/sp-detail/sp-detail-sp_fal_cancelacion_cuenta_debito.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **40** |
| Fan-out (callees) | **20** |
| Callees principales | `bdicheq`, `bdibpi` |
| LOC | **11,516** |
| Tablas consultadas | 3 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_fal_cancelacion_cuenta_deb."]
    N1{"saldo_actual_cuenta = 0"}
    A --> N1
    N2{"resultado_estatus != 1"}
    N1 --> N2
    N3["CALL: bdicheq"]
    N2 --> N3
    N4(["Iteracion"])
    N1 --> N4
    N5["CALL: bdicheq"]
    N4 --> N5
    N6["CALL: (Banca Por Internet)"]
    N1 --> N6
    N7["CALL: bdicheq"]
    N1 --> N7
    N8{"coderet = '069'"}
    N1 --> N8
    N9["CALL: bdicheq"]
    N8 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D07 Aclaraciones
    participant SP as sp_fal_cancelacion_cuenta_d.
    participant C1 as bdicheq
    participant C2 as bdibpi
    CL->>SP: invoca sp_fal_cancelacion_cuenta_d.
    SP->>C1: delega a bdicheq
    C1-->>SP: resultado
    SP->>C2: delega a bdibpi
    C2-->>SP: resultado
    Note over SP,CL: vocab: fal, cancelacion, cuenta, debito
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
| `cancelacion` | ACCION | ALTA | cancela |
| `cuenta` | ENTIDAD | ALTA | cuenta |
| `debito` | ENTIDAD | ALTA | débito |
| `cancela` | ACCION | ALTA | cancela |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
