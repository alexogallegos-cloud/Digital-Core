# D02 · Integración y Auth — Dependencias entre Dominios

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdinteg` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 5 · Riesgo: **CRÍTICO**
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
| Dominios de los que depende (upstream) | **7** |
| Dominios que dependen de este (downstream) | **8** |
| Llamadas cross-dominio salientes (total) | **201** |
| Llamadas cross-dominio entrantes (total) | **11,540** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdinteg` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdinteg` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 5 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdinteg` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D09](D09-bdimnsj/) | `bdimnsj` | Mensajería | 73 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 53 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:genmov` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 46 | 🟢 BAJO | `bdicheq:cargo_ref`, `bdicheq:reversion`, `bdicheq:sp_generafolionomina` |
| [D11](D11-bdicobranza/) | `bdicobranza` | Cobranza | 13 | 🟢 BAJO | `bdicobranza:sp_inserta_bitacora_cob` |
| [D05](D05-bdisac/) | `bdisac` | Saldos y Cuentas | 9 | 🟢 BAJO | `bdisac:sp_sac_guardamensajeerror`, `bdisac:sp_validanombenefbts` |
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 4 | 🟢 BAJO | `bdicnweb:sp_calificacion_scoring`, `bdicnweb:sp_validacte_transfer` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 3 | 🟢 BAJO | `bdisolic:sp_obtienegrupo`, `bdisolic:sp_actualiza_status_sol`, `bdisolic:sp_valida_cliente_grupo` |

## Dependencias downstream — estos dominios llaman a `bdinteg`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdinteg` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 11,391 | 🔴 CRÍTICO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_cnsif_permisosejecutivo`, `bdinteg:sp_valida_perfil_usuario` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 43 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_inserta_msjafore`, `bdinteg:sp_limite_max` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 39 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_desc_ret`, `bdinteg:valor_divisa_pesos` |
| [D10](D10-bdisuc/) | `bdisuc` | Sucursales | 27 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo` |
| [D12](D12-bdicont/) | `bdicont` | Contabilidad | 19 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo` |
| [D05](D05-bdisac/) | `bdisac` | Saldos y Cuentas | 12 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_registra_telefonos`, `bdinteg:sp_actvalidacioncofetel` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 7 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:valor_divisa_pesos`, `bdinteg:mesesvalidoscte` |
| [D08](D08-bdispei/) | `bdispei` | SPEI | 2 | 🟢 BAJO | `bdinteg:sp_desc_ret` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdinteg` → `bdimnsj` (73 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdinteg`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdinteg:consnumcte_n_web` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdinteg` y `bdimnsj`?


#### `bdinteg` → `bdicred` (53 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdinteg`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdinteg:sp_cnsif_consprodcte` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdinteg:sp_consultarfcalterno` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |
| `bdinteg:ctemoraldatoslegales` | `bdicred:genmov` | 176 fan-in | [SME-PENDING] |
| `bdinteg:sp_depura_si_refdirecciones` | `bdicred:sp_inserta_bitacora` | 143 fan-in | [SME-PENDING] |
| `bdinteg:sp_bloqueactas` | `bdicred:sp_bloqueocuenta` | 90 fan-in | [SME-PENDING] |
| `bdinteg:sp_cnsif_consprodcte` | `bdicred:sp_consulta_datos_general` | 66 fan-in | [SME-PENDING] |
| `bdinteg:sp_cnsif_consprodcte` | `bdicred:sp_consultasaldocorte` | 44 fan-in | [SME-PENDING] |
| `bdinteg:sp_desbctasfus` | `bdicred:sp_desbloqueocuenta` | 40 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdinteg` y `bdicred`?


#### `bdinteg` → `bdicheq` (46 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdinteg`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdinteg:sps_grabaremail` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdinteg:sps_grabaremail` | `bdicheq:reversion` | 377 fan-in | [SME-PENDING] |
| `bdinteg:sp_cargaarchivodomicilia_club` | `bdicheq:sp_generafolionomina` | 253 fan-in | [SME-PENDING] |
| `bdinteg:sp_bloqueactas` | `bdicheq:bloqueo_cta` | 184 fan-in | [SME-PENDING] |
| `bdinteg:sp_cnsif_consprodcte` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |
| `bdinteg:sp_cuentadoctos_soc` | `bdicheq:digver11` | 27 fan-in | [SME-PENDING] |
| `bdinteg:sp_cuentadoctos_soc` | `bdicheq:ctaclabe` | 14 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdinteg` y `bdicheq`?


#### `bdinteg` → `bdicobranza` (13 llamadas)

> Dominio destino: **Cobranza** (D11) · Wave: Wave 2

| SP caller (`bdinteg`) | SP callee (`bdicobranza`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdinteg:sp_desbctasfus_obtnombresupana` | `bdicobranza:sp_inserta_bitacora_cob` | 406 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdinteg` y `bdicobranza`?


#### `bdicnweb` → `bdinteg` (11,391 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdinteg`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_bitacora` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicnweb:sp_cp_validacaractertdc` | `bdinteg:sp_cnsif_permisosejecutivo` | 621 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_valida_perfil_usuario` | 388 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_desc_ret` | 358 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdinteg:sp_cuentadoctos_soc` | 354 fan-in | [SME-PENDING] |
| `bdicnweb:sp_consultareportepagoscre` | `bdinteg:sp_consultacoloniascp` | 281 fan-in | [SME-PENDING] |


#### `bdicheq` → `bdinteg` (43 llamadas — este dominio como **proveedor**)

> Dominio origen: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdinteg`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicheq:ischar` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicheq:cargo_ref` | `bdinteg:sp_inserta_msjafore` | 36 fan-in | [SME-PENDING] |
| `bdicheq:cargo_ref` | `bdinteg:sp_limite_max` | 15 fan-in | [SME-PENDING] |
| `bdicheq:reversion` | `bdinteg:sp_reversa_acum_x` | 7 fan-in | [SME-PENDING] |


#### `bdicred` → `bdinteg` (39 llamadas — este dominio como **proveedor**)

> Dominio origen: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdinteg`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicred:sp_status_sol_aud2` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |
| `bdicred:sp_obtenerdoctosdigitalizar` | `bdinteg:sp_desc_ret` | 358 fan-in | [SME-PENDING] |
| `bdicred:sp_cac_asignasolanalista` | `bdinteg:valor_divisa_pesos` | 53 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdinteg` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdinteg (upstream):
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Cobranza (bdicobranza) API: [SME-PENDING definir endpoint/evento]
  - Saldos y Cuentas (bdisac) API: [SME-PENDING definir endpoint/evento]
  - Canal Digital Web (bdicnweb) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdinteg (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]
  - Para Créditos (bdicred): [SME-PENDING definir endpoint/evento]
  - Para Sucursales (bdisuc): [SME-PENDING definir endpoint/evento]
  - Para Contabilidad (bdicont): [SME-PENDING definir endpoint/evento]
  - Para Saldos y Cuentas (bdisac): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Integración y Auth cruzan hacia otros dominios?
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
