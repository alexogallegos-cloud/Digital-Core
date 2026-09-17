CREATE PROCEDURE "informix".sp_bloqctasinformadas( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE vtrxabierta  SMALLINT;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcuenta      CHAR(20);
    
    LET vcodret1    = '000';
    LET vcodret2    = '';
    LET vcodret3    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vcomienza   = -1;
    LET vtrxabierta = 0;
    LET vcontador1  = 0;
    LET vcontador2  = 0;
    LET vcuenta     = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqctasinformadas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
        END IF;
        RETURN vcodret1, vcontador1;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_bloqctasinformadas.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '5'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vtrxabierta = '1';
            BEGIN WORK;
        END IF;
        
        UPDATE sc_maechq
           SET motivo = '55'
         WHERE cuenta = vcuenta;
         
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF vtrxabierta = 1 THEN
        COMMIT WORK;
        LET vtrxabierta = 0;
    END IF;

    RETURN vcodret1, vcontador1;
    
    END;

END PROCEDURE;