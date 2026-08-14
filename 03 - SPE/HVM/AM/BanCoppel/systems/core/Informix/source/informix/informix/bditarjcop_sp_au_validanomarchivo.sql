CREATE PROCEDURE "informix".sp_au_validanomarchivo(psEmpresa VARCHAR(3), psNomArchivo VARCHAR(15) )

RETURNING VARCHAR(5) AS CodRetorno;

--****************************************************************************************************
-- DESCRIPCION: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL
-- AUTOR : Casanova Edeza Hector Juan
-- FECHA : 23/12/2011
-- BD: bdiTarCop
-- SISTEMA : Inventario de Tarjetas Alta Unica.
--****************************************************************************************************

/*  DEFINICION DE VARIABLES */

DEFINE vsFlagSoloNumeros VARCHAR (1);
DEFINE vsCodRetorno VARCHAR (5);

DEFINE viSqlError INTEGER;

/* INICIALIZACION DE VARIABLES */
LET vsFlagSoloNumeros = '';
LET vsCodRetorno = '00000';

LET viSqlError = 0;

BEGIN

  ON EXCEPTION SET viSqlError    --cacha el error en caso de que exista y regresa un valor predeterminado

		RETURN viSqlError;

    END EXCEPTION;

	--SET DEBUG FILE TO "/tmp/conciliacion/cargarsurt.txt";
	--TRACE ON;
    --set explain on;
	
	--S2011100301.dat
	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	EXECUTE PROCEDURE BdiTarjCop:"informix".sp_EsNumerico (SUBSTR(psNomArchivo, 2,10)) INTO vsFlagSoloNumeros;


	IF (LENGTH ( TRIM(psNomArchivo)) <> 15 )  THEN --EL NOMBRE DEL ARCHIVO NO POSEE LA EXTENCION CORRESPONDIENTE
		LET vsCodRetorno = '00001';
		
	ELIF ((SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'S') AND (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 1 FOR 1) <> 'G')) THEN -- NO ES ARCHIVO DE SURTIDO
		LET vsCodRetorno = '00002';
		
	ELIF ( vsFlagSoloNumeros <> 'V' ) THEN --VALIDA QUE LA FECHA DEL ARCHIVO CONTENGA UNICAMENTE NUMEROS
		LET vsCodRetorno = '00003';
	
	ELIF ((SUBSTR(psNomArchivo, 2,4)::INTEGER < 1900) OR (SUBSTR(psNomArchivo, 2,4)::INTEGER > 2900)) THEN --SE VALIDA QUE EL ANO SEA CORRECTO
		LET vsCodRetorno = '00004';	
	
	ELIF ((SUBSTR(psNomArchivo, 6,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 6,2)::INTEGER > 12)) THEN --SE VALIDA QUE EL MES SEA CORRECTO
		LET vsCodRetorno = '00005';	
	
	ELIF  ((SUBSTR(psNomArchivo, 8,2)::INTEGER < 1) OR (SUBSTR(psNomArchivo, 8,2)::INTEGER > 31)) THEN --SE VALIDA QUE EL DIA SEA CORRECTO
		LET vsCodRetorno = '00006';

	ELIF (SUBSTRING ( UPPER( TRIM(psNomArchivo)) FROM 12 FOR 4) <> '.DAT') THEN -- NO ES ARCHIVO DE EXTENCION DAT
		LET vsCodRetorno = '00007';
	
	ELIF NOT EXISTS (SELECT Empresa FROM BdiTarjCop:"informix".InventarioTarCop WHERE Empresa = psEmpresa ) THEN  --NO EXISTE LA EMPRESA PROPORCIONADA
		LET vsCodRetorno = '00008';	
		
	ELIF EXISTS ( SELECT NomArchivo FROM BdiTarjCop:"informix".BitacoraTarCop WHERE NomArchivo = psNomArchivo AND CodRetorno = '00000') THEN --CHECA QUE EL ARCHIVO NO FUE PROCESADO ANTERIORMENTE.
		LET vsCodRetorno = '00009';
		
	ELSE --OK
		LET vsCodRetorno = '00000';
		
	END IF ;

	RETURN vsCodRetorno;

END

END PROCEDURE
DOCUMENT
'AUTOR: Casanova Edeza Hector Juan',
'Proyecto: Alta Única',
'Descripcion: VALIDA EL NOMBRE DE ARCHIVO DE ENVIOS DE TARJETAS COPPEL.',
'Fecha: 2011/12/23',
'Version: 20111223.1700',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_ostelefonica(
psEmpresa CHAR(3),
psClaveSucursal CHAR(4),
psFlagActDesact CHAR(1)
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Registrar una sucursal en el sistema de inventario de tarjetas coppel para que la sucursal pueda asignar tarjetas coppel.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 29/01/2009
-- BD: bditarjcop
-- SISTEMA : Caja Unica
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);

LET viSqlErr = 0;
LET vsCodRet = '';

--SET DEBUG FILE TO "/tmp/sp_OsTelefonica.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	END IF;
END EXCEPTION;

--Proceso de activacion de opcion supervision telefonica
IF(psFlagActDesact = 'V')THEN
	--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este en operacion.
	IF EXISTS(SELECT empresa, sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psClaveSucursal)THEN
		--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal se encuentre resgistrada en cajaunica.
		IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
			--Registra y activa sucursal en ostelefonica en caso que no exista.
			INSERT INTO bditarjcop:"informix".sucursalescajaunica(
			empresa, cvesucursal, cajaunica, fechaactcu, ostelefonica)
			VALUES(
			psEmpresa, psClaveSucursal, 'F', '1900-01-01 00:00:00.0', 'V');
			--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la operación se realizo de manera exitosa.
			LET vsCodRet = '00000';
		ELIF EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND ostelefonica = 'V')THEN
			--La sucursal se encuentra con ostelefonica activada actualmente.
			LET vsCodRet = '01600';
		ELSE
			--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de caja unica con estatus activa.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			UPDATE bditarjcop:"informix".sucursalescajaunica SET ostelefonica = 'V' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			LET vsCodRet = '00000';
		END IF;
	ELSE
		--La sucursal no esta en operacion
		LET vsCodRet = '01602';
	END IF;
--Proceso de desactivacion de opcion supervision telefonica
ELIF(psFlagActDesact = 'F')THEN
	--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este en operacion.
	IF EXISTS(SELECT empresa, sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psClaveSucursal)THEN
		--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal se encuentre resgistrada en cajaunica.
		IF EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND ostelefonica = 'V')THEN
			--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de ostelefonica con estatus inactiva.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			UPDATE bditarjcop:"informix".sucursalescajaunica SET ostelefonica = 'F' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--El Sistema de Registro Sucursal Tarjetas Coppel marca el producto para la sucural correspondiente con la opcion de de ostelefonica inactiva.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			UPDATE bditarjcop:"informix".prodostelefonica SET ostelefonica = "F" WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la operación se realizo de manera exitosa.
			LET vsCodRet = '00000';
		ELSE
			--La sucursal actualmente esta desactivada en ostelefonica
			LET vsCodRet = '01601';
		END IF;
	ELSE
		--La sucursal no se encuentra en operacion.
		LET vsCodRet = '01602';
	END IF;
ELSE
	--Parametro no valido
	LET vsCodRet = '01603';
END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registrar una sucursal en el sistema de inventario de tarjetas coppel para que la sucursal pueda asignar tarjetas coppel.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'MODIFICA: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Marca inactivos los productos para la sucursal correspondiente con estatus de os telefonica.',
'Fecha: 2012/01/09',
'Version: 20120109.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_registrarsucursaltarcop(
psEmpresa CHAR(3),
psCveSuc CHAR(4),
pdFechaActSuc DATE
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Registrar una sucursal en el sistema de inventario de tarjetas coppel para que la sucursal pueda asignar tarjetas coppel.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 29/01/2009
-- BD: bditarjcop
-- SISTEMA : Caja Unica
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE psClaveSucursal CHAR(4);

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET psClaveSucursal = '';

--SET DEBUG FILE TO "/tmp/sp_RegistrarSucursalTarCop.out"; 
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
		RETURN viSqlErr;
	END IF;
END EXCEPTION;

