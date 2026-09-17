# Obligaciones CAN — Catálogo Regulatorio
> **Fuente:** Circular 3/2012 Banxico (compilado Circular 6/2025)
> **Versión:** 1.0.0 · 2026-09-16 · dt-normativa-can
> **[DATO-REQUERIDO]:** Art. 81 Bis 1 y 81 Bis 2 (Servicio de Nómina Interbancaria) — pendiente extracción de páginas 111+ de la circular

---

## Resumen de Obligaciones por Rol

| Rol BanCoppel | Obligaciones aplicables |
|---------------|------------------------|
| **Como Institución Ordenante** (lleva Cuenta Ordenante) | OBL-013 a OBL-023 |
| **Como Institución Acreedora** (otorga el CAN) | OBL-001 a OBL-012 |
| **Ambos roles** | Mecanismo Art. 63 Bis 3 (OBL-012) |

---

## Catálogo de Obligaciones

### CAN-OBL-001 · Solicitar info antes de ofrecer CAN interbancario
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 1) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Antes de celebrar crédito destinado a ser CAN en Cuenta Ordenante de otra Institución, solicitar a esa institución la información del Art. 22 Bis 1 I(b) segundo párrafo (monto de cargos, saldos y abonos recientes) por medio del mecanismo Art. 63 Bis 3 |
| Tipo | `control` |
| Frecuencia | `evento` — al ofrecer un CAN en cuenta de otra institución |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018), modificado 2025 |
| Notas | La información solo puede usarse para estimar viabilidad de pago; uso para otro fin está prohibido |

### CAN-OBL-002 · Porcentaje límite de amortizaciones sobre nómina promedio
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 2) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | El monto total de amortizaciones periódicas de todos los CANs del acreditado no puede exceder el porcentaje límite que determine el Comité de Riesgos, basado en el promedio mensual de abonos en la Cuenta Ordenante de los últimos 6 meses consecutivos (o período menor si aplica) |
| Tipo | `limite` |
| Frecuencia | `continuo` |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | El límite lo fija el Comité de Riesgos de la institución; Banxico tiene facultades de supervisión para verificar cumplimiento |

### CAN-OBL-003 · Notificar a Banxico el límite del Comité de Riesgos
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 2, último párrafo) |
| Circular origen | Circular 15/2018 |
| Descripción | Enviar comunicación suscrita por quien presida el Comité de Riesgos a la Gerencia de Autorizaciones y Consultas de Banca Central de Banxico, informando el límite aprobado — dentro de los 10 DHB siguientes a su aprobación o modificación |
| Tipo | `reporte` |
| Frecuencia | `evento` — cuando el Comité aprueba o modifica el límite |
| Riesgo sanción | `alto` |
| Plazo | 10 Días Hábiles Bancarios desde la aprobación del límite |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-004 · Verificar identidad del cliente antes de solicitar info de Cuenta Ordenante
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 3) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Antes de solicitar info a la institución depositaria, verificar la identidad del cliente obteniendo a elección de este: (a) carátula del contrato de apertura de la Cuenta, (b) estado de cuenta del trimestre anterior, o (c) tarjeta de débito vigente con nombre del cuentahabiente |
| Tipo | `control` |
| Frecuencia | `evento` |
| Riesgo sanción | `medio` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-005 · Obtener mandato del acreditado con autorización expresa CAN
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 4) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Antes de celebrar el CAN, obtener mandato del acreditado autorizando expresamente a la institución acreedora para: (a) solicitar info de Cuenta Ordenante, (b) requerir modificación del contrato de depósito, (c) gestionar Domiciliación a nombre del acreditado, (d) informar a otras instituciones la designación CAN. Consentimiento puede ser escrito, electrónico o huella digital |
| Tipo | `control` |
| Frecuencia | `evento` — al celebrar cada CAN |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | Sin este mandato, la institución no tiene base legal para actuar ante la institución depositaria |

