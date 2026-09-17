CREATE PROCEDURE "informix".sp_sac_insertaremesasnoconciliadaswu_pba(pFecha_Inicio DATE, pFecha_Fin DATE, pUsuario CHAR(8))

RETURNING 
		CHAR(5)		AS codigo_respuesta,
		CHAR(80)    AS mensaje_respuesta;
		
		--DEFINICION DE VARIABLES 
		DEFINE iSqlError 			INTEGER;
		DEFINE cCodRet 				VARCHAR(5);
		DEFINE dFechaHoy 			DATE ;
		DEFINE iServicios 			INTEGER; 
		DEFINE cDiferencia 			VARCHAR(16);
		DEFINE dFechaIni 			DATE;
		DEFINE dFechaFin 			DATE;
		DEFINE cFolioSucCheques 	VARCHAR(16);
		DEFINE cReferencia 			VARCHAR(11);
		DEFINE cCuentaPrestadora	VARCHAR(11);	
		DEFINE iSumaServicios		INTEGER;
		DEFINE iPagosCheques        INTEGER;
		DEFINE cStatus				VARCHAR(1);
		DEFINE iCantidadPagosServ   INTEGER;	
		DEFINE cTransaccEfec        VARCHAR(4);
		DEFINE cTransaccAbo         VARCHAR(4);
		DEFINE cCategoria 			VARCHAR(2);
		DEFINE cConvenio 			VARCHAR(3);
		DEFINE cFolioSucServicios   VARCHAR(16);
		DEFINE cExiste				VARCHAR(2);
		DEFINE dFechaMaxima 		DATETIME YEAR TO FRACTION(5);
		DEFINE iCountServicios		INTEGER;
		DEFINE iCount 				INTEGER;
		
		DEFINE cMensaje				VARCHAR(80);
		DEFINE cRev					CHAR(1);
		DEFINE iCantidadCheques		INTEGER;
		DEFINE iCantidadPagosPAY	INTEGER;		
		DEFINE cDescripcionSPJ	    VARCHAR(100);
		DEFINE sCont				INTEGER;
		DEFINE iFolio_suc_serv      VARCHAR(13);
		DEFINE foreignA				VARCHAR(20);
		DEFINE mt_cn                VARCHAR(13);
		DEFINE iFolio_suc      		VARCHAR(16);
		DEFINE iProceso             VARCHAR(13);
		DEFINE sCommit              INTEGER;
		DEFINE countFolios          INTEGER;
		DEFINE countFoliosSuc       INTEGER;
		
		--INICIALIZAMOS LAS VARIABLES
		LET iSqlError = 0; 
		LET cCodRet = '00000';
		LET dFechaHoy = CURRENT;
		LET iServicios = 0;
		LET cDiferencia ="Sin Diferencia";
		LET dFechaIni=CURRENT;
		LET dFechaFin = CURRENT;
		LET cFolioSucCheques = "";
		LET cReferencia ="";
		LET cCuentaPrestadora = "";
		LET iPagosCheques = 0;
		LET cStatus = '0';
		LET iCantidadPagosServ = 0;
		LET cTransaccEfec      = "";
		LET cTransaccAbo      = "";
		LET cFolioSucServicios = "";
		LET cExiste = "NO";
		LET dFechaMaxima = CURRENT;
		LET iCountServicios = 0;
		LET iCount =0;
		--LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
		--LET cConvenio = SUBSTRING(pConvenio FROM 3 FOR 3);
		LET cCategoria = '';
		LET cConvenio = '';
		
		LET cMensaje				='PROCESO EXITOSO';
		LET cRev					='';
		LET iCantidadCheques		= 0;
		LET iCantidadPagosPAY		= 0;		
		LET cDescripcionSPJ	 		= 'Inserta datos de Remesas NO conciliadas de WU, OV y VG';
		LET sCont				    = 0;
		LET iFolio_suc_serv			= '';
		LET foreignA                = '';
		LET mt_cn                   = '';
		LET iFolio_suc              = '';
		LET iProceso                = '';
		LET sCommit                 =  0;
		LET countFolios             =  0;
		LET countFoliosSuc          =  0;
		
		BEGIN
			
			ON EXCEPTION SET iSqlError
				IF iSqlError <> 0 THEN		
					
					LET cCodRet = iSqlError;
					LET cMensaje = "ERROR";
	
					DELETE FROM bdisac:"informix".sac_chequesrevwu_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_serviciosrevwu_paso WHERE usuario = pUsuario;
					DELETE {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} FROM bdisac:"informix".sac_conciliacionrevwu_paso WHERE usuario = pUsuario; 
					
					--Eliminamos las tablas pagadas				
					DELETE FROM bdisac:"informix".sac_chequeswu_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_servicioswu_paso WHERE usuario = pUsuario;
					DELETE FROM bdisac:"informix".sac_wucaja_paso WHERE usuario = pUsuario;		
					RETURN cCodRet, cMensaje;					

				END IF;
			END EXCEPTION;
			
			
			--SET DEBUG FILE TO  '/RESPALDOSNEW/enrique/sp_sac_insertaremesasnoconciliadaswu.out';
			--TRACE ON;
		
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			
			IF (pFecha_Inicio =="" OR pFecha_Inicio IS NULL) OR (pFecha_Fin =="" OR pFecha_Fin IS NULL) THEN 
				LET cCodRet = '00001'; --Parametros vacios
				LET cMensaje = "ERROR";
				RETURN cCodRet,cMensaje;	
			ELSE 
				IF pFecha_Inicio = pFecha_Fin THEN		
					
					SELECT proceso 
					into iProceso 
					FROM "informix".sac_procesos_jobs 
					where fecha_proceso = pFecha_Fin and proceso='IND_RNC_WU';
					IF NVL(iProceso,"") == "" THEN
						--INSERTA EN BITACORA
						EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_RNC_WU', pFecha_Fin, '0', 'informix', 'sp_sac_insertaremesasnoconciliadaswu', cDescripcionSPJ);
					ELSE
						SELECT status 
						INTO cStatus
						FROM "informix".sac_procesos_jobs 
						WHERE fecha_proceso = pFecha_Fin and proceso='IND_RNC_WU';
						IF cStatus = '0' THEN						
							DELETE {+INDEX("informix".sac_wu_remesasnoconciliadas idxsac_wu_remesasnoconciliadasnnr)} FROM "informix".sac_wu_remesasnoconciliadas where retfecha = pFecha_Fin;										
						END IF;
					END IF;			
				END IF;	
				IF cStatus = '0' THEN
					--Remesas NO Conciliadas REVERSADAS
					BEGIN WORK;
					FOREACH		
						select numcategoria, numconvenio
						into cCategoria, cConvenio
						from bdisac:"informix".sac_convenios
						where numcategoria || numconvenio in ('07006','07007','07008')
						
						DELETE FROM bdisac:"informix".sac_chequesrevwu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_serviciosrevwu_paso WHERE usuario = pUsuario;
						DELETE {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} FROM bdisac:"informix".sac_conciliacionrevwu_paso WHERE usuario = pUsuario; 
						
						--Eliminamos las tablas pagadas				
						DELETE FROM bdisac:"informix".sac_chequeswu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_servicioswu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_wucaja_paso WHERE usuario = pUsuario;
						
						SELECT fecha_hoy {+INDEX(bdisac:"informix".sac_fechas idx_fechas1)}
						INTO dFechaHoy
						FROM bdisac:"informix".sac_fechas
						WHERE empresa = '001'; 
						
						SELECT cuenta_prestadora, trans_cen_efectivo_cliente, trans_cen_cargo_cliente
						INTO cCuentaPrestadora, cTransaccEfec, cTransaccAbo
						FROM bdisac:"informix".sac_convenios 
						WHERE numcategoria= cCategoria
						AND numconvenio= cConvenio;
						
						--Tomamos los valores de las fecha de los parametros
						LET dFechaIni = pFecha_Inicio;
						LET dFechaFin = pFecha_Fin;
						
						LET cRev					='1';
						LET iCantidadPagosPAY		= 0;
						
						IF dFechaIni = dFechaFin AND dFechaIni = dFechaHoy THEN --Consulta al dia
							
							INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy
							AND cancelad = 'S'
							AND cuenta = cCuentaPrestadora
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							AND referencia = 'REV';
							LET sCont = sCont + 1;
							
							--Insertamos en las tablas pagadas  
							INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy 
							AND cuenta = cCuentaPrestadora
							AND cancelad <> 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo);
							LET sCont = sCont + 1;
							
							INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientos
							WHERE fecha_pago= dFechaHoy
							AND numconvenio= cConvenio
							AND numcategoria= cCategoria;
							LET sCont = sCont + 1;
							
							--Insertamos en las tablas pagadas  
							INSERT INTO bdisac:"informix".sac_servicioswu_paso
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientos
							WHERE fecha_pago= dFechaHoy
							AND numconvenio= cConvenio
							AND numcategoria= cCategoria;	
							LET sCont = sCont + 1;	
							IF sCont >= 5000 THEN
								COMMIT WORK;	
								LET sCont = 0;
								BEGIN WORK;
							END IF;
						ELIF (dFechaIni <> dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) OR (dFechaIni = dFechaFin AND dFechaIni <> dFechaHoy AND dFechaFin <> dFechaHoy) THEN --Consulta del dia
					
							INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt >= dFechaIni
							AND fech_alt <= dFechaFin
							AND cancelad = 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							AND referencia = 'REV';	
							LET sCont = sCont + 1;
							
							----Insertamos en las tablas pagadas
							INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt >= dFechaIni
							AND fech_alt <= dFechaFin
							AND cancelad <> 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo);
							LET sCont = sCont + 1;
					
							INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria= cCategoria
							AND fecha_pago >= dFechaIni
							AND fecha_pago <= dFechaFin
							AND numconvenio= cConvenio;
							LET sCont = sCont + 1;
							
							---Insertamos en las tablas pagadas
							INSERT INTO bdisac:"informix".sac_servicioswu_paso
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria= cCategoria  
							AND fecha_pago >= dFechaIni
							AND fecha_pago <= dFechaFin
							AND numconvenio= cConvenio;
							LET sCont = sCont + 1;
							IF sCont >= 5000 THEN
								COMMIT WORK;	
								LET sCont = 0;
								BEGIN WORK;
							END IF;
						ELSE
							
							INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy
							AND cancelad = 'S'
							AND cuenta = cCuentaPrestadora
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							AND referencia = 'REV';
							LET sCont = sCont + 1;

							--Insertamos en las tablas pagadas
							INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movdia 
							WHERE fech_alt = dFechaHoy 
							AND cuenta = cCuentaPrestadora
							AND cancelad <> 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo);	
							LET sCont = sCont + 1;	
							
							INSERT {+INDEX("informix".sac_chequesrevwu_paso idx_tmpchequesrevwu1)} INTO bdisac:"informix".sac_chequesrevwu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt >= dFechaIni
							AND fech_alt <= dFechaFin
							AND cancelad = 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo)
							AND referencia = 'REV';	
							LET sCont = sCont + 1;
							
							----Insertamos en las tablas pagadas
							INSERT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} INTO bdisac:"informix".sac_chequeswu_paso
							SELECT folio_suc, fech_alt, pUsuario
							FROM bdicheq:"informix".sc_movhis 
							WHERE cuenta = cCuentaPrestadora
							AND fech_alt >= dFechaIni
							AND fech_alt <= dFechaFin
							AND cancelad <> 'S'
							AND transacc IN (cTransaccEfec,cTransaccAbo);
							LET sCont = sCont + 1;	
							
							INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							SELECT  folio_suc,referencia1,status_cancelado, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientos
							WHERE fecha_pago= dFechaHoy
							AND numcategoria=  cCategoria
							AND numconvenio= cConvenio;
							LET sCont = sCont + 1;
							
							--Insertamos en las tablas pagadas
							INSERT INTO bdisac:"informix".sac_servicioswu_paso
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario
							FROM bdisac:"informix".sac_movimientos
							WHERE fecha_pago= dFechaHoy
							AND numconvenio= cConvenio
							AND numcategoria= cCategoria;
							LET sCont = sCont + 1;

							
							INSERT INTO bdisac:"informix".sac_serviciosrevwu_paso
							SELECT  folio_suc,referencia1,status_cancelado, fecha_pago, fecha_insert,pUsuario
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria=  cCategoria 
							AND fecha_pago >= dFechaIni
							AND fecha_pago <= dFechaFin
							AND numconvenio= cConvenio;
							LET sCont = sCont + 1;
							
							---Insertamos en las tablas pagadas
							INSERT INTO bdisac:"informix".sac_servicioswu_paso
							SELECT  folio_suc,referencia1,status_cancelado, flag_confirmacion_sucursal, fecha_pago,fecha_insert, pUsuario 
							FROM bdisac:"informix".sac_movimientoshistorial
							WHERE numcategoria= cCategoria 
							AND fecha_pago >= dFechaIni
							AND fecha_pago <= dFechaFin
							AND numconvenio=cConvenio;
							LET sCont = sCont + 1;
							IF sCont >= 5000 THEN
								COMMIT WORK;	
								LET sCont = 0;
								BEGIN WORK;
							END IF;
						END IF;
						
							INSERT INTO bdisac:"informix".sac_wucaja_paso
							SELECT mtcn, foreign_rs_refnum_rq, fecha_insert, pUsuario
							FROM bdisac:"informix".sac_wu_pay											   
							WHERE 
			--	2014.03.07 FRG-i
							fecha_insert::DATE  >= dFechaIni
							AND fecha_insert::DATE  <= dFechaFin
							and retcode = '00000'
							and mtcn in
								(select referencia1 from bdisac:sac_movimientoshistorial
								WHERE 
								fecha_pago >= dFechaIni
								AND fecha_pago <= dFechaFin
								AND numcategoria= cCategoria 
								AND numconvenio= cConvenio
								);
							--	conf_pago = 'P' 
							--	AND fecha_insert::DATE  >= dFechaIni
							--	AND fecha_insert::DATE  <= dFechaFin;
			--	2014.03.07 FRG-f				
							LET sCont = sCont + 1;
							IF sCont >= 5000 THEN
								COMMIT WORK;	
								LET sCont = 0;
								BEGIN WORK;
							END IF;
						WHILE (dFechaIni <= dFechaFin)

							SELECT COUNT(folio_suc) --SERVICIOS
							INTO iCantidadPagosServ
							FROM bdisac:"informix".sac_serviciosrevwu_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'S'
							AND usuario = pUsuario;
							
							--REALIZAMOS LA BUQUEDA PORFECHAS ANTERIORES
							SELECT COUNT(folio_suc)  --cheques
							INTO iPagosCheques
							FROM bdisac:"informix".sac_chequesrevwu_paso
							WHERE fech_alt = dFechaIni
							AND usuario = pUsuario;
								
							IF (iCantidadPagosServ = iPagosCheques)THEN
								LET cDiferencia = "Sin Diferencia";	
								
								INSERT INTO "informix".sac_wu_remesasnoconciliadas (retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES (cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								LET sCont = sCont + 1;
								IF sCont >= 5000 THEN
									COMMIT WORK;	
									LET sCont = 0;
									BEGIN WORK;
								END IF;
							ELSE
								DELETE {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} FROM bdisac:"informix".sac_conciliacionrevwu_paso WHERE usuario = pUsuario;
								IF (iPagosCheques > iCantidadPagosServ) THEN
									
										INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso
										SELECT cheq.folio_suc ,mov.referencia1, pUsuario 
										FROM bdisac:"informix".sac_chequesrevwu_paso cheq, bdisac:"informix".sac_serviciosrevwu_paso mov
										WHERE cheq.fech_alt = dFechaIni
										AND  cheq.fech_alt = mov.fecha_pago
										AND  cheq.folio_suc =  mov.folio_suc
										AND cheq.usuario = pUsuario
										AND cheq.usuario = mov.usuario
										AND cheq.folio_suc NOT IN (SELECT folio_suc
															FROM bdisac:"informix".sac_serviciosrevwu_paso
															WHERE fecha_pago = dFechaIni
															AND status_cancelado = 'S'
															AND usuario = pUsuario);
															LET sCont = sCont + 1;
									IF sCont >= 5000 THEN
										COMMIT WORK;	
										LET sCont = 0;
										BEGIN WORK;
									END IF;					
								END IF;

								IF (iCantidadPagosServ > iPagosCheques) THEN
								
										INSERT INTO bdisac:"informix".sac_conciliacionrevwu_paso
										SELECT folio_suc, referencia1, pUsuario
										FROM bdisac:"informix".sac_serviciosrevwu_paso
										WHERE fecha_pago = dFechaIni
										AND status_cancelado = 'S'
										AND usuario = pUsuario
										AND  folio_suc NOT IN(SELECT folio_suc 
															  FROM bdisac:"informix".sac_chequesrevwu_paso
															  WHERE fech_alt = dFechaIni
															  AND usuario = pUsuario)
										AND folio_suc NOT IN(SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} folio_suc 
															FROM bdisac:"informix".sac_conciliacionrevwu_paso
															WHERE usuario = pUsuario);
															LET sCont = sCont + 1;
									IF sCont >= 5000 THEN
										COMMIT WORK;	
										LET sCont = 0;
										BEGIN WORK;
									END IF;								
								END IF; 					    

								FOREACH 
								
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} DISTINCT(referencia) 
									INTO cReferencia
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE usuario = pUsuario
									
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} COUNT(referencia)
									INTO iSumaServicios 
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE referencia = cReferencia
									AND usuario = pUsuario; 
									
									SELECT {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} COUNT(referencia)
									INTO iCountServicios 
									FROM bdisac:"informix".sac_conciliacionrevwu_paso
									WHERE usuario = pUsuario; 	 
									
									IF iSumaServicios > 1 THEN 
										LET iCount = iCount + iSumaServicios ;
									ELSE 
										LET iCount = iCount + 1;
									END IF;						
										
									  SELECT MAX(fecha_insert) 
									  INTO dFechaMaxima 
									  FROM bdisac:"informix".sac_servicioswu_paso 
									  WHERE fecha_pago = dFechaIni
									  AND referencia1 = cReferencia
									  AND usuario = pUsuario;
										
										--IF EXISTS (SELECT folio_suc FROM bdisac:"informix".sac_servicioswu_paso WHERE fecha_insert = dFechaMaxima AND status_cancelado = 'N' AND referencia1 = cReferencia AND usuario = pUsuario) THEN --
										SELECT folio_suc,count(*) 
										into iFolio_suc_serv,countFolios 
										FROM bdisac:"informix".sac_servicioswu_paso 
										WHERE fecha_insert = dFechaMaxima 
										AND status_cancelado = 'N' 
										AND referencia1 = cReferencia 
										AND usuario = pUsuario group by folio_suc;
										
										IF NVL(iFolio_suc_serv,"") <> "" and countFolios > 0 THEN	
											SELECT folio_suc 
											INTO cFolioSucServicios
											FROM bdisac:"informix".sac_servicioswu_paso
											WHERE fecha_insert = dFechaMaxima 
											AND status_cancelado = 'N'
											AND fecha_insert = dFechaMaxima
											AND referencia1 = cReferencia
											AND usuario = pUsuario;
											
											--IF EXISTS(SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} folio_suc FROM bdisac:"informix".sac_chequeswu_paso  WHERE folio_suc = cFolioSucServicios AND fech_alt = dFechaIni AND usuario = pUsuario) THEN 
											SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} folio_suc, count(*)
											into iFolio_suc,countFoliosSuc
											FROM bdisac:"informix".sac_chequeswu_paso  
											WHERE fech_alt = dFechaIni 
											AND folio_suc = cFolioSucServicios
											AND usuario = pUsuario group by folio_suc;	
											
											IF NVL(iFolio_suc,"") <> "" and countFoliosSuc > 0 THEN
													--IF EXISTS (SELECT foreign_rs_refnum_rq,mtcn FROM bdisac:"informix".sac_wucaja_paso WHERE foreign_rs_refnum_rq= cFolioSucServicios AND mtcn = cReferencia AND usuario = pUsuario)THEN 
													SELECT foreign_rs_refnum_rq,mtcn 
													into foreignA,mt_cn 
													FROM bdisac:"informix".sac_wucaja_paso 
													WHERE foreign_rs_refnum_rq= cFolioSucServicios 
													AND mtcn = cReferencia 
													AND usuario = pUsuario;	
													
													IF NVL(foreignA,"") <> "" THEN
														LET cExiste = "SI";
													ELSE 
														LET cExiste = "NO";	
														
													END IF;
											END IF;	
										END IF;
									
									IF cExiste = "NO" THEN 
									
										IF iSumaServicios > 1 THEN 
											LET cDiferencia = cReferencia || "(" || iSumaServicios||")";	
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								 
										ELSE 
											LET cDiferencia = cReferencia;
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								 
										END IF;
										
									ELIF  cExiste = "SI" AND iCount = iCountServicios AND cDiferencia = "Sin Diferencia" THEN 
											INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
																																								
											VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iPagosCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								
									END IF;
									
									LET cFolioSucServicios = "";							
									LET cExiste = "NO";
									LET cReferencia = "";
									LET iSumaServicios =0;
									
					  
						
					 
				
								END FOREACH;
							
					 
					   
					
			   
		
							END IF;
							
							--AUMENTAMOS UN DIA EN LA dFechaIni
							LET iSumaServicios = 0;
							LET iCantidadPagosServ = 0;
							LET iPagosCheques =0;
							LET iServicios = 0;
							LET iCount = 0;
							LET iCountServicios =0;
							LET cDiferencia = "Sin Diferencia";
							
							LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;
							
					
					  
				   
			  
						END WHILE;
					END FOREACH;
					IF sCont < 5000 THEN
						COMMIT WORK;
						LET sCont = 0;
					END IF;		
					--Remesas NO Conciliadas PAGADAS
					BEGIN WORK;
					FOREACH
						select numcategoria, numconvenio
						into cCategoria, cConvenio
						from bdisac:"informix".sac_convenios
						where numcategoria || numconvenio in ('07006','07007','07008')
						
						DELETE FROM bdisac:"informix".sac_chequeswu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_servicioswu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_conciliacionwu_paso WHERE usuario = pUsuario;
						DELETE FROM bdisac:"informix".sac_wucaja_paso WHERE usuario = pUsuario;
			
						SELECT trans_cen_efectivo_cliente, trans_cen_cargo_cliente
						INTO cTransaccEfec, cTransaccAbo
						FROM bdisac:"informix".sac_convenios
						WHERE numcategoria= cCategoria 
						AND numconvenio= cConvenio;
						
						--Tomamos los valores de las fecha de los parametros
						LET dFechaIni = pFecha_Inicio;
						LET dFechaFin = pFecha_Fin;
						
						LET cRev					='0';
						
						insert into bdisac:"informix".sac_servicioswu_paso
						select folio_suc,referencia1,status_cancelado,flag_confirmacion_sucursal,fecha_pago,fecha_insert,pUsuario
						from bdisac:"informix".sac_movimientoshistorial 
						where fecha_pago >= dFechaIni
					    and fecha_pago <= dFechaFin
						and numcategoria = cCategoria
						and numconvenio = cConvenio;
						LET sCont = sCont + 1;		
						
						INSERT {+INDEX("informix".sac_servicioswu_paso idx_tmpservicioswu1)} INTO bdisac:"informix".sac_chequeswu_paso
						select a.folio_suc,a.fech_alt,pUsuario 
						from bdicheq:"informix".sc_movhis a,bdisac:"informix".sac_servicioswu_paso b
						where empresa = '001'
						and fech_alt >= dFechaIni
						and fech_alt <= dFechaFin
						and transacc in (cTransaccEfec,cTransaccAbo)
						and cancelad <> 'S'
						and a.folio_suc = b.folio_suc
						and a.fech_alt = b.fecha_pago
						and b.usuario = pUsuario;	
						LET sCont = sCont + 1;		
						 
						INSERT {+INDEX("informix".sac_servicioswu_paso idx_tmpservicioswu1)} INTO bdisac:"informix".sac_chequeswu_paso
						select a.folio_suc,a.fech_alt,pUsuario 
						from bdicheq:"informix".sc_movhis_old a,bdisac:"informix".sac_servicioswu_paso b
						where empresa = '001'
						and fech_alt >= dFechaIni
						and fech_alt <= dFechaFin
																													   
						and transacc in (cTransaccEfec,cTransaccAbo)
						and cancelad <> 'S'
						and a.folio_suc = b.folio_suc
						and a.fech_alt = b.fecha_pago
						and b.usuario = pUsuario;
						LET sCont = sCont + 1;	
						  
						insert {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} into bdisac:"informix".sac_conciliacionwu_paso
						select a.folio_suc, a.referencia1, pUsuario
						from bdisac:"informix".sac_movimientoshistorial a, bdisac:"informix".sac_chequeswu_paso b				
						where a.numcategoria = cCategoria
						and a.numconvenio = cConvenio
						and a.folio_suc = b.folio_suc																												
						and a.fecha_pago = b.fech_alt																						 
						and b.usuario = pUsuario;
						LET sCont = sCont + 1;	
						   
						insert {+INDEX("informix".sac_conciliacionwu_paso idx_conciliacionwu)} into bdisac:"informix".sac_wucaja_paso
						select mtcn,foreign_rs_refnum_rq,fecha_insert,pUsuario
						from bdisac:"informix".sac_wu_pay, bdisac:"informix".sac_conciliacionwu_paso
					    where referencia = mtcn
					    and fecha_insert::date >= dFechaIni
					    and fecha_insert::date <= dFechaFin
					    and conf_pago='P' 
					    and retcode = '00000'
					    and usuario = pUsuario;
						LET sCont = sCont + 1;	
						IF sCont >= 5000 THEN
							COMMIT WORK;	
							LET sCont = 0;
							BEGIN WORK;
						END IF;		
						 WHILE (dFechaIni <= dFechaFin)
						 
							SELECT COUNT(folio_suc) --SERVICIOS
							INTO iCantidadPagosServ
							FROM bdisac:"informix".sac_servicioswu_paso
							WHERE fecha_pago = dFechaIni
							AND status_cancelado = 'N'
							--AND flag_confirmacion_sucursal <> 0
							AND usuario = pUsuario;
				
							SELECT {+INDEX("informix".sac_chequeswu_paso idx_tmpchequeswu)} COUNT(folio_suc) --CHEQUES
							INTO iCantidadCheques
							FROM bdisac:"informix".sac_chequeswu_paso
							WHERE fech_alt = dFechaIni
							AND usuario = pUsuario;
							
							SELECT COUNT(mtcn)  --PAGOS
							INTO iCantidadPagosPAY
							FROM bdisac:"informix".sac_wucaja_paso
							WHERE fecha_insert::DATE = dFechaIni
							AND usuario = pUsuario;

							IF iCantidadPagosServ = iCantidadCheques AND iCantidadPagosPAY = iCantidadPagosServ THEN
								LET cDiferencia = "Sin Diferencia";
								
								INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								LET sCont = sCont + 1;
								IF sCont >= 5000 THEN
									COMMIT WORK;	
									LET sCont = 0;
									BEGIN WORK;
								END IF;		
							ELSE					
								 FOREACH							 
									select referencia 
									into cReferencia
									from bdisac:"informix".sac_conciliacionwu_paso
									where referencia not in (select a.mtcn
					
															 from bdisac:"informix".sac_wu_pay a
														   	where a.fecha_insert::date >= dFechaIni
															and a.fecha_insert::date <= dFechaFin
															and a.conf_pago='P' 
															and a.retcode = '00000'
															and a.mtcn IN (SELECT referencia FROM bdisac:"informix".sac_conciliacionwu_paso WHERE referencia = a.mtcn)
															and pUsuario IN (SELECT usuario FROM bdisac:"informix".sac_conciliacionwu_paso WHERE usuario = pUsuario))
									and usuario = pUsuario

									LET cDiferencia = cReferencia;
										INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
										VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
								END FOREACH;
		
							END IF;
							
							IF cDiferencia = "" THEN
								INSERT INTO "informix".sac_wu_remesasnoconciliadas(retcodigoret,retfecha,retservicios,retcheques,retwucaja,retdiferencia,numcategoria,numconvenio,rev)
								VALUES(cCodRet,dFechaIni,iCantidadPagosServ,iCantidadCheques,iCantidadPagosPAY,cDiferencia,cCategoria,cConvenio,cRev);
							  
							END IF;
							
							--AUMENTAMOS UN DIA EN LA dFechaIni
							LET iCantidadPagosServ = 0;
							LET iCantidadPagosPAY = 0;
							LET iCantidadCheques =0;
							LET cDiferencia = "";
							
							LET dFechaIni = dFechaIni + INTERVAL(1) DAY TO DAY;	
						END WHILE;
					END FOREACH;
				END IF;
			END IF;	
			IF sCont > 0 AND sCont < 5000 THEN
				COMMIT WORK;
				LET sCont = 0;
			END IF;		
			--ACTUALIZA EN BITACORA
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_RNC_WU', pFecha_Fin, '1', 'informix', 'sp_sac_insertaremesasnoconciliadaswu', cDescripcionSPJ);				
			
			UPDATE STATISTICS MEDIUM FOR TABLE "informix".sac_wu_remesasnoconciliadas;
			RETURN cCodRet, cMensaje;			
			
		END 
		
		DELETE FROM bdisac:"informix".sac_chequesrevwu_paso WHERE usuario = pUsuario;
		DELETE FROM  bdisac:"informix".sac_serviciosrevwu_paso WHERE usuario = pUsuario;
		DELETE {+INDEX("informix".sac_conciliacionrevwu_paso idx_conciliacionrevwu)} FROM bdisac:"informix".sac_conciliacionrevwu_paso WHERE usuario = pUsuario; 
		
		DELETE FROM bdisac:"informix".sac_chequeswu_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_servicioswu_paso WHERE usuario = pUsuario;
		DELETE FROM bdisac:"informix".sac_wucaja_paso WHERE usuario = pUsuario;
		
