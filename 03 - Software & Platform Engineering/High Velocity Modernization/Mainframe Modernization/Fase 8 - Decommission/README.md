# Fase 8 — Decommission & Regulatory Retention
> Carpeta-puntero · Mainframe Modernization · HVM · 03 S&PE

```
┌─ CARPETA-PUNTERO ──────────────────────────────────────────┐
│ Esta fase NO tiene specialist local en Digital Core.        │
│ La ejecutan dos SMEs externos en coordinación.              │
└─────────────────────────────────────────────────────────────┘
```

## Quiénes ejecutan esta fase

| SME | Rol en la fase |
|---|---|
| `Solutioning/Delivery - SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/` | Sign-off regulatorio para decommission · obligaciones de retención CNBV · plan de notificación a regulador |
| `Solutioning/Delivery - SME/Technology/Cybersecurity/Data Security & Privacy/` | Disposición segura de datos legacy · retención de datos regulatorios · destrucción certificada |

El Regulatory SME determina **cuándo se puede** hacer el decommission; el Cybersecurity SME determina **cómo se hace** la disposición de los datos.

## Objetivo de la fase

Retirar el sistema legacy del aire de forma irreversible, asegurando:
1. **Cumplimiento de ventana de coexistencia** (≥ 12 meses con consumers externos/regulatorios)
2. **Retención regulatoria** de datos históricos (CNBV: 10 años para operaciones bancarias)
3. **Notificación al regulador** si aplica (cambio en sistemas que procesan transacciones reportables)
4. **Destrucción o archivo certificado** del código fuente y datos del mainframe
5. **Decommission del LPAR / partición** con reducción real de licenciamiento

**`[CRÍTICO]` El decommission es la única acción del lifecycle de modernización que NO tiene rollback.** Todas las condiciones de salida deben cumplirse antes de apagar el mainframe.

## Prerequisites de entrada (gates de entrada)

Todos los siguientes deben estar en `✅ COMPLETADO` antes de iniciar esta fase:

| Condición | Gate |
|---|---|
| Equivalence ≥ 99.99% en parallel-run (DoD-SPE-MM-01) | ✅ / ☐ |
| Parallel-run ≥ 3 meses con reconciliación diaria (DoD-SPE-MM-02) | ✅ / ☐ |
| Rollback al mainframe probado por capability (DoD-SPE-MM-03) | ✅ / ☐ |
| Sign-off auditoría interna + regulador (DoD-SPE-MM-04) | ✅ / ☐ |
| SLA del nuevo ≤ SLA del mainframe (DoD-SPE-MM-05) | ✅ / ☐ |
| Ventana de coexistencia ≥ 12 meses cumplida (DoD-SPE-MM-06) | ✅ / ☐ |
| Plan de retención de datos firmado por compliance | ✅ / ☐ |
| CAB approval para decommission del LPAR | ✅ / ☐ |

## Outputs canónicos

| Artefacto | Descripción |
|---|---|
| `decommission-plan-{sistema}.md` | Secuencia de apagado del mainframe: qué se apaga, cuándo, en qué orden |
| `regulatory-retention-plan-{sistema}.md` | Qué datos se retienen, en qué formato, por cuánto tiempo, dónde y cómo se acceden si el regulador los requiere |
| `regulatory-notification-{sistema}.md` | Notificación a CNBV / Banxico (si el sistema está sujeto a aviso de cambio) |
| `data-destruction-certificate-{sistema}.md` | Certificado de destrucción de datos del mainframe no sujetos a retención |
| `license-release-{sistema}.md` | Confirmación de liberación de licencias Unisys / IBM / Micro Focus y reducción de MIPS |

## Packet `[INVOKE]` — Regulatory

```
[INVOKE: Solutioning/Delivery - SME/Framework/ITSM/GRC/Specialist - Mainframe Modernization Regulatory/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
FASE            : 8 — Decommission
JURISDICCION    : CNBV Circular Única de Bancos · Banxico · Ley de Instituciones de Crédito
DATOS-REGULADOS : operaciones de captación · {N} años histórico · reportes Serie R
DELIVERABLE     : regulatory-retention-plan + notificación regulatoria + sign-off decommission
PREREQUISITO    : DoD-SPE-MM-01..06 todos en ✅
```

## Packet `[INVOKE]` — Data Security & Privacy

```
[INVOKE: Solutioning/Delivery - SME/Technology/Cybersecurity/Data Security & Privacy/]
COMPONENTE      : SPE-MM-{NNN} — {nombre del sistema}
FASE            : 8 — Decommission
DATOS-SENSIBLES : PII de clientes bancarios · datos financieros · secreto bancario
RETENCION       : datos pre-retención → destrucción certificada · datos retenidos → archivo seguro
FORMATO-ARCHIVO : legible sin software Unisys (conversión EBCDIC → UTF-8 · DMSII → formato estándar)
DELIVERABLE     : data-destruction-certificate + secure-archive-plan
```

## Posición en el ciclo metodológico

```
OPERATE (parallel-run 3+ meses) → OBSERVE (equivalence drift < 0.01%) → FASE 8 DECOMMISSION

                                              ↓
                                  Solo se inicia cuando TODOS los gates
                                  de entrada están en ✅
                                  
                                  Decommission es irreversible —
                                  medir dos veces, cortar una vez
```

*Última actualización: 2026-06-30 · v1.0 · Fase creada como carpeta-puntero per REORG de fases MM.*