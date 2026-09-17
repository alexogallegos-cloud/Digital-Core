CREATE PROCEDURE "informix".udetallelayout_edocuenta(pempresa char(3),pnum_credito char(20))
RETURNING CHAR(3);


--DECLARACION DE VARIABLES:


DEFINE v_id_registro   char(3);
DEFINE v_marca         char(3);
DEFINE v_fechahoy      date;

DEFINE v_dia           char(2);
DEFINE v_mes           char(2);
DEFINE v_ano	       char(4);
DEFINE v_fecha_emi     date;
DEFINE v_referencia    char(296);
DEFINE v_referencia23  char(279);
DEFINE v_rfc_comer     char(276);
DEFINE v_transacc      char(4);
DEFINE v_monto         decimal(18,2);
DEFINE v_num_credito   char(20);

DEFINE v_concepto      varchar(255);
DEFINE v_naturaleza    char(1);
DEFINE v_secuencia     integer;
DEFINE v_letra         char(15);
DEFINE v_fecha_mov     char(12);

DEFINE v_compra	       decimal(18,2);
DEFINE v_abono	       decimal(18,2);
DEFINE v_usted_debe_ant     decimal(18,2);
DEFINE v_usted_debe     decimal(18,2);

DEFINE v_maximo        char(10);
DEFINE v_fecha_corte   char(12);
DEFINE v_contador      smallint;

DEFINE cod_ret             char(5);
DEFINE sql_err             integer;


--SE INICIALIZAN VARIABLES:

LET v_id_registro  = "";
LET v_marca        = "";

LET v_dia          = "";
LET v_mes          = "";
LET v_ano	   = "";
LET v_referencia   = "";
LET v_referencia23 = "";
LET v_rfc_comer    = "";
LET v_transacc     = "";
LET v_num_credito  = "";

LET v_concepto     = "";
LET v_naturaleza   = "";
LET v_letra        = "";
LET v_fecha_mov    = "";
LET v_maximo       = "";
LET v_fecha_corte  = "";

LET v_monto     = 0;
LET v_contador     = 0;
LET v_usted_debe_ant      = 0;
LET v_usted_debe      = 0;

LET v_compra    = "";
LET v_abono     = "";


 
BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

	-----------------OBTENGO LA FECHA DE PROCESO---------------------------------------------------

	SELECT FIRST 1 '04/20/2007' INTO v_fechahoy FROM sd_fechas;

   	-------------------CONTROL DEL ARCHIVO:--------------------------------------------------------


	LET v_id_registro = "300";
	LET v_marca       = "0";

	IF NOT EXISTS(SELECT * FROM sd_detalle_edocta  WHERE fecha_emision = v_fechahoy AND num_credito = v_id_registro) THEN
	INSERT INTO sd_detalle_edocta(fecha_emision,num_credito,secuencia,fecha_mov,
				concepto,cargos,abonos,nlinea)
	         VALUES(v_fechahoy,v_id_registro,v_marca,"0","0","0","0","0");

	END IF

   -----------------------VALIDO SI EXISTE EL REGISTRO DE SER ASI SE REPORCESA :---------------------------------------------------
--        IF EXISTS(SELECT * FROM sd_detalle_edocta
--                WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito) THEN
        DELETE FROM sd_detalle_edocta WHERE fecha_emision = v_fechahoy AND num_credito = pnum_credito;
