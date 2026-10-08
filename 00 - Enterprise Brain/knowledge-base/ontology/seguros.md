# Ontología Base — Seguros
> Enterprise Brain · Knowledge Base · Ontología de Negocio por Industria
> Versión 1.0 · 2026-10-08 · Digital Core · Accenture México

Clientes del estate: **AXA**

---

## Identidad

| Campo | Valor |
|-------|-------|
| `system_info.industry` | `seguros` |
| `system_info.brain_name` canónico | `insurance-brain` |
| Industry SME | `SME/Industry/Industry Insurance/` (v2.0 — ACORD + todos los ramos + CNSF/IFRS 17) |
| **Eje raíz: LOB / Ramo** | La ontología de seguros es ramo-first — todo parte del tipo de seguro antes que del proceso |

---

## Dimensión LOB / Ramo

A diferencia de banca y retail, en seguros el **ramo** es el eje raíz: el proceso de suscripción de un seguro de auto es fundamentalmente distinto al de un seguro de vida. Sin ramo no hay proceso correcto.

| Ramo | `lob` canónico | Regulación específica |
|------|---------------|----------------------|
| Daños (P&C) | `pc` | CNSF — Reservas de daños, reaseguro proporcional |
| Vida + Accidentes y Enfermedades (Vida-AP) | `vida_ap` | CNSF — Reservas matemáticas, IFRS 17 grupos de contratos |
| Salud / Gastos Médicos Mayores (GMM) | `gmm` | CNSF · SSA — Cobertura mínima, reembolso vs. red |
| Fianzas | `fianzas` | CNSF · SHCP — Fianza de fidelidad, judicial, empresa |
| Agrícola | `agricola` | CNSF · SAGARPA — Paramétrico vs. indemnizatorio |
| Crédito a la Vivienda | `credito_vivienda` | CNSF · CONAVI | Aplica si el cliente opera con instituciones de vivienda |

### Cómo se usa en brain.db

```sql
-- system_info
lob_dimension  = 'ramo'     -- declara que el eje raíz es el ramo

-- capabilities
lob            = 'pc'       -- cada capability L3 lleva su ramo
                             -- capabilities transversales llevan lob = 'all'

-- regulatory_obligations
ramo           = 'pc'       -- la obligación aplica a ese ramo específico
```

---

## Modelo de Capabilities

### ETB Seguros — Estructura L1/L2 por Ramo

| L1 | L2 (principales) | Aplica a ramos | Tablas brain.db |
|----|-----------------|----------------|-----------------|
| **Customer & Distribution** | Agentes · Corredores · Bancassurance · Digital · Autoservicio | todos | `capabilities` · `stakeholders` · `journeys` |
| **Product Design & Pricing** | Tarificación actuarial · Modelado de riesgo · Reaseguro diseño · Lanzamiento | todos | `capabilities` · `rules` (fórmulas actuariales) |
| **Origination & Underwriting** | Cotización · Suscripción · Inspección de riesgo · Aceptación/rechazo | pc · vida_ap · gmm · fianzas | `capabilities` · `journeys` · `rules` |
| **Policy Management** | Emisión · Endoso · Renovación · Cancelación · Portabilidad | todos | `capabilities` · `components` · `rules` |
| **Claims & Benefits** | Aviso de siniestro · Ajuste · Valuación · Liquidación · Salvamento · Subrogación | pc · gmm | `capabilities` · `journeys` · `rules` |
| **Life Benefits & Annuities** | Suma asegurada · Invalidez · Fallecimiento · Rescate · Beneficiarios | vida_ap | `capabilities` · `rules` (tablas de mortalidad) |
| **Reinsurance** | Cesión · Facultativo · Proporcional · XL · Finito | todos | `capabilities` · `external_systems` |
| **Finance & Reserving** | Reservas técnicas · IFRS 17 · Resultado técnico · Retrocesión | todos | `capabilities` · `regulatory_obligations` · `data_entities` |
| **Compliance & Regulatory** | CNSF reporting · Solvencia II (grupos europeos) · IFRS 17 · AML | todos | `capabilities` · `regulatory_obligations` |
| **Technology & Infrastructure** | Core de pólizas · Core de siniestros · Portales · APIs ACORD | todos | `technology_components` · `itom_layer` |

### ACORD Standards

Usado en: AXA y todo asegurador con integración con reaseguradoras o corredores internacionales.

| ACORD Standard | Área | Relevancia en brain.db |
|---------------|------|------------------------|
| ACORD XML / AL3 | Intercambio de datos de pólizas | `data_entities` · `external_systems` |
| ACORD 103 (Life) | Datos de aplicación de vida | `rules` · `journeys` |
| ACORD 125 (P&C Application) | Solicitud de seguro de daños | `journeys` · `rules` |
| ACORD RMSIG | Gestión de riesgo | `capabilities` |

---

## Ontología de Procesos

