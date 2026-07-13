# D05 · Ahorro — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdisac` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, IPAB, SAT, LFPDPPP |
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
| CNBV | CUB criterio B-1 — captación tradicional: devengamiento diario de intereses obligatorio | 🔴 ALTO |
| CNBV | Art. 164 CUB — aviso 60 días (cambio material en sistema de ahorro) | 🔴 ALTO |
| CNBV | Reporte R04A (captación a plazo) — mensual | 🔴 ALTO |
| IPAB | Saldos de ahorro forman parte de la Cuenta Única por CURP (junto con bdicheq y bdicont) | 🔴 CRÍTICO |
| IPAB | Cobertura máxima: 400,000 UDIs por persona → los saldos deben reportarse correctamente | 🔴 ALTO |
| SAT | ISR sobre intereses — LISR Art. 54: tasa 0.90% anual (LIF 2026) | 🔴 ALTO |
| SAT | Exención por UMA: 5 UMAs anuales ($206,815.50 MXN aprox. en 2026) — no retener si intereses < umbral | 🔴 ALTO |
| SAT | GAT Real (Ganancia Anual Total Real) — cálculo obligatorio para cuentas de ahorro con rendimiento | 🟠 MEDIO |
| SAT | Constancia anual de intereses y retenciones para clientes | 🟠 MEDIO |
| LFPDPPP | Datos de ahorro y rendimientos son datos financieros sensibles | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdisac` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | CUB Criterio B-1 — devengamiento diario | El target debe devengar intereses diariamente (incluyendo fines de semana y festivos). Si Informix solo devengaba en días hábiles → hay una diferencia regulatoria que debe corregirse en el target o documentarse como CR explícito con sign-off del área de Cumplimiento. | 🔴 CRÍTICO |
| **IPAB** | Cuenta Única — LPAB | Los saldos de bdisac (ahorro) deben incluirse en la consolidación de la Cuenta Única IPAB por CURP. El proceso que genera el reporte mensual al IPAB debe incluir bdisac + bdicheq + bdicont. Diferencia post-cutover: 0%. | 🔴 CRÍTICO |
| **SAT** | ISR retención — LIF 2026 Art. 21 tasa 0.90% | El cálculo de retención de ISR sobre intereses en el target debe usar 0.90% anual (LIF 2026), no el valor histórico. Aplicar la fórmula: ISR_mensual = saldo_promedio × (0.90%/365) × días. Riesgo MONEY rounding: usar RoundingMode.HALF_EVEN en JDBC. | 🔴 CRÍTICO |
| **SAT** | Exención UMA — LISR Art. 93-XX-a) | Si el total de intereses anuales del cliente en BanCoppel es ≤ $206,815.50 MXN (5 × UMA 2026), no se retiene ISR. El sistema debe acumular intereses anuales por cliente para aplicar correctamente la exención. Un umbral hardcodeado con el valor UMA de años anteriores → DRIFT. | 🔴 ALTO |
| **SAT** | GAT Real — CONDUSEF + SAT | El GAT Real = rendimiento neto descontando inflación (INPC). Debe calcularse y publicarse en el estado de cuenta. Un INPC hardcodeado o no actualizado → error en el GAT Real → posible sanción CONDUSEF/SAT. | 🟠 MEDIO |

## Restricciones de ventana de cutover

- Evitar cutover en enero (semana 1): cierre fiscal anual SAT + actualización UMA INEGI.
- Evitar cutover en mayo-junio: reporte FATCA/CRS del SAT.
- Evitar cutover el día 17 hábil del mes (fecha de pago de cuotas IPAB desde D12-bdicont, pero los saldos de bdisac alimentan la base de cálculo).
- Ejecutar Cuenta Única IPAB en el primer día de producción incluyendo saldos de bdisac.

## LFPDPPP — Transferencia a terceros

bdisac puede integrarse con sistemas de inversión (CETES, Directo). Verificar DPA si hay transferencia de datos de clientes a plataformas de inversión.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, IPAB, SAT · [SME-PENDING] inventario PII real requerido*
