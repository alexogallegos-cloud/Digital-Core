CREATE PROCEDURE "informix".sp_validalineacapgdf_bei(pLineaCap CHAR(20), pTipoServicio CHAR(4), pIdCatOperacion CHAR(4) )
 returning char(5), integer;

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;

	DEFINE sCount   INTEGER;
    LET cod_ret  = "00000";
    LET sCount = 0;

  BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
          let cod_ret = sql_err;
          RETURN cod_ret, sCount;
      END IF ;
   END EXCEPTION ;

    SET LOCK MODE TO WAIT 4;

    IF NVL(pLineaCap,'') =='' THEN
	 	  LET cod_ret = '00001'; -- No Agrego Linea de Captura
       RETURN cod_ret, sCount;
	END IF;

    IF NVL(pTipoServicio,'') =='' THEN
	 	  LET cod_ret = '00002'; -- No Agrego Tipo Servicio
       RETURN cod_ret, sCount;
	END IF;

    IF NVL(pIdCatOperacion,'') =='' THEN
	 	  LET cod_ret = '00003'; -- No Agrego Cat Operacion
       RETURN cod_ret, sCount;
	END IF;

    SELECT  COUNT(referencia)
    INTO    sCount
    FROM    bdibei:bei_operacionesmancomunadasoperador
    WHERE   tipo_servicio = pTipoServicio
    AND     statusoperacion = 'P'
    AND     id_cat_operacion = pIdCatOperacion
    AND     referencia = pLineaCap;

     RETURN cod_ret, sCount;

END;
END PROCEDURE;