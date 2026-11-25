<!--
  Documento: estudio de mercado para la conversación de ciclo de entrega con Banamex
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture que arma la propuesta. No es material de cliente.
  Versión:   v1.1 · 2026-10-28 · Todas las afirmaciones llevan la fecha del dato y la del hallazgo.
-->

# Estudio de mercado: el ciclo de entrega de software en Banamex y en la banca mexicana

**Fecha de corte de la investigación: 28 de octubre de 2026.**

## Para qué sirve este documento y cómo leer las fechas

La propuesta anterior se cayó porque llegó con método y sin datos del banco, y porque presentó en octubre de 2026 un mapa levantado en octubre de 2025 sin refrescarlo. Sería incoherente cometer el mismo error aquí, así que cada afirmación de este documento lleva dos fechas: la del dato, que es el momento al que se refiere el hecho, y la de la fuente, que es cuándo se publicó.

Donde la evidencia es autorreportada por el banco o por su proveedor, se dice. Donde falta el dato, se marca como DATO-REQUERIDO en vez de rellenarlo. La sección 11 resume qué tan fresco es cada bloque y qué hay que revalidar antes de usarlo frente al cliente.

---

## 1. Cronología de los hechos que enmarcan la conversación

| Fecha | Hecho | Frescura |
|---|---|---|
| 4 de noviembre de 2024 | Francisco Leyva toma la dirección corporativa de Operaciones y Tecnología de Banamex, procedente de BBVA | Confirmado |
| Cuarto trimestre de 2024 | Corte de las cifras operativas del banco que circulan en prensa: 20 millones de clientes, 1,284 sucursales, 39,415 empleados | Dos años de antigüedad |
| 6 y 9 de enero de 2025 | Leyva describe en Expansión un plan a seis años para renovar los sistemas, con inversión de 1,700 millones de dólares | Primera aparición pública de la cifra |
| 24 de abril de 2025 | Entrevista de Leyva en IT Masters Mag, la fuente de casi todas sus citas en este documento | Dieciocho meses |
| 24 de abril de 2025 | La Comisión Nacional Bancaria y de Valores aprueba la licencia bancaria de Nu México | Superado por hechos posteriores |
| Junio de 2025 | Santander completa el despliegue de Gravity en su tecnología central de España | Vigente |
| Septiembre de 2025 | Banorte renueva por tres años su alianza con Google Cloud, vigente desde 2021 | Vigente |
| Octubre de 2025 | Accenture levanta el mapa del ciclo de entrega actual de Banamex | Un año, sin refrescar |
| Diciembre de 2025 | Fernando Chico Pardo compra el 25% de Grupo Financiero Banamex por 2,300 millones de dólares y asume la presidencia del consejo | Vigente |
| 31 de marzo de 2026 | Citi declara en su reporte trimestral que no prevé más ventas de acciones en 2026 | Vigente |
| 28 de mayo de 2026 | BBVA anuncia 15,000 licencias de asistente de código y 100,000 repositorios en plataforma global | El caso más reciente disponible |
| 30 de junio de 2026 | Citi declara en su reporte trimestral que podría desconsolidar Banamex a inicios de 2027 | Vigente |
| 2 de julio de 2026 | Entra en vigor la verificación de identidad por biometría facial en bancos mexicanos | Vigente |
| 10 de julio de 2026 | La Comisión autoriza a Nu México a iniciar operaciones como banco | Vigente |
| Julio de 2026 | Banorte reporta 6% de crecimiento en utilidad y 29% de ventas por canales digitales | Vigente |
| 6 de agosto de 2026 | Nu México opera con licencia bancaria completa, tras migración técnica el día 5 | Vigente |
| 23 de agosto de 2026 | Caída de la aplicación de Banamex reportada por usuarios | Puntual, no estructural |
| Segundo trimestre de 2026 | Banamex queda cuarto en satisfacción de aplicaciones, detrás de Mercado Pago, DiDi Finanzas y Nu | Vigente |
| 13 de octubre de 2026 | Se reporta concluida la venta del tramo restante hasta completar el 49% | Vigente |
| 21 de octubre de 2026 | Expansión publica el plan de Chico Pardo y reconfirma los 1,700 millones de dólares | Vigente |
| 22 de octubre de 2026 | Analistas de los bancos colocadores se reúnen con la dirección en Ciudad de México | Vigente |
| Octubre de 2026 | Accenture presenta la propuesta v3.3 y Banamex la rechaza | Hecho que origina este trabajo |
| Inicios de 2027 | Desconsolidación contable prevista por Citi | Proyectado |
| Primer trimestre de 2027 | Oferta pública inicial perfilada, por más de 3,000 millones de dólares | Proyectado, sin fecha oficial |
| 2029 | Fecha declarada de separación tecnológica completa de los sistemas de Citi | Proyectado |

Dos lecturas de esta tabla. La primera es que el reloj corre: quedan poco más de dos meses hasta el cierre del año y un trimestre hasta la oferta pública. La segunda, más incómoda, es que las declaraciones en las que basamos la lectura del interlocutor tienen dieciocho meses.

---

## 2. Banamex hoy

### La situación de control y el calendario

Citi completó la venta del 49% del capital de Banamex. Fernando Chico Pardo compró el 25% en diciembre de 2025 por 2,300 millones de dólares y asumió la presidencia del consejo; un grupo de inversionistas tomó el 24% restante por unos 2,500 millones de dólares, y el 13 de octubre de 2026 se reportó concluido el tramo final. En su reporte al 31 de marzo de 2026 Citi declaró que no anticipa más ventas en 2026.

El paso siguiente no es la bolsa sino la desconsolidación contable. En el reporte al 30 de junio de 2026 Citi indicó que, según sus expectativas, podría reconocer las pérdidas por conversión y desconsolidar Banamex a inicios de 2027. La oferta pública inicial se perfila para el primer trimestre de 2027, con un tamaño reportado de más de 3,000 millones de dólares en nota de Bloomberg del 22 de octubre de 2026, aunque no hay fecha oficial, rango de precio ni bolsa confirmada. Ese mismo día los analistas de los colocadores estuvieron en Ciudad de México reuniéndose con la dirección.

Para la conversación que nos interesa, el calendario importa por una razón concreta: entre hoy y el primer trimestre de 2027 hay poco más de un trimestre, y entre hoy y 2029 hay tres años. Lo primero fija la exigencia de que nada se rompa. Lo segundo fija el volumen de trabajo.

### El tamaño del esfuerzo tecnológico

