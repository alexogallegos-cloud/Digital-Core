# Modelo Operativo de Migración — BCOPCore
> **Estrategia**: Wave-based Strangler Fig con Parallel Run por Wave
> **Versión**: 0.1.0 · 2026-08-02
> **Proyecto**: SPE-AM-001 · BanCoppel Application Modernization
> **Estado**: DRAFT — DESIGN

---

## 1. Estrategia General

### 1.1 Patrón Seleccionado: Wave-based Strangler Fig

Cada wave agrupa bounded contexts (ETB L2) por afinidad funcional y orden de dependencias. Para cada wave:

```
CICLO POR WAVE
══════════════
BUILD          PARALLEL RUN         CUTOVER         DECOMMISSION
───────────    ──────────────────    ─────────────   ─────────────────
Microservicios Legacy + target       Feature flag    Legacy desactivado
+ ACL          en paralelo           al 100%         + datos archivados
(~3-6 meses)   (≥ 3 meses CNBV)     (1 evento)      (6-12 meses post)
```

**Por qué no Big Bang:** 16 bases de datos Informix, 10,144 SPs, 60 TB, regulación CNBV — un cutover único concentra riesgo N5 inaceptable dado el estado actual del risk register (2 DEFECTO-PROD activos en P655).

**Por qué no Strangler Fig Alma por Alma:** 16 Almas independientes implicarían 16 ciclos de cutover, 16 ACLs simultáneas, y complejidad de coordinación no manejable para un equipo de delivery bancario.

**Wave-based equilibra:** 6 waves = 6 eventos de cutover, cada uno acotado funcionalmente, con parallel run que garantiza equivalencia funcional antes de cortar.

---

### 1.2 Anti-Corruption Layer (ACL)

Durante el período de coexistencia, los consumidores del sistema legacy (canales, sistemas externos) siguen llamando al mismo endpoint. El ACL intercepta y enruta:

```
CONSUMIDOR          ACL                  DESTINO
──────────    ──────────────────────    ──────────────────
Canal BTS  →  Router por feature flag → Legacy Informix SP  (pre-cutover)
Canal BTS  →  Router por feature flag → Microservicio Java  (post-cutover)

Tipos de ACL según wave:
  W0-W1: ACL liviano (enrutamiento de sesión / canal)
  W2-W3: ACL financiero (traducción de tipos MONEY → BigDecimal, códigos de retorno)
  W4:    ACL regulatorio SPEI (transformación ISO 20022 / protocolo Banxico)
  W5:    ACL contable (asientos GL legacy → eventos de dominio)
```

`[CRÍTICO]` El ACL financiero (W2+) debe preservar la semántica `MONEY → BigDecimal(RoundingMode.HALF_EVEN)`. Cualquier conversión de tipo en el ACL que use HALF_UP introduce desbalance acumulativo.

---

## 2. Waves — Definición y Secuencia

### Wave 0 — Fundación e Identidad del Cliente

**Objetivo**: establecer los cimientos del target — infraestructura AWS, identidad del cliente, utilidades transversales.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-4.7 | Business Process Management | — (cross-cutting) | Shared library de utilidades |
| BC-7.1 | Customer Management | D02, D06, D14 | bdinteg, bdisolic, bdibei |
| BC-5.3 | Policy Management | D02 | bdinteg |

**Por qué primero:**
- BC-7.1 (Cliente) es la dependencia más transitiva del sistema: 8 bounded contexts lo necesitan
- BC-4.7 son utilidades de proceso (split, regex, eventos) que todos los demás SPs invocan
- Sin identidad de cliente estabilizada, el parallel run de W2+ no puede validar equivalencia

**Parallel run:** 2 meses — volumen bajo, bajo riesgo financiero directo.

**Go/No-Go W0:**
- [ ] Perfil de cliente creado en target = perfil en legacy (mismos campos, mismo ID canónico)
- [ ] Autenticación target funciona para 100% de los tipos de sesión del legacy
- [ ] BC-4.7 utilities retornan outputs idénticos a SPs cross-cutting de Informix

---

### Wave 1 — Canales

**Objetivo**: migrar la capa de presentación e interacción sin tocar datos financieros.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-1.1 | Digital Interaction Channel | D01 | bdicnweb |
| BC-1.2 | Physical Interaction Channel | D10 | bdisuc |
| BC-1.4 | Channel Access Management | D01 | bdicnweb |
| BC-7.3 | Interaction Management | D01, D09 | bdicnweb, bdimnsj |
| BC-2.7 | Message Management | D09 | bdimnsj |

**Por qué segundo:**
- Los canales no tienen ownership de datos financieros — son fachadas de interacción
- Migrar canales primero permite que los equipos aprendan el modelo de deployment en AWS antes de tocar el core
- Si algo falla en W1, el rollback no compromete datos de clientes ni saldos

**Parallel run:** 2 meses — sin transacciones financieras directas.

**Go/No-Go W1:**
- [ ] Canal digital sirve el 100% de los journeys de consulta (saldo, movimientos, perfil)
- [ ] Canal físico (sucursal) enruta correctamente a SPs legacy sin degradación de latencia
- [ ] Mensajería transaccional entregada con mismo SLA que legacy (SMS, push)
- [ ] ZERO errores de sesión o autenticación en producción shadow

---

### Wave 2 — Captación (Cuentas y Saldos)

**Objetivo**: migrar el núcleo de captación — el corazón del modelo de negocio BanCoppel.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-3.2 | Accounts and Deposits Management | D04, D05, D06 | bdicheq, bdisac, bdisolic |
| BC-3.17 | Cash Management | D05, D10, D12 | bdisac, bdisuc, bdicont |
| BC-3.1 | Product Management | D03, D06 | bdicred, bdisolic |
| BC-3.15 | Interest and Fees | D04, D16 | bdicheq, intercard |
| BC-3.16 | Limits Management | D04, D16 | bdicheq, intercard |

**Riesgo principal:** D04 (bdicheq) tiene capabilities de BC-3.2, BC-3.4 y BC-3.5 mezcladas. Requiere separación explícita de ownership antes de BUILD.

`[CRÍTICO]` El parallel run de W2 debe verificar centavo a centavo. Criterio: diferencia de saldo entre legacy y target = $0.00 para el 100% de las cuentas activas al cierre de cada día.

**Parallel run:** 3 meses mínimo (CNBV requiere evidencia de equivalencia de saldos en período contable completo).

**Dependencias previas resueltas:** W0 (BC-7.1 Customer estabilizado), W1 (canales enrutando).

**Go/No-Go W2:**
- [ ] Balance diario legacy = balance target a $0.00 por 60 días consecutivos
- [ ] Reconciliación nocturna automatizada sin partidas por aclarar no cerradas
- [ ] Todos los journeys de consulta de saldo y apertura de cuenta equivalentes
- [ ] Reverso de operación mismo día funciona con restricción de fecha idéntica al legacy
- [ ] CNBV: saldo promedio de captación reportado coincide entre legacy y target para Serie R

---

### Wave 3 — Crédito y Tarjetas

**Objetivo**: migrar el portafolio de crédito al consumo y la gestión de tarjeta BanCoppel.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-3.3 | Lending Management | D03, D06, D11 | bdicred, bdisolic, bdicobranza |
| BC-3.5 | Cards Management | D04, D07, D16 | bdicheq, bdiaclaracion, intercard |
| BC-5.9 | Risk Management | D03, D11 | bdicred, bdicobranza |

**Riesgo principal:** D16 (intercard) está en scope PCI-DSS. Cualquier migración de este dominio requiere re-certificación PCI-DSS del stack cloud antes del cutover.

`[CRÍTICO]` PAN de tarjeta debe estar tokenizado en el target desde el primer día de parallel run. No se migran PANs en claro a AWS.

**Parallel run:** 3 meses mínimo + 1 ciclo de corte mensual completo para verificar cálculo de intereses, comisiones y estado de cuenta.

**Dependencias previas resueltas:** W2 (BC-3.2 Accounts — el crédito debita contra cuentas).

**Go/No-Go W3:**
- [ ] Saldo de cartera vigente target = saldo legacy a $0.00
- [ ] Estado de cuenta mensual target = estado de cuenta legacy (mismo cálculo de intereses, mismo corte)
- [ ] PCI-DSS: certificación del stack AWS para datos de tarjeta completada
- [ ] Metodología de reservas CNBV (ECL) produce mismo resultado en target
- [ ] Cobranza: scoring y gestión de mora equivalente para el mismo portfolio de clientes

---

### Wave 4 — Pagos

**Objetivo**: migrar el módulo de pagos — SPEI, CoDi, TEF, corresponsalía BTS.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-3.4 | Payments | D04, D08, D13, D16 | bdicheq, bdispei, bditef, intercard |
| BC-7.4 | Ecosystem Management | D08 | bdispei |

**Este es el wave más regulado.** Requiere certificación técnica de Banxico antes del cutover.

`[CRÍTICO]` Banxico requiere certificación del ambiente antes de operar SPEI en producción. La ventana de certificación es independiente del calendario del proyecto — debe planificarse con 90+ días de anticipación.

**Parallel run:** 3 meses mínimo + certificación Banxico (variable — puede extender el ciclo).

**Dependencias previas resueltas:** W2 (cuentas origen del débito), W3 (tarjetas para pagos con tarjeta).

**Go/No-Go W4:**
- [ ] SLA SPEI: < 20 segundos end-to-end en el 99.9% de las transacciones
- [ ] Reconciliación interbancaria SPEI: cero diferencias con SIAC de Banxico
- [ ] CoDi/DiMo: QR generados y procesados equivalentes al legacy
- [ ] Corresponsalía BTS: operaciones de caja en tiendas Coppel equivalentes
- [ ] Certificación técnica Banxico obtenida y documentada
- [ ] CNBV: notificación formal de cambio mayor en sistemas de pago (90 días previos)

---

### Wave 5 — Regulatorio y Post-trade

**Objetivo**: migrar el GL contable, AML, cumplimiento y aclaraciones — el eslabón final.

| BC | Nombre | AS-IS Origen | Dominios |
|----|--------|--------------|---------|
| BC-5.4 | Finance Management (GL) | D12 | bdicont |
| BC-5.8 | Fraud and AML Management | D15 | bdilide |
| BC-5.10 | Compliance Management | D15 | bdilide |
| BC-3.18 | Dispute Management | D07 | bdiaclaracion |
| BC-4.5 | Legal Support Management | D07 | bdiaclaracion |

**Por qué al final:**
- El GL (BC-5.4) consolida asientos de TODAS las waves anteriores. Migrarlo al final garantiza que los eventos de dominio que alimentan los asientos ya están estabilizados.
- AML y Compliance dependen de tener el stack financiero completo para monitorear.
- No se puede cerrar la migración con el GL en legacy — el decommission del Informix requiere que el GL esté en el target.

`[CRÍTICO]` D15 (bdilide) tiene datos compartidos entre BC-5.8 (AML) y BC-5.10 (Compliance). La separación de ownership debe hacerse en BUILD, no en parallel run.

**Parallel run:** 3 meses mínimo + 1 cierre mensual completo con Serie R verificada.

**Go/No-Go W5:**
- [ ] Balance de comprobación GL target = balance GL legacy a $0.00 por 60 días
- [ ] Serie R mensual generada desde target coincide con legacy para el mismo período
- [ ] Partidas por aclarar: cero al cierre de cada día hábil
- [ ] AML: alertas generadas por target son equivalentes o superiores a las del legacy
- [ ] CNBV: auditoría de contabilidad del período de parallel run sin observaciones
- [ ] INAI: evidencia de enmascaramiento/anonimización de datos personales cumplida

---

## 3. Timeline Referencial

Asunciones: BUILD de waves se puede solapar con PARALLEL RUN de la wave anterior. Sin fecha de inicio real — expresado en meses relativos (M0 = inicio de BUILD W0).

```
WAVE   M0  M1  M2  M3  M4  M5  M6  M7  M8  M9  M10 M11 M12 M13 M14 M15 M16 ...
───────────────────────────────────────────────────────────────────────────────
W0     ████BUILD████  ████PARALLEL████ CUTOVER
W1          ████████BUILD████████  ████PARALLEL████ CUTOVER
W2                    ████████████BUILD████████████  ████████PARALLEL████████ CUTOVER
W3                                    ████████BUILD████████  ████████PARALLEL████████ CUTOVER
W4                                                  ████████BUILD████████  ███PARALLEL+CERT███ CUTOVER
W5                                                                  ████BUILD████  ███PARALLEL███ CUTOVER
───────────────────────────────────────────────────────────────────────────────
Decommission Informix completo: M0 + ~36-42 meses
```

**Estimados por wave** (BUILD + PARALLEL RUN):
| Wave | BUILD | PARALLEL RUN | Total |
|------|-------|-------------|-------|
| W0 | 3 meses | 2 meses | 5 |
| W1 | 4 meses | 2 meses | 6 |
| W2 | 6 meses | 3 meses | 9 |
| W3 | 6 meses | 3 meses | 9 |
| W4 | 5 meses | 4 meses + cert Banxico | 9-12 |
| W5 | 4 meses | 3 meses | 7 |

> Estos estimados no incorporan el tamaño del equipo ni la complejidad real de los SPs de cada wave. Requieren calibración con CCM v1.8 y análisis del BCOPBrain por wave.

---

## 4. Dependencias entre Waves

```
W0 ──→ W1 (canales necesitan autenticación de W0)
W0 ──→ W2 (cuentas necesitan Customer de W0)
W1 ──→ (W2 puede iniciar BUILD en paralelo, no bloquea)
W2 ──→ W3 (crédito debita contra cuentas de W2)
W2 ──→ W4 (pagos verifican saldo en cuentas de W2)
W3 ──→ W4 (pagos con tarjeta necesitan Cards de W3)
W2 + W3 + W4 ──→ W5 (GL consolida asientos de todas las waves)
```

**Secuencia mínima bloqueante:** W0 → W2 → W3 → W4 → W5

W1 puede ejecutarse en paralelo a W2 BUILD sin bloquear.

---

## 5. Restricciones Regulatorias CNBV

| Wave | Obligación CNBV / Banxico | Plazo |
|------|--------------------------|-------|
| Inicio del programa | Notificación a CNBV: plan de migración como cambio mayor TIC | 90 días antes de W0 BUILD |
| W2 cutover | Plan de continuidad de negocio (PCN) aprobado para captación | Antes del cutover |
| W4 | Notificación formal CNBV: cambio en sistemas de pago | 90 días antes del cutover W4 |
| W4 | Certificación técnica Banxico para SPEI | Variable — iniciar proceso en W3 BUILD |
| W5 | Auditoría contable de período de parallel run | Antes del cutover W5 |
| Post-W5 | Notificación CNBV: decommission del sistema legacy | 30 días previos |

`[CRÍTICO]` La notificación inicial a CNBV debe enviarse **antes** de iniciar cualquier actividad de migración en producción. No es opcional — la Circular 14/2022 lo requiere para cambios mayores en infraestructura TIC.

---

## 6. Resolución de Bloqueantes Previos a W0

El risk register actual tiene 2 DEFECTO-PROD activos (P655-R001 y P655-R002) que deben resolverse antes de iniciar BUILD de W0:

| Riesgo | Acción requerida | Owner | Deadline |
|--------|-----------------|-------|---------|
| P655-R001 | Documentar el defecto: SP afectado, comportamiento observado vs. esperado, impacto regulatorio | DT-Riesgos + DBA IBM Informix | Pre-W0 BUILD |
| P655-R002 | Ídem P655-R001 | DT-Riesgos + DBA IBM Informix | Pre-W0 BUILD |
| sp_consultasaldocortemin_mx2 CWE-390 | Corregir ON EXCEPTION silencioso en la implementación target (no en legacy) | Core Banking Transformation + Software Engineering | W2 BUILD |

---

## 7. Estructura del Equipo por Wave

| Rol | W0 | W1 | W2 | W3 | W4 | W5 |
|-----|----|----|----|----|----|----|
| Architect Lead | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ |
| Java Developers (microservicios) | 2 | 4 | 6 | 6 | 4 | 3 |
| DBA IBM Informix (legacy) | 1 | — | 2 | 2 | 1 | 1 |
| DBA AWS Aurora (target) | 1 | — | 2 | 2 | 1 | 1 |
| QA / Equivalence Testing | 1 | 1 | 2 | 2 | 2 | 2 |
| Cybersecurity | 1 | — | 1 | 1 (PCI) | 1 | 1 |
| SRE / DevOps | 1 | 1 | 1 | 1 | 2 | 1 |
| Regulatory / CNBV liaison | — | — | 1 | — | 1 | 1 |

---

## 8. Decisiones Arquitectónicas Pendientes (ADRs Required)

| ADR | Decisión | Impacto |
|-----|----------|---------|
| ADR-BCOPCore-001 | Estrategia de coexistencia ACL: ¿feature flag por SP o por bounded context? | Diseño del ACL W2+ |
| ADR-BCOPCore-002 | Sincronización de datos durante parallel run: CDC (Debezium) vs. dual-write en ACL | Arquitectura de datos W2+ |
| ADR-BCOPCore-003 | Tokenización de PAN: solución AWS Payment Cryptography vs. tercero (Thales/Futurex) | PCI-DSS W3 |
| ADR-BCOPCore-004 | GL generación de asientos: eventos de dominio síncronos vs. outbox pattern | W5 y confiabilidad de asientos |
| ADR-BCOPCore-005 | Split de D04 (bdicheq): estrategia de separación BC-3.2 / BC-3.4 / BC-3.5 en tabla level | W2 BUILD |

---

*v0.1.0 · 2026-08-02 · dt-modelo-dominio · BCOPCore SPE-AM-001*