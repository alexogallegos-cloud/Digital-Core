# Guion para Copilot — Deck ejecutivo del Laboratorio de Aceleración
## Versión con identidad Accenture

> Generado el 21 de octubre de 2026 desde `lab-brain.db`.
> No editar a mano: se regenera con `generators/build-copilot-prompt.py`.

**Cómo usarlo.** Abre PowerPoint, invoca Copilot y pega todo lo que viene después de la línea divisoria. Está escrito para que Copilot no tenga que buscar ni inferir nada: todos los datos van embebidos y verificados contra el Anexo B firmado.

**Antes de compartir.** Este deck es interno. La lámina 1 incluye modelo económico y penalizaciones, y la 2 distingue lo contratado de lo que no. Si va a salir del equipo de delivery, hay que sanitizarlo primero.

---

Necesito una presentación de **exactamente 5 láminas**, en español de México, para un comité ejecutivo. Audiencia: dirección de Accenture y liderazgo de delivery. Tiempo de exposición: 10 minutos, dos minutos por lámina.

## Reglas que aplican a todas las láminas

- **No inventes ningún dato.** Usa solo lo que te doy. Si algo falta, deja el espacio en blanco y anótalo como dato pendiente en las notas del orador.
- **Nada de tarifas, costos por persona ni precios unitarios.** No los tienes y no se deben estimar.
- **No incluyas nombres de personas del cliente ni cargos individuales.** Usa roles genéricos.
- Cada lámina lleva un título corto y una frase de bajada que diga la conclusión, no el tema.
- Prosa en frases completas. Sin flechas, sin vinetas con símbolos decorativos, sin emojis. Máximo seis líneas de texto por lámina fuera de las tablas.
- Las notas del orador llevan el detalle; la lámina lleva lo que se ve de lejos.

### Identidad visual: marca Accenture

Formato 16 por 9. Paleta de cinco roles, sin introducir colores fuera de esta lista:

| Rol | Color | Uso |
|---|---|---|
| Ancla | `#1C0032` | Paneles de encabezado, barras de tabla, cifras grandes |
| Papel | `#FFFFFF` | Fondo de las láminas |
| Plano | `#F8F4FF` | Superficies secundarias, filas alternas, recuadros |
| Trazo | `rgba(161, 0, 255, 0.18)` | Solo líneas, bordes y separadores. Nunca texto |
| Señal | `#A100FF` | Acento: barra superior de 3 puntos, rombos de hito y numerales de lámina |
| Texto | `#1A1A1A` | Cuerpo sobre papel o plano |
| Texto secundario | `#666666` | Notas al pie y valores de referencia |

- El morado vibrante es el acento icónico de la marca. Úsalo solo sobre el morado profundo, nunca sobre blanco.
- Todo texto sobre el color ancla va en blanco puro, sin transparencias ni grises.
- Cada panel de color ancla lleva una barra de 3 puntos en color señal en su borde superior. Es el único elemento que se repite en todas las láminas.
- Tipografía Segoe UI, con Calibri y Arial como alternativas. Solo dos pesos: negrita para títulos y datos, ligera para el cuerpo. La jerarquía se hace con peso, no con un tercer color.
- Nada de recuadros rellenos de color para marcar estado. Si necesitas destacar una celda, usa un subrayado de 1.5 puntos en color ancla.

### Logotipo

Coloca el logotipo de Accenture en la esquina inferior derecha de cada lámina, a un tamaño discreto. Los archivos están en `C:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Solutioning/Design - Studio/logos`:

- Accenture_logo_white_letters.png sobre fondos oscuros, Accenture_logo_hd.png sobre blanco

---

## Lámina 1. Resumen ejecutivo del contrato

Título sugerido: **Qué contratamos**. La bajada debe decir que es un laboratorio aislado de desarrollo, no un entorno productivo, y que esa distinción gobierna todo lo demás.

Datos exactos:

| Concepto | Valor |
|---|---|
| Instrumento | Anexo B del Contrato Maestro de Prestación de Servicios 2022.021519 |
| Servicio | CMO, Accenture Cloud Manager and Optimizer |
| Vigencia | Tres años, del 12 de octubre de 2026 al 11 de octubre de 2029 |
| Región | mx-central-1, México Central, Querétaro |
| Ventana de servicio | Lunes a viernes, 9 a 18 horas, hora Centro de Ciudad de México |
| Componentes | Habilitación inicial, Activación, Operación y Soporte |
| Cuota de arranque | 30,000 USD más IVA, exigible solo al acreditar en sesión en vivo que el laboratorio está listo |
| Modelo económico | Consumo de nube a precio de lista más un servicio mensual que va del 37 al 45 por ciento del consumo según la talla |
| Penalizaciones | Tope de 5 por ciento del monto mensual |
| Propiedad intelectual | Todos los Entregables son propiedad exclusiva de Banamex. Accenture no puede reutilizarlos, comercializarlos ni usarlos para entrenar modelos de IA |

