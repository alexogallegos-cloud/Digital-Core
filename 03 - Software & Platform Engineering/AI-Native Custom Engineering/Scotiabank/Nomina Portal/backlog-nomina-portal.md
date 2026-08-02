# Backlog Inicial — Portal Empresas Nómina · Scotiabank México
> dt-product-owner · SPE-ANCE-001 · v0.1 · 2026-07-24
> Fuente: Análisis Portal Empresa Scotiabank (versión actual) + BIAN capacidades mapeadas + regulatorio MX

---

## Contexto

La nueva versión del Portal Empresas Nómina de Scotiabank México va **más allá del portal actual**: además de gestionar la apertura y seguimiento de cuentas nómina de empleados (modelo del portal actual), incluye la dispersión real de nómina vía SPEI y la generación de CFDI. El portal es el canal único B2B end-to-end.

### Roles de Usuario

| Rol | Abreviación | Descripción |
|-----|-------------|-------------|
| Administrador Empresa | ADMIN-EMP | Configuración empresa, gestión de usuarios, límites |
| Operador Nómina | OPER-NOM | Creación de nómina, carga de layout, instruir dispersión |
| Auditor Empresa | AUD-EMP | Solo lectura: movimientos, CFDI, historial |
| Administrador Scotiabank | ADMIN-SCO | Gestión interna de empresas, reportes regulatorios |

### Prioridades (MoSCoW por Épica)

| Épica | Prioridad | Sprint objetivo |
|-------|-----------|-----------------|
| EP-01 Autenticación | **Must** | S1 |
| EP-02 Dashboard | **Must** | S2 |
| EP-03 Gestión de Empresas | **Must** | S1 |
| EP-04 Gestión de Empleados | **Must** | S2–S3 |
| EP-05 Centros de Trabajo | **Should** | S3–S4 |
| EP-06 Dispersión de Nómina | **Must** | S3–S5 |
| EP-07 CFDI de Nómina | **Must** | S4–S5 |
| EP-08 Registros y Auditoría | **Should** | S4–S5 |
| EP-09 Administración Scotiabank | **Could** | S5–S6 |

---

## EP-01: Autenticación y Gestión de Acceso

**BIAN**: N/A (Auth transversal)
**Regulatorio**: CNBV CUB Art. 310 · LFPDPPP · PCI-DSS Req. 7–8

| ID | Historia | Rol | Criterios de Aceptación | ADR Bloqueante |
|----|----------|-----|------------------------|----------------|
| NP-001 | Como **usuario empresa**, quiero iniciar sesión con mis credenciales Scotiabank México empresariales para acceder al portal | ADMIN-EMP, OPER-NOM, AUD-EMP | Flujo OAuth2 PKCE · sesión JWT con expiración ≤1h · redirect a dashboard | `ADR-ANCE-004` |
| NP-002 | Como **ADMIN-EMP**, quiero que la sesión expire automáticamente después de 15 minutos de inactividad para cumplir con los controles de seguridad del banco | ADMIN-EMP | Timeout warning a los 12 min · cierre automático a los 15 min · redirect a login | `ADR-ANCE-004` |
| NP-003 | Como **ADMIN-EMP**, quiero invitar nuevos usuarios de mi empresa y asignarles un rol para delegar operaciones de nómina | ADMIN-EMP | Envío de invitación por email · asignación de rol (OPER-NOM / AUD-EMP) · activación por el invitado | `ADR-ANCE-004` |
| NP-004 | Como **ADMIN-EMP**, quiero revocar acceso de un usuario de mi empresa cuando ya no es parte del equipo | ADMIN-EMP | Revocación inmediata · sesión activa invalidada · auditoría del evento | `ADR-ANCE-004` |
| NP-005 | Como **ADMIN-EMP**, quiero ver el historial de accesos de los usuarios de mi empresa para detectar actividad inusual | ADMIN-EMP | Log: usuario · fecha-hora · IP · acción · exportable a Excel/CSV | — |
| NP-006 | Como **OPER-NOM**, quiero confirmar operaciones críticas (dispersión) con un segundo factor de autenticación para proteger fondos de la empresa | OPER-NOM | `[DATO-REQUERIDO: mecanismo 2FA: token hardware, OTP app, SMS]` · falla de 2FA cancela la operación | `ADR-ANCE-004` |