--        END IF



	---------------------OBTENGO USTED DEBIA:-----------------------------------------------
	SELECT usted_debia INTO v_usted_debe_ant
	FROM sd_encabezado2_edocta
	WHERE 	fecha_emision = (v_fechahoy - 1 UNITS MONTH)  AND
			num_credito = pnum_credito;

	LET v_usted_debe_ant = NVL(v_usted_debe_ant,0);

	SELECT NVL(MAX(secuencia), 0) + 1 as maximo INTO v_maximo FROM sd_detalle_edocta WHERE num_credito = v_num_credito;

	INSERT INTO sd_detalle_edocta(fecha_emision,   num_credito,      secuencia,
			       fecha_mov,       concepto,         cargos,
			       abonos,          nlinea)
			VALUES(v_fechahoy,     pnum_credito,    v_maximo,
			       "",     "USTED DEBIA", v_usted_debe_ant,
			       "",         v_contador);

   ------------------TRAIGO LA INFO. DE SALDOS Y MOVIMIENTOS----------------------------------------
   	FOREACH
		SELECT 	DAY(a.fecha_mov),
				MONTH(a.fecha_mov),
				YEAR(a.fecha_mov),
				a.fecha_mov,
		   		a.referencia,
		   		a.referencia23,
		   		a.rfc_comer,
		   		a.transacc_suc,
		   		a.monto,
		   		a.num_credito,
		   		TRIM(b.descripcion),
		   		b.naturaleza,
		   		a.secuencia,
                DECODE( MONTH(a.fecha_mov),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6",
                        "JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC")
 		INTO    v_dia,v_mes,
 				v_ano,
 				v_fecha_emi,
				v_referencia,
				v_referencia23,
				v_rfc_comer,
				v_transacc,
				v_monto,
				v_num_credito,
				v_concepto,
				v_naturaleza,
				v_secuencia,
				v_letra
		FROM sd_movdia a, bdinteg:si_transacc b,sd_transfun c
			WHERE a.empresa = pempresa AND a.num_credito = pnum_credito AND
				b.se_emite_edocta = "S" AND c.transacc    = b.numero AND
				a.codigo_fun = c.codigo_fun AND a.codigo_ref = c.codigo_ref
		UNION
		SELECT 	DAY(a.fecha_mov),
				MONTH(a.fecha_mov),
				YEAR(a.fecha_mov),
				a.fecha_mov,
				a.referencia,
				a.referencia23,
				a.rfc_comer,
				a.transacc_suc,
				a.monto,
				a.num_credito,
				TRIM(b.descripcion),
				b.naturaleza,
				a.secuencia,
                DECODE( MONTH(a.fecha_mov),"1","ENE","2","FEB","3","MAR","4","ABR","5","MAY","6",
                        "JUN","7","JUL","8","AGO","9","SEP","10","OCT","11","NOV","12","DIC")
			FROM sd_movhis a, bdinteg:si_transacc b,sd_transfun c,sd_maecredanexo d
				WHERE
                    (a.codigo_fun = c.codigo_fun AND  a.codigo_ref = c.codigo_ref) AND
                    (a.empresa = d.empresa AND a.num_credito = d.num_credito ) AND
                    c.transacc = b.numero    AND
                    a.empresa = pempresa AND
                    a.num_credito = pnum_credito AND
					a.fecha_mov >= ( (month(v_fechahoy)||'/'||d.dia_corte||'/'||year(v_fechahoy))::DATE  - 1 UNITS MONTH) + 1 UNITS DAY AND
					a.fecha_mov <= v_fechahoy AND
                    b.se_emite_edocta = "S"
			ORDER BY 4,13


	------------------------- CONCATENO EL CONCEPTO DEL DETALLE:----------------------------------------------

	LET v_concepto = NVL(TRIM(v_concepto),'') || "  " || NVL(TRIM(v_referencia23),'') || "  " || NVL(TRIM(v_rfc_comer),'');

	------------------------- ARMO LA FEC MOVIMIENTO CON LETRA:----------------------------------------------
	IF v_mes IS NOT NULL THEN
     		LET v_fecha_mov = Trim(v_dia) || "-" || Trim(v_letra) || "-" || v_ano[3] || v_ano[4];
	END IF;

	------------------------- TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA:-----------------------

	IF v_naturaleza IS NOT NULL THEN
		IF v_naturaleza = "C" THEN
			LET v_compra = v_monto;
		ELSE
			LET v_abono  = v_monto;
		END IF;
	END IF;

	------------------------- TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA:-----------------------

	SELECT NVL(MAX(secuencia), 0) + 1 as maximo INTO v_maximo FROM sd_detalle_edocta WHERE num_credito = v_num_credito;

	-------------------------EJECUTO EL SPL ENCARGADO DE CORTAR LOS RENGLONES DE CADA CONCEPTO:-----------------------

	LET v_contador = 0;

	----------------------------------------------------------------------------------------

	FOREACH EXECUTE PROCEDURE corta_linea(v_concepto) INTO v_concepto

		LET v_contador = v_contador + 1;

		IF v_contador = 1 THEN

		-------------COMIENZA LA GRABACION EN LA TABLA DE DETALLE DE EDO CUENTA:-----------------------
			 INSERT INTO sd_detalle_edocta(fecha_emision,   num_credito,      secuencia,
						       fecha_mov,       concepto,         cargos,
						       abonos,          nlinea)
						VALUES(v_fechahoy,     v_num_credito,    v_maximo,
						       v_fecha_mov,     Trim(v_concepto), v_compra,
						       v_abono,         v_contador);
		END IF;

		IF v_contador > 1 THEN
			INSERT INTO sd_detalle_edocta(fecha_emision,     num_credito,   secuencia,
						      concepto,          nlinea)
				               VALUES(v_fechahoy,       v_num_credito, v_maximo,
						      Trim(v_concepto),  v_contador);
		END IF;

	END FOREACH;


	LET v_num_credito  = "";
	LET v_maximo       = "";
	LET v_fecha_mov    = "";
	LET v_concepto     = "";
	LET v_compra       = "";
	LET v_abono        = "";

   END FOREACH;

	---------------------OBTENGO USTED DEBE:-----------------------------------------------
	SELECT usted_debe INTO v_usted_debe
	FROM sd_encabezado2_edocta
	WHERE 	fecha_emision = v_fechahoy AND
			num_credito = pnum_credito;

	LET v_usted_debe = NVL(v_usted_debe,0);

	SELECT NVL(MAX(secuencia), 0) + 1 as maximo INTO v_maximo FROM sd_detalle_edocta WHERE num_credito = v_num_credito;

	INSERT INTO sd_detalle_edocta(fecha_emision,   num_credito,      secuencia,
			       fecha_mov,       concepto,         cargos,
			       abonos,          nlinea)
			VALUES(v_fechahoy,     pnum_credito,    v_maximo,
			       "",     "USTED DEBE", v_usted_debe,
			       "",         v_contador);


  END;
  RETURN cod_ret;

END PROCEDURE ;