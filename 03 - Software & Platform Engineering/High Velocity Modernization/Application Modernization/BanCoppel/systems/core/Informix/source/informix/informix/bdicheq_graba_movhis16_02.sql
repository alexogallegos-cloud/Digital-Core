CREATE PROCEDURE "informix".graba_movhis16_02(pempresa char(3))
    RETURNING CHAR(5), integer;

    DEFINE vcodret     CHAR(5);
    DEFINE vcodret1    CHAR(5);
    DEFINE vt_cuenta   CHAR(20);
    DEFINE sql_err     INTEGER;
    DEFINE vt_cuantos  INTEGER;

    LET vcodret    = "000";
    LET vt_cuenta = 0;
    LET sql_err = 0;
    LET vt_cuantos = -1;

    BEGIN
       ON EXCEPTION SET sql_err
          IF sql_err > 0 THEN
             LET vcodret = sql_err;
             IF vt_cuantos <> 0 THEN
                ROLLBACK WORK;
             END IF
             RETURN vcodret, 0;
          END IF;
       END EXCEPTION;

       --SET DEBUG FILE TO "./pasa_al_movhis.out";
       --TRACE ON;

       SET ISOLATION TO DIRTY READ;

       if (vt_cuantos = -1) then
          begin work;
          let vt_cuantos = 0;
       end if;

       -- **********************
       --   FOREACH PRINCIPAL
       -- **********************
       FOREACH with hold
          SELECT cuenta
          INTO vt_cuenta
          FROM sc_movhis_mov16
          WHERE num_serial > 37316500

          INSERT INTO sc_movhis
          SELECT "200901", mov.*
          FROM sc_movhis_mov16 mov
          WHERE mov.empresa = pempresa
          AND mov.cuenta = vt_cuenta;

          LET vt_cuantos = vt_cuantos + 1;

          if (vt_cuantos  >= 70000) then
             let vt_cuantos = 0;
             commit work;
             update statistics medium for table sc_movhis;
             begin work;
          end if;
       END FOREACH

       if (vt_cuantos  >= 0) then
          commit work;
          update statistics medium for table sc_movhis;
       end if;
       RETURN vcodret, vt_cuantos ;
    END
END PROCEDURE;