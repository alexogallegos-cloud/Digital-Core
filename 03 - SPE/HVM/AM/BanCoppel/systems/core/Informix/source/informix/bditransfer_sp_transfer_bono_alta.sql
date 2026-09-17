CREATE PROCEDURE "informix".sp_transfer_bono_alta( pEmpresa CHAR(3) )
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE vActivo      CHAR(8);
    DEFINE vFechaHoy    DATE;
    DEFINE vFechaAnt    DATE;
    DEFINE vMonto       MONEY(14,2);
    DEFINE vHora        CHAR(15);
    DEFINE vFolio       CHAR(16);
    DEFINE vCuenta      CHAR(20);
    DEFINE vFechaAlta   DATE;
    DEFINE cCodRetAbono CHAR(5);
    
    LET cCodRet      = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr      = 0;
    LET iSamErr      = 0;
    LET cDesErr      = 0;
    LET vActivo      = '0';
    LET vFechaHoy    = '';
    LET vFechaAnt    = '';
    LET vMonto       = 0.00;
    LET vHora        = '';
    LET vFolio       = '';
    LET vCuenta      = '';
    LET vFechaAlta   = '';
    LET cCodRetAbono = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_bono_alta.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT valor
      INTO vActivo
      FROM bdicheq:sc_param
     WHERE empresa = pEmpresa
       AND codparam = 'VigBonoAltaTransfer';
       
    IF vActivo = '1' THEN
        SELECT fecha_hoy, fecha_ant
          INTO vFechaHoy, vFechaAnt
          FROM bdicheq:sc_fechas
         WHERE empresa = pEmpresa;
        
        SELECT valor
          INTO vMonto
          FROM bdicheq:sc_param
         WHERE empresa = pEmpresa
           AND codparam = 'MtoBonoAltaTransfer';
         
        LET vHora = CURRENT HOUR TO FRACTION;
        LET vFolio = 'informix'||vHora[1,2]||vHora[4,5]||vHora[7,8]||vHora[10,11];
         
        FOREACH WITH HOLD
            SELECT cuenta_tf, fec_alta
              INTO vCuenta, vFechaAlta
              FROM tf_maecte
             WHERE status_cta = '1'
               AND fec_alta = vFechaAnt
            
            EXECUTE PROCEDURE bdicheq:abono_ref(pEmpresa,'9250','informix','0327','0000',vFolio,vCuenta,0,vMonto,vMonto,0,0,0,'01','BONO DE BIENVENIDA TRANSFER','','')
            INTO cCodRetAbono;
            
            IF cCodRetAbono = '000' THEN
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO APLICADO' );
            ELSE
                INSERT INTO tf_bonos_transfer VALUES( vFechaHoy, 'BONO DE BIENVENIDA', vCuenta, vFechaAlta, vMonto, cCodRetAbono, 'BONO NO APLICADO' );
            END IF;
        END FOREACH;
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;