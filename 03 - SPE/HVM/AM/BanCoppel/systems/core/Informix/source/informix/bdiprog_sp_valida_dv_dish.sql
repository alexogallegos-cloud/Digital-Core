CREATE PROCEDURE  "informix".sp_valida_dv_dish(pNumRef CHAR(13))
RETURNING 
	CHAR (5) AS CodigoRetorno;
	
--DEFINICION DE LAS VARIABLES
DEFINE iSqlErr			 INTEGER;
DEFINE sI 		    	 SMALLINT;
DEFINE iNoPeso      	 INTEGER;
DEFINE iValorDigito 	 INTEGER;  
DEFINE iSuma			 INTEGER;
DEFINE iAux				 INTEGER;
DEFINE cCodRet			 CHAR(5); 
DEFINE cNum1			 CHAR(2);
DEFINE cNum2			 CHAR(2);
DEFINE iDigVerCapturado  INTEGER;
DEFINE iDigVerCalculado  INTEGER;
DEFINE sFijo			 SMALLINT;
DEFINE iResiduo			 INTEGER;

--INICIALIZACION DE LAS VARIABLES
LET cCodRet        	 = '00004';
LET iSqlErr        	 = 0;
LET sI 		    	 = 0;	
LET iNoPeso      	 = 60;
LET iValorDigito 	 = 0;
LET iSuma			 = 0;
LET iAux			 = 0;	
LET cNum1			 = '0';
LET cNum2			 = '0';
LET iDigVerCapturado = 0;
LET iDigVerCalculado = 0;
LET sFijo			 = 24;
LET iResiduo		 = 0;

BEGIN

	ON EXCEPTION SET iSqlErr
		   IF (iSqlErr != 0) THEN
			  LET cCodRet = iSqlErr;
			  RETURN cCodRet;
		   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/yuri/sp_valida_dv_dish.out';
	--TRACE ON;		
	
	SET ISOLATION TO DIRTY READ;

	IF LENGTH(TRIM(pNumRef))= 13 THEN
		
		LET sFijo = SUBSTR(pNumRef, 1, 2)::SMALLINT;		
--		IF sFijo = 21 THEN
		
		LET iDigVerCapturado = SUBSTR(pNumRef,13,1)::SMALLINT;
			FOR sI = 1 TO 12 
	
				LET iValorDigito = SUBSTR(pNumRef,sI,1)::SMALLINT;

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
					END IF;
				ELSE
					IF iResiduo =  iDigVerCapturado THEN
						LET cCodRet = '00000';
					ELSE
						LET cCodRet = '00001';						
					END IF;
				
				END IF;

--		END IF;		
	ELSE	
	--ESCENARIO: LONGITUD DE REFERENCIA INCORRECTA.
		LET cCodRet 		= '00002';	

	END IF;

	RETURN cCodRet;

END
END PROCEDURE;