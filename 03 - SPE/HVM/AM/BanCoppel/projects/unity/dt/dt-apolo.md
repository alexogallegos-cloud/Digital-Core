# DT: APOLO — Originación Digital TDC R4
> **Digital Twin** · Fuente: APOLO_R4_HDU_TDC.xlsm · Plan_Integral_Apolo_R4_VF3_050826.xls · ADP_Onboarding Apolo TDC R4_20260708
> **Versión**: v1.0.0 · 2026-08-16
> **Propósito**: Catálogo completo de 37 HDUs de APOLO, 17 Building Blocks, plan integral fase a fase, recursos y mapeo a capabilities Unity

---

## ¿Qué es APOLO?

APOLO es el sistema de **Originación Digital** de BanCoppel — la aplicación que un prospecto usa para solicitar y recibir la Tarjeta de Crédito Clásica Digital (Producto 4900). No es un componente de SmartVista: es un sistema separado de Appwhere que se integra con SmartVista al momento del alta de crédito.

| Campo | Valor |
|-------|-------|
| Vendor | Appwhere |
| Tipo de sistema | `channels` (canal digital de originación) |
| Integración clave | SmartVista (alta de crédito, BB16 Expediente Digital) |
| Tasa ordinaria vigente | **69.4%** (parametrizable) |
| RECA CONDUSEF asignado | **1654-999-037863/09-01070-0526** |
| Duración del plan | 151 días · 22 jun 2026 → 22 ene 2027 |
| Go-live producción | **22 enero 2027** |
| QA Sign-off | 5 enero 2027 |

---

## Flujo de APOLO — 17 Building Blocks

El flujo de originación pasa por 17 BBs en secuencia:

```
BB1  Preparación
  │
BB2  Términos y Condiciones / Aviso de Privacidad
  │
BB3  Validación de Teléfono  ←── OTP · Titularidad · Regla 30 días
  │
BB4  Validación del Cliente   ←── Tipo: titular / prospecto / nuevo
  │
BB5  Perfilamiento             ←── Name Matching (listas negras)
  │
BB6  Validación de Domicilio  ←── Sucursalización corporativa
  │
BB7  KYC / PEP                ←── Familiar con cargo público (listas negras)
  │
BB8  PLD                      ←── Proveedor de recursos (listas negras) · KO si usa dinero de terceros
  │
BB9  Persona Vulnerable        ←── Declaración · Grupo prioritario
  │
BB10 Validación SIC            ←── Buró de Crédito · Círculo de Crédito
  │
BB11 Paramétrico               ←── Decisión crediticia · Referencia (listas negras)
  │
BB12 Oferta de Producto        ←── Tasa 69.4% · CAT calculado · imagen tarjeta (Coltrane)
  │
BB13 Prueba de Vida / Video Selfie
  │
BB14 Solicitud de Servicios Digitales  ←── Popup informativo · Términos servicios digitales
  │
BB15 Validación de Correo
  │
BB16 Integración de Expediente Digital  ←── Firma electrónica · OnBase · SmartVista (alta crédito) · Expediente
  │
BB17 Bienvenida               ←── Confirmación · Correo welcome kit (RECA, contrato PDF, carátula, portada)
```

---

## Catálogo de HDUs — 37 HDUs

### MVP1 — En scope enero 2027 (VoBo + Taggeo)

