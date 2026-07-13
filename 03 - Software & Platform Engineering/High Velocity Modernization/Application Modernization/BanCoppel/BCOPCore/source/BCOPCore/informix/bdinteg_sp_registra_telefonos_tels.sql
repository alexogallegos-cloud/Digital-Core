CREATE PROCEDURE "informix".sp_registra_telefonos_tels(
	pEmpresa     CHAR(3),
    pNumCte      CHAR(20), 
    pTelefono    CHAR(13),
    pTipoTel     SMALLINT,
    pExtension   CHAR(5),
	pCarrier     SMALLINT,
    pCanal       SMALLINT,
    pUserInsert  CHAR(8) )
	
	RETURNING CHAR(5) AS cCodRet1;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 	    CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
    DEFINE iSqlErr  		INTEGER;
    DEFINE iSamErr  		INTEGER;
    DEFINE cDesErr  		CHAR(50);
    DEFINE iExisteCte       INTEGER;
    DEFINE iExisteCanal     INTEGER;
    DEFINE cCodRetValTel    CHAR(5);
    DEFINE cValCasa         CHAR(1);
    DEFINE cValCelular      CHAR(1);
    DEFINE cValOficina      CHAR(1);
    DEFINE cCofetel         CHAR(1);
    DEFINE iExisteCarrier   INTEGER;
    DEFINE dFechaInsert		DATE;
    DEFINE sMaxSecTel       SMALLINT;
    DEFINE sContacto        SMALLINT;
    DEFINE iSecMaxDir       INTEGER;
    DEFINE iExisteTelefono  INTEGER;
    DEFINE iFijoMovil  		INTEGER;
    DEFINE cDescFijoMovil  	CHAR(5);
    DEFINE cResulFijoMovil	CHAR(5);
	DEFINE cVerificado		CHAR(1);
    DEFINE iTelInvalido     INTEGER;
	DEFINE vmarcatel        CHAR(1);
	DEFINE vfecha_actualiza DATE; 
	DEFINE v_tel_confirmado CHAR(1);
	DEFINE vfech_confirmado DATE;
    DEFINE iDiasVerificado  INTEGER;
    DEFINE iDiasPeriodo     INTEGER;
    DEFINE sSucursal        CHAR(4);
    DEFINE iValidaDias      INTEGER;
	DEFINE iValidaDiasTu    INTEGER;
	DEFINE iTelValidado   	INTEGER;
	DEFINE iTelNoValidado   INTEGER;
	DEFINE iDiasDiff        INTEGER;
	DEFINE iDiasDiffTu      INTEGER;
    DEFINE nrows            SMALLINT;
    DEFINE cTelval          CHAR(13);
	DEFINE cCodRetSp        CHAR(5);
	DEFINE sLimitNumFijo    SMALLINT;
	DEFINE sCoincideNumFijo SMALLINT;
	DEFINE iRegistros		SMALLINT;
    DEFINE iRegistrosCanc   SMALLINT;
	DEFINE status_telefono  CHAR(1);
	DEFINE iTelCta          INTEGER;
	DEFINE iSucSMS          INTEGER;
	DEFINE vNumCteSMS       CHAR(20);
    DEFINE cCodRetSp2       CHAR(5);
    DEFINE correoCli        CHAR(100);
    DEFINE celularCli       CHAR(13);
	DEFINE contTel          INTEGER;
	DEFINE vCuentas1800		INTEGER;
	DEFINE UserOnline		CHAR(8);
	DEFINE vSuc				CHAR(4);
	DEFINE iNviejo          SMALLINT; --EPG 021621	
	--APR RQM Matto Telefonos
	DEFINE sNumcte			CHAR(9);
	DEFINE CodRet			CHAR(5);
	DEFINE sTipoCte			CHAR(1);
	DEFINE sSecuencia		CHAR(3);
	
	
	--INICIALIZA VARIABLES
    LET cCodRet1		 = '000';
    LET cCodRet2		 = '';
    LET cCodRet3		 = '';
    LET iSqlErr			 = 0;
    LET iSamErr			 = 0;
    LET cDesErr			 = '';
    LET iExisteCte		 = 0;
    LET iExisteCanal	 = 0;
    LET cCodRetValTel	 = '';
    LET cValCasa		 = '';
    LET cValCelular		 = '';
    LET cValOficina		 = '';
    LET cCofetel		 = '';
    LET iExisteCarrier	 = 0;
    LET dFechaInsert	 = '';
    LET sMaxSecTel		 = 0;
    LET sContacto		 = 0;
    LET iSecMaxDir		 = 0;
    LET iExisteTelefono	 = 0;
    LET iFijoMovil		 = 0;
    LET cDescFijoMovil	 = '';
    LET cResulFijoMovil	 = '';
	LET cVerificado		 = 'F';
    LET iTelInvalido     = 0;
	LET vmarcatel        = '';
	LET vfecha_actualiza = ''; 
	LET v_tel_confirmado = '';
	LET vfech_confirmado = '';
    LET iDiasVerificado  = 0;
    LET iDiasPeriodo     = 0;
    LET sSucursal        ='0000';
	LET iValidaDias      = 0;
	LET iValidaDiasTu    = 0;
	LET iDiasDiff        = 0;
	LET iDiasDiffTu      = 0;
	LET iTelValidado	 = 0;
	LET iTelNoValidado   = 0;
    LET nrows            = 0;
    LET cTelval          = '';
    LET cCodRetSp        = '00000';
	LET sLimitNumFijo    = 0;
	LET sCoincideNumFijo = 0;
	LET iRegistros		 = 0;
    LET iRegistrosCanc   = 0;
	LET status_telefono  = '';
	LET iTelCta          = 0;
	LET iSucSMS          = 0;
	LET vNumCteSMS 		 = '';
	LET cCodRetSp2       = '00000';
	LET correoCli        = '';
	LET celularCli       = '';
	LET contTel          = 0;
	LET UserOnline		 = '';
	LET vSuc			= '';
	LET iNviejo          = '0'; --EPG 021621	
	LET vCuentas1800	= 0;
	--RQM Mtto Telefonos
	LET sNumcte			= '';
	LET CodRet			= '00000';
	LET sTipoCte		= '';
	LET sSecuencia		= '';
	
	
	--SET DEBUG FILE TO "/informix/EPG/sp_registra_telefonos.out";
	--TRACE ON;
	
    BEGIN
	    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_telefonos.err";
        --TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;
    		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
        (pTipoTel is null OR pTipoTel = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT COUNT(*)
      INTO iExisteCte
      FROM "informix".si_cliente
     WHERE numcte = pNumCte;
     
    IF iExisteCte = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1;
    END IF;
    --RQM 1697 INICIO
    IF ((pTelefono is null OR pTelefono = '') and pTipoTel IN (1,2))  THEN
        UPDATE "informix".si_telefonos set status_tel='C' WHERE numcte = pNumCte and tipo_tel = pTipoTel;
        DELETE FROM "informix".si_telefonos_actual WHERE numcte = pNumCte and tipo_tel = pTipoTel;
        LET cCodRet1 = '220';
        RETURN cCodRet1;
    END IF;
    --RQM 1697 FIN
    
    -- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
    SELECT COUNT(*)
      INTO iExisteTelefono
      FROM "informix".si_telefonos_actual
     WHERE numcte = pNumCte
       AND tipo_tel = pTipoTel
       AND telefono = pTelefono
       AND status_tel = 'A';
       
    IF iExisteTelefono > 0 THEN
        LET cCodRet1 = '999'; 
    END IF;
    
	--Valida que el nÃ?Ã?Ã?ÃÂºmero en cuestion no este registrado para ese cliente, pero con otro tipo de telÃ?Ã?Ã?ÃÂ©fono
	IF pTipoTel IN (1, 2) THEN					   
		SELECT COUNT(*)
		INTO iExisteTelefono
		FROM "informix".si_telefonos
		WHERE numcte = pNumCte
		AND tipo_tel != pTipoTel
		AND telefono = pTelefono
		AND status_tel = 'A'
		AND tipo_tel IN (1,2)
		;

		IF iExisteTelefono > 0 THEN
			LET cCodRet1 = '2861';
			RETURN cCodRet1;
		END IF;
	END IF;
	
    -- // VALIDA EL CANAL DE PROCEDENCIA
    SELECT COUNT(*)
      INTO iExisteCanal
      FROM "informix".si_canal
     WHERE cve_canal = pCanal;
     
    IF iExisteCanal = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1;
    END IF;
	
	SELECT valor INTO UserOnline FROM bdinteg:si_param where cod_param = 481;
		
	IF UserOnline=pUserInsert THEN
		LET cVerificado='V';
	END IF;
		
	SELECT telefono  --Obtiene el numero viejo del celular del cliente
	INTO celularCli 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte = pNumCte	AND tipo_tel='2' AND status_tel='A'; 
	
	LET iNviejo = dbinfo("sqlca.sqlerrd2");	 --EPG 021621	
	
	SELECT COUNT(*) INTO contTel 
	FROM bdinteg:"informix".si_telefonos 
	WHERE numcte=pNumCte AND tipo_tel=2 AND status_tel='A';
    
    -- // VALIDA SI EL TELEFONO ES VALIDO PARA COFETEL
    EXECUTE PROCEDURE "informix".sp_validatelefono(pEmpresa, pTelefono, pTelefono, pTelefono)
    INTO cCodRetValTel, cValCasa, cValCelular, cValOficina;
    
    IF cValCasa = '1' OR cValCelular = '1' OR cValOficina = '1' THEN
        LET cCofetel = 'V';
    ELSE
        LET cCofetel = 'F';
    END IF;
    
    -- // VALIDA EL TELEFONO EN TABLA DE TELEFONOS INVALIDOS
    SELECT COUNT(*)
      INTO iTelInvalido
      FROM "informix".si_telefonos_invalidos
     WHERE telefono = pTelefono;
     
    IF iTelInvalido > 0 THEN
        LET cCodRet1 = '104'; 
        RETURN cCodRet1;
    END IF;
    	
	
	-- //SI ES NUMERO FIJO VALIDA QUE NO EXCEDA EL LIMITE DE REGISTROS PERMITIDOS - LIPC
	IF pTipoTel = '1' THEN
		SELECT valor INTO sLimitNumFijo FROM "informix".si_param WHERE cod_param='462'; 
		SELECT COUNT(telefono) INTO sCoincideNumFijo FROM "informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel='1' AND status_tel='A' AND numcte != pNumCte;
			
		IF sCoincideNumFijo >= sLimitNumFijo THEN
			LET cCodRet1 = '1167'; 
			RETURN cCodRet1;
		END IF;
		
	END IF;
	
	SELECT valor INTO iValidaDias FROM "informix".si_param WHERE cod_param='542';
    SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiff FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;
	
    IF iDiasDiff<=iValidaDias THEN
        LET cCodRet1 = '1165'; 
        RETURN cCodRet1;
    END IF;

	--APR Validaciones RQM Mtto Telefonos --revisar porqeu s/verificdo = V puede traer el primero y sea cancelado
	--ya no estariamos aseguradno que sea el de un titular y Verificado
	SELECT first 1 numcte INTO sNumcte FROM "informix".si_telefonos 
		WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;
		--WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND numcte != pNumCte;		
	
	EXECUTE PROCEDURE bdinteg:cons_tipo_cte('001',sNumcte)
		   INTO CodRet, sTipoCte, sSecuencia;

	--RQM 10 1768 Inicio Bloque Comentado RQM Mtto Telefonos
	/*
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

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
		SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
		SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

		IF iDiasDiffTu<=iValidaDiasTu THEN
			LET iTelValidado = 1;
			LET cCodRet1 = '1168'; 
			RETURN cCodRet1;
		ELSE
			LET iTelValidado = 0;
		END IF;
	END IF;
	*/
	--RQM 10 1768 Fin Bloque Comentado RQM Mtto Telefonos

	--RQM 10 1768 Inicio RQM Mtto Telefonos
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		IF sTipoCte = '1' THEN	
			SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
			SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

			IF iDiasDiffTu<=iValidaDiasTu THEN
				LET iTelValidado = 1;
				LET cCodRet1 = '1168'; 
				RETURN cCodRet1;
			ELSE
				LET iTelValidado = 0;
			END IF;
		END IF;
	END IF;
	
	--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE (CONSIDERANDO CAMPO FECHA_ACTUALIZA) - LIPC
	IF pTipoTel = '2' THEN
		IF sTipoCte = '1' THEN	
			SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
			SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

			IF iDiasDiffTu<=iValidaDiasTu THEN
				LET iTelValidado = 1;
				LET cCodRet1 = '1168'; 
				RETURN cCodRet1;
			ELSE
				LET iTelValidado = 0;
			END IF;
		END IF;
	END IF;
	--RQM 10 1768 Fin RQM Mtto Telefonos
	
	
	--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iTelNoValidado
		FROM "informix".si_telefonos 
		WHERE telefono=pTelefono 
		AND tipo_tel='2' 
		AND status_tel='A' 
		AND verificado != 'V'
		AND numcte != pNumCte;
		   
		IF iTelNoValidado > 0 THEN
			LET cCodRet1 = '1166'; 
			--RETURN cCodRet1;
		END IF;
	END IF;
	
	--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
	IF pTipoTel = '2' THEN
		SELECT COUNT(telefono) INTO iRegistros
		FROM "informix".si_telefonos 
		WHERE numcte = pNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono
		AND status_tel = 'C'
		AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_telefonos WHERE numcte = pNumCte 
		AND tipo_tel = '2' 
		AND telefono = pTelefono);
			
		IF (iRegistros > 0 AND iTelValidado > 0) THEN
			LET cCodRet1 = '1169';
			RETURN cCodRet1;
		END IF;
	END IF;
	
    LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);
			
	SELECT COUNT(*) INTO iSucSMS FROM "informix".si_sucvalidasms WHERE sucursal=sSucursal AND activo='1';
    IF iSucSMS > 0 THEN

			--RQM 10 1768 Inicio Bloque Comentado RQM Mtto Telefonos
			/*			
        -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (PARAMETRO 384 SI_PARAM)
            SELECT valor INTO iDiasVerificado FROM "informix".si_param WHERE cod_param='541';
            SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasPeriodo FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;

            IF iDiasPeriodo<=iDiasVerificado THEN
                LET cCodRet1 = '1163'; 
                RETURN cCodRet1;
            END IF;
			
			--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
			IF pTipoTel = '2' THEN
				SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
				SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

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
				SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
				SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

				IF iDiasDiffTu<=iValidaDiasTu THEN
					LET iTelValidado = 1;
					LET cCodRet1 = '1168'; 
					RETURN cCodRet1;
				ELSE
					LET iTelValidado = 0;
				END IF;
			END IF;
			*/
			--RQM 10 1768 Fin Bloque Comentado RQM Mtto Telefonos			

		--RQM 10 1768 Inicio RQM Mtto Telefonos			
        -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (PARAMETRO 384 SI_PARAM)
            SELECT valor INTO iDiasVerificado FROM "informix".si_param WHERE cod_param='541';
			IF sTipoCte = '1' THEN	
				SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasPeriodo FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;

				IF iDiasPeriodo<=iDiasVerificado THEN
					LET cCodRet1 = '1163'; 
					RETURN cCodRet1;
				END IF;
			END IF;
			
			--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
			IF pTipoTel = '2' THEN
				IF sTipoCte = '1' THEN				
					SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
					SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

					IF iDiasDiffTu<=iValidaDiasTu THEN
						LET iTelValidado = 1;
						LET cCodRet1 = '1168'; 
						RETURN cCodRet1;
					ELSE
						LET iTelValidado = 0;
					END IF;
				END IF;
			END IF;
			
			--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE (CONSIDERANDO CAMPO FECHA_ACTUALIZA) - LIPC
			IF pTipoTel = '2' THEN
				IF sTipoCte = '1' THEN	
					SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='543';
					SELECT DATE(CURRENT) - DATE(MAX(fecha_actualiza)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

					IF iDiasDiffTu<=iValidaDiasTu THEN
						LET iTelValidado = 1;
						LET cCodRet1 = '1168'; 
						RETURN cCodRet1;
					ELSE
						LET iTelValidado = 0;
					END IF;
				END IF;
			END IF;
			--RQM 10 1768 Fin RQM Mtto Telefonos
			
			--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
			IF pTipoTel = '2' THEN
				SELECT COUNT(telefono) INTO iTelNoValidado
				FROM "informix".si_telefonos
				WHERE telefono=pTelefono 
				AND tipo_tel='2' 
				AND status_tel='A' 
				AND verificado != 'V'
				AND numcte != pNumCte;
			   
				IF iTelNoValidado > 0 THEN
					LET cCodRet1 = '1166'; 
					--RETURN cCodRet1;
				END IF;
			END IF;
			
			--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
			IF pTipoTel = '2' THEN
				SELECT COUNT(telefono) INTO iRegistros
				FROM "informix".si_telefonos 
				WHERE numcte = pNumCte 
				AND tipo_tel = '2' 
				AND telefono = pTelefono
				AND status_tel = 'C'
				AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_telefonos WHERE numcte = pNumCte 
				AND tipo_tel = '2' 
				AND telefono = pTelefono);
			
				IF (iRegistros > 0 AND iTelValidado > 0) THEN
					LET cCodRet1 = '1169';
					RETURN cCodRet1;
				END IF;
			END IF;
        

        -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
			SELECT COUNT(*) INTO iTelCta FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono and num_cte<>pNumCte;
            IF iTelCta > 0 THEN
                LET cCodRet1 = '1164'; 
                RETURN cCodRet1;
            END IF;
        -- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
    END IF;

    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO dFechaInsert
      FROM "informix".si_fechas
     WHERE empresa = pEmpresa;
	 
