CREATE PROCEDURE "informix".sp_consultarorigen(p_sEmpresa CHAR(3), p_iClaveSE INTEGER, p_sDescripcion CHAR(20))
        RETURNING   CHAR(5),
                    INTEGER,
                    CHAR(20);

    DEFINE vcCodRet CHAR(5);
    DEFINE viSqlErr INTEGER;
    DEFINE v_iClaveSE           INTEGER;
	DEFINE v_sDescripcion		CHAR(20);

    LET vcCodRet = '000';
    LET viSqlErr = 0;
    LET v_iClaveSE = 0;
    LET v_sDescripcion = "";
	--------------------------------------------------------------------------
    -- Creado por Walber Castro 23/02/2009
    --SET DEBUG FILE TO "/tmp/walber/sp_consultarorigen.out";
	--TRACE ON;
	--------------------------------------------------------------------------
    BEGIN
        ON EXCEPTION SET viSqlErr
            LET vcCodRet = viSqlErr;
            RETURN vcCodRet, v_iClaveSE, v_sDescripcion;
        END EXCEPTION;

        IF ( p_iClaveSE is null OR p_iClaveSE = '' ) AND ( p_sDescripcion = '' OR p_sDescripcion is null ) THEN

            FOREACH --SE OBTIENEN TODOS LOS ORIGENES Y SU DESCRIPCION
                SELECT {+INDEX (se_sitesporigen idx_sitesporigen)}cvesitesporigen, descripcion
                INTO v_iClaveSE, v_sDescripcion
                FROM bdisitesp:se_sitesporigen
                WHERE empresa = p_sEmpresa
                ORDER BY cvesitesporigen::INTEGER

                RETURN vcCodRet, v_iClaveSE, v_sDescripcion WITH RESUME;
            END FOREACH;
        ELIF p_iClaveSE is not null AND ( p_sDescripcion = '' OR p_sDescripcion is null ) THEN
            FOREACH --SE OBTIENE LA DESCRIPCION DE UN ORIGEN EN ESPECIFICO
                SELECT {+INDEX (se_sitesporigen idx_sitesporigen)}cvesitesporigen, descripcion
                INTO v_iClaveSE, v_sDescripcion
                FROM bdisitesp:se_sitesporigen
                WHERE empresa = p_sEmpresa AND cvesitesporigen = p_iClaveSE
                ORDER BY cvesitesporigen::INTEGER

                RETURN vcCodRet, v_iClaveSE, v_sDescripcion WITH RESUME;
            END FOREACH;
        ELIF ( p_iClaveSE is null OR p_iClaveSE = '' ) AND ( p_sDescripcion <> '' OR NOT p_sDescripcion is null ) THEN
            FOREACH  --SE OBTIENEN TODOS LOS ORIGENES Y SU DESCRIPCION DEPENDIENDO EL CRITERIO DE BUSKEDA
                SELECT {+INDEX (se_sitesporigen idx_sitesporigen)}cvesitesporigen, descripcion
                INTO v_iClaveSE, v_sDescripcion
                FROM bdisitesp:se_sitesporigen
                WHERE empresa = p_sEmpresa
                AND descripcion LIKE '%' || TRIM(p_sDescripcion) || '%'
                ORDER BY cvesitesporigen::INTEGER

                RETURN vcCodRet, v_iClaveSE, v_sDescripcion WITH RESUME;
            END FOREACH;
        END IF;
    END;
END PROCEDURE;