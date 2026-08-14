CREATE PROCEDURE "informix".sp_get_indicadores_sucursal(dFechaInicial DATE, dFechaFinal DATE)
RETURNING CHAR(6), CHAR(100);
--VARIABLES DE ERROR
DEFINE cVarDataErr      	CHAR(100);
DEFINE iSqlErr          	INTEGER;
DEFINE iSamErr          	INTEGER;
DEFINE vCodRet          	CHAR(6);
--DEFINICION DE VARIABLES		
--DEFINE dFechahoy			DATE;	
DEFINE dfecha_alta			DATE;
DEFINE dmax_fecha_insert	DATE;
DEFINE iEnTransaccion		SMALLINT;
DEFINE vcod_param_sms		SMALLINT;
DEFINE vcod_param_cels		SMALLINT;
DEFINE vcod_param_correo	SMALLINT;
DEFINE vcod_param_alta_cte	SMALLINT; 
DEFINE iCod_param_ind_com   SMALLINT;
DEFINE vsms_val				INTEGER;
DEFINE vsms_total			INTEGER;
DEFINE vsms_no_val			INTEGER;
DEFINE ivalidos				INTEGER;
DEFINE iinvalidos			INTEGER;
DEFINE isin_validar			INTEGER;
DEFINE iBanco				INTEGER;
DEFINE icoppel				INTEGER;
DEFINE ibanco_coppel 		INTEGER;
DEFINE isolo_coppel 		INTEGER;
DEFINE isolo_banco			INTEGER;
DEFINE ibca_basica			INTEGER;
DEFINE ibca_avanzada		INTEGER;
--ALTA DE CLIENTES
DEFINE cnumcte				CHAR(20);
DEFINE cPromotor			CHAR(8);
DEFINE csucursal			CHAR(4);
DEFINE cProceso				CHAR(100);
DEFINE cEvento				CHAR(100);
DEFINE iTotal_tel_casa		INTEGER;
DEFINE iTotal_tel_casa_val	INTEGER;
DEFINE iTotal_tel_casa_inval INTEGER;
DEFINE iTotal_tel_casa_pen	INTEGER;
DEFINE iTotal_tel_casa_rep	INTEGER;
DEFINE iTotal_celular		INTEGER;
DEFINE iTotal_celular_val	INTEGER;
DEFINE iTotal_celular_inval	INTEGER;
DEFINE iTotal_celular_pen	INTEGER;
DEFINE iVerificados			INTEGER;
DEFINE iTotal_celular_rep	INTEGER;
DEFINE iTotal_otro			INTEGER;
DEFINE iTotal_otro_val		INTEGER;
DEFINE iTotal_otro_inval	INTEGER;
DEFINE iTotal_otro_pen		INTEGER;
DEFINE iTotal_otro_rep		INTEGER;
DEFINE iprospectos			INTEGER;
DEFINE iTitulares			INTEGER;
DEFINE isinproductos		INTEGER;
DEFINE dFechaProceso		DATE;
--MANTENIMIENTOS
DEFINE vcod_param_manntos_diarios SMALLINT;
DEFINE imannto_huella		INTEGER;
DEFINE imannto_direcciones	INTEGER;
DEFINE imannto_direcciones_casa	INTEGER;
DEFINE imannto_direcciones_oficina	INTEGER;
DEFINE imannto_correos		INTEGER;
DEFINE itel_casa			INTEGER;
DEFINE itel_celular			INTEGER;
DEFINE itel_oficina			INTEGER;
DEFINE itel_otro			INTEGER;
DEFINE cstatus_consulta		CHAR(1);				
DEFINE dfecha_solicitud		DATETIME YEAR TO FRACTION;
DEFINE dfecha_respuesta		DATETIME YEAR TO FRACTION;
DEFINE dtiempo_resp    		INTERVAL HOUR TO SECOND;
DEFINE usuario				CHAR(8);
DEFINE dfecha_insert		DATETIME YEAR TO FRACTION;

--ASIGNACION DE VARIABLES
--LET dFechahoy=CURRENT::DATE;
LET vcod_param_sms=0;
LET vcod_param_cels=0;
LET vcod_param_correo=0;
LET vsms_val=0;				
LET vsms_total=0;	
LET vsms_no_val=0;	
LET ivalidos=0;			
LET iinvalidos=0;
LET isin_validar=0;
LET iCod_param_ind_com=0;
LET iEnTransaccion = 0;
--ALTA DE CLIENTES
LET vcod_param_alta_cte=0;
LET cnumcte='';
LET iBanco=0;
LET icoppel=0;
LET ibanco_coppel=0;
LET isolo_coppel=0;
LET isolo_banco=0;
LET ibca_basica=0;
LET ibca_avanzada=0;
LET csucursal='';
LET iprospectos=0;
LET dfecha_alta='';
LET iTitulares=0;
LET isinproductos=0;			
--MANTENIMIENTOS
LET vcod_param_manntos_diarios=0;
LET imannto_huella=0;
LET imannto_direcciones=0;
LET imannto_direcciones_casa=0;
LET imannto_direcciones_oficina=0;
LET imannto_correos=0;
LET itel_casa=0;
LET itel_celular=0;
LET itel_oficina=0;
LET itel_otro=0;
LET cstatus_consulta ='';				
LET dfecha_solicitud ='';
LET dfecha_respuesta ='';
LET dtiempo_resp ='';
LET usuario	='';
LET dfecha_insert='';
LET cProceso = '';
LET cEvento = '';
LET dFechaProceso = '01011900';

--ASIGNACION DE VARIABLES ERROR
LET vCodRet = '000000';
LET cVarDataErr = 'EL REPORTE DE ESTADISTICAS, FUE GENERADO SATISFACTORIAMENTE';

--SET DEBUG FILE TO '/informix/josea/sp_get_indicadores_sucursal.out';
--TRACE ON;