--  Valida Clientes Nivel 1
	/*IF pTipoTel = '2' THEN
		-- // VERIFICA SI EL NUMERO DE CLIENTE ES NIVEL 1
		SELECT COUNT(*)
		  INTO vCuentas1800
		  FROM bdinteg:"informix".si_cliente_nivel
		 WHERE numcte = pNumCte and nivel='1' and status = '1';
	   
		IF vCuentas1800=1 AND celularCli <> pTelefono THEN
			SELECT sucursal
				INTO vSuc
				FROM "informix".si_ejecut
				WHERE ejecutivo = pUserInsert;
			
			--EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','uamador@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			
			
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','kagarcia@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','arlopez@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','ecardenas@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','apardo@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','crgamez@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','alabra@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','jngarcia@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','rmadrigales@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:sp_registra_evento('1','CUB_EMAIL','INT_ACT_CEL','000000000','','','1',TRIM(pNumCte),TRIM(celularCli),TRIM(pTelefono),pUserInsert,vSuc,CURRENT,'','','','','imcervantes@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			
			
			LET cCodRet1 = '1167';
			-- INSERTAR DATOS EN TABLA DE BITACORA			
			INSERT INTO bdinteg:"informix".si_telefonos_pendientes
			(numcte, cel_ant, cel_nvo, tipo_cel, sucursal, fecha_hora, user_insert)
			VALUES
			(pNumCte, celularCli, pTelefono, pTipoTel, vSuc, current, pUserInsert);
					
			RETURN cCodRet1;
		END IF;
	END IF;*/
-- Termina validaciÃ?ÃÂ³n ciente Nivel 1
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO sMaxSecTel
      FROM "informix".si_telefonos
     WHERE numcte = pNumCte;
             
    IF sMaxSecTel is null OR sMaxSecTel = '' THEN
        LET sMaxSecTel = 0;
    END IF;
    
    LET sMaxSecTel = sMaxSecTel + 1;
	
		
	IF(cCodRet1 != '999') THEN
		UPDATE "informix".si_telefonos
		   SET status_tel = 'C'
		 WHERE numcte = pNumCte
		   AND tipo_tel = pTipoTel;
	END IF;
	
	
    -- // VERIFICA SI ES MOVIL O FIJO   
    EXECUTE PROCEDURE "informix".sp_tipored (pEmpresa, pTelefono) 
    INTO cResulFijoMovil, cDescFijoMovil, iFijoMovil;
    
    IF cDescFijoMovil = 'FIJO' THEN
        LET iFijoMovil = 0;
    ELIF cDescFijoMovil = 'MOVIL' THEN
        LET iFijoMovil = 1;
    ELSE
        LET iFijoMovil = 0;
    END IF;
    
    --// Valida si existe mas de un cliente con el mismo celular para enviarle sms
    FOREACH
        SELECT telefono,numcte INTO cTelval,vNumCteSMS FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND numcte<>pNumCte
        LET nrows = dbinfo("sqlca.sqlerrd2");
        IF(nrows > 0) THEN
            --EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','OFI_AVSMS','ACT_CEL',vNumCteSMS,'','','1','','','','','','','','','','','',pTelefono,1,0,0,0,0,'','') INTO cCodRetSp;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			EXIT FOREACH;
        END IF;
    END FOREACH;
    --//
	
	IF(cCodRet1 != '999') THEN
		INSERT INTO si_telefonos
		( empresa, numcte, telefono, tipo_tel, status_tel, secuencia, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel, verificado, marcatel, fecha_actualiza, tel_confirmado, fech_confirmado)
		VALUES
		( pEmpresa, pNumCte, pTelefono, pTipoTel, 'A', sMaxSecTel, pExtension, pCarrier, pCanal, sContacto, cCofetel, CURRENT, pUserInsert, iFijoMovil, '', cVerificado, vmarcatel, vfecha_actualiza, v_tel_confirmado, vfech_confirmado);
		
		IF (sMaxSecTel > 1 AND pTipoTel = 2 AND contTel>=1 AND celularCli <> pTelefono) THEN
			--EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,'','') INTO cCodRetSp2;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(pTelefono),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
			--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_registra_telefonos_cub', pTelefono,'Nuevo') INTO cCodRetSp2;--SPL de prueba

			IF (iNviejo > 0) THEN --EPG 021621
				--INFORMAMOS ACTUALIZACION DE TELEFONO SI TIENE UN TELEFONO VIEJO
				EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('2','CUB_SMS','SMS_TELCOR',TRIM(pNumCte),'','','1','','','','','','','','','','','',TRIM(celularCli),1,0,0,0,0,CURRENT,'') INTO cCodRetSp2;
				--EXECUTE PROCEDURE "informix".sp_registra_evento( 'sp_registra_telefonos_cub', celularCli,'Viejo') INTO cCodRetSp2; --SPL de prueba
			END IF;               --EPG 021621	
						
		END IF;
	
	ELSE
		LET cCodRet1 = '000';
	END IF;
	
    RETURN cCodRet1;
	
	END;
    
END PROCEDURE

DOCUMENT
'Modifico: Claudio Almodovar',
'Fecha: 19/04/2013',
'BDD: bdinteg',
'Descripcion: Llamado al sp_tipored para saber si es Fijo o Movil',
'             iFijoMovil = 0 - Si el telefono es Fijo',
'             iFijoMovil = 1 - Si el telefono es Movil',
'',
'Modifico: Rodolfo Tortolero Varela',
'Fecha: 10/06/2013',
'             Si cDescFijoMovil es "FIJO"  - iFijoMovil = 0 ',
'             Si cDescFijoMovil es "MOVIL" - iFijoMovil = 1 ',
'Modifico: Uriel Amador Islas',
'Fecha: 29/08/2023',
'DescripciÃ?ÃÂ³n: Se agregan envÃ?ÃÂ­o de notificaciÃ?ÃÂ³n a 2 personas mÃ?ÃÂ¡s',
"Usuario: Uriel Amador Islas",
"Modiicacion: Se comentan lÃÂ­neas de validacion de cliente nivel 1.",
"Fecha: 13/11/2023",
"Modificacion: Cambia al inicio del procedimiento para validar primero si el parametro del telefono de casa viene vacio y tomarlo como una cancelacion del telefono anterior, para cambiar",
"el estatus a C en la si_telefonos y borrarlos de la si_telefonos_actual",
"Fecha: 18/11/2025",
"Iniciativa: RQM 10 1697 Adendum Reparo de Auditoria",
"Usuario: NAVY";

