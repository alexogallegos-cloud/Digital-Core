CREATE PROCEDURE "informix".sp_desfusion_ctesprincipal(pFecha DATE)
--RETORNOS-
RETURNING
CHAR(6)	AS codret,
CHAR(50)	AS detalle_ret,
CHAR(20)	AS cliente_tit,
CHAR(20)	AS cliente_tras;

--DECLARACION DE VARIABLES--
DEFINE iSql_err			INTEGER;
DEFINE iIsamErr     	INTEGER;
DEFINE cDescErr     	CHAR(50);
DEFINE cDetalleErr     	CHAR(50);
DEFINE cCodret		CHAR(6);
DEFINE cCteTit		CHAR(20);
DEFINE cCteTras		CHAR(20);
DEFINE cEstatus		SMALLINT;
DEFINE cProceso		CHAR(30);
DEFINE cUsuario		CHAR(8);
DEFINE dFechaActual	DATE;
DEFINE cRetornoCtesCap	CHAR(6);
DEFINE cRetornoCtesCred	CHAR(6);
DEFINE cRetornoCtesDig	CHAR(6);
DEFINE iTransaccion 	INTEGER;
DEFINE iContador		INTEGER;
DEFINE iExiste 		INTEGER;
DEFINE cDetalleMov	CHAR(200);
DEFINE cBandVal		CHAR(1);
DEFINE sFin			SMALLINT;
DEFINE sIni			SMALLINT;
DEFINE cNumcteInco	CHAR(20);
DEFINE cCodigoDig		CHAR(5);
DEFINE cSecuencia		CHAR(5);
DEFINE cSecActual		CHAR(5);
DEFINE cFecha		CHAR(12);
DEFINE cCuenta 		CHAR(20);
DEFINE cProducto		CHAR(5);
DEFINE cTramaDetalle	CHAR(200);
DEFINE cIdentificador	CHAR(1);
DEFINE cTabla			CHAR(25);
DEFINE cTabla1			CHAR(25);
DEFINE cTabla2			CHAR(25);
DEFINE cRetornoLog      CHAR(6);


--INICIALIZACION DE VARIABLES--
LET iSql_err		= 0;
LET iIsamErr    		= 0;
LET cDescErr    		= '';
LET cDetalleErr    	= '';
LET cCodret			= '000000';
LET cCteTit			= '';
LET cCteTras		= '';
LET cEstatus		= 0;
LET cProceso		= '';
LET cUsuario		= 'infdesf';
LET dFechaActual	= DATE(1);
LET cRetornoCtesCap		= '';
LET CRetornoCtesCred	= '';
LET cRetornoCtesDig		= '';
LET iTransaccion 		= 0;
LET iContador			= 0;
LET iExiste				= 0;
LET cDetalleMov			= '';
LET cBandVal			= '';
LET sFin				= 0;
LET sIni				= 0;
LET cNumcteInco			= '';
LET cCodigoDig		= '';
LET cSecuencia		= '';
LET cSecActual		= '';
LET cCuenta 		= '';
LET cProducto		= '';
LET cFecha			= '';
LET cTramaDetalle		= '';
LET cIdentificador	= '';
LET cTabla			= '';
LET cTabla1			= '';
LET cTabla2			= '';
LET cRetornoLog     = '';

