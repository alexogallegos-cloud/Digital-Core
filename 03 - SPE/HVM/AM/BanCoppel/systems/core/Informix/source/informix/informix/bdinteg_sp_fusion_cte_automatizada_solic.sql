CREATE PROCEDURE "informix".sp_fusion_cte_automatizada_solic(pNumCteCorrecto CHAR(20), pNumCteIncorrecto CHAR(20), pCanal CHAR(5), pFecha DATE, pUsuario CHAR(20))
RETURNING CHAR(5) AS codretorno, CHAR(200) AS mensaje;
--Definicion de Variables
DEFINE iSqlErr				INTEGER;
DEFINE iIsamErr				INTEGER;
DEFINE cCodRet				CHAR(5);
DEFINE cErrorInfo			CHAR(200);
DEFINE cEstado				CHAR(200);

DEFINE iEstatus				INTEGER;
--DEFINE iCantResultado		INTEGER;
DEFINE iPorProcesar			INTEGER;
DEFINE iMaximoFusiones		INTEGER;
DEFINE iTipo_cte_correcto	INTEGER;
DEFINE iTipo_cte_incorrecto	INTEGER;
DEFINE iCtaTel_CC			INT;
DEFINE iCtaTel_CI			INT;
DEFINE iCtaTransfer_CC		INT;
DEFINE iCtaTransfer_CI		INT;
DEFINE iIsamErrIDE			INT;
/*DEFINE iMesActual			INTEGER;
DEFINE iMesAnterior			INTEGER;
DEFINE iAnioActual			INTEGER;
DEFINE iAnioAnterior		INTEGER;
DEFINE iProcesados			INTEGER;
DEFINE iFusionados			INTEGER;
DEFINE iNo_fusionados		INTEGER;*/

DEFINE cSexo				CHAR(1);
DEFINE cSexoCorrecto		CHAR(1);
DEFINE cSexoIncorrecto		CHAR(1);
DEFINE cEmpresa				CHAR(3);
DEFINE cStatusCte			CHAR(2);
DEFINE cSucursal			CHAR(4); 

DEFINE cCodRetSP			CHAR(5);
DEFINE cCanal				CHAR(5);
DEFINE cCod_Retorno			CHAR(5);
DEFINE cCodRetEst			CHAR(6);
--DEFINE cResultado			CHAR(6);
DEFINE cRfc					CHAR(13);
DEFINE cCte_Titular			CHAR(20);
DEFINE cCte_Traspaso		CHAR(20);
DEFINE cApellPaterno_Inc	CHAR(26); 
DEFINE cApellMaterno_Inc	CHAR(26); 
DEFINE cNombre_Inc			CHAR(26); 
DEFINE cNombre2_Inc			CHAR(26);
DEFINE cNom1CteCorrecto		CHAR(26);
DEFINE cNom2CteCorrecto		CHAR(26); 
DEFINE cApell_Pat_Correcto	CHAR(26); 
DEFINE cApell_Mat_Correcto	CHAR(26);
DEFINE cProceso_Res			CHAR(30);
DEFINE cProceso				CHAR(30);
DEFINE cMensaje				CHAR(80);
DEFINE cTraspasoIde			CHAR(100);
DEFINE cMensajeIde			CHAR(100);
DEFINE cPorcentajeDef		CHAR(100);
DEFINE cGeneros				CHAR(100);
DEFINE cUserEjecuta			CHAR(100);
DEFINE cValidaNom			CHAR(100);

DEFINE dFecha				DATE;
DEFINE dFecha_Fusion		DATE;
DEFINE dFechaAlta			DATE; 
DEFINE dFechaNac			DATE;
/*DEFINE dFechaInicial		DATE;
DEFINE dFechaFinal			DATE;
DEFINE dMaxFechaInicial		DATE;
DEFINE dMaxFechaFinal		DATE;*/
DEFINE dFechaHoy			DATE;

DEFINE dPorcentaje			DECIMAL(6,0);
DEFINE cClubCC				CHAR(20);
DEFINE cClubCI				CHAR(20);

--Inicializacion de Variables
LET iSqlErr    		    = 0;
LET iIsamErr			= 0;
LET cCodRet      	    = '00000';
LET cErrorInfo			= '';
LET cEstado = 'PROCESO DE FUSION REALIZADO SATISFACTORIAMENTE';

LET iEstatus      	    = 0;
LET iCtaTel_CC			= 0;
LET iCtaTel_CI			= 0;
--LET iCantResultado		= 0;
LET iPorProcesar		= 0;
LET iMaximoFusiones 	= 0;
LET iTipo_cte_correcto 	= 0;
LET iTipo_cte_incorrecto = 0;
LET iIsamErrIDE			= 0;
/*LET iMesActual = MONTH(CURRENT::DATE);
LET iAnioActual = YEAR(CURRENT::DATE);
LET iProcesados			= 0;
LET iFusionados			= 0;
LET iNo_fusionados		= 0;*/

LET cSexo         	    = '';
LET cSexoCorrecto       = '';
LET cSexoIncorrecto     = '';
LET cEmpresa            = '';
LET cStatusCte    	    = '';
LET cSucursal     	    = '';
LET cCodRetSP    	    = '00000';
LET cCanal        	    = '';
LET cCod_Retorno 	    = '';
LET cRfc        	    = '';
LET cCte_Titular 	    = '';
LET cCte_Traspaso 	    = '';
LET cApellPaterno_Inc   = '';
LET cApellMaterno_Inc   = '';
LET cNombre_Inc         = '';
LET cNombre2_Inc        = '';
LET cNom1CteCorrecto    = '';
LET cNom2CteCorrecto 	= ''; 
LET cApell_Pat_Correcto = ''; 
LET cApell_Mat_Correcto = '';
LET cProceso_Res        = '';
LET cProceso     	    = '';
LET cMensaje            = '';
LET cTraspasoIde        = '';
LET cPorcentajeDef      = '';
LET cGeneros            = '';
LET cUserEjecuta		= '';
LET cValidaNom    	    = '';
LET cMensajeIde			= '';

LET dFecha_Fusion 	    = DATE(1);
LET dFecha        	    = DATE(1);
LET dFechaAlta    	    = DATE(1);
LET dFechaNac     	    = DATE(1);
LET dFechaHoy			= CURRENT::DATE;
--LET dFechaHoy			= '08-01-2014';

