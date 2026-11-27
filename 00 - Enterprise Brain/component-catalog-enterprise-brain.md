# Component Catalog — Enterprise Brain
> Catálogo vivo de deployments activos del asset Enterprise Brain
> Última actualización: 2026-11-26 · v1.1

---

## Deployments Activos

Datos verificados con `dt/dt-brain-auditor/validate.py` contra cada `brain.db` el 2026-11-26. La columna **Canon** es el resultado de D1 (tablas del CORE más la extensión que corresponde por `brain_type`) **contra el canon vigente**: 38 tablas para un brain `system`, 34 para uno `project` y 27 para uno `enterprise`. Las ediciones anteriores de este catálogo medían contra el CORE previo a ADR-EB-012 y no son comparables con esta columna.

### Brains con corpus poblado

| ID | Cliente | Sistema / Proyecto | brain_type | Hemisferio | State | Componentes | Reglas | Tamaño | Canon |
|----|---------|-------------------|-----------|-----------|-------|------------|--------|--------|-------|
| EB-001 | BanCoppel | Informix PISA | system | run | ACTIVE | 11,391 SPs | 6,664 | 90 MB | 8/38 |
| EB-002 | BanCoppel | ControlM | system | run | ACTIVE | 5,052 jobs | — | 4.5 MB | 3/38 |
| EB-003 | BanCoppel | AppMóvil | system | run | ACTIVE | servicios | 2,817 | 2.9 MB | 5/38 |
| EB-004 | BanCoppel | Unity R4 | project | change | ACTIVE | — | — | 1.1 MB | 3/34 |
| EB-005 | BanCoppel | Exodus | project | change | ACTIVE | 30 apps | — | 192 KB | 4/34 |
| EB-006 | BanCoppel | CAN | project | change | ACTIVE | — | — | 57 KB | 1/34 |
| EB-007 | Banamex | S500+S151 Unisys | system | run | ACTIVE | 152 programas | 1,583 | 122 MB | 38/38 |
| EB-008 | MONEX | Payments Modernization | project | change | ACTIVE | capabilities | — | 168 KB | 1/34 |
| EB-009 | Santander | CAN | project | change | ACTIVE | microservicios | — | 288 KB | 1/34 |
| EB-010 | Coppel | eCommerce | system | run | ACTIVE | plataformas | — | 229 KB | 3/38 |
| EB-011 | Gentera | GENCore | system | run | BUILDING | objetos | 21 | 180 KB | 1/38 |

### Brains de nivel cliente (brain_type = enterprise)

El brain de cliente es el nivel más alto — federa ambos hemisferios vía SQLite ATTACH.

Se nombran por **industria**, no por cliente (ADR-EB-007 / Regla B18).

| ID | Cliente | Industria | Brain canónico | Nombre actual | Hemisferio Change | Hemisferio Run | Federación | Canon |
|----|---------|-----------|---------------|--------------|------------------|---------------|-----------|-------|
| EB-BB-001 | BanCoppel | Banca | `bank-brain` | `bank-brain` | Unity · Exodus · CAN | Informix · AppMóvil · ControlM | Real | 4/27 |
| EB-BB-002 | Liverpool | Retail | `retail-brain` | `liverpool-brain` ⟵ renombrar | — | 20 sistemas | ATTACH funcional | 1/27 |
| EB-BB-003 | AXA | Seguros | `insurance-brain` | `axa-brain` ⟵ renombrar | — | 16 sistemas | Declarada, `brain_attached=0` | 1/27 |
| EB-BB-004 | MONEX | Banca | `bank-brain` | `monex-brain` ⟵ renombrar | Payments Modernization | 11 sistemas | Declarada | 2/27 |
| EB-BB-005 | Santander | Banca | `bank-brain` | `santander-brain` ⟵ renombrar | CAN | 28 sistemas | Declarada | 0/27 |
| EB-BB-006 | Coppel | Retail | `retail-brain` | `retail-brain` | — | eCommerce | Scaffold vacío | — |

El rename es de carpeta y archivo; los datos no cambian.

### Scaffolds sembrados sin corpus

