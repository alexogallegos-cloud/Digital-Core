CREATE PROCEDURE "informix".sp_validasolper2(pNumCte varchar(13), pNumCuenta varchar(13), pNumtarjeta CHAR(16))
   RETURNING CHAR(5), CHAR(50), CHAR(6), CHAR(1);
      
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cDescripcion 	  CHAR(50);
   DEFINE cIdSolicitud 	  CHAR(6);
   DEFINE cEstatusProceso CHAR(1);
   DEFINE cNumTarj        CHAR(16);  
   DEFINE cNumTarj2        CHAR(16);   
   DEFINE cNumCte        CHAR(16);  
   DEFINE cCodProdTar        CHAR(3);
   
   LET cCodRet 		      = '00000';   
   LET cDescripcion	      = '';
   LET cIdSolicitud	      = '';
   LET cEstatusProceso    = '';
   LET cNumTarj           = '';
   LET cNumTarj2       = '';
   LET cNumCte           = '';  
   LET cCodProdTar           = '';
      
BEGIN

	/*ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
	END EXCEPTION;*/
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/SP_VALIDASOLPER.out";
    --TRACE ON;	
	-- AAME RQM 10 676-2 Se agrega filtro de consulta por NÃÂºmero de tarjeta
	FOREACH
		SELECT MAX(idsolicitud) INTO cIdSolicitud       
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta 
	   
        SELECT estatusproceso, codproductotarjeta INTO cEstatusProceso, cCodProdTar  
		FROM intercard: solicitudtarjeta WHERE numcliente = pNumCte AND numcuenta = pNumCuenta AND idsolicitud = cIdSolicitud;

		--IF cNumTarj <> "" OR cNumTarj is not null THEN
        IF pNumtarjeta <> "" OR pNumtarjeta is not null OR pNumtarjeta ='Sin tarjeta' THEN
			SELECT FIRST 1 numcliente INTO cNumCte 
            FROM intercard: tarjeta WHERE numcliente = pNumCte AND codstatusasignada in ('NOA', 'NOE')
            AND codstatustarjeta = 'INA' AND codproductotarjeta = cCodProdTar;
		END IF;
		
		IF cEstatusProceso = "V" AND NVL(cNumCte,'') <> '' THEN

			SELECT {+INDEX(intercard:"informix".detalle_maquila idx_idsolicitud)} numtarjeta INTO cNumTarj2 FROM intercard:detalle_maquila WHERE idsolicitud = cIdSolicitud;		
			
			SELECT num_tarjeta INTO cNumTarj FROM bdicheq: sc_tarjeta WHERE numcte = pNumCte AND cuenta = pNumCuenta AND num_tarjeta = cNumTarj2;
			IF cNumTarj = "" OR cNumTarj is null THEN
				SELECT num_tarjeta INTO cNumTarj FROM bdicred: sd_tarjeta WHERE numcte = pNumCte AND num_credito = pNumCuenta AND num_tarjeta = cNumTarj2;
			END IF;
			
			IF cNumTarj = "" OR cNumTarj is null THEN
				LET cCodRet = "00000";
				LET cDescripcion = "Solicitud Procesada";      -- Tarjeta no asignada		
			ELSE
				LET cCodRet = "00001";
				LET cDescripcion = "Solicitud (ReposiciÃÂ³n)";      -- Tarjeta asignada
			END IF;
			-- AAME RQM 10 676-2 Se agrega return para que no continue con validaciÃÂ³n una vez que se tiene resultado
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
        ELIF cEstatusProceso = "F" AND NVL(cNumCte,'') = '' THEN
			LET cCodRet = "00000";
			LET cDescripcion = "Solicitud en Proceso";
			RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
			-- AAME RQM 10 676-2 Se agrega nueva validaciÃÂ³n no contemplada para indicar que ya se procesÃÂ³ la solicitud y se encuentra activa la tarjeta
		ELIF cEstatusProceso = "V" AND NVL(cNumCte,'') = '' THEN
			SELECT {+INDEX(intercard:"informix".detalle_maquila idx_idsolicitud)} numtarjeta INTO cNumTarj2 FROM intercard:detalle_maquila WHERE idsolicitud = cIdSolicitud;		
			
			SELECT num_tarjeta INTO cNumTarj FROM bdicheq: sc_tarjeta WHERE numcte = pNumCte AND cuenta = pNumCuenta AND num_tarjeta = cNumTarj2;
			IF cNumTarj = "" OR cNumTarj is null THEN
				SELECT num_tarjeta INTO cNumTarj FROM bdicred: sd_tarjeta WHERE numcte = pNumCte AND num_credito = pNumCuenta AND num_tarjeta = cNumTarj2;
			END IF;			

            IF cNumTarj = "" OR cNumTarj is null THEN
				LET cCodRet = "00000";
				LET cDescripcion = "Solicitud Procesada";      -- Tarjeta no asignada		
			ELSE
				LET cCodRet = "00001";
				LET cDescripcion = "Solicitud (ReposiciÃÂ³n)";      -- Tarjeta asignada
			END IF;
            RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;
			
		END IF;	
	END FOREACH;
			-- AAME RQM 10 676-2 Se completo mas la descripciÃÂ³n
	IF cIdSolicitud = "" OR cEstatusProceso = "" OR cIdSolicitud is null OR cEstatusProceso is null THEN
		LET cCodRet = "00001";
		LET cDescripcion = 'Solicitud (Por primera vez) ';		
	END IF;
	
	RETURN cCodRet, cDescripcion, cIdSolicitud, cEstatusProceso;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Scarlett Mendoza',
'FECHA: 10/05/2018',
'BD: Intercard',
'Objetivo: Validar proceso de solicitud de tarjeta personalizada';

CREATE PROCEDURE "informix".sp_valida_telefonos_altarem(pEmpresa     CHAR(3),
                                                   pNumCte       CHAR(20), 
                                                   pTelefonoCasa CHAR(13),
												   pTelefonoCel	 CHAR(13),
                                                   pExtension    CHAR(5),
                                                   pCarrier      SMALLINT,
                                                   pCanal        SMALLINT,
                                                   pUserInsert   CHAR(8))
	RETURNING CHAR(5) AS cCodRet1,
			  CHAR(5) AS cCodRet2,
			  CHAR(1) AS cTelCasa,
			  CHAR(1) AS cTelCel;
    
	--DEFINICION DE VARIABLES
    DEFINE cCodRet1 		CHAR(5);
    DEFINE cCodRet2 		CHAR(5);
    DEFINE cCodRet3 		CHAR(50);
	DEFINE cCodRet4			CHAR(5);
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
	DEFINE pTelefono		CHAR(13);
	DEFINE i				INTEGER;
	DEFINE cTelCasa			CHAR(1);
	DEFINE cTelCel			CHAR(1);
	DEFINE iTipoTel			INTEGER;

	
	--INICIALIZA VARIABLES
    LET cCodRet1		= '00000';
    LET cCodRet2		= '00000';
    LET cCodRet3		= '';
	LET cCodRet4		= '00000';
    LET iSqlErr			= 0;
    LET iSamErr			= 0;
    LET cDesErr			= '';
    LET iExisteCte		= 0;
    LET iExisteCanal	= 0;
    LET cCodRetValTel	= '';
    LET cValCasa		= '';
    LET cValCelular		= '';
    LET cValOficina		= '';
    LET cCofetel		= '';
    LET iExisteCarrier	= 0;
    LET dFechaInsert	= '';
    LET sMaxSecTel		= 0;
    LET sContacto		= 0;
    LET iSecMaxDir		= 0;
    LET iExisteTelefono	= 0;
    LET iFijoMovil		= 0;
    LET cDescFijoMovil	= '';
    LET cResulFijoMovil	= '';
	LET cVerificado		= 'F';
    LET iTelInvalido    = 0;
	LET vmarcatel       = '';
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
	LET pTelefono		 = '';
	LET i				 = 1;
	LET cTelCasa		 = '';
	LET cTelCel			 = '';
	LET iTipoTel		 = 0;
	
	--SET DEBUG FILE TO "/informix/LIP/sp_registra_telefonos.out";
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
            RETURN cCodRet1,cCodRet2,cTelCasa,cTelCel;
        END IF;
    END EXCEPTION;
    
    

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);

    -- // VALIDA PARAMETROS DE ENTRADA
    IF (pEmpresa is null OR pEmpresa = '') OR (pNumCte is null OR pNumCte = '') OR
       ((pTelefonoCasa is null OR pTelefonoCasa = '') AND (pTelefonoCel is null OR pTelefonoCel = '')) OR 
       (pCarrier is null) OR (pCanal is null OR pCanal = 0) OR
       (pUserInsert is null OR pUserInsert = '') THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1,cCodRet2,cTelCasa,cTelCel;
    END IF;
    
	WHILE (i <= 2) LOOP
		IF i = 1 THEN
			LET pTelefono = TRIM(pTelefonoCasa);	
			LET iTipoTel = 1;
		ELSE
			IF i = 2 THEN
				LET pTelefono = TRIM(pTelefonoCel);
				LET iTipoTel = 2;
			END IF;
		END IF;
		LET i = i + 1;
		LET cCodRet4 = cCodRet1;
		LET cCodRet1 = '00000';
		
		IF TRIM(pTelefono) <> '' THEN
	
			-- // VERIFICA SI EXISTE EL NUMERO PARA EL TIPO INDICADO
			SELECT COUNT(*)
			  INTO iExisteTelefono
			  FROM "informix".si_telefonos_actual
			 WHERE numcte = pNumCte
			   AND tipo_tel = iTipoTel
			   AND telefono = pTelefono;
			   
			IF iExisteTelefono > 0 THEN
				LET cCodRet1 = '999'; 
			END IF;
			
			-- // VALIDA EL CANAL DE PROCEDENCIA
			SELECT COUNT(*)
			  INTO iExisteCanal
			  FROM "informix".si_canal
			 WHERE cve_canal = pCanal;
			 
			IF iExisteCanal = 0 THEN
				LET cCodRet1 = '104';
			END IF;
			
			-- // VALIDA EL CARRIER PARA NUMEROS CELULARES
			IF pCarrier > 0 THEN
				SELECT COUNT(*)
				  INTO iExisteCarrier
				  FROM "informix".si_carriers
				 WHERE cve_carrier = pCarrier;
				 
				IF iExisteCarrier = 0 THEN
					LET cCodRet1 = '104';
				END IF;
			END IF;
			
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
			END IF;
				
			
			-- //SI ES NUMERO FIJO VALIDA QUE NO EXCEDA EL LIMITE DE REGISTROS PERMITIDOS - LIPC
			IF iTipoTel = '1' THEN
				SELECT valor INTO sLimitNumFijo FROM "informix".si_param WHERE cod_param='462'; 
				SELECT COUNT(telefono) INTO sCoincideNumFijo FROM "informix".si_telefonos_actual WHERE telefono=pTelefono AND tipo_tel='1' AND status_tel='A' AND numcte != pNumCte;
					
				IF sCoincideNumFijo >= sLimitNumFijo THEN
					LET cCodRet1 = '1167'; 
				END IF;
				
			END IF;
			
			SELECT valor INTO iValidaDias FROM "informix".si_param WHERE cod_param='455';
			SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiff FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;
			
			IF iDiasDiff<=iValidaDias THEN
				LET cCodRet1 = '1165'; 
			END IF;

			--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
			IF iTipoTel = '2' THEN
				SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
				SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

				IF iDiasDiffTu<=iValidaDiasTu THEN
					LET iTelValidado = 1;
					LET cCodRet1 = '1168'; 
				ELSE
					LET iTelValidado = 0;
				END IF;
			END IF;
			
			--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
			IF iTipoTel = '2' THEN
				SELECT COUNT(telefono) INTO iTelNoValidado
				FROM "informix".si_telefonos 
				WHERE telefono=pTelefono 
				AND tipo_tel='2' 
				AND status_tel='A' 
				AND verificado != 'V'
				AND numcte != pNumCte;
				   
				IF iTelNoValidado > 0 THEN
					LET cCodRet1 = '1166'; 
				END IF;
			END IF;
			
			--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
			IF iTipoTel = '2' THEN
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
				END IF;
			END IF;
			
			LET sSucursal=(select first 1 sucursal from "informix".si_ejecut where ejecutivo=pUserInsert);
					
			SELECT COUNT(*) INTO iSucSMS FROM "informix".si_sucvalidasms WHERE sucursal=sSucursal AND activo='1';
			IF iSucSMS > 0 THEN

				-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (PARAMETRO 384 SI_PARAM)
					SELECT valor INTO iDiasVerificado FROM "informix".si_param WHERE cod_param='384';
					SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasPeriodo FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND user_insert='transBPI' AND numcte != pNumCte;

					IF iDiasPeriodo<=iDiasVerificado THEN
						LET cCodRet1 = '1163'; 
					END IF;
					
					--SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS POR OTRO CLIENTE - LIPC
					IF iTipoTel = '2' THEN
						SELECT valor INTO iValidaDiasTu FROM "informix".si_param WHERE cod_param='463';
						SELECT DATE(CURRENT) - DATE(MAX(fecha_hora)) INTO  iDiasDiffTu FROM "informix".si_telefonos WHERE telefono=pTelefono AND tipo_tel='2' AND status_tel='A' AND verificado = 'V' AND numcte != pNumCte;

						IF iDiasDiffTu<=iValidaDiasTu THEN
							LET iTelValidado = 1;
							LET cCodRet1 = '1168'; 
						ELSE
							LET iTelValidado = 0;
						END IF;
					END IF;
					
					--SE VALIDA QUE EL TELEFONO ESTA REGISTRADO PERO NO HA SIDO VALIDADO POR OTRO CLIENTE - LIPC
					IF iTipoTel = '2' THEN
						SELECT COUNT(telefono) INTO iTelNoValidado
						FROM "informix".si_telefonos
						WHERE telefono=pTelefono 
						AND tipo_tel='2' 
						AND status_tel='A' 
						AND verificado != 'V'
						AND numcte != pNumCte;
					   
						IF iTelNoValidado > 0 THEN
							LET cCodRet1 = '1166'; 
						END IF;
					END IF;
					
					--EN EL MANTENIMIENTO DE DATOS SE VALIDA SI EL NUMERO CELULAR DEL CLIENTE ESTA CANCELADO - LIPC
					IF iTipoTel = '2' THEN
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
						END IF;
					END IF;
				-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO VERIFICADO EN LOS ULTIMOS 90 DIAS (PARAMETRO 384 SI_PARAM)


				-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
					SELECT COUNT(*) INTO iTelCta FROM bdicheq:"informix".sc_cuenta_telefono WHERE telefono=pTelefono and num_cte<>pNumCte;
					IF iTelCta > 0 THEN
						LET cCodRet1 = '1164'; 
					END IF;
				-- // SE VALIDA QUE EL TELEFONO NO HAYA SIDO ASOCIADO A UNA CUENTA, TABLA SC_CUENTA_TELEFONO
			END IF;
			
		END IF;

		IF cCodRet1 = '00000' THEN
			IF iTipoTel = 1 THEN
				LET cTelCasa = '0';
			ELSE
				LET cTelCel = '0';
			END IF;
		ELSE
			IF iTipoTel = 1 THEN
				LET cTelCasa = '1';
			ELSE
				LET cTelCel =  '1';
			END IF;
		END IF;
	END LOOP;
	
	LET cCodRet2 = cCodRet1;
	LET cCodRet1 = cCodRet4;
		
    RETURN cCodRet1,cCodRet2,cTelCasa,cTelCel;
	
	END;
    
