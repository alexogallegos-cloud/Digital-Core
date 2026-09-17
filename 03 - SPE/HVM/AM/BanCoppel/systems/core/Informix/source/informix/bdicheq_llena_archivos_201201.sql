CREATE PROCEDURE "informix".llena_archivos_201201()
RETURNING CHAR(5);

    DEFINE vsuc          CHAR(4);
    DEFINE vaniomes      CHAR(6);
    DEFINE vsqlerr       INTEGER;
    DEFINE isam_err      INTEGER;
    DEFINE error_info    CHAR(50);
    DEFINE vcodret       CHAR(5);
    DEFINE vcta          CHAR(20);
    DEFINE vanio         INTEGER;
    DEFINE vcommit       INTEGER;
    DEFINE vmincta       CHAR(20);
    DEFINE vmaxcta       CHAR(20);
    DEFINE vcontador     INTEGER;

    ON EXCEPTION SET vsqlerr, isam_err, error_info
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret;
        END IF;
    END EXCEPTION;

    LET vcodret  = "000";
    LET vaniomes = "201201";
    LET vanio    = 2012;
    LET vcommit  = -1;
    LET vmincta  = "";
    LET vmaxcta  = "";
    LET vcontador = 0;

    --- SET DEBUG FILE TO "llena_archivos_201201.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
      
    SELECT cuenta 
      FROM sc_sdodiarioc_2012
     WHERE cuenta BETWEEN vmincta AND vmaxcta
       AND aniomes = vaniomes
      INTO TEMP tmp_sdosdiarios WITH NO LOG;
    CREATE INDEX idx_tmpsdos ON tmp_sdosdiarios(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sdosdiarios;

    FOREACH WITH HOLD
        SELECT cuenta, sucursal 
          INTO vcta, vsuc
          FROM sc_maechq
         WHERE empresa = '001'
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND cuenta NOT IN(SELECT cuenta FROM tmp_sdosdiarios)
           AND status_cta <> '2'

        IF (vcommit = -1) THEN
            BEGIN WORK;
            LET vcommit = 0;
        END IF;

        INSERT INTO sc_sdodiarioc_2012 VALUES( vcta, vaniomes, vsuc, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );

        INSERT INTO sc_sdomensualc_2012 VALUES( vcta, vanio, vsuc,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
        
        LET vcommit = vcommit + 1; 

        IF (vcommit >= 7500) THEN
            LET vcommit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;   
        
    END FOREACH;

    IF (vcommit >= 0) THEN
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_sdodiarioc_2012;
    UPDATE STATISTICS MEDIUM FOR TABLE sc_sdomensualc_2012;

    RETURN vcodret;

END PROCEDURE;