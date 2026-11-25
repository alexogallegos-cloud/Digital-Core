<!--
  Documento: benchmark extendido de BBVA, Santander y Banorte en entrega de software
  Proyecto:  SDLC Reinvent (03 - SPE/HVM/MM/Banamex/projects/sdlc-reinvent/)
  Audiencia: equipo interno de Accenture. No es material de cliente.
  Versión:   v1.0 · 2026-10-28 · Cada dato con su fecha.
-->

# BBVA, Santander y Banorte: qué han hecho con su ciclo de entrega

Los tres competidores con los que Banamex se compara, mirados por la única dimensión que nos interesa: cómo construyen y liberan software, con qué gente, con cuánto dinero y en cuánto tiempo.

Advertencia transversal: prácticamente todas las cifras de resultado son autorreportadas por el banco o por su proveedor. Las de plantilla provienen de prensa y portales de empleo. Ninguna está auditada de forma independiente.

---

## El cuadro que resume la conversación

| | BBVA | Santander | Banorte | Banamex |
|---|---|---|---|---|
| Inversión declarada | Más de 100,000 millones de pesos, 2025 a 2030 (BBVA México) | Alrededor de 2,000 millones de dólares, 2026 a 2028 (Santander México) | No publica cifra consolidada | 1,700 millones de dólares, 2025 a 2029 |
| Core en nube | Parcial. En 2020 el 28% de transacciones fuera del legado | **México migrado en noviembre de 2025**, tercero después de Chile y España | Mainframe modernizado en Querétaro, 2026. No migrado | Separación de Citi en curso, horizonte 2029 |
| Plataforma de desarrollo | Única y global. Más de 100,000 repositorios, mayo de 2026 | Única y común para todos los mercados tras la fusión de filiales, 2026 | Capa de servicios con interfaces sobre core Altamira, desde 2021 | DATO-REQUERIDO. Dos vehículos internos con supuestos de herramientas en conflicto |
| Organización de software | Área global de Software, más de 16,000 personas, desde enero de 2022 | Filial única tras fusionar SGTO y Gravity, con recorte en curso desde septiembre de 2026 | 90% de desarrollos ágiles, cerca de 1,300 desarrolladores equivalentes, 2021 | Unas 7,000 personas en Sistemas, 2025 |
| Inteligencia artificial en el ciclo | 15,000 licencias de asistente de código, 70% de desarrolladores, mayo de 2026 | No publica cifras de asistentes de código | Plataforma propia de modelos. Trabajo de meses a semanas, 2026 | Sin despliegue conocido |

**La comparación que más va a doler y la que más nos sirve.** Santander México planea invertir alrededor de 2,000 millones de dólares en tres años. Banamex, 1,700 millones en seis. Por año, Santander México gasta más del doble. Y lo más importante: Santander México **ya terminó** la migración de su core a nube en noviembre de 2025, mientras Banamex sigue separándose de la plataforma de Citi con horizonte 2029. No es una diferencia de ambición, es una diferencia de cuatro años de calendario.

---

## BBVA

Es el caso que más peso tiene en la sala, porque es la casa de la que viene el interlocutor y porque él construyó buena parte de lo que aquí se describe. Ver [perfil-francisco-leyva.md](perfil-francisco-leyva.md).

**La organización, enero de 2022.** BBVA creó un área de Software dentro de Ingeniería que agrupa a más de 16,000 personas entre internas y externas dedicadas a diseñar, desarrollar o mantener software. Reportan a ella los equipos de diseño y desarrollo de cada país y los equipos globales. Su objetivo declarado es reutilizar componentes para entregar más rápido. El proyecto de globalización movilizó a más de 1,300 desarrolladores. El propio Leyva fijó la meta en términos de compresión: ocho años en condiciones normales, cuatro con los nuevos medios.

**La plataforma.** GloMo, la plataforma móvil global, nació en México como país ancla y para enero de 2022 tenía más de 300 interfaces globales reutilizadas por las aplicaciones de cada país. El paso siguiente declarado era compartir servicios entre países sobre un modelo de datos común. En la plataforma de datos del grupo, el acceso a subconjuntos pasó de semanas a minutos.

**Resultado de ciclo, el único concreto.** En la aplicación móvil global, los plazos del ciclo de desarrollo de producto se redujeron a la mitad al trabajar con equipos ágiles.

