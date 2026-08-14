CREATE PROCEDURE "informix".sp_obtsolicedomov_ivr()
RETURNING 	CHAR(5)	AS CodRet,			-- CodRet
		  	CHAR(20)AS NumeroCliente,	-- Numcte
		  	CHAR(16)AS NumCCT,			-- Num. Cta, Num. Credito o NÃÆÃÂºm. Tarjeta 
		  	INTEGER	AS FlagTipoCta,		-- TipoCta (CREDITO = 1 / DEBITO = 0) 
		  	CHAR(15)AS FechaCorte,		-- Fecha Corte.
		 	CHAR(15)AS FechaActual,		-- Fecha Actual
		  	CHAR(15)AS Telefono,		-- TelÃÆÃÂ©fono.
			INTEGER AS Secuencia,		--Secuencia
			CHAR(50)AS Correo,			-- Correo.
            CHAR(50)AS NomCte;          -- Nombre del Cliente

	-- Declaracion  de variables   
	DEFINE cCodRet			CHAR(5);
	DEFINE iEmpresa			CHAR(3); 
	DEFINE iEstatus			INTEGER;
	DEFINE iEstatusEnvio	INTEGER;   
	DEFINE iSecuencia		INTEGER; 
	DEFINE cNumCte			CHAR(20); 
	DEFINE cNumCCT			CHAR(16);
	DEFINE iFlagTipoCta 	INTEGER; 
	DEFINE cFechaCorte 		CHAR(15);
	DEFINE cFechaActual 	CHAR(15);
	DEFINE cTelefono 		CHAR(10);
	DEFINE cCorreo	 		CHAR(50);
    DEFINE cNomCte          CHAR(50);
	DEFINE iSqlErr  		INTEGER;

	--InicializaciÃÆÃÂ³n de Variables
	LET cCodRet 		= '00000';
	LET iEmpresa 		= ''; 
	LET iEstatus 		= 0;
	LET iEstatusEnvio 	= 0;   
	LET iSecuencia  	= 0; 
	LET cNumCte 		= ''; 
	LET cNumCCT 		= '';
	LET iFlagTipoCta 	= 0; 
	LET cFechaCorte 	= '';
	LET cFechaActual 	= '';
	LET cTelefono 		= ''; 
	LET cCorreo 		= '';
    LET cNomCte         = '';
	LET iSqlErr  		= 0;
		
	--SET DEBUG FILE TO "/tmp/zamarripa/debug/sp_tmp_solicedomov_ivr.out"; -- MODIFICAR RUTA DEL ARCHIVO
	--TRACE ON;	

	BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			 RETURN cCodRet,cNumCte,CNumCCT,iFlagTipoCta,cFechaCorte,cFechaActual,cTelefono,iSecuencia,cCorreo,cNomCte WITH RESUME;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	FOREACH WITH HOLD
		SELECT empresa, estatusenvio, secuencia, numerocliente, numcct, flagtipoCta, TO_CHAR(fechacorte, '%Y-%m-%d'), TO_CHAR(CAST(CURRENT AS DATE), '%Y-%m-%d'), telefono, correo 
		INTO iEmpresa, iEstatusEnvio,iSecuencia,cNumCte,cNumCCT,iFlagTipoCta,cFechaCorte,cFechaActual,cTelefono,cCorreo 
		FROM bdivr:"informix".tmp_solicedomov_ivr WHERE estatusenvio = 0 ORDER BY numerocliente

        SELECT nombre1 INTO cNomCte FROM bdinteg: si_cliente WHERE numcte = cNumCte;
		
		RETURN cCodRet,cNumCte,cNumCCT,iFlagTipoCta,cFechaCorte,cFechaActual,cTelefono,iSecuencia,cCorreo,cNomCte WITH RESUME;	
	END FOREACH;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00001';
		RETURN cCodRet,cNumCte,cNumCCT,iFlagTipoCta,cFechaCorte,cFechaActual,cTelefono,iSecuencia,cCorreo,cNomCte WITH RESUME;	
	END IF;	
	
	END;
END PROCEDURE
DOCUMENT
'Realiza validaciones correspondientes al sp_tmp_solicedomov_ivr para luego Consultarlos ',
'en la tabla tmp_solicedomov_ivr temporalmente hasta se Consultara en la tabla tmp_solicedomov_ivr si el estatus_Envio es ta en 0' ,
'AUTOR : Jose Manuel Higuera Zamarripa' ,
'FECHA : 10/01/2020' ,
'FOLIO : 623.1' ,
'BD    : BDIVR' ;

CREATE PROCEDURE "informix".sp_act_estatusenv_ivr(p_iSecuencia SMALLINT, p_cValorCapturado CHAR(16))
RETURNING 	CHAR(5)	AS CodRet;
		  	
	-- Declarar variables   
	DEFINE cCodRet CHAR(5);   	
	DEFINE iSqlErr INTEGER;

	--Iniciar Variables
	LET cCodRet	= '00000';	
	LET iSqlErr	= 0;
		
	--SET DEBUG FILE TO "/tmp/Misael/sp_act_estatusenv_ivr.out"; 
	--TRACE ON;	

	BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	UPDATE {+INDEX bdivr:"informix".tmp_solicedomov_ivr idx_secuencia_edomov}
	bdivr:"informix".tmp_solicedomov_ivr
		SET estatusenvio = 1 
	WHERE secuencia = p_iSecuencia
	AND numcct = p_cValorCapturado;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00001';
		RETURN cCodRet;	
	END IF;	
	
	RETURN cCodRet;	
	END;
END PROCEDURE
DOCUMENT
'MOTIVO: Se crea procedimiento para generar UPDATE a la solicitud pendiente del envio de la consulta de estado de movimientos despues del corte.' ,
'AUTOR : Jibran Mercado Obeso' ,
'FECHA : 20/02/2020' ,
'FOLIO : 623.1' ,
'BD    : BDIVR' ;

CREATE PROCEDURE "informix".sp_act_estatusenv_ivr(P_empresa CHAR(3),P_numCte CHAR(9), P_CtaCredTarj CHAR(16), P_tipoReporte INTEGER,  P_FechaCorte DATE, P_FechaActual DATE,
									P_Correo CHAR(50), P_telefono CHAR(10), P_flagExitoso INTEGER)
RETURNING 	CHAR(5)	AS CodRet;
		  	
	-- Declarar variables   
	DEFINE cCodRet CHAR(5);   	
	DEFINE iSqlErr INTEGER;

	--Iniciar Variables
	LET cCodRet	= '00000';	
	LET iSqlErr	= 0;
		
	--SET DEBUG FILE TO "/tmp/Misael/sp_act_estatusenv_ivr.out"; 
	--TRACE ON;	

	BEGIN

	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	INSERT INTO bdivr: "informix".tmp_solicedomov_ivr (empresa,estatusenvio,numerocliente,numcct,flagtipocta,fechacorte,fechaactual,telefono,correo)
	VALUES (P_empresa,P_flagExitoso,P_numCte,P_CtaCredTarj,P_tipoReporte,P_FechaCorte,P_FechaActual,P_telefono,P_Correo);
		
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00001';
		RETURN cCodRet;	
	END IF;	
	
	RETURN cCodRet;	
	END;
END PROCEDURE
DOCUMENT
'MOTIVO: Se crea procedimiento para generar UPDATE a la solicitud pendiente del envio de la consulta de estado de movimientos despues del corte.' ,
'AUTOR : Jibran Mercado Obeso' ,
'FECHA : 20/02/2020' ,
'FOLIO : 623.1' ,
'BD    : BDIVR' ;

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