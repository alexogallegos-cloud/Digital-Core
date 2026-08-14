CREATE PROCEDURE "informix".sp_cancela_pagares(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       SMALLINT;    
    
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
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    LET vsecuencia   = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_pagares.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_cancela_pagares.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'pagaresxcancelar') THEN
        DROP TABLE "informix".pagaresxcancelar;
    END IF;
    
    CREATE TABLE "informix".pagaresxcancelar
      (
        cuenta    char(20) not null,
        secuencia smallint not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_pagxcanc ON "informix".pagaresxcancelar(cuenta, secuencia) ONLINE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/pagaresxcorreg.unl INSERT INTO pagaresxcancelar" > /resplogifx/conciliachq/pags_canc.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/pags_canc.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE pagaresxcancelar;
    
    FOREACH WITH HOLD
        SELECT cuenta, secuencia
          INTO vcuenta, vsecuencia
          FROM pagaresxcancelar
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        UPDATE sv_maeinv
           SET status_cta = '2',
               fec_cancelac = TODAY
         WHERE cuenta = vcuenta
           AND secuencia = vsecuencia;
               
        IF ( dbinfo('sqlca.sqlerrd2') > 0 ) THEN
            LET vcontador2 = vcontador2 + 1;
            COMMIT WORK;
            BEGIN WORK;
        ELSE
            ROLLBACK WORK;
            BEGIN WORK;           
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        
        LET vcuenta    = '';
        LET vsecuencia = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;