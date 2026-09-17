CREATE PROCEDURE "informix".sp_finintisrxprodcedula( pFecha DATE ) 
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
        SET DEBUG FILE TO "/tmp/sp_finintisrxprodcedula.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_finintisrxprodcedula.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pFecha is null OR pFecha = '' )  THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_intisrxprodcedula
     WHERE fecha = pFecha;
       
    IF iExiste > 0 THEN
        UPDATE bdicheq:sc_intisrxprodcedula
           SET editable = '1'
         WHERE fecha = pFecha;
           
        RETURN cCodRet1;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1;
    END IF;
     
    END;
    
END PROCEDURE;