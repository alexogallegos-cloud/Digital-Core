# Taxonomía de Negocio — BanCoppel
> **Tipo**: Modelo Lógico de Negocio · Taxonomía Canónica del Sistema
> **Versión**: 0.1.0 · 2026-08-02
> **Proyecto**: SPE-AM-001 · Informix
> **Autoridad**: SME Industry Banking · validada con evidencia AS-IS de BCOPBrain
> **Estado**: DRAFT — L1-L3 definidos · L4-L5 pendientes de análisis SP

---

## Propósito

Esta taxonomía es el **hilo conductor** del proyecto Informix. Todo artefacto del Gemelo Cognitivo (reglas de negocio, vocabulario, journeys, capacidades, riesgos) se referencia a un nodo de esta jerarquía.

| Nivel | Nombre | Descripción | Ejemplo |
|-------|--------|-------------|---------|
| L1 | **Dominio** | Área de negocio mayor del banco | Captación y Saldos |
| L2 | **Subdominio** | Agrupación funcional dentro del dominio | Cuenta de Ahorro |
| L3 | **Capacidad** | Qué puede hacer el banco en ese subdominio | Apertura de Cuenta |
| L4 | **Proceso** | Flujo de pasos que materializa la capacidad | Proceso de Onboarding de Cuenta |
| L5 | **Tarea** | Acción atómica dentro del proceso | Validar CURP en RENAPO |

**Cross-references por nodo:**
- `[ETB: X.Y.Z]` — código ETB v5.0 equivalente
- `[DB: DXX]` — base de datos Informix AS-IS
- `[REGLA: bc_id]` — regla de negocio SBVR de dt-reglas
- `[VOCAB: término]` — término de dt-vocabulario
- `[JOURNEY: id]` — journey de dt-journeys
- `[CNBV]` — disposición regulatoria aplicable

---

## Estructura de 7 Dominios

```
1. Cliente y Onboarding
2. Captación y Saldos
3. Crédito al Consumo
4. Tarjetas BanCoppel
5. Pagos y Transferencias
6. Canales y Distribución
7. Finanzas y Cumplimiento Regulatorio
```

---

# 1. Cliente y Onboarding
> Gestión del cliente como entidad central del banco — desde la captación inicial hasta el ciclo de vida completo de la relación.
> `[ETB: 7.1 Customer Management]` · `[DB: D02 bdinteg, D06 bdisolic, D14 bdibei]`

## 1.1 Perfil del Cliente
> Datos maestros del cliente: identidad, información personal, segmentación.
> `[ETB: 7.1.1]` · `[DB: D06 bdisolic]`

### 1.1.1 Creación del Perfil
> Capacidad de registrar por primera vez a un cliente con todos sus datos de identidad y contacto.
> `[CNBV: CUB Art. 78 — conservación 5 años]`

#### 1.1.1.1 Proceso de Captura de Datos Personales `[TBD — poblar desde BCOPBrain]`
##### 1.1.1.1.1 Captura de nombre completo `[TBD]`
##### 1.1.1.1.2 Captura de CURP `[TBD]`
##### 1.1.1.1.3 Captura de RFC `[TBD]`
##### 1.1.1.1.4 Captura de domicilio `[TBD]`

### 1.1.2 Actualización del Perfil
> Capacidad de modificar datos del cliente ya existente.

#### 1.1.2.1 Proceso de Actualización de Datos `[TBD]`

### 1.1.3 Consulta del Perfil
> Capacidad de recuperar el perfil completo del cliente para operaciones y validaciones.

#### 1.1.3.1 Proceso de Consulta de Datos del Cliente `[TBD]`

---

## 1.2 Onboarding y KYC
> Proceso de incorporación de nuevos clientes con verificación de identidad y cumplimiento regulatorio.
> `[ETB: 7.1.1, 3.2.1, 3.2.2]` · `[DB: D06 bdisolic]` · `[CNBV: Disposiciones PLD — CUP Art. 5]`

