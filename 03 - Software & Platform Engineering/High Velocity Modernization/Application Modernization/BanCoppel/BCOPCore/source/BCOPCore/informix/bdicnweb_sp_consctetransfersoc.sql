CREATE PROCEDURE "informix".sp_consctetransfersoc( pNumCte CHAR(20) )
RETURNING CHAR(5), CHAR(104), CHAR(13), CHAR(10);
    
    DEFINE cCodRet1     CHAR(5);
    DEFINE cCodRet2     CHAR(5);
    DEFINE cCodRet3     CHAR(50);
    DEFINE iSqlErr      INTEGER;
    DEFINE iSamErr      INTEGER;
    DEFINE cDesErr      CHAR(50);
    DEFINE iExiste      SMALLINT;
    DEFINE cNombreCte   CHAR(104);
    DEFINE cRFC         CHAR(13);
    DEFINE cTpoCte      CHAR(10);
    
    LET cCodRet1    = '000';
    LET cCodRet2    = '';
    LET cCodRet3    = '';
    LET iSqlErr	    = 0;
    LET iSamErr     = 0;
    LET cDesErr     = '';
    LET iExiste     = 0;
    LET cNombreCte  = '';
    LET cRFC        = '';
    LET cTpoCte     = '';
	
	BEGIN
    
    ON EXCEPTION SET iSqlErr, iSamErr, cDesErr
        SET DEBUG FILE TO "/tmp/sp_consctetransfersoc.err";
        TRACE ON;
        IF iSqlErr <> 0 THEN
            LET cCodRet1 = iSqlErr;
            LET cCodRet2 = iSamErr;
            LET cCodRet3 = cDesErr;
            RETURN cCodRet1, cNombreCte, cRFC, cTpoCte;
        END IF;
    END EXCEPTION;  
    
    --- SET DEBUG FILE TO "/tmp/sp_consctetransfersoc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT COUNT(*) 
      INTO iExiste
      FROM bditransfer:tf_maecte mae,
           bdinteg:si_cliente cte
     WHERE mae.numcte = pNumCte
       AND cte.numcte = mae.numcte;
       
    IF iExiste = 0 THEN
        LET cCodRet1 = '104';
        RETURN cCodRet1, cNombreCte, cRFC, cTpoCte;
    END IF;
    
    SELECT TRIM(cte.nombre1)||' '||TRIM(cte.nombre2)||' '||TRIM(cte.apell_paterno)||' '||TRIM(cte.apell_materno), cte.rfc, tpo.descripcion
      INTO cNombreCte, cRFC, cTpoCte
      FROM bdinteg:si_cliente cte,
           bdinteg:si_tipocte tpo
     WHERE cte.numcte = pNumCte
       AND tpo.tipo_cliente = cte.tipo_cliente;
       
    IF cNombreCte is null OR cNombreCte = '' THEN 
        LET cNombreCte = ' ';
    END IF;
    
    IF cRFC is null OR cRFC = '' THEN
        LET cRFC = ' ';
    END IF;
    
    IF cTpoCte is null OR cTpoCte = '' THEN
        LET cTpoCte = ' ';
    END IF;
    
    RETURN cCodRet1, cNombreCte, cRFC, cTpoCte;
    
    END;
    
END PROCEDURE;