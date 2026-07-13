CREATE PROCEDURE "informix".bloqueoctas_tmp(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vsql		CHAR(100);
   DEFINE vfolio	CHAR(20);

   LET    vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./bloqueo_cta_tmp.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
{
   
   CREATE TABLE "informix".cuentasbloq(cuenta CHAR(20));

   LET vsql = "";
   LET vsql = 'echo "LOAD FROM cuentasabloquear.txt INSERT INTO cuentasbloq" > ctas_bloq.sql';
   SYSTEM vsql;

   LET vsql = "";
   --LET vsql = "dbaccess bdicheq ctas_bloq.sql";
   LET vsql = "/ifxsif01/bin/dbaccess bdicheq ctas_bloq.sql";
   SYSTEM vsql;
   LET vsql = "";
   
}
   FOREACH
       SELECT UNIQUE cuenta
	 INTO vcuenta
         FROM cuentasbloq

       INSERT INTO sc_ctabloqueo VALUES(vcuenta, "09", 4, " ", " ", " ", " ");

       INSERT INTO sc_histbloq VALUES(pempresa, vcuenta, "B", "09", 4,
	                              0.00, "informix", vfecha,
				      current hour to fraction,
				      "1111", "B", vfolio, " ", " ", " ", " ", " ");

       UPDATE sc_maechq
  	  SET status_cta = "3",
	      motivo = "09"
	WHERE empresa = pempresa
	  AND cuenta = vcuenta;
   END FOREACH

   END;

   DROP TABLE "informix".cuentasbloq;

   RETURN vcodret;

END PROCEDURE;