LET psClaveSucursal = psCveSuc;
--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este en operacion.
IF EXISTS(SELECT empresa, sucursal FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psClaveSucursal)THEN
	--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal se encuentre resgistrada en cajaunica.
	IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
		--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal no tenga un inventario de tarjetas coppel asignado.
		IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
			--Registra sucursal en cajaunica en caso que no exista.
			INSERT INTO bditarjcop:"informix".sucursalescajaunica(
			empresa, cvesucursal, cajaunica, fechaactcu)
			VALUES(
			psEmpresa, psClaveSucursal, 'V', pdFechaActSuc);
			--El Sistema de Registro Sucursal Tarjetas Coppel guarda un registro de inventario para las tarjetas numeradas de la nueva sucursal.
			INSERT INTO bditarjcop:"informix".inventariotarcop(
			empresa, cvesucursal, consumo, existencia, tipotarjeta)
			VALUES(
			psEmpresa, psClaveSucursal, 0, 0, 'N');
			--El Sistema de Registro Sucursal Tarjetas Coppel guarda un registro de inventario para las tarjetas de reposición de la nueva sucursal..
			INSERT INTO bditarjcop:"informix".inventariotarcop(
			empresa, cvesucursal, consumo, existencia, tipotarjeta)
			VALUES(
			psEmpresa, psClaveSucursal, 0, 0, 'R');
			--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la operación se realizo de manera exitosa.
			LET vsCodRet = '00000';
		--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la sucursal posee un inventario de tarjetas coppel asignado.
		ELSE
			LET vsCodRet = '00802';
		END IF;
	ELSE
		IF EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND cajaunica = 'V')THEN
			--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la sucursal posee la opcion de caja unica activa.
			LET vsCodRet = '00801';
		ELSE
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de caja unica con estatus activa y reinicia la fecha de activacion.
			UPDATE bditarjcop:"informix".sucursalescajaunica SET cajaunica = 'V', fechaactcu = pdFechaActSuc WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal no tenga un inventario de tarjetas coppel asignado.
			IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
				--El Sistema de Registro Sucursal Tarjetas Coppel guarda un registro de inventario para las tarjetas numeradas de la nueva sucursal.
				INSERT INTO bditarjcop:"informix".inventariotarcop(
				empresa, cvesucursal, consumo, existencia, tipotarjeta)
				VALUES(
				psEmpresa, psClaveSucursal, 0, 0, 'N');
				--El Sistema de Registro Sucursal Tarjetas Coppel guarda un registro de inventario para las tarjetas de reposición de la nueva sucursal..
				INSERT INTO bditarjcop:"informix".inventariotarcop(
				empresa, cvesucursal, consumo, existencia, tipotarjeta)
				VALUES(
				psEmpresa, psClaveSucursal, 0, 0, 'R');
				--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la operación se realizo de manera exitosa.
				LET vsCodRet = '00000';
			--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la sucursal posee un inventario de tarjetas coppel asignado.
			ELSE
			LET vsCodRet = '00802';
			END IF;
		END IF;
	END IF;
--El Sistema de Registro Sucursal Tarjetas Coppel informa al Sistema de operaciones que la sucursal no esta en operacion.
ELSE
	LET vsCodRet = '00800';
END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registrar una sucursal en el sistema de inventario de tarjetas coppel para que la sucursal pueda asignar tarjetas coppel.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registrar una sucursal en el sistema de inventario de tarjetas coppel para que la sucursal pueda asignar tarjetas coppel.',
'Fecha: 2011/12/27',
'Version: 20111227.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_activadesactivaproductos(
psEmpresa CHAR(3), 
piTipo INTEGER, 
psTipoOrigen CHAR(1), 
psCodigo CHAR(4), 
psProducto CHAR(4), 
psSistema CHAR(2),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5); -- Código de retorno

-- Declaración de variables
DEFINE vsCodRet					CHAR(5);
DEFINE viSqlErr					INTEGER;
DEFINE viSamErr					INTEGER;
DEFINE vsErrorInfo				CHAR(60);
DEFINE vsSucursales				CHAR(4);
DEFINE viExiste					INTEGER;
DEFINE vsFlagAltaU				CHAR(1);
DEFINE vsNombreSuc				CHAR(40);

DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE viDesactivadas		INTEGER;
DEFINE vsiTipo				INTEGER;
LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET viDesactivadas		= 0;
LET vsiTipo 			= 0;

-- Asignación variables
LET vsCodRet				= '00000';
LET viSqlErr				= 0;
LET viSamErr				= 0;
LET vsErrorInfo				= '';
LET vsSucursales			= '';
LET viExiste				= 0;
LET vsFlagAltaU				= '';
LET vsNombreSuc				= '';

BEGIN

ON EXCEPTION SET viSqlErr, viSamErr, vsErrorInfo
	LET vsCodRet = viSqlErr;
	RETURN vsCodRet;
END EXCEPTION;

--SET DEBUG FILE TO "/tmp/sp_activadesactivaproductos.sql";
--TRACE ON;

LET vsiTipo = piTipo;

IF (vsiTipo = 1) THEN --Activación
	IF (psTipoOrigen = 'E') THEN --Activacion de productos para Estado
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S'
				IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF (psTipoOrigen = 'R') THEN --Activacion de productos para Region
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
											   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
				WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
				AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
				IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo <> '')) THEN --Activacion de productos para Sucursal
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT COUNT(num_producto) INTO viExiste FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = psCodigo AND num_producto = psProducto;
			IF (viExiste = 0) THEN
				INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
				VALUES (psEmpresa, psCodigo, psProducto, psSistema);
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;

			IF NOT EXISTS(SELECT * FROM bdisolic:"informix".ss_control_parametricos where empresa = psEmpresa AND sucursal = psCodigo AND num_producto = psProducto) THEN
				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6001', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix',TODAY);

				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6600', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix', TODAY);

				INSERT INTO bdisolic:"informix".ss_control_parametricos(empresa, num_producto, sucursal, num_parametrico, descripcion, user_insert, fecha_insert)
				VALUES(psEmpresa, '6300', psCodigo, '2', ' Nuevo modelo paramétrico CRIF', 'informix', TODAY);
			END IF;
		END IF;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo = '')) THEN --Activacion de productos para todas las Sucursales
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = 'S'
				IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	ELIF (psTipoOrigen = 'D') THEN --Activacion de productos para Division
		EXECUTE PROCEDURE bditarjcop:"informix".sp_validasucprodaltaunica(psEmpresa, psTipoOrigen, psCodigo, psProducto) INTO vsCodRet;
		IF (vsCodRet = '00000')THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'
				IF NOT EXISTS(SELECT sucursal, num_producto FROM bdinteg:"informix".si_prod_sucursal WHERE sucursal = vsSucursales AND num_producto = psProducto) THEN
					INSERT INTO bdinteg:"informix".si_prod_sucursal (empresa, sucursal, num_producto, sistema)
					VALUES (psEmpresa, vsSucursales, psProducto, psSistema);
					EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Activación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				END IF;
			END FOREACH;
		END IF;
	END IF;
ELIF (vsiTipo = 0) THEN--Desactivacion
	IF (psTipoOrigen = 'E') THEN --Desactivacion de productos para Estado
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = 'S'
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF (psTipoOrigen = 'R') THEN --Desactivacion de productos para Region
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
										   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo <> '')) THEN --Desactivacion de productos para Sucursal
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE sucursal = psCodigo AND tpo_sucursal = 'S';
		DELETE FROM bdinteg:"informix".si_prod_sucursal 
		WHERE empresa = psEmpresa AND sucursal = psCodigo AND num_producto = psProducto AND sistema = psSistema;
		EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
	ELIF ((psTipoOrigen = 'S') AND (psCodigo = '')) THEN --Desactivacion de productos para todas las Sucursales
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE tpo_sucursal = 'S'
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	ELIF (psTipoOrigen = 'D') THEN --Desactivacion de productos para Division
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre INTO vsSucursales, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'
			DELETE FROM bdinteg:"informix".si_prod_sucursal 
			WHERE empresa = psEmpresa AND sucursal = vsSucursales AND num_producto = psProducto AND sistema = psSistema;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursales, vsNombreSuc, 'PR', 'Desactivación', CURRENT::DATE, psProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END FOREACH;
	END IF;
END IF;

RETURN vsCodRet;
	
