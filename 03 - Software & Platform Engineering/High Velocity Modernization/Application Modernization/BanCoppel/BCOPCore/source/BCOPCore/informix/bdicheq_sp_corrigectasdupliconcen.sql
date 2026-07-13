CREATE PROCEDURE "informix".sp_corrigectasdupliconcen( pEmpresa CHAR(3), pFecha DATE )
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE cCodRet          CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iTransacc        SMALLINT;
    DEFINE iContador1       INTEGER;
    DEFINE iContador2       INTEGER;
    DEFINE dFechaHoy        DATE;
    DEFINE cCtaNostro       CHAR(20);
    DEFINE cProdNostro      CHAR(4);
    DEFINE cSucNostro       CHAR(4);
    DEFINE mSdoNostro       DECIMAL(18,2);
    DEFINE cStatCtaNostro   CHAR(1);   
    DEFINE cHora            CHAR(15);
    DEFINE cFolio           CHAR(16);
    DEFINE cCuenta          CHAR(20);
    DEFINE mMonto           DECIMAL(14,2);
    DEFINE cSucursal        CHAR(4);
    DEFINE cProducto        CHAR(4);
    DEFINE mSdoCuenta       DECIMAL(14,2);
    DEFINE cStatusCta       CHAR(1);
    DEFINE cHoraTrx         CHAR(12);
	DEFINE dFechaOperacion  DATE;
    
    LET cCodRet         = '000';
    LET cCodRet2        = '';
    LET cCodRet3        = '';
    LET iSqlErr         = 0;
    LET iSamErr         = 0;
    LET cDesErr         = 0;
    LET iTransacc       = 0;
    LET iContador1      = 0;
    LET iContador2      = 0;
    LET dFechaHoy       = '';
    LET cCtaNostro      = '';
    LET cProdNostro     = '';
    LET cSucNostro      = '';
    LET mSdoNostro      = 0.00;
    LET cStatCtaNostro  = '';
    LET cHora           = '';
    LET cFolio          = '';
    LET cCuenta         = '';
    LET mMonto          = 0.00;
    LET cSucursal       = '';
    LET cProducto       = '';
    LET mSdoCuenta      = 0.00;
    LET cStatusCta      = '';
    LET cHoraTrx      = '';
	LET dFechaOperacion = TODAY;
    
    

    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigectasdupliconcen.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador1, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigectasdupliconcen.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LA FECHA
    SELECT fecha_hoy
      INTO dFechaHoy
      FROM sc_fechas
     WHERE empresa = pEmpresa;
     
    -- // OBTIENE LA CUENTA CONCENTRADORA PARA TRASPASOS POR INACTIVIDAD
    SELECT valor
      INTO cCtaNostro
      FROM sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'CtaConcentradorArt61';
       
    SELECT producto, sucursal, status_cta
      INTO cProdNostro, cSucNostro, cStatCtaNostro
      FROM sc_maechq 
     WHERE empresa = pEmpresa
       AND cuenta = cCtaNostro;
       
    -- // OBTIENE LAS CUENTAS DUPLICADAS    
    SELECT cuenta, COUNT(*) veces
      FROM sc_movhis
     WHERE fech_alt = pFecha
       AND transacc = '0320'      
       AND cancelad <> 'S'        
     GROUP BY 1
    HAVING COUNT(*) > 1
    INTO TEMP tmp_ctas_dupli WITH NO LOG;
    CREATE INDEX idxtmp_ctasdupli ON tmp_ctas_dupli(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctas_dupli;
    
    SELECT UNIQUE cuenta, monto_tot
      FROM sc_movhis
     WHERE fech_alt = pFecha
       AND transacc = '0320'      
       AND cancelad <> 'S'
       AND cuenta IN(SELECT cuenta FROM tmp_ctas_dupli)
    INTO TEMP tmp_ctasxcorreg WITH NO LOG;
    CREATE INDEX idxtmp_ctascorreg ON tmp_ctasxcorreg(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_ctasxcorreg;
    
    LET cHora = CURRENT HOUR TO FRACTION;
    LET cFolio = 'informix'||cHora[1,2]||cHora[4,5]||cHora[7,8]||cHora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, monto_tot
          INTO cCuenta, mMonto
          FROM tmp_ctasxcorreg
         WHERE cuenta = cuenta
         
        LET iContador1 = iContador1 + 1;
         
        SELECT sucursal, producto, sdo_actual, status_cta
          INTO cSucursal, cProducto, mSdoCuenta, cStatusCta
          FROM sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta = cCuenta;
         
        BEGIN WORK;
        LET iTransacc = 1;
        
        LET cHoraTrx = CURRENT HOUR TO FRACTION(3);
        
        INSERT INTO sc_movdia VALUES
        ( 0, cFolio, '9250' , 'informix', dFechaHoy, dFechaHoy, cHoraTrx, '0242', cSucursal, cProducto, pEmpresa, cCuenta, '', 0, 
          mMonto, mMonto, 0.00, 0.00, 0, '', cStatusCta, mSdoCuenta, '0000' , 'ABONO POR CORRECCION', 0.000000, '', '', '', dFechaOperacion);
          
        UPDATE sc_maechq
           SET sdo_actual     = sdo_actual + mMonto,
               imp_abonos_mes = imp_abonos_mes + mMonto, 
               num_abonos_mes = num_abonos_mes + 1,
               fec_ult_mov    = dFechaHoy
         WHERE empresa = pEmpresa 
           AND cuenta = cCuenta;
           
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            SELECT sdo_actual
              INTO mSdoNostro
              FROM sc_maechq 
             WHERE empresa = pEmpresa
               AND cuenta = cCtaNostro;
               
            LET cHoraTrx = CURRENT HOUR TO FRACTION(3);
            
            INSERT INTO sc_movdia VALUES
            ( 0, cFolio, '9250' , 'informix', dFechaHoy, dFechaHoy, cHoraTrx, '0252', cSucNostro, cProdNostro, pEmpresa, cCtaNostro, '', 0, 
              mMonto, 0.00, 0.00, 0.00, 0, '', cStatCtaNostro, mSdoNostro, '0000' , 'CARGO POR CORRECCION', 0.000000, '', '', '', dFechaOperacion);
              
            UPDATE sc_maechq
               SET sdo_actual   = sdo_actual - mMonto,
                   imp_cgos_mes = imp_cgos_mes + mMonto,
                   num_cgos_mes = num_cgos_mes + 1,
                   fec_ult_mov  = dFechaHoy,
                   fecultret    = dFechaHoy
             WHERE empresa = pEmpresa
               AND cuenta = cCtaNostro; 
               
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                LET iContador2 = iContador2 + 1;
                COMMIT WORK;
                LET iTransacc = 0;
            ELSE
                ROLLBACK WORK;
                LET iTransacc = 0;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET iTransacc = 0;
        END IF;
        
        LET cCuenta = '';
        LET mMonto = 0.00;
        LET cSucursal = '';
        LET cProducto = '';
        LET mSdoCuenta = 0.00;
        LET cStatusCta = '';
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador1, iContador2;
    
END PROCEDURE;