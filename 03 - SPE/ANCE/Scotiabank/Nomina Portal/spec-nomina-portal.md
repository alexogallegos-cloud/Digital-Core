# Component Spec — Portal Empresas Nómina · Scotiabank México
> §16 DC Universal Rules · Component Specification Standard · SPE-ANCE-001
> Estado: `[STATE: DRAFT · DISCOVER]` · v0.3 · Última actualización: 2026-07-24
> Owner: dt-solution-architect · Contribuyen: dt-product-owner · dt-banking-domain · dt-dba · dt-security-engineer
> SME consultado: Spec Design & Standards (`SME/Technology/Software Engineering/Spec-Driven Development/Specialist - Spec Design & Standards/`)
> Contrato ejecutable: `api/openapi-nomina-portal.yaml` (contract-first · seed del `ADR-ANCE-002`)

---

## 0. Índice

1. Identificación
2. Visión de Producto y Alcance
3. Actores y Roles
4. Módulos Funcionales
5. Modelo de Dominio
6. Máquinas de Estado
7. Arquitectura de Componentes
8. Superficie de API (resource groups)
9. Integración con el Core Bancario
10. Integración SPEI/CoDi y CFDI
11. Modelo de Datos y Clasificación PII/PCI
12. Seguridad, Identidad y Accesos
13. Reglas de Negocio y Validaciones
14. Requisitos No Funcionales (SLOs)
15. Regulatorio y Compliance
16. Capacidades BIAN
17. Observabilidad
18. Alcance del Mock vs. Producto
19. Datos Requeridos (DoR blockers)
20. Trazabilidad

---

## 1. Identificación

| Campo | Valor |
|-------|-------|
| Component ID raíz | `SPE-ANCE-001` |
| Nombre | Portal Empresas Nómina |
| Tipo | Sistema compuesto: Frontend SPA + Backend API + Core Banking Adapter + SPEI Adapter + DB |
| Cliente | Scotiabank México |
| Sub-offering | AI-Native Custom Engineering (03 S&PE) |
| Modelo de delivery | Digital Twin Swarm (9 DTs) |
| Owner técnico | dt-solution-architect |
| Product Owner | dt-product-owner |
| Estado SDLC | `DISCOVER` |
| Modelo de despliegue | Standalone integrado al Portal Empresa existente (`ADR-ANCE-007`) |

---

## 2. Visión de Producto y Alcance

### Visión
Plataforma B2B que permite a las empresas clientes de Scotiabank México **digitalizar end-to-end el ciclo de nómina bancaria**: desde el alta de empleados y la apertura de su cuenta nómina, hasta la dispersión de pagos vía SPEI y la emisión del CFDI de nómina. Hoy este proceso es mayoritariamente manual; el portal lo convierte en un flujo self-service, trazable y regulatoriamente conforme.

### Objetivos de producto
1. Reducir el tiempo de alta de empleados y apertura de cuenta nómina de días (manual) a minutos (self-service).
2. Ejecutar dispersiones de nómina masivas con validación previa y trazabilidad completa por empleado.
3. Emitir y resguardar el CFDI de nómina conforme SAT 4.0 dentro del mismo portal.
4. Dar a la empresa visibilidad en tiempo real del estado de cuentas, dispersiones y comprobantes.

### En alcance (producto)
- Gestión de empresas y su contrato de nómina (dentro del portal).
- Gestión de empleados: alta individual y masiva, consulta, actualización, baja.
- Gestión de centros de trabajo y (si aplica) recepción de tarjetas.
- Creación de nómina, carga de layout, validación, dispersión vía SPEI.
- Generación, consulta y descarga de CFDI de nómina.
- Registros, auditoría y reportes operativos y regulatorios.
- Identidad y accesos (IAM propio en mock → SSO federado en prod).

### Fuera de alcance
- El core bancario (se consume, no se construye ni se reemplaza).
- El Portal Empresa existente (el portal de nómina se integra a él, no lo modifica).
- Timbrado fiscal PAC — se consume un PAC `[DATO-REQUERIDO]`, no se implementa.
- Originación/KYC de la empresa como cliente del banco (proceso bancario externo; el portal recibe la empresa ya dada de alta o la registra según `DR-011`).

---

## 3. Actores y Roles

