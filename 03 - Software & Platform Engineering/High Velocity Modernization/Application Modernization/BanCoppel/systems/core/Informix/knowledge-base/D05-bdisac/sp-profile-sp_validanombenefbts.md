# SP Profile: `sp_validanombenefbts`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 243 callers en produccion

---

## Historia Funcional

El SP `sp_validanombenefbts` implementa la logica de valida nómina, beneficiario y beneficiarios en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 511 lineas de codigo, 1 tablas consultadas. Es invocado por 243 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `sp_comparacaracteresbts`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_validanombenefbts.html](../../portal/sp-detail/sp-detail-sp_validanombenefbts.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **243** |
| Fan-out (callees) | **3** |
| Callees principales | `sp_comparacaracteresbts` |
| LOC | **511** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_validanombenefbts"]
    N1{"nvl(papematbts,'')  '' and nvl(p."}
    A --> N1
    N2["CALL: actualiza beneficiarios (complemen."]
    N1 --> N2
    Z["Salida"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D05 SAC / Transferencias
    participant SP as sp_validanombenefbts
    participant C1 as sp_comparacaracteresbts
    CL->>SP: invoca sp_validanombenefbts
    SP->>C1: delega a sp_comparacaracteresbts
    C1-->>SP: resultado
    Note over SP,CL: vocab: valida, benef, valid
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `valida` | ACCION | ALTA | valida |
| `benef` | ENTIDAD | ALTA | beneficiario |
| `valid` | ACCION | MEDIA | valida |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
