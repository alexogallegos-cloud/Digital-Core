# DT: SmartVista & Canales — Unity R4
> **Digital Twin** · Fuente: `HDU_R4_CANALES APP_SIWEB_CATT_SMARTVISTA.xlsx` + `TDC_R4_SV_Canales_PreGame_20260728_V1.0_Appwhere.pdf`
> **Versión**: v1.0.0 · 2026-08-16
> **Scope**: Producto 4900 — Tarjeta de Crédito · BIN 4268 0711

---

## Cobertura PreGame por Canal

| Canal | HDUs | Nativo | Configurable | Parcial | No cubierto | Por determinar | Cobertura SV |
|-------|------|--------|--------------|---------|-------------|----------------|--------------|
| SmartVista | 22 | 2 | 3 | 13 | 2 | 2 | 55% |
| APP | 20 | 0 | 0 | 13 | 4 | 0 | 44% |
| CAT | 12 | 0 | 0 | 6 | 6 | 0 | 34% |
| SIWEB | 5 | 0 | 0 | 3 | 1 | 1 | 37% |
| **Total** | **59** | **2** | **3** | **35** | **13** | **3** | — |

> **Lectura**: "Cobertura SV" indica qué porcentaje de las User Stories del canal puede ser cubierto por SmartVista (nativo + configurable + parcial). El resto requiere construcción en el canal.

---

## HDUs por Canal y Funcionalidad Macro

### SmartVista — 22 HDUs

#### SV-MF-01: Solicitud de Maquila Automatizada (HDU-SMART-R4-01 a 08)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-01 | Certificar layouts de maquila con GID/Forza/TGS (PGP+HSM) | PARCIAL | DTM_ExecuteCardManufacturingRequest |
| HDU-SMART-R4-02 | Consultar inventario de tarjetas por sucursal (existencia vs en-ruta) | PARCIAL | — |
| HDU-SMART-R4-03 | Calcular maquila con parámetros de abasto (piso, semanas, redondeo 250) | **NO CUBIERTO** | DTM_CalculateCardManufacturing |
| HDU-SMART-R4-04 | Ejecutar solicitud automatizada de maquila | PARCIAL | DTM_ExecuteCardManufacturingRequest |
| HDU-SMART-R4-05 | Ejecutar solicitud manual de maquila | TOTAL NATIVO | — |
| HDU-SMART-R4-06 | Generar archivos seguros de maquila (SVBO→OCG→Cargen→PGP→Connect Direct) | TOTAL NATIVO | — |
| HDU-SMART-R4-07 | Dar seguimiento a estatus de lotes | PARCIAL | — |
| HDU-SMART-R4-08 | Controlar recepción y cancelación de lotes | PARCIAL | — |

#### SV-MF-02: Comisiones y Catálogos (HDU-SMART-R4-09)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-09 | Gestión de comisiones por catálogo centralizado (homologación BANXICO) | TOTAL PARAMETRIZABLE | — |

#### SV-MF-03: Autorizador 88 Reglas (HDU-SMART-R4-10, 11)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-10 | Actualizar nombre del producto desde catálogo SV (no hardcode) | PARCIAL | — |
| HDU-SMART-R4-11 | Configurar criterios autorizador: Módulo 1 ISO + Módulo 2 PayTrue | PARCIAL | DTM_ValidateBPCAuthorization |

#### SV-MF-04: Saldo a Favor / Overpayment (HDU-SMART-R4-12 a 14)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-12 | Parametrizar límite de saldo a favor por tramo de línea de crédito | TOTAL PARAMETRIZABLE | — |
| HDU-SMART-R4-13 | Validar límite saldo a favor (rechazo completo, sin póliza parcial) | **POR DETERMINAR** ⚠️ BYU0039 | DTM_ManageOverpaymentLimit |
| HDU-SMART-R4-14 | Excluir abonos SPEI del límite de crédito hasta confirmación clearing | **POR DETERMINAR** | — |

#### SV-MF-05: Catálogo / Gestión de Tarjetas (HDU-SMART-R4-15 a 18)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-15 | Actualizar mensajes de error desde catálogo SV (3 canales) | PARCIAL | — |
| HDU-SMART-R4-16 | Gestionar campañas MSI/MCI (parametrización) | TOTAL PARAMETRIZABLE | — |
| HDU-SMART-R4-17 | Gestionar estatus CSTS de tarjeta (física/digital por campo Classification) | PARCIAL | — |
| HDU-SMART-R4-18 | Reposición y reemplazo de tarjeta (robo, extravío, daño, vencimiento) | PARCIAL | — |

