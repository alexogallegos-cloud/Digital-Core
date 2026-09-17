# Catálogo de Campos — Códigos de Operación CAN (C-50 a C-58)
> **Fuente:** Documento de Entendimiento CAN v4.2 · 25/08/2026 · Cecoban
> **Versión:** 1.0.0 · 2026-09-17 · dt-de-can
> **Tipo/Req:** N=Numérico, A=Alfanumérico · M=Mandatorio, O=Opcional, C=Condicional

---

## C-50 — Solicitud de información del nominado y disponibilidad de pago

**Enviado por:** Banco Otorgante (BanCoppel como Acreedora)
**Recibido por:** Cecoban → retransmite al Banco Ordenante
**SLA:** No aplica (originado por el banco)

| # | Tipo | Req | Campo | Descripción | Reglas de validación |
|---|------|-----|-------|-------------|---------------------|
| 01 | N | M | Código de Operación | Valor fijo: 50 | Catálogo Códigos de Operación |
| 02 | N | M | Banco Otorgante | Código de banco Cecoban (40137 = BanCoppel) | Catálogo Bancos; 5 dígitos |
| 03 | N | M | Banco Ordenante | Código del banco donde está la cuenta del nominado | Catálogo Bancos; 5 dígitos |
| 04 | A | M | Cuenta CLABE del Banco Ordenante | Cuenta de nómina del nominado | `^\d{18}$`; dígitos 1-3 deben coincidir con código de banco |
| 05 | A | M | CURP del nominado | CURP del trabajador | 18 caracteres alfanumérico |
| 06 | A | M | RFC del nominado | RFC del trabajador | 13 chars (PF) o 12 chars (PM) |
| 07 | A | M | Nombre del banco otorgante | Nombre de BanCoppel | Texto libre |
| 08 | A | M | Folio de la solicitud | Folio único generado por Banco Otorgante | Identificador interno único por banco |
| 09 | A | M | Fecha y hora de registro | Timestamp de creación | ISO 8601 `AAAA-MM-DDThh:mm:ss` (CDMX, sin offset) |
| 10 | A | M | Cuenta CLABE del crédito a liquidar | CLABE del crédito existente (si aplica liquidación) | `^\d{18}$`; "00" si no aplica |
| 11 | A | M | Liquidación CAN o Mis to Mis | SI = solicita liquidación del crédito indicado en campo 10 | "SI" o "NO" |
| 12 | A | M | Número de crédito | Número interno del crédito en Banco Otorgante | Texto libre; "00" si es crédito nuevo |
| 13 | N | M | Banco Otorgante del crédito a liquidar | Código del banco del crédito a liquidar | Catálogo Bancos; "00000" si no aplica |
| 14 | A | M | Cuenta CLABE del crédito CAN | CLABE del CAN existente a liquidar (si aplica) | `^\d{18}$`; "00" si no aplica |

---

## C-51 — Respuesta a la solicitud de información del nominado

**Enviado por:** Banco Ordenante (BanCoppel como Depositaria)
**Recibido por:** Cecoban → retransmite al Banco Otorgante
**SLA crítico:** 30 segundos máximos desde recepción del C-50

