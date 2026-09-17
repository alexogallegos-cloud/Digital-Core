CREATE PROCEDURE "informix".edocuenta(e_empresa CHAR(3),
				     e_fechainicio DATE,
				     e_fechafin DATE)
RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_existe     CHAR(1);
DEFINE v_finmes     DATE;
DEFINE v_fechamae   DATE;
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET v_existe     = " ";
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;

      SELECT NVL(status_proc,"X") INTO v_existe
        FROM sd_contproc
       WHERE proceso ="EDO_CTA"
	 AND fecha = e_fechafin;
      IF v_existe ="X" THEN
        INSERT INTO SD_CONTPROC
             (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
              HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
        VALUES (e_empresa, 'EDO_CTA', e_fechafin, 'C', USER, CURRENT,
             CURRENT, scod_ret, ' ');
      ELSE
	DELETE FROM sd_contproc
	 WHERE proceso ="EDO_CTA"
	   AND fecha = e_fechafin;
      END IF
      RETURN scod_ret;
   END IF;
END EXCEPTION;



-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

   /* Borra las tablas */

   DELETE FROM axcred:sd_maesdos;
   DELETE FROM axcred:sd_maecred;
   DELETE FROM axcred:sd_movdia;


	-- Valida Fechas
	SELECT ult_hab_mes INTO v_finmes
	  FROM sd_fechas;

	IF v_finmes <> e_fechafin THEN
		SELECT MAX(fecha) INTO v_fechamae
		  FROM sd_maesdostc;
	ELSE
		LET v_fechamae = e_fechafin;
	END IF


	-- INSERTA EL MAESTRO DE SALDOS AL DIA PARA TC
        INSERT INTO
           axcred:sd_maesdos
        SELECT empresa, num_credito, fecha_ult_mov, sdo_int_anticip,
           sdo_int_ant_dev, sdo_intereses, sdo_dia_ant_int, sdo_mes_ant_int,
           sdo_acum_mes_int, favp, sdo_acum_cap_int, sdo_exig_int, sdo_no_exig,
           provision_normal, dias_acum_int, sdo_moratorio, sdo_dia_ant_mor,
           sdo_mes_ant_mor, sdo_contab_mora, dias_acum_mora, sdo_capital,
           sdo_cap_insoluto, sdo_dia_ant_cap, sdo_mes_ant_cap, sdo_acum_mes_cap,
           mto_capitalizado, mto_ministra_cap, cargos_dia_cap, abonos_dia_cap,
           cargos_mes_cap, abonos_mes_cap, dias_acum_cap, monto_vencido,
	   mto_venc_trasp, monto_financiado, monto_reservado, sdo_acum_vencido,
           dias_acum_intper, sdo_global_int, sdo_acum_intper, monto_otorgado,
           provi_venc_normal, provi_venc_anticip, cap_tras_no_venci,
           mto_venc_int, mto_venc_tra_int, mto_finan_vdo, mto_reser_int,
           mto_fin_ven_trasp, mto_fin_vig_trasp, int_tra_no_exig, sdo_trab4
        from bdicred:sd_maesdostc
        where empresa = e_empresa
        AND fecha = v_fechamae;

	-- INSERTA EL MAESTRO DE CREDITO PARA TC
        INSERT INTO
           axcred:sd_maecred
        SELECT * FROM bdicred:sd_maecred WHERE num_producto = '410';


	INSERT INTO axcred:sd_movdia
	SELECT * FROM sd_movdia
	 WHERE num_producto = "410"
	   AND fecha_mov >= e_fechainicio
	   AND fecha_mov <= e_fechafin;



      SELECT NVL(status_proc,"X") INTO v_existe
        FROM sd_contproc
       WHERE proceso ="EDO_CTA"
         AND fecha = e_fechafin;
      IF v_existe <> "X" THEN
        DELETE FROM sd_contproc
         WHERE proceso ="EDO_CTA"
           AND fecha = e_fechafin;
      END IF

        INSERT INTO SD_CONTPROC
             (EMPRESA, PROCESO, FECHA, STATUS_PROC, EJECUTIVO,
              HORA_INICIO, HORA_FIN, COD_RET, MENSAJE)
        VALUES (e_empresa, 'EDO_CTA', e_fechafin, 'F', USER, CURRENT,
             CURRENT, '000', ' ');



END
	RETURN scod_ret;
END PROCEDURE;