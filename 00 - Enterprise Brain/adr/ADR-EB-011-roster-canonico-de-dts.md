# ADR-EB-011 — Roster canónico de Digital Twins: 20 DTs en tres categorías

> Estado: **APROBADO** · Propuesto: 2026-10-05 · Aprobado: 2026-10-05 · Asset: Enterprise Brain · Digital Core
> Formaliza la Regla B41. Extiende la excepción de ADR-EB-009 y enmienda el conteo del CORE de ADR-EB-010.
> **`[ENMENDADO]` El roster creció de 20 a 24.** Este ADR fijó 20 DTs y rechazó por disciplina agregar los ocho dominios L1 de negocio en lugar de seis. Esa decisión se revirtió después con evidencia trazada al XLSX del ETB, y el roster incorporó `dt-business-support-owner`, `dt-sustainability-owner`, `dt-source-steward` (ADR-EB-014) y `dt-client-intelligence` (ADR-EB-015). El conteo vigente vive en la Regla B41 y en `dt/cobertura-dt.md`, no en este documento.

---

## Contexto

La Regla B29 establece que los Digital Twins construyen y mantienen el brain en enjambre, pero no dice **cuáles deben existir siempre**. Sin un roster fijo, cada brain inventa su propio conjunto y nadie responde por lo que ninguno reclamó.

El inventario del estate lo confirmó. En los 16 brains hay **124 carpetas de DT dentro de 85 carpetas `dt/`**, y su distribución revela el hueco:

| Naturaleza del DT | Cantidad | Ejemplos |
|-------------------|----------|----------|
| Dimensiones de análisis | ~115 | `dt-reglas`, `dt-journeys`, `dt-vocabulario`, `dt-almas`, `dt-capacidades`, los `*-lifecycle` de seguros y banca |
| Rol de TI | 2 tipos | `dt-itom` en dos brains, `dt-brain-auditor` en tres |
| Función de negocio genérica | 4 casos | `dt-productos`, `dt-capacidades`, `dt-inteligencia-cliente` (replicado en 4 brains), `dt-inteligencia-negocio` |
| Carpetas vacías sin `CLAUDE.md` | 36 | todas en un mismo brain |

**No existía ni un `dt-arquitecto`, ni un `dt-change-manager`, ni un `dt-configuration-manager`, ni un `dt-knowledge-manager` en ningún brain del estate.** Los 115 DTs de dimensión extraen conocimiento del código y del negocio, pero nadie organiza lo que extraen ni responde por su estructura.

### Por qué no se pudo destilar el lado de negocio como se destiló el de TI

El lado de TI tenía un ancla disponible: el SME `SME/Framework/IT Operating Model` prescribe 38 procesos y 46 roles, y es agnóstico de industria. El lado de negocio no la tenía. Se verificó por búsqueda en los tres ecosistemas:

- **Cero menciones de APQC o Process Classification Framework.** No existe marco de procesos cross-industry publicado.
- `SME/Framework/Business Process & Journey` es **metodológico, no ontológico**: aporta BPMN, customer journey mapping, value stream y process mining, sin catálogo de capacidades.
- Los siete SMEs restantes de `SME/Framework/` son todos de TI.

Lo que sí existe son cuatro catálogos de industria con taxonomía propia: Banking ETB V5.0, el marco ACORD de seguros con niveles L1 a L4, ETB P&C v3.0, ETB Health Payer v6.0, más la cadena de valor de retail. Al cruzarlos aparecieron **seis dominios de primer nivel que se repiten casi literalmente**, y ese cruce es la evidencia de esta decisión.

### Las dos tensiones que el roster abre

1. **Con el principio de destilación (ADR-EB-006).** Una tabla entra al CORE cuando existe en tres o más brains. La tabla `suppliers`, que necesita el DT de proveedores, existe en cero.
2. **Con la Regla B19.** El brain no inventa la ontología de su industria. Los seis dominios L1 no los publica ningún Industry SME: se derivaron de cuatro catálogos.

---

## Decisión

### 1. Veinte DTs canónicos en tres categorías

Las tres categorías tienen **sistemas de coordenadas distintos**, y eso es lo esencial: confundirlas es lo que dejaba huecos estructurales.

| Categoría | Razona sobre | Se mide contra | DTs |
|-----------|-------------|----------------|-----|
| **A. Rol de TI** | La organización de TI del cliente | Los 38 procesos del IT Operating Model | 10 |
| **B. Ingeniería del brain** | El brain como producto | El Brain Lifecycle y las reglas P1 a P5 | 4 |
| **C. Negocio** | El modelo de negocio del cliente | Los 6 dominios L1 comunes a los catálogos de industria | 6 |