CREATE PROCEDURE "informix".sp_altamasivaempnet_registra( pEmpresa CHAR(3), pNumCteMoral CHAR(20), pEjecutivo CHAR(8), pNomArchivo CHAR(30) )
RETURNING CHAR(5), CHAR(100);
    
    DEFINE iSqlErr				INTEGER;
    DEFINE iIsamErr				INTEGER;
    DEFINE iDescErr				CHAR(50);
    DEFINE cCodRet 				CHAR(5);
    DEFINE cCodRet2				CHAR(5);
    DEFINE cCodRet3				CHAR(50);
    DEFINE cCodRetRfc	        CHAR(6);
    DEFINE cCodRetCte	        CHAR(5);
    DEFINE cCodRetDir	        CHAR(5);
    DEFINE cCodRetCta	        CHAR(5);
    DEFINE cMensaje				VARCHAR(100);
    DEFINE iBegin				INTEGER;
    
    DEFINE dFechaHoy 			DATE;
    DEFINE iExiste				INTEGER;
    DEFINE cProducto 			CHAR(4);
    DEFINE cTipoPersona			CHAR(2);
    DEFINE cTipoCliente			CHAR(1);
    DEFINE cSucursal            CHAR(4);
    DEFINE cNumEmpresa			CHAR(3);
    DEFINE cNumEmpleado			CHAR(30);
    DEFINE cNombre1				CHAR(30);
    DEFINE cNombre2				CHAR(30);
    DEFINE cApellPatern			CHAR(30);
    DEFINE cApellMatern			CHAR(30);
    DEFINE cFecNac 				CHAR(8);
    DEFINE cRFC 				CHAR(13);
    DEFINE cSexo 				CHAR(1);
    DEFINE cTipoId              CHAR(1);
    DEFINE cNumId               CHAR(30);
    DEFINE cCalle               CHAR(30);
    DEFINE iNoExt               CHAR(10);
    DEFINE iNoInt               CHAR(10);
    DEFINE cColonia             CHAR(30);
    DEFINE cDelMun              CHAR(30);
    DEFINE cCiudad              CHAR(30);
    DEFINE cEstado              CHAR(30);
    DEFINE cCodPos              CHAR(10);
    DEFINE cPais                CHAR(4);
    DEFINE cRFCGenerado			CHAR(13);
    DEFINE cNumCliente			CHAR(20);
    DEFINE sSecuencia           SMALLINT;
    DEFINE vcCalle              CHAR(40);
    DEFINE vcColonia            CHAR(60);
    DEFINE vcMunicipio          CHAR(5);
    DEFINE vcEntreCalles        CHAR(40);
    DEFINE vcPais               CHAR(3);
    DEFINE vcEstado             CHAR(2);
    DEFINE vcCiudad             CHAR(3);
    DEFINE vcCod_post           CHAR(5);
    DEFINE vcTipoTel1           CHAR(1);
    DEFINE vcTel1               CHAR(13);
    DEFINE vcTipoTel2           CHAR(1);
    DEFINE vcTel2               CHAR(13);
    DEFINE vcTipoTel3           CHAR(1);
    DEFINE vcTel3               CHAR(13);
    DEFINE vcExtension          CHAR(5);
    DEFINE vcEdo_inegi          CHAR(2);
    DEFINE vcMuni_iegi          CHAR(3);
    DEFINE vcLocal_inegi        CHAR(4);
    DEFINE vsNumCiudad          SMALLINT;
    DEFINE vcNumExtCalle        CHAR(10);
    DEFINE vcNumIntCalle        CHAR(10);
    DEFINE vcDepto              CHAR(6);
    DEFINE viNumCalle           INTEGER;
    DEFINE viNumColonia         INTEGER;
    DEFINE vcPtoCardinal        CHAR(1);
    DEFINE vcUnidad_habit       CHAR(1);
	DEFINE vvnumcteenc          VARCHAR(20);
	DEFINE vvcurp 			    VARCHAR(20);
	DEFINE vvlistanegra			INTEGER;
    DEFINE vsManzana            SMALLINT;
    DEFINE vsOtros              SMALLINT;
    DEFINE vsAndador            SMALLINT;
    DEFINE vsEtapa              SMALLINT;
    DEFINE vsLote               SMALLINT;
    DEFINE vsEdificio           SMALLINT;
    DEFINE vsEntrada            SMALLINT;
    DEFINE vcObserva            CHAR(80);
    DEFINE cNumCuenta			CHAR(20);
    DEFINE cCtaClaBe 			CHAR(20);
    DEFINE viRegProcesados      INTEGER;
    DEFINE viRegxProcesar       INTEGER;
    DEFINE dFecNac              DATE;
    DEFINE cCuentaMoral         CHAR(20);
	DEFINE vvcuenta				VARCHAR(20);
    DEFINE vvstatus_cta			CHAR(1);
    DEFINE vvmarca_ret			CHAR(1);
    DEFINE vvnumeric1			INTEGER;
    DEFINE vvnumeric2			INTEGER;
	--CAMBIOS INICIATIVA CUENTA nomina
	DEFINE cProductoTemp 		CHAR(4);
	DEFINE cCodRetCtaNom	    CHAR(5);
	DEFINE vvstatus_ctaBl		CHAR(1);
        
    LET iSqlErr		= 0;
    LET iIsamErr	= 0;
    LET iDescErr	= '';
    LET cCodRet 	= '00000';
    LET cCodRet2 	= '';
    LET cCodRet3 	= '';
    LET cCodRetRfc	= '';
    LET cCodRetCte	= '';
    LET cCodRetDir	= '';
    LET cCodRetCta	= '';
    LET cMensaje    = '';
    LET iBegin      = 0;
    
    LET dFechaHoy       = '';
    LET iExiste	        = 0;
    LET cProducto       = '';
    LET cTipoPersona    = '';
    LET cTipoCliente    = '';
    LET cSucursal       = '';
    LET cNumEmpresa     = '';
    LET cNumEmpleado    = '';
    LET cNombre1        = '';
    LET cNombre2        = '';
    LET cApellPatern    = '';
    LET cApellMatern    = '';
    LET cFecNac         = '';
    LET cRFC            = '';
    LET cSexo           = '';
    LET cTipoId         = '';
    LET cNumId          = '';
    LET cCalle          = '';
    LET iNoExt          = '';
    LET iNoInt          = '';
    LET cColonia        = '';
    LET cDelMun         = '';
    LET cCiudad         = '';
    LET cEstado         = '';
    LET cCodPos         = '';
    LET cPais           = '';
    LET cRFCGenerado    = '';
    LET cNumCliente     = '';
    LET sSecuencia      = 0;
    LET vcCalle         = '';
    LET vcColonia       = '';
    LET vcMunicipio     = '';
    LET vcEntreCalles   = '';
    LET vcPais          = '';
    LET vcEstado        = '';
    LET vcCiudad        = '';
    LET vcCod_post      = '';
    LET vcTipoTel1      = '';
    LET vcTel1          = '';
    LET vcTipoTel2      = '';
    LET vcTel2          = '';
    LET vcTipoTel3      = '';
    LET vcTel3          = '';
    LET vcExtension     = '';
    LET vcEdo_inegi     = '';
    LET vcMuni_iegi     = '';
    LET vcLocal_inegi   = '';
    LET vsNumCiudad     = 0;
    LET vcNumExtCalle   = '';
    LET vcNumIntCalle   = '';
    LET vcDepto         = '';
    LET viNumCalle      = 0;
    LET viNumColonia    = 0;
    LET vcPtoCardinal   = '';
    LET vcUnidad_habit  = '';
    LET vsManzana       = 0;
    LET vsOtros         = 0;
    LET vsAndador       = 0;
    LET vsEtapa         = 0;
    LET vsLote          = 0;
    LET vsEdificio      = 0;
    LET vsEntrada       = 0;
    LET vcObserva       = '';
    LET cNumCuenta      = '';
    LET cCtaClaBe       = '';
    LET viRegProcesados = 0;
    LET viRegxProcesar  = 0;
    LET dFecNac         = '';
    LET cCuentaMoral    = '';
	LET vvnumcteenc     = '';
	LET vvcurp    		= '';
	LET vvlistanegra 	= 0;
	LET vvcuenta		= '';
	LET vvstatus_cta	= '';
	LET vvmarca_ret		= '';
	LET vvnumeric1		= '';
	LET vvnumeric2		= '';
	--CAMBIOS INICIATIVA CUENTA nomina
	LET cProductoTemp   = '1700';
	LET cCodRetCtaNom   = '';
	LET vvstatus_ctaBl  = '';
	--SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_registra.out";
    --TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, iDescErr
        --SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_altamasivaempnet_registra.err";
        --TRACE ON;
        IF iSqlErr != 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = iDescErr;
            LET cMensaje = 'OCURRIO UN ERROR NO CONTROLADO';
            IF iBegin = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, cMensaje;
        END IF;
    END EXCEPTION;


    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5; 
    
    -- // OBTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy 
      INTO dFechaHoy 
      FROM bdinteg:si_fechas 
     WHERE empresa = '001';
     
    -- // VALIDA REGISTROS A PROCESAR
    SELECT COUNT(*)
      INTO iExiste 
      FROM bdinteg:si_altamasivaempnet_ctrl 
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '1'; 

    IF iExiste IS NULL OR iExiste = '' OR iExiste = 0 THEN
        LET cCodRet = '00001';
        LET cMensaje = 'NO EXISTEN REGISTROS A PROCESAR';
        RETURN cCodRet, cMensaje;
    END IF;
    
    -- // VALIDA LA PERSONA MORAL
    SELECT COUNT(cte.numcte)
      INTO iExiste
      FROM bdinteg:si_cliente cte
     INNER JOIN bdinteg:si_tipper tpo ON cte.tpo_persona = tpo.tpo_persona
     WHERE cte.empresa = '001'
       AND cte.numcte = pNumCteMoral
       AND tpo.es_fisica = "N";
    
    IF iExiste = 0 THEN
        LET cCodRet = "00002";
        RETURN cCodRet, cMensaje;
    END IF;
    
    -- // OBTIENE PARAMETROS PARA EL ALTA
    SELECT TRIM(acepta_producto), cuenta
      INTO cProducto, cCuentaMoral
      FROM bdicheq:sc_nominaempresas 
     WHERE codigo = pEmpresa;
     
    SELECT tpo_persona 
      INTO cTipoPersona 
      FROM bdinteg:si_tipper 
     WHERE tpo_persona = '01';
     
    SELECT tipo_cliente 
      INTO cTipoCliente 
      FROM bdinteg:si_tipocte 
     WHERE empresa = '001' 
       AND tipo_cliente = 2;
       
    SELECT sucursal
      INTO cSucursal
      FROM bdicheq:sc_maechq
     WHERE empresa = '001'
       AND cuenta = cCuentaMoral;
       
    IF cSucursal is null OR cSucursal = '' THEN
        SELECT TRIM(valor) 
          INTO cSucursal 
          FROM bdicheq:sc_param 
         WHERE codparam = 'AMSUCURSAL' 
           AND empresa = '001';
    END IF;

    -- // VALIDA PARAMETROS ENCONTRADOS PARA EL ALTA
    IF cProducto IS NULL OR cTipoPersona IS NULL OR cTipoCliente IS NULL OR cSucursal IS NULL THEN
        LET cCodRet = '00002';
        LET cMensaje = 'NO SE OBTUVIERON LOS PARÃMETROS NECESARIOS';
        RETURN cCodRet, cMensaje;
    END IF;
    
    SELECT COUNT(*)
      INTO viRegxProcesar
      FROM bdinteg:si_altamasivaempnet_det
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '0';
    
    -- // CONSULTA LAS PETICIONES DE APERTURAS DE NÃMINA PARA QUE SEAN PROCESADAS
    FOREACH WITH HOLD
        SELECT cod_empresa, cve_cte, nombre1, nombre2, ape_pat, ape_mat, fecha_nac, rfc, genero, 
               tipo_id, num_id, calle, no_ext, no_int, colonia, del_mun, ciudad, estado, cod_pos, pais 
          INTO cNumEmpresa, cNumEmpleado, cNombre1, cNombre2, cApellPatern, cApellMatern, cFecNac, cRFC, cSexo, 
               cTipoId, cNumId, cCalle, iNoExt, iNoInt, cColonia, cDelMun, cCiudad, cEstado, cCodPos, cPais 
          FROM bdinteg:si_altamasivaempnet_det
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo
           AND status = '0'

        BEGIN WORK;
        LET iBegin = 1;
        
        LET dFecNac = SUBSTR(cFecNac,3,2)||SUBSTR(cFecNac,1,2)||SUBSTR(cFecNac,5,4);

		    LET vvnumcteenc   = '';
			LET vvcuenta      = '';
			LET vvstatus_cta  = '';
			LET cRFCGenerado  = '';
			LET cCodRetRfc    = '';
			LET vvcurp        = '';
			LET cNumCliente   = '';
			LET cNumCuenta    = '';
			LET cMensaje      = '';
			LET cRFC          = '';
			LET vvlistanegra  = 0;
			LET vvnumeric1    = 0;
			LET vvnumeric2	  = 0;
			LET vvmarca_ret	  = '';
			LET vvstatus_cta  = '';
			LET cCodRetCta	  = '';
			LET cCtaClaBe     = '';
			LET cCodRetCte	  = '';
			LET cCodRetDir    = '';
			LET cCodRetCtaNom = '';
			LET vvstatus_ctaBl= '';
        
        IF cNombre2 is null THEN
            LET cNombre2 = '';
        END IF;
        
        IF cApellMatern is null THEN
            LET cApellMatern = '';
        END IF;
        
        -- // CALCULA EL RFC
        CALL bdinteg:sp_calcularfc( '001', cApellPatern, cApellMatern, cNombre1, cNombre2, dFecNac ) 
        RETURNING cCodRetRfc, cMensaje, cRFCGenerado;
        
        IF cCodRetRfc <> '000000' THEN
            LET cCodRet = '00003';
            LET cMensaje = 'FALLÃ EN EL PROCESO AL INTENTAR LA GENERACIÃN DE RFC';
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
   
        -- // VALIDA QUE EL GENERADO SEA IGUAL AL QUE RECIBIMOS POR EL CLIENTE, SI NO SE TOMA EL QUE NOSOTROS GENERAMOS
        IF TRIM(cRFC) <> TRIM(cRFCGenerado) THEN
            LET cRFC = cRFCGenerado;
        END IF;
			
		     /*VALIDACIONES RQI 03 587*/
		--//VALIDA QUE EL RFC DEL CLIENTE NO EXISTA
		SELECT numcte INTO vvnumcteenc FROM bdinteg:si_cliente WHERE rfc =  cRFC;
		
		--//EN CASO DE EXISTIR EL RFC, SE VALIDA QUE EXISTA LA CURP
		IF (vvnumcteenc !='') THEN
		    --CAMBIO INICIATIVA CUENTA NOMINA
		    IF NVL(cProducto,'1700') = '2100' THEN
			    LET cProductoTemp = '2100';			END IF;
				SELECT curp INTO vvcurp FROM bdinteg:si_ctepf where numcte  = vvnumcteenc;
				/*SELECT A.cuenta, A.status_cta, A.marca_ret, B.numeric1, B.numeric2
						INTO vvcuenta, vvstatus_cta, vvmarca_ret, vvnumeric1, vvnumeric2
					FROM bdicheq:sc_maechq A INNER JOIN bdinteg:si_ctepf B ON (A.num_cte = B.numcte)
                            WHERE A.num_cte = vvnumcteenc
                              AND A.Producto = '1700';	*/
					--CAMBIO INICIATIVA CUENTA NOMINA
					FOREACH WITH HOLD--Se agrega foreach en caso de tener mas de una cuenta de este producto
				        SELECT A.cuenta, A.status_cta, A.marca_ret, B.numeric1, B.numeric2
						      INTO vvcuenta, vvstatus_cta, vvmarca_ret, vvnumeric1, vvnumeric2
					          FROM bdicheq:sc_maechq A INNER JOIN bdinteg:si_ctepf B ON (A.num_cte = B.numcte)
                              WHERE A.num_cte = vvnumcteenc
                              AND A.Producto = cProductoTemp
						
						IF nvl(vvstatus_cta,'')='1' THEN
						    exit foreach;
						ELIF vvstatus_cta='3' OR vvstatus_cta='4' THEN--se almacena en caso de tener cuenta bloqueada o inactiva
						   LET vvstatus_ctaBl = vvstatus_cta;
						END IF;
					END FOREACH;
		END IF;
		
		--//EN CASO DE EXISTIR LA CURP SE VALIDA QUE EL CLIENTE NO ESTE EN LA LISTA NEGRA PLD
		IF (vvcurp !='') THEN
				SELECT COUNT(*) INTO vvlistanegra FROM BDIAUDITOR:tbl_listainterna WHERE rfc = cRFC;
				
		END IF;
		--//EN CASO DE EXISTIR EN LA LISTA NEGRA
		IF (vvlistanegra >0) THEN
					LET cCodRet = "00002";
     				LET cMensaje = "El cliente tiene bloqueo PLD.";
					
		END IF;
			--//VALIDACIONES EN CASO DE QUE DEL CLIENTE TENGA UNA CUENTA 1700 o 2100		
		IF (vvcuenta != '') THEN	
				IF (vvnumeric1 = pEmpresa::INTEGER) THEN
						IF(vvnumeric2 = cNumEmpleado::INTEGER) THEN
								IF (vvstatus_cta = 1) THEN 
										LET cCodRet = "00002";
										LET cMensaje = "El cliente tiene cuenta asociada a esta empresa.";
							    END IF;
						END IF;
				END IF;
				EXECUTE PROCEDURE  "informix".sp_desasocia_ctapbn_emp(pEmpresa, cRFC, vvnumcteenc, vvcuenta)
					 INTO cCodRet, cMensaje, vvstatus_cta;
		END IF;
				
				   
	-----
		IF (vvnumcteenc = '') OR (vvnumcteenc IS NULL) THEN
        
							-- // ALTA DEL CLIENTE
							EXECUTE PROCEDURE ctefisico( '001',         --- empresa
														 'A',           --- tipo de funcion
														 '',            --- no. cliente
														 cSucursal,     --- sucursal
														 pEjecutivo,    --- ejecutivo
														 cTipoPersona,  --- tpo. persona
														 cTipoCliente,  --- tpo. cliente
														 cApellPatern,  --- apell. paterno
														 cApellMatern,  --- apell. materno
														 cNombre1,      --- nombre 1
														 cNombre2,      --- nombre 2
														 cRfc,          --- rfc
														 '32',          --- sector
														 '000',         --- segmento
														 '',            --- actividad
														 '000',         --- grupo
														 '000',         --- subgrupo
														 '1',           --- residencia
														 '',            --- apell casada
														 '',            --- no. cte ref
														 '01',          --- distrito
														 '',            --- puesto pol exp
														 '',            --- familiar pol exp
														 '00000000000', --- actividad esp
														 dFecNac,       --- fecha nac
														 '',            --- lugar nac
														 '001',         --- nacionalidad
														 '',            --- fm3
														 '',            --- edo civil
														 '',            --- regimen mat
														 '11',          --- profesion
														 cSexo,         --- sexo
														 '',            --- curp
														 cTipoId,       --- cod identificacion
														 cNumId,        --- no. identificacion
														 '',            --- no imss
														 0,             --- dependientes
														 '',            --- tutor
														 '',            --- email
														 '',            --- nom conyuge
														 '0',           --- seguro def
														 '',            --- escolaridad
														 'P',           --- habita en
														 0,             --- anios hanita
														 '',            --- nombre prop
														 0,             --- imp hip renta
														 '',            --- no. ife
														 '',            --- no. tutor
														 '',            --- no. conyuge
														 USER,          --- autoriza
														 '',            --- promocion
														 '' )           --- no. habitantes
							INTO cCodRetCte, cNumCliente;

							IF cCodRetCte <> '000' THEN
								LET cCodRet = "00005";
								LET cMensaje = "Error al dar de alta al cliente.";
								ROLLBACK WORK;
								LET iBegin = 0;
								CONTINUE FOREACH;
							END IF;
							
							-- // GUARDA DIRECCION DEL CLIENTE (TRABAJO)
							SELECT MAX(secuencia)
							  INTO sSecuencia
							  FROM bdinteg:si_direcciones_actual
							 WHERE numcte = pNumCteMoral;
							
							IF sSecuencia IS NULL THEN
								LET cCodRet = "00004";
								LET cMensaje = "No existe direcciÃ³n para el cliente moral indicado.";
								ROLLBACK WORK;
								LET iBegin = 0;
								CONTINUE FOREACH;
							END IF;
							
							SELECT dir.calle, dir.colonia, dir.municipio, dir.entre_calles, dir.pais, dir.estado, dir.ciudad, dir.cod_postal,
								   tel1.tipo_tel, tel1.telefono, tel2.tipo_tel, tel2.telefono, tel3.tipo_tel, tel3.telefono, tel3.extension,
								   dir.estado_inegi, dir.municipio_inegi, dir.localidad_inegi, dir.numerociudad, dir.numeroextcalle, dir.numerointcalle,
								   dir.departamento, dir.numerocalle, dir.numerocolonia, dir.puntocardinal, dir.unidadhabitac, dir.manzana,
								   dir.otros, dir.andador, dir.etapa, dir.lote, dir.edificio, dir.entrada, dir.observaciones
							  INTO vcCalle, vcColonia, vcMunicipio, vcEntreCalles, vcPais, vcEstado, vcCiudad, vcCod_post,
								   vcTipoTel1, vcTel1, vcTipoTel2, vcTel2, vcTipoTel3, vcTel3, vcExtension,
								   vcEdo_inegi, vcMuni_iegi, vcLocal_inegi, vsNumCiudad, vcNumExtCalle, vcNumIntCalle,
								   vcDepto, viNumCalle, viNumColonia, vcPtoCardinal, vcUnidad_habit, vsManzana,
								   vsOtros, vsAndador, vsEtapa, vsLote, vsEdificio, vsEntrada, vcObserva
							  FROM bdinteg:si_direcciones_actual dir
							  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel1 ON ( tel1.numcte = dir.numcte AND tel1.tipo_tel = 1 )
							  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel2 ON ( tel2.numcte = dir.numcte AND tel2.tipo_tel = 2 )
							  LEFT OUTER JOIN bdinteg:si_telefonos_actual tel3 ON ( tel3.numcte = dir.numcte AND tel3.tipo_tel = 3 )
							 WHERE dir.numcte = pNumCteMoral
							   AND dir.secuencia = sSecuencia;
							
							EXECUTE PROCEDURE direcciones( '001',           --- empresa
														   'A',             --- tpo funcion
														   cNumCliente,     --- no. cliente
														   0,               --- secuencia
														   "3",             --- tipo dir
														   vcCalle,         --- calle
														   vcColonia,       --- colonia
														   vcMunicipio,     --- municipio
														   vcEntreCalles,   --- entre calles
														   vcPais,          --- pais
														   vcEstado,        --- entidad
														   vcCiudad,        --- localidad
														   vcCod_post,      --- cod postal
														   vcTipoTel1,      --- tipo tel 1
														   vcTel1,          --- telefono 1
														   vcTipoTel2,      --- tipo tel 2
														   vcTel2,          --- telefono 2
														   vcTipoTel3,      --- tipo tel 3
														   vcTel3,          --- telefono 3
														   vcExtension,     --- extension
														   vcEdo_inegi,     --- edo inegi
														   vcMuni_iegi,     --- munic imegi
														   vcLocal_inegi,   --- localid inegi
														   vsNumCiudad,     --- no ciudad
														   vcNumExtCalle,   --- no ext calle
														   vcNumIntCalle,   --- no int calle
														   vcDepto,         --- depto
														   viNumCalle,      --- no calle
														   viNumColonia,    --- no colonia
														   vcPtoCardinal,   --- pto cardinal
														   vcUnidad_habit,  --- unidad hab
														   vsManzana,       --- manzana
														   vsOtros,         --- otros
														   vsAndador,       --- andador
														   vsEtapa,         --- etapa
														   vsLote,          --- lote
														   vsEdificio,      --- edificio
														   vsEntrada,       --- entrada
														   vcObserva,       --- observaciones
														   pejecutivo,      --- ejecutivo
														   dFechaHoy,       --- fecha alta
														   cSucursal )      --- sucursal
							INTO cCodRetDir;
							
							IF cCodRetDir <> '000' THEN
								LET cCodRet = "00006";
								LET cMensaje = "Error al registrar la direcciÃ³n del cliente.";
								ROLLBACK WORK;
								LET iBegin = 0;
								CONTINUE FOREACH;
							END IF;
							
							-- // GUARDA DIRECCION DEL CLIENTE (PERSONAL)
							INSERT INTO bdinteg:si_altamasivaempnet_dircte
							(numcte, calle, no_ext, no_int, colonia, del_mun, ciudad, estado, cod_pos, pais)
							VALUES
							(cNumCliente, cCalle, iNoExt, iNoInt, cColonia, cDelMun, cCiudad, cEstado, cCodPos, cPais);
					----    
		END IF;
        --CAMBIO INICIATIVA CUENTA NOMINA
		IF ((vvcuenta = '') OR (vvcuenta IS NULL) OR( vvstatus_cta !=1) AND TRIM(cProducto)<>'2100')
		OR ((vvcuenta = '') OR (vvcuenta IS NULL) OR( vvstatus_cta !=1 AND vvstatus_ctaBl !='3' AND vvstatus_ctaBl !='4') AND TRIM(cProducto)='2100')  THEN
		        IF NVL(cNumCliente,'') = '' THEN
				    LET cNumCliente = vvnumcteenc;
				END IF;
        -- // ALTA DE LA CUENTA DEL CLIENTE
		        IF trim(cProducto) <> '2100' THEN
						CALL bdicheq:cuenta2( '001',         --- empresa
											  pEjecutivo,    --- usuario
											  cSucursal,     --- sucursal
											  cProducto,     --- producto
											  cNumCliente,--- no cliente
											  '02',          --- no cotitular
											  '1',           --- clase cta
											  '3',           --- reg firmas
											  '001',         --- tipo banca
											  pEjecutivo,    --- ejecutivo
											  '1',           --- envio direcc
											  '',            --- cuenta
											  0,             --- direcc envio
											  '',            --- cliente 2
											  '',            --- nombre 
											  '',            --- instrucc cap
											  '',            --- cuenta cap
											  '',            --- instrucc int
											  '',            --- cuenta int
											  0,             --- plazo
											  'N',           --- cobra isr
											  '02',          --- proc apert cta
											  '02',          --- proce mant cta
											  '01',          --- monto mensual
											  '01',          --- cantidad dep
											  '01',          --- monto dep
											  '01',          --- cantidad ret
											  '01',          --- monto ret
											  '',            --- forma apert
											  0.00,          --- monto apert
											  cNumEmpresa,   --- no. empleado 
											  cNumEmpleado ) --- no. nomina
						RETURNING cCodRetCta, cNumCuenta, cCtaClaBe;
				ELSE
				--CAMBIO INICIATIVA CUENTA NOMINA
				        CALL bdicheq:cuenta1( '001',         --- empresa
											  pEjecutivo,    --- usuario
											  cSucursal,     --- sucursal
											  cProducto,     --- producto
											  cNumCliente,   --- no cliente
											  '01',          --- no cotitular
											  '1',           --- clase cta
											  '3',           --- reg firmas
											  '001',         --- tipo banca
											  pEjecutivo,    --- ejecutivo
											  '1',           --- envio direcc
											  '',            --- cuenta
											  0,             --- direcc envio
											  '',            --- cliente 2
											  '',            --- nombre 
											  '',            --- instrucc cap
											  '',            --- cuenta cap
											  '',            --- instrucc int
											  '',            --- cuenta int
											  0,             --- plazo
											  'N',           --- cobra isr
											  '02',          --- proc apert cta
											  '02',          --- proce mant cta
											  '01',          --- monto mensual
											  '01',          --- cantidad dep
											  '01',          --- monto dep
											  '01',          --- cantidad ret
											  '01',          --- monto ret
											  '',            --- forma apert
											  0.00)          --- monto apert
						RETURNING cCodRetCta, cNumCuenta, cCtaClaBe;
				
				END IF;
						
        END IF;
        IF cCodRetCta = '000' THEN
            UPDATE bdinteg:si_altamasivaempnet_det
               SET numcte = cNumCliente, 
                   cuenta = cNumCuenta,
                   status = '1'
             WHERE cod_empresa = pEmpresa
               AND cve_cte = cNumEmpleado
               AND nombre_archivo = pNomArchivo;
               
            UPDATE bdinteg:si_cliente
               SET string1 = "2"
             WHERE empresa = pEmpresa
               AND numcte = cNumCliente;
               
            UPDATE bdicheq:sc_maechq
               SET marca_ret = '1'
             WHERE num_cte = cNumCliente
               AND cuenta = cNumCuenta;
			   --CAMBIO INICIATIVA CUENTA NOMINA
			IF trim(cProducto) = '2100' THEN--Se genera el insert de beneficios de nomina
			    CALL bdiadminnomina:sp_sn_register_account(
				                                           cNumCliente,--NOCLIENTE
				                                           cNumCuenta,--NOCUENTA
				                                           1,----pEstatus
				                                           1,--pCuentaNomina
				                                           1,--pEstatusCuentaNomina
				                                           1,--pEmpresagc
				                                           1,--pGrupoBenef
				                                           0,--pPeriodicidad
				                                           5,--pTipoCliente
				                                           1,--pEstatusPeticionCliente
				                                           'EMPNET',--PROCESO
				                                           1)--OPCION
				RETURNING cCodRetCtaNom;
			END IF;
               
            COMMIT WORK;
            LET iBegin = 0;
        ELSE 
		--CAMBIO INICIATIVA CUENTA NOMINA
			IF (vvstatus_cta = 1) OR ((vvstatus_ctaBl ='3' OR vvstatus_ctaBl ='4') AND TRIM(cProducto)='2100') THEN 
					UPDATE bdinteg:si_altamasivaempnet_det
					   SET numcte = vvnumcteenc, 
						   status = '3'
					 WHERE cod_empresa = pEmpresa
					   AND cve_cte = cNumEmpleado
					   AND nombre_archivo = pNomArchivo;
					   COMMIT WORK;
					   LET iBegin = 0;
					   CONTINUE FOREACH;
			END IF;
			IF (vvlistanegra >0) THEN
				UPDATE bdinteg:si_altamasivaempnet_det
				   SET numcte = vvnumcteenc, 
					   status = '2'
				 WHERE cod_empresa = pEmpresa
				   AND cve_cte = cNumEmpleado
				   AND nombre_archivo = pNomArchivo;
					LET cCodRet = "00002";
     				LET cMensaje = "El cliente tiene bloqueo PLD.";
					COMMIT WORK;
					LET iBegin = 0;
					CONTINUE FOREACH;
		   END IF;
			
            ROLLBACK WORK;
            LET iBegin = 0;
            CONTINUE FOREACH;
        END IF;
    END FOREACH;
	
	IF iBegin = 1 THEN
	   ROLLBACK WORK;
	END IF;
    
    SELECT COUNT(*)
      INTO viRegProcesados
      FROM bdinteg:si_altamasivaempnet_det
     WHERE cod_empresa = pEmpresa
       AND nombre_archivo = pNomArchivo
       AND status = '1';
       
    IF viRegProcesados = 0 THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '2', --- NO SE PROCESO NINGUN CLIENTE
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = 0
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    ELIF viRegProcesados < viRegxProcesar THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '3', --- SE PROCESARON MENOS CLIENTES DEL TOTAL DEL ARCHIVO
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = viRegProcesados
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    ELIF viRegProcesados = viRegxProcesar THEN
        UPDATE bdinteg:si_altamasivaempnet_ctrl
           SET status = '4', --- SE PROCESARON TODOS LOS CLIENTES DEL ARCHIVO
               fecha_aplicado = dFechaHoy,
               hora_aplicado = CURRENT HOUR TO SECOND,
               registros_aplic = viRegxProcesar
         WHERE cod_empresa = pEmpresa
           AND nombre_archivo = pNomArchivo;
    END IF;
    
    RETURN cCodRet, cMensaje;
    
    END;
    