| Rol | Código | Descripción | Origen |
|-----|--------|-------------|--------|
| Administrador Empresa | `ADMIN_EMPRESA` | Configura la empresa, gestiona usuarios, define límites | Usuario empresa |
| Operador Nómina | `OPERADOR_NOMINA` | Crea nómina, carga layout, instruye dispersión | Usuario empresa |
| Auditor Empresa | `AUDITOR` | Solo lectura: movimientos, CFDI, historial | Usuario empresa |
| Administrador Scotiabank | `ADMIN_SCO` | Back-office: alta/bloqueo de empresas, límites globales, reportes CNBV | Usuario interno banco |

Modelo de autorización idéntico en mock y producción (`@PreAuthorize` por rol). Solo cambia el emisor de identidad (`ADR-ANCE-004`).

---

## 4. Módulos Funcionales

Mapeo a las épicas del backlog (`backlog-nomina-portal.md`).

| Módulo | Épica | Descripción | Componentes |
|--------|-------|-------------|-------------|
| M1 · Autenticación y Accesos | EP-01 | Login, gestión de usuarios, roles, 2FA, sesión | 001, 002, 004, 005 |
| M2 · Dashboard | EP-02 | KPIs de empleados, dispersiones, gráficas | 001, 002 |
| M3 · Gestión de Empresas | EP-03 | Datos de empresa, contrato, límites, movimientos cuenta origen | 001, 002, 003, 005 |
| M4 · Gestión de Empleados | EP-04 | Alta individual/masiva, consulta, actualización, baja | 001, 002, 003, 005 |
| M5 · Centros de Trabajo | EP-05 | Directorio, alta, carga masiva, recepción de tarjetas | 001, 002, 005 |
| M6 · Dispersión de Nómina | EP-06 | Creación de nómina, layout, validación, dispersión SPEI, seguimiento | 001, 002, 003, 006, 005 |
| M7 · CFDI de Nómina | EP-07 | Generación, timbrado, consulta, descarga | 001, 002, 005 |
| M8 · Registros y Auditoría | EP-08 | Historial de cargas, log de auditoría, estados por empleado | 001, 002, 005 |
| M9 · Administración Scotiabank | EP-09 | Back-office: empresas, límites globales, reportes regulatorios | 001, 002, 005 |

---

## 5. Modelo de Dominio

### Entidades principales

```
Empresa 1──N Usuario
Empresa 1──N CentroTrabajo
Empresa 1──N Empleado
Empresa 1──N Nomina
CentroTrabajo 1──N Empleado
Nomina 1──N DetalleNomina (renglón por empleado)
Nomina 1──1 Dispersion
Dispersion 1──N MovimientoDispersion (por empleado)
MovimientoDispersion 1──0..1 CFDI
Empleado 1──N CFDI
Empresa 1──N RegistroAuditoria
```

### Diccionario de entidades (atributos clave)

**Empresa** — cliente de nómina (owner: dt-banking-domain)
`idEmpresa (UUID)` · `numeroContrato` · `rfcEmpresa` · `razonSocial` · `claveGiro` · `clabeOrigen` · `numeroCuenta` · `limiteDispersionNomina` · `limiteDispersionEmpleado` · `limiteDispersionDiario` · `requiereDobleAutorizacion` · `montoUmbralAutorizacion` · `estadoEmpresa {ACTIVA, BLOQUEADA, SUSPENDIDA_PLDFT, INACTIVA}` · `perfilRiesgoPLDFT {BAJO, MEDIO, ALTO}` · `idGrupoEmpresarial?` · `idClienteCore` `[DATO-REQUERIDO]`

**Usuario** — operador del portal
`idUsuario (UUID)` · `idEmpresa` · `email` · `nombre` · `rol {ADMIN_EMPRESA, OPERADOR_NOMINA, AUDITOR, ADMIN_SCO}` · `estado {ACTIVO, INVITADO, REVOCADO}` · `passwordHash` (solo mock) · `subjectIdP` (solo prod/SSO) · `ultimoAcceso`

