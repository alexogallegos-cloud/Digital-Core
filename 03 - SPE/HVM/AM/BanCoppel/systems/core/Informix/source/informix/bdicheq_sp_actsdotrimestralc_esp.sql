CREATE PROCEDURE "informix".sp_actsdotrimestralc_esp( panio SMALLINT )
RETURNING CHAR(5), INTEGER;

    DEFINE vCodRet      CHAR(5);
    DEFINE vCodRet2     CHAR(5);
    DEFINE vCodRet3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE ven_transacc SMALLINT;
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;   
    DEFINE vcuenta      CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vcapvigprom1 DECIMAL(18,2);
    DEFINE vcapvigprom2 DECIMAL(18,2);
    DEFINE vcapvigprom3 DECIMAL(18,2);
    DEFINE vcappromtrim DECIMAL(18,2);
    
    LET vCodRet      = '000';
    LET vCodRet2     = '';
    LET vCodRet3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcuenta      = '';
    LET vsucursal    = '';
    LET vcapvigprom1 = 0.00;
    LET vcapvigprom2 = 0.00;
    LET vcapvigprom3 = 0.00;
    LET vcappromtrim = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/tmp/sp_actsdotrimestralc_esp.err";
        TRACE ON;
        IF vsqlerr != 0 THEN
            LET vCodRet  = vsqlerr;
            LET vCodRet2 = visamerr;
            LET vCodRet3 = vdescerr;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vCodRet, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/tmp/sp_actsdotrimestralc_esp.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    FOREACH WITH HOLD
        SELECT sdo.cuenta, sdo.sucursal, sdo.capvigprom1, sdo.capvigprom2, sdo.capvigprom3 
          INTO vcuenta, vsucursal, vcapvigprom1, vcapvigprom2, vcapvigprom3
          FROM sc_sdomensualc sdo,
               sc_maechq mae
         WHERE sdo.cuenta = mae.cuenta
           AND sdo.anio = panio
           AND mae.status_cta <> '2'
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
            LET ven_transacc = 1;
        END IF;
    
        LET vcappromtrim = ( ( vcapvigprom1 + vcapvigprom2 + vcapvigprom3) / 3 );
        
        INSERT INTO sc_sdotrimestralc VALUES
        ( vcuenta, panio, vsucursal, vcappromtrim, 0.00, 0.00, 0.00 );
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador2 = vcontador2 + 1;
        
        IF vcontador2 >= 1000 THEN
            LET vcontador2 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta      = '';
        LET vsucursal    = '';
        LET vcapvigprom1 = 0.00;
        LET vcapvigprom2 = 0.00;
        LET vcapvigprom3 = 0.00;
        LET vcappromtrim = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vCodRet, vcontador1;
    
END PROCEDURE;