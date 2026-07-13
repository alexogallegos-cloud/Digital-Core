# D06 · Solicitudes — Dependencias entre Dominios

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisolic` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Dominios de los que depende (upstream) | **5** |
| Dominios que dependen de este (downstream) | **3** |
| Llamadas cross-dominio salientes (total) | **94** |
| Llamadas cross-dominio entrantes (total) | **1,334** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdisolic` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdisolic` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 3 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdisolic` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D03](D03-bdicred/) | `bdicred` | Créditos | 54 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:genmov` |
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 23 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 7 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:valor_divisa_pesos`, `bdinteg:mesesvalidoscte` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 6 | 🟢 BAJO | `bdicheq:abono_ref`, `bdicheq:sp_generafolionomina`, `bdicheq:sp_cons_sdodisp_x_tpcalculo` |
| [D11](D11-bdicobranza/) | `bdicobranza` | Cobranza | 4 | 🟢 BAJO | `bdicobranza:sp_inserta_bitacora_cob` |

## Dependencias downstream — estos dominios llaman a `bdisolic`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdisolic` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 1,316 | 🟠 ALTO | `bdisolic:sp_asigna_solicitud_soc`, `bdisolic:determina_lincred_tc_cjunk`, `bdisolic:sp_obtienegrupo` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 15 | 🟢 BAJO | `bdisolic:determina_lincred_tc_cjunk`, `bdisolic:sp_obtienegrupo`, `bdisolic:sp_actualiza_statusmttobcycc` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 3 | 🟢 BAJO | `bdisolic:sp_obtienegrupo`, `bdisolic:sp_actualiza_status_sol`, `bdisolic:sp_valida_cliente_coppel` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdisolic` → `bdicred` (54 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdisolic`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisolic:sp_prestamoflex_sms` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdisolic:situacion_pago_banco_cjunk` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |
| `bdisolic:sp_actualiza_monto_lineas` | `bdicred:genmov` | 176 fan-in | [SME-PENDING] |
| `bdisolic:sp_obtensolicitudmaquilatdc` | `bdicred:sp_grabadetallearchivotdc` | 154 fan-in | [SME-PENDING] |
| `bdisolic:sp_depura_autorizacion` | `bdicred:sp_inserta_bitacora` | 143 fan-in | [SME-PENDING] |
| `bdisolic:sp_validaradn` | `bdicred:reversion` | 114 fan-in | [SME-PENDING] |
| `bdisolic:determina_lincred_tc_cjunk` | `bdicred:sp_obtiene_tasa_int_diferenciadas` | 42 fan-in | [SME-PENDING] |
| `bdisolic:califica_scoring2_cjunk` | `bdicred:sp_valida2credito` | 10 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisolic` y `bdicred`?


#### `bdisolic` → `bdimnsj` (23 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdisolic`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisolic:califica_scoring2_cjunk` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisolic` y `bdimnsj`?


#### `bdisolic` → `bdinteg` (7 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdisolic`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisolic:sp_cnt_consultadetallesolicitudes` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdisolic:califica_scoring2_cjunk` | `bdinteg:valor_divisa_pesos` | 53 fan-in | [SME-PENDING] |
| `bdisolic:sp_obtienegrupo` | `bdinteg:mesesvalidoscte` | 16 fan-in | [SME-PENDING] |
| `bdisolic:califica_scoring2_cjunk` | `bdinteg:sp_consultareferencias` | 15 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisolic` y `bdinteg`?


#### `bdisolic` → `bdicheq` (6 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdisolic`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisolic:sp_validaradn` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdisolic:sp_prestamoflex_sms` | `bdicheq:sp_generafolionomina` | 253 fan-in | [SME-PENDING] |
| `bdisolic:sp_verifmaxmto` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisolic` y `bdicheq`?


#### `bdicnweb` → `bdisolic` (1,316 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdisolic`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_consultareportepagoscre` | `bdisolic:sp_asigna_solicitud_soc` | 236 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacatczb_rh` | `bdisolic:determina_lincred_tc_cjunk` | 208 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacatczb_rh` | `bdisolic:sp_obtienegrupo` | 174 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisolic:sp_consultarfacturacionos2` | 168 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacatczb_rh` | `bdisolic:califica_scoring2_cjunk` | 167 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacatczb_rh` | `bdisolic:sp_cons_empleado_mc` | 148 fan-in | [SME-PENDING] |


#### `bdicred` → `bdisolic` (15 llamadas — este dominio como **proveedor**)

> Dominio origen: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdisolic`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicred:cancelatarjeta_web` | `bdisolic:determina_lincred_tc_cjunk` | 208 fan-in | [SME-PENDING] |
| `bdicred:apercred1_pp_web` | `bdisolic:sp_obtienegrupo` | 174 fan-in | [SME-PENDING] |
| `bdicred:sp_mon_buro_conssolcredlincred2` | `bdisolic:sp_actualiza_statusmttobcycc` | 9 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdisolic` (3 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdisolic`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:alta_sol_tc_cjunk` | `bdisolic:sp_obtienegrupo` | 174 fan-in | [SME-PENDING] |
| `bdinteg:sp_desbctasfus_obtnombresupana` | `bdisolic:sp_actualiza_status_sol` | 100 fan-in | [SME-PENDING] |
| `bdinteg:ctemoral` | `bdisolic:sp_valida_cliente_coppel` | 28 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdisolic` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdisolic (upstream):
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Cobranza (bdicobranza) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdisolic (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Créditos (bdicred): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Solicitudes cruzan hacia otros dominios?
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
