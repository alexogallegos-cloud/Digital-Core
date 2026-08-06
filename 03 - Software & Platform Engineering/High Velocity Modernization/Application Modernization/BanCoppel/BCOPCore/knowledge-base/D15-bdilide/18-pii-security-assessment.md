# D15 · LIDE/PLD (Prevención de Lavado de Dinero) — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** bdilide
> **Wave:** Wave 4 · Riesgo: CRÍTICO (regulatorio — PLD/CNBV/SHCP)
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- Cybersecurity (`SME/Technology/Cybersecurity/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — SAT** (`SME/Regulatory/SAT/`)
- Domain Expert — BanCoppel / Área de Cumplimiento
- DBA IBM Informix (inventario real de columnas PII)
- Cloud Architect — AWS Banking

> `[COMPLIANCE-SIGN-OFF-REQUIRED]` en toda decisión de seguridad que afecte el manejo de datos PLD.

---

## Perfil de riesgo de datos — Máxima sensibilidad

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | SÍNCRONO SÍ — RFC, CURP, nombre, número de cliente |
| Contiene datos financieros sensibles | SÍ — montos de operaciones, historial transaccional |
| Datos de tarjeta (PCI-DSS) | Probable NO — confirmar con DBA |
| Datos regulatorios especiales | SÍ — registros PLD, lista LIDE, reportes regulatorios |
| Nivel de clasificación | MÁXIMO — datos bajo secreto regulatorio (LFPIORPI Art. 30) |
| Regulaciones aplicables | LFPIORPI, CNBV CUB Título XIV, SAT, LFPDPPP, FATF |

> **Nota crítica:** los datos del dominio PLD tienen un estatus especial bajo la LFPIORPI. El Art. 30 establece la confidencialidad de los reportes PLD — divulgar que un cliente fue reportado es una infracción. Esta confidencialidad debe preservarse en los logs, APIs y cualquier mecanismo de observabilidad del target.

## Inventario de campos PII

| Campo / Variable | Tipo de dato personal | Regulación | Acción requerida |
|-----------------|----------------------|-----------|-----------------|
| `rfc` | RFC del cliente — identificador fiscal | LFPDPPP + SAT | Cifrar en reposo (KMS CMK); eliminar de logs |
| `curp` | CURP del cliente — identificador personal único | LFPDPPP | Cifrar en reposo; eliminar de logs |
| `num_cte` / `numclt` | Número de cliente BanCoppel | CNBV | Tokenizar en ambientes no-productivos |
| Nombre completo | Datos en `sl_detlide` (causal de LIDE) | LFPDPPP | Anonimizar en ambientes de prueba |
| `fecha_nacimiento` (si aplica) | Fecha de nacimiento | LFPDPPP | Cifrar; agregar ruido en analítica |
| Montos de operaciones | Montos en `sl_movefec`, `sl_retlide` | LFPDPPP + CNBV | No exponer en logs; cifrar en reposo |

## Datos de sensibilidad especial — régimen PLD

Estos datos van más allá del PII estándar y tienen protección especial bajo la LFPIORPI:

| Dato | Clasificación especial | Restricción |
|------|----------------------|-------------|
| Registro en lista LIDE | Dato regulatorio confidencial | PROHIBIDO divulgar a terceros no autorizados; PROHIBIDO confirmar o negar en respuestas de API sin autorización |
| Operaciones reportadas a CNBV/UIF | Secreto regulatorio (LFPIORPI Art. 30) | PROHIBIDO divulgar al cliente que fue reportado; PROHIBIDO compartir con otras áreas de BanCoppel sin autorización del Área de Cumplimiento |
| Historial de acumulación PLD | Dato regulatorio | Acceso restringido a Cumplimiento y Auditoría |
| Resultado de consulta Buró de Crédito | Dato financiero protegido | Solo el área que realiza la consulta puede acceder al resultado |

## Controles AWS obligatorios para D15

| Control | Servicio AWS | Configuración requerida | Nivel |
|---------|-------------|------------------------|:-----:|
| Cifrado en reposo (datos PLD) | AWS KMS CMK exclusiva del dominio PLD | Una CMK solo para bdilide; rotación anual automática; sin acceso desde otros dominios | 🔴 CRÍTICO |
| Cifrado en reposo (archivos regulatorios) | S3 + KMS | S3 Object Lock (COMPLIANCE mode) + SSE-KMS | 🔴 CRÍTICO |
| Cifrado en tránsito | TLS 1.3 | MÍNIMO TLS 1.2; preferir TLS 1.3 en todas las conexiones del LideService | 🔴 CRÍTICO |
| Autenticación entre servicios | mTLS | Todos los callers del LideService requieren certificado de cliente válido | 🔴 CRÍTICO |
| Anonimización en QA/UAT | AWS Macie + Lambda | RFC y CURP reemplazados por valores sintéticos antes de copiar a ambientes no-prod | 🔴 CRÍTICO |
| Audit trail | AWS CloudTrail + CloudWatch Logs | Retención 10 años (LFPIORPI Art. 19); inmutable con Object Lock | 🔴 CRÍTICO |
| Control de acceso granular | AWS IAM (Attribute-Based) | Solo LideService puede leer/escribir en Aurora bdilide; PldBatchService solo puede ejecutar Jobs | 🔴 CRÍTICO |
| Detección de anomalías | Amazon GuardDuty + Security Hub | Alertas automáticas por acceso inusual a datos PLD | 🟠 ALTO |
| Prevención de exfiltración | VPC Endpoints + Security Groups | Sin salida directa a internet desde Aurora bdilide; solo via endpoints específicos | 🟠 ALTO |
| Network isolation | VPC privada dedicada (o subnet dedicada) | El LideService opera en subnets privadas sin acceso directo desde internet | 🟠 ALTO |
| Protección de archivos regulatorios | S3 Object Lock COMPLIANCE | Los archivos enviados a CNBV/SHCP/SAT no pueden eliminarse ni modificarse | 🔴 CRÍTICO |

## Restricciones de acceso al dominio PLD

| Tipo de acceso | Entidad autorizada | Justificación |
|---------------|-------------------|--------------|
| Lectura Aurora bdilide | LideService (IAM Role) | Consultas transaccionales |
| Escritura Aurora bdilide | PldBatchService (IAM Role) | Procesos batch |
| Lectura S3 archivos regulatorios | PldBatchService | Carga/descarga de archivos |
| Escritura S3 archivos regulatorios | PldBatchService | Generación de archivos |
| Acceso de auditoría | Área de Cumplimiento (IAM User específico) | Auditoría regulatoria |
| Acceso de mantenimiento | DBA con MFA obligatorio | Solo en ventana de mantenimiento aprobada |
| Acceso de desarrollo | PROHIBIDO en producción | Los desarrolladores no acceden a datos PLD de producción |

## Regulaciones aplicables — detalle

| Regulador | Norma | Obligación específica para `bdilide` | Severidad |
|-----------|-------|----------------------------------|----------|
| **LFPIORPI** | Art. 19 | Conservar registros PLD 10 años mínimo | 🔴 CRÍTICO |
| **LFPIORPI** | Art. 30 | Confidencialidad de reportes a UIF — el cliente NO debe saber que fue reportado | 🔴 CRÍTICO |
| **CNBV** | CUB Título XIV Art. 130 | Confidencialidad de los registros del sistema PLD | 🔴 CRÍTICO |
| **CNBV** | CUB Título XIV Art. 115 | El sistema de monitoreo PLD debe ser automatizado, con trazabilidad completa | 🔴 CRÍTICO |
| **SAT** | LIDE (bases del intercambio) | Los datos de exentos intercambiados con el SAT son datos fiscales protegidos | 🔴 ALTO |
| **LFPDPPP** | Art. 8-10 | RFC, CURP y datos personales del cliente requieren consentimiento o base legal | 🔴 ALTO |
| **FATF R.11** | Conservación de registros | Registros de DDC y transacciones monitoreadas deben conservarse ≥ 5 años (FATF exige 10 años en práctica mexicana) | 🔴 ALTO |

## Transferencia de datos a terceros

El dominio `bdilide` transfiere datos a los siguientes terceros. Cada transferencia debe tener base legal documentada:

| Tercero | Tipo de datos | Base legal | DPA requerido |
|---------|--------------|-----------|:------------:|
| SAT | RFC, status de exención, montos acumulados | Obligación legal (LIDE) | No aplica — entidad pública |
| CNBV/UIF | Datos de operaciones inusuales/relevantes | Obligación legal (LFPIORPI) | No aplica — entidad pública |
| SHCP | Datos de operaciones en efectivo > $7,500 USD | Obligación legal (LFPIORPI) | No aplica — entidad pública |
| Buró de Crédito | RFC, CURP (consulta) | Contrato + consentimiento del cliente | Sí — verificar DPA vigente |
| OFAC / ONU | Datos para screening (receptores de la lista, no proveedores) | Obligación de cumplimiento | No aplica — fuentes públicas |

## `[SME-PENDING]`

- [ ] Cybersecurity: confirmar que la CMK PLD está aislada de las CMKs de otros dominios.
- [ ] DBA IBM Informix: confirmar si `sl_detlide` contiene nombre completo del cliente u otros datos biométricos.
- [ ] Área de Cumplimiento: confirmar el procedimiento de notificación al cliente si sus datos son reportados (¿cómo se maneja la confidencialidad de LFPIORPI Art. 30 en el proceso de comunicación al cliente?).
- [ ] Legal BanCoppel: confirmar que el DPA con el Buró de Crédito cubre la nueva arquitectura AWS.
- [ ] Confirmar si los ambientes de UAT y QA tienen datos anonimizados antes de iniciar las pruebas.

---
*Generado: Cybersecurity + SME Regulatorio CNBV · 2026-08-03*
