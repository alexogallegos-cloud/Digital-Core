# RFP-PAG v2.6 — Requisitos del Motor de Pagos MONEX
> Fuente: RFP-PAG v2.6 · 27-Ago-2026 · Confidencial — Restringido
> Owner: Architecture Board / Design Authority — Rafael Pereda (Sponsor)

---

## Timeline del Proceso

| Hito | Fecha | Estado |
|------|-------|--------|
| Emisión del RFP | 27-Ago-2026 | DONE |
| Confirmación de participación + NDA | 01-Sep-2026 | DONE |
| Preguntas y respuestas | 04-Sep-2026 | DONE |
| Respuestas oficiales | 11-Sep-2026 | DONE |
| **Entrega de propuesta** | **18-Sep-2026** | **DONE** |
| Evaluación inicial y shortlist | 24-Sep-2026 | IN_PROGRESS |
| **Demostraciones** | **28-Sep-2026** | **PENDIENTE — 6 días** |
| Due Diligence y Negociación | 05-Oct-2026 | PENDIENTE |
| Decisión y notificación | 09-Oct-2026 | PENDIENTE |

**ATENCIÓN**: La propuesta ya fue entregada (18-Sep). Hoy 22-Sep estamos en evaluación/shortlist.
El siguiente hito crítico son las **demostraciones del 28-Sep**.

---

## Modelo de Propuesta — Joint Vendor + SI

El RFP requiere una propuesta conjunta:

| Rol | Responsabilidad |
|-----|-----------------|
| **Platform Vendor** | Producto (Temenos / Form3 / Volante / Finastra) |
| **Systems Integrator** | Implementación, Fit-to-Standard, diseño, configuración, integración, migración, pruebas, cutover, adopción, seguridad y estabilización |

**Accenture = SI**. El vendor se confirma en la propuesta. El SI lidera la relación con MONEX.

---

## Alcance Geográfico (4+1)

| Geografía | Rieles de Pago | Reguladores |
|-----------|---------------|-------------|
| **México** | SPEI, SPID, CoDi, DIMO | Banxico, CNBV, CONDUSEF, UIF |
| **USA** | ACH, Fedwire | FinCEN, Federal Reserve |
| **UK** | Faster Payments, CHAPS | FCA — **DORA activo desde Jan 2025** |
| **España/EU** | SEPA, ISO 20022 | CNMV, Banco de España, ECB |
| **Cross-border** | SWIFT, CBPR+, UETR, corresponsales | SWIFT, CLS Bank |

---

## Requisitos Funcionales Críticos (R-F)

| ID | Categoría | Descripción | Evidencia Requerida |
|----|-----------|-------------|---------------------|
| R-F01 | Configuración | Administrar productos, monedas, entidades, rieles, calendarios, cut-offs, cargos y reglas mediante configuración con control de versiones — sin duplicar el core. | Demo + configuración global/local |
| R-F02 | Iniciación multi-canal | Recibir instrucciones por APIs, H2H, archivos, canales, operaciones asistidas, Treasury y FX, normalizando a modelo común. | Demo end-to-end |
| R-F03 | Pagos masivos y tiempo real | Procesar pagos individuales, lotes y pagos inmediatos con control de volúmenes, prioridad e idempotencia. | Demo + prueba de carga |
| R-F04 | Autorizaciones | Controles maker-checker multi-nivel, poderes, firmas, límites y SoD por entidad, monto, producto, canal y riesgo. | Demo + escenarios positivos/negativos |
| R-F05 | Validación y enriquecimiento | Validar sintaxis, semántica, cliente, cuenta, beneficiario, banco, fondos, fecha valor, ISO 20022 y datos regulatorios. | Demo + catálogo de reglas |
| R-F06 | Controles externos | Orquestar sanciones, PLD/FT, fraude y límites con bloqueo/liberación/rechazo, código de razón y evidencia. | Demo |
| R-F07 | Enrutamiento | Seleccionar riel y corresponsal basado en costo, urgencia, riesgo, liquidez, disponibilidad y SLA, preservando la justificación. | Demo + política de enrutamiento |
| R-F08 | Fallback seguro | Cambiar ruta solo cuando el resultado previo está controlado, manteniendo idempotencia, no duplicación y evidencia. | Escenario de falla |
| R-F09 | Clearing y Settlement | Generar mensajes nativos, validar y transmitir, capturar ACK/NACK, estatus e identificadores, mantener vinculación con cuentas de liquidación. | Demo en simulador o riel real |
| R-F10 | Cross-border | Soportar SWIFT/CBPR+, UETR, redes de banca corresponsal, partes, cargos OUR/SHA/BEN y trazabilidad. | Demo internacional |
| R-F11 | Integración FX | Recibir ID de operación, monedas, montos y fechas valor sin recalcular los economics; solicitar conversión/entrega. | Demo FX→pago |

