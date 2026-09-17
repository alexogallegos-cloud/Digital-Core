create procedure "informix".sp_obtenertasa_prom(pSucursal CHAR(4),
                                    pPlazo INTEGER,
                                    pCapital MONEY(14,2),
                                    pNumcte CHAR(20),
                                    pNumCuenta char(20), 
                                    pSecuencia smallint)
-- ******************************************************************************************
-- Realizo   : Daniel Perez
-- Proyecto  : RQM Administrador de tasas
-- Actividad : Obtener una tasa promocional a partir de ciertos criterios del administrador
--                 
-- Fecha     : 20 de Septiembre de 2023
-- ******************************************************************************************                                    
RETURNING CHAR(5) AS codRet,
decimal(9,6) AS tasaPromocional,
int as idPromocion;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vIdPromocion          	INTEGER;
DEFINE vCodRet          		CHAR(5);
DEFINE vTipoSucursal          	CHAR(2);
DEFINE vInstruccionCapital      CHAR(2);
DEFINE vInstruccionIntereses    CHAR(2);
DEFINE vTasaPromocional 		DECIMAL(9,6);
DEFINE vCanal 		            SMALLINT;
DEFINE vFechaApertura 		    DATE;
DEFINE vFechaHoy                DATE;

-- Valores iniciales
LET vCodRet	 					= '000';
LET vTipoSucursal          	    = '';
LET vInstruccionCapital         = '';
LET vInstruccionIntereses       = '';
LET vTasaPromocional	 		= 0;
LET vCanal	 		            = 0;
LET vIdPromocion	 		    = -1;
LET vFechaApertura              = NULL;
LET vFechaHoy                   = '01011990';

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vTasaPromocional, vIdPromocion;
	END EXCEPTION;

	--SET debug FILE TO "/home/e98480286/PruebasSP/sp_obtenertasa_prom.out";
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

    --APERTURA
	DROP TABLE IF EXISTS temp_admintasas_promocion;

    IF pSecuencia = 1 THEN 

        SELECT {+INDEX(sv_fechas idx_fechas)} MAX(fecha_hoy) 
        INTO vFechaHoy
        FROM sv_fechas
        WHERE empresa = '001';

        SELECT instruccion_capital, instruccion_intereses 
        INTO vInstruccionCapital, vInstruccionIntereses
        FROM sv_admintasas_instruccion_vencimiento
        WHERE num_cte = pNumcte;

        --OBTENER LA FECHA DE APERTURA DE SU PRIMER CUENTA DE CAPTACION
        SELECT MIN(maenoc.fecha_alta)
        INTO vFechaApertura
        FROM bdicheq:sc_maenoc AS maenoc
        INNER JOIN bdicheq:sc_maechq AS maechq
        ON maenoc.cuenta = maechq.cuenta
        AND maechq.producto IN (SELECT {+INDEX(sv_admintasas_clientesnuevos_productos idx_sv_admintasas_clientesnuevos_productos)} producto FROM sv_admintasas_clientesnuevos_productos WHERE activo = 'S')
        WHERE maechq.num_cte = pNumcte;

        SELECT FIRST 1 mae.id_promocion, mae.tasa
        FROM bdinvers:sv_admintasas_pagare AS mae
        LEFT JOIN bdinvers:sv_sucursales_promocion AS suc
            ON mae.id_promocion = suc.id_promocion
        LEFT JOIN bdinvers:sv_clientes_promocion AS cte
            ON mae.id_promocion = cte.id_promocion
        LEFT JOIN bdinvers:sv_cuentas_promocion AS cta
            ON mae.id_promocion = cta.id_promocion
        INNER JOIN sv_admintasas_estatus AS est
            ON mae.id_promocion = est.id_promocion
		LEFT join bdicheq:sc_admintasas_sdo_nuevo as sdo 
        	on (sdo.id_promocion = mae.id_promocion  and  sdo.num_cliente = pNumcte)
        WHERE pPlazo BETWEEN plazo_inicio AND plazo_vencimiento 
        AND pCapital BETWEEN capital_min AND capital_max
        AND mae.canal = vCanal
        AND ((vFechaHoy BETWEEN fecha_inicio AND fecha_vencimiento AND mae.dias_vigencia IS NULL) OR (vFechaApertura BETWEEN fecha_inicio AND fecha_vencimiento AND vFechaHoy <= (vFechaApertura + COALESCE(mae.dias_vigencia, 0))))
        AND (num_sucursal = pSucursal OR num_sucursal IS NULL)
        AND (num_cte = pNumcte OR num_cte IS NULL)
        AND cta.num_cuenta IS NULL
        AND est.fecha_cambio = (select max(fecha_cambio) from sv_admintasas_estatus where id_promocion = mae.id_promocion)
        AND est.cod_estatus in (1,2)
        AND ((mae.instruccion_vencimiento_capital IS NULL AND mae.instruccion_vencimiento_intereses IS NULL) OR (mae.instruccion_vencimiento_capital = COALESCE(vInstruccionCapital, '') AND mae.instruccion_vencimiento_intereses = COALESCE(vInstruccionIntereses, '')))
		AND (((sdo.sdo_nuevo * -1) >= monto_saldonuevo) OR ((sdo.sdo_nuevo) >= monto_saldonuevo) OR monto_saldonuevo IS NULL)
        ORDER BY tasa DESC
		INTO temp temp_admintasas_promocion
        WITH NO LOG;

		SELECT id_promocion, tasa
		INTO vIdPromocion, vTasaPromocional
		FROM temp_admintasas_promocion;
	   
    ELSE
        --REINVERSION
        --Reinversion desde apertura
        --Validar si la cuenta fue aperturada con una promocion con escalamiento
        SELECT limit 1 id_promocion INTO vIdPromocion from sv_logapertura_admintasas where cuenta = pNumCuenta;

        --Cuando es promocion emergente
        IF vIdPromocion IS NULL THEN
            SELECT cuenta.id_promocion INTO vIdPromocion 
            FROM sv_cuentas_promocion as cuenta
            INNER JOIN sv_admintasas_estatus as est
            ON cuenta.id_promocion = est.id_promocion
            WHERE num_cuenta = pNumCuenta 
            AND est.fecha_cambio = (select max(fecha_cambio) from sv_admintasas_estatus where id_promocion = cuenta.id_promocion)
            AND est.cod_estatus IN (1,2);
        END IF;
        --Obtener tasa promocional
        SELECT tasa INTO vTasaPromocional FROM sv_admintasas_renovacion WHERE id_promocion = vIdPromocion AND secuencia = pSecuencia - 1;

        DELETE FROM sv_admintasas_instruccion_vencimiento WHERE num_cte = pNumcte;
    END IF;

    

    IF vTasaPromocional IS NULL OR vTasaPromocional = 0 THEN
        LET vCodRet = '001';
    END IF;

    DROP TABLE IF EXISTS temp_admintasas_promocion;

    RETURN vCodRet, vTasaPromocional, vIdPromocion;


END;
END PROCEDURE