---

## EP-02: Dashboard

**BIAN**: `BN-PAY-001` Payroll Processing · `BN-TAR-001` Tarjeta Nómina
**Regulatorio**: CNBV (reportes de actividad)

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-007 | Como **OPER-NOM**, quiero ver en el dashboard un resumen del estado de mis empleados activos para tener visibilidad inmediata del padrón nómina | OPER-NOM, ADMIN-EMP | Indicadores: Total empleados activos · Con cuenta Scotiabank México · Sin cuenta · Bloqueados |
| NP-008 | Como **OPER-NOM**, quiero ver en el dashboard el estado de las dispersiones recientes para saber si los pagos fueron exitosos | OPER-NOM, ADMIN-EMP | Tabla: últimas 5 dispersiones · monto · estado · fecha · acceso rápido al detalle |
| NP-009 | Como **ADMIN-EMP**, quiero ver una gráfica del histórico de dispersiones de los últimos 3 meses para analizar tendencias de nómina | ADMIN-EMP | Gráfica de barras · eje X: semanas/meses · eje Y: monto total dispersado · filtro por periodo |
| NP-010 | Como **OPER-NOM**, quiero ver accesos rápidos a las acciones más frecuentes (nueva dispersión, carga de empleados) para acelerar mi flujo de trabajo | OPER-NOM | Mínimo 4 acciones rápidas configurables · responsive mobile |
| NP-011 | Como **ADMIN-EMP**, quiero ver en el dashboard los KPIs de cuenta de nómina (empleados por estado) para reportar internamente el nivel de adopción | ADMIN-EMP | Contadores: No iniciados · En proceso · Finalizados · Bloqueados · Vinculados |
| NP-012 | Como **ADMIN-SCO**, quiero un dashboard agregado con el total de empresas activas y sus métricas de dispersión para monitorear el producto a nivel banco | ADMIN-SCO | Vista global de todas las empresas · monto total dispersado en el mes · empresas con dispersiones fallidas |

---

## EP-03: Gestión de Empresas y Contrato

**BIAN**: `BN-CFR-001` Customer Facility Registration
**Regulatorio**: CNBV PLDFT · LFPDPPP

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-013 | Como **ADMIN-EMP**, quiero ver los datos de mi empresa (RFC, razón social, número de contrato nómina) para confirmar que el portal está correctamente configurado | ADMIN-EMP | Vista de datos de empresa: RFC · Razón Social · No. Contrato · CLABE cuenta origen · límites de dispersión |
| NP-014 | Como **ADMIN-EMP**, quiero configurar los límites de dispersión (máximo por empleado, máximo por nómina) para tener control de exposición financiera | ADMIN-EMP | Límite por empleado · límite por nómina · límite diario · requiere confirmación 2FA · registro en auditoría |
| NP-015 | Como **ADMIN-SCO**, quiero dar de alta una nueva empresa en el portal asignando su contrato nómina Scotiabank México para activarla en el sistema | ADMIN-SCO | Alta: RFC · Razón Social · No. Contrato · CLABE origen · límites · validación KYC `[DATO-REQUERIDO: proceso KYC Scotiabank México]` |
| NP-016 | Como **ADMIN-SCO**, quiero bloquear una empresa en el portal por instrucción del área de cumplimiento para suspender operaciones inmediatamente | ADMIN-SCO | Bloqueo inmediato · empresas bloqueadas no pueden instruir dispersiones · notificación al ADMIN-EMP |
| NP-017 | Como **ADMIN-EMP**, quiero ver los movimientos de la cuenta de nómina origen (cargos por dispersiones) para conciliar mi nómina internamente | ADMIN-EMP | Tabla de movimientos: fecha · concepto · monto · referencia SPEI · descargable a Excel/PDF |

---

## EP-04: Gestión de Empleados

**BIAN**: `BN-PAY-001` Payroll Processing · `BN-TAR-001` Tarjeta Nómina
**Regulatorio**: LFPDPPP (PII) · CNBV (identidad) · SAT (RFC/CURP validación)

### EP-04A: Alta de Empleados (Carga Individual)

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-018 | Como **OPER-NOM**, quiero registrar un empleado individualmente con sus datos personales y laborales para solicitar la apertura de su cuenta nómina Scotiabank México | OPER-NOM | Formulario: Nombre(s) · Apellidos · Género · RFC (validado mod-11) · CURP (validado) · Nacionalidad · Estado civil |
| NP-019 | Como **OPER-NOM**, al registrar un empleado, quiero capturar sus datos laborales (No. empleado, fecha ingreso, sueldo neto, centro de trabajo) para vincular correctamente el empleado al padrón | OPER-NOM | Campos laborales: No. empleado · Fecha ingreso · Ingreso mensual neto · No. sucursal · ID Centro de trabajo |
| NP-020 | Como **OPER-NOM**, quiero validar en tiempo real el RFC y CURP del empleado para evitar errores que retrasen la apertura de cuenta | OPER-NOM | RFC: 13 caracteres · checksum SHCP · CURP: 18 caracteres · validación formato SAT · error inline si inválido |
| NP-021 | Como **OPER-NOM**, quiero confirmar la carga de empleados con segundo factor de autenticación para proteger el proceso de alta | OPER-NOM | Modal 2FA obligatorio antes de enviar solicitud al banco · `[DATO-REQUERIDO: mecanismo 2FA]` |
| NP-022 | Como **OPER-NOM**, quiero asignar un empleado a uno o múltiples centros de trabajo para que su tarjeta llegue al lugar correcto | OPER-NOM | Selector de centro de trabajo · opción de múltiples CTs · CT por defecto de la empresa |

### EP-04B: Carga Masiva de Empleados

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-023 | Como **OPER-NOM**, quiero descargar la plantilla de carga masiva de empleados en formato Excel y TXT para preparar mis datos en el formato correcto | OPER-NOM | Descarga de plantillas: Excel con macros · Excel sin macros · TXT · Incluye instrucciones de llenado |
| NP-024 | Como **OPER-NOM**, quiero cargar un archivo de empleados en masa para registrar múltiples empleados en una sola operación | OPER-NOM | Soporta .xlsx y .txt · validación previa antes de enviar · reporte de errores por fila · máximo `[DATO-REQUERIDO]` empleados |
| NP-025 | Como **OPER-NOM**, cuando cargo un archivo con errores, quiero ver exactamente qué fila y campo tiene error para corregir sin recargar todo el archivo | OPER-NOM | Tabla de errores: No. fila · campo · descripción del error · ejemplo de valor válido · descargable |
| NP-026 | Como **OPER-NOM**, quiero cargar un archivo de empleados para múltiples centros de trabajo simultáneamente para no tener que hacer cargas separadas por centro | OPER-NOM | Columna ID Centro de trabajo en el layout · asignación automática por CT · validación que el CT existe |
| NP-027 | Como **OPER-NOM**, quiero confirmar la carga masiva con segundo factor de autenticación antes de enviar al banco | OPER-NOM | 2FA obligatorio · resumen: X empleados a registrar · X centros de trabajo afectados |

### EP-04C: Consulta y Estado de Empleados

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-028 | Como **OPER-NOM**, quiero buscar a un empleado por RFC, nombre o número de empleado para consultar su estado de cuenta nómina | OPER-NOM, AUD-EMP | Búsqueda en tiempo real · resultados mientras escribe · filtros: estado · centro de trabajo |
| NP-029 | Como **OPER-NOM**, quiero ver el detalle completo de un empleado (datos personales, estado de cuenta, historial de dispersiones) para gestionar incidencias | OPER-NOM, ADMIN-EMP | Vista detalle: datos personales (mascarado PII) · CLABE (últimos 6 visible) · No. tarjeta (últimos 4) · historial |
| NP-030 | Como **OPER-NOM**, quiero ver todos mis empleados ordenados por estado de cuenta para priorizar gestión de casos pendientes | OPER-NOM, ADMIN-EMP | Tabla con columnas configurables · filtros por estado · exportable a Excel |
| NP-031 | Como **OPER-NOM**, quiero actualizar datos de un empleado (salario, centro de trabajo) cuando hay cambios en su situación laboral | OPER-NOM | Edición de campos autorizados · CLABE solo actualizable vía proceso bancario · auditoría de cambios |
| NP-032 | Como **OPER-NOM**, quiero dar de baja a un empleado que sale de la empresa para desvincularlo del padrón nómina | OPER-NOM, ADMIN-EMP | Baja lógica con fecha efectiva · historial de dispersiones preservado · cuenta bancaria del empleado no se cierra |

