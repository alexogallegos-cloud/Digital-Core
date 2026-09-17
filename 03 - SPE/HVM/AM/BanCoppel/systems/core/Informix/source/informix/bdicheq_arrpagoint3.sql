CREATE PROCEDURE "informix".arrpagoint3(pempresa CHAR(3))
   
RETURNING CHAR(5), INTEGER;

    DEFINE vcodret       CHAR(5);
    DEFINE vsqlerr       INTEGER;
    DEFINE contador      INTEGER;
    DEFINE vt_cuantos    INTEGER;
    DEFINE vcuenta       CHAR(20);
    DEFINE vsdo_actual   MONEY(14,2);
    DEFINE vmonto_int    MONEY(14,2);

    LET vcodret = "000";
    LET contador = -1;
    LET vt_cuantos = 0;

    --- SET DEBUG FILE TO "arrpagoint.out";
    --- TRACE ON;

    BEGIN

    ON EXCEPTION SET vsqlerr
        IF vsqlerr <> 0 THEN
            LET vcodret = vsqlerr;
            RETURN vcodret, vt_cuantos;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 4;
    
    FOREACH WITH HOLD
        SELECT mov.cuenta, mov.monto_tot
          INTO vcuenta, vmonto_int
          FROM sc_movhis mov
         WHERE mov.empresa = pempresa
           AND mov.cuenta IS NOT NULL
           AND mov.fech_alt = '12082009'
           AND mov.transacc = '3276'
           AND mov.producto <> '1100'

        IF (contador = -1) THEN
            BEGIN WORK;
            LET contador = 0;
        END IF;

        UPDATE sc_maechq
           SET sdo_actual = sdo_actual + vmonto_int,
               num_abonos_mes = num_abonos_mes + 1,
               imp_abonos_mes = imp_abonos_mes + vmonto_int,
               ultpagoint = '12082009',
               fec_ult_mov = '12092009'
         WHERE empresa = pempresa
           AND cuenta = vcuenta;

        LET contador = contador + 1;

        IF (contador >= 1000) THEN
        LET vt_cuantos = vt_cuantos + contador;
        LET contador = 0;
        COMMIT WORK;
        BEGIN WORK;
        END IF;

    END FOREACH;

    -- ********************** FOREACH PRINCIPAL *************************

    LET vt_cuantos = vt_cuantos + contador;

    IF (contador > 0) THEN
    COMMIT WORK;
    END IF;

    END;

    RETURN vcodret, vt_cuantos;

END PROCEDURE;