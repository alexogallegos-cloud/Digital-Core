CREATE PROCEDURE "informix".sp_consulta_limites_beneficiarios_bei(pIdParam integer)
 returning char(5), INTEGER;

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE iLimiteBeneficiario INTEGER ;


    LET iLimiteBeneficiario=0;
    LET cod_ret  = "00000";
	
	--****************************************************************************************************
	-- DESCRIPCION: Consulta Limite de Beneficiarios para Dispersion Ordenes Pago Individual
	-- AUTOR : Solser
	-- FECHA : 12/02/2015
	-- BD: bdibei
	-- SOLICITO : SOLSER
	--***************************************************************************************************

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
          RETURN cod_ret, iLimiteBeneficiario;
      END IF ;
   END EXCEPTION ;

--**************************************************************************************************************
--***CONSULTA LIMITE DE BENEFICIARIOS
--**************************************************************************************************************
    SET LOCK MODE TO WAIT 4;
	IF NVL(pIdParam,0) == 0 THEN
	 	  LET cod_ret = '00001';  -- Valor IdParam es nulo
          RETURN cod_ret, iLimiteBeneficiario;
	END IF;

    SELECT valor
    INTO   iLimiteBeneficiario
    FROM   bdibpi:enet_parametros
    WHERE  id_param = pIdParam
    AND    tipo_dispersion=2;

    RETURN cod_ret, iLimiteBeneficiario;
END
END PROCEDURE;