**Empleado** — persona con cuenta nómina
`idEmpleado (UUID)` · `idEmpresa` · `idCentroTrabajo` · `numeroEmpleado` · `nombres` · `primerApellido` · `segundoApellido` · `rfc` **(PII)** · `curp` **(PII)** · `genero` · `nacionalidad` · `estadoCivil` · `fechaIngreso` · `ingresoMensualNeto` **(PII)** · `numeroCuenta` **(PCI)** · `clabe` **(PCI)** · `numeroTarjeta` **(PCI, tokenizado)** · `estadoCuenta {NO_INICIADA, EN_PROCESO, DOCUMENTADA, FINALIZADA, VINCULADA, BLOQUEADA, ELIMINADA}` · `estadoDeposito {DESBLOQUEADA, BLOQUEADA}` · `estadoCargo {DESBLOQUEADA, BLOQUEADA}`

**CentroTrabajo**
`idCentroTrabajo (UUID)` · `idEmpresa` · `nombre` · `sucursalAsignada` · `direccion {calle, numExt, numInt, colonia, cp, municipio, estado}` · `contactos[1..3] {nombre, email, telefono, area}` · `instruccionesEntrega` · `totalEmpleados` · `tarjetasAsignadas`

**Nomina** — cabecera de un ciclo de pago
`idNomina (UUID)` · `idEmpresa` · `tipo {SEMANAL, QUINCENAL, MENSUAL, EXTRAORDINARIA}` · `periodoInicio` · `periodoFin` · `descripcion` · `estado {BORRADOR, LAYOUT_CARGADO, VALIDADA, EN_AUTORIZACION, AUTORIZADA, DISPERSANDO, CONFIRMADA, RECHAZADA_PARCIAL, CANCELADA}` · `montoTotal` · `totalEmpleados` · `fechaProgramada?`

**DetalleNomina** — renglón por empleado en la nómina
`idDetalle (UUID)` · `idNomina` · `idEmpleado` · `clabeDestino` **(PCI)** · `importe` · `estadoRenglon {VALIDO, ERROR}` · `mensajeError?`

**Dispersion** — ejecución de la nómina
`idDispersion (UUID)` · `idNomina` · `estado {PENDIENTE, PROCESANDO, CONFIRMADA, RECHAZADA_PARCIAL}` · `fechaInstruccion` · `usuarioInstruye` · `usuarioAutoriza?` · `referenciaInterna` · `montoDispersado`

**MovimientoDispersion** — resultado por empleado
`idMovimiento (UUID)` · `idDispersion` · `idEmpleado` · `importe` · `clabeDestino` **(PCI)** · `estado {ENVIADO, CONFIRMADO, RECHAZADO}` · `referenciaSPEI` (clave de rastreo 18) · `codigoRechazoBanxico?` · `fechaConfirmacion?`

**CFDI** — comprobante fiscal de nómina
`idCFDI (UUID)` · `idMovimiento` · `idEmpleado` · `uuidSAT` (folio fiscal) · `estadoTimbrado {PENDIENTE, TIMBRADO, ERROR}` · `xml` (resguardo) · `codigoErrorSAT?` · `fechaTimbrado?`

**RegistroAuditoria** — bitácora inmutable
`idRegistro (UUID)` · `idEmpresa` · `idUsuario` · `accion` · `entidadAfectada` · `idEntidad` · `timestamp` · `ipOrigen` · `detalle (JSON)`

**CargaMasiva** — trazabilidad de archivos cargados
`idCarga (UUID)` · `idEmpresa` · `tipo {EMPLEADOS, CENTROS, LAYOUT_NOMINA}` · `nombreArchivo` · `usuario` · `fecha` · `totalRegistros` · `exitosos` · `conError` · `estado`

---

## 6. Máquinas de Estado

### 6.1 Ciclo de vida de la cuenta del Empleado
```
NO_INICIADA → EN_PROCESO → DOCUMENTADA → FINALIZADA → VINCULADA
                  │              │
                  └──────────────┴──→ BLOQUEADA
                                       ELIMINADA (baja lógica)
```
- `VINCULADA`: cuenta abierta + tarjeta/CLABE asignada → elegible para dispersión.
- Solo empleados en `FINALIZADA` o `VINCULADA` pueden recibir dispersión.