END PROCEDURE 
DOCUMENT
'DESCRIPCION: Se crea procedimiento para obtener los totales para las transacciones REVERSADAS de Servicio,Cheques',
'para el reporte de remesas no conciliadas WU, asu ves mostrar las diferencias si existen entre',
'cada una de las sumatorias',
'AUTOR :Eduardo Lopez Cuevas',
'FECHA : 2013/07/05',
'Ver.  : 20130705.0938',
'BD    : bdisac';

CREATE PROCEDURE  "informix".sp_calculadvdish(pNumReferencia CHAR(14))
RETURNING 
	CHAR (5) AS CodigoRetorno,
	SMALLINT AS IerrcomCodigo,
	SMALLINT AS IerrcomSistema;
	
--DEFINICION DE LAS VARIABLES
DEFINE iSqlErr			 INTEGER;
DEFINE sI 		    	 SMALLINT;
DEFINE iNoPeso      	 INTEGER;
DEFINE iValorDigito 	 INTEGER;  
DEFINE iSuma			 INTEGER;
DEFINE iAux				 INTEGER;
DEFINE cCodRet			 CHAR(5); --SE CAMBIO DE INTEGER A CHAR.
DEFINE cNum1			 CHAR(2);
DEFINE cNum2			 CHAR(2);
DEFINE cNum3			 CHAR(2);
DEFINE cNum4			 CHAR(2);
DEFINE iDigVerCapturado  INTEGER;
DEFINE iDigVerCalculado  INTEGER;
DEFINE sFijo			 SMALLINT;
DEFINE iResiduo			 INTEGER;
DEFINE sIerrcomCodigo	 SMALLINT;
DEFINE sIerrcomSistema	 SMALLINT;
DEFINE iSumaReferencia   INTEGER;
DEFINE referenciaDish 	 CHAR(13);

