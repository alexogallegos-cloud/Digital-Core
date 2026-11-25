<!--
  Documento: lectura del documento de casa sobre Spec-Driven Development
  Fuente:    source/docs/sdd speckit beginners guide v1.pdf (6 páginas, Accenture, febrero de 2026)
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-29
  Contrastado contra fuente primaria el 2026-10-29, porque el propio documento declara
  al pie que tiene contenido generado por IA.
-->

# El Spec-Driven Development, y qué hacemos con él

**Conclusión primero.** Es la dirección correcta y es la pieza que le faltaba a nuestro enfoque. Hasta ahora decíamos que el tiempo se va en esperas y que los controles hay que enrutarlos por riesgo, pero no teníamos el mecanismo que produce el artefacto sobre el cual se enruta. Ese mecanismo es la especificación convertida en plano de control.

**Y una advertencia que hay que dar nosotros, no esperar a que la den en la sala.** El documento de casa sobrevende el tooling y omite la evidencia. Contrastado contra fuente primaria, el toolkit que propone está declarado por su propio autor como un experimento, y la evidencia controlada sobre el método es delgada. Eso no invalida la dirección: la refuerza, porque convierte a SDD en una razón más para medir antes de adoptar, que es exactamente lo que ya estamos proponiendo.

---

## Qué dice el documento

La tesis central es una frase: la especificación deja de ser subproducto y pasa a ser **el plano de control autoritativo** de la entrega. No es documentación que acompaña al código; es el artefacto versionado que gobierna arquitectura, orquestación, calidad y evolución del sistema.

El argumento de por qué ahora es el que nos sirve. El desarrollo AI-Assisted Development amplifica la productividad y también el riesgo: sin gobierno, la IA introduce abstracciones inconsistentes, huecos de seguridad y arquitectura no conforme. La especificación embebe el gobierno antes de que se escriba una línea. En palabras del propio documento, funciona como una compuerta de calidad que opera **antes** del código en lugar de durante las pruebas.

El flujo que describe tiene cinco fases.

| Fase | Qué produce | Por qué importa aquí |
|---|---|---|
| Constitución | Reglas no negociables: tecnologías permitidas, patrones de arquitectura, requisitos de seguridad, estándares de calidad | Son los mismos límites que ya se le exigen a un humano, ahora declarados también para la máquina |
| Especificación | Requisitos funcionales, escenarios de usuario, contratos de datos, criterios de aceptación. Comportamiento, no tecnología | Es el artefacto que hoy existe disperso entre épicas, historias y documento de alcance |
| Planeación | Arquitectura, descomposición, contratos de interfaz, modelos de datos, fronteras de dependencia | Es donde la decisión de arquitectura deja de ser una validación y pasa a ser un plano |
| Tareas | Tareas atómicas con entradas, salidas y criterios de validación, ejecutables en paralelo **sin sobrecarga de coordinación** | Esta frase es la más valiosa del documento para nuestro caso |
| Implementación | Ejecución tarea por tarea con validación continua contra la especificación | Evita la deriva de alcance y detecta desviaciones temprano |

La sección de futuro apunta a especificación como columna vertebral viva, automatización de la cadena completa, desarrollo multiagente, gobierno por defecto, rastros de auditoría trazables de especificación a código, y plantillas por industria.

---

## Qué verifiqué, y qué no coincide

Esto es lo que hay que corregir antes de apoyarse en el documento.

**El toolkit está declarado como experimento por su propio autor.** GitHub describe Spec Kit como un experimento para probar qué tan bien funcionan las metodologías detrás del Spec-Driven Development, y no lo presenta como producto terminado. El documento de casa lo presenta como toolkit para operacionalizar el método, sin esa salvedad. Llevar a un banco una pieza experimental como columna de su ciclo de entrega sin decirlo es repetir la escena que nos costó la propuesta anterior.

**El flujo real tiene siete pasos, no cinco.** Además de constitución, especificación, planeación, tareas e implementación, hay dos pasos intermedios: clarificar, que identifica huecos en la especificación, y analizar, que verifica consistencia antes de generar tareas. El documento los omite. Son precisamente los dos pasos de control de calidad del método, y en un banco regulado son los que lo vuelven defendible.

**La evidencia es delgada y conviene saberlo.** Las cifras que circulan de tres a diez veces más acierto en el primer intento son reportes de proveedor y hay que tratarlas como direccionales. Un caso de banca con 73% menos defectos de seguridad no está replicado de forma independiente. El pronóstico de Gartner de 25% más lento para quien no adopte hacia 2027 es un pronóstico, no una medición. Y el dato más riguroso que encontré apunta en contra: un piloto controlado reportado en septiembre de 2026 encontró que, con la especificación como línea base, cinco revisores hallaron prácticamente los mismos defectos que sin ella, con un recall de 0.525 contra 0.518. La misma fuente advierte que cuánto ayuda una especificación depende de cómo esté escrita, y que ese piloto probó un solo estilo sobre dos servicios.

**El documento declara contenido generado por IA.** Lo dice en su última línea. Es correcto que lo declare, y es también la razón por la cual no se cita como fuente ante el cliente. Se usa la sustancia, verificada contra las fuentes primarias que el propio documento lista.

**La herramienta no es única.** Todas las plataformas grandes de asistencia de código han sacado su propia variante del método. Eso es buena noticia para nosotros: confirma que SDD es una disciplina y no un producto, y encaja con la regla de este proyecto de mantenernos neutrales de herramienta hasta que la medición diga dónde está el cuello de botella.