END PROCEDURE
DOCUMENT
'MODIFICO: Jose Mauricio Ramirez Zamudio',
'FECHA:  16/05/2025',
'BD:  bdinteg',
'DESCRIPCION: Se agrega producto 2100 al consultar cuentas del cliente, se limpian variables al inicio del foreach',
' se agrega sp cuenta1 para apertura de cuentas 2100, en caso de tener estatus 1,4,3 la cuenta existente 2100 no dara de alta una nueva cuenta 2100',
' se agrega ejecucion al sp sp_sn_register_account para en el caso de las nuevas cuentas 2100 generar insert en las tablas de la bd bdiadminnomina';

CREATE PROCEDURE "informix".sp_registra_correos_valcor( pEmpresa    CHAR(3),
														pNumCte     CHAR(20), 
														pCorreoElec CHAR(100),
														pTipoCorreo SMALLINT,
														pCanal      SMALLINT,
														pUserInsert CHAR(8),
														pStatusCode CHAR (3))
RETURNING CHAR(5) AS vcodret1;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vTpoPersona      CHAR(2);
    DEFINE vfecha_insert    DATE;
    DEFINE vSecuenciaMax    SMALLINT;
    DEFINE vExisteCorreo    SMALLINT;
    DEFINE vMaxSec          SMALLINT;
	DEFINE cValido			CHAR(1);
    DEFINE vCorreoNoValido  INTEGER;
	DEFINE contCorr         INTEGER;
	DEFINE cCodRetSp1       CHAR(5);
	DEFINE correoCli        CHAR(100);
	DEFINE vCuentas1800         INTEGER;
	DEFINE vSuc				CHAR(4);
	
    LET vcodret1 = '000';
    LET vcodret2 = '000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vTpoPersona   = '';
    LET vfecha_insert = '';
    LET vSecuenciaMax = 0;
    LET vExisteCorreo = 0;
    LET vMaxSec       = 0;
	LET cValido		  = '';
    LET vCorreoNoValido  = 0;
	LET contCorr         = 0;
	LET cCodRetSp1       = '00000';
	LET correoCli        ='';
	LET vCuentas1800          =0;
	LET vSuc			= '';
	
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        --SET DEBUG FILE TO "/resplogifx/conciliachq/sp_registra_correos.err";
        --TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-239)
        LET vcodret1 = '999';
        RETURN vcodret1;
    END EXCEPTION WITH RESUME;
    
    --SET DEBUG FILE TO "/RESPALDOSNEW/enrique/sp_registra_correos_valcor.out";
    --TRACE ON;
		
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR
       (pNumCte is null OR pNumCte = '') OR
       (pCorreoElec is null OR pCorreoElec = '') OR
       (pTipoCorreo is null OR pTipoCorreo = 0) OR
       (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET vcodret1 = '110';
        RETURN vcodret1;
    END IF;
    
	-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
	SELECT COUNT(id)
      INTO vCorreoNoValido
      FROM bdinteg:"informix".si_cat_correos_novalidos
     WHERE TRIM(correo) = TRIM(pCorreoElec);
	
	IF vCorreoNoValido > 0 THEN
        LET vcodret1 = '120';
        RETURN vcodret1;
    END IF;
	
	
    -- // VERIFICA SI EXISTE EL NUMERO DE CLIENTE
    SELECT tpo_persona, COUNT(*)
      INTO vTpoPersona, vExisteCte
      FROM bdinteg:"informix".si_cliente
     WHERE numcte = pNumCte
      GROUP BY 1;
     
    IF vExisteCte = 0 THEN
        LET vcodret1 = '104';
        RETURN vcodret1;
    END IF;
    
    
    -- // VERIFICA SI EXISTE EL CORREO PARA EL TIPO INDICADO
    /* #####################################################
    SELECT MAX(secuencia)
      INTO vSecuenciaMax
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo;
       
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo
       AND correo_elec = pCorreoElec
       AND secuencia = vSecuenciaMax;
    ##################################################### */
    
    SELECT COUNT(*)
      INTO vExisteCorreo
      FROM bdinteg:"informix".si_correos
     WHERE correo_elec = pCorreoElec
       AND status_correo = 'A';
       
    IF vExisteCorreo > 0 THEN
        LET vcodret1 = '999';
        RETURN vcodret1;
    END IF;
    
    -- // ONTIENE LA FECHA DEL SISTEMA
    SELECT fecha_hoy
      INTO vfecha_insert
      FROM bdinteg:"informix".si_fechas
     WHERE empresa = pEmpresa;
	
	SELECT correo_elec --Obtiene el correo antiguo que tenia el cliente
		INTO correoCli 
		FROM bdinteg:"informix".si_correos 
		WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';		
	SELECT COUNT(*) INTO contCorr FROM
	bdinteg:"informix".si_correos 
	WHERE numcte=pNumCte AND tipo_correo=1 AND status_correo='A';

--  Valida Clientes Nivel 1
    -- // VERIFICA SI EL NUMERO DE CLIENTE ES NIVEL 1
    /*SELECT COUNT(*)
      INTO vCuentas1800
      FROM bdinteg:"informix".si_cliente_nivel
     WHERE numcte = pNumCte and nivel='1' and status = '1';
   
	IF vCuentas1800=1 THEN
		SELECT sucursal
			INTO vSuc
			FROM "informix".si_ejecut
			WHERE ejecutivo = pUserInsert;
			
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','kagarcia@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','arlopez@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','ecardenas@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','apardo@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','crgamez@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','alabra@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','jngarcia@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','rmadrigales@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','INT_ACT_EM','000000000','','','1',TRIM(pNumCte),TRIM(correoCli),TRIM(pCorreoElec),pUserInsert,vSuc,CURRENT,'','','','','imcervantes@bancoppel.com','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1;
		
		LET vcodret1 = '120';
		
		-- INSERTAR DATOS EN TABLA DE BITACORA
		INSERT INTO bdinteg:"informix".si_correos_pendientes
		(numcte, correo_ant, correo_nvo, tipo_correo, sucursal, fecha_hora, user_insert)
		VALUES
		(pNumCte, correoCli, pCorreoElec, pTipoCorreo, vSuc, current, pUserInsert);
				
		RETURN vcodret1;
	END IF;*/
-- Termina validaciÃÂÃÂ³n ciente Nivel 1	
    
    -- // INSERTA EN TABLA DE TELEFONOS
    SELECT MAX(secuencia)
      INTO vMaxSec
      FROM bdinteg:"informix".si_correos
     WHERE numcte = pNumCte;
             
    IF vMaxSec is null OR vMaxSec = '' THEN
        LET vMaxSec = 0;
    END IF;
    
    LET vMaxSec = vMaxSec + 1;
    
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(correoCli),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION AL CORREO ANTERIOR
	END IF;
	
    UPDATE bdinteg:"informix".si_correos
       SET status_correo = 'C'
     WHERE numcte = pNumCte
       AND tipo_correo = pTipoCorreo;
	   
	IF pStatusCode IN ("200","210","220") THEN
		LET cValido = '1';
	ELSE 
		LET cValido = '0';
		
	END IF;
	   
	IF pStatusCode = '-1' THEN -- Se presento un error al consultar el servicio strikeiron, no se registran datos de validacion
		INSERT INTO bdinteg:"informix".si_correos
		(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert)
		VALUES
		(pEmpresa, pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert);
	ELSE
		INSERT INTO bdinteg:"informix".si_correos
		(empresa, numcte, correo_elec, tipo_correo, status_correo, secuencia, canal, fecha_hora, user_insert,valida_correo,valido,fecha_valida)
		VALUES
		(pEmpresa, pNumCte, pCorreoElec, pTipoCorreo, 'A', vMaxSec, pCanal, current, pUserInsert,pStatusCode,cValido,current);
	END IF;

	
	IF (vMaxSec > 1 AND contCorr >=1 AND pTipoCorreo= 1) THEN
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','CUB_EMAIL','NOT_ACT_EM',TRIM(pNumCte),'','','1','',TRIM(correoCli),'',TRIM(pCorreoElec),'','','','','','',TRIM(pCorreoElec),'',1,0,0,0,0,CURRENT,'') INTO cCodRetSp1; ------- NOTIFICACION DE NUEVO DE CORREO
	END IF;
    
    END;

    RETURN vcodret1;

END PROCEDURE
DOCUMENT
"Modificacion: Se crea copia de procedimiento almacenado para guardar respuesta de el web service Strike Iron.",
"Sustento: RQI 63 044 - Valida Correo Alta Clientes Bancoppel.pdf",
"Solicita: Jaime GonzÃÂÃÂÃÂÃÂÃÂÃÂÃÂÃÂ¡lez Prado",
"Modiicacion: Se agregan cuantas de correo para notificar intento de actualizacion.",
"Fecha: 26/10/2023",
"Usuario: Uriel Amador Islas",
"Modiicacion: Se comentan lÃ­neas de validacion de cliente nivel 1.",
"Fecha: 13/11/2023",
"Usuario: Uriel Amador Islas",
"BD: bdinteg";

CREATE PROCEDURE "informix".sp_registrardatoscontacto_tels(
    cEmpresa			CHAR(3),
    cNumCte				CHAR(20), 
    cCorreoElecronico	CHAR(100),
    cTelefonoCasa		CHAR(13),
    cTelefonoCelular	CHAR(13),
    iCanal				SMALLINT,
    cUserInsert			CHAR(8))

RETURNING   CHAR(5) AS cCodRet;

    DEFINE iSqlErr INTEGER;
    DEFINE vCodRet CHAR(5);
    DEFINE cStatusCode CHAR(3);
    DEFINE vExisteCorreo SMALLINT;
    
    LET iSqlErr = 0;
    LET vCodRet	= '00000';
    LET vExisteCorreo = 0;

    BEGIN
        -- // MANEJO DE EXCEPCIONES
        ON EXCEPTION
            SET iSqlErr
            IF iSqlErr <> 0 THEN
                    LET vCodRet = iSqlErr;
                    RETURN vCodRet;
            END IF;
        END EXCEPTION;
    
        --SET DEBUG FILE TO "/resplogifx/conciliachq/registrarDatosContacto.err";
		--SET DEBUG FILE TO "/pisa/pisabanco/sp_registrardatoscontacto_tels.out";
        --TRACE ON;
    
        SET LOCK MODE TO WAIT 3;
        SET ISOLATION TO DIRTY READ;
    
        IF vCodRet = '00000' THEN
            --Telefono celular
            --EXECUTE PROCEDURE sp_registra_telefonos(cEmpresa, cNumCte, cTelefonoCelular, 2, '',
            --    1, iCanal, cUserInsert) INTO vCodRet;
			--RQM 10 1768 Mantto tels
            EXECUTE PROCEDURE sp_registra_telefonos_tels(cEmpresa, cNumCte, cTelefonoCelular, 2, '',
                1, iCanal, cUserInsert) INTO vCodRet;
    
            IF vCodRet = '999' OR vCodRet = '000' OR vCodRet = '220' THEN
                LET vCodRet = '00000';
            END IF;
        END IF;
    
        IF vCodRet = '00000' THEN
            --Telefono de casa
            EXECUTE PROCEDURE sp_registra_telefonos_tels(
                cEmpresa, cNumCte, cTelefonoCasa, 1, '',
                0, iCanal, cUserInsert) 
                INTO vCodRet;
    
            --'Realiza actualizaciÃÂ³n del telefono'
            IF vCodRet = '999' OR vCodRet = '000' OR vCodRet = '220' THEN
                LET vCodRet = '00000';
            END IF;
        END IF;
    
        --if vcodret1 = '000' and pCorreoElec is not null and pCorreoElec <> '' then
        IF vCodRet = '00000' AND cCorreoElecronico <> '' THEN
            --OK
            LET cStatusCode = '000';
            EXECUTE PROCEDURE sp_registra_correos_valcor(
                cEmpresa, cNumCte, cCorreoElecronico, 1, iCanal,
                cUserInsert, cStatusCode) 
                INTO vCodRet;
    
            --Para este escenario, el correo es el mismo, tener cuidado porque maneja excepcion con 999
            --pero descartar severidad porque solo inserta el SP anterior
		ELSE 
		    IF cCorreoElecronico = '' THEN
                --CUENTA SI EL CLIENTE TIENE CORREO EN LA TABLA CON ESTATUS "A" PARA CAMBIARLE EL ESTATUS A "C" AEEC
                SELECT COUNT(*)
                INTO vExisteCorreo
                FROM bdinteg:"informix".si_correos
                WHERE numcte = cNumCte
                AND status_correo = 'A';
                
                --VALIDA SI EL CLIENTE TIENE REGISTROS A LOS CUALES HACERLES LA ACTUALIZACION DEL ESTATUS, DE LO CONTRARIO NO ES NECESARIO EJECUTAR EL UPDATE   AEEC
                IF vExisteCorreo > 0 THEN
                    UPDATE bdinteg:"informix".si_correos
                    SET status_correo = 'C'
                    WHERE numcte = cNumCte
                    AND tipo_correo = 1;
                END IF;
                --CODIGO DE RETORNO PARA EL CASO DONDE VENGA VACIO EL CORREO ELECTRONICO Y SE TOME COMO CANCELACION  AEEC
                LET vCodRet = '220';
            END IF;
        END IF;
		IF vCodRet = '999' OR vCodRet = '000' OR vCodRet = '220' THEN
			LET vCodRet = '00000';
		END IF;
		RETURN vCodRet;
    END;
    
END PROCEDURE
DOCUMENT
'FOLIO: 868 RQM 18 159 - 2 OptimizaciÃÂ³n de Clientes y ContrataciÃÂ³n de Productos',
'Descripcion: CreaciÃÂ³n de procedure para el guardado de los datos de telefono y correo electronico, Codigo de retorno 000 OK cualquier otro codigo es un error',
'AUTOR: 98021080 - Hiram Ramirez',
'Fecha: 17/10/2022',
'BDD: bdinteg',
"Modificacion: Cambia el procedimiento para validar primero si el parametro del telefono de casa viene vacio y tomarlo como una cancelacion del telefono anterior y se ejecute el procedimiento sp_registra_telefonos_tels",
"Fecha: 18/11/2025",
"Iniciativa: RQM 10 1697 Adendum Reparos de Auditoria",
"Usuario: NAVY",
"Modificacion: Cambia el procedimiento para validar primero si el parametro del correo viene vacio y tomarlo como una cancelacion del correo anterior y se ejecute el procedimiento sp_registra_correos_valcor",
"Fecha: 18/11/2025",
"Iniciativa: RQM 10 1697 Adendum Reparos de Auditoria",
"Usuario: AEEC";

CREATE PROCEDURE "informix".sp_actualiza_estado_au(
    pLugar_nac CHAR(2),
    pNumcte    CHAR(20)
)
RETURNING CHAR(5);

    DEFINE cCodret CHAR(5);
    DEFINE iSqlErr INTEGER;

    LET cCodret = "0005";
	
	--SET DEBUG FILE TO "/informix/sp_actualiza_estado_au.out";
	--TRACE ON;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
                RETURN "99999"; -- cÃ³digo  de error
            END IF;
        END EXCEPTION;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 5;

        -- ValidaciÃ³n de parÃ¡metro
        IF pNumcte IS NULL OR TRIM(pNumcte) = "" THEN
            LET cCodret = "00104";
            RETURN cCodret;
        END IF;

        -- ActualizaciÃ³n
        UPDATE bdinteg:"informix".si_ctepf
           SET lugar_nac = pLugar_nac
         WHERE numcte    = pNumcte;

        IF SQLCODE <> 0 THEN
            LET cCodret = "00999"; -- error en update
        END IF;

        RETURN cCodret;

    END;

END PROCEDURE
DOCUMENT
'SCRIPT DE PROCEDIMIENTO ALMACENADO "sp_actualiza_estado"',
'Folio.........: RQM 10 1697-2 Adendum: Reparos de AuditorÃ­a.',
'Autor.........: 99806221 - Juan Pablo Marin Rincon',
'Fecha.........: 15/10/2025',
'Solicita......: Fernando Rojas/David Garcia',
'BD............: bdinteg';

CREATE PROCEDURE "informix".sp_consulta_huella_actual(pNumcte CHAR(20))

RETURNING CHAR(5)       AS  cCodRet,
		  LVARCHAR(942) AS  cTemplate1,
		  LVARCHAR(942) AS  cTemplate2,
		  LVARCHAR(942) AS  cTemplate3,
		  LVARCHAR(942) AS  cTemplate4,
		  LVARCHAR(942) AS  cTemplate5,
		  LVARCHAR(942) AS  cTemplate6,
		  LVARCHAR(942) AS  cTemplate7,
		  LVARCHAR(942) AS  cTemplate8,
		  LVARCHAR(942) AS  cTemplate9,
		  LVARCHAR(942) AS  cTemplate10,
		  SMALLINT      AS sNfiq1,
		  SMALLINT      AS sNfiq2, 
		  SMALLINT      AS sNfiq3, 
		  SMALLINT      AS sNfiq4, 
		  SMALLINT      AS sNfiq5, 
		  SMALLINT      AS sNfiq6, 
		  SMALLINT      AS sNfiq7, 
		  SMALLINT      AS sNfiq8, 
		  SMALLINT      AS sNfiq9, 
		  SMALLINT      AS sNfiq10,
		  SMALLINT      AS sMinucias1,
          SMALLINT      AS sMinucias2,
          SMALLINT      AS sMinucias3,
          SMALLINT      AS sMinucias4,
          SMALLINT      AS sMinucias5,
          SMALLINT      AS sMinucias6,
          SMALLINT      AS sMinucias7,
		  SMALLINT      AS sMinucias8,
		  SMALLINT      AS sMinucias9,
		  SMALLINT      AS sMinucias10,
		  SMALLINT      AS sSecuencia;
	 	
		--DEFINICION DE VARIABLES
		 DEFINE cCodRet 	 CHAR(5);
		 DEFINE cTemplate1   LVARCHAR(942);
		 DEFINE cTemplate2   LVARCHAR(942);
		 DEFINE cTemplate3   LVARCHAR(942);
		 DEFINE cTemplate4   LVARCHAR(942);
		 DEFINE cTemplate5   LVARCHAR(942);
		 DEFINE cTemplate6   LVARCHAR(942);
		 DEFINE cTemplate7   LVARCHAR(942);
		 DEFINE cTemplate8   LVARCHAR(942);
		 DEFINE cTemplate9   LVARCHAR(942);
         DEFINE cTemplate10  LVARCHAR(942);
		 DEFINE tampNumCte   CHAR(2);
		 DEFINE iSqlErr      INTEGER;
		 DEFINE i            INTEGER;
		 DEFINE cId_template SMALLINT;
		 DEFINE cTemplate    LVARCHAR(942);
		 DEFINE sNfiq        SMALLINT;
		 DEFINE sMinucias    SMALLINT;
		 
		 DEFINE sNfiq1       SMALLINT;
		 DEFINE sNfiq2       SMALLINT;
		 DEFINE sNfiq3       SMALLINT;
		 DEFINE sNfiq4       SMALLINT;
		 DEFINE sNfiq5       SMALLINT;
		 DEFINE sNfiq6       SMALLINT;
		 DEFINE sNfiq7       SMALLINT;
		 DEFINE sNfiq8       SMALLINT;
		 DEFINE sNfiq9       SMALLINT;
		 DEFINE sNfiq10      SMALLINT;
		 
		 DEFINE sMinucias1   SMALLINT;
		 DEFINE sMinucias2   SMALLINT;
		 DEFINE sMinucias3   SMALLINT;
		 DEFINE sMinucias4   SMALLINT;
		 DEFINE sMinucias5   SMALLINT;
		 DEFINE sMinucias6   SMALLINT;
		 DEFINE sMinucias7   SMALLINT;
		 DEFINE sMinucias8   SMALLINT;
		 DEFINE sMinucias9   SMALLINT;
		 DEFINE sMinucias10  SMALLINT;
		 
		 DEFINE sSecuencia   SMALLINT;	 
		 
		 LET cCodRet      = '00000';
		 LET cTemplate1   = '';
		 LET cTemplate2   = '';
		 LET cTemplate3   = '';
		 LET cTemplate4   = '';
		 LET cTemplate5   = '';
		 LET cTemplate6   = '';
		 LET cTemplate7   = '';
		 LET cTemplate8   = '';
		 LET cTemplate9   = '';
         LET cTemplate10  = '';
		 LET tampNumCte   = LENGTH(pNumcte);
		 LET iSqlErr      = 0;
		 LET i            = 0;
		 LET cId_template = 0;
		 LET cTemplate    = '';
		 LET sNfiq        = 0;
		 
		 LET sNfiq1  = 0;
		 LET sNfiq2  = 0;
		 LET sNfiq3  = 0;
		 LET sNfiq4  = 0;
		 LET sNfiq5  = 0;
		 LET sNfiq6  = 0;
		 LET sNfiq7  = 0;
		 LET sNfiq8  = 0;
		 LET sNfiq9  = 0;
		 LET sNfiq10 = 0;
		 
		 LET sMinucias1 = 0; 
		 LET sMinucias2 = 0; 
		 LET sMinucias3 = 0; 
		 LET sMinucias4 = 0; 
		 LET sMinucias5 = 0; 
		 LET sMinucias6 = 0; 
		 LET sMinucias7 = 0; 
		 LET sMinucias8 = 0; 
		 LET sMinucias9 = 0; 
		 LET sMinucias10 = 0;
		 
		 LET sSecuencia = 0;
		 
BEGIN
   ON EXCEPTION SET iSqlErr
      IF iSqlErr !=0 THEN
		RETURN TRIM (isqlerr),cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
	  END IF
	
   END EXCEPTION
	
   SET LOCK MODE TO WAIT 3;
   SET ISOLATION TO DIRTY READ;
	
   --SET DEBUG FILE TO '/home/sysifx/Brms/sp_consulta_huella_actual.out';
   --TRACE ON;
	
    --VALIDAR DATOS VACIOS
    IF NVL(pNumcte,'') = '' THEN
       LET cCodRet = '00001'; 
       RETURN cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
    ELSE
       IF (tampNumCte < 9) THEN
          LET pNumcte = to_char(pNumcte, '&&&&&&&&&');
       END IF;
		
       FOREACH
          SELECT id_template,template,nfiq,minucias,secuencia 
          INTO cId_template,cTemplate, sNfiq, sMinucias, sSecuencia
          FROM si_cte_huella_dec_actual 
          WHERE numcte = pNumcte
          ORDER BY id_template ASC
			
          IF (i = 0) THEN
             LET cTemplate1 = cTemplate;
             LET sNfiq1 = sNfiq;
             LET sMinucias1 = sMinucias;
          END IF;
				
          IF (i = 1) THEN
             LET cTemplate2 = cTemplate;
             LET sNfiq2 = sNfiq;
             LET sMinucias2 = sMinucias;
          END IF;
				
          IF (i = 2) THEN
             LET cTemplate3 = cTemplate;
             LET sNfiq3 = sNfiq;
             LET sMinucias3 = sMinucias;
          END IF;
						
          IF (i = 3) THEN
             LET cTemplate4 = cTemplate;
             LET sNfiq4 = sNfiq;
             LET sMinucias4 = sMinucias;
          END IF;
				
          IF (i = 4) THEN
             LET cTemplate5 = cTemplate;
             LET sNfiq5 = sNfiq;
             LET sMinucias5 = sMinucias;
          END IF;	
				
          IF (i = 5) THEN
             LET cTemplate6 = cTemplate;
             LET sNfiq6 = sNfiq;
             LET sMinucias6 = sMinucias;
          END IF;
				
          IF (i = 6) THEN
             LET cTemplate7 = cTemplate;
             LET sNfiq7 = sNfiq;
             LET sMinucias7 = sMinucias;
          END IF;
					 
          IF (i = 7) THEN
             LET cTemplate8 = cTemplate;
             LET sNfiq8 = sNfiq;
             LET sMinucias8 = sMinucias;
          END IF;
						
          IF (i = 8) THEN
             LET cTemplate9 = cTemplate;
             LET sNfiq9 = sNfiq;
             LET sMinucias9 = sMinucias;
         END IF;
				
         IF (i = 9) THEN
            LET cTemplate10 = cTemplate;
            LET sNfiq10 = sNfiq;
            LET sMinucias10 = sMinucias;
         END IF;	
			
         LET i = i + 1;
      END FOREACH;		
    END IF;

   IF dbinfo('sqlca.sqlerrd2') = 0 THEN
      LET cCodRet= '00002';
   END IF;	
	
   RETURN  cCodRet,cTemplate1,cTemplate2,cTemplate3,cTemplate4,cTemplate5,cTemplate6,cTemplate7,cTemplate8,cTemplate9,cTemplate10,sNfiq1,sNfiq2,sNfiq3,sNfiq4,sNfiq5,sNfiq6,sNfiq7,sNfiq8,sNfiq9,sNfiq10,sMinucias1,sMinucias2,sMinucias3,sMinucias4,sMinucias5,sMinucias6,sMinucias7,sMinucias8,sMinucias9,sMinucias10,sSecuencia;
END

END PROCEDURE
DOCUMENT
'Creacion: Aracely UreÃÂ±a',
'BD: bdinteg',
'Descripcion: Se crea sp para consulta de huellas actuales de cliente, 10 huellas',
'Peticion: 399 - Implementacion 442 para verificacion y enrolamiento ';

CREATE PROCEDURE "informix".sp_limite_max(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20),
										  pfolsuc      char(16),
										  preferencia  char(40))
