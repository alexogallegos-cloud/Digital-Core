CREATE PROCEDURE "informix".sp_cat_genera_testigo(ptipo_cobranza CHAR(1))
--CREATE PROCEDURE "informix".sp_cat_genera_testigo(pfecha_cartera DATE,ptipo_cobranza CHAR(1))
RETURNING CHAR(5);

--Fecha de creaciÃ³n: 4/Enero/2010
--Creado por Enrique LizÃ¡rraga Lugo
--Proceso que genera los clientes que son considerados como testigo en la cartera del CAT

--DefiniciÃ³n de variables de bitÃ¡cora.

DEFINE cCodRet 		CHAR(5);
DEFINE isqlerr 		INTEGER;
DEFINE isam_err	 	INTEGER;
DEFINE vProceso		CHAR(5);
DEFINE error_info	CHAR(80);
DEFINE cMensaje		CHAR(80);
DEFINE vfecha_hoy	DATE;
DEFINE vempresa		CHAR(3);
DEFINE vnumcte		CHAR(20);
DEFINE vconteo		INTEGER;
DEFINE v_asignados	INTEGER;
DEFINE v_cantidadant	INTEGER;
DEFINE vtotal		INTEGER;
DEFINE vstatus		CHAR(2);
DEFINE vcontaux		INTEGER;
DEFINE vbandera		CHAR(1);
DEFINE vday			INTEGER;
DEFINE vnum_prod	CHAR(4);
DEFINE v_pago_venc_ini INTEGER;
DEFINE v_pago_venc_fin INTEGER;
DEFINE v_porcentaje_asignado DECIMAL(9,2);
DEFINE vfecha_vig 	DATE;

--InicializaciÃ³n de variables
LET isqlerr = 0;
LET vProceso = 'GCT';
LET cMensaje = 'PROCESO EXITOSO';
LET isam_err = 0;
LET error_info = '';
LET cCodRet = '00000';
LET vfecha_hoy = '';
LET vempresa = '001';
LET vnumcte = '';
LET vconteo = 0;
LET v_asignados = 0;
LET v_cantidadant = 0;
LET vtotal = 0;
LET vstatus = '';
LET vcontaux = 0;
LET vbandera = '';
LET vday = 0;
LET vnum_prod = '';
LET v_pago_venc_ini = 0;
LET v_pago_venc_fin = 0;
LET v_porcentaje_asignado = 0;
LET vfecha_vig = DATE(1);

BEGIN    
	ON EXCEPTION SET isqlerr, isam_err, error_info
		LET cCodret = isqlerr;
		LET cMensaje = error_info;
		CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vProceso, cCodRet, cMensaje, '02');
		RETURN cCodRet;            
	END EXCEPTION;

	--SET DEBUG FILE TO "sp_cat_genera_testigo.out";
	--TRACE ON; 

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vProceso, cCodRet, cMensaje, '01');

--ObtenciÃ³n de status de cliente testigo
	SELECT valor_alfabetico into vstatus
	FROM bdicobranza:cb_param_campania
	WHERE empresa = vempresa
	AND grupo_parametro = 'STATUSCTE'
	AND num_parametro = 8
	AND tipo_campania = 1;

	SELECT pago_venc_ini, pago_venc_fin, porcentaje_asignado
	INTO v_pago_venc_ini, v_pago_venc_fin, v_porcentaje_asignado
	FROM "informix".cb_gestion_cobranza_agex
	WHERE canal = "TEST";

	SELECT MAX(fecha_insert) INTO vfecha_hoy 
	FROM "informix".cb_cat_directorio_cte 
	WHERE empresa = vempresa 
	AND tipo_cobranza = ptipo_cobranza;

	IF ptipo_cobranza = 'A' THEN
		LET vday = DAY(vfecha_hoy);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = vempresa AND tipo_campania = 61
			AND grupo_parametro = ptipo_cobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			IF (vnum_prod = '6001') THEN
				SELECT MAX(fecha_insert) INTO vfecha_hoy 
				FROM "informix".cb_cat_directorio_cte 
				WHERE empresa = vempresa 
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto = vnum_prod;

				SELECT {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} cliente, MIN(fecha_insert) fecha_min, MAX(fecha_insert) fecha_max
				FROM "informix".cb_cat_cte_testigo
				WHERE cliente > ""
				AND fecha_insert <= TODAY
				AND tipo_cobranza = ptipo_cobranza
				AND f_vig = "1" GROUP BY 1
				INTO TEMP paso_testtdc WITH NO LOG;

				CREATE INDEX indx_paso_testtdc ON paso_testtdc(cliente, fecha_max);
				UPDATE STATISTICS MEDIUM FOR TABLE paso_testtdc;

				FOREACH WITH HOLD
					SELECT a.cliente, a.fecha_min
						INTO vnumcte, vfecha_vig
					FROM paso_testtdc a
					INNER JOIN "informix".cb_cat_directorio_cte b ON(b.empresa = vempresa AND b.tipo_cobranza = ptipo_cobranza AND b.fecha_insert = vfecha_hoy AND b.numcte = a.cliente AND b.status_cliente <> 'TE' AND b.num_producto = vnum_prod)
					WHERE a.cliente NOT IN(SELECT agex.numcte FROM "informix".cb_cat_directorio_cte_agex agex WHERE agex.numcte = a.cliente AND agex.fecha_insert = (vfecha_hoy - 1 UNITS MONTH) AND agex.tipo_cobranza = ptipo_cobranza AND agex.f_vigencia = "1" AND agex.num_producto = vnum_prod)
					AND a.fecha_max = (vfecha_hoy - 1 UNITS MONTH)

					IF vfecha_vig < (vfecha_hoy - 6 UNITS MONTH) THEN
						BEGIN WORK;
							UPDATE "informix".cb_cat_cte_testigo 
							SET f_vig = "0"
							WHERE cliente = vnumcte
							AND fecha_insert <= TODAY
							AND tipo_cobranza = ptipo_cobranza
							AND f_vig = "1";
						COMMIT WORK;

						CONTINUE FOREACH;
					END IF;					

					SELECT LIMIT 1 {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} '1' INTO vbandera
					FROM "informix".cb_cat_cte_testigo WHERE cliente = vnumcte AND fecha_insert = vfecha_hoy AND tipo_cobranza = ptipo_cobranza AND f_vig = "1";

					IF (vbandera IS NULL OR vbandera = '') THEN
						BEGIN WORK;
							INSERT INTO "informix".cb_cat_cte_testigo(cliente, fecha_insert, tipo_cobranza, num_producto, f_vig) 
											values (vnumcte, vfecha_hoy, ptipo_cobranza, vnum_prod, "1");

							UPDATE {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} "informix".cb_cat_directorio_cte 
								SET status_cliente = vstatus, canal = 'TEST'
								WHERE empresa = vempresa
								AND tipo_cobranza = ptipo_cobranza
								AND numcte = vnumcte
								AND fecha_insert = vfecha_hoy
								AND num_producto = vnum_prod;
						COMMIT WORK;
					END IF;

					LET vbandera = '';
				END FOREACH;

				SELECT COUNT(numcte)
				INTO vconteo
				FROM "informix".cb_cat_directorio_cte
				WHERE empresa = vempresa 
				AND tipo_cobranza = ptipo_cobranza
				AND num_producto = vnum_prod
				AND fecha_insert = vfecha_hoy
				AND status_cliente <> 'TE'
				AND pago_venc >= v_pago_venc_ini
				AND pago_venc <= v_pago_venc_fin;

				LET vtotal = ROUND((vconteo * v_porcentaje_asignado)/100);

				SELECT {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} COUNT(cliente) INTO v_cantidadant
				FROM "informix".cb_cat_cte_testigo 
				WHERE cliente > ""
				AND fecha_insert = vfecha_hoy 
				AND tipo_cobranza = ptipo_cobranza
				AND f_vig = "1";

				LET v_asignados = vtotal - v_cantidadant;

				IF v_asignados > 0 THEN
					FOREACH WITH HOLD
						SELECT {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} a.numcte INTO vnumcte
						FROM "informix".cb_cat_directorio_cte a
						WHERE a.empresa = vempresa
						AND a.tipo_cobranza = ptipo_cobranza
						AND a.fecha_insert = vfecha_hoy
						AND a.numcte NOT IN(SELECT agex.numcte FROM "informix".cb_cat_directorio_cte_agex agex WHERE agex.numcte = a.numcte AND agex.fecha_insert = (vfecha_hoy - 1 UNITS MONTH) AND agex.tipo_cobranza = ptipo_cobranza AND agex.f_vigencia = "1" AND agex.num_producto = vnum_prod)
						AND a.status_cliente <> 'TE'
						AND a.num_producto = vnum_prod
						AND a.pago_venc >= v_pago_venc_ini
						AND a.pago_venc <= v_pago_venc_fin

						SELECT LIMIT 1 {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} '1' INTO vbandera
						FROM "informix".cb_cat_cte_testigo WHERE cliente = vnumcte AND fecha_insert = vfecha_hoy AND tipo_cobranza = ptipo_cobranza AND f_vig = "1";

						IF (vbandera IS NULL OR vbandera = '') THEN
							BEGIN WORK;
								INSERT INTO "informix".cb_cat_cte_testigo(cliente, fecha_insert, tipo_cobranza, num_producto, f_vig) 
												values (vnumcte, vfecha_hoy, ptipo_cobranza, vnum_prod, "1");

								UPDATE {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} "informix".cb_cat_directorio_cte 
									SET status_cliente = vstatus, canal = 'TEST'
									WHERE empresa = vempresa 
									AND tipo_cobranza = ptipo_cobranza 
									AND numcte = vnumcte  
									AND fecha_insert = vfecha_hoy
									AND num_producto = vnum_prod;

								LET vcontaux = vcontaux + 1;
							COMMIT WORK;

							IF vcontaux = v_asignados THEN EXIT FOREACH; END IF;
						END IF;

						LET vbandera = '';
					END FOREACH;
				END IF;

				LET v_asignados, vconteo, vtotal, v_cantidadant, vcontaux = 0, 0, 0, 0, 0;

				DROP TABLE paso_testtdc;
			ELSE
				EXIT FOREACH;
			END IF;
		END FOREACH;
	ELIF ptipo_cobranza = 'R' THEN
		SELECT {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} cliente, num_producto, MIN(fecha_insert) fecha_min, MAX(fecha_insert) fecha_max
		FROM "informix".cb_cat_cte_testigo
		WHERE cliente > ""
		AND tipo_cobranza = ptipo_cobranza
		AND f_vig = "1" GROUP BY 1, 2
		INTO TEMP paso_testpp WITH NO LOG;

		CREATE INDEX indx_paso_testpp ON paso_testpp(cliente, num_producto, fecha_max);
		UPDATE STATISTICS MEDIUM FOR TABLE paso_testpp;
	
		FOREACH WITH HOLD
			SELECT DISTINCT(num_producto)
			INTO vnum_prod
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = vempresa 
			AND tipo_cobranza = ptipo_cobranza
			AND fecha_insert = vfecha_hoy
			AND num_producto IN ("6300","7600","7700")

			FOREACH WITH HOLD
				SELECT a.cliente, a.fecha_min
					INTO vnumcte, vfecha_vig
				FROM paso_testpp a
				INNER JOIN "informix".cb_cat_directorio_cte b ON(b.empresa = vempresa AND b.tipo_cobranza = ptipo_cobranza AND b.fecha_insert = vfecha_hoy AND b.numcte = a.cliente AND b.status_cliente <> 'TE' AND b.num_producto = vnum_prod)
				WHERE a.cliente NOT IN(SELECT agex.numcte FROM "informix".cb_cat_directorio_cte_agex agex WHERE agex.numcte = a.cliente AND agex.fecha_insert >= (MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy)) - 1 UNITS MONTH) AND agex.fecha_insert <= MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy)) AND agex.tipo_cobranza = ptipo_cobranza AND agex.f_vigencia = "1" AND agex.num_producto = vnum_prod)
				AND a.num_producto = vnum_prod
				AND a.fecha_max >= (MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy)) - 1 UNITS MONTH)
				AND a.fecha_max <= MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy))

				IF vfecha_vig < (vfecha_hoy - 6 UNITS MONTH) THEN
					BEGIN WORK;
						UPDATE "informix".cb_cat_cte_testigo 
						SET f_vig = "0"
						WHERE cliente = vnumcte
						AND tipo_cobranza = ptipo_cobranza
						AND num_producto = vnum_prod
						AND f_vig = "1";
					COMMIT WORK;

					CONTINUE FOREACH;
				END IF;					

				SELECT LIMIT 1 {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} '1' INTO vbandera
				FROM "informix".cb_cat_cte_testigo WHERE cliente = vnumcte AND fecha_insert = vfecha_hoy AND tipo_cobranza = ptipo_cobranza AND num_producto = vnum_prod AND f_vig = "1";

				IF (vbandera IS NULL OR vbandera = '') THEN
					BEGIN WORK;
						INSERT INTO "informix".cb_cat_cte_testigo(cliente, fecha_insert, tipo_cobranza, num_producto, f_vig) 
										values (vnumcte, vfecha_hoy, ptipo_cobranza, vnum_prod, "1");

						UPDATE {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} "informix".cb_cat_directorio_cte 
							SET status_cliente = vstatus, canal = 'TEST'
							WHERE empresa = vempresa
							AND tipo_cobranza = ptipo_cobranza
							AND numcte = vnumcte
							AND fecha_insert = vfecha_hoy
							AND num_producto = vnum_prod;

						LET vbandera = '';
					COMMIT WORK;
				END IF;
			END FOREACH;

			SELECT COUNT(numcte)
			INTO vconteo
			FROM "informix".cb_cat_directorio_cte
			WHERE empresa = vempresa 
			AND tipo_cobranza = ptipo_cobranza
			AND num_producto = vnum_prod
			AND fecha_insert = vfecha_hoy
			AND status_cliente <> 'TE'
			AND pago_venc >= v_pago_venc_ini
			AND pago_venc <= v_pago_venc_fin;

			LET vtotal = ROUND((vconteo * v_porcentaje_asignado)/100);

			SELECT {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} COUNT(cliente) INTO v_cantidadant
			FROM "informix".cb_cat_cte_testigo 
			WHERE cliente > ""
			AND fecha_insert = vfecha_hoy 
			AND tipo_cobranza = ptipo_cobranza
			AND num_producto = vnum_prod
			AND f_vig = "1";

			LET v_asignados = vtotal - v_cantidadant;

			IF v_asignados > 0 THEN
				FOREACH WITH HOLD
					SELECT {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} a.numcte INTO vnumcte
					FROM "informix".cb_cat_directorio_cte a
					WHERE a.empresa = vempresa
					AND a.tipo_cobranza = ptipo_cobranza
					AND a.fecha_insert = vfecha_hoy
					AND a.numcte NOT IN(SELECT agex.numcte FROM "informix".cb_cat_directorio_cte_agex agex WHERE agex.numcte = a.numcte AND agex.fecha_insert >= (MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy)) - 1 UNITS MONTH) AND agex.fecha_insert <= MDY(MONTH(vfecha_hoy),1,YEAR(vfecha_hoy)) AND agex.tipo_cobranza = ptipo_cobranza AND agex.f_vigencia = "1" AND agex.num_producto = vnum_prod)
					AND a.status_cliente <> 'TE'
					AND a.num_producto = vnum_prod
					AND a.pago_venc >= v_pago_venc_ini
					AND a.pago_venc <= v_pago_venc_fin

					SELECT LIMIT 1 {+INDEX(bdicobranza:cb_cat_cte_testigo idx_testigo)} '1' INTO vbandera
					FROM "informix".cb_cat_cte_testigo WHERE cliente = vnumcte AND fecha_insert = vfecha_hoy AND tipo_cobranza = ptipo_cobranza AND num_producto = vnum_prod AND f_vig = "1";

					IF (vbandera IS NULL OR vbandera = '') THEN
						BEGIN WORK;
							INSERT INTO "informix".cb_cat_cte_testigo(cliente, fecha_insert, tipo_cobranza, num_producto, f_vig) 
											values (vnumcte, vfecha_hoy, ptipo_cobranza, vnum_prod, "1");

							UPDATE {+INDEX(bdicobranza:cb_cat_directorio_cte idx_dir)} "informix".cb_cat_directorio_cte 
								SET status_cliente = vstatus, canal = 'TEST'
								WHERE empresa = vempresa 
								AND tipo_cobranza = ptipo_cobranza 
								AND numcte = vnumcte  
								AND fecha_insert = vfecha_hoy
								AND num_producto = vnum_prod;

							LET vcontaux = vcontaux + 1;
						COMMIT WORK;

						IF vcontaux = v_asignados THEN EXIT FOREACH; END IF;
					END IF;

					LET vbandera = '';
				END FOREACH;
			END IF;

			LET v_asignados, vconteo, vtotal, v_cantidadant, vcontaux = 0, 0, 0, 0, 0;
		END FOREACH;

		DROP TABLE paso_testpp;
	END IF;

	CALL bdicobranza:"informix".inserta_bitacora_cob(vempresa, vproceso, cCodRet, cMensaje, '03');
	RETURN cCodRet;
END;
END PROCEDURE;