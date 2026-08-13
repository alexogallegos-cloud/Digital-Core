CREATE PROCEDURE "informix".act_mens(pempresa CHAR(3))
RETURNING CHAR(5);

DEFINE sql_err INTEGER;

DEFINE cod_ret  char(5);
DEFINE vnaturaleza,vtipo_mov char(1);
DEFINE vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector char(10);
DEFINE vmoneda char(2);
DEFINE vciudad char(3);
DEFINE vsucursal char(4);
DEFINE v_empresa char(3);
DEFINE vusuario,vpoliza_usuario char(8);
DEFINE vnro_auxiliar char(12);
DEFINE vdescripcion char(50);
DEFINE vmonto money(18,2);
DEFINE vvalor_cambio, vvalor_div_cambio money(12,7);
DEFINE vfecha_captura, vfecha_valida date;
DEFINE vsecuencia, vcontrol_poliza integer;
DEFINE vfecha_hoy,v_pridiames  date;
DEFINE vccosto_orig char(4);

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

-- Graba los movimientos del Diario en el Mensual de Contabilidad
LET cod_ret = "151";

SELECT fecha_hoy,pri_dia_mes
INTO   vfecha_hoy,v_pridiames
FROM   co_fechas
WHERE  empresa = pempresa;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = vfecha_hoy
                                      AND descripcion_cierre="ACT_MENS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

	FOREACH
	  SELECT usuario,control_poliza,fecha_captura,secuencia,empresa,
	         ccmayor,ccsub,ccsubsub,ccssubsub,ccsssubsub,
	         sector,ciudad,sucursal,naturaleza,nro_auxiliar,
		 monto ,descripcion,fecha_valida,moneda,valor_cambio,
		 valor_div_cambio,poliza_usuario,tipo_mov,ccosto_orig
	  INTO   vusuario,vcontrol_poliza,vfecha_captura,vsecuencia ,v_empresa,
	         vccmayor,vccsub,vccsubsub,vccssubsub,vccsssubsub,
		 vsector,vciudad,vsucursal,vnaturaleza,vnro_auxiliar,
		 vmonto,vdescripcion,vfecha_valida,vmoneda,vvalor_cambio,
		 vvalor_div_cambio,vpoliza_usuario,vtipo_mov,vccosto_orig
	  FROM   co_diario
	  WHERE  empresa = pempresa

	  IF vfecha_valida >= v_pridiames THEN
	     INSERT INTO co_mensual
	     VALUES (vusuario, vcontrol_poliza, vfecha_captura, vsecuencia , v_empresa,
	             vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub,
	             vsector , vciudad, vsucursal, vnaturaleza, vnro_auxiliar,
	             vmonto  , vdescripcion, vfecha_valida , vmoneda, vvalor_cambio,
	             vvalor_div_cambio, vpoliza_usuario,vtipo_mov,vccosto_orig);
	  ELSE
	     INSERT INTO co_historico
	     VALUES (vusuario, vcontrol_poliza, vfecha_captura, vsecuencia , v_empresa,
	             vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub,
	             vsector , vciudad, vsucursal, vnaturaleza, vnro_auxiliar,
	             vmonto  , vdescripcion, vfecha_valida, vmoneda, vvalor_cambio,
	             vvalor_div_cambio, vpoliza_usuario,vtipo_mov,vccosto_orig);
	  END IF
	END FOREACH;

	LET cod_ret = "000";

RETURN cod_ret;
END PROCEDURE;