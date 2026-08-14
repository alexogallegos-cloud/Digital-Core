CREATE PROCEDURE "informix".sp_solpagoskyonline( pFolioSuc char(16) )
	--RETORNOS
	RETURNING
	CHAR(5)  AS cCodigoRet, CHAR(993) AS cTrama;
	
				
			
				
	--Definicion de Variables
	DEFINE cFolioSuc  CHAR(16);
	DEFINE cCodigoRet CHAR(5);
	
	DEFINE iSqlErr INTEGER;
	
	--nuevas
	DEFINE cTrancinterac CHAR(5);
	DEFINE cTrancservice CHAR(5);
	DEFINE cEnte_id 		CHAR(3);
	DEFINE cNumero_cuenta CHAR(12);
	DEFINE cImporte_transaccion CHAR(13);
	DEFINE cFecha_hora_trans CHAR(19);
	DEFINE cFecha_depo_banco CHAR(10);
	DEFINE cCaja			CHAR(4);
	DEFINE cTienda 		CHAR(6);
	DEFINE cOperador		CHAR(4);
	DEFINE cPlaza 		CHAR(30);
	DEFINE cFolio_pago	CHAR(10);
	DEFINE cMoneda		CHAR(3);
	DEFINE cPais_id		CHAR(2);
	DEFINE cNombre 		CHAR(100);
	DEFINE cUso_futuro1 CHAR(256);
	DEFINE cUso_futuro2 CHAR(256);
	DEFINE cUso_futuro3 CHAR(256);
	DEFINE cTrama 		CHAR(993);
	DEFINE cForma_Pago	CHAR(2);
	
	
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cFolioSuc = '0';
	LET cTrama = '';
	
	LET cTrancinterac ='';
	LET cTrancservice ='';
	LET cEnte_id 		='';
	LET cNumero_cuenta ='';
	LET cImporte_transaccion ='';
	LET cFecha_hora_trans ='';
	LET cFecha_depo_banco ='';
	LET cCaja		='';
	LET cTienda 	='';
	LET cOperador	='';
	LET cPlaza 		='';
	LET cFolio_pago	='';
	LET cMoneda		='';
	LET cPais_id	='';
	LET cNombre 	='';
	LET cUso_futuro1 ='';
	LET cUso_futuro2 ='';
	LET cUso_futuro3 ='';
	LET cForma_Pago = '';
	
	
	
	--SET DEBUG FILE TO '/home/sysifx/Geovani'; 
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM( NVL(cCodigoRet,"")),TRIM( NVL(cTrama,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		IF NVL(pFolioSuc, '') = '' THEN
			 LET cCodigoRet = '00001';
		ELSE
			select trans_interact, trans_servicio
			into cTrancinterac,	cTrancservice		
			from "informix".sac_intrfz_serv 
			where numcategoria = '06' and numconvenio='001' and num_trama = '1';
			
			select valor
			into cEnte_id		
			from "informix".sac_param 
			where  cod_param = '114';
			
			select referencia1 , importe_pago, id_sucursal, SUBSTR(usuario, 5, 4),referencia3
			into cNumero_cuenta , cImporte_transaccion , cTienda , cOperador, cNombre
			from "informix".sac_movimientos
			where folio_suc = pFolioSuc ;
			
			LET cFecha_hora_trans =
								  SUBSTR(CURRENT, 9,  2)     ||'/'|| -- DD 
								  SUBSTR(CURRENT, 6,  2)     ||'/'|| -- MM  
								  SUBSTR(CURRENT, 1,  4)     ||' '|| -- AAAA   
								  SUBSTR(CURRENT, 12, 2)     ||':'|| -- HH   (Hour)
								  SUBSTR(CURRENT, 15, 2)     ||':'|| -- MM  Minute)
								  SUBSTR(CURRENT, 18, 2)     || 	-- SS(Segundos)
								  								  '';
			LET cfecha_depo_banco =
								  SUBSTR(CURRENT, 9,  2)     ||'/'|| -- DD 
								  SUBSTR(CURRENT, 6,  2)     ||'/'|| -- MM  
								  SUBSTR(CURRENT, 1,  4) 	 ||''; 					  
								  
								  
			select valor
			into cCaja		
			from "informix".sac_param 
			where  cod_param = '115';					  
								
			select nombre
			into cPlaza
			from bdinteg: "informix".si_estados 
			where estado = (select estado from bdinteg: "informix".si_sucursales where sucursal = cTienda);
			
			Let cFolio_pago = SUBSTR(pFolioSuc, 7,  10); 
						
			select sky_cod_moneda , sky_cod_pais
			into cMoneda, cPais_id
			from sac_sky_codpais 
			where id_sky_pais = '1'; 
			
			SELECT  CASE forma_pago
                        WHEN '1' THEN '01'
                        WHEN '2' THEN '28'
                        ELSE '99' END AS formpag
			INTO	cForma_Pago
			FROM	bdisac:"informix".sac_movimientos
			WHERE	folio_suc = pFolioSuc;
			
			LET		cUso_futuro2 = cForma_Pago;
			
			Let cTrama = NVL(cTrancinterac, '')  || NVL(cTrancservice, '') || NVL(cEnte_id, '') || NVL(cNumero_cuenta, '') || NVL(SUBSTR(cImporte_transaccion,2,12), '') || NVL(cFecha_hora_trans, '') || NVL(cfecha_depo_banco, '') || NVL(cCaja, '') || NVL(cTienda, '')  || NVL(cOperador, '') || NVL(cPlaza, '')  || NVL(cFolio_pago, '') || NVL(cMoneda, '') || NVL(cPais_id, '')  || NVL(cNombre, '') || NVL(cUso_futuro1, '')  || NVL(cUso_futuro2, '') || NVL(cUso_futuro3, '');
			
			
			
		END IF;
		
		
		
		RETURN  TRIM( NVL(cCodigoRet,"")),TRIM( NVL(cTrama,"")) ;
		
	END;
END PROCEDURE;