CREATE PROCEDURE "informix".sp_modintacum_pagares( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE ven_transacc CHAR(1);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    
    DEFINE vfecha_hoy       DATE;
    DEFINE vpri_hab_mes     DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       SMALLINT;
    DEFINE vfecha_alta      DATE;
    DEFINE vcapital         MONEY(14,2);
    DEFINE vvalor_tasa      DECIMAL(9,6);
    DEFINE vtasa            DECIMAL(9,6);
    DEFINE vdias            SMALLINT;
    DEFINE vprov_mes        MONEY(14,2);
    
    LET vcodret      = '';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET vsqlerr      = 0;
    LET visamerr     = 0;
    LET vdescerr     = '';
    LET ven_transacc = '0';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    
    LET vfecha_hoy     = '';
    LET vpri_hab_mes   = '';
    LET vcuenta        = '';
    LET vsecuencia     = 0;
    LET vfecha_alta    = '';
    LET vcapital       = 0.00;
    LET vvalor_tasa    = 0;
    LET vtasa          = 0;
    LET vdias          = 0;
    LET vprov_mes      = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modintacum_pagares.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modintacum_pagares.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    SELECT fecha_hoy, pri_hab_mes
      INTO vfecha_hoy, vpri_hab_mes
      FROM sv_fechas
     WHERE empresa = pempresa;
     
    FOREACH WITH HOLD
        SELECT cuenta, secuencia, fecha_alta, capital, tasa
          INTO vcuenta, vsecuencia, vfecha_alta, vcapital, vvalor_tasa
          FROM sv_maeinv
         WHERE status_cta = 1
           AND fecha_venc > vfecha_hoy
           AND fecha_alta < vfecha_hoy
            
        BEGIN WORK;
        LET ven_transacc = '1';
        
        LET vtasa = vvalor_tasa / 100;
        
        IF ( vfecha_alta > vpri_hab_mes ) THEN
            LET vdias = vfecha_hoy - vfecha_alta;
        ELSE 
            LET vdias = vfecha_hoy - vpri_hab_mes;
        END IF;
        
        LET vprov_mes = (((vcapital * vtasa) * vdias) / 360);
          
        UPDATE sv_maeinv
           SET sdo_ult_corte = vprov_mes
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND secuencia = vsecuencia;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
           
        COMMIT WORK;
        LET ven_transacc = '0';
        
        LET vcuenta     = '';
        LET vsecuencia  = 0;
        LET vfecha_alta = '';
        LET vcapital    = 0.00;
        LET vvalor_tasa = 0;
        LET vtasa       = 0;
        LET vdias       = 0;
        LET vprov_mes   = 0.00;
    END FOREACH;
    
    IF vcontador1 = vcontador2 THEN
        LET vcodret  = '000';
        LET vcodret2 = '000';
        LET vcodret3 = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    ELSE
        LET vcodret  = '999';
        LET vcodret2 = '999';
        LET vcodret3 = 'NO SE ACTUALIZARON TODAS LAS CUENTAS';
    END IF;
    
    END;
    
    RETURN vcodret, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;