BEGIN	
	ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
        IF iSqlErr <> 0 THEN
			LET vCodret=iSqlErr;
			
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;
			
			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cVarDataErr);
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_alta_ctes_titulares') THEN
				DROP TABLE tmp_alta_ctes_titulares;
			END IF;			
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut') THEN
				DROP TABLE tmp_sucursal_ejecut;
			END IF;			
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctenvos') THEN
				DROP TABLE tmp_telefonos_ctenvos;
			END IF;		
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_mantto_ctes_titulares') THEN
				DROP TABLE tmp_mantto_ctes_titulares;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctesmantto') THEN
				DROP TABLE tmp_telefonos_ctesmantto;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut_mantto') THEN
				DROP TABLE tmp_sucursal_ejecut_mantto;
			END IF;
	
			RETURN vCodret, iSamErr || ' ' ||cVarDataErr;
		END IF;
	END EXCEPTION;
	
	LET cProceso = 'PRINCIPAL';
	LET cEvento	= 'VALIDACION DE PARAMETROS DE ENTRADA';
	
	IF dFechaInicial > dFechafinal THEN
		LET vCodRet = '000001';
		LET cVarDataErr = 'PARAMETROS INCORRECTOS, FECHA INICIAL MAYOR A FECHA FINAL';
	ELIF (NVL(dFechaInicial,'') = '' OR NVL(dFechafinal,'') = '') THEN
		LET vCodRet = '000002';
		LET cVarDataErr = 'PARAMETROS INCORRECTOS, UNO O MAS PARAMETROS NULOS o VACIOS';
	ELSE
		LET cEvento	= 'OBTENCION DE PARAMETROS';
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;					
		
		SELECT valor 
		INTO vcod_param_sms
		FROM bdinteg:"informix".si_param 
		WHERE empresa='001'
		AND cod_param='312';
		
		SELECT valor 
		INTO vcod_param_cels
		FROM bdinteg:"informix".si_param 
		WHERE empresa='001'
		AND cod_param='310';
		
		SELECT valor 
		INTO vcod_param_correo
		FROM bdinteg:"informix".si_param 
		WHERE empresa='001'
		AND cod_param='311';
		
		SELECT NVL(valor,0)::INTEGER 
		INTO iCod_param_ind_com 
		FROM bdinteg:si_param WHERE cod_param = 343;

		LET dFechaProceso = dFechaInicial;
		
		WHILE (dFechaProceso <= dFechaFinal) LOOP				
			LET cEvento	= 'GENERACION TABLA TEMPORAL TMP_ALTA_CTES_TITULARES';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
			WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaproceso 
			AND a.tipo_cliente='1'	
			INTO TEMP tmp_alta_ctes_titulares
			WITH NO LOG;
			
			CREATE INDEX "informix".tmp_idx_alta_ctes_titulares ON tmp_alta_ctes_titulares (numcte, fecha_alta, sucursal);
			
			LET cEvento = 'GENERACION TABLA TEMPORAL TMP_MANTTO_CTES_TITULARES';
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT a.numcte, a.user_insert AS numemp, c.sucursal, a.fecha  AS fecha_alta
			FROM TABLE(MULTISET(SELECT DISTINCT user_insert, numcte, fecha_hora::DATE AS fecha FROM si_telefonos WHERE fecha_hora::DATE = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
							UNION ALL
							SELECT DISTINCT user_insert, numcte, fecha_hora::DATETIME YEAR TO FRACTION::DATE AS fecha FROM si_correos WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI'))) a,
			si_cliente b, si_ejecut c, si_cte_huella d
			WHERE a.numcte = b.numcte
			AND b.numcte = d.numcte
			AND b.tipo_cliente = '1'
			AND a.user_insert = c.ejecutivo
			AND d.secuencia = 1
			AND a.fecha > d.fecha_alta
			INTO TEMP tmp_mantto_ctes_titulares 
			WITH NO LOG;
			
			CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (numcte, fecha_alta, sucursal);
				
			LET cProceso = 'INDICADORES DE SMS';
			BEGIN WORK;
				LET iEnTransaccion = 1;
				IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_sms WHERE fecha = dFechaproceso ) THEN 		
					LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;											
					SELECT COUNT(*) AS sms_val
					INTO vsms_val 
					FROM bdinteg:si_telefonos WHERE telefono IN (
					SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 
					FROM bdimnsj:"informix".mnsjr_trx_online 
					WHERE id_mensaje = 'OFI_AVSMS' 
					AND fecha_hora_registro::DATE = dFechaproceso)
					AND tipo_tel='2' AND verificado='V' AND fecha_hora::DATE = dFechaproceso;		
						
					LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS_ACTUAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					SELECT COUNT(*) AS sms_total
					INTO vsms_total 
					FROM bdinteg:si_telefonos_actual WHERE telefono IN (
					SELECT {+INDEX (bdimnsj:"informix".mnsjr_trx_online inx_fh_idmsg)} celular_alterno 
					FROM bdimnsj:"informix".mnsjr_trx_online 
					WHERE id_mensaje = 'OFI_AVSMS' 
					AND fecha_hora_registro::DATE = dFechaproceso) 
					AND cofetel='V' AND tipo_tel='2' AND fecha_hora::DATE=dFechaproceso; 
					
					LET vsms_no_val = vsms_total - vsms_val;		
					
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_SMS';
					INSERT INTO bdinteg:"informix".si_estadistica_sms(fecha, sms_val, sms_no_val, total, porc_val, porc_no_val, user_insert, fecha_insert)
					VALUES (dFechaproceso, vsms_val, vsms_no_val, vsms_total, NVL(((NULLIF(vsms_val,0)/ NULLIF(vsms_total,0))*100),0), NVL(((NULLIF(vsms_no_val,0)/ NULLIF(vsms_total,0))*100),0), USER, CURRENT);
									
				END IF;	
			COMMIT WORK;
			LET iEnTransaccion = 0;
			---------------------------------------
			LET cProceso = 'INDICADORES DE CORREOS DE CLIENTES NUEVOS';
			BEGIN WORK;
				LET iEnTransaccion = 1;
				IF NOT EXISTS(SELECT 1 FROM bdinteg:si_estadistica_correos_clientes_nvos WHERE fecha = dFechaProceso) THEN 			
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_CLIENTES_NVOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					INSERT INTO bdinteg:"informix".si_estadistica_correos_clientes_nvos (sucursal, fecha, total, validos, invalidos, sin_validar, user_insert, fecha_insert)
					SELECT sucursal,dFechaproceso, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar, USER, CURRENT::DATE
					FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} d.sucursal,
										CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) ELSE 0 END AS validos,
										CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) ELSE 0 END AS invalidos,
										CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) ELSE 0 END AS sin_validar
										 
									FROM bdinteg:"informix".si_correos a, bdinteg:si_cliente b, bdinteg:"informix".si_cte_huella c, bdinteg:"informix".si_ejecut d
									WHERE a.numcte=b.numcte
									AND b.numcte=c.numcte
									AND b.tipo_cliente= '1'
									AND a.secuencia =1
									AND c.secuencia = 1
									AND c.fecha_alta = a.fecha_hora::DATETIME YEAR TO FRACTION::DATE
									AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE =dFechaproceso
									AND c.usuario = d.ejecutivo
									GROUP BY d.sucursal, a.valido
					))
					GROUP BY 1,2;
				END IF;
			COMMIT WORK;
			LET iEnTransaccion = 0;
			
			LET cProceso = 'INDICADORES DE CORREOS REPETIDOS';	
			BEGIN WORK;
				LET iEnTransaccion = 1;
				IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_correos WHERE fecha = dFechaProceso) THEN	--DIARIO		
					LET cEvento = 'OBTENCION DE INDICADORES DE SI_CORREOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;					
					SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
					INTO ivalidos, iinvalidos, isin_validar
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} 
												CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) END AS validos,
												CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) END AS invalidos,
												CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) END AS sin_validar
										FROM bdinteg:"informix".si_correos a, bdinteg:si_cliente b
										WHERE a.numcte=b.numcte
										AND a.status_correo='A'
										AND b.fecha_alta= dFechaproceso
										GROUP BY a.valido))); 
					
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS';
					INSERT INTO bdinteg:"informix".si_estadistica_correos(fecha, total, valido,invalido,sin_validar, user_insert, fecha_insert)
					VALUES(dFechaproceso, (NVL(ivalidos,0)+ NVL(iinvalidos,0)+ NVL(isin_validar,0)), NVL(ivalidos,0), NVL(iinvalidos,0), NVL(isin_validar,0), USER, CURRENT);				
					
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_REPETIDOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;					
					INSERT INTO bdinteg:"informix".si_estadistica_correos_repetidos(correo_elec, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
					SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_ctetipcorrstat)} b.correo_elec, COUNT(*) AS cantidad, a.sucursal, a.user_insert, a.fecha_alta, USER, CURRENT
					FROM bdinteg:si_cliente a, bdinteg:"informix".si_correos b
					WHERE a.numcte=b.numcte
					AND a.fecha_alta= dFechaproceso
					AND b.correo_elec<>'' 
					AND b.status_correo='A'
					GROUP BY 1,3,4,5
					HAVING COUNT(*) > 1;  			
				END IF;
			COMMIT WORK; 
			LET iEnTransaccion = 0;
			
			LET cProceso = 'INDICADORES DE CELULARES REPETIDOS';	
			BEGIN WORK;
				LET iEnTransaccion = 1;
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_estadistica_cels WHERE fecha = dFechaProceso ) THEN
					LET cEvento = 'OBTENCION DE INDICADORES DE SI_TELEFONOS_ACTUAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos
					INTO ivalidos, iinvalidos
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} 
									CASE WHEN a.cofetel = 'V' THEN COUNT(a.telefono) END AS validos,
									CASE WHEN a.cofetel = 'F' THEN COUNT(a.telefono) END AS invalidos                       
									FROM bdinteg:si_telefonos_actual a, bdinteg:si_cliente b 
									WHERE a.numcte=b.numcte
									AND a.tipo_tel='2' 
									AND a.status_tel='A'
									AND a.fecha_hora::DATE= dFechaproceso 
									AND b.fecha_alta= dFechaproceso
									GROUP BY a.cofetel)));					
					
					LET cEvento = 'INSERCION DE INDICADORES DE SI_ESTADISTICA_CELS';
					INSERT INTO bdinteg:"informix".si_estadistica_cels(fecha, total, validos, invalidos, user_insert, fecha_insert)
					VALUES(dFechaproceso, (NVL(ivalidos,0)+ NVL(iinvalidos,0)), NVL(ivalidos,0), NVL(iinvalidos,0), USER, CURRENT);	
					
					LET cProceso = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CELS_REPETIDOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;					
					INSERT INTO bdinteg:"informix".si_estadistica_cels_repetidos(telefono, cantidad, sucursal, usuario, fecha, user_insert, fecha_insert)
					SELECT  {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} a.telefono, COUNT(*) AS cantidad, b.sucursal, b.user_insert, b.fecha_alta, USER, CURRENT
					FROM bdinteg:si_telefonos_actual a, bdinteg:si_cliente b
					WHERE a.numcte=b.numcte
					AND a.tipo_tel='2' 
					AND a.status_tel='A'
					AND a.fecha_hora::DATE= dFechaproceso
					AND b.fecha_alta= dFechaproceso
					GROUP BY 1,3,4,5
					HAVING COUNT(*) > 1;			
				END IF; 
			COMMIT WORK;
			LET iEnTransaccion = 0;
			
			LET cProceso = 'INDICADORES DE ALTA DE CLIENTES';	
			BEGIN WORK;
				LET iEnTransaccion = 1;		
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_alta_ctes_indicadores WHERE fecha_proceso = dFechaProceso) THEN 					
					LET cEvento = 'INSERCION DE INDICADORES DE ALTA DE CLIENTES EN SI_ALTA_CTES_INDICADORES_SUC';	
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
					SELECT fecha_alta, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert
					FROM (TABLE(MULTISET(SELECT fecha_alta ,sucursal, NVL(COUNT(*),0) AS titulares,0 AS prospectos,0 AS total,0 AS tot_prod_coppel,0 AS tot_prod_banco,0 AS tot_cop_bco, 0 AS tot_sinproductos,0 AS tot_bca_basica,0 AS tot_bca_avanzada, USER AS user_insert, CURRENT AS fecha_insert
					FROM tmp_alta_ctes_titulares
					GROUP BY fecha_alta, sucursal 
					ORDER BY sucursal))); 			
					
					LET cEvento = 'GENERACION DE INDICADORES DE ALTA DE CLIENTES PROSPECTOS';	
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} sucursal, NVL(COUNT(*),0) AS prospectos
						INTO csucursal, iprospectos
						FROM bdinteg:si_cliente 
						WHERE tipo_cliente='2'
						AND fecha_alta= dFechaproceso
						GROUP BY sucursal  
						
						IF EXISTS (SELECT fecha_proceso FROM bdinteg:"informix".si_alta_ctes_indicadores_suc WHERE fecha_proceso = dfechaproceso AND sucursal = csucursal) THEN
							UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
							SET prospectos = iprospectos  
							WHERE fecha_proceso=dfechaproceso 
							AND sucursal=csucursal; 
						ELSE
							INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
							VALUES(dfechaproceso, csucursal, 0, NVL(iprospectos,0), NVL(iprospectos,0),0,0,0,0,0,0, USER, CURRENT);
						END IF;										
					END FOREACH; 
					
					LET cEvento = 'GENERACION DE INDICADORES DE PRODUCTOS DE NUEVOS CLIENTES TITULARES';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					FOREACH 
						SELECT DISTINCT sucursal 
						INTO csucursal
						FROM tmp_alta_ctes_titulares			
						FOREACH		
							SELECT numcte 
							INTO cnumcte
							FROM tmp_alta_ctes_titulares 
							WHERE sucursal=csucursal		
																	
							LET iBanco = 0;
							LET iCoppel = 0;
										
							IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cnumcte AND sucursal=csucursal) THEN
								LET iBanco=1;			
							ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud<>'C') THEN
								LET iBanco=1;
							ELIF EXISTS (SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cnumcte AND sucursal=csucursal) THEN
								LET iBanco=1;
							END IF;				
							IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud='C') THEN
								LET iCoppel=1; 
							END IF;	
							IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
								LET isinproductos = isinproductos + 1;  
							END IF;		
							IF (iBanco = 1 AND iCoppel=1 ) THEN
								LET ibanco_coppel=ibanco_coppel + 1;  
							ELSE
								LET isolo_coppel = isolo_coppel + iCoppel; 
								LET isolo_banco = isolo_banco + iBanco; 
							END IF;					
						END FOREACH;	
									
						LET cEvento = 'GENERACION DE INDICADORES DE BANCA BASICA/AVANZADA DE NUEVOS CLIENTES TITULARES';
						
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
						INTO ibca_basica, ibca_avanzada
						FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
											CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
											CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
											FROM bdinteg:"informix".si_bpiusuarios a, tmp_alta_ctes_titulares b
											WHERE a.numcte=b.numcte
											AND a.suc_registro = b.sucursal 
											AND a.suc_registro= csucursal
											AND a.f_registro::DATE=dFechaproceso
											AND b.fecha_alta::DATE=dFechaproceso
											GROUP BY a.servicio))); 
						
						UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
						SET total =(isolo_coppel + isolo_banco + ibanco_coppel + isinproductos), tot_prod_coppel=isolo_coppel, tot_prod_banco=isolo_banco, tot_cop_bco=ibanco_coppel, tot_sinproductos = isinproductos, tot_bca_basica=ibca_basica, tot_bca_avanzada=ibca_avanzada  
						WHERE fecha_proceso=dFechaproceso 
						AND sucursal=csucursal;				
						LET ibca_basica=0;
						LET ibca_avanzada=0;						
						LET ibanco_coppel=0;
						LET isolo_coppel=0;
						LET isolo_banco=0;
						LET isinproductos=0;				
					END FOREACH;
								
					LET ibanco_coppel = 0;
					LET isolo_coppel = 0;
					LET isolo_banco = 0;
					LET isinproductos = 0;	

					SELECT NVL(COUNT(*),0)
					INTO iTitulares
					FROM tmp_alta_ctes_titulares;
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} NVL(COUNT(*),0)
					INTO iProspectos
					FROM bdinteg:si_cliente
					WHERE tipo_cliente = '2'
					AND fecha_alta= dFechaproceso; 
									
					FOREACH --	AGREGAR LA SUCURSAL
						SELECT numcte, sucursal 
						INTO cnumcte, csucursal
						FROM tmp_alta_ctes_titulares
						
						LET iBanco = 0;
						LET iCoppel = 0;
						
						IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
							LET iBanco=1;
						ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud<>'C') THEN
							LET iBanco=1;			
						ELIF EXISTS(SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cnumcte AND sucursal=csucursal ) THEN
							LET iBanco=1;
						END IF;			
						IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cnumcte AND sucursal=csucursal AND tipo_solicitud='C') THEN
							LET iCoppel=1; 
						END IF;

						IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
							LET isinproductos = isinproductos + 1;  
						END IF;	
						IF (iBanco = 1 AND iCoppel=1) THEN
							LET ibanco_coppel = ibanco_coppel + 1;  
						ELSE
							LET isolo_coppel = isolo_coppel + iCoppel; 
							LET isolo_banco = isolo_banco + iBanco; 
						END IF;			
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE TOTAL CLIENTES CON BANCA BASICA/AVANZADA';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
					INTO ibca_basica, ibca_avanzada
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
										CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
										CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
										FROM bdinteg:"informix".si_bpiusuarios a, tmp_alta_ctes_titulares b
										WHERE a.numcte=b.numcte
										AND a.suc_registro= b.sucursal 
										AND a.f_registro::DATE=dFechaproceso
										AND b.fecha_alta::DATE=dFechaproceso
										GROUP BY a.servicio)));  
										
					INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
					VALUES (dFechaproceso, NVL(iTitulares,0), NVL(iProspectos,0), NVL(( iTitulares + iProspectos),0), NVL(isolo_coppel,0), NVL(isolo_banco,0) , NVL(ibanco_coppel,0), NVL(isinproductos,0), NVL(ibca_basica,0), NVL(ibca_avanzada,0), USER, CURRENT);
				
					IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
						INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
						VALUES(dFechaproceso, 0, 0, 0,0,0,0,0,0,0, USER, CURRENT);
					END IF;	
				END IF;
			COMMIT WORK;
			LET iEnTransaccion = 0;
			
			LET cProceso = 'INDICADORES DE MANTENIMIENTOS DIARIOS';	
			BEGIN WORK;
				LET iEnTransaccion = 1;	
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_manntos_diarios WHERE fecha_proceso = dFechaProceso) THEN
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE HUELLAS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT {+INDEX (bdisitesp:"informix".se_sitespctetmphis idx_se_sitespctetmphis_ctefecha)} COUNT(a.numcte) 
					INTO imannto_huella
					FROM bdisitesp:se_sitespctetmphis a INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte
					WHERE a.fecha= dFechaproceso
					AND b.tipo_cliente= '1'; 
					
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE DOMICILIOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;		
					SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_cte3)} COUNT(dir.numcte) AS imannto_direcciones
					INTO imannto_direcciones	
					FROM bdinteg:"informix".si_direcciones_actual dir 
					INNER JOIN	bdinteg:si_cliente cte ON dir.numcte = cte.numcte
					WHERE dir.fecha_insert = dFechaproceso
					AND dir.secuencia > 1
					AND dir.tipo_dir IN('1','2','3') 
					AND cte.tipo_cliente= '1'  
					AND cte.fecha_insert <> dFechaproceso;	 
							
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE CORREOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_cte_fhr_sec)} COUNT(a.numcte) 
					INTO imannto_correos 
					FROM bdinteg:"informix".si_correos a 
					INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte 
					WHERE a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso 
					AND a.secuencia > 1 
					AND b.tipo_cliente= '1'
					AND b.fecha_insert <> dFechaproceso; 
					
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE TELEFONOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT NVL(SUM(tel_casa),0) AS tel_casa, NVL(SUM(tel_celular),0) AS tel_celular, NVL(SUM(tel_oficina),0) AS tel_oficina, NVL(SUM(tel_otro),0) AS tel_otro
					INTO itel_casa, itel_celular, itel_oficina, itel_otro
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo )}  
										CASE WHEN a.tipo_tel= 1 THEN COUNT(telefono) END AS tel_casa,
										CASE WHEN a.tipo_tel= 2 THEN COUNT(telefono) END AS tel_celular,
										CASE WHEN a.tipo_tel= 3 THEN COUNT(telefono) END AS tel_oficina,
										CASE WHEN a.tipo_tel= 4 THEN COUNT(telefono) END AS tel_otro
										FROM bdinteg:si_telefonos_actual a INNER JOIN bdinteg:"informix".si_cliente b
										ON a.numcte=b.numcte
										WHERE b.fecha_insert <> dFechaproceso
										AND a.secuencia>1
										AND a.fecha_hora::DATE= dFechaproceso
										AND b.tipo_cliente= '1'
										GROUP BY a.tipo_tel)));	 
													
					LET cEvento = 'INSERCION DE INDICADORES EN SI_MANNTOS_DIARIOS';
					
					INSERT INTO bdinteg:"informix".si_manntos_diarios(fecha_proceso,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
					VALUES(dFechaproceso, NVL(imannto_huella,0), NVL(imannto_direcciones,0), NVL(itel_casa,0), NVL(itel_celular,0), NVL(itel_oficina,0), NVL(itel_otro,0), NVL(imannto_correos,0), USER, CURRENT);
					
					IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
						INSERT INTO bdinteg:"informix".si_manntos_diarios(fecha_proceso,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
						VALUES(dFechaproceso, 0, 0, 0,0,0,0,0, USER, CURRENT);
					END IF;	
							
					LET imannto_huella=0;
					LET imannto_direcciones=0;
					LET imannto_correos=0;
					LET itel_casa=0;
					LET itel_celular=0;
					LET itel_oficina=0;
					LET itel_otro=0;
								
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE HUELLAS POR SUCURSAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					FOREACH				
						SELECT {+INDEX (bdisitesp:"informix".se_sitespctetmphis idx_se_sitespctetmphis_ctefecha)} a.sucursal, COUNT(a.numcte) 
						INTO csucursal, imannto_huella
						FROM bdisitesp:se_sitespctetmphis a INNER JOIN bdinteg:"informix".si_cliente b ON a.numcte = b.numcte
						WHERE a.fecha= dFechaproceso
						AND b.tipo_cliente ='1'	
						GROUP BY a.sucursal ORDER BY a.sucursal		
						IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
							UPDATE bdinteg:"informix".si_manntos_diarios_suc 
							SET huellas = imannto_huella 
							WHERE sucursal = csucursal 
							AND fecha_proceso = dFechaproceso;
						ELSE 
							INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso,sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos, user_insert,fecha_insert)
							VALUES(dFechaproceso, csucursal, NVL(imannto_huella,0),0,0,0,0,0,0, USER, CURRENT);
						END IF;				
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE DIRECCIONES POR SUCURSAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".si_direcciones_actual idx_diract_cte3)}  b.sucursal, COUNT(a.numcte) AS imannto_direcciones
						INTO csucursal, imannto_direcciones
						FROM bdinteg:"informix".si_direcciones_actual a INNER JOIN bdinteg:"informix".si_cliente b
						ON a.numcte = b.numcte 
						WHERE a.fecha_insert = dFechaproceso 
						AND a.secuencia > 1
						AND b.fecha_insert <> dFechaproceso
						AND b.tipo_cliente ='1'
						GROUP BY b.sucursal ORDER BY 1	
						IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN --SQUENTIAL
							UPDATE bdinteg:"informix".si_manntos_diarios_suc 
							SET direcciones = imannto_direcciones 
							WHERE sucursal = csucursal 
							AND fecha_proceso = dFechaproceso;
						ELSE 
							INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso,sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos, user_insert,fecha_insert)
							VALUES(dFechaproceso,csucursal,0,NVL(imannto_direcciones,0),0,0,0,0,0, USER, CURRENT);
						END IF;			
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE CORREOS POR SUCURSAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					FOREACH	
						SELECT {+INDEX(bdinteg:"informix".si_correos idx_corr_cte_fhr_sec)}  b.sucursal, COUNT(a.numcte) AS imannto_correos
						INTO csucursal, imannto_correos
						FROM bdinteg:"informix".si_correos a INNER JOIN bdinteg:"informix".si_cliente b 
						ON a.numcte = b.numcte
						WHERE a.fecha_hora::DATETIME YEAR TO FRACTION::DATE= dFechaproceso 
						AND a.secuencia>1  
						AND b.fecha_insert <> dFechaproceso 
						AND b.tipo_cliente ='1'		
						GROUP BY b.sucursal 
						ORDER BY b.sucursal 	
						IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
							UPDATE bdinteg:"informix".si_manntos_diarios_suc 
							SET correos = imannto_correos 
							WHERE sucursal = csucursal 
							AND fecha_proceso = dFechaproceso;
						ELSE 
							INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso, sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
							VALUES(dFechaproceso, csucursal,0,0,0,0,0,0, NVL(imannto_correos,0), USER, CURRENT);
						END IF;		
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE MANTENIMIENTOS DE TELEFONOS POR SUCURSAL';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					FOREACH
						SELECT sucursal, NVL(SUM(tel_casa),0), NVL(SUM(tel_celular),0), NVL(SUM(tel_oficina),0), NVL(SUM(tel_otro),0)
						INTO csucursal, itel_casa, itel_celular, itel_oficina, itel_otro 
						FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_telefonos_actual idx_telact_ctetipo)} 
												CASE WHEN a.tipo_tel= 1 THEN COUNT(a.telefono) END AS tel_casa,
												CASE WHEN a.tipo_tel= 2 THEN COUNT(a.telefono) END AS tel_celular,
												CASE WHEN a.tipo_tel= 3 THEN COUNT(a.telefono) END AS tel_oficina,
												CASE WHEN a.tipo_tel= 4 THEN COUNT(a.telefono) END AS tel_otro, b.sucursal 
											FROM bdinteg:si_telefonos_actual a INNER JOIN bdinteg:"informix".si_cliente b 
											ON a.numcte=b.numcte
											WHERE b.fecha_insert <> dFechaproceso
											AND a.secuencia>1
											AND a.fecha_hora::DATE= dFechaproceso
											AND b.tipo_cliente ='1'
											GROUP BY a.tipo_tel, b.sucursal))
											GROUP BY sucursal ORDER BY sucursal			
						
						LET cEvento = 'INSERCION DE INDICADORES EN SI_MANNTOS_DIARIOS_SUC';
						IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_manntos_diarios_suc WHERE sucursal=csucursal AND fecha_proceso=dFechaproceso) THEN
							UPDATE bdinteg:"informix".si_manntos_diarios_suc 
							SET tel_casa=itel_casa, tel_cel=itel_celular, tel_ofi=itel_oficina,  tel_otro=itel_otro 
							WHERE sucursal=csucursal 
							AND fecha_proceso=dFechaproceso;
						ELSE 
							INSERT INTO bdinteg:"informix".si_manntos_diarios_suc(fecha_proceso, sucursal,huellas,direcciones,tel_casa,tel_cel,tel_ofi,tel_otro,correos,user_insert,fecha_insert)
							VALUES(dFechaproceso, csucursal, 0, 0, NVL(itel_casa,0),NVL(itel_celular,0),NVL(itel_oficina,0),NVL(itel_otro,0), 0,USER, CURRENT);
						END IF;				
					END FOREACH;	
				END IF; --TERMINA LOS MANNTOS. DIARIOS
			COMMIT WORK;
			LET iEnTransaccion = 0;
			
			LET cProceso = 'INDICADORES DE CORREOS/TELEFONOS DE MANTENIMIENTOS/CLIENTES NUEVOS';
			
			BEGIN WORK;
				LET iEnTransaccion = 1;
				IF NOT EXISTS(SELECT 1 FROM bdinteg:si_indicadores_ctes_nvos_det WHERE fecha = dFechaProceso) THEN
					LET cEvento	= 'GENERACION DE TABLA TEMPORAL TMP_SUCURSAL_EJECUT';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
					FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_alta_ctes_titulares c
					WHERE a.sucursal = b.sucursal
					AND b.ejecutivo = c.numemp
					INTO TEMP tmp_sucursal_ejecut
					WITH NO LOG;
					
					LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_sucursal_ejecut';
					CREATE INDEX "informix".idx_tmp_suc_ejecut ON tmp_sucursal_ejecut (ejecutivo, sucursal);
					
					LET cEvento	= 'INSERCION DE INDICADORES DE CORREOS DE NUEVOS CLIENTES TITULARES';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO bdinteg:si_indicadores_ctes_nvos_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
														  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
														  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
														  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
					SELECT '1', dFechaproceso, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos, 
							0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
					FROM TABLE(MULTISET(
					SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
					FROM 
					TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
								   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
													   FROM tmp_alta_ctes_titulares a 
													   LEFT JOIN
													   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
													   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																			   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																			   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																			   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																			FROM bdinteg:"informix".si_correos
																			WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																			GROUP BY user_insert, numcte, valido ))
																			GROUP BY user_insert, numcte)) b
													   ON a.numcte = b.numcte
													   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
								   GROUP BY numemp)) a
								   LEFT JOIN 
								   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
												  FROM bdinteg:"informix".si_correos a, tmp_alta_ctes_titulares b
												  WHERE a.numcte=b.numcte
												  AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
												  GROUP BY 1,2
												  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
								   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut b
					WHERE a.numemp = b.ejecutivo;
					
					LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS DE NUEVOS CLIENTES TITULARES';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT '1' AS tipo_movto, dFechaproceso AS fecha, a.numemp, 
						   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
						   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
						   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
					FROM TABLE(MULTISET(
					SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
						   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
						   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
					FROM tmp_alta_ctes_titulares a 
					LEFT JOIN
					TABLE(MULTISET(SELECT user_insert, numcte,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
											NVL(SUM(verificado),0) AS verificados,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
											FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
																FROM
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
																	   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
																	   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
																	   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
																FROM bdinteg:"informix".si_telefonos
																WHERE fecha_hora::DATE = dFechaproceso
																GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																			   FROM bdinteg:"informix".si_telefonos
																			   WHERE fecha_hora::DATE = dFechaproceso
																			   AND verificado = 'V' 
																			   AND tipo_tel = '2'
																			   GROUP BY user_insert, numcte, tipo_tel)) b
																ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
														))
											GROUP BY user_insert, numcte, tipo_tel))b
					ON a.numcte = b.numcte GROUP BY 1,2)) a 
					LEFT JOIN
					TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
									   FROM 
									   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
															 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
															 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
															 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
													  FROM bdinteg:"informix".si_telefonos a, tmp_alta_ctes_titulares b
													  WHERE a.numcte=b.numcte
													  AND a.user_insert = b.numemp
													  AND a.fecha_hora::DATE = dFechaproceso
													  GROUP BY b.numemp, a.telefono, a.tipo_tel
													  HAVING COUNT(a.telefono) >1))
									   GROUP BY 1)) b
					ON a.numemp = b.numemp
					GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
					INTO TEMP tmp_telefonos_ctenvos WITH NO LOG;
					
					LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES TITULARES';
					
					MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a 
					USING tmp_telefonos_ctenvos AS b
					ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
					WHEN MATCHED THEN UPDATE
					SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep, 
						telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
						telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;
					
					LET cEvento	= 'GENERACION DE TABLA TEMPORAL TMP_SUCURSAL_EJECUT_MANTTO';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
					FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_mantto_ctes_titulares c
					WHERE a.sucursal = b.sucursal
					AND b.ejecutivo = c.numemp
					INTO TEMP tmp_sucursal_ejecut_mantto
					WITH NO LOG;			
					
					LET cEvento	= 'ACTUALIZACION DE TABLA TEMPORAL TMP_SUCURSAL_EJECUT';
					
					MERGE INTO tmp_sucursal_ejecut a
						USING tmp_sucursal_ejecut_mantto b
						ON a.ejecutivo= b.ejecutivo
						AND a.sucursal = b.sucursal
					WHEN NOT MATCHED THEN
						INSERT (a.sucursal, a.nom_suc, a.ejecutivo, a.nom_emp)
							VALUES 
								(b.sucursal, b.nom_suc, b.ejecutivo, b.nom_emp);
					
					LET cEvento	= 'OBTENCION DE INDICADORES DE CORREOS CLIENTES TITULARES CON MANTENIMIENTO';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					INSERT INTO bdinteg:si_indicadores_ctes_nvos_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
														  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
														  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
														  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
					SELECT DISTINCT '2' AS tipo_mov, dFechaproceso AS fecha, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos, 
							0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
					FROM TABLE(MULTISET(
					SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
					FROM 
					TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
								   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
													   FROM tmp_mantto_ctes_titulares a 
													   LEFT JOIN
													   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
													   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																			   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																			   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																			   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																			FROM bdinteg:"informix".si_correos
																			WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																			GROUP BY user_insert, numcte, valido ))
																			GROUP BY user_insert, numcte)) b
													   ON a.numcte = b.numcte
													   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
								   GROUP BY numemp)) a
								   LEFT JOIN 
								   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
												  FROM bdinteg:"informix".si_correos a, tmp_mantto_ctes_titulares b
												  WHERE a.numcte=b.numcte
												  AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
												  GROUP BY 1,2
												  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
								   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut_mantto b
					WHERE a.numemp = b.ejecutivo;
					
					LET cEvento	= 'OBTENCION DE INDICADORES DE TELEFONOS CLIENTES TITULARES CON MANTENIMIENTO';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					SELECT '2' AS tipo_movto, dFechaproceso AS fecha, a.numemp, 
						   NVL(SUM(a.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(a.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(a.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(a.total_tel_casa_pen),0) AS total_tel_casa_pen, NVL(b.tel_casa_rep,0) AS total_tel_casa_rep,
						   NVL(SUM(a.total_celular), 0) AS total_celular, NVL(SUM(a.total_celular_val),0) AS total_celular_val, NVL(SUM(a.total_celular_inval),0) AS total_celular_inval, NVL(SUM(a.total_celular_pen),0) AS total_celular_pen, NVL(SUM(a.verificados),0) AS verificados, NVL(b.tel_cel_rep,0) AS total_tel_cel_rep,
						   NVL(SUM(a.total_otro), 0) AS total_otro, NVL(SUM(a.total_otro_val),0) AS total_otro_val, NVL(SUM(a.total_otro_inval),0) AS total_otro_inval, NVL(SUM(a.total_otro_pen),0) AS total_otro_pen, NVL(b.tel_otro_rep,0) AS total_tel_otro_rep
					FROM TABLE(MULTISET(
					SELECT a.numemp, a.numcte, NVL(SUM(b.total_tel_casa), 0) AS total_tel_casa, NVL(SUM(b.total_tel_casa_val),0) AS total_tel_casa_val, NVL(SUM(b.total_tel_casa_inval),0) AS total_tel_casa_inval, NVL(SUM(b.total_tel_casa_pen),0) AS total_tel_casa_pen,
						   NVL(SUM(b.total_celular), 0) AS total_celular, NVL(SUM(b.total_celular_val),0) AS total_celular_val, NVL(SUM(b.total_celular_inval),0) AS total_celular_inval, NVL(SUM(b.total_celular_pen),0) AS total_celular_pen, NVL(SUM(b.verificados),0) AS verificados,
						   NVL(SUM(b.total_otro), 0) AS total_otro, NVL(SUM(b.total_otro_val),0) AS total_otro_val, NVL(SUM(b.total_otro_inval),0) AS total_otro_inval, NVL(SUM(b.total_otro_pen),0) AS total_otro_pen
					FROM tmp_mantto_ctes_titulares a 
					LEFT JOIN
					TABLE(MULTISET(SELECT user_insert, numcte,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(validos),0) ELSE 0 END AS total_tel_casa_val,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_tel_casa_inval,
											CASE WHEN tipo_tel = '1' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_tel_casa_pen,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(validos),0) ELSE 0 END AS total_celular_val,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_celular_inval,
											CASE WHEN tipo_tel = '2' THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_celular_pen,
											NVL(SUM(verificado),0) AS verificados,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(validos),0) ELSE 0 END AS total_otro_val,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(invalidos),0) ELSE 0 END AS total_otro_inval,
											CASE WHEN tipo_tel NOT IN('1','2') THEN NVL(SUM(sin_validar),0) ELSE 0 END AS total_otro_pen
											FROM TABLE(MULTISET(SELECT a.user_insert, a.numcte, a.tipo_tel, a.validos, a.invalidos, a.sin_validar, b.verificado
																FROM
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel,
																	   CASE WHEN cofetel = 'V' THEN COUNT(telefono) ELSE 0 END AS validos,
																	   CASE WHEN cofetel = 'F' THEN COUNT(telefono) ELSE 0 END AS invalidos,
																	   CASE WHEN cofetel IS NULL THEN COUNT(telefono)ELSE 0  END AS sin_validar
																FROM bdinteg:"informix".si_telefonos
																WHERE fecha_hora::DATE = dFechaproceso
																GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																			   FROM bdinteg:"informix".si_telefonos
																			   WHERE fecha_hora::DATE = dFechaproceso
																			   AND verificado = 'V' 
																			   AND tipo_tel = '2'
																			   GROUP BY user_insert, numcte, tipo_tel)) b
																ON a.user_insert = b.user_insert AND a.numcte = b.numcte AND a.tipo_tel = b.tipo_tel
														))
											GROUP BY user_insert, numcte, tipo_tel))b
					ON a.numcte = b.numcte GROUP BY 1,2)) a 
					LEFT JOIN
					TABLE(MULTISET(SELECT numemp, SUM(NVL(tel_casa_rep,0)) AS tel_casa_rep, SUM(NVL(tel_cel_rep,0)) AS tel_cel_rep, SUM(NVL(tel_otro_rep,0)) AS tel_otro_rep
									   FROM 
									   TABLE(MULTISET(SELECT b.numemp AS numemp, a.telefono,
															 CASE WHEN a.tipo_tel = '1' THEN COUNT(a.telefono) ELSE 0 END AS tel_casa_rep,
															 CASE WHEN a.tipo_tel = '2' THEN COUNT(a.telefono) ELSE 0 END AS tel_cel_rep,
															 CASE WHEN a.tipo_tel NOT IN('1','2') THEN COUNT(a.telefono) ELSE 0 END AS tel_otro_rep
													  FROM bdinteg:"informix".si_telefonos a, tmp_mantto_ctes_titulares b
													  WHERE a.numcte=b.numcte
													  AND a.user_insert = b.numemp
													  AND a.fecha_hora::DATE = dFechaproceso
													  GROUP BY b.numemp, a.telefono, a.tipo_tel
													  HAVING COUNT(a.telefono) >1))
									   GROUP BY 1)) b
					ON a.numemp = b.numemp
					GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
					INTO TEMP tmp_telefonos_ctesmantto WITH NO LOG;
							
					LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES CON MANTENIMIENTO';
					
					MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a 
					USING tmp_telefonos_ctesmantto AS b
					ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
					WHEN MATCHED THEN UPDATE
					SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep, 
						telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
						telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;
					
					LET cEvento	= 'OBTENCION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES/MANTENIMIENTOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO bdinteg:si_indicadores_ctes_nvos (tipo_movto, fecha, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
																  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
																  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
																  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep) 
					SELECT tipo_movto, fecha, NVL(SUM(altas_ctes),0), NVL(SUM(correo_cap),0), NVL(SUM(correo_val),0),  NVL(SUM(correo_inval),0), NVL(SUM(correo_pen),0), NVL(SUM(correo_rep),0), 
						   NVL(SUM(telcasa_cap),0), NVL(SUM(telcasa_val),0), NVL(SUM(telcasa_inval),0), NVL(SUM(telcasa_pen),0), NVL(SUM(telcasa_rep),0), 
						   NVL(SUM(telcel_cap),0), NVL(SUM(telcel_val),0), NVL(SUM(telcel_inval),0), NVL(SUM(telcel_pen),0), NVL(SUM(telcel_ver),0), NVL(SUM(telcel_rep),0), 
						   NVL(SUM(telotro_cap),0), NVL(SUM(telotro_val),0), NVL(SUM(telotro_inval),0), NVL(SUM(telotro_pen),0), NVL(SUM(telotro_rep),0)
					FROM si_indicadores_ctes_nvos_det
					WHERE fecha = dFechaproceso
					--AND tipo_movto = '1'
					GROUP BY 1,2;						
				
					LET cEvento	= 'INSERCION DE INDICADORES EN BDIBI';
					
					IF iCod_param_ind_com = 1 THEN					
						--INSERT INTO bdibi@coppel_tcp:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut, 				Pruebas
						INSERT INTO bdibi@stag_ids_1170_tcp:"informix".bi_indicadores_ctes_nvos_det (tipo_movto, fecha, sucursal, nombre_suc, ejecutivo, nombre_ejecut, 
																		altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
																		telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
																		telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
																		telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
						SELECT a.tipo_movto, a.fecha, a.sucursal, b.nom_suc, a.ejecutivo, b.nom_emp, 
							   a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep, 
							   a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep, 
							   a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep, 
							   a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep
						FROM  bdinteg:si_indicadores_ctes_nvos_det a , tmp_sucursal_ejecut b
						WHERE a.ejecutivo = b.ejecutivo
						AND a.sucursal = b.sucursal
						--AND a.tipo_movto = '1'
						AND a.fecha = dFechaproceso;
						
					END IF;
				END IF;
			COMMIT WORK;
			LET iEnTransaccion = 0;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_alta_ctes_titulares') THEN
				DROP TABLE tmp_alta_ctes_titulares;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut') THEN
				DROP TABLE tmp_sucursal_ejecut;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctenvos') THEN
				DROP TABLE tmp_telefonos_ctenvos;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_mantto_ctes_titulares') THEN
				DROP TABLE tmp_mantto_ctes_titulares;
			END IF;
			
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_telefonos_ctesmantto') THEN
				DROP TABLE tmp_telefonos_ctesmantto;
			END IF;
				
			IF EXISTS (SELECT dbsname,tabname FROM sysmaster:"informix".systabnames WHERE tabname = 'tmp_sucursal_ejecut_mantto') THEN
				DROP TABLE tmp_sucursal_ejecut_mantto;
			END IF;
			
			LET dFechaProceso = dFechaProceso + 1 UNITS DAY;
		END LOOP;
	END IF;
	IF vCodRet <> '000000' THEN
		INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
		VALUES (dFechaProceso, cProceso, cEvento, vCodret, cVarDataErr);
	END IF;
	RETURN vCodRet,cVarDataErr;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se genera procedimiento almacenado para contingencias, el cual podra ejecutarse para calcular las estadisticas de comportamiento',
'de una fecha especifica',
'FECHA:16/06/2015',
'VERSION:20150616.01',
'ELABORO: Jose Angel Lopez Adams',
'SOLICITA:José Ángel López Adams',
'BASE DE DATOS:bdinteg';

CREATE PROCEDURE "informix".sp_cnsif_consultamovtosdiarioscta4(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20), pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2), pNumRegistro INTEGER,pRecuperacion INTEGER)
				returning 	CHAR(5)  AS Cod_Retorno,
							DATE     AS Fecha,
							DATETIME HOUR to FRACTION(3) AS Hora,
							CHAR(4)  AS CveTransaccion,
							CHAR(120) AS Desc_Transaccion,
							CHAR(16) AS Folio,
							DATE     AS Periodo_Inicial,
							MONEY(14,2) AS Monto,
							DATE     AS Periodo_Final,
							CHAR(20) AS Sistema_Cuenta,
							CHAR(1)  AS Naturaleza,
							CHAR(40) AS Referencia,
							CHAR(1)  AS Reversos,
							CHAR(4)  AS Sucursal,
							CHAR(20) AS CveProcedencia,
							CHAR(50) AS Desc_Procedencia,
							MONEY(14,2) AS Saldo,
							CHAR(20) AS Numero_Tarjeta,
							CHAR(1)  AS Reversados,
							CHAR(8)  AS Usuario,
							CHAR(23) AS Referencia23;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(120);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cRfcComer           CHAR(10);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
