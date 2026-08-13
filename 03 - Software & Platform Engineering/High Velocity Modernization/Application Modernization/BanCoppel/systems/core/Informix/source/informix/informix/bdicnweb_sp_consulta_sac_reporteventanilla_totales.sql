CREATE PROCEDURE "informix".sp_consulta_sac_reporteventanilla_totales( pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha_inicial DATE,pFecha_final DATE, pSucursal CHAR(4))
	RETURNING CHAR(5) AS codret,INTEGER AS totRegistros;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iTotales INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iTotales = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotales;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_sac_reporteventanilla_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR  pIdFuncion = '' OR pFecha_inicial = '' OR pFecha_final = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotales;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotales;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        LET pFecha_inicial = pFecha_inicial;
		LET pFecha_final=pFecha_final;
		IF nvl(pSucursal,'') ='' THEN

	    SELECT COUNT (*) as numfilas
		INTO iTotales
		FROM bdisac:sac_reportediariovent_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final;

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
				
		ELSE 
		
		SELECT COUNT (*) as numfilas
		INTO iTotales
		FROM bdisac:sac_reportediariovent_seg
		WHERE fecha_pago BETWEEN pFecha_inicial AND pFecha_final AND sucursal_pago_ventanilla=pSucursal;

		IF iTotales = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet, iTotales;
		

		END IF;

	END;		

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 21/05/2021',
'MODULO:  ',
'FUNCIONALIDAD:',
'DESCRIPCION: SPL encargado de obtener el total de registros en tabla sac_reportediariovent_seg',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sac_verificastatusgridrepdomiciliacion(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS total,
		CHAR(15) AS proceso;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cBanDetError CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError CHAR(5);
	DEFINE iTotal INTEGER;
	DEFINE iProcesados INTEGER;
	DEFINE iNoProcesados INTEGER;
	DEFINE cProceso CHAR(15);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cBanDetError = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iTotal = 0;
	LET iProcesados = 0;
	LET iNoProcesados = 0;
	LET cProceso='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cp_verificastatusarchivo.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;		
			
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,error_proceso,error,total_registros,tipo_proceso
		INTO cStatus,cErrorProceso,cError,iTotal,cProceso
		FROM "informix".sw_sac_reportedomiciliaciongrid
		WHERE usuario = TRIM(pUsuario);
		
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			RETURN cCodRet,'I','','','',0;
		ELSE 			
			RETURN cCodRet,cStatus,cErrorProceso,cError,iTotal,cProceso;
		END IF;	
		
	END;
END PROCEDURE;