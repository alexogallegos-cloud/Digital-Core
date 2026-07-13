CREATE PROCEDURE "informix".ajusteprovision()

RETURNING CHAR(5);


DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(40);
DEFINE cod_ret      CHAR(5);
DEFINE vFecha       DATE;
DEFINE vCuenta      CHAR(20);
DEFINE vInteres     DECIMAL(14,2);
DEFINE vProvision   DECIMAL(14,2);
DEFINE vAlta        DATE;
DEFINE vgusuario    CHAR(8);
DEFINE vgsucursal   CHAR(4);
DEFINE vgproducto   CHAR(4);
DEFINE vgstatus_cta CHAR(1);
DEFINE vgsdo_actual DECIMAL(14,2);
DEFINE vBegin       CHAR(1);
DEFINE vhora        DATETIME HOUR TO FRACTION;
DEFINE vhoraw       CHAR(15);
DEFINE vfolio_suc   CHAR(16);
-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      IF vBegin = "S" THEN
         ROLLBACK WORK;
      END IF
      RETURN cod_ret;
   END EXCEPTION;

--    set debug file to "ajusteprovision.out";
--    trace on;
-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret    = "000";
LET vBegin     = "N";
LET vgusuario  = "informix";
SELECT fecha_hoy INTO vFecha FROM sc_fechas;

-- **************************************************************************
-- *                      PROGRAMA PRINCIPAL                                *
-- **************************************************************************

FOREACH WITH HOLD     
       SELECT a.cuenta, ROUND((ROUND((acum_pos / dias_pos),2) * .04) /360,2),
              b.fecha_alta, c.sucursal, c.producto, status_cta, sdo_actual
	 INTO vCuenta, vInteres, vAlta, vgsucursal, vgproducto, vgstatus_cta,
	      vgsdo_actual
         FROM bdicheq:sc_Salpro a, sc_maenoc b, sc_maechq c
        WHERE a.fecha = TO_DATE("2008-03","%Y-%m")
          AND b.empresa = "001"
          AND b.cuenta = a.cuenta
          AND c.empresa = b.empresa
          AND c.cuenta = b.cuenta
          AND c.status_cta ="1"
          AND ROUND((ROUND((acum_pos / dias_pos),2) * .04) /360,2) > 0
--and a.cuenta ="1410070476"

	BEGIN WORK;
	LET vBegin ="S";

        LET vhora = current hour to fraction;
        LET vhoraw = vhora;
        LET vhoraw = vhoraw[1,2]||vhoraw[4,5]||vhoraw[7,8]||vhoraw[10,11];
        LET vfolio_suc = vgusuario||vhoraw[1,8];


	IF DAY(vFecha) <= DAY(vAlta) THEN
		LET vInteres = vInteres * (DAY(vFecha) - 1);
		UPDATE sc_maenoc
		   SET acum_sdo_int = acum_sdo_int + vInteres
		 WHERE empresa ="001"
		   AND cuenta = vCuenta;

	ELSE

	   LET vProvision = vInteres * DAY(vAlta);
	   INSERT INTO sc_movdia
           VALUES (0,vfolio_suc,vgsucursal,vgusuario,vFecha,
                  vFecha,vhora,"3381",vgsucursal,vgproducto,"001",
                  vCuenta, "",0,vProvision,vProvision,0,0,0,"",
		  vgstatus_cta, vgsdo_actual,"0000"," ",4,"","","");

            INSERT INTO sc_movdia
               VALUES (0,vfolio_suc,vgsucursal,vgusuario,vFecha,
                       vFecha,vhora,"3276",vgsucursal,vgproducto,
                       "001",vCuenta, "",0,vProvision,vProvision,0,0,0,"","1",
                       vgsdo_actual,"0000"," ",4,"","","");

            UPDATE sc_maechq
               SET (fec_ult_mov,num_abonos_mes,imp_abonos_mes,sdo_actual,
                    ultpagoint) =
                   (vFecha,num_abonos_mes + 1,
		    imp_abonos_mes + (vProvision),
                    sdo_actual + (vProvision), vFecha)
               WHERE empresa = "001" AND cuenta = vCuenta;


	    LET vInteres = vInteres * ((DAY(vFecha)- DAY(vAlta)) - 1);
            UPDATE sc_maenoc
               SET acum_sdo_int = acum_sdo_int + vInteres
             WHERE empresa ="001"
               AND cuenta = vCuenta;

	END IF

	COMMIT WORK;
	LET vBegin = "N";



END FOREACH

RETURN cod_ret;

END PROCEDURE
;