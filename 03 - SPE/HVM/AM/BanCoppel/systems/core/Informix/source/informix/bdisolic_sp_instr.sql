CREATE PROCEDURE "informix".sp_instr(p_tipo INTEGER, p_cadena LVARCHAR(10000), p_buscar LVARCHAR, p_repeticion INTEGER DEFAULT 1, p_inicio INTEGER DEFAULT 1)

	--DATOS A REGRESAR---
	RETURNING
	CHAR(5),
	SMALLINT;

	--DEFINICION DE VARIABLES--
	DEFINE sql_err 	INTEGER;
	DEFINE vCodRet 	CHAR(5);

	DEFINE i, j, contador SMALLINT;    
	DEFINE c1   LVARCHAR; 

	--INICIALIZACION DE VARIABLES--
	LET sql_err 	 = 0;
	LET vCodRet 	 = '00000';

	LET i = 0;
	LET j = 0;
	LET contador = 1;
	LET c1 = "";

	--SET DEBUG FILE TO "/respaldosbd/Daniela/sp_instr.out";
	--TRACE ON;

	BEGIN

		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET vCodRet = sql_err;
				RETURN  vCodRet, i;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO dirty READ;
		SET LOCK MODE TO WAIT 3;

			IF(p_cadena is NULL) OR (p_buscar IS NULL) THEN
				RETURN "00001", -1;
			END IF;

			LET j = LENGTH(p_cadena);

			IF p_tipo = 1 THEN --Busca desde el Inicio de la cadena hasta el final
				FOR i = p_inicio to j
					IF(SUBSTR(p_cadena,i,1) = SUBSTR(p_buscar,1,1)) THEN
						LET c1 = SUBSTR(p_cadena,i,LENGTH(p_buscar));
						IF(c1 = p_buscar) THEN
							IF contador = p_repeticion THEN
								RETURN "00000", i;
							ELSE
								LET contador = contador + 1;
							END IF;
						END IF;
					END IF;
				END FOR;
			ELIF p_tipo = 2 THEN --Busca desde el final de la cadena hasta el inicio
				FOR i = LENGTH(p_cadena) to p_inicio
					IF(SUBSTR(p_cadena,i,1) = SUBSTR(p_buscar,1,1)) THEN
						LET c1 = SUBSTR(p_cadena,i,LENGTH(p_buscar));
						IF(c1 = p_buscar) THEN
							IF contador = p_repeticion THEN
								RETURN "00000", i;
							ELSE
								LET contador = contador + 1;
							END IF;
						END IF;
					END IF;
				END FOR;
			END IF;

			RETURN "00000", 0; --Si no encontro concurrencias manda 0(no existe).
	END

END PROCEDURE

