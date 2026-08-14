CREATE PROCEDURE "informix".sp_conscreportnom_bpi(pNumCte CHAR(20), pNumCta CHAR(20))
											  
-- DESCRIPCIÃN 	: Se crea SP para identificar si la cuenta de nÃ³mina BanCoppel cuenta con algÃºn producto de 
--					PrÃ©stamo Directo de NÃ³mina y/o Anticipo de NÃ³mina en estatus Activo, Vigente y/o con Adeudo.
-- AUTOR		: Keevyn Adrian Gil Valenzuela
-- FECHA 		: 09/01/2017
-- BD    		: BDICRED


	-- Retornos
	RETURNING
		CHAR(6);

	-- Declarar variables 
	DEFINE cCodRet 				CHAR(6);
	DEFINE iSql_err 			INTEGER;
	
	DEFINE cNumSoliAnticipo		CHAR(20);
	DEFINE cNumSoliPrestamo		CHAR(20);
	DEFINE cStatusCredAnticipo 	CHAR(2);
	DEFINE cStatusCredPrestamo 	CHAR(2);
	DEFINE cMto6400				DECIMAL(18,2);
	DEFINE cMto7800				DECIMAL(18,2);
	
	-- AsignaciÃ³n
	LET cCodRet = "00000";
	LET iSql_err = 0;
	LET cNumSoliAnticipo = "";
	LET cNumSoliPrestamo = "";
	LET cStatusCredAnticipo = "";
	LET cStatusCredPrestamo = "";
	LET cMto6400			= 0;
	LET cMto7800			= 0;


	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
				let cCodRet = iSql_err;
				RETURN cCodRet;
			END IF;
		END EXCEPTION ;
		
		SET LOCK MODE TO WAIT 3;
		
	--	SET DEBUG FILE TO "/sp_conscreportnom_bpi.out";
	--	TRACE ON;
		
		SELECT num_solicitud INTO cNumSoliPrestamo FROM bdisolic:"informix".ss_sol_nomina WHERE numcte = pNumCte AND cuenta = pNumCta; --6400
		SELECT num_solicitud INTO cNumSoliAnticipo FROM bdisolic:"informix".ss_adn_solicitudcuenta WHERE numcte = pNumCte AND cuenta_nomina = pNumCta; --7800
				
		IF TRIM(cNumSoliPrestamo) != "" OR TRIM(cNumSoliPrestamo) IS NOT NULL OR TRIM(cNumSoliAnticipo) != "" OR TRIM(cNumSoliAnticipo) IS NOT NULL THEN
			
			-- Producto 6400 (PrÃ©stamo Directo de NÃ³mina)
		   SELECT a.status_cred, NVL(b.monto_vencido + b.mto_venc_trasp,0)
			 INTO cStatusCredPrestamo, cMto6400 
			 FROM bdicred:"informix".sd_maecredcrd a 
			 INNER JOIN bdicred:"informix".sd_maesdoscrd b ON (a.num_credito = b.num_credito) 
			WHERE a.num_producto = "6400" 
			  AND a.numcte = pNumCte 
			  AND a.num_credito = cNumSoliPrestamo;
			
			-- Producto 7800 (Anticipo de NÃ³mina)
		   SELECT a.status_cred, NVL(b.monto_vencido + b.mto_venc_trasp,0) 
			 INTO cStatusCredAnticipo, cMto7800 
			 FROM bdicred:"informix".sd_maecred a 
			INNER JOIN bdicred:"informix".sd_maesdos b ON (a.num_credito = b.num_credito)
			WHERE a.num_producto = "7800" 
			  AND a.numcte = pNumCte 
			  AND a.num_credito = cNumSoliAnticipo;
			
			IF cStatusCredPrestamo IN ("AA","E1") AND cStatusCredAnticipo IN ("AA","E1") AND (cMto6400 + cMto7800) = 0  THEN -- Anticipo y PrÃ©stamo Activos (6400 Y 7800)
				LET cCodRet = "00002";
			ELIF cStatusCredPrestamo IN ("AA","E1") AND cMto6400 = 0 THEN  -- 6400 Activo
				LET cCodRet = "00001";
			ELIF cStatusCredAnticipo IN ("AA","E1") AND cMto7800 = 0 THEN -- 7800 Activo
				LET cCodRet = "00003";
			ELIF cStatusCredAnticipo IN ("BA","BT","E1","E3") AND cMto7800 > 0 THEN	-- 7800 con Adeudo Ã³ Adeudo Vencido
				LET cCodRet = "00004";
			END IF;
			
		ELSE
			LET cCodRet = "00000"; -- No tiene adeudo.
		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE;