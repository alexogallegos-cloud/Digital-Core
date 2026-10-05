# Catálogos de Referencia CAN — Cecoban
> **Fuente:** Documento de Entendimiento CAN v4.2 · 25/08/2026 · Cecoban (Anexo)
> **Versión:** 1.0.0 · 2026-09-17 · dt-de-can

---

## Catálogo de Códigos de Operación

| Id | Descripción | Iniciado por | Santander rol |
|----|-------------|-------------|---------------|
| 50 | Solicitud de información del nominado y disponibilidad de pago | Banco Otorgante | Envía (Acreedora) / Recibe (Depositaria) |
| 51 | Respuesta a la solicitud de información del nominado y disponibilidad de pago | Banco Ordenante | Envía (Depositaria) |
| 52 | Otorgamiento del Crédito CAN | Banco Otorgante | Envía (Acreedora) |
| 53 | Envío de Prelación | Cecoban | Recibe (Depositaria) |
| 54 | Actualización de cuenta CLABE del nominado en Banco Ordenante | Banco Ordenante | Envía (Depositaria) |
| 55 | Actualización datos del crédito CAN en Banco Otorgante | Banco Otorgante | Envía (Acreedora) |
| 56 | Cambio de Banco Ordenante del nominado | Nuevo Banco Ordenante | Envía (si cliente migra nómina a Santander) |
| 57 | Entrega de información de créditos por cambio de Banco Ordenante | Cecoban | Recibe (Acreedora) |
| 58 | Otorgamiento y Mantenimiento del crédito CAN propio | Banco Otorgante/Ordenante | Envía (ambos roles — CAN propio) |

---

## Catálogo de Bancos (participantes en CAN)

| Número | Institución |
|--------|-------------|
| 40002 | Banco Nacional de México, S.A. (Citibanamex) |
| 40012 | BBVA Bancomer, S.A. |
| 40014 | Banco Santander, S.A. |
| 40021 | HSBC México, S.A. |
| 40030 | Banco del Bajío, S.A. |
| 40036 | Banco Inbursa, S.A. |
| 40042 | Banca Mifel, S.A. |
| 40044 | Scotiabank Inverlat, S.A. |
| 40058 | Banco Regional de Monterrey, S.A. |
| 40059 | Banco Invex, S.A. |
| 40060 | Bansi, S.A. |
| 40062 | Banca Afirme, S.A. |
| 40072 | Banco Mercantil del Norte, S.A. (Banorte) |
| 40108 | MUFG Bank México, S.A. |
| 40112 | Banco Monex, S.A. |
| 40113 | Banco Ve por Más, S.A. |
| 40127 | Banco Azteca, S.A. |
| 40128 | Banco Autofin México, S.A. |
| 40130 | Banco Compartamos, S.A. |
| 40132 | Banco Multiva, S.A. |
| 40133 | Banco Actinver, S.A. |
| 40136 | Intercam Banco, S.A. |
| **40137** | **BanCoppel, S.A.** |
| 40138 | ABC Capital, S.A. |
| 40140 | CONSUBANCO, S.A. |
| 40141 | Volkswagen Bank, S.A. |
| 40147 | Bankaool, S.A. |
| 40148 | Banco PagaTodo, S.A. |
| 40149 | Banco Forjadores, S.A. |
| 40150 | Banco Inmobiliario Mexicano, S.A. |
| 40152 | Banco Bancrea, S.A. |
| 40154 | Banco Covalto, S.A. |
| 40159 | Bank of China México, S.A. |
| 40165 | Banco Bineo, S.A. |
| 40167 | Hey Banco, S.A. |
| 40169 | Openbank México S.A. |
| 40170 | Revolut Bank, S.A. |
| 40171 | Banco Plata S.A. |
| 40638 | Nubank, S.A. |

---

## Catálogo de Estatus

