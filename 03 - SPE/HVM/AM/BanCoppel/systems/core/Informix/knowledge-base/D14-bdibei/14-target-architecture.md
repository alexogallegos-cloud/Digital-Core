# D14 · Banca Electrónica Institucional (BEI) — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdibei
> **Wave:** Wave 3 · Riesgo: CRÍTICO (batch nómina)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Core Banking Transformation (diseño de arquitectura target, ACL, API contracts)
- Cloud Architect — AWS Banking (servicios AWS, sizing, redes, seguridad)
- Software Engineering SME (implementación de microservicios Java 21)
- Data & ML — Data Architect (migración de datos, CDC, schema migration)
- SRE & AIOps (observabilidad, runbooks, cutover operativo)
- Cybersecurity (seguridad cloud, IAM, PII encryption)

> `[SME-PENDING]` = requiere validación con Core Banking Transformation + Cloud Architect antes de BUILD.
---

## Decisión de Arquitectura (ADR-SPE-AM-BEI-001)

| Atributo | Valor |
|----------|-------|
| Patrón de modernización | **Strangler-Fig por capacidad** — reemplazar las capacidades BEI gradualmente |
| Coexistencia | IBM Informix (legacy) + microservicios AWS (target) durante ventana de migración |
| Base de datos target | Amazon Aurora PostgreSQL 15+ (cluster Multi-AZ) |
| Motor de batch | AWS Step Functions + EventBridge Scheduler (reemplaza scheduler AIX) |
| API Gateway | Amazon API Gateway + AWS WAF (para portal BEI empresa) |
| Mensajería | Amazon MSK (Kafka) — reemplaza IBM MQ para integraciones asíncronas |
| Runtime microservicios | Java 21 + Spring Boot 3 en Amazon ECS Fargate (o EKS según sizing final) |
| Protocolo interno | REST / OpenAPI 3.1 entre microservicios BEI |

---

## Mapa de capacidades BEI → Microservicios target

| Capacidad BEI | Microservicio target | Owner de BD | Dependencias API |
|---------------|---------------------|-------------|-----------------|
| Gestión de convenios empresa | `ConvenioEmpresaService` | `bei_convenios` | CreditoEmpresaService (D03) |
| Gestión de beneficiarios / nómina | `BeneficiariosService` | `bei_beneficiarios` | — |
| Dispersión de pagos (online) | `DispersionService` | `bei_dispersiones` | SPEIService (D08) · CuentasService (D05) · ContabilidadService (D12) |
| Batch de nómina (crítico) | `BatchNominaService` | `bei_dispersiones` + `bei_dispersiones_det` | DispersionService · Step Functions |
| Comisiones BEI | `ComisionService` | `bei_comisiones` | ConvenioEmpresaService |
| Autenticación empresa | `AuthEmpresaService` | `bei_tokens_empresa` | IAM / Cognito |
| Reportes regulatorios | `ReportesBEIService` | Read-only replica | CNBV endpoints |
| Auditoría y bitácora | `AuditService` | `bei_bitacora` | Todos los servicios (pub/sub) |
| Notificaciones | `NotificacionEmpresaService` | Sin BD propia | SES / SNS |

---

## Diagrama de arquitectura target