RETURNING CHAR(5), CHAR (80), CHAR(1);

--SP limite_max sobrecargado para requerimiento normativo CUB RQI 62 991 Modificaciones a bdinteg sp_limite_max

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);
	--DEFINE vCodret2     	    CHAR(3);

    DEFINE vMtoacumcta          DECIMAL(16,2);
    DEFINE vLim_canal_pesos     DECIMAL(16,2);
    DEFINE vExiste              INTEGER;
    DEFINE vTipo_mensaje        CHAR(2);
    DEFINE vRestriccion         CHAR(2);
    DEFINE vMax_pesos           DECIMAL(16,2);
    DEFINE vMensaje1            CHAR (80);
    DEFINE vEnviar              CHAR(1);
    DEFINE vEmpresa             CHAR(3);
    DEFINE vEmail               CHAR(80);
    DEFINE vCorreoElec          CHAR(100); -- se agrega por la reingenieria
    DEFINE vNombre              CHAR(104);
    DEFINE vIndicador           CHAR(1);
    DEFINE vImporte             DECIMAL(16,2);
    DEFINE vEnviarMensaje       CHAR(60);
	DEFINE vOperacion           CHAR(2);   -- BGM SE DECLARA VARIABLE DE VOPERACION
    DEFINE Vtipo_tarjeta        CHAR(20);  -- RRG TIPO DE TARJETA TITULAR O ADICIONAL
	DEFINE vImporte2            CHAR(16);
	DEFINE vMontoTotal			CHAR(16);

	DEFINE vActivar_Limite      CHAR(100);
	DEFINE vCod_param           SMALLINT;
	DEFINE vMensaje2            CHAR (80);

	DEFINE v_fecha1             CHAR(200);
	DEFINE v_fecha              CHAR(06);
	DEFINE v_ano_wk             CHAR(04);
	DEFINE v_longitud           INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_cuenta				INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_subcadena			CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_mail_incorrecto	CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico

    DEFINE vExisteCta           SMALLINT;
    DEFINE vSistema             CHAR(2);
    DEFINE vSist                CHAR(2);

    DEFINE vTipoCorreo      	SMALLINT;
    DEFINE vStatusCorreo    	CHAR(1);
	
    DEFINE vsidmensaje 			CHAR(10);

	DEFINE vMax_pesos1 			DECIMAL(16,2);
	DEFINE vMax_pesos2 			DECIMAL(16,2);
	DEFINE vlimite_personalizado_rest1 SMALLINT;
	DEFINE vlimite_personalizado_rest2 SMALLINT;
	
	DEFINE vMax_pesosAC         DECIMAL(16,2);
	DEFINE vEnviarMensajeAC     CHAR(60);
	DEFINE vTipo_mensajeAC      CHAR(2);
	DEFINE vsidmensajeAC		CHAR(10);
	DEFINE vCambioPlantilla  	CHAR(1);
	DEFINE cRet					CHAR(5);
	DEFINE vValorUdi			DECIMAL(14,6);
	DEFINE vfecha				DATE;
	
	DEFINE cLugar_oper          CHAR(40);
	DEFINE cFolio_suc           CHAR(16);
	DEFINE cDescOper			CHAR(40);
	DEFINE cDescTar 			CHAR(40);
	DEFINE cReferencia          CHAR(40);
	DEFINE cfolsuc CHAR(16);
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_limite_max.out';
	--TRACE ON; 