### 6.2 Ciclo de vida de la Nómina / Dispersión
```
BORRADOR → LAYOUT_CARGADO → VALIDADA → [EN_AUTORIZACION] → AUTORIZADA → DISPERSANDO
                 │              │                                            │
              (errores)     (fondos                            ┌────────────┴────────────┐
                 ↓          insuficientes)                     ↓                         ↓
            LAYOUT_CARGADO   ← ─ ─ ─ ─ ─                  CONFIRMADA              RECHAZADA_PARCIAL
                                                                                        │
                                                            (reproceso individual por empleado)
            CANCELADA (hasta antes de AUTORIZADA)
```
- `EN_AUTORIZACION` solo si `montoTotal ≥ montoUmbralAutorizacion` y `requiereDobleAutorizacion = true`.
- Transición a `DISPERSANDO` es irreversible (fondos comprometidos).

### 6.3 Ciclo de vida del CFDI
```
PENDIENTE → TIMBRADO
     │
     └──→ ERROR → (reintento manual ≤ 72h) → TIMBRADO
```

---

## 7. Arquitectura de Componentes

Detalle en `component-catalog-nomina-portal.md` y `reference-architecture-nomina-portal.md`.

| Component ID | Nombre | Tipo | Stack |
|--------------|--------|------|-------|
| `SPE-ANCE-001` | Frontend Portal | SPA | Angular 20 · Signals · Nginx |
| `SPE-ANCE-002` | Nómina API | Microservicio síncrono | Java 21 · Spring Boot 3.3 · Virtual Threads |
| `SPE-ANCE-003` | Core Banking Adapter | Microservicio (ACL) | Java 21 · Spring Boot 3.3 |
| `SPE-ANCE-004` | Auth Gateway | Servicio de identidad | Java 21 · Spring Security (mock JWT · OIDC prod) |
| `SPE-ANCE-005` | Nómina DB | Persistencia | MS SQL Server 2022 |
| `SPE-ANCE-006` | SPEI Adapter | Microservicio (ACL) | Java 21 · Spring Boot 3.3 |

Principios: API-First / Contract-First · Anti-Corruption Layer hacia core y SPEI · Standalone integrado al portal existente · Defense in Depth · 12-Factor · Virtual Threads · Signals-first.

### 7.1 Estándar de UI del mock (paridad visual + branding)

Las pantallas del mock replican la **forma y la funcionalidad** del Portal Empresa de referencia, con la marca Scotiabank. Estándar transversal (aplica a toda pantalla nueva):

- **Branding**: logo Scotiabank y paleta de marca. Rojo Scotia (`#EC111A`, hover `#C30F16`) **solo como acento** (logo, botón primario, estado de navegación activo). Superficies blancas, texto `#1a1a1a`, fondo `#f4f5f7`. Tokens en `styles.scss` (`--np-color-*`).
- **Chrome (mock)**: sidebar blanco con logo arriba, contexto de empresa (contrato/modelo), navegación con íconos en rojo (activo = fondo rosa tenue + barra roja izquierda), Ayuda y Cerrar sesión al pie. Topbar con título + usuario + rol. En prod (`ADR-ANCE-007`) el chrome lo provee el Portal Empresa padre; esta SPA solo aporta el contenido.
- **Paleta de gráficas**: categórica de baja saturación (ámbar, azul, teal, verde, morado, coral) — no colores saturados.
- **Regla de fondo (no negociable)**: la paridad visual **no** implica datos falsos. Toda cifra, gráfica, tabla o descarga se alimenta de un endpoint real respaldado por BD; nada se hardcodea en el frontend.
- **Marca compartible**: los artefactos externos/compartibles (decks, HTML de propuesta) se mantienen genéricos y sin nombre de cliente; el branding Scotiabank vive solo dentro del mock funcional.

---

## 8. Superficie de API (resource groups)

Contrato detallado en OpenAPI 3.1 (`ADR-ANCE-002`, pendiente). Base: `/api/v1/`.

