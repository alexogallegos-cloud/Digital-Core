# Unity — Programa de Modernización del Core Bancario BanCoppel
# project_type: core-banking-modernization
# project_state: active
# platform: Temenos Transact
# horizon_present: productos en producción sobre Temenos (pendiente de especificar)
# horizon_future: capabilities en construcción hacia sustitución o coexistencia con Informix
# replaces_or_complements: systems/core/Informix (baseline actual)

> **Tipo:** Proyecto de modernización (no es un sistema técnico — ver `systems/` para sistemas en producción)
> **Estado:** `[STATE: ACTIVE]` — productos en producción + construcción activa  
> **Release activo:** R4 — Tarjeta de Crédito (Producto 4900) · Go-Live: enero 2027  
> **Última actualización:** 2026-08-19

---

## ¿Qué es Unity?

Unity es el **programa estratégico de BanCoppel para modernizar el core bancario**, basado en la plataforma **Temenos Transact**. Nació con la visión de sustituir el core actual (IBM Informix / PISA), lanzando primero productos nuevos sobre la plataforma moderna.

El programa opera en dos horizontes simultáneos:

| Horizonte | Descripción |
|-----------|-------------|
| **PRESENTE** | Productos ya en producción sobre Temenos Transact — knowledge verificado |
| **FUTURO** | Capabilities en construcción — knowledge incubado, sujeto a evolución |

> **Regla de oro:** Todo artefacto en este proyecto debe declarar explícitamente si describe el PRESENTE o el FUTURO. Nunca mezclar sin etiqueta.

---

## Relación con el Core Actual (Informix)

Los escenarios de coexistencia no están cerrados. Los posibles:

| Escenario | Descripción | Probabilidad actual |
|-----------|-------------|---------------------|
| **Sustitución total** | Unity reemplaza Informix capability por capability | Visión original — largo plazo |
| **Coexistencia permanente** | Ambos sistemas operan en dominios distintos indefinidamente | Escenario probable |
| **Híbrido** | Unity reemplaza algunos dominios; Informix persiste en otros | Escenario actual |

La `migration_fate` de los SPs Informix (registrada en `systems/core/Informix/digital-brain/brain.db`) refleja el estado actual de esta decisión por capability.

---

## Arquitectura del Brain del Proyecto

El `digital-brain/brain.db` de Unity acumula conocimiento **forward** — diferente al brain de Informix que analiza código existente.

| Tabla | Qué almacena |
|-------|-------------|
| `products` | Productos que Unity entrega (PRESENTE y FUTURO) |
| `capabilities` | Capabilities ETB cubiertas, en desarrollo, o planeadas |
| `decisions` | ADRs del programa (coexistencia, arquitectura, tecnología) |
| `coexistence_rules` | Reglas de routing entre Unity e Informix por canal/producto |
| `informix_migration_map` | Mapeo de capabilities Informix → Unity por status |
| `program_stakeholders` | Registro ejecutivo de stakeholders del programa (62 personas: sponsors, directores, track owners, equipo ACN, vendors — incluye alerts EY como competidor) |
| `capability_stakeholders` | SMEs ACN + arquitectos + owners por capability (RACI técnico) |

---

## Conexión con bank-brain

El `bank-brain` federa este brain para responder:
- ¿Qué capabilities ETB cubre Informix HOY en producción?
- ¿Qué capabilities tiene Unity en producción?
- ¿Qué capabilities están en construcción en Unity?
- ¿Qué gap queda sin cobertura en ninguno de los dos?

---

## Productos Unity

| ID | Producto | Status | Release | Plataforma | Informix: reemplaza / complementa |
|----|----------|--------|---------|------------|----------------------------------|
> **Unity tiene DOS productos.** No cinco. El alcance formal del programa, declarado en el documento que va a CNBV, son dos productos más un proceso y un entregable regulatorio.

**Los dos productos del alcance** (`scope = cnbv-scope` en `brain.db::products`):

| ID | Producto | Segmento | Status | Release | Plataforma | Reemplaza |
|----|----------|----------|--------|---------|------------|-----------|
| UNITY-R4-P4900 | **Tarjeta de Crédito** | Persona física | `building` | **SmartVista R4** ✓ | SmartVista (BPC) + APOLO | CMS / Intercard / Macweb |
| UNITY-RX-P-PS | **Crédito Simple Empresarial** | **Persona moral** | `planned` | **Transact R4** ✓ | Temenos Transact (CBS) | — |

**Fuera del alcance de dos productos** (`scope = prior-scope`) — productos de captación en producción sobre Transact, no listados en el documento CNBV:

| ID | Producto | Status | Release |
|----|----------|--------|---------|
| UNITY-R1-P-CE-N2 | Cuenta Efectiva N2 | `live` | sin fuente* |
| UNITY-R2-P-CED-N4 | Cuenta Efectiva Digital N4 | `live` | sin fuente* |
| UNITY-R3-P-NOM-N4 | Nómina N4 | `live` | sin fuente* |

> ✓ = release con respaldo documental textual. \* = el número de release **no tiene fuente**; ver la sección de numeración de releases.

> **DATO-REQUERIDO**: confirmar si estos tres fueron entregados por releases anteriores de Unity o si nunca pertenecieron al programa. Señal a favor de lo segundo: el `Roadmap Unity 2025.pptx` etiqueta el bloque como *"CUENTAS - N2/N4 (Legado)"*.

---

## Alcance Formal del Programa (documento CNBV)

`Documento de Arquitectura UNITY_v1.0.docx` es la declaración autoritativa de alcance, redactada para revisión y autorización de **CNBV**. Declara cuatro componentes:

| # | Componente | Tipo | Plataforma |
|---|------------|------|------------|
| 1 | OnBoarding Digital Apolo | Proceso | Apolo (AppWhere) |
| 2 | **Tarjeta de Crédito — CMS** | Producto | SmartVista (BPC) |
| 3 | **Crédito Simple Empresarial — CBS** | Producto | Temenos Transact |
| 4 | Reportes Regulatorios | Entregable regulatorio | Multi-fuente (TDC y CSE) |

