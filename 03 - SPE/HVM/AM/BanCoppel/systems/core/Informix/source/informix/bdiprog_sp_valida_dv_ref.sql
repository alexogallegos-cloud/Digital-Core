CREATE PROCEDURE "informix".sp_valida_dv_ref(pNumRef CHAR(10), pLong INT)
	 RETURNING CHAR(5);

	-- ***************************************************************************
	-- Realizo: MANUEL RAMOS                                                   --*
	-- Actividad: validar digito verificador en la referencia Arabela y ECI    --*
	-- Solicito: Jose de Jesus N.                                              --*
	-- Fecha: 25/Mayo/2012                                                     --*
	-- ***************************************************************************

	--Declaración de Variables
	DEFINE sql_err INTEGER;
	DEFINE vCodRet CHAR(5);
	DEFINE vLongRef INTEGER;
	DEFINE vDV integer;
	DEFINE vAux1 INTEGER;
	DEFINE vAux2 INTEGER;
	DEFINE i INTEGER;

	--Asignación valores a variables
	LET sql_err =0;
	LET vCodRet = '00000';
	LET vLongRef = 0;
	LET vAux1 = 0;
	LET vAux2 = 0;

	--Inicio del procedimiento

	BEGIN

		ON EXCEPTION SET sql_err
			LET vCodRet = sql_err;
			RETURN vCodRet;
		END EXCEPTION;
		
		LET vLongRef = LENGTH(TRIM(pNumRef));
		
		IF (vLongRef = pLong) THEN
			LET vDV = SUBSTR(pNumRef,pLong,1)::INTEGER;
			
			FOR i = 1 TO vLongRef - 1
				LET vAux1 = SUBSTR(pNumRef,i,1)::INTEGER;
				IF MOD(i, 2) != 0 THEN
					LET vAux1 = vAux1 * 2;					
					IF vAux1 > 9 THEN
						LET vAux1 = (vAux1 - 10) + 1;
					END IF					
				END IF;
				LET vAux2 = vAux2 + vAux1;
			END FOR;
			
			LET vAux2 = 10 - MOD(vAux2, 10);
			
			IF(vAux2==10)THEN
				LET vAux2 = 0;
			END IF;
			
			IF vDV <> vAux2 THEN
				LET vCodRet = '00002';
			END IF;
		ELSE
			LET vCodRet = '00001';
		END IF;
		
		RETURN vCodRet;
	END
END PROCEDURE;