CREATE PROCEDURE "informix".bonif_int(eEmpresa CHAR(3))
RETURNING CHAR(5);


DEFINE vCred      CHAR(20);
DEFINE vFecha     DATE;
DEFINE vMinimo    DECIMAL(14,2);
DEFINE vMonto     DECIMAL(14,2);
DEFINE vVencido   DECIMAL(14,2);
DEFINE sql_err    SMALLINT;
DEFINE isam_err   SMALLINT;
DEFINE error_info CHAR(40);
DEFINE cod_ret    CHAR(5);
DEFINE vDebe      DECIMAL(14,2);
DEFINE vPagado    DECIMAL(14,2);
DEFINE vFecha2    DATE;
DEFINE vFechaHoy  DATE;
DEFINE vDebe2     DECIMAL(14,2);
DEFINE vPagado2   DECIMAL(14,2);
DEFINE vValor     DECIMAL(14,2);
DEFINE vVigente   DECIMAL(14,2);
DEFINE vStatus    CHAR(1);
DEFINE vStatusCred   CHAR(2);
DEFINE vCuantos   SMALLINT;


-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      ROLLBACK WORK;
      RETURN cod_ret;
   END EXCEPTION;

--  set debug file to "bonif_int.out";
--  trace on;

-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret    = "000";
LET vCred   = "?";
LET vFecha  = NULL ;
LET vMinimo = 0;
LET vMonto  = 0;
LET vVencido  = 0;
LET vCuantos = 0;

SELECT fecha_hoy INTO vFechaHoy FROM sd_fechas;

UPDATE sd_maecred SET cod_caract = NULL WHERE 1=1;

FOREACH WITH HOLD 
           SELECT a.num_credito, sdo_cap_insoluto, sdo_trab4   
	     INTO vCred, vMonto, vVencido
          FROM sd_maecred a, sd_maesdoshist b
         WHERE a.empresa = eEmpresa
           AND a.fecha_apertura <= "12/20/2007"
           AND a.status_cred = "AA"
           AND a.cod_caract IS NULL
           AND b.fecha = "12/20/2007"
           AND b.empresa = a.empresa
           AND b.num_credito = a.num_credIto
           AND b.sdo_cap_insoluto <= ( SELECT SUM(monto) from sd_bonint c
   				        WHERE c.num_credito = a.num_credito
 					  AND c.codigo_fun IN ("033","334","005")
 					  AND c.codigo_ref IN (7,8,10,901,1,2)
           				  AND c.fecha_mov BETWEEN "12/21/2007" 
							    AND "01/20/2008"
           				  AND c.reversado = "N")
	  AND exists (SELECT * FROM sd_bonint d
             	       WHERE num_credito = a.num_credito
               		 AND codigo_fun ="605"
               		 AND codigo_ref = 3
               	         AND fecha_mov = "01/20/2008"
               		 AND reversado = "N")

	BEGIN WORK;

	SELECT COUNT(*) INTO vCuantos 
	  FROM sd_movhis
	 WHERE  empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = "005"
           AND codigo_ref = 1
           AND fecha_mov = "02/20/2008"
           AND reversado = "N";

	IF vCuantos > 1 THEN
		DELETE FROM sd_movhis
	         WHERE  empresa = "001"
                   AND num_credito = vCred
                   AND codigo_fun = "005"
                   AND codigo_ref IN (1,2,50,51)
                   AND fecha_mov = "02/20/2008"
                   AND reversado = "N";
	ELSE
		COMMIT WORK;
		CONTINUE FOREACH;
	END IF



	SELECT SUM(monto) INTO vMonto
	  FROM sd_bonint  
         WHERE num_credito = vCred
           AND codigo_fun ="605"
           AND codigo_ref IN (3, 2)
           AND fecha_mov = "01/20/2008"
           AND reversado = "N";


	UPDATE sd_maesdos 
	   SET sdo_capital = sdo_capital + vMonto,
	       sdo_cap_insoluto = sdo_cap_insoluto + vMonto,
	       monto_financiado = monto_financiado + vMonto,
	       sdo_trab4 = sdo_trab4 + vMonto
	 WHERE num_credito = vCred
	   AND empresa = eEmpresa;

	UPDATE sd_maesdoshist 
	   SET sdo_trab4 = sdo_trab4 + vMonto,
	       monto_financiado = monto_financiado + vMonto
	 WHERE fecha = "01/20/2008" 
	   AND   num_credito = vCred
	   AND empresa = eEmpresa;

	INSERT INTO sd_movhis
		(empresa, secuencia, fecha_mov, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
		 codigo_fun, codigo_ref, divisa, reversado, folio_suc,
		 num_producto, nro_tarjeta, referencia, tipo_cambio,
	 	 monto_dls, suc_origen, rfc_comer, referencia23)
	 SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 "005", 50, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23
	   FROM sd_bonint
	  WHERE num_credito = vCred
	    AND codigo_fun = "605"
	    AND codigo_ref = 2
	    AND fecha_mov = "01/20/2008"
	    AND reversado = "N";


        INSERT INTO sd_movhis
                (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23)
         SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 "005", 1, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23
           FROM sd_bonint
          WHERE num_credito = vCred
            AND codigo_fun = "605"
            AND codigo_ref = 2
            AND fecha_mov = "01/20/2008"
            AND reversado = "N";

        INSERT INTO sd_movhis
                (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23)
         SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 "005", 51, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23
           FROM sd_bonint
          WHERE num_credito = vCred
            AND codigo_fun = "605"
            AND codigo_ref = 3
            AND fecha_mov = "01/20/2008"
            AND reversado = "N";

        INSERT INTO sd_movhis
                (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23)
         SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                 num_credito, plaza, transacc_suc, usuario, monto,
                 "005", 2, divisa, reversado, folio_suc,
                 num_producto, nro_tarjeta, referencia, tipo_cambio,
                 monto_dls, suc_origen, rfc_comer, referencia23
           FROM sd_bonint
          WHERE num_credito = vCred
            AND codigo_fun = "605"
            AND codigo_ref = 3
            AND fecha_mov = "01/20/2008"
            AND reversado = "N";



	UPDATE sd_maecred SET cod_caract = "Y"
	 WHERE num_credito = vCred
	   AND empresa = eEmpresa;

	COMMIT WORK;

END FOREACH



--DROP TABLE sd_movhis20;

RETURN cod_ret;

END PROCEDURE
;