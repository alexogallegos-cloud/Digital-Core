CREATE PROCEDURE "informix".ivr_registra_cte_apoyo(p_cCte CHAR(9), p_cTelefono CHAR(10))
RETURNING 	CHAR(5); --- Codigo de Retorno

	--*********************************************************
	-- CODIGOS DE ERRORES
	--*********************************************************
	-- TODO BIEN 										(00000)
	-- PARAMETROS DE ENTRADA NULOS O VACIOS 			(00002)
	-- NO EXISTE CLIENTE EN SI_CLIENTE		 			(00003)	
	-----------------------------------------------------------	
	--*********************************************************
	-- MOTIVO: Se crea procedimiento para almancenar los registros de los cliente
	-- que solicitaron el apoyo del contingencia por IVR.
	-- AUTOR: Jibran Mercado
	-- FOLIO: 
	-- CENTRO: 230204
	-- SOLICITA: Jose Luis Puebla
	--*********************************************************	
	
	--DECLARACION DE VARIABLES
	-----------------------------------------------------------
	DEFINE cCodRet			CHAR(5);
	DEFINE cCodRetDes		CHAR(100);
	DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr			INTEGER;
	DEFINE iErrorInfo		CHAR(20);	
    DEFINE cDescOper      	CHAR(20);
	DEFINE vTarjeta      	CHAR(16); 
	DEFINE vSucursal   	 	CHAR(4);
	DEFINE v_sNumcliente	CHAR(9);
	DEFINE vSecMax          INTEGER;
	DEFINE vFecOper         DATE;
	
	--INICIALIZACION DE VARIABLES
	-----------------------------------------
	LET cCodRet			= '00000';
	LET cCodRetDes		= '';
	LET iSqlErr			= 0;
	LET iIsamErr		= 0;
	LET iErrorInfo		= '';
	LET cDescOper 		= '';
	LET vTarjeta   		= '0000000000000000';
	LET vSucursal   	= '';
	LET v_sNumcliente 	= '';
	LET vSecMax 		= 0;
	LET vFecOper		= CURRENT::DATE;
	
	--SET DEBUG FILE TO "/tmp/Felix/ivr_registra_cte_apoyo.out"; -- MODIFICAR RUTA DEL ARCHIVO
	--TRACE ON;

	BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, iErrorInfo
			IF iSqlErr != 0 OR iIsamErr != 0 OR iErrorInfo != '' THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		IF ( TRIM(NVL(p_cTelefono,'') )  != ''  AND  TRIM(NVL(p_cCte,'')) != '' ) THEN
		
			--VALIDA Nï¿½MERO DE CLIENTE
			SELECT numcte,sucursal 
			INTO v_sNumcliente, vSucursal  
			FROM bdinteg:"informix".si_cliente 
			WHERE numcte = p_cCte;
				
			IF DBINFO("sqlca.sqlerrd2") > 0 THEN			
				
				EXECUTE PROCEDURE bdicred:"informix".sp_diferir (v_sNumcliente,'','','10') INTO cCodRet, cCodRetDes;
					
			ELSE 
				LET cCodRet = '00003'; --NO EXISTE CLIENTE EN SI_CLIENTE
			END IF;

			--GUARDA REGISTRO EN BITACORA
			----------------------------------------
			SELECT MAX(secuencia)
			INTO vSecMax
			FROM bdinteg:"informix".si_bitacora_ivr
			WHERE DATE(fecha_oper) = vFecOper
			AND numcte = v_sNumcliente;

			IF vSecMax IS NULL THEN
				LET vSecMax = 0;
			END IF;

			LET vSecMax = vSecMax + 1;
			
			IF (cCodRet = '00000') THEN
				LET cDescOper = 'INSCRITO_APOYO_COVID';
			ELIF (cCodRet = '00005') THEN
				LET cDescOper = 'PREV_INS_APOYO_COVID';
			ELIF (cCodRet = '00008' OR cCodRet = '00009' OR cCodRet = '00006') THEN
				LET cDescOper = 'NO_CUMPLE_REQ_COVID';
			ELSE
				LET cDescOper = 'ERROR_CTE_COVID19';
			END IF;

			INSERT INTO bdinteg:"informix".si_bitacora_ivr
			VALUES (CURRENT, vSecMax, cDescOper, vTarjeta, v_sNumcliente, p_cTelefono,'NUM_CTE', vSucursal);
		ELSE
			LET cCodRet = '00002'; --PARAMETROS DE ENTRADA NULOS O VACIOS
		END IF;
				
		RETURN cCodRet;
	END
END PROCEDURE;