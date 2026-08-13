CREATE PROCEDURE "informix".sp_guardasoldespagosky(pImporteTransaccion money(10,2), pFolioSuc char(16), pNumCuenta char(12), pUsuario char(8)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet;
	
	--Definicion de Variables
	DEFINE cCodigoRet  CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEnteId CHAR(3);
	DEFINE cMpelId CHAR(15);
	DEFINE cFolio_pago CHAR(10);
	DEFINE cAutorizacion CHAR(10);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cEnteId = '0';
	LET cMpelId = '0';
	LET cFolio_pago ='';
	LET cAutorizacion = '';

	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM(NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		 --Validamos parámetros para que no sean nulos
		 IF NVL(pImporteTransaccion,'') = '' OR NVL(pFolioSuc,'') = '' OR NVL(pNumCuenta,'') = '' OR NVL(pUsuario,'') = '' THEN
		 LET cCodigoRet = '00001';		 RETURN NVL(cCodigoRet,"");
         ELSE	
		 
		 SELECT mpel_id INTO cMpelId FROM sac_sky_wsgpago where folio_suc = pFolioSuc;
		 SELECT autorizacion INTO cAutorizacion FROM sac_sky_wsgpago where folio_suc = pFolioSuc; 
		 SELECT valor into cEnteId FROM sac_param WHERE cod_param = '114';

		 
		 LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);	
		 
		 INSERT INTO "informix".sac_sky_wsgreverso(txn_status,ente_id,numcuenta,fechadepbanco,importetrans,folio_pago,autorizacion_s,mpel_id_s,uso_futuro1,uso_futuro2,uso_futuro3,folio_suc,usuario_insert,fecha_insert) 
		 VALUES('C',cEnteId,pNumCuenta,today,pImporteTransaccion,cFolio_pago,cAutorizacion,cMpelId,null,null,null,pFolioSuc,pUsuario,today);
		  	
	 	
		 IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		 END IF;	
	END IF;
	
	RETURN  TRIM(NVL(cCodigoRet,""));
	
	END;
END PROCEDURE;