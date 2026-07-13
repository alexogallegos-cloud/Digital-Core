# D08 · SPEI — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdispei` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — Banxico** (`Solutioning/Delivery - SME/Regulatory/Banxico/`)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | Banxico, CNBV, LFPDPPP |
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
| Banxico | Circular 14/2017 (consolidada con Circular 12/2023 y 2/2025) — Reglas del SPEI | 🔴 CRÍTICO |
| Banxico | Recertificación técnica SPEI obligatoria antes del cutover — proceso de 4-6 semanas | 🔴 CRÍTICO |
| Banxico | Ventana de cutover SPEI: SOLO sábado 22:00 – domingo 06:00 CDMX | 🔴 CRÍTICO |
| Banxico | RTO SPEI < 2 horas; disponibilidad ≥ 99.95% en horario operativo | 🔴 CRÍTICO |
| Banxico | CoDi y DiMo usan SPEI como rail — un fallo en D08 afecta ambos | 🔴 ALTO |
| Banxico | Notificación a Banxico ≥ 5 días hábiles antes del cutover con detalle técnico | 🔴 CRÍTICO |
| CNBV | Circular 11/2023 — ciberseguridad en sistemas de pago: controles mínimos obligatorios | 🔴 ALTO |
| CNBV | Art. 164 CUB — aviso 60 días (cambio material en sistema SPEI) | 🔴 CRÍTICO |
| LFPDPPP | Los datos de origen/destino de transferencias SPEI son datos financieros sensibles | 🟠 MEDIO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdispei` | Severidad |
|-----------|-------|----------------------------------|----------|
| **Banxico** | Recertificación SPEI — Circular 14/2017 | La migración del sistema SPEI al target AWS requiere re-certificar ante Banxico: (1) Conectar el target al ambiente de certificación Banxico, (2) Ejecutar el plan oficial de pruebas (PACS.008, PACS.004, CAMT.029, pruebas de carga, failover), (3) Obtener el certificado de participación. Sin certificación → el cutover no procede. Plan B: mantener Informix para SPEI mientras se corrigen defectos. Ver SME Banxico para detalle completo. | 🔴 CRÍTICO |
| **Banxico** | Irrevocabilidad SPEI | El target debe tratar los pagos SPEI como irrevocables una vez que Banxico liquida. No puede implementarse un 'rollback' sobre un pago liquidado — solo PACS.004 (retorno voluntario del beneficiario). Cualquier lógica de reversión sobre pagos liquidados es una BRECHA regulatoria. | 🔴 CRÍTICO |
| **Banxico** | Ventana de mantenimiento | La ventana sábado 22:00 – domingo 06:00 CDMX NO es negociable. El cutover de D08 solo puede ejecutarse dentro de esta ventana. | 🔴 CRÍTICO |
| **Banxico** | ISO 20022 | Banxico está migrando SPEI a ISO 20022. Si el target se construye sobre el estándar anterior, puede requerir una segunda migración. Considerar implementar ISO 20022 directamente. Ver SME Banxico para calendario. | 🟠 MEDIO |
| **CNBV** | Circular 11/2023 — ciberseguridad en pagos | El target de SPEI debe cumplir los controles mínimos de ciberseguridad en sistemas de pago definidos por la CNBV: cifrado en tránsito TLS 1.3, HSM para claves, controles de acceso privilegiado, monitoreo en tiempo real, y plan de respuesta a incidentes con notificación en 2 horas. | 🔴 CRÍTICO |
| **CNBV** | Art. 164 CUB | El sistema SPEI es claramente material para BanCoppel. Notificación 60 días a CNBV con descripción del cambio, plan de continuidad, y plan de rollback. | 🔴 CRÍTICO |

## Restricciones de ventana de cutover

- ✅ ÚNICA VENTANA VÁLIDA: sábado 22:00 – domingo 06:00 CDMX (ventana de mantenimiento SPEI Banxico).
- ❌ PROHIBIDO cutover en cualquier día hábil bancario (SPEI opera 06:00-22:00 L-V).
- La recertificación técnica con Banxico debe completarse ANTES del cutover — planificar 4-6 semanas de buffer.
- Notificación formal a Banxico: ≥ 5 días hábiles antes del cutover, con detalle del plan técnico.
- Notificación a CNBV: ≥ 60 días antes (Art. 164 CUB).
- El primer lote SPEI del lunes siguiente debe ser supervisado por el equipo técnico y por Banxico.
- CoDi y DiMo deben probarse explícitamente como parte del plan de cutover — no son automáticos.

## LFPDPPP — Transferencia a terceros

bdispei se conecta directamente con Banxico (infraestructura SPEI). La conexión al ambiente de producción de Banxico es el proveedor crítico — no hay DPA (es regulación federal), pero sí hay un contrato de participante directo SPEI que debe actualizarse para el nuevo sistema.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: Banxico, CNBV · [SME-PENDING] inventario PII real requerido*
