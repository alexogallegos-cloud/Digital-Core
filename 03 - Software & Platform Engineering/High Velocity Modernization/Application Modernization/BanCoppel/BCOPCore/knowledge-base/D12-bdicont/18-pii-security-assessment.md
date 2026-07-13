# D12 · Contabilidad — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicont` · Nivel PII: 🟠 MEDIA
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
- **SME Regulatorio — SAT** (`Solutioning/Delivery - SME/Regulatory/SAT/`)
- **SME Regulatorio — IPAB** (`Solutioning/Delivery - SME/Regulatory/IPAB/`)
- **SME Regulatorio — CNBV** (`Solutioning/Delivery - SME/Regulatory/CNBV/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | SAT, IPAB, CNBV |
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
| SAT | Contabilidad Electrónica — Anexo 24: catálogo de cuentas, balanza mensual (vence día 25) | 🔴 CRÍTICO |
| SAT | NO realizar cutover en días 20-25 de ningún mes (período de envío de balanza a SAT) | 🔴 CRÍTICO |
| SAT | FATCA/CRS — datos de bdicont pueden alimentar los reportes anuales de junio | 🟠 MEDIO |
| SAT | CFDI de comisiones y operaciones registradas en contabilidad | 🟠 MEDIO |
| IPAB | Cuotas ordinarias IPAB (4 al millar sobre pasivos asegurados) — cálculo y pago desde bdicont | 🔴 CRÍTICO |
| IPAB | Cuenta Única IPAB — bdicont es uno de los 3 sistemas que aportan saldos (D04 + D05 + D12) | 🔴 CRÍTICO |
| IPAB | Cuotas IPAB se pagan vía SPEI a Banxico — coordinación con D08-bdispei | 🔴 ALTO |
| CNBV | Reportes R01 (balance general) y R01B — vencen día 5 hábil del mes siguiente | 🔴 CRÍTICO |
| CNBV | Criterios de Contabilidad para IC (CUB Anexo) — criterios B-1 a D-4 | 🔴 CRÍTICO |
| CNBV | Art. 164 CUB — aviso 60 días (cambio en sistema de contabilidad es material) | 🔴 CRÍTICO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdicont` | Severidad |
|-----------|-------|----------------------------------|----------|
| **SAT** | Contabilidad Electrónica — CFF Art. 28 Fracc. III + Anexo 24 RMF | El target debe poder generar: (1) catálogo de cuentas en formato XML SAT, (2) balanza de comprobación mensual en formato XML SAT (vence día 25 del mes siguiente), (3) pólizas y auxiliares ante requerimiento de auditoría. Cualquier migración que altere los códigos de cuenta o los formatos de exportación puede interrumpir el cumplimiento SAT. NO cortar D12 entre los días 20 y 25 de ningún mes. | 🔴 CRÍTICO |
| **SAT** | Período de restricción — Contabilidad Electrónica | El período prohibido para cutover de D12 es el más amplio de todos los dominios: días 20-25 del mes (SAT) + enero (cierre anual) + mayo-junio (FATCA) + noviembre-diciembre (ajuste ISR). La ventana ideal es julio o agosto-septiembre. | 🔴 CRÍTICO |
| **IPAB** | Cuotas ordinarias — LPAB Art. 22 | El target de bdicont debe calcular las cuotas IPAB (4 al millar anual sobre pasivos asegurados promedio del mes) y generar el pago vía SPEI a la cuenta IPAB en Banxico. El cálculo debe ser idéntico al de Informix. Diferencia en cuota pagada → sanción IPAB con intereses. | 🔴 CRÍTICO |
| **IPAB** | Cuenta Única — aporte de bdicont | Los saldos contables de D12-bdicont forman parte de la Cuenta Única IPAB (junto con D04 y D05). El proceso mensual de Cuenta Única debe consolidar los tres sistemas correctamente. | 🔴 CRÍTICO |
| **CNBV** | Reportes R01 y R01B — CUB | El balance general (R01) vence el día 5 hábil del mes siguiente. El target debe poder generar este reporte con los mismos saldos que Informix. Verificar que el cierre contable del target produce el mismo balance que el cierre de Informix para el mismo período de prueba. | 🔴 CRÍTICO |
| **CNBV** | Criterios de Contabilidad — CUB Criterio D-1 y D-2 | Los estados financieros en el target deben seguir los criterios contables CNBV (no solo NIF generales). En particular: devengamiento diario de intereses, categorización correcta de cartera, presentación del margen financiero como primera línea del estado de resultados. | 🔴 ALTO |

## Restricciones de ventana de cutover

- ❌ EVITAR días 20-25 de cualquier mes: envío de balanza de comprobación al SAT (Contabilidad Electrónica).
- ❌ EVITAR primera quincena de enero: cierre fiscal anual + actualización de catálogos SAT.
- ❌ EVITAR mayo-junio: reporte FATCA/CRS anual del SAT.
- ❌ EVITAR noviembre-diciembre: ajuste anual ISR + cierre fiscal.
- ❌ EVITAR el día 17 hábil del mes: fecha de pago de cuotas IPAB (bdicont genera el SPEI a Banxico).
- ❌ EVITAR días 1-5 hábiles del mes: vencimiento reportes R01/R01B CNBV.
- ✅ VENTANA RECOMENDADA: julio (posterior a FATCA, lejos del cierre) o agosto-septiembre.
- Notificación CNBV: 60 días antes (Art. 164 CUB).
- Validar que el catálogo de cuentas SAT (XML) es idéntico en el target antes del cutover.

## LFPDPPP — Transferencia a terceros

bdicont se conecta con el SAT (para Contabilidad Electrónica) y con Banxico (para el pago de cuotas IPAB vía SPEI). Confirmar que las credenciales de acceso al buzón tributario SAT y a la cuenta SPEI de Banxico están configuradas en el ambiente de producción del target.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: SAT, IPAB, CNBV · [SME-PENDING] inventario PII real requerido*
