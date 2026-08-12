CREATE PROCEDURE "informix".determina_lincred_tc(o_empresa CHAR(3),
                                      o_numsol  CHAR(20),
			              o_cte_nvo CHAR(1))


RETURNING CHAR(5), MONEY(14,2);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret            CHAR(3);
DEFINE vsqlerr             INTEGER;
DEFINE v_tasa              DECIMAL(9,6);
DEFINE v_factor	           CHAR(1);
DEFINE v_sobretasa         DECIMAL(9,6);
DEFINE v_porc_linea        DECIMAL(6,3);
DEFINE v_salariomin        DECIMAL(14,2);
DEFINE v_porcsalmin        DECIMAL(6,3);
DEFINE v_paramfactor       SMALLINT;
DEFINE v_ingreso           MONEY(14,2);
DEFINE v_tope_ingre        DECIMAL(9,6);
DEFINE v_situacion         DECIMAL(6,3);
DEFINE v_meseshist         SMALLINT;
DEFINE v_comproboingreso   SMALLINT;
DEFINE v_porcpermitido     DECIMAL(6,3);
DEFINE v_mesespermitido    SMALLINT;
DEFINE v_minimomesespermitido  SMALLINT;
DEFINE v_capacidad         MONEY(14,2);
DEFINE v_linea      	   MONEY(14,2);
DEFINE v_factor_calc       DECIMAL(21,10);
DEFINE v_compromisos       MONEY(14,2);
DEFINE v_lintienda         MONEY(14,2);
DEFINE v_plazo		       SMALLINT;
DEFINE v_elevado           DECIMAL(21,6);
DEFINE v_moneypaso         MONEY(14,2);
DEFINE cNumCte             CHAR(20);
DEFINE cEdad               CHAR(10);
DEFINE v_limite_inferior   DECIMAL(14,2);
DEFINE v_limitsuperior_sc  DECIMAL(14,2);
DEFINE v_limitsuperior_cc  DECIMAL(14,2);
DEFINE v_topemax           DECIMAL(14,2);
DEFINE v_param_edad        DECIMAL(14,2);
DEFINE v_abonomesprestamo  MONEY(14,2);
DEFINE v_abonomesmuebles   MONEY(14,2);
DEFINE v_abonomesropa      MONEY(14,2);
DEFINE v_diaspromedio      DECIMAL(14,2);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret        = "000";
LET vsqlerr         = 0;
LET v_plazo         = 12;
LET v_linea         = 0;
LET cNumCte         = "";
LET cEdad           = "";
LET v_diaspromedio  = 0;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, v_linea;
   END IF;
END EXCEPTION;

