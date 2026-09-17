CREATE PROCEDURE "informix".sp_obtdatostotalesconciliacion(pEstatusSolicitud SMALLINT, pFechaInicial DATE, pFechaFinal DATE)
   RETURNING CHAR(5), SMALLINT, SMALLINT, DECIMAL(12,2), SMALLINT, SMALLINT, SMALLINT, SMALLINT, SMALLINT, DECIMAL(12,2);
   
   DEFINE cCodRet             		CHAR(5);
   DEFINE sql_err             		SMALLINT;
   DEFINE isam_err            		SMALLINT;
   DEFINE error_info          		CHAR(40);

   DEFINE sTotalTokenAsig			SMALLINT;
   DEFINE sTotalTokenEnv			SMALLINT;
   DEFINE dMontoTotCobrado			DECIMAL(12,2);
   DEFINE sDiferenciaEnc			SMALLINT;
   DEFINE sTotalRegistros			SMALLINT;
   DEFINE sConNomina				SMALLINT;
   DEFINE sSinNomina				SMALLINT;
   DEFINE sTotalSolCobradas			SMALLINT;
   DEFINE dMontoTotCobradoCte		DECIMAL(12,2);

   DEFINE dMontoTotalCobro 			DECIMAL(12,2);
   DEFINE cTokenAsignado 			CHAR(10);
   DEFINE sEstatusSolicitud 		SMALLINT;
   DEFINE sEstatusConciliacion 		CHAR(13);
   
   DEFINE cNumCte 					  CHAR(9);
   DEFINE cSolicitud 				  CHAR(10);
   DEFINE cFolioSucursal 			  CHAR(16);
   DEFINE cTipoPersona 				  CHAR(2); 
   DEFINE xnumcte						CHAR(9);
   DEFINE xsolicitud					CHAR(10);
   DEFINE xfolio						CHAR(16);
    DEFINE xns_token					CHAR(10);

   LET sTotalTokenAsig			= 0;
   LET sTotalTokenEnv			= 0;
   LET dMontoTotCobrado			= 0.00;
   LET sDiferenciaEnc			= 0;
   LET sTotalRegistros			= 0;
   LET sConNomina				= 0;
   LET sSinNomina				= 0;
   LET sTotalSolCobradas		= 0;
   LET dMontoTotCobradoCte		= 0.00;

   LET cCodRet 					  	= '00000';   
   LET dMontoTotalCobro 		  	= 0.00;
   LET cTokenAsignado 			  	= '';
   LET sEstatusSolicitud 		  	= 0;
   LET sEstatusConciliacion 	  	= '';

   LET cNumCte 					  = '';
   LET cSolicitud 				  = '';
   LET cFolioSucursal 			  = '';
   LET cTipoPersona 			  = '';
   LET xnumcte						= '';
   LET xsolicitud					= '';
   LET xfolio						= '';
   LET xns_token					= '';
   
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, sTotalTokenAsig, sTotalTokenEnv, dMontoTotCobrado, sDiferenciaEnc, sTotalRegistros, sConNomina, sSinNomina, sTotalSolCobradas, dMontoTotCobradoCte;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/tmp/sp_obtdatostotalesconciliacion.out";
	--TRACE ON;
	
	IF pEstatusSolicitud = 0 THEN
		LET cCodRet = '00001';
		RETURN cCodRet, sTotalTokenAsig, sTotalTokenEnv, dMontoTotCobrado, sDiferenciaEnc, sTotalRegistros, sConNomina, sSinNomina, sTotalSolCobradas, dMontoTotCobradoCte;
	END IF;
	
	IF pEstatusSolicitud <> -1 THEN
			
		FOREACH 	
			SELECT cob.numcte, cob.solicitud, cob.folio_suc, cob.monto_tot, cob.t_persona, cob.id_status, 
		   tkn.ns_token, tkn.id_status 
			INTO cNumCte, cSolicitud, cFolioSucursal, dMontoTotalCobro, cTipoPersona, sEstatusConciliacion,  cTokenAsignado, sEstatusSolicitud
			FROM bdibpi: "informix".tkn_solcobranza cob, bdibpi:"informix".bpi_tokensolicitud tkn, bdibpi:"informix".tkn_envios env
			WHERE cob.id_status = pEstatusSolicitud AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '01'
			AND tkn.solicitud = cob.solicitud
			AND env.solicitud = cob.solicitud

			UNION ALL

			SELECT cob.numcte, cob.solicitud, cob.folio_suc, cob.monto_tot, cob.t_persona, cob.id_status,
			tkn.ns_token, tkn.id_status 
			FROM bdibpi:"informix".tkn_solcobranza cob, bdibei:"informix".bei_solicitudtoken sol, bdibei:"informix".bei_envios env, bdibei:"informix".bei_tokensolicitud tkn
			WHERE cob.id_status = pEstatusSolicitud AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '02'
			AND sol.solicitud = cob.solicitud
			AND env.solicitud = cob.solicitud
			AND tkn.solicitud = cob.solicitud
			ORDER BY cob.t_persona ASC
			
			if(cTipoPersona='02' AND NVL(cTokenAsignado,'') <> '') 
			  then
				 SELECT MIN(ns_token) INTO xns_token  FROM  bdibei:bei_tokensolicitud where solicitud = cSolicitud; 
				if (xns_token <> cTokenAsignado)
					then
						LET  dMontoTotalCobro = '0.00';			
				end if;
			end if;	
			

			IF NVL(cTokenAsignado, '') <> '' THEN
				LET sTotalTokenAsig = sTotalTokenAsig + 1;
			END IF;

			IF NVL(sEstatusSolicitud, 0) = 120 THEN
				LET sTotalTokenEnv = sTotalTokenEnv + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET dMontoTotCobrado = dMontoTotCobrado + dMontoTotalCobro;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) = 0.00 THEN
				LET sDiferenciaEnc = sDiferenciaEnc + 1;
			END IF;

			LET sTotalRegistros = sTotalRegistros + 1;

			IF NVL(dMontoTotalCobro, 0.00) = 0.00 THEN
				LET sConNomina = sConNomina + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET sSinNomina = sSinNomina + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET sTotalSolCobradas = sTotalSolCobradas + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET dMontoTotCobradoCte = dMontoTotCobradoCte + dMontoTotalCobro;
			END IF;
		END FOREACH;

		RETURN cCodRet, sTotalTokenAsig, sTotalTokenEnv, dMontoTotCobrado, sDiferenciaEnc, sTotalRegistros, sConNomina, sSinNomina, sTotalSolCobradas, dMontoTotCobradoCte;

	ELSE
	
		FOREACH 	
			SELECT cob.numcte, cob.solicitud, cob.folio_suc, cob.monto_tot, cob.t_persona, cob.id_status, 
		   tkn.ns_token, tkn.id_status 
			INTO cNumCte, cSolicitud, cFolioSucursal, dMontoTotalCobro, cTipoPersona, sEstatusConciliacion,  cTokenAsignado, sEstatusSolicitud
			FROM bdibpi: "informix".tkn_solcobranza cob, bdibpi:"informix".bpi_tokensolicitud tkn, bdibpi:"informix".tkn_envios env
			WHERE cob.id_status IN (100,180,200) AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '01'
			AND tkn.solicitud = cob.solicitud
			AND env.solicitud = cob.solicitud

			UNION ALL

			SELECT cob.numcte, cob.solicitud, cob.folio_suc, cob.monto_tot, cob.t_persona, cob.id_status,
			tkn.ns_token, tkn.id_status 
			FROM bdibpi:"informix".tkn_solcobranza cob, bdibei:"informix".bei_solicitudtoken sol, bdibei:"informix".bei_envios env, bdibei:"informix".bei_tokensolicitud tkn
			WHERE cob.id_status IN (100,180,200) AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '02'
			AND sol.solicitud = cob.solicitud 
			AND env.solicitud = cob.solicitud
			AND tkn.solicitud = cob.solicitud
			
			if(cTipoPersona='02' AND NVL(cTokenAsignado,'') <> '') 
			  then
				 SELECT MIN(ns_token) INTO xns_token  FROM  bdibei:bei_tokensolicitud where solicitud = cSolicitud; 
				if (xns_token <> cTokenAsignado)
					then
						LET  dMontoTotalCobro = '0.00';			
				end if;
			end if;	
			
			
			IF NVL(cTokenAsignado, '') <> '' THEN
				LET sTotalTokenAsig = sTotalTokenAsig + 1;
			END IF;

			IF NVL(sEstatusSolicitud, 0) = 120 THEN
				LET sTotalTokenEnv = sTotalTokenEnv + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET dMontoTotCobrado = dMontoTotCobrado + dMontoTotalCobro;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) = 0.00 THEN
				LET sDiferenciaEnc = sDiferenciaEnc + 1;
			END IF;

			LET sTotalRegistros = sTotalRegistros + 1;

			IF NVL(dMontoTotalCobro, 0.00) = 0.00 THEN
				LET sConNomina = sConNomina + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET sSinNomina = sSinNomina + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET sTotalSolCobradas = sTotalSolCobradas + 1;
			END IF;

			IF NVL(dMontoTotalCobro, 0.00) > 0 THEN
				LET dMontoTotCobradoCte = dMontoTotCobradoCte + dMontoTotalCobro;
			END IF;
		END FOREACH;

		RETURN cCodRet, sTotalTokenAsig, sTotalTokenEnv, dMontoTotCobrado, sDiferenciaEnc, sTotalRegistros, sConNomina, sSinNomina, sTotalSolCobradas, dMontoTotCobradoCte;

	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: 97190322 Leidy L. Quevedo Peñuelas.',
'FECHA: 18/05/2016',
'BD: bdibpi',
'Objetivo: Obtiene los totales del cobro por reeenvio solicitud token';

CREATE PROCEDURE "informix".sp_obtenerdatosconciliacion(pEstatusSolicitud SMALLINT, pFechaInicial DATE, pFechaFinal DATE, pRegistro SMALLINT)
   RETURNING CHAR(5), CHAR(9), CHAR(10), DATE, CHAR(16), DATE, DECIMAL(12,2), CHAR(20), DATE, CHAR(10), DATE, SMALLINT, CHAR(3), CHAR(2);
   
   DEFINE cCodRet             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   
   DEFINE cNumCte 					  CHAR(9);
   DEFINE cSolicitud 				  CHAR(10);
   DEFINE dFechaContratacion 		  DATE;
   DEFINE cFolioSucursal 			  CHAR(16);
   DEFINE dFechaCobro 				  DATE;
   DEFINE dMontoTotalCobro 			  DECIMAL(12,2);
   DEFINE cNumeroCuentaoTarjetaCargo  CHAR(20);
   DEFINE dFechaAsignacion 	 		  DATE; 
   DEFINE cTokenAsignado 			  CHAR(10);
   DEFINE dFechaEnvio 				  DATE; 
   DEFINE sEstatusSolicitud 		  SMALLINT;
   DEFINE sEstatusConciliacion 		  CHAR(13);
   DEFINE cTipoPersona 				  CHAR(2);     
   DEFINE xns_token					CHAR(10);
   
   
   LET cCodRet 					  = '00000';   
   LET cNumCte 					  = '';
   LET cSolicitud 				  = '';
   LET dFechaContratacion 		  = '01-01-1990';
   LET cFolioSucursal 			  = '';
   LET dFechaCobro 				  = '01-01-1990';
   LET dMontoTotalCobro 		  = 0.00;
   LET cNumeroCuentaoTarjetaCargo = '';
   LET dFechaAsignacion 	 	  = '01-01-1990';
   LET cTokenAsignado 			  = '';
   LET dFechaEnvio 				  = '01-01-1990'; 
   LET sEstatusSolicitud 		  = 0;
   LET sEstatusConciliacion 	  = '';
   LET cTipoPersona 			  = '';   
   LET xns_token					= '';
   
BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
		SET DEBUG FILE TO "VerifCte1.err";
		TRACE sql_err||" * "||isam_err||" * "||error_info;
		LET cCodRet = sql_err;
		RETURN cCodRet, cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, dFechaAsignacion, cTokenAsignado, dFechaEnvio, sEstatusSolicitud, sEstatusConciliacion, cTipoPersona;											  
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	--SET DEBUG FILE TO "/home/informix/sp_obtenerDatosConciliacion.out";
	--TRACE ON;
	
	IF pEstatusSolicitud = 0 THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, dFechaAsignacion, cTokenAsignado, dFechaEnvio, sEstatusSolicitud, sEstatusConciliacion, cTipoPersona;											  
	END IF;
	
	IF pEstatusSolicitud <> -1 THEN
			
		FOREACH 	
			SELECT SKIP pRegistro FIRST 20 {+INDEX (bdibpi:"informix".tkn_solcobranza idx_tkn_solcobranza_fSolicitud), +INDEX (bdibei:"informix".bei_envios idx_bei_envios_fEnvios)}
			cob.numcte, cob.solicitud, cob.f_solicitud, cob.folio_suc, cob.f_cobro, cob.monto_tot, cob.cuenta, cob.t_persona, cob.id_status, 
			tkn.f_atencion, tkn.ns_token, tkn.id_status, 
			env.f_envio
			INTO cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, cTipoPersona, sEstatusConciliacion, dFechaAsignacion, cTokenAsignado, sEstatusSolicitud, dFechaEnvio
			FROM bdibpi: "informix".tkn_solcobranza cob, bdibpi:"informix".bpi_tokensolicitud tkn, bdibpi:"informix".tkn_envios env
			WHERE cob.id_status = pEstatusSolicitud AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '01'
			AND tkn.solicitud = cob.solicitud
			AND tkn.numcte = env.numcte

			UNION ALL

			SELECT cob.numcte, cob.solicitud, cob.f_solicitud, cob.folio_suc, cob.f_cobro, cob.monto_tot, cob.cuenta, cob.t_persona, cob.id_status, 
			sol.f_atencion, tkn.ns_token, sol.id_status, 
			env.f_envio
			FROM bdibpi:"informix".tkn_solcobranza cob, bdibei:"informix".bei_solicitudtoken sol, bdibei:"informix".bei_envios env, bdibei:"informix".bei_tokensolicitud tkn
			WHERE cob.id_status = pEstatusSolicitud AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '02'
			AND cob.solicitud = sol.solicitud 
			AND cob.solicitud = env.solicitud
			AND cob.solicitud = tkn.solicitud
			ORDER BY cob.t_persona ASC
			
			if(cTipoPersona='02' AND NVL(cTokenAsignado,'') <> '') 
			  then
				 SELECT MIN(ns_token) INTO xns_token  FROM  bdibei:bei_tokensolicitud where solicitud = cSolicitud; 
				if (xns_token <> cTokenAsignado)
					then
						LET  dMontoTotalCobro = '0.00';			
				end if;
			end if;	
		
			RETURN cCodRet, cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, dFechaAsignacion, cTokenAsignado, dFechaEnvio, sEstatusSolicitud, sEstatusConciliacion, cTipoPersona WITH RESUME;
		END FOREACH;		
		
	ELSE
	
		FOREACH 	
			SELECT SKIP pRegistro FIRST 20
			cob.numcte, cob.solicitud, cob.f_solicitud, cob.folio_suc, cob.f_cobro, cob.monto_tot, cob.cuenta, cob.t_persona, cob.id_status, 
			tkn.f_atencion, tkn.ns_token, tkn.id_status, 
			env.f_envio
			INTO cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, cTipoPersona, sEstatusConciliacion, dFechaAsignacion, cTokenAsignado, sEstatusSolicitud, dFechaEnvio
			FROM bdibpi: "informix".tkn_solcobranza cob, bdibpi:"informix".bpi_tokensolicitud tkn, bdibpi:"informix".tkn_envios env
			WHERE cob.id_status IN (100,180,200) AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '01'
			AND tkn.solicitud = cob.solicitud
			AND tkn.numcte = env.numcte

			UNION ALL

			SELECT cob.numcte, cob.solicitud, cob.f_solicitud, cob.folio_suc, cob.f_cobro, cob.monto_tot, cob.cuenta, cob.t_persona, cob.id_status, 
			sol.f_atencion, tkn.ns_token, sol.id_status, 
			env.f_envio
			FROM bdibpi:"informix".tkn_solcobranza cob, bdibei:"informix".bei_solicitudtoken sol, bdibei:"informix".bei_envios env, bdibei:"informix".bei_tokensolicitud tkn
			WHERE cob.id_status IN (100,180,200) AND cob.f_cobro >= pFechaInicial AND cob.f_cobro <= pFechaFinal AND cob.t_persona = '02'
			AND cob.solicitud = sol.solicitud 
			AND cob.solicitud = env.solicitud
			AND cob.solicitud = tkn.solicitud
			ORDER BY cob.t_persona ASC

			if(cTipoPersona='02' AND NVL(cTokenAsignado,'') <> '') 
			  then
				 SELECT MIN(ns_token) INTO xns_token  FROM  bdibei:bei_tokensolicitud where solicitud = cSolicitud; 
				if (xns_token <> cTokenAsignado)
					then
						LET  dMontoTotalCobro = '0.00';			
				end if;
			end if;	
			
			RETURN cCodRet, cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, dFechaAsignacion, cTokenAsignado, dFechaEnvio, sEstatusSolicitud, sEstatusConciliacion, cTipoPersona WITH RESUME;
		END FOREACH;		
	
	END IF;
	
	IF cNumCte = '' OR cSolicitud = '' THEN
		LET cCodRet = '00002';
		RETURN cCodRet, cNumCte, cSolicitud, dFechaContratacion, cFolioSucursal, dFechaCobro, dMontoTotalCobro, cNumeroCuentaoTarjetaCargo, dFechaAsignacion, cTokenAsignado, dFechaEnvio, sEstatusSolicitud, sEstatusConciliacion, cTipoPersona;
	END IF;
END;
END PROCEDURE
DOCUMENT
'AUTOR: 95419888 Elmer López Valenzuela',
'FECHA: 08/09/2015',
'BD: bdibpi',
'Objetivo: Obtiene los datos del cobro token',
'AUTOR: 97190322 Leidy L. Quevedo Peñuelas',
'FECHA: 17/05/2016',
'BD: bdibpi',
'Objetivo: Obtiene los datos del cobro token';

CREATE PROCEDURE "informix".sp_consultafrases_bpi()
RETURNING CHAR (5), INT, CHAR(100);

	DEFINE iSql_err INT;
	DEFINE cCod_ret CHAR (5);
	DEFINE iIdFrase INT;
	DEFINE vDesc_frase VARCHAR(100);
	DEFINE iMaxID INT;
	DEFINE iIdAleatorio INT;
	

	LET cCod_ret = '00000';
	LET iIdFrase = 0;
	LET vDesc_frase = '';
	LET iMaxID = 0;
	LET iIdAleatorio = 0;


	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iIdFrase, vDesc_frase;
		  END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO '/informix/gaby/spl_consulta-frase/sp_consultafrases_bpi.out';
		--TRACE ON;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;


				SELECT  COUNT(*) INTO iMaxID FROM bdibpi:"informix".bpi_cat_frases;

				
				EXECUTE PROCEDURE bdibpi:"informix".sp_random(1, iMaxID) INTO iIdAleatorio;

				
				SELECT FIRST 1 id_frase, desc_frase INTO iIdFrase, vDesc_frase FROM bdibpi:"informix".bpi_cat_frases WHERE id_frase = iIdAleatorio;

				
				IF NVL(iIdFrase, 0) = 0 THEN
				LET iIdFrase='0';
				LET  vDesc_frase='VALENZUELA';
				END IF;
				
		RETURN cCod_ret, iIdFrase, vDesc_frase;
	END;

