# SP Profile: `sp_app_valdigito`

> **Base de datos**: `bdisac` · Dominio D05 — SAC / Transferencias
> **Tipo de artefacto**: Perfil funcional · Gemelo Cognitivo — Capa 4: Intencion
> **Ultima actualizacion**: 2026-08-03
> **Estado**: ACTIVO · 157 callers en produccion

---

## Historia Funcional

El SP `sp_app_valdigito` implementa la logica de dígito verificador (canal app) en el dominio SAC / Transferencias (base de datos `bdisac`). Comprende 307 lineas de codigo, 1 tablas consultadas. Es invocado por 157 callers en el sistema, lo que lo convierte en un componente de alta dependencia. Delega logica a: `sp_verificaconvenio`.

---

## Relaciones en la KB

| Tipo de relacion | Documento |
|-----------------|-----------|
| Cross-reference de reglas y vocabulario | [../cross-reference/sp-rules-vocab-map.md](../cross-reference/sp-rules-vocab-map.md) |
| Dependencias del dominio D05 | [../D05-bdisac/07-dependencies.md](../D05-bdisac/07-dependencies.md) |
| Reglas globales del sistema | [../rules/business-rules-bcop.md](../rules/business-rules-bcop.md) |
| Vocabulario del sistema | [../vocabulary/vocabulary-knowledge-base-bcop.md](../vocabulary/vocabulary-knowledge-base-bcop.md) |
| Vista HTML interactiva | [../../portal/sp-detail/sp-detail-sp_app_valdigito.html](../../portal/sp-detail/sp-detail-sp_app_valdigito.html) |

---

## Metricas del Gemelo Cognitivo

| Metrica | Valor |
|---------|-------|
| Fan-in (callers) | **157** |
| Fan-out (callees) | **3** |
| Callees principales | `sp_verificaconvenio` |
| LOC | **307** |
| Tablas consultadas | 1 |
| Reglas de negocio activas | **2** |
| Autores historicos | 0 |

---

## Flujo de Decision

```mermaid
flowchart TD
    A["Entrada: sp_app_valdigito"]
    N1{"cvalor = '20067'"}
    A --> N1
    N2["CALL: verifica convenio"]
    N1 --> N2
    Y["Aplica reglas (2 reglas)"]
    N2 --> Y
    Z["Salida"]
    Y --> Z
```

---

## Diagrama de Secuencia con Reglas y Vocabulario

```mermaid
sequenceDiagram
    autonumber
    participant CL as D05 SAC / Transferencias
    participant SP as sp_app_valdigito
    participant C1 as sp_verificaconvenio
    CL->>SP: invoca sp_app_valdigito
    SP->>C1: delega a sp_verificaconvenio
    C1-->>SP: resultado
    Note over SP,CL: vocab: app, digi, digito
    SP-->>CL: retorna resultado
```

---

## Reglas de Negocio Activas

| ID | Tipo | Categoria | Linea | Codigo | Referencia |
|----|------|-----------|-------|--------|------------|
| BR-V2-6439 | FÓRMULA | CALCULO_FINANCIERO | 55 | `iValor1 = iValor1 * 2` | — |
| BR-V2-6440 | FÓRMULA | CALCULO_FINANCIERO | 63 | `iValor4 = iValor3 * '9'` | — |

---

## Vocabulario Clave

| Termino | Categoria | Nivel | Significado |
|---------|-----------|-------|-------------|
| `app` | MODIF | ALTA | canal app |
| `digi` | ACCION | MEDIA | digitalización |
| `digito` | ENTIDAD | ALTA | dígito verificador |

---

## Nota de Migracion

El nombre contiene tokens sinteticos (`?_val`), lo que indica que el alcance original fue parcialmente documentado por el equipo historico.

Ver registro completo de riesgos: [migration-risk-register.md](../migration-risk-register.md).
