# D04 · Cheques / Cuentas — Evaluación de Seguridad y PII

> **Componente:** LegacyCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdicheq` · Nivel PII: 🔴 ALTA
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
- **SME Regulatorio — TESOFE** (`SME/Regulatory/TESOFE/`)
- **SME Regulatorio — IPAB** (`SME/Regulatory/IPAB/`)
- **SME Regulatorio — CONDUSEF** (`SME/Regulatory/CONDUSEF/`)

> `[SME-PENDING]` = requiere sesión de validación con el experto indicado.
---


## Perfil de riesgo de datos

| Dimensión | Valor |
|-----------|-------|
| Contiene datos personales (PII) | ✅ SÍ — LFPDPPP aplica |
| Regulaciones aplicables | CNBV, TESOFE, IPAB, CONDUSEF, LFPDPPP |
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
| CNBV | Art. 164 CUB — aviso 60 días antes del cutover del sistema de cuentas (cambio material) | 🔴 CRÍTICO |
| CNBV | Atomicidad débito-crédito: débito debe asentarse o fallar completamente (sin débitos parciales) | 🔴 CRÍTICO |
| CNBV | Reportes R04A y R04D (captación de exigibilidad inmediata) — mensual | 🔴 ALTO |
| TESOFE | Dispersiones bimestrales Pensión Bienestar y Becas — restricción de ventana cutover | 🔴 CRÍTICO |
| TESOFE | Confirmación de dispersión TESOFE → SPEI → abono_ref: cualquier fallo durante migración = beneficiarios sin pago | 🔴 CRÍTICO |
| IPAB | Cuenta Única IPAB: saldo consolidado por CURP → bdicheq es componente principal | 🔴 CRÍTICO |
| IPAB | Post-cutover: 0% de diferencia aceptable en Cuenta Única vs. Informix | 🔴 CRÍTICO |
| CONDUSEF | Aclaraciones por cargos no reconocidos — 45 días hábiles (5 días para cargos en el exterior) | 🔴 ALTO |
| LFPDPPP | Datos de cuenta corriente son datos financieros sensibles | 🔴 ALTO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdicheq` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Art. 164 CUB — 60 días de aviso previo | bdicheq es el sistema de cuentas de captación — su migración es un cambio material. CNBV debe ser notificado con 60 días de anticipación. Sin notificación: sanción administrativa. | 🔴 CRÍTICO |
| **CNBV** | Atomicidad débito-crédito | El target debe garantizar que un débito y su crédito correspondiente son atómicos (ACID). En Informix esto estaba garantizado por el motor transaccional. En Aurora/PostgreSQL se debe implementar con transacciones explícitas y verificar que ningún fallo parcial deja un saldo inconsistente. | 🔴 CRÍTICO |
| **CNBV** | Reportes R04A/R04D | Los saldos de captación reportados al CNBV deben ser idénticos entre Informix y el target el día del cutover. Divergencia en saldos → inconsistencia en reporte regulatorio. | 🔴 ALTO |
| **TESOFE** | Dispersiones bimestrales | La cadena TESOFE → SPEI → bdicheq:abono_ref × N → bdimnsj:sp_registra_evento debe funcionar completa desde el primer día en producción. Coordinar ventana de cutover fuera de los períodos de dispersión bimestral. Ver SME TESOFE para calendario exacto. | 🔴 CRÍTICO |
| **IPAB** | Cuenta Única IPAB — LPAB Art. 22 | Ejecutar el proceso de Cuenta Única (saldo consolidado por CURP sumando bdicheq + D05-bdisac + D12-bdicont) en el primer día de producción. Comparar con el último reporte de Informix. Diferencia aceptable: 0%. Ver SME IPAB. | 🔴 CRÍTICO |
| **CONDUSEF** | Plazos de aclaración — LPDUSF Art. 50 y 50 Bis | bdicheq es el dominio que origina los cargos que dan lugar a aclaraciones. Si el cutover genera cargos incorrectos o duplicados → aclaraciones masivas → riesgo de vencimiento de 45 días → abono provisional obligatorio + multa CONDUSEF. | 🔴 ALTO |

## Restricciones de ventana de cutover

- ❌ EVITAR días 1-5 de cada bimestre (feb, abr, jun, ago, oct, dic): dispersión activa Pensión Bienestar y Becas TESOFE.
- ❌ EVITAR días 15 y último hábil del mes: quincenas de nómina de gobierno.
- ❌ EVITAR el mes previo al cierre IPAB mensual (coordinar con área de Operaciones la fecha de reporte Cuenta Única).
- ✅ VENTANA SEGURA: semanas 2-3 de bimestre, alejadas de dispersiones y quincenas.
- Notificar a CNBV con 60 días de anticipación (Art. 164 CUB).
- Ejecutar Cuenta Única IPAB en el primer día de producción y comparar 0% diferencia con el último reporte de Informix.

## LFPDPPP — Transferencia a terceros

bdicheq recibe dispersiones de TESOFE vía SPEI. Confirmar que la cuenta LegacyCore en Banxico está correctamente configurada para recibir transferencias en el ambiente de producción del target.

**[SME-PENDING — Cybersecurity + Legal LegacyCore]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, TESOFE, IPAB, CONDUSEF · [SME-PENDING] inventario PII real requerido*