| Id | Estatus | Código donde aplica |
|----|---------|---------------------|
| 01 | Activo | C-52, C-56, C-58 |
| 02 | Baja por liquidación del crédito | C-55, C-58 |
| 03 | Baja por sustitución de crédito | C-55, C-58 |
| 04 | Cancelación de la Domiciliación a petición del cliente | C-54, C-55, C-58 |
| 05 | Ya no recibe depósitos de nómina (después de 2 meses sin depósito) | C-54 |
| 06 | CAN vigente, actualización de condiciones | C-55 |
| 07 | Cancelación de cuenta ordenante | C-54 |
| 08 | Cuenta ordenante bloqueada | C-54 |
| 09 | Nueva apertura / dispersión | C-56 |
| 10 | Cambio de cuenta ordenante | C-54, C-56 |
| 11 | Cuenta reactivada (se desbloquea o reactiva domiciliación) | C-54 |

---

## Catálogo de Tipo de Crédito

| Id | Tipo de Crédito |
|----|-----------------|
| 01 | CAN |
| 02 | Consumo |
| 03 | Hipotecario |
| 04 | Nómina |
| 05 | Auto |
| 06 | Tarjeta de crédito |

---

## Catálogo de Periodicidad

| Id | Periodicidad |
|----|--------------|
| 01 | Mensual |
| 02 | Quincenal |
| 03 | Decenal |
| 04 | Catorcenal |
| 05 | Semanal |

---

## Catálogo de Frecuencia

| Id | Frecuencia |
|----|------------|
| 01 | Mensual |
| 02 | Quincenal |
| 03 | Decenal |
| 04 | Catorcenal |
| 05 | Semanal |

> **Nota:** Periodicidad = cuándo dispersa el patrón. Frecuencia = cuándo el nominado debe abonar al crédito. Deben ser consistentes pero no necesariamente iguales.

---

## Catálogo de Meses

| Id | Mes | Id | Mes |
|----|-----|----|----|
| 01 | Enero | 07 | Julio |
| 02 | Febrero | 08 | Agosto |
| 03 | Marzo | 09 | Septiembre |
| 04 | Abril | 10 | Octubre |
| 05 | Mayo | 11 | Noviembre |
| 06 | Junio | 12 | Diciembre |

---

## Catálogo de Información del Nominado (C-51, campo 25)

| Id | Descripción | Notas |
|----|-------------|-------|
| 01 | Cliente con disponibilidad | Nominado cumple ≥ 6 meses de depósitos en cuenta ordenante |
| 02 | Cuenta incorrecta | La cuenta CLABE reportada no coincide |
| 03 | RFC y CURP incorrecto | Datos de identidad erróneos |
| 04 | Folio en trámite (mismo Banco) | Ya hay un C-50 activo del mismo banco para este nominado |
| 05 | No recibe depósitos de nómina | La cuenta no tiene dispersión activa |
| 06 | Cuenta bloqueada | La cuenta ordenante está bloqueada |
| 07 | Sí, pero la cuenta es Nivel 2 | Cuenta básica nivel 2 — limitaciones operativas |
| 08 | Contratos y/o Colectivos especiales con dispersión intermitente | No tiene dispersión continua |
| 09 | Cliente con domiciliación cancelada | La domiciliación fue cancelada |
| 10 | Cliente nominado no cumple con 3 meses de dispersión | Historial insuficiente |
| 11 | Folio en trámite (Otro Banco) | Ya hay un C-50 activo de otro banco para este nominado |
| 12 | Cliente sin disponibilidad | No cumple los criterios de disponibilidad |

---

## Causas de Rechazo de Cecoban

