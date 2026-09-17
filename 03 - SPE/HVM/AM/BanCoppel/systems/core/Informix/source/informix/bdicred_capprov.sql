CREATE PROCEDURE "informix".capprov(eEmpresa CHAR(3))
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
DEFINE vExiste    SMALLINT;
DEFINE vFun       CHAR(3);
DEFINE vRef       SMALLINT;
DEFINE vFunR      CHAR(3);
DEFINE vRefR      SMALLINT;
DEFINE vCap       DECIMAL(14,2);

-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      ROLLBACK WORK;
      RETURN cod_ret;
   END EXCEPTION;

--  set debug file to "capprov.out";
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

SELECT fecha_hoy INTO vFechaHoy FROM sd_fechas;

SELECT COUNT(*) INTO vExiste FROM systables WHERE tabname = "sd_movcapprov";
{
IF vExiste = 0 THEN
 create table sd_movcapprov
  (
    empresa char(3) not null ,
    secuencia serial not null ,
    fecha_mov date not null ,
    hora_mov datetime hour to fraction(3) not null ,
    sucursal char(4),
    num_credito char(20) not null ,
    plaza char(3) not null ,
    transacc_suc char(4) not null ,
    usuario char(8) not null ,
    monto decimal(18,2) not null ,
    codigo_fun char(3) not null ,
    codigo_ref integer not null ,
    divisa char(2) not null ,
    reversado char(1) not null ,
    folio_suc char(16) not null ,
    num_producto char(4) not null ,
    nro_tarjeta varchar(20,1),
    referencia varchar(40,1),
    tipo_cambio decimal(14,6),
    monto_dls decimal(14,2),
    suc_origen varchar(4,1),
    rfc_comer varchar(20,1),
    referencia23 varchar(23,1),
    primary key (fecha_mov,num_credito,sucursal,hora_mov,secuencia,empresa)
  );
 revoke all on sd_movcapprov from "public";


 create index "informix".capprov1e on "informix".sd_movcapprov
    (fecha_mov,monto,codigo_fun,codigo_ref) using btree ;
 create index "informix".capprov4e on "informix".sd_movcapprov
    (empresa,fecha_mov,num_credito,reversado) using btree ;
 create index "informix".capprov5e on "informix".sd_movcapprov
    (fecha_mov,codigo_fun,codigo_ref) using btree ;
 create index "informix".capprov6e on "informix".sd_movcapprov
    (codigo_fun,codigo_ref,folio_suc) using btree ;
 create index "informix".capprove on "informix".sd_movcapprov
    (empresa,num_credito,codigo_fun,codigo_ref,fecha_mov,reversado)
    using btree ;
END IF

INSERT INTO sd_movcapprov
select * from sd_movhis
where fecha_mov ="04202008"
and codigo_fun in ("606","605", "340")
and codigo_ref in (3,2,1,20,22);

update statistics medium for table sd_movcapprov;

UPDATE sd_movcapprov SET reversado ="S"
WHERE 1=1;
}
SELECT num_credito
  FROM sd_movhis
 WHERE fecha_mov = "04202008"
   AND codigo_fun = "606"
   AND codigo_ref = 1
  INTO TEMP prov;

SELECT  a.num_credito
  FROM  prov a
 WHERE NOT EXISTS (SELECT * FROM sd_movhis
		    WHERE empresa = "001"
		      AND num_credito = a.num_credito
		      AND fecha_mov = "04202008"
		      AND codigo_fun ="605"
		      AND codigo_ref = 2 )
INTO TEMP provi;


