CREATE PROCEDURE "informix".cierre_mensual(pempresa char(3),pfecha_hoy date)
RETURNING CHAR(5);

   DEFINE cod_reti char(5);
   DEFINE cod_ret char(5);
   DEFINE cod_ins CHAR(5);
   DEFINE GLOBAL v_hora_inicio CHAR(12) DEFAULT "";
   DEFINE GLOBAL v_hora_fin    CHAR(12) DEFAULT "";

   --SET DEBUG FILE TO '/tmp/cierre_mensual.out';
   --TRACE ON;

   LET cod_ret = "000";
   
BEGIN WORK;   

   -- Pasa el detalle de las polizas de co_diario a co_mensual o a co_historico
   -- segun sea la fecha valida de cada asiento.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_mens(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   ROLLBACK WORK;

	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_MENS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre_notran(pempresa,pfecha_hoy,
	                           "ACT_MENS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Todas las cuentas contables que estan en el co_diario se checan contra el
   -- catalogo contable para obtener su naturaleza y si no existen en co_sdodias
   -- se agregan con saldos en 0; lo mismo para co_diasaux.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_sdodias(pempresa,pfecha_hoy) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   ROLLBACK WORK;

	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_SDODIAS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre_notran(pempresa,pfecha_hoy,
	                           "ACT_SDODIAS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Actualiza todas las tablas de saldos y movimientos dependiendo de la fecha
   -- a partir de co_diario y co_sdodias, checa si el movimiento es hacia cuentas
   -- de resultados y hacia ejercicio anterior para efectuar la cancelacion de
   -- resultados en forma automatica.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE cierre(pempresa,pfecha_hoy) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   ROLLBACK WORK;

	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "CIERRE",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre_notran(pempresa,pfecha_hoy,
	                           "CIERRE",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Genera registros en co_sdodias para el o los dias siguientes al dia que se
   -- esta cerrando, hasta el dia habil siguiente inclusive.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE sdo_dias(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   ROLLBACK WORK;

	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "SDO_DIAS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre_notran(pempresa,pfecha_hoy,
	                           "SDO_DIAS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Genera registros en co_diasaux para el o los dias siguientes al dia que se
   -- esta cerrando, hasta el dia habil siguiente inclusive.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE dias_aux(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   ROLLBACK WORK;

	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "DIAS_AUX",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre_notran(pempresa,pfecha_hoy,
	                           "DIAS_AUX",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

COMMIT WORK;

   -- Actualiza los saldos de la tabla co_sdomes en base a la tabla co_sdodias
   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_sdom(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_SDOM",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_SDOM",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Actualioza los saldos de la tabla co_sdomux en base a la tabla co_diasaux
   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_sdomux(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_SDOMUX",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_SDOMUX",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Actualiza la tabla historica de saldos co_histsdodias en base a la tabla
   -- co_sdodias.
   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_histsdos(pempresa,pfecha_hoy) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_HISTSDOS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_HISTSDOS",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

   -- Actualiza la tabla de movimientos historicos vaciando la tabla co_mensual a
   -- la tabla co_historico.

   LET v_hora_inicio = CURRENT HOUR TO FRACTION(3);
   EXECUTE PROCEDURE act_hist(pempresa) into cod_ret;
   LET v_hora_fin = CURRENT HOUR TO FRACTION(3);

   IF cod_ret NOT IN ('000','999') THEN
	   EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_HIST",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
	   RETURN cod_ret;
   ELSE 
		IF NOT cod_ret = '999' THEN
			EXECUTE PROCEDURE inserta_estatus_cierre(pempresa,pfecha_hoy,
	                           "ACT_HIST",
	                           "EFECTUADO",cod_ret,USER,0,
	                            v_hora_inicio,v_hora_fin) INTO cod_reti;
		ELSE
			   LET cod_ret = "000";
		END IF
   END IF

RETURN cod_ret;
END PROCEDURE;