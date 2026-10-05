# Quick Wins — AXA México P&C · Ola 1
> Generado: 2026-09-03
> Intervenciones de alto impacto / bajo esfuerzo · 0-12 meses

---

Las 5 intervenciones con mejor ratio impacto/esfuerzo identificadas desde el brain:

## QW-1 · API ERN → cotización (1-2 meses)

**Problema**: Los resultados de modelación catastrófica de ERN se copian manualmente al HSD.
**Acción**: Crear una API (o exportación estructurada) de ERN que alimente directamente
la herramienta de cotización técnica.
**Impacto**: Elimina transcripción manual de PML, velocidad y exactitud en Property/RT.
**Prerequisito**: Acceso técnico a ERN para evaluar capacidad de integración.

## QW-2 · SAFAC — carga masiva de capas (1-3 meses)

**Problema**: SAFAC solo soporta estructura lineal de reaseguro.
**Acción**: Evaluar si SAFAC tiene funcionalidad de carga masiva no utilizada;
si no, implementar importación desde Excel de capas/reaseguradores.
**Impacto**: Reduce tiempo de registro de colocaciones complejas.
**Prerequisito**: Sesión con el equipo de reaseguro + proveedor de SAFAC.

## QW-3 · Confirmar Monitor (2-4 semanas)

**Problema**: Monitor aparece en el proceso de suscripción pero su rol exacto no está confirmado.
**Acción**: Entrevista con el equipo de reporting para confirmar si Monitor es:
(a) herramienta de reporting CNSF, (b) monitoreo de cartera, o (c) ambas.
**Impacto**: Desbloquea dt-regulatory-solvency y dt-financial-reporting.
**Prerequisito**: Acceso al equipo de control de gestión / finanzas.

## QW-4 · Visibilidad de folios para agentes (3-6 meses)

**Problema**: Los agentes y corredores no tienen visibilidad del estado de sus casos en Vector.
**Acción**: Exponer una vista de solo lectura de folios Vector por conducto,
sin requerir un portal nuevo completo (puede ser un reporte/email automático).
**Impacto**: Reduce llamadas/correos de seguimiento; mejora relación con intermediarios.
**Prerequisito**: Confirmar si Vector tiene API o capacidad de exportación/notificación.

## QW-5 · Diagnóstico HSD — roadmap de digitalización (4-8 semanas)

**Problema**: La HSD (Hoja de Suscripción de Daños) es el gap más crítico del proceso
de suscripción. Antes de decidir cómo reemplazarla, se necesita un diagnóstico completo.
**Acción**: Taller con los suscriptores para mapear todas las variantes del HSD por LoB,
identificar campos críticos vs redundantes, y proponer alternativas (configurador web,
Python/Streamlit, integración con Vector, módulo en plataforma de suscripción).
**Impacto**: Define la decisión de inversión más importante del programa.
**Prerequisito**: Disponibilidad de suscriptores por LoB (Property, RT, RC mínimo).

---

## Matriz Resumen

| # | Quick Win | Esfuerzo | Tiempo | Impacto | Prerequisito |
|---|-----------|----------|--------|---------|--------------|
| QW-1 | API ERN → cotización | Bajo | 1-2 meses | Alto | Acceso técnico ERN |
| QW-2 | SAFAC carga masiva | Bajo | 1-3 meses | Medio | Sesión reaseguro |
| QW-3 | Confirmar Monitor | Muy bajo | 2-4 semanas | Alto (desbloqueador) | Entrevista reporting |
| QW-4 | Visibilidad folios agentes | Medio | 3-6 meses | Alto | API/export Vector |
| QW-5 | Diagnóstico HSD | Bajo | 4-8 semanas | Muy alto (decisión clave) | Suscriptores disponibles |

---

*Generado por build-gap-analysis.py el 2026-09-03*