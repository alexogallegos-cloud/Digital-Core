<!--
  Documento: lectura de la infografía sobre Skill-Driven Development
  Fuente:    infografía "Beyond the Spec: The Evolution of Skill-Driven AI Development",
             sin autor, sin fecha y sin fuentes visibles. Recibida el 2026-10-29.
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-29
  Contrastado contra fuente primaria el mismo día. Ver sección de verificación.
-->

# El Skill-Driven Development, y qué sobrevive de él

**Conclusión primero.** Trae un argumento que es mejor que el que yo había escrito para la etapa tres, y hay que adoptarlo. Trae también cifras que no se pueden usar con este cliente bajo ninguna circunstancia. Y verificado contra fuente primaria, el problema que describe está bien documentado, pero el nombre de la solución es el término de un solo autor.

---

## El argumento que hay que adoptar

Mi versión de la etapa tres decía que las capacidades del banco se empaquetan una vez y se reutilizan. Es correcto y es tibio. La infografía dice algo más preciso y más fuerte, en tres piezas encadenadas.

**La especificación codifica el qué, no el cómo.** Describe el resultado deseado, pero no captura las convenciones aprendidas que persisten de una tarea a otra. Esa es una crítica real al método que acabamos de poner en el centro del salto dos, y conviene que la hagamos nosotros antes de que la haga alguien más.

**De ahí sale la amnesia de sesión y su impuesto.** Cada sesión arranca en frío y el primer tramo se gasta en reorientar al agente sobre restricciones de arquitectura que ya había visto. La infografía lo llama impuesto de orientación y lo cuantifica en quince minutos por sesión. La cifra no tiene fuente, pero el fenómeno sí está documentado.

**Y la consecuencia es la que importa: crecimiento lineal contra crecimiento compuesto.** Un equipo en Spec-Driven Development vuelve a hacer las mismas correcciones una y otra vez. Un equipo en Skill-Driven Development codifica una corrección **una sola vez y esa categoría de error desaparece**. Esa frase es el argumento entero de la etapa tres, y es mucho mejor que hablar de reutilización.

La infografía describe además la capa de infraestructura que lo sostiene, con tres piezas: memoria de sesión, que es un almacén consultable de transcripciones y decisiones pasadas; grafo de conocimiento del código, que indexa el espacio de trabajo y permite contestar qué se rompe si cambio esto; y vocabulario de comandos, que son manifiestos estructurados para que el agente no adivine sintaxis.

---

## Lo que esto nos da con Banamex, y es lo más diferenciado del expediente

**De las tres piezas de esa infraestructura, una ya existe para el core de este banco y la construimos nosotros.** El grafo de conocimiento del código es exactamente lo que es el cerebro digital del core en Unisys: 1,583 reglas de negocio trazadas al programa y a la línea, 152 programas, dependencias cruzadas, trece reportes regulatorios trazados al programa que los produce y un vocabulario de 2,668 términos normalizados. La pregunta de qué se rompe si cambio esto tiene respuesta para sus sistemas, hoy.

Eso no es una promesa, es un inventario. Y es la única parte de toda esta conversación donde llegamos con el activo construido en lugar de con el método.

**Cuidado con el encuadre.** Esto se trae como prueba de que sabemos construir la capa de conocimiento que la etapa tres exige, no como una propuesta sobre el core. La conversación es del ciclo de entrega. Si se convierte en una conversación de modernización del core, nos salimos del tema y repetimos el error de empaquetar otro proyecto dentro de este.

---

## Lo que verifiqué

**El problema está documentado. El nombre de la solución, no.** Un trabajo académico sobre Spec-Driven Development para ingeniería agéntica establece que un modelo de lenguaje es, por construcción, sin estado, y que cada sesión empieza sin memoria de lo anterior; propone un almacén persistente de decisiones, justificaciones y hallazgos que se lee al inicio y se escribe al final de cada sesión. Eso valida la amnesia de sesión como fenómeno real.

**El término Skill-Driven Development no tiene definición establecida.** La referencia más cercana es una entrada de blog de un solo autor que lo contrapone al Spec-Driven Development, con el argumento de que las especificaciones son artefactos de entrada que se consumen y quedan estáticos, mientras que las capacidades son artefactos de salida producidos durante la construcción y reutilizables por cualquier agente posterior. Es una opinión, bien argumentada, no un método establecido.

**La afirmación de crecimiento compuesto no está probada.** Descansa en esa misma entrada de blog y no aparece verificada en la literatura que encontré.

