CREATE PROCEDURE "informix".sp_consultaslconsat(cRfc CHAR(13), cAnio CHAR(6))
RETURNING CHAR(5),    -- Codigo de Retorno
          DATE,       -- Fecha Cons
          CHAR(1),    -- Exento
          CHAR(1)     -- Estado

    -- DEFINICION DE VARIABLES --
    DEFINE iSql_Err INTEGER;
    DEFINE cCodRet CHAR(5);
    DEFINE dFechaCons DATE;
    DEFINE cExento CHAR(1);
    DEFINE cEstado CHAR(1);

    --INICIALIZACION DE VARIABLES--
    LET iSql_Err = 0;
    LET cCodRet = '000';
    LET dFechaCons = '';
    LET cExento = '';
    LET cEstado = '';

    BEGIN

    ON EXCEPTION SET iSql_Err
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, dFechaCons, cExento, cEstado;
        END IF;
    END  EXCEPTION;

    --- SET DEBUG FILE TO "/tmp/sp_consultaslconsat.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH
        SELECT fecha_sol, estado
          INTO dFechaCons, cEstado
          FROM bdilide:sl_consat
         WHERE rfc = cRfc
           AND YEAR(fecha_sol) = cAnio
           
        SELECT status
          INTO cExento
          FROM bdilide:sl_exentos
         WHERE rfc = cRfc;
         
        IF cExento is null  THEN
            LET cExento = '';
        END IF;

        RETURN cCodRet, dFechaCons, cExento, cEstado WITH RESUME;
    END FOREACH;

    END;
    
END PROCEDURE
