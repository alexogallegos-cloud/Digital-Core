CREATE PROCEDURE "informix".sp_valida_depinfonavitdv(pNumReferencia CHAR(27),pImporte char(10))
		
	RETURNING 
		CHAR(5) AS CodigoRetorno;
		
	--DEFINICION DE LAS VARIABLES
	DEFINE iCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCadImporte CHAR(10);
	DEFINE iContCadImporte INTEGER;
	DEFINE iMontoCondensado INTEGER;
	DEFINE iDVCalculado INTEGER;
	DEFINE iFechaHoyCondensada INTEGER;
	DEFINE iI INTEGER;
	DEFINE iJ INTEGER;
	DEFINE iDia INTEGER;
	DEFINE iMes INTEGER;
	DEFINE iAnio INTEGER;
	DEFINE cFechaHoy DATE;
	
	
	--INICIALIZACION DE LAS VARIABLES
	LET iCodRet = '00000';
	LET iSqlErr = 0;
	LET iCadImporte = '';
	LET iContCadImporte = 0;
	LET iMontoCondensado = 0;
	LET iDVCalculado = 0;
	LET iFechaHoyCondensada = 0;
	LET iI = 1;
	LET iJ = 7;
	LET iDia = 0;
	LET iMes = 0;
	LET iAnio = 0;
	LET cFechaHoy = MDY('01','01','1900');
	

	BEGIN
		
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_DEPdv.out';
		--TRACE ON;


		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		
		SELECT fecha_hoy
		INTO cFechaHoy
		FROM 'informix'.sac_fechas
		WHERE empresa = '001';
		
		
		--LET cFechaHoy = MDY('10','02','2017');	
		
		--DETERMINACION DE MONTO CONDENSADO
		IF NVL(pNumReferencia,'') = '' THEN
			LET iCodRet = '00086';
		ELIF LENGTH(pNumReferencia) < 27 THEN
			LET iCodRet = '00047';
		ELSE
			
			
			LET iCadImporte = pImporte;
			
			LET iI = 10;
			
			--MULTIPLICAR POR PONDERDORES 7,3,1 DE DERECHA A IZQUIERDA LAS 10 POSICIONES DE LA CADENA DEL MONTO, LOOS RESULTADOS SE SUMAN
			
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
			
			IF NVL(pImporte,'') <> '' THEN  -- <-- VALIDACION DEL MONTO EN LA SEGUNDA VALIDACION DE LA CAJA AL MONTO
			
				IF iMontoCondensado <> SUBSTR(pNumReferencia,24,1) AND iCodRet = '00000' THEN
					LET iCodRet = '00083';
				END IF;
			
			END IF;
			
			/*VALIDACION DE LA FECHA DE PAGO SEGUN REFERENCIA, APLICANDO ALGORITMO DE CONDENSACION, 
				FECHA VALIDA SI RESULTADO ES IGUAL O MENOR AL DE LA REFERNECIA*/
				
			LET iDia = DAY(cFechaHoy) - 1;
			LET iMes = (MONTH(cFechaHoy) -1) * 31;
			LET iAnio = (YEAR(cFechaHoy) - 2013) * 372;
			LET iFechaHoyCondensada = idia + iMes + iAnio;

			
			IF iFechaHoyCondensada > SUBSTR(pNumReferencia,20,4) AND iCodRet = '00000' THEN
				LET iCodRet = '00003';
			END IF;
			
			/*MULTIPLICAR POR PONDERDORES 11,13,17,19 Y 23 DE DERECHA A IZQUIERDA LAS 25 POSICIONES DE LA CADENA DEL MONTO
				(EXCLUYENDO LOS DOS ULTIMOS DEL DV CAPTURADO EN LA REFERNCIA), LOS RESULTADOS SE SUMAN*/
				
			LET iI = 25;
			LET iJ = 11;
			
			WHILE iI > 0
				IF iJ = 11 THEN 
					LET iDVCalculado = iDVCalculado + (SUBSTR(pNumReferencia,iI,1)::INTEGER * 11);
					LET iJ = 13;
				ELIF iJ = 13 THEN 
					LET iDVCalculado = iDVCalculado + (SUBSTR(pNumReferencia,iI,1)::INTEGER * 13);
					LET iJ = 17;
				ELIF iJ = 17 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pNumReferencia,iI,1)::INTEGER * 17);
					LET iJ = 19;
				ELIF iJ = 19 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pNumReferencia,iI,1)::INTEGER * 19);
					LET iJ = 23;
				ELIF iJ = 23 THEN
					LET iDVCalculado = iDVCalculado + (SUBSTR(pNumReferencia,iI,1)::INTEGER * 23);
					LET iJ = 11;
				END IF;
				LET iI = iI - 1;
			END WHILE;
			
			--PARA OBTENER EL DV, EL RESULTADO SE DIVIDE ENTRE 97 Y AL RESIDUO SE LE SUMA 1
			LET iDVCalculado = (MOD(iDVCalculado,97)) + 1;
			
			IF iDVCalculado <> SUBSTR(pNumReferencia,26,2)::INTEGER AND iCodRet = '00000' THEN
				LET iCodRet = '00109';
			END IF;
			
		END IF;
		
		RETURN iCodRet;
	END;
	
END PROCEDURE;