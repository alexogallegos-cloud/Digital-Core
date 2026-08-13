CREATE PROCEDURE "informix".sp_consultas_cac_central_total2(pEmpresa CHAR(3),pSucursal CHAR(4), pFechaInicial DATE, pFechaFinal DATE, pNumSol CHAR(20), pBanCac CHAR(1), pCac_Opt1_1 DECIMAL(5,2), pCac_Opt3_1 INTEGER, pArea CHAR(2), pStatus CHAR(2), pCausa CHAR(3), pProducto CHAR(4), pUsuario CHAR(10))
RETURNING
          CHAR(6),          -- Codigo de Retorno
          INTEGER           -- Total de Registros

DEFINE cNumSolicitud           CHAR(20);
DEFINE cNumCte                 CHAR(20);
DEFINE cSucursal               CHAR(4);
DEFINE dtFechaInsert           DATE;
DEFINE dtFechaModificacion     DATE;
DEFINE dMontoSolicitado        DECIMAL(18,2);
DEFINE cStatusSol              CHAR(2);
DEFINE cTipoSolicitud          CHAR(1);
DEFINE iInfoBuro               INTEGER;
DEFINE cComentarioAut          CHAR(511);
DEFINE iRevisionCac            INTEGER;
DEFINE cNombreCte              CHAR(104);
DEFINE cRFC                    CHAR(13);
DEFINE dSituacionPago          DECIMAL(5,2);
DEFINE iMesesHistoria          INTEGER;
DEFINE dSeccion1               DECIMAL(18,2);
DEFINE dSeccion2               DECIMAL(18,2);
DEFINE dSeccionAux             DECIMAL(18,2);
DEFINE dSumaSecciones          DECIMAL(18,2);
DEFINE iCantidad               INTEGER;
DEFINE icuantos                INTEGER;
DEFINE iSecAux                 INTEGER;
DEFINE cEmpAux                 CHAR(3);
DEFINE iSqlErr                 INTEGER;
DEFINE iIsamErr                INTEGER;
DEFINE cErrorInfo              CHAR(80);
DEFINE cCodRet                 CHAR(6);
DEFINE cMensajeRet             CHAR(80);
DEFINE cFecha                  CHAR(10);
DEFINE cCausa				   CHAR(3);
DEFINE dECValor1			   DECIMAL(5,2);
DEFINE dECValor2			   DECIMAL(5,2);
DEFINE dMACValor1			   DECIMAL(5,2);
DEFINE dMACValor2			   DECIMAL(5,2);
DEFINE dPSValor1			   DECIMAL(5,2);
DEFINE dPSValor2			   DECIMAL(5,2);

DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);
DEFINE iNumRegistros    	   INTEGER;


LET cNumSolicitud              = '';
LET cNumCte                    = '';
LET cSucursal                  = '';
LET dtFechaInsert              = DATE(1);
LET dtFechaModificacion        = DATE(1);
LET dMontoSolicitado           = 0;
LET cStatusSol                 = '';
LET cTipoSolicitud             = '';
LET iInfoBuro                  = 0;
LET cComentarioAut             = '';
LET iRevisionCac               = 0;

LET cNombreCte                 = '';
LET cRFC                       = '';

LET dSituacionPago             = 0;
LET iMesesHistoria             = 0;

LET dSeccion1                  = 0;
LET dSeccion2                  = 0;
LET dSeccionAux                = 0;
LET dSumaSecciones             = 0;
LET iCantidad                  = 0;
LET icuantos                   = 0;
LET iSecAux                    = 0;
LET cEmpAux                    = '';

LET iSqlErr                    = 0;
LET iIsamErr                   = 0;
LET cErrorInfo                 = '';
LET cCodRet                    = '';
LET cMensajeRet                = '';

LET cFecha                     = '';
LET cCausa					   = '';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iNumRegistros         	   = 0;

