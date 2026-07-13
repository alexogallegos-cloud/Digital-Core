CREATE PROCEDURE "informix".sp_verifica_bandera_sms_bex(pNumCte char(9), pTelefono char(10))
	RETURNING CHAR(5) AS  cCodRet;

	DEFINE cCodRet 		char(5);
	DEFINE iSqlErr  	INTEGER;
	DEFINE iSamErr  	INTEGER;
	DEFINE cDesErr  	CHAR(50);
	DEFINE cCont	 	INTEGER;
	DEFINE iDiasDiffTu 	INTEGER;
	DEFINE iDiasDif 	INTEGER;

	LET cCodRet 		= '00000'; 
	LET iSqlErr  		= 0;
	LET iSamErr  		= 0;
	LET cDesErr 		= '';
	LET cCont 			= 0;
	LET iDiasDiffTu 	= 0;
	LET iDiasDif  		= 0;

	
	BEGIN

		 ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
			
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF(pNumCte = '' OR pTelefono = '') THEN
			
			LET cCodRet = '00001';  --DATOS VACIOS
			
			ELSE    
					SELECT COUNT(numcte)              		
					INTO cCont
					FROM "informix".si_bitsmstels
					WHERE numcte = pNumCte
					AND telefono = pTelefono
					AND bandera = 't';
					
					SELECT {+AVOID_FULL(bdinteg:"informix".si_bitsmstels)} DATE(CURRENT) - DATE(MAX(fecha))  
					INTO iDiasDif
					FROM "informix".si_bitsmstels
					WHERE telefono = pTelefono
					AND bandera = 't'
					AND numcte = pNumCte;
				
				
				IF(cCont <> '0' and iDiasDif <= 90) THEN
					LET cCodRet = '00000';  --SE VALIDA QUE EL TELEFONO ESTA ACTIVO CON EL MISMO CLIENTE EN LOS ULTIMOS 90 DIAS	
				ELSE 
				
				  SELECT {+AVOID_FULL(bdinteg:"informix".si_bitsmstels)} DATE(CURRENT) - DATE(MAX(fecha))  
					INTO iDiasDif
					FROM "informix".si_bitsmstels
					WHERE telefono = pTelefono
					AND bandera = 't'
					AND numcte != pNumCte;
					
					IF (iDiasDif <= 90) then 
						--LET cCodRet = '00002';  ----SE VALIDA QUE EL TELEFONO ESTA ACTIVO POR OTRO CLIENTE EN LOS ULTIMOS 90 DIAS
										
						--ELSE
				
							SELECT {+AVOID_FULL(bdinteg:"informix".si_telefonos)} DATE(CURRENT) - DATE(MAX(fecha_hora)) 
								INTO iDiasDiffTu 
								FROM bdinteg:"informix".si_telefonos WHERE 
								telefono = pTelefono AND 
								tipo_tel = '2' AND 
								status_tel = 'A' AND 
								verificado = 'V' AND 
								numcte != pNumCte;
							
							IF (iDiasDiffTu <= 90) THEN 
								LET cCodRet = '00003';  ----SE VALIDA QUE EL TELEFONO SE REGISTRO EN LOS ULTIMOS 90 DIAS				
							END IF;
					END IF; 
				END IF; 
			END IF;

		RETURN cCodRet;	
	END
END PROCEDURE;