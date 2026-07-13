CREATE PROCEDURE "informix".sp_corrije_ints_sdos_diarios( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE iSqlErr          INTEGER;
    DEFINE iIsamErr         INTEGER;
    DEFINE cDescErr         CHAR(50);
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE iComienza        SMALLINT;
    DEFINE iAbierto         SMALLINT;
    DEFINE cAnioMes         CHAR(6);
    DEFINE cCuenta          CHAR(20);
    DEFINE mIntProvNoPag    DECIMAL(14,2);
    
    LET iSqlErr	      = 0;
    LET iIsamErr      = 0;
    LET cDescErr      = '';
    LET cCodRet1      = '000';
    LET cCodRet2      = '';
    LET cCodRet3      = '';   
    LET iContador1    = 0;
    LET iContador2    = 0;
    LET iComienza     = -1;
    LET iAbierto      = 0;
    LET cAnioMes      = '';
    LET cCuenta       = '';
    LET mIntProvNoPag = 0.00;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iAbierto = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    LET cAnioMes = YEAR(pFecha)||LPAD(MONTH(pFecha),2,'0');
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO cCuenta
          FROM sc_movhis 
         WHERE empresa = pEmpresa
           AND cuenta >= '10000005016'
           AND fech_alt = pFecha
           AND cancelad <> 'S'
           AND transacc IN('3381')
           AND transacc NOT IN('3276')
        
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iAbierto = 1;
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        SELECT SUM(monto_tot)
          INTO mIntProvNoPag
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND fech_alt = pFecha
           AND transacc = '3381';
        
        UPDATE sc_sdodiarioc
           SET intprovnp31 = mIntProvNoPag
         WHERE cuenta = cCuenta
           AND aniomes = cAnioMes;
        
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 1000 THEN
            LET iContador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cCuenta = '';
        LET mIntProvNoPag = 0.00;
    END FOREACH;
    
    IF iAbierto = 1 THEN
        LET iAbierto = 0;
        COMMIT WORK;
    END IF;
    
    END; 
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE;