CREATE PROCEDURE "informix".sp_validacteportnom_bpi( pEmpresa CHAR(3), pNumCte CHAR(20), pCuenta CHAR(20) ) 
RETURNING CHAR(5), CHAR(100);
    
    DEFINE intSqlErr    INTEGER;
    DEFINE intIsamErr   INTEGER;
    DEFINE chrDescErr   CHAR(100);
    DEFINE chrCodRet1   CHAR(5);
    DEFINE chrCodRet2   CHAR(5);
    DEFINE chrCodRet3   CHAR(100);
    DEFINE intExisteCte SMALLINT;
    DEFINE intExisteCta SMALLINT;
    DEFINE iActivo      SMALLINT;

    LET intSqlErr    = 0;
    LET intIsamErr   = 0;
    LET chrDescErr   = '';
    LET chrCodRet1   = '000';
    LET chrCodRet2   = '';
    LET chrCodRet3   = 'CLIENTE / CUENTA VALIDOS';
    LET intExisteCte = 0;
    LET intExisteCta = 0;
    LET iActivo      = 0;

    BEGIN
    
    ON EXCEPTION SET intSqlErr, intIsamErr, chrDescErr
        --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validacteportnom_bpi.err";
        --- TRACE ON;
        IF intSqlErr <> 0 THEN
            LET chrCodRet1 = intSqlErr;
            LET chrCodRet2 = intIsamErr;
            LET chrCodRet3 = chrDescErr;
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_validacteportnom_bpi.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa = '' OR pEmpresa = ' ' ) OR
       ( pNumCte  is null OR pNumCte  = '' OR pNumCte  = ' ' ) OR
       ( pCuenta  is null OR pCuenta  = '' OR pCuenta  = ' ' ) THEN
        LET chrCodRet1 = '110';
        LET chrCodRet3 = 'PARAMETROS DE ENTRADA INCORRECTOS';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    SELECT activo
      INTO iActivo
      FROM sc_producportab
     WHERE producto = '2900';
     
    IF iActivo = 0 THEN
        LET chrCodRet1 = '014';
        LET chrCodRet3 = 'PRODUCTO NO PERMITE PORTABILIDAD';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    SELECT COUNT(*)
      INTO intExisteCte
      FROM bdinteg:si_cliente
     WHERE numcte = pNumCte
       AND tipo_cliente = '1';
       
    IF intExisteCte > 0 THEN
        IF LENGTH(pCuenta) = 11 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_maechq
             WHERE cuenta = pCuenta
               AND num_cte = pNumCte
               AND status_cta IN('1','3','4','5');
        ELIF LENGTH(pCuenta) = 16 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_tarjeta trj,
                   sc_maechq mae
             WHERE trj.num_tarjeta = pCuenta
               AND mae.num_cte = pNumCte
               AND mae.cuenta = trj.cuenta
               AND mae.num_cte = trj.numcte
               AND mae.status_cta IN('1','3','4','5');
        ELIF LENGTH(pCuenta) = 18 THEN
            SELECT COUNT(*)
              INTO intExisteCta
              FROM sc_maechq
             WHERE cuenta_clabe = pCuenta
               AND num_cte = pNumCte
               AND status_cta IN('1','3','4','5');
        ELSE
            LET chrCodRet1 = '100';
            LET chrCodRet3 = 'CUENTA NO EXISTE';
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
        
        IF intExisteCta = 0 THEN
            LET chrCodRet1 = '200';
            LET chrCodRet3 = 'CUENTA NO EXISTE / CANCELADA';
            RETURN chrCodRet1, TRIM(chrCodRet3);
        END IF;
    ELSE
        LET chrCodRet1 = '104';
        LET chrCodRet3 = 'CLIENTE NO EXISTE / TIPO DE CLIENTE INVALIDO';
        RETURN chrCodRet1, TRIM(chrCodRet3);
    END IF;
    
    RETURN chrCodRet1, TRIM(chrCodRet3);
    
    END;
    
END PROCEDURE;