| ID | Descripción corta | Building Block(s) principal | Fuente/Épica | Status |
|----|-------------------|----------------------------|-------------|--------|
| HDU-TDC-R4-01 | Actualizar tasa ordinaria (69.4%) y CAT en oferta de producto | BB12 Oferta de Producto | Cambio de tasas y contrato | VoBo |
| HDU-TDC-R4-03 | Enviar por correo el contrato vigente al finalizar la firma | BB17 Bienvenida / Correo contractual | Cambio de tasas y contrato | VoBo |
| HDU-TDC-R4-04 | Aplicar Coltrane en bloques iniciales y validación temprana (BB1-BB4) | BB1,BB2,BB3,BB4 | Cambio de marca Fase 2 | VoBo |
| HDU-TDC-R4-05 | Aplicar Coltrane en bloques perfilamiento, riesgo y decisión (BB5-BB11) | BB5,BB6,BB7,BB8,BB9,BB10,BB11 | Cambio de marca Fase 2 | VoBo |
| HDU-TDC-R4-06 | Aplicar Coltrane en oferta, autenticación, expediente y cierre (BB12-BB17) | BB12-BB17 | Cambio de marca Fase 2 | VoBo |
| HDU-TDC-R4-07 | Capturar declaración inicial de persona vulnerable | BB9 Persona Vulnerable | Incluir Persona Vulnerable | VoBo |
| HDU-TDC-R4-08 | Desplegar y guardar opciones de grupo prioritario (responde Sí) | BB9 Persona Vulnerable | Incluir Persona Vulnerable | VoBo |
| HDU-TDC-R4-09 | Mostrar info legal de persona vulnerable y medir eventos del bloque | BB9 / Medición digital | Incluir Persona Vulnerable | Taggeo por Modyo |
| HDU-TDC-R4-10 | Actualizar imagen de tarjeta y textos legales en pantallas clave | BB1,BB12,BB17 | Actualización visual | VoBo |
| HDU-TDC-R4-13 | Validar al solicitante contra listas negras en Perfilamiento | BB5 / Name Matching | Listas negras | VoBo |
| HDU-TDC-R4-14 | Validar al familiar con cargo público contra listas negras (KYC/PEP) | BB7 KYC-PEP / Name Matching | Listas negras | VoBo |
| HDU-TDC-R4-16 | Validar referencia contra listas negras en Paramétrico | BB11 / Name Matching | Listas negras | VoBo |
| HDU-TDC-R4-17 | Presentar pantalla de términos con Contrato Múltiple y Servicios Digitales | BB16 / Formalización y Firma | Contrato servicios digitales | VoBo |
| HDU-TDC-R4-18 | Permitir lectura de documentos y avance a firma electrónica | BB16 / Lectura · Firma | Contrato servicios digitales | VoBo |
| HDU-TDC-R4-19 | Mostrar info de activación de servicios digitales mediante popup | BB14 / Popup | Contrato servicios digitales | VoBo |
| HDU-TDC-R4-20 | Integrar firma, alta de crédito, expediente digital y marcaje | BB16 Firma·SmartVista·OnBase·Expediente | Contrato servicios digitales | VoBo |
| HDU-TDC-R4-21 | Aplicar KO automático cuando prospecto usará dinero de otra persona | BB8 PLD / Proveedor Recursos | Listas negras | VoBo |
| HDU-TDC-R4-22 | Medir Thank You Page de rechazo por proveedor de recursos | BB8 PLD / Medición digital | Medición digital | Taggeo por Modyo |
| HDU-TDC-R4-23 | Validar formato del número celular en preparación y validación teléfono | BB1,BB3,BB4 | Reglas de teléfono | VoBo |
| HDU-TDC-R4-24 | Validar titularidad del celular y disponibilidad por regla de 30 días | BB4 / Titularidad Teléfono | Reglas de teléfono | VoBo |
| HDU-TDC-R4-25 | Cancelar vínculo previo del número cuando originación concluye exitosamente | BB4 / Reasignación Teléfono | Reglas de teléfono | VoBo |
| HDU-TDC-R4-26 | Gestionar reglas del OTP para validación telefónica | BB1,BB4,BB10 / OTP | Reglas de teléfono | VoBo |
| HDU-TDC-R4-27 | Asegurar máscara de SMS BanCoppel en mensajes OTP | BB OTP/SMS/Comunicación | Reglas de teléfono | VoBo |
| HDU-TDC-R4-34 | Asignar sucursal corporativa parametrizable a la TDC BanCoppel | BB6 / Sucursalización | Sucursalización | VoBo |
| HDU-TDC-R4-37 | Implementar medición digital faltante por grupos de BBs | Medición digital · 10 BBs | Medición digital | Taggeo por Modyo |

