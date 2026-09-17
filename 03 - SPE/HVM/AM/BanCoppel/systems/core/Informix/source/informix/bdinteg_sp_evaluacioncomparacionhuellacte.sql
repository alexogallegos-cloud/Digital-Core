CREATE PROCEDURE "informix".sp_evaluacioncomparacionhuellacte(pNumCteBanc CHAR(20),
															  pNomCteBanc CHAR(40),
															  pNomCte2Banc CHAR(40),
															  pApPatCteBanc CHAR(40),
															  pApMatCteBanc CHAR(40),
															  pFecNacCteBanc CHAR(10),
															  pCausaCteBanc SMALLINT,
															  pSitEspCteBanc CHAR(1),
															  pNumCteConc CHAR(20),
															  pNomCteConc CHAR(40),
															  pNomCte2Conc CHAR(40),
															  pApPatCteConc CHAR(40),
															  pApMatCteConc CHAR(40),
															  pFecNacCteConc CHAR(10),
															  pCausaCteConc SMALLINT,
															  pSitEspCteConc CHAR(1),
															  pSucursal CHAR(4),
															  pNumCajero CHAR(8),
															  pNumCoinc SMALLINT,
															  pEmpresaCoinc CHAR(1),
															  pStatusEmpleado CHAR(1),
															  pRecontratable CHAR(1),
															  pCausaBaja CHAR(2),
															  pEmpresa CHAR(3))
	
RETURNING CHAR(5) AS CodRetorno,  
		  INTEGER AS FlagCoppel,
		  INTEGER AS FlagProdCred;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE cCodRet 			CHAR(5);
DEFINE cDato 			CHAR(2);
DEFINE cCodRetSP 		CHAR(5);
DEFINE cNomCte1 		CHAR(40);
DEFINE cNomCte2 		CHAR(40);
DEFINE cApPatCte 		CHAR(40);
DEFINE cApMatCte 		CHAR(40);
DEFINE cFecNacCte 		CHAR(10);
DEFINE cSituacionCte 	CHAR(1);
DEFINE cPorcentajeAutom CHAR(2);
DEFINE cPorcentajePromo CHAR(2);
DEFINE cNumCteRefCoinc 	CHAR(20);
DEFINE cSituacionExEmp 	CHAR(1);
DEFINE cCausaExEmp 		CHAR(2);
DEFINE cNumCteListNegra CHAR(20);
DEFINE cRetSituacion 	CHAR(1);
DEFINE dPorcentaje 		DECIMAL(6,0);
DEFINE iOfertaProdCred 	INTEGER;
DEFINE iFlagCoppel 		INTEGER;
DEFINE iPonderacion1 	SMALLINT;
DEFINE iPonderacion2 	SMALLINT;
DEFINE iListaNegra		SMALLINT;
DEFINE sCausaCte 		SMALLINT;
DEFINE sRetCausa 		SMALLINT;
DEFINE cNombre			CHAR(104);

--Inicializacion de Variables
LET iSqlErr 			= 0;
LET cCodRet 			='00000';
LET cDato 				= '';
LET cCodRetSP 			='00000';
LET cNomCte1 			= '';
LET cNomCte2 			= '';
LET cApPatCte 			= '';
LET cApMatCte 			= '';
LET cFecNacCte 			= '';
LET cSituacionCte 		= '';
LET sCausaCte 			= 0;
LET dPorcentaje 		= 0;
LET cPorcentajeAutom 	= '';
LET cPorcentajePromo 	= '';
LET cNumCteRefCoinc 	= '';
LET iOfertaProdCred 	= 0;
LET iFlagCoppel 		= 0;
LET iPonderacion1		= 0;
LET iPonderacion2 		= 0;
LET iListaNegra 		= 0;
LET cSituacionExEmp 	= '';
LET cCausaExEmp 		= '';
LET cNumCteListNegra 	= '';
LET cRetSituacion 		= '';
LET sRetCausa 			= 0;
LET cNombre				= '';

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/cristo/sp_evaluacioncomparacionhuellacte.out';
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;	
    SET ISOLATION TO DIRTY READ ;
	
		SELECT valor 
		INTO cPorcentajeAutom
		FROM bdinteg:"informix".si_param 
		WHERE cod_param='160';
		
		SELECT valor 
		INTO cPorcentajePromo
		FROM bdinteg:"informix".si_param  
		WHERE cod_param='161';
		
		LET cNombre = TRIM(pNomCteConc)||' '||TRIM(pNomCte2Conc)||' '||TRIM(pApPatCteConc)||' '||TRIM(pApMatCteConc);
		
