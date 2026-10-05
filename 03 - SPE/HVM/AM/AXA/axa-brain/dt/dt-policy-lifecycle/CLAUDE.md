# dt-policy-lifecycle — Digital Twin · Ciclo de Vida de la Póliza
> Cubre el flujo completo de una póliza de daños: cotización → emisión → endoso → renovación → cancelación.

---

## PROPÓSITO

Responde: **¿Qué sistemas tocan una póliza desde la cotización hasta la cancelación, dónde se rompe el flujo, y cómo debería ser?**

---

## SISTEMAS INVOLUCRADOS (HOY)

| Etapa | Sistema | Rol | Estado |
|-------|---------|-----|--------|
| Cotización | Vector + HSD | Gestión del folio y cálculo técnico | CONFIRMED-NAME |
| Búsqueda cliente | SINCO | Antecedentes y conductos | CONFIRMED-NAME |
| Reaseguro | SAFAC | Colocación facultativa si aplica | CONFIRMED-NAME |
| Emisión | General Daños | Captura condiciones → genera póliza | CONFIRMED-NAME |
| Endoso / Renovación | General Daños | Modificaciones sobre póliza vigente | CONFIRMED-NAME |
| Siniestralidad | Power BI | Consulta histórica por póliza | CONFIRMED-NAME |
| Cancelación | Por confirmar | — | SCAFFOLD |

---

## ESTRUCTURA DE CAPAS

```
dt-policy-lifecycle/
├── CLAUDE.md        ← este archivo
├── as-is.md         ← HOY: flujo cotización→cancelación por etapa
├── gaps.md          ← GAP: recaptura manual slip→General Daños; sin identificador único de póliza cross-sistema
└── to-be.md         ← MAÑANA: póliza digital con flujo automatizado
```

---

## GAP PRINCIPAL

**Recaptura manual**: las condiciones aprobadas en suscripción (Vector/HSD/slip) se recapturan manualmente en General Daños para emitir la póliza. No hay integración automática entre el expediente de suscripción y el sistema de emisión. Esto genera errores, retrasos y retrabajo.

---

## ESCENARIOS MAÑANA

1. **Integración Vector → General Daños**: API de traspaso de condiciones aprobadas (quick win)
2. **Póliza digital end-to-end**: cotización digital → aprobación → emisión automática sin recaptura
3. **Policy-as-a-Service**: API de póliza consumible por canales digitales y portal de agentes

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold*