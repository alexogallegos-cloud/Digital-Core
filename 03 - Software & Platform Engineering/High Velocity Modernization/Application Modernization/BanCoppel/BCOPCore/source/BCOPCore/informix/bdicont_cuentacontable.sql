CREATE PROCEDURE "informix".cuentacontable(p_empresa CHAR(3), p_ccmayor CHAR(4), p_ccsub CHAR(2), p_ccsubsub CHAR(2), p_ccssubsub CHAR(2), p_ccsssubsub CHAR(2))

    RETURNING CHAR(50), CHAR(4), CHAR(2), CHAR(2), CHAR(2), CHAR(2), CHAR(2),CHAR(50);

DEFINE tccmayor     CHAR(4);
DEFINE tccsub       CHAR(2);
DEFINE tccsubsub    CHAR(2);
DEFINE tccssubsub   CHAR(2);
DEFINE tccsssubsub  CHAR(2);
DEFINE tsector      CHAR(2);
DEFINE tnombre      CHAR(50);

    --**************************************************
    -- Creado por Fabiola Corrales Tapia 22/Mar/2007 --*
    -- Debug del Procedure                           --*
    -- SET DEBUG FILE TO "/tmp/cuentacontable.out";  --*
    -- TRACE ON;                                     --*
    --**************************************************

LET tccmayor    = '';
LET tccsub      = '';
LET tccsubsub   = '';
LET tccssubsub  = '';
LET tccsssubsub = '';
LET tsector     = '';
LET tnombre     = '';

IF (p_ccmayor IS NOT NULL AND p_ccmayor <> '') AND (p_ccsub ='' OR p_ccsub IS NULL) THEN
    FOREACH
        SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre
        INTO tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
        FROM bdinteg:si_catalog
        WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub <> '00' AND ccsubsub = '00'
        AND ccssubsub = '00' AND ccsssubsub = '00' AND sector = '00'

        RETURN NULL, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
        WITH RESUME;
    END FOREACH;
ELSE
    IF (p_ccsub IS NOT NULL AND p_ccsub <> '00' AND p_ccsub <> '') AND (p_ccsubsub ='' OR p_ccsubsub IS NULL) THEN
        FOREACH
            SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre
            INTO tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
            FROM bdinteg:si_catalog
            WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub <> '00'
            AND ccssubsub = '00' AND ccsssubsub = '00' AND sector = '00'

            RETURN NULL, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
            WITH RESUME;
        END FOREACH;
    ELSE
        IF (p_ccsubsub IS NOT NULL AND p_ccsubsub <> '00' AND p_ccsubsub <> '') AND (p_ccssubsub ='' OR p_ccssubsub IS NULL) THEN
            FOREACH
                SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre
                INTO tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                FROM bdinteg:si_catalog
                WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub
                AND ccssubsub <> '00'  AND ccsssubsub = '00' AND sector = '00'

                RETURN NULL, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                WITH RESUME;
            END FOREACH;
        ELSE
            IF (p_ccssubsub IS NOT NULL AND p_ccssubsub <> '00' AND p_ccssubsub <> '') AND (p_ccsssubsub = '' OR p_ccsssubsub IS NULL) THEN
                FOREACH
                    SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre
                    INTO tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                    FROM bdinteg:si_catalog
                    WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub
                    AND ccssubsub = p_ccssubsub AND ccsssubsub <> '00' AND sector = '00'

                    RETURN NULL, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                    WITH RESUME;
                END FOREACH;
            ELSE
                IF p_ccsssubsub IS NOT NULL AND p_ccsssubsub <> '00' AND p_ccsssubsub <> '' THEN
                    FOREACH
                        SELECT ccmayor, ccsub, ccsubsub, ccssubsub, ccsssubsub, sector, nombre
                        INTO tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                        FROM bdinteg:si_catalog
                        WHERE empresa = p_empresa AND ccmayor = p_ccmayor AND ccsub = p_ccsub AND ccsubsub = p_ccsubsub
                        AND ccssubsub = p_ccssubsub AND ccsssubsub = p_ccsssubsub AND sector <> '00'

                        RETURN NULL, tccmayor, tccsub, tccsubsub, tccssubsub, tccsssubsub, tsector, tnombre
                        WITH RESUME;
                    END FOREACH;
                ELSE
                    RETURN 'EL ULTIMO PARAMETRO DEBE SER DIFERENTE DE 00', p_ccmayor, p_ccsub, p_ccsubsub, p_ccssubsub, p_ccsssubsub, NULL, NULL;
                END IF
            END IF
        END IF
    END IF
END IF
IF tccmayor = '' AND tccsub = '' AND tccsubsub = '' AND tccssubsub = '' AND tccsssubsub = '' AND tsector = '' AND tnombre = '' THEN
    RETURN 'NO EXISTEN NIVELES INFERIORES PARA ESTA CUENTA', NULL, NULL, NULL, NULL, NULL, NULL, NULL;
END IF
END PROCEDURE;