# Cobertura de los DTs Canónicos

> Versión 1.0 · 2026-10-05 · Regla B41 · ADR-EB-011 · Asset Enterprise Brain · Digital Core

Este documento es **artefacto verificable**, no descriptivo. Si un proceso del IT Operating Model o una regla de pipeline queda sin DT dueño, es hallazgo bloqueante del Brain Auditor. Si dos DTs reclaman lo mismo, es solapamiento que se resuelve con ADR.

Los 24 DTs canónicos se dividen en tres categorías con sistemas de coordenadas distintos. Confundirlas es lo que deja huecos estructurales.

> **`[ADR-EB-016]`** Estas 24 filas son el **roster exigible**: responsabilidades que ningún brain puede dejar sin dueño. Lo que se audita es cobertura de rol, no coincidencia de nombre de carpeta. Los DTs de dimensión de cada brain no entran aquí y no se enumeran.

| Categoría | Razona sobre | Se mide contra | DTs |
|-----------|-------------|----------------|-----|
| **A. Rol de TI** | La organización de TI del cliente | Los 38 procesos canónicos del IT Operating Model v9.0 | 10 |
| **B. Ingeniería del brain** | El brain como producto | El Brain Lifecycle, las reglas de pipeline P1 a P5 y las capas de arquitectura | 5 |
| **C. Negocio** | El modelo de negocio del cliente | Los 7 dominios L1 comunes a los catálogos de industria, más la identidad de la empresa | 9 |

**El modelo es de negocio, la evidencia es de TI, y la brecha es el hallazgo.** Esa es la razón de tener las dos caras. La categoría C declara qué dice el modelo de la industria; la categoría A aporta lo que el código demuestra. Una capability que el modelo exige y ningún componente cubre es brecha de negocio. Un componente que no mapea a ninguna capability es deuda sin propósito. Un proceso modelado que el código ejecuta de otra forma es la divergencia más reveladora de cualquier modernización. Es la Regla B20 generalizada.

---

## Categoría A — Cobertura de los 38 procesos ITOM

Catálogo de referencia: `SME/Framework/IT Operating Model` (ITOM v9.0 Accelerator Pack, 38 procesos en 6 dominios). El brain no inventa este catálogo (Regla B23).

### Dominio 1 — Customer and Ecosystem Engagement

| # | Proceso | DT dueño |
|---|---------|----------|
| 1 | Business Demand Management | `dt-demand-manager` |
| 2 | Service Level Management | `dt-change-manager` fija el target; `dt-service-operations-lead` mide el current |
| 3 | Service Portfolio Management | `dt-demand-manager` |
| 4 | Commercial Services Management | `dt-supplier-relationship-manager` |
| 5 | Strategic Partner Management | `dt-supplier-relationship-manager` |

### Dominio 2 — IT Strategy

| # | Proceso | DT dueño |
|---|---------|----------|
| 6 | Digital Strategy Formulation | `dt-domain-architect` |
| 7 | Technology Strategy Formulation | `dt-domain-architect` |
| 8 | Innovation Management | `dt-domain-architect` |
| 9 | Investment Planning | `dt-demand-manager` |
| 10 | Enterprise Architecture Planning and Governance | `dt-domain-architect` |

### Dominio 3 — Product / Service Delivery

| # | Proceso | DT dueño |
|---|---------|----------|
| 11 | Architecture Development | `dt-domain-architect` |
| 12 | User Experience Design | `dt-demand-manager` |
| 13 | Demand and Supply Management | `dt-programme-manager` |
| 14 | Planning and Scheduling | `dt-programme-manager` |
| 15 | Service Introduction Management | `dt-change-manager` |
| 16 | Release and Deployment Management | `dt-change-manager` |
| 17 | Programme and Project Management | `dt-programme-manager` |
| 18 | Quality Management | `dt-brain-auditor` |

### Dominio 4 — Technology Operations

| # | Proceso | DT dueño |
|---|---------|----------|
| 19 | Service Request Management | `dt-service-operations-lead` |
| 20 | Access Management | `dt-it-risk-manager` |
| 21 | Service Catalogue Management | `dt-service-operations-lead` |
| 22 | Service Monitoring and Reporting | `dt-service-operations-lead` |
| 23 | Incident Management | `dt-service-operations-lead` |
| 24 | Problem Management | `dt-service-operations-lead` |
| 25 | Event Management | `dt-service-operations-lead` |
| 26 | Provisioning Management | `dt-asset-configuration-manager` |
| 27 | Change Management | `dt-change-manager` |
| 28 | Asset and Configuration Management | `dt-asset-configuration-manager` |
| 29 | Capacity Management | `dt-service-operations-lead` |
| 30 | Availability Management | `dt-service-operations-lead` |
| 31 | Business Continuity and Disaster Recovery | `dt-it-risk-manager` |
| 32 | Technical Security Management | `dt-it-risk-manager` |

