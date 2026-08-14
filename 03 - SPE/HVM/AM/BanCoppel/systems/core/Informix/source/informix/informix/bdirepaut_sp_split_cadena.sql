CREATE PROCEDURE "informix".sp_split_cadena(pCadena LVARCHAR, pDelimitador CHAR(1))
	RETURNING LVARCHAR AS palabra;
	
	DEFINE tPalabra LVARCHAR;
	DEFINE i INTEGER;
	DEFINE iTamCad INTEGER;
	DEFINE iInicioCadena INTEGER;
	DEFINE iRecuperarCaracteres INTEGER;
	DEFINE cCaracter CHAR(1);
	DEFINE cPalabra LVARCHAR;
	
	LET tPalabra = '';
	LET iTamCad = LENGTH(TRIM(pCadena));
	LET cCaracter = '';
	LET cPalabra = '';
	LET iInicioCadena = 1;
	LET iRecuperarCaracteres = 0;

	--SET DEBUG FILE TO '/tmp/mfinis/sp_split_cadena.sql';
	--TRACE ON;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	BEGIN
		FOR i IN (1 TO iTamCad) LOOP
		
			LET cCaracter = SUBSTR(TRIM(pCadena), i, 1);
			LET iRecuperarCaracteres = iRecuperarCaracteres + 1;
			
			IF cCaracter = pDelimitador THEN
				LET iRecuperarCaracteres = iRecuperarCaracteres - 1;
				
				--TRACE iInicioCadena||' -> '|| iRecuperarCaracteres;
				LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
				LET iInicioCadena = i + 1;
				LET iRecuperarCaracteres = 0;
				
				IF cPalabra <> '' THEN
					RETURN cPalabra WITH RESUME;
				END IF;
			END IF;
			
		END LOOP;
		
		LET cPalabra = SUBSTR(TRIM(pCadena), iInicioCadena, iRecuperarCaracteres);
		IF cPalabra <> '' THEN
			RETURN cPalabra;
		END IF;
	END;
	
END PROCEDURE