--------------INICIA BANCOPPEL---------	
		--Si la empresa en 5 indica que tubo match con cliente BANCOPPEL
		IF pNumCoinc = 1 AND pEmpresaCoinc = '5' THEN 
			IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_cliente WHERE numcte = pNumCteConc AND tipo_cliente='2') THEN --se agrega validacion nueva para matchÂ´s prospectos
				EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
				INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
				IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
					--Codigo de error el cliente necesita aclarar su situacion especial en coppel
					--Muestre mensaje 
					LET cCodRet = '00014';
					RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
				ELSE 
					RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
				END IF;
			END IF;
			--Verificamos si tiene algun parentesco padre-hijo
			EXECUTE PROCEDURE bdinteg:"informix".sp_obtieneparentesco(TRIM(pNumCteBanc),TRIM(pNumCteConc))
			INTO cCodRetSP,cNomCte1,cNomCte2,cApPatCte,cApMatCte,cFecNacCte,cSituacionCte,sCausaCte;
			
			IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
				--Si es 0 entonces no tiene parentesco con un cliente, procedemos hacer la comparacion de nombres
				EXECUTE PROCEDURE bdinteg:"informix".sp_validanombrefn(pNomCteBanc,pNomCte2Banc,pApPatCteBanc, pApMatCteBanc,pFecNacCteBanc, 
																			 cNomCte1 ,cNomCte2 ,cApPatCte ,cApMatCte ,cFecNacCte,0)
				INTO cCodRetSP,dPorcentaje;
				
				IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
					
					--Se guarda porcentaje de similitud
					UPDATE "informix".si_resulcomphuella SET similitud=dPorcentaje WHERE numcte=TRIM(pNumCteBanc);
					
					--El porcentaje es MAYOR o IGUAL a 85 %
					IF dPorcentaje >= CAST(cPorcentajeAutom AS DECIMAL(6,0)) THEN 
						--Actualizamos la situacion a U-3 al nuevo cliente
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',3,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
						
						IF  CAST(cCodRetSP AS INTEGER)  = 0 THEN
							--Modificacion, se asigna la situacion U-3 cuando se ejecuta el SP. DSB 03/12/2013
							--Guardamos en la bitacora 
							EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),'U','3',TRIM(pNumCteConc),cSituacionCte,sCausaCte,pEmpresaCoinc,pSucursal,pNumCajero,1) 
							INTO cCodRetSP;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								--Si tiene alguana de estas situaciones la coincidencia se le avisa al promotor que no puede continuar
								IF (cSituacionCte = 'U' AND sCausaCte IN (59,60)) OR
									(cSituacionCte = 'P' AND sCausaCte IN (29,108)) OR 
									(cSituacionCte = 'F' AND sCausaCte = 42) THEN
									--LLeva un retorno  
										LET cCodRet = '00010'; 
										RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
								ELIF (cSituacionCte = 'T' AND sCausaCte = 97) OR
									 (cSituacionCte = 'U' AND sCausaCte IN( 62,65)) THEN 
									--Muestra mensaje y levanta pantalla coincidencia
									--Al presionar dictaminar levanta mensaje 
										LET cCodRet = '00011'; 
										RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
								ELSE 
									LET cCodRet ='00050'; -- Indica que no cumple con ninguna situacion y causa cuando es >= 85%
									RETURN cCodRet,0,0 ;
								END IF;
							ELSE 
								 RETURN cCodRetSP,0,0 ;
							END IF;
						ELSE 
							RETURN cCodRetSP,0,0 ;
						END IF;
					--El porcentaje es MAYOR o IGUAL a 40% and MENOR a 85%
					ELIF (dPorcentaje >= CAST(cPorcentajePromo AS DECIMAL(6,0))) AND (dPorcentaje < CAST(cPorcentajeAutom AS DECIMAL(6,0))) THEN 
						LET iFlagCoppel = 1;
						IF (cSituacionCte = 'T' AND sCausaCte = 97) OR
							(cSituacionCte = 'U' AND sCausaCte = 62) OR 
							(cSituacionCte = 'P' AND sCausaCte = 35) THEN
							--LLeva retorno y muestra mensaje y no levanta dictamen
							--Muestra coincidencia bancoppel
							--Muestra boton de consulta expediente
							LET cCodRet = '00012'; 
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
						ELSE 
							IF (cSituacionCte = 'U' AND sCausaCte IN ( 60,59)) OR
								(cSituacionCte = 'P' AND sCausaCte IN (108,29)) OR 
								(cSituacionCte = 'F' AND sCausaCte IN (42,43)) THEN
								--LLeva retorno y muestra mensaje y levanta dictamen
								--Muestra coincidencia bancoppel
								--Muestra boton de consulta expediente
								LET cCodRet = '00055'; 
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
							ELSE	
								--Levanta Dictamen y Muestra boton de consulta expediente
								LET cCodRet ='00051'; -- Indica que no cumple con ninguna situacion y causa cuando es >= 40& y < 85%
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred ;
							END IF;	
						END IF;	
					--El porcentaje es MENOR a 40% 
					ELIF (dPorcentaje < CAST(cPorcentajePromo AS DECIMAL(6,0))) THEN 
						--Actualizamos al cliente a una situacion U-62
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',62,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							--Como se actualizo a U-62 no se ofertan productos de credito
							LET iOfertaProdCred = 1;
							--Graba bitacora de comparaciones
							EXECUTE PROCEDURE bdinteg:"informix".sp_bit_comparaciones(TRIM(pNumCteBanc),1,pSucursal,pNumCoinc,pNumCajero,1) 
							INTO cCodRetSP;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								LET cCodRet = '00013';
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
							ELSE 
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;
					END IF;
				ELSE
					 RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;	
				END IF;
			ELIF CAST(cCodRetSP AS INTEGER)  = 1 THEN 
				--Tiene coincidencia padre-hijo y termina proceso
				LET cCodRet = '00009';
				RETURN cCodRet,iFlagCoppel,iOfertaProdCred ;
			END IF;