Banamex prevé invertir alrededor de 1,700 millones de dólares en seis años para modernizar sus plataformas y dejar de depender de los sistemas de Citi, con fecha de separación en 2029. La cifra no es nueva: Leyva la describió en enero de 2025, y Expansión la reconfirmó el 21 de octubre de 2026, lo que es buena señal porque indica que el compromiso sobrevivió al cambio de accionista. En su informe público de abril de 2026, Moody's Local México señala que la salida de Citi como accionista mayoritario obliga al banco a acelerar inversiones ante la desvinculación progresiva de los sistemas legados de su matriz. En marzo de 2026, Chico Pardo anticipó que el gasto en tecnología sería la mayor inversión de su primer año al mando.

Si el plan es a seis años desde enero de 2025, hoy va en el año dos. Vale la pena preguntarle al banco cuánto se ha ejercido y qué se ha entregado, porque esa pregunta la va a tener que contestar frente a analistas en unos meses.

La organización que ejecuta eso son unas 18,000 personas en Tecnología y Operaciones, de las cuales unas 7,000 están en Sistemas, según la entrevista de abril de 2025. El artículo no fecha estas dos cifras, a diferencia del resto de su tabla, de modo que hay que tratarlas como aproximadas y de 2025. Las cifras operativas del banco que circulan, 20 millones de clientes con 12.2 millones de usuarios digitales, 1,284 sucursales, 9,112 cajeros, 13,152 corresponsales y 39,415 empleados, están explícitamente marcadas al cierre del cuarto trimestre de 2024. Tienen dos años. La operación digital movía 156 millones de interacciones en banca móvil y unos 50 millones de transacciones digitales al mes en ese mismo corte.

### La posición competitiva

Con datos a julio de 2026 reportados por Expansión el 21 de octubre de 2026: Banamex es cuarto en activos y quinto en cartera; tiene cerca de una cuarta parte del mercado de tarjetas de crédito, pero menos de 6% en hipotecario y en empresarial, y presencia limitada en automotriz y microcrédito. Su cartera creció 11.9% anual contra 8% del sistema, pero convierte en préstamos 67 de cada 100 pesos captados, veinte puntos por debajo del promedio, y su morosidad es de 3.18% contra 2.31% del sistema. La utilidad neta de enero a julio de 2026 fue de 13,494 millones de pesos, 57.8% más que un año antes, apoyada por la venta de su participación en el Buró de Crédito. El retorno sobre capital rondaba 11.5%, por debajo del promedio sectorial.

La ambición declarada del nuevo dueño, en octubre de 2026, es explícita y es grande: "¿Por qué no aspirar a ser del tamaño de BBVA en unos años?". Eso no se consigue con el ciclo de entrega actual, y ese es exactamente el punto donde nuestra conversación tiene lugar.

### Lo que el banco ya hace bien

Conviene no entrar con un diagnóstico de desastre, porque no sería cierto y además el interlocutor lo sabe. En el monitor de aplicaciones bancarias y fintech de México del segundo trimestre de 2026, la aplicación de Banamex registró la mayor proporción de usuarios muy satisfechos y quedó cuarta en la puntuación general, detrás de Mercado Pago, DiDi Finanzas y Nu. Global Finance le otorgó nueve reconocimientos en 2026, incluido el de mejor aplicación de banca móvil. La cuenta digital Switch superaba las 100,000 aperturas mensuales en octubre de 2026. El problema no es que el banco no sepa construir producto digital. El problema es cuánto tarda y cuánta gente necesita para lograrlo.

---

## 3. Lo que Francisco Leyva ha dicho en público, y cuándo lo dijo

**Advertencia de vigencia, y es la más importante del documento.** Casi todas las citas que siguen son de la entrevista publicada el 24 de abril de 2025 en IT Masters Mag. Tienen dieciocho meses y son anteriores a la entrada de Chico Pardo como presidente del consejo en diciembre de 2025. Siguen siendo la mejor evidencia pública de su agenda, pero no son evidencia de su agenda de hoy. Hay que usarlas como hipótesis a confirmar en la sesión, no como hechos. Confirmar si existe una declaración más reciente es una tarea pendiente antes de presentar.

Un dato de contexto que importa y que no estaba en nuestra lectura anterior: Leyva llegó a Banamex desde BBVA, con el cargo efectivo el 4 de noviembre de 2024. Eso significa que viene de la organización que hoy corre 15,000 licencias de asistente de código sobre una plataforma global única. Sabe cómo se ve una cadena de entrega consolidada, y va a notar de inmediato si le proponemos algo que no lo esté.

Sobre la autonomía, abril de 2025: "El objetivo es claro: ser un banco universal, autónomo y con capacidades propias" y "Tenemos que ser autónomos lo antes posible". Liga explícitamente la bolsa con la preparación tecnológica: "necesitamos estar listos, y eso pasa por estar listos tecnológicamente".

Sobre la dependencia de terceros, que es la frase que más nos sirve, abril de 2025: "Hoy dependemos demasiado de terceros", y lo atribuye a "decisiones del pasado con ventajas contables o estructuras globales". Su conclusión es "Tenemos que fortalecer nuestras capacidades internas". Esto es, textualmente, la agenda de reducir contratación externa y subir capacidad propia.

Sobre el tamaño de las entregas, abril de 2025: "Prefiero los despliegues en periodos cortos. Los proyectos grandes, de varios años, suelen desviarse", y "Haremos entregas progresivas y visibles". Sobre el legado: "Hay que salir de los mainframes tradicionales para evitar esos costos", pero "de forma progresiva, sin un big bang que paralice la operación".

Sobre el dinero, la frase que reinterpreta la objeción de "muy cara", abril de 2025: "No se cuestionan las inversiones. Son recursos generosos, pero también con una exigencia clara de orden y prioridades". El banco tiene 1,700 millones de dólares comprometidos. Lo que no tiene es tolerancia a gasto sin prioridad demostrada. Nuestra propuesta de octubre de 2026 no falló la prueba del precio; falló la prueba de la prioridad. Aquí hay que tener cuidado con la vigencia: la frase es de antes de que llegara el nuevo dueño, y la disciplina de gasto bajo un consejo que prepara una oferta pública puede ser bastante más dura hoy.

Sobre el alcance del cambio, abril de 2025: "Tecnología no lo es todo. También es clave modernizar procesos, automatizar donde sea necesario". Y sobre las fintech: "Han habilitado buenas experiencias, sobre todo en la economía informal", pero "no tienen capacidades estructurales como el fondeo", y "Si nosotros damos buenas experiencias, no hay razón para que nos desplacen". Esta última conviene contrastarla con el dato del segundo trimestre de 2026: tres de los competidores que menciona quedaron por delante de Banamex en satisfacción.