**Crédito Simple Empresarial** es crédito para **persona moral**, no crédito personal. El promotor genera la carpeta empresarial (escritura constitutiva, poderes notariales, representante legal); el analista centralizador valida y solicita el alta. Soportado por OnBase, PISA y Temenos Transact. Módulos Transact relevantes: garantías colaterales, préstamos de modelo, préstamos y montos dispuestos de líneas.

> **DATO-REQUERIDO**: ningún documento equipara "Crédito Simple Empresarial" (nombre del documento CNBV) con "Préstamo Simple" (nombre del Design Authority). Podrían ser el mismo producto o dos distintos. Confirmar con PMO antes de tratarlos como uno.

---

## Reportes Regulatorios — Cuarto Componente del Alcance

Caracterizado por barrido documental el 2026-08-19. No tiene DT propio ni fase en el lifecycle todavía.

**Cadena de generación** (cita: *"Cadena: Temenos TDH → DataStage → DWH → RiskLogic → reportes CNBV (R-04-C, calificación cartera)"*): Temenos Transact vía TDH, SmartVista BPC y Apolo alimentan por DataStage un DWH, del que RiskLogic y Bajaware generan los reportes. Todo on-premise; el documento de arquitectura declara explícitamente que *"se mantiene a como se tenía establecido previamente"* y que no requiere alta disponibilidad.

**Reguladores.** No son solo CNBV y Banxico. La documentación nombra **CNBV, Banxico, IPAB y CONDUSEF**, más PROFECO en regulaciones locales y SAT por la vía CFDI. VISA y MasterCard aparecen como destinatarios de reportes tipificados como regulatorios. Aplica también LFPIORPI para PEP y KYC. **CNSF y SHCP no aparecen** en ningún documento.

**Volumen.** Tres cifras distintas y no reconciliadas: serie **R-04-C** más calificación de cartera; **18 reportes** en el bloque de SmartVista (cartera, número de tarjetas, apertura por mes); y **~20 reportes SPL** en el legado disparados por Control-M con frecuencias diaria, mensual, trimestral, semestral y anual. Una minuta estima *"alrededor de 100 reportes"* con la anotación *"por confirmar"*.

> **Cuidado con "0430 al 0440"**: ese rango solo aparece en el documento de arquitectura. El único otro uso de "0430" en la documentación es un **tipo de mensaje ISO 8583**, no un reporte CNBV. Posible homónimo.

**Owners identificados**: Gustavo Martínez Martínez (dueño de negocio, *"Reporte Autoridades"*), Selene Esparza (arquitectura de la cadena UNITY-RegRep), Diana Patricia Morales Ramírez (representante en mesas SmartVista). No hay owner de Design Authority asignado al componente.

### Riesgos abiertos del componente

| # | Riesgo | Evidencia |
|---|--------|-----------|
| 1 | **Documentación CNBV desactualizada, con hallazgo formal de severidad Alta** | Hallazgos APO_F01 y SMA_F01: *"se identificó la incorporación de herramientas tecnológicas adicionales que no estaban contempladas en la arquitectura de referencia aprobada ni declaradas en la documentación presentada ante la CNBV"*. Owner Mercedes Espinosa Cortés. Pide *"plan de actualización y regularización de la documentación presentada ante la CNBV"* |
| 2 | **Bajaware está en decomiso mientras la arquitectura aprobada depende de él** | *"En proceso de Baja - Decomiso Fecha 1er Bimestre 2027"*, y el documento CNBV lo declara como uno de los dos motores de generación |
| 3 | **IC-83: los pipelines DataStage se rompen al decomisar Informix** | Quinta decisión crítica del Design Authority. Estado Gap, owner *"Por asignar"*. T-17 y T-19 en Confianza Baja, y su definición no existe en la documentación |
| 4 | **Cobertura de Apolo y SmartVista nunca evaluada** | El mapa de capacidades marca *"P — En producción"* con la columna de gap vacía, pero las columnas de Apolo y SmartVista dicen literalmente *"← completar"* |
| 5 | **No es stream propio en R4** | Está anidado bajo *"5 CONTABILIDAD"* en el plan de trabajo. La capacidad *"2.4.2 Reportería"* es P1 con alcance no confirmado |
| 6 | **Descuadre por códigos compartidos** | El código 43 de SmartVista agrupa motivos de baja distintos, lo que *"podría alterar la veracidad de los reportes entregados a las autoridades reguladoras"* |
| 7 | **Homologación de comisiones bloqueada por normatividad** | *"no puede avanzar técnicamente hasta confirmar aprobación de normatividad y estatus en Banxico/RECO"*. 2 User Stories Must regulatorias bloqueadas por DTMs sin fecha |
| 8 | **Exodus Ola 6 declara migrarlos pero no los inventaría** | La ficha de Ola 6 dice migrar *"Reportes Regulatorios CNBV"* pero su lista es de 3 sistemas: Intranet, Contabilidad y DWH. Las apps 96, 97 y 100 no aparecen en ninguna ola |

**Retención**: *"Copias inmutables (WORM) retenidas por un periodo regulatorio de 5 a 10 años conforme a la CUB de la CNBV"*.

---

## Barrido de Verificación Documental (2026-08-19)

Barrido de 257 documentos del corpus con cross-reference por cita textual. Reglas derivadas.

### ⚠️ Riesgo de autorreferencia en nuestros propios entregables

Cuatro de las cinco banderas rojas que citamos sobre el legado se sostienen **solo** en entregables de Accenture de julio 2026 (`Design_Authority_v1.2` y `Catálogo de Capacidades de Interoperabilidad v0.1`) que **se citan mutuamente** vía los IDs ARQ-07, IC-82 e INT-09. Ninguna fuente de BanCoppel las respalda.

La única con respaldo independiente y anterior del banco es *"el decomiso del Sistema Legado, el cual no está confirmado si se puede realizar ni como se realizaría"* (`20260706_Arquitectura UNITY.pptx`, 6-jul-2026).

> **Regla**: antes de presentar una cifra del legado al cliente, verificar si su única fuente somos nosotros. Si el cliente audita el Plan Director, cuatro de cinco banderas resultan autorreferenciales.

### Cifras huérfanas — no usar sin calificar

| Cifra que citábamos | Estado real |
|---|---|
| **128 aplicaciones** de PISA | Huérfana y sobre-atribuida. La versión previa del mismo deck decía **114**, sin que cambiara ninguna fuente. Los inventarios reales dicen 116, 124, 125 y 129, y son totales del legado del banco, no de PISA |
| **13,000–14,000 SPLs** sin mapear | Huérfana. Solo en 4 documentos nuestros que se citan entre sí. Cifras alternativas: el inventario del propio banco (`Inventario_bdanalisis`, ago-2026) suma **17,380** SPs declarados en Informix; Exodus planea refactorizar **7,480** con desglose auditable por ola; el mismo informe de Exodus dice también "10,000+" |
| **10,144 stored procedures** (nuestro brain) | **Es la única cifra con base empírica.** Proviene del parseo del código fuente real. Hay que defenderla explicando que cuenta SPs reales en las bases entregadas, no estimaciones por aplicación |
| **80 SUDs ejecutan SPL** | Error de categoría. El dato real es **80 de 88 System Understanding Documents referencian** Informix, OLTP o SPL. Un SUD es un documento nuestro, no un sistema del banco |

### Versión de Informix — nuestro brain es el correcto

El corpus de Unity dice *"Informix 12"* y *"Informix 12.10 – Core Bancario"*. **Está desactualizado.** El log de operación de la instancia productiva dice textualmente:

```
IBM Informix Dynamic Server Version 14.10.FC10W2 -- On-Line (Prim) -- Up
```

> Fuente: `systems/core/Informix/source/logs/.../ifmx_stats_coppel_shm_*.txt`, salida directa de la instancia. Prevalece sobre la documentación del programa. El módulo Contabilidad también está documentado en v14.

### La afirmación sobre EY no se sostiene como la teníamos

La palabra "incumbente" no existe en el corpus. Los releases de Transact son **R1 a R4**, no R1 a R3, y **el propio documento de EY contiene alcance R4** (*"R4 — Originaciones de procesos"*, *"R4 — Pago de Créditos/Amortizaciones"*). No hay ninguna evidencia de que EY salga del programa, y sí indicios en contra: figura como colaborador del Master Test Plan.

Redacción defendible: *EY es responsable de la arquitectura objetivo de Transact (ARQ-10, E-AQ-EY) y autor del documento de cobertura por release; su alcance contractual y su participación en R4 no están documentados.*

> **Falso positivo a evitar**: los hostnames `BPrismEYR1Mty`, `BluePrismEYR2Cul` y `BluePrismEYR4Cul` son bots **Blue Prism**, no releases de EY.

### Golden Record — hallazgo que reordena el decomiso

El Golden Record **vive hoy en Informix**, no en ATLAS ni en Transact. Cita del documento CNBV: *"El cliente se generará en la base de datos de Informix (PISA) donde BanCoppel utilizará esta base de datos para almacenar el Golden Record del cliente"*.

Hay tres candidatos simultáneos: Informix (operativo hoy), ATLAS/AlloyDB (Fase 2 sep-2026, sin diseño) y Transact (nunca activado en ningún release). Y la carga inicial de Informix hacia ATLAS *"no aparece en ningún documento del programa"*.

> Consecuencia: el decomiso de PISA está bloqueado por la **propiedad del Golden Record**, al mismo nivel que por los stored procedures. No estaba en nuestro análisis.

### Sistemas de primer orden que faltaban en el inventario

| Sistema | Qué es | Proveedor |
|---------|--------|-----------|
| **SIF (Sistema Integral Financiero)** | El producto core real que corre sobre Informix. Informix es el motor, SIF es la aplicación | Grupo PISA |
| **SOC (Sistema Operativo Central)** | Mini-core bancario, 15 módulos y 710 funcionalidades. Destino de migración de módulos del SIF | TASF |
| **Temenos Data Hub (TDH)** | Extracción near-realtime de Transact. Alimenta el ODS y los reportes regulatorios | Temenos |
| **InterAct Router / Switch** | Middleware transaccional. Es **una de las 3 únicas vías válidas al core** | Syndein |
| **IBM BUS (IIB/ACE)** | ESB corporativo. Otra de las 3 vías al core | IBM |

> Las 3 únicas vías al core son: conexión directa a BD por ODBC/JDBC/SPL, InterAct, e IBM BUS. Informix **no** recibe REST, SOAP, ISO 8583 ni SFTP directo.

**ATLAS está en GCP, no en AWS**, y es un MDM de **grupo** (retail Coppel, banco y Afore), no solo bancario. Usa AlloyDB para el Golden Record, Cloud Run, Vertex AI Vector Search para fuzzy matching y Apigee. Su proveedor no está documentado.

### Retirar del inventario de sistemas

No son sistemas: **DPP** (funcionalidad de SmartVista, "Deferred Payment Plan"), **CrediSoluciones** (producto comercial y transacción SIWEB 623), **BYU0039** (ticket de defecto BPC de severidad High), **Forza** y **TGS** (proveedores de maquila), **SUD** (tipo de documento). **Estados de Cuenta** solo tiene como evidencia una etiqueta en un diagrama.

### Desambiguaciones obligatorias

- **BRM** tiene tres referentes distintos: WebMethods BRM (Software AG), Experian BRM (motor de evaluación) y BRM Coppel (web service de Red Coppel).
- **Prometeo** y **OnBase** están fusionados en un inventario y separados en otro, con stacks incompatibles.
- **SOC** tiene dos expansiones: "Sistema Operativo Central" (mayoritaria) y "Sistema de Operación Central".
- **BPC** se expande mal como "Banking Payments Context" en el documento de arquitectura. La razón social es **BPC Banking Technologies**.
- **Nunca cruzar inventarios por ID**: el ID 111 es "Prometeo Gestor Documental" en una matriz y "Administración ATM's (SPL)" en otra.

### Dos programas más que no teníamos

**Exodus** es un programa aparte, no parte de Unity: migración de datacenters de México a la nube 2026-2030, 6 olas más Ola 0, con el apagado de Informix en la Ola 6 (2029-H2). Los hallazgos de Unity lo tratan como tercero al que *"alinearse"*. Ningún documento de Exodus menciona Unity.

> **Tiene estructura y brain propios desde 2026-08-19**: [`projects/exodus/`](../exodus/CLAUDE.md) — 30 aplicaciones con assessment APO, 6 olas, 7 preguntas abiertas. Consultar con `python projects/exodus/digital-brain/brain.py coverage`.

**ACDC** es una tercera iniciativa corporativa de migración a la nube, par de Exodus, de la que no tenemos nada.

> **Implicación de negocio**: si el decomiso de Informix ocurre en Exodus Ola 6 y no en Unity, el business case de Unity (*"el decomiso de PISA es parte central del ahorro proyectado"*) descansa sobre el roadmap de **otro programa, sin dueño compartido**.

### Contradicción entre programas sobre el API gateway

El Plan Director declara Apigee con **EOL 2027** y migración a MuleSoft *"en curso"*, pero el mismo documento admite que *"no tiene plan ni inventario de APIs documentado"*. Exodus Ola 1 va en dirección **opuesta**: *"Mantener y migrar su gateway a Apigee"*. Y los Lineamientos StackTech del 11-ago-2026 listan una tercera opción: *"Apigee / WSO2 API Manager"*, sin MuleSoft.

Además son **dos** migraciones, no una: Apigee a MuleSoft (gateway) e IBM BUS/InterAct a MuleSoft (ESB).

---

## Numeración de Releases — Es por Plataforma, No del Programa

> **Regla crítica**: no existe un tren único de releases R1→R5 del programa. Cada plataforma numera sus propios releases y **coexisten dos "R4" simultáneos en plataformas distintas**. Confundirlos produce cronogramas y alcances falsos.

Fuente: `Bancoppel_Plan_Director_-_Design_Authority_v1.2.pptx`, slide 7 "Dominios en scope".

| Dominio | Plataforma | Releases declarados | Nota del Design Authority |
|---------|-----------|--------------------|--------------------------|
| Canales / Onboarding | Apolo | sin numeración propia | Arquitectura dual con Transact en CED N4: Apolo hace onboarding, Transact el core |
| Core Transaccional | Transact (T24) | **R1 a R4** | "Préstamo Simple es Transact R4, no Apolo" |
| Tarjetas y Pagos | SmartVista (BPC) | **R3, R4, R4.5** | TDC Clásica; escenario de despliegue R4 sin decidir |
| Legado | PISA / Informix | — | 128 aplicaciones; 13,000–14,000 SPLs sin mapa funcional; decomiso sin confirmar |
| Integraciones | Apigee · MuleSoft | — | ATLAS/Golden Record crítico para TDC R4 en sep-2026 |
| Datos / MDM | ATLAS · DataStage | — | Golden Record no activado en ningún release de Transact |

### Tren de releases por producto

**Tarjeta de Crédito (SmartVista)**

| Release | Alcance | Estado |
|---------|---------|--------|
| SmartVista R1 | **Configuración del gestor de TDC** (SmartVista como CMS) | ✅ **En productivo** — dic-2024, 38 funcionalidades, **sin canales listados** |
| SmartVista R2 | **Integración a App y onboarding de la TDC** | ✅ **En productivo** — jul-2025, 33 funcionalidades; App, Promotoría, Sucursal, SPEI |
| SmartVista R3 | **Tarjeta física**, liberada en modo Friends & Family | ✅ **En productivo** — sep-2025, 15 funcionalidades; depende de ATLAS a sep-2026 (decisión L-03 pide plan alterno) |
| **SmartVista R4** | **Tarjeta de Crédito Clásica — Producto 4900** | **Building — release ancla**, SIT 15-oct a 15-dic-2026, go-live ~15-ene-2027 |
| SmartVista R4.5 | Meses con intereses (MCI) en App | Backlog — el Design Authority nombra R4.5 pero no declara su alcance; el alcance viene del PreGame vía `dt-smartvista` |

**Producto 2 — Crédito Simple Empresarial (Temenos Transact)**

| Release del producto | Alcance | Release de plataforma | Estado |
|---------------------|---------|----------------------|--------|
| **R1** | Crédito simple a persona moral | Transact R4 | ✅ **En productivo** |

> **La decisión L-02 no es sobre el arranque del producto.** Como el R1 ya opera en producción, *"Estrategia Préstamo Simple: F&F vs migración de cartera"* tiene que ser sobre qué se hace con la **cartera empresarial existente en el legado**: dejarla donde está y captar solo negocio nuevo en Transact, o migrarla. Es consistente con sus dos entregables: E-MG-03 *"Decision Paper Préstamo Simple"* y E-MG-06 *"Revisión Plan Migración"*, el segundo condicionado a *"si E-MG-03 resulta en migración"*. La cartera vive en el legado vía **Orión SFI** (Crédito Comercial, proveedor TASF), cuyo destino declarado es *"Migrar (Transformar) a Temenos Transact"*.