**El mensaje central de la lámina**, que debe quedar visualmente destacado:

> La conexión con entornos productivos o con el Core real no forma parte del alcance

Y los cinco entregables formales, en una tabla compacta:

| # | Entregable | Frecuencia | Vence |
|---|---|---|---|
| 1 | Diseño de arquitectura y seguridad | Única, primer mes | 11 de noviembre de 2026 |
| 2 | Laboratorio base habilitado | Única, primer mes | 11 de noviembre de 2026 |
| 3 | Reporte de consumo de infraestructura y soporte | Mensual | Recurrente |
| 4 | Reporte de actividades realizadas por el equipo de SDLC | Mensual | Recurrente |
| 5 | Módulos de código para plantillas de arquetipos | Mensual | Recurrente |

En las notas del orador: la aceptación opera por silencio a los diez días hábiles, y los entregables 1 y 2 son los únicos con fecha dura.

---

## Lámina 2. Calendario

Título sugerido: **Cuatro semanas para una fecha que no se mueve**. La bajada debe decir que el Anexo no fija plazo de implementación y que su única fecha es el primer mes, por eso la ventana se ajustó a cuatro semanas.

Construye un **diagrama de Gantt horizontal** con eje semanal del 12 de octubre de 2026 al 11 de enero de 2027. Cuatro barras:

| Componente | Desde | Hasta | Tratamiento |
|---|---|---|---|
| HAB Habilitación inicial | 12 de octubre de 2026 | 23 de octubre de 2026 | Morado profundo sólido, está en la ruta crítica |
| ACT Activación de capacidades de emulación, SDLC y automatización | 19 de octubre de 2026 | 6 de noviembre de 2026 | Morado profundo sólido, está en la ruta crítica |
| OPE Operación y Soporte | 9 de noviembre de 2026 | 31 de marzo de 2027 | Gris claro con borde, continúa más allá del eje |
| EXT Trabajo de apoyo fuera del Anexo B | 19 de octubre de 2026 | 6 de noviembre de 2026 | Gris claro, no está contratado |

**Importante sobre la barra de Operación y Soporte:** el eje termina en enero pero el servicio corre hasta octubre de 2029. Etiquétala para que se entienda que continúa, no la cortes sin avisar.

Sombrea las primeras cuatro semanas, del 12 de octubre al 6 de noviembre, con una banda morada tenue rotulada **Implementación, 4 semanas**.

Marca los hitos con rombos en color acento:

| Hito | Fecha | Qué es |
|---|---|---|
| H1 | 12 de octubre de 2026 | Inicio de vigencia del Anexo B |
| H2 | 9 de noviembre de 2026 | Arranque de Operación y Soporte |
| H3 | 11 de noviembre de 2026 | Cierre del primer mes del proyecto |
| H4 | 11 de noviembre de 2026 | Acreditación de los cuatro criterios |

En las notas del orador: los hitos H3 y H4 caen el mismo día, y el H4 no tiene fecha en el contrato, es la que proponemos nosotros.

---

## Lámina 3. Equipo

Título sugerido: **Equipo dimensionado al ambiente, no al patrón**. La bajada debe decir que los niveles de servicio son de un ambiente de desarrollo y el equipo se dimensionó en consecuencia.

Dos cifras grandes y legibles de lejos: **8.30 FTE** en implementación y **5.80 FTE** en operación, sobre 12 perfiles.

Tabla de perfiles, ordenada como viene:

| Rol | Nivel | Tier | Ubicación | FTE implementación | FTE operación |
|---|---|---|---|---|---|
| Delivery Executive | L4 | Gobierno | Onshore | 0.05 | 0.05 |
| Service Delivery Lead | L7 | T3 | Onshore | 0.50 | 0.50 |
| Solution Architect | L7 | T3 | Nearshore | 1.00 | 0.25 |
| SDLC y DevSecOps Architect | L8 | T3 | Nearshore | 1.00 | 0.50 |
| Cloud Engineer Senior | L8 | T2 | Nearshore | 1.00 | 1.00 |
| Platform Engineer, infraestructura como código | L9 | T2 | Nearshore | 2.00 | 1.00 |
| Harness y Agent Engineer | L9 | T2 | Nearshore | 1.00 | 0.50 |
| Synthetic Data Engineer | L9 | T2 | Nearshore | 0.50 | 0.25 |
| IAM Engineer | L9 | T2 | Nearshore | 0.50 | 0.25 |
| SecOps Engineer | L9 | T2 | Nearshore | 0.50 | 0.25 |
| FinOps Analyst | L9 | T2 | Nearshore | 0.25 | 0.25 |
| Operations Engineer | L10 | T2 | Nearshore | 0.00 | 1.00 |
| **Total** | | | | **8.30** | **5.80** |

