CREATE PROCEDURE "informix".sp_compara_huellas_ctes(pEmpresa CHAR(3))
RETURNING CHAR(5), CHAR(100);

	--DEFINICION DE VARIABLES
	DEFINE vCodret			CHAR(5);
	DEFINE vSqlerr			INTEGER;
	DEFINE cNumCteMatch		CHAR(20);
	DEFINE cMatch			CHAR(4);
	DEFINE iContador		INTEGER;
	DEFINE iContaMatch		INTEGER;	
	DEFINE iCtesRevAut		INTEGER;
	DEFINE cDescripcion		CHAR(100);
	DEFINE dFecha_actual	DATETIME YEAR TO SECOND;
	DEFINE sExiste			SMALLINT;
	DEFINE sVar				SMALLINT;
	DEFINE sCont			SMALLINT;
	DEFINE iPonSE_ini		INTEGER;
	DEFINE iPonSE_fin		INTEGER;
	DEFINE cCteMatch		INTEGER;
	DEFINE cSituacionMatch	CHAR(1);
	DEFINE iCausaMatch		SMALLINT;
	DEFINE cNombreOperador	CHAR(45);
	DEFINE cNumCteRefCoinc	CHAR(8);
	DEFINE cSecuenciacpl	CHAR(2);

	DEFINE dFecha_alta 		DATE;
	DEFINE cMatchResult		SMALLINT;
	DEFINE cNumMatchRes 	SMALLINT;
	
	
	
	--Variables de tabla temporal
	DEFINE cNumCte			CHAR(20);
	DEFINE cSucursal		CHAR(4);
	DEFINE cPromotor		CHAR(8);
	DEFINE cTicket			CHAR(50);
	DEFINE cStatusCons		CHAR(1);
	DEFINE cNumMen			CHAR(3);
	DEFINE cEmpresa			CHAR(4);
	DEFINE iCliente			INTEGER;
	
	--VARIABLES DE PARENTESCO
	DEFINE cCodRetParen		CHAR(5);
	DEFINE cNomCte1 		CHAR(40);
	DEFINE cNomCte2 		CHAR(40);
	DEFINE cApPatCte 		CHAR(40);
	DEFINE cApMatCte 		CHAR(40);
	DEFINE cFecNacCte 		CHAR(10);
	DEFINE cSituacionCte 	CHAR(1);
	DEFINE sCausaCte 		SMALLINT;
	
	--VARIABLES PARA COMPARACION
	DEFINE cNomCte1_1 		CHAR(104);
	DEFINE cNomCte2_1  		CHAR(40);
	DEFINE cApPatCte_1  	CHAR(40);
	DEFINE cApMatCte_1  	CHAR(40);
	DEFINE cFecNacCte_1  	CHAR(10);
	DEFINE cSituacionCte_1 	CHAR(1);
	DEFINE cNomCte1_2 		CHAR(40);
	DEFINE cNomCte2_2  		CHAR(40);
	DEFINE cApPatCte_2  	CHAR(40);
	DEFINE cApMatCte_2  	CHAR(40);
	DEFINE cFecNacCte_2  	CHAR(10);
	DEFINE cSituacionCte_2 	CHAR(1);
	DEFINE sCausaCte_2 		SMALLINT;
	DEFINE cSit_ini			CHAR(1);
	DEFINE cSit_fin			CHAR(1);
	DEFINE sCausa_ini		SMALLINT;
	DEFINE sCausa_fin		SMALLINT;
	DEFINE sCausaCte_1 		SMALLINT;
	
	DEFINE cCodRet_par		CHAR(5);
	DEFINE dPorcentaje		DECIMAL(14,2);
	DEFINE cPorcDecAut		CHAR(100);
	DEFINE cOperador		CHAR(8);
	DEFINE cCodRetSP 		CHAR(5);
	DEFINE sPonderacion 	CHAR(6);
	DEFINE cCausa 			CHAR(6);
	DEFINE cSituacion 		CHAR(1);
	DEFINE sBitComp			SMALLINT;
	DEFINE iDictaminados	SMALLINT;
	
	DEFINE cTipoCte			CHAR(1);
	
	--INICIALIZACION DE VARIABLES
	LET vCodret			= '00002';
	LET vSqlerr			= 0;
	LET cNumcte			= '';
	LET cNumCteMatch	= '';
	LET cTicket			= '';
	LET iContador		= 0;
	LET iContaMatch     = 0;	
	LET cDescripcion	= 'Clientes sin situacion especial';
	LET cSucursal		= '';
	LET cEmpresa		= '';
	LET cSit_fin		= '';
	LET sExiste			= 0;
	LET sCausa_fin		= 0;
	LET sCont			= 0;
	LET cSituacionMatch	= '';
	LET iCausaMatch		= 0;
	LET cCteMatch		= 0;
	LET cNumCteRefCoinc = '';
	LET cSecuenciacpl	= '';
	
	LET cNombreOperador = '';	
	LET dFecha_alta = TODAY;
	LET cMatchResult	= 0;
	LET cNumMatchRes 	= 0;
	
	--VARIABLES DE PARENTESCO	
	LET cCodRetParen	= '00000';
	LET cNomCte1 		= '';
	LET cNomCte2 		= '';
	LET cApPatCte 		= '';
	LET cApMatCte 		= '';
	LET cFecNacCte 		= '';
	LET cSituacionCte 	= '';
	LET sCausaCte 		= 0;
	
	--VARIABLES PARA COMPARACION
	LET cNomCte1_1 		= '';
	LET cNomCte2_1	 	= '';
	LET cApPatCte_1 	= '';
	LET cApMatCte_1 	= '';
	LET cFecNacCte_1 	= '';
	
	LET cSit_ini		= '';
	LET sCausa_ini		= 0;
		
	LET cCodRet_par		= '';
	LET dPorcentaje		= 0.0;
	LET cPorcDecAut		= '';
	LET cOperador		= '';
	LET cCodRetSP		= '';
	LET sPonderacion 	= '';
	LET cCausa 			= '';
	LET cSituacion 		= '';
	LET sBitComp		= 0;
	LET iDictaminados 	= 0;
	
	LET cTipoCte		= '';
	
--	SET DEBUG FILE TO '/informix/vhrojas/sp_compara_huellas_ctes.out';
 --   TRACE ON;
	
    BEGIN    
		ON EXCEPTION SET vSqlerr
			IF vSqlerr <> 0 THEN
				LET vCodret = vSqlerr;
				IF sCont < 1000 and sCont > 0 THEN
					COMMIT WORK;
				END IF;				
				RETURN vCodret, 'Error en cliente: ' || TRIM(cNumcte) || ' con match: '||TRIM(cNumCteMatch);
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		-- Se eliminan datos de tabla de paso
	    TRUNCATE TABLE "informix".tmp_si_comphuella;
		
		BEGIN WORK;			
			SELECT fecha_hoy::DATE 
			INTO dFecha_actual
			FROM "informix".si_fechas
			where empresa = pEmpresa;
			
			IF NVL(pEmpresa,'') = '' THEN		  
				LET vCodret  = '00001';
				LET cDescripcion = 'Parametro Empresa vacio';
			END IF;		

			-- CONSULTAMOS EL PORCENTAJE DE DECISION AUTOMATICA
			SELECT TRIM(Valor)
			INTO cPorcDecAut
			FROM "informix".si_param
			WHERE cod_param = '160';
			
				
			-- PARA SITUACIONES ESPECIALES NORMALES
			LET vCodret  		= '00000';
			LET iContador   	= 0;
			LET cNumcte			= '';
			LET cEmpresa		= '001';
			LET cNumCteMatch	= '';
			LET cOperador		= '';
			LET cSucursal		= '';
			LET cTicket			= '';
			LET cCodRetParen	= '';
			LET iCtesRevAut		= 0;
			--*******************   Inicia la validacion de los clientes que se encuentran marcados con R1 (Pendiente de comparacion de rostro)**************************************
			FOREACH
				SELECT numcte, fchalta::date, empleadoefectuo, nombreefectuo
				INTO cNumcte, dFecha_alta, cOperador, cNombreOperador
				FROM bdisitesp:"informix".se_ctessitespcte WHERE situacion='R' AND causa=1
				
				SELECT sucursal,status_consulta,match_result,num_match_result,ticket INTO cSucursal, cStatusCons, cMatchResult, cNumMatchRes, cTicket
				FROM "informix".si_rostro_linea 
				WHERE numcte = cNumcte
				AND secuencia = (SELECT MAX(secuencia) FROM "informix".si_rostro_linea WHERE numcte = cNumcte AND fecha_consulta=dFecha_alta);
				
				IF cStatusCons='3' AND TRIM(NVL(cTicket,"")) <> "" THEN --el cliente ya tiene resultados de comparacion facial?
				
					IF cMatchResult>0 AND cNumMatchRes>0 THEN --tiene match?
					
