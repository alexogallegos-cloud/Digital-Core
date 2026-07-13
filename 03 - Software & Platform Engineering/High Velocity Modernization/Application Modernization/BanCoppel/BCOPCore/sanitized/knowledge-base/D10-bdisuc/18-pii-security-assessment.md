# D10 · Sucursales — Evaluación de Seguridad y PII

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisuc` · Nivel PII: 🔴 ALTA
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
| CNBV | Operación de sucursales — requisitos de apertura, cierre y cambio de horario | 🟠 MEDIO |
| CNBV | Registro de operaciones en sucursal (logs de cajero, operaciones de ventanilla) — retención 5 años | 🔴 ALTO |
| CNBV | Art. 164 CUB — si bdisuc maneja sistemas críticos de operación de sucursal | 🟠 MEDIO |
| CONDUSEF | Atención a usuarios en sucursal — proceso de aclaración presencial | 🟠 MEDIO |
| CONDUSEF | Módulo de Atención a Usuarios — el cajero/ventanilla debe poder recibir una queja CONDUSEF | 🟠 MEDIO |
| LFPDPPP | Datos capturados en sucursal (biometría, identificaciones) son datos sensibles | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdisuc` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Registro de operaciones de sucursal | Las operaciones de cajero y ventanilla deben quedar registradas con timestamp, usuario, tipo de operación y monto. Retención mínima: 5 años (CNBV). El target debe garantizar que el audit log es inmutable (AWS CloudTrail + S3 Object Lock). | 🔴 ALTO |
| **CONDUSEF** | Módulo de Atención a Usuarios (MAU) | Las sucursales son un punto de recepción de quejas CONDUSEF. El target debe integrar el módulo de quejas con el sistema de aclaraciones (D07-bdiaclaracion) para que el plazo de 45 días empiece a contar desde el momento en que el ejecutivo registra la queja, no desde que se notifica al sistema central. | 🟠 MEDIO |

## Restricciones de ventana de cutover

- El cutover de D10 debe coordinarse con el horario de sucursales. Idealmente durante un fin de semana largo (3 días) para dar tiempo a pruebas.
- Las sucursales deben poder operar en modo degradado (mínimo: consulta de saldo y retiros) si el target tiene problemas el día 1.
- Capacitar a ejecutivos de sucursal en el nuevo sistema antes del cutover — el personal que atiende quejas CONDUSEF debe saber usar el nuevo sistema de aclaraciones.

## LFPDPPP — Transferencia a terceros

bdisuc puede integrarse con proveedores de cajeros automáticos y terminales punto de venta. Verificar DPA con cada proveedor.

**[SME-PENDING — Cybersecurity + Legal LegacyCore]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF · [SME-PENDING] inventario PII real requerido*
