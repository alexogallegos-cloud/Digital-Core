CREATE PROCEDURE "informix".sp_consctepros( pEmpresa char(3), pRFC char(20) )
RETURNING CHAR(5), CHAR(20);

    DEFINE viSqlErr      INTEGER;
    DEFINE viIsamErr     INTEGER;
    DEFINE vcDescErr     CHAR(50);
    DEFINE vcCodRet      CHAR(5);
    DEFINE vcCodRet2     CHAR(5);
    DEFINE vcCodRet3     CHAR(50);
    DEFINE vcNumPros     CHAR(20);
    
    LET viSqlErr  = 0;
    LET viIsamErr = 0;
    LET vcDescErr = 0;
    LET vcCodRet  = '00000';
    LET vcCodRet2 = '';
    LET vcCodRet3 = '';
    LET vcNumPros = '';

    --- SET DEBUG FILE TO "/informix/jivan/sp_consctepros.out";
    --- TRACE ON;

    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/tmp/sp_consctepros.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            LET vcNumPros  = '';
            RETURN vcCodRet, vcNumPros;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF ( pRFC is null OR pRFC = '' ) OR 
       ( pEmpresa is null OR pEmpresa = '' ) THEN
        LET vcCodRet = '00110';
        LET vcNumPros = '';
        RETURN vcCodRet, vcNumPros;
    END IF;
    
    SELECT numcte_pros
      INTO vcNumPros
      FROM pr_cliente
     WHERE rfc = pRFC;
     
    IF vcNumPros is null OR vcNumPros = '' THEN
        LET vcNumPros = '';
    ELSE
        LET vcNumPros = vcNumPros;
    END IF;

    RETURN vcCodRet, vcNumPros;
    
    END;
    
END PROCEDURE;