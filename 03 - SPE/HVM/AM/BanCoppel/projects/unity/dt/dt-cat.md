# DT — CAT / Contact Center (Canal IVR + ICCAT)
> Digital Twin del track CAT (Contact Center Atención Telefónica) para la Tarjeta de Crédito R4 (Producto 4900).
> Fuente primaria: `20260803 - R4 CAT - Analisis detallado HDUs e Integraciones.docx`
> Fuente secundaria: `Consolidacion y priorizacion_HUs_R4_v2.xlsx` · `Inventario de Integraciones_HUs_ R4_v1.0.xlsx`
> Sesión de análisis: 2026-08-03
> Última actualización: 2026-08-20 · v1.0.0

---

## Resumen del Track

| Campo | Valor |
|-------|-------|
| Track ID | `cat` |
| Tipo | channel (Contact Center — IVR + ICCAT) |
| Proveedor | **Por contratar** (provider_status: pending) |
| Status | 🔴 En riesgo crítico |
| User Stories totales | 12 |
| RAG | 🔴 RED en las TRES dimensiones |
| Sesión de análisis | 2026-08-03 |
| Source doc | `20260803 - R4 CAT - Analisis detallado HDUs e Integraciones.docx` |

> **Estado crítico confirmado 2026-08-19:** CAT es el único track ROJO en las tres dimensiones (solución, integración y proveedor). Doble bloqueo activo: sin proveedor contratado y sin responsable confirmado para DTMs. Sin fechas de implementación. El proveedor, de contratarse en agosto, entraría a mediados de septiembre con 1 mes de onboarding — su inicio real de implementación coincidiría con el arranque de SIT (octubre 2026).

### Sistemas del Track

| Sistema | Rol |
|---------|-----|
| **IVR** | Canal de autoservicio (800 BanCoppel) — menús de voz, ANI, DTMF |
| **IBR** | Plataforma de IVR — ambiente bloqueado (requiere nube; arquitectura rechazó habilitación) |
| **ICCAT** | Herramienta de gestión de llamadas para agentes del Contact Center |
| **SMARTVISTA (SVIP)** | Core que expone las 92 APIs (SVIP) consumidas por IVR/ICCAT |

---

## MoSCoW del Track

| MoSCoW | Cuenta | Notas |
|--------|--------|-------|
| Must | 9 | Entrega comprometida R4 |
| Should | 3 | Mejoras de experiencia y autenticación |
| Could | 0 | — |
| Won't | 0 | — |
| **Total** | **12** | — |

### Distribución por Tipo de Solución

| Tipo | Cuenta |
|------|--------|
| Solución (sin integración) | 5 |
| Solución e Integración | 7 |

### Complejidad

| Nivel | Cuenta |
|-------|--------|
| Baja | 4 |
| Media | 4 |
| Alta | 4 |

---

## User Stories (hdu_catalog) — 12 User Stories

Cobertura general: **6 partial + 6 not_covered** = 12 total. El ratio de not_covered (50%) es el más alto de todos los tracks — consecuencia directa de que el proveedor no está contratado y el ambiente IBR está bloqueado.

### CAT-MF-01 — Autoservicio IVR

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-CAT-R4-01 | Alta producto 4900 en menú IVR con ANI (identificación automática del número) | CAP-CHANNEL-SELFSERVICE | **not_covered** |
| HDU-CAT-R4-02 | Consultar saldos y movimientos desde IVR (`getInstantCreditStatement`) | CAP-BALANCE-STATEMENT | **not_covered** |
| HDU-CAT-R4-08 | Completar integración saldo/movimientos IVR con SVIP (locuciones español mexicano) | CAP-BALANCE-STATEMENT | **not_covered** |
| HDU-CAT-R4-09 | Gestionar autenticación reforzada en IVR (DTMF) | CAP-AUTHENTICATION | **not_covered** |
| HDU-CAT-R4-10 | Gestionar opciones de autoservicio IVR por nivel de mora (`agingPeriod E1/E2/E3`) | CAP-COLLECTIONS-AGING | **not_covered** |

> Los 5 User Stories de autoservicio IVR son not_covered. El IVR es un canal externo al alcance de SmartVista — la lógica de menús, ANI, DTMF y locuciones es responsabilidad del proveedor CAT, no de SmartVista.

### CAT-MF-02 — Identificación y Autenticación en ICCAT

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-CAT-R4-03 | Identificar cliente y perfil TDC en ICCAT (crédito 18 dígitos) | CAP-CUSTOMER-PROFILE | partial |
| HDU-CAT-R4-04 | Gestionar intentos de autenticación en CAT (3 intentos max, bloqueo) | CAP-AUTHENTICATION | **not_covered** |
| HDU-CAT-R4-05 | Bloquear tarjeta desde CAT via ICCAT (`updateCardStatus` + SMS `MAI_BDT_IC`) | CAP-CARD-LIFECYCLE | partial |
| HDU-CAT-R4-06 | Desbloquear tarjeta desde CAT con OTP SMS de 4 dígitos | CAP-CARD-LIFECYCLE | partial |
| HDU-CAT-R4-07 | Consultar estatus de tarjeta desde CAT (`getAccountCards`/`getCardInfo`) | CAP-CARD-LIFECYCLE | partial |

