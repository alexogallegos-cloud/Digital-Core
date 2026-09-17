CREATE PROCEDURE "informix".sp_verificabonospei( pEmpresa CHAR(3), pTransacc CHAR(4) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador1   INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE iSerial      INTEGER;
    DEFINE cCuenta      CHAR(20);
    DEFINE cFolio       CHAR(16);
    DEFINE cSucursal    CHAR(4);
    DEFINE cUsuario     CHAR(8);
    DEFINE dFechaAlt    DATE;
    DEFINE dFechaVal    DATE;
    DEFINE cTransacc    CHAR(4);
    DEFINE cSucCta      CHAR(4);
    DEFINE cProducto    CHAR(4);
    DEFINE mMonto       MONEY(14,2);
    DEFINE cStatus      CHAR(1);
    DEFINE mSdoCta      MONEY(14,2);
    DEFINE cReferencia  CHAR(40);
    DEFINE cTarjeta     CHAR(16);
    DEFINE cAutoriza    CHAR(8);
	DEFINE dFechaOperacion DATE;
    
    LET cCodRet1    = '';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iTransacc   = 0;
    LET iContador1   = 0;
    LET iContador2   = 0;
    LET iSerial     = 0;
    LET cCuenta     = '';
    LET cFolio      = '';
    LET cSucursal   = '';
    LET cUsuario    = '';
    LET dFechaAlt   = '';
    LET dFechaVal   = '';
    LET cTransacc   = '';
    LET cSucCta     = '';
    LET cProducto   = '';
    LET mMonto      = 0.00;
    LET cStatus     = '';
    LET mSdoCta     = 0.00;
    LET cReferencia = '';
    LET cTarjeta    = '';
    LET cAutoriza   = '';
	LET dFechaOperacion = TODAY;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_verificabonospei.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_verificabonospei.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT {+INDEX(sc_movdia idx_movdiamspei)}
           referencia, cuenta, monto_tot, fech_val, transacc, COUNT(*) veces
      FROM sc_movdia
     WHERE transacc IN('0273','0276','0277')
       AND fech_val = fech_val
       AND cancelad <> 'S'
       AND referencia = referencia
     GROUP BY 1, 2, 3, 4, 5
    HAVING COUNT(*) > 1
    INTO TEMP tmp_dupls WITH NO LOG;
    CREATE INDEX idxtmp_dupls ON tmp_dupls(cuenta, transacc, fech_val, monto_tot, referencia) ONLINE;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_dupls;
    
    FOREACH WITH HOLD
        SELECT FIRST 1 
               mov.num_serial, mov.cuenta, mov.folio_suc, mov.sucursal, mov.usuario, mov.fech_alt, mov.fech_val, mov.transacc, 
               mov.suc_cuen, mov.producto, mov.monto_tot, mov.edo_cta, mov.sdo_cuenta, mov.referencia, mov.num_tarjeta, mov.usuautoriza
          INTO iSerial, cCuenta, cFolio, cSucursal, cUsuario, dFechaAlt, dFechaVal, cTransacc, 
               cSucCta, cProducto, mMonto, cStatus, mSdoCta, cReferencia, cTarjeta, cAutoriza
          FROM sc_movdia mov,
               tmp_dupls tmp
         WHERE mov.cuenta = tmp.cuenta
           AND mov.transacc = tmp.transacc
		   AND mov.fech_val = tmp.fech_val
		   AND mov.monto_tot = tmp.monto_tot
		   AND mov.referencia = tmp.referencia
           AND mov.cancelad <> 'S'
    
        BEGIN WORK;
        LET iTransacc = 1;
        LET iContador1 = iContador1 + 1;
        
        INSERT INTO sc_movdia VALUES
        ( 0, cFolio, cSucursal, cUsuario, dFechaAlt, dFechaVal, CURRENT, cTransacc, cSucCta, cProducto, pEmpresa, cCuenta, '',
          0, mMonto * -1, 0.00, 0.00, 0.00, 0, 'S', cStatus, mSdoCta, '0000', cReferencia, 0.000000, cTarjeta, cAutoriza, '', dFechaOperacion);
          
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            UPDATE sc_maechq
               SET sdo_actual     = sdo_actual - mMonto,
                   imp_abonos_mes = imp_abonos_mes - mMonto,
                   num_abonos_mes = num_abonos_mes - 1
             WHERE cuenta = cCuenta;
               
            IF dbinfo('sqlca.sqlerrd2') > 0 THEN
                UPDATE sc_movdia
                   SET cancelad = 'S'
                 WHERE num_serial = iSerial;
                 
                LET iContador2 = iContador2 + 1;
            ELSE
                ROLLBACK WORK;
            END IF;
        ELSE
            ROLLBACK WORK;
        END IF;
        
        COMMIT WORK;
        
        LET iTransacc = 0;
        
        LET iSerial     = 0;
        LET cCuenta     = '';
        LET cFolio      = '';
        LET cSucursal   = '';
        LET cUsuario    = '';
        LET dFechaAlt   = '';
        LET dFechaVal   = '';
        LET cTransacc   = '';
        LET cSucCta     = '';
        LET cProducto   = '';
        LET mMonto      = 0.00;
        LET cStatus     = '';
        LET mSdoCta     = 0.00;
        LET cReferencia = '';
        LET cTarjeta    = '';
        LET cAutoriza   = '';
    END FOREACH;
    
    LET cCodRet1 = '000';
    LET cCodRet2 = '000';
    LET cCodRet3 = 'PROCESO REALIZADO CORRECTAMENTE';
    
    END;
    
    RETURN cCodRet1, cCodRet2, cCodRet3, iContador1, iContador2;
    
END PROCEDURE;