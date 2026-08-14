CREATE PROCEDURE "informix".totcomp_sbc(o_empresa CHAR(3), o_usuario CHAR(8), o_sucursal CHAR(4), o_num_total SMALLINT)
	RETURNING 
			CHAR(5),
			CHAR(2),
			MONEY(16, 2),
			MONEY(16, 2),
			MONEY(16, 2),
			MONEY(16, 2),
			CHAR(40),
			INTEGER,
			INTEGER,
			INTEGER,
			INTEGER;
			
-- ============================================================================
-- =                        DEFINICION DE VARIABLES                           =
-- ============================================================================
	DEFINE v_monto_cargo	MONEY(16, 2);
	DEFINE v_monto_firme 	MONEY(16, 2);
	DEFINE v_monto_sbc 	 	MONEY(16, 2);
	DEFINE v_monto_rem 	 	MONEY(16, 2);
	DEFINE v_movto_cargo		 INTEGER;
	DEFINE v_movto_firme 	     INTEGER;
	DEFINE v_movto_sbc   		 INTEGER;
	DEFINE v_movto_rem   		 INTEGER;
	DEFINE v_descripcion 		CHAR(40);
	DEFINE v_contador    		SMALLINT;
	DEFINE v_fecha 					DATE;
	DEFINE v_row 				 INTEGER;
	DEFINE v_codret 			 CHAR(5);
	DEFINE v_empresa 			 CHAR(3);
	DEFINE w_plaza 				 CHAR(3);
	DEFINE w_sucursal 			 CHAR(4);
	DEFINE v_producto 			 CHAR(4);
	DEFINE v_ciclo 				SMALLINT;
	DEFINE v_divisa 			 CHAR(2);
	DEFINE v_cal_int_chq 		 CHAR(1);
	DEFINE sql_err 				 INTEGER;
	DEFINE v_usuario 			 CHAR(8);
	DEFINE v_existe 			 CHAR(1);	
	
-- ============================================================================
-- =                        ASIGNACION DE VALORES                             =
-- ============================================================================	
	LET v_codret		= "00000";
	LET v_contador 		= 0;
	LET v_ciclo 		= 0;	
	LET v_monto_cargo 	= 0;
	LET v_monto_firme 	= 0;
	LET v_monto_sbc 	= 0;
	LET v_monto_rem 	= 0;
	LET v_movto_cargo 	= 0;
	LET v_movto_firme 	= 0;
	LET v_movto_sbc 	= 0;
	LET v_movto_rem 	= 0;
	LET v_divisa 		= "";
	LET v_descripcion	= "";
	LET v_usuario     	= "";	
	LET v_existe 		= "";

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/dbexportb/clemente/totcomp.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET v_coDret = sql_err;
			RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, v_descripcion, v_movto_cargo, 
				   v_movto_firme, v_movto_sbc, v_movto_rem;
		END IF
	END EXCEPTION;

	SELECT {+INDEX(sd_fechas idx_sdfechas)} fecha_hoy 
	  INTO v_fecha
	  FROM bdicred:sd_fechas
	 WHERE empresa = o_empresa;
	
 
	FOREACH
		SELECT {+INDEX(sd_movdia idx_movdia2)} divisa, 
			   NVL(SUM(CASE WHEN codigo_fun = '002' THEN monto END), 0),
			   NVL(SUM(CASE WHEN codigo_fun = '002' THEN 1 END), 0),
			   NVL(SUM(CASE WHEN codigo_fun IN ('033', '333') THEN monto END), 0),
			   NVL(SUM(CASE WHEN codigo_fun IN ('033', '333') THEN 1 END), 0),
			   NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN monto END), 0),
			   NVL(SUM(CASE WHEN codigo_fun = "336" AND codigo_ref = 20 THEN 1 END), 0),
			   (SELECT descripcion FROM bdinteg:si_divisas WHERE a.divisa = divisa AND empresa = '001')
		  INTO v_divisa, 
			   v_monto_cargo,
			   v_movto_cargo, 
			   v_monto_firme,
			   v_movto_firme,
			   v_monto_sbc,
			   v_movto_sbc,
			   v_descripcion
		  FROM bdicred:sd_movdia a
		 WHERE usuario = o_usuario
		   AND sucursal = o_sucursal
		   AND ((codigo_fun IN ("033", "333") AND codigo_ref = 1)
			   OR (codigo_fun = "336" AND codigo_ref = 20)
			   OR (codigo_fun = "002" AND codigo_ref IN (50, 60)))
		   AND reversado <> "S"
		   AND fecha_mov = v_fecha
		   AND empresa = o_empresa
	  GROUP BY 1

		RETURN v_codret, v_divisa, v_monto_cargo, v_monto_firme, v_monto_sbc, v_monto_rem, TRIM(v_descripcion), v_movto_cargo, v_movto_firme,
			   v_movto_sbc, v_movto_rem WITH RESUME;
			   
	END FOREACH;
END
END PROCEDURE;