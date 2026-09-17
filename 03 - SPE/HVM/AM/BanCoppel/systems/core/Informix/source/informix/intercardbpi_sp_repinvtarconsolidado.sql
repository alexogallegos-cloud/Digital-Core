CREATE PROCEDURE "informix".sp_repinvtarconsolidado(
psSucursal CHAR (5),
pdFechaInicial DATE,
pdFechaFinal DATE
)

RETURNING INTEGER AS codret, DATETIME YEAR TO FRACTION(5) AS fecha, CHAR(5) AS numero_sucursal, CHAR(50) AS nombre_sucursal, INTEGER AS numero_lote, CHAR(10) AS cve_tipo_tarjeta, CHAR(18) AS desc_tipo_tarjeta,
		  INTEGER AS tot_rec_imagen, INTEGER AS tot_rec_suc, CHAR(3) AS codigo_flujo, INTEGER AS tot_pend_imagen, INTEGER AS tot_pend_suc, INTEGER AS cant_tar_asig, INTEGER AS cant_tar_asig_suc,
		  INTEGER AS cant_tar_can, INTEGER AS cant_tar_can_suc, INTEGER AS cant_tar_disp, INTEGER AS cant_tar_disp_suc;

--****************************************************************************************************
-- DESCRIPCION: Obtiene informacion de tarjetas recibidas,pendientes,asignadas,canceladas,disponibles en sucursal por imagen y total general
-- AUTOR : Rochin Rocha Edgar Ivan 
-- AUTOR : Mohamed Hassan Carreon Perez
-- FECHA : 10/11/2008
-- BD: Intercard
-- SISTEMA : Reporte Inventario De Tarjetas
--****************************************************************************************************

DEFINE vdFecha DATETIME YEAR TO FRACTION (5);     --Fecha De Consulta
DEFINE vsNumSucursal CHAR(5);                     --Numero De Sucursal
DEFINE vsNombreSuc CHAR(50);                      --Nombre De Sucursal
DEFINE viNumLote INTEGER;                         --Numero De Lote
DEFINE vsClaveTipoTar CHAR(10);                   --Imagen De Tarjeta
DEFINE vsDescTipoTar CHAR(18);                    --Descripcion Tipo Tarjeta
DEFINE viTotRecImagen INTEGER;                    --Total De Tarjetas Recibidas Por Imagen
DEFINE viTotRecSuc INTEGER;                       --Total De Tarjetas Recibidas Por Sucursal
DEFINE viTotPendImagen INTEGER;                   --Total De Tarjetas Pendientes Por Imagen   
DEFINE viTotPendSuc INTEGER;                      --Total De Tarjetas Pendientes Por Sucursal
DEFINE vsCodFlujo CHAR(3);                        --Indica Si Fue Recibido El Lote En Sucursal
DEFINE viCantTarAsig INTEGER;                     --Cantidad De Tarjetas Asignadas Por Imagen
DEFINE viCantTarAsigSuc INTEGER;                  --Cantidad De Tarjetas Asignadas Por Sucursal                     
DEFINE viCantTarCan INTEGER;                      --Cantidad De Tarjetas Canceladas Por Imagen
DEFINE viCantTarCanSuc INTEGER;                   --Cantidad De tarjetas Canceladas Por Sucursal
DEFINE viCantTarDisp INTEGER;                     --Cantidad De Tarjetas Disponibles
DEFINE viCantTarDispSuc INTEGER;                  --Cantidad De Tarjetas Disponibles Por Sucursal
DEFINE visqlerr INTEGER ;

LET vdFecha = CURRENT;
LET vsNumSucursal = '';
LET vsNombreSuc = '';
LET viNumLote = '';
LET vsClaveTipoTar = '';
LET vsDescTipoTar = '';
LET viTotRecImagen = 0; 
LET viTotRecSuc = 0;
LET viTotPendImagen = 0;
LET viTotPendSuc = 0; 
LET vsCodFlujo = '';
LET viCantTarAsig = 0;
LET viCantTarAsigSuc = 0;
LET viCantTarCan = 0;
LET viCantTarCanSuc = 0;
LET viCantTarDisp = 0;
LET viCantTarDispSuc = 0;
LET visqlerr = 0; 

--set debug file to "/tmp/sp_repinvtar.out";
--Trace on;