> **Dos numeraciones que no se contradicen.** El producto está en su **R1**, su primer release (confirmado por el equipo el 2026-08-19). Ese R1 aterriza sobre **Transact R4**, que es el release de la plataforma que habilita el ciclo de vida de crédito. El Design Authority dice *"Préstamo Simple es Transact R4, no Apolo"* refiriéndose al tren de **plataforma**, no al del producto.
>
> Por qué difieren aquí y no en la TDC: Transact hospeda varios productos, así que su tren de plataforma va por delante del de cada producto. SmartVista solo hospeda la TDC, así que ahí las dos numeraciones coinciden.
>
> Según la fuente de EY, **Transact R4** habilita justamente lo que el crédito empresarial necesita: *"Originaciones de procesos"*, *"Pago de Créditos/Amortizaciones"*, *"Reestructuración / modificación de crédito"* y *"Procesamiento de cheques"*.
>
> El `Roadmap Unity 2025.pptx` **no le asigna número**: etiqueta sus barras como **"CSE"** (Despliegue, Desarrollo, Transición, Pruebas, Estabilización y Soporte) en paralelo a las barras R1, R2 y R3 del carril de TDC. También registra un análisis de variantes futuras: *"Análisis - Nuevos Productos (CSE Variantes | Cuenta Corriente | Factoraje)"*.

**Captación (Temenos Transact) — en producción, release sin verificar**

| Producto | Estado | Release |
|----------|--------|---------|
| Cuenta Efectiva N2 | Live | Sin fuente documental |
| Cuenta Efectiva Digital N4 | Live | Sin fuente documental — el DA habla de "Fase 1 de CED N4", lo que sugiere fases propias en lugar de un R2 |
| Nómina N4 | Live | Sin fuente documental |

> El Design Authority declara que Transact tiene "Releases R1–R4" y que R4 es Préstamo Simple, pero **nunca dice qué son R1, R2 y R3**. El mapeo a estos tres productos venía de síntesis previa del brain sin fuente. Señal contraria: el `Roadmap Unity 2025.pptx` agrupa "Onboarding | Cuenta N4 / N2" y "Go-Live Cuenta N4 / N2" como un mismo tramo, no como dos releases, y etiqueta "CUENTAS - N2/N4 (Legado)".

### Abreviaturas de release — no confundirlas

| Sigla | Significado | Qué denota | Fuente |
|-------|-------------|-----------|--------|
| **F&F** | **Friends & Family** | Modo de liberación: piloto acotado antes de disponibilidad general | `Roadmap Unity 2025.pptx` contrapone "Onboarding TDC Digital (Friends & Family)" con "(Manos del Cliente)" |
| **F&D** | **Física y Digital** | Forma del plástico: convivencia de tarjeta física y digital | `build-brain.py`: "card TDC F&D con convivencia física/digital; botoneras dinámicas por banderas" |

> No son la misma sigla, pero **no son excluyentes**. "TDC R3 F&F" significa el release de **tarjeta física** liberado en modo **Friends & Family**. Confirmado por el equipo el 2026-08-19 y sustentado por el DEF cuyo título es literalmente *"DEF Tarjeta física R3 desglozado Historia de Usuario"*. El error a evitar es el opuesto: tratar F&F como si fuera el alcance del release en lugar de su modo de liberación.

### Procedencia del alcance de R1 y R2

Confirmado por el equipo el 2026-08-19. **No es cita literal**: la frase "gestor de TDC" no existe en la documentación. Está sustentado de forma indirecta y convergente.

A favor: SmartVista está documentado como *"Administrador de Tarjetas"* y *"CMS (Card Management System) de BPC para gestión del ciclo de vida completo de la TDC"*, así que "configuración del gestor" describe la configuración de SmartVista. Para R2 hay dos cadenas que emparejan el gestor con exactamente lo que se describe: *"CMS Administrador de Tarjetas - Apolo Onboarding"* y *"CMS Administrador de Tarjetas - App Bancoppel"*. Y el encabezado del roadmap dice que las liberaciones cubren *"todo su ciclo de vida (Onboarding, Operación y Post-Venta)"*.

Señal estructural fuerte: **R1 tiene 38 funcionalidades y ningún canal listado**, mientras las listas de canales arrancan en R2. Un release con funcionalidad y sin canales es lo esperable de una configuración de plataforma.

> **Límite de verificación**: la lámina 2 del `Roadmap Unity 2025.pptx` contiene la matriz de releases, pero al extraerla a texto **se pierde la asignación de celda a columna** porque PowerPoint entrega las cajas en orden de creación, no de posición visual. Se ven los elementos "TDC Digital", "Configuración y Customización de Caja", "TDC Física" y "TDC MVP" sin poder saber a qué release corresponde cada uno. Además ese elemento dice "Caja" (ventanilla), no "gestor de TDC". **Para cerrarlo hay que abrir visualmente la lámina 2.**

### Qué hace realmente el R3 de tarjeta física

Su propósito no es emitir plástico: es **cerrar la brecha de valor** entre el producto que Apolo origina y el legado, para habilitar la migración del portafolio. Cita del DEF:

> *"Actualmente el producto de TDC clásica que se otorga desde Apolo (4900) tiene una brecha de valor al cliente respecto a lo que hoy en día oferta el producto vigente (6100)... El homologar las funcionalidades entre el legacy y Apolo nos permitirá empezar con la migración de portafolio a Smart Vista, así el cliente actual no pierde ninguna funcionalidad que hoy en día tiene."*

Alcance declarado: acceso a ATM para las operaciones que hoy hace un cliente legado, tarjetas adicionales para clientes que viven en SmartVista, contratación directa desde canal digital, generación de contratos, reportes automáticos y conciliación de pagos fijos, y rediseño de la App.

**El objetivo de negocio detrás es la migración de 3 millones de tarjetas**: *"Migrara el portafolio actual de 3 millones de tarjetas a Smart Vista"*, con una estimación de 122,000 clientes nuevos para 2025 y 2026.

> El portafolio de TDC es más amplio que la Clásica: **Oro (8100), Platinum (7000), Clásica (6001), Clásica Apolo (4900), Grupo Coppel e Infinite**, quedando paramétrico para nuevos productos. Reducir SmartVista a "TDC Clásica" describe R3 y R4, no el alcance del tren.
>
> Ojo con el código del legado: el mismo DEF dice **6100** en la introducción y **6001** en el alcance. El resto de la documentación usa 6001, y el cambio regulatorio se documenta como **6001 a 4900**. El 6100 es errata.

