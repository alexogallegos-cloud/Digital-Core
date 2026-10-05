# Design Studio — AXA México

Paleta de marca, logos y templates HTML para todos los portales del Digital Brain AXA.

---

## Paleta de Colores AXA

| Token | Hex | Uso |
|-------|-----|-----|
| `axa-blue` | `#00008F` | Primario, headers, nav, CTAs, bordes activos |
| `axa-red` | `#FF1721` | Acento, alertas, highlights, badges críticos |
| `white` | `#FFFFFF` | Fondos de contenido |
| `gray-light` | `#F5F5F5` | Fondos secundarios, filas alternadas |
| `gray-mid` | `#9B9B9B` | Texto secundario, placeholders |
| `gray-dark` | `#333333` | Texto principal |
| `axa-blue-dark` | `#00006B` | Hover sobre elementos primarios |
| `axa-blue-light` | `#E8E8F5` | Fondos de sección con tono azul suave |

---

## Logos

- `logos/axa-logo.svg` — Logo AXA oficial (por agregar)
- `logos/accenture-logo.svg` — Logo Accenture (por agregar)

---

## Templates HTML

Todos los portales HTML del proyecto deben referenciar:

```html
<link rel="stylesheet" href="../../design-studio/templates/axa-theme.css">
```

Ruta relativa desde cualquier `systems/{cat}/{sys}/portal/` o `projects/{ws}/portal/`.

---

## Reglas de Presentación

- Logo AXA siempre a la izquierda en el header. Navegación (dots + flechas) a la derecha.
- Toda descripción visible en HTML inicia con mayúscula.
- Sin emojis en contenido formal.
- Prosa humana en textos de negocio: párrafos completos, sin bullets excesivos ni flechas.
- Sin separadores `+` ni `·` en texto visible; usar "y", coma o punto y coma.
- Presentar URL localhost clickeable al generar cualquier portal HTML.

---

## Variables CSS AXA

```css
:root {
  --axa-blue:       #00008F;
  --axa-blue-dark:  #00006B;
  --axa-blue-light: #E8E8F5;
  --axa-red:        #FF1721;
  --gray-light:     #F5F5F5;
  --gray-mid:       #9B9B9B;
  --gray-dark:      #333333;
  --white:          #FFFFFF;
  --font-main:      'Inter', 'Helvetica Neue', Arial, sans-serif;
}
```