--------------TERMINA BANCOPPEL---------
		ELIF pNumCoinc = 1 AND pEmpresaCoinc = '4' THEN
--------------INICIA COPPEL-------------
		--Los datos los tomaremos del cliente coincidencia que viene en los parametros 
			EXECUTE PROCEDURE bdinteg:"informix".sp_validanombrefn(pNomCteBanc,pNomCte2Banc,pApPatCteBanc, pApMatCteBanc, 
																		 pFecNacCteBanc ,pNomCteConc ,pNomCte2Conc ,pApPatCteConc ,pApMatCteConc ,pFecNacCteConc,0)
			INTO cCodRetSP,dPorcentaje;
				
			IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
			
				--Se guarda porcentaje de similitud, nombre y fecha de nacimiento del cliente match
				UPDATE "informix".si_resulcomphuella SET similitud=dPorcentaje WHERE numcte=TRIM(pNumCteBanc);
				
				--Se guarda el nombre, fecha de nacimiento y situacion especial del cliente coppel
				UPDATE "informix".si_huella_linea_resultado SET nombre= cNombre,fecha_nac = pFecNacCteConc, situacion=pSitEspCteConc,causa=pCausaCteConc 
				WHERE ticket=(select ticket from bdinteg:"informix".si_huella_linea where numcte=TRIM(pNumCteBanc)) AND num_mensaje ='602' AND empresa = '4';
					
				--El porcentaje es MAYOR o IGUAL a 85 %
				IF dPorcentaje >= CAST(cPorcentajeAutom AS DECIMAL(6,0)) THEN 
					--Validos cliente referencia
					--Que nos retorne el numero de cliente con el que hizo coincidencia
					EXECUTE PROCEDURE bdinteg:"informix".sp_valida_relacion_huella(1,TRIM(pNumCteBanc), TRIM(pNumCteConc), pEmpresa ,pNumCajero, 4, 'Huella en Linea')
					INTO cCodRetSP,cNumCteRefCoinc;					
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										 
						
						--Guardamos en bitacora relaciones 
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_ctes_rel(TRIM(pNumCteBanc), TRIM(cNumCteRefCoinc),NVL(TRIM(pNumCteConc),''),pSucursal,pNumCajero)
						INTO cCodRetSP;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							IF (pSitEspCteConc = 'F' AND pCausaCteConc = 42 ) OR 
								(pSitEspCteConc = 'U' AND pCausaCteConc IN (3,58,59,60)) THEN
								
								--Guardamos en la tabla de dictamenes 
								EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),pSitEspCteBanc,pCausaCteBanc,TRIM(pNumCteConc),pSitEspCteConc,pCausaCteConc,pEmpresaCoinc,pSucursal,pNumCajero,1) 
								INTO cCodRetSP;
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
									INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
									IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										--Codigo de error el cliente necesita aclarar su situacion especial en coppel
										--Muestre mensaje 
										LET cCodRet = '00014';
										RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
									ELSE 
										RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
									END IF;
									
								ELSE
									RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
								END IF;								
							ELIF (pSitEspCteConc = 'P' AND pCausaCteConc IN (9,10,13,18,19,21,49,51,55) ) OR
								(pSitEspCteConc = 'T' AND pCausaCteConc = 16 ) OR
								(pSitEspCteConc = 'V' AND pCausaCteConc = 40 )THEN
									EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
									INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
									IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										--Indica que no se le ofertaran productos de debito
										LET iOfertaProdCred = 2;
										--Muestre mensaje 
										LET cCodRet = '00015';
										RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
									ELSE 
										RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
									END IF;
								
							ELSE
								--No cumple con ninguna de las situaciones anteriores
								--Por lo tanto no tiene problemas para continuar con el registro
								--Actualizamos la situacion a U-65 al nuevo cliente
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
								INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									LET cCodRet = '00052';
									RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
								ELSE 
									RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
								END IF;
								
							END IF;
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;
					ELSE
						RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
					END IF;	
			--El porcentaje es MAYOR o IGUAL a 40% and MENOR a 85%
			ELIF (dPorcentaje >= CAST(cPorcentajePromo AS DECIMAL(6,0))) 
				  AND (dPorcentaje < CAST(cPorcentajeAutom AS DECIMAL(6,0))) THEN	
						
					IF (pSitEspCteConc = 'F' AND pCausaCteConc = 42 ) OR
					   (pSitEspCteConc = 'U' AND pCausaCteConc IN (3,58,59,60) ) THEN 
						--Guardamos bitacora dictamenes 
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),pSitEspCteBanc,pCausaCteBanc,TRIM(pNumCteConc),pSitEspCteConc,pCausaCteConc,pEmpresaCoinc,pSucursal,pNumCajero,1) 
							INTO cCodRetSP;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
								INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									--Codigo de error el cliente necesita aclarar su situacion especial en coppel
									--Muestre mensaje 
									LET iFlagCoppel = 1;
									LET cCodRet = '00016';
									RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
								ELSE 
									RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
								END IF;
							ELSE
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;									
						 
					ELIF (pSitEspCteConc = 'P' AND pCausaCteConc IN (9,10,13,18,19,21,49,51,55) ) OR
						 (pSitEspCteConc = 'T' AND pCausaCteConc = 16 ) OR
						 (pSitEspCteConc = 'V' AND pCausaCteConc = 40 )THEN						
							EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
							INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								--Indica que no se le ofertaran productos de Debito
								LET iOfertaProdCred = 2;
								LET iFlagCoppel = 1;
								--Muestre mensaje 
								LET cCodRet = '00017';
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
							ELSE 
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;
					
					ELSE
						--No cumple con ninguna de las situaciones anteriores
						--Actualizamos la situacion a U-65 al nuevo cliente
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET cCodRet = '00053';
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;		
						
					END IF;
				--El porcentaje es MENO a 40% 	
				ELIF (dPorcentaje < CAST(cPorcentajePromo AS DECIMAL(6,0))) THEN 
					--Actualizamos al cliente a una situacion U-62
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',62,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
						--Como se actualizo a U-62 no se ofertan productos de credito
						LET iOfertaProdCred = 1;
						--Graba bitacora de comparaciones
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_comparaciones(TRIM(pNumCteBanc),1,pSucursal,pNumCoinc,pNumCajero,1) 
						INTO cCodRetSP;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET cCodRet = '00018'; --El proceso continua de forma normal
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;
					ELSE 
						RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
					END IF;
					
				END IF;
			END IF;