/* 	original			SELECT limit 1 num_match_result
						INTO cNumMatchRes
						FROM bdinteg:"informix".si_rostro_linea_result
						WHERE ticket = cTicket AND numcte_match <> pNumcte;
			
se cambio por este	    IF exists (SELECT limit 1 num_match_result FROM bdinteg:"informix".si_rostro_linea_result WHERE ticket = cTicket AND numcte_match <> pNumcte;) <> 0 THEN --Se cambia a R2 porque tiene Match con utros clientes Banco
 */ 						
						IF exists (SELECT num_match_result FROM bdinteg:"informix".si_rostro_linea_result WHERE ticket = cTicket AND numcte_match <> cNumcte) THEN --Se cambia a R2 porque tiene Match con utros clientes Banco
							EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp (1, pEmpresa, cNumcte, 'R', '2', '1', 'S',cSucursal, cOperador,cNombreOperador, '','') 
							INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
						ELSE							
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',61,'M','2',cSucursal,cOperador,cNombreOperador,'','')
								INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									LET vCodret = '00000';
								ELSE
									LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
								END IF;

						END IF;
					ELIF EXISTS (SELECT resultado FROM si_huella_linea_resultado WHERE ticket = (SELECT ticket FROM si_huella_linea WHERE numcte=cNumcte) AND resultado=1) THEN --si tiene resultados en huella, se pasa a U 61 para que pase por el proceso de huellas batch
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',61,'M','2',cSucursal,cOperador,cNombreOperador,'','')
						INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET vCodret = '00000';
						ELSE
							LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
						END IF;
					ELSE --Se inserta U 65 por no tener match de rostro ni de huella
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,cNombreOperador,'','')
						INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET vCodret = '00000';
						ELSE
							LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
						END IF;
					END IF;
					
				ELIF (cStatusCons='1' OR cStatusCons='2') AND dFecha_alta < TODAY-1 THEN --Sin resultados de comparaciÃ³n Facial y ya pasaron 2 dias
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',61,'M','2',cSucursal,cOperador,cNombreOperador,'','')
					INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
						LET vCodret = '00000';
					ELSE
						LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
					END IF;
					
				END IF;				
				
				LET cSucursal		= '';				
				LET cStatusCons 	= '';
				LET cMatchResult	= 0;
				LET cNumMatchRes 	= 0;
				LET cTicket			= '';
				
			END FOREACH;
			--*******************   Inicia la validacion de los clientes que se encuentran en la tabla bdisitesp:se_sitespctetmp (mantenimientos de huella)***************************
			FOREACH
				SELECT {+INDEX(bdisitesp:"informix".se_sitespctetmp idx_se_sitespctetmp01)}numcte, sucursal, operador
				INTO cNumcte, cSucursal, cOperador
				FROM bdisitesp:"informix".se_sitespctetmp  
				WHERE situacion = 'U' 
				AND causa = 61 
				AND empresa = pEmpresa
				
				SELECT situacion,causa
				INTO cSit_ini, sCausa_ini
				FROM bdisitesp: "informix".se_ctessitespcte
				WHERE numcte = cNumcte;
				
				SELECT empleado, ticket INTO cOperador, cTicket
				FROM "informix".si_huella_linea 
				WHERE numcte = cNumcte
				AND status_consulta = '3';
				
				SELECT nombre
				INTO cNombreOperador
				FROM bdinteg:si_ejecut 
				WHERE ejecutivo = cOperador;
				
				--Verifica si existe registro en la bitacora de comparaciones
				IF EXISTS (SELECT {+AVOID("informix".si_bitacora_comparaciones)} numcte FROM "informix".si_bitacora_comparaciones WHERE numcte=cNumcte) THEN
					LET sBitComp = 1;
				ELSE 
					LET sBitComp = 0;
				END IF;
				
				IF TRIM(NVL(cTicket,"")) <> "" THEN
				
					LET vCodret  = '00000';
					/*
					SELECT {+AVOID(si_huella_linea_resultado)} NVL(COUNT(ticket),0)
					INTO iContador
					FROM si_huella_linea_resultado
					WHERE ticket = cTicket;
					*/
			
					SELECT count(cliente) 
					INTO iContador
					FROM table(multiset(
											SELECT {+AVOID(si_huella_linea_resultado)} cliente,empresa,max(secuenciacpl)
											FROM "informix".si_huella_linea_resultado
											WHERE ticket = cTicket
											AND cliente not in  ('0',TRIM(cNumcte))
											AND num_mensaje = '602'
											group by cliente,empresa
										)	
							);

					IF NVL(iContador,0) = 0 THEN --Cliente no tuvo coincidencias
						-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,cNombreOperador,'','')
						INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET vCodret = '00000';
						ELSE
							LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
						END IF;
											
						INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
                        SELECT empresa, numcte, situacion, causa, cSit_fin,sCausa_fin, sucursal, proceso_origen, operador, fecha, CURRENT
                        FROM bdisitesp:"informix".se_sitespctetmp 
                        WHERE numcte = cNumcte;
						--VALUES(pEmpresa,cNumcte,'U',61,cSit_fin,sCausa_fin,cSucursal,'3',USER,CURRENT,CURRENT);
										
						-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
						DELETE FROM bdisitesp:"informix".se_sitespctetmp 
						WHERE numcte = cNumcte;
						
					ELIF iContador = 1 THEN 
						--Una coincidencia
						SELECT {+AVOID(si_huella_linea_resultado)} empresa, LPAD(TRIM(cliente::CHAR(20)) , 9, '0') as cliente,max(secuenciacpl)
						INTO cMatch, cNumCteMatch,cSecuenciacpl
						FROM "informix".si_huella_linea_resultado
						WHERE ticket = cTicket
						AND cliente not in  ('0',TRIM(cNumCte))
						AND num_mensaje = '602'
						GROUP BY empresa,cliente;
						
						IF NOT EXISTS (SELECT 1 FROM si_bitacora_dictamenes WHERE numcte = cNumcte AND numcte_coinc = cNumCteMatch AND tipo = cMatch) THEN						
							IF TRIM(cMatch) = '5' THEN							
								-- VERIFICAMOS SI TIENE PARENTESCO PADRE O HIJO.
								EXECUTE PROCEDURE "informix".sp_obtieneparentesco(TRIM(cNumcte),TRIM(cNumCteMatch))
								INTO cCodRetParen, cNomCte1, cNomCte2, cApPatCte, cApMatCte, cFecNacCte, cSituacionCte, sCausaCte;   

								-- SI EL PROCEDIMIENTO REGRESA CODIGO RETORNO = 1 SI TIENE PARENTESCO PADRE O HIJO.
								-- SI EL CLIENTE HACE MATCH CON SU MISMO  NUMERO DE EMPLEADO
								IF cCodRetParen::INTEGER = 1  OR cNumCteMatch = cNumcte THEN					
									-- SI EL CLIENTE TIENE PARENTESCO SE MARCA COMO TERMINADO EL ANALISIS DEL CLIENTE situacion = "U", causa = "65".
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,cNombreOperador,'','')
									INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
									
									IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										LET vCodret = '00000';
									ELSE
										LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
									END IF;
									
									SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} NVL(situacion,''), NVL(causa,0)
										INTO cSituacionMatch, iCausaMatch
										FROM bdisitesp:"informix".se_ctessitespcte
									WHERE numcte = cNumCteMatch;
									
									INSERT INTO "informix".si_bitacora_dictamenes (numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
									VALUES(cNumcte,'U',65,cNumCteMatch,NVL(cSituacionMatch,''),NVL(iCausaMatch,0),'5',cSucursal,cOperador,'1',CURRENT,'2',CURRENT,CURRENT);
									
									-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
									INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
									SELECT empresa, numcte, situacion, causa, 'U', 65, sucursal, proceso_origen, operador, fecha, CURRENT
									FROM bdisitesp:"informix".se_sitespctetmp
									WHERE numcte = cNumcte;
									--VALUES(pEmpresa,cNumcte,'U',61,'U',65,cSucursal,'3',USER,CURRENT,CURRENT);
									
									-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
									DELETE FROM bdisitesp:"informix".se_sitespctetmp 
									WHERE numcte = cNumcte;
								ELSE		
									-- SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE BANCOPPEL.							
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1
									FROM "informix".si_cliente a, "informix".si_ctepf b, bdisitesp: "informix".se_ctessitespcte c
									WHERE a.numcte = cNumcte
									AND c.idmovto = (SELECT MAX(idmovto) FROM bdisitesp: "informix".se_ctessitespcte WHERE numcte  = cNumcte)
									AND a.numcte = b.numcte
									AND b.numcte = c.numcte
									AND a.numcte = c.numcte;						
			
									-- SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE MATCH.
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1_2,cNomCte2_2,cApPatCte_2,cApMatCte_2,cFecNacCte_2
									FROM "informix".si_cliente a, "informix".si_ctepf b--, bdisitesp: "informix".se_ctessitespcte c
									WHERE a.numcte = cNumCteMatch
									--AND c.idmovto = (SELECT MAX(idmovto) FROM bdisitesp: "informix".se_ctessitespcte WHERE numcte  = cNumCteMatch)
									AND a.numcte = b.numcte;
									--AND b.numcte = c.numcte
									--AND a.numcte = c.numcte;
																									
									-- SE REALIZA AL COMPARACION DE LOS NOMBRES DE LOS CLIENTES PARA OBTENER EL PORCENTAJE DE SIMILITUD.
									EXECUTE PROCEDURE "informix".sp_validanombrefechanac(cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1,cNomCte1_2,cNomCte2_2,cApPatCte_2,cApMatCte_2,cFecNacCte_2)
									INTO cCodRet_par, dPorcentaje;
																	
									-- SI EL PORCENTAJE DE DECISION AUTOMATICA ES MAYOR O IGUAL AL PROCENTAJE DE SIMILITUD DE AMBOS CLIENTES SE DETERMINA QUE ES LA MISMA PERSONA.
									IF dPorcentaje >= cPorcDecAut::DECIMAL(6,0) THEN
										-- SE MARCA AL CLIENTE CON SITUACION ESPECIAL U3
										EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',3,'M','2',cSucursal,cOperador,cNombreOperador,'','')
										INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
										
										IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
											LET vCodret = '00000';
										ELSE
											LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
										END IF;
										
										SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} NVL(situacion,''), NVL(causa,0)
										INTO cSituacionMatch, iCausaMatch
										FROM bdisitesp:"informix".se_ctessitespcte
										WHERE numcte = cNumCteMatch;
										
										-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES bdinteg:"informix".si_bitacora_dictamenes.
										INSERT INTO "informix".si_bitacora_dictamenes (numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
										VALUES(cNumcte, 'U', 3, cNumCteMatch, NVL(cSituacionMatch,''), NVL(iCausaMatch,0),dPorcentaje,'5', cSucursal, cOperador, '1', CURRENT,'1',CURRENT,CURRENT);
										--VALUES(cNumcte,'U',61,cNumCteMatch,'U','3','5',cSucursal,cOperador,'1',CURRENT);
											
										-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
										INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa, numcte, situacion, causa, situacion_fin, causa_fin, sucursal, proceso_origen, operador, fecha, fechamovto)
										SELECT empresa, numcte, situacion, causa, 'U', 3, sucursal, proceso_origen, operador, fecha, CURRENT
										FROM bdisitesp:"informix".se_sitespctetmp
										WHERE numcte = cNumcte;
										--VALUES(pEmpresa, cNumcte, 'U', 61, 'U', 3, cSucursal, '3', USER, CURRENT, CURRENT);
																		
										-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
										DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
									ELSE									
																																				
										
											-- CLIENTE PENDIENTE DE DICTAMEN.
											IF NOT EXISTS (SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte) THEN
												EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',62,'M','5', cSucursal, cOperador, cNombreOperador, '', '')
												INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
											END IF;
											
											IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
												LET vCodret = '00000';
											ELSE
												LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
											END IF;

											-- SE LEVANTA LA ALERTA PARA SER ANALIZADA POR EL SISTEMA CENTRAL DE FRAUDES.
											IF sBitComp = 0 THEN
												INSERT INTO "informix".si_bitacora_comparaciones( numcte, origen, sucursal, num_huellas, numemp, status_alerta, fecha_insert)
												VALUES( cNumcte, '3', cSucursal, iContador, cOperador, '1', CURRENT);
											ELSE
												UPDATE "informix".si_bitacora_comparaciones SET origen='3',sucursal=cSucursal,num_huellas=iContador,numemp=cOperador,status_alerta='1',fecha_insert=current WHERE numcte=cNumcte;
											END IF;
											
											IF NVL(cSit_ini,'') = '' AND NVL(sCausa_ini,'')='' THEN -- Se Inserta situacion especial a U-62 cuando no es existe registro
												EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
												INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											ELIF cSit_ini = '' AND sCausa_ini='0' THEN  -- Se actualiza la situacion especial a U-62 cuando existe registro vacio
												EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
												INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											END IF;
											

											-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
											INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa, numcte, situacion, causa, situacion_fin, causa_fin, sucursal, proceso_origen, operador, fecha, fechamovto)
											SELECT empresa, numcte, situacion, causa, 'U', 62, sucursal, proceso_origen, operador, fecha, CURRENT
											FROM bdisitesp:"informix".se_sitespctetmp
											WHERE numcte = cNumcte;

											-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
											DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
										
									END IF;
								END IF;
							-- COINCIDENCIA  CLIENTE COPPEL(4) 1 a 1
							ELIF TRIM(cMatch)='4' THEN
								IF NVL(cSit_ini,'') = '' AND NVL(sCausa_ini,'')='' THEN
									---Se asigna la situacion especial U-65 debido a que se hizo match cliente coppel 1 a 1
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
									INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
									IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										LET vCodret = '00000';
									ELSE
										LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
									END IF;
									
									DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
									
								END IF;
							-- COINCIDENCIA EMPLEADO OTRA EMPRESA (0), EMPLEADO GRUPO COPPEL(1,2,3) 
							ELIF TRIM(cMatch) IN('0', '1', '2', '3') THEN
								IF NOT EXISTS (SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte) THEN
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1, pEmpresa, cNumcte, 'U', 62, 'M', '2', cSucursal, cOperador, cNombreOperador, '', '')
									INTO cCodRetSP, sPonderacion, cSit_fin, sCausa_fin;
								END IF;
								
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									LET vCodret = '00000';
								ELSE
									LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
								END IF;
								
								-- SE LEVANTA LA ALERTA PARA SER ANALIZADA POR EL SISTEMA CENTRAL DE FRAUDES.
								IF sBitComp = 0 THEN
									-- SE LEVANTA LA ALERTA PARA SER ANALIZADA POR EL SISTEMA CENTRAL DE FRAUDES.
									INSERT INTO "informix".si_bitacora_comparaciones( numcte, origen, sucursal, num_huellas, numemp, status_alerta, fecha_insert)
									VALUES( cNumcte, '3', cSucursal, iContador, cOperador, '1', CURRENT);
								ELSE
									UPDATE "informix".si_bitacora_comparaciones SET origen='3',sucursal=cSucursal,num_huellas=iContador,numemp=cOperador,status_alerta='1',fecha_insert=current WHERE numcte=cNumcte;
								END IF;
							
								IF NVL(cSit_ini,'') = '' AND NVL(sCausa_ini,'')='' THEN -- Se Inserta situacion especial a U-62 cuando no es existe registro
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
									INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
								ELIF cSit_ini = '' AND sCausa_ini='0' THEN  -- Se actualiza la situacion especial a U-62 cuando existe registro vacio
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
									INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
								END IF;
							
								-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
								INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa, numcte, situacion, causa, situacion_fin, causa_fin, sucursal, proceso_origen, operador, fecha, fechamovto)
								SELECT empresa, numcte, situacion, causa, 'U', 62, sucursal, proceso_origen, operador, fecha, CURRENT
								FROM bdisitesp:"informix".se_sitespctetmp
								WHERE numcte = cNumcte;
								
								-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
								DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
							END IF;
						ELSE
							INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
							SELECT empresa, numcte, situacion, causa, (SELECT situacion FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte), (SELECT causa FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte), sucursal, proceso_origen, operador, fecha, CURRENT
							FROM bdisitesp:"informix".se_sitespctetmp
							WHERE numcte = cNumcte;
							
							DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
						END IF;							
					ELIF iContador > 1 THEN -- SI EL CLIENTE TIENE MAS DE UNA COINCIDENCIA.
						
						--Se obtiene el numero de coincidencias encontradas del cliente y que fueron previamente dictaminadas
						SELECT COUNT(a.ticket)
						INTO iDictaminados
						FROM si_huella_linea_resultado a,  si_bitacora_dictamenes b
						WHERE a.ticket = cTicket
						AND a.cliente::CHAR(20) = b.numcte_coinc
						AND a.empresa = b.tipo
						AND a.cliente <> 0						
						AND a.num_mensaje = '602'
						AND b.numcte = cNumcte;
						
						--Si existen matches que no han sido dictamindos levantara ALERTA
						IF iContador  > iDictaminados THEN
						
							IF NOT EXISTS (SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} numcte FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte) THEN
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,cOperador,cNombreOperador,'','')
								INTO cCodRetSP,sPonderacion,cSit_fin,sCausa_fin;
							END IF;
							
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								LET vCodret = '00000';
							ELSE
								LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
							END IF;

							-- SE LEVANTA LA ALERTA PARA SER ANALIZADA POR EL SISTEMA CENTRAL DE FRAUDES.
							IF sBitComp = 0 THEN
								-- SE LEVANTA LA ALERTA PARA SER ANALIZADA POR EL SISTEMA CENTRAL DE FRAUDES.
								INSERT INTO "informix".si_bitacora_comparaciones( numcte, origen, sucursal, num_huellas, numemp, status_alerta, fecha_insert)
								VALUES( cNumcte, '3', cSucursal, iContador - iDictaminados, cOperador, '1', CURRENT);
							ELSE
								UPDATE "informix".si_bitacora_comparaciones SET origen='3',sucursal=cSucursal,num_huellas = iContador - iDictaminados,numemp=cOperador,status_alerta='1',fecha_insert=current WHERE numcte=cNumcte;
							END IF;	
							
							IF NVL(cSit_ini,'') = '' AND NVL(sCausa_ini,'')='' THEN -- Se Inserta situacion especial a U-62 cuando no es existe registro
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(1,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
								INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
							ELIF cSit_ini = '' AND sCausa_ini='0' THEN  -- Se actualiza la situacion especial a U-62 cuando existe registro vacio
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
								INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
							END IF;
								
							-- SE INSERTA EL REGISTRO DE LA SITUACION ALTERNA DEL CLIENTE EN LA TABLA bdisitesp:"informix".se_sitespctetmphis
							INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
							SELECT empresa, numcte, situacion, causa, 'U', 62, sucursal, proceso_origen, operador, fecha, CURRENT
							FROM bdisitesp:"informix".se_sitespctetmp
							WHERE numcte = cNumcte;
	--						VALUES(pEmpresa, cNumcte, 'U', 61, 'U', 62, cSucursal, '3', USER, CURRENT, CURRENT);

							-- SE ELIMINA EL REGISTRO DEL CLIENTE DE LA TABLA SE SITUACIÃ?Ã?Ã?Ã?N TEMPORALES bdisitesp:"informix".se_sitespctetmp.
							DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
						ELSE 
							INSERT INTO bdisitesp: "informix".se_sitespctetmphis(empresa,numcte,situacion,causa,situacion_fin,causa_fin,sucursal,proceso_origen,operador,fecha,fechamovto)
							SELECT empresa, numcte, situacion, causa, (SELECT situacion FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte), (SELECT causa FROM bdisitesp:se_ctessitespcte WHERE numcte = cNumcte), sucursal, proceso_origen, operador, fecha, CURRENT
							FROM bdisitesp:"informix".se_sitespctetmp
							WHERE numcte = cNumcte;
							
							DELETE FROM bdisitesp:"informix".se_sitespctetmp WHERE numcte = cNumcte;
							--
						END IF;
					END IF;
				END IF;				
			END FOREACH;
			--***************************************Termina la validacion de registros originados en mantenimiento de huellas******************************************
			
			FOREACH WITH HOLD
			
				SELECT sit.numcte, sit.sucursal, sit.empleadoefectuo, lin.ticket,lin.status_consulta,res.num_mensaje,res.empresa,res.cliente,res.secuenciacpl
				INTO cNumCte,cSucursal,cPromotor,cTicket,cStatusCons,cNumMen,cEmpresa,iCliente,cSecuenciacpl
				FROM bdisitesp:"informix".se_ctessitespcte sit,
				bdinteg:"informix".si_huella_linea lin,
				bdinteg:"informix".si_huella_linea_resultado res
				WHERE sit.situacion = 'U' AND sit.causa = 61 AND sit.empresa = '001'
				AND sit.fchalta::DATE = dFecha_actual
				AND lin.numcte = sit.numcte
				AND lin.status_consulta = '3'
				AND lin.ticket = res.ticket
								
				INSERT INTO "informix".tmp_si_comphuella(numcte,sucursal,promotor,ticket,status_consulta,num_mensaje,empresa,cliente,secuenciacpl) VALUES(TRIM(cNumCte),TRIM(cSucursal),TRIM(cPromotor),TRIM(cTicket),TRIM(cStatusCons),TRIM(cNumMen),TRIM(cEmpresa),iCliente,TRIM(cSecuenciacpl));
				
				LET sCont = sCont + 1;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
							
			END FOREACH;
			
			IF sCont < 1000 and sCont > 0 THEN
				COMMIT WORK;
				LET sCont = 0;
				BEGIN WORK;
			END IF;
						
			FOREACH WITH HOLD
				
				SELECT {+INDEX("informix".tmp_si_comphuella idx_comphuella)} numcte,sucursal,promotor,ticket
				INTO cNumCte,cSucursal,cOperador,cTicket
				FROM tmp_si_comphuella
				WHERE numcte = numcte
				GROUP BY numcte,sucursal,promotor,ticket
				ORDER BY numcte
				
				SELECT count(cliente) 
				INTO iContador
				FROM table(multiset(
									SELECT cliente,empresa,max(secuenciacpl)
									FROM "informix".tmp_si_comphuella
									WHERE numcte=cNumcte
									AND cliente not in  ('0',TRIM(cNumCte))
                                    and num_mensaje='602'
									group by cliente,empresa
								)	
				);
					
					

				
				LET sCont = sCont + 1;
				
				LET iCtesRevAut = 0;
				LET iContaMatch = NVL(iContador,0);				
				
				IF NVL(iContador,0) = 0 THEN -- Solo existe un registro con num_mensaje = 601

					--SIN COINCIDENCIAS(U-65), CLIENTE REVISADO
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,'','','')
					INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
					IF CAST(cCodRetSP AS INTEGER)  <> 0 THEN
						LET vCodret = cCodRetSP;
						LET cDescripcion = 'Error al actualizar situacion especial';
					END IF
				
				ELSE	-- Se procesa cliente con uno o dos match de huella 
					
					LET iContador = 0;
					
					FOREACH WITH HOLD
			
						SELECT cliente,empresa,max(secuenciacpl)
						INTO cCteMatch,cEmpresa,cSecuenciacpl
						FROM "informix".tmp_si_comphuella
						WHERE numcte=cNumcte
						AND procesado <> 'V'
						AND cliente not in  ('0',TRIM(cNumCte))
						and num_mensaje='602'
						group by cliente,empresa
									
									
						
						LET iContador = iContador + 1;
						
						IF cEmpresa = '5' THEN
							-- COINCIDENCIA CON CLIENTE BANCOPPEL.
							-- VERIFICAMOS SI TIENE PARENTESCO PADRE O HIJO.
							
							LET cNumCteMatch = LPAD(TRIM(cCteMatch::CHAR(20)),9,'0');
							
							IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_fuscliente WHERE numcte = cNumCteMatch) THEN
								
								EXECUTE PROCEDURE "informix".sp_obtieneparentesco( cNumcte, cNumCteMatch )
								INTO cCodRetParen, cNomCte1, cNomCte2, cApPatCte, cApMatCte, cFecNacCte, cSituacionCte, sCausaCte;
								
								-- EVALUAMOS EL RETORNO EN LA VARIABLE cCodRetParen
								IF cCodRetParen::INTEGER = 1 THEN
									
									LET iContador = iContador - 1; -- Se descarta match por parentesco		
									LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
									
								ELSE
									-- NO EXISTE PARENTESCO,  SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE BANCOPPEL.							
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1
									FROM "informix".si_cliente a, "informix".si_ctepf b
									WHERE a.numcte = cNumcte AND a.numcte = b.numcte;
									
									-- SE ASIGNA FORMATO DE FECHA COMO DD/MM/YYYY PARA COMPARACION DE NOMBRE Y FECHA
									LET cFecNacCte_1 =  LPAD( TRIM(DAY(cFecNacCte_1)::CHAR(2)),2,'0') || '/' || LPAD(TRIM(MONTH(cFecNacCte_1)::CHAR(2)),2,'0') || '/' || YEAR(cFecNacCte_1);
									
									-- SE REALIZA AL COMPARACION DE LOS NOMBRES DE LOS CLIENTES PARA OBTENER EL PORCENTAJE DE SIMILITUD.
									EXECUTE PROCEDURE "informix".sp_validanombrefn(cNomCte1_1,cNomCte2_1,cApPatCte_1,cApMatCte_1,cFecNacCte_1,cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,0)
									INTO cCodRet_par, dPorcentaje;
									
									-- COMPARANDO EL PROCENTAJE DE SIMILITUD DE AMBOS CLIENTES
									IF dPorcentaje >= cPorcDecAut::DECIMAL(6,0) THEN
									
										-- COINCIDENCIA BANCOPPEL Y CLIENTE SON LA MISMA PERSONA, SE MARCA COMO CLIENTE CON COINCIDENCIA EN HUELLA
										IF cNumcte <> cNumCteMatch THEN
											EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',3,'M','2',cSucursal,"informix",'','','')
											INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
												LET vCodret = '00000';
											ELSE
												LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
											END IF;
											
											-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
											INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
											VALUES(cNumcte,'U','3',cNumCteMatch, NVL(cSituacionCte,''), NVL(sCausaCte,0),dPorcentaje,cEmpresa, cSucursal,'informix','2',CURRENT,'1',CURRENT,CURRENT);
										
										ELSE
											---Se asigna la situacion especial U-65 debido a que se hizo match con mismo cliente
											EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
											INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
											IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
												LET vCodret = '00000';
											ELSE
												LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
											END IF;
											
											SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte bdisitesp:"informix".se_ctessitespcte_idx1)} NVL(situacion,'U'),NVL(causa,65) INTO cSituacion,cCausa 
											FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = cNumcte;
											
											-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
											INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
											VALUES(cNumcte,NVL(cSituacion,'U'), NVL(cCausa,65), cNumCteMatch, NVL(cSituacionCte,''), NVL(sCausaCte,0),dPorcentaje,cEmpresa, cSucursal,'informix','2',CURRENT,'2',CURRENT,CURRENT);
											
										END IF;
										
										
										UPDATE "informix".si_huella_linea_resultado SET nombre= TRIM(TRIM(cNomCte1)||' '||TRIM(cNomCte2))||' '||TRIM(TRIM(cApPatCte)||' '||TRIM(cApMatCte)) , fecha_nac=cFecNacCte WHERE ticket=cTicket and num_mensaje='602' and empresa=cEmpresa and cliente = cNumCteMatch;
										
										LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
										
									END IF;
									
								END IF;
							ELSE 
							
								LET iContador = iContador - 1; -- Se descarta match con cliente fusionado
								LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
								
								UPDATE "informix".tmp_si_comphuella set fusionado='V'  WHERE numcte=cNumCte and empresa=cEmpresa and cliente=cCteMatch;
								--UPDATE "informix".tmp_si_comphuella set fusionado='V'  WHERE CURRENT OF curso;
							END IF;
							
						ELIF cEmpresa = '4' THEN
							
							-- SE OBTIENE EL NOMBRE, FECHA DE NACIMIENTO Y SITUACION ESPECIAL DEL CLIENTE COPPEL.							
							SELECT LIMIT 1 TRIM(nombre),TRIM(fecha_nac),TRIM(situacion),causa
							INTO cNomCte1_1,cFecNacCte_1,cSituacionCte_1,sCausaCte_1
							FROM "informix".si_huella_linea_resultado
							WHERE ticket = cTicket
							and empresa = cEmpresa
							and num_mensaje = '602'
							and cliente = cCteMatch;
							
							IF (NVL(cNomCte1_1,'') <> '') AND (NVL(cFecNacCte_1,'') <> '') THEN 
							
								-- SE OBTIENE EL NOMBRE Y FECHA DE NACIMIENTO DEL CLIENTE BANCOPPEL.							
									SELECT NVL(a.nombre1,''),NVL(a.nombre2,''),NVL(a.apell_paterno,''),NVL(a.apell_materno,''),NVL(b.fecha_nac,'')
									INTO cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte
									FROM "informix".si_cliente a, "informix".si_ctepf b
									WHERE a.numcte = cNumcte AND a.numcte = b.numcte; 
									
									-- SE ASIGNA FORMATO DE FECHA COMO DD/MM/YYYY PARA COMPARACION DE NOMBRE Y FECHA
									LET cFecNacCte =  LPAD( TRIM(DAY(cFecNacCte)::CHAR(2)),2,'0') || '/' || LPAD(TRIM(MONTH(cFecNacCte)::CHAR(2)),2,'0') || '/' || YEAR(cFecNacCte);
									
								
								-- SE REALIZA AL COMPARACION DE LOS NOMBRES DE LOS CLIENTES PARA OBTENER EL PORCENTAJE DE SIMILITUD.
								EXECUTE PROCEDURE "informix".sp_validanombrefn(cNomCte1_1,"","","",cFecNacCte_1,cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,0)
								INTO cCodRet_par, dPorcentaje;
								
								-- COMPARANDO EL PROCENTAJE DE SIMILITUD DE AMBOS CLIENTES
								IF dPorcentaje >= cPorcDecAut::DECIMAL(6,0) THEN
									--Validos cliente referencia
									--Que nos retorne el numero de cliente con el que hizo coincidencia
									EXECUTE PROCEDURE bdinteg:"informix".sp_valida_relacion_huella(1,cNumCte,cCteMatch, "001",USER, 4, 'Huella en Linea')
									INTO cCodRet_par,cNumCteRefCoinc;					
									
									IF CAST(cCodRet_par AS INTEGER)  = 0 THEN
										--Guardamos en bitacora relaciones 
										EXECUTE PROCEDURE bdinteg:"informix".sp_bit_ctes_rel(cNumCte, cNumCteRefCoinc,NVL(cCteMatch,''),cSucursal,USER)
										INTO cCodRet_par;
										
										IF CAST(cCodRet_par AS INTEGER)  = 0 THEN
											    
												SELECT {+AVOID_FULL(bdisitesp:"informix".se_ctessitespcte)} first 1 situacion,causa INTO cSituacion,cCausa FROM bdisitesp:"informix".se_ctessitespcte WHERE numcte = cNumcte;
												
												-- SE INSERTA EL REGISTRO EN LA BITACORA DICTAMENES
												INSERT INTO "informix".si_bitacora_dictamenes(numcte,situacion,causa,numcte_coinc,situacion_coinc,causa_coinc,similitud,tipo,sucursal,numemp,origen,fecha_insert,tipo_dictamen,fecha_dicta_ini,fecha_dicta_fin)
												VALUES(cNumcte,cSituacion,cCausa,cCteMatch, NVL(cSituacionCte_1,''), NVL(sCausaCte_1,0),dPorcentaje,cEmpresa, cSucursal,USER,'2',CURRENT,'1',CURRENT,CURRENT);
												
												LET iCtesRevAut = iCtesRevAut+1; -- Match procesado
												
										END IF;
									END IF;		
									
								END IF;
							END IF;
						END IF;
						
					END FOREACH;
					
					IF (iContador = 0) OR (iCtesRevAut = iContador) THEN 
						
						--SIN COINCIDENCIAS(U-65), CLIENTE REVISADO
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,cOperador,'','','')
						INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
						IF CAST(cCodRetSP AS INTEGER)  <> 0 THEN
							LET vCodret = cCodRetSP;
							LET cDescripcion = 'Error al actualizar situacion especial';
						END IF
						
					ELIF (iCtesRevAut) < iContador  THEN-- se verifica si ambos match se dictaminaron
						
						SELECT {+INDEX(bdinteg:"informix".si_cliente idx_si_cliente5)} tipo_cliente INTO cTipoCte FROM bdinteg:"informix".si_cliente WHERE empresa='001' and numcte=cNumCte;
					
						-- SOLO SE GENERAN ALERTAS A PREVENCION DE FRAUDES DE CLIENTES TITULARES
						IF cTipoCte <> '1' THEN
								--CUANDO EL CLIENTE ES PROSPECTO SE LE ACTUALIZA LA SITUACIÃN ESPECIAL POR DEFECTO A U65
								IF cTipoCte = '2' THEN
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
									INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
									UPDATE "informix".tmp_si_comphuella set procesado='V' WHERE numcte=cNumCte;
									CONTINUE FOREACH;
								ELSE
								--DE LO CONTRARIO CONTINUA CON EL PROCESO HABITUAL
									UPDATE "informix".tmp_si_comphuella set procesado='P' WHERE numcte=cNumCte;
									CONTINUE FOREACH;
								END IF;
						END IF;
						-- CLIENTES CON MATCH COPPEL 1 A 1
						IF iContaMatch=1 AND cEmpresa = '4' THEN
							EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',65,'M','2',cSucursal,"informix",'','','')
							INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
							
							UPDATE "informix".tmp_si_comphuella set procesado='V' WHERE numcte=cNumCte;
							
							CONTINUE FOREACH;
						END IF;
						
						-- CLIENTE PENDIENTE DE DICTAMEN DEL DEPARTAMENTO DE FRAUDES.
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,cNumcte,'U',62,'M','2',cSucursal,"informix",'','','')
						INTO cCodRetSP,sPonderacion,cSituacion,cCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET vCodret = '00000';
						ELSE
							LET cDescripcion = cCodRetSP || ' Error al actualizar situacion especial';
						END IF;
						
						-- SE LEVANTA LA ALERTA PARA EL SISTEMA CENTRAL DE FRAUDES.
						IF EXISTS(SELECT {+AVOID("informix".si_bitacora_comparaciones)} numcte FROM "informix".si_bitacora_comparaciones WHERE numcte=cNumcte) THEN
							UPDATE "informix".si_bitacora_comparaciones SET origen='2',sucursal=cSucursal,num_huellas=iContador-iCtesRevAut,numemp=cOperador,status_alerta='1',fecha_insert=current WHERE numcte=cNumcte;
						ELSE
							INSERT INTO "informix".si_bitacora_comparaciones( numcte, origen, sucursal, num_huellas, numemp, status_alerta, fecha_insert)
							VALUES( cNumcte, '2', cSucursal, iContador-iCtesRevAut, cOperador, '1', CURRENT);
						END IF;		
						
					END IF
				END IF;
				
				UPDATE "informix".tmp_si_comphuella set procesado='V' WHERE numcte=cNumCte;
				
				IF sCont = 1000 THEN
					COMMIT WORK;
					LET sCont = 0;
					BEGIN WORK;
				END IF;
				
			END FOREACH;
			
			IF sCont < 1000 and sCont >= 0 THEN
				COMMIT WORK;
			END IF;
			
		
			IF TRIM(vCodret) = '00000' THEN LET cDescripcion= 'Exito'; END IF
			RETURN vCodret, cDescripcion;	

	END;
END PROCEDURE;