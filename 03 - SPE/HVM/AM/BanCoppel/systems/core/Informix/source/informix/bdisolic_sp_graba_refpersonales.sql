CREATE PROCEDURE "informix".sp_graba_refpersonales (pEmpresa CHAR(3),
													pNumSol CHAR(20),
													pNumSolCapturada CHAR(20),
													pNumCte CHAR(20), 
													pReferencia CHAR(20), 
													pNombreRef CHAR(104), 
													pParentesco CHAR(2), 
													pTelefono  CHAR(13),
													pOpcion  CHAR(1),
													pSecuencia INTEGER)	
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(100) AS descodret,
				CHAR(1) AS valida_num_referencias,
				CHAR(104) AS Nombreref,
				CHAR(25)	AS parentesco,
				CHAR(13)	AS Telsolcap,
				CHAR(12) AS Secuencia;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          					INTEGER;
	DEFINE cCodRet           				CHAR(5);
	DEFINE cdesc_codret					CHAR(100);
	DEFINE cNumCliente         			CHAR(20);
	DEFINE cValidaReferencias 		CHAR(1);
	DEFINE iCont								INTEGER;
	DEFINE cNom_ref 						CHAR(104);
	DEFINE cparentesco 					CHAR(25);	
	DEFINE ctel_ref 							CHAR(13);
	DEFINE i 									INTEGER;
	DEFINE iContador 						INTEGER;
	DEFINE sCampo_cadena 			CHAR(20);
	DEFINE cnomcliente1 					CHAR(20);
	DEFINE cnomcliente2 					CHAR(20);
	DEFINE capellpatcliente 				CHAR(20);
	DEFINE capellmatcliente 			CHAR(20);
	DEFINE cNumClienteRef				CHAR(20);
	DEFINE iSecuencia						INTEGER;
	DEFINE cSecuencia					CHAR(12);
	DEFINE cdescripcion					CHAR(20);
	DEFINE cNombreref					CHAR(104);
	DEFINE cregistroActualizado 	    INTEGER;
	DEFINE cnombrecteobl                CHAR(104);
	DEFINE fechanacteobl					DATE;
	DEFINE cfechanac_ref				DATE;
	DEFINE dMontoSolicitud				DECIMAL(18,2);
	DEFINE cnumsolTit						CHAR(20);
	DEFINE cNumSolic						CHAR(20);
	DEFINE cNumClienteRefAnt			CHAR(20);
	
	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cdesc_codret           		= '';
	LET cNumCliente            		= '';
	LET cValidaReferencias    		= '';
	LET iCont								= 0;
	LET cNom_ref						= '';
	LET cparentesco						= '';
	LET ctel_ref 							= '';
	LET i 									= 0;
	LET iContador 						= 0;
	LET sCampo_cadena 			    = '';
	LET cnomcliente1 					= '';
	LET cnomcliente2 					= '';
	LET capellpatcliente 				= '';
	LET capellmatcliente 			    = '';
	LET cNumClienteRef				= '';
	LET iSecuencia						= 0;
	LET cdescripcion					= '';
	LET cNombreref						= '';
	LET cSecuencia						= '';
	LET cregistroActualizado 	    = 0;
	LET cnombrecteobl                 = '';
	LET fechanacteobl					= DATE(1);
	LET cfechanac_ref					= DATE(1);
	LET dMontoSolicitud				= 0.00;
	LET cnumsolTit						= '';
	LET cNumSolic						= '';
	LET cNumClienteRefAnt			= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
		END EXCEPTION;
	
		--SET DEBUG FILE TO '/tmp/sp_graba_refpersonales.out'; 
		--TRACE ON;		

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF NVL(pEmpresa,'') = '' OR NVL(pNumSol,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pReferencia,'') = '' OR (NVL(pNombreRef,'') = ''
				AND NVL(pParentesco,'') = '' AND NVL(pTelefono,'') = ''  AND NVL(pOpcion,'') NOT IN ('4','5')) OR NVL(pOpcion,'') = '' THEN
				LET cCodRet = '00001';
				LET cdesc_codret = 'Faltan parÃ¡metros de Entrada';
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;	
		END IF;
		
		IF pOpcion = '1' THEN
		
			   For i = 1 To Length(pNombreRef) STEP 1
				 --Recorre la cadena leÃ­da del nombre de referencia y se divide en 4 campos
				 If substr(pNombreRef, i, 1) = " " Then
					LET iContador = iContador + 1;
					IF substr(pNombreRef, i-1, 1) = " " THEN
						LET sCampo_cadena = " ";
					END IF;
					If iContador= 1 THEN
						LET cnomcliente1 = sCampo_cadena;
						LET cnomcliente1 = cnomcliente1;
					Elif iContador= 2 THEN
						LET cnomcliente2 = sCampo_cadena;
						LET cnomcliente2 = cnomcliente2;
					Elif iContador= 3 THEN
						LET capellpatcliente = sCampo_cadena;
						LET capellpatcliente = capellpatcliente;
					End if
					LET sCampo_cadena = "";
				 Else
					LET sCampo_cadena = TRIM(sCampo_cadena) || substr(pNombreRef, i, 1);
					If i = Length(pNombreRef) AND capellpatcliente <> '' THEN
						LET capellmatcliente = sCampo_cadena;
					Else
						IF i = Length(pNombreRef) THEN
							LET capellpatcliente = sCampo_cadena;
						END IF;
					End if;

				 End If;

				END FOR;		
						
			--Se valida que el obligado no sea el mismo del titular
			SELECT count(a.numcte) INTO iCont
			FROM bdinteg:si_cliente a 
			INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.rfc = b.rfc AND b.secuencia = pSecuencia)
			WHERE a.empresa =pEmpresa
			AND TRIM(a.nombre1) = TRIM(b.nombre1) AND TRIM(a.nombre2) = TRIM(b.nombre2) AND  TRIM(a.apell_paterno) = TRIM(b.apell_paterno) AND TRIM(a.apell_materno)=TRIM(b.apell_materno) 
			AND a.numcte = pNumCte ;			
		
			IF iCont > 0 THEN							
				LET cCodRet = '01296';
				LET cdesc_codret = 'El nombre del titular no puede ser el mismo Obligado Solidario';
				SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
				IF iCont > 0 THEN
						DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
				END IF;
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
			END IF;				
			
			--Se valida si el cliente ya es obligado solidario de este prÃ©stamo activo		
			SELECT count(a.num_solicitud) INTO iCont 
			FROM bdisolic:ss_refpersonales a
            INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
			WHERE a.empresa =pEmpresa
            AND a.numcte = pNumCte AND a.num_solicitud =pNumSol AND a.numcte_ref like 'R3%' 
			AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) 
			AND a.nombre_ref = pNombreRef
			--AND a.parentesco = pParentesco
			AND b.secuencia <> pSecuencia
			AND a.numcte_ref <> pReferencia;
			
			IF iCont >= 1 THEN				
			
				SELECT count(num_solicitud) INTO iCont FROM bdisolic:ss_refpersonales  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND numcte_ref = pReferencia;
				IF substr(pReferencia,11,1) <> "1" OR (substr(pReferencia,11,1) = "1" AND iCont > 0)THEN
					
					IF iCont = 0 THEN 					
						LET cCodRet = '01295';
						LET cdesc_codret = 'El cliente ya se encuentra registrado, favor de verificar';		
						SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
						IF iCont > 0 THEN
								DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol  AND secuencia = pSecuencia ;					
						END IF;	
					ELSE 
						SELECT a.nombre_ref,a.parentesco,a.telefono_ref, b.fecha_nac 
						INTO cNom_ref,cparentesco,ctel_ref, fechanacteobl
						FROM bdisolic:ss_refpersonales a
						INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
						WHERE a.empresa =pEmpresa
						AND a.numcte = pNumCte AND a.num_solicitud =pNumSol AND a.numcte_ref like 'R3%' 
						AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) 
						AND a.nombre_ref = pNombreRef
						--AND a.parentesco = pParentesco						
						AND b.secuencia <>pSecuencia
						AND a.numcte_ref <> pReferencia;
						
						SELECT fecha_nac INTO cfechanac_ref FROM bdinteg:si_refclientes WHERE numcte =pNumCte  AND num_solicitud =pNumSol  AND secuencia = pSecuencia ;
							
						IF cNom_ref = pNombreRef AND cparentesco = pParentesco AND fechanacteobl = cfechanac_ref THEN
							LET cCodRet = '01295';
							LET cdesc_codret = 'El cliente ya se encuentra registrado, favor de verificar';		
							IF iCont > 0 THEN
									DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;		
									DELETE FROM bdisolic:ss_refpersonales  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND numcte_ref = pReferencia;
							END IF;								
						END IF;
					END IF;
				END IF;
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;				
			END IF;			
			
			--Se valida si el cliente ya es obligado solidario de otro prÃ©stamo activo		
			SELECT count(a.numcte) INTO iCont 
			FROM bdisolic:ss_refpersonales a
            INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
			WHERE a.empresa =pEmpresa
			AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) 
			AND a.nombre_ref = pNombreRef
			AND a.numcte <> pNumCte AND a.numcte_ref like 'R3%' 
            AND a.num_solicitud IN (SELECT num_solicitud FROM bdisolic:ss_solicitudes 
                                    WHERE empresa = pEmpresa AND a.numcte = numcte AND num_solicitud = a.num_solicitud  
                                    AND status_solicitud NOT IN ('PC','AN','CN'));			
			
			IF iCont >= 1 THEN					
				
				LET cCodRet = '01295';
				LET cdesc_codret = 'El cliente ya es obligado solidario en otro prÃ©stamo activo';		
				SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
				IF iCont > 0 THEN
						DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
				END IF;				
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;				
			END IF;	
			
			--No debe de permitir que un cliente que tenga el crÃ©dito (tu moto activo) sea obligado solidario.
				SELECT count(a.numcte)
				INTO iCont 
				FROM bdinteg:si_cliente a
				INNER JOIN bdinteg:si_telefonos_actual b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND b.telefono = pTelefono AND b.status_tel='A')
				WHERE a.apell_paterno = capellpatcliente AND a.apell_materno = capellmatcliente AND a.nombre1 = cnomcliente1 AND a.nombre2 = NVL(cnomcliente2,' ') ;	
			
				IF iCont >= 1 THEN
					SELECT a.numcte
					INTO cNumClienteRef 
					FROM bdinteg:si_cliente a
					INNER JOIN bdinteg:si_telefonos_actual b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND b.telefono = pTelefono AND b.status_tel='A')
					WHERE a.apell_paterno = capellpatcliente AND a.apell_materno = capellmatcliente AND a.nombre1 = cnomcliente1 AND a.nombre2 = NVL(cnomcliente2,' ') ;	
					
					SELECT count(numcte) INTO iCont  FROM bdisolic:"informix".ss_solicitudes WHERE numcte = cNumClienteRef AND num_producto IN ('9100', '9300') AND status_solicitud IN('BC','MC','OS','EE','AT','AP');
					
					IF iCont >= 1 THEN
						LET cCodRet = '01297';
						LET cdesc_codret = 'El cliente ya cuenta con un prÃ©stamo activo, por lo que no puede ser obligado solidario';	
						SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
						IF iCont > 0 THEN
								DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = pSecuencia ;
						END IF;						
						RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;				
					END IF;
				END IF;
	
			--Se valida si existe el registro de obligados para ver si actualiza o inserta.		
			SELECT COUNT(numcte_ref) INTO iCont FROM bdisolic:"informix".ss_refpersonales 
			WHERE empresa =pEmpresa AND num_solicitud = pNumSol AND numcte_ref=pReferencia; --AND nombre_ref = pNombreRef;				

			IF iCont >= 1  THEN	
					SELECT b.secuencia,a.nombre_ref,a.parentesco,a.telefono_ref 
					INTO iSecuencia,cNom_ref,cparentesco,ctel_ref
					FROM bdisolic:ss_refpersonales a
					INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)
					WHERE a.empresa =pEmpresa
					AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) 
					AND a.numcte =pNumCte AND a.num_solicitud =pNumSol AND a.numcte_ref =pReferencia AND b.secuencia = pSecuencia;
					
					IF NVL(iSecuencia,'') = '' AND NVL(pSecuencia,'') <> '' THEN
						SELECT b.secuencia,a.nombre_ref,a.parentesco,a.telefono_ref 
						INTO iSecuencia,cNom_ref,cparentesco,ctel_ref
						FROM bdisolic:ss_refpersonales a
						INNER JOIN bdinteg:si_refclientes b	ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud)	
						WHERE a.empresa = pEmpresa AND a.numcte =pNumCte AND a.num_solicitud =pNumSol AND a.numcte_ref =pReferencia AND b.secuencia = pSecuencia;
					END IF;
									
						--Actualiza la referencia de obligado solidario
						IF NVL(ctel_ref,'') <> pTelefono THEN
							SELECT count(num_solicitud) INTO iCont FROM bdisolic:ss_refpersonales  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND telefono_ref = pTelefono AND numcte_ref <> pReferencia;
							
							IF iCont = 0 THEN 
								SELECT count(nombre_ref) INTO iCont FROM bdisolic:ss_refpersonales  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND telefono_ref = pTelefono AND numcte_ref <> pReferencia;
								IF iCont <> 0  AND iSecuencia <>  pSecuencia THEN
									LET cCodRet = '01307';
									LET cdesc_codret = 'El telefono no puede ser el mismo que el de las referencias';
									SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND parentesco=pParentesco AND secuencia = pSecuencia ;
									IF iCont > 0 THEN
											DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND parentesco=pParentesco AND secuencia = pSecuencia ;
									END IF;										
									RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
								END IF;
							ELSE
								IF iCont <> 0  AND iSecuencia <>  pSecuencia THEN
									LET cCodRet = '01307';
									LET cdesc_codret = 'El telefono no puede ser el mismo que el de las referencias';
									SELECT count(num_solicitud) INTO iCont FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND parentesco=pParentesco AND secuencia = pSecuencia ;
									IF iCont > 0 THEN
											DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND parentesco=pParentesco AND secuencia = pSecuencia ;										
									END IF;	
									RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
								END IF;
							END IF;
							UPDATE bdisolic:ss_refpersonales SET telefono_ref = pTelefono WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND numcte_ref =pReferencia;
									
							--UPDATE bdinteg:si_refclientes SET telefono_ref= ctel_ref WHERE  secuencia = cSecuencia;								
						END IF;							
						IF NVL(cNom_ref,'') <> pNombreRef THEN
							UPDATE bdisolic:ss_refpersonales SET nombre_ref = pNombreRef WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND numcte_ref =pReferencia;						
									
							UPDATE bdinteg:si_refclientes SET nombre1= cnomcliente1, nombre2= cnomcliente2,apell_paterno=capellpatcliente, apell_materno= capellmatcliente WHERE  secuencia = pSecuencia;								
						
						END IF;
						IF NVL(cparentesco,'') <> pParentesco THEN
							UPDATE bdisolic:ss_refpersonales SET parentesco = pParentesco WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND numcte_ref =pReferencia;
									
							UPDATE bdinteg:si_refclientes SET parentesco= pParentesco WHERE  secuencia = pSecuencia;							
						END IF;

			ELSE
					--Graba la referencia de obligado solidario
					INSERT INTO  bdisolic:"informix".ss_refpersonales
							(empresa, num_solicitud, numcte, numcte_ref, tipo_relacion,
							 nombre_ref, parentesco, telefono_ref)
					VALUES  (pEmpresa, pNumSol, pNumCte, pReferencia, "02",
							pNombreRef , pParentesco, pTelefono);
			END IF;
					
			RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
		END IF;
		
		IF pOpcion = '2' THEN
			--Se actualiza el registro de la tabla bdinteg:si_refclientes en el campo numcte_ref.
			SELECT numcte
			INTO cNumCliente
			FROM bdisolic:ss_solicitudes WHERE num_solicitud = pNumSolCapturada AND status_solicitud NOT IN ('RT','PC','AN') AND num_producto IN('9100','9300');
			
			IF (Substr(pNumSol,1,4) = '9200'  AND Substr(pNumSolCapturada,1,4) = '9100' ) OR  (Substr(pNumSol,1,4) = '9400'  AND Substr(pNumSolCapturada,1,4) = '9300' ) THEN
				IF NVL(cNumCliente,'') <> '' THEN
	
					SELECT count(a.numcte)
					INTO iCont
                    FROM bdisolic:"informix".ss_refpersonales a 
                    INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte  AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
                    WHERE a.empresa =pEmpresa AND a.num_solicitud = pNumSolCapturada AND  a.numcte = cNumCliente AND  a.numcte_ref like 'R3%' ;
					
					IF iCont >= 1 THEN
						FOREACH
							SELECT b.secuencia,a.nombre_ref,a.parentesco,a.telefono_ref, b.fecha_nac
							INTO iSecuencia,cNom_ref,cparentesco,ctel_ref, cfechanac_ref		
							FROM bdisolic:"informix".ss_refpersonales a 
							INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
							WHERE a.empresa =pEmpresa AND a.num_solicitud = pNumSolCapturada AND a.numcte = cNumCliente AND a.numcte_ref like 'R3%' 

							SELECT TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) as nom_ref, a.fecha_nac
							INTO cnombrecteobl, fechanacteobl
							FROM bdinteg:si_ctepf a
							INNER JOIN bdinteg:si_cliente b ON (a.empresa = b.empresa AND a.numcte = b.numcte)
							WHERE a.numcte = pNumCte;
							
							IF TRIM(cnombrecteobl) = TRIM(cNom_ref) AND fechanacteobl= cfechanac_ref THEN
								UPDATE bdinteg:"informix".si_refclientes 
								SET numcte_ref = pNumSol, numcte_banco = pNumCte
								WHERE empresa = pEmpresa
								AND numcte = cNumCliente
								--AND numcte_banco = pNumCte
								AND num_solicitud = pNumSolCapturada
								AND secuencia = iSecuencia;
								
								LET cregistroActualizado = 1;
							END IF;
						END FOREACH;
						IF cregistroActualizado = 0 THEN
								LET cCodRet = '01298';
								LET cdesc_codret = 'El nÃºmero de la solicitud no corresponde al Prestamo Titular solicitado';	
								RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
						ELSE 
							RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
						END IF;				
					ELSE 
						LET cCodRet = '01298';
						LET cdesc_codret = 'El nÃºmero de la solicitud no corresponde al Prestamo Titular solicitado';			
						RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;					
					END IF;
				ELSE
					SELECT count(numcte)
					INTO iCont
					FROM bdisolic:ss_solicitudes WHERE num_solicitud = pNumSolCapturada AND status_solicitud IN ('RT','PC','AN') AND num_producto IN('9100','9300');
					IF iCont >= 1 THEN
						LET cCodRet = '01301';
						LET cdesc_codret = 'La solicitud capturada se encuentra rechazada o cancelada';
						RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
					ELSE 
						LET cCodRet = '01302';
						LET cdesc_codret = 'La solicitud capturada no existe ';
						RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
					END IF;
				END IF;
			ELSE 
				LET cCodRet = '01298';
				LET cdesc_codret = 'El nÃºmero de la solicitud no corresponde al Prestamo Titular solicitado';			
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
			END IF;
		END IF;
		
		IF pOpcion = '3' THEN
		
			IF Substr(pNumSol,1,4) IN ('9100','9300') THEN
				--Se valida que el registro de la tabla bdisolic:"informix".ss_refpersonales en el campo numcte_ref no se encuentre mas de 3 veces como referencia de acreditado.		
				SELECT COUNT(numcte_ref) INTO iCont  
				FROM bdisolic:"informix".ss_refpersonales
				WHERE empresa = pEmpresa AND num_solicitud = pNumSolCapturada AND numcte_ref like 'R3%'  AND tipo_relacion ='02';			
				--Se valida si ya existen 3 registro de obligados, si es asÃ­ devuelve mensaje y no deja continuar
				IF iCont >= 3 THEN
					LET cValidaReferencias = '1';
					LET cCodRet = '01299';
					LET cdesc_codret = 'La solicitud ya cuenta con 3 obligados capturados';						
				ELSE
					LET cValidaReferencias = '0';
				END IF;
			END IF;

			RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
		END IF;
		IF pOpcion = '4' THEN
			--Se valida si ya existe el registro de obligados los retorna para mostrar en el grid en automatico.		
			SELECT COUNT(numcte_ref) INTO iCont FROM bdisolic:"informix".ss_refpersonales WHERE empresa =pEmpresa AND num_solicitud = pNumSol AND numcte_ref like 'R3%' ;
			IF iCont > 0 THEN
				FOREACH
					SELECT a.nombre_ref, a.parentesco, a.telefono_ref, b.secuencia, a.numcte_ref
					INTO cNom_ref,cparentesco,ctel_ref, iSecuencia, cNumClienteRef			
					FROM bdisolic:"informix".ss_refpersonales a 
					INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.num_solicitud = b.num_solicitud AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
					WHERE a.empresa =pEmpresa AND a.num_solicitud = pNumSol  AND a.numcte_ref like 'R3%' 	
					ORDER BY a.numcte_ref,b.secuencia
					
					LET cSecuencia = iSecuencia::CHAR(12);					
					
					IF cNumClienteRefAnt = cNumClienteRef THEN
						DELETE FROM bdinteg:si_refclientes  WHERE numcte =pNumCte  AND num_solicitud =pNumSol AND secuencia = iSecuencia ;
						SELECT COUNT(numcte_ref) INTO iCont FROM bdisolic:"informix".ss_refpersonales WHERE empresa =pEmpresa AND num_solicitud = pNumSol AND numcte_ref = cNumClienteRef;
						--IF iCont = 1 THEN
						--	DELETE FROM bdisolic:"informix".ss_refpersonales WHERE empresa =pEmpresa AND num_solicitud = pNumSol AND numcte_ref = cNumClienteRef;
						--END IF;
						CONTINUE FOREACH;
					END IF;

					SELECT descripcion INTO  cdescripcion
					FROM bdinteg:"informix".si_parentesco WHERE empresa = pEmpresa AND parentesco = cparentesco;
					
					LET cparentesco = TRIM(cparentesco) || " " || TRIM(cdescripcion) ;
					
					LET cNumClienteRefAnt = cNumClienteRef;
				
					RETURN cCodRet,cdesc_codret,cValidaReferencias, TRIM(cNom_ref),TRIM(cparentesco),TRIM(ctel_ref),TRIM(cSecuencia) WITH RESUME;
				END FOREACH;
				
			ELSE
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
			END IF;
		END IF;
		IF pOpcion = '5' THEN
				SELECT  TRIM(a.nombre1)||" " || TRIM(a.nombre2) || " " || TRIM(a.apell_paterno) || " " || TRIM(a.apell_materno), b.fecha_nac
				INTO cNom_ref, cfechanac_ref
				FROM bdinteg:si_cliente a
				INNER JOIN bdinteg:si_ctepf b ON (a.empresa = b.empresa AND a.numcte = b.numcte)
				WHERE a.numcte= pNumCte;		
				
			--Se valida si ya existe el registro de acreditado con el obligado y si es asÃ­ los retorna para mostrar en el grid en automatico.	
			IF substr(pNumSol,1,4) IN ("9100","9300") THEN
				SELECT COUNT(b.numcte_ref) INTO iCont 
				FROM bdisolic:"informix".ss_refpersonales a 
				INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte  AND  a.num_solicitud = b.num_solicitud  AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
				WHERE a.empresa =pEmpresa AND a.num_solicitud = pNumSol  AND a.numcte_ref like 'R3%' ;				
				IF iCont > 0 THEN		
					FOREACH
					SELECT b.numcte_ref
					INTO cNumClienteRef  --Numero de Solicitud de Prestamo Moto Obligado
					FROM bdisolic:"informix".ss_refpersonales a 
					INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte  AND  a.num_solicitud = b.num_solicitud AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
					WHERE a.empresa =pEmpresa AND a.num_solicitud = pNumSol  AND a.numcte_ref like 'R3%'  AND b.numcte_ref <> ''	
					
						LET icontador = icontador +1;

						IF length(cNumClienteRef) < 12 THEN
							IF iCont = 1 OR iCont = icontador THEN
								LET cNumClienteRef = "";
								LET cCodRet = '01308';		
							ELSE 
								CONTINUE FOREACH;
							END IF;
						ELSE 	
							SELECT num_solicitud
							INTO cNumSolic
							FROM "informix".ss_solicitudes
							WHERE empresa = pEmpresa AND num_solicitud = cNumClienteRef
							AND status_solicitud = 'AT';
							
							IF NVL(cNumSolic,'') = '' THEN
								IF iCont = 1 OR iCont = icontador THEN								
									LET cCodRet = '01301';
									LET cdesc_codret = 'La solicitud capturada se encuentra rechazada o cancelada';
								ELSE 
									CONTINUE FOREACH;
								END IF;
							ELSE 	
								EXIT FOREACH;
							END IF;
						END IF;										
					END FOREACH;
					RETURN cCodRet,cdesc_codret,cValidaReferencias, NVL(cNumClienteRef,''),cparentesco,ctel_ref,cSecuencia;					
				END IF;		
				RETURN cCodRet,cdesc_codret,cValidaReferencias, NVL(cNumClienteRef,''),cparentesco,ctel_ref,cSecuencia;
			ELIF substr(pNumSol,1,4) IN ("9200","9400") THEN		
			
				SELECT COUNT(a.num_solicitud) INTO iCont 
				FROM bdisolic:"informix".ss_refpersonales a 
				INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte  AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco)
				WHERE a.empresa =pEmpresa AND a.numcte_ref like 'R3%' AND a.nombre_ref = cNom_ref AND b.fecha_nac = cfechanac_ref;				
				IF iCont > 0 THEN		

					SELECT limit 1  b.num_solicitud
					INTO cnumsolTit  --Numero de Solicitud de Prestamo Moto titular
					FROM bdisolic:"informix".ss_refpersonales a 
					INNER JOIN bdinteg:si_refclientes b ON (a.empresa = b.empresa AND a.numcte = b.numcte AND a.nombre_ref = TRIM(b.nombre1)||" " || TRIM(b.nombre2) || " " || TRIM(b.apell_paterno) || " " || TRIM(b.apell_materno) AND a.parentesco= b.parentesco )
					INNER JOIN bdisolic:ss_solicitudes c ON (b.empresa = c.empresa AND b.numcte = c.numcte  AND  b.num_solicitud = c.num_solicitud AND c.status_solicitud NOT IN('RT','PC','AN'))
					WHERE a.empresa =pEmpresa AND a.numcte_ref like 'R3%' AND a.nombre_ref = cNom_ref AND b.fecha_nac = cfechanac_ref;						
					
					IF cnumsolTit <> '' THEN
							SELECT monto_solicitado INTO dMontoSolicitud FROM bdisolic:"informix".ss_solicitudes WHERE num_solicitud = cnumsolTit;
							LET cparentesco = dMontoSolicitud::CHAR(25);
					END IF;		
				END IF;
				RETURN cCodRet,cdesc_codret,cValidaReferencias, cnumsolTit,cparentesco,ctel_ref,cSecuencia;				
			END IF;
		END IF;		
		
		IF DBINFO("sqlca.sqlerrd2") = 0  THEN
			--LET cCodRet = '00001';
			RETURN cCodRet,cdesc_codret,cValidaReferencias, cNom_ref,cparentesco,ctel_ref,cSecuencia;
		END IF;

	END;
END PROCEDURE
