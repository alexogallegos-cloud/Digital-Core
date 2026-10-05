# dt-claims-lifecycle — Digital Twin · Ciclo de Vida del Siniestro
> Estado: DATO-REQUERIDO — sin fuente de datos confirmatoria aún.

---

## PROPÓSITO

Responde: **¿Qué sistemas intervienen desde la notificación de un siniestro (FNOL) hasta el pago y cierre, y dónde están los gaps?**

---

## ESTADO ACTUAL

Este DT no tiene datos verificados en el brain. El Excel de Competitive Discovery Suscripción Daños
cubre el proceso de **suscripción**, no el de **siniestros**. Se requiere una fuente adicional:
entrevistas con el equipo de siniestros, un Excel equivalente de mapeo de procesos de claims,
o acceso al sistema de siniestros (nombre real por confirmar).

---

## SISTEMAS ESPERADOS (hipótesis — sin confirmar)

| Etapa | Sistema hipotético | Estado |
|-------|-------------------|--------|
| FNOL | Por confirmar | SCAFFOLD |
| Asignación ajustador | Por confirmar | SCAFFOLD |
| Investigación / peritaje | Por confirmar | SCAFFOLD |
| Autorización | Por confirmar | SCAFFOLD |
| Pago | Por confirmar (¿Billing?) | SCAFFOLD |
| Cierre | Por confirmar | SCAFFOLD |
| Reporte regulatorio | Monitor (tentativo) / Power BI | PARTIAL |

---

## ESTRUCTURA DE CAPAS

```
dt-claims-lifecycle/
├── CLAUDE.md        ← este archivo
├── as-is.md         ← HOY: se llenará cuando llegue la fuente de datos
├── gaps.md          ← GAP: por descubrir
└── to-be.md         ← MAÑANA: por definir
```

---

## DATO-REQUERIDO

Para activar este DT, solicitar al cliente:
- Excel de mapeo de procesos de siniestros (equivalente al Competitive Discovery de Suscripción)
- Nombre del sistema de siniestros en producción
- Nombre del sistema de pagos a asegurados

---

*Última actualización: 2026-09-03 · v1.0 · DATO-REQUERIDO — sin fuente*