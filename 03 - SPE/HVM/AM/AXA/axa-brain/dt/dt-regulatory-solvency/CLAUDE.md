# dt-regulatory-solvency — Digital Twin · Regulatorio y Solvencia
> Cubre los sistemas que alimentan el cálculo de reservas técnicas, Solvencia C e IFRS 17 para CNSF.

---

## PROPÓSITO

Responde: **¿Qué sistemas alimentan los reportes regulatorios de AXA México, cuáles están por confirmar, y cómo debe verse la cadena regulatoria TO-BE?**

---

## SISTEMAS INVOLUCRADOS (HOY)

| Función regulatoria | Sistema | Estado |
|--------------------|---------|--------|
| Modelación catastrófica (Solvencia C) | ERN | CONFIRMED-NAME |
| Reporting / consulta | Monitor (tentativo) | PARTIAL — rol exacto por confirmar |
| Reservas técnicas | Por confirmar | SCAFFOLD |
| Cálculo Solvencia C | Por confirmar | SCAFFOLD |
| IFRS 17 (contabilidad) | Por confirmar | SCAFFOLD |
| Reporte CNSF (Boletín Estadístico) | Por confirmar | SCAFFOLD |
| CONDUSEF (reclamaciones) | Por confirmar | SCAFFOLD |

---

## GAP PRINCIPAL

La cadena regulatoria no está mapeada. Se conoce ERN para catástrofes y Monitor como probable
herramienta de reporte, pero los sistemas de reservas técnicas, Solvencia C y IFRS 17 están
por confirmar. Sin este mapa, el brain no puede razonar sobre el impacto regulatorio de los
cambios tecnológicos.

---

## DATO-REQUERIDO

- Confirmar rol de Monitor: ¿es la herramienta de reporting CNSF o solo monitoreo de cartera?
- Nombre del sistema de reservas técnicas
- Herramienta de cálculo de Solvencia C
- Estado de implementación IFRS 17 en AXA México

---

## ESTRUCTURA DE CAPAS

```
dt-regulatory-solvency/
├── CLAUDE.md         ← este archivo
├── as-is.md          ← HOY: cadena regulatoria conocida (ERN + Monitor tentativo)
├── gaps.md           ← GAP: sistemas por confirmar, IFRS 17 pendiente
└── to-be.md          ← MAÑANA: single source of truth regulatorio
```

---

## ESCENARIOS MAÑANA

1. **Trazabilidad regulatoria**: mapa completo ERN → reservas → Solvencia C → CNSF con audit trail
2. **IFRS 17 compliance**: integración contable-actuarial con sistemas existentes
3. **Regulatory reporting automatizado**: generación de reportes CNSF sin intervención manual

---

*Última actualización: 2026-09-03 · v1.0 · DATO-REQUERIDO — confirmar Monitor y reservas*