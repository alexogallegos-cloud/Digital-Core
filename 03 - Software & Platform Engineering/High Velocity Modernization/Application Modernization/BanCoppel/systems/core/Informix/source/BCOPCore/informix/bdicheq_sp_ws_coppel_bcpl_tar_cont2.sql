CREATE PROCEDURE "informix".sp_ws_coppel_bcpl_tar_cont2( pcAgent_trans_type_code CHAR(10),
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
CHAR(5) AS CodigoError,
CHAR(4) AS CodRet,
CHAR(40) AS Descripcion,
CHAR(3) AS Registros;

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
	DEFINE cNumTarjetas				CHAR(20);

	--VARIABLES DE CONTROL DE ERRORES
	DEFINE	iSqlErr 				INTEGER;
	DEFINE	iIsamErr				INTEGER;
	DEFINE	vErrorInfo				VARCHAR(80);
	DEFINE  iIsamError 				INTEGER;
	DEFINE  cRegistros 				CHAR(3);
	DEFINE  cReturnProc				CHAR(3);
	DEFINE  cCtBanco				CHAR(20);

	---INICIALIZAR VARIABLES
	LET ccCodRetorno  				= '00000';
	LET cCodRet 					= '0000';
	LET mensaje 					= 'Consulta Exitosa';
	LET cFecha_proceso 				= TRIM(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));
	LET cHora_proceso				= REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cOpcode 					= '0000';
	LET cDescr_completa_mensaje 	= 'Consulta Exitosa.';
	LET cNombre_proceso				= 'sp_ws_coppel_bcpl_tar_cont2';
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
	LET cRegistros 	 		= "0";
	LET cReturnProc			= "";
	LET cNumTarjetas 		= "";
	LET cCtBanco			= "";
	
	--SET DEBUG FILE TO '/home/sysifx/respaldosbd/Adrian/577/LiberacionIncidenciaWs/sp_ws_coppel_bcpl_tar_cont2.out';
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

				LET cDescr_completa_mensaje = TRIM( cDescr_completa_mensaje );

				INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
				VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);

				DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
				DROP TABLE IF EXISTS tmp_si_tarjetas_cont;

				RETURN cCodRet, cOpcode, SUBSTR( cDescr_completa_mensaje, 1, 40 ), cRegistros;
			END IF;
		END EXCEPTION;

		-- VALIDACION DE PARAMETROS
		IF  NVL(pcAgent_cd,'?') <> 'TDA' OR NVL(pcAgent_trans_type_code,'?') <> 'BCPL_TAR2' OR NVL(pcUsuario,'?')= '?'
			 OR NVL(pcPassword,'?')= '?' OR NVL(pcFecha_peticion,'?')= '?' OR NVL(pcHora_peticion,'?')= '?'
			 OR NVL(pcIp_origen,'')= '' OR NVL(pcSession_id,'')=''
			 OR NVL(pcTipoEje,'?')= '?' OR NVL(pcNumCteNumTar,'?')= '?'
			 OR LENGTH( TRIM( pcNumCteNumTar ) ) <= 1 THEN

			LET cCodRet ='9996';
		ELSE

			EXECUTE PROCEDURE bdisac:"informix".sp_valida_session(pcAgent_trans_type_code, pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id)
			INTO cCodRet, mensaje;
			
			IF cCodRet = '0000' THEN
				IF( pcTipoEje IN( 1, 2 ) AND pcNumCteNumTar != '' ) THEN
					
					SET LOCK MODE TO WAIT 3;
					SET ISOLATION TO DIRTY READ;
					
					DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
					DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
					
					LET pcNumCteNumTar = TRIM( pcNumCteNumTar );
					
					IF TRIM( NVL(pcTipoEje, "") ) = "1" THEN

						select nvl(numcte,'')
						  into cCtBanco
						  FROM bdinteg:"informix".si_cliente 
						 where numcte_ref = pcNumCteNumTar;
						 
						select num_tarjeta numtarjeta, numcte
						  from bdicheq:"informix".sc_tarjeta
						 where status_tar = 'A'
						   and numcte = cCtBanco
						INTO TEMP tmp_si_clientetarjetas_cont with no log;
						  
						 
						/*
						SELECT b.numtarjeta, {+INDEX (bdinteg:"informix".idx_numcte_ref)} a.numcte
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE a.numcte_ref = pcNumCteNumTar
						AND c.status_tar = 'A'
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas_cont with no log; */

					ELSE


						select num_tarjeta numtarjeta,  numcte
						  from bdicheq:"informix".sc_tarjeta
						 where num_tarjeta = pcNumCteNumTar
						INTO TEMP tmp_si_clientetarjetas_cont with no log;

						/*
						SELECT {+INDEX (intercard:tarjeta idx_tarjeta1)} b.numtarjeta, a.numcte
						FROM bdinteg:"informix".si_cliente a JOIN intercard:"informix".tarjeta b
						ON a.numcte = b.numcliente
						JOIN bdicheq:"informix".sc_tarjeta c
						ON b.numtarjeta = c.num_tarjeta
						WHERE b.numtarjeta = pcNumCteNumTar
						AND a.empresa = '001'
						INTO TEMP tmp_si_clientetarjetas_cont with no log; */

					END IF;
					
					CREATE TEMP TABLE tmp_si_tarjetas_cont(numtarj VARCHAR(16)) WITH NO LOG;
					
					SELECT FIRST 1 numcte
					INTO cCtBanco
					FROM tmp_si_clientetarjetas_cont;
					
					FOREACH
						EXECUTE PROCEDURE bditrapres:"informix".sp_consulta_tarjetas_dep(cCtBanco) INTO cReturnProc,cNumTarjetas
						INSERT INTO tmp_si_tarjetas_cont(numtarj)VALUES(cNumTarjetas);
					END FOREACH;
					
					SELECT TO_CHAR( COUNT(*), '&&&' )
					INTO cRegistros
					FROM tmp_si_clientetarjetas_cont a JOIN tmp_si_tarjetas_cont c
					ON a.numtarjeta = c.numtarj;
					
					
					INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
					VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescripcion, cClienteBancoppel, cClienteCoppel, cRegistros, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
					
					DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
					DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
					
					RETURN cCodigoError, cCodRet, cDescripcion, cRegistros;
					
				END IF;
			END IF;
		END IF;
		
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
			
			LET cDescr_completa_mensaje = TRIM( cDescr_completa_mensaje );
			
			INSERT INTO bdicheq:"informix".sc_ws_coppel_bcpl_tar(agent_cd, user_request, password, ip_origen, id_sesion, date_request, time_request, numcte_numtar, cod_error, descr_message, cte_ban, cte_cop, num_tarjeta, fecha_asi, estatus_tar, ind_tar, datetimeinsert)
			VALUES(pcAgent_cd, pcUsuario, pcPassword, pcIp_origen, pcSession_id, pcFecha_peticion, pcHora_peticion, pcNumCteNumTar, cCodRet, cDescr_completa_mensaje, cClienteBancoppel, cClienteCoppel, cNumTarjeta, cFechaAsignacion, cEstatusTarjeta, cIndicadorTarjeta, CURRENT);
			
			DROP TABLE IF EXISTS tmp_si_clientetarjetas_cont;
			DROP TABLE IF EXISTS tmp_si_tarjetas_cont;
			
			RETURN cCodRet, cOpcode, SUBSTR( cDescr_completa_mensaje, 1, 40 ), '000';
			
		END IF;
	END;
END PROCEDURE
;