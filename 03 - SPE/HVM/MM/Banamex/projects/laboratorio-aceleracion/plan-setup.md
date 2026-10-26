# Laboratorio de Aceleración — Plan de Setup

> Nivel de ejecución del `plan-de-trabajo.md`, que es el plan maestro
> Versión 1.0, 19 de octubre de 2026
> Ancla contractual: Anexo B del Contrato Maestro 2022.021519

---

## Para qué existe este setup

El laboratorio no se monta para tener un laboratorio. Se monta para habilitar cuatro
iniciativas estratégicas del banco, y el setup está terminado cuando esas cuatro pueden
arrancar sin esperar nada más:

| Iniciativa | Qué necesita del laboratorio |
|---|---|
| Modernización del Core | Un lugar donde certificar APIs contra el core emulado sin tocar el core real, y las reglas de negocio del legado disponibles como contratos |
| TSA Exit | Un lugar donde construir y probar los reemplazos de los servicios heredados, sin depender del calendario de la Zona D |
| Iniciativas de negocio | Sandboxes por producto con pipeline y compuertas, para validar hipótesis de negocio contra un core que responde |
| Transformación del SDLC del banco | Una implementación de referencia del SDLC agéntico que después se extiende al resto del banco |

La cuarta merece una aclaración porque es la que más fácil se malinterpreta. **No se trata del
SDLC interno del laboratorio, sino del SDLC de todo el banco.** El laboratorio es el lugar donde
ese modelo se incuba y se prueba con productos reales, pero el objetivo es que salga de ahí y
se vuelva la forma de construir software del banco completo. Eso tiene dos consecuencias para
el setup: el SDLC del laboratorio tiene que diseñarse desde el principio como algo extensible y
transferible, no como una configuración a la medida de cuatro sandboxes, y hay que levantar el
estado actual del SDLC del banco en paralelo, porque sin línea base no hay transformación que
se pueda demostrar.

---

## Los componentes del Anexo y su calendario

El Anexo no habla de fases, habla de **tres componentes**. Cláusula Cuarta: *la solución se
estructura en tres componentes diferenciados: (i) Habilitación; (ii) Activación de capacidades
de emulación, SDLC y automatización; y (iii) Operación y Soporte para la operación recurrente
del laboratorio*. Más adelante agrupa los dos primeros como *la fase de habilitación y
activación del servicio*, y ubica los entregables 1 y 2 en *la fase de on-boarding*, dentro del
primer mes. Ese es todo el vocabulario de fases que el contrato tiene.

| Componente | Cláusula | Ventana | Estado |
|---|---|---|---|
| Habilitación inicial | Cuarta (i) | Semanas 1 y 2, del 12 al 23 de octubre de 2026 | Por verificar |
| Activación | Cuarta (ii) | Semanas 2 a 4, del 19 de octubre al 6 de noviembre de 2026 | Por ejecutar |
| Operación y Soporte | Cuarta (iii) | Del 9 de noviembre de 2026 al 11 de octubre de 2029 | Por ejecutar |
| Trabajo de apoyo | No contratado | En paralelo a la implementación | En curso |

**La ventana de implementación es de cuatro semanas**, del 12 de octubre al 6 de noviembre, con
la entrega formal de los entregables 1 y 2 el 11 de noviembre. Se ajustó a cuatro porque es lo
que cabe dentro del único plazo que el Anexo fija, que es el primer mes. El diseño de solución
planteaba una semana de habilitación y seis de activación, siete en total, que no caben, y
además esas duraciones no son contractuales: el Anexo no fija plazo de implementación para
ninguno de sus tres componentes.

De las 38 actividades del plan, **22 se sostienen en el texto del Anexo y 16 son apoyo nuestro**.
Las de apoyo no sobran, pero conviene saber cuáles son: verificar el estado real de la
habilitación, cerrar las decisiones de seguridad, llevar el registro del proyecto, automatizar
la revocación de accesos, el marco de controles, los pilotos, el ensayo previo al gate, la línea
base del SDLC del banco y las ocho del Digital Brain.

El componente de Habilitación aparece como "por verificar" a propósito. El compromiso del deck
era una semana con sandbox operado al quinto día, y esa semana ya pasó. La primera actividad del
plan es contrastar lo levantado contra lo comprometido.

## Habilitación inicial — Cláusula Cuarta (i)

