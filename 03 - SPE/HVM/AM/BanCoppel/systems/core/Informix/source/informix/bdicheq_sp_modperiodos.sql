CREATE PROCEDURE "informix".sp_modperiodos( pcEmpresa  CHAR(3) )
RETURNING CHAR(5)  AS vcCodret1,
          CHAR(5)  AS vcCodret2,
          CHAR(50) AS vcCodret3,
          INTEGER  AS viContador1,
          INTEGER  AS viContador2;
    
    DEFINE vcCodret1    CHAR(5);
    DEFINE vcCodret2    CHAR(5);
    DEFINE vcCodret3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viContador1  INTEGER;
    DEFINE viContador2  INTEGER;
    DEFINE viTransacc   SMALLINT;
    DEFINE vcCuenta     CHAR(20);
    
    LET vcCodret1   = '000';
    LET vcCodret2   = '000';
    LET vcCodret3   = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET viSqlErr    = 0;
    LET viIsamErr   = 0;
    LET vcDescErr   = '';
    LET viContador1 = 0;
    LET viContador2 = 0;
    LET viTransacc  = 0;
    LET vcCuenta    = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modperiodos.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodret1 = viSqlErr;
            LET vcCodret2 = viIsamErr;
            LET vcCodret3 = vcDescErr;
            IF viTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodret1, vcCodret2, vcCodret3, viContador1, viContador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modperiodos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ; 
    SET LOCK MODE TO WAIT 5; 
    
    FOREACH WITH HOLD
        SELECT cuenta 
          INTO vcCuenta
          FROM sc_maehis_2013
         WHERE empresa = pcEmpresa
           AND cuenta >= '10000005016'
           AND fechaini = '04/26/2013'
           AND fechafin = '05/25/2013'
         
        BEGIN WORK;
        LET viTransacc = 1;
         
        UPDATE sc_maehis_2013
           SET aniomes = '201304'
         WHERE empresa = pcEmpresa
           AND cuenta = vcCuenta
           AND fechaini = '04/26/2013'
           AND fechafin = '05/25/2013';
           
        DELETE FROM sc_maehis
         WHERE empresa = pcEmpresa
           AND aniomes >= '000000'
           AND cuenta = vcCuenta
           AND fechaini = '04/26/2013'
           AND fechafin = '05/25/2013';
           
        INSERT INTO sc_maehis
        SELECT *
          FROM sc_maehis_2013
         WHERE empresa = pcEmpresa
           AND cuenta = vcCuenta
           AND fechaini = '04/26/2013'
           AND fechafin = '05/25/2013';
           
        LET viContador1 = viContador1 + 1;
           
        COMMIT WORK;
        LET viTransacc = 0;
        
        LET vcCuenta  = '';
    END FOREACH;
    
    FOREACH WITH HOLD
        SELECT cuenta 
          INTO vcCuenta
          FROM sc_maehis
         WHERE empresa = pcEmpresa
           AND aniomes >= '000000'
           AND cuenta >= '10000005016'
           AND fechaini = '04/27/2013'
           AND fechafin = '05/26/2013'
         
        BEGIN WORK;
        LET viTransacc = 1;
         
        UPDATE sc_maehis
           SET aniomes = '201304'
         WHERE empresa = pcEmpresa
           AND aniomes >= '000000'
           AND cuenta = vcCuenta
           AND fechaini = '04/27/2013'
           AND fechafin = '05/26/2013';
           
        LET viContador2 = viContador2 + 1;
           
        COMMIT WORK;
        LET viTransacc = 0;
        
        LET vcCuenta  = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodret1, vcCodret2, vcCodret3, viContador1, viContador2;

END PROCEDURE;