---

## EP-05: Centros de Trabajo

**BIAN**: `BN-TAR-001` (distribución física de tarjetas)
**Regulatorio**: N/A directo

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-033 | Como **ADMIN-EMP**, quiero ver el directorio de mis centros de trabajo con sus datos, número de empleados asignados y stock de tarjetas para gestionar la logística de entrega | ADMIN-EMP | Tabla: ID CT · Nombre · Estado · Ciudad · No. empleados · Stock tarjetas · acciones |
| NP-034 | Como **ADMIN-EMP**, quiero registrar un nuevo centro de trabajo con su dirección y contactos para que Scotiabank México pueda enviar tarjetas ahí | ADMIN-EMP | Formulario: nombre · dirección completa · hasta 3 contactos (nombre, email, teléfono, área) · instrucciones de entrega |
| NP-035 | Como **ADMIN-EMP**, quiero cargar múltiples centros de trabajo desde un archivo para dar de alta mi red de sucursales en una sola operación | ADMIN-EMP | Descarga de plantilla CT · carga masiva · validación · reporte de errores |
| NP-036 | Como **ADMIN-EMP**, quiero registrar la recepción de una remesa de tarjetas en un centro de trabajo para confirmar que las tarjetas llegaron y asignarlas a los empleados | ADMIN-EMP | Ingreso de código de remesa · validación del código · resumen de tarjetas en la remesa · confirmación con 2FA · `[DATO-REQUERIDO: ¿maneja Scotiabank México remesas físicas?]` |
| NP-037 | Como **ADMIN-EMP**, quiero ver el historial de remesas recibidas por centro de trabajo para tener trazabilidad de la distribución de tarjetas | ADMIN-EMP | Tabla: No. remesa · fecha entrega · cantidad de tarjetas · estado · CT destinatario |

---

## EP-06: Dispersión de Nómina

**BIAN**: `BN-PAY-002` Payroll Execution · `BN-ODS-001` Payment Instruction · `BN-INT-001` SPEI Integration
**Regulatorio**: Banxico SPEI (Circular 14/2017) · PCI-DSS Req. 3 · CNBV CUB

> **Nota ADR**: EP-06 depende de `ADR-ANCE-001` (integración core bancario) y `ADR-ANCE-005` (SPEI gateway). Las historias se pueden diseñar pero no se pueden construir hasta que los ADR estén firmados.

### EP-06A: Creación de Nómina

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-038 | Como **OPER-NOM**, quiero crear una nueva nómina (quincena, semana, mes) especificando el periodo para preparar la dispersión | OPER-NOM | Campos: tipo de nómina · periodo (fecha inicio – fecha fin) · descripción · cuenta origen Scotiabank México preconfigurada |
| NP-039 | Como **OPER-NOM**, quiero cargar el layout de nómina con los importes de cada empleado para definir cuánto dispersar a cada uno | OPER-NOM | Descarga plantilla layout · upload Excel/TXT · validación de CLABEs · validación de importes > 0 · sin límites excedidos |
| NP-040 | Como **OPER-NOM**, cuando cargo un layout con errores, quiero ver exactamente qué fila tiene el problema para corregirlo antes de dispersar | OPER-NOM | Tabla de errores: fila · campo · descripción · CLABE inválida destacada · ningún error = layout válido |
| NP-041 | Como **OPER-NOM**, quiero ver un resumen de la nómina antes de dispersar (total empleados, monto total, monto disponible en cuenta origen) para confirmar que hay fondos suficientes | OPER-NOM | Resumen: Total empleados · Monto total a dispersar · Saldo disponible cuenta origen · Diferencia · Alerta si fondos insuficientes |
| NP-042 | Como **OPER-NOM**, quiero que el sistema valide en tiempo real que hay saldo suficiente en la cuenta origen antes de permitirme instruir la dispersión para evitar pagos rechazados | OPER-NOM | Consulta saldo `[DATO-REQUERIDO: core bancario Scotiabank México]` en tiempo real · si saldo < monto nómina → bloquear instrucción + mensaje claro |

