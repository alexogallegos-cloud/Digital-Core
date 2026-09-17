CREATE PROCEDURE "informix".sp_pagointinvcrec(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vfecha_hoy       DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vcuentadep       CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vproducto        CHAR(4);
    DEFINE vstatus_cta      CHAR(1);
    DEFINE vsdo_actual      MONEY(14,2);
    DEFINE vhora            DATETIME HOUR TO FRACTION;
    DEFINE vhoraw           CHAR(15);
    DEFINE vfolio_suc       CHAR(16);
    DEFINE vinteres         MONEY(14,2);
    DEFINE visr             MONEY(14,2);
    DEFINE vvalor_tasa      DECIMAL(9,6);
    DEFINE vtipo_tasa       CHAR(1);
    DEFINE vprovisionado    MONEY(14,2);
    DEFINE vprovision       MONEY(14,2);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO FINALIZADO';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcontador3    = 0;
    LET ven_transacc  = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vfecha_hoy    = '';
    LET vcuenta       = '';
    LET vcuentadep    = '';
    LET vsucursal     = '';
    LET vproducto     = '';
    LET vstatus_cta   = '';
    LET vsdo_actual   = 0.00;
    LET vhora         = '';
    LET vhoraw        = '';
    LET vfolio_suc    = '';
    LET vinteres      = 0.00;
    LET visr          = 0.00;
    LET vvalor_tasa   = 0.00;
    LET vtipo_tasa    = '';
    LET vprovisionado = 0.00;
    LET vprovision    = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pagointinvcrec.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_pagointinvcrec.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'invsxmodif') THEN
        DROP TABLE "informix".invsxmodif;
    END IF;
    
    CREATE RAW TABLE "informix".invsxmodif
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_invcrecxmod ON "informix".invsxmodif(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/invcrecxact.unl INSERT INTO invsxmodif" > /resplogifx/conciliachq/invcrec.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/invcrec.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS HIGH FOR TABLE invsxmodif;
    
    SELECT fecha_hoy
      INTO vfecha_hoy
      FROM "informix".sc_fechas
     WHERE empresa = pempresa;
    
    FOREACH WITH HOLD
        SELECT a.cuenta, b.sucursal, b.producto, b.status_cta, b.sdo_actual, c.int_acum, c.isr, c.valor_tasa, c.tipo_tasa
          INTO vcuenta, vsucursal, vproducto, vstatus_cta, vsdo_actual, vinteres, visr, vvalor_tasa, vtipo_tasa
          FROM invsxmodif a,
               sc_maechq b,
               sc_tasa_var_hist c
         WHERE a.cuenta = b.cuenta
           AND a.cuenta <> '11008532097'
           AND c.empresa = b.empresa
           AND c.cuenta = b.cuenta
           AND c.tipo_tasa IN('M','P')
           AND c.fin_periodo = '02/28/2013'
         ORDER BY a.cuenta, c.tipo_tasa
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vtipo_tasa = 'M' THEN
            SELECT monto_tot
              INTO vprovisionado
              FROM sc_movhis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND fech_alt = '01/31/2013'
               AND cancelad <> 'S'
               ANd transacc = '3381';
               
            IF vprovisionado is null THEN
                LET vprovisionado = 0.00;
            END IF;
            
            LET vprovision = vinteres - vprovisionado;
        ELSE
            LET vprovision = vinteres;
        END IF;
        
        IF vstatus_cta = '2' THEN
            SELECT cuentadep
              INTO vcuentadep
              FROM sc_maeinstrucc
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
               
            SELECT sucursal, producto, status_cta, sdo_actual
              INTO vsucursal, vproducto, vstatus_cta, vsdo_actual
              FROM sc_maechq
             WHERE empresa = pempresa
               AND cuenta = vcuentadep;
               
            LET vcuenta = vcuentadep;
        END IF;
        
        LET vhora = current hour to fraction;
        LET vhoraw = vhora;
        LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
        LET vfolio_suc = 'informix'||vhoraw[1,8];
        
        IF vinteres > 0 THEN
            INSERT INTO sc_movdia VALUES
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3381', vsucursal, vproducto, pempresa, 
              vcuenta, '', 0, vprovision, vprovision, 0, 0, 0, '', vstatus_cta, vsdo_actual, "0000", " ", vvalor_tasa, '', '', '');
              
            INSERT INTO sc_movdia VALUES
            ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3276', vsucursal, vproducto, pempresa, 
            vcuenta, '', 0, vinteres, vinteres, 0, 0, 0, '', vstatus_cta, vsdo_actual, "0000", " ", vvalor_tasa, '', '' ,'');
            
            IF visr > 0 THEN
                INSERT INTO sc_movdia VALUES
                ( 0, vfolio_suc, vsucursal, 'informix', vfecha_hoy, vfecha_hoy, vhora, '3277', vsucursal, vproducto, pempresa, 
                  vcuenta, '', 0, visr, visr, 0, 0, 0, '', vstatus_cta, vsdo_actual, "0000", " ", 0.0, '', '' ,'');
            END IF;
            
            UPDATE sc_maechq
               SET num_abonos_mes = num_abonos_mes + 1, 
                   imp_abonos_mes = imp_abonos_mes + vinteres, 
                   sdo_actual = sdo_actual + (vinteres - visr), 
                   ultpagoint = vfecha_hoy, 
                   chq_exp_mes = 0 
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vcuenta       = '';
        LET vcuentadep    = '';
        LET vsucursal     = '';
        LET vproducto     = '';
        LET vstatus_cta   = '';
        LET vsdo_actual   = 0.00;
        LET vhora         = '';
        LET vhoraw        = '';
        LET vfolio_suc    = '';
        LET vinteres      = 0.00;
        LET visr          = 0.00;
        LET vvalor_tasa   = 0.00;
        LET vtipo_tasa    = '';
        LET vprovisionado = 0.00;
        LET vprovision    = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;