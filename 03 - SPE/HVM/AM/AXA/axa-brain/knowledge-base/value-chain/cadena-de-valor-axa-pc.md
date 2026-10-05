# Cadena de Valor — AXA México · P&C Commercial Lines
> AXA Seguros S.A. de C.V. · Líneas Comerciales de Daños
> Última actualización: 2026-09-03 · v1.0
> Marco de referencia: ETB Insurance P&C v3.0 + Competitive Discovery Suscripción Daños

---

## Diagrama de la Cadena de Valor

```
┌──────────────────────────────────────────────────────────────────────────────────┐
│                        CADENA DE VALOR — AXA P&C COMMERCIAL LINES               │
├──────────┬──────────┬──────────────┬──────────┬──────────┬──────────┬───────────┤
│  C1      │   C2     │    C3        │   C4     │   C5     │   C6     │    C7     │
│ DISEÑO   │ DISTRIBU-│ SUSCRIPCIÓN  │ EMISIÓN  │ REINTE-  │SINIESTROS│ COBRANZA  │
│PRODUCTO  │  CIÓN    │ / UNDERWRIT. │ PÓLIZA   │ GRACIÓN  │          │ PRIMAS    │
│          │          │              │          │          │          │           │
│ Nota     │  SINCO   │  Vector      │ General  │  SAFAC   │   ???    │   ???     │
│ Técnica  │ Conductos│  + HSD ⚠️    │  Daños   │          │          │           │
│ ERN(cat) │          │  SINCO       │          │  ERN     │          │           │
│          │          │  ERN         │          │          │          │           │
│  D6.2    │ D1/D2/D4 │    D6.3      │   D6.4   │   D6.1   │   D6.5   │   D6.1   │
│ PARTIAL  │  PARTIAL │  PARTIAL⚠️   │  PARTIAL │  PARTIAL │ SCAFFOLD │ SCAFFOLD  │
└──────────┴──────────┴──────────────┴──────────┴──────────┴──────────┴───────────┘

━━━━━━━━━━━━━━━━━━━━━━ ACTIVIDADES DE SOPORTE ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  S1 · ACTUARÍA Y RESERVAS         ERN (catastrófico) + Por confirmar (reservas)
  S2 · REASEGURO                   SAFAC · ERN  [ETB D6.1 Reinsurance]
  S3 · ANALYTICS Y BI              Power BI (acceso fragmentado)
  S4 · REGULATORIO (CNSF)          Monitor (tentativo) + Por confirmar
  S5 · FINANZAS (IFRS 17)          Por confirmar
  S6 · TECNOLOGÍA E INTEGRACIÓN    Sin API gateway · Sin event bus
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ HSD = Gap crítico: cálculo técnico de suscripción en Excel, sin sistema real
??? = Sistemas por confirmar
```

---

## Actividades Primarias — Detalle

### C1 · Diseño de Producto y Pricing
**¿Qué hace?** Define qué riesgos acepta AXA, bajo qué condiciones, con qué coberturas y a qué precio base. Para Commercial Lines esto implica: notas técnicas por ramo, tarifas de referencia, reglas de suscripción, catálogos de productos en General Daños.

| Elemento | Detalle |
|----------|---------|
| ETB | D6.2 Product Management |
| Sistemas AXA | Nota Técnica (documento, no sistema) · ERN para pricing catastrófico · General Daños (catálogos de productos) |
| Regulación | Nota Técnica registrada ante CNSF · Circular Única de Seguros y Fianzas |
| Estado | PARTIAL — no se identificó sistema de gestión de productos; las notas técnicas son documentos manuales |
| Gap | Sin sistema de product lifecycle management; cambios de tarifa requieren coordinación manual con CNSF |
| LoB aplicable | Todos (Property, RT, RC, Marítimo, Aviación, OA, LF) |

---

### C2 · Distribución y Gestión de Intermediarios
**¿Qué hace?** Gestiona la red de agentes, corredores y conductos. Incluye onboarding, comisiones, desempeño por canal, y la recepción de solicitudes de cotización.

