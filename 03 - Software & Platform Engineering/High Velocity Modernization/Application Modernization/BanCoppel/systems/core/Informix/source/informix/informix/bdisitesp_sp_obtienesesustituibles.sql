CREATE PROCEDURE "informix".sp_obtienesesustituibles(pEmpresa CHAR(3), pSE CHAR(1), pCausa SMALLINT, pAlcance SMALLINT)

    RETURNING
    CHAR(6), CHAR(5), CHAR(5), CHAR(75); --cod retorno

    --EL PARAMETRO ALCANCE ES PARA FILTRAR LA BUSQUEDA, POR EJEMPLO SI SOLO SE REQUIEREN CONSULTAR LAS SE SUSTITUIBLES PARA EL CLIENTE NO PARA EL CREDITO.
    --VALORES DE ALCANCE:
    --0=CLIENTE, 1=CREDITO, 2=AMBOS

    --Definicion de variables
    DEFINE v_codret CHAR(6);
    DEFINE v_sqlerr INTEGER;

    DEFINE v_SE             CHAR(1);
    DEFINE v_Causa          SMALLINT;
    DEFINE v_Descripcion    CHAR(75);

	--SET DEBUG FILE TO "/tmp/sp_ObtieneSESustituibles.out"; --*
    --TRACE ON;  
    --Inicializacion de variables
    LET v_codret 		= "000";
    LET v_sqlerr 		= 0;

    LET v_SE            = "";
    LET v_Causa         = 0;
    LET v_Descripcion   = "";

	IF pSE <> "" AND pSE IS NOT NULL THEN
		LET pSE = UPPER(pSE);
	END IF;

    --06-03-2009
    --Realizo:
    --Walber Castro
    --Consulta las SE y Causas que pueden sustituir a la SE que llego por parámetro.

    BEGIN
        ON EXCEPTION SET v_sqlerr
            IF v_sqlerr != 0 THEN
                LET v_codret = v_sqlerr;
                RETURN v_codret, v_SE, v_Causa, v_Descripcion;
            END IF;
        END EXCEPTION;

        --checar valores nulos en los parametros
            IF (pSE = "" OR pSE IS NULL) OR (pCausa = 0 OR pCausa IS NULL) OR (pEmpresa = "" OR pEmpresa IS NULL) THEN
                LET v_codret = "999";   --Faltan parametros
                RETURN v_codret, v_SE, v_Causa, v_Descripcion;
            ELSE
                --Validar si no existe la SE y Causa
                IF NOT EXISTS (SELECT {+ INDEX(se_catsitesp idx_catsitesp)} situacion FROM bdisitesp:se_catsitesp WHERE situacion = pSE AND causa = pCausa) THEN
                    LET v_codret = "001";   --No es una SE y Causa validos
                    RETURN v_codret, v_SE, v_Causa, v_Descripcion;
                ELSE
                    -- Obtener SE y Causa que pueden sustituir a la SE Parametrizada.
                    FOREACH
                        SELECT {+ INDEX(se_catsitesp idx_catsitesp2)} a.sitsiguente, a.causasiguiente, b.descripcion
                        INTO v_SE, v_Causa, v_Descripcion
                        FROM bdisitesp:se_logicasustit a
						INNER JOIN bdisitesp:se_catsitesp b ON ( a.sitsiguente = b.situacion
																AND a.causasiguiente = b.causa
																AND a.empresa = b.empresa)
                        WHERE a.situacion = pSE
							AND a.causa = pCausa
							AND a.empresa = pEmpresa
							AND b.alcance IN (pAlcance, 2)
						ORDER BY a.sitsiguente, a.causasiguiente::INTEGER

                        RETURN v_codret, v_SE, v_Causa, v_Descripcion WITH RESUME;
                    END FOREACH;
                END IF;
            END IF;
    END;
END PROCEDURE;