### Datos corregidos y pendientes

- **DATO-REQUERIDO**: el Design Authority lo llama "Préstamo Simple"; el documento CNBV lo llama "Crédito Simple Empresarial". Confirmar con PMO si son el mismo producto.
- **DATO-REQUERIDO (L-07)**: discrepancia declarada entre EY y el roadmap maestro sobre las fechas de Transact R1 y R2.
- **Corregido**: "R5 · ATM · Tarjetas adicionales · Corresponsales" se retiró de los artefactos. El `Plan de trabajo R4_v1 Julio` dice "disponible R5" para esos alcances pero nunca declara de qué plataforma, así que asignarlo a un R5 del programa era inferencia sin sustento.
- **Corregido**: "R6" y "R7+" se retiraron. Eran valores de una lista de validación de Excel en el RAID v2.0, no releases planeados.

Ver `dt/dt-productos.md` para el catálogo completo con componentes R4.

---

## Componentes R4

| ID | Nombre | Tipo | User Stories | Estado |
|----|--------|------|-----|--------|
| `smartvista` | SmartVista (BPC) | core | 22 | development |
| `apolo` | APOLO — Originación Digital | core | 22 | development |
| `app` | APP / AppMovil | channel | 18 | development |
| `cat` | CAT — Contact Center | channel | 12 | **at_risk** — proveedor no contratado |
| `siweb` | SIWEB — Sucursales | channel | 5 | **blocked** — esperando APIs |
| `cobranza` | Cobranza Direccionada | enabler | 37–50 | development |
| `apificacion` | Apificación (Accenture) | transversal | — | development |

---

## Cronograma R4

| Hito | Fecha | Estado |
|------|-------|--------|
| Cierre de análisis (último track) | 16 oct 2026 | pending |
| Cierre desarrollo + UT | 15 oct 2026 | pending |
| Inicio SIT | 15 oct 2026 | **at_risk** |
| Pentest Cobranza (conflicto SIT) | 15–20 nov 2026 | **at_risk** |
| Fin SIT / Code Freeze | 15 dic 2026 | pending |
| **Go-Live Producto 4900** | **~15 ene 2027** | pending |

Ver `dt/dt-cronograma.md` para el cronograma detallado con riesgos.

---

## Riesgos Críticos (resumen)

| ID | Descripción corta | Componente | Due Date |
|----|-------------------|-----------|----------|
| RISK-001 | Proveedor CAT no contratado | `cat` | 2026-08-31 |
| RISK-002 | 6 User Stories Must Have APP cierran en noviembre | `app` | 2026-10-01 |
| RISK-010 | Sin sign-off formal de negocio | transversal | 2026-09-15 |

Ver `dt/dt-riesgos.md` para los 10 riesgos con detalle completo.

---

## Decisiones de Arquitectura (ADRs del Programa)

| ID | Decisión | Status |
|----|----------|--------|
| ADR-UNITY-001 | Plataforma: Temenos Transact como nuevo core | Aceptada |
| ADR-UNITY-002 | *(pendiente: estrategia de coexistencia con Informix)* | Propuesta |
| ADR-UNITY-003 | *(pendiente: routing de canales por producto)* | Propuesta |
| ADR-UNITY-004 | SmartVista (BPC) como plataforma de gestión de tarjetas R4 | Aceptada |

---

## Digital Twins

| DT | Descripción | Archivo |
|----|-------------|---------|
| dt-productos | Catálogo de productos y componentes R4 | `dt/dt-productos.md` |
| dt-riesgos | Registro de 10 riesgos con mitigaciones | `dt/dt-riesgos.md` |
| dt-cronograma | Hitos R4 con semáforo de estado | `dt/dt-cronograma.md` |
| dt-smartvista | 58 HDUs · 14 DTMs · PreGame coverage · gaps críticos (DPP, BYU0039, OCG manual) | `dt/dt-smartvista.md` |
| dt-vendors | 8 vendors · SIAM model · CAT sin contratar (🔴 deadline 31-ago) · BYU0039 · DPP · maquiladores | `dt/dt-vendors.md` |
| dt-gobierno | Gobernanza del programa · comités · RACI · RAID owners · protocolo escalación | `dt/dt-gobierno.md` |
| dt-equipo | Equipo por componente · rotación 60% dic-ene · capacidad vs. demanda · change management | `dt/dt-equipo.md` |
| dt-coexistencia | Routing Informix↔Unity por canal/producto · tipos MONEY · migration_fate · parallel run | `dt/dt-coexistencia.md` |
| dt-slo-observabilidad | SLIs/SLOs por componente · criterios cuantitativos de cutover · business observability | `dt/dt-slo-observabilidad.md` |
| dt-sit-uat | Plan SIT/UAT por capability · conflicto pentest nov 15-20 · triage · criterios entrada/salida | `dt/dt-sit-uat.md` |
| dt-compliance | CNBV Art.76 LIC · PCI-DSS v4.0 scope SmartVista · CONDUSEF · timeline regulatorio | `dt/dt-compliance.md` |
| dt-ops-readiness | PRR por capability · runbooks · on-call model · DRP · rollback plan · handoff AMS | `dt/dt-ops-readiness.md` |
| dt-apolo | 37 HDUs · 17 BBs · plan integral 10 fases · 13 sprints backend · integración crítica SV (HDU-20) | `dt/dt-apolo.md` |
| dt-plan-director | Gobierno del programa por producto (TDC P4900) · KPI framework · 8 acciones críticas · RAG cruzado · anti-silos | `dt/dt-plan-director.md` |

---

## Fuentes Procesadas