BEGIN

ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
    IF visqlerr <> 0 THEN
    RETURN visqlerr, vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, viTotRecImagen, viTotRecSuc, vsCodFlujo, viTotPendImagen, viTotPendSuc, viCantTarAsig, viCantTarAsigSuc, viCantTarCan, viCantTarCanSuc, viCantTarDisp, viCantTarDispSuc ;
	END IF ; 
END EXCEPTION ;

IF(pdFechaInicial = "") OR (pdFechaInicial IS NULL) THEN --En caso que la fecha inicial venga vacia o nulo marcara error
    LET visqlerr = 1 ;
    RETURN visqlerr, vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, NVL(viTotRecImagen,0), viTotRecSuc, vsCodFlujo, NVL(viTotPendImagen,0), NVL(viTotPendSuc,0), NVL(viCantTarAsig,0),
               NVL(viCantTarAsigSuc,0), NVL(viCantTarCan,0), NVL(viCantTarCanSuc,0), NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0);
END IF ;

IF (pdFechaFinal = "") OR (pdFechaFinal IS NULL) THEN --En caso que la fecha final venga vacia o nulo marcara error
    LET visqlerr = 2;
    RETURN visqlerr, vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, NVL(viTotRecImagen,0), viTotRecSuc, vsCodFlujo, NVL(viTotPendImagen,0), NVL(viTotPendSuc,0), NVL(viCantTarAsig,0),
               NVL(viCantTarAsigSuc,0), NVL(viCantTarCan,0), NVL(viCantTarCanSuc,0), NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0);
END IF ;


IF(psSucursal <> '') AND (psSucursal IS NOT NULL) THEN --Valida que la consulta sea por una sucursal especifica
	IF EXISTS(SELECT clave_sucursal, enoperacion FROM intercard:sucursal WHERE clave_sucursal = psSucursal AND enoperacion = 'V') THEN --Valida que la sucursal este activa
			SET ISOLATION TO DIRTY READ ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
			SELECT lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal, lot.numerolote, lot.clave_tipotarjeta, tipotar.descripcion
				 ,(SELECT SUM(lot1.cantidadtarjetassol) AS tot_rec_imagen --Muestra la cantidad de tarjetas recibidas por imagen
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
				 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = 'RES')  
				   AS tot_rec_suc, flulot.codflujo --Muestra la cantidad de tarjetas recibidas por sucursal
				 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND flulot1.codflujo <> 'RES')  	
				   AS tot_pend_imagen --Muestra la cantidad de tarjetas pendientes por imagen
				 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo <> 'RES')  	
				   AS tot_pend_suc --Muestra la cantidad de tarjetas pendientes por sucursal
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_asig_imagen --Muestra la cantidad de tarjetas asignadas por imagen
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'SIA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_asig_suc --Muestra la cantidad de tarjetas asignadas por sucursal
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'SIA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_can_imagen --Muestra la cantidad de tarjetas canceladas por imagen
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'NOA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_can_suc --Muestra la cantidad de tarjetas canceladas por sucursal
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'NOA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)	
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_imagen --Muestra la cantidad de tarjetas disponibles por imagen
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
				 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_suc --Muestra la cantidad de tarjetas disponibles por sucursal
				   FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
				   WHERE suc1.clave_sucursal = lot1.clave_sucursal 
				   AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
				   GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)	
			INTO vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, viTotRecImagen, viTotRecSuc, vsCodFlujo, viTotPendImagen, viTotPendSuc, viCantTarAsig, viCantTarAsigSuc, viCantTarCan, viCantTarCanSuc, viCantTarDisp, viCantTarDispSuc
			FROM intercard:sucursal AS suc, intercard:lote AS lot , intercard:flujolote AS flulot, intercard:tipotarjeta AS tipotar 
			WHERE suc.clave_sucursal = lot.clave_sucursal    
			AND lot.numerolote = flulot.numerolote
			AND suc.clave_sucursal = psSucursal
			AND tipotar.clave_tipotarjeta = lot.clave_tipotarjeta
			AND lot.fechageneracion >= pdFechaInicial 
			AND lot.fechageneracion <= pdFechaFinal
			GROUP BY lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal, lot.numerolote, lot.clave_tipotarjeta, flulot.codflujo, tipotar.descripcion
			ORDER BY suc.clave_sucursal,lot.clave_tipotarjeta
			
			RETURN visqlerr, vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, NVL(viTotRecImagen,0), viTotRecSuc, vsCodFlujo, NVL(viTotPendImagen,0), NVL(viTotPendSuc,0), NVL(viCantTarAsig,0),
				   NVL(viCantTarAsigSuc,0), NVL(viCantTarCan,0), NVL(viCantTarCanSuc,0), NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0)	WITH RESUME;
			
			END FOREACH
		END IF;