**Talento, 2024 a 2026.** El grupo sumó unas 10,100 personas de tecnología y datos en tres años, con meta cercana a 20,000 profesionales tecnológicos. Los perfiles más buscados siguen siendo desarrolladores de software e ingenieros de datos, seguidos de seguridad, infraestructura y arquitectura. México es la mayor plantilla del grupo, con 47,745 empleados frente a 29,479 en España. BBVA Technology América, con sede en México, pasa a ser centro global de servicios con más de 800 colaboradores.

**Inteligencia artificial, 28 de mayo de 2026.** Unas 15,000 licencias de asistente de código usadas por el 70% de sus desarrolladores, con más de 100,000 repositorios migrados a una plataforma global única. Más de 105,000 empleados pasaron por su programa interno de inteligencia artificial generativa durante 2025. El banco describe que sus ingenieros pasaron de ejecutar tareas manuales a coordinar flujos completos de trabajo.

**Lo que hay que decir en la sala.** El resultado de BBVA no viene del asistente de código, viene de la consolidación que lo hizo posible: una plataforma, un modelo de datos, componentes reutilizables. Esa consolidación tomó años y la dirigió la persona que tenemos enfrente. Banamex no la tiene, y por eso saltarse directamente a las licencias no produciría el mismo efecto.

---

## Santander

Es el caso más vigente en materia de legado y el más incómodo en materia de calendario.

**El core, noviembre de 2025.** Santander migró el núcleo de su actividad bancaria en México a Gravity, su plataforma propia en nube, después de Chile y España. En la presentación de resultados del tercer trimestre de 2025, el consejero delegado del grupo fijó como meta tener migrados los núcleos de las grandes geografías hacia finales de 2026, con Brasil como siguiente. España había quedado completa en junio de 2025. Gravity permite correr cargas en el mainframe y en nube al mismo tiempo, lo que habilita pruebas reales sin interrumpir el negocio. El grupo reporta una reducción de 70% en consumo energético, y todavía no ha detallado ahorros de costo.

**Lo que afirma sobre tiempo de salida.** En 2025 dice que el lanzamiento de nuevas funcionalidades pasó de semanas a horas. Comunicados anteriores decían de días a horas, lo que indica que la cifra se mueve según el año. Un análisis independiente de junio de 2025 cuestiona que falte validación concreta y que la confiabilidad bajo estrés no esté demostrada. Conviene citar las dos cosas juntas.

**La reorganización, 2026.** En julio de 2026 la filial de tecnología y operaciones absorbió a otra filial de back office mayorista, lo que generó funciones duplicadas. El 17 de septiembre de 2026 el banco comunicó a los sindicatos el inicio de conversaciones para un expediente de regulación de empleo en sus filiales tecnológicas en España, el primero desde la pandemia. El motivo declarado es la duplicidad de puestos tras la fusión y la finalización de algunos proyectos. Las cifras de plantilla varían según la fuente, entre unas 10,750 y unas 13,000 personas en las dos sociedades a nivel mundial, con unas 6,000 en España.

**Inversión en México.** El director general de Santander México declaró que el banco prevé invertir una cantidad similar o ligeramente menor a 2,000 millones de dólares entre 2026 y 2028, destinada principalmente a plataformas tecnológicas y digitalización. Dijo que el plan sigue en pie y que no lo van a retrasar.

**Lo que hay que decir en la sala, y hay que decirlo con cuidado.** Santander demuestra dos cosas opuestas y las dos sirven. Demuestra que se puede sacar el core de un banco mexicano a nube sin gran corte, y que ya está hecho. Y demuestra que consolidar la plataforma tiene una factura humana: terminada la unificación, vienen las duplicidades y el recorte. Si la conversación con Banamex va hacia una pirámide más pequeña, ese es el precedente real y es mejor nombrarlo nosotros que dejar que lo nombre alguien más.

---

## Banorte

Es el referente local que el consejo entiende sin traducción, y el único de los tres cuyo punto de partida se parece al de Banamex.

