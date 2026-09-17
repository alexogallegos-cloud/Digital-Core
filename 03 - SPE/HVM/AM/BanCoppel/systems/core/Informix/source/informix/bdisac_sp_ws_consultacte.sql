CREATE PROCEDURE "informix".sp_ws_consultacte(pcAgent_trans_type_code CHAR(10),pcAgent_cd CHAR(6),pcUsuario CHAR(8),pcPassword CHAR(8),pcIp_origen CHAR(15),
													 pcSession_id CHAR(30),pcNum_cte_ban CHAR (20), pcNum_cte_cop CHAR (20), email CHAR(20), pcNum_cta CHAR(20),
                                                     pcSistema CHAR(1), pcTransaccion CHAR(20), pcFecha_peticion CHAR(8), pcHora_peticion CHAR(6))

	RETURNING CHAR(5),CHAR(5),CHAR(255),CHAR(20),CHAR(4),CHAR(16),CHAR(8),CHAR(1),CHAR(1),CHAR(8),CHAR(4);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE vsMensaje        CHAR(200);
DEFINE cCodRet 			CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(255);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cNum_cte 		CHAR(20);
DEFINE cFecha_proceso 	CHAR(8);

DEFINE cHora_proceso 	CHAR(6);
DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cId_sesion_act	CHAR(30);
DEFINE cNombre_preceso	CHAR(17);
DEFINE cBlokeo_abono	CHAR(1);
DEFINE cBlokeo_cargo	CHAR(1);
DEFINE cCod_retorno		CHAR(5);
DEFINE cCod_retorno2	CHAR(5);

DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;

DEFINE cProducto 		CHAR(4);
DEFINE cNumTarjeta 		CHAR(16);
DEFINE cFechaVenc 		CHAR(8);
DEFINE cTipoTarjeta		CHAR(1);


--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCodRet = '0000';
LET cOpcode = '';
LET cDescr_mensaje = '';
LET cDescr_completa_mensaje = '';