Su filosofía de cierre, que conviene citarle de vuelta porque define el formato que va a aceptar: "Las transformaciones que valen la pena se construyen ladrillo a ladrillo".

**Lectura para la propuesta.** Un interlocutor que dice esto no va a comprar un programa de nueve semanas con tres fases y trece entregables documentales. Va a comprar un primer ladrillo pequeño, visible, medible y con una fecha corta, que además demuestre capacidad propia en lugar de instalar más dependencia externa. Cualquier cosa que proponga Accenture tiene que resolver la tensión de que nosotros también somos un tercero, y la única manera honesta de resolverla es proponerse como el tercero que se va.

---

## 4. Los cinco retos de Banamex que tocan el ciclo de entrega

**La separación tiene fecha y la ventana es finita.** Según la entrevista de abril de 2025, buena parte de la infraestructura y de los servicios operan bajo un acuerdo temporal de servicios con Citi, que cubre entre otras cosas ciberseguridad, recursos humanos y tesorería. Ese acuerdo da soporte por un periodo limitado que ninguna fuente pública fecha. Cada mes que el ciclo de entrega tarda más de lo necesario es un mes menos de ventana para reemplazar lo que hoy presta Citi, y el horizonte declarado es 2029.

**Hay capacidades que no existen y hay que construirlas o integrarlas.** Leyva lo dijo sin rodeos en abril de 2025: "Hoy hay capacidades que no tenemos, como las del negocio corporativo que se quedan con Citi. Pero vamos a recuperarlas", y "Tenemos que desarrollar o integrar nuestras propias soluciones de forma urgente". Esto convierte el ciclo de entrega en el cuello de botella del programa completo: no es un tema de eficiencia interna, es la restricción que gobierna si la separación se cumple en 2029.

**La dependencia de terceros es un problema declarado, no una sospecha.** Con unas 7,000 personas en Sistemas en 2025 y una declaración pública de sobredependencia externa, la pregunta que el banco se está haciendo no es cuánto cuesta un proveedor más, sino cómo queda la pirámide de talento al final. Esa pregunta no tiene respuesta hoy, y nadie se la ha puesto por escrito.

**La salida del mainframe obliga a entregas cortas.** Un banco que decide salir del legado sin un gran corte único necesita, por construcción, poder liberar con frecuencia y con poco riesgo durante los tres años que quedan hasta 2029. El ciclo de entrega deja de ser un asunto de productividad y se vuelve el prerrequisito de la estrategia de modernización. Si el ciclo no se acorta, la única salida posible del mainframe vuelve a ser el gran corte único que el banco ya descartó en 2025.

**La bolsa convierte la predictibilidad en requisito de mercado de capitales.** A partir del primer trimestre de 2027, el banco tendrá que sostener compromisos de entrega frente a analistas que ya están viéndolo desde octubre de 2026. Fallar una fecha deja de ser un tema interno. Un ciclo que hoy no se puede medir tampoco se puede prometer.

---

## 5. Los retos de la banca mexicana en 2026

### La competencia cambió de naturaleza, y cambió este año

Nu México presentó su solicitud de licencia el 19 de octubre de 2023, la Comisión Nacional Bancaria y de Valores la aprobó el 24 de abril de 2025, la autorización para iniciar operaciones llegó el 10 de julio de 2026 y el banco opera con licencia completa desde el 6 de agosto de 2026, tras una migración técnica el día anterior. Con más de 15 millones de clientes se convierte en el banco digital más grande del país. La protección de sus depósitos pasó automáticamente del tope de sociedad financiera popular, de unos 12,600 dólares, a la garantía del Instituto para la Protección al Ahorro Bancario, de unos 201,000 dólares por cliente. En el primer trimestre de 2026 Nu México reportó punto de equilibrio y más de 5,900 millones de dólares en depósitos. La licencia le abre nómina, cuenta corriente, límites mayores y crédito.

Es decir, la competencia que Leyva describía en abril de 2025 como jugadores de nicho sin capacidad de fondeo cambió de categoría legal hace tres meses. El dato incómodo para Banamex no es que Nu exista, sino el orden del ranking de satisfacción del segundo trimestre de 2026: Mercado Pago, DiDi Finanzas y Nu por delante. Tres competidores que no cargan con un acuerdo de separación tecnológica ni con cuatro centros de datos, y que liberan software todas las semanas.

La gobernadora del Banco de México observó en 2026 que la operación de Banamex deja dos bancos sistémicos nuevos en el país, sumando a Citi, lo que puede aumentar la competencia. El propio regulador espera que el mercado se ponga más duro, no menos.

Para dimensionar el movimiento del sector, la Asociación de Bancos de México contaba 50 instituciones en 2018 y 55 en 2025. La Política Nacional de Inclusión Financiera 2025-2030 reporta que en 2024 alrededor del 77% de la población adulta tenía algún producto financiero, con rezago concentrado en zonas rurales.

### Los otros grandes ya están gastando

BBVA México anunció una inversión de más de 100,000 millones de pesos para el periodo 2025 a 2030 en digitalización, sostenibilidad y crédito productivo; en mayo de 2026 reiteró la cifra y añadió que la inteligencia artificial podría volverla 30% más eficiente. Banorte trabaja con Google Cloud desde 2021 y renovó la alianza por tres años en septiembre de 2025 para inteligencia artificial, analítica y ciberseguridad. En julio de 2026 reportó un crecimiento de 6% en utilidad neta y señaló que sus ventas por canales digitales pasaron de 7% en 2019 a 29% en 2026. Fue el único banco mexicano incluido en el índice Evident de inteligencia artificial para bancos de América Latina en 2026.

La comparación relevante no es de inversión sino de punto de partida. BBVA y Banorte invierten sobre una base que ya controlan, y llevan cinco años haciéndolo. Banamex invierte mientras se separa de la plataforma de otro, y lleva dos.

### La regulación añade pasos al ciclo, no los quita

Esto es lo que casi siempre se omite en las propuestas de aceleración y es justo lo que un Director de Operaciones de banco va a comprobar primero.

