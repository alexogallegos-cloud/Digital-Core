CREATE PROCEDURE "informix".sp_usuarioscedulascons( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), CHAR(8), CHAR(104), CHAR(8), CHAR(10), CHAR(10);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cUsuario     CHAR(8);
    DEFINE cNombre      CHAR(104);
    DEFINE cFuncion     CHAR(8);
    DEFINE cConcepto    CHAR(10);
    DEFINE cEstatus     CHAR(10);
    DEFINE iFuncion     SMALLINT;
    DEFINE cStatus      CHAR(1);
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET iExiste    = 0;
    LET cUsuario   = '';
    LET cNombre    = '';
    LET cFuncion   = '';
    LET cConcepto  = '';
    LET cEstatus   = '';
    LET iFuncion   = 0;
    LET cStatus    = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_usuarioscedulascons.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cUsuario, cNombre, cFuncion, cConcepto, cEstatus;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_usuarioscedulascons.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pEmpresa is null OR pEmpresa <> '001' THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, cUsuario, cNombre, cFuncion, cConcepto, cEstatus;
    END IF;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bdicheq:sc_cedulacontableusuarios
     WHERE concepto IN('CAPITAL','INTERES','SOBREGIRO','PAGARE','INT PAGARE','INTS E ISR')
       AND status IN('1','2');
       
    IF iExiste > 0 THEN
        FOREACH
            SELECT usuario, nombre, funcion, concepto, status
              INTO cUsuario, cNombre, iFuncion, cConcepto, cStatus
              FROM bdicheq:sc_cedulacontableusuarios
             WHERE concepto IN('CAPITAL','INTERES','SOBREGIRO','PAGARE','INT PAGARE','INTS E ISR')
               AND status IN('1','2')
              
            IF iFuncion = 1 THEN
                LET cFuncion = 'ELABORA';
            ELIF iFuncion = 2 THEN
                LET cFuncion = 'REVISA';
            ELIF iFuncion = 3 THEN
                LET cFuncion = 'AUTORIZA';
            END IF;
            
            IF cStatus = '1' THEN
                LET cEstatus = 'ACTIVO';
            ELIF cStatus = '2' THEN
                LET cEstatus = 'INACTIVO';
            END IF;
              
            RETURN cCodRet1, cUsuario, cNombre, cFuncion, cConcepto, cEstatus WITH RESUME;
        END FOREACH;
    ELSE
        LET cCodRet1 = '100';
        RETURN cCodRet1, cUsuario, cNombre, cFuncion, cConcepto, cEstatus;
    END IF;
    
    END;
    
END PROCEDURE;