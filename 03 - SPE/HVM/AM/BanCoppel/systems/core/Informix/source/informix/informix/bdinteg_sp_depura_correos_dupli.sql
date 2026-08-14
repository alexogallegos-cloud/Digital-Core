CREATE PROCEDURE "informix".sp_depura_correos_dupli( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vcodret3         CHAR(50);
    DEFINE sql_err          INTEGER;
    DEFINE isam_err         INTEGER;
    DEFINE desc_err         CHAR(50);
    DEFINE vEnTransacc      SMALLINT;
    DEFINE vContador        INTEGER;
    DEFINE vNumCte          CHAR(20);
    DEFINE vTipoCorreo      SMALLINT;
    
    LET vcodret1      = '000';
    LET vcodret2      = '000';
    LET vcodret3      = '';
    LET sql_err	      = 0;
    LET isam_err      = 0;
    LET desc_err      = '';
    LET vEnTransacc   = 0;
    LET vContador     = 0;
    LET vNumCte       = '';
    LET vTipoCorreo   = 0;
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_correos_dupli.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = desc_err;
            IF vEnTransacc = 1 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vContador;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_correos_dupli.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT numcte, tipo_correo, status_correo, COUNT(*) AS repeticiones
      FROM si_correos
     WHERE status_correo = 'A'
     GROUP BY 1, 2, 3
    HAVING COUNT(*) > 1
    INTO TEMP tmp_duplicados WITH NO LOG;
    CREATE INDEX idxtmp_corrdupl ON tmp_duplicados(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS HIGH FOR TABLE tmp_duplicados;
    
    FOREACH WITH HOLD
        SELECT numcte, tipo_correo
          INTO vNumCte, vTipoCorreo
          FROM tmp_duplicados
          
        BEGIN WORK;
        LET vEnTransacc = 1;
          
        UPDATE si_correos
           SET status_correo = 'C'
         WHERE numcte = vNumCte
           AND tipo_correo = vTipoCorreo
           AND secuencia < ( SELECT MAX(secuencia)
                               FROM si_correos
                              WHERE numcte = vNumCte
                                AND tipo_correo = vTipoCorreo );
           
        COMMIT WORK;
        LET vEnTransacc = 0;
        
        LET vContador = vContador +1;
        
        LET vNumCte     = '';
        LET vTipoCorreo = 0;
    END FOREACH;
    
    END;

    RETURN vcodret1, vContador;

END PROCEDURE;