END PROCEDURE

DOCUMENT
'CREO: Marco Rivera',
'Fecha: 28/02/2019',
'BDD: bdinteg',
'Descripcion: SP para validar realizar todas las validaciones correspondiente',
'a los telefonos y comprobar que sean validos antes de realizar las insercciones ';

CREATE PROCEDURE "informix".sp_verifica_telefono_cel( p_Numcte CHAR(20), p_Telefono CHAR(13), p_TipoTelefono SMALLINT, p_TipoEjecucion SMALLINT)

RETURNING CHAR(5), CHAR (20);

--DeclaraciÃ³n de variables

	DEFINE v_verificado			CHAR (1);
	DEFINE v_CodRet 			CHAR(5);
	DEFINE iSqlErr				INTEGER;
	DEFINE iIsamErr				INTEGER;
	DEFINE cErrorInfo			CHAR(80);
	DEFINE v_numcte				CHAR (20);
	DEFINE v_sec				SMALLINT;

--InicializaciÃ³n de Variables

	LET v_CodRet 	 = '';
	LET v_verificado = 'F';
	LET v_numcte 	 = '';
	LET v_sec 		 = 0;
	
	--SET DEBUG FILE TO "/tmp/PAOLA/sp_verifica_telefono_cel.out";
	--TRACE ON;
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr != 0 THEN
			LET v_CodRet     = iSqlErr;
		END IF;
			RETURN v_CodRet, v_numcte;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		IF (p_Telefono = ''  AND p_TipoEjecucion = 2 ) OR (p_Telefono = '' AND p_Numcte = '' AND p_TipoEjecucion = 1 ) THEN
			LET v_CodRet = '00001';
			LET v_numcte ='';
			RETURN v_CodRet, v_numcte; 
		END IF;
		
		IF p_TipoEjecucion = 1 THEN
		
			SELECT MAX(verificado)
			  INTO v_verificado 
			  FROM bdinteg:"informix".si_telefonos 
			 WHERE numcte = p_Numcte 
			   AND telefono = p_Telefono 
			   AND tipo_tel = p_TipoTelefono
			   AND status_tel = 'A';

			IF (v_verificado = 'F') THEN
				LET v_CodRet = '00000';
			ELSE
				LET v_CodRet = '00001';
			END IF;
			
		RETURN v_CodRet, v_numcte;
			
		ELIF p_TipoEjecucion = 2 THEN
			
			SELECT MAX (numcte) 
			  INTO v_numcte 
			  FROM bdinteg:"informix".si_telefonos a 
			 WHERE telefono = p_Telefono
			   AND tipo_tel = p_TipoTelefono
			   AND status_tel = 'A'
			   AND secuencia = (SELECT MAX(secuencia) 
			                      FROM bdinteg:"informix".si_telefonos b 
							     WHERE b.telefono = a.telefono 
							       AND b.tipo_tel = a.tipo_tel 
								   AND b.status_tel = a.status_tel);
			
				IF (v_numcte <> '') THEN
					LET v_CodRet = '00000';
					RETURN v_CodRet, v_numcte; 
				ELSE
					LET v_CodRet = '00001';
					LET v_numcte ='';
					RETURN v_CodRet, v_numcte; 
				END IF;
		END IF;

	END
