# Cobertura de los DTs Canónicos

> Versión 1.0 · 2026-10-05 · Regla B41 · ADR-EB-011 · Asset Enterprise Brain · Digital Core

Este documento es **artefacto verificable**, no descriptivo. Si un proceso del IT Operating Model o una regla de pipeline queda sin DT dueño, es hallazgo bloqueante del DT-Validador. Si dos DTs reclaman lo mismo, es solapamiento que se resuelve con ADR.

Los 20 DTs canónicos se dividen en tres categorías con sistemas de coordenadas distintos. Confundirlas es lo que deja huecos estructurales.

| Categoría | Razona sobre | Se mide contra | DTs |
|-----------|-------------|----------------|-----|
| **A. Rol de TI** | La organización de TI del cliente | Los 38 procesos canónicos del IT Operating Model v9.0 | 10 |
| **B. Ingeniería del brain** | El brain como producto | El Brain Lifecycle y las reglas de pipeline P1 a P5 | 4 |
| **C. Negocio** | El modelo de negocio del cliente | Los 6 dominios L1 comunes a los catálogos de industria | 6 |

**El modelo es de negocio, la evidencia es de TI, y la brecha es el hallazgo.** Esa es la razón de tener las dos caras. La categoría C declara qué dice el modelo de la industria; la categoría A aporta lo que el código demuestra. Una capability que el modelo exige y ningún componente cubre es brecha de negocio. Un componente que no mapea a ninguna capability es deuda sin propósito. Un proceso modelado que el código ejecuta de otra forma es la divergencia más reveladora de cualquier modernización. Es la Regla B20 generalizada.

---

## Categoría A — Cobertura de los 38 procesos ITOM

Catálogo de referencia: `SME/Framework/IT Operating Model` (ITOM v9.0 Accelerator Pack, 38 procesos en 6 dominios). El brain no inventa este catálogo (Regla B23).

### Dominio 1 — Customer and Ecosystem Engagement

| # | Proceso | DT dueño |
|---|---------|----------|
| 1 | Business Demand Management | `dt-valor` |
| 2 | Service Level Management | `dt-cambio` fija el target; `dt-operacion` mide el current |
| 3 | Service Portfolio Management | `dt-valor` |
| 4 | Commercial Services Management | `dt-proveedores` |
| 5 | Strategic Partner Management | `dt-proveedores` |

### Dominio 2 — IT Strategy

| # | Proceso | DT dueño |
|---|---------|----------|
| 6 | Digital Strategy Formulation | `dt-arquitectura` |
| 7 | Technology Strategy Formulation | `dt-arquitectura` |
| 8 | Innovation Management | `dt-arquitectura` |
| 9 | Investment Planning | `dt-valor` |
| 10 | Enterprise Architecture Planning and Governance | `dt-arquitectura` |

### Dominio 3 — Product / Service Delivery

| # | Proceso | DT dueño |
|---|---------|----------|
| 11 | Architecture Development | `dt-arquitectura` |
| 12 | User Experience Design | `dt-valor` |
| 13 | Demand and Supply Management | `dt-entrega` |
| 14 | Planning and Scheduling | `dt-entrega` |
| 15 | Service Introduction Management | `dt-cambio` |
| 16 | Release and Deployment Management | `dt-cambio` |
| 17 | Programme and Project Management | `dt-entrega` |
| 18 | Quality Management | `dt-validador` |

### Dominio 4 — Technology Operations

| # | Proceso | DT dueño |
|---|---------|----------|
| 19 | Service Request Management | `dt-operacion` |
| 20 | Access Management | `dt-riesgo` |
| 21 | Service Catalogue Management | `dt-operacion` |
| 22 | Service Monitoring and Reporting | `dt-operacion` |
| 23 | Incident Management | `dt-operacion` |
| 24 | Problem Management | `dt-operacion` |
| 25 | Event Management | `dt-operacion` |
| 26 | Provisioning Management | `dt-configuracion` |
| 27 | Change Management | `dt-cambio` |
| 28 | Asset and Configuration Management | `dt-configuracion` |
| 29 | Capacity Management | `dt-operacion` |
| 30 | Availability Management | `dt-operacion` |
| 31 | Business Continuity and Disaster Recovery | `dt-riesgo` |
| 32 | Technical Security Management | `dt-riesgo` |

