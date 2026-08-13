CREATE PROCEDURE "informix".sp_consultarecaudacioneslide(cNumCte CHAR(20), cRfc CHAR(13), cAnioMes1 CHAR(6), cAnioMes2 CHAR(6))
RETURNING CHAR(5) -- DATOS A REGRESAR --

    -- DEFINICION DE VARIABLES --
    DEFINE iSql_Err INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE vexiste INTEGER;

    --INICIALIZACION DE VARIABLES--
    LET iSql_Err = 0;
    LET cCodRet = '000';
    LET vexiste = 0;

    BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet;
        END IF;
    END  EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_consultarecaudacioneslide.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    SELECT COUNT(*)
      INTO vexiste
      FROM bdilide:sl_retlide
     WHERE num_cte = cNumCte
       AND rfc = cRfc
       AND aniomes BETWEEN cAnioMes1 AND cAnioMes2;

    IF vexiste > 0 THEN
    --- IF EXISTS(SELECT num_cte FROM bdilide:sl_retlide WHERE num_cte = cNumCte AND rfc = cRfc AND aniomes BETWEEN cAnioMes1 AND cAnioMes2) THEN
        LET cCodRet = '001';
    END IF;

    RETURN cCodRet;

    END;
    
END PROCEDURE
