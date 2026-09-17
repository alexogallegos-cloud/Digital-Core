CREATE PROCEDURE "informix".sp_movdiaconcil_descarga()
RETURNING CHAR(5);
          
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE cSql         CHAR(300);
    
    LET cCodRet  = '000';
    LET cCodRet2 = '';
    LET cCodRet3 = '';
    LET iSqlErr  = 0;
    LET iSamErr  = 0;
    LET cDesErr  = 0;
    LET cSql     = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_descarga.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_movdiaconcil_descarga.out";
    --- TRACE ON;
        
    LET cSql = '';
    LET cSql = 'echo "SET ISOLATION TO DIRTY READ; UNLOAD TO /resplogifx/conciliachq/movdia_concil.unl '||
               'SELECT mov.* FROM sc_movdia mov, sc_fechas fecha WHERE mov.fech_alt = fecha.fecha_ant;" > /resplogifx/conciliachq/movdiaconcil.sql';
    SYSTEM cSql;
    
    LET cSql = '';
    LET cSql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/movdiaconcil.sql'; 
    SYSTEM cSql;
    
    LET cSql = '';
    LET cSql = 'ls -l /resplogifx/conciliachq/movdia_concil.unl'; 
    SYSTEM cSql;
     
    END;
    
    RETURN cCodRet;
    
END PROCEDURE;