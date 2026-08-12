CREATE PROCEDURE "informix".sp_registra_unica(pGrupoUnica CHAR(5))

RETURNING 
		CHAR(100) AS Proceso,
		CHAR(6)   AS CodRet,
		CHAR(100) AS DataError;
		
	 --DEFINICION DE VARIABLES--
	DEFINE iSqlErr			INTEGER;
	DEFINE iSamErr			INTEGER;
	DEFINE cProceso			CHAR(100);
	DEFINE cCodRet      	CHAR(5);
	DEFINE cVarDataErr		CHAR(100);
    DEFINE cAnioMesAct      CHAR(6);
	DEFINE cAnioMesUni      CHAR(6);
	DEFINE iStatus_Ejec_ivr INTEGER;
	DEFINE iStatus_Ejec_bpi INTEGER;
	DEFINE iStatus_Ejec_sol INTEGER;	
	DEFINE iStatus_Ejec_cap INTEGER;
	DEFINE iStatus_Ejec_ich INTEGER;
	DEFINE iStatus_Ejec_vpn INTEGER;
	DEFINE iStatus_Ejec_pcr INTEGER;
	DEFINE iStatus_Ejec_crd INTEGER;
	DEFINE iStatus_Ejec_vcr INTEGER;
	DEFINE iStatus_Ejec_icr INTEGER;
	DEFINE dF_ini_ivr	   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_bpi   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_sol   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_cap   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_ich   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_vpn   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_pcr   	DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_crd       DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_vcr       DATETIME YEAR TO FRACTION;
	DEFINE dF_ini_icr       DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_ivr		DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_bpi   	DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_sol		DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_cap   	DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_ich   	DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_vpn   	DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_pcr   	DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_crd       DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_vcr       DATETIME YEAR TO FRACTION;
	DEFINE dF_fin_icr       DATETIME YEAR TO FRACTION;
	DEFINE dF_proceso_ivr	DATE;
	DEFINE dF_proceso_bpi	DATE;
	DEFINE dF_proceso_sol	DATE;
	DEFINE dF_proceso_cap	DATE;
	DEFINE dF_proceso_ich	DATE;
	DEFINE dF_proceso_vpn	DATE;
	DEFINE dF_proceso_pcr	DATE;
	DEFINE dF_proceso_crd   DATE;
	DEFINE dF_proceso_vcr   DATE;
	DEFINE dF_proceso_icr   DATE;
	
	--INICIALIZACION DE VARIABLES--	
	LET iSqlErr 		= 0;
	LET iSamErr			= 0;
	LET cProceso 		= '';	
    LET cCodRet 		= '00000';
	LET cVarDataErr		= '';
    LET cAnioMesAct     = '';
	LET cAnioMesUni     = '';
	LET iStatus_Ejec_ivr = 0;
	LET iStatus_Ejec_bpi = 0;
	LET iStatus_Ejec_sol = 0;
	LET iStatus_Ejec_cap = 0;
	LET iStatus_Ejec_ich = 0;
	LET iStatus_Ejec_vpn = 0;
	LET iStatus_Ejec_pcr = 0;
	LET iStatus_Ejec_crd = 0;
	LET iStatus_Ejec_vcr = 0;
	LET iStatus_Ejec_icr = 0;
	LET dF_ini_ivr   	= '';
	LET dF_ini_bpi   	= '';
	LET dF_ini_sol   	= '';
	LET dF_ini_cap   	= '';
	LET dF_ini_ich   	= '';
	LET dF_ini_vpn   	= '';
	LET dF_ini_pcr   	= '';
	LET dF_ini_crd      = '';
	LET df_ini_vcr      = '';
	LET df_ini_icr      = '';
    LET dF_fin_ivr   	= '';
	LET dF_fin_bpi   	= '';
	LET dF_fin_sol   	= '';
    LET dF_fin_cap   	= '';
	LET dF_fin_ich   	= '';
	LET dF_fin_vpn   	= '';
	LET dF_fin_pcr   	= '';
	LET dF_fin_crd      = '';
	LET dF_fin_vcr		= '';
	LET dF_fin_icr		= '';
	LET dF_proceso_ivr  = '';
	LET dF_proceso_bpi  = '';
	LET dF_proceso_sol  = '';
	LET dF_proceso_cap  = '';
	LET dF_proceso_ich  = '';
	LET dF_proceso_vpn  = '';
	LET dF_proceso_pcr  = '';
	LET dF_proceso_crd  = '';
	LET dF_proceso_vcr  = '';
	LET dF_proceso_icr  = '';

	--SET DEBUG FILE TO "/informix/ljfs/sp_registra_unica_ljfs.out";
	--TRACE ON;
	
	BEGIN
		--Manejo del error
		ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				LET cVarDataErr = 'ERROR NO CONTROLADO';
				INSERT INTO bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso (nombre_proceso, fecha_inicio, fecha_fin, status_ejecucion, observacion)
				VALUES (cProceso, CURRENT, CURRENT, cCodRet , cVarDataErr);
				RETURN cProceso,cCodRet, cVarDataErr;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		
		IF (UPPER(pGrupoUnica) = 'INTEG') THEN
			---Asignamos fechas de inicio al proceso de IVR
			IF dF_ini_ivr IS NULL OR dF_ini_ivr = '' THEN
			   SELECT    MAX(fecha_proceso) INTO dF_ini_ivr
			   FROM      bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE     tipo_proceso = 'IVR' AND status_ejecucion = 1;
			   IF dF_ini_ivr IS NULL OR dF_ini_ivr = '' THEN
				  SELECT   MAX(ultimo_ingreso) INTO dF_ini_ivr
				  FROM     bdiunica@stag_ids1170:"informix".uni_ivr;
				  IF  dF_ini_ivr IS NULL OR dF_ini_ivr = '' THEN
					  SELECT  MIN(fecha_oper) INTO dF_ini_ivr
					  FROM    bdinteg:"informix".si_bitacora_ivr WHERE   secuencia = 1; 
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso IVR
			LET dF_ini_ivr = (dF_ini_ivr::DATE) - 1;
			LET dF_fin_ivr = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso IVR
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_ivr 
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'IVR' AND status_ejecucion = 1;
			-- Obtenemos el ultimo estatus de ejecucion IVR
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_ivr
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'IVR'  AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso IVR
			IF dF_proceso_ivr IS NULL OR dF_proceso_ivr < TODAY::DATE OR iStatus_Ejec_ivr <> 1 THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_registro_ivr_bpi('IVR', dF_ini_ivr, dF_fin_ivr)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_ivr
				WHERE   tipo_proceso = 'IVR'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
	
	
			---Asignamos fechas de inicio al proceso de BPI
			IF dF_ini_bpi IS NULL OR dF_ini_bpi = '' THEN
			   SELECT    MAX(fecha_proceso) INTO dF_ini_bpi
			   FROM      bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE     tipo_proceso = 'BPI' AND status_ejecucion = 1;
			   IF dF_ini_bpi IS NULL OR dF_ini_bpi = '' THEN
				  SELECT   MAX(f_ultimo_acceso) INTO dF_ini_bpi
				  FROM     bdiunica@stag_ids1170:"informix".uni_bpi;
				  IF  dF_ini_bpi IS NULL OR dF_ini_bpi = '' THEN
					  SELECT  MIN(f_ultimo_acceso) INTO dF_ini_bpi
					  FROM    bdinteg:"informix".si_bpiusuarios WHERE   empresa = '001';
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso BPI
			LET dF_ini_bpi = (dF_ini_bpi::DATE) - 1;
			LET dF_fin_bpi = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso BPI
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_bpi
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'BPI' AND status_ejecucion = 1;
			-- Obtenemos el ultimo estatus de ejecucion BPI
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_bpi
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'BPI' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso BPI
			IF dF_proceso_bpi IS NULL OR dF_proceso_bpi < TODAY::DATE OR iStatus_Ejec_bpi <> 1 THEN 
				EXECUTE PROCEDURE bdinteg:"informix".sp_registro_ivr_bpi('BPI', dF_ini_bpi, dF_fin_bpi)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_bpi
				WHERE   tipo_proceso = 'BPI'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
		END IF;


		IF (UPPER(pGrupoUnica) = 'SOLIC') THEN
			---Asignamos fechas de inicio al proceso de SOL
			IF dF_ini_sol IS NULL OR dF_ini_sol = '' THEN
			   SELECT    MAX(fecha_proceso) INTO dF_ini_sol
			   FROM      bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE     tipo_proceso = 'SOL' AND status_ejecucion = 1;
			   IF dF_ini_sol IS NULL OR dF_ini_sol = '' THEN
				  SELECT   MAX(fecha_status) INTO dF_ini_sol
				  FROM     bdiunica@stag_ids1170:"informix".uni_solicitudes;
				  IF  dF_ini_sol IS NULL OR dF_ini_sol = '' THEN
					  SELECT  MIN(fecha_insert) INTO dF_ini_sol
					  FROM    bdisolic:"informix".ss_solicitudes;
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso SOL
			LET dF_ini_sol = (dF_ini_sol::DATE) - 1;
			LET dF_fin_sol = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso SOL
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_sol
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'SOL' AND status_ejecucion = 1;
			-- Obtenemos el ultimo estatus de ejecucion SOL
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_sol
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'SOL' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso SOL
			IF dF_proceso_sol IS NULL OR dF_proceso_sol < TODAY::DATE OR iStatus_Ejec_sol <> 1 THEN 
				EXECUTE PROCEDURE bdisolic:"informix".sp_actualiza_solicitudes('SOL',dF_ini_sol, dF_fin_sol)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_sol
				WHERE   tipo_proceso = 'SOL'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;	
		END IF;


		IF (UPPER(pGrupoUnica) = 'CAPTA') THEN	
			---Asignamos la fecha de inicio al proceso CAP
			IF dF_ini_cap IS NULL OR dF_ini_cap = '' THEN
			   SELECT    MAX(fecha_proceso) INTO dF_ini_cap
			   FROM      bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE     tipo_proceso = 'CAP' AND status_ejecucion = 1;
			   IF dF_ini_cap IS NULL OR dF_ini_cap = '' THEN
				  SELECT   MAX(fecha_apertura) INTO dF_ini_cap
				  FROM     bdiunica@stag_ids1170:"informix".uni_captacion;
				  IF  dF_ini_cap IS NULL OR dF_ini_cap = '' THEN
					  SELECT  MIN(ultpagocap) INTO dF_ini_cap
					  FROM    bdicheq:"informix".sc_maechq WHERE empresa = '001';
				  END IF;
			   END IF;
			END IF
			-- Asignamos la fecha final al proceso CAP
			LET dF_ini_cap = (dF_ini_cap::DATE) - 1;
			LET dF_fin_cap = TODAY;
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso CAP
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_cap 
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'CAP' AND status_ejecucion = 1;
			-- Obtenemos el ultimo estatus de ejecucion CAP
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_cap
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'CAP' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso CAP
			IF dF_proceso_cap IS NULL OR dF_proceso_cap < TODAY::DATE OR iStatus_Ejec_cap <> 1 THEN 
				EXECUTE PROCEDURE bdicheq:"informix".sp_actualiza_chq_cap('CAP',dF_ini_cap, dF_fin_cap)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_cap
				WHERE   tipo_proceso = 'CAP'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
					
			---Asignamos la fecha de inicio al proceso VPN
			IF dF_ini_vpn IS NULL OR dF_ini_vpn = '' THEN
			   SELECT  MAX(fecha_proceso) INTO dF_ini_vpn
			   FROM    bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE   tipo_proceso = 'VPN' AND status_ejecucion = 1;
			   IF dF_ini_vpn IS NULL OR dF_ini_vpn = '' THEN
				  SELECT   MAX(MDY(SUBSTRING(fecha_solicitud FROM 5 FOR 2),SUBSTRING(fecha_solicitud FROM 7 FOR 2),SUBSTRING(fecha_solicitud FROM 1 FOR 4))) INTO dF_ini_vpn
				  FROM     bdiunica@stag_ids1170:"informix".uni_var_port_nomina;
				  IF dF_ini_vpn IS NULL OR dF_ini_vpn = '' THEN
					 SELECT  MIN(MDY(SUBSTRING(fecha_solicitud FROM 5 FOR 2),SUBSTRING(fecha_solicitud FROM 7 FOR 2),SUBSTRING(fecha_solicitud FROM 1 FOR 4))) INTO dF_ini_vpn
					 FROM    bdicheq:"informix".sc_portacec_solicitud;
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso VPN
			LET dF_ini_vpn = (dF_ini_vpn::DATE) - 1;
			LET dF_fin_vpn = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso VPN
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_vpn 
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'VPN' AND status_ejecucion = 1;
			-- Obtenemos el ultimo estatus de ejecucion VPN
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_vpn
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'VPN' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso VPN
			IF dF_proceso_vpn IS NULL OR dF_proceso_vpn < TODAY::DATE OR iStatus_Ejec_vpn <> 1 THEN 
				EXECUTE PROCEDURE bdicheq:"informix".sp_actualiza_chq_cap('VPN', dF_ini_vpn, dF_fin_vpn)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_vpn
				WHERE   tipo_proceso = 'VPN'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
		END IF;


		IF (UPPER(pGrupoUnica) = 'CRED1') THEN
			-- Asignamos la fecha de inicio al proceso PCR
			IF dF_ini_pcr IS NULL OR dF_ini_pcr = '' THEN
			   SELECT  MAX(fecha_proceso) INTO dF_ini_pcr
			   FROM    bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE   tipo_proceso = 'PCR' AND status_ejecucion = 1;
			   IF dF_ini_pcr IS NULL OR dF_ini_pcr = '' THEN
				  SELECT   MAX(fecha_alta) INTO dF_ini_pcr
				  FROM     bdiunica@stag_ids1170:"informix".uni_cred_plazo;
				  IF dF_ini_pcr IS NULL OR dF_ini_pcr = '' THEN
					 SELECT  MIN(fecha_ult_mov) INTO dF_ini_pcr
					 FROM    bdicred:"informix".sd_maesdoscrd where empresa = '001';
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso PCR
			LET dF_ini_pcr = (dF_ini_pcr::DATE) - 1;
			LET dF_fin_pcr = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso PCR
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_pcr
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'PCR' AND status_ejecucion = 1;	
			-- Obtenemos el ultimo estatus de ejecucion PCR
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_pcr
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'PCR' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso PCR
			IF dF_proceso_pcr IS NULL OR dF_proceso_pcr < TODAY::DATE OR iStatus_Ejec_pcr <> 1 THEN 
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_creditos('PCR', dF_ini_pcr, dF_fin_pcr)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_pcr
				WHERE   tipo_proceso = 'PCR'
				AND     fecha_proceso IS NULL;	
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
			
			
						---Asignamos la fecha de inicio al proceso CRD
			IF dF_ini_crd IS NULL OR dF_ini_crd = '' THEN
			   SELECT  MAX(fecha_proceso) INTO dF_ini_crd
			   FROM    bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE   tipo_proceso = 'CRD' AND status_ejecucion = 1;
			   IF dF_ini_crd IS NULL OR dF_ini_crd = '' THEN
				  SELECT   MAX(fecha_apertura) INTO dF_ini_crd
				  FROM     bdiunica@stag_ids1170:"informix".uni_credito;
				  IF dF_ini_crd IS NULL OR dF_ini_crd = '' THEN
					 SELECT  MIN(fecha_ult_mov) INTO dF_ini_crd
					 FROM    bdicred:"informix".sd_maesdos where empresa = '001';
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso CRD
			LET dF_ini_crd = (dF_ini_crd::DATE) - 1;
			LET dF_fin_crd = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso CRD
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_crd
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'CRD' AND status_ejecucion = 1;	
			-- Obtenemos el ultimo estatus de ejecucion CRD
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_crd
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'CRD' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso CRD
			IF dF_proceso_crd IS NULL OR dF_proceso_crd < TODAY::DATE OR iStatus_Ejec_crd <> 1 THEN 
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_creditos('CRD', dF_ini_crd, dF_fin_crd)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_crd
				WHERE   tipo_proceso = 'CRD'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;	
		END IF;
		
		
		IF (UPPER(pGrupoUnica) = 'CRED2') THEN	
			---Asignamos la fecha de inicio al proceso VCR
			IF dF_ini_vcr IS NULL OR dF_ini_vcr = '' THEN
			   SELECT  MAX(fecha_proceso) INTO dF_ini_vcr
			   FROM    bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE   tipo_proceso = 'VCR' AND status_ejecucion = 1;
			   IF dF_ini_vcr IS NULL OR dF_ini_vcr = '' THEN
				  SELECT   MAX(fecha_apertura) INTO dF_ini_vcr
				  FROM     bdiunica@stag_ids1170:"informix".uni_var_credito;
				  IF dF_ini_vcr IS NULL OR dF_ini_vcr = '' THEN
					 SELECT  MIN(fecha_apertura) INTO dF_ini_vcr
					 FROM    bdicred:"informix".sd_maecred md;
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso VCR
			LET dF_ini_vcr = (dF_ini_vcr::DATE) - 1;
			LET dF_fin_vcr = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso VCR
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_vcr
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'VCR' AND status_ejecucion = 1;	
			-- Obtenemos el ultimo estatus de ejecucion VCR
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_vcr
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'VCR' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso VCR
			IF dF_proceso_vcr IS NULL OR dF_proceso_vcr < TODAY::DATE OR iStatus_Ejec_vcr <> 1 THEN 
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_creditos('VCR', dF_ini_vcr, dF_fin_vcr)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_vcr
				WHERE   tipo_proceso = 'VCR'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
		
			---Asignamos la fecha de inicio al proceso ICR
			IF dF_ini_icr IS NULL OR dF_ini_icr = '' THEN
			   SELECT  MAX(fecha_proceso) INTO dF_ini_icr
			   FROM    bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			   WHERE   tipo_proceso = 'ICR' AND status_ejecucion = 1;
			   IF dF_ini_icr IS NULL OR dF_ini_icr = '' THEN
				  SELECT   MAX(fechaultimocambio) INTO dF_ini_icr
				  FROM     bdiunica@stag_ids1170:"informix".uni_ind_credito;
				  IF dF_ini_icr IS NULL OR dF_ini_icr = '' THEN
					 SELECT  MIN(fecha_alta) INTO dF_ini_icr
					 FROM    bdicred:"informix".sd_indicador_cred icr where empresa = '001';
				  END IF;
			   END IF;
			END IF;
			-- Asignamos la fecha final al proceso ICR
			LET dF_ini_icr = (dF_ini_icr::DATE) - 1;
			LET dF_fin_icr = TODAY;		
			-- Se obtiene cuando fue la ultima fecha de ejecucion del proceso ICR
			SELECT   MAX(fecha_proceso)
			INTO     dF_proceso_icr
			FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
			WHERE    tipo_proceso = 'ICR' AND status_ejecucion = 1;	
			-- Obtenemos el ultimo estatus de ejecucion ICR
			SELECT   ej.status_ejecucion
			INTO     iStatus_Ejec_icr
			FROM     (SELECT   MAX(fecha_proceso),
							   status_ejecucion
					  FROM     bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
					  WHERE    tipo_proceso = 'ICR' AND status_ejecucion = 1
					  GROUP BY status_ejecucion) ej;		
			--Se ejecuta proceso ICR
			IF dF_proceso_icr IS NULL OR dF_proceso_icr < TODAY::DATE OR iStatus_Ejec_icr <> 1 THEN 
				EXECUTE PROCEDURE bdicred:"informix".sp_actualiza_creditos('ICR', dF_ini_icr, dF_fin_icr)
				INTO cProceso,cCodRet, cVarDataErr;	
				UPDATE  bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET     fecha_proceso = dF_fin_icr
				WHERE   tipo_proceso = 'ICR'
				AND     fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
		END IF;


		IF (UPPER(pGrupoUnica) = 'INDCI') THEN
			
			SELECT TO_CHAR(TODAY, '%Y%m') - '1'
			INTO   cAnioMesAct
			FROM   systables WHERE tabid = 1;
		
		    --Se ejecuta proceso ICH para archivo .UNL
			IF cAnioMesAct IS NOT NULL THEN 
				EXECUTE  PROCEDURE bdicheq:"informix".sp_archivo_ind_cheques('UNL')
				INTO     cProceso,cCodRet, cVarDataErr;	
				UPDATE   bdiunica@stag_ids1170:"informix".uni_reg_ejec_proceso 
				SET      fecha_proceso = dF_fin_vcr
				WHERE    tipo_proceso = 'UNL'
				AND      fecha_proceso IS NULL;
			ELSE 
				LET cCodRet     = '00000';
				LET cVarDataErr = 'EJECUCION EXITOSA ANTERIORMENTE';
			END IF;
			
		END IF;
		
			
		IF cCodRet = '00000' THEN
		   LET cProceso = 'SP_REGISTRA_UNICA';
		   LET cVarDataErr = 'EJECUCION EXITOSA';
		   RETURN cProceso, cCodRet, cVarDataErr;
		ELSE
		   LET cProceso = 'SP_REGISTRA_UNICA';
		   LET cVarDataErr = 'Error';
		   LET cCodRet  = '00001';
		   RETURN cProceso,cCodRet, cVarDataErr;
		END IF;

    END;
END PROCEDURE;