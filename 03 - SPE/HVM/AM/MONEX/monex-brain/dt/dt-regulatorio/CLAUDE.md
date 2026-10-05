# DT Regulatorio — Digital Twin
> CNBV · Banxico · FCA · DORA · AML/PLD

## Pregunta Central
¿Qué sistemas alimentan qué reportes regulatorios en cada jurisdicción?

## Mapa Regulación → Sistema → Reporte

| Regulación | Reporte | Sistemas fuente | Frecuencia | Estado |
|-----------|---------|-----------------|-----------|--------|
| Banxico SPEI | Tráfico SPEI | spei | Diario | SCAFFOLD |
| Banxico DIOR | Pagos internacionales > USD 10K | payments-legacy, swift | Por evento | SCAFFOLD |
| CNBV | Reportes capital/conducta | treasury, fx-engine | Mensual | SCAFFOLD |
| UIF/GAFI | Operaciones inusuales AML | fx-engine, payments-legacy | Por evento | SCAFFOLD |
| FCA UK | Operational Resilience Report | todos | Anual | SCAFFOLD |
| DORA | ICT Risk Report · Major Incident | todos | Anual + incidentes | SCAFFOLD |
| FinCEN USA | CMIR (>USD 10K) | payments-legacy | Por evento | SCAFFOLD |
| SWIFT CSP | Attestation de seguridad | swift | Anual | SCAFFOLD |

## Gaps Críticos de Cumplimiento

| Gap | Riesgo | Impacto Regulatorio |
|----|--------|-------------------|
| Sin MDM/Golden Record — datos dispersos | CRÍTICO | AML cross-jurisdicción incompleto |
| DORA compliance — evaluación no completada | ALTO | FCA multa potencial (aplica desde ene-2025) |
| Sin inventario de APIs trazadas a regulación | ALTO | Imposible auditar impacto de cambios |

## Pendientes (DATO-REQUERIDO)
- [ ] Inventario completo de reportes regulatorios por jurisdicción
- [ ] Estado actual de DORA self-assessment UK
- [ ] Proceso actual de AML screening cross-jurisdicción

---
*v1.0 · 2026-09-22 · Scaffold*
