CREATE PROCEDURE "informix".sp_updsdosctasconc(pempresa CHAR(3))
RETURNING CHAR(5)  AS vcodret1, 
          CHAR(5)  AS vcodret2, 
          CHAR(50) AS vcodret3,
          INTEGER  AS vcontador;

    DEFINE vcodret1    CHAR(5);
    DEFINE vcodret2    CHAR(5);
    DEFINE vcodret3    CHAR(50);
    DEFINE sql_err     INTEGER;
    DEFINE isam_err    INTEGER;
    DEFINE desc_err    CHAR(50);
    DEFINE vcomienza   SMALLINT;
    DEFINE ventransacc SMALLINT;
    DEFINE vcontador   INTEGER;
    DEFINE vcuenta     CHAR(20);
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET vcodret3    = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = ''; 
    LET vcomienza   = 0;
    LET ventransacc = 0;
    LET vcontador   = 0;
    LET vcuenta     = '';
    
    BEGIN

    ON EXCEPTION
        SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_updsdosctasconc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ventransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_updsdosctasconc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM bdicheq:"informix".sc_maechq
         WHERE status_cta = '6'
           AND sdo_dia_ant > 0.00
           
        IF vcomienza = 0 THEN
            LET vcomienza = 1;
            LET ventransacc = 1;
            BEGIN WORK;
        END IF;
           
        UPDATE bdicheq:"informix".sc_maechq
           SET sdo_dia_ant = 0.00
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        UPDATE bdicheq:"informix".sc_sdodiarioc
           SET capvig15 = 0.00,
               capvig16 = 0.00,
               capvig17 = 0.00,
               capvig18 = 0.00,
               capvig19 = 0.00,
               capvig20 = 0.00,
               capvig21 = 0.00,
               capvig22 = 0.00
         WHERE aniomes = '201112'
           AND cuenta = vcuenta;
           
        COMMIT WORK;
        BEGIN WORK;
           
        LET vcontador = vcontador + 1;
        LET vcuenta   = '';
    END FOREACH;
    
    IF ventransacc = 1 THEN
        LET ventransacc = 0;
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador;

END PROCEDURE;