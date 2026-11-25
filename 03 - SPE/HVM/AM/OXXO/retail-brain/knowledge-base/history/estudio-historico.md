# Estudio histórico de OXXO

> Regla B26 del Enterprise Brain. Primer artefacto de DISCOVER: antes de leer código, antes de mapear sistemas, antes de la primera tabla.
> Brain: `retail-brain` (OXXO) — Versión 0.1 — 2026-11-20 — Estado: abierto, se llena con cada conversación.

---

## Para qué existe este documento

La historia no es contexto decorativo, es la explicación del porqué del código. Un procedimiento escrito de forma extraña tiene una razón histórica. Una regla que parece arbitraria responde a una regulación de hace veinte años. Un sistema con cuatro maneras de calcular lo mismo fue absorbiendo tres adquisiciones.

Sin este estudio el brain puede describir con precisión qué hace el sistema hoy, y no puede responder la pregunta que más importa en una modernización: por qué lo hace así.

Esta primera versión se construyó con fuentes públicas, porque todavía no hay acceso a documentación interna del cliente. Eso fija el techo de calidad de cada afirmación: lo que viene de un comunicado o informe de la propia empresa entra gold, lo que viene de prensa entra silver, y lo que es inferencia de quien escribe entra bronze y lleva marcada la pregunta que la resolvería. Las dos dimensiones que más importan para una modernización, la cuarta y la quinta, no se pueden cerrar sin el cliente.

## Cómo se conecta al brain

| Enlace | Dónde | Qué significa |
|--------|-------|---------------|
| Referencia | `system_info.source_of_truth` | El brain declara este estudio como una de sus fuentes |
| Huecos | `knowledge_gaps` | Cada pregunta sin responder, dirigida a quien la tiene |
| Tiempo | `knowledge_lineage.valid_from` | Cada hecho lleva la fecha en que fue verdad, no la de captura (Regla B40) |
| Eje rector | `business_milestones` y `strategic_drivers` | Los hitos que siguen vivos se vuelven filas, no solo párrafos |

Los hechos de nivel empresa de este estudio no atan a un proceso de negocio y no debe inventárseles uno: entran anclados a `company_profile`, que es la excepción cerrada que reconoce ADR-EB-017 a la Regla B22.

---

## Dimensión 1 — Fundación y modelo de negocio original

OXXO abrió su primera tienda en 1978 en Monterrey, Nuevo León, como canal de distribución de los productos de Cervecería Cuauhtémoc. El surtido inicial era corto y de alta rotación: cerveza, botanas y cigarros. El nombre y el logotipo en forma de carrito de compra buscaban recordarse fácil, y la propia empresa conserva como anécdota fundacional que la primera venta fue un frasco de café.

Lo que esto le explica al brain es el núcleo que nadie toca. El modelo no nació como tienda de abarrotes sino como punto de venta de un fabricante de bebidas, y esa genealogía sigue visible en la relación comercial con el proveedor de bebidas, en la rotación como métrica rectora y en la tienda física como unidad atómica de la operación. Toda capacidad de surtido, reabasto y punto de venta que hoy exista descansa sobre ese diseño original.

