# SP Profile: `sp_cargarreversarcuentatoken_bei`

> **Base de datos**: `bdibei` · Dominio D14 — BEI / Banca Empresarial
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_cargarreversarcuentatoken_bei` implementa la logica de carga cuenta, token y Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad en el dominio BEI / Banca Empresarial (base de datos `bdibei`). Comprende 237 lineas de codigo, 5 tablas consultadas, 2 autores historicos. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D14 | [../D14-bdibei/07-dependencies.md](../D14-bdibei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_cargarreversarcuentatoken_bei.html](../../portal/sp-detail/sp-detail-sp_cargarreversarcuentatoken_bei.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **5** |
| Callees principales | — |
| LOC | **237** |
| Tablas consultadas | 5 |
| Reglas de negocio activas | **1** |
| Autores historicos | 2 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_cargarreversarcuentatoken_bei\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-0248: mIva = pMonto * mIva"]
    N1 --> N2
    Z["Retorna resultado"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D14 BEI / Banca Empresar.
    participant SP as sp_cargarreversarcuentatoke.
    CL->>SP: invoca sp_cargarreversarcuentatoke.
    Note over SP,CL: vocab: bei, cuenta, carga, token
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0248 | FÓRMULA | CALCULO_FINANCIERO | 151 | `mIva = pMonto * mIva` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `bei` | ENTIDAD | ALTA | BEI — Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad |
| `cuenta` | ENTIDAD | ALTA | cuenta |
| `carga` | ACCION | ALTA | carga / ingresa |
| `token` | ENTIDAD | ALTA | token (autenticación) |
| `reversa` | ACCION | ALTA | Reversión — anula/revierte una operación (bdibei:sp_reversa_solicitudes_bei, sp_reversa_tokenasociados_bei) |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?r`, `?r`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
