CREATE PROCEDURE "informix".sp_reportetipobusqueda(
												    pEmpresa	CHAR(3),
											      pDia 		  DATE,
											      pDiaMin	  DATE,
											      pDiaMax	  DATE,
												    pUsuario	CHAR(8),
												    pArea		  CHAR(50)
											     )

	RETURNING
	CHAR(6),  --cod retorno
	CHAR(8),  --Usuario
	CHAR(50), --Area
	INTEGER,  --Nuevos
	INTEGER,  --Sustituidos
	INTEGER,  --Eliminados
	INTEGER;  --Total

	--Declaracion de variables
	DEFINE v_codret 		  CHAR(6);
	DEFINE v_sqlerr 		  INTEGER;

	DEFINE v_Nuevo			  INTEGER;
	DEFINE v_Sustituidos	INTEGER;
	DEFINE v_Eliminados		INTEGER;
	DEFINE v_Total			  INTEGER;

	DEFINE v_IdArea			  INTEGER;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

	LET v_Nuevo			  = 0;
	LET v_Sustituidos	= 0;
	LET v_Eliminados	= 0;
	LET v_Total			  = 0;

	--******************************************************
	--12-02-2009
	--Realizo:
	--tmp_reportes_sitesp Ayala
	--Obtener los toales de los movimientos de Situaciones y Causa.
	--******************************************************
	--21-04-2010
	--Modificó: Bernardo Carlos Baez Gonzalez
	--Se modifica para solo contemplar SE y Causas que apliquen a clientes
	--******************************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, pUsuario, '', v_Nuevo, v_Sustituidos, v_Eliminados, v_Total;
	        END IF;
	    END EXCEPTION;

	--SET debug FILE TO '/tmp/sp_ReporteTipoBusqueda.out';
--trace ON;

	    --checar valores nulos en los parametros
	    IF pEmpresa = "" THEN

	        LET v_codret = "999";	--Faltan parametros
	        RETURN v_codret, pUsuario, '', v_Nuevo, v_Sustituidos, v_Eliminados, v_Total;
	    ELSE	--Seccion para consultar todos los datos

			--Validamos si la tabla existe, de ser asi la eliminamos
			IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_reportes_sitesp' AND dbsname = 'bdisitesp') THEN
				DROP TABLE tmp_reportes_sitesp;
			END IF;

			--Creamos una tabla temporal para juntar los campos de las tablas historicas de cliente y credito de situaciones especiales, para trabajar en base a los datos agrupados
			/*SELECT {+ INDEX(bdisitesp:se_ctessitespcred_his se_ctessitespcred_his_idx3)} tipomovto, numcte, empresa, fchalta, fchmodifica,
				   (CASE WHEN tipomovto IN ("S", "E") THEN usrmodifica ELSE usralta END) AS usuario
			FROM bdisitesp:se_ctessitespcred_his
			UNION ALL*/
			SELECT {+ INDEX(bdisitesp:se_ctessitespcte_his se_ctessitespcte_his_idx1)} tipomovto, numcte, empresa, fchalta, fchmodifica,
				     (CASE WHEN tipomovto IN ("S", "E") THEN usrmodifica ELSE usralta END) AS usuario
			  FROM bdisitesp:se_ctessitespcte_his
			  INTO temp tmp_reportes_sitesp;

			IF pDia <> DATE(1) AND pDia IS NOT NULL THEN
				--Seccion para consultar por dia
				FOREACH
					SELECT usuario, SUM(CASE WHEN tipomovto = "M" THEN 1 ELSE 0 END),
								 SUM(CASE WHEN tipomovto = "S" THEN 1 ELSE 0 END),
								 SUM(CASE WHEN tipomovto = "E" THEN 1 ELSE 0 END)
					  INTO pUsuario, v_Nuevo, v_Sustituidos, v_Eliminados
					  FROM tmp_reportes_sitesp
					 WHERE empresa = pEmpresa
					   AND DATE(fchalta) = pDia
						  OR DATE(fchmodifica) = pDia
					 GROUP BY usuario

					LET v_Total = v_Nuevo + v_Sustituidos + v_Eliminados;

					RETURN v_codret, pUsuario, '', v_Nuevo, v_Sustituidos, v_Eliminados, v_Total WITH RESUME;

				END FOREACH;

				--Validamos si la tabla existe, de ser asi la eliminamos
				IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_reportes_sitesp' AND dbsname = 'bdisitesp') THEN
					DROP TABLE tmp_reportes_sitesp;
				END IF;

			ELIF pDiaMin <> DATE(1) AND pDiaMin IS NOT NULL AND pDiaMax <> DATE(1) AND pDiaMax IS NOT NULL THEN
				FOREACH
					--Seccion para buscar por un rango de fecha
					SELECT usuario, SUM(CASE WHEN tipomovto = "M" THEN 1 ELSE 0 END),
								 SUM(CASE WHEN tipomovto = "S" THEN 1 ELSE 0 END),
								 SUM(CASE WHEN tipomovto = "E" THEN 1 ELSE 0 END)
					  INTO pUsuario, v_Nuevo, v_Sustituidos, v_Eliminados
					  FROM tmp_reportes_sitesp
					 WHERE empresa = pEmpresa
					   AND DATE(fchalta) BETWEEN pDiaMin AND pDiaMax
						  OR DATE(fchmodifica) BETWEEN pDiaMin AND pDiaMax
					 GROUP BY usuario

					LET v_Total = v_Nuevo + v_Sustituidos + v_Eliminados;

					RETURN v_codret, pUsuario, '', v_Nuevo, v_Sustituidos, v_Eliminados, v_Total WITH RESUME;

				END FOREACH;

				--Validamos si la tabla existe, de ser asi la eliminamos
				IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'tmp_reportes_sitesp' AND dbsname = 'bdisitesp') THEN
					DROP TABLE tmp_reportes_sitesp;
				END IF;

			ELIF pUsuario <> '' AND pUsuario IS NOT NULL THEN
				--Seccion para buscar por usuario
				SELECT SUM(CASE WHEN tipomovto = "M" THEN 1 ELSE 0 END),
					     SUM(CASE WHEN tipomovto = "S" THEN 1 ELSE 0 END),
					     SUM(CASE WHEN tipomovto = "E" THEN 1 ELSE 0 END)
				  INTO v_Nuevo, v_Sustituidos, v_Eliminados
				  FROM tmp_reportes_sitesp
				 WHERE empresa = pEmpresa
				   AND usuario = pUsuario
				 GROUP BY usuario;

				--Eliminamos la tabla temporal
				DROP TABLE tmp_reportes_sitesp;

				LET v_Total = v_Nuevo + v_Sustituidos + v_Eliminados;

				RETURN v_codret, pUsuario, '', v_Nuevo, v_Sustituidos, v_Eliminados, v_Total;
			END IF;
		END IF;
	END;
END PROCEDURE;