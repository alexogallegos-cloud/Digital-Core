CREATE PROCEDURE "informix".sp_obtienepromocion_admintasas_addendum(pIdPromocion INT)

RETURNING CHAR(5)		AS codRet,
		  CHAR(100) 	AS nombrePromocion,
		  SMALLINT  	AS canal,
		  DECIMAL(9,6)  AS tasa,
		  MONEY(14,2)   AS capitalMin,
		  MONEY(14,2)   AS capitalMax,
		  INT			AS plazoInicio,
		  INT 			AS plazoVencimiento,
		  DATE			AS fechaInicio,
		  DATE 			AS fechaVencimiento,
		  DECIMAL(9,6)  AS gatNominal,
		  DECIMAL(9,6)  AS gatReal,
		  CHAR(2)		AS intruccionCapital,
		  CHAR(2)		AS intruccionIntereses,
		  SMALLINT 		AS diasVigencia,
		  MONEY(14,2)	AS montoSaldoNuevo


DEFINE SQL_ERR          		INTEGER;
DEFINE ERROR_INFO       		CHAR(80);
DEFINE ISAM_ERR         		INTEGER;
DEFINE vCodRet          		CHAR(5);
DEFINE vNombrePromocion			CHAR(100);
DEFINE vCanal					SMALLINT;
DEFINE vTasa					DECIMAL(9,6);
DEFINE vGatNominal				DECIMAL(9,6);
DEFINE vGatReal					DECIMAL(9,6);
DEFINE vCapitalMin				MONEY(14,2);
DEFINE vCapitalMax				MONEY(14,2);
DEFINE vPlazoVencimiento		INT;
DEFINE vPlazoInicio				INT;
DEFINE vFechaInicio				DATE;
DEFINE vFechaVencimiento		DATE;
DEFINE vIntruccionCapital		CHAR(2);
DEFINE vInstruccionIntereses	CHAR(2);
DEFINE vDiasVigencia			SMALLINT;
DEFINE vMontoSaldoNuevo	 		MONEY(14,2);

LET vNombrePromocion = '';
LET vCanal = 0;
LET vTasa = 0;
LET vCapitalMin = 0;
LET vCapitalMax = 0;
LET vPlazoVencimiento = 0;
LET vPlazoInicio = 0;
LET vFechaInicio = '01011990';
LET vFechaVencimiento = '01011990';
LET vGatNominal = 0;
LET vGatReal = 0;
LET vCodRet = '000';
LET vIntruccionCapital = '';
LET vInstruccionIntereses = '';
LET vDiasVigencia = 0;
LET vMontoSAldoNuevo = 0;

BEGIN

	ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoInicio,
			   vPlazoVencimiento, vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal, vIntruccionCapital, vInstruccionIntereses, vDiasVigencia, vMontoSAldoNuevo;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/pruebas_admin_tasas/sp_obtienepromocion_admintasas_addendum.out';
    --TRACE ON;

	SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;
	
	IF pIdPromocion IS NULl OR pIdPromocion <= 0 THEN
		LET vCodRet = '001';
		RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoInicio,
			   vPlazoVencimiento, vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal, vIntruccionCapital, vInstruccionIntereses, vDiasVigencia, vMontoSAldoNuevo;
	END IF
	
	SELECT nombre_estrategia, canal, tasa, capital_min, capital_max, plazo_inicio, plazo_vencimiento,
		   fecha_inicio, fecha_vencimiento, gat_real, gat_nominal, instruccion_vencimiento_capital, instruccion_vencimiento_intereses, dias_vigencia, monto_saldonuevo
	INTO   vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax,vPlazoInicio, vPlazoVencimiento,
		   vFechaInicio, vFechaVencimiento, vGatReal, vGatNominal, vIntruccionCapital, vInstruccionIntereses, vDiasVigencia, vMontoSAldoNuevo
	FROM sv_admintasas_pagare
	WHERE id_promocion = pIdPromocion;
	
	RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoInicio,
		   vPlazoVencimiento , vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal, vIntruccionCapital, vInstruccionIntereses, vDiasVigencia, vMontoSAldoNuevo;

END

END PROCEDURE
;