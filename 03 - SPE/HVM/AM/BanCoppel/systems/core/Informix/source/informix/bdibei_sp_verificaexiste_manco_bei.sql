CREATE PROCEDURE "informix".sp_verificaexiste_manco_bei(pNumCliente CHAR(9),pTipoOper SMALLINT,pTipoMov SMALLINT,pIdUsuario INTEGER, pNSToken CHAR(10) )
RETURNING CHAR(5),char(5);

    DEFINE sql_err INTEGER;
	DEFINE cCod_ret CHAR (5);
    DEFINE vExist CHAR(5);


    LET cCod_ret = '00000';
    LET vExist = '00000';

--****************************************************************************************************
-- DESCRIPCION:  Busca si la operacion a realiza requiere mancomunidad.
-- AUTOR : SOLSER
-- FECHA : 
-- BD: bdibei
-- SOLICITO :BanCoppel
-- Liberado a produccion: Mayo 2014
--***************************************************************************************************


BEGIN
    ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            LET cCod_ret = sql_err;
            RETURN cCod_ret,vExist;
      END IF ;
    END EXCEPTION ;

    IF NVL(pTipoMov,0) == 0 THEN
	 	  LET cCod_ret = '00001'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cCod_ret,vExist;
	END IF;

	IF NVL(pTipoOper,0) == 0 THEN
	 	  LET cCod_ret = '00002'; -- No contiene Dato de ID de Mancomunidad Temporal
          RETURN cCod_ret,vExist;
	END IF;

	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cCod_ret = '00003'; -- No contiene Dato de Numero de Cliente
       RETURN cCod_ret,vExist;
	END IF;


    IF (pTipoOper == 1) THEN
     	IF(pTipoMov==1) THEN
     	 	RETURN cCod_ret,vExist;
     	END IF;

       	SELECT COUNT(id_admin_manco)
    	INTO vExist
   	 	FROM bei_admin_manco_temp
   		WHERE num_cliente_admin= pNumCliente
		AND tipo_oper= pTipoOper
		AND tipo_mov = pTipoMov
		AND id_usuario=pIdUsuario;
	ELIF (pTipoOper==2) THEN

        IF(pTipoMov == 4) THEN
			SELECT COUNT(id_admin_manco)
			INTO vExist
			FROM bei_admin_manco_temp
			WHERE num_cliente_admin= pNumCliente
			AND tipo_oper= pTipoOper
			AND tipo_mov = pTipoMov
			AND (id_usuario = nvl(pIdUsuario, 0) OR ns_token=nvl(pNSToken, ''));
		ELSE
			SELECT COUNT(id_admin_manco)
			INTO vExist
			FROM bei_admin_manco_temp
			WHERE num_cliente_admin= pNumCliente
			AND tipo_oper= pTipoOper
			AND tipo_mov = pTipoMov
			AND ns_token=pNSToken;
		END IF;

    END IF;

    RETURN cCod_ret,vExist;

END

END PROCEDURE;