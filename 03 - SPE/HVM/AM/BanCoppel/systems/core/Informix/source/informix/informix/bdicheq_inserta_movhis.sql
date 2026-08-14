CREATE PROCEDURE "informix".inserta_movhis(pempresa CHAR(3))

RETURNING CHAR(5), CHAR(5), INTEGER;

    DEFINE vcodret1         CHAR(5);
    DEFINE vcodret2         CHAR(5);
    DEFINE vsqlerr          INTEGER;
    DEFINE visamerr         INTEGER;
    DEFINE vcontador        INTEGER;
    DEFINE vcuantos         INTEGER;
    DEFINE vcomienza        INTEGER;
    DEFINE vtransaccion     SMALLINT;
    DEFINE vfcuenta         CHAR(20);
    DEFINE FechaProc        DATE;
    DEFINE vaniomes         CHAR(6);
    DEFINE vmes,
           vdia             CHAR(2);
    DEFINE vanio            CHAR(4);
    DEFINE vfecha_hoy       DATE;
    DEFINE vult_dia_mes     DATE;
    DEFINE vBandNva         SMALLINT;
    
    LET vcodret1     = "000";
    LET vcodret2     = "000";
    LET vcontador    = -1;
    LET vcuantos     = 0;
    LET vcomienza    = -1;
    LET vtransaccion = 0;
    
    --- SET DEBUG FILE TO "inserta_movhis.out"
    --- TRACE ON;
    
    BEGIN
    
    ON EXCEPTION SET vsqlerr, visamerr
        IF vsqlerr <> 0 THEN
            LET vcodret1 = vsqlerr;
            LET vcodret2 = visamerr;
            IF vtransaccion = 1 THEN
                ROLLBACK WORK;
            END IF
            RETURN vcodret1, vcodret2, vcuantos;
        END IF;
    END EXCEPTION;
    
    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 2;
    
    SELECT fecha_hoy, ult_dia_mes
      INTO vfecha_hoy, vult_dia_mes
      FROM sc_fechas
     WHERE empresa = pempresa;

    -- // Realiza Pase de Movimientos al Historico Especial
    LET vfcuenta  = '';
    LET FechaProc = '';

    FOREACH WITH HOLD
        SELECT b.cuenta, a.fecha_proceso
          INTO vfcuenta, FechaProc
          FROM sc_maechq a, 
               sc_movdia b
         WHERE a.empresa = pempresa
           AND a.cuenta = b.cuenta
           AND b.empresa = a.empresa
           AND b.cuenta = a.cuenta
           AND b.fech_alt = '01272010'
           
        IF vcomienza = -1 THEN
            LET vcomienza = 0;
            LET vcontador = 0;
            LET vtransaccion = 1;
            BEGIN WORK;
        END IF

        SELECT MAX(aniomes)
          INTO vaniomes
          FROM sc_maehis
         WHERE empresa = pempresa
           AND cuenta = vfcuenta;

        IF vaniomes IS NULL THEN
            LET vaniomes =  YEAR(FechaProc) || LPAD(month(FechaProc),2,0);
        ELSE
            LET vdia = DAY(FechaProc);
            LET vmes = MONTH(vfecha_hoy);
            LET vanio = YEAR(vfecha_hoy);

            IF FechaProc = vfecha_hoy THEN
                LET vdia = 0;
            END IF

            IF vdia > DAY(vult_dia_mes) OR vdia < 1 THEN
                LET FechaProc = vult_dia_mes;
            ELSE
                LET FechaProc = LPAD(TRIM(vmes),2,"0")||"/"||
                                LPAD(TRIM(vdia),2,"0")||"/"||vanio;
            END IF
        END IF
        
        IF FechaProc <> vfecha_hoy THEN
            LET vBandNva = SUBSTR(vaniomes,5);

            IF vBandNva = 12 THEN
                LET vBandNva = 1;
            ELSE
                LET vBandNva = vBandNva + 1;
            END IF

            LET vaniomes = SUBSTR(vaniomes,1,4) || LPAD(vBandNva,2,0);
        END IF

        INSERT INTO sc_movhis
        SELECT vaniomes, a.*
          FROM sc_movdia a
         WHERE a.empresa = pempresa
           AND a.cuenta  = vfcuenta;
           
        DELETE FROM sc_movdia
         WHERE empresa = pempresa
           AND cuenta  = vfcuenta;
           
        LET vcontador = vcontador + 1;
        
        IF vcontador >= 500 THEN
            LET vcuantos = vcuantos + vcontador;
            LET vcontador = 0;
            COMMIT WORK;
            BEGIN WORK;
        END IF

    END FOREACH
    
    IF vcontador > 0 THEN
        LET vcuantos = vcuantos + vcontador;
        COMMIT WORK;
    END IF
    
    END;

    RETURN vcodret1, vcodret2, vcuantos;

END PROCEDURE;