| Clave | Descripción | Cuándo aplica |
|-------|-------------|---------------|
| 01 | Banco inválido o no participa en el servicio | Banco no está en el Catálogo de Bancos participantes |
| 02 | UUID no corresponde al generado por Cecoban | El UUID enviado no coincide con el asignado por Cecoban |
| 03 | Contiene valor diferente a "00" | Campo mandatorio vacío debe ir en "00" pero tiene otro valor |
| 05 | Valor del campo inválido, no coincide con la nomenclatura | Dato no ajusta al formato, catálogo o norma técnica |
| 06 | Estructura del mensaje json incorrecta | JSON no cumple el layout-schema del código |
| 08 | Código de Operación inválido | Código incorrecto para la solicitud |
| 10 | Formato fecha y hora inválido | No cumple ISO 8601 `AAAA-MM-DDThh:mm:ss` |
| 11 | Frecuencia no coincide con periodicidad | Frecuencia incompatible con el campo periodicidad |
| 12 | Frecuencia no está relacionada con subcampos | Frecuencia incompatible con los días de pago |
| 13 | Formato de CURP incorrecto | No cumple estructura alfanumérica de 18 caracteres |
| 14 | Formato incorrecto RFC no válido | No cumple estructura de 13 caracteres con Homoclave |
| 15 | Cuenta CLABE inválida | No cumple estructura numérica de 18 dígitos |
| 17 | Mes inválido, no coincide con catálogo | Número de mes fuera del Catálogo de Meses |
| 19 | Información del nominado inválida, no corresponde al catálogo | Código fuera del Catálogo de Información del Nominado |
| 20 | Formato de fecha inválido | No cumple ISO 8601 `AAAA-MM-DD` |
| 21 | No existe operación origen | No hay C-50 previo registrado en BD de Cecoban |
| 22 | Tipo de crédito inválido, no corresponde al catálogo | Código fuera del Catálogo de Tipo de Crédito |
| 24 | Frecuencia de pago inválida, no corresponde al catálogo | Código fuera del Catálogo de Frecuencia |
| 25 | Contiene caracteres inválidos | Caracteres fuera de la Tabla de Caracteres Válidos |
| 28 | Número de Banco en la cuenta CLABE no coincide con el indicado en campo correspondiente | Los primeros 3 dígitos de la CLABE no coinciden con el código del banco |
| 30 | Total de ingresos del mes incorrecto | La suma de abonos no coincide con el total mensual |
| 32 | Periodicidad inválida, no corresponde al catálogo | Código fuera del Catálogo de Periodicidad |
| 33 | Respuesta de liquidación CAN – Mis to Mis inválida | El campo liquidación no es "SI" o "NO" |
| 34 | Valor del campo inválido, es obligatorio | Campo mandatorio vacío o nulo |
| 35 | Valor de estatus incorrecto | Código fuera del Catálogo de Estatus |
| 36 | Solicitud rechazada por presentación fuera del tiempo máximo permitido | Se excedió el SLA de 30 segundos |

---

## Expresiones Regulares (validaciones)

| Campo | Expresión regular |
|-------|------------------|
| UUID | `^[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}$` |
| Fecha (AAAA-MM-DD) | `^\d{4}-(0[1-9]\|1[0-2])-(0[1-9]\|[12]\d\|3[01])$` |
| Fecha-hora ISO 8601 sin offset | `^\d{4}-(0[1-9]\|1[0-2])-(0[1-9]\|[12]\d\|3[01])T([01]\d\|2[0-3]):[0-5]\d:[0-5]\d$` |
| Importe (2 decimales) | `^\d+\.\d{2}$` |
| CURP (18 caracteres) | Ver DE CAN v4.2 página 93 |
| RFC persona física (13 caracteres) | `^[A-Z&Ñ]{4}\d{2}(0[1-9]\|1[012])(0[1-9]\|[12]\d\|3[01])[A-Z0-9]{2}[0-9A]$` |
| RFC persona moral (12 caracteres) | `^[A-Z&Ñ]{3}\d{2}(0[1-9]\|1[012])(0[1-9]\|[12]\d\|3[01])[A-Z0-9]{2}[0-9A]$` |
| CLABE (18 dígitos) | `^\d{18}$` |
| Código de banco (5 dígitos) | `^\d{5}$` |

---

*v1.0.0 · 2026-09-17 · Extraído de DE CAN v4.2 Anexo (pp. 87-93) · Cecoban, S.A. de C.V. · dt-de-can*
