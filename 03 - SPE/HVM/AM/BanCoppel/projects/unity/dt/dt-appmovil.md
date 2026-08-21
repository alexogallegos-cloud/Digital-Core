# DT — APP / AppMovil (Canal Digital)
> Digital Twin del track AppMovil para la Tarjeta de Crédito R4 (Producto 4900).
> Fuente primaria: `20260806 - R4 APP - Analisis detallado HDUs e Integraciones.docx`
> Fuentes secundarias: `Consolidacion User Stories v2.xlsx`, `Inventario de Integraciones_HUs_ R4_v1.0.xlsx`,
>                      `app_user_stories Jira (SMART-3962…4531)`
> Última actualización: 2026-08-20 · v1.0.0

---

## Resumen del Track

| Campo | Valor |
|-------|-------|
| Track ID | `app` |
| Proveedor | Nova Solution Systems |
| Sesiones de análisis | 2 sesiones (2026-08-04 / 2026-08-06) |
| RAG R4 | 🟡 YELLOW (general) · 🔴 RED (dimensión integraciones) |
| Source doc | `20260806 - R4 APP - Analisis detallado HDUs e Integraciones.docx` |

### MoSCoW del Track (USI v2)

| MoSCoW | Cuenta | Notas |
|--------|--------|-------|
| Must | 15 | Entrega comprometida R4 |
| Should | 0 | — |
| Could | 1 | SMART-4105 notificación activación |
| Won't | 2 | Diferidas a R4.5 (ver sección de gaps) |
| **Total** | **18** | Incluye los 2 Won't (15+0+1+2=18) |

### Distribución por Tipo de Solución

| Tipo | Cuenta |
|------|--------|
| Solución (frontend) | 10 |
| Integración (backend) | 4 |
| Mixta (solución + integración) | 4 |

### Complejidad

| Nivel | Cuenta |
|-------|--------|
| Baja | 5 |
| Media | 6 |
| Alta | 7 |

---

## User Stories (hdu_catalog) — 20 User Stories

La tabla User Story (Historias de Usuario de Desarrollo) refleja el análisis técnico del canal App para R4.
Fuente: generada por Accenture en sesiones de análisis agosto 2026.

### APP-MF-01 — Visualización y gestión básica F&D

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-APP-R4-01 | Visualizar estado de cuenta de TDC en App (`getInstantCreditStatement`) | CAP-BALANCE-STATEMENT | partial |
| HDU-APP-R4-02 | Gestionar convivencia de tarjeta física y digital en App | CAP-CARD-LIFECYCLE | partial |
| HDU-APP-R4-03 | Operar botones de acción por estatus CSTS de tarjeta | CAP-COLLECTIONS-AGING | partial |
| HDU-APP-R4-04 | Visualizar detalle de tarjeta física y digital (`getAccountCards`) | CAP-CUSTOMER-PROFILE | partial |
| HDU-APP-R4-05 | Visualizar detalle de tarjeta en pantalla dedicada | CAP-CUSTOMER-PROFILE | partial |
| HDU-APP-R4-06 | Gestionar CVV dinámico de tarjeta digital con timer de visibilidad | CAP-AUTHENTICATION | partial |
| HDU-APP-R4-07 | Etiquetar transacciones "En Proceso" (`amountHoldPlaced=true`) | CAP-BALANCE-STATEMENT | partial |
| HDU-APP-R4-08 | Consultar movimientos del periodo (`getTransactions v22`) | CAP-BALANCE-STATEMENT | partial |

### APP-MF-02 — Operaciones

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-APP-R4-09 | Consultar estado de planes de compras diferidas (CrediSoluciones) | CAP-DEFERRED-PURCHASE | partial |
| HDU-APP-R4-10 | Procesar pago de TDC desde App (MAD/PPNGI/total/libre) | CAP-PAYMENT | partial |
| HDU-APP-R4-11 | Gestionar eliminación de tarjeta digital (cancelación definitiva en SmartVista) | CAP-CARD-LIFECYCLE | partial |
| HDU-APP-R4-12 | Gestionar límite de reposiciones de tarjeta por periodo | CAP-CARD-LIFECYCLE | partial |

### APP-MF-03 — Notificaciones

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-APP-R4-13 | Notificar impactos al eliminar tarjeta digital (aviso previo) | CAP-CARD-LIFECYCLE | **not_covered** |

### APP-MF-04 — Compras diferidas

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-APP-R4-14 | Visualizar desglose de compras diferidas MCI en App | CAP-DEFERRED-PURCHASE | partial |
| HDU-APP-R4-15 | Visualizar desglose de compras diferidas MSI en App (vía E-Global) | CAP-DEFERRED-PURCHASE | partial |
| HDU-APP-R4-16 | Visualizar montos diferidos en estado de cuenta App | CAP-DEFERRED-PURCHASE | partial |

