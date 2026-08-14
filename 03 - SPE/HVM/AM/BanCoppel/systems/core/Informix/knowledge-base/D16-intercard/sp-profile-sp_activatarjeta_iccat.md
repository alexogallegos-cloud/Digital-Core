# SP Profile: `sp_activatarjeta_iccat`

> **Base de datos**: `intercard` · Dominio D16 — Intercard
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 0 callers en produccion

---

## Historia Funcional

El SP `sp_activatarjeta_iccat` implementa la logica de activa tarjeta vía canal ICCAT (BPI); gestiona solicitudes de entrega, reposición de token y desbloqueo de acceso en el dominio Intercard (base de datos `intercard`). Comprende 941 lineas de codigo. 

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D16 | [../D16-intercard/07-dependencies.md](../D16-intercard/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_activatarjeta_iccat.html](../../portal/sp-detail/sp-detail-sp_activatarjeta_iccat.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **0** |
| Fan-out (callees) | **3** |
| Callees principales | — |
| LOC | **941** |
| Tablas consultadas | 0 |
| Reglas de negocio activas | **0** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["sp_activatarjeta_iccat\nRecibe parámetros de entrada"]
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
    participant CL as D16 Intercard
    participant SP as sp_activatarjeta_iccat
    CL->>SP: invoca sp_activatarjeta_iccat
    Note over SP,CL: vocab: iccat, tarjeta, activa
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

_No se detectaron reglas de negocio para este proceso._

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `iccat` | ENTIDAD | MEDIA | ICCAT — canal de atención al cliente en BPI; gestiona solicitudes de entrega y reposición de token, desbloqueo de acceso (bdibpi:sp_iccat_*, sp_*_iccat) |
| `tarjeta` | ENTIDAD | ALTA | tarjeta |
| `activa` | ACCION | ALTA | activa |

---

## Nota de Migracion

Sin restricciones regulatorias criticas identificadas en el codigo fuente. Verificar en parallel-run que el comportamiento sea equivalente al del sistema legado.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
