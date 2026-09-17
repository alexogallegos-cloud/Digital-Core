# Spec Técnica — Mecanismo Art. 63 Bis 3 (Plataforma Cecoban CAN)
> **Fuente:** Documento de Entendimiento CAN v4.2 · 25/08/2026 · GT de CAN - ABM · Cecoban
> **Versión:** 1.0.0 · 2026-09-17 · dt-de-can

---

## Hallazgo Crítico para el Change Bank

> **BanCoppel NO construye el Mecanismo Art. 63 Bis 3.**
> 
> Cecoban, S.A. de C.V. opera una plataforma centralizada de intercambio CAN, igual que opera la Cámara de Compensación para SPEI. BanCoppel debe **integrarse** a esa plataforma mediante APIs HTTPS/JSON.
>
> BanCoppel ya tiene un enlace de comunicación con Cecoban (Cámara de Compensación). El alcance técnico es: **¿usar el enlace existente o contratar uno nuevo?**

---

## Identificación de BanCoppel en el Sistema

| Campo | Valor |
|-------|-------|
| Nombre | BanCoppel, S.A. |
| Número de institución Cecoban | **40137** |
| Roles en el mecanismo | Banco Otorgante (Acreedora) + Banco Ordenante (Depositaria) |

---

## Arquitectura del Mecanismo

```
BanCoppel (Acreedora)                    Cecoban                    BanCoppel (Depositaria)
        │                                    │                               │
        │── C-50 (solicita info nominado) ──→│                               │
        │                                    │── C-50 (retransmite) ────────→│
        │                                    │←── C-51 (responde 30seg) ────│
        │←── C-51 (retransmite, 30seg) ──────│                               │
        │                                    │                               │
        │── C-52 (otorga crédito, 48h) ─────→│                               │
        │                                    │── C-53 (prelación) ──────────→│
```

**Protocolo:**
- Transport: HTTPS (TLS 1.3)
- Formato: JSON (REST API, método POST)
- Autenticación: Certificados digitales emitidos por Cecoban
- Enlace: Punto a punto Banco ↔ Cecoban (usar Cámara de Compensación existente o enlace nuevo)

**Ambientes requeridos:** Desarrollo · QA · UAT · Producción · DRP (contingencia)

---

## Tiempos de Servicio (SLAs críticos)

| Operación | Responsable | SLA |
|-----------|-------------|-----|
| Cecoban procesa C-50 y entrega al Banco Ordenante | Cecoban | 30 segundos máximo |
| Banco Ordenante responde C-51 | BanCoppel (Depositaria) | **30 segundos máximo** desde recepción del C-50 |
| Cecoban retransmite C-51 al Banco Otorgante | Cecoban | 30 segundos máximo |
| Banco Otorgante envía C-52 (si decide otorgar) | BanCoppel (Acreedora) | 48 horas desde recepción del C-51 |
| Cecoban procesa cualquier otro código | Cecoban | 30 segundos máximo |

> **SLA crítico para bdiadminnomina:** El C-51 debe responderse en **30 segundos**. Esto es un query en tiempo real contra los registros de la Cuenta Ordenante: 6 meses de ingresos por fecha/monto/concepto. Este es el principal riesgo de performance del proyecto.

---

## Los 9 Códigos de Operación

| Código | Nombre | Iniciado por | BanCoppel rol activo | OBL relacionada |
|--------|--------|-------------|---------------------|-----------------|
| **C-50** | Solicitud de información del nominado y disponibilidad de pago | Banco Otorgante | Envía (como Acreedora) / Recibe (como Depositaria) | OBL-001, OBL-004, OBL-015 |
| **C-51** | Respuesta a la solicitud | Banco Ordenante | Responde (como Depositaria) en 30 seg | OBL-015 |
| **C-52** | Otorgamiento del Crédito CAN | Banco Otorgante | Envía (como Acreedora) en 48h | OBL-009, OBL-010 |
| **C-53** | Envío de Prelación | Cecoban | Recibe (como Depositaria) — actualiza orden de prelación | OBL-016 |
| **C-54** | Actualización de cuenta CLABE del nominado | Banco Ordenante | Envía (como Depositaria) | OBL-019, OBL-020 |
| **C-55** | Actualización datos del crédito CAN | Banco Otorgante | Envía (como Acreedora) | OBL-011 |
| **C-56** | Cambio de Banco Ordenante del nominado | Nuevo Banco Ordenante | Envía (si cliente cambia nómina a BanCoppel) | OBL-023 |
| **C-57** | Entrega de información de créditos por cambio de Banco Ordenante | Cecoban | Recibe (como Acreedora) cuando cliente cambia a otro banco | OBL-019 |
| **C-58** | Otorgamiento y Mantenimiento del crédito CAN propio | Banco Otorgante/Ordenante | Envía (cuando BanCoppel es ambos — CAN propio) | OBL-012 |

