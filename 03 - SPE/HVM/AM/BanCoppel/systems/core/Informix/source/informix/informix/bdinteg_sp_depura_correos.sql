CREATE PROCEDURE "informix".sp_depura_correos( pEmpresa CHAR(3) )
RETURNING CHAR(5), INTEGER;
    
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE desc_err     CHAR(50);
    DEFINE vEnTransacc  SMALLINT;
    DEFINE vContador    INTEGER;
    DEFINE vNumCte      CHAR(20);
    DEFINE vTipoCorreo  SMALLINT;
    DEFINE vCorreoElec  CHAR(100);
    
    LET vcodret1    = '000';
    LET vcodret2    = '000';
    LET vcodret3    = '';
    LET sql_err	    = 0;
    LET isam_err    = 0;
    LET desc_err    = '';
    LET vEnTransacc = 0;
    LET vContador   = 0;
    LET vNumCte     = '';
    LET vTipoCorreo = 0;
    LET vCorreoElec = '';
    
    BEGIN
    
    -- // MANEJO DE EXCEPCIONES
    ON EXCEPTION SET sql_err, isam_err, desc_err
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_correos.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_depura_correos.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    BEGIN WORK;
    
    DELETE FROM si_correos
     WHERE numcte IN('010756364','010013996')
       AND tipo_correo = 1
       AND secuencia = 2;
       
    COMMIT WORK;
    
    SELECT numcte, tipo_correo, correo_elec, COUNT(*) AS repeticiones
      FROM si_correos
     GROUP BY 1, 2, 3
    HAVING COUNT(*) > 1
    INTO TEMP tmp_duplicados WITH NO LOG;
    CREATE INDEX idxtmp_corrdupl ON tmp_duplicados(numcte) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_duplicados;
    
    FOREACH WITH HOLD
        SELECT numcte, tipo_correo, correo_elec
          INTO vNumCte, vTipoCorreo, vCorreoElec
          FROM tmp_duplicados
          
        BEGIN WORK;
        LET vEnTransacc = 1;
          
        DELETE FROM si_correos
         WHERE numcte = vNumCte
           AND tipo_correo = vTipoCorreo
           AND correo_elec = vCorreoElec
           AND secuencia < ( SELECT MAX(secuencia)
                               FROM si_correos
                              WHERE numcte = vNumCte
                                AND tipo_correo = vTipoCorreo
                                AND correo_elec = vCorreoElec );
           
        COMMIT WORK;
        LET vEnTransacc = 0;
        
        LET vContador = vContador +1;
        
        LET vNumCte     = '';
        LET vTipoCorreo = 0;
        LET vCorreoElec = '';
    END FOREACH;
    
    END;

    RETURN vcodret1, vContador;

END PROCEDURE;