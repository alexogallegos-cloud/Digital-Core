CREATE PROCEDURE "informix".sp_consultas_cac_central_total(pEmpresa          CHAR(3),
                                                     pSucursal         CHAR(4),
                                                     pFechaInicial     DATE,
                                                     pFechaFinal       DATE,
                                                     pNumSol           CHAR(20),
                                                     pBanCac           CHAR(1),
                                                     pCac_Opt1_1       DECIMAL(5,2),
                                                     pCac_Opt3_1       INTEGER,
                                                     pArea             CHAR(2),
                                                     pStatus           CHAR(2),
                                                     pCausa            CHAR(3),
													 pProducto         CHAR(4))
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
DEFINE iTotReg                 INTEGER;
DEFINE iMeseshist              INTEGER;
DEFINE cProducto               CHAR(4);

DEFINE sol_pBanCac				CHAR(20);
DEFINE sol_pCac_Opt3_1			CHAR(20);
DEFINE sol_sucursal				CHAR(20);
DEFINE sol_pProducto			CHAR(20);
DEFINE sol_status				CHAR(20);
DEFINE sol_causa				CHAR(20);
DEFINE sol_InfoBuro				CHAR(20);
DEFINE sol_InfoBuro2			CHAR(20);
DEFINE sol_resum				CHAR(20);
DEFINE sol_conteo				INTEGER;
DEFINE count_InfoBuro			INTEGER;
DEFINE count_InfoBuro2			INTEGER;
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
LET cCausa					   = '10';
LET dECValor1				   = 0.0;
LET dECValor2				   = 0.0;
LET dMACValor1				   = 0.0;
LET dMACValor2				   = 0.0;
LET dPSValor1				   = 0.0;
LET dPSValor2				   = 0.0;
LET iMeseshist                 = 0;
LET cProducto                  = "";
LET iTotReg                    = 0;


LET sol_pBanCac				= '';
LET sol_pCac_Opt3_1			= '';
LET sol_sucursal			= '';
LET sol_pProducto			= '';
LET sol_status				= '';
LET sol_causa				= '';
LET sol_InfoBuro			= '';
LET sol_InfoBuro2			= '';
LET sol_resum				= '';
LET sol_conteo 				= 0;
LET count_InfoBuro			= 0;
LET count_InfoBuro2			= 0;



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

BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet,iTotReg;
   END IF;
END EXCEPTION;

--  Se genera archivo DEBUG!
----SET DEBUG FILE TO '/home/sysifx/Viridiana/sp_consultas_CAC_central.out';
----TRACE ON;
-- SET DEBUG FILE TO '/informix/Israel/sp_consultas_cac_central_total_itd.out';
-- TRACE ON;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET cCodRet= "000000";
LET cMensajeRet= "Se realizo la consulta al central correctamente.";

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

IF NVL(pNumSol,"")  <> "" THEN 

		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.num_solicitud=  pNumSol 
		   AND sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
---		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1; 
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	

			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
				
ELSE
		-- Se obtienen los datos de la solicitud.
		 SELECT
				sol.num_solicitud,         -- Numero de Solicitud
				sol.numcte,                -- Numero Cte
				sol.status_solicitud,      -- Status Solicitud
				sol.tipo_solicitud,        -- Tipo Solicitud
				sol.num_producto,
				aut.revision_cac,
				sol.sucursal,
				aut.causa_solicitud
			FROM bdisolic:"informix".ss_solicitudes sol
			JOIN bdisolic:"informix".ss_autorizacion aut ON (aut.num_solicitud= sol.num_solicitud AND aut.empresa= sol.empresa  AND aut.status_solicitud= sol.status_solicitud)
			FULL OUTER JOIN bdisolic:"informix".ss_autorizacion_especial esp ON (esp.empresa= sol.empresa AND esp.num_solicitud= sol.num_solicitud 
				AND esp.numcte=sol.numcte and sol.status_solicitud= esp.status_nvo)
		 WHERE sol.empresa= pEmpresa
		   AND sol.status_solicitud NOT IN ("PC","AN")
		   AND sol.fecha_insert between pFechaInicial and pFechaFinal
		INTO temp paso1 ;
				   