-- ** HISTORIAL DE CAMBIOS ** --
--  Autor: Roque Solis.
--  Fecha : 02/25/2009.
--  Comentarios: Se quitaron las restricciones de comprobacion de ingresos.
-- Autor: Paul Ivan Quintero Varela.
-- Fecha: 04/05/2009.
-- Comentarios: Se modifica para contemplar en la seleccion principal los 3 tipos de consulta
--                        adicionales (Numero cte, Nombre y Numero de solicitud).
--Autor Roque Solis
--25/05/2009
--Comentarios: Se quitaron las consultas por nombre y numero de cliente,
-- se agrego el rfc
--
--Autor Mohamed Carreon
--07/06/ 2010
--Comentarios: se agrego la causa del status y los filtros para los criterios del cac y mc.
--Autor: Viridiana Osobampo Aguilar
--24/01/ 2011
--Comentarios: Se modifica para que la validacion de eficiencia, meses de historia y puntuacion scoring
--                        solo se realice cuando se trate de una consulta por CAC o MC.

--AUTOR: L. Montserrat LeÃ³n Amador
--FECHA: 19/09/2019
--DESCRIPCION: Se modifica SPL para implementar la eliminaciÃ³n de registros de la tabla paso1 (que ahora es fÃ­sica) a partir del indice id_registro.

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, iNumRegistros;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!

--SET DEBUG FILE TO '/tmp/mfinis/sp_consultas_CAC_central.out';
--TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizÃ³ la consulta al central correctamente.";

 IF NVL(pSucursal,'') = '' THEN
    LET pSucursal = NULL;
 END IF;

 IF pFechaInicial = '' THEN
    LET pFechaInicial = DATE(1);
 END IF;

 IF pFechaFinal = '' THEN
    LET pFechaFinal = CURRENT;
 END IF;

 IF pFechaInicial IS NOT NULL AND pFechaFinal IS NULL THEN
     SELECT valor
           INTO cFecha
           FROM bdicred:"informix".sd_param
          WHERE cod_param='030';
     LET pFechaInicial=DATE(cFecha);
  END IF;

 IF pNumSol = '' THEN
    LET pNumSol = NULL;
 END IF;

--IF pArea <> '' THEN
--- >>> POR CAC O MC <<< ---
---  OBTIENE LOS CRITERIOS DE EFICIENCIA COPPEL

  --  SELECT valor1,valor2
    --  INTO dECValor1,dECValor2
      --FROM bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "01";

---  OBTIENE LOS CRITERIOS DE MESES DE HISTORIA COPPEL
    --SELECT valor1,valor2
    --  INTO dMACValor1,dMACValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "02";

---  OBTIENE LOS CRITERIOS DE PUNTUACION DE SCORING
  --  SELECT valor1,valor2
      --INTO dPSValor1,dPSValor2
      --FROM  bdicred:"informix".sd_criterios_consulta_cac
     --WHERE id_area = pArea
--       AND tpo_criterio = "03";
--END IF;
	
	-- SE LIMPIA TABLA POR USUARIO Y PROCESO
	SET LOCK MODE TO WAIT 3;
	DELETE FROM bdicnweb:"informix".paso1
	WHERE usuario = TRIM(pUsuario);

