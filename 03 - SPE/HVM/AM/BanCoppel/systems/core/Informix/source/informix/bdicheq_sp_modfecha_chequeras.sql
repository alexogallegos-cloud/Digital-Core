CREATE PROCEDURE "informix".sp_modfecha_chequeras(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

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
    DEFINE vfecha_alta      DATE;
    DEFINE vfecha_nueva     DATE;
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = 'PROCESO FINALIZADO';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET ven_transacc  = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    LET vfecha_alta  = '';
    LET vfecha_nueva = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modfecha_chequeras.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modfecha_chequeras.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cheqxmod') THEN
        DROP TABLE "informix".cheqxmod;
    END IF;
    
    CREATE TABLE "informix".cheqxmod
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cheqxmod ON "informix".cheqxmod(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/cuentas_1900.unl INSERT INTO cheqxmod" > /resplogifx/conciliachq/cheqxmod.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/cheqxmod.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS HIGH FOR TABLE "informix".cheqxmod;
    
    FOREACH WITH HOLD
        SELECT chq.cuenta, noc.fecha_alta
          INTO vcuenta, vfecha_alta
          FROM cheqxmod chq,
               sc_maenoc noc
         WHERE noc.empresa = pempresa
           AND noc.cuenta = chq.cuenta
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vfecha_nueva = LPAD(MONTH(vfecha_alta), 2, '0')||'/'||'26'||'/'||YEAR(vfecha_alta);
        
        UPDATE sc_maenoc
           SET fecha_alta = vfecha_nueva
         WHERE empresa = pempresa
           AND cuenta = vcuenta;
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            LET ven_transacc = 0;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0;
        END IF;
        
        LET vcuenta = '';
        LET vfecha_alta = '';
        LET vfecha_nueva = '';
    END FOREACH;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    
END PROCEDURE;