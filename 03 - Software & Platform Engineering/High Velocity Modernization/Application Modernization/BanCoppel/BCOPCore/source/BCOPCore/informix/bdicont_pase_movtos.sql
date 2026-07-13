CREATE PROCEDURE "informix".pase_movtos(pempresa char(3),pfecha_hoy date)
RETURNING CHAR(5);

DEFINE sql_err INTEGER;

DEFINE vnaturaleza,
       vtipo_mov         char(1);
DEFINE vccmayor,
       vccsub,
       vccsubsub,
       vccssubsub,
       vccsssubsub,
       vsector           char(10);
DEFINE vmoneda           char(2);
DEFINE vciudad           char(3);
DEFINE vsucursal         char(4);
DEFINE w_empresa         char(3);
DEFINE vusuario char(8);
DEFINE vpoliza_usuario   char(8);
DEFINE vnro_auxiliar     char(12);
DEFINE vdescripcion      char(50);
DEFINE vmonto            money(14,2);
DEFINE vvalor_cambio,
       vvalor_div_cambio money(12,7);
DEFINE vfecha_captura,
       vfecha_valida     date;
DEFINE vsecuencia,
       vcontrol_poliza   integer;
DEFINE v_rowid           integer;
DEFINE pfecha_hoy1       date;
DEFINE vexiste           integer;
DEFINE vccosto_orig      char(4);
DEFINE vcontador INTEGER;
DEFINE cod_ret char(5);
DEFINE begintran smallint;

    ON EXCEPTION SET sql_err 
        LET cod_ret = sql_err;
		IF begintran = 1 THEN
			ROLLBACK WORK;
		END IF
        RETURN cod_ret;
     END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/pase_movtos.out';
	--TRACE ON;

-- Inicializa variables de trabajo

   LET vnaturaleza   = " ";
   LET vsucursal     = " ";
   LET vusuario      = " ";
   LET vnro_auxiliar = 0;
   LET vexiste       = 1;
   LET vcontador = 1;
   LET cod_ret = "111";

    IF EXISTS (SELECT codigo_retorno FROM co_cierre_cif 
				                    WHERE cierre_fecha = pfecha_hoy
                                      AND descripcion_cierre="PASE_MOVTOS"
									  AND codigo_retorno = '000') THEN
   
		LET cod_ret = "999";
		RETURN cod_ret;
	END IF

-- Elimina los movimientos contenidos en el diario antes de cada pase
    TRUNCATE co_diario;

-- Graba en el Diario los movimientos de polizas con la fecha del calendario
	FOREACH WITH HOLD
	  SELECT rowid, usuario, control_poliza, fecha_captura, secuencia, ccmayor,
	         ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, ciudad,
		 sucursal, naturaleza, nro_auxiliar, monto, descripcion_det,
		 fecha_valida, moneda, valor_cambio, valor_div_cambio, empresa,
		 poliza_usuario,tipo_mov,ccosto_orig
	         INTO v_rowid, vusuario, vcontrol_poliza, vfecha_captura, vsecuencia,
	         vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector, vciudad,
		 vsucursal, vnaturaleza, vnro_auxiliar, vmonto, vdescripcion,
		 vfecha_valida, vmoneda, vvalor_cambio, vvalor_div_cambio, w_empresa ,
		 vpoliza_usuario,vtipo_mov,vccosto_orig
	  FROM co_detpol
	 WHERE empresa = pempresa
	   AND fecha_captura = pfecha_hoy
	   AND control_poliza != 0
	   AND sucursal > 0 
	  AND naturaleza in ('C','D')

	  IF vcontador=1 THEN
		BEGIN WORK;
		LET begintran = 1;
	  END IF;

	  IF vnro_auxiliar is null then
	     LET vnro_auxiliar = 0;
	  END IF

	  IF vciudad is null then
	     LET vciudad = 0;
	  END IF

	  IF vdescripcion is null then
	     LET vdescripcion = " ";
	  END IF

	  INSERT INTO co_diario
	  VALUES (vusuario, vcontrol_poliza, vfecha_captura, vsecuencia, w_empresa,
	          vccmayor, vccsub, vccsubsub, vccssubsub, vccsssubsub, vsector,
	          vciudad, vsucursal, vnaturaleza, vnro_auxiliar, vmonto, vdescripcion,
		  vfecha_valida, vmoneda, vvalor_cambio, vvalor_div_cambio,
		  vpoliza_usuario,vtipo_mov,vccosto_orig);

		IF vcontador >=50000 THEN
			COMMIT WORK;
			UPDATE STATISTICS MEDIUM FOR TABLE bdicont:co_diario;
			LET vcontador=1;
		ELSE
			LET vcontador = vcontador + 1 ;
		END IF;
  	    CONTINUE FOREACH;
	END FOREACH;

	IF vcontador > 1 THEN
        COMMIT WORK;
		LET vcontador=1; 
		LET begintran = 0;
	END IF;

BEGIN WORK;
	LET begintran = 1;

	DELETE FROM co_poliza
	WHERE fecha_captura = pfecha_hoy
	AND empresa = pempresa;

	DELETE FROM co_detpol
	WHERE empresa = pempresa
	   AND fecha_captura = pfecha_hoy
	   AND control_poliza != 0
	   AND sucursal > 0 
	  AND naturaleza in ('C','D');

COMMIT WORK;
LET begintran = 0;

LET cod_ret = "000";

RETURN cod_ret;
END PROCEDURE;