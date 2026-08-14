CREATE PROCEDURE "informix".sp_desbloqueo_esp(pempresa CHAR(3))
RETURNING CHAR(5), INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE ven_transacc SMALLINT;
    DEFINE vsql         CHAR(500);
    DEFINE vstmt        CHAR(250);
    DEFINE vhora        CHAR(15);
    DEFINE vfolio       CHAR(16);
    DEFINE vcuenta      CHAR(20);
    DEFINE vusuario     CHAR(8);
    DEFINE vreferencia  CHAR(20);
    DEFINE vborra       SMALLINT;
    DEFINE vinserta     SMALLINT;
    DEFINE vactualiza   SMALLINT;
    
    LET vcodret1      = '000';
    LET vcodret2      = '';
    LET vcodret3      = '';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vcontador1    = 0;
    LET vcontador2    = 0;
    LET ven_transacc  = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vhora        = '';
    LET vfolio       = '';
    LET vcuenta      = '';
    LET vusuario     = 'informix';
    LET vreferencia  = 'DESBLOQ CONTING SPEI';
    LET vborra       = 0;
    LET vinserta     = 0;
    LET vactualiza   = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloqueo_esp.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_desbloqueo_esp.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctas_desbloq_esp') THEN
        DROP TABLE "informix".ctas_desbloq_esp;
    END IF;
    
    CREATE TABLE "informix".ctas_desbloq_esp
      (
        cuenta char(20) not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasdesbloqesp_cta ON "informix".ctas_desbloq_esp(cuenta) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ctas_desbloquear.txt INSERT INTO ctas_desbloq_esp" > /resplogifx/conciliachq/ctasdesbloqesp.sql';
    SYSTEM vsql;
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasdesbloqesp.sql';
    SYSTEM vstmt;
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctas_desbloq_esp;
    
    LET vhora = CURRENT HOUR TO FRACTION;
    LET vfolio = vusuario||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
    
    FOREACH WITH HOLD
        SELECT cuenta
          INTO vcuenta
          FROM ctas_desbloq_esp
        
        BEGIN WORK;
        LET ven_transacc = 1;
        
        DELETE FROM sc_ctabloqueo
         WHERE cuenta = vcuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vborra = 1;
        ELSE
            LET vborra = 0;
        END IF;
         
        INSERT INTO sc_histbloq VALUES
        ( pempresa, vcuenta, 'D', '00', 0, 0.00, vusuario, today, current, '2210', 'D', vfolio, vreferencia, '', '', '', '' );
        
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vinserta = 1;
        ELSE
            LET vinserta = 0;
        END IF;
        
        UPDATE sc_maechq
           SET status_cta = '1',
               motivo = '00'
         WHERE cuenta = vcuenta;
         
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vactualiza = 1;
        ELSE
            LET vactualiza = 0;
        END IF;
         
        IF vborra = 1 OR vinserta = 1 OR vactualiza = 1 THEN
            LET vcontador2 = vcontador2 + 1;
            
            COMMIT WORK;
            LET ven_transacc = 0;
        ELSE
            ROLLBACK WORK;
            LET ven_transacc = 0;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
    END FOREACH;
    
    END;

    RETURN vcodret1, vcontador1, vcontador2;

END PROCEDURE;