La Circular Única de Bancos, emitida en diciembre de 2005 y reformada muchas veces desde entonces, regula la contratación de servicios de apoyo tecnológico, con el Anexo 52 como referencia de lineamientos mínimos de operación y seguridad. La guía de la Comisión para la contratación con terceros, en su versión del 12 de septiembre de 2022, exige declarar la subcontratación y nombrar a cada proveedor que participa, mantener en México la documentación de evaluaciones, auditorías y reportes de desempeño, y entregarla en español cuando se requiera. Cuando el proveedor es el primario y su falla podría interrumpir operaciones, se requiere autorización de Banco de México y de la Comisión. Las reglas conjuntas de 2021 exigen que los datos sensibles de pagos se almacenen y procesen en territorio mexicano. Desde el 2 de julio de 2026 los bancos pueden verificar identidad con biometría facial, y en ciertos casos están obligados a hacerlo. En junio de 2026 entraron cambios escalonados que tocan el cálculo del costo anual total, el acceso de instituciones de tecnología financiera al sistema de pagos y los requisitos de capital mínimo por volumen.

Al mismo tiempo, el nivel más valioso de open finance sigue sin regulación secundaria ocho años después de la Ley Fintech de 2018, al punto de que hay un amparo presentado contra la Comisión, Banco de México y Hacienda por esa omisión. Banco de México ha identificado los avances tecnológicos como principal riesgo para las instituciones financieras y sus usuarios.

**Por qué esto importa para el ciclo de entrega.** Cada uno de estos requisitos se traduce hoy, en casi todos los bancos mexicanos, en evidencia documental producida a mano por personas que no escriben código. Ese es el trabajo del que el Director de Operaciones quiere prescindir. La vía para quitarlo no es saltárselo, que es ilegal, sino generarlo automáticamente desde la propia cadena de entrega. Ese es el argumento más fuerte que tenemos y el que ningún proveedor de simplificación de procesos puede dar, porque exige tocar la ingeniería y no el flujo de aprobación.

Precaución de vigencia: las fuentes sobre contratación con terceros van de agosto de 2017 a septiembre de 2022, y buena parte proviene de proveedores de nube y de análisis de terceros. Antes de afirmar cualquier requisito específico frente al cliente hay que verificar el texto vigente de la Circular Única en el sitio de la Comisión.

---

## 6. Qué han hecho otros bancos, y hace cuánto

Advertencia general de calidad de evidencia: casi todas las cifras de resultado en esta categoría son autorreportadas por el banco o por su proveedor de nube, y varias tienen entre cinco y ocho años. No hay auditorías independientes públicas. Sirven para ilustrar la forma del cambio, no para comprometer un número.

### DBS, Singapur. El caso más cercano a la agenda de Leyva

Fechas del caso: 2014 a 2024, con el cambio estructural en 2018.

Es el único caso grande cuya tesis central es exactamente la del Director de Operaciones de Banamex: reducir dependencia externa y subir capacidad técnica propia. DBS pasó de estar alrededor de 85% tercerizado en 2014 a tener cerca de 85% a 90% del trabajo adentro hacia 2019, construyendo entre otras cosas un equipo propio de unas 2,000 personas en Hyderabad. Las fuentes dan porcentajes ligeramente distintos, entre 80% y 90%, según la entrevista y el año.

El cambio estructural vino en 2018, documentado en el informe anual de ese año: se reorganizó en 33 plataformas, cada una dirigida conjuntamente por un responsable de negocio y uno de tecnología que comparten una sola tarjeta de resultados, con fondeo permanente de unidad en lugar de presupuesto por proyecto y revisión sobre tableros en vivo. Parte de la remuneración de la pareja estaba atada a la transformación. A partir de 2021 añadió una segunda capa para el trabajo que cruza varias plataformas: para 2024 corrían más de 60 recorridos de cliente que cubrían más del 60% del ingreso, según el caso del IMD. El banco ya está evolucionando el modelo de dos a múltiples responsables por caja, incorporando operaciones y funciones de soporte al mismo resultado; la fecha exacta de ese último paso es DATO-REQUERIDO.

En resultados de entrega, material del propio banco de alrededor de 2018 reporta que el tiempo de salida de una liberación mayor pasó de seis meses a menos de cuatro semanas, y el tiempo de espera de 32 horas a 3 horas. Un reconocimiento de Forrester reporta 60% de aceleración en el tiempo de entrega a despliegue de su plataforma analítica en 2021. Sobre inteligencia artificial, en 2025 el propio banco planteaba que busca acelerar tiempo de salida y mejorar calidad, pero describe el efecto como aumentar al ingeniero, no sustituirlo.

**Lo que hay que llevarse de DBS.** No fue una metodología. Fueron tres decisiones de gobierno: equipos permanentes con fondeo permanente, una sola tarjeta de resultados compartida entre negocio y tecnología, y traer la capacidad adentro. La velocidad fue consecuencia, no objetivo. La advertencia honesta es que los números de entrega tienen ocho años y no hay actualización pública de los ratios de internalización desde 2021.

### ING, Países Bajos. El caso con el que hay que tener cuidado

Fechas del caso: reorganización en 2015, estudio de McKinsey en 2017, crítica en 2021. Es el caso más viejo del conjunto.

Reorganizó en 2015 en unos 350 equipos de nueve personas dentro de 13 tribus. El propio banco atribuye al cambio más procesos automatizados, una reducción marcada de traspasos entre áreas y una cultura de desempeño colaborativa. McKinsey reporta mejoras en tiempo de salida, compromiso del personal y productividad.

La advertencia es igual de útil que el caso. Un análisis crítico de 2021 señala que los resultados globales frecuentemente no alcanzaron promesas poco realistas, y describe la transformación como una colisión entre nuevas formas de trabajar y viejas formas de financiar. Esa frase es la que hay que decirle al banco: si el dinero se sigue asignando por proyecto anual, el equipo puede ser ágil y el ciclo seguirá siendo lento. Algunas cifras que circulan sobre ING, como una reducción de 30% de plantilla o un salto de satisfacción de menos 30 a más 30, no están verificadas contra fuente primaria y no deben usarse.

### Capital One, Estados Unidos. El caso de la capacidad propia

Fechas del caso: migración de 2012 a 2020, con una nota de diciembre de 2025 que conviene conocer.

Cerró sus ocho centros de datos y migró completo a nube pública en unos ocho años, construyendo desde cero cerca del 80% de las casi 2,000 aplicaciones que corre. El equipo de tecnología creció a unas 11,000 personas durante la migración. En resultados de entrega reporta que el tiempo de construcción de un ambiente de desarrollo pasó de tres meses a minutos, con 70% de mejora en pruebas de recuperación ante desastres y 50% de reducción en errores de transacción y en tiempo de resolución de incidentes críticos.

