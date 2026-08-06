# BCOPCore — Matriz de Dependencias entre Dominios

> **Proyecto:** BanCoppel Application Modernization · SPE-AM-001
> **Fase:** DISCOVER Etapa 1 — Static Analysis
> **Última actualización:** 2026-07-03
> **Evidencia:** callgraph-data.json · 34,279 aristas totales · 30,701 cross-DB entre los 12 dominios

---
**SME responsable:**
- Specialist — Informix SPL Analysis (extracción del call graph)
- Architect — Application Modernization (diseño de ACL y contratos)
- Domain Expert — BanCoppel (validación de secuencia de migración)
---

## Matriz de llamadas cross-dominio

Filas = caller (quién llama). Columnas = callee (a quién llama). Valores = número de aristas únicas en el call graph.

| Caller \ Callee | [D01](../D01-bdicnweb/) `bdicnweb` | [D02](../D02-bdinteg/) `bdinteg` | [D03](../D03-bdicred/) `bdicred` | [D04](../D04-bdicheq/) `bdicheq` | [D05](../D05-bdisac/) `bdisac` | [D06](../D06-bdisolic/) `bdisolic` | [D07](../D07-bdiaclaracion/) `bdiaclar` | [D08](../D08-bdispei/) `bdispei` | [D09](../D09-bdimnsj/) `bdimnsj` | [D10](../D10-bdisuc/) `bdisuc` | [D11](../D11-bdicobranza/) `bdicobra` | [D12](../D12-bdicont/) `bdicont` | **Total OUT** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| [D01](../D01-bdicnweb/) `bdicnweb` | — | **11,391** 🔴 | **9,027** 🟠 | 494 🟡 | **2,601** 🟠 | 1,316 🟡 | · | · | 949 🟡 | **3,255** 🟠 | · | · | **29,033** |
| [D02](../D02-bdinteg/) `bdinteg` | 4 | — | 53 | 46 | 9 | 3 | · | · | 73 | · | 13 | · | **201** |
| [D03](../D03-bdicred/) `bdicred` | · | 39 | — | 242 🟡 | · | 15 | · | · | 77 | · | 138 | · | **511** |
| [D04](../D04-bdicheq/) `bdicheq` | 13 | 43 | 5 | — | 1 | · | · | 3 | 72 | 1 | · | · | **138** |
| [D05](../D05-bdisac/) `bdisac` | · | 12 | 21 | 312 🟡 | — | · | · | · | 10 | · | · | · | **355** |
| [D06](../D06-bdisolic/) `bdisolic` | · | 7 | 54 | 6 | · | — | · | · | 23 | · | 4 | · | **94** |
| [D07](../D07-bdiaclaracion/) `bdiaclar` | · | · | 21 | 125 | · | · | — | · | 34 | · | · | · | **180** |
| [D08](../D08-bdispei/) `bdispei` | · | 2 | · | 48 | · | · | · | — | 19 | · | · | · | **69** |
| [D09](../D09-bdimnsj/) `bdimnsj` | · | · | · | · | · | · | · | · | — | · | · | · | **0** |
| [D10](../D10-bdisuc/) `bdisuc` | · | 27 | · | · | · | · | · | · | · | — | · | · | **27** |
| [D11](../D11-bdicobranza/) `bdicobra` | · | · | 21 | · | · | · | · | · | 53 | · | — | · | **74** |
| [D12](../D12-bdicont/) `bdicont` | · | 19 | · | · | · | · | · | · | · | · | · | — | **19** |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| **Total IN** | **17** | **11,540** | **9,202** | **1,273** | **2,611** | **1,334** | **0** | **3** | **1,310** | **3,256** | **155** | **0** | |

> **Lectura:** `bdicnweb` (D01) llama masivamente a `bdinteg` (D02) y `bdicred` (D03). `bdimnsj` (D09) solo recibe llamadas — es hoja del grafo de dependencias.

## Top-15 dependencias más críticas (por volumen)