**Y la literatura señala un riesgo que la infografía menciona de pasada y que en realidad es el principal.** A medida que la biblioteca de capacidades crece, adquirirla y mantenerla se vuelven problemas distintos, y las bibliotecas acumulan duplicados y regresiones. La propia infografía lo dice bien: el mantenimiento es el único costo, y una capacidad obsoleta es peor que ninguna porque el agente la seguirá con convicción equivocada.

Hay una formulación de la literatura que vale la pena conservar textualmente: memoria sin ingeniería de contexto se vuelve acumulación, e ingeniería de contexto sin memoria se vuelve amnesia.

---

## Las cifras, y por qué ninguna entra

**197,831 líneas de código en once días, contra un estándar de industria de diez a dieciocho meses.** No se usa. Líneas de código es una medida desacreditada de productividad y más líneas no es más valor; el interlocutor dirigió una organización global de software y lo va a decir en cuatro segundos. El estándar de industria citado no corresponde a ningún trabajo comparable, porque la biblioteca construida no se nombra ni se describe. Y la infografía no trae autor, fecha ni fuente.

**Setenta y cinco capacidades heredadas, medidamente más capaz.** Medido con qué, contra qué. No se usa.

**Quince minutos de impuesto de orientación por sesión.** El fenómeno sí, la cifra no. Se puede decir que cada sesión arranca en frío y que ese arranque cuesta; no se puede poner un número sin medirlo aquí.

Estas tres son exactamente el tipo de cifra que hundió la versión 3.3. Las adoptamos como dirección y las descartamos como evidencia.

---

## Un detalle de consistencia de la propia infografía

Llama a su capa inferior *capa de infraestructura SDD* mientras describe infraestructura de capacidades, y atribuye el caso de las 197,831 líneas a SDD bajo un encabezado de Skill-Driven Development. La sigla se usa para las dos cosas. Conviene no heredar esa confusión: en nuestro material, especificación y capacidades son dos etapas distintas con dos unidades de trabajo distintas.

---

## Qué cambia en nuestra matriz

**La etapa tres de Artefactos** deja de ser *los artefactos se componen* y pasa a ser *las correcciones dejan de repetirse*. Una corrección se codifica una vez y esa categoría de error desaparece.

**La etapa tres de Gobierno gana un objeto de control nuevo**, y esto es importante en un banco. Si la capacidad se certifica una vez y cada uso hereda esa certificación, entonces la biblioteca de capacidades pasa a ser un activo gobernado: hay que versionarla, certificarla y caducarla. Una capacidad obsoleta que un agente aplica con convicción no es un defecto de software, es un incidente de cumplimiento. La certificación tiene que tener vencimiento.

**La etapa tres de Tecnología** gana las tres piezas concretas de infraestructura: memoria de sesión, grafo de conocimiento del código y vocabulario de comandos. Deja de ser abstracta.

---

## Sobre la etapa uno, y el nombre que trae

La infografía llama a su etapa uno *vibe coding*: prompting no estructurado, corregir sobre la marcha, rápido para prototipos y peligroso para producción por falta de repetibilidad.

**Ese nombre no va delante de este interlocutor**, ni como etiqueta de su organización. Nuestra etapa uno se sigue llamando AI-Assisted Development.

Pero el concepto sí sirve, y vale como hallazgo de gobierno. AI-Assisted Development y vibe coding son la cara gobernada y la no gobernada de la misma etapa. **En un entorno sin control de versiones, sin integración continua y sin automatización de pruebas no existe ningún mecanismo que distinga una de la otra.** Ese es el estado declarado del banco en Tecnología. No es una acusación: es la razón concreta por la cual la cadena de ingeniería es prerrequisito y no complemento.

---

## Fuentes

Infografía recibida el 29 de octubre de 2026, sin autor, fecha ni fuentes visibles.

Contraste primario, consultado el 29 de octubre de 2026: [trabajo sobre Spec-Driven Development para ingeniería agéntica, arXiv](https://arxiv.org/pdf/2609.00252), [entrada original sobre Skill-Driven Development](https://zakelfassi.com/skdd-skills-driven-development), [compilación de experiencia del agente en conocimiento persistente, arXiv](https://arxiv.org/html/2608.27454v1), [sobre evolución continua de capacidades e historial persistente de decisiones, arXiv](https://arxiv.org/pdf/2606.08671), [sobre compresión de capacidades y el problema de mantenimiento, arXiv](https://arxiv.org/pdf/2608.11079), [memoria del agente frente a ingeniería de contexto](https://www.augmentcode.com/guides/agent-memory-vs-context-engineering).
