CREATE PROCEDURE "informix".sp_consulmontointeredo( pParametro CHAR(20) )
RETURNING CHAR(5), CHAR(60);
       
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE vcCodRet     CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE vcValParam   CHAR(60);
    
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET vcCodRet    = '000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET vcValParam  = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_consulmontointeredo.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/altamasempnet/sp_consulmontointeredo.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = vcDescErr;
            RETURN vcCodRet, vcValParam;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF pParametro is null OR pParametro = '' THEN
        LET vcCodRet = '110';
        LET vcValParam  = '';
        RETURN vcCodRet, vcValParam;
    END IF;
    
    SELECT valor
      INTO vcValParam
      FROM sc_param
     WHERE empresa = '001'
       AND codparam = pParametro;
       
    IF vcValParam is null THEN
        LET vcValParam = '';
    ELSE
        LET vcValParam = TRIM(vcValParam);
    END IF;
    
    RETURN vcCodRet, vcValParam;

    END;

END PROCEDURE;