```
┌─────────────────────────────────────────────────────────────────┐
│                    CAPA DE ACCESO EMPRESA                        │
│                                                                  │
│  ┌─────────────────┐    ┌─────────────────┐                      │
│  │  Portal BEI Web │    │  API BEI (B2B)  │                      │
│  │  (Angular/React)│    │  REST/SOAP      │                      │
│  └────────┬────────┘    └────────┬────────┘                      │
└───────────┼─────────────────────┼─────────────────────────────┘
            ▼                     ▼
  ┌──────────────────────────────────────────┐
  │         Amazon API Gateway + WAF         │
  │      JWT / mTLS empresa autenticación    │
  └──────────────────────┬───────────────────┘
                         ▼
  ┌──────────────────────────────────────────────────────────────┐
  │                   CAPA DE MICROSERVICIOS                      │
  │                   (ECS Fargate / EKS)                         │
  │                                                               │
  │  ┌─────────────┐  ┌─────────────┐  ┌──────────────────────┐  │
  │  │ AuthEmpresa │  │  Convenio   │  │   Beneficiarios      │  │
  │  │   Service   │  │  Empresa    │  │      Service         │  │
  │  └─────────────┘  │   Service   │  └──────────────────────┘  │
  │                   └─────────────┘                             │
  │  ┌──────────────────────────────────────────────────────────┐ │
  │  │              DispersionService                           │ │
  │  │   (online + orquesta BatchNominaService)                 │ │
  │  └──────────────────────────────────────────────────────────┘ │
  │  ┌────────────┐  ┌─────────────┐  ┌──────────────────────┐  │
  │  │  Comision  │  │  Reportes   │  │   Notificacion       │  │
  │  │  Service   │  │   Service   │  │  EmpresaService      │  │
  │  └────────────┘  └─────────────┘  └──────────────────────┘  │
  └──────────────────────┬───────────────────────────────────────┘
                         │ (publicador de eventos de auditoría)
                         ▼
  ┌──────────────────────────────────────────┐
  │        Amazon MSK (Kafka)                │
  │  Topic: bei.operaciones · bei.auditoria  │
  │  Topic: bei.dispersiones.pendientes      │
  └──────────────────────┬───────────────────┘
                         ▼
  ┌─────────────────────────────┐
  │      AuditService           │
  │   (bei_bitacora → Aurora)   │
  └─────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────┐
  │                  CAPA DE BATCH (CRÍTICA)                      │
  │                                                               │
  │  ┌──────────────────────────────────────────────────────┐     │
  │  │     EventBridge Scheduler → Step Functions           │     │
  │  │         BatchNominaStateMachine                      │     │
  │  │   (reemplaza scheduler AIX + SP batch Informix)      │     │
  │  │                                                       │     │
  │  │   Etapas Step Functions:                             │     │
  │  │   1. ValidarConvenioBatch                            │     │
  │  │   2. CargarBeneficiariosLote (paginado 100 regs)     │     │
  │  │   3. DispersarPorBeneficiario (loop con checkpoint)  │     │
  │  │   4. LiquidarSPEI (D08)                              │     │
  │  │   5. RegistrarContable (D12)                         │     │
  │  │   6. NotificarResultadoEmpresa                       │     │
  │  │   7. (en fallo) EscalarP1 + GuardarPendientes        │     │
  │  └──────────────────────────────────────────────────────┘     │
  └──────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────┐
  │                  CAPA DE DATOS                                │
  │                                                               │
  │  Amazon Aurora PostgreSQL 15+ (Multi-AZ, us-east-2)          │
  │  ┌────────────────────────────────────────────────────────┐   │
  │  │  Cluster primary (escritura): bei_dispersiones,        │   │
  │  │  bei_convenios, bei_beneficiarios, bei_comisiones,     │   │
  │  │  bei_archivos_nomina, bei_bitacora, bei_param          │   │
  │  │  Replica reader (lectura): Reportes + Auditoría        │   │
  │  └────────────────────────────────────────────────────────┘   │
  └──────────────────────────────────────────────────────────────┘

  ┌──────────────────────────────────────────────────────────────┐
  │              INTEGRACIONES EXTERNAS                           │
  │                                                               │
  │  SPEIService (D08) ←──── DispersionService (REST)            │
  │  CreditoEmpresaService (D03) ←── ConvenioService (REST)      │
  │  CuentasService (D05) ←──── DispersionService (REST)         │
  │  ContabilidadService (D12) ←── DispersionService (REST)      │
  │                                                               │
  │  CNBV Portal ←──── ReportesBEIService (SFTP/API)             │
  │  Banxico SPEI catálogo ←──── job sync diario                 │
  │  SAT RFC validación ←──── ConvenioEmpresaService (API)       │
  └──────────────────────────────────────────────────────────────┘
```

---

## Decisiones técnicas clave

### Reemplazo del LCG de `getrandomcode`

El SP `getrandomcode` implementa un LCG no criptográfico. En el target, `AuthEmpresaService` usa:
```java
// Target — reemplaza getrandomcode()
import java.security.SecureRandom;
private static final SecureRandom rng = new SecureRandom();
public String generateOTP() {
    String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    StringBuilder otp = new StringBuilder(8);
    for (int i = 0; i < 8; i++) {
        otp.append(chars.charAt(rng.nextInt(chars.length())));
    }
    return otp.toString();
}
```

### Manejo de errores ESB (INC-006) en el target

```java
// Resilience4j circuit breaker para llamadas al ESB
@CircuitBreaker(name = "esb-bei", fallbackMethod = "dispersionFallback")
@Retry(name = "esb-bei", fallbackMethod = "dispersionFallback")
public DispersionResult dispersar(DispersionRequest req) {
    // llamada al servicio externo o D08
}

// Configuración: maxRetryAttempts=3, waitDuration=2s/4s/8s
// circuitBreaker: failureRateThreshold=50%, waitDurationInOpenState=30s
```

### Checkpoint en batch de nómina

```yaml
# Step Functions BatchNominaStateMachine
DispersarPorBeneficiario:
  Type: Map
  ItemsPath: "$.beneficiarios"
  MaxConcurrency: 10
  Iterator:
    StartAt: DispersarUnBeneficiario
    States:
      DispersarUnBeneficiario:
        Type: Task
        Catch:
          - ErrorEquals: ["ESBMessagingException", "States.TaskFailed"]
            Next: MarcarPendiente  # no falla todo el lote
```

---

## Observabilidad target

| Componente | Herramienta | Alertas críticas |
|-----------|-------------|-----------------|
| Microservicios | CloudWatch + X-Ray | Latencia P95 > 200ms · Error rate > 0.1% |
| Batch nómina | CloudWatch + Step Functions | Job no inicia en horario esperado (P1) · Job falla con error ESB (P1) |
| Aurora PostgreSQL | RDS Enhanced Monitoring | Conexiones al 80% · Latencia escritura > 50ms |
| MSK (Kafka) | CloudWatch | Consumer lag > 1000 mensajes · Partición no disponible |
| Alertas P1 | PagerDuty | Batch nómina fallido · Dispersión bloqueada > 30 min |

---
*Generado por: Core Banking Transformation + Cloud Architect AWS Banking · 2026-08-03 · Fuente: sp-specs-bdibei.md + INC-006 + referencia arquitectura Informix*
