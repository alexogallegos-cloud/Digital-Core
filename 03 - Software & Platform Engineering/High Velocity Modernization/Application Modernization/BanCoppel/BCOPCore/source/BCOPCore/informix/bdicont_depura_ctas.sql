CREATE PROCEDURE "informix".depura_ctas(pempresa char(3))
RETURNING char(5);

   DEFINE sql_err INTEGER;
   DEFINE cod_ret    char(5);
   DEFINE vfecha_hoy date;

    ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/depura_ctas.out';
	--TRACE ON;

   LET cod_ret = "111";

   SELECT fecha_hoy 
	 INTO vfecha_hoy
   FROM co_fechas
   WHERE empresa = pempresa;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = vfecha_hoy
                                      AND descripcion_cierre="DEPURA_CTAS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

   DELETE
   FROM co_sdodias
   WHERE empresa          = pempresa
     AND saldo_inicio_dia = 0
     AND cargos_dia       = 0
     AND abonos_dia       = 0
     AND saldo_fin_de_dia = 0
     AND saldo_acumulado  = 0;

   DELETE
   FROM co_diasaux
   WHERE empresa          = pempresa
     AND saldo_inicio_dia = 0
     AND cargos_dia       = 0
     AND abonos_dia       = 0
     AND saldo_fin_de_dia = 0
     AND saldo_acumulado  = 0;

   LET cod_ret = "000";

RETURN cod_ret;
END procedure;