LET dPorcentaje   	    = 0;
LET cClubCC				= '0';
LET cClubCI				= '0';
LET iCtaTransfer_CC		= 0;
LET iCtaTransfer_CI		= 0;

	--SET DEBUG FILE TO '/informix/rmarquez/sp_fusion_cte_automatizada_solic.out';
	--TRACE ON;	
BEGIN
	ON EXCEPTION
		SET iSqlErr, iIsamErr, cErrorInfo
		IF iSqlErr <> 0 THEN	
			LET cCodRet = iSqlErr;
			LET cEstado = 'OCURRIO UN ERROR DURANTE EL PROCESO DE FUSION: '||iIsamErr||', '|| TRIM(cErrorInfo);
			
			INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES('Manejo de excepciones', 'sp_fusion_cte_automatizada_solic', cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| TRIM(cEstado), CURRENT  , 'infoaut', CURRENT);
			
			RETURN cCodRet, cEstado;
		END IF;
	END EXCEPTION;
	SET LOCK MODE TO WAIT 3;
	
	IF	NVL(pFecha, '') = '' OR  NVL(pCanal, '') = '' OR  NVL(pUsuario, '') = '' THEN

		INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
		VALUES('Valida parametros entrada', 'sp_fusion_cte_automatizada_solic', pNumCteCorrecto, pNumCteIncorrecto, '00003' ||'|'|| 'Parametros incorrectos', CURRENT  , 'infoaut', CURRENT);
		
		LET cEstado = 'PROCESO NO REALIZADO, PARAMETROS DE ENTRADA INCORRECTOS, FECHA: ('||NVL(pFecha,'')||'), CANAL:('||NVL(TRIM(pCanal),'')||'),: USUARIO: ('||NVL(TRIM(pUsuario),'')||')';
	ELSE
		
		IF EXISTS(SELECT valor FROM bdinteg:si_param WHERE cod_param = '314') THEN  --Verifica si existe el parametro con el usuario correcto para realizar fusion
			
			SELECT NVL(TRIM(valor),'') INTO cUserEjecuta 
			FROM bdinteg:si_param 
			WHERE cod_param = '314';
			
			IF cUserEjecuta <> '' THEN
				IF USER = TRIM(cUserEjecuta) THEN
				
					EXECUTE PROCEDURE bdinteg:"informix".sp_valida_ejecucion_reporte_regulatorio('001','CNBV','R24B2423') INTO cCodRetSP, cProceso;
					IF cCodRetSP = '00002' THEN								
						INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
						VALUES('sp_valida_ejecucion_reporte_regulatorio', 'bdirepaut:sp_controlproceso', pNumCteCorrecto, pNumCteIncorrecto, '00007' ||'|'|| cProceso, CURRENT  , pUsuario, CURRENT);
						
						LET cEstado = 'PROCESO NO REALIZADO, SE ESTA GENERANDO REPORTE REGULATORIO';
					ELSE
						IF cCodRetSP <> '00000' THEN				
							INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
							VALUES('sp_valida_ejecucion_reporte_regulatorio', 'bdirepaut:sp_controlproceso', pNumCteCorrecto, pNumCteIncorrecto, cCodRet ||'|'|| cProceso, CURRENT  , pUsuario, CURRENT);
						END IF;				
						
						SELECT empresa
						INTO cEmpresa
						FROM bdinteg:"informix".si_empresas;
					
						IF NVL(pNumCteCorrecto, '') = '' OR  NVL(pNumCteIncorrecto, '') = '' THEN				

							SELECT COUNT(*) 
							INTO iPorProcesar
							FROM bdinteg:"informix".si_fusion_solic
							WHERE estatus = 0
							AND fecha_insert >= pFecha;
							--AND canal = pCanal;

							IF iPorProcesar > 0 THEN
								
								SELECT TRIM(valor) 
								INTO cTraspasoIde
								FROM bdinteg:"informix".si_param 
								WHERE cod_param = '150';
								
								FOREACH WITH HOLD
									SELECT cliente_tit, cliente_tras, canal, fecha_insert, estatus, cod_retorno, proceso, fecha_fusion 
									INTO cCte_Titular, cCte_Traspaso, cCanal, dFecha, iEstatus, cCod_Retorno, cProceso,dFecha_Fusion
									FROM bdinteg:"informix".si_fusion_solic
									WHERE estatus = 0
									AND fecha_insert >= pFecha
									--AND canal = pCanal
									
									--Valida que los clientes sean distintos
									IF cCte_Titular <> cCte_Traspaso THEN
									
										--Validamos que el cliente correcto exista
										IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = cCte_Titular) THEN	
											--Se valida que los Cte no esten fusionados
											EXECUTE PROCEDURE bdinteg:"informix".sp_fuscte_conscte(cCte_Traspaso)
											INTO cCodRetSP, cApellPaterno_Inc, cApellMaterno_Inc, cNombre_Inc, cNombre2_Inc, cSucursal, cRfc, cStatusCte, dFechaAlta, dFechaNac, cSexo;
									
											IF cCodRetSP = '00000' THEN										
												EXECUTE PROCEDURE bdinteg:"informix".sp_cuentadoctos(cCte_Titular, 1) 
												INTO cCodRetSP, iIsamErrIDE, cMensajeIde;
												
												IF cCodRetSP = '00000' THEN
													EXECUTE PROCEDURE bdinteg:"informix".sp_cuentadoctos(cCte_Traspaso, 2) 
													INTO cCodRetSP, iIsamErrIDE, cMensajeIde;
													
													IF cCodRetSP = '00000' OR (cCodRetSP = '00200' AND cTraspasoIde = 1) THEN
														SELECT TRIM(valor) 
														INTO cValidaNom
														FROM bdinteg:"informix".si_param 
														WHERE cod_param ='182';
												
														SELECT nombre1, nombre2, apell_paterno, apell_materno
														INTO   cNom1CteCorrecto, cNom2CteCorrecto, cApell_Pat_Correcto, cApell_Mat_Correcto
														FROM bdinteg:"informix".si_cliente
														WHERE numcte = cCte_Titular;
													
														IF cValidaNom = 1 THEN
															EXECUTE PROCEDURE bdisac:"informix".sp_validanombenefbts(cNom1CteCorrecto, cNom2CteCorrecto, cApell_Pat_Correcto, cApell_Mat_Correcto, cNombre_Inc, cNombre2_Inc, cApellPaterno_Inc, cApellMaterno_Inc)
															INTO cCodRetSP, dPorcentaje;
														
															IF cCodRetSP <> '00000' THEN
																LET cCodRet = cCodRetSP;
																LET cProceso  = 'sp_validanombenefbts';
																INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																VALUES('sp_validanombenefbts', '', pNumCteCorrecto, pNumCteIncorrecto, cCodRetSP, CURRENT  , pUsuario, CURRENT);
															ELSE
																SELECT TRIM(valor) 
																INTO cPorcentajeDef
																FROM bdinteg:"informix".si_param 
																WHERE cod_param ='138'; 
											
																IF dPorcentaje < CAST(cPorcentajeDef AS DECIMAL(6,0)) THEN 
																	LET cCodRet  = '00001';
																	LET cProceso = 'sp_validanombenefbts';
																END IF;	
															END IF;	
														END IF;
												
														IF cValidaNom = 0 OR (cCodRetSP = '00000' AND cCodRet = '00000') THEN 	
															
															LET cClubCI = '0';
															LET cClubCC = '0';
															
															IF EXISTS(SELECT NVL(numcte,'') FROM bdinteg:si_club_proteccion 
																		WHERE numcte = cCte_Titular and empresa = '001' and aceptada IS NOT NULL) THEN
																LET cClubCC = '1';
															END IF;
															
															IF EXISTS(SELECT NVL(numcte,'') FROM bdinteg:si_club_proteccion 
																		WHERE numcte = cCte_Traspaso and empresa = '001' and aceptada IS NOT NULL) THEN
																LET cClubCI = '1';
															END IF;
															--Si los dos clientes cuentan con club de proteccion, la fusion de los clientes se cancela
															IF (cClubCI <> '0' AND cClubCC <> '0') THEN
																	--Si ambos cuentan con club de protección
																	LET cCodRet = '00014';
																	LET cProceso  = 'si_club_proteccion';
																	
																	INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																	VALUES('CLUB DE PROTECCION', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CLUB DE PROTECCION', CURRENT  , pUsuario, CURRENT);
															ELSE
																LET iCtaTel_CC = 0;
																LET iCtaTel_CI = 0;
																
																SELECT 1 INTO iCtaTel_CC FROM bdicheq:sc_cuenta_telefono WHERE num_cte = cCte_Titular;
																SELECT 1 INTO iCtaTel_CI FROM bdicheq:sc_cuenta_telefono WHERE num_cte = cCte_Traspaso;
																
																IF (iCtaTel_CC + iCtaTel_CI) = 2 THEN
																	LET cCodRet = '00016';
																	LET cProceso  = 'sc_cuenta_telefono';
																	
																	INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																	VALUES('CUENTA-TELEFONO', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA-TELEFONO', CURRENT  , pUsuario, CURRENT);

																ELSE
																--TRANSFER
																	LET iCtaTransfer_CC = 0;
																	LET iCtaTransfer_CI = 0;
																	
																			
																		--SELECT 1 INTO iCtaTransfer_CC FROM bditransfer:tf_maecte WHERE numcte = cCte_Titular;
																		
																		IF EXISTS (SELECT 1 FROM bditransfer:tf_maecte WHERE numcte = cCte_Titular) THEN
																				LET iCtaTransfer_CC = 1;
																		END IF;
																				
																		--SELECT 1 INTO iCtaTransfer_CI FROM bditransfer:tf_maecte WHERE numcte = cCte_Traspaso;		
																		IF EXISTS (SELECT 1 FROM bditransfer:tf_maecte WHERE numcte = cCte_Traspaso) THEN
																				LET iCtaTransfer_CI = 1; 
																		END IF;
																		
																		
																		
																		
																						
																	IF (NVL(iCtaTransfer_CC,0) + NVL(iCtaTransfer_CI,0) = 2) THEN
																		LET cCodRet = '00017';
																		LET cProceso  = 'bditransfer:tf_maecte';
																		INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																		VALUES('CUENTA-TRANSFER', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA TRANSFER', CURRENT  , pUsuario, CURRENT);																
																	ELSE
																		EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_cap(cCte_Titular, cCte_Traspaso, pUsuario)
																		INTO cCodRetSP, cMensaje;
																		IF cCodRetSP <> '00000' THEN
																			LET cCodRet = cCodRetSP;
																			LET cProceso  = 'sp_traspasocuentas_cap';
																		ELSE								
																			EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred(cCte_Titular, cCte_Traspaso, pUsuario)
																			INTO cCodRetSP, cMensaje;
																			IF cCodRetSP <> '00000' THEN
																				LET cCodRet = cCodRetSP;
																				LET cProceso  = 'sp_traspasocuentas_cred';
																			ELSE
																				EXECUTE PROCEDURE bdinteg:"informix".sp_fustraspasotelefonos(cCte_Titular, cCte_Traspaso, pUsuario)
																				INTO cCodRetSP, cMensaje;
																				IF cCodRetSP <> '00000' THEN
																					LET cCodRet = cCodRetSP;
																					LET cProceso  = 'sp_fustraspasotelefonos';	
																				ELSE
																					
																					IF cTraspasoIde = 1 THEN
																						EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_ide(cCte_Titular, cCte_Traspaso, pUsuario)
																						INTO cCodRetSP, cMensaje; 
																					
																						IF cCodRetSP <> '00000' THEN
																							LET cCodRet = cCodRetSP;
																							LET cProceso  = 'sp_traspasocuentas_ide';
																						END IF;
																					END IF;
																				
																					IF cCodRetSP = '00000' THEN 
																						EXECUTE PROCEDURE bdinteg:"informix".sp_respalda_imagenes(cEmpresa,cCte_Titular,cCte_Traspaso)
																						INTO cCodRetSP, cProceso_Res;
																							IF cCodRetSP <> '00000' THEN
																								LET cCodRet  = cCodRetSP;
																								LET cProceso  = cProceso_Res;
																								INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																								VALUES('sp_respalda_imagenes', '', cCte_Titular, cCte_Traspaso, cCodRetSP ||'|'|| cProceso_Res, CURRENT  , pUsuario, CURRENT);
																							END IF;
																					END IF;
																				END IF;
																			END IF;			
																		END IF;
																	END IF; --TRANSFER	
																END IF;													
															END IF; --si_club_proteccion
														END	IF;
													ELSE
														LET cCodRet = cCodRetSP;
														LET cProceso  = 'sp_cuentadoctos 2';
													END IF; --Validacion sp_cuentadoctos 1
												ELSE
													LET cCodRet = cCodRetSP;
													LET cProceso  = 'sp_cuentadoctos 1';
												END IF; --Validacion sp_cuentadoctos 1
											ELSE
												LET cCodRet = cCodRetSP;
												LET cProceso  = 'sp_fuscte_conscte';
											END IF;
											
											IF cCodRet = '00000' THEN
												UPDATE bdinteg:"informix".si_fusion_solic 
												SET estatus = 1, cod_retorno = '00000', proceso = 'CLIENTE FUSIONADO', fecha_fusion = CURRENT, fecha_proceso = dFechaHoy
												WHERE cliente_tit = cCte_Titular 
													AND cliente_tras = cCte_Traspaso 
													AND canal = cCanal
													AND fecha_insert = dFecha
													AND estatus = 0;
												
												DELETE bdinteg:"informix".si_cliente 
													WHERE numcte = cCte_Traspaso;
													
												DELETE bdinteg:"informix".si_ctepf 
													WHERE numcte = cCte_Traspaso;
											ELSE
												UPDATE bdinteg:"informix".si_fusion_solic 
												SET cod_retorno = cCodRet, proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy 
												WHERE cliente_tit = cCte_Titular 
													AND cliente_tras = cCte_Traspaso
													AND canal = cCanal
													AND fecha_insert = dFecha
													AND estatus = 0;
												
												LET cCodRet = '00000';
											END IF;
										ELSE	
											--Aqui retorno por que no existe el cliente titular
											LET cProceso = 'CLIENTE TITULAR NO EXISTE';
											UPDATE bdinteg:"informix".si_fusion_solic 
											SET cod_retorno = '00013', proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy 
											WHERE cliente_tit = cCte_Titular 
												AND cliente_tras = cCte_Traspaso 
												AND canal = cCanal
												AND fecha_insert = dFecha
												AND estatus = 0;

											INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
											VALUES('Validacion cliente correcto', 'sp_fusion_cte_automatizada_solic', cCte_Titular, cCte_Traspaso, '00013'||'|'||cProceso, CURRENT  , pUsuario, CURRENT);
										END IF;
									ELSE
										LET cProceso = 'FUSION OMITIDA: MISMOS CLIENTES';
										UPDATE bdinteg:"informix".si_fusionaut 
										SET cod_retorno = '00015', proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy::DATE 
										WHERE cliente_tit = cCte_Titular 
											AND cliente_tras = cCte_Traspaso
											AND canal = cCanal
											AND fecha_insert = dFecha
											AND estatus = 0;

										INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
										VALUES('Validacion de numeros de cliente', 'sp_fusion_cte_automatizada', cCte_Titular, cCte_Traspaso, '00015'||'|'||cProceso, CURRENT  , pUsuario, CURRENT);
									END IF;
								END FOREACH;
								
								--GENERACION DE ESTADISTICA GENERAL DE FUSIONES
								EXECUTE PROCEDURE "informix".sp_get_estadisticafusion('0', '' , dFechaHoy, '', pFecha, pUsuario) 
								INTO cCodRetEst;
								
								IF cCodRetEst::INTEGER <> 0 THEN
									INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
									VALUES('Estadistica fusion', 'sp_get_estadisticafusion', pNumCteCorrecto, pNumCteIncorrecto, cCodRetEst||'|'|| 'ERROR AL CALCULAR ESTADISTICA', CURRENT  , pUsuario, CURRENT);
								END IF;
								
							ELSE
							
								INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
								VALUES('Instrucciones de fusion por procesar', 'sp_fusion_cte_automatizada_solic', pNumCteCorrecto, pNumCteIncorrecto, '00009' ||'|'||iPorProcesar ||':Instruciones por procesar', CURRENT, pUsuario, CURRENT);
								
								LET cEstado = 'PROCESO NO REALIZADO, NO EXISTEN FUSIONES POR PROCESAR';

							END IF;
							
						ELSE  --Busqueda solo para clientes especificos
							SELECT cliente_tit, cliente_tras, canal, fecha_insert, estatus, cod_retorno, proceso, fecha_fusion 
							INTO cCte_Titular, cCte_Traspaso, cCanal, dFecha, iEstatus, cCod_Retorno, cProceso,dFecha_Fusion
							FROM bdinteg:"informix".si_fusion_solic
							WHERE estatus = 0
							AND fecha_insert >= pFecha
							AND canal = pCanal
							AND cliente_tit = pNumCteCorrecto 
							AND cliente_tras = pNumCteIncorrecto;
							
							--Se valida que ambos clientes sean distintos
							IF cCte_Titular <> cCte_Traspaso THEN
								IF NVL(cCte_Titular, '' ) <> '' THEN
									--Aqui consultamos los tipo de clientes
									IF EXISTS(SELECT numcte FROM bdinteg:si_cliente WHERE numcte = cCte_Titular) THEN	

										EXECUTE PROCEDURE bdinteg:"informix".sp_fuscte_conscte(cCte_Traspaso)
										INTO cCodRetSP, cApellPaterno_Inc, cApellMaterno_Inc, cNombre_Inc, cNombre2_Inc, cSucursal, cRFC, cStatusCte, dFechaAlta, dFechaNac, cSexo;

										IF cCodRetSP = '00000' THEN		
											SELECT TRIM(valor) 
											INTO cValidaNom
											FROM bdinteg:"informix".si_param 
											WHERE cod_param ='182';
									
											SELECT nombre1, nombre2, apell_paterno, apell_materno
											INTO   cNom1CteCorrecto, cNom2CteCorrecto, cApell_Pat_Correcto, cApell_Mat_Correcto
											FROM bdinteg:"informix".si_cliente
											WHERE numcte = cCte_Titular;
										
											IF cValidaNom = 1 THEN
												EXECUTE PROCEDURE bdisac:"informix".sp_validanombenefbts(cNom1CteCorrecto, cNom2CteCorrecto, cApell_Pat_Correcto, cApell_Mat_Correcto, cNombre_Inc, cNombre2_Inc, cApellPaterno_Inc, cApellMaterno_Inc)
												INTO cCodRetSP, dPorcentaje;
											
												IF cCodRetSP <> '00000' THEN
													LET cCodRet = cCodRetSP;
													LET cProceso  = 'sp_validanombenefbts';	
													INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
													VALUES('sp_validanombenefbts', '', cNom1CteCorrecto, cNom2CteCorrecto, cCodRetSP, CURRENT  , pUsuario, CURRENT);
												ELSE
													SELECT TRIM(valor) 
													INTO cPorcentajeDef
													FROM bdinteg:"informix".si_param 
													WHERE cod_param ='138'; 
								
													IF dPorcentaje < CAST(cPorcentajeDef AS DECIMAL(6,0)) THEN 
														LET cCodRet  = '00001';
														LET cProceso = 'sp_validanombenefbts';
													END IF;	
												END IF;	
											END IF;
									
											IF cValidaNom = 0 OR (cCodRetSP = '00000' AND cCodRet = '00000') THEN 	
												LET cClubCI = '0';
												LET cClubCC = '0';
												
												IF EXISTS(SELECT NVL(numcte,'') FROM bdinteg:si_club_proteccion 
															WHERE numcte = cCte_Titular and empresa = '001' and aceptada IS NOT NULL) THEN
													LET cClubCC = '1';
												END IF;
												
												IF EXISTS(SELECT NVL(numcte,'') FROM bdinteg:si_club_proteccion 
															WHERE numcte = cCte_Traspaso and empresa = '001' and aceptada IS NOT NULL) THEN
													LET cClubCI = '1';
												END IF;
												--Si los dos clientes cuentan con club de proteccion, la fusion de los clientes se cancela
												IF (cClubCI <> '0' AND cClubCC <> '0') THEN
													--Si ambos cuentan con club de protección
													LET cCodRet = '00014';
													LET cProceso  = 'si_club_proteccion';
													LET cEstado = 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CLUB DE PROTECCION';	
													
													INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
													VALUES('CLUB DE PROTECCION', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CLUB DE PROTECCION', CURRENT  , pUsuario, CURRENT);
												ELSE
													LET iCtaTel_CC = 0;
													LET iCtaTel_CI = 0;
													
													SELECT 1 INTO iCtaTel_CC FROM bdicheq:sc_cuenta_telefono WHERE num_cte = cCte_Titular;
													SELECT 1 INTO iCtaTel_CI FROM bdicheq:sc_cuenta_telefono WHERE num_cte = cCte_Traspaso;
													
													IF (iCtaTel_CC + iCtaTel_CI) = 2 THEN
														LET cCodRet = '00016';
														LET cProceso  = 'sc_cuenta_telefono';
														LET cEstado = 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA-TELEFONO';
														
														INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
														VALUES('CUENTA-TELEFONO', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA-TELEFONO', CURRENT  , pUsuario, CURRENT);
													ELSE
														--TRANSFER
														LET iCtaTransfer_CC = 0;
														LET iCtaTransfer_CI = 0;
																	
														--SELECT 1 INTO iCtaTransfer_CC FROM bditransfer:tf_maecte WHERE numcte = cCte_Titular;
														
														IF EXISTS (SELECT 1 FROM bditransfer:tf_maecte WHERE numcte = cCte_Titular) THEN
															LET iCtaTransfer_CC = 1;
														END IF;
																								
														IF EXISTS (SELECT 1 FROM bditransfer:tf_maecte WHERE numcte = cCte_Traspaso) THEN
															LET iCtaTransfer_CI = 1; 
														END IF;
														
														--SELECT 1 INTO iCtaTransfer_CI FROM bditransfer:tf_maecte WHERE numcte = cCte_Traspaso;
																	
														IF (NVL(iCtaTransfer_CC,0) + NVL(iCtaTransfer_CI,0) = 2 ) THEN
															LET cCodRet = '00017';
															LET cProceso  = 'bditransfer:tf_maecte';
															LET cEstado = 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA TRANSFER';
															
															INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
															VALUES('CUENTA TRANSFER', cProceso, cCte_Titular, cCte_Traspaso, cCodRet ||'|'|| 'PROCESO NO REALIZADO, AMBOS CLIENTES TIENEN CUENTA TRANSFER', CURRENT  , pUsuario, CURRENT);

														ELSE													
															EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_cap(cCte_Titular, cCte_Traspaso, pUsuario)
															INTO cCodRetSP, cMensaje;
															IF cCodRetSP <> '00000' THEN
																LET cCodRet = cCodRetSP;
																LET cProceso  = 'sp_traspasocuentas_cap';
															ELSE								
																EXECUTE PROCEDURE bdicred:"informix".sp_traspasocuentas_cred(cCte_Titular, cCte_Traspaso, pUsuario)
																INTO cCodRetSP, cMensaje;
																IF cCodRetSP <> '00000' THEN
																	LET cCodRet = cCodRetSP;
																	LET cProceso  = 'sp_traspasocuentas_cred';									
																ELSE
																	EXECUTE PROCEDURE bdinteg:"informix".sp_fustraspasotelefonos(cCte_Titular, cCte_Traspaso, pUsuario)
																	INTO cCodRetSP, cMensaje;
																	IF cCodRetSP <> '00000' THEN
																		LET cCodRet = cCodRetSP;
																		LET cProceso  = 'sp_fustraspasotelefonos';										
																	ELSE
																		SELECT TRIM(valor) 
																		INTO cTraspasoIde
																		FROM bdinteg:"informix".si_param 
																		WHERE cod_param = '150';
									
																		IF cTraspasoIde = 1 THEN
																			EXECUTE PROCEDURE bdinteg:"informix".sp_traspasocuentas_ide(cCte_Titular, cCte_Traspaso, pUsuario)
																			INTO cCodRetSP, cMensaje; 
																		
																			IF cCodRetSP <> '00000' THEN
																				LET cCodRet = cCodRetSP;
																				LET cProceso  = 'sp_traspasocuentas_ide';												
																			END IF;
																		END IF;
																	
																		IF cCodRetSP = '00000' THEN 
																			EXECUTE PROCEDURE bdinteg:"informix".sp_respalda_imagenes(cEmpresa,cCte_Titular,cCte_Traspaso)
																			INTO cCodRetSP, cProceso_Res;
																			IF cCodRetSP <> '00000' THEN
																				LET cCodRet  = cCodRetSP;
																				LET cProceso  = cProceso_Res;
																				INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
																				VALUES('sp_respalda_imagenes', '', cCte_Titular, cCte_Traspaso, cCodRetSP ||'|'|| cProceso_Res, CURRENT  , pUsuario, CURRENT);
																			END IF;
																		END IF;
																	END IF;
																END IF;			
															END IF;
														END IF; --TRANSFER	
													END IF; --sc_cuenta_telefono
												END IF; --Club de proteccion
											END	IF;
										ELSE
											LET cCodRet = cCodRetSP;
											LET cProceso  = 'sp_fuscte_conscte';
										END IF;
								
										IF cCodRet = '00000' THEN
											UPDATE bdinteg:"informix".si_fusion_solic 
											SET estatus = 1, cod_retorno = '00000', proceso = 'CLIENTE FUSIONADO', fecha_fusion = CURRENT, fecha_proceso = dFechaHoy 
											WHERE cliente_tit = cCte_Titular 
												AND cliente_tras = cCte_Traspaso 
												AND canal = cCanal
												AND fecha_insert = dFecha
												AND estatus = 0;
												
											DELETE bdinteg:"informix".si_cliente 
												WHERE numcte = cCte_Traspaso;
											
											DELETE bdinteg:"informix".si_ctepf 
												WHERE numcte = cCte_Traspaso;
											
											--LET iFusionados = iFusionados + 1;
										ELSE
											UPDATE bdinteg:"informix".si_fusion_solic 
											SET cod_retorno = cCodRet, proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy 
											WHERE cliente_tit = cCte_Titular 
												AND cliente_tras = cCte_Traspaso 
												AND canal = cCanal
												AND fecha_insert = dFecha
												AND estatus = 0;
											
											--LET iNo_fusionados = iNo_fusionados + 1;
										END IF;
										
									ELSE
										--Aqui retorno por que no existe el cliente titular
										LET cProceso = 'CLIENTE TITULAR NO EXISTE';
										
										--LET iNo_fusionados = iNo_fusionados + 1;
										
										UPDATE bdinteg:"informix".si_fusion_solic 
										SET cod_retorno = '00013', proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy
										WHERE cliente_tit = cCte_Titular 
											AND cliente_tras = cCte_Traspaso 
											AND canal = cCanal
											AND fecha_insert = dFecha
											AND estatus = 0;

										INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
										VALUES('Validacion cliente correcto', 'sp_fusion_cte_automatizada_solic', cCte_Titular, cCte_Traspaso, '00013'||'|'||cProceso, CURRENT  , pUsuario, CURRENT);
									END IF;
									
									--EXECUTE PROCEDURE "informix".sp_get_estadisticafusion(cCanal, cCodRet, dFechaHoy, '', '', pUsuario) 
									EXECUTE PROCEDURE "informix".sp_get_estadisticafusion(cCanal, cCodRet, dFechaHoy, cCanal, pFecha, pUsuario)
									INTO cCodRetEst;
									
									IF cCodRetEst::INTEGER <> 0 THEN
										INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
										VALUES('Estadistica fusion', 'sp_get_estadisticafusion', pNumCteCorrecto, pNumCteIncorrecto, cCodRetEst||'|'|| 'ERROR AL CALCULAR ESTADISTICA', CURRENT  , pUsuario, CURRENT);
									END IF;
								ELSE								
									INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
									VALUES('Valida instruccion', 'sp_fusion_cte_automatizada_solic', pNumCteCorrecto, pNumCteIncorrecto, '00012' ||'|'|| 'INSTRUCCION NO EXISTE O YA FUE EJECUTADA', CURRENT  , pUsuario, CURRENT);
									
									LET cEstado = 'PROCESO NO REALIZADO, INSTRUCCION NO EXISTE O YA FUE EJECUTADA';
								END IF;
							ELSE							
								LET cProceso = 'FUSION OMITIDA: MISMOS CLIENTES';
								UPDATE bdinteg:"informix".si_fusionaut 
								SET cod_retorno = '00015', proceso = cProceso, estatus = 2, fecha_proceso = dFechaHoy::DATE 
								WHERE cliente_tit = cCte_Titular 
									AND cliente_tras = cCte_Traspaso
									AND canal = cCanal
									AND fecha_insert = dFecha
									AND estatus = 0;

								INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
								VALUES('Validacion de numeros de cliente', 'sp_fusion_cte_automatizada_solic', cCte_Titular, cCte_Traspaso, '00015'||'|'||cProceso, CURRENT  , pUsuario, CURRENT);							
							END IF;
						END IF;
					END IF;
				ELSE
					INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
					VALUES('Valida usuario de ejecucion', 'bdinteg:si_param', pNumCteCorrecto, pNumCteIncorrecto, '00008' ||'|'|| 'USUARIO NO PERMITIDO: '|| USER, CURRENT  , pUsuario, CURRENT);
					
					LET cEstado = 'PROCESO NO REALIZADO, EL USUARIO '|| USER ||' NO ES EL DEFINIDO PARA EJECUTAR FUSION DE CLIENTES';
		 
				END IF;
			ELSE
				INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
				VALUES('Valida parametro usuario', 'sp_fusion_cte_automatizada_solic', pNumCteCorrecto, pNumCteIncorrecto, '00011' ||'|'|| 'Parametro nulo o vacio', CURRENT  , pUsuario, CURRENT);
			
				LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO USUARIO PERMITIDIO ES NULO o VACIO';
			END IF;
		ELSE
			INSERT INTO "informix".log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES('Valida parametro usuario', 'sp_fusion_cte_automatizada_solic', pNumCteCorrecto, pNumCteIncorrecto, '00010' ||'|'|| 'Parametro no existe', CURRENT  , pUsuario, CURRENT);
			
			LET cEstado = 'PROCESO NO REALIZADO, PARAMETRO USUARIO PERMITIDO NO EXISTE';			
		END IF;
	END IF;	
	RETURN cCodRet, cEstado;
END;
END PROCEDURE
DOCUMENT
'SUSTENTA: RQI 64 045',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 2014-11-21',
'DESCRIPCION: Se crea el SP para procesar instrucciones de fusion originadas en SOC/FRAUDES',
'BASE DE DATOS: bdinteg',
'----------------------------------------------',
'FECHA: 2014/12/01',
'MODIFICACION: Se modifica consulta para validar si el cliente cuenta con Club de proteccion, esto para evitar error -284',
'SUSTENTO: RQI 64 058',
'MODIFICA: José Ángel Lopez Adams',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 27/ENE/2015',
'DESCRIPCION: Se modifica para validar si ambos clientes se encuentran en la bdicheq:sc_cuenta_telefono como restriccion para continuar con la fusión',
'SUSTENTO: RQI 64 068',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg',
'----------------------------------------------',
'AUTOR: Rocio Karina Márquez Coronel',
'FECHA: 12/MAR/2015',
'DESCRIPCION: Se modifica para validar si ambos clientes se encuentran en la bditransfer:tf_maecte como restriccion para continuar con la fusión',
'SUSTENTO: RQI 64 075',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg',
'----------------------------------------------',
'AUTOR: Jose Angel Lopez Adams',
'FECHA: 04/JUN/2015',
'DESCRIPCION: Se modifica para ejecutar el SP sp_cuentadoctos para contemplar restricciones de fusion, tambien se cambia el momento de consultar el parametro',
'150 de la si_param, ahora se hace despues de identificar que hay instrucciones por procesar',
'SUSTENTO: RQI 64 097',
'SOLICITA: Jose Angel Lopez Adams',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_consultacte_altaunica_filtro(pEmpresa CHAR(3), pNumero CHAR(16),pOpcion CHAR(1))
RETURNING CHAR(6) AS cCodRet,CHAR(26) AS cPrimerNombre,CHAR(26) AS cSegundoNombre,CHAR(26) AS cApellidoPaterno,CHAR(26) AS cApellidoMaterno,DATE AS dFechaNacimiento,CHAR(13) AS cRfc,CHAR(20) AS cClienteCoppel,CHAR(20) AS cNumCte;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(6);
DEFINE cCodRet2  CHAR(5);
DEFINE cPrimerNombre  CHAR(26);
DEFINE cSegundoNombre CHAR(26);
DEFINE cApellidoPaterno CHAR(26);
DEFINE cApellidoMaterno CHAR(26);
DEFINE dFechaNacimiento DATE;
DEFINE cRfc CHAR(13);
DEFINE cClienteCoppel CHAR(20);
DEFINE iSqlErr INTEGER;
DEFINE cNumCte CHAR(20);
--INICIALIZACION DE VARIABLES 
LET cCodret	= "000000";
LET cCodret2 = "00000";
LET cPrimerNombre = "";
LET cSegundoNombre ="";
LET cApellidoPaterno ="";
LET cApellidoMaterno ="";
LET dFechaNacimiento ="";
LET cRfc ="";
LET cClienteCoppel ="";
LET iSqlErr = 0;
LET cNumCte ="";
--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_consultacte_altaunica_filtro.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,cClienteCoppel,cNumcte;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		IF TRIM(NVL(pEmpresa,''))='' OR TRIM(NVL(pNumero,'')) ='' OR TRIM(NVL(pOpcion,''))='' THEN
			LET cCodret = '000001'; --Parámetros de entrada vacíos
		ELSE
			IF TRIM(NVL(pOpcion,''))='1' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicheq:"informix".sc_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			ELIF TRIM(NVL(pOpcion,''))='2' THEN
				FOREACH
					SELECT num_cte
					INTO cNumCte
					FROM bdicheq:"informix".sc_maechq
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
					UNION
					SELECT num_cte
					FROM bdinvers:"informix".sv_maeinv
					WHERE cuenta= TRIM(NVL(pNumero,''))
					AND empresa=TRIM(NVL(pEmpresa,''))
				END FOREACH;
			ELIF TRIM(NVL(pOpcion,''))='3' THEN
				LET cNumCte=pNumero;
			ELIF TRIM(NVL(pOpcion,''))='4' THEN
				SELECT numcte 
				INTO cNumCte
				FROM  bdicred:"informix".sd_tarjeta
				WHERE num_tarjeta=TRIM(NVL(pNumero,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
			END IF
			
			SELECT apell_paterno,apell_materno,nombre1,nombre2,rfc
			INTO cApellidoPaterno, cApellidoMaterno, cPrimerNombre, cSegundoNombre, cRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte=TRIM(NVL(cNumcte,''))
			AND empresa=TRIM(NVL(pEmpresa,''));
			
			IF dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCodret	= "000002";
				LET cPrimerNombre='';
				LET cSegundoNombre='';
				LET cApellidoPaterno='';
				LET cApellidoMaterno='';
				LET dFechaNacimiento='';
				LET cRfc='';
				LET cClienteCoppel='';
			ELSE
				SELECT fecha_nac
				INTO dFechaNacimiento
				FROM bdinteg:"informix".si_ctepf
				WHERE numcte= TRIM(NVL(cNumcte,''))
				AND empresa=TRIM(NVL(pEmpresa,''));
				
				IF dbinfo("sqlca.sqlerrd2") = 0 THEN
					LET cCodret	= "000002";
					LET cPrimerNombre='';
					LET cSegundoNombre='';
					LET cApellidoPaterno='';
					LET cApellidoMaterno='';
					LET dFechaNacimiento='';
					LET cRfc='';
					LET cClienteCoppel='';
				ELSE
					EXECUTE PROCEDURE bdinteg:"informix".sp_consultactesrelacionados_filtro (TRIM(NVL(pEmpresa,'')),TRIM(NVL(cNumcte,'')))
					INTO cCodret2, cClienteCoppel;
				END IF
			END IF
		END IF
		RETURN  cCodRet,cPrimerNombre,cSegundoNombre,cApellidoPaterno,cApellidoMaterno,dFechaNacimiento,cRfc,TRIM(NVL(cClienteCoppel,'')),TRIM(NVL(cNumcte,''));
END
END PROCEDURE
DOCUMENT
"Descripción: Consulta datos generales del cliente",
"Autor : Leslie Rendón",
"FECHA : 24/10/2014",
"Descripción: Se modifica para agregar consulta por Tarjeta de crédito",
"Modifico : Leslie Rendón",
"FECHA : 16/12/2014",
"BD    : bdinteg",
'Clon de sp sp_consultacte_altaunica, que deja en blanco el cliente coppel si empieza con 9 y es de 11 digitos',
'Autor :Obed Vega',
'FECHA : 01/Julio/2016',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_replica_indicadores_kiosko(dFecha DATE, cSucursal CHAR(4), iCons_movtos INTEGER, iCons_saldos INTEGER, iCons_edocta INTEGER)
RETURNING CHAR(6), CHAR(100);

--DEFINICION DE VARIABLES
DEFINE cCodRet          CHAR(6);
DEFINE cMensCodRet      CHAR(100);
DEFINE cEvento 			CHAR(100);
DEFINE bEnTransaccion   BOOLEAN;
DEFINE iNomErr			INTEGER;
DEFINE iIsamErr			INTEGER;


--ASIGNACION DE VARIABLES
LET cCodRet = '000000';
LET cEvento = '';
LET cMensCodRet = 'EL PROCESO DE REPLICA EXITOSO';
LET bEnTransaccion = 'f';

--SET DEBUG FILE TO "/tmp/josea/64170/sp_replica_indicadores_kiosko.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET iNomErr, iIsamErr, cMensCodRet
		IF iNomErr <> 0 THEN
			LET cCodRet=iNomErr;
			IF bEnTransaccion = 't' THEN	
				ROLLBACK;
			END IF;
			
			INSERT INTO informix.si_log_indicadores_sucursal(fecha, proceso, evento, cod_error, mensaje, fecha_insert) 
			VALUES(dFecha, 'REPLICA INDICADORES KIOSKO', cEvento, cCodRet, cMensCodRet, (SELECT DBINFO('utc_to_datetime',sh_curtime) FROM sysmaster:"informix".sysshmvals));
			
			LET cEvento = 'RETORNO DE RESULTADOS EXCEPCION';
			RETURN cCodRet, cMensCodRet;
		END IF;
	END EXCEPTION;	
	
	LET cEvento = 'VALIDACION DE BANDERA DE TRANSACCION 1';
	IF bEnTransaccion = 'f' THEN
		BEGIN WORK;
		LET bEnTransaccion = 't';
	END IF;
	
	LET cEvento = 'VALIDACION DE PARAMETROS';
	
	IF NVL(dFecha,'') = '' THEN
		LET cCodRet = '000001';
		LET cMensCodRet = 'FECHA PROCESO INVALIDA';
	ELIF NVL(cSucursal,'') = '' THEN
		LET cCodRet = '000002';
		LET cMensCodRet = 'SUCURSAL INVALIDA';
	ELIF iCons_movtos IS NULL OR iCons_saldos IS NULL OR iCons_edocta IS NULL THEN
		LET cCodRet = '000003';
		LET cMensCodRet = 'CIFRAS RECIBIDAS INVALIDAS';
	ELSE
		LET cEvento = 'VALIDACION DE REGISTRO PREVIO';
		IF EXISTS (SELECT 1 FROM si_indicadores_kiosko WHERE fecha_proceso = dFecha AND sucursal = TRIM(cSucursal)) THEN
			LET cEvento = 'ACTUALIZACION DE REGISTRO';
			
			UPDATE si_indicadores_kiosko SET cons_movimientos = iCons_movtos, cons_saldos = iCons_saldos, cons_edocta = iCons_edocta
			WHERE fecha_proceso = dFecha AND sucursal = TRIM(cSucursal);
		ELSE
			LET cEvento = 'INSERCION DE REGISTRO';
			
			INSERT INTO si_indicadores_kiosko (fecha_proceso, sucursal, cons_movimientos, cons_saldos, cons_edocta)
			VALUES (dFecha, cSucursal, iCons_movtos, iCons_saldos, iCons_edocta);
		END IF;
	END IF;
	
	LET cEvento = 'VALIDACION DE BANDERA DE TRANSACCION 2';
	IF bEnTransaccion = 't' THEN
		COMMIT WORK;
		LET bEnTransaccion = 'f';
	END IF;
	
	LET cEvento = 'RETORNO DE RESULTADOS PRINCIPAL';
	RETURN cCodRet, cMensCodRet;
END;
END PROCEDURE	
DOCUMENT
'FECHA:29/06/2016',
'DESCRIPCION: SP utilizado por el replicador de indicadores de kiosko para insertar la informaciÃ³n extraida del server de postgresql';

CREATE PROCEDURE "informix".sp_actualiza_folio()
				returning CHAR(5) AS Cod_Retorno,INTEGER as Idreg;


DEFINE iexiste 			INT;
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;
DEFINE sRetCod          CHAR(5);
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE sFolio     CHAR(15);
DEFINE sFolio2     CHAR(15);
DEFINE iConteo	  INT;
DEFINE iFolio2     INT8;
DEFINE cFecha     CHAR(10);
DEFINE iId		     INT8;

LET sFolio        = '';
LET iFolio2        =0;
LET iConteo			=0;
LET iFolio2			=0;
LET cFecha        = '';
LET iId				=0;
LET sRetCod          	="99999";
LET cCodRet 			= "00000";

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet,iId;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO "/informix/VH/PM/sp_cnsif_consnumcte.out";
	--TRACE ON;
		

	SET ISOLATION TO DIRTY READ;
	FOREACH

		SELECT folio,count(*),fecha_insert INTO sFolio,iConteo,cFecha FROM "informix".si_solicitud_movil
		WHERE status_valua IS NOT NULL
		GROUP BY folio,fecha_insert
		HAVING count(*)>1

		SELECT max(folio),max(folio)::INT8+1 INTO sFolio2,iFolio2 FROM "informix".si_solicitud_movil
		WHERE fecha_insert=cFecha;

		SELECT max(id) INTO iId FROM "informix".si_solicitud_movil WHERE folio=sFolio;

		UPDATE "informix".si_solicitud_movil set folio=iFolio2 WHERE id=iId;


	END FOREACH;


	RETURN cCodRet,iId;
END
END PROCEDURE;