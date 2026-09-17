CREATE PROCEDURE "informix".sp_get_indicadores_cels_rep(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);
	
	DEFINE iValidos	INTEGER;
	DEFINE iInvalidos	INTEGER;	
	
	DEFINE cFlag	CHAR(1);
	DEFINE bEnTransaccion	BOOLEAN;
	DEFINE bExisteTemp	BOOLEAN;	
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET iValidos = 0;
	LET iInvalidos = 0;
	LET cFlag = '';
	LET bEnTransaccion = 'f';
	LET bExisteTemp = 'f';
	
	--SET DEBUG FILE TO '/tmp/josea/64171/sp_get_indicadores_cels_rep.out';
	--TRACE ON;		
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;					
					LET bEnTransaccion = 'f';
					
					IF bExisteTemp = 't' THEN
						LET bExisteTemp = 'f';
					END IF;
				END IF;
				
				IF bExisteTemp = 't' THEN
					DROP TABLE tmp_estadistica_cels_repetidos;
					LET bExisteTemp = 'f';
				END IF;
				
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
		
		--LET cProceso = 'INDICADORES DE CELULARES REPETIDOS';
		LET cEvento = 'VALIDACION DE PARAMETROS';
		
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

				LET cEvento = 'VALIDACION DE TABLA TEMPORAL';
				
				IF NOT EXISTS(SELECT 1 FROM si_tmp_telefonos WHERE fecha = dFechaproceso) THEN
					LET cEvento = 'GENERACION DE INFORMACION TEMPORAL';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO si_tmp_telefonos
					SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
					FROM si_telefonos
					WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND);
				END IF;
				
				LET cEvento = 'OBTENCION DE INDICADORES DE SI_TELEFONOS_ACTUAL';
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;			
				SELECT NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos
				INTO iValidos, iInvalidos
				FROM (TABLE(MULTISET(SELECT CASE WHEN a.cofetel = 'V' THEN COUNT(a.telefono) END AS validos,
											CASE WHEN a.cofetel = 'F' THEN COUNT(a.telefono) END AS invalidos                       
									 FROM bdinteg:si_tmp_telefonos a, bdinteg:si_cliente b 							
									 WHERE a.numcte=b.numcte
									 AND a.tipo_tel='2' 
									 AND a.fecha = dFechaproceso
									 AND b.fecha_alta= a.fecha
									 GROUP BY a.cofetel)));
									 
				IF NOT EXISTS (SELECT 1 FROM bdinteg:si_estadistica_cels WHERE fecha = dFechaProceso) THEN
					LET cEvento = 'INSERCION DE INDICADORES DE SI_ESTADISTICA_CELS';						
					INSERT INTO bdinteg:"informix".si_estadistica_cels(fecha, total, validos, invalidos, user_insert, fecha_insert)
					VALUES(dFechaproceso, (NVL(iValidos,0)+ NVL(iInvalidos,0)), NVL(iValidos,0), NVL(iInvalidos,0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));	
				ELSE
					UPDATE bdinteg:"informix".si_estadistica_cels
					SET total = (NVL(iValidos,0)+ NVL(iInvalidos,0)),
						validos =  NVL(iValidos,0),
						invalidos =  NVL(iInvalidos,0), 
						fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE fecha = dFechaProceso;
				END IF;
				
				LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CELS_REPETIDOS';
				SET ISOLATION TO DIRTY READ;
				SET LOCK MODE TO WAIT 3;
				SELECT  a.telefono, COUNT(*) AS cantidad, b.sucursal, b.user_insert AS usuario, b.fecha_alta AS fecha, USER AS user_insert, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals) AS fecha_insert
				FROM bdinteg:si_tmp_telefonos a, bdinteg:si_cliente b
				WHERE a.numcte=b.numcte
				AND a.tipo_tel='2' 
				AND a.fecha = dfechaproceso
				AND b.fecha_alta= dFechaproceso
				GROUP BY 1,3,4,5
				HAVING COUNT(*) > 1
				INTO TEMP tmp_estadistica_cels_repetidos WITH NO LOG;
				
				LET bExisteTemp = 't';

				MERGE INTO si_estadistica_cels_repetidos a
					USING tmp_estadistica_cels_repetidos b
					ON a.fecha= b.fecha AND a.sucursal = b.sucursal AND a.telefono = b.telefono AND a.usuario = b.usuario
				WHEN MATCHED THEN UPDATE
					SET a.cantidad = b.cantidad, a.fecha_insert = b.fecha_insert
				WHEN NOT MATCHED THEN
					INSERT (a.telefono, a.cantidad, a.sucursal, a.usuario, a.fecha, a.user_insert, a.fecha_insert)
					VALUES (b.telefono, b.cantidad, b.sucursal, b.usuario, b.fecha, b.user_insert, b.fecha_insert);
									
				IF bExisteTemp = 't' THEN
					DROP TABLE tmp_estadistica_cels_repetidos;
					LET bExisteTemp = 'f';
				END IF;
				
			COMMIT WORK;
			LET bEnTransaccion = 'f';
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