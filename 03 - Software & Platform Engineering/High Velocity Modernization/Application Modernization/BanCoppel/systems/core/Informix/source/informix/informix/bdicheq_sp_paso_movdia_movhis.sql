CREATE PROCEDURE "informix".sp_paso_movdia_movhis(pempresa CHAR(3))

  RETURNING CHAR(5), INTEGER, INTEGER;

    DEFINE vcodret     	CHAR(5);
    DEFINE vcuenta   	CHAR(20);
    DEFINE sql_err     	INTEGER;
    DEFINE vcontador	INTEGER;	
    DEFINE vno_ctas	INTEGER;

    LET vcodret    = "000";
    LET sql_err = 0;
    LET vcontador = -1;
    LET vno_ctas = 0;

    BEGIN

       ON EXCEPTION SET sql_err
          IF sql_err <> 0 THEN
             LET vcodret = sql_err;
             RETURN vcodret, vcontador, vno_ctas;
          END IF;
       END EXCEPTION;

       -- SET DEBUG FILE TO "./paso_movdia_movhis.out";
       -- TRACE ON;

       SET ISOLATION TO DIRTY READ;
       SET LOCK MODE TO WAIT 3;

       UPDATE STATISTICS HIGH FOR TABLE "informix".paso_movdia_movhis;

       SELECT COUNT(DISTINCT cuenta)
         INTO vno_ctas
         FROM paso_movdia_movhis
        WHERE cuenta IS NOT NULL
          AND empresa = pempresa;

       -- ********************** FOREACH PRINCIPAL **********************

       FOREACH WITH HOLD
          SELECT DISTINCT(cuenta)
            INTO vcuenta
            FROM paso_movdia_movhis
           WHERE cuenta IS NOT NULL
             AND empresa = pempresa

          IF (vcontador = -1) THEN
             BEGIN WORK;
             LET vcontador = 0;
          END IF

          INSERT INTO sc_movhis
          SELECT *, "", ""
            FROM paso_movdia_movhis
           WHERE cuenta  = vcuenta
             AND empresa = pempresa;

          LET vcontador = vcontador + 1;

          COMMIT WORK;
          BEGIN WORK;

       END FOREACH;

       -- ********************** FOREACH PRINCIPAL **********************


       IF (vno_ctas = vcontador) THEN
          -- TRUNCATE TABLE "informix".paso_movdia_movhis;
       ELSE
          LET vcodret = "111";
          RETURN vcodret, vcontador, vno_ctas;
       ENd IF       

    END;

    RETURN vcodret, vcontador, vno_ctas;

END PROCEDURE;