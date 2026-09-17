CREATE PROCEDURE "informix".sp_cobrosbg_pba(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    
    DEFINE vfecha           DATE;
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vproducto        CHAR(4);
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vsdo_actual      MONEY(18,2);    
    DEFINE vsdo_retenido    MONEY(18,2);    
    DEFINE vsdo_cong        MONEY(18,2);    
    DEFINE vimp_chq_sbg     MONEY(18,2);    
    DEFINE vsdo_disp        MONEY(18,2);
    
    LET vcodret1	 = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    
    LET vfecha  = '';
    LET vhora   = '';
    LET vfolio  = '';
    
    LET vcuenta       = '';
    LET vsucursal     = '9250';
    LET vproducto     = '';
    LEt vsuc_cta      = '';
    LET vsdo_actual   = 0.00;
    LET vsdo_retenido = 0.00;
    LET vsdo_cong     = 0.00;
    LET vimp_chq_sbg  = 0.00;
    LET vsdo_disp     = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cobrosbg.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy
      INTO vfecha
      FROM sc_fechas
     WHERE empresa = pempresa;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq maecheques)} cuenta, producto, sucursal, sdo_actual, sdo_retenido, sdo_cong, imp_chq_sbg
          INTO vcuenta, vproducto, vsuc_cta, vsdo_actual, vsdo_retenido, vsdo_cong, vimp_chq_sbg
          FROM sc_maechq
         ---WHERE status_cta NOT IN('2','6','7','8')
          WHERE num_cte between '000001001' and '900000006'    
            AND ( ( status_cta != '2' ) OR 
                  ( status_cta != '6' ) OR 
                  ( status_cta != '7' ) OR 
                  ( status_cta != '8' ) )
           AND imp_chq_sbg > 0.00
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vsdo_disp = vsdo_actual - (vsdo_retenido + vsdo_cong);
        
        IF vsdo_disp > 0.00 THEN
        
            IF vsdo_disp >= vimp_chq_sbg THEN
            
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vimp_chq_sbg, 0, 0, 0, 0, " ", " ", vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix" );
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vimp_chq_sbg,
                       imp_chq_sbg = 0.00
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            ELIF vsdo_disp < vimp_chq_sbg THEN
            
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio, vsucursal, "informix", vfecha, vfecha, vhora, '3247', vsuc_cta, vproducto, pempresa, vcuenta, 
                  " ", 0, vsdo_disp, 0, 0, 0, 0, " ", " ", vsdo_actual, '0000', "COBRO PENDIENTE DE SOBREGIRO", 0, " ", "informix" );
                  
                IF ( dbinfo('sqlca.sqlerrd2') = 0 ) THEN
                    IF ven_transacc = 1 THEN
                        ROLLBACK WORK;
                        BEGIN WORK;
                    ELSE
                        ROLLBACK WORK;
                    END IF;
                    CONTINUE FOREACH;
                END IF;
                
                UPDATE sc_maechq
                   SET sdo_actual  = sdo_actual - vsdo_disp,
                       imp_chq_sbg = imp_chq_sbg - vsdo_disp
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                
            END IF;
        
            LET vcontador2 = vcontador2 + 1;
            
        END IF;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
        LET vproducto     = '';
        LEt vsuc_cta      = '';
        LET vsdo_actual   = 0.00;
        LET vsdo_retenido = 0.00;
        LET vsdo_cong     = 0.00;
        LET vimp_chq_sbg  = 0.00;
        LET vsdo_disp     = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;