END;
END PROCEDURE
DOCUMENT
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Activa y desactiva productos por grupo de sucursales o individual.',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bdinteg',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se modifico tipo de parametro de cha a smallint.',
'Fecha: 2012/06/18',
'Versión: 20120618.1800',
'BD: bditarjcop''MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se agrego Set lock mode to wait a Desactivacion de productos para Sucursal.',
'Fecha: 2012/07/06',
'Versión: 20120706.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_guardareporte(
psEmpresa CHAR(3),
psCveSucursal CHAR(4),
psNomSucursal CHAR(40),
psTipoConsulta CHAR(2),
psTipoCambio CHAR(13),
pdFechaProg DATE,
psProducto CHAR(4),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret;

--***********************************************************************************************************
-- DESCRIPCION: Guarda registro de cualquier activacion o desactivacion de producto, sucursal, ostelefonica.
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2012/01/25
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_guardareporte.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr;
	END IF;
END EXCEPTION;

IF (((psEmpresa IS NOT NULL) AND (psEmpresa <> "")) AND (psCveSucursal IS NOT NULL) AND (psNomSucursal IS NOT NULL) AND (psTipoConsulta IS NOT NULL) 
						   AND (psTipoCambio IS NOT NULL) AND (pdFechaProg IS NOT NULL) AND (psProducto IS NOT NULL) 
						   AND (psClaveUsuario IS NOT NULL) AND (psNombreUsuario IS NOT NULL)) THEN
	INSERT INTO bditarjcop:"informix".reportetarcop
	(
	cve_sucursal,
	nom_sucursal,
	tipo_consulta,
	tipo_cambio,
	fecha_prog,
	producto,
	cve_usuario,
	nom_usuario,
	fecha_reg
	)
	VALUES
	(
	psCveSucursal,
	psNomSucursal,
	psTipoConsulta,
	psTipoCambio,
	pdFechaProg,
	psProducto,
	psClaveUsuario,
	psNombreUsuario,
	CURRENT
	);
ELSE
	LET vsCodRet = "10000";
END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Guarda registro de cualquier activacion o desactivacion de producto, sucursal, ostelefonica',
'Fecha: 2012/01/25',
'Versión: 20120125.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_madpstelitdc_cat(psTipoBusqueda CHAR(1))

RETURNING CHAR(5) AS CodRet, CHAR(10) AS Codigo, CHAR(40) AS CodDescripcion;

--***********************************************************************************************************
-- DESCRIPCION: Consulta diferentes tipos de búsqueda por la aplicación madsupteli.exe
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE vsCodDescripcion		CHAR(40); --Variable utilizada para obtener diferentes tipos de busqueda, estado, región, sucursal, división, contiene codigo y nombre.
DEFINE vsCodigo				CHAR(10); --Contiene codigo referente a estado, región, sucursal, división.

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET vsCodDescripcion = "";
LET vsCodigo = "";

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_madpstelitdc_cat.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "");
	END IF;
END EXCEPTION;

--Se realiza consulta por estado.
IF(psTipoBusqueda == "E")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT estado, estado ||" - "|| nombre INTO vsCodigo, vsCodDescripcion FROM bdinteg:"informix".si_estados ORDER BY estado
		RETURN vsCodRet, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "") WITH RESUME;
	END FOREACH
--Se realiza consulta por región.
ELIF(psTipoBusqueda == "R")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT numero_region, numero_region ||" - "|| nombre_region INTO vsCodigo, vsCodDescripcion FROM bdinteg:"informix".si_regiones ORDER BY numero_region
		RETURN vsCodRet, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "") WITH RESUME;
	END FOREACH
--Se realiza consulta por sucursal.
ELIF(psTipoBusqueda == "S")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT "", " TODAS" FROM bdinteg:"informix".si_sucursales
		UNION
		SELECT sucursal, sucursal ||" - "|| nombre INTO vsCodigo, vsCodDescripcion FROM bdinteg:"informix".si_sucursales  WHERE tpo_sucursal = "S"
		RETURN vsCodRet, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "") WITH RESUME;
	END FOREACH
--Se realiza consulta por división.
ELIF(psTipoBusqueda == "D")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT DISTINCT(sipla.plaza), sipla.regional ||" - "|| sipla.nombre
		INTO vsCodigo, vsCodDescripcion
		FROM bdinteg:"informix".si_plazas AS sipla, bdinteg:"informix".si_sucursales AS sisuc
		WHERE sipla.plaza = sisuc.plaza
		AND sisuc.tpo_sucursal = "S"
		GROUP BY 1, 2 
		ORDER BY 2
		--SELECT plaza, regional ||" - "|| nombre INTO vsCodigo, vsCodDescripcion FROM bdinteg:"informix".si_plazas ORDER BY regional, plaza
		RETURN vsCodRet, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "") WITH RESUME;
	END FOREACH
--Se realiza consulta de productos.
ELIF(psTipoBusqueda == "P")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT num_producto, num_producto || " - " || nombre_prod INTO vsCodigo, vsCodDescripcion FROM bdicred:"informix".sd_definicion ORDER BY num_producto
		RETURN vsCodRet, NVL(vsCodigo, ""), NVL(vsCodDescripcion, "") WITH RESUME;
	END FOREACH
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta diferentes tipos de busqueda por la aplicacion madsupteli.exe',
'Fecha: 2011/12/27',
'Versión: 20111227.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_madpstelitdc_prodos(
psEmpresa CHAR(3),
psClaveSucursal CHAR(4),
psNumProducto CHAR(4),
psFlagActDesact CHAR(1),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Registrar un producto para una sucursal con supervision telefonica.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 09/01/2012
-- BD: bditarjcop
-- SISTEMA : Alta Única
--****************************************************************************************************

DEFINE viSqlErr		INTEGER;
DEFINE vsCodRet		CHAR(5);
DEFINE vsNombreSuc	CHAR(40);

LET viSqlErr = 0;
LET vsCodRet = '00000';
LET vsNombreSuc	= "";

--SET DEBUG FILE TO "/tmp/sp_madpstelitdc_prodos.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	END IF;
END EXCEPTION;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
SELECT nombre
INTO vsNombreSuc
FROM bdinteg:"informix".si_sucursales
WHERE empresa = psEmpresa
AND sucursal = psClaveSucursal
AND tpo_sucursal = "S";
--Proceso de activacion de opcion supervision telefonica
IF(psFlagActDesact = 'V')THEN
	EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, psClaveSucursal, "V") INTO vsCodRet;
	IF(vsCodRet == "00000")THEN
		IF NOT EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".prodostelefonica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto)THEN
			INSERT INTO bditarjcop:"informix".prodostelefonica(empresa, cvesucursal, numproducto, ostelefonica)
			VALUES(psEmpresa, psClaveSucursal, psNumProducto, psFlagActDesact);
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psClaveSucursal, vsNombreSuc, "ST", "Activación", CURRENT::DATE, psNumProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			LET vsCodRet = '00000';
		ELIF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".prodostelefonica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto AND ostelefonica = "F")THEN
			--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de os telefonica con estatus activa.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			UPDATE bditarjcop:"informix".prodostelefonica SET ostelefonica = 'V' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psClaveSucursal, vsNombreSuc, "ST", "Activación", CURRENT::DATE, psNumProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			LET vsCodRet = '00000';
		ELSE
			--El producto se encuentra con ostelefonica activada actualmente.
			LET vsCodRet = '00702';
		END IF;
	ELIF(vsCodRet == "01600")THEN
		IF NOT EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".prodostelefonica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto)THEN
			INSERT INTO bditarjcop:"informix".prodostelefonica(empresa, cvesucursal, numproducto, ostelefonica)
			VALUES(psEmpresa, psClaveSucursal, psNumProducto, psFlagActDesact);
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psClaveSucursal, vsNombreSuc, "ST", "Activación", CURRENT::DATE, psNumProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			LET vsCodRet = '00000';
		ELIF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".prodostelefonica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto AND ostelefonica = "F")THEN
				--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de os telefonica con estatus activa.
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				UPDATE bditarjcop:"informix".prodostelefonica SET ostelefonica = 'V' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psClaveSucursal, vsNombreSuc, "ST", "Activación", CURRENT::DATE, psNumProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
				LET vsCodRet = '00000';
		ELSE
			--El producto se encuentra con ostelefonica activada actualmente.
			LET vsCodRet = '00702';
		END IF;
	END IF;
