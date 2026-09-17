CREATE PROCEDURE "informix".sp_adn_obtienectas(pEmpresa CHAR(3), pNumCte CHAR(20))
RETURNING CHAR(6)        AS codigo_retorno,
		  CHAR(20)      AS cuentas;

DEFINE cCodRet		CHAR(6);
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;
DEFINE cErrorInfo	VARCHAR(80,1);

DEFINE cCuenta	CHAR(20);

-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
DEFINE cCuentaSol	INT;

DEFINE vPeriodo	    DATE;

LET cCodRet			= "000000";
LET iSqlErr			= 0;
LET iSamErr			= 0;
LET cErrorInfo		= "";

LET cCuenta		= "";
LET vPeriodo = DATE(1);

-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
LET cCuentaSol	= 0;

BEGIN
ON EXCEPTION SET iSqlErr, iSamErr, cErrorInfo
IF iSqlErr != 0 THEN
	LET cCodRet = iSqlErr::CHAR(8);
	RETURN NVL(cCodRet,''),'';
END IF;
END EXCEPTION; 	

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF TRIM(NVL(pEmpresa,"")) = "" OR  TRIM(NVL(pNumCte,"")) = ""  THEN
		LET cCodRet  = "000001";
		RETURN cCodRet,cCuenta;
	END IF;

	-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
	SELECT 	COUNT(*) INTO cCuentaSol
	FROM	bdisolic:"informix".ss_solicitudes
	WHERE	numcte = pNumCte
	AND		num_producto = '7800'
	AND		status_solicitud = 'PC'
	AND		canal_sol = '8'
	AND		fecha_insert < MDY(1,1,2025);

	IF (cCuentaSol > 0) THEN
		LET cCodRet  = "000003";
		RETURN cCodRet,cCuenta; -- YA CUENTA CON SOLICITUD POR OTRO CANAL
	END IF;
	-- INC 27 331 Bloqueo de aperturas para el producto 7800 Anticipo de Nomina
    
    SELECT MAX(periodo)
    INTO   vPeriodo
    FROM   bdicheq:"informix".sc_bitacora_movnom
    WHERE  id_proceso = 'ingajustado'
	AND    fechahora_fin IS NOT NULL;
    
    IF (NVL(vPeriodo,'') = '') THEN
		RETURN '000004',cCuenta;
    END IF;
    
    FOREACH WITH HOLD
        SELECT 		a.cuenta
        INTO        cCuenta
		FROM  		bdicheq:"informix".sc_nom_disp_cte a
		INNER JOIN	bdisolic:"informix".ss_producto_credcap b ON b.producto_cap = a.producto AND b.num_producto = '7800'
		WHERE 		a.numcte     = pNumCte
		AND   		a.fecha_pago = vPeriodo
		ORDER BY 	a.ingreso_ajustado DESC
		
		RETURN cCodRet, cCuenta WITH RESUME;
	END  FOREACH;
	
	IF (cCuenta = '') THEN 
		RETURN '000002',cCuenta; -- No se encontraron cuentas validas
	END IF;
END
END PROCEDURE