--SET DEBUG FILE TO "determina_lincred.out";
--TRACE ON;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************


	-- **************************************************
	-- Extrae Parametros para la definicion de la Linea *
	-- **************************************************
	SELECT valor INTO v_porcpermitido -- Porcentaje de Situacion de pago
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 307;

	IF v_porcpermitido IS NULL THEN
		LET scod_ret = "451";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor INTO v_mesespermitido -- Meses de Historia base
	 FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 308;

    IF v_mesespermitido IS NULL THEN 
		LET scod_ret = "452";
		RETURN scod_ret, v_linea;
	END IF

      	SELECT valor INTO v_minimomesespermitido --  Meses de Historia Minimo
	  FROM ss_param
	  WHERE empresa = o_empresa
	    AND secuencia = 329;

	IF  v_minimomesespermitido IS NULL THEN
		LET scod_ret = "452";
		RETURN scod_ret, v_linea;
	END IF

	SELECT valor::DECIMAL(14,2) 
      INTO v_salariomin -- Salario Minimo Base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 354; ---rqm 09 172

	IF v_salariomin IS NULL THEN
		LET scod_ret = "452";
		RETURN scod_ret, v_linea;
	END IF;

	SELECT valor::DECIMAL(14,2)
      INTO v_diaspromedio -- Salario Minimo Base
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = 355;

	IF v_diaspromedio IS NULL THEN
		LET scod_ret = "452";
		RETURN scod_ret, v_linea;
	END IF;

        SELECT valor INTO v_tasa -- Tasa para determinacion de linea
          FROM ss_param
         WHERE empresa = o_empresa
           AND secuencia = 312;

        IF v_tasa IS NULL THEN
                LET scod_ret = "453";
                RETURN scod_ret, v_linea;
        END IF

         SELECT valor::DECIMAL(9,6)
           INTO v_tope_ingre
           FROM bdisolic:ss_param
	      WHERE empresa = o_empresa
	        AND secuencia=353;

   -- ********************************************
   --  Se obtiene la edad del cliente            *
   -- ********************************************
		SELECT numcte INTO cNumCte
		  FROM ss_solicitudes
		 WHERE num_solicitud = o_numsol;

		SELECT (EXTEND(current, year to month) - extend(fecha_nac, year to month)) INTO cEdad
		FROM bdinteg:si_ctepf
		WHERE numcte = cNumCte;

		LET cEdad = TRIM(cEdad);

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************
        SELECT ingreso_mensual, situacion_pago, meses_historia , pago_minimo,
               linea_tienda, abonomensualprestamos,abonomensualmuebles,abonomensualropa
	  INTO v_ingreso, v_situacion, v_meseshist, v_compromisos, v_lintienda,
           v_abonomesprestamo,v_abonomesmuebles,v_abonomesropa
          FROM ss_resum_scor_fin
         WHERE empresa = o_empresa
           AND num_solicitud = o_numsol;

--ini cas rqm 09 172 
	-- *******************************************
	-- Extrae Porcentaje de ingresos del cliente *
	-- *******************************************
/*	IF o_cte_nvo = 1 THEN
	    LET v_paramfactor = 302; -- Cliente Nuevo
	ELSE
	    LET v_paramfactor = 301; -- Cliente No Nuevo
	END IF

	SELECT valor / 100 INTO v_porcsalmin
	  FROM ss_param
	 WHERE empresa = o_empresa
	   AND secuencia = v_paramfactor;

	IF v_porcsalmin IS NULL THEN
		LET scod_ret = "453";
		RETURN scod_ret, v_linea;
	END IF

        IF o_cte_nvo = 1 THEN
            LET v_situacion = 0;
            LET v_meseshist = 0;
        END IF;*/
            IF (v_situacion >= v_porcpermitido and v_meseshist >= v_minimomesespermitido) THEN -- OR (v_situacion >= v_porcpermitido and v_meseshist < v_mesespermitido and v_meseshist >= v_minimomesespermitido)
                LET v_paramfactor = 301; -- Cliente No Nuevo factor 0.20 
            ELSE
                LET v_paramfactor = 302; -- Cliente Nuevo
                LET v_situacion = 0;
                LET v_meseshist = 0;
            END IF

            SELECT valor / 100 
              INTO v_porcsalmin
              FROM ss_param
             WHERE empresa = o_empresa
               AND secuencia = v_paramfactor;

            IF v_porcsalmin IS NULL THEN
                LET scod_ret = "453";
                RETURN scod_ret, v_linea;
            END IF