| # | Tipo | Req | Campo | Descripción | Fuente sistema BanCoppel |
|---|------|-----|-------|-------------|--------------------------|
| 01 | N | M | Código de Operación | Valor fijo: 51 | — |
| 02 | N | M | Banco Ordenante | 40137 (BanCoppel) | — |
| 03 | A | M | UUID | UUID asignado por Cecoban en C-50 | **Eco del C-50 — no alterar** |
| 04 | A | M | Folio de la Solicitud | Folio del C-50 original | Eco del C-50 |
| 05 | A | M | Fecha y hora de registro | Timestamp del C-50 original | Eco del C-50 |
| 06 | A | M | Nombre(s) del Nominado | Nombre(s) de pila del trabajador | Cuentahabientes (tabla principal) |
| 07 | A | O | Primer Apellido del Nominado | Apellido paterno | Cuentahabientes |
| 08 | A | O | Segundo Apellido del Nominado | Apellido materno | Cuentahabientes |
| 09 | A | M | CURP del Nominado | CURP validado | Cuentahabientes (campo CURP) |
| 10 | A | O | RFC del Nominado | RFC con homoclave | Cuentahabientes (campo RFC) |
| 11 | A | M | Liquidación CAN o Mis to Mis | Eco del campo 11 del C-50 | Eco del C-50 |
| 12 | N | C | Cuenta CLABE del crédito a liquidar | CLABE del crédito si campo 11 = SI | bdiadminnomina — créditos propios activos |
| 13 | N | M | Cuenta CLABE del Banco Ordenante | Cuenta de nómina actual del nominado | Cuenta ordenante vigente |
| 14 | N | M | Banco Ordenante | 40137 | — |
| 15 | A | C | Liquidación CAN o Mis to Mis (detalle) | Detalle de créditos vigentes que pueden liquidarse | bdiadminnomina — CANs vigentes + Mis to Mis |
| 16 | N | C | Cuenta CLABE del crédito MIS to MIS | CLABE del crédito Mis a Mis a liquidar | bdiadminnomina — créditos mismo banco |
| 17 | N | C | Cuenta CLABE del crédito CAN | CLABE del CAN existente a liquidar | bdiadminnomina — CANs activos |
| 18 | A | O | RFC de la emisora / patrón | RFC del patrón que dispersa la nómina | Tabla de patrones/dispersores de nómina |
| 19 | N | M | Cuenta CLABE del Banco Ordenante | Confirmación de la cuenta ordenante | Confirma campo 13 |
| 20 | A | M | Tipo de crédito MIS to MIS | Todos los créditos vigentes del nominado en BanCoppel con subcampos: tipo, CLABE, monto, banco otorgante | bdiadminnomina — cartera completa del nominado |
| 21 | N | M | Banco Otorgante del Crédito | Eco del banco otorgante del C-50 | Eco del C-50 |
| 22 | N | M | Periodicidad de la dispersión de nómina | Catálogo Periodicidad (01-05) | Configuración de dispersión por cuenta |
| 23 | N | M | Frecuencia de pago de nómina | Catálogo Frecuencia (01-05) + subcampos días de pago del mes | Calendario de dispersión del patrón |
| **24** | — | M | **Ingreso del cliente** | **6 meses de historia de depósitos de nómina** | **Motor de nómina — historial de abonos** |
| 25 | N | M | Información del Nominado | Catálogo Información del Nominado (01-12) | Resultado de validación interna |
| 26 | A | M | Fecha y hora de respuesta | Timestamp de generación del C-51 | — |

**Detalle campo 24 — Ingreso del cliente (subcampos anidados):**

```json
"campo_24": [
  {
    "subcampo_1": "09",              // Mes (catálogo 01-12)
    "subcampo_2": "15000.00",        // Total de ingresos del mes
    "abonos": [
      {
        "sub_subc_1": "2026-09-01",  // Fecha del abono
        "sub_subc_2": "7500.00",     // Monto del abono
        "sub_subc_3": "DISPERSIÓN NÓMINA QUINCENA 1"  // Descripción (opcional)
      },
      {
        "sub_subc_1": "2026-09-15",
        "sub_subc_2": "7500.00",
        "sub_subc_3": "DISPERSIÓN NÓMINA QUINCENA 2"
      }
    ]
  }
  // ... (total 6 meses, del más reciente hacia atrás)
]
```

**Reglas de validación campo 24:**
- Deben incluirse exactamente los últimos 6 meses calendario (incluyendo meses con cero ingresos)
- La suma de sub-subcampos 2 de cada mes debe ser igual al subcampo 2 del mismo mes
- Mínimo 3 meses con ingresos reales; de lo contrario enviar Info del Nominado = 10
- Causa de rechazo 30: total de ingresos del mes incorrecto

---

## C-52 — Otorgamiento del Crédito CAN

**Enviado por:** Banco Otorgante (BanCoppel como Acreedora)
**SLA:** 48 horas desde recepción del C-51

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 52 |
| 02 | N | M | Banco Otorgante | 40137 |
| 03 | A | M | UUID | UUID del C-50 original (Cecoban-asignado) — PRESERVAR |
| 04 | A | M | Folio de la Solicitud | Folio del C-50 original |
| 05 | A | M | Fecha y hora de registro | Timestamp del C-50 |
| 06 | A | M | CURP del Nominado | CURP del trabajador (del C-51) |
| 07 | A | O | RFC del Nominado | RFC (del C-51) |
| 08 | N | M | Banco Ordenante | Banco donde está la cuenta de nómina |
| 09 | N | M | Estatus del Crédito | 01 = Activo (apertura de nuevo CAN) |
| 10 | A | M | Número de crédito | ID único del crédito CAN en sistema Acreedora |
| 11 | N | M | Tipo de Crédito | Catálogo Tipo de Crédito (01-06) |
| 12 | N | M | Monto otorgado | Monto total del crédito en MXN | 
| 13 | N | M | Monto de pago periódico | Monto de cada cargo de nómina |
| 14 | N | M | Periodicidad de cobro | Catálogo Periodicidad (01-05) |
| 15 | A | M | Fecha de asignación del crédito | AAAA-MM-DD cuando se aprobó |
| 16 | A | M | Fecha de primer cargo | AAAA-MM-DD del primer descuento de nómina |
| 17 | A | M | Fecha de último cargo | AAAA-MM-DD del último descuento esperado |
| 18 | N | M | Número de pagos | Plazo en número de quincenas/meses/etc. |
| 19 | N | M | Tasa de interés anual | Tasa efectiva anual del crédito (%) |
| 20 | N | M | Cuenta CLABE del crédito | CLABE del crédito en Banco Otorgante (BanCoppel) |
| 21 | N | M | Cuenta CLABE en Banco Ordenante | Cuenta de nómina donde se aplica el descuento |
| 22+ | — | O | Campos adicionales | Según versión vigente del catálogo Cecoban |

> **Post-C-52:** Cecoban genera automáticamente el C-53 (Prelación) y lo envía al Banco Ordenante.

---

## C-53 — Envío de Prelación

**Generado y enviado por:** Cecoban (automático)
**Recibido por:** Banco Ordenante (BanCoppel como Depositaria)

> **REGLA CRÍTICA: Los bancos NUNCA calculan la prelación. Cecoban es el único responsable de calcular y transmitir el orden de prelación.** BanCoppel debe aplicar el orden que Cecoban establezca.

**Triggers que hacen que Cecoban genere C-53:**
- Recepción de C-52 (nuevo otorgamiento)
- Recepción de C-55 con estatus 02 o 03 (baja de crédito)
- Recepción de C-56 (cambio de banco ordenante)
- Recepción de C-58 (CAN propio)

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 53 |
| 02 | N | M | Banco Ordenante | Banco que debe aplicar la prelación |
| 03 | A | M | CURP del Nominado | Identifica al trabajador |
| 04 | A | O | RFC del Nominado | Complemento de identidad |
| 05 | — | M | Lista de créditos con prelación | Orden completo de descuentos de nómina para este nominado |

**Subcampos de campo 05 (por cada crédito en prelación):**

| Sub | Descripción |
|-----|-------------|
| 5.1 | Número de prelación (posición en el orden: 1, 2, 3...) |
| 5.2 | Banco Otorgante del crédito |
| 5.3 | Número de crédito en Banco Otorgante |
| 5.4 | Tipo de crédito (catálogo) |
| 5.5 | Monto del pago periódico |
| 5.6 | Cuenta CLABE del crédito |
| 5.7 | Cuenta CLABE de la cuenta ordenante |

---

## C-54 — Actualización de cuenta CLABE del nominado en Banco Ordenante

**Enviado por:** Banco Ordenante (BanCoppel como Depositaria)
**Trigger:** Eventos en la Cuenta Ordenante que afectan la domiciliación

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 54 |
| 02 | N | M | Banco Ordenante | 40137 |
| 03 | A | M | CURP del Nominado | Trabajador afectado |
| 04 | A | O | RFC del Nominado | Complemento |
| 05 | N | M | Estatus | Ver catálogo de estatus |
| 06 | A | M | Fecha y hora de registro | ISO 8601 |
| 07 | N | C | Nueva Cuenta CLABE | Nueva CLABE si estatus = 10 (cambio de cuenta) | 
| 08 | A | O | Descripción | Descripción libre del motivo |

**Estatus válidos para C-54:**
| Estatus | Significado | Cuándo enviarlo |
|---------|-------------|-----------------|
| 04 | Cancelación domiciliación a petición del cliente | El nominado pide cancelar todos sus descuentos CAN |
| 05 | Sin depósitos de nómina ≥ 2 meses | La cuenta dejó de recibir nómina por 2 meses consecutivos |
| 07 | Cancelación de la cuenta ordenante | La cuenta fue cerrada |
| 08 | Cuenta bloqueada | La cuenta fue bloqueada |
| 10 | Cambio de cuenta ordenante | El nominado cambió su cuenta de nómina (nueva CLABE en campo 07) |
| 11 | Cuenta reactivada | La cuenta se desbloqueó o se reactivó la domiciliación |

