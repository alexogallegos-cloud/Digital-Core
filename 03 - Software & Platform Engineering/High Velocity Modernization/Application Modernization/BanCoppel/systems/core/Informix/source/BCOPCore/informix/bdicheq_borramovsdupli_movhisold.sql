CREATE PROCEDURE "informix".borramovsdupli_movhisold( pfecha DATE )
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
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsdupli_movhisold.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
        END IF;
    END EXCEPTION;
    
    -- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovsdupli_movhisold.out";
    -- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT num_serial, COUNT(*) cuantos
      FROM sc_movhis_old
     WHERE fech_alt = pfecha
     GROUP BY 1
      INTO TEMP tmp_seriales WITH NO LOG;
    CREATE INDEX idxtmp_seriales ON tmp_seriales(cuantos) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_seriales;
      
    SELECT num_serial
      FROM tmp_seriales
     WHERE cuantos > 1
      INTO TEMP tmp_movs_dupl WITH NO LOG;
    CREATE INDEX idxtmp_movsdupl ON tmp_movs_dupl(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_movs_dupl;
    
    FOREACH cursor_borra WITH HOLD FOR
        SELECT {+INDEX(sc_movhis_old idx_movhis_serial_old)}
               num_serial
          INTO vnum_serial
          FROM sc_movhis_old
         WHERE fech_alt = pfecha
           AND num_serial IN(SELECT num_serial FROM tmp_movs_dupl)
           
        IF vcontador1 = -1 THEN
            LET vcontador1 = 0;
            BEGIN WORK;
        END IF;
        
        DELETE FROM sc_movhis_old
         WHERE CURRENT OF cursor_borra;
         
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;

    END;

    RETURN vcodret1, vcodret2, vcontador1;

END PROCEDURE;