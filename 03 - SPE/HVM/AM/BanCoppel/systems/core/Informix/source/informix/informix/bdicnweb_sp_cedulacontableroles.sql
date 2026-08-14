CREATE PROCEDURE "informix".sp_cedulacontableroles( pEmpresa CHAR(3) ) 
RETURNING CHAR(5), SMALLINT, CHAR(10);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE iTipoRol     SMALLINT;
    DEFINE cNombre      CHAR(10);    
    
    LET cCodRet1   = '000';
    LET cCodRet2   = '';
    LET cCodRet3   = '';
    LET iSqlErr	   = 0;
    LET iSamErr    = 0;
    LET cDesErr    = '';
    LET iExiste    = 0;
    LET iTipoRol   = 0;
    LET cNombre    = '';    
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_cedulacontableroles.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, iTipoRol, cNombre;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_cedulacontableroles.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pEmpresa is null OR pEmpresa <> '001' ) THEN
        LET cCodRet1 = '110';
        RETURN cCodRet1, iTipoRol, cNombre;
    END IF;
    
    SELECT COUNT(*)
      INTO iExiste
      FROM bdicheq:sc_cedulacontableroles;
      
    IF iExiste = 0 THEN
        LET cCodRet1 = '100';
        RETURN cCodRet1, iTipoRol, cNombre;
    END IF;
    
    FOREACH
        SELECT rol_usuario, descripcion_rol
          INTO iTipoRol, cNombre
          FROM bdicheq:sc_cedulacontableroles
          
        RETURN cCodRet1, iTipoRol, cNombre WITH RESUME;
    END FOREACH;
    
    END;
    
END PROCEDURE;