--------------TERMINA COPPEL-------------------------------

--------------INICIA EMPLEADO ACTIVO COPPEL----------------
		ELIF pNumCoinc = 1 AND pStatusEmpleado = '0' AND pEmpresaCoinc IN ('0','1','2','3')THEN 
			--Los datos los tomaremos del cliente coincidencia que viene en los parametros 
			EXECUTE PROCEDURE bdinteg:"informix".sp_validanombrefn(pNomCteBanc,pNomCte2Banc,pApPatCteBanc, pApMatCteBanc, 
																		 pFecNacCteBanc ,pNomCteConc ,pNomCte2Conc ,pApPatCteConc ,pApMatCteConc ,pFecNacCteConc,0)
			INTO cCodRetSP,dPorcentaje;
			IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
				
				--Se guarda porcentaje de similitud
				UPDATE "informix".si_resulcomphuella SET similitud=dPorcentaje WHERE numcte=TRIM(pNumCteBanc);
				
				--El porcentaje es MAYOR o IGUAL a 85 %
				IF dPorcentaje >= CAST(cPorcentajeAutom AS DECIMAL(6,0)) THEN 
					--Actualizamos al cliente a una situacion P-23 Por ser Empleado
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'P',23,'M','5',pSucursal,pNumCajero,'','','')
					INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
						--No oferta productos credito
						LET iOfertaProdCred = 1;
						--Guardamos en la tabla de dictamenes 
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),'P',23,TRIM(pNumCteConc),pSitEspCteConc,pCausaCteConc,pEmpresaCoinc,pSucursal,pNumCajero,1) 
						INTO cCodRetSP;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							--Codigo de que el cliente debe continar el registro de forma normal 
							LET cCodRet = '00019';
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
						ELSE
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;	
					ELSE 
						RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
					END IF;	
				--El porcentaje es MENOR a 85%
				ELIF (dPorcentaje < CAST(cPorcentajeAutom AS DECIMAL(6,0))) THEN 
					--Actualizamos al cliente a una situacion U-62
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',62,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
						--Como se actualizo a U-62 no se ofertan productos de credito
						LET iOfertaProdCred = 1;
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_comparaciones(TRIM(pNumCteBanc),1,pSucursal,pNumCoinc,pNumCajero,1) 
						INTO cCodRetSP;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							--Codigo de que el cliente debe continar el registro de forma normal 
							LET cCodRet = '00020';
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;
					ELSE 
						RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
					END IF;
				END IF;	
			ELSE 
				RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
			END IF;
