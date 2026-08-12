CREATE PROCEDURE "informix".sp_actualiza_sac_bts_sdep()
RETURNING
CHAR(5)         AS codigo_respuesta,
CHAR(200)		AS mensaje_respuesta;
   
    DEFINE iSqlErr              	INTEGER;
    DEFINE iIsamErr             	INTEGER;
    DEFINE cInfoErr             	CHAR(100);
	DEFINE cCodRet              	CHAR(5);
	DEFINE cMensaje					CHAR(200);
	DEFINE cEstatus_sdep			CHAR(2);
	DEFINE cIntentos_envio			CHAR(2);
	DEFINE cNum_confirmacion		CHAR(12);
	DEFINE cConteoActualizados		INTEGER;
	DEFINE vChannelid				CHAR(3);
	DEFINE vHora					INTEGER;
	DEFINE cReferencia				CHAR(3);

	LET iSqlErr       		        = 0;
	LET iIsamErr       			    = 0;
	LET cInfoErr       			    = 0;
	LET cCodRet  					= '00000';
	LET cMensaje 					= 'PROCESO EXITOSO';
	LET cEstatus_sdep           	= '';
	LET cIntentos_envio           	= '';
	LET cNum_confirmacion			= '';
	LET cConteoActualizados			= 0;
	LET vChannelid					= '';
	LET vHora						= 0;
	LET cReferencia					= '';

			--SET DEBUG FILE TO '/home/c90302774/sp_actualiza_sac_bts_sdep.out';
			--TRACE ON;

	BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "ERROR";
                EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, 'sp_actualiza_sac_bts_sdep');
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		--BTS
			DROP TABLE IF EXISTS sac_bts_pemporal;
		
			SELECT estatus_sdep, intentos_envio, NVL(num_confirmacion,'') AS num_confirmacion
			FROM bdisac:"informix".sac_bts_sdep 
			WHERE estatus_sdep = '03'
			AND intentos_envio >= '11'
			INTO TEMP sac_bts_pemporal WITH NO LOG;
			
		
			FOREACH WITH HOLD
				
				SELECT estatus_sdep, intentos_envio, num_confirmacion
				INTO cEstatus_sdep, cIntentos_envio, cNum_confirmacion
				FROM sac_bts_pemporal
			
						UPDATE bdisac:"informix".sac_bts_sdep SET intentos_envio = '0' WHERE estatus_sdep = cEstatus_sdep 
						AND intentos_envio = cIntentos_envio AND num_confirmacion = cNum_confirmacion;

						LET cConteoActualizados = cConteoActualizados +1;
						
			END FOREACH;


		--APPRIZA
			DROP TABLE IF EXISTS sac_app_pemporal;

			SELECT estatus_getorder, intentos_envio, NVL(uniquereferencenumber,'') AS uniquereferencenumber
			FROM bdisac:"informix".sac_app_getorder
			WHERE estatus_getorder = '03'
            AND fecha_insert >=TODAY-10
			AND intentos_envio >= '11'
			INTO TEMP sac_app_pemporal WITH NO LOG;

			FOREACH WITH HOLD

				SELECT estatus_getorder, intentos_envio, uniquereferencenumber
				INTO cEstatus_sdep, cIntentos_envio, cNum_confirmacion
				FROM sac_app_pemporal

						UPDATE bdisac:"informix".sac_app_getorder SET intentos_envio = '0' WHERE estatus_getorder = cEstatus_sdep 
						AND intentos_envio = cIntentos_envio AND uniquereferencenumber = cNum_confirmacion;

						LET cConteoActualizados = cConteoActualizados +1;

			END FOREACH;