--inicializando variables
LET  iexiste = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET  iExisteCta = 0;
LET  cRfcComer = '';

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
	END EXCEPTION;
                
     --SET DEBUG FILE TO "/informix/CHVN/sp_cnsif_consultamovtosdiarioscta4.out";
     --TRACE ON;
              
	IF cID_USUARIOC = '' OR cID_FUNCIONC = '' OR cNUMCUENTA  = '' OR dPERIODOI IS NULL OR dPERIODOF IS NULL OR cSISTEMACUENTA = '' THEN
		LET cCodRet = "00036";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;

    IF pNumRegistro<0 THEN
		LET cCodRet='00098';
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;                        
    ELSE
        IF pRecuperacion<=0 THEN
			LET cCodRet='00098';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
        END IF;
    END IF; 
	IF cSISTEMACUENTA <> 'CAPTACION' AND cSISTEMACUENTA <> 'CREDITO'  AND cSISTEMACUENTA <> 'INVERSIONES' THEN
		LET cCodRet = "00037";
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
		cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;

     --VALIDACION
	IF cSISTEMACUENTA = 'CAPTACION' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'01','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'CREDITO' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'06','1')
		INTO cCodRet;
	END IF;

	IF cSISTEMACUENTA = 'INVERSIONES' THEN
		EXECUTE PROCEDURE sp_cnsif_permisosejecutivo(cID_USUARIOC,cID_FUNCIONC, cNUMCUENTA,'03','1')
		INTO cCodRet;
	END IF;

	IF (cCodRet != '00000')  THEN
		RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			  cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
	END IF;
    -- TERMINA VALIDACION
     IF cSISTEMACUENTA = 'CAPTACION' THEN
		SET ISOLATION TO DIRTY READ;
		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';
	
		SET ISOLATION TO DIRTY READ;
		FOREACH               
			SELECT SKIP pNumRegistro FIRST pRecuperacion MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,
			MO.referencia,MO.cancelad, MO.sucursal,MO.folio_suc, dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			INTO dFecha,dHora,cTransaccion,cD_Transaccion,mMonto,cNaturaleza,mSaldo,cReferencia,cReversos,cSucursal,cFolio,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cNumtarjeta,cUsuario,cReferencia23
			FROM bdicheq:sc_movdia MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF AND MO.empresa='001' 
			AND MO.cuenta = cNUMCUENTA
		UNION
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion ,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
				MO.sucursal,MO.folio_suc,dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			FROM bdicheq:sc_movhis MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt >= cconsmovhis
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.empresa = TR.empresa
			AND MO.cuenta = cNUMCUENTA
		UNION
			SELECT MO.fech_alt,MO.fech_hor,MO.transacc,TRIM(NVL(TR.descripcion,""))||" "||TRIM(NVL(MO.referencia,"")) AS descripcion,MO.monto_tot,TR.naturaleza,MO.sdo_cuenta,MO.referencia,MO.cancelad,
					MO.sucursal,MO.folio_suc,dPERIODOI,dPERIODOF,MO.num_serial,MO.num_tarjeta,MO.usuario,MO.referencia_23
			FROM bdicheq:sc_movhis_old  MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = 'S'
			WHERE MO.fech_alt >= cconsmovhisold
			AND MO.fech_alt < cconsmovhis
			AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
			AND MO.empresa='001'
			AND MO.cuenta = cNUMCUENTA
		ORDER BY MO.num_serial, MO.fech_alt DESC

			IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
			ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
				SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
			ELSE
				LET cProcedencia="";
				LET cD_Procedencia="";
			END IF;
			   
			LET iCont=iCont+1;
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
		END FOREACH;

		IF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
				   cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF;
			
     ELIF cSISTEMACUENTA = 'CREDITO' THEN
	 
		SET ISOLATION TO DIRTY READ;
		FOREACH
			SELECT SKIP pNumRegistro FIRST pRecuperacion {+INDEX (bdicred:sd_movdia mov4)} MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,
			MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia, MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			INTO          
			cCodfun,cCodref,dFecha,dHora,cNumtarjeta,cFolio,cTransaccion,cD_Transaccion,cRfcComer,cReferencia,mMonto,cNaturaleza,cReversos,cSucursal,
			dPeriodoI_1,dPeriodoF_1,sNUMSERIAL,cUsuario,cReferencia23
			FROM bdicred:sd_movdia MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = 'S'
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
		UNION
			SELECT {+INDEX(bdicred:"informix".sd_movhis inx_movhis4)}
			MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			FROM bdicred:sd_movhis MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = 'S'
			WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