--------------TERMINE EMPLEADO ACTIVO COPPEL----------------
--------------INICIA EX-EMPLEADO COPPEL----------------
		ELIF pNumCoinc = 1 AND pStatusEmpleado = '1' AND pEmpresaCoinc IN ('0','1','2','3') THEN 
			--Validamos si el cte es recontratable  
			--Busacamos al cliente en la lista negra
			IF pEmpresaCoinc = '2' THEN 
				SELECT numcte 
				INTO cNumCteListNegra
				FROM bdiauditor:"informix".tbl_listainterna 
				WHERE numcte = pNumCteConc;
				
				IF DBINFO("sqlca.sqlerrd2") = 1 THEN
					LET iListaNegra = 1;
				END IF;
			END IF;
			--Los datos los tomaremos del cliente coincidencia que viene en los parametros 
			EXECUTE PROCEDURE bdinteg:"informix".sp_validanombrefn(pNomCteBanc,pNomCte2Banc,pApPatCteBanc, pApMatCteBanc, 
																		 pFecNacCteBanc ,pNomCteConc ,pNomCte2Conc ,pApPatCteConc ,pApMatCteConc ,pFecNacCteConc,0)
			INTO cCodRetSP,dPorcentaje;			
			IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
				--Se guarda porcentaje de similitud
				UPDATE "informix".si_resulcomphuella SET similitud=dPorcentaje WHERE numcte=TRIM(pNumCteBanc);
				
				IF dPorcentaje >= CAST(cPorcentajeAutom AS DECIMAL(6,0)) THEN
					--Validamos si la empresa en 2 y si esta en la lista negra						
					IF pEmpresaCoinc = '2' AND  iListaNegra = 1 THEN 																					
						--Actualizamos la situacion especial del cliente bancoppel a lista negra
						EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',60,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET pSitEspCteBanc = 'U';
							LET pCausaCteBanc = 60;
							EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),pSitEspCteBanc,pCausaCteBanc,TRIM(pNumCteConc),pSitEspCteConc,pCausaCteConc,pEmpresaCoinc,pSucursal,pNumCajero,1) 
							INTO cCodRetSP;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								--Indicamos al cliente que no es posible continuar con el proceso
								--Muestra mensaje 
								LET cCodRet = '00021';
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
							ELSE
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;
						ELSE 
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
						END IF;	
							
					ELIF  pEmpresaCoinc <> '2' OR iListaNegra = 0 THEN 
						IF pCausaBaja = '27' OR pCausaBaja = '28' THEN 
							--Evaluamos la poderacion con la causa de baja
							--P-29-->27    F-42--> 28
							IF pCausaBaja = '27' THEN
								LET cSituacionExEmp = 'P';
								LET cCausaExEmp ='29';
							ELIF pCausaBaja = '28' THEN 
								LET cSituacionExEmp = 'F';
								LET cCausaExEmp ='42';
							END IF;								
							--Obtenemos la ponderacion del cliente nuevo 
							EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(3,'','',pSitEspCteBanc,pCausaCteBanc,'','','','','','','')
							INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								--Obtenemos la ponderacion del cliente ex-empleado
								EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(3,'','',cSituacionExEmp,cCausaExEmp,'','','','','','','')
								INTO cCodRetSP,iPonderacion2,cRetSituacion,sRetCausa;
								IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
									IF iPonderacion1 >= iPonderacion2 THEN
										IF cCausaExEmp = '42' THEN 
											LET pSitEspCteBanc = 'F';
											LET pCausaCteBanc = '43';
										END IF;			
										
										IF cSituacionExEmp = 'P' AND cCausaExEmp = '29' THEN 
											LET pSitEspCteBanc = 'P';
											LET pCausaCteBanc = '29';
										END IF;	
										
										EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),pSitEspCteBanc,pCausaCteBanc,'M','5',pSucursal,pNumCajero,'','','')
										INTO cCodRetSP,iPonderacion2,cRetSituacion,sRetCausa;
										
									ELSE
										LET cCodRetSP = "00000";
									END IF;
									
									IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
										EXECUTE PROCEDURE bdinteg:"informix".sp_bit_dictamenes(TRIM(pNumCteBanc),pSitEspCteBanc,pCausaCteBanc,TRIM(pNumCteConc),cSituacionExEmp,cCausaExEmp,pEmpresaCoinc,pSucursal,pNumCajero,1) 
										INTO cCodRetSP;
										IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
											--Indicamos al cliente que no es posible continuar con el proceso
											LET cCodRet = '00022';
											RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
										ELSE
											RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
										END IF;
									ELSE 
										RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
									END IF;	
								ELSE 
									RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
								END IF;			
							ELSE 
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;		
						ELSE 
							--Continua con el flujo normal 
							EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',65,'M','5',pSucursal,pNumCajero,'','','')
							INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
							IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
								LET cCodRet = '00056';
								RETURN cCodRet,iFlagCoppel,iOfertaProdCred;	
							ELSE 
								RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
							END IF;

						END IF;		
					END IF;
				ELIF dPorcentaje < CAST(cPorcentajeAutom AS DECIMAL(6,0)) THEN	
					--Actualizamos al cliente a una situacion U-62
					EXECUTE PROCEDURE bdisitesp:"informix".sp_insertasitesp(2,pEmpresa,TRIM(pNumCteBanc),'U',62,'M','5',pSucursal,pNumCajero,'','','')
						INTO cCodRetSP,iPonderacion1,cRetSituacion,sRetCausa;
					--No oferta productos credito
					LET iOfertaProdCred = 1;
					IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
						--Guardar en la bitacora de comparaciones 
						EXECUTE PROCEDURE bdinteg:"informix".sp_bit_comparaciones(TRIM(pNumCteBanc),1,pSucursal,pNumCoinc,pNumCajero,1) 
						INTO cCodRetSP;
						IF CAST(cCodRetSP AS INTEGER)  = 0 THEN
							LET cCodRet = '00023';
							RETURN cCodRet,iFlagCoppel,iOfertaProdCred;
						ELSE
							RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;	
						END IF;	
					ELSE
						RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
					END IF;
				END IF;	
			ELSE 
				RETURN cCodRetSP,iFlagCoppel,iOfertaProdCred;
			END IF;
