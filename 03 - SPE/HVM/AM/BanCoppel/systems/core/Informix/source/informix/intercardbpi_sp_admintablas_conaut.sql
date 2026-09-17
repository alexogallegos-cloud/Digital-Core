CREATE PROCEDURE "informix".sp_admintablas_conaut(
psLogATM CHAR(1),
psLogPOS CHAR(1),
psCentral CHAR(1),
psMonitorConciliacionAut CHAR(1),
psBitacoraConciliacion CHAR(1),
psSysErrorConciliacion CHAR(1),
psConciliacionATM CHAR(1)
)

RETURNING INTEGER ;

--****************************************************************************************************
-- DESCRIPCION: MANTENIMIENTO PARA TABLAS DE CONCILIACION AUTOMATICA 
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 10/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--MODIFICADO: ROCHIN ROCHA EDGAR IVAN 18/09/2008 
--MODIFICADO: 2010/01/20 Hector Juan Casanova Edeza -Se agrego la la opcion para borrar el contenido antiguo de la tabla Con_ArchErrInt.
--MODIFICADO: 2010/02/10 Hector Juan Casanova Edeza -SE AGREGO EL BORRADO DE REGISTROS (MENORES A UN FECHA PARAMETRIZABLE) DE LAS TABLAS DE LA CONCILIACION ADMINISTRATIVA (CONADMIN Y CONARCHCOMISIONES).
--***************************************************************************************************

--Declaracion de variables
DEFINE vsLogATM CHAR(1);
DEFINE vsLogPOS CHAR(1);
DEFINE vsCentral CHAR(1);
DEFINE viMonitorConcAut INTEGER;
DEFINE viBitacoraConc INTEGER;
DEFINE viSysErrorConc INTEGER;
DEFINE vsError CHAR(1);
DEFINE vsError1 CHAR(1);
DEFINE vsError2 CHAR(1);
DEFINE viSQLerr INTEGER;
DEFINE vdFechaFin DATE;
DEFINE vsConciliacionATM CHAR(1);
DEFINE viCon_ArchErrInt INTEGER;
DEFINE viConAdMin INTEGER;

LET vsLogATM = '' ;
LET vsLogPOS = '';
LET vsCentral = '';
LET viMonitorConcAut = 0;
LET viBitacoraConc = 0;
LET viSysErrorConc = 0;
LET vsError = '' ;
LET vsError1 = '' ;
LET vsError2 = '' ;
LET viSQLerr = 0 ;
LET vdFechaFin = '';
LET vsConciliacionATM = '';
LET viCon_ArchErrInt = 0;
LET viConAdMin = 0;

--set debug file to "/tmp/conciliacion/sp_admin.out";
--Trace on;

BEGIN

	--Controlador de errores de informix
	ON EXCEPTION SET viSQLerr
		IF viSQLerr <> 0 THEN
			RETURN viSQLerr ;
		END IF;
	END EXCEPTION;

	--Verifica si el parametro de entrada de la tabla LOG_ATM es VERDADERO
	IF (psLogATM = 'V') THEN
	--Verifica si el administrador autoriza el borrado de la tabla LOG_ATM
			SET ISOLATION TO DIRTY READ ;
	        SELECT FIRST 1 UPPER(valor)  INTO vsLogATM FROM intercard:param_conciliacionauto WHERE descripcion  = 'LOG_ATM';
	END IF

	IF vsLogATM = 'V' THEN

	SET ISOLATION TO DIRTY READ ;
	--Verifica que no exista error en alguno de los siguentes archivos en la tabla de intercard:bitacora_conciliacion
		IF NOT EXISTS (SELECT flagerror  FROM  intercard:bitacora_conciliacion  WHERE archivoorigen IN('TMC','TMD','TMP')  AND flagerror = "V" AND fechaconciliacion::DATE = CURRENT::DATE) THEN
	                   

	--Verifica si existe la tabla LOG_ATM en la base de datos    
	IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'log_atm') THEN
			DROP TABLE  "informix".log_atm;
	END IF

	CREATE TABLE  "informix".log_atm
			(
			keyx serial not null ,
			fechaconciliacion datetime year to fraction(5) not null ,
			archivoorigen char(3) not null ,
			adquiriente char(4) not null ,
			secuenciaauth char(6) not null ,
			numtarjeta char(16) not null ,
			numcuenta char(13) not null ,
			descripcion1 char(15) not null ,
			indicadordereversa char(19) not null ,
			codigorespuesta char(2) not null ,
			Cajero CHAR(14) not null ,
			secuenciacajero char(14) not null ,
			fecha char(8) not null ,
			hora char(8) not null ,
			monto money(16,2) not null ,
			Resp CHAR(6) NOT NULL,
			Orden CHAR(6) NOT NULL,
			Red CHAR(7) NOT NULL,
			Dolares CHAR(7) NOT NULL,
			NumAutorizacion CHAR(6) NOT NULL,
			CodPais CHAR(2) NOT NULL,
			MontoOrigen CHAR(13) NOT NULL,
			CodMoneda CHAR(3) NOT NULL,
			MontoSurcharge MONEY(16,2) NOT NULL,
			Donativo MONEY(16,2) NOT NULL,
			Empresa CHAR(4) NOT NULL,
			Compania CHAR(10) NOT NULL,
			Monto_LoyaltyFee MONEY(16,2) NOT NULL,
			Monto_UsoLinea MONEY(16,2) NOT NULL,
			NomBancoEmisor CHAR(20) NOT NULL,
			BanderaAdquiriente CHAR(1) NOT NULL,
			query1 char(1000) not null ,
			codigoiso char(2) not null ,
			secuencia char(7) not null ,
			secuenciaorig char(7) not null ,
			codreversa char(3) not null ,
			comisionenlinea char(1) not null ,
			permitecomisionpendiente char(1) not null ,
			generocomisionpendiente char(1) not null ,
			seccomision char(7) not null ,
			montocomision money(16,2) not null ,
			codigoretcomision char(5) not null ,
			montomov money(16,2) not null ,
			montorealrevfzda money(16,2) not null ,
			movconciliado char(1) not null ,
			fechamov char(4) not null ,
			horamov char(6) not null ,
			movreversado char(1) not null ,
			enlinea char(1) not null ,
			idterminal char(16) not null ,
			descripccion2 char(100) not null ,
			descripccion3 char(100) not null ,
			registrocentral1 char(300) not null ,
			registrocentral2 char(300) not null ,
			query2 char(2000) not null ,
			estado char(60) not null ,
			tipoconciliacion char(2) not null ,
			nombrearchivo CHAR(30) DEFAULT '' NOT NULL,
			primary key (keyx,fechaconciliacion,archivoorigen) 
			);                 

		END IF
END IF

--Verifica si el parametro de entrada de la tabla LOG_POS es VERDADERO
IF (psLogPOS = 'V') THEN
--Verifica si el administrador autoriza el borrado de la tabla LOG_POS
SELECT FIRST 1 UPPER(valor)  INTO vsLogPOS FROM intercard:param_conciliacionauto WHERE descripcion  = 'LOG_POS';
END IF

	IF vsLogPOS = 'V' THEN
   
		IF NOT EXISTS (SELECT  flagerror  FROM  intercard:bitacora_conciliacion  WHERE archivoorigen IN( 'VNC','VND','VIC','VID','TCC','TCD','PNC')  AND flagerror = "V" AND fechaconciliacion::DATE = CURRENT::DATE) THEN
					

			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'log_pos') THEN
			   DROP TABLE   "informix".log_pos;
			END IF
					   
			CREATE TABLE  "informix".log_pos
			(
			keyx serial not null ,
			fechaconciliacion datetime year to fraction(5) not null ,
			archivoorigen char(3) not null ,
			numtarjeta char(16) not null ,
			tipotransaccion char(2) not null ,
			monto money(16,2) not null ,
			montocashback money(16,2) not null ,
			idcomercio char(9) not null ,
			nomcomercio char(30) not null ,
			secuencia char(6) not null ,
			reftransaccion char(30) not null ,
			rfc char(16) not null ,
			fuenteid char(3) not null ,
			numcuenta char(13) not null ,
			query1 char(800) not null ,
			codigoiso char(2) not null ,
			formato char(4) not null ,
			movconciliado char(1) not null ,
			fechamov char(4) not null ,
			horamov char(6) not null ,
			codigoapliccentral char(5) not null ,
			secuenciaorig char(7) not null ,
			horalocaltransaccion char(6) not null ,
			montorealfzda money(16,2) not null ,
			codtran char(2) not null ,
			enlinea char(1) not null ,
			idterminal char(8) not null ,
			prodind char(2) not null ,
			secuenciacashback char(7) not null ,
			secuenciacomisioncashback char(10) not null ,
			montocomisioncashback money(16,2) not null ,
			comisionenlinea char(1) not null ,
			permitecomisionpendiente char(1) not null ,
			generacomisionpendiente char(1) not null ,
			seccomision char(7) not null ,
			montocomision money(16,2) not null ,
			codigoretcomision char(5) not null ,
			idreceptor char(4) not null ,
			query2 char(350) not null ,
			rfcodigoiso char(2) not null ,
			rfmonto money(16,2) not null ,
			rfsecuencia char(7) not null ,
			rffechamov char(4) not null ,
			rfenlinea char(1) not null ,
			rfidterminal char(8) not null ,
			rfhoralocaltransaccion char(6) not null ,
			descripcion1 char(100) not null ,
			descripcion2 char(100) not null ,
			descripcion3 char(200) not null ,
			registrocentral1 char(300) not null ,
			registrocentral2 char(300) not null ,
			query3 char(2000) not null ,
			estado char(30) not null ,
			tipoconciliacion char(2) not null ,
			nombrearchivo CHAR(30) NOT NULL,
			primary key (keyx,fechaconciliacion,archivoorigen)
			);
							  
		END IF
END IF	

	--Verifica si el parametro de entrada de la tabla CENTRAL es VERDADERO
	IF (psCentral = 'V') THEN
	--Verifica si el administrador autoriza el borrado de la tabla CENTRAL

			SELECT FIRST 1 UPPER(valor)  INTO vsCentral FROM intercard:param_conciliacionauto WHERE descripcion  = 'CENTRAL';
	END IF

	IF vsCentral = 'V' THEN

		IF NOT EXISTS (SELECT  flagerror  FROM  intercard:bitacora_conciliacion  WHERE archivoorigen IN( 'TMC','TMD','TMP','VNC','VND','VIC','VID','TCC','TCD','PNC')  AND flagerror = "V" AND fechaconciliacion::DATE = CURRENT::DATE) THEN
	                 --Verifica si existe la tabla LOG_POS en la base de datos                  

			IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'central') THEN
			   DROP TABLE   "informix".central;
			END IF
			CREATE TABLE  "informix".central
			(
			keyx serial not null ,
			fechaconciliacion datetime year to fraction(5) not null ,
			archivoorigen char(3) not null ,
			ident_det char(1) not null ,
			tipomov char(1) not null ,
			transaccion char(4) not null ,
			sucursal char(4) not null ,
			foliosucursal char(15) not null ,
			numtarjeta char(16) not null ,
			documento char(15) not null ,
			importe money(16,2) not null ,
			moneda char(3) not null ,
			referencia char(40) not null ,
			folioorig char(15) not null ,
			doctoorig char(7) not null ,
			transaccionorig char(4) not null ,
			montooriginal money(16,2) not null ,
			rfc char(16) not null ,
			reftransaccion char(23) not null ,
			divisa char(3) default '',
			montodivisa money(16,2) default 0.00,
			numcajero char(14) default '',
			tipotransinterempresa char(4) default '',
			montocominterempresa money(16,2) default 0.00,
			formadepago char(1) default '',
			control char(1) default '',
			convenio char(10) default '',
			nombrearchivo CHAR(30) NOT NULL,
			IdArchivoCental CHAR(20) NOT NULL,
			primary key (keyx,fechaconciliacion,archivoorigen)
			);
							  
		END IF