**Categoría A** — `dt-domain-architect`, `dt-information-architect`, `dt-knowledge-manager`, `dt-asset-configuration-manager`, `dt-change-manager`, `dt-service-operations-lead`, `dt-it-risk-manager`, `dt-demand-manager`, `dt-programme-manager`, `dt-supplier-relationship-manager`. Cobertura verificada: **38 de 38 procesos**, con el proceso 2 compartido por diseño entre `dt-change-manager`, que fija el target del SLO, y `dt-service-operations-lead`, que mide el current.

**Categoría B** — `dt-build-operator`, `dt-human-reviewer`, `dt-brain-engineer`, `dt-brain-auditor`.

**Categoría C** — `dt-channel-owner`, `dt-distribution-owner`, `dt-product-owner`, `dt-customer-owner`, `dt-operations-owner`, `dt-enterprise-functions-owner`.

El mapa completo y verificable vive en `dt/cobertura-dt.md`.

### 2. `suppliers` entra al CORE, que pasa de 14 a 15 tablas

La justificación **no es la evidencia en el estate**, que es cero, sino una consecuencia del roster:

> **Si el roster canónico obliga a que un DT exista en todo brain, la tabla que ese DT posee es CORE por consecuencia.**

Esto **cambia la base de justificación del CORE**, y el cambio es deliberado. Hasta aquí el CORE se justificaba por destilación: una tabla entra cuando tres brains la implementan (ADR-EB-006), con la excepción acotada que concedió ADR-EB-009 para `kpis`, `data_entities` y `technology_components`. A partir de esta decisión el CORE tiene **dos fundamentos legítimos**:

| Fundamento | Criterio | Tablas que lo usan |
|-----------|----------|--------------------|
| **Destilación** | Existe en 3 o más brains independientes | La mayoría del CORE |
| **Implicación del roster** | Un DT canónico obligatorio la posee | `suppliers` |

El segundo fundamento es más exigente de lo que parece, no menos: solo aplica a tablas poseídas por un DT del roster, y el roster solo crece con ADR. No es una puerta abierta a tablas aspiracionales.

La alternativa era dejar `suppliers` en las extensiones, y se rechazó porque habría exigido duplicarla en SYSTEM y en PROJECT, y porque la dependencia de un proveedor crítico es materia regulatoria en banca supervisada, es decir aplica a todo brain y no a un tipo.

### 3. Propiedad en dos ejes

| Eje | Quién | Qué posee |
|-----|-------|-----------|
| **Vertical, por tabla** | Categorías A y B | La estructura y la semántica de la tabla completa |
| **Horizontal, por dominio** | Categoría C | El contenido de negocio de su dominio L1, atravesando varias tablas |

La intersección es una **celda**, no una tabla. Por eso las tres categorías conviven sin que ninguna tabla cambie de dueño al agregar la categoría C.

**Las cinco tablas que quedaban sin dueño vertical se asignan aquí**, porque la redacción anterior decía que la categoría A posee "las tablas del CORE y de extensión" y al mismo tiempo las declaraba sin dueño:

| Tabla | Dueño vertical | Razón |
|-------|---------------|-------|
| `rules` | `dt-asset-configuration-manager` | Es lógica extraída de los componentes que ese DT ya posee: misma familia de evidencia |
| `component_capabilities` | `dt-asset-configuration-manager` | Atribución del lado del componente, con su confianza |
| `component_processes` | `dt-asset-configuration-manager` | Ídem |
| `rule_enrichment_log` | `dt-knowledge-manager` | Es linaje, y `knowledge_lineage` lo generaliza |
| `federated_brains` | `dt-domain-architect` | La federación es estructura |

El sentido de negocio de `rules` sigue siendo del eje horizontal, en `dt-operations-owner`. Poseer la estructura no es poseer el significado.

### 4. El roster es íntegro en todo brain; lo que varía es el estado de cada DT

La Regla B41 exige los 20 DTs en todo brain, pero la Regla B15 da a cada brain el CORE más **una sola** extensión según su `brain_type`. Un brain de proyecto no tiene `components` ni `rules`; uno enterprise no tiene ninguna de las dos.

Eso no es contradicción si se usa la máquina de estados que ya declaran los scaffolds:

| Estado | Cuándo | Qué puede hacer el DT |
|--------|--------|----------------------|
| **SCAFFOLD** | Las tablas que posee no existen en este `brain_type`, o existen vacías | Razonar con lo que el brain ya sabe y con lo que leen los brains federados (Regla B4) |
| **ACTIVE** | Posee al menos una tabla con contenido y registró su primer hallazgo con linaje | Construir y mantener |

