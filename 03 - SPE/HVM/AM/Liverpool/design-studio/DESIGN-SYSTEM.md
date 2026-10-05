# Design Studio — Liverpool Brain
> Sistema de diseño canónico para todos los portales HTML del Liverpool Brain.
> Versión 1.0 · 2026-09-02

---

## Por qué existe este Design Studio

El Liverpool Brain (SPE-AM-003) genera portales HTML de análisis para los 20 sistemas del programa. Este Design Studio define la fuente de verdad del look-and-feel, los tokens de diseño y los componentes reutilizables para que todos los portales sean visualmente coherentes bajo la identidad de marca de El Puerto de Liverpool.

---

## Portales existentes

| Sistema | Ruta | Páginas | Estado |
|---------|------|---------|--------|
| Liverpool Brain (federated) | `liverpool-brain/portal/` | 1 página | Activo |
| SAP (core) | `systems/core/SAP/portal/` | — | Pendiente |
| Mainframe (core) | `systems/core/Mainframe/portal/` | — | Pendiente |
| Oracle PL-SQL (processors) | `systems/processors/Oracle-PL-SQL/portal/` | — | Pendiente |
| Digital-Platform (channels) | `systems/channels/Digital-Platform/portal/` | — | Pendiente |

---

## Tokens CSS

Todos los portales deben declarar estos tokens en `:root`. Representan la paleta oficial de El Puerto de Liverpool (fuente: BrandFetch, confirmado 2026-09-02).

```css
:root {
  /* Paleta El Puerto de Liverpool */
  --cerise:    #E00198;   /* Hollywood Cerise — primario de marca */
  --cerise-d:  #b5007a;   /* Cerise profundo — gradientes */
  --cerise-dd: #850059;   /* Cerise más profundo — sombras */
  --sky:       #87C3D3;   /* Half Baked — secundario azul-teal */
  --sky-l:     #96CCEE;   /* Cornflower — azul claro */
  --rose:      #DA7AB0;   /* Hopbush — rosa terciario */

  /* Tipografía */
  --ink:       #F8F0F5;   /* Blanco cálido (tinte rosa sutil) */
  --muted:     #c4a8bc;   /* Rosa-gris secundario */
  --muted2:    #9a7d92;   /* Rosa-gris terciario / labels */

  /* Glassmorphism */
  --glass:     rgba(255,255,255,.055);
  --glassb:    rgba(255,255,255,.10);
}

/* Fondo base — oscuro con undertone vino/magenta */
body { background: #0d0408; }
```

### Colores de estado

```css
--crit-color: #E8400A;   /* Crítico / muy alto riesgo */
--warn-color: #E00198;   /* Advertencia — mismo cerise primario */
--ok-color:   #87C3D3;   /* Saludable / bajo riesgo */
```

### Fuentes de referencia (sin dependencias externas)

```
font-family: 'SF Pro Display', -apple-system, BlinkMacSystemFont, 'Inter', 'Segoe UI', Calibri, sans-serif
```

---

## Componentes del sistema

### Aurora (fondo animado)

Tres blobs radiales animados que reflejan la paleta Liverpool. El blob izquierdo usa cerise, el derecho usa teal, y el inferior usa rose. Nunca modificar los colores ni las animaciones.

```css
.aurora::before { background: radial-gradient(circle, rgba(224,1,152,.55), transparent 70%); }
.aurora::after  { background: radial-gradient(circle, rgba(135,195,211,.38), transparent 70%); }
.aurora .blob   { background: radial-gradient(circle, rgba(218,122,176,.18), transparent 70%); }
```

### Barra de progreso de scroll

```css
#prog {
  background: linear-gradient(90deg, var(--cerise), #fff);
  box-shadow: 0 0 12px rgba(224,1,152,.6);
}
```

### Nav fijo

Logo izquierda, título del sistema, espacio flexible, links de navegación a la derecha.

Clases de links disponibles:
- `.jump` — link de sección (color muted, hover glow)
- `.jump.ext` — link a otra página del portal (color cerise)
- `.back` — botón de retorno con borde

### Glass card

Componente base de todas las tarjetas. El hover usa glow cerise en lugar de amarillo.

```css
.vcard:hover {
  border-color: rgba(224,1,152,.42);
  box-shadow: 0 22px 56px rgba(0,0,0,.5);
}
```

### Variantes de borde de estado

```css
.vcard.crit { border-left: 3px solid #E8400A; }
.vcard.warn { border-left: 3px solid var(--cerise); }
.vcard.ok   { border-left: 3px solid var(--sky); }
```

### Chips / badges

```css
.chip.cerise { border-color: rgba(224,1,152,.35); color: var(--cerise); background: rgba(224,1,152,.09); }
.chip.sky    { border-color: rgba(135,195,211,.35); color: var(--sky); background: rgba(135,195,211,.09); }
.chip.rose   { border-color: rgba(218,122,176,.35); color: var(--rose); background: rgba(218,122,176,.09); }
```

---

## Convención de archivos por portal

Cada sistema tiene su carpeta `portal/` con estas páginas canónicas:

| Archivo | Propósito | Template base |
|---------|-----------|---------------|
| `index.html` | Dashboard — stats, dominios, DTs, arquitectura | `template.html` |
| `capabilities.html` | Mapa de capacidades RTL/FSV | `template.html` (grid) |
| `components.html` | Inventario de componentes del sistema | `template.html` (tabla) |
| `flow-{nombre}.html` | Vista detalle de un flujo específico | Gold standard: flow detail |

---

## Regla de generación

**REGLA**: `portal/*.html` NUNCA se edita a mano. El generador canónico es `generators/build-portal.py`. El brain.db es la fuente de verdad.

```bash
# Regenerar portal del Liverpool Brain
cd liverpool-brain
python generators/build-portal.py
```

---

## Ruta del logo

El logo de Liverpool se coloca en `design-studio/logos/Liverpool_logo.png`. Ruta relativa desde cada portal:

| Portal | Ruta relativa al logo |
|--------|-----------------------|
| `liverpool-brain/portal/` | `../../design-studio/logos/liverpool-logo.png` |
| `systems/core/SAP/portal/` | `../../../../design-studio/logos/liverpool-logo.png` |
| `systems/channels/Digital-Platform/portal/` | `../../../../design-studio/logos/liverpool-logo.png` |

---

## Reglas de contenido

Las mismas que rigen el ecosistema BanCoppel:

1. **Descripciones inician con mayúscula** — todo texto visible comienza con letra capital.
2. **Sin separadores `+` ni `·` en prosa** — usar "y", coma o punto y coma.
3. **Sin emojis en prosa** — solo en el atributo `class="ico"` de las vcards.
4. **Sin comentarios de código** en el HTML generado.
5. **Sin dependencias externas** — no CDNs, no Google Fonts, no librerías JS externas.
6. **CSS siempre inline en `<style>`** — no archivos `.css` separados.
7. **Sin nombres de clientes reales** en artefactos compartibles — usar nombre genérico de marca.
8. **Localhost URL siempre presentada** al usuario al generar un HTML nuevo.

---

*Design Studio Liverpool Brain · v1.0 · 2026-09-02 · SPE-AM-003*