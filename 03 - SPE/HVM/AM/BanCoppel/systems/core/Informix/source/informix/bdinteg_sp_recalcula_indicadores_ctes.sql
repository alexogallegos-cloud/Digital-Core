CREATE PROCEDURE "informix".sp_recalcula_indicadores_ctes(dFechaIni DATE, dFechaFin DATE)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE vCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE cCodRetSP        CHAR(6);
DEFINE cVarDataErrSP    CHAR(100);
DEFINE cVarDataErr      CHAR(100);
DEFINE iEnTransaccion   SMALLINT;
DEFINE iSqlErr			INTEGER;
DEFINE iSamErr			INTEGER;
DEFINE iFlag			INTEGER;
DEFINE bT1, bT2, bT3, bT4, bT5, bT6, bT7, bT8, bT9, bT10 BOOLEAN;
DEFINE iTemporal		SMALLINT;
DEFINE iBorrandoTmp		SMALLINT;
DEFINE dFechaProceso	DATE;
DEFINE dFechahoy	    DATE;
DEFINE cProceso			CHAR(100);
DEFINE cEvento			CHAR(100);
DEFINE cContador		INTEGER;
DEFINE cFechaProceso    CHAR(11);


--ASIGNACION DE VARIABLES
LET vCodRet = '000000';
LET cMensCodRet = 'EL PROCESO SE REALIZO CORRECTAMENTE';
LET iEnTransaccion = 0;
LET iFlag = 0;
LET cProceso = '';
LET cEvento = '';
LET dFechahoy = CURRENT::DATE;
LET bT1 = 'f';
LET bT2 = 'f';
LET bT3 = 'f';
LET bT4 = 'f';
LET bT5 = 'f';
LET bT6 = 'f';
LET bT7 = 'f';
LET bT8 = 'f';
LET bT9 = 'f';
LET bT10 = 'f';
LET iTemporal = 0;
LET iBorrandoTmp = 0;
LET cContador = 0;
LET cFechaProceso = '';

