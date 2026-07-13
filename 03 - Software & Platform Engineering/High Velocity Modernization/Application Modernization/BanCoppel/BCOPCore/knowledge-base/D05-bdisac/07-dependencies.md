# D05 · Saldos y Cuentas — Dependencias entre Dominios

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisac` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 3 · Riesgo: **ALTO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción de dependencias del call graph)
- Architect — Application Modernization (diseño de Anti-Corruption Layer)
- Domain Expert — BanCoppel (validación funcional de contratos entre dominios)

> Secciones marcadas `[SME-PENDING]` requieren definición del contrato de interfaz target antes de Etapa 2.
---


## Perfil de dependencias

| Métrica | Valor |
|---------|-------|
| Dominios de los que depende (upstream) | **4** |
| Dominios que dependen de este (downstream) | **3** |
| Llamadas cross-dominio salientes (total) | **355** |
| Llamadas cross-dominio entrantes (total) | **2,611** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdisac` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdisac` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 3 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdisac` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 312 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:reversion` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 12 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_registra_telefonos`, `bdinteg:sp_actvalidacioncofetel` |
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 10 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |

## Dependencias downstream — estos dominios llaman a `bdisac`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdisac` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 2,601 | 🟠 ALTO | `bdisac:sp_validanombenefbts`, `bdisac:sp_sac_consucursales`, `bdisac:sp_validabts` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 9 | 🟢 BAJO | `bdisac:sp_sac_guardamensajeerror`, `bdisac:sp_validanombenefbts` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 1 | 🟢 BAJO | `bdisac:sp_reversionsac` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdisac` → `bdicheq` (312 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdisac`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisac:sp_actualizahistoricodetransacciones` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdisac:sp_consremcambiost` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdisac:sp_consremcambiost` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdisac:sp_app_aplicapagos_cred` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisac` y `bdicheq`?


#### `bdisac` → `bdicred` (21 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdisac`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisac:sp_app_recordorder` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdisac:sp_app_aplicapagos_cred` | `bdicred:reversion` | 114 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisac` y `bdicred`?


#### `bdisac` → `bdinteg` (12 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdisac`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisac:sp_app_aplicapago` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdisac:sp_app_obtieneinfoidentificacion` | `bdinteg:sp_registra_telefonos` | 82 fan-in | [SME-PENDING] |
| `bdisac:sp_app_obtieneinfoidentificacion` | `bdinteg:sp_actvalidacioncofetel` | 16 fan-in | [SME-PENDING] |
| `bdisac:sp_app_obtieneinfoidentificacion` | `bdinteg:sp_bitacoraapertura` | 9 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisac` y `bdinteg`?


#### `bdisac` → `bdimnsj` (10 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdisac`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisac:sp_app_aplicapago` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisac` y `bdimnsj`?


#### `bdicnweb` → `bdisac` (2,601 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdisac`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_consultareportepagoscre` | `bdisac:sp_validanombenefbts` | 243 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacion_cheques_presentar` | `bdisac:sp_sac_consucursales` | 195 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_validabts` | 182 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_obtieneparametro` | 176 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_consinfobtssif` | 162 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_sac_wu_guardarespuesta_search` | 162 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdisac` (9 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdisac`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:sp_alta_ctebpi` | `bdisac:sp_sac_guardamensajeerror` | 321 fan-in | [SME-PENDING] |
| `bdinteg:sp_compara_nombres` | `bdisac:sp_validanombenefbts` | 243 fan-in | [SME-PENDING] |


#### `bdicheq` → `bdisac` (1 llamadas — este dominio como **proveedor**)

> Dominio origen: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdisac`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicheq:reversion` | `bdisac:sp_reversionsac` | 9 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdisac` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdisac (upstream):
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdisac (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Saldos y Cuentas cruzan hacia otros dominios?
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