> HDU-03/05/06/07 son `partial` porque las APIs SVIP están disponibles; lo que falta es la integración entre ICCAT y SmartVista, que es responsabilidad del proveedor CAT. HDU-04 es not_covered porque la lógica de contador de intentos es del canal, no de SmartVista.

### CAT-MF-03 — Gestión de Tarjetas desde CAT

| ID | Narrativa corta | Capability | PreGame |
|----|----------------|-----------|---------|
| HDU-CAT-R4-11 | Registrar reporte de robo/extravío desde CAT (bloqueo + folio + SMS) | CAP-CARD-LIFECYCLE | partial |
| HDU-CAT-R4-12 | Gestionar cancelación definitiva de tarjeta desde CAT (robo/extravío/daño/vencimiento) | CAP-CARD-LIFECYCLE | partial |

> DTM: `ManageCardCancellationReport`. La cancelación por daño/destrucción depende de parametrización CSTS adicional.

---

## User Stories Inventory (USI v2) — 12 User Stories

Fuente: `Consolidacion y priorizacion_HUs_R4_v2.xlsx`

| ID | Título | MoSCoW | Complejidad | Tipo | Integraciones |
|----|--------|--------|-------------|------|--------------|
| HDU-CAT-R4-01 | Alta producto 4900 en menú IVR | Must | Alta | Sol. e Integración | 2 |
| HDU-CAT-R4-02 | Rutar opciones IVR de atención TDC | Must | Media | Sol. e Integración | 1 |
| HDU-CAT-R4-03 | Identificar cliente Apolo en CAT | Must | Baja | Solución | 0 |
| HDU-CAT-R4-04 | Mantener autenticación en misma llamada | Should | Baja | Solución | 0 |
| HDU-CAT-R4-05 | Bloquear tarjeta por CAT | Must | Alta | Sol. e Integración | 1 |
| HDU-CAT-R4-06 | Desbloquear tarjeta por CAT | Must | Alta | Sol. e Integración | 1 |
| HDU-CAT-R4-07 | Actualizar históricos CAT por cambio de estatus | Should | Media | Solución | 0 |
| HDU-CAT-R4-08 | Consultar saldos y movimientos del producto 4900 por IVR | Must | Alta | Sol. e Integración | 1 |
| HDU-CAT-R4-09 | Controlar datos inválidos e intentos fallidos en IVR | Must | Baja | Solución | 0 |
| HDU-CAT-R4-10 | Gestionar intentos fallidos de autenticación en ICCAT | Should | Baja | Solución | 0 |
| HDU-CAT-R4-11 | Consultar en CAT los productos y estatus de tarjetas del cliente | Must | Media | Sol. e Integración | 1 |
| HDU-CAT-R4-12 | Reportar robo, extravío, daño o vencimiento y cancelar el plástico desde CAT | Must | Media | Sol. e Integración | 1 |

---

## Integraciones del Track CAT — 7 integraciones

Fuente: `Inventario de Integraciones_HUs_ R4_v1.0.xlsx`

| ID | User Story | Nombre | Origen | Destino | Tipo | Estado | Complejidad | Existe Hoy |
|----|-----|--------|--------|---------|------|--------|-------------|-----------|
| ICAT01 | R4-01 | Consulta de clientes SmartVista | IVR | SMARTVISTA | API | Nueva | Media | No |
| ICAT02 | R4-01 | Consulta de cliente por cuenta SmartVista | IVR | SMARTVISTA | API | Nueva | Media | No |
| ICAT03 | R4-02 | Canalizar al cliente con ejecutivo | IVR-Robot | IVR-CC | Evento | Modificar | Baja | Sí |
| ICAT04 | R4-08 | Consulta de saldos y movimientos por IVR | IVR | SMARTVISTA | API | Nueva | Alta | No |
| ICAT05 | R4-05 | Bloqueo de tarjeta SmartVista | ICCAT | SMARTVISTA | API | Nueva | Media | No |
| ICAT06 | R4-06 | Desbloqueo de tarjeta SmartVista | ICCAT | SMARTVISTA | API | Nueva | Media | No |
| ICAT07 | R4-11 | Consultar productos y estatus de tarjetas | ICCAT | SMARTVISTA | API | Nueva | Media | No |