--INICIO--
BEGIN
	--CONTROL DE ERRORES--
	ON EXCEPTION SET iSql_err , iIsamErr, cDescErr
		IF iSql_err <> 0 THEN
			LET cCodret = iSql_err;
			LET cDetalleErr = cDescErr;
			RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
		END IF;
	END EXCEPTION;

 --SET DEBUG FILE TO '/informix/ALAN/Sps/Nuevacarpeta/sp_desfusion_ctesprincipal.out';
 --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT fecha_hoy
	INTO dFechaActual
	FROM "informix".si_fechas
	WHERE empresa = '001';

	IF 	NVL(pFecha,'') = '' OR pFecha > dFechaActual THEN
		LET cCodret = '000001'; --ERROR EN LOS PARAMETROS
		LET cDetalleErr = 'FECHA NO VALIDA';
		RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
	END IF;

	EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal','000000000','000000000','Inicia consulta de si_desfusionctes',cUsuario) INTO cRetornoLog;
	FOREACH WITH HOLD
		
		SELECT {+INDEX ("informix".si_desfusionctes idx_desfusion_cte)} cliente_tit, cliente_tras
		INTO cCteTit, cCteTras
		FROM "informix".si_desfusionctes
		WHERE cliente_tit = cliente_tit
		AND cliente_tras = cliente_tras
		AND estatus = 0
		AND fecha_insert >= pFecha

		BEGIN
			ON EXCEPTION SET iSql_err, iIsamErr, cDescErr
				IF iSql_err <> 0 THEN
					LET cCodret = iSql_err;
					LET cDetalleErr = cDescErr;
					IF iTransaccion = 1 THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						END IF
				END IF;
				CONTINUE FOREACH;
			END EXCEPTION WITH RESUME;

			LET iContador = iContador + 1;

			IF iContador >= 1 THEN
				BEGIN WORK;
				LET iTransaccion = 1;
			END IF
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_cliente',cUsuario) INTO cRetornoLog;
			
			INSERT INTO "informix".si_cliente(empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
			rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
			numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno, tpo_biometria,cliente_pros)
			SELECT empresa,numcte,status_cte,sucursal,ejecutivo,tpo_persona,tipo_cliente,apell_paterno,apell_materno,nombre1,nombre2,razon_social,
			rfc,sector,segmento,actividad_princ,grupo,subgrupo,residencia,fecha_alta,apell_casada,distrito,numcte_ref,string1,string2,numeric1,
			numeric2,money1,date1,puesto_ppes,familiar_ppes,actividad_esp,ejecut_autoriza,user_insert,fecha_insert,rfc_alterno,tpo_biometria,cliente_pros 
			FROM "informix".si_fuscliente WHERE  numcte = TRIM(cCteTras);
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_ctepf',cUsuario) INTO cRetornoLog;
			
			INSERT INTO "informix".si_ctepf (empresa, numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil,
			regim_matrimonio, profesion, sexo, curp, codidentifi, numidentifi, no_imss, dependientes, tutor,
			nom_conyuge, seguro_defunc, escolaridad, habita_en, anios_habita, nombre_prop, imp_hipo_renta,
			actividadogiro, numeroife, numerotutor, numeroconyuge, string1, string2, numeric1, numeric2,
			money1, date1, user_insert, fecha_insert,sms_cel,hora_insert,validacurp,id_pais)
			SELECT FIRST 1 empresa, numcte, fecha_nac, lugar_nac, nacionalidad, no_fm3, estado_civil, regim_matrimonio, profesion,
			sexo, curp, codidentifi, numidentifi, no_imss, dependientes, tutor, nom_conyuge, seguro_defunc, escolaridad,
			habita_en, anios_habita, nombre_prop, imp_hipo_renta, actividadogiro, numeroife, numerotutor, numeroconyuge,
			string1, string2, numeric1, numeric2, money1,date1, user_insert, fecha_insert, sms_cel, hora_insert,validacurp,id_pais
			FROM "informix".si_fusctepf
			WHERE numcte = TRIM(cCteTras);
			

			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en si_logdesfusion',cUsuario) INTO cRetornoLog;
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES ('CLIENTE','si_fuscliente',cCteTit,cCteTras,cCteTras,CURRENT HOUR TO FRACTION(4),cUsuario,CURRENT);

			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctescap',cUsuario) INTO cRetornoLog;
			EXECUTE PROCEDURE "informix".sp_desfusion_ctescap(cCteTit, cCteTras, cUsuario) INTO cCodret, cDescErr;
			IF iTransaccion = 1 THEN
				IF cCodRet <> '000000' THEN	
					ROLLBACK WORK;
					LET cEstatus = 2;
					LET cDetalleErr = cDescErr;
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes',cUsuario) INTO cRetornoLog;
					UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
					WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
					LET iTransaccion = 0;
					RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
					CONTINUE FOREACH;
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctescred',cUsuario) INTO cRetornoLog;
					EXECUTE PROCEDURE bdicred:"informix".sp_desfusion_ctescred(cCteTit, cCteTras, cUsuario) INTO cCodret, cDescErr;
					LET cIdentificador = '1';
					IF cCodRet <> '000000' THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						LET cDetalleErr = cDescErr;
						EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 2',cUsuario) INTO cRetornoLog;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						CONTINUE FOREACH;
					END IF;
				END IF;
			END IF;
					
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inicia consulta en log_fusionclientes',cUsuario) INTO cRetornoLog;
			FOREACH WITH HOLD

				SELECT detalle_mov
				INTO cDetalleMov
				FROM "informix".log_fusionclientes
				WHERE cliente_tras = cCteTras
				AND proceso = 'DG_EXPEDIENTE'
				AND detalle_mov LIKE '%IMAGEN ACTUALIZADA%'

				LET cBandVal = '1';
				LET sIni = 1;

				LET cNumcteInco = '';
				LET cCodigoDig = '';
				LET cSecuencia = '';
				LET cSecActual = '';
				LET sFin = 0;
				LET cTramaDetalle = '';

				--SE EXTRAE EL NUMERO DE CTE INCORRECTO DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cNumcteInco = TRIM(SUBSTR(cDetalleMov,sIni,sFin - 1));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL CODIGO DE DIGITALIZACION
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCodigoDig = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1 ;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE LA SECUENCIA QUE CONTABA CTE ANTES DE LA FUSION
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecuencia = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE LA SECUENTA ACTUAL DEL CTE
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecActual = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE
				
				LET cTramaDetalle = TRIM(cNumcteInco)||'|'||TRIM(cCodigoDig)||'|'||TRIM(cSecuencia)||'|'||TRIM(cSecActual)||'|';
				EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctesdigital',cUsuario) INTO cRetornoLog;
				--EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_desfusion_ctesdigital(TRIM(cCteTit), TRIM(cTramaDetalle), TRIM(cIdentificador)) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(TRIM(cCteTit), TRIM(cTramaDetalle), TRIM(cIdentificador)) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
					IF iTransaccion = 1 THEN
						IF cCodRet <> '000000' THEN
							ROLLBACK WORK;
							LET cEstatus = 2;
							LET cDetalleErr = cDescErr;
							EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 3',cUsuario) INTO cRetornoLog;
							UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
							WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
							LET iTransaccion = 0;
							RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
							CONTINUE FOREACH;
						ELSE
							IF cTabla = 'dg_expediente' THEN
								--LOG
								EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente',cUsuario) INTO cRetornoLog;
								INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
								VALUES('DG_EXPEDIENTE', 'dg_expediente', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								IF cTabla1 = 'dg_expediente_img' THEN
									--LOG
									EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_img',cUsuario) INTO cRetornoLog;
									INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
									VALUES('DG_EXPEDIENTE', 'dg_expediente_img', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
									IF cTabla1 = 'dg_expediente_img_his' THEN
										--LOG
										EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_his',cUsuario) INTO cRetornoLog;
										INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
										VALUES('DG_EXPEDIENTE', 'dg_expediente_img_his', cCteTit, cCteTras, TRIM(cTramaDetalle)||'IMAGEN ACTUALIZADA', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
									END IF;
								END IF;		
							END IF;
						END IF;
					END IF;
					
			END FOREACH
			
			LET cIdentificador = '';
			LET cIdentificador = '2';
			
			EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inicia consulta log_fusionclientes:dg_expediente',cUsuario) INTO cRetornoLog;
			FOREACH WITH HOLD

				SELECT detalle_mov
				INTO cDetalleMov
				FROM "informix".log_fusionclientes
				WHERE cliente_tras = TRIM(cCteTras)
				AND proceso ='DG_EXPEDIENTE'
				AND detalle_mov
				LIKE '%DOCUMENTO ELIMINADO%'

				LET cBandVal = '1';
				LET sIni = 1;

				LET cNumcteInco = '';
				LET cCuenta = '';
				LET cProducto = '';
				LET cCodigoDig = '';
				LET cSecuencia = '';
				LET cFecha = '';
				LET sFin = 0;
				LET cTramaDetalle = '';

				--SE EXTRAE EL NUMERO DE CLIENTE INCORRECTO DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cNumcteInco = TRIM(SUBSTR(cDetalleMov,sIni,sFin - 1));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL NUMERO DE CUENTA DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCuenta = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1 ;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL PRODUCTO DE LA TRAMA.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cProducto = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE EL CODIGO DE DIGITALIZACION.
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cCodigoDig = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cBandVal = '1';
				--SE EXTRAE SECUENCIA  DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cSecuencia = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE
				
				LET cBandVal = '1';
				--SE EXTRAE FECHA  DE LA TRAMA
				WHILE cBandVal = '1'
					LET sFin = sFin + 1;
					IF SUBSTR(cDetalleMov,sFin,1) = '|' THEN
						LET cBandVal = '0';
						LET cFecha = TRIM(SUBSTR(cDetalleMov,sIni,sFin - sIni));
						LET sIni = sFin + 1;
					END IF;
				END WHILE

				LET cTramaDetalle = TRIM(cNumcteInco)||'|'||TRIM(cCuenta)||'|'||TRIM(cProducto)||'|'||TRIM(cCodigoDig)||'|'||TRIM(cSecuencia)||'|'||TRIM(cFecha)||'|';
				EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Ejecuta sp_desfusion_ctesdigital 2',cUsuario) INTO cRetornoLog;
				--EXECUTE PROCEDURE bdidigital@coppelimg_tcp:"informix".sp_desfusion_ctesdigital(cCteTit, cTramaDetalle, cIdentificador) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(cCteTit, cTramaDetalle, cIdentificador) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
				IF iTransaccion = 1 THEN
					IF cCodRet <> '000000' THEN
						ROLLBACK WORK;
						LET cEstatus = 2;
						LET cDetalleErr = cDescErr;
						EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes 3',cUsuario) INTO cRetornoLog;
						UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = TRIM(cDetalleErr), estatus = cEstatus, fecha = current
						WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
						LET iTransaccion = 0;
						RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
						CONTINUE FOREACH;
					ELSE
						IF cTabla = 'dg_expediente' THEN
							--LOG
							EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente 2',cUsuario) INTO cRetornoLog;
							INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
							VALUES('DG_EXPEDIENTE', 'dg_expediente', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
						
							IF cTabla1 = 'dg_expediente_img' THEN
								--LOG
								EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_img 2',cUsuario) INTO cRetornoLog;
								INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
								VALUES('DG_EXPEDIENTE', 'dg_expediente_img', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								
								IF cTabla2 = 'dg_expediente_img_his' THEN
									--LOG
									EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Inserta en log_desfusion:dg_expediente_his 2',cUsuario) INTO cRetornoLog;
									INSERT INTO "informix".si_logdesfusion (proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert) 
									VALUES('DG_EXPEDIENTE', 'dg_expediente_img_his', cCteTit, cCteTras, TRIM(cTramaDetalle)||'DOCUMENTO ELIMINADO', CURRENT HOUR TO SECOND, cUsuario, dFechaActual);
								END IF;	
							END IF;
						END IF;
					END IF;
				END IF;
					
			END FOREACH
				IF cCodRet = '000000' THEN
					LET cEstatus = 1;
					--SE CAMBIA ESTATUS A 1, SE INSERTA YA QUE FUE EXITOSO.
					EXECUTE PROCEDURE bdinteg:"informix".sp_graba_logdesfusion('Fusion','Principal',cCteTit,cCteTras,'Actualiza en si_desfusionctes: proceso exitoso',cUsuario) INTO cRetornoLog;
					UPDATE "informix".si_desfusionctes SET cod_retorno = TRIM(cCodret), proceso = 'CLIENTE DESFUSIONADO', estatus = cEstatus, fecha = current
					WHERE cliente_tit = cCteTit AND cliente_tras = cCteTras;
				END IF;

				IF iContador > 0 THEN
					COMMIT WORK;
					LET iContador =0;
					LET iTransaccion = 0;
				END IF;

			RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), NVL(TRIM(cCteTit),''), NVL(TRIM(cCteTras),'') WITH RESUME;
		END;
	END FOREACH

	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '000002';
		LET cDetalleErr = 'REPOSITORIO SIN CLIENTES';
		RETURN NVL(TRIM(cCodret),''), NVL(TRIM(cDetalleErr),''), '','';
	END IF;

END;
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1399',
'Autor: 92893422',
'Fecha: 21/01/2014',
'Descripción: ',
'Sustento: Desfusion de Clientes v1.4.doc',
'Solicita: Armando Morales Barraza',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 27/ENE/2015',
'DESCRIPCION: Se modifica contemplar el nuevo campo tp_biometria de la tabla si_cliente',
'SUSTENTO: RQI 64 068',
'SOLICITA: Jose Angel Lopez Adams',
'----------------------------------------------',
'FECHA: 22/ENE/2016',
'DESCRIPCION: Se modifica para ejecutar el SP sp_desfusion_ctesdigital sobre la BD bdinteg de la instancia OLTP',
'SUSTENTO: RQI 64 141',
'SOLICITA: Jose Angel Lopez Adams',
'BD:BDINTEG';

CREATE PROCEDURE "informix".sp_cnsif_aclaraciones(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(12), cNUMTARJETA CHAR(16),dPERIODOI  DATE, dPERIODOF DATE,pNumRegistro INTEGER,pRecuperacion INTEGER)
							
				returning CHAR(5)     AS Cod_Retorno,
						  CHAR(11)    AS Ticket,
						  CHAR(50)    AS Evento,
						  CHAR(255)   AS Status,
						  MONEY(14,2) AS Importe,
						  MONEY(14,2) AS Abono,
						  DATE        AS Fecha_Captura,
						  DATE        AS Fecha_Solucion,
						  CHAR(04)    AS Sucursal,
						  CHAR(04)    AS Cve_Documento,
						  SMALLINT    AS Secuencia;
										
DEFINE iexiste 			INT;
DEFINE cCodRet 		CHAR(5);
DEFINE iSql_err 		INT;							
--VARIABLES
DEFINE cTicket	       CHAR(11);
DEFINE cEvento	       CHAR(50);
DEFINE cStatus	       CHAR(255);
DEFINE mImporte		   MONEY(14,2);
DEFINE mAbono		   MONEY(14,2);
DEFINE dFechaCaptura   DATE;
DEFINE dFechaSolucion  DATE;
DEFINE cSucursal       CHAR(04);
DEFINE cCveDoc	       CHAR(04);
DEFINE smallSecuencia  SMALLINT;

DEFINE iFkyCliente      INTEGER;
DEFINE iPkyProducto     INTEGER;
DEFINE iFkyTipoProd     INTEGER;
DEFINE iPkyTipoEvento   INTEGER;
DEFINE iFkyStatusAclara INTEGER;
DEFINE iPkyAclaracion   INTEGER;
DEFINE iPkySucursal     INTEGER;

DEFINE cNumCliente      CHAR(20);
DEFINE cGrupoDoc        CHAR(04);
DEFINE cCodDef          CHAR(04);


DEFINE iCont            INTEGER;

--INICIALIZA VARIABLES
LET  iexiste 		    = 0;
LET cCodRet 	        = "00000";
LET iSql_err 			= 0 ;	

LET cTicket             ="";
LET cEvento 			= "";
LET cStatus				= "";
LET mImporte			= 0;
LET mAbono		        = 0;
LET dFechaCaptura       = "";
LET dFechaSolucion  	= "";
LET cSucursal       	= "";
LET cCveDoc	       		= "";
LET smallSecuencia  	= 0;

LET iFkyCliente      = 0;
LET iPkyProducto     = 0;
LET iFkyTipoProd     = 0;
LET iPkyTipoEvento   = 0;
LET iFkyStatusAclara = 0;
LET iPkyAclaracion   = 0;
LET iPkySucursal     = 0;

LET cNumCliente      = '';
LET cGrupoDoc        = '';
LET cCodDef          = '';

LET iCont            = 0;



BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
		END IF;
	END EXCEPTION;
	--  SET DEBUG FILE TO "/tmp/CNSIF/sp_cnsif_aclaraciones.out";
	--  TRACE ON;

SET LOCK MODE TO WAIT 3;

	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR (cNUMCUENTA   = '' AND cNUMTARJETA  = '') OR
		dPERIODOI    = ''   OR
		dPERIODOF    = ''   THEN 
		LET cCodRet = "00054";
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
	END IF;	
    
    IF pNumRegistro<0 THEN
        LET cCodRet='00098';
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
    ELSE
        IF pRecuperacion<=0 THEN
            LET cCodRet='00098';
            RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
        END IF;
    END IF;    
	--VALIDACION
	IF cNUMCUENTA <> '' THEN
        IF SUBSTR(cNUMCUENTA,1,1)='3' THEN    
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
            INTO
            cCodRet;
        ELIF SUBSTR(cNUMCUENTA,1,1)='6' THEN      
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
            INTO
            cCodRet;  
        ELSE
            EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'11','1')
            INTO
            cCodRet;
        END IF;
	ELSE
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMTARJETA,'11','3')
		INTO
		cCodRet;
	END IF
	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;					
	END IF;
	-- TERMINA VALIDACION		
	SET ISOLATION TO DIRTY READ;
    IF cNUMCUENTA<>'' THEN
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_cuenta  = cNUMCUENTA;
	ELSE
        SELECT NVL(COUNT(num_cliente),0) into iexiste FROM bdiaclaracion:acl_producto WHERE numero_tarjeta = cNUMTARJETA;
    END IF;
	IF iexiste  = 0 THEN 
        LET cCodRet = "00058";
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF;

    IF cNUMCUENTA<>'' THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_cuenta = cNUMCUENTA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                -- AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    ELSE
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT  
            num_cliente,pky_producto,fky_tipo_producto
            INTO 		
            cNumCliente,iPkyProducto,iFkyTipoProd
            FROM bdiaclaracion:acl_producto
            WHERE numero_tarjeta = cNUMTARJETA

            SET ISOLATION TO DIRTY READ;
            FOREACH

                SELECT {+INDEX (bdiaclaracion:"informix".acl_aclaracion 132_91)} SKIP pNumRegistro FIRST pRecuperacion
                folio_csuac AS ticket,
                importereclamado AS importe, 
                CASE 
                WHEN fky_estatus_corp_general = 8 THEN importereclamado ELSE null END AS Abono,
                fechacaptura,
                CASE 
                WHEN fecha_dictamen IS NULL THEN null ELSE fecha_dictamen END AS fecha_solucion,
                fky_tipo_evento,
                fky_estatus_aclaracion,
                pky_aclaracion
                INTO
                cTicket,mImporte,mAbono,dFechaCaptura,dFechaSolucion,iPkyTipoEvento,iFkyStatusAclara,iPkyAclaracion
                FROM bdiaclaracion:acl_aclaracion
                WHERE num_cliente = cNumCliente
                AND fky_producto = iPkyProducto
                AND fecha_dictamen::DATE BETWEEN dPERIODOI AND dPERIODOF ORDER BY folio_csuac

                SELECT descripcion,grupo_doc
                INTO cEvento,cGrupoDoc
                FROM bdiaclaracion:acl_tipo_evento
                WHERE pky_tipo_evento = iPkyTipoEvento;


                SELECT FIRST 1 cod_definicion
                INTO cCodDef
                FROM bdidigital@coppelimg_tcp:dg_definicion
                WHERE cod_producto = cGrupoDoc;

                IF LENGTH(cCodDef) = 3 THEN
                    LET cCodDef = '0' || cCodDef;
                END IF

                SELECT descripcion AS Estatus
                INTO cStatus
                FROM bdiaclaracion:acl_estatus_aclaracion
                WHERE pky_estatus_aclaracion = iFkyStatusAclara;

                SELECT --+AVOID_FULL (bdiaclaracion:"informix".acl_movimiento)
				NVL(num_sucursal,'') INTO cSucursal FROM bdiaclaracion:acl_movimiento WHERE fky_aclaracion = iPkyAclaracion;

                SET ISOLATION TO DIRTY READ;
                SELECT cod_docto,secuencia 
                INTO cCveDoc,smallSecuencia
                FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef
                AND secuencia =(SELECT max(secuencia) FROM bdidigital@coppelimg_tcp:dg_expediente
                WHERE cliente = cNumCliente
                --AND empresa = '001'
                AND cuenta = cTicket
                AND cod_docto  = cCodDef);

                LET iCont=iCont+1;

                RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia With Resume;

            END FOREACH;
        END FOREACH;            
    END IF;
    IF iCont = 0 THEN
        IF pNumRegistro=0 THEN
            LET cCodRet = '00091'; 
        ELSE
            LET cCodRet = '1001'; 
        END IF;
        RETURN cCodRet,cTicket,cEvento,cStatus,mImporte,mAbono,dFechaCaptura,dFechaSolucion,cSucursal,cCveDoc,smallSecuencia;
    END IF 
END

END PROCEDURE
DOCUMENT
"AutOR : ARTURO CERVANTES PEÑA",
"FUNCIONAMIENTO:Obtener la información de Aclaraciones asociadas a un Cliente. ",
"El SP obtendrá la información de la Base de Datos central de Informix, enviando como parámetro el Número de Cuenta.",
"FECHA : 23-03-2012",
"BD    : bdinteg",
"VER   : 1.0";

CREATE PROCEDURE "informix".img_sol_rec_clientes(pempresa char(3))
RETURNING    char(5);  

   DEFINE v_codret char(5);
   DEFINE v_cliente char(9);
   DEFINE v_cod_docto char(4);
   DEFINE v_secuencia smallint;
   DEFINE sql_err,isam_err int; 
   define v_cuenta char(20);
   define v_producto char(04);
   define v_tipo_cliente char(01);
   --define v_contador smallint;


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

   LET v_codret    = "000";
   LET v_cliente     = "";
   LET v_cod_docto    = "";
   LET v_secuencia = 0;
   let v_cuenta = "";
   let v_producto = "";
   let v_tipo_cliente = "";
   --let v_contador = 0;


BEGIN
   on exception set sql_err,isam_err
      if sql_err <> 0 or isam_err <> 0 then
         let v_codret = sql_err;
         return v_codret;
      end if;
   end exception;

--SET DEBUG FILE TO '/tmp/img_sol_rec_2';
--TRACE ON;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pempresa is null THEN
    
       -- datos de entrada incompletos
       
       LET v_codret = 110; 
       RETURN v_codret; 
    END IF;

--------------------RGH

	

        FOREACH WITH HOLD

	    SELECT numcte, tipo_cliente
            INTO v_cliente, v_tipo_cliente
            FROM bdidigital@coppelimg_tcp:tmp_cliente 
            WHERE tipo_cliente <> '5'
	

            BEGIN WORK;

            FOREACH WITH HOLD
                SELECT cod_docto,secuencia, cuenta, producto
                INTO v_cod_docto, v_secuencia, v_cuenta, v_producto
                FROM bdidigital@coppelimg_tcp:dg_expediente 
                WHERE cliente = v_cliente
                --WHERE empresa = pempresa

		 --BEGIN WORK;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente_img
                    WHERE empresa = pempresa
                    AND cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    AND secuencia = v_secuencia;

                    DELETE FROM bdidigital@coppelimg_tcp:dg_expediente
                    --WHERE empresa = pempresa
                    WHERE cliente = v_cliente
                    AND cod_docto = v_cod_docto
                    and cuenta = v_cuenta
                    AND producto = v_producto
                    AND secuencia = v_secuencia;
	            
		--COMMIT WORK;

            END FOREACH;

            update bdidigital@coppelimg_tcp:tmp_cliente
            set tipo_cliente = '5'
            where numcte = v_cliente;

            if (v_tipo_cliente = '1') then
                update bdinteg:si_cliente 
                set tipo_cliente = '2'
                where numcte = v_cliente;
            end if;

		COMMIT WORK;

		--LET v_contador = v_contador + 1;
	
		--IF (v_contador <= 100) THEN
			--CONTINUE FOREACH;
		--ELSE 
			--LET v_codret = '000';
			--RETURN v_codret;
		--END IF;
	

	    END FOREACH;


	

END;    

RETURN v_codret;

END PROCEDURE;