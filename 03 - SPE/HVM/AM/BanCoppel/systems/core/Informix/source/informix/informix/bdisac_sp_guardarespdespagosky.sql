CREATE PROCEDURE "informix".sp_guardarespdespagosky(pFolioSuc char(16), pIdRespuesta char(3),pAutorizacionRes char(10),pMpelIdREs CHAR(15),pFechaHoraAuto  datetime year to second,pUsoFuturo1 CHAR(256), pUsoFuturo2 CHAR(256),pUsoFuturo3 CHAR(256))
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet;
	
	
	--Definicion de Variables
	DEFINE cCodigoRet  CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFolio_suc CHAR(16);
	DEFINE ctxn_status CHAR(1);
	
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cFolio_suc = '';
	LET ctxn_status = '';
	
	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		--Errores de Informix
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM(NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		
		 --Validamos parámetros para que no sean nulos
		 
		 IF NVL(pFolioSuc,'') = '' OR NVL(pIdRespuesta,'') = '' THEN
			LET cCodigoRet = '00001';			RETURN cCodigoRet;
		 
         ELSE	
		 
				IF pIdRespuesta = '000' OR pIdRespuesta = '100' THEN
					LET ctxn_status = 'A';
				ELSE
					LET ctxn_status = 'C';
				END IF;
		 
		 --Hacemos update 
			UPDATE "informix".sac_sky_wsgreverso
			SET  txn_status = ctxn_status, fechahoraautorizacion = pFechaHoraAuto,id_respuesta = pIdRespuesta, mpel_id_r = pMpelIdREs, autorizacion_r = pAutorizacionRes, uso_futuro1=pUsoFuturo1 ,uso_futuro2=pUsoFuturo2,uso_futuro3=pUsoFuturo3
			WHERE folio_suc = pFolioSuc;
            
			IF dbinfo('sqlca.sqlerrd2') = 0 THEN
				LET cCodigoRet= '00002';
			END IF;	
		 END IF;
	
RETURN cCodigoRet;

	END;
END PROCEDURE;