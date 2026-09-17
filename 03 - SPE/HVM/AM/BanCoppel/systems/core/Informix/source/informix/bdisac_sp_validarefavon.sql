CREATE PROCEDURE "informix".sp_validarefavon(pReferencia char(20), pMonto char(8))
	
	RETURNING 
		char(5); --CodRet
		
	--DEFINICION DE LAS VARIABLES
	DEFINE iCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCadImporte CHAR(8);
	DEFINE iMontoCondensado INTEGER;
	DEFINE iDVCalculado INTEGER;
	DEFINE iFechaCondensada CHAR(4);
	DEFINE iI INTEGER;
	DEFINE iJ INTEGER;
	DEFINE iTipoRef INTEGER;
	
	
	--INICIALIZACION DE LAS VARIABLES
	LET iCodRet = '00000';
	LET iSqlErr = 0;
	LET iCadImporte = '';
	LET iMontoCondensado = 0;
	LET iDVCalculado = 0;
	LET iFechaCondensada = '';
	LET iI = 1;
	LET iJ = 7;
	LET iTipoRef = 0;
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_AVONdv.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 2;
		
		IF NVL(pReferencia,'') = '' THEN
			LET iCodRet = '00086';
		ELIF LENGTH(pReferencia) < 20 THEN
			LET iCodRet = '00047';
		ELSE
				
				
			--EVALUA SI LA REFERENCIA ES DE 14 O 20 DIGITOS
			IF SUBSTR(pReferencia,1,1)::INTEGER + SUBSTR(pReferencia,2,1)::INTEGER + 
				SUBSTR(pReferencia,3,1)::INTEGER + SUBSTR(pReferencia,4,1)::INTEGER + 
					SUBSTR(pReferencia,5,1)::INTEGER + SUBSTR(pReferencia,6,1)::INTEGER = 0 THEN
					LET iTipoRef = 14;
			ELSE
					LET iTipoRef = 20;
			END IF;
			

			IF NVL(pMonto,'') <> '' THEN  -- <-- VALIDACION DEL MONTO EN LA SEGUNDA VALIDACION DE LA CAJA AL MONTO
				
				/*CALCULO DE IMPORTE CONDENSADO PARA VALIDAR */
				LET iCadImporte = pMonto;
			
				LET iI = 8;
			
				--MULTIPLICAR POR PONDERDORES 7,3,1 DE DERECHA A IZQUIERDA LAS 8 POSICIONES DE LA CADENA DEL MONTO, LOS RESULTADOS SE SUMAN
			
				WHILE iI > 0
					IF iJ = 7 THEN 
						LET iMontoCondensado = iMontoCondensado + (SUBSTR(iCadImporte,iI,1)::INTEGER * 7);
						LET iJ = 3;
					ELIF iJ = 3 THEN 
						LET iMontoCondensado = iMontoCondensado + (SUBSTR(iCadImporte,iI,1)::INTEGER * 3);
						LET iJ = 1;
					ELIF iJ = 1 THEN
						LET iMontoCondensado = iMontoCondensado + (SUBSTR(iCadImporte,iI,1)::INTEGER * 1);
						LET iJ = 7;
					END IF;
					LET iI = iI - 1;
				END WHILE;
			
				/*DIVIDIR RESULTADO ENTRE 10 Y EL RESIDUO ES EL DIGITO DE MONTO CONDENSADO QUE SE 
					PUEDE VERIFICAR CON EL CAPTURADO EN LA LINEA DE REFERENCIA*/
					
				LET iMontoCondensado = MOD(iMontoCondensado,10);
			
				IF iMontoCondensado <> SUBSTR(pReferencia,17,1) AND iCodRet = '00000' THEN
					LET iCodRet = '00083';
				END IF;
			
			END IF;	
						
			/*MULTIPLICAR POR PONDERDORES 11,13,17,19 Y 23 DE DERECHA A IZQUIERDA LAS 18 POSICIONES DE LA CADENA
				(RESTANTES EXCLUYENDO LOS DOS ULTIMOS DEL DV CAPTURADO EN LA REFERNCIA), LOS RESULTADOS SE SUMAN*/
		
			LET iI = 18;
			LET iJ = 11;
			
			WHILE iI > 0
				IF iJ = 11 THEN 
					LET iDVCalculado = iDVCalculado + (SUBSTR(pReferencia,iI,1)::INTEGER * 11);
					LET iJ = 13;
				ELIF iJ = 13 THEN 
					LET iDVCalculado = iDVCalculado + (SUBSTR(pReferencia,iI,1)::INTEGER * 13);
					LET iJ = 17;
				ELIF iJ = 17 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pReferencia,iI,1)::INTEGER * 17);
					LET iJ = 19;
				ELIF iJ = 19 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pReferencia,iI,1)::INTEGER * 19);
					LET iJ = 23;
				ELIF iJ = 23 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pReferencia,iI,1)::INTEGER * 23);
					LET iJ = 11;
				END IF;
				LET iI = iI - 1;
			END WHILE;
			
			--PARA OBTENER EL DV, EL RESULTADO SE DIVIDE ENTRE 97 Y AL RESIDUO SE LE SUMA 1, si la referencia es de 14 antes de la dividir de suma 322
			IF iTipoRef = 14 THEN 
				LET iDVCalculado = iDVCalculado + 322;
			END IF;
			
			LET iDVCalculado = (MOD(iDVCalculado,97)) + 1;
			
			IF iDVCalculado <> SUBSTR(pReferencia,19,2)::INTEGER AND iCodRet = '00000' THEN
				LET iCodRet = '00109';
			END IF;
			
		END IF;
			
		RETURN iCodRet;
		
	END;
	
END PROCEDURE;