Un DT en SCAFFOLD **no es un defecto**: es la lente que existe aunque el dato viva en otro brain. `dt-programme-manager` en un brain de sistema no posee `waves`, pero sí puede preguntar al brain de proyecto qué ola viene y qué tocará. Esa es la razón de que el roster sea íntegro y no variable: la pregunta siempre es válida, lo que cambia es dónde está la respuesta.

### 5. Aclaración a la Regla B19

B19 dice que el brain no inventa la ontología de su industria. Los seis dominios L1 de la categoría C **no son ontología de industria**: son una capa superior que ordena las ontologías de industria, destilada de cuatro catálogos reales y sin sustituir a ninguno.

La frontera es precisa y la enuncia el propio SME de Seguros: *el modelo de capacidades es independiente del ramo; lo que cambia son los procesos y las reglas dentro de cada capacidad*. Por lo tanto:

- **El dominio L1 es canónico y genérico.** Lo fija este ADR.
- **Su contenido, es decir las capabilities, los procesos y las reglas de cada dominio, lo suministra el Industry SME** declarado en `system_info.industry_sme`. Ningún DT de negocio lo inventa.

Dos candidatos quedaron fuera por tener evidencia en solo dos de los cuatro catálogos: socios y ecosistema, que se absorbe en distribución porque en seguros el distribuidor es el socio y en retail el proveedor vive en el macro-proceso de compra; y analítica de negocio, que el lado de TI ya cubre con `dt-information-architect` vía el proceso 34.

---

## Consecuencias

- **Los 20 DTs nacen en estado SCAFFOLD.** Declaran identidad, propiedad y cobertura, y son invocables desde el día uno. El único ACTIVE hoy es `dt-brain-auditor`.
- **Una carpeta de DT sin `CLAUDE.md` no es un scaffold: es una carpeta.** No la puede invocar nadie ni verificarla el validador. Las 36 que existen en el estate son deuda y se cierran con la estructura mínima que ya manda la Regla B9.
- **El CORE pasa a 15 tablas.** Deben actualizarse en consecuencia: la Regla B15, el encabezado de `templates/schema.sql`, la dimensión D1 de `dt/dt-brain-auditor/CLAUDE.md` y la constante `CORE_TABLES` de `validate.py`. Mientras no se haga, `suppliers` existe en el DDL y no se valida ni se puebla.
- **`suppliers` necesita cargador.** No hay `load_suppliers()` en `build-brain.py`, y la tabla declara `process_id`, así que también entra en `PROCESS_LINKED_TABLES` del validador.
- **Los DTs de dimensión que ya existen no se sustituyen.** Siguen extrayendo conocimiento del código y del negocio del cliente. Los canónicos organizan lo que esos extraen y responden por su calidad: es la diferencia entre la abeja que trae el néctar y la que construye la celda.
- **`dt-itom`, que existe en dos brains, queda absorbido por `dt-domain-architect`**, porque su mandato actual es proyectar el brain sobre los seis dominios del modelo operativo y eso es exactamente la propiedad de `itom_layer`. Se homologa por vista (Regla B16) y no se borra.
- **`dt-inteligencia-cliente` no se confunde con `dt-customer-owner`.** El primero investiga al cliente como empresa para el equipo de cuenta y está replicado en cuatro brains; el segundo modela al cliente del cliente. Son dos objetos distintos y ambos legítimos.
- **La cobertura se vuelve auditable.** Un proceso del modelo operativo sin DT dueño, o una regla de pipeline sin responsable, es hallazgo bloqueante. Falta implementar esa verificación: hoy `validate.py` tiene nueve dimensiones y ninguna mira el roster.

## Alternativas consideradas y rechazadas

**Un roster variable por `brain_type`.** Se rechazó porque convierte el roster en decisión de diseño de cada proyecto, que es justo el problema que esta decisión resuelve. La máquina de estados SCAFFOLD y ACTIVE logra lo mismo sin perder la integridad del contrato.

**Inventar un marco de capacidades de negocio propio.** Se rechazó por contradecir B19 en espíritu. Destilar de cuatro catálogos reales es verificable; inventar una taxonomía no lo es.

**Agregar los ocho dominios L1 en lugar de seis.** Se rechazó por disciplina: dos tenían evidencia en solo dos de cuatro catálogos, que es por debajo del umbral que ADR-EB-009 obligó a documentar como excepción.

**Dejar que los DTs de negocio poseyeran tablas.** Se rechazó porque habría exigido mover `products`, `kpis`, `processes` y `capabilities` del lado de TI al de negocio, rompiendo asignaciones ya establecidas. La propiedad horizontal por dominio logra la separación sin mover nada.
