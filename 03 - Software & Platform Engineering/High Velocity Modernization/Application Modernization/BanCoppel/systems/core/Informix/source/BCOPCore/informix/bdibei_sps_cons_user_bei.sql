CREATE PROCEDURE "informix".sps_cons_user_bei(pIdUsuario Integer)
   returning char(5),Integer,CHAR(9);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    

    DEFINE sNumCliente CHAR(9);
    

    LET cod_ret  = "000";
    LET sNumCliente = '';

	--****************************************************************************************************
	-- DESCRIPCION:  OBTIENE DATOS USUARIO POR NOMBRE DE USUARIO , PARA VALIDACION INICIAL EMPRESANET
	-- AUTOR : Irving Guzman Salas - SOLSER
	-- FECHA : 28/08/2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- FECHA LIBERACION A PRODUCCION: 22-ENERO-2015
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret,  pIdUsuario,sNumCliente;

      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;

      	SELECT usr.num_cliente INTO sNumCliente 
    	FROM bdibei:"informix".bei_usuario as usr
   		WHERE usr.id_usuario =pIdUsuario;

   	


  RETURN cod_ret,  pIdUsuario,sNumCliente;

END
END PROCEDURE;