--SET DEBUG FILE TO "/tmp/masv/monitor/sp_recalcula_indicadores_ctes.out";
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr, iSamErr, cMensCodRet
		IF iSqlErr <> 0 THEN
			LET vCodRet=iSqlErr;

			IF iEnTransaccion = 1 THEN
				ROLLBACK;
			END IF;

			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

			RETURN vCodRet, cMensCodRet;
		END IF;
	END EXCEPTION;

	ON EXCEPTION IN(-206) SET iSqlErr, iSamErr, cMensCodRet
		IF iBorrandoTmp = 0 THEN
			IF iEnTransaccion = 1 THEN
				ROLLBACK;
				LET iEnTransaccion = 0;
			END IF;

			INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
			VALUES (dFechaProceso, cProceso, cEvento, vCodret, cMensCodRet);

			LET vCodRet = iSqlErr;
			RETURN vCodRet, cMensCodRet;
		END IF;
	END EXCEPTION WITH RESUME;

	IF NVL(dFechaIni,'') = '' OR  NVL(dFechaFin,'') = ''  THEN
		LET vCodRet = '000001';
		LET cMensCodRet = 'PARAMETRO INCORRECTO, PARAMETRO VACIO';
		RETURN vCodRet, cMensCodRet;
	ELIF dFechaIni > dFechaFin THEN
		LET vCodRet = '000002';
		LET cMensCodRet = 'PARAMETROS INCORRECTOS, FECHA INCIAL MAYOR A FECHA FINAL';
		RETURN vCodRet, cMensCodRet;

	END IF;

	LET dFechaProceso = dFechaIni;
	LET cFechaProceso = (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';

	LET cProceso = 'GENERACION DE INDICADORES DE SUCURSAL';
	WHILE (dFechaProceso <= dFechaFin)
		BEGIN WORK;
			LET iEnTransaccion = 1;
			LET iTemporal = 1;
			LET cEvento	= 'GENERACION TABLA TEMPORAL TMP_ALTA_CTES_TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
			FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b
			WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta = dFechaproceso
			AND a.tipo_cliente='1'
			INTO TEMP tmp_alta_ctes_titulares
			WITH NO LOG;
			
			LET bT1 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_alta_ctes_titulares';
			CREATE INDEX "informix".tmp_idx_alta_ctes_titulares ON tmp_alta_ctes_titulares (numcte, fecha_alta, sucursal);

			LET iTemporal = 2;
			LET cEvento = 'GENERACION TABLA TEMPORAL TMP_SI_TELEFONOS';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
			FROM si_telefonos
			WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
			INTO TEMP tmp_si_telefonos WITH NO LOG;
			
			

			LET bT2 = 't';

			LET iTemporal = 3;
			LET cEvento = 'GENERACION TABLA TEMPORAL TMP_MANTTO_CTES_TITULARES';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT a.numcte, a.user_insert AS numemp, c.sucursal, a.fecha  AS fecha_alta
			FROM TABLE(MULTISET(SELECT DISTINCT user_insert, numcte, fecha_hora::DATE AS fecha FROM tmp_si_telefonos WHERE fecha = dFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI')
							UNION ALL
							SELECT DISTINCT user_insert, numcte, dFechaproceso AS fecha 
							FROM si_correos WHERE fecha_hora like cFechaproceso AND secuencia > 1 AND user_insert NOT IN ('interact', 'transBPI'))) a,
			si_cliente b, si_ejecut c, si_cte_huella d
			WHERE a.numcte = b.numcte
			AND b.numcte = d.numcte
			AND b.tipo_cliente = '1'
			AND a.user_insert = c.ejecutivo
			AND d.secuencia = 1
			AND a.fecha > d.fecha_alta
			AND c.password IN ('bancoppel2007','informix')
			INTO TEMP tmp_mantto_ctes_titulares
			WITH NO LOG;
			
		
			LET bT3 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_mantto_ctes_titulares';
			CREATE INDEX "informix".tmp_idx_mantto_ctes_titulares ON tmp_mantto_ctes_titulares (numcte, fecha_alta, sucursal);

			LET iTemporal = 4;
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_alta_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut
			WITH NO LOG;

			LET bT4 = 't';

			LET cEvento	= 'GENERACION DE INDICE DE TABLA TEMPORAL tmp_sucursal_ejecut';
			CREATE INDEX "informix".idx_tmp_suc_ejecut ON tmp_sucursal_ejecut (ejecutivo, sucursal);

			LET iTemporal = 5;
			LET cEvento	= 'GENERACION DE INDICADORES DE CORREOS DE NUEVOS CLIENTES TITULARES';

			SELECT '1' AS tipo_movto, dFechaproceso AS fecha, b.sucursal AS sucursal, a.numemp AS ejecutivo, a.altas AS altas_ctes, a.total_correos AS correo_cap, a.validos AS correo_val, a.invalidos AS correo_inval, a.sin_validar AS correo_pen, a.repetidos AS correo_rep,
					0 AS telcasa_cap,0 AS telcasa_val,0 AS telcasa_inval,0 AS telcasa_pen,0 AS telcasa_rep,
					0 AS telcel_cap,0 AS telcel_val,0 AS telcel_inval,0 AS telcel_pen,0 AS telcel_ver,0 AS telcel_rep,
					0 AS telotro_cap,0 AS telotro_val,0 AS telotro_inval,0 AS telotro_pen,0 AS telotro_rep
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_alta_ctes_titulares a
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+AVOID_FULL (bdinteg:"informix".si_correos)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora like cFechaproceso
																	AND secuencia = 1
																	AND status_correo = 'A'
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
										  FROM bdinteg:"informix".si_correos a, tmp_alta_ctes_titulares b
										  WHERE a.numcte=b.numcte
										  AND fecha_valida::DATE = dFechaproceso
										  GROUP BY 1,2
										  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut b
			WHERE a.numemp = b.ejecutivo
			INTO TEMP tmp_indicadores_ctes_det WITH NO LOG;

			LET bT5 = 't';

			LET iTemporal = 6;
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
														FROM bdinteg:"informix".tmp_si_telefonos
														WHERE fecha = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".tmp_si_telefonos
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
											  FROM bdinteg:"informix".tmp_si_telefonos a, tmp_alta_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctenvos WITH NO LOG;

			LET bT6 = 't';

			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES TITULARES';
			MERGE INTO bdinteg:tmp_indicadores_ctes_det AS a
			USING tmp_telefonos_ctenvos AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep,
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;

			LET iTemporal = 7;
			LET cEvento	= 'GENERACION DE TABLA TEMPORAL tmp_sucursal_ejecut_mantto';
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			SELECT DISTINCT a.sucursal, a.nombre AS nom_suc, b.ejecutivo, b.nombre AS nom_emp
			FROM bdinteg:"informix".si_sucursales a, bdinteg:"informix".si_ejecut b, tmp_mantto_ctes_titulares c
			WHERE a.sucursal = b.sucursal
			AND b.ejecutivo = c.numemp
			INTO TEMP tmp_sucursal_ejecut_mantto
			WITH NO LOG;

			LET bT7 = 't';

			LET cEvento	= 'ACTUALIZACION DE TABLA TEMPORAL tmp_sucursal_ejecut';
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
			INSERT INTO bdinteg:tmp_indicadores_ctes_det( tipo_movto, fecha, sucursal, ejecutivo, altas_ctes, correo_cap, correo_val, correo_inval, correo_pen, correo_rep,
												  telcasa_cap, telcasa_val, telcasa_inval, telcasa_pen, telcasa_rep,
												  telcel_cap, telcel_val, telcel_inval, telcel_pen, telcel_ver, telcel_rep,
												  telotro_cap, telotro_val, telotro_inval, telotro_pen, telotro_rep)
			SELECT DISTINCT '2' AS tipo_mov, dFechaproceso, b.sucursal, a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, a.repetidos,
					0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
			FROM TABLE(MULTISET(
			SELECT a.numemp, a.altas, a.total_correos, a.validos, a.invalidos, a.sin_validar, NVL(b.repetidos,0) AS repetidos
			FROM
			TABLE(MULTISET(SELECT numemp, SUM(NVL(altas,0)) AS altas, SUM(NVL(total_correos,0)) AS total_correos, SUM(NVL(validos,0)) AS validos, SUM(NVL(invalidos,0)) AS invalidos, SUM(NVL(sin_validar,0)) AS sin_validar
						   FROM TABLE(MULTISET(SELECT a.numemp, a.numcte, NVL(COUNT(a.numcte),0) AS altas , NVL(b.total_correos, 0) AS total_correos, NVL(b.validos,0) AS validos, NVL(b.invalidos,0) AS invalidos, NVL(b.sin_validar,0) AS sin_validar
											   FROM tmp_mantto_ctes_titulares a
											   LEFT JOIN
											   TABLE(MULTISET(SELECT user_insert, numcte, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
											   FROM TABLE(MULTISET(SELECT {+AVOID_FULL (bdinteg:"informix".si_correos)} user_insert,numcte,
																	   CASE WHEN valido = '1' THEN COUNT(correo_elec) ELSE 0 END AS validos,
																	   CASE WHEN valido = '0' THEN COUNT(correo_elec) ELSE 0 END AS invalidos,
																	   CASE WHEN valido IS NULL THEN COUNT(correo_elec) ELSE 0  END AS sin_validar
																	FROM bdinteg:"informix".si_correos
																	WHERE fecha_hora like cFechaproceso
																	AND status_correo = 'A'
																	GROUP BY user_insert, numcte, valido ))
																	GROUP BY user_insert, numcte)) b
											   ON a.numcte = b.numcte
											   GROUP BY a.numemp, a.numcte,b.total_correos, b.validos, b.invalidos, b.sin_validar))
						   GROUP BY numemp)) a
						   LEFT JOIN
						   TABLE(MULTISET(SELECT numemp, SUM(repetidos) AS repetidos FROM TABLE(MULTISET(SELECT a.user_insert AS numemp, a.correo_elec, COUNT(a.correo_elec) AS repetidos
										  FROM bdinteg:"informix".si_correos a, tmp_mantto_ctes_titulares b
										  WHERE a.numcte=b.numcte
										  AND fecha_valida::DATE = dFechaproceso
										  GROUP BY 1,2
										  HAVING COUNT(a.correo_elec) >1)) GROUP BY 1)) b
						   ON a.numemp = b.numemp ))a, tmp_sucursal_ejecut_mantto b
			WHERE a.numemp = b.ejecutivo;

			LET iTemporal = 8;
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
														FROM bdinteg:"informix".tmp_si_telefonos
														--WHERE fecha_hora::DATE = dFechaproceso
														WHERE fecha = dFechaproceso
														GROUP BY user_insert, numcte, tipo_tel, cofetel)) a LEFT JOIN
														TABLE(MULTISET(SELECT user_insert,numcte,tipo_tel, COUNT(telefono) AS verificado
																	   FROM bdinteg:"informix".tmp_si_telefonos
																	   --WHERE fecha_hora::DATE = dFechaproceso
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
											  FROM bdinteg:"informix".tmp_si_telefonos a, tmp_mantto_ctes_titulares b
											  WHERE a.numcte=b.numcte
											  AND a.user_insert = b.numemp
											  AND a.fecha = dFechaproceso
											  GROUP BY b.numemp, a.telefono, a.tipo_tel
											  HAVING COUNT(a.telefono) >1))
							   GROUP BY 1)) b
			ON a.numemp = b.numemp
			GROUP BY 1, 2, 3, b.tel_casa_rep, tel_cel_rep, b.tel_otro_rep
			INTO TEMP tmp_telefonos_ctesmantto WITH NO LOG;

			LET bT8 = 't';

			LET cEvento	= 'UNION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES CON MANTENIMIENTO';
			MERGE INTO bdinteg:tmp_indicadores_ctes_det AS a
			USING tmp_telefonos_ctesmantto AS b
			ON a.tipo_movto = b.tipo_movto AND a.ejecutivo = b.numemp AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
			SET telcasa_cap = total_tel_casa, telcasa_val = total_tel_casa_val, telcasa_inval = total_tel_casa_inval, telcasa_pen = total_tel_casa_pen, telcasa_rep = total_tel_casa_rep,
				telcel_cap = total_celular, telcel_val = total_celular_val, telcel_inval = total_celular_inval, telcel_pen = total_celular_pen, telcel_ver = verificados, telcel_rep = total_tel_cel_rep,
				telotro_cap = total_otro, telotro_val = total_otro_val, telotro_inval = total_otro_inval, telotro_pen = total_otro_pen, telotro_rep = total_tel_otro_rep;

			LET cEvento	= 'ACTUALIZACION DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos_det AS a
			USING tmp_indicadores_ctes_det AS b
			ON a.tipo_movto = b.tipo_movto AND a.fecha = b.fecha AND a.sucursal = b.sucursal AND a.ejecutivo = b.ejecutivo
			WHEN MATCHED THEN UPDATE
				SET a.altas_ctes = b.altas_ctes, a.correo_cap = b.correo_cap, a.correo_val = b.correo_val, a.correo_inval = b.correo_inval, a.correo_pen = b.correo_pen, a.correo_rep = b.correo_rep,
					a.telcasa_cap = b.telcasa_cap, a.telcasa_val = b.telcasa_val, a.telcasa_inval = b.telcasa_inval, a.telcasa_pen = b.telcasa_pen, a.telcasa_rep = b.telcasa_rep,
					a.telcel_cap = b.telcel_cap, a.telcel_val = b.telcel_val, a.telcel_inval = b.telcel_inval, a.telcel_pen = b.telcel_pen, a.telcel_ver = b.telcel_ver, a.telcel_rep = b.telcel_rep,
					a.telotro_cap = b.telotro_cap, a.telotro_val = b.telotro_val, a.telotro_inval = b.telotro_inval, a.telotro_pen = b.telotro_pen, a.telotro_rep = b.telotro_rep
			WHEN NOT MATCHED THEN INSERT
						(a.tipo_movto, a.fecha, a.sucursal, a.ejecutivo,
						a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
						a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
						a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
						a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep)
				VALUES( b.tipo_movto, b.fecha, b.sucursal, b.ejecutivo,
						b.altas_ctes, b.correo_cap, b.correo_val, b.correo_inval, b.correo_pen, b.correo_rep,
						b.telcasa_cap, b.telcasa_val, b.telcasa_inval, b.telcasa_pen, b.telcasa_rep,
						b.telcel_cap, b.telcel_val, b.telcel_inval, b.telcel_pen, b.telcel_ver, b.telcel_rep,
						b.telotro_cap, b.telotro_val, b.telotro_inval, b.telotro_pen, b.telotro_rep);

			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			LET cEvento	= 'OBTENCION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE NUEVOS CLIENTES/MANTENIMIENTOS';

			LET iTemporal = 9;
			SELECT tipo_movto, fecha, NVL(SUM(altas_ctes),0) AS altas_ctes, NVL(SUM(correo_cap),0) AS correo_cap, NVL(SUM(correo_val),0) AS correo_val,  NVL(SUM(correo_inval),0) AS correo_inval, NVL(SUM(correo_pen),0) AS correo_pen, NVL(SUM(correo_rep),0) correo_rep,
				   NVL(SUM(telcasa_cap),0) AS telcasa_cap, NVL(SUM(telcasa_val),0) AS telcasa_val, NVL(SUM(telcasa_inval),0) AS telcasa_inval, NVL(SUM(telcasa_pen),0) AS telcasa_pen, NVL(SUM(telcasa_rep),0) AS telcasa_rep,
				   NVL(SUM(telcel_cap),0) AS telcel_cap, NVL(SUM(telcel_val),0) AS telcel_val, NVL(SUM(telcel_inval),0) AS telcel_inval, NVL(SUM(telcel_pen),0) AS telcel_pen, NVL(SUM(telcel_ver),0) AS telcel_ver, NVL(SUM(telcel_rep),0) AS telcel_rep,
				   NVL(SUM(telotro_cap),0) AS telotro_cap, NVL(SUM(telotro_val),0) AS telotro_val, NVL(SUM(telotro_inval),0) AS telotro_inval, NVL(SUM(telotro_pen),0) AS telotro_pen, NVL(SUM(telotro_rep),0) AS telotro_rep
			FROM si_indicadores_ctes_nvos_det
			WHERE fecha = dFechaproceso
			GROUP BY 1,2
			INTO TEMP tmp_indicadores_ctes WITH NO LOG;

			LET bT9 = 't';

			LET cEvento	= 'ACTUALIZACION DE TOTALES DE INDICADORES DE TELEFONOS Y CORREOS DE CLIENTES';
			MERGE INTO bdinteg:si_indicadores_ctes_nvos AS a
			USING tmp_indicadores_ctes AS b
			ON a.tipo_movto = b.tipo_movto AND a.fecha = b.fecha
			WHEN MATCHED THEN UPDATE
				SET a.altas_ctes = b.altas_ctes, a.correo_cap = b.correo_cap, a.correo_val = b.correo_val, a.correo_inval = b.correo_inval, a.correo_pen = b.correo_pen, a.correo_rep = b.correo_rep,
					a.telcasa_cap = b.telcasa_cap, a.telcasa_val = b.telcasa_val, a.telcasa_inval = b.telcasa_inval, a.telcasa_pen = b.telcasa_pen, a.telcasa_rep = b.telcasa_rep,
					a.telcel_cap = b.telcel_cap, a.telcel_val = b.telcel_val, a.telcel_inval = b.telcel_inval, a.telcel_pen = b.telcel_pen, a.telcel_ver = b.telcel_ver, a.telcel_rep = b.telcel_rep,
					a.telotro_cap = b.telotro_cap, a.telotro_val = b.telotro_val, a.telotro_inval = b.telotro_inval, a.telotro_pen = b.telotro_pen, a.telotro_rep = b.telotro_rep
			WHEN NOT MATCHED THEN INSERT
						(a.tipo_movto, a.fecha,
						a.altas_ctes, a.correo_cap, a.correo_val, a.correo_inval, a.correo_pen, a.correo_rep,
						a.telcasa_cap, a.telcasa_val, a.telcasa_inval, a.telcasa_pen, a.telcasa_rep,
						a.telcel_cap, a.telcel_val, a.telcel_inval, a.telcel_pen, a.telcel_ver, a.telcel_rep,
						a.telotro_cap, a.telotro_val, a.telotro_inval, a.telotro_pen, a.telotro_rep)
				VALUES( b.tipo_movto, b.fecha,
						b.altas_ctes, b.correo_cap, b.correo_val, b.correo_inval, b.correo_pen, b.correo_rep,
						b.telcasa_cap, b.telcasa_val, b.telcasa_inval, b.telcasa_pen, b.telcasa_rep,
						b.telcel_cap, b.telcel_val, b.telcel_inval, b.telcel_pen, b.telcel_ver, b.telcel_rep,
						b.telotro_cap, b.telotro_val, b.telotro_inval, b.telotro_pen, b.telotro_rep);

			LET iBorrandoTmp = 1;

			IF bT1 = 't' THEN
				DROP TABLE tmp_alta_ctes_titulares;
				LET bT1 = 'f';
			END IF;

			IF bT2 = 't' THEN
				DROP TABLE tmp_si_telefonos;
				LET bT2 = 'f';
			END IF;

			IF bT3 = 't' THEN
				DROP TABLE tmp_mantto_ctes_titulares;
				LET bT3 = 'f';
			END IF;

			IF bT4 = 't' THEN
				DROP TABLE tmp_sucursal_ejecut;
				LET bT4 = 'f';
			END IF;

			IF bT5 = 't' THEN
				DROP TABLE tmp_indicadores_ctes_det;
				LET bT5 = 'f';
			END IF;

			IF bT6 = 't' THEN
				DROP TABLE tmp_telefonos_ctenvos;
				LET bT6 = 'f';
			END IF;

			IF bT7 = 't' THEN
				DROP TABLE tmp_sucursal_ejecut_mantto;
				LET bT7 = 'f';
			END IF;

			IF bT8 = 't' THEN
				DROP TABLE tmp_telefonos_ctesmantto;
				LET bT8 = 'f';
			END IF;

			IF bT9 = 't' THEN
				DROP TABLE tmp_indicadores_ctes;
				LET bT9 = 'f';
			END IF;
			LET iBorrandoTmp = 0;

		COMMIT WORK;
		LET iEnTransaccion = 0;
		LET dFechaProceso = dFechaProceso + 1 UNITS DAY;

	END WHILE;

	LET cProceso = 'REPLICA DE INFORMACION A BDIBI';
	LET cEvento	= 'OBTIENE VALOR FLAG PARA GRABAR BDIBI';

	SELECT NVL(valor,0)::INTEGER
	INTO iFlag
	FROM bdinteg:si_param
	WHERE cod_param = 343;

	IF iFlag = 1 THEN
	LET cEvento	= 'EJECUCION DE SP sp_replica_manual_indicadores_ctes_bi';

		EXECUTE PROCEDURE bdinteg:"informix".sp_replica_manual_indicadores_ctes_bi(2,dFechaIni, dFechaFin, '')
		INTO cCodRetSP, cVarDataErrSP;

			IF cCodRetSP <> '000000' THEN
				INSERT INTO si_log_indicadores_sucursal (fecha, proceso, evento, cod_error, mensaje)
				VALUES (dFechaHoy, cProceso, cEvento, cCodRetSP, cVarDataErrSP);

				LET vCodRet = cCodRetSP;
				LET cVarDataErr = cVarDataErrSP;
			END IF;
	END IF;
	LET iBorrandoTmp = 1;

	IF bT1 = 't' THEN
		DROP TABLE tmp_alta_ctes_titulares;
		LET bT1 = 'f';
	END IF;

	IF bT2 = 't' THEN
		DROP TABLE tmp_si_telefonos;
		LET bT2 = 'f';
	END IF;

	IF bT3 = 't' THEN
		DROP TABLE tmp_mantto_ctes_titulares;
		LET bT3 = 'f';
	END IF;

	IF bT4 = 't' THEN
		DROP TABLE tmp_sucursal_ejecut;
		LET bT4 = 'f';
	END IF;

	IF bT5 = 't' THEN
		DROP TABLE tmp_indicadores_ctes_det;
		LET bT5 = 'f';
	END IF;

	IF bT6 = 't' THEN
		DROP TABLE tmp_telefonos_ctenvos;
		LET bT6 = 'f';
	END IF;

	IF bT7 = 't' THEN
		DROP TABLE tmp_sucursal_ejecut_mantto;
		LET bT7 = 'f';
	END IF;

	IF bT8 = 't' THEN
		DROP TABLE tmp_telefonos_ctesmantto;
		LET bT8 = 'f';
	END IF;

	IF bT9 = 't' THEN
		DROP TABLE tmp_indicadores_ctes;
		LET bT9 = 'f';
	END IF;
	LET iBorrandoTmp = 0;

	RETURN vCodRet, cMensCodRet;
