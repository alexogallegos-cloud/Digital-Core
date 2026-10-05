# dt-reinsurance-program — Digital Twin · Programa de Reaseguro
> Cubre la cesión facultativa de riesgos de daños comerciales en AXA México.

---

## PROPÓSITO

Responde: **¿Cómo se calcula y registra la cesión de reaseguro, qué limitaciones tiene SAFAC, y cuál es el camino hacia una plataforma moderna de reaseguro?**

---

## SISTEMAS INVOLUCRADOS (HOY)

| Función | Sistema | Estado | Limitación conocida |
|---------|---------|--------|---------------------|
| Colocación facultativa | SAFAC | CONFIRMED-NAME | Solo estructura lineal; sin carga masiva de capas |
| Cálculo técnico de la cesión | HSD (Excel) | GAP CRÍTICO | Manual, sin integración con SAFAC |
| Modelación catastrófica | ERN | CONFIRMED-NAME | Resultados se trasladan manualmente |
| Reaseguradoras | Por confirmar | SCAFFOLD | Gestión de participaciones y confirmaciones |
| Reporting reaseguro | Por confirmar | SCAFFOLD | — |

---

## GAP PRINCIPAL

SAFAC es el sistema de reaseguro facultativo, pero solo soporta estructura lineal. Las colocaciones
complejas (múltiples capas, múltiples reaseguradores por capa) se gestionan fuera del sistema.
La vinculación con la HSD y con ERN es manual, lo que crea inconsistencias entre el cálculo técnico
y lo registrado en el sistema.

---

## ESTRUCTURA DE CAPAS

```
dt-reinsurance-program/
├── CLAUDE.md         ← este archivo
├── as-is.md          ← HOY: proceso facultativo con SAFAC + HSD + ERN
├── gaps.md           ← GAP: estructura lineal, sin carga masiva, sin integración
└── to-be.md          ← MAÑANA: plataforma de reaseguro integrada
```

---

## ESCENARIOS MAÑANA

1. **SAFAC extendido**: carga masiva de capas y participaciones (quick win — si SAFAC lo soporta)
2. **Integración SAFAC ↔ HSD digital**: traspaso automático de condiciones técnicas (12 meses)
3. **Plataforma reaseguro**: sustitución de SAFAC por plataforma moderna (Munich Re RI.One, etc.) (24+ meses)

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold*