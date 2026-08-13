CREATE PROCEDURE "informix".sp_valida_cadena(p_Cadena LVARCHAR(345),p_tipo CHAR(1))


	RETURNING CHAR(5);
	--Elaboró: Alejandro Osuna Iza
   --Actividad: Valida que la cadena no contenga caracteres especiales
   --Solicito: Hector Casanova
   --Fecha: 13 de julio de 2009


	DEFINE v_sCodRet  CHAR(5);
	DEFINE longitud integer;
	DEFINE cadenados CHAR(20);
	DEFINE inicio integer;
	DEFINE finciclo char(1);
	DEFINE valor CHAR(1);


	LET cadenados = "";
	LET finciclo = "";
	LET v_sCodRet = "";
	LET valor = "";

	--SET DEBUG FILE TO "/tmp/sp_valida_cadena.out";
    --TRACE ON;

	IF 	(p_tipo = "A")  OR (p_tipo = "N") OR (p_tipo = "B") OR (p_tipo = "P") OR (p_tipo = "T") THEN
	ELSE
		LET v_sCodRet = "00608";
            RETURN v_sCodRet;
	END IF;
	IF (p_tipo = "N") OR (p_tipo = "A") OR (p_tipo = "T") THEN
		IF (p_Cadena is null) OR (p_Cadena = "")THEN
			LET v_sCodRet = "00608";
	            RETURN v_sCodRet;
		END IF;
	END IF;
	--Se valida QUE LA CADENA SEA ALFANUMERICO
	IF p_tipo = "A" then
       --LET cadena = p_sreferencia1;
       LET longitud = length(p_Cadena);
       LET inicio = 1;
       LET finciclo = 'F';
       while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= 'A') and (cadenados <= 'Z')) or ((cadenados >= 'a') and (cadenados <= 'z')) or ((cadenados >= '0')  and (cadenados <= '9'))THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;
        IF valor = 'B' THEN
			LET v_sCodRet = "00609";
            RETURN v_sCodRet;
        END IF;
	END if;
	--Se valida QUE LA CADENA SEA NUMERICO
	IF p_tipo = "N" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= '0')  and (cadenados <= '9'))THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00610";
			RETURN v_sCodRet;
        END IF;
	END IF;
	IF p_tipo = "B" then
        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF (cadenados = ' ') THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00612";
			RETURN v_sCodRet;
        END IF;
	END IF;
	--Se valida CON LA TABLA DE CARACTERES VALIDOS EN LA CCE(CHEQUES,TEF, DOMI)
	IF p_tipo = "T" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= ' ') and (cadenados <= ';'))
				or ((cadenados >= '?')  and (cadenados <= 'Z'))
				or (cadenados >= '\')
				or (cadenados >= '_')
				or ((cadenados >= 'a')  and (cadenados <= 'z'))
				or (cadenados >= 'é')
				or ((cadenados >= 'á')  and (cadenados <= 'Ñ'))
				or (cadenados >= '¿')
				or (cadenados >= '¡') THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00614";
			RETURN v_sCodRet;
        END IF;
	END IF;
	--SE VALIDA CON RESPECTO A LOS CARACTERES PERMITIDOS EN LA NOMENCLATURA DE ARCHIVOS DE ENTRADA
	IF p_tipo = "P" then

        LET longitud = length(p_Cadena);
        LET inicio = 1;
        LET finciclo = 'F';
        while (inicio <= longitud) and (finciclo = 'F')
            LET cadenados = substr(p_Cadena,inicio,1);
            IF ((cadenados >= '0') and (cadenados <= 'z'))
				or (cadenados >= '.') --and (cadenados <= 'z'))
				/*or ((cadenados >= 'á')  and (cadenados <= 'Ñ'))
				or ((cadenados >= '¿')
				or ((cadenados >= '¡')
				/*or ((cadenados >= ' ')  and (cadenados <= '/'))
				or ((cadenados >= ' ')  and (cadenados <= '/'))*/
				THEN
                LET valor = 'A';
            ELSE
                LET valor = 'B';
                LET finciclo = 'T';
            END IF;
            LET inicio = (inicio + 1);
        END WHILE;

        IF valor = 'B' THEN
			LET v_sCodRet = "00615";
			RETURN v_sCodRet;
        END IF;
	END IF;

	LET v_sCodRet = "00000";
	RETURN v_sCodRet;


END PROCEDURE;