/* =============================================================================
   V003__seed_mock.sql
   Portal Empresas Nómina · Scotiabank México · SPE-ANCE-005

   *** DATOS SINTÉTICOS — SOLO PARA EL MOCK ***
   Nada en este archivo corresponde a personas, RFC, CURP, CLABE, cuentas ni
   tarjetas reales. Todos los valores son ficticios y están construidos sólo para
   que los flujos del portal (login, empleados, nómina, dispersión, CFDI) tengan
   datos con los que operar en DEV/QA. PROHIBIDO usar datos reales en no-PROD
   (anti-patrón dt-dba). No cargar este script en ambientes productivos.

   Password demo (los 4 usuarios): "Demo1234!"
   passwordHash = bcrypt (cost 10) de "Demo1234!" — verificado.
   ============================================================================= */

SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------- Empresa demo */
INSERT INTO dbo.Empresa
    (idEmpresa, numeroContrato, rfcEmpresa, razonSocial, claveGiro, clabeOrigen, numeroCuenta,
     limiteDispersionNomina, limiteDispersionEmpleado, limiteDispersionDiario,
     requiereDobleAutorizacion, montoUmbralAutorizacion, estadoEmpresa, perfilRiesgoPLDFT, idClienteCore)
VALUES
    ('11111111-1111-1111-1111-111111111111', 'CTR-DEMO-0001', 'NOM950101AB2',
     N'Nómina Demo Sintética, S.A. de C.V.', '5411', '044180123456789012', '0123456789',
     5000000.00, 100000.00, 2000000.00, 1, 500000.00, 'ACTIVA', 'BAJO', 'CORE-DEMO-0001');
GO

/* ------------------------------------------------------------ Centros de trabajo */
INSERT INTO dbo.CentroTrabajo
    (idCentroTrabajo, idEmpresa, nombre, sucursalAsignada,
     direccionCalle, direccionNumExt, direccionColonia, direccionCp, direccionMunicipio, direccionEstado,
     contactos, instruccionesEntrega, totalEmpleados, tarjetasAsignadas)
VALUES
    ('22222222-2222-2222-2222-000000000001', '11111111-1111-1111-1111-111111111111',
     N'Corporativo CDMX', N'Sucursal Reforma 342',
     N'Av. Paseo de la Reforma', '342', N'Juárez', '06600', N'Cuauhtémoc', N'Ciudad de México',
     N'[{"nombre":"Ana Demo","email":"ana.demo@empresa-demo.mx","telefono":"5550000001","area":"RH"}]',
     N'Entregar en recepción, horario 9-18h.', 6, 6),
    ('22222222-2222-2222-2222-000000000002', '11111111-1111-1111-1111-111111111111',
     N'Planta Monterrey', N'Sucursal San Pedro',
     N'Av. Vasconcelos', '1000', N'Del Valle', '66220', N'San Pedro Garza García', N'Nuevo León',
     N'[{"nombre":"Luis Demo","email":"luis.demo@empresa-demo.mx","telefono":"8180000002","area":"Operaciones"}]',
     N'Contactar a seguridad en caseta.', 3, 3),
    ('22222222-2222-2222-2222-000000000003', '11111111-1111-1111-1111-111111111111',
     N'Centro Guadalajara', N'Sucursal Providencia',
     N'Av. Américas', '500', N'Providencia', '44630', N'Guadalajara', N'Jalisco',
     N'[{"nombre":"Sofía Demo","email":"sofia.demo@empresa-demo.mx","telefono":"3330000003","area":"RH"}]',
     N'Sin instrucciones especiales.', 1, 0);
GO

/* -------------------------------------------------------------------- Usuarios */
/* Uno por rol · passwordHash = bcrypt("Demo1234!") · ADMIN_SCO no está scoped a empresa */
INSERT INTO dbo.Usuario
    (idUsuario, idEmpresa, email, nombre, rol, estado, passwordHash, ultimoAcceso)
VALUES
    ('33333333-3333-3333-3333-000000000001', '11111111-1111-1111-1111-111111111111',
     'admin@empresa-demo.mx',    N'Admin Empresa Demo',  'ADMIN_EMPRESA',   'ACTIVO',
     '$2b$10$RlAjexoXkeZWb2L45cevGe6a0h2O95N7hcCToqEWMp6Vi0e.Qz0au', NULL),
    ('33333333-3333-3333-3333-000000000002', '11111111-1111-1111-1111-111111111111',
     'operador@empresa-demo.mx', N'Operador Nómina Demo', 'OPERADOR_NOMINA', 'ACTIVO',
     '$2b$10$RlAjexoXkeZWb2L45cevGe6a0h2O95N7hcCToqEWMp6Vi0e.Qz0au', NULL),
    ('33333333-3333-3333-3333-000000000003', '11111111-1111-1111-1111-111111111111',
     'auditor@empresa-demo.mx',  N'Auditor Empresa Demo', 'AUDITOR',         'ACTIVO',
     '$2b$10$RlAjexoXkeZWb2L45cevGe6a0h2O95N7hcCToqEWMp6Vi0e.Qz0au', NULL),
    ('33333333-3333-3333-3333-000000000004', NULL,
     'admin.sco@scotiabank-demo.mx', N'Admin Scotiabank Demo', 'ADMIN_SCO',  'ACTIVO',
     '$2b$10$RlAjexoXkeZWb2L45cevGe6a0h2O95N7hcCToqEWMp6Vi0e.Qz0au', NULL);
