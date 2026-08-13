CREATE PROCEDURE "informix".sp_alertacargospei(pempresa CHAR(3))
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
    DEFINE vfecha_hoy       DATE;
    DEFINE vfecha_ant       DATE;
    DEFINE vprox_fecha      DATE;
    DEFINE vfecha_ant2      DATE;

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
    LET vfecha_hoy     = '';
    LET vfecha_ant     = 0;
    LET vprox_fecha    = '';
    LET vfecha_ant2    = '';

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
    
    TRUNCATE TABLE "informix".cargosspei;

    LET vsql = 'echo "LOAD FROM /resplogifx/conciliachq/ordenes_pago_spei.txt INSERT INTO cargosspei;" > /resplogifx/conciliachq/cgosspei.sql';
    SYSTEM vsql;

    LET vstmt = '/ifxsif01/bin/dbaccess bdispei /resplogifx/conciliachq/cgosspei.sql';
    SYSTEM vstmt;

    UPDATE STATISTICS MEDIUM FOR TABLE cargosspei;

    SELECT fecha_hoy, fecha_ant
      INTO vfecha_hoy, vfecha_ant
      FROM bdicheq:sc_fechas
     WHERE empresa = pempresa;
     
    LET vfecha_ant2 = (vfecha_ant - 2 UNITS DAY);
    LET vprox_fecha = (vfecha_hoy + 2 UNITS DAY);
    
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
           AND fech_val >= vfecha_ant2
           AND cancelad <> 'S'
           AND referencia = vclave_rastreo;

        IF vexiste_movdia = 0 THEN
            SELECT {+INDEX(bdicheq:sc_movhis idx_movhisspei)} 
			COUNT(*)
              INTO vexiste_movhis
              FROM bdicheq:sc_movhis
             WHERE transacc = '0274'
               AND fech_val >= vfecha_ant2
               AND cancelad <> 'S'
               AND referencia = vclave_rastreo;
        END IF;

        IF ( vexiste_movdia = 0 AND vexiste_movhis = 0 ) THEN
            LET vmailx = 'mailx -s"ATENCION: SE GENERO UN SPEI SIN CARGO A CUENTA DE CHEQUES, CLAVE DE RASTREO: '||vclave_rastreo||'" olopezl@bancoppel.com -c vfuentes@bancoppel.com cima_monitoreo@bancoppel.com mromero@bancoppel.com';
            SYSTEM vmailx;
        END IF;

        INSERT INTO cargosspeihist(clave_rastreo)
        VALUES(vclave_rastreo);
        
        --
	--	DELETE {+INDEX(cargosspei idx_cgospei_cve)}
         -- FROM cargosspei
         --WHERE clave_rastreo = vclave_rastreo;
		--}

        LET vcontador1 = vcontador1 + 1;

        IF vcontador1 >= 100 THEN
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