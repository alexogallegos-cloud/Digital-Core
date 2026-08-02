# GemCog Portal — Capa de Presentación
> Indexado: ✅ 2026-07-17 — Capa de presentación del portal GemCog

**Repositorio:** `Banamex/GemCog/portal/` · **Deploy:** `s3://bdtc-showcase-demo-frontend-ab0cf743/banamex/portal/`
**Sistema de diseño:** Dark `#071c23` base · rojo `#E8344A` (S500) · azul-cielo `#6CC5D8` (S151) · glassmorphism consistente

---

## 1. `index.html` — Hub Central / Landing

**Título:** *Banamex · Gemelo Cognitivo del Core Mainframe*

**Layout:** Single-page scrollable de pantalla completa con nav fija superior.

**Componentes visuales:**
- **Aurora background:** tres blobs animados con blur radial + capa de grano (SVG noise filter) — ambos en `position:fixed`, `z-index:-1/-2`.
- **Barra de progreso de scroll:** línea de 3px en top con gradiente dorado/blanco.
- **Nav sticky:** logo Banamex + texto proyecto + links de anchor a secciones.
- **Hero section:** eyebrow chip animado (dot pulsante) · H1 gigante con gradiente de texto · subtítulo explicativo · scroll cue con flecha bouncing.
- **6 tiles de stats** (grid 6 col): programas · LOC · dominios · etc.
- **Secciones con cards de navegación** hacia los 11 portales satélite — cada card (`vcard`) tiene ícono, título, descripción y link. Cards inactivas/pendientes usan clase `vcard-pending` con opacity 0.55.
- **Cards de transversales** (`xcard`) con borde izquierdo dorado para capas metodológicas.

**Interacciones:** Hover lift en vcards (`translateY(-6px)` + sombra). Scroll suave entre secciones.

---

## 2. `chord-gemcog.html` — Grafo de Llamadas entre Dominios

**Título:** *Grafo de Llamadas entre Dominios · S500 + S151 · Capa 4 (Intención)*

**Layout:** Header fijo → barra de stats → lead text → área de visualización (flex row) → footer.

**Componentes visuales:**
- **Barra de 5 KPIs:** Dominios S500 `3` (rojo) · Dominios S151 `5` (sky) · Aristas totales `1,085` · CAPTACION↔CONTABILIDAD `196` · Cross-system `272`.
- **Chord diagram D3 v7:** anillo de 8 arcos coloreados (S500 rojo-family, S151 sky-family) · cintas proporcionales al volumen de llamadas PERFORM/CALL · etiquetas de nombre en cada arco.
- **Panel de leyenda** (240px, derecha): agrupado por sistema S500/S151, swatch de color + nombre de dominio + hint de lectura.
- **Tooltip flotante** (`position:fixed`): aparece en hover sobre arco o cinta mostrando sistemas, nombres y conteo.

**Interacciones:** Hover sobre arco → aisla sus cintas (resto baja opacity a 0.06). Hover sobre cinta → muestra detalle de la relación bidireccional.

---

## 3. `flow-gemcog.html` — Flujo de Control COBOL/ALGOL

**Título:** *Flujo de Control · GemCog · S500 + S151*

**Layout:** Dos paneles fijos a 100vh: sidebar izquierda (320px) + panel principal (flex:1).

**Sidebar:**
- Banner con logo + subtítulo + advertencia naranja (nombres pendientes).
- Indicador de carga (`#ls`) con estados: wait/ok/err (colores semáforo).
- Input de búsqueda de journeys.
- Lista de journeys ordenados por complejidad: cada row muestra nombre en monospace, badge de complejidad (C=rojo/H=naranja/L=verde), badge de dominio.

**Panel principal:**
- Header de journey seleccionado: nombre en monospace grande, descripción, métricas tiles (profundidad, calls, IFs, loops), leyenda de colores.
- Área de flow (monospace `Cascadia Code/Consolas`): árbol de llamadas con sangría + íconos por tipo: `→` CALL (verde) · `?` IF (naranja) · `⟳` PERFORM UNTIL (azul).
- Tags inline: `[x]` cross-dominio (rojo) · `[r]` regulatorio (sky).
- Estado vacío cuando no hay journey seleccionado.

