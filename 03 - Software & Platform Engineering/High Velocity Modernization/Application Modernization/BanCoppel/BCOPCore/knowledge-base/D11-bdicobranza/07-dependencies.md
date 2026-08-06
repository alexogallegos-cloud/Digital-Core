# D11 · Cobranza — Dependencias entre Dominios

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdicobranza` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **MEDIO**
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
| Dominios de los que depende (upstream) | **2** |
| Dominios que dependen de este (downstream) | **3** |
| Llamadas cross-dominio salientes (total) | **74** |
| Llamadas cross-dominio entrantes (total) | **155** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdicobranza` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdicobranza` esté listo:** (ninguno crítico)
- **Wave asignada:** Wave 2 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdicobranza` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D09](../D09-bdimnsj/) | `bdimnsj` | Mensajería | 53 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D03](../D03-bdicred/) | `bdicred` | Créditos | 21 | 🟢 BAJO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd` |

## Dependencias downstream — estos dominios llaman a `bdicobranza`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdicobranza` |
|----|--------------|---------|---------|-----------|----------------------|
| [D03](../D03-bdicred/) | `bdicred` | Créditos | 138 | 🟡 MEDIO | `bdicobranza:sp_inserta_bitacora_cob` |
| [D02](../D02-bdinteg/) | `bdinteg` | Integración y Auth | 13 | 🟢 BAJO | `bdicobranza:sp_inserta_bitacora_cob` |
| [D06](../D06-bdisolic/) | `bdisolic` | Solicitudes | 4 | 🟢 BAJO | `bdicobranza:sp_inserta_bitacora_cob` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdicobranza` → `bdimnsj` (53 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdicobranza`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicobranza:fn_formaretiquetaxml` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicobranza` y `bdimnsj`?


#### `bdicobranza` → `bdicred` (21 llamadas)

> Dominio destino: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicobranza`) | SP callee (`bdicred`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdicobranza:fn_formaretiquetaxml` | `bdicred:sp_consulta_saldos_general` | 435 fan-in | [SME-PENDING] |
| `bdicobranza:sp_generafechpagoreestructura` | `bdicred:monthadd` | 271 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdicobranza` y `bdicred`?


#### `bdicred` → `bdicobranza` (138 llamadas — este dominio como **proveedor**)

> Dominio origen: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdicobranza`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicred:sp_cac_consultasolincrelincred` | `bdicobranza:sp_inserta_bitacora_cob` | 406 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdicobranza` (13 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdicobranza`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:sp_desbctasfus_obtnombresupana` | `bdicobranza:sp_inserta_bitacora_cob` | 406 fan-in | [SME-PENDING] |


#### `bdisolic` → `bdicobranza` (4 llamadas — este dominio como **proveedor**)

> Dominio origen: **Solicitudes** (D06) · Wave: Wave 3

| SP caller (`bdisolic`) | SP callee (`bdicobranza`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdisolic:sp_demografica_grupo6` | `bdicobranza:sp_inserta_bitacora_cob` | 406 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdicobranza` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdicobranza (upstream):
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Créditos (bdicred) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdicobranza (downstream):
  - Para Créditos (bdicred): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]
  - Para Solicitudes (bdisolic): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Cobranza cruzan hacia otros dominios?
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
