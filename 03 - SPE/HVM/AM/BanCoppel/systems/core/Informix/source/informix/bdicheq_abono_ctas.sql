CREATE PROCEDURE "informix".abono_ctas(pempresa CHAR(3))

    RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(200);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    
    LET vcodret	     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador    = -1;
    LET ven_transacc = 0;
    
    LET vsql         = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/abono_ctas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret, vcodret2, vcontador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/abono_ctas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxabonar') THEN
        DROP TABLE "informix".ctasxabonar;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxabonar
      (
        cuenta      char(20)    not null,
        monto       money(14,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxabon ON "informix".ctasxabonar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/abonos_26082010.unl DELIMITER ''","'' INSERT INTO ctasxabonar" > /resplogifx/conciliachq/atmchq.sql';
    SYSTEM vsql;
    LET vsql = '';
    -- LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/atmchq.sql';
    LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/atmchq.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxabonar;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto, transacc, descripcion
          INTO vcuenta, vmonto, vtransacc, vdescripcion
          FROM ctasxabonar
        
        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET ven_transacc = 1;
        END IF;
        
        LET vhora = CURRENT HOUR TO FRACTION;
        LET vfolio = 'informix'||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
        
        SELECT sucursal
          INTO vsucursal
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        CALL abono_ref( pempresa, vsucursal, "informix", vtransacc, "0000", vfolio, vcuenta, 
                        0, vmonto, vmonto, 0, 0, 0, "01", vdescripcion, " ", "informix" )
        RETURNING vcodret;
        
        LET vcuenta      = '';
        LET vmonto       = 0.00;
        LET vtransacc    = '';
        LET vdescripcion = '';
        LET vsucursal    = '';
        
        LET vcontador = vcontador + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    -- DROP TABLE "informix".ctasxabonar;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;