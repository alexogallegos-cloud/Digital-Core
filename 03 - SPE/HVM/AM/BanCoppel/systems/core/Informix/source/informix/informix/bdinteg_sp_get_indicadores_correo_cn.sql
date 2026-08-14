CREATE PROCEDURE "informix".sp_get_indicadores_correo_cn(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);
	
	DEFINE cFlag	CHAR(1);
	DEFINE bEnTransaccion	BOOLEAN;
	
	DEFINE iTotalCorreos	INTEGER;
	DEFINE iCorreosValidos	INTEGER;
	DEFINE iCorreosInvalidos INTEGER;
	DEFINE iCorreosSinValidar INTEGER;
	DEFINE cSucursal	CHAR(4);
	
	DEFINE cFechaProceso	CHAR(11);
	
		
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET cFlag = '';
	LET bEnTransaccion = 'f';
	
	LET iTotalCorreos = 0;
	LET iCorreosValidos = 0;
	LET iCorreosInvalidos = 0;
	LET iCorreosSinValidar = 0;
	LET cSucursal = '';
	
	LET cFechaProceso = '';
	
	--SET DEBUG FILE TO '/informix/jagl/bdinteg/sp_get_indicadores_correo_cn.out';
	--TRACE ON;	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
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
		
		--LET cProceso = 'INDICADORES DE CORREOS DE CLIENTES NUEVOS';
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
		
		LET cFechaProceso = (TO_CHAR(dFechaproceso, '%Y-%m-%d')) || '%';
		
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
								
				--IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_correos_clientes_nvos WHERE fecha = dFechaproceso) THEN
				
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL';
					
					IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaproceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;	
						INSERT INTO si_tmp_alta_ctes_titulares
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
						FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
						WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaproceso 
						AND a.tipo_cliente='1';
					END IF;
					
					LET cEvento = 'OBTENCION DE INDICADORES EN SI_TELEFONOS';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					LET cEvento = 'INSERCION DE INDICADORES EN SI_ESTADISTICA_CORREOS_CLIENTES_NVOS';

					FOREACH
						SELECT sucursal, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar
						INTO cSucursal, iTotalCorreos, iCorreosValidos, iCorreosInvalidos, iCorreosSinValidar
						FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} d.sucursal,
												CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) ELSE 0 END AS validos,
												CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) ELSE 0 END AS invalidos,
												CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) ELSE 0 END AS sin_validar								
											FROM bdinteg:"informix".si_correos a, si_tmp_alta_ctes_titulares b,  bdinteg:"informix".si_ejecut d
											WHERE a.numcte=b.numcte
											AND a.secuencia =1
											--AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
											AND a.fecha_hora like cFechaProceso
											AND a.user_insert = d.ejecutivo
											GROUP BY d.sucursal, a.valido))
						GROUP BY 1
						
						IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_estadistica_correos_clientes_nvos WHERE fecha = dFechaproceso AND sucursal = cSucursal) THEN
							INSERT INTO bdinteg:"informix".si_estadistica_correos_clientes_nvos (sucursal, fecha, total, validos, invalidos, sin_validar, user_insert, fecha_insert)
							VALUES (cSucursal, dFechaProceso, iTotalCorreos, iCorreosValidos, iCorreosInvalidos, iCorreosSinValidar, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
						ELSE
							UPDATE bdinteg:si_estadistica_correos_clientes_nvos
							SET total = iTotalCorreos,
								validos = iCorreosValidos,
								invalidos = iCorreosInvalidos, 
								sin_validar = iCorreosSinValidar,
								fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
							WHERE fecha = dFechaproceso AND sucursal = cSucursal;
						END IF;
					END FOREACH;
					/*SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					INSERT INTO bdinteg:"informix".si_estadistica_correos_clientes_nvos (sucursal, fecha, total, validos, invalidos, sin_validar, user_insert, fecha_insert)
					SELECT sucursal,dFechaproceso AS fecha_proceso, NVL(SUM(validos),0)+ NVL(SUM(invalidos),0)+ NVL(SUM(sin_validar),0) AS total_correos, NVL(SUM(validos),0) AS validos, NVL(SUM(invalidos),0) AS invalidos, NVL(SUM(sin_validar),0) AS sin_validar, USER, CURRENT::DATE
					FROM TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_correos idx_corr_status)} d.sucursal,
											CASE WHEN a.valido = '1' THEN COUNT(a.correo_elec) ELSE 0 END AS validos,
											CASE WHEN a.valido = '0' THEN COUNT(a.correo_elec) ELSE 0 END AS invalidos,
											CASE WHEN a.valido IS NULL THEN COUNT(a.correo_elec) ELSE 0 END AS sin_validar								
										FROM bdinteg:"informix".si_correos a, si_tmp_alta_ctes_titulares b,  bdinteg:"informix".si_ejecut d
										WHERE a.numcte=b.numcte
										AND a.secuencia =1
										AND a.fecha_hora::DATETIME YEAR TO FRACTION::DATE = dFechaproceso
										AND a.user_insert = d.ejecutivo
										GROUP BY d.sucursal, a.valido))
					GROUP BY 1,2;*/
				--END IF;

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