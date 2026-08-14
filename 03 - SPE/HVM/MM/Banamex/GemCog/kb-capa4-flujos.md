# GemCog Capa 4 — Flujos de Proceso / Mapa de Tareas
> Banamex · S500 (Cargos/Abonos) + S151 (Movimientos Contables GL) · Unisys ClearPath MCP
> Capa 4 sintetiza la dimensión funcional: qué hace el sistema desde el punto de vista de procesos de usuario
> Fuente primaria: [task-process-rules-index.md](task-process-rules-index.md) · 527T · 783R · 7 tipos de tarea · 23 capacidades (T.5.1 WFL + T.6.1 CPE pendientes de integración en índice)
> Actualizado: 2026-07-22 · v1.1 · +T.5.1 WFL + T.6.1 CPE a modelo de 23 caps
> **Tipo-artefacto:** `Flujo`  
> **Capa-GemCog:** `4`  
> **Propósito:** Síntesis de los flujos de proceso de usuario (Capa 4) y dependencias inter-capacidad — responde "qué flujos existen y cómo se encadenan" sin leer las 527 tareas individuales.  
> **Relacionado-con:** task-process-rules-index · kb-capa3-capacidades · kb-capa5-fronteras

---

## Rol de Capa 4 en el Gemelo Cognitivo

```
Capa 1 (Vocabulario)  →  qué significan los términos del sistema
Capa 2 (Reglas)       →  qué restricciones y decisiones rigen el comportamiento
Capa 3 (Capacidades)  →  qué agrupaciones funcionales existen (vista BIAN)
Capa 4 (Flujos)       ←  qué hace el sistema vista como procesos de usuario   [este artefacto]
Capa 5 (Fronteras)    →  dónde están las fronteras entre bounded contexts
Capa 6 (Siembra)      →  cómo se proyecta el dominio al sistema target
```

Capa 4 responde a: *"¿Qué transacciones y flujos ejecuta el sistema? ¿Qué tarea activa qué reglas?"* Es la vista ortogonal a las capacidades: una misma capacidad puede tener 7 tareas (MQ) o 78 (INT). Una tarea puede cruzar capacidades.

---

## Cobertura por Dominio BIAN

| Dominio BIAN | Capacidades | Tareas | Reglas vinculadas | Sistemas |
|---|---|---|---|---|
| **2 — Channels** | TAR · TEL | 38 | 52 | S500 + S151 |
| **4 — Common Customer View** | HLD | 22 | 50 | S151 |
| **5 — Product Processing** | DEP | 15 | 16 | S500 |
| **6 — Common Services** | CMP · PAY · INT · ORC · REC · STA · MQ · CFR | 218 | 432 | S500 + S151 |
| **7 — Enterprise Support** | GL · ADJ | 100 | 107 | S151 |
| **8 — Technology Tools** | SCH | 22 | 25 | S500 + S151 |
| **9 — Insights & Information** | ODS | 62 | 70 | S500 + S151 |
| **T — Transversal** | SEC · RPT | 50 | 93 | S500 + S151 |
| **Total** | **23 caps** | **527+** | **783+** | T.5.1 WFL + T.6.1 CPE pendientes |

> FSV (Financial Servicing · 2R) · ACC (Access Control · 8R) · SPI (Payment Schemes · 5R): capacidades sin tareas propias, mergeadas en cap-int.md · cap-sec.md · cap-pay.md respectivamente.

---

## Distribución de tipos de tarea

| Tipo | Descripción funcional | Capacidades con mayor densidad |
|---|---|---|
| `control` | Routing · dispatching · toggles · estado del proceso | PAY · ORC · HLD · SCH |
| `validación` | Gates · filtros · clasificación · comparación | REC · CMP · TEL · DEP |
| `contable` | Generación de asientos GL · acumulación de totales · rounding | INT · GL · ADJ · HLD |
| `escritura` | Persistencia en base de datos · generación de archivos | DEP · HLD · TAR · STA |
| `consulta` | Lookup · lectura de catálogos · resolve de configuración | INT · HLD · ODS · TEL |
| `reporte` | Generación de reportes · archivos regulatorios · CNBV | CMP · RPT · CFR · STA |
| `seguridad` | Autorización · FACULTAD · enmascaramiento PII · Q015 | TEL · SEC |

