CREATE PROCEDURE "informix".sp_actualizastusermanco_bei(
pIdAdminManco INTEGER,pNumCliente CHAR(9),pIdUsuario INTEGER,pAutoriza SMALLINT
,pIp CHAR(20),pSucursal CHAR(20),pUser CHAR(20))
 returning char(5) ,INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE stipoOper SMALLINT ;
    DEFINE sTipoMov SMALLINT ;

    DEFINE sIdUserAdmin 		INTEGER ;

  	DEFINE sIdUsuario 		INTEGER ;
  	DEFINE sNumCliente		CHAR(9);

  	DEFINE sIdStatus  		SMALLINT ;
	DEFINE sEmp 		CHAR(3);

	DEFINE sIdStatusToken  		SMALLINT ;
	DEFINE sNsToken 		CHAR(20) ;


    LET cod_ret     = "00000";
    LET sEmp     = "";
    LET stipoOper   = 0;
    LET sTipoMov    = 0;
    LET sIdUsuario  = 0;
	LET sIdStatus	= 0;
	LET sIdStatusToken  	= 0;
	LET sNsToken 	=	"";


--****************************************************************************************************
-- DESCRIPCION:  Ejecuta Proceso de Mancomuniadd Bloqueo Desbloqueo de Usuarios
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************

  BEGIN


    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret,sIdUsuario;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;


	IF NVL(pIdAdminManco,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cod_ret,sIdUsuario;
	END IF;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
       RETURN cod_ret,sIdUsuario;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Dato Id de Usuario
        RETURN cod_ret,sIdUsuario;
	END IF;
	IF NVL(pAutoriza,0) == 0 THEN
	 	  LET cod_ret = '00004'; -- No contiene Dato de Autorizacion
         RETURN cod_ret,sIdUsuario;
	END IF;

		SELECT  id_usuario_admin,manco.tipo_oper,manco.tipo_mov
	 	INTO  	sIdUserAdmin,stipoOper,sTipoMov
        FROM "informix".bei_admin_manco_temp  manco
        WHERE  manco.id_admin_manco  = pIdAdminManco
        AND manco.num_cliente_admin  = pNumCliente;


        IF NVL(stipoOper,999) == 999  THEN
        	 	  LET cod_ret = '00005'; --No contiene Dato de Tipo de Operacion
         RETURN cod_ret,sIdUsuario;
		END IF;

        IF NVL(sTipoMov,999) == 999  THEN
        	 	  LET cod_ret = '00006'; -- No contiene Dato de Tipo de Movimiento
        	 	  RETURN cod_ret,sIdUsuario;
		END IF;

     IF(pAutoriza==1)THEN
        IF stipoOper==1  THEN
--------------------------------------------------------
--------------------------------------------------------
------------------------- Bloqueo Desbloqueo Usuario ---
--------------------------------------------------------
--------------------------------------------------------
 			IF sTipoMov==6 THEN

            	SELECT  usu.id_usuario,usu.num_cliente,usu.id_status
            	INTO 	sIdUsuario,sNumCliente,sIdStatus
            	FROM "informix".bei_admin_manco_temp  usu
            	WHERE  usu.id_admin_manco  = pIdAdminManco
            	AND usu.num_cliente_admin=pNumCliente ;

            	EXECUTE PROCEDURE bdibei:"informix".sp_actualizastatususuario_bei(sEmp,sNumCliente,	sIdUsuario,sIdStatus,pIp,pSucursal,pUser,null)
				into cod_ret;

 				IF cod_ret='00000' THEN
 					SELECT ns_token,id_status_token
						INTO sNsToken,sIdStatusToken
						FROM "informix".bei_token
						WHERE num_cliente=pNumCliente
						AND id_usuario=sIdUsuario;

					IF sIdStatus == 70 THEN
						IF sIdStatusToken == 140 THEN
							EXECUTE PROCEDURE "informix".sp_actualiza_status_token_bei(sIdUsuario, sNumCliente,170,sNsToken)into cod_ret,sIdStatusToken;
						END IF;
					ELSE
						IF sIdStatus == 26 THEN
							IF sIdStatusToken == 170 THEN
								EXECUTE PROCEDURE "informix".sp_actualiza_status_token_bei(sIdUsuario, sNumCliente,140,sNsToken)into cod_ret,sIdStatusToken;
							END IF;
						END IF;
					END IF;
				ELSE
				  LET cod_ret = '00009'; --ERROR EN ACTUALIZACION DE ESTATUS USUARIO
        	 	  RETURN cod_ret,sIdUsuario;
				END IF;

            ELSE
              	LET cod_ret = '00007'; -- Valor Incorrecto de Tipo de Movimiento
        	 	RETURN cod_ret,sIdUsuario;
            END IF;
        ELSE
             LET cod_ret = '00008'; -- Valor Incorrecto de Tipo Operaciones
        	 RETURN cod_ret,sIdUsuario;
        END IF;
    ELSE
     END IF;

     RETURN cod_ret,sIdUsuario;
END
END PROCEDURE;