### 1.2.1 Solicitud de Producto
> Capacidad de recibir y gestionar una solicitud de apertura de cuenta o crédito.
> `[DB: D06 bdisolic]`

#### 1.2.1.1 Proceso de Solicitud de Cuenta `[TBD]`
#### 1.2.1.2 Proceso de Solicitud de Crédito `[TBD]`

### 1.2.2 Verificación de Identidad
> Capacidad de validar que el solicitante es quien dice ser (KYC — Know Your Customer).
> `[CNBV: Disposiciones PLD]` · `[LFPDPPP: datos biométricos]`

#### 1.2.2.1 Proceso de Validación Documental `[TBD]`
#### 1.2.2.2 Proceso de Verificación RENAPO `[TBD]`

### 1.2.3 Lista Negra y Restricciones
> Capacidad de verificar al cliente contra listas de personas inhabilitadas antes de abrir la relación.
> `[DB: D15 bdilide]` · `[CNBV: PLD]`

#### 1.2.3.1 Proceso de Consulta LIDE `[TBD]`

---

## 1.3 Autenticación e Identidad Digital
> Capacidad de verificar la identidad del cliente en cada sesión de acceso al banco.
> `[ETB: 7.1.2, 7.1.4]` · `[DB: D02 bdinteg]`

### 1.3.1 Autenticación por Canal
> Verificación de credenciales según el canal de acceso (digital, físico, telefónico).

#### 1.3.1.1 Proceso de Login Digital `[TBD]`
#### 1.3.1.2 Proceso de Autenticación en Caja `[TBD]`

### 1.3.2 Gestión de Sesión
> Control del ciclo de vida de la sesión activa del cliente.

#### 1.3.2.1 Proceso de Apertura de Sesión `[TBD]`
#### 1.3.2.2 Proceso de Cierre de Sesión `[TBD]`

---

## 1.4 Mantenimiento y Cancelación de Relación
> Capacidad de gestionar cambios en la relación con el cliente y su eventual cierre.

### 1.4.1 Modificación de Datos de Contacto
### 1.4.2 Cancelación de Relación Bancaria
> `[CNBV: procedimiento de cancelación de cuenta]`

---

# 2. Captación y Saldos
> Gestión de los productos de depósito y saldo del banco — el corazón del modelo de captación de BanCoppel.
> `[ETB: 3.2 Accounts and Deposits Management]` · `[DB: D04 bdicheq, D05 bdisac, D06 bdisolic]`

## 2.1 Cuenta de Ahorro
> Producto de captación básico — cuenta de ahorro con tarjeta de débito asociada.
> `[ETB: 3.2.1, 3.2.2]` · `[DB: D05 bdisac]` · `[CNBV: LRAF]`

### 2.1.1 Apertura de Cuenta de Ahorro
> Capacidad de crear una nueva cuenta de ahorro para un cliente existente o nuevo.
> `[CNBV: LRAF — nivel de cuenta 1, 2 o 3]`

#### 2.1.1.1 Proceso de Apertura de Cuenta `[TBD — relacionar con sp_apertura_cta*]`
##### 2.1.1.1.1 Validar nivel de cuenta LRAF `[TBD]`
##### 2.1.1.1.2 Generar número de cuenta `[TBD]`
##### 2.1.1.1.3 Asociar tarjeta de débito `[TBD]`
##### 2.1.1.1.4 Registrar asiento contable inicial `[TBD → 7.1.1.1]`

### 2.1.2 Consulta de Saldo
> Capacidad de obtener el saldo disponible y contable de una cuenta.
> `[DB: D05 bdisac]`

#### 2.1.2.1 Proceso de Consulta de Saldo `[TBD — sp_consulta*]`
##### 2.1.2.1.1 Consultar saldo disponible `[TBD]`
##### 2.1.2.1.2 Consultar saldo retenido `[TBD]`
##### 2.1.2.1.3 Consultar saldo de corte `[TBD — CWE-390 activo en sp_consultasaldocortemin_mx2]`