END IF

--Verifica si el parametro de entrada de la tabla MONITOR_CONCILIACIONAUT es VERDADERO
IF (psMonitorConciliacionAut = 'V') THEN
--Verifica si el administrador autoriza el mantenimiento de la tabla MONITOR_CONCILIACIONAUT
	SET ISOLATION TO DIRTY READ ;
			SELECT UPPER(valor)  INTO viMonitorConcAut FROM intercard:param_conciliacionauto WHERE descripcion  = 'MONITOR_CONCILIACIONAUT';
			SELECT UPPER(valor)  INTO viConAdMin FROM intercard:param_conciliacionauto WHERE descripcion  = 'TABLAS_CONADMIN';
	END IF

	IF viMonitorConcAut > 0 THEN

		LET	vdFechaFin = CURRENT::DATE - viMonitorConcAut;
		
		DELETE FROM intercard:monitor_conciliacionaut WHERE fechaconciliacion::DATE <= vdFechaFin::DATE;
		
	END IF

--CONCILIACION ADMINISTRATIVA
	IF viConAdMin > 0 THEN

		LET	vdFechaFin = CURRENT::DATE - viConAdMin;
		
		DELETE FROM intercard:ConAdMin WHERE fecharegistro::DATE <= vdFechaFin::DATE;
		DELETE FROM intercard:ConArchComisiones WHERE fechamov::DATE <= vdFechaFin::DATE;
		
	END IF
	
	--Verifica si el parametro de entrada de la tabla BITACORA_CONCILIACION es VERDADERO
IF (psBitacoraConciliacion = 'V') THEN
		--Verifica si el administrador autoriza el mantenimiento de la tabla BITACORA_CONCILIACION
		SET ISOLATION TO DIRTY READ ;
		SELECT UPPER(valor)  INTO viBitacoraConc FROM intercard:param_conciliacionauto WHERE descripcion  = 'BITACORA_CONCILIACION';
END IF

IF viBitacoraConc > 0 THEN
		
		LET vdFechaFin = CURRENT::DATE - viBitacoraConc;
		DELETE FROM intercard:monitor_conciliacionaut WHERE fechaconciliacion::DATE <= vdFechaFin::DATE;
		
END IF


--Verifica si el parametro de entrada de la tabla SYSERROR_CONCILIACION es VERDADERO
	IF (psSysErrorConciliacion = 'V') THEN
		--Verifica si el administrador autoriza el mantenimiento de la tabla SYSERROR_CONCILIACION
		SET ISOLATION TO DIRTY READ ;
		SELECT UPPER(valor)  INTO viSysErrorConc FROM intercard:param_conciliacionauto WHERE descripcion  = 'SYSERROR_CONCILIACION';
		SELECT UPPER(valor)  INTO viCon_ArchErrInt FROM intercard:param_conciliacionauto WHERE descripcion  = 'CON_ARCHERRINT';
	END IF
	/*
	IF viSysErrorConc > 0 THEN
		
		LET vdFechaFin = CURRENT::DATE - viSysErrorConc;
		DELETE FROM intercard:monitor_conciliacionaut WHERE fechaconciliacion::DATE <= vdFechaFin::DATE;
		
	END IF
	*/
	IF viSysErrorConc > 0 THEN
		
		LET vdFechaFin = CURRENT::DATE - viCon_ArchErrInt;
		DELETE FROM Intercard:Con_ArchErrInt WHERE fechaconciliacion::DATE <= vdFechaFin::DATE;
		
	END IF
	
	IF (psConciliacionATM = "V" ) THEN

		SET ISOLATION TO DIRTY READ ;
		--Verifica si existe la tabla conciliacion_atm_in en la base de datos    
		IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'conciliacion_atm_in') THEN
			DROP TABLE  "informix".conciliacion_atm_in;
		END IF
		
		create table "informix".conciliacion_atm_in 
		(
		keyx serial not null ,
		fechaconciliacion datetime year to fraction(5) not null ,
		archivoorigen char(3) not null ,
		secuenciaauth char(6) not null ,
		numtarjeta char(16) not null ,
		fecha char(8) not null ,
		hora char(8) not null ,
		conciliado "informix".boolean not null ,
		adquiriente char(4) not null ,
		numcuenta char(13) not null ,
		descripcion char(15) not null ,
		indicadordereversa char(19) not null ,
		codigoiso char(2) not null ,
		secuenciacajero char(12) not null ,
		monto money(16,2) not null ,
		numcajero char(14) not null ,
		--PROSA
		Resp CHAR(6) NOT NULL,
		Orden CHAR(6) NOT NULL,
		Red CHAR(7) NOT NULL,
		Dolares CHAR(7) NOT NULL,
		NumAutorizacion CHAR(6) NOT NULL,
		CodPais CHAR(2) NOT NULL,
		MontoOrigen CHAR(13) NOT NULL,
		CodMoneda CHAR(3) NOT NULL,
		MontoSurcharge MONEY(16,2) NOT NULL,
		Donativo MONEY(16,2) NOT NULL,
		Empresa CHAR(4) NOT NULL,
		Compania CHAR(10) NOT NULL,
		Monto_LoyaltyFee MONEY(16,2) NOT NULL,
		Monto_UsoLinea MONEY(16,2) NOT NULL,
		NomBancoEmisor CHAR(20) NOT NULL,
		BanderaAdquiriente CHAR(1) NOT NULL,
		primary key (keyx,fechaconciliacion,archivoorigen) 
		);
	END IF

	RETURN viSQLerr ;
END

END PROCEDURE 
DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: MANTENIMIENTO PARA TABLAS DE CONCILIACION AUTOMATICA.',
'Fecha: 2008/09/10',
'Version: 20080910.1025',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego la la opcion para borrar el contenido antiguo de la tabla Con_ArchErrInt.',
'Fecha: 2010/01/20',
'Version: 20100120.1745',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: SE AGREGO EL BORRADO DE REGISTROS (MENORES A UN FECHA PARAMETRIZABLE) DE LAS TABLAS DE LA CONCILIACION ADMINISTRATIVA (CONADMIN Y CONARCHCOMISIONES).',
'Fecha: 2010/02/10',
'Version: 20100210.1055',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de los campos de NombreArchivo del script de creacion de las tablas, Log_Pos, Log_ATM y Central.',
'Fecha: 2010/04/13',
'Version: 20100413.0925',
'BD: Intercard',
'',
'Modificado: Reséndiz Martínez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de los campos de NombreArchivo a 30 del script de creacion de las tablas, Log_Pos, Log_ATM y Central ',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard';

CREATE PROCEDURE "informix".sp_genarcherroresconaut ( psUsuario CHAR(8), pdtFecha DATE )

RETURNING INTEGER AS Retorno ;

--****************************************************************************************************
-- DESCRIPCION:  Genera los archivos con los regiostrios con error de integridad correspondientes a cada archivo de conciliacion.
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 14/12/2009
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsSQL				CHAR (400);
DEFINE vsSQL1				CHAR(170);
DEFINE vsSQL2 				CHAR(130);
DEFINE vsSQL3 				CHAR(100);
DEFINE vsSQL4				CHAR(100);
DEFINE visqlerr INTEGER ;

DEFINE viContador INTEGER;
DEFINE vsRepositorioError CHAR (90);
DEFINE vsNomArchivoError CHAR (27);

DEFINE vsNomArchivo CHAR (30);
DEFINE vsRuta_Repositorio_AIX CHAR (90);
DEFINE vsArchivoOrigen CHAR (3); 
DEFINE vsRuta_Repositorio_WIN CHAR (90);

/* INICIALIZACION DE VARIABLES */
LET vsSQL = "";
LET vsSQL1 = "";
LET vsSQL2 = "";
LET vsSQL3 = "";
LET vsSQL4 = "";

LET visqlerr = 0;

LET viContador = 0;
LET vsRepositorioError = '';
LET vsNomArchivoError = '';

LET vsNomArchivo = '';
LET vsRuta_Repositorio_AIX  = '';
LET vsArchivoOrigen  = '';
LET vsRuta_Repositorio_WIN  = '';

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado        
		
		EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora( psUsuario, vsArchivoOrigen, 'GENARCH_ERROR' , 'ERROR INFORMIX NO CONTROLADO (' || visqlerr ||')') INTO viContador ;
		
		RETURN visqlerr ;
		
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/conciliacion/xxxxxxx.txt';
	--TRACE ON ;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ ;
	
	IF EXISTS ( SELECT valor FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = 'REP_ERROR_AIX') THEN  
		--OBTIENE REPOSITORIO.
		SELECT TRIM (valor) INTO vsRepositorioError FROM Intercard:Param_ConciliacionAuto WHERE Descripcion = 'REP_ERROR_AIX';
		
		WHILE (viContador < 29) --VERIFICA LA EXISTENCIA DE REG CON ERROR DE LOS 11 TIPOS DE ARCHIVO A CONCILIAR ()RECORRE LOS POSIBLES 29 ARCHIVOS (USADOS 11)
			
			LET viContador = viContador + 1 ;
			EXECUTE PROCEDURE sp_ObtenerNombreArchivo (viContador) INTO vsNomArchivo, vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN ;
			
			IF (TRIM(vsNomArchivo) <> '') THEN 
			
				IF EXISTS ( SELECT Registro FROM Intercard:Con_ArchErrInt WHERE FechaConciliacion = pdtFecha AND ArchivoOrigen = vsArchivoOrigen) THEN --VERIFICA SI EXISTEN REGISTROS DE ERROR PARA EL TIPO DE ARCHIVO ACTUAL.
					--BCPL***_DDMMAAAA.txt  /   BCPLVID_20062008.txt
					--BCPL_ATM*_DDMMAA.txt  /  BCPL_ATMD_270308.txt
					--BCPL_ATMOL_DDMMAA.txt  /  BCPL_ATMOL_270308.txt
					--BCPL_ATMPL_DDMMAA.txt  /  BCPL_ATMPL_270308.txt
					IF (vsArchivoOrigen == 'TMO') OR (vsArchivoOrigen == 'TMP')THEN 
						LET vsNomArchivoError = SUBSTRING (vsNomArchivo FROM 1 FOR 17) || '_ERROR.txt';
					ELSE
						LET vsNomArchivoError = SUBSTRING (vsNomArchivo FROM 1 FOR 16) || '_ERROR.txt';
					END IF;
					
					--GENERA EL ARCHIVO DE INTERCAMBIO 
					LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(vsRepositorioError) || '/' || TRIM(vsNomArchivoError)|| ' DELIMITER ' || '''|''';
					
					LET vsSQL2 = "SELECT Registro , ErrorRegistro FROM Intercard:Con_ArchErrInt WHERE FechaConciliacion = '" || pdtFecha || "' AND ArchivoOrigen = '" ||vsArchivoOrigen || "'";
					
					LET vsSQL3 = '">' || TRIM(vsRepositorioError) || '/tmp_conciliacionError.sql';
					
					LET vsSQL1 = TRIM(vsSQL1);
					LET vsSQL3 = TRIM(vsSQL3);
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
								
					IF ( vsSQL <> '' ) THEN 
						SYSTEM vsSQL ;
						LET vsSQL4 = '' ;
						LET vsSQL4 = 'dbaccess intercard ' || TRIM(vsRepositorioError) || '/tmp_conciliacionError.sql';
						SYSTEM vsSQL4 ;
					END IF;
					
					EXECUTE PROCEDURE Intercard:sp_Insertar_Bitacora( psUsuario, vsArchivoOrigen, 'GENARCH_ERROR' , '') INTO visqlerr ;
					
				END IF;
			ELSE --NO CONTIENE NOMBRE DE ARCHIVO
				
			END IF;
			
		END WHILE;

	ELSE --NO EXISTE EL REPOSITORIO DE ERROR
		LET visqlerr = 1; 
	END IF;
	
	RETURN visqlerr;
	
