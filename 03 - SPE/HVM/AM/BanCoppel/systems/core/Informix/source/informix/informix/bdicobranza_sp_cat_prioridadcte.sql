CREATE PROCEDURE "informix".sp_cat_prioridadcte(Ptipo_cobranza CHAR(1))
       RETURNING char(6), char(150);

-- Modificado por: Martha A Hernandez
-- Fecha: Noviembre 2011
-- Modificacion: Se agrega funcionalidad para tipo cobranza = 'R'  que incluye Reestructuras y Prestamo Personal

--declaracion de variables
------------------------------------------------------------
DEFINE cCod_ret                 CHAR(6);
DEFINE sql_err 			        INTEGER;
DEFINE isam_err 		        INTEGER;
DEFINE error_info		        CHAR(150);
DEFINE vvccod_ret               CHAR(6);
DEFINE cMensaje 		        CHAR(150);
DEFINE vtipo_logica             INTEGER;
DEFINE vnumcte                  CHAR(20);
DEFINE vpago_venc               INTEGER;
DEFINE vpago_minimo             DECIMAL(18,2);
DEFINE vfecha_insert            DATE;
DEFINE vfecha                   DATE;
DEFINE vnum_credito             CHAR(20);
DEFINE vprioridad               SMALLINT;
DEFINE vempresa                 CHAR(3);
DEFINE cProceso                 CHAR(4);
DEFINE vday						INTEGER;
DEFINE vnum_prod		  		CHAR(4);
DEFINE vbandera					CHAR(1);

------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------
------------------------------------------------------------

--SET DEBUG FILE TO '/tmp/sp_obtiene_prioridad.out';
--TRACE ON;


LET cCod_ret      = '000000';
LET sql_err       = 0;
LET isam_err      = 0;
LET error_info    = '';
LET cMensaje      = 'PROCESO EXITOSO';
LET vempresa      = '001';
LET cProceso      = '0007';
LET vpago_venc    = 0;
LET vpago_minimo  = 0;
LET vnum_credito  = '';
LET vprioridad    = 0;
LET vday			= 0;
LET vnum_prod		= '';
LET vbandera		= '';

------------------------------------------------------------
-----------------------------------------------------------

BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
	    LET cMensaje = error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
            RETURNING vvcCod_ret;
		RETURN cCod_ret, cMensaje;

    END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01')
            RETURNING vvcCod_ret;

        --se obtiene la informacion

	IF Ptipo_cobranza = 'A' THEN
		SELECT MAX(fecha_insert) INTO vfecha
		FROM bdicobranza:cb_cat_directorio_cte
		WHERE empresa = vempresa AND tipo_cobranza = Ptipo_cobranza;
	
		LET vday = DAY(vfecha);

		FOREACH WITH HOLD
			SELECT valor_alfabetico INTO vnum_prod
			FROM "informix".cb_param_campania 
			WHERE empresa = vempresa AND tipo_campania = 61
			AND grupo_parametro = Ptipo_cobranza
			AND valor_numerico = vday

			IF vnum_prod IS NULL THEN LET vnum_prod = ''; END IF;

			SELECT descripcion INTO vbandera FROM bdicobranza:"informix".cb_param WHERE empresa = vempresa AND valor = vnum_prod;

			IF vbandera IS NULL THEN LET vbandera = ''; END IF;

			IF (vbandera = 'N' OR vbandera = '') THEN
				LET vbandera = '';
				CONTINUE FOREACH;
			END IF;

			SELECT MAX(fecha_insert) INTO vfecha
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE empresa = vempresa AND tipo_cobranza = Ptipo_cobranza
			AND num_producto = vnum_prod;
			
			FOREACH WITH HOLD
				SELECT a.numcte,  b.num_credito, a.pago_venc, a.tipo_logica, a.fecha_insert, d.monto_financiado
				INTO vnumcte ,vnum_credito, vpago_venc, vtipo_logica, vfecha_insert, vpago_minimo
				FROM bdicobranza:cb_cat_directorio_cte a
				LEFT JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
				LEFT JOIN bdicred:sd_maesdos d ON (d.empresa = b.empresa AND d.num_credito = b.num_credito)
				WHERE a.tipo_cobranza = Ptipo_cobranza
				AND a.fecha_insert = vfecha
				AND a.tipo_logica >= 1
				AND a.num_producto = vnum_prod

				LET vprioridad= 0;

				IF vpago_minimo IS NULL THEN LET vpago_minimo = 0; END IF;

				SELECT {+INDEX(bdicobranza:cb_catprioridad cb_catprioridad_idx)} first 1 prioridad
					INTO vprioridad
					FROM bdicobranza:cb_catprioridad
					WHERE tipologica = vtipo_logica
					AND mesesvencidos = vpago_venc
					AND vpago_minimo >= rangoinicial  and vpago_minimo < rangofinal;

				BEGIN WORK;
					UPDATE bdicobranza:cb_cat_directorio_cte
					SET prioridad= vprioridad
					WHERE empresa= vempresa
					AND tipo_cobranza= Ptipo_cobranza
					AND numcte= vnumcte
					AND fecha_insert= vfecha_insert
					AND num_producto = vnum_prod;
				COMMIT WORK;
			END FOREACH;
		END FOREACH;
    ---------------------------- Se obtienen DATOS del CLIENTE y SALDOS---------------------------
    ELSE
		SELECT MAX(fecha_insert) INTO vfecha
			FROM bdicobranza:cb_cat_directorio_cte
			WHERE empresa = vempresa AND tipo_cobranza = Ptipo_cobranza;

		IF (Ptipo_cobranza = 'P') THEN
			FOREACH WITH HOLD
				SELECT a.numcte,  b.num_credito, a.pago_venc, a.tipo_logica, a.fecha_insert, d.monto_financiado
					INTO vnumcte ,vnum_credito, vpago_venc, vtipo_logica, vfecha_insert, vpago_minimo
					FROM bdicobranza:cb_cat_directorio_cte a
					LEFT JOIN bdicred:sd_maecred b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
					LEFT JOIN bdicred:sd_maesdos d ON (d.empresa = b.empresa AND d.num_credito = b.num_credito)
					WHERE a.tipo_cobranza = Ptipo_cobranza
						AND a.fecha_insert = vfecha
						AND a.tipo_logica >= 1

				LET vprioridad= 0;

				IF vpago_minimo IS NULL THEN LET vpago_minimo = 0; END IF;

				SELECT {+INDEX(bdicobranza:cb_catprioridad cb_catprioridad_idx)} first 1 prioridad
					INTO vprioridad
					FROM bdicobranza:cb_catprioridad
					WHERE tipologica = vtipo_logica
					AND mesesvencidos = vpago_venc
					AND vpago_minimo >= rangoinicial  and vpago_minimo < rangofinal;

				BEGIN WORK;
					UPDATE bdicobranza:cb_cat_directorio_cte
					SET prioridad= vprioridad
					WHERE empresa= vempresa
					AND tipo_cobranza= Ptipo_cobranza
					AND numcte= vnumcte
					AND fecha_insert= vfecha_insert;
				COMMIT WORK;
			END FOREACH;
		ELSE            -- Tipo cobranza R, E


			FOREACH WITH HOLD

				SELECT a.numcte,  b.num_credito, a.pago_venc, a.tipo_logica, a.fecha_insert, d.monto_financiado
					INTO vnumcte ,vnum_credito, vpago_venc, vtipo_logica, vfecha_insert, vpago_minimo
					FROM bdicobranza:cb_cat_directorio_cte a 
					LEFT JOIN bdicred:sd_maecredcrd b ON (b.empresa = a.empresa AND b.num_credito = a.num_credito)
					LEFT JOIN bdicred:sd_maesdoscrd d ON (d.empresa = b.empresa AND d.num_credito = b.num_credito)
					WHERE a.tipo_cobranza = Ptipo_cobranza
						AND a.fecha_insert = vfecha
						AND a.tipo_logica >= 1

				LET vprioridad= 0;

				IF vpago_minimo IS NULL THEN LET vpago_minimo = 0; END IF;

				SELECT {+INDEX(bdicobranza:cb_catprioridad cb_catprioridad_idx)} first 1 prioridad
					INTO vprioridad
					FROM bdicobranza:cb_catprioridad
					WHERE tipologica = vtipo_logica
					AND mesesvencidos = vpago_venc
					AND vpago_minimo >= rangoinicial  and vpago_minimo < rangofinal;

				BEGIN WORK;
					UPDATE bdicobranza:cb_cat_directorio_cte
					SET prioridad= vprioridad
					WHERE empresa= vempresa
					AND tipo_cobranza= Ptipo_cobranza
					AND numcte= vnumcte
					AND fecha_insert= vfecha_insert;
				COMMIT WORK;

			END FOREACH;
		END IF;
    END IF;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
        RETURNING vvcCod_ret;
	RETURN cCod_ret, cMensaje;

END;

END PROCEDURE;