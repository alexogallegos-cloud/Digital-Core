CREATE PROCEDURE "informix".eva_scoring(o_empresa CHAR(3),
				  o_numsol   CHAR(20))

RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_valor_lc   DECIMAL(14,2);
DEFINE v_valor      DECIMAL(14,4);
DEFINE v_valor_1s   DECIMAL(14,4);
DEFINE v_valor_2s   DECIMAL(14,4);
DEFINE v_valor_im   DECIMAL(14,4);
DEFINE v_valor_ex   DECIMAL(14,4);
DEFINE v_paso       CHAR(1);
DEFINE v_cuantos    SMALLINT;
DEFINE v_seccion    SMALLINT;
DEFINE v_grupo      SMALLINT;
DEFINE v_tpsol      CHAR(1);
DEFINE v_hoy        DATE;
DEFINE v_cliente    CHAR(20);
DEFINE vCompromisos DECIMAL(14,2);
DEFINE vMensaje     VARCHAR(255);
DEFINE vedocivil    CHAR(1);
DEFINE vTpCiudad    CHAR(1);
DEFINE vCiudadCte   SMALLINT;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_valor      = 0;
LET v_valor_1s   = 0;
LET v_valor_2s   = 0;
LET v_valor_im   = 0;
LET v_valor_ex   = 0;
LET v_paso       = "";
LET v_cuantos    = 0;
LET v_seccion    = 0;
LET v_grupo      = 0;
LET v_tpsol      = "";
SELECT fecha_hoy INTO v_hoy FROM bdicred:sd_fechas;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "/informix/eva_scoring.out";
--TRACE ON;
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

FOREACH SELECT empresa, num_solicitud
	  INTO o_empresa, o_numsol
	  FROM ss_solicitudes
