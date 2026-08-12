CREATE PROCEDURE "informix".sp_consultacoppel_hist(pEmpresa CHAR(3), pNumCte CHAR(20), pRegistros INTEGER )

RETURNING 
	CHAR(6)			AS CodRet,
	CHAR(100)       AS Mensaje,
	DATE			AS FechaMovimiento,
	CHAR(20)		AS ClienteBanco,
	CHAR(20)		AS ClienteCoppel,
	DECIMAL(5,2)	AS EficienciaCoppel,
	SMALLINT		AS HistCoppel,
	CHAR(3)			AS PutualidadCoppel,
	MONEY(14,2)		AS VencidoUdis,
	CHAR(2)			AS SitEspecial,
	SMALLINT		AS Causa,
	CHAR(15)		AS Proceso,
	CHAR(45)		AS Analista,
	INTEGER         AS Registros,
	INTEGER         AS Bandera;


DEFINE iSql_err        	    INTEGER;
DEFINE iIsamErr        	    INTEGER;
DEFINE cErrorInfo      	    CHAR(100);	
	
DEFINE cCodRet 				CHAR(6);
DEFINE cMensaje             CHAR(100);
DEFINE dfechaMovimiento 	DATE;
DEFINE cClienteBanco		CHAR(20);
DEFINE cClienteCoppel		CHAR(20);
DEFINE dcEficienciaCoppel	DECIMAL(5,2);
DEFINE sHistCoppel			SMALLINT;
DEFINE cPutualidadCoppel	CHAR(3);
DEFINE mVencidoUdis			MONEY(14,2);
DEFINE cSitEspecial			CHAR(2);
DEFINE sCausa				SMALLINT;
DEFINE cProceso				CHAR(15);
DEFINE cAnalista			CHAR(45);   
DEFINE iRegistros  			INTEGER;
DEFINE iContador            INTEGER; 
DEFINE iComienzo            INTEGER;            
DEFINE cNumCteRef           CHAR(20);
DEFINE cNumSolicitud        CHAR(20);
DEFINE cFechaInsert         CHAR(10);
DEFINE iBandera             INTEGER;

DEFINE dcSitPago            DECIMAL(5,2);
DEFINE sMesesHis            SMALLINT;
DEFINE cPuntualidad         CHAR(3);
DEFINE mRopa                MONEY(14,2);
DEFINE mMuebles             MONEY(14,2);
DEFINE mPrestamos           MONEY(14,2);
DEFINE cSitEspecialCon      CHAR(2);
DEFINE sCausaSit            SMALLINT;
DEFINE cEjecutivo           CHAR(8);
DEFINE cNomEjecutivo        CHAR(45);
DEFINE iLimit               INTEGER;

DEFINE iSolicitudes1        INTEGER;
DEFINE iSolicitudes2        INTEGER;
DEFINE iSolicitudes3        INTEGER;
DEFINE cCodRetUDI           CHAR(6);
DEFINE dcValorUDI           DECIMAL(14,6);
-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err			= 0;
LET iIsamErr           	= 0;
LET cErrorInfo         	= "";
	
LET cCodRet				= '000000';
LET cMensaje            = 'PROCESO EXITOSO';
LET dfechaMovimiento	= DATE(1);
LET cClienteBanco		= '';
LET cClienteCoppel		= '';
LET dcEficienciaCoppel	= 0;
LET sHistCoppel			= 0;
LET cPutualidadCoppel	= '';
LET mVencidoUdis		= 0;
LET cSitEspecial		= '';
LET sCausa				= 0;
LET cProceso			= '';
LET cAnalista			= '';
LET iRegistros          = 0;
LET iContador           = 0;
LET iComienzo           = 0;
LET cNumCteRef          = '';
LET cNumSolicitud       = ''; 
LET cFechaInsert        = '';
LET iBandera            = 0;

LET dcSitPago    	    = 0;
LET sMesesHis	        = 0;
LET cPuntualidad	    = '';
LET mRopa	            = 0;
LET mMuebles	        = 0;
LET mPrestamos          = 0;
LET cSitEspecialCon     = '';
LET sCausaSit           = 0;
LET cEjecutivo          = '';
LET cNomEjecutivo       = '';
LET iLimit              = 20;

