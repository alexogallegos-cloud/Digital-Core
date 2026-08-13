CREATE PROCEDURE "informix".sp_soldespagoskyonline(pFolioSuc char(16)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet, CHAR(850) AS cTrama; 
	
	--Definicion de Variables
	DEFINE cCodigoRet  	CHAR(5);
	DEFINE cTrama    	CHAR(850);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cEnte_id 			CHAR(3);
	DEFINE cNumero_cuenta 	    CHAR(12);
	DEFINE cFecha_depo_banco    CHAR(10);
	DEFINE cImporte_transaccion CHAR(13);
	DEFINE cAutorizacion 	CHAR(10);
	DEFINE cMpel_id 		CHAR(15);
	DEFINE cUsoFuturo1 		CHAR(256);
	DEFINE cUsoFuturo2 		CHAR(256);
	DEFINE cUsoFuturo3 		CHAR(256);
	DEFINE cFolio_pago 		CHAR(10);
	DEFINE cTrancinterac    CHAR(5);
	DEFINE cTrancservice    CHAR(5);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET cTrama = '';
	LET iSqlErr = 0;
	LET cEnte_id ='';
	LET cNumero_cuenta ='';
	LET cFecha_depo_banco ='';
	LET cImporte_transaccion ='';
	LET cAutorizacion =''; 	
	LET cMpel_id ='';		
	LET cUsoFuturo1 	='';	
	LET cUsoFuturo2 	=''; 		
	LET cUsoFuturo3 	='';
	LET cFolio_pago 	=''; 
	LET cTrancinterac 	='';
	LET cTrancservice   ='';
	
	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		
		--Validamos parÃ¡metros para que no sean nulos
		IF NVL(pFolioSuc,'') = '' THEN
			 LET cCodigoRet = '00001';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
        ELSE
		
		if (SELECT COUNT(*) FROM "informix".sac_sky_wsgpago  WHERE folio_suc = pFolioSuc AND id_respuesta ='000'  ) = 0 then 
			 LET cCodigoRet = '00002';			 RETURN TRIM(NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
		END IF;
		SELECT trans_interact
		INTO cTrancinterac		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT trans_servicio
		INTO cTrancservice		
		FROM bdisac: "informix".sac_intrfz_serv  
		WHERE numcategoria = '06' and numconvenio='001' and num_trama = '2';
		
		
		SELECT valor 
		INTO cEnte_id 
		FROM bdisac: "informix".sac_param 
		WHERE cod_param = '114';
		
		SELECT referencia1 
		INTO cNumero_cuenta 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		--Fecha actual del sistema
		LET cfecha_depo_banco =
		SUBSTR(CURRENT, 9,  2)     ||'/'|| -- DD 
		SUBSTR(CURRENT, 6,  2)     ||'/'|| -- MM  
		SUBSTR(CURRENT, 1,  4)     ||' '|| -- AAAA   
					'';
		
		SELECT importe_pago 
		INTO cImporte_transaccion 
		FROM bdisac: "informix".sac_movimientos 
		WHERE folio_suc = pFolioSuc;
		
		LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);
		
		SELECT autorizacion
		INTO cAutorizacion
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		SELECT mpel_id 
		INTO cMpel_id
		FROM bdisac: "informix".sac_sky_wsgpago 
		WHERE folio_suc = pFolioSuc;
		
		--concatenar todas la variables en cTrama
LET cTrama = NVL(cTrancinterac,'') || NVL(cTrancservice,'') || NVL(cEnte_id,'') || NVL(cNumero_cuenta,'') || NVL(cFecha_depo_banco,'') || NVL(SUBSTR(cImporte_transaccion,2,12),'0.00') || NVL(cFolio_pago,'') || NVL(cAutorizacion,'') || NVL(cMpel_id,'') || NVL(cUsoFuturo1,'') || NVL(cUsoFuturo2,'') || NVL(cUsoFuturo3,'');	
 
	END IF;
	
	RETURN TRIM(NVL(cCodigoRet,'')),NVL(cTrama,'');
	
	END;
END PROCEDURE;