---

## 4. `evolution-gemcog.html` — Evolución del Código ("las vetas del árbol")

**Título:** *Evolución del Código · GemCog — "las vetas del árbol"*

**Layout:** Header → area flex (SVG principal + sidebar derecha 300px) → tiles summary → footer.

**Componentes visuales:**
- **Área chart D3:** eje X = tiempo (décadas) · eje Y = LOC acumulado por capa de lenguaje · milestones marcados con línea punteada + año. Cada capa tiene color propio, hover eleva opacity.
- **Sidebar derecha:** filtro por lenguaje (leyenda clickeable on/off) · cards de product por periodo con sparkline de barras + nombre + métricas.
- **Tiles summary** (strip horizontal): KPIs de LOC, programas, eras detectadas.
- **Tooltip:** muestra año, capa, LOC, milestone si aplica.
- **Footer:** metadata técnica del análisis.

---

## 5. `generations-gemcog.html` — Relevo Generacional y Deuda

**Título:** *Relevo Generacional, Vocabulario y Deuda · Capa 3 (Biografía)*

**Layout:** Header sticky → `.wrap` scrollable (max 1020px centrado) → footer.

**Componentes visuales:**
- **Aurora background:** tres blobs estáticos con blur 80px.
- **4 verdict cards (2×2):** glassmorphism con borde izquierdo colored — sky para hallazgos positivos (`vok`), rojo para deuda/riesgo (`vdebt`). Temas: Vocabulario · Deuda técnica · Autoría (Conway's Law) · Riesgo de modernización.
- **System badges:** `S500` (rojo, background rgba) y `S151` (sky) como separadores de sección.
- **Tablas generacionales:** por era/generación, con columnas: era, LOC, programas, complejidad media, % huérfano.
- **Charts SVG inline:** barras de huérfanos por generación (`hl` = valor, `mx` = max label, ediv = separadores).
- **Minigrid 2×2:** mini-charts de evolución paralela S500 vs S151.
- **Nota glassmorphism** al final de cada sección: highlight de la lectura clave.

---

## 6. `journeys-gemcog.html` — Journeys de Negocio

**Título:** *Journeys de Negocio · S500 Cargos & Abonos · S151 Movimientos Contables*

**Layout:** Tres columnas fijas a 100vh: sidebar izquierda (238px) + lista de journeys (278px) + panel de detalle (flex:1).

**Sidebar izquierda:**
- Banner con logo.
- Botones de filtro por dominio con swatch de color circular + nombre + conteo.
- Panel de cobertura: orquestadores, servicios expuestos, dominios (11), programas (219), evidencia.
- Leyenda de colores.

**Lista de journeys:**
- Header de dominio seleccionado con descripción.
- Cards filtradas: título del journey (bold), nombre de programa (monospace gris), métricas (steps, regulatorios, cross-domain), badges de tipo.

**Panel de detalle:**
- Header con programa + descripción + métricas inline.
- Secuencia de steps en monospace con números de línea, ícono direccional, nombre del proceso, programa origen.
- Tags `[r]` (regulatorio) y `[x]` (cross-dominio) en naranja/sky.
- Estado vacío con instrucción cuando no hay journey seleccionado.

---

## 7. `component-map-gemcog.html` — Mapa de Componentes (Grafo de Fuerza)

**Título:** *Mapa de Componentes (Grafo) — Banamex Unisys MCP*

**Layout:** Sidebar izquierda fija (240px) + canvas principal a 100vh overflow hidden.

**Sidebar:**
- Scope banner con logo + título + warning de cobertura (azul claro).
- Indicador de carga (ok/err/wait).
- Navegación de dominios: botones colapsables con swatch circular + nombre + conteo de programas · badges `REG`/`CRIT` en rojo.
- Headers separadores `S500` y `S151` en dorado.
- Controles de filtro (zoom, isolate, reset).

**Canvas principal:**
- D3 force-directed graph: nodos = programas · aristas = llamadas PERFORM/CALL.
- Colores de nodos = dominio (misma paleta que chord).
- Tamaño de nodo proporcional a LOC o grado de conexión.
- Tooltip al hover: nombre, dominio, LOC, conexiones.

---

## 8. `lexical-evolution-gemcog.html` — Evolución del Lenguaje y las Almas

**Título:** *Evolución del Lenguaje y las Almas · capas 1×2×3*

**Layout:** Header sticky → `.wrap` scrollable (max 1080px) → footer.

**Componentes visuales:**
- **5 tiles de stats** (grid 5 col, top-border sky/rojo): 143 términos v2.2 · breakdown por categoría (fundacional, técnico, regulatorio, etc.).
- **Sección 1 — Evolución léxica:** SVG line chart · eje X = generaciones/eras · eje Y = términos activos · áreas sombreadas por era · leyenda de tipo de término.
- **Sección 2 — Soul Gantt:** por cada "alma" (iniciales/código de empleado), barra horizontal que abarca su periodo de actividad. S500 barras en gradiente rojo, S151 en gradiente sky. Valores de LOC a la derecha.
- **Sección 3 — Fingerprints:** grid 2×2 de paneles por alma destacada · chips (`pill`) con sus términos característicos · hover con tooltip de frecuencia.
- **Nota glassmorphism:** lectura metodológica del Gemelo Cognitivo.

---

## 9. `quality-gemcog.html` — Calidad del Código (ISO 5055)

**Título:** *Calidad del Código (ISO 5055) · GemCog*

**Layout:** Header sticky → `.wrap` scrollable (max 1180px) → footer.

**Componentes visuales:**
- **Badge ISO 5055** en header (sky, esquina derecha).
- **Stats tiles** (flex-wrap): programas totales · críticos · ok · por dominio — con borde izquierdo coloreado (sky/verde/rojo).
- **Lead text:** explicación del estándar ISO/IEC 5055:2021 y su aplicación a COBOL/ALGOL.
- **Factor bars:** por cada una de las 4 características ISO (Fiabilidad, Seguridad, Eficiencia de rendimiento, Mantenibilidad) + Tamaño — barra segmentada mostrando distribución S500 vs S151, número de score a la derecha.
- **Radar chart SVG (pentagonal):** dos polígonos superpuestos — S500 (rojo, semi-transparente) vs S151 (sky, semi-transparente) · labels de los 5 ejes · valores en vértices.
- **Tablas detalladas:** por dominio y programa · columnas: nombre monospace, dominio chip, score, issue count, evidencias (chips de reglas infringidas).
- **Histograma de complejidad:** distribución ciclomática con htrack bars + valores en rojo/naranja para outliers.

---

## 10. `modelo-er.html` — Modelo Entidad-Relación de Dominios

**Título:** *Modelo Entidad-Relación de Dominios · Capa 1 (lenguaje · vocabulario de dominio)*

**Layout:** Header sticky → intro text → área con scroll horizontal → footer.

**Componentes visuales:**
- **Intro paragraph:** explica lectura del diagrama (top-10 términos como atributos, relaciones = llamadas reales del dep graph).
- **Canvas posicionado absolutamente (1300×760px):** con overflow-x scroll.
- **Domain boxes** (`position:absolute`): cada dominio como tarjeta con header (`dh`) en gradiente azul-oscuro + filas de atributos en grid 72px/1fr — tipo E (entidad, sky) · A (atributo, rojo) · R (relación, cyan claro) — valores en monospace.
- **SVG de líneas** (overlay, `pointer-events:none`): paths curvados entre dominios con marcadores de punto en extremos + etiqueta de conteo de llamadas sobre la línea.
- S500 (TARJETAS, CAPTACION, CONTROL, ASINCRONA, TELETON, MAPLI) posicionados a la izquierda; S151 (CONTABILIDAD, MOVIMIENTOS, CTRL-GL, REPORTES, AJUSTES) a la derecha.

---

## 11. `rules-report-gemcog.html` — Reglas de Negocio

**Título:** *Reglas de Negocio y Fórmulas · GemCog — S500 + S151*

**Layout:** Viewport fijo 100vh · header → barra de controles → tabla con scroll interno.

**Barra de controles:**
- Select de **Dominio** con `optgroup` S500 / S151.
- Select de **Programa** (P010, P015, P130, etc.).
- Select de **Tipo** (IF / EVALUATE / COMPUTE / PERFORM / CALL).
- Input de **Búsqueda** libre (180px).
- Contador dinámico: `N de 63 reglas`.

**Tabla scrollable (sticky thead):**

| Columna | Presentación |
|---------|--------------|
| Dominio | Chip coloreado: `REP`=naranja · `CTL`=verde · `SEC`=púrpura · `TAR`=azul · `CON`=azul oscuro · `MOV`=verde claro · `CTL151`=rosa |
| Programa | Monospace gris |
| Tipo | Badge: `IF`=verde · `EVALUATE`=lima · `COMPUTE`=lavanda · `PERFORM`=rojo · `CALL`=azul |
| Línea | Monospace pequeño |
| Descripción | Texto max-width 340px |
| Regulatorio | Micro-chips: `CNBV` · `BANXICO` · `SAT` · `CONDUSEF` |

**Interacciones:** Click en headers de columna para ordenar (con indicador ↑/↓). Filtros combinables en tiempo real.

---

## 12. `modelo-capacidades.html` — Modelo de Capacidades Bancarias

**Título:** *Modelo de Capacidades Bancarias (referencia + cobertura S500 / S151)*

**Layout:** Header sticky → barra de KPIs + leyenda → matriz de capacidades → panel deslizante de detalle → footer.

**Componentes visuales:**
- **Barra de KPIs** (tiles inline): capacidades cubiertas por sistema.
- **Leyenda de cobertura:** S500 (rojo) · S151 (sky) · Ambos (teal) · Sin cobertura (oscuro).
- **Matriz de capacidades** (max-width 1500px): áreas bancarias como filas (`area`) con título en sky a la izquierda · grupos de capacidades (`grp`) con label en uppercase · celdas individuales (`cap`) coloreadas por cobertura.
- **Panel de detalle deslizante** (`#dpanel`): 50% de ancho · slide desde derecha con transición `cubic-bezier` · cabecera con nombre de capacidad, descripción y stats · cuerpo con process cards (`proc`) mostrando nombre del proceso, descripción, programas (monospace), trigger, y flujo de pasos. Borde izquierdo: rojo (S500), sky (S151), teal (ambos).

**Interacciones:** Click en cualquier celda de capacidad cubierta → abre panel. Botón `×` para cerrar.

---

## 13. `flows/t-{cap}-{NNN}.html` — Flow Pages (Tareas L5)

**Patrón de nombre:** `t-{slug}-{NNN}.html` donde slug = capacidad (pay, orc, gl, rec…) y NNN = número secuencial por capacidad.
**Breadcrumb ID:** `6.X.X.N · Nombre del proceso L4 / T-CAP-NNN`
**Servidor local de desarrollo:** `python -m http.server 7700` desde `portal/`

---

### Layout estándar (secciones en orden)

| Sección | Clase / elemento | Obligatorio |
|---------|-----------------|-------------|
| Header sticky con breadcrumb | `<header>` + `.breadcrumb` | ✅ |
| Título + meta (sistema, tipo, frecuencia, regla, confianza) | `header h1` + `.meta` | ✅ |
| Flujo visual (Mermaid flowchart) | `.card` + `.mermaid-wrap.flow-pad` | ✅ |
| Reglas centrales | `.card` + `.rule-block` (1–3 reglas) | ✅ |
| Vocabulario controlado | `.card` + `.vocab-grid` + `.vocab-item` | ✅ |
| Diagrama de secuencia (Mermaid) | `.card` + `.mermaid-wrap` | ✅ |
| Riesgos de migración | `.card` + `.risk-table` | ✅ |
| Secciones adicionales opcionales | variante-grid, slot-diagram, chain-box… | opcional |
| Footer con referencias | `<footer>` | ✅ |
| Tooltip flotante `#mmtip` | `<div id="mmtip">` + JS | ✅ |

---

### Design tokens (idénticos en todos los flows)

```css
--bg:#071c23   --bg2:#0a2530   --panel:#0e2e3a   --line:#1a4555
--txt:#F0F8FA  --muted:#7fb8c8
--on:#C1272D   (S500 / error / crítico)
--on2:#6CC5D8  (S151 / info / teal)
--on3:#1E8FA0  (S500+S151 / ambos)
--acc:#6CC5D8  (accent text, links)
```

Badges de sistema: `.badge` = S500 rojo · `.badge.s151` = S151 sky · `.badge.ambos` = teal.

---

### Sistema de hover — contrato canónico

#### Estructura de datos

```javascript
// Objeto de información de un nodo/término
{
  title: string,       // Nombre del concepto (obligatorio)
  rule:  string?,      // ID de regla: "RN-S500-115" (opcional)
  range: string?,      // Rango numérico: "0 THRU 999" — solo si aplica
  sub:   string?,      // Subtipo COBOL: "PIC X(10)" — solo vocab-items
  body:  string,       // Descripción (obligatorio)
  warn:  string?       // Advertencia en amber — solo si hay riesgo
}
```

#### Dos fuentes de datos

| Fuente | Dónde se define | Cuándo usar |
|--------|----------------|-------------|
| `MINFO` | JS inline, objeto literal | Nodos del flowchart Mermaid (`.node` SVG) |
| `VOCAB_EXTRA` | JS inline, mergeado con `buildVocab()` | Términos en diagramas sin card DOM |
| `.vocab-item` DOM | HTML cards en sección Vocabulario | Términos con card visible — `buildVocab()` los lee |

`buildVocab()` fusiona los `.vocab-item` del DOM con `VOCAB_EXTRA` (VOCAB_EXTRA tiene prioridad si hay colisión de clave).

#### Render canónico del tooltip (ambas funciones)

```javascript
const renderTip = info =>
  `<div class="mtt-title">${info.title}</div>` +
  (info.rule  ? `<div class="mtt-rule">${info.rule}</div>`      : '') +
  (info.range ? `<div class="mtt-range">${info.range}</div>`    : '') +
  (info.sub   ? `<div class="mtt-sub">${info.sub}</div>`        : '') +
  `<div class="mtt-body">${info.body}</div>` +
  (info.warn  ? `<div class="mtt-warn">⚠ ${info.warn}</div>`   : '');
```

**Multi-match:** cuando un elemento SVG contiene varios términos del vocab, se muestran todos apilados separados por `<hr class="mmtip-sep">`.

#### Posicionamiento del tooltip

```javascript
mmtip.style.left = Math.min(e.clientX + 14, innerWidth - 295) + 'px';
mmtip.style.top  = (e.clientY + 12) + 'px';
// max-width del #mmtip: 280px
```

#### `bindMermaidHovers()` — flowchart nodes

- Selector: `.mermaid-wrap svg .node`
- Match: `node.textContent.trim().toUpperCase().includes(KEY)`
- Delay de inicio: `setTimeout(bindMermaidHovers, 400)` en `load`

#### `bindVocabHovers()` — todos los SVGs (flowchart + secuencia)

- Espera `svgs.length >= 2` (ambos diagramas renderizados); reintentos cada 300ms, máx 20
- Selector: `'text,tspan,foreignObject span,foreignObject div,foreignObject p,.label,.messageText span'`
- Filtra elementos con hijos (evita contenedores padre): `if(el.children.length && el.tagName!=='tspan') return`
- Dedup por elemento: `if(el._vb) return; el._vb = true`
- Delay de inicio: `setTimeout(bindVocabHovers, 500)` en `load`

---

### Clases CSS canónicas reutilizables (todas en el `<style>` del archivo)

| Clase | Uso |
|-------|-----|
| `.breadcrumb-current` | Último segmento del breadcrumb (negrita, color txt) |
| `.mmtip-sep` | Separador `<hr>` dentro del tooltip multi-match |
| `.rule-tag-critico` | Badge de severidad CRÍTICO en rule-meta |
| `.ctx-intro` | Párrafo introductorio de contexto (12px, #a0c8d8) |
| `.slot-label` | Etiqueta de sección sobre diagramas de slots |
| `.slot-desc` | Texto descriptivo dentro de un slot (9px, muted) |
| `.slot-overflow-desc` | Texto de overflow en slot (9px, #ff6b6b) |
| `.chain-detail` | Panel de detalle en chain-box (10px, muted, min-width 140px) |
| `.hl-s151` | Texto highlight color S151/sky (`var(--on2)`) |

**Regla:** ningún `style=""` inline en el HTML. Todo va a clases en el `<style>` del mismo archivo.

---

### `@keyframes` — restricciones

- No usar `box-shadow` dentro de `@keyframes` (trigger Paint — hint de performance).
- Usar `outline` o `border-color` para animaciones de pulso.

---

### Mermaid — configuración estándar

```javascript
mermaid.initialize({
  startOnLoad: true,
  theme: 'dark',
  themeVariables: {
    primaryColor:     '#0e2e3a',
    primaryTextColor: '#F0F8FA',
    primaryBorderColor: '#1E8FA0',   // teal para ORC/GL/REC
    // '#C1272D' para flows de capacidades S500 puras (PAY)
    lineColor:   '#6CC5D8',
    background:  '#071c23',
    mainBkg:     '#0e2e3a',
    nodeBorder:  '#1a4555'
  }
});
```

`primaryBorderColor` varía por capacidad: `#C1272D` (S500) · `#6CC5D8` (S151) · `#1E8FA0` (S500+S151).

---

## Resumen de Arquitectura de Presentación

| Vista | Tipo de layout | Visualización principal | Datos externos |
|-------|---------------|------------------------|----------------|
| `index` | Single-page scroll | Cards de navegación | — |
| `chord-gemcog` | Header + chart | D3 Chord diagram | — (inline) |
| `flow-gemcog` | 2 paneles 100vh | Árbol de control monospace | journeys JSON |
| `evolution-gemcog` | 2 paneles 100vh | D3 Area chart | `evolution-data-gemcog.json` |
| `generations-gemcog` | Scroll con aurora | SVG charts + tablas | — (inline) |
| `journeys-gemcog` | 3 paneles 100vh | Lista + secuencia steps | `journeys-data.json` |
| `component-map-gemcog` | 2 paneles 100vh | D3 Force-directed graph | `dependency-graph-s{500,151}.json` |
| `lexical-evolution-gemcog` | Scroll | Line chart + Gantt + chips | `souls-s{500,151}.json`, `vocab-s{500,151}.json` |
| `quality-gemcog` | Scroll | Factor bars + Radar SVG + tablas | — (inline) |
| `modelo-er` | Scroll horizontal | Canvas posicionado + SVG paths | — (inline) |
| `rules-report-gemcog` | 100vh tabla filtrable | Tabla sorteable + filtros | — (inline) |
| `modelo-capacidades` | Scroll + side panel | Matriz de celdas + slide panel | — (inline) |
| `flows/t-pay-001` | Scroll, max 1100px | Mermaid flowchart + sequence | — (inline) |
| `flows/t-pay-002` | Scroll, max 1100px | Mermaid sequence | — (inline) |
| `flows/t-orc-001` | Scroll, max 1100px | Mermaid flowchart + sequence + risk table | — (inline) |
| `flows/t-orc-002` | Scroll, max 1100px | Mermaid flowchart + sequence + slot diagram | — (inline) |