ELIF(psFlagActDesact = 'F')THEN
	IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".prodostelefonica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto AND ostelefonica = "V")THEN
		--El Sistema de Registro Sucursal Tarjetas Coppel marca la sucursal correspondiente con la opcion de ostelefonica con estatus inactiva.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjcop:"informix".prodostelefonica SET ostelefonica = 'F' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND numproducto = psNumProducto;
		EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psClaveSucursal, vsNombreSuc, "ST", "Desactivación", CURRENT::DATE, psNumProducto, psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		LET vsCodRet = '00000';
	ELSE
		--El producto ya se encuentra con estatus inactivo para os telefonica.
		LET vsCodRet = '00701';
	END IF;
END IF;
RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Registra productos de credito para supervision telefonica',
'Fecha: 2012/01/09',
'Versión: 20120109.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_madpstelitdc_sucau(
psEmpresa CHAR(3),
psTipoBusqueda CHAR(1),
psCodigo CHAR(4)
)

RETURNING CHAR(5) AS codret, CHAR(40) AS descripcion, CHAR(1) AS actdesau, CHAR(30) AS fechaactau;

--***********************************************************************************************************
-- DESCRIPCION: Consulta grupo de sucursales activadas o desactivadas en alta única
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE viDesactivadas		INTEGER;
DEFINE vsDescripcion		CHAR(40);
DEFINE vsFlagActDes			CHAR(1);
DEFINE vsFechaActAU			CHAR(30);
DEFINE vsSucursal			CHAR(4);
DEFINE viCoincidenFechas    INTEGER;

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

DEFINE vpsEmpresa			CHAR(3);
DEFINE vpsTipoBusqueda		CHAR(1);
DEFINE vpsCodigo			CHAR(4);

LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET viDesactivadas		= 0;
LET vsDescripcion		= '';
LET vsFlagActDes		= '';
LET vsFechaActAU		= '';
LET vsSucursal			= '';
LET viCoincidenFechas	= 0;

LET vsCodRet = '00000';
LET viSqlErr = 0;

LET vpsEmpresa			= '';
LET vpsTipoBusqueda		= '';
LET vpsCodigo			= '';

--SET DEBUG FILE TO "/dbexport/sp_madpstelitdc_sucau.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, NVL(vsDescripcion, ''), NVL(vsFlagActDes, ''), NVL(vsFechaActAU, '');
	END IF;
END EXCEPTION;

LET vpsEmpresa			= psEmpresa;
LET vpsTipoBusqueda		= NVL(psTipoBusqueda, '');
LET vpsCodigo			= NVL(psCodigo, '');

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;
--Se realiza consulta por estado.
IF(vpsTipoBusqueda = 'E')THEN
	--Realiza conteo de sucursales para el estado especificado.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) 
	INTO viCantidadSuc
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = vpsEmpresa
	AND estado = vpsCodigo 
	AND tpo_sucursal = 'S';
	
	--Obtiene sucursal correspondiente al estado como muestra.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 sucursal 
	INTO vsSucursal
	FROM bdinteg:"informix".si_sucursales
	WHERE empresa = vpsEmpresa 
	AND estado = vpsCodigo 
	AND tpo_sucursal = 'S';
	
	--Obtiene fecha de activacion de sucursal correspondiente al estado indicado.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 fechaactcu
	INTO vsFechaActAU
	FROM bditarjcop:"informix".sucursalescajaunica 
	WHERE cvesucursal = vsSucursal;
	
	--Obtiene la descripcion del estado y las sucursales activas y no activas en alta unica.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT siest.estado ||' - '|| siest.nombre,
	SUM(CASE WHEN sucau.cajaunica = 'V' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.cajaunica, 'F') = 'F' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.fechaactcu, '1900-01-01 00:00:00.0') = vsFechaActAU THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas, viCoincidenFechas
	FROM bdinteg:"informix".si_estados AS siest, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau, bdinteg:"informix".si_sucursales AS sisuc
	WHERE siest.estado = vpsCodigo
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.empresa = vpsEmpresa  
	AND sisuc.estado = vpsCodigo
	AND sisuc.tpo_sucursal = 'S'
	GROUP BY siest.estado, siest.nombre;
	
	--Se identifica si estan todas activas o no activas asi como tambien algunas activas y otras no.
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'V';
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'F';
	ELSE
		LET vsFlagActDes = 'W';
	END IF;
	
	--Se muestra fecha en caso que todas coincidan.
	IF(viCoincidenFechas = viCantidadSuc)THEN
		LET vsFechaActAU = vsFechaActAU;
	ELSE 
		LET vsFechaActAU = '1900-01-01 00:00:00.0';
	END IF;
	
	RETURN vsCodRet, NVL(vsDescripcion, ''), NVL(vsFlagActDes, ''), NVL(vsFechaActAU, '');
--Se realiza consulta por region.
ELIF (vpsTipoBusqueda = 'R') THEN
	--Realiza conteo de sucursales para la region especificada.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) 
	INTO viCantidadSuc 
	FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
	     bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
	WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = vpsCodigo;
	
	--Obtiene sucursal correspondiente a la region como muestra.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 sucursal
	INTO vsSucursal 
	FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
	     bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
	WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo;
	
	--Obtiene fecha de activacion de sucursal correspondiente a la region indicada.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 fechaactcu
	INTO vsFechaActAU
	FROM bditarjcop:"informix".sucursalescajaunica 
	WHERE cvesucursal = vsSucursal;
	
	--Obtiene la descripcion de la region y las sucursales activas y no activas en alta unica.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sireg.numero_region ||' - '|| sireg.nombre_region,
	SUM(CASE WHEN sucau.cajaunica = 'V' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.cajaunica, 'F') = 'F' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.fechaactcu, '1900-01-01 00:00:00.0') = vsFechaActAU THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas, viCoincidenFechas
	FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
		 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau
	WHERE sisuc.tpo_sucursal = 'S' 
	AND sireg.numero_region = vpsCodigo
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.ciudad = siciu.ciudad 
	AND sisuc.pais = siciu.pais 
	AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad 
	AND sicat.numero_region = sireg.numero_region
	GROUP BY sireg.numero_region, sireg.nombre_region;
	
	--Se identifica si estan todas activas o no activas asi como tambien algunas activas y otras no.
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'V';
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'F';
	ELSE
		LET vsFlagActDes = 'W';
	END IF;
	
	--Se muestra fecha en caso que todas coincidan.	
	IF(viCoincidenFechas = viCantidadSuc)THEN
		LET vsFechaActAU = vsFechaActAU;
	ELSE 
		LET vsFechaActAU = '1900-01-01 00:00:00.0';
	END IF;
	
	RETURN vsCodRet, NVL(vsDescripcion, ''), NVL(vsFlagActDes, ''), NVL(vsFechaActAU, '');
--Se realiza consulta por sucursal.
ELIF(vpsTipoBusqueda = 'S')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sucursal ||' - '||nombre,
	NVL((SELECT cajaunica FROM bditarjcop:"informix".sucursalescajaunica  WHERE cvesucursal = sucursal),'F'),
	NVL((SELECT fechaactcu FROM bditarjcop:"informix".sucursalescajaunica WHERE cvesucursal = sucursal),'1900-01-01 00:00:00.0')
	INTO vsDescripcion, vsFlagActDes, vsFechaActAU
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = vpsEmpresa 
	AND sucursal = vpsCodigo
	AND tpo_sucursal = 'S';
	RETURN vsCodRet, NVL(vsDescripcion, ''), NVL(vsFlagActDes, ''), NVL(vsFechaActAU, '');