| Cliente | Ubicación | N | Estado |
|---------|-----------|---|--------|
| BanCoppel | `systems/*/*/digital-brain/` | ~32 | `system_info` + `signals` + `cross_dependencies`, 9-16 filas |
| AXA | `systems/*/*/digital-brain/` | 16 | `brain.py`+`build-brain.py` de 38 líneas, sin `brain.db` |
| Liverpool | `systems/*/*/digital-brain/` | ~20 | solo `seeds/` vacío |
| MONEX | `systems/*/*/digital-brain/` | 11 | schema de 4 tablas, `status=SCAFFOLD` |

Los scaffolds no son deuda: son la Regla B9 operando — todo sistema descubierto recibe estructura canónica de inmediato.

---

## Rutas Canónicas por Cliente

| Cliente | Ruta raíz AM | Brain raíz |
|---------|-------------|-----------|
| BanCoppel | `03 - SPE/HVM/AM/BanCoppel/` | `systems/core/Informix/digital-brain/` |
| Banamex | `03 - SPE/HVM/MM/Banamex/` | `systems/core/unisys/digital-brain/` |
| MONEX | `03 - SPE/HVM/AM/MONEX/` | `AM/MONEX/` |
| Liverpool | `03 - SPE/HVM/AM/Liverpool/` | `liverpool-brain/` |
| AXA | `03 - SPE/HVM/AM/AXA/` | `axa-brain/` |
| Santander | `03 - SPE/HVM/AM/Santander/` | `santander-brain/` |
| Coppel | `03 - SPE/HVM/AM/Coppel/` | `retail-brain/` |
| Gentera | `03 - SPE/HVM/AM/Gentera/` | `GENCore/digital-brain/` |

**Nomenclatura resuelta (ADR-EB-007)**: el brain de nivel cliente se nombra por industria — `bank-brain`, `insurance-brain`, `retail-brain` — porque la industria determina la semántica del brain, no el cliente. Cuatro brains quedan pendientes de renombrar.

---

## Tecnologías de Sistema Cubiertas

| Tecnología | Extractor | Deployments |
|-----------|-----------|-------------|
| IBM Informix SPL | Specialist - Informix SPL | EB-001 · EB-005 (Exodus) |
| Unisys DMSII / COBOL / ALGOL | Specialist - Mainframe Migration | EB-007 (Banamex) |
| Java / Spring (Feign, Mongo, Redis) | Análisis estático + LLM | EB-003 (AppMóvil) |
| Control-M / shell | Parser CTM | EB-002 |
| Node / Next / Go / SFCC | Análisis estático | EB-010 (Coppel) |
| SAP ABAP | Specialist - SAP ABAP | EB-011 (Gentera) |
| SAP / Oracle / Mainframe | Análisis estático + LLM | EB-BB-002 (Liverpool) |

---

## Métricas Agregadas del Asset

| Métrica | Valor | Fecha |
|---------|-------|-------|
| Brains con corpus poblado | 11 | 2026-11-26 |
| Brains de nivel cliente (`enterprise`) | 6 (1 scaffold) | 2026-11-26 |
| Scaffolds sembrados sin corpus | ~79 | 2026-11-26 |
| Brains en hemisferio Change | 5 | 2026-11-26 |
| Brains en hemisferio Run | 6 | 2026-11-26 |
| Reglas de negocio gestionadas | 11,085 medidas en brain.db | 2026-11-26 |
| Clientes con estate de brains | 8 | 2026-11-26 |
| Brains que pasan D1 contra el canon vigente | **1 de 16** — solo EB-007, con 38 de 38 | 2026-11-26 |
| Brains con Brain Auditor PASS completo | **0 de 16** | 2026-11-26 |
| Brains que declaran su industria | **0 de 16** | 2026-11-26 |
| Industrias en el estate | 3 (banca, seguros, retail) | 2026-11-26 |

---

## Estado de Homologación

### Pipeline de fuentes

Entregado con el asset, copiable a cualquier instancia. Es la capa que convierte
una fuente registrada en conocimiento cargable, y la frontera dura del canon: un
extractor **nunca** escribe en `brain.db`.