-- Genera Movimientos de Capitalizacion
FOREACH WITH HOLD
           SELECT a.num_credito, codigo_fun, codigo_ref, monto
	     INTO vCred, vFun, vRef, vMonto
          FROM sd_movcapprov  a, provi b
	 WHERE a.empresa = "001"
	   AND a.num_credito = b.num_credito
           AND fecha_mov ="04202008"
	   AND codigo_fun IN ("606", "340")
	   AND codigo_ref IN (1,20)
	   AND reversado = "S"



	BEGIN WORK;

	   UPDATE sd_maesdos
	      SET sdo_capital = sdo_capital + vMonto,
	          sdo_cap_insoluto = sdo_cap_insoluto + vMonto,
	          monto_financiado = monto_financiado + vMonto
	    WHERE num_credito = vCred
	      AND empresa = eEmpresa;

	   UPDATE sd_maesdoshist
	      SET sdo_capital = sdo_capital + vMonto,
	          sdo_cap_insoluto = sdo_cap_insoluto + vMonto,
	          monto_financiado = monto_financiado + vMonto
	    WHERE fecha = "04/20/2008"
	      AND  num_credito = vCred
	      AND empresa = eEmpresa;

	   INSERT INTO sd_movhis
	   	   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
		    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
		    num_producto, nro_tarjeta, referencia, tipo_cambio,
	 	    monto_dls, suc_origen, rfc_comer, referencia23)
	   SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto,
                  "605", DECODE(vRef, 1,2,20,3), divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
	     FROM sd_movcapprov
	    WHERE num_credito = vCred
	      AND codigo_fun = "606"
	      AND codigo_ref = vRef
	      AND fecha_mov = "04/20/2008"
	      AND reversado = "S";

           INSERT INTO sd_movcapprov
                   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
                    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                    num_producto, nro_tarjeta, referencia, tipo_cambio,
                    monto_dls, suc_origen, rfc_comer, referencia23)
           SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto,
                  "605", DECODE(vRef, 1,2,10,3), divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
             FROM sd_movcapprov
            WHERE num_credito = vCred
              AND codigo_fun = "606"
              AND codigo_ref = vref
              AND fecha_mov = "04/20/2008"
              AND reversado = "S";



	COMMIT WORK;

END FOREACH



SELECT num_credito
  FROM sd_movhis
 WHERE fecha_mov = "04202008"
   AND codigo_fun = "605"
   AND codigo_ref = 2
  INTO TEMP cap;

SELECT  a.num_credito
  FROM  cap a
 WHERE NOT EXISTS (SELECT * FROM sd_movhis
                    WHERE empresa = "001"
                      AND num_credito = a.num_credito
                      AND fecha_mov = "04202008"
                      AND codigo_fun ="606"
                      AND codigo_ref = 1
		      AND reversado = "N" )
INTO TEMP capital;



--Genera Movimientos de Provision
FOREACH WITH HOLD
           SELECT a.num_credito, codigo_fun, codigo_ref, monto
             INTO vCred, vFun, vRef, vMonto
          FROM sd_movcapprov  a, capital b
	 WHERE empresa ="001"
	   AND a.num_credito = b.num_credito
           AND fecha_mov ="04202008"
           AND codigo_fun IN ("605")
           AND codigo_ref IN (2,3)
	   AND reversado = "S"

        BEGIN WORK;

        SELECT COUNT(*) INTO vExiste
          FROM sd_movcapprov
         WHERE empresa = "001"
           AND num_credito = vCred
           AND codigo_fun = DECODE(vFun, "605","604","340","340")
           AND codigo_ref = DECODE(vRef, 2,2,22,20)
           AND fecha_mov = "04/20/2008"
           AND reversado = "S";

        IF vExiste > 0 THEN
           COMMIT WORK;
           CONTINUE FOREACH;
        END IF

	   IF vFun = "605" AND vRef = 2 THEN
	    LET vFunR = "604";
	    LET vRefR = 2;
	   ELSE
	    LET vFunR = "340";
	    LET vRefR = 22;
	   END IF

	   -- Movimientos de Reversion
           INSERT INTO sd_movhis
                   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
                    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                    num_producto, nro_tarjeta, referencia, tipo_cambio,
                    monto_dls, suc_origen, rfc_comer, referencia23)
           SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto * -1,
                  vFunR, vRefr, divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
             FROM sd_movcapprov
	    WHERE empresa ="001"
              AND num_credito = vCred
              AND codigo_fun = vFun
              AND codigo_ref = vRef
              AND fecha_mov = "04/20/2008"
              AND reversado = "S";

           INSERT INTO sd_movcapprov
                   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
                    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                    num_producto, nro_tarjeta, referencia, tipo_cambio,
                    monto_dls, suc_origen, rfc_comer, referencia23)
           SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto * -1,
                  vFunR , vRefR, divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
             FROM sd_movcapprov
            WHERE empresa ="001"
              AND num_credito = vCred
              AND codigo_fun = vFun
              AND codigo_ref = vRef
              AND fecha_mov = "04/20/2008"
              AND reversado = "S";
	   -- Termina Movimientos de Reversion

           INSERT INTO sd_movhis
                   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
                    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                    num_producto, nro_tarjeta, referencia, tipo_cambio,
                    monto_dls, suc_origen, rfc_comer, referencia23)
           SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto ,
                  DECODE(vFunR, "604","606","340","340"),
		  DECODE(vRefR, 2,1,22,20), divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
             FROM sd_movcapprov
            WHERE empresa ="001"
              AND num_credito = vCred
              AND codigo_fun = vFun
              AND codigo_ref = vRef
              AND fecha_mov = "04/20/2008"
              AND reversado = "S";


           INSERT INTO sd_movcapprov
                   (empresa, secuencia, fecha_mov, hora_mov, sucursal,
                    num_credito, plaza, transacc_suc, usuario, monto,
                    codigo_fun, codigo_ref, divisa, reversado, folio_suc,
                    num_producto, nro_tarjeta, referencia, tipo_cambio,
                    monto_dls, suc_origen, rfc_comer, referencia23)
           SELECT empresa, 0, vFechaHoy, hora_mov, sucursal,
                  num_credito, plaza, transacc_suc, usuario, monto,
                  DECODE(vFunR, "604","606","340","340") ,
		  DECODE(vRefR, 2,1,22,20),divisa, "N", folio_suc,
                  num_producto, nro_tarjeta, referencia, tipo_cambio,
                  monto_dls, suc_origen, rfc_comer, referencia23
             FROM sd_movcapprov
	    WHERE empresa ="001"
              AND num_credito = vCred
              AND codigo_fun = vFun
              AND codigo_ref = vRef
              AND fecha_mov = "04/20/2008"
              AND reversado = "S";



        COMMIT WORK;

