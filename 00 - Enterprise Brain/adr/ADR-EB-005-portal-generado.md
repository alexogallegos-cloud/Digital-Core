# ADR-EB-005 — Portal HTML generado siempre desde build-portal.py

**Estado**: APROBADO
**Fecha**: 2026-09-29
**Autores**: alejandro.gallegos@accenture.com
**Contexto**: Gestión y generación de los archivos HTML del portal del Enterprise Brain

---

## Contexto

Cada deployment del Enterprise Brain incluye un `portal/` con archivos HTML que permiten al equipo de modernización navegar el brain: KPIs, dominios, almas, reglas de negocio, quality gates. Estos archivos necesitan reflejar el estado actual del brain.db en todo momento.

La pregunta es: ¿se editan los HTML directamente o se generan desde el brain.db?

---

## Decisión

**Los archivos `portal/*.html` nunca se editan a mano**. Son siempre generados por `generators/build-portal.py` a partir del brain.db activo.

```bash
# Comando canónico de regeneración:
python generators/build-portal.py --system informix --db digital-brain/brain.db --out portal/index.html
```

Cualquier cambio de presentación (estilo, layout, nuevas secciones) se hace en `build-portal.py` — nunca en el HTML generado.

---

## Razones

1. **brain.db es la única fuente de verdad**: si el HTML puede divergir del brain.db, hay dos fuentes de verdad. El equipo de modernización no sabe cuál creer.
2. **Los cambios en el brain no se reflejan automáticamente**: si se edita el HTML a mano y luego se rebuilda el brain, el regenerador sobrescribe los cambios manuales — se pierden.
3. **Consistencia entre sistemas**: todos los portales del mismo cliente tienen el mismo layout y las mismas secciones — generados por el mismo script. Sin edición manual no hay divergencia entre portales.
4. **Trazabilidad**: `git log -- portal/` muestra exactamente cuándo se regeneró cada portal y qué build lo produjo. Con edición manual, el historial mezcla datos con presentación.
5. **Refuerza la invariante del Gemelo Cognitivo**: el brain no es un documento — es un sistema vivo. Los documentos (HTML) son proyecciones del sistema, no el sistema mismo.

---

## Consecuencias

- El script `generators/build-portal.py` es un artefacto de primera clase — se versiona, se mantiene, se prueba.
- Agregar una nueva sección al portal (ej. "Pipeline diagram") = agregar la sección al script, no al HTML.
- El portal se regenera en cada RELEASE y en cada ITERATE con cambios significativos.
- Los archivos `portal/*.html` **sí se commitean al repositorio** (a diferencia del brain.db) — son el artefacto de presentación para el equipo. Pero solo se editan vía el generador.

---

## Excepción documentada

Si existe un `portal/*.html` hand-authored previo a este ADR (ej. portales creados antes del Enterprise Brain asset), se conserva con nombre `portal/{nombre}-legacy.html` hasta ser reemplazado por el generador. No se modifica — se reemplaza.

---

## Alternativas rechazadas

| Alternativa | Por qué se rechazó |
|-------------|-------------------|
| Edición manual del HTML | Divergencia inevitable entre brain.db y portal. Pérdida de cambios al regenerar. |
| Jupyter notebook como portal | No es navegable sin Jupyter instalado. No es compartible como URL estática. |
| Dashboard en Streamlit / Grafana | Requiere servidor levantado. El portal estático se sirve con `python -m http.server`. |
| Plantilla HTML con variables JS que leen brain.db directamente | browser no puede abrir SQLite directamente. Requiere backend. |

---

*ADR-EB-005 · Enterprise Brain · Digital Core · Accenture México · 2026-09-29*
