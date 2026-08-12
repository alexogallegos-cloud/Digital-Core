# SP Profile: `sp_reportedesbloqueoctasmasivocre`

> **Base de datos**: `bdicnweb` · Dominio D01 — Canal Digital Web
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_reportedesbloqueoctasmasivocre` implementa la logica de desbloquea cuenta reporte, cuentas y crédito (masivo) en el dominio Canal Digital Web (base de datos `bdicnweb`). Comprende 49,456 lineas de codigo, 3 tablas consultadas. Delega logica a: `bdicnweb`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D01 | [../D01-bdicnweb/07-dependencies.md](../D01-bdicnweb/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_reportedesbloqueoctasmasivocre.html](../../portal/sp-detail/sp-detail-sp_reportedesbloqueoctasmasivocre.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **124** |
| Callees principales | `bdicnweb` |
| LOC | **49,456** |
| Tablas consultadas | 3 |
| Reglas de negocio activas | **2** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_reportedesbloqueoctasmasiv."]
    N1["CALL: (canal web)"]
    A --> N1
    Y["Aplica reglas (2 reglas)"]
    N1 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D01 Canal Digital Web
    participant SP as sp_reportedesbloqueoctasmas.
    participant C1 as bdicnweb
    CL->>SP: invoca sp_reportedesbloqueoctasmas.
    SP->>C1: delega a bdicnweb
    C1-->>SP: resultado
    Note over SP: BR-V2-3035 CALCULO_FINANCIERO: Fórmula: producto · ejecutivo · número de cliente
    Note over SP,CL: vocab: reporte, ctas, masivo, bloqueo
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-3035 | FÓRMULA | CALCULO_FINANCIERO | 97 | `cCmd3 = "lote, trim(numcte), trim(nombre_cliente), trim(num_` | — |
| BR-V2-3036 | VALIDACIÓN | CONTABILIDAD_REPORTES | 104 | `RAISE EXCEPTION cCodRetSp::INTEGER, 0, ''` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `reporte` | ENTIDAD | ALTA | reporte |
| `ctas` | ENTIDAD | ALTA | cuentas |
| `masivo` | MODIF | ALTA | masivo |
| `bloqueo` | ACCION | ALTA | bloquea cuenta |
| `desbloqueo` | ACCION | ALTA | desbloquea cuenta |
| `desb` | ACCION | MEDIA | desbloqueo |
| `bloq` | ACCION | MEDIA | bloqueo |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