---

## C-55 — Actualización datos del crédito CAN en Banco Otorgante

**Enviado por:** Banco Otorgante (BanCoppel como Acreedora)
**Trigger:** Cambios en el crédito CAN (baja, cancelación, actualización de condiciones)

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 55 |
| 02 | N | M | Banco Otorgante | 40137 |
| 03 | A | M | UUID | UUID original del ciclo de vida del CAN |
| 04 | A | M | CURP del Nominado | Trabajador del crédito |
| 05 | A | O | RFC del Nominado | Complemento |
| 06 | N | M | Banco Ordenante | Banco donde se aplica el descuento |
| 07 | N | M | Estatus | Ver catálogo |
| 08 | A | M | Número de crédito | ID del CAN en Banco Otorgante |
| 09 | N | M | Tipo de Crédito | Catálogo Tipo de Crédito |
| 10 | N | C | Monto de pago periódico nuevo | Si cambia el monto (estatus 06) |
| 11 | N | C | Periodicidad nueva | Si cambia la periodicidad (estatus 06) |
| 12 | A | C | Fecha de último cargo nueva | Si cambia el plazo (estatus 06) |
| 13 | N | M | Cuenta CLABE del crédito | CLABE del crédito en BanCoppel |
| 14 | N | M | Cuenta CLABE en Banco Ordenante | Cuenta de nómina donde se descuenta |
| 15 | A | M | Fecha y hora de registro | ISO 8601 |
| 16-19 | — | O | Campos adicionales condiciones | Tasa, fecha primer cargo, número de pagos, monto total |

**Estatus válidos para C-55:**
| Estatus | Significado |
|---------|-------------|
| 02 | Baja por liquidación del crédito (terminó de pagar) |
| 03 | Baja por sustitución (se reemplaza por otro crédito) |
| 04 | Cancelación de domiciliación a petición del cliente |
| 06 | CAN vigente — actualización de condiciones (nuevo monto, plazo, tasa) |

> **Post-C-55 con estatus 02 ó 03:** Cecoban actualiza prelación y envía nuevo C-53.

---

## C-56 — Cambio de Banco Ordenante del nominado

**Enviado por:** Nuevo Banco Ordenante (BanCoppel si el nominado migra su nómina a BanCoppel)
**Trigger:** El nominado cambia el banco donde recibe su nómina

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 56 |
| 02 | N | M | Nuevo Banco Ordenante | 40137 (BanCoppel) |
| 03 | A | M | CURP del Nominado | Trabajador que cambia de banco |
| 04 | A | O | RFC del Nominado | Complemento |
| 05 | N | M | Anterior Banco Ordenante | Código del banco que abandonó el nominado |
| 06 | N | M | Anterior Cuenta CLABE | CLABE de la cuenta de nómina anterior |
| 07 | N | M | Nueva Cuenta CLABE | CLABE de la nueva cuenta en BanCoppel |
| 08 | A | M | Fecha de alta en nuevo banco | AAAA-MM-DD cuando BanCoppel registró la dispersión |
| 09 | A | M | Fecha y hora de registro | ISO 8601 |
| 10 | A | O | RFC de la emisora | RFC del patrón |
| 11 | N | M | Periodicidad | Catálogo Periodicidad |
| 12 | A | M | Tipo de crédito MIS to MIS | Créditos Mis a Mis existentes del nominado en BanCoppel |
| 13 | N | M | Banco Otorgante | Del crédito Mis to Mis (si aplica) |
| 14 | N | M | Número de pagos restantes | Del crédito Mis to Mis (si aplica) |
| 15 | N | M | Monto de pago periódico | Del crédito Mis to Mis (si aplica) |

> **Post-C-56:** Cecoban genera C-57 (entrega información al Nuevo Banco Ordenante) + C-53 (nueva prelación).

---

## C-57 — Entrega de información de créditos por cambio de Banco Ordenante