### EP-06B: Autorización y Ejecución

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-043 | Como **OPER-NOM**, quiero instruir la dispersión de una nómina validada confirmando con segundo factor de autenticación para autorizar el pago | OPER-NOM | 2FA obligatorio · confirmación del monto total · no reversible después de autorización · estado cambia a PROCESANDO |
| NP-044 | Como **ADMIN-EMP**, quiero que dispersiones que superen cierto monto (umbral configurable) requieran doble autorización para proteger el patrimonio de la empresa | ADMIN-EMP | Umbral configurable por la empresa · notificación de pendiente de autorización · flujo de aprobación con 2FA del autorizador |
| NP-045 | Como **OPER-NOM**, quiero ver el estado de la dispersión en tiempo real (PROCESANDO → CONFIRMADO / RECHAZADO_PARCIAL) para saber si los pagos llegaron a los empleados | OPER-NOM | Polling cada 30 segundos o WebSocket · estado por empleado visible · código de rechazo Banxico si aplica |
| NP-046 | Como **OPER-NOM**, cuando un empleado tiene un rechazo SPEI, quiero ver el motivo específico para poder corregir los datos y reprocesar su pago | OPER-NOM | Código de rechazo Banxico (31 códigos) · descripción legible · acción sugerida · opción de reprocesar individualmente |
| NP-047 | Como **OPER-NOM**, quiero programar una dispersión para que se ejecute en una fecha y hora específica para automatizar el proceso de pago | OPER-NOM | Selector de fecha-hora · validación horarios SPEI (L-V 7am-5:30pm Banxico) · confirmación con 2FA · cancelable hasta T-1h |

### EP-06C: Historial y Consulta

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-048 | Como **AUDITOR**, quiero ver el historial completo de dispersiones por periodo para auditar los pagos de nómina | AUD-EMP, ADMIN-EMP | Filtros: periodo · estado · monto · paginación · ordenable por fecha |
| NP-049 | Como **AUDITOR**, quiero ver el detalle de una dispersión (lista de empleados pagados, montos, CLABEs, referencias SPEI) para proporcionar comprobantes ante una auditoría | AUD-EMP, ADMIN-EMP | Detalle por empleado · CLABE destino (mascarada) · monto · referencia SPEI 18 dígitos · estado |
| NP-050 | Como **OPER-NOM**, quiero descargar el comprobante de una dispersión en PDF para mis archivos contables | OPER-NOM, ADMIN-EMP | PDF con: empresa · periodo · total empleados · monto total · fecha-hora de instrucción · referencia interna · estado final |

---

## EP-07: CFDI de Nómina

**BIAN**: `BN-PAY-003` Payroll Tax & CFDI
**Regulatorio**: SAT CFDI complemento nómina v1.2 · CFF Art. 29-A · `[DATO-REQUERIDO: ¿Scotiabank México genera CFDI o solo el empleador?]`

> **Nota de dominio**: `[DATO-REQUERIDO: Confirmar si el portal Scotiabank México genera los CFDI de nómina del empleador hacia el SAT, o si el empleador es quien los genera externamente y el portal solo los adjunta/consulta]`

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-051 | Como **OPER-NOM**, quiero que el portal genere automáticamente el CFDI de nómina (complemento v1.2) para cada empleado pagado, para cumplir con mi obligación fiscal ante el SAT | OPER-NOM | CFDI generado por cada pago exitoso · XML válido complemento nómina v1.2 · firmado con sello del empleador · `[DATO-REQUERIDO: certificado del empleador]` |
| NP-052 | Como **AUDITOR**, quiero consultar y descargar el CFDI (XML y representación impresa PDF) de un empleado para un periodo específico para responder a solicitudes de revisión fiscal | AUD-EMP, OPER-NOM | Búsqueda por empleado + periodo · descarga XML · descarga PDF (representación impresa CFDI SAT) |
| NP-053 | Como **OPER-NOM**, quiero ver el estado de timbrado de los CFDIs (timbrados, con error, pendientes) para identificar qué empleados no tienen su comprobante fiscal | OPER-NOM | Vista: total CFDIs · timbrados · errores · porcentaje de éxito · detalle por empleado con error |
| NP-054 | Como **OPER-NOM**, cuando el timbrado de un CFDI falla, quiero ver el código de error del SAT y poder reintentarlo para resolver la incidencia sin contactar al banco | OPER-NOM | Código de error SAT · descripción · acción de remediación · reintento manual disponible por 72 horas |
| NP-055 | Como **OPER-NOM**, quiero descargar todos los CFDIs de una nómina comprimidos en un ZIP para entregar a mi equipo de contabilidad | OPER-NOM | ZIP con XMLs + PDFs de todos los empleados · nombre de archivo con convenio: `CFDI_NOMIINA_{AAAAMMDD}_{RFC}.zip` |

