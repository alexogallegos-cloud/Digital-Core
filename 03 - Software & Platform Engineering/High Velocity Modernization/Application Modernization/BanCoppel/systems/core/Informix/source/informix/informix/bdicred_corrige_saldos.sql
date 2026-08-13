CREATE PROCEDURE "informix".corrige_saldos(eEmpresa CHAR(3))
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
   -- Caso 1 Vigente con Venc Trasp y Venc No Exig
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
		  sdo_capital + mto_venc_trasp + cap_tras_no_venci
	     INTO NumCred, Insoluto, Capital
	     FROM sd_maesdos a, sd_maecred b
	    WHERE a.empresa = eEmpresa
	      AND b.empresa = a.empresa
	      AND b.num_credito = a.num_credito
	      AND b.status_cred = "AA"
	      AND cap_tras_no_venci > 0
	      AND sdo_capital > 0

	IF Insoluto <> Capital THEN
		CONTINUE FOREACH;
	END IF

	UPDATE sd_maesdos
	   SET sdo_capital = sdo_cap_insoluto,
	       mto_venc_trasp = 0,
	       cap_tras_no_venci = 0
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;

   END FOREACH


   -- Caso 2 VIgente con VIgente en Negativo y Venc No Exig
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + cap_tras_no_venci
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "AA"
              AND cap_tras_no_venci > 0
	      AND sdo_capital < 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = sdo_cap_insoluto,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

   END FOREACH


   -- Caso 3 Vigente con Venc Traspasado Negativo
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + monto_vencido
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "AA"
              AND monto_vencido < 0
              AND sdo_capital > 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = sdo_cap_insoluto,
               monto_vencido = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

   END FOREACH


   -- Caso 4 Vigente con Venc Traspasado y cap_tras_no_venci positivos
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + mto_venc_trasp + cap_tras_no_venci
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "AA"
              AND mto_venc_trasp > 0
              AND sdo_capital > 0
	      AND cap_tras_no_venci > 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = sdo_cap_insoluto,
               mto_venc_trasp = 0,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

   END FOREACH


   -- Caso 4 Transitorio con Monto Vencido en Cero
   FOREACH SELECT a.num_credito,
                  sdo_capital
	     INTO NumCred, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BA"
              AND monto_vencido = 0
              AND sdo_capital > 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = sdo_cap_insoluto,
               monto_vencido = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_maecred
	   SET status_cred = "AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_amortiza_credito
	   SET capital_status = "1"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
	   AND capital_status = "7";

   END FOREACH

   -- Caso 5 Transitorio con Cap Venc No Exig mayor a Cero
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + cap_tras_no_venci + monto_vencido,
	          monto_vencido
	     INTO NumCred, Insoluto, Capital, MtoVencido
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BA"
              AND monto_vencido > 0
              AND cap_tras_no_venci > 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = Capital - MtoVencido,
               cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_maecred
           SET status_cred = "BA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

        UPDATE sd_amortiza_credito
           SET capital_status = "7"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
           AND capital_status = "1"
	   AND fecha_cuota < "08/20/2007";

   END FOREACH

   -- Caso 6 Traspasado con Saldo de Capital Vigente
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BT"
              AND sdo_capital > 0


	   UPDATE sd_maesdos
	      SET cap_tras_no_venci = cap_tras_no_venci + sdo_capital,
		  sdo_capital = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;


   END FOREACH

   -- Caso 20 Saldos Retenido vs Maestro de Credito
   SELECT a.num_credito, sdo_retenido,
	  NVL((SELECT SUM(monto) FROM sd_maeretenido
		WHERE num_credito = a.num_credito
	   	  AND empresa = eEmpresa
		  AND estatus = "P"),0) detalle
     FROM sd_maesdos a
     INTO TEMP retcred;


   FOREACH SELECT num_credito, detalle
	     INTO NumCred, Capital
	     FROM retcred
	    WHERE sdo_retenido <> detalle

	UPDATE sd_maesdos
	   SET sdo_retenido = Capital
	 WHERE num_credito = NumCred
	   AND empresa = eEmpresa;

   END FOREACH


   -- Caso 21 Saldos Retenido vs Maestro de Cheques
   SELECT cuenta, sdo_retenido,
          NVL((SELECT SUM(monto) FROM bdicheq:sc_docret
                WHERE cuenta = a.cuenta
                  AND empresa = eEmpresa
                  AND cancelado = "P"),0) detalle
     FROM bdicheq:sc_maechq a
     INTO TEMP retchq;


   FOREACH SELECT cuenta, detalle
             INTO NumCred, Capital
             FROM retchq
            WHERE sdo_retenido <> detalle

        UPDATE bdicheq:sc_maechq
           SET sdo_retenido = Capital
         WHERE cuenta = NumCred
           AND empresa = eEmpresa;

   END FOREACH

FOREACH SELECT num_credito, monto
	  INTO NumCred, Capital
          FROM sd_movhis
         WHERE transacc_suc ="6699"
           AND reversado ="N"
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