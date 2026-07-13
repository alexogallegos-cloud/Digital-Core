CREATE PROCEDURE "informix".sp_actual_ctasconc(pempresa CHAR(3))
RETURNING CHAR(5);

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(80);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(80);
    DEFINE vcontador1   INTEGER;
    DEFINE vcomienza    SMALLINT;
    DEFINE ven_transacc SMALLINT;
    DEFINE vcuenta      CHAR(20);

    LET vcodret1     = '000';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET sql_err      = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0;
    LET vcuenta      = '';

    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actual_ctasconc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            RETURN vcodret1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_actual_ctasconc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

    FOREACH WITH HOLD
        SELECT {+INDEX(sc_maechq idx_sc_maechq2)}
               cuenta
          INTO vcuenta
          FROM sc_maechq
         WHERE status_cta = '6'
           AND producto <> '5000'
           AND sdo_dia_ant <> 0.00

        IF (vcomienza = -1) THEN
            LET vcomienza = 0;
            LET ven_transacc = 1;
            BEGIN WORK;
        END IF;

        UPDATE sc_maechq
           SET sdo_dia_ant = 0.00
         WHERE cuenta = vcuenta;

        LET vcontador1 = vcontador1 + 1;

        IF vcontador1 >= 500 THEN
            LET vcontador1 = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;

        LET vcuenta = '';
    END FOREACH;

    IF ven_transacc = 1 THEN
        LET ven_transacc = 0;
        COMMIT WORK;
    END IF;

    END;

    RETURN vcodret1;

END PROCEDURE;