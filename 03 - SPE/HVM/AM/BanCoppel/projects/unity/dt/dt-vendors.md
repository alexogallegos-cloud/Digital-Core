# DT: Gestión de Vendors — Unity R4
> **Digital Twin** · Fuente: RAID v2.0 · Minutas R4 · PreGame Appwhere · Análisis SME IT Operating Model + Core Banking Transformation
> **Versión**: v2.0.0 · 2026-08-19 — Modelo SIAM formal, Escalation Matrix, Penalization Log, Dependency Map, SIAM Charter
> **Propósito**: Modelo SIAM del programa — contratos, deliverables, tickets abiertos, riesgos de concentración y palanca contractual por vendor

---

## 🔴 ALERTA CRÍTICA — CAT sin contratar

**Deadline: 2026-08-31** (15 días desde hoy)
Si no se contrata al proveedor de Contact Center antes de esa fecha, el canal CAT **no entra en go-live enero 2027**.
Impacto directo: 12 HDUs · 2 capabilities (CAP-CHANNEL-SELFSERVICE + CAP-AUTHENTICATION) · RISK-001 abierto.

---

## Mapa de Vendors del Programa

| Vendor | Rol | Componente | Status contrato | Riesgo principal |
|--------|-----|-----------|-----------------|-----------------|
| BPC Banking Technologies | Plataforma SmartVista | `smartvista` | Contratado | BYU0039 abierto + DPP no licenciado |
| Appwhere | APOLO (originación) + DTMs SmartVista | `apolo` | Contratado | Latencia 9s PROD / 30s QA pendiente |
| **Proveedor CAT** | Contact Center (IVR + agentes) | `cat` | **NO CONTRATADO** 🔴 | RISK-001 — deadline 31-ago |
| GID (Giesecke & Devrient) | Maquila de tarjetas | `smartvista` | DATO-REQUERIDO | Certificación PGP/layout pendiente |
| Forza | Maquila de tarjetas | `smartvista` | DATO-REQUERIDO | Certificación pendiente |
| TGS (Thomas Greg & Sons) | Maquila de tarjetas | `smartvista` | DATO-REQUERIDO | Certificación pendiente |
| Kreios | Implementación / change management | transversal | DATO-REQUERIDO | Fatiga organizacional 60% rotación dic-ene |
| EY | Implementación Temenos Transact (R1-R3) | Transact | Contratado (incumbente) | Competidor — no compartir análisis |

---

## Vendor 1 — BPC Banking Technologies (SmartVista)

### Rol en el programa
Proveedor de la plataforma **SmartVista** (SVBO, SVFE, SVCG/Cargen, SVIP, OCG). Responsable de la configuración y entrega de los 22 HDUs SmartVista del R4. Appwhere actúa como integrador técnico de BPC para los DTMs.

### Módulos contratados vs. no contratados

| Módulo | Status | Impacto |
|--------|--------|---------|
| SVBO (Back Office) | Contratado ✓ | Core de gestión de tarjetas |
| SVFE (Front End / consola) | Contratado ✓ | Operación de agentes |
| SVCG / Cargen (generación de tarjetas) | Contratado ✓ | Maquila automatizada |
| SVIP (Integration Platform — 92 comandos) | Contratado ✓ | APIs para todos los canales |
| OCG (generador solicitudes maquila) | Contratado ✓ | Manual en R4 — automatizar post-R4 |
| **DPP (Deferred Payment Plan)** | **NO CONTRATADO** 🔴 | CAP-DEFERRED-PURCHASE bloqueada |
| SVFM (Fraud Management) | **NO LICENCIADO** | PayTrue sustituye esta función |

### Tickets abiertos con BPC

| Ticket | Título | Status | Capability afectada |
|--------|--------|--------|---------------------|
| BYU0039 | Límite Máximo de Saldo a Favor | Opened, in investigation | CAP-OVERPAYMENT (tbd) |
| #13830642 | OCG automatización en R4 | DATO-REQUERIDO | CAP-CARD-MANUFACTURING |
| #13830651 | Connect Direct automatización en R4 | DATO-REQUERIDO | CAP-CARD-MANUFACTURING |

### Riesgos BPC