### Dominio 5 — Information and Analytics

| # | Proceso | DT dueño |
|---|---------|----------|
| 33 | Data Governance | `dt-information-architect` |
| 34 | Insights Generation | `dt-information-architect` |
| 35 | Knowledge Management | `dt-knowledge-manager` |

### Dominio 6 — IT Management

| # | Proceso | DT dueño |
|---|---------|----------|
| 36 | Technology Financial Management | `dt-demand-manager` |
| 37 | Risk and Compliance Management | `dt-it-risk-manager` |
| 38 | Talent and Change Management | `dt-knowledge-manager` |

### Verificación de categoría A

| Métrica | Valor |
|---------|-------|
| Procesos cubiertos | **38 de 38** |
| Procesos sin DT dueño | 0 |
| Procesos compartidos | 1, el proceso 2, compartido por diseño (Reglas B24 y B36) |

Dos asignaciones las fija el propio ITOM v9.0 y no son criterio del canon: el proceso 8 corresponde al Domain Architect y el 34 al Information Architect, según el catálogo de 46 roles del SME.

Carga por DT: `dt-service-operations-lead` 9 procesos, `dt-domain-architect` 5, `dt-demand-manager` 5, `dt-it-risk-manager` 4, `dt-change-manager` 4, `dt-programme-manager` 3, `dt-information-architect` 2, `dt-knowledge-manager` 2, `dt-asset-configuration-manager` 2, `dt-supplier-relationship-manager` 2, `dt-brain-auditor` 1. El desbalance es correcto: Technology Operations es el dominio más denso del modelo con 14 procesos, y es el más relevante para sistemas heredados en producción (Regla B23).

---

## Categoría B — Cobertura del Brain Lifecycle y del pipeline

Estos DTs no cubren procesos del cliente. Cubren el brain como producto.

### Reglas de pipeline

| Regla | Qué dice | DT dueño |
|-------|----------|----------|
| **P1** | Flujo `source/` a `knowledge-base/` a `digital-brain/` | `dt-build-operator` |
| **P2** | Idempotencia dura, rebuild determinista | `dt-build-operator` |
| **P3** | Marks de alta confianza no se sobreescriben | `dt-build-operator` |
| **P4** | Portal generado siempre, nunca escrito a mano | `dt-brain-engineer` |
| **P5** | `brain.db` en `.gitignore` | `dt-brain-engineer` |

### Reglas de conocimiento que requieren operador humano

| Regla | Qué dice | DT dueño del modelo | DT que opera el flujo |
|-------|----------|--------------------|-----------------------|
| **B37** | Calidad y linaje del conocimiento | `dt-knowledge-manager` | `dt-human-reviewer` |
| **B39** | Niveles de autonomía A0 a A3 | `dt-change-manager` define el catálogo | `dt-human-reviewer` rutea la aprobación |
| **B40** | Bi-temporalidad, los dos relojes | `dt-knowledge-manager` | `dt-build-operator` al cargar |

La separación entre modelo y operación es deliberada. `dt-knowledge-manager` define qué nivel tiene cada afirmación y cuál es su linaje; `dt-human-reviewer` consigue que la persona correcta mire lo correcto en el momento correcto. Son dos trabajos distintos y el segundo es el cuello de botella real.

### Fases del Brain Lifecycle

| Fase | DT dueño | DTs que contribuyen |
|------|----------|--------------------|
| DISCOVER — Brain Bootstrap | `dt-build-operator` | `dt-domain-architect`, `dt-demand-manager`, `dt-it-risk-manager` |
| DESIGN — Knowledge Architecture | `dt-domain-architect` | `dt-information-architect`, `dt-change-manager` |
| BUILD — Brain Population | `dt-build-operator` | `dt-human-reviewer`, todos los de dimensión |
| TEST — Brain Validation | `dt-brain-auditor` | `dt-brain-engineer` |
| RELEASE — Brain Activation | `dt-brain-auditor` | `dt-human-reviewer`, `dt-brain-engineer` |
| OPERATE — Brain-First Delivery | Todos los de categoría A | `dt-human-reviewer` |
| OBSERVE — Brain Health | `dt-brain-auditor` | `dt-knowledge-manager` mide la latencia de B40 |
| ITERATE — Brain Evolution | `dt-build-operator` | `dt-brain-engineer` |

### Definition of Done

