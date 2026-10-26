# Guion para Copilot — Plan de cobertura de arquitectura
## Digital Core México, FY27

> Generado desde `data/pipeline-fy27.json`, línea base validada el 2026-10-21.
> No editar a mano: se regenera con `generators/build-copilot-cobertura.py`.

**Correcciones aplicadas en esta versión.** Los offerings 02 AIE, 05 MDP y 06 Innovation aparecen consolidados en **Data & AI**, porque los tres se fusionaron en uno solo. Y se retiraron las dos láminas que clasificaban las oportunidades por vigencia: la de estado del portafolio y la de por qué no se puede atender una por una.

**Nota sobre el dato.** La consolidación se aplica al generar el guion. El archivo de línea base conserva los tres offerings originales para no perder trazabilidad.

---

Necesito una presentación en español de México para el liderazgo de Digital Core. Formato 16 por 9. Título del documento: **Plan de cobertura de arquitectura, Digital Core México, FY27**.

## Reglas que aplican a todas las láminas

- **No inventes ningún dato.** Usa solo lo que te doy. Si algo falta, déjalo en blanco y anótalo en las notas del orador.
- **Sin tarifas, sin montos por persona, sin precios unitarios.**
- **Sin nombres de personas ni cargos individuales.** Usa roles genéricos.

### Identidad visual: marca Accenture

| Rol | Color | Uso |
|---|---|---|
| Ancla | `#1C0032` | Banda de título, encabezados de tabla, cifras grandes |
| Papel | `#FFFFFF` | Fondo de las láminas |
| Plano | `#F8F4FF` | Recuadros laterales y filas alternas |
| Trazo | `rgba(161, 0, 255, 0.18)` | Solo líneas y separadores. Nunca texto |
| Señal | `#A100FF` | Acento: cifra destacada, numerales, barra superior |
| Texto | `#1A1A1A` | Cuerpo |
| Texto secundario | `#666666` | Notas al pie |

- El morado vibrante solo sobre el morado profundo o como cifra destacada. Nunca como fondo de bloques grandes de texto.
- Todo texto sobre el color ancla va en blanco puro.
- Tipografía Segoe UI, con Calibri y Arial como alternativas. Dos pesos: negrita para títulos y datos, ligera para el cuerpo.
- Cada lámina lleva la banda de título en color ancla arriba, el contenido en papel, y un pie con el texto **Plan de cobertura de arquitectura | Digital Core México, FY27** más el número de lámina.
- Las tablas no llevan recuadros rellenos de color. Separadores finos y nada más.
- Prosa en frases completas. Sin flechas, sin emojis, sin vinetas decorativas.

### Logotipo

Logotipo de Accenture discreto en la esquina inferior derecha. Archivos en `C:/Users/alejandro.gallegos/OneDrive - Accenture/Documents/Solutioning/Design - Studio/logos`: `Accenture_logo_white_letters.png` sobre fondos oscuros y `Accenture_logo_hd.png` sobre blanco.

---

## Lámina 1. El portafolio en una vista

Título: **Qué tenemos enfrente**. La bajada debe decir que el portafolio se concentra en pocas cuentas y pocos offerings.

Tres cifras grandes, en color señal:

- **53** oportunidades
- **16** cuentas
- **5** offerings tras la consolidación de Data & AI

Debajo, un recuadro en color plano con esta nota de método, textual:

> El inventario se construyó leyendo las fechas escritas dentro de los deal-states y los brains, no el timestamp de los archivos. Muchas carpetas comparten la misma fecha de modificación por una operación masiva de OneDrive que no corresponde a trabajo real.

---

## Lámina 2. Cobertura por offering

Título: **Dónde está el portafolio**. La bajada debe decir que un solo offering concentra la mitad de las oportunidades.

Gráfica de barras horizontales, ordenada de mayor a menor, con la tabla al lado:

| Offering | Oportunidades | Participación |
|---|---|---|
| 03 S&PE | 26 | 49 por ciento |
| 07 AMS | 11 | 21 por ciento |
| 04 II | 8 | 15 por ciento |
| Data & AI | 5 | 9 por ciento |
| 01 TS&T | 3 | 6 por ciento |
| **Total** | **53** | **100 por ciento** |

En las notas del orador: Data & AI reúne lo que antes se reportaba como AI Enabled Enterprise, Modern Data Platform e Innovation, que se consolidaron en un solo offering.

Las cinco oportunidades que componen Data & AI, por si las piden:

| Cuenta | Oportunidad |
|---|---|
| Banamex | Flujo 5, Future Bank |
| Banamex | Innovation Environment |
| Gentera | GenAI RFP Analyzer |
| Gentera | Nueva Estrategia de Datos |
| Volaris | GenAI Gateway |

---

## Lámina 3. Concentración por cuenta

Título: **La capacidad no sigue al portafolio**. La bajada debe decir que la cuenta con más oportunidades es AXA, con 14, y que cae en el bucket que recibe 20 por ciento de la capacidad.

Tabla de las cuentas con más de una oportunidad:

| Cuenta | Oportunidades |
|---|---|
| AXA | 14 |
| Banamex | 11 |
| BanCoppel | 5 |
| Actinver | 3 |
| BBVA | 3 |
| Gentera | 2 |
| Liverpool | 2 |
| MIFEL | 2 |
| Mapfre | 2 |
| Scotia | 2 |
| Volaris | 2 |
| Cuentas con una sola oportunidad | 5 |

Al lado, un recuadro en color plano que compare el peso del portafolio contra la capacidad comprometida. Este contraste es el mensaje de la lámina:

| Bucket | Oportunidades | Capacidad asignada |
|---|---|---|
| Banamex | 11 | 40 por ciento |
| Bancoppel | 5 | 40 por ciento |
| Resto | 37 | 20 por ciento |

---

## Lámina 4. El plan de cobertura

Título: **Cómo lo cubrimos**. La bajada debe decir qué se atiende primero y con qué criterio.

Construye una tabla de tres columnas, una por bucket, con la capacidad asignada en el encabezado y debajo las cuentas que caen en cada uno:

- **Banamex**, 40 por ciento de la capacidad, 11 oportunidades: Banamex.
- **Bancoppel**, 40 por ciento de la capacidad, 5 oportunidades: BanCoppel.
- **Resto**, 20 por ciento de la capacidad, 37 oportunidades: AXA, Actinver, BBVA, Banorte, Coppel, Gentera, HSBC, KOF, Liverpool, MIFEL, Mapfre, Posadas, Scotia, Volaris.

En las notas del orador: el reparto de capacidad es del owner del portafolio. Las dos cuentas con bucket propio suman 16 oportunidades y 80 por ciento de la capacidad, mientras que el resto suma 37 oportunidades con 20 por ciento. Ahí está la decisión que la lámina pone sobre la mesa, y AXA es el caso más visible.

---

## Lo que esta versión NO lleva

**Queda fuera toda la dimensión de vigencia**, es decir la clasificación de las oportunidades en vivas, prospectivas, en riesgo, caducadas y sin expediente. Se retiraron a propósito las dos láminas que la usaban:

- La de estado del portafolio, con el conteo por vigencia y la cifra de oportunidades vivas sobre el total.
- La de por qué no se puede atender una por una, con el tipo de atención que pide cada vigencia.

No reintroduzcas esa clasificación en ninguna otra lámina, ni en las notas del orador.

Cuando termines, dime qué datos dejaste en blanco por no tenerlos.
