# D07 · Aclaraciones — Evaluación de Seguridad y PII

> **Componente:** Informix · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdiaclaracion` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)
- **SME Regulatorio — CNBV** (`SME/Regulatory/CNBV/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CONDUSEF, CNBV, LFPDPPP |
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
| CONDUSEF | sp_acl_regulatorio27 — equivalencia funcional LEGAL (no solo técnica) obligatoria | 🔴 CRÍTICO |
| CONDUSEF | Plazo máximo de resolución de aclaraciones: 45 días hábiles (5 días para cargos en el exterior) | 🔴 CRÍTICO |
| CONDUSEF | Abono provisional obligatorio si el cargo no reconocido supera umbral mientras dura la aclaración | 🔴 CRÍTICO |
| CONDUSEF | Buró de Entidades Financieras — los datos de quejas son públicos y permanentes | 🔴 ALTO |
| CONDUSEF | Proceso de conciliación ante CONDUSEF — no asistir genera fallo automático a favor del usuario | 🟠 MEDIO |
| CNBV | Registro de aclaraciones como parte del expediente del cliente | 🟠 MEDIO |
| CNBV | Art. 164 CUB — aviso 60 días si el sistema de aclaraciones cambia materialmente | 🔴 ALTO |
| LFPDPPP | Datos de aclaración contienen transacciones del cliente (datos financieros sensibles) | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdiaclaracion` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CONDUSEF** | sp_acl_regulatorio27 — Regulatorio 27 | Este es el SP más crítico de bdiaclaracion. Su equivalencia no es técnica — es LEGAL. Si el SP en el target produce un resultado diferente al de Informix en cualquier caso, el contrato de adhesión puede ser inválido ante CONDUSEF. Requiere validación del área legal de BanCoppel, no solo del equipo técnico. Nivel de equivalencia requerido: L4 (financiero, 0% divergencia). | 🔴 CRÍTICO |
| **CONDUSEF** | 45 días hábiles — LPDUSF Art. 50 | El sistema target debe tener un mecanismo de seguimiento de plazos que: (1) calcule el plazo en días hábiles bancarios (no naturales), (2) genere alertas automáticas a los 30, 40 y 44 días, (3) aplique el abono provisional automáticamente si el plazo vence sin resolución. Un sistema sin estas alertas es un riesgo operativo de multa CONDUSEF. | 🔴 CRÍTICO |
| **CONDUSEF** | Buró de Entidades Financieras | Cualquier fallo durante la migración que cause incumplimiento de plazos de aclaración se reflejará en el Buró de Entidades Financieras de BanCoppel. Los datos son públicos y permanentes. Un mes malo durante la migración afecta la reputación por años. | 🔴 ALTO |
| **CNBV** | Art. 164 CUB | Si el sistema de aclaraciones cambia materialmente (nuevo software, nueva plataforma), notificación 60 días a CNBV. | 🔴 ALTO |

## Restricciones de ventana de cutover

- ❌ NO realizar el cutover de D07 mientras haya aclaraciones abiertas cerca del vencimiento del plazo de 45 días hábiles.
- Inventariar TODAS las aclaraciones abiertas en Informix el día del cutover y migrarlas al target conservando la fecha de apertura original.
- El plazo de 45 días corre desde la fecha original de la aclaración — no se reinicia en el cutover.
- Alertas automáticas a días 30, 40 y 44 de cada aclaración deben estar activas desde el primer día en producción.

## LFPDPPP — Transferencia a terceros

bdiaclaracion puede integrarse con CONDUSEF (plataforma REUNE para conciliaciones). Verificar que la integración con REUNE está activa desde el target desde el primer día de producción.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CONDUSEF, CNBV · [SME-PENDING] inventario PII real requerido*
