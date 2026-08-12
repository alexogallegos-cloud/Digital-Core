CREATE PROCEDURE "informix".sp_intentos_ctas_frec (pnumcte CHAR(9), ptipo CHAR(1))

RETURNING char(5);

DEFINE iSqlErr INTEGER;
DEFINE iExist INTEGER;
DEFINE contIntento SMALLINT;
DEFINE primerIntento INTEGER;
DEFINE cCodSp CHAR(5);

LET iExist = 0;
LET contIntento = 0;
LET primerIntento = 1;
LET cCodSp = '00001'; 
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr;
			END IF;
		END EXCEPTION;
		
		
		IF pnumcte <> "" AND ptipo <> "" THEN 
		
			LET cCodSp = '00000'; 
		
			SELECT numintento INTO contIntento FROM bdibpi:"informix".bpi_intentos_alta_cta_frec 
			  WHERE numcte=pnumcte and tipo=ptipo and EXTEND(fecha, YEAR TO DAY) = EXTEND(current, YEAR TO DAY);

			
			IF NVL(contIntento,0) = 0 THEN
					
					DELETE FROM bdibpi:"informix".bpi_intentos_alta_cta_frec WHERE numcte=pnumcte and tipo=ptipo;					
					INSERT INTO bdibpi:"informix".bpi_intentos_alta_cta_frec(numcte, fecha, numintento, tipo) 
					 VALUES(pnumcte, current YEAR TO DAY, primerIntento, ptipo);
			ELSE 
				IF(contIntento < 20) THEN
						LET contIntento = contIntento + 1 ;
						UPDATE bdibpi:"informix".bpi_intentos_alta_cta_frec SET numintento = contIntento
						WHERE numcte=pnumcte and tipo=ptipo and EXTEND(fecha, YEAR TO DAY) = EXTEND(current, YEAR TO DAY);
				ELSE
					LET cCodSp = '00001';					
				END IF;
			END IF;

		END IF;
		
	RETURN cCodSp;
END;
END PROCEDURE;