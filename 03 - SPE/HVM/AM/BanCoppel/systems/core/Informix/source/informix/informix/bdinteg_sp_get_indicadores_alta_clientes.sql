CREATE PROCEDURE "informix".sp_get_indicadores_alta_clientes(dFechaProceso DATE, cTipoRp CHAR(2),  iIdRp INTEGER)
	
	DEFINE cCodRet	CHAR(6);
	DEFINE cMensaje	CHAR(100);
	DEFINE iSqlErr 	INTEGER;
	DEFINE iSamErr	INTEGER;
	
	DEFINE cProceso	CHAR(100);
	DEFINE cEvento	CHAR(100);
	
	DEFINE cSucursal 		INTEGER;
	DEFINE iProspectos 		INTEGER;
	DEFINE cNumCte			CHAR(20);
	DEFINE iBanco			INTEGER;
	DEFINE iCoppel			INTEGER;
	DEFINE iSinProductos	INTEGER;
	DEFINE iBanco_Coppel	INTEGER;
	DEFINE iSolo_Coppel		INTEGER;
	DEFINE iSolo_Banco		INTEGER;
	DEFINE iBca_Basica		INTEGER;
	DEFINE iBca_Avanzada	INTEGER;
	DEFINE iTitulares		INTEGER;
	DEFINE bEnTransaccion	BOOLEAN;
	DEFINE cFlag			CHAR(1);
	DEFINE bExisteTemp		BOOLEAN;
		
	LET cCodRet = '000000';
	LET cMensaje = 'PROCESO EXITOSO';
	
	LET cSucursal = '';
	LET iProspectos = 0;
	LET cNumCte = '';
	LET iBanco = 0;
	LET iCoppel = 0;
	LET iSinProductos=0;
	LET iBanco_Coppel=0;
	LET iSolo_Coppel=0;
	LET iSolo_Banco = 0;	
	LET iBca_Basica=0;	
	LET iBca_Avanzada=0;
	LET iTitulares = 0;
	
	LET cFlag = '';
	LET bEnTransaccion = 'f';
	LET bExisteTemp = 'f';
	
	--SET DEBUG FILE TO '/tmp/josea/64171/sp_get_indicadores_alta_clientes.out';
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
		
		--LET cProceso = 'INDICADORES DE ALTA DE CLIENTES';
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
				
				--IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_alta_ctes_indicadores WHERE fecha_proceso = dFechaProceso) THEN
				
					LET cEvento = 'VALIDACION DE TABLA TEMPORAL';
					
					IF NOT EXISTS(SELECT 1 FROM si_tmp_alta_ctes_titulares WHERE fecha_alta = dFechaProceso) THEN
						LET cEvento = 'GENERACION DE INFORMACION TEMPORAL';
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;	
						INSERT INTO si_tmp_alta_ctes_titulares
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} a.sucursal, a.numcte, b.usuario AS numemp, b.fecha_alta
						FROM bdinteg:"informix".si_cliente a, bdinteg:"informix".si_cte_huella b 
						WHERE a.numcte=b.numcte AND b.secuencia=1 AND b.fecha_alta=dFechaProceso 
						AND a.tipo_cliente='1';
					END IF;
					LET cEvento = 'INSERCION DE INDICADORES DE ALTA DE CLIENTES EN SI_ALTA_CTES_INDICADORES_SUC';
					
					DELETE FROM bdinteg:si_alta_ctes_indicadores_suc
					WHERE fecha_proceso=dFechaProceso;
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
					SELECT fecha_alta, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert
					FROM (TABLE(MULTISET(SELECT fecha_alta ,sucursal, NVL(COUNT(*),0) AS titulares,0 AS prospectos,0 AS total,0 AS tot_prod_coppel,0 AS tot_prod_banco,0 AS tot_cop_bco, 0 AS tot_sinproductos,0 AS tot_bca_basica,0 AS tot_bca_avanzada, USER AS user_insert, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals) AS fecha_insert
					FROM si_tmp_alta_ctes_titulares
					GROUP BY fecha_alta, sucursal 
					ORDER BY sucursal)));
					
					LET cEvento = 'GENERACION DE INDICADORES DE ALTA DE CLIENTES PROSPECTOS';	
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					FOREACH
						SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} sucursal, NVL(COUNT(*),0) AS prospectos
						INTO cSucursal, iProspectos
						FROM bdinteg:si_cliente 
						WHERE tipo_cliente='2'
						AND fecha_alta= dFechaProceso
						GROUP BY sucursal  
						
						IF EXISTS (SELECT fecha_proceso FROM bdinteg:"informix".si_alta_ctes_indicadores_suc WHERE fecha_proceso = dFechaProceso AND sucursal = cSucursal) THEN
							UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
							SET prospectos = iProspectos  
							WHERE fecha_proceso=dFechaProceso 
							AND sucursal=cSucursal; 
						ELSE
							INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores_suc(fecha_proceso, sucursal, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
							VALUES(dFechaProceso, cSucursal, 0, NVL(iProspectos,0), NVL(iProspectos,0),0,0,0,0,0,0, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
						END IF;										
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE PRODUCTOS DE NUEVOS CLIENTES TITULARES';
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;			
					FOREACH 
						SELECT DISTINCT sucursal 
						INTO cSucursal
						FROM si_tmp_alta_ctes_titulares			
						FOREACH		
							SELECT numcte 
							INTO cNumCte
							FROM si_tmp_alta_ctes_titulares 
							WHERE sucursal=cSucursal		
																	
							LET iBanco = 0;
							LET iCoppel = 0;
										
							IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cNumCte AND sucursal=cSucursal) THEN
								LET iBanco=1;			
							ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cNumCte AND sucursal=cSucursal AND tipo_solicitud<>'C') THEN
								LET iBanco=1;
							ELIF EXISTS (SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cNumCte AND sucursal=cSucursal) THEN
								LET iBanco=1;
							END IF;				
							IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cNumCte AND sucursal=cSucursal AND tipo_solicitud='C') THEN
								LET iCoppel=1; 
							END IF;	
							IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
								LET iSinProductos = iSinProductos + 1;  
							END IF;		
							IF (iBanco = 1 AND iCoppel=1 ) THEN
								LET iBanco_Coppel=iBanco_Coppel + 1;  
							ELSE
								LET iSolo_Coppel = iSolo_Coppel + iCoppel; 
								LET iSolo_Banco = iSolo_Banco + iBanco; 
							END IF;					
						END FOREACH;	
									
						LET cEvento = 'GENERACION DE INDICADORES DE BANCA BASICA/AVANZADA DE NUEVOS CLIENTES TITULARES';
						
						SET ISOLATION TO DIRTY READ;
						SET LOCK MODE TO WAIT 3;
						SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
						INTO iBca_Basica, iBca_Avanzada
						FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
											CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
											CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
											FROM bdinteg:"informix".si_bpiusuarios a, si_tmp_alta_ctes_titulares b
											WHERE a.numcte=b.numcte
											AND a.suc_registro = b.sucursal 
											AND a.suc_registro= cSucursal
											AND a.f_registro::DATE=dFechaProceso
											AND b.fecha_alta::DATE=dFechaProceso
											GROUP BY a.servicio))); 
						
						UPDATE bdinteg:"informix".si_alta_ctes_indicadores_suc 
						SET total =(iSolo_Coppel + iSolo_Banco + iBanco_Coppel + iSinProductos), tot_prod_coppel=iSolo_Coppel, tot_prod_banco=iSolo_Banco, tot_cop_bco=iBanco_Coppel, tot_sinproductos = iSinProductos, tot_bca_basica=iBca_Basica, tot_bca_avanzada=iBca_Avanzada  
						WHERE fecha_proceso=dFechaProceso 
						AND sucursal=cSucursal;				
						LET iBca_Basica=0;
						LET iBca_Avanzada=0;
						LET iBanco_Coppel=0;
						LET iSolo_Coppel=0;
						LET iSolo_Banco=0;
						LET iSinProductos=0;
					END FOREACH;
					
					LET iBanco_Coppel = 0;
					LET iSolo_Coppel = 0;
					LET iSolo_Banco = 0;
					LET iSinProductos = 0;	
					--GENERA TOTALES GLOBALES DE ALTA DE CLIENTES.
					SELECT NVL(COUNT(*),0)
					INTO iTitulares
					FROM si_tmp_alta_ctes_titulares;
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT {+INDEX (bdinteg:"informix".si_cliente idx_si_clientex )} NVL(COUNT(*),0)
					INTO iProspectos
					FROM bdinteg:si_cliente
					WHERE tipo_cliente = '2'
					AND fecha_alta = dFechaProceso; 
									
					FOREACH --	AGREGAR LA SUCURSAL
						SELECT numcte, sucursal 
						INTO cNumCte, cSucursal
						FROM si_tmp_alta_ctes_titulares
						
						LET iBanco = 0;
						LET iCoppel = 0;
						
						IF EXISTS(SELECT num_cte FROM bdicheq:"informix".sc_maechq WHERE num_cte=cNumCte AND sucursal=cSucursal ) THEN
							LET iBanco=1;
						ELIF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cNumCte AND sucursal=cSucursal AND tipo_solicitud<>'C') THEN
							LET iBanco=1;			
						ELIF EXISTS(SELECT {+INDEX (bdinvers:"informix".sv_maeinv mai3)} num_cte FROM bdinvers:"informix".sv_maeinv WHERE num_cte=cNumCte AND sucursal=cSucursal ) THEN
							LET iBanco=1;
						END IF;			
						IF EXISTS(SELECT {+INDEX (bdisolic:"informix".ss_solicitudes idx_numctesolic)} numcte FROM bdisolic:"informix".ss_solicitudes WHERE numcte=cNumCte AND sucursal=cSucursal AND tipo_solicitud='C') THEN
							LET iCoppel=1; 
						END IF;
						--CONTABILIZA LOS TOTALES DE CLIENTES POR PRODUCTO
						IF (iBanco = 0 AND iCoppel=0 ) THEN --EN CASO QUE NO TENGA CUENTA DE BANCO NI DE COPPEL
							LET iSinProductos = iSinProductos + 1;  
						END IF;	
						IF (iBanco = 1 AND iCoppel=1) THEN
							LET iBanco_Coppel = iBanco_Coppel + 1;  
						ELSE
							LET iSolo_Coppel = iSolo_Coppel + iCoppel; 
							LET iSolo_Banco = iSolo_Banco + iBanco; 
						END IF;			
					END FOREACH;
					
					LET cEvento = 'GENERACION DE INDICADORES DE TOTAL CLIENTES CON BANCA BASICA/AVANZADA';
					
					SET ISOLATION TO DIRTY READ;
					SET LOCK MODE TO WAIT 3;
					SELECT NVL(SUM(bca_basica),0) AS bca_basica, NVL(SUM(bca_avanzada),0) AS bca_avanzada
					INTO iBca_Basica, iBca_Avanzada
					FROM (TABLE(MULTISET(SELECT {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} 
										CASE WHEN a.servicio= 1 THEN COUNT(a.numcte) END AS bca_basica,
										CASE WHEN a.servicio= 2 THEN COUNT(a.numcte) END AS bca_avanzada			
										FROM bdinteg:"informix".si_bpiusuarios a, si_tmp_alta_ctes_titulares b
										WHERE a.numcte=b.numcte
										AND a.suc_registro= b.sucursal 
										AND a.f_registro BETWEEN (EXTEND(MDY(MONTH(dFechaProceso), DAY(dFechaProceso), YEAR(dFechaProceso)), YEAR to SECOND)+ 0 UNITS HOUR+0 UNITS MINUTE+0 UNITS SECOND) AND (EXTEND(MDY(MONTH(dFechaProceso), DAY(dFechaProceso), YEAR(dFechaProceso)), YEAR to SECOND)+ 23 UNITS HOUR+59 UNITS MINUTE+59 UNITS SECOND)
										AND b.fecha_alta = dFechaProceso
										GROUP BY a.servicio)));  
					
					IF NOT EXISTS (SELECT 1 FROM bdinteg:"informix".si_alta_ctes_indicadores WHERE fecha_proceso = dFechaProceso) THEN
						INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
						VALUES (dFechaProceso, NVL(iTitulares,0), NVL(iProspectos,0), NVL(( iTitulares + iProspectos),0), NVL(iSolo_Coppel,0), NVL(iSolo_Banco,0) , NVL(iBanco_Coppel,0), NVL(iSinProductos,0), NVL(iBca_Basica,0), NVL(iBca_Avanzada,0), USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));

						IF DBINFO ('sqlca.sqlerrd2') = 0 THEN
							INSERT INTO bdinteg:"informix".si_alta_ctes_indicadores(fecha_proceso, titulares, prospectos, total, tot_prod_coppel, tot_prod_banco, tot_cop_bco, tot_sinproductos, tot_bca_basica, tot_bca_avanzada, user_insert, fecha_insert)
							VALUES(dFechaProceso, 0, 0, 0,0,0,0,0,0,0, USER, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
						END IF;	
					ELSE
						UPDATE bdinteg:si_alta_ctes_indicadores
						SET titulares = NVL(iTitulares,0), 
							prospectos = NVL(iProspectos,0),
							total = NVL(( iTitulares + iProspectos),0),
							tot_prod_coppel = NVL(iSolo_Coppel,0), 
							tot_prod_banco = NVL(iSolo_Banco,0), 
							tot_cop_bco = NVL(iBanco_Coppel,0), 
							tot_sinproductos = NVL(iSinProductos,0), 
							tot_bca_basica =  NVL(iBca_Basica,0),  
							tot_bca_avanzada = NVL(iBca_Avanzada,0),
							fecha_insert = (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals)
						WHERE fecha_proceso = dFechaProceso;
					END IF;
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