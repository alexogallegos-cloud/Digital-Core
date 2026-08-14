CREATE PROCEDURE "informix".sp_borradetallemes(pempresa CHAR(3), panio INTEGER)
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    DEFINE vtransaccion     INTEGER;

    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vnum_serial     = 0;
    LET vtransaccion    = 0;

    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "./borramovshist.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "./sp_borradetallemes.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    FOREACH cursor_borra WITH HOLD FOR
        SELECT rowid
        INTO vnum_serial
        FROM bdimonitorcob:mc_detestadmes
        WHERE empresa = pempresa
        AND anio = panio


        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            BEGIN WORK;
        END IF;

        DELETE FROM bdimonitorcob:mc_detestadmes
        WHERE CURRENT OF cursor_borra;

        LET vcontador1 = vcontador1 + 1;

        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    END;
    RETURN vcodret1, vcodret2, vcontador1;
END PROCEDURE;