CREATE PROCEDURE "informix".sp_cons_user_bei(pUsuario char(50))
   returning char(5),Integer,CHAR(9);

    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    
    DEFINE sIdUsuario Integer;
    DEFINE sNumCliente CHAR(9);
    

    LET cod_ret  = "000";
  	LET sIdUsuario = 0;
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
            RETURN cod_ret,  sIdUsuario,sNumCliente;

      END IF ;
   END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;

      	SELECT usr.num_cliente,usr.id_usuario INTO sNumCliente ,sIdUsuario
    	FROM bdibei:"informix".bei_usuario as usr
   		WHERE usr.usuario_bei =pUsuario;

   			IF(sIdUsuario IS NULL) OR (sIdUsuario==0) THEN
				LET cod_ret = '001';  -- Usuario NO EXISTE
			END IF;


  RETURN cod_ret,  sIdUsuario,sNumCliente;

END
END PROCEDURE;