END;

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Genera los archivos con los regiostrios con error de integridad correspondientes a cada archivo de conciliacion.',
'Fecha: 2010/01/19',
'Version: 20100119.1710',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 23 caracteres y la variable de NomArchivoError a 27 caracteres, adems se agrego una validacion para identificar los nombres de archivos que contengan 20 y 23 caracteres para formar correctamente el nombre del archivo de error.',
'Fecha: 2010/04/14',
'Version: 20100414.1203',
'BD: Intercard'
'',
'Modificado: Reséndiz Martínez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de las variables de NombreArchivo a 30 caracteres .',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard'
*/;

CREATE PROCEDURE "informix".sp_insertar_bitacora ( psNumEmpleado CHAR (8), psArchivoOrigen CHAR (3),  psActividad CHAR (25), psDescripcionError CHAR (500) )

RETURNING INTEGER ;


--****************************************************************************************************
-- DESCRIPCION: GUARDA UN REGISTRO DEL ESTADO DE LA CONCILIACION (EXITO O ERROR)
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 10/03/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard
-- MODIFICADO : Casanova Edeza Hector Juan  2010/02/18 Se agrego un nuevo campo a la tabla syserror_conciliacion "nombrearchivo" el cual es obtenido mediante la consulta de la tabal de parametros de la conciliacion para conocer el archivo que esta procesandose actualmente.
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */ 
DEFINE vdtFecha DATETIME DAY TO FRACTION ;
DEFINE viSecuenciaBitacora INTEGER ;
DEFINE vsFlagError CHAR (1) ;
DEFINE vsNombreArchivo CHAR (30);

DEFINE viCodRet INTEGER ;
DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */
LET vdtFecha = CURRENT ;
LET viSecuenciaBitacora = 0;
LET vsFlagError = 'F' ;
LET vsNombreArchivo = '';

LET viCodRet = 0 ;
LET visqlerr = 0 ;

BEGIN

	ON EXCEPTION SET visqlerr
		IF visqlerr <> 0 THEN 
			LET viCodRet = visqlerr;
			--ROLLBACK WORK;
			RETURN viCodRet ;
		END IF; 
	END EXCEPTION;

	--BEGIN WORK ;

		SET LOCK MODE TO WAIT  ;
		SET ISOLATION TO DIRTY READ ;
		SELECT FIRST 1 valor INTO vsNombreArchivo FROM intercard:param_conciliacionauto WHERE descripcion = 'NOMBRE_ARCHIVO';
	
		IF (   NVL ( psDescripcionError, '' ) <> ''  ) THEN 
			LET vsFlagError = 'V' ;
		ELSE
			LET vsFlagError = 'F' ;
		END IF ;

		INSERT INTO BITACORA_CONCILIACION (
			FechaConciliacion,
			ArchivoOrigen ,
			Empleado,
			Actividad,
			FlagError
		)
		VALUES (
			vdtFecha ,
			NVL (psArchivoOrigen, '' ),
			NVL (psNumEmpleado, '' ), 
			NVL(psActividad, '' ),
			vsFlagError
		) ;

		--CHECA SI EXISTE ERROR PARA GUARDARLO EN LA TABLA SYSERROR
		IF ( vsFlagError = 'V' )  THEN 

			SET LOCK MODE TO WAIT  ;
			SET ISOLATION TO DIRTY READ ;

			SELECT limit 1 Keyx INTO viSecuenciaBitacora  FROM BITACORA_CONCILIACION WHERE FechaConciliacion = vdtFecha AND FlagError = vsFlagError ;
 
			INSERT INTO SYSERROR_CONCILIACION (
				Fecha,
                nom_archivo,
				SecuenciaBitacora,
				descripcionerror
			)
			VALUES (
				vdtFecha,
				TRIM( UPPER (NVL(vsNombreArchivo, ''))),
                viSecuenciaBitacora,
				psDescripcionError 
			) ;

		END IF ;

	--COMMIT WORK ;

	RETURN viCodRet ;

END

END PROCEDURE 
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GUARDA UN REGISTRO DEL ESTADO DE LA CONCILIACION (EXITO O ERROR).',
'Fecha: 2008/03/10',
'Version: 20080310.1025',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego un nuevo campo a la tabla syserror_conciliacion "nombrearchivo" el cual es obtenido mediante la consulta de la tabal de parametros de la conciliacion para conocer el archivo que esta procesandose actualmente.',
'Fecha: 2010/02/18',
'Version: 20100218.01835',
'BD: Intercard'
''
'Modificado: Reséndiz Martinez Ricardo ',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico campo de Nombre archivo a 30, por integracion de Archivo REDTCAT137DYYMMDDEDCC.DAT a proceso conciliacion 
'Fecha: 2011/10/06',
'Version: 20111006.1018',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_integridad_conciliacion_auto ( psArchivoorigen CHAR (3) )

RETURNING INTEGER AS Retorno, CHAR (1) AS FlagError, CHAR (200) AS MensajeError ;

--****************************************************************************************************
-- DESCRIPCION:  CHECA LA INTEGRIDAD DE LOS ARCHIVOS DE ATM Y POS
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 22/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 14/12/2009 Casanova Edeza Hector Juan. 
-- MODIFICADO : 22/04/2010 Casanova Edeza Hector Juan.  Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS. 
-- SISTEMA : Conciliacion Intercard -- Transferencia de prestamos coppel
-- MODIFICADO : 25/05/2011 Alfonso Antonio Cruz Alvarez.  Se modifico el flujo para que contemple los nuevos archivos archivos de transferencia de prestamos(TPD) se manejan como archivos de POS. 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE viContador 					INTEGER ;
DEFINE viNumRegistros 				INTEGER ;
DEFINE viNumTransacciones 			INTEGER ;
DEFINE vsRegistroATM 				CHAR(601);
DEFINE vsRegistroPOS 				CHAR(326);

DEFINE vsMensajeError 				CHAR (200);
DEFINE vsMensajeError2 				CHAR (200);
DEFINE vsFlagError 					CHAR (1) ;

DEFINE vsADQUIRIENTE  				CHAR (4) ;
DEFINE vsSECUENCIAAUTH 				CHAR (6) ;
DEFINE vsNUMTARJETA  				CHAR (16) ;
DEFINE vsNUMCUENTA  				CHAR (20) ;
DEFINE vsINDICADORREVERSA  			CHAR (19) ;
DEFINE vsDESCRIPCION  				CHAR (15) ;
DEFINE vsCODIGOISO  				CHAR (3) ;
DEFINE vsSECUENCIA  				CHAR (12) ;
DEFINE vsFECHA  					CHAR (8) ;
DEFINE vsHORA  						CHAR (8) ;
DEFINE vsMONTO 						CHAR (11) ;
DEFINE vsNUMCAJERO  				CHAR (14) ;

DEFINE vsEMISOR  					CHAR(4) ;
DEFINE vsCAJERO  					CHAR(10) ;
DEFINE vsNUMEROCUENTA 				CHAR(19);
DEFINE vsCUENTAORIGEN 				CHAR(19);
DEFINE vsCUENTADESTINO 				CHAR(19);

DEFINE vsORDEN  					CHAR (6) ;
DEFINE vsRED  						CHAR (7) ;
DEFINE vsDOLARES  					CHAR (7) ;
DEFINE vsMONTOCASHBACK  			CHAR (13) ;
DEFINE vsREFTRANSACCION 			CHAR (23) ;

DEFINE vsAuxiliar 					CHAR (20) ;
DEFINE visqlerr 					INTEGER ;
DEFINE viContErrores 				INTEGER;

DEFINE vsRESP 						CHAR(6);
DEFINE vsMSURCHARGE 				CHAR(10);
DEFINE vsMLOYALFEE 					CHAR(10);
DEFINE vsBANCOEMISOR 				CHAR(20);
DEFINE vsADQUIRIENTESURCH 			CHAR(1);
DEFINE vsRegistroATMAux 			CHAR(325);
DEFINE vsRegistroATMAux1 			CHAR(270);
DEFINE vsRegistroATMAux2 			CHAR(300);
DEFINE vsRegistroATMAux3			CHAR(600);
DEFINE vsORDEN1 					CHAR(4);
DEFINE vsRED1 						CHAR(4);
DEFINE vsDONATIVO 					CHAR(10);
DEFINE vsEMP 						CHAR(4);
DEFINE vsCOMPANIA 					CHAR(10);
DEFINE vsCOMEMISORA 				CHAR(10);
DEFINE vsMONTOORIGEN 				CHAR(13);
DEFINE vsTARJETA 					CHAR(19);
DEFINE vsCODPAIS 					CHAR(2);
DEFINE vsCODIGOMONEDA 				CHAR(3);

-- Variables para archivo REDTCAT137D
DEFINE	vmcount1					CHAR(11);
DEFINE	vmcount2					CHAR(11);
DEFINE	vmcount3					CHAR(11);
DEFINE	vmcount4					CHAR(11);
DEFINE	vmcount5					CHAR(11);
DEFINE	vmcount6					CHAR(11);
DEFINE	vmtotaloutdolares			CHAR(11);
DEFINE	vmtlfdolares				CHAR(11);
DEFINE	vmdifdolares				CHAR(11);
DEFINE	vmtotaloutmonlocal			CHAR(11);
DEFINE	vmtlfmonedalocal			CHAR(11);
DEFINE	vmdiferenmon				CHAR(11);
DEFINE	vmend1						CHAR(11);
DEFINE	vmend2						CHAR(11);
DEFINE	vmend3						CHAR(11);
DEFINE	vmend4						CHAR(11);
DEFINE	vmend5						CHAR(11);
DEFINE	vmend6						CHAR(11);
DEFINE	vmremanentedolares			CHAR(11);
DEFINE	vmremanentelocal			CHAR(11);
DEFINE	videnomc1					INTEGER;
DEFINE	vicdec1						INTEGER;
DEFINE	videnomc2					INTEGER;
DEFINE	vicdec2						INTEGER;
DEFINE	videnomc3					INTEGER;
DEFINE	vicdec3						INTEGER;
DEFINE	videnomc4					INTEGER;
DEFINE	vicdec4						INTEGER;
DEFINE	videnomc5					INTEGER;
DEFINE	vicdec5						INTEGER;
DEFINE	videnomc6					INTEGER;
DEFINE	vicdec6						INTEGER;
DEFINE	vdfechainicial				CHAR(15);
DEFINE	vdfechafinal				CHAR(15);
DEFINE	vstipocorte					CHAR(5);

/* INICIALIZACION DE VARIABLES */

LET viContador = 0 ;
LET viNumRegistros = 0 ;
LET viNumTransacciones = 0 ;
LET vsRegistroATM = '' ;
LET vsRegistroPOS = '' ;

LET vsMensajeError = '' ;
LET vsMensajeError2 = '' ;
LET vsFlagError = '' ;

LET vsADQUIRIENTE = '' ;
LET vsSECUENCIAAUTH = '' ;
LET vsNUMTARJETA = '' ;
LET vsNUMCUENTA = '' ;
LET vsINDICADORREVERSA = '' ;
LET vsDESCRIPCION = '' ;
LET vsCODIGOISO = '' ;
LET vsSECUENCIA = '' ;
LET vsFECHA = '' ;
LET vsHORA = '' ;
LET vsMONTO = '' ;
LET vsNUMCAJERO = '' ;

LET vsEMISOR = '' ;
LET vsCAJERO = '' ;
LET vsNUMEROCUENTA = '';
LET vsCUENTAORIGEN = '';
LET vsCUENTADESTINO = '';
LET vsORDEN = '' ;
LET vsRED = '' ;
LET vsDOLARES = '' ;
LET vsMONTOCASHBACK  = '' ;
LET vsREFTRANSACCION = '' ;