| Carpeta | Status | Documentos |
|---------|--------|------------|
| `source/docs/Minuta de Sesiones/` | ✓ Procesada | 17 documentos (10 minutas + 7 sesiones trabajo User Stories) → `brain.db::track_analysis` (7 tracks) |
| `source/docs/RAID/` | ✓ Procesada | RAID_Log_Programa_Unity_R4_v2.0.xlsx — 18 riesgos, 4 supuestos, 3 issues, 2 dependencias · **Propuesta de RAID_R4.pptx — 3 slides · contexto de governance del RAID: por qué se creó, proceso de integración semanal, valor para Go/No-Go diciembre (solo contexto, datos ya en XLSX)** |
| `source/docs/Referencia Docs Bancoppel - Smart Vista y Canales/` | ✓ Procesada | HDU R4 canales (58 HDUs · 4 canals) + PreGame Appwhere → `dt/dt-smartvista.md` + `brain.db::hdu_catalog+dtm_catalog` |
| `source/docs/Referencia Docs Bancoppel - Plan de trabajo/` | ✓ Procesada | Plan de Trabajo XLSX (12-ago) → `brain.db::plan_progress` (11 actividades) · DEF PV ✓ · **Plan de trabajo R4_v1 Julio.pptx — baseline original: TDC=18 (SV=7+App=7+CAT=3+Promotoría=1) + Onboarding=27 (Apolo); scope out-of-scope confirmado (ATM, tarjetas adicionales, incrementos, corresponsales); R5 deferidos (cliente prospecto, retoma); stakeholders Barragán/Vázquez/Madinaveitia/Bueno; riesgos DTMs (R01) y Cobranza (R06) identificados desde julio → `dt/dt-cronograma.md` v1.1.0** |
| `source/docs/Referencia Docs Bancoppel -Apolo R4/` | ✓ Procesada | APOLO_R4_HDU_TDC.xlsm (37 HDUs) · Plan_Integral (10 fases, 13 sprints) → `dt-apolo.md` + `brain.db::apolo_hdu_catalog` · **ADP_Onboarding (17 DTMs REC_* · 8 Critical Breakers · equipo AppWhere · governance 5 comités) → `dt-apolo.md` v1.1.0** · **Plan Apolo N4 F2 (Gantt 151 días · tensión fechas 15-ene vs 22-ene) → `dt-apolo.md`** |
| `source/docs/Respaldo Docs Bancoppel - App/` | ✓ Procesada | 13 User Stories Jira (SMART-3962…4531) TDC F&D canal App → `brain.db::app_user_stories` |
| `source/docs/Roadmap Accenture/` | ✓ Procesada | BCPL_R4 Roadmap PPTX (5 tracks RAG · 8 acciones críticas · 9 User Stories R4.1) + Consolidacion User Stories v2 (76 User Stories scoring) + Inventario Integraciones v1.0 (18 integraciones) → `brain.db::user_stories_inventory + r4_integrations + track_rag` |

---

## brain.db — Estado v1.1.0 (2026-08-20)

> Build canónico generado por `build-brain.py --reset`. Tablas Marco 3D (`program_stakeholders`, `program_systems`, `it_capabilities`) pendientes de implementar en `build-brain.py` — ver Próximos Pasos.

| Tabla | Registros | Notas |
|-------|-----------|-------|
| `products` | 5 | 2 cnbv-scope (TDC P4900 · CSE) + 3 prior-scope (CED N4 · Nómina N4 · Cuenta Efectiva N2) · campo `scope` añadido v1.1.0 |
| `product_releases` | 8 | **NUEVO v1.1.0** — TDC: R1(dic-2024) R2(jul-2025) R3(sep-2025) R4(building) R4.5 R5 R6+ · CSE: R1(building) · 4 productivos |
| `program_capabilities` | 14 | Spine del brain — 1 configurable + 8 partial + 4 not_covered + 1 tbd · bloqueadas: 4 |
| `program_components` | 8 | 8 componentes R4 (2 en riesgo, 1 bloqueado) |
| `hdu_catalog` | 58 | 4 canales: SV(22) APP(20) CAT(12) SIWEB(5) — todos con capability_id |
| `dtm_catalog` | 14 | 5 con gap crítico — todos con capability_id |
| `apolo_hdu_catalog` | 37 | HDUs de APOLO originación digital: 22 VoBo + 10 MVP2 + 3 Taggeo + 2 Desestimada |
| `capability_vendors` | 22 | Vendor responsable por capability + status contrato |
| `capability_slos` | 14 | SLI/SLO targets por capability |
| `capability_test_plan` | 14 | Plan SIT/UAT por capability + bloqueantes |
| `capability_compliance` | 14 | CNBV Art.76 / PCI-DSS / CONDUSEF por capability |
| `capability_prr` | 14 | Production Readiness Review por capability |
| `capability_routing` | 11 | Routing Informix↔Unity por canal y capability |
| `capability_stakeholders` | 49 | SMEs ACN + arquitectos del programa + owners BanCoppel por capability (RACI técnico) |
| `track_analysis` | 7 | User Stories por sesión de trabajo: SV/APOLO/APP/CAT/SIWEB/Cobranza/Apificación — complejidad, integraciones, MoSCoW |
| `plan_progress` | 11 | **Corte 17-ago: global 21.19% real vs 60.58% esperado — 9 retrasadas, 2 a tiempo** |
| `product_vision_requirements` | 28 | RFs del DEF PV 1006626 — todos Alta/Esencial · canal: app(13) cat(4) cross(1) multi(4) siweb(2) smartvista(4) |
| `app_user_stories` | 13 | User Stories Jira canal App TDC F&D: backlog(8) release(3) removed(2) · SMART-3962…4531 |
| `user_stories_inventory` | 79 | **Actualizado v1.1.0** — Inventario con scoring MoSCoW: must=46 should=28 · apolo:22 app:18 cat:12 siweb:5 smartvista:22 · 3 HUs APP-ENC-nn añadidas |
| `r4_integrations` | 18 | Integraciones R4: API(15) Batch(2) Evento(1) · Nueva(9) Modificar(9) · SmartVista(7)+CAT(7)+APP(4) |
| `track_rag` | 5 | RAG por track (PPTX 11-ago): red=app,cat · yellow=smartvista,siweb,apolo · fuente: Roadmap Accenture |
| `risks` | 26 | **26 riesgos** (12 alta, 1 cerrado) — incluye 8 nuevos Reportes Regulatorios añadidos barrido 2026-08-19 |
| `raid_assumptions` | 4 | Supuestos RAID (sin validar) |
| `raid_issues` | 3 | Issues RAID (todos alta severidad) |
| `raid_dependencies` | 2 | Dependencias RAID (ambas severas) |
| `milestones` | 6 | Hitos de cronograma |
| `vocabulary` | 93 | **93 términos** — RAID v2.0 + SmartVista/Canales + F&F/F&D/Manos del Cliente añadidos v1.1.0 |
| `decisions` | 4 | ADR-UNITY-001 a 004 |
| `capability_360` | vista | Cross-join 7 dimensiones (vendors · SLOs · test · compliance · PRR · routing · stakeholders) |