| Grupo | Recursos principales | Módulo |
|-------|---------------------|--------|
| `/auth` | `POST /login` · `POST /refresh` · `POST /logout` · `POST /2fa/verify` | M1 |
| `/usuarios` | CRUD usuarios de empresa · asignación de rol · revocación | M1 |
| `/empresas` | `GET/PUT /empresas/{id}` · `/limites` · `/movimientos` | M3 |
| `/empleados` | CRUD · `POST /carga-masiva` · `GET /buscar` · `PATCH /{id}/baja` | M4 |
| `/centros-trabajo` | CRUD · `POST /carga-masiva` · `POST /{id}/remesas` | M5 |
| `/nominas` | `POST` · `POST /{id}/layout` · `POST /{id}/validar` · `GET /{id}/resumen` | M6 |
| `/dispersiones` | `POST /nominas/{id}/dispersar` · `POST /autorizar` · `GET /{id}/estado` · `POST /{id}/reprocesar` | M6 |
| `/cfdi` | `GET /cfdi` · `GET /{id}/xml` · `GET /{id}/pdf` · `POST /{id}/reintentar` · `GET /nominas/{id}/zip` | M7 |
| `/registros` | `GET /cargas` · `GET /auditoria` · `GET /empleados/estados` | M8 |
| `/admin` | `POST /empresas` · `PATCH /empresas/{id}/bloqueo` · `GET /reportes/cnbv` | M9 |
| `/dashboard` | `GET /dashboard` (resumen agregado: empleados por estado, nóminas por estado, centros de trabajo) | M2 |

### Estándares de contrato (aplicados por SME Spec Design & Standards)
- **Contract-first**: el OpenAPI 3.1 (`api/openapi-nomina-portal.yaml`) se escribe antes del código; el mock server y los contract tests salen de él.
- **`operationId`** obligatorio en camelCase en cada operación (nombre de función en los SDKs generados).
- **`additionalProperties: false`** en todo schema de request (evita campos inesperados).
- **Ejemplos obligatorios** por operación (es el contrato que el consumer entiende primero).
- **Errores RFC 9457** (Problem Details, supersede RFC 7807) — envelope de error consistente.
- **Versioning URI** (`/api/v1/`) — default bancario, enruta por path en el gateway.
- **Idempotencia** (`Idempotency-Key` header) obligatoria en dispersión y toda operación no-idempotente con efecto financiero.
- **Dinero nunca en float/double**: `BigDecimal` en Java · `DECIMAL(18,2)` en SQL Server · string-encoded decimal en JSON (evita errores de punto flotante — en banca es incidente P1).
- **Uniones discriminadas** (`oneOf` + `discriminator`) para representar estados/tipos mutuamente excluyentes.
- **Paginación** cursor por default en listados de alto volumen (empleados, movimientos).

### 8.1 Dashboard (M2) — agregación en BD, no en cliente

`GET /api/v1/dashboard` (operationId `getDashboardResumen`) devuelve el resumen operativo de la empresa. Los conteos se calculan con `GROUP BY` en SQL Server, acotados a `idEmpresa` (aislamiento multi-tenant), **nunca derivados en el frontend**. Disponible para los tres roles de empresa (el `AUDITOR` es solo lectura).

Payload `DashboardResumen`:

| Campo | Tipo | Origen |
|-------|------|--------|
| `empleadosPorEstado` | `[{estado, total}]` | `Empleado` agrupado por `estadoCuenta`, excluye `ELIMINADA` (baja lógica) |
| `totalEmpleados` | `long` | conteo de empleados activos de la empresa |
| `nominasPorEstado` | `[{estado, total}]` | `Nomina` agrupada por `estado` |
| `totalNominas` | `long` | conteo de nóminas de la empresa |
| `centros` | `[{idCentroTrabajo, nombre, sucursal}]` | `CentroTrabajo` de la empresa |
| `totalCentros` | `long` | conteo de centros |

Consumo en frontend (pantalla P-INI-01): tarjeta "Carga de empleados" (barras horizontales por estado), "Cuentas de empleados" (donut SVG), panel "Nóminas" y panel "Centros de trabajo". El listado "Empleados recientes" usa `GET /empleados?limit=8`. Marca visual: paleta y logo Scotiabank (chrome del mock; en prod lo provee el Portal Empresa padre — `ADR-ANCE-007`).

