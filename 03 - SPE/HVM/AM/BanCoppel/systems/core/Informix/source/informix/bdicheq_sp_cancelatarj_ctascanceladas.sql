CREATE PROCEDURE "informix".sp_cancelatarj_ctascanceladas( pcEmpresa  CHAR(3) )
RETURNING CHAR(5)  AS vcCodret1,
          CHAR(5)  AS vcCodret2,
          CHAR(50) AS vcCodret3,
          INTEGER  AS viContador;
    
    DEFINE vcCodret1    CHAR(5);
    DEFINE vcCodret2    CHAR(5);
    DEFINE vcCodret3    CHAR(50);
    DEFINE viSqlErr     INTEGER;
    DEFINE viIsamErr    INTEGER;
    DEFINE vcDescErr    CHAR(50);
    DEFINE viContador   INTEGER;
    DEFINE vComienza    SMALLINT;
    DEFINE viTransacc   SMALLINT;
    DEFINE vcCuenta     CHAR(20);
    DEFINE vcTarjeta    CHAR(16);
    
    LET vcCodret1  = '000';
    LET vcCodret2  = '000';
    LET vcCodret3  = 'PROCESO FINALIZADO CORRECTAMENTE';
    LET viSqlErr   = 0;
    LET viIsamErr  = 0;
    LET vcDescErr  = '';
    LET viContador = 0;
    LET vComienza  = 0;
    LET viTransacc = 0;
    LET vcCuenta   = '';
    LET vcTarjeta  = '';
    
    BEGIN
    
    ON EXCEPTION SET viSqlErr, viIsamErr, vcDescErr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelatarj_ctascanceladas.err";
        TRACE ON;
        IF viSqlErr <> 0 THEN
            LET vcCodret1 = viSqlErr;
            LET vcCodret2 = viIsamErr;
            LET vcCodret3 = vcDescErr;
            IF viTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcCodret1, vcCodret2, vcCodret3, viContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancelatarj_ctascanceladas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta 
          INTO vcCuenta
          FROM sc_maechq
         WHERE status_cta = '2'
         
        IF vComienza = -1 THEN
            LET vComienza = 0;
        END IF;
        
        BEGIN WORK;
        LET viTransacc = 1;
         
        FOREACH
            SELECT num_tarjeta
              INTO vcTarjeta
              FROM bdicheq:"informix".sc_tarjeta
             WHERE empresa = pcEmpresa
               AND cuenta = vcCuenta
               AND secuencia > 0
               AND status_tar = 'A'
        
            UPDATE bdicheq:"informix".sc_tarjeta
               SET status_tar = 'C'
             WHERE empresa = pcEmpresa
               AND cuenta = vcCuenta
               AND num_tarjeta = vcTarjeta;
               
            UPDATE intercard:"informix".tarjeta
               SET codstatustarjeta = 'CAN'
             WHERE numtarjeta = vcTarjeta;
        END FOREACH;
        
        LET viContador = viContador + 1;
           
        COMMIT WORK;
        LET viTransacc = 0;
        
        LET vcCuenta  = '';
        LET vcTarjeta = '';
    END FOREACH;
    
    END;
    
    RETURN vcCodret1, vcCodret2, vcCodret3, viContador;

END PROCEDURE;