Un reporte de diciembre de 2025, sin verificar contra fuente primaria, señala que la empresa explora centros de datos propios para cargas de inteligencia artificial por el costo de cómputo. No lo usaría frente al cliente, pero conviene saberlo por si alguien en la sala lo menciona.

**Lo que hay que llevarse.** El número que mejor se traduce a la conversación de Banamex es el del ambiente de desarrollo. Tres meses de espera por un ambiente es tiempo que no aparece en ninguna metodología y que domina el tiempo total de salida. Es, además, el tipo de espera que Origen existe para eliminar.

### Santander. El caso del legado sin gran corte

Fechas del caso: alianza con Google Cloud en octubre de 2022, España completo en junio de 2025, crítica independiente en junio de 2025. Es el caso más vigente en materia de legado.

Gravity permite correr cargas en el mainframe y en la nube al mismo tiempo, lo que habilita pruebas reales sin interrumpir el negocio. España completó la migración de su tecnología central en junio de 2025, y el grupo estima que al terminar Brasil y México tendrá alrededor del 80% de su infraestructura central en nube. El banco afirma en 2025 que el tiempo de lanzamiento de nuevas funcionalidades pasó de semanas a horas, aunque comunicados anteriores decían de días a horas, lo que ya indica que la cifra se mueve según el año. Un análisis independiente de junio de 2025 cuestiona que falte validación concreta de esas afirmaciones y que la confiabilidad bajo estrés no esté demostrada.

**Lo que hay que llevarse.** La forma de salir del legado sin gran corte existe y está probada en un banco grande con operación en México. Conviene citar el escepticismo junto con la cifra, porque eso es exactamente lo que da credibilidad frente a un ejecutivo que ya rechazó una propuesta por poco aterrizada.

### BBVA. El caso de la inteligencia artificial a escala, y la casa de la que viene Leyva

Fechas del caso: anuncio del 28 de mayo de 2026. Es el caso más reciente del conjunto y el que el interlocutor conoce desde adentro.

Tiene desplegadas unas 15,000 licencias de asistente de código, usadas por el 70% de sus desarrolladores, y migró más de 100,000 repositorios a una plataforma global única. El banco afirma que acorta tiempos de entrega, acelera la modernización de código y reorganiza equipos, y describe que sus ingenieros pasaron de ejecutar tareas manuales a coordinar flujos completos de trabajo, incluyendo documentación, validación y gestión de incidentes.

**Lo que hay que llevarse, y el matiz.** BBVA no publica porcentajes de productividad. El dato de 55% más rápido que circula es de un estudio interno del fabricante sobre 95 ingenieros en una tarea de laboratorio, no un resultado de BBVA. El detalle que sí importa es el otro: una plataforma global única con 100,000 repositorios. El beneficio no vino del asistente sino de la consolidación previa que lo hizo posible. Banamex no tiene esa consolidación, y por eso copiar la parte visible del caso no produciría el mismo efecto. Dado que Leyva viene de ahí, este es el argumento que más peso va a tener y también el que peor tolera la imprecisión.

### Banorte. El referente local

Fechas del caso: alianza desde 2021, renovada en septiembre de 2025, resultados reportados en julio de 2026.

Trabaja con Google Cloud desde 2021 en modernización de infraestructura, y usa una plataforma abierta de contenedores para sus modelos y asistentes internos. Sus ventas digitales pasaron de 7% en 2019 a 29% en 2026. Es el único banco mexicano en el índice Evident de inteligencia artificial para América Latina en 2026.

**Lo que hay que llevarse.** Es la referencia local que el consejo de Banamex entiende sin traducción, y el dato de 7% a 29% en siete años es una buena vara para discutir qué tan rápido se mueve realmente un banco mexicano cuando sostiene una sola dirección tecnológica durante años. También es el contraargumento a cualquier promesa de transformación en nueve semanas.

---

## 7. Lo que la evidencia dice sobre la inteligencia artificial en el ciclo

Esta sección es el contrapeso honesto y, paradójicamente, es lo que más nos diferencia. Todos los proveedores van a llegar prometiendo aceleración por inteligencia artificial. Llegar con la evidencia completa, incluida la que incomoda, es lo que permite sostener una conversación de ejecutivo.

El informe DORA de 2024 encontró que un aumento de 25% en adopción de inteligencia artificial se asociaba con una caída estimada de 1.5% en rendimiento de entrega y de 7.2% en estabilidad. El informe de 2025, publicado como estudio sobre desarrollo asistido por inteligencia artificial, revierte parcialmente ese hallazgo: cerca del 90% de los encuestados ya la usa, más del 80% cree que ha subido su productividad, y la adopción ahora se asocia con mayor rendimiento de entrega, pero sigue asociada con mayor inestabilidad. La lectura del propio estudio es que la inteligencia artificial amplifica el sistema de ingeniería que ya existe, y que el tiempo ahorrado en crear se reasigna con frecuencia a auditar y verificar.

El estudio de METR midió en febrero de 2025 y se publicó en julio de 2025. Con 16 desarrolladores expertos trabajando sobre repositorios propios que conocían desde hacía años, encontró que con asistentes de código tardaron alrededor de 19% más en completar las tareas, aceptaron menos del 44% de las sugerencias, y aun así estimaron después que habían ganado un 20% de productividad. Los autores advierten que el resultado puede no trasladarse a desarrolladores menos expertos o a bases de código desconocidas, y que es una medición puntual con herramientas de principios de 2025. Esa advertencia hay que darla nosotros, no esperar a que la den en la sala: las herramientas de hoy no son las de febrero de 2025.

**La conclusión operativa.** La inteligencia artificial acelera el tecleo. En un banco donde el tiempo de salida está dominado por esperas, el tecleo no es el cuello de botella, de modo que acelerarlo no mueve la cifra que al Director de Operaciones le importa. Peor aún: en un sistema con control manual, la inestabilidad adicional se paga en más revisión manual, que es justo el trabajo que se quería eliminar. Esto no es un argumento contra la inteligencia artificial. Es un argumento sobre el orden: primero se mide dónde se va el tiempo y se automatiza la evidencia, y entonces la inteligencia artificial produce resultado neto en vez de deuda de revisión.

---

## 8. Los cinco patrones que se repiten en los que sí movieron el tiempo de salida

