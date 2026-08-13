CREATE PROCEDURE "informix".tmppagoint()
RETURNING CHAR(5);

--//Definicion de variables
   DEFINE vcodret      CHAR(5);
   DEFINE vsqlerr      INTEGER;
   DEFINE v_cuenta     CHAR(20);
   DEFINE vfecha_hoy   DATE;
   DEFINE v_interes    DECIMAL(14,2);
   DEFINE vhoraw       CHAR(15);
   DEFINE vhora        DATETIME HOUR TO FRACTION;
   DEFINE vsuc         char(4);
   DEFINE vprod        char(4);
   DEFINE vsdo         decimal(14,2);
   DEFINE vfolio_suc   CHAR(16);
   DEFINE vstatus      CHAR(1);

   LET vcodret      = "000";

   BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;


-- set debug file to "tmppagoint.out";
-- trace on;

   SELECT fecha_hoy INTO vfecha_hoy
     FROM sc_fechas;

   LET vhora = current hour to fraction;
   LET vhoraw = vhora;
   LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
   LET vfolio_suc = "informix" ||vhoraw[1,8];

   --// **********************
   --// FOREACH PRINCIPAL
   --// **********************

   FOREACH
       SELECT cuenta, interes, sucursal, producto, status_cta, saldo
         INTO v_cuenta, v_interes, vsuc, vprod, vstatus, vsdo
         FROM pago_int_02012009

       IF v_interes > 0 THEN
          UPDATE sc_maechq
             SET sdo_actual = sdo_actual + v_interes,
                 sdo_dia_ant = sdo_dia_ant + v_interes
          WHERE empresa = "001"
            AND cuenta = v_cuenta;

          UPDATE sc_maenoc
             SET acum_sdo_pos = acum_sdo_pos + (v_interes * dia_sdo_pos)
          WHERE empresa = "001"
            AND cuenta = v_cuenta;

         INSERT INTO sc_movdia
          VALUES (0,vfolio_suc,vsuc,"informix",vfecha_hoy,
                  vfecha_hoy,vhora,"3276",vsuc,vprod,"001",
                  v_cuenta, "",0,v_interes,v_interes,0,0,0,"",
		  vstatus, vsdo,"0000"," ",0,"","");
       END IF;

   END FOREACH;

   END
   RETURN vcodret;
END PROCEDURE;