| Elemento | Detalle |
|----------|---------|
| ETB | D1 Channel Mgmt. · D2 Distribution Mgmt. · D4 Sales Mgmt. |
| Sistemas AXA | SINCO (registro de cuentas, antecedentes, conductos) · Sin portal de agentes confirmado |
| Canales | Agentes · Corredores · Brokers internacionales (para facultativo) |
| Estado | PARTIAL — SINCO cubre solo búsqueda por razón social + dirección; sin identificador confiable de intermediario |
| Gap principal | Sin portal de agentes; coordinación por correo / Teams / WhatsApp sin trazabilidad |
| Gap secundario | SINCO no es un CRM completo: sin pipeline, sin tracking de oportunidades, sin gestión de comisiones |
| Cobertura descubrimiento | Proceso documentado en 541 pasos — rol del conducto aparece en fase de Preparación |

---

### C3 · Suscripción / Underwriting
**¿Qué hace?** Evalúa el riesgo individual, calcula la tarifa técnica, negocia las condiciones con el asegurado/corredor, y decide aceptar, rechazar o condicionar el riesgo.

**Es la actividad más documentada del brain: 541 pasos de proceso en 7 LoBs.**

| Elemento | Detalle |
|----------|---------|
| ETB | D6.3 Underwriting & Pricing (14 sub-capacidades L3) |
| Sistemas AXA | Vector (workflow de folios) · HSD-Excel (cálculo técnico ⚠️) · SINCO (antecedentes) · ERN (modelación catastrófica) · Power BI (siniestralidad histórica) |
| Estado | PARTIAL con GAP CRÍTICO — Vector gestiona el flujo, pero el cálculo técnico vive en Excel |
| Gap central | **HSD** no es un sistema: es una Hoja de Suscripción de Daños en Excel. Sin integración con Vector, ERN ni SAFAC. Sin control de versiones, sin trazabilidad, sin API. |
| Fases del proceso | Preparación → Evaluación del Riesgo → Modelación Catastrófica → Definición Cotización → Negociación |
| LoBs cubiertas | Property · Ramos Técnicos · RC · Marítimo · Aviación · Obras de Arte · Líneas Financieras |
| Pain points | 26 de 33 pain points aplican a esta actividad |
| DT dedicado | `dt-underwriting-intelligence/` — poblado con 541 pasos + 26 pain points |

**Sub-capacidades ETB con mayor brecha:**

| ETB ID | Capacidad | Estado AXA |
|--------|-----------|-----------|
| 6.3.2 | Risk Assessment & Rating | **GAP** — HSD Excel |
| 6.3.4 | Quote Management | **GAP** — sin sistema |
| 6.3.5 | Negotiation & Placement | **GAP** — correo/WhatsApp |
| 6.3.3 | Catastrophe Modelling | PARTIAL — ERN sin integración automática |
| 6.3.1 | Risk Information Management | PARTIAL — SINCO limitado |

---

### C4 · Emisión y Gestión de Póliza
**¿Qué hace?** Captura las condiciones aprobadas en suscripción, emite la póliza, gestiona endosos, renovaciones y cancelaciones durante la vigencia.

| Elemento | Detalle |
|----------|---------|
| ETB | D6.4 Policy Admin & Serving |
| Sistemas AXA | General Daños (sistema de emisión confirmado) |
| Estado | PARTIAL — sistema confirmado, pero con limitaciones de integración |
| Gap principal | **Recaptura manual**: las condiciones aprobadas en suscripción (Vector + HSD) se reteclean en General Daños. No hay integración automática entre el expediente de suscripción y el sistema de emisión. |
| Gap secundario | Fallas técnicas en catálogos de productos en General Daños (identificado en proceso) |
| DT dedicado | `dt-policy-lifecycle/` — CLAUDE.md definido, contenido pendiente |

---

### C5 · Reaseguro
**¿Qué hace?** Protege a AXA de pérdidas catastróficas o de gran tamaño cediendo parte del riesgo a reaseguradores internacionales. Para Commercial Lines, principalmente facultativo (riesgo por riesgo).

