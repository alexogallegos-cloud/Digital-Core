# D01 · Canal Digital Web — Dependencias entre Dominios

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicnweb` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** ÚLTIMO · Riesgo: **ALTO**
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
| Dominios que dependen de este (downstream) | **2** |
| Llamadas cross-dominio salientes (total) | **29,033** |
| Llamadas cross-dominio entrantes (total) | **17** |
| Ratio de acoplamiento | **EMISOR NETO** (más salidas que entradas) |

## Impacto en la secuencia de migración

- **`bdicnweb` bloquea su propia migración hasta que estén listos:** `bdinteg`, `bdicred`, `bdisuc`, `bdisac`, `bdisolic`, `bdimnsj`
- **Dominios que no pueden migrar hasta que `bdicnweb` esté listo:** (ninguno crítico)
- **Wave asignada:** ÚLTIMO — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdicnweb` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 11,391 | 🔴 CRÍTICO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_cnsif_permisosejecutivo`, `bdinteg:sp_valida_perfil_usuario` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 9,027 | 🔴 CRÍTICO | `bdicred:sp_consulta_saldos_general`, `bdicred:sp_mon_buro_conssolcredlincred2`, `bdicred:sp_inserta_productos` |
| [D10](D10-bdisuc/) | `bdisuc` | Sucursales | 3,255 | 🟠 ALTO | `bdisuc:sp_consultadatospiezas_bym3`, `bdisuc:sp_consutacat_dictamen_bym`, `bdisuc:sp_consultadatospiezas_bym2` |
| [D05](D05-bdisac/) | `bdisac` | Saldos y Cuentas | 2,601 | 🟠 ALTO | `bdisac:sp_validanombenefbts`, `bdisac:sp_sac_consucursales`, `bdisac:sp_validabts` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 1,316 | 🟠 ALTO | `bdisolic:sp_asigna_solicitud_soc`, `bdisolic:determina_lincred_tc_cjunk`, `bdisolic:sp_obtienegrupo` |
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 949 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 494 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |

## Dependencias downstream — estos dominios llaman a `bdicnweb`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdicnweb` |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 13 | 🟢 BAJO | `bdicnweb:sp_split_cadena` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 4 | 🟢 BAJO | `bdicnweb:sp_calificacion_scoring`, `bdicnweb:sp_validacte_transfer` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdicnweb` → `bdinteg` (11,391 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdicnweb`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicnweb:sp_bitacora` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdinteg:sp_cnsif_permisosejecutivo` | 621 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_valida_perfil_usuario` | 388 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_desc_ret` | 358 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdinteg:sp_cuentadoctos_soc` | 354 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_consultacoloniascp` | 281 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_dicta_actualizastatusalerta` | 270 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_dicta_consultactesdictamen2` | 268 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicnweb` y `bdinteg`?


#### `bdicnweb` → `bdicred` (9,027 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicnweb`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicnweb:eliminasolicusuariomc` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdicred:sp_mon_buro_conssolcredlincred2` | 325 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_inserta_productos` | 305 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_conspoliticacreditoprod` | 303 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_consulta_frecpago` | 303 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_obtenerdoctosdigitalizar` | 300 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_mensajes_activos` | 299 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdicred:sp_consulta_subproducto` | 298 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicnweb` y `bdicred`?


#### `bdicnweb` → `bdisuc` (3,255 llamadas)

> Dominio destino: **Sucursales** (D10) · Wave: Wave 3

| SP caller (`bdicnweb`) | SP callee (`bdisuc`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym3` | 381 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consutacat_dictamen_bym` | 378 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym2` | 376 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym3_totales` | 376 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultacat_estatus_bym` | 375 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consulta_catdenominacion_bym` | 374 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_altamodificacion_piezas_bym` | 373 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_entrada_salida` | 333 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicnweb` y `bdisuc`?


#### `bdicnweb` → `bdisac` (2,601 llamadas)

> Dominio destino: **Saldos y Cuentas** (D05) · Wave: Wave 3

| SP caller (`bdicnweb`) | SP callee (`bdisac`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicnweb:sp_consultareportepagoscre` | `bdisac:sp_validanombenefbts` | 243 fan-in | [SME-PENDING] |
| `bdicnweb:sp_actualizacion_cheques_presentar` | `bdisac:sp_sac_consucursales` | 195 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_validabts` | 182 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_obtieneparametro` | 176 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_consinfobtssif` | 162 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_sac_wu_guardarespuesta_search` | 162 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_validarembtsensac` | 159 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdisac:sp_app_valdigito` | 157 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicnweb` y `bdisac`?


#### `bdicheq` → `bdicnweb` (13 llamadas — este dominio como **proveedor**)

> Dominio origen: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdicnweb`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicheq:pasecheqhis` | `bdicnweb:sp_split_cadena` | 857 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdicnweb` (4 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdicnweb`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:sps_grabaremail` | `bdicnweb:sp_calificacion_scoring` | 117 fan-in | [SME-PENDING] |
| `bdinteg:sp_cnsif_consprodcte` | `bdicnweb:sp_validacte_transfer` | 66 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdicnweb` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdicnweb (upstream):
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]
  - Sucursales (bdisuc) API: [SME-PENDING definir endpoint/evento]
  - Saldos y Cuentas (bdisac) API: [SME-PENDING definir endpoint/evento]
  - Solicitudes (bdisolic) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdicnweb (downstream):
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Canal Digital Web cruzan hacia otros dominios?
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
