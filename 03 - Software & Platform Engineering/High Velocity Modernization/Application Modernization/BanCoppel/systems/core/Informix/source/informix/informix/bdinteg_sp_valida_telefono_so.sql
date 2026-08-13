CREATE PROCEDURE "informix".sp_valida_telefono_so( pRFC CHAR(13),
                                                   pTelefono    CHAR(13),
                                                   pTipoTel     SMALLINT)
	RETURNING CHAR(4) AS cCodRet1;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 		CHAR(4);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
	
	DEFINE vNumCte			CHAR(20);
	DEFINE vExisteCte       INTEGER;
	DEFINE iTelInvalido     INTEGER;
	DEFINE iValidaDias      INTEGER;
	DEFINE iDiasDiff        INTEGER;
	DEFINE iDiasVerificado  INTEGER;
	DEFINE iDiasPeriodo     INTEGER;
	DEFINE iValidaDiasTu    INTEGER;
	DEFINE iDiasDiffTu      INTEGER;
	DEFINE iTelValidado   	INTEGER;
	DEFINE iTelNoValidado   INTEGER;
	DEFINE iTelCta          INTEGER;
	DEFINE vExisteCteCelular INTEGER;
	DEFINE sLimitNumFijo    SMALLINT;
	DEFINE sCoincideNumFijo SMALLINT;
	DEFINE iRegistros		SMALLINT;
	
	--INICIALIZA VARIABLES
    LET cCodRet1		= '0000';
    LET cCodRet2		= '';
    LET cCodRet3		= '';
    LET iSqlErr			= 0;
    LET iSamErr			= 0;
    LET cDesErr			= '';
	
	LET vNumCte = '0';
	LET vExisteCte    = 0;
	LET iTelInvalido    = 0;
	LET iValidaDias      = 0;
	LET iDiasDiff        = 0;
	LET iDiasVerificado  = 0;
	LET iDiasPeriodo     = 0;
	LET iValidaDiasTu    = 0;
	LET iDiasDiffTu      = 0;
	LET iTelValidado	 = 0;
	LET iTelNoValidado   = 0;
	LET iTelCta          = 0;
	LET vExisteCteCelular = 0;
	LET sLimitNumFijo    = 0;
	LET sCoincideNumFijo = 0;
	LET iRegistros		 = 0;
	
    BEGIN
	    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/informix/LIP/sp_valida_telefono_so.out";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;

	--SET DEBUG FILE TO "/informix/LIP/logs/sp_valida_telefono_so.out";
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pRFC is null OR pRFC = '') OR
       (pTelefono is null OR pTelefono = '') OR (pTipoTel is null OR pTipoTel = 0) THEN
        LET cCodRet1 = '0110';
        RETURN cCodRet1;
    END IF;
    
	-- // VERIFICA SI ES O NO EL MISMO CLIENTE QUE ESTÃ REALIZANDO LA SOLICITUD
	SELECT numcte, COUNT(*)
	INTO vNumCte, vExisteCte
	FROM "informix".si_cliente
	WHERE rfc = pRFC
	GROUP BY 1;
	
	IF(LENGTH(vNumCte) = 0 OR vNumCte IS NULL) THEN
		LET vNumCte = '0';
	END IF;
	
	---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	
	-- //SI ES NUMERO FIJO VALIDA QUE NO EXCEDA EL LIMITE DE REGISTROS PERMITIDOS - LIPC
	IF pTipoTel = '1' THEN
		SELECT valor INTO sLimitNumFijo FROM "informix".si_param WHERE cod_param='462'; 
		SELECT COUNT(telefono) INTO sCoincideNumFijo FROM "informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel='1' AND status_tel='A' AND numcte = vNumCte;
			
		IF sCoincideNumFijo >= sLimitNumFijo THEN
			LET cCodRet1 = '1167'; 
			RETURN cCodRet1;
		END IF;
		
	END IF;
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte = vNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '0004'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (CONSIDERANDO CAMPO FECHA_ACTUALIZA)
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte = vNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '0004'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iTelNoValidado
		FROM "informix".si_telefonos 
		WHERE telefono=pTelefono 
		AND tipo_tel='2' 
		AND status_tel='A' 
		AND verificado != 'V'
		AND numcte = vNumCte;
		   
		IF iTelNoValidado > 0 THEN
			LET cCodRet1 = '0003'; 
			--RETURN cCodRet1;
		END IF;
	END IF;

   -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
   SELECT COUNT(*) INTO iTelCta FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono and num_cte = vNumCte;
   IF iTelCta > 0 THEN
      LET cCodRet1 = '0005'; 
      RETURN cCodRet1;
   END IF;
	
	--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTÃ CANCELADO - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iRegistros
		FROM "informix".si_telefonos 
		WHERE numcte = vNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono
		AND status_tel = 'C'
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_telefonos WHERE numcte = vNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono);
			
		IF (iRegistros > 0 AND iTelValidado > 0) THEN
			LET cCodRet1 = '1169';
			RETURN cCodRet1;
		END IF;
	END IF;
	
	---->>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
	
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO iTelInvalido
      FROM "informix".si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF iTelInvalido > 0 THEN
        LET cCodRet1 = '0104'; 
        RETURN cCodRet1;
    END IF;
	
	--SE VALIDA SI EL TELEFONO YA ESTA REGISTRADO CON EL USUARIO TRANSBPI
	SELECT valor INTO iValidaDias FROM "informix".si_param WHERE cod_param='455';
    SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiff FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != vNumCte;
	
    IF iDiasDiff<=iValidaDias THEN
        LET cCodRet1 = '1165'; 
        RETURN cCodRet1;
    END IF;

	SELECT valor INTO iDiasVerificado FROM "informix".si_param WHERE cod_param='384';
    SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasPeriodo FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != vNumCte;

    IF iDiasPeriodo<=iDiasVerificado THEN
        LET cCodRet1 = '1163'; 
        RETURN cCodRet1;
    END IF;	
	
	-- //SI ES NUMERO FIJO VALIDA QUE NO EXCEDA EL LIMITE DE REGISTROS PERMITIDOS - LIPC
	IF pTipoTel = '1' THEN
		SELECT valor INTO sLimitNumFijo FROM "informix".si_param WHERE cod_param='462'; 
		SELECT COUNT(telefono) INTO sCoincideNumFijo FROM "informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel='1' AND status_tel='A' AND numcte != vNumCte;
			
		IF sCoincideNumFijo >= sLimitNumFijo THEN
			LET cCodRet1 = '1167'; 
			RETURN cCodRet1;
		END IF;
		
	END IF;
	
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != vNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '1168'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE (CONSIDERANDO CAMPO FECHA_ACTUALIZA) - LIPC
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != vNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '1168'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iTelNoValidado
		FROM "informix".si_telefonos 
		WHERE telefono=pTelefono 
		AND tipo_tel='2' 
		AND status_tel='A' 
		AND verificado != 'V'
		AND numcte != vNumCte;
		   
		IF iTelNoValidado > 0 THEN
			LET cCodRet1 = '1166'; 
			--RETURN cCodRet1;
		END IF;
	END IF;

   -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
   SELECT COUNT(*) INTO iTelCta FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono and num_cte<>vNumCte;
   IF iTelCta > 0 THEN
      LET cCodRet1 = '1164'; 
      RETURN cCodRet1;
   END IF;
	
   RETURN cCodRet1;

   END;
    
END PROCEDURE;