| Componente | Qué es | Estado |
|---|---|---|
| `templates/extractors/contrato.py` | El contrato y sus cuatro garantías: tope de tier, procedencia exigida, tabla declarada y prohibición de escribir sobre un brain | ACTIVE |
| `templates/extractors/tiers.py` | La tabla F2 de `dt-source-steward`, ejecutable. El tier deja de depender de que alguien la recuerde | ACTIVE |
| `templates/extractors/doc-identidad.py` | Documento de texto a los candidatos de la Etapa 0, con procedencia hasta la línea | ACTIVE |
| `templates/extractors/codigo-componentes.py` | Árbol de código a componentes y grafo de llamadas. El único que emite en gold | ACTIVE |
| `templates/extractors/test-extractores.py` | Viola cada garantía a propósito. 27 casos | ACTIVE |

Cobertura: **2 de los 16 tipos de fuente** que F2 clasifica. La familia
`connector`, para sistemas vivos, no tiene implementación todavía.

---

La columna **Canon** de este catálogo ya está recalculada contra el canon vigente, el que fijan ADR-EB-012 a ADR-EB-018 con sus 11 dimensiones. Los baselines guardados en `dt/dt-brain-auditor/` miden el canon previo a ADR-EB-012, con su CORE más chico y las dimensiones D1 a D9 de entonces (ADR-EB-009, ADR-EB-010, ADR-EB-011): `baseline-2026-10-01.json` es el último de esa serie y `baseline-2026-09-30.json` queda como histórico. No se comparan con esta columna y no se van a actualizar: su valor es dejar constancia de dónde estaba el estate cuando cambió el canon.

**Un solo brain pasa D1 hoy**: EB-007, con 38 de 38 tablas. Los otros quince siguen por debajo, y ninguno de los dieciséis llega a Brain Auditor PASS completo — EB-007 falla en otras dimensiones. La homologación del resto no ha comenzado.

Los 11 brains de sistema y de proyecto reprueban D8 (puente Change–Run, ADR-EB-008); ninguno implementa el contrato común. Siete tienen piezas propias del lado Change y ninguno el lado Run con ruteo.

Brecha del CORE sobre los 16 brains medidos, contra las 25 tablas del canon vigente (B15), el 2026-11-26:

| Tabla del CORE | Contrato | Brains sin ella |
|---------------|----------|----------------|
| `ontology_bindings` · `processes` · `kpis` · `data_entities` · `technology_components` · `suppliers` · `measurements` · `costs` · `knowledge_lineage` · `queries` · `source_catalog` · `company_profile` · `business_milestones` · `strategic_drivers` · `driver_links` | Ontología, cadena de valor, linaje, consumo y Etapa 0 | **15 de 16** |
| `capabilities` · `stakeholders` · `knowledge_gaps` · `action_catalog` · `actions` | Ontología, honestidad y capa agéntica | 14 de 16 |
| `system_info` · `itom_layer` · `signals` | Identidad, ITOM y federación | 13 de 16 |
| `products` | Cadena de valor | 12 de 16 |
| `cross_dependencies` | Federación | 9 de 16 |

Las quince tablas de la primera fila existen en un solo brain, EB-007, que es el único que adoptó el canon vigente completo. `cross_dependencies` sigue siendo la tabla más extendida del CORE porque la federación fue lo primero que el estate necesitó.

Brecha semántica (ADR-EB-007): **ningún brain declara `industry`, `capability_model`, `process_ontology` ni su composición de ontologías**. La semántica estaba implícita en los 16 — que es exactamente por qué divergieron.

Orden de homologación recomendado:

1. **Declarar la semántica** — `system_info` + `ontology_bindings`. Es lo más barato y lo que más divergencia previene hacia adelante.
2. **Vistas de compatibilidad** (Regla B16) para los nombres canónicos del CORE.
3. **Rename** de los cuatro brains de nivel cliente.

El rename va al final a propósito: renombrar carpetas antes de declarar la semántica solo mueve el problema de lugar.

La ruta de homologación es la Regla B16 — vista de compatibilidad, no migración de datos.

---

## Notas de Mantenimiento

- El catálogo se actualiza cuando un deployment cambia de estado (BUILDING → ACTIVE → STALE → ARCHIVED).
- Las cifras de esta página se verifican corriendo el Brain Auditor, no se estiman.
- Los campos "—" indican métrica no medida formalmente, no que el brain esté vacío.
