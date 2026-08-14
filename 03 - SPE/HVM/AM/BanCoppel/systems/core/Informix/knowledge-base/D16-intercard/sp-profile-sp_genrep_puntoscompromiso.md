# SP Profile: `sp_genrep_puntoscompromiso`

> **Base de datos**: `intercard` · Dominio D16 — Intercard
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_genrep_puntoscompromiso` implementa la logica de genera reporte puntos y compromiso de pago en el dominio Intercard (base de datos `intercard`). Comprende 235 lineas de codigo, 7 tablas consultadas. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D16 | [../D16-intercard/07-dependencies.md](../D16-intercard/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_genrep_puntoscompromiso.html](../../portal/sp-detail/sp-detail-sp_genrep_puntoscompromiso.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **3** |
| Callees principales | — |
| LOC | **235** |
| Tablas consultadas | 7 |
| Reglas de negocio activas | **1** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_genrep_puntoscompromiso\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    N2["BR-V2-7558: Error en la ejecucion del sp bdimnsj:sp."]
    N1 --> N2
    Z["Retorna resultado"]
    N2 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D16 Intercard
    participant SP as sp_genrep_puntoscompromiso
    CL->>SP: invoca sp_genrep_puntoscompromiso
    Note over SP: BR-V2-7558 OPERACIONAL: Error en la ejecucion del sp bdimnsj:sp_registra_.
    Note over SP,CL: vocab: genrep, comp, puntos, compromiso
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-7558 | VALIDACIÓN | OPERACIONAL | 166 | `RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP ` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `genrep` | ACCION | MEDIA | genera reporte (abreviación genrep) |
| `comp` | MODIF | ALTA | complemento |
| `puntos` | ENTIDAD | ALTA | puntos (recompensas) |
| `compromiso` | ENTIDAD | ALTA | compromiso de pago — promesa formal de liquidación (sp_consultacompromisosvigente) |
| `prom` | ABREVIATURA | MEDIA | promedio |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
