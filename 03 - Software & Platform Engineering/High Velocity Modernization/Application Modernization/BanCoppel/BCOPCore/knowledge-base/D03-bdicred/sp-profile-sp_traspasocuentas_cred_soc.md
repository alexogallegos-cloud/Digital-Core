# SP Profile: `sp_traspasocuentas_cred_soc`

> **Base de datos**: `bdicred` · Dominio D03 — Credito
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 238 callers en produccion

---

## Historia Funcional

El SP `sp_traspasocuentas_cred_soc` implementa la logica de traspaso entre cuentas cuenta, crédito y Sistema Operativo Central en el dominio Credito (base de datos `bdicred`). Comprende 1,021 lineas de codigo, 46 tablas consultadas. Es invocado por 238 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `bdicred`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D03 | [../D03-bdicred/07-dependencies.md](../D03-bdicred/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_traspasocuentas_cred_soc.html](../../portal/sp-detail/sp-detail-sp_traspasocuentas_cred_soc.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **238** |
| Fan-out (callees) | **2** |
| Callees principales | `bdicred` |
| LOC | **1,021** |
| Tablas consultadas | 46 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_traspasocuentas_cred_soc"]
    N1["CALL: bdicred"]
    A --> N1
    Z["Salida"]
    N1 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D03 Credito
    participant SP as sp_traspasocuentas_cred_soc
    participant C1 as bdicred
    CL->>SP: invoca sp_traspasocuentas_cred_soc
    SP->>C1: delega a bdicred
    C1-->>SP: resultado
    Note over SP,CL: vocab: cred, soc, cuenta, cuentas
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cred` | ENTIDAD | ALTA | crédito |
| `soc` | ENTIDAD | ALTA | Sistema Operativo Central (SOC) — confirmado SME |
| `cuenta` | ENTIDAD | ALTA | cuenta |
| `cuentas` | ENTIDAD | ALTA | cuentas (plural) |
| `traspaso` | ACCION | ALTA | traspaso entre cuentas |
| `traspas` | ACCION | MEDIA | traspaso |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
