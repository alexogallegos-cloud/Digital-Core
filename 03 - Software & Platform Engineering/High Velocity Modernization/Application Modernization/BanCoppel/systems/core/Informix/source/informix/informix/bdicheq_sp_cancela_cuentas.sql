CREATE PROCEDURE "informix".sp_cancela_cuentas(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;
    
    DEFINE vcodret1      CHAR(5);
    DEFINE vcodret2      CHAR(5);
    DEFINE vcodret3      CHAR(50);
    DEFINE sql_err       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE desc_err      CHAR(50);
    DEFINE vcontador1    INTEGER;
    DEFINE vcontador2    INTEGER;
    DEFINE vcomienza     SMALLINT;
    DEFINE ven_transacc  SMALLINT;
    DEFINE vsql          CHAR(500);
    DEFINE vstmt         CHAR(250);
    DEFINE vcuenta       CHAR(20);
    DEFINE vmotivo       CHAR(2);    
    DEFINE vusuario      CHAR(8);
    DEFINE vsucursal     CHAR(4);
    DEFINE vcodretcan1   CHAR(5);
    DEFINE vcodretcan2   CHAR(5);
    DEFINE vmsjretcan    CHAR(80);
    DEFINE vfolioretcanc CHAR(22);
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET vcomienza     = -1;
    LET ven_transacc  = 0;
    LET vsql          = '';
    LET vstmt         = '';
    LET vcuenta       = '';
    LET vmotivo       = '';
    LET vusuario      = '';
    LET vsucursal     = '';
    LET vcodretcan1   = '';
    LET vcodretcan2   = '';
    LET vmsjretcan    = '';
    LET vfolioretcanc = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_cuentas.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_cuentas.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cuentasxcancelar') THEN
        DROP TABLE "informix".cuentasxcancelar;
    END IF;
    
    CREATE TABLE "informix".cuentasxcancelar
      (
        cuenta   char(20) not null,
        motivo   char(2)  not null,
        usuario  char(8)  not null,
        sucursal char(4)  not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxcanc ON "informix".cuentasxcancelar(cuenta) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentasxcancelar.unl DELIMITER ''","'' INSERT INTO cuentasxcancelar;" > /resplogifx/conciliachq/ctasxcanc.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxcanc.sql';
    SYSTEM vstmt;
    
    UPDATE STATISTICS MEDIUM FOR TABLE cuentasxcancelar;
    
    FOREACH WITH HOLD
        SELECT cuenta, motivo, usuario, sucursal
          INTO vcuenta, vmotivo, vusuario, vsucursal
          FROM cuentasxcancelar
        
        BEGIN WORK;
        LET ven_transacc = 1;
        LET vcontador1 = vcontador1 + 1;
        
        CALL sp_cancelactachq(pempresa, vcuenta, vmotivo, vusuario, vsucursal)
        RETURNING vcodretcan1, vcodretcan2, vmsjretcan, vfolioretcanc;
               
        IF vcodretcan1 = '000' THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            LET ven_transacc = 0;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0;
        END IF;
        
        LET vcuenta = '';
        LET vmotivo = '';
        LET vusuario = '';
        LET vsucursal = '';
        LET vcodretcan1 = '';
        LET vcodretcan2 = '';
        LET vmsjretcan = '';
        LET vfolioretcanc = '';
    END FOREACH;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;