CREATE PROCEDURE "informix".sp_guardaresppagosky
(
	pFolioSuc char(16), pIdRespuesta char(3), pAutorizacion char (10), pMeplId char (15), pFechaHoraAutorizacion datetime year to second, pUsoFuturo1 CHAR(256), pUsoFuturo2 CHAR(256),pUsoFuturo3 CHAR(256)
)
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet;
	
	--Definicion de Variables
	DEFINE cFolioSuc  CHAR(16);
	DEFINE cCodigoRet CHAR(5);
	DEFINE cFechaDep CHAR(10);
	DEFINE ccaja CHAR(4);
	DEFINE iSqlErr INTEGER;
	DEFINE cFechaFuturo1 CHAR(19);
	DEFINE ctxn_status CHAR(1);
	DEFINE cIdRespuesta CHAR(3);
	DEFINE iIdRespuesta INTEGER;
	
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cFolioSuc = '0';
	LET cFechaDep = '1900-01-01';
	LET ccaja = '0000';
	LET cFechaFuturo1= '';
	LET ctxn_status = '';
	LET cIdRespuesta = '';
	LET iIdRespuesta = 0;
	
	
	--SET DEBUG FILE TO '/home/sysifx/Geovani'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM( NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		LET cIdRespuesta = pIdRespuesta;
		
		LET iIdRespuesta = TO_NUMBER(cIdRespuesta);
		
		
		IF iIdRespuesta IS NOT NULL THEN
			LET ctxn_status = 'A';
		ELSE
			LET ctxn_status = 'C';
		END IF;
		
		IF NVL(pFolioSuc, '') = '' OR NVL(pIdRespuesta, '') = '' THEN
			 LET cCodigoRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodigoRet;
			 
		ELSE

			
     		LET cFechaFuturo1 = SUBSTR(CURRENT::CHAR(23),1,19);
				
			LET cFechaDep =
			  SUBSTR(cFechaDep, 7,  4)     ||'-'|| -- AAAA
			  SUBSTR(cFechaDep, 1,  2)     ||'-'|| -- MM  
			  SUBSTR(cFechaDep, 4,  2);
				UPDATE "informix".sac_sky_wsgpago SET txn_status = ctxn_status, id_respuesta= pIdRespuesta, autorizacion = pAutorizacion, mpel_id=pMeplId ,fechahoraautorizacion=pFechaHoraAutorizacion,uso_futuro1=pUsoFuturo1,uso_futuro2= pUsoFuturo2 ,uso_futuro3= pUsoFuturo3 WHERE folio_suc = pFolioSuc;

				IF dbinfo('sqlca.sqlerrd2') = 0 THEN
					LET cCodigoRet = '00003';
				END IF;
				
		END IF;			
		
		RETURN  TRIM( NVL(cCodigoRet,""));
		
	END;
END PROCEDURE;