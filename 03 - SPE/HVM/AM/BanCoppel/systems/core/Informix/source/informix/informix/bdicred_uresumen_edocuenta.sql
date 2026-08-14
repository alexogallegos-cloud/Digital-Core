create procedure "informix".uresumen_edocuenta (pempresa char(3))

------------DECLARACION DE VARIABLES-----------------

DEFINE v_id_registro  char(3);
DEFINE v_marca        char(3);
DEFINE v_fecha_corte  char(12);
DEFINE v_mes          char(5);
DEFINE v_ano          char(5);
DEFINE v_dia_corte    smallint;
DEFINE v_apartado_100 smallint;
DEFINE v_apartado_200 smallint;
DEFINE v_apartado_300 smallint;
DEFINE v_apartado_400 smallint;
DEFINE v_total        decimal(18,2);
DEFINE v_fechahoy     date;


------------INICIALIZACION DE VARIABLES--------------

LET v_fechahoy = today;

-----------------------INICIA PL--------------------------------


BEGIN

   	---------------------CONTROL DEL ARCHIVO---------------------------

	LET v_id_registro = "999";
        LET v_marca       = "0";

	--INSERTO EN LA TABLA DE SD_PIE_EDOCTA:

		INSERT INTO sd_control_edocta(fecha_emision, regitro100, registro200, registro300,  registro400, edos_cuenta, total_pagar)
				       VALUES(v_fechahoy, v_id_registro, v_marca, "0", "0", "0", "0");

	-----------------------------------------------------------------------------------------------------------

	--CONTABILIZO TODOS LOS REGISTROS APARTADO DE ENCABEZADO_EDOCUENTA(DATOS DEL CLIENTE):

		SELECT COUNT(num_credito) INTO v_apartado_100 FROM sd_encabezado_edocta;

	--CONTABILIZO TODOS LOS REGISTROS APARTADO DE ENCABEZADO2_EDOCUENTA(SALDOS Y MOV.):

		SELECT COUNT(num_credito) INTO v_apartado_200 FROM sd_encabezado2_edocta;

	--CONTABILIZO TODOS LOS REGISTROS APARTADO DE DETALLE DE EDOCUENTA:

		SELECT COUNT(num_credito) INTO v_apartado_300 FROM sd_detalle_edocta;

	--CONTABILIZO TODOS LOS REGISTROS DE APARTADO DE PIE DE EDOCUENTA:

		SELECT COUNT(num_credito) INTO v_apartado_400 FROM sd_pie_edocta;

	-- SUMO LOS PAGOS MINIMOS DE LOS ESTADOS DE CUENTA:

		SELECT SUM(sdo_pagar) INTO v_total FROM sd_encabezado2_edocta;

	-----------------------------------------------------------------------------------------------------------

	--INSERTO EN LA TABLA DE SD_PIE_EDOCTA:

		INSERT INTO sd_control_edocta(fecha_emision, regitro100, registro200, registro300,  registro400, edos_cuenta, total_pagar)
				       VALUES(v_fechahoy, v_apartado_100, v_apartado_200, v_apartado_300, v_apartado_400, v_apartado_100, v_total);

END;

END PROCEDURE
;