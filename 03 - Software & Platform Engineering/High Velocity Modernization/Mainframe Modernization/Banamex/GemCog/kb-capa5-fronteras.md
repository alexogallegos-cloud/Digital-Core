# KB — Capa 5: Fronteras · Bounded Contexts + 7R + Wave Map
## Banamex · GemCog · S500 Cargos y Abonos + S151 Movimientos Contables GL

> **Capa 5 en la metodología GemCog:** pivote AS-IS → TO-BE. Toma el conocimiento acumulado en Capas 1-4 (lenguaje, almas, biografía, intención) y lo convierte en decisiones de arquitectura target: cuáles son los Bounded Contexts del sistema modernizado, qué ruta 7R toma cada programa, y en qué Wave se ejecuta cada transformación.
>
> **Executor:** `Specialist - 7R Assessment` (Fase 1 - Discover · gate de salida)
> **Fecha de análisis:** 2026-07-14 · Basada en Etapas 1-3 completadas (S500 + S151)

---

## 1. Inputs Disponibles de Capas 1–4

| Input | Fuente | Estado |
|-------|--------|--------|
| Inventario 218 programas (id, tipo, LOC, dominio) | `gemelo-s{500,151}.json` | ✅ Completo |
| Call graph 1,059 aristas PERFORM/CALL | `dependency-graph-s{500,151}.json` | ✅ Completo |
| 143 términos vocabulario v2.2 + 5 colisiones | `vocab-s{500,151}.json` | ✅ Completo |
| 118 autores + bus factor + % huérfanos | `souls-s{500,151}.json` | ✅ Completo |
| 63 reglas de negocio (47 S500 + 16 S151) con flags regulatorios | `rules-report-gemcog.html` | ✅ Completo |
| Scores ISO 5055 por programa (4 factores) | `quality-gemcog.html` | ✅ Parcial — inferido, no auditado formalmente |
| MIPS/EPC consumption por programa | — | ❌ No disponible — Unisys usa modelo EPC distinto a IBM Z |

**Gaps de input que afectan la calidad del 7R:**
- **ISO 5055 formal**: los scores en `quality-gemcog.html` son el análisis estático del Code Quality Specialist con las reglas disponibles. No han sido validados por un auditor externo. Para ADRs firmables en banca CNBV, se recomienda validación con herramienta certificada (Cast Highlight u equivalente) en Wave 2+.
- **Flags regulatorios confirmados**: los flags CNBV/Banxico/SAT/CONDUSEF en `rules-report-gemcog.html` son inferidos del análisis estático (IF/EVALUATE que mencionan conceptos regulatorios). Para programas Retain, el Regulatory SME debe confirmar antes del ADR.
- **EPC Unisys**: sin datos de consumo por programa, el driver financiero de salida debe venir de la factura global de licenciamiento Unisys ClearPath vs costo target. Unisys Banking SME puede proveer el modelo EPC.

---

## 2. Los 9 Bounded Contexts del Target

Derivados de los 8 dominios canónicos (Capas 1-4) + 1 contexto de interfaz cross-sistema.

### S500 — 4 Bounded Contexts

| ID | Bounded Context | Dominio origen | Programas candidatos | LOC estimado |
|----|----------------|----------------|---------------------|--------------|
| BC-01 | **Cuentas de Captación** | CAPTACION (core) | P010, P050, P080, P142, P144, P165, P305 + batch CAPCARGOP, PAGSPEIEN | ~180K LOC |
| BC-02 | **Control Operacional** | CONTROL | P030 (fecha), P040 (día), L010, L020 + MAPLI, TELETON, ASINCRONA | ~60K LOC |
| BC-03 | **Tarjetas Débito** | TARJETAS | P130 S500 (sucursales), BD04 (intercambio) | ~25K LOC |
| BC-04 | **ACL GL Interface** ⭐ | Cross-system (S500→S151) | L002R2, L002R3, L002R4, L002R5 (S151REGISTRA) | ~28K LOC |

> ⭐ **BC-04 es el Anti-Corruption Layer crítico.** Es la frontera donde S500 escribe al GL de S151 vía la biblioteca `S151REGISTRA`. Debe ser el primer bounded context encapsulado — ningún otro BC puede modernizarse hasta que BC-04 tenga su API estabilizada.

### S151 — 5 Bounded Contexts

