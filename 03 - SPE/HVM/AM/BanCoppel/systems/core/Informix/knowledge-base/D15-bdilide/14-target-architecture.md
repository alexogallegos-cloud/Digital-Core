# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---

## Principios de diseño para el dominio PLD

1. **Aislamiento regulatorio:** el microservicio PLD debe ser un componente independiente con acceso restringido. Solo los servicios autorizados pueden consultarlo.
2. **Auditabilidad total:** todas las decisiones del motor PLD deben registrarse con trazabilidad completa (quién consultó, qué resultado, qué regla aplicó, cuándo).
3. **Equivalencia primero:** la arquitectura target no debe "mejorar" el comportamiento del motor PLD sin sign-off del Área de Cumplimiento. Primero equivalencia, luego mejoras.
4. **Retención garantizada:** los datos PLD deben sobrevivir cualquier fallo de infraestructura. S3 Object Lock + Aurora con backups en múltiples regiones.
5. **Zero-downtime en parallel-run:** durante los 3 meses de parallel-run, ambos sistemas (legacy Informix y target AWS) deben ejecutar el motor PLD y sus resultados deben compararse.

## Diagrama de arquitectura target

```
┌──────────────────────────────────────────────────────────────────┐
│                    DOMINIO D15 — PLD/LIDE                        │
│                                                                  │
│  ┌─────────────┐     ┌──────────────────────────────────────┐   │
│  │  API Gateway │     │        LideService (ECS Fargate)     │   │
│  │  (privado)   │────▶│  Spring Boot 3.x / Java 21           │   │
│  └─────────────┘     │  · Consulta LIDE                      │   │
│                      │  · Motor PLD transaccional             │   │
│  Callers internos:   └────────────────┬─────────────────────┘   │
│  · bdicnweb                           │                          │
│  · bdinteg                            │                          │
│  · bdicred                            ▼                          │
│                      ┌──────────────────────────────────────┐   │
│                      │   Aurora PostgreSQL (bdilide_target)  │   │
│                      │   · Multi-AZ                          │   │
│                      │   · CMK KMS (cifrado en reposo)       │   │
│                      │   · Retención backups: 35 días        │   │
│                      └──────────────────────────────────────┘   │
│                                       │                          │
│  ┌────────────────────────────────────┼───────────────────┐     │
│  │       PldBatchService (ECS Fargate / Step Functions)   │     │
│  │  · ejecutor_diario → EventBridge Scheduler             │     │
│  │  · acumulacion_operaciones → ECS Task largo plazo      │     │
│  │  · generacion_informe_sat → Step Function              │     │
│  └────────────────────────────────────┬───────────────────┘     │
└───────────────────────────────────────┼─────────────────────────┘
                                        │
          ┌─────────────────────────────┼──────────────────────┐
          │                             │                        │
          ▼                             ▼                        ▼
   [S3 — Archivos              [SNS → Compliance           [CloudWatch]
    regulatorios]               Alerts]                    [X-Ray]
   Object Lock                  · Reportes fallidos        [Dashboard PLD]
   (inmutable)                  · Divergencias PLD
```

## Componentes del target

### LideService — Servicio transaccional PLD/LIDE

| Componente | Tecnología | Justificación |
|-----------|-----------|--------------|
| Runtime | Java 21 / Spring Boot 3.x | Estándar Informix |
| Deployment | ECS Fargate (no Lambda) | Conexiones a Aurora con warm pool; evitar cold starts en consultas LIDE |
| Base de datos | Aurora PostgreSQL 15 (Multi-AZ) | Estándar Informix; HA para servicio crítico |
| Secretos | AWS Secrets Manager | Credenciales Aurora, Buró de Crédito, SAT |
| Feature flag | AWS AppConfig | Porcentaje de tráfico entre legacy y target en parallel-run |
| Cifrado | KMS CMK exclusiva del dominio PLD | Aislamiento de claves regulatorio |

### PldBatchService — Procesamiento batch nocturno

| Componente | Tecnología | Justificación |
|-----------|-----------|--------------|
| Orquestación | Step Functions | Visibilidad del estado de cada etapa del batch |
| Ejecución masiva | ECS Fargate Task | Soporte de ejecuciones largas (>15 minutos) |
| Scheduler | EventBridge Scheduler | Reemplaza el cron AIX |
| Procesamiento archivos SAT | Lambda (Python) | Reemplaza los comandos `sed`/`rm` del AIX |
| Almacenamiento archivos | S3 con Object Lock | Inmutabilidad regulatoria |

## Estrategia de integración cross-dominio

Las llamadas cross-DB de Informix se reemplazan por:

| Llamada Informix | Equivalente target |
|-----------------|--------------------|
| `SELECT si_cliente WHERE num_cte = ?` | REST API a IntegracionService (D02) |
| `UPDATE si_fechas` | Evento Kafka → IntegracionService actualiza su propio registro |
| `SELECT sc_fechas` | REST API a CuentasService (D04) |
| `INSERT sc_movdia` | Evento Kafka → CuentasService consume y persiste |
| `INSERT sd_movdia` | Evento Kafka → CredService (D03) consume y persiste |

## Anti-Corruption Layer (ACL) PLD

```
Callers (bdicnweb, bdinteg, bdicred)
        │
        ▼
[PldACL — Spring Security + mTLS]
  · Autenticación mTLS entre microservicios
  · Rate limiting: máx. 1,000 req/seg por caller
  · Circuit breaker (Resilience4j): threshold 10% errores / 30s → OPEN
  · Respuesta degradada: si LIDE no responde en 200ms → DENY (falla segura)
        │
        ▼
[LideService]
```

> **Falla segura en PLD:** si el servicio LIDE no está disponible, la respuesta predeterminada es DENY (bloquear la operación). Nunca asumir que un cliente está libre de LIDE si el servicio no responde. `[COMPLIANCE-SIGN-OFF-REQUIRED]`

## Archivos regulatorios en el target

```
[PldBatchService]
      │
      ├── Genera archivo de consulta SAT
      │         │
      │         ▼
      │   [S3 pld-regulatory-{env}/sat/consulta/AAAAMM/]
      │         │ (Object Lock: COMPLIANCE mode, 10 años)
      │         ▼
      │   [AWS Transfer Family — SFTP] → SAT
      │
      └── Recibe archivo de resultado SAT
                │
                ▼
          [S3 pld-regulatory-{env}/sat/resultado/AAAAMM/]
                │
                ▼
          [PldBatchService procesa y actualiza Aurora]
```

## `[SME-PENDING]`

- [ ] Cloud Architect: validar que ECS Fargate es el deployment correcto vs. Lambda para el LideService.
- [ ] Confirmar el mecanismo de falla segura (DENY) con el Área de Cumplimiento.
- [ ] Definir la CMK KMS del dominio PLD y el proceso de rotación.
- [ ] Confirmar el protocolo de transferencia de archivos con SAT (¿AWS Transfer Family SFTP? ¿API directa?).
- [ ] Diseñar el schema Aurora para preservar los tipos MONEY con `NUMERIC(16,2)` y `RoundingMode.HALF_EVEN`.

---
*Generado: Cloud Architect — AWS Banking + Core Banking Transformation · 2026-08-03*
