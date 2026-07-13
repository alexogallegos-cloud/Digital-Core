CREATE PROCEDURE "informix".corrige_saldos5(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE NumCred     CHAR(20);
DEFINE Insoluto    DECIMAL(14,2);
DEFINE Capital     DECIMAL(14,2);
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);
DEFINE CodRet      CHAR(5);
DEFINE MtoVencido DECIMAL(14,2);
DEFINE CUantos    SMALLINT;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

 SET DEBUG FILE TO "dupintercard.out";
 TRACE ON;

LET CodRet ="000";


FOREACH SELECT num_credito
	  INTO NumCred
	  FROM sd_maecred
	 WHERE status_cred = "BT"


	SELECT SUM(interes_debe + interes_pagado)
	  INTO MtoVencido
	  FROM sd_amortiza_credito
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred;


	UPDATE sd_maesdos
	   SET sdo_no_exig = MtoVencido,
	       int_tra_no_exig = MtoVencido
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;


	UPDATE sd_amortiza_credito
	   SET capital_status = "2"
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred
	   AND fecha_cuota < "09/19/2007"
	   AND capital_status <> "5";

END FOREACH


FOREACH SELECT a.num_credito, SUM(interes_debe - interes_pagado)
	  INTO NumCred, MtoVencido
          FROM sd_maesdos a, sd_amortiza_credito b
         WHERE a.sdo_cap_insoluto <= 0
           AND b.empresa = a.empresa
           AND b.num_credito = a.num_credito
         GROUP BY 1
        HAVING SUM(interes_debe - interes_pagado) > 0


	UPDATE sd_amortiza_credito
	   SET interes_debe = 0,
	       interes_pagado = 0,
	       iva_debe = 0,
	       iva_pagado = 0
	WHERE empresa = eEmpresa
	  AND num_credito = NumCred;


END FOREACH


FOREACH select num_credito
   INTO NumCred from sd_movhis
  WHERE codigo_fun ="005"
    AND codigo_ref IN (1  )
    AND fecha_mov between "09212007" and "10202007"

	UPDATE sd_amortiza_credito
	   SET interes_debe = 0,
	       interes_pagado = 0,
	       iva_debe = 0,
	       iva_pagado = 0
	 WHERE empresa = eEmpresa
	   AND num_credito = NumCred;

END FOREACH

RETURN CodRet;

END PROCEDURE
;