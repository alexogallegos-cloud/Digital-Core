CREATE PROCEDURE "informix".sp_cons_num_oper_bei(pNumCliente char(9))
 returning char(5), INTEGER;


    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE iTotalOpers INTEGER ;


    LET iTotalOpers=0;
    LET cod_ret  = "00000";
	
	--****************************************************************************************************
	-- DESCRIPCION: Consulta La cantidad de operadores de una empresa
	-- AUTOR : Solser
	-- FECHA : 25/02/2014
	-- BD: bdibei
	-- SOLICITO : BanCoppel
	-- Liberado a Producción: Mayo 2014
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, iTotalOpers;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA TOTAL DE REGISTROS DE TOKEN
--**************************************************************************************************************
     SET LOCK MODE TO WAIT 4;
	IF NVL(pNumCliente,0) == 0 THEN
	 	  LET cod_ret = '00001'; -- No ay Registros
          RETURN cod_ret, iTotalOpers;
	END IF;

		IF NOT EXISTS ( SELECT num_cliente FROM bdibei:"informix".bei_contratacion WHERE num_cliente=pNumCliente) THEN
			LET cod_ret = '00002'; -- No existe el Cliente
          	RETURN cod_ret, iTotalOpers;
		END IF;

            SELECT COUNT(*)
            INTO iTotalOpers
            FROM bdibei:"informix".bei_usuario
            WHERE num_cliente=pNumCliente
            and id_tipo_usuario=2;    

        RETURN cod_ret,iTotalOpers;
END
END PROCEDURE;