-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';
	--LET vCodret2  = '000';

    LET vMtoacumcta         = 0.00;
    LET vLim_canal_pesos    = 0.00;
    LET vExiste             = 0;
    LET vTipo_mensaje       = '';
    LET vRestriccion        = '';
    LET vMax_pesos          = 0.00;
    LET vMensaje1           = 'El proceso concluyo exitosamente';
    LET vEnviar             = '';
    LET vEmpresa            = '001';
    LET vEmail              = '';
    LET vCorreoElec         = '';   -- se agrega por la reingenieria
    LET vNombre             = '';
    LET vIndicador          = '0';
    LET vImporte            = 0.00;
    LET vEnviarMensaje      = '';
	LET vImporte2			= '';
	LET vMontoTotal			= '';

    LET vActivar_Limite     = '';
    LET vCod_param          = 110;
    LET vMensaje2           = 'Validacion Inactiva';

    LET v_ano_wk            = YEAR(TODAY);
    LET v_ano_wk            = v_ano_wk[3,4];

    LET v_fecha             = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
	LET v_longitud          = 0;    -- BGM 31-08-2010 Variable para validacion de correo electronico
	LET v_cuenta            = 1;    -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_subcadena         = '';   -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_mail_incorrecto   = 'F';  -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET Vtipo_tarjeta       = '';   -- RRG 07-11-2011 Variable para tipo de tarjeta Titular o Adicional

    LET vExisteCta          = 0;
    LET vSistema            = '';

    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';
	
	LET vMax_pesos1=0.00; --Variable para limites EmpresaNetPlus restriccion 01
	LET vMax_pesos2=0.00; --Variable para limites EmpresaNetPlus restriccion 02
	LET vlimite_personalizado_rest1=0;
	LET vlimite_personalizado_rest2=0;
	
	LET vMax_pesosAC        = 0.00;
	LET vEnviarMensajeAC    = '';
	LET vTipo_mensajeAC     = '';
    LET vsidmensajeAC	    = '';
	LET vCambioPlantilla	= 'F';
	LET cRet				= '';
	LET vValorUdi			= 0.00;
	LET vfecha				= DATE(1);
	
	LET cLugar_oper = '';
    LET cFolio_suc = '';
	LET cDescOper= '';
	LET cDescTar = '';
	LET cReferencia = '';
	LET cfolsuc = '';

    --**************************************************************
     -- Creado por Raul Ramirez    01/Jul/2010
     -- Capitulo X Acumulado Diario y Preparacion para el envio de Mensaje
     -- Modificado el 03/03/2011, Se modifica el sp para envio de mensaje
     -- con informacion en particular para credito y debito, de transacciones
     -- realizadas en ATM y POS.
     -- Modificado el 17/01/2011, Se agrega el numero de tarjeta y el tipo
     -- para el armado del envio de mensaje.
     -- Se modifica el proceso por la reigenieria del Correo Electronico 26/03/12
	 
	 --Modificacion: para que consulte la tabla nueva de limites por empresa.
	 -- se agregan dos nuevas restricciones para EmpresaNetPlus.
	 --Fecha: 18 Agosto 2014
	 --Por: Berenice Noriega
	 --Liberado a produccion: 30-Enero-2015 	 
     --**************************************************************

    	--SET DEBUG FILE TO "/tmp/cristo/sp_limite_max.out";
    	--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err  --, isam_err
		--- GENERA BITACORA DIARIA DE ERROR SIN INTERRUMPIR EL PROCESO DE JOM
		-- 10/02/2021 SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		-- 10/02/2021 TRACE ON;

		IF sql_err <> 0 THEN
			LET vCodret1 = sql_err;
		END IF;

		LET vMensaje1 = 'Se produjo un error inesperado';  ---- 21/07/2010
		LET vIndicador = '0';                              ---- 21/07/2010

		RETURN vcodret1,vMensaje1,vIndicador;   -- Termina proceso del SP 21/07/2010

	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
            --------    AGREGAR LA VALIDACION DEL NUMETO DE TARJETA
    IF (pNumcte is null OR pNumcte = '') OR --LENGTH(pNumcte) <> 10) OR
       (pCuenta is null OR pCuenta = '') OR --LENGTH(pCuenta) <> 16) OR
       (pOperacion is null OR pOperacion = '' OR pOperacion = '00' OR LENGTH(pOperacion) <> 2) OR
       (pCanal is null OR pCanal = '' OR pCanal <= '00' OR LENGTH(pCanal) <> 2) OR
       (pFecha is null OR pFecha = '') AND
       (pMto_tot is null OR pMto_tot <= 0.00) THEN


        LET vcodret1 = '00030';
        LET vMensaje1 = 'Se genero algun error en la ejecucion';

        RETURN vcodret1,vMensaje1,vIndicador;
    END IF;
	
	-- Obtiene el Parametro para su Validacion y asignar el valor indicado en VACTIVAR_LIMITES
	SELECT valor
	INTO vActivar_Limite
	FROM bdinteg:"informix".si_param
	WHERE empresa = vEmpresa
	AND cod_param = vCod_param;

    IF vActivar_Limite = 'F' THEN              -- Validacion del Parametro de la tabla si_param
       RETURN vcodret1,vMensaje2,vIndicador;   -- Termina proceso del SP
    END IF;

	-- Verifica si ya existe un registro en la tabla si_limite_diario, para esa combinacion de cuenta / canal.
	-- En caso de que no exista, lo inserta.

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		LET vOperacion = pOperacion;
	ELSE
		LET vOperacion = '00';
	END IF;

	SELECT {+index (si_limite_diario idx_limite_dia)} count (*)
	INTO vExiste
	FROM bdinteg:si_limite_diario
	WHERE f_operacion = pFecha
	AND cuenta = pCuenta
	AND numcte = pNumcte
	AND id_canal = pCanal
	AND id_operacion = vOperacion;  -- BGM SE CAMBIA VARIABLE A VOPERACION


	IF vExiste = 0 THEN
		INSERT INTO bdinteg:si_limite_diario VALUES
		(pFecha, pCuenta, pNumcte, pCanal, vOperacion, 0.00);  -- BGM SE MODIFICA VARIABLE PARA PARAMETRO DE ID OPERACION
	END IF;

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor valido.

	IF vExiste >= 1 THEN
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION

		IF vImporte is null or vImporte = '' THEN
			UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario SET importe_dia = 0.00
			WHERE f_operacion = pFecha
			AND cuenta = pCuenta
			AND numcte = pNumcte
			AND id_canal = pCanal
			AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
			
			LET vImporte = 0.00;
		END IF
	END IF;

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		 LET vOperacion = pOperacion;

		--******************************************************************************************************************--
		---INICIA PRIMERA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
		--******************************************************************************************************************--
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND num_cta= pcuenta
			AND id_restriccion='01'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos1
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND num_cta= pcuenta
			AND id_restriccion = '01'; --En la tabla si_plimites_empresas la restruccion 01 es por el ACUMULADO por cuenta-operacion-cliente
			
			LET vlimite_personalizado_rest1=1;		
			
		END IF;	
		
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND id_restriccion='02'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos2
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND id_restriccion = '02'; --En la tabla si_plimites_empresas la restriccion 02 es por CADA OPERACION.
			
			LET vlimite_personalizado_rest2=1;					
		END IF;	
		
		
		
		
		IF vlimite_personalizado_rest1= 0 THEN --
			--**TERMINA PRIMERA PARTE DE MODIFICACION***************************************************************************--			 
			SELECT {+index (si_plimites idx_plimites)} tope_max_pesos
			INTO vMax_pesos
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND id_restriccion = '02';

		END IF;
	ELSE --Else, si no se trata de canal pCanal = '03' OR pCanal = '15' OR pCanal = '17' 
		LET vOperacion = '00';
		SELECT {+index (si_canales idx_canal)} limite_canal_pesos
		INTO vMax_pesos
		FROM bdinteg:si_canales
		WHERE id_canal = pCanal;
	END IF

	IF vlimite_personalizado_rest2=1 and pMto_tot > vMax_pesos2 THEN --si existe un limite por operacion,vMax_pesos es de si_plimites_empresas
		LET vcodret1 = '00035'; --00036
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el limite diario permitido para el canal';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador; -- Termina proceso del SP
	ELSE
		--  SELECCIONA EL IMPORTE QUE TIENE PARA PROCEDER CON LA ACTUALIZACION
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;	-- BGM SE MODIFICA VALOR DE ID OPERACION

		--  ACTUALIZA ACUMULADO
		UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario
		SET importe_dia = vImporte + pMto_tot
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
		LET vIndicador = '0';
		--END IF;
		--RETURN vCodret1, vMensaje1, vIndicador WITH RESUME;  --------*****************
	END IF;

    LET venviar = 'F';

    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF
	

	--******************************************************************************************************************--
	--INICIA SEGUNDA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
	--******************************************************************************************************************--
	IF vlimite_personalizado_rest1=0 THEN --Si no se encontro en la tabla de limites entonces entra a validar los limites generales
		--**TERMINA SEGUNDA PARTE DE LA MODIFICACION************************************************************************--

		FOREACH

			SELECT {+index (si_plimites idx_plimites)} id_restriccion, tope_max_pesos, envio_mensaje, id_tipo_mensaje,sistema, id_mensaje
			INTO vRestriccion, vMax_pesos, vEnviarMensaje, vTipo_mensaje, vSistema, vsidmensaje
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND sistema = vSist


			IF vRestriccion = '01' THEN  -- OBTIENE IMPORTE DEL CAMPO IMPORTE_DIA y lo asigna en variable vImporte
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
					LET vOperacion = pOperacion;
				ELSE
					LET vOperacion = '00';
				END IF

				SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
				INTO vImporte
				FROM bdinteg:si_limite_diario
				WHERE f_operacion = pFecha
				AND cuenta = pCuenta
				AND numcte = pNumcte
				AND id_canal = pCanal
				AND id_operacion = vOperacion;	-- BGM se usara la variable vOperacion en lugar del parametro pOperacion

				--IF vImporte > vMax_pesos THEN
					--LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				--END IF;
				
				--vSist = '01' ATM_DEB   vSist = '06' ATM_CRED
				--IF vSist = '01' THEN
					IF (NVL(pMto_tot,0) > 0 OR pMto_tot <> '') THEN
							IF pMto_tot > vMax_pesos THEN
								LET vEnviar = 'V';
							ELSE
								LET vEnviar = 'F';
							END IF;
						ELSE
							LET vEnviar = 'F';
					END IF;
				--END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
										
					IF NVL(pMto_tot,0) > 0 OR pMto_tot <> '' THEN
						IF pMto_tot > vMax_pesos THEN
							LET vImporte = pMto_tot;
							LET vEnviar = 'V';
						ELSE
							LET vEnviar = 'F';
						END IF;
					ELSE
						LET vEnviar = 'F';
					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V


				LET vsidmensaje=trim(vsidmensaje);
				
				IF vsidmensaje = 'ATM_CRED' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'ATM_DEB' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_DEB' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_CRED' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';					
				ELSE
					LET cDescOper= 'Un Movimiento';
					LET cDescTar = 'Cuenta';
					LET pnumtarjeta = '';
				END IF;
	
				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));

				LET cReferencia = NVL(preferencia,'');
				LET cfolsuc = NVL(pfolsuc,'');
				
				LET cLugar_oper = SUBSTRING(TRIM(cReferencia) from 1 for 20);
				LET cFolio_suc = TRIM(cfolsuc);
				
				-- Optimizacion de SMS Se usara solo la plantilla CUB_EMAIL para las notificaciones de tarjetas de credito y debito. Descartando CUB_SMS
				EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				cLugar_oper,cDescTar,cFolio_suc,'','',
				'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				IF vCodret1 <> '00000' THEN
					LET vMensaje1 = 'Error Registra Evento';
				END IF;

				--Codigo original antes de modificacion del proyecto de Optimizacion de SMS
				/*EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				INTO vcodret2, vCorreoElec, vTipoCorreo, vStatusCorreo;
				   
				
				IF vcodret2 = '000' AND (NVL(vCorreoElec,'') <> '' OR vCorreoElec <> '')  THEN
				
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
					pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
					cLugar_oper,cDescTar,cFolio_suc,'','',
					'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
					
				ELSE 	
					LET cDescOper = REPLACE(cDescOper, 'Una ', '');
					LET cDescOper = REPLACE(cDescOper, 'Un ', '');
					
					EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2','CUB_SMS','NOT_MOV_TJT',
					pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
					cLugar_oper,cDescTar,'','','',
					'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				END IF;*/

			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		BDINTEG',