---

## Requisitos No Funcionales Críticos (R-N)

| ID | Categoría | Descripción |
|----|-----------|-------------|
| R-N01 | Capacidad | Demostrar throughput sostenido, picos y procesamiento batch con controles y trazabilidad habilitados. |
| R-N02 | Latencia | Medir p95/p99 para recepción, validación y enrutamiento bajo condiciones reproducibles. |
| R-N03 | Disponibilidad | Clases de servicio y arquitectura para alcanzar disponibilidad acordada por relevancia. |
| R-N04 | RTO/RPO | Cumplir y probar RTO<2h y RPO<5min por servicio sin pérdida de integridad ni duplicación. |
| R-N05 | Tolerancia a fallos | Continuar o degradar de forma controlada ante fallo de componente, zona, dependencia o riel de pago. |
| R-N06 | Seguridad | Integrar IAM/MFA, RBAC/ABAC, mTLS, cifrado, vault, hardening y sesiones privilegiadas. |
| R-N07 | Privacidad | Clasificar, minimizar, enmascarar, retener y eliminar datos por finalidad y jurisdicción. |
| R-N08 | APIs/Eventos | Soportar OpenAPI/AsyncAPI, versionado, compatibilidad, idempotencia, replay y gobernanza de esquemas. |
| R-N09 | Observabilidad | Proporcionar logs estructurados, métricas, trazas, IDs de correlación, health checks, alertas y runbooks. |
| R-N10 | DevSecOps | Soportar CI/CD, IaC, testing automatizado, segregación de entornos y rollback. |
| R-N12 | Auditabilidad | Generar registro exportable e inmutable de cada transacción, control, mensaje, acceso, decisión y resolución. |
| R-N13 | Observabilidad+ | Logs, métricas, trazas, compatibilidad SIEM, monitoreo 24x7, activo-activo, OWASP secure coding. |

---

## Requisitos Regulatorios y de Cumplimiento (R-R)

| ID | Categoría | Descripción |
|----|-----------|-------------|
| R-R01 | Aplicabilidad | Mantener matriz de obligaciones por entidad legal, país, producto, riel de pago y tipo de pago. |
| R-R02 | Partes y trazabilidad | Transmitir y retener ordenantes, beneficiarios, instituciones, intermediarios y autorizaciones. |
| R-R03 | Sanciones y PLD/FT | Ejecutar controles previos a la liberación, retener listas/versiones y gestionar decisiones y casos. |
| R-R04 | Registros y auditoría | Retener instrucciones, mensajes, decisiones, registros de acceso y evidencia con integridad verificable. |
| R-R05 | Protección de datos | Controlar minimización, residencia, acceso transfronterizo, sub-procesadores y derechos aplicables. |
| R-R06 | Rieles de pago locales | Cumplir reglas, mensajes, calendarios y reportes para cada riel por geografía. |

---

## Requisitos de IA (AI-01 a AI-12)

