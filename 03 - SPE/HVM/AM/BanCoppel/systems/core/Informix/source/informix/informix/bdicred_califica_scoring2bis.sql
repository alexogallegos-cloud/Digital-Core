CREATE PROCEDURE "informix".califica_scoring2bis(o_empresa CHAR(3),
				  o_numsol   	CHAR(20))

RETURNING CHAR(5);


-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_valor      DECIMAL(14,2);
DEFINE v_valor_1s   DECIMAL(14,2);
DEFINE v_valor_2s   DECIMAL(14,2);
DEFINE v_valor_im   DECIMAL(14,2);
DEFINE v_valor_ex   DECIMAL(14,2);
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
DEFINE vCiudadCte   CHAR(3);
DEFINE vEstadoCte   CHAR(2);
DEFINE vCte         CHAR(20);
DEFINE vAntiguedad  CHAR(1);
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
LET vCte         = "";
LET vAntiguedad  = "?";
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


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
        -- **************************************
        -- Inicia Proceso de Circulo de Credito *
        -- **************************************
	 SELECT numcte INTO vCte
	  FROM ss_solicitudes
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

{        EXECUTE PROCEDURE cal_circulocredito(o_empresa, vCte)
           INTO scod_ret, v_paso, vCompromisos, vMensaje;

        IF scod_ret <> "000" THEN
                RETURN scod_ret;
        END IF

        UPDATE ss_resum_scor_fin
           SET evalua_cc = v_paso,
               motivo_cc= vMensaje,
               pago_minimo = vCompromisos
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

                RETURN scod_ret;
        END IF}

         {UPDATE ss_resum_scor_fin
           SET evalua_cc = "0",
               motivo_cc= "Prueba",
               pago_minimo = 0
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;}


	-- ********************************
	-- Inicia Proceso de Calificacion *
	-- ********************************

	SELECT tipo_solicitud INTO v_tpsol
	  FROM ss_solicitudes
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol;

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

       LET vAntiguedad = "0";
       IF v_valor <= v_cuantos THEN
		LET vAntiguedad = "1";
       END IF


	-- ********************************
	-- Califica Comportamiento Interno*
	-- ********************************

	SELECT puntuacion INTO v_valor_2s
	  FROM ss_scoring_financ a, ss_resum_scor_fin b
	 WHERE b.empresa = o_empresa
	   AND b.num_solicitud = o_numsol
	   AND a.empresa = a.empresa
	   AND a.tp_solicitud = v_tpsol
	   AND a.tp_cliente = vAntiguedad
	   AND (b.meses_historia >= a.min_mes_hist
	   AND b.meses_historia <= a.max_mes_hist )
	   AND (b.situacion_pago >= a.min_porc_pago
	   AND b.situacion_pago <= a.max_porc_pago)
	   AND a.circulo_credito = (SELECT DECODE(r.evalua_cc,"X","X",
						              "0","0",
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
	DELETE FROM ss_resumen_scoring
	  WHERE empresa = o_empresa
	    AND num_solicitud = o_numsol;
        DELETE FROM ss_autorizacion
	  WHERE empresa = o_empresa
	    AND num_solicitud = o_numsol
	    AND status_solicitud IN ("RT","EE");
	INSERT INTO ss_resumen_scoring
	  (empresa, num_solicitud, seccion, evaluacion)
	VALUES
	  (o_empresa, o_numsol, v_seccion, v_valor);


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

		INSERT INTO ss_autorizacion
		 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
		  comentario, fecha_entrada, fecha_salida)
		VALUES
		 (o_empresa, "sistema", o_numsol, "RT",
		  "Puntos acumulados en Scoring fueron insuficientes para " ||
		  "su Aprobacion", v_hoy, v_hoy);

		RETURN scod_ret;
	END IF

	-- Valida para generacion de Orden de Supervision
	LET v_paso = "0";
	IF vAntiguedad = "1" THEN
		INSERT INTO ss_solicitud_os
		  (empresa, num_solicitud, fecha_solicitud, status,
		   usuario_solicita)
		VALUES
		  (o_empresa, o_numsol, v_hoy, "S", "sistema");

		--EXECUTE PROCEDURE sp_os_integracion(o_numsol, v_hoy)
		--  INTO scod_ret;

                INSERT INTO ss_autorizacion
                 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
                  comentario, fecha_entrada, fecha_salida)
                VALUES
                 (o_empresa, "sistema", o_numsol, "EE",
                  "Solicitud Enviada a Orden de Supervision ", v_hoy, v_hoy);

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
	INTO scod_ret, v_valor;

	IF v_paso = "0" THEN -- Bandera que indica que esta en O.S.
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor,
	   	       status_solicitud = "AT"
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;

                INSERT INTO ss_autorizacion
                 (empresa, ejecutivo_auto, num_solicitud, status_solicitud,
                  comentario, fecha_entrada, fecha_salida)
                VALUES
                 (o_empresa, "sistema", o_numsol, "AT",
                  "Solicitud Autorizada", v_hoy, v_hoy);
	ELSE
        	UPDATE ss_solicitudes
	   	   SET monto_solicitado = v_valor
         	 WHERE empresa = o_empresa
           	   AND num_solicitud = o_numsol;
	END IF
END
	RETURN scod_ret;

END PROCEDURE
;