--------------TERMINA EX-EMPLEADO COPPEL----------------			
		END IF;	
	RETURN cCodRet,iFlagCoppel,iOfertaProdCred ;		
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea Procedimiento Almacenado para realizar la evaluaciÃÂ³n de la comparacion de la huella en lÃÂ­nea del cliente',
'AUTOR : Eduardo Lopez',
'FECHA : 18/09/2013',
'VERSION: 20130918',
'BD: BDINTEG',

'Folio: 1571',
'Autor: 95584315',
'Fecha: 03/12/2013',
'ModificaciÃÂ³n: Se modifica SP en linea 133 donde asigna la situacion y causa como valores fijos U-3',
'Sustento: HomologarEvaluaciÃÂ³nDeHuellasEnPiloto',
'Solicita: Manuel Osuna',
'BD: BDINTEG',

'Folio: 1571',
'Autor: 93111207',
'Fecha: 05/12/2013',
'ModificaciÃÂ³n: Se modifica SP en la linea 449, se cambian unos campos en la ejecucion de el sp_bit_dictamenes',
'Sustento: HomologarEvaluaciÃÂ³nDeHuellasEnPiloto',
'Solicita: Manuel Osuna',
'BD: BDINTEG',

"AUTOR: Jaret Antonio Ramirez",
"DESCRIPCION: RQI 63 784 (AtenciÃ³n RQM 06 705) nuevas reglas para marcado de clientes con U 65",
"FECHA: 2022-04-25",
"BD: bdinteg ";

CREATE PROCEDURE "informix".sp_traslada_boletos_renueva2013(p_cve_sorteo CHAR(5), p_fecha_pase DATE)
RETURNING CHAR(5)  AS Codigo_retorno, 
          CHAR(80) AS Mensaje,
          CHAR(1)  AS Reverso,
          CHAR(60) AS StorePro;              
               
    DEFINE vsqlerr            INTEGER; 
    DEFINE v_codigo_retorno	  CHAR(5);
    DEFINE v_mensaje	  	    CHAR(80);
    DEFINE v_reverso          CHAR(1);
    DEFINE v_store_pro        CHAR(60);
    DEFINE vrowid             INTEGER;
    DEFINE vd_valida          DATE;
    DEFINE vd_fecha2          DATE;
    DEFINE vd_fsorteo         DATE;
    DEFINE vc_cvesorteo       INTEGER;

    --SET debug file TO "/informix/raul/renueva2013/traslada_boletos.out";
    --TRACE ON;

    LET v_codigo_retorno = "00000";
    LET v_mensaje = "Proceso Inicia Correctamente";
    LET v_reverso = '0';
    LET v_store_pro = 'sp_traslada_boletos_renueva2013';
    LET vrowid     = 0;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr          
        IF vsqlerr <> 0 THEN         
            LET v_codigo_retorno = "00045";
            LET v_mensaje = "Se Genero Error de Exception, Verifique Datos SQL!";
            LET v_reverso = '1';         
            LET v_store_pro = v_store_pro;
            RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
        END IF;
    END EXCEPTION;
