/* =============================================================================
   V001__baseline_schema.sql
   Portal Empresas Nómina · Scotiabank México · SPE-ANCE-005
   Motor: Microsoft SQL Server 2022 · Migraciones: Flyway
   Owner: dt-dba · Spec de referencia: spec-nomina-portal.md §5 / §6 / §11
   Contrato: api/openapi-nomina-portal.yaml (enums alineados 1:1)

   Convenciones:
     - Tablas en PascalCase (mismo nombre que la entidad JPA del spec §5,
       package mx.scotiabank.nomina).
     - Columnas en camelCase, idénticas a los atributos del spec §5.
     - PK = UNIQUEIDENTIFIER con DEFAULT NEWID().
     - Dinero = DECIMAL(18,2) (NUNCA float/real/money).
     - Fechas de calendario = DATE · marcas de tiempo = DATETIME2(3) UTC.
     - Estados = VARCHAR con CHECK constraint que enumera el enum del OpenAPI.
     - PII/PCI marcados en línea con -- PII / -- PCI (ver spec §11).

   Multi-tenant (ADR-ANCE-003 PENDIENTE):
     Estrategia provisional = columna discriminadora `idEmpresa` en las tablas
     tenant-scoped de primer nivel (Usuario, Empleado, CentroTrabajo, Nomina,
     RegistroAuditoria, CargaMasiva). Las tablas de segundo nivel (DetalleNomina,
     Dispersion, MovimientoDispersion, CFDI) se aíslan por su cadena de FKs hacia
     Nomina→Empresa. La decisión final schema-per-tenant vs shared-schema queda
     abierta en ADR-ANCE-003; migrar a schema-per-tenant sólo requeriría mover
     estas tablas a un schema por empresa sin cambiar el modelo relacional.
   ============================================================================= */

SET NOCOUNT ON;
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