---

## EP-08: Registros y Auditoría

**BIAN**: `BN-GL-001` General Ledger · `BN-ODS-002` Operational Data
**Regulatorio**: CNBV CUB (logs 5 años) · PCI-DSS Req. 10 · LFPDPPP

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-056 | Como **AUDITOR**, quiero ver el historial completo de cargas de empleados (archivos subidos, fecha, usuario, resultado) para tener trazabilidad de cambios al padrón | AUD-EMP, ADMIN-EMP | Tabla: nombre archivo · fecha-hora · usuario · Total empleados · Exitosos · Con errores · estado final |
| NP-057 | Como **AUDITOR**, quiero ver el detalle de una carga específica (qué empleados se cargaron, cuáles tuvieron error, qué se corrigió) para auditar la integridad del padrón | AUD-EMP | Drill-down de la carga · lista por empleado: nombre · RFC · estado · error si aplica |
| NP-058 | Como **ADMIN-EMP**, quiero que todas las acciones de usuarios (quién hizo qué y cuándo) queden registradas en un log de auditoría para cumplir con los requisitos regulatorios | ADMIN-EMP | Log: usuario · acción · entidad afectada · fecha-hora · IP · no modificable por usuarios del portal |
| NP-059 | Como **ADMIN-EMP**, quiero exportar el log de auditoría de un periodo para incluirlo en mis reportes de control interno o auditorías externas | ADMIN-EMP | Exportable a Excel/CSV · filtrable por usuario · acción · periodo · máximo 12 meses por exportación |
| NP-060 | Como **AUDITOR**, quiero ver el estado detallado de cada empleado (No iniciado, En proceso, Documentado, Finalizado, Bloqueado, Vinculado) organizado por estado para gestionar casos | AUD-EMP, OPER-NOM | Vista Kanban o tabla por estado · contadores por estado · acciones disponibles por estado |
| NP-061 | Como **OPER-NOM**, quiero ver los empleados que requieren corrección o validación en sucursal para priorizar su atención y no retrasar el primer pago | OPER-NOM | Vista filtrada: "Por corregir" · "Validar en sucursal" · datos del empleado · tipo de error o pendiente |

---

## EP-09: Administración Scotiabank México (Back-Office)

**BIAN**: `BN-CMP-001` Compliance Monitoring · `BN-ORC-001` Orchestration
**Regulatorio**: CNBV CUB · PLDFT · Circular 14/2017 Banxico

| ID | Historia | Rol | Criterios de Aceptación |
|----|----------|-----|------------------------|
| NP-062 | Como **ADMIN-SCO**, quiero ver un reporte consolidado de todas las empresas activas (dispersiones del mes, empleados registrados, cargas recientes) para monitorear el producto | ADMIN-SCO | Dashboard ejecutivo: total empresas · total empleados · monto total dispersado mes · empresas con incidencias |
| NP-063 | Como **ADMIN-SCO**, quiero configurar los límites globales de dispersión por empresa y por producto para controlar la exposición de riesgo del banco | ADMIN-SCO | CRUD límites: por empresa · por tipo de nómina · límite diario global · requiere aprobación de dos ADMIN-SCO |
| NP-064 | Como **ADMIN-SCO**, quiero generar el reporte regulatorio de dispersiones de nómina para la CNBV en el formato requerido | ADMIN-SCO | Formato CNBV `[DATO-REQUERIDO: formato exacto]` · selección de periodo · exportable |
| NP-065 | Como **ADMIN-SCO**, quiero recibir alertas automáticas cuando una empresa tenga un alto porcentaje de rechazos SPEI para intervenir proactivamente | ADMIN-SCO | Alerta si tasa rechazo > 10% en una dispersión · canal: email + portal · acción: bloqueo automático opcional |

