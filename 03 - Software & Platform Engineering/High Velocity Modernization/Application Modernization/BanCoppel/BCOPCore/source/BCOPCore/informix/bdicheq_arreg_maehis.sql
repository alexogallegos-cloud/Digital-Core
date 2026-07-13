CREATE PROCEDURE "informix".arreg_maehis(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), CHAR(11), INTEGER, INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcomienza1       SMALLINT;
    DEFINE vcomienza2       SMALLINT;
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vprimero         SMALLINT;
    DEFINE vsql             CHAR(200);
    
    DEFINE vcuenta          CHAR(20);
    DEFINE wcuenta          CHAR(20);
    DEFINE vaniomestmp      CHAR(6);
    DEFINE vaniomes         CHAR(6);
    DEFINE vaniomesok       CHAR(6);
    DEFINE vfechaini        DATE;
    DEFINE vfechafin        DATE;
    DEFINE vdifdias         SMALLINT;
    DEFINE vultfechafin     DATE;
    DEFINE vexiste_aniomes  CHAR(6);
    DEFINE vmax_aniomes     CHAR(6);
    DEFINE vnumero          SMALLINT;
    DEFINE vnumero2         CHAR(2);
    DEFINE vmincta          CHAR(20);
    DEFINE vmaxcta          CHAR(20);
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcomienza1      = -1;
    LET vcomienza2      = -1;
    LET vcontador1      = -1;
    LET vcontador2      = 0;
    LET ven_transacc    = 0; 
    LET vprimero        = 0;
    LET vsql            = '';
    
    LET vcuenta         = ''; 
    LET wcuenta         = '';
    LET vnumero         = 0;
    LET vnumero2        = '';
    LET vaniomestmp     = '';
    LET vaniomes        = '';
    LET vaniomesok      = '';
    LET vfechaini       = '';
    LET vfechafin       = '';
    LET vdifdias        = 0;
    LET vultfechafin    = '';
    LET vexiste_aniomes = '';
    LET vmax_aniomes    = '';
    LET vmincta         = '';
    LET vmaxcta         = '';
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        --- SET DEBUG FILE TO "/ids10_uc8/jivan/cierrechq/arreg_maehis.err";
        --- TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcuenta, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/ids10_uc8/jivan/cierrechq/arreg_maehis.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  
                WHERE partnum > 0 AND tabname = 'ctasxcorreg') THEN
        DROP TABLE "informix".ctasxcorreg;
    END IF;
    
    CREATE RAW TABLE "informix".ctasxcorreg
      (
        cuenta      char(20)    not null,
        aniomes     char(6)     not null,
        fechaini    date        not null,
        fechafin    date        not null
      )
    EXTENT SIZE 32 NEXT SIZE 32 LOCK MODE ROW;
    CREATE INDEX "informix".idx_ctasxcorreg ON "informix".ctasxcorreg(cuenta) USING BTREE;
      
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/maehis.unl INSERT INTO ctasxcorreg" > /resplogifx/conciliachq/ctas4.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = '/ifxsif01/bin/dbaccess bdicheq /resplogifx/conciliachq/ctas4.sql';
    --- LET vsql = 'dbaccess bdicheq /resplogifx/conciliachq/ctas4.sql';
    SYSTEM vsql;
    LET vsql = '';
    
    UPDATE STATISTICS MEDIUM FOR TABLE ctasxcorreg;
    
    FOREACH WITH HOLD
        SELECT UNIQUE cuenta
          INTO vcuenta
          FROM ctasxcorreg
          
        IF (vcontador1 = -1) THEN
            BEGIN WORK;
            LET vcontador1 = 0;
            LET ven_transacc = 1;
        END IF;
        
        LET vnumero = 1;
        
        FOREACH
            SELECT aniomes, fechaini, fechafin
              INTO vaniomes, vfechaini, vfechafin
              FROM sc_maehis
             WHERE empresa = pempresa
               AND cuenta = vcuenta
             ORDER BY fechaini
             
            LET vnumero2 = LPAD(vnumero, 2, '0');
            LET vaniomestmp = '0000' || vnumero2;
            
            UPDATE sc_maehis
               SET aniomes = vaniomestmp
             WHERE empresa = pempresa
               AND cuenta = vcuenta
               AND aniomes = vaniomes
               AND fechaini = vfechaini
               AND fechafin = vfechafin;
            
            LET vnumero = vnumero + 1;
        END FOREACH;
        
        FOREACH
            SELECT cuenta, aniomes, fechaini, fechafin
              INTO wcuenta, vaniomes, vfechaini, vfechafin
              FROM ctasxcorreg
             WHERE cuenta = vcuenta
             ORDER BY fechaini
                    
            UPDATE sc_maehis
               SET aniomes = vaniomes
             WHERE empresa = pempresa
               AND cuenta = wcuenta
               AND fechaini = vfechaini
               AND fechafin = vfechafin;
            
            LET vcontador2 = vcontador2 + 1;
            
            LET vaniomes        = '';
            LET vfechaini       = '';
            LET vfechafin       = '';
        END FOREACH;
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcuenta, vcontador1, vcontador2;

END PROCEDURE;