Cruzando DBS en 2018, ING en 2015, Capital One entre 2012 y 2020 y Santander en 2025, lo que se repite no son herramientas sino decisiones de gobierno. Que el patrón aguante una década de distancia entre casos es, en sí mismo, la mejor señal de que no depende de la tecnología de moda.

El primero es que los equipos y su dinero se vuelven permanentes. Se financia un equipo por un periodo para perseguir un resultado, en lugar de aprobar una suma grande para un proyecto de dos años. El análisis crítico de ING de 2021 es contundente en que el modelo de financiamiento es el punto donde estas transformaciones se rompen. Referencias de la industria mencionan mejoras de 30% a 50% en tiempo de salida al reducir traspasos y aprobaciones, pero esa cifra viene de material de proveedor sin fecha verificable y conviene tratarla como indicativa.

El segundo es que negocio y tecnología comparten una sola tarjeta de resultados, con nombre y apellido de ambos lados y con parte de la remuneración atada. Es el modelo que DBS documentó en su informe anual de 2018. Mientras existan dos listas de prioridades, existe la figura del gestor que las reconcilia, y esa figura es trabajo que el Director de Operaciones quiere eliminar.

El tercero es que la capacidad se trae adentro. Es el patrón de DBS entre 2014 y 2019 y de Capital One entre 2012 y 2020, y es literalmente la frase de Leyva de abril de 2025. Tiene una consecuencia incómoda para cualquier proveedor, incluidos nosotros, y es mejor decirla que esconderla.

El cuarto es que la evidencia de control se produce sola. Los bancos que aceleraron no quitaron controles, los automatizaron. En un entorno regulado por la Circular Única esto no es opcional, es la única vía legal de acortar el ciclo.

El quinto es que se mide en público y de forma continua. DBS revisa en tableros en vivo con un consejo de directivos desde 2018. Sin medición no hay conversación posible sobre si algo mejoró, y es la razón por la que la línea base es la pieza que no se puede posponer.

---

## 9. Dónde está Banamex frente a esos patrones

| Patrón | Situación en Banamex | Fecha del dato | Confianza |
|---|---|---|---|
| Equipos y fondeo permanentes | Planeación anual con aprobación por proyecto | Octubre de 2025, sin refrescar | Media, el dato tiene un año |
| Tarjeta de resultados compartida | DATO-REQUERIDO. No consta si existe responsabilidad conjunta de negocio y tecnología por plataforma | Sin dato | Sin evidencia |
| Capacidad propia | Declarada como prioridad; unas 7,000 personas en Sistemas y sobredependencia externa reconocida | Abril de 2025 | Media, declaración pública de hace dieciocho meses |
| Evidencia de control automatizada | DATO-REQUERIDO. El levantamiento sugiere control documental manual, falta confirmar | Octubre de 2025 | Baja |
| Medición continua y pública | No existe línea base de ninguna métrica del ciclo | Octubre de 2026 | Alta, confirmado en el diagnóstico |

La lectura es que Banamex tiene resuelto el primero de los habilitadores, que es el dinero, y declarada la intención sobre el tercero, que es la capacidad propia. Lo que no tiene es la medición, que es la pieza más barata de las cinco y la única que condiciona a todas las demás. También es el único renglón de la tabla cuyo dato es de este mes.

---

## 10. Implicaciones para nuestra propuesta

El dinero no es la objeción. El banco tiene 1,700 millones de dólares comprometidos desde enero de 2025, reconfirmados en octubre de 2026, y un dueño que en marzo de 2026 puso la tecnología como su mayor inversión del primer año. Cuando dijeron "muy cara" no estaban comparando contra un presupuesto, estaban comparando contra la prioridad que le asignaban.

El formato tiene que ser un ladrillo. Un interlocutor que declara preferencia por despliegues cortos y desconfianza de los proyectos de varios años no va a comprar un programa de tres fases con trece entregables.

El tiempo de salida se gana quitando esperas, no acelerando el trabajo. Es el argumento central y está respaldado por DORA en 2024 y 2025, por METR en 2025 y por el número de Capital One sobre ambientes de desarrollo. Como el otro proveedor va a atacar la espera de aprobaciones, nos queda el resto del tiempo total, que probablemente sea la mayor parte.

Nosotros también somos un tercero, y hay que decirlo primero. La única forma honesta de entrar a un banco que declaró sobredependencia externa es proponerse con fecha de salida y con transferencia de capacidad medible como entregable, no como promesa.

La línea base caduca. Cuando entre en operación el proceso nuevo del otro proveedor, la fotografía del antes deja de ser levantable para siempre, y con ella la posibilidad de demostrar que algo mejoró. Es el único trabajo del programa que no se puede hacer después, cuesta poco, no compite con nadie y además es lo que el banco va a necesitar cuando tenga que sostener compromisos frente a analistas a partir del primer trimestre de 2027.

Y una advertencia sobre nosotros mismos. Nuestra lectura del interlocutor descansa en una entrevista de abril de 2025. Si vamos a reprocharle a la propuesta anterior haber presentado un mapa de un año de antigüedad, no podemos construir la nueva sobre declaraciones de dieciocho meses sin verificarlas. Confirmar la agenda vigente de Leyva es tarea previa a la sesión, no durante.

---

## 11. Frescura de la evidencia

| Bloque | Fecha del dato más reciente | Antigüedad al 28 de octubre de 2026 | Qué hacer |
|---|---|---|---|
| Operación de venta y calendario de la oferta pública | 22 de octubre de 2026 | Una semana | Usar con confianza |
| Finanzas y posición de mercado de Banamex | Julio de 2026, publicado en octubre | Tres meses | Usar con confianza |
| Declaraciones de Francisco Leyva | 24 de abril de 2025 | Dieciocho meses | Verificar antes de citar en la sesión |
| Cifras operativas del banco: clientes, sucursales, plantilla | Cuarto trimestre de 2024 | Dos años | Pedirlas actualizadas al banco |
| Plantilla de Tecnología y Operaciones: 18,000 y 7,000 | Abril de 2025, sin corte declarado | Dieciocho meses | Tratar como aproximado y confirmar |
| Competencia digital en México | Agosto y segundo trimestre de 2026 | Dos a cinco meses | Usar con confianza |
| Regulación de contratación con terceros | Septiembre de 2022 | Cuatro años | Verificar texto vigente de la Circular Única |
| Caso BBVA | 28 de mayo de 2026 | Cinco meses | Usar con confianza |
| Caso Santander | Junio de 2025 | Dieciséis meses | Usar, citando también la crítica independiente |
| Caso Banorte | Julio de 2026 | Tres meses | Usar con confianza |
| Caso DBS | Estructura de 2018, recorridos a 2024 | Dos a ocho años | Usar por el patrón, no por las cifras |
| Caso Capital One | 2020 | Seis años | Usar solo el dato de ambientes de desarrollo |
| Caso ING | 2015, crítica de 2021 | Cinco a once años | Usar solo como advertencia sobre el fondeo |
| Evidencia sobre inteligencia artificial | Informe DORA de 2025 | Menos de un año | Usar con confianza, declarando los límites |
| Mapa del ciclo de entrega de Banamex | Octubre de 2025 | Un año | No volver a presentarlo sin refrescar |

