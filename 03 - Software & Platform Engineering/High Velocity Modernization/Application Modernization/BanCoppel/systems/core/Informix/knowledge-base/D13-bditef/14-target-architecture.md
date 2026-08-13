# D13 · Transferencias Electrónicas de Fondos (TEF) — Arquitectura Target

> **Componente:** Informix · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Architect Target — Informix (diseño del microservicio)
- SME — Core Banking Transformation (patrones de migración bancaria)
- SME — SRE & AIOps (operabilidad, SLOs, observabilidad)
- SME Regulatorio — CNBV (cumplimiento regulatorio en el target)

---

## Descripción

Arquitectura objetivo del dominio `bditef` en AWS. El dominio se migra como el microservicio `TransferenciasService` — un servicio autónomo que encapsula toda la lógica de Transferencias Electrónicas de Fondos actualmente en los 139 SPs de Informix.

---

## Principios de diseño

1. **Equivalencia funcional primero:** Cada SP del callgraph tiene un endpoint o método equivalente en `TransferenciasService`. No hay refactorización funcional durante la migración.
2. **Desacoplamiento de cross-DB:** Las referencias directas a `bdicheq` y `bdinteg` se transforman en llamadas a APIs internas (`ChequeService`, `MasterDataService`).
3. **Contrato explícito de errores:** Los 5 códigos ESB de INC-005 y todos los códigos de retorno `char(5)` tienen un equivalente tipado en el API contract.
4. **Idempotencia de operaciones:** El algoritmo de folio único (BR-D13-024) se reemplaza por UUID v4 generado por el servicio — nunca por el cliente.
5. **Circuit breaker para el sistema TEF externo:** Obligatorio dado el patrón de timeout evidenciado (ESB code 3743).

---

## Arquitectura de componentes

```
┌─────────────────────────────────────────────────────────────────┐
│  API Gateway (Amazon API Gateway)                               │
│  ├── /transferencias/v1/enviar         POST                     │
│  ├── /transferencias/v1/reverso        POST                     │
│  ├── /transferencias/v1/consulta       GET                      │
│  └── /transferencias/v1/estado/{folio} GET                      │
└──────────────────────┬──────────────────────────────────────────┘
                       │ JWT / mTLS
┌──────────────────────▼──────────────────────────────────────────┐
│  TransferenciasService  (Java 21 / Spring Boot 3.x)             │
│                                                                  │
│  ┌─────────────────┐  ┌──────────────────┐  ┌───────────────┐  │
│  │ TransferHandler │  │ CamaraProcessor  │  │ CalendarSvc   │  │
│  │ (cargo_cta,     │  │ (procesarArch    │  │ (cal_fecha    │  │
│  │  abono_cta,     │  │  60/61/62/63,    │  │  _pre_fh,     │  │
│  │  grabaOper)     │  │  generarArch)    │  │  cal_habil    │  │
│  └────────┬────────┘  └────────┬─────────┘  │  _ant)        │  │
│           │                    │             └───────────────┘  │
│  ┌────────▼────────────────────▼─────────────────────────────┐  │
│  │  FolioGenerator (UUID v4 — reemplaza algoritmo BR-D13-024)│  │
│  └────────────────────────────────────────────────────────────┘  │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  CircuitBreaker (Resilience4j)  — sistema TEF externo    │   │
│  │  timeout: 30s · retries: 3 · backoff: exponencial        │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                  │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │  AuditLogger → tef_bitacora (Aurora PostgreSQL)          │   │
│  └──────────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────────┘
                       │
        ┌──────────────┼──────────────┐
        │              │              │
┌───────▼──────┐ ┌─────▼──────┐ ┌────▼─────────────────────────┐
│ Aurora PSQL  │ │ChequeService│ │ Sistema TEF Externo (SOAP)   │
│ (bditef)     │ │(bdicheq)   │ │ via AWS PrivateLink / VPN    │
└──────────────┘ └─────────────┘ └─────────────────────────────┘
                       │
                ┌──────▼──────────────┐
                │ MasterDataService   │
                │ (si_feriado,        │
                │  cce_param,         │
                │  catálogo bancos)   │
                └─────────────────────┘
```

---

## Componentes AWS

