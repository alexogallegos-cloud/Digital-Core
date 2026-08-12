CREATE PROCEDURE "informix".sp_monitor_alerta_aclaraciones()
RETURNING
	CHAR(5) AS codret, CHAR(100) AS descrip;

	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;

	DEFINE cMensaje CHAR(100);
	DEFINE cRutaArch CHAR(25);
	DEFINE vsSQL  CHAR(1600);
	DEFINE vsSQL1 CHAR(500);
	DEFINE vsSQL2 CHAR(500);
	DEFINE vsSQL3 CHAR(500);
	DEFINE vsArchTemp CHAR(50);
	DEFINE nContador INTEGER;
	DEFINE vFechaAclaracion CHAR(10);

	DEFINE cHora				CHAR(8);
	DEFINE cFechaArchivoOUT		CHAR(29);
	DEFINE iPaso				SMALLINT;

	LET cHora				= TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H:%M:%S');
	LET cFechaArchivoOUT	= YEAR(CURRENT::DATE)||LPAD(MONTH(CURRENT::DATE),2,'0')||LPAD(DAY(CURRENT::DATE),2,'0')||SUBSTR(cHora,1,2)||SUBSTR(cHora,4,2)||SUBSTR(cHora,7,2)||'_tmpmonitoracla';
	LET vFechaAclaracion    = LPAD(DAY(CURRENT::DATE),2,'0')||'/'||LPAD(MONTH(CURRENT::DATE),2,'0')||'/'||YEAR(CURRENT::DATE);
	LET iPaso				= 0;
	
	LET cRutaArch = '';
	LET cMensaje = 'ERROR EN PASO: ';
	
	LET vsSQL = '';
	LET vsSQL1 = '';
	LET vsSQL2 = '';
	LET vsSQL3 = '';
	LET vsArchTemp = '';
	LET v_cod_ret = '00000';
	LET nContador = 0;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	BEGIN

		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
			
				LET v_cod_ret = iSqlErr;
			END IF;
			
			LET cMensaje = TRIM( cMensaje ) || iPaso;
			
			RETURN v_cod_ret, cMensaje;
		END EXCEPTION;

    --CAMBIAR EN PRODUCCION POR UNA RUTA QUE TENGA TODOS LOS PERMISOS
	LET cRutaArch = '/home/procesos/';

	LET iPaso = 1;
	
	LET vsArchTemp = cFechaArchivoOUT||'.txt';
	
	--ACLARACIONES CON ESTATUS DE INTENTO Y BONIFICACION TEMPORAL

	LET vsSQL1 = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || TRIM (vsArchTemp)|| ' DELIMITER ' || ''' ''';
	
	LET vsSQL2 = " SELECT DISTINCT acl.folio_csuac "
	|| " FROM bdiaclaracion:acl_movimiento mov INNER JOIN bdiaclaracion:acl_aclaracion acl "
	|| " ON acl.folio_csuac = mov.folio_csuac "
	|| " WHERE acl.fky_estatus_aclaracion = '1' and mov.exitoso = '1' and acl.fechacaptura = TODAY "
	|| " ORDER BY acl.folio_csuac ";

	LET vsSQL3 = ' " > '|| TRIM(cRutaArch) || cFechaArchivoOUT||'.sql';
	LET vsSQL = TRIM( vsSQL1 ) || ' ' || TRIM( vsSQL2 ) || ' ' || TRIM( vsSQL3 );
	SYSTEM vsSQL;
	
	LET iPaso = 2;
	
	--RUTA PRODUCTIVA
	LET vsSQL = '/ifxsif01/bin/dbaccess bdiaclaracion ' || TRIM(cRutaArch) || cFechaArchivoOUT||'.sql > '||TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	
	--RUTA PRUEBAS
	--LET vsSQL = '/informix/bin/dbaccess bdiaclaracion ' || TRIM(cRutaArch) || cFechaArchivoOUT||'.sql > '||TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.out 2>&1';
	SYSTEM vsSQL;
	
	LET iPaso = 3;
	
	SELECT COUNT(*)
	INTO nContador
	FROM bdiaclaracion:acl_movimiento mov INNER JOIN bdiaclaracion:acl_aclaracion acl
	ON acl.folio_csuac = mov.folio_csuac
	WHERE acl.fky_estatus_aclaracion = '1' and mov.exitoso = '1' and acl.fechacaptura = TODAY;
	
	LET iPaso = 4;
	
	IF( nContador == 0 ) THEN
		LET vsSQL = 'echo "No existen movimiento pendientes." >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	ELSE
		LET vsSQL = 'echo "Los siguientes Folios CSUAC no concluyeron su ingreso, quedando con estatus intento, pero generaron un abono temporal:" >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	END IF;	
	
	SYSTEM vsSQL;
	
	LET iPaso = 5;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;
	
	LET iPaso = 6;	
	
	LET vsSQL = 'cat ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'.txt >> ' || TRIM(cRutaArch)||TRIM(cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;	

	LET iPaso = 7;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.sql';
	SYSTEM vsSQL;
	
	LET iPaso = 8;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.out';
	SYSTEM vsSQL;
	
	LET iPaso = 9;
	
	LET vsSQL = 'chmod 666 ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.txt';
	SYSTEM vsSQL;

	LET iPaso = 10;
	
	LET vsSQL = 'mailx -s"MONITOR DE ACLARACIONES ' || vFechaAclaracion || '" "ncorona@bancoppel.com -c oortega@bancoppel.com; vjmendoza@bancoppel.com; rzavalag@bancoppel.com; plopezl@bancoppel.com; molverar@bancoppel.com; jgonzalez@bancoppel.com;" < ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;
	
	LET iPaso = 11;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.sql';
	SYSTEM vsSQL;
	
	LET iPaso = 12;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.out';
	SYSTEM vsSQL;	
	
	LET iPaso = 13;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'.txt';
	SYSTEM vsSQL;	
	
	LET iPaso = 14;
	
	LET vsSQL = 'rm ' || TRIM(cRutaArch) || TRIM (cFechaArchivoOUT)||'mail.txt';
	SYSTEM vsSQL;	
		
	RETURN v_cod_ret, 'PROCESO TERMINADO';

END;
--##############################################################################
--## Procedimiento   : 
--## Version         : 1.0
--## Creado por      : 
--## Fecha creacion  : 
--##Descripcion :  
--##############################################################################
END PROCEDURE;