# Design Studio — BanCoppel Digital Brain
> Sistema de diseño canónico para todos los portales HTML del Digital Brain de BanCoppel.
> Versión 1.0 · 2026-08-13

---

## Por qué existe este Design Studio

Cada sistema analizado (Informix, AppMovil, y los que vengan) genera un portal HTML de análisis. Sin un sistema de diseño centralizado, el CSS se copia manualmente entre portales y diverge con el tiempo. Este Design Studio define la fuente de verdad del look-and-feel, los tokens de diseño y los componentes reutilizables para que todos los portales sean visualmente coherentes.

---

## Portales existentes

| Sistema | Ruta | Páginas | Estado |
|---------|------|---------|--------|
| Informix (core) | `systems/core/Informix/portal/` | 30+ páginas | Activo |
| AppMovil (canal) | `systems/channels/AppMovil/portal/` | 3 páginas | Activo |
| *(próximo sistema)* | `systems/{type}/{name}/portal/` | — | Plantilla disponible |

---

## Tokens CSS

Todos los portales deben declarar estos tokens en `:root`. No alterar los valores — son los colores de marca de BanCoppel y los tokens de la capa glass.

```css
:root {
  /* Paleta BanCoppel */
  --blue:    #3D5FCD;   /* Azul medio — gradientes y acentos */
  --blued:   #122FB1;   /* Azul principal de marca BanCoppel */
  --bluedd:  #0d2185;   /* Azul profundo — sombras y fondos */
  --yellow:  #F0D224;   /* Amarillo señal — CTAs, badges, acentos */

  /* Tipografía */
  --ink:     #F4F6FF;   /* Texto principal */
  --muted:   #aab3d4;   /* Texto secundario */
  --muted2:  #818ab0;   /* Texto terciario / labels */

  /* Glassmorphism */
  --glass:   rgba(255,255,255,.055);  /* Fondo de tarjetas */
  --glassb:  rgba(255,255,255,.10);   /* Borde de tarjetas */
}

/* Fondo base */
body { background: #060a1a; }
```

---

## Componentes del sistema

### Aurora (fondo animado)

Presente en todas las páginas. Tres blobs radiales animados que dan profundidad al fondo oscuro. Nunca modificar las animaciones ni los colores de los blobs.

```html
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
```

```css
.aurora { position: fixed; inset: 0; z-index: -2; overflow: hidden; }
.aurora::before, .aurora::after, .aurora .blob {
  content: ""; position: absolute; border-radius: 50%; filter: blur(90px);
}
/* blob azul izquierdo, blob azul derecho, blob amarillo inferior */
.grain { position: fixed; inset: 0; z-index: -1; opacity: .045; }
```

### Barra de progreso de scroll

```html
<div id="prog"></div>
```

```css
#prog { position: fixed; top: 0; left: 0; height: 3px; width: 0; z-index: 100;
  background: linear-gradient(90deg, var(--yellow), #fff);
  box-shadow: 0 0 12px rgba(240,210,36,.6); }
```

```javascript
window.addEventListener('scroll', () => {
  const d = document.documentElement;
  document.getElementById('prog').style.width =
    (d.scrollTop / (d.scrollHeight - d.clientHeight) * 100) + '%';
});
```

### Nav fijo

Logo a la izquierda, título del sistema, espacio flexible, links de navegación a la derecha. El logo siempre usa `onerror="this.style.display='none'"` para manejar paths relativos.

```html
<nav>
  <img src="{{LOGO_PATH}}" alt="BanCoppel" onerror="this.style.display='none'">
  <span class="nt">{{SYSTEM_NAME}} · {{PAGE_TITLE}}</span>
  <span class="sp"></span>
  <a class="jump" href="#section1">Label</a>
  <a class="jump ext" href="otra-pagina.html">Página externa</a>
  <a class="back" href="index.html">← Portal</a>
</nav>
```

Las clases de links disponibles:
- `.jump` — link de sección (color muted, hover glow)
- `.jump.ext` — link a otra página del portal (color yellow)
- `.back` — botón de retorno con borde (para páginas internas)

### Glass card

Componente base de todas las tarjetas, paneles y stat boxes.

```css
.glass {
  background: var(--glass);
  backdrop-filter: blur(22px) saturate(155%);
  border: 1px solid var(--glassb);
  border-radius: 22px;
  box-shadow: 0 12px 44px rgba(0,0,0,.36), inset 0 1px 0 rgba(255,255,255,.10);
}
```

Variantes de color de borde izquierdo para estados:
```css
.crit { border-left: 3px solid #E8400A; }  /* Crítico */
.warn { border-left: 3px solid #F0D224; }  /* Advertencia */
```

### Hero section

