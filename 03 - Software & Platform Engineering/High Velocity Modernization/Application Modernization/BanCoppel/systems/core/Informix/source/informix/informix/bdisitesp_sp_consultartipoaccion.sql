CREATE PROCEDURE "informix".sp_consultartipoaccion(
												  pEmpresa 		CHAR(3),
												  pIdAccion		INTEGER,
												  pdescaccion	CHAR(40)
												 )

	RETURNING
	CHAR(5),	--cod retorno
	INTEGER,	--IdAccion
	CHAR(40); 	--descaccion

	--Declaracion de variables
	DEFINE v_codret 		CHAR(5);
	DEFINE v_sqlerr 		INTEGER;

	DEFINE v_IdAccion		INTEGER;
	DEFINE v_descaccion		CHAR(40);

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
    LET v_IdAccion = 0;
    LET v_descaccion = '';

	IF pIdAccion IS NULL THEN
		LET pIdAccion = 0;
	END IF;
	IF pdescaccion IS NULL THEN
		LET pdescaccion = '';
	ELSE
		LET pdescaccion = UPPER(TRIM(pdescaccion));
	END IF;

	--***********************************
	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Obtener las posibles tipos de acciones.
	--***********************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
                RETURN v_codret, v_IdAccion , v_descaccion;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultarTipoAccion.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF pEmpresa = '' OR pEmpresa IS NULL THEN
			LET v_codret = '999';	--Faltan parametros
            RETURN v_codret, v_IdAccion , v_descaccion;
		ELSE
			--Consultar todo
			IF pIdAccion = 0 AND pdescaccion = "" THEN
				FOREACH
					SELECT {+INDEX (se_seaccdesenc idx_seaccdesenc)} idaccion, descaccion
					INTO v_IdAccion , v_descaccion
					FROM bdisitesp:se_seaccdesenc
					WHERE empresa = pEmpresa

					RETURN v_codret, v_IdAccion , v_descaccion WITH RESUME;
				END FOREACH;
			--Consultar por Clave prefil
		    ELIF pIdAccion <> 0 AND pdescaccion = '' THEN
				FOREACH
                    SELECT {+INDEX (se_seaccdesenc idx_seaccdesenc)} idaccion, descaccion
					INTO v_IdAccion , v_descaccion
					FROM bdisitesp:se_seaccdesenc
					WHERE empresa = pEmpresa AND
						  idaccion = pIdAccion

					RETURN v_codret, v_IdAccion , v_descaccion WITH RESUME;
				END FOREACH;
			--Consultar por descaccion
			ELIF pIdAccion = 0 AND pdescaccion <> '' THEN
				FOREACH
                    SELECT {+INDEX (se_seaccdesenc idx_seaccdesenc)} idaccion, descaccion
					INTO v_IdAccion , v_descaccion
					FROM bdisitesp:se_seaccdesenc
					WHERE empresa = pEmpresa AND
                          descaccion LIKE '%' || TRIM(pdescaccion) || '%'

					RETURN v_codret, v_IdAccion , v_descaccion WITH RESUME;
				END FOREACH;
			--Consultar por ambos valores
			ELIF pIdAccion <> 0 AND pdescaccion <> '' THEN
				FOREACH
                    SELECT {+INDEX (se_seaccdesenc idx_seaccdesenc)} idaccion, descaccion
					INTO v_IdAccion , v_descaccion
					FROM bdisitesp:se_seaccdesenc
					WHERE empresa = pEmpresa AND
						  idaccion = pIdAccion	AND
                          descaccion LIKE '%' || TRIM(pdescaccion) || '%'

					RETURN v_codret, v_IdAccion , v_descaccion WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
	END;
END PROCEDURE;