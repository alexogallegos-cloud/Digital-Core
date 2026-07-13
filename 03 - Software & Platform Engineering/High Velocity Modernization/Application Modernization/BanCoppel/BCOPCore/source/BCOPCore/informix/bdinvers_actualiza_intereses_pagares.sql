CREATE PROCEDURE "informix".actualiza_intereses_pagares(pempresa CHAR(3))
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
    DEFINE vhora            CHAR(15);
    DEFINE vfolio           CHAR(16);
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       SMALLINT;    
    DEFINE vsucursal        CHAR(4);  
    DEFINE vmonto_int       DECIMAL(14,2);
    
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
    LET vcuenta    = '';
    LET vsecuencia = 0;
    LET vsucursal  = '';
    LET vmonto_int = 0.00;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_intereses_pagares.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/actualiza_intereses_pagares.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'invxactualizar') THEN
        DROP TABLE "informix".invxactualizar;
    END IF;
    
    CREATE RAW TABLE "informix".invxactualizar
      (
        cuenta      char(20)        not null,
        secuencia   smallint        not null,
        sucursal    char(4)         not null,
        monto_int   decimal(14,2)   not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_intpag ON "informix".invxactualizar(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/intereses_pagares.unl DELIMITER ''","'' INSERT INTO invxactualizar" > /resplogifx/conciliachq/int_pag.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/int_pag.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE invxactualizar;
    
    FOREACH WITH HOLD
        SELECT cuenta, secuencia, sucursal, monto_int
          INTO vcuenta, vsecuencia, vsucursal, vmonto_int
          FROM invxactualizar
        
        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        UPDATE bdinvers:"informix".sv_provdia
           SET ipa_dia30 = vmonto_int
         WHERE aniomes = '201109'
           AND cuenta = vcuenta
           AND secuencia = vsecuencia
           AND sucursal = vsucursal;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
        
        LET vcuenta    = '';
        LET vsecuencia = 0;
        LET vsucursal  = '';
        LET vmonto_int = 0.00;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    LET vcontador2 = vcontador1;
    
    END;

    RETURN vcodret1, vcodret2, vcontador1, vcontador2;

END PROCEDURE;