END;
END PROCEDURE
DOCUMENT
'FECHA:09/09/2015',
'VERSION:20150909.1515',
'REALIZO: JOSE ANGEL LOPEZ ADAMS',
'DESCRIPCION: Se realiza el recalculo de los indicadores de telefonos y correos de un rango de fechas establecido',
'			  Si esta encendida la replica a BI actualizara/insertara los registros generados',
'FECHA: 24/10/2017',
'VERSION: 20171024',
'RELIZO: Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica proceso para hacer llamado al sp_replica_manual_indicadores_ctes_bi correctamente (4 parÃÂ¡metros)',
'FECHA: 29/09/2021',
'REALIZ: Miguel Angel Solano Valdez',
'DESCRIPCION: Se corrige consulta para tomar correctmente el valor de fecha_hora de la tabla si_correos',
'FECHA: 07/11/2022',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se corrige consulta para validar el valor sobre fecha_hora de la tabla si_correos',
'FECHA: 11/01/2023',
'REALIZO: Uriel Amador Islas',
'DESCRIPCION: Se agrega validaciÃ³n sobre el status de correo (A/C), para solo obtener los correos con status "A" (Alta)';

CREATE PROCEDURE "informix".sp_inserta_msjafore(pNumcte CHAR(20), pCuenta_tarjeta CHAR(20), pSucursal CHAR(4), pDebito CHAR(8))

