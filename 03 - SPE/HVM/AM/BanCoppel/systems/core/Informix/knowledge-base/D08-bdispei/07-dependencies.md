# D08 · SPEI — Dependencias entre Dominios

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdispei` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 2 · Riesgo: **CRÍTICO**
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
| Dominios de los que depende (upstream) | **3** |
| Dominios que dependen de este (downstream) | **1** |
| Llamadas cross-dominio salientes (total) | **69** |
| Llamadas cross-dominio entrantes (total) | **3** |
| Ratio de acoplamiento | **EMISOR NETO** (más salidas que entradas) |

## Impacto en la secuencia de migración

- **`bdispei` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdispei` esté listo:** (ninguno crítico)
- **Wave asignada:** Wave 2 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdispei` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](../D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 48 | 🟢 BAJO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:sp_cons_sdodisp_x_tpcalculo` |
| [D09](../D09-bdimnsj/) | `bdimnsj` | Mensajería | 19 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D02](../D02-bdinteg/) | `bdinteg` | Integración y Auth | 2 | 🟢 BAJO | `bdinteg:sp_desc_ret` |

## Dependencias downstream — estos dominios llaman a `bdispei`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdispei` |
|----|--------------|---------|---------|-----------|----------------------|
| [D04](../D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 3 | 🟢 BAJO | `bdispei:sp_validafecha` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdispei` → `bdicheq` (48 llamadas)

> Dominio destino: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdispei`) | SP callee (`bdicheq`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdispei:spei_aplicaordenpago` | `bdicheq:cargo_ref` | 561 fan-in | [SME-PENDING] |
| `bdispei:spei_aplicaordenpago` | `bdicheq:abono_ref` | 520 fan-in | [SME-PENDING] |
| `bdispei:sp_calc_comasiva` | `bdicheq:sp_cons_sdodisp_x_tpcalculo` | 131 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdispei` y `bdicheq`?


#### `bdispei` → `bdimnsj` (19 llamadas)

> Dominio destino: **Mensajería** (D09) · Wave: Wave 1

| SP caller (`bdispei`) | SP callee (`bdimnsj`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdispei:spei_aplicaordenpago` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdispei` y `bdimnsj`?


#### `bdispei` → `bdinteg` (2 llamadas)

> Dominio destino: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdispei`) | SP callee (`bdinteg`) | Fan-in callee | Contrato de interfaz target |
|-------------------|---------------------|--------------|----------------------------|
| `bdispei:sp_regordenspei` | `bdinteg:sp_desc_ret` | 358 fan-in | [SME-PENDING] |

> **[SME-PENDING]** Definir contrato API para reemplazar este puente:
> - ¿Es una operación síncrona (REST/gRPC) o asíncrona (evento/cola)?
> - ¿Qué datos se intercambian? ¿Hay estado compartido?
> - ¿La transacción es atómica entre `bdispei` y `bdinteg`?


#### `bdicheq` → `bdispei` (3 llamadas — este dominio como **proveedor**)

> Dominio origen: **Cheques / Cuentas** (D04) · Wave: Wave 4

| SP caller (`bdicheq`) | SP callee (`bdispei`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicheq:bloqueo_cta` | `bdispei:sp_validafecha` | 52 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdispei` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdispei (upstream):
  - Cheques / Cuentas (bdicheq) API: [SME-PENDING definir endpoint/evento]
  - Mensajería (bdimnsj) API: [SME-PENDING definir endpoint/evento]
  - Integración y Auth (bdinteg) API: [SME-PENDING definir endpoint/evento]

CONTRATOS QUE DEBE EXPONER bdispei (downstream):
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de SPEI cruzan hacia otros dominios?
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
