CREATE PROCEDURE "informix".sp_soe_folios(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro CHAR(20))
	RETURNING CHAR(5) AS codret,
		CHAR(50) AS mensajeError,
		CHAR(7) AS folio;

	DEFINE cCodRet CHAR(5);
	DEFINE cMensajeError CHAR(50);
	DEFINE cFolio CHAR(7);
	DEFINE iSqlErr INTEGER;
	DEFINE cValor CHAR(50);
	DEFINE iPosGuion SMALLINT;
	DEFINE i SMALLINT;
	DEFINE cC CHAR(1);
	DEFINE iContinuo INTEGER;
	
	LET cCodRet = '00000';
	LET cMensajeError = '';
	LET cFolio = '';
	LET iSqlErr = 0;
	LET cValor = '';
	LET iPosGuion = 0;
	LET cC = '';
	LET iContinuo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cMensajeError = 'ERROR INTERNO EN BASE DE DATOS';
			RETURN cCodRet, cMensajeError, cFolio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_folios.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParametro = '' THEN
			LET cCodRet = '00003';
			LET cMensajeError = 'FALTAN PARAMENTROS DE ENTRADA';
			RETURN cCodRet, cMensajeError, cFolio;
		END IF;
		
		-- ValidaciÃ³n del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET cMensajeError = 'SIN PRIVILEGIOS PARA EJECUTAR EL PROCEDIMIENTO';
			RETURN cCodRet, cMensajeError, cFolio;
		END IF;
		
		-- Buscamos el valor del parametro recibido
		SELECT valor
		INTO cValor
		FROM bdibei:"informix".soe_parametros
		WHERE parametro = pParametro;
		
		-- Buscamos la posicion del guiÃ³n
		FOR i = 0 TO LENGTH(TRIM(cValor))
			LET cC = SUBSTR(TRIM(cValor), i, 1);
			IF cC = '-' THEN
				LET iPosGuion = i + 1;
				EXIT FOR;
			END IF;
		END FOR;
		
		LET cValor = SUBSTR(TRIM(cValor), iPosGuion, 22);
		LET iContinuo = TO_NUMBER(TRIM(cValor));
		
		IF iContinuo > 9999999 THEN
			LET iContinuo = 0;
		END IF;	
		LET iContinuo = iContinuo + 1;
		
		-- Asignamos el entero a la variable del folio
		LET cValor = iContinuo;
		LET cFolio = iContinuo;
		
		FOR i = 1 TO ( 7 - LENGTH(TRIM(cValor)))
			LET cFolio = '0'||cFolio;
		END FOR;
		
		-- ActualizaciÃ³n del valor del folio
		UPDATE bdibei:"informix".soe_parametros
		   SET valor = cFolio,
		       f_modificacion = CURRENT
		WHERE parametro = pParametro;
		
		RETURN cCodRet, cMensajeError, cFolio;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 26/09/2013",
"DESCRIPCION: Procedimiento que obtienen un folio para SOE en SOC";

CREATE PROCEDURE "informix".sp_soe_generacodigoautenticacion(pUsuario CHAR(8), pIdFuncion CHAR(10), pRfc CHAR(13), pNoIdentificacion CHAR(30))
	RETURNING CHAR(5) AS codret,
			CHAR(8) AS codigo_email;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr integer;
	DEFINE cCodEmail CHAR(8);
	DEFINE iExiste INTEGER;
	DEFINE iCodEncontrado SMALLINT;
	DEFINE iCodGen INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cCodEmail = '';
	LET iExiste = 0;
	LET iCodEncontrado = 0;
	LET iCodGen = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodEmail;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_generacodigoautenticacion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRfc = '' OR pNoIdentificacion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCodEmail;
		END IF;
		
		-- ValidaciÃ³n del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCodEmail;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		WHILE iCodEncontrado = 0
			FOREACH EXECUTE PROCEDURE getrandomcode()  INTO iCodGen, cCodEmail
				
				SELECT COUNT(codigo_email)
				INTO iExiste
				FROM bdibei:soe_codigo_email
				WHERE codigo_email = cCodEmail;
				
				IF iExiste = 0 THEN
					INSERT INTO bdibei:"informix".soe_codigo_email(rfc, identificacion_admin, f_generacodigo, codigo_email, usu_autenticado)
					VALUES(pRfc, pNoIdentificacion, current, cCodEmail, 'f');
					
					LET iCodEncontrado = 1;
					EXIT FOREACH;
				END IF;
				
			END FOREACH;
			
			IF iCodEncontrado = 1 THEN
				EXIT WHILE;
			END IF;
		END WHILE;
		
		RETURN cCodRet, cCodEmail;
	END;
			
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 29/08/2013",
"DESCRIPCION: Procedimiento que genera un codigo de autenticaciÃ³n que sera envÃ­ado por e-mail";

