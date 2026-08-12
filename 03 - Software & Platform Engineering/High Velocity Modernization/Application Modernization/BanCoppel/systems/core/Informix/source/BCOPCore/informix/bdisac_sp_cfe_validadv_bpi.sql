CREATE PROCEDURE "informix".sp_cfe_validadv_bpi(pReferencia CHAR(30),pImporte CHAR(10))
	RETURNING 
    CHAR (5)  AS cCodRet,
    CHAR (80) AS Descripcion;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet			CHAR(5);
DEFINE cDescripcion 	CHAR(80);
DEFINE cDigVerRef      	CHAR(1);
DEFINE cFechaRef		CHAR(6);
DEFINE cFechaHoy		CHAR(8);
DEFINE cFechaFinal		CHAR(6);
DEFINE iMultiplo		INTEGER;
DEFINE i 				INTEGER;
DEFINE iNum				INTEGER;
DEFINE iLongDV			INTEGER;
DEFINE iSuma        	INTEGER;
DEFINE iModulo			INTEGER;
DEFINE iDigVer			INTEGER;	
DEFINE cImporte         CHAR(10);

--Inicializacion de Variables
LET iSqlErr 		= 0;
LET cCodRet 		= '00000';
LET cDescripcion	= '';
LET cDigVerRef		= 0;
LET cFechaRef		= '';
LET cFechaHoy		= '';
LET cFechaFinal		= '';
LET iMultiplo		= 0;
LET i       		= 0;
LET iNum			= 0;
LET iLongDV			= 0;
LET iSuma			= 0;
LET iModulo			= 0;
LET iDigVer			= 0;
let cImporte        = '';

	--SET DEBUG FILE TO '/informix/yuri/sp_validadv_cfe.out';
	--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET  cCodRet = iSqlErr;
			RETURN cCodRet,cDescripcion;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pReferencia,'')) = '' OR LENGTH(TRIM(pReferencia)) < 30 THEN
		LET cCodRet = '00004';
		LET cDescripcion = 'Referencia incorrecta, favor de validar';
	ELSE
		
		SELECT TO_CHAR(fecha_hoy,'%Y%m%d') INTO cFechaHoy
		FROM bdisac:"informix".sac_fechas;	

		--LET cFechaHoy= '20150512';
		
		LET iLongDV = LENGTH(TRIM(pReferencia)) -1 ;
		LET cDigVerRef = SUBSTR (pReferencia, LENGTH(TRIM(pReferencia)), 1);
		LET cFechaRef = SUBSTR(pReferencia,15,6);
        LET cImporte = SUBSTR(pReferencia,21,9);

		LET cFechaFinal  = SUBSTR(cFechaHoy,3,6);

        
        IF (cImporte::money) <> (pImporte::money) THEN
			LET cCodRet = '00001';
			LET cDescripcion = 'El importe es diferente al de la referencia';
            RETURN cCodRet,cDescripcion;
        END IF;
		
		
		IF (cFechaRef - cFechaFinal) < 2 THEN
			LET cCodRet = '00002';
			LET cDescripcion = 'Fecha fuera de rango, favor de validar';
            
		ELSE 
			LET iMultiplo  = 2;
			
			FOR i = 1 TO iLongDV
				LET iNum = SUBSTRING (pReferencia FROM iLongDV FOR 1);
				LET iDigVer = iNum * iMultiplo;
				
				LET iSuma = iSuma + iDigVer;
				LET iLongDV = iLongDV - 1;
				LET iMultiplo = iMultiplo + 1;
				
				IF iMultiplo > 7 THEN 
					LET iMultiplo  = 2;
				END IF;
				
			END FOR;
			
			LET iModulo = MOD(iSuma,11);
			IF iModulo = 10 THEN	    
				LET iModulo = 0;
			END IF;
			
			IF iModulo <> cDigVerRef THEN
				LET cCodRet = '00003';
				LET cDescripcion = 'Digito verificador incorrecto, favor de validar';
			ELSE 
				LET cCodRet = '00000';
				LET cDescripcion = 'Referencia valida';
				
			END IF;
			
		END IF;
		
			
	END IF;
	
	RETURN cCodRet,cDescripcion;
	
END;
	
