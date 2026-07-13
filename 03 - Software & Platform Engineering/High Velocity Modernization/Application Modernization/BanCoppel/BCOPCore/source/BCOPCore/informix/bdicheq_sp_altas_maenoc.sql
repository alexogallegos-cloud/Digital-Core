CREATE PROCEDURE "informix".sp_altas_maenoc(pempresa CHAR(3))
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
    DEFINE vcuenta          CHAR(20);
    
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
    LET vcuenta      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altas_maenoc.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_altas_maenoc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctassinmaenoc') THEN
        DROP TABLE "informix".ctassinmaenoc;
    END IF;
    
    CREATE RAW TABLE "informix".ctassinmaenoc
      (
        cuenta      char(20)    not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasinnoc ON "informix".ctassinmaenoc(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_sin_maenoc.unl DELIMITER ''","'' INSERT INTO ctassinmaenoc" > /resplogifx/conciliachq/ctassinnoc.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctassinnoc.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctassinmaenoc;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM ctassinmaenoc
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        IF EXISTS( SELECT cuenta FROM sc_maenoc WHERE empresa = pempresa AND cuenta = vcuenta ) THEN
            CONTINUE FOREACH;
        END IF;
        
        INSERT INTO sc_maenoc VALUES
        ( pempresa, vcuenta, "00", '1', '1', '001', ' ', '1', 0, 0, " ", 
          0, " ", " ", 0, 0, 0, 0, 0, 0, 0, 0, ' ', '05/03/2011', " ", " ", 0, 0, 'M', " ", 0, 0, 0, 0);
        
        LET vcontador2 = vcontador2 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta       = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;