| DoD | Criterio | DT responsable |
|-----|----------|----------------|
| DoD-EB-01 | Pipeline idempotente, nunca hand-crafted | `dt-build-operator` |
| DoD-EB-02 | Cero business_name vacíos o genéricos | `dt-build-operator` sintetiza, `dt-human-reviewer` valida |
| DoD-EB-03 | Clase clasificada en 100% de reglas | `dt-build-operator` |
| DoD-EB-04 | Regulación anotada en 100% de reglas | `dt-build-operator`, `dt-it-risk-manager` valida |
| DoD-EB-05 | Brain Auditor PASS | `dt-brain-auditor` |
| DoD-EB-06 | Seeds emitidos a todos los vecinos | `dt-build-operator` |
| DoD-EB-07 | Portal generado desde `brain.db` | `dt-brain-engineer` |
| DoD-EB-08 | `brain.py` expone la interfaz estándar | `dt-brain-engineer` |
| DoD-EB-09 | Taxonomía del cliente como hilo conductor | `dt-domain-architect` |
| DoD-EB-10 | bank-brain federado actualizado | `dt-domain-architect` |

### Verificación de categoría B

| Métrica | Valor |
|---------|-------|
| Reglas de pipeline cubiertas | 5 de 5 |
| Fases del Brain Lifecycle con dueño | 8 de 8 |
| Criterios de DoD con responsable | 10 de 10 |

---

## Categoría C — Cobertura de los dominios L1 de negocio

No existe un marco de capacidades de negocio agnóstico de industria publicado en el ecosistema: se verificó que no hay APQC ni Process Classification Framework en ninguno de los tres ecosistemas, y el único SME de negocio tipo Framework, Business Process & Journey, aporta metodología (BPMN, journey mapping, process mining, value stream) y no taxonomía.

Por eso estos ocho dominios **se destilaron de los catálogos de industria existentes**, no se inventaron. Fuentes: Banking ETB V5.0, el marco ACORD de seguros con taxonomía L1 a L4, ETB P&C v3.0, ETB Health Payer v6.0 y la cadena de valor de retail.

| DT | Dominio L1 | Banca | Seguros | Retail |
|----|-----------|-------|---------|--------|
| `dt-channel-owner` | Canales e interacción | 1. Channel Management | D2 Distribución y Canales | SELL omnicanal |
| `dt-distribution-owner` | Distribución, marketing y ventas | 2. Marketing & Sales | D2 intermediarios | PLAN y SELL |
| `dt-product-owner` | Producto y servicio | 3. Product and Service, diseño y catálogo: 3.1 | D1 Producto y Actuaría | PLAN y BUY |
| `dt-customer-owner` | Gestión de cliente | 7. Customer & Partner Mgmt | D3 Gestión de Cliente | SERVICE y lealtad |
| `dt-operations-owner` | Operaciones del core | 3. Product and Service, lado operativo: 3.2 a 3.18 | D4 Pólizas, D5 Cobranza, D6 Siniestros | MOVE |
| `dt-enterprise-functions-owner` | Funciones de empresa | 5. Enterprise Functions | D8 Finanzas y Regulatorio | Finanzas y personas |
| `dt-business-support-owner` | Soporte corporativo | 4. Business Support | **[PENDIENTE]** | **[PENDIENTE]** |
| `dt-sustainability-owner` | Sostenibilidad, ética e inclusión | 6. Responsible Business | **[PENDIENTE]** | **[PENDIENTE]** |

### Verificación de categoría C

| Métrica | Valor |
|---------|-------|
| Dominios L1 con DT dueño | 6 de 6 |
| Dominios con evidencia en 3 o más catálogos de industria | 6 de 6 |
| Dominio con etiqueta textual en 3 de 4 catálogos | Funciones de empresa, el de mayor respaldo |

**Dos candidatos excluidos, con su razón.** Socios y ecosistema aparece en solo dos de los cuatro catálogos y se absorbe en distribución, porque en seguros el distribuidor es el socio y en retail el proveedor vive en BUY; los proveedores de tecnología son otro objeto y pertenecen a `dt-supplier-relationship-manager`. Analítica de negocio aparece también en dos de cuatro, y el lado de TI ya la cubre con `dt-information-architect` vía el proceso 34. Incluirlos habría significado inflar el roster con evidencia de dos de cuatro, que es el umbral que ADR-EB-009 obligó a documentar como excepción.

**El dominio es genérico, su contenido lo especializa cada industria.** Tal como lo enuncia el SME de Seguros, el modelo de capacidades es independiente del ramo y lo que cambia son los procesos y las reglas dentro de cada capacidad. Ningún DT de negocio inventa el catálogo de su industria: lo toma del Industry SME declarado en `system_info.industry_sme` (Regla B19).

---

## Propiedad del schema

La propiedad funciona en **dos ejes**. Las categorías A y B poseen tablas, en vertical. La categoría C posee dominios dentro de esas tablas, en horizontal. La intersección es una celda, no una tabla, y por eso las tres categorías conviven sin que ninguna tabla cambie de dueño.

| Eje | Quién | Qué posee | Ejemplo |
|-----|-------|-----------|---------|
| **Vertical, por tabla** | Categorías A y B | La estructura y la semántica de la tabla completa | `dt-demand-manager` responde por la estructura de `products` y `kpis` |
| **Horizontal, por dominio** | Categoría C | El contenido de negocio de su dominio L1, atravesando varias tablas | `dt-customer-owner` responde por las capabilities, procesos, productos y KPIs del L1 de gestión de cliente |

Cada tabla tiene exactamente un DT dueño en el eje vertical. La propiedad es sobre la **estructura y la semántica**, no sobre el contenido.

| DT | Tablas que posee |
|----|-----------------|
| `dt-domain-architect` | `system_info`, `ontology_bindings`, `capabilities`, `itom_layer`, `decisions`, `plateaus`, `federated_brains` |
| `dt-information-architect` | `data_entities`, `component_data`, `vocabulary` |
| `dt-knowledge-manager` | `knowledge_lineage`, `knowledge_gaps`, `queries`, `stakeholders`, `documents`, `rule_enrichment_log`, la columna `tier` en toda tabla |
| `dt-asset-configuration-manager` | `components`, `component_calls`, `technology_components`, `cross_dependencies`, `external_systems`, `rules`, `component_capabilities`, `component_processes` |
| `dt-change-manager` | `transitions`, `readiness_gates`, el campo `target` de `slos` |
| `dt-service-operations-lead` | `findings`, `signals`, el campo `current` de `slos`, `measurements` en su dimensión de servicio |
| `dt-it-risk-manager` | `regulatory_obligations`, `risks`, la columna `reg` de `rules`, la política de confidencialidad de B42 y la clasificación de `data_entities` |
| `dt-demand-manager` | `products`, `kpis`, `processes`, `journeys`, `costs`, `measurements` en su dimensión de negocio |
| `dt-programme-manager` | `applications`, `waves`, `user_stories` |
| `dt-supplier-relationship-manager` | `suppliers` |
| `dt-build-operator` | Los extractores, `build-brain.py`, `digital-brain/seeds/` |
| `dt-brain-engineer` | `generators/`, `templates/`, `brain.py`, `build-portal.py`, las vistas de homologación |
| `dt-human-reviewer` | La cola de validación, `validated_by`, el registro de aprobaciones |
| `dt-brain-auditor` | Las 10 dimensiones. Audita todo y no posee ninguna tabla de contenido |
| `dt-source-steward` | `source_catalog` (tabla CORE desde ADR-EB-014); filas `gap_type='source'` en `knowledge_gaps`; clasificación canónica de tier por tipo de fuente |
| `dt-client-intelligence` | `company_profile`, `business_milestones`, `strategic_drivers`, `driver_links` · las filas de `measurements` ancladas a `company_profile` (ADR-EB-015) |

### Las tres capas de propiedad

Cinco tablas de conocimiento se reparten entre varias capas y conviene explicitarlo: `rules`, `component_capabilities`, `component_processes`, `rule_enrichment_log` y `federated_brains`. Tienen dueño vertical en la tabla de arriba desde ADR-EB-011, y aun así su contenido lo llena otra capa. El modelo tiene tres capas y cada una responde de algo distinto:

| Capa | Quién | De qué responde |
|------|-------|-----------------|
| Estructura | Los 10 DTs de categoría A | Las tablas del CORE y de extensión, su semántica y su anclaje a la cadena de valor |
| Extracción | Los DTs de dimensión de cada brain (`dt-reglas`, `dt-journeys`, `dt-vocabulario`, `dt-almas`) | El contenido que llena esas tablas |
| Calidad | `dt-knowledge-manager`, `dt-human-reviewer` y `dt-brain-auditor` | El nivel de certeza, el linaje, la validación humana y la auditoría |

Así `rules` no queda huérfana: la llena `dt-reglas`, la ancla `dt-demand-manager` a su proceso y producto, responde por su nivel `dt-knowledge-manager`, consigue su validación `dt-human-reviewer` y la audita `dt-brain-auditor`.

---

*Artefacto verificable del asset Enterprise Brain · Regla B41 · ADR-EB-011 · Accenture México*