---

## Capacidades por densidad de tareas

Ordenadas de mayor a menor complejidad de flujo de proceso:

| Rango | Slug | Tareas | Reglas vinculadas | Ratio T/R |
|---|---|---|---|---|
| 1 | INT (Interest & Fees + Integraciones) | 78 | 159 | 2.0 |
| 2 | GL (Finance GL) | 62 | 70 | 1.1 |
| 3 | ODS (Operational Data Stores) | 62 | 70 | 1.1 |
| 4 | ADJ (GL Adjustments BC-09) | 38 | 37 | 1.0 |
| 5 | RPT (Batch Control & Regulatory) | 40 | 82 | 2.1 |
| 6 | CFR (Regulatory Reporting CNBV) | 30 | 42 | 1.4 |
| 7 | HLD (Holdings · Saldos) | 32 | 50 | 1.6 |
| 8 | ORC (Operational Reconciliation) | 28 | 61 | 2.2 |
| 9 | REC (Financial Reconciliation) | 26 | 30 | 1.2 |
| 10 | SCH (Scheduling) | 22 | 25 | 1.1 |
| 11 | TAR (ATM/PoS) | 19 | 19 | 1.0 |
| 12 | TEL (Teller Gateway) | 19 | 33 | 1.7 |
| 13 | STA (Statements) | 17 | 30 | 1.8 |
| 14 | PAY (Payments) | 13 | 22 | 1.7 |
| 15 | DEP (Deposits) | 15 | 16 | 1.1 |
| 16 | SEC (Security) | 10 | 11 | 1.1 |
| 17 | CMP (Compliance FraudLink) | 9 | 9 | 1.0 |
| 18 | MQ (Async / MQ) | 7 | 7 | 1.0 |

> Ratio T/R > 1.5 indica tareas con múltiples reglas vinculadas — señal de complejidad lógica alta. ORC (2.2) y RPT (2.1) tienen los flujos más ramificados.

---

## Flujos críticos identificados

### F-01 · Posting GL S500→S151 (flujo principal de negocio)
`PAY` → `ORC` → `GL`

1. P020/LINCOMS clasifica CVETRAN y asigna TIPO-PROC S151 (33-37 según copia)
2. 15 programas S500 generan mensajes S151REGISTRA con función REGMOV=1
3. L002R3/R4/R5 (ACL) reciben el mensaje → CARGAMOV1 → P109 (GL Posting Engine)
4. P109 aplica asientos en BD10 (MOVTOS) + BD11 (POSCONTA) + BD12 (MOVCTO)

**Reglas clave:** RN-S500-108..114 (TIPO-PROC), RN-S500-153..172 (S151REGISTRA), RN-S151-633..689 (ACL), RN-S151-021..060 (P109 GL Engine)

### F-02 · Cierre de día batch (orquestación WFL)
`SCH` → `ORC` → `INT` → `GL` → `RPT`

1. WFL LINEA detecta día hábil (DIA30/DIA15/DIA1MES)
2. P130 procesa rendimientos e ISR → asientos GL a S151
3. P021 (ALGOL) gestiona shutdown S500 vía DCKEYIN HI signals
4. P677 actúa como gate de cierre (modo 1=permite · modo 2=bloquea)
5. P199 valida FIN_S408 AND FIN_S500 AND FUNCION_82 AND FUNCION_83

**Reglas clave:** RN-S500-104..107 (WFL flags), RN-S151-181..185 (P021 shutdown), RN-S151-421..490 (RPT gate)

