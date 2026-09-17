CREATE PROCEDURE "informix".sp_ctanvl2_regcurp( pNumCte CHAR(20),
                                                pCurp CHAR(18),
                                                pSexo CHAR(1),
                                                pApellPaterno CHAR(50),
                                                pApellMaterno CHAR(50),
                                                pNombre CHAR(50),
                                                pFechaNac DATE,
                                                pEntidad CHAR(2) )                                                
RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iTotalReg INTEGER;
	DEFINE cApell_paterno VARCHAR(50);    
	DEFINE cApell_materno VARCHAR(50);    
	DEFINE cNombreCte VARCHAR(50);  
	DEFINE cCurp CHAR(18);  
	DEFINE iTotalCurp INTEGER;
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cNumCte CHAR(20);
	DEFINE iTotalEnt INTEGER;
	DEFINE cExiste CHAR(1);
    DEFINE i SMALLINT;
    DEFINE cCaracter CHAR(1);
    DEFINE bBoolValue BOOLEAN;
	
	LET cCodRet = '000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iTotalReg = 0;
	LET cApell_paterno = '';
	LET cApell_materno = '';
	LET cNombreCte = '';
	LET cCurp = '';
	LET iTotalCurp = 0;
	LET cMes = '';
	LET cDia = '';
	LET cAnio = '';
	LET cNumCte = '';
	LET iTotalEnt = 0;
	LET cExiste = '';
    LET i = 0;
    LET cCaracter = '';
    LET bBoolValue = 'f';
	
	BEGIN
		
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN 
            LET cCodRet = iSqlErr;
            RETURN cCodRet;
        END IF;
    END EXCEPTION;
    
    --SET DEBUG FILE TO '/tmp/mfinis/sp_ctanvl2_regcurp.out';
    --TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    --VALIDACION DE CAMPOS REQUERIDOS
    IF pCurp IS NULL OR pCurp = '' OR
       pSexo IS NULL OR pSexo = '' OR 
       pApellPaterno IS NULL OR pApellPaterno = '' OR 
       pNombre IS NULL OR pNombre = '' OR 
       pFechaNac IS NULL OR pFechaNac = '' OR 
       pEntidad IS NULL OR pEntidad = '' THEN
        LET cCodRet = '110';
        RETURN cCodRet;
    END IF;
    
    --VALIDA QUE EL GENERO SEA MASCULINO = 'M' O FEMENINO = 'F'  
    IF pSexo NOT IN ('F', 'M') THEN 
        LET cCodRet = '377'; 
        RETURN cCodRet;
    END IF;
    
    
    --ASIGNACION DE VALORES PARA FECHA
    --LET cMes = SUBSTR(pFechaNac,1,2);
    --LET cDia = SUBSTR(pFechaNac,4,2);
    --LET cAnio = SUBSTR(pFechaNac,7,4);
    
    LET cMes = MONTH(pFechaNac);
    LET cDia = DAY(pFechaNac);
    LET cAnio = YEAR(pFechaNac);
    
    --VALIDA FORMATO DE FECHA
    IF (cMes <> MONTH(pFechaNac)) OR (cDia <> DAY(pFechaNac)) OR (cAnio <> YEAR(pFechaNac)) THEN
        LET cCodRet = '195';
        RETURN cCodRet;
    ELSE
        IF (cMes::INTEGER > 12) THEN
            LET cCodRet = '184';
            RETURN cCodRet;
        END IF;
        
        IF (cDia::INTEGER > 31) THEN
            LET cCodRet = '185';
            RETURN cCodRet;
        END IF;
    END IF;
    
    --VALIDA ENTIDAD FEDERATIVA
    SELECT {+INDEX (bdinteg:"informix".si_estados inx_estado)}
    1 INTO cExiste
    FROM bdinteg:"informix".si_estados
    WHERE estado = pEntidad;
    
    IF cExiste IS NULL THEN
        LET cCodRet = '402';
        RETURN cCodRet;
    END IF;
    
    --VALIDA LA LONGITUD DE LA CURP
    IF LENGTH(pCurp) <> 18 THEN
        LET cCodRet = '395';
        RETURN cCodRet;
    END IF;
    
    --VALIDA QUE LA CURP SOLO CONTENGA LETRAS Y NUMEROS
    FOR i = 0 TO LENGTH(TRIM(pCurp))
        LET cCaracter = SUBSTR(TRIM(pCurp), i, 1);
        EXECUTE PROCEDURE sp_sololetrasnumeros(cCaracter) 
        INTO bBoolValue;
        
        IF NOT bBoolValue THEN
            LET cCodRet = '396';
            RETURN cCodRet;
        END IF;
    END FOR;
    
    RETURN cCodRet;
		
	END;
    
END PROCEDURE
DOCUMENT 'AUTOR: Veronica SÃ¡nchez Tlacomulco',
'FECHA: 18/06/2020',
'DESCRIPCION: SPL encargado de validar y registrar la CURP del cliente',
'BD: bdinteg';

CREATE PROCEDURE "informix".sp_obtenerparametros_aweb(p_iCodParam INTEGER, p_sEmpresa CHAR(3))
	RETURNING	CHAR(5)  AS retorno,
				CHAR(50) AS descripcion,
				CHAR(100) AS valor;

	DEFINE v_codret     CHAR(5);
	DEFINE v_sDescripcion 	CHAR(50);
	DEFINE v_sValor			CHAR(100);
	LET v_codret    = "00000";
	--------------------------------------------------------------------------
	-- Creado por Erick Zamora 17/12/2008
	--SET DEBUG FILE TO "/tmp/sp_obtenerParametros.out";
	--TRACE ON;
	--------------------------------------------------------------------------

 
       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

	BEGIN
		FOREACH
			SELECT descripcion, valor
			INTO v_sDescripcion, v_sValor
			FROM bdinteg:si_param
			WHERE cod_param = NVL(p_iCodParam,cod_param)
                        AND empresa = p_sEmpresa

			RETURN v_codret, v_sDescripcion, v_sValor WITH RESUME;
		END FOREACH
	END
END PROCEDURE;