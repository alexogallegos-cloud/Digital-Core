CREATE PROCEDURE "informix".sp_get_indicadores_correos_tels(dFechaProceso DATE, cTipoRp CHAR(2), iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);

	DEFINE iCorreopen	INTEGER;
	DEFINE iCorreoCap	INTEGER;
	DEFINE iPorcentCorreo INTEGER;
	DEFINE vcod_correoPen INTEGER;
	DEFINE iReplicaActiva	INTEGER;
	
	DEFINE cCodRetSP	CHAR(6);
	DEFINE cVarDataErrSP CHAR(100);

	
	DEFINE bExiste_tmp_telefonos_ctenvos BOOLEAN;
	DEFINE bExiste_tmp_sucursal_ejecut_mantto BOOLEAN;
	DEFINE bExiste_tmp_telefonos_ctesmantto BOOLEAN;
	
	DEFINE bEnTransaccion	BOOLEAN;
	DEFINE cFlag	CHAR(1);
		
	DEFINE cFechaProceso	CHAR(11);
	
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET bExiste_tmp_telefonos_ctenvos = 'f';
	LET bExiste_tmp_sucursal_ejecut_mantto = 'f';
	LET bExiste_tmp_telefonos_ctesmantto = 'f';	
	
	LET bEnTransaccion = 'f';
	LET cFlag			= '';
	
	LET cFechaProceso = '';
	
	--SET DEBUG FILE TO '/informix/jagl/bdinteg/sp_get_indicadores_correos_tels.out';
	--TRACE ON;		
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
					
					IF bExiste_tmp_sucursal_ejecut_mantto = 't' THEN
						LET bExiste_tmp_sucursal_ejecut_mantto = 'f';
					END IF;
					IF bExiste_tmp_telefonos_ctenvos = 't' THEN
						LET bExiste_tmp_telefonos_ctenvos = 'f';
					END IF;
					IF bExiste_tmp_telefonos_ctesmantto = 't' THEN
						LET bExiste_tmp_telefonos_ctesmantto = 'f';
					END IF;
				END IF;

				IF bExiste_tmp_sucursal_ejecut_mantto = 't' THEN
					DROP TABLE tmp_sucursal_ejecut_mantto;
					LET bExiste_tmp_sucursal_ejecut_mantto = 'f';
				END IF;
				IF bExiste_tmp_telefonos_ctenvos = 't' THEN
					DROP TABLE tmp_telefonos_ctenvos;
					LET bExiste_tmp_telefonos_ctenvos = 'f';
				END IF;
				IF bExiste_tmp_telefonos_ctesmantto = 't' THEN
					DROP TABLE tmp_telefonos_ctesmantto;
					LET bExiste_tmp_telefonos_ctesmantto = 'f';
				END IF;
				/*IF bExiste_tmp_mantto_ctes_titulares = 't' THEN
					DROP TABLE si_tmp_mantto_ctes_titulares;
					LET bExiste_tmp_mantto_ctes_titulares = 'f';
				END IF;*/
				
				UPDATE si_controlproc_indicadores
				SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
					maxfecha_cargada = '',
					flagfinalizado = 'F',
					coderror = cCodRet, 
					msgerror = cMensaje
				WHERE tipo = cTipoRp 
					AND  id_proc = iIdRp
					AND fecha_procesoIni = dFechaProceso 
					AND fecha_procesoFin = dFechaProceso;
					
				INSERT INTO "informix".si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaProceso, cProceso, cEvento, cCodRet, cMensaje);				
			END IF;
		END EXCEPTION;

		SELECT nombre_proceso 
		INTO cProceso
		FROM si_proc_indicadores
		WHERE tipo = cTipoRp AND identificador = iIdRp;
		
		--LET cProceso = 'INDICADORES DE CORREOS Y TELEFONOS BOARD';	
		LET cEvento = 'VALIDACION DE PARAMETROS RECIBIDOS';
		
		IF NVL(dFechaProceso,' ') = ' ' THEN
			LET cCodRet = '000001';
			LET cMensaje = 'FECHA INVALIDA';
		ELIF NVL(cTipoRp,' ') = ' ' THEN
			LET cCodRet = '000002';
			LET cMensaje = 'TIPO INDICADOR INVALIDO';
		ELIF NVL(iIdRp,0) = 0 THEN
			LET cCodRet = '000003';
			LET cMensaje = 'ID INDICADOR INVALIDO';
		ELIF NOT EXISTS (SELECT 1 FROM si_proc_indicadores WHERE  tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000004';
			LET cMensaje = 'INDICADOR NO REGISTRADO EN SI_PROC_INDICADORES';	
		ELIF EXISTS (SELECT 1 FROM si_proc_indicadores WHERE estatus_proceso = 'I' AND tipo = cTipoRp AND  identificador = iIdRp) THEN
			LET cCodRet = '000005';
			LET cMensaje = 'INDICADOR INACTIVO';
		END IF;

		LET cFechaProceso = (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';
		
		LET cEvento = 'CONSULTA DE PARAMETROS DE SISTEMA';		
		SELECT valor::INTEGER 
		INTO vcod_correoPen
		FROM bdinteg:"informix".si_param 
		WHERE empresa='001'
		AND cod_param = 377;

		LET cEvento	= 'OBTIENE VALOR FLAG PARA GRABAR BDIBI';
		SELECT NVL(valor,0)::INTEGER 
		INTO iReplicaActiva 
		FROM bdinteg:si_param WHERE cod_param = 343;
		
		LET cEvento = 'CONSULTA ESTATUS EN SI_CONTROLPROC_INDICADORES';
		SELECT flagfinalizado INTO  cFlag
		FROM  si_controlproc_indicadores 
		WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

		IF NVL(cFlag,'') = '' THEN
			INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
			
		END IF;	
		
		IF cCodRet::INTEGER = 0 THEN
			BEGIN WORK;
			LET bEnTransaccion = 't';
				
				DELETE FROM bdinteg:si_indicadores_ctes_nvos_det WHERE fecha = dFechaproceso;
				DELETE FROM bdinteg:si_indicadores_ctes_nvos WHERE fecha = dFechaproceso;
				
				IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_indicadores_ctes_nvos_det WHERE fecha = dFechaproceso) THEN
				
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL TELEFONOS';
					
					IF NOT EXISTS(SELECT 1 FROM si_tmp_telefonos WHERE fecha = dFechaproceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL TELEFONOS';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						INSERT INTO si_tmp_telefonos
						SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
						FROM si_telefonos
						WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND);
					END IF;
					
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL CLIENTES TITULARES';
					IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaProceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL CLIENTES TITULARES';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;	
						INSERT INTO si_tmp_alta_ctes_titulares
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
						FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
						WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaProceso 
						AND a.tipo_cliente='1';
					END IF;	
					
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL CLIENTES MANTENIMIENTO';
					IF NOT EXISTS(SELECT 1 FROM si_tmp_mantto_ctes_titulares WHERE fecha_alta = dFechaProceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL CLIENTES MANTENIMIENTO';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						INSERT INTO si_tmp_mantto_ctes_titulares
						SELECT a.numcte, a.user_insert AS numemp, c.sucursal, a.fecha  AS fecha_alta
						FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:si_tmp_telefonos tmp_idx_tmp_si_telefonos)} DISTINCT user_insert, numcte, fecha AS fecha FROM si_tmp_telefonos  
											WHERE fecha = dFechaproceso
											AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
											UNION ALL
											--SELECT DISTINCT user_insert, numcte, fecha_hora::DATETIME YEAR TO FRACTION::DATE AS fecha FROM si_correos 
											--WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso-- BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), MONTH(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), MONTH(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
											SELECT DISTINCT user_insert, numcte, dFechaproceso AS fecha FROM si_correos 
											WHERE fecha_hora LIKE cFechaProceso
											AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI'))) a, si_cliente b, si_ejecut c, si_cte_huella d
						WHERE a.numcte = b.numcte
						AND b.numcte = d.numcte
						AND b.tipo_cliente = '1'
						AND a.user_insert = c.ejecutivo
						AND d.secuencia = 1
						AND a.fecha > d.fecha_alta
						AND c.password IN ('bancoppel2007','informix');
					END IF;					
					
					LET cEvento	= 'VALIDACION DE TABLA TEMPORAL  si_tmp_sucursal_ejecut';
					IF NOT EXISTS(SELECT 1 FROM si_tmp_sucursal_ejecut) THEN
						--TRUNCATE TABLE si_tmp_sucursal_ejecut;					
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						INSERT INTO  si_tmp_sucursal_ejecut
						SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
						FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, si_tmp_alta_ctes_titulares c
						WHERE a.sucursal = b.sucursal
						AND b.ejecutivo = c.numemp;
					END IF;

					LET cEvento	= 'INSERCION DE INDICADORES DE CORREOS DE NUEVOS CLIENTES TITULARES';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO bdinteg:si_indicadores_ctes_nvos_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
														  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
														  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
														  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
					SELECT '1', dFechaproceso, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos, 
							0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
					FROM TABLE(MULTISET(SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
										FROM  TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
															 FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
																			   FROM si_tmp_alta_ctes_titulares a 
																			   LEFT JOIN
																			   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
																			   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																									   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																									   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																									   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																									FROM bdinteg:"informix".si_correos
																									--WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																									WHERE fecha_hora LIKE cFechaProceso
																									AND secuencia = 1
																									GROUP BY user_insert, numcte, valido ))
																									GROUP BY user_insert, numcte)) b
																			   ON a.numcte = b.numcte
																			   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
															 GROUP BY numemp)) a
															 LEFT JOIN 
															 TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
																		  FROM bdinteg:"informix".si_correos a, si_tmp_alta_ctes_titulares b
																		  WHERE a.numcte=b.numcte
																		  --AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																		  AND a.fecha_hora LIKE cFechaProceso
																		  GROUP BY 1,2
																		  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
															 ON a.numemp = b.numemp ))a, si_tmp_sucursal_ejecut b
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
					FROM si_tmp_alta_ctes_titulares a 
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
																--FROM bdinteg:"informix".si_telefonos
																FROM bdinteg:si_tmp_telefonos
																--WHERE fecha_hora::DATE = dFechaproceso
																WHERE fecha = dFechaproceso
																GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																			   --FROM bdinteg:"informix".si_telefonos
																			   FROM bdinteg:si_tmp_telefonos
																			   --WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
																			   WHERE fecha = dFechaproceso
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
													  --FROM bdinteg:"informix".si_telefonos a, si_tmp_alta_ctes_titulares b
													  FROM bdinteg:"informix".si_tmp_telefonos a, si_tmp_alta_ctes_titulares b
													  WHERE a.numcte=b.numcte
													  AND a.user_insert = b.numemp
													  --AND a.fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
													  AND a.fecha = dFechaproceso
													  GROUP BY b.numemp, a.telefono, a.tipo_tel
													  HAVING COUNT(a.telefono) >1))
									   GROUP BY 1)) b
					ON a.numemp = b.numemp
					GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
					INTO TEMP tmp_telefonos_ctenvos WITH NO LOG;
					
					LET bExiste_tmp_telefonos_ctenvos = 't';

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
					FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, si_tmp_mantto_ctes_titulares c
					WHERE a.sucursal = b.sucursal
					AND b.ejecutivo = c.numemp
					INTO TEMP tmp_sucursal_ejecut_mantto
					WITH NO LOG;
					
					LET bExiste_tmp_sucursal_ejecut_mantto = 't';

					LET cEvento	= 'ACTUALIZACION DE TABLA TEMPORAL si_tmp_sucursal_ejecut';
					MERGE INTO si_tmp_sucursal_ejecut a
						USING tmp_sucursal_ejecut_mantto b
						ON a.ejecutivo= b.ejecutivo
						AND a.sucursal = b.sucursal
					WHEN NOT MATCHED THEN
						INSERT (a.sucursal, a.nom_suc, a.ejecutivo, a.nom_emp)
						VALUES (b.sucursal, b.nom_suc, b.ejecutivo, b.nom_emp);

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
													   FROM si_tmp_mantto_ctes_titulares a 
													   LEFT JOIN
													   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
													   FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} user_insert,numcte,
																			   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																			   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																			   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																			FROM bdinteg:"informix".si_correos
																			--WHERE fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
																			WHERE fecha_hora LIKE cFechaProceso
																			GROUP BY user_insert, numcte, valido ))
																			GROUP BY user_insert, numcte)) b
													   ON a.numcte = b.numcte
													   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
								   GROUP BY numemp)) a
								   LEFT JOIN 
								   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
												  FROM bdinteg:"informix".si_correos a, si_tmp_mantto_ctes_titulares b
												  WHERE a.numcte=b.numcte
												  --AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
												  AND a.fecha_hora LIKE cFechaProceso
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
					FROM si_tmp_mantto_ctes_titulares a 
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
																--FROM bdinteg:"informix".si_telefonos
																FROM bdinteg:si_tmp_telefonos
																--WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
																WHERE fecha = dFechaproceso
																GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
																TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																			   --FROM bdinteg:"informix".si_telefonos
																			   FROM bdinteg:"informix".si_tmp_telefonos
																			   --WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
																			   WHERE fecha = dFechaproceso
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
													  --FROM bdinteg:"informix".si_telefonos a, si_tmp_mantto_ctes_titulares b
													  FROM bdinteg:"informix".si_tmp_telefonos a, si_tmp_mantto_ctes_titulares b
													  WHERE a.numcte=b.numcte
													  AND a.user_insert = b.numemp
													  --AND a.fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
													  AND fecha = dFechaproceso
													  GROUP BY b.numemp, a.telefono, a.tipo_tel
													  HAVING COUNT(a.telefono) >1))
									   GROUP BY 1)) b
					ON a.numemp = b.numemp
					GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
					INTO TEMP tmp_telefonos_ctesmantto WITH NO LOG;
					
					LET bExiste_tmp_telefonos_ctesmantto = 't';
					
					LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES CON MANTENIMIENTO';
					MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a 
					USING tmp_telefonos_ctesmantto AS b
					ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
					WHEN MATCHED THEN UPDATE
					SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep, 
						telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
						telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;					

					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;	
					
					LET cEvento	= 'OBTENCION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES/MANTENIMIENTOS';
					INSERT INTO bdinteg:si_indicadores_ctes_nvos (tipo_movto, fecha, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep, 
																  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep, 
																  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep, 
																  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep) 
					SELECT tipo_movto, fecha, NVL(SUM(altas_ctes),0), NVL(SUM(correo_cap),0), NVL(SUM(correo_val),0),  NVL(SUM(correo_inval),0), NVL(SUM(correo_pen),0), NVL(SUM(correo_rep),0), 
						   NVL(SUM(telcasa_cap),0), NVL(SUM(telcasa_val),0), NVL(SUM(telcasa_inval),0), NVL(SUM(telcasa_pen),0), NVL(SUM(telcasa_rep),0), 
						   NVL(SUM(telcel_cap),0), NVL(SUM(telcel_val),0), NVL(SUM(telcel_inval),0), NVL(SUM(telcel_pen),0), NVL(SUM(telcel_ver),0), NVL(SUM(telcel_rep),0), 
						   NVL(SUM(telotro_cap),0), NVL(SUM(telotro_val),0), NVL(SUM(telotro_inval),0), NVL(SUM(telotro_pen),0), NVL(SUM(telotro_rep),0)
					FROM si_indicadores_ctes_nvos_det
					WHERE fecha = dFechaProceso
					--AND tipo_movto = '1'
					GROUP BY 1,2;
					
					-- 1509 - valida el porcentaje de correos pendientes
					SELECT SUM(correo_pen),SUM(correo_cap) 
					INTO iCorreopen,iCorreoCap
					FROM "informix".si_indicadores_ctes_nvos
					WHERE fecha = dFechaProceso;

					IF NVL(iCorreopen, 0) > 0 AND  NVL(iCorreoCap, 0) > 0 THEN -- Se valida no realize divicion entre cero.
						LET iPorcentCorreo= (iCorreopen/iCorreoCap)*100;
						
						IF 	iPorcentCorreo >= vcod_correoPen THEN
							INSERT INTO "informix".si_alertas_indicadores (id,fecha,activa,fecha_alerta,fecha_cambio,fecha_ult_monitoreo)
							VALUES (0,dFechaProceso, "V", CURRENT,"","");
						END IF;
					END IF;
				ELSE
					LET cEvento = 'VALIDA FLAG REPLICA DE INFORMACION A BDIBI 1';
					IF iReplicaActiva = 1 THEN
						LET cEvento = 'VALIDA REPLICA PREVIA DE INFORMACION A BDIBI 1';
						--DESARROLLO 
						-- IF NOT EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 2 ) THEN
						-- PRODUCCION ---
						
						IF NOT EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 2 ) THEN							
							LET cEvento	= 'GENERACION DE TABLA TEMPORAL si_tmp_sucursal_ejecut';								
							TRUNCATE TABLE si_tmp_sucursal_ejecut;
							
							SET ISOLATION TO DIRTY READ;
							SET LOCK MODE TO WAIT 3;
							INSERT INTO  si_tmp_sucursal_ejecut
							SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
							FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, si_indicadores_ctes_nvos_det c
							WHERE c.fecha = dFechaproceso
							AND a.sucursal = b.sucursal
							AND b.ejecutivo = c.ejecutivo;							
						END IF;	
					END IF;
				END IF;
			COMMIT WORK;
			LET bEnTransaccion = 'f';

			LET cEvento = 'VALIDA FLAG REPLICA DE INFORMACION A BDIBI 2';
						
			IF iReplicaActiva = 1 THEN
				LET cEvento = 'VALIDA REPLICA PREVIA DE INFORMACION A BDIBI 2';
				--DESARROLLO-- 
				--IF NOT EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 2) THEN 
				
				--PRODUCCION ---
				IF NOT EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 2) THEN		
					LET cEvento	= 'EJECUCION DE sp_replica_indicadores_ctes_bi';
					
					EXECUTE PROCEDURE "informix".sp_replica_indicadores_ctes_bi(2,dFechaProceso)
					INTO cCodRetSP, cVarDataErrSP;
					
					IF cCodRetSP <> '000000' THEN
						INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
						VALUES (dFechaProceso, cProceso, cEvento, cCodRetSP, cVarDataErrSP);						
					END IF;						
				END IF;
				
				LET cEvento = 'VALIDA REPLICA PREVIA DE INFORMACION A BDIBI 3';
				--DESARROLLO-- 
				--IF NOT EXISTS (SELECT 1 FROM bdibi@coppel_tcp:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 101) THEN				
				--PRODUCCION ---
				IF NOT EXISTS (SELECT 1 FROM bdibi@stag_ids1170:"informix".bi_controlprocesos WHERE fecha_carga = dFechaProceso AND flagfinalizado = 'V' AND id_proc = 101) THEN		
					LET cEvento	= 'EJECUCION DE sp_replica_indicadores_ctes_bi';
					
					EXECUTE PROCEDURE "informix".sp_replica_indicadores_ctes_bi(101,dFechaProceso)
					INTO cCodRetSP, cVarDataErrSP;
					
					IF cCodRetSP <> '000000' THEN
						INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
						VALUES (dFechaProceso, cProceso, cEvento, cCodRetSP, cVarDataErrSP);						
					END IF;	
				END IF;				
			END IF;								
		END IF;
		
		IF bExiste_tmp_sucursal_ejecut_mantto = 't' THEN
			DROP TABLE tmp_sucursal_ejecut_mantto;
			LET bExiste_tmp_sucursal_ejecut_mantto = 'f';
		END IF;
		IF bExiste_tmp_telefonos_ctenvos = 't' THEN
			DROP TABLE tmp_telefonos_ctenvos;
			LET bExiste_tmp_telefonos_ctenvos = 'f';
		END IF;		
		IF bExiste_tmp_telefonos_ctesmantto = 't' THEN
			DROP TABLE tmp_telefonos_ctesmantto;
			LET bExiste_tmp_telefonos_ctesmantto = 'f';
		END IF;
		
		UPDATE si_controlproc_indicadores
		SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), 
			maxfecha_cargada = DECODE (cCodRet,'000000',dFechaProceso,NULL),
			flagfinalizado = DECODE (cCodRet,'000000','V','F'),
			coderror = cCodRet, 
			msgerror = cMensaje
		WHERE tipo = cTipoRp 
			AND  id_proc = iIdRp
			AND fecha_procesoIni = dFechaProceso 
			AND fecha_procesoFin = dFechaProceso;
	END;
END PROCEDURE;