# dt-gap-analysis — Digital Twin · Análisis de Brechas y Oportunidades
> DT de transformación — generado desde axa-brain.db (pain_points + etb_capabilities + process_steps)
> Este DT es el motor de priorización de la transformación. No documenta AS-IS: razona sobre brechas.

---

## PROPÓSITO

Responde: **¿Dónde están las brechas más críticas entre el estado actual y las capacidades que debería tener AXA México según ETB, y en qué orden atacarlas?**

Es el DT que da al brain sus "facultades de transformación": cruza pain points reales con capacidades
ETB faltantes y genera una lista priorizada de oportunidades de inversión.

---

## FUENTES DE DATOS (todas en axa-brain.db)

| Tabla | Registros | Aporte al gap analysis |
|-------|-----------|------------------------|
| `pain_points` | 33 | Síntomas reales organizados en 7 categorías con causa raíz 5D |
| `etb_capabilities` | 104 | Catálogo de capacidades que debería existir (Insurance P&C v3.0) |
| `process_steps` | 541 | Pasos del proceso actual — revela qué se hace manualmente vs en sistema |
| `systems` | 16 | Estado de cada sistema (confirmed / partial / scaffold) |

---

## ESTRUCTURA DE CAPAS

```
dt-gap-analysis/
├── CLAUDE.md          ← este archivo
├── gap-matrix.md      ← GENERADO: cruce pain_points × ETB capabilities (ejecutar generador)
├── opportunities.md   ← GENERADO: oportunidades priorizadas por impacto × esfuerzo
└── quick-wins.md      ← GENERADO: 5-7 intervenciones de alto impacto / bajo esfuerzo
```

---

## CÓMO GENERAR EL CONTENIDO

```bash
# Desde AXA/axa-brain/
python generators/build-gap-analysis.py
```

El generador lee brain.db y produce los 3 archivos MD. Ejecutar después de cada actualización
de pain_points o process_steps.

---

## LÓGICA DE PRIORIZACIÓN

Un gap tiene alta prioridad cuando cumple 3+ de estos criterios:
1. Aparece en múltiples pain points (frecuencia alta)
2. Afecta múltiples LoBs (amplitud alta)
3. Tiene causa tecnológica confirmada (no organizacional o de negocio)
4. El pain point tiene flag `manualidad=1` (intervención manual = automatizable)
5. La capacidad ETB correspondiente tiene sistema AXA scaffold o ausente

---

## GAPS CONOCIDOS SIN GENERAR ANÁLISIS (pre-análisis)

1. **HSD como herramienta crítica**: cálculo técnico en Excel → sin sistema (ETB: 6.3.2 Risk Assessment)
2. **Información dispersa**: 8 pain points en categoría "Información dispersa y herramientas no conectadas"
3. **Sin portal de agentes confirmado**: canal de distribución sin sistema (ETB: Distribution Management)
4. **ERN → HSD manual**: transferencia de resultados catastrófico → cotización sin API
5. **SAFAC estructura lineal**: sin carga masiva de capas (ETB: Reinsurance Management)

---

*Última actualización: 2026-09-03 · v1.0 · Generador pendiente de crear (build-gap-analysis.py)*