CREATE PROCEDURE "informix".sp_corrije_ints_sdos_diarios_comp( pEmpresa CHAR(3), pFecha DATE ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cDescErr             CHAR(50);
    DEFINE cCodRet1             CHAR(5);
    DEFINE cCodRet2             CHAR(5);
    DEFINE cCodRet3             CHAR(50);
    DEFINE iContador1           INTEGER;
    DEFINE iContador2           INTEGER;
    DEFINE iContador3           INTEGER;
    DEFINE iComienza            SMALLINT;
    DEFINE iAbierto             SMALLINT;
    DEFINE cAnioMes             CHAR(6);
    DEFINE cCuenta              CHAR(20);
    DEFINE mIntProvision        DECIMAL(14,2);
    DEFINE mIntDesprovision     DECIMAL(14,2);
    DEFINE mIntProvisionados    DECIMAL(14,2);
    DEFINE mIntPagados          DECIMAL(14,2);
    DEFINE mIntProvNoPag        DECIMAL(14,2);
    
    LET iSqlErr	          = 0;
    LET iIsamErr          = 0;
    LET cDescErr          = '';
    LET cCodRet1          = '000';
    LET cCodRet2          = '';
    LET cCodRet3          = '';   
    LET iContador1        = 0;
    LET iContador2        = 0;
    LET iContador3        = 0;
    LET iComienza         = -1;
    LET iAbierto          = 0;
    LET cAnioMes          = '';
    LET cCuenta           = '';
    LET mIntProvision     = 0.00;
    LET mIntDesprovision  = 0.00;
    LET mIntProvisionados = 0.00;
    LET mIntPagados       = 0.00;
    LET mIntProvNoPag     = 0.00;
    
    BEGIN

    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios_comp.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrije_ints_sdos_diarios_comp.out";
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
           AND transacc IN('3381','3382','3276')
        
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iAbierto = 1;
        END IF;
        
        LET iContador1 = iContador1 + 1;
        
        SELECT SUM(monto_tot)
          INTO mIntProvision
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND fech_alt = pFecha
           AND transacc = '3381';
           
        IF mIntProvision is null THEN
            LET mIntProvision = 0.00;
        END IF;
           
        SELECT SUM(monto_tot)
          INTO mIntDesprovision
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND fech_alt = pFecha
           AND transacc = '3382';
           
        IF mIntDesprovision is null THEN
            LET mIntDesprovision = 0.00;
        END IF;
        
        LET mIntProvisionados = mIntProvision - mIntDesprovision;
           
        SELECT SUM(monto_tot)
          INTO mIntPagados
          FROM sc_movhis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND fech_alt = pFecha
           AND transacc = '3276';
           
        IF mIntPagados is null THEN
            LET mIntPagados = 0.00;
            LET mIntProvNoPag = mIntProvisionados;
        ELSE
            LET mIntProvNoPag = 0.00;
        END IF;
        
        UPDATE sc_sdodiarioc
           SET intprovnp31 = mIntProvNoPag
         WHERE cuenta = cCuenta
           AND aniomes = cAnioMes;
        
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET iContador2 = iContador2 + 1;
        END IF;
        
        LET iContador3 = iContador3 + 1;
        
        IF iContador3 >= 1000 THEN
            LET iContador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cCuenta           = '';
        LET mIntProvision     = 0.00;
        LET mIntDesprovision  = 0.00;
        LET mIntProvisionados = 0.00;
        LET mIntPagados       = 0.00;
        LET mIntProvNoPag     = 0.00;
    END FOREACH;
    
    IF iAbierto = 1 THEN
        LET iAbierto = 0;
        COMMIT WORK;
    END IF;
    
    END; 
    
    RETURN cCodRet1, iContador1, iContador2;
    
END PROCEDURE;