--INICIALIZACION DE LAS VARIABLES
LET cCodRet        	 = '00004';
LET iSqlErr        	 = 0;
LET sI 		    	 = 0;	
LET iNoPeso      	 = 60;
LET iValorDigito 	 = 0;
LET iSuma			 = 0;
LET iAux			 = 0;	
LET iDigVerCapturado = 0;
LET iDigVerCalculado = 0;
LET sFijo			 = 24;
LET iResiduo		 = 0;
LET sIerrcomCodigo   = 0;
LET sIerrcomSistema  = 0;
LET iSumaReferencia	 = 0;
LET referenciaDish	 = '';


BEGIN

	ON EXCEPTION SET iSqlErr
		   IF (iSqlErr != 0) THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;
		   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_calculadvdish.out';
	--TRACE ON;		
	
	SET ISOLATION TO DIRTY READ;

	IF LENGTH(TRIM(pNumReferencia))= 14 THEN
		
		LET cNum1 = substr(pNumReferencia,11,1);
		LET cNum2 = substr(pNumReferencia,12,1);
		LET cNum3 = substr(pNumReferencia,13,1);
		LET cNum4 = substr(pNumReferencia,14,1);

		LET iSumaReferencia = (cNum1::SMALLINT) + (cNum2::SMALLINT) + (cNum3::SMALLINT) + (cNum4::SMALLINT);

		IF iSumaReferencia = 0 THEN
			LET cCodRet = '00000';
		ELSE
			LET referenciaDish = substr(pNumReferencia,2,14);
			LET sFijo = SUBSTR(referenciaDish, 1, 2)::SMALLINT;		
			--		IF sFijo = 21 THEN
		
			LET iDigVerCapturado = SUBSTR(referenciaDish,13,1)::SMALLINT;
				FOR sI = 1 TO 12 
	
					LET iValorDigito = SUBSTR(referenciaDish,sI,1)::SMALLINT;

					IF MOD(sI,2)= 1 THEN
						LET iNoPeso = 1;
					ELSE
						LET iNoPeso = 2;
					END IF;
				
					LET iAux = iValorDigito * iNoPeso;
					   
					IF iAux > 9 THEN
						--raise notice ''Multiplicacion Mayor a 9 = %'', iAux ;
						LET cNum1 = SUBSTR(iAux::CHAR(2),1,1) ;
						LET cNum2 = SUBSTR(iAux::CHAR(2),2,1) ;
						LET iAux = (cNum1::SMALLINT) + (cNum2::SMALLINT);
					END IF; 
									
					LET iSuma = iSuma + iAux;		
					
				END FOR;
								
				LET iResiduo = MOD(iSuma , 10);

				IF iResiduo > 0 THEN
					
					LET iValorDigito = 10 - iResiduo;
					
					IF iValorDigito =  iDigVerCapturado THEN
						LET cCodRet = '00000';						
					ELSE
						LET cCodRet = '00001';
						LET sIerrcomCodigo = 91;
						LET sIerrcomSistema = 24;
					END IF;
				ELSE
					IF iResiduo =  iDigVerCapturado THEN
						LET cCodRet = '00000';
					ELSE
						LET cCodRet = '00001';
						LET sIerrcomCodigo = 91;
						LET sIerrcomSistema = 24;
					END IF;
				
				END IF;
		END IF;		
	ELSE	
	--ESCENARIO: LONGITUD DE REFERENCIA INCORRECTA.
		LET cCodRet 		= '00002';
		LET sIerrcomCodigo  = 47;
		LET sIerrcomSistema = 24;

	END IF;

	RETURN cCodRet, sIerrcomCodigo, sIerrcomSistema;

