CREATE PROCEDURE "informix".sp_cargosideesp(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vcodret_cargo    CHAR(5);
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vaniomes         CHAR(6);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    DEFINE vtransacc        CHAR(4);
    DEFINE vdescripcion     CHAR(40);
    DEFINE vsucursal        CHAR(4);  
    DEFINE vusuario         CHAR(8);
    DEFINE vmoneda          CHAR(2);
    DEFINE vtranret         CHAR(4);
    DEFINE vfechoy          DATE;
    DEFINE vsdodisp         DECIMAL(18,2);
    DEFINE vmontoret        DECIMAL(18,2);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vcodret_cargo = '';
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vaniomes     = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vtransacc    = '';
    LET vdescripcion = '';
    LET vsucursal    = '';
    LET vusuario     = 'informix';
    LET vmoneda      = '01';
    LET vtranret     = '';
    LET vfechoy      = '';
    LET vsdodisp     = 0.00;
    LET vmontoret    = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cargosideesp.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cargosideesp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxcargaride') THEN
        DROP TABLE "informix".ctasxcargaride;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcargaride
      (
        aniomes     char(4)     not null,
        cuenta      char(20)    not null,
        sucursal    char(4)     not null,
        monto       money(18,2) not null,
        transacc    char(4)     not null,
        descripcion char(40)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcargaride ON "informix".ctasxcargaride(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cargos_esp_ide.unl DELIMITER ''","'' INSERT INTO ctasxcargaride" > /resplogifx/conciliachq/cargoside.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cargoside.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcargaride;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT aniomes, cuenta, sucursal, monto, transacc, descripcion
          INTO vaniomes, vcuenta, vsucursal, vmonto, vtransacc, vdescripcion
          FROM ctasxcargaride
         ORDER BY aniomes, cuenta
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        CALL cargo_ref( pempresa,       -- empresa
                        vsucursal,      -- sucursal
                        vusuario,       -- usuario
                        vtransacc,      -- transaccion
                        '0000',         -- transacc suc
                        vfolio,         -- folio
                        vcuenta,        -- cuenta
                        0,              -- cheque
                        vmonto,         -- monto
                        vmoneda,        -- divisa
                        vdescripcion,   -- referencia
                        ' ',            -- num tarjeta
                        vusuario )      -- autoriza
        RETURNING vcodret_cargo, vtranret, vfechoy, vsdodisp, vmontoret;
        
        IF vcodret_cargo = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE 
            ROLLBACK WORK;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vaniomes      = '';
        LET vcuenta       = '';
        LET vsucursal     = '';
        LET vmonto        = 0.00;
        LET vtransacc     = '';
        LET vdescripcion  = '';
        LET vcodret_cargo = '';
        LET vtranret      = '';
        LET vfechoy       = '';
        LET vsdodisp      = 0.00;
        LET vmontoret     = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;