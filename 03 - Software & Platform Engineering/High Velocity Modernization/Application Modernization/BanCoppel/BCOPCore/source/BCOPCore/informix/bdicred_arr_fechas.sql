CREATE PROCEDURE "informix".arr_fechas()
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

--	DELETE FROM contador WHERE 1=1;
--	INSERT INTO contador VALUES(0);

	CREATE TEMP TABLE no_jalo(credito CHAR(20), codigo CHAR(5));

{       SELECT a.num_credito , min(fecha_cuota) fecha
         FROM sd_pagocapit a, sd_maecred b
        WHERE a.num_credito = b.num_credito
          and fecha_cuota - fecha_apertura < 30
	  AND status_cred <> "CC"
	group by 1
        INTO TEMP fechas;}


	FOREACH WITH HOLD SELECT b.num_credito, fecha_apertura, cod_tipcred
		  INTO v_credito, v_fechaap, v_tpcred
		  FROM sd_maecred b, sd_definicion c
		 WHERE c.num_producto = b.num_producto
		   AND b.num_credito ="100002273429001"

--		UPDATE contador set cuenta = cuenta + 1;

		LET v_mesini = v_fechaap;
		IF DAY(v_fechaap) > 1 THEN
			LET v_mesini = v_mesini + 2 UNITS MONTH;
				--LET v_mesini = 1;
		        --LET v_fechaap = v_fechaap + 2 UNITS MONTH;
		ELSE
			LET v_mesini = v_mesini + 1 UNITS MONTH;
				--LET v_mesini = 1;
		        --LET v_fechaap = v_fechaap + 1 UNITS MONTH;
		END IF
		IF v_tpcred = "01" OR v_tpcred ="04" THEN
			LET v_fechaini = MDY(MONTH(v_mesini),"01",
			 		 YEAR(v_mesini));
		ELSE
			SELECT MIN(fecha_cuota) INTO v_fechaini
			  FROM sd_pagocapit
			 WHERE num_credito = v_credito;
			LET v_dia = DAY(v_fechaini);
			IF v_dia > 28 AND MONTH(v_mesini) = 2 THEN
				LET v_dia = 28;
			END IF
			IF v_dia = 31 THEN LET v_dia = 30; END IF
			LET v_fechaini = MDY(MONTH(v_mesini),v_dia,
			 		 YEAR(v_mesini));
		END IF
			
			

		BEGIN WORK;
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
				LET v_dia = 28;
				LET v_mesini = v_fechaini;
				LET v_mesini = v_mesini + 1 UNITS MONTH;
				LET v_fechaini = MDY(MONTH(v_mesini),v_dia,
			 			 YEAR(v_mesini));
			ELSE
				LET v_fechaini = v_fechaini;
				LET v_fechaini = v_fechaini + 1 UNITS MONTH;	
			END IF

		END FOREACH

{		SELECT MIN(fecha_cuota) INTO v_fechaini
		  FROM sd_pagocapit 
		 WHERE num_credito  = v_credito;
		 IF DAY(v_fechaini) = 30 OR DAY(v_fechaini) = 31 THEN
		  UPDATE sd_pagocapit 
		    SET fecha_cuota = fecha_cuota + 30
		  WHERE num_credito = v_credito;

		  UPDATE sd_paginter 
		    SET fecha_cuota = fecha_cuota + 30
		  WHERE num_credito = v_credito;
		 ELSE
		  UPDATE sd_pagocapit 
		    SET fecha_cuota = fecha_cuota + 1 UNITS MONTH
		  WHERE num_credito = v_credito;

		  UPDATE sd_paginter 
		    SET fecha_cuota = fecha_cuota + 1 UNITS MONTH
		  WHERE num_credito = v_credito;
		END IF}

                SELECT num_producto, plazo, monto_otorgado,tasa_interes,
                       (SELECT a.monto_cuota + b.monto_cuota
                          FROM sd_pagocapit a, sd_paginter b
                         WHERE a.num_credito = b.num_credito
                           AND a.fecha_cuota = b.fecha_cuota
                           AND a.fecha_cuota = (SELECT MIN(fecha_cuota)
                                                FROM sd_pagocapit
                                               WHERE num_credito = v_credito)
                          AND a.num_credito = v_credito)
                  INTO v_prod, v_plazo, v_montooto, v_tasa, v_cuota
                  FROM sd_maecred f, sd_maesdos g
                 WHERE f.num_credito = g.num_credito
                   AND f.num_credito = v_credito;

                EXECUTE PROCEDURE renivela_ax("001"
                                             ,v_prod
                                             ,v_plazo
                                             ,v_montooto
                                             ,v_tasa
                                             ,v_credito
                                             ,v_cuota)
                   INTO ax_codret, ax_pasodec, ax_pasodec, ax_pasodec,
                        ax_pasoch, ax_pasoch, ax_pasodec;
                IF ax_codret <> "00000" THEN
                    --    INSERT INTO no_jalo VALUES (v_credito, ax_codret);
                        ROLLBACK WORK;
                        CONTINUE FOREACH;
                END IF

		EXECUTE PROCEDURE clasica_sdosp(v_credito, "11/01/2004")
		   INTO ax_codret;

		IF ax_codret <> "00000" THEN
		--	INSERT INTO no_jalo VALUES (v_credito, ax_codret);
			ROLLBACK WORK;
		ELSE
			COMMIT WORK;
		END IF

	END FOREACH

END
	RETURN ax_codret;
END PROCEDURE;