# SP Profile: `sp_obtieneparametro`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 176 callers en produccion

---

## Historia Funcional

El SP `sp_obtieneparametro` implementa la logica de obtiene parámetro en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 760 lineas de codigo, 1 tablas consultadas. Es invocado por 176 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `sp_verificaconvenio`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtieneparametro.html](../../portal/sp-detail/sp-detail-sp_obtieneparametro.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **176** |
| Fan-out (callees) | **3** |
| Callees principales | `sp_verificaconvenio` |
| LOC | **760** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_obtieneparametro"]
    N1{"cast (siparametro as integer)= 0"}
    A --> N1
    N2{"cvalor in ('30802','30803'"}
    N1 --> N2
    N3["CALL: verifica convenio"]
    N2 --> N3
    Z["Salida"]
    N3 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D05 SAC / Transferencias
    participant SP as sp_obtieneparametro
    participant C1 as sp_verificaconvenio
    CL->>SP: invoca sp_obtieneparametro
    SP->>C1: delega a sp_verificaconvenio
    C1-->>SP: resultado
    Note over SP,CL: vocab: obtiene, param, parametro
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
| `param` | ENTIDAD | ALTA | parámetro |
| `parametro` | ENTIDAD | ALTA | parámetro |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
