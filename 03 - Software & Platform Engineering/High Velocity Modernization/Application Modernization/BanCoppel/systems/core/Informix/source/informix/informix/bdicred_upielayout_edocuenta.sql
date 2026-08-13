CREATE PROCEDURE "informix".upielayout_edocuenta (
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)

RETURNING CHAR(5);

DEFINE cod_ret             char(5);
DEFINE sql_err             integer;

DEFINE v_tasa_mensual      char(20);
DEFINE v_tasa_anual        char(20);
DEFINE v_cat               char(20);
DEFINE v_saldo_promedio    decimal(18,2);
DEFINE v_mas_intereses     decimal(14,2);
DEFINE v_dias_trans        char(20);

DEFINE v_tasa_interes	   decimal(9,3);
DEFINE v_sdo_acum_mes_cap  decimal(18,2);
DEFINE v_dias_acum_cap     decimal(18,2);

--INICIALIZACION

LET v_tasa_mensual     = "";
LET v_tasa_anual       = "";
LET v_cat              = "";
LET v_saldo_promedio   = 0;
LET v_mas_intereses = 0;
LET v_dias_trans       = "";

LET v_tasa_interes     = 0;
LET v_sdo_acum_mes_cap = 0;
LET v_dias_acum_cap    = 0;


--INICIA PL

-- --SET DEBUG FILE TO "pieestadocuenta.out";
-- --TRACE ON;


BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    --------------------------------------------------------
    --	OBTIENE LA TASA DE INTERES
    --------------------------------------------------------
	SELECT tasa_interes
		INTO v_tasa_interes
	FROM sd_maecred
		WHERE num_credito = pnum_credito
		AND empresa = pempresa;
    --------------------------------------------------------
    --	OBTIENE SALDO ACUMULADO DEL MES Y LOS DIAS
    --------------------------------------------------------
	SELECT   sdo_acum_mes_cap,dias_acum_cap
		INTO v_sdo_acum_mes_cap,v_dias_acum_cap
	FROM   sd_maesdoshist
		WHERE   fecha = pfechahoy
		AND empresa = pempresa
		AND num_credito = pnum_credito;

	LET v_tasa_anual   = v_tasa_interes;
	LET v_tasa_mensual = v_tasa_interes / 12;
    --------------------------------------------------------
    --	OBTIENE EL VALOR DEL CAT
    --------------------------------------------------------
	SELECT valor
		INTO v_cat
	FROM sd_param
		WHERE empresa = pempresa
		AND cod_param = '034';

	IF v_cat IS NULL THEN
		LET v_cat = 69.58;
	END IF
    --------------------------------------------------------
    --	CALCULA EL SALDO PROMEDIO
    --------------------------------------------------------
    SELECT  mas_intereses
    INTO v_mas_intereses
    FROM sd_encabezado2_edocta
    WHERE fecha_emision = pfechahoy
	AND num_credito = pnum_credito;


	IF v_dias_acum_cap > 0 THEN
		--LET v_saldo_promedio = ((v_mas_intereses * 36000) / 54) / 31;
		LET  v_saldo_promedio = (v_sdo_acum_mes_cap / v_dias_acum_cap);
	ELSE
		LET v_saldo_promedio = 0;
	END IF;

	LET v_dias_trans = '31';
    --------------------------------------------------------
    --	GENERA EL PIE DEL ESTADO DE CUENTA
    --------------------------------------------------------
	INSERT INTO sd_pie_edocta
			(
			fecha_emision,num_credito,tasa_mensual,
			tasa_anual,cat,saldo_promedio,
			dias_periodo
			)
	VALUES
			(
			pfechahoy,pnum_credito,v_tasa_mensual,
			v_tasa_anual,v_cat,v_saldo_promedio,
			v_dias_trans
			);

  END;

  RETURN cod_ret;

END PROCEDURE DOCUMENT "Version 1.00.000";

CREATE PROCEDURE "informix".intnov()
RETURNING CHAR(5), CHAR(20);


DEFINE CodRet     CHAR(5);
DEFINE sql_err    SMALLINT;
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE vCred      CHAR(20);
DEFINE vInsoluto  DECIMAL(14,2);
DEFINE vCapital   DECIMAL(14,2);
DEFINE vHInsoluto DECIMAL(14,2);
DEFINE vHCapital  DECIMAL(14,2);
DEFINE vMonto     DECIMAL(14,2);
DEFINE vMinimo    DECIMAL(14,2);


 -- **************************************************************************
 -- *                      CONTROL DE ERRORES                                *
 -- **************************************************************************
 ON EXCEPTION SET sql_err, isam_err, error_info
    LET CodRet = sql_err;
    RETURN CodRet, vCred;
 END EXCEPTION WITH RESUME;

