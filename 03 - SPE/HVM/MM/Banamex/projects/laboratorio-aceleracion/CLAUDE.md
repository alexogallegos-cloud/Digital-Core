# Laboratorio de Aceleración — Project Agent
# project_type: innovation-acceleration-lab
# project_state: active
# platform: AWS mx-central-1 (México Central, Querétaro), cuenta a nombre de Banamex, operada por Accenture
# horizon_present: Cloud Readiness y Landing Zone frenados por dependencias de Citi, Zona D hasta 2027
# horizon_future: laboratorio aislado operado como servicio, con core emulado y SDLC agéntico
# replaces_or_complements: complementa systems/core/unisys (Run the Bank)

> **Engagement**: Laboratorio de Aceleración, offering Origen
> **Modelo**: Change the Bank
> **Contrato**: Anexo B del Contrato Maestro 2022.021519, vigencia del 12 de octubre de 2026 al 11 de octubre de 2029
> **Servicio**: CMO, Accenture Cloud Manager and Optimizer
> **Origen comercial**: propuesta Innovation Environment, ganada
> **Fuente contractual**: `source/sow/` (Anexo B firmado)
> **Fuente de solución**: `source/docs/Banamex_LaboratorioAceleracion_v8.pptx`
> **Plan maestro**: `plan-de-trabajo.md`, frontera contractual y riesgos
> **Plan de ejecución**: `plan-setup.md`, actividades y entregables del setup
> **Brain**: `digital-brain/`, API `LabBrain`, federa el brain del core por referencia

---

## QUÉ ES ESTE PROYECTO

El Laboratorio de Aceleración es un laboratorio Cloud aislado donde el banco construye,
integra y prueba productos digitales contra servicios de Core emulados y datos sintéticos. Se
presta como servicio administrado, con controles de seguridad, cumplimiento, observabilidad,
gestión de accesos y gobierno operativo. Reside en AWS México Central, en una cuenta a nombre
de Banamex que Accenture opera.

Existe por una razón concreta: Cloud Readiness y el Landing Zone del banco están frenados por
dependencias y controles de Citi, y la Zona D no llega antes de 2027. El laboratorio es la
manera de avanzar sin esperar a esa dependencia, con la regla de diseño de que lo que hoy se
prueba contra el core simulado es lo mismo que mañana apunta al core real, sin reescribir nada.

**El alcance contratado excluye el core real.** El Anexo B dice textualmente que la conexión
con entornos productivos o con el Core real no forma parte del alcance. Cualquier trabajo sobre
el core real necesita otro vehículo contractual.

**Guardrail de naming:** este entorno no se llama *sandbox*. Se le dice Laboratorio de
Aceleración, Innovation Lab o Entorno de Habilitación de Ideas.

---

## WORKSTREAMS

Seis workstreams, de los cuales solo dos tienen cobertura contractual en el Anexo B. La
distinción no es burocrática: determina qué se entrega como obligación y qué requiere orden de
servicio o control de cambio.

| Workstream | Carpeta de conocimiento | Qué gobierna | Anexo B |
|---|---|---|---|
| Base Laboratorio | `knowledge-base/base-laboratorio/` | Arquetipos, plan de montaje y montaje del laboratorio personalizado | Sí, entregables 1 y 2 |
| SDLC | `knowledge-base/sdlc-agentico/` | Proceso to-be, stack de SDLC agéntico y business case | Parcial, el business case no |
| Modernización Core Bancario | `knowledge-base/modernizacion-core/` | Digital Enterprise Brain, decisiones 7R, metodología y roadmap | No |
| TSA Exit | `knowledge-base/tsa-exit/` | Análisis de TSAs aplicables y roadmap de salida | No |
| Future Bank | `knowledge-base/future-bank/` | Cartera de iniciativas del banco futuro y su roadmap | No |
| BAU | `knowledge-base/bau/` | Proyectos existentes que entran o conviven con el laboratorio | No, y sin entregables definidos |

El plan de trabajo vive en `plan-de-trabajo.md` y es el artefacto de coordinación entre los seis.

---

## LAS CUATRO INICIATIVAS ESTRATÉGICAS

El laboratorio no se monta para tener un laboratorio. Se monta para habilitar cuatro
iniciativas, y el setup está terminado cuando las cuatro pueden arrancar.

| ID | Iniciativa | Qué necesita del laboratorio | Brecha principal |
|---|---|---|---|
| INI-01 | Modernización del Core | Certificar APIs contra el core emulado sin tocar el core real | Las decisiones 7R cubren 5 programas de 152 |
| INI-02 | TSA Exit | Construir y probar reemplazos sin depender del calendario de la Zona D | No existe inventario de TSAs aplicables |
| INI-03 | Iniciativas de negocio | Sandboxes por producto con pipeline, compuertas y core que responde | No existe la cartera con su hipótesis de valor |
| INI-04 | Transformación del SDLC del banco | Implementación de referencia del SDLC agéntico | No existe línea base del SDLC actual del banco |

