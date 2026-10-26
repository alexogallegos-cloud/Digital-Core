# Laboratorio de Aceleración — Plan de Trabajo

> Proyecto: `projects/laboratorio-aceleracion/`, capa Change the Bank
> Versión 0.1, 19 de octubre de 2026
> Ancla contractual: Anexo B del Contrato Maestro 2022.021519, vigencia del 12 de octubre de 2026 al 11 de octubre de 2029
> Fuentes: `source/sow/` (Anexo B firmado) y `source/docs/Banamex_LaboratorioAceleracion_v8.pptx`

---

## Lo primero: dónde estamos parados en el calendario

El Anexo B arrancó el lunes 12 de octubre de 2026. Hoy es lunes 19 de octubre, día ocho de
vigencia, segunda semana. Eso importa porque el Anexo fija dos entregables con fecha dura:

**El diseño de arquitectura y seguridad y el laboratorio base habilitado se entregan "una
única vez al primer mes del proyecto durante la fase de on-boarding".** El primer mes vence el
miércoles 11 de noviembre de 2026. Quedan veintitrés días naturales.

El diseño de solución comprometió además una habilitación de una semana, con sandbox operado al
quinto día, y una activación de seis semanas. Esas duraciones son del deck, no del Anexo: el
contrato no fija plazo de implementación para ninguno de sus tres componentes, y su única fecha
de implementación es el primer mes para los entregables 1 y 2.

Por eso la ventana de implementación se fijó en cuatro semanas, del 12 de octubre al 6 de
noviembre. La activación se comprime de seis semanas a tres. La primera verificación del plan es
contrastar el estado real de la habilitación contra lo que se comprometió en la semana 1.

---

## La frontera contractual, que es el punto más importante de este plan

La tabla de workstreams de la que parte este plan tiene seis entradas. Solo dos de ellas
corresponden a obligaciones del Anexo B. Conviene decirlo antes de planear nada, porque de lo
contrario el equipo termina entregando gratis cuatro workstreams completos.

El Anexo B contrata **la habilitación, activación y operación de un laboratorio Cloud aislado
para construir, integrar y probar productos digitales contra servicios de Core emulados y
datos sintéticos**, prestado como servicio administrado. Y es explícito en lo que excluye: *la
conexión con entornos productivos o con el Core real no forma parte del alcance*.

| Workstream | ¿Está en el Anexo B? | Qué significa para el plan |
|---|---|---|
| Base Laboratorio | Sí, es el núcleo | Entregables 1 y 2 del Anexo, con fecha al primer mes |
| SDLC | Parcialmente | El flujo SDLC y sus pipelines están en Activación. El business case no es entregable contractual |
| Modernización Core Bancario | No | El Anexo excluye el core real. Es agenda de uso, necesita vehículo propio |
| TSA Exit | No | Es la razón de ser del laboratorio, pero el análisis de TSAs no es un servicio contratado aquí |
| Future Bank | No | Es la cartera que llenará el laboratorio de demanda. No es entregable del Anexo |
| BAU o proyectos existentes | No | Sin entregables definidos ni en la tabla ni en el Anexo |

Esto no quiere decir que los cuatro workstreams de abajo sobren. Al contrario: son la razón
por la que el laboratorio tiene sentido y la fuente de la demanda que define la talla
contratada. Lo que quiere decir es que el plan tiene que correr en dos pistas con reglas
distintas, y que ninguna promesa de la pista de agenda puede presentarse al cliente como
compromiso del Anexo B sin una orden de servicio o un control de cambio que la respalde.

---

## Pista contractual: los cinco entregables del Anexo B

| # | Entregable | Contenido mínimo según el Anexo | Criterio de aceptación | Frecuencia |
|---|---|---|---|---|
| 1 | Diseño de arquitectura y seguridad | Arquitectura lógica, segmentación, identidad, cifrado, trazabilidad, conectividad permitida y guardrails | Revisión conjunta con Arquitectura y Seguridad del banco, con observaciones críticas resueltas o aceptadas | Única, primer mes |
| 2 | Laboratorio base habilitado | Cuentas, red, identidad, auditoría, repositorios, pipeline, catálogo y sandbox inicial | Ejecución satisfactoria de pruebas de conectividad, acceso, despliegue, auditoría y aislamiento | Única, primer mes |
| 3 | Reporte de consumo de infraestructura y soporte | Desglose de elementos por infraestructura y servicios | Entrega en formato de presentación ejecutiva | Mensual |
| 4 | Reporte de actividades del equipo de SDLC | Detalle de las actividades realizadas | Entrega en formato de presentación ejecutiva | Mensual |
| 5 | Módulos de código para plantillas de arquetipos | Evidencia de código en repositorios | Scripts de infraestructura como código en Terraform | Mensual |

