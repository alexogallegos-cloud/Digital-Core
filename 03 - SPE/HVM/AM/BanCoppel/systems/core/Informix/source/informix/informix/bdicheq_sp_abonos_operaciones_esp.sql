CREATE PROCEDURE "informix".sp_abonos_operaciones_esp(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(14,2);    
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones_esp.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_abonos_operaciones_esp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxabonaresp') THEN
        DROP TABLE "informix".ctasxabonaresp;
    END IF;
    
    CREATE TABLE "informix".ctasxabonaresp
      (
        cuenta      char(20)    not null,
        sdo_cuenta  money(18,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxabon_esp ON "informix".ctasxabonaresp(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/abonos.unl INSERT INTO ctasxabonaresp" > /resplogifx/conciliachq/abonos_esp.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/abonos_esp.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxabonaresp;
    
    FOREACH WITH HOLD
        SELECT cuenta, sdo_cuenta
          INTO vcuenta, vmonto
          FROM ctasxabonaresp
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        UPDATE sc_maechq
          SET sdo_actual = vmonto
         WHERE cuenta = vcuenta;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        
        LET vcuenta       = '';
        LET vmonto        = 0.00;
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;