/*			UNION
			   SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
			MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			   FROM bdicred:sd_maecredcrd MC
			   LEFT JOIN bdicred:sd_movdiacrd  MO
			   ON MC.num_credito = MO.num_credito
			   LEFT JOIN bdicred:sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			   LEFT JOIN bdinteg:si_transacc TS
			   ON TR.transacc = TS.numero
			   WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA
			   AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
			   AND TS.se_emite_edocta = 'S'
			UNION
			   SELECT MO.codigo_fun,MO.codigo_ref,MO.fecha_mov,MO.hora_mov,MO.nro_tarjeta,MO.folio_suc,  
			MO.transacc_suc,TR.descripcion,MO.rfc_comer,
			MO.referencia,MO.monto,TR.sentido,MO.reversado,MO.sucursal,dPERIODOI,dPERIODOF,MO.secuencia,MO.usuario,MO.referencia23
			   FROM bdicred:sd_maecredcrd MC
			   LEFT JOIN bdicred:sd_movhiscrd  MO
			   ON MC.num_credito = MO.num_credito
			   LEFT JOIN bdicred:sd_transfun TR
			   ON MO.codigo_fun= TR.codigo_fun and MO.codigo_ref= TR.codigo_ref
			   LEFT JOIN bdinteg:si_transacc TS
			   ON TR.transacc = TS.numero
			   WHERE MO.num_credito = cNUMCUENTA
			   AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
			   AND TS.se_emite_edocta = 'S'*/
		ORDER BY MO.secuencia DESC
			
			IF cReferencia is NULL THEN
				 if trim(cD_Transaccion) = "SU PAGO CON CHEQUE" then
                    LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'') || " " || trim(cReferencia23);
                else
    				LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'');
                end if;
			ELSE
				IF cReferencia[1,1] = "i" THEN
                   IF (cTransaccion in ('6800','6871','6873')) THEN
                       LET cD_Transaccion = TRIM(SUBSTRING(cReferencia FROM 18))||NVL(TRIM(cReferencia23),'');
				   ELIF (cTransaccion = '6901') THEN
							  LET cD_Transaccion =  NVL(TRIM(cD_Transaccion),'');	   							  	   							  							  	   
                   ELSE
                       LET cD_Transaccion = NVL(TRIM(SUBSTRING(cReferencia FROM 18)),'')
                                        || "  " ||
                                        NVL(TRIM(cRfcComer),'')
                                        || "  " ||
                                        NVL(TRIM(cReferencia23),'');
                   END IF

                   IF cD_Transaccion[1,1] = "i" THEN
                        LET cD_Transaccion = TRIM(SUBSTRING(cD_Transaccion FROM 18));
                   END IF

				ELSE
                    IF TRIM(cD_Transaccion) = "PAGO CORRESPONSAL COPPEL" THEN
                        LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'')|| "  " ||TRIM(cReferencia);
                    ELSE
                        LET cD_Transaccion = NVL(TRIM(cD_Transaccion),'')|| "  " ||TRIM(cReferencia[1,16]);
                    END IF
				END IF
			END IF
			
            IF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND sucursal=cSucursal AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE transacc=cTransaccion AND transacc<>'';
            ELIF (SELECT NVL(COUNT(*),0) FROM si_procedencia WHERE sucursal=cSucursal AND transacc='')>0 THEN
                SELECT LIMIT 1 procedencia,descripcion INTO cProcedencia,cD_Procedencia FROM si_procedencia WHERE sucursal=cSucursal AND transacc='';
            ELSE
                LET cProcedencia="";
                LET cD_Procedencia="";
            END IF;
              
			LET iCont=iCont+1;

			IF cCodfun ='001' AND cCodref in (1,2,3) THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELIF cCodfun ='002' AND cCodref =1 THEN
				IF iCont>0 THEN
					 LET iCont=iCont - 1;
				END IF;
			ELSE
					 RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
					 cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23 WITH resume;
			END IF;
		END FOREACH;
                        
		IF iCont = 0 AND pNumRegistro=0 THEN
			LET cCodRet = '00039';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		ELIF iCont = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cTransaccion,cD_Transaccion,cFolio,dPeriodoI_1,mMonto,dPeriodoF_1,cSISTEMACUENTA,cNaturaleza,
			cReferencia,cReversos,cSucursal,cProcedencia,cD_Procedencia,mSaldo,cNumtarjeta,cReversados,cUsuario,cReferencia23;
		END IF
     END IF
