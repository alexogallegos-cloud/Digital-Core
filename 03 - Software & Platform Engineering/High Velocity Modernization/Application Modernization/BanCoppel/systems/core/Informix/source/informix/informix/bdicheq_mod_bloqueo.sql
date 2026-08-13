CREATE PROCEDURE "informix".mod_bloqueo(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vfolio	CHAR(20);
   DEFINE vcuenta	CHAR(20);
   DEFINE vmotivo 	CHAR(2);
   DEFINE vexiste	INTEGER;

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./mod_bloqueo.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];

   FOREACH
       SELECT cuenta, motivo
	 INTO vcuenta, vmotivo
         FROM sc_maechq
        WHERE status_cta = "3"
          AND cuenta <> "16000000012"

       IF vmotivo = "09" THEN

	   SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_ctabloqueo
	    WHERE cuenta = vcuenta
	      AND clave = vmotivo
	      AND opcion = "3";

	   IF vexiste = 0 THEN
               INSERT INTO sc_ctabloqueo VALUES (vcuenta, "09", "3");
	   END IF;

	   
	   SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_ctabloqueohist
	    WHERE cuenta = vcuenta
	      AND clave = vmotivo
	      AND opcion = "3";

	   IF vexiste = 0 THEN
               INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", "3");
	   END IF;


	   SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_histbloq
	    WHERE cuenta = vcuenta
	      AND status_blo = "B"
	      AND tipo_mov = "B"
	      AND empresa = pempresa
	      AND motivo = vmotivo
	      AND opcion = 3;

	   IF vexiste = 0 THEN
	       INSERT INTO sc_histbloq VALUES(
		  pempresa, vcuenta, "B", "09", 3, 0.00, "informix", vfecha,
		  current hour to fraction, "1111", "B", vfolio, " ");
	   END IF;

       ELSE 

           SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_ctabloqueo
	    WHERE cuenta = vcuenta
	      AND clave = vmotivo;

	   IF vexiste = 0 THEN
               INSERT INTO sc_ctabloqueo VALUES (vcuenta, vmotivo, "4");
	   END IF;


	   SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_ctabloqueohist
	    WHERE cuenta = vcuenta
	      AND clave = vmotivo;

	   IF vexiste = 0 THEN
               INSERT INTO sc_ctabloqueohist VALUES (vcuenta, vmotivo, "4");
	   END IF;


	   SELECT COUNT(*)
	     INTO vexiste
	     FROM sc_histbloq
	    WHERE cuenta = vcuenta
	      AND status_blo = "B"
	      AND tipo_mov = "B"
	      AND empresa = pempresa
	      AND motivo = vmotivo;

	   IF vexiste = 0 THEN
	       INSERT INTO sc_histbloq VALUES(
		 pempresa, vcuenta, "B", vmotivo, 4, 0.00, "informix", vfecha,
		 current hour to fraction, "1111", "B", vfolio, " ");
	   END IF;

       END IF;

   END FOREACH

   END;

   RETURN vcodret;

END PROCEDURE;