create procedure "informix".sp_admintasas_valida_clientenuevo(pNumcte CHAR(20), pSucursal CHAR(4), pProducto CHAR(4))
-- ******************************************************************************************
-- Realizo   : Daniel Perez
-- Proyecto  : RQM Administrador de tasas - TEMCAP08 Addendum
-- Actividad : Determinar si existen promociones disponibles para un cliente nuevo.
--                 
-- Fecha     : 23 de Junio de 2025
-- ******************************************************************************************                                    
RETURNING CHAR(5) AS codRet,
DATE AS fecha_apertura,
DATE AS fecha_prom;

-- DefiniciÃ³n de Variables
DEFINE SQL_ERR          		INTEGER;
DEFINE vIdPromocion          	INTEGER;
DEFINE vCodRet          		CHAR(5);
DEFINE vTipoSucursal          	CHAR(2);
DEFINE vCanal 		            SMALLINT;
DEFINE vPromocionesDisponibles	SMALLINT;
DEFINE vcantidadCuentasCaptacion SMALLINT;
DEFINE vFechaHoy                DATE;
DEFINE vFechaApertura 		    DATE;
DEFINE vFechaPromocion		    DATE;

-- Valores iniciales
LET vCodRet	 					= '001';
LET vTipoSucursal          	    = '';
LET vCanal	 		            = 0;
LET vPromocionesDisponibles	    = 0;
LET vcantidadCuentasCaptacion	= 0;
LET vFechaHoy                   = '01011990';
LET vFechaApertura              = '01011990';
LET vFechaPromocion             = '01011990';

BEGIN

	ON EXCEPTION SET SQL_ERR
        LET vCodRet = SQL_ERR;
        RETURN vCodRet, vFechaApertura, vFechaPromocion;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/sysifx/Miguel/Captacion/prueba_ofi_pagare/sp_admintasas_valida_clientenuevo.out';
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


    --DETERMINAR SI ES UN CLIENTE NUEVO
    SELECT COUNT(*), MIN(maenoc.fecha_alta)
    INTO vcantidadCuentasCaptacion, vFechaApertura
    FROM bdicheq:sc_maenoc AS maenoc
    INNER JOIN bdicheq:sc_maechq AS maechq
    ON maenoc.cuenta = maechq.cuenta    
    WHERE maechq.num_cte = pNumcte
    AND maechq.producto IN (SELECT producto FROM sv_admintasas_clientesnuevos_productos WHERE activo = 'S');

    IF vcantidadCuentasCaptacion = 1 AND pProducto IN (SELECT producto FROM sv_admintasas_clientesnuevos_productos WHERE activo = 'S') THEN

        SELECT {+INDEX(sv_fechas idx_fechas)} MAX(fecha_hoy) 
        INTO vFechaHoy
        FROM sv_fechas
        WHERE empresa = '001';

        SELECT COUNT(*), (vFechaHoy + MAX(mae.dias_vigencia))
        INTO vPromocionesDisponibles, vFechaPromocion
        FROM bdinvers:sv_admintasas_pagare AS mae
        LEFT JOIN bdinvers:sv_sucursales_promocion AS suc
            ON mae.id_promocion = suc.id_promocion
        LEFT JOIN bdinvers:sv_clientes_promocion AS cte
            ON mae.id_promocion = cte.id_promocion
        LEFT JOIN bdinvers:sv_cuentas_promocion AS cta
            ON mae.id_promocion = cta.id_promocion
        INNER JOIN sv_admintasas_estatus AS est
            ON mae.id_promocion = est.id_promocion
        WHERE mae.canal = vCanal
        AND vFechaHoy BETWEEN fecha_inicio AND fecha_vencimiento 
        AND mae.dias_vigencia IS NOT NULL
        AND (suc.num_sucursal = pSucursal OR suc.num_sucursal IS NULL)
        AND (cte.num_cte = pNumcte OR cte.num_cte IS NULL)
        AND cta.num_cuenta IS NULL
        AND est.fecha_cambio = (select max(fecha_cambio) from sv_admintasas_estatus where id_promocion = mae.id_promocion)
        AND est.cod_estatus in (1,2);
    END IF;


    IF vPromocionesDisponibles > 0 THEN
        LET vCodRet = '000';
    END IF;

    RETURN vCodRet, vFechaApertura, vFechaPromocion;


END;
END PROCEDURE