LET vCred = "?????????????";
LET CodRet = "000";
  -- ***********************************************************************
  -- Arregla Creditos que fueron desprovisionados teniendo que capitalizar *
  -- ***********************************************************************
  FOREACH WITH HOLD
	SELECT a.num_credito, b.sdo_cap_insoluto, b.sdo_capital,
	       c.sdo_cap_insoluto, c.sdo_capital
	  INTO vCred, vInsoluto, vCapital, vHInsoluto, vHCapital
	  FROM intnov a, sd_maesdos b, sd_maesdoshist c
	 WHERE marca = 1
	   AND procesado = 0
	   AND b.num_credito = a.num_credito
	   AND b.empresa = "001"
	   AND c.fecha = "11/20/2007"
	   AND c.empresa = b.empresa
	   AND c.num_credito = b.num_credito

	BEGIN WORK;

	SELECT SUM(monto) INTO vMonto
	  FROM sd_movhis
	 WHERE empresa ="001"
	   AND num_credito = vCred
	   AND codigo_fun = "005"
	   AND codigo_ref IN (1,2)
	   AND fecha_mov = "11/20/2007"
	   AND reversado = "N";

	IF vMonto IS NULL THEN
		LET vMonto = 0;
                UPDATE intnov
                   SET procesado = 1
                 WHERE num_credito = vCred;
		COMMIT WORK;
		CONTINUE FOREACH;
	END IF

	LET vMinimo = vHInsoluto + vMonto;
	LET vMinimo = ROUND((vMinimo / 10),-0);

	UPDATE sd_maesdos
	   SET sdo_cap_insoluto = vInsoluto + vMonto,
	       sdo_capital = vCapital + vMonto,
	       monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE num_credito = vCred
	   AND empresa = "001";

	UPDATE sd_maesdoshist
	   SET sdo_cap_insoluto = vHInsoluto + vMonto,
	       sdo_capital = vHCapital + vMonto,
	       monto_financiado = vMinimo,
	       sdo_trab4 = vMinimo
	 WHERE fecha = "11/20/2007"
	   AND empresa = "001"
	   AND num_credito = vCred;

	INSERT INTO sd_movhis
	SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
	       transacc_suc,usuario,monto,"605",2,divisa,reversado,
	       folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
	       suc_origen,rfc_comer,referencia23
	  FROM sd_movhis
	 WHERE empresa = "001"
	   AND num_credito = vCred
	   AND codigo_fun = "005"
	   AND codigo_ref = 1
	   AND fecha_mov = "11/20/2007"
	   AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,monto,"605",3,divisa,reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "005"
           AND codigo_ref = 2
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,(monto * -1),codigo_fun,codigo_ref,divisa,
               reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "005"
           AND codigo_ref = 1
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,(monto * -1),codigo_fun,codigo_ref,divisa,
               reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "005"
           AND codigo_ref = 2
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";



	{UPDATE sd_movhis
	   SET reversado = "S"
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "005"
           AND codigo_ref IN (1,2)
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";}

	  UPDATE intnov
	     SET procesado = 1
	   WHERE num_credito = vCred;

	COMMIT WORK;

  END FOREACH


  -- *******************************************
  -- Arregla Creditos que fueron Capitalizados *
  -- *******************************************
  FOREACH WITH HOLD
        SELECT a.num_credito, b.sdo_cap_insoluto, b.sdo_capital,
               c.sdo_cap_insoluto, c.sdo_capital
          INTO vCred, vInsoluto, vCapital, vHInsoluto, vHCapital
          FROM intnov a, sd_maesdos b, sd_maesdoshist c
         WHERE marca = 2
	   AND procesado = 0
           AND b.num_credito = a.num_credito
           AND b.empresa = "001"
           AND c.fecha = "11/20/2007"
           AND c.empresa = b.empresa
           AND c.num_credito = b.num_credito

        BEGIN WORK;

        SELECT SUM(monto) INTO vMonto
          FROM sd_movhis
         WHERE empresa ="001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref IN (2,3)
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        IF vMonto IS NULL THEN
                LET vMonto = 0;
                UPDATE intnov
                   SET procesado = 1
                 WHERE num_credito = vCred;
                COMMIT WORK;
                CONTINUE FOREACH;
        END IF

        LET vMinimo = vHInsoluto - vMonto;
        LET vMinimo = ROUND((vMinimo / 10),-0);

        UPDATE sd_maesdos
           SET sdo_cap_insoluto = vInsoluto - vMonto,
               sdo_capital = vCapital - vMonto,
               monto_financiado = vMinimo,
               sdo_trab4 = vMinimo
         WHERE num_credito = vCred
           AND empresa = "001";

        UPDATE sd_maesdoshist
           SET sdo_cap_insoluto = vHInsoluto - vMonto,
               sdo_capital = vHCapital - vMonto,
               monto_financiado = vMinimo,
               sdo_trab4 = vMinimo
         WHERE fecha = "11/20/2007"
           AND empresa = "001"
           AND num_credito = vCred;

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,monto,"005",1,divisa,reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref = 2
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,monto,"005",2,divisa,reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,2011,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref = 3
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,(monto * -1),codigo_fun,codigo_ref,divisa,
               reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,
               2011.10,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref = 2
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        INSERT INTO sd_movhis
        SELECT empresa,0,fecha_mov,hora_mov,sucursal,num_credito,plaza,
               transacc_suc,usuario,(monto * -1),codigo_fun,codigo_ref,divisa,
               reversado,
               folio_suc,num_producto,nro_tarjeta,referencia,tipo_cambio,
               2011.10,
               suc_origen,rfc_comer,referencia23
          FROM sd_movhis
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref = 3
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

        UPDATE sd_movhis
           SET reversado = "S"
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "605"
           AND codigo_ref IN (2,3)
           AND fecha_mov = "11/20/2007"
           AND reversado = "N";

          UPDATE intnov
             SET procesado = 1
           WHERE num_credito = vCred;


        COMMIT WORK;

  END FOREACH





END PROCEDURE
;