# Metodología del Análisis de la Situación — Banco Ripley Chile

> Enterprise Brain, método de nivel empresa. Versión 1.0, 2026-10-27.
> Instanciada desde la semilla de `00 - Enterprise Brain/`. Canon aplicable: las 45 reglas de `canon/brain-rules.md`.
> Candidata a promoverse al asset como `knowledge-base/methodology/00-analisis-situacion.md`, porque el asset hoy no publica el método de nivel empresa.

---

## Por qué hacía falta escribir esto

El asset publica cuatro etapas: Lenguaje, Almas, Biografía e Intención. Las cuatro leen código fuente. La primera mina identificadores de stored procedures y tablas, la segunda calcula fan_in y fan_out sobre un grafo de llamadas, la tercera recorre ese grafo desde los puntos de entrada y la cuarta extrae reglas de negocio línea por línea. Es un método excelente y es el método de un **brain de sistema**.

Banco Ripley no tiene hoy una sola línea de código cargada. Lo que hay es un banco real, un regulador real, estados financieros auditados y un modelo de industria. Aplicar las cuatro etapas aquí no produciría un análisis pobre: no produciría nada, porque no tienen insumo.

Lo que corresponde es el método de **brain de empresa**, que trabaja en el sentido contrario. En lugar de subir desde el código hacia el negocio, baja desde el modelo de negocio hacia la evidencia, y declara con honestidad dónde la evidencia todavía no llega. El producto no es un inventario: es el mapa de lo que el banco debería poder hacer, lo que la evidencia demuestra que hace, y la distancia entre ambas cosas. Esa distancia es el hallazgo, y es la Regla B20 generalizada.

Las cuatro etapas del asset siguen vigentes y corren después, por sistema, cuando haya código. Este método no las sustituye: les construye el marco donde aterrizan.

---

## El principio que ordena todo el método

> **El lado de negocio declara el modelo, el lado de TI aporta la evidencia, y la brecha entre ambos es el hallazgo.**

De ahí salen las dos caras del enjambre. Los ocho Digital Twins de negocio no describen a Banco Ripley: describen qué exige el modelo Digital Bank 4.0 de un banco de consumo ligado a retail. Los diez Digital Twins de rol de TI no describen el modelo: describen qué demuestra la evidencia disponible. Confundir las dos caras es lo que convierte un análisis de la situación en una lámina de consultor.

Y de ahí sale también la regla más incómoda de este documento: con fuente solo pública, la mayoría de los Digital Twins de TI va a producir huecos y no hallazgos. Eso no es un fracaso del método, es el método funcionando. Un hueco declarado, con una pregunta concreta dirigida a un interlocutor con nombre, vale más que un dato inventado, y la Regla B17 lo prohíbe expresamente.

---

## La estructura: cinco rondas y una capa transversal

El enjambre no trabaja en fila india. Trabaja en rondas, y dentro de cada ronda los Digital Twins corren en paralelo porque no dependen unos de otros. Lo que sí es secuencial es el paso de una ronda a la siguiente, porque R3 necesita las dos anteriores completas para poder cruzarlas.

| Ronda | Nombre | Quién corre | Qué produce |
|-------|--------|-------------|-------------|
| R0 | Encuadre | Nadie del enjambre, lo hace el arquitecto del brain | La identidad del brain, su ontología declarada y su catálogo de fuentes |
| R1 | El modelo | Los 8 Digital Twins de negocio | Qué exige el modelo de industria, en capabilities, procesos, productos y KPIs |
| R2 | La evidencia | Los 10 Digital Twins de rol de TI, más el auditor en el proceso 18 | Qué demuestra la evidencia, y dónde no llega |
| R3 | La brecha | `dt-domain-architect` con `dt-knowledge-manager` | Los hallazgos: brecha de negocio, deuda sin propósito y divergencia |
| R4 | El consejo | Los Digital Twins dueños de cada hallazgo | Escenarios y alternativas, con el nivel de conocimiento que los sostiene |

Los cinco Digital Twins de ingeniería no son una ronda. Son la capa transversal que corre durante las cinco, porque gobiernan el pipeline, el nivel de certeza, la validación humana y la auditoría. Ponerlos al final sería tratarlos como un control de calidad de salida, y no lo son.

---

## R0 — Encuadre

No participa el enjambre. Es el acto de declarar qué brain es este, contra qué ontología razona y de qué corpus se alimenta. Sin R0 las rondas siguientes no tienen dónde escribir.

### Lo que se declara en `system_info`

| Campo | Valor para Banco Ripley | Regla |
|-------|------------------------|-------|
| `brain_name` | `bank-brain` | B18, el brain de cliente se nombra por industria |
| `brain_type` | `enterprise` | B14, y determina que la extensión sea `federated_brains`, `documents` y `processes` |
| `hemisphere` | `change` y `run`, los dos | B13 |
| `industry` | `banca` | ADR-EB-007 |
| `industry_sme` | `SME/Industry/Industry Banking/` | B19, la ontología la suministra el SME y no el brain |
| `itom_sme` | `SME/Framework/IT Operating Model/` | B23 |
| `capability_model` | Accenture Logical Operating Model for Banking, Digital Bank 4.0 | B2 |
| `source_of_truth` | Registros públicos: CMF, Bolsa de Santiago, memorias de Ripley Corp | B31 |
| `status` | `discovered` | §20 de las reglas universales |
| `build_agent` | El enjambre de 23 Digital Twins canónicos | B29 |

### Lo que se declara en `ontology_bindings`

Multi-fila, porque Banco Ripley compone su ontología de más de una fuente (Regla B20).

| Binding | Tipo | Rol en el modelo |
|---------|------|------------------|
| Digital Bank 4.0, 28 L1 en tres agrupaciones L0 | `etb` | La cara de negocio. Es el north star |
| IT Operating Model v9.0, 38 procesos en 6 dominios | `it-capability` | La cara de TI. Es el habilitador |
| Cadena de valor de retail | `value-chain` | Solo para el canal tienda. No modela lifecycle propio |
| Marco regulatorio chileno | `regulatory` | **No existe todavía.** Es la brecha bloqueante de R1 |
| BIAN Service Landscape v14 | `bian` | Mapeo de los L2 con contraparte BIAN, para cuando haya sistemas |

El cuarto binding es el problema. El Industry Banking SME tiene resuelta su capa local para México, con la extensión de 89 productos de banca múltiple y el mapa de CNBV, Banxico y CONDUSEF, y no tiene nada para Chile. R0 no puede inventarlo (Regla B23) y R1 no puede cerrar sin él en los dominios regulados. Por eso R0 termina abriendo ese hueco formalmente, no cerrándolo.

### Lo que se declara en `source_catalog`

El dueño es `dt-source-steward` y la clasificación de nivel por tipo de fuente es suya. Al 2026-10-27 el catálogo es corto, y conviene que se vea corto.

| Fuente | Qué aporta | Nivel al cargar | Por qué ese nivel |
|--------|-----------|-----------------|-------------------|
| Normativa publicada de la CMF y del Banco Central de Chile | Obligaciones regulatorias | **gold** | Una regulación publicada no es debatible. La Regla B37 la manda directo a gold |
| Estados financieros auditados y análisis razonado de Ripley Corp | Tamaño, composición de cartera, resultados del segmento bancario | **gold** en lo financiero | Es hecho publicado y auditado. No dice nada de la tecnología |
| Hechos esenciales ante la CMF | Eventos materiales, incluidos incidentes operativos relevantes | **gold** con fecha | Es declaración formal del emisor |
| Memorias anuales y reportes de sostenibilidad | Iniciativas, estructura, compromisos | **silver** | Es relato del propio emisor y su parte narrativa no está auditada |
| Prensa financiera y notas sectoriales | Señales de mercado y de competencia | **silver** o **bronze** | Depende de si cita fuente primaria |
| Modelo Digital Bank 4.0 | Qué debería poder hacer el banco | **silver** | Es el modelo, no es Banco Ripley |

