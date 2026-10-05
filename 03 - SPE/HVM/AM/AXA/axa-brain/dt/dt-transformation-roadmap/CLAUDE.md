# dt-transformation-roadmap — Digital Twin · Hoja de Ruta de Transformación
> DT de transformación — depende de dt-gap-analysis para su contenido.
> Define las olas de transformación con quick wins, decisiones estratégicas y transformación profunda.

---

## PROPÓSITO

Responde: **¿En qué orden debe AXA México invertir en transformación tecnológica de su negocio P&C Comercial, con qué secuencia de olas, y cuáles son los trade-offs de cada decisión?**

Este DT es el output final del brain como asesor de transformación: integra gaps, capacidades ETB,
contexto de mercado e inteligencia competitiva para proponer un roadmap defendible.

---

## DEPENDENCIAS

| Fuente | Qué aporta |
|--------|-----------|
| `dt-gap-analysis/gap-matrix.md` | Lista de brechas priorizadas |
| `dt-gap-analysis/opportunities.md` | Oportunidades por impacto × esfuerzo |
| `dt-inteligencia-mercado/market-intelligence.md` | Contexto de mercado y presión competitiva |
| `dt-inteligencia-mercado/regulatory-signals.md` | Señales regulatorias con fechas |
| `axa-brain.db → systems` | Estado actual de sistemas (confirmed / partial / scaffold) |

---

## ESTRUCTURA DE OLAS

### Ola 1 — Quick Wins (0-12 meses)
Intervenciones de alto impacto / bajo esfuerzo que no requieren reemplazar sistemas.
Candidatos pre-análisis:
- Digitalizar HSD: mover cálculo técnico de Excel a herramienta web integrada con Vector
- Integrar ERN → sistema de cotización: API de resultados catastróficos sin copia manual
- Portal agentes básico: visibilidad de folios Vector sin nueva infraestructura

### Ola 2 — Decisiones Estratégicas (12-24 meses)
Decisiones que requieren inversión significativa y definen la arquitectura target.
Candidatos pre-análisis:
- Integrar Vector ↔ General Daños: eliminar recaptura manual de condiciones aprobadas
- SAFAC extendido o reemplazado: decisión build vs buy en reaseguro facultativo
- Datawarehouse consolidado: single source of truth para primas, siniestros, gastos

### Ola 3 — Transformación Profunda (24-48 meses)
Cambios estructurales que redefinen el modelo operativo.
Candidatos pre-análisis:
- Plataforma de suscripción digital end-to-end (sustitución de HSD + integración total)
- Portal agentes self-service con underwriting automático para riesgos estándar
- Reporting regulatorio automatizado (CNSF + IFRS 17 + AXA Group)

---

## ESTRUCTURA DE ARCHIVOS

```
dt-transformation-roadmap/
├── CLAUDE.md          ← este archivo
├── roadmap.md         ← GENERADO: olas con iniciativas, secuencia y dependencias
├── ola-1-quickwins.md ← detalle de quick wins: impacto, esfuerzo, owner, timeline
├── ola-2-strategic.md ← detalle de decisiones estratégicas con alternativas y trade-offs
└── ola-3-deep.md      ← detalle de transformación profunda con visión TO-BE
```

---

## CÓMO GENERAR EL CONTENIDO

```bash
# Desde AXA/axa-brain/
python generators/build-transformation-roadmap.py
```

Requiere que `dt-gap-analysis/` esté poblado primero.

---

## PRINCIPIOS DEL ROADMAP

1. **Quick wins primero**: demostrar valor antes de comprometer inversión transformacional
2. **No big-bang**: cada ola es independiente y entrega valor por sí sola
3. **Regulatorio como restricción, no como iniciativa**: IFRS 17 y Solvencia C son fechas fijas
4. **HSD como señal, no como destino**: el Excel no es el problema; la falta de integración lo es
5. **Cada ola financia la siguiente**: los ahorros de Ola 1 justifican la inversión de Ola 2

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold — requiere build-gap-analysis.py primero*