| Componente | Servicio AWS | Justificación |
|-----------|-------------|---------------|
| API expuesta | Amazon API Gateway (REST) | Control de throttling, autenticación JWT |
| Lógica del servicio | Amazon ECS (Fargate) — Java 21 | Containerización, escalamiento horizontal |
| Base de datos | Amazon Aurora PostgreSQL | Compatibilidad SQL, alta disponibilidad multi-AZ |
| Archivos CECOBAN | AWS Transfer Family (SFTP) | Reemplaza el SFTP actual al sistema CECOBAN |
| Jobs batch | Amazon EventBridge + AWS Batch | Orquestación de ciclos de cámara CECOBAN |
| Circuit breaker | Resilience4j (in-process) | Manejo del patrón de timeout del sistema TEF externo |
| Secretos y certificados | AWS Secrets Manager + ACM | Certificados SSL para CECOBAN y sistema TEF |
| Observabilidad | Amazon CloudWatch + AWS X-Ray | SLOs, trazas distribuidas, alertas operativas |
| Auditoría | CloudWatch Logs + S3 | Retención de tef_bitacora por 5 años (CNBV) |

---

## Mapeo SP → endpoint/método del target

| SP Informix | Equivalente target | HTTP method | Path |
|------------|-------------------|-------------|------|
| `sp_tef_grabaoperacion` | `TransferHandler.enviar()` | POST | `/transferencias/v1/enviar` |
| `sp_grabaoperaciontef` | `TransferHandler.enviarLegacy()` | POST | `/transferencias/v1/enviar` (mismo endpoint) |
| `sp_tef_reversoperacion` | `TransferHandler.reverso()` | POST | `/transferencias/v1/reverso` |
| `sp_tef_validahorario` | `CalendarSvc.esHorarioHabil()` | — (interno) | — |
| `sp_tef_valida_datos` | `TransferHandler.validar()` | — (interno pre-validación) | — |
| `cargo_cta` | `ChequeService.cargo()` | POST (interno) | `/cuentas/v1/{id}/cargo` |
| `abono_cta` | `ChequeService.abono()` | POST (interno) | `/cuentas/v1/{id}/abono` |
| `cal_fecha_pre_fh` | `CalendarSvc.siguienteDiaHabil()` | — (interno) | — |
| `cal_habil_ant` | `CalendarSvc.anteriorDiaHabil()` | — (interno) | — |
| `sp_consultarepop_tef` | `TransferHandler.consultar()` | GET | `/transferencias/v1/consulta` |
| `sp_tef_procesararchivo60` | `CamaraProcessor.procesarFormato60()` | — (batch) | — |
| `sp_tef_generararchivo60` | `CamaraProcessor.generarFormato60()` | — (batch) | — |
| `sp_tef_presentador_g` | `CamaraProcessor.ejecutarPresentacion()` | — (batch) | — |
| `sp_tef_moverregistroshist` | `ArchivadoJob.moverAHistorico()` | — (batch EventBridge) | — |
| `sp_tef_bitacora` | `AuditLogger.log()` | — (interno) | — |

---

## SLOs propuestos

| Métrica | SLO propuesto | Justificación |
|---------|--------------|---------------|
| Latencia p99 — envío de transferencia | < 3s | Incluye llamada a sistema TEF externo + cargo en cuenta |
| Latencia p99 — consulta de operación | < 500ms | Solo lectura de Aurora |
| Disponibilidad del servicio | 99.9% (3h downtime/año) | Operación bancaria crítica |
| Procesamiento de archivo CECOBAN | < 30 min por ciclo | Ventana operativa CECOBAN |
| Retención de bitácora | 5 años | CNBV Circular Única de Bancos |

---

## `[SME-PENDING]`

- [ ] Confirmar el patrón de transacciones distribuidas (Saga vs. 2PC) para cargo+registro TEF.
- [ ] Validar con CECOBAN el mecanismo de certificación del formato de archivos target.
- [ ] Definir la estrategia de migración de datos históricos de `tef_bitacora` (retención 5 años).
- [ ] Confirmar si el ESB actual se elimina o persiste como capa de integración durante la transición.
- [ ] Validar SLOs con el Domain Expert BanCoppel y el área de operaciones.

---
*Generado por análisis de callgraph + contexto regulatorio + patrones de Core Banking en AWS*
