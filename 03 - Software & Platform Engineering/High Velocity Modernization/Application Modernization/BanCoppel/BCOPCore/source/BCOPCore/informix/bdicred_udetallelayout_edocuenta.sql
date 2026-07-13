CREATE PROCEDURE "informix".udetallelayout_edocuenta(
				pempresa char(3),
				pnum_credito char(20),
				pfechahoy date)
RETURNING CHAR(5);


--DECLARACION DE VARIABLES:


DEFINE v_id_registro   		char(3);
DEFINE v_marca         		char(3);
DEFINE cod_ret             	char(5);
DEFINE sql_err             	integer;

DEFINE v_dia           		char(2);
DEFINE v_mes           		char(2);
DEFINE v_ano	       		char(4);
DEFINE v_fecha_emi     		date;
DEFINE v_referencia    		char(296);
DEFINE v_referencia23  		char(279);
DEFINE v_rfc_comer     		char(276);
DEFINE v_transacc      		char(4);
DEFINE v_monto         		decimal(18,2);
DEFINE v_num_credito   		char(20);

DEFINE v_concepto      		varchar(255);
DEFINE v_naturaleza    		char(1);
DEFINE v_secuencia     		integer;
DEFINE v_letra         		char(15);
DEFINE v_fecha_mov     		char(12);

DEFINE v_compra	       		decimal(18,2);
DEFINE v_abono	       		decimal(18,2);
DEFINE v_usted_debe_ant     decimal(18,2);
DEFINE v_usted_debe     	decimal(18,2);

DEFINE v_maximo        		char(10);
DEFINE v_fecha_corte   		char(12);
DEFINE v_contador      		smallint;



--SE INICIALIZAN VARIABLES:

LET v_id_registro  = "";
LET v_marca        = "";

LET v_dia          = "";
LET v_mes          = "";
LET v_ano	   	   = "";
LET v_referencia   = "";
LET v_referencia23 = "";
LET v_rfc_comer    = "";
LET v_transacc     = "";
LET v_monto     = 0;
LET v_num_credito  = "";

LET v_concepto     = "";
LET v_naturaleza   = "";
LET v_letra        = "";
LET v_fecha_mov    = "";

LET v_compra    = "";
LET v_abono     = "";
LET v_usted_debe_ant      = 0;
LET v_usted_debe      = 0;

LET v_maximo       = "";
LET v_fecha_corte  = "";
LET v_contador     = 0;

 --SET DEBUG FILE TO "detalleedocuenta.out";
 --TRACE ON;

