# D09 · Mensajería — Plan de Cutover

> **Componente:** Informix · SPE-AM-001 · RELEASE Phase
> **Base de datos:** `bdimnsj` → Aurora PostgreSQL
> **Wave:** Wave 1 · Riesgo: **BAJO**
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert BanCoppel (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Criterios de entrada (Go/No-Go Gate)

**No proceder al cutover si alguno de estos está en rojo:**

| Criterio | Responsable | Estado |
|---------|------------|--------|
| Golden master completado con 0 divergencias L4 (financiero) | QA Lead | [SME-PENDING] |
| Baseline de performance capturado | QA Lead + DBA | [SME-PENDING] |
| Target cumple SLOs (p99 ≤ baseline+20%) | QA Lead | [SME-PENDING] |
| Parallel-run ≥ 72 horas sin divergencias críticas | QA Lead | [SME-PENDING] |
| Schema real completado en Aurora (DBA confirmado) | DBA IBM Informix | [SME-PENDING] |
| SEQUENCES inicializadas con margen correcto | DBA | [SME-PENDING] |
| API contracts aprobados por Domain Expert BanCoppel | Core Banking | [SME-PENDING] |
| Controles PII y cifrado KMS habilitados | Cybersecurity | [SME-PENDING] |
| Runbook de observabilidad listo (21-observability-runbook.md) | SRE & AIOps | [SME-PENDING] |
| Sign-off de Tesorería BanCoppel (dominios financieros) | Domain Expert | [SME-PENDING] |

## Pre-requisitos — dominios upstream

`Mensajería` no puede cortar hasta que estos dominios estén disponibles como API:

| ID | Dominio | Llamadas | Estado |
|----|---------|---------|--------|
| D02 | Integración y Autenticación | 9 | API disponible como prereq |
| D03 | Créditos | 7 | API disponible como prereq |
| D06 | Solicitudes | 3 | API disponible como prereq |

## Dominios bloqueados por `bdimnsj`

Estos dominios no pueden migrar hasta que `bdimnsj` complete el cutover:

| ID | Dominio | Llamadas | Impacto |
|----|---------|---------|---------|
| D01 | Canal Digital Web | 949 | No puede migrar hasta que `bdimnsj` esté listo |
| D02 | Integración y Autenticación | 79 | No puede migrar hasta que `bdimnsj` esté listo |
| D03 | Créditos | 77 | No puede migrar hasta que `bdimnsj` esté listo |
| D04 | Cheques / Cuentas | 72 | No puede migrar hasta que `bdimnsj` esté listo |
| D11 | Cobranza | 53 | No puede migrar hasta que `bdimnsj` esté listo |

## Secuencia de cutover (ventana sugerida: sábado 22:00 → domingo 04:00 CDMX)

```
T-7 días:  Notificación a BanCoppel — ventana de cutover confirmada
T-1 día:   Freeze de deployments no relacionados
           Validación final del ambiente Aurora (DBA)
           Briefing del equipo SRE (runbook ready)

T=0 (22:00): INICIO VENTANA DE CUTOVER
  22:00  → Activar modo mantenimiento en canal (bdicnweb — si aplica)
  22:05  → Freeze de escrituras en Informix bdimnsj
  22:10  → Drenar CDC: esperar que MSK/Kafka procese últimos mensajes
  22:20  → Validar COUNT(*) por tabla: Informix vs. Aurora (DBA ejecuta)
  22:30  → Inicializar SEQUENCES en Aurora: SET val = MAX(id) * 1.5
  22:35  → Ejecutar smoke tests contra Aurora (QA Lead)
  22:45  → Feature flag al 1% del tráfico hacia target (AppConfig)
  23:00  → Si OK: feature flag al 10%
  23:30  → Si OK: feature flag al 50%
  00:00  → Si OK: feature flag al 100%
  00:30  → Monitoreo intensivo: CloudWatch + X-Ray + divergence dashboard
  02:00  → Si 0 alertas críticas: CUTOVER EXITOSO

ROLLBACK (activar si > N divergencias L4 en 30 minutos):
  → Feature flag al 0% (tráfico vuelve a Informix)
  → Aurora en modo read-only
  → Post-mortem 48h después
```

## Criterios de rollback automático

| Condición | Umbral | Acción |
|-----------|--------|--------|
| Divergencias L4 (financiero) en 30 min | > 0 | Rollback inmediato |
| Error rate en target | > 1% | Rollback |
| Latencia p99 en target | > 2x baseline | Rollback |
| CloudWatch alarm crítico | Cualquiera | Rollback + notificación |

## Comunicaciones

| Momento | Audiencia | Canal | Responsable |
|---------|-----------|-------|------------|
| T-7 días | BanCoppel IT + Negocio | Email formal | Program Manager |
| T-1 hora | Equipo técnico | Slack/Teams | SRE Lead |
| T=0 | Command center activo | Videollamada | Release Manager |
| Cutover exitoso | BanCoppel IT + Negocio | Email + Teams | Program Manager |
| Rollback (si aplica) | BanCoppel IT + Negocio + Accenture | Email urgente | Program Manager |

---
*Generado por: SRE & AIOps + Cloud Architect AWS Banking · 2026-07-03 · [SME-PENDING] criterios go/no-go requieren validación QA Lead*
