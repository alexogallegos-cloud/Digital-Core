CREATE FUNCTION "informix".valrfcemp_cecoban(pRFC CHAR(13))
	RETURNING --CHAR(5), -- codret,
              CHAR(1); -- Resp


    --DEFINE cCodRet 		CHAR(5);
	--DEFINE iSqlErr 		INTEGER;
    DEFINE cRespuesta	CHAR(1);
	DEFINE cValRFC1		CHAR(1);
	DEFINE cRFC1		CHAR(1);
    DEFINE iRFC1		SMALLINT;
	DEFINE i			SMALLINT;
    DEFINE iBandEspacio SMALLINT;
	DEFINE Var_rfcchar   VARCHAR(13);
	
	
	
    --LET cCodRet 	= "000";
    --LET iSqlErr  	= 0;
    LET cRespuesta	= "0";
	LET cValRFC1	= "";
	LET	cRFC1		= "";
    LET Var_rfcchar  = "";
	
	
	
BEGIN
    /*
	------  Control de Errores no Controlados
		ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;    
            RETURN cCodRet, cRespuesta;
        END IF;
		END EXCEPTION;
   */
	
		  --  SET DEBUG FILE TO "/informix/oper-prod/valrfcemp_cecoban.out";
		  --  TRACE ON;
   
    LET pRFC = TRIM(pRFC);

	
	IF LENGTH (pRFC) > 0 AND LENGTH (pRFC) < 13  THEN
      -- VALIDA QUE LOS PRIMEROS 3 CARACTERES SEAN LETRAS
		
			LET Var_rfcchar = TRIM(pRFC);
			
			LET iBandEspacio = INSTR (Var_rfcchar,' ',1);
			
			IF iBandEspacio = 0  THEN     
			
			
						FOR i=1 to 3
							LET cRFC1=SUBSTR(pRFC,i,1);
							CALL bdiprog:isnumeric(cRFC1) RETURNING cValRFC1;
							IF cValRFC1 = 1 THEN	
								LET cRespuesta = 1;  -- RFC INCORRECTO
								--EXIT FOR
								RETURN cRespuesta;
							END IF;
						END FOR
						
						
					   -- VALIDA QUE LOS CARACTES DE LA POSICION 4 A LA 9 SEAN NUMEROS
						FOR i=4 to 9
							LET cRFC1=SUBSTR(pRFC,i,1);
							CALL bdiprog:isnumeric(cRFC1) RETURNING cValRFC1;
							IF cValRFC1 = 0 THEN	
								LET cRespuesta = 1;  -- RFC INCORRECTO
								--EXIT FOR
								RETURN cRespuesta;
							END IF;
						END FOR
				   
				   
						-- VALIDACION DE FECHA
						LET iRFC1=SUBSTR(pRFC,6,2)::SMALLINT;

						
						IF  iRFC1 > 12 THEN
							LET cRespuesta = 1;  -- RFC INCORRECTO
						END IF;

						LET iRFC1=SUBSTR(pRFC,8,2)::SMALLINT;
					
						
						IF iRFC1 > 31 THEN
							LET cRespuesta = 1;  -- RFC INCORRECTO
						END IF;
				
			ELSE
			LET cRespuesta = 1;  -- RFC INCORRECTO
			
			END IF	
				
				
	 ELSE
	 LET cRespuesta = 1;  -- RFC INCORRECTO
				
				
     END IF
	
	RETURN cRespuesta;

END;
END FUNCTION
;