END PROCEDURE
DOCUMENT
'Folio: 308',
'Autor: 93086393, Aaron QuiÃ±onez',
'Fecha: 26/09/2017',
'DescripciÃ³n: Se crea procedimiento para validar la linea de captura de CFE',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_conciliacion_bcpl_cpl_sig_dia()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(80)		AS mensaje_respuesta;

    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cCodRet          CHAR(5);
	DEFINE cMensaje			CHAR(80);
	DEFINE cCodRetSP		CHAR(5);
	DEFINE cMensajeSP		CHAR(80);
	DEFINE dFecha_Hoy		DATE;
	DEFINE cStatus			CHAR(1);
	DEFINE bExisteCarga		SMALLINT;
	
    LET cCodRet 			= '00000';
	LET cMensaje			= 'PROCESO EXITOSO';
	LET cCodRetSP			= '99999';
	LET cMensajeSP			= 'ERROR';
	LET dFecha_Hoy			= DATE(1);
	LET cStatus				= '0';
	LET bExisteCarga		= 1;
	
	--SET DEBUG FILE TO  '/tmp/adrian/sp_conciliacion_bcpl_cpl_sig_dia.out';
	--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_conciliacion_bcpl_cpl_sig_dia");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		--SE OBTIENE LA FECHA DEL DIA ANTERIOR (ESTA PENSADO PARA QUE EL REPROCESO SEA GENERADO EL MISMO DIA QUE LA FECHA DE PROCESO ORIGINAL)
		SELECT {+INDEX(bdisac:"informix".sac_fechas idx_sac_fechas)} fecha_hoy - 1
		INTO dFecha_Hoy
		FROM bdisac:"informix".sac_fechas;
		
		--PRIMERO REVISO QUE NO SE HAYA GENERADO EL PROCESO DE CARGA DE ARCHIVO DEL DIA A PROCESAR (DIA ANTERIOR)
		IF NOT EXISTS(SELECT *
		              FROM   sac_procesos
		              WHERE  proceso       IN ('CONCI_CARG', 'CONCI_CAR2')
		              AND    fecha_proceso = dFecha_Hoy) THEN
					  
			--NO EXISTIÃ CARGA DE ARCHIVO PREVIA (SEGURAMENTE A ESA HORA NO EXISTIO ARCHIVO A CARGAR)
			LET bExisteCarga = 0;
			
		ELSE
		
			/* PLATICADO CON LEONARDO HERNANDEZ, EN ESTE MOMENTO EXCLUIDAS ESTAS OPCIONES */
			
			IF NOT EXISTS(SELECT *
						  FROM   sac_procesos
		                  WHERE  proceso       = 'CONCI_CAR2'
		                  AND    fecha_proceso = dFecha_Hoy) THEN
				--OBTENGO ESTATUS DEL PROCESO DE CARGA NORMAL (CRONT)
				SELECT status
				INTO   cStatus
				FROM   sac_procesos
				WHERE  proceso       = 'CONCI_CARG'
				AND    fecha_proceso = dFecha_Hoy;
			ELSE
				--OBTENGO ESTATUS DEL PROCESO DE CARGA MANUAL
				SELECT status
				INTO   cStatus
				FROM   sac_procesos
				WHERE  proceso       = 'CONCI_CAR2'
				AND    fecha_proceso = dFecha_Hoy;
			END IF;
			
			IF cStatus = '0' THEN
				LET bExisteCarga = 0;
			END IF;
			
		END IF;
		
		--SI LA BANDERA DE CARGA ES CORRECTA ENVIO MENSAJE Y TERMINO EJECUCION
		IF bExisteCarga = 1 THEN
			LET cCodRet  = '00001';
			LET cMensaje = 'NO ES NECESARIA ESTA CARGA EXTRAORDINARIA, CARGA PREVIA';
			RETURN cCodRet, cMensaje;
		END IF;
		
		--VALIDAR SI YA SE EJECUTO LA CARGA DEL ARCHIVO
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_CAR3'
					AND  fecha_proceso = dFecha_Hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_CAR3', dFecha_Hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_CAR3'
			AND fecha_proceso = dFecha_Hoy;
		END IF;
		
		--CARGAR EL ARCHIVO (NUEVO INTENTO)
		IF cStatus = '0' THEN
			EXECUTE PROCEDURE "informix".sp_cargaarchivoaconciliacionbcpl(dFecha_Hoy) INTO cCodRetSP,cMensajeSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = cCodRetSP;
				LET cMensaje = cMensajeSP;
				RETURN cCodRet, cMensaje;				
			ELSE
				--ACTUALIZAR EL STATUS DE LA BITACORA
				UPDATE bdisac:"informix".sac_procesos
				SET status = '1'
				WHERE TRIM(proceso) = 'CONCI_CAR3'
				AND  fecha_proceso = dFecha_Hoy;
			END IF;				
		END IF;
		
		LET cStatus = '0';

		--VALIDAR SI TERMINO DE MANERA CORRECTA LA CARGA DEL ARCHIVO (NUEVO INTENTO)
		IF NOT EXISTS(SELECT proceso, fecha_proceso, status, user_insert, fecha_insert
					FROM bdisac:"informix".sac_procesos
					WHERE TRIM(proceso) = 'CONCI_MOV3'
					AND  fecha_proceso = dFecha_hoy) THEN

			INSERT INTO bdisac:"informix".sac_procesos (proceso, fecha_proceso, status, user_insert, fecha_insert)
			VALUES('CONCI_MOV3', dFecha_hoy, '0', 'informix',CURRENT);
		ELSE
			SELECT status
			INTO cStatus
			FROM bdisac:"informix".sac_procesos
			WHERE TRIM(proceso) = 'CONCI_MOV3'
			AND fecha_proceso = dFecha_hoy;		
		END IF;
		
		--CONCILIAR MOVIMIENTOS
		IF cStatus = '0' THEN
			EXECUTE PROCEDURE "informix".sp_generaconciliacioncoppel(dFecha_Hoy) INTO cCodRetSP,cMensajeSP;
			IF cCodRetSP <> '00000' THEN
				LET cCodRet = cCodRetSP;
				LET cMensaje = cMensajeSP;
				RETURN cCodRet, cMensaje;
			ELSE
				--ACTUALIZAR EL STATUS DE LA BITACORA
				UPDATE bdisac:"informix".sac_procesos
				SET status = '1'
				WHERE TRIM(proceso) = 'CONCI_MOV3'
				AND  fecha_proceso = dFecha_hoy;

				--VALIDAR ACTUALIZACION DE BITACORA
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
					LET cMensaje = 'ERROR AL ACTUALIZAR LA BITACORA PARA CONCI_MOV3';
					RETURN cCodRet,cMensaje;
				END IF;
			END IF;
		END IF;
        
        RETURN cCodRet,cMensaje;
		
    END;
END PROCEDURE
;