CREATE PROCEDURE "informix".corrige_saldos4(eEmpresa CHAR(3))
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

-- SET DEBUG FILE TO "dupintercard.out";
-- TRACE ON;

LET CodRet ="000";
   -- Caso especial
   UPDATE sd_amortiza_credito
      SET capital_status = "1"
    WHERE capital_status IN ("2","7")
      AND fecha_cuota = "08/20/2007";



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

   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7","2"))
	     INTO NumCred, Cuantos
	     FROM sd_maecred a
	    WHERE status_cred = "AA"


	     IF Cuantos = 0 THEN
		CONTINUE FOREACH;
	     END IF


	     UPDATE sd_amortiza_credito
		SET capital_status ="5"
	      WHERE num_credito = NumCred
		AND empresa = eEmpresa
		AND fecha_cuota < "08/20/2007";


   END FOREACH

   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("2"))
             INTO NumCred, Cuantos
             FROM sd_maecred a
            WHERE status_cred = "BT"


             IF Cuantos = 2 THEN
                CONTINUE FOREACH;
             END IF


             UPDATE sd_amortiza_credito
                SET capital_status ="2"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota < ("08/20/2007");


   END FOREACH


   FOREACH SELECT a.num_credito,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =eEmpresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7"))
             INTO NumCred, Cuantos
             FROM sd_maecred a
            WHERE status_cred = "BA"


             IF Cuantos = 1 THEN
                CONTINUE FOREACH;
             END IF

	     UPDATE sd_amortiza_credito
                SET capital_status ="5"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota < ("07/20/2007");


             UPDATE sd_amortiza_credito
                SET capital_status ="7"
              WHERE num_credito = NumCred
                AND empresa = eEmpresa
                AND fecha_cuota IN ("07/20/2007");


   END FOREACH

   FOREACH SELECT a.num_credito INTO NumCred
	     FROM sd_maesdos a, sd_maecred b
	    WHERE status_cred = "BA"
	      AND sdo_cap_insoluto =0
	      AND a.num_credito = b.num_credito

	  UPDATE sd_maecred set status_cred = "AA"
	   WHERE num_credito = NumCred
	     AND empresa = "001";

  END FOREACH


   -- Caso 3 Vigente con Venc Traspasado Negativo
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + mto_venc_trasp
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "AA"
              AND mto_venc_trasp < 0
              AND sdo_capital > 0


        UPDATE sd_maesdos
           SET sdo_capital = Capital,
	       sdo_cap_insoluto = Capital,
               monto_vencido = 0,
	       mto_venc_trasp = 0,
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
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + monto_vencido
	     INTO NumCred, Insoluto,Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred IN ("BA", "AA")
              AND monto_vencido < 0
              AND sdo_capital > 0

        IF Insoluto <> Capital THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_maesdos
           SET sdo_capital = Capital,
	       sdo_cap_insoluto = Capital,
               monto_vencido = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_maecred
	   SET status_cred = "AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_amortiza_credito
	   SET capital_status = "5"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
	   AND capital_status IN ("7","2");

   END FOREACH

   -- Caso 5 Transitorio con Cap Venc No Exig mayor a Cero
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + cap_tras_no_venci + monto_vencido,
	          monto_vencido,
                  (SELECT COUNT(*) FROM sd_amortiza_credito
                    where empresa =a.empresa
                      AND num_credito = a.num_credito
                      AND capital_status IN ("7","2"))
	     INTO NumCred, Insoluto, Capital, MtoVencido, Cuantos
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BA"
              AND monto_vencido > 0

        IF Cuantos <=  1  THEN
                CONTINUE FOREACH;
        END IF

        UPDATE sd_amortiza_credito
           SET capital_status = "7"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
           AND capital_status = "1"
	   AND fecha_cuota = "07/20/2007";

   END FOREACH

   -- Caso 6 Traspasado con Saldo de Capital Vigente
   FOREACH SELECT a.num_credito, cap_tras_no_venci,
                  sdo_capital + mto_venc_trasp
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BT"
              AND mto_venc_trasp < 0

	   LET Insoluto = Insoluto - Capital;
	   UPDATE sd_maesdos
	      SET cap_tras_no_venci = 0,
		  sdo_capital = Insoluto,
		  sdo_cap_insoluto = Insoluto
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;


	  UPDATE sd_maecred
	     SET status_cred = "AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;


	UPDATE sd_amortiza_credito
	   SET capital_status = "5"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
	   AND fecha_cuota < "08/20/2007";


   END FOREACH


RETURN CodRet;

END PROCEDURE
;