BEGIN


  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret;
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

    --------------------------------------------------------
    --	OBTIENE EL TOTAL REGISTROS DETALLE DE LA CUENTA
    --------------------------------------------------------
	SELECT NVL(MAX(secuencia), 0) + 1 as maximo
		INTO v_maximo
	FROM sd_detalle_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = v_num_credito ;

    --------------------------------------------------------
    --      GENERA USTED DEBIA
    --------------------------------------------------------

	SELECT usted_debia
		INTO v_usted_debe_ant
	FROM sd_encabezado2_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = pnum_credito;


	INSERT INTO sd_detalle_edocta
				(
				fecha_emision,num_credito,secuencia,
			    fecha_mov,concepto,cargos,nlinea
			    )
			VALUES(
				pfechahoy,pnum_credito,v_maximo,
			    "","USTED DEBIA",NVL(v_usted_debe_ant,0),1
			    );

    --------------------------------------------------------
    --      GENERA EL DETALLE DE LAS CUENTAS
    --------------------------------------------------------
	FOREACH SELECT 	DAY(a.fecha_mov),MONTH(a.fecha_mov),YEAR(a.fecha_mov),
				a.fecha_mov,a.referencia,a.referencia23,
				a.rfc_comer,a.transacc_suc,a.monto,
				a.num_credito,TRIM(c.descripcion),b.naturaleza,
				a.secuencia,
                DECODE( MONTH(a.fecha_mov),
                		"1","ENE","2","FEB","3","MAR",
                		"4","ABR","5","MAY","6","JUN",
                		"7","JUL","8","AGO","9","SEP",
                		"10","OCT","11","NOV","12","DIC")
		 		INTO    v_dia,v_mes,v_ano,
		 				v_fecha_emi,v_referencia,v_referencia23,
						v_rfc_comer,v_transacc,v_monto,
						v_num_credito,v_concepto,v_naturaleza,
						v_secuencia,v_letra
			FROM sd_movhisedocta  a
			INNER JOIN sd_transfun c
				ON a.codigo_fun = c.codigo_fun
				AND a.codigo_ref = c.codigo_ref
				AND  a.empresa = c.empresa
			INNER JOIN  bdinteg:si_transacc b
				ON c.empresa = b.empresa
				AND c.transacc = b.numero
				and b.sistema = "06"
			WHERE  a.empresa = pempresa
				AND a.num_credito = pnum_credito
				AND a.fecha_mov > pfechahoy - 1 UNITS MONTH
				AND a.fecha_mov <= pfechahoy
				AND a.reversado <> "S"
				AND b.se_emite_edocta = "S"
			ORDER BY a.fecha_mov,a.secuencia


			IF v_monto = 0 THEN
				CONTINUE FOREACH;
			END IF
		    --------------------------------------------------------
		    --      GENERO LA DESCRIPCION DEL MOVIMIENTO
		    --------------------------------------------------------
			IF v_referencia IS NULL THEN
				LET v_concepto = NVL(TRIM(v_concepto),'');
			ELSE
				IF v_referencia[1,8] = "intercar" THEN
				   LET v_concepto = TRIM(SUBSTRING(v_referencia FROM 16))
				   					|| "  " ||
				   					NVL(TRIM(v_referencia23),'')
				   					|| "  " ||
				   					NVL(TRIM(v_rfc_comer),'');
				   IF v_concepto[1,8] = "intercar" THEN
						LET v_concepto = TRIM(SUBSTRING(v_concepto FROM 16));
				   END IF
				ELSE
					LET v_concepto = NVL(TRIM(v_concepto),'')|| "  " ||TRIM(v_referencia[1,16]);
				END IF
			END IF
		    --------------------------------------------------------
		    --ARMO LA FEC MOVIMIENTO CON LETRA
		    --------------------------------------------------------
			IF v_mes IS NOT NULL THEN
		     	LET v_fecha_mov = Trim(v_dia)  || "-" ||
		     					  Trim(v_letra)|| "-" ||
		     					  v_ano[3]||v_ano[4];
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL MONTO DEPENDIENDO SI ES UNA ENTRADA O SALIDA
		    --------------------------------------------------------
			IF v_naturaleza IS NOT NULL THEN
				IF v_naturaleza = "A" THEN
					LET v_abono  = v_monto;
				ELSE
					LET v_compra = v_monto;
				END IF;
			ELSE
				LET v_compra = v_monto;
			END IF;
		    --------------------------------------------------------
		    --TRAIGO EL SERIAL CONSECUTIVO DE LA TABLA DETALLE EDOCUENTA
		    --------------------------------------------------------
			LET v_maximo = v_maximo + 1 ;
			LET v_contador = 0;
		    --------------------------------------------------------
		    --DIVIDO EL CONCEPTO DEL MOVIMIENTOS EN VARIAS LINEAS
		    --------------------------------------------------------
				FOREACH EXECUTE PROCEDURE corta_linea(v_concepto) INTO v_concepto

					LET v_contador = v_contador + 1;
					IF v_contador = 1 THEN
						 INSERT INTO sd_detalle_edocta
						 	(
						 	fecha_emision,num_credito,secuencia,
							fecha_mov,concepto,cargos,
							abonos,nlinea
							)
						VALUES
							(
							pfechahoy,v_num_credito,v_maximo,
							v_fecha_mov,Trim(v_concepto),v_compra,
							v_abono,v_contador
							);
					ELSE
						INSERT INTO sd_detalle_edocta
							(
							fecha_emision,num_credito,secuencia,
							concepto,nlinea
							)
						VALUES(
							pfechahoy,v_num_credito,v_maximo,
							Trim(v_concepto),v_contador
							);
					END IF;

				END FOREACH;
		    --------------------------------------------------------
		    --INICIALIZA LAS VARIABLES
		    --------------------------------------------------------
			LET v_num_credito  = "";
			LET v_fecha_mov    = "";
			LET v_concepto     = "";
			LET v_compra       = "";
			LET v_abono        = "";

	END FOREACH;

    --------------------------------------------------------
    --      GENERA USTED DEBE
    --------------------------------------------------------
	SELECT usted_debe
		INTO v_usted_debe
	FROM sd_encabezado2_edocta
		WHERE fecha_emision = pfechahoy
		AND num_credito = pnum_credito;

	INSERT INTO sd_detalle_edocta
			(
			fecha_emision,num_credito,secuencia,
			fecha_mov,concepto,cargos,nlinea
			)
			VALUES
			(
			pfechahoy,pnum_credito,v_maximo + 1,
			"","USTED DEBE",NVL(v_usted_debe,0),1
			);


  END;
  RETURN cod_ret;

END PROCEDURE ;