Falta todo lo demás: arquitectura, inventario de aplicaciones, contratos de proveedor, CMDB, monitoreo, código fuente. Ese "todo lo demás" es exactamente el landscape tecnológico, y por eso R2 va a producir sobre todo huecos.

### Estudio histórico de la organización

La Regla B26 obliga a que todo brain arranque con el estudio histórico, desde la fundación hasta hoy, porque la historia explica el porqué del código. En Banco Ripley eso significa reconstruir cómo una casa comercial llegó a tener licencia bancaria, qué decisiones tecnológicas tomó en cada etapa y qué peso sigue cargando de ellas. Va en `knowledge-base/historia/`.

Esta es además una de las siete reglas que el propio asset declara sin artefacto verificable: la carpeta de historia no existe en el asset. Aquí sí se crea, y si funciona es candidata a volver al asset.

### Gate de salida de R0

R0 cierra cuando `system_info` está completa, `ontology_bindings` tiene sus filas con el binding regulatorio marcado como hueco abierto, `source_catalog` está poblado con su nivel por fuente, y el estudio histórico tiene al menos su línea de tiempo. No cierra por tener contenido: cierra por tener el marco.

---

## R1 — El modelo, los ocho Digital Twins de negocio

Cada uno declara qué exige el modelo Digital Bank 4.0 en su dominio L1, para un banco de consumo ligado a una red de retail. Ninguno afirma nada sobre Banco Ripley que no tenga fuente. Todo lo que produce esta ronda entra **silver**, porque es el modelo y no es el banco.

La pregunta de encuadre de cada Digital Twin no es retórica. Es la pregunta que, si nadie la responde, deja ese dominio sin modelo y por lo tanto sin con qué comparar la evidencia en R3.

| Digital Twin | Dominio L1 | Pregunta de encuadre | Tablas que puebla |
|--------------|-----------|---------------------|-------------------|
| `dt-channel-owner` | Canales e interacción | ¿Qué capacidades de canal exige el modelo, y qué peso tiene el piso de venta de la tienda como canal bancario frente a la app, la web, el call center y la red de cajeros? | `capabilities` del L1 Channel Management, `journeys` esperados por canal |
| `dt-distribution-owner` | Distribución, marketing y ventas | ¿Cómo se origina un cliente nuevo y cómo se fija el precio? Incluye la obligación de informar la Carga Anual Equivalente, que es regla de negocio dura y no material de marketing | `capabilities` de Marketing y de Sales, `products` con su canal de originación |
| `dt-product-owner` | Producto y servicio | ¿Cuál es el catálogo de productos que el modelo espera y cómo se mapea a la taxonomía Digital Bank 4.0? Hipótesis a confirmar: tarjeta de crédito, avance en efectivo, crédito de consumo, cuenta vista, depósito a plazo y el seguro asociado al crédito | `products`, `capabilities` de Product Design and Development |
| `dt-customer-owner` | Gestión de cliente | ¿Qué exige el modelo en onboarding, conocimiento del cliente, servicio y lealtad? Y la pregunta propia de este banco: cómo se relaciona el programa de lealtad del retail con el cliente bancario | `capabilities` de Customer Service y de Customer Experience, `stakeholders` |
| `dt-operations-owner` | Operaciones del core | ¿Qué procesos de originación, servicing del contrato, pagos, procesamiento de tarjetas, cobranza y gestión de mora exige el modelo para un banco cuyo activo principal es la tarjeta de crédito? | `processes`, `capabilities` de Cross Products Processing and Servicing |
| `dt-enterprise-functions-owner` | Funciones de empresa | ¿Qué exige el modelo en contabilidad, reporte regulatorio a la CMF, tesorería, gestión de capital y riesgo de crédito? | `capabilities` de Enterprise Functions, `kpis` regulatorios |
| `dt-business-support-owner` | Soporte corporativo | ¿Qué exige el modelo en legal, compras, personas y servicios internos? | `capabilities` de Business Support |
| `dt-sustainability-owner` | Sostenibilidad, ética e inclusión | ¿Qué exige la normativa chilena de reporte ASG y qué compromisos públicos de Ripley Corp caen sobre el banco? | `capabilities` de Responsible Business, `regulatory_obligations` |

