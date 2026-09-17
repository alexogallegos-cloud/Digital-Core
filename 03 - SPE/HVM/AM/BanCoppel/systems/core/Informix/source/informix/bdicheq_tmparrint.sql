CREATE PROCEDURE "informix".tmparrint()
RETURNING CHAR(5);

--//Definicion de variables
   DEFINE vcodret      CHAR(5);
   DEFINE vsqlerr      INTEGER;
   DEFINE v_cuenta     CHAR(20);
   DEFINE v_diferencia DECIMAL(14,2);

   LET vcodret      = "000";
   LET v_diferencia = 0;

   BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;


-- set debug file to "tmparrint.out";
-- trace on;


   --// **********************
   --// FOREACH PRINCIPAL
   --// **********************

   FOREACH
       SELECT cuenta, diferencia
         INTO v_cuenta, v_diferencia
         FROM dif_provision_16122008
         WHERE cuenta in(
"11000013082",
"11000013562",
"11000012922",
"11000013058",
"11000013198",
"11000013490",
"11000013180",
"11000013287",
"11000013511",
"11000013139",
"11000013333",
"11000013473",
"11000013104",
"11000013252",
"11000013260",
"11000013309",
"11000013376",
"18000079959",
"18000079967")


       IF v_diferencia > 0 THEN
          UPDATE sc_maechq
             SET sdo_actual = sdo_actual + v_diferencia,
                 sdo_dia_ant = sdo_dia_ant + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta;

          UPDATE sc_maenoc
             SET acum_sdo_pos = acum_sdo_pos + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta;

          UPDATE sc_maehis
             SET sdo_actual = sdo_actual + v_diferencia,
                 totintpag  = totintpag  + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta
            AND fechafin = "12162008";

          UPDATE sc_movhis
             SET monto_tot = monto_tot + v_diferencia,
                 firme = firme + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta
            AND fech_alt = "12162008"
            AND transacc in("3381", "3276");
      ELSE
          LET v_diferencia = v_diferencia * -1;
          UPDATE sc_maechq
             SET sdo_actual = sdo_actual + v_diferencia,
                 sdo_dia_ant = sdo_dia_ant + v_diferencia

          WHERE empresa = "001"
            AND cuenta = v_cuenta;

          UPDATE sc_maenoc
             SET acum_sdo_pos = acum_sdo_pos + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta;

          UPDATE sc_maehis
             SET sdo_actual = sdo_actual + v_diferencia,
                 totintpag  = totintpag  + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta
            AND fechafin = "12162008";

          UPDATE sc_movhis
             SET monto_tot = monto_tot + v_diferencia,
                 firme = firme + v_diferencia
          WHERE empresa = "001"
            AND cuenta = v_cuenta
            AND fech_alt = "12162008"
            AND transacc in("3381", "3276");
      END IF;

   END FOREACH;

   END
   RETURN vcodret;
END PROCEDURE;