### 2.1.3 Registro de Movimientos
> Capacidad de registrar cargos y abonos en la cuenta.

#### 2.1.3.1 Proceso de Cargo en Cuenta `[TBD]`
#### 2.1.3.2 Proceso de Abono en Cuenta `[TBD]`
#### 2.1.3.3 Proceso de Reverso de Operación
> `[REGLA: restricción reverso mismo día — pFecha = cFechaFormat]` · `[VOCAB: reverso_msw]`

### 2.1.4 Estado de Cuenta
> Capacidad de generar el resumen de movimientos de un período.
> `[CNBV: CUB Art. 52]`

### 2.1.5 Cancelación de Cuenta de Ahorro

---

## 2.2 Cuenta de Cheques
> Cuenta de cheques para clientes con necesidades de operación más sofisticadas.
> `[ETB: 3.2.3, 3.2.4]` · `[DB: D04 bdicheq]`

### 2.2.1 Apertura de Cuenta de Cheques
### 2.2.2 Emisión y Gestión de Cheques
### 2.2.3 Consulta y Movimientos
### 2.2.4 Cancelación

---

## 2.3 Saldos y Posición Financiera del Cliente
> Vista consolidada de la posición del cliente en todos sus productos de captación.
> `[ETB: 3.17.2, 3.17.8]` · `[DB: D05 bdisac]`

### 2.3.1 Saldo Consolidado por Cliente
### 2.3.2 Posición de Caja (operativa interna)
> `[ETB: 3.17 Cash Management]` · `[DB: D10 bdisuc, D12 bdicont]`

---

# 3. Crédito al Consumo
> Gestión del ciclo completo del crédito al consumo: desde la originación hasta la recuperación.
> `[ETB: 3.3 Lending Management]` · `[DB: D03 bdicred, D11 bdicobranza, D06 bdisolic]`

## 3.1 Originación de Crédito
> Capacidad de analizar, aprobar y desembolsar un nuevo crédito.
> `[ETB: 3.3.1, 3.3.2, 3.1.4]` · `[DB: D06 bdisolic, D03 bdicred]` · `[CNBV: LACP]`

### 3.1.1 Solicitud de Crédito
#### 3.1.1.1 Proceso de Captura de Solicitud `[TBD]`
#### 3.1.1.2 Proceso de Análisis Crediticio (Buró) `[TBD]`

### 3.1.2 Autorización de Crédito
#### 3.1.2.1 Proceso de Aprobación / Rechazo `[TBD]`
#### 3.1.2.2 Proceso de Parametrización (monto, plazo, tasa) `[TBD]`

### 3.1.3 Disposición del Crédito
#### 3.1.3.1 Proceso de Desembolso `[TBD]`
#### 3.1.3.2 Proceso de Registro Contable de Originación `[TBD → 7.1.1.1]`

---

## 3.2 Administración de Cartera
> Gestión del crédito a lo largo de su vida: pagos, cargos de interés, vencimientos.
> `[ETB: 3.3.3, 3.3.4]` · `[DB: D03 bdicred]`

### 3.2.1 Cálculo de Intereses y Comisiones
> `[ETB: 3.15 Interest and Fees]`

#### 3.2.1.1 Proceso de Devengamiento de Intereses `[TBD]`
#### 3.2.1.2 Proceso de Cálculo de Comisión por Apertura `[TBD]`
#### 3.2.1.3 Proceso de Cálculo de Interés Moratorio `[TBD]`

### 3.2.2 Ciclo de Corte
> `[VOCAB: corte]` · `[CNBV: LACP — estado de cuenta mensual]`

#### 3.2.2.1 Proceso de Corte Mensual de Crédito `[TBD]`
#### 3.2.2.2 Proceso de Generación de Estado de Cuenta `[TBD]`

