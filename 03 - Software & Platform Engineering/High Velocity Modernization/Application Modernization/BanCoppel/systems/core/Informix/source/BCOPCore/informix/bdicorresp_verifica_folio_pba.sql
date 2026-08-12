CREATE PROCEDURE "informix".verifica_folio_pba( pfolio char(16) )
RETURNING CHAR(3);

    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE cod_ret1         CHAR(3);
    DEFINE cod_ret2         CHAR(5);
    DEFINE vexiste          SMALLINT;
    DEFINE vexiste_folio    CHAR(1);

    LET sql_err = 0;
    LET isam_err = 0;
    LET cod_ret1 = "001";
    LET cod_ret2 = "000";
    LET vexiste = 0;
    LET vexiste_folio = '0';

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/verifica_folio.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        IF (sql_err <> 0) THEN
            --- SET DEBUG FILE TO "/resplogifx/conciliachq/verifica_folio.err";
            --- TRACE ON;
            LET cod_ret1 = sql_err;
            LET cod_ret2 = isam_err;
            RETURN cod_ret1;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    IF (pfolio is null OR pfolio = '' OR LENGTH(pfolio) <> 16) THEN
        LET cod_ret1 = '001';
        RETURN cod_ret1;
    END IF;

    SELECT COUNT(*)
      INTO vexiste
      FROM bdicheq:"informix".sc_movdia
     WHERE empresa = '001'
       AND cuenta is not null
       AND cancelad <> 'S'
       AND folio_suc = pfolio;

    IF vexiste > 0 THEN
        LET cod_ret1 = '000';
        LET vexiste_folio = '1';
    ELSE
       SELECT COUNT(*)
         INTO vexiste
         FROM bdicred:"informix".sd_movdia
        WHERE folio_suc = pfolio
          AND reversado <> 'S';
        IF vexiste > 0 THEN
           LET cod_ret1 = '000';
           LET vexiste_folio = '1';
        END IF;
    END IF;

    RETURN cod_ret1;

    END;

END PROCEDURE;