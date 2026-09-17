CREATE PROCEDURE "informix".sp_consulta_estatus_cuenta_cred_otros(p_tipo CHAR(1),p_cuenta char(30),p_cliente integer)

    RETURNING char(50) AS valor_retorno_s;
    
    DEFINE iSqlErr      	        INTEGER;
    DEFINE cod_retorno              CHAR(5);
    DEFINE p_estatus_cuenta          CHAR(30);
    DEFINE fecha_alta_p             CHAR(30);
    DEFINE consulta_est_cta         CHAR(1);
    DEFINE consulta_est_fech_alta    CHAR(30);
    DEFINE valor_retorno            CHAR(30);
   
    LET iSqlErr      	         = '';
    LET cod_retorno              = '000*';
    LET p_estatus_cuenta           = '';
    LET fecha_alta_p             = '';  
    LET consulta_est_cta         = '1';
    LET consulta_est_fech_alta   = '2';
    LET valor_retorno            = '';
   
	BEGIN
        
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN  '001*'; --RETURNING
            END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "/aplicacion/pisabanco/pisa_ftes/syndein/img/InterAct/cfg/sp_consulta_estatus_cuenta"||"_"||TRIM(p_cuenta)||"_34.out"; --> TRACE DESDE APP
  --      TRACE ON;
         /*CUENTA ACTIVA (ESTATUS) PARA CUENTAS DE CREDITO */
          IF p_tipo=consulta_est_cta THEN 
            SELECT tc.descripcion FETCH INTO p_estatus_cuenta
               FROM bdicred:sd_maecredcrd mcrd
                 INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
               WHERE mcrd.numcte = p_cliente
                 AND num_credito = p_cuenta;

              LET  valor_retorno = p_estatus_cuenta;
          END IF;
          /*CUENTA ACTIVA(FECHA APERTURA) PARA CUENTAS DE CREDITO */
          IF p_tipo=consulta_est_fech_alta THEN 

            SELECT TO_CHAR(mcrd.fecha_apertura) FETCH INTO consulta_est_fech_alta  --mcrd.fecha_apertura
               FROM bdicred:sd_maecredcrd mcrd
                 INNER JOIN bdicred:sd_tipocartera tc ON tc.status_cred = mcrd.status_cred
               WHERE mcrd.numcte = p_cliente
                 AND num_credito = p_cuenta;


           LET  valor_retorno = consulta_est_fech_alta;
          END IF;
        
 
    RETURN trim(valor_retorno);

    END

END PROCEDURE
DOCUMENT
'Sp				:	sp_consulta_estatus_cuenta_cred_otros',
'Sistema		:	Aclaraciones',
'AUTOR			:	Root',
'Area			:	Sistemas Administrativos y Perifericos',
					'Gerencia de Mtto y Soporte IV',
'Coordinador	:	Norberto Corona Berruecos',
'RQM			: 	RQM 06 612',
'FECHA			: 	ABRIL 2018',
'VERSION		: 	1.0.0',
'BD				:	bdiaclaracion';

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