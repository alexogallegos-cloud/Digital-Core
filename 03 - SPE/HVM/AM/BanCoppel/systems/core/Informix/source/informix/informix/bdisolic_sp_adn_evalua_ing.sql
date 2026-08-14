CREATE PROCEDURE "informix".sp_adn_evalua_ing(pCuenta CHAR(20), pMeses INTEGER)

RETURNING CHAR(6)           AS codigo_retorno,
          CHAR(3)           AS segmento,
		  DECIMAL(18,2)     AS monto,
		  INTEGER           AS num_depositos;

DEFINE cCodRet          CHAR(6);
DEFINE iSqlErr          INTEGER;
DEFINE vMonto           DECIMAL(18,2);
DEFINE vPeriodo,
       vFechaDepositos  DATE;
DEFINE vSegmento        CHAR(3);
DEFINE vNumDep          INTEGER;

LET cCodRet = '000000';
LET iSqlErr = 0;
LET vMonto  = 0;
LET vNumDep = 0;
LET vFechaDepositos = DATE(1);
LET vPeriodo = DATE(1);
LET vSegmento = '';


BEGIN
    ON EXCEPTION SET iSqlErr
    IF iSqlErr != 0 THEN
        LET cCodRet = iSqlErr;
        RETURN NVL(cCodRet,''),vSegmento,vMonto,vNumDep;
    END IF;
END EXCEPTION;

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO dirty READ;
    
    SELECT  MAX(periodo)
    INTO    vPeriodo
    FROM    bdicheq:"informix".sc_bitacora_movnom
    WHERE   id_proceso = 'ingajustado'
    AND     fechahora_fin IS NOT NULL;

    IF NVL(vPeriodo,'') = '' THEN
        LET cCodRet = '000002';
	    RETURN cCodRet, vSegmento, vMonto, vNumDep;
    END IF;
    
    IF pMeses > 0 THEN 
        LET vFechaDepositos = vPeriodo - pMeses UNITS MONTH;
    ELIF pMeses = 0 THEN
        LET vFechaDepositos = vPeriodo;
    ELSE
        LET cCodRet = '000003';
	    RETURN cCodRet, vSegmento, vMonto, vNumDep;
    END IF;
    
    SELECT SUM(conteo_depositos)
    INTO   vNumDep
    FROM   bdicheq:"informix".sc_nom_disp_cte
    WHERE  cuenta = pCuenta
    AND    fecha_pago >= vFechaDepositos;
    
    SELECT ingreso_ajustado, tipo_transaccion
    INTO   vMonto, vSegmento
    FROM   bdicheq:"informix".sc_nom_disp_cte
    WHERE  cuenta = pCuenta
    AND    fecha_pago = vPeriodo;
    
    IF NVL(vMonto,'') = '' THEN
        LET cCodRet = '000001';
	    RETURN cCodRet, vSegmento, vMonto, vNumDep;
    END IF
    
    RETURN cCodRet, vSegmento, vMonto, vNumDep;

END
END PROCEDURE
