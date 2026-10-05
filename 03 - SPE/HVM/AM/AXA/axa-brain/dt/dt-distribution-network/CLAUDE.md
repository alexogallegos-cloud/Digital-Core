# dt-distribution-network — Digital Twin · Red de Distribución
> Cubre el flujo desde el agente/corredor hasta la póliza emitida.

---

## PROPÓSITO

Responde: **¿Cómo llega una oportunidad de negocio desde un agente o corredor hasta el sistema, y qué se pierde en el camino?**

---

## SISTEMAS INVOLUCRADOS (HOY)

| Etapa | Sistema | Rol | Estado |
|-------|---------|-----|--------|
| Cuenta / cliente | SINCO | Registro y búsqueda de cuenta, conducto, antecedentes | CONFIRMED-NAME |
| Caso / folio | Vector | Apertura del expediente de suscripción | CONFIRMED-NAME |
| Cálculo técnico | HSD (Excel) | Cotización técnica — fuera del sistema | GAP CRÍTICO |
| Emisión | General Daños | Póliza emitida | CONFIRMED-NAME |
| Portal agentes | Por confirmar | ¿Existe? ¿Integrado con Vector? | SCAFFOLD |
| Comunicación | Correo / Teams / WhatsApp | Coordinación fuera de sistemas | GAP |

---

## GAP PRINCIPAL

No existe un **portal de agentes confirmado**. La coordinación entre el agente/corredor y el suscriptor
se hace por correo, Teams y WhatsApp — completamente fuera de los sistemas de registro. Esto genera:
- Información dispersa y difícil de rastrear
- Sin visibilidad del pipeline de negocio por conducto
- Sin SLA medible por intermediario

---

## ESTRUCTURA DE CAPAS

```
dt-distribution-network/
├── CLAUDE.md        ← este archivo
├── as-is.md         ← HOY: flujo agente→SINCO→Vector→HSD→emisión
├── gaps.md          ← GAP: sin portal, comunicación fragmentada
└── to-be.md         ← MAÑANA: portal agentes integrado + pipeline tracking
```

---

## ESCENARIOS MAÑANA

1. **Portal agentes básico**: cotización en línea integrada con Vector (12 meses)
2. **Self-service suscripción**: agente ingresa riesgo → underwriting automático para riesgos estándar
3. **API abierta**: exposición de capacidades de cotización a brokers con sistemas propios

---

*Última actualización: 2026-09-03 · v1.0 · Scaffold*