---

## Historias Técnicas (Tech Stories)

| ID | Historia técnica | Owner DT | Sprint |
|----|-----------------|----------|--------|
| NP-T-001 | Configurar CI/CD pipeline completo en GitHub Actions (11 stages) | dt-devops-engineer | S1 |
| NP-T-002 | Implementar estructura de proyecto Angular 20 con Signals-first + módulos base | dt-frontend-engineer | S1 |
| NP-T-003 | Implementar estructura Spring Boot 3.3 con configuración base (actuator, security, OTel) | dt-backend-engineer | S1 |
| NP-T-004 | Diseñar y aplicar migración Flyway V001 con tablas base (Empresa, Empleado, Nomina) | dt-dba | S1 |
| NP-T-005 | Implementar OpenAPI 3.1 contract de Nómina API (endpoints EP-04 y EP-06) | dt-solution-architect | S1–S2 |
| NP-T-006 | Configurar stack de observabilidad: OTel Agent + Collector + backend TBD | dt-devops-engineer | S1 |
| NP-T-007 | Implementar Pact contract tests: Frontend↔API · API↔Core Banking Adapter | dt-qa-engineer | S2 |
| NP-T-008 | Configurar External Secrets Operator en K8s para gestión de secrets | dt-devops-engineer | S1 |
| NP-T-009 | Diseñar Threat Model STRIDE del portal (flujos: login, carga, dispersión) | dt-security-engineer | S1 |
| NP-T-010 | Implementar Core Banking Adapter (mock) con interfaz definida para desbloquearlo en UAT | dt-backend-engineer | S2 |
| NP-T-011 | Configurar Testcontainers SQL Server 2022 para integration tests | dt-qa-engineer | S2 |
| NP-T-012 | Implementar layout de carga masiva de empleados (validador de Excel/TXT) | dt-backend-engineer | S2–S3 |

---

## Estadísticas del Backlog

| Métrica | Valor |
|---------|-------|
| Total historias funcionales | 65 |
| Total tech stories | 12 |
| Total historias | **77** |
| Épicas funcionales | 9 |
| Historias BLOQUEADAS por ADR | 15 (EP-01, EP-06) |
| DATO-REQUERIDO pendientes | 10 |
| Pantallas Scotiabank (portal actual — referencia) | 37 |
| Pantallas Scotiabank nueva versión estimadas | ~50 (incluye dispersión y CFDI, más allá del portal actual) |

---

## DATOs REQUERIDOS Consolidados

| # | Pregunta | Bloquea | Owner |
|---|----------|---------|-------|
| DR-001 | ¿Mecanismo de 2FA Scotiabank México? (token hardware, OTP app, SMS) | NP-006, NP-021, NP-027, NP-043 | dt-security-engineer → `ADR-ANCE-004` |
| DR-002 | ¿Qué productos de cuenta nómina tiene Scotiabank México? | NP-013, NP-015 | dt-product-owner → SME Industry Banking |
| DR-003 | ¿Scotiabank México distribuye tarjetas físicas a centros de trabajo o es solo CLABE digital? | EP-05 | dt-product-owner |
| DR-004 | ¿Layout de carga masiva: formato Scotiabank México propio o compatible SAT? | NP-023, NP-024 | dt-product-owner |
| DR-005 | ¿Algún paso requiere validación presencial en sucursal? | NP-028, NP-061 | dt-product-owner |
| DR-006 | ¿Portal Scotiabank México genera CFDI del empleador o solo adjunta/consulta? | EP-07 completo | dt-product-owner → SME SAT |
| DR-007 | ¿Certificado SAT del empleador para timbrado — quién lo gestiona? | NP-051 | dt-product-owner |
| DR-008 | ¿Formato reporte CNBV para dispersiones de nómina? | NP-064 | dt-product-owner → SME CNBV |
| DR-009 | ¿Portal gestiona múltiples contratos por grupo empresarial? | NP-013 | dt-product-owner |
| DR-010 | ¿Umbral de monto para doble autorización de dispersión? | NP-044 | dt-product-owner → cliente |

---

*Backlog generado por dt-product-owner · 2026-07-24 · v0.1*
*Próxima acción: revisar con Scotiabank México los DATOs REQUERIDOS y desbloquear ADR-ANCE-004*