| ID | Bounded Context | Dominio origen | Rango de programas | LOC estimado |
|----|----------------|----------------|--------------------|--------------|
| BC-05 | **General Ledger** | CONTABILIDAD | P100–P199 (40 pgm) · escritura de asientos | ~180K LOC |
| BC-06 | **Procesamiento de Movimientos** | MOVIMIENTOS | P001–P099 (27 pgm) · P130 S151 Agrupador ⚠COLISIÓN | ~120K LOC |
| BC-07 | **Control GL** | CTRL-GL | P200–P299 (21 pgm) · P015 S151 ActMov ⚠COLISIÓN · base semanal | ~80K LOC |
| BC-08 | **Reportería GL** | REPORTES | P600–P699 (13 pgm) · salidas regulatorias | ~50K LOC |
| BC-09 | **Ajustes GL** | AJUSTES | P300–P399 (3 pgm) · ajustes manuales y reversiones | ~15K LOC |

**Colisiones de nomenclatura (riesgo de wave plan):**
- `P130` existe en BC-03 (S500 · sucursales) Y BC-06 (S151 · agrupador). Son programas completamente distintos con funciones distintas — requieren IDs de componente target diferenciados desde el primer ADR.
- `P015` existe en BC-02 (S500 · control de fecha) Y BC-07 (S151 · ActMov semanal). Misma situación.
- En el wave plan y SME roster, siempre usar prefijo: `S500/P130` vs `S151/P130`.

---

## 3. Decisión 7R por Tipo de Programa

Aplicación del framework del `Specialist - 7R Assessment` al stack Unisys ClearPath MCP.

### Reglas de decisión calibradas para Banamex S500+S151

```
¿El programa es ALGOL (L-prefix)?
  SÍ → RETAIN + evaluar ENCAPSULATE si es interfaz crítica
       Rationale: No existe transpiler para ALGOL Unisys MCP.
       Excepción: L002R2-R5 (S151REGISTRA) → ENCAPSULATE (BC-04 ACL)
       SME: Unisys Banking SME advisory obligatorio

¿El programa es DASDL (schema de base de datos DMSII)?
  SÍ → RETAIN hasta Fase 6 (Data Migration)
       Rationale: La migración del modelo de datos DMSII es una actividad
       separada que requiere un plan CDC + dual-write propio.
       No se refactoriza — se migra como parte de Fase 6.

¿El programa es WFL (job scheduler)?
  SÍ → REPLATFORM → Argo Workflows / AWS Step Functions
       Rationale: WFL no tiene equivalente COBOL que transpilar;
       es lógica de orquestación que se reescribe en el scheduler target.
       Requiere Specialist - Batch Architecture para mapear dependencias entre jobs.

¿El programa es INC/COPY (copybook)?
  SÍ → RETAIN (migra con el programa que lo usa)
       Se convierte en clase/record compartido en el target.

¿El programa no aparece en el call graph Y LOC < 500?
  SÍ → RETIRE_CANDIDATE
       ALERTA: verificar contra WFL que puedan llamarlo fuera del call graph analizado.
       No emitir RETIRE definitivo sin confirmación del RE Specialist.

¿El programa tiene flag regulatorio CNBV/Banxico Y LOC > 5,000?
  SÍ → RETAIN o ENCAPSULATE_PRIMERO
       Rationale: El riesgo de regresión regulatoria supera el beneficio
       de velocidad en Wave 1. Encapsular primero crea la fachada API
       mientras el COBOL interno sigue corriendo en MCP (coexistencia).

¿El programa tiene flag regulatorio CNBV/Banxico Y LOC ≤ 5,000?
  SÍ → ENCAPSULATE → REFACTOR en Wave 2
       La API estabilizada en Wave 0/1 reduce el riesgo del refactor posterior.

¿El programa es $SET S151REGISTRA (S500 que escribe al GL)?
  SÍ → Su decisión 7R está ACOPLADA a BC-04 (ACL GL Interface).
       No puede moverse de forma independiente.
       Requiere que BC-04 esté encapsulado primero.

¿El programa es COBOL limpio (sin flags regulatorios, ISO 5055 ≥ medio)?
  LOC < 3,000 → REFACTOR Wave 1 (candidato a transpilación Specialist - Transpilation)
  LOC 3,000-8,000 → REFACTOR Wave 2
  LOC > 8,000 → evaluar Specialist - Batch Architecture si es batch;
                 si es online → REFACTOR Wave 2 con revisión humana ampliada
```