--Se realiza consulta por division.
ELIF (vpsTipoBusqueda = 'D') THEN
	--Realiza conteo de sucursales para la division especificada.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) 
	INTO viCantidadSuc 
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = vpsEmpresa 
	AND plaza = vpsCodigo 
	AND tpo_sucursal = 'S';
	
	--Obtiene sucursal correspondiente a la division como muestra.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 sucursal
	INTO vsSucursal 
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = vpsEmpresa 
	AND plaza = vpsCodigo 
	AND tpo_sucursal = 'S';
	
	--Obtiene fecha de activacion de sucursal correspondiente a la division indicada.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT FIRST 1 fechaactcu
	INTO vsFechaActAU
	FROM bditarjcop:"informix".sucursalescajaunica 
	WHERE cvesucursal = vsSucursal;
	
	--Obtiene la descripcion de la division y las sucursales activas y no activas en alta unica.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sipla.regional ||' - '|| sipla.nombre,
	SUM(CASE WHEN sucau.cajaunica = 'V' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.cajaunica, 'F') = 'F' THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.fechaactcu, '1900-01-01 00:00:00.0') = vsFechaActAU THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas, viCoincidenFechas
	FROM bdinteg:"informix".si_plazas AS sipla, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau, bdinteg:"informix".si_sucursales AS sisuc
	WHERE sipla.plaza = vpsCodigo
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.empresa = vpsEmpresa  
	AND sisuc.plaza = vpsCodigo
	AND sisuc.tpo_sucursal = 'S'
	GROUP BY sipla.regional, sipla.nombre;
	
	--Se identifica si estan todas activas o no activas asi como tambien algunas activas y otras no.
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'V';
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = 'F';
	ELSE
		LET vsFlagActDes = 'W';
	END IF;
	
	--Se muestra fecha en caso que todas coincidan.
	IF(viCoincidenFechas = viCantidadSuc)THEN
		LET vsFechaActAU = vsFechaActAU;
	ELSE 
		LET vsFechaActAU = '1900-01-01 00:00:00.0';
	END IF;
	
	RETURN vsCodRet, NVL(vsDescripcion, ''), NVL(vsFlagActDes, ''), NVL(vsFechaActAU, '');
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta grupo de sucursales activadas o desactivadas en alta única',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Se validan registros no existentes en tabla sucursalescajaunica',
'Fecha: 2012/02/14',
'Versión: 20120214.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Regresa fecha de activacion de sucursal en caso de que coincidan todas las sucursales de un mismo grupo.',
'Fecha: 2012/06/18',
'Versión: 20120618.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_madpstelitdc_sucos(
psEmpresa CHAR(3),
psTipoBusqueda CHAR(1),
psCodigo CHAR(4),
psProducto CHAR(4)
)

RETURNING CHAR(5) AS codret, CHAR(40) AS descripcion, CHAR(1) AS actdesos;

--***********************************************************************************************************
-- DESCRIPCION: Consulta grupo de sucursales activadas o desactivadas en os telefonica
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE viDesactivadas		INTEGER;
DEFINE vsDescripcion		CHAR(40);
DEFINE vsFlagActDes			CHAR(1);

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET viDesactivadas		= 0;
LET vsDescripcion		= "";
LET vsFlagActDes		= "";

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_madpstelitdc_sucos.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr,  NVL(vsDescripcion, ""), NVL(vsFlagActDes, "");
	END IF;
END EXCEPTION;

--Se realiza consulta por estado.
IF(psTipoBusqueda == "E")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) 
	INTO viCantidadSuc
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = psEmpresa
	AND estado = psCodigo 
	AND tpo_sucursal = "S";

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT siest.estado ||" - "|| siest.nombre,
	SUM(CASE WHEN sucau.ostelefonica = "V" THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.ostelefonica, "F") = "F" THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas
	FROM bdinteg:"informix".si_estados AS siest, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau, bdinteg:"informix".si_sucursales AS sisuc
	WHERE siest.estado = psCodigo
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.empresa = psEmpresa  
	AND sisuc.estado = psCodigo
	AND sisuc.tpo_sucursal = "S"
	GROUP BY siest.estado, siest.nombre;
		
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "V";
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "F";
	ELSE
		LET vsFlagActDes = "W";
	END IF;
	RETURN vsCodRet,  NVL(vsDescripcion, ""), NVL(vsFlagActDes, "");
--Se realiza consulta por region.
ELIF (psTipoBusqueda == "R") THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
	WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sireg.numero_region ||" - "|| sireg.nombre_region,
	SUM(CASE WHEN sucau.ostelefonica = "V" THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.ostelefonica, "F") = "F" THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas
	FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
		 bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau
	WHERE sisuc.tpo_sucursal = "S" 
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.ciudad = siciu.ciudad 
	AND sisuc.pais = siciu.pais 
	AND sisuc.estado = siciu.estado
	AND siciu.ciudad_coppel = sicat.numerociudad 
	AND sicat.numero_region = sireg.numero_region 
	AND sireg.numero_region = psCodigo
	GROUP BY sireg.numero_region, sireg.nombre_region;
	
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "V";
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "F";
	ELSE
		LET vsFlagActDes = "W";
	END IF;
	RETURN vsCodRet,  NVL(vsDescripcion, ""), NVL(vsFlagActDes, "");
--Se realiza consulta por sucursal.
ELIF(psTipoBusqueda == "S")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sucursal ||" - " ||nombre,
	NVL((SELECT ostelefonica FROM bditarjcop:"informix".prodostelefonica WHERE cvesucursal = psCodigo AND numproducto = psProducto),'F')
	INTO vsDescripcion, vsFlagActDes
	FROM bdinteg:"informix".si_sucursales 
	WHERE empresa = psEmpresa 
	AND sucursal = psCodigo
	AND tpo_sucursal = "S";
	RETURN vsCodRet,  NVL(vsDescripcion, ""), NVL(vsFlagActDes, "");
--Se realiza consulta por division.
ELIF (psTipoBusqueda == "D") THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S";
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	SELECT sipla.regional ||" - "|| sipla.nombre,
	SUM(CASE WHEN sucau.ostelefonica = "V" THEN 1 ELSE 0 END),
	SUM(CASE WHEN NVL(sucau.ostelefonica, "F") = "F" THEN 1 ELSE 0 END)
	INTO vsDescripcion, viActivadas, viDesactivadas
	FROM bdinteg:"informix".si_plazas AS sipla, OUTER bditarjcop:"informix".sucursalescajaunica AS sucau, bdinteg:"informix".si_sucursales AS sisuc
	WHERE sipla.plaza = psCodigo
	AND sucau.cvesucursal = sisuc.sucursal 
	AND sisuc.empresa = psEmpresa  
	AND sisuc.plaza = psCodigo
	AND sisuc.tpo_sucursal = "S"
	GROUP BY sipla.regional, sipla.nombre;
	
	IF(viActivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "V";
	ELIF(viDesactivadas = viCantidadSuc)THEN
		LET vsFlagActDes = "F";
	ELSE
		LET vsFlagActDes = "W";
	END IF;
	RETURN vsCodRet, NVL(vsDescripcion, ""), NVL(vsFlagActDes, "");
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta grupo de sucursales activadas o desactivadas en os telefonica',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Se validan registros no existentes en tabla sucursalescajaunica',
'Fecha: 2012/02/14',
'Versión: 20120214.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_madpstelitdc_sucursales(
psEmpresa CHAR(3),
psTipoBusqueda CHAR(2),
psNumProducto CHAR(4)
)

RETURNING CHAR(5) AS CodRet, CHAR(4) AS cvesucursal, CHAR(40) AS Descripcion, CHAR(1) AS ActDes, CHAR(30) AS FechaActAU;

--***********************************************************************************************************
-- DESCRIPCION: Consulta sucursales activadas o desactivadas en alta única
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE vsClaveSuc			CHAR(4);
DEFINE vsDescripcion		CHAR(40);
DEFINE vsFlagActAU		CHAR(1);
DEFINE vsFlagActOS		CHAR(1); 
DEFINE vsFechaActAU			CHAR(30);

DEFINE vsCodRet				CHAR(5);
DEFINE viSqlErr				INTEGER;

LET vsClaveSuc = "";
LET vsDescripcion = "";
LET vsFlagActAU = "";
LET vsFlagActOS = "";
LET vsFechaActAU = "";

LET vsCodRet = "00000";
LET viSqlErr = 0;

--SET DEBUG FILE TO "/dbexport/sp_madpstelitdc_sucursales.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsClaveSuc, vsDescripcion, "", vsFechaActAU;
	END IF;
END EXCEPTION;

--Se realiza consulta por sucursal.
IF(psTipoBusqueda == "AU")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, sucursal ||" - " ||nombre,
		NVL((SELECT cajaunica FROM bditarjcop:"informix".sucursalescajaunica  WHERE cvesucursal = sucursal),'F'), 
		NVL((SELECT fechaactcu FROM bditarjcop:"informix".sucursalescajaunica WHERE cvesucursal = sucursal),'1900-01-01 00:00:00.0')
		INTO vsClaveSuc, vsDescripcion, vsFlagActAU, vsFechaActAU
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND tpo_sucursal = "S" 
		ORDER BY sucursal
		
		RETURN vsCodRet, NVL(vsClaveSuc, ""), NVL(vsDescripcion, ""), NVL(vsFlagActAU, ""), NVL(vsFechaActAU, "") WITH RESUME;
	END FOREACH
