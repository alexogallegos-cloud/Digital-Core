# D09 · Mensajería — Dependencias entre Dominios

> **Componente:** LegacyCore · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** `bdimnsj` · IBM Informix IDS 14.10 FC10W2 / POWER-AIX
> **Wave de migración:** Wave 1 · Riesgo: **BAJO**
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
| Dominios de los que depende (upstream) | **0** |
| Dominios que dependen de este (downstream) | **9** |
| Llamadas cross-dominio salientes (total) | **0** |
| Llamadas cross-dominio entrantes (total) | **1,310** |
| Ratio de acoplamiento | **RECEPTOR NETO** (más entradas que salidas) |

## Impacto en la secuencia de migración

- **`bdimnsj` bloquea su propia migración hasta que estén listos:** (ninguno crítico)
- **Dominios que no pueden migrar hasta que `bdimnsj` esté listo:** `bdicnweb`
- **Wave asignada:** Wave 1 — debe respetarse estrictamente o los dominios dependientes rompen.

## Dependencias upstream — `bdimnsj` llama a estos dominios

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs callee principales |
|----|--------------|---------|---------|-----------|----------------------|
| (sin dependencias upstream en los 12 dominios) | | | | | |

## Dependencias downstream — estos dominios llaman a `bdimnsj`

| ID | Base de datos | Dominio | Llamadas | Criticidad | SPs que expone `bdimnsj` |
|----|--------------|---------|---------|-----------|----------------------|
| [D01](D01-bdicnweb/) | `bdicnweb` | Canal Digital Web | 949 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| [D03](D03-bdicred/) | `bdicred` | Créditos | 77 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D02](D02-bdinteg/) | `bdinteg` | Integración y Auth | 73 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D04](D04-bdicheq/) | `bdicheq` | Cheques / Cuentas | 72 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D11](D11-bdicobranza/) | `bdicobranza` | Cobranza | 53 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D07](D07-bdiaclaracion/) | `bdiaclaracion` | Aclaraciones | 34 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D06](D06-bdisolic/) | `bdisolic` | Solicitudes | 23 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D08](D08-bdispei/) | `bdispei` | SPEI | 19 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |
| [D05](D05-bdisac/) | `bdisac` | Saldos y Cuentas | 10 | 🟢 BAJO | `bdimnsj:sp_registra_evento` |

## Detalle de puentes SP-a-SP (bridges)

Para cada par de dominios conectados, se listan los SPs de mayor fan-in en el callee (= SPs más críticos a convertir en API):


#### `bdicnweb` → `bdimnsj` (949 llamadas — este dominio como **proveedor**)

> Dominio origen: **Canal Digital Web** (D01) · Wave: ÚLTIMO

| SP caller (`bdicnweb`) | SP callee (`bdimnsj`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicnweb:sp_bitacora` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |


#### `bdicred` → `bdimnsj` (77 llamadas — este dominio como **proveedor**)

> Dominio origen: **Créditos** (D03) · Wave: Wave 4

| SP caller (`bdicred`) | SP callee (`bdimnsj`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdicred:altatarcred_v_1` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |


#### `bdinteg` → `bdimnsj` (73 llamadas — este dominio como **proveedor**)

> Dominio origen: **Integración y Auth** (D02) · Wave: Wave 5

| SP caller (`bdinteg`) | SP callee (`bdimnsj`) | Fan-in callee | Servicio target a exponer |
|---------------------|--------------------|--------------|--------------------------|
| `bdinteg:consnumcte_n_web` | `bdimnsj:sp_registra_evento` | 1,404 fan-in | [SME-PENDING] |


## Contratos de interfaz requeridos (Anti-Corruption Layer)

En el target distribuido, **cada puente cross-DB se convierte en un contrato de interfaz**. Para `bdimnsj` se requieren:

```
[SME-PENDING + Architect — Application Modernization]

CONTRATOS QUE DEBE CONSUMIR bdimnsj (upstream):

CONTRATOS QUE DEBE EXPONER bdimnsj (downstream):
  - Para Canal Digital Web (bdicnweb): [SME-PENDING definir endpoint/evento]
  - Para Créditos (bdicred): [SME-PENDING definir endpoint/evento]
  - Para Integración y Auth (bdinteg): [SME-PENDING definir endpoint/evento]
  - Para Cheques / Cuentas (bdicheq): [SME-PENDING definir endpoint/evento]
  - Para Cobranza (bdicobranza): [SME-PENDING definir endpoint/evento]
  - Para Aclaraciones (bdiaclaracion): [SME-PENDING definir endpoint/evento]

```

## Transacciones distribuidas (BEGIN WORK cross-DB)

En Informix, todas las llamadas cross-DB dentro de un `BEGIN WORK … COMMIT WORK` son atómicas (motor único). En el target distribuido esto requiere:

```
[SME-PENDING] ¿Cuáles transacciones de Mensajería cruzan hacia otros dominios?
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
