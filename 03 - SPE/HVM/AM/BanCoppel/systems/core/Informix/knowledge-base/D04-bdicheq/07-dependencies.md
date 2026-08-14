# D04 · Cheques / Cuentas — Dependencias entre Dominios

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicheq` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
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
| Dominios de los que depende (upstream) | **7** |
| Dominios que dependen de este (downstream) | **7** |
| Llamadas cross-dominio salientes (total) | **138** |
| Llamadas cross-dominio entrantes (total) | **1,273** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdicheq` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdicheq` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 4 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdicheq` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D09](../D09-bdimnsj/) | `bdimnsj` | Mensajería | 72 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D02](../D02-bdinteg/) | `bdinteg` | Integración y Auth | 43 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_inserta_msjafore`, `bdinteg:sp_limite_max` |
| [D01](../D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 13 | 🟢 BAJO | `bdicnweb:sp_split_cadena` |
| [D03](../D03-bdicred/) | `bdicred` | Créditos | 5 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:principalrefer` |
| [D08](../D08-bdispei/) | `bdispei` | SPEI | 3 | 🟢 BAJO | `bdispei:sp_validafecha` |
| [D05](../D05-bdisac/) | `bdisac` | Saldos y Cuentas | 1 | 🟢 BAJO | `bdisac:sp_reversionsac` |
| [D10](../D10-bdisuc/) | `bdisuc` | Sucursales | 1 | 🟢 BAJO | `bdisuc:reversion` |

## Dependencias downstream — estos dominios llaman a `bdicheq`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdicheq` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](../D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 494 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| [D05](../D05-bdisac/) | `bdisac` | Saldos y Cuentas | 312 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| [D03](../D03-bdicred/) | `bdicred` | Créditos | 242 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| [D07](../D07-bdiaclaracion/) | `bdiaclaracion` | Aclaraciones | 125 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:bloqueo_cta` |
| [D08](../D08-bdispei/) | `bdispei` | SPEI | 48 | 🟢 BAJO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:sp_cons_sdodisp_x_tpcalculo` |
| [D02](../D02-bdinteg/) | `bdinteg` | Integración y Auth | 46 | 🟢 BAJO | `bdicheq:cargo_ref`, `bdicheq:reversion`, `bdicheq:sp_generafolionomina` |
| [D06](../D06-bdisolic/) | `bdisolic` | Solicitudes | 6 | 🟢 BAJO | `bdicheq:abono_ref`, `bdicheq:sp_generafolionomina`, `bdicheq:sp_cons_sdodisp_x_tpcalculo` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdicheq` → `bdimnsj` (72 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdicheq`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicheq:bloqueo_cta` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicheq` y `bdimnsj`?


#### `bdicheq` → `bdinteg` (43 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdicheq`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicheq:ischar` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicheq:cargo_ref` | `bdinteg:sp_inserta_msjafore` | 36 fan-in | [SME-PENDING] |
| `bdicheq:cargo_ref` | `bdinteg:sp_limite_max` | 15 fan-in | [SME-PENDING] |
| `bdicheq:reversion` | `bdinteg:sp_reversa_acum_x` | 7 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicheq` y `bdinteg`?


#### `bdicheq` → `bdicnweb` (13 llamadas)

> Dominio destino: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicheq`) | SP callee (`bdicnweb`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicheq:pasecheqhis` | `bdicnweb:sp_split_cadena` | 857 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicheq` y `bdicnweb`?


#### `bdicheq` → `bdicred` (5 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicheq:sp_consulta_cuentas_credito` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdicheq:sp_edoctaencabezado` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |
| `bdicheq:bloqueo_cta` | `bdicred:principalrefer` | 51 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicheq` y `bdicred`?


#### `bdicnweb` → `bdicheq` (494 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdicheq`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_calificacion_scoring` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdicnweb:sp_abonotransfersoc` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdicnweb:sp_calificacion_scoring` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdicnweb:sp_calificacion_scoring` | `bdicheq:sp_generafolionomina` | 253 fan-in | [SME-PENDING] |
| `bdicnweb:sp_abono_ref_masivo` | `bdicheq:bloqueo_cta` | 184 fan-in | [SME-PENDING] |
| `bdicnweb:sp_calificacion_scoring` | `bdicheq:digverclabe` | 57 fan-in | [SME-PENDING] |


#### `bdisac` → `bdicheq` (312 llamadas — este dominio como **proveedor**)

> Dominio origen: **Saldos y Cuentas** (D05) · Wave: Wave 3

| SP caller (`bdisac`) | SP callee (`bdicheq`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdisac:sp_actualizahistoricodetransacciones` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdisac:sp_consremcambiost` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdisac:sp_consremcambiost` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdisac:sp_app_aplicapagos_cred` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |


#### `bdicred` → `bdicheq` (242 llamadas — este dominio como **proveedor**)

> Dominio origen: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdicheq`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicred:apercred1_pp_domicilia_web` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdicred:altatarcred_v_1` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdicred:apercred1_pp_domicilia_web` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdicred:altatarcred` | `bdicheq:sp_generafolionomina` | 253 fan-in | [SME-PENDING] |
| `bdicred:cobrauto` | `bdicheq:bloqueo_cta` | 184 fan-in | [SME-PENDING] |
| `bdicred:cobrauto` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdicheq` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdicheq (upstream):
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]
  - Canal Digital Web (bdicnweb) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]
  - SPEI (bdispei) API: [SME-PENDING definir endpoint/evento]
  - Saldos y Cuentas (bdisac) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdicheq (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Saldos y Cuentas (bdisac): [SME-PENDING definir endpoint/evento]
  - Para Créditos (bdicred): [SME-PENDING definir endpoint/evento]
  - Para Aclaraciones (bdiaclaracion): [SME-PENDING definir endpoint/evento]
  - Para SPEI (bdispei): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Cheques / Cuentas cruzan hacia otros dominios?
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