Agrega un recuadro lateral con tres frases cortas que expliquen por qué el equipo es más chico que el patrón de banca del guideline:

- No hay datos reales de clientes ni ruta al core real.
- La ventana de servicio es de lunes a viernes de 9 a 18 horas, y el contrato no menciona operación continua en ningún lugar.
- No hay recuperación ante desastres en el alcance.

En las notas del orador: estos FTE son un patrón de referencia para dimensionar. El headcount formal lo calcula IMS Estimation y se formaliza en el SP-11. Y hay un supuesto pendiente de confirmar por escrito, que el reloj de severidad 1 y 2 corra dentro de la ventana de servicio; si no se cumple, el equipo crece más de un FTE.

---

## Lámina 4. Responsabilidades

Título sugerido: **Un solo responsable por entregable**. La bajada debe decir que cada entregable tiene un dueño único que responde, y que el resto ejecuta, consulta o se entera.

Construye una **matriz RACI**: entregables en las filas, roles en las columnas. Usa las iniciales A, R, C e I. Destaca la A con negrita o con un subrayado de color, nunca con un recuadro relleno.

Columnas, en este orden:

- **R01**: Delivery Executive
- **R02**: Service Delivery Lead
- **R03**: Solution Architect
- **R04**: SDLC y DevSecOps Architect
- **R05**: Cloud Engineer Senior
- **R06**: Platform Engineer, infraestructura como código
- **R07**: Harness y Agent Engineer
- **R08**: Synthetic Data Engineer
- **R09**: IAM Engineer
- **R10**: SecOps Engineer
- **R11**: FinOps Analyst
- **R12**: Operations Engineer

Matriz:

| Entregable | R01 | R02 | R03 | R04 | R05 | R06 | R07 | R08 | R09 | R10 | R11 | R12 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| Diseño de arquitectura y seguridad |  | I | A | C | R |  |  |  |  | C |  |  |
| Laboratorio base habilitado |  | I | C |  | A | R |  |  | R |  |  |  |
| Acreditación de los cuatro criterios | I | A |  |  | C | R |  |  | R |  |  |  |
| Core emulado y harness de agentes |  |  | C | A |  |  | R | R |  |  |  |  |
| Fábrica de datos sintéticos |  |  |  | A |  |  |  | R |  | C |  |  |
| Compuertas con evidencia automática |  |  |  | A |  | R | R |  |  |  |  |  |
| Plantillas de arquetipos en Terraform |  |  | C |  | R | A |  |  |  |  | C |  |
| Reporte mensual de consumo y soporte |  | R |  |  |  |  |  |  |  |  | A | C |
| Reporte mensual de actividades de SDLC |  | A |  | R |  | C |  |  |  |  |  |  |
| Cumplimiento de los compromisos de servicio |  | A |  |  |  |  |  |  | R | C |  | R |
| Arquetipo nuevo a la medida, 10 días hábiles |  | I | A |  |  | R |  |  |  |  | C |  |

Leyenda al pie: A es quien responde, R quien ejecuta, C a quien se consulta, I a quien se informa.

---

## Lámina 5. Detalle de la implementación

Título sugerido: **Las cuatro semanas, actividad por actividad**. La bajada debe decir dónde está el cuello de botella.

Organiza la lámina en **cuatro columnas, una por semana**. Encabeza cada columna con el rango de fechas y el número de actividades. Dentro de cada columna lista las actividades por su identificador y un resumen de cinco a ocho palabras. Marca en negrita las que están en la ruta crítica.

### Semana 1: del 12 de octubre de 2026 al 16 de octubre de 2026 (4 actividades)

Foco: Habilitación: cuentas, red aislada, controles base y catálogo

| ID | Actividad | Ruta crítica | Componente |
|---|---|---|---|
| ACT-08 | Organización cloud, cuentas hijas, unidades organizativas y políticas de control | Sí | HAB |
| ACT-09 | Red aislada, endpoints privados y verificación de que no hay ruta al core real |  | HAB |
| ACT-11 | Controles base: cifrado con llave del banco, registro de actividad, postura |  | HAB |
| ACT-14 | Catálogo de aprovisionamiento de autoservicio | Sí | HAB |

### Semana 2: del 19 de octubre de 2026 al 23 de octubre de 2026 (22 actividades)

Foco: Verificación, decisiones de seguridad, identidad y repositorio

| ID | Actividad | Ruta crítica | Componente |
|---|---|---|---|
| ACT-01 | Inventariar el estado real de la habilitación contra lo comprometido | Sí | HAB |
| ACT-02 | Confirmar la talla esperada del servicio y la demanda que la justifica |  | HAB |
| ACT-03 | Pedir a Banamex la designación de usuarios para el gate de arranque | Sí | HAB |
| ACT-04 | Agendar la revisión conjunta con Arquitectura y Seguridad del banco | Sí | HAB |
| ACT-05 | Cerrar las tres decisiones de seguridad abiertas | Sí | HAB |
| ACT-06 | Levantar el registro de decisiones, riesgos y datos requeridos |  | HAB |
| ACT-07 | Pedir la línea base del SDLC actual del banco: tiempo de ciclo, costo, equipos |  | EXT |
| ACT-10 | Identidad federada con MFA obligatorio para terceros y proveedores | Sí | HAB |
| ACT-12 | Repositorio y ruta de ingreso de código según la decisión de ACT-05 | Sí | HAB |
| ACT-13 | Pipeline de integración y despliegue continuos | Sí | HAB |
| ACT-15 | Sandbox inicial operado | Sí | HAB |
| ACT-16 | Despliegue de los arquetipos de arranque como plantillas de Terraform |  | HAB |
| ACT-17 | Automatizar el vencimiento y la revocación de accesos | Sí | HAB |
| ACT-19 | Recibir del banco contratos de interfaz, esquemas de mensajes y reglas de negocio |  | ACT |
| ACT-28 | Entregar el diseño de arquitectura y seguridad y conseguir la revisión conjunta |  | HAB |
| ACT-31 | Montar el brain del laboratorio con su esquema y su cargador |  | EXT |
| ACT-32 | Cargar la capa contractual desde el Anexo B |  | EXT |
| ACT-33 | Cargar la capa de laboratorio desde el diseño de solución |  | EXT |
| ACT-34 | Cargar la capa de setup con las actividades y entregables del plan |  | EXT |
| ACT-35 | Federar el brain del core por referencia, sin duplicar el corpus |  | EXT |
| ACT-36 | Modelar las cuatro iniciativas estratégicas con sus habilitadores y brechas |  | EXT |
| ACT-37 | Derivar contratos de interfaz candidatos desde las reglas del core |  | EXT |

### Semana 3: del 26 de octubre de 2026 al 30 de octubre de 2026 (5 actividades)

Foco: Núcleo de la activación: core emulado, datos sintéticos y pipeline

| ID | Actividad | Ruta crítica | Componente |
|---|---|---|---|
| ACT-18 | Acordar el marco de controles con Seguridad del banco e integrarlo a su estándar |  | ACT |
| ACT-20 | Modelar escenarios por dominio: normal, excepción, latencia, rechazo y caos |  | ACT |
| ACT-21 | Construir el core emulado por dominio con agentes y enrutador de escenarios |  | ACT |
| ACT-22 | Montar la fábrica de datos sintéticos con validación, versionado y firma |  | ACT |
| ACT-25 | Conectar observabilidad, centro de operaciones de seguridad, gestión de servicio y parcheo |  | OPE |

### Semana 4: del 2 de noviembre de 2026 al 6 de noviembre de 2026 (7 actividades)

Foco: Compuertas, pilotos, ensayo y sesión de acreditación

| ID | Actividad | Ruta crítica | Componente |
|---|---|---|---|
| ACT-23 | Implementar las compuertas de control con evidencia automática |  | ACT |
| ACT-24 | Levantar dos sandboxes piloto y el primer micro frontend en pruebas |  | ACT |
| ACT-26 | Activar las capacidades por catálogo según la talla contratada |  | ACT |
| ACT-27 | Ensayar internamente los cuatro criterios de extremo a extremo | Sí | ACT |
| ACT-29 | Ejecutar la sesión de verificación con usuarios reales de Banamex | Sí | ACT |
| ACT-30 | Obtener la confirmación por escrito del cumplimiento | Sí | ACT |
| ACT-38 | Levantar el estado actual del SDLC del banco como capa del brain |  | EXT |

Al pie de la lámina, una franja con esta frase, que es la conclusión:

> La semana 2 concentra la mayor carga y seis de sus actividades están en la ruta crítica. Tres de ellas no dependen de trabajo técnico nuestro: dependen de que el banco designe usuarios, dé una agenda con Arquitectura y Seguridad, y cierre tres decisiones de seguridad.

En las notas del orador: la ruta crítica completa tiene 14 pasos y termina en la sesión en vivo que acredita los cuatro criterios y vuelve exigible la cuota de arranque.

---

Cuando termines, dime qué datos dejaste en blanco por no tenerlos.
