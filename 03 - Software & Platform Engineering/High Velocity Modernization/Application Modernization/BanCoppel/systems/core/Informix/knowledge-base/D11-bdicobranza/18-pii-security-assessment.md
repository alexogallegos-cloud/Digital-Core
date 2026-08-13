# D11 · Cobranza — Evaluación de Seguridad y PII

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicobranza` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, CONDUSEF, LFPDPPP |
| Datos financieros sensibles | ✅ SÍ |
| Datos de tarjeta (PCI-DSS) | ❌ NO |

## Inventario de campos PII (inferidos del análisis estático)

> **[SME-PENDING — Cybersecurity + DBA IBM Informix]** Completar con lista real de columnas PII desde `syscolumns`. Los campos abajo son candidatos inferidos por nombre:

| Campo candidato | Tipo de dato personal | Regulación | Acción requerida |
|----------------|----------------------|-----------|-----------------|
| `num_cte` / `numclt` | Número de cliente (identificador bancario) | CNBV | Tokenización en ambientes no-productivos |
| `num_tarjeta` / `no_tarjeta` | Número de tarjeta | PCI-DSS | Enmascarar primeros 12 dígitos; usar solo BIN+últimos 4 |
| `clabe` / `num_cuenta` | CLABE interbancaria / número de cuenta | CNBV + LFPDPPP | Cifrar en reposo (KMS CMK) |
| `nombre` / `ap_paterno` | Nombre completo del cliente | LFPDPPP | Anonimizar en ambientes de prueba |
| `correo` / `email` | Correo electrónico | LFPDPPP | Anonimizar (@bancoppel-test.com.mx) |
| `celular` / `telefono` | Número telefónico | LFPDPPP | Anonimizar (10 dígitos aleatorios) |
| `curp` / `rfc` | CURP / RFC | LFPDPPP + SAT | Cifrar en reposo; eliminar de logs |
| `fecha_nacimiento` | Fecha de nacimiento | LFPDPPP | Cifrar; agregar ruido en analítica |

## Controles AWS obligatorios

| Control | Servicio AWS | Configuración requerida |
|---------|-------------|------------------------|
| Cifrado en reposo | AWS KMS (CMK) | Una CMK por dominio; rotación anual automática |
| Cifrado en tránsito | TLS 1.2+ | Obligatorio en todas las APIs y conexiones Aurora |
| Anonimización en QA | AWS Macie + Lambda | Detectar PII y enmascarar antes de copiar a ambientes no-prod |
| Audit trail | AWS CloudTrail | Retención 5 años (CNBV); inmutable en S3 con Object Lock |
| Control de acceso | AWS IAM + Attribute-based access control | Mínimo privilegio por microservicio |
| Detección de anomalías | Amazon GuardDuty | Alertas automáticas por acceso inusual a datos PII |
| Red | VPC privada + Security Groups | Sin acceso directo a Aurora desde internet |

## Regulaciones aplicables — detalle por dominio

| Regulador | Obligación | Severidad |
|-----------|-----------|----------|
| CNBV | CUB criterio B-6 — calificación de cartera vencida (90 días) y estimaciones preventivas | 🔴 CRÍTICO |
| CNBV | Prácticas de cobranza reguladas — prohibición de hostigamiento | 🔴 ALTO |
| CNBV | Reporte R24C (cartera vencida y castigos) — mensual | 🔴 ALTO |
| CNBV | Castigos de cartera — procedimiento CNBV, requiere acta del Consejo | 🟠 MEDIO |
| CONDUSEF | Ley de Derechos del Deudor — prácticas de cobranza prohibidas (horarios, intimidación) | 🔴 ALTO |
| CONDUSEF | Si el cliente presenta aclaración de un adeudo en cobranza → suspender gestión durante la aclaración | 🟠 MEDIO |
| LFPDPPP | Datos de deudores — datos financieros sensibles; los despachos de cobranza externos que reciben datos deben tener DPA | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdicobranza` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Cartera vencida 90 días — CUB Criterio B-6 | El target debe traspasar créditos a cartera vencida exactamente a los 90 días de mora (no 89, no 91). El mismo criterio aplica para las estimaciones preventivas. Verificar que la migración no altera la fecha de inicio del conteo de mora para ningún crédito. | 🔴 CRÍTICO |
| **CNBV** | Prácticas de cobranza | El sistema target debe respetar los límites regulatorios: horarios de contacto (07:00-22:00), identificación del cobrador, prohibición de comunicarse con terceros no autorizados. Si el target tiene automatización de contacto (IVR, SMS de cobranza), verificar que cumple con estas restricciones. | 🔴 ALTO |
| **CONDUSEF** | Ley del Deudor — suspensión de cobranza durante aclaración | Si un cliente en cobranza presenta una aclaración ante CONDUSEF o ante BanCoppel, la gestión de cobranza debe suspenderse durante la duración de la aclaración. El target debe integrar esta validación con D07-bdiaclaracion. | 🟠 MEDIO |
| **LFPDPPP** | Despachos de cobranza externos | Si BanCoppel traslada gestiones de cobranza a despachos externos, estos reciben datos PII (nombre, RFC, CURP, monto adeudado, datos de contacto). Cada despacho debe tener DPA firmado. El target debe auditar qué datos se comparten con cada despacho. | 🔴 ALTO |

## Restricciones de ventana de cutover

- Evitar el cutover en los 3 últimos días hábiles del mes (cierre de calificación de cartera para reporte R24C).
- Si hay gestiones de cobranza activas en el momento del cutover, el target debe conocer el estado exacto de cada gestión para no reiniciar procesos incorrectamente.
- Los despachos de cobranza externos deben ser notificados del cambio de sistema y de la actualización de los archivos/APIs de trabajo.

## LFPDPPP — Transferencia a terceros

Despachos de cobranza externos (alto riesgo PII — verificar DPA). Buró de Crédito (reportar cartera vencida — verificar contrato y DPA).

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF · [SME-PENDING] inventario PII real requerido*
