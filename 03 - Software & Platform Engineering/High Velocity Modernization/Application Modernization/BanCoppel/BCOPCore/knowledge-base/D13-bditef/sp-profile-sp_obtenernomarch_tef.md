# SP Profile: `sp_obtenernomarch_tef`

> **Base de datos**: `bditef` · Dominio D13 — TEF / Nomina
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-09
> **Estado**: ACTIVO · 42 callers en produccion

---

## Historia Funcional

El SP `sp_obtenernomarch_tef` implementa la logica de obtiene nómina, archivo y transferencia electrónica de fondos en el dominio TEF / Nomina (base de datos `bditef`). Comprende 6,829 lineas de codigo, 2 tablas consultadas, 2 autores historicos. Es invocado por 42 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D13 | [../D13-bditef/07-dependencies.md](../D13-bditef/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_obtenernomarch_tef.html](../../portal/sp-detail/sp-detail-sp_obtenernomarch_tef.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **42** |
| Fan-out (callees) | **25** |
| Callees principales | — |
| LOC | **6,829** |
| Tablas consultadas | 2 |
| Reglas de negocio activas | **0** |
| Autores historicos | 2 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_obtenernomarch_tef\nRecibe parámetros de entrada"]
    N1["Ejecuta lógica principal"]
    A --> N1
    Z["Retorna resultado"]
    N1 --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D13 TEF / Nomina
    participant SP as sp_obtenernomarch_tef
    CL->>SP: invoca sp_obtenernomarch_tef
    Note over SP,CL: vocab: tef, arch, obtener, obten
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `tef` | ENTIDAD | ALTA | TEF — transferencia electrónica de fondos |
| `arch` | ENTIDAD | ALTA | archivo |
| `obtener` | ACCION | ALTA | obtiene / recupera |
| `obten` | ACCION | ALTA | obtiene / recupera |
| `nomarch` | ABREVIATURA | MEDIA | nombre de archivo |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../../knowledge-base/migration-risk-register.md).
