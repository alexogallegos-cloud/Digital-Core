# D07 · Aclaraciones — Dependencias entre Dominios

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdiaclaracion` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción de dependencias del call graph)
- Architect — Application Modernization (diseño de Anti-Corruption Layer)
- Domain Expert — LegacyCore (validación funcional de contratos entre dominios)

> Secciones marcadas `[SME-PENDING]` requieren definición del contrato de interfaz target antes de Etapa 2.
---


## Perfil de dependencias

| Métrica | Valor |
|---------|-------|
| Dominios de los que depende (upstream) | **3** |
| Dominios que dependen de este (downstream) | **0** |
| Llamadas cross-dominio salientes (total) | **180** |
| Llamadas cross-dominio entrantes (total) | **0** |
| Ratio de acoplamiento | **EMISOR NETO** (más salidas que entradas) |

## Impacto en la secuencia de migración

- **`bdiaclaracion` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdiaclaracion` esté listo:** (ninguno crítico)
- **Wave asignada:** Wave 2 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdiaclaracion` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 125 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:bloqueo_cta` |
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 34 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general` |

## Dependencias downstream — estos dominios llaman a `bdiaclaracion`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdiaclaracion` |
|----|--------------|---------|---------|-----------|----------------------|
| (ningún dominio de los 12 llama a este dominio) | | | | | |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdiaclaracion` → `bdicheq` (125 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdiaclaracion`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdiaclaracion:sp_cargoxajuste_debcred` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdiaclaracion:sp_fal_asignar_analista_credito` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdiaclaracion:sp_acl_consulta_ciudades` | `bdicheq:bloqueo_cta` | 184 fan-in | [SME-PENDING] |
| `bdiaclaracion:sp_cierres_masivos_afectacion` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdiaclaracion` y `bdicheq`?


#### `bdiaclaracion` → `bdimnsj` (34 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdiaclaracion`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdiaclaracion:sp_acl_validacion_abonoinmediato` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdiaclaracion` y `bdimnsj`?


#### `bdiaclaracion` → `bdicred` (21 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdiaclaracion`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdiaclaracion:sp_fal_busca_beneficiarios_pagares_por_cuenta` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdiaclaracion` y `bdicred`?


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdiaclaracion` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdiaclaracion (upstream):
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdiaclaracion (downstream):

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Aclaraciones cruzan hacia otros dominios?
Opciones de diseño (ADR requerido):
  A) Saga pattern (compensating transactions)
  B) Two-Phase Commit (2PC) — solo si atomicidad es no negociable
  C) Eventual consistency + idempotency (preferido para banca moderna)
```

## Componentes técnicos compartidos

Componentes técnicos que este dominio comparte o consume:

| Componente | Tipo | Dominio propietario | Tipo de acceso | Notas |
|-----------|------|--------------------|----|-------|
| Anti-Corruption Layer | Infraestructura | Transversal | Requerido | Traduce llamadas `CALL db:sp()` a API REST/gRPC |
| `bdinteg:sp_cnsif_confirmaejecutivo` | SP crítico | D02-bdinteg | Cross-DB | 2,400 callers — candidato a AuthService |
| Informix IDS 14.10 (instancia) | Motor DB | Infraestructura | Compartido | Todos los dominios en la misma instancia |
| IBM POWER-AIX (DCMSIF01/02) | Servidor | Infraestructura | Compartido | Reemplazar por AWS/cloud en target |
| [SME-PENDING] | | | | |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: callgraph-data.json (graph.edges cross_db=True)*