La aceptación opera por silencio: Banamex tiene diez días hábiles desde el envío para aceptar
o rechazar por escrito, y pasado ese plazo el entregable se considera aceptado. Conviene
registrar la fecha de envío de cada uno, porque ese reloj corre a nuestro favor pero solo si
hay evidencia de cuándo empezó.

### El verdadero criterio de salida de la Etapa 1

El Anexo condiciona la cuota de arranque de treinta mil dólares a cuatro criterios que no se
acreditan con documentos. Se verifican en una sesión en vivo con usuarios de Banamex sobre el
laboratorio funcionando, y la cuota solo es exigible cuando el banco lo confirma por escrito:

1. Los usuarios designados por Banamex tienen acceso habilitado al laboratorio.
2. Esos usuarios ingresan por sí mismos al laboratorio y a sus herramientas.
3. Los usuarios visualizan y pueden utilizar los entornos contratados.
4. Los usuarios ejecutan con éxito, de punta a punta, al menos un pipeline de construcción y
   despliegue dentro del laboratorio.

Este es el hito que ordena toda la Etapa 1. No es la presentación de arquitectura ni el
documento de habilitación: es un grupo de personas de Banamex corriendo un pipeline completo
frente a nosotros. Todo lo demás del setup existe para llegar ahí.

### Compromisos de servicio que arrancan con la operación

| Tipo de requerimiento | Quién aprueba | Tiempo comprometido | Nivel de pena |
|---|---|---|---|
| Activar un arquetipo del catálogo | Owner de Banamex | 3 días hábiles | B, 1% |
| Crear un producto en un arquetipo vigente | Líder del equipo | 1 día hábil | B, 1% |
| Cambiar cuotas, escenarios o presupuestos | Operación de Accenture | 1 día hábil | B, 1% |
| Alta de una persona | Owner de Banamex | 2 días hábiles | B, 1% |
| Baja de una persona | Owner de Banamex | 1 día hábil | A, 3% |
| Diseñar un arquetipo nuevo a la medida, dentro del cupo | Owner de Banamex | 10 días hábiles | B, 1% |
| Integrar una herramienta fuera del catálogo | Comité de la iniciativa | Estimación en 5 días | B, 1% |
| Incidente de severidad 1 | No aplica | Atención en 30 minutos | A, 3% |
| Incidente de severidad 2 | No aplica | Atención en 2 horas | A, 3% |
| Incidentes de severidad 3 y 4 | No aplica | Mismo día y siguiente día hábil | B, 1% si más del 10% del mes incumple |

El tope de penalización es cinco por ciento del monto mensual. La baja de persona atrasada que
deje un acceso abierto es severidad alta, tres por ciento por evento: es el requerimiento más
barato de atender y el más caro de incumplir, y conviene automatizarlo desde el primer día.

---

## Etapa 1, Setup: los quince entregables de la tabla de origen

### Base Laboratorio

**Listado de arquetipos personalizados.** El deck ya propone cuatro arquetipos iniciales como
plantillas de Terraform en el repositorio del laboratorio: A para certificar APIs, B para
producto digital, C para plataforma multiequipo y D para IA intensiva. El trabajo de la Etapa 1
no es inventarlos sino decidir cuáles aplican a Banamex y con qué personalización. El cupo
depende de la talla, que a su vez se lee del consumo mensual y no se contrata de antemano: dos
arquetipos en xSmall, tres en Small, cuatro en Medium, ocho en Large y quince en XL. Sin saber
la talla esperada no se puede dimensionar este entregable, y es la primera decisión que hay que
cerrar.

**Plan de montaje de personalización.** Secuencia y esfuerzo para llevar cada arquetipo de
plantilla a versión personalizada. El Anexo pone precio y tiempo a esto: un arquetipo nuevo a
la medida dentro del cupo se diseña en diez días hábiles, y fuera del cupo cuesta entre mil
ciento setenta y dos mil novecientos veinticinco dólares según complejidad. Ese es el marco
dentro del que se planea, no una estimación libre.

