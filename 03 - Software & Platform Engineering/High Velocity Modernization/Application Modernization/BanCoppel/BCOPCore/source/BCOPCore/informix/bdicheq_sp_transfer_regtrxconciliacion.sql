CREATE PROCEDURE "informix".sp_transfer_regtrxconciliacion
( 
	pFolioSuc     CHAR(16), 
	pSucursal     CHAR(4),
	pUsuario      CHAR(8),
	pTransacc     CHAR(4),
	pCuenta       CHAR(20),
	pMonto        DECIMAL(14,2),
	pReferencia   CHAR(40),
	pTarjeta      CHAR(16) 
)
RETURNING CHAR(5);
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(5);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE vFechaHoy    DATE;
    DEFINE vHora        DATETIME HOUR TO FRACTION(3);
    DEFINE vProducto    CHAR(4);
    DEFINE vSucCuenta   CHAR(4);
	DEFINE vFechaOperacion DATE;
	
    LET cCodRet     = '';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr     = 0;
    LET iSamErr     = 0;
    LET cDesErr     = 0;
    LET vFechaHoy   = '';
    LET vHora       = '';
    LET vProducto   = '';
    LET vSucCuenta  = '';
	LET vFechaOperacion = TODAY;

    BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_regtrxconciliacion.err";
        TRACE ON;
		
        IF iSqlErr <> 0 THEN
            LET cCodRet  = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet;
        END IF;
		
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_transfer_regtrxconciliacion.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFolioSuc is null OR pFolioSuc = '' ) OR
         ( pSucursal is null OR pSucursal = '' ) OR
         ( pUsuario  is null OR pUsuario  = '' ) OR
         ( pTransacc is null OR pTransacc = '' ) OR
         ( pCuenta   is null OR pCuenta   = '' ) OR
         ( pMonto   is null  OR pMonto   <= 0 ) ) 
	THEN
        
		LET cCodRet = '110';
        RETURN cCodRet;
		
    END IF;
    
    SELECT fecha_hoy
    INTO vFechaHoy
    FROM sc_fechas
    WHERE empresa = '001';
     
    IF SUBSTR(pCuenta, 1, 2) = '80' THEN
	
        SELECT valor
        INTO vProducto
        FROM sc_param
        WHERE empresa = '001'
        AND codparam = 'ProductoTransfer';
        
        LET vSucCuenta = pSucursal;
		
    ELSE
	
        SELECT producto, sucursal
        INTO vProducto, vSucCuenta
        FROM sc_maechq
        WHERE cuenta = pCuenta;
		
    END IF;
    
    LET vHora = CURRENT HOUR TO FRACTION;
    
	-- 29/06/2023 Se confirma con el equipo de BD que cambios o adecuaciones a las tablas principales de bdicheq y bdicred por el momento 
	-- no es posible, por lo que realizar alguna depuraciÃ³n en cuanto a informaciÃ³n y/o indices no es viable para aplicar.
    INSERT INTO sc_movdia 
	VALUES
	( 
		0, pFolioSuc, pSucursal, pUsuario, vFechaHoy, vFechaHoy, vHora, pTransacc, vSucCuenta, vProducto, 
		'001', pCuenta, "", 0, pMonto, 0, 0, 0, 0, "", "", 0.00, '0000', pReferencia, 0, pTarjeta, '', '', vFechaOperacion
	);
    
    IF dbinfo('sqlca.sqlerrd2') > 0  THEN
        LET cCodRet = '000';
    ELSE
        LET cCodRet = '999';
    END IF;
    
    END;
    
    RETURN cCodRet; 
    
END PROCEDURE;