ELIF(psTipoBusqueda == "OS")THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, sucursal ||" - " ||nombre,
		NVL((SELECT ostelefonica FROM bditarjcop:"informix".prodostelefonica  WHERE cvesucursal = sucursal AND numproducto = psNumProducto),'F')
		INTO vsClaveSuc, vsDescripcion, vsFlagActOS
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND tpo_sucursal = "S" 
		ORDER BY sucursal
			
		RETURN vsCodRet, NVL(vsClaveSuc, ""), NVL(vsDescripcion, ""), NVL(vsFlagActOS, ""), "" WITH RESUME;
	END FOREACH
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Consulta sucursales activadas o desactivadas en alta única',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_regclaugruposuctarcop(
psEmpresa CHAR(3),
psRegClau CHAR(1),
psCierraInv CHAR(1),
psTipoRegistro CHAR(1),
psCodigo CHAR(4),
pdFechaActSuc DATE,
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret, CHAR(4) AS sucursal;

--***********************************************************************************************************
-- DESCRIPCION: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsSucursal CHAR(4);
DEFINE vsNombreSuc	CHAR(40);

LET viSqlErr = 0;
LET vsCodRet = '';
LET vsSucursal = '';
LET vsNombreSuc = '';

--SET DEBUG FILE TO "/informix/tmp/sp_regclaugruposuctarcop.out";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsSucursal;
	END IF;
END EXCEPTION;

IF(psTipoRegistro = 'E')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, nombre
		INTO vsSucursal, vsNombreSuc
		FROM bdinteg:"informix".si_sucursales 
		WHERE empresa = psEmpresa 
		AND estado = psCodigo 
		AND tpo_sucursal = 'S'
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH
ELIF(psTipoRegistro = 'R')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
									   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE sisuc.tpo_sucursal = 'S' AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
		AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH;
ELIF(psTipoRegistro = 'S')THEN
	IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, psCodigo, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psCodigo, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
	ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, psCodigo) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = 'S';
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, psCodigo, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
	END IF;
	RETURN vsCodRet, NVL(psCodigo, '') WITH RESUME;
ELIF(psTipoRegistro = 'D')THEN
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	FOREACH
		SELECT sucursal, nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = 'S'
		IF(psRegClau = 'R')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_registrarsucursaltarcop(psEmpresa, vsSucursal, pdFechaActSuc) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Activación', pdFechaActSuc, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		ELIF(psRegClau = 'C')THEN
			EXECUTE PROCEDURE bditarjcop:"informix".sp_clausurarsucursaltarcop(psEmpresa, psCierraInv, vsSucursal) INTO vsCodRet;
			IF (vsCodRet = '00000') THEN
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, 'CP', 'Desactivación', CURRENT::DATE, '', psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
		END IF;
		RETURN vsCodRet, NVL(vsSucursal, '') WITH RESUME;
	END FOREACH;
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel.',
'Fecha: 2011/12/27',
'Version: 20111227.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_regclaugruposuctarcopos(
psEmpresa CHAR(3),
psTipoRegistro CHAR(1),
psCodigo CHAR(4),
psFlagActDesact CHAR(1),
psClaveUsuario CHAR(8),
psNombreUsuario CHAR(40)
)

RETURNING CHAR(5) AS codret, CHAR(4) AS sucursal;

--***********************************************************************************************************
-- DESCRIPCION: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel
-- AUTOR : EDGAR IVAN ROCHIN ROCHA
-- FECHA : 2011/12/27
-- BD: bditarjcop
-- SISTEMA : Alta Única
--***********************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsSucursal CHAR(4);
DEFINE vsNombreSuc	CHAR(40);
DEFINE vsActDesact CHAR(13);

LET viSqlErr = 0;
LET vsCodRet = '';
LET vsSucursal = "";
LET vsNombreSuc = "";
LET vsActDesact = "";

--SET DEBUG FILE TO "/dbexport/sp_regclaugruposuctarcopos.sql";
--TRACE ON;

BEGIN 

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr, vsSucursal;
	END IF;
END EXCEPTION;

IF((psEmpresa <> "") OR (psEmpresa IS NOT NULL)) AND ((psCodigo <> "") OR (psCodigo IS NOT NULL)) AND ((psFlagActDesact <> "") OR (psFlagActDesact IS NOT NULL))THEN
	IF(psTipoRegistro == "E")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre
			INTO vsSucursal, vsNombreSuc
			FROM bdinteg:"informix".si_sucursales 
			WHERE empresa = psEmpresa 
			AND estado = psCodigo 
			AND tpo_sucursal = "S"
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH
	ELIF(psTipoRegistro == "R")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sisuc.sucursal, sisuc.nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
											   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH;
	ELIF(psTipoRegistro == "S")THEN
		EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, psCodigo, psFlagActDesact) INTO vsCodRet;
		IF (vsCodRet == "00000") THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			SELECT nombre INTO vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
			IF (psFlagActDesact == "V") THEN
				LET vsActDesact = "Activación";
			ELIF (psFlagActDesact == "F") THEN
				LET vsActDesact = "Desactivación";
			END IF;
			EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
		END IF;
		RETURN vsCodRet, NVL(psCodigo, "") WITH RESUME;
	ELIF(psTipoRegistro == "D")THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal, nombre INTO vsSucursal, vsNombreSuc FROM bdinteg:"informix".si_sucursales WHERE plaza = psCodigo AND tpo_sucursal = "S"
			EXECUTE PROCEDURE bditarjcop:"informix".sp_ostelefonica(psEmpresa, vsSucursal, psFlagActDesact) INTO vsCodRet;
			IF (vsCodRet == "00000") THEN
				IF (psFlagActDesact == "V") THEN
					LET vsActDesact = "Activación";
				ELIF (psFlagActDesact == "F") THEN
					LET vsActDesact = "Desactivación";
				END IF;
				EXECUTE PROCEDURE bditarjcop:"informix".sp_guardareporte(psEmpresa, vsSucursal, vsNombreSuc, "ST", vsActDesact, CURRENT::DATE, "", psClaveUsuario, psNombreUsuario) INTO vsCodRet;
			END IF;
			RETURN vsCodRet, NVL(vsSucursal, "") WITH RESUME;
		END FOREACH;
	END IF;
	
END IF;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Registra una sucursal o un grupo de sucursales en el sistema de inventario de tarjetas coppel.',
'Fecha: 2011/12/27',
'Version: 201090129.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_reportemovtoshis(
cTipo_Con CHAR(2),
dFecha_ini DATE,
dFecha_fin DATE
)

RETURNING VARCHAR(6), VARCHAR(80), VARCHAR(4), VARCHAR(40), VARCHAR(2), VARCHAR(15), DATE, VARCHAR(40), VARCHAR(9), VARCHAR(40), DATETIME YEAR TO FRACTION(5);

DEFINE  SQL_ERR           INTEGER;
DEFINE  ISAM_ERR          INTEGER;
DEFINE  ERROR_INFO        VARCHAR(80);
DEFINE  P_COD_RET         VARCHAR(6);
DEFINE  P_MENSAJE         VARCHAR(80);

DEFINE vc_cve_sucursal 	  VARCHAR(4);
DEFINE vc_nom_sucursal    VARCHAR(40);
DEFINE vc_tipo_consulta   VARCHAR(2);
DEFINE vc_tipo_cambio     VARCHAR(15);
DEFINE vc_fecha_prog      CHAR(10); 
DEFINE vc_producto        VARCHAR(40);
DEFINE vc_cve_usuario     VARCHAR(9);
DEFINE vc_nom_usuario     VARCHAR(40);
DEFINE vd_fecha_reg       DATETIME YEAR TO FRACTION(5); 


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET P_COD_RET    = SQL_ERR;
      LET P_MENSAJE  = ERROR_INFO;
      
		RETURN P_COD_RET, P_MENSAJE,vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			   vc_cve_usuario,vc_nom_usuario,vd_fecha_reg;
   END EXCEPTION;

--	SET debug file to '/tmp/sp_reportemovtoshis.sql';
--	TRACE ON;

