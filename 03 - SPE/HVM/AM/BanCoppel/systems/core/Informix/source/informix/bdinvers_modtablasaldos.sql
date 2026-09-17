CREATE PROCEDURE "informix".modtablasaldos(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret          CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vt_cuantos       INTEGER;
    DEFINE vt_cuantos2      INTEGER;
    DEFINE vfecha_hoy       DATE;
    DEFINE vcuenta          CHAR(20);
    DEFINE vsecuencia       CHAR(2);
    DEFINE vint23           MONEY(14,2);
    DEFINE vinteres         MONEY(18,2);
    DEFINE vanio            CHAR(4);
    DEFINE vmes             CHAR(2);
    DEFINE vaniomes         CHAR(6);
    DEFINE vsql             CHAR(500);

    LET vcodret     = '000';
    LET vcodret2    = '000';
    LET sql_err     = 0;
    LET isam_err    = 0;
    LET vcontador   = -1;
    LET vt_cuantos  = 0;
    LET vt_cuantos2 = 0;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF sql_err <> 0 THEN
            LET vcodret = sql_err;
            LET vcodret2 = isam_err;
            RETURN vcodret, vcodret2, vt_cuantos, vt_cuantos2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "./modtablasaldos.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT {+INDEX(sv_fechas idx_fechas)} fecha_hoy
      INTO vfecha_hoy
      FROM sv_fechas
     WHERE empresa = pempresa;
     
    LET vanio = YEAR(vfecha_hoy);
    LET vmes  = MONTH(vfecha_hoy);
    LET vaniomes = vanio||vmes;
    
    IF EXISTS (SELECT tabname FROM sysmaster:systabnames
                WHERE partnum BETWEEN (SELECT MIN(partnum) FROM sysmaster:systabnames) AND
                                      (SELECT MAX(partnum) FROM sysmaster:systabnames)
                  AND tabname = 'saldospag') THEN
        DROP TABLE "informix".saldospag;
        CREATE RAW TABLE "informix".saldospag(
            cuenta      char(20),
            secuencia   char(2),
            interes     money(18,2));
    ELSE
        CREATE RAW TABLE "informix".saldospag(
            cuenta      char(20),
            secuencia   char(2),
            interes     money(18,2));
    END IF;
    
    LET vsql = '';
    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/tabla_saldos.unl INSERT INTO saldospag;" > /resplogifx/conciliachq/modtabsaldos.sql';
    -- LET vsql = 'echo "LOAD FROM /home/informix/jivan/pagares/tabla_saldos.csv INSERT INTO saldospag;" > /home/informix/jivan/pagares/modtabsaldos.sql';
    SYSTEM vsql;
    LET vsql = '';
    LET vsql = "/ifxsif01/bin/dbaccess bdinvers /resplogifx/conciliachq/modtabsaldos.sql";
    -- LET vsql = "dbaccess bdinvers /resplogifx/conciliachq/modtabsaldos.sql";
    SYSTEM vsql;
    LET vsql = "";
    
    FOREACH WITH HOLD
        SELECT {+INDEX(sv_provdia idx_provdia)} 
               cuenta, secuencia, ipa_dia23
          INTO vcuenta, vsecuencia, vint23
          FROM sv_provdia
         WHERE cuenta IS NOT NULL
           AND aniomes = vaniomes
           AND ipa_dia23 IS NOT NULL
           
        IF vcontador = -1 THEN
            LET vcontador = 0;
            BEGIN WORK;
        END IF;
           
        SELECT interes
          INTO vinteres
          FROM saldospag
         WHERE cuenta = vcuenta
           AND secuencia = vsecuencia;
           
        IF vint23 <> vinteres THEN
            UPDATE {+INDEX(sv_provdia idx_provdia)} sv_provdia
               SET ipa_dia23 = vinteres
             WHERE cuenta = vcuenta
               AND aniomes = vaniomes
               AND secuencia = vsecuencia;
               
            LET vt_cuantos2 = vt_cuantos2 + 1;
        END IF;
        
        LET vcontador = vcontador + 1;

        IF (vcontador >= 10000) THEN
            LET vt_cuantos = vt_cuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
        
    END FOREACH
    
    IF (vcontador > 0) THEN
        LET vt_cuantos = vt_cuantos + vcontador;
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vcodret2, vt_cuantos, vt_cuantos2;

END PROCEDURE;