CREATE PROCEDURE "informix".sp_actual_ctaclabe( pempresa CHAR(3), psucursal CHAR(4) )
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcuenta          CHAR(20);
    DEFINE vctaclabe        CHAR(18);    
    DEFINE vnewctaclabe     CHAR(18);
    DEFINE vcodret_ctaclabe CHAR(5);
    
    LET vcodret1         = '000';
    LET vcodret2         = '';
    LET vcodret3         = '';
    LET sql_err	         = 0;
    LET isam_err         = 0;
    LET desc_err         = '';
    LET vcontador1       = 0;
    LET vcontador2       = 0;
    LET vcomienza        = -1;
    LET ven_transacc     = 0;    
    LET vcuenta          = '';
    LET vctaclabe        = '';
    LET vnewctaclabe     = '';
    LET vcodret_ctaclabe = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actual_ctaclabe.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actual_ctaclabe.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    FOREACH WITH HOLD
        SELECT cuenta, cuenta_clabe
          INTO vcuenta, vctaclabe
          FROM sc_maechq
         WHERE empresa = pempresa
           AND sucursal = psucursal
           AND status_cta <> '2'
           AND producto <> '1100'
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        CALL ctaclabe( pempresa, vcuenta, psucursal )
        RETURNING vcodret_ctaclabe, vnewctaclabe;
        
        IF ( vcodret_ctaclabe = '000' AND ( vctaclabe <> vnewctaclabe ) ) THEN
            UPDATE sc_maechq
               SET cuenta_clabe = vnewctaclabe
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                LET vcontador2 = vcontador2 + 1;
                COMMIT WORK;
                BEGIN WORK;
            ELSE
                ROLLBACK WORK;
                BEGIN WORK;
            END IF;
        END IF;
        
        LET vcuenta = '';
        LET vctaclabe = '';
        LET vnewctaclabe = '';
        LET vcodret_ctaclabe = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;