### 3.2.3 Registro de Pagos
#### 3.2.3.1 Proceso de Pago de Crédito en Caja `[TBD]`
#### 3.2.3.2 Proceso de Pago por Transferencia `[TBD]`
#### 3.2.3.3 Proceso de Domiciliación de Pago `[TBD]`

---

## 3.3 Cobranza y Recuperación
> Gestión de la cartera en mora: desde la mora temprana hasta el castigo y recuperación.
> `[ETB: 3.3.4, 5.9]` · `[DB: D11 bdicobranza]`

### 3.3.1 Gestión de Mora Temprana (0–30 días)
### 3.3.2 Gestión de Mora Tardía (30–180 días)
### 3.3.3 Castigo de Cartera
> `[CNBV: metodología de reservas crediticias]`

### 3.3.4 Recuperación Post-Castigo
### 3.3.5 Reestructuras y Quitas

---

# 4. Tarjetas BanCoppel
> Gestión del producto de tarjeta — tanto el plástico como la línea de crédito o débito asociada.
> `[ETB: 3.5 Cards Management, 3.15, 3.16]` · `[DB: D16 intercard, D04 bdicheq]` · `[PCI-DSS]`

## 4.1 Gestión del Plástico
> Ciclo de vida físico de la tarjeta (emisión, activación, bloqueo, reposición).
> `[ETB: 3.5.1]` · `[DB: D16 intercard]`

### 4.1.1 Emisión de Tarjeta
> `[PCI-DSS: Req. 3 — protección de datos de tarjeta]` · `[VOCAB: PAN]`

#### 4.1.1.1 Proceso de Generación de PAN `[TBD]`
#### 4.1.1.2 Proceso de Personalización y Envío `[TBD]`

### 4.1.2 Activación de Tarjeta
#### 4.1.2.1 Proceso de Activación en Canal Digital `[TBD]`
#### 4.1.2.2 Proceso de Activación en Caja `[TBD]`

### 4.1.3 Bloqueo y Desbloqueo
#### 4.1.3.1 Proceso de Bloqueo por Reporte de Robo `[TBD]`
#### 4.1.3.2 Proceso de Bloqueo Temporal `[TBD]`

### 4.1.4 Reposición de Tarjeta

---

## 4.2 Operación de Tarjeta
> Autorización y registro de transacciones de compra, retiro y pago.
> `[ETB: 3.4.3]` · `[DB: D16 intercard, D04 bdicheq]`

### 4.2.1 Autorización de Compra
> `[VOCAB: sp_consultaregtarjeta — patrón gating, 97.29% error esperado]`

#### 4.2.1.1 Proceso de Autorización en POS `[TBD]`
#### 4.2.1.2 Proceso de Autorización en E-commerce `[TBD]`

### 4.2.2 Control de Límites
> `[ETB: 3.16 Limits Management]`

#### 4.2.2.1 Proceso de Validación de Límite de Crédito `[TBD]`
#### 4.2.2.2 Proceso de Actualización de Límite `[TBD]`

---

# 5. Pagos y Transferencias
> Ejecución de pagos entre cuentas dentro del banco y hacia el sistema financiero.
> `[ETB: 3.4 Payments]` · `[DB: D08 bdispei, D13 bditef, D04 bdicheq]`

## 5.1 Pagos Interbancarios SPEI
> Sistema de Pagos Electrónicos Interbancarios — el sistema de pagos de Banxico.
> `[ETB: 3.4.1 a 3.4.8]` · `[DB: D08 bdispei]` · `[BANXICO: SPEI]`

### 5.1.1 Transferencia SPEI Saliente
> `[BANXICO: ventana 7:00–17:30 · SLA < 20 seg]`

#### 5.1.1.1 Proceso de Envío de Transferencia SPEI `[TBD]`
##### 5.1.1.1.1 Validar cuenta origen `[TBD → 2.1.2.1]`
##### 5.1.1.1.2 Validar cuenta destino (CLABE) `[TBD]`
##### 5.1.1.1.3 Debitar cuenta origen `[TBD → 2.1.3.1]`
##### 5.1.1.1.4 Enviar mensaje SPEI a Banxico `[TBD]`
##### 5.1.1.1.5 Confirmar liquidación `[TBD]`
##### 5.1.1.1.6 Registrar asiento contable `[TBD → 7.1.1.1]`