/* -----------------------------------------------------------------------------
   Empresa — cliente de nómina (owner de dominio: dt-banking-domain)
   Relación: Empresa 1──N Usuario/Empleado/CentroTrabajo/Nomina/RegistroAuditoria
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.Empresa (
    idEmpresa                   UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Empresa_idEmpresa DEFAULT NEWID(),
    numeroContrato              VARCHAR(40)      NOT NULL,
    rfcEmpresa                  VARCHAR(13)      NOT NULL,   -- PII (RFC persona moral 12 / física 13 · RN-01)
    razonSocial                 NVARCHAR(200)    NOT NULL,   -- PII
    claveGiro                   VARCHAR(10)      NULL,
    clabeOrigen                 VARCHAR(18)      NOT NULL,   -- PCI (cuenta origen de dispersión)
    numeroCuenta                VARCHAR(20)      NULL,       -- PCI
    limiteDispersionNomina      DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Empresa_limNomina    DEFAULT (0),
    limiteDispersionEmpleado    DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Empresa_limEmpleado  DEFAULT (0),
    limiteDispersionDiario      DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Empresa_limDiario    DEFAULT (0),
    requiereDobleAutorizacion   BIT              NOT NULL CONSTRAINT DF_Empresa_dobleAut     DEFAULT (0),
    montoUmbralAutorizacion     DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Empresa_umbral       DEFAULT (0),
    estadoEmpresa               VARCHAR(20)      NOT NULL CONSTRAINT DF_Empresa_estado       DEFAULT ('ACTIVA'),
    perfilRiesgoPLDFT           VARCHAR(10)      NOT NULL CONSTRAINT DF_Empresa_riesgo       DEFAULT ('BAJO'),
    idGrupoEmpresarial          UNIQUEIDENTIFIER NULL,       -- DR-009: grupos empresariales / multi-contrato (pendiente)
    idClienteCore               VARCHAR(40)      NULL,       -- DATO-REQUERIDO: id de cliente en core bancario
    fechaCreacion               DATETIME2(3)     NOT NULL CONSTRAINT DF_Empresa_fecha        DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Empresa PRIMARY KEY (idEmpresa),
    CONSTRAINT UQ_Empresa_numeroContrato UNIQUE (numeroContrato),
    CONSTRAINT UQ_Empresa_rfc UNIQUE (rfcEmpresa),
    CONSTRAINT CK_Empresa_estado CHECK (estadoEmpresa IN ('ACTIVA','BLOQUEADA','SUSPENDIDA_PLDFT','INACTIVA')),
    CONSTRAINT CK_Empresa_riesgo CHECK (perfilRiesgoPLDFT IN ('BAJO','MEDIO','ALTO'))
);
GO

/* -----------------------------------------------------------------------------
   Usuario — operador del portal (mock IAM · prod SSO federado, ADR-ANCE-004)
   Relación: Empresa 1──N Usuario
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.Usuario (
    idUsuario       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Usuario_idUsuario DEFAULT NEWID(),
    idEmpresa       UNIQUEIDENTIFIER NULL,        -- NULL para ADMIN_SCO (usuario interno del banco, no scoped a empresa)
    email           NVARCHAR(320)    NOT NULL,    -- PII
    nombre          NVARCHAR(200)    NOT NULL,    -- PII
    rol             VARCHAR(20)      NOT NULL,
    estado          VARCHAR(12)      NOT NULL CONSTRAINT DF_Usuario_estado DEFAULT ('INVITADO'),
    passwordHash    VARCHAR(72)      NULL,        -- SOLO mock (bcrypt) · en prod la identidad es federada
    subjectIdP      NVARCHAR(255)    NULL,        -- SOLO prod (subject del IdP vía OIDC)
    ultimoAcceso    DATETIME2(3)     NULL,
    fechaCreacion   DATETIME2(3)     NOT NULL CONSTRAINT DF_Usuario_fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Usuario PRIMARY KEY (idUsuario),
    CONSTRAINT UQ_Usuario_email UNIQUE (email),
    CONSTRAINT FK_Usuario_Empresa FOREIGN KEY (idEmpresa) REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT CK_Usuario_rol CHECK (rol IN ('ADMIN_EMPRESA','OPERADOR_NOMINA','AUDITOR','ADMIN_SCO')),
    CONSTRAINT CK_Usuario_estado CHECK (estado IN ('ACTIVO','INVITADO','REVOCADO'))
);
GO

/* -----------------------------------------------------------------------------
   CentroTrabajo — directorio de centros de trabajo de la empresa
   Relación: Empresa 1──N CentroTrabajo · CentroTrabajo 1──N Empleado
   Nota: `direccion` (objeto del spec) se aplana en columnas direccion*.
         `contactos[1..3]` se persiste como arreglo JSON validado (ISJSON).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.CentroTrabajo (
    idCentroTrabajo     UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CentroTrabajo_id DEFAULT NEWID(),
    idEmpresa           UNIQUEIDENTIFIER NOT NULL,
    nombre              NVARCHAR(200)    NOT NULL,
    sucursalAsignada    NVARCHAR(120)    NULL,
    direccionCalle      NVARCHAR(200)    NULL,
    direccionNumExt     NVARCHAR(20)     NULL,
    direccionNumInt     NVARCHAR(20)     NULL,
    direccionColonia    NVARCHAR(120)    NULL,
    direccionCp         VARCHAR(5)       NULL,
    direccionMunicipio  NVARCHAR(120)    NULL,
    direccionEstado     NVARCHAR(120)    NULL,
    contactos           NVARCHAR(MAX)    NULL,        -- JSON: [{nombre,email,telefono,area}] (1..3)
    instruccionesEntrega NVARCHAR(1000)  NULL,
    totalEmpleados      INT              NOT NULL CONSTRAINT DF_CentroTrabajo_totEmp DEFAULT (0),
    tarjetasAsignadas   INT              NOT NULL CONSTRAINT DF_CentroTrabajo_tarj   DEFAULT (0),
    fechaCreacion       DATETIME2(3)     NOT NULL CONSTRAINT DF_CentroTrabajo_fecha  DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_CentroTrabajo PRIMARY KEY (idCentroTrabajo),
    CONSTRAINT FK_CentroTrabajo_Empresa FOREIGN KEY (idEmpresa) REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT CK_CentroTrabajo_contactos CHECK (contactos IS NULL OR ISJSON(contactos) = 1)
);
GO

/* -----------------------------------------------------------------------------
   Empleado — persona con cuenta nómina
   Relación: Empresa 1──N Empleado · CentroTrabajo 1──N Empleado · Empleado 1──N CFDI
   Máquina de estado del spec §6.1 (estadoCuenta).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.Empleado (
    idEmpleado          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Empleado_id DEFAULT NEWID(),
    idEmpresa           UNIQUEIDENTIFIER NOT NULL,
    idCentroTrabajo     UNIQUEIDENTIFIER NULL,
    numeroEmpleado      VARCHAR(40)      NOT NULL,
    nombres             NVARCHAR(120)    NOT NULL,   -- PII
    primerApellido      NVARCHAR(120)    NOT NULL,   -- PII
    segundoApellido     NVARCHAR(120)    NULL,       -- PII
    rfc                 VARCHAR(13)      NOT NULL,   -- PII (RN-01)
    curp                VARCHAR(18)      NOT NULL,   -- PII (RN-02)
    genero              VARCHAR(10)      NULL,
    nacionalidad        NVARCHAR(60)     NULL,
    estadoCivil         VARCHAR(10)      NULL,
    fechaIngreso        DATE             NOT NULL,
    ingresoMensualNeto  DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Empleado_ingreso DEFAULT (0),  -- PII
    numeroCuenta        VARCHAR(20)      NULL,       -- PCI
    clabe               VARCHAR(18)      NULL,       -- PCI (RN-03 · 18 dígitos + verificador)
    numeroTarjeta       VARCHAR(64)      NULL,       -- PCI (tokenizado — nunca PAN en claro)
    estadoCuenta        VARCHAR(15)      NOT NULL CONSTRAINT DF_Empleado_estadoCuenta   DEFAULT ('NO_INICIADA'),
    estadoDeposito      VARCHAR(12)      NOT NULL CONSTRAINT DF_Empleado_estadoDeposito DEFAULT ('DESBLOQUEADA'),
    estadoCargo         VARCHAR(12)      NOT NULL CONSTRAINT DF_Empleado_estadoCargo    DEFAULT ('DESBLOQUEADA'),
    fechaCreacion       DATETIME2(3)     NOT NULL CONSTRAINT DF_Empleado_fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Empleado PRIMARY KEY (idEmpleado),
    CONSTRAINT UQ_Empleado_numeroEmpleado UNIQUE (idEmpresa, numeroEmpleado),
    CONSTRAINT FK_Empleado_Empresa       FOREIGN KEY (idEmpresa)       REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT FK_Empleado_CentroTrabajo FOREIGN KEY (idCentroTrabajo) REFERENCES dbo.CentroTrabajo (idCentroTrabajo),
    CONSTRAINT CK_Empleado_estadoCuenta CHECK (estadoCuenta IN ('NO_INICIADA','EN_PROCESO','DOCUMENTADA','FINALIZADA','VINCULADA','BLOQUEADA','ELIMINADA')),
    CONSTRAINT CK_Empleado_estadoDeposito CHECK (estadoDeposito IN ('DESBLOQUEADA','BLOQUEADA')),
    CONSTRAINT CK_Empleado_estadoCargo    CHECK (estadoCargo    IN ('DESBLOQUEADA','BLOQUEADA')),
    CONSTRAINT CK_Empleado_genero      CHECK (genero      IS NULL OR genero      IN ('MASCULINO','FEMENINO','OTRO')),
    CONSTRAINT CK_Empleado_estadoCivil CHECK (estadoCivil IS NULL OR estadoCivil IN ('SOLTERO','CASADO','OTRO'))
);
GO

/* -----------------------------------------------------------------------------
   Nomina — cabecera de un ciclo de pago
   Relación: Empresa 1──N Nomina · Nomina 1──N DetalleNomina · Nomina 1──1 Dispersion
   Máquina de estado del spec §6.2 (estado).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.Nomina (
    idNomina        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Nomina_id DEFAULT NEWID(),
    idEmpresa       UNIQUEIDENTIFIER NOT NULL,
    tipo            VARCHAR(15)      NOT NULL,
    periodoInicio   DATE             NOT NULL,
    periodoFin      DATE             NOT NULL,
    descripcion     NVARCHAR(300)    NULL,
    estado          VARCHAR(20)      NOT NULL CONSTRAINT DF_Nomina_estado DEFAULT ('BORRADOR'),
    montoTotal      DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Nomina_monto DEFAULT (0),
    totalEmpleados  INT              NOT NULL CONSTRAINT DF_Nomina_totEmp DEFAULT (0),
    fechaProgramada DATETIME2(3)     NULL,
    fechaCreacion   DATETIME2(3)     NOT NULL CONSTRAINT DF_Nomina_fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_Nomina PRIMARY KEY (idNomina),
    CONSTRAINT FK_Nomina_Empresa FOREIGN KEY (idEmpresa) REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT CK_Nomina_tipo CHECK (tipo IN ('SEMANAL','QUINCENAL','MENSUAL','EXTRAORDINARIA')),
    CONSTRAINT CK_Nomina_estado CHECK (estado IN ('BORRADOR','LAYOUT_CARGADO','VALIDADA','EN_AUTORIZACION','AUTORIZADA','DISPERSANDO','CONFIRMADA','RECHAZADA_PARCIAL','CANCELADA')),
    CONSTRAINT CK_Nomina_periodo CHECK (periodoFin >= periodoInicio)
);
GO

/* -----------------------------------------------------------------------------
   DetalleNomina — renglón por empleado en la nómina
   Relación: Nomina 1──N DetalleNomina · Empleado 1──N DetalleNomina
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.DetalleNomina (
    idDetalle       UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_DetalleNomina_id DEFAULT NEWID(),
    idNomina        UNIQUEIDENTIFIER NOT NULL,
    idEmpleado      UNIQUEIDENTIFIER NOT NULL,
    clabeDestino    VARCHAR(18)      NOT NULL,   -- PCI
    importe         DECIMAL(18,2)    NOT NULL,
    estadoRenglon   VARCHAR(6)       NOT NULL CONSTRAINT DF_DetalleNomina_estado DEFAULT ('VALIDO'),
    mensajeError    NVARCHAR(500)    NULL,
    CONSTRAINT PK_DetalleNomina PRIMARY KEY (idDetalle),
    CONSTRAINT UQ_DetalleNomina UNIQUE (idNomina, idEmpleado),
    CONSTRAINT FK_DetalleNomina_Nomina   FOREIGN KEY (idNomina)   REFERENCES dbo.Nomina (idNomina),
    CONSTRAINT FK_DetalleNomina_Empleado FOREIGN KEY (idEmpleado) REFERENCES dbo.Empleado (idEmpleado),
    CONSTRAINT CK_DetalleNomina_estado CHECK (estadoRenglon IN ('VALIDO','ERROR')),
    CONSTRAINT CK_DetalleNomina_importe CHECK (importe > 0)   -- RN-04
);
GO

/* -----------------------------------------------------------------------------
   Dispersion — ejecución de la nómina (1──1 con Nomina)
   Máquina de estado del spec §6.2 (estado de dispersión).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.Dispersion (
    idDispersion        UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_Dispersion_id DEFAULT NEWID(),
    idNomina            UNIQUEIDENTIFIER NOT NULL,
    estado              VARCHAR(20)      NOT NULL CONSTRAINT DF_Dispersion_estado DEFAULT ('PENDIENTE'),
    fechaInstruccion    DATETIME2(3)     NOT NULL CONSTRAINT DF_Dispersion_fechaInstr DEFAULT (SYSUTCDATETIME()),
    usuarioInstruye     UNIQUEIDENTIFIER NOT NULL,
    usuarioAutoriza     UNIQUEIDENTIFIER NULL,       -- doble autorización (RN-06)
    referenciaInterna   VARCHAR(40)      NOT NULL,
    montoDispersado     DECIMAL(18,2)    NOT NULL CONSTRAINT DF_Dispersion_monto DEFAULT (0),
    CONSTRAINT PK_Dispersion PRIMARY KEY (idDispersion),
    CONSTRAINT UQ_Dispersion_Nomina UNIQUE (idNomina),              -- refuerza el 1──1
    CONSTRAINT UQ_Dispersion_referencia UNIQUE (referenciaInterna),
    CONSTRAINT FK_Dispersion_Nomina          FOREIGN KEY (idNomina)        REFERENCES dbo.Nomina (idNomina),
    CONSTRAINT FK_Dispersion_UsuarioInstruye FOREIGN KEY (usuarioInstruye) REFERENCES dbo.Usuario (idUsuario),
    CONSTRAINT FK_Dispersion_UsuarioAutoriza FOREIGN KEY (usuarioAutoriza) REFERENCES dbo.Usuario (idUsuario),
    CONSTRAINT CK_Dispersion_estado CHECK (estado IN ('PENDIENTE','PROCESANDO','CONFIRMADA','RECHAZADA_PARCIAL'))
);
GO

/* -----------------------------------------------------------------------------
   MovimientoDispersion — resultado por empleado
   Relación: Dispersion 1──N MovimientoDispersion · MovimientoDispersion 1──0..1 CFDI
   Máquina de estado del spec (ENVIADO/CONFIRMADO/RECHAZADO).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.MovimientoDispersion (
    idMovimiento            UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_MovimientoDispersion_id DEFAULT NEWID(),
    idDispersion            UNIQUEIDENTIFIER NOT NULL,
    idEmpleado              UNIQUEIDENTIFIER NOT NULL,
    importe                 DECIMAL(18,2)    NOT NULL,
    clabeDestino            VARCHAR(18)      NOT NULL,   -- PCI
    estado                  VARCHAR(10)      NOT NULL CONSTRAINT DF_MovimientoDispersion_estado DEFAULT ('ENVIADO'),
    referenciaSPEI          VARCHAR(18)      NULL,       -- clave de rastreo Banxico (18 dígitos)
    codigoRechazoBanxico    VARCHAR(10)      NULL,
    fechaConfirmacion       DATETIME2(3)     NULL,
    CONSTRAINT PK_MovimientoDispersion PRIMARY KEY (idMovimiento),
    CONSTRAINT FK_MovimientoDispersion_Dispersion FOREIGN KEY (idDispersion) REFERENCES dbo.Dispersion (idDispersion),
    CONSTRAINT FK_MovimientoDispersion_Empleado   FOREIGN KEY (idEmpleado)   REFERENCES dbo.Empleado (idEmpleado),
    CONSTRAINT CK_MovimientoDispersion_estado CHECK (estado IN ('ENVIADO','CONFIRMADO','RECHAZADO')),
    CONSTRAINT CK_MovimientoDispersion_importe CHECK (importe > 0)
);
GO

/* -----------------------------------------------------------------------------
   CFDI — comprobante fiscal de nómina (SAT 4.0 · complemento nómina 1.2)
   Relación: MovimientoDispersion 1──0..1 CFDI · Empleado 1──N CFDI
   Máquina de estado del spec §6.3 (estadoTimbrado). RN-10: sólo mov. CONFIRMADO.
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.CFDI (
    idCFDI          UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CFDI_id DEFAULT NEWID(),
    idMovimiento    UNIQUEIDENTIFIER NOT NULL,
    idEmpleado      UNIQUEIDENTIFIER NOT NULL,
    uuidSAT         VARCHAR(36)      NULL,       -- folio fiscal (UUID SAT) — NULL hasta timbrar
    estadoTimbrado  VARCHAR(10)      NOT NULL CONSTRAINT DF_CFDI_estado DEFAULT ('PENDIENTE'),
    xml             NVARCHAR(MAX)    NULL,        -- resguardo del comprobante (retención SAT/CNBV)
    codigoErrorSAT  VARCHAR(20)      NULL,
    fechaTimbrado   DATETIME2(3)     NULL,
    fechaCreacion   DATETIME2(3)     NOT NULL CONSTRAINT DF_CFDI_fecha DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_CFDI PRIMARY KEY (idCFDI),
    CONSTRAINT UQ_CFDI_Movimiento UNIQUE (idMovimiento),           -- refuerza el 0..1 (un CFDI por movimiento)
    CONSTRAINT FK_CFDI_Movimiento FOREIGN KEY (idMovimiento) REFERENCES dbo.MovimientoDispersion (idMovimiento),
    CONSTRAINT FK_CFDI_Empleado   FOREIGN KEY (idEmpleado)   REFERENCES dbo.Empleado (idEmpleado),
    CONSTRAINT CK_CFDI_estado CHECK (estadoTimbrado IN ('PENDIENTE','TIMBRADO','ERROR'))
);
GO

/* -----------------------------------------------------------------------------
   RegistroAuditoria — bitácora inmutable (RN-11 · retención CNBV 5 años)
   Relación: Empresa 1──N RegistroAuditoria · Usuario 1──N RegistroAuditoria
   Inmutabilidad se refuerza a nivel de aplicación/permisos (sólo INSERT/SELECT).
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.RegistroAuditoria (
    idRegistro      UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_RegistroAuditoria_id DEFAULT NEWID(),
    idEmpresa       UNIQUEIDENTIFIER NULL,       -- NULL para acciones de ADMIN_SCO no scoped a empresa
    idUsuario       UNIQUEIDENTIFIER NULL,
    accion          VARCHAR(80)      NOT NULL,
    entidadAfectada VARCHAR(60)      NOT NULL,
    idEntidad       VARCHAR(60)      NULL,
    [timestamp]     DATETIME2(3)     NOT NULL CONSTRAINT DF_RegistroAuditoria_ts DEFAULT (SYSUTCDATETIME()),
    ipOrigen        VARCHAR(45)      NULL,        -- IPv4/IPv6
    detalle         NVARCHAR(MAX)    NULL,        -- JSON (nunca PII/PCI en claro)
    CONSTRAINT PK_RegistroAuditoria PRIMARY KEY (idRegistro),
    CONSTRAINT FK_RegistroAuditoria_Empresa FOREIGN KEY (idEmpresa) REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT FK_RegistroAuditoria_Usuario FOREIGN KEY (idUsuario) REFERENCES dbo.Usuario (idUsuario),
    CONSTRAINT CK_RegistroAuditoria_detalle CHECK (detalle IS NULL OR ISJSON(detalle) = 1)
);
GO

/* -----------------------------------------------------------------------------
   CargaMasiva — trazabilidad de archivos cargados (empleados/centros/layout)
   Relación: Empresa 1──N CargaMasiva
   ----------------------------------------------------------------------------- */