| ID | Actividad | Entregable | Depende de |
|---|---|---|---|
| ACT-01 | Inventariar el estado real de la habilitación contra lo comprometido en el deck | Reporte de desfase con decisión de recuperar o replantear | — |
| ACT-02 | Confirmar la talla esperada del servicio y la demanda inicial que la justifica | Nota de dimensionamiento con la talla y su sustento | ACT-01 |
| ACT-03 | Pedir a Banamex la designación de los usuarios para el gate de arranque | Lista de usuarios designados con rol y fecha de disponibilidad | — |
| ACT-04 | Agendar la revisión conjunta con Arquitectura y Seguridad del banco | Fecha en firme en calendario de ambas partes | — |
| ACT-05 | Cerrar las tres decisiones de seguridad abiertas | Tres decisiones documentadas y firmadas | ACT-04 |
| ACT-06 | Levantar el registro de decisiones, riesgos y datos requeridos del proyecto | Registro vivo en `knowledge-base/` | — |
| ACT-07 | Pedir la línea base del SDLC actual del banco: tiempo de ciclo, costo por entrega, número de equipos | Línea base documentada o DATO-REQUERIDO formal | — |

ACT-03 y ACT-04 no dependen de nada y son las que más tardan en conseguirse. Salen hoy.

ACT-07 parece prematura y no lo es. La transformación del SDLC del banco se mide contra un
punto de partida, y ese dato rara vez existe de forma utilizable. Si se pide en diciembre, el
business case se escribe sin cifras.

---

### Lo que el Anexo pide en Habilitación

Corresponde al entregable 2 del Anexo B, el laboratorio base habilitado, cuyo contenido mínimo
contractual es cuentas, red, identidad, auditoría, repositorios, pipeline, catálogo y sandbox
inicial.

| ID | Actividad | Entregable | Depende de |
|---|---|---|---|
| ACT-08 | Organización AWS, cuentas hijas, unidades organizativas y políticas de control de servicio | Estructura de cuentas desplegada en Terraform | ACT-01 |
| ACT-09 | Red aislada, endpoints privados y verificación de que no existe ruta al core real | Diagrama de red y evidencia de aislamiento | ACT-08 |
| ACT-10 | Identidad federada con Identity Center, MFA obligatorio para terceros y proveedores | Flujo de alta, cambio y baja operando | ACT-05 |
| ACT-11 | Controles base: cifrado con KMS del banco, CloudTrail, Config, GuardDuty, Security Hub | Tablero de postura con hallazgos y dueños | ACT-08 |
| ACT-12 | Repositorio y ruta de ingreso de código según la decisión de ACT-05 | Repositorios mirror y work operando con su control de acceso | ACT-05, ACT-10 |
| ACT-13 | Pipeline de integración y despliegue continuos | Pipeline ejecutando de punta a punta | ACT-12 |
| ACT-14 | Catálogo de aprovisionamiento de autoservicio | Catálogo publicado con sus productos | ACT-08 |
| ACT-15 | Sandbox inicial operado | Sandbox disponible y monitoreado | ACT-13, ACT-14 |
| ACT-16 | Despliegue de los arquetipos de arranque como plantillas de Terraform | Arquetipos activos en el repositorio de infraestructura | ACT-14 |
| ACT-17 | Automatizar el vencimiento y la revocación de accesos | Baja automática por vencimiento, verificada | ACT-10 |

ACT-17 no está en el contenido mínimo del Anexo y aun así va en esta fase. La baja de persona
atrasada que deje un acceso abierto es severidad alta, tres por ciento del monto mensual por
evento, y es el incumplimiento más fácil de cometer. Automatizarlo antes de que entre el primer
usuario cuesta mucho menos que el primer incidente.

---

## Activación — Cláusula Cuarta (ii)

