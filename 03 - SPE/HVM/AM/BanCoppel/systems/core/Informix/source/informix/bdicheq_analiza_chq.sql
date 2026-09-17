CREATE PROCEDURE "informix".analiza_chq(eEmpresa CHAR(3))

   RETURNING CHAR(5), INTEGER;


   DEFINE vCuenta       CHAR(20);
   DEFINE vActual       MONEY(14,2);
   DEFINE vRetenido     MONEY(14,2);
   DEFINE vTran         CHAR(4);
   DEFINE vFecha        DATE;
   DEFINE vMonto        MONEY(14,2);
   DEFINE vNat          CHAR(1);
   DEFINE vTipo         CHAR(2);
   DEFINE vActualCalc   MONEY(14,2);
   DEFINE vRetenidoCalc MONEY(14,2);
   DEFINE vExiste       SMALLINT;
   DEFINE CodRet        CHAR(5);
   DEFINE sql_err       SMALLINT;
   DEFINE isam_err      SMALLINT;
   DEFINE error_info    CHAR(40);
   DEFINE vCuantas      INTEGER;


   ON EXCEPTION SET sql_err, isam_err, error_info
      LET CodRet = sql_err;
      RETURN CodRet, vCuantas;
   END EXCEPTION;
   

   LET vActual = 0;
   LET vRetenido = 0;
   LET vActualCalc = 0;
   LET vRetenidoCalc = 0;
   LET vCuantas      = 0;
   LET CodRet        = "000";

   -- SET DEBUG FILE TO "analiza_chq.out";
   -- TRACE ON;

   TRUNCATE TABLE "informix".analiza;

   FOREACH 
      SELECT {+ INDEX(sc_maechq idx_maechq1)}
             cuenta, sdo_actual, sdo_retenido
        INTO vCuenta, vActual, vRetenido
	FROM sc_maechq
       WHERE empresa = eEmpresa
         AND cuenta is not null
         AND status_cta <> "2"

      LET vActualCalc = 0;
      LET vRetenidoCalc = 0;

      FOREACH 
         SELECT transacc, fech_alt, monto_tot, naturaleza, tipo_tran
	   INTO vTran, vFecha, vMonto, vNat, vTipo
	   FROM sc_movdia a, bdinteg:si_transacc b
	  WHERE a.empresa = eEmpresa
	    AND a.cuenta = vCuenta
	    AND a.cancelad <> "S"
	    AND b.sistema = "01"
	    AND b.numero = a.transacc
	    AND b.empresa = a.empresa
	    AND b.naturaleza <> "R"
         UNION ALL
         SELECT transacc, fech_alt, monto_tot, naturaleza, tipo_tran
           FROM sc_movhis a, bdinteg:si_transacc b
          WHERE a.empresa = eEmpresa
            AND a.cuenta = vCuenta
            AND a.cancelad <> "S"
            AND b.sistema = "01"
            AND b.numero = a.transacc
            AND b.empresa = a.empresa
            AND b.naturaleza <> "R"

         IF vTipo BETWEEN "20" AND "29" THEN

	    IF vNat = "A" THEN
	       LET vActualCalc = vActualCalc + vMonto;
	       LET vRetenidoCalc = vRetenidoCalc + vMonto;
	    ELSE
	       LET vRetenidoCalc = vRetenidoCalc + vMonto;
	    END IF

	 ELIF vTipo BETWEEN "30" AND "39" THEN

	    IF vNat = "A" THEN
	       LET vRetenidoCalc = vRetenidoCalc - vMonto;
	    ELSE
	       LET vActualCalc = vActualCalc - vMonto;
	       LET vRetenidoCalc = vRetenidoCalc - vMonto;
	    END IF

	 ELIF vTipo NOT IN ("11") THEN

	    IF vNat = "A" THEN
	       LET vActualCalc = vActualCalc + vMonto;
	    ELSE
	       LET vActualCalc = vActualCalc - vMonto;
	    END IF

	 END IF

      END FOREACH


      { ***************************************

	SELECT COUNT(*) INTO vExiste
	  FROM analiza
	 WHERE cuenta = vCuenta;
	IF vExiste IS NULL OR vExiste = 0 THEN

      **************************************** }


      IF vActual <> vActualCalc OR
         vRetenido <> vRetenidoCalc THEN

         INSERT INTO "informix".analiza VALUES
	 (vCuenta, vActual, vActualCalc, vRetenido, vRetenidoCalc);

         LET vCuantas = vCuantas + 1;

      END IF


      { ******************************************

	ELSE
		UPDATE analiza
		   SET actual = vActual,
		       actcalc = vActualCalc,
		       retenido = vRetenido,
		       retcalc = vRetenidoCalc
		 WHERE cuenta = vCuenta;
	END IF

      ******************************************* }

   END FOREACH

   RETURN CodRet, vCuantas;

END PROCEDURE;