--	WHERE num_solicitud = "600000111929"
--	  AND num_solicitud < "600000106473"
        WHERE status_solicitud NOT IN ("AP","AN")

	-- **********************************************************
	-- Incorpora Grupo 12 (ciudad) de acuerdo a dato del cliente*
	-- **********************************************************
	SELECT numerociudad 
	  INTO vCiudadCte
	  FROM bdinteg:si_direcciones a, ss_solicitudes b
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = o_numsol
	   AND a.numcte = b.numcte	
	   AND a.secuencia = 1;

	IF vCiudadCte IS NULL OR vCiudadCte = 0 THEN
		LET vTpCiudad = "4";
	ELSE
		SELECT tipo_ciudad 
		  INTO vTpCiudad
		  FROM bdinteg:si_catciudades
		 WHERE numerociudad = vCiudadCte;

		IF vTpCiudad IS NULL THEN 
			LET vTpCiudad = "4";
		END IF
	END IF	

        SELECT valor INTO v_valor
          FROM ss_scoring_pesos
         WHERE empresa = o_empresa
           AND tp_solicitud = "T"
           AND grupo = 12
           AND elemento = vTpCiudad
           AND seccion = 2
           AND tpo_persona = "01";

	IF v_valor IS NULL THEN
		LET v_valor = 0;
	END IF

	DELETE FROM ss_detalle_scoring
	 WHERE empresa = "001"
	  AND num_solicitud = o_numsol
	  AND grupo = 12;

        INSERT INTO ss_detalle_scoring
         (empresa, seccion, grupo, elemento, tpo_persona, num_solicitud, valor)
        VALUES
         (o_empresa, 2, 12, vTpCiudad, "01", o_numsol, v_valor);


        -- **************************************
        -- Inicia Proceso de Circulo de Credito *
        -- **************************************

       { EXECUTE PROCEDURE cal_circulocredito(o_empresa, v_cliente)
           INTO scod_ret, v_paso, vCompromisos, vMensaje;

        IF scod_ret <> "000" THEN
                RETURN scod_ret;
        END IF

        UPDATE ss_resum_scor_fin
           SET evalua_cc = v_paso,
               motivo_cc= vMensaje,
               pago_minimo = v_compromisos
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

        IF v_paso = "1" THEN

		UPDATE ss_solicitudes SET status_solicitud = "RT"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		INSERT INTO ss_autorizacion
		 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
		  comentario, fecha_entrada, fecha_salida)
		VALUES
		 (o_empresa, "sistema", o_numsol, "RT",
	 	  "Evaluacion en Circulo de Credito Negativa, " ||
		  "Solicitud No Aprobada", v_hoy, v_hoy);

                --RETURN scod_ret;
        END IF}

        UPDATE ss_resum_scor_fin
           SET evalua_cc = "0",
               motivo_cc= "Prueba",
               pago_minimo = 0
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;


	-- ********************************
	-- Inicia Proceso de Calificacion *
	-- ********************************

	SELECT tipo_solicitud INTO v_tpsol
	  FROM ss_solicitudes
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	LET v_valor_ex =0;
	LET v_valor_im =0;
	LET v_valor_1s=0;
	LET v_valor_2s=0;

	FOREACH SELECT a.seccion INTO v_seccion
		  FROM ss_scoring_solic a, ss_scoring_seccion b
		 WHERE a.empresa = o_empresa
		   AND a.tp_solicitud = v_tpsol
                   AND b.empresa = a.empresa
		   AND b.seccion = a.seccion
		   AND b.automatico = "0"

	   -- ************
	   -- Explicitos *
	   -- ************
	   FOREACH SELECT grupo INTO v_grupo
		     FROM ss_scoring_grupo
		    WHERE empresa = o_empresa
		      AND seccion  = v_seccion
		      AND implicito = "0"


		SELECT SUM(valor) INTO v_valor
		  FROM ss_detalle_scoring
		 WHERE empresa = o_empresa
		   AND seccion = v_seccion
		   AND grupo = v_grupo
	    	   AND num_solicitud = o_numsol;

		IF v_valor IS NULL THEN
			LET v_valor = 0;
		END IF

		LET v_valor_ex = v_valor_ex + v_valor;

	   END FOREACH

	   -- ************
	   -- Implicitos *
	   -- ************
           FOREACH SELECT agrupar, valor, COUNT(*)
                     INTO v_paso, v_valor, v_cuantos
                     FROM ss_scoring_grupo a, ss_detalle_scoring b
                    WHERE a.empresa = o_empresa
                      AND a.seccion  = v_seccion
                      AND a.implicito = "1"
		      AND b.empresa = a.empresa
		      AND b.seccion = a.seccion
		      AND b.grupo = a.grupo
		      AND b.elemento = 1
		      AND b.num_solicitud = o_numsol
		    GROUP BY 1,2

		IF v_cuantos > 0 THEN
			LET v_valor_im = v_valor_im + v_valor;
		END IF

           END FOREACH

	   LET v_valor_1s = v_valor_ex + v_valor_im;

	END FOREACH

	-- ********************************
	-- Califica Comportamiento Interno*
	-- ********************************

	SELECT puntuacion INTO v_valor_2s
	  FROM ss_scoring_financ a, ss_resum_scor_fin b
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = o_numsol
	   AND a.empresa = a.empresa
	   AND a.tp_solicitud = v_tpsol
	   AND (b.meses_historia >= a.min_mes_hist
	   AND b.meses_historia <= a.max_mes_hist )
	   AND (b.situacion_pago >= a.min_porc_pago
	   AND b.situacion_pago <= a.max_porc_pago)
	   AND a.circulo_credito = (SELECT DECODE(r.evalua_cc,"0","0",
							      "2","1",
							      "3","1",
    							      "4","1","1")
				      FROM ss_resum_scor_fin r
				     WHERE empresa = o_empresa
				       AND num_solicitud = o_numsol);

	IF v_valor_2s IS NULL THEN
		LET v_valor_2s = 0;
	END IF

	-- *************************************
	-- Almacena Resultado de la Evaluacion *
	-- *************************************
	LET v_valor = v_valor_1s + v_valor_2s;
	UPDATE ss_resumen_scoring 
	   SET evaluacion = v_valor
	 WHERE empresa = o_empresa
	  AND num_solicitud = o_numsol;

	-- ************************************
	-- Valida Resultado de la  Evaluacion *
	-- ************************************
	SELECT COUNT(*) INTO v_cuantos
	  FROM ss_scoring_solic
	 WHERE empresa = o_empresa
	   AND tp_solicitud = v_tpsol
	   AND seccion = v_seccion
	   AND (v_valor >= evaluacion_min
	   AND  v_valor <= evaluacion_max);

	IF v_cuantos IS NULL OR v_cuantos = 0 THEN
		UPDATE ss_solicitudes SET status_solicitud = "RT"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		CONTINUE FOREACH; 
	END IF

	-- *******************************
	-- Evalua Antiguedad del Cliente *
	-- *******************************

	-- Extrae Valor de Parametro
	SELECT valor INTO v_cuantos
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 300;

	-- Extrae Valor del Cliente
	SELECT meses_historia INTO v_valor
	  FROM ss_resum_scor_fin
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

	-- Valida para generacion de Orden de Supervision
	LET v_paso = "0";
	
	IF v_valor <= v_cuantos THEN

		--EXECUTE PROCEDURE sp_os_integracion(o_numsol, v_hoy)
		--   INTO scod_ret;

		UPDATE ss_solicitudes SET status_solicitud = "EE"
		 WHERE empresa = o_empresa
		   AND num_solicitud = o_numsol;

		LET v_paso = "1"; -- Asigna Bandera para nuevos
	END IF

	-- *************************
	-- Genera Linea de Credito *
	-- *************************
	EXECUTE PROCEDURE determina_lincred_tc(o_empresa,
				 	       o_numsol,
					       v_paso)
	INTO scod_ret, v_valor_lc;

	IF v_paso = "0" THEN -- Bandera que indica que esta en O.S.
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor_lc,
	   	       status_solicitud = "AT"
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;

	ELSE
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor_lc
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;
	END IF

END FOREACH

END
	RETURN scod_ret;

END PROCEDURE
;