### Dominio 5 — Information and Analytics

| # | Proceso | DT dueño |
|---|---------|----------|
| 33 | Data Governance | `dt-informacion` |
| 34 | Insights Generation | `dt-informacion` |
| 35 | Knowledge Management | `dt-conocimiento` |

### Dominio 6 — IT Management

| # | Proceso | DT dueño |
|---|---------|----------|
| 36 | Technology Financial Management | `dt-valor` |
| 37 | Risk and Compliance Management | `dt-riesgo` |
| 38 | Talent and Change Management | `dt-conocimiento` |

### Verificación de categoría A

| Métrica | Valor |
|---------|-------|
| Procesos cubiertos | **38 de 38** |
| Procesos sin DT dueño | 0 |
| Procesos compartidos | 1, el proceso 2, compartido por diseño (Reglas B24 y B36) |

Dos asignaciones las fija el propio ITOM v9.0 y no son criterio del canon: el proceso 8 corresponde al Domain Architect y el 34 al Information Architect, según el catálogo de 46 roles del SME.

Carga por DT: `dt-operacion` 9 procesos, `dt-arquitectura` 5, `dt-valor` 5, `dt-riesgo` 4, `dt-cambio` 4, `dt-entrega` 3, `dt-informacion` 2, `dt-conocimiento` 2, `dt-configuracion` 2, `dt-proveedores` 2, `dt-validador` 1. El desbalance es correcto: Technology Operations es el dominio más denso del modelo con 14 procesos, y es el más relevante para sistemas heredados en producción (Regla B23).

---

## Categoría B — Cobertura del Brain Lifecycle y del pipeline

Estos DTs no cubren procesos del cliente. Cubren el brain como producto.

### Reglas de pipeline

| Regla | Qué dice | DT dueño |
|-------|----------|----------|
| **P1** | Flujo `source/` a `knowledge-base/` a `digital-brain/` | `dt-pipeline` |
| **P2** | Idempotencia dura, rebuild determinista | `dt-pipeline` |
| **P3** | Marks de alta confianza no se sobreescriben | `dt-pipeline` |
| **P4** | Portal generado siempre, nunca escrito a mano | `dt-ingenieria` |
| **P5** | `brain.db` en `.gitignore` | `dt-ingenieria` |

### Reglas de conocimiento que requieren operador humano

| Regla | Qué dice | DT dueño del modelo | DT que opera el flujo |
|-------|----------|--------------------|-----------------------|
| **B37** | Calidad y linaje del conocimiento | `dt-conocimiento` | `dt-hitl` |
| **B39** | Niveles de autonomía A0 a A3 | `dt-cambio` define el catálogo | `dt-hitl` rutea la aprobación |
| **B40** | Bi-temporalidad, los dos relojes | `dt-conocimiento` | `dt-pipeline` al cargar |

La separación entre modelo y operación es deliberada. `dt-conocimiento` define qué nivel tiene cada afirmación y cuál es su linaje; `dt-hitl` consigue que la persona correcta mire lo correcto en el momento correcto. Son dos trabajos distintos y el segundo es el cuello de botella real.

### Fases del Brain Lifecycle

| Fase | DT dueño | DTs que contribuyen |
|------|----------|--------------------|
| DISCOVER — Brain Bootstrap | `dt-pipeline` | `dt-arquitectura`, `dt-valor`, `dt-riesgo` |
| DESIGN — Knowledge Architecture | `dt-arquitectura` | `dt-informacion`, `dt-cambio` |
| BUILD — Brain Population | `dt-pipeline` | `dt-hitl`, todos los de dimensión |
| TEST — Brain Validation | `dt-validador` | `dt-ingenieria` |
| RELEASE — Brain Activation | `dt-validador` | `dt-hitl`, `dt-ingenieria` |
| OPERATE — Brain-First Delivery | Todos los de categoría A | `dt-hitl` |
| OBSERVE — Brain Health | `dt-validador` | `dt-conocimiento` mide la latencia de B40 |
| ITERATE — Brain Evolution | `dt-pipeline` | `dt-ingenieria` |

