CREATE PROCEDURE "informix".sp_consultamovinversion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaInicio Date, pFechafin DATE)
		RETURNING CHAR(5) AS codret,
		INTEGER AS num_registros;
		
	DEFINE cCodRet			CHAR(5);
	DEFINE iSqlErr 			INTEGER;
	DEFINE iNoRegistros 	INTEGER;
	
	LET cCodRet 	  = '00000';
	LET iSqlErr 	  = 0;
	LET iNoRegistros  = 0;
	
	BEGIN	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_consultamovinversion_totales.out';
		-- TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFechaInicio IS NULL OR pFechafin IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		SELECT COUNT(*)
		INTO iNoRegistros
		FROM bdinvers:"informix".sv_movsinver
		WHERE fecha >= pFechaInicio 
			AND fecha <= pFechafin;
		
		RETURN cCodRet, iNoRegistros;
	
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Angelica Hernandez Perez',
'FECHA: 15/06/2016',
'MODULO: CONCILIACIONES',
'FUNCIONALIDAD: MOVIMIENTOS DEL SISTEMA DE INVERSIONES (PAGARE)',
'DESCRIPCION: Spl que realiza la consulta de los totales para los movimientos del sistema de inversiones de los pagares.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_finalizacedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    
    LET cCodRet1     = '000';
    LET cCodRet2     = '';
    LET cCodRet3     = '';
    LET iSqlErr	     = 0;
    LET iSamErr      = 0;
    LET cDesErr      = '';
    LET iExiste      = 0;
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_finalizacedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_finalizacedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'CAPITAL';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'CAPITAL';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INTERES';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INTERES';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'SOBREGIRO';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'SOBREGIRO';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontable
         WHERE fecha_concil = pFechaConcil
           AND concepto = 'INT PAGARE';
           
        IF iExiste > 0 THEN
            UPDATE bdicheq:sc_cedulacontable
               SET editable = '1'
             WHERE fecha_concil = pFechaConcil
               AND concepto = 'INT PAGARE';
               
            RETURN cCodRet1;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1;
        END IF;
    END IF;
     
    END;
    
END PROCEDURE;