#### SV-MF-06: Compras Diferidas / Liquidación (HDU-SMART-R4-19 a 21)

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SMART-R4-19 | Gestionar PPNGI y MAD en estado de cuenta | PARCIAL | — |
| HDU-SMART-R4-20 | Liquidar plan de pagos diferidos anticipadamente | PARCIAL | DTM_SettleDeferredPurchasePlan |
| HDU-SMART-R4-21 | Cancelar plan de pagos diferidos desde canales digitales | **NO CUBIERTO** 🔴 GAP DPP | DTM_CancelDeferredPurchasePlan |

---

### APP — 20 HDUs

#### APP-MF-01: Consulta y Estado de Cuenta (HDU-APP-R4-01 a 09)

| HDU | Narrativa corta | PreGame |
|-----|-----------------|---------|
| HDU-APP-R4-01 | Visualizar estado de cuenta TDC (getInstantCreditStatement, agingPeriod) | PARCIAL |
| HDU-APP-R4-02 | Gestionar convivencia tarjeta física y digital (estados individuales) | PARCIAL |
| HDU-APP-R4-03 | Operar botones de acción por estatus CSTS (bloqueo por agingPeriod) | PARCIAL |
| HDU-APP-R4-04 | Visualizar detalle de tarjeta física y digital (getAccountCards) | PARCIAL |
| HDU-APP-R4-05 | Pantalla de detalle dedicada de tarjeta | PARCIAL |
| HDU-APP-R4-06 | Gestionar CVV dinámico con timer de visibilidad | PARCIAL |
| HDU-APP-R4-07 | Etiquetar transacciones "En Proceso" (amountHoldPlaced=true) | PARCIAL |
| HDU-APP-R4-08 | Consultar movimientos del periodo (getTransactions v22) | PARCIAL |
| HDU-APP-R4-09 | Consultar estado de planes CrediSoluciones | PARCIAL |

#### APP-MF-02/03: Pagos y Restricciones (HDU-APP-R4-10 a 13)

| HDU | Narrativa corta | PreGame |
|-----|-----------------|---------|
| HDU-APP-R4-10 | Procesar pago TDC desde App (MAD/PPNGI/total/libre) | PARCIAL |
| HDU-APP-R4-11 | Gestionar eliminación tarjeta digital (cancelación definitiva) | PARCIAL |
| HDU-APP-R4-12 | Gestionar límite de reposiciones por periodo | PARCIAL |
| HDU-APP-R4-13 | Notificar impactos al eliminar tarjeta digital (aviso previo) | **NO CUBIERTO** |

#### APP-MF-04: Montos Diferidos (HDU-APP-R4-14 a 16)

| HDU | Narrativa corta | PreGame |
|-----|-----------------|---------|
| HDU-APP-R4-14 | Visualizar desglose de compras diferidas MCI | PARCIAL |
| HDU-APP-R4-15 | Visualizar desglose de compras diferidas MSI (vía E-Global) | PARCIAL |
| HDU-APP-R4-16 | Visualizar montos diferidos en estado de cuenta | PARCIAL |

#### APP-MF-05: Validaciones y Restricciones (HDU-APP-R4-17 a 20)

| HDU | Narrativa corta | PreGame |
|-----|-----------------|---------|
| HDU-APP-R4-17 | Mostrar restricciones por mora (E1/E2/E3 visual) | PARCIAL |
| HDU-APP-R4-18 | Validar límite saldo a favor en middleware App | **NO CUBIERTO** |
| HDU-APP-R4-19 | Mensaje de restricción saldo a favor (homologado entre canales) | **NO CUBIERTO** |
| HDU-APP-R4-20 | Validación preventiva de inputs de pago (frontend) | **NO CUBIERTO** |

---

### CAT — 12 HDUs

#### CAT-MF-01: IVR Autoservicio

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-CAT-R4-01 | Acceso al menú IVR con ANI (identificación automática) | **NO CUBIERTO** | — |
| HDU-CAT-R4-02 | Consultar saldos y movimientos desde IVR | **NO CUBIERTO** | DTM_RetrieveCreditCardBalanceAndMovements |
| HDU-CAT-R4-08 | Completar integración saldo/movimientos IVR-SVIP | **NO CUBIERTO** | DTM_RetrieveCreditCardBalanceAndMovements |
| HDU-CAT-R4-09 | Autenticación reforzada en IVR (DTMF) | **NO CUBIERTO** | — |
| HDU-CAT-R4-10 | Menú dinámico IVR por nivel de mora (agingPeriod) | **NO CUBIERTO** | — |

