CREATE PROCEDURE "informix".cobranza (pnum_credito char(20))
returning CHAR(3),char(36);

--DECLARACION DE VARIABLES:

DEFINE v_fechahoy      		DATE;
DEFINE cod_ret         		CHAR(3);
DEFINE sql_err         		INTEGER;
DEFINE v_cl_cobranza        CHAR(36);

DEFINE v_tp_cliente         CHAR(2);
DEFINE v_situacion          CHAR(1);
DEFINE v_estado_civil       CHAR(1);
DEFINE v_tp_casa            CHAR(1);
DEFINE v_sexo               CHAR(1);
DEFINE v_cantidad           CHAR(2);
DEFINE v_antiguedad         CHAR(2);
DEFINE v_nacimiento         CHAR(2);
DEFINE v_mto_tot_adeudo     CHAR(5);
DEFINE v_adeudo_vencido     CHAR(5);
DEFINE v_fec_ult_pago       CHAR(4);
DEFINE v_monto_ult_convenio CHAR(5);
DEFINE v_fecha_ult_convenio CHAR(4);
DEFINE v_est_cumpl_convenio CHAR(1);
DEFINE v_numcte             CHAR(10);


DEFINE v_sec_ingreso        CHAR(2);
DEFINE v_salario            DECIMAL(18,2);
DEFINE v_monto_adeudo       DECIMAL(18,2);
DEFINE v_mto_adeudo_venc    DECIMAL(18,2);

DEFINE v_clave1		    	VARCHAR(40);
DEFINE v_clave2		    	VARCHAR(40);
DEFINE v_clave3		    	VARCHAR(40);
DEFINE v_clave4		    	VARCHAR(40);
DEFINE v_clave5         	VARCHAR(40);


--INICIALIZO VARIABLES:

LET cod_ret        		 = "";
LET sql_err        		 = "";
LET v_cl_cobranza        = "";

LET v_tp_cliente         = "";
LET v_situacion          = "";
LET v_estado_civil       = "";
LET v_tp_casa            = "";
LET v_sexo               = "";
LET v_cantidad           = "";
LET v_antiguedad         = "";
LET v_nacimiento         = "";
LET v_mto_tot_adeudo     = "";
LET v_adeudo_vencido     = "";
LET v_fec_ult_pago       = "";
LET v_monto_ult_convenio = "";
LET v_fecha_ult_convenio = "";
LET v_est_cumpl_convenio = "";
LET v_numcte             = "";

LET v_sec_ingreso        = "";
LET v_salario            = 0;
LET v_monto_adeudo		 = 0;
LET v_mto_adeudo_venc    = 0;

LET v_clave1		 	= "";
LET v_clave2		 	= "";
LET v_clave3			= "";
LET v_clave4		 	= "";
LET v_clave5         	= "";