CREATE TABLE dbo.CargaMasiva (
    idCarga         UNIQUEIDENTIFIER NOT NULL CONSTRAINT DF_CargaMasiva_id DEFAULT NEWID(),
    idEmpresa       UNIQUEIDENTIFIER NOT NULL,
    tipo            VARCHAR(15)      NOT NULL,
    nombreArchivo   NVARCHAR(260)    NOT NULL,
    usuario         UNIQUEIDENTIFIER NULL,
    fecha           DATETIME2(3)     NOT NULL CONSTRAINT DF_CargaMasiva_fecha DEFAULT (SYSUTCDATETIME()),
    totalRegistros  INT              NOT NULL CONSTRAINT DF_CargaMasiva_total DEFAULT (0),
    exitosos        INT              NOT NULL CONSTRAINT DF_CargaMasiva_ok    DEFAULT (0),
    conError        INT              NOT NULL CONSTRAINT DF_CargaMasiva_err   DEFAULT (0),
    estado          VARCHAR(12)      NOT NULL CONSTRAINT DF_CargaMasiva_estado DEFAULT ('PROCESANDO'),
    CONSTRAINT PK_CargaMasiva PRIMARY KEY (idCarga),
    CONSTRAINT FK_CargaMasiva_Empresa FOREIGN KEY (idEmpresa) REFERENCES dbo.Empresa (idEmpresa),
    CONSTRAINT FK_CargaMasiva_Usuario FOREIGN KEY (usuario)   REFERENCES dbo.Usuario (idUsuario),
    CONSTRAINT CK_CargaMasiva_tipo   CHECK (tipo   IN ('EMPLEADOS','CENTROS','LAYOUT_NOMINA')),
    CONSTRAINT CK_CargaMasiva_estado CHECK (estado IN ('PROCESANDO','COMPLETADO','ERROR'))
);
GO
