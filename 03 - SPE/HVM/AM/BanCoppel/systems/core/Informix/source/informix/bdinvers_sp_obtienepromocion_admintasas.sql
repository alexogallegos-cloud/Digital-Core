CREATE PROCEDURE "informix".sp_obtienepromocion_admintasas(pIdPromocion INT)

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
		  DECIMAL(9,6)  AS gatReal


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

BEGIN

	ON EXCEPTION SET SQL_ERR,ISAM_ERR,ERROR_INFO
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoVencimiento,
			   vPlazoInicio, vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/pruebas_admin_tasas/sp_obtienepromocion_admintasas.out';
    --TRACE ON;
	
	IF pIdPromocion IS NULl OR pIdPromocion <= 0 THEN
		LET vCodRet = '001';
		RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoVencimiento,
			   vPlazoInicio, vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal;
	END IF
	
	SELECT nombre_estrategia, canal, tasa, capital_min, capital_max, plazo_inicio, plazo_vencimiento,
		   fecha_inicio, fecha_vencimiento, gat_real, gat_nominal
	INTO   vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax,vPlazoInicio, vPlazoVencimiento,
		   vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal
	FROM sv_admintasas_pagare
	WHERE id_promocion = pIdPromocion;
	
	RETURN vCodRet, vNombrePromocion , vCanal, vTasa, vCapitalMin, vCapitalMax, vPlazoInicio,
		   vPlazoVencimiento , vFechaInicio, vFechaVencimiento, vGatNominal, vGatReal;

END

END PROCEDURE
;