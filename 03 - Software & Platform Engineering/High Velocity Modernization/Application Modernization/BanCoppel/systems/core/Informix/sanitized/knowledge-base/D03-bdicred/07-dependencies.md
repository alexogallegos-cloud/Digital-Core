# D03 · Créditos — Dependencias entre Dominios

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicred` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 4 · Riesgo: **CRÍTICO**
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
| Dominios de los que depende (upstream) | **5** |
| Dominios que dependen de este (downstream) | **7** |
| Llamadas cross-dominio salientes (total) | **511** |
| Llamadas cross-dominio entrantes (total) | **9,202** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdicred` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdicred` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 4 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdicred` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 242 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| [D11](D11-bdicobranza/) | `bdicobranza` | Cobranza | 138 | 🟡 MEDIO | `bdicobranza:sp_inserta_bitacora_cob` |
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 77 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 39 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_desc_ret`, `bdinteg:valor_divisa_pesos` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 15 | 🟢 BAJO | `bdisolic:determina_lincred_tc_cjunk`, `bdisolic:sp_obtienegrupo`, `bdisolic:sp_actualiza_statusmttobcycc` |

## Dependencias downstream — estos dominios llaman a `bdicred`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdicred` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 9,027 | 🔴 CRÍTICO | `bdicred:sp_consulta_saldos_general`, `bdicred:sp_mon_buro_conssolcredlincred2`, `bdicred:sp_inserta_productos` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 54 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:genmov` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 53 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:genmov` |
| [D07](D07-bdiaclaracion/) | `bdiaclaracion` | Aclaraciones | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general` |
| [D11](D11-bdicobranza/) | `bdicobranza` | Cobranza | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd` |
| [D05](D05-bdisac/) | `bdisac` | Saldos y Cuentas | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:reversion` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 5 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:principalrefer` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdicred` → `bdicheq` (242 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicred:apercred1_pp_domicilia_web` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdicred:altatarcred_v_1` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdicred:apercred1_pp_domicilia_web` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdicred:altatarcred` | `bdicheq:sp_generafolionomina` | 253 fan-in | [SME-PENDING] |
| `bdicred:cobrauto` | `bdicheq:bloqueo_cta` | 184 fan-in | [SME-PENDING] |
| `bdicred:cobrauto` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicred` y `bdicheq`?


#### `bdicred` → `bdicobranza` (138 llamadas)

> Dominio destino: **Cobranza** (D11) · Wave: Wave 2

| SP caller (`bdicred`) | SP callee (`bdicobranza`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicred:sp_cac_consultasolincrelincred` | `bdicobranza:sp_inserta_bitacora_cob` | 406 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicred` y `bdicobranza`?


#### `bdicred` → `bdimnsj` (77 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdicred`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicred:altatarcred_v_1` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicred` y `bdimnsj`?


#### `bdicred` → `bdinteg` (39 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdicred`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicred:sp_status_sol_aud2` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicred:sp_obtenerdoctosdigitalizar` | `bdinteg:sp_desc_ret` | 358 fan-in | [SME-PENDING] |
| `bdicred:sp_cac_asignasolanalista` | `bdinteg:valor_divisa_pesos` | 53 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicred` y `bdinteg`?


#### `bdicnweb` → `bdicred` (9,027 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdicred`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:eliminasolicusuariomc` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdicred:sp_mon_buro_conssolcredlincred2` | 325 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_inserta_productos` | 305 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_conspoliticacreditoprod` | 303 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_consulta_frecpago` | 303 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_obtenerdoctosdigitalizar` | 300 fan-in | [SME-PENDING] |


#### `bdisolic` → `bdicred` (54 llamadas — este dominio como **proveedor**)

> Dominio origen: **Solicitudes** (D06) · Wave: Wave 3

| SP caller (`bdisolic`) | SP callee (`bdicred`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdisolic:sp_prestamoflex_sms` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdisolic:situacion_pago_banco_cjunk` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |
| `bdisolic:sp_actualiza_monto_lineas` | `bdicred:genmov` | 176 fan-in | [SME-PENDING] |
| `bdisolic:sp_obtensolicitudmaquilatdc` | `bdicred:sp_grabadetallearchivotdc` | 154 fan-in | [SME-PENDING] |
| `bdisolic:sp_depura_autorizacion` | `bdicred:sp_inserta_bitacora` | 143 fan-in | [SME-PENDING] |
| `bdisolic:sp_validaradn` | `bdicred:reversion` | 114 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdicred` (53 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdicred`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:sp_cnsif_consprodcte` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdinteg:sp_consultarfcalterno` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |
| `bdinteg:ctemoraldatoslegales` | `bdicred:genmov` | 176 fan-in | [SME-PENDING] |
| `bdinteg:sp_depura_si_refdirecciones` | `bdicred:sp_inserta_bitacora` | 143 fan-in | [SME-PENDING] |
| `bdinteg:sp_bloqueactas` | `bdicred:sp_bloqueocuenta` | 90 fan-in | [SME-PENDING] |
| `bdinteg:sp_cnsif_consprodcte` | `bdicred:sp_consulta_datos_general` | 66 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdicred` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdicred (upstream):
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Cobranza (bdicobranza) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]
  - Solicitudes (bdisolic) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdicred (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Solicitudes (bdisolic): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]
  - Para Aclaraciones (bdiaclaracion): [SME-PENDING definir endpoint/evento]
  - Para Cobranza (bdicobranza): [SME-PENDING definir endpoint/evento]
  - Para Saldos y Cuentas (bdisac): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Créditos cruzan hacia otros dominios?
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
