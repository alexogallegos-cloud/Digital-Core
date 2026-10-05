# Design Studio — Santander Digital Brain
> Sistema de diseño canónico para todos los portales HTML del Digital Brain de Santander México.
> Versión 1.0 · 2026-09-17

---

## Por qué existe este Design Studio

Cada proyecto (CAN, y los que vengan) genera portales HTML de análisis y cumplimiento. Este Design Studio define la fuente de verdad del look-and-feel, los tokens de diseño y los componentes reutilizables para que todos los portales sean visualmente coherentes y alineados a la marca Santander.

---

## Portales existentes

| Proyecto | Ruta | Páginas | Estado |
|----------|------|---------|--------|
| CAN — Cumplimiento | `projects/can/portal/` | 1 página | Activo |
| santander-brain | `santander-brain/portal/` | 1 página | Activo |
| *(próximo portal)* | `{ruta}/portal/` | — | Plantilla disponible |

---

## Identidad Visual Santander

La identidad de Santander se construye sobre tres elementos:

1. **La Llama** — símbolo icónico, rojo Santander, representa movimiento y fortaleza
2. **El Rojo** — `#EC0000` es el color primario absoluto, no tiene sustituto
3. **La tipografía limpia** — SF Pro Display / system sans-serif, sin serifas

---

## Tokens CSS

Todos los portales deben declarar estos tokens en `:root`. El rojo es el acento principal (equivalente al amarillo en BanCoppel).

```css
:root {
  /* Paleta Santander */
  --red:     #EC0000;   /* Rojo Santander — acento principal, CTAs, highlights */
  --redd:    #CC0000;   /* Rojo oscuro — hover, sombras */
  --reddd:   #9A0000;   /* Rojo profundo — fondos de aurora, sombras profundas */
  --redglow: rgba(236,0,0,.55);  /* Glow del rojo — box-shadow, dot pulse */

  /* Tipografía */
  --ink:     #FFF5F5;   /* Texto principal (blanco levemente cálido) */
  --muted:   #d4aaaa;   /* Texto secundario */
  --muted2:  #a07878;   /* Texto terciario / labels */

  /* Glassmorphism */
  --glass:   rgba(255,255,255,.055);  /* Fondo de tarjetas */
  --glassb:  rgba(255,255,255,.09);   /* Borde de tarjetas */
}

/* Fondo base — oscuro con tinte rojo muy sutil */
body { background: #0d0202; }
```

---

## Componentes del sistema

### Aurora (fondo animado)

Tres blobs radiales en tonos rojos Santander. Nunca modificar las animaciones ni los colores.

```html
<div class="aurora"><div class="blob"></div></div>
<div class="grain"></div>
```

```css
.aurora { position: fixed; inset: 0; z-index: -2; overflow: hidden; }
.aurora::before, .aurora::after, .aurora .blob {
  content: ""; position: absolute; border-radius: 50%; filter: blur(90px);
}
/* blob rojo izquierdo */
.aurora::before { background: radial-gradient(circle,rgba(200,0,0,.50),transparent 70%); }
/* blob rojo profundo derecho */
.aurora::after  { background: radial-gradient(circle,rgba(130,0,0,.55),transparent 70%); }
/* blob rojo claro inferior */
.aurora .blob   { background: radial-gradient(circle,rgba(236,0,0,.18),transparent 70%); }
```

### Barra de progreso de scroll

```css
#prog { background: linear-gradient(90deg, var(--red), #ff8888); }
```

### Nav fijo

Logo (llama + wordmark) a la izquierda, título, links a la derecha.

```html
<nav>
  <img src="{{LOGO_PATH}}" alt="Santander" onerror="this.style.display='none'">
  <span class="nt">{{SYSTEM_NAME}} · Portal</span>
  <span class="sp"></span>
  <a class="jump" href="#section1">Label</a>
  <a class="jump ext" href="otra-pagina.html">Página externa</a>
</nav>
```

Los links `.ext` usan `--red` (mismo rol que el amarillo en BanCoppel).

### Glass card

```css
.glass {
  background: var(--glass);
  backdrop-filter: blur(22px) saturate(155%);
  border: 1px solid var(--glassb);
  border-radius: 22px;
  box-shadow: 0 12px 44px rgba(0,0,0,.40), inset 0 1px 0 rgba(255,255,255,.08);
}
```

