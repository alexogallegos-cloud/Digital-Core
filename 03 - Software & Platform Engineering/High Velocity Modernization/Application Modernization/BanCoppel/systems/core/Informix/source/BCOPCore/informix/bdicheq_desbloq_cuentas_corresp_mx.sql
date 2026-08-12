CREATE PROCEDURE "informix".desbloq_cuentas_corresp_mx(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vstatus 	CHAR(1);
   DEFINE vmotivo 	CHAR(2);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vfolio	CHAR(20);
   DEFINE vsql	    CHAR(500);

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   SET DEBUG FILE TO "/tmp/desbloq_cuentas.out";
   TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
   
   CREATE TABLE "informix".desbloqcuentas(cuenta CHAR(20));

   LET vsql = "";
   LET vsql = 'echo "LOAD FROM cuentasadesbloquear.txt INSERT INTO desbloqcuentas" > ctas_desbloq.sql';
   SYSTEM vsql;

   LET vsql = "";
   LET vsql = "dbaccess bdicheq ctas_desbloq.sql";
   -- LET vsql = "/ifxsif01/bin/dbaccess bdicheq ctas_bloq.sql";
   SYSTEM vsql;
   LET vsql = "";
   
   FOREACH
    SELECT cuenta
	  INTO vcuenta
      FROM desbloqcuentas
     WHERE cuenta IS NOT NULL

	SELECT status_cta, motivo
	  INTO vstatus, vmotivo
	  FROM sc_maechq
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

	IF vstatus = "3" AND vmotivo = "09" THEN

        UPDATE sc_maechq
           SET status_cta = "1",
	            motivo = "00"
	     WHERE empresa = pempresa
           AND cuenta = vcuenta;

	    INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "D", "00", " ", 0.00, "informix", vfecha, current hour to fraction, "1111", "D", vfolio, " ", " ", " ", " ", " ");

        DELETE FROM sc_ctabloqueo
	     WHERE cuenta = vcuenta;
		 
	END IF;
	
	DELETE FROM cuentas
     WHERE cuenta = vcuenta;

   END FOREACH
   
   END;
   
   DROP TABLE "informix".desbloqcuentas;

   RETURN vcodret;

END PROCEDURE;