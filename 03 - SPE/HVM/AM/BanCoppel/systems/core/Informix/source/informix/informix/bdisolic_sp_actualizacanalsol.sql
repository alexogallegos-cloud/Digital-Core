CREATE PROCEDURE "informix".sp_actualizacanalsol ()	
RETURNING CHAR(5);          -- Codigo de Retorno

-- EXCEPTION
DEFINE cCodRet          CHAR(5);
DEFINE vsqlerr          INTEGER;

DEFINE v_num_solicitud  CHAR(20);
DEFINE v_numcte         CHAR(20);


-- INICIALIZA VARIABLES
LET cCodRet         = '00000';
LET vsqlerr         = 0;

LET v_num_solicitud = '';
LET v_numcte = '';

BEGIN
    ON EXCEPTION SET vsqlerr
        IF vsqlerr != 0 THEN
            LET cCodRet = vsqlerr;
            RETURN TRIM(cCodRet);
        END IF;
    END EXCEPTION;

    -- 81,937 solicitudes con canal nulo
    FOREACH WITH HOLD
        SELECT  num_solicitud, numcte
        INTO    v_num_solicitud, v_numcte
        FROM    bdisolic:ss_solicitudes 
        WHERE   empresa='001' 
        AND     num_solicitud IN (  SELECT  num_credito 
                                    FROM    bdicred:sd_maecred 
                                    WHERE   status_cred IN ('E1','E2','E3') 
                                    AND     num_producto ='7800') 
        AND     num_producto ='7800' 
        AND     canal_sol IS NULL

            BEGIN WORK;
            UPDATE  bdisolic:ss_solicitudes 
            SET     canal_sol = '1'
            WHERE   num_solicitud = v_num_solicitud
            AND     numcte = v_numcte;
            COMMIT WORK;

    END FOREACH;

    RETURN cCodRet; 
END
END PROCEDURE
