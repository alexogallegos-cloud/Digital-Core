CREATE PROCEDURE "informix".pase_act_hist(pempresa char(3))
RETURNING CHAR(5);

DEFINE cod_ret char(5);
DEFINE vnaturaleza,vtipo_mov char(1);
DEFINE vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector char(10);
DEFINE vmoneda char(2);
DEFINE v_ciudad char(3);
DEFINE vsucursal char(4);
DEFINE v_empresa char(3);
DEFINE vusuario,vpoliza_usuario char(8);
DEFINE vnro_auxiliar char(12);
DEFINE vdescripcion char(50);
DEFINE vmonto, vvalor_cambio, vvalor_div_cambio money(14,2);
DEFINE vfecha_captura, vfecha_valida date;
DEFINE vsecuencia integer;
DEFINE vcontrol_poliza integer;
DEFINE vpri_dia_mes date;
DEFINE vult_dia_mes date;
DEFINE vccost_orig char (4);
DEFINE vcontador INTEGER;

-- ****************************************************************************
-- Graba movimientos del Mensual en el Historico de Contabilidad
-- ****************************************************************************
LET vcontador = 1;
LET cod_ret = "000";
LET v_empresa = pempresa;

SET LOCK MODE TO WAIT;

SELECT pri_dia_mes, ult_dia_mes INTO vpri_dia_mes,vult_dia_mes FROM bdicont:co_fechas
    WHERE empresa = v_empresa;

FOREACH WITH HOLD
  SELECT usuario, control_poliza, fecha_captura, secuencia, empresa, ccmayor,
         ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
         sucursal, naturaleza, nro_auxiliar, monto, descripcion,
         fecha_valida, moneda, valor_cambio, valor_div_cambio,poliza_usuario,
         tipo_mov, ccosto_orig
  INTO vusuario, vcontrol_poliza, vfecha_captura, vsecuencia,v_empresa,vccmayor,
         vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector, v_ciudad,
         vsucursal, vnaturaleza, vnro_auxiliar, vmonto, vdescripcion,
         vfecha_valida, vmoneda, vvalor_cambio, vvalor_div_cambio,
         vpoliza_usuario,vtipo_mov, vccost_orig
  FROM co_historico_tmp
  WHERE fecha_captura between vpri_dia_mes AND vult_dia_mes

	IF vcontador=1 THEN
		BEGIN WORK;
	END IF;

  INSERT INTO co_historico
  VALUES (vusuario, vcontrol_poliza, vfecha_captura, vsecuencia, v_empresa,
         vccmayor,vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector, v_ciudad,
         vsucursal, vnaturaleza, vnro_auxiliar, vmonto, vdescripcion,
         vfecha_valida, vmoneda, vvalor_cambio, vvalor_div_cambio,
         vpoliza_usuario,vtipo_mov, vccost_orig);

	IF vcontador >=75000 THEN
		COMMIT WORK;
		LET vcontador=1;
	ELSE
		LET vcontador = vcontador + 1 ;
	END IF;

  CONTINUE FOREACH;
END FOREACH;

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
	END IF;

RETURN cod_ret;

END PROCEDURE;