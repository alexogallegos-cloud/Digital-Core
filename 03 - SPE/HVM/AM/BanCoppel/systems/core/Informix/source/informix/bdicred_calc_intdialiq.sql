CREATE PROCEDURE "informix".calc_intdialiq(enum_credito CHAR(20))
RETURNING CHAR(5), DECIMAL(16,2), SMALLINT;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_tasa       DECIMAL(8,6);
DEFINE v_tpcred     CHAR(2);
DEFINE v_capital    MONEY(14,2);
DEFINE v_hoy        DATE;
DEFINE v_cuota1	    DATE;
DEFINE v_cuotavig   DATE;
DEFINE v_fechacalc  DATE;
DEFINE ax_intdia    DECIMAL(16,2);
DEFINE ax_diascalc  SMALLINT;
DEFINE v_diasano    SMALLINT;
DEFINE v_status     CHAR(1);
DEFINE ax_difint    DECIMAL(16,2);
DEFINE ax_intant    DECIMAL(16,2);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;
LET ax_intdia    = 0;
LET ax_diascalc  = 0;
LET ax_difint    = 0;
let ax_intant    = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret, ax_intdia, ax_diascalc;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	IF SUBSTR(enum_credito,10,3) = "410" THEN
		SELECT sdo_no_exig, dias_acum_int
	 	  INTO ax_intdia, ax_diascalc
	 	  FROM sd_maesdos
		 WHERE num_credito = enum_credito;

		 RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF

	SELECT a.tasa_interes / 100, cod_tipcred, sdo_capital	
	  INTO v_tasa, v_tpcred, v_capital
	  FROM sd_maecred a, sd_definicion b, sd_maesdos c
	 WHERE a.num_producto = b.num_producto
	   AND c.num_credito = a.num_credito
	   AND a.num_credito = enum_credito;

	IF v_tpcred = "01" OR v_tpcred = "04" THEN
		LET v_diasano = 365;
	ELSE
		LET v_diasano = 360;
	END IF

	SELECT fecha_hoy INTO v_hoy FROM sd_fechas;

	SELECT MIN(fecha_cuota) INTO v_cuota1
	  FROM sd_pagocapit
	 WHERE num_credito = enum_credito;

        -- Determina Fecha Cuota Vigente
        SELECT NVL(MIN(fecha_cuota),"01/01/1800")
          INTO v_cuotavig
          FROM sd_paginter, sd_fechas
         WHERE fecha_cuota >= fecha_hoy
           AND num_credito = enum_credito;


	IF v_cuotavig = "01/01/1800" THEN
		RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF

	SELECT status_cuota INTO v_status 
	  FROM sd_paginter 
	 WHERE num_credito = enum_credito
	   AND fecha_cuota = v_cuotavig;


	IF v_cuotavig = v_cuota1 THEN
		SELECT fecha_apertura INTO v_fechacalc 
		  FROM sd_maecred
		 WHERE num_credito = enum_credito;

		IF v_fechacalc = v_hoy THEN
			RETURN scod_ret, ax_intdia, ax_diascalc;
		END IF

                SELECT monto_pag INTO ax_intant
                  FROM sd_detcomi
                 WHERE num_credito = enum_credito
                   AND cod_comis = "0004"
                   AND estado_com = "A";


	ELSE
		SELECT MAX(fecha_cuota) INTO  v_fechacalc  
		  FROM sd_pagocapit 
		 WHERE num_credito = enum_credito 
		   AND fecha_cuota < v_cuotavig;
	END IF


	LET ax_diascalc = v_hoy - v_fechacalc ;
	IF ax_diascalc <=0 then
		RETURN scod_ret, ax_intdia, ax_diascalc;
	END IF


	LET ax_intdia = ((v_capital * v_tasa) / v_diasano) * ax_diascalc ;
        LET ax_intdia = ax_intdia - ax_intant;
	
END
	RETURN scod_ret, ax_intdia, ax_diascalc;


END PROCEDURE;