**Total MVP1: 25 HDUs (22 VoBo + 3 Taggeo)**

### MVP2 — Fuera de alcance enero 2027

| ID | Descripción corta | Razón/Épica |
|----|-------------------|-------------|
| HDU-TDC-R4-02 | Mostrar contrato legal vigente durante formalización | Cambio de tasas (aplaza a MVP2) |
| HDU-TDC-R4-12 | Guardar referencia capturada sin convertirla en cliente prospecto | Observaciones legal |
| HDU-TDC-R4-28 | Iniciar recuperación de solicitud mediante captura de teléfono y OTP | Recuperación solicitud |
| HDU-TDC-R4-29 | Validar OTP de recuperación y controlar errores de captura | Recuperación solicitud |
| HDU-TDC-R4-30 | Resolver retoma según vigencia del prospecto y última etapa | Recuperación solicitud |
| HDU-TDC-R4-31 | Gestionar solicitudes vigentes de otros canales y estatus CN | Recuperación solicitud |
| HDU-TDC-R4-32 | Gestionar retoma en estatus BC y CC con consultas crediticias | Recuperación solicitud |
| HDU-TDC-R4-33 | Resolver retoma de estatus RT, CP, TC y AT según vigencias | Recuperación solicitud |
| HDU-TDC-R4-35 | Identificar clientes titulares, prospectos y nuevos en validación | Sucursalización clientes |
| HDU-TDC-R4-36 | Actualizar registro prospecto tipo 02 y aplicar alcance a onboarding | Onboarding cliente prospecto |

**Total MVP2: 10 HDUs** — la funcionalidad de **Recuperación de Solicitud** (retoma) queda completamente fuera del go-live de enero 2027.

### Desestimadas

| ID | Descripción | Motivo |
|----|-------------|--------|
| HDU-TDC-R4-11 | Reordenar documentos en Expediente conforme a observaciones legales | Desestimada |
| HDU-TDC-R4-15 | Validar proveedor de recursos contra listas negras en PLD | Desestimada |

---

## DTMs — Especificación Técnica (17 servicios identificados en PreGame)

> Fuente: ADP_Onboarding Apolo TDC R4_20260708_Base v1.0.pdf · Página 10

| DTM | Nombre técnico (API) | Tipo | Cal. SA | HDU | Descripción funcional |
|-----|----------------------|------|---------|-----|-----------------------|
| DTM-01 | `REC_RetrieveOfferPricing` | Atómico | 3 | HDU-01 | Actualizar tasa ordinaria y CAT en oferta |
| DTM-02 | `REC_NotifyContractDelivery` | Atómico | 3 | HDU-03 | Enviar contrato vigente al finalizar firma |
| DTM-03 | No aplica | No Aplica | 0 | HDU-04 | Aplicar Coltrane en bloques iniciales (sin servicio nuevo) |
| DTM-04 | No aplica | No Aplica | 0 | HDU-05 | Aplicar Coltrane en perfilamiento y riesgo |
| DTM-05 | No aplica | No Aplica | 0 | HDU-06 | Aplicar Coltrane en oferta, expediente y cierre |
| DTM-06 | `REC_RecordVulnerableCustomerDeclaration` | Orquestado | 8 | HDU-07 | Capturar declaración inicial de persona vulnerable |
| DTM-07 | `REC_RecordPriorityGroupSelection` | Orquestado | 8 | HDU-08 | Guardar opciones de grupo prioritario seleccionado |
| DTM-08 | No aplica | No Aplica | 0 | HDU-10 | Actualizar imagen tarjeta y textos legales |
| DTM-09 | `REC_EvaluateCustomerNameMatching` | Orquestado | 8 | HDU-13 | Validar solicitante contra listas negras PLD |
| DTM-10 | `REC_EvaluatePepRelativeNameMatching` | Orquestado | 8 | HDU-14 | Validar familiar público contra listas negras |
| DTM-11 | `REC_EvaluateReferenceNameMatching` | Orquestado | 8 | HDU-16 | Validar referencia contra listas negras paramétrico |
| DTM-12 | `REC_RecordDigitalAgreement` | Orquestado | 10 | HDU-17 | Presentar términos contrato múltiple y servicios digitales |
| DTM-13 | `REC_RetrieveAgreementDocuments` | Atómico | 3 | HDU-18 | Permitir lectura de documentos y avance a firma |
| DTM-14 | `REC_ProvideDigitalServicesActivationInfo` | No Aplica | 0 | HDU-19 | Mostrar activación servicios digitales mediante popup |
| DTM-15 | `REC_ExecuteCreditContracting` | Orquestado | **12** | HDU-20 | **Integrar firma, alta crédito y expediente digital** — complejidad Alta |
| DTM-16 | `REC_EvaluateThirdPartyFunds` | Regla de Negocio | 1 | HDU-21 | Aplicar KO por dinero de otra persona |
| DTM-17 | `REC_EvaluatePhoneFormat` | Regla de Negocio | 1 | HDU-23 | Validar formato de celular |
| DTM-18 | `REC_EvaluatePhoneOwnership` | Orquestado | 8 | HDU-24 | Validar titularidad celular — regla 30 días |
| DTM-19 | `REC_UpdatePhoneLinkage` | Atómico | 3 | HDU-25 | Cancelar vínculo previo tras originación exitosa |
| DTM-20 | `REC_ExecuteOtpValidation` | Orquestado | 8 | HDU-26 | Gestionar reglas OTP para validación telefónica |
| DTM-21 | `REC_NotifyOtpBanCoppelMask` | Atómico | 3 | HDU-27 | Asegurar máscara BanCoppel en mensajes OTP |
| DTM-22 | `REC_ProvideBranchAssignment` | Atómico | 3 | HDU-34 | Asignar sucursal corporativa parametrizable |

