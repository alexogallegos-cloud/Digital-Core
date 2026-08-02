# D02 · Integración — Evaluación de Seguridad y PII

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdinteg` · Nivel PII: 🟠 MEDIA
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
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, LFPDPPP |
| Datos financieros sensibles | ✅ SÍ |
| Datos de tarjeta (PCI-DSS) | 🟡 POTENCIAL |

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
| CNBV | Circular 8/2022 — todos los servicios que bdinteg expone deben operar desde infraestructura cloud cumpliendo los 7 requisitos | 🔴 ALTO |
| CNBV | Art. 164 CUB — bdinteg es punto de integración de 11 dominios; su cambio es material | 🔴 ALTO |
| LFPDPPP | Transferencia de datos PII entre dominios a través del bus de integración | 🟠 MEDIO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdinteg` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Circular 8/2022 | Como capa de integración en cloud, bdinteg debe garantizar que todos los datos regulatorios en tránsito cumplan los requisitos de cifrado, auditoría y residencia en México. | 🔴 CRÍTICO |
| **CNBV** | Art. 164 CUB | El cambio del bus de integración que afecte la disponibilidad o el comportamiento de múltiples sistemas bancarios califica como cambio material → notificación 60 días. | 🔴 CRÍTICO |
| **LFPDPPP** | Art. 36 — Transferencia nacional | bdinteg transfiere datos PII entre dominios. Aunque sea transferencia interna, el tratamiento debe estar documentado en el aviso de privacidad. | 🟡 BAJO |

## Restricciones de ventana de cutover

- bdinteg es dependencia crítica de todos los dominios (los otros 11 dominios leen de él). El cutover de bdinteg debe preceder o ser simultáneo con el de los dominios dependientes.
- Sin restricción de fecha de calendario, pero la ventana de cutover debe coordinarse con Banxico si hay flujos SPEI integrados (D08 requiere notificación a Banxico ≥5 días hábiles).
- bdinteg debe exponer un catálogo API antes de que D09-bdimnsj pueda migrar completamente (dependencia documentada: 27 lecturas cross-DB de D09 a bdinteg).

## LFPDPPP — Transferencia a terceros

bdinteg integra con sistemas externos (SPEI, TEF, Latinia, StrikeIron según análisis D09). Verificar DPA y contratos de cada proveedor que recibe PII a través de este bus.

**[SME-PENDING — Cybersecurity + Legal LegacyCore]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV · [SME-PENDING] inventario PII real requerido*