---

## BanCoppel como Banco Depositaria (Ordenante) — Responsabilidades

### C-51: El mensaje más complejo

El C-51 es la respuesta al C-50 que BanCoppel debe enviar en **30 segundos**. Contiene:

| Campo | Tipo | Req | Descripción | Fuente en bdiadminnomina |
|-------|------|-----|-------------|--------------------------|
| 01 | N | M | Código de operación (51) | — |
| 02 | N | M | Banco Ordenante (40137) | — |
| 03 | A | M | UUID generado por Cecoban | — (eco) |
| 04 | A | M | Folio de la Solicitud | — (eco del C-50) |
| 05 | A | M | Fecha y hora de registro (ISO 8601) | — (eco del C-50) |
| 06 | A | M | Nombre(s) del Nominado | **Tabla de cuentahabientes** |
| 07 | A | O | Primer Apellido del Nominado | **Tabla de cuentahabientes** |
| 08 | A | O | Segundo Apellido del Nominado | **Tabla de cuentahabientes** |
| 09 | A | M | CURP del Nominado | **Tabla de cuentahabientes** |
| 10 | A | O | RFC del Nominado | **Tabla de cuentahabientes** |
| 11 | A | M | Liquidación CAN o Mis to Mis (SI/NO) | — (eco del C-50) |
| 12 | N | M | Cuenta CLABE del crédito a liquidar | **bdiadminnomina — créditos propios** |
| 13 | N | M | Cuenta CLABE del Banco Ordenante | **Cuenta Ordenante del nominado** |
| 14 | N | M | Banco Ordenante (40137) | — |
| 15 | A | M | Liquidación CAN o Mis to Mis + subcampos | **bdiadminnomina — créditos existentes** |
| 16 | N | M | Cuenta CLABE del crédito MIS to MIS | **bdiadminnomina — créditos Mis to Mis** |
| 17 | N | M | Cuenta CLABE del crédito CAN | **bdiadminnomina — CANs existentes** |
| 18 | A | O | RFC de la emisora (patrón) | **Tabla de patrones/dispersores** |
| 19 | N | M | Cuenta CLABE en Banco Ordenante | — (confirma campo 13) |
| 20 | A | M | Tipo de crédito MIS to MIS + subcampos | **bdiadminnomina — todos los créditos vigentes** |
| 21 | N | M | Banco Otorgante del Crédito | — (eco del C-50) |
| 22 | N | M | Periodicidad de la dispersión de nómina | **Tabla de configuración de dispersión** |
| 23 | N | M | Frecuencia de pago de nómina + días de pago | **Tabla de dispersión + calendario** |
| **24** | — | — | **Ingreso del cliente — 6 meses de historia** | **Motor de nómina — historial de abonos** |
| 25 | N | M | Información del Nominado (catálogo) | **Validación interna** |
| 26 | A | M | Fecha y hora de respuesta | — |

**Campo 24 — Ingreso del cliente (el más crítico para bdiadminnomina):**
```
Por cada uno de los 6 meses consecutivos (mes vencido → mes actual-1):
  - Subcampo 1: Mes (01=Enero ... 12=Diciembre)
  - Subcampo 2: Monto de ingreso mensual (total del mes, 2 decimales)
  - Por cada abono del mes:
    - Sub-subcampo 1: Fecha del abono (AAAA-MM-DD)
    - Sub-subcampo 2: Monto del abono (2 decimales)
    - Sub-subcampo 3: Descripción/concepto del abono (opcional)
Mínimo 3 meses con ingresos requeridos.
Si nominado tiene dispersión intermitente: enviar igualmente los 6 meses.
```

### Otros códigos como Depositaria

| Código | Acción BanCoppel (Depositaria) | Trigger |
|--------|-------------------------------|---------|
| C-53 (recibe) | Actualizar orden de prelación en bdiadminnomina | Cecoban envía cuando hay cambios de prelación |
| C-54 (envía) | Informar a Cecoban: cancelación domiciliación, cuenta bloqueada, no recibe nómina, cambio de cuenta | Eventos en Cuenta Ordenante |
| C-56 (envía) | Informar a Cecoban: cliente cambió su nómina a BanCoppel | Alta de nueva dispersión de nómina |