```html
<header class="hero">
  <div class="eyebrow reveal"><span class="dot"></span> {{PROJECT_CODE}} · {{PHASE}}</div>
  <h1 class="reveal">{{TITULO_PRINCIPAL}}</h1>
  <p class="sub reveal">{{SUBTÍTULO}}</p>
  <div class="stats reveal"><!-- ver Stats Row --></div>
</header>
```

### Stats row

Siempre con `data-target` para que el contador animado funcione.

```html
<div class="stats">
  <div class="stat glass">
    <div class="statn" data-target="216">0</div>
    <div class="statl">Label en MAYÚSCULAS</div>
  </div>
  <!-- máx 5 columnas -->
</div>
```

```javascript
// Animación de contadores — copiar de template.html
const statEls = document.querySelectorAll('.statn[data-target]');
const sObs = new IntersectionObserver(entries => { /* ... */ }, { threshold: .3 });
statEls.forEach(s => sObs.observe(s));
```

### vcard (tarjeta de contenido)

Tarjeta con icono, título, descripción y call-to-action. Se usa en grids de 3 columnas.

```html
<div class="cardgrid">
  <a class="vcard glass [crit|warn]" href="{{URL}}">
    <div class="ico">{{EMOJI}}</div>
    <div>
      <div class="vtag [crit|warn]">{{TAG}}</div>
      <div class="vt">{{TÍTULO}}</div>
      <div class="vd">{{DESCRIPCIÓN — inicia con mayúscula}}</div>
      <div class="go">Ver más <span class="arr">→</span></div>
    </div>
  </a>
</div>
```

### Reveal on scroll

Agregar la clase `.reveal` a cualquier elemento para que aparezca con animación al hacer scroll.

```javascript
const revs = document.querySelectorAll('.reveal');
const rObs = new IntersectionObserver(entries => {
  entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('in'); rObs.unobserve(e.target); } });
}, { threshold: .08 });
revs.forEach(r => rObs.observe(r));
```

---

## Convención de archivos por portal

Cada sistema tiene su carpeta `portal/` con estas páginas canónicas:

| Archivo | Propósito | Template base |
|---------|-----------|---------------|
| `index.html` | Dashboard — stats, DT ecosystem, hallazgos, arquitectura | `template.html` |
| `vocabulario.html` | Catálogo de términos con búsqueda y filtros | `template-vocab.html` |
| `sp-dependencies.html` | Inventario de SPs, bases de datos, olas de migración | `template.html` (sección tabla) |
| `almas.html` | Los N microservicios/SPs más críticos del sistema | `template.html` (cardgrid) |
| `journeys.html` | Customer journeys mapeados a flujos técnicos | `template.html` (timeline) |
| `rules-catalog.html` | Catálogo de reglas de negocio | `template.html` (tabla) |
| `flow-{nombre}.html` | Vista detalle de un flujo específico | Gold standard: `t-pay-001.html` |

---

## Ruta del logo

El logo de BanCoppel está en `systems/core/Informix/bancoppel-logo.png`. La ruta relativa depende de dónde esté el portal:

| Sistema | Ruta relativa al logo |
|---------|-----------------------|
| `systems/core/Informix/portal/` | `../bancoppel-logo.png` |
| `systems/channels/AppMovil/portal/` | `../../../core/Informix/bancoppel-logo.png` |
| *(nuevo sistema en channels)* | `../../../core/Informix/bancoppel-logo.png` |
| *(nuevo sistema en core)* | `../bancoppel-logo.png` |

---

## Reglas de contenido

Estas reglas aplican a todo el HTML de los portales:

1. **Descripciones inician con mayúscula** — todo texto visible que describe algo comienza con letra capital.
2. **Sin separadores `+` ni `·` en prosa** — usar "y", coma o punto y coma.
3. **Sin emojis en prosa** — solo en el atributo `class="ico"` de las vcards.
4. **Sin comentarios de código** — el HTML debe ser autoexplicativo.
5. **Sin dependencias externas** — no CDNs, no Google Fonts, no librerías JS externas (excepción: `mermaid.min.js` local si se necesita).
6. **CSS siempre inline en `<style>`** — no archivos `.css` separados.
7. **Localhost URL siempre presentada** al usuario al generar un HTML nuevo.

---

## Cómo crear un portal para un sistema nuevo

1. Copiar `design-studio/template.html` como `systems/{type}/{name}/portal/index.html`
2. Reemplazar todos los `{{PLACEHOLDER}}` con los valores del sistema
3. Copiar `design-studio/template-vocab.html` como `portal/vocabulario.html`
4. Ajustar la ruta del logo según la tabla de rutas de arriba
5. Verificar que el servidor local sirve el directorio correcto

---

*Design Studio BanCoppel · v1.0 · 2026-08-13 · SPE-AM-001*