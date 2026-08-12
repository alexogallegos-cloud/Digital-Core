CREATE PROCEDURE "informix".upd_movdia(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vnum_serial 	INTEGER;

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./upd_movdia.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;
   
   FOREACH
       SELECT {+ INDEX(sc_movdia idx_movdia1a)}
	      num_serial, cuenta
	 INTO vnum_serial, vcuenta
         FROM sc_movdia
        WHERE empresa = pempresa
	  AND cuenta IS NOT NULL
          AND transacc = "0270"
          AND usuario = "informix"

       UPDATE {+ INDEX(sc_movdia idx_movdia1a)} sc_movdia
          SET transacc = "0830",
	      transacc_suc = "0830"
	WHERE empresa = pempresa
	  AND cuenta = vcuenta
          AND transacc = "0270"
	  AND num_serial = vnum_serial
        AND usuario = "informix";

   END FOREACH

   END;

   RETURN vcodret;

END PROCEDURE;