END

END PROCEDURE

DOCUMENT
"AUTOR : CESAR HORACIO VELAZQUEZ NERIA",
"FUNCIONAMIENTO:Este sp realizara la busqueda de movimientos por cuenta para el kiosko de informacion",
"FECHA : 27-11-2014",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_depura_telefonos( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), INTEGER, INTEGER; 
    
    DEFINE cCodRet      CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iIsamErr     INTEGER;
    DEFINE cDescErr     CHAR(50);
    DEFINE iTransacc    SMALLINT;
    DEFINE iContador    INTEGER;
    DEFINE iContador2   INTEGER;
    DEFINE cNumCte      CHAR(20);
    DEFINE iTipoTel     SMALLINT;
    DEFINE iMaxSec      SMALLINT;
    DEFINE iCuantos     SMALLINT;
    DEFINE cTelefono    CHAR(13);
    DEFINE iSecuencia   SMALLINT;
    DEFINE cExtension   CHAR(5);
    DEFINE iCarrier     SMALLINT;
    DEFINE iCanal       SMALLINT;
    DEFINE iContacto    SMALLINT;
    DEFINE cCofetel     CHAR(1);
    DEFINE dFecha       DATETIME YEAR TO SECOND;
    DEFINE cUser        CHAR(8);
    DEFINE cMovil       CHAR(1);
    DEFINE cStatus      CHAR(1);
    
    LET cCodRet    = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iIsamErr   = 0;
    LET cDescErr   = '';
    LET iTransacc  = 0;
    LET iContador  = 0;
    LET iContador2 = 0;
    LET cNumCte    = '';
    LET iTipoTel   = 0;
    LET iMaxSec    = 0;
    LET iCuantos   = 0;
    LET cTelefono  = '';
    LET iSecuencia = 0;
    LET cExtension = '';
    LET iCarrier   = 0;
    LET iCanal     = 0;
    LET iContacto  = 0;
    LET cCofetel   = '';
    LET dFecha     = '';
    LET cUser      = '';
    LET cMovil     = '';
    LET cStatus    = '';
    
    BEGIN
    
    ON EXCEPTION SET iSqlErr, iIsamErr, cDescErr
        SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            LET cCodRet2 = iIsamErr;
            LET cCodRet3 = cDescErr;
            IF iTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN cCodRet, iContador, iContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/informix/jivan/sp_depura_telefonos.out";
    --- TRACE ON;
    
    UPDATE STATISTICS MEDIUM FOR TABLE si_ctesdepurados;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    -- // OBTIENE CLIENTES A PROCESAR
    FOREACH WITH HOLD
        SELECT UNIQUE numcte
          INTO cNumCte
          FROM si_telefonos
         WHERE numcte NOT IN( SELECT numcte FROM si_ctesdepurados )
           AND tipo_tel IN( 1, 2, 3, 4 ) 
           AND status_tel = 'A'
         
        -- // ABRE TRANSACCION
        BEGIN WORK;
        LET iTransacc = 1;
        
        -- // TIPOS DE TELEFONO POR CLIENTE
        FOREACH WITH HOLD
            SELECT UNIQUE tipo_tel
              INTO iTipoTel
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND status_tel = 'A'
        
            SELECT MAX(secuencia)
              INTO iMaxSec
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND status_tel = 'A';
               
            -- // VALIDACIONES EN TABLA DE TELEFONOS
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia < iMaxSec
               AND status_tel = 'A';
           
            IF iCuantos > 0 THEN               
                UPDATE si_telefonos
                   SET status_tel = 'C'
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel
                   AND secuencia < iMaxSec
                   AND status_tel = 'A';
            END IF;
            
            -- // VALIDACIONES EN TABLA DE TELEFONOS ACTUALES
            SELECT telefono, extension, carrier, canal, contacto, cofetel, fecha_hora, user_insert, movil_fijo, status_stel
              INTO cTelefono, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus
              FROM si_telefonos
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec;
            
            SELECT COUNT(*)
              INTO iCuantos
              FROM si_telefonos_actual
             WHERE numcte = cNumCte
               AND tipo_tel = iTipoTel
               AND secuencia = iMaxSec
               AND status_tel = 'A'
               AND telefono = cTelefono
               AND extension = cExtension
               AND carrier = iCarrier
               AND canal = iCanal
               AND contacto = iContacto
               AND cofetel = cCofetel
               AND fecha_hora = dFecha
               AND user_insert = cUser
               AND movil_fijo = cMovil
               AND status_stel = cStatus;
           
            IF iCuantos = 0 THEN 
                SELECT COUNT(*)
                  INTO iCuantos
                  FROM si_telefonos_actual
                 WHERE numcte = cNumCte
                   AND tipo_tel = iTipoTel;
                   
                IF iCuantos > 0 THEN 
                    UPDATE si_telefonos_actual
                       SET secuencia = iMaxSec,
                           status_tel = 'A',
                           telefono = cTelefono,
                           extension = cExtension,
                           carrier = iCarrier,
                           canal = iCanal,
                           contacto = iContacto,
                           cofetel = cCofetel,
                           fecha_hora = dFecha,
                           user_insert = cUser,
                           movil_fijo = cMovil,
                           status_stel = cStatus
                     WHERE numcte = cNumCte
                       AND tipo_tel = iTipoTel;
                ELSE
                    INSERT INTO si_telefonos_actual VALUES
                    ( pEmpresa, cNumCte, cTelefono, iTipoTel, 'A', iMaxSec, cExtension, iCarrier, iCanal, iContacto, cCofetel, dFecha, cUser, cMovil, cStatus );
                END IF;
                
                LET iContador2 = iContador2 + 1;
            END IF;
            
            LET iCuantos   = 0;
            LET iTipoTel   = 0;
            LET iMaxSec    = 0;
            LET cTelefono  = '';
            LET iSecuencia = 0;
            LET cExtension = '';
            LET iCarrier   = 0;
            LET iCanal     = 0;
            LET iContacto  = 0;
            LET cCofetel   = '';
            LET dFecha     = '';
            LET cUser      = '';
            LET cMovil     = '';
            LET cStatus    = '';
        END FOREACH;
        
        -- // REGISTRA CLIENTE PROCESADO
        INSERT INTO si_ctesdepurados VALUES(cNumCte);
        
        LET iContador = iContador + 1;
        
        -- // CIERRA TRANSACCION
        COMMIT WORK;
        LET iTransacc = 0;
        
        LET cNumCte = '';
    END FOREACH;
    
    END;
    
    RETURN cCodRet, iContador, iContador2;
    
END PROCEDURE;