| ID | Actividad | Entregable | Depende de |
|---|---|---|---|
| ACT-18 | Acordar el marco de controles con Seguridad del banco e integrarlo a su estándar | Marco de controles firmado | ACT-05, ACT-11 |
| ACT-19 | Recibir del banco los contratos de interfaz, esquemas de mensajes y reglas de negocio del core | Contratos OpenAPI versionados en el repositorio | — |
| ACT-20 | Modelar escenarios por dominio: normal, excepción, latencia, rechazo y caos controlado | Catálogo de escenarios por dominio | ACT-19 |
| ACT-21 | Construir el core emulado por dominio con agentes y enrutador de escenarios | Core emulado respondiendo según contrato | ACT-20 |
| ACT-22 | Montar la fábrica de datos sintéticos con generación, validación, versionado y firma | Fábrica operando, con aprobación previa al uso | ACT-18 |
| ACT-23 | Implementar las compuertas de control con evidencia automática | Compuertas G0 a G4 operando con evidencia firmada | ACT-13, ACT-21 |
| ACT-24 | Levantar dos sandboxes piloto y el primer micro frontend en pruebas | Dos pilotos funcionando contra el core emulado | ACT-15, ACT-21 |
| ACT-25 | Conectar observabilidad, centro de operaciones de seguridad, gestión de servicio y parcheo | Operación con monitoreo, incidentes y parcheo activos | ACT-11 |
| ACT-26 | Activar las capacidades por catálogo según la talla contratada | Catálogo alineado al cupo de la talla | ACT-02, ACT-14 |

ACT-19 es la dependencia más subestimada de esta fase. El Anexo condiciona el diseño del core
emulado a contratos, esquemas y reglas de negocio **proporcionados y aprobados por el Cliente**.
Si el banco no los entrega, la activación se detiene y la causa no es imputable a Accenture,
pero el calendario se cae igual. Conviene pedirlos formalmente y registrar la fecha.

Aquí es donde el Digital Brain cambia las cosas, y por eso el track paralelo existe.

---

## La acreditación de los cuatro criterios — Cláusula Sexta

El Anexo condiciona la cuota de arranque de treinta mil dólares a cuatro criterios que se
verifican en una sesión en vivo con usuarios de Banamex sobre el laboratorio funcionando, no
mediante la entrega de documentos.

| ID | Actividad | Entregable | Depende de |
|---|---|---|---|
| ACT-27 | Ensayar internamente los cuatro criterios de extremo a extremo | Ensayo completado sin incidencias | ACT-15, ACT-17 |
| ACT-28 | Entregar el diseño de arquitectura y seguridad y conseguir la revisión conjunta | Entregable 1 del Anexo, aceptado o con observaciones resueltas | ACT-04, ACT-09, ACT-11 |
| ACT-29 | Ejecutar la sesión de verificación con usuarios reales de Banamex | Acta de la sesión con los cuatro criterios acreditados | ACT-03, ACT-27 |
| ACT-30 | Obtener la confirmación por escrito del cumplimiento | Confirmación escrita, que vuelve exigible la cuota | ACT-29 |

Los cuatro criterios, textuales del Anexo: los usuarios designados tienen acceso habilitado;
esos usuarios ingresan por sí mismos al laboratorio y a sus herramientas; visualizan y pueden
utilizar los entornos contratados; y ejecutan con éxito, de punta a punta, al menos un pipeline
de construcción y despliegue.

Todo el setup se ordena hacia esta sesión. Si algo compite por tiempo, gana lo que acerque a
ACT-29.

---

## Trabajo de apoyo fuera del Anexo B

El brain corre en paralelo porque no depende de la plataforma y porque es lo que vuelve
ejecutables las cuatro iniciativas estratégicas. Sin él, cada una arranca con un
descubrimiento de meses.

| ID | Actividad | Entregable | Depende de |
|---|---|---|---|
| ACT-31 | Montar el brain del laboratorio con su esquema y su cargador | `digital-brain/build-brain.py` y `brain.py` | — |
| ACT-32 | Cargar la capa contractual desde el Anexo B | Entregables, compromisos de servicio, tallas, penas y criterios de arranque consultables | ACT-31 |
| ACT-33 | Cargar la capa de laboratorio desde el diseño de solución | Arquetipos, capas, compuertas y stack consultables | ACT-31 |
| ACT-34 | Cargar la capa de setup con las actividades y entregables de este plan | Avance del setup consultable por fase y workstream | ACT-31 |
| ACT-35 | Federar el brain del core por referencia, sin duplicar el corpus | Consulta cruzada entre laboratorio y core | ACT-31 |
| ACT-36 | Modelar las cuatro iniciativas estratégicas con sus habilitadores y brechas | Tablero de preparación por iniciativa | ACT-32, ACT-35 |
| ACT-37 | Derivar contratos de interfaz candidatos desde las reglas del core | Insumo para ACT-19, con trazabilidad a la regla de origen | ACT-35 |
| ACT-38 | Levantar el estado actual del SDLC del banco como capa del brain | Línea base del SDLC consultable | ACT-07 |

ACT-37 es el puente que más valor tiene de todo el plan. El Anexo pide que el core emulado se
construya a partir de contratos de interfaz, esquemas de mensajes y reglas de negocio. El brain
del core es exactamente eso, extraído del código fuente del legado: mil quinientas ochenta y
tres reglas de negocio sobre veintiséis capacidades, con el vocabulario y la trazabilidad al
programa que las implementa. En lugar de esperar a que el banco redacte contratos desde cero,
se le pueden proponer contratos derivados de su propio código para que los apruebe. Eso
convierte la dependencia más riesgosa de la Activación en una revisión en vez de una
redacción.

---

## Las iniciativas estratégicas, que no están en el Anexo

Esto arranca cuando la implementación cierra. Se incluye aquí para que el setup se diseñe hacia
ella y no al revés.

| Iniciativa | Qué habilita el laboratorio | Qué aporta el brain | Qué falta |
|---|---|---|---|
| Modernización del Core | Arquetipo de certificación de APIs contra el core emulado, con evidencia firmada por compuerta | Reglas de negocio del legado, capacidades, riesgos de migración y las decisiones de disposición ya tomadas | Extender las decisiones de disposición más allá de las cinco existentes y construir el roadmap |
| TSA Exit | Lugar para construir y probar reemplazos sin depender del calendario de la Zona D | Evidencia en código del acoplamiento heredado, incluida la clave de institución fijada en duro | El inventario de TSAs aplicables, que hoy no existe en ningún artefacto |
| Iniciativas de negocio | Sandboxes por producto con pipeline, compuertas y core que responde | Capacidades del core que toca cada iniciativa y riesgos asociados | La cartera de iniciativas con su hipótesis de valor |
| Transformación del SDLC del banco | Implementación de referencia del SDLC agéntico, probada con productos reales | Línea base del SDLC actual y trazabilidad de la evidencia por compuerta | El alcance de la transformación: qué equipos, en qué orden, con qué meta |

Las tres brechas de la última columna son datos del banco, no trabajo nuestro. Pedirlas en la
la semana 2 es lo que evita que las iniciativas arranquen con dos meses de descubrimiento.

**Ninguna de estas cuatro iniciativas está contratada en el Anexo B.** El Anexo cubre la
habilitación, activación y operación del laboratorio, y excluye explícitamente la conexión con
entornos productivos o con el core real. Habilitarlas desde el laboratorio es legítimo y es el
propósito del proyecto; entregarlas como servicio requiere orden de servicio o control de
cambio. La decisión del vehículo es del Account Lead y conviene tomarla antes de que las
iniciativas arranquen.

---

## Resumen de entregables del setup

| Entregable | Fase | ¿Contractual? |
|---|---|---|
| Reporte de desfase de habilitación | 0 | No, control interno |
| Nota de dimensionamiento de talla | 0 | No, insumo comercial |
| Tres decisiones de seguridad documentadas | 0 | No, prerrequisito |
| Diseño de arquitectura y seguridad | 3 | **Sí, entregable 1, vence el 11 de noviembre** |
| Laboratorio base habilitado | 1 | **Sí, entregable 2, vence el 11 de noviembre** |
| Acta de acreditación de los cuatro criterios | 3 | Condición de la cuota de arranque |
| Core emulado por dominio | 2 | Parte de Activación |
| Fábrica de datos sintéticos | 2 | Parte de Activación |
| Compuertas con evidencia automática | 2 | Parte de Activación |
| Plantillas de arquetipos en Terraform | 1 y continuo | **Sí, entregable 5, mensual** |
| Reporte de consumo de infraestructura y soporte | Desde operación | **Sí, entregable 3, mensual** |
| Reporte de actividades del equipo de SDLC | Desde operación | **Sí, entregable 4, mensual** |
| Digital Brain del laboratorio operando | Apoyo | No, habilitador de las iniciativas |
| Tablero de preparación de las cuatro iniciativas | Apoyo | No, insumo de las iniciativas |

---

*v1.0, 19 de octubre de 2026. Complementa `plan-de-trabajo.md`, que mantiene el análisis de
frontera contractual y el registro de riesgos.*