### F-03 · Reconciliación contable diaria
`REC` → `ADJ` → `GL`

1. P112 filtra movimientos FUNCION=1 AND STATUS=1
2. Ordena por clave 5-dimensional (LIBRO+PRODUCTO+MONEDA+CVETRAN+ESQCON)
3. Resuelve naturaleza contable via tabla S028 (1=CARGO · 2=ABONO · 3=NEUTRO)
4. Gate INDS151=2: verifica guía contable; si inexistente → error auditable CNBV
5. P312/P330/P360 (BC-09) sincronizan ajustes GL entre sistemas

**Reglas clave:** RN-S151-001..020 (P112), RN-S151-710..749 (BC-09)

### F-04 · Consulta de saldos (Holdings)
`TEL` → `HLD` → `ODS`

1. P010 (LINEA) recibe request online → valida FACULTAD → routing MDA
2. P050 dispatcher COMS 93 ramas → consulta BD02ADSALDO
3. P052 procesa distribución SECORE con filtros dormancia + centralización
4. THECALENDAR valida hábil (FUN=18 — convención invertida: 0=hábil)

**Reglas clave:** RN-S151-241..272 (P010), RN-S151-281..330 (P050/P052)

### F-05 · Reporte regulatorio CNBV Serie B
`CFR` → `RPT` → (entrega externa CNBV)

1. P130 GL agrupador → P131 traductor CFR Serie B
2. P131 mapea códigos Banamex a estructura CNBV → genera archivo de entrega
3. P677 y P610 controlan el paso batch; P612 el WFL de extracción
4. Riesgos: P021 puede interrumpir el ciclo si shutdown S500 llega antes del cierre de P131

**Reglas clave:** RN-S151-061..080 (P130-P131 agrupador), RN-S151-091..112 (P131 traductor)

### F-06 · Art. 61 LIC — Dormidos → Cuenta Global → Beneficencia Pública
`DEP` → `INT` → (entrega regulatoria CNBV/TESOFE) · BIAN: `[DATO-REQUERIDO]`

> ⚠ **Hallazgo SME 2026-07-21 (Mario):** Journey ausente del modelo de capacidades al momento de la extracción. Ningún cap-*.md documentaba este flujo. Riesgo de misclasificación en wave planning — ver `MR-DEP-07` en migration-risk-register.md.

1. **P130** evalúa condición Art. 61 CUB por contrato (T-INT-022 · RN-S500-098): primer viernes aniversario con `STA-BENEF IN {3, 8}` → ejecuta traspaso automático (50113600-TRASP-BENEF)
2. **P186** `[DATO-REQUERIDO: documentar reglas en GemCog]` — gestiona el traspaso a cuenta global y entrega final a Beneficencia Pública/TESOFE
3. Flujo regulado por Art. 61 Ley de Instituciones de Crédito (LIC) — incumplimiento genera sanción CNBV

**Programas de CONTEXTO — no ejecutores del journey:**

| Programa | Rol | Indicador en código | Etiqueta |
|---|---|---|---|
| P155 | Filtro exclusión: excluye contratos Art. 61 del borrado físico BD01/B25 | `88 W88-ES-ART61 VALUE 3, 8` / `88 W88-NO-ART61 VALUE 0, 1, 6, 7` | `[FILTRO-CONTEXTO]` — NO ejecuta traspaso |
| P160 | Propagación de dato: copia FECHART61 al archivo motor para P189 | `WKS-E01-R1-FECHART61` en archivo de salida | `[FILTRO-CONTEXTO]` — NO ejecuta traspaso |

> **Validación SME (BR-051):** P155/P160 "nada que ver con Art. 61" como ejecutores — desambiguación confirmada por Mario (SME S500).

> ⚠ **HITL antes de Wave Planning:** SME BIAN + Modelo Operativo deben confirmar el service domain BIAN y las reglas de P186 antes de asignar P130/P186 a cualquier wave.