--fin cas rqm 09 172 

        IF v_ingreso IS NULL THEN
		LET scod_ret = "454";
                RETURN scod_ret, v_linea;
        END IF

        IF v_compromisos IS NULL THEN
		LET v_compromisos = 0;
        END IF

        IF v_abonomesprestamo IS NULL THEN
                LET v_abonomesprestamo=0;
        END IF;
        IF v_abonomesmuebles IS NULL THEN
                LET v_abonomesmuebles=0;
        END IF;
        IF v_abonomesropa IS NULL THEN
                LET v_abonomesropa=0;
        END IF;

        IF v_situacion IS NULL THEN
		LET scod_ret = "455";
                RETURN scod_ret, v_linea;
        END IF

        IF v_meseshist IS NULL THEN
		LET scod_ret = "456";
                RETURN scod_ret, v_linea;
        END IF

        IF v_lintienda IS NULL THEN
		LET scod_ret = "457";
                RETURN scod_ret, v_linea;
        END IF

	-- *******************************************************************
	-- Extrae Ingreso, Situacion de Pago y Meses de Historia del Cliente *
	-- *******************************************************************

	SELECT COUNT(*) INTO v_comproboingreso
	  FROM ss_detalle_scoring
	 WHERE empresa = o_empresa
	   AND num_solicitud = o_numsol
	   AND seccion = 2
	   AND grupo = 14
	   AND elemento = 3;

	IF v_comproboingreso IS NULL THEN
		LET v_comproboingreso = 0;
	END IF

        -- *************************************
        -- Extrae Tasa de interes del producto *
        -- *************************************

	{SELECT valor, c.factor_sobretasa, c.sobretasa
	  INTO v_tasa, v_factor, v_sobretasa
	  FROM ss_solicitudes a, bdinteg:si_fechavalor b,
	       bdicred:sd_definicion c
	 WHERE a.empresa = o_empresa
	   AND a.num_solicitud = o_numsol
	   AND c.empresa = a.empresa
	   AND c.num_producto = a.num_producto
	   AND b.empresa = c.empresa
	   AND b.tasa = c.cod_tasa_base
	   AND b.fecha = (SELECT MAX(fecha) FROM bdinteg:si_fechavalor
			   WHERE tasa = c.cod_tasa_base);

        IF v_tasa IS NULL THEN
		LET scod_ret = "458";
                RETURN scod_ret, v_linea;
        END IF

	IF v_factor = "+" THEN
		LET v_tasa = v_tasa + v_sobretasa;
	ELIF v_factor = "-" THEN
		LET v_tasa = v_tasa - v_sobretasa;
	ELIF v_factor = "*" THEN
		LET v_tasa = v_tasa * v_sobretasa;
	ELSE
		LET v_tasa = v_tasa / v_sobretasa;
	END IF}

        -- **********************************************************
        -- Extrae Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente			    *
        -- **********************************************************
--ini cas RQM 09 172 PUNTO 4 Eliminar politica de reduccion de linea al 50%
 --  IF  v_situacion >= v_porcpermitido
 --       AND v_meseshist >= v_mesespermitido THEN
		SELECT valor / 100 INTO v_porc_linea
		  FROM ss_param
		 WHERE empresa = o_empresa
		   AND secuencia = 304;
/*	ELSE

		IF  v_situacion >= v_porcpermitido
        	AND v_meseshist <= v_mesespermitido
        	AND v_comproboingreso = 1 THEN
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 305;
		ELSE
			SELECT valor / 100 INTO v_porc_linea
		  	  FROM ss_param
		 	 WHERE empresa = o_empresa
		   	   AND secuencia = 306;
		END IF
	END IF*/
--fin cas RQM 09 172 PUNTO 4 Eliminar politica de reduccion de linea al 50%
        IF v_porc_linea IS NULL THEN
		LET scod_ret = "459";
                RETURN scod_ret, v_linea;
        END IF
--ini cas RQM 09 172 PUNTO 3 Montos en salarios minimos
        IF v_comproboingreso = 0 and v_ingreso > (v_tope_ingre * v_salariomin * v_diaspromedio) THEN
            LET v_ingreso = (v_tope_ingre * v_salariomin * v_diaspromedio);
        END IF;
--fin cas RQM 09 172 PUNTO 3 Montos en salarios minimos
           
	-- ************************************
	-- Inicia Proceso de Calculo de Linea *
	-- ************************************
	--LET v_capacidad = ((v_ingreso * v_porcsalmin) - v_compromisos)
	--			  * v_porc_linea;
	LET v_capacidad = (v_ingreso * v_porcsalmin) - v_compromisos - v_abonomesprestamo - v_abonomesmuebles - v_abonomesropa;

	LET v_factor_calc=POW(ROUND(((v_tasa/100)/v_plazo)+1,10),(v_plazo*-1));
	LET v_factor_calc = 1-(v_factor_calc);
	LET v_linea =(v_capacidad * v_factor_calc) / ((v_tasa/100)/v_plazo);
	--insert into vallinea values (o_numsol, v_linea);
        -- **********************************************************
        -- Valida Porcentajes de Otorgamiento de Linea de acuerdo a *
        -- a caracteristicas del cliente                            *
        -- **********************************************************
