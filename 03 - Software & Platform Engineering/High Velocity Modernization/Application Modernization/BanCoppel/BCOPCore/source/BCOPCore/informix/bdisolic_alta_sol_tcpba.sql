CREATE PROCEDURE "informix".alta_sol_tcpba(o_empresa CHAR(3),
                             o_num_cliente   CHAR(20),
                             o_producto      CHAR(4),
                             o_sucursal      CHAR(4),
                             o_ejecutivo     CHAR(8),
			     o_referencia1   CHAR(20),
			     o_referencia2   CHAR(20),
			     o_porcentaje    DECIMAL(5,2),
			     o_situacion     CHAR(1),
			     o_meses         SMALLINT,
			     o_ingreso       MONEY(14,2),
			     o_linea         MONEY(14,2),
			     o_causa         SMALLINT)


RETURNING CHAR(5), CHAR(20);

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

SELECT valor INTO vEdadMin
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 310;

SELECT valor INTO vEdadMax
  FROM ss_param
 WHERE empresa = o_empresa
   AND secuencia = 311;
-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
set debug file to "alta_sol_tc.out";
TRACE ON ;

BEGIN
   ON EXCEPTION SET sql_err, isam_err, error_info
      SET DEBUG FILE TO "CargoLineaCredito.err";
   --   TRACE sql_err||" * "||isam_err||" * "||error_info;
      LET scod_ret = sql_err;
      RETURN scod_ret, s_numsol;
   END EXCEPTION;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

        -- ***************************************************
        -- Valicacion Generales para el alta de la solicitud *
        -- ***************************************************
	-- Valida Solicitudes en Proceso
        SELECT COUNT(*) INTO v_paso6
          FROM ss_solicitudes
         WHERE empresa = o_empresa
           AND numcte = o_num_cliente
           AND status_solicitud IN ("EA","EE","AT","AP","CC");

        IF v_paso6 > 0 THEN
                LET scod_ret = "710";
      		RETURN scod_ret, s_numsol;
        END IF

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

        CALL asigna_numsol(o_empresa)
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
		 meses_historia, fuente, ingreso_mensual, linea_tienda, causa)
	VALUES
               (o_empresa, s_numsol, o_porcentaje , o_situacion, o_meses,
		v_fuente, o_ingreso, o_linea, o_causa);

END
	RETURN scod_ret, s_numsol;

END PROCEDURE;