### Definition of Done

| DoD | Criterio | DT responsable |
|-----|----------|----------------|
| DoD-EB-01 | Pipeline idempotente, nunca hand-crafted | `dt-pipeline` |
| DoD-EB-02 | Cero business_name vacíos o genéricos | `dt-pipeline` sintetiza, `dt-hitl` valida |
| DoD-EB-03 | Clase clasificada en 100% de reglas | `dt-pipeline` |
| DoD-EB-04 | Regulación anotada en 100% de reglas | `dt-pipeline`, `dt-riesgo` valida |
| DoD-EB-05 | DT-Validador PASS | `dt-validador` |
| DoD-EB-06 | Seeds emitidos a todos los vecinos | `dt-pipeline` |
| DoD-EB-07 | Portal generado desde `brain.db` | `dt-ingenieria` |
| DoD-EB-08 | `brain.py` expone la interfaz estándar | `dt-ingenieria` |
| DoD-EB-09 | Taxonomía del cliente como hilo conductor | `dt-arquitectura` |
| DoD-EB-10 | bank-brain federado actualizado | `dt-arquitectura` |

### Verificación de categoría B

| Métrica | Valor |
|---------|-------|
| Reglas de pipeline cubiertas | 5 de 5 |
| Fases del Brain Lifecycle con dueño | 8 de 8 |
| Criterios de DoD con responsable | 10 de 10 |

---

## Categoría C — Cobertura de los dominios L1 de negocio

No existe un marco de capacidades de negocio agnóstico de industria publicado en el ecosistema: se verificó que no hay APQC ni Process Classification Framework en ninguno de los tres ecosistemas, y el único SME de negocio tipo Framework, Business Process & Journey, aporta metodología (BPMN, journey mapping, process mining, value stream) y no taxonomía.

Por eso estos seis dominios **se destilaron de los catálogos de industria existentes**, no se inventaron. Fuentes: Banking ETB V5.0, el marco ACORD de seguros con taxonomía L1 a L4, ETB P&C v3.0, ETB Health Payer v6.0 y la cadena de valor de retail.

| DT | Dominio L1 | Banca | Seguros | Retail |
|----|-----------|-------|---------|--------|
| `dt-negocio-canales` | Canales e interacción | 1. Channel Management | D2 Distribución y Canales | SELL omnicanal |
| `dt-negocio-distribucion` | Distribución, marketing y ventas | 2. Marketing & Sales | D2 intermediarios | PLAN y SELL |
| `dt-negocio-productos` | Producto y servicio | 3. Product & Service | D1 Producto y Actuaría | PLAN y BUY |
| `dt-negocio-clientes` | Gestión de cliente | 7. Customer & Partner Mgmt | D3 Gestión de Cliente | SERVICE y lealtad |
| `dt-negocio-operaciones` | Operaciones del core | 4. Business Support | D4 Pólizas, D5 Cobranza, D6 Siniestros | MOVE |
| `dt-negocio-funciones` | Funciones de empresa | 5. Enterprise Functions | D8 Finanzas y Regulatorio | Finanzas y personas |

### Verificación de categoría C

| Métrica | Valor |
|---------|-------|
| Dominios L1 con DT dueño | 6 de 6 |
| Dominios con evidencia en 3 o más catálogos de industria | 6 de 6 |
| Dominio con etiqueta textual en 3 de 4 catálogos | Funciones de empresa, el de mayor respaldo |

**Dos candidatos excluidos, con su razón.** Socios y ecosistema aparece en solo dos de los cuatro catálogos y se absorbe en distribución, porque en seguros el distribuidor es el socio y en retail el proveedor vive en BUY; los proveedores de tecnología son otro objeto y pertenecen a `dt-proveedores`. Analítica de negocio aparece también en dos de cuatro, y el lado de TI ya la cubre con `dt-informacion` vía el proceso 34. Incluirlos habría significado inflar el roster con evidencia de dos de cuatro, que es el umbral que ADR-EB-009 obligó a documentar como excepción.

