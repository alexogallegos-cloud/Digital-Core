CREATE PROCEDURE "informix".sp_ws_coppel_bcpl_tar( pcAgent_trans_type_code CHAR(10),
											  pcAgent_cd CHAR(3),
											  pcUsuario CHAR(8),
											  pcPassword CHAR(8),
											  pcIp_origen CHAR(15),
											  pcSession_id CHAR(30),
											  pcFecha_peticion CHAR(8),
											  pcHora_peticion CHAR(6),
											  pcTipoEje CHAR(1),
											  pcNumCteNumTar CHAR(20) )

RETURNING 
 CHAR(5) AS ccCodRetorno,
 CHAR(4)  AS cCodRet,
 CHAR(100) AS mensaje,
 CHAR(8)  AS cFecha_proceso,
 CHAR(6)  AS cHora_proceso,
 CHAR(20) AS ClienteBancoppel,
 CHAR(20) AS ClienteCoppel,
 CHAR(20) AS NumTarjeta,
 CHAR(10) AS FechaAsignacion,
 CHAR(1)  AS EstatusTarjeta,
 CHAR(1)  AS IndicadorTarjeta;
			
	--VARIABLES DE RETORNO 
	DEFINE ccCodRetorno 			CHAR(5);
	DEFINE cCodRet					CHAR(4);
	DEFINE mensaje					CHAR(100);
	DEFINE cFecha_proceso 			CHAR(8);
	DEFINE cHora_proceso 			CHAR(6);
	DEFINE cOpcode 					CHAR(4);
	DEFINE cDescr_completa_mensaje 	CHAR(100);
	DEFINE cNombre_proceso			CHAR(17);
	DEFINE cCadena_ent				CHAR(100);

	DEFINE cCodigoError 			CHAR(5);
	DEFINE cDescripcion 			CHAR(40);
	DEFINE cClienteBancoppel 		CHAR(20);
	DEFINE cClienteCoppel 			CHAR(20);
	DEFINE cNumTarjeta 				CHAR(20);
	DEFINE cFechaAsignacion 		CHAR(20);
	DEFINE cEstatusTarjeta 			CHAR(1);
	DEFINE cIndicadorTarjeta 		CHAR(1);
	DEFINE iContador 				INTEGER;
	
	--VARIABLES DE CONTROL DE ERRORES
	DEFINE	iSqlErr 				INTEGER;
	DEFINE	iIsamErr				INTEGER;
	DEFINE	vErrorInfo				VARCHAR(80);
	DEFINE  iIsamError 				INTEGER;


	---INICIALIZAR VARIABLES
	LET ccCodRetorno  				= '00000';
	LET cCodRet 					= '0000';
	LET mensaje 					= 'Consulta Exitosa';
	LET cFecha_proceso 				= TRIM(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode 					= '0000';
	LET cDescr_completa_mensaje 	= 'Consulta Exitosa.';
	LET cNombre_proceso				= 'sp_ws_coppel_bcpl_tar';
	LET cCadena_ent 				= TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
	  
	LET iIsamError = 0;
	
	LET cCodigoError 		= "00000";
	LET cDescripcion 		= "CONSULTA EXITOSA";
	LET cClienteCoppel 		= "";
	LET cClienteBancoppel 	= "";
	LET cNumTarjeta 		= "";
	LET cFechaAsignacion 	= "";
	LET cEstatusTarjeta 	= "";
	LET cIndicadorTarjeta 	= "";
	LET iSqlErr 			= 0;
	LET iContador 			= 0;

	--SET DEBUG FILE TO '/tmp/ingrid/sp_ws_tda_huella.out';
	--TRACE ON;	
	   
BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			IF iSqlErr = '-1213' THEN

				LET cCodRet = '0001';
				LET cOpcode = cCodRet;
		
				SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
				INTO cOpcode,mensaje,cDescr_completa_mensaje
				FROM bdisac:"informix".sac_ws_catmensajes
				WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
				INTO ccCodRetorno;
				
				IF cOpcode IS NULL THEN
					LET cOpcode = cCodRet;
					LET mensaje = 'Codigo no registrado en catalogo.';
					LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
				END IF;
			ELSE
			
				LET cCodRet = iSqlErr;
				LET cOpcode = cCodRet;
				LET mensaje = '';
				LET cDescr_completa_mensaje = '';
				
				--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso, cCodRet, mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
				INTO ccCodRetorno;
				
			END IF;	
			
			INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
			VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
			
			DROP TABLE IF EXISTS tmp_si_clientetarjetas;
			
			--RETURN cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
			RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
		END IF;
	END EXCEPTION;


	-- VALIDACION DE PARAMETROS
	
	IF  NVL(pcAgent_cd,'?') <> 'TDA' OR NVL(pcAgent_trans_type_code,'?') <> 'BCPL_TAR' OR NVL(pcUsuario,'?')= '?'
		OR NVL(pcPassword,'?')= '?' OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?' 
		OR NVL(pcIp_origen,'')= '' OR NVL(pcSession_id,'')=''
		OR NVL(pcTipoEje,'?')= '?' OR NVL(pcNumCteNumTar,'?')= '?' THEN
		
		LET cCodRet ='9996';
	
	ELSE
	
		EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code, pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id) 
		INTO cCodRet, mensaje;
			
		IF cCodRet = '0000' THEN 
			
			IF( pcTipoEje IN( 1, 2 ) AND pcNumCteNumTar != '' ) THEN

					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					
					DROP TABLE IF EXISTS tmp_si_clientetarjetas;

					IF TRIM( NVL(pcTipoEje, "") ) = "1" THEN

						--SELECT a.numcte AS numctebancoppel, a.numcte_ref AS numctecoppel, b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, SPACE(1) AS statustarjeta, 'C' AS indicadortarjeta
						--SELECT {+INDEX (bdinteg:"informix".idx_si_cliente5)} a.numcte AS numctebancoppel, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte_ref AS numctecoppel, {+INDEX (intercard:"informix".idx_tarjeta1)} b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, SPACE(1) AS statustarjeta, 'C' AS indicadortarjeta
						SELECT a.numcte AS numctebancoppel, {+INDEX (bdinteg:si_cliente idx_numcte_ref)} a.numcte_ref AS numctecoppel, {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, SPACE(1) AS statustarjeta, 'C' AS indicadortarjeta
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicred:"informix".sd_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE a.numcte_ref = TRIM( pcNumCteNumTar )
						AND c.status_tar = 'A'
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas with no log;

						INSERT INTO tmp_si_clientetarjetas( numctebancoppel, numctecoppel, numtarjeta, fechaasignacion, statustarjeta, indicadortarjeta )
						--SELECT a.numcte, a.numcte_ref, b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ), '', 'D'
						SELECT a.numcte, {+INDEX (bdinteg:si_cliente idx_numcte_ref)} a.numcte_ref, {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ), '', 'D'
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE a.numcte_ref = TRIM( pcNumCteNumTar )
						AND c.status_tar = 'A'
						AND a.empresa = '001';

					ELSE

						--SELECT a.numcte AS numctebancoppel, a.numcte_ref AS numctecoppel, SPACE(20) AS numtarjeta, NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, c.status_tar AS statustarjeta, c.tipo_tarjeta AS indicadortarjeta
						--SELECT {+INDEX (bdinteg:"informix".idx_si_cliente5)} a.numcte AS numctebancoppel, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte_ref AS numctecoppel, SPACE(20) AS numtarjeta, NVL( SUBSTR( DATE( {+INDEX (intercard:"informix".idx_tarjeta1)} b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, {+INDEX (intercard:"informix".idxsdtarjetapba)} c.status_tar AS statustarjeta, c.tipo_tarjeta AS indicadortarjeta
						SELECT a.numcte AS numctebancoppel, {+INDEX (bdinteg:si_cliente idx_numcte_ref)} a.numcte_ref AS numctecoppel, SPACE(20) AS numtarjeta, NVL( SUBSTR( DATE( {+INDEX (intercard:tarjeta idx_tarjeta1)} b.fechaasignacion ), 1, 10), '1900-01-01' ) AS fechaasignacion, {+INDEX (intercard:tarjeta idxsdtarjetapba)} c.status_tar AS statustarjeta, c.tipo_tarjeta AS indicadortarjeta
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicred:"informix".sd_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE B.numtarjeta = TRIM( pcNumCteNumTar )
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas with no log;

						INSERT INTO tmp_si_clientetarjetas( numctebancoppel, numctecoppel, numtarjeta, fechaasignacion, statustarjeta, indicadortarjeta )
						--SELECT a.numcte, a.numcte_ref, '', NVL( SUBSTR( DATE( b.fechaasignacion ), 1, 10), '1900-01-01' ), c.status_tar, c.tipo_tarjeta
						SELECT a.numcte, {+INDEX (bdinteg:si_cliente idx_numcte_ref)} a.numcte_ref, '', NVL( SUBSTR( DATE( {+INDEX (intercard:tarjeta idx_tarjeta1)} b.fechaasignacion ), 1, 10), '1900-01-01' ), c.status_tar, c.tipo_tarjeta
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE b.numtarjeta = TRIM( pcNumCteNumTar )
						AND a.empresa = '001';

					END IF;

					FOREACH sal_cursor FOR
						SELECT numctebancoppel, numctecoppel, numtarjeta, fechaasignacion, statustarjeta, indicadortarjeta
						INTO cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cindicadorTarjeta
						FROM tmp_si_clientetarjetas
						
						LET iContador = iContador + 1;

						--RETURN cCodigoError, cDescripcion, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;
						RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta WITH RESUME;	
					
					END FOREACH;
					
			END IF;
						
					
		END IF;

	END IF;
	
	DROP TABLE IF EXISTS tmp_si_clientetarjetas;

	IF cCodRet <> '0000' THEN			
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
	
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
	
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_proceso,cCodRet, mensaje, '', '', cCadena_ent, pcUsuario,cFecha_proceso,cHora_proceso)
		INTO ccCodRetorno;
		
	END IF;
	
	INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
	VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescr_completa_mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);

	IF  iContador = 0 THEN
		RETURN cCodRet, cOpcode, cDescr_completa_mensaje, cFecha_proceso, cHora_proceso, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta;
	END IF;
	--RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,NVL(cNumCte,''),NVL(cNumCte_cop,''),NVL(cSecuencia,''),NVL(cEstado,''),NVL(cUsuario,''),NVL(cSucursal,''),NVL(cSexo,''),NVL(cFecha_movto,''),NVL(cDMapa,''),NVL(cIMapa,'');
	
END
END PROCEDURE;