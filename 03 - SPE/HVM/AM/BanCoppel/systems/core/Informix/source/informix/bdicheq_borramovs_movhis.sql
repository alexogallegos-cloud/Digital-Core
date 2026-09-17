CREATE PROCEDURE "informix".borramovs_movhis(pempresa CHAR(3))
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER, INTEGER;

    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vcomienza    INTEGER;
    DEFINE ven_transacc CHAR(1);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcont_commit INTEGER;
    DEFINE vfecha       DATE;
    DEFINE vfechamax    DATE;
    DEFINE vnum_serial  INTEGER;
    
    LET vcodret1     = '';
    LET vcodret2     = '';
    LET vcodret3     = '';
    LET sql_err	     = 0;
    LET isam_err     = 0;
    LET desc_err     = '';
    LET vcomienza    = -1;
    LET ven_transacc = '0'; 
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcont_commit = 0;
    LET vfecha       = ''; 
    LET vfechamax    = '03/13/2013';
    LET vnum_serial  = 0;
    
    BEGIN

    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/borramovs_movhis.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF ven_transacc = '1' THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
        END IF;
    END EXCEPTION;

    --- SET DEBUG FILE TO "/resplogifx/conciliachq/borramovs_movhis.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE LA FECHA A PROCESAR
    SELECT valor
      INTO vfecha
      FROM sc_param
     WHERE empresa = pempresa
       AND codparam = 'BorraRegistrosMovhis';
       
    IF vfecha > vfechamax THEN
        LET vcodret1 = '111';
        LET vcodret2 = '111';
        LET vcodret3 = 'NO HAY MAS REGISTROS POR ELIMINAR';
        RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;
    END IF;
     
    SELECT {+INDEX(sc_movhis idx_movhisnew6)}
           COUNT(*)
      INTO vcontador1
      FROM sc_movhis
     WHERE fech_alt = vfecha;
     
    -- // ELIMINA REGISTROS DE MOVHIS
    FOREACH WITH HOLD 
        SELECT {+INDEX(sc_movhis idx_movhisnew6)} 
               num_serial
          INTO vnum_serial
          FROM sc_movhis
         WHERE fech_alt = vfecha
           
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = '1';
        END IF;
        
        DELETE {+INDEX(sc_movhis idx_movhis_serial)}
          FROM sc_movhis
         WHERE fech_alt = vfecha
           AND num_serial = vnum_serial;
         
        LET vcontador2 = vcontador2 + 1;
        LET vcont_commit = vcont_commit + 1;
        
        IF vcont_commit >= 5000 THEN
            COMMIT WORK;
            BEGIN WORK;
            LET vcont_commit = 0;
        END IF;
    END FOREACH;
    
    IF ven_transacc = '1' THEN
        COMMIT WORK;
        LET ven_transacc = '0';
    END IF;
    
    IF vcontador1 = vcontador2 THEN
        LET vfecha = vfecha + 1 UNITS DAY;
        
        UPDATE sc_param
           SET valor = vfecha
         WHERE empresa = pempresa
           AND codparam = 'BorraRegistrosMovhis';
           
        UPDATE sc_param
           SET valor = vfecha
         WHERE empresa = pempresa
           AND codparam = 'fechcon_movhis';
           
        UPDATE sc_param
           SET valor = vfecha
         WHERE empresa = pempresa
           AND codparam = 'PasoMovhis_MovhisOld';
    
        LET vcodret1 = '000';
        LET vcodret2 = '000';
        LET vcodret3 = 'PROCESO FINALIZADO CORRECTAMENTE';
    END IF;
    
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2;

END PROCEDURE;