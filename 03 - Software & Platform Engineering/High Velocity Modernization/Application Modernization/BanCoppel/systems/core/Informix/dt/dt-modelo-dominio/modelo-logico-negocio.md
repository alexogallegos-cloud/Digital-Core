# Modelo Lógico de Negocio — Informix
> **Framework**: Banking ETB v5.0 — L2 Groups como Bounded Contexts
> **Versión**: 0.1.0 · 2026-08-02
> **Proyecto**: SPE-AM-001 · BanCoppel Application Modernization
> **Estado**: DRAFT — DESIGN Inicial

---

## 1. Contexto y Decisión Arquitectónica

El modelo lógico de negocio de Informix está definido por los **23 ETB L2 Groups** que tienen al menos una capacidad COVERED o CROSS_CUTTING en el sistema Informix actual.

| Métrica | Valor |
|---------|-------|
| L1 domains cubiertos | 6 de 7 (Responsible Business sin cobertura) |
| L2 groups cubiertos (bounded contexts) | 23 |
| Capacidades COVERED | 61 |
| Capacidades CROSS_CUTTING | 1 |
| Cobertura vs. ETB completo | 23.8% (62/261) |
| Dominios Informix AS-IS | 16 (D01–D16) |

Cada ETB L2 Group es un **Bounded Context** en la arquitectura target. Los microservicios se diseñan dentro de los límites del bounded context al que pertenecen. Los datos son propiedad del bounded context primario.

---

## 2. Mapa de Bounded Contexts

### L1-1 — Channel Management · 3 BCs

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-1.1** | Digital Interaction Channel | D01 (bdicnweb) | 3 | Data-owning |
| **BC-1.2** | Physical Interaction Channel | D10 (bdisuc) | 2 | Data-owning |
| **BC-1.4** | Channel Access Management | D01 (bdicnweb) | 1 | Shared (con BC-7.1) |

**Responsabilidades de dominio:**
- BC-1.1 — interfaces digitales (web, mobile, IVR); sesiones de canal; enrutamiento de transacciones entrantes
- BC-1.2 — red de sucursales y cajeros; configuración de tiendas BanCoppel/Coppel como corresponsal; capacidad por caja
- BC-1.4 — gestión de acceso por canal (límites, horarios, autorizaciones de canal)

---

### L1-2 — Marketing and Sales · 1 BC

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-2.7** | Message Management | D09 (bdimnsj) | 2 | Data-owning |

**Responsabilidades de dominio:**
- BC-2.7 — mensajería transaccional y alertas al cliente; notificaciones de operación (SMS, push, email)

---

### L1-3 — Product and Service · 9 BCs

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-3.1** | Product Management | D03, D06 | 1 | Shared |
| **BC-3.2** | Accounts and Deposits Management | D04, D05, D06 | 4 | Data-owning (núcleo) |
| **BC-3.3** | Lending Management | D03, D06, D11 | 5 | Data-owning |
| **BC-3.4** | Payments | D04, D08, D13, D16 | 8 | Data-owning (crítico) |
| **BC-3.5** | Cards Management | D04, D07 | 3 | Data-owning |
| **BC-3.15** | Interest and Fees | D04, D16 | 2 | Service (cálculo) |
| **BC-3.16** | Limits Management | D04, D16 | 1 | Service (configuración) |
| **BC-3.17** | Cash Management | D05, D10, D12 | 5 | Shared |
| **BC-3.18** | Dispute Management | D07 (bdiaclaracion) | 1 | Data-owning |

**Responsabilidades de dominio:**
- BC-3.1 — catálogo de productos bancarios; parametrización de productos vigentes
- **BC-3.2** — cuentas de ahorro y cheques; saldos; apertura/cierre de cuenta; estados de cuenta — **aggregate root: Cuenta**
- **BC-3.3** — crédito al consumo; tarjeta de crédito (ciclo crediticio); préstamos; cobranza — **aggregate root: Crédito**
- **BC-3.4** — SPEI, CoDi, DiMo, TEF, pagos de servicios (convenios); corresponsalía BTS — **aggregate root: Transacción de Pago**
- **BC-3.5** — gestión del plástico (tarjeta); activación/bloqueo; reposición; disputas de tarjeta — **aggregate root: Tarjeta**
- BC-3.15 — cálculo de intereses, comisiones y cargos; aplica sobre BC-3.2 y BC-3.3
- BC-3.16 — límites de transacción por producto, canal, cliente
- BC-3.17 — posición de caja; conciliación operativa; posición de efectivo por sucursal
- BC-3.18 — aclaraciones y disputas del cliente; resolución; CONDUSEF reporting

---

### L1-4 — Business Support · 2 BCs

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-4.5** | Legal Support Management | D07 (bdiaclaracion) | 1 | Service |
| **BC-4.7** | Business Process Management | — (cross-cutting) | 0 + 1 CROSS | Infraestructura |

**Responsabilidades de dominio:**
- BC-4.5 — soporte jurídico a aclaraciones escaladas; cobranza judicial
- BC-4.7 — utilidades transversales de proceso: registro de eventos (`sp_registra_evento`), parsing de cadenas (`sp_split_cadena`), validación de expresiones regulares (`regex_match`)

> BC-4.7 no es un bounded context de negocio — es una librería de infraestructura. Sus SPs son candidatos a **shared library** en el target, no a microservicio independiente.

---

### L1-5 — Enterprise Functions · 4 BCs

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-5.3** | Policy Management | D02 (bdinteg) | 1 | Service |
| **BC-5.4** | Finance Management | D12 (bdicont) | 5 | Data-owning (regulatorio) |
| **BC-5.8** | Fraud and AML Management | D15 (bdilide) | 2 | Data-owning |
| **BC-5.9** | Risk Management | D03, D11 | 4 | Service (analytics) |
| **BC-5.10** | Compliance Management | D15 (bdilide) | 2 | Data-owning (regulatorio) |

**Responsabilidades de dominio:**
- BC-5.3 — políticas de seguridad y autenticación; reglas de acceso a datos
- **BC-5.4** — libro mayor (GL); contabilidad regulatoria CNBV; cierre contable diario; reportes Serie R — **aggregate root: Asiento Contable / Cuenta GL**
- BC-5.8 — monitoreo de lavado de dinero; alertas AML; LIDE (Lista de Inhabilitados)
- BC-5.9 — scoring crediticio; gestión de cartera en riesgo; reservas CNBV; metodología ECL
- BC-5.10 — cumplimiento regulatorio CNBV/Banxico/CONDUSEF; reportes de cumplimiento; PLD

> BC-5.8 y BC-5.10 comparten D15 (bdilide). Son bounded contexts distintos pero con origen en la misma base de datos. En el target requieren separación explícita de ownership de datos.

---

### L1-7 — Customer and Partner Management · 3 BCs

| BC | L2 | AS-IS Domains | Caps | Tipo |
|----|----|---------------|------|------|
| **BC-7.1** | Customer Management | D01, D02, D06, D14 | 5 | Data-owning (núcleo) |
| **BC-7.3** | Interaction Management | D01, D09 | 2 | Service |
| **BC-7.4** | Ecosystem Management | D08 (bdispei) | 1 | Service (integración) |

**Responsabilidades de dominio:**
- **BC-7.1** — perfil del cliente; KYC/onboarding; autenticación; identidad digital; datos maestros del cliente — **aggregate root: Cliente**
- BC-7.3 — gestión de interacciones multicanal; historial de contacto; preferencias de comunicación
- BC-7.4 — conectividad con ecosistemas externos: Banxico (SPEI/CoDi), APPRIZA/CFPA (remesas), convenios de pago

---

## 3. Mapa AS-IS → TO-BE

| Dominio | DB Informix | BC Primario (TO-BE) | BCs Secundarios |
|---------|-------------|---------------------|-----------------|
| D01 | bdicnweb | BC-1.1 Digital Interaction Channel | BC-1.4, BC-7.3 |
| D02 | bdinteg | BC-7.1 Customer Management | BC-5.3 |
| D03 | bdicred | BC-3.3 Lending Management | BC-3.1, BC-5.9 |
| D04 | bdicheq | BC-3.2 Accounts and Deposits | BC-3.4, BC-3.5, BC-3.15, BC-3.16, BC-3.17 |
| D05 | bdisac | BC-3.2 Accounts and Deposits | BC-3.17 |
| D06 | bdisolic | BC-7.1 Customer Management | BC-3.1, BC-3.2, BC-3.3 |
| D07 | bdiaclaracion | BC-3.18 Dispute Management | BC-3.5, BC-4.5 |
| D08 | bdispei | BC-3.4 Payments | BC-7.4 |
| D09 | bdimnsj | BC-2.7 Message Management | BC-7.3 |
| D10 | bdisuc | BC-1.2 Physical Interaction Channel | BC-3.17 |
| D11 | bdicobranza | BC-3.3 Lending Management | BC-5.9 |
| D12 | bdicont | BC-5.4 Finance Management | BC-3.17 |
| D13 | bditef | BC-3.4 Payments | — |
| D14 | bdibei | BC-7.1 Customer Management | — |
| D15 | bdilide | BC-5.8 Fraud and AML | BC-5.10 |
| D16 | intercard | BC-3.5 Cards Management | BC-3.4, BC-3.15, BC-3.16 |

