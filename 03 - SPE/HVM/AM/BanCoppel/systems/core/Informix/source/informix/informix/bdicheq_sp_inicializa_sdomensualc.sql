CREATE PROCEDURE "informix".sp_inicializa_sdomensualc( pEmpresa CHAR(3), pAnio SMALLINT )
RETURNING CHAR(5), CHAR(5), CHAR(50), INTEGER;

    DEFINE sql_err      INTEGER;
    DEFINE isam_err     INTEGER;
    DEFINE error_info   CHAR(50);
    DEFINE vcodret1     CHAR(5);
    DEFINE vcodret2     CHAR(5);
    DEFINE vcodret3     CHAR(50);
    DEFINE vcomienza    SMALLINT;
    DEFINE vcuantos     INTEGER;
    DEFINE vcommit      INTEGER;
    
    DEFINE vfecha_hoy   DATE;
    DEFINE vanio_actual CHAR(4);
    DEFINE vult_dia_mes DATE;
    DEFINE vdiaproxmes  DATE;
    DEFINE vanio        CHAR(4);
    DEFINE vmes         CHAR(2);
    DEFINE vaniomes     CHAR(6);
    DEFINE vcuenta      CHAR(20);
    DEFINE vsucursal    CHAR(4);
    DEFINE vmincta      CHAR(20);
    DEFINE vmaxcta      CHAR(20);

    LET sql_err    = 0;
    LET isam_err   = 0;
    LET error_info = '';
    LET vcodret1   = '000';
    LET vcodret2   = '000';
    LET vcodret3   = 'PROCESO CONCLUIDO SATISFACTORIAMENTE';
    LET vcomienza  = -1;
    LET vcuantos   = 0;
    LET vcommit    = 0;
    
    LET vfecha_hoy = '';
    LET vanio_actual = '';
    LET vult_dia_mes = '';
    LET vdiaproxmes = '';
    LET vanio = '2015';
    LET vmes = '';
    LET vaniomes = '';
    LET vcuenta = '';
    LET vsucursal = '';
    LET vmincta  = "";
    LET vmaxcta  = "";
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdomensualc.err";
        TRACE ON;
        IF sql_err <> 0 THEN
            LET vcodret1 = sql_err;
            LET vcodret2 = isam_err;
            LET vcodret3 = error_info;
            IF vcommit > 0 THEN
                ROLLBACK WORK;
            END IF;
            RETURN vcodret1, vcodret2, vcodret3, vcuantos;
        END IF;
    END EXCEPTION;
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdomensualc.out";
    --- TRACE ON;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
      
    SELECT cuenta 
      FROM sc_sdomensualc
     WHERE cuenta BETWEEN vmincta AND vmaxcta
       AND anio = pAnio
      INTO TEMP tmp_sdosmensuales WITH NO LOG;
    CREATE INDEX idx_tmpsdos ON tmp_sdosmensuales(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sdosmensuales;
    
    FOREACH WITH HOLD
        SELECT cuenta, sucursal 
          INTO vcuenta, vsucursal
          FROM sc_maechq
         WHERE empresa = pEmpresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND cuenta NOT IN(SELECT cuenta FROM tmp_sdosmensuales)
           AND status_cta <> '2'
        
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;
        
        INSERT INTO sc_sdomensualc VALUES( vcuenta, pAnio, vsucursal,
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
        
        INSERT INTO sc_sdotrimestralc VALUES
        (vcuenta, pAnio, vsucursal, 0.00, 0.00, 0.00, 0.00);
        
        LET vcuantos = vcuantos + 1;
        LET vcommit = vcommit + 1; 
        
        IF vcommit >= 1000 THEN
            LET vcommit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;   
        
        LET vcuenta = '';
        LET vsucursal = '';
    END FOREACH;
    
    IF vcommit >= 0 THEN
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_sdomensualc;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcuantos;
    
END PROCEDURE;