## Plan Director — DTs v1.0.0 (2026-08-16)

| DT Plan Director | Propósito | Status |
|-----------------|-----------|--------|
| dt-gobierno | Gobernanza, comités, RACI, escalación | ✓ v1.0.0 |
| dt-vendors | SIAM, 8 vendors, CAT urgente, BYU0039 | ✓ v1.0.0 |
| dt-equipo | Equipo, rotación, capacidad, change mgmt | ✓ v1.0.0 |
| dt-coexistencia | Routing Informix↔Unity, migration fate | ✓ v1.0.0 |
| dt-slo-observabilidad | SLOs, cutover criteria, observability | ✓ v1.0.0 |
| dt-sit-uat | Plan pruebas, pentest conflict, triage | ✓ v1.0.0 |
| dt-compliance | CNBV Art.76, PCI-DSS v4.0, CONDUSEF | ✓ v1.0.0 |
| dt-ops-readiness | PRR, runbooks, DRP, rollback, AMS | ✓ v1.0.0 |
| **dt-plan-director** | **Gestión transversal por producto · KPI framework · dashboard RAG cruzado** | **✓ v1.0.0** |

## Próximos Pasos

- [x] Cargar productos live en `brain.db::products` (R1-R3+Rx) — v0.4.0
- [x] Procesar carpeta RAID/ — 18 riesgos, 4 supuestos, 3 issues, 2 deps — v0.3.0
- [x] Procesar carpeta SmartVista y Canales — 58 HDUs, 14 DTMs, `dt-smartvista.md` — v0.4.0
- [x] Elevar capabilities a spine del brain (`program_capabilities` + FK en HDUs/DTMs) — v0.5.0
- [x] 8 DTs plan director creados — v1.0.0
- [ ] **SIGUIENTE**: Enriquecer `build-brain.py` con semántica y ontología cross-DT (v0.6.0)
- [x] Capa semántica/ontológica v0.6.0 — `capability_vendors`, `capability_slos`, `capability_test_plan`, `capability_compliance`, `capability_prr`, `capability_routing`, `capability_stakeholders` (49 rows: SMEs ACN + arquitectos + owners BCO), vista `capability_360` 7 dimensiones
- [x] v0.7.0 — `track_analysis` (7 sesiones User Stories: MoSCoW, complejidad, integraciones, APIficación scope) + `plan_progress` (Plan de Trabajo 12-ago: avance global 20.66% vs 34%, 9 retrasadas, 3 críticas)
- [x] Procesar `DEF PV 1006626 Mercado Abierto (R4).docx` — 28 RFs en `brain.db::product_vision_requirements` — v0.8.0
- [x] Procesar `Respaldo Docs Bancoppel - App/` — 13 User Stories Jira TDC F&D en `brain.db::app_user_stories` — v0.9.0
- [x] Procesar `Roadmap Accenture/` — 76 User Stories scoring + 18 integraciones + 5 tracks RAG en `brain.db::user_stories_inventory+r4_integrations+track_rag` — v1.0.0
- [x] **v1.1.0 — `product_releases` (8 releases TDC+CSE con plataforma y estado) + campo `scope` en `products` (cnbv-scope vs prior-scope) + inventario HUs 76→79 (APP-ENC-01/02/03 Encendido/Apagado TDC F&D) + `plan_progress` actualizado a corte 17-ago (21.19% vs 60.58%) + vocabulario F&F/F&D/Manos del Cliente + 8 riesgos Reportes Regulatorios + portal lifecycle-p4900.html + barrido documental 257 docs**
- [ ] **v1.2.0 — Marco 3D SISTEMA: `program_systems` (11: smartvista · transact · informix · apolo · app-movil · siweb · cat · atlas · controlm · eglobal · connect-direct con togaf_type+togaf_state+vendor) + `it_capabilities` (13 top-level: qe · devops · ambientacion · seguridad · interoperabilidad · data · arquitectura · change-mgmt · ai · release-management · vendor-management · observabilidad · compliance) + ejes system_id/itcapability_ids en RAID y user_stories_inventory**
- [ ] **v1.3.0 — Marco 3D STAKEHOLDER: `program_stakeholders` (62 personas: sponsors(2) · director(1) · PM(1) · track_owners(7) · pmo(4) · arquitectos(4) · acn(12) · vendors(6) · otros) + QE sub-caps (qe-strategy · qe-tem · qe-tdm) en `it_capabilities` (16 total)**
- [ ] Mapear capabilities ETB de los productos live en `brain.db`
- [ ] Registrar ADR-UNITY-002 (coexistencia) + ADR-UNITY-003 (routing)
- [ ] Conectar al `bank-brain` vía ATTACH

---

*Creado: 2026-08-15 · Actualizado: 2026-08-20 (v1.1.0: product_releases · scope cnbv · 79 HUs · plan 17-ago · lifecycle-p4900.html · barrido 257 docs · brain.db Estado corregido a v1.1.0 — v1.2.0/v1.3.0 Marco 3D pendientes de implementar en build-brain.py)*