--ini cas RQM 09 172 Parametrizar limites inferior y superior en salarios minimos

           SELECT (sum(cant_smb_inf) * v_salariomin * v_diaspromedio), (sum(cant_smb_sup) * v_salariomin * v_diaspromedio)
             INTO v_limite_inferior,v_topemax
             FROM bdisolic:ss_scoring_solic
            WHERE empresa = o_empresa
              AND tp_solicitud = 'T'
              AND seccion = '2'
              AND (min_porc_pago <= v_situacion
              AND max_porc_pago >= v_situacion)
              AND (min_mes_hist <= v_meseshist
              AND max_mes_hist >= v_meseshist)
              AND activa = '1';

              IF v_topemax IS NULL OR v_topemax = 0 THEN
                 LET scod_ret = "463";
                 RETURN scod_ret, v_linea;
              END IF;

              IF v_limite_inferior IS NULL  OR v_limite_inferior = 0 THEN
                 LET scod_ret = "466";
                 RETURN scod_ret, v_linea;
              END IF;

 /*       IF  v_situacion >= v_porcpermitido THEN
           IF v_meseshist >= v_mesespermitido THEN---Evalua meses mayor igual a 13
        	    SELECT valor INTO v_topemax
				   FROM ss_param
				   WHERE empresa = o_empresa
				   AND secuencia = 317;

				 IF v_topemax IS NULL THEN
					LET scod_ret = "463";
    				RETURN scod_ret, v_linea;
			     END IF;

				 SELECT valor INTO v_limite_inferior
					FROM ss_param
				    WHERE empresa = o_empresa
			        AND secuencia = 314;

				IF v_limite_inferior IS NULL THEN
					LET scod_ret = "466";
    				RETURN scod_ret, v_linea;
				END IF;
            ELSE
                IF v_meseshist > v_minimomesespermitido THEN ---- Evalua meses mayor a 6
                    SELECT valor INTO v_topemax
                       FROM ss_param
                       WHERE empresa = o_empresa
                       AND secuencia = 331;

                    IF v_topemax IS NULL THEN
                        LET scod_ret = "463";
                        RETURN scod_ret, v_linea;
                    END IF;

                     SELECT valor INTO v_limite_inferior
                        FROM ss_param
                     WHERE empresa = o_empresa
                        AND secuencia = 330;

                    IF v_limite_inferior IS NULL THEN
                        LET scod_ret = "466";
                        RETURN scod_ret, v_linea;
                    END IF;
                 ELSE
                    SELECT valor INTO v_topemax
                       FROM ss_param
                     WHERE empresa = o_empresa
                       AND secuencia = 333;

                    IF v_topemax IS NULL THEN
                        LET scod_ret = "463";
                        RETURN scod_ret, v_linea;
                    END IF;

                     SELECT valor INTO v_limite_inferior
                        FROM ss_param
                     WHERE empresa = o_empresa
                        AND secuencia = 332;

                    IF v_limite_inferior IS NULL THEN
                        LET scod_ret = "466";
                        RETURN scod_ret, v_linea;
                    END IF;
                 END IF;
           END IF; */
