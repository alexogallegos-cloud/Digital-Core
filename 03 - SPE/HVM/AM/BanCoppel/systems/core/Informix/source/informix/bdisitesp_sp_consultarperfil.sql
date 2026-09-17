CREATE PROCEDURE "informix".sp_consultarperfil(
									pEmpresa		CHAR(3),
									pCvePerfil 		INTEGER,
									pDescripcion	CHAR(50)
									)

	RETURNING
	CHAR(5),	--cod retorno
	INTEGER,	--cveperfil
	CHAR (50);	--Descripcion

	--Declaracion de variables
	DEFINE v_codret CHAR(5);
	DEFINE v_sqlerr INTEGER;

	DEFINE v_CvePerfil INTEGER;
	DEFINE v_Descripcion CHAR(50);

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
    LET v_CvePerfil = 0;
    LET v_Descripcion = '';

	IF pCvePerfil IS NULL THEN
		LET pCvePerfil = 0;
	END IF;
	IF pDescripcion IS NULL THEN
		LET pDescripcion = '';
	ELSE
		LET pDescripcion = UPPER(TRIM(pDescripcion));
	END IF;

	--***********************************************************
	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Consulta los perfiles que coinsidan con los parametros de entrada.
	--***********************************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
                RETURN v_codret, v_CvePerfil , v_Descripcion;
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultarPerfil.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = '' OR pEmpresa IS NULL ) THEN
			LET v_codret = '999';	--Faltan parametros
            RETURN v_codret, v_CvePerfil , v_Descripcion;
		ELSE
			--Consultar todo
			IF pCvePerfil = 0 AND pDescripcion = "" THEN
				FOREACH
					SELECT {+INDEX (se_perfiles idx_perfiles2)} idperfil, descripcion
					INTO v_CvePerfil , v_Descripcion
					FROM bdisitesp:se_perfiles
					WHERE empresa = pEmpresa

					RETURN v_codret, v_CvePerfil , v_Descripcion WITH RESUME;
				END FOREACH;
			--Consultar por Clave prefil
		    ELIF pCvePerfil <> 0 AND pDescripcion = '' THEN
				FOREACH
					SELECT {+INDEX (se_perfiles idx_perfiles2)} idperfil, descripcion
					INTO v_CvePerfil , v_Descripcion
					FROM bdisitesp:se_perfiles
					WHERE empresa = pEmpresa AND
						  idperfil = pCvePerfil

					RETURN v_codret, v_CvePerfil , v_Descripcion WITH RESUME;
				END FOREACH;
			--Consultar por descripcion
			ELIF pCvePerfil = 0 AND pDescripcion <> '' THEN
				FOREACH
					SELECT {+INDEX (se_perfiles idx_perfiles2)} idperfil, descripcion
					INTO v_CvePerfil , v_Descripcion
					FROM bdisitesp:se_perfiles
					WHERE empresa = pEmpresa AND
                          descripcion LIKE '%' || TRIM(pDescripcion) || '%'

					RETURN v_codret, v_CvePerfil , v_Descripcion WITH RESUME;
				END FOREACH;
			--Consultar por ambos valores
			ELIF pCvePerfil <> 0 AND pDescripcion <> '' THEN
				FOREACH
					SELECT {+INDEX (se_perfiles idx_perfiles2)} idperfil, descripcion
					INTO v_CvePerfil , v_Descripcion
					FROM bdisitesp:se_perfiles
					WHERE empresa = pEmpresa AND
						  idperfil = pCvePerfil	AND
                          descripcion LIKE '%' || TRIM(pDescripcion) || '%'


					RETURN v_codret, v_CvePerfil , v_Descripcion WITH RESUME;
				END FOREACH;
			END IF;
		END IF;
	END;
END PROCEDURE;