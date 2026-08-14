CREATE PROCEDURE "informix".colaborapp_rev( pIdTrxGlobal    VARCHAR(23),
                                            pSistemaOrigen  VARCHAR(9),
                                            pNumEmpCoppel   CHAR(9),
                                            pFolio          CHAR(16) )
RETURNING CHAR(5), CHAR(9), CHAR(16), CHAR(40);
    
    DEFINE iSqlError  INTEGER;
    DEFINE iSamError  INTEGER;
    DEFINE cDesError  CHAR(50);
    DEFINE cSqlErr    CHAR(5);
    DEFINE cIsamErr   CHAR(5);
    DEFINE cDescErr   CHAR(50);
    
    DEFINE cCodRet    CHAR(5);
    DEFINE cDescrip   CHAR(50);
    DEFINE iExiste    INTEGER;
    DEFINE cCodRetRev CHAR(5);
    
    LET iSqlError  = 0;
    LET iSamError  = 0;
    LET cDesError  = '';
    LET cSqlErr    = '';
    LET cIsamErr   = '';
    LET cDescErr   = '';
    
    LET cCodRet    = '';
    LET cDescrip   = '';
    LET iExiste    = 0;
    LET cCodRetRev = '';
    
    BEGIN

    ON EXCEPTION SET iSqlError, iSamError, cDesError
        SET DEBUG FILE TO "/resplogifx/conciliachq/colaborapp_rev.err";
        TRACE ON;
        IF iSqlError <> 0 THEN
            LET cSqlErr  = iSqlError;
            LET cIsamErr = iSamError;
            LET cDescErr = cDesError;
            LET cCodRet = '00999';
            LET cDescrip = 'FALLA DEL SISTEMA';
            RETURN cCodRet, pNumEmpCoppel, pFolio, cDescrip;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/colaborapp_rev.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pIdTrxGlobal is null OR pIdTrxGlobal = '' ) OR
         ( pSistemaOrigen is null OR pSistemaOrigen = '' ) OR
         ( pNumEmpCoppel is null OR pNumEmpCoppel = '' ) OR
         ( pFolio is null OR pFolio = '' ) ) THEN
        LET cCodRet = '00110';
        LET cDescrip = 'DATOS INSUFICIENTES';
        RETURN cCodRet, pNumEmpCoppel, pFolio, cDescrip;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM bdicheq:sc_movdia 
     WHERE folio_suc = pFolio;
       
    IF iExiste = 0 THEN
        LET cCodRet = '00001';
        LET cDescrip = 'OPERACION NO ENCONTRADA';
        RETURN cCodRet, pNumEmpCoppel, pFolio, cDescrip;
    END IF;
    
    EXECUTE PROCEDURE bdicheq:reversion('001', '8509', 'informix', pFolio, 'A')
    INTO cCodRetRev;
    
    IF cCodRetRev = '000' THEN
        LET cCodRet = '00000';
        LET cDescrip  = 'EJECUCION EXITOSA';
        
        INSERT INTO bdicheq:bitacora_colaborapp_rev
        ( idtrxglobal, sistemaorigen, numempcoppel, folio )
        VALUES
        ( pIdTrxGlobal, pSistemaOrigen, pNumEmpCoppel, pFolio );
    ELSE
        LET cCodRet = '00999';
        LET cDescrip  = 'FALLA DEL SISTEMA';
    END IF;
    
    END;
    
    RETURN cCodRet, pNumEmpCoppel, pFolio, cDescrip;
    
END PROCEDURE;