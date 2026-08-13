CREATE PROCEDURE "informix".executaedoctageneral_solo(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
--------------------------------------------------------
--	INICIALIZACION VARIABLES 
--------------------------------------------------------
LET sql_err          = "";
LET v_cod_ret	    = "000";

LET v_empresa        = "";
LET v_num_credito    = "";

LET v_id_registro    = "";
LET v_descripcion 	= "";

LET v_periodo_anterior   	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc 		= 0;	--dias_periodo_tc

--SET DEBUG FILE TO "ExecutaEdoCtaGeneral.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

	
	-------------------------------------------------------
	--SE INICIALIZA TABLA PARA EDOCTAS
	------------------------------------------------------
--	Truncate sd_movhisedocta;
        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy)) 
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	--------------------------------------------------------
	--	PREPARA LA TABLA  PARA EDOCTAS
	-------------------------------------------------------

--	INSERT INTO sd_movhisedocta
--		SELECT a.empresa,			a.secuencia,			   a.fecha_mov,			
--			   a.hora_mov,			a.sucursal,                a.num_credito,
--			   a.plaza,				a.transacc_suc,			   a.usuario,
--			   a.monto,             a.codigo_fun,			   a.codigo_ref,
--			   a.divisa,			a.reversado,			   a.folio_suc,
--			   a.num_producto,      a.nro_tarjeta,			   a.referencia,
--			   a.tipo_cambio,		a.monto_dls,			   a.suc_origen,
--		       a.rfc_comer,			a.referencia23		
  --      FROM sd_movhisnew a, sd_transfun b , bdinteg:si_transacc  c
	--	WHERE a.codigo_fun = b.codigo_fun AND a.codigo_ref  = b.codigo_ref
	--	AND c.numero = b.transacc AND c.se_emite_edocta = "S"
	--	AND fecha_mov >= v_periodo_anterior AND fecha_mov <= pfechahoy
	--	AND reversado <> "S";
		
	-------------------------------------------------------
	--SE ARREGLAN TRANSACCIONES
	------------------------------------------------------
