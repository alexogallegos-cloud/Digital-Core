CREATE PROCEDURE "informix".reverso_atm( psucursal CHAR(4),   --- Sucursal
                                         pfolio    CHAR(16) ) --- Folio Operacion
RETURNING CHAR(5); --- Codigo de Retorno

    DEFINE vcCodRet1    CHAR(5);
    DEFINE vcCodRet2    CHAR(5);
    DEFINE vcCodRet3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE viDescErr    CHAR(50);
    DEFINE viEnTransac  SMALLINT;
    DEFINE viReversado  SMALLINT;
    DEFINE vcCodRetRev  CHAR(5);
    
    LET vcCodRet1   = '00000';
    LET vcCodRet2   = '';
    LET vcCodRet3   = '';
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET viDescErr   = 0;
    LET viEnTransac = 0;
    LET viReversado = 0;
    LET vcCodRetRev = '';
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/reverso_atm.out";
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, viDescErr
        SET DEBUG FILE TO '/resplogifx/conciliachq/reverso_atm.err';
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodRet1  = viSqlErr;
            LET vcCodRet2 = viIsamErr;
            LET vcCodRet3 = viDescErr;
            IF viEnTransac = 1 then
                ROLLBACK WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
            END IF
            LET vcCodRet1 = '00999';
            RETURN vcCodRet1;
        END IF;
    END EXCEPTION;
    
    ON EXCEPTION IN (-535)
        LET viEnTransac = 1;
    END EXCEPTION WITH resume;

    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        BEGIN WORK;
    END IF;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;    
    
    IF ( psucursal is null OR psucursal = '' OR LENGTH(psucursal) <> 4 ) OR
       ( pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16 ) THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00110';
        RETURN vcCodRet1;
    END IF;
    
    SELECT COUNT(*)
      INTO viReversado
      FROM bdicheq:"informix".sc_movdia
     WHERE cancelad = 'S'
       AND folio_suc = pfolio;
       
    IF viReversado > 0 THEN
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        LET vcCodRet1 = '00005';
        RETURN vcCodRet1;
    END IF;
    
    EXECUTE PROCEDURE bdicheq:reversion('001', psucursal, 'informix', pfolio, 'A')
    INTO vcCodRetRev;
    
    IF vcCodRetRev <> '000' THEN
        IF vcCodRetRev = '413' THEN
            LET vcCodRet1 = '00413';
        END IF;
        IF viEnTransac = 1 THEN
            ROLLBACK WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
        END IF;
        RETURN vcCodRet1;
    END IF;
    
    IF viEnTransac = 1 THEN
        COMMIT WORK;
        BEGIN WORK;
    ELSE
        COMMIT WORK; 
    END IF;
    
    END;
    
    RETURN vcCodRet1;

END PROCEDURE;