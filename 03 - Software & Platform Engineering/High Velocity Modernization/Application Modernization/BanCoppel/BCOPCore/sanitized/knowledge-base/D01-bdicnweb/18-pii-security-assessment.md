# D01 · Canal Web / Digital — Evaluación de Seguridad y PII

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicnweb` · Nivel PII: 🔴 ALTA
> **Última actualización:** 2026-07-03

---
**SME responsable:**
- Specialist — Informix SPL Analysis (análisis estático y equivalencias)
- DBA — IBM Informix IDS (schema real vía syscolumns — Etapa 2)
- Cloud Architect — AWS Banking (arquitectura target y servicios AWS)
- QA Lead — Equivalencia Funcional (golden master y criterios go/no-go)
- Core Banking Transformation (ACL design y API contracts)
- Industry Banking / Domain Expert LegacyCore (validación funcional)
- Cybersecurity (PII, CNBV, LFPDPPP, PCI-DSS)
- SRE & AIOps (observabilidad y runbooks)
- Data & ML — Data Architect (migración de datos, CDC Debezium)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, CONDUSEF, LFPDPPP |
| Datos financieros sensibles | 🟡 Parcial |
| Datos de tarjeta (PCI-DSS) | ❌ NO |

## Inventario de campos PII (inferidos del análisis estático)

> **[SME-PENDING — Cybersecurity + DBA IBM Informix]** Completar con lista real de columnas PII desde `syscolumns`. Los campos abajo son candidatos inferidos por nombre:

| Campo candidato | Tipo de dato personal | Regulación | Acción requerida |
|----------------|----------------------|-----------|-----------------|
| `num_cte` / `numclt` | Número de cliente (identificador bancario) | CNBV | Tokenización en ambientes no-productivos |
| `num_tarjeta` / `no_tarjeta` | Número de tarjeta | PCI-DSS | Enmascarar primeros 12 dígitos; usar solo BIN+últimos 4 |
| `clabe` / `num_cuenta` | CLABE interbancaria / número de cuenta | CNBV + LFPDPPP | Cifrar en reposo (KMS CMK) |
| `nombre` / `ap_paterno` | Nombre completo del cliente | LFPDPPP | Anonimizar en ambientes de prueba |
| `correo` / `email` | Correo electrónico | LFPDPPP | Anonimizar (@legacycore-test.com.mx) |
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
| CNBV | Circular 8/2022 (cloud pública) | 🔴 ALTO |
| CNBV | Art. 164 CUB — aviso 60 días por cambio material del sistema | 🔴 ALTO |
| CNBV | Circular 6/2017 — notificaciones obligatorias al cliente desde canal digital | 🟠 MEDIO |
| CONDUSEF | Disponibilidad del canal para gestión de aclaraciones (45 días hábiles) | 🔴 ALTO |
| CONDUSEF | Transparencia: CAT, comisiones y leyendas obligatorias en pantallas | 🟠 MEDIO |
| LFPDPPP | Aviso de privacidad visible y consentimiento antes de captura de datos | 🔴 ALTO |
| LFPDPPP | Cookies y tracking: base legal requerida | 🟡 BAJO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdicnweb` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Circular 8/2022 | El sistema en AWS debe cumplir los 7 requisitos de cloud pública: datos en México, derechos de auditoría CNBV, notificación de incidentes en 24 h, cláusulas contractuales con el proveedor cloud. | 🔴 CRÍTICO |
| **CNBV** | Art. 164 CUB | Notificar a CNBV con 60 días de anticipación antes del cutover de cualquier sistema material. D01 es el canal digital principal — califica como cambio material. | 🔴 CRÍTICO |
| **CNBV** | Circular 6/2017 | Notificaciones por transacciones deben seguir activas durante y después del cutover. Coordinar con D09-bdimnsj (mensajería). | 🟠 MEDIO |
| **CONDUSEF** | LTOSF Art. 18 Bis | Las pantallas del canal deben mostrar: estado de cuenta con ISR retenido, intereses, comisiones desglosadas, leyendas obligatorias CAT/GAT, y opción de aclaración. | 🔴 ALTO |
| **CONDUSEF** | RECO | Todas las comisiones cobradas vía el canal deben estar registradas en RECO. Verificar que el catálogo de comisiones del target coincide con el RECO de LegacyCore vigente. | 🟠 MEDIO |
| **LFPDPPP** | Art. 8 — Consentimiento | El aviso de privacidad y el consentimiento deben estar activos en el target desde el día 1 del cutover. Sin aviso visible → infracción INAI. | 🔴 ALTO |

## Restricciones de ventana de cutover

- Sin restricción de fecha específica para D01 — pero si bdicnweb cae durante un período de aclaración activo, los usuarios no pueden gestionar aclaraciones → riesgo CONDUSEF.
- Coordinar con D07-bdiaclaracion: el canal no debe caer mientras haya aclaraciones abiertas cerca del vencimiento de 45 días.
- Notificar a clientes con anticipación el mantenimiento (Circular 6/2017 aplica a notificaciones de cambios que afecten el servicio).

## LFPDPPP — Transferencia a terceros

bdicnweb integra con proveedores de identidad (biometría, OTP) y pasarelas de pago. Verificar DPA con cada proveedor.

**[SME-PENDING — Cybersecurity + Legal LegacyCore]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF · [SME-PENDING] inventario PII real requerido*