### CAN-OBL-006 · Liquidación de créditos anteriores via SPEI al otorgar CAN de refinanciamiento
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (párrafo 5) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Si el CAN se usa para liquidar otro crédito (misma institución u otra), transferir vía SPEI los recursos a la institución acreedora anterior, usando la Clave Básica Estandarizada del crédito a liquidar |
| Tipo | `control` |
| Frecuencia | `evento` |
| Riesgo sanción | `alto` |
| Condiciones | El CAN de refinanciamiento tiene la misma prelación que el crédito liquidado solo si: (a) importe periódico no supera el del crédito anterior, (b) condiciones del CAN son mejores, (c) se cumple Art. 2059 Código Civil Federal |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-007 · Presentar comparativo CAN vs. crédito no-CAN al cliente
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (penúltimo párrafo) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Antes de contratar, presentar al cliente las condiciones del CAN comparadas con las condiciones de un crédito similar que no sea designado como CAN |
| Tipo | `disclosure` |
| Frecuencia | `evento` — previo a cada CAN |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-008 · Reportar a buró de crédito el carácter CAN
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (anteúltimo párrafo) |
| Circular origen | Circular 15/2018 |
| Descripción | Reportar a sociedad de información crediticia que el crédito tiene el carácter de Crédito Asociado a la Nómina, conforme a las disposiciones aplicables |
| Tipo | `reporte` |
| Frecuencia | `evento` |
| Riesgo sanción | `medio` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-009 · Asignar Clave Básica Estandarizada a cada CAN
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis (último párrafo) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Asignar una Clave Básica Estandarizada (conforme Reglas SPEI Circular 14/2017) a cada Crédito Asociado a la Nómina que se otorgue |
| Tipo | `control` |
| Frecuencia | `evento` — al otorgar cada CAN |
| Riesgo sanción | `medio` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | Esta clave se usa en liquidaciones SPEI de refinanciamiento |

### CAN-OBL-010 · Gestionar Domiciliación ante institución de Cuenta Ordenante
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis 1 (párrafo 1) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | La institución acreedora del CAN debe gestionar la Domiciliación ante la institución que lleva la Cuenta Ordenante mediante solicitud del Art. 64, asumiendo el rol de Proveedor y Banco del Proveedor. Debe indicar importes, días del mes y plazo |
| Tipo | `control` |
| Frecuencia | `evento` — al formalizar el CAN |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-011 · Ajustar pagos periódicos por prepago o reducción de monto
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis 1 (párrafo 2) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | En caso de pagos anticipados o cualquier reducción del importe/número de pagos pendientes, ajustar el monto de los pagos periódicos conforme a la Circular 16/2007 Banxico (transparencia en pagos anticipados) |
| Tipo | `control` |
| Frecuencia | `evento` |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-012 · Usar mecanismos de comunicación transparentes y notificar a Banxico
| Campo | Valor |
|-------|-------|
| Artículo | Art. 63 Bis 3 |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Las consultas e intercambio de información entre instituciones (Arts. 22 Bis 1, 63 Bis y 65) deben realizarse únicamente por mecanismos transparentes que no restrinjan ni impidan la participación de otras instituciones en igualdad de circunstancias. Los términos deben notificarse a la Gerencia de Autorizaciones y Consultas de Banca Central de Banxico de manera previa a su implementación |
| Tipo | `control` |
| Frecuencia | `evento` — al implementar o modificar el mecanismo |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | La plataforma/hub de comunicación CAN debe ser aprobada/notificada a Banxico antes de usarse |

---

### CAN-OBL-013 · Identificar Cuentas Ordenantes
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis (mod. Circular 6/2025) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | La institución que administre cuentas de personas físicas debe identificar como Cuentas Ordenantes aquellas que: (I) reciben Prestaciones Laborales del Servicio de Nómina, (II) son cuentas básicas de nómina (Art. 48 Bis 2 LIC), (III) fueron abiertas directamente por el cliente indicando que recibirá abonos de Prestaciones Laborales de Patrones identificados |
| Tipo | `control` |
| Frecuencia | `continuo` — proceso permanente |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018), mod. 2025 |
| Notas | Para la fracción III, la institución debe permitir que el cliente indique que recibirá abonos de Prestaciones Laborales y requerir documentación probatoria del Patrón |

