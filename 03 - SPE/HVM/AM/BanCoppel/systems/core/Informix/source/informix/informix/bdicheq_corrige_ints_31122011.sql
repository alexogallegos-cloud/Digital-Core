CREATE PROCEDURE "informix".corrige_ints_31122011(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER;
    
    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vsql             CHAR(200);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsaldo           MONEY(18,2);    
    DEFINE vinteres         MONEY(18,2);     
    
    LET vcodret	     = '000';
    LET vcodret2     = '000';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET vcontador    = -1;
    LET ven_transacc = 0;
    
    LET vsql         = '';
    LET vcuenta      = '';
    LET vsaldo       = 0.00;
    LET vinteres     = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_ints_31122011.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_ints_31122011.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxcorregir') THEN
        DROP TABLE "informix".ctasxcorregir;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcorregir
      (
        cuenta  char(20) not null,
        interes money(18,2) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcorr ON "informix".ctasxcorregir(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ints_31122011.unl INSERT INTO ctasxcorregir" > /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcorregir;
    
    FOREACH WITH HOLD
        SELECT cuenta, interes
          INTO vcuenta, vinteres
          FROM ctasxcorregir
        
        IF (vcontador = -1) THEN
            BEGIN WORK;
            LET vcontador = 0;
            LET ven_transacc = 1;
        END IF;
        
        UPDATE sc_sdodiarioc_2011
           SET intprovnp31 = vinteres
         WHERE cuenta = vcuenta
           AND aniomes = '201112';
        
        LET vcontador = vcontador + 1;
        
        LET vcuenta = '';
        LET vinteres = 0.00;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    DROP TABLE "informix".ctasxcorregir;
    
    END;

    RETURN vcodret, vcodret2, vcontador;

END PROCEDURE;