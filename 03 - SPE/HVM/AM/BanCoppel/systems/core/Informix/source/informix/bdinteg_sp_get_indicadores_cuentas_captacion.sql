CREATE PROCEDURE "informix".sp_get_indicadores_cuentas_captacion(dFechaProceso DATE, cTipoRp CHAR(2), iIdRp INTEGER)

	--DEFINICION DE VARIABLES
	DEFINE cCodRet 		 			CHAR(6);
	DEFINE cMensaje 	 			CHAR(50);
	DEFINE cProceso					CHAR(100);
	DEFINE cEvento					CHAR(100);
	DEFINE iSQLerr		 			INTEGER;
	DEFINE iSamErr					INTEGER;
	DEFINE bEnTransaccion			BOOLEAN;
	DEFINE cFlag					CHAR(1);
	DEFINE bTablatmp				BOOLEAN;
	DEFINE dFecha					DATE;
	DEFINE iCtesNvosctascap 		INTEGER;
	DEFINE iCelregctesnvos			INTEGER;
	DEFINE iCelverimisdia			INTEGER;
	DEFINE iCelnover				INTEGER;
	DEFINE iTelcasa					INTEGER;
	DEFINE iCtesExisctascap			INTEGER;
	DEFINE iCelregctesexis			INTEGER;
	DEFINE iCelVeriMisDiaCtesExis	INTEGER;
	DEFINE iCelNoVerCtesExis		INTEGER;
	DEFINE iCelRegVerFechPost		INTEGER;
	DEFINE iTelCasaCtesExis			INTEGER;

	--INICIALIZACION DE VARIABLES 
	LET cCodRet 	   	       	= '000000';
	LET cMensaje 	   	        = 'PROCESO EXITOSO';
	LET iSQLerr 	  	       	= 0;
	LET bEnTransaccion         	= 'f';
	LET cFlag					= '';
	LET bTablatmp			   	= 'f';
	LET dFecha			       	= '';
	LET iCtesNvosctascap       	= 0;
	LET iCelregctesnvos	       	= 0;
	LET iCelverimisdia	       	= 0;
	LET iCelnover		       	= 0;
	LET iTelcasa		       	= 0;
	LET iCtesExisctascap   	   	= 0;
	LET iCelregctesexis	   	   	= 0;
	LET iCelVeriMisDiaCtesExis 	= 0;
	LET iCelNoVerCtesExis      	= 0;
	LET iCelRegVerFechPost     	= 0;
	LET iTelCasaCtesExis       	= 0;

	--SET DEBUG FILE TO '/tmp/Ingrid/sp_get_indicadores_cuentas_captacion.out';
	--TRACE ON;
	
	BEGIN
		--MANEJO DEL ERROR
		ON EXCEPTION SET iSqlErr, iSamErr, cMensaje
			IF iSqlErr <> 0 THEN
				LET cCodRet=iSqlErr;
				
				IF bEnTransaccion = 't' THEN
					ROLLBACK WORK;
					LET bEnTransaccion = 'f';
					
					IF bTablatmp = 't' THEN
						LET bTablatmp = 'f';
						
					END IF;
				END IF;
				
				IF bTablatmp = 't' THEN
					DROP TABLE tmp_ctes_ctas_cap;
					LET bTablatmp = 'f';
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
		SELECT flagfinalizado INTO cFlag
		FROM  si_controlproc_indicadores 
		WHERE tipo = cTipoRp AND id_proc = iIdRp AND fecha_procesoIni = dFechaProceso AND fecha_procesoFin = dFechaProceso;

		IF NVL(cFlag,'') = '' THEN
			INSERT INTO si_controlproc_indicadores (fecha_procesoIni, fecha_procesoFin, tipo, id_proc, nombre_proceso, fecha_cargaini, fecha_cargafin, maxfecha_cargada, flagfinalizado, coderror, msgerror)
			VALUES (dFechaProceso, dFechaProceso, cTipoRp, iIdRp, NVL(cProceso,''), (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals), NULL, NULL, 'F', NULL, NULL );
		END IF;	
					
		IF cCodRet::INTEGER = 0 THEN
			BEGIN WORK;
			LET bEnTransaccion = 't';						
					
				LET cEvento = 'VALIDACION DE TABLAS TEMPORALES';
				
				IF NOT EXISTS(SELECT 1 FROM si_tmp_telefonos WHERE fecha = dFechaproceso) THEN
					LET cEvento = 'GENERACION DE INFORMACION TEMPORAL DE TELEFONOS';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO si_tmp_telefonos
					SELECT {+INDEX (bdinteg:"informix".si_telefonos idx_fecha_tel )} *, dFechaproceso::DATE AS fecha
					FROM si_telefonos
					WHERE fecha_hora BETWEEN (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaproceso), DAY(dFechaproceso), YEAR(dFechaproceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND);
				END IF;
					
				IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaproceso) THEN
					LET cEvento = 'GENERACION DE INFORMACION TEMPORAL DE CLIENTES TITULARES';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO si_tmp_alta_ctes_titulares
					SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
					FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
					WHERE a.numcte = b.numcte AND b.secuencia = 1 AND b.fecha_alta = dFechaproceso 
					AND a.tipo_cliente= '1';	
				END IF;
				
				LET cEvento = 'CREACION DE TABLA TEMPORAL tmp_cuentas_ctes';
				
				DROP TABLE IF EXISTS tmp_cuentas_ctes;
				SELECT a.num_cte AS numcte, a.cuenta, (dFechaproceso) AS fecha_alta
				FROM bdicheq:sc_maechq a, bdicheq:sc_maenoc b
				WHERE a.cuenta = b.cuenta AND clase_cta = '1' AND fecha_alta = dFechaproceso
				INTO TEMP tmp_cuentas_ctes WITH NO LOG;
				
				LET cEvento = 'OBTENCION DE FECHA Y CLIENTES NUEVOS CON CUENTA DE CAPTACION';

				SELECT COUNT(DISTINCT a.numcte)
				INTO iCtesNvosctascap
				FROM bdinteg:si_tmp_alta_ctes_titulares a, tmp_cuentas_ctes b
				WHERE a.fecha_alta  = b.fecha_alta
				AND a.numcte = b.numcte
				AND b.fecha_alta = dFechaproceso;
					
				LET cEvento = 'OBTENCION DE CANTIDAD DE CELULARES CTES NUEVOS';
					
				SELECT NVL(COUNT(b.telefono),0) 
				INTO iCelregctesnvos
				FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:si_tmp_telefonos b, tmp_cuentas_ctes c
				WHERE a.numcte = b.numcte 
				AND b.numcte = c.numcte
				AND b.tipo_tel = '2' AND b.status_tel = 'A'
				AND a.fecha_alta = b.fecha
				AND b.fecha = dFechaproceso;				
				
				LET cEvento = 'OBTENCION DE CELULARES REGISTRADOS Y VERIFICADOS EL MISMO DIA DEL REGISTRO CTES NUEVOS';
				
				SELECT NVL(COUNT(b.telefono),0) 
				INTO iCelverimisdia
				FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:si_tmp_telefonos b, tmp_cuentas_ctes c
				WHERE a.numcte = b.numcte 
				AND b.numcte = c.numcte
				AND b.tipo_tel = '2' AND b.status_tel = 'A' AND b.verificado = 'V'
				AND a.fecha_alta = b.fecha 
				AND b.fecha = DATE(fecha_actualiza)
				AND b.fecha = dFechaproceso;
				
					
				LET cEvento = 'OBTENCION DE CELULARES NO VERIFICADOS CTES NUEVOS';
				
				SELECT NVL(COUNT(b.telefono),0) 
				INTO iCelnover
				FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:si_tmp_telefonos b, tmp_cuentas_ctes c
				WHERE a.numcte = b.numcte 
				AND b.numcte = c.numcte
				AND b.tipo_tel = '2' AND b.status_tel = 'A' AND b.verificado <> 'V'
				AND a.fecha_alta = b.fecha 
				AND b.fecha = dFechaproceso;
				
			
				LET cEvento = 'OBTENCION DE TELEFONOS DE CASA CTES NUEVOS';
					
				SELECT NVL(COUNT(b.telefono),0) 
				INTO iTelcasa
				FROM bdinteg:si_tmp_alta_ctes_titulares a, bdinteg:si_tmp_telefonos b, tmp_cuentas_ctes c
				WHERE a.numcte = b.numcte 
				AND b.numcte = c.numcte
				AND b.tipo_tel <> '2' AND b.status_tel = 'A'
				AND a.fecha_alta = b.fecha
				AND b.fecha = dFechaproceso;
			
			
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_indicadores_ctas_cap WHERE fecha_proceso = dFechaproceso AND id_movto = '1') THEN
				LET cEvento = 'INSERSION DE INDICADORES DE CLIENTES NUEVOS EN SI_INDICADORES_CTAS_CAP';
					INSERT INTO bdinteg:"informix".si_indicadores_ctas_cap(id_movto, fecha_proceso, ctes_ctas_cap, cel_regis, cel_regisveri_misdia, cel_noveri, cel_regisveri_fechpost, tel_casa, user_insert, fecha_insert)
					VALUES ('1', dFechaProceso, NVL(iCtesNvosctascap,0), NVL(iCelregctesnvos,0), NVL(iCelverimisdia,0), NVL(iCelNover,0), 0, NVL(iTelcasa,0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));	
				ELSE
					UPDATE bdinteg:si_indicadores_ctas_cap
					SET ctes_ctas_cap = iCtesNvosctascap, 
					cel_regis = iCelregctesnvos, 
					cel_regisveri_misdia = iCelverimisdia, 
					cel_noveri = iCelNover, 
					cel_regisveri_fechpost = 0,
					tel_casa = iTelcasa ,
					fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE fecha_proceso = dFechaproceso AND id_movto = '1';
				END IF;
					
				LET cEvento = 'CREACION DE TABLA TEMPORAL TMP_CTES_CTAS_CAP';
				
				SELECT a.num_cte 
				FROM TABLE(MULTISET(SELECT {+INDEX(bdicheq:sc_maenoc idx_sc_maenoc2)} DISTINCT a.num_cte
									FROM bdicheq:sc_maechq a INNER JOIN bdicheq:sc_maenoc b
									ON a.cuenta = b.cuenta
									WHERE b.cuenta >= '1' AND b.clase_cta ='1' AND b.fecha_alta = dFechaProceso)) a LEFT JOIN si_tmp_alta_ctes_titulares b
				ON a.num_cte = b.numcte
				WHERE b.numcte IS NULL
				INTO TEMP tmp_ctes_ctas_cap WITH NO LOG;
				
				LET bTablatmp = 't';
				
				LET cEvento = 'OBTENCION DE CLIENTES EXISTENTES CON CUENTAS DE CAPTACION';
				
				SELECT COUNT(num_cte) 
				INTO iCtesExisctascap
				FROM tmp_ctes_ctas_cap;
								
				LET cEvento = 'OBTENCION DE CANTIDAD DE CELULARES CTES EXISTENTES';

				SELECT NVL(COUNT (b.telefono),0) 
				INTO iCelregctesexis
				FROM tmp_ctes_ctas_cap a, bdinteg:si_tmp_telefonos b 
				WHERE a.num_cte = b.numcte 
				AND tipo_tel = '2' AND status_tel = 'A' 
				AND b.fecha = dFechaproceso;

				
				LET cEvento = 'OBTENCION DE CELULARES REGISTRADOS Y VERIFICADOS EL MISMO DIA DEL REGISTRO CTES EXISTENTES';
			
				SELECT COUNT(b.telefono)
				INTO iCelVeriMisDiaCtesExis
				FROM tmp_ctes_ctas_cap a, bdinteg:si_tmp_telefonos b
				WHERE a.num_cte = b.numcte
				AND tipo_tel = '2' AND status_tel = 'A' AND b.verificado = 'V'
				AND b.fecha = dFechaproceso;
				
				LET cEvento = 'OBTENCION DE CELULARES NO VERIFICADOS CTES EXISTENTES';
					
				SELECT COUNT(b.telefono) 
				INTO iCelNoVerCtesExis
				FROM tmp_ctes_ctas_cap a, bdinteg:si_tmp_telefonos b
				WHERE a.num_cte = b.numcte and tipo_tel = '2' and status_tel = 'A' AND b.verificado <> 'V'
				AND b.fecha = dFechaproceso;
				
				LET cEvento = 'OBTENCION DE CELULARES REGISTRADOS Y VERIFICADOS FECHA POSTERIOR AL REGISTRO CTES EXISTENTES';
							
				SELECT COUNT(a.telefono)
				INTO iCelRegVerFechPost
				FROM si_tmp_telefonos a, tmp_ctes_ctas_cap b
				WHERE a.numcte = b.num_cte 
				AND a.tipo_tel = '2' 
				AND a.status_tel = 'A'
				AND a.verificado = 'V'
				AND a.fecha = dFechaproceso
				AND a.fecha_actualiza > a.fecha;
				--AND a.fecha_actualiza > DATE(a.fecha_hora);
										
				LET cEvento = 'OBTENCION DE TELEFONOS DE CASA CTES EXISTENTES';
						
				SELECT COUNT(a.telefono) 
				INTO iTelCasaCtesExis
				FROM si_tmp_telefonos a, tmp_ctes_ctas_cap b
				WHERE a.numcte = b.num_cte
				AND fecha = dFechaproceso
				AND a.tipo_tel <> '2' AND a.status_tel = 'A';

					
				IF NOT EXISTS(SELECT 1 FROM bdinteg:"informix".si_indicadores_ctas_cap WHERE fecha_proceso = dFechaproceso AND id_movto = '2') THEN
				LET cEvento = 'INSERSION DE INDICADORES DE CLIENTES EXISTENTES EN SI_INDICADORES_CTAS_CAP';
					INSERT INTO bdinteg:"informix".si_indicadores_ctas_cap(id_movto, fecha_proceso, ctes_ctas_cap, cel_regis, cel_regisveri_misdia, cel_noveri, cel_regisveri_fechpost, tel_casa, user_insert, fecha_insert)
					VALUES ('2', dFechaproceso, NVL(iCtesExisctascap,0), NVL(iCelregctesexis,0), NVL(iCelVeriMisDiaCtesExis,0), NVL(iCelNoVerCtesExis,0), NVL(iCelRegVerFechPost,0), NVL(iTelCasaCtesExis,0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
				ELSE
					UPDATE bdinteg:si_indicadores_ctas_cap
						SET ctes_ctas_cap = iCtesExisctascap, 
						cel_regis = iCelregctesexis, 
						cel_regisveri_misdia = iCelVeriMisDiaCtesExis, 
						cel_noveri = iCelNoVerCtesExis,
						cel_regisveri_fechpost = iCelRegVerFechPost,
						tel_casa = iTelCasaCtesExis,
						fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
					WHERE fecha_proceso = dFechaproceso AND id_movto = '2';
				END IF;
						
			COMMIT WORK;
			LET bEnTransaccion = 'f';
		END IF;
			
		IF bTablatmp = 't' THEN
			DROP TABLE tmp_ctes_ctas_cap;
			LET bTablatmp = 'f';
		END IF;
			
		UPDATE si_controlproc_indicadores
		SET fecha_cargafin = (SELECT DBINFO('utc_to_datetime', sh_curtime) FROM sysmaster:"informix".sysshmvals), 
		maxfecha_cargada = DECODE (cCodRet, '000000', dFechaProceso, NULL), flagfinalizado = DECODE (cCodRet,'000000','V','F'),
		coderror = cCodRet, 
		msgerror = cMensaje
		WHERE tipo = cTipoRp 
		AND id_proc = iIdRp
		AND fecha_procesoIni = dFechaProceso 
		AND fecha_procesoFin = dFechaProceso;
			
	END;
END PROCEDURE;