#### CAT-MF-02: Autenticación y Perfil

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-CAT-R4-03 | Identificar cliente y perfil TDC en ICCAT (crédito 18 dígitos) | PARCIAL | DTM_RetrieveCustomerCreditCardProfile |
| HDU-CAT-R4-04 | Gestionar intentos de autenticación CAT (3 max, bloqueo) | **NO CUBIERTO** | — |
| HDU-CAT-R4-05 | Bloquear tarjeta desde CAT vía ICCAT (updateCardStatus + SMS) | PARCIAL | — |
| HDU-CAT-R4-06 | Desbloquear tarjeta desde CAT con OTP SMS de 4 dígitos | PARCIAL | — |
| HDU-CAT-R4-07 | Consultar estatus de tarjeta desde CAT (getAccountCards/getCardInfo) | PARCIAL | — |

#### CAT-MF-03: Reporte de Cancelación

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-CAT-R4-11 | Registrar reporte de robo/extravío desde CAT (folio + SMS) | PARCIAL | — |
| HDU-CAT-R4-12 | Gestionar cancelación definitiva de tarjeta desde CAT | PARCIAL | DTM_ManageCardCancellationReport |

---

### SIWEB — 5 HDUs

| HDU | Narrativa corta | PreGame | DTM |
|-----|-----------------|---------|-----|
| HDU-SIWEB-R4-01 | Consultar saldos y movimientos TDC en SIWEB | PARCIAL | — |
| HDU-SIWEB-R4-02 | Procesar compras diferidas MCI/MSI en SIWEB (Transacción 623) | PARCIAL | DTM_ManageDeferredPurchase |
| HDU-SIWEB-R4-03 | Cancelar plan de compras diferidas desde SIWEB | **NO CUBIERTO** 🔴 GAP DPP | DTM_ManageDeferredPurchase |
| HDU-SIWEB-R4-04 | Registrar efectos contables compras diferidas (SV-SIWEB-PISA) | PARCIAL | DTM_RegisterDeferredPurchaseAccountingEffects |
| HDU-SIWEB-R4-05 | Validar límite saldo a favor en caja/ventanilla | **POR DETERMINAR** ⚠️ BYU0039 | DTM_ValidateOverpaymentLimit |

---

## Inventario de DTMs (14 componentes técnicos)

| DTM | Canal | HDUs | Estado | Gap |
|-----|-------|------|--------|-----|
| DTM_CalculateCardManufacturing | smartvista | R4-03 | 🔴 NO CUBIERTO | Lógica de cálculo paramétrico no nativa; requiere desarrollo |
| DTM_ExecuteCardManufacturingRequest | smartvista | R4-01, R4-04 | 🟡 PARCIAL | OCG y Connect Direct manuales en R4 (2 pasos) |
| DTM_CancelDeferredPurchasePlan | smartvista | R4-21 | 🔴 NO CUBIERTO | **Módulo DPP no contratado** — gap crítico de programa |
| DTM_SettleDeferredPurchasePlan | smartvista | R4-20 | 🟡 PARCIAL | Liquidación existe; validaciones contables específicas como delta |
| DTM_ManageOverpaymentLimit | smartvista | R4-13 | ⚠️ POR DETERMINAR | **Ticket BYU0039 abierto** en ValueEdge |
| DTM_ValidateOverpaymentLimit | siweb | SIWEB-R4-05 | ⚠️ POR DETERMINAR | **Misma dependencia BYU0039** |
| DTM_ValidateBPCAuthorization | smartvista | R4-11 | 🟡 PARCIAL | Autorizador base nativo; integración PayTrue como delta |
| DTM_ManageDeferredPurchase | siweb | SIWEB-R4-02, R4-03 | 🟡 PARCIAL | Cierre automático DPP no contratado; cancela mación gap |
| DTM_RegisterDeferredPurchaseAccountingEffects | siweb | SIWEB-R4-04 | 🟡 PARCIAL | Guía contable formal pendiente (dependencia RAID D01) |
| DTM_RetrieveCreditCardBalanceAndMovements | cat | CAT-R4-02, R4-08 | 🔴 NO CUBIERTO | Integración IVR-SVIP completa a construir |
| DTM_RetrieveCustomerCreditCardProfile | cat | CAT-R4-03 | 🟡 PARCIAL | APIs SVIP disponibles; integración ICCAT a construir |
| DTM_ManageCardCancellationReport | cat | CAT-R4-12 | 🟡 PARCIAL | Robo/extravío cubiertos; daño/destrucción dependen de parametrización |
| NO-DTM-SMART-R4-10 | smartvista | R4-10 | 🟡 PARCIAL | Sin DTM asignado; catálogo SV existe; modificar App y SIWEB |
| NO-DTM-SMART-R4-15 | smartvista | R4-15 | 🟡 PARCIAL | Sin DTM asignado; catálogo SV existe; modificar 3 canales |