**Resumen de tipos**: Atómico=6 · Orquestado=9 · Regla de Negocio=2 · No Aplica=5 · **Total SA en scope: 98 servicios identificados**

> El DTM de mayor complejidad es `REC_ExecuteCreditContracting` (HDU-20, Cal. SA=12, Alta) — es la API de alta de crédito en SmartVista. Cualquier retraso en este DTM bloquea el go-live.

---

## Critical Breakers del PreGame (identificados por AppWhere)

> Fuente: ADP_Onboarding Apolo TDC R4_20260708_Base v1.0.pdf · Página 15

Condiciones que AppWhere declaró como bloqueadoras absolutas del inicio del proyecto:

| # | Critical Breaker | Estado (estimado al corte) |
|---|-----------------|---------------------------|
| CB1 | Formalización del Plan de Comunicación y Matriz RACI del proyecto (comités Flow Engineering) | 🔄 En proceso |
| CB2 | Certificación y aprobación de Arquitectura (Industria, Seguridad, Integración, Soluciones) — debe resolverse antes de la fase de construcción | 🔴 Fase 9 activa, 105 días |
| CB3 | Resolver estrategia de Branching (repos nuevos/actuales, clusters, token) | 🔄 En proceso |
| CB4 | Revisión y aprobación de alcances y propuestas comerciales por proveedores con WAR correspondiente | 🟡 Pendiente de cerrar |
| CB5 | Revisión y aprobación de alcances de todos los actores en la RACI (internos/externos) — presentar en Kickoff | 🔄 En proceso |
| CB6 | HDUs formalizadas y autorizadas por responsables de Negocio (cerrar alcance funcional) | ✓ 22 HDUs con VoBo |
| CB7 | Asegurar infraestructura y configuración del ambiente — su falta es stopper | 🔴 Riesgo activo (ver R03 cerrado → pendiente confirmar) |
| CB8 | El roadmap final se formaliza hasta que proveedores externos completen análisis, dimensionamiento y cotización post-PreGame | ✓ Plan N4 F2 publicado 05-ago-2026 |

---

## Estructura de Gobierno del Proyecto

> Fuente: ADP_Onboarding Apolo TDC R4_20260708_Base v1.0.pdf · Página 17

