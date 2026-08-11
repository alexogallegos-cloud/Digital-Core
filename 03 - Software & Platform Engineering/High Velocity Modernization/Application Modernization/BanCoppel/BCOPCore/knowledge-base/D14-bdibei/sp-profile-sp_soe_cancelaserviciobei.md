# SP Profile: `sp_soe_cancelaserviciobei`

> **Base de datos**: `bdibei` · Dominio D14 — BEI / Banca Empresarial
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_soe_cancelaserviciobei` implementa la logica de cancela Soporte Operativo EmpresaNet; confirmado por SME, servicio y Banca En Internet; canal digital principal de BanCoppel; base de datos bdibei con 279+ SPs de operaciones, autenticación, transferencias y mancomunidad en el dominio BEI / Banca Empresarial (base de datos `bdibei`). Comprende 1,595 lineas de codigo, 7 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D14 | [../D14-bdibei/07-dependencies.md](../D14-bdibei/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_soe_cancelaserviciobei.html](../../portal/sp-detail/sp-detail-sp_soe_cancelaserviciobei.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **6** |
| Callees principales | — |
| LOC | **1,595** |
| Tablas consultadas | 7 |
| Reglas de negocio activas | **4** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_soe_cancelaserviciobei\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-0267 · BR-V2-0268 +2 reglas"]
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
    participant SP as sp_soe_cancelaserviciobei
    CL->>SP: invoca sp_soe_cancelaserviciobei
    Note over SP: BR-V2-0267 OPERACIONAL: Error en la ejecucion del sp sp_soe_obtstatus_can.
    Note over SP: BR-V2-0268 OPERACIONAL: Error en la ejecucion del sp sp_soe_set_solicitud.
    Note over SP: BR-V2-0269 OPERACIONAL: Error en la ejecucion del sp sp_soe_cancelartoken
    Note over SP: BR-V2-0270 OPERACIONAL: Error en la ejecucion del sp sp_soe_set_statustok.
    Note over SP,CL: vocab: soe, cancela, servicio, canc
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-0267 | VALIDACIÓN | OPERACIONAL | 77 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0268 | VALIDACIÓN | OPERACIONAL | 158 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0269 | VALIDACIÓN | OPERACIONAL | 183 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |
| BR-V2-0270 | VALIDACIÓN | OPERACIONAL | 210 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `soe` | ENTIDAD | ALTA | SOE — Soporte Operativo EmpresaNet; confirmado por SME (Jorge Isaac Díaz, 2026-07-09) |
| `cancela` | ACCION | ALTA | cancela |
| `servicio` | ENTIDAD | ALTA | servicio |
| `canc` | ABREVIATURA | MEDIA | cancelación |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
