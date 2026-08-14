CREATE PROCEDURE "informix".sp_consultarlogicasustitucion(
													     pEmpresa 		CHAR (3),
													     pSituacion		CHAR(1),
													     pCausa			INTEGER
													    )

	RETURNING
	CHAR(6),  --cod retorno
	CHAR(1),  --Situacion
	INTEGER;  --Causa

	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

	DEFINE v_Situacion	CHAR(1);
	DEFINE v_Causa		INTEGER;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;
    LET v_Situacion = '';
    LET v_Causa = 0;

    --IF pCausa IS NULL THEN
    --    LET pCausa = 0;
    --END IF;

	--12-02-2009
	--Realizo:
	--Abraham Ayala
	--Consultar los datos existentes en el catalogo de logica de sustitucion.

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
	            RETURN v_codret, '', '';
	        END IF;
	    END EXCEPTION;

	--Set debug file to '/tmp/sp_ConsultarLogicaSustitucion.out';
	--trace on;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = '' OR pEmpresa IS NULL ) OR ( pSituacion = '' OR pSituacion IS NULL ) OR ( pCausa = 0 OR pCausa IS NULL ) THEN
            LET v_codret = "999";   --Faltan parametros
            RETURN v_codret, v_Situacion, v_Causa;
	    ELSE
			--Seccion para consultar todas las situaciones y causas por las que puede ser sustituida la Situacion y Causa que se envio como parametro de entrada al SP
			FOREACH
				SELECT {+INDEX (se_logicasustit  idx_logicasustit2)} sitsiguente, causasiguiente
				INTO v_Situacion, v_Causa
				FROM bdisitesp:se_logicasustit
				WHERE empresa = pEmpresa AND
					  situacion = pSituacion AND
					  causa = pCausa

				RETURN v_codret, v_Situacion, v_Causa WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE;