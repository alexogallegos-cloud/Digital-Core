CREATE PROCEDURE "informix".cargoref_tc_ofi(o_empresa  CHAR(3),
				 o_sucursal CHAR(4),
				 o_usuario  CHAR(8),
				 o_tarjeta  CHAR(20),
				 o_monto    DECIMAL(14,2),
				 o_folio    CHAR(16),
				 o_transuc  CHAR(4))

RETURNING CHAR(5),       -- Codigo Retorno
	  DECIMAL(14,2), -- Saldo Disponible 
          DECIMAL(14,2), -- Importe Cargado
	  DECIMAL(14,2); -- Importe Comision

-- **************************************************************************
-- *                      DEFINICION DE VARIABLES                           *
-- **************************************************************************
DEFINE cod_ret             CHAR(5);
DEFINE cod_ret2            CHAR(5);
DEFINE sql_err             SMALLINT;
DEFINE isam_err            SMALLINT;
DEFINE error_info          CHAR(40);
DEFINE Saldo               MONEY(14,2);
DEFINE SaldoCom            MONEY(14,2);
DEFINE v_monto		   MONEY(14,2);
DEFINE v_codparam	   CHAR(4);
DEFINE v_fecha             DATE;
DEFINE v_num_credito       CHAR(20);
DEFINE v_divisa		   CHAR(2);
DEFINE MtoCgo		   MONEY(14,2);
DEFINE MtoCom		   MONEY(12,2);
DEFINE v_faplica           CHAR(1);
DEFINE v_factor		   DECIMAL(9,6);


-- **************************************************************************
-- *                      CONTROL DE ERRORES                                *
-- **************************************************************************

ON EXCEPTION SET sql_err, isam_err, error_info
   SET DEBUG FILE TO "CargoLineaCredito.err";
--   TRACE sql_err||" * "||isam_err||" * "||error_info;
   LET cod_ret = sql_err;
   LET Saldo = 0;
   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom;
END EXCEPTION;



-- **************************************************************************
-- *                      ASIGNACION DE VARIABLES                           *
-- **************************************************************************

LET cod_ret       = "000";
LET Saldo         = 0;
LET cod_ret2      = "000";
LET SaldoCom      = 0;
LET MtoCgo	  = 0;
LET MtoCom	  = 0;

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	-- **************************
	-- **************************
	SELECT a.num_credito, b.divisa
	  INTO v_num_credito, v_divisa
	  FROM sd_tarjeta a, sd_maecred b
	 WHERE a.empresa = o_empresa
	   AND a.num_tarjeta = o_tarjeta
	   AND b.empresa = a.empresa
	   AND b.num_credito = a.num_credito;

	IF v_num_credito IS NULL THEN
		LET cod_ret = "008";
	        RETURN cod_ret, SaldoCom, MtoCgo, MtoCom;
	END IF



	-- ***********************************************
	-- Extrae Comision por disposicion en ventanilla *
	-- ***********************************************
	SELECT valor INTO v_codparam
	  FROM sd_param
	 WHERE empresa = o_empresa
	   AND cod_param = "334";


	SELECT form_aplica, monto, apli_factor
	  INTO v_faplica, v_monto, v_factor
	  FROM sd_tpcomis
	 WHERE empresa = o_empresa
	   AND cod_comis = v_codparam;

	IF v_faplica = 2 THEN
		LET v_monto = o_monto * v_factor;
	END IF

	EXECUTE PROCEDURE cargo_ref_cel(o_tarjeta, o_sucursal, o_usuario,
					o_transuc, o_transuc,  o_folio,
					v_num_credito, 1, o_monto, 0,
					" ", " ", v_divisa, "",  
					o_sucursal, o_usuario, v_codparam,
					v_codparam, o_folio, v_num_credito,
					1, v_monto, v_divisa, " ", "2",
					" ", " ", " ", 0, 0, " ", " ")
	INTO cod_ret, v_codparam, v_fecha, Saldo, MtoCgo, 
	     cod_ret2, v_codparam, v_fecha, SaldoCom, MtoCom;


   RETURN cod_ret, SaldoCom, MtoCgo, MtoCom;

END PROCEDURE
				 
;