---

## 12. Vacíos que hay que cerrar antes de la conversación

Si existe una declaración pública o interna de Leyva posterior a abril de 2025 sobre su agenda tecnológica. Es el vacío más importante, porque toda nuestra lectura del interlocutor cuelga de ahí.

Cuándo termina el trabajo del otro proveedor y si tendremos acceso a sus entregables. Sin eso no se puede fijar la fecha de nuestra entrada ni afirmar que no competimos.

La fecha de vencimiento del acuerdo de servicios con Citi por dominio. Es el reloj real del programa y ninguna fuente pública lo da.

Cuánto de los 1,700 millones de dólares se ha ejercido desde enero de 2025 y qué se ha entregado. Van dos años de seis.

La composición actual de las personas de Sistemas entre plantilla propia y terceros, con corte de 2026 y no de 2025. Sin ese número no se puede dibujar la pirámide de antes y después.

Si existe hoy responsabilidad conjunta de negocio y tecnología por plataforma o si cada lado tiene su propia lista de prioridades. Determina si la reducción de gestores es una reorganización o solo un recorte.

Quién absorbe internamente el mensaje de reducir gestores. Es la pregunta política del asunto y define si la oficina de proyectos es aliada o parte afectada.

---

## Fuentes

Sobre Banamex y la operación con Citi: [Citi, comunicado sobre la venta del 24%](https://www.citigroup.com/global/news/press-release/2026/citi-announces-agreements-with-investors-for-commitments-to-purchase-an-aggregate-24-equity-stake-in-banamex), [Citi, comunicado sobre el cierre del 22.6%](https://www.citigroup.com/global/news/press-release/2026/citi-announces-completion-22-6-percent-sale-equity-stake-banamex), [Citigroup, reporte 10-Q al 30 de junio de 2026](https://www.sec.gov/Archives/edgar/data/0000831001/000083100126000045/c-20260630.htm), [Citigroup, reporte 10-Q al 31 de marzo de 2026](https://www.sec.gov/Archives/edgar/data/0000831001/000083100126000019/c-20260331.htm), [Bloomberg Línea sobre la desconsolidación](https://www.bloomberglinea.com/latinoamerica/mexico/citi-desconsolidara-banamex-a-inicios-de-2027-para-avanzar-hacia-la-opi/), [Bloomberg Línea sobre la oferta pública](https://www.bloomberglinea.com/latinoamerica/mexico/citi-planea-opi-de-banamex-por-mas-de-us3000-millones-a-inicios-de-2027/), [La Jornada, 13 de octubre de 2026, sobre la separación total](https://www.jornada.com.mx/noticia/2026/10/13/economia/separacion-total-de-citi-y-banamex-se-dara-a-inicios-de-2027), [El Financiero, 22 de octubre de 2026, sobre la reunión con analistas](https://elfinanciero.com.mx/mundo/2026/10/22/citigroup-reune-a-analistas-en-mexico-para-preparar-la-salida-a-bolsa-de-banamex), [Rio Times sobre el avance de la oferta pública](https://www.riotimesonline.com/banamex-ipo-citi-analysts-49-percent-2026/).

Sobre el plan de Chico Pardo y la inversión tecnológica: [Expansión, 21 de octubre de 2026](https://expansion.mx/economia/2026/10/21/fernando-chico-pardo-quiere-llevar-banamex-al-nivel-de-bbva), [El Financiero, 4 de marzo de 2026](https://www.elfinanciero.com.mx/bloomberg-businessweek/2026/03/04/fernando-chico-pardo-y-su-plan-para-despertar-a-banamex/), [El Congresista sobre los 1,700 millones de dólares](https://elcongresista.mx/finanzas/banamex-inversion-1700-millones-modernizacion), [IT Masters Mag sobre la prioridad de inversión](https://www.itmastersmag.com/transformacion-digital/banamex-mantendra-como-prioridad-la-inversion-en-tecnologia-chico-pardo/), [Moody's Local México, informe público de abril de 2026](https://moodyslocal.com.mx/wp-content/uploads/2026/04/1.2.1_MLMX-Informe-PUBLICO-Banamex-2026-1.pdf).

Sobre Francisco Leyva: [entrevista en IT Masters Mag, 24 de abril de 2025](https://www.itmastersmag.com/transformacion-digital/francisco-leyva-rubio-director-de-operaciones-y-tecnologia-de-banamexlas-transformaciones-que-merecen-la-pena-se-construyen-ladrillo-a-ladrillo/), [Expansión, enero de 2025, sobre los responsables de relanzar el banco](https://expansion.mx/economia/2025/01/09/nuevo-banamex-responsables-relanzar-banco), [Funds Society sobre su incorporación](https://www.fundssociety.com/es/noticias/nombramientos/citibanamex-incorpora-a-francisco-leyva-como-director-corporativo-de-operaciones-y-tecnologia-para-banamex/), [The Digital Banker sobre su llegada desde BBVA](https://thedigitalbanker.com/citi-nabs-bbva-tech-head-to-lead-revamp-ahead-of-banamex-ipo/).

Sobre competencia y banca digital en México: [Nu, comunicado de autorización de julio de 2026](https://nu.com/es/sala-de-prensa/compania/nu-mexico-recibe-autorizacion-para-iniciar-operaciones-como-banco), [El Financiero, 10 de julio de 2026](https://www.elfinanciero.com.mx/economia/2026/07/10/nu-recibe-autorizacion-para-operar-como-banco-en-mexico-que-mensaje-mando-a-sus-usuarios/), [Rio Times sobre la licencia completa](https://www.riotimesonline.com/nu-mexico-full-bank-launch-2026/), [Nu, cronología de su licencia bancaria](https://blog.nu.com.mx/nubank/como-nu-se-convirtio-en-banco/), [Rankings LatAm, encuesta de aplicaciones del segundo trimestre de 2026](https://rankingslatam.com/blogs/industry-news/mexico-banking-and-fintech-apps-survey-2026-user-satisfaction-remains-strong-but-only-a-handful-of-apps-reach-best-in-class-performance), [El Universal sobre el despegue de la banca digital](https://www.eluniversal.com.mx/cartera/anticipan-despegue-de-la-banca-digital-en-mexico-este-ano/), [El Financiero, 18 de marzo de 2026, sobre la nueva era de la banca digital](https://www.elfinanciero.com.mx/economia/2026/03/18/arranca-nueva-era-de-la-banca-digital-y-desafia-lo-tradicional/), [BBVA México, inversión a 2030](https://www.fintechexpert.mx/p/bbva-mexico-invertira-mas-de-100), [Banorte y Google Cloud, septiembre de 2025](https://www.banorte.com/GFB/Boletines-de-prensa/Banorte-y-Google-Cloud.html), [Banorte, resultados de julio de 2026](https://www.imagenradio.com.mx/finanzas/utilidades-banorte-crecen-6-impulsadas-por-tecnologia-e-innovacion).

Sobre regulación: [CNBV, guía para la autorización de contratación con terceros, 12 de septiembre de 2022](https://www.gob.mx/cms/uploads/attachment/file/762170/2022_09_12_Nueva_gu_a_contrataci_n_terceros_bancos__DGSROT___DGSSI___DGASF__VF.pdf), [CNBV, guía de prestadores de servicios, agosto de 2017](https://www.cnbv.gob.mx/SECTORES-SUPERVISADOS/BANCA-MULTIPLE/Documents/Guia_Presetadores_de_Servicios_Bancos_agosto_2017.pdf), [IMCO, cómputo en la nube para el sector financiero, 2022](https://imco.org.mx/wp-content/uploads/2022/09/Computo-en-la-nube-para-el-sector-financiero_Documento.pdf), [guía de AWS sobre normas aplicables a instituciones de crédito en México](https://d1.awsstatic.com/fs-compliance-center/pdf-summaries/aws-user-guide-to-regulations-to-credit-institutions-in-mexico-es.pdf), [Facephi sobre biometría facial y open banking](https://facephi.com/observatory/en/open-banking-facial-biometrics-cnbv-mexico/), [Facephi sobre la Ley Fintech en 2026](https://facephi.com/observatory/en/fintech-law-in-mexico-2026-competition-sandbox-and-new-financial-models/), [Creditolab sobre los cambios regulatorios de junio de 2026](https://creditolab.com/mx/noticias/cnbv-nuevas-regulaciones-fintech-mexico-2026).

Sobre casos de otros bancos: [DBS, informe anual 2018, declaración del director de tecnología](https://www.dbs.com/annualreports/2018/cio-statement.html), [DBS Tech Blog sobre el cambio de modelo operativo](https://medium.com/dbs-tech-blog/transformational-leadership-the-key-to-ensuring-a-smooth-transition-while-changing-operation-ac52fb50ae0a), [Computer Weekly sobre el viaje digital de DBS](https://www.computerweekly.com/feature/Inside-DBS-Banks-digital-journey), [Computer Weekly sobre la industrialización de la inteligencia artificial en DBS](https://www.computerweekly.com/news/366569993/How-DBS-is-industrialising-AI-across-its-business), [INSEAD sobre DBS](https://knowledge.insead.edu/economics-finance/how-dbs-became-worlds-best-bank), [IMD, caso DBS](https://www.imd.org/research-knowledge/customer-centricity/case-studies/dbs-a-damn-bloody-slow-to-best-digital-bank-in-the-world/), [McKinsey sobre la transformación ágil de ING](https://www.mckinsey.com/industries/financial-services/our-insights/ings-agile-transformation), [ING sobre talento de ingeniería](https://www.ing.com/Newsroom/News/Nothing-beats-engineering-talent-INGs-agile-transformation.htm), [Forbes, 2021, sobre los riesgos de las transformaciones ágiles de gran corte](https://www.forbes.com/sites/stevedenning/2021/10/29/why-big-bang-agile-transformations-are-a-bad-idea/), [AWS, caso Capital One](https://aws.amazon.com/solutions/case-studies/capital-one-all-in-on-aws/), [Santander, despliegue de Gravity en España, junio de 2025](https://www.santander.com/en/press-room/press-releases/2025/06/santander-completes-the-digitalization-of-its-technology-infrastructure-in-spain-with-the-deployment-of-gravity), [Santander, siete preguntas sobre Gravity](https://www.santander.com/en/stories/7-questions-on-how-gravity-is-transforming-santander), [Santander y Google Cloud, octubre de 2022](https://www.santander.com/en/press-room/press-releases/2022/10/google-and-santander-to-help-other-companies-simplify-their-transition-from-legacy-tech-to-the-cloud), [Hyperframe Research, junio de 2025, análisis crítico de la migración de Santander](https://hyperframeresearch.com/2025/06/25/does-santanders-cloud-migration-actually-deliver/), [Microsoft Source, mayo de 2026, sobre BBVA e inteligencia artificial agéntica](https://news.microsoft.com/source/emea/features/bbva-acelera-el-desarrollo-de-productos-con-la-ia-agentica-de-microsoft/?lang=es).

Sobre evidencia de inteligencia artificial en el ciclo de entrega: [informe DORA 2025 sobre desarrollo asistido por inteligencia artificial](https://services.google.com/fh/files/misc/2025_state_of_ai_assisted_software_development.pdf), [DORA sobre el equilibrio de tensiones](https://dora.dev/insights/balancing-ai-tensions/), [IT Revolution sobre el efecto espejo](https://itrevolution.com/articles/ais-mirror-effect-how-the-2025-dora-report-reveals-your-organizations-true-capabilities/), [RedMonk sobre DORA 2025](https://redmonk.com/rstephens/2025/12/18/dora2025/), [Business Insider sobre el estudio METR](https://www.businessinsider.nl/ai-coding-tools-could-make-experienced-software-engineers-less-productive-a-new-study-suggests/).

Sobre el modelo de producto y fondeo: [Martin Fowler, productos sobre proyectos](https://martinfowler.com/articles/products-over-projects.html), [IT Revolution sobre el modelo de fondeo](https://itrevolution.com/articles/funding-model-the-seven-domains-of-transformation/), [McKinsey sobre el cambio a producto y plataforma](https://www.mckinsey.com/capabilities/tech-and-ai/our-insights/the-big-product-and-platform-shift-five-actions-to-get-the-transformation-right).