---

## BanCoppel como Banco Acreedora (Otorgante) — Responsabilidades

| Código | Acción BanCoppel (Acreedora) | SLA |
|--------|------------------------------|-----|
| C-50 (envía) | Solicitar información del nominado al Cecoban antes de ofertar CAN interbancario | — |
| C-52 (envía) | Informar otorgamiento del CAN (número de crédito, condiciones, periodicidad, descuento) | 48h desde C-51 |
| C-55 (envía) | Actualizar condiciones del CAN (cambio de monto, baja por liquidación, baja por sustitución) | — |
| C-58 (envía) | Registrar CANs propios (cuando BanCoppel es Acreedora y Depositaria a la vez) | — |
| C-57 (recibe) | Recibir notificación cuando un nominado cambia su nómina a otro banco | — |

---

## Implicaciones para los Sistemas BanCoppel

| Sistema | Impacto | Tipo de cambio |
|---------|---------|---------------|
| **bdiadminnomina** (Informix) | Exponer vía API: historial 6 meses de abonos por CURP, CANs vigentes, créditos Mis to Mis, periodicidad de dispersión, RFC patrón | **Query nuevo** + exposición API. Riesgo performance: 30 segundos |
| **Capa de integración** (nuevo/existente) | Adaptar o crear cliente API Cecoban: envío/recepción de 9 C-codes en JSON/TLS 1.3 | **Nuevo microservicio** de integración Cecoban-CAN |
| **ControlM** | Jobs de actualización C-54: cuando Cuenta Ordenante se bloquea, cierra o deja de recibir nómina → trigger automático de C-54 a Cecoban | **Nuevo job batch** de sincronización |
| **Canales digitales** | Originar C-50 al solicitar CAN interbancario; mostrar al cliente estado de su CAN | **Flujo nuevo** en App Móvil y Banca Internet |
| **Reporting** | Registro de los 9 C-codes + ACK de Cecoban para auditoría (10 años de retención) | **Tabla de log** + proceso de archivado |

---

## Consideraciones Técnicas Críticas

1. **Enlace de comunicación**: BanCoppel debe informar a Cecoban si usará el enlace existente de la Cámara de Compensación o si contratan uno nuevo específico para CAN. Recomendación: aprovechar el existente SPEI.

2. **SLA 30 segundos para C-51**: El query de 6 meses de ingresos sobre bdiadminnomina debe ejecutarse en tiempo real. Si el SP no existe o tarda más de 30 segundos → rechazo del mensaje. Este es el **principal riesgo técnico del proyecto**.

3. **CURP como llave**: Cecoban usa CURP + RFC como llaves de identificación del nominado. BanCoppel debe tener CURP almacenado en bdiadminnomina por cuenta. Si no está, hay brecha que bloquea la operación.

4. **C-58 para CANs propios**: Todos los CANs donde BanCoppel sea ambos Acreedora y Depositaria deben registrarse en Cecoban. Esto aplica a los CANs existentes que BanCoppel ya tiene en cartera — requiere migración/registro inicial.

5. **Retención 10 años**: Todos los mensajes C-code + ACK deben guardarse 10 años. No es el sistema de origen (bdiadminnomina) sino un log de transacciones de integración.

---

## Catálogos Relevantes (resumen)

Los catálogos completos están en [catalogos-referencia-can.md](catalogos-referencia-can.md).

| Catálogo | Valores clave |
|----------|---------------|
| Códigos de Operación | 50-58 (9 codes) |
| Bancos | 40137 = BanCoppel |
| Estatus de cuenta/crédito | 01 Activo · 02 Baja liquidación · 03 Baja sustitución · 04 Cancelación domiciliación · 05-11 |
| Tipo de Crédito | 01 CAN · 02 Consumo · 03 Hipotecario · 04 Nómina · 05 Auto · 06 Tarjeta de crédito |
| Periodicidad | 01 Mensual · 02 Quincenal · 03 Decenal · 04 Catorcenal · 05 Semanal |
| Info del Nominado | 01 Con disponibilidad · 12 Sin disponibilidad (12 valores en total) |

---

*v1.0.0 · 2026-09-17 · DE CAN v4.2 (GT de CAN - ABM, Cecoban) · dt-de-can*
