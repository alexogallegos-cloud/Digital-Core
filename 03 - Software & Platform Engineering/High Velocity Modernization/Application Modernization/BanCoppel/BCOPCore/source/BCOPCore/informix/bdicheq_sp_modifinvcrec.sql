CREATE PROCEDURE "informix".sp_modifinvcrec(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER, INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE ven_transacc SMALLINT;
    DEFINE vsql         CHAR(500);
    DEFINE vstmt        CHAR(250);
    DEFINE vcuenta      CHAR(20);
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO FINALIZADO';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET ven_transacc = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modifinvcrec.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_modifinvcrec.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 5;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxmodif') THEN
        DROP TABLE "informix".ctasxmodif;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxmodif
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxmodif ON "informix".ctasxmodif(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/invcrecxmodif.unl INSERT INTO ctasxmodif" > /resplogifx/conciliachq/invcrec.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/invcrec.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS HIGH FOR TABLE ctasxmodif;
    
    FOREACH WITH HOLD
        SELECT a.cuenta
          INTO vcuenta
          FROM ctasxmodif a,
               "informix".sc_maechq b
         WHERE a.cuenta = b.cuenta
           AND b.status_cta <> '2'
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        UPDATE "informix".sc_tasa_variable
           SET fin_periodo = '09/06/2013'
         WHERE empresa = pempresa
           AND cuenta = vcuenta
           AND tipo_tasa IN('M','P')
           AND fin_periodo = '09/05/2013';
           
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            UPDATE "informix".sc_maenoc
               SET fecha_alta = '09/06/2012',
                   fecha_mod = '09/06/2013'
             WHERE empresa = pempresa
               AND cuenta = vcuenta;
            IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
                UPDATE "informix".sc_maechq
                   SET fecha_proceso = '09/05/2013'
                 WHERE empresa = pempresa
                   AND cuenta = vcuenta;
                        
                COMMIT WORK;
                LET ven_transacc = 0;
                LET vcontador2 = vcontador2 + 1;
            ELSE
                ROLLBACK WORK;
                LET ven_transacc = 0;
                LET vcontador3 = vcontador3 + 1;
            END IF;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0;
            LET vcontador3 = vcontador3 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcuenta = '';
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;
    
    RETURN vcodret1, vcodret2, vcontador1, vcontador2, vcontador3;
    
END PROCEDURE;