LET iSolicitudes1      = 0;
LET iSolicitudes2      = 0;
LET iSolicitudes3      = 0;
LET cCodRetUDI         = '00000';
LET dcValorUDI         = 0;

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/respaldosbd/felipe/Sps/sp_consultacoppel_hist.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iIsamErr, cErrorInfo
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cErrorInfo;
			RETURN cCodRet, cMensaje, dfechaMovimiento, cClienteBanco, cClienteCoppel, dcEficienciaCoppel, sHistCoppel, cPutualidadCoppel, mVencidoUdis, cSitEspecial, sCausa, cProceso, cAnalista, iRegistros, iBandera WITH RESUME;
		END IF;
	END EXCEPTION;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' AND  TRIM(NVL(pNumCte,'')) <> ''  THEN
	
		IF NVL(pRegistros,-1) >= 0 THEN
			
			LET iRegistros =  pRegistros;
			
			SELECT COUNT(num_solicitud)
			INTO iSolicitudes1
			FROM bdisolic:"informix".ss_solicitudes
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte;
			
			SELECT COUNT(num_solicitud)
			INTO iSolicitudes2
			FROM bdicred:"informix".sd_consultar_infoctecoppel
			WHERE empresa = pEmpresa
			AND numcte = pNumCte;
			
			SELECT COUNT(ejecutivo) 
			INTO iSolicitudes3
			FROM bdisolic:"informix".ss_respuesta_conscoppel_hist						
			WHERE empresa = pEmpresa
			AND numcte = pNumCte;
			
			CALL bdicred:"informix".determina_udi("001", TODAY) RETURNING cCodRetUDI, dcValorUDI;
			
			SELECT numcte_ref 
			INTO cNumCteRef
			FROM bdinteg:"informix".si_cliente
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte;
			
			IF iRegistros < iSolicitudes1 AND NVL(iSolicitudes1,0) <> 0 THEN
			
				FOREACH
					SELECT SKIP pRegistros LIMIT iLimit num_solicitud, fecha_insert 
					INTO cNumSolicitud, cFechaInsert
					FROM bdisolic:"informix".ss_solicitudes
					WHERE empresa = pEmpresa 
					AND numcte = pNumCte
					ORDER BY num_solicitud
					
					LET iContador = iContador + 1;
					
					SELECT situacion_pago, meses_historia, puntualidad, vencidoropa, vencidomuebles, vencidoprestamos, situacion_especial, causa_situacion
					INTO dcSitPago, sMesesHis, cPuntualidad, mRopa, mMuebles, mPrestamos, cSitEspecialCon, sCausaSit
					FROM bdisolic:"informix".ss_resum_scor_fin
					WHERE empresa = pEmpresa 
					AND num_solicitud = cNumSolicitud;
					
					LET dfechaMovimiento= cFechaInsert;
					LET cClienteBanco = pNumCte;
					LET cClienteCoppel = cNumCteRef;
					LET dcEficienciaCoppel=dcSitPago;
					LET sHistCoppel = sMesesHis;
					LET cPutualidadCoppel = cPuntualidad;
					LET cSitEspecial = cSitEspecialCon;
					LET sCausa = sCausaSit;
					LET cProceso = 'ORIGINACIÓN';
					LET cAnalista =  'SISTEMAS';
					LET iRegistros =  pRegistros + iContador;
					LET mVencidoUdis = CASE WHEN dcValorUDI <= 0 THEN 0 ELSE (NVL(mRopa,0) + NVL(mMuebles,0) + NVL(mPrestamos,0)) / dcValorUDI END;
					
					IF iSolicitudes2 = 0 AND iSolicitudes3 = 0 THEN
						IF iRegistros = iSolicitudes1 THEN
							LET iBandera = 1;
						END IF;
					END IF;
					
					RETURN cCodRet, cMensaje, dfechaMovimiento, cClienteBanco, cClienteCoppel, dcEficienciaCoppel, sHistCoppel, cPutualidadCoppel, mVencidoUdis, cSitEspecial, sCausa, cProceso, cAnalista, iRegistros, iBandera WITH RESUME;
				END FOREACH;
			END IF;
			
			IF iContador <> 20 THEN
			
				LET iLimit = 20 - iContador;
				
				IF iRegistros >= iSolicitudes1 AND  iRegistros < (iSolicitudes1 + iSolicitudes2) AND NVL(iSolicitudes2,0) <> 0  THEN
				
					LET iComienzo = iRegistros-iSolicitudes1; 
					
					FOREACH
						SELECT SKIP iComienzo LIMIT iLimit numcte_ref, fecha_envio, num_solicitud 
						INTO cNumCteRef, cFechaInsert, cNumSolicitud
						FROM bdicred:"informix".sd_consultar_infoctecoppel
						WHERE empresa = pEmpresa
						AND numcte = pNumCte
						ORDER BY numcte_ref, num_solicitud

						LET iContador = iContador + 1;
						
						SELECT eficiencia, meseshist, puntualidad, vdoropa, vdomuebles, vdoprestamos, sitespecial, causa
						INTO dcSitPago, sMesesHis, cPuntualidad, mRopa, mMuebles, mPrestamos, cSitEspecialCon, sCausaSit
						FROM bdicred:"informix".sd_graba_respuesta_conscoppel
						WHERE empresa = pEmpresa
						AND numcte = pNumCte
						AND num_solicitud = cNumSolicitud;
						
						LET dfechaMovimiento= cFechaInsert;
						LET cClienteBanco = pNumCte;
						LET cClienteCoppel = cNumCteRef;
						LET dcEficienciaCoppel=dcSitPago;
						LET sHistCoppel = sMesesHis;
						LET cPutualidadCoppel = cPuntualidad;
						LET cSitEspecial = cSitEspecialCon;
						LET sCausa = sCausaSit;
						LET cProceso = 'INCREMENTO';
						LET cAnalista =  'SISTEMAS';
						LET iRegistros =  pRegistros + iContador;
                        LET mVencidoUdis = CASE WHEN dcValorUDI <= 0 THEN 0 ELSE (NVL(mRopa,0) + NVL(mMuebles,0) + NVL(mPrestamos,0)) / dcValorUDI END;
						
						IF iSolicitudes3 = 0 THEN
							IF  iSolicitudes1 = 0  THEN
								IF iRegistros = iSolicitudes2 THEN
									LET iBandera = 1;
								END IF;
							ELSE
								IF iRegistros = (iSolicitudes1 + iSolicitudes2) THEN
									LET iBandera = 1;
								END IF;
							END IF;
						END IF;

						RETURN cCodRet, cMensaje, dfechaMovimiento, cClienteBanco, cClienteCoppel, dcEficienciaCoppel, sHistCoppel, cPutualidadCoppel, mVencidoUdis, cSitEspecial, sCausa, cProceso, cAnalista, iRegistros, iBandera WITH RESUME;
					END FOREACH;
				END IF;
				
				IF iContador <> 20 THEN
					
					LET iLimit = 20 - iContador;

					IF iRegistros >= (iSolicitudes1 + iSolicitudes2) AND  iRegistros < (iSolicitudes1 + iSolicitudes2 + iSolicitudes3) AND NVL(iSolicitudes3,0) <> 0  THEN
						
						LET iComienzo = iRegistros-(iSolicitudes1+ iSolicitudes2);

						FOREACH
							SELECT SKIP iComienzo LIMIT iLimit fecha_consulta, numcte_ref, eficiencia, meseshist, puntualidad, vdoropa, vdomuebles, vdoprestamos, sitespecial, causa, ejecutivo 
							INTO cFechaInsert, cNumCteRef, dcSitPago, sMesesHis, cPuntualidad, mRopa, mMuebles, mPrestamos, cSitEspecialCon, sCausaSit, cEjecutivo
							FROM bdisolic:"informix".ss_respuesta_conscoppel_hist						
							WHERE empresa = pEmpresa
							AND numcte = pNumCte
							ORDER BY  numcte_ref, fecha_consulta
							
							LET iContador = iContador + 1;
							
							SELECT nombre
							INTO cNomEjecutivo
							FROM bdinteg:"informix".si_ejecut
							WHERE  empresa = pEmpresa
							AND ejecutivo = cEjecutivo;
							
							
							LET dfechaMovimiento= cFechaInsert;
							LET cClienteBanco = pNumCte;
							LET cClienteCoppel = cNumCteRef;
							LET dcEficienciaCoppel=dcSitPago;
							LET sHistCoppel = sMesesHis;
							LET cPutualidadCoppel = cPuntualidad;
							LET cSitEspecial = cSitEspecialCon;
							LET sCausa = sCausaSit;
							LET cProceso = 'MESA DE CONTROL';
							LET cAnalista =  TRIM(cNomEjecutivo);
							LET iRegistros =  pRegistros + iContador;
							LET mVencidoUdis = CASE WHEN dcValorUDI <= 0 THEN 0 ELSE (NVL(mRopa,0) + NVL(mMuebles,0) + NVL(mPrestamos,0)) / dcValorUDI END;
							
							IF iSolicitudes1 = 0 AND iSolicitudes2 = 0 THEN
								IF iRegistros = iSolicitudes3 THEN
									LET iBandera = 1;
								END IF;
							ELSE
								IF iRegistros = (iSolicitudes1 + iSolicitudes2 + iSolicitudes3) THEN
									LET iBandera = 1;
								END IF;
							END IF;
						
							RETURN cCodRet, cMensaje, dfechaMovimiento, cClienteBanco, cClienteCoppel, dcEficienciaCoppel, sHistCoppel, cPutualidadCoppel, mVencidoUdis, cSitEspecial, sCausa, cProceso, cAnalista, iRegistros, iBandera WITH RESUME;
							
						END FOREACH;
					
					END IF;
					
					IF iRegistros = 0 THEN
						LET cCodRet = '000002';
						LET cMensaje = 'No se encontraron registros';
					END IF;
					
				END IF;
				
			END IF;
			
		ELSE
			LET cCodRet = '000001';
			LET cMensaje = 'Parametros de entrada incompletos,verifique';
		END IF;
		
	ELSE
		LET cCodRet = '000001';
		LET cMensaje = 'Parametros de entrada incompletos,verifique';
	END IF;

	IF cCodRet <> '000000' THEN
		RETURN cCodRet, cMensaje, dfechaMovimiento, cClienteBanco, cClienteCoppel, dcEficienciaCoppel, sHistCoppel, cPutualidadCoppel, mVencidoUdis, cSitEspecial, sCausa, cProceso, cAnalista, iRegistros, iBandera WITH RESUME;
	END IF;

END;    
END PROCEDURE
