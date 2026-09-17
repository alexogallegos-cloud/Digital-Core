CREATE PROCEDURE "informix".executaedoctageneral_solo(pempresa CHAR(3),pfechahoy DATE)
RETURNING CHAR(5);


--------------------------------------------------------
--	VARIABLES CONTROL DE ERRORES
--------------------------------------------------------
DEFINE sql_err          INTEGER;
DEFINE v_cod_ret	    CHAR(5);
DEFINE v_corta_retorno          INTEGER;
--------------------------------------------------------
--	VARIABLES GENERALES
--------------------------------------------------------
DEFINE v_empresa        CHAR(3);
DEFINE v_num_credito    CHAR(20);

DEFINE v_id_registro    CHAR(3);
DEFINE v_descripcion 	CHAR(50);

DEFINE v_periodo_anterior   	DATE;			--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 		INTEGER;		--dias_periodo_tc
DEFINE v_texto		            VARCHAR(255);
DEFINE v_clave           		INTEGER;
DEFINE v_secuencia        		INTEGER;
DEFINE v_mensajes				VARCHAR(255);

DEFINE GLOBAL v_cat			    DECIMAL(18,2) DEFAULT 0;
DEFINE GLOBAL v_linea_auxiliar	DECIMAL(14,2) DEFAULT 0;
DEFINE GLOBAL v_corta_linea_mensaje 	INTEGER  DEFAULT 0;
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
LET v_cat                   = 0; --- CAT
LET v_texto                 = "";
LET v_linea_auxiliar        =999999.00;
LET v_mensajes				= "";
LET v_corta_retorno 		= 0;
LET v_corta_linea_mensaje 	= 100;

--SET DEBUG FILE TO "ExecutaEdoCtaGeneral.out";
--TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET v_cod_ret = sql_err;

            RETURN v_cod_ret;
        END IF
   END EXCEPTION;

---SET PDQPRIORITY 60;
---SET OPTIMIZATION HIGH;
        --------------------------------------------------------
	--SE OBTIENE FECHA HOY MENOS UN MES
	--------------------------------------------------------
	EXECUTE PROCEDURE sp_mes_siguiente(pfechahoy,-1,DAY(pfechahoy))
	INTO v_cod_ret,v_periodo_anterior,v_dias_periodo_tc;

	LET v_periodo_anterior = v_periodo_anterior + 1 UNITS DAY;

	SET ISOLATION TO DIRTY READ;

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
	--	GENERA VARIABLES GLOBALES
	-------------------------------------------------------
    ----VALOR DEL CAT
	SELECT valor INTO v_cat
	FROM sd_param
	WHERE empresa = pempresa
	AND cod_param = '035'; 

	IF v_cat IS NULL THEN
		LET v_cat = 0.0;
	END IF
    -----MENSAJES DEL ESTADO DE CUENTA

        CREATE TEMP TABLE mensajes(
                clave     serial,
                secuencia integer,
                mensaje   char(101));

        LET v_clave=1;
            FOREACH            
                    SELECT REPLACE(mensajes,'{0}',TRIM(v_linea_auxiliar::VARCHAR(21))) INTO v_texto
                     FROM bdicred:sd_config_mensaje_edocta order by clave
                     
                     LET v_secuencia=1;

                FOREACH 
                     EXECUTE PROCEDURE corta_linea(TRIM(v_texto),v_corta_linea_mensaje) INTO v_mensajes, v_corta_retorno
                     insert into mensajes values (v_clave,v_secuencia,v_mensajes);
                     LET v_secuencia=v_secuencia+1;
                END FOREACH;

                LET v_clave = v_clave + 1;

            END FOREACH;

            DELETE FROM mensajes WHERE clave <> '2';

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

    DROP TABLE mensajes;
END;

	RETURN "000";

END PROCEDURE ;