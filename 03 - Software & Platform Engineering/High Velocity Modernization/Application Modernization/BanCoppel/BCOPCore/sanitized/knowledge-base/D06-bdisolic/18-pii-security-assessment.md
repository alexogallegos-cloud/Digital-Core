# D06 · Solicitudes — Evaluación de Seguridad y PII

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisolic` · Nivel PII: 🔴 ALTA
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
| CNBV | KYC — identificación de clientes antes de apertura de producto (CUB Cap. X PLD) | 🔴 CRÍTICO |
| CNBV | Art. 164 CUB — aviso 60 días si el sistema de apertura cambia materialmente | 🔴 ALTO |
| CNBV | Expedientes de clientes: datos de identificación obligatorios (INE, CURP, comprobante domicilio) | 🔴 ALTO |
| CONDUSEF | RECO — el producto ofertado debe tener contrato de adhesión registrado antes de la apertura | 🔴 ALTO |
| CONDUSEF | Información pre-contractual: CAT y condiciones deben mostrarse antes de la firma | 🟠 MEDIO |
| LFPDPPP | Consentimiento explícito al capturar datos para apertura de cuenta | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdisolic` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | KYC — CUB Capítulo X | El proceso de apertura en el target debe validar: INE/Pasaporte vigente, CURP, comprobante de domicilio. La base de datos de expedientes debe migrar completamente y los expedientes existentes deben seguir siendo accesibles post-cutover. | 🔴 CRÍTICO |
| **CNBV** | Art. 164 CUB | Si bdisolic es el sistema que registra la apertura de cuentas, su migración es material. Notificación 60 días a CNBV. | 🔴 ALTO |
| **CONDUSEF** | RECO — LTOSF Art. 6 | El target debe verificar que el producto que se ofrece está registrado en RECO antes de permitir la apertura. Un producto sin registro en RECO no puede contratarse legalmente. | 🔴 ALTO |
| **CONDUSEF** | Información pre-contractual | Antes de la firma digital del contrato, el sistema debe mostrar el CAT, la tasa de interés, las comisiones, y las leyendas obligatorias. Verificar que el flujo digital del target incluye este paso obligatorio. | 🟠 MEDIO |

## Restricciones de ventana de cutover

- Sin restricción de fecha de calendario crítica para D06.
- El target debe ser capaz de procesar solicitudes desde el primer día — el proceso de apertura de cuenta no puede interrumpirse.
- Verificar que los expedientes digitales en el target tienen los mismos campos requeridos por CNBV para KYC.

## LFPDPPP — Transferencia a terceros

bdisolic integra con el INE (validación de identidad) y CURP (RENAPO). Verificar que los servicios de validación tienen DPA firmado y están disponibles en el ambiente de producción del target.

**[SME-PENDING — Cybersecurity + Legal LegacyCore]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF · [SME-PENDING] inventario PII real requerido*