END PROCEDURE
DOCUMENT
'CREÓ: 95419888 ELMER LÓPEZ VALENZUELA',
'FECHA: 05/01/2016',
'BD: bdibpi',
'Objetivo: OBTIENE UNA FRASE FALSA ALEATORIA',
'2016-05-05',
'Se modifica flujo dummy',
'Bibiana Gaxiola Verdugo',
'Se modifica para quitar la tabla temporal',
'Gabriela Aguilar, 09-08-2016';

CREATE PROCEDURE "informix".sp_obtenerpreguntasusuario(pNumCliente VARCHAR(9), pLimite INT)
RETURNING CHAR (5), INT, CHAR(50);
	-- Creador: Javier Calderón
	-- Objetivo: Obtiene preguntas del usuario
	-- Solicitó: Diana Castellanos
	-- Fecha: 17/11/2010

	-- Modifico: Manuel Ramos Figueroa
	-- Objetivo: Se modifico para que retorne las preguntas del usuario con excepcion de las asociaciones (id_pregunta = 1010)
	-- Fecha: 10/11/2011

	-- Modifico: René Aldana Hernández
	-- Objetivo: Se modifico para grabar el id_registro en la tabla auxiliar
	-- Fecha: 13/07/2015	
	
	DEFINE iSql_err int;
	DEFINE cCod_ret CHAR (5);
	DEFINE iId_pregunta INT;
	DEFINE vDesc_pregunta VARCHAR(50);
	DEFINE iIdRegistro INTEGER;
	DEFINE iOrdAle INTEGER;
	DEFINE iOrdAleAux INTEGER;
	DEFINE iIdUsuario INTEGER;
	DEFINE xIdUsuario INTEGER;
	DEFINE iLen       INTEGER;

	LET cCod_ret = '00000';
	LET iId_pregunta = 0;
	LET vDesc_pregunta = '';
	LET iIdRegistro = 0;
	LET iOrdAle = 0;
	LET iOrdAleAux = 0;
	LET iLen = 5;

	--SET DEBUG FILE TO "/home/informix/raldana/casos1010/spl/splModAlek/sp_obtenerpreguntasusuario.out";
	--TRACE ON;

	BEGIN
		ON EXCEPTION SET iSql_err
		  IF iSql_err <> 0 THEN
				LET cCod_ret = iSql_err;
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta;
		  END IF ;
		END EXCEPTION ;

		SET LOCK MODE TO WAIT 3;
		SELECT id_usuario INTO iIdUsuario FROM bdibpi:"informix".bpi_usuario 
			WHERE numcliente = pNumCliente AND st_portal = 'activo';
			
		--EXECUTE PROCEDURE sp_random(0, 1000) INTO iIdRegistro;
		LET iIdRegistro = 0;

		-- VALIDA PREGUNTAS
		SELECT COUNT(*) INTO iIdRegistro
				FROM bdibpi:"informix".bpi_resp_seguridad 
				WHERE id_usuario = iIdUsuario
				AND id_pregunta <> 1010;
		
		IF iIdRegistro < 5 THEN
			LET iOrdAle = -1;
			FOREACH
				SELECT id_usuario INTO xIdUsuario FROM bdibpi:"informix".bpi_usuario 
					WHERE numcliente = pNumCliente AND st_portal = 'inactivo'
					ORDER BY id_usuario DESC
				
				SELECT COUNT(*) INTO iIdRegistro
				FROM bdibpi:"informix".bpi_resp_seguridad 
				WHERE id_usuario = xIdUsuario
				AND id_pregunta <> 1010;	
				IF iIdRegistro >= 5 THEN
					LET iOrdAle = 1;
					EXIT FOREACH;
				END IF;
			END FOREACH;
			IF iOrdAle < 0 THEN
				IF (SELECT count(numcte) FROM bdinteg:si_bpiusuarios WHERE numcte = pNumCliente AND id_status='40' ) = 1 THEN
					EXECUTE PROCEDURE bdibpi:sp_actualiza_status_bpi('001', pNumCliente, '50', '0.0.0.0', '5003', 'transBPI');
				END IF;
				LET cCod_ret = '00003';
				RETURN cCod_ret, iId_pregunta, vDesc_pregunta; 
			END IF;
							
			DELETE 	FROM bdibpi:"informix".bpi_resp_seguridad 
			WHERE id_usuario = iIdUsuario
			AND id_pregunta <> '1010';
				
			UPDATE bdibpi:"informix".bpi_resp_seguridad SET id_usuario = iIdUsuario
			WHERE id_usuario = xIdUsuario
			AND id_pregunta <> 1010;			
		END IF;
		
		LET iOrdAle = 0;
		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT pre.id_pregunta, pre.desc_pregunta INTO iId_pregunta, vDesc_pregunta
				FROM 
					bdibpi:"informix".bpi_cat_preguntas pre
					INNER JOIN bdibpi:"informix".bpi_resp_seguridad res ON res.id_pregunta = pre.id_pregunta
				WHERE res.id_usuario = iIdUsuario
				AND res.id_pregunta < 1010
				ORDER BY pre.id_pregunta
		
			LET iOrdAleAux = iOrdAle;
			EXECUTE PROCEDURE sp_random(iOrdAleAux, 100) INTO iOrdAle;

			INSERT INTO bdibpi:"informix".bpi_cat_preguntas_aux (id_ordenamiento, id_pregunta, desc_pregunta, id_registro) 
				VALUES (iOrdAle, iId_pregunta, vDesc_pregunta, iIdUsuario);
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		FOREACH
			SELECT LIMIT pLimite id_pregunta, desc_pregunta 
			INTO iId_pregunta, vDesc_pregunta 
			FROM bdibpi:"informix".bpi_cat_preguntas_aux 
			WHERE id_registro = iIdUsuario
			ORDER BY id_ordenamiento

			RETURN cCod_ret, iId_pregunta, vDesc_pregunta WITH RESUME;
		END FOREACH;

		SET LOCK MODE TO WAIT 3;
		DELETE FROM bdibpi:"informix".bpi_cat_preguntas_aux WHERE id_registro = iIdUsuario;
		
		
	END;
END PROCEDURE;