| Hecho | Fecha | Nivel | Fuente |
|-------|-------|-------|--------|
| Apertura de la primera tienda en Monterrey, Nuevo León | 1978 | gold | [OXXO 45 Aniversario, FEMSA](https://www.femsa.com/wp-content/uploads/2023/10/OXXO-45-Aniversario.pdf) |
| Origen como canal de distribución de Cervecería Cuauhtémoc | 1978 | silver | [El CEO](https://elceo.com/negocios/asi-fue-como-se-creo-oxxo-el-minisuper-mas-popular-de-mexico) |
| Surtido fundacional de cerveza, botanas y cigarros | 1978 | silver | [El CEO](https://elceo.com/mercados/oxxo-asi-fue-como-se-inicio-operaciones-la-primera-tienda-en-mexico/) |
| Listado de FEMSA en la Bolsa Mexicana de Valores | 1978-09-19 | silver | [Wikipedia, FEMSA](https://en.wikipedia.org/wiki/FEMSA) |
| Primera franquicia de Coca-Cola del grupo | 1979 | silver | [Expansión](https://expansion.mx/empresas/2026/04/10/como-nacio-femsa-del-hielo-y-cerveza-al-imperio-oxxo) |

Dos datos quedan en disputa y no se resuelven promediando. Una fuente ubica la fundación en Guadalupe, Nuevo León, y no en Monterrey, y una sola fuente da el 1 de mayo de 1978 como fecha exacta sin que ninguna otra la confirme. Ambos van a huecos.

---

## Dimensión 2 — Hitos de crecimiento y expansión

El crecimiento de OXXO tiene tres motores que llegaron en momentos distintos y dejaron, cada uno, su propia capa tecnológica.

El primero es la densidad de tiendas en México, que es el motor original y sigue activo aunque desacelerado: la cadena cerró septiembre de 2026 con 24,759 tiendas en el país frente a 24,057 un año antes, y en 2026 anunció un freno en el ritmo de aperturas. El segundo es la expansión geográfica, hacia Sudamérica y, desde la compra de Valora en 2022, hacia Europa. El tercero es el brazo financiero, que empezó en 2014 con la tarjeta de débito Saldazo en alianza con Banamex y maduró en la cuenta Spin by OXXO.

A esos tres motores se suma un movimiento de signo contrario que importa tanto como ellos. En febrero de 2023 FEMSA anunció la estrategia FEMSA Forward y concentró al grupo en proximidad, el embotellador de Coca-Cola y el negocio digital. Lo que siguió fue una cadena de desinversiones: Heineken en junio de 2023, Jetro Restaurant Depot, Envoy Solutions, las refrigeradoras de Imbera y Torrey, el negocio de plásticos y, en julio de 2025, buena parte de la logística de Solistica, vendida a Grupo Traxión.

Lo que esto le explica al brain son dos cosas distintas. La heterogeneidad tecnológica viene de las adquisiciones, porque sistemas que nunca fueron diseñados juntos terminan teniendo que dialogar, y el brazo financiero creció con una lógica regulatoria propia que no es la del retail. Pero las desinversiones plantean algo menos obvio y más delicado para una modernización: logística y refrigeración eran casas del mismo grupo y hoy pertenecen a terceros, así que integraciones que nacieron internas serían ahora interfaces con un proveedor externo, con otro régimen de contrato, de dato y de disponibilidad. Esa es una hipótesis que hay que verificar con el cliente, no un hecho verificado.

| Hecho | Fecha | Nivel | Fuente |
|-------|-------|-------|--------|
| Primera tarjeta de débito Saldazo, en alianza con Banamex | 2014 | silver | [Rest of World](https://restofworld.org/2022/oxxo-spin-mexico-banco/) |
| OXXO como principal corresponsal bancario del país, con 43% de 43,397 puntos | 2019 | silver | [Bloomberg Línea](https://www.bloomberglinea.com/2022/10/11/banorte-y-oxxo-ganan-terreno-fintech-mientras-la-banca-de-consumo-se-reconfigura-en-mexico/) |
| Adquisición de Valora, convenience europeo | 2022 | silver | [SEC, formulario 6-K de FEMSA](https://www.sec.gov/Archives/edgar/data/1061736/000110465923068568/tm2317966d1_ex99-1.htm) |
| Anuncio de la estrategia FEMSA Forward | 2023-02-15 | gold | [FEMSA Forward](https://www.femsa.com/en/?p=20805) |
| Venta de la participación en Heineken | 2023-06-20 | silver | [El CEO](https://elceo.com/negocios/del-hielo-al-oxxo-femsa-se-despide-de-la-cerveza-con-millones-bajo-el-brazo/) |
| Venta de Envoy Solutions, conservando 37% | 2024 | silver | [Bloomberg Línea](https://www.bloomberglinea.com/latinoamerica/mexico/femsa-vende-participacion-en-envoy-solutions-como-parte-de-plan-de-desinversion/) |
| Venta de Imbera y Torrey por 8,000 millones de pesos | 2024 | silver | [Bloomberg Línea](https://www.bloomberglinea.com/latinoamerica/mexico/femsa-concreta-venta-de-su-negocio-de-refrigeracion-y-equipamiento-en-mxn8000-millones/) |
| Venta del negocio de plásticos a AMMI por 3,165 millones de pesos | 2025-01-03 | silver | [Expansión](https://expansion.mx/empresas/2025/01/07/por-que-femsa-esta-desinvirtiendo-en-negocios) |
| Venta de operaciones de Solistica a Grupo Traxión, sin la operación LTL de Brasil | 2025-07 | silver | [Expansión](https://expansion.mx/empresas/2025/07/01/femsa-completa-la-venta-de-algunas-operaciones-de-solistica-a-traxion) |
| Proximity Americas cierra el año con 25,587 tiendas | 2025-12-31 | silver | [Merca2.0](https://www.merca20.com/?p=12555407) |
| Freno anunciado en el ritmo de apertura de tiendas en México | 2026-05 | silver | [Expansión](https://expansion.mx/empresas/2026/05/04/oxxo-frena-apertura-tiendas-mexico-2026) |
| 24,759 tiendas en México, frente a 24,057 un año antes | 2026-09-30 | silver | [Merca2.0](https://www.merca20.com/?p=12614560) |

---

## Dimensión 3 — Eventos regulatorios

OXXO vive bajo cuatro regímenes regulatorios simultáneos que no comparten autoridad ni lógica, y esa es la particularidad que más condiciona su arquitectura.

El régimen financiero es el más exigente y el más reciente. La corresponsalía bancaria convirtió a la tienda en ventanilla de otros bancos bajo supervisión de la Comisión Nacional Bancaria y de Valores. La Ley Fintech de marzo de 2018 creó la figura de Institución de Fondos de Pago Electrónico, y en octubre de 2022 la Comisión autorizó bajo esa figura a la sociedad que opera la marca Spin, que había comenzado a operar antes de la ley. Spin mueve dinero por el Sistema de Pagos Electrónicos Interbancarios del Banco de México, lo que suma a Banxico como autoridad y a la CONDUSEF por la relación con el usuario de servicios financieros. En agosto de 2025 la empresa buscó una licencia bancaria propia y en abril de 2026 puso el trámite en pausa, con el argumento de priorizar la rentabilidad y reducir el costo regulatorio, de modo que la figura vigente sigue siendo la de fondos de pago electrónico, con el límite que eso impone: sin licencia bancaria no hay nómina, inversión ni crédito con los fondos captados.

El régimen fiscal y de consumo opera sobre el mostrador, con el Servicio de Administración Tributaria y la Procuraduría Federal del Consumidor, y en 2026 el Impuesto Especial sobre Producción y Servicios a bebidas saborizadas y cigarros movió precios y mezcla de venta lo suficiente como para explicar parte del crecimiento en ingresos. El régimen sanitario aplica a las farmacias del grupo y lo administra la Comisión Federal para la Protección contra Riesgos Sanitarios. Y el régimen de venta de alcohol y tabaco no es federal sino estatal y municipal, lo que significa reglas distintas por entidad y, probablemente, parametrización por tienda en el punto de venta.

Lo que esto le explica al brain es por qué su ontología no puede ser solo retail. La regulación viaja con la capability y no con la empresa, que es exactamente el caso probado en Liverpool: las capacidades de cuenta y pago cargan CNBV, Banxico y CONDUSEF dentro de una empresa cuya industria ancla es el comercio. Una regla de negocio que hoy parezca arbitraria en el punto de venta tiene buena probabilidad de responder a una de estas cuatro autoridades, y saber cuál es la diferencia entre poder cambiarla y no poder tocarla.

| Hecho | Fecha | Nivel | Fuente |
|-------|-------|-------|--------|
| Entrada en vigor de la Ley Fintech, que crea la figura de Institución de Fondos de Pago Electrónico | 2018-03 | gold | Ley para Regular las Instituciones de Tecnología Financiera, Diario Oficial de la Federación |
| Autorización de la CNBV a la operadora de Spin como Institución de Fondos de Pago Electrónico | 2022-10 | silver | [Expansión](https://expansion.mx/empresas/2022/10/07/oxxo-autorizacion-operar-pagos-electronicos-app-spin) |
| Operación de transferencias por SPEI desde la cuenta Spin | 2022 en adelante | silver | [Expansión](https://expansion.mx/empresas/2026/04/07/por-que-spin-oxxo-no-es-banco-pero-permite-transferencias) |
| Solicitud de licencia bancaria para Spin | 2025-08 | silver | [Expansión](https://expansion.mx/economia/2025/08/12/spin-oxxo-busca-licencia-bancaria-apuesta-por-clientes-de-bajos-recursos) |
| Pausa del trámite de licencia bancaria | 2026-04 | silver | [El Imparcial](https://www.elimparcial.com/dinero/2026/04/01/femsa-pone-en-stand-by-el-tramite-para-que-spin-tenga-su-propio-banco-con-el-objetivo-de-priorizar-la-rentabilidad-de-oxxo-y-reducir-costos-regulatorios-tras-la-caida-en-el-trafico-de-clientes/) |
| Efecto del Impuesto Especial sobre Producción y Servicios en precios y mezcla de venta | 2026 | silver | [Expansión](https://expansion.mx/empresas/2026/10/28/oxxo-vende-impulsado-ieps-a-cigarros-y-refrescos) |

---

## Dimensión 4 — Decisiones tecnológicas históricas

Esta es la dimensión que más vale para una modernización y la que casi no tiene fuente pública. Lo que se puede afirmar hoy es poco y conviene decirlo con esa honestidad en lugar de rellenarla.

De la plataforma de punto de venta existe un reporte de prensa, sin fecha identificable, sobre la selección de una solución de la marca NEC. No hay forma de saber si sigue vigente, y una plataforma de punto de venta a esta escala es precisamente el tipo de decisión que sobrevive décadas, así que la pregunta importa. De la presencia de SAP no hay evidencia pública alguna, ni a favor ni en contra, y este documento no la va a suponer. Lo que sí está declarado públicamente por la dirección de tecnología de la empresa es la postura: la digitalización se describe como medio para la experiencia del cliente y la eficiencia operativa, no como objetivo propio, y la logística aparece tratada como eje estratégico junto con la tecnología.

Todo lo demás, que es casi todo, son huecos. En particular falta lo que la Regla B26 llama el dato más valioso de esta dimensión y que casi nadie documenta: qué intentos de modernización ya se hicieron y cómo terminaron. Nadie quiere repetir una migración fallida y casi nadie la escribe.

| Hecho | Fecha | Nivel | Fuente |
|-------|-------|-------|--------|
| Selección reportada de una plataforma de punto de venta de NEC, vigencia desconocida | sin fecha confirmada | bronze | [Merca2.0](https://www.merca20.com/?p=41074) |
| Postura declarada de la tecnología como medio y no como fin | fecha por confirmar | silver | [Banorte](https://www.banorte.com/GFB/Noticias-GFB/La-tecnologia-es-un-medio-no-un-fin-OXXO.html) |
| Logística y tecnología tratadas como eje estratégico | 2026-08 | silver | [The Logistics World](https://thelogisticsworld.com/tecnologia/oxxo-la-logistica-y-la-tecnologia-como-su-eje-estrategico/) |

---

## Dimensión 5 — Cultura organizacional y poder

Sin acceso al cliente esta dimensión no se documenta, se infiere, y una inferencia sobre quién decide qué es justo el tipo de afirmación que no debe entrar al brain con apariencia de hecho. Lo único que la evidencia pública sostiene es estructural: OXXO es una unidad de negocio dentro de un grupo con holding propio, y las decisiones de portafolio se toman arriba de OXXO. FEMSA Forward lo demuestra sin ambigüedad, porque salir de la cerveza y vender la logística no fueron decisiones de la cadena de tiendas.

La consecuencia práctica para el brain es concreta y vale declararla desde ahora. El rol accountable de una decisión que afecte a OXXO puede no vivir en OXXO, y eso es exactamente lo que alimenta la tabla `stakeholders` y lo que determina si una acción puede ejecutarse en nivel A2 o necesita aprobación explícita en A3 bajo la Regla B39. Un brain que asuma que el dueño de la decisión está dentro de la unidad de negocio va a proponer acciones que nadie dentro de ella puede aprobar.

---

## Huecos abiertos por este estudio

Diecisiete preguntas, cada una redactada para que se pueda responder. Se sincronizan con `knowledge_gaps`, ancladas en `company_profile` o con `gap_type` de fuente, según corresponda.

| Dimensión | Pregunta concreta | A quién se le pregunta | Estado |
|-----------|-------------------|------------------------|--------|
| 1 | ¿La primera tienda abrió en Monterrey o en Guadalupe, Nuevo León? Hay fuentes contradictorias | Comunicación corporativa de la empresa | abierto |
| 1 | ¿Cuál es la fecha exacta de apertura de la primera tienda? Una sola fuente da el 1 de mayo de 1978 | Comunicación corporativa de la empresa | abierto |
| 2 | ¿Qué sistemas quedaron compartidos con los negocios desinvertidos en logística y refrigeración, y cómo se resolvió la separación? | Dirección de tecnología | abierto |
| 2 | ¿Las operaciones internacionales corren la misma plataforma que México o cada país tiene la suya? | Dirección de tecnología | abierto |
| 2 | ¿Valora opera con su propio stack europeo o se integró al de la unidad de proximidad? | Dirección de tecnología | abierto |
| 2 | ¿Qué formatos distintos de tienda existen hoy y cuáles comparten plataforma de punto de venta? | Dirección de operaciones | abierto |
| 3 | ¿Qué obligaciones regulatorias concretas se materializan como reglas dentro del punto de venta, y cuáles viven en sistemas separados? | Cumplimiento regulatorio | abierto |
| 3 | ¿Cómo se parametriza por entidad federativa la restricción de venta de alcohol y tabaco? | Dirección de operaciones | abierto |
| 3 | ¿Qué cambió en los sistemas por el régimen de corresponsalía bancaria y qué sigue siendo manual? | Cumplimiento regulatorio y dirección de tecnología | abierto |
| 3 | ¿La pausa del trámite de licencia bancaria dejó trabajo tecnológico detenido a medio camino? | Dirección de tecnología de la unidad financiera | abierto |
| 4 | ¿Cuál es la plataforma de punto de venta vigente, en qué versión y desde cuándo? | Dirección de tecnología | abierto |
| 4 | ¿Existe un ERP corporativo y cuál es el alcance que cubre en la operación de tienda? | Dirección de tecnología | abierto |
| 4 | ¿Qué intentos de modernización se emprendieron antes y cómo terminaron? | Dirección de tecnología | abierto |
| 4 | ¿Qué corre en centro de datos propio y qué en nube pública, y con qué proveedor? | Dirección de infraestructura | abierto |
| 4 | ¿Qué sistemas no se han reemplazado nunca y por qué razón explícita? | Arquitectura empresarial | abierto |
| 5 | ¿Quién aprueba un cambio en producción que afecta la operación de tienda, y hasta qué alcance decide la unidad sin subir al grupo? | Dirección de tecnología | abierto |
| 5 | ¿Qué decisiones tecnológicas se toman en el grupo y cuáles en la unidad de negocio? | Arquitectura empresarial | abierto |

---

## Nota sobre las fuentes de esta versión

Todo lo anterior se levantó de fuentes públicas el 20 de noviembre de 2026, sin acceso a documentación interna. Tres consecuencias conviene tenerlas presentes al leerlo. La prensa reporta con variaciones, y donde dos fuentes no coinciden el dato quedó como hueco en lugar de promediarse. Las cifras de tienda y de tráfico cambian cada trimestre, así que se registran con su fecha de validez y no como estado actual permanente, conforme a la Regla B40. Y ninguna afirmación de este documento es suficiente para sostener un gate: para eso hace falta la fuente primaria, que en este caso son los informes trimestrales de la empresa, las resoluciones publicadas del regulador y la documentación que entregue el cliente.

---

*Regla B26 del asset Enterprise Brain — Digital Core — Accenture México*
