CREATE PROCEDURE "informix".corrige_saldos3(eEmpresa CHAR(3))
RETURNING CHAR(5);



DEFINE NumCred     CHAR(20);
DEFINE Insoluto    DECIMAL(14,2);
DEFINE Capital     DECIMAL(14,2);
DEFINE sql_err     INTEGER;
DEFINE isam_err    INTEGER;
DEFINE error_info  VARCHAR(60);
DEFINE CodRet      CHAR(5);
DEFINE MtoVencido DECIMAL(14,2);
DEFINE vSucursal  CHAR(4);
DEFINE Mensaje    CHAR(50);
DEFINE FechaHoy   DATE;


   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "dupintercard.err";
      TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET CodRet = sql_err;
      RETURN CodRet;
   END EXCEPTION;

-- SET DEBUG FILE TO "dupintercard.out";
-- TRACE ON;
SELECT fecha_hoy INTO FechaHoy FROM sd_fechas;
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


   -- Caso 4 Transitorio con Monto Vencido menor o = a Cero
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
                  sdo_capital + monto_vencido
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BA"
              AND monto_vencido <= 0

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

   -- Caso 7 Traspasado con Saldo Traspa en Cero o negativo
   FOREACH SELECT a.num_credito, sdo_cap_insoluto,
	          mto_venc_trasp + cap_tras_no_venci
	     INTO NumCred, Insoluto, Capital
             FROM sd_maesdos a, sd_maecred b
            WHERE a.empresa = eEmpresa
              AND b.empresa = a.empresa
              AND b.num_credito = a.num_credito
              AND b.status_cred = "BT"
	      AND mto_venc_trasp <= 0
	      AND cap_tras_no_venci > 0


	UPDATE sd_maecred SET status_cred = "AA"
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_maesdos SET sdo_capital = Capital,
			      mto_venc_trasp = 0,
			      cap_tras_no_venci = 0
         WHERE num_credito = NumCred
           AND empresa = eEmpresa;

	UPDATE sd_amortiza_credito
	   SET capital_status = 1
         WHERE num_credito = NumCred
           AND empresa = eEmpresa
	   AND capital_status IN ("2","7");

   END FOREACH

   -- Caso 8 Desprovision de intereses a creditos con saldos negativos
   FOREACH SELECT a.num_credito,
                 (SELECT SUM(iva_debe - iva_pagado)
		    FROM sd_amortiza_credito b
		   WHERE b.empresa = eEmpresa
		     AND b.num_credito = a.num_credito),
		  sdo_no_exig, sucursal
	     INTO NumCred, Insoluto, Capital, vSucursal
	     FROM sd_maesdos a, sd_maecred b
	    WHERE a.empresa = eEmpresa
	      AND sdo_capital < 0
	      AND b.empresa = a.empresa
	      AND b.num_credito = a.num_credito


                IF Insoluto > 0 THEN  -- Desprovision de Iva
                   CALL GenMov("001", NumCred,"6001", 2,
                               "005", FechaHoy, Insoluto,
                               "correcion3108007", vSucursal, "01", "0000")
                   RETURNING CodRet, Mensaje;

		   UPDATE sd_amortiza_credito
		      SET iva_pagado = 0,
			  iva_debe   = 0
		    WHERE empresa = eEmpresa
		      AND num_credito = NumCred;

		END IF

		IF Capital > 0 THEN
                   CALL GenMov("001", NumCred,"6001", 1,
                               "005", FechaHoy, Capital,
                               "correcion3108007", vSucursal, "01", "0000")
                   RETURNING CodRet, Mensaje;

		   UPDATE sd_maesdos SET sdo_no_exig = 0
		    WHERE empresa = eEmpresa
		      AND num_credito = NumCred;

		END IF


   END FOREACH


RETURN CodRet;

END PROCEDURE
;