**Estadísticas generales (filtro + reporte):**
- `GET /dashboard?meses={3|6|12}` — el parámetro `meses` ("Intervalo de tiempo") acota el conteo de empleados por `fechaIngreso >= hoy - meses`; sin el parámetro devuelve todo el histórico. El filtro se resuelve en la query SQL, no en el cliente.
- `GET /dashboard/reporte?tipo={RESUMEN|EMPLEADOS|NOMINAS}&meses=` (operationId `descargarReporte`) — genera un CSV real desde la BD (`text/csv; charset=UTF-8`, `Content-Disposition: attachment`). `RESUMEN` = conteos agregados; `EMPLEADOS` = listado (numeroEmpleado, nombre, estadoCuenta, fechaIngreso — sin PII/PCI sensible); `NOMINAS` = listado de ciclos de pago. El frontend descarga el blob y dispara la descarga por `Content-Disposition`.

---

## 9. Integración con el Core Bancario

Patrón Anti-Corruption Layer vía `SPE-ANCE-003`. Aísla el modelo del portal del modelo del core.

| Operación lógica | Propósito | Estado |
|------------------|-----------|--------|
| `consultarCliente(idClienteCore)` | Traer datos de la empresa desde el core | `[DATO-REQUERIDO]` |
| `abrirCuentaNomina(empleado)` | Solicitar apertura de cuenta del empleado | `[DATO-REQUERIDO]` |
| `consultarSaldo(clabeOrigen)` | Validar fondos antes de dispersar | `[DATO-REQUERIDO]` |
| `instruirCargo(clabeOrigen, monto, ref)` | Debitar cuenta origen para dispersión | `[DATO-REQUERIDO]` |
| `consultarMovimientos(clabeOrigen, periodo)` | Conciliación de cuenta origen | `[DATO-REQUERIDO]` |

Estrategia de transporte (REST · MQ · adapter Java directo): `ADR-ANCE-001` `[BLOCKER]`. En el mock, estas operaciones se implementan como **stub determinista** dentro de `SPE-ANCE-003`.

---

## 10. Integración SPEI/CoDi y CFDI

### SPEI (vía `SPE-ANCE-006`)
- Instrucción de pago por renglón de dispersión → clave de rastreo (referencia SPEI 18 dígitos).
- Respeto de horarios operativos SPEI Banxico (L-V, ventana operativa).
- Manejo de los códigos de rechazo Banxico → mapeo a mensaje legible + acción sugerida.
- Gateway: `[DATO-REQUERIDO: directo Banxico o intermediario interno Scotiabank]` (`ADR-ANCE-005`).
- Mock: SPEI Adapter simula confirmación/rechazo con reglas deterministas.

### CFDI de nómina
- Complemento de nómina v1.2 · CFDI 4.0 SAT.
- Timbrado vía PAC `[DATO-REQUERIDO: PAC de Scotiabank o del empleador]`.
- Certificado de sello: `[DATO-REQUERIDO: quién sella — banco o empleador]` (`DR-007`).
- Mock: generación de XML válido estructuralmente + timbrado simulado.

---

## 11. Modelo de Datos y Clasificación PII/PCI

Detalle y DDL en `swarm/dt-dba.md` y `ADR-ANCE-003` (estrategia multi-tenant). Motor: SQL Server 2022.

| Clasificación | Campos | Control |
|---------------|--------|---------|
| **PCI** | `clabe` · `numeroCuenta` · `numeroTarjeta` · `clabeDestino` | Cifrado en reposo (Always Encrypted / TDE) · enmascarado en UI (últimos 4/6) · nunca en logs |
| **PII** | `rfc` · `curp` · `nombres/apellidos` · `ingresoMensualNeto` | Cifrado · enmascarado según rol · LFPDPPP |
| **Auditoría** | `RegistroAuditoria` | Inmutable · retención CNBV (5 años) |
| **Operacional** | resto | Estándar |

Estrategia multi-tenant (schema por empresa vs. columna discriminadora): `ADR-ANCE-003`.

---

## 12. Seguridad, Identidad y Accesos

Decisión: `ADR-ANCE-004` (ACCEPTED para mock).

| Aspecto | Mock | Producción |
|---------|------|------------|
| Emisor de identidad | Auth service propio (`SPE-ANCE-004`) emite JWT | IdP Scotiabank vía OIDC / SSO federado |
| Almacén de usuarios | Tabla `Usuario` en SQL Server | Federado desde IdP |
| Autorización | `@PreAuthorize` por rol | Idéntico |
| 2FA | Simulado (interfaz declarada) | `[DATO-REQUERIDO: mecanismo real]` |
| Abstracción | `JwtDecoder`/`AuthenticationProvider` intercambiable — la migración a SSO no toca controllers ni lógica de negocio |