Variantes de borde izquierdo:
```css
.crit { border-left: 3px solid #E8400A; }   /* Crítico */
.warn { border-left: 3px solid var(--red); } /* Advertencia / Atención */
.ok   { border-left: 3px solid #22c55e; }   /* OK / Cumplido */
```

### Hero — gradiente de texto

En Santander el gradiente de h1 va de blanco a rojo claro (en vez de blanco a azul de BanCoppel):

```css
.hero h1 {
  background: linear-gradient(176deg, #fff 34%, #ff9999);
  -webkit-background-clip: text; background-clip: text; color: transparent;
}
```

### Dot de pulso en eyebrow

```css
.eyebrow .dot { background: var(--red); box-shadow: 0 0 12px var(--redglow); }
```

### vtag (badge de categoría)

```css
.vtag {
  background: rgba(236,0,0,.12);
  border: 1px solid rgba(236,0,0,.28);
  color: var(--red);
}
.vtag.crit { color: #E8400A; background: rgba(232,64,10,.12); border-color: rgba(232,64,10,.3); }
.vtag.ok   { color: #22c55e; background: rgba(34,197,94,.12); border-color: rgba(34,197,94,.3); }
```

### Chips / badges inline

```css
.chip.red    { border-color: rgba(236,0,0,.35); color: #ff8888; background: rgba(236,0,0,.10); }
.chip.yellow { border-color: rgba(255,180,0,.35); color: #ffd666; background: rgba(255,180,0,.09); }
.chip.green  { border-color: rgba(34,197,94,.35); color: #86efac; background: rgba(34,197,94,.09); }
```

---

## Convención de archivos por portal

| Archivo | Propósito | Template base |
|---------|-----------|---------------|
| `index.html` | Dashboard principal — stats, DTs, brechas, arquitectura | `template.html` |
| `obligaciones.html` | Catálogo de obligaciones regulatorias | `template.html` (tabla) |
| `brechas.html` | Brechas de cumplimiento con criticidad | `template.html` (cardgrid crit/warn) |
| `cecoban.html` | Especificación técnica CECOBAN — endpoints, Kafka, errores | `template.html` |
| `arquitectura.html` | Diagrama y ADRs de arquitectura de integración | `template.html` |

---

## Ruta del logo

El logo SVG de la llama está en `design-studio/logos/santander-logo.svg`. Ruta relativa desde cada portal:

| Ruta del portal | Ruta relativa al logo |
|-----------------|-----------------------|
| `projects/can/portal/` | `../../../design-studio/logos/santander-logo.svg` |
| `santander-brain/portal/` | `../../design-studio/logos/santander-logo.svg` |
| `systems/{cat}/{sys}/portal/` | `../../../../design-studio/logos/santander-logo.svg` |

---

## Reglas de contenido (idénticas a BanCoppel)

1. **Descripciones inician con mayúscula** — todo texto visible que describe algo comienza con letra capital.
2. **Sin separadores `+` ni `·` en prosa** — usar "y", coma o punto y coma.
3. **Sin emojis en prosa** — solo en el atributo `class="ico"` de las vcards.
4. **Sin comentarios de código** en el HTML final.
5. **Sin dependencias externas** — no CDNs, no Google Fonts, no librerías JS externas.
6. **CSS siempre inline en `<style>`** — no archivos `.css` separados.
7. **Localhost URL siempre presentada** al usuario al generar un HTML nuevo.
8. **`portal/*.html` nunca hand-authored** — siempre generado desde `brain.db`.

---

## Diferencias clave vs. Design Studio BanCoppel

| Elemento | BanCoppel | Santander |
|----------|-----------|-----------|
| Acento principal | `#F0D224` (amarillo) | `#EC0000` (rojo llama) |
| Fondo base | `#060a1a` (azul noche) | `#0d0202` (rojo noche) |
| Aurora | Blobs azul + amarillo | Blobs rojo oscuro + rojo claro |
| Gradiente h1 | blanco → azul | blanco → rojo claro |
| Barra de scroll | amarillo → blanco | rojo → rosa |
| Links `.ext` | amarillo | rojo |

El patrón de componentes (glass, vcard, timeline, mgrid, xrow, chips, reveal) es **idéntico** — solo cambian los tokens de color.

---

*Design Studio Santander · v1.0 · 2026-09-17 · SPE-AM-003 (Santander CAN)*
