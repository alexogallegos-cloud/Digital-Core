CREATE PROCEDURE "informix".sp_desprov_pagares( pempresa char(3) )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER, INTEGER;
    
    DEFINE vcodret      CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vsqlerr      INTEGER;
    DEFINE visamerr     INTEGER;
    DEFINE vdescerr     CHAR(50);
    DEFINE ven_transacc CHAR(1);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    
    DEFINE vsql             CHAR(300);
    DEFINE vstmt            CHAR(100);
    DEFINE vfecha_hoy       DATE;
    DEFINE vpri_hab_mes     DATE;
    DEFINE vdias            SMALLINT;
    DEFINE vtrx_desprov     CHAR(4);
    DEFINE vhora            CHAR(15);
    DEFINE vfoliosuc        CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       SMALLINT;
    DEFINE vmonto_desprov   MONEY(14,2);
    DEFINE vcod_instrum     CHAR(4);
    DEFINE vplaza           CHAR(3);
    DEFINE vsucursal        CHAR(4);
    DEFINE vcapital         MONEY(14,2);
    DEFINE vvalor_tasa      DECIMAL(9,6);
    DEFINE vhoratrx         CHAR(12);
    DEFINE vtasa            DECIMAL(9,6);
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
    LET vcontador3   = 0;
    
    LET vsql           = '';
    LET vstmt          = '';
    LET vfecha_hoy     = '';
    LET vpri_hab_mes   = '';
    LET vdias          = 0;
    LET vtrx_desprov   = '';
    LET vhora          = '';
    LET vfoliosuc      = '';
    LET vcuenta        = '';
    LET vsecuencia     = 0;
    LET vmonto_desprov = 0.00;
    LET vcod_instrum   = '';
    LET vplaza         = '';
    LET vsucursal      = '';
    LET vcapital       = 0.00;
    LET vvalor_tasa    = 0;
    LET vhoratrx       = '';
    LET vtasa          = 0;
    LET vprov_mes      = 0.00;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr, vdescerr
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desprov_pagares.err";
        TRACE ON;
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            LET vcodret2 = visamerr;
            LET vcodret3 = vdescerr;
            IF ven_transacc = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desprov_pagares.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'pagaresxdesprov' ) THEN
        DROP TABLE "informix".pagaresxdesprov;
    END IF;
    
    CREATE TABLE "informix".pagaresxdesprov
      (
        cuenta          char(20)    not null,
        secuencia       smallint    not null,
        monto_desprov   money(18,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idxtmp_pagxdesprov ON "informix".pagaresxdesprov(cuenta) USING BTREE FILLFACTOR 99;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/pagaresxdesprovisionar.unl DELIMITER ''","'' INSERT INTO pagaresxdesprov" > /resplogifx/conciliachq/querypag.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/querypag.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE pagaresxdesprov;
    
    SELECT fecha_hoy, pri_hab_mes
      INTO vfecha_hoy, vpri_hab_mes
      FROM sv_fechas
     WHERE empresa = pempresa;
     
    LET vdias = vfecha_hoy - vpri_hab_mes;
    
    SELECT valor
      INTO vtrx_desprov
      FROM bdinvers:sv_param
     WHERE empresa = pempresa
       AND codparam = 'tranrevprov';
       
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfoliosuc = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT pag.cuenta, pag.secuencia, pag.monto_desprov, mae.cod_instrum, mae.plaza, mae.sucursal, mae.capital, mae.tasa
          INTO vcuenta, vsecuencia, vmonto_desprov, vcod_instrum, vplaza, vsucursal, vcapital, vvalor_tasa
          FROM pagaresxdesprov pag,
               sv_maeinv mae
         WHERE mae.empresa = pempresa
           AND mae.cuenta = pag.cuenta
           AND mae.secuencia = pag.secuencia
            
        BEGIN WORK;
        LET ven_transacc = '1';
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vhoratrx = current hour to fraction(3);
        
        INSERT INTO sv_movdia VALUES
        ( pempresa, 0, vfoliosuc, vplaza, '9250', 'informix', vfecha_hoy, vhoratrx, vtrx_desprov, vsucursal, 
          vcuenta, vsecuencia, vcod_instrum, 0, vmonto_desprov, vmonto_desprov, 0.00, 0.00, '', vcapital, '0000' );
          
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
          
        LET vtasa = vvalor_tasa / 100;
        LET vprov_mes = (((vcapital * vtasa) * vdias) / 360);
          
        UPDATE sv_maeinv
           SET sdo_ult_corte = vprov_mes
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND secuencia = vsecuencia;
           
        IF dbinfo('sqlca.sqlerrd2') > 0 THEN
            LET vcontador3 = vcontador3 + 1;
        END IF;
           
        COMMIT WORK;
        LET ven_transacc = '0';
    END FOREACH;
    
    IF ((vcontador1 = vcontador2) AND (vcontador1 = vcontador3)) THEN
        LET vcodret  = '000';
        LET vcodret2 = '000';
        LET vcodret3 = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    ELSE
        LET vcodret  = '999';
        LET vcodret2 = '999';
        LET vcodret3 = 'NO SE ACTUALIZARON TODAS LAS CUENTAS';
    END IF;
    
    RETURN vcodret, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;
    
    END;
    
END PROCEDURE;