--************************************************************
-- Creado por Manuel Osuna Valencia (23-01-2012)
-- Guarda reporte de activacion o desactivacion de productos o sucursales en alta unica, ostelefonica
-- Proyecto  Alta Única
--************************************************************

	LET P_COD_RET = '00000';
	LET P_MENSAJE = 'PROCESO EXITOSO';
	LET vc_cve_sucursal = '';
	LET vc_nom_sucursal    = '';
	LET vc_tipo_consulta   = '';
	LET vc_tipo_cambio     = '';
	LET vc_fecha_prog      = '01-01-1900'; 
	LET vc_producto        = '';
	LET vc_cve_usuario     = '';
	LET vc_nom_usuario     = '';
	LET vd_fecha_reg       = CURRENT;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
    FOREACH
		SELECT cve_sucursal, nom_sucursal, tipo_consulta, tipo_cambio, fecha_prog, producto, cve_usuario, nom_usuario, fecha_reg
		INTO vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			 vc_cve_usuario, vc_nom_usuario, vd_fecha_reg
		FROM bditarjcop:"informix".reportetarcop
		WHERE tipo_consulta = cTipo_Con AND fecha_reg::DATE BETWEEN dFecha_ini AND dFecha_fin
		
		RETURN P_COD_RET, P_MENSAJE,vc_cve_sucursal,vc_nom_sucursal,vc_tipo_consulta,vc_tipo_cambio,vc_fecha_prog,vc_producto,
			   vc_cve_usuario,vc_nom_usuario,vd_fecha_reg WITH RESUME;                 
	END FOREACH;

	IF (TRIM(vc_cve_sucursal) = '') THEN
		LET P_COD_RET = '00001';
		LET P_MENSAJE = 'NO EXISTEN DATOS';
		RETURN P_COD_RET, P_MENSAJE, vc_cve_sucursal, vc_nom_sucursal, vc_tipo_consulta, vc_tipo_cambio, null, vc_producto,
		vc_cve_usuario, vc_nom_usuario, null;
	END IF;
   
END;
END PROCEDURE
DOCUMENT
'AUTOR: MANUEL OSUNA VALENCIA',
'Proyecto: Alta Única',
'Descripcion: Guarda reporte de activacion o desactivacion de productos o sucursales en alta unica, ostelefonica.',
'Fecha: 2012/01/23',
'Version: 20120123.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Se modifica para que las fechas en el return no muestren dato en caso de no existir registros',
'Fecha: 2012/02/14',
'Versión: 20120214.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Rodolfo Gomez, Abraham Narvaez',
'Descripción: Se modifico tipo de fecha_prog de DATE a CHAR.',
'Fecha: 2012/06/18',
'Versión: 20120618.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_validasucprodaltaunica(
psEmpresa CHAR(3),
psTipoOrigen CHAR(1),
psCodigo CHAR(4),
psProducto CHAR(4)
)

RETURNING CHAR(5); -- Código de retorno

DEFINE vsCodRet					CHAR(5);
DEFINE viSqlErr					INTEGER;
DEFINE viCantidadSuc		INTEGER;
DEFINE viActivadas			INTEGER;
DEFINE vsSucursales				CHAR(4);

LET viCantidadSuc		= 0;
LET viActivadas			= 0;
LET vsCodRet				= '';
LET viSqlErr				= 0;
LET vsSucursales			= '';

--SET DEBUG FILE TO "/dbexport/sp_validasucprodaltaunica.sql";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
		RETURN viSqlErr;
	END IF;
END EXCEPTION;

IF (psProducto == "6500") THEN --Valida Producto TDC
	IF (psTipoOrigen = "E") THEN
		--Obtiene cantidad de sucursales del estado.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal del estado.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND estado = psCodigo AND tpo_sucursal = "S"
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "R") THEN
		--Obtiene cantidad de sucursales por region.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
		WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
		AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo;
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal de la region.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales AS sisuc, bdinteg:"informix".si_ciudades AS siciu,
												   bdinteg:"informix".si_catciudades AS sicat, bdinteg:"informix".si_regiones AS sireg
			WHERE sisuc.tpo_sucursal = "S" AND sisuc.ciudad = siciu.ciudad AND sisuc.pais = siciu.pais AND sisuc.estado = siciu.estado
			AND siciu.ciudad_coppel = sicat.numerociudad AND sicat.numero_region = sireg.numero_region AND sireg.numero_region = psCodigo
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "S") AND (psCodigo == "") THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND tpo_sucursal = "S"
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	ELIF (psTipoOrigen == "S") AND (psCodigo <> "") THEN
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
		--Obtiene la sucursal.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND sucursal = psCodigo AND tpo_sucursal = "S";
		--Valida si esta activada en altaunica.
		IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
			LET viActivadas = viActivadas + 1;
		END IF;
	ELIF (psTipoOrigen == "D") THEN
		--Obtiene cantidad de sucursales por division.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		SELECT COUNT(sucursal) INTO viCantidadSuc FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S";
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		FOREACH
			--Obtiene la sucursal de la division.
			SELECT sucursal INTO vsSucursales FROM bdinteg:"informix".si_sucursales WHERE empresa = psEmpresa AND plaza = psCodigo AND tpo_sucursal = "S"
			--Valida si esta activada en altaunica.
			IF EXISTS(SELECT cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = vsSucursales AND cajaunica = "V")THEN
				LET viActivadas = viActivadas + 1;
			END IF;
		END FOREACH;
	END IF;
	--Si la cantidad de sucursales activadas en alta unica del estado coincide con la cantidad total de sucursales de ese estado, continua...
	IF (viActivadas == viCantidadSuc) THEN
		LET vsCodRet = "00000";
	ELSE
		LET vsCodRet = "00003";
	END IF;
ELSE
	LET vsCodRet = "00000";
END IF;

RETURN vsCodRet;

END
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Solicitó: Jaime Garciadiego, Juan Miguel Rivas',
'Descripción: Valida que la(s) sucursal(es) esten activadas en alta única antes de ofertar el producto 6500 TDC coppel.',
'Fecha: 2011/12/29',
'Versión: 20111229.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_clausurarsucursaltarcop(
psEmpresa CHAR(3),
psCierraInv CHAR(1),
psClaveSucursal CHAR(4)
)

RETURNING CHAR(5) AS codret;

--****************************************************************************************************
-- DESCRIPCION: Desactivar la opción de caja única de una sucursal y bloquear el manejo de tarjetas coppel.
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 03/02/2009
-- BD: bditarjcop
-- SISTEMA : Caja Unica
--****************************************************************************************************

DEFINE viSqlErr INTEGER;
DEFINE vsCodRet CHAR(5);
DEFINE vsEmpresa CHAR(3);
DEFINE vsCveSucursal CHAR(5);
DEFINE vsTipoTarjeta CHAR(1);
DEFINE vsNumEnvio CHAR(9);
DEFINE vdFechaSurt DATETIME YEAR TO FRACTION(5);
DEFINE viCantidadRec INTEGER;
DEFINE viRangoIni INTEGER;
DEFINE viRangoFin INTEGER;
DEFINE vdFechaRec DATETIME YEAR TO FRACTION(5);
DEFINE vsEnvioDisponible CHAR(1);
DEFINE vsEmpleadoRec CHAR(9);
DEFINE vsNumGuia CHAR(25);
DEFINE vdFechaGuia DATETIME YEAR TO FRACTION(5);
DEFINE vsTipoSurtido CHAR(2);

DEFINE vdFecha DATETIME YEAR TO FRACTION(5);
DEFINE vsFechaMesAct CHAR(7);
DEFINE viConsumo INTEGER;
DEFINE viExistencia INTEGER;

LET viSqlErr = 0;
LET vsCodRet = "00000";
LET vsEmpresa = '';
LET vsCveSucursal = '';
LET vsTipoTarjeta = '';
LET vsNumEnvio = '';
LET vdFechaSurt = CURRENT;
LET viCantidadRec = 0;
LET viRangoIni = 0;
LET viRangoFin = 0;
LET vdFechaRec = CURRENT;
LET vsEnvioDisponible = '';
LET vsEmpleadoRec = '';
LET vsNumGuia = '';
LET vdFechaGuia = CURRENT;
LET vsTipoSurtido = '';

LET vdFecha = CURRENT;
LET vsFechaMesAct = '';
LET viConsumo = 0;
LET viExistencia = 0;

