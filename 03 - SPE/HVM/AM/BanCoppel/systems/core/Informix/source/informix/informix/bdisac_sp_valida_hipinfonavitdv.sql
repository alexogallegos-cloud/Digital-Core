CREATE PROCEDURE  "informix".sp_valida_hipinfonavitdv(pNumReferencia CHAR(10))
	RETURNING 
		CHAR(5) AS CodigoRetorno;

	--DEFINICION DE LAS VARIABLES
	DEFINE iCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE isumapares INTEGER;
	DEFINE isumanones INTEGER;
	DEFINE iresiduo INTEGER;
	DEFINE idv INTEGER;
	DEFINE idvcapturado INTEGER;
	DEFINE icont INTEGER;
	DEFINE icos DECIMAL;

	--INICIALIZACION DE LAS VARIABLES
	LET iCodRet= '00000';
	LET iSqlErr= 0;
	LET isumapares= 0;
	LET isumanones= 0;
	LET iresiduo= 0;
	LET idv= 0;
	LET idvcapturado=0;
	LET icont = 1;
	LET icos = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_hipdv.out';
		--TRACE ON;	

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF TRIM(pNumReferencia) = '' THEN
			LET iCodRet = '00080';
		ELIF LENGTH(pNumReferencia) <> 10 THEN
			LET iCodRet = '00047';
		ELIF pNumReferencia = '0000000000' THEN 
			LET iCodRet = '00109';
		ELSE
			--PASO 1 SUMAR POSICIONES NONES Y PARES DE LA REFERENCIA EXCLUYENDO POSICION 10
			WHILE icont <= 10
				IF icont = 10 THEN 
					LET idvcapturado = SUBSTR(pNumReferencia,icont,1)::INTEGER;
				ELSE
					IF MOD(icont,2) = 0 THEN
						LET isumapares = isumapares + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					ELSE
						LET isumanones = isumanones + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					END IF;
				END IF;
				LET icont = icont + 1;
			END WHILE;
			
			--PASO 2 EL RESULADO DE LA SUMATORIA DE LOS NONES SE DIVIDE ENTRE 10
			LET iresiduo = MOD(isumanones,10);
			
			--PASO 3 EL RESIDUO DE LA ADIVISION ANTERIOR SE DIVIDE ENTRE 5, TAMBIEN SE GUARDA EL COSIENTE DE LA DIVISION
			--LET iresiduo = MOD(iresiduo,5);
			LET icos = iresiduo / 5;
			
			--PASO 4 EL RESULTADO DE LA SUMA DE LOS NONES DEL PASO 1 SE MULTIPLICA POR 2, Se vuelve a inicializar la variable icont para reciclarla
			LET icont = 0;  
			LET icont = isumanones * 2;
			
			-- PASO 5 AL RESULTADO DEL PUNTO 4 SE LE SUMA EL RESULTADO DE LA SUMA DE LOS PARES DEL PASO 1
			LET icont = icont + isumapares;
			
			-- PASO 6 AL RESULTADO DEL PASO 5 SE LE SUMA EL COSIENTE DE LA DIVISION DEL PASO 3
			LET icont = icont + icos;
			
			-- PASO 7 AL RESULTADO DEL PASO 6 SE DIVIDE ENTRE 10
			LET icont = MOD(icont,10);
			
			-- PASO 8 EL DV ES EL RESIDUO DEL PASO 7
			LET iresiduo = icont;
			
			-- SI EL DV CAPTURADO ES EL MISMO QUE EL CALCULADO EL CODIGO DE RETORNO ES CORRECTO (00000).
			IF iresiduo <> idvcapturado AND  iCodRet = '00000' then
				LET iCodRet = '00109';
			END IF
			
		END IF;
		
		RETURN iCodRet;
		
	END;
END PROCEDURE;