/*VALIDA QUE LA BANDERA DEL CONCURSO 00002 SEA 1*/
    
    
    IF EXISTS (SELECT {+index (si_sorteo idx_si_sorteo_cve)} flag_sort
                     FROM bdinteg:si_sorteo 
                    WHERE cve_sorteo = p_cve_sorteo AND flag_sort = 1 AND p_fecha_pase BETWEEN f_ini AND f_fin) THEN
       			
				        --*********************************************************--
						-- Creado por: RaÃºl Ramirez Galindo	
						--Fecha Creacion: 23/ABRIL/2013
						--Objetivo: Traspasa los boletos generados diariamente y 
						--   los envia a la tabla historica Sorteo Renueva 2013.    
						--*********************************************************--
						
						IF (NVL(p_fecha_pase,'') = '') THEN
							LET v_codigo_retorno = "00030";
							LET v_mensaje = "Se genero error de Ejecucion, Verifique Fecha Nula!";
							LET v_reverso = '1';
							LET v_store_pro = v_store_pro;
							RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
						END IF;
						
						SELECT LIMIT 1 DATE(f_registro)
						  INTO vd_fsorteo
						  FROM si_boleto_hist
						 WHERE DATE(f_registro) = p_fecha_pase;

						IF vd_fsorteo = p_fecha_pase THEN
							LET v_codigo_retorno = "00040";
							LET v_mensaje = "Ya existen registros en la historica";
							LET v_reverso = '1';
							LET v_store_pro = v_store_pro;
							RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
						END IF;


						/*FOREACH cursor_inserta WITH HOLD FOR
							SELECT  {+index (si_boleto idx_si_boleto_cte)} rowid
							INTO vrowid            
							FROM bdinteg:"informix".si_boleto
							WHERE date(f_registro) = p_fecha_pase 
							AND numcte <> ''
							
							BEGIN WORK;
							
							INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
							bdinteg:"informix".si_boleto_hist
							SELECT {+index (si_boleto idx_si_boleto_cte)} *
							FROM bdinteg:"informix".si_boleto
							WHERE rowid = vrowid;                                                                 
						
							COMMIT WORK;                           
						END FOREACH;*/
						

                        INSERT INTO --{+index (si_boleto_hist idx_si_boleto_hist)} 
						bdinteg:"informix".si_boleto_hist
						SELECT {+index (si_boleto idx_si_boleto_cte)} *
						FROM bdinteg:"informix".si_boleto
						WHERE fecha = p_fecha_pase;  

						----  BORRA LA INFORMACION DE LA TABLA
						BEGIN;
						TRUNCATE TABLE "informix".si_boleto;
						COMMIT;
	
	ELSE
						LET v_codigo_retorno = "22222";
						LET v_mensaje = "Â¡EL CONCURSO NORMAL NO ESTA ACTIVO!";
						LET v_reverso = '1';
						LET v_store_pro = v_store_pro;                 
       
    
	

	END IF;					
						
						
						
    RETURN v_codigo_retorno, v_mensaje, v_reverso, v_store_pro;
 END;   
