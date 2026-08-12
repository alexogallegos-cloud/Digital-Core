CREATE PROCEDURE "informix".reverdis(o_empresa CHAR(3),
			   o_sucursal CHAR(3),
			   o_usuario  CHAR(8),
			   o_folio    CHAR(16))
RETURNING CHAR(5);

-- ***************************************************************************
-- *                         DEFINICION DE VARIABLES                         *
-- ***************************************************************************
DEFINE v_codret		CHAR(5);
DEFINE sql_err		INTEGER;
DEFINE vtotefec         MONEY(14,2);
DEFINE vtottran         MONEY(14,2);
DEFINE vdivisa          CHAR(2);
DEFINE vdenom           MONEY(14,2);
DEFINE vcantidad        INTEGER;
DEFINE vingegr          CHAR(1);
DEFINE vstatus          INTEGER;
DEFINE vuser            CHAR(8);


-- ***************************************************************************


   ON EXCEPTION SET sql_err
      LET v_codret  = "000";
      IF sql_err <> 0 THEN
         SET DEBUG FILE TO "/apasco/pisa_ftes/ofi.spl/reverdis.out";
         TRACE ON;
         LET v_codret = sql_err;
         ROLLBACK WORK;
         RETURN v_codret;
      END IF
   END EXCEPTION;



LET v_codret  = "000";
LET sql_err   = 0;
LET vtotefec = 0;
LET vtottran = 0;
LET o_folio = o_folio;
LET vdivisa = " ";
LET vdenom   = 0;
LET vcantidad   = 0;
LET vingegr = " ";
LET vstatus  = 0;
LET vuser   = " ";

  SELECT status,usuarioid INTO vstatus,vuser
  FROM   so_transacmov
  WHERE sectransac = trim(o_folio);
  IF vstatus = 5 or vstatus IS NULL THEN
     LET v_codret = "000";
     RETURN v_codret;
  END IF
-- Total efectivo 

--SELECT divisaid,importetransac INTO vdivisa,vtottran
--FROM   so_transacmov
--WHERE  sectransac = trim(o_folio);

--SELECT totalefectivo INTO vtotefec 
--FROM   so_arqueo
--WHERE  divisaid = vdivisa
--AND    usuarioid = trim(o_usuario);

--IF vtotefec < vtottran THEN
--   LET v_codret = "120";
--   RETURN v_codret;
--END IF


   BEGIN WORK;

   foreach
       SELECT divisaid,denominid,cantidad,importe,ingresoegreso
       INTO   vdivisa,vdenom,
              vcantidad,vtoTefec,vingegr
       FROM   so_desgefectdet
       WHERE  sectransac = trim(o_folio)
       IF vdivisa IS NULL THEN
          exit foreach;
       END IF
       IF vingegr = "I" THEN
          UPDATE so_arqueodet SET cantidad = cantidad - vcantidad,
              importe = importe - vtotefec
          WHERE  denominid = vdenom
          AND    divisaid = vdivisa
          AND    usuarioid = trim(vuser);
          UPDATE so_arqueo SET totalefectivo = totalefectivo - vtotefec
          WHERE  divisaid = vdivisa
          AND    usuarioid = trim(vuser);
       ELSE
          UPDATE so_arqueodet SET cantidad = cantidad + vcantidad,
              importe = importe + vtotefec
          WHERE  denominid = vdenom
          AND    divisaid = vdivisa
          AND    usuarioid = trim(vuser);
          UPDATE so_arqueo SET totalefectivo = totalefectivo + vtotefec
          WHERE  divisaid = vdivisa
          AND    usuarioid = trim(vuser);
       END IF
   end foreach     

   UPDATE so_transacmov SET status = 5
   WHERE sectransac = trim(o_folio);

   COMMIT WORK;
RETURN v_codret;

END PROCEDURE;