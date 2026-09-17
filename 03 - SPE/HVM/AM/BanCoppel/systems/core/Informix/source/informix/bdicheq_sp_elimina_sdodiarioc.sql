CREATE PROCEDURE "informix".sp_elimina_sdodiarioc(pempresa CHAR(3), paniomes CHAR(6))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   CHAR(50);
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcuantos     INTEGER;
    DEFINE vcommit      INTEGER;
    DEFINE vmincta      CHAR(20);
    DEFINE vmaxcta      CHAR(20);
    DEFINE vcuenta      CHAR(20);
    DEFINE vaniomes     CHAR(6);

    LET sql_err    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET vcomienza  = -1;
    LET vcuantos   = 0;
    LET vcommit    = 0;
    LET vmincta  = "";
    LET vmaxcta  = "";
    LET vaniomes = '';
    LET vcuenta = '';
    
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_elimina_sdodiarioc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            IF vcommit > 0 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcuantos;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_elimina_sdodiarioc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_sdodiarioc_2017;

    FOREACH WITH HOLD
        SELECT cuenta, aniomes 
          INTO vcuenta, vaniomes
          FROM sc_sdodiarioc_2017
         WHERE cuenta BETWEEN vmincta AND vmaxcta
           AND aniomes >= paniomes

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;

        DELETE FROM sc_sdodiarioc_2017
         WHERE cuenta = vcuenta
           AND aniomes = vaniomes;
        
        LET vcuantos = vcuantos + 1;
        LET vcommit = vcommit + 1; 
        
        IF vcommit >= 5000 THEN
            LET vcommit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;   
    END FOREACH;
    
    IF vcommit >= 0 THEN
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcuantos;
    
END PROCEDURE;