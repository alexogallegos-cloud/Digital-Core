# Design Studio — MONEX Grupo Financiero

Sistema de diseño canónico para todos los portales HTML del proyecto MONEX.
Todo portal generado (`generators/build-*.py`) consume estos activos. Nunca hardcodear colores en un generador.

## Estructura canónica

```
design-studio/
├── DESIGN-STUDIO.md          ← esta guía
├── palette/
│   └── monex-palette.json    ← tokens de color canónicos (fuente de verdad de la paleta)
├── logos/                    ← logotipos (dejar los archivos aquí; ver logos/README.md)
│   ├── monex-logo-white.png  ← blanco, para fondos oscuros (hero)
│   └── monex-logo.png        ← color, para fondos claros
├── templates/
│   └── monex-theme.css       ← CSS canónico embebido por los portales
└── fonts/                    ← tipografías vía CDN (Inter, JetBrains Mono)
```

## Paleta de Colores

Fuente de verdad: `palette/monex-palette.json`. Espejo en tokens CSS de `templates/monex-theme.css`.

| Token | Hex | Uso |
|-------|-----|-----|
| `--a` | `#0B1D46` | Navy primario — header, fondos oscuros, texto de marca |
| `--s` | `#00AEEF` | Cyan "Banca Digital" — acentos, CTAs, highlights |
| `--bg` | `#F5F7FA` | Fondo neutro |
| `--text` | `#1A1A2E` | Texto principal |
| `--muted` | `#6B7280` | Texto secundario |
| `--border` | `#E5E7EB` | Bordes y separadores |
| `--success` | `#10B981` | Estados COVERED / CONFIRMED |
| `--warning` | `#F59E0B` | Estados PARTIAL / en progreso |
| `--danger` | `#EF4444` | Estados NOT_COVERED / gap |

Escalas de marca (tints) en `palette/monex-palette.json`: navy 600-900, cyan 100-600, gradiente de hero.

## Tipografía

- **Headers**: Inter Bold
- **Body**: Inter Regular
- **Monospace**: JetBrains Mono (código, IDs)

Se cargan por CDN de Google Fonts; no requieren archivos locales en `fonts/`.

## Logo

Ver `logos/README.md`. El generador embebe el logo en base64 al construir el portal;
preferencia sobre fondo navy: `monex-logo-white.png`.

## Templates

- `templates/monex-theme.css` — CSS canónico. Los generadores lo leen y lo embeben en un bloque `<style>`
  (sin estilos inline por elemento). Cualquier ajuste visual va al CSS o al generador, nunca al HTML de salida.

---

*Paleta extraída de monex.com.mx · Estructura canónica v1.0 · 2026-09-22*