| Comité | Participantes | Periodicidad |
|--------|--------------|-------------|
| **Comité de Gobierno Estratégico** | Director General · Operación TI · Sponsor Ejecutivo + SM AppWhere/Modyo/Play Digital | Mensual |
| **Comité de Gobierno Táctico** | Gerente SR Nuevas Tecnologías · Líder Operación TI · Team Lead + SM AppWhere/Modyo/Play Digital | Quincenal |
| **Comité Técnico Especializado** | Equipos habilitadores: Infra, Telecomm, Arquitectura, Continuidad TI, Seguridad, UX/UI + SM AppWhere/Modyo/Play Digital | Bajo demanda |
| **Daily Flow Control** | Equipos de implementación TI + Proveedores + TC + RTE | Lunes a Viernes |
| **Comité Operativo Intermedio** | Equipo técnico + funcional + transversales | Miércoles y viernes |

**Proveedores involucrados**: AppWhere · Modyo (CMS/frontend Coltrane) · Play Digital

---

## Agrupación por Building Block (BBs con más HDUs)

| Building Block | HDUs asociados | Total CAs |
|----------------|---------------|-----------|
| Recuperación de Solicitud | 7 HDUs (todos MVP2) | 31 |
| Validación del Cliente | 6 | 26 |
| Preparación | 5 | 23 |
| Name Matching (listas negras) | 4 | 16 |
| OTP | 4 | 17 |
| PLD | 4 | 16 |
| Persona Vulnerable | 4 | 16 |
| Medición digital | 3 | 13 |
| Oferta de Producto | 3 | 12 |
| Paramétrico | 3 | 13 |
| Perfilamiento | 3 | 13 |
| Solicitud de Servicios Digitales | 3 | 12 |

---

## Plan Integral — 10 Fases

| Fase | Duración | Inicio | Fin | Estado (al 2026-08-16) |
|------|---------|--------|-----|------------------------|
| 1. Inicio y Planeación | 33 días | 22 jun 2026 | 5 ago 2026 | ✓ Completada |
| 2. Análisis — Flow Engineering (BB por BB) | 31 días | 6 ago 2026 | 18 sep 2026 | 🔄 En curso |
| 3. Diseño + Backend por Sprint (13 sprints, ~5 APIs c/u) | 33 días | 11 ago 2026 | 25 sep 2026 | 🔄 Iniciando |
| 4. Desarrollo Frontend (Coltrane HDU-04/05/06/10/19) | 23 días | 25 ago 2026 | 25 sep 2026 | Próximo |
| 5. Integración Stateful/Stateless + WM | 59 días | 11 ago 2026 | 2 nov 2026 | 🔄 Iniciando |
| 6. Preparación de Matrices de Prueba | 20 días | 1 oct 2026 | 28 oct 2026 | Pending |
| 7. Despliegue a QA | 19 días | 12 oct 2026 | 5 nov 2026 | Pending |
| 8. Ejecución QA (pruebas + UAT + automatizadas) | 40 días | 6 nov 2026 | 5 ene 2027 | Pending |
| 9. Certificación de Arquitectura (paralela) | 105 días | 6 ago 2026 | 5 ene 2027 | 🔄 En curso |
| 10. Pase a Producción (4 capas: SpringBoot·MuleSoft/Apigee·Frontend·WM) | 13 días | 6 ene 2027 | 22 ene 2027 | Pending |

### Detalle Sprint Plan — Backend (Fase 3)

| Sprint | Foco | HDUs | APIs |
|--------|------|------|------|
| S1 | Validación Teléfono | 23, 24 | 5 |
| S2 | Validación Teléfono | 26 | 5 |
| S3 | Val. Teléfono / Domicilio / Perfilamiento | 27 | 5 |
| S4 | Perfilamiento / Oferta | — | 5 |
| S5 | Oferta / PEP (KYC) | — | 5 |
| S6 | PEP / PLD | 16 | 5 |
| S7 | PLD / Persona Vulnerable | 16, 17, 07 | 5 |
| S8 | Persona Vulnerable / Expediente | 07, 08, 17 | 5 |
| S9 | Expediente Digital | 17, 18 | 5 |
| S10 | Expediente Digital | 18, 20 | 5 |
| S11 | Expediente Digital | 20, 25 | 5 |
| S12 | Expediente Digital | 20, 25 | 5 |
| S13 | Expediente Digital / Bienvenida | 25 | 3 |

