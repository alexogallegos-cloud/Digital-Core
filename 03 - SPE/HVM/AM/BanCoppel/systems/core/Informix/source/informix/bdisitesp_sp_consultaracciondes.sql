CREATE PROCEDURE "informix".sp_consultaracciondes(
												 pEmpresa 		CHAR (3),
												 pSituacion		CHAR(1),
                                                 pCausa         INTEGER
												)

	RETURNING
	CHAR(6),  --cod retorno
	INTEGER,  --IdAccion
    CHAR(1),  --instruccion
    INTEGER;  --Tipo Marca

	--Declaracion de variables
	DEFINE v_codret 		CHAR(6);
	DEFINE v_sqlerr 		INTEGER;

    DEFINE v_IdAccion       CHAR(5);
	DEFINE v_Instruccion	CHAR(1);
    DEFINE v_IdTipoMarca   INTEGER;

	--Inicializacion de variables
	LET v_codret = "000";
	LET v_sqlerr = 0;

    LET v_IdAccion = "";
    LET v_Instruccion = "";
    LET v_IdTipoMarca = 0;
    --IF pCausa IS NULL THEN
    --    LET pCausa = 0;
    --END IF;
    --IF pIdTipoMarca IS NULL THEN
    --    LET pIdTipoMarca = 0;
    --END IF;

	--*******************************************
	--13-02-2009
	--Realizo:
	--Abraham Ayala
	--Mostrar los datos solicitados para consultar
	--*******************************************
    --20-04-2009
	--Realizo:
    --Walber Castro
    --Se elimina el tipo de marca de los parametros y de la consulta.
    --*******************************************

	BEGIN
	    ON EXCEPTION SET v_sqlerr
	        IF v_sqlerr != 0 THEN
	            LET v_codret = v_sqlerr;
                RETURN v_codret, '', '', 0;
	        END IF;
	    END EXCEPTION;

	--SET debug FILE TO '/tmp/sp_ConsultarAccionDes.out';
	--trace ON;

	    --checar valores nulos en los parametros
        IF ( pEmpresa = "" OR pEmpresa IS NULL ) OR ( pSituacion = "" OR pSituacion IS NULL ) OR ( pCausa = 0 OR pCausa IS NULL ) THEN
            LET v_codret = "999";   --Faltan parametros
            RETURN v_codret, '', 0, 0;
	    ELSE
			--Seccion para consultar todas las acciones que ccoinsidan con los datos recibidos en el SP
			FOREACH
        SELECT {+ index (se_situacionaccion idx_situacionaccion)} idaccion, instruccion, idtipomarca
        INTO v_IdAccion, v_Instruccion, v_IdTipoMarca
				FROM bdisitesp:se_situacionaccion
				WHERE empresa = pEmpresa AND
					  situacion = pSituacion AND
                      causa = pCausa

                RETURN v_codret, v_IdAccion, v_Instruccion, v_IdTipoMarca WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE;