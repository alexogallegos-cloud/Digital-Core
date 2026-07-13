CREATE PROCEDURE "informix".sp_obtienepromociones_admintasas(
                                    pSucursal CHAR(4),
                                    pNumcte CHAR(20))
    
RETURNING CHAR(5) AS codRet,
DECIMAL(9,6) AS tasaPromocional,
INT as idPromocion,
DATE as fechaVencimiento,
DECIMAL(9,6) AS gatNominal,
DECIMAL(9,6) AS gatReal;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vIdPromocion          	INTEGER;
DEFINE vCodRet          		CHAR(5);
DEFINE vTipoSucursal          	CHAR(2);
DEFINE vTasaPromocional 		DECIMAL(9,6);
DEFINE vCanal 		            smallint;
DEFINE vFechaVencimiento		DATE;
DEFINE vGatNominal 				DECIMAL(9,6);
DEFINE vGatReal 				DECIMAL(9,6);

-- Valores iniciales
LET vCodRet	 					= '000';
LET vTipoSucursal          	    = '';
LET vTasaPromocional	 		= 0;
LET vCanal	 		            = 0;
LET vIdPromocion	 		    = -1;
LET vFechaVencimiento 			= '01011990';
LET vGatNominal	 				= 0;
LET vGatReal	 				= 0;

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/prueba_ofi_pagare/sp_obtienepromociones_admintasas.out';
    --TRACE ON;

    --Identificar el tipo de canal
    IF pSucursal = '5011' THEN
        LET vCanal = 2; --APP
    ELIF pSucursal = '5003' THEN
        LET vCanal = 3; --PORTAL
    ELSE
        SELECT tpo_sucursal 
        INTO vTipoSucursal
        FROM bdinteg:si_sucursales WHERE sucursal = pSucursal;

        IF vTipoSucursal = 'S' THEN 
            LET vCanal = 1; --SUCURSAL
        ELIF vTipoSucursal = 'C' THEN
             LET vCanal = 4; --CAJERO
        END IF;
    END IF;

    FOREACH
		SELECT mae.tasa, mae.id_promocion, mae.fecha_vencimiento, mae.gat_nominal, mae.gat_real
		INTO vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal
		FROM bdinvers:sv_admintasas_pagare AS mae
		LEFT JOIN bdinvers:sv_sucursales_promocion AS suc
			ON mae.id_promocion = suc.id_promocion
		LEFT JOIN bdinvers:sv_clientes_promocion AS cte
			ON mae.id_promocion = cte.id_promocion
        LEFT JOIN bdinvers:sv_cuentas_promocion AS cta
			ON mae.id_promocion = cta.id_promocion
        INNER JOIN bdinvers:sv_admintasas_estatus AS est
            ON mae.id_promocion = est.id_promocion
		WHERE mae.canal = vCanal
		AND today BETWEEN fecha_inicio AND fecha_vencimiento
		AND (num_sucursal = pSucursal	OR num_sucursal IS NULL)
		AND (num_cte = pNumcte OR num_cte IS NULL)
        AND cta.num_cuenta IS NULL
        AND est.fecha_cambio = (select max(fecha_cambio) from sv_admintasas_estatus where id_promocion = mae.id_promocion)
        AND est.cod_estatus <> 0
		ORDER BY mae.capital_min, mae.tasa
		RETURN vCodRet, vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal WITH RESUME;
	END FOREACH; 
	

END;
END PROCEDURE  ;