### APP-MF-05 — Mora y sobrepago

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-APP-R4-17 | Mostrar restricciones por mora (`agingPeriod E1/E2/E3`) en App | CAP-COLLECTIONS-AGING | partial |
| HDU-APP-R4-18 | Validar límite de saldo a favor en middleware de App | CAP-OVERPAYMENT | **not_covered** |
| HDU-APP-R4-19 | Mostrar mensaje de restricción por saldo a favor (homologado entre canales) | CAP-OVERPAYMENT | **not_covered** |
| HDU-APP-R4-20 | Validación preventiva de inputs de pago en App (formato, mínimo, máximo) | CAP-OVERPAYMENT | **not_covered** |

**Resumen cobertura User Story**: 16 partial + 4 not_covered = 20 total.
Los 4 not_covered (HDU-13, 18, 19, 20) están vinculados a gaps de capabilities CAP-CARD-LIFECYCLE y CAP-OVERPAYMENT.

---

## User Stories Inventory (USI v2) — 18 User Stories

Fuente: `Consolidacion User Stories v2.xlsx` + `APP - Analisis detallado HDUs e Integraciones.docx`

| ID | Título | MoSCoW | Complejidad | Tipo |
|----|--------|--------|-------------|------|
| APP-ENC-01 | Encendido, Apagado y Bloqueo Operativo — TDC Digital (Originación Apolo) | Must | Media | Solución |
| APP-ENC-02 | Encendido, Apagado y Bloqueo Operativo — TDC Física (Originación Apolo) | Must | Media | Solución |
| APP-ENC-03 | Encendido, Apagado y Bloqueo Operativo — TDC Física (Originación Legado) | Must | Baja | Solución |
| PTCSF-6267 | Actualizar operaciones TDC Digital en una misma sesión | Must | Media | Solución |
| SMART-3962 | Detalle de crédito convivencia TDC F&D | Must | Alta | Sol. e Integración |
| SMART-3963 | Tarjetas Asociadas Física y Digital | Must | Alta | Solución |
| SMART-3964 | Gestión de Tarjeta de Crédito Física — Canal Apolo | Must | Alta | Solución |
| SMART-3966 | Activación de TDC Digital | Must | Media | Solución |
| SMART-4105 | Notificación de activación Tarjeta Digital BanCoppel | Could | Baja | Integración |
| SMART-4176 | Movimientos Convivencia TDC F&D | Must | Media | Sol. e Integración |
| SMART-4180 | Detalle de Movimientos Convivencia TDC F&D | **Won't R4.5** | Alta | Sol. e Integración |
| SMART-4182 | Visualización y aplicación de montos de pago en Línea TDC | Must | Baja | Integración |
| SMART-4183 | Límite de saldo a favor para pago de TDC en la aplicación móvil | Must | Baja | Integración |
| SMART-4219 | Gestión de Tarjeta de Crédito Digital — Canal Apolo | Must | Alta | Solución |
| SMART-4226 | Gestión de Tarjeta de Crédito Física — Modelo Legado | Must | Alta | Solución |
| SMART-4278 | Eliminación de TDC Digital | **Won't R4.5** | Alta | Sol. e Integración |
| SMART-4280 | Gestión del campo "Otra cantidad" basado en el límite de saldo a favor | Must | Baja | Integración |
| SMART-4531 | Convivencia en Home de Cuentas TDC F&D | Must | Media | Solución |

### User Stories del Jira (estado Jira)

Fuente: `Respaldo Docs Bancoppel - App/` — 13 historias Jira (SMART-3962…SMART-4531)

| SMART ID | Título | Estado Jira | Capability |
|----------|--------|-------------|-----------|
| SMART-3962 | Detalle de Crédito Convivencia TDC F&D | removed | CAP-BALANCE-STATEMENT |
| SMART-3963 | Tarjetas Asociadas Física y Digital | backlog | CAP-CARD-LIFECYCLE |
| SMART-3964 | Gestión de TDC Física (Orig. Apolo) | release | CAP-CARD-LIFECYCLE |
| SMART-3965 | Encendido y apagado de TDC Física y Digital | backlog | CAP-CARD-LIFECYCLE |
| SMART-3966 | Activación de TDC Digital | backlog | CAP-CARD-LIFECYCLE |
| SMART-4105 | Notificación activación Tarjeta Digital BanCoppel | backlog | CAP-CARD-LIFECYCLE |
| SMART-4176 | Movimientos Convivencia TDC F&D | backlog | CAP-BALANCE-STATEMENT |
| SMART-4180 | Detalle de Movimientos Convivencia TDC F&D | backlog | CAP-BALANCE-STATEMENT |
| SMART-4182 | Visualización y aplicación de montos de pago en Línea TDC | backlog | CAP-PAYMENT |
| SMART-4219 | Gestión de TDC Digital (Orig. Apolo) | release | CAP-CARD-LIFECYCLE |
| SMART-4426 | Gestión de TDC Física (Orig. Legado) | release | CAP-CARD-LIFECYCLE |
| SMART-4478 | Eliminación de TDC Digital | removed | CAP-CARD-LIFECYCLE |
| SMART-4531 | Convivencia en Home de Cuentas TDC F&D | backlog | CAP-CARD-LIFECYCLE |

