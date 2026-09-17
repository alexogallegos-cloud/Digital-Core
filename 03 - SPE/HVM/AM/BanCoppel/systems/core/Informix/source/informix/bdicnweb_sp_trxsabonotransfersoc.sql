CREATE PROCEDURE "informix".sp_trxsabonotransfersoc( pEmpresa CHAR(3) )
RETURNING CHAR(5), CHAR(4), CHAR(80);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cTransacc    CHAR(4);
    DEFINE cDescripcion CHAR(80);
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
    LET cTransacc    = '';
    LET cDescripcion = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_trxsabonotransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cTransacc, cDescripcion;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_trxsabonotransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_trxtrfabonosoc
     WHERE transacc = transacc;
       
    IF iExiste = 0 THEN
        LET cCodRet1 = '999';
        RETURN cCodRet1, cTransacc, cDescripcion;
    END IF;
    
    FOREACH
        SELECT transacc, descripcion
          INTO cTransacc, cDescripcion
          FROM bdicheq:sc_trxtrfabonosoc
         WHERE transacc = transacc
         ORDER BY transacc
         
        RETURN cCodRet1, cTransacc, cDescripcion WITH RESUME;
    
        LET cTransacc = '';
        LET cDescripcion = '';
    END FOREACH

    END;
    
END PROCEDURE;