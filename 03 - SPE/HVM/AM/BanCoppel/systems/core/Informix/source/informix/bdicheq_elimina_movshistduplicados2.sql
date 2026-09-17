CREATE PROCEDURE "informix".elimina_movshistduplicados2( pempresa CHAR(3), pFecha DATE )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vcontador1       INTEGER;
    DEFINE vcontador2       INTEGER;
    DEFINE vempieza         SMALLINT;
    DEFINE ven_transacc     SMALLINT;
    
    DEFINE vSerialDuplicado INTEGER;
    DEFINE vmin_serial      INTEGER;
    DEFINE vmax_serial      INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = 'PROCESO REALIZADO SATISFACTORIAMENTE';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vempieza     = -1;
    LET ven_transacc = 0; 
    
    LET vSerialDuplicado = 0;
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/elimina_movshistduplicados2.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/elimina_movshistduplicados2.out";
    --- TRACE ON;
    
    set optimization high;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
           num_serial, COUNT(*) cuantos
      FROM bdicheq:"informix".sc_movhis_old
     WHERE fech_alt = pFecha
     GROUP BY 1
      INTO TEMP tmp_seriales WITH NO LOG;
    CREATE INDEX idx_tmpser ON tmp_seriales(cuantos) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_seriales;
      
    SELECT num_serial  
      FROM tmp_seriales 
     WHERE cuantos > 1
      INTO TEMP tmp_duplicados WITH NO LOG;
    CREATE INDEX idx_tmpdupl ON tmp_duplicados(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_duplicados;
      
    /* #########################################################################
    SELECT {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
           UNIQUE mov.*
      FROM bdicheq:"informix".sc_movhis_old mov,
           tmp_duplicados tmp
     WHERE mov.fech_alt = pFecha
       AND tmp.num_serial = mov.num_serial
      INTO TEMP tmp_movs WITH NO LOG;
    CREATE INDEX idx_tmpmovs ON tmp_movs(num_serial) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_movs;
    ######################################################################### */

    FOREACH WITH HOLD 
        SELECT num_serial
          INTO vSerialDuplicado
          FROM tmp_duplicados
           
        IF vempieza = -1 THEN
            LET vempieza = 0;
            LET ven_transacc = 1; 
            BEGIN WORK;
        END IF;
        
        DELETE {+INDEX(bdicheq:"informix".sc_movhis_old idx_movhisnew6_old)} 
               bdicheq:"informix".sc_movhis_old
         WHERE fech_alt = pfecha
           AND num_serial = vSerialDuplicado;
         
        /* ############################################
        INSERT INTO bdicheq:"informix".sc_movhis_old
        SELECT *
          FROM tmp_movs
         WHERE num_serial = vSerialDuplicado;
        ############################################ */
        
        LET vcontador1 = vcontador1 + 1;
        
        COMMIT WORK;
        BEGIN WORK;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET vcontador2 = 0;
        LET ven_transacc = 0;
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1;

END PROCEDURE;