LET vsRESP = '';
LET vsMSURCHARGE = '';
LET vsMLOYALFEE = '';
LET vsBANCOEMISOR = '';
LET vsADQUIRIENTESURCH = '';
LET vsRegistroATMAux = '';
LET vsRegistroATMAux1 = '';
LET vsRegistroATMAux2 = '';
LET vsRegistroATMAux3 = '';
LET vsORDEN1 = '';
LET vsRED1 = '';
LET vsDONATIVO = '';
LET vsEMP = '';
LET vsCOMPANIA = '';
LET vsCOMEMISORA = '';
LET vsMONTOORIGEN = '';
LET vsTARJETA = '';
LET vsCODPAIS = '';
LET vsCODIGOMONEDA = '';

LET vsAuxiliar = '' ;
LET visqlerr = 0;

LET viContErrores = 0;

LET	vmcount1 = '';
LET	vmcount2 = '';
LET	vmcount3 = '';
LET	vmcount4 = '';
LET	vmcount5 = '';
LET	vmcount6 = '';
LET	vmtotaloutdolares = '';
LET	vmtlfdolares = '';
LET	vmdifdolares = '';
LET	vmtotaloutmonlocal = '';
LET	vmtlfmonedalocal = '';
LET	vmdiferenmon = '';
LET	vmend1 = '';
LET	vmend2 = '';
LET	vmend3 = '';
LET	vmend4 = '';
LET	vmend5 = '';
LET	vmend6 = '';
LET	vmremanentedolares = '';
LET	vmremanentelocal = '';
LET	videnomc1 = 0;
LET	vicdec1	= 0;
LET	videnomc2 = 0;
LET	vicdec2	= 0;
LET	videnomc3 = 0;
LET	vicdec3	= 0;
LET	videnomc4 = 0;
LET	vicdec4 = 0;
LET	videnomc5 = 0;
LET	vicdec5	= 0;
LET	videnomc6 = 0;
LET	vicdec6	 = 0;
LET	vdfechainicial = '';
LET	vdfechafinal = '';
LET	vstipocorte	= '';

BEGIN

ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado        
		
		RETURN visqlerr, vsFlagError, vsMensajeError ;
		
END EXCEPTION;

--SET DEBUG FILE TO '/dbexport/ivan/TraceINTEGRIDAD.sql'; 
--SET DEBUG FILE TO '/home/informix/rrm/TraceINTEGRIDAD.txt'; 
--TRACE ON;

	--INDICA A QUE TABLA CORRESPONDEN LOS REGISTROS 
        IF ( ( psArchivoOrigen = 'TMC' ) OR ( psArchivoOrigen = 'TMD' ) ) THEN --ATM  ( STAT 07 )
			--SET LOCK MODE TO WAIT  ; 
			--SET ISOLATION TO DIRTY READ ;
			--IF ( ( psArchivoOrigen = 'TMC' ) OR ( psArchivoOrigen = 'TMD' ) ) THEN --ATM´S DE EGLOBAL
				SET LOCK MODE TO WAIT 3; 
				SET ISOLATION TO DIRTY READ ;
				DELETE FROM intercard:archivos_conciliacion WHERE 
				(Registro MATCHES '   ' ) OR 
				(Registro = '' ) OR 
				(Registro MATCHES '    *' ) OR 
				(Registro MATCHES '90EGLOBAL*' ) OR
				(Registro MATCHES '*TRANSACCIONES*' );
			--END IF ;
			SET LOCK MODE TO WAIT 3; 
			SET ISOLATION TO DIRTY READ ;
			--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM archivos_conciliacion
			FOREACH SELECT Registro INTO vsRegistroATM FROM intercard:archivos_conciliacion
				LET viContador = viContador + 1 ;
				LET vsRegistroATMAux = vsRegistroATM;
				LET vsRegistroATMAux = REPLACE(vsRegistroATMAux,' ','|');
				--Valida la longitud del registro.
				IF ( ( LENGTH (vsRegistroATMAux) < 240 ) ) THEN
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
				ELSE
					LET vsADQUIRIENTE = TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 ));  --ADQUIRIENTE
					--LET vsSECUENCIAAUTH = TRIM(SUBSTRING (vsRegistroATM FROM 10 FOR 6 )) ;   --SECUENCIAAUTH
					LET vsNUMTARJETA = TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 16 ));  --NUMTARJETA
					LET vsNUMCUENTA = TRIM(SUBSTRING (vsRegistroATM FROM 48 FOR 20 ));  --NUMCUENTA
					LET vsINDICADORREVERSA = TRIM(SUBSTRING (vsRegistroATM FROM 70 FOR 19 ));  --INDICADORREVERSA
					LET vsDESCRIPCION = TRIM(SUBSTRING (vsRegistroATM FROM 91 FOR 15 ));  --DESCRIPCION
					LET vsRESP = TRIM(SUBSTRING (vsRegistroATM FROM 109 FOR 6 ));  --RESP
					LET vsCODIGOISO = TRIM(SUBSTRING (vsRegistroATM FROM 115 FOR 3 ));  --CODIGOISO
					LET vsSECUENCIA = TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 12 ));  --SECUENCIACAJERO
					LET vsNUMCAJERO = TRIM(SUBSTRING (vsRegistroATM FROM 136 FOR 14 )); -- NUMCAJERO
					LET vsFECHA = TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 ));  --FECHA
					LET vsHORA = TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 ));  --HORA
					LET vsORDEN = TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 6 )); --ORDEN
					LET vsRED = TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 7 ));  --RED
					LET vsMONTO = TRIM(SUBSTRING (vsRegistroATM FROM 183 FOR 10 )) ;  --MONTO
					LET vsDOLARES = TRIM(SUBSTRING (vsRegistroATM FROM 193 FOR 7 ));  --DOLARES
					LET vsMSURCHARGE = TRIM(SUBSTRING (vsRegistroATM FROM 200 FOR 10 ));  --MSURCHARGE
					LET vsMLOYALFEE = TRIM(SUBSTRING (vsRegistroATM FROM 210 FOR 10 ));  --MLOYALFEE
					--LET vsBANCOEMISOR = TRIM(SUBSTRING (vsRegistroATM FROM 220 FOR 20 ));  --BANCOEMISOR
					LET vsADQUIRIENTESURCH = TRIM(SUBSTRING (vsRegistroATM FROM 240 FOR 1 ));  --ADQUIRIENTESURCH
				
					--CHECA LA LONGITUD DE LOS DATOS
					IF ( ( LENGTH (TRIM (NVL (vsADQUIRIENTE,''))) < 3 ) ) THEN  --ADQUIRIENTE 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ADQUIRIENTE FORMATO INCORRECTO';
					/*ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIAAUTH,''))) = 0 ) ) THEN --SECUENCIAAUTH
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIAAUTH FORMATO INCORRECTO';*/
					ELIF ( ( LENGTH (TRIM (NVL (vsNUMTARJETA,''))) < 16 ) ) THEN  --NUMTARJETA --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMTARJETA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsNUMCUENTA,''))) = 0 ) ) THEN  --NUMCUENTA --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsDESCRIPCION,''))) = 0 ) ) THEN  --DESCRIPCION
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DESCRIPCION FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCODIGOISO,''))) < 2 ) ) THEN  --CODIGOISO  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CODIGOISO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIA,''))) = 0 ) ) THEN  --SECUENCIA
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsNUMCAJERO,''))) = 0 ) ) THEN  --NUMCUENTA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsFECHA,''))) < 8 ) ) THEN  --FECHA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FECHA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsHORA,''))) < 8 ) ) THEN  --HORA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' HORA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsMONTO,''))) < 10 ) ) THEN  --MONTO  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsMSURCHARGE,''))) < 10 ) ) THEN  --MSURCHARGE  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MSURCHARGE FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsMLOYALFEE,''))) < 10 ) ) THEN  --MLOYALFEE  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE FORMATO INCORRECTO';
					/*ELIF ( ( LENGTH (TRIM (NVL (vsBANCOEMISOR,''))) = 0 ) ) THEN  --BANCOEMISOR 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' BANCOEMISOR FORMATO INCORRECTO';*/
					ELIF ( ( LENGTH (TRIM (NVL (vsADQUIRIENTESURCH,''))) = 0 ) ) THEN  --ADQUIRIENTESURCH  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ADQUIRIENTESURCH FORMATO INCORRECTO';
					END IF;
				
					--CHECA QUE LOS DATOS SEAN NUMERICOS
					IF ( vsFlagError <> 'V' ) THEN
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsNUMTARJETA) INTO vsNUMTARJETA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsNUMCUENTA) INTO vsNUMCUENTA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsCODIGOISO) INTO vsCODIGOISO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsSECUENCIA) INTO vsSECUENCIA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMONTO) INTO vsMONTO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMSURCHARGE) INTO vsMSURCHARGE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMLOYALFEE) INTO vsMLOYALFEE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsADQUIRIENTESURCH) INTO vsADQUIRIENTESURCH;
						
						IF (vsNUMTARJETA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMTARJETA DEBE SER NUMERICO';
						ELIF (vsNUMCUENTA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA DEBE SER NUMERICO';
						ELIF (vsCODIGOISO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CODIGOISO DEBE SER NUMERICO';
						ELIF (vsSECUENCIA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIA DEBE SER NUMERICO';
						ELIF (vsMONTO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO DEBE SER NUMERICO';
						ELIF (vsMSURCHARGE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MSURCHARGE DEBE SER NUMERICO';
						ELIF (vsMLOYALFEE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE DEBE SER NUMERICO';
						ELIF (vsADQUIRIENTESURCH = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ADQUIRIENTESURCH DEBE SER NUMERICO';
						END IF;
					END IF;
					IF (vsFlagError = 'V') THEN 
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						INSERT INTO intercard:Con_ArchErrInt (FechaConciliacion, ArchivoOrigen, Registro, ErrorRegistro) 
							VALUES (CURRENT::DATE, psArchivoOrigen, vsRegistroATM, vsMensajeError);
						
						LET vsMensajeError2 = vsMensajeError;
									
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						DELETE FROM Intercard:Archivos_Conciliacion WHERE Registro = vsRegistroATM;
						LET vsFlagError = 'F';
						LET vsMensajeError = '';
						LET viContErrores = viContErrores + 1;
					END IF;
				END IF;
			END FOREACH;
		
		ELIF ( psArchivoOrigen = 'TMP' ) THEN --ATM´S DE  PROSA
			SET LOCK MODE TO WAIT  ; 
			SET ISOLATION TO DIRTY READ ;
			--BORRA LOS REGISTROS DEL HEADER Y EL TRAILER
			DELETE FROM intercard:archivos_conciliacion WHERE (Registro MATCHES '  Adquirente*') OR 
				(Registro MATCHES '*Transacciones:*') OR (Registro MATCHES '===============*') OR
				(Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES*') OR 
				(Registro MATCHES '*Institucion            Clave:*') OR 
				(Registro MATCHES '*Codigo: STAT0*') OR 
				(Registro MATCHES '    *' ) OR
				(Registro MATCHES '   ' ) OR 
				(Registro = '' );
				--( LENGTH ( TRIM(REGISTRO ) ) < 50 ) ;
				SET LOCK MODE TO WAIT 3;
				SET ISOLATION TO DIRTY READ;
				FOREACH SELECT Registro INTO vsRegistroATM FROM intercard:Archivos_Conciliacion
					--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM Archivos_Conciliacion
					LET viContador = viContador + 1 ;
					LET vsRegistroATMAux2 = vsRegistroATM;
					LET vsRegistroATMAux2 = REPLACE(vsRegistroATMAux2,' ','|');
					--Valida la longitud del registro.
					IF ( ( LENGTH (vsRegistroATMAux2) <> 300 ) ) THEN
						LET vsFlagError = 'V' ;
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELSE
						LET vsADQUIRIENTE = TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 ));  --ADQUIRIENTE
						LET vsTARJETA = TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 19 ));  --TARJETA
						LET vsNUMCUENTA = TRIM(SUBSTRING (vsRegistroATM FROM 48 FOR 19 ));  --NUMCUENTA
						LET vsINDICADORREVERSA = TRIM(SUBSTRING (vsRegistroATM FROM 70 FOR 19 ));  --INDICADORREVERSA
						LET vsDESCRIPCION = TRIM(SUBSTRING (vsRegistroATM FROM 91 FOR 15 ));  --DESCRIPCION
						LET vsRESP = TRIM(SUBSTRING (vsRegistroATM FROM 109 FOR 2 ));  --RESP
						LET vsCODIGOISO = TRIM(SUBSTRING (vsRegistroATM FROM 115 FOR 3 ));  --CODIGOISO
						LET vsSECUENCIA = TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 12 ));  --SECUENCIACAJERO
						LET vsNUMCAJERO = TRIM(SUBSTRING (vsRegistroATM FROM 136 FOR 10 )); -- NUMCAJERO
						LET vsFECHA = TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 ));  --FECHA
						LET vsHORA = TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 ));  --HORA
						LET vsORDEN1 = TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 4 )); --ORDEN1
						LET vsRED1 = TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 4 ));  --RED1
						LET vsMONTO = TRIM(SUBSTRING (vsRegistroATM FROM 181 FOR 10 )) ;  --MONTO
						LET vsDOLARES = TRIM(SUBSTRING (vsRegistroATM FROM 192 FOR 7 ));  --DOLARES
						LET vsSECUENCIAAUTH = TRIM(SUBSTRING (vsRegistroATM FROM 201 FOR 6 )) ;   --SECUENCIAAUTH
						LET vsCODPAIS = TRIM(SUBSTRING (vsRegistroATM FROM 209 FOR 2 )) ;   --CODPAIS
						LET vsMONTOORIGEN = TRIM(SUBSTRING (vsRegistroATM FROM 213 FOR 13 )) ;   --MONTOORIGEN
						LET vsCODIGOMONEDA = TRIM(SUBSTRING (vsRegistroATM FROM 228 FOR 3 )) ;   --CODIGOMONEDA
						LET vsMSURCHARGE = TRIM(SUBSTRING (vsRegistroATM FROM 233 FOR 10 ));  --MSURCHARGE
						LET vsDONATIVO = TRIM(SUBSTRING (vsRegistroATM FROM 245 FOR 10 ));  --DONATIVO
						LET vsEMP = TRIM(SUBSTRING (vsRegistroATM FROM 257 FOR 4 ));  --EMP
						LET vsCOMPANIA = TRIM(SUBSTRING (vsRegistroATM FROM 262 FOR 10 ));  --COMPANIA
						LET vsMLOYALFEE = TRIM(SUBSTRING (vsRegistroATM FROM 273 FOR 10 ));  --MLOYALFEE
						LET vsCOMEMISORA = TRIM(SUBSTRING (vsRegistroATM FROM 284 FOR 10 ));  --COMEMISORA
						
						--CHECA LA LONGITUD DE LOS DATOS
						IF ( ( LENGTH (TRIM (NVL (vsADQUIRIENTE,''))) < 3 ) ) THEN  --ADQUIRIENTE 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ADQUIRIENTE FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsTARJETA,''))) < 16 ) ) THEN  --NUMTARJETA --is numeric
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMTARJETA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsNUMCUENTA,''))) = 0 ) ) THEN  --NUMCUENTA --is numeric
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsDESCRIPCION,''))) = 0 ) ) THEN  --DESCRIPCION
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DESCRIPCION FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsCODIGOISO,''))) < 2 ) ) THEN  --CODIGOISO  --is numeric
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CODIGOISO FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIA,''))) = 0 ) ) THEN  --SECUENCIA
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsNUMCAJERO,''))) = 0 ) ) THEN  --NUMCUENTA 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsFECHA,''))) < 8 ) ) THEN  --FECHA 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FECHA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsHORA,''))) < 8 ) ) THEN  --HORA 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' HORA FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsORDEN1,''))) = 0 ) ) THEN  --ORDEN1 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ORDEN1 FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsRED1,''))) = 0 ) ) THEN  --RED1 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' RED1 FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsMONTO,''))) < 10 ) ) THEN  --MONTO  --is numeric
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsDOLARES,''))) = 0 ) ) THEN  --DOLARES
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DOLARES FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIAAUTH,''))) = 0 ) ) THEN --SECUENCIAAUTH
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIAAUTH FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsMSURCHARGE,''))) < 10 ) ) THEN  --MSURCHARGE  --is numeric
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MSURCHARGE FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsDONATIVO,''))) < 4 ) ) THEN  --DONATIVO 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DONATIVO FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsEMP,''))) = 0 ) ) THEN  --EMP
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' EMP FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsMLOYALFEE,''))) < 10 ) ) THEN  --MLOYALFEE  
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE FORMATO INCORRECTO';
						ELIF ( ( LENGTH (TRIM (NVL (vsCOMEMISORA,''))) < 10 ) ) THEN  --COMEMISORA 
							LET vsFlagError = 'V';
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' COMEMISORA FORMATO INCORRECTO';
						END IF;
					END IF;
				
					--CHECA QUE LOS DATOS SEAN NUMERICOS
					IF ( vsFlagError <> 'V' ) THEN
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsTARJETA) INTO vsTARJETA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsNUMCUENTA) INTO vsNUMCUENTA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMONTO) INTO vsMONTO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsDOLARES) INTO vsDOLARES;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMSURCHARGE) INTO vsMSURCHARGE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsDONATIVO) INTO vsDONATIVO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMLOYALFEE) INTO vsMLOYALFEE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsCOMEMISORA) INTO vsCOMEMISORA;
						
						IF (vsTARJETA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' TARJETA DEBE SER NUMERICO';
						ELIF (vsNUMCUENTA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMCUENTA DEBE SER NUMERICO';
						ELIF (vsMONTO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO DEBE SER NUMERICO';
						ELIF (vsDOLARES = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DOLARES DEBE SER NUMERICO';
						ELIF (vsMSURCHARGE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MSURCHARGE DEBE SER NUMERICO';
						ELIF (vsDONATIVO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DONATIVO DEBE SER NUMERICO';
						ELIF (vsMLOYALFEE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE DEBE SER NUMERICO';
						ELIF (vsCOMEMISORA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' COMEMISORA DEBE SER NUMERICO';
						END IF;
					END IF;
					IF (vsFlagError = 'V') THEN 
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						INSERT INTO intercard:Con_ArchErrInt (FechaConciliacion, ArchivoOrigen, Registro, ErrorRegistro) 
							VALUES (CURRENT::DATE, psArchivoOrigen, vsRegistroATM, vsMensajeError);
							
							LET vsMensajeError2 = vsMensajeError;
						
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						DELETE FROM Intercard:Archivos_Conciliacion WHERE Registro = vsRegistroATM;
						LET vsFlagError = 'F';
						LET vsMensajeError = '';
						LET viContErrores = viContErrores + 1;
					END IF;
				END FOREACH;
					
        ELIF ( ( psArchivoOrigen = 'VNC' ) OR ( psArchivoOrigen = 'VND' ) OR ( psArchivoOrigen = 'VIC' ) OR ( psArchivoOrigen = 'VID' ) OR 
				( psArchivoOrigen = 'PNC' ) OR ( psArchivoOrigen = 'TCC' ) OR ( psArchivoOrigen = 'TCD' ) OR
				( psArchivoOrigen = 'CCP' ) OR ( psArchivoOrigen = 'CCD' ) OR 
				( psArchivoOrigen = 'TPD' ) ) THEN --POS     ( STAT 325 )
			
			SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
            DELETE FROM intercard:Conciliacion_POS_IN where ArchivoOrigen = psArchivoOrigen;
			
			SET LOCK MODE TO WAIT  ;
            SET ISOLATION TO DIRTY READ ;
			--BORRA LOS REGISTROS DEL HEADER Y EL TRAILER
			DELETE FROM intercard:archivos_conciliacion WHERE (Registro MATCHES 'HEADER*') OR (Registro MATCHES 'TRAILER*') ;
						
            SET LOCK MODE TO WAIT  3;
            SET ISOLATION TO DIRTY READ ;
            FOREACH SELECT Registro INTO vsRegistroPOS FROM intercard:Archivos_Conciliacion
					

				LET viContador = viContador + 1 ;
			
				LET vsSECUENCIAAUTH = TRIM(SUBSTRING (vsRegistroPOS FROM 210 FOR 6 ));  --SECUENCIAAUTH
				LET vsNUMTARJETA = TRIM(SUBSTRING (vsRegistroPOS FROM 5 FOR 16 ));  --NUMTARJETA
				LET vsFECHA = TRIM(SUBSTRING (vsRegistroPOS FROM 234 FOR 6 )); --FECHA
				LET vsMONTO = TRIM(SUBSTRING (vsRegistroPOS FROM 39 FOR 11 )) ; --MONTO
				LET vsMONTOCASHBACK  = TRIM(SUBSTRING (vsRegistroPOS FROM 52 FOR 13 )); --MONTOCASHBACK
				LET vsREFTRANSACCION = TRIM(SUBSTRING (vsRegistroPOS FROM 142 FOR 23 )); --REFTRANSACCION
				
				
				IF ( ( LENGTH (vsMONTO) < 10 ) ) THEN  --MONTO  --is numeric
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO FORMATO INCORRECTO' ;
				ELIF ( ( LENGTH (vsMONTOCASHBACK) < 10 ) ) THEN  --MONTOCASHBACK  --is numeric
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTOCASHBACK FORMATO INCORRECTO' ;
				END IF ; 
				
				
				LET vsAuxiliar = vsNUMTARJETA ;
				EXECUTE PROCEDURE intercard:sp_EsNumerico (vsNUMTARJETA) INTO vsNUMTARJETA ;
				EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMONTO) INTO vsMONTO ;
				EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMONTOCASHBACK) INTO vsMONTOCASHBACK ;
				
				
				IF (vsNUMTARJETA = 'F' ) THEN 
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || '--' ||vsAuxiliar ||  ' NUMTARJETA DEBE SER NUMERICO' ;
				ELIF (vsMONTO = 'F' ) THEN 
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO DEBE SER NUMERICO' ;
				ELIF (vsMONTOCASHBACK = 'F' ) THEN 
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTOCASHBACK DEBE SER NUMERICO' ;
				END IF ;
				
				IF (vsFlagError = 'V') THEN 
					SET LOCK MODE TO WAIT 3; 
					SET ISOLATION TO DIRTY READ ;
					INSERT INTO intercard:Con_ArchErrInt (FechaConciliacion, ArchivoOrigen, Registro, ErrorRegistro) 
						VALUES (CURRENT::DATE, psArchivoOrigen, vsRegistroPOS, vsMensajeError);
						
						LET vsMensajeError2 = vsMensajeError;
						
					SET LOCK MODE TO WAIT 3; 
					SET ISOLATION TO DIRTY READ ;
					DELETE FROM Intercard:Archivos_Conciliacion WHERE Registro = vsRegistroPOS;
					LET vsFlagError = 'F';
					LET vsMensajeError = '';
					LET viContErrores = viContErrores + 1;
				END IF;
				
             END FOREACH;

        ELIF ( ( psArchivoOrigen = 'TMO' ) ) THEN --ATM OTROS ( STAT 06 )
			
			SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;
			--BORRA LOS REGISTROS DEL HEADER Y EL TRAILER
			DELETE FROM intercard:archivos_conciliacion WHERE (Registro MATCHES '  Emisor*') OR 
			(Registro MATCHES '*Transacciones:*') OR (Registro MATCHES '===============*') OR
			(Registro MATCHES '*REGISTRO DETALLADO DE TRANSACCIONES POR CAJERO*') OR 
			(Registro MATCHES '*Institucion            Clave:*') OR 
			(Registro MATCHES '*Codigo: STAT06*') OR 
			(Registro MATCHES '    *' ) OR
			(Registro MATCHES '   ' ) OR 
			(Registro = '' );
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT Registro INTO vsRegistroATM FROM intercard:Archivos_Conciliacion
			--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM Archivos_Conciliacion
				LET viContador = viContador + 1 ;
				LET vsRegistroATMAux1 = vsRegistroATM;
				LET vsRegistroATMAux1 = REPLACE(vsRegistroATMAux1,' ','|');
				--Valida la longitud del registro.
				IF ( ( LENGTH (vsRegistroATMAux1) <> 270 ) ) THEN
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
				ELSE
					LET vsEMISOR = TRIM(SUBSTRING (vsRegistroATM FROM 3 FOR 4 ));  --EMISOR
					LET vsCAJERO = TRIM(SUBSTRING (vsRegistroATM FROM 25 FOR 10 ));  --CAJERO
					LET vsNUMEROCUENTA = TRIM(SUBSTRING (vsRegistroATM FROM 37 FOR 19 ));  --NUMEROCUENTA
					LET vsCUENTAORIGEN = TRIM(SUBSTRING (vsRegistroATM FROM 60 FOR 19 ));  --CUENTAORIGEN
					LET vsCUENTADESTINO = TRIM(SUBSTRING (vsRegistroATM FROM 82 FOR 19 ));  --CUENTADESTINO
					LET vsDESCRIPCION = TRIM(SUBSTRING (vsRegistroATM FROM 103 FOR 15 ));  --DESCRIPCION
					LET vsRESP = TRIM(SUBSTRING (vsRegistroATM FROM 121 FOR 2 ));  --RESP
					LET vsCODIGOISO = TRIM(SUBSTRING (vsRegistroATM FROM 127 FOR 3 ));  --CODIGOISO
					LET vsSECUENCIA = TRIM(SUBSTRING (vsRegistroATM FROM 133 FOR 12 ));  --SECUENCIA
					LET vsFECHA = TRIM(SUBSTRING (vsRegistroATM FROM 150 FOR 8 ));  --FECHA
					LET vsHORA = TRIM(SUBSTRING (vsRegistroATM FROM 159 FOR 8 ));  --HORA
					LET vsORDEN1 = TRIM(SUBSTRING (vsRegistroATM FROM 170 FOR 4 ));  --ORDEN1
					LET vsRED1 = TRIM(SUBSTRING (vsRegistroATM FROM 176 FOR 4 ));  --RED1
					LET vsMONTO = TRIM(SUBSTRING (vsRegistroATM FROM 181 FOR 10 ));  --MONTO
					LET vsDOLARES = TRIM(SUBSTRING (vsRegistroATM FROM 192 FOR 7 ));  --DOLARES
					LET vsMSURCHARGE = TRIM(SUBSTRING (vsRegistroATM FROM 200 FOR 10 ));  --MSURCHARGE
					LET vsDONATIVO = TRIM(SUBSTRING (vsRegistroATM FROM 211 FOR 10 ));  --DONATIVO
					LET vsEMP = TRIM(SUBSTRING (vsRegistroATM FROM 222 FOR 4 ));  --EMP
					LET vsSECUENCIAAUTH = TRIM(SUBSTRING (vsRegistroATM FROM 227 FOR 6 ));  --SECUENCIAAUTH
					LET vsCOMPANIA = TRIM(SUBSTRING (vsRegistroATM FROM 234 FOR 10 ));  --COMPANIA
					LET vsMLOYALFEE = TRIM(SUBSTRING (vsRegistroATM FROM 245 FOR 10 ));  --MLOYALFEE
					LET vsCOMEMISORA = TRIM(SUBSTRING (vsRegistroATM FROM 256 FOR 10 ));  --COMEMISORA
					
					--CHECA LA LONGITUD DE LOS DATOS
					IF ( ( LENGTH (TRIM (NVL (vsEMISOR,''))) < 3 ) ) THEN  --EMISOR 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' EMISOR FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCAJERO,''))) = 0 ) ) THEN --CAJERO
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CAJERO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsNUMEROCUENTA,''))) < 16 ) ) THEN  --NUMEROCUENTA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMTARJETA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCUENTAORIGEN,''))) = 0 ) ) THEN  --CUENTAORIGEN --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CUENTAORIGEN FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsDESCRIPCION,''))) = 0 ) ) THEN  --DESCRIPCION
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DESCRIPCION FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsRESP,''))) < 1 ) ) THEN  --RESP
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' RESP FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCODIGOISO,''))) < 2 ) ) THEN  --CODIGOISO  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CODIGOISO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIA,''))) = 0 ) ) THEN  --SECUENCIA
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsFECHA,''))) < 8 ) ) THEN  --FECHA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FECHA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsHORA,''))) < 8 ) ) THEN  --HORA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' HORA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsORDEN1,''))) = 0 ) ) THEN  --ORDEN1 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' ORDEN1 FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsRED1,''))) = 0 ) ) THEN  --RED1 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' RED1 FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsDOLARES,''))) = 0 ) ) THEN  --DOLARES
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DOLARES FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsMSURCHARGE,''))) < 4 ) ) THEN  --MSURCHARGE  --is numeric
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsDONATIVO,''))) < 4 ) ) THEN  --DONATIVO 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DONATIVO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsEMP,''))) = 0 ) ) THEN  --EMP
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' EMP FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsSECUENCIAAUTH,''))) = 0 ) ) THEN --SECUENCIAAUTH
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' SECUENCIAAUTH FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsMLOYALFEE,''))) < 10 ) ) THEN  --MLOYALFEE  
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCOMEMISORA,''))) < 10 ) ) THEN  --COMEMISORA 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' COMEMISORA FORMATO INCORRECTO';
					END IF;
					
					--CHECA QUE LOS DATOS SEAN NUMERICOS
					IF ( vsFlagError <> 'V' ) THEN
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsNUMEROCUENTA) INTO vsNUMEROCUENTA;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsCUENTAORIGEN) INTO vsCUENTAORIGEN;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMONTO) INTO vsMONTO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsDOLARES) INTO vsDOLARES;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMSURCHARGE) INTO vsMSURCHARGE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsDONATIVO) INTO vsDONATIVO;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsMLOYALFEE) INTO vsMLOYALFEE;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vsCOMEMISORA) INTO vsCOMEMISORA;
						
						IF (vsNUMEROCUENTA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' NUMEROCUENTA DEBE SER NUMERICO';
						ELIF (vsCUENTAORIGEN = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CUENTAORIGEN DEBE SER NUMERICO';
						ELIF (vsMONTO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MONTO DEBE SER NUMERICO';
						ELIF (vsDOLARES = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DOLARES DEBE SER NUMERICO';
						ELIF (vsMSURCHARGE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MSURCHARGE DEBE SER NUMERICO';
						ELIF (vsDONATIVO = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DONATIVO DEBE SER NUMERICO';
						ELIF (vsMLOYALFEE = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' MLOYALFEE DEBE SER NUMERICO';
						ELIF (vsCOMEMISORA = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' COMEMISORA DEBE SER NUMERICO';
						END IF;
					END IF;
					IF (vsFlagError = 'V') THEN 
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						INSERT INTO intercard:Con_ArchErrInt (FechaConciliacion, ArchivoOrigen, Registro, ErrorRegistro) 
							VALUES (CURRENT::DATE, psArchivoOrigen, vsRegistroATM, vsMensajeError);
							
							LET vsMensajeError2 = vsMensajeError;
							
						
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						--DELETE FROM Intercard:Archivos_Conciliacion WHERE TRIM(Registro) = vsRegistroATM;
						DELETE FROM Intercard:Archivos_Conciliacion WHERE Registro = vsRegistroATM;
						LET vsFlagError = 'F';
						LET vsMensajeError = '';
						LET viContErrores = viContErrores + 1;
					END IF;
				END IF;
			END FOREACH;
		-- ##############################################################
		ELIF ( ( psArchivoOrigen = 'TMS' ) ) THEN --switch ATM (Conciliacion_redtcat137d)
--			SET DEBUG FILE TO '/home/informix/rrm/TraceINTEGRIDAD.txt'; 
--			TRACE ON;
			SET LOCK MODE TO WAIT 3;
            SET ISOLATION TO DIRTY READ ;
			DELETE FROM intercard:archivos_conciliacion --BORRA LOS REGISTROS DEL HEADER
			WHERE 
				(Registro MATCHES ' FIID|*'); 
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ;
			FOREACH SELECT Registro INTO vsRegistroATM FROM intercard:Archivos_Conciliacion
			--FOREACH SELECT TRIM(Registro) INTO vsRegistroATM FROM Archivos_Conciliacion
				LET viContador = viContador + 1 ;
				LET vsRegistroATMAux3 = vsRegistroATM;
				LET vsRegistroATMAux3 = REPLACE(vsRegistroATMAux3,' ','|');
				--Valida la longitud del registro.
				IF ( ( LENGTH (vsRegistroATMAux3) <> 600 ) ) THEN
					LET vsFlagError = 'V' ;
					LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
				ELSE
					LET vsEMISOR = TRIM(SUBSTRING (vsRegistroATM FROM 2 FOR 4 ));  			--EMISOR
					LET vsCAJERO = TRIM(SUBSTRING (vsRegistroATM FROM 14 FOR 6 ));  		--CAJERO
					LET	vmcount1 = TRIM(SUBSTRING (vsRegistroATM FROM 30 FOR 11 ));
					LET	vmcount2 = TRIM(SUBSTRING (vsRegistroATM FROM 51 FOR 11 ));
					LET	vmcount3 = TRIM(SUBSTRING (vsRegistroATM FROM 72 FOR 11 ));
					LET	vmcount4 = TRIM(SUBSTRING (vsRegistroATM FROM 93 FOR 11 ));
					LET	vmcount5 = TRIM(SUBSTRING (vsRegistroATM FROM 114 FOR 11 ));
					LET	vmcount6 = TRIM(SUBSTRING (vsRegistroATM FROM 135 FOR 11 ));
					LET	vmtotaloutdolares = TRIM(SUBSTRING (vsRegistroATM FROM 156 FOR 11 ));
					LET	vmtlfdolares = TRIM(SUBSTRING (vsRegistroATM FROM 177 FOR 11 ));
					LET	vmdifdolares = TRIM(SUBSTRING (vsRegistroATM FROM 198 FOR 11 ));
					LET	vmtotaloutmonlocal = TRIM(SUBSTRING (vsRegistroATM FROM 219 FOR 11 ));
					LET	vmtlfmonedalocal = TRIM(SUBSTRING (vsRegistroATM FROM 240 FOR 11 ));
					LET	vmdiferenmon = TRIM(SUBSTRING (vsRegistroATM FROM 261 FOR 11 ));
					LET	vmend1 = TRIM(SUBSTRING (vsRegistroATM FROM 282 FOR 11 ));
					LET	vmend2 = TRIM(SUBSTRING (vsRegistroATM FROM 303 FOR 11 ));
					LET	vmend3 = TRIM(SUBSTRING (vsRegistroATM FROM 324 FOR 11 ));
					LET	vmend4 = TRIM(SUBSTRING (vsRegistroATM FROM 345 FOR 11 ));
					LET	vmend5 = TRIM(SUBSTRING (vsRegistroATM FROM 366 FOR 11 ));
					LET	vmend6 = TRIM(SUBSTRING (vsRegistroATM FROM 387 FOR 11 ));
					LET	vmremanentedolares = TRIM(SUBSTRING (vsRegistroATM FROM 408 FOR 11 ));
					LET	vmremanentelocal = TRIM(SUBSTRING (vsRegistroATM FROM 429 FOR 11 ));
					LET	videnomc1 = TRIM(SUBSTRING (vsRegistroATM FROM 446 FOR 5 ));
					LET	vicdec1	= TRIM(SUBSTRING (vsRegistroATM FROM 454 FOR 5 ));
					LET	videnomc2 = TRIM(SUBSTRING (vsRegistroATM FROM 465 FOR 5 ));
					LET	vicdec2	= TRIM(SUBSTRING (vsRegistroATM FROM 473 FOR 5 ));
					LET	videnomc3 = TRIM(SUBSTRING (vsRegistroATM FROM 484 FOR 5 ));
					LET	vicdec3	= TRIM(SUBSTRING (vsRegistroATM FROM 492 FOR 5 ));
					LET	videnomc4 = TRIM(SUBSTRING (vsRegistroATM FROM 503 FOR 5 ));
					LET	vicdec4 = TRIM(SUBSTRING (vsRegistroATM FROM 511 FOR 5 ));
					LET	videnomc5 = TRIM(SUBSTRING (vsRegistroATM FROM 522 FOR 5 ));
					LET	vicdec5	= TRIM(SUBSTRING (vsRegistroATM FROM 530 FOR 5 ));
					LET	videnomc6 = TRIM(SUBSTRING (vsRegistroATM FROM 541 FOR 5 ));
					LET	vicdec6	 = TRIM(SUBSTRING (vsRegistroATM FROM 549 FOR 5 ));
					LET	vdfechainicial = TRIM(SUBSTRING (vsRegistroATM FROM 556 FOR 15 ));
					LET	vdfechafinal = TRIM(SUBSTRING (vsRegistroATM FROM 573 FOR 15 ));
					LET	vstipocorte	= TRIM(SUBSTRING (vsRegistroATM FROM 594 FOR 5 ));
					--CHECA LA LONGITUD DE LOS DATOS 
					IF ( ( LENGTH (TRIM (NVL (vsEMISOR,''))) < 3 ) ) THEN  --EMISOR 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' EMISOR FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vsCAJERO,''))) = 0 ) ) THEN --CAJERO
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CAJERO FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount1,''))) = 0 ) ) THEN  --COUNT 1
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount2,''))) = 0 ) ) THEN  --COUNT 2
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount3,''))) = 0 ) ) THEN  --COUNT 3
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount4,''))) = 0 ) ) THEN  --COUNT 4
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount5,''))) = 0 ) ) THEN  --COUNT 5
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmcount6,''))) = 0 ) ) THEN  --COUNT 6
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmtotaloutdolares,''))) = 0 ) ) THEN  --TOTAL SALIDA EN DOLARES
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmtlfdolares,''))) = 0 ) ) THEN  -- TLF DOLARES
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmdifdolares,''))) = 0 ) ) THEN  -- DIFERENCIA DOLARES
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmtotaloutmonlocal,''))) = 0 ) ) THEN  -- TOTAL DE SALIDA EN MONEDA NACIONAL
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmtlfmonedalocal,''))) = 0 ) ) THEN  --TLF MONEDA NACIONAL
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmdiferenmon,''))) = 0 ) ) THEN  -- DIFERENCIA EN MONEDA LOCAL
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend1,''))) = 0 ) ) THEN  --FINAL 1
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend2,''))) = 0 ) ) THEN  --FINAL 2
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend3,''))) = 0 ) ) THEN  --FINAL 3
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend4,''))) = 0 ) ) THEN  --FINAL 4
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend5,''))) = 0 ) ) THEN  --FINAL 5
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vmend6,''))) = 0 ) ) THEN  --FINAL 6
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc1,''))) = 0 ) ) THEN  --DENOMINACION 1 50
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec1,''))) = 0 ) ) THEN  -- CANTIDAD DENOMINACION 1
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc2,''))) = 0 ) ) THEN  --DENOMINACION 2 100
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec2,''))) = 0 ) ) THEN  --CANTIDAD DENOMINACION 2
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc3,''))) = 0 ) ) THEN  --DENOMINACION 3 200
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec3,''))) = 0 ) ) THEN  --CANTIDAD DENOMINACION 3
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc4,''))) = 0 ) ) THEN  --DENOMINACION 4 500
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec4,''))) = 0 ) ) THEN  -- CANTIDAD DENOMINACION 4
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc5,''))) = 0 ) ) THEN  --DENOMINACION 5 0
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec5,''))) = 0 ) ) THEN  --CANTIDAD DENOMINACION 5
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (videnomc6,''))) = 0 ) ) THEN  --DENOMINACION 6 0
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vicdec6,''))) = 0 ) ) THEN  --CANTIDAD DENOMINACION 6
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vdfechainicial,''))) < 15 ) ) THEN  --FECHA INICIAL
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FECHA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vdfechafinal,''))) < 15 ) ) THEN  --FECHA FINAL
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FECHA FORMATO INCORRECTO';
					ELIF ( ( LENGTH (TRIM (NVL (vstipocorte,''))) < 2 ) ) THEN  --TIPO DE CORTE 
						LET vsFlagError = 'V';
						LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' FORMATO DE TIPO DE CORTE INCORRECTO';
					END IF;
					--CHECA QUE LOS DATOS SEAN NUMERICOS
					IF ( vsFlagError <> 'V' ) THEN
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount1) INTO vmcount1;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount2) INTO vmcount2;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount3) INTO vmcount3;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount4) INTO vmcount4;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount5) INTO vmcount5;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmcount6) INTO vmcount6;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmtotaloutdolares) INTO vmtotaloutdolares; 
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmtlfdolares) INTO vmtlfdolares;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmdifdolares) INTO vmdifdolares;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmtotaloutmonlocal) INTO vmtotaloutmonlocal;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmtlfmonedalocal) INTO vmtlfmonedalocal;
						EXECUTE PROCEDURE intercard:sp_EsNumericoNeg (vmdiferenmon) INTO vmdiferenmon;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend1) INTO vmend1;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend2) INTO vmend2;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend3) INTO vmend3;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend4) INTO vmend4;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend5) INTO vmend5;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmend6) INTO vmend6;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmremanentedolares) INTO vmremanentedolares;
						EXECUTE PROCEDURE intercard:sp_EsNumerico (vmremanentelocal) INTO vmremanentelocal;

						IF (vmcount1 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 1  DEBE SER NUMERICO';
						ELIF (vmcount2 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 2 DEBE SER NUMERICO';
						ELIF (vmcount3 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 3 DEBE SER NUMERICO';
						ELIF (vmcount4 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 4 DEBE SER NUMERICO';
						ELIF (vmcount5 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 5 DEBE SER NUMERICO';
						ELIF (vmcount6 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' CANTIDAD 6 DEBE SER NUMERICO';
						ELIF (vmtotaloutdolares = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' TOTAL OUT DOLARES DEBE SER NUMERICO';
						ELIF (vmtlfdolares = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' TLF DOLARES DEBE SER NUMERICO';
						ELIF (vmdifdolares = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DIFERENCIA DOLARES DEBE SER NUMERICO';
						ELIF (vmtotaloutmonlocal = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' TOTAL OUT MONEDA LOCAL DEBE SER NUMERICO';
						ELIF (vmtlfmonedalocal = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' TLF MONEDA LOCAL DEBE SER NUMERICO';
						ELIF (vmdiferenmon = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' DIFERENCIA MONEDA NACIONAL DEBE SER NUMERICO MENOR A 0';
						ELIF (vmend1 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmend2 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmend3 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmend4 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmend5 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmend6 = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' VALOR DEBE SER NUMERICO';
						ELIF (vmremanentedolares = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' REMANENTE EN DOLARES DEBE SER NUMERICO';
						ELIF (vmremanentelocal = 'F' ) THEN 
							LET vsFlagError = 'V' ;
							LET vsMensajeError = 'REGISTRO NUM: ' || viContador || ' REMANENTE MONEDA LOCAL  DEBE SER NUMERICO';

							END IF;
					END IF;
					IF (vsFlagError = 'V') THEN 
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						INSERT INTO intercard:Con_ArchErrInt (FechaConciliacion, ArchivoOrigen, Registro, ErrorRegistro) 
							VALUES (CURRENT::DATE, psArchivoOrigen, vsRegistroATM, vsMensajeError);
							
							LET vsMensajeError2 = vsMensajeError;
							
						
						SET LOCK MODE TO WAIT 3; 
						SET ISOLATION TO DIRTY READ ;
						--DELETE FROM Intercard:Archivos_Conciliacion WHERE TRIM(Registro) = vsRegistroATM;
						DELETE FROM Intercard:Archivos_Conciliacion WHERE Registro = vsRegistroATM;
						LET vsFlagError = 'F';
						LET vsMensajeError = '';
						LET viContErrores = viContErrores + 1;
					END IF;
				END IF;
			END FOREACH;
		ELSE -- NINGUNO DE LOS CASOS            
			LET visqlerr = 3 ;
		END IF ;
		
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		--VALIDA SI EXISTEN REGISTROS CON ERROR PARA EL ARCHIVO ACTUAL.
		IF EXISTS ( SELECT Registro FROM Intercard:Con_ArchErrInt WHERE FechaConciliacion = CURRENT::DATE AND ArchivoOrigen = psArchivoOrigen) THEN
			--LET visqlerr = 101; --ERROR DE INTEGRIDAD 
			LET vsFlagError = 'W';
			LET vsMensajeError = 'EL ARCHIVO '|| psArchivoOrigen || ' CONTIENE ' || viContErrores || ' REGISTROS CON ERRORES DE INTEGRIDAD DE ' || viContador || ' REGISTROS CONTENIDOS EN EL ARCHIVO. (' || TRIM(vsMensajeError2) || ')';
		ELSE --OK
			LET vsFlagError = 'F';
			LET vsMensajeError = '';
		END IF;
		
	RETURN visqlerr, vsFlagError, vsMensajeError ;
	
END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Valida le integridad de los datos del archivo a conciliar.',
'Fecha: 2008/08/20',
'Version: 20080820.1025',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se guardan los registros con error de integridad en una tabla para ser reportados al emisor de los archivos.',
'Fecha: 2010/01/20',
'Version: 20100120.1125',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de corresponsales de pagos(CCP), depositos(CCD) se manejan como archivos de POS.',
'Fecha: 2010/04/22',
'Version: 20100422.1213',
'BD: Intercard',
'',
'Modificado: Alfonso Antonio Cruz Alvarez',
'Proyecto: Conciliacion Automatica - Transferencia de prestamos',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple los nuevos archivos archivos de transferencia de prestamos(TPD) se manejan como archivos de POS.',
'Fecha: 2011/05/25',
'Version: 20110525.1040',
'BD: Intercard'
'',
'Modificado: Resendiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica - Integracion de validacion de archivo REDTCAT137DYYMMDDEDCC.DAT',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se modifico el flujo para que contemple el nuevo archivo REDTCAT137DYYMMDDEDCC.DAT del Switch (TMS) se manejan como archivos de TMO. y la Variable vsRegistroATM se modifico a 601 caracteres',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard'
*/;

CREATE PROCEDURE "informix".sp_loadarchivo_conciliacionauto ( psRuta_Repositorio VARCHAR (90), psNomArchivo VARCHAR (30), psRuta_Procesos VARCHAR (90) )

RETURNING INTEGER AS Retorno ;

--****************************************************************************************************
-- DESCRIPCION:  CARGA LOS REGISTROS DEL ARCHIVO A LA TABLA Archivos_Conciliacion PARA SER PROCESADO
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 20/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 14/12/2009 Casanova Edeza Hector Juan.  
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsSQL VARCHAR (200) ;
DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vsSQL = '' ;
LET visqlerr = 0;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado        
				
		RETURN visqlerr ;
		
    END EXCEPTION;
			--SET DEBUG FILE TO '/home/informix/rrm/TraceLOAD.txt'; 
			--TRACE ON;
	IF psNomArchivo LIKE 'REDTCAT%' THEN 
		DELETE FROM intercard:Archivos_Conciliacion;
		--CREA ARCHIIVO DE INSTRUCCION DE CARGA
			LET vsSQL = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || "'" ||" DELIMITER "  ||"','"|| ' INSERT INTO archivos_conciliacion" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsSQL = 'dbaccess intercard ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
		
		RETURN visqlerr;
	ELSE
		DELETE FROM intercard:Archivos_Conciliacion;
		--CREA ARCHIVO DE INSTRUCCION DE CARGA
			LET vsSQL = 'echo "LOAD FROM '''|| TRIM(psRuta_Repositorio) || '/' || TRIM(psNomArchivo) || "'" || ' INSERT INTO archivos_conciliacion" > ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		--CARGA EL ARCHIVO ORIGINAL A LA TABLA TEMPORAL
			LET vsSQL = 'dbaccess intercard ' || TRIM(psRuta_Procesos) ||  '/load_archivo.sql';
			SYSTEM vsSQL;
	
		RETURN visqlerr;
	END IF;

END

END PROCEDURE
/*DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: Carga un archivo de conciliacion a la tabla de trabajo (Archivos_Conciliacion) para ser procesado.',
'Fecha: 2008/08/20',
'Version: 20080820.0933',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se limpia la tabla de trabajo (Archivos_Conciliacion) antes de cargar un nuevo archivo.',
'Fecha: 2010/01/20',
'Version: 20100120.1225',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1308',
'BD: Intercard'
'Modificado: Resendiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 30 caracteres y se agrega ciclo para que los archivos REDTCAT137DYYMMDDEDCC.DAT los cargue ignorando el delimitador "|" ',
'Fecha: 2011/10/13',
'Version: 20111013.1400',
'BD: Intercard';*/;

CREATE PROCEDURE "informix".sp_obtregmonitorconciliacionaut
(
psArchivoOrigen CHAR(3),
pdFechaInicial DateTime  YEAR TO fraction(5), 
pdFechaFinal DateTime  YEAR TO fraction(5)
)

RETURNING INTEGER AS X, CHAR(3) AS Archivo, DATE AS Fecha_Conciliacion, CHAR(8) AS Usuario, CHAR(30) AS Nombre_Archivo, CHAR(1) AS Transferir_Archivo_Win_Aix, DATETIME YEAR TO FRACTION(5) AS Trans_Hora,
		  CHAR(1) AS Obtener_Archivo, DATETIME YEAR TO FRACTION(5) AS ObtArch_Hora, CHAR(1) AS Integro, DATETIME YEAR TO FRACTION(5)AS Integridad_Hora, CHAR(1) AS Cargar_Tabla,
          DATETIME YEAR TO FRACTION(5) AS Cargar_Tabla_Hora, INTEGER AS Numero_Registros, CHAR(1) AS Conciliacion, DATETIME YEAR TO FRACTION(5) AS Conc_Hora,
		  INTEGER AS Numero_Registros_Conciliados, CHAR(11) AS Exportar_Registros_Central, DATETIME YEAR TO FRACTION(5) AS ExpRegCentral_Hora,
		  INTEGER AS Numero_Registros_Exportados, CHAR(1) AS Configurar_Central, DATETIME YEAR TO FRACTION(5) AS ConfigCentral_Hora, CHAR(1) AS Aplicar_Saldos, DATETIME YEAR TO FRACTION(5)AS AplicarSaldos_Hora, DATE AS Fecha_Termino;
		  
		  
--****************************************************************************************************
-- DESCRIPCION: Obtiene informacion de la tabla monitor_conciliacionaut
-- AUTOR : Rochin Rocha Edgar Ivan
-- FECHA : 10/09/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Automatica
--MODIFICADO: ROCHIN ROCHA EDGAR IVAN 18/09/2008
--***************************************************************************************************

		  
DEFINE cCodRet CHAR(3);
DEFINE viLlave INTEGER ;
DEFINE vsArchivoO CHAR(3);
DEFINE vdFechaCon DateTime  YEAR TO fraction(5);
DEFINE vsUsuario CHAR(8) ;
DEFINE vsNomArch CHAR(30) ;
DEFINE vsTransferirArchWin_Aix CHAR(1) ;
DEFINE vdTransferirArchWin_AixHora Datetime year to fraction (5); 
DEFINE vsObtArchivo CHAR(1);
DEFINE vdObtenerArchivoHora DateTime YEAR TO fraction(5);
DEFINE vsIntegro CHAR(1) ;
DEFINE vdIntegridadHora DateTime YEAR TO fraction(5);
DEFINE vsCargarT CHAR(1) ;
DEFINE vdCargarTablaHora DateTime YEAR TO fraction(5);
DEFINE viNumReg INTEGER ;
DEFINE vsConci CHAR(1);
DEFINE vdConciliacionHora DateTime YEAR TO fraction(5);
DEFINE viNumRegCon INTEGER ;
DEFINE vsExpRegCent CHAR(11) ;
DEFINE vdExportarCentralHora DateTime YEAR TO fraction(5);
DEFINE viNumRegExp INTEGER ;
DEFINE vsConfigCen CHAR(1) ;
DEFINE vdConfigurarCentralHora DateTime YEAR TO Fraction(5);
DEFINE vsAplicarSal CHAR(1) ;
DEFINE vdAplicarSaldosHora DateTime YEAR TO Fraction(5);
DEFINE vdFecTermino DateTime  YEAR TO fraction(5);

DEFINE visqlerr INTEGER ;

Let viLlave  = 0;
Let vsArchivoO = "";
Let vdFechaCon = CURRENT ;
Let vsUsuario = '';
Let vsNomArch = '';
LET vsTransferirArchWin_Aix = '' ;
LET vdTransferirArchWin_AixHora = CURRENT ;
Let vsObtArchivo = '';
LET vdObtenerArchivoHora = CURRENT ;
Let vsIntegro = "" ;
LET vdIntegridadHora = CURRENT ;
Let vsCargarT = "" ;
LET vdCargarTablaHora = CURRENT ;
Let viNumReg = 0 ;
Let vsConci = "" ;
LET vdConciliacionHora = CURRENT ;
Let viNumRegCon = 0 ;
Let vsExpRegCent = "" ;
LET vdExportarCentralHora = CURRENT ;
Let viNumRegExp = 0 ;
Let vsConfigCen = "" ;
LET vdConfigurarCentralHora = CURRENT ;
Let vsAplicarSal = "" ;
LET vdAplicarSaldosHora = CURRENT ;
Let vdFecTermino = CURRENT ;
LET cCodRet = "000";

LET visqlerr = 0 ;
--set debug file to "/tmp/sp_ObtRegMonitorConciliacion.out";
--Trace on;
BEGIN


ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN             

            RETURN visqlerr, vsArchivoO, vdFechaCon, vsUsuario, TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora, vsIntegro, vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora, viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;

        END IF ; 
    END EXCEPTION ;

 



IF(pdFechaInicial = "") OR (pdFechaInicial is NULL) THEN
    LET visqlerr = 1 ;
    RETURN  visqlerr, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;
END IF ;

IF (pdFechaFinal = "") OR (pdFechaFinal IS NULL) THEN
    LET visqlerr = 2;
    RETURN  visqlerr, vsArchivoO, vdFechaCon, vsUsuario,  TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino;
END IF ;


IF (psArchivoOrigen = '')  THEN
        
        SET ISOLATION TO DIRTY READ ;
        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Nom_Archivo, TransferirArchWin_Aix, TransferirArchWin_AixHora, Obtener_Archivo, ObtenerArchivoHora, Integridad, IntegridadHora,
			Cargar_Tabla, CargarTablaHora, Num_Registros, Conciliacion, ConciliacionHora, Num_Registros_Conciliados, Exportar_Registros_A_Central, ExportarCentralHora,
			Num_Registros_Exportados, Configurar_Central, ConfigurarCentralHora, Aplicar_Saldos, AplicarSaldosHora,  Fecha_Termino
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora,  vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino
            FROM monitor_conciliacionaut WHERE FechaConciliacion >=  pdFechaInicial  AND Fecha_Termino <= pdFechaFinal ORDER BY KeyX
			
		            
               RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario, TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg, vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora, viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora, vsAplicarSal, vdAplicarSaldosHora, vdFecTermino  WITH RESUME ;

        END ForEach
ELSE
        
        ForEach
            SELECT
            Keyx, ArchivoOrigen, FechaConciliacion, Usuario, Nom_Archivo, TransferirArchWin_Aix, TransferirArchWin_AixHora, Obtener_Archivo, ObtenerArchivoHora, Integridad, IntegridadHora,
			Cargar_Tabla, CargarTablaHora, Num_Registros, Conciliacion, ConciliacionHora, Num_Registros_Conciliados, Exportar_Registros_A_Central, ExportarCentralHora,
			Num_Registros_Exportados, Configurar_Central, ConfigurarCentralHora, Aplicar_Saldos, AplicarSaldosHora,  Fecha_Termino 
            INTO
            viLlave, vsArchivoO, vdFechaCon, vsUsuario,  vsNomArch, vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino  
            FROM monitor_conciliacionaut WHERE ArchivoOrigen = psArchivoOrigen AND FechaConciliacion >=  pdFechaInicial  AND Fecha_Termino <= pdFechaFinal ORDER BY keyx
            
                RETURN   viLlave, vsArchivoO, vdFechaCon, vsUsuario,  TRIM(vsNomArch), vsTransferirArchWin_Aix, vdTransferirArchWin_AixHora, vsObtArchivo, vdObtenerArchivoHora,  vsIntegro,  vdIntegridadHora,
            vsCargarT, vdCargarTablaHora, viNumReg,  vsConci, vdConciliacionHora,  viNumRegCon, vsExpRegCent, vdExportarCentralHora,  viNumRegExp,
			vsConfigCen, vdConfigurarCentralHora,  vsAplicarSal, vdAplicarSaldosHora,  vdFecTermino  WITH RESUME ;          

        END ForEach

END IF ;

END
END PROCEDURE
/*DOCUMENT
'AUTOR: Rochin Rocha Edgar Ivan',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: OBTIENE INFORMACION DE LA TABLA MONITOR_CONCILIACIONAUT.',
'Fecha: 2008/09/10',
'Version: 20080910.1025',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable correspondiente al nombre del archivo.',
'Fecha: 2010/04/13',
'Version: 20100413.0913',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 23 caracteres.',
'Fecha: 2010/04/14',
'Version: 20100414.1316',
'BD: Intercard'
''
'Modificado: Resendiz Martinez Ricardo',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable de NombreArchivo a 30 caracteres.',
'Fecha: 2010/10/13',
'Version: 20111013.1400',
'BD: Intercard'*/
;

CREATE PROCEDURE "informix".sp_esnumericoneg( psCadena CHAR (20))

RETURNING CHAR (1) AS Munerico ;

--****************************************************************************************************
-- DESCRIPCION:  VERIFICA QUE LA CADENA DE ENTRADA SOLAMENTE CONTENGA NUMEROS NEGATIVOS
-- CLONACION : Reséndiz Martinez Ricardo  
-- FECHA : 13/10/2011
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico 
--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsRespuesta CHAR (1) ;

DEFINE visqlerr INTEGER ;
/* INICIALIZACION DE VARIABLES */

LET vsRespuesta = 'F' ;

LET visqlerr = 0;

BEGIN

  ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
  
        IF visqlerr = -1213 THEN             
			LET vsRespuesta = 'F' ;	
		ELSE
			LET vsRespuesta = ' ' ;	
        END IF; 
		
		RETURN vsRespuesta ;
		
    END EXCEPTION;
	
	IF (psCadena <= 0) THEN 
		LET vsRespuesta = 'V';
	ELSE
		LET vsRespuesta = 'F';
	END IF  ;
	
	RETURN vsRespuesta ;
	
END

END PROCEDURE
;