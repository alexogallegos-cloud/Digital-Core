CREATE PROCEDURE "informix".sp_situacionesclientescoppelporenviar_pbas4 (pEmpresa CHAR(3), pNumCte CHAR(20), pCliente CHAR(20), pIduSituacion INTEGER,pResultados INTEGER,
															pStatus CHAR(3), pMensaje CHAR(150), pCtl_Enviado CHAR(1), pOpcion INTEGER, pEmpleado CHAR(8))
															
															
															
	RETURNING CHAR (6) AS rCodRet 	

	/* 
	
				CodRet  = '000000' : 'Se realizo con exito'
						= '000003' :	'Parametros Vacios'
						= '000004' : 'No se encontro el cliente'
	
	*/
		
	--DECLARACION DE VARIABLES 
	DEFINe	dFecha_Modificacion		DATETIME YEAR TO SECOND;
	DEFINE 	cCodRet					CHAR(6);
	DEFINE  iSqlErr					INTEGER;
	DEFINE	cNumCte					CHAR(20);
	
	--INICIALIZACIÒN DE VARIABLES 
	LET		dFecha_Modificacion	=		CURRENT;
	LET		cCodRet				=		'000000';
	LET     iSqlErr				=		0;
	LET		cNumCte				= 		'';
	

--SET DEBUG FILE TO '/respaldosbd/Carolina/sp_.out';
--TRACE ON;
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF (iSqlErr != 0) then 
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pOpcion = 1 THEN 
		
				IF NVL(pEmpresa, '')<> '' AND NVL(pNumCte, '')<> ''  AND  NVL( pOpcion , '') <> ''  AND NVL(pCliente, '')<> ''  THEN
			
									
				    SELECT numcte
					INTO  cNumCte
					FROM  bdinteg: "informix".si_clientescoppelporenviar
					WHERE numcte = TRIM(pNumCte) AND status = 3;
					
					
					UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
					SET cliente = pCliente
					WHERE numcte = TRIM(pNumCte) AND status = 0; 	
						
					IF NVL(cNumCte, '') ='' THEN 
					
					
						UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
						SET ctl_enviado = 2, empleado = pEmpleado, fecha_modificacion = CURRENT, idusituacion = pIduSituacion
						WHERE numcte = TRIM(pNumCte) AND status = 0;
						
						LET cCodRet = '000004';	
			
					END IF;												
			
						
				ELSE 				
					LET cCodRet ='000003';	
					
				END IF; 
				
		ELIF pOpcion = 2 THEN	

					IF   NVL( pCtl_Enviado , '') <> '' AND NVL(pCliente, '')<> ''THEN 	
					
						IF pCtl_Enviado = '1' THEN 	
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados, idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND  cliente = TRIM(pCliente); 
							
							--Se Borra registro, porque ya se movio a tabla historica 
							DELETE  bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							WHERE  cliente = TRIM(pCliente); 
							
						ELSE 
							
							UPDATE bdinteg: "informix".si_situaciones_clientescoppel_porenviar 
							SET  resultados = pResultados,idusituacion =pIduSituacion, status = pStatus, mensaje = pMensaje, ctl_enviado = pCtl_Enviado, fecha_modificacion = CURRENT, empleado = pEmpleado
							WHERE empresa = pEmpresa AND cliente = TRIM(pCliente); 
						END IF;
						
					ELSE 
						LET cCodRet = '000003';
					END IF;	
				
			       
		END IF;
	
		RETURN cCodRet;	
	END
END	PROCEDURE