Controles transversales: TLS 1.3 · JWT expiración ≤1h · headers de seguridad (HSTS, CSP, X-Frame-Options — este último relevante por el embebido en el portal existente) · secrets en secrets manager · DevSecOps shift-left (SAST · SCA · secrets · DAST).

---

## 13. Reglas de Negocio y Validaciones

| ID | Regla | Módulo |
|----|-------|--------|
| RN-01 | RFC persona física 13 caracteres · persona moral 12 · validación de estructura SAT | M3, M4 |
| RN-02 | CURP 18 caracteres · validación de estructura | M4 |
| RN-03 | CLABE 18 dígitos · dígito verificador válido | M4, M6 |
| RN-04 | Importe de dispersión > 0 y ≤ `limiteDispersionEmpleado` | M6 |
| RN-05 | Monto total de nómina ≤ `limiteDispersionNomina` y ≤ saldo cuenta origen | M6 |
| RN-06 | Dispersión con `montoTotal ≥ montoUmbralAutorizacion` requiere doble autorización | M6 |
| RN-07 | Solo empleados en estado `FINALIZADA`/`VINCULADA` son dispersables | M6 |
| RN-08 | Toda operación de escritura crítica requiere 2FA | M1, M4, M6 |
| RN-09 | Empresa `BLOQUEADA`/`SUSPENDIDA_PLDFT` no puede instruir dispersiones | M3, M6 |
| RN-10 | CFDI se genera solo para movimientos en estado `CONFIRMADO` | M7 |
| RN-11 | Toda acción de usuario queda en `RegistroAuditoria` (inmutable) | M8 |
| RN-12 | Carga masiva de empleados reporta error por fila sin abortar el lote válido | M4 |

---

## 14. Requisitos No Funcionales (SLOs)

| SLO | ID | Target | Notas |
|-----|-----|--------|-------|
| Disponibilidad | `SLO-ANCE-01` | ≥ 99.9% mensual | Estándar bancario |
| Latencia API P95 | `SLO-ANCE-02` | < 500ms | Operaciones síncronas |
| Dispersión E2E | `SLO-ANCE-03` | < 2 min | Instrucción → confirmación |
| Error rate | `SLO-ANCE-04` | < 0.1% en 7 días | |
| Éxito de CFDI | `SLO-ANCE-05` | ≥ 99.5% timbrados | |

Otros NFR: accesibilidad WCAG 2.1 AA · i18n es-MX (base) · navegadores evergreen · carga masiva hasta `[DATO-REQUERIDO]` empleados · responsive para el embebido en el portal existente.

---

## 15. Regulatorio y Compliance

| Marco | Impacto |
|-------|---------|
| CNBV CUB | Reportes de movimientos · PLDFT corporativo · Tech Outsourcing · retención de logs 5 años |
| PCI-DSS | Manejo de CLABE/cuenta/tarjeta · cifrado · enmascarado · scope del portal |
| SAT CFDI 4.0 | Complemento de nómina v1.2 · timbrado · resguardo |
| LFPDPPP | Datos personales de empleados · aviso de privacidad · derechos ARCO |
| Banxico SPEI | Circular 14/2017 · horarios · claves de rastreo · códigos de rechazo |
| CONDUSEF | Protección al cliente empresarial |

---

## 16. Capacidades BIAN

| ID BIAN | Capacidad | Relevancia |
|---------|-----------|-----------|
| 2.1.1 | Current Account | Cuenta origen de dispersión |
| 2.2.6 | Payment Order | Instrucción de dispersión nómina |
| 2.2.7 | Payment Execution | Ejecución SPEI/CoDi |
| 6.1.3 | Financial Statement | Estado de cuenta empresa |
| 6.5.2 | Payment Reconciliation | Conciliación de dispersiones |
| 7.1.1 | Transaction Capture | Registro de movimientos nómina |
| 9.1.1 | Customer Management | Gestión de empresas (CFR) |

---

## 17. Observabilidad