RETURNING CHAR(5)  AS cCodRet;

--Definicion de Variables
DEFINE cCodRet			CHAR(5);
DEFINE iSqlErr 			INTEGER;

DEFINE cCurp			CHAR(20);
DEFINE cApell_paterno	CHAR(26);
DEFINE cApell_materno	CHAR(26);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cFecha_nac		DATE;
DEFINE cLugar_nac		CHAR(2);
DEFINE cSexo			CHAR(1);
DEFINE cNroCta_tarj		CHAR(20);

--Inicializacion de Variables
LET cCodRet    		= '00000';
LET iSqlErr 		= 0;

LET cCurp			= '';
LET cApell_paterno	= '';
LET cApell_materno	= '';
LET cNombre1		= '';
LET cNombre2		= '';
LET cFecha_nac		= NULL;
LET cLugar_nac		= '';
LET cSexo			= '';
LET cNroCta_tarj 	= '';


--SET DEBUG FILE TO '/ifxsif01/LIP/sp_inserta_msjafore.out';
--TRACE ON;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	--Sucursal y empleado
	IF ((pSucursal IS NOT NULL AND pSucursal <> '') AND (pDebito IS NOT NULL AND pDebito <> '')) THEN


		--Numero de cliente
		IF (pNumcte IS NOT NULL AND pNumcte <> '') THEN
		
			SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
			INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
			FROM bdinteg:si_cliente cte
					INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
			WHERE cte.numcte = pNumcte;


			INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
			VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
					
			RETURN cCodRet;
		
		END IF;
		
		--Numero de cuenta o tarjeta
		IF (pCuenta_tarjeta IS NOT NULL AND pCuenta_tarjeta <> '') THEN
			--Tarjeta
			IF(LENGTH(TRIM(pCuenta_tarjeta)) = 16) THEN
				
				
					--debito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicheq:sc_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_tarjeta 
					WHERE num_tarjeta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
				
					END IF;
				
			
			--Cuenta
			ELSE
			
				
					--debito
					SELECT FIRST 1 num_cte
					INTO pNumcte
					FROM bdicheq:sc_maechq 
					WHERE cuenta = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
						

						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
								
						RETURN cCodRet;
					
					END IF;
				
				
					--credito
					SELECT FIRST 1 numcte
					INTO pNumcte
					FROM bdicred:sd_maecred 
					WHERE num_credito = pCuenta_tarjeta;
					
					IF(pNumcte IS NOT NULL AND pNumcte <> '') THEN
					
						SELECT pf.curp, cte.apell_paterno, cte.apell_materno, cte.nombre1, cte.nombre2, pf.fecha_nac, pf.lugar_nac, pf.sexo
						INTO cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo
						FROM bdinteg:si_cliente cte
								INNER JOIN bdinteg:si_ctepf pf ON cte.numcte = pf.numcte
						WHERE cte.numcte = pNumcte;
					
				
						INSERT INTO bdinteg:si_ws_mensajeafore(numcte, ejecutivo, sucursal, curp, apell_paterno, apell_materno, nombre1, nombre2, fecha_nac, lugar_nac, sexo, fecha_insert)
						VALUES(pNumcte, pDebito, pSucursal, cCurp, cApell_paterno, cApell_materno, cNombre1, cNombre2, cFecha_nac, cLugar_nac, cSexo, CURRENT);
							
						RETURN cCodRet;
					
					END IF;
				
			
			END IF;
			
		
		END IF;

	END IF;

	RETURN cCodRet;
END;

END PROCEDURE;