**INI-04 no es el SDLC del laboratorio.** Es el SDLC de todo el banco. El laboratorio es donde
el modelo se incuba y se prueba con productos reales, pero el objetivo es que salga de ahí. Eso
obliga a diseñar el SDLC del laboratorio como algo extensible y transferible desde el
principio, y a levantar la línea base del banco en paralelo.

Ninguna de las cuatro está cubierta por el Anexo B. Consultables con
`LabBrain().tablero_iniciativas()`.

---

## RELACIÓN CON EL RESTO DE LA ONTOLOGÍA BANAMEX

| Capa | Ruta | Vínculo con este proyecto |
|---|---|---|
| Run the Bank | `systems/core/unisys/` | S500 y S151 en Unisys ClearPath. El Digital Brain de estos sistemas alimenta el workstream de Modernización Core |
| Run the Bank | `systems/compliance/{cnbv,banxico,condusef,ipab,sat,tesofe}/` | Marco regulatorio que condiciona qué puede salir del tenant productivo |
| Change the Bank | `projects/laboratorio-aceleracion/` | Este proyecto |

El Digital Brain del core (`systems/core/unisys/digital-brain/brain.db`) es insumo, no copia.
Las consultas se hacen contra ese brain con la API `GemCogBrain`; aquí no se duplica el corpus.

---

## ESTRUCTURA

```
laboratorio-aceleracion/
├── CLAUDE.md                  este archivo
├── plan-de-trabajo.md         plan maestro, frontera contractual y riesgos
├── plan-setup.md              actividades y entregables del setup
├── prompt-copilot-deck.md     guion para pedirle a Copilot el deck de 5 láminas
├── digital-brain/             lab-brain.db, API LabBrain, federa el brain del core
├── dt/                        Digital Twins del proyecto
├── generators/                build-plan.py genera el portal desde el brain
├── knowledge-base/            un subdirectorio por workstream
├── old/                       versiones retiradas
├── portal/                    HTML generado, nunca escrito a mano
└── source/
    ├── sow/                   SOW firmado y anexos contractuales
    └── docs/                  material del cliente y de la propuesta
```

---

## HECHOS CONTRACTUALES DEL ANEXO B

| Dato | Valor |
|---|---|
| Instrumento | Anexo B del Contrato Maestro de Prestación de Servicios 2022.021519 |
| Vigencia | Tres años, del 12 de octubre de 2026 al 11 de octubre de 2029 |
| Componentes del servicio | Habilitación inicial, Activación, Operación y Soporte |
| Entregables formales | Cinco: diseño de arquitectura y seguridad, laboratorio base habilitado, reporte de consumo mensual, reporte de actividades SDLC mensual, scripts Terraform de arquetipos |
| Fecha dura | Entregables 1 y 2 al primer mes, vence el 11 de noviembre de 2026 |
| Aceptación | Diez días hábiles, el silencio equivale a aceptación |
| Horario | Lunes a viernes, 9 a 18 horas, hora de Ciudad de México, remoto |
| Cuota de arranque | Treinta mil dólares más IVA, exigible solo al acreditar en vivo los cuatro criterios de laboratorio listo |
| Modelo económico | Consumo AWS a precio de lista más servicio mensual como porcentaje del consumo, 45% en tallas xSmall a Medium, 40% en Large, 37% en XL |
| Tallas y cupo de arquetipos | xSmall 2, Small 3, Medium 4, Large 8, XL 15. La talla se lee del rango de consumo, no se contrata |
| True-up de arquetipos | Trimestral. Hasta más 10% sin cobro, de 10 a 30% cobro por arquetipo, más de 30% control de cambio |
| Penas convencionales | Nivel A 3% por evento, Nivel B 1% por evento, tope combinado 5% del monto mensual |
| Propiedad intelectual | Todos los entregables son propiedad exclusiva de Banamex. Accenture no puede reutilizarlos ni entrenar modelos con ellos |
| Subcontratación | Prohibida |
| Terminación anticipada | Aviso de 90 días naturales. La cuota de arranque no es reembolsable |
| Escalamiento Accenture | Responsable Cloud y Responsable del Servicio de Laboratorio, nombrados en el Anexo |
| Escalamiento Banamex | Technology Architecture y Head of Architecture, nombrados en el Anexo |

**Datos que el Anexo no fija y siguen abiertos:** MMS ID del engagement, talla esperada del
servicio, equipo comprometido y perfiles, cadencia de comités de gobierno.

---

## REGLAS DE TRABAJO

- El Anexo B es la fuente de verdad contractual. Si un entregable no se puede rastrear al
  Anexo, se marca como fuera de alcance o como propuesta de ampliación, nunca como compromiso.
- El core real está fuera de alcance por contrato. Todo lo que lo toque necesita otro vehículo.
- Las tarifas y el AHR no se generan aquí. Se redirigen al Pricing and Commercial Modeler.
- Los HTML de `portal/` se generan desde `generators/`. No se editan a mano.
- Los Digital Twins viven en `dt/` en minúsculas.
- Nada de nombres de personas del cliente ni de cargos en artefactos visuales compartibles.
- El Digital Brain del core es insumo de consulta, no se duplica su corpus aquí.

---

*Creado el 19 de octubre de 2026, v0.2, anclado al Anexo B firmado*
