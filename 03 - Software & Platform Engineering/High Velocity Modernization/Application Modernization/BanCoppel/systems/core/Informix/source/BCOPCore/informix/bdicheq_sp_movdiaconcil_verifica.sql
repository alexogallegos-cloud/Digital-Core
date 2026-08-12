CREATE PROCEDURE "informix".sp_movdiaconcil_verifica()
RETURNING CHAR(5);
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iRegsConcil  INTEGER;
    DEFINE iRegsMovhis  INTEGER;
    
    LET cCodRet     = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr     = 0;
    LET iSamErr     = 0;
    LET cDesErr     = 0;
    LET iRegsConcil = 0;
    LET iRegsMovhis = 0;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_verifica.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_verifica.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
        
    SELECT COUNT(*)
      INTO iRegsConcil
      FROM sc_movdia_concil;
      
    SELECT COUNT(*)
      INTO iRegsMovhis
      FROM sc_movdia mov,
           sc_fechas fecha
     WHERE mov.fech_alt = fecha.fecha_ant;
       
    IF iRegsConcil = iRegsMovhis THEN
        LET cCodRet = '000';
    ELSE
        LET cCodRet = '111';
    END IF;
     
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;