| Riesgo | Descripción | Palanca contractual |
|--------|-------------|---------------------|
| BYU0039 sin fecha de cierre | Bloquea CAP-OVERPAYMENT en SIT | Escalar a account manager BPC antes de oct |
| DPP no contratado | CAP-DEFERRED-PURCHASE (cancelación) imposible | Decisión de contratar o desarrollar alternativa |
| OCG/Connect Direct manuales | Operación de maquila no automatizada en R4 | Tickets abiertos — confirmar fecha de resolución |

### Deliverables BPC — R4

- [ ] Cierre BYU0039 con dictamen formal antes de inicio SIT (oct 2026)
- [ ] Decisión DPP: contratar módulo o alternativa — DATO-REQUERIDO: fecha límite de decisión
- [ ] Automatización OCG (ticket #13830642) — DATO-REQUERIDO: fecha comprometida
- [ ] Automatización Connect Direct (ticket #13830651) — DATO-REQUERIDO: fecha comprometida
- [ ] Certificación layouts maquila con GID, Forza, TGS (PGP+HSM) — DATO-REQUERIDO: status

### Contactos BPC
> DATO-REQUERIDO: nombre del account manager BPC, escalation path para tickets ValueEdge.

---

## Vendor 2 — Appwhere (APOLO + DTMs SmartVista)

### Rol en el programa
Appwhere desarrolla y entrega dos componentes:
1. **APOLO** — plataforma de originación/onboarding digital de la TDC (22 User Stories)
2. **DTMs/DTCs de SmartVista** — development de los componentes técnicos sobre SmartVista que BPC no entrega nativamente

Metodología: Flow Engineering (4 semanas de diseño por módulo). Herramienta de gestión: Mind Master.

### Issues activos

| Issue | Descripción | Status |
|-------|-------------|--------|
| Latencia APOLO | 9s en PROD / 30s en QA — mejoras pendientes | DATO-REQUERIDO: status de mejoras comprometidas |
| User Stories Must Have (6) | 6 User Stories críticas de App cierran en noviembre (RISK-002) | En negociación de fechas |

### Deliverables Appwhere — R4

- [ ] Cerrar 6 User Stories Must Have de App antes de octubre — DATO-REQUERIDO: compromiso formal
- [ ] Mejora de latencia APOLO a <DATO-REQUERIDO ms — DATO-REQUERIDO: SLA comprometido
- [ ] DTMs: resolver los 5 con gap crítico antes de SIT
- [ ] Integración ICCAT para CAP-CUSTOMER-PROFILE en CAT — depende de proveedor CAT

### Contactos Appwhere
> DATO-REQUERIDO: nombre del delivery lead Appwhere, escalation path.

---

## Vendor 3 — Proveedor CAT (Contact Center) 🔴

### Situación actual
**No contratado.** Este es el riesgo de mayor urgencia del programa (RISK-001).

El proveedor de Contact Center debe entregar:
- IVR con menú dinámico por nivel de mora (agingPeriod E1/E2/E3)
- Autenticación via ANI + DTMF + OTP SMS 4 dígitos
- Integración ICCAT con SmartVista vía SVIP
- Consulta de saldos y movimientos desde IVR (DTM_RetrieveCreditCardBalanceAndMovements — hoy not_covered)
- Reporte de robo/extravío y cancelación de tarjeta

### Impacto si no se contrata antes del 31 de agosto

| Impacto | Detalle |
|---------|---------|
| Capabilities bloqueadas | CAP-CHANNEL-SELFSERVICE · CAP-AUTHENTICATION |
| HDUs sin cobertura | 12 HDUs del canal CAT (CAT-R4-01 a CAT-R4-12) |
| DTMs sin asignación | DTM_RetrieveCreditCardBalanceAndMovements · DTM_RetrieveCustomerCreditCardProfile |
| Riesgo go-live | Canal CAT no disponible en enero 2027 — clientes sin soporte telefónico para TDC |

### Qué necesita definirse antes del 31-ago

- [ ] Selección de proveedor y firma de contrato
- [ ] Definición de arquitectura: ¿IVR propio o integrado al IVR actual de BanCoppel?
- [ ] Confirmar si ICCAT es el middleware o se usa SVIP directamente
- [ ] SLA de implementación para llegar a SIT en octubre

### Propietario de la decisión
> DATO-REQUERIDO: quién en BanCoppel es el owner de la decisión de contratación CAT.

---

## Vendor 4 — Maquiladores (GID · Forza · TGS)

### Rol en el programa
Los tres maquiladores producen los plásticos físicos de la TDC. Reciben los archivos de maquila desde SmartVista via Connect Direct (cifrado PGP+HSM). Layout único posicional homologado para los tres.

### Reglas operativas

| Regla | Descripción |
|-------|-------------|
| Layout único | Un solo formato posicional para los 3 maquiladores — sin variantes |
| Cifrado | PGP por proveedor + HSM por tarjeta |
| Vigencia de llaves | Validar vigencia antes de generar cada lote |
| Redondeo | Volumen redondeado a múltiplos de 250 plásticos |
| Batch diario | Cálculo de reorden a las 6:00 AM; piso default 4 semanas |

### Status por maquilador

| Maquilador | Certificación layout R4 | Certificación PGP/HSM | Fecha estimada producción |
|------------|------------------------|----------------------|--------------------------|
| GID | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| Forza | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |
| TGS | DATO-REQUERIDO | DATO-REQUERIDO | DATO-REQUERIDO |

### Deliverables maquiladores — R4

- [ ] Certificar layout Producto 4900 (TDC Digital) con GID
- [ ] Certificar layout con Forza
- [ ] Certificar layout con TGS
- [ ] Validar caracteres embosables (rechazo de caracteres no válidos documentado)
- [ ] Prueba end-to-end: SVBO → OCG → Cargen → PGP → Connect Direct → Maquilador → retorno inventario

---

## Vendor 5 — Kreios

### Rol en el programa
Implementación operativa y change management. Mencionado en documentación del programa como ejecutor de la transición organizacional. Fatiga de equipo es un riesgo activo: rotación prevista del 60% en diciembre-enero.

### Riesgos Kreios

| Riesgo | Descripción | Mitigación |
|--------|-------------|-----------|
| Rotación diciembre-enero | 60% del equipo en transición durante go-live | DATO-REQUERIDO: plan de transferencia de conocimiento |
| Roles y responsabilidades | 18% de fricción en el programa por falta de claridad | Definir en dt-gobierno |
| Fatiga organizacional | Equipo bajo presión sostenida desde inicio del programa | DATO-REQUERIDO: plan de relevos |

> DATO-REQUERIDO: deliverables formales de Kreios para R4.

---

## Modelo SIAM Formal — Unity R4

SIAM (Service Integration and Management) define los tres roles del programa y sus responsabilidades de coordinación. La regla cardinal: **un SLA sin dientes es solo una lista de deseos** — las penalizaciones deben aplicarse cuando corresponda.

### Los tres roles

```
┌─────────────────────────────────────────────────────────────────────┐
│  ROL 1 — SERVICE RECIPIENT                                          │
│  BanCoppel (dueño del programa y del resultado)                     │
│                                                                     │
│  Decisiones: Juan Manuel Fernández Islas (Executive Sponsor)        │
│              Pablo Madinaveitia (Program Director)                  │
│  Operación: Tere González (PM) · Fernanda Barbosa / Araceli Bárcenas (PMO) │
│  Financiero: Brenda Abril Pichardo ⚠ sin precedente de penalizaciones │
│  Técnico: Miguel Bucio (Arquitecto) · Stephany Ley (SmartVista owner) │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ gobierna y aprueba
                           ▼
┌─────────────────────────────────────────────────────────────────────┐
│  ROL 2 — SERVICE INTEGRATOR                                         │
│  Accenture (delivery governance, integración cross-vendor, RAID)    │
│                                                                     │
│  Responsable: Pablo Lorenzo Díaz (Lead)                             │
│  Equipo: Salomón Monroy · Joaquín Navajas · Alejandro Alonso · Omar Patrón │
│  AMS: Joaquín Pichardo · Gaby Maximiliano · Alfredo García          │
│  Expertos globales: Lukasz Pietrzyk · José Luis Navas · Pavel Vilosski │
│                                                                     │
│  Rol de integrador:                                                 │
│  · Coordina dependencias cross-vendor (AppWhere ↔ BPC ↔ CAT)       │
│  · Escala bloqueos con evidencia al Service Recipient               │
│  · Mantiene RAID unificado; conduce RAID Review semanal             │
│  · Emite recomendación de penalización cuando SLA se incumple       │
└──────────────────────────┬──────────────────────────────────────────┘
                           │ coordina y audita
              ┌────────────┼────────────┬───────────────┐
              ▼            ▼            ▼               ▼
┌──────────────┐  ┌──────────────┐  ┌───────────┐  ┌──────────────┐
│  ROL 3a      │  │  ROL 3b      │  │  ROL 3c   │  │  ROL 3d      │
│  BPC         │  │  AppWhere    │  │  CAT      │  │  Kreios      │
│  SmartVista  │  │  APOLO+DTMs  │  │  🔴 SIN   │  │  Change Mgmt │
│  22 User Stories      │  │  22+DTMs     │  │  CONTRATAR│  │              │
└──────────────┘  └──────────────┘  └───────────┘  └──────────────┘
```

### Responsabilidades por rol

| Responsabilidad | Service Recipient | Service Integrator | Service Provider |
|---|---|---|---|
| Aprobar scope y prioridades | Accountable | Consulted | Informed |
| Emitir penalizaciones contractuales | Accountable | Recommends | N/A |
| Coordinar dependencias cross-vendor | Informed | Accountable | Responsible por su parte |
| Mantener RAID actualizado | Informed | Accountable | Responsible por sus issues |
| Definir SLAs del contrato | Accountable | Consulted | Negotiates |
| Escalar a ejecutivos del vendor | Decides | Executes escalation | Responds |
| Go/No-Go decisión final | Accountable | Recommends | Informed |

---

## Vendor Register — Compromisos Formales por Vendor

| Vendor | Componente | SLA de entrega | Penalización contractual | Estado |
|---|---|---|---|---|
| BPC | SmartVista 22 User Stories | Entrega funcional antes de SIT oct-2026 | DATO-REQUERIDO | Parcial — DPP y BYU0039 abiertos |
| AppWhere | APOLO 22 User Stories + DTMs | 6 User Stories Must Have antes oct-2026; latencia <DATO-REQUERIDO ms | DATO-REQUERIDO | 🟡 En negociación |
| Proveedor CAT | CAT 12 User Stories | Firma contrato antes 2026-08-31 | N/A — sin contrato | 🔴 Sin contratar |
| Kreios | Change management | Deliverables R4 DATO-REQUERIDO | DATO-REQUERIDO | Plan de transferencia pendiente |
| GID / Forza / TGS | Maquila plásticos | Certificación layout P4900 antes go-live | DATO-REQUERIDO | Desconocido |

---

## Mapa de Dependencias Cross-Vendor

Las dependencias entre vendors son el mayor riesgo operativo del programa. Un bloqueo en un vendor puede paralizar a otro.

```
AppWhere ──[depende de APIs SVIP]──► BPC
   │
   └──[DTMs de SmartVista]──► BPC debe proveer ambiente SV estable

CAT ──[depende de SVIP APIs definidas]──► BPC
   │
   └──[depende de ICCAT definido]──► AppWhere (ICAT integrations)

SIWEB ──[bloqueado esperando APIs]──► BPC (ISV06 GetDPP no definido)

Maquiladores ──[reciben archivos via Connect Direct]──► BPC (configuración OCG/Cargen)
   │
   └──[requieren certificación PGP/HSM]──► BPC (formato posicional P4900)

Temenos Transact (EY) ──[recibe asientos de]──► BPC SmartVista
   │
   └──[PP-TRNT-PAGOS: 0% vs 100% esperado]──► BPC debe definir TRNTs Pagos
```

### Bloqueos activos cross-vendor (2026-08-19)

| Bloqueo | Vendor bloqueado | Bloqueador | Capability afectada | Urgencia |
|---|---|---|---|---|
| APIs SVIP no definidas para SIWEB | SIWEB | BPC | CAP-DEFERRED-PURCHASE (ISV06 GetDPP) | Alta |
| ICCAT no definido | CAT vendor (sin contratar) | AppWhere/BPC | CAP-CHANNEL-SELFSERVICE | Crítica |
| TRNTs Pagos sin definir (0% avance) | Temenos Transact | BPC | CAP-ACCOUNTING-INTEGRATION | Alta |
| OCG/Connect Direct manuales | Maquiladores | BPC | CAP-CARD-MANUFACTURING | Media |
| BYU0039 sin cierre | AppWhere (integraciones SV) | BPC | CAP-OVERPAYMENT | Media |
| DPP no contratado | AppWhere (DTMs) | BPC (decisión licencia) | CAP-DEFERRED-PURCHASE | Alta |

---

## Matriz de Escalación

La escalación debe ser temprana, documentada y con evidencia. Escalar tarde convierte un bloqueo en un riesgo de go-live.

| Nivel | Trigger | Escalador | Destino | Plazo de respuesta |
|---|---|---|---|---|
| **L1 — Técnico** | Issue técnico entre vendors sin solución en 3 días | ACN Tech Lead | Delivery Lead del vendor | 48 horas |
| **L2 — Delivery** | Bloqueo que impacta milestone o SLA | ACN Lead (Pablo Lorenzo) | Delivery Lead vendor + BanCoppel PM (Tere) | 24 horas |
| **L3 — Ejecutivo** | Bloqueo que impacta go-live o requiere decisión contractual | BanCoppel PM + ACN Lead | Account Manager del vendor + Pablo Madinaveitia | 24 horas |
| **L4 — Contractual** | Incumplimiento de SLA con impacto confirmado | Pablo Madinaveitia + Brenda Abril | Dirección del vendor + Juan Manuel Fernández | 48 horas |

### Escalation paths por vendor

| Vendor | Contacto L1/L2 | Contacto L3/L4 | Nota |
|---|---|---|---|
| BPC | DATO-REQUERIDO (account manager) | DATO-REQUERIDO (dirección BPC) | Tickets via ValueEdge |
| AppWhere | Alfredo Aguilar | DATO-REQUERIDO | DTMs en Mind Master |
| CAT | N/A (sin contratar) | Decisión BanCoppel — owner: DATO-REQUERIDO | Deadline 2026-08-31 |
| Kreios | DATO-REQUERIDO | DATO-REQUERIDO | Fatiga equipo, rotación dic |
| Maquiladores | DATO-REQUERIDO por proveedor | DATO-REQUERIDO | Tres maquiladores distintos |
| Temenos Transact | Angélica Tolosa (EY) | EY Leadership | ⚠ COMPETIDOR — solo contacto técnico vía BanCoppel |

---

## Penalization Log

Registro formal de incumplimientos de SLA. BanCoppel históricamente no ha aplicado penalizaciones (alerta Brenda Abril). Este log existe para hacer el incumplimiento visible y accionable.

> **Regla SIAM:** el Service Integrator (Accenture) debe recomendar la penalización con evidencia al Service Recipient (BanCoppel). La decisión de aplicarla es de BanCoppel, pero la omisión sin análisis explícito convierte el contrato en letra muerta.

| ID | Fecha detección | Vendor | Incumplimiento | SLA comprometido | Evidencia | Status | Decisión BanCoppel |
|---|---|---|---|---|---|---|---|
| PEN-001 | 2026-08-16 | BPC | PP-TRNT-PAGOS: 0% vs 100% esperado | Definición TRNTs Pagos completa antes 2026-08-13 | plan_progress::PP-TRNT-PAGOS deviation=-100% | Abierto | Pendiente |
| PEN-002 | 2026-08-16 | AppWhere | 6 User Stories Must Have App sin fecha comprometida formal | Entrega antes oct-2026 (verbal) | RISK-002 abierto | Abierto | Pendiente |

*Nuevas entradas deben registrarse dentro de 48 horas de detectado el incumplimiento.*

---

## Comités de Coordinación SIAM

| Comité | Frecuencia recomendada | Participantes | Owner | Propósito |
|---|---|---|---|---|
| Steering Committee Unity | Quincenal | Juan Manuel · Pablo M. · ACN Lead · Delivery Leads vendors | BanCoppel (Pablo M.) | Decisiones ejecutivas, go/no-go, contractuales |
| Technical Sync SmartVista | Semanal | AppWhere · BPC · ACN Tech | ACN Tech Lead | Resolución de bloqueos técnicos cross-vendor |
| RAID Review | Semanal | PMO BanCoppel · ACN · todos los vendors | ACN (Pablo Lorenzo) | Estado de riesgos, issues, escalaciones activas |
| Vendor Scorecard Review | Mensual | Brenda Abril · PMO · ACN Lead | BanCoppel PMO | Evaluación de desempeño por SLA; base para penalizaciones |
| CAT Onboarding | Cuando se contrate | BanCoppel · ACN · nuevo vendor CAT | Tere González | Kickoff, alcance, integración al modelo SIAM |

*Frecuencias a confirmar con Tere González y Pablo Madinaveitia.*

---

## SIAM Governance Charter — Compromisos del Programa

Los siguientes compromisos son no negociables para la operación del modelo SIAM en Unity R4:

**Del Service Recipient (BanCoppel):**
1. Tomar decisiones contractuales (penalizaciones, contrataciones) en máximo 5 días hábiles tras recomendación de Accenture.
2. Designar owner de la decisión de contratación CAT antes del 2026-08-25.
3. Brenda Abril aprueba formalmente toda penalización recomendada por Accenture antes de aplicarla.

**Del Service Integrator (Accenture):**
1. Mantener RAID actualizado semanalmente con evidencia de bloqueos cross-vendor.
2. Emitir recomendación formal de penalización dentro de 72 horas de confirmar incumplimiento de SLA.
3. No escalar a EY directamente — toda coordinación con Temenos Transact va vía BanCoppel.

**De los Service Providers:**
1. BPC: resolver BYU0039 con dictamen formal antes de inicio SIT (2026-10-15).
2. BPC: definición completa de TRNTs Pagos antes de 2026-09-15.
3. AppWhere: compromiso formal escrito de las 6 User Stories Must Have antes de 2026-08-31.
4. CAT vendor: firma de contrato antes de 2026-08-31 o comunicación formal de imposibilidad.
5. Kreios: entregar plan de transferencia de conocimiento ante rotación diciembre antes de 2026-10-01.

---

## Matriz de Riesgos por Vendor

| Riesgo | Vendor | Probabilidad | Impacto | Fecha límite | Palanca |
|---|---|---|---|---|---|
| CAT sin contratar | Proveedor CAT | Alta | Crítico | 2026-08-31 | Decisión ejecutiva BanCoppel — owner DATO-REQUERIDO |
| BYU0039 sin cierre | BPC | Media | Alto | 2026-10-15 (antes SIT) | Escalar L3 a account manager BPC |
| DPP no licenciado | BPC | Decisión pendiente | Alto | DATO-REQUERIDO | Contratar módulo o desarrollar alternativa |
| TRNTs Pagos 0% | BPC | Alta | Alto | 2026-09-15 | Penalization Log PEN-001 — recomendación L4 |
| Latencia APOLO | AppWhere | Media | Medio | Antes SIT | SLA contractual — confirmar compromiso escrito |
| 6 User Stories Must Have App | AppWhere | Alta | Alto | 2026-10-01 | Penalization Log PEN-002 — compromiso escrito |
| Rotación Kreios | Kreios | Alta | Medio | Dic 2026 | Plan de transferencia obligatorio antes oct |
| Certificación maquiladores | GID/Forza/TGS | Desconocida | Alto | Antes go-live | Confirmar status ahora — Vendor Scorecard |

---

## DATO-REQUERIDO — Información crítica faltante

1. **CAT**: nombre del proveedor seleccionado, fecha de firma, owner de la decisión en BanCoppel
2. **BPC BYU0039**: fecha comprometida de resolución y dictamen formal
3. **BPC DPP**: decisión de contratar módulo o desarrollar alternativa — fecha límite
4. **BPC TRNTs**: plan de recuperación para llegar a 100% — responsable BPC nombrado
5. **BPC tickets maquila** (#13830642 + #13830651): fecha de resolución comprometida
6. **AppWhere**: compromiso formal escrito de las 6 User Stories Must Have de App
7. **AppWhere**: SLA de latencia APOLO comprometido post-mejoras (valor en ms)
8. **Maquiladores**: status de certificación de layout P4900 para GID, Forza, TGS
9. **Kreios**: deliverables formales R4 + plan de transferencia ante rotación diciembre
10. **Comités SIAM**: confirmar frecuencias y fechas de primer sesión con Tere González
11. **Escalation paths**: nombre del account manager BPC y dirección de AppWhere para L3/L4

---

*Creado: 2026-08-16 v1.0.0 — Digital Twin Vendors Unity R4*
*Actualizado: 2026-08-19 v2.0.0 — Modelo SIAM formal · Vendor Register · Dependency Map · Escalation Matrix · Penalization Log · SIAM Charter*
*Prioridad: URGENTE — deadline CAT 2026-08-31 · PEN-001 BPC TRNTs pendiente*