### CAN-OBL-014 · Ofrecer derecho a designar CANs en la Cuenta Ordenante
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción I (párrafo 1) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | La institución que lleve una Cuenta Ordenante debe ofrecer al cuentahabiente el derecho de designar créditos/préstamos (propios o de otras instituciones/SOFOM) como CANs, para que los recursos de la Cuenta Ordenante se usen para cubrir las obligaciones de pago. Este derecho debe quedar estipulado en el contrato de la Cuenta Ordenante |
| Tipo | `control` |
| Frecuencia | `evento` — al abrir/modificar contrato de Cuenta Ordenante |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-015 · Comunicar info de Cuenta Ordenante al siguiente DHB
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción I, inciso b) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Cuando otra Institución/SOFOM declare (via Art. 63 Bis 3) haber ofrecido un CAN en cumplimiento del mandato del cuentahabiente, la institución depositaria debe comunicar a más tardar al DHB siguiente: (i) confirmación de que la Cuenta es Cuenta Ordenante, (ii) monto agregado de cargos actuales y saldo insoluto de CANs vigentes + créditos no-CAN con la misma institución, con fecha límite de liquidación, (iii) monto y fecha de cada abono de los últimos 6 meses consecutivos (o el período disponible, mínimo 3 meses) |
| Tipo | `reporte` |
| Frecuencia | `evento` |
| Plazo | 1 Día Hábil Bancario desde la solicitud |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-016 · Respetar prelación de cargos en Cuenta Ordenante
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción I, inciso e) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Al realizar cargos en la Cuenta Ordenante, respetar el siguiente orden de prelación: (i) créditos y préstamos no-CAN contratados con la misma institución depositaria con anterioridad a los CANs, (ii) CANs en el orden de fecha y hora de designación, (iii) Domiciliaciones de bienes/servicios y otros créditos no-CAN. Si los recursos son insuficientes para un CAN, cargar lo disponible y completar con los siguientes abonos que lleguen a la cuenta |
| Tipo | `control` |
| Frecuencia | `diario` — en cada ciclo de pago |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | Regla crítica que impacta el motor de procesamiento de cargos de bdiadminnomina |

### CAN-OBL-017 · Efectuar cargos de CANs previos al abrir nueva Cuenta Ordenante
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción I, inciso f) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Si se abre una nueva Cuenta Ordenante y se tiene conocimiento (via Art. 63 Bis 3) de CANs vigentes previos otorgados por otras instituciones, la nueva institución depositaria debe efectuar los cargos en la prelación correspondiente |
| Tipo | `control` |
| Frecuencia | `evento` |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-018 · Obtener mandato del cuentahabiente para consultar e informar CANs
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción II |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Al abrir una Cuenta Ordenante o al designar una cuenta como Cuenta Ordenante, obtener del cuentahabiente un mandato con autorización expresa para: proporcionar información regulatoria y consultar (via Art. 63 Bis 3) si el cuentahabiente tiene CANs previos con otras instituciones. El mandato puede ser escrito, electrónico o por huella digital |
| Tipo | `control` |
| Frecuencia | `evento` |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | Sin este mandato, la institución no puede legalmente consultar ni compartir información CAN del cliente |

### CAN-OBL-019 · Comunicar datos de nueva Cuenta Ordenante a instituciones con CANs previos
| Campo | Valor |
|-------|-------|
| Artículo | Art. 22 Bis 1, fracción II (párrafos 2-4) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Al abrir o designar una Cuenta Ordenante, si otra institución tiene CANs previos del mismo cuentahabiente en otra Cuenta Ordenante, comunicar a esa institución: (i) nombre de la institución que abre/designa la cuenta, (ii) número y CLABE de la nueva Cuenta Ordenante, (iii) nombre completo, RFC (con homoclave) y CURP del cuentahabiente |
| Tipo | `reporte` |
| Frecuencia | `evento` |
| Plazo | Al momento de apertura/designación |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |
| Notas | Información solo puede usarse para identificar a la institución acreedora del CAN — no para otros fines |

