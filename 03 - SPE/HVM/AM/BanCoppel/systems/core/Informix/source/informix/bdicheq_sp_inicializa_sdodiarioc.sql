CREATE PROCEDURE "informix".sp_inicializa_sdodiarioc(pempresa CHAR(3))
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
    LET vanio = '';
    LET vmes = '';
    LET vaniomes = '';
    LET vcuenta = '';
    LET vsucursal = '';
    LET vmincta  = "";
    LET vmaxcta  = "";
    
    BEGIN
    
    ON EXCEPTION SET sql_err, isam_err, error_info
        SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdodiarioc.err";
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
    
    --- SET DEBUG FILE TO "/resplogifx/conciliachq/sp_inicializa_sdodiarioc.out";
    --- TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT fecha_hoy, ult_dia_mes
      INTO vfecha_hoy, vult_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;
     
    LET vanio_actual = YEAR(vfecha_hoy);
    LET vdiaproxmes = vult_dia_mes + 1;
    LET vanio = YEAR(vdiaproxmes);
    LET vmes = LPAD(MONTH(vdiaproxmes),2,'0');
    LET vaniomes = vanio||vmes;
    
    SELECT MIN(cuenta), MAX(cuenta)
      INTO vmincta, vmaxcta
      FROM sc_maechq;
      
    SELECT cuenta 
      FROM sc_sdodiarioc
     WHERE cuenta BETWEEN vmincta AND vmaxcta
       AND aniomes = vaniomes
      INTO TEMP tmp_sdosdiarios WITH NO LOG;
    CREATE INDEX idx_tmpsdos ON tmp_sdosdiarios(cuenta) USING BTREE FILLFACTOR 99;
    UPDATE STATISTICS MEDIUM FOR TABLE tmp_sdosdiarios;

    FOREACH WITH HOLD
        SELECT cuenta, sucursal 
          INTO vcuenta, vsucursal
          FROM sc_maechq
         WHERE empresa = pempresa
           AND cuenta BETWEEN vmincta AND vmaxcta
           AND cuenta NOT IN(SELECT cuenta FROM tmp_sdosdiarios)
           AND status_cta <> '2'

        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            BEGIN WORK;
        END IF;

        INSERT INTO sc_sdodiarioc VALUES
        ( vcuenta, vaniomes, vsucursal, 
          0, 0, '', -- 1
          0, 0, '', -- 2
          0, 0, '', -- 3
          0, 0, '', -- 4
          0, 0, '', -- 5
          0, 0, '', -- 6
          0, 0, '', -- 7
          0, 0, '', -- 8
          0, 0, '', -- 9
          0, 0, '', -- 10
          0, 0, '', -- 11
          0, 0, '', -- 12
          0, 0, '', -- 13
          0, 0, '', -- 14
          0, 0, '', -- 15
          0, 0, '', -- 16
          0, 0, '', -- 17 
          0, 0, '', -- 18
          0, 0, '', -- 19
          0, 0, '', -- 20
          0, 0, '', -- 21
          0, 0, '', -- 22
          0, 0, '', -- 23
          0, 0, '', -- 24
          0, 0, '', -- 25
          0, 0, '', -- 26
          0, 0, '', -- 27
          0, 0, '', -- 28
          0, 0, '', -- 29
          0, 0, '', -- 30
          0, 0, '', -- 31
          0, 0, '' );

        IF vmes = '01' AND vanio <> vanio_actual THEN
            INSERT INTO sc_sdomensualc VALUES( vcuenta, vanio, vsucursal,
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 
            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 );
            
            INSERT INTO sc_sdotrimestralc VALUES
            (vcuenta, vanio, vsucursal, 0.00, 0.00, 0.00, 0.00);
        END IF;
        
        LET vcuantos = vcuantos + 1;
        LET vcommit = vcommit + 1; 
        
        IF vcommit >= 1000 THEN
            LET vcommit = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF;   
        
    END FOREACH;
    
    IF vcommit >= 0 THEN
        COMMIT WORK;
    END IF;
    
    UPDATE STATISTICS MEDIUM FOR TABLE sc_sdodiarioc;
    
    IF vmes = '01' AND vanio <> vanio_actual THEN
        UPDATE STATISTICS MEDIUM FOR TABLE sc_sdomensualc;
    END IF;
    
    END;
    
    RETURN vcodret1, vcodret2, vcodret3, vcuantos;
    
END PROCEDURE;