CREATE PROCEDURE "informix".graba_sol_precalificada(v_empresa   CHAR(3),
				         v_numsol    CHAR(20),
				         v_numcte    CHAR(20),
     				         v_sucursal  CHAR(4),
     				         v_tpsol     CHAR(1),
     				         v_producto  CHAR(4),
     				         v_ejecutivo CHAR(8),
							 v_subProducto CHAR(4))


RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE v_hoy	    DATE;
--APR 20180605
DEFINE ncliente_pros	CHAR(1);
DEFINE sStatus_numctepros CHAR(2);
--FJPR
DEFINE csucursal   CHAR(4);
-- RQI 21 246  OriginaciÃ³n de solicitudes 24 x 7  
DEFINE vfechaServ DATE;		
--APOLO
DEFINE cUser_insert CHAR(10);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_hoy        =" ";
--APR 20180605
LET ncliente_pros = '';
LET sStatus_numctepros = '';
LET cUser_insert = '';

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
	INSERT INTO ax_paso values ("graba_sol", sql_err);
      RETURN scod_ret;
   END EXCEPTION;

    --Set debug file to '/pisa/pisabanco/graba_sol_precalificada.out';
    --trace on;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	SELECT fecha_hoy INTO v_hoy FROM bdicred:sd_fechas;
	
	-- RQI 21 246  OriginaciÃ³n de solicitudes 24 x 7	
	SELECT DBINFO('utc_to_datetime', sh_curtime)::DATE 
	INTO vfechaServ
	FROM sysmaster:sysshmvals;
	
	IF v_hoy < vfechaServ THEN
		LET v_hoy = vfechaServ;
	END IF;

	-- ***************************************************
	-- Adiciona Registro en Tabla Maestra de Solicitudes *
	-- ***************************************************
	INSERT INTO ss_solicitudes
	 (empresa, num_solicitud, numcte, sucursal, tipo_solicitud,
	  status_solicitud, num_producto, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_numsol, v_numcte, v_sucursal, v_tpsol,
	  "PC", v_producto, v_ejecutivo, v_hoy);

	-- ****************************************************************
	-- Adiciona Registro en Tabla valores informativos de la solicitud*
	-- ****************************************************************
	INSERT INTO ss_anexosol
	 (empresa, num_solicitud, fecha_sol, ejecutivo_sol, user_insert,
	  fecha_insert,cod_linea)
	VALUES
	 (v_empresa, v_numsol, v_hoy, v_ejecutivo, v_ejecutivo, v_hoy,v_subProducto );

	
	-- *********************************************************
	-- Adiciona Registro en Tabla Autorizaciones de Solicitudes*
	-- *********************************************************

/*	INSERT INTO ss_autorizacion 
	 (empresa, ejecutivo_auto, num_solicitud, status_solicitud, comentario,
	  fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_ejecutivo, v_numsol, "PC", 
	  "Solicitud Pre-Calificada  por sistema", 
          v_hoy, v_hoy, v_ejecutivo, v_hoy);*/

		  
	IF EXISTS(SELECT a.numcte
	FROM bdisolic:'informix'.ss_solicitudes a
	JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
	JOIN bdiprospectos:'informix'.pr_autorizacion c ON b.numcte_pros = c.num_solicitud
	WHERE a.num_solicitud = v_numsol
	and c.status_solicitud = 'PC') THEN

		SELECT b.status_numcte_pros INTO sStatus_numctepros
		FROM bdisolic:'informix'.ss_solicitudes a
		JOIN bdiprospectos:'informix'.pr_cliente b ON a.numcte = b.numcte
		AND a.num_solicitud = v_numsol;

		IF sStatus_numctepros NOT IN ('CM','RT','CN') THEN
			IF (SELECT COUNT(num_solicitud) FROM bdisolic: ss_autorizacion where num_solicitud = v_numsol AND status_solicitud = 'PC') > 1 THEN
				LET ncliente_pros = '1';
			ELSE
				IF (EXISTS(SELECT num_solicitud FROM bdisolic: ss_autorizacion where num_solicitud = v_numsol AND status_solicitud = 'OA'))
					AND ('PC' in ('EE','OS')) THEN
					LET ncliente_pros = '1';
				ELSE
					LET ncliente_pros = '2';
				END IF;
			END IF;
		END IF;
		
	END IF

	INSERT INTO ss_autorizacion 
	 (empresa, ejecutivo_auto, num_solicitud, status_solicitud, cliente_pros, comentario,
	  fecha_entrada, fecha_salida, user_insert, fecha_insert)
	VALUES
	 (v_empresa, v_ejecutivo, v_numsol, "PC", ncliente_pros, 
	  "Solicitud Pre-Calificada  por sistema", 
          v_hoy, v_hoy, v_ejecutivo, v_hoy);
	IF ncliente_pros IN ('1','2') THEN
	
		SELECT sucursal INTO csucursal FROM bdiprospectos:pr_cliente WHERE numcte = v_numcte;
		IF csucursal = '0800' THEN
		
			UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '3'
			WHERE numcte = v_numcte AND num_solicitud = v_numsol;
		
		ELSE
			UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '5'
			WHERE numcte = v_numcte AND num_solicitud = v_numsol;
		
		END IF;	
		
	ELIF ncliente_pros = '' THEN
	
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '1'
		WHERE numcte = v_numcte AND num_solicitud = v_numsol;
	
	END IF;
	
	SELECT user_insert INTO cUser_insert FROM bdinteg:si_cliente WHERE numcte = v_numcte;

	IF cUser_insert = 'sysapolo' THEN		
		UPDATE bdisolic:"informix".ss_solicitudes SET canal_sol = '9'
		WHERE numcte = v_numcte AND num_solicitud = v_numsol;
	END IF;
	
END
	RETURN scod_ret;
END PROCEDURE
;