'FECHA :        28-11-2025',
'MODIFICACION : La plantilla de mensajes CUB_SMS se descarto y solo se considerara la plantilla CUB_EMAIL para optimizar' ,
			   'las notificaciones de movimiento tarjeta, ya que las plantillas comparten el mismo contenido y tipo de transacciones',
'PROYECTO :     Optimizacion de SMS',
'VERSION :      1.0.2';

CREATE PROCEDURE "informix".sp_limite_max99(pNumcte CHAR(10),
                                          pCuenta CHAR(16),
                                          pOperacion CHAR(2),
                                          pCanal CHAR(2),         -- 01 - ATM, 02 - POS, 03 - PORTAL, 15 - EMPRESANET, 17 - BANCOPPEL MOVIL ONLINE.
                                          pFecha DATE,
                                          pMto_tot DECIMAL(16,2),
                                          pnumtarjeta CHAR (20),
										  pfolsuc      char(16),
										  preferencia  char(40))
RETURNING CHAR(5), CHAR (80), CHAR(1);

--SP limite_max sobrecargado para requerimiento normativo CUB RQI 62 991 Modificaciones a bdinteg sp_limite_max

-- Declaracion de variables

    DEFINE sql_err      	    INTEGER;
    DEFINE isam_err     	    INTEGER;
    DEFINE vCodret1     	    CHAR(5);
	--DEFINE vCodret2     	    CHAR(3);

    DEFINE vMtoacumcta          DECIMAL(16,2);
    DEFINE vLim_canal_pesos     DECIMAL(16,2);
    DEFINE vExiste              INTEGER;
    DEFINE vTipo_mensaje        CHAR(2);
    DEFINE vRestriccion         CHAR(2);
    DEFINE vMax_pesos           DECIMAL(16,2);
    DEFINE vMensaje1            CHAR (80);
    DEFINE vEnviar              CHAR(1);
    DEFINE vEmpresa             CHAR(3);
    DEFINE vEmail               CHAR(80);
    DEFINE vCorreoElec          CHAR(100); -- se agrega por la reingenieria
    DEFINE vNombre              CHAR(104);
    DEFINE vIndicador           CHAR(1);
    DEFINE vImporte             DECIMAL(16,2);
    DEFINE vEnviarMensaje       CHAR(60);
	DEFINE vOperacion           CHAR(2);   -- BGM SE DECLARA VARIABLE DE VOPERACION
    DEFINE Vtipo_tarjeta        CHAR(20);  -- RRG TIPO DE TARJETA TITULAR O ADICIONAL
	DEFINE vImporte2            CHAR(16);
	DEFINE vMontoTotal			CHAR(16);

	DEFINE vActivar_Limite      CHAR(100);
	DEFINE vCod_param           SMALLINT;
	DEFINE vMensaje2            CHAR (80);

	DEFINE v_fecha1             CHAR(200);
	DEFINE v_fecha              CHAR(06);
	DEFINE v_ano_wk             CHAR(04);
	DEFINE v_longitud           INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_cuenta				INTEGER;  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_subcadena			CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico
	DEFINE v_mail_incorrecto	CHAR(1);  -- BGM 31-08-2010 Variable para validacion de correo electronico

    DEFINE vExisteCta           SMALLINT;
    DEFINE vSistema             CHAR(2);
    DEFINE vSist                CHAR(2);

    DEFINE vTipoCorreo      	SMALLINT;
    DEFINE vStatusCorreo    	CHAR(1);
	
    DEFINE vsidmensaje 			CHAR(10);

	DEFINE vMax_pesos1 			DECIMAL(16,2);
	DEFINE vMax_pesos2 			DECIMAL(16,2);
	DEFINE vlimite_personalizado_rest1 SMALLINT;
	DEFINE vlimite_personalizado_rest2 SMALLINT;
	
	DEFINE vMax_pesosAC         DECIMAL(16,2);
	DEFINE vEnviarMensajeAC     CHAR(60);
	DEFINE vTipo_mensajeAC      CHAR(2);
	DEFINE vsidmensajeAC		CHAR(10);
	DEFINE vCambioPlantilla  	CHAR(1);
	DEFINE cRet					CHAR(5);
	DEFINE vValorUdi			DECIMAL(14,6);
	DEFINE vfecha				DATE;
	
	DEFINE cLugar_oper          CHAR(40);
	DEFINE cFolio_suc           CHAR(16);
	DEFINE cDescOper			CHAR(40);
	DEFINE cDescTar 			CHAR(40);
	DEFINE cReferencia          CHAR(40);
	DEFINE cfolsuc CHAR(16);
	
	--SET DEBUG FILE TO '/informix/HMLG/sp_limite_max.out';
	--TRACE ON; 
-- Inicializacion de variables

    LET sql_err   = 0;
    LET isam_err  = 0;
    LET vCodret1  = '00000';
	--LET vCodret2  = '000';

    LET vMtoacumcta         = 0.00;
    LET vLim_canal_pesos    = 0.00;
    LET vExiste             = 0;
    LET vTipo_mensaje       = '';
    LET vRestriccion        = '';
    LET vMax_pesos          = 0.00;
    LET vMensaje1           = 'El proceso concluyo exitosamente';
    LET vEnviar             = '';
    LET vEmpresa            = '001';
    LET vEmail              = '';
    LET vCorreoElec         = '';   -- se agrega por la reingenieria
    LET vNombre             = '';
    LET vIndicador          = '0';
    LET vImporte            = 0.00;
    LET vEnviarMensaje      = '';
	LET vImporte2			= '';
	LET vMontoTotal			= '';

    LET vActivar_Limite     = '';
    LET vCod_param          = 110;
    LET vMensaje2           = 'Validacion Inactiva';

    LET v_ano_wk            = YEAR(TODAY);
    LET v_ano_wk            = v_ano_wk[3,4];

    LET v_fecha             = LPAD(DAY(TODAY -1),2,0)||LPAD(MONTH(TODAY),2,0)||v_ano_wk;
	LET v_longitud          = 0;    -- BGM 31-08-2010 Variable para validacion de correo electronico
	LET v_cuenta            = 1;    -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_subcadena         = '';   -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET v_mail_incorrecto   = 'F';  -- BGM 31-08-2010 Variable para validacion de correo electronico
    LET Vtipo_tarjeta       = '';   -- RRG 07-11-2011 Variable para tipo de tarjeta Titular o Adicional

    LET vExisteCta          = 0;
    LET vSistema            = '';

    LET vTipoCorreo = 0;
    LET vStatusCorreo = '';
	
	LET vMax_pesos1=0.00; --Variable para limites EmpresaNetPlus restriccion 01
	LET vMax_pesos2=0.00; --Variable para limites EmpresaNetPlus restriccion 02
	LET vlimite_personalizado_rest1=0;
	LET vlimite_personalizado_rest2=0;
	
	LET vMax_pesosAC        = 0.00;
	LET vEnviarMensajeAC    = '';
	LET vTipo_mensajeAC     = '';
    LET vsidmensajeAC	    = '';
	LET vCambioPlantilla	= 'F';
	LET cRet				= '';
	LET vValorUdi			= 0.00;
	LET vfecha				= DATE(1);
	
	LET cLugar_oper = '';
    LET cFolio_suc = '';
	LET cDescOper= '';
	LET cDescTar = '';
	LET cReferencia = '';
	LET cfolsuc = '';

    --**************************************************************
     -- Creado por Raul Ramirez    01/Jul/2010
     -- Capitulo X Acumulado Diario y Preparacion para el envio de Mensaje
     -- Modificado el 03/03/2011, Se modifica el sp para envio de mensaje
     -- con informacion en particular para credito y debito, de transacciones
     -- realizadas en ATM y POS.
     -- Modificado el 17/01/2011, Se agrega el numero de tarjeta y el tipo
     -- para el armado del envio de mensaje.
     -- Se modifica el proceso por la reigenieria del Correo Electronico 26/03/12
	 
	 --Modificacion: para que consulte la tabla nueva de limites por empresa.
	 -- se agregan dos nuevas restricciones para EmpresaNetPlus.
	 --Fecha: 18 Agosto 2014
	 --Por: Berenice Noriega
	 --Liberado a produccion: 30-Enero-2015 	 
     --**************************************************************

    	--SET DEBUG FILE TO "/tmp/cristo/sp_limite_max.out";
    	--TRACE ON;

