# D09 · Mensajería — Evaluación de Seguridad y PII

> **Componente:** BCOPCore · SPE-AM-001 · DESIGN Phase
> **Base de datos:** `bdimnsj` · Nivel PII: 🔴 ALTA
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
| CNBV | Circular 6/2017 — notificaciones obligatorias al cliente por transacciones en cuenta | 🔴 CRÍTICO |
| CNBV | Art. 164 CUB — aviso 60 días (cambio en el sistema de notificaciones bancarias) | 🔴 ALTO |
| CONDUSEF | Notificación al cliente sobre cargos no reconocidos como primer paso del proceso de aclaración | 🔴 ALTO |
| CONDUSEF | Notificación de cambios en comisiones con 30 días de anticipación al cliente | 🟠 MEDIO |
| LFPDPPP | Latinia y StrikeIron reciben datos PII de clientes (número celular, correo) — transferencia a terceros | 🔴 ALTO |
| LFPDPPP | Datos de mensajería (contenido de SMS/push) pueden contener saldos, montos — datos financieros sensibles | 🟠 MEDIO |

## Obligaciones regulatorias — por agente SME

> Cada obligación tiene un **SME Regulatorio** dueño que valida el cumplimiento. Consultar el CLAUDE.md del SME correspondiente para el análisis completo.

| Regulador | Norma | Obligación específica para `bdimnsj` | Severidad |
|-----------|-------|----------------------------------|----------|
| **CNBV** | Circular 6/2017 — notificaciones transaccionales | BanCoppel tiene obligación de notificar a los clientes por cada transacción relevante (cargos, abonos, pagos). El target debe garantizar que ninguna notificación se pierde durante el cutover. Las 10 tablas notif_online_* deben migrarse completamente y el patrón de partición debe reemplazarse por EventBridge en AWS. | 🔴 CRÍTICO |
| **CNBV** | Art. 164 CUB | El sistema de notificaciones es material (afecta a todos los clientes). Notificación 60 días a CNBV. | 🔴 ALTO |
| **CONDUSEF** | Notificación de cargos no reconocidos | La notificación por cargo no reconocido inicia el plazo de aclaración del cliente. Si el sistema de mensajería falla y un cliente no recibe la notificación del cargo, puede argumentar que no estaba informado. El target debe garantizar entrega de notificaciones con confirmación (delivery receipt de Latinia). | 🔴 ALTO |
| **LFPDPPP** | Latinia — DPA obligatorio | Latinia recibe datos personales (número de celular, contenido de mensajes con datos financieros). Verificar que: (1) existe DPA firmado con Latinia, (2) Latinia almacena datos en México o tiene transferencia internacional autorizada, (3) los datos de mensajería se eliminan de Latinia según las políticas de retención. | 🔴 CRÍTICO |
| **LFPDPPP** | sp_validacion_msj — EXECUTE PROCEDURE dinámico | El SP sp_validacion_msj usa EXECUTE PROCEDURE dinámico. En el análisis de dead code se identificó riesgo de llamadas a SPs que procesen PII sin control estático. El target debe auditar todas las rutas de ejecución dinámica para garantizar que el tratamiento de PII está documentado y controlado. | 🟠 MEDIO |

## Restricciones de ventana de cutover

- Las notificaciones deben seguir funcionando durante el cutover. El período sin notificaciones debe ser mínimo (máximo la ventana de mantenimiento de la madrugada).
- Si el cutover de D09 coincide con una dispersión TESOFE (días 1-5 bimestral), los clientes esperan notificación del abono. Un fallo en bdimnsj durante una dispersión → queja masiva CONDUSEF.
- Verificar que el feature flag cod_param='5' (que activa/desactiva ciertos tipos de notificación) está configurado correctamente en el target antes del cutover.
- Probar con Latinia que la integración en producción AWS está activa antes del cutover (Latinia es CRÍTICO para las notificaciones).

## LFPDPPP — Transferencia a terceros

Latinia (CRÍTICO — mensajería transaccional), StrikeIron (HIGH — validación de datos), Innovattia (MEDIUM). Cada proveedor debe tener DPA firmado. Latinia es el proveedor de mayor riesgo PII — revisar contrato y ubicación de servidores.

**[SME-PENDING — Cybersecurity + Legal BanCoppel]:**
- [ ] Identificar todos los proveedores que reciben datos personales de este dominio
- [ ] Verificar que cada proveedor tiene DPA firmado
- [ ] Confirmar que los servidores del proveedor están en México o tienen transferencia internacional autorizada
- [ ] Documentar base legal del tratamiento (consentimiento, contrato, obligación legal)

---
*Actualizado: 2026-07-03 · SMEs regulatorios: CNBV, CONDUSEF · [SME-PENDING] inventario PII real requerido*