--			SELECT count (*) INTO v_conteo FROM paso1

			
			IF pBanCac <> 'N' THEN
				---- Si es diferente de N solo se dejan RT
				FOREACH
					SELECT num_solicitud
					INTO sol_pBanCac
					FROM paso1
					WHERE status_solicitud <> 'RT'		

					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pBanCac;
					COMMIT;
				END FOREACH;
				
			END IF;
		
			IF pCac_Opt3_1 = 1 THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pCac_Opt3_1
					FROM paso1
					WHERE revision_cac = 0
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pCac_Opt3_1;
					COMMIT;
				END FOREACH;
			END IF;
	
			IF pSucursal IS NOT NULL THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_sucursal
					FROM paso1
					WHERE sucursal <> pSucursal
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_sucursal;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pProducto <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_pProducto
					FROM paso1
					WHERE num_producto <> pProducto
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_pProducto;
					COMMIT;
				END FOREACH;
			END IF;				

			IF pStatus <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_status
					FROM paso1
					WHERE status_solicitud <> pStatus
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_status;
					COMMIT;
				END FOREACH;
			END IF;	

			IF pCausa <> '' THEN			
				FOREACH
					SELECT num_solicitud
					INTO sol_causa
					FROM paso1
					WHERE causa_solicitud <> pCausa
				
					BEGIN;
					DELETE FROM paso1 WHERE num_solicitud = sol_causa;
					COMMIT;
				END FOREACH;
			END IF;	
			
			SELECT count (a.num_solicitud)
			INTO count_InfoBuro  
			FROM paso1 a
			join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
			LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
			WHERE status_solicitud in ('BC','CC');
			
			IF count_InfoBuro > 0 THEN
				FOREACH WITH HOLD
					SELECT a.num_solicitud
						INTO sol_InfoBuro  
						FROM paso1 a
						join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
						LEFT OUTER JOIN  bdiburo:"informix".sb_regreso AS reg ON (a.num_solicitud = reg.num_solicitud)
						WHERE status_solicitud in ('BC','CC')
					
					BEGIN;
						DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro;
					COMMIT;
				
				END FOREACH;
			END IF;
			
				
				SELECT count (a.num_solicitud)
				INTO count_InfoBuro2  
				FROM paso1 a
				join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
				LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
				WHERE status_solicitud in ('BC','CC');
				
				IF count_InfoBuro2 > 0 THEN 
			
					FOREACH WITH HOLD
						SELECT a.num_solicitud
							INTO sol_InfoBuro2  
							FROM paso1 a
							join bdiburo:"informix".br_traslado AS tras on (a.num_solicitud = tras.num_solicitud)
							LEFT OUTER JOIN  bdiburo:"informix".sb_regreso_2011 AS reg ON (a.num_solicitud = reg.num_solicitud)
							WHERE status_solicitud in ('BC','CC')
						
						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_InfoBuro2;
						COMMIT;
					
					END FOREACH;
				END IF;
				
			   SELECT count (a.num_solicitud)
				  INTO sol_conteo
				  FROM paso1 a 
				  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
				 WHERE ef.situacion_pago IS NULL AND ef.meses_historia IS NULL AND a.num_producto <> '6011';
			
				IF sol_conteo > 0 THEN 
					FOREACH WITH HOLD			
						SELECT a.num_solicitud
						  INTO sol_resum
						  FROM paso1 a 
						  join bdisolic:"informix".ss_resum_scor_fin ef on (a.num_solicitud = ef.num_solicitud)
						 WHERE ef.situacion_pago  AND ef.meses_historia AND a.num_producto <> '6011'

						BEGIN;
							DELETE FROM paso1 WHERE num_solicitud = sol_resum;
						COMMIT;
						  
					END FOREACH;
				END IF;
				
		Select count (*) INTO iTotReg FROM paso1;

	RETURN cCodRet,iTotReg;
			
END IF

END

END PROCEDURE;