**Resumen:** 6 APIs + 1 Evento. 6 nuevas + 1 modificación. ICAT01/02/04 son IVR→SmartVista; ICAT05/06/07 son ICCAT→SmartVista. Responsable: nuevo proveedor CAT + equipo Apificación (Accenture).

> Las 6 integraciones nuevas (ICAT01/02/04/05/06/07) no tienen responsable técnico hasta contratar el proveedor. Ver RISK-UNITY-R27.

---

## Capabilities Impactadas

| Capability | Cobertura | Build | Notas |
|-----------|----------|-------|-------|
| CAP-CHANNEL-SELFSERVICE | not_covered | not_built | Bloqueado por RISK-UNITY-R27 (proveedor) — SLO bloqueado |
| CAP-AUTHENTICATION | partial | not_built | OTP/ANI/DTMF especificados; implementación bloqueada — SLO bloqueado |
| CAP-BALANCE-STATEMENT | partial | not_built | IVR/CAT parcialmente bloqueado; App y SIWEB avanzan independientemente |
| CAP-CARD-LIFECYCLE | partial | not_built | APIs SVIP disponibles; integración ICCAT pendiente de proveedor |
| CAP-COLLECTIONS-AGING | partial | not_built | HDU-CAT-R4-10: menú dinámico IVR por `agingPeriod`; depende de Cobranza + proveedor |
| CAP-CUSTOMER-PROFILE | partial | not_built | APIs SVIP disponibles; integración ICCAT completa a construir |
| CAP-ERROR-CATALOG | partial | not_built | CAT debe consumir catálogo SV dinámicamente (hoy hardcodeado) |
| CAP-COLLECTIONS-ENGINE | partial | not_built | Motor de cobranza direccionada — `agingPeriod` que consume HDU-CAT-R4-10 depende de que este motor esté construido. Bloqueante: RISK-UNITY-R06 |

---

## Riesgos del Track

| ID | Descripción | Categoría | Impacto | Probabilidad | Due Date | Status | Owner |
|----|-------------|-----------|---------|-------------|----------|--------|-------|
| RISK-UNITY-R27 | Proveedor CAT no contratado — Contact Center sin equipo técnico responsable de 12 User Stories y 6 integraciones nuevas | vendor | Alto | Alto | 2026-08-31 | 🔴 Abierto | PMO Unity |
| RISK-UNITY-R18 | Ambiente IBR bloqueado — arquitectura rechazó habilitar servidor IBR sin nube; proceso involucra múltiples áreas con SLAs independientes | Entornos | Alto | Alto | Sin fecha | 🔴 Abierto | Ramses Santos |
| RISK-UNITY-R17 | Frameworks obsoletos en canales CAT — vulnerabilidades + riesgo de cronograma si se decide cambiar en R4 | Arquitectura | Medio | Medio | 2026-08-03 | 🟡 Abierto | Ramses Santos / Mercedes Espinosa |

**Riesgo dominante (RISK-UNITY-R27):** si el proveedor no firma antes del 2026-08-31, las 6 integraciones nuevas (ICAT01/02/04/05/06/07) no tendrán responsable técnico para SIT (oct-nov 2026). Escenario de scope-out: diferir CAT a R4.5 y lanzar sin autoservicio telefónico.

**Riesgo compuesto:** si RISK-R18 (ambiente IBR) y RISK-R27 (proveedor) no se resuelven simultáneamente, el proveedor contratado no tendría ambiente donde desarrollar ni probar. El ambiente IBR debe desbloquearse antes o en paralelo con la contratación del proveedor.

---

## Stakeholders

| Rol | Nombre | Empresa | Notas |
|-----|--------|---------|-------|
| Track Owner / PM CAT | Ramses Santos | BanCoppel | Accountable — contratación proveedor BLOQUEADA |
| Arquitecta CAT | Mercedes Espinosa Cortes | BanCoppel | Postura frameworks obsoletos; autoridad sobre IBR |
| SME Accenture | Core Banking Transformation | Accenture | SVIP 92 comandos — diseño IVR con SmartVista |
| SME Seguridad | Cybersecurity | Accenture | OTP, ANI, DTMF — PCI-DSS control 8.6 MFA |
| Apificación | Oscar Melo / José Villena | Accenture | Integración SVIP — responsables de ICAT01-07 |

---

## SLOs

| SLO ID | Capability | Disponibilidad | Latencia P95 | Error Rate | Ventana | Status |
|--------|-----------|---------------|-------------|-----------|---------|--------|
| SLO-CHAN | CAP-CHANNEL-SELFSERVICE | 99.9% | 3,000 ms | 0.1% | Mensual | 🔴 Bloqueado |
| SLO-AUTHN | CAP-AUTHENTICATION | 99.9% | — | 0.1% | Mensual | 🔴 Bloqueado |
| SLO-BAL | CAP-BALANCE-STATEMENT | 99.9% | 3,000 ms | 0.1% | 5 min | 🟡 Pendiente |
| SLO-LIFE | CAP-CARD-LIFECYCLE | 99.9% | 3,000 ms | 0.5% | Mensual | 🟡 Pendiente |

