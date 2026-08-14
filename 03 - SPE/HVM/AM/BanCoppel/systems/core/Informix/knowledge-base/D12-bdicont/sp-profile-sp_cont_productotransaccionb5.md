# SP Profile: `sp_cont_productotransaccionb5`

> **Base de datos**: `bdicont` · Dominio D12 — Contabilidad
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_cont_productotransaccionb5` implementa la logica de producto-transacción en el dominio Contabilidad (base de datos `bdicont`). Comprende 3,990 lineas de codigo. Delega logica a: `bdicnweb`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D12 | [../D12-bdicont/07-dependencies.md](../D12-bdicont/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_cont_productotransaccionb5.html](../../portal/sp-detail/sp-detail-sp_cont_productotransaccionb5.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **72** |
| Callees principales | `bdicnweb` |
| LOC | **3,990** |
| Tablas consultadas | 0 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_cont_productotransaccionb5"]
    N1{"pbandera = '1'"}
    A --> N1
    N2["CALL: (canal web)"]
    N1 --> N2
    N3["CALL: (canal web)"]
    N1 --> N3
    N4(["Iteracion"])
    N1 --> N4
    N5["CALL: (canal web)"]
    N4 --> N5
    N6["CALL: (canal web)"]
    N1 --> N6
    N7(["Iteracion"])
    N1 --> N7
    N8["CALL: (canal web)"]
    N7 --> N8
    N9(["Iteracion"])
    N1 --> N9
    Z["Salida"]
    N9 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D12 Contabilidad
    participant SP as sp_cont_productotransaccion.
    participant C1 as bdicnweb
    CL->>SP: invoca sp_cont_productotransaccion.
    SP->>C1: delega a bdicnweb
    C1-->>SP: resultado
    Note over SP,CL: vocab: cont, producto, transaccion, prod
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `cont` | PREFIJO | ALTA | familia contabilidad |
| `producto` | ENTIDAD | ALTA | producto |
| `transaccion` | ENTIDAD | ALTA | transacción |
| `prod` | ENTIDAD | MEDIA | producto |
| `trans` | ENTIDAD | ALTA | [polisemia] Transferencia (bditransfer, bditrans: transferencias y remesas con campos pbco_dest/ppais_dest) | Transacción (sufijo genérico en SPs de reversión y procesamiento) |
| `transacc` | ENTIDAD | ALTA | código de transacción |
| `productotransaccion` | ENTIDAD | ALTA | producto-transacción |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