**~63 APIs en 13 sprints** — la Integración de Expediente Digital (BB16) consume los 6 sprints finales.

---

## Integración APOLO → SmartVista

La integración crítica entre APOLO y SmartVista sucede en **HDU-TDC-R4-20** (BB16):

```
Firma Electrónica completada
  │
  ├── Alta de crédito → SmartVista (SVIP)
  │     ├── Creación de cuenta TDC en SmartVista
  │     └── Asignación de límite de crédito
  │
  ├── Expediente Digital → OnBase
  │     └── Documentos firmados
  │
  └── Marcaje (taggeo) de visualización
```

> Esta HDU es el **punto de integración más crítico de APOLO** — es donde el prospecto se convierte en cliente con tarjeta activa. Un fallo aquí bloquea el go-live completo.

---

## Mapeo a Capabilities Unity

| Capability Unity | Building Blocks APOLO | HDUs principales |
|-----------------|----------------------|-----------------|
| CAP-CUSTOMER-PROFILE | BB4 Validación Cliente · BB5 Perfilamiento · BB7 KYC-PEP · BB8 PLD · BB10 SIC · BB9 Persona Vulnerable | 07, 08, 13, 14, 21, 34, 35 |
| CAP-AUTHENTICATION | BB3 Validación Teléfono · OTP · Titularidad | 23, 24, 25, 26, 27 |
| CAP-CARD-LIFECYCLE | BB17 Bienvenida (alta en SV) | 20 (integración crítica) |
| CAP-BALANCE-STATEMENT | BB12 Oferta de Producto (tasa, CAT) | 01 |
| CAP-FEE-COMMISSION | BB17 correo (tabla de comisiones, carátula) | 01, 03 |
| CAP-CHANNEL-SELFSERVICE | N/A — APOLO es canal digital propio, no IVR | — |
| CAP-ERROR-CATALOG | Estatus CN/BC/CC/RT/CP/TC/AT (retoma) | 31-33 (MVP2) |

---

## Hallazgos de Compliance

| Hallazgo | Detalle | DT relacionado |
|----------|---------|----------------|
| **RECA CONDUSEF** | 1654-999-037863/09-01070-0526 — contrato múltiple de crédito para persona física | dt-compliance |
| **Welcome Kit** | Correo tras onboarding incluye: contrato múltiple + tabla de comisiones + carátula + portada de tarjeta + contrato de servicios digitales + carátula de servicios digitales | dt-compliance |
| **Tasa 69.4%** | Parametrizable en BD — cumplimiento marco normativo CONDUSEF | dt-compliance |
| **Contrato servicios digitales** | Requiere términos + firma + popup informativo antes de activar | dt-compliance |

---

## Hallazgos de Equipo

| Persona | Rol | Fuente |
|---------|-----|--------|
| **Josué Rosales Chimal** | Flow Engineering Lead (AppWhere) — responsable de metodología PreGame | ADP_Onboarding |
| **Isrrael Murillo Contreras** | PM del proyecto (AppWhere) | ADP_Onboarding |
| **Brenda Itzel Espinoza González** | Lead Funcional (AppWhere) | ADP_Onboarding |
| **Oscar de los Santos** | Lead Dev — desarrollo backend APIs (AppWhere) | ADP_Onboarding |
| **Ignacio Cayetano** | Tech Lead — arquitectura técnica (AppWhere) | ADP_Onboarding |
| **Gabriel Montoya** | Lead UX/UI | ADP_Onboarding |
| **Enrique Gutiérrez** | Lead (rol por confirmar — arquitectura o integración) | ADP_Onboarding |
| Eduardo Guzmán | PM APOLO / BanCoppel | Plan_Integral |
| Brenda Espinosa | PM técnico / BanCoppel | Plan_Integral |
| Alejandra Mayela | Análisis funcional (AppWhere) | Plan_Integral |
| LPFE, LSTIB | Roles abreviados de recursos AppWhere | Tabla_asignación |

