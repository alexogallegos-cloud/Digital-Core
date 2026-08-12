# D13 · Transferencias Electrónicas de Fondos (TEF) — Evaluación PII y Seguridad

> **Componente:** BCOPCore · SPE-AM-001 · Etapa 3 — Business Logic Extraction
> **Base de datos:** `bditef`
> **Wave:** Wave 3 · Riesgo: ALTO
> **Última actualización:** 2026-08-03

---
**SME responsable:**
- SME — Cybersecurity (`Delivery - SME/Cybersecurity/`)
- SME Regulatorio — CNBV (`SME/Regulatory/CNBV/`) — secreto bancario, datos financieros
- Data Architect (clasificación de datos y controles en el target)

---

## Descripción

Evaluación de datos de carácter personal (PII) y sensibles de seguridad en el dominio `bditef`. El dominio maneja datos financieros de alto impacto: números de cuenta, importes de transferencias, datos de beneficiarios y bitácoras de operaciones bancarias.

**Marco regulatorio aplicable:**
- LFPDPPP — Ley Federal de Protección de Datos Personales en Posesión de Particulares
- CNBV — Circular Única de Bancos (secreto bancario, protección de información financiera)
- PCI-DSS — si aplica a los datos de cuenta manejados
- ISO 27001 — estándar de seguridad de la información

---

## Clasificación de datos por nivel de sensibilidad

### NIVEL 1 — PII Financiero Crítico

Datos que combinan identidad del cliente con información financiera. Exposición no autorizada implica violación del secreto bancario (CNBV) y riesgo de fraude.

| Campo / Tabla | Tipo de dato | Clasificación | Regulación |
|--------------|-------------|---------------|------------|
| `cuentaOrigen` / `sc_maechq.numcuenta` | Número de cuenta bancaria (20 dígitos) | PII Financiero Crítico | CNBV · LFPDPPP Art. 3 |
| `cuentaDest` en `tef_operaciones` | Número de cuenta o CLABE beneficiaria | PII Financiero Crítico | CNBV · LFPDPPP |
| `importe` en `tef_operaciones` | Monto de la transferencia | PII Financiero Crítico | CNBV · secreto bancario |
| `tef_operaciones.folio` | Identificador único de operación | PII Financiero Crítico | CNBV (trazabilidad) |
| `tef_bitacora` completa | Historial de operaciones del cliente | PII Financiero Crítico | CNBV — retención 5 años |

### NIVEL 2 — PII Financiero Alto

Datos que permiten inferir comportamiento financiero o identificar al cliente.

| Campo / Tabla | Tipo de dato | Clasificación | Regulación |
|--------------|-------------|---------------|------------|
| `pusuario` / `usuario` en `tef_operaciones` | ID del operador que realizó la operación | PII Operacional | ISO 27001 |
| `cce_usuarios_aut` completa | Usuarios autorizados para operaciones CCE | PII Operacional | ISO 27001 |
| `cce_cedula_usr` | Perfil/cédula de usuario CCE | PII Operacional | LFPDPPP (si incluye datos personales del empleado) |
| `cce_cheques_dev` | Cheques devueltos con datos de cuenta | PII Financiero Alto | CNBV |

### NIVEL 3 — Datos Operacionales Sensibles

Datos de configuración y control que, si se exponen, facilitan ataques.

| Campo / Tabla | Tipo de dato | Clasificación |
|--------------|-------------|---------------|
| `cce_param` (hora de corte, parámetros) | Configuración operativa de CECOBAN | Confidencial Operacional |
| `tef_archivos` (nombres de archivos) | Identificadores de archivos CECOBAN | Confidencial Operacional |
| Credenciales SFTP CECOBAN | Acceso al sistema de cámara | CRÍTICO — secreto |

---

## Controles de seguridad requeridos en el target

### Encriptación

| Capa | Control requerido | Estándar |
|------|-----------------|---------|
| En tránsito | TLS 1.3 mínimo para todos los endpoints de `TransferenciasService` | PCI-DSS 4.0 |
| En tránsito (SFTP CECOBAN) | SFTP sobre SSH con certificado de clave pública | CECOBAN |
| En reposo (Aurora) | Cifrado de base de datos con AWS KMS | ISO 27001 · CNBV |
| En reposo (S3 staging) | SSE-KMS en el bucket de staging de migración | ISO 27001 |
| En tránsito (sistema TEF externo) | TLS con validación de certificado (evidencia de ESB code 3165 — SSL error indica que puede no estar configurado correctamente) | PCI-DSS |

### Control de acceso

