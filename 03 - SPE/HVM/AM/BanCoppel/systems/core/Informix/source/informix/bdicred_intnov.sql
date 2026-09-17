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