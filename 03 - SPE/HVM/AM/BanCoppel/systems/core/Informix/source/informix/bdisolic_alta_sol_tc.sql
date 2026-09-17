CREATE PROCEDURE "informix".alta_sol_tc(o_empresa CHAR(3),
							o_num_cliente 	CHAR(20),
							o_producto 		CHAR(4),
							o_sucursal		CHAR(4),
							o_ejecutivo		CHAR(8),
							o_referencia1 	CHAR(20),
							o_referencia2	CHAR(20),
							o_porcentaje	DECIMAL(5,2),
							o_situacion		CHAR(1),
							o_meses			SMALLINT,
							o_ingreso 		MONEY(14,2),
							o_linea 		MONEY(14,2),
							o_causa			SMALLINT,
							o_puntualidad 	CHAR(2),
							o_saldoropa		MONEY(14,2),
							o_saldomuebles 	MONEY(14,2),
							o_saldoprestamos MONEY(14,2),
							o_vencidoropa	MONEY(14,2),
							o_vencidomuebles MONEY(14,2),
							o_vencidoprestamos MONEY(14,2),
							o_abonomensualropa MONEY(14,2),
							o_abonomensualmuebles MONEY(14,2),
							o_abonomensualprestamos MONEY(14,2))

RETURNING CHAR(5), CHAR(20);
-- CONTROL DE CAMBIOS:
------------------------------------------------------------------------------------------------------------------------
-- Fecha: 22/Jul/2009
-- Modifico:  Alfonso Velázquez Capuleño
-- Objetivo: Colocar el nuevo estatus "CE" en la lista de los estatus
--                  que no permiten generar nuevas solicitudes
------------------------------------------------------------------------------------------------------------------------
-- Modificó: Viridiana Osobampo
-- Descripción: Se modifica para que en el llamado del procedimiento asigna_numsol se envíe como
--		 parámetro el número de producto que se solicita.
-- Fecha modificación: 05-01-2010
-- Petición: Préstamo Personal BanCoppel
------------------------------------------------------------------------------------------------------------------------

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE s_numsol     VARCHAR(20);
DEFINE v_tpsol      CHAR(1);
DEFINE v_tipper     CHAR(2);
DEFINE v_paso1      CHAR(20);
DEFINE v_paso2      CHAR(120);
DEFINE v_paso3      CHAR(20);
DEFINE v_paso4      CHAR(120);
DEFINE v_paso5      CHAR(1);
DEFINE v_paso6      SMALLINT;
DEFINE v_paso7      CHAR(1);
DEFINE v_paso8      CHAR(2);
DEFINE v_paso9      CHAR(3);
DEFINE v_paso10     CHAR(3);
DEFINE v_paso11     CHAR(3);
DEFINE v_paso12     CHAR(13);
DEFINE v_paso13     CHAR(13);
DEFINE v_paso14     CHAR(2);
DEFINE v_paso15     CHAR(2);
DEFINE v_paso16     CHAR(20);
DEFINE v_fuente     CHAR(1);
DEFINE sql_err      SMALLINT;
DEFINE isam_err     SMALLINT;
DEFINE error_info   CHAR(100);
DEFINE vEdadCte     SMALLINT;
DEFINE vEdadMin     SMALLINT;
DEFINE vEdadMax     SMALLINT;
DEFINE vMesesHis    SMALLINT;
--  ini jom Parametro referencia coppel
define v_paso_cliente char(20);
--  fin jom Parametro referencia coppel

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "000";
LET vsqlerr      = 0;
LET v_fuente     = "T"; -- EL valor T en esta columna define que los datos de la
                        -- precalificacion llegaron de la tienda coppel
LET v_paso1      = "";
LET v_paso2      = "";
LET v_paso3      = "";
LET v_paso4      = "";
LET v_tpsol      = "";
LET s_numsol     = "??????";
--  ini jom Parametro referencia coppel
let v_paso_cliente = "";
--  fin jom Parametro referencia coppel

SELECT valor INTO vEdadMin
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 310;

SELECT valor INTO vEdadMax
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 311;

SELECT valor INTO vMesesHis
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 327;

--  ini jom Parametro referencia coppel
SELECT valor INTO v_paso_cliente
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 325;
--  fin jom Parametro referencia coppel

    --Set debug file to '/tmp/alta_sol_tc_prueba.out';
    --trace on;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************

BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, s_numsol;
   END EXCEPTION;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- ****************************************************
	--   VERIFICA ANTIGUEDAD EN CLIENTES COPPEL Y NUEVOS  *
	-- ****************************************************

    IF (trim(v_paso_cliente) <> trim(o_num_cliente)) THEN
        IF NVL(o_meses,0)<vMesesHis THEN
            LET scod_ret = "104";
      		RETURN scod_ret, s_numsol;
        END IF
    END IF;

        -- ***************************************************
        -- Valicacion Generales para el alta de la solicitud *
        -- ***************************************************
	-- Valida Solicitudes en Proceso
        SELECT COUNT(*) INTO v_paso6
          FROM ss_solicitudes
         WHERE empresa = o_empresa
           AND numcte = o_num_cliente
           AND num_producto = o_producto
           AND status_solicitud IN ("EA","EE","AT","AP","CC","OA","CE","OS","BC","ST");

        IF v_paso6 > 0 THEN
                LET scod_ret = "710";
      		RETURN scod_ret, s_numsol;
        END IF

        -- *************************************
        -- Graba Solicitud como Pre-Calificada *
        -- *************************************


	-- Valida Edad Permtida para Otorgamiento
	IF vEdadMin IS NULL OR vEdadMax IS NULL THEN
                LET scod_ret = "100";
      		RETURN scod_ret, s_numsol;
	END IF

	SELECT ROUND((((SELECT fecha_hoy
			  FROM bdinteg:si_fechas
			 WHERE empresa = o_empresa) -
		      fecha_nac) / 365))
	 INTO vEdadCte
	 FROM bdinteg:si_ctepf
	WHERE numcte = o_num_cliente
	  AND empresa = o_empresa;

	IF vEdadCte < vEdadMin OR vEdadCte > vEdadMax THEN
                LET scod_ret = "711";
      		RETURN scod_ret, s_numsol;
	END IF

	-- *******************+******
	-- Extrae Tipo de Solicitud *
	-- *******************+******
        SELECT a.tp_solicitud INTO v_tpsol
          FROM ss_tp_solicitud a, ss_solic_producto b
         WHERE b.empresa = o_empresa
           AND b.num_producto = o_producto
           AND a.tp_solicitud = b.tp_solicitud;

        -- *****************************************
        -- Determina Numero de Solicitud a Asignar *
        -- *****************************************

        CALL asigna_numsol(o_empresa,o_producto)
        RETURNING scod_ret, s_numsol;

        IF scod_ret <> "000" THEN
                RETURN scod_ret, s_numsol;
        END IF

        -- *************************************
        -- Graba Solicitud como Pre-Calificada *
        -- *************************************

        EXECUTE PROCEDURE graba_sol_precalificada
                (o_empresa, s_numsol, o_num_cliente, o_sucursal,
                 v_tpsol,  o_producto, o_ejecutivo)
           INTO scod_ret;

        IF scod_ret <> "000" THEN
                RETURN scod_ret, s_numsol;
        END IF

       IF o_porcentaje = 0 THEN
		EXECUTE PROCEDURE situacion_pago_banco
			(o_empresa, o_num_cliente, o_producto, o_sucursal,
			 o_ejecutivo, "1")
		   INTO scod_ret, v_tipper, v_paso1, v_paso2, v_paso3, v_paso4,
			v_paso5, v_paso7, v_paso6, v_paso8, v_paso9, v_paso10, v_paso11,
                        v_paso12, v_paso13, v_paso14, v_paso15, v_paso16;

		LET o_porcentaje = v_paso1;
		LET o_situacion = v_paso2;
		LET o_meses = v_paso3;
		LET v_fuente = "B"; -- Valores de Precalificacion son del banco
	END IF

        INSERT INTO ss_resum_scor_fin
		(empresa, num_solicitud, situacion_pago, situacion_credito,
		 meses_historia, fuente, ingreso_mensual, linea_tienda, causa,
                 puntualidad, saldoropa, saldomuebles, saldoprestamos, vencidoropa,
                 vencidomuebles, vencidoprestamos, abonomensualropa, abonomensualmuebles,
                 abonomensualprestamos)
	VALUES
               (o_empresa, s_numsol, o_porcentaje , o_situacion, o_meses,
		v_fuente, o_ingreso, o_linea, o_causa, o_puntualidad, o_saldoropa,
                o_saldomuebles, o_saldoprestamos, o_vencidoropa, o_vencidomuebles,
                o_vencidoprestamos, o_abonomensualropa, o_abonomensualmuebles,
                o_abonomensualprestamos);

END
	RETURN scod_ret, s_numsol;

END PROCEDURE 