Dos de estos ocho merecen advertencia. `dt-business-support-owner` y `dt-sustainability-owner` son los que el propio asset marca como pendientes en los catálogos de seguros y de retail, y son los que más riesgo tienen de quedarse vacíos por falta de contraparte en el modelo. Si se quedan vacíos hay que decirlo, no rellenarlos.

### Gate de salida de R1

Los ocho dominios L1 tienen su conjunto de capabilities esperadas, con el nivel silver registrado y la fuente identificada en el modelo. Los dominios que dependen de normativa chilena quedan marcados como incompletos mientras el Industry Banking SME no entregue la capa Chile. Un dominio regulado declarado completo sin esa capa es un falso positivo, y es peor que dejarlo abierto.

---

## R2 — La evidencia, los diez Digital Twins de rol de TI

Cada uno va a la evidencia disponible y declara qué puede sostener sobre sus procesos del IT Operating Model. La columna más importante de esta tabla es la última, porque es la que dice la verdad sobre el estado del análisis al 2026-10-27.

Los 38 procesos los cubren once Digital Twins y no diez: el proceso 18, Quality Management, lo posee `dt-brain-auditor`, que es de la capa de ingeniería. El proceso 2, Service Level Management, es el único compartido por diseño, porque `dt-change-manager` fija el objetivo y `dt-service-operations-lead` mide el estado actual.

| Digital Twin | Procesos ITOM | Pregunta de encuadre | Qué puede sostener hoy con fuente pública |
|--------------|---------------|---------------------|-------------------------------------------|
| `dt-it-risk-manager` | 20, 31, 32, 37 | ¿Qué obligaciones regulatorias de TI pesan sobre el banco, y qué exige el regulador en continuidad, ciberseguridad y riesgo operacional? | **Mucho, y gold.** La normativa de la CMF es pública y entra directo a gold. Es el Digital Twin con mejor posición de partida |
| `dt-supplier-relationship-manager` | 4, 5 | ¿Quiénes son los proveedores de tecnología y qué dependencia crea cada uno? | **Parcial, silver.** Las memorias y las notas a los estados financieros filtran proveedores y contratos relevantes |
| `dt-service-operations-lead` | 2 actual, 19, 21, 22, 23, 24, 25, 29, 30 | ¿Cuál es la disponibilidad real de los canales y qué incidentes materiales ha tenido el banco? | **Parcial, silver con fecha.** Los incidentes materiales se informan como hecho esencial a la CMF. La operación cotidiana no es pública |
| `dt-programme-manager` | 13, 14, 17 | ¿Qué programas de transformación están en curso y con qué horizonte? | **Parcial, silver.** El análisis razonado y la memoria mencionan iniciativas, sin plan ni alcance |
| `dt-demand-manager` | 1, 3, 9, 12, 36 | ¿Cómo se prioriza y financia la demanda de TI, y cuánto gasta el banco en tecnología? | **Muy poco.** El estado de resultados da gastos de apoyo agregados, nunca el desglose de TI |
| `dt-information-architect` | 33, 34 | ¿Cómo gobierna sus datos, qué entidades críticas tiene y cómo cumple la ley de datos personales? | **Solo la obligación, no la práctica.** La ley es pública, su implementación no |
| `dt-domain-architect` | 6, 7, 8, 10, 11 | ¿Cuál es la arquitectura de referencia del banco y qué decisiones la explican? | **Nada.** Hueco completo |
| `dt-change-manager` | 2 objetivo, 15, 16, 27 | ¿Cómo se liberan cambios a producción y con qué compromiso de servicio? | **Nada.** Hueco completo |
| `dt-asset-configuration-manager` | 26, 28 | ¿Qué aplicaciones e infraestructura componen el landscape, y cuál es el core bancario? | **Nada.** Es el hueco central del análisis, y el que más vale cerrar |
| `dt-knowledge-manager` | 35, 38 | ¿Qué sabemos, con qué nivel y de dónde? | **Todo, por construcción.** Es el dueño del tablero de niveles del propio análisis |