END;
END PROCEDURE
DOCUMENT
'-------------------------------------------------------------------------------------------------------------',
'DESCRIPCION: Se convierte una funcion de sucursal a una rutina de central, atendiendo el folio 1483-MttoValRefPagServAVON', 
'(procedimiento en central para validar el digito verificador para pago de servicios Dish)',
'MODIFICO: Antonio Cebreros Perez',
'FECHA: 24/02/2015',
'Cambio para aceptar referencias de 14 digitos',
'MODIFICO: Mario Enriquez',
'FECHA: 19/09/2019',
'BD: bdisac';

CREATE PROCEDURE "informix".sp_tramaconsulta_dish(pNumCategoria CHAR (2), pNumConvenio CHAR (3), pFolioSucursal CHAR (16), pRef1 CHAR (40), pId_Sucursal CHAR (4), pFecha_Pago DATE, pNumTrama INTEGER, pTimeStamp CHAR (10))
RETURNING CHAR (5) AS cCodRet, CHAR (21) AS cTrama;

--Variables
DEFINE cCodRet CHAR(5);
DEFINE cTrama CHAR(21);
DEFINE iSqlErr INTEGER;
DEFINE cTrans_MotorS CHAR(5); -- Trans_Motors
DEFINE cTrans_Suc CHAR(4);
DEFINE cTrans_Central CHAR(5);
DEFINE cTrans_Interact CHAR(5);
DEFINE cTienda CHAR(2);
DEFINE cNum_Sucursal CHAR (4);
DEFINE cReferencia CHAR(14);
DEFINE cUser_Insert CHAR(10);

