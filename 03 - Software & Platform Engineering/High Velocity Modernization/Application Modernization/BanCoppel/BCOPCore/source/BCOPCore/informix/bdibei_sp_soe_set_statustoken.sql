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