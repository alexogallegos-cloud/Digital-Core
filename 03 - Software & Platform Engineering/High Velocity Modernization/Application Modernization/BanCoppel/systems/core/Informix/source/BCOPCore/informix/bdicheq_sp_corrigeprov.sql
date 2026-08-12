CREATE PROCEDURE "informix".sp_corrigeprov(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vfecha_hoy       DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);   
    DEFINE vsuc_cta         CHAR(4);
    DEFINE vproducto        CHAR(4);
    DEFINE vsdo_actual      MONEY(16,2);
    DEFINE vtransacc        CHAR(4);
    DEFINE vsucursal        CHAR(4);  
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET ven_transacc  = 0;
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vfecha_hoy   = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vsuc_cta     = '';
    LET vproducto    = '';
    LET vsdo_actual  = 0.00;
    LET vtransacc    = '';
    LET vsucursal    = '9250';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigeprov.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_corrigeprov.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxprovisionar') THEN
        DROP TABLE "informix".ctasxprovisionar;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxprovisionar
      (
        cuenta  char(20)    not null,
        monto   money(14,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxprov ON "informix".ctasxprovisionar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/prov_falta_24122013.unl DELIMITER ''","'' INSERT INTO ctasxprovisionar" > /resplogifx/conciliachq/ctasprov.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasprov.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxprovisionar;
    
    LET vfecha_hoy = '12/24/2013';
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT ctas.cuenta, ctas.monto, mae.sucursal, mae.producto, mae.sdo_actual
          INTO vcuenta, vmonto, vsuc_cta, vproducto, vsdo_actual
          FROM ctasxprovisionar ctas,
               sc_maechq mae
         WHERE ctas.cuenta = mae.cuenta
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        IF vmonto > 0 THEN
            LET vmonto = vmonto;
            LET vtransacc = '3381';
        ELSE
            LET vmonto = vmonto * -1;
            LET vtransacc = '3382';
        END IF;
        
        INSERT INTO sc_movhis VALUES
        ( '201312', 0, vfolio, vsucursal, "informix", vfecha_hoy, vfecha_hoy, vhora, vtransacc, vsuc_cta, vproducto, 
          pempresa, vcuenta, "", 0, vmonto, vmonto, 0, 0, 0, "", "", vsdo_actual, "0000", "", 0, "", "informix", "" );
          
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            UPDATE sc_sdodiarioc
               SET intprovnp24 = 0.00
             WHERE cuenta = vcuenta
               AND aniomes = '201312';
               
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                COMMIT WORK;
                LET ven_transacc = 0;
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0;
            END IF;
        ELSE 
            ROLLBACK WORK;
            LET ven_transacc = 0;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vcuenta     = '';
        LET vmonto      = 0.00;
        LET vsuc_cta    = '';
        LET vproducto   = '';
        LET vsdo_actual = 0.00;
        LET vtransacc   = '';
    END FOREACH;
    
    END;
    
    RETURN vcodret1, vcodret2, vcontador1;
    
END PROCEDURE;