LET cCodRet		= '00000';
LET iSqlErr		= 0;
LET cTrama		= '';
LET cTrans_MotorS	= '';	
LET cTrans_Suc = '';
LET cTrans_Central = '';
LET cTrans_Interact = '';
LET cTienda = '1';
LET cNum_Sucursal = pId_Sucursal;
LET cReferencia = TRIM(pRef1);
LET cUser_Insert = 'Informix';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_tramaconsultadish.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, NVL(cTrama, '');
		END IF;
	END EXCEPTION;

	IF NVL(pFecha_Pago, '') = '' OR NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL (pRef1, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; --DATOS VACIOS, ERROR.
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
	--Obtenemos la codigo del interac requeridos  de bdisac:"informix".sac_intrfz_serv
	SELECT trans_interact, trans_servicio INTO  cTrans_Interact, cTrans_MotorS FROM   bdisac: "informix".sac_intrfz_serv WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND num_trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Interact= '' Or cTrans_MotorS= '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;
		
		--Obtenemos los parametros de la sac_param para la generacion de la trama
	SELECT TRIM(valor) INTO cTienda FROM  bdisac:"informix".sac_param  where cod_param = 060021;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTienda = ''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '');
	END IF;				
		
	LET cTienda = RPAD(cTienda,2,' ');

	--Agrupa los datos para la generacion de la trama
	LET cTrama = cTrans_MotorS||cReferencia||cTienda;
	
	SELECT trans_suc_efectivo, trans_cen_efectivo_cliente INTO cTrans_Suc, cTrans_Central FROM   bdisac: "informix".sac_convenios WHERE  numcategoria = pNumCategoria AND numconvenio = pNumConvenio;
	IF DBINFO("sqlca.sqlerrd2") = 0 Or cTrans_Suc= '' Or  cTrans_Central=''THEN
		LET cCodRet = '00001';
		RETURN cCodRet, NVL(cTrama, '0');
	END IF;
	
	INSERT INTO bdisac: "informix".sac_msw_solicitud(
		numcategoria,
		numconvenio, 
		id_sucursal, 
		trans_suc, 
		trans_central, 
		trans_interact, 
		folio_suc, 
		fecha_pago, 
		num_trama, 
		campo1, 
		campo2, 
		campo3, 
		campo4,
		campo5,campo6,campo7,campo8,campo9,campo10,campo11,campo12,campo13,campo14,
		campo15,campo16,campo17,campo18,campo19,campo20,campo21,campo22,campo23,campo24,
		campo25,campo26,campo27,campo28,campo29,campo30,campo31,campo32,campo33,campo34,
		campo35,campo36,campo37,campo38,campo39,campo40,
		user_insert,
		fecha_insert) 
		VALUES (
		pNumCategoria, 
		pNumConvenio, 
		pId_Sucursal, 
		cTrans_Suc, 
		cTrans_Central, 
		cTrans_Interact, 
		pFolioSucursal, 
		pFecha_Pago,
		pNumTrama,
		cTrans_MotorS,
		cNum_Sucursal,
		cReferencia,
		cTienda,
		pTimeStamp,
		'','','','','','','','','','','',
		'','','','', '', '', '', '', '',
		'', '', '', '', '', '', '', '', '',
		'', '', '', '', '', '',
		cUser_Insert,
		current);		
	  
	RETURN cCodRet, NVL(cTrama, '');
