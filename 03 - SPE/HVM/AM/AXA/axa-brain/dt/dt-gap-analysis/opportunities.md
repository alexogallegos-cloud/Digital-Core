# Oportunidades de Transformación — AXA México P&C
> Generado: 2026-09-03 · Priorizado por impacto × esfuerzo

---

## Mapa de Oportunidades

```
           ALTO IMPACTO
                │
  OPP-002 ──────┼────── OPP-001  OPP-003  OPP-004
  OPP-006       │       OPP-007
  BAJO ─────────┼───────────────────────── ALTO
  ESFUERZO      │              OPP-005
                │
           BAJO IMPACTO
```

---

## Detalle por Oportunidad

### OPP-001 — Digitalizar la HSD — eliminar Excel de cálculo técnico

**Tipo**: Quick Win → Estratégico  
**Impacto**: Alto | **Esfuerzo**: Medio  
**ETB**: 6.3.2 Risk Assessment & Rating  
**LoBs afectadas**: Todos (Property, RT, RC, Marítimo, Aviación, OA, LF)  
**Sistemas involucrados**: underwriting-engine  
**Pain points relacionados**: 3.02.2, 3.02.3, 3.02.4, 3.02.5, 2.01.1

Sustituir la Hoja de Suscripción de Daños (Excel) por una herramienta web integrada con Vector. Es el gap más crítico: el cálculo técnico de suscripción vive fuera de cualquier sistema.

### OPP-002 — API ERN → sistema de cotización

**Tipo**: Quick Win  
**Impacto**: Alto | **Esfuerzo**: Bajo  
**ETB**: 6.3.3 Catastrophe Modelling  
**LoBs afectadas**: Property, Ramos Técnicos  
**Sistemas involucrados**: actuarial, underwriting-engine  
**Pain points relacionados**: Ver gap matrix

Exponer los resultados de ERN (modelación catastrófica) como API para eliminar la copia manual de PML y cúmulos al HSD.

### OPP-003 — Integración Vector → General Daños

**Tipo**: Estratégico  
**Impacto**: Alto | **Esfuerzo**: Medio  
**ETB**: 6.4 Policy Administration  
**LoBs afectadas**: Todos  
**Sistemas involucrados**: underwriting-engine, policy-admin  
**Pain points relacionados**: Ver gap matrix

Eliminar la recaptura manual de condiciones aprobadas desde el slip al sistema de emisión. Crear una API de traspaso de condiciones entre el expediente de suscripción y la póliza.

### OPP-004 — Portal de agentes básico

**Tipo**: Estratégico  
**Impacto**: Alto | **Esfuerzo**: Medio  
**ETB**: 4.1 Distribution Management  
**LoBs afectadas**: Todos  
**Sistemas involucrados**: portal-agentes, underwriting-engine  
**Pain points relacionados**: Ver gap matrix

Visibilidad del estado de folios en Vector para agentes y corredores. Sin este canal, la coordinación se hace por correo/WhatsApp, sin trazabilidad.

### OPP-005 — Consolidación de información cross-sistema

**Tipo**: Estratégico  
**Impacto**: Alto | **Esfuerzo**: Alto  
**ETB**: 5.1 Analytics & BI / 8.1 Integration Platform  
**LoBs afectadas**: Todos  
**Sistemas involucrados**: datawarehouse, analytics, api-gateway  
**Pain points relacionados**: 1.01.1, 1.02.1, 1.03.1, 1.04.1, 1.04.2

Resolver la fragmentación de información entre Vector, SINCO, HSD, ERN y Power BI. Los suscriptores buscan datos en múltiples sistemas sin fuente única de verdad.

### OPP-006 — SAFAC extendido — carga masiva de capas

**Tipo**: Quick Win  
**Impacto**: Medio | **Esfuerzo**: Bajo  
**ETB**: 6.5 Reinsurance Management  
**LoBs afectadas**: Property, Ramos Técnicos, RC  
**Sistemas involucrados**: reinsurance  
**Pain points relacionados**: Ver gap matrix

Ampliar SAFAC para soportar estructuras de reaseguro complejas (múltiples capas, múltiples reaseguradores por capa) sin requerir manipulación manual.

### OPP-007 — Mapa regulatorio completo (Monitor + reservas)

**Tipo**: Quick Win (discovery)  
**Impacto**: Alto | **Esfuerzo**: Bajo  
**ETB**: 9.1 Regulatory Reporting  
**LoBs afectadas**: Regulatorio  
**Sistemas involucrados**: reporting-cnsf, cnsf, solvency  
**Pain points relacionados**: Ver gap matrix

Confirmar el rol de Monitor y los sistemas de reservas técnicas para construir la cadena regulatoria CNSF completa. Prerequisito para IFRS 17 y Solvencia C.

---

*Generado por build-gap-analysis.py el 2026-09-03*