**Dominios con split de bounded context** (una DB Informix → múltiples BCs primarios):
- D04 (bdicheq): contiene capabilities de BC-3.2 (cuentas) y BC-3.4 (pagos) y BC-3.5 (tarjetas). Requiere separación explícita de tablas por bounded context al migrar.
- D05 (bdisac): cubre BC-3.2 y BC-3.17. Mayoritariamente BC-3.2.
- D15 (bdilide): cubre BC-5.8 (AML) y BC-5.10 (Compliance). Requieren ownership separado.

---

## 4. Aggregate Roots Identificados (preliminar)

Los aggregate roots son las entidades raíz de los bounded contexts data-owning. Son los candidatos a identificadores canónicos en el sistema target.

| Bounded Context | Aggregate Root | ID canónico | Origen AS-IS |
|-----------------|---------------|-------------|-------------|
| BC-7.1 Customer Management | **Cliente** | `num_cliente` / CURP | D06 bdisolic, D02 bdinteg |
| BC-3.2 Accounts and Deposits | **Cuenta** | `num_cuenta` (16 dígitos) | D05 bdisac, D04 bdicheq |
| BC-3.3 Lending Management | **Crédito** | `num_credito` | D03 bdicred |
| BC-3.4 Payments | **Transacción de Pago** | `folio` (transaccional) | D08 bdispei, D13 bditef |
| BC-3.5 Cards Management | **Tarjeta** | PAN (tokenizado) | D16 intercard |
| BC-5.4 Finance Management | **Asiento Contable** | `folio_contable` + fecha | D12 bdicont |
| BC-3.18 Dispute Management | **Aclaración** | `num_aclaracion` | D07 bdiaclaracion |
| BC-5.8 Fraud and AML | **Alerta AML** | `id_alerta` | D15 bdilide |

> Aggregate roots pendientes de validación contra schema real de syscolumns en BCOPBrain.

---

## 5. Dependencias entre Bounded Contexts

Las dependencias indican qué BC necesita datos o servicios de otro BC para completar su operación.

```
MAPA DE DEPENDENCIAS (→ = "depende de")
════════════════════════════════════════

BC-3.4 Payments ──────────→ BC-3.2 Accounts (verificar saldo)
BC-3.4 Payments ──────────→ BC-7.1 Customer (validar identidad)
BC-3.4 Payments ──────────→ BC-7.4 Ecosystem (conectar SPEI/CoDi)
BC-3.4 Payments ──────────→ BC-3.5 Cards (autorización de tarjeta)

BC-3.3 Lending ───────────→ BC-7.1 Customer (perfil crediticio)
BC-3.3 Lending ───────────→ BC-3.2 Accounts (débito de cuotas)
BC-3.3 Lending ───────────→ BC-5.9 Risk (scoring / reservas)

BC-3.2 Accounts ──────────→ BC-7.1 Customer (titular de cuenta)
BC-3.2 Accounts ──────────→ BC-3.15 Interest (cálculo de intereses)
BC-3.2 Accounts ──────────→ BC-3.16 Limits (aplicar límites)

BC-5.4 Finance ───────────→ BC-3.2 Accounts (asientos de captación)
BC-5.4 Finance ───────────→ BC-3.3 Lending (asientos de crédito)
BC-5.4 Finance ───────────→ BC-3.4 Payments (asientos de pago)
BC-5.4 Finance ───────────→ BC-3.17 Cash (posición de caja)

BC-3.5 Cards ─────────────→ BC-7.1 Customer (titular)
BC-3.5 Cards ─────────────→ BC-3.3 Lending (línea de crédito)
BC-3.5 Cards ─────────────→ BC-3.15 Interest (comisiones)

BC-5.8 Fraud/AML ─────────→ BC-3.4 Payments (monitoreo)
BC-5.8 Fraud/AML ─────────→ BC-3.3 Lending (originación)
BC-5.8 Fraud/AML ─────────→ BC-7.1 Customer (perfil de riesgo)

BC-3.18 Disputes ─────────→ BC-3.4 Payments (transacción disputada)
BC-3.18 Disputes ─────────→ BC-3.5 Cards (disputa de tarjeta)
BC-3.18 Disputes ─────────→ BC-7.1 Customer (cliente reclamante)

BC-1.1 Digital Channel ───→ BC-7.1 Customer (autenticación)
BC-1.2 Physical Channel ──→ BC-3.4 Payments (operaciones en caja)
BC-2.7 Message Mgmt ──────→ BC-3.4 Payments (notificaciones)
BC-2.7 Message Mgmt ──────→ BC-3.2 Accounts (alertas de saldo)

BC-4.7 BPM ───────────────→ (todos — infraestructura transversal)
```

**Bounded contexts núcleo** (mayor número de dependencias entrantes):
1. **BC-7.1 Customer Management** — 8 dependencias entrantes
2. **BC-3.2 Accounts and Deposits** — 6 dependencias entrantes
3. **BC-3.4 Payments** — 5 dependencias entrantes
4. **BC-3.3 Lending Management** — 4 dependencias entrantes

Estos 4 BCs son los que mayor impacto tienen en el sistema y deben tener diseño más robusto antes del BUILD.

---

## 6. Bounded Contexts Excluidos del Scope Actual

Los 34 L2 groups restantes del ETB que no tienen capacidades COVERED en Informix están **fuera del scope del sistema actual**. Ejemplos relevantes:
- 1.3 Channel Development — no hay capabilities de desarrollo de canal
- 2.1–2.6 — Marketing, Sales, Campaign — BanCoppel no tiene CRM en este stack
- 3.6–3.14 — Trade Finance, Securities, etc. — no aplica para banca de consumo
- 4.1–4.4 — Supply Chain, Asset Mgmt — fuera de scope bancario retail
- 6.x — Responsible Business — ESG/sostenibilidad, fuera de scope
- 5.1, 5.2 — Strategic/Financial Planning — back-office fuera de Informix

Estos pueden ser candidatos a fases futuras o a soluciones complementarias.

---

## 7. Candidate Wave Groups (input para Modelo Operativo)

Agrupación preliminar de bounded contexts en waves basada en dependencias y criticidad regulatoria:

| Wave | BCs incluidos | Criterio | Criticidad regulatoria |
|------|--------------|----------|----------------------|
| **W0 — Infraestructura** | BC-4.7 BPM · BC-7.1 Customer | Sin dependencias entrantes; fundación del target | Media |
| **W1 — Canales** | BC-1.1 Digital · BC-1.2 Physical · BC-1.4 Access · BC-7.3 Interaction · BC-2.7 Messaging · BC-5.3 Policy | Canales y mensajería; bajo riesgo de datos financieros | Baja |
| **W2 — Cuentas y Saldos** | BC-3.2 Accounts · BC-3.17 Cash · BC-3.1 Product · BC-3.16 Limits · BC-3.15 Interest | Core de captación; BC raíz de dependencias | Alta (CNBV captación) |
| **W3 — Crédito y Tarjetas** | BC-3.3 Lending · BC-3.5 Cards · BC-5.9 Risk · BC-7.4 Ecosystem | Crédito al consumo; tarjeta BanCoppel | Alta (CNBV crédito) |
| **W4 — Pagos** | BC-3.4 Payments | SPEI/CoDi/TEF; corresponsalía; certificación Banxico | Crítica (Banxico) |
| **W5 — Regulatorio y Post-trade** | BC-5.4 Finance · BC-5.8 Fraud/AML · BC-5.10 Compliance · BC-3.18 Disputes · BC-4.5 Legal · BC-7.4 Ecosystem | GL regulatorio CNBV; AML; aclaraciones | Crítica (CNBV/PLD) |

> Esta propuesta de waves es preliminar. Requiere validación con: (1) análisis de dependencias de datos entre waves, (2) RTO/RPO por wave, (3) confirmación regulatoria CNBV de orden de corte, (4) disponibilidad de equipos.

---

## 8. Gaps Identificados vs. ETB Completo

Los 199 L3 capabilities NOT_COVERED representan funcionalidades que el sistema Informix actual no implementa. Para Informix, los gaps más relevantes de la banca de consumo son:

| L2 Group | Gap notable | Implicación |
|----------|-------------|-------------|
| 3.7 Insurance | Sin bancaseguros en stack actual | Producto futuro — fuera de scope |
| 3.19 Remittance Management | Remesas vía APPRIZA (externo) — gap interno | Dependencia de sistema externo sin ownership |
| 2.1–2.6 Marketing/CRM | Sin CRM en Informix | El CRM vive fuera del stack Informix |
| 5.5 Treasury | Sin gestión de tesorería interna | Probablemente en otro sistema |
| 5.6 HR Management | Fuera de scope de core bancario | Otro sistema |
| 4.3 Supplier Management | Fuera de scope | Otro sistema |

---

*v0.1.0 · 2026-08-02 · dt-modelo-dominio · Informix SPE-AM-001*