**Montaje Laboratorio Personalizado.** Corresponde al entregable 2 del Anexo. Cierra con la
sesión en vivo de los cuatro criterios.

### SDLC

**Proceso to-be de alto nivel.** El deck ya define las compuertas G0 a G4, donde G4 es el paso
a la Zona D. Como la Zona D no existe todavía, el proceso to-be tiene que ser explícito sobre
qué pasa con un producto que llega a G3 y se queda esperando. Ese es el punto donde este
entregable aporta valor real y no solo un diagrama.

**Stack SDLC agéntico.** El deck lo define sobre servicios nativos de AWS: Kiro como IDE
agéntico, CodePipeline y CodeBuild, agentes de Bedrock como core simulado, un agente evaluador
que firma evidencia para las compuertas, y Terraform para la infraestructura. En Etapa 1 el
trabajo es acordarlo con Seguridad del banco e integrarlo al estándar, que es justamente lo que
el deck colocó en la activación, ahora comprimida a tres semanas.

**Business case.** No es entregable del Anexo B. Si se entrega, es cortesía o insumo para la
siguiente venta, y conviene tratarlo como tal. Además necesita una línea base de costo y tiempo
de ciclo del banco que hoy no tenemos: hay que pedirla ahora, no cuando toque escribirlo.

### Modernización Core Bancario

Ninguno de los cuatro entregables de este workstream está en el Anexo B, y el Anexo excluye
explícitamente el core real. Lo que sí tenemos es una ventaja que conviene explotar: el Digital
Brain de S500 y S151 ya existe y está poblado, con más de mil quinientas reglas de negocio
extraídas del código, veintiséis capacidades de negocio modeladas, ciento ochenta y un riesgos
de migración catalogados y el corpus completo de ambos sistemas indexado. Vive en
`systems/core/unisys/digital-brain/brain.db` y se consulta con la API `GemCogBrain`.

Eso cambia el carácter de los cuatro entregables. La presentación ejecutiva del Digital
Enterprise Brain no es una propuesta de lo que haríamos, es la demostración de algo construido.
El "3R" inicial puede sustentarse en evidencia del código en lugar de entrevistas, y tiene que
nombrarse como primera clasificación y no como decisión firme de arquitectura. La metodología
es la formalización de cómo se llegó a eso. El roadmap es la consecuencia de los tres
anteriores.

Hay además un puente natural con el laboratorio que vale la pena construir: el core simulado
del laboratorio se arma a partir de contratos de interfaz, esquemas de mensajes y reglas de
negocio aprobados por el cliente, según el Anexo. El Digital Brain es precisamente un
repositorio de reglas de negocio del core extraídas del código fuente. Alimentar el harness de
emulación desde el brain es la integración más valiosa entre las dos pistas de este plan, y
conviene plantearla en la Etapa 1 aunque se ejecute después.

### TSA Exit

El deck es claro sobre por qué existe el laboratorio: Cloud Readiness y el Landing Zone se
frenan por dependencias y controles de Citi, y la Zona D llega hasta 2027. El laboratorio es la
manera de avanzar sin esperar. Esto convierte al TSA Exit en el contexto del engagement más que
en un entregable suyo.

El análisis de TSAs aplicables y su roadmap no están contratados en el Anexo B. Si se van a
entregar, necesitan vehículo propio. Dicho eso, el Digital Brain vuelve a dar ventaja: la
separación entre las dos marcas está escrita en el código del legado, y el brain ya tiene
localizadas dependencias concretas que la atan, incluida la clave de institución fijada en duro
en el traductor de reportes regulatorios, con catorce ocurrencias documentadas. Un análisis de
TSAs que arranca de evidencia de código llega antes y llega con sustento.

### Future Bank

El listado y el roadmap de iniciativas no están en el Anexo B. Son, sin embargo, el insumo que
determina la talla del laboratorio, porque la talla se lee del consumo y el consumo lo generan
los arquetipos activos, que a su vez responden a las iniciativas que el banco quiera probar.
Sin cartera de iniciativas la talla se estima a ciegas. Por eso este workstream, aunque no sea
contractual, es dependencia directa del dimensionamiento del servicio.

### BAU o proyectos existentes