--	CALL ARR_MOVHIS();


	-------------------------------------------------------
    --SE CORRE ACTUALIZACION DE ESTADISTICAS 
    ------------------------------------------------------
	UPDATE STATISTICS HIGH FOR TABLE sd_movhisedocta;

	

	--------------------------------------------------------
	--	GENERACION ENCABEZADO EDO CUENTA
	--------------------------------------------------------
  	LET v_id_registro = "000";
  	IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta
  				  WHERE fecha_emision = pfechahoy
  				  AND num_credito = v_id_registro) THEN

 		INSERT INTO sd_encabezado_edocta
			(
     		fecha_emision,		num_credito, 			numcte,
     		num_tarjeta, 		nombre_cte,				direccion_cn,
			direccion_col,		direccion_del,			edo_cd,
		 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
		 	fecha_corte,		rfc,			 	 	cl_cobra,
		 	CP,					ruta
			)
  		VALUES  
  			(
			 pfechahoy,			v_id_registro,			"0",
  		 	 "0",				"0",					"0",
  			 "0",				"0",					"0",
  			 "0",				"0",			 		"0",
  			 pfechahoy,			"0",			 		"0",
  			 "0",				"0"
			);
  	END IF
  	LET v_id_registro = "100";
 	IF NOT EXISTS(SELECT * FROM sd_encabezado_edocta
  		      WHERE fecha_emision = pfechahoy
  		      AND num_credito = v_id_registro) THEN

     	 INSERT INTO sd_encabezado_edocta
			(
     		fecha_emision,		num_credito, 			numcte,
     		num_tarjeta, 		nombre_cte,				direccion_cn,
		 	direccion_col,		direccion_del,			edo_cd,
	 	 	sucursal_nombre,	sucursal_gerente, 	 	sucursal_tel,
	 	 	fecha_corte,		rfc,	 	 			cl_cobra,
	 	 	CP,					ruta
			)
  		VALUES  (
			 pfechahoy,			v_id_registro,			"0",
  		 	 "0",				"0",					"0",
  			 "0",				"0",					"0",
  			 "0",				"0",			 		"0",
  			 pfechahoy,			"0",			 		"0",
  			 "0",				"0"
			);
 	 END IF
	--------------------------------------------------------
	--	VARIABLES GENERACION ENCABEZADO2 EDO CUENTA
	--------------------------------------------------------
	LET v_id_registro = "200";
  	IF NOT EXISTS(SELECT * FROM sd_encabezado2_edocta
  		      WHERE fecha_emision = pfechahoy
  		      AND num_credito = v_id_registro) THEN


		INSERT INTO sd_encabezado2_edocta 
			(
			fecha_emision,		num_credito,			capital_tc,
			interes_tc,			iva_interes_tc,			capital_ven_tc,
			interes_ven_tc,		iva_interes_ven_tc,		moratorios_tc,
			iva_moratorios_tc,	sdo_pagar,				interes_pago_total_tc,
			limite_tc,			sdo_disponible,			periodo_tc_ini,
			periodo_tc_fin,		pago_antes_de,			fecha_corte,
			dias_periodo_tc,	usted_debia,			menos_abonos,
			mas_compras,		sus_comisiones,			mas_disp_efectivo,
			mas_intereses,		mas_iva,				mas_rendimientos,
			sdo_debe,			menos_o_abonos,			mas_o_cargos,
			usted_debe,			mensajes 
			)
		VALUES (
			pfechahoy,			v_id_registro,			0,
			0,					0,						0,
			0,					0,						0,
			0,					0,						0,
			0,					0,						pfechahoy,
			pfechahoy,			pfechahoy,				pfechahoy,
			0,					0,						0,
			0,					0,						0,
			0,					0,						0,
			0,					0,						0,
			0,					"");
				
	END IF
	--------------------------------------------------------
	--	VARIABLES GENERACION DETALLE EDO CUENTA
	--------------------------------------------------------
	LET v_id_registro = "300";
	IF NOT EXISTS(SELECT * FROM sd_detalle_edocta
		      WHERE fecha_emision = pfechahoy
		      AND num_credito = v_id_registro) THEN

		INSERT INTO sd_detalle_edocta
			(
			fecha_emision, 		num_credito, 			secuencia,
			fecha_mov, 			concepto, 				cargos,
			abonos, 			nlinea
			)
		VALUES
         	(
         	pfechahoy,			v_id_registro,			"0",
         	"0", 				"0", 					"0",
			"0", 				"0"
         	);

	END IF
	--------------------------------------------------------
	--	VARIABLES GENERACION ACLARACIONES EDO CUENTA
	--------------------------------------------------------
	LET v_id_registro = "400";
	IF NOT EXISTS(SELECT * FROM sd_aclaraciones_edocta
		      WHERE fecha_emision = pfechahoy
		      AND num_credito = v_id_registro) THEN

		INSERT INTO sd_aclaraciones_edocta
			(
			fecha_emision, 			num_credito, 		secuencia,
			nlinea,					fecha_aclara, 		descripcion, 
			importe 
			)
		VALUES
         	(
         	pfechahoy,				v_id_registro,		"0",
         	"0",					pfechahoy, 			"",
         	""
         	);

	END IF
	--------------------------------------------------------
	--	VARIABLES GENERACION MENSAJES EDO CUENTA
	--------------------------------------------------------	
	LET v_id_registro = "500";
	IF NOT EXISTS(SELECT * FROM sd_mensajes_edocta
		      WHERE fecha_emision = pfechahoy
		      AND num_credito = v_id_registro) THEN

		INSERT INTO sd_mensajes_edocta
			(
			fecha_emision, 			num_credito, 		secuencia,
			nlinea,					si_paga, 			mensajes
			)
		VALUES
         	(
         	pfechahoy,				v_id_registro,		"0",
         	"0",					0, 					""
         	);

	END IF
	--------------------------------------------------------
	--	VARIABLES GENERACION PIE EDO CUENTA
	--------------------------------------------------------
  	LET v_id_registro = "600";
	IF NOT EXISTS(SELECT * FROM sd_pie_edocta
	  	      WHERE fecha_emision = pfechahoy
	  	      AND num_credito = v_id_registro) THEN

		INSERT INTO sd_pie_edocta
			(
			fecha_emision,			num_credito,		tasa_mensual,
			tasa_anual, 			cat, 				saldo_promedio,
			dias_periodo
			)
		VALUES  (
			pfechahoy, 				v_id_registro, 		"0",
			"0", 					"0", 				"0",
			"0"
			);
	  END IF


	--------------------------------------------------------
	--	GENERA UNO A UNO LOS ESTADOS DE CUENTA
	-------------------------------------------------------
 	FOREACH SELECT empresa,num_credito
 			INTO v_empresa,v_num_credito
 			FROM sd_maesdoshist
        	WHERE fecha = pfechahoy
        	AND empresa = pempresa
        	AND num_credito NOT IN
        	(SELECT num_credito FROM sd_encabezado_edocta
        	WHERE fecha_emision = pfechahoy)


		EXECUTE PROCEDURE GeneraEstadosdeCuenta
					(
					v_empresa,
					v_num_credito,
					pfechahoy
					) INTO v_cod_ret;

      	IF v_cod_ret <> "000" THEN
      	
      		SELECT descripcion  INTO v_descripcion
      		FROM bdinteg:si_codret
      		WHERE codigo_retorno = v_cod_ret
      		AND sistema  ="06";

      		INSERT INTO sd_valedocta
      			(
      			empresa,		num_credito,		cod_ret,
      			descripcion,	fecha_proc,			tipo
      			)
      		VALUES
      			(
      			v_empresa,		v_num_credito,		v_cod_ret,
      			v_descripcion,	pfechahoy,			"E"
      			);

		END IF
 	END FOREACH;

END;

	RETURN "000";

END PROCEDURE ;