**El dominio es genérico, su contenido lo especializa cada industria.** Tal como lo enuncia el SME de Seguros, el modelo de capacidades es independiente del ramo y lo que cambia son los procesos y las reglas dentro de cada capacidad. Ningún DT de negocio inventa el catálogo de su industria: lo toma del Industry SME declarado en `system_info.industry_sme` (Regla B19).

---

## Propiedad del schema

La propiedad funciona en **dos ejes**. Las categorías A y B poseen tablas, en vertical. La categoría C posee dominios dentro de esas tablas, en horizontal. La intersección es una celda, no una tabla, y por eso las tres categorías conviven sin que ninguna tabla cambie de dueño.

| Eje | Quién | Qué posee | Ejemplo |
|-----|-------|-----------|---------|
| **Vertical, por tabla** | Categorías A y B | La estructura y la semántica de la tabla completa | `dt-valor` responde por la estructura de `products` y `kpis` |
| **Horizontal, por dominio** | Categoría C | El contenido de negocio de su dominio L1, atravesando varias tablas | `dt-negocio-clientes` responde por las capabilities, procesos, productos y KPIs del L1 de gestión de cliente |

Cada tabla tiene exactamente un DT dueño en el eje vertical. La propiedad es sobre la **estructura y la semántica**, no sobre el contenido.

| DT | Tablas que posee |
|----|-----------------|
| `dt-arquitectura` | `system_info`, `ontology_bindings`, `capabilities`, `itom_layer`, `decisions`, `plateaus` |
| `dt-informacion` | `data_entities`, `component_data`, `vocabulary` |
| `dt-conocimiento` | `knowledge_lineage`, `knowledge_gaps`, `stakeholders`, `documents`, la columna `tier` en toda tabla |
| `dt-configuracion` | `components`, `component_calls`, `technology_components`, `cross_dependencies`, `external_systems` |
| `dt-cambio` | `transitions`, `readiness_gates`, el campo `target` de `slos` |
| `dt-operacion` | `findings`, `signals`, el campo `current` de `slos` |
| `dt-riesgo` | `regulatory_obligations`, `risks`, la columna `reg` de `rules` |
| `dt-valor` | `products`, `kpis`, `processes`, `journeys` |
| `dt-entrega` | `applications`, `waves`, `user_stories` |
| `dt-proveedores` | `suppliers` |
| `dt-pipeline` | Los extractores, `build-brain.py`, `digital-brain/seeds/` |
| `dt-ingenieria` | `generators/`, `templates/`, `brain.py`, `build-portal.py`, las vistas de homologación |
| `dt-hitl` | La cola de validación, `validated_by`, el registro de aprobaciones |
| `dt-validador` | Las 9 dimensiones. Audita todo y no posee ninguna tabla de contenido |

### Las tres capas de propiedad

Cinco tablas de conocimiento no aparecen arriba: `rules`, `component_capabilities`, `component_processes`, `rule_enrichment_log` y `federated_brains`. No es un olvido. El modelo tiene tres capas y cada una responde de algo distinto:

| Capa | Quién | De qué responde |
|------|-------|-----------------|
| Estructura | Los 10 DTs de categoría A | Las tablas del CORE y de extensión, su semántica y su anclaje a la cadena de valor |
| Extracción | Los DTs de dimensión de cada brain (`dt-reglas`, `dt-journeys`, `dt-vocabulario`, `dt-almas`) | El contenido que llena esas tablas |
| Calidad | `dt-conocimiento`, `dt-hitl` y `dt-validador` | El nivel de certeza, el linaje, la validación humana y la auditoría |

Así `rules` no queda huérfana: la llena `dt-reglas`, la ancla `dt-valor` a su proceso y producto, responde por su nivel `dt-conocimiento`, consigue su validación `dt-hitl` y la audita `dt-validador`.

---

*Artefacto verificable del asset Enterprise Brain · Regla B41 · ADR-EB-011 · Accenture México*
