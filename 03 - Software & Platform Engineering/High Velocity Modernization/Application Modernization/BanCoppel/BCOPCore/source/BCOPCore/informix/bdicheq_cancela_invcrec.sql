CREATE PROCEDURE "informix".cancela_invcrec(pempresa char(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE nComit           INTEGER;
    DEFINE vsql             CHAR(200);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(20);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE vsucursal        CHAR(4);
    DEFINE vimporte         MONEY(14,2);
    DEFINE vtransacc        CHAR(4);
    DEFINE vfecha_cargo     DATE;
    DEFINE vdispo           MONEY(14,2);
    DEFINE vcargo           MONEY(14,2);
    
    LET vcodret     = "000";
    LET vcodret2    = "000";
    LET sql_err     = 0;
    LET isam_err    = 0;
    LET nComit      = 0;
    LET vcuantos    = -1;
    LET vcontador   = 0;
    LET vsql        = '';
    LET vhora       = '';
    LET vfolio      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF nComit = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcontador;
        END IF;
    END EXCEPTION;

    -- SET DEBUG FILE TO "/resplogifx/conciliachq/cancela_invcrec.out";
    -- TRACE ON;
    
    LET vcuenta      = '';
    LET vsucursal    = '';
    LET vimporte     = 0.00;
    LET vtransacc    = '';
    LET vfecha_cargo = '';
    LET vdispo       = 0.00;
    LET vcargo       = 0.00;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'invcrecxcancelar') THEN
        DROP TABLE invcrecxcancelar;
    END IF;
    
    CREATE RAW TABLE invcrecxcancelar( cuenta char(20) ) LOCK MODE ROW;
    
    LET vsql = '';
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/inv_creciente_cancelar.unl INSERT INTO invcrecxcancelar" > /resplogifx/conciliachq/invcrecxcanc.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/invcrecxcanc.sql';
    -- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/invcrecxcanc.sql';
    SYSTEM vsql;
    
    UPDATE STATISTICS MEDIUM FOR TABLE invcrecxcancelar;

    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, sucursal, sdo_actual
          INTO vcuenta, vsucursal, vimporte
          FROM sc_maechq
         WHERE empresa = pempresa 
           AND cuenta IN (SELECT cuenta FROM invcrecxcancelar)

        IF vcuantos = -1 THEN
            BEGIN WORK;
            LET nComit = 1;
            LET vcuantos = 0;
        END IF
        
        CALL cargo_ref(pempresa, vsucursal, "informix", "0252", 
                       "0252", vfolio, vcuenta, 0, vimporte, "01", 
                       "CARGO POR CORRECCION", " ", "informix")
        RETURNING vcodret, vtransacc, vfecha_cargo, vdispo, vcargo;
        
        IF vcodret = '000' THEN
            UPDATE sc_maechq
               SET status_cta = '2'
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
        END IF;
        
        LET vcuantos = vcuantos + 1;
        
        IF vcuantos >= 1 THEN
            LET vcontador = vcontador +  vcuantos;
            LET vcuantos = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vsucursal = '';
        LET vimporte = 0.00;
        LET vtransacc = '';
        LET vfecha_cargo = '';
        LET vdispo = 0.00;
        LET vcargo = 0.00;

    END FOREACH

    IF nComit = 1 THEN
        LET nComit = 0;
        COMMIT WORK;
    END IF;

    END;
    
    DROP TABLE invcrecxcancelar;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;