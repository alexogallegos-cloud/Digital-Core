CREATE PROCEDURE "informix".recupera_retenido(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE nComit           SMALLINT;
    DEFINE vcuantos         INTEGER;
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vimporte         MONEY(18,2);

    BEGIN

    ON EXCEPTION SET sql_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/recupera_retenido.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/recupera_retenido.out";
    --- TRACE ON;

    LET vcodret1  = "000";
    LET vcodret2  = "000";
    LET sql_err   = 0;
    LET isam_err  = 0;
    LET nComit    = 0;
    LET vcuantos  = -1;
    
    LET vcuenta         = ''; 
    LET vimporte        = 0.00;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto_tot
          INTO vcuenta, vimporte
          FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta > '10000000000'
           AND transacc = '0830'
           AND folio_suc = 'informix23040100'
           
        IF vcuantos = -1 THEN
            LET nComit = 1;
            LET vcuantos = 0;
            BEGIN WORK;
        END IF;
        
        UPDATE sc_movdia
           SET cancelad = 'S'
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND transacc = '0830'
           AND folio_suc = 'informix23040100'
           AND monto_tot = vimporte;
           
        UPDATE sc_maechq
           SET sdo_actual = sdo_actual + vimporte
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
        
        LET vcuantos = vcuantos + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta         = ''; 
        LET vimporte        = 0.00;
    END FOREACH;

    IF nComit = 1 THEN
        COMMIT WORK;
        LET nComit = 0;
    END IF;

    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;