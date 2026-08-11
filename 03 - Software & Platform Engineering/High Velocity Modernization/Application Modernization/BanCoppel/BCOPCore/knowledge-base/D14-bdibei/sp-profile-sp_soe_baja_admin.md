# SP Profile: `sp_soe_baja_admin`

> **Base de datos**: `bdibei` · Dominio D14 — BEI / Banca Empresarial
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_soe_baja_admin` implementa la logica de Soporte Operativo EmpresaNet; confirmado por SME y Administrador (de baja) en el dominio BEI / Banca Empresarial (base de datos `bdibei`). Comprende 1,751 lineas de codigo, 4 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D14 | [../D14-bdibei/07-dependencies.md](../D14-bdibei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_soe_baja_admin.html](../../portal/sp-detail/sp-detail-sp_soe_baja_admin.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **7** |
| Callees principales | — |
| LOC | **1,751** |
| Tablas consultadas | 4 |
| Reglas de negocio activas | **4** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_soe_baja_admin\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-0263 · BR-V2-0264 +2 reglas"]
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
    participant SP as sp_soe_baja_admin
    CL->>SP: invoca sp_soe_baja_admin
    Note over SP: BR-V2-0263 OPERACIONAL: Error en la ejecucion del sp sp_soe_obtenertoken
    Note over SP: BR-V2-0264 OPERACIONAL: Error en la ejecucion del sp sp_soe_set_solicitud.
    Note over SP: BR-V2-0265 OPERACIONAL: Error en la ejecucion del sp sp_soe_cancelartoken
    Note over SP: BR-V2-0266 OPERACIONAL: Error en la ejecucion del sp sp_soe_set_statustok.
    Note over SP,CL: vocab: soe, baja, admin
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0263 | VALIDACIÓN | OPERACIONAL | 88 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0264 | VALIDACIÓN | OPERACIONAL | 105 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0265 | VALIDACIÓN | OPERACIONAL | 119 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0266 | VALIDACIÓN | OPERACIONAL | 133 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `soe` | ENTIDAD | ALTA | SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorge Isaac Díaz, 2026-07-09) |
| `baja` | MODIF | ALTA | de baja |
| `admin` | ENTIDAD | ALTA | Administrador — rol de usuario con privilegios administrativos (pIdAdmin INTEGER en bdibei/bdibpi); también administración de tasas y procesos |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