**El modelo de desarrollo, abril de 2021.** Su responsable de tecnología declaró que cerca del 90% de los desarrollos siguen método ágil, con casi tres millones de horas persona de desarrollo al año, que él equiparó a unas 1,300 personas programando todos los días. Para nuevos desarrollos adoptaron microservicios. Construyeron una capa de gestión de servicios que conecta con terceros por interfaces, con autenticación y seguridad, y sacaron las reglas de negocio del core hacia esa capa. El core, Altamira, corre en mainframe en el centro de datos y funciona sobre todo como libro de registro. Operan en tres niveles: centro de datos, nube privada para algunos servicios y nube pública para adquirencia.

**La infraestructura, 2026.** Trasladaron el centro de datos principal de Ciudad de México a Querétaro y modernizaron el mainframe con un socio de almacenamiento. El nuevo entorno, de dos mainframes y tres cabinas interconectadas, recortó alrededor de 50% los tiempos de respuesta de las transacciones digitales.

**Nube e inteligencia artificial.** Trabaja con Google Cloud desde 2021, con acuerdo renovado por tres años en septiembre de 2025 para inteligencia artificial, analítica y ciberseguridad, incluyendo un lago de datos. Usa una plataforma abierta de contenedores como base de sus modelos y asistentes internos, y reporta que actividades que antes requerían meses hoy se resuelven en semanas. Es el único banco mexicano en el índice Evident de inteligencia artificial para América Latina en 2026.

**Resultados.** Las ventas por canales digitales pasaron de 7% en 2019 a 29% en 2026. La utilidad neta creció 6% al segundo trimestre de 2026.

**Lo que hay que decir en la sala.** Dos cosas. La primera es la vara de velocidad realista: siete años para pasar de 7% a 29% de ventas digitales. Eso es lo que se mueve un banco mexicano grande sosteniendo una sola dirección, y es el contraargumento honesto a cualquier promesa de transformación en nueve semanas. La segunda es la comparación de densidad: Banorte produce tres millones de horas de desarrollo al año con el equivalente a unas 1,300 personas programando a diario. Banamex tiene alrededor de 7,000 personas en Sistemas. No son categorías idénticas y no hay que presentarlas como si lo fueran, pero la pregunta de por qué la diferencia es de ese orden es exactamente la pregunta que un director de operaciones quiere poder contestar.

---

## Los tres patrones comunes

**Los tres consolidaron antes de acelerar.** BBVA una plataforma global y un modelo de datos común. Santander una sola plataforma tecnológica para todos los mercados. Banorte una capa de servicios que sacó las reglas de negocio del core. En los tres casos la velocidad llegó después de la consolidación, nunca antes.

**Los tres sacaron trabajo del core sin apagarlo.** Ninguno hizo un gran corte. BBVA convivió años con 72% del tráfico en legado. Santander corre mainframe y nube en paralelo por diseño. Banorte dejó el core como libro de registro y movió la lógica afuera. Es la confirmación empírica de la postura que Leyva ya declaró para Banamex.

**Los tres pagaron la consolidación con reorganización de plantilla.** Es el renglón que nadie pone en las láminas. Santander lo está haciendo explícito en 2026 con un expediente de regulación de empleo tras unificar sus filiales. BBVA lo hizo creciendo y recomponiendo perfiles, no recortando, con una meta de 20,000 profesionales tecnológicos y una apuesta declarada por desarrolladores e ingenieros de datos sobre otros perfiles. Si Banamex quiere una plantilla más pequeña y más técnica, tiene los dos caminos a la vista y conviene que elija cuál antes de que lo elija el calendario.

---

## Vacíos

El reparto entre plantilla propia y terceros en cualquiera de los tres. Ninguno lo publica, y es justo la cifra que haría comparable la situación de Banamex.

El dato de Banorte es de abril de 2021, tiene cinco años, y su responsable de tecnología de entonces puede ya no tener ese cargo. Conviene buscar una declaración más reciente antes de usar la cifra de tres millones de horas.

Si BBVA México publica resultados locales de las 15,000 licencias de asistente de código, más allá del anuncio del grupo.

El número final de afectados por el expediente de Santander, que al 17 de septiembre de 2026 no estaba concretado.

---

## Fuentes

