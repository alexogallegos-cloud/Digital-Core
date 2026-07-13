CREATE PROCEDURE "informix".sp_repinvtardia(
psSucursal CHAR (5),
pdFechaInicial DATE,
pdFechaFinal DATE
)

RETURNING INTEGER AS CodRet, DATETIME YEAR TO FRACTION (5) AS fechageneracion, CHAR(5) AS cve_sucursal, CHAR(50) AS nombre_sucursal, INTEGER AS cant_tar_disp,
          INTEGER AS cant_tar_disp_suc, INTEGER AS cant_tar_sol, CHAR(20) AS desc_tipo_tar, INTEGER AS tot_sol_suc;

--****************************************************************************************************
-- DESCRIPCION: Obtiene informacion de tarjetas recibidas,pendientes,asignadas,canceladas,disponibles en sucursal por imagen y total general
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 05/12/2008
-- BD: Intercard
-- SISTEMA : Reporte Inventario De Tarjetas
--****************************************************************************************************

DEFINE viSqlErr INTEGER ;
DEFINE vdFechaGen DATETIME YEAR TO FRACTION (5);     --Fecha
DEFINE vsCveSucursal CHAR(5);                     --Numero De Sucursal
DEFINE vsNomSucursal CHAR(50);                    --Nombre De Sucursal
DEFINE viCantidadTarjetasSol INTEGER;             --Cantidad De Tarjetas Solicitadas
DEFINE viCantTarDisp INTEGER;                     --Cantidad De Tarjetas Disponibles
DEFINE viCantTarDispSuc INTEGER;                  --Cantidad De Tarjetas Disponibles Por Sucursal
DEFINE vsDescTipoTar CHAR(20);                    --Descripcion Tipo Tarjeta
DEFINE vsTotSolSuc INTEGER;                       --Total Solicitadas Por Sucursal

LET viSqlErr = 0;
LET vdFechaGen = CURRENT;
LET vsCveSucursal = '';
LET vsNomSucursal = '';
LET viCantidadTarjetasSol = 0;
LET viCantTarDisp = 0;
LET viCantTarDispSuc = 0;
LET vsDescTipoTar = '';
LET vsTotSolSuc = 0;

--set debug file to "/tmp/sp_RepInvTarDia.sql";
--Trace on;

BEGIN

ON EXCEPTION SET viSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF viSqlErr <> 0 THEN
    RETURN viSqlErr, vdFechaGen, vsCveSucursal, vsNomSucursal, NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0), viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc WITH RESUME;
	END IF; 
END EXCEPTION ;

IF(pdFechaInicial = "") OR (pdFechaInicial IS NULL) THEN --En caso que la fecha inicial venga vacia o nulo marcara error
    LET viSqlErr = 1 ;
    RETURN viSqlErr, vdFechaGen, vsCveSucursal, vsNomSucursal, NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0), viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc WITH RESUME;
END IF;

IF (pdFechaFinal = "") OR (pdFechaFinal IS NULL) THEN --En caso que la fecha final venga vacia o nulo marcara error
    LET viSqlErr = 2;
    RETURN viSqlErr, vdFechaGen, vsCveSucursal, vsNomSucursal, NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0), viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc WITH RESUME;
END IF;

IF(psSucursal <> '') AND (psSucursal IS NOT NULL) THEN --Valida que la consulta sea por una sucursal especifica
	IF EXISTS(SELECT clave_sucursal, enoperacion FROM intercard:sucursal WHERE clave_sucursal = psSucursal AND enoperacion = 'V') THEN --Valida que la sucursal este activa
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
			SELECT lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal
				  ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_imagen --Muestra la cantidad de tarjetas disponibles por imagen
					FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
					WHERE suc1.clave_sucursal = lot1.clave_sucursal 
					AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
					GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
				  ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_suc --Muestra la cantidad de tarjetas disponibles por sucursal
					FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
					WHERE suc1.clave_sucursal = lot1.clave_sucursal 
					AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
					GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo),lot.cantidadtarjetassol, tipotar.descripcion
				  ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
			        WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal)  
			        AS tot_sol_suc
			INTO vdFechaGen, vsCveSucursal, vsNomSucursal, viCantTarDisp, viCantTarDispSuc, viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc
			FROM intercard:sucursal AS suc, intercard:lote AS lot , intercard:flujolote AS flulot, intercard:tipotarjeta AS tipotar 
			WHERE suc.clave_sucursal = lot.clave_sucursal 
			AND lot.numerolote = flulot.numerolote
			AND lot.clave_tipotarjeta = tipotar.clave_tipotarjeta
			AND suc.clave_sucursal = psSucursal
			AND lot.fechageneracion >= pdFechaInicial 
			AND lot.fechageneracion <= pdFechaFinal
			ORDER BY suc.clave_sucursal,lot.clave_tipotarjeta
			
			RETURN viSqlErr, vdFechaGen, vsCveSucursal, vsNomSucursal, NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0), viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc WITH RESUME;
			END FOREACH
	END IF;
ELSE
	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
	SELECT lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal
		  ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_imagen --Muestra la cantidad de tarjetas disponibles por imagen
			FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
			WHERE suc1.clave_sucursal = lot1.clave_sucursal 
			AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
			GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
		  ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_suc --Muestra la cantidad de tarjetas disponibles por sucursal
			FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
			WHERE suc1.clave_sucursal = lot1.clave_sucursal 
			AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
			GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo),lot.cantidadtarjetassol, tipotar.descripcion
		  ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
			WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal)  
			AS tot_sol_suc
	INTO vdFechaGen, vsCveSucursal, vsNomSucursal, viCantTarDisp, viCantTarDispSuc, viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc
	FROM intercard:sucursal AS suc, intercard:lote AS lot , intercard:flujolote AS flulot, intercard:tipotarjeta AS tipotar 
	WHERE suc.clave_sucursal = lot.clave_sucursal 
	AND lot.numerolote = flulot.numerolote 
	AND lot.clave_tipotarjeta = tipotar.clave_tipotarjeta
	AND lot.fechageneracion >= pdFechaInicial 
	AND lot.fechageneracion <= pdFechaFinal
	ORDER BY suc.clave_sucursal,lot.clave_tipotarjeta
	
	RETURN viSqlErr, vdFechaGen, vsCveSucursal, vsNomSucursal, NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0), viCantidadTarjetasSol, vsDescTipoTar, vsTotSolSuc WITH RESUME;
	END FOREACH
	
END IF;
END
END PROCEDURE;