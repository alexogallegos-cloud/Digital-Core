# DT — Nómina Interbancaria (Art. 81 Bis 1 y 81 Bis 2)
> **Proyecto:** CAN · BanCoppel
> **Versión:** 0.1.0 · `[STATE: ACTIVE]`

## Propósito

Extrae y estructura los artículos 81 Bis 1 y 81 Bis 2 de la Circular 3/2012 Banxico
(páginas 111+ del compilado Circular 6/2025), que regulan el Servicio de Nómina
Interbancaria — el mecanismo de portabilidad de nómina entre instituciones. Complementa
dt-normativa-can con las obligaciones de portabilidad que no están en el bloque
Art. 63 Bis.

## SMEs Heredados

| SME | Rol |
|-----|-----|
| Regulatory/Banxico | Interpretación de Art. 81 Bis 1 y 81 Bis 2: alcance, obligaciones, plazos |
| Industry Banking | Contexto del producto Servicio de Nómina Interbancaria: portabilidad, acuerdos patrón-banco |
| Industry Payments → SPEI | Mecanismo de transferencia interbancaria de Prestaciones Laborales (OBL-023 y su extensión interbancaria) |

## Inputs Esperados

1. `source/docs/regulacion/Circular 3-2012 CAN Compilado 6-2025.pdf` — páginas 111 en adelante (Art. 81 Bis 1 y 81 Bis 2)
2. `knowledge-base/regulacion/obligaciones-can.md` — contexto de OBL-023 (transferencia Prestaciones Laborales)
3. `knowledge-base/regulacion/glosario-can.md` — definiciones de Institución Ordenante, Institución Receptora

## Outputs

| Artefacto | Ruta |
|-----------|------|
| Obligaciones Nómina Interbancaria | `knowledge-base/regulacion/obligaciones-nomina-interbancaria.md` |
| Glosario extendido | Actualización de `knowledge-base/regulacion/glosario-can.md` |
| Actualización brain.db | Filas adicionales en `regulatory_obligations` (OBL-024 en adelante) |

## Metodología

1. Leer páginas 111+ de la Circular 3/2012 compilado — localizar Art. 81 Bis 1 y 81 Bis 2
2. Extraer: definición del Servicio de Nómina Interbancaria, obligaciones de la Institución Ordenante, obligaciones de la Institución Receptora, plazos, condiciones de portabilidad
3. Identificar si BanCoppel aplica como Institución Ordenante, Receptora o ambas
4. Cruzar con OBL-023 (transferencia Prestaciones Laborales mismo DHB) — ¿extiende esa obligación?
5. Determinar si `bdiadminnomina` y `bdispei` están en scope de Art. 81 Bis 1 y 81 Bis 2

## Preguntas Clave a Responder

- ¿Cuál es el plazo para ejecutar la portabilidad de nómina interbancaria?
- ¿Qué información debe intercambiar BanCoppel (como Institución Ordenante/Receptora)?
- ¿Hay obligaciones adicionales de reporte a Banxico por la portabilidad de nómina?
- ¿Art. 81 Bis 1 y 81 Bis 2 crean obligaciones nuevas para `bdispei` más allá de OBL-006?

## Dependencias

- `[DEPENDS-ON: dt-normativa-can]` — contexto de OBL-023 y arquitectura de obligaciones CAN
- `[FEEDS: dt-impacto-sistemas]` — si hay impacto en bdispei o procesos de portabilidad en bdiadminnomina
- `[FEEDS: dt-brecha-compliance]` — nuevas brechas si Art. 81 Bis 1/2 generan obligaciones aún no cubiertas

## Estado

`[DATO-REQUERIDO]` — Pendiente extracción de páginas 111+ de `source/docs/regulacion/Circular 3-2012 CAN Compilado 6-2025.pdf`.

*v0.1.0 · 2026-09-17*