BEGIN

    ON EXCEPTION SET sql_err  --, isam_err
		--- GENERA BITACORA DIARIA DE ERROR SIN INTERRUMPIR EL PROCESO DE JOM
		-- 10/02/2021 SET DEBUG FILE TO 'log'||to_char(today, '%Y%m%d')||'.err' WITH APPEND;
		-- 10/02/2021 TRACE ON;

		IF sql_err <> 0 THEN
			LET vCodret1 = sql_err;
		END IF;

		LET vMensaje1 = 'Se produjo un error inesperado';  ---- 21/07/2010
		LET vIndicador = '0';                              ---- 21/07/2010

		RETURN vcodret1,vMensaje1,vIndicador;   -- Termina proceso del SP 21/07/2010

	END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
            --------    AGREGAR LA VALIDACION DEL NUMETO DE TARJETA
    IF (pNumcte is null OR pNumcte = '') OR --LENGTH(pNumcte) <> 10) OR
       (pCuenta is null OR pCuenta = '') OR --LENGTH(pCuenta) <> 16) OR
       (pOperacion is null OR pOperacion = '' OR pOperacion = '00' OR LENGTH(pOperacion) <> 2) OR
       (pCanal is null OR pCanal = '' OR pCanal <= '00' OR LENGTH(pCanal) <> 2) OR
       (pFecha is null OR pFecha = '') AND
       (pMto_tot is null OR pMto_tot <= 0.00) THEN


        LET vcodret1 = '00030';
        LET vMensaje1 = 'Se genero algun error en la ejecucion';

        RETURN vcodret1,vMensaje1,vIndicador;
    END IF;
	
	-- Obtiene el Parametro para su Validacion y asignar el valor indicado en VACTIVAR_LIMITES
	SELECT valor
	INTO vActivar_Limite
	FROM bdinteg:"informix".si_param
	WHERE empresa = vEmpresa
	AND cod_param = vCod_param;

    IF vActivar_Limite = 'F' THEN              -- Validacion del Parametro de la tabla si_param
       RETURN vcodret1,vMensaje2,vIndicador;   -- Termina proceso del SP
    END IF;

	-- Verifica si ya existe un registro en la tabla si_limite_diario, para esa combinacion de cuenta / canal.
	-- En caso de que no exista, lo inserta.

	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		LET vOperacion = pOperacion;
	ELSE
		LET vOperacion = '00';
	END IF;

	SELECT {+index (si_limite_diario idx_limite_dia)} count (*)
	INTO vExiste
	FROM bdinteg:si_limite_diario
	WHERE f_operacion = pFecha
	AND cuenta = pCuenta
	AND numcte = pNumcte
	AND id_canal = pCanal
	AND id_operacion = vOperacion;  -- BGM SE CAMBIA VARIABLE A VOPERACION


	IF vExiste = 0 THEN
		INSERT INTO bdinteg:si_limite_diario VALUES
		(pFecha, pCuenta, pNumcte, pCanal, vOperacion, 0.00);  -- BGM SE MODIFICA VARIABLE PARA PARAMETRO DE ID OPERACION
	END IF;

	-- Si ya existe un registro en si_limite_diario, se asegura que el campo importe_dia tenga un valor valido.

	IF vExiste >= 1 THEN
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION

		IF vImporte is null or vImporte = '' THEN
			UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario SET importe_dia = 0.00
			WHERE f_operacion = pFecha
			AND cuenta = pCuenta
			AND numcte = pNumcte
			AND id_canal = pCanal
			AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
			
			LET vImporte = 0.00;
		END IF
	END IF;

	---- VALIDACION DE MONTO POR CANAL
	IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
		 LET vOperacion = pOperacion;

		--******************************************************************************************************************--
		---INICIA PRIMERA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
		--******************************************************************************************************************--
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND num_cta= pcuenta
			AND id_restriccion='01'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos1
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND num_cta= pcuenta
			AND id_restriccion = '01'; --En la tabla si_plimites_empresas la restruccion 01 es por el ACUMULADO por cuenta-operacion-cliente
			
			LET vlimite_personalizado_rest1=1;		
			
		END IF;	
		
		IF EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_plimites_empresas 
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente=pNumcte
			AND id_restriccion='02'	) THEN
			
			SELECT tope_max_pesos
			INTO vMax_pesos2
			FROM bdinteg:"informix".si_plimites_empresas
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND num_cliente = pNumcte
			AND id_restriccion = '02'; --En la tabla si_plimites_empresas la restriccion 02 es por CADA OPERACION.
			
			LET vlimite_personalizado_rest2=1;					
		END IF;	
		
		
		
		
		IF vlimite_personalizado_rest1= 0 THEN --
			--**TERMINA PRIMERA PARTE DE MODIFICACION***************************************************************************--			 
			SELECT {+index (si_plimites idx_plimites)} tope_max_pesos
			INTO vMax_pesos
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND id_restriccion = '02';

		END IF;
	ELSE --Else, si no se trata de canal pCanal = '03' OR pCanal = '15' OR pCanal = '17' 
		LET vOperacion = '00';
		SELECT {+index (si_canales idx_canal)} limite_canal_pesos
		INTO vMax_pesos
		FROM bdinteg:si_canales
		WHERE id_canal = pCanal;
	END IF

	IF vlimite_personalizado_rest2=1 and pMto_tot > vMax_pesos2 THEN --si existe un limite por operacion,vMax_pesos es de si_plimites_empresas
		LET vcodret1 = '00035'; --00036
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el transaccion';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;
		
	ELIF vlimite_personalizado_rest1=1 and (pMto_tot + vImporte) > vMax_pesos1 THEN --Si existe limite por cuenta-operacion, 
		LET vcodret1 = '00035'; --00037
		LET vMensaje1 = 'Importe de la operacion excede el limite diario permitido para el cuenta';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador;

	ELIF vlimite_personalizado_rest1=0 and (pMto_tot + vImporte) > vMax_pesos   THEN --se agrega el if vlimite_personalizado=0
		LET vcodret1 = '00035';
		LET vMensaje1 = 'Importe de la transaccion excede el limite diario permitido para el canal';
		LET vIndicador = '1';
		RETURN vCodret1, vMensaje1, vIndicador; -- Termina proceso del SP
	ELSE
		--  SELECCIONA EL IMPORTE QUE TIENE PARA PROCEDER CON LA ACTUALIZACION
		SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
		INTO vImporte
		FROM bdinteg:si_limite_diario
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;	-- BGM SE MODIFICA VALOR DE ID OPERACION

		--  ACTUALIZA ACUMULADO
		UPDATE {+index (si_limite_diario idx_limite_dia)} bdinteg:si_limite_diario
		SET importe_dia = vImporte + pMto_tot
		WHERE f_operacion = pFecha
		AND cuenta = pCuenta
		AND numcte = pNumcte
		AND id_canal = pCanal
		AND id_operacion = vOperacion;		-- BGM SE MODIFICA VALOR DE ID OPERACION
		LET vIndicador = '0';
		--END IF;
		--RETURN vCodret1, vMensaje1, vIndicador WITH RESUME;  --------*****************
	END IF;

    LET venviar = 'F';

    --- Validacion para indentificar la cuenta, para el envio de mensaje correspondiente debito o credito.
	SELECT {+index (bdicheq:sc_maechq idx_maechq1)} COUNT(*)
	INTO vExisteCta
	FROM bdicheq:sc_maechq
	WHERE empresa = vEmpresa
	AND cuenta = pCuenta;

    IF vExisteCta > 0 THEN
        LET vSist = '01';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en debito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicheq:sc_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    ELSE
		LET vSist = '06';
		----  Validacion para el tipo de Tarjeta Titular o Adicional en credito
		SELECT tipo_tarjeta
		INTO Vtipo_tarjeta
		FROM bdicred:sd_tarjeta
		WHERE empresa = vEmpresa
		AND num_tarjeta = pnumtarjeta;
    END IF
	

	--******************************************************************************************************************--
	--INICIA SEGUNDA PARTE DE LA MODIFICACION PARA LIMITES PERSONALIZADOS EMPRESANETPLUS--------------------------------
	--******************************************************************************************************************--
	IF vlimite_personalizado_rest1=0 THEN --Si no se encontro en la tabla de limites entonces entra a validar los limites generales
		--**TERMINA SEGUNDA PARTE DE LA MODIFICACION************************************************************************--

		FOREACH

			SELECT {+index (si_plimites idx_plimites)} id_restriccion, tope_max_pesos, envio_mensaje, id_tipo_mensaje,sistema, id_mensaje
			INTO vRestriccion, vMax_pesos, vEnviarMensaje, vTipo_mensaje, vSistema, vsidmensaje
			FROM bdinteg:si_plimites
			WHERE id_operacion = pOperacion
			AND id_canal = pCanal
			AND sistema = vSist


			IF vRestriccion = '01' THEN  -- OBTIENE IMPORTE DEL CAMPO IMPORTE_DIA y lo asigna en variable vImporte
				IF pCanal = '03' OR pCanal = '15' OR pCanal = '17' THEN		-- BGM SE AGREGA VALIDACION DE CANAL PARA ASIGNAR EL VALOR INDICADO EN VOPERACION
					LET vOperacion = pOperacion;
				ELSE
					LET vOperacion = '00';
				END IF

				SELECT {+index (si_limite_diario idx_limite_dia)} importe_dia
				INTO vImporte
				FROM bdinteg:si_limite_diario
				WHERE f_operacion = pFecha
				AND cuenta = pCuenta
				AND numcte = pNumcte
				AND id_canal = pCanal
				AND id_operacion = vOperacion;	-- BGM se usara la variable vOperacion en lugar del parametro pOperacion

				--IF vImporte > vMax_pesos THEN
					--LET vEnviar = 'V';              -- ACTUALIZA VARIABLE vEnviar
				--END IF;
				
				--vSist = '01' ATM_DEB   vSist = '06' ATM_CRED
				--IF vSist = '01' THEN
					IF (NVL(pMto_tot,0) > 0 OR pMto_tot <> '') THEN
							IF pMto_tot > vMax_pesos THEN
								LET vEnviar = 'V';
							ELSE
								LET vEnviar = 'F';
							END IF;
						ELSE
							LET vEnviar = 'F';
					END IF;
				--END IF;
				
			END IF;

			IF vlimite_personalizado_rest2=0 THEN --Si la empresa no tiene personalisado para cada operacion
				IF vRestriccion = '02' THEN  --  Se valida que el monto de la transaccion sea mayor al limite en pesos
										
					IF NVL(pMto_tot,0) > 0 OR pMto_tot <> '' THEN
						IF pMto_tot > vMax_pesos THEN
							LET vImporte = pMto_tot;
							LET vEnviar = 'V';
						ELSE
							LET vEnviar = 'F';
						END IF;
					ELSE
						LET vEnviar = 'F';
					END IF;
				END IF;
			END IF;

			IF vEnviar = 'V' and vEnviarMensaje = 'V' THEN -- VALIDA EL VALOR DE LA VARIABLE vEnviar y vEnviarMensaje, si es V


				LET vsidmensaje=trim(vsidmensaje);
				
				IF vsidmensaje = 'ATM_CRED' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'ATM_DEB' THEN
					LET cDescOper= 'Un Retiro';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_DEB' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Debito';
					LET pCuenta = '';
				ELIF vsidmensaje = 'POS_CRED' THEN
					LET cDescOper= 'Una Compra';
					LET cDescTar = 'Tarjeta de Credito';
					LET pCuenta = '';					
				ELSE
					LET cDescOper= 'Un Movimiento';
					LET cDescTar = 'Cuenta';
					LET pnumtarjeta = '';
				END IF;
	
				--Divide el importe en millares para alertas de mensajeria
				LET vImporte2 = trim (to_char(vImporte,"###,###,###,###.##"));
				LET vMontoTotal = trim (to_char(pMto_tot,"###,###,###,###.##"));

				LET cReferencia = NVL(preferencia,'');
				LET cfolsuc = NVL(pfolsuc,'');
				
				LET cLugar_oper = SUBSTRING(TRIM(cReferencia) from 1 for 20);
				LET cFolio_suc = TRIM(cfolsuc);
				
				-- Optimizacion de SMS Se usara solo la plantilla CUB_EMAIL para las notificaciones de tarjetas de credito y debito. Descartando CUB_SMS
				EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				cLugar_oper,cDescTar,cFolio_suc,'','',
				'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				
				IF vCodret1 <> '00000' THEN
					LET vMensaje1 = 'Error Registra Evento';
				END IF;

				--EXECUTE PROCEDURE "informix".sp_consulta_correos('001', pNumcte, 1, '0')   -- se agrega por la reingenieria
				--INTO vcodret2, vCorreoElec, vTipoCorreo, vStatusCorreo;
				--   
				--
				--IF vcodret2 = '000' AND (NVL(vCorreoElec,'') <> '' OR vCorreoElec <> '')  THEN
				--
				--	EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('1','CUB_EMAIL','NOT_INT_MOVI',
				--	pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				--	cLugar_oper,cDescTar,cFolio_suc,'','',
				--	'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				--	
				--ELSE 	
				--	LET cDescOper = REPLACE(cDescOper, 'Una ', '');
				--	LET cDescOper = REPLACE(cDescOper, 'Un ', '');
				--	
				--	EXECUTE PROCEDURE bdimnsj:'informix'.sp_registra_evento ('2','CUB_SMS','NOT_MOV_TJT',
				--	pNumcte,pCuenta,pnumtarjeta,'1',cDescOper,vMontoTotal,'','','',
				--	cLugar_oper,cDescTar,'','','',
				--	'','',1,0,0,0,0,CURRENT,'') INTO vCodret1;
				--
				--END IF;

			ELSE
				  LET vEnviar = 'F';

			END IF;

		END FOREACH;
	END IF;
END
    RETURN vCodret1, vMensaje1, vIndicador;

END PROCEDURE
DOCUMENT
'MODIFICO :     Ezequiel Moreno Paredes',
'BD :     		BDINTEG',
'FECHA :        28-11-2025',
'MODIFICACION : La plantilla de mensajes CUB_SMS se descarto y solo se considerara la plantilla CUB_EMAIL para optimizar' ,
			   'las notificaciones de movimiento tarjeta, ya que las plantillas comparten el mismo contenido y tipo de transacciones',
'PROYECTO :     Optimizacion de SMS',
'VERSION :      1.0.2';

CREATE PROCEDURE "informix".sp_genera_numcte( pEmpresa CHAR(3) )
RETURNING CHAR(5) AS cCodRet, CHAR(20) AS cNumCte;

    -- 1. DefiniciÃ³n de Variables
    -- Solo declaramos las necesarias para que funcione tu bloque de cÃ³digo
    DEFINE cCodret      CHAR(5);
    DEFINE cNumcte      CHAR(20);
    DEFINE iSignumcte   INT;           -- Entero para poder sumar
    DEFINE sLong_cte    SMALLINT;      -- Variable para el parÃ¡metro 7
    DEFINE sDiferencia  SMALLINT;      -- Variable para el cÃ¡lculo de ceros
    DEFINE sI           SMALLINT;      -- Contador del ciclo FOR
    DEFINE iSqlerr      INTEGER;       -- Para control de excepciones

    -- 2. InicializaciÃ³n
    LET cCodret = "000";
    LET cNumcte = "";

BEGIN
    -- Manejo de Excepciones
    ON EXCEPTION SET iSqlerr
        IF iSqlerr <> 0 THEN
            LET cCodret = iSqlerr;
            RETURN cCodret, cNumcte;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    -- 3. TU LÃGICA (Insertada textualmente como solicitaste)
    
          SELECT valor
            INTO sLong_cte
            FROM bdinteg:"informix".si_param
           WHERE cod_param = 7
             AND empresa = pEmpresa;

        IF sLong_cte IS NULL THEN
            LET cCodret = "105";
            RETURN cCodret,cNumcte;
        ELSE
            SELECT valor
              INTO iSignumcte
              FROM bdinteg:"informix".si_param
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            IF iSignumcte IS NULL THEN
                LET iSignumcte = 1;
            END IF

            LET cNumcte = iSignumcte;
            LET iSignumcte = iSignumcte + 1;

            UPDATE bdinteg:"informix".si_param
               SET (valor) = (iSignumcte)
             WHERE empresa = pEmpresa
               AND cod_param = 6;

            -- Nota: AsegÃºrate que cNumcte no tenga espacios al final para que LENGTH funcione bien
            LET sDiferencia = sLong_cte - LENGTH(cNumcte); 

            IF sDiferencia > 0 THEN
                FOR sI = 1 TO sDiferencia
                    LET cNumcte = "0" || cNumcte;
                END FOR;
            END IF
        END IF;

    -- 4. Retorno final (Si todo saliÃ³ bien)
    RETURN cCodret, cNumcte;
    END;

END PROCEDURE;