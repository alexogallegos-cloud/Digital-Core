CREATE PROCEDURE "informix".sp_desbloq_ctas(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vcuenta          CHAR(20);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET ven_transacc = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloq_ctas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloq_ctas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasxdesbloq') THEN
        DROP TABLE "informix".cuentasxdesbloq;
    END IF;
    
    CREATE TABLE "informix".cuentasxdesbloq
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cuentaxdesbloq ON "informix".cuentasxdesbloq(cuenta) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasxdesbloq.csv INSERT INTO cuentasxdesbloq" > /resplogifx/conciliachq/ctas_desbloq.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctas_desbloq.sql';
    SYSTEM vstmt;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentasxdesbloq;
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM cuentasxdesbloq
          
        LET vcontador1 = vcontador1 + 1;
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        DELETE FROM cuentas
         WHERE cuenta = vcuenta;
         
        DELETE FROM sc_ctabloqueo
         WHERE cuenta = vcuenta;
         
        UPDATE sc_maechq
           SET status_cta = '1',
               motivo = ''
         WHERE cuenta = vcuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        COMMIT WORK;
        LET ven_transacc = 0;
        
        LET vcuenta = '';
    END FOREACH;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;