# SP Profile: `sp_consulta_catdenominacion_bym`

> **Base de datos**: `bdisuc` · Dominio D10 — Sucursales
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 374 callers en produccion

---

## Historia Funcional

El SP `sp_consulta_catdenominacion_bym` implementa la logica de consulta catálogo de denominaciones y Billetes y Monedas en el dominio Sucursales (base de datos `bdisuc`). Comprende 1,052 lineas de codigo, 1 tablas consultadas. Es invocado por 374 callers en el sistema, lo que lo convierte en un componente de alta dependencia. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D10 | [../D10-bdisuc/07-dependencies.md](../D10-bdisuc/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_consulta_catdenominacion_bym.html](../../portal/sp-detail/sp-detail-sp_consulta_catdenominacion_bym.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **374** |
| Fan-out (callees) | **374** |
| Callees principales | — |
| LOC | **1,052** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_consulta_catdenominacion_b."]
    B["Proceso principal"]
    A --> B
    Z["Salida"]
    B --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D10 Sucursales
    participant SP as sp_consulta_catdenominacion.
    CL->>SP: invoca sp_consulta_catdenominacion.
    Note over SP,CL: vocab: consulta, catdenominacion, bym, cons
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `consulta` | ACCION | ALTA | consulta / lee |
| `catdenominacion` | ENTIDAD | ALTA | catálogo de denominaciones |
| `bym` | ENTIDAD | MEDIA | Billetes y Monedas (efectivo en sucursal — evidencia: 'piezas' + 'denominación') |
| `cons` | ACCION | ALTA | consulta |
| `nomina` | ENTIDAD | ALTA | nómina |
| `denominacion` | ENTIDAD | ALTA | denominación (valor facial del billete/moneda) |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
