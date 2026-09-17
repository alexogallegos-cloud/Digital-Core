CREATE PROCEDURE "informix".pasamovshistesp( pfecha_ini DATE, pfecha_fin DATE )
RETURNING CHAR(5), CHAR(5), CHAR(60), INTEGER, INTEGER, INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(60);
    DEFINE vsql_err     INTEGER;
    DEFINE visam_err    INTEGER;
    DEFINE vdesc_err    CHAR(50);
    DEFINE vcontador1   INTEGER;
    DEFINE vcontador2   INTEGER;
    DEFINE vcontador3   INTEGER;
    DEFINE vcomienza    SMALLINT;
    DEFINE ven_transacc SMALLINT;
    DEFINE vcont_commit INTEGER;
    DEFINE vfecha       DATE;
    DEFINE vserial      INTEGER;
    
    LET vcodret1     = '000';
    LET vcodret2     = '000';
    LET vcodret3     = '';
    LET vsql_err	 = 0;
    LET visam_err    = 0;
    LET vdesc_err    = '';
    LET vcontador1   = 0;
    LET vcontador2   = 0;
    LET vcontador3   = 0;
    LET vcomienza    = -1;
    LET ven_transacc = 0; 
    LET vcont_commit = 0;
    LET vfecha       = '';
    LET vserial      = 0;
    
    BEGIN
    
    ON EXCEPTION SET vsql_err, visam_err, vdesc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistesp.err";
        TRACE ON;
        IF vsql_err <> 0 THEN
            LET vcodret1 = vsql_err;
            LET vcodret2 = visam_err;
            LET vcodret3 = vdesc_err;
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/pasamovshistesp.out";
    --- TRACE ON;
    
    SET OPTIMIZATION HIGH;
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    -- // OBTIENE EL NUMERO DE REGISTROS A TRASPASAR
    SELECT COUNT(*)
      INTO vcontador1
      FROM sc_movhis_old3
     WHERE fech_alt BETWEEN pfecha_ini AND pfecha_fin;
    
    -- // TRASPASO DE REGISTROS 
    FOREACH WITH HOLD
        SELECT fech_alt, num_serial
          INTO vfecha, vserial
          FROM sc_movhis_old3
         WHERE fech_alt BETWEEN pfecha_ini AND pfecha_fin
        
        IF vcomienza = -1 THEN
            BEGIN WORK;
            LET vcomienza = 0;
            LET ven_transacc = 1;
        END IF;
        
        INSERT INTO sc_movhis_old2
        SELECT *
          FROM sc_movhis_old3 
         WHERE fech_alt = vfecha
           AND num_serial = vserial;
         
        DELETE FROM sc_movhis_old3 
         WHERE fech_alt = vfecha
           AND num_serial = vserial;
         
        LET vcont_commit = vcont_commit + 1;
        
        IF vcont_commit >= 1000 THEN
            LET vcont_commit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;
    END FOREACH;
    
    IF ven_transacc = 1 THEN
        COMMIT WORK;
        LET ven_transacc = 0;
    END IF;
    
    -- // OBTIENE EL NUMERO DE REGISTROS TRASPASADOS
    SELECT COUNT(*)
      INTO vcontador2
      FROM sc_movhis_old2
     WHERE fech_alt BETWEEN pfecha_ini AND pfecha_fin;
     
    -- // OBTIENE EL NUMERO DE REGISTROS NO TRASPASADOS
    SELECT COUNT(*)
      INTO vcontador3
      FROM sc_movhis_old3
     WHERE fech_alt BETWEEN pfecha_ini AND pfecha_fin;
    
    -- // PROCESO CONCLUIDO EXITOSAMENTE
    IF vcontador1 = vcontador2 THEN
        LET vcodret1 = '000'; 
        LET vcodret2 = '000';
        LET vcodret3 = 'LOS REGISTROS POR TRASPASAR Y TRASPASADOS COINCIDEN';
    ELSE  
        LET vcodret1 = '999'; 
        LET vcodret2 = '999';
        LET vcodret3 = 'LOS REGISTROS POR TRASPASAR Y TRASPASADOS NO COINCIDEN';
    END IF;
       
    END;

    RETURN vcodret1, vcodret2, vcodret3, vcontador1, vcontador2, vcontador3;

END PROCEDURE;