| Elemento | Detalle |
|----------|---------|
| ETB | D6.1 Cross Capability — Reinsurance |
| Sistemas AXA | SAFAC (Sistema de Reaseguro Facultativo) · ERN (base técnica de la cesión) |
| Estado | PARTIAL — SAFAC confirmado pero con limitaciones estructurales |
| Gap principal | SAFAC solo soporta estructura lineal: sin carga masiva de capas ni múltiples reaseguradores por capa |
| Gap secundario | Sin integración SAFAC ↔ HSD: las condiciones técnicas de la cesión se trasladan manualmente |
| DT dedicado | `dt-reinsurance-program/` — CLAUDE.md definido |

---

### C6 · Gestión de Siniestros
**¿Qué hace?** Atiende el siniestro desde la primera notificación (FNOL), coordina el ajuste, autoriza el pago y cierra el expediente.

| Elemento | Detalle |
|----------|---------|
| ETB | D6.5 Claims |
| Sistemas AXA | **Sin confirmar** — ningún sistema de siniestros fue identificado en el Competitive Discovery |
| Estado | **SCAFFOLD** — sin datos |
| Dato requerido | Nombre del sistema de siniestros, mapeo de proceso, roles, tiempos |
| Impacto en brain | dt-claims-lifecycle no puede poblarse sin fuente adicional |
| Importancia estratégica | Alta — siniestros es donde se materializa la promesa de la póliza y donde más se genera NPS |

---

### C7 · Cobranza y Recaudación de Primas
**¿Qué hace?** Cobra las primas a los asegurados, gestiona la morosidad, concilia pagos y maneja fraccionamiento de prima.

| Elemento | Detalle |
|----------|---------|
| ETB | D6.1 Cross Capability — Billing |
| Sistemas AXA | **Sin confirmar** — `billing` es scaffold |
| Estado | **SCAFFOLD** — sin datos |
| Dato requerido | Sistema de facturación y cobranza; integración con General Daños y bancos |

---

## Actividades de Soporte — Detalle

### S1 · Actuaría y Reservas Técnicas
| Elemento | Detalle |
|----------|---------|
| ETB | D6.3 Underwriting & Pricing (pricing) · D7.1 Finance (reservas) |
| Sistemas | ERN (catastrófico, confirmado) · Sistema de reservas: por confirmar · Pricing de ramos simples: por confirmar |
| Estado | PARTIAL — ERN confirmado; resto por mapear |
| Relevancia regulatoria | Solvencia C · IFRS 17 · CNSF nota técnica |

### S2 · Reaseguro Proporcional y No Proporcional
La diferencia con C5: C5 cubre el facultativo (riesgo a riesgo). S2 cubre los tratados proporcionales
y no proporcionales (XL, stop-loss) que protegen la cartera global. Ambos usan SAFAC o herramientas
complementarias (por confirmar).

### S3 · Analytics, BI y Datos
| Elemento | Detalle |
|----------|---------|
| ETB | D8 Data & Analytics (fuera de D6) |
| Sistemas | Power BI (confirmado — siniestralidad histórica) · Datawarehouse: por confirmar |
| Estado | PARTIAL — Power BI activo pero acceso fragmentado; sin DW confirmado |
| Gap | Sin single source of truth de datos; cada área accede a datos de forma independiente |

### S4 · Regulatorio y Cumplimiento (CNSF)
| Elemento | Detalle |
|----------|---------|
| ETB | D7.2 Regulatory Reporting · D9 Compliance |
| Sistemas | Monitor (tentativo) · Por confirmar para reservas, Solvencia C, IFRS 17 |
| Estado | PARTIAL — Monitor sin rol confirmado |
| Regulación aplicable | CNSF Circular Única · Solvencia C · IFRS 17 · CONDUSEF · Ley ISR |

