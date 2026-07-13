CREATE PROCEDURE "informix".sp_ipab_actualiza_saldos() 
RETURNING CHAR(5), CHAR(5), CHAR(50);
    
    DEFINE cCodRet CHAR(5);
    DEFINE cCodRet2 CHAR(5);
    DEFINE cCodRet3 CHAR(60);
    DEFINE iSqlErr INTEGER;
    DEFINE iSamErr INTEGER;
    DEFINE cDesErr CHAR(60);
    DEFINE iContador1 INTEGER;
    DEFINE iContador2 INTEGER;
    DEFINE iComienza SMALLINT;
    DEFINE iComit SMALLINT;
    DEFINE cStmt CHAR(200);
    DEFINE cSql CHAR(600);
    DEFINE cNumCuenta CHAR(20);
    DEFINE mSdoCuenta DECIMAL(15,2);
    DEFINE mIntereses DECIMAL(15,2);
    DEFINE mISR DECIMAL (15,2);
    DEFINE mSdoNeto DECIMAL(15,2);
    DEFINE cNumCte CHAR(20);
    
    LET cCodRet = '000'; 
    LET cCodRet2 = '000'; 
    LET cCodRet3 = 'PROCESO FINALIZADO CORRECTAMENTE'; 
    LET iSqlErr = 0; 
    LET iSamErr = 0; 
    LET cDesErr = ''; 
    LET iContador1 = 0; 
    LET iContador2 = 0;
    LET iComienza = -1;
    LET iComit = 0; 
    LET cStmt = '';
    LET cSql = '';
    LET cNumCuenta = '';
    LET mSdoCuenta = 0;
    LET mIntereses = 0;
    LET mISR = 0;
    LET mSdoNeto = 0;
    LET cNumCte = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_actualiza_saldos.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        LET cNumCuenta = cNumCuenta;
        IF iComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodRet, cCodRet2, cCodRet3;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_ipab_actualiza_saldos.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT cta.cve_unica, pat.numcta, pat.sdo_cuenta, pat.intereses, pat.ret_impuestos
          INTO cNumCte, cNumCuenta, mSdoCuenta, mIntereses, mISR
          FROM si_infpattit_ipab pat,
               si_ctaasotit_ipab cta,
               si_infpertit_ipab per
         WHERE pat.numcta = cta.numcta
           AND pat.num_inversion = cta.num_inversion
           AND pat.num_inversion = '0'
           AND per.cve_unica = cta.cve_unica
         
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iComit = 1;
        END IF;
        
        LET mSdoNeto = ((mSdoCuenta + mIntereses) - mISR);
        
        UPDATE si_infpattit_ipab
           SET sdo_neto = mSdoNeto
         WHERE numcta = cNumCuenta
           AND num_inversion = '0';
           
        UPDATE si_infpertit_ipab
           SET sdo_compensado = mSdoNeto
         WHERE cve_unica = cNumCte;
         
        INSERT INTO si_ctrlctas_ipab VALUES
        (cNumCte, cNumCuenta);
        
        LET iContador1 = iContador1 + 1;
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 1000 THEN
            LET iContador2 = 0;
            LET cSql = 'echo "REGISTROS PROCESADOS: '||iContador1||'" > /resplogifx/conciliachq/ipab/regs_procesados_sdos.txt';
            SYSTEM cSql;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCuenta = '';
        LET mSdoCuenta = 0;
        LET mIntereses = 0;
        LET mISR = 0;
        LET mSdoNeto = 0;
        LET cNumCte = '';
    END FOREACH; 

    IF iComit = 1 THEN
        COMMIT WORK;
        LET iComit = 0;
    END IF;
    
    END;
    
    RETURN cCodRet, cCodRet2, cCodRet3;
    
END PROCEDURE;