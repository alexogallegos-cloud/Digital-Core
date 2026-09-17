CREATE PROCEDURE "informix".sp_finalizacedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_finalizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_finalizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'CAPITAL';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INTERES';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'SOBREGIRO';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INT PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;