---

## Qué nos resuelve para Banamex

**La constitución es la respuesta regulatoria, y es la pieza que no teníamos.** La pregunta difícil de un banco bajo Circular Única no es si la IA escribe código, es cómo se demuestra que lo que escribió cumple. La constitución convierte los estándares de arquitectura, los requisitos de seguridad y las restricciones regulatorias en reglas que la máquina puede comprobar sola, en lugar de documentos que nadie lee. Es la diferencia entre pedir confianza y entregar control.

**Es el mecanismo real para quitar la capa de coordinación, y es mejor argumento que el tamaño del equipo.** Veníamos diciendo equipos de tres a cinco en lugar de ocho a doce, que es una consigna de forma. El documento dice algo más preciso: las tareas con entradas, salidas y criterios de validación explícitos se ejecutan en paralelo **sin sobrecarga de coordinación**. Esa es la causa raíz. La capa de gestores existe porque las tareas son ambiguas y alguien tiene que reconciliarlas. Quitar la ambigüedad quita la necesidad del reconciliador. Para un director que quiere reducir gestores, ese razonamiento es mucho más fuerte que un número de pirámide.

**La trazabilidad de especificación a código es la evidencia de cumplimiento del salto tres.** Ya decíamos que la evidencia se genera desde la cadena en lugar de redactarse a mano. SDD es el cómo: si la especificación es el origen y cada tarea lleva criterios de validación, el rastro existe por construcción y no por esfuerzo.

**Nuestras 1,583 reglas del core son materia prima de especificación.** Están extraídas del código y trazadas al programa y a la línea. Eso es exactamente lo que hace falta para escribir la especificación del reemplazo de un programa heredado. Nadie más en esa mesa puede decir eso, y es la única parte de este tema donde llegamos con trabajo hecho en lugar de método.

**Y la evidencia delgada juega a favor, no en contra.** Si el método todavía no tiene resultado controlado concluyente, la conclusión no es esperar: es medir antes y después, que es literalmente lo que estamos vendiendo en el salto uno. SDD sin línea base es fe. Con línea base es un experimento con denominador.

---

## El prerrequisito duro, y es el hallazgo

**No hay Spec-Driven Development sin control de versiones y sin cadena de despliegue.** Todo el método descansa en artefactos versionados, en tareas verificables y en validación continua contra la especificación. En el levantamiento de 2025 del banco no aparece control de versiones, no aparece motor de integración y despliegue, y no aparece automatización de pruebas.

Eso fija su lugar con precisión. SDD **no es un salto uno**. Es un salto dos, y su prerrequisito es el componente que en el punto de partida está declarado *en proceso*, que es Tecnología. Decirlo en la sesión nos protege de dos maneras: evita prometer un método cuya condición de entrada el banco no cumple, y convierte la ausencia de cadena de ingeniería de un hallazgo incómodo en la razón concreta por la cual hay un orden.

---

## Cómo cambia la taxonomía y los saltos

En **Artefactos**, el subcomponente de especificación y requerimientos cambia de naturaleza: deja de ser documentación de entrada y pasa a ser el plano de control. Es un cambio de estado del subcomponente, no un componente nuevo.

En **Gobierno**, la constitución es la forma verificable por máquina de dos subcomponentes que ya existen: arquitectura y estándares, y riesgo, cumplimiento y regulación.

En los **saltos**, SDD entra en el dos y se cobra en el tres. El salto uno no lo ejecuta, pero lo alimenta: la separación de cuáles controles exige el regulador local y cuáles vienen del grupo es exactamente el insumo de la constitución. Por eso **Artefactos deja de estar apagado en el salto dos**.

---

## Qué no llevamos a la sesión

El nombre del toolkit se queda fuera del material de cliente, por la regla de neutralidad de herramienta de este proyecto y porque está declarado como experimental. El método sí se nombra; el producto no.

Las cifras de proveedor se quedan fuera completas. No hay ninguna que sobreviva la pregunta de la fuente.

La palabra agente se dosifica. El desarrollo multiagente es el destino del método y es correcto, pero abrir con autonomía agéntica ante un director que acaba de rechazar una propuesta por poco aterrizada es volver a lo abstracto. Entra en el salto tres, no en la lámina uno.

---

## Fuentes

Documento de casa: [`source/docs/sdd speckit beginners guide v1.pdf`](../../source/docs/), Accenture, febrero de 2026, seis páginas, con declaración de contenido generado por IA.

Contraste primario, consultado el 29 de octubre de 2026: [Microsoft Learn, módulo sobre Spec-Driven Development con Spec Kit](https://learn.microsoft.com/en-us/training/modules/spec-driven-development-github-spec-kit-enterprise-developers), [Microsoft for Developers, entrada original del método](https://developer.microsoft.com/blog/spec-driven-development-spec-kit), [GitHub, anuncio del toolkit abierto](https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/), [documentación de Spec Kit](https://github.github.io/spec-kit/), [Pluralsight sobre SDD en empresa](https://www.pluralsight.com/resources/blog/software-development/spec-driven-development-with-AI-SDD), [Opsera con el pronóstico de Gartner](https://opsera.ai/blog/spec-driven-development), [revisión del estado del método en 2026](https://dev.to/krlz/spec-driven-development-in-2026-what-it-is-the-tooling-and-how-teams-actually-use-it-2fk2).
