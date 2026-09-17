CREATE PROCEDURE "informix".sp_user_per_cte_bei(pNumCliente char(9))
 returning char(5),   INTEGER ;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

    DEFINE iTotalUsuario INTEGER ;
    DEFINE iCountUsuario INTEGER ;
    DEFINE iCountManco INTEGER ;
    DEFINE iTotal INTEGER ;


    LET iTotalUsuario=0;
    LET iTotal=0;
    LET iCountUsuario=0;
      LET iCountManco=0;
    LET cod_ret  = "00000";

--****************************************************************************************************
-- DESCRIPCION:  OBTIENE LA CANTIDAD DE USUARIOS QUE PUEDEN SER CREADOS POR CUENTA
-- AUTOR : Irving Guzman Salas
-- FECHA : 24/05/2013
-- BD: bdibei
-- SOLICITO :
--***************************************************************************************************
  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, iCountUsuario;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************
     SET LOCK MODE TO WAIT 4;
	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No ay Registros
          RETURN cod_ret, iCountUsuario;
	END IF;

		IF NOT EXISTS ( SELECT num_cliente FROM "informix".bei_contratacion WHERE num_cliente=pNumCliente) THEN
			LET cod_ret = '00002'; -- No existe el Cliente
          	RETURN cod_ret, iCountUsuario;
		END IF;


            SELECT COUNT(*)
            INTO iCountUsuario
            FROM "informix".bei_usuario
            WHERE num_cliente=pNumCliente
            AND id_tipo_usuario=2;

            SELECT COUNT(*)
            INTO iCountManco
            FROM "informix".bei_admin_manco_temp
			WHERE num_cliente_admin=pNumCliente
			AND tipo_oper=1
			AND tipo_mov=1;

			LET iTotal=iCountUsuario+iCountManco;

            SELECT  oper_no_token
            INTO iTotalUsuario
            FROM bei_contratacion
            WHERE num_cliente=pNumCliente;

     IF (iTotal<iTotalUsuario) THEN
         LET cod_ret = '00000'; -- Aun se pueden crear Usuarios
     ELSE
     	 LET cod_ret = '00003'; -- No se pueden crear mas Usuarios
     END IF ;

        RETURN cod_ret,(iTotalUsuario-iCountUsuario);
END
END PROCEDURE;