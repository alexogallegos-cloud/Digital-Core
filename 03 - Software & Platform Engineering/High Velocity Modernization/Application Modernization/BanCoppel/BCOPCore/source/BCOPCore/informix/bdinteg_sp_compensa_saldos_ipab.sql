CREATE PROCEDURE "informix".sp_compensa_saldos_ipab() 
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
    DEFINE cSql CHAR(200);
    DEFINE cNumCliente CHAR(20);
    DEFINE dSdoCheques DECIMAL(14,2);
    DEFINE dSdoCredito DECIMAL(14,2);
    DEFINE dSaldoCompensado DECIMAL(15,2);
    DEFINE iCausalRev SMALLINT;
    DEFINE mValorUDIS DECIMAL(14,2);
    
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
    LET cSql = '';
    LET cNumCliente = '';
    LET dSdoCheques = 0; 
    LET dSdoCredito = 0;
    LET dSaldoCompensado = 0;
    LET iCausalRev = 0;
    LET mValorUDIS = 7.426776 * 400000;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_compensa_saldos_ipab.err';
        TRACE ON;
        LET cCodRet  = iSqlErr;
        LET cCodRet2 = iSamErr;
        LET cCodRet3 = cDesErr;
        LET cNumCliente = cNumCliente;
        IF iComit = 1 THEN
            ROLLBACK WORK;
        END IF;
        RETURN cCodRet, cCodRet2, cCodRet3;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO '/resplogifx/conciliachq/ipab/sp_compensa_saldos_ipab.out';
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // FOREACH CLIENTES
    FOREACH WITH HOLD
        SELECT UNIQUE per.cve_unica, per.causal_rev
          INTO cNumCliente, iCausalRev
          FROM si_infpertit_ipab per,
               si_crdasotit_ipab crd,
               si_infcrdtit_ipab inf
         WHERE per.cve_unica = crd.cve_unica
		   AND crd.num_credito = inf.num_credito
         
        IF iComienza = -1 THEN
            LET iComienza = 0;
            BEGIN WORK;
            LET iComit = 1;
        END IF;
        
        IF iCausalRev = 0 THEN
            SELECT SUM(chq.sdo_neto)
              INTO dSdoCheques
              FROM si_infpattit_ipab chq,
                   si_ctaasotit_ipab cta
             WHERE chq.numcta = cta.numcta
               AND chq.num_inversion = cta.num_inversion
               AND cta.cve_unica = cNumCliente;
               
            IF dSdoCheques is null THEN
                LET dSdoCheques = 0;
            END IF;
            
            IF dSdoCheques > mValorUDIS THEN
                LET dSdoCheques = mValorUDIS;
            END IF;
        
            SELECT SUM(crd.cap_vencido + crd.ints_ord_exig + crd.ints_moratorios + crd.otros_accesorio)
              INTO dSdoCredito
              FROM si_infcrdtit_ipab crd,
                   si_crdasotit_ipab cta
             WHERE crd.num_credito = cta.num_credito
               AND cta.cve_unica = cNumCliente;
               
            IF dSdoCredito is null THEN
                LET dSdoCredito = 0;
            END IF;
            
            LET dSaldoCompensado = dSdoCheques - dSdoCredito;
            
            IF dSaldoCompensado < 0 THEN
                LET dSaldoCompensado = 0.00;
            END IF;
        ELSE
            LET dSaldoCompensado = 0.00;
        END IF;
        
        UPDATE si_infpertit_ipab
           SET sdo_compensado = dSaldoCompensado
         WHERE cve_unica = cNumCliente;
        
        LET iContador1 = iContador1 + 1;
        LET iContador2 = iContador2 + 1;
        
        IF iContador2 >= 1000 THEN
            LET iContador2 = 0;
            LET cSql = 'echo "REGISTROS PROCESADOS COMPENSACION SALDOS: '||iContador1||'" > /resplogifx/conciliachq/ipab/regsproc_compsdos.txt';
            SYSTEM cSql;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET cNumCliente = '';
        LET dSdoCheques = 0;
        LET dSdoCredito = 0;
        LET dSaldoCompensado = 0;
        LET iCausalRev = 0;
    END FOREACH; 

    IF iComit = 1 THEN
        COMMIT WORK;
        LET iComit = 0;
    END IF;
    
    END;
    
    RETURN cCodRet, cCodRet2, cCodRet3;
    
END PROCEDURE;