END PROCEDURE
DOCUMENT
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃ?N: 15 ABRIL DE 2015',
'OBJETIVO: SE CAMBIA EL CÃ?DIGO DE RETORNO DE 00040 A',
'          22222 EN CASO DE QUE EL CAMPO cve_sorteo SEA',
'          DIFERENTE A 00002 PARA QUE SEA UNA SALIDA',
'          CONTROLADA Y NO LLEGUE E-MAIL DE CONTROL-M',
'BD: BDINTEG',
'MODIFICADO POR: ISRAEL FLORES GONZÃLEZ',
'FECHA DE MODIFICACIÃ?N: 27 MAYO DE 2015',
'OBJETIVO: SE CAMBIA LA BUSQUDEDA EN LA TABLA si_sorteo',
'          PARA QUE LA CONDICION VALIDE SI EXITE EN ESA TABLA',
'          EL CONCURSO 00002 Y LA BANDERA SEA 1, EN CASO DE',
'          NO EXISTIR MANDE EL CODIGO DE RETORNO 22222',
'          PARA QUE SEA UNA SALIDA CONTROLADA Y NO LLEGUE E-MAIL',
'          DE CONTROL-M',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online_pba(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
pap_nombre1        	CHAR(26),
pap_nombre2        	CHAR(26),
pap_apell_paterno  	CHAR(26),
pap_apell_materno  	CHAR(26),
pap_sexo           	CHAR(1),
pap_fecha_nac      	CHAR(10),
pap_rfc            	CHAR(13),
pemail             	CHAR(100),
ptelefono_casa     	CHAR(10),
ptelefono          	CHAR(10),
pcarrier           	CHAR(1),
ppais_nac          	CHAR(3),
pap_cod_postal     	CHAR(5),
pap_id_estado         	CHAR(2),
pap_id_ciudad         	CHAR(3),
pap_id_colonia        	CHAR(10),
pap_id_municipio      	CHAR(5),
pap_id_calle          	CHAR(40),
pnumero_exterior	CHAR(10),
pnumero_interior	CHAR(10),
pentre_calles		CHAR(40),
pcomplemento		CHAR(80),
ptarjeta_de_credito_activa	CHAR(1),
pultimos_cuatro_digitos	CHAR(4),
pcredito_hipotecario	CHAR(1),
pcredito_automotriz		CHAR(1),
pfirma_buro        	CHAR(1),
pescolaridad       	CHAR(2),
pestado_civil       CHAR(1),
ptpo_edo_civil     	CHAR(2),
pmeses_edo_civil   	CHAR(2),
ptipo_residencia   	CHAR(1),
ptiempo_domicilio  	CHAR(2),
ppers_domicilio    	CHAR(2),
ppers_trabajan     	CHAR(2),
ppers_dependen     	CHAR(2),
pempresa           	CHAR(60),
ptiempo_trabajo    	CHAR(2),
ptiempo_trab_ant   	CHAR(2),
pactividad         	CHAR(2),
psubactividad      	CHAR(2),
pnivel_ingresos    	CHAR(8),
ptel_trabajo       	CHAR(10),
pprimer_nombre_referencia	CHAR(26),
psegundo_nombre_referencia	CHAR(26),	
pprimer_apellido_referencia	CHAR(26),
psegundo_apellido_referencia	CHAR(26),
pfecha_de_nacimiento_referencia	DATE,
pgenero_referencia				CHAR(1),
pparentesco_referencia			CHAR(2),
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pnumero_control         	CHAR(25),
pfecha_hora        	DATETIME YEAR to FRACTION(5)
)

    RETURNING 
          CHAR(4)       as vcodret1,
		  CHAR(120)     as vmsjresp,
		  CHAR(2)       as vcodsolbcpl,
		  CHAR(40)      as vdescsolbcpl,
		  CHAR(255)     as vmotivobcpl,
		  CHAR(4)       as vproductobcpl,
		  CHAR(20)      as vfoliobcpl,
		  CHAR(2)       as vcodsolcpl,
		  CHAR(40)      as vdescsolcpl,
		  CHAR(255)     as vmotivocpl,
		  CHAR(4)       as vproductocpl,
		  CHAR(20)      as vfoliocpl;
         
    DEFINE vcodret1 CHAR(4);
	DEFINE vmsjresp CHAR(120);
	DEFINE vcodsolbcpl CHAR(2);
	DEFINE vdescsolbcpl CHAR(40);
	DEFINE vmotivobcpl CHAR(255);
	DEFINE vproductobcpl CHAR(4);
	DEFINE vfoliobcpl CHAR(20);
	DEFINE vcodsolcpl CHAR(2);
	DEFINE vdescsolcpl CHAR(40);
	DEFINE vmotivocpl CHAR(255);
	DEFINE vproductocpl CHAR(4);
	DEFINE vfoliocpl CHAR(20);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = 'PA';
	LET vdescsolbcpl = 'Pre autorizada';
	LET vmotivobcpl = '';
	LET vproductobcpl = '6001';
	LET vfoliobcpl = '11111111';
	LET vcodsolcpl = 'PA';
	LET vdescsolcpl = 'Pre autorizada';
	LET vmotivocpl = '';
	LET vproductocpl = '6500';
	LET vfoliocpl = '55555555';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_alta_solicitud_movil_online.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vmsjresp = isam_err;
				--LET vmsjresp = desc_err;
				RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
			END IF;
		END EXCEPTION;

		SET DEBUG FILE TO "/tmp/sp_alta_solicitud_movil_online.out";
		TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO informix.si_solicitud_movil_online(productos, numcte, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref, tel_celular_ref, ejecutivo, numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,ptelefono_celular_referencia,pejecutivo,pnumero_control,pfecha_hora);

		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
	END;
	
END PROCEDURE;