CREATE PROCEDURE "informix".spei_desbloqbandera( pEmpresa CHAR(3) ) 
RETURNING CHAR(5);
    
    DEFINE intSqlErr    INTEGER;
    DEFINE intIsamErr   INTEGER;
    DEFINE chrDescErr   CHAR(80);
    DEFINE chrCodRet1   CHAR(5);
    DEFINE chrCodRet2   CHAR(5);
    DEFINE chrCodRet3   CHAR(80);
    DEFINE intExiste    SMALLINT;
    DEFINE chrBandera   SMALLINT;
    DEFINE chrHorario   CHAR(8);
    DEFINE chrSql       CHAR(300);
    DEFINE intNumSerial INTEGER;
    DEFINE dteHorario   CHAR(8);
    DEFINE vcSleep      VARCHAR(20);

    LET intSqlErr    = 0;
    LET intIsamErr   = 0;
    LET chrDescErr   = '';
    LET chrCodRet1   = '000';
    LET chrCodRet2   = '';
    LET chrCodRet3   = '';
    LET intExiste    = 0;
    LET chrBandera   = 0;
    LET chrHorario   = '';
    LET chrSql       = '';
    LET intNumSerial = 0;
    LET dteHorario   = '';
    LET vcSleep      = '';

    BEGIN
    
    ON EXCEPTION SET intSqlErr, intIsamErr, chrDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_desbloqbandera.err";
        TRACE ON;
        IF intSqlErr <> 0 THEN
            LET chrCodRet1 = intSqlErr;
            LET chrCodRet2 = intIsamErr;
            LET chrCodRet3 = chrDescErr;
            RETURN chrCodRet1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/spei/spei_desbloqbandera.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT TRIM(vchrvalor)
      INTO vcSleep
      FROM tblparametros
     WHERE vchrcveparametro = 'SLEEP_DESBLQ_BANDERA';      
    
    LET chrSql = 'echo "/usr/bin/sleep '||vcSleep||'" > /resplogifx/conciliachq/spei/qry_sleep.sh';
    SYSTEM chrSql;
    
    LET chrSql = 'sh /resplogifx/conciliachq/spei/qry_sleep.sh';
    SYSTEM chrSql;
    
    UPDATE tblparametros
       SET vchrvalor = '0'
     WHERE vchrcveparametro IN('FOLIO_OPCAJERO','FOLIO_BITACORA','FOLIO_PAGO','FOLIO_DEVOLUCION','BLOQUEO_A_USUARIOS');
    
    RETURN chrCodRet1;
    
    END;
    
END PROCEDURE;