### 5.1.2 Transferencia SPEI Entrante
#### 5.1.2.1 Proceso de Recepción de Transferencia SPEI `[TBD]`

### 5.1.3 CoDi — Cobro Digital
> `[BANXICO: CoDi — QR y NFC]`

#### 5.1.3.1 Proceso de Generación de QR CoDi `[TBD]`
#### 5.1.3.2 Proceso de Cobro CoDi `[TBD]`

---

## 5.2 Transferencias Electrónicas de Fondos (TEF)
> Transferencias internas y entre cuentas propias del cliente.
> `[ETB: 3.4.1, 3.4.4]` · `[DB: D13 bditef]`

### 5.2.1 Transferencia entre Cuentas Propias
### 5.2.2 Transferencia a Terceros BanCoppel

---

## 5.3 Pagos de Servicios
> Pagos de recibos de servicios públicos y privados mediante convenios.
> `[ETB: 3.4.7]` · `[DB: D08 bdispei]` · `[VOCAB: convenio, GDF]`

### 5.3.1 Pago de Servicio por Convenio
#### 5.3.1.1 Proceso de Consulta de Adeudo `[TBD]`
#### 5.3.1.2 Proceso de Pago de Servicio `[TBD]`
#### 5.3.1.3 Proceso de Generación de Comprobante `[TBD]`

### 5.3.2 Gestión de Convenios
#### 5.3.2.1 Proceso de Alta de Convenio `[TBD]`

---

## 5.4 Remesas Internacionales
> Recepción y envío de remesas internacionales mediante proveedores externos.
> `[DB: D05 bdisac (remisac)]` · `[VOCAB: APPRIZA, CFPA]` · `[BANXICO + FinCEN]`

### 5.4.1 Recepción de Remesa
#### 5.4.1.1 Proceso de Consulta de Remesa Disponible `[TBD — APPRIZA, error 1100/9999 esperados]`
#### 5.4.1.2 Proceso de Pago de Remesa al Beneficiario `[TBD]`

### 5.4.2 Envío de Remesa
#### 5.4.2.1 Proceso de Envío Internacional `[TBD]`

---

# 6. Canales y Distribución
> Gestión de los puntos de contacto del banco con sus clientes y la red de distribución.
> `[ETB: 1.1, 1.2, 7.3]`

## 6.1 Canal Digital
> Aplicación web y móvil de BanCoppel para clientes.
> `[ETB: 1.1 Digital Interaction Channel]` · `[DB: D01 bdicnweb]`

### 6.1.1 Banca en Línea (Web)
> `[ETB: 1.1.1]`
### 6.1.2 Banca Móvil
> `[ETB: 1.1.2]`
### 6.1.3 Atención Telefónica / IVR
> `[ETB: 1.1.5]`

---

## 6.2 Canal Físico
> Red de sucursales BanCoppel y cajeros automáticos.
> `[ETB: 1.2]` · `[DB: D10 bdisuc]`

### 6.2.1 Sucursales BanCoppel
> `[ETB: 1.2.1]`
### 6.2.2 Cajeros Automáticos (ATM)
> `[ETB: 1.2.2]`

---

## 6.3 Corresponsalía — Tiendas Coppel (BTS)
> Red de tiendas Coppel operando como agentes corresponsales del banco.
> `[ETB: 1.2.2]` · `[DB: D10 bdisuc]` · `[CNBV: CUB Art. 310-315]` · `[VOCAB: BTS, Banca de Tienda System]`

### 6.3.1 Operaciones de Caja en Tienda
> `[CNBV: corresponsalía bancaria — autorización previa]`