LET cNum_cte = ''; 		
LET cFecha_proceso = trim(YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0'));

LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cId_sesion_act = '';
LET cNombre_preceso = 'sp_ws_consultacte';
LET cBlokeo_abono = '';
LET cBlokeo_cargo = '';
LET cCod_retorno  = '';
LET cCod_retorno2 = '';
LET cFecha_dia    = '';
LET dtFecha_dia   = CURRENT::DATE;
LET vsMensaje     = '';

LET cProducto =	'';	
LET cNumTarjeta = '';
LET cFechaVenc = '';
LET cTipoTarjeta = '';


BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError,vsMensaje
		--SET DEBUG FILE TO '/tmp/sp_ws_consultadircte_epg.out';
		--TRACE ON;
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cOpcode = cCodRet;
			
			LET cDescr_mensaje = '';
			LET cDescr_completa_mensaje = '';
	
			--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCodRet, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;
			
		END IF;
	END EXCEPTION;

	--log
	--SET DEBUG FILE TO '/informix/cristo/sp_ws_consultacte.out';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 10;
	
	
	
	--Se inserta el registro del proceso en curso	
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);
	
	--Se valida que alguno de los parametros de entrada no venga nulo

	IF	NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' 
		OR NVL(pcSession_id, '') = '' OR NVL(pcNum_cte_ban, '') = '' OR NVL(pcTransaccion, '') = '' OR pcFecha_peticion = ''  OR NVL(pcNum_cta,'') = '' OR NVL(pcSistema,'') = '' THEN
		LET cCodRet = '9996';

	ELSE 
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes		
				   WHERE agent_cd = pcAgent_cd AND transaccion = pcAgent_trans_type_code AND usuario = usuario AND activa = 'S' ) THEN
			
			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen,id_sesion_act
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen,cId_sesion_act
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd;
			
            /*SELECT fecha_hoy
            INTO dtFecha_dia
            FROM bdisac:"informix".sac_fechas
			where empresa = '001';*/
									
 			LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');

			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN
							IF cId_sesion_act = pcSession_id THEN
								IF (SELECT count(*) FROM bdinteg:si_cliente  WHERE numcte = pcNum_cte_ban) > 0 THEN
									--Se valida que la fecha sea correcta la del servidor
									IF pcFecha_peticion = cFecha_dia THEN
										IF pcSession_id = (SELECT id_sesion_act::CHAR(30) FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd and fecha_insert = dtFecha_dia) THEN

                                                SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
                                                    INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje 
                                                    FROM bdisac:"informix".sac_ws_catmensajes 
                                                   WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;

                                                    EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCodRet,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
                                                    INTO cCod_retorno;

                                                    IF cOpcode IS NULL THEN
                                                        LET cOpcode = cCodRet;
                                                        LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
                                                        LET cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
                                                    END IF;
													
													IF LENGTH(pcNum_cta) > 1 THEN
														FOREACH
																SELECT {+INDEX(sc_tarjeta,205_241)+INDEX(sc_tarjeta, ix_tarjeta3} NVL(tarjeta.numcte, ''), NVL(tarjeta.prodtarjeta, ''), NVL(tarjeta.num_tarjeta,''),NVL( YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),'') , NVL(tarjeta.tipo_tarjeta,''),'D'
															        INTO cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema
																	FROM bdicheq:"informix".sc_tarjeta tarjeta, bdicheq:"informix".sc_maechq cheq 
																WHERE tarjeta.empresa = cheq.empresa	
																	AND tarjeta.empresa = '001' 
																	AND tarjeta.numcte = cheq.num_cte 
																	AND tarjeta.numcte = pcNum_cte_ban 
																	AND tarjeta.status_tar = 'A'
																	AND tarjeta.cuenta = pcNum_cta
																	GROUP BY tarjeta.numcte,tarjeta.prodtarjeta,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
																union all
																SELECT NVL(tarjeta.numcte, ''), NVL(mae.num_producto, ''), NVL(tarjeta.num_tarjeta,''), NVL(YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),''), NVL(tarjeta.tipo_tarjeta,''),'C'
																	FROM bdicred:"informix".sd_tarjeta tarjeta, bdicred:"informix".sd_maecred mae, bdicred:"informix".sd_maecredanexo anex
																WHERE tarjeta.empresa = mae.empresa	
																	AND tarjeta.empresa = '001' 
																	AND tarjeta.num_credito = mae.num_credito
																	AND tarjeta.num_credito = anex.num_credito
																	AND tarjeta.numcte = mae.numcte
																	AND tarjeta.numcte = pcNum_cte_ban 
																	AND tarjeta.status_tar = 'A'
																	AND tarjeta.num_credito = pcNum_cta
																	GROUP BY tarjeta.numcte,mae.num_producto,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
																	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_mensaje,cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema,cFecha_proceso,cHora_proceso WITH RESUME;
														END FOREACH;																	
																	IF (cNum_cte is null OR  cNum_cte == '')  THEN
																	LET cCodRet = '9974';
																	END IF;	
													
                                                    ELIF pcSistema = 'D' THEN

                                                        FOREACH 
                                                                SELECT {+INDEX(sc_tarjeta,205_241)+INDEX(sc_tarjeta, ix_tarjeta3} NVL(tarjeta.numcte, ''), NVL(tarjeta.prodtarjeta, ''), NVL(tarjeta.num_tarjeta,''), NVL(YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),''), NVL(tarjeta.tipo_tarjeta,'')
																	INTO cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta
																	FROM bdicheq:"informix".sc_tarjeta tarjeta, bdicheq:"informix".sc_maechq cheq 
                                                                 WHERE tarjeta.empresa = cheq.empresa	
																	AND tarjeta.empresa = '001' 
																	AND tarjeta.numcte = cheq.num_cte 
																	AND tarjeta.numcte = pcNum_cte_ban 
																	AND tarjeta.status_tar = 'A'
																	GROUP BY tarjeta.numcte,tarjeta.prodtarjeta,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
							                                       	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_mensaje,cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema,cFecha_proceso,cHora_proceso WITH RESUME;
														END FOREACH;
																	IF (cNum_cte is null OR  cNum_cte == '')  THEN
																	LET cCodRet = '9974';
																	END IF;	

                                                    ELIF pcSistema = 'C' THEN

                                                        FOREACH 
                                                                SELECT NVL(tarjeta.numcte, ''), NVL(mae.num_producto, ''), NVL(tarjeta.num_tarjeta,''), NVL(YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),''), NVL(tarjeta.tipo_tarjeta,'')
                                                                    INTO cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta
                                                                    FROM bdicred:"informix".sd_tarjeta tarjeta, bdicred:"informix".sd_maecred mae, bdicred:"informix".sd_maecredanexo anex
                                                                WHERE tarjeta.empresa = mae.empresa	
                                                                    AND tarjeta.empresa = '001' 
                                                                    AND tarjeta.num_credito = mae.num_credito
                                                                    AND tarjeta.num_credito = anex.num_credito
                                                                    AND tarjeta.numcte = mae.numcte
                                                                    AND tarjeta.numcte = pcNum_cte_ban 
                                                                    AND tarjeta.status_tar = 'A'
                                                                    GROUP BY tarjeta.numcte,mae.num_producto,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
					                                                RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_mensaje,cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema,cFecha_proceso,cHora_proceso WITH RESUME;
														END FOREACH;
																	IF (cNum_cte is null OR  cNum_cte == '')  THEN
																	LET cCodRet = '9974';
																	END IF;	

                                                    ELIF pcSistema = 'T' THEN

                                                        FOREACH
																SELECT NVL(tarjeta.numcte, ''), NVL(tarjeta.prodtarjeta, ''), NVL(tarjeta.num_tarjeta,''),NVL( YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),'') , NVL(tarjeta.tipo_tarjeta,''),'D'
															        INTO cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema
																	FROM bdicheq:"informix".sc_tarjeta tarjeta, bdicheq:"informix".sc_maechq cheq 
																WHERE tarjeta.empresa = cheq.empresa	
																	AND tarjeta.empresa = '001' 
																	AND tarjeta.numcte = cheq.num_cte 
																	AND tarjeta.numcte = pcNum_cte_ban 
																	AND tarjeta.status_tar = 'A'
																	GROUP BY tarjeta.numcte,tarjeta.prodtarjeta,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
																union all
																SELECT NVL(tarjeta.numcte, ''), NVL(mae.num_producto, ''), NVL(tarjeta.num_tarjeta,''), NVL(YEAR(tarjeta.expiracion) || LPAD(MONTH(tarjeta.expiracion),2,'0') || LPAD(DAY(tarjeta.expiracion),2,'0'),''), NVL(tarjeta.tipo_tarjeta,''),'C'
																	FROM bdicred:"informix".sd_tarjeta tarjeta, bdicred:"informix".sd_maecred mae, bdicred:"informix".sd_maecredanexo anex
																WHERE tarjeta.empresa = mae.empresa	
																	AND tarjeta.empresa = '001' 
																	AND tarjeta.num_credito = mae.num_credito
																	AND tarjeta.num_credito = anex.num_credito
																	AND tarjeta.numcte = mae.numcte
																	AND tarjeta.numcte = pcNum_cte_ban 
																	AND tarjeta.status_tar = 'A'
																	GROUP BY tarjeta.numcte,mae.num_producto,tarjeta.num_tarjeta,tarjeta.expiracion,tarjeta.tipo_tarjeta
																	RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_mensaje,cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema,cFecha_proceso,cHora_proceso WITH RESUME;
														END FOREACH;																	
																	IF (cNum_cte is null OR  cNum_cte == '')  THEN
																	LET cCodRet = '9974';
																	END IF;	
                                                               
                                                     END IF;
										ELSE
											LET cCodRet = '9975';
										END IF;
									ELSE
										LET cCodRet = '9977';
									END IF;
								ELSE 
									LET cCodRet = '9995';
								END IF;	
							ELSE
								LET cCodRet = '9975';
							END IF;
						ELSE
							LET cCodRet = '9976';
						END IF;
					ELSE
						LET cCodRet = '9979';
					END IF;
				ELSE
					LET cCodRet = '9980';
				END IF;
			ELSE
				LET cCodRet = '9998';
			END IF;
		ELSE
			LET cCodRet = '9999';
		END IF;
	END IF;


	IF cCodRet <> '0000' THEN		
		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje 
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCodRet;
		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCodRet;
			LET cDescr_mensaje = 'Codigo no registrado en catalogo.';
			LET	cDescr_completa_mensaje = 'Codigo no registrado en catalogo.';
		END IF;
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCodRet,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
		INTO cCod_retorno;

        RETURN LPAD(cCodRet,5,'0'),cOpcode,cDescr_mensaje,cNum_cte,cProducto,cNumTarjeta,cFechaVenc,cTipoTarjeta,pcSistema,cFecha_proceso,cHora_proceso;
	END IF;




END;
END PROCEDURE;