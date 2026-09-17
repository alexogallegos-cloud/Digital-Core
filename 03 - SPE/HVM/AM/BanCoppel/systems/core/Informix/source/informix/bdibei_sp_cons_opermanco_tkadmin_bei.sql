CREATE PROCEDURE "informix".sp_cons_opermanco_tkadmin_bei(pIdAdminManco INTEGER,pNumCliente CHAR(9),pIdUsuario INTEGER)
 returning char(5) ,SMALLINT,SMALLINT,INTEGER, CHAR(10) ,INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE stipoOper SMALLINT ;
    DEFINE sTipoMov SMALLINT ;

  	DEFINE sIdUsuario 		INTEGER ;

    DEFINE sNsToken CHAR(10) ;
    DEFINE sIdStatusToken INTEGER ;

    LET cod_ret  = "00000";

    LET stipoOper  = 0;
    LET sTipoMov  = 0;
    LET sIdUsuario  = 0;
    LET sNsToken  = "";
    LET sIdStatusToken  = 0;


--****************************************************************************************************
-- DESCRIPCION:  Ejecuta Proceso de Mancomuniadd
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************


  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret,stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken  ;
      END IF ;
   END EXCEPTION ;

     SET LOCK MODE TO WAIT 4;

	IF NVL(pIdAdminManco,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cod_ret,stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken  ;
	END IF;

	IF NVL(pNumCliente,'') == '' THEN
	 	  LET cod_ret = '00002'; -- No contiene Dato de Numero de Cliente
        RETURN cod_ret,stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken  ;
	END IF;

	IF NVL(pIdUsuario,0) == 0 THEN
	 	  LET cod_ret = '00003'; -- No contiene Dato Id de Usuario
        RETURN cod_ret,stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken  ;
	END IF;


		SELECT  manco.tipo_oper,manco.tipo_mov, manco.id_usuario,manco.ns_token,manco.id_status_token
	 	INTO  	stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken
        FROM "informix".bei_admin_manco_temp  manco
        WHERE  manco.id_admin_manco  = pIdAdminManco
        AND manco.num_cliente_admin  = pNumCliente
        AND manco.id_usuario_admin  <> pIdUsuario
        AND manco.id_usuario <> pIdUsuario;


        IF NVL(stipoOper,999) == 999  THEN
        	 	  LET cod_ret = '00004'; --No contiene Dato de Tipo de Operacion
		END IF;

        IF NVL(sTipoMov,999) == 999  THEN
        	 	  LET cod_ret = '00005'; -- No contiene Dato de Tipo de Movimiento
		END IF;


 		IF stipoOper==2 THEN
            IF sTipoMov==4 THEN
				LET cod_ret = '00000'; -- Valor correcto de Tipo de Movimiento
            ELIF sTipoMov==5 THEN
    	 		LET cod_ret = '00000'; -- Valor correcto de Tipo de Movimiento
            ELSE
              	LET cod_ret = '00006'; -- Valor Incorrecto de Tipo de Movimiento
            END IF;
        ELSE
             LET cod_ret = '00007'; -- Valor Incorrecto de Tipo Operaciones
        END IF;



     RETURN cod_ret,stipoOper,sTipoMov,sIdUsuario, sNsToken,sIdStatusToken  ;
END
END PROCEDURE;