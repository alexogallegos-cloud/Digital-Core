CREATE PROCEDURE "informix".sp_desfusion_ctesprincipal_1(pFecha DATE)
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

 --SET DEBUG FILE TO '/informix/ALAN/Sps/Nuevacarpeta/sp_desfusion_ctesprincipal_1.out';
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
				--EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(TRIM(cCteTit), TRIM(cTramaDetalle), TRIM(cIdentificador)) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
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
				--EXECUTE PROCEDURE bdinteg:sp_desfusion_ctesdigital(cCteTit, cTramaDetalle, cIdentificador) INTO cCodret, cDescErr, cTabla, cTabla1, cTabla2;
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

CREATE PROCEDURE "informix".sp_genera_reporte_correos_validos()
RETURNING 
CHAR(5) AS CodRet,
CHAR(50) AS Mensaje;

----------------DEFINE VARIABLES----------------------
DEFINE sFechaEjecucion    CHAR(10);
DEFINE cCodRet        	  CHAR(5);
DEFINE cCodRetC           CHAR(5);
DEFINE iSqlErr	       	  INTEGER;
DEFINE cDesc          	  CHAR(50);
DEFINE sMes               CHAR(2);
DEFINE sAnio              CHAR(4);
DEFINE sDescMes           CHAR(10);    
DEFINE sSolic_cap         CHAR(20);
DEFINE sCtes_titulares    CHAR(20);
DEFINE sCtes_no_titulares CHAR(20);

DEFINE sMes2              CHAR(2);
DEFINE sAnio2             CHAR(4);
DEFINE sDescMes2          CHAR(10);    
DEFINE sTotal             CHAR(20);
DEFINE sCod_valid         CHAR(20);
DEFINE sCod_notvalid      CHAR(20);
DEFINE sCod_null          CHAR(20);
DEFINE sFecha_valida_null CHAR(20);
DEFINE sValidos           CHAR(20);

DEFINE sMes3              CHAR(2);
DEFINE sAnio3             CHAR(4);
DEFINE sDescMes3          CHAR(10);    
DEFINE sTitulares         CHAR(20);
DEFINE sTodos             CHAR(20);
DEFINE sDiaspormes        CHAR(20);
DEFINE sPromdiatit        CHAR(20);
DEFINE sPromdiatod        CHAR(20);

DEFINE sPorcentaje        CHAR(5);
DEFINE svt_fecha_hoy      DATE;
DEFINE svt_fecha_udia      DATE;
DEFINE sUdia              CHAR(2);
DEFINE sDiaP              CHAR(2);
DEFINE sMesP              CHAR(2);
DEFINE sAnoP              CHAR(4);

----------------INICIALIZA VARIABLES------------------
LET sFechaEjecucion     = '';
LET cCodRet             ='00000';
LET cCodRetC            ='00000';
LET iSqlErr	            = 0;
LET cDesc               ='';
LET sMes                ='';
LET sAnio               ='';
LET sDescMes            ='';
LET sSolic_cap          ='';
LET sCtes_titulares     ='';
LET sCtes_no_titulares  ='';

LET sMes2               ='';
LET sAnio2              ='';
LET sDescMes2           ='';
LET sTotal              ='';
LET sCod_valid          ='';
LET sCod_notvalid       ='';
LET sCod_null           ='';
LET sFecha_valida_null  ='';
LET sValidos            ='';

LET sMes3               ='';
LET sAnio3              ='';
LET sDescMes3           ='';
LET sTitulares          ='';
LET sTodos              ='';
LET sDiaspormes         ='';
LET sPromdiatit         ='';
LET sPromdiatod         ='';

LET sPorcentaje         ='';
LET svt_fecha_hoy       ='';
LET sUdia               ='';
LET sDiaP               ='';
LET sMesP               ='';
LET sAnoP               ='';

BEGIN

    ----------ERRORES DE INFORMIX-------------------------
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cDesc='Error no controlado';
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-------------------------------------OBTIENE FECHA-------------------------------------------
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)} add_months(fecha_hoy,-1) INTO svt_fecha_hoy
	FROM bdinteg:si_fechas
	WHERE empresa = '001';

    LET sDiaP = SUBSTR(svt_fecha_hoy,4,2);
    LET sMesP = SUBSTR(svt_fecha_hoy,0,2);
    LET sAnoP = SUBSTR(svt_fecha_hoy,7,4);
	
	SELECT LAST_DAY(mdy(sMesP,sDiaP,sAnoP)) INTO svt_fecha_udia
	FROM systables WHERE tabid = 1;
	
	LET sUdia = SUBSTR(svt_fecha_udia,4,2);
	---------------------------------------------------------------------------------------------
	
	------------------SOLICITUDES----------------------------------------------------------------
	DROP TABLE IF EXISTS tmp_tabla_solic;
    SELECT 
        month(S.fecha_insert) as mes
        , year(S.fecha_insert) as anio
        ,DECODE(MONTH(S.fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(S.fecha_insert) as mesDesc
        , count(*) as Solic_Cap 
        ,sum(case when C.tipo_cliente='1' then 1 else 0 end) as ctes_titulares
        ,sum(case when C.tipo_cliente='1' then 0 else 1 end) as ctes_no_titulares    
    FROM bdisolic:informix.ss_solicitudes S, bdinteg:informix.si_cliente C
    where 
        (S.fecha_insert >= mdy(sMesP,'01',sAnoP) and S.fecha_insert <= mdy(sMesP,sUdia,sAnoP) )
        and S.num_producto='6500'
        and (C.fecha_insert >= mdy(sMesP,'01',sAnoP) and C.fecha_insert <= mdy(sMesP,sUdia,sAnoP) )
        --and S.fecha_insert = C.fecha_insert
        and C.numcte=S.numcte
    group by 1,2,3 order by 2,1,3 asc
	INTO TEMP tmp_tabla_solic WITH NO LOG;

	SET ISOLATION TO DIRTY READ;
    FOREACH c1 FOR
		SELECT mes, anio, mesDesc, Solic_Cap, ctes_titulares, ctes_no_titulares
			INTO sMes, sAnio, sDescMes, sSolic_cap, sCtes_titulares, sCtes_no_titulares
		FROM tmp_tabla_solic			
    END FOREACH;
	--------------------------------------------------------------------------------------
	
	-------------------------------VALIDACION DE CORREO-----------------------------------
	DROP TABLE IF EXISTS tmp_tabla_valida_correo;
	select {+INDEX (bdinteg:"informix".si_correos idx_si_correos8)}
	month(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as mes2
	, year(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as anio2
	,DECODE(MONTH(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date) as mesDesc2
    ,count(*) as Total
    , sum(case when valida_correo='200' then 1 when valida_correo='210' then 1 when valida_correo='220' then 1 else 0 end) as cod_valid
    , sum(case when valida_correo='300' then 1 when valida_correo='400' then 1 when valida_correo='500' then 1 else 0 end) as cod_notvalid
    , sum(case when valida_correo is null then 1 else 0 end) as cod_NULL
    , sum(case when fecha_valida is null then 1 else 0 end) as fecha_valida_NULL
    , (sum(case when valida_correo='200' then 1 when valida_correo='210' then 1 when valida_correo='220' then 1 else 0 end) / count(*)) * 100 as validos
    from bdinteg:"informix".si_correos C, bdinteg:si_cliente T
    where substr(C.fecha_hora, 12, 5) between '10:00' and '20:00'
    and T.tipo_cliente='1'
    and cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date >= mdy(sMesP,'01',sAnoP)
    and cast(C.fecha_hora AS DATETIME YEAR to FRACTION(3))::date <= mdy(sMesP,sUdia,sAnoP)
    and T.numcte=C.numcte
    group by 2,1,3
    order by 2,1,3 asc
	INTO TEMP tmp_tabla_valida_correo WITH NO LOG;
	
    SET ISOLATION TO DIRTY READ;
    FOREACH c2 FOR
		SELECT mes2, anio2, mesDesc2, Total, cod_valid, cod_notvalid, cod_NULL, fecha_valida_NULL,validos
			INTO sMes2, sAnio2, sDescMes2, sTotal, sCod_valid, sCod_notvalid, sCod_null, sFecha_valida_null, sValidos
		FROM tmp_tabla_valida_correo			
    END FOREACH;
    ----------------------------------------------------------------------------

    ------------------------ALTAS DE CLIENTES-----------------------------------
    DROP TABLE IF EXISTS tmp_tabla_altas_ctes; 
    select month(fecha_insert) as mes3
    ,year(fecha_insert) as anio3
    ,DECODE(MONTH(fecha_insert),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(fecha_insert) as mesDesc3
    ,sum(case tipo_cliente when '1' then 1 else 0 end) as titulares
    , count(*) Todos
    , count(distinct(day(fecha_insert))) as diasPorMes
    , cast(sum(case tipo_cliente when '1' then 1 else 0 end) / count(distinct(day(fecha_insert))) as decimal(18,0)) as PromDiaTit
    , cast(count(*) / count(distinct(day(fecha_insert))) as decimal(18,0)) as PromDiaTod
    from bdinteg:si_cliente
    where empresa='001'
    and fecha_insert is not null
    and fecha_insert >= mdy(sMesP,'01',sAnoP) and fecha_insert <= mdy(sMesP,sUdia,sAnoP)
    group by 1,2,3
    order by 2,1,3 asc
    INTO TEMP tmp_tabla_altas_ctes WITH NO LOG;

    SET ISOLATION TO DIRTY READ;
    FOREACH c3 FOR
		SELECT mes3, anio3, mesDesc3, titulares, Todos, PromDiaTit, PromDiaTod
			INTO sMes3, sAnio3, sDescMes3, sTitulares, sTodos, sPromDiaTit, sPromDiaTod
		FROM tmp_tabla_altas_ctes			
    END FOREACH;
	--------------------------------------------------------------------------------
	
	-----------------------------------VALIDA CIFRAS---------------------------------	
	SELECT {+INDEX (bdinteg:"informix".si_fechas idx_si_fechas)}
	SUBSTR(LOWER(DECODE(MONTH(svt_fecha_hoy),1,'Enero',2,'Febrero',3,'Marzo',4,'Abril',5,'Mayo',6,'Junio',7,'Julio',8,'Agosto',9,'Septiembre',10,'Octubre',11,'Noviembre',12,'Diciembre') || ' ' || year(svt_fecha_hoy)),0,3)
	||'-'|| SUBSTR(sAnoP,3,2)
	INTO sDescMes  
	FROM bdinteg:si_fechas
	WHERE empresa = '001';	
	
	IF(sTitulares = '' OR sTitulares IS NULL) THEN
		LET sTitulares=0;
	END IF;
	
	IF(sSolic_cap = '' OR sSolic_cap IS NULL) THEN
		LET sSolic_cap=0;
	END IF;
	
	IF(sTotal = '' OR sTotal IS NULL) THEN
		LET sTotal=0;
	END IF;
	
	IF(sCod_valid = '' OR sCod_valid IS NULL) THEN
		LET sCod_valid=0;
	END IF;
			
	IF(sTotal = 0 OR sCod_valid = 0) THEN
		LET sPorcentaje=0;
		ELSE
		---------------------CALCULA PORCENTAJE-----------------------------------------
		LET sPorcentaje = SUBSTR(ROUND((sCod_valid / sTotal),2),3,2) || '%';
		--------------------INSERTA EN TABLA DE REPORTE---------------------------------
	END IF;
	---------------------------------------------------------------------------------
	
	INSERT INTO "informix".si_reporte_correos_validos(mes, altas_clientes, solicitudes_coppel, correos_capturados, correos_validos, porcentaje) 
    VALUES(sDescMes, TO_CHAR(sTitulares, "<<<,<<<,<<<,<<&"), TO_CHAR(sSolic_cap, "<<<,<<<,<<<,<<&"), TO_CHAR(sTotal, "<<<,<<<,<<<,<<&"), TO_CHAR(sCod_valid, "<<<,<<<,<<<,<<&"), sPorcentaje);
    --------------------------------------------------------------------------------
	
	----------Envio de correo automatico--------------------------------------------
	EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento_prod ('1', 'COR_CAP_AU', 'COR_CAP_AU','GRUPO_COR_CAP', '','', '1',
	sDescMes,TO_CHAR(sTitulares, "<<<,<<<,<<<,<<&"),TO_CHAR(sSolic_cap, "<<<,<<<,<<<,<<&"),TO_CHAR(sTotal, "<<<,<<<,<<<,<<&"),TO_CHAR(sCod_valid, "<<<,<<<,<<<,<<&"),sPorcentaje,'','','','','','',1,0,0,0,0,'','')
	INTO cCodRetC;
	--------------------------------------------------------------------------------
	
	LET cDesc= 'PROCESO EXITOSO';
	RETURN cCodRet, cDesc;
END 
END PROCEDURE;