END PROCEDURE
DOCUMENT
'DESCRIPCION: Realiza la validaciÃ³n del telefono del cliente para saber si el tipo es F o V',
'AUTOR : Ever Fierro HernÃ¡ndez',
'FECHA : 29/10/2018',
'Folio : 480',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_limpia_si_ctessat_tmp()

RETURNING CHAR(5) AS CodRet;

DEFINE iSql_err 	INTEGER;
DEFINE cCodRet 		CHAR(5);
DEFINE cNumcte		CHAR(50);
DEFINE cCalle		CHAR(40);
DEFINE cNumext		CHAR(10);
DEFINE cNumint		CHAR(10);
DEFINE iContador 	INTEGER;

LET iSql_err		= 0;
LET cCodRet 		= '00000';
LET cNumcte			= '';
LET cCalle			= '';
LET cNumext			= '';
LET cNumint			= '';
LET iContador       = 0;

BEGIN

	ON EXCEPTION
		SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			ROLLBACK WORK;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/emm/sp_limpia_si_ctessat_tmp.out';
	--TRACE ON;
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN WORK;
	
	FOREACH WITH HOLD
	
		SELECT {+INDEX (si_ctessat_tmp idx_si_ctessat_tmp_numcte)}
			numcte,replace(calle,'|','') calle,replace(num_ext,'|','') num_ext,replace(num_int,'|','') num_int 
		INTO cNumcte,cCalle,cNumext,cNumint FROM "informix".si_ctessat_tmp
		
		LET iContador = iContador + 1;
	
		UPDATE "informix".si_ctessat_tmp SET calle=cCalle, num_int=cNumext, num_ext=cNumint WHERE numcte=cNumcte;
	
		IF( iContador = 500 ) THEN
            COMMIT WORK;
            LET iContador = 0;
			BEGIN WORK;
        END IF;
	
	END FOREACH;
	
	COMMIT WORK;	
	RETURN cCodRet;
	
END;
END PROCEDURE;