La tabla de origen deja este workstream sin entregables. Es un hueco de alcance que hay que
cerrar en la Etapa 1: o aporta entregables propios, o se define explícitamente como la frontera
de lo que el laboratorio no toca. Mientras quede indefinido, los proyectos existentes del banco
van a competir por las mismas personas sin que el plan lo reconozca.

---

## Secuencia de la Etapa 1

La primera semana que viene no se planea, se verifica. El Anexo lleva ocho días corriendo y el
compromiso de habilitación era de una semana, así que lo primero es contrastar el estado real
contra lo comprometido y, si hay desfase, decidir si se recupera o se replantea con el cliente
antes de que la fecha del primer mes se vuelva problema.

De ahí al 11 de noviembre hay tres frentes que corren en paralelo. El diseño de arquitectura y
seguridad es trabajo de documento, pero su aceptación depende de una revisión conjunta con
Arquitectura y Seguridad del banco, y conseguir esa agenda suele tomar más que escribir el
documento. El laboratorio base depende de accesos, de la decisión de federación de identidad y
de la ruta de ingreso de código, que son decisiones del banco. Y la sesión de verificación de
los cuatro criterios depende de que haya usuarios designados y disponibles, que es lo que más
tarda en conseguirse y lo que nadie suele pedir con anticipación.

Esa es la lectura corta de la secuencia: lo que está en el camino crítico no es nuestro trabajo
técnico, son tres decisiones y una agenda que dependen del cliente. Hay que pedirlas esta
semana.

---

## Decisiones abiertas

| Decisión | Por qué bloquea | Quién decide |
|---|---|---|
| Talla esperada del servicio | Define cupo de arquetipos, usuarios, dominios de core emulado y pipelines. Sin ella no se dimensiona la Etapa 1 | Banamex, sobre la cartera de iniciativas |
| Federación de identidad: invitado B2B contra cuenta en dominio Accenture | Determina si las altas dependen del tenant del banco o no. La opción B2B exige federar Entra ID de Banamex | Seguridad de Banamex |
| Ruta de ingreso de código: OIDC desde GitHub Actions, CodeConnections o paquete firmado por SFTP | Cambia la arquitectura del entregable 1 y el diseño del repositorio | Seguridad de Banamex |
| Capa de experiencia: Modyo Connect contra BFF propio en el laboratorio | El deck lo marca como decisión de Fase 0 y recomienda el BFF propio por control y transferibilidad | Arquitectura de Banamex |
| Cuáles de los cuatro arquetipos iniciales aplican y con qué personalización | Es el primer entregable de Base Laboratorio | Conjunta |
| Alcance del workstream BAU | Hueco de alcance abierto | Conjunta |
| Vehículo contractual de los workstreams no cubiertos | Define si Modernización Core, TSA Exit y Future Bank se entregan y bajo qué condiciones | Account Lead |

---

## Riesgos tempranos

**El camino crítico está del lado del cliente.** Tres decisiones de seguridad y una agenda de
usuarios condicionan los dos entregables con fecha dura. Es el patrón por el que este tipo de
engagement se atrasa, y el atraso no se recupera porque la fecha del primer mes es contractual.

**La cuota de arranque no se cobra con documentos.** Treinta mil dólares dependen de que
usuarios del banco corran un pipeline de punta a punta frente a nosotros. Si los usuarios no
están designados a tiempo, el entregable técnico puede estar listo y la cuota seguir sin ser
exigible.

**Cuatro workstreams fuera del Anexo pueden entregarse por inercia.** Modernización Core, TSA
Exit, Future Bank y BAU suman nueve entregables que nadie contrató. Es el riesgo comercial más
grande del plan y se mitiga con una decisión explícita, no evitando el tema.

**La talla no se contrata, se lee del consumo.** El modelo cobra servicio como porcentaje del
consumo y la talla se deduce del rango. Eso significa que el dimensionamiento de la Etapa 1
tiene efecto directo en la facturación del banco, y una expectativa mal puesta en el setup se
convierte después en una discusión de true-up trimestral.

**La baja de persona es la pena más fácil de incurrir.** Un día hábil, severidad alta, tres por
ciento por evento. Conviene automatizar el vencimiento y la revocación antes de que entre el
primer usuario, no después del primer incidente.

---

*v0.1, 19 de octubre de 2026. Anclado al Anexo B firmado. Pendiente de validar el estado real
de habilitación contra lo comprometido.*