#### 6.3.1.1 Proceso de Depósito en Efectivo en Tienda `[TBD]`
#### 6.3.1.2 Proceso de Retiro en Efectivo en Tienda `[TBD]`
#### 6.3.1.3 Proceso de Pago de Crédito en Tienda `[TBD]`
#### 6.3.1.4 Proceso de Consulta de Saldo en Tienda `[TBD]`

### 6.3.2 Gestión de Caja BTS
#### 6.3.2.1 Proceso de Apertura de Caja `[TBD]`
#### 6.3.2.2 Proceso de Cierre de Caja `[TBD]`
#### 6.3.2.3 Proceso de Cuadre de Caja `[TBD → sp_consdatosticketbts]`

---

## 6.4 Banca Electrónica Institucional (BEI)
> Canal de banca en línea para clientes empresariales.
> `[ETB: 7.1.2, 7.1.3, 7.1.4]` · `[DB: D14 bdibei]`

### 6.4.1 Acceso Empresarial
### 6.4.2 Pagos y Transferencias Masivas

---

# 7. Finanzas y Cumplimiento Regulatorio
> Operaciones de back-office regulatorio: contabilidad, prevención de lavado de dinero y reportes a CNBV.
> `[ETB: 5.4, 5.8, 5.9, 5.10]`

## 7.1 Contabilidad y Libro Mayor
> Registro contable de todas las operaciones del banco conforme al CUB CNBV.
> `[ETB: 5.4 Finance Management]` · `[DB: D12 bdicont]` · `[CNBV: CUB Anexo 33-36]`

### 7.1.1 Libro Mayor (GL)
> `[VOCAB: folio_contable]` · `[CNBV: CUB Art. 78 — 5 años]`

#### 7.1.1.1 Proceso de Registro de Asiento Contable `[TBD — sp_registra_movimiento_gl]`
##### 7.1.1.1.1 Validar cuenta del catálogo mínimo CNBV `[TBD → CNBV Anexo 33]`
##### 7.1.1.1.2 Validar que debe = haber `[TBD]`
##### 7.1.1.1.3 Registrar en gl_movimientos `[TBD]`

#### 7.1.1.2 Proceso de Consulta de Saldo de Cuenta GL `[TBD]`

### 7.1.2 Cierre Contable Diario
> `[VOCAB: corte, cierre]`

#### 7.1.2.1 Proceso de Conciliación Operativa Diaria `[TBD]`
##### 7.1.2.1.1 Cruzar D05 vs GL `[TBD]`
##### 7.1.2.1.2 Cruzar D08 vs GL `[TBD]`
##### 7.1.2.1.3 Cruzar D10 vs GL `[TBD]`
##### 7.1.2.1.4 Verificar balance de comprobación `[TBD]`
##### 7.1.2.1.5 Cerrar partidas por aclarar `[TBD]`

#### 7.1.2.2 Proceso de Snapshot de Cierre `[TBD]`

### 7.1.3 Reportes Serie R
> `[CNBV: Serie R — entrega primeros 10 días hábiles del mes]`

#### 7.1.3.1 Proceso de Generación R01-A (Balance General) `[TBD]`
#### 7.1.3.2 Proceso de Generación R04-A (Cartera) `[TBD]`
#### 7.1.3.3 Proceso de Generación R12 (Captación) `[TBD]`

---

## 7.2 Prevención de Lavado de Dinero (PLD/AML)
> Monitoreo y reporte de operaciones inusuales y relevantes.
> `[ETB: 5.8 Fraud and AML Management]` · `[DB: D15 bdilide]` · `[CNBV: CUP Art. 5-CUB]`

### 7.2.1 Monitoreo de Transacciones
#### 7.2.1.1 Proceso de Detección de Operación Inusual `[TBD]`
#### 7.2.1.2 Proceso de Generación de Alerta AML `[TBD]`

### 7.2.2 Lista de Personas Inhabilitadas (LIDE)
#### 7.2.2.1 Proceso de Consulta LIDE en Onboarding `[TBD → 1.2.3.1]`
#### 7.2.2.2 Proceso de Actualización de LIDE `[TBD]`

### 7.2.3 Reportes PLD
#### 7.2.3.1 Proceso de Reporte de Operación Relevante (ROR) `[TBD]`
#### 7.2.3.2 Proceso de Reporte de Operación Inusual (ROI) `[TBD]`

---

## 7.3 Cumplimiento Regulatorio
> Gestión del cumplimiento con todas las obligaciones regulatorias del banco.
> `[ETB: 5.10 Compliance Management]` · `[DB: D15 bdilide, D02 bdinteg]`

### 7.3.1 Obligaciones CNBV
#### 7.3.1.1 Proceso de Reportes Regulatorios CNBV `[TBD → 7.1.3]`
#### 7.3.1.2 Proceso de Atención de Requerimientos CNBV `[TBD]`

### 7.3.2 Obligaciones Banxico
#### 7.3.2.1 Proceso de Encaje Legal `[TBD]`
#### 7.3.2.2 Proceso de Reporte de Incidentes SPEI `[TBD]`

### 7.3.3 Obligaciones CONDUSEF
> `[VOCAB: SAC, remisac]`
#### 7.3.3.1 Proceso de Registro de Reclamación RECA `[TBD → 7.4.1.1]`

---

## 7.4 Aclaraciones y Disputas
> Gestión de reclamaciones del cliente sobre operaciones incorrectas.
> `[ETB: 3.18 Dispute Management, 4.5]` · `[DB: D07 bdiaclaracion]` · `[CONDUSEF: RECA]`

### 7.4.1 Recepción de Aclaración
#### 7.4.1.1 Proceso de Alta de Aclaración `[TBD]`
#### 7.4.1.2 Proceso de Clasificación de Aclaración `[TBD]`

### 7.4.2 Resolución de Aclaración
#### 7.4.2.1 Proceso de Investigación `[TBD]`
#### 7.4.2.2 Proceso de Resolución y Notificación al Cliente `[TBD]`
#### 7.4.2.3 Proceso de Escalación a CONDUSEF `[TBD]`

---

## Índice de Dominios

| Código | Dominio | Dominios Informix | ETB L2 Principal |
|--------|---------|-------------------|-----------------|
| **1** | Cliente y Onboarding | D02, D06, D14 | 7.1 Customer Management |
| **2** | Captación y Saldos | D04, D05 | 3.2 Accounts and Deposits |
| **3** | Crédito al Consumo | D03, D11 | 3.3 Lending Management |
| **4** | Tarjetas BanCoppel | D16, D04 | 3.5 Cards Management |
| **5** | Pagos y Transferencias | D08, D13 | 3.4 Payments |
| **6** | Canales y Distribución | D01, D10, D14 | 1.1, 1.2 Channel Mgmt |
| **7** | Finanzas y Cumplimiento | D12, D15, D02 | 5.4, 5.8, 5.10 |

---

## Estado de Cobertura por Nivel

| Nivel | Total definido | Pendiente (TBD) | Fuente de población |
|-------|---------------|-----------------|---------------------|
| L1 Dominio | 7 | 0 | SME Industry Banking |
| L2 Subdominio | 24 | 0 | SME Industry Banking |
| L3 Capacidad | 67 | 0 | SME Industry Banking + ETB |
| L4 Proceso | ~85 definidos | **mayoría TBD** | BCOPBrain — journeys + call graph |
| L5 Tarea | ~200 estimados | **todos TBD** | BCOPBrain — SPs + reglas SBVR |

**Próximo paso**: poblar L4-L5 por dominio prioritario usando BCOPBrain, dt-journeys y dt-reglas como fuentes.

---

*v0.2.0 · 2026-08-03 · dt-modelo-dominio · Autoridad: SME Industry Banking · Informix SPE-AM-001 — Corrección conteos: 24 subdominios · 67 caps; ref 7.3.3.1 → 7.4.1.1*