END FOREACH

--Recalcula Pago Minimo
FOREACH SELECT a.num_credito, a.status_cred, b.sdo_capital,
	      b. monto_vencido
	  INTO vCred, vStatusCred, vVigente, vVencido
	  FROM sd_maecred a, sd_maesdos b
	 WHERE a.empresa = "001"
	   AND a.num_credito = (SELECT UNIQUE(num_credito)
			 	FROM sd_movcapprov
			       WHERE empresa = "001"
				 AND num_credito = a.num_credito
			         AND fecha_mov = "04202008"
			         AND codigo_fun ="605"
				 AND codigo_ref IN (2)
				 AND reversado = "N")
	  AND b.empresa = a.empresa
	  AND b.num_credito = a.num_credito



	IF vStatusCred = "BT" THEN
		CONTINUE FOREACH;
	ELIF vStatusCred = "AA" THEN

	  IF vVigente > 0 THEN
		LET vMinimo = ROUND((vVigente /10), -0);
	  ELSE
		LET vMinimo = 0;
	  END IF

          SELECT SUM(monto) INTO vMonto
            FROM sd_movhis
           WHERE empresa = '001'
	     AND num_credito = vCred
	     AND codigo_fun IN ('033','334') AND codigo_ref= 1
             AND fecha_mov BETWEEN '03/21/2008' AND '04/20/2008'
	     AND reversado = 'N';


          SELECT sdo_capital INTO vCap FROM sd_maesdoshist
           WHERE fecha='03/20/2008'
  	     AND empresa ='001'
	     AND num_credito = vCred;


	  IF vMonto < vCap THEN
	     IF vCap > 0 THEN
	 	LET vCap = ROUND(vCap / 10,-0);
	     ELSE
		LET vCap = 0;
	     END IF

	     IF vMinimo < vCap THEN
		LET vMinimo = ROUND(vCap / 10,-0);
	     END IF
	  END IF


	ELIF vStatusCred = "BA" THEN
		LET vMinimo = vVigente + vVencido;
	END IF

	IF vMinimo < 40 THEN
	   LET vMinimo = 40;
	END IF

	IF vMinimo > vVigente THEN
		LET vMinimo = vVigente;
	END IF

	UPDATE sd_maesdoshist
	   SET monto_financiado = monto_financiado+(vMinimo - monto_financiado),
	       sdo_trab4 = sdo_trab4 + (vMinimo - sdo_trab4)
	 WHERE fecha = "04202008"
	   AND empresa = "001"
	   AND num_credito = vCred;

	UPDATE sd_maesdoshist
	   SET monto_financiado = monto_financiado+(vMinimo - monto_financiado),
	       sdo_trab4 = sdo_trab4 + (vMinimo - sdo_trab4)
	 WHERE empresa = "001"
	   AND num_credito = vCred;


END FOREACH


--CALL pasecontesp("001", "04/20/2008", "informix", "retrocrd",
--		 "pase",  "04/22/2008")
--RETURNING cod_ret, error_info;




--DROP TABLE sd_movhis20;

RETURN cod_ret;

END PROCEDURE
;