Tres Digital Twins con hueco completo no es un accidente de este cliente: es lo que pasa siempre que se arranca un análisis de la situación sin acceso al cliente. Lo que distingue a este método es que esos tres huecos se escriben en `knowledge_gaps` con una pregunta concreta y un destinatario, en lugar de rellenarse con supuestos de industria.

### El formato del hueco

La Regla B35 pide que el brain, cuando le falta un eslabón, pida la información concreta al responsable en lugar de inventarla. Un hueco bien escrito tiene cuatro cosas, y sin las cuatro no sirve:

| Campo | Qué lleva |
|-------|-----------|
| `gap_type` | `source` cuando falta la fuente, `knowledge` cuando la fuente existe y no se ha procesado |
| La pregunta | Concreta y contestable. No "falta información de arquitectura", sino "¿cuál es el core bancario y en qué versión corre?" |
| El destinatario | Un rol con nombre, del lado del cliente o del lado del SME |
| `resolution_action` | Qué se hace cuando llegue la respuesta y en qué tabla aterriza |

### Gate de salida de R2

Los 38 procesos del modelo operativo tienen un Digital Twin que se pronunció sobre ellos, aunque el pronunciamiento sea un hueco. Ningún proceso queda sin pronunciamiento, porque un proceso sin dueño es hallazgo bloqueante del Brain Auditor. Y ningún hueco queda sin las cuatro cosas de la tabla de arriba.

---

## R3 — La brecha, que es el hallazgo

Se cruzan R1 y R2. Lo opera `dt-domain-architect`, que es dueño de `capabilities` y de `decisions`, con `dt-knowledge-manager`, que responde por el nivel de cada afirmación del cruce. Los hallazgos van a `findings`.

Hay tres tipos y conviene no mezclarlos, porque llevan a conversaciones distintas con el cliente.

| Tipo de hallazgo | Qué es | Qué conversación abre |
|------------------|--------|----------------------|
| **Brecha de negocio** | El modelo exige una capability y ninguna evidencia la cubre | Qué le falta al banco para competir, o qué nos falta a nosotros por saber. Las dos lecturas son válidas y hay que distinguirlas |
| **Deuda sin propósito** | Hay un componente o un gasto que no mapea a ninguna capability | Qué se está pagando sin que mueva un KPI |
| **Divergencia** | El modelo describe un proceso y la evidencia muestra que se ejecuta de otra forma | La más reveladora de todas. Es donde vive el conocimiento que ningún documento tiene |

Con fuente solo pública, el tipo que se va a poder producir es el primero, y con una advertencia grande: una brecha de negocio detectada sin evidencia del lado de TI **no distingue entre "el banco no lo hace" y "no sabemos si lo hace"**. Esa distinción es la diferencia entre un hallazgo y una acusación. Mientras R2 esté dominada por huecos, todo hallazgo de R3 se marca explícitamente como brecha de conocimiento y no como brecha de capacidad.

Los otros dos tipos requieren evidencia del landscape y por lo tanto no se pueden producir todavía. Decirlo es parte del entregable.

### Gate de salida de R3

Cada hallazgo tiene su tipo, su nivel de certeza, la evidencia que lo sostiene con el nivel que esa evidencia tenía al momento del cruce, y la distinción explícita entre brecha de capacidad y brecha de conocimiento. Ningún hallazgo sin esa distinción sale del gate.

---

## R4 — El consejo

El brain es un motor de razonamiento y no un tablero de medición. Un hallazgo sin alternativas es una medición, y el valor está en lo que sigue: para cada hallazgo, el Digital Twin dueño propone al menos un conjunto de opciones, con lo que cada una supone y con el nivel del conocimiento que la sostiene.

La forma la fija la Regla B43. Toda decisión trazable guarda las opciones descartadas, el conocimiento que la sostuvo con el nivel que tenía en ese momento, el rol que decidió y, después, el resultado. Ese último campo es el que convierte al brain en aprendiz: si aconsejó algo y el KPI no se movió como se esperaba, eso se registra, porque es el hallazgo más valioso que el brain puede producir sobre sí mismo.