| ID | Capability | Descripción |
|----|-----------|-------------|
| AI-01 | Detección de anomalías | Modelos explicables y versionados con features, umbrales, decisiones, códigos de razón y monitoreo. |
| AI-02 | Copiloto operativo | Consulta de estatus de pago, evidencia, procedimientos y próximas acciones con fuentes citadas y sin ejecución no autorizada. |
| AI-03 | Conciliación e investigación | Detección de diferencias, correlación de evidencia y propuesta de causa/acción para aprobación humana. |
| AI-04 | Liquidez y capacidad | Pronósticos por moneda, entidad, cuenta y riel de pago; predicción de picos, colas y degradación. |
| AI-05 | Enrutamiento inteligente | Recomendaciones basadas en costo, liquidez, disponibilidad, riesgo y SLA, sujetas a reglas obligatorias. |
| AI-06 | RAG y conocimiento | Búsqueda semántica sobre políticas, manuales, contratos y conocimiento, con citas, permisos y aislamiento. |
| AI-07 | AI Gateway y multi-modelo | Control central de modelos, acceso, cuotas, políticas, observabilidad, costos y portabilidad. |
| AI-08 | MLOps / LLMOps | Registro, evaluación, aprobación, despliegue, monitoreo, drift, rollback y retiro de modelos/prompts. |
| AI-09 | IA Responsable | Evaluación de impacto, explicabilidad, sesgo, Human-in-the-Loop, auditabilidad y límites de autonomía. |
| AI-10 | Seguridad de IA | Protección contra prompt injection, fuga de datos, abuso de herramientas y outputs inseguros. |
| AI-11 | Fallback | Fallback a reglas, modelo alternativo o proceso humano donde la disponibilidad o confianza sea insuficiente. |
| AI-12 | IA en Delivery | Aceleración controlada de diseño, desarrollo, pruebas y documentación con controles de propiedad intelectual. |

---

## Modelo de Evaluación

### Stage Gates G1-G6

| Gate | Criterio |
|------|----------|
| G1 | Revisión de propuesta y elegibilidad |
| G2 | Evaluación técnica (PAG-D07 v0.2) |
| G3 | Evaluación de IA (40 requisitos) |
| G4 | Evaluación de seguridad y cumplimiento |
| G5 | Evaluación comercial (TCO 5 años) |
| G6 | Evaluación de implementación y experiencia |

### Escala de Scoring 0-4

| Valor | Interpretación |
|-------|---------------|
| 4 | Excede los requisitos con evidencia verificable |
| 3 | Cumple completamente los requisitos con evidencia |
| 2 | Cumple parcialmente — gaps documentados |
| 1 | Cumple mínimamente — riesgo alto de implementación |
| 0 | No cumple |

### Factores de Cobertura

| Tipo | Factor |
|------|--------|
| Standard (nativo) | 1.00 |
| Configurable | 0.95 |
| Extension (customización guiada) | 0.80 |
| External Integration | 0.70 |
| Bespoke (desarrollo a medida) | 0.50 |
| Roadmap (futuro) | 0.25 |
| Not Covered | 0.00 |

> "El precio será relevante, pero no compensará deficiencias críticas en cumplimiento regulatorio, seguridad, integridad financiera o resiliencia." — RFP-PAG v2.6 §13.1

---

## 10 Escenarios de Demostración (D-01 a D-10)

Para las demostraciones del **28-Sep-2026**:

| Escenario | Descripción |
|-----------|-------------|
| D-01 | Configuración: alta de producto + calendario + cut-off en entorno multi-entidad |
| D-02 | Pago SPEI — flujo completo desde iniciación multicanal hasta confirmación |
| D-03 | Pago SWIFT — cross-border con UETR, cargos OUR/SHA/BEN y trazabilidad |
| D-04 | Sanciones — bloqueo, escalamiento, caso y liberación con evidencia |
| D-05 | Enrutamiento inteligente — selección de riel por costo/liquidez/SLA |
| D-06 | Fallback seguro — cambio de ruta con idempotencia garantizada |
| D-07 | Batch/Bulk — procesamiento masivo con prioridad y control de colas |
| D-08 | Conciliación — detección de diferencia y propuesta de ajuste con AI |
| D-09 | Dashboards — monitoring end-to-end en tiempo real por geografía y riel |
| D-10 | AI Copiloto — consulta de estatus de pago con RAG y sin ejecución no autorizada |

---

*RFP-PAG v2.6 · 27-Ago-2026 · Confidencial — Restringido*
*Cargado en brain: 2026-09-22*