> SLO-CHAN y SLO-AUTHN permanecen bloqueados hasta contratar proveedor CAT. APOLO tiene latencia actual de 9 s — requiere mejora antes de SIT.

---

## Plan de Testing

| Capability | SIT | Status SIT | UAT | Tipo de Tests | Notas |
|-----------|-----|-----------|-----|--------------|-------|
| CAP-CHANNEL-SELFSERVICE | Sí | 🔴 Bloqueado (RISK-UNITY-R27) | Sí | Integration + UAT | Sin proveedor = sin tests posibles |
| CAP-AUTHENTICATION | Sí | Planned | Sí | Integration + Security | OTP/ANI parcialmente bloqueado por CAT |
| CAP-BALANCE-STATEMENT | Sí | Planned | Sí | Integration + UAT | IVR/CAT parcialmente bloqueado |
| CAP-CARD-LIFECYCLE | Sí | Planned | Sí | Integration + UAT | — |

---

## Timeline

| Evento | Fecha | Status |
|--------|-------|--------|
| Sesión de análisis CAT R4 | 2026-08-03 | Completado |
| Deadline contratación proveedor (RISK-R27) | 2026-08-31 | 🔴 Crítico |
| Entrada estimada del proveedor | ~2026-09-15 | Condicional |
| Onboarding proveedor (~1 mes) | Sep-Oct 2026 | Condicional |
| Inicio optimista de implementación | ~2026-10-15 | 🔴 Coincide con SIT |
| Inicio SIT (todos los componentes) | 2026-10-15 | En riesgo |
| Fin SIT / Code Freeze | 2026-12-15 | Pendiente |
| Go-Live Producto 4900 | 2027-01-15 | Pendiente |

---

## Gaps Críticos

| Gap ID | Descripción | Impacto | Status |
|--------|-------------|---------|--------|
| GAP-CAT-01 | Sin proveedor contratado — 12 User Stories y 6 integraciones nuevas sin responsable técnico | Sin entrega de CAT en R4 si no se firma antes del 2026-08-31 | 🔴 Abierto |
| GAP-CAT-02 | Ambiente IBR bloqueado — arquitectura rechazó habilitar sin infraestructura cloud | Sin ambiente de desarrollo/pruebas para el proveedor CAT | 🔴 Abierto |
| GAP-CAT-03 | 7 de 12 User Stories en not_covered — ratio más alto de todos los tracks | Autoservicio IVR (menús, ANI, DTMF, locuciones) sin cobertura | 🔴 Sin proveedor |
| GAP-CAT-04 | Frameworks obsoletos — postura técnica sin definir (RISK-R17) | Si se actualiza: impacto cronograma. Si no: deuda técnica y vulnerabilidades | 🟡 Abierto |
| GAP-CAT-05 | HDU-CAT-R4-10 (agingPeriod IVR) depende de Cobranza Direccionada + proveedor CAT | Menú dinámico por mora no disponible en IVR para R4 | 🟡 Dependencia doble |

---

## Relación con Otros Tracks

| Track | Dependencia |
|-------|------------|
| SmartVista | CAT consume 6 de las 92 APIs SVIP. SmartVista debe exponer `agingPeriod`, `CSTS`, `updateCardStatus`, `getAccountCards`, `getCardInfo` antes de que CAT pueda integrar |
| Cobranza Direccionada | HDU-CAT-R4-10 (menú IVR por mora) no puede completarse sin que Cobranza construya el `agingPeriod` en SmartVista |
| Apolo | CAT identifica al cliente por crédito de 18 dígitos (originación Apolo) — HDU-CAT-R4-03 requiere perfil de cliente Apolo accesible desde ICCAT |

---

## Pendientes

- [ ] Contratar proveedor CAT antes del 2026-08-31 (RISK-UNITY-R27)
- [ ] Desbloquear ambiente IBR con arquitectura y nube (RISK-UNITY-R18) — debe resolverse en paralelo con la contratación
- [ ] Definir postura sobre frameworks obsoletos con Mercedes Espinosa (RISK-UNITY-R17)
- [ ] Validar si el cronograma es viable: onboarding proveedor (1 mes) + implementación deja inicio de desarrollo el mismo día que SIT
- [ ] Confirmar trazabilidad completa de integraciones ICAT01-07 vs DTMs
- [ ] Definir escenario de contingencia: si no hay proveedor firmado al 2026-08-31, ¿CAT se scopea fuera de R4?

---

*Creado: 2026-08-20 · v1.0.0 · Fuente: `20260803 - R4 CAT - Analisis detallado HDUs e Integraciones.docx` + brain.db v1.4.0*