--ini cas RQM 09 172 Parametrizar limites inferior y superior en salarios minimos
                SELECT valor / 100 INTO v_porc_linea
                  FROM ss_param
                  WHERE empresa = o_empresa
                  AND secuencia = 304;

				IF v_porc_linea IS NULL THEN
        			LET scod_ret = "460";
					RETURN scod_ret, v_linea;
        		END IF

                    SELECT (valor::decimal(14,2) * v_salariomin * v_diaspromedio) 
                      INTO v_param_edad
                      FROM ss_param
                     WHERE empresa = o_empresa
                      AND secuencia = 318;

				IF v_param_edad IS NULL THEN
					LET scod_ret = "466";
				    RETURN scod_ret, v_linea;
			    END IF;

				LET v_moneypaso = v_linea * v_porc_linea;

				IF cEdad[1,2] >= '75' AND cEdad[1,2] <= '85' THEN
					IF v_moneypaso >= v_param_edad THEN
	     				LET v_linea = v_param_edad;
                    ELSE
                        LET v_linea = v_moneypaso;
	     			END IF;
     			ELSE
     				IF v_moneypaso >= v_topemax THEN
     					LET v_linea = v_topemax;
     				ELSE
                        LET v_linea = v_moneypaso;
     				END IF;
				END IF;
--ini cas RQM 09 172 Punto 4 Eliminar politica de comparacion de linea de credito Coppel
			/*	IF v_lintienda <= v_linea THEN
					LET v_linea = v_lintienda;
				END IF; */
--FIN cas RQM 09 172 Punto 4 Eliminar politica de comparacion de linea de credito Coppel
				IF v_linea < v_limite_inferior THEN
					LET v_linea = v_limite_inferior;
				END IF;

    /*    ELSE
                IF  v_situacion <= v_porcpermitido
                AND v_meseshist <= v_mesespermitido
                AND v_comproboingreso = 1 THEN
                        SELECT valor / 100 INTO v_porc_linea
                        FROM ss_param
                        WHERE empresa = o_empresa
                        AND secuencia = 305;

        			IF v_porc_linea IS NULL THEN
                		LET scod_ret = "461";
                		RETURN scod_ret, v_linea;
        			END IF

        			SELECT valor INTO v_limitsuperior_cc
						FROM ss_param
					    WHERE empresa = o_empresa
						AND secuencia = 316;

					IF v_limitsuperior_cc IS NULL THEN
						LET scod_ret = "465";
					    RETURN scod_ret, v_linea;
					END IF;

	                IF (v_linea * v_porc_linea) >= (v_limitsuperior_cc) THEN
                       LET v_linea  = v_limitsuperior_cc;
                    ELSE
                       LET v_linea = v_linea * v_porc_linea;
                    END IF

					 SELECT valor INTO v_limite_inferior
					   FROM ss_param
					   WHERE empresa = o_empresa
					   AND secuencia = 313;

					 IF v_limite_inferior IS NULL THEN
						LET scod_ret = "468";
					    RETURN scod_ret, v_linea;
					 END IF;

					 IF v_linea < v_limite_inferior THEN
						LET v_linea = v_limite_inferior;
					 END IF

                ELSE

                     SELECT valor / 100 INTO v_porc_linea
                       FROM ss_param
                       WHERE empresa = o_empresa
                       AND secuencia = 306;

                     IF v_porc_linea IS NULL THEN
                          LET scod_ret = "462";
                          RETURN scod_ret, v_linea;
                     END IF

                      SELECT valor INTO v_limitsuperior_sc
						FROM ss_param
					   WHERE empresa = o_empresa
						AND secuencia = 315;

					 IF v_limitsuperior_sc IS NULL THEN
						LET scod_ret = "464";
                        RETURN scod_ret, v_linea;
				     END IF;

				     SELECT valor INTO v_limite_inferior
					   FROM ss_param
					   WHERE empresa = o_empresa
					   AND secuencia = 313;

					 IF v_limite_inferior IS NULL THEN
						LET scod_ret = "467";
                        RETURN scod_ret, v_linea;
					 END IF;

                     IF (v_linea * v_porc_linea) >= (v_limitsuperior_sc) THEN
                   		LET v_linea  = v_limitsuperior_sc;
                     ELSE
						IF (v_linea * v_porc_linea) < v_limite_inferior THEN
							LET v_linea = v_limite_inferior;
                        ELSE
							LET v_linea = v_linea * v_porc_linea;
                        END IF;
                     END IF
                END IF
        END IF */
LET v_linea = ROUND(v_linea,-2);

END
	RETURN scod_ret, v_linea;

END PROCEDURE;