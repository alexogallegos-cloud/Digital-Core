CREATE PROCEDURE "informix".arr_nouno()
RETURNING CHAR(5);


-- DEFINE VARIABLES
DEFINE v_credito CHAR(20);
DEFINE v_fechaap DATE;
DEFINE ax_codret CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_tpcred CHAR(2);
DEFINE v_mesini DATETIME YEAR TO MONTH;
DEFINE v_fechaini DATE;
DEFINE v_fold DATE;
DEFINE vrowp INTEGER;
DEFINE vrowi INTEGER;
DEFINE v_dia  SMALLINT;
DEFINE v_prod CHAR(4);
DEFINE v_plazo SMALLINT;
DEFINE v_montooto MONEY(14,2);
DEFINE v_tasa DECIMAL(21,6);
DEFINE v_cuota MONEY(14,2);
DEFINE ax_pasodec DECIMAL(21,6);
DEFINE ax_pasoch  CHAR(10);

-- ASIGNA VALORES
LET ax_codret ="00000";
LET vsqlerr = 0;

-- CONTROL DE ERRORES
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET ax_codret=vsqlerr;
      RETURN ax_codret;
   END IF;
END EXCEPTION;




-- PROGRAMA PRINCIPAL

		BEGIN WORK;

	FOREACH WITH HOLD 
		SELECT "1" || LPAD(TRIM(credito),8,"0") || seg || 
			LPAD(TRIM(tipo),2,"0") || "001",
		       SUBSTR(fecha,5,2) || "/" || SUBSTR(fecha,7,2) || "/" ||
		       SUBSTR(fecha,1,4), dia
		  INTO v_credito, v_fechaap, v_dia
		  FROM nouno

		LET v_mesini = v_fechaap;
		LET v_mesini = v_mesini + 1 UNITS MONTH;
		IF MONTH(v_mesini)=2 AND v_dia > 28 THEN
		  LET v_fechaini = MDY(MONTH(v_mesini), 28,YEAR(v_mesini));
	        ELSE	
		  LET v_fechaini = MDY(MONTH(v_mesini), v_dia,YEAR(v_mesini));
		  IF v_fechaap - v_fechaini < 30  THEN
			LET v_fechaini = v_fechaini + 1 UNITS MONTH;
		  END IF
		END IF

		set constraints all deferred;
		FOREACH WITH HOLD
			SELECT a.fecha_cuota, a.rowid, b.rowid 
			  INTO v_fold, vrowp, vrowi
			  FROM sd_pagocapit a, sd_paginter b
			 WHERE a.num_credito = v_credito
			   AND a.num_credito = b.num_credito
			   AND a.fecha_cuota = b.fecha_cuota
			 ORDER BY 1


			UPDATE sd_pagocapit SET fecha_cuota = v_fechaini
			 WHERE num_credito = v_credito 
			   AND rowid = vrowp;

			UPDATE sd_paginter SET fecha_cuota = v_fechaini
			 WHERE num_credito = v_credito 
			   AND rowid = vrowi;
	
			LET v_fold = v_fold;	
			IF DAY(v_fechaini) > 28 AND MONTH(v_fechaini) = 1 THEN
				--LET v_dia = 28;
				LET v_mesini = v_fechaini;
				LET v_mesini = v_mesini + 1 UNITS MONTH;
				LET v_fechaini = MDY(MONTH(v_mesini),28,
			 			 YEAR(v_mesini));
			ELSE
				LET v_fechaini = v_fechaini + 1 UNITS MONTH;	
				IF v_dia <> DAY(v_fechaini) THEN
				  LET v_fechaini = MDY(MONTH(v_fechaini),v_dia,
						     YEAR(v_fechaini));
				END IF
			END IF

		END FOREACH

			--COMMIT WORK;

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;