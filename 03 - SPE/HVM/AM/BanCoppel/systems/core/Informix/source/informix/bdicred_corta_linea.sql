CREATE PROCEDURE "informix".corta_linea (plinea varchar(255))
RETURNING CHAR(21);


DEFINE v_caracter 	CHAR(1);
DEFINE v_pos_actual INTEGER;
DEFINE v_pos_blanco INTEGER;
DEFINE v_renglon	VARCHAR(50);


LET v_caracter 		= "";
LET v_pos_actual 	= 1;
LET v_pos_blanco 	= 1;
LET v_renglon		= "";

BEGIN


	IF LENGTH(NVL(plinea,'')) = 0 THEN
		RETURN v_renglon WITH RESUME;
	END IF

	WHILE LENGTH(NVL(plinea,'')) > 0
		----------OBTENGO EL CARACTER ACTUAL
		LET v_caracter = SUBSTR(plinea,v_pos_actual,1);
		----------OBTENGO LA POSICION DE LA ULTIMA PALABRA ENCONTRADA
		IF v_caracter = " " THEN
			LET v_pos_blanco = v_pos_actual;
		END IF;
		
		IF v_pos_actual = 25 THEN
			IF v_caracter = " " THEN
				LET v_renglon = SUBSTR(plinea,1,21);
				LET plinea = SUBSTR(plinea,v_pos_actual + 1 ,LENGTH(plinea));

				LET v_pos_actual 	= 1;
				LET v_pos_blanco 	= 1;

				RETURN v_renglon WITH RESUME;
			ELSE
				LET v_renglon = SUBSTR(plinea,1,v_pos_blanco);
				LET plinea = SUBSTR(plinea,v_pos_blanco + 1 ,LENGTH(plinea));

				LET v_pos_actual 	= 1;
				LET v_pos_blanco 	= 1;

			    RETURN v_renglon WITH RESUME;
			END IF
		END IF

		IF LENGTH(NVL(plinea,'')) <= 25 THEN
			LET v_renglon = plinea;
			LET plinea = '';

			LET v_pos_actual 	= 1;
			LET v_pos_blanco 	= 1;

		    RETURN v_renglon WITH RESUME;
		END IF

		LET v_pos_actual =v_pos_actual + 1;
	END WHILE


END
END PROCEDURE;