CREATE PROCEDURE "informix".sp_soe_obtener_num_serie_token(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pIdUsuario INTEGER, pStatus INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(10) AS ns_token,
			INTEGER AS id_status_token;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE cNoSerieToken CHAR(10);
	DEFINE iIdStatusToken INTEGER;
	DEFINE iIdStatusTknSerie INTEGER;
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET cNoSerieToken = '';
	LET iIdStatusToken = 0;
	LET iIdStatusTknSerie = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obtener_num_serie_token.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumCliente = '' OR pIdUsuario = '' OR pStatus = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END IF;
		
		-- Validación del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END IF;
		
		-- Buscamos que el cliente existe
		SELECT COUNT(num_cliente)
		INTO iExiste
		FROM bdibei:"informix".bei_token
		WHERE num_cliente = pNumCliente AND id_usuario = pIdUsuario;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00184'; -- El usuario no existe
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END IF;
		
		SELECT ns_token, id_status_token
		INTO cNoSerieToken, iIdStatusToken
		FROM bdibei:"informix".bei_token
		WHERE num_cliente = pNumCliente AND id_usuario = pIdUsuario;
		
		IF cNoSerieToken IS NULL OR TRIM(cNoSerieToken) = '' THEN
			LET cCodRet = '00185'; -- Usuario sin token asignado
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END IF;
		
		SELECT id_status
		INTO iIdStatusTknSerie
		FROM bdibpi:"informix".tkn_nseries
		WHERE ns_token = cNoSerieToken;		
		
		IF (iIdStatusToken < 140) OR (iIdStatusTknSerie < 140) THEN
			LET cCodRet = '00186'; -- Token de usuario no activado
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;		
		ELIF iIdStatusToken = '152' AND pStatus = '152' THEN
			LET cCodRet = '00187'; -- el token ya se encuentra bloqueado
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		ELIF iIdStatusToken = '140' AND pStatus = '160' THEN
			LET cCodRet = '00215'; -- el token ya se encuentra desbloqueado
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		ELIF iIdStatusToken = 199 THEN
			LET cCodRet = '00188'; -- token cancelado
			RETURN cCodRet, cNoSerieToken, iIdStatusToken;
		END IF;
		
		RETURN cCodRet, cNoSerieToken, iIdStatusToken;
	
	END;
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 05/09/2013",
"DESCRIPCION: Obtiene el numero de serie de token de un cliente en SOE, en la plataforma SOC",
"AUTOR: Jose Luis Polanco B.",
"FECHA 15/10/2013",
"DESCRIPCION: Se modifica sp para validar el status de la tabla bdibpi:tkn_nseries y validacion para cuando ya se encuentre desbloquedo el token";

CREATE PROCEDURE "informix".sp_soe_obtparametro(pUsuario CHAR(8), pIdFuncion CHAR(10), pParametro CHAR(20))
	RETURNING CHAR(5) AS codret,
			CHAR(50) AS mensaje_error,
			CHAR(50) AS valor;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cMensajeError CHAR(50);
	DEFINE cValor CHAR(50);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cMensajeError = '';
	LET cValor = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cMensajeError = 'ERROR INTERNO EN BASE DE DATOS';
			RETURN cCodRet, cMensajeError, cValor;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_soe_obtparametro.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pParametro = '' THEN
			LET cCodRet = '00003';
			LET cMensajeError = 'PARAMETROS INCORRECTOS';
			RETURN cCodRet, cMensajeError, cValor;
		END IF;
		
		-- ValidaciÃ³n del acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET cMensajeError = 'SIN PRIVILEGIOS PARA EJECUTAR EL PROCEDIMIENTO';
			RETURN cCodRet, cMensajeError, cValor;
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		SELECT valor
		INTO cValor
		FROM bdibei:"informix".soe_parametros
		WHERE TRIM(parametro) = TRIM(pParametro);
		
		IF cValor IS NULL OR TRIM(cValor) = '' THEN
			LET cCodRet = '00190';
			LET cMensajeError = 'NO EXISTE VALOR PARA ESTE PARAMETRO';
			RETURN cCodRet, cMensajeError, cValor;
		END IF;
		
		RETURN cCodRet, cMensajeError, cValor;
	
	END;
			
END PROCEDURE
DOCUMENT "AUTOR: Saul Ortiz Baeza",
"FECHA: 05/09/2013",
"DESCRIPCION: Obtiene el valor de un parametro para la aplicaciÃ³n SOE, en la plataforma SOC";

CREATE PROCEDURE "informix".sp_soe_set_statustoken(pIdUsuario CHAR(8), pIdFuncion CHAR(10),pNsToken CHAR(9), pEstatusViejo SMALLINT, pEstatusNuevo SMALLINT, 
										pUsuAtendido CHAR(8), pCanal CHAR(2))
	RETURNING
			CHAR(5) AS v_cod_ret,
			VARCHAR(50) AS vMensajeErr;
			
	DEFINE iExiste		SMALLINT;
	DEFINE v_cod_ret    CHAR(5);
	DEFINE vMensajeErr	VARCHAR(50);
	DEFINE iSqlErr      INTEGER;
	DEFINE iSamErr      INTEGER;
	DEFINE iIdStatus 	SMALLINT;
	
	LET iExiste		=0;	
	LET v_cod_ret	='00000';
	LET vMensajeErr = '';
	LET iIdStatus = pEstatusNuevo;
	
	BEGIN
		ON EXCEPTION
			SET iSqlErr, iSamErr
			IF iSqlErr <> 0 THEN
				LET v_cod_ret = iSqlErr;
				LET vMensajeErr= 'ERROR INTERNO EN BASE DE DATOS';
			END IF;			
			RETURN v_cod_ret,vMensajeErr;
		END EXCEPTION;
		
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO v_cod_ret;
		IF v_cod_ret <> '00000' THEN
			RETURN v_cod_ret,vMensajeErr;
		END IF;
	
		IF pNsToken = '' OR pEstatusViejo = '' OR pEstatusNuevo = '' OR pUsuAtendido = '' OR pCanal = '' THEN
			LET v_cod_ret = '00003';
			LET vMensajeErr= 'PARAMETROS INCORRECTOS';
			RETURN v_cod_ret,vMensajeErr; 
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		/*SELECT COUNT(*)
		INTO iExiste
		FROM bdibpi:tkn_nseries a
		WHERE a.ns_token = pNsToken AND a.id_status = pEstatusViejo;

		IF iExiste = 0 THEN
				LET v_cod_ret = '00189';
				LET vMensajeErr= pEstatusViejo;
				RETURN v_cod_ret,vMensajeErr; 
		END IF;*/
		
		IF pEstatusNuevo = 160 THEN
			LET iIdStatus = '140';
			LET pEstatusNuevo = '140';
		END IF;
		
		UPDATE bdibpi:"informix".tkn_nseries
	       SET id_status = iIdStatus,
		       f_status = CURRENT,
		       canal = pCanal
	     WHERE ns_token = pNsToken
	       AND id_status = pEstatusViejo;
			   
		SET LOCK MODE TO WAIT 3;
		INSERT INTO bdibpi:"informix".tkn_status_token(ns_token, anterior, actual, f_cambio_status, usr_cambio_status, canal)
		VALUES(pNsToken, pEstatusViejo, pEstatusNuevo, CURRENT, pUsuAtendido, pCanal);
		
		RETURN v_cod_ret,vMensajeErr;		
	END;

END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 26/09/2013",
"DESCRIPCION: Guarda el estatus del token para SOE en SOC",
"AUTOR: Jose Luis Polanco B.",
"FECHA: 15/10/2013",
"DESCRIPCION: Se inhibe validación de que si existe en la tabla bdibpi:tkn_nseries";

CREATE PROCEDURE "informix".sp_actualiza_aut_manc_bei(pIdUser INTEGER,pNumCte CHAR(9),pNumCta CHAR(16),pAutoriza CHAR(1))
   returning char(5);


    DEFINE cCod_ret char(5);
    DEFINE sql_err integer ;

    LET cCod_ret  = "00000";


--****************************************************************************************************
-- DESCRIPCION:  Actualiza Autorizacion de Mancomunidad por Cuenta
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cCod_ret = sql_err;
            RETURN cCod_ret;
      END IF ;
   END EXCEPTION ;


SET LOCK MODE TO WAIT 4;

	 IF NVL(pIdUser,-1) == -1 THEN
		LET cCod_Ret = '00002';   ---No se Recibio ID de Usuario
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pNumCte,'') == '' THEN
		LET cCod_Ret = '00003';   ---No se Recibio Numero de Cliente
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pNumCta,'') == '' THEN
		LET cCod_Ret = '00004';   ---No se Recibio Numero de Cuenta
	    RETURN cCod_ret;
	 END IF;

	 IF NVL(pAutoriza,'') == '' THEN
		LET cCod_Ret = '00005';   ---No se Recibio valor de Autorizacion
	    RETURN cCod_ret;
	 END IF;


 	IF EXISTS ( 	SELECT id_usuario
	   				FROM bdibei:"informix".bei_mancomunidad
	   				WHERE id_usuario =pIdUser
					AND num_cte = pNumCte
					AND num_cta = pNumCta) THEN


		UPDATE  bdibei:"informix".bei_mancomunidad
		SET autoriza = pAutoriza
		WHERE id_usuario = pIdUser
		AND num_cte =pNumCte
		AND num_cta =pNumCta;

	ELSE
	    INSERT INTO bdibei:"informix".bei_mancomunidad
		(id_usuario,num_cte,num_cta,autoriza) VALUES
		(pIdUser, pNumCte,pNumCta, pAutoriza );
	END IF;


  RETURN cCod_ret;


END
END PROCEDURE;