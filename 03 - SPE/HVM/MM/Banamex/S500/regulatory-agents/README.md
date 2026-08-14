# Agentes Expertos Regulatorios — S500 Banamex AIRE 2026
> Indexado: ✅ 2026-07-17 — README del proyecto/componente (contexto de conocimiento)

> Sistema S500 · Banamex · v1 · 2026-07-03

## Propósito

Estos agentes validan reglas de negocio reconstruidas por ingeniería inversa del sistema S500 contra la normativa vigente. No diseñan soluciones técnicas — emiten **veredictos normativos estructurados** que consume el detector de contradicciones cruzadas (AG-XVAL).

## Agentes activos

| Agente | Materias | Reglas asignadas | Estado |
|--------|---------|-----------------|--------|
| [SAT](SAT/CLAUDE.md) | ISR retención, IVA, FATCA/CRS | BR-015 a BR-028, BR-035 (14 reglas) | Activo |
| [CNBV](CNBV/CLAUDE.md) | Contabilidad, Art.61 LIC, PLD, Reportería | BR-002, BR-006, BR-009, BR-010, BR-012, BR-013, BR-032, BR-036, BR-037, BR-047, BR-049, BR-050, BR-053, BR-055, BR-061, BR-064, BR-068 (16 reglas) | Activo |
| [Banxico](Banxico/CLAUDE.md) | SPEI, TEF, ventanas operativas | BR-011, BR-014, BR-038, BR-039 (4 reglas) | Activo |
| [CONDUSEF](CONDUSEF/CLAUDE.md) | Transparencia, RECO, EDC, CAT | BR-028, BR-033, BR-034 (3 reglas) | Activo |
| [TESOFE](TESOFE/CLAUDE.md) | Concentración fondos federales, CUT | BR-046 (1 regla) | Activo |
| [IPAB](IPAB/CLAUDE.md) | Cuotas ordinarias, seguro depósito | Ninguna confirmada (pendiente H-09) | Condicional |

## Taxonomía de veredictos

| Veredicto | Significado |
|-----------|-------------|
| `VALIDADO` | La regla coincide con la norma vigente |
| `DRIFT` | Valor/lógica desactualizada vs. norma vigente |
| `VERIFICAR` | Requiere confirmación de vigencia — no hay respaldo en corpus |
| `BRECHA` | Falta fundamento localizable en el corpus |
| `NO_APLICA` | La regla no pertenece a la materia del agente |

## Esquema de salida (contrato AG-XVAL)

```json
{
  "br_id": "BR-025",
  "agente": "SAT",
  "en_alcance": true,
  "veredicto": "DRIFT",
  "fundamento": [
    {
      "norma": "Ley de Ingresos de la Federación 2026",
      "articulo": "Art. 21",
      "vigencia": "2026",
      "url": "https://www.diputados.gob.mx/LeyesBiblio/pdf/LIF_2026.pdf"
    }
  ],
  "discrepancia": {
    "parametro": "tasa de retención ISR sobre intereses",
    "valor_codigo": "0.50%",
    "valor_norma": "0.90%",
    "vigencia_norma": "2026"
  },
  "justificacion": "La tasa está hardcodeada en el valor histórico; la LIF 2026 la fijó en 0.90%.",
  "confianza": "ALTA",
  "recomendacion": "Parametrizar por fecha de vigencia en el forward."
}
```

El campo `discrepancia` se omite cuando el veredicto es `VALIDADO` o `NO_APLICA`.

## Reglas de operación transversales

1. **Vigencia primero.** Confirmar que la norma esté vigente antes de validar el parámetro.
2. **Nunca inventar fundamento.** Sin respaldo en corpus → `VERIFICAR` o `BRECHA`.
3. **Un veredicto por regla por agente.** AG-XVAL reconcilia cuando una regla toca dos materias.
4. **Trazabilidad obligatoria.** Todo veredicto conserva `archivo:línea` de la regla y `artículo+url` de la norma.
5. **Idioma:** español.

## Insumos relacionados

- `Crosswalk_ReglasNegocio_Normativa_S500_v1.md` — mapa completo BR→norma
- `Hallazgos_Regulatorios_S500_v1.md` — 10 hallazgos accionables
- `Especificacion_Agentes_Regulatorios_S500_v1.md` — especificación de construcción

*Creado: 2026-07-03 · Proyecto activo: Banamex S500 AIRE 2026*