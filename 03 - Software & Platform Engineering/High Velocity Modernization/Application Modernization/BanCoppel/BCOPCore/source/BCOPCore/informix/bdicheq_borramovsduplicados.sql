CREATE PROCEDURE "informix".borramovsduplicados(pempresa CHAR(3), pfecha DATE)
RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE vcontador1       INTEGER;
    DEFINE vnum_serial      INTEGER;
    
    LET vcodret1        = '000';
    LET vcodret2        = '000';
    LET sql_err	        = 0;
    LET isam_err        = 0;
    LET vcontador1      = -1;
    LET vnum_serial     = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsduplicados.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsduplicados.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    select {+index(sc_movhis_old2 idx_movhisnew6_old2)}
           num_serial, count(*) cuantos
      from sc_movhis_old2
     where fech_alt = pfecha
     group by 1
      into temp tmp_serial with no log;
    create index idxtmp_serial on tmp_serial(num_serial) using btree fillfactor 99;
    update statistics medium for table tmp_serial;
      
    select *
      from tmp_serial
     where cuantos > 1
      into temp tmp_movs_dupl with no log;
    create index idxtmp_movs on tmp_movs_dupl(num_serial) using btree fillfactor 99;
    update statistics medium for table tmp_movs_dupl;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT {+index(sc_movhis_old2 idx_movhisnew6_old2)} num_serial
          INTO vnum_serial
          FROM sc_movhis_old2
         WHERE fech_alt = pfecha
           AND num_serial IN(SELECT num_serial FROM tmp_movs_dupl)
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_movhis_old2
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;