### Tabla resumen por tipo de objeto

| Tipo | Conteo S500 | Conteo S151 | Decisión default | Wave |
|------|-------------|-------------|-----------------|------|
| COBOL (P-prefix, sin flags) | ~30 | ~50 | REFACTOR | 1–2 |
| COBOL (P-prefix, con flags CNBV/Banxico) | ~20 | ~15 | ENCAPSULATE → REFACTOR | 0–2 |
| ALGOL (L-prefix, no S151REGISTRA) | ~11 | ~12 | RETAIN | Retain pool |
| ALGOL S151REGISTRA (L002R2-R5) | — | 4 | ENCAPSULATE ⭐ | Wave 0 |
| DASDL (BD*/S151BD*) | 7 | 6 | RETAIN → Fase 6 | Retain/Fase 6 |
| WFL (jobs) | 4 | 3 | REPLATFORM | Wave 4 |
| INC/COPY (copybooks) | 11 | — | RETAIN (con su programa) | — |
| INC L010/L020 (críticos) | 2 | — | RETAIN (shared library) | Retain pool |

---

## 4. Wave Map — Plan de Modernización

### Prerrequisito global: Wave 0 (ACL Foundation)

**Debe completarse ANTES de cualquier otra wave.**

| Programa | BC | Decisión | Acción | SME |
|----------|----|----------|--------|-----|
| S151/L002R2 S151REGISTRA | BC-04 | ENCAPSULATE | API REST/gRPC sobre ALGOL intacto · z/OS Connect o MuleSoft adapter | Specialist - Encapsulation |
| S151/L002R3 S151REGISTRA | BC-04 | ENCAPSULATE | Misma fachada API | Specialist - Encapsulation |
| S151/L002R4 S151REGISTRA | BC-04 | ENCAPSULATE | Misma fachada API | Specialist - Encapsulation |
| S151/L002R5 S151REGISTRA | BC-04 | ENCAPSULATE | Misma fachada API | Specialist - Encapsulation |

**Output de Wave 0:** API `GL-Posting-Service` que abstrae S151REGISTRA. Todos los programas S500 que hacen `$SET S151REGISTRA` deben apuntar a este servicio — sin tocar su COBOL interno aún.

**Dependencia regulatoria:** CNBV debe ser notificada si el cambio de interfaz modifica la trazabilidad de asientos contables. Verificar con Regulatory SME antes de corte a producción de Wave 0.

---

### Wave 1 — COBOL de bajo riesgo (sin flags regulatorios, LOC < 3K)

Candidatos: programas COBOL de CONTROL y TARJETAS sin flags CNBV/Banxico confirmados.

| BC candidato | Criterio de entrada | Parallelismo |
|-------------|--------------------|-----------  |
| BC-02 Control Operacional | Sin flags regulatorios · LOC medio | Hasta 3 programas en paralelo |
| BC-03 Tarjetas | 1 programa principal S500/P130 | Secuencial — verificar colisión |
| BC-09 Ajustes GL | 3 programas, bajo LOC | Hasta 3 en paralelo |

**Gate de salida Wave 1:**
- Equivalence-check ≥ 99.95% (Application Modernization standard — estos no tienen flag CNBV directo)
- Parallel-run ≥ 2 sprints
- BC-04 ACL operacional y estable

---

### Wave 2 — COBOL core con flags regulatorios

Candidatos: P142, P144 (CAPTACION · S500 · CNBV + Banxico), P100-P199 seleccionados (CONTABILIDAD S151).

| BC candidato | Criterio de entrada | Gate adicional |
|-------------|--------------------|--------------  |
| BC-01 Cuentas de Captación | Wave 1 verde · BC-04 estable | Equivalence ≥ 99.99% · CNBV |
| BC-05 General Ledger (parcial) | Wave 0 verde · BC-04 estable | Equivalence ≥ 99.99% · reconciliación diaria |
| BC-06 Movimientos (parcial) | Depende de BC-05 parcial | Equivalence ≥ 99.99% |

**Gate de salida Wave 2:**
- Equivalence-check ≥ **99.99%** (banca CNBV · reconciliación contable diaria)
- Parallel-run ≥ 3 meses
- Auditoría interna sign-off mensual

