CREATE PROCEDURE "informix".sp_abonos_operaciones(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcodret_abono    CHAR(5);
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vusuario         CHAR(8);
    DEFINE vmoneda          CHAR(2);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vcodret_abono = '';
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '9250';
    LET vusuario     = 'informix';
    LET vmoneda      = '01';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxabonar') THEN
        DROP TABLE "informix".ctasxabonar;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxabonar
      (
        cuenta      char(20)    not null,
        monto       money(18,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxabon ON "informix".ctasxabonar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/abonos_operaciones.unl DELIMITER ''","'' INSERT INTO ctasxabonar" > /resplogifx/conciliachq/abonos.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/abonos.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxabonar;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta, monto, transacc, descripcion
          INTO vcuenta, vmonto, vtransacc, vdescripcion
          FROM ctasxabonar
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        CALL abono_ref( pempresa,       -- empresa
                        vsucursal,         -- sucursal
                        vusuario,       -- usuario
                        vtransacc,      -- transaccion
                        '0000',         -- transacc suc
                        vfolio,         -- folio
                        vcuenta,        -- cuenta
                        0,              -- cheque
                        vmonto,         -- monto
                        vmonto,         -- monto firme
                        0,              -- monto sbc
                        0,              -- monto rem
                        0,              -- dias ret
                        vmoneda,        -- divisa
                        vdescripcion,   -- referencia
                        ' ',            -- num tarjeta
                        vusuario )      -- autoriza
        RETURNING vcodret_abono;
        
        IF vcodret_abono = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE 
            ROLLBACK WORK;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vcuenta       = '';
        LET vmonto        = 0.00;
        LET vtransacc     = '';
        LET vdescripcion  = '';
        LET vcodret_abono = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;