ELSE
		SET ISOLATION TO DIRTY READ ;
		SET LOCK MODE TO WAIT 3;
		FOREACH
		SELECT lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal, lot.numerolote, lot.clave_tipotarjeta, tipotar.descripcion
		     ,(SELECT SUM(lot1.cantidadtarjetassol) AS tot_rec_imagen --Muestra la cantidad de tarjetas recibidas por imagen
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
			 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
               WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = 'RES')  
               AS tot_rec_suc, flulot.codflujo --Muestra la cantidad de tarjetas recibidas por sucursal
			 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
               WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND flulot1.codflujo <> 'RES')  	
			   AS tot_pend_imagen --Muestra la cantidad de tarjetas pendientes por imagen
			 ,(SELECT SUM(lot1.cantidadtarjetassol) FROM intercard:sucursal AS suc1, intercard:lote AS lot1, intercard:flujolote AS flulot1 
               WHERE suc1.clave_sucursal = lot1.clave_sucursal AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo <> 'RES')  	
			   AS tot_pend_suc --Muestra la cantidad de tarjetas pendientes por sucursal
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_asig_imagen --Muestra la cantidad de tarjetas asignadas por imagen
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'SIA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_asig_suc --Muestra la cantidad de tarjetas asignadas por sucursal
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'SIA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_can_imagen --Muestra la cantidad de tarjetas canceladas por imagen
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'NOA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_can_suc --Muestra la cantidad de tarjetas canceladas por sucursal
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatusasignada = 'NOA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)	
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_imagen --Muestra la cantidad de tarjetas disponibles por imagen
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.clave_tipotarjeta = lot.clave_tipotarjeta AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, lot1.clave_tipotarjeta, flulot.codflujo)
			 ,(SELECT COUNT(lot1.cantidadtarjetassol) AS tar_dis_suc --Muestra la cantidad de tarjetas disponibles por sucursal
               FROM intercard:sucursal AS suc1, intercard:lote AS lot1 , intercard:flujolote AS flulot1, intercard:tarjeta AS tar1  
               WHERE suc1.clave_sucursal = lot1.clave_sucursal 
               AND lot1.numerolote = flulot1.numerolote AND suc1.clave_sucursal = suc.clave_sucursal AND flulot1.codflujo = "RES" AND lot1.numerolote = tar1.numerolote AND tar1.codstatustarjeta = 'ACT' AND tar1.codstatusasignada = 'NOA'
               GROUP BY suc1.clave_sucursal, suc1.nombre_sucursal, flulot.codflujo)	
		INTO vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, viTotRecImagen, viTotRecSuc, vsCodFlujo, viTotPendImagen, viTotPendSuc, viCantTarAsig, viCantTarAsigSuc, viCantTarCan, viCantTarCanSuc, viCantTarDisp, viCantTarDispSuc
		FROM intercard:sucursal AS suc, intercard:lote AS lot , intercard:flujolote AS flulot, intercard:tipotarjeta AS tipotar
		WHERE suc.clave_sucursal = lot.clave_sucursal    
		AND lot.numerolote = flulot.numerolote
		AND tipotar.clave_tipotarjeta = lot.clave_tipotarjeta
		AND lot.fechageneracion >= pdFechaInicial 
		AND lot.fechageneracion <= pdFechaFinal
		GROUP BY lot.fechageneracion, suc.clave_sucursal, suc.nombre_sucursal, lot.numerolote, lot.clave_tipotarjeta, flulot.codflujo, tipotar.descripcion
		ORDER BY suc.clave_sucursal,lot.clave_tipotarjeta
		
		RETURN visqlerr, vdFecha, vsNumSucursal, vsNombreSuc, viNumLote, vsClaveTipoTar, vsDescTipoTar, NVL(viTotRecImagen,0), viTotRecSuc, vsCodFlujo, NVL(viTotPendImagen,0), NVL(viTotPendSuc,0), NVL(viCantTarAsig,0),
               NVL(viCantTarAsigSuc,0), NVL(viCantTarCan,0), NVL(viCantTarCanSuc,0), NVL(viCantTarDisp,0), NVL(viCantTarDispSuc,0)	WITH RESUME;
		
		END FOREACH	
END IF;

END
END PROCEDURE;