---

### Wave 3 — Batch pesado (Batch Architecture sign-off obligatorio)

Candidatos: programas batch WFL LOTE con DMSII BLOCK CONTAINS complejos.

**Prerequisito:** Specialist - Batch Architecture completa el análisis de throughput de ventana batch ANTES de iniciar transpilación. Sin ese sign-off, prohibido.

| BC candidato | Acción | SME principal |
|-------------|--------|--------------|
| BC-01 batch jobs CAPCARGOP | Rewrite batch en Argo Workflows + Java | Specialist - Batch Architecture → Transpilation |
| BC-06 jobs de cierre GL | Rewrite batch scheduler | Specialist - Batch Architecture → Transpilation |

---

### Wave 4 — WFL Jobs (REPLATFORM)

Los 7 WFL jobs (4 S500 + 3 S151) se reescriben como DAGs en Argo Workflows o AWS Step Functions. No es transpilación — es reescritura de orquestación.

**Parallel-run especial:** los WFL pueden correr en shadow durante 1 sprint adicional comparando logs de ejecución batch.

---

### Retain Pool (indefinido — revisar cada ciclo)

| Categoría | Programas | Rationale | Revisión |
|-----------|-----------|-----------|----------|
| ALGOL no interfaz | S500 L010-L080, S151 L001, L006, L009, L030 (¡COLISIÓN!), L050 | Sin transpiler. Encapsular si se necesita funcionalidad en target. | Cada 6 meses o cuando haya herramienta |
| DASDL schemas | S500 BD01-BD26, S151 S151BD* (6 schemas) | Data model — migrar en Fase 6 con CDC | Junto con Fase 6 |
| COBOL regulatorio crítico alta complejidad | P-programs con CNBV + LOC > 8K + ISO 5055 bajo | Riesgo de regresión > beneficio | Después de Wave 2 exitosa |
| Dead code candidates | Programas sin conexiones en call graph | Verificar con RE Specialist + WFL antes de marcar Retire | Sprint de verificación |

---

## 5. Análisis de SME Agents

### Agents que YA EXISTEN y cubren Capa 5

| Agent | Ubicación | Rol en Capa 5 | Estado |
|-------|-----------|--------------|--------|
| **Specialist - 7R Assessment** | `Fase 1 - Discover/Specialist - 7R Assessment/` | **Executor principal** — emite ADR-SPE-MM-001 por programa, wave map, SME roster | ✅ Existe |
| **Specialist - Encapsulation** | `Fase 4 - Encapsulate/Specialist - Encapsulation/` | Ejecuta Wave 0 — API-fy de S151REGISTRA (BC-04) | ✅ Existe |
| **Specialist - Transpilation** | `Fase 5 - Modernize/Specialist - Transpilation/` | Ejecuta Wave 1-3 REFACTOR | ✅ Existe |
| **Specialist - Batch Architecture** | `Fase 5 - Modernize/Specialist - Batch Architecture/` | Sign-off obligatorio antes de Wave 3 | ✅ Existe |
| **Specialist - Reverse Engineering** | `Fase 1 - Discover/Specialist - Reverse Engineering/` | Valida dead code candidates antes de RETIRE · actualiza inventario con estado 7R | ✅ Existe |
| **Specialist - GemCog Chatbot** | `Fase 1 - Discover/Specialist - GemCog Chatbot/` | Consulta interactiva sobre el análisis | ✅ Existe |

### Agents SME en Solutioning (advisory — NO ejecutores)

| Agent | Solutioning path | Rol en Capa 5 |
|-------|-----------------|--------------|
| **Mainframe Migration SME** | `Solutioning/Delivery - SME/Infrastructure/Mainframe Migration/` | Validación metodológica de decisiones 7R · business case · sign-off de wave plan |
| **Unisys Banking SME** | `Solutioning/Delivery - SME/Platform/Unisys Banking/` | Advisory obligatorio para cualquier decisión sobre ALGOL S151 (TellerVision, Forward!, Elevate) |
| **Code Quality Specialist** | `Solutioning/Delivery - SME/Technology/Software Engineering/Specialist - Code Quality Assessment/` | Validación formal de scores ISO 5055 si se requiere ADR firmable |
| **Regulatory SME** | `Fase 2 - Regulatory/` (carpeta-puntero) | Confirmación de flags CNBV/Banxico por programa antes de ADR Wave 2+ |