`process_ontology` en `system_info`: `insurance-mx-{ramo}` (ej. `insurance-mx-pc`)

### L1 — Ciclo de la Póliza (universal a todos los ramos)

| L1 | L2 (principales) | Ramo | Regulador rector |
|----|-----------------|------|-----------------|
| **Prospección & Distribución** | Cotización · Presentación · Canal (agente/corredor/digital) | todos | CNSF (registro de intermediarios) |
| **Suscripción** | Evaluación de riesgo · Underwriting · Inspección · Aceptación/Rechazo | pc · fianzas | CNSF (límites de retención, tarifas autorizadas) |
| **Emisión** | Generación de póliza · Endosos iniciales · Entrega · Cobranza primer recibo | todos | CNSF (texto de póliza autorizado) · CONDUSEF (nota técnica) |
| **Servicio en Vigencia** | Endosos · Cambios de beneficiarios · Portabilidad · Renovación | todos | CNSF · CONDUSEF |
| **Siniestros & Beneficios** | Aviso · Asignación de ajustador · Valuación · Dictamen · Liquidación · Subrogación | pc · gmm | CNSF (plazos de respuesta Circ. S-18.3) |
| **Vida & Beneficios** | Suma asegurada · Invalidez total · Rescate · Supervivencia · Fallecimiento | vida_ap | CNSF (tablas de mortalidad CNSF-2000K) |
| **Reaseguro** | Cesión automática · Facultativo · Recupero de siniestros · Estado de cuenta RAS | todos | CNSF · AMIS |
| **Reservas & IFRS 17** | Cálculo de reservas · GMM (grupos de contratos) · CSM (Contractual Service Margin) · LRC/LIC | todos | CNSF · IASB/IFRS 17 |
| **Cumplimiento & Reporting** | Estados financieros CNSF · Solvencia · Estadísticas AMIS · AML | todos | CNSF · UIF |
| **Cancelación & Fin de Cobertura** | Cancelación por mora · Devolución de prima · Finiquito | todos | CNSF · CONDUSEF |

---

## Reguladores Rectores

### Mapa Regulatorio Seguros México

| Regulador | Tipo | Jurisdicción | Tablas brain.db afectadas |
|-----------|------|-------------|--------------------------|
| **CNSF** | Prudencial + conducta | Toda institución aseguradora y afianzadora en México | `regulatory_obligations` · `capabilities` · `rules` · `data_entities` |
| **CONDUSEF** | Protección al usuario | Transparencia de pólizas, RESBA (seguros), Buró de Entidades, disputas | `regulatory_obligations` · `rules` (texto de cláusulas) |
| **IASB / IFRS 17** | Contable internacional | Reconocimiento y medición de contratos de seguro | `regulatory_obligations` · `rules` (reservas, CSM) · `data_entities` (grupos de contratos) |
| **UIF** | Inteligencia financiera (SHCP) | PLD/FT en aseguradoras (primas altas, siniestros inusuales) | `regulatory_obligations` · `rules` (AML) |
| **SAT / SHCP** | Fiscal | CFDI de primas · Deducibilidad de seguros de gastos médicos · BEPS | `regulatory_obligations` · `data_entities` |
| **AMIS** | Estadística sectorial | Estadísticas de mercado, tarificación referencial | `knowledge_gaps` (cuando faltan datos de mercado) |
| **IMSS / SSA** | Salud pública | Aplica a GMM: red de hospitales, coberturas mínimas | `regulatory_obligations` (solo ramo GMM) |

### Instrumentos Normativos Clave

| Instrumento | Emisor | Impacto en brain.db |
|-------------|--------|---------------------|
| **LISF — Ley de Instituciones de Seguros y Fianzas** | Congreso | Marco general: solvencia, reservas, reaseguro · `regulatory_obligations` (obligaciones de la institución) |
| **Circular S-18.3 (Plazos de atención de siniestros)** | CNSF | Plazos de respuesta en `rules` · SLA en `slos` · `kpis` (tiempo de liquidación) |
| **Circular S-22.1 (Inversiones y solvencia)** | CNSF | Restricciones de inversión de reservas · `kpis` (SCR, MCR) |
| **IFRS 17 — Implementation** | CNSF + IASB | Grupos de contratos · GMM · CSM · `data_entities` (entidades contables) · `rules` (fórmulas de reserva) |
| **Tablas de Mortalidad CNSF-2000K** | CNSF | Gold en `rules` (fórmulas actuariales de vida) · irrefutables porque son regulación publicada |
| **Disposiciones ALD/FT para Aseguradoras** | UIF | KYC de asegurados con primas altas · `rules` (umbrales) |
| **Ley Federal de Protección de Datos (LFPDPPP)** | INAI | Datos sensibles de salud en GMM · `data_entities.sensitivity_level` |
| **ACORD Standards (adopción de mercado)** | ACORD | Interoperabilidad con reaseguradoras internacionales · `external_systems` · `data_entities` |

---