- Instrumentación OpenTelemetry en todos los servicios Java + OTel Browser SDK en Angular.
- Métricas RED por servicio · dashboard de dispersiones en vuelo · latencia SPEI · tasa de éxito CFDI · DORA.
- Logs estructurados (sin PII/PCI) · tracing distribuido end-to-end de la dispersión.
- Backend de observabilidad: `[DATO-REQUERIDO: Dynatrace / Azure Monitor / Datadog]`.

---

## 18. Alcance del Mock vs. Producto

| Capacidad | Mock | Producto |
|-----------|------|----------|
| Identidad y accesos | IAM propio (JWT) | SSO federado OIDC |
| Integración core bancario | Stub determinista en `SPE-ANCE-003` | Integración real (`ADR-ANCE-001`) |
| SPEI | Adapter simulado (confirma/rechaza por reglas) | Gateway real Banxico/interno (`ADR-ANCE-005`) |
| CFDI | XML válido + timbrado simulado | PAC real + certificado |
| Despliegue | Local / Docker | Kubernetes (`ADR-ANCE-006`) + embebido en portal (`ADR-ANCE-007`) |
| Datos | Sintéticos | Reales (con controles PII/PCI) |
| Módulos funcionales | **Todos** (M1–M9) con datos y flujos reales de UI/negocio | Idénticos + integraciones reales |

El mock construye el **producto completo funcionalmente**; solo las integraciones externas y la identidad se sustituyen por stubs intercambiables.

---

## 19. Datos Requeridos (DoR blockers)

| ID | Dato | Bloquea | Owner |
|----|------|---------|-------|
| DR-CORE | Estrategia y contrato de integración con core bancario | Integración real (no mock) | dt-solution-architect · `ADR-ANCE-001` |
| DR-SSO | IdP y contrato de federación del portal existente | Auth de producción | dt-security-engineer · `ADR-ANCE-004/007` |
| DR-SPEI | Gateway SPEI (directo Banxico o interno) | Dispersión real | dt-solution-architect · `ADR-ANCE-005` |
| DR-K8S | Cluster target (AKS · OpenShift · on-prem) | Deploy productivo | dt-devops-engineer · `ADR-ANCE-006` |
| DR-OBS | Backend de observabilidad | Dashboards prod | dt-devops-engineer |
| DR-PAC | PAC y certificado de sello CFDI | CFDI real | dt-product-owner |
| DR-002 | Productos de cuenta nómina Scotiabank (N4/N2 equiv.) | M3, M4 | dt-banking-domain |
| DR-003 | ¿Tarjetas físicas o solo CLABE digital? | M5 | dt-banking-domain |
| DR-009 | ¿Grupos empresariales / multi-contrato? | Modelo Empresa | dt-banking-domain |
| DR-011 | ¿Alta de empresa automática desde core o manual ADMIN_SCO? | M3, M9 | dt-banking-domain |
| DR-STACK | Stack y mecanismo de integración del portal existente | `ADR-ANCE-007` prod | dt-solution-architect |

Ninguno de estos bloquea el **mock** — todos tienen stub o decisión de mock tomada.

---

## 20. Trazabilidad

| Épica | Módulo | Componentes | BIAN | Reglas |
|-------|--------|-------------|------|--------|
| EP-01 | M1 | 001,002,004,005 | — | RN-08 |
| EP-02 | M2 | 001,002 | 2.1.1 | — |
| EP-03 | M3 | 001,002,003,005 | 9.1.1, 6.1.3 | RN-01, RN-09 |
| EP-04 | M4 | 001,002,003,005 | 9.1.1 | RN-01..03, RN-12 |
| EP-05 | M5 | 001,002,005 | — | — |
| EP-06 | M6 | 001,002,003,006,005 | 2.2.6, 2.2.7 | RN-04..09 |
| EP-07 | M7 | 001,002,005 | 7.1.1 | RN-10 |
| EP-08 | M8 | 001,002,005 | 6.5.2 | RN-11 |
| EP-09 | M9 | 001,002,005 | 9.1.1 | RN-09 |

---

*Creado: 2026-07-24 · v0.2 · [STATE: DRAFT · DISCOVER] · Spec build-ready sintetizada por dt-solution-architect con dt-product-owner + dt-banking-domain + dt-dba + dt-security-engineer*
