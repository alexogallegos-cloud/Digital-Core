CREATE PROCEDURE "informix".sp_alertacargospei_exp1(pempresa CHAR(3))
RETURNING CHAR(5);

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(80);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(80);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vcomienza        SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    DEFINE vclave_rastreo   CHAR(30);
    DEFINE vsql             CHAR(150);
    DEFINE vstmt            CHAR(100);
    DEFINE vmailx           CHAR(250);
    DEFINE vexiste_movdia   SMALLINT;
    DEFINE vexiste_movhis   SMALLINT;
    DEFINE vexiste_tabla    SMALLINT;
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vprox_fecha      DATE;

    LET vcodret1       = '000';
    LET vcodret2       = '';
    LET vcodret3       = '';
    LET sql_err        = 0;
    LET isam_err       = 0;
    LET desc_err       = '';
    LET vcontador1     = 0;
    LET vcontador2     = 0;
    LET vcomienza      = -1;
    LET ven_transacc   = 0;
    LET vclave_rastreo = '';
    LET vsql           = '';
    LET vstmt          = '';
    LET vmailx         = '';
    LET vexiste_movdia = 0;
    LET vexiste_movhis = 0;
    LET vexiste_tabla  = 0;
    LET vfecha_hoy     = '';
    LET vfecha_ant     = 0;
    LET vprox_fecha    = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertacargospei.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_alertacargospei.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    /* ########################################################################################################################
    --- IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames WHERE partnum > 0 AND tabname = 'cargosspei') THEN
    SELECT COUNT(*)
      INTO vexiste_tabla
      FROM sysmaster:systabnames 
     WHERE partnum > 0 
       AND tabname = 'cargosspei';
       
    IF vexiste_tabla > 0 THEN
        DROP TABLE "informix".cargosspei;
    END IF;

    CREATE TABLE "informix".cargosspei
      (
        clave_rastreo char(96)
      )
    EXTENT SIZE 500 NEXT SIZE 250 LOCK MODE ROW;
    CREATE INDEX "informix".idx_cgospei_cve ON "informix".cargosspei(clave_rastreo) ONLINE;
    ######################################################################################################################## */
    
    TRUNCATE TABLE "informix".cargosspei;

    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_pago_spei.txt INSERT INTO cargosspei;" > /resplogifx/conciliachq/cgosspei.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/cgosspei.sql';
    SYSTEM vstmt;

    UPDATE STATISTICS MEDIUM FOR TABLE cargosspei;

    SELECT fecha_hoy, fecha_ant, prox_fecha
      INTO vfecha_hoy, vfecha_ant, vprox_fecha
      FROM bdicheq:sc_fechas
     WHERE empresa = pempresa;

    FOREACH WITH HOLD
        SELECT {+INDEX(cargosspei idx_cgospei_cve)}
               TRIM(clave_rastreo)
          INTO vclave_rastreo
          FROM cargosspei
         WHERE clave_rastreo NOT IN( SELECT {+INDEX(cargosspeihist cargosspeihist_cve)} clave_rastreo FROM cargosspeihist )

        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;

        SELECT {+INDEX(bdicheq:sc_movdia idx_movdiamspei)}
               COUNT(*)
          INTO vexiste_movdia
          FROM bdicheq:sc_movdia
         WHERE transacc = '0274'
           AND fech_val = fech_val
           AND cancelad <> 'S'
           --- AND fech_alt = vfecha_hoy
           AND fech_alt BETWEEN vfecha_ant AND vprox_fecha
           AND referencia = vclave_rastreo;

        IF vexiste_movdia = 0 THEN
            SELECT {+INDEX(bdicheq:sc_movhis idx_movhisnew4)}
                   COUNT(*)
              INTO vexiste_movhis
              FROM bdicheq:sc_movhis
             WHERE empresa = pempresa
               AND cuenta >= '10000005016'
               AND fech_alt BETWEEN (vfecha_hoy - 5 UNITS DAY) AND vfecha_hoy
               AND cancelad <> 'S'
               AND transacc = '0274'
               AND referencia = vclave_rastreo;
        END IF;

        IF ( vexiste_movdia = 0 AND vexiste_movhis = 0 ) THEN
            --- LET vmailx = 'mailx -s"ATENCION: SE GENERO UN SPEI SIN CARGO A CHEQUES, CLAVE RASTREO: '||vclave_rastreo||'" jvazquez@bancoppel.com -c olopezl@bancoppel.com vfuentes@bancoppel.com avazquezs@bancoppel.com cima_monitoreo@bancoppel.com mromero@bancoppel.com';
            LET vmailx = 'mailx -s"ATENCION: SE GENERO UN SPEI SIN CARGO A CUENTA DE CHEQUES, CLAVE DE RASTREO: '||vclave_rastreo||'" olopezl@bancoppel.com -c vfuentes@bancoppel.com cima_monitoreo@bancoppel.com mromero@bancoppel.com';
            SYSTEM vmailx;
        END IF;

        INSERT INTO cargosspeihist(clave_rastreo)
        VALUES(vclave_rastreo);
        
        DELETE {+INDEX(cargosspei idx_cgospei_cve)}
          FROM cargosspei
         WHERE clave_rastreo = vclave_rastreo;

        LET vcontador1 = vcontador1 + 1;

        IF vcontador1 >= 1000 THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

        LET vclave_rastreo = '';
    END FOREACH;

    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1;

END PROCEDURE;