--SET DEBUG FILE TO "/tmp/sp_ClausurarSucursalTarCop.out";
--TRACE ON;

BEGIN

ON EXCEPTION SET viSqlErr   --Cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
	RETURN viSqlErr;
	END IF;
END EXCEPTION;

--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este en operacion.
IF EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal)THEN
	--El Sistema de Registro Sucursal Tarjetas Coppel valida que la sucursal este con la opcion de caja unica activa.
	IF EXISTS(SELECT empresa, cvesucursal, cajaunica FROM bditarjcop:"informix".sucursalescajaunica WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND cajaunica = 'V')THEN
		--El Sistema Inventario Caja Unica actualiza la opcion de caja unica de la sucursal a estatus inactiva y reinicia la fecha de activacion.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjcop:"informix".sucursalescajaunica SET cajaunica = 'F', fechaactcu = '1900-01-01 00:00:00.0' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
		--El Sistema Inventario Caja Unica marca como "Cancelado" a todos los envios asignados a la sucursal indicada por el Sistema de operaciones.
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		UPDATE bditarjcop:"informix".enviostarcop SET enviodisponible = 'C' WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
		--El Sistema Inventario Caja Unica guarda en el histórico el inventario actual de la sucursal indicada por el Sistema de operaciones.
		IF(psCierraInv == "V")THEN
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH
				SELECT empresa, cvesucursal, tipotarjeta, numenvio, fechasurt, cantidadrec, rangoini, rangofin, fecharec, enviodisponible, empleadorec, numguia, fechaguia, tiposurtido
				INTO vsEmpresa, vsCveSucursal, vsTipoTarjeta, vsNumEnvio, vdFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vdFechaRec, vsEnvioDisponible, vsEmpleadoRec, vsNumGuia, vdFechaGuia, vsTipoSurtido
				FROM bditarjcop:"informix".enviostarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal
				
				INSERT INTO bditarjcop:"informix".envioshisttarcop(
				empresa, cvesucursal, tipotarjeta, numenvio, fechasurt, cantidadrec, rangoini, rangofin, fecharec, enviodisponible, empleadorec, numguia, fechaguia, tiposurtido)
				VALUES(
				vsEmpresa, vsCveSucursal, vsTipoTarjeta, vsNumEnvio, vdFechaSurt, viCantidadRec, viRangoIni, viRangoFin, vdFechaRec, vsEnvioDisponible, vsEmpleadoRec, vsNumGuia, vdFechaGuia, vsTipoSurtido);
			END FOREACH;
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			DELETE bditarjcop:"informix".enviostarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--Verifica si el consumo y la existencia de esta sucursal se encuentra en cero.
			IF NOT EXISTS(SELECT empresa, cvesucursal FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal AND consumo = 0 AND existencia = 0)THEN
				--El Sistema Inventario Caja Unica guarda en el histórico el inventario actual de la sucursal indicada por el Sistema de operaciones.
				LET vdFecha = CURRENT MONTH TO MONTH;
				LET vsFechaMesAct = SUBSTRING(vdFecha FROM 6 FOR 2) || '/' || SUBSTRING(vdFecha FROM 1 FOR 4);
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				FOREACH
				SELECT empresa, cvesucursal, consumo, existencia, tipotarjeta
				INTO vsEmpresa, vsCveSucursal, viConsumo, viExistencia, vsTipoTarjeta
				FROM bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal
				
				INSERT INTO bditarjcop:"informix".estadisticahisttarcop(
				empresa, cvesucursal, consumo, existencia, fecha, tipotarjeta)
				VALUES(
				vsEmpresa, vsCveSucursal, viConsumo, viExistencia, vsFechaMesAct, vsTipoTarjeta);
				END FOREACH;
			END IF;
			--El Sistema Inventario Caja Unica elimina del inventario todos los registros de la sucursal indicada por el Sistema de operaciones.
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			DELETE bditarjcop:"informix".inventariotarcop WHERE empresa = psEmpresa AND cvesucursal = psClaveSucursal;
			--La operación se realizo de manera exitosa.
			LET vsCodRet = '00000';
		END IF;
	--La sucursal no existe en caja unica.
	ELSE
		LET vsCodRet = '01400';
	END IF;
	--La sucursal no esta en operacion.
ELSE
	LET vsCodRet = '01400';
END IF;

RETURN vsCodRet;

END 
END PROCEDURE
DOCUMENT
'AUTOR: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Desactivar la opción de caja única de una sucursal y bloquear el manejo de tarjetas coppel.',
'Fecha: 2009/01/29',
'Version: 201090129.1800',
'BD: bditarjcop',
'MODIFICO: EDGAR IVAN ROCHIN ROCHA',
'Proyecto: Alta Única',
'Descripcion: Se agrega flag para cerrar o no, el inventario existente para la sucursal a clausurar en alta única.',
'Fecha: 2012/01/06',
'Version: 20120106.1800',
'BD: bditarjcop';

CREATE PROCEDURE "informix".sp_conslotepend(pSucursal CHAR(4), pEmpresa CHAR(3))

RETURNING CHAR(5), CHAR(4), CHAR(1), INTEGER, INTEGER, INTEGER, CHAR(1), DATE;

	-- Autor: Manuel Ramos Figueroa
	-- Actividad: Consulta los envios de lotes de tarjetas por sucursal.
	-- Fecha de Solicitud: 05/11/2012

	DEFINE iSqlErr, iIsamErr	INTEGER;
	DEFINE cCodRetorno			CHAR(5);
	DEFINE cSucursal			CHAR(4);
	DEFINE cTipoTarjeta			CHAR(1);
    DEFINE iNumEnvio			INTEGER;
	DEFINE iRangoIni			INTEGER;
	DEFINE iRangoFin			INTEGER;
    DEFINE cStatus				CHAR(1);
	DEFINE dFechaSurtido		DATE;
	DEFINE cAux					CHAR(4);
	DEFINE cAux2				CHAR(4);
	DEFINE iTotalN				INTEGER;
	DEFINE iTotalR				INTEGER;

    LET cCodRetorno		= "00000";
	LET cSucursal		= "";
	LET cTipoTarjeta	= "";
    LET iNumEnvio		= 0;
	LET iRangoIni		= 0;
	LET iRangoFin		= 0;
    LET cStatus			= "";
	LET dFechaSurtido	= "";
	LET cAux			= "";
	LET cAux2			= "";
	LET iTotalN			= 0;
	LET iTotalR			= 0;

   --SET DEBUG FILE TO "/informix/lflores/sp_conslotepend.out";
   --TRACE ON;

    BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr
			IF iSqlErr != 0 THEN
				LET cCodRetorno = iSqlErr;
				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		SELECT LIMIT 1 cvesucursal INTO cAux FROM bditarjcop:"informix".enviostarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;
		SELECT LIMIT 1 cvesucursal INTO cAux2 FROM bditarjcop:"informix".envioshisttarcop WHERE empresa = pEmpresa AND cvesucursal = pSucursal;

		IF (cAux <> "" OR cAux2 <> "") THEN			
			FOREACH
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				INTO cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido 
				FROM bditarjcop:"informix".enviostarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal
				AND enviodisponible <> ''
				
				UNION ALL
				
				SELECT cvesucursal, tipotarjeta, numenvio, rangoini, rangofin, enviodisponible, fechasurt 
				FROM bditarjcop:"informix".envioshisttarcop 
				WHERE empresa = pEmpresa 
				AND cvesucursal = pSucursal 
				AND enviodisponible <> ''
				ORDER BY numenvio DESC, tipotarjeta

				IF (cTipoTarjeta == "N") THEN
					LET iTotalN = iTotalN + 1;
					IF iTotalN > 5 THEN
						CONTINUE FOREACH;
					END IF;
				ELIF (cTipoTarjeta == "R") THEN
					LET iTotalR = iTotalR + 1;
					IF iTotalR > 5 THEN
						CONTINUE FOREACH;
					END IF;
				END IF;

				RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido WITH RESUME;
			END FOREACH;
		ELSE
			--No existe la sucursal
			LET cCodRetorno = "00001";
			RETURN cCodRetorno, cSucursal, cTipoTarjeta, iNumEnvio, iRangoIni, iRangoFin, cStatus, dFechaSurtido;
		END IF;
    END;
END PROCEDURE;