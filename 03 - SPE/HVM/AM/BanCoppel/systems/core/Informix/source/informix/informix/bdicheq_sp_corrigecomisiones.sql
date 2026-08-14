CREATE PROCEDURE "informix".sp_corrigecomisiones( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador        INTEGER;
    DEFINE iSerialCom       INTEGER;
    DEFINE cCuenta          CHAR(20);
    DEFINE cFolioSuc        CHAR(16);
    DEFINE mMontoCom        DECIMAL(14,2);
    DEFINE cCodRetAbo       CHAR(5);
    DEFINE iExisteIva       SMALLINT;
    DEFINE iSerialIva       INTEGER;
    DEFINE mMontoIva        DECIMAL(14,2);
    DEFINE iExisComPend     SMALLINT;
    DEFINE mMontoComPend    DECIMAL(14,2);
    
    LET cCodRet       = '000';
    LET cCodRet2      = '';
    LET cCodRet3      = '';
    LET iSqlErr       = 0;
    LET iSamErr       = 0;
    LET cDesErr       = 0;
    LET iTransacc     = 0;
    LET iContador     = 0;    
    LET iSerialCom    = 0;
    LET cCuenta       = '';
    LET cFolioSuc     = '';
    LET mMontoCom     = 0.00;
    LET cCodRetAbo    = '';
    LET iExisteIva    = 0;
    LET iSerialIva    = 0;
    LET mMontoIva     = 0.00;
    LET iExisComPend  = 0;
    LET mMontoComPend = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisiones.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisiones.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
        
    FOREACH WITH HOLD
        SELECT num_serial, cuenta, folio_suc, monto_tot
          INTO iSerialCom, cCuenta, cFolioSuc, mMontoCom
          FROM sc_movdia
         WHERE transacc = '3290'
           AND cancelad <> 'S'
           AND producto IN('9900','9901','2600','2700','2800','8000')
           
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // CANCELA TRANSACCION DE COMISION
        UPDATE sc_movdia 
           SET cancelad = 'S'
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND num_serial = iSerialCom;
        
        -- // ACTUALIZA EL SALDO DE LA CUENTA
        UPDATE sc_maechq
           SET sdo_actual = sdo_actual + mMontoCom
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
            
        -- // VERIFICA SI COBRO IVA DE LA COMISION
        SELECT COUNT(*)
          INTO iExisteIva
          FROM sc_movdia
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND folio_suc = cFolioSuc
           AND transacc = '0260'
           AND cancelad <> 'S';
                   
        IF iExisteIva > 0 THEN
            SELECT num_serial, monto_tot
              INTO iSerialIva, mMontoIva
              FROM sc_movdia
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND folio_suc = cFolioSuc
               AND transacc = '0260'
               AND cancelad <> 'S';
               
            -- // CANCELA TRANSACCION DE IVA
            UPDATE sc_movdia 
               SET cancelad = 'S'
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND num_serial = iSerialIva;
               
            -- // ACTUALIZA EL SALDO DE LA CUENTA
            UPDATE sc_maechq
               SET sdo_actual = sdo_actual + mMontoIva
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta;
        END IF;
        
        -- // VERIFICA SI EL COBRO DE COMISION DEJO COMISION PENDIENTE
        SELECT COUNT(*), SUM(monto_com)
          INTO iExisComPend, mMontoComPend
          FROM sc_detcomis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND folio_suc = cFolioSuc
           AND comision = '3290'
           AND fecha_alta = today
           AND estado_com = 'P';
                   
        IF iExisComPend > 0 THEN
            -- // ELIMINA RGISTROS DE COMISION PENDIENTE
            DELETE FROM sc_detcomis
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND folio_suc = cFolioSuc
               AND comision = '3290'
               AND fecha_alta = today
               AND estado_com = 'P';
               
            -- // ACTUALIZA EL SALDO DE LA CUENTA Y LA COMISION PENDIENTE
            UPDATE sc_maechq 
               SET sdo_actual = sdo_actual + mMontoComPend,
                   com_pendiente = com_pendiente - mMontoComPend
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta;
        END IF;
        
        LET iContador = iContador + 1;
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET iSerialCom    = 0;
        LET cCuenta       = '';
        LET cFolioSuc     = '';
        LET mMontoCom     = 0.00;
        LET cCodRetAbo    = '';
        LET iExisteIva    = 0;
        LET iSerialIva    = 0;
        LET mMontoIva     = 0.00;
        LET iExisComPend  = 0;
        LET mMontoComPend = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador; 
    
END PROCEDURE;