### ¿Se necesita un nuevo agent?

| Gap identificado | Decisión |
|-----------------|---------|
| **Unisys EPC Economics** — no hay datos de consumo por programa | ❌ No crear nuevo specialist. El driver financiero viene de licencia global Unisys vs costo target cloud. Unisys Banking SME puede proveer el modelo EPC. Documentar en ADR como `[DATO-REQUERIDO]`. |
| **ISO 5055 auditor externo** — scores son inferidos, no certificados | ❌ No crear specialist. Usar herramienta externa (Cast Highlight) para programas de Wave 2+. Activar vía Code Quality Specialist en Solutioning. |
| **Dead Code Verification** — RE Specialist debe verificar WFL antes de RETIRE | ✅ **Este trabajo ya corresponde al RE Specialist existente** — solo necesita instrucción explícita: leer los 7 WFL jobs y construir la lista de programas llamados desde WFL que podrían no aparecer en el call graph estático COBOL. |

**Conclusión:** No se requieren nuevos agents SME. El roster existente cubre Capa 5 completa. El único trabajo nuevo es la verificación de dead code via WFL que hace el RE Specialist.

---

## 6. Anti-Corruption Layer — Diseño de BC-04

El ACL entre S500 y S151 es la pieza arquitectónica más crítica del engagement.

### Estado actual (AS-IS)

```
S500/P142 (CAPTACION) ──CALL ENLACE_8D──→ S151/L002R2 S151REGISTRA
S500/P144 (CAPTACION) ──CALL ENLACE_8D──→ S151/L002R3 S151REGISTRA
S500/P010 (CAPTACION) ──CALL ENLACE_8D──→ S151/L002R4 S151REGISTRA
[otros P-programs con $SET S151REGISTRA] → S151/L002R5 S151REGISTRA
```

La llamada `ENLACE_8D` es la única puerta de entrada al GL. Los 4 programas ALGOL L002Rx procesan:
- `GRABALOG` — escritura de asientos en jerarquía NIVLOG (header HD + descriptores de 890 bytes)
- `DFELIMINA` — cascada de cancelación de asientos (6 condiciones · errores 9/11/12/13/15)
- `GRABASDO` — registros TESOFE SDO 65 palabras (2019)

### Target (TO-BE) — GL Posting Service API

```
[S500 modernizado] ──HTTP/gRPC──→ GL-Posting-Service ──→ [S151 ALGOL intacto o modernizado]
                                          │
                                   Contrato OpenAPI 3.1:
                                   POST /gl/entries        (GRABALOG)
                                   DELETE /gl/entries/{id} (DFELIMINA)
                                   POST /gl/tesofe         (GRABASDO)
```

**Contrato de equivalencia obligatorio para BC-04:**
- Toda llamada a `GL-Posting-Service` debe producir **exactamente** el mismo asiento que la llamada directa a `ENLACE_8D`
- Equivalence ≥ 99.99% — el asiento contable es el registro más auditable del banco
- El comparator del parallel-run debe correr en **tiempo real** (no batch): cada transacción S500 que llame a BC-04 debe reconciliarse en el mismo día hábil

**ADR requerido:** `ADR-SPE-MM-004` — Data sync strategy para BC-04 (dual-write mientras ALGOL S151 sigue en MCP)

---

## 7. Dependency Constraints — Qué Bloquea Qué

```
Wave 0 (BC-04 ACL)
  └── BLOQUEA TODA la migración posterior. Ningún BC puede mover al target
      sin que BC-04 tenga su API estabilizada.

Wave 0 → Wave 1 (BC-02, BC-03, BC-09)
  └── Dependencia: BC-04 estable
  └── NO dependen entre sí — pueden correr en paralelo

Wave 1 → Wave 2 (BC-01, BC-05 parcial, BC-06 parcial)
  └── Dependencia: Wave 1 verde + BC-04 stable
  └── BC-01 y BC-05 tienen acoplamiento (S500 CAPTACION escribe GL):
      BC-01 no puede hacer cutover hasta que BC-05 partial esté en parallel-run

Wave 1 || Wave 3 (BC-01 batch, BC-06 batch)
  └── Pueden correr en paralelo SI Batch Architecture sign-off está listo
  └── Batch Architecture sign-off = prerequisito bloqueante

Wave 2 → Wave 4 (WFL REPLATFORM)
  └── Los WFL jobs orquestan COBOL. El REPLATFORM debe esperar a que
      los COBOL que orquesta estén en Wave 2+.

Retain Pool → nunca bloquea otras waves
  └── DASDL se desacopla en Wave 0 a través del GL-Posting-Service API
```

---

## 8. Métricas de Capa 5

| Métrica | Valor proyectado | Fuente |
|---------|-----------------|--------|
| Bounded Contexts definidos | 9 (4 S500 + 5 S151) | Este análisis |
| Programas RETIRE candidatos | ~8–12 (pendiente verificación WFL) | Call graph análisis |
| Programas REFACTOR Wave 1 | ~20 (estimado) | Tipo COBOL + sin flags + LOC < 3K |
| Programas REFACTOR Wave 2 | ~30 (estimado) | Tipo COBOL + flags + post-ACL |
| Programas REPLATFORM (WFL) | 7 (4 S500 + 3 S151) | Inventario completo |
| Programas RETAIN (ALGOL + DASDL) | ~57 (31 ALGOL + 13 DASDL + 11 INC + 2 críticos) | Inventario + framework |
| Programas ENCAPSULATE (S151REGISTRA) | 4 (L002R2-R5) | Call graph cross-system |
| Waves totales | 5 (0-4) + Retain pool | Este análisis |
| Parallel-run mínimo requerido | 3 meses (Wave 2 en adelante) · 2 sprints (Wave 1) | DoD-SPE-MM-02 |
| Equivalence target Wave 1 | ≥ 99.95% | DoD Application Modernization |
| Equivalence target Wave 2+ | ≥ 99.99% | DoD-SPE-MM-01 · CNBV |

---

## 9. Próximos Pasos para Completar Capa 5

1. **Ejecutar `build-boundaries.py`** — produce `boundaries-s500s151.json` con la decisión 7R preliminar por los 218 programas usando los datos disponibles.

2. **Verificar dead code** — RE Specialist lee los 7 WFL jobs y lista todos los programas llamados desde WFL que podrían no aparecer en el call graph estático COBOL. Actualizar RETIRE candidates.

3. **Confirmar flags regulatorios** — Regulatory SME (o lectura directa del source) confirma qué programas tienen lógica directamente ligada a reportes CNBV/Banxico. Elevar calidad de los flags de "inferido" a "confirmado".

4. **Emitir ADR-SPE-MM-001 por programa** — comenzando por los 4 programas S151REGISTRA (Wave 0) y los candidatos de Wave 1. El 7R Assessment Specialist es el dueño de estos ADRs.

5. **Invocar Unisys Banking SME** (advisory) — para validar las decisiones sobre los 31 programas ALGOL antes de confirmar el Retain pool.

6. **Construir la vista portal de Capa 5** — HTML con el wave map interactivo + tabla de 7R decisions filtrable por BC, wave, tipo, regulatorio.

---

## 10. Relación con la Metodología GemCog

```
Capa 1 (Lenguaje)   → insumo: ubiquitous language del bounded context target
Capa 2 (Almas)      → insumo: bus factor informa el riesgo de knowledge loss por wave
Capa 3 (Biografía)  → insumo: eras de modificación informan la estratificación de deuda técnica
Capa 4 (Intención)  → insumo: call graph determina dependency constraints entre waves
                                ↓
Capa 5 (Fronteras)  → OUTPUT: 9 BCs + 7R por programa + Wave Map + SME Roster + ACL design
                                ↓
Capa 6 (Siembra)    → el gemelo como spec del target: los BCs de Capa 5 alimentan el ADR de transpilación
Capa 7 (Equivalencia) → el Wave Map de Capa 5 define el scope del golden-master
Capa 8 (Continuidad) → el Retain pool de Capa 5 define qué sigue en MCP durante parallel-run
```

---

*Generado: 2026-07-14 · GemCog v2.2 · S500 (114 obj · 296,677 LOC) + S151 (104 obj · 444,992 LOC) · 218 programas · 9 Bounded Contexts*
*Owner: Specialist - 7R Assessment · Advisory: Mainframe Migration SME + Unisys Banking SME*