### S5 · Finanzas y Reporting al Grupo
| Elemento | Detalle |
|----------|---------|
| ETB | D7.1 Finance & Accounting |
| Sistemas | Por confirmar — consolidación resultado técnico, reporting AXA Group |
| Estado | SCAFFOLD |
| Relevancia | IFRS 17 tiene fecha de obligatoriedad; impacta contabilidad de contratos de seguro |

### S6 · Tecnología e Integración
| Elemento | Detalle |
|----------|---------|
| ETB | D10 Technology Infrastructure · D11 Data & AI Platform |
| Sistemas | API Gateway: scaffold · Event Bus: scaffold · Datawarehouse: scaffold |
| Estado | SCAFFOLD — capa de integración no documentada |
| Gap | Los sistemas confirmados (Vector, SINCO, ERN, SAFAC, General Daños, Power BI) no tienen integración conocida entre sí. Cada intercambio es manual. |

---

## Cobertura del Discovery por Actividad

| Actividad | Cobertura actual | Fuente | DT |
|-----------|-----------------|--------|-----|
| C1 Diseño Producto | Baja — solo menciones indirectas | Competitive Discovery Suscripción | — |
| C2 Distribución | Media — SINCO identificado, sin portal | Competitive Discovery | dt-distribution-network |
| **C3 Suscripción** | **Alta — 541 pasos, 26 pain points** | **Competitive Discovery** | **dt-underwriting-intelligence ✓** |
| C4 Emisión Póliza | Media — General Daños confirmado, sin proceso | Competitive Discovery | dt-policy-lifecycle |
| C5 Reaseguro | Media — SAFAC confirmado, limitaciones claras | Competitive Discovery | dt-reinsurance-program |
| C6 Siniestros | **Nula — sin datos** | Sin fuente | dt-claims-lifecycle |
| C7 Cobranza | Nula — sin datos | Sin fuente | — |
| S1 Actuaría | Baja — ERN identificado | Competitive Discovery | dt-regulatory-solvency |
| S3 Analytics/BI | Media — Power BI confirmado | Competitive Discovery | dt-financial-reporting |
| S4 Regulatorio | Baja — Monitor tentativo | Competitive Discovery | dt-regulatory-solvency |

---

## La Pregunta Central de Transformación

AXA México P&C Commercial Lines tiene una cadena de valor donde **la actividad más crítica
(suscripción) opera con una herramienta que no es un sistema**. El HSD concentra el conocimiento
técnico del negocio en un Excel que no puede escalar, no puede auditarse y no puede integrarse.

**La transformación no es "modernizar los sistemas". Es construir la cadena de valor que hoy
no existe como tal**: un flujo continuo desde la solicitud del intermediario hasta la póliza emitida,
con datos fluyendo automáticamente entre evaluación del riesgo, modelación catastrófica,
cotización técnica, negociación y emisión.

La cadena hoy tiene 6 eslabones; funciona como 6 islas con puentes manuales entre ellas.

---

## Matriz Calor — Brecha vs. Impacto

| Actividad | Brecha tecnológica | Impacto al negocio | Prioridad |
|-----------|-------------------|-------------------|-----------|
| C3 Suscripción (HSD) | 🔴 Muy alta | 🔴 Muy alto | **1** |
| C6 Siniestros | 🔴 Sin datos | 🔴 Muy alto (promesa) | **2** |
| C4 Emisión → Integración | 🟠 Alta | 🟠 Alto | **3** |
| C2 Distribución (portal) | 🟠 Alta | 🟠 Alto | **4** |
| C5 Reaseguro | 🟡 Media | 🟡 Medio | **5** |
| S6 Integración | 🔴 Muy alta | 🟠 Alto (habilitador) | **6** |
| S4 Regulatorio | 🟡 Media | 🔴 Alto (IFRS 17) | **7** |
| C7 Cobranza | Sin datos | 🟡 Medio | **8** |
| C1 Diseño Producto | Baja | 🟡 Medio | **9** |

---

*Última actualización: 2026-09-03 · v1.0 · Basado en ETB Insurance P&C v3.0 + Competitive Discovery Suscripción Daños (541 pasos, 33 pain points, 8 sistemas reales identificados)*