CREATE PROCEDURE "informix".act_hist(pempresa char(3))
RETURNING CHAR(5);

DEFINE sql_err INTEGER;

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
DEFINE v_fecha_hoy date;
DEFINE vccost_orig char (4);
DEFINE vcontador INTEGER;

	ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
        RETURN cod_ret;
     END EXCEPTION;

-- ****************************************************************************
-- Graba movimientos del Mensual en el Historico de Contabilidad
-- ****************************************************************************
LET vcontador = 1;
LET cod_ret = "156";
LET v_empresa = pempresa;

SELECT fecha_hoy INTO v_fecha_hoy FROM co_fechas
    WHERE empresa = v_empresa;

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = v_fecha_hoy
                                      AND descripcion_cierre="ACT_HIST"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF


IF EXISTS (select tabname from bdicont:systables where tabname='co_historico_tmp') THEN
	DROP TABLE co_historico_tmp;
END IF

CREATE TABLE "informix".co_historico_tmp
  (
    usuario char(8) not null,
    control_poliza integer not null,
    fecha_captura date not null,
    secuencia integer not null,
    empresa char(3) not null,
    ccmayor char(4) not null,
    ccsub char(2) not null,
    ccsubsub char(2) not null,
    ccssubsub char(2) not null,
    ccsssubsub char(2) not null,
    sector char(2) not null,
    ciudad char(3) not null,
    sucursal char(4),
    naturaleza char(1),
    nro_auxiliar char(12) not null,
    monto money(14,2) not null,
    descripcion char(50) not null,
    fecha_valida date not null,
    moneda char(2) not null,
    valor_cambio money(12,7) not null,
    valor_div_cambio money(12,7) not null,
    poliza_usuario char(8),
    tipo_mov char(1),
    ccosto_orig char(4),
    primary key (usuario,control_poliza,fecha_captura,secuencia,empresa)  
  )  extent size 2197264 next size 219728 lock mode row;

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
  FROM co_mensual
  WHERE empresa = v_empresa

	IF vcontador=1 THEN
		BEGIN WORK;
	END IF;

  INSERT INTO co_historico_tmp
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

	CREATE INDEX "informix".idx1_co_historico_tmp ON "informix".co_historico_tmp(fecha_captura) USING btree FILLFACTOR 99 ONLINE;
	UPDATE STATISTICS MEDIUM FOR TABLE co_historico_tmp(fecha_captura);

LET cod_ret = "000";

RETURN cod_ret;

END PROCEDURE;