| Par | Llamadas | Nivel | SPs callee más invocados |
|-----|---------|-------|--------------------------|
| D01 `bdicnweb` → D02 `bdinteg` | 11,391 | 🔴 CRÍTICO | `bdinteg:sp_cnsif_confirmaejecutivo`, `bdinteg:sp_cnsif_permisosejecutivo`, `bdinteg:sp_valida_perfil_usuario` |
| D01 `bdicnweb` → D03 `bdicred` | 9,027 | 🔴 CRÍTICO | `bdicred:sp_consulta_saldos_general`, `bdicred:sp_mon_buro_conssolcredlincred2`, `bdicred:sp_inserta_productos` |
| D01 `bdicnweb` → D10 `bdisuc` | 3,255 | 🟠 ALTO | `bdisuc:sp_consultadatospiezas_bym3`, `bdisuc:sp_consutacat_dictamen_bym`, `bdisuc:sp_consultadatospiezas_bym2` |
| D01 `bdicnweb` → D05 `bdisac` | 2,601 | 🟠 ALTO | `bdisac:sp_validanombenefbts`, `bdisac:sp_sac_consucursales`, `bdisac:sp_validabts` |
| D01 `bdicnweb` → D06 `bdisolic` | 1,316 | 🟡 MEDIO | `bdisolic:sp_asigna_solicitud_soc`, `bdisolic:determina_lincred_tc_cjunk`, `bdisolic:sp_obtienegrupo` |
| D01 `bdicnweb` → D09 `bdimnsj` | 949 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| D01 `bdicnweb` → D04 `bdicheq` | 494 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| D05 `bdisac` → D04 `bdicheq` | 312 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| D03 `bdicred` → D04 `bdicheq` | 242 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:reversion` |
| D03 `bdicred` → D11 `bdicobranza` | 138 | 🟡 MEDIO | `bdicobranza:sp_inserta_bitacora_cob` |
| D07 `bdiaclaracion` → D04 `bdicheq` | 125 | 🟡 MEDIO | `bdicheq:cargo_ref`, `bdicheq:abono_ref`, `bdicheq:bloqueo_cta` |
| D03 `bdicred` → D09 `bdimnsj` | 77 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| D02 `bdinteg` → D09 `bdimnsj` | 73 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| D04 `bdicheq` → D09 `bdimnsj` | 72 | 🟡 MEDIO | `bdimnsj:sp_registra_evento` |
| D06 `bdisolic` → D03 `bdicred` | 54 | 🟡 MEDIO | `bdicred:sp_consulta_saldos_general`, `bdicred:monthadd`, `bdicred:genmov` |

## Orden de migración por Wave

La secuencia de migración debe respetar las dependencias: un dominio no puede migrarse hasta que sus dominios upstream estén disponibles como APIs.

| Wave | Dominios | Pre-requisitos (>500 llamadas) |
|------|----------|-------------------------------|
| Wave 1 | [D09](../D09-bdimnsj/) `bdimnsj` | (sin prereqs críticos entre los 12 dominios) |
| Wave 2 | [D07](../D07-bdiaclaracion/) `bdiaclaracion`, [D08](../D08-bdispei/) `bdispei`, [D11](../D11-bdicobranza/) `bdicobranza` | (sin prereqs críticos entre los 12 dominios) |
| Wave 3 | [D05](../D05-bdisac/) `bdisac`, [D06](../D06-bdisolic/) `bdisolic`, [D10](../D10-bdisuc/) `bdisuc` | (sin prereqs críticos entre los 12 dominios) |
| Wave 4 | [D03](../D03-bdicred/) `bdicred`, [D04](../D04-bdicheq/) `bdicheq`, [D12](../D12-bdicont/) `bdicont` | (sin prereqs críticos entre los 12 dominios) |
| Wave 5 | [D02](../D02-bdinteg/) `bdinteg` | (sin prereqs críticos entre los 12 dominios) |
| ÚLTIMO | [D01](../D01-bdicnweb/) `bdicnweb` | `bdicred` (Wave 4), `bdinteg` (Wave 5), `bdisac` (Wave 3), `bdisolic` (Wave 3),  |

## Grafo de dependencias — descripción textual

```
WAVE 1 (hojas — sin dependencias upstream):
  bdimnsj (Mensajería) ← recibe de todos, no llama a nadie crítico

WAVE 2 (soporte funcional):
  bdiaclaracion → bdinteg, bdicheq, bdimnsj
  bdispei       → bdinteg, bdicheq
  bdicobranza   → bdinteg, bdicred, bdimnsj

WAVE 3 (core funcional):
  bdisac   → bdinteg, bdicheq
  bdisolic → bdinteg, bdicred
  bdisuc   → bdinteg, bdicheq, bdimnsj

WAVE 4 (primitivos financieros):
  bdicred  → bdinteg, bdicheq, bdimnsj
  bdicheq  → bdinteg              ← CRÍTICO: cargo_ref/abono_ref
  bdicont  → bdinteg, bdicheq, bdicred, bdisac

WAVE 5 (backbone de integración):
  bdinteg  → (minimal upstream)   ← todos dependen de él

ÚLTIMO (canal de presentación):
  bdicnweb → TODOS LOS DOMINIOS   ← mayor fan-out, migra al final
```

## Anti-Corruption Layer (ACL) — contratos requeridos

Cada flecha en la matriz representa un contrato de interfaz a diseñar. Los contratos de mayor prioridad (mayor volumen o riesgo):

| # | Contrato | Tipo sugerido | Razón |
|---|----------|--------------|-------|
| 1 | `bdinteg` expone `sp_cnsif_confirmaejecutivo` | REST API (AuthService) | 2,400 callers — centralidad máxima |
| 2 | `bdicheq` expone `cargo_ref` / `abono_ref` | gRPC (TransactionService) | Atomicidad financiera requerida |
| 3 | `bdimnsj` expone `sp_registra_evento` | Async (EventBus/SQS) | Idempotente — candidato a evento |
| 4 | `bdinteg` → todos | API Gateway interno | Reemplaza routing cross-DB de bdicnweb |
| 5 | `bdispei` expone interfaces SPEI | REST certificado Banxico | Regulatorio — contrato fijo Banxico |

## Componentes técnicos transversales

Componentes técnicos que son compartidos por múltiples dominios y deben estar listos antes que sus dependientes:

| Componente | Tipo | Dominios dependientes | Prioridad |
|-----------|------|-----------------------|----------|
| `bdinteg:sp_cnsif_confirmaejecutivo` | SP / futuro AuthService | D01, D03, D04, D05, D06, D07, D08, D10, D11, D12 | 🔴 CRÍTICA |
| `bdicheq:cargo_ref` | SP / futuro TransactionService | D01, D03, D05, D06, D07, D08, D10 | 🔴 CRÍTICA |
| `bdicheq:abono_ref` | SP / futuro TransactionService | D01, D03, D05, D06, D07, D08 | 🔴 CRÍTICA |
| `bdimnsj:sp_registra_evento` | SP / futuro EventBus | D01, D03, D04, D05, D06, D07, D10, D11 | 🟠 ALTA |
| Anti-Corruption Layer (ACL) | Infraestructura | Todos | 🔴 CRÍTICA |
| IBM Informix IDS 14.10 (instancia) | Motor DB | Todos | 🔴 CRÍTICA |
| IBM POWER-AIX DCMSIF01/02 | Servidor | Todos | 🟠 ALTA |

---
*Generado por: Specialist — Informix SPL Analysis · 2026-07-03 · Evidencia: callgraph-data.json*
