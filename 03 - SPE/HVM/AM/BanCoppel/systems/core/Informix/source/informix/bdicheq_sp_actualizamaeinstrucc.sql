CREATE PROCEDURE "informix".sp_actualizamaeinstrucc( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
     
    DEFINE vcodret1             char(5);
    DEFINE vcodret2             char(5);
    DEFINE vcodret3             char(50);
    DEFINE sql_err              integer;
    DEFINE isam_err             integer;
    DEFINE desc_err             char(50);
    DEFINE vcontador1           integer;
    DEFINE vcontador2           integer;
    DEFINE vcontador3           integer;
    DEFINE ven_transacc         smallint;
    DEFINE vcomienza            smallint;
    DEFINE vregistro            INTEGER;
    DEFINE vmincta, vmaxcta     CHAR(20);

    LET vcodret1     = "000";               
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err      = 0;                   
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;                   
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;                   
    LET vcomienza    = -1;  
    LET vregistro    = 0;
    LET vmincta      = '';
    LET vmaxcta      = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualizamaeinstrucc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actualizamaeinstrucc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maeinstrucc;

    FOREACH WITH HOLD
        SELECT rowid
          INTO vregistro
          FROM sc_maeinstrucc
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
          
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        UPDATE sc_maeinstrucc
           SET instrucc = '01'
         WHERE rowid = vregistro;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 2500 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
           
        LET vregistro = 0;
    END FOREACH;
    
    IF vcontador2 > 0 THEN
        LET vcontador2 = 0;
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_maeinstrucc;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;