---

## Dependencias inter-capacidad detectadas desde tareas

| Tarea origen | Capacidad | Tarea destino | Capacidad | Mecanismo |
|---|---|---|---|---|
| T-PAY-005 REGISTRAS500 | PAY | T-ORC-001..010 | ORC | ENLACE_8D · L002R5 |
| T-INT-014/015/016 asientos GL | INT | T-GL-* posting | GL | S151REGISTRA CARGAMOV1 |
| T-SCH-001 día hábil | SCH | T-ORC (shutdown) | ORC | WFL flag DIA30/DIA15 |
| T-TEL-005 FACULTAD | TEL | T-HLD-001 inicialización | HLD | Tabla de 5,000 sucursales×sistemas |
| T-RPT-* gate batch | RPT | T-CFR-* reporte CNBV | CFR | P677 modo 1/2 |
| T-REC-012 gate INDS151=2 | REC | T-ADJ-* ajuste | ADJ | BC-09 P312/P330/P360 |

---

## Relación con otras capas

| Capa | Artefacto | Qué aporta respecto a Capa 4 |
|---|---|---|
| Capa 2 (Reglas) | rules-catalog/ (33 archivos · 1,513 RN-IDs) | Detalle de cada regla que una tarea invoca |
| Capa 3 (Capacidades) | cap-*.md (22 archivos) | Contexto BIAN y riesgos de migración de cada agrupación |
| Capa 4 (este artefacto) | task-process-rules-index.md + este KB | Vista de proceso de usuario — qué tareas existen y cómo se encadenan |
| Capa 5 (Fronteras) | kb-capa5-fronteras.md | Dónde cortar el sistema en bounded contexts (derivado en parte de las dependencias inter-tarea de Capa 4) |

---

## Gap: ~730 reglas sin tarea asignada

El catálogo total tiene 1,513 RN-IDs únicos; el task-process-rules-index vincula 783. Los ~730 restantes no tienen tarea asignada porque pertenecen a una de estas categorías:

| Categoría | Ejemplos | Razón sin tarea |
|---|---|---|
| Esquemas DASDL | RN-S151-491..525 (35 reglas) | Definiciones estructurales de BD, no procesos de usuario |
| Stubs ALGOL RETAIN | rules-s151-algol-wfl-stubs, rules-s500-algol-wfl-stubs | Estrategia de encapsulación, no proceso activo |
| Librería L030 | RN-S151-526..550 (25 reglas) | Utilidades de plataforma, no proceso de dominio |
| Reglas de programas analizados post-índice | RN-S151-750..1139 (contabilidad-a/b, movimientos) | task-process-rules-index se construyó antes de que se extrajesen estos programas |
| Controles de batch sin proceso observable | Hardcodes · configuración · timeouts | Sin correlato en proceso de usuario visible |

**Acción pendiente**: actualizar task-process-rules-index.md para cubrir los programas de las series contabilidad-a/b y movimientos (RN-S151-750..1139 · ~390 reglas). Estas son las que más probablemente tienen tareas de negocio documentables.

---

## Artefactos relacionados

| Artefacto | Relación |
|---|---|
| [task-process-rules-index.md](task-process-rules-index.md) | Fuente primaria de Capa 4 — detalle completo tarea a tarea |
| [kb-capa3-capacidades.md](kb-capa3-capacidades.md) | Contexto BIAN de cada capacidad referenciada aquí |
| [kb-capa5-fronteras.md](kb-capa5-fronteras.md) | Fronteras de bounded contexts derivadas parcialmente de dependencias Capa 4 |
| [traceability-matrix.md](traceability-matrix.md) | Trazabilidad Regla↔Capacidad que complementa la vista Tarea→Regla de Capa 4 |
| [migration-risk-register.md](migration-risk-register.md) | Los flujos críticos F-01..F-05 mapean a los riesgos de mayor prioridad en el registro |