**BBVA:** [CIO España, 14 de enero de 2022](https://www.cio.com/article/2071629/bbva-crea-un-area-de-desarrollo-de-software-con-mas-de-16-000-empleados.html) · [IT User sobre la división global de software](https://www.ituser.es/estrategias-digitales/2022/01/bbva-crea-una-division-global-de-software-con-mas-de-16000-desarrolladores) · [BBVA, área de Software para soluciones globales](https://www.bbva.com/en/innovation/bbva-creates-a-software-development-area-to-drive-global-scalable-solutions/) · [BBVA, plataforma móvil global](https://www.bbva.com/en/global-mobile-banking-platform-quickly-reach-customers/) · [AWS, plataforma global de datos de BBVA](https://aws.amazon.com/blogs/industries/part-1-bbva-building-a-multi-region-multi-country-global-data-and-ml-platform-at-scale/) · [Microsoft Source, mayo de 2026](https://news.microsoft.com/source/emea/features/bbva-acelera-el-desarrollo-de-productos-con-la-ia-agentica-de-microsoft/?lang=es) · [CIO España sobre los 20,000 empleados tecnológicos](https://www.cio.com/article/3811136/bbva-preve-alcanzar-cerca-de-20-000-empleados-tech-en-2025.html) · [BBVA Technology América, centro global en México](https://www.fintechexpert.mx/p/bbva-technology-america-hub-global-mexico) · [BBVA México, inversión a 2030](https://www.fintechexpert.mx/p/bbva-mexico-invertira-mas-de-100)

**Santander:** [Santander, Gravity en España, junio de 2025](https://www.santander.com/en/press-room/press-releases/2025/06/santander-completes-the-digitalization-of-its-technology-infrastructure-in-spain-with-the-deployment-of-gravity) · [Santander, siete preguntas sobre Gravity](https://www.santander.com/en/stories/7-questions-on-how-gravity-is-transforming-santander) · [migración del core de México a Gravity, noviembre de 2025](https://valenciaplaza.com/valenciaplaza/bolsas/santander-prosigue-la-implantacion-de-su-plataforma-gravity-con-la-migracion-del-core-bancario-de-mexico) · [Capital Madrid sobre México en Gravity](https://www.capitalmadrid.com/2025/11/10/70586/santander-incorpora-mexico-a-su-plataforma-gravity.html) · [El Economista, expediente en filiales tecnológicas, septiembre de 2026](https://www.eleconomista.es/banca-finanzas/noticias/14014788/09/26/santander-realizara-un-ere-en-sus-filiales-tecnologicas-en-espana.html) · [La República sobre la reorganización de filiales](https://www.larepublica.co/globoeconomia/santander-reorganiza-sus-filiales-tecnologicas-para-ganar-eficiencia-4428394) · [El CEO, inversión de 2,000 millones de dólares en México](https://elceo.com/negocios/santander-alista-alrededor-de-2000-mdd-de-inversion-hacia-2028-en-mexico/) · [Hyperframe Research, análisis crítico, junio de 2025](https://hyperframeresearch.com/2025/06/25/does-santanders-cloud-migration-actually-deliver/)

**Banorte:** [IT Masters Mag, entrevista del 29 de abril de 2021](https://www.itmastersmag.com/noticias-analisis/francisco-martha-cio-de-banorte-vivimos-12-meses-perro-en-avance-digital/) · [Banorte y Google Cloud, septiembre de 2025](https://www.banorte.com/GFB/Boletines-de-prensa/Banorte-y-Google-Cloud.html) · [Data Center Dynamics sobre el centro de datos de Querétaro](https://www.datacenterdynamics.com/es/noticias/banorte-refuerza-su-banca-digital-con-nuevo-centro-de-datos-en-quer%C3%A9taro-y-almacenamiento-de-hitachi/) · [Techtegia sobre la reducción de 50% en tiempos de respuesta](https://techtegia.com/2026/03/banorte-reduce-al-50-sus-tiempos-de-respuesta-digital-el-exito-de-su-modernizacion-con-hitachi-vantara/) · [Infochannel sobre inteligencia artificial y modernización](https://infochannel.info/imss-y-banorte-destacan-por-sus-proyectos-de-ia-y-modernizacion-tecnologica/) · [Banorte, utilidades de julio de 2026](https://www.imagenradio.com.mx/finanzas/utilidades-banorte-crecen-6-impulsadas-por-tecnologia-e-innovacion)
