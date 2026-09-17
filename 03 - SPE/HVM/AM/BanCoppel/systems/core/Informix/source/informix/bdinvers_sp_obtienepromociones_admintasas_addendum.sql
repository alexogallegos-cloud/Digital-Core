CREATE PROCEDURE "informix".sp_obtienepromociones_admintasas_addendum(
                                    pSucursal CHAR(4),
                                    pNumcte CHAR(20))
    
RETURNING 
CHAR(5)      AS codRet,
DECIMAL(9,6) AS tasaPromocional,
INT          AS idPromocion,
DATE         AS fechaVencimiento,
DECIMAL(9,6) AS gatNominal,
DECIMAL(9,6) AS gatReal,
MONEY(14,2)  AS saldoNuevo;

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
DEFINE vFechaApertura 		    DATE;
DEFINE vSaldoNuevo 				MONEY(14,2);
DEFINE vFechaHoy                DATE;

-- Valores iniciales
LET vCodRet	 					= '000';
LET vTipoSucursal          	    = '';
LET vTasaPromocional	 		= 0;
LET vCanal	 		            = 0;
LET vIdPromocion	 		    = -1;
LET vFechaVencimiento 			= '01011990';
LET vGatNominal	 				= 0;
LET vGatReal	 				= 0;
LET vFechaApertura              = NULL;
LET vSaldoNuevo	 				= 0;
LET vFechaHoy                   = '01011990';

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal, vSaldoNuevo;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/informix/cliente_nuevo/prueba_ofi_pagare/sp_obtienepromociones_admintasas_addendum.out';
    --TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

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

    SELECT {+INDEX(sv_fechas idx_fechas)} MAX(fecha_hoy) 
        INTO vFechaHoy
        FROM sv_fechas
        WHERE empresa = '001';

    SELECT MIN(maenoc.fecha_alta)
        INTO vFechaApertura
        FROM bdicheq:sc_maenoc AS maenoc
        INNER JOIN bdicheq:sc_maechq AS maechq
        ON maenoc.cuenta = maechq.cuenta
        AND maechq.producto IN (SELECT {+INDEX(sv_admintasas_clientesnuevos_productos idx_sv_admintasas_clientesnuevos_productos)} producto FROM sv_admintasas_clientesnuevos_productos WHERE activo = 'S')
        WHERE maechq.num_cte = pNumcte;

	FOREACH
		SELECT mae.tasa, mae.id_promocion, mae.fecha_vencimiento, mae.gat_nominal, mae.gat_real, mae.monto_saldonuevo
		INTO vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal, vSaldoNuevo
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
		AND ((vFechaHoy BETWEEN fecha_inicio AND fecha_vencimiento AND mae.dias_vigencia IS NULL) OR (vFechaApertura BETWEEN fecha_inicio AND fecha_vencimiento AND vFechaHoy <= (vFechaApertura + COALESCE(mae.dias_vigencia, 0))))
		AND (num_sucursal = pSucursal	OR num_sucursal IS NULL)
		AND (num_cte = pNumcte OR num_cte IS NULL)
        AND cta.num_cuenta IS NULL
        AND est.fecha_cambio = (select max(fecha_cambio) from sv_admintasas_estatus where id_promocion = mae.id_promocion)
        AND est.cod_estatus in (1,2)
		ORDER BY mae.capital_min, mae.tasa
		RETURN vCodRet, vTasaPromocional, vIdPromocion, vFechaVencimiento, vGatNominal, vGatReal, vSaldoNuevo WITH RESUME;
	END FOREACH; 

END;
END PROCEDURE  ;