> **Discrepancia documentada (OPEN):** El Jira tiene 13 historias; la USI v2 tiene 18.
> Los 8 IDs en USI que no aparecen en el Jira BanCoppel: APP-ENC-01/02/03, PTCSF-6267, SMART-4183, SMART-4226, SMART-4278, SMART-4280.
> Posible causa: APP-ENC-* y PTCSF-* pueden ser tickets en una instancia Jira diferente (Nova Solution Systems),
> mientras que SMART-* son tickets de la instancia BanCoppel. Requiere confirmación con PMO.

---

## Integraciones del Track APP — 4 integraciones

Fuente: `Inventario de Integraciones_HUs_ R4_v1.0.xlsx`

| ID | User Story | Nombre | Sistema Origen | Sistema Destino | Tipo | Estado | Complejidad |
|----|-----------|--------|---------------|----------------|------|--------|-------------|
| IAPP01 | SMART-3962 | CAMBIOS en detalle TDC `Rec_retrieveCreditCardStatement` | APP | SMARTVISTA | API | Modificar | Media |
| IAPP02 | SMART-4183 | Realiza el pago de TDC `Rec_executeCardPaymentTransaction` | SMARTVISTA | APP | API | Modificar | Alta |
| IAPP03 | SMART-4176 | Consulta de movimientos `Rec_RetrieveAccountTransaction` | SMARTVISTA | APP | API | Modificar | Media |
| IAPP05 | SMART-4105 | Notificación activación de Tarjeta Digital BanCoppel | APP | CES | API | Nueva | Media |

> **Nota:** El ID IAPP04 no existe en el inventario — puede ser un gap de numeración en la fuente.
> Las 4 integraciones son 100% API REST en tiempo real. Las 3 primeras son modificaciones de APIs existentes;
> solo la notificación a CES es nueva.

---

## Gaps Críticos del Track

| Gap ID | Descripción | Impacto | Status |
|--------|-------------|---------|--------|
| GAP-APP-01 | SMART-4180 "Detalle de Movimientos Convivencia TDC F&D" diferida a R4.5 | No verá historial completo en convivencia F&D | Won't R4.5 |
| GAP-APP-02 | SMART-4278 "Eliminación de TDC Digital" diferida a R4.5 | El cliente no podrá eliminar la tarjeta digital desde App en R4 | Won't R4.5 |
| GAP-APP-03 | HDU-APP-R4-13: notificación de impactos al eliminar TDC digital | Flujo de eliminación incompleto sin aviso previo | not_covered |
| GAP-APP-04 | HDU-APP-R4-18/19/20: validación y mensajes de saldo a favor — no cubiertos | 3 User Stories independientes de BYU0039 sin cobertura | not_covered |

---

## Riesgos del Track

| Riesgo | Descripción | Probabilidad | Impacto | Due Date |
|--------|-------------|-------------|---------|----------|
| RISK-UNITY-R02 | 6 User Stories Must Have APP cierran en noviembre — riesgo de SIT tarde | Alta | Alto | 2026-10-01 |

---

## Stakeholders del Track APP

| Rol | Nombre | Empresa |
|-----|--------|---------|
| Proveedor APP | Nova Solution Systems | Nova |
| SME ACN | Por confirmar | Accenture |
| Track Owner BanCoppel | Por confirmar | BanCoppel |

---

## Pendientes

- [ ] Confirmar si APP-ENC-* y PTCSF-* son tickets Jira Nova o BanCoppel
- [ ] Resolver discrepancia entre 13 historias Jira y 18 en USI v2
- [ ] Confirmar estado de HDU-APP-R4-11 (eliminación TDC digital): ¿Won't o partial?
  (El hdu_catalog dice "partial" pero la USI marca SMART-4278 como "Won't")
- [ ] Verificar cobertura de IAPP04 faltante en el inventario de integraciones

---

*Creado: 2026-08-20 · v1.0.0 · Fuente: análisis sesiones APP 2026-08-04/06*