Dos límites duros en esta ronda:

Primero, **ninguna decisión de gate se sostiene sobre conocimiento que no sea gold**. Retirar un sistema, hacer un cutover o declarar cumplimiento regulatorio exige gold, sin excepción. Con el corpus de hoy, R4 puede proponer y no puede decidir.

Segundo, **nada de lo que salga de aquí lleva tarifas ni estimaciones de costo**. Si el consejo toca esfuerzo o precio, se escala a Pricing and Commercial Modeler. El brain aporta el alcance y los supuestos, no el número.

---

## La capa transversal: los cinco Digital Twins de ingeniería

Corren durante las cinco rondas. No razonan sobre Banco Ripley: razonan sobre el brain como producto.

| Digital Twin | Qué gobierna en este análisis |
|--------------|------------------------------|
| `dt-source-steward` | El catálogo de fuentes y la clasificación de nivel por tipo de fuente. En un análisis de fuente pública es el Digital Twin más determinante, porque de su clasificación depende el nivel de todo lo demás |
| `dt-build-operator` | Las reglas P1 y P2: ningún dato en el brain sin el parser o el conector capaz de recrearlo desde la fuente original. Un PDF de la CMF se procesa con un parser versionado, no se transcribe a mano |
| `dt-brain-engineer` | `brain.py` con su interfaz estándar, los generadores y el portal. La Regla P4 es inviolable: el portal se genera, nunca se escribe a mano |
| `dt-human-reviewer` | La cola de validación. Es el cuello de botella real y conviene tratarlo como tal desde el principio: qué afirmación necesita qué persona, y en qué orden |
| `dt-brain-auditor` | Las nueve dimensiones y el proceso 18 del modelo operativo. Corre en cada rebuild y bloquea si hay errores |

---

## Lo que cambia respecto de México

Esta es la sección que hay que leer antes de reusar cualquier artefacto del estate. Banco Ripley es el primer cliente fuera de México y la capa local no se traduce, se construye.

| Dimensión | México | Chile | Por qué importa |
|-----------|--------|-------|-----------------|
| Supervisor | CNBV y CONDUSEF por separado | Comisión para el Mercado Financiero, integrada | Cambia el interlocutor y cambia el cuerpo normativo completo |
| Banco central | Banxico | Banco Central de Chile, con su Compendio de Normas Financieras | Cambia el régimen de pagos y de encaje |
| Protección al consumidor | CONDUSEF y PROFECO | SERNAC | Cambia el régimen de reclamos y de publicidad financiera |
| Cuerpo normativo bancario | Circular Única de Bancos | Recopilación Actualizada de Normas de la CMF | Ningún capítulo es equivalente uno a uno |
| Unidad indexada | UDI | **Unidad de Fomento, UF** | El detector de riesgo de equivalencia del asset tiene UDI en su taxonomía y necesita UF. Es cambio de código, no de documentación |
| Tope de tasa | No hay equivalente directo | **Tasa Máxima Convencional** | Es una regla de negocio dura que el core tiene que evaluar en cada originación. No tiene contraparte mexicana |
| Costo informado al cliente | CAT | **Carga Anual Equivalente** | Fórmula y obligación distintas |
| Pagos minoristas | SPEI, CoDi, DiMo | Transferencias electrónicas y cámara de compensación, con un ecosistema de adquirencia de cuatro partes | No existe un equivalente de SPEI. Reusar el vocabulario de pagos mexicano sería un error de fondo |
| Finanzas abiertas | Ley Fintech y sus circulares | **Ley Fintec 21.521** y el Sistema de Finanzas Abiertas | Calendario en movimiento durante 2026, ver abajo |
| Datos personales | LFPDPPP | **Ley 21.719**, con autoridad de control propia | Cambia el régimen de tratamiento y de sanción |
| Fraude en medios de pago | Régimen general | **Ley 20.009 y su reforma** | Material para un banco centrado en tarjeta: define quién absorbe la pérdida |
| Portabilidad | Régimen de portabilidad de nómina | **Ley 21.236 de portabilidad financiera** | Afecta directamente el ciclo de vida del cliente de crédito |
| Marco de capital | Basilea III vía CUB | Basilea III vía la reforma a la Ley General de Bancos | Mismo marco internacional, distinta implementación local |

