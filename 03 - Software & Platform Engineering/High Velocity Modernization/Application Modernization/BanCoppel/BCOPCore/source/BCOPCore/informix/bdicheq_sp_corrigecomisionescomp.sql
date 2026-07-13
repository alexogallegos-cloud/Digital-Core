CREATE PROCEDURE "informix".sp_corrigecomisionescomp( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador        INTEGER;
    DEFINE cCuenta          CHAR(20);
    DEFINE cFolioSuc        CHAR(16);
    DEFINE mMontoCom        DECIMAL(14,2);
    DEFINE cCodRetAbo       CHAR(5);
    DEFINE iExisteIva       SMALLINT;
    DEFINE iSerialIva       INTEGER;
    DEFINE mMontoIva        DECIMAL(14,2);
    DEFINE iExisComPend     SMALLINT;
    DEFINE mMontoComPend    DECIMAL(14,2);
    DEFINE cHora            CHAR(15);
    DEFINE cFolio           CHAR(16);
    
    LET cCodRet       = '000';
    LET cCodRet2      = '';
    LET cCodRet3      = '';
    LET iSqlErr       = 0;
    LET iSamErr       = 0;
    LET cDesErr       = 0;
    LET iTransacc     = 0;
    LET iContador     = 0;    
    LET cCuenta       = '';
    LET cFolioSuc     = '';
    LET mMontoCom     = 0.00;
    LET cCodRetAbo    = '';
    LET iExisteIva    = 0;
    LET mMontoIva     = 0.00;
    LET iExisComPend  = 0;
    LET mMontoComPend = 0.00;
    LET cHora         = '';
    LET cFolio        = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisionescomp.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigecomisionescomp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE CUENTAS COBRO DE COMISION 3290
    SELECT UNIQUE cuenta 
      FROM sc_movhis  
     WHERE fech_alt = '06/01/2015' 
       AND transacc = '3290'
       AND cancelad <> 'S'
      INTO TEMP ctaspmxcobmal WITH NO LOG;
    CREATE INDEX idxtmp_comcobmal ON ctaspmxcobmal(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE ctaspmxcobmal;
    
    -- // GENERA FOLIO PARA TRANSACCIONES DE ABONO
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    FOREACH WITH HOLD
        SELECT mae.cuenta
          INTO cCuenta
          FROM ctaspmxcobmal tmp, 
               sc_maehis mae
         WHERE mae.empresa = pEmpresa
           AND mae.cuenta = tmp.cuenta
           AND mae.fechaini = '05/01/2015'
           AND mae.fechafin = '05/31/2015'
           AND mae.dia_sdo_pos > 0
           AND ( mae.acum_sdo_pos / mae.dia_sdo_pos ) >= 2000.00
        
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // BONIFICA COBRO DE COMISION
        FOREACH WITH HOLD
            SELECT folio_suc, monto_tot
              INTO cFolioSuc, mMontoCom
              FROM sc_movhis
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt >= '06/01/2015'
               AND cancelad <> 'S'
               AND transacc = '3290'
            UNION ALL
            SELECT folio_suc, monto_tot
              FROM sc_movdia
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND fech_alt = today 
               AND cancelad <> 'S'
               AND transacc = '3290'
           
            CALL abono_ref( pEmpresa, '9250', 'informix', '0263', '0000', cFolio, cCuenta, 0, mMontoCom, mMontoCom, 0, 0, 0, '01', 'BONIFICACION COMISION POR BAJO PROMEDIO', '', '' )
            RETURNING cCodRetAbo;
        
            -- // VERIFICA SI COBRO IVA DE LA COMISION PARA BONIFICARLO
            SELECT COUNT(*), SUM(monto_tot)
              INTO iExisteIva, mMontoIva
              FROM sc_movhis
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND folio_suc = cFolioSuc
               AND transacc = '0260'
               AND cancelad <> 'S';
               
            IF iExisteIva = 0 THEN
                SELECT COUNT(*), SUM(monto_tot)
                  INTO iExisteIva, mMontoIva
                  FROM sc_movdia
                 WHERE empresa = pEmpresa
                   AND cuenta = cCuenta
                   AND folio_suc = cFolioSuc
                   AND transacc = '0260'
                   AND cancelad <> 'S';
            END IF;
                       
            IF iExisteIva > 0 THEN
                CALL abono_ref( pEmpresa, '9250', 'informix', '0263', '0000', cFolio, cCuenta, 0, mMontoIva, mMontoIva, 0, 0, 0, '01', 'BONIFICACION IVA COMISION', '', '' )
                RETURNING cCodRetAbo;
            END IF;
            
            LET cFolioSuc     = '';
            LET mMontoCom     = 0.00;
            LET iExisteIva    = 0;
            LET mMontoIva     = 0.00;
            LET cCodRetAbo    = '';
        END FOREACH;
        
        -- // VERIFICA SI EL COBRO DE COMISION DEJO COMISION PENDIENTE
        SELECT COUNT(*), SUM(monto_com)
          INTO iExisComPend, mMontoComPend
          FROM sc_detcomis
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta
           AND comision = '3290'
           AND fecha_alta >= '06/01/2015'
           AND estado_com = 'P';
               
        IF iExisComPend > 0 THEN
            -- // ELIMINA REGISTROS DE COMISION PENDIENTE
            DELETE FROM sc_detcomis
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta
               AND comision = '3290'
               AND fecha_alta >= '06/01/2015'
               AND estado_com = 'P';
               
            -- // ACTUALIZA LA COMISION PENDIENTE EN EL MAESTRO DE CHEQUES
            UPDATE sc_maechq 
               SET com_pendiente = com_pendiente - mMontoComPend
             WHERE empresa = pEmpresa
               AND cuenta = cCuenta;
        END IF;
        
        LET iContador = iContador + 1;
        
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET cCuenta = '';
        LET iExisComPend = 0;
        LET mMontoComPend = 0.00;
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador; 
    
END PROCEDURE;