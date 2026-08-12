CREATE PROCEDURE "informix".colaborapp_dep( pIdTrxGlobal    VARCHAR(23),
                                            pSistemaOrigen  VARCHAR(9),
                                            pNumEmpCoppel   CHAR(9),
                                            pSucursal       CHAR(4),
                                            pTransacc       CHAR(4),
                                            pMoneda         CHAR(3),
                                            pFecha          DATE,
                                            pFolio          CHAR(16),
                                            pCuenta         VARCHAR(13),
                                            pMonto          DECIMAL(13,2),
                                            pTipoOperacion  CHAR(2) )
RETURNING CHAR(5), CHAR(9), DATE, DATE, CHAR(16);
    
    DEFINE iSqlError    INTEGER;
    DEFINE iSamError    INTEGER;
    DEFINE cDesError    CHAR(50);
    DEFINE cSqlErr      CHAR(5);
    DEFINE cIsamErr     CHAR(5);
    DEFINE cDescErr     CHAR(50);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cMoneda      CHAR(2);
    DEFINE cCuenta      CHAR(20);
    DEFINE cCuentaCgo   CHAR(20);
    DEFINE cTransacCgo  CHAR(4);
    DEFINE cCodRetCgo   CHAR(5);
    DEFINE cTranRetCgo  CHAR(4);
    DEFINE dtFechaCgo   DATE;
    DEFINE mSdoDispCgo  MONEY(14,2);
    DEFINE mMtoRetCgo   MONEY(14,2);
    DEFINE cCodRetDep   CHAR(5);
    DEFINE dtFechaOpera DATE;
    DEFINE dtFechaAplic DATE;
    
    LET iSqlError    = 0;
    LET iSamError    = 0;
    LET cDesError    = '';
    LET cSqlErr      = '';
    LET cIsamErr     = '';
    LET cDescErr     = '';
    
    LET cCodRet      = '';
    LET cMoneda      = '';
    LET cCuenta      = '';
    LET cCuentaCgo   = '';
    LET cTransacCgo  = '';
    LET cCodRetCgo   = '';
    LET cTranRetCgo  = '';
    LET dtFechaCgo   = '';
    LET mSdoDispCgo  = 0.00;
    LET mMtoRetCgo   = 0.00;
    LET cCodRetDep   = '';
    LET dtFechaOpera = '';
    LET dtFechaAplic = '';
    
    BEGIN

    ON EXCEPTION SET iSqlError, iSamError, cDesError
        SET DEBUG FILE TO "/resplogifx/conciliachq/colaborapp_dep.err";
        TRACE ON;
        IF iSqlError <> 0 THEN
            LET cSqlErr  = iSqlError;
            LET cIsamErr = iSamError;
            LET cDescErr = cDesError;
            LET cCodRet  = '00999';
            RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/colaborapp_dep.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pIdTrxGlobal is null OR pIdTrxGlobal = '' ) OR
         ( pSistemaOrigen is null OR pSistemaOrigen = '' ) OR
         ( pNumEmpCoppel is null OR pNumEmpCoppel = '' ) OR
         ( pSucursal is null OR pSucursal = '' ) OR
         ( pTransacc is null OR pTransacc = '' ) OR
         ( pMoneda is null OR pMoneda = '' ) OR
         ( pFecha is null OR pFecha = '' ) OR
         ( pFolio is null OR pFolio = '' ) OR
         ( pCuenta is null OR pCuenta = '' ) OR
         ( pMonto is null OR pMonto <= 0.00 ) OR
         ( pTipoOperacion is null OR pTipoOperacion = '' ) ) THEN
        LET cCodRet = '00110';
        RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
    END IF;
    
    IF pMoneda = '484' THEN
        LET cMoneda = '01';
    ELSE
        LET cCodRet = '00951';
        RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
    END IF;
    
    IF pTransacc NOT IN('0539','0540') THEN
        LET cCodRet = '00550';
        RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
    END IF;
	
	SELECT {+INDEX(intercard:ctas_nomina_empleado idx_ctas_nomina_empleado_num_empleado)}
		   cuenta
      INTO cCuenta
      FROM intercard:ctas_nomina_empleado
     WHERE num_empleado = pNumEmpCoppel
       AND SUBSTR(cuenta,LENGTH(cuenta)-3,4) = pCuenta;
     
    IF ( cCuenta is null OR cCuenta = '' OR cCuenta = ' ' OR LENGTH(cCuenta) <> 11 ) THEN
        SELECT mae.cuenta
          INTO cCuenta
          FROM bdinteg:si_cliente cte,
               bdicheq:sc_maechq mae
         WHERE cte.numcte_ref = pNumEmpCoppel
           AND mae.num_cte = cte.numcte
           AND mae.status_cta IN('1','3','4','5');
         
        IF ( cCuenta is null OR cCuenta = '' OR cCuenta = ' ' OR LENGTH(cCuenta) <> 11 ) THEN
            SELECT mae.cuenta
              INTO cCuenta
              FROM bdinteg:si_relacion_ctebcplcpl cte,
                   bdicheq:sc_maechq mae
             WHERE cte.empresa = mae.empresa
               AND cte.cliente = pNumEmpCoppel
               AND cte.numcte_banco = mae.num_cte
               AND mae.status_cta IN('1','3','4','5');
               
            IF ( cCuenta is null OR cCuenta = '' OR cCuenta = ' ' OR LENGTH(cCuenta) <> 11 ) THEN
                LET cCodRet = '00112';
                RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
            END IF;
        END IF;
        
        LET cCodRet = '00112';
        RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
    END IF;
    
    SELECT valor
      INTO cCuentaCgo
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'CuentaCgoColaborApp';
       
    SELECT valor
      INTO cTransacCgo
      FROM bdicheq:sc_param
     WHERE empresa = '001'
       AND codparam = 'TransacCgoColaborApp';
    
    EXECUTE PROCEDURE bdicheq:cargo_ref( '001', pSucursal, 'informix', cTransacCgo, '0000', pFolio, cCuentaCgo, 0, pMonto, cMoneda, 'CARGO POR DEPOSITO COLABORAPP', '', '' )
    INTO cCodRetCgo, cTranRetCgo, dtFechaCgo, mSdoDispCgo, mMtoRetCgo;
    
    IF cCodRetCgo = '000' THEN
        EXECUTE PROCEDURE bdicheq:abono_ref( '001', pSucursal, 'informix', pTransacc, '0000', pFolio, cCuenta, 0, pMonto, pMonto, 0, 0, 0, cMoneda, 'DEPOSITO COLABORAPP', '', '' )
        INTO cCodRetDep;
        
        IF cCodRetDep = '000' THEN
            LET cCodRet = '00000';
            
            SELECT {+INDEX(bdicheq:sc_movdia idx_movdia7a)}
				   FIRST 1 fech_alt, fech_oper
              INTO dtFechaAplic, dtFechaOpera
              FROM bdicheq:sc_movdia
             WHERE cuenta = cCuenta
               AND folio_suc = pFolio
               AND monto_tot = pMonto
               AND sucursal = pSucursal
               AND transacc = pTransacc;
               
            INSERT INTO bdicheq:bitacora_colaborapp
            ( idtrxglobal, sistemaorigen, numempcoppel, sucursal, transaccion, moneda, fecha, folio, cuenta, monto, tipo_operacion )
            VALUES
            ( pIdTrxGlobal, pSistemaOrigen, pNumEmpCoppel, pSucursal, pTransacc, pMoneda, current, pFolio, cCuenta, pMonto, pTipoOperacion );
        ELSE
            IF cCodRetDep = '301' THEN
                LET cCodRet = '00301';
            ELSE
                LET cCodRet = '00010';
            END IF;
        END IF;
    ELSE
        LET cCodRet = '00010';
    END IF;
    
    END;
    
    RETURN cCodRet, pNumEmpCoppel, dtFechaOpera, dtFechaAplic, pFolio;
    
END PROCEDURE;