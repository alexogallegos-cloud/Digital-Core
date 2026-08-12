# D10 · Sucursales — Dependencias entre Dominios

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdisuc` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
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
| Dominios de los que depende (upstream) | **1** |
| Dominios que dependen de este (downstream) | **2** |
| Llamadas cross-dominio salientes (total) | **27** |
| Llamadas cross-dominio entrantes (total) | **3,256** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdisuc` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdisuc` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 3 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdisuc` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D02](../D02-bdinteg/) | `bdinteg` | Integración y Auth | 27 | 🟢 BAJO | `bdinteg:sp_cnsif_confirmaejecutivo` |

## Dependencias downstream — estos dominios llaman a `bdisuc`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdisuc` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](../D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 3,255 | 🟠 ALTO | `bdisuc:sp_consultadatospiezas_bym3`, `bdisuc:sp_consutacat_dictamen_bym`, `bdisuc:sp_consultadatospiezas_bym2` |
| [D04](../D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 1 | 🟢 BAJO | `bdisuc:reversion` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdisuc` → `bdinteg` (27 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdisuc`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdisuc:sp_entrada_salida` | `bdinteg:sp_cnsif_confirmaejecutivo` | 2,400 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdisuc` y `bdinteg`?


#### `bdicnweb` → `bdisuc` (3,255 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdisuc`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym3` | 381 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consutacat_dictamen_bym` | 378 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym2` | 376 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultadatospiezas_bym3_totales` | 376 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consultacat_estatus_bym` | 375 fan-in | [SME-PENDING] |
| `bdicnweb:sp_bitacora` | `bdisuc:sp_consulta_catdenominacion_bym` | 374 fan-in | [SME-PENDING] |


#### `bdicheq` → `bdisuc` (1 llamadas — este dominio como **proveedor**)

> Dominio origen: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdisuc`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicheq:reversion` | `bdisuc:reversion` | 12 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdisuc` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdisuc (upstream):
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdisuc (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Sucursales cruzan hacia otros dominios?
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
