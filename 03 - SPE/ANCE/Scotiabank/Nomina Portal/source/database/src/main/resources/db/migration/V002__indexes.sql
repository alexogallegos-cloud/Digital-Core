/* =============================================================================
   V002__indexes.sql
   Portal Empresas Nómina · Scotiabank México · SPE-ANCE-005
   Índices en migración separada (no bloqueante).

   Todos los índices se crean con (ONLINE = ON) para no bloquear las tablas en
   despliegues futuros con datos productivos (SQL Server 2022 Enterprise/Azure).
   En Standard Edition (ONLINE = ON no soportado) retirar la opción o aplicar en
   ventana de mantenimiento — ver README.md.

   Cubre: FKs (búsqueda por padre), y los accesos declarados por el spec/OpenAPI
   (filtros por estado, RFC, número de empleado, timeline de auditoría).
   ============================================================================= */

SET NOCOUNT ON;
GO

/* ---- Empresa ---- */
CREATE INDEX IX_Empresa_estado           ON dbo.Empresa (estadoEmpresa)        WITH (ONLINE = ON);
CREATE INDEX IX_Empresa_grupo            ON dbo.Empresa (idGrupoEmpresarial)   WITH (ONLINE = ON);
GO

/* ---- Usuario ---- */
CREATE INDEX IX_Usuario_idEmpresa        ON dbo.Usuario (idEmpresa)            WITH (ONLINE = ON);
CREATE INDEX IX_Usuario_rol              ON dbo.Usuario (rol)                  WITH (ONLINE = ON);
GO

/* ---- CentroTrabajo ---- */
CREATE INDEX IX_CentroTrabajo_idEmpresa  ON dbo.CentroTrabajo (idEmpresa)      WITH (ONLINE = ON);
GO

/* ---- Empleado ---- (FKs + accesos del OpenAPI: filtro estadoCuenta, búsqueda RFC/numeroEmpleado) */
CREATE INDEX IX_Empleado_idEmpresa       ON dbo.Empleado (idEmpresa)           WITH (ONLINE = ON);
CREATE INDEX IX_Empleado_idCentroTrabajo ON dbo.Empleado (idCentroTrabajo)     WITH (ONLINE = ON);
CREATE INDEX IX_Empleado_rfc             ON dbo.Empleado (rfc)                 WITH (ONLINE = ON);
CREATE INDEX IX_Empleado_numeroEmpleado  ON dbo.Empleado (numeroEmpleado)      WITH (ONLINE = ON);
CREATE INDEX IX_Empleado_estadoCuenta    ON dbo.Empleado (estadoCuenta)        WITH (ONLINE = ON);
GO

/* ---- Nomina ---- */
CREATE INDEX IX_Nomina_idEmpresa         ON dbo.Nomina (idEmpresa)             WITH (ONLINE = ON);
CREATE INDEX IX_Nomina_estado            ON dbo.Nomina (estado)                WITH (ONLINE = ON);
GO

/* ---- DetalleNomina ---- */
CREATE INDEX IX_DetalleNomina_idNomina   ON dbo.DetalleNomina (idNomina)       WITH (ONLINE = ON);
CREATE INDEX IX_DetalleNomina_idEmpleado ON dbo.DetalleNomina (idEmpleado)     WITH (ONLINE = ON);
GO

/* ---- Dispersion ---- (idNomina ya cubierto por UQ_Dispersion_Nomina) */
CREATE INDEX IX_Dispersion_estado        ON dbo.Dispersion (estado)            WITH (ONLINE = ON);
CREATE INDEX IX_Dispersion_usuarioInstruye ON dbo.Dispersion (usuarioInstruye) WITH (ONLINE = ON);
GO

/* ---- MovimientoDispersion ---- */
CREATE INDEX IX_MovimientoDispersion_idDispersion ON dbo.MovimientoDispersion (idDispersion) WITH (ONLINE = ON);
CREATE INDEX IX_MovimientoDispersion_idEmpleado   ON dbo.MovimientoDispersion (idEmpleado)   WITH (ONLINE = ON);
CREATE INDEX IX_MovimientoDispersion_estado       ON dbo.MovimientoDispersion (estado)       WITH (ONLINE = ON);
GO

/* ---- CFDI ---- (idMovimiento ya cubierto por UQ_CFDI_Movimiento) */
CREATE INDEX IX_CFDI_idEmpleado          ON dbo.CFDI (idEmpleado)              WITH (ONLINE = ON);
CREATE INDEX IX_CFDI_estadoTimbrado      ON dbo.CFDI (estadoTimbrado)          WITH (ONLINE = ON);
GO

/* ---- RegistroAuditoria ---- (timeline por empresa: idEmpresa + timestamp) */
CREATE INDEX IX_RegistroAuditoria_empresa_ts ON dbo.RegistroAuditoria (idEmpresa, [timestamp] DESC) WITH (ONLINE = ON);
CREATE INDEX IX_RegistroAuditoria_idUsuario  ON dbo.RegistroAuditoria (idUsuario) WITH (ONLINE = ON);
GO

/* ---- CargaMasiva ---- */
CREATE INDEX IX_CargaMasiva_idEmpresa     ON dbo.CargaMasiva (idEmpresa)        WITH (ONLINE = ON);
GO