IF NVL(pNumSol,"")  <> "" THEN 
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto
															  AND aut.revision_cac = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
															  AND aut.status_solicitud = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
															  AND aut.causa_solicitud = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  ---Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  pNumSol
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
--		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= (CASE WHEN pFechaInicial IS NULL THEN sol.fecha_insert ELSE pFechaInicial END)
				AND  sol.fecha_insert <= (CASE WHEN pFechaFinal IS NULL THEN sol.fecha_insert ELSE pFechaFinal END))
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)
--			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND sol.num_producto = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
--			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)			
--			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;
				  
				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
				  
					IF NVL(iInfoBuro,0) = 0 THEN
						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;

				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					--  IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN
						  --IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
								   --(iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
			--IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   --END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;

ELSE
	FOREACH
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- NÃºmero de Solicitud
				sol.numcte,                -- NÃºmero Cte
				sol.sucursal,              -- Sucursal
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.monto_solicitado,      -- Monto Solicitado
				sol.fecha_insert,          -- Fecha Insert
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1))  -- Fecha de Ultima AutorizaciÃ³n
					 THEN NVL(aut.fecha_entrada,date(1))
					 ELSE NVL(esp.fecha_modif,date(1))
				END),
				(CASE WHEN NVL(aut.fecha_entrada,date(1)) >= NVL(esp.fecha_modif,date(1)) -- Comentario de AutorizaciÃ³n
					 THEN NVL(aut.comentario,"")
					 ELSE NVL(esp.comentario,"")
				END),
				NVL(aut.revision_cac,0),
			aut.causa_solicitud,
			sol.num_producto
		   INTO cNumSolicitud,
				cNumCte,
				cSucursal,
				cStatusSol,
				cTipoSolicitud,
				dMontoSolicitado,
				dtFechaInsert,
				dtFechaModificacion,
				cComentarioAut,
				iRevisionCac,
				cCausa,
				cProducto
		  FROM bdisolic:"informix".ss_solicitudes sol
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud
															  AND aut.empresa= sol.empresa
															  AND aut.status_solicitud= sol.status_solicitud
															  AND aut.rowid=(SELECT MAX(aut_aux.rowid)
																					   FROM bdisolic:"informix".ss_autorizacion aut_aux
																					   WHERE aut_aux.empresa= sol.empresa
																					   AND aut_aux.num_solicitud= sol.num_solicitud
																					   AND aut_aux.status_solicitud= sol.status_solicitud)
															  AND aut.ejecutivo_auto= aut.ejecutivo_auto)
	FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa
																	   AND esp.num_solicitud= sol.num_solicitud
																	   AND esp.numcte=sol.numcte
																	   AND esp.secuencia= (SELECT NVL(MAX(esp_aux.secuencia),0)
																							 FROM bdisolic:"informix".ss_autorizacion_especial AS esp_aux
																							WHERE esp_aux.empresa= sol.empresa
																							  AND esp_aux.num_solicitud= sol.num_solicitud
																							  AND esp_aux.numcte= sol.numcte)
																	   AND sol.status_solicitud= esp.status_nvo)
		  --Inner join bdinteg:"informix".si_cliente as cli on (sol.numcte = cli.numcte)
		--LEFT OUTER JOIN bdicred:"informix".sd_criterios_status_causa_cac cri ON (aut.status_solicitud = cri.status AND aut.causa_solicitud = cri.causa AND cri.id_area = pArea)
		 WHERE sol.num_solicitud=  sol.num_solicitud 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud = (CASE WHEN pBanCac = 'N' THEN sol.status_solicitud ELSE 'RT' END) -- Valida si el opciÃ³n de la consulta es CAC, si es asi tendrian que ser solo status "RT"
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND NVL(aut.revision_cac,0) = (CASE WHEN pCac_Opt3_1 = 1 THEN 0 ELSE NVL(aut.revision_cac,0) END)
		   AND sol.sucursal = (CASE WHEN pSucursal IS NULL THEN sol.sucursal ELSE TRIM(pSucursal) END)
		   AND (sol.fecha_insert >= pFechaInicial AND  sol.fecha_insert <= pFechaFinal )
			--AND NVL(cri.id_area,'') = DECODE(pArea,'',NVL(cri.id_area,''),pArea)

			AND NVL(sol.num_producto,'') = DECODE(pProducto,'',NVL(sol.num_producto,''),pProducto)
			AND NVL(aut.status_solicitud,'') = DECODE(pStatus,'',NVL(aut.status_solicitud,''),pStatus)
			AND NVL(aut.causa_solicitud,'') = DECODE(pCausa,'',NVL(aut.causa_solicitud,''),pCausa)

		-- Se valida que el usuario en caso de estar en el status CC tengo su informacion referente a buro correctamente,
		-- En caso contrario no se mostraria en la consulta.

		   IF cStatusSol IN ('CC','BC') THEN
				SELECT COUNT(*)
				  INTO iInfoBuro
				  FROM bdiburo:"informix".br_traslado AS tras
				  INNER JOIN bdiburo:"informix".sb_regreso AS reg ON (tras.num_solicitud = reg.num_solicitud)
				  WHERE tras.num_solicitud = cNumSolicitud;

				IF NVL(iInfoBuro,0) = 0 THEN
					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras 
					INNER JOIN bdiburo:"informix".br_respuesta_aprocesar AS res ON (tras.num_solicitud = res.num_solicitud) 
					WHERE tras.num_solicitud = cNumSolicitud;
					
					IF NVL(iInfoBuro,0) = 0 THEN

						SELECT COUNT(*)
						INTO iInfoBuro
						FROM bdiburo:"informix".br_traslado AS tras 
						INNER JOIN bdiburo:"informix".sb_regreso_2013 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud) 
						WHERE tras.num_solicitud = cNumSolicitud;

						IF NVL(iInfoBuro,0) = 0 THEN
						   CONTINUE FOREACH;
						END IF;

					END IF;
				END IF;
				
				 IF NVL(iInfoBuro,0) = 0 THEN

					SELECT COUNT(*)
					INTO iInfoBuro
					FROM bdiburo:"informix".br_traslado AS tras
					INNER JOIN bdiburo:"informix".sb_regreso_2011 AS reg_2011 ON (tras.num_solicitud = reg_2011.num_solicitud)
					WHERE tras.num_solicitud = cNumSolicitud;

					IF NVL(iInfoBuro,0) = 0 THEN
					   CONTINUE FOREACH;
					END IF;

				 END IF;

		   END IF;

		-- Se obtienen los datos de la informaciÃ³n crediticia en COPPEL/BANCOPPEL.

				   SELECT ef.situacion_pago,         -- Situacion Pago
						   ef.meses_historia          -- Meses Historia
					  INTO dSituacionPago,
						   iMesesHistoria
					  FROM bdisolic:"informix".ss_resum_scor_fin AS ef
					 WHERE ef.empresa= pEmpresa
					   AND ef.num_solicitud= cNumSolicitud;
					   
					   -- SE VALIDA QUE EL PRODUCTO NO SEA DE REESTRUCTURA DE TARJETAS DE CRÃDITO

					 -- IF (dSituacionPago IS NULL AND iMesesHistoria IS NULL) AND NVL(cProducto,'') <> '6011' THEN
						--CONTINUE FOREACH;
					  --END IF;

					--IF NVL(pArea, "") <> "" THEN

						--  IF NOT ((dSituacionPago >= dECValor1 AND dSituacionPago <= dECValor2) AND
							--	   (iMesesHistoria >= dMACValor1 AND iMesesHistoria <=dMACValor2)) AND NVL(cProducto,'') <> '6011' THEN

								--CONTINUE FOREACH;
					  --END IF;

					--END IF;
		-- Se obtiene las puntuaciones del scoring que se le realizÃ³ al cliente.
		SELECT NVL(SUM(DECODE(seccion, '1', NVL(evaluacion,0), 0)),0) AS seccion1,
			   NVL(SUM(DECODE(seccion, '2', NVL(evaluacion,0), 0)),0) AS seccion2,
			   NVL(SUM(NVL(evaluacion, 0)),0) AS suma,
			   COUNT(num_solicitud) AS cantidad
		  INTO dSeccion1,    
			   dSeccion2,
			   dSumaSecciones,
			   iCantidad
		  FROM bdisolic:"informix".ss_resumen_scoring
		 WHERE empresa= pEmpresa
		   AND num_solicitud = cNumSolicitud
		   AND seccion IN ('1','2');

		IF iCantidad <> 2 THEN

			   LET dSeccion1= 0;
			   LET dSeccion2= 0;
			   LET dSumaSecciones= 0;

			SELECT nvl(SUM(nvl(puntuacion,0)),0) AS seccion1,
				   COUNT(*) AS cuantos
			  INTO dSeccion1, icuantos
			  FROM bdisolic:"informix".ss_scoring_financ sf, bdisolic:"informix".ss_resum_scor_fin rsf
			 WHERE rsf.empresa = pEmpresa
			   AND rsf.num_solicitud = cNumSolicitud
			   AND rsf.empresa = sf.empresa
			   AND UPPER(sf.tp_solicitud) = UPPER(cTipoSolicitud)
			   AND NVL(sf.circulo_credito,'') = NVL(evalua_cc,'')
			   AND sf.min_mes_hist <= rsf.meses_historia
			   AND sf.max_mes_hist >= rsf.meses_historia
			   AND sf.min_porc_pago <= rsf.situacion_pago
			   AND sf.max_porc_pago >= rsf.situacion_pago;

		   FOREACH
				SELECT sg.empresa, sg.seccion,
					   decode(nvl(sg.agrupar, ''),'', SUM(nvl(dc.valor,0)), MAX(nvl(dc.valor,0))) AS suma
				  INTO cEmpAux, iSecAux, dSeccionAux
				  FROM bdisolic:"informix".ss_detalle_scoring dc, bdisolic:"informix".ss_scoring_grupo sg
				 WHERE sg.empresa = dc.empresa
				   AND sg.grupo = dc.grupo
				   AND sg.seccion = dc.seccion
				   AND dc.num_solicitud = cNumSolicitud
				   AND dc.seccion = '2'
				   AND dc.empresa = pEmpresa
			  GROUP BY sg.empresa, sg.seccion, sg.agrupar

				LET dSeccion2= dSeccion2 + dSeccionAux;
				LET dSumaSecciones= dSeccion1 + dSeccion2;
	   END FOREACH;

	   END IF;

	   --IF NVL(pArea,"") <> "" THEN
		--	IF NOT (dSumaSecciones >= dPSValor1 AND dSumaSecciones <= dPSValor2) AND NVL(cProducto,'') <> '6011' THEN
					--CONTINUE FOREACH;
			--END IF;
	   ---END IF;

	 -- Se obtiene el nombre del cliente
		SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
												  TRIM(nvl(a.nombre2,'')) ||' '||
												  TRIM(nvl(a.apell_paterno,'')) ||' '||
												  TRIM(nvl(a.apell_materno,'')),
												  TRIM(a.razon_social)),
			   rfc
		  INTO cNombreCte, cRFC
		  FROM bdinteg:"informix".si_cliente a
		 WHERE a.numcte = cNumCte;

			--RQM 08 008 JMAH
	IF TRIM(cStatusSol) = "AT"  THEN
		
		IF EXISTS (SELECT num_credito FROM bdisolic:"informix".ss_solautorizadasgte WHERE num_credito =cNumSolicitud) THEN
			LET cComentarioAut = "Solicitud Autorizada GTE"||"-"||TRIM(cComentarioAut);
		END IF	
	END IF
	
		INSERT INTO bdicnweb:"informix".paso1(num_solicitud, num_cte, nombre_cte, rfc, sucursal, fecha_solic, fecha_cambio_stsuts, importe_linea, eficiencia, historial, puntos_seccion, puntos_2da_seccion, status_solicitud, observaciones_ant, suma_secciones, causas_status, usuario) 
			VALUES(NVL(cNumSolicitud,''),NVL(cNumCte,''),NVL(cNombreCte,''),NVL(cRFC,''),NVL(cSucursal,''),dtFechaInsert,dtFechaModificacion,NVL(dMontoSolicitado,0),
			   NVL(dSituacionPago,0),NVL(iMesesHistoria,0),NVL(dSeccion1,0),NVL(dSeccion2,0),NVL(cStatusSol,''),NVL(cComentarioAut,''), dSumaSecciones, NVL(cCausa,''), pUsuario);

	END FOREACH;
END IF

	SELECT COUNT (*) 
	INTO iNumRegistros
	FROM bdicnweb:"informix".paso1 
	WHERE usuario = pUsuario;

	RETURN NVL(cCodRet,''), NVL(iNumRegistros,0);

END
END PROCEDURE;