GO

/* ------------------------------------------------------------------- Empleados */
/* 10 empleados sintéticos cubriendo todos los estados del spec §6.1.            */
/* CLABE/cuenta/tarjeta sólo presentes en estados con cuenta abierta.            */
INSERT INTO dbo.Empleado
    (idEmpleado, idEmpresa, idCentroTrabajo, numeroEmpleado, nombres, primerApellido, segundoApellido,
     rfc, curp, genero, nacionalidad, estadoCivil, fechaIngreso, ingresoMensualNeto,
     numeroCuenta, clabe, numeroTarjeta, estadoCuenta, estadoDeposito, estadoCargo)
VALUES
    ('44444444-4444-4444-4444-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00001', N'María', N'López', N'García', 'LOGM900101AB1', 'LOGM900101MDFPRR03', 'FEMENINO', N'MEXICANA', 'SOLTERO',
     '2024-01-15', 18500.00, '1000000001', '044180000000000019', 'tok_4d1f0001', 'VINCULADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000002', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00002', N'Juan', N'Martínez', N'Hernández', 'MAHJ850315CD2', 'MAHJ850315HDFRRN08', 'MASCULINO', N'MEXICANA', 'CASADO',
     '2023-06-01', 24300.00, '1000000002', '044180000000000027', 'tok_4d1f0002', 'VINCULADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000003', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00003', N'Ana', N'Ramírez', N'Torres', 'RATA920720EF3', 'RATA920720MDFMRN01', 'FEMENINO', N'MEXICANA', 'SOLTERO',
     '2025-02-10', 15200.00, '1000000003', '044180000000000035', 'tok_4d1f0003', 'VINCULADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000004', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00004', N'Carlos', N'Sánchez', N'Díaz', 'SADC880505GH4', 'SADC880505HDFNZR05', 'MASCULINO', N'MEXICANA', 'CASADO',
     '2022-11-20', 31000.00, '1000000004', '044180000000000043', NULL, 'FINALIZADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000005', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000002',
     'E-00005', N'Laura', N'Gómez', N'Flores', 'GOFL910909IJ5', 'GOFL910909MNLMLR02', 'FEMENINO', N'MEXICANA', 'OTRO',
     '2024-08-01', 19800.00, '1000000005', '044180000000000051', NULL, 'FINALIZADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000006', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000002',
     'E-00006', N'Pedro', N'Torres', N'Ruiz', 'TORP830212KL6', 'TORP830212HNLRZD09', 'MASCULINO', N'MEXICANA', 'CASADO',
     '2023-03-15', 27500.00, NULL, NULL, NULL, 'DOCUMENTADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000007', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000002',
     'E-00007', N'Sofía', N'Vázquez', N'Mendoza', 'VAMS950630MN7', 'VAMS950630MJCZND04', 'FEMENINO', N'MEXICANA', 'SOLTERO',
     '2025-05-05', 16750.00, NULL, NULL, NULL, 'EN_PROCESO', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000008', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000003',
     'E-00008', N'Miguel', N'Jiménez', N'Castro', 'JICM871118OP8', 'JICM871118HJCMSG06', 'MASCULINO', N'MEXICANA', 'SOLTERO',
     '2026-01-02', 22100.00, NULL, NULL, NULL, 'NO_INICIADA', 'DESBLOQUEADA', 'DESBLOQUEADA'),
    ('44444444-4444-4444-4444-000000000009', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00009', N'Gabriela', N'Reyes', N'Ortiz', 'REOG930814QR9', 'REOG930814MDFYRB07', 'FEMENINO', N'MEXICANA', 'CASADO',
     '2023-09-10', 28900.00, '1000000009', '044180000000000078', 'tok_4d1f0009', 'BLOQUEADA', 'BLOQUEADA', 'BLOQUEADA'),
    ('44444444-4444-4444-4444-000000000010', '11111111-1111-1111-1111-111111111111', '22222222-2222-2222-2222-000000000001',
     'E-00010', N'Roberto', N'Morales', N'Núñez', 'MONR860427ST1', 'MONR860427HDFRXB03', 'MASCULINO', N'MEXICANA', 'OTRO',
     '2021-07-01', 34500.00, '1000000010', '044180000000000086', NULL, 'ELIMINADA', 'BLOQUEADA', 'BLOQUEADA');
GO

/* --------------------------------------------------- Nómina demo (BORRADOR) ---- */
/* Cabecera de ejemplo para poder ejercitar M6 sin ejecutar dispersión.          */
INSERT INTO dbo.Nomina
    (idNomina, idEmpresa, tipo, periodoInicio, periodoFin, descripcion, estado, montoTotal, totalEmpleados)
VALUES
    ('55555555-5555-5555-5555-000000000001', '11111111-1111-1111-1111-111111111111',
     'QUINCENAL', '2026-07-01', '2026-07-15', N'Primera quincena julio (demo)', 'BORRADOR', 0.00, 0);
GO

PRINT 'V003__seed_mock: datos sintéticos cargados (1 empresa, 3 centros, 4 usuarios, 10 empleados, 1 nómina demo).';
GO
