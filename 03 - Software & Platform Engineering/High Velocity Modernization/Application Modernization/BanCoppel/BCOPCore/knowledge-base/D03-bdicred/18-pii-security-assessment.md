# D03 · Crédito — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicred` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)
- **SME Regulatorio — CONDUSEF** (`Solutioning/Delivery - SME/Regulatory/CONDUSEF/`)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, CONDUSEF, SAT, LFPDPPP |
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
| CNBV | CUB criterio B-6 — calificación de cartera crediticia (90 días → vencida) | 🔴 ALTO |
| CNBV | Reportes R10C (cartera de crédito) y R24C (cartera vencida) | 🔴 ALTO |
| CNBV | Art. 164 CUB — aviso 60 días por cambio en sistema de crédito | 🔴 ALTO |
| CONDUSEF | CAT (Costo Anual Total) — fórmula IRR obligatoria, publicación en contrato y EDC | 🔴 ALTO |
| CONDUSEF | RECO — comisiones de crédito registradas (apertura, disposición, mantenimiento) | 🔴 ALTO |
| SAT | CFDI 4.0 por comisiones cobradas y desembolsos (Art. 29 CFF) | 🔴 ALTO |
| SAT | ISR sobre intereses de crédito (retención si aplica al tipo de crédito) | 🟠 MEDIO |
| LFPDPPP | Datos crediticios son datos financieros sensibles (Art. 16 LFPDPPP) | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdicred` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | CUB Criterio B-6 | El sistema target debe implementar el traspaso a cartera vencida exactamente a los 90 días naturales de mora. Ni 89 ni 91 días. Verificar que la lógica de calificación crediticia produce los mismos resultados que Informix (test de equivalencia funcional de cartera). | 🔴 CRÍTICO |
| **CNBV** | Reporte R10C y R24C | Los datos de cartera que alimentan los reportes CNBV deben generarse idénticamente en el target. Cualquier diferencia en los saldos reportados → observación CNBV. | 🔴 CRÍTICO |
| **CONDUSEF** | CAT — LTOSF Art. 17 | El cálculo del CAT debe usar la fórmula IRR definida por CONDUSEF (no una simplificación). Un CAT incorrecto es sancionable. Incluir caso de prueba TC-CAT: verificar que el target produce el mismo CAT que Informix para cada tipo de crédito. | 🔴 CRÍTICO |
| **CONDUSEF** | RECO | Verificar en portal RECO de CONDUSEF que todas las comisiones de crédito de BanCoppel están registradas y que el target las cobra en los montos exactos registrados. | 🟠 MEDIO |
| **SAT** | CFDI 4.0 — Art. 29 CFF | El microservicio target de bdicred debe generar CFDI de ingreso por cada comisión cobrada (apertura, disposición de efectivo, anualidad) y CFDI de egreso en desembolsos cuando aplique. Validar que el PAC (Proveedor Autorizado de Certificación) está integrado en el target. | 🔴 CRÍTICO |
| **SAT** | ISR intereses — LISR Art. 54 | Si bdicred genera intereses pagados a clientes (créditos con pago de intereses al depositante, productos de ahorro vinculados), verificar retención de ISR al 0.90% anual (LIF 2026). Riesgo de MONEY rounding en la retención. | 🟠 MEDIO |

## Restricciones de ventana de cutover

- Evitar cutover en los 3 últimos días hábiles del mes (cierre de calificación de cartera CNBV — reportes R10C).
- Evitar cutover en días 20-25 de cualquier mes (SAT: vencimiento de balanza de comprobación que incluye crédito en D12).
- Verificar que CFDI de comisiones siga generándose correctamente desde el día 1 del cutover (si el microservicio target no genera CFDI antes del cutover → incumplimiento SAT).

## LFPDPPP — Transferencia a terceros

bdicred puede integrarse con buró de crédito (Círculo de Crédito, Buró de Crédito). Verificar DPA. Los datos de crédito enviados a buró son transferencias reguladas por LFPDPPP y CNBV.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF, SAT · [SME-PENDING] inventario PII real requerido*