## Cadena de Valor — Seguros

### Top-down: Producto → Código

```
products                  ← Seguro de auto · Seguro de vida · GMM · Fianza de empresa
    │  (lob: pc / vida_ap / gmm / fianzas)
    ▼
kpis                      ← Loss ratio · Combined ratio · Retention rate · NPS · Reservas/SCR
    │
    ▼
processes                 ← Suscripción · Siniestros · Reservas · Distribución
    │  (process_id incluye ramo: P-SINP-001 = siniestro P&C)
    ▼
capabilities (ETB L3)     ← "Valuación de daños" · "Cálculo CSM" · "Asignación de ajustador"
    │
    ▼
components/rules          ← Fórmulas actuariales · tablas de mortalidad · motores de tarificación
    │  (rules.reg → Circular S-18.3 / IFRS 17 / LISF artículo N)
    ▼
technology_components     ← Core de pólizas · Core de siniestros · DWH actuarial
    │
    ▼
itom_layer                ← Technology Operations · Information & Analytics
```

### Bottom-up: Infra → KPI

```
itom_layer (technology-operations)
    → technology_components (Core pólizas · Core siniestros · DWH IFRS 17)
        → components (motores de tarificación · módulos de reserva · APIs ACORD)
            → rules (fórmulas: prima pura · reserve técnica · CSM · tablas mortalidad)
                → processes (Suscripción P&C · Reservas IFRS 17 · Siniestros GMM)
                    → kpis (Loss ratio · Combined ratio · SCR · Tiempo liquidación)
                        → products (Seguro auto · GMM · Vida entera)
```

### Correlación Regulatoria Clave

Una regla que calcula la reserva IBNR de siniestros de auto toca:
- `regulatory_obligations`: CNSF Circular S-22.1 (metodología de reservas) + IFRS 17 (GMM group)
- `rules.reg`: marcado con instrumento específico y artículo
- `knowledge_lineage.tier`: gold (fórmula publicada en circular) o silver (interpretación actuarial)
- `kpis`: impacta Loss Ratio y Solvency Capital Requirement

---

## ITOM — Dominios Predominantes en Seguros

| Dominio ITOM | Hemisferio | Sub-capacidades clave en seguros | Casos de uso de IA |
|-------------|-----------|--------------------------------|-------------------|
| `technology-operations` | Run | Core pólizas ops · Core siniestros · Batch actuarial nocturno | RCA en liquidaciones · runbooks de cierre contable |
| `information-analytics` | Ambos | Gobierno de datos · Reporting CNSF · IFRS 17 cálculos | Automatización estadísticas · detección anomalías en reservas |
| `delivery` | Change | APIs ACORD · Modernización de core · Digital channels | Generación de specs ACORD · casos de prueba suscripción |
| `it-management` | Ambos | Risk & Compliance (CNSF) · FinOps · AML | Mapeo LISF → código · trazabilidad reservas → regulación |
| `customer-engagement` | Ambos | Portales de agentes · Autoservicio · Claims tracking | UX desde journeys reales de siniestros |

---

## Cómo Usar en brain.db

### `system_info` (fields específicos de seguros)

```sql
industry         = 'seguros'
brain_name       = 'insurance-brain'    -- solo si es enterprise
industry_sme     = 'SME/Industry/Industry Insurance/'
capability_model = 'etb'               -- ETB P&C / Life / GMM según ramos activos
process_ontology = 'insurance-mx-pc'   -- por ramo principal del cliente
lob_dimension    = 'ramo'              -- campo propio de seguros
regulator        = 'CNSF'             -- regulador principal
```

### `ontology_bindings` (entradas típicas para una aseguradora multi-ramo)

```sql
-- P&C / Daños
(model_type='etb', catalog='Insurance_ETB_PC_v3.0', role='primary',
 regulators='["CNSF","CONDUSEF"]', lob='pc')
-- Vida + AP
(model_type='etb', catalog='Insurance_ETB_Life_v2.0', role='primary',
 regulators='["CNSF","IASB"]', lob='vida_ap')
-- GMM
(model_type='etb', catalog='Insurance_ETB_Life_v2.0', role='primary',
 regulators='["CNSF","IMSS"]', lob='gmm')
-- Modelo propio del cliente (AXA pattern)
(model_type='client-logical', catalog='AXA_Operating_Model', role='secondary')
-- TI
(model_type='itom', catalog='ITOM_v9.0', role='primary', regulators='[]')
```

---

## Del Estate — Lo que los Brains Reales Usan

| Cliente | Ramos activos | model_type(s) | Particularidad |
|---------|--------------|--------------|----------------|
| AXA México | P&C · Vida-AP · GMM | `etb` + `client-logical` | AXA tiene modelo operativo propio (AXA P&C) como capa adicional; IFRS 17 en implementación |

---

*Ontología Base Seguros · Enterprise Brain Knowledge Base · v1.0 · 2026-10-08*
