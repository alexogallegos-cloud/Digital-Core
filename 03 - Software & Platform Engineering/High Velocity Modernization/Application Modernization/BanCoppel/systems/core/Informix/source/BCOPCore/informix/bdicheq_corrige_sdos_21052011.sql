CREATE PROCEDURE "informix".corrige_sdos_21052011(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(40);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcontador3       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vsql             CHAR(500);
    DEFINE vstmt            CHAR(250);
    DEFINE vcuenta          CHAR(20);
    DEFINE vmonto           MONEY(18,2);    
    DEFINE vexiste          INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO TERMINADO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vsql         = '';
    LET vstmt        = '';
    LET vcuenta      = '';
    LET vmonto       = 0.00;
    LET vexiste      = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdos_21052011.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/corrige_sdos_21052011.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // TABLA DE CUENTAS POR BLOQUEAR
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'ctasxcorregir') THEN
        DROP TABLE "informix".ctasxcorregir;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcorregir
      (
        cuenta          char(20)    not null,
        monto           money(18,2),
        nul1			char(1),
		nul12			char(1),
		nul13			char(1),
		nul14			char(1),
		nul15			char(1),
		nul16			char(1)									   
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctaxcorreg ON "informix".ctasxcorregir(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ctasxcorregir.unl DELIMITER ''","'' INSERT INTO ctasxcorregir" > /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    LET vstmt = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctasxcorreg.sql';
    SYSTEM vstmt;
    LET vstmt = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcorregir;
    
    FOREACH WITH HOLD
        SELECT cuenta, monto
          INTO vcuenta, vmonto
          FROM ctasxcorregir
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;
        
        SELECT COUNT(*)
          INTO vexiste
          FROM sc_sdodiarioc
         WHERE cuenta = vcuenta
           AND aniomes = '201105';
           
        IF vexiste > 0 THEN
            UPDATE sc_sdodiarioc
               SET capvig21 = vmonto
             WHERE cuenta = vcuenta
               AND aniomes = '201105';
               
            LET vcontador2 = vcontador2 + 1;
        END IF;
        
        LET vcontador1 = vcontador1 + 1;
        LET vcontador3 = vcontador3 + 1;
        
        IF vcontador3 >= 1000 THEN
            LET vcontador3 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
        LET vcuenta = '';
        LET vmonto  = 0.00;
        LET vexiste = 0;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;