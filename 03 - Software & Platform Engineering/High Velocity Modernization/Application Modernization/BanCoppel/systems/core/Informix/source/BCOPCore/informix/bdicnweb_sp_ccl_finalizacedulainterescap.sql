CREATE PROCEDURE "informix".sp_ccl_finalizacedulainterescap(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE)
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ccl_finalizacedulainterescap.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFecha = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_finintisrxprodcedula(pFecha)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bdicheq:sp_finintisrxprodcedula";
		ELIF iCodRetSp = 110  THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 100  THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet;
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Johnattan Esquivel SÃ¡nchez',
'FECHA: 06/03/2017',
'MODULO: Conciliaciones',
'FUNCIONALIDAD: CÃ©dula Contable de Intereses Pagados en Cuentas de CaptaciÃ³n',
'DESCRIPCION: Finaliza la cedula impidiendo la modificacion de esta',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_usuarioscedulas( pFechaConcil DATE, pTipo SMALLINT ) 
RETURNING CHAR(5), CHAR(104), SMALLINT;
    
    DEFINE cCodRet1         CHAR(5);
    DEFINE cCodRet2         CHAR(5);
    DEFINE cCodRet3         CHAR(50);
    DEFINE iSqlErr          INTEGER;
    DEFINE iSamErr          INTEGER;
    DEFINE cDesErr          CHAR(50);
    DEFINE iExiste          SMALLINT;
    DEFINE cNombre          CHAR(104);
    DEFINE iFuncion         SMALLINT;
    
    LET cCodRet1         = '000';
    LET cCodRet2         = '';
    LET cCodRet3         = '';
    LET iSqlErr	         = 0;
    LET iSamErr          = 0;
    LET cDesErr          = '';
    LET iExiste          = 0;
    LET cNombre          = '';
    LET iFuncion         = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_usuarioscedulas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( ( pFechaConcil is null OR pFechaConcil = '' ) OR
         ( pTipo is null OR pTipo NOT IN(1, 2, 3, 4, 5, 6) ) ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cNombre, iFuncion;
    END IF;
    
    IF pTipo = 1 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'CAPITAL'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'CAPITAL'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 2 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTERES'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTERES'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 3 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'SOBREGIRO'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'SOBREGIRO'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 4 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 5 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INT PAGARE'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INT PAGARE'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    ELIF pTipo = 6 THEN
        SELECT COUNT(*) 
          INTO iExiste
          FROM bdicheq:sc_cedulacontableusuarios
         WHERE concepto = 'INTS E ISR'
           AND status = '1';
           
        IF iExiste > 0 THEN
            FOREACH
                SELECT nombre, funcion
                  INTO cNombre, iFuncion
                  FROM bdicheq:sc_cedulacontableusuarios
                 WHERE concepto = 'INTS E ISR'
                   AND status = '1'
                 
                RETURN cCodRet1, cNombre, iFuncion WITH RESUME;
            END FOREACH;
        ELSE
            LET cCodRet1 = '100';
            RETURN cCodRet1, cNombre, iFuncion;
        END IF;
    END IF;
    
    END;
    
END PROCEDURE;