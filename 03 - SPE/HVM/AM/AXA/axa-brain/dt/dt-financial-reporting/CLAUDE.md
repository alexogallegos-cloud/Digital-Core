# dt-financial-reporting — Digital Twin · Resultado Técnico y Reporting
> Cubre la consolidación del resultado técnico y su reporte interno y al regulador.

---

## PROPÓSITO

Responde: **¿Cómo se consolida el resultado técnico de AXA México, en qué sistemas vive, y cómo se integra con el reporting al regulador?**

---

## SISTEMAS INVOLUCRADOS (HOY)

| Función | Sistema | Estado |
|---------|---------|--------|
| Analytics / BI gestión | Power BI | CONFIRMED-NAME |
| Reporting operativo | Monitor (tentativo) | PARTIAL |
| Datawarehouse | Por confirmar | SCAFFOLD |
| Contabilidad / resultado | Por confirmar | SCAFFOLD |
| Reporte CNSF financiero | Por confirmar | SCAFFOLD |
| Reporte AXA Group | Por confirmar | SCAFFOLD |

---

## GAP PRINCIPAL

Power BI está confirmado para consulta de siniestralidad histórica. El camino completo
(transacciones → DW → Power BI → resultado técnico) no está mapeado. Sin datawarehouse
confirmado, no es claro cómo se consolidan primas, siniestros y gastos para el reporting
interno y para AXA Group.

---

## ESTRUCTURA DE CAPAS

```
dt-financial-reporting/
├── CLAUDE.md         ← este archivo
├── as-is.md          ← HOY: Power BI + Monitor (tentativo)
├── gaps.md           ← GAP: DW por confirmar, cadena datos fragmentada
└── to-be.md          ← MAÑANA: reporting integrado IFRS 17 + AXA Group
```

---

## ESCENARIOS MAÑANA

1. **Data pipeline documentado**: mapear cómo llegan los datos a Power BI (fuentes, frecuencia, calidad)
2. **Datawarehouse consolidado**: single source of truth para primas, siniestros, gastos
3. **IFRS 17 reporting**: integración contable con disclosure compliant

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold*