# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Dependencias del Dominio

> **Componente:** Informix · SPE-AM-001 · Etapa 1 — Static Analysis
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Mapa de dependencias

```
                    [CNBV / SHCP / SAT]
                           ▲
                   (reportes regulatorios)
                           │
         ┌─────────────────┼─────────────────┐
         │                 │                 │
  [D01-bdicnweb]    [D02-bdinteg]     [D03-bdicred]
  (canal digital)   (integración)      (crédito)
         │                 │                 │
         └─────────────────┼─────────────────┘
                           │  (consultas LIDE en journeys)
                           ▼
                    ┌──────────────┐
                    │  bdilide     │  ← D15 (este dominio)
                    │  (LIDE/PLD)  │
                    └──────┬───────┘
                           │
            ┌──────────────┼──────────────┐
            │              │              │
     [bdinteg]         [bdicheq]      [bdicred]
     (integración)     (cheques)      (crédito)
     · si_fechas       · sc_fechas    · sd_fechas
     · si_cliente      · sc_movdia    · sd_movhis
     · sx_contproc     · sc_movhis    · sd_movdia
                           │
                    [Buró de Crédito]
                    (sistema externo)
```

## Dependencias entrantes (quién llama a bdilide)

| Dominio origen | Base de datos | Tipo de dependencia | Criticidad | Notas |
|---------------|--------------|--------------------|-----------:|-------|
| D01-bdicnweb (canal digital) | `bdicnweb` | Verificación LIDE en onboarding | 🔴 CRÍTICA | Bloquea el alta de nuevos clientes si LIDE no responde |
| D02-bdinteg (integración) | `bdinteg` | Verificación LIDE en autenticación | 🔴 CRÍTICA | Bloquea transacciones si LIDE no responde |
| D03-bdicred (crédito) | `bdicred` | Consulta LIDE pre-otorgamiento | 🔴 CRÍTICA | Bloquea el otorgamiento de crédito si LIDE no responde |
| `[DATO-REQUERIDO]` | `[DATO-REQUERIDO]` | 4to y 5to caller del callgraph | `[DATO-REQUERIDO]` | Identificar los 5 SPs del callgraph |

## Dependencias salientes (bdilide llama a quién)

| Dominio destino | Base de datos | Tabla | Tipo de acceso | Criticidad |
|----------------|--------------|-------|---------------|-----------|
| D02-bdinteg | `bdinteg` | `si_fechas` | SELECT, UPDATE | 🔴 CRÍTICA — sincronización de fecha de proceso |
| D02-bdinteg | `bdinteg` | `si_cliente` | SELECT | 🔴 CRÍTICA — datos del cliente para análisis PLD |
| D02-bdinteg | `bdinteg` | `sx_contproc` | INSERT | 🟠 ALTA — registro de control de proceso |
| D04-bdicheq | `bdicheq` | `sc_fechas` | SELECT, UPDATE | 🔴 CRÍTICA — sincronización de fecha en cuentas |
| D04-bdicheq | `bdicheq` | `sc_movdia` | INSERT | 🟠 ALTA — movimientos del día |
| D04-bdicheq | `bdicheq` | `sc_movhis` | SELECT | 🟠 ALTA — historial de movimientos |
| D03-bdicred | `bdicred` | `sd_fechas` | UPDATE | 🔴 CRÍTICA — sincronización de fecha en crédito |
| D03-bdicred | `bdicred` | `sd_movhis` | SELECT | 🟠 ALTA — historial de movimientos crédito |
| D03-bdicred | `bdicred` | `sd_movdia` | INSERT | 🟠 ALTA — movimientos del día crédito |

## Dependencias externas

| Sistema externo | Tipo de integración | Protocolo | Datos intercambiados | Regulatorio |
|----------------|--------------------|-----------|--------------------|:-----------:|
| Buró de Crédito | Consulta de historial crediticio | `[DATO-REQUERIDO]` — protocolo CHI (inferido) | RFC, CURP, historial | Sí — CNBV |
| SAT | Intercambio de archivos IDE/exentos | Archivo estructurado (batch) | RFC, status exento, montos | Sí — SAT/LIDE |
| CNBV / UIF | Envío de reportes PLD | Archivo estructurado (batch) | Operaciones inusuales, relevantes, preocupantes | Sí — LFPIORPI |
| SHCP | Envío de reportes de operaciones relevantes | Archivo estructurado (batch) | Operaciones > $7,500 USD | Sí — LFPIORPI |
| OFAC (indirecto) | Actualización de lista | `[DATO-REQUERIDO]` | Lista de personas sancionadas | Sí — compliance |
| ONU / INTERPOL | Actualización de lista | `[DATO-REQUERIDO]` | Lista de terroristas/lavado | Sí — FATF |

## Impacto en el orden de migración (Wave 4)

Para que `bdilide` pueda migrarse, los dominios de los que depende deben estar disponibles en el target o tener un mecanismo de compatibilidad:

| Prerequisito | Dominio | Estado requerido al momento del cutover D15 |
|-------------|---------|---------------------------------------------|
| `si_cliente` disponible | D02-bdinteg | API o vista disponible en el target |
| `si_fechas` sincronizable | D02-bdinteg | El ejecutor diario debe poder actualizar este registro |
| `sc_fechas`, `sc_movdia`, `sc_movhis` | D04-bdicheq | API o acceso directo disponible |
| `sd_fechas`, `sd_movhis`, `sd_movdia` | D03-bdicred | API o acceso directo disponible |

> **Nota:** Si los dominios D02, D03 y D04 no están migrados cuando se migre D15, se requiere un mecanismo de acceso cross-DB hacia el Informix legacy. Este es el patrón estándar de Wave 4 — `bdilide` depende de que los dominios previos tengan sus ACL publicadas.

## `[SME-PENDING]`

- [ ] Identificar los 5 SPs exactos en el callgraph y sus dominios llamantes.
- [ ] Confirmar el protocolo de comunicación con el Buró de Crédito (¿SOAP? ¿archivo? ¿API REST?).
- [ ] Documentar los formatos exactos de los archivos enviados a CNBV, SHCP y SAT.
- [ ] Definir el mecanismo de actualización de las listas OFAC y ONU.
- [ ] Confirmar si existe un SLA con el Buró de Crédito para el tiempo de respuesta de consultas.

---
*Generado: análisis estático bdilide · 2026-08-03*