---

## Riesgos Identificados

| Riesgo | Descripción | Impacto |
|--------|-------------|---------|
| **BB16 / HDU-20** | La integración Firma → SmartVista → OnBase es la más compleja y consume los últimos 6 sprints backend — cualquier retraso en SmartVista bloquea el cierre | Go-live |
| **Recuperación de Solicitud** (MVP2) | Las 7 HDUs de retoma quedan fuera — un prospecto que abandona a mitad del flujo pierde su solicitud | Experiencia usuario post go-live |
| **Taggeo por Modyo** | 3 HDUs dependen de Modyo (plataforma externa de CMS) para el taggeo — dependencia no del vendor Appwhere | Medición digital |
| **Certificación Arquitectura (Fase 9)** | 105 días, paralela a todo el desarrollo — si la certificación no aprueba antes del 5-ene, bloquea el pase a producción | Go-live |
| **4 capas de despliegue** | SpringBoot + MuleSoft/Apigee + Frontend + WM — 4 capas independientes en 13 días (6-22 ene) | Go-live |
| **APOLO latencia P95** | Actualmente en 9,000ms producción vs SLO de 5,000ms — ya out-of-SLO antes del go-live R4 | SLO go-live |

> El riesgo de latencia APOLO está registrado en `dt-slo-observabilidad`: APOLO actualmente corre a 9,000ms en producción, SLO objetivo para R4 es P95 ≤ 5,000ms.

---

## Tensión de Fechas — APOLO vs Producto TDC P4900

| Fecha | Evento | Sistema |
|-------|--------|---------|
| **06 ene 2027** | Inicia pase a producción APOLO (4 capas) | APOLO |
| **15 ene 2027** | **Go-Live TDC P4900** — fecha objetivo del programa | Producto |
| **22 ene 2027** | Cierre formal del proyecto APOLO | APOLO |

El **pase a producción de APOLO inicia el 6-ene y dura 13 días** (termina 22-ene). Si el go-live del producto es el 15-ene, APOLO llevaría solo **9 días de despliegue** — sin margen para resolución de incidencias. Esta tensión requiere decisión explícita del programa: ¿go-live parcial sin APOLO completamente desplegado, o ajuste de fecha objetivo?

---

## DATO-REQUERIDO

1. ¿Cuántas APIs exactas tiene APOLO hoy en producción (pre-R4)? El plan habla de ~63 nuevas APIs en los 13 sprints.
2. Roles LPFE y LSTIB — ¿qué persona/empresa representan?
3. ¿Cuándo fue la Fase 1 completada formalmente (kick-off actaado)?
4. ¿El Coltrane Design System es el mismo que usa AppMovil o es una instancia separada para APOLO?
5. ¿OnBase es un sistema de BanCoppel (ya en producción) o nuevo en R4?
6. Resultado del análisis de arquitectura (PDI) — ¿ya tiene pre-certificación?
7. ¿WM (Work Manager) en Fase 5 y 10 es un componente de Appwhere o de BanCoppel?

---

*Creado: 2026-08-16 — v1.0.0 · Digital Twin APOLO Originación Digital Unity R4*
*Actualizado: 2026-08-17 — v1.1.0 · +17 DTMs con nombres técnicos REC_* · +8 Critical Breakers PreGame · +Perfiles equipo AppWhere · +Estructura gobierno · +Tensión fechas APOLO vs producto*
*Fuentes: APOLO_R4_HDU_TDC.xlsm (37 HDUs) · Plan_Integral_Apolo_R4_VF3_050826.xls (10 fases, 13 sprints) · ADP_Onboarding Apolo TDC R4_20260708_Base v1.0.pdf (PreGame) · Plan Apolo N4 F2-05082026 V1.pdf (Gantt detallado)*