### Lo que está en movimiento y hay que verificar antes de usarlo con el cliente

El Sistema de Finanzas Abiertas de la Ley Fintec tenía entrada en vigor prevista para julio de 2026 y durante el primer semestre de ese año la CMF puso en consulta una extensión de doce meses adicionales. A fines de abril de 2026 la presidenta de la CMF declaró que veía complejo que el sistema estuviera operativo en julio y que la normativa seguía en revisión. Hay además referencias a una norma de carácter general con las reglas técnicas del sistema, fechada en junio de 2026, que no está verificada contra el texto oficial.

Tres cosas que quedan marcadas como por confirmar y que no deben entrar al brain como gold hasta verificarse en el sitio de la CMF y en el Diario Oficial: la fecha efectiva de entrada en vigor del Sistema de Finanzas Abiertas, el número y contenido de la norma técnica que lo regula, y la fecha de entrada en vigencia plena de la Ley 21.719 de protección de datos personales.

---

## Handoffs que este análisis necesita

El brain no inventa la ontología de la industria (Reglas B19 y B23). Estos son los pedidos concretos, y el primero es bloqueante.

| Destinatario | Qué se le pide | Bloquea |
|--------------|----------------|---------|
| `SME/Industry/Industry Banking/` | La capa Chile: el equivalente de `kb-banking-regulacion-mx.md` y de la extensión de productos de banca múltiple, construida contra la Recopilación Actualizada de Normas y el Compendio de Normas Financieras | **R1 en todos los dominios regulados** |
| `SME/Industry/Industry Banking Accounting/` | El equivalente chileno del Compendio de Normas Contables de la CMF, para el reporte regulatorio | `dt-enterprise-functions-owner` |
| `SME/Industry/Industry Payments/` | Tarjetas, adquirencia de cuatro partes y el régimen de la Ley 20.009 | `dt-operations-owner` y `dt-channel-owner` |
| `SME/Industry/Industry Retail/` | La cara retail del canal tienda, para el binding de cadena de valor | `dt-channel-owner` y `dt-distribution-owner` |
| `SME/Framework/IT Operating Model/` | Confirmación de que los 38 procesos aplican sin ajuste local | R2 completa |

---

## Lo que este método no hace

No produce un assessment 7R. Eso exige inventario de aplicaciones y evidencia de código, y vive en Application Modernization.

No sustituye las cuatro etapas del gemelo cognitivo. Cuando haya código fuente de un sistema, ese sistema abre su propio brain de tipo `system` bajo `systems/`, y ahí corren Lenguaje, Almas, Biografía e Intención.

No es una propuesta comercial. No lleva tarifas, no lleva estimaciones de esfuerzo y no lleva precio. Si el análisis deriva en una conversación comercial, el paquete se arma con Pricing and Commercial Modeler.

No decide nada. Con el corpus de hoy, todo lo que produce es silver en el mejor caso, y ninguna decisión de gate se sostiene sobre silver.

---

## Criterio de cierre del análisis

El análisis de la situación está terminado, en su versión de fuente pública, cuando se cumplen cinco cosas:

Las cinco rondas pasaron su gate de salida. Los 38 procesos del modelo operativo tienen un Digital Twin que se pronunció. Los ocho dominios L1 de negocio tienen su modelo declarado o su hueco abierto. Cada hallazgo distingue brecha de capacidad de brecha de conocimiento. Y el tablero de niveles dice, sin maquillaje, qué proporción del análisis es gold, qué proporción es silver y qué proporción sigue siendo un hueco con destinatario.

Ese último punto es el entregable real de esta versión. Un análisis de la situación honesto sobre un banco al que todavía no tenemos acceso no se mide por cuánto afirma: se mide por la calidad de las preguntas que deja planteadas y por saber exactamente a quién dirigirlas.

---

*Metodología del asset Enterprise Brain instanciada para Banco Ripley Chile. Accenture México, Digital Core.*
