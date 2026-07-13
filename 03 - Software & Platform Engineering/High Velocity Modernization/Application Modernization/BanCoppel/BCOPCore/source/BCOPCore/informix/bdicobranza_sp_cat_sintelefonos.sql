CREATE PROCEDURE "informix".sp_cat_sintelefonos(ptipo_cobranza char(1))
       RETURNING char(6), char(150);


-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se modifica para procese tambien el tipo de cobranza R

--declaracion de variables
----------------------------------------------------------------------------------------------
DEFINE sql_err 			            INTEGER;
DEFINE isam_err 		            INTEGER;
DEFINE error_info		            CHAR(150);
DEFINE cMensaje 		            CHAR(150);
DEFINE cCod_ret                     CHAR(6);
DEFINE vvcCod_ret                   CHAR(6);
DEFINE vempresa                     CHAR(3);
DEFINE vnumcte                      CHAR(20);
DEFINE vestatus                     CHAR(2);
DEFINE cproceso                     CHAR(4);
DEFINE vfech_insert                 DATE;
DEFINE vday							INTEGER;
DEFINE vnum_prod		  			CHAR(4);
DEFINE vbandera						CHAR(1);

--SET DEBUG FILE TO "/ids10_uc9/jtrujillo/sp_carga_telefonos.out";
--TRACE ON; 

LET cCod_ret          = '000000';
LET sql_err           = 0;
LET isam_err          = 0;
LET error_info        = '';
LET cMensaje          = 'PROCESO EXITOSO';
LET vempresa          = '001';
LET vestatus          = 'AC';
LET cproceso          = '0032';   
LEt vnumcte           = '';
LET vday			  = 0;
LET vnum_prod		  = '';
LET vbandera		  = '';

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
	    LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;
    END EXCEPTION;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF ptipo_cobranza = 'A' THEN
		SELECT MAX(fecha_insert) INTO vfech_insert
		FROM bdicobranza:"informix".cb_cat_directorio_cte
		WHERE empresa = vempresa 
		AND tipo_cobranza = ptipo_cobranza;

		LET vday = DAY(vfech_insert);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = vempresa AND tipo_campania = 61
			AND grupo_parametro = ptipo_cobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = vempresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;

			IF vbandera = 'N' OR vbandera = '' THEN
				LET vbandera = '';
				CONTINUE FOREACH;
			END IF;

			LET vbandera = '';

			SELECT MAX(fecha_insert) INTO vfech_insert
			FROM bdicobranza:"informix".cb_cat_directorio_cte
			WHERE empresa = vempresa 
			AND tipo_cobranza = ptipo_cobranza
			AND num_producto = vnum_prod;

			FOREACH WITH HOLD

				SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio2)} numcte 
					INTO vnumcte
					FROM bdicobranza:"informix".cb_cat_directorio_cte
					WHERE empresa = vempresa
						AND tipo_cobranza = ptipo_cobranza
						AND fecha_insert = vfech_insert
						AND status_cliente = vestatus
						AND num_producto = vnum_prod

				SELECT LIMIT 1 '1' INTO vbandera FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = vnumcte AND cofetel= 'V';

				IF (vbandera IS NULL OR vbandera = '') THEN
					BEGIN WORK;
						UPDATE bdicobranza:cb_cat_directorio_cte SET status_cliente = 'NT'
							WHERE empresa = vempresa AND tipo_cobranza = ptipo_cobranza
							AND numcte = vnumcte AND fecha_insert = vfech_insert AND num_producto = vnum_prod;
					COMMIT WORK;
				END IF;

				LET vbandera = '';
			END FOREACH;
		END FOREACH;
	ELSE
		SELECT MAX(fecha_insert) INTO vfech_insert
		FROM bdicobranza:"informix".cb_cat_directorio_cte
		WHERE empresa = vempresa 
			AND tipo_cobranza = ptipo_cobranza;

		FOREACH WITH HOLD

			SELECT {+INDEX (bdicobranza:cb_cat_directorio_cte idx_cat_directorio2)} numcte 
				INTO vnumcte
				FROM bdicobranza:"informix".cb_cat_directorio_cte
				WHERE empresa = vempresa
					AND tipo_cobranza = ptipo_cobranza
					AND fecha_insert = vfech_insert
					AND status_cliente = vestatus

	/*            WHERE empresa = vempresa
					AND tipo_cobranza = ptipo_cobranza
					AND fecha_insert = vfech_insert
					AND status_cliente = vestatus
					AND numcte NOT IN (SELECT tel.numcte FROM bdinteg:"informix".si_telefonos_actual tel 
										WHERE tel.cofetel= 'V' )*/
			SELECT LIMIT 1 '1' INTO vbandera FROM bdinteg:"informix".si_telefonos_actual WHERE numcte = vnumcte AND cofetel= 'V';

			IF (vbandera IS NULL OR vbandera = '') THEN
				BEGIN WORK;
					UPDATE bdicobranza:cb_cat_directorio_cte SET status_cliente = 'NT'
						WHERE empresa = vempresa AND tipo_cobranza = ptipo_cobranza
						AND numcte = vnumcte AND fecha_insert = vfech_insert;
				COMMIT WORK;
			END IF;

			LET vbandera = '';
		END FOREACH;
	END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje , '03')
        RETURNING vvcCod_ret;

    RETURN cCod_ret, cMensaje;  
	
END;

END PROCEDURE;