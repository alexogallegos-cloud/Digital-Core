CREATE PROCEDURE "informix".graba_movhis_neg02(pempresa CHAR(3))
    RETURNING CHAR(5), INTEGER;

    DEFINE vcodret     	CHAR(5);
    DEFINE vcuenta   	CHAR(20);
    DEFINE vnum_serial	INTEGER;
    DEFINE sql_err     	INTEGER;
    DEFINE vcontador  	INTEGER;
    DEFINE vt_cuantos	INTEGER;

    LET vcodret    = "000";
    LET vcuenta = 0;
    LET vnum_serial = 0;
    LET sql_err = 0;
    LET vcontador = -1;
    LET vt_cuantos = 0;

    BEGIN

       ON EXCEPTION SET sql_err
          IF sql_err <> 0 THEN
             LET vcodret = sql_err;
             RETURN vcodret, vt_cuantos;
          END IF;
       END EXCEPTION;

       --SET DEBUG FILE TO "./graba_neg.out";
       --TRACE ON;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 4;

       SELECT {+ INDEX(sc_movhis_movneg idx_movhis_movneg)} *
       FROM sc_movhis_movneg
       WHERE empresa = pempresa
       AND cuenta IS NOT NULL
       -- AND num_serial >= 34796864
       -- AND num_serial <= 35365286
       AND cancelad <> "S"
       ORDER BY num_serial
       INTO TEMP tmp_neg02 WITH NO LOG;
       CREATE INDEX idx_tmp_neg ON tmp_neg02(empresa,cuenta) USING BTREE;
       UPDATE STATISTICS MEDIUM FOR TABLE tmp_neg02;

       -- ************************ FOREACH PRINCIPAL ***********************

       FOREACH WITH HOLD
          SELECT cuenta,num_serial
          INTO vcuenta,vnum_serial
          FROM tmp_neg02
          WHERE empresa = pempresa
          AND cuenta IS NOT NULL

          IF (vcontador = -1) THEN
             BEGIN WORK;
             LET vcontador = 0;
          END IF;

          INSERT INTO sc_movdia
          SELECT 0,folio_suc,sucursal,usuario,fech_alt,fech_val,
                 fech_hor,transacc,suc_cuen,producto,empresa,cuenta,causa_dev,
                 num_cheq,monto_tot,firme,en_sbc,remesas,dias_ret,cancelad,
                 edo_cta,sdo_cuenta,transacc_suc,referencia,tasa_aplicada,
                 num_tarjeta,usuautoriza
          FROM tmp_neg02
          WHERE empresa = pempresa
          AND cuenta = vcuenta;

          INSERT INTO sc_movhis
          SELECT "200901", *
          FROM sc_movdia
          WHERE empresa = pempresa
          AND cuenta  = vcuenta
          AND transacc in('3381');

          DELETE FROM sc_movdia
          WHERE empresa = pempresa
          AND cuenta = vcuenta
          AND transacc in('3381');

          UPDATE sc_movhis_movneg
          SET cancelad = "S"
          WHERE empresa = pempresa
          AND cuenta = vcuenta
          AND num_serial = vnum_serial;

	  LET vcontador = vcontador + 1;

          IF (Vcontador >= 36000) THEN
             LET vt_cuantos = vt_cuantos + vcontador;
	     LET vcontador = 0;
             COMMIT WORK;
             BEGIN WORK;
          END IF;
       END FOREACH;

       -- ************************ FOREACH PRINCIPAL ***********************

       LET vt_cuantos = vt_cuantos + vcontador;

       IF (vcontador > 0) THEN
          COMMIT WORK;
       END IF;

    END;

    RETURN vcodret, vt_cuantos;

END PROCEDURE;