### CAN-OBL-020 · Notificar cancelación de Domiciliación CAN a institución acreedora
| Campo | Valor |
|-------|-------|
| Artículo | Art. 65 |
| Circular origen | Circular 7/2019, mod. 6/2025 |
| Descripción | Cuando el cuentahabiente solicite cancelar la Domiciliación de un CAN otorgado por otra institución/SOFOM, el Banco del Cliente debe informar a esa institución/SOFOM via mecanismo Art. 63 Bis 3, a más tardar al DHB siguiente a la recepción de la solicitud |
| Tipo | `control` |
| Frecuencia | `evento` |
| Plazo | 1 Día Hábil Bancario desde la solicitud de cancelación |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2019 (Circular 7/2019) |

### CAN-OBL-021 · Resolver objeción de cargos CAN en 5 DHB
| Campo | Valor |
|-------|-------|
| Artículo | Art. 68 (párrafo 2) |
| Circular origen | Circular 15/2018, mod. 6/2025 |
| Descripción | Para notificaciones de objeción relativas a Domiciliaciones de CANs, resolver en máximo 5 Días Hábiles Bancarios (no aplica el plazo de 60 días de otras Domiciliaciones). Si procede, abonar a más tardar al DHB siguiente a la fecha de resolución |
| Tipo | `control` |
| Frecuencia | `evento` |
| Plazo | 5 Días Hábiles Bancarios desde la notificación de objeción |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2018 (Circular 15/2018) |

### CAN-OBL-022 · Remitir objeción CAN a institución acreedora en 2 DHB
| Campo | Valor |
|-------|-------|
| Artículo | Art. 68 (párrafo 3) |
| Circular origen | Circular 7/2019, mod. 6/2025 |
| Descripción | Para objeciones de CANs otorgados por otra institución/SOFOM, el Banco del Cliente debe remitir copia de la notificación de objeción a esa institución/SOFOM en máximo 2 DHB. La institución/SOFOM debe responder en máximo 3 DHB adicionales |
| Tipo | `control` |
| Frecuencia | `evento` |
| Plazo | 2 DHB para remitir; 3 DHB adicionales para respuesta de la acreedora |
| Riesgo sanción | `alto` |
| Fecha efectiva | 2019 (Circular 7/2019) |

### CAN-OBL-023 · Transferir Prestaciones Laborales el mismo DHB o al siguiente
| Campo | Valor |
|-------|-------|
| Artículo | Art. 75 |
| Circular origen | Circular 7/2015, mod. 15/2018 y 7/2019 |
| Descripción | La Institución Ordenante debe ejecutar las transferencias de Prestaciones Laborales a la Cuenta Receptora: (a) el mismo DHB si el abono llega antes de las 17:00:00, (b) el DHB siguiente si llega después de las 17:00:00. Excepción: si debe cargar previamente montos de CANs del cuentahabiente. Sin costo para el cuentahabiente |
| Tipo | `control` |
| Frecuencia | `diario` |
| Riesgo sanción | `critico` |
| Fecha efectiva | 2015 (Circular 7/2015) |
| Notas | La excepción CAN es crítica: si hay cargos CAN pendientes, se aplican antes de transferir el remanente |

---

## [DATO-REQUERIDO] Obligaciones Pendientes de Extracción

Los siguientes artículos están en la Circular 3/2012 pero no fueron incluidos en el rango de páginas extraído (págs. 59-110):

| Artículo | Tema | Estado |
|----------|------|--------|
| Art. 81 Bis 1 | Servicios de Nómina Interbancaria | `[DATO-REQUERIDO]` — extraer págs. 111+ |
| Art. 81 Bis 2 | Lineamientos para el ofrecimiento y prestación del Servicio de Nómina Interbancaria | `[DATO-REQUERIDO]` — extraer págs. 111+ |
| Anexos 1-4 Bis | Formatos de solicitud de Domiciliación, cancelación, objeción y transferencia | `[DATO-REQUERIDO]` — revisar últimas páginas |

---

*v1.0.0 · 2026-09-16 · dt-normativa-can · 23 obligaciones catalogadas*