| Control | Descripción |
|---------|-------------|
| RBAC en `TransferenciasService` | Roles: `OPERADOR_TEF`, `SUPERVISOR_TEF`, `AUDITOR_TEF`, `ADMIN_CCE` |
| Separación de funciones | El operador que registra una transferencia NO puede aprobar su reverso |
| Autenticación de API | JWT con tiempo de expiración máximo 8 horas (sesión operativa) |
| Autenticación de jobs batch | IAM roles para ECS Tasks — sin credenciales embebidas |
| Rotación de credenciales SFTP | AWS Secrets Manager con rotación automática |

### Auditoría

| Control | Descripción | Retención |
|---------|-------------|-----------|
| `tef_bitacora` (Aurora) | Log de toda operación TEF | 5 años — CNBV |
| CloudWatch Logs | Logs del servicio `TransferenciasService` | 1 año mínimo |
| AWS CloudTrail | Auditoría de acceso a la base de datos Aurora | 1 año mínimo |
| AWS Config | Cambios en configuración de recursos de seguridad | `[SME-PENDING]` |

---

## Riesgos de seguridad identificados

### RIESGO-SEC-001 · Credenciales SFTP CECOBAN en código legacy

**Descripción:** El SP `sp_tef_subirarchivos` realiza la subida de archivos a CECOBAN. Es posible que las credenciales SFTP estén configuradas en parámetros de la base de datos (`cce_param`) o en archivos de configuración del servidor POWER-AIX.

**Acción requerida:** Auditar `cce_param` y el servidor POWER-AIX para identificar dónde están almacenadas las credenciales. Migrar a AWS Secrets Manager antes del cutover.

### RIESGO-SEC-002 · ESB code 3165 — SSL socket error

**Descripción:** El código ESB 3165 indica errores de SSL en la comunicación con sistemas externos. Puede indicar un certificado expirado, cipher suite obsoleto o validación de certificado deshabilitada.

**Acción requerida:** Auditar la configuración TLS del ESB y del sistema TEF externo antes de la migración. El target debe usar TLS 1.3 mínimo.

### RIESGO-SEC-003 · UUID de sesión fijo en procesos batch (evidencia de D05)

**Descripción:** El patrón de UUID de sesión fijo detectado en D05-bdisac (`22e4e9ee-...`) puede replicarse en los jobs batch de `bditef`. Si los jobs de ciclo de cámara usan tokens de sesión compartidos, existe riesgo de idempotencia y potencial acceso no autorizado si el token se expone.

**Acción requerida:** Revisar los SPs batch de `bditef` (especialmente `sp_tef_presentador_g`, `sp_tef_receptor_g`) para identificar patrones de sesión compartida.

### RIESGO-SEC-004 · Datos de cuenta en `char(20)` sin enmascaramiento

**Descripción:** Los números de cuenta viajan en texto claro en todos los parámetros de los SPs. En el target, los logs de `TransferenciasService` no deben registrar números de cuenta sin enmascaramiento.

**Acción requerida:** Implementar enmascaramiento en logs (`1234****56789`) antes de que el servicio entre en producción.

---

## Requisitos regulatorios de privacidad

| Requisito | Regulación | Implementación en target |
|-----------|-----------|------------------------|
| Derecho de acceso del titular | LFPDPPP Art. 22 | API de consulta de operaciones propias con autenticación fuerte |
| Derecho de cancelación | LFPDPPP Art. 24 | `[SME-PENDING]` — verificar si aplica a datos de operaciones bancarias (secreto bancario puede prevalecer) |
| Secreto bancario | CNBV — Ley de Instituciones de Crédito Art. 117 | Acceso a `tef_operaciones` restringido a roles autorizados + auditoría |
| Notificación de brechas | LFPDPPP Art. 37 | Plan de respuesta a incidentes debe incluir `bditef` como sistema crítico |
| Transferencia a terceros | LFPDPPP | CECOBAN como encargado del tratamiento — contrato de confidencialidad vigente `[SME-PENDING]` |

---

## `[SME-PENDING]`

- [ ] Confirmar dónde están almacenadas las credenciales SFTP de CECOBAN en el sistema legacy.
- [ ] Obtener análisis de configuración TLS del sistema TEF externo (relacionado con ESB code 3165).
- [ ] Confirmar con el área legal de BanCoppel si el derecho de cancelación de LFPDPPP aplica a datos de operaciones bancarias con retención obligatoria de CNBV.
- [ ] Verificar si `cce_cedula_usr` contiene datos personales de empleados (RFC, CURP, etc.).
- [ ] Validar el contrato de confidencialidad con CECOBAN como encargado del tratamiento de datos.

---
*Generado por análisis de tablas y campos PII en sp-specs-bditef.md + marco regulatorio LFPDPPP + CNBV + INC-005*