**Generado y enviado por:** Cecoban (automático)
**Recibido por:** Nuevo Banco Ordenante AND todos los Bancos Otorgantes con CANs activos del nominado

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 57 |
| 02 | N | M | Nuevo Banco Ordenante | Código del banco que recibe al nominado |
| 03 | A | M | CURP del Nominado | |
| 04 | A | O | RFC del Nominado | |
| 05 | N | M | Nombre del Nominado | Nombre completo |
| 06-08 | A | O | Apellidos | Paterno, materno |
| 09 | N | M | Anterior Banco Ordenante | |
| 10 | N | M | Anterior Cuenta CLABE | |
| 11 | N | M | Nueva Cuenta CLABE | En el Nuevo Banco Ordenante |
| 12 | A | M | Fecha de alta | AAAA-MM-DD |
| 13 | A | M | RFC de la emisora | |
| 14 | N | M | Periodicidad | |
| 15 | — | M | Créditos CAN vigentes | Lista de todos los CANs activos del nominado (subcampos) |
| 16 | — | M | Créditos Mis a Mis | Lista de créditos Mis to Mis (subcampos) |
| 17-24 | — | M | Datos por crédito | Banco Otorgante, número crédito, tipo, monto, periodicidad, CLABE, fechas |

---

## C-58 — Otorgamiento y Mantenimiento del crédito CAN propio

**Enviado por:** Banco Otorgante/Ordenante (BanCoppel — cuando es ambos roles simultáneamente)
**Contexto:** Solo aplica cuando BanCoppel otorga un CAN a un nominado que TAMBIÉN tiene su cuenta de nómina en BanCoppel

> **C-58 NO se transmite a otros bancos.** Es solo un registro en la base de datos de Cecoban. La prelación sí se actualiza (Cecoban genera C-53).

| # | Tipo | Req | Campo | Descripción |
|---|------|-----|-------|-------------|
| 01 | N | M | Código de Operación | 58 |
| 02 | N | M | Banco Otorgante/Ordenante | 40137 |
| 03 | A | M | CURP del Nominado | |
| 04 | A | O | RFC del Nominado | |
| 05 | N | M | Estatus | 01=Activo, 02=Baja liquidación, 03=Baja sustitución, 04=Cancelación domiciliación, 06=Actualización |
| 06 | A | M | Número de crédito | ID del CAN propio en BanCoppel |
| 07 | N | M | Tipo de Crédito | Catálogo (01-06) |
| 08 | N | M | Monto otorgado | MXN con 2 decimales |
| 09 | N | M | Monto de pago periódico | |
| 10 | N | M | Periodicidad | Catálogo Periodicidad |
| 11 | A | M | Fecha de asignación | AAAA-MM-DD |
| 12 | A | M | Fecha de primer cargo | AAAA-MM-DD |
| 13 | A | M | Fecha de último cargo | AAAA-MM-DD |
| 14 | N | M | Número de pagos | Plazo total |
| 15 | N | M | Tasa de interés anual | % efectivo anual |
| 16 | N | M | Cuenta CLABE del crédito | CLABE del crédito en BanCoppel |
| 17 | N | M | Cuenta CLABE ordenante | Cuenta de nómina del nominado en BanCoppel |

---

## Resumen de campos críticos por sistema BanCoppel

| Sistema | Campos requeridos | C-codes que los usan |
|---------|-------------------|---------------------|
| **Cuentahabientes** | Nombre, apellidos, CURP, RFC | C-51 campos 06-10 |
| **bdiadminnomina — nómina** | Historial 6 meses: fecha, monto, descripción por abono | C-51 campo 24 |
| **bdiadminnomina — créditos** | CANs vigentes (CLABE, tipo, monto, periodicidad) | C-51 campos 15-17, 20 |
| **bdiadminnomina — Mis to Mis** | Créditos dentro de BanCoppel del nominado | C-51 campo 16, C-56 campos 12-15 |
| **Dispersión nómina** | Periodicidad, frecuencia, días de pago, RFC patrón | C-51 campos 18, 22, 23 |
| **Eventos cuenta** | Bloqueos, cierres, cancelaciones, cambios de cuenta | C-54 |
| **Cartera CAN** | Número crédito, monto, fechas, estado | C-52, C-55, C-58 |
| **Prelación (entrada)** | Orden de prelación por nominado | C-53 (se recibe, no se calcula) |

---

*v1.0.0 · 2026-09-17 · DE CAN v4.2 (Secciones 3-5, pp. 6-86) · Cecoban, S.A. de C.V. · dt-de-can*