END;
END PROCEDURE
DOCUMENT
'AUTOR : 90020599 - Mario Enriquez Gallegos',
'DESCRIPCION: SPL que recupera datos (Dish) para generar la trama de consulta y enviar a Interact.',
'FECHA : 02-10-2019',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_valida_respuesta_ws_dish(pNumCategoria CHAR   (2),  pNumConvenio CHAR (3), pId_Sucursal CHAR (4), 
		pFolioSucursal CHAR (16),  pFecha_Pago  DATE,     pNumTrama    INTEGER)
RETURNING CHAR(5) as cCodRet, CHAR(40) as cCodigoRespuesta;
      
-- Declaracion de variables 
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodigoRespuesta CHAR(40);
	DEFINE vCampoTres CHAR(40);	

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodigoRespuesta	= '';
	LET vCampoTres = '';
					
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCodigoRespuesta;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/RESPALDOSNEW/meg/sp_valida_respuesta_ws_dish.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	IF  NVL(pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL(pId_Sucursal, '') = '' OR NVL(pFolioSucursal, '') = '' OR NVL(pFecha_Pago, '') = '' OR NVL(pNumTrama, '') = '' THEN
		LET cCodRet = '00002'; 
		RETURN cCodRet, NVL(cCodigoRespuesta, '');
	END IF;

	SELECT TRIM(campo3) INTO vCampoTres FROM bdisac: "informix".sac_msw_respuesta
	WHERE numcategoria= pNumCategoria AND numconvenio = pNumConvenio AND folio_suc = pFolioSucursal AND num_trama = pNumTrama;
		  
    SELECT codigoRetorno INTO cCodigoRespuesta FROM bdisac: "informix".sac_dish_cat_respuestaws where codigoRespuesta = vCampoTres AND trama = pNumTrama;
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00001';
	ELSE 
		LET cCodRet = '00000';
	END IF;
	
	RETURN cCodRet, NVL(cCodigoRespuesta, '');
		
END;
END PROCEDURE
DOCUMENT
'AUTOR : 90020599 - Mario Enriquez Gallegos',
'DESCRIPCION: SP regresa el concepto de el codigo de respuesta a consultar de bdisac: sac_dish_cat_respuestaws',
'FECHA : 08-10-2019',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_pagos_activos_msw(pOrigen CHAR(4))
	RETURNING
	CHAR(5)	 AS codigo,	
	CHAR(30) AS mensaje,	
	CHAR(2)	 AS categoria,	
	CHAR(3)	 AS convenio,	
	CHAR(20) AS descripcion,	
	CHAR(8)	 AS fecha;

	DEFINE iSqlErr       INTEGER;
    DEFINE iIsamErr      INTEGER;
    DEFINE cInfoErr      CHAR(100);
	DEFINE cCodRet       CHAR(5);
	DEFINE cMensaje		 CHAR(30);
	DEFINE cCategoria	 CHAR(2);
	DEFINE cConvenio	 CHAR(3);
	DEFINE cDescripcion	 CHAR(20);
	DEFINE dFecha		 DATE;
	DEFINE cFechaFormat	 CHAR(8);
	DEFINE cMensaje1     CHAR(20);
	
	--SET DEBUG FILE TO  '/informix/EPG/sp_pagos_activos_msw_epg.out';
	--TRACE ON;

	LET cCodRet      = "00000";
	LET cMensaje     = "Exitoso";
	LET cCategoria   = '';
	LET cConvenio    = '';
	LET cDescripcion = '';
	LET dFecha       = '';
	LET cFechaFormat = '';
	LET cMensaje1 = '';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
				LET cMensaje = "Error";
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_pagos_activos_msw_epg");
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, cFechaFormat;
            END IF;
        END EXCEPTION;
		
		LET cMensaje1 = pOrigen;
		
		IF pOrigen = "" THEN
            LET cCodRet = "00100";
			LET cMensaje = "Error";
            RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;

		IF pOrigen = 'CPL' OR pOrigen = 'cpl' THEN
			FOREACH
				SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
				INTO cCategoria, cConvenio, cDescripcion, dFecha
				FROM bdisac:"informix".sac_servicios_cpl a, bdisac:"informix".sac_convenios b, bdisac:sac_controlconvenios C
				WHERE (a.numcategoria = b.numcategoria AND a.numconvenio = b.numconvenio)--nmr
                  and (a.numcategoria = c.numcategoria AND a.numconvenio = c.numconvenio)--nmr
                  AND c.status_cpl = 'A'--nmr
				ORDER BY a.numcategoria, a.numconvenio
				
				LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;
				
				RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
				WITH RESUME;
			END FOREACH;

            ELIF pOrigen = 'BCPL' OR pOrigen = 'bcpl' THEN
                FOREACH
                    SELECT a.numcategoria, a.numconvenio, TRIM(SUBSTR(b.nomconvenio,1,20)), b.fechaactualizacion
                    INTO cCategoria, cConvenio, cDescripcion, dFecha
                    FROM bdisac:"informix".sac_controlconvenios a, bdisac:"informix".sac_convenios b
                    WHERE a.estatus = 'A'
                    AND a.numcategoria = b.numcategoria
                    AND a.numconvenio = b.numconvenio
                    AND a.status_cpl = 'A'

                    ORDER BY a.numcategoria, a.numconvenio

                    LET cFechaFormat = YEAR(dFecha) || LPAD(MONTH(dFecha),2,0) || LPAD(DAY(dFecha),2,0) ;

                    RETURN cCodRet, cMensaje, cCategoria, cConvenio, cDescripcion, cFechaFormat
                    WITH RESUME;
                END FOREACH;
			ELSE
                LET cCodRet = "00101";
                LET cMensaje = "Origen desconocido";
                RETURN cCodRet, cMensaje,  cCategoria,  cConvenio,  cDescripcion, '';
		END IF;	
		
	END;
END PROCEDURE;