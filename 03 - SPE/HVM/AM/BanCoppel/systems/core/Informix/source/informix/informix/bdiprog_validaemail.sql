CREATE PROCEDURE "informix".validaemail(p_sEmail CHAR(100))
    RETURNING CHAR(5);

--Declaracion de variables

DEFINE v_sCodRet CHAR(5);
DEFINE v_iEmail INTEGER;
DEFINE v_sFinCiclo CHAR(1);
DEFINE v_iLongEmail INTEGER;
DEFINE v_sEmail CHAR(100);
DEFINE v_iTerminacion INTEGER;
DEFINE v_iTerminacion2 INTEGER;
DEFINE v_iTerminacion3 INTEGER;

-- *****************************************************
-- Realizo: Marcos Cuevas                        	 --*
-- Actividad: Dar de alta y de baja              	 --*
-- Solicito:Jorge NuÃ±ez                          	 --*
--Fecha: 19/ENE/2009                             	 --*
-- Debug del Procedure                           	 --*
-- SET DEBUG FILE TO "/tmp/validaEmail.out";         --*
-- TRACE ON;  
-- Modifico: Viridiana Paredes R                     --*
-- Actividad: Modificar la longitud de p_sEmail a 100 --*
-- Folio:216             				             --*
-- Fecha: 29/MAR/2017                                --*
-- BD: bdiprog			                             --*
-- *****************************************************

--Asignacion de variables

LET v_sCodRet = '00000';
LET v_iEmail = 0;
LET v_sFinCiclo = 'T';
LET v_iLongEmail = 1;
LET v_sEmail = '';
LET v_iTerminacion = 0;
LET v_iTerminacion2 = 0;
LET v_iTerminacion3 = 0;

--Inicio del procedimiento

BEGIN

	IF (NVL(p_sEmail,'') <> '') THEN
		LET v_iEmail = LENGTH(p_sEmail);
			
		WHILE (v_iLongEmail <= v_iEmail) AND (v_sFinCiclo = 'T')
			LET v_sEmail = SUBSTR(p_sEmail,v_iLongEmail,1);
			IF (v_sEmail = '@') THEN
				LET v_sFinCiclo = 'C';
				LET v_iTerminacion = v_iLongEmail;
			ELSE
				LET v_iLongEmail = ( v_iLongEmail + 1);
			END IF;
		END WHILE;
	
		IF v_sFinCiclo = 'T' THEN
			LET v_sCodRet = '00004';
			RETURN v_sCodRet;
		END IF;
	
		IF (v_iTerminacion = 1) THEN
			LET v_sCodRet = '00001';
			RETURN v_sCodRet;
		END IF;	
	
		WHILE (v_iLongEmail <= v_iEmail) AND (v_sFinCiclo = 'C')
			LET v_sEmail = SUBSTR(p_sEmail,v_iLongEmail,1);
			IF (v_sEmail = '.') THEN
				LET v_sFinCiclo = 'P';
				LET v_iTerminacion2 = v_iLongEmail;
			ELSE
				LET v_iLongEmail = ( v_iLongEmail + 1);
			END IF;
		END WHILE;
		LET v_iTerminacion3 = v_iTerminacion + 1;
		IF (v_iTerminacion2 = v_iTerminacion3) THEN
			LET v_sCodRet = '00002';
			RETURN v_sCodRet;
		END IF;	
		
		IF v_sFinCiclo = 'C' THEN
			LET v_sCodRet = '00005';
			RETURN v_sCodRet;
		END IF;
		
		WHILE (v_iLongEmail <= v_iEmail) AND (v_sFinCiclo = 'P')
			LET v_sEmail = SUBSTR(p_sEmail,v_iLongEmail,1);
			IF (v_iLongEmail = v_iEmail) THEN
				LET v_sFinCiclo = 'F';
			ELSE
				LET v_iLongEmail = ( v_iLongEmail + 1);
			END IF;	
		END WHILE;
		IF (v_iTerminacion2 = v_iLongEmail) THEN
			LET v_sCodRet = '00003';
			RETURN v_sCodRet;
		END IF;	
		
	ELSE
		LET v_sCodRet = '00000';
	END IF;

    RETURN v_sCodRet;
END
END PROCEDURE;