BEGIN


  ----------------------CONTROLO LOS ERRORES------------------------------------------
  ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;
            RETURN cod_ret,'';
        END IF
   END EXCEPTION;

   LET cod_ret = "000";

  -------------------OBTENGO LA FECHA DE PROCESO-------------------------------------------------------------------

  SELECT FIRST 1 '04/20/2007' INTO v_fechahoy FROM sd_fechas;

	----------------------1.--TIPO DE CLIENTE: (2 Numero)-----------------------------

	SELECT numcte,TRIM(NVL(calificacion_riesgo,''))
	INTO   v_numcte,v_tp_cliente
	FROM   bdicred:sd_maecredcont
	WHERE  num_credito = pnum_credito AND
		   fecha = '04/30/2007';

  	IF LENGTH(TRIM(v_tp_cliente)) <> 1 THEN
  		LET cod_ret = "206";
		RETURN cod_ret,'';
	ELSE
		LET v_tp_cliente = ' '||TRIM(v_tp_cliente);
  	END IF

	----------------------2.--SITUACION ESPECIAL: (1 letra)--------------------------

	LET v_situacion = "X";

	-----3,4,5,8.--Estado Civil (1 letra),Tipo de Casa (1 letra),Sexo (1 letra),Año Nacimiento (2 Numeros)------

	SELECT 	TRIM(NVL(estado_civil,'')),TRIM(NVL(SUBSTR(habita_en, 2,1),'')),
		  	TRIM(NVL(sexo,'')), NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'')
	INTO 	v_estado_civil, v_tp_casa,
			v_sexo,   v_nacimiento
    FROM   bdinteg:si_ctepf
	WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_estado_civil)) <> 1 THEN
  		LET cod_ret = "207";
		RETURN cod_ret,'';
  	END IF

  	IF LENGTH(TRIM(v_tp_casa)) <> 1 THEN
  		LET cod_ret = "208";
		RETURN cod_ret,'';
  	END IF

  	IF LENGTH(TRIM(v_sexo)) <> 1 THEN
  		LET cod_ret = "209";
		RETURN cod_ret,'';
  	END IF

  	IF LENGTH(TRIM(v_nacimiento)) <> 2 THEN
  		LET cod_ret = "210";
		RETURN cod_ret,'';
  	END IF

	----------------------6.--SALARIO (2 NUMEROS):------------------------------------


	SELECT max(sec_ingreso) as maxima
	INTO   v_sec_ingreso
	FROM   bdinteg:si_ingresos
	WHERE  numcte = v_numcte;

	SELECT NVL(ingreso_mensual,0) / 1000
	INTO   v_salario
	FROM   bdinteg:si_ingresos
	WHERE  numcte = v_numcte and sec_ingreso = v_sec_ingreso;

	IF v_salario <= 0 OR v_salario >= 100 THEN
  		LET cod_ret = "211";
		RETURN cod_ret,'';
	ELSE
		LET v_cantidad = LPAD(v_salario::INTEGER::VARCHAR(2),2,'0');
	END IF


	----------------------7.-ANTIGUEDAD: (2 NUMEROS)-------------------------------------


	SELECT NVL(SUBSTR(YEAR(fecha_alta), 3, 2),'')
	INTO   v_antiguedad
	FROM   bdinteg:si_cliente
	WHERE  numcte = v_numcte;

  	IF LENGTH(TRIM(v_antiguedad)) <> 2 THEN
  		LET cod_ret = "212";
		RETURN cod_ret,'';
  	END IF

	----------------------9.-TRAIGO EL MONTO TOTAL DE ADEUDO (5 NUMEROS)---------------

	SELECT NVL(sdo_cap_insoluto,0)
	INTO   v_monto_adeudo
	FROM   bdicred:sd_maesdoshist
	WHERE  num_credito = pnum_credito
			AND fecha = v_fechahoy
			AND fecha_ult_mov = v_fechahoy;

	IF v_monto_adeudo >= 100000 THEN
  		LET cod_ret = "213";
		RETURN cod_ret,'';
	ELSE
		LET v_mto_tot_adeudo = LPAD(v_monto_adeudo::INTEGER::VARCHAR(5),5,'0');
	END IF

	----------------------10.-TRAIGO EL ADEUDO VENCIDO (5 NUMEROS)---------------------

	SELECT NVL(monto_vencido,0) + NVL(mto_venc_trasp,0)
	INTO   v_mto_adeudo_venc
	FROM   bdicred:sd_maesdoshist
	WHERE  num_credito = pnum_credito
			AND fecha = v_fechahoy
			AND fecha_ult_mov = v_fechahoy;


	IF v_mto_adeudo_venc >= 100000 THEN
  		LET cod_ret = "214";
		RETURN cod_ret,'';
	ELSE
		LET v_adeudo_vencido =  LPAD(v_mto_adeudo_venc::INTEGER::VARCHAR(5),5,'0');
	END IF



	----------------------11.-FECHA DE ULT. PAGO: (4 NUMEROS)---------------------------
	SELECT NVL(MONTH(fecha_ult_pago),0) || NVL(YEAR(fecha_ult_pago),0)
	INTO v_fec_ult_pago
	FROM sd_maecredanexo
	WHERE num_credito = pnum_credito;

	LET v_fec_ult_pago =  LPAD(v_fec_ult_pago,4,'0');


	----------------------12.-MONTO DE ULT. CONVENIO: (5 NUMEROS)------------------------
	LET v_monto_ult_convenio =  LPAD("0",5,'0');

	----------------------13.-FECHA DE ULT. CONVENIO:	(4 NUMEROS)----------------------
	LET v_fecha_ult_convenio =  LPAD("0",4,'0');

	----------------------14.-ESTADO DE CUMPLIMIENTO DE CONVENIO: (1 LETRA)--------------
	LET v_est_cumpl_convenio =  "0";

	-------------------------------ARMO LA CLAVE DE COBRANZA:----------------------------

	LET v_clave1 = v_tp_cliente         	  || "" || TRIM(v_situacion)    || "" || TRIM(v_estado_civil);
	LET v_clave2 = TRIM(v_tp_casa)            || "" || TRIM(v_sexo)         || "" || TRIM(v_cantidad);
	LET v_clave3 = TRIM(v_antiguedad)         || "" || TRIM(v_nacimiento)   || "" || TRIM(v_mto_tot_adeudo);
	LET v_clave4 = TRIM(v_adeudo_vencido)     || "" || TRIM(v_fec_ult_pago) || "" || TRIM(v_monto_ult_convenio);
	LET v_clave5 = TRIM(v_fecha_ult_convenio) || "" || TRIM(v_est_cumpl_convenio);

	LET v_cl_cobranza = v_clave1 || "" || v_clave2 || "" || v_clave3 || "" || v_clave4 || "" || v_clave5;

END
RETURN '000',v_cl_cobranza;
END PROCEDURE ;