---

## Brechas Críticas del Release R4

### GAP 1 — Módulo DPP no contratado (impacto en 3 HDUs y 3 DTMs)

El módulo **Deferred Payment Plan (DPP)** de SmartVista/BPC no está licenciado por BanCoppel para R4. Esto genera un bloque en cascada:

- HDU-SMART-R4-21: No se puede cancelar un plan CrediSoluciones desde canales digitales
- HDU-SIWEB-R4-03: No se puede cancelar un plan CrediSoluciones desde sucursal
- DTM_CancelDeferredPurchasePlan: No existe la función de cancelación
- DTM_ManageDeferredPurchase: El cierre automático del pago fijo queda sin completar

**Opciones de remediación**: (1) Contratar el módulo DPP con BPC — decisión y presupuesto pendientes; (2) Desarrollar lógica de cancelación a medida — esfuerzo no dimensionado.

### GAP 2 — Ticket BYU0039 abierto (impacto en 2 HDUs y 2 DTMs)

El ticket **BYU0039** en ValueEdge sobre "Límite Máximo de Saldo a Favor" está en estado `Opened, in investigation`. Hasta que no cierre, no se puede determinar el comportamiento exacto ni cerrar los criterios de aceptación de:

- HDU-SMART-R4-13 + DTM_ManageOverpaymentLimit
- HDU-SIWEB-R4-05 + DTM_ValidateOverpaymentLimit

**Owner**: SmartVista / Armando García + BPC.

### GAP 3 — OCG y Connect Direct manuales (impacto operativo en maquila)

El flujo de generación de tarjetas en R4 tiene los pasos 2 y 3 manuales:

```
SVBO → [OCG → Cargen]manual → PGP → Connect Direct
```

Los pasos `OCG` y `Cargen` son automáticos en producción futura pero manuales en R4. Esto limita la capacidad de maquila automatizada hasta que se completen los tickets de infraestructura (#13830642 y #13830651).

---

## Arquitectura de Integración SVIP

```
E-Global ──────────────────────────────────────┐
                                               ▼
App BanCoppel ── Middleware ──► SVIP ──► SVBO (contratos, contabilidad, parámetros)
SIWEB ────────── (Accenture) ──► SVIP ──► SVFE (autorizador, consola operativa)
ICCAT (CAT) ────────────────────► SVIP ──► SVCG/Cargen (maquila de tarjetas)
IVR (800 BanCoppel) ────────────► SVIP ──► OCG → Cargen → PGP → Connect Direct
APOLO (originación) ────────────► SVIP        └─► Maquiladores: GID | Forza | TGS
```

**APIs clave del catálogo SVIP (92 comandos):**

| API | Qué retorna | HDUs que la consumen |
|-----|-------------|----------------------|
| `getInstantCreditStatement` | Estado de cuenta en tiempo real: saldo, límite, disponible, PPNGI, MAD, fechas | APP-01, CAT-02, CAT-08, SIWEB-01 |
| `getTransactions v22` | Movimientos con `amountHoldPlaced` (boolean "En Proceso") | APP-07, APP-08, SIWEB-01 |
| `getAccountCards` | Tarjetas por cuenta (física/digital, campo Classification F/D) | APP-04, CAT-07 |
| `updateCardStatus` | Cambia estatus CSTS de una tarjeta | CAT-05, CAT-06, CAT-11 |
| `getCardInfo` | Detalle de tarjeta individual | CAT-07 |
| CVV dinámico | Código de verificación temporal para tarjeta digital | APP-06 |

---

## Campos Críticos del Modelo de Datos SmartVista

| Campo | Tipo | Significado | HDUs afectadas |
|-------|------|-------------|----------------|
| `agingPeriod` | Enum E1/E2/E3 | Nivel de mora: E1=0-1 (sin restricción), E2=2-3 (parcial), E3≥4 (bloqueo) | APP-01/03/17, CAT-10 |
| `amountHoldPlaced` | Boolean | `true` = pre-autorización e-commerce no liquidada ("En Proceso") | APP-07, SIWEB-01 |
| `Classification` | Char F/D | F=física, D=digital. NO se determina por BIN | APP-02/04, SMART-17 |
| `CSTS` | Prefijo catálogo | Estatus de tarjeta (CSTS_ACTIVE, CSTS_BLOCKED, etc.) | APP-03, CAT-05/06/12 |
| `BLTP` | Código | Balance Type: subcuenta/cajón de saldo dentro del contrato | SMART-19/20 |
| `PPNGI` | Decimal | Pago Para No Generar Intereses del periodo | APP-01/10, SMART-19 |
| `MAD` | Decimal | Monto mínimo a pagar del periodo (distinto del PPNGI) | APP-01/10, SMART-19 |
| Crédito 18 dígitos | String(18) | Número interno SmartVista ≠ PAN 16 dígitos del plástico | CAT-01/03 |
| BIN 4268 0711 | String | BIN del Producto 4900; subBIN 0-4=digital, 5-9=física | SMART-17 |

---

## Flujo de Autorización de Transacciones

```
Comercio → E-Global → SmartVista autorizador (88 reglas)
                            ├── Módulo 1: rechazo inmediato por código ISO (catálogo BPC)
                            └── Módulo 2: evaluación de riesgo vía PayTrue (no SVFM)
                                    ├── Aprobación → respuesta ISO a E-Global → Comercio
                                    └── Rechazo → respuesta ISO con código de rechazo
```

**Nota SVFM**: El módulo SmartVista Fraud Management **NO está licenciado** por BanCoppel. PayTrue actúa como el motor de fraude externo que reemplaza la función de SVFM.

---

## Flujo de Compras Diferidas

```
MSI: Canal → E-Global → SmartVista (registro) — R4 scope; pruebas integración en scope
MCI: Canal → SIWEB → SmartVista (CrediSoluciones/DPP) — backend R4; APP en R4.5
     Contabilidad: SmartVista aplica el TRNT (tipo de transacción contable interno, ej. T623) y PISA recibe
                   OJO: TRNT aquí NO es Temenos Transact. Transact no participa en el ciclo del Producto 4900.
     Reclasificación MCI: Grupo contable 13 (capital no corriente)
     Cuenta 2402/Eglobal: solo para interchange MSI; MCI NO debe recircular aquí
```

---

## Productos en Producción (PRESENTE) — Alcance RAID

Los siguientes productos fueron identificados en el alcance del RAID v2.0 como productos ya en producción sobre Temenos Transact (releases anteriores a R4):

| ID | Producto | Release | Status |
|----|----------|---------|--------|
| UNITY-R1-P-CE-N2 | Cuenta Efectiva N2 | R1 | live |
| UNITY-R2-P-CED-N4 | Cuenta Efectiva Digital N4 | R2 | live |
| UNITY-R3-P-NOM-N4 | Nómina N4 | R3 | live |
| UNITY-RX-P-PS | Préstamo Simple | Rx (pendiente confirmar) | live |

> **DATO-REQUERIDO**: Confirmar release exacto y fecha de go-live de Préstamo Simple con PMO Unity.

---

## Reglas de Negocio Clave (selección)

**Maquila:**
- RN-OP-MA-01: Layout único posicional homologado para los 4 maquiladores (sin variantes de formato)
- RN-OP-MA-02: Cifrado PGP por proveedor + HSM por tarjeta; validar vigencia antes de generar
- RN-OP-MA-04: Cálculo automático de reorden diario a las 6:00 AM; piso default 4 semanas
- RN-OP-MA-11: Redondeo de volumen a múltiplos de 250 plásticos

**Saldo a favor / Pagos:**
- Límite de saldo a favor diferenciado por tramo de línea de crédito
- Si abono excede el límite → rechazo completo sin póliza parcial
- PPNGI: pago ≥ PPNGI → no se generan intereses; pago < MAD → cargo interés moratorio + actualiza agingPeriod

**Autorizador:**
- Módulo 1: rechazo inmediato por código ISO (catálogo BPC nativo)
- Módulo 2: evaluación de riesgo/fraude vía PayTrue (sistema externo)
- Flujo: E-Global → SmartVista → PayTrue → respuesta ISO

**Compras diferidas:**
- MCI: Grupo contable 13 para capital no corriente; NO recircular por cuenta 2402/Eglobal
- DPP cancelación: módulo no contratado → gap; cierre automático no disponible en R4
- TRNT 623: "PAGO CGO A CTA DE CREDISOLUCIONES" — código de transacción contable SIWEB

**Seguridad CAT:**
- OTP de 4 dígitos obligatorio para desbloquear tarjeta desde CAT
- ANI: número origen de llamada validado contra expediente del cliente
- Máximo 3 intentos de autenticación en IVR antes de transferir a agente
- Templates SMS: MAI_BDT_IC (bloqueo), SMS_BDT_IC (desbloqueo)

---

*Creado: 2026-08-16 — Digital Twin SmartVista & Canales R4 v1.0.0*
