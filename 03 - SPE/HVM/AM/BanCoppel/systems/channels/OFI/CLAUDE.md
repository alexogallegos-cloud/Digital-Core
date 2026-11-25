# OFI — Originación en sucursal por promotoría
# togaf_type: channels
# togaf_state: discovered
# togaf_system_of: differentiation
# togaf_abb: branch-origination

> **Proyecto**: BanCoppel Application Modernization, `SPE-AM-001`
> **Ruta canónica**: `systems/channels/OFI/`
> **Hereda**: `Application Modernization/CLAUDE.md` (Reglas B y Reglas V)
> **Estado**: `[STATE: DISCOVERED]`, estructura abierta por Regla B9 el 2026-11-04. Sin código fuente todavía.

---

## QUÉ ES

OFI es la aplicación cliente servidor desde la que la promotoría da de alta clientes y productos en sucursal. Sigue operando hoy.

El nombre completo es Oficina Financiera Integral. Son **dos aplicativos distintos**, no dos nombres del mismo: OFI es el cliente servidor y SIWEB es el frente web. El As-Is lo registra como el desglose entre OFI Tradicional y OFI Web, y aclara que OFI Web es SIWEB; **la convención del programa es llamarlos OFI y SIWEB, nunca OFIWeb**. Esa frontera ya costó una corrección de auditoría que afectó a 74 procesos de sucursal.

El inventario del Anexo 5 lo registra como la aplicación 58 y lo describe como "sistema tradicional de operaciones a promotoría en sucursales". Su SUD propio, `Bancoppel_SUD_OFI.docx`, define su función principal como el alta de clientes nuevos y la oferta de productos de captación y crédito, incluido el crédito de Coppel y de BanCoppel.

---

## POR QUÉ IMPORTA MÁS DE LO QUE PARECE

**El alta nace aquí.** Confirmado por el equipo del proyecto el 2026-11-04. No es un canal más: es el punto donde se origina el cliente y donde se colocan los productos.

Eso lo pone en el camino crítico del análisis de estacionalidad de noviembre de 2026 a enero de 2027, que marca Alta Única como servicio crítico porque depende de seis cosas a la vez y si falla cualquiera no hay alta.

Hay una consecuencia incómoda y vale dejarla escrita. Ese análisis trata a OFI y a OfiWeb como si fueran el mismo sistema, escribe "OfiWeb/OFI" y propone como remediación urgente ajustar timeouts y reintentos del cliente SOAP y el pool HTTP de OfiWeb, que corre sobre WAS. Esa remediación protege el frente web, que es SIWEB. Si el alta nace en el frente cliente servidor, ese trabajo no protege el punto donde el alta se origina. **Conviene resolverlo antes de aprobar el backlog de remediación.**

---

## CÓMO LLEGA AL RESTO DEL BANCO

El Catálogo de Interfaces AS-IS del Anexo 5 documenta cinco interfaces, todas salientes, y su forma confirma la arquitectura cliente servidor:

| Destino | Tipo | Confianza |
|---|---|---|
| Informix, core OLTP | Acceso directo a base de datos por SPL | Alta |
| Interact Router | Message broker por InterAct | Alta |
| Motor de Evaluación de Crédito | API REST | Alta |
| Motor de Huellas | Batch por SFTP | Alta |
| Motor de Rostros | Especializada, biometría | Media |

Lo importante del cuadro no es a dónde va, sino **por dónde no va**: OFI entra al core por acceso directo SPL y por InterAct, no por el BUS. El BUS observa `OFI_WEB` con 2,171,891 llamadas, el 53 por ciento de su tráfico, pero ése es el frente web, es decir SIWEB. La carga de OFI no aparece en las trazas del BUS, así que hoy es invisible para la mejor evidencia de ejecución que tiene el programa.

Tres de sus cinco destinos son exactamente las dependencias que el análisis de estacionalidad atribuye a Alta Única: evaluación de crédito, huellas y rostros. El As-Is lo confirma por otro lado al describir que la petición de autenticación por huella inicia desde OFI o desde SIWEB, y que existe un servicio intermedio que comprueba la identidad del cliente y de la sucursal cuando se solicita un alta a través de OFI.

---

## ESTADO DEL BRAIN

No hay `digital-brain/brain.db` todavía. Ningún sistema le ha emitido un seed, y por eso la Regla B12 no lo ha inicializado.

SIWEB lo cita en su `cross_dependencies` como enlace de canal a canal, con la nota de que el As-Is lo marcaba como probable falso positivo pendiente de validar contra el SUD. Con lo que hoy sabemos, esa cita hay que reinterpretarla: no parece una llamada de un sistema a otro, sino el reflejo de que ambos son frentes de la misma función de sucursal. Conviene corregirla en el brain de SIWEB en lugar de heredarla como dependencia.

### Para activar el brain (DoR)

- [ ] Conseguir el `Bancoppel_SUD_OFI.docx` completo
- [ ] Conseguir el código fuente de la aplicación cliente servidor y su configuración de conexión al core
- [ ] Determinar el volumen de altas por día y su perfil intradía, que hoy no mide nadie
- [ ] Mapear qué procedimientos de Informix invoca directamente, y cuáles a través de InterAct
- [ ] Declarar `cross_dependencies` en primera persona para los cinco destinos del catálogo
- [ ] Corregir en el brain de SIWEB la relación canal a canal, una vez confirmada la frontera

### Preguntas abiertas

Cuántos puestos de promotoría operan la aplicación y con qué concurrencia, porque de eso depende saber si el pico de altas de la temporada cabe por este camino. El análisis de estacionalidad proyecta la ventanilla de sucursal en 1.57 veces su día típico para el 16 de noviembre, y nadie ha medido qué significa ese factor para una aplicación cliente servidor que no pasa por el BUS ni por WAS.

Queda también por confirmar si la frontera que corrigió la auditoría sobre 74 procesos de sucursal dejó bien repartidos los procesos entre este frente y SIWEB.

---

## FUENTES

| Fuente | Qué aporta |
|---|---|
| Confirmación del equipo del proyecto, 2026-11-04 | El alta nace en OFI; es cliente servidor y sigue operando; la usa la promotoría. OFI y SIWEB son dos aplicativos; el frente web se nombra SIWEB |
| `projects/unity/source/docs/DocumentosTrabajo/ArquitecturaAplicativaAsIs/BanCoppel_ASIS_Base_Conocimiento_y_Regeneracion_2.md` | El desglose entre los dos frentes, la ficha del SUD, la autenticación por huella y la corrección de frontera |
| `.../BanCoppel_Unity_Catalogo_Interfaces_ASIS_2_jeap.xlsx` | La aplicación 58 y sus cinco interfaces con protocolo y confianza |
| `source/docs/BanCoppel_Estrategia_Analisis_Operacion_Estacionalidad_v3 1.html` | Alta Única como servicio crítico y la remediación dirigida al frente web |
| `Bancoppel_SUD_OFI.docx` | Pendiente de conseguir completo |

---

*Última actualización: 2026-11-04. Estructura abierta por Regla B9 tras confirmarse que el alta de clientes y productos nace en este sistema. Nomenclatura del programa: OFI y SIWEB.*
