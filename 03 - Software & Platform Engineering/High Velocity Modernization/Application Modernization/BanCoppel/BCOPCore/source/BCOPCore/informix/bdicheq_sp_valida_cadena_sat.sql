CREATE PROCEDURE "informix".sp_valida_cadena_sat(p_Cadena LVARCHAR(295))

RETURNING LVARCHAR(295);

    -- Elaboró: Alejandro Osuna Iza
    -- Actividad: Valida que la cadena no contenga |
    -- Solicito:Jorge Nuñez
    -- Fecha: 06 de Octubre de 2009
    
    DEFINE v_sCodRet  CHAR(295);
    DEFINE longitud integer;
    DEFINE cadenados CHAR(1);
    DEFINE inicio integer;
    DEFINE finciclo char(1);
    DEFINE valor CHAR(1);
    DEFINE v_campoDir 	lvarchar(295);

    LET cadenados = "";
    LET finciclo = "";
    LET v_sCodRet = "";
    LET valor = "";
    LET v_campoDir = "";

    -- SET DEBUG FILE TO "/tmp/sp_valida_cadena.out";
    -- TRACE ON;

    -- // Se valida QUE LA CADENA SEA ALFANUMERICO
    LET longitud = length(p_Cadena);
    LET inicio = 1;
    LET finciclo = 'F';
    
    while (inicio <= longitud)
        LET cadenados = substr(p_Cadena,inicio,1);
        
        IF cadenados = '|'THEN
            LET cadenados = "";
            LET v_campoDir = v_campoDir || cadenados ;
        ELSE
            LET v_campoDir = v_campoDir || cadenados ;
        END IF;
        
        LET inicio = (inicio + 1);
    END WHILE;
    
    LET v_sCodRet = v_campoDir;
    
    RETURN v_sCodRet;
	
END PROCEDURE;