--REMESAS APPRIZA PENDIENTES (ESTATUS INTERMEDIO)

			DROP TABLE IF EXISTS sac_app_pemporal2;
			SELECT MIN(channelid) channelid, 
			MIN(REPLACE(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) hora,
			estatus_getorder,
			NVL(uniquereferencenumber,'') AS uniquereferencenumber
			FROM bdisac:"informix".sac_app_getorder
			WHERE estatus_getorder IN ('02','11','12','07','97','98') --se agrega el estatus 07 por falta de fondos de la remesadora
			AND fecha_insert >=TODAY-10
			AND replace(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER>20000
			GROUP BY 3,4
			INTO TEMP sac_app_pemporal2 WITH NO LOG;

			FOREACH WITH HOLD SELECT channelid, hora, estatus_getorder, uniquereferencenumber INTO vChannelid, vHora, cEstatus_sdep, cNum_confirmacion FROM sac_app_pemporal2

					IF TRIM(cEstatus_sdep) ='12' THEN

					--SI ESTATUS 12 AND DEBITADO THEN ESTATUS 03, INTENTOS_ENVIO= 0 WHERE CHANNELID=MIN(CHANNELID)

						IF EXISTS (SELECT C.folio_suc FROM 
										(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
										    UNION ALL 
										    SELECT distinct SD.folio_suc FROM bdicheq:sc_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
										 ) C
									) THEN

							UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='03' 
							WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
							AND channelid = vChannelid
							--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora
							;

							EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 03', 'sp_actualiza_sac_bts_sdep');

							UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='09'
							WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
							AND channelid <> vChannelid
							--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora
							;

							LET cConteoActualizados = cConteoActualizados +1;
						ELSE
							--SI ESTATUS 12 AND REVERSADO THEN ESTATUS 04, INTENTOS_ENVIO= 0 WHERE CHANNELID=MIN(CHANNELID)

								IF EXISTS (SELECT C.folio_suc FROM 
											(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
												WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
											    UNION ALL 
											    SELECT distinct SD.folio_suc FROM bdicheq:sc_movhis SD, sac_movimientoshistorial MH 
												WHERE SD.folio_suc=MH.folio_suc and fech_alt >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and cancelad <> 'S' --and status_cancelado <> 'S'
											    UNION ALL
											    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
												WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
											    UNION ALL
											    SELECT distinct SD.folio_suc FROM bdicred:sd_movhis SD, sac_movimientoshistorial MH 
												WHERE SD.folio_suc=MH.folio_suc and fecha_mov >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and reversado <> 'S' --and status_cancelado <> 'S'
											    UNION ALL
    											SELECT numconfirmacion FROM sac_remesaslimitepld_app WHERE numconfirmacion = TRIM(cNum_confirmacion)
											) C,
											(SELECT estatus_getorder FROM sac_app_getorder WHERE uniquereferencenumber = TRIM(cNum_confirmacion)) A
											) THEN

									UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='04' 
									WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
									AND channelid = vChannelid
									--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora
									;

									EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 04', 'sp_actualiza_sac_bts_sdep');

									UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='09' 
									WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
									AND channelid <> vChannelid
									--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora
									;

									LET cConteoActualizados = cConteoActualizados +1;
									
								ELSE
									
									LET cReferencia = '%' || cNum_confirmacion || '%';
											
									IF EXISTS (SELECT COUNT(*) FROM bdisac:sac_ws_errores WHERE proceso = 'sp_app_aplicapago' AND cadena_ent like cReferencia) THEN		
											
										UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='04' 		
										WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 		
										AND channelid = vChannelid		
										--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora		
										;		
												
										EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 04', 'sp_actualiza_sac_bts_sdep');		
												
										UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='09' 		
										WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 		
										AND channelid <> vChannelid		
										--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT - fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora		
										;	

										LET cConteoActualizados = cConteoActualizados +1;
										
									END IF;		

								END IF;

						END IF;

					END IF;

					IF TRIM(cEstatus_sdep) IN('02','11','07','97','98') THEN --02 Y 11 FALLA DEL BUS, 07 FALTA DE FONDOS, 97 FALLA EN LA VALIDACION DE LA CUENTA, 98 COBRO SIMULTANEO 

					--IF ESTATUS 02 Y 11 AND NO DEBITADO THEN ESTATUS=01 WHERE CHANNELID=MIN(CHANNELID)

						IF NOT EXISTS (SELECT C.folio_suc FROM 
										(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad='N' --and status_cancelado <> 'S'
										    UNION ALL 
										    SELECT distinct SD.folio_suc FROM bdicheq:sc_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and cancelad='N' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado='N' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and reversado='N' --and status_cancelado <> 'S'
										) C
									) THEN

							UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='01' 
							WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
							AND channelid = vChannelid
							--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) = vHora
							;

							EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemAPP: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 01', 'sp_actualiza_sac_bts_sdep');

							UPDATE sac_app_getorder SET intentos_envio='0', estatus_getorder='09' 
							WHERE uniquereferencenumber=TRIM(cNum_confirmacion) 
							AND channelid <> vChannelid
							--AND MIN(REPLACE(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) <> vHora
							;

							LET cConteoActualizados = cConteoActualizados +1;
						END IF;

					END IF;

			END FOREACH;

--REMESAS BTS PENDIENTES (ESTATUS 02)

			DROP TABLE IF EXISTS sac_bts_temporal;
			SELECT --MIN(channelid) channelid, 
			MIN(REPLACE(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER) hora,
			estatus_sdep,
			NVL(num_confirmacion,'') AS num_confirmacion
			FROM "informix".sac_bts_sdep
			WHERE estatus_sdep IN ('02')
			AND fecha_insert >=TODAY-10
			AND replace(SUBSTR(TRIM((CURRENT -fecha_insert)::CHAR(30)),3,12),':','')::INTEGER>20000
			GROUP BY 2,3
			INTO TEMP sac_bts_temporal WITH NO LOG;

			FOREACH WITH HOLD SELECT hora, estatus_sdep, num_confirmacion INTO vHora, cEstatus_sdep, cNum_confirmacion FROM sac_bts_temporal

				IF NOT EXISTS (SELECT C.folio_suc FROM 
										(SELECT distinct SD.folio_suc FROM bdicheq:sc_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt = TODAY and referencia1 = TRIM(cNum_confirmacion) and cancelad='N' --and status_cancelado <> 'S'
										    UNION ALL 
										    SELECT distinct SD.folio_suc FROM bdicheq:sc_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fech_alt >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and cancelad='N' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movdia SD, sac_movimientos MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov = TODAY and referencia1 = TRIM(cNum_confirmacion) and reversado='N' --and status_cancelado <> 'S'
										    UNION ALL
										    SELECT distinct SD.folio_suc FROM bdicred:sd_movhis SD, sac_movimientoshistorial MH 
											WHERE SD.folio_suc=MH.folio_suc and fecha_mov >= TODAY-10 and referencia1 = TRIM(cNum_confirmacion) and reversado='N' --and status_cancelado <> 'S'
										 ) C
									) THEN

					UPDATE "informix".sac_bts_sdep SET intentos_envio='0', estatus_sdep='01'
					WHERE num_confirmacion=TRIM(cNum_confirmacion)
					AND estatus_sdep='02'
					;

					EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemBTS: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 01', 'sp_actualiza_sac_bts_sdep');

				ELSE

					UPDATE "informix".sac_bts_sdep SET intentos_envio='0', estatus_sdep='03'
					WHERE num_confirmacion=TRIM(cNum_confirmacion)
					AND estatus_sdep='02'
					;

					EXECUTE PROCEDURE "informix".sp_sac_guardamensajeerror(0, 0, 'Actualiza Estatus RemBTS: ' || TRIM(cNum_confirmacion) || ' de ' || TRIM(cEstatus_sdep) || ' a 03', 'sp_actualiza_sac_bts_sdep');

				END IF;

				LET cConteoActualizados = cConteoActualizados +1;

			END FOREACH;

			LET cMensaje = 'SE REALIZARON ' || cConteoActualizados || ' ACTUALIZACIONES';

		RETURN cCodRet, cMensaje;

	END;

END PROCEDURE;