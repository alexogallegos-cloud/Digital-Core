CREATE PROCEDURE "informix".act_sdodias(pempresa char(3),pfecha_hoy date)
RETURNING CHAR(5);

DEFINE sql_err INTEGER;

DEFINE cod_ret       char(5);
DEFINE vccmayor,vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector char(10);
DEFINE vmoneda       char(2);
DEFINE vciudad       char(3);
DEFINE vsucursal     char(4);
DEFINE v_empresa     char(3);
DEFINE vnro_auxiliar char(12);
DEFINE v_auxiliar    char(1);
DEFINE v_cuantos     integer;

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

	LET cod_ret = "152";

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = pfecha_hoy
                                      AND descripcion_cierre="ACT_SDODIAS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

-- ****************************************************************************
-- Obtiene la cta. y si maneja o no auxiliar en co_diario y si_catalog
-- ****************************************************************************
FOREACH
  SELECT unique d.empresa  , d.ccmayor   , d.ccsub , d.ccsubsub,
                d.ccssubsub, d.ccsssubsub, d.sector, d.ciudad,
                filtrasuc (d.sucursal, region_suc) , d.nro_auxiliar, d.moneda,
                c.auxiliar
  INTO          v_empresa  , vccmayor    ,vccsub         ,vccsubsub,
                vccssubsub , vccsssubsub ,vsector        ,vciudad,
                vsucursal  , vnro_auxiliar , vmoneda    ,v_auxiliar
  FROM  co_diario d, bdinteg:si_catalog c
  WHERE d.empresa    = c.empresa    AND
        d.ccmayor    = c.ccmayor    AND
        d.ccsub      = c.ccsub      AND
        d.ccsubsub   = c.ccsubsub   AND
        d.ccssubsub  = c.ccssubsub  AND
        d.ccsssubsub = c.ccsssubsub AND
        d.sector     = c.sector     AND
        d.empresa    = pempresa     AND
        c.empresa    = pempresa

   SELECT count(*)
   INTO   v_cuantos
   FROM   co_sdodias
   where co_sdodias.empresa    = v_empresa    AND
         co_sdodias.ccmayor    = vccmayor     AND
         co_sdodias.ccsub      = vccsub       AND
         co_sdodias.ccsubsub   = vccsubsub    AND
         co_sdodias.ccssubsub  = vccssubsub   AND
         co_sdodias.ccsssubsub = vccsssubsub  AND
         co_sdodias.sector     = vsector      AND
         co_sdodias.ciudad     = vciudad      AND
         co_sdodias.sucursal   = vsucursal    AND
         co_sdodias.moneda     = vmoneda      AND
         co_sdodias.mes_dia    = pfecha_hoy;

   IF v_cuantos = 0 then
      INSERT INTO co_sdodias VALUES (
             v_empresa ,
             vccmayor ,
             vccsub ,
             vccsubsub ,
             vccssubsub ,
             vccsssubsub ,
             vsector ,
             vciudad ,
             vsucursal ,
             vmoneda,
             pfecha_hoy, 0,0,0,0,0,0,0,0,0);
   END IF
   LET v_cuantos = 0;
   IF (v_auxiliar = "S") then
      SELECT count(*)
      INTO  v_cuantos
      FROM  co_diasaux
      WHERE co_diasaux.empresa    = v_empresa     AND
            co_diasaux.ccmayor    = vccmayor      AND
            co_diasaux.ccsub      = vccsub        AND
            co_diasaux.ccsubsub   = vccsubsub     AND
            co_diasaux.ccssubsub  = vccssubsub    AND
            co_diasaux.ccsssubsub = vccsssubsub   AND
            co_diasaux.sector     = vsector       AND
            co_diasaux.ciudad     = vciudad       AND
            co_diasaux.sucursal   = vsucursal     AND
            co_diasaux.auxiliar   = vnro_auxiliar AND
            co_diasaux.moneda     = vmoneda       AND
            co_diasaux.mes_dia    = pfecha_hoy;

      IF v_cuantos = 0 then
         INSERT INTO co_diasaux VALUES(
         v_empresa,
         vccmayor,
         vccsub,
         vccsubsub,
         vccssubsub,
         vccsssubsub,
         vsector,
         vciudad,
         vsucursal,
         vnro_auxiliar,
         vmoneda,
         pfecha_hoy, 0,0,0,0,0,0,0,0,0);
      END IF
   END IF
END FOREACH;

LET cod_ret = "000";

RETURN COD_RET;
END PROCEDURE;