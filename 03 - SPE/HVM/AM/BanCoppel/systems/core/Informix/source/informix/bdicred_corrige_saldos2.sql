CREATE PROCEDURE "informix".corrige_saldos2(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE NumCred     CHAR(20);
DEFINE Insoluto    DECIMAL(14,2);
DEFINE Capital     DECIMAL(14,2);
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);
DEFINE CodRet      CHAR(5);
DEFINE MtoVencido DECIMAL(14,2);


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

-- SET DEBUG FILE TO "dupintercard.out";
-- TRACE ON;

LET CodRet ="000";

FOREACH SELECT num_credito, monto
	  INTO NumCred, Capital
          FROM sd_movhis
         WHERE codigo_fun ="342"
           AND codigo_ref = 2
         ORDER BY 1

        UPDATE sd_maesdos
           SET sdo_capital = sdo_capital + Capital,
               sdo_cap_insoluto = sdo_cap_insoluto + Capital
         WHERE empresa = eEmpresa
           AND num_credito = NumCred;


END FOREACH 

RETURN CodRet;

END PROCEDURE
;