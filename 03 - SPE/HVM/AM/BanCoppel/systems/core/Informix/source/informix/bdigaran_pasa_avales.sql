CREATE PROCEDURE "informix".pasa_avales()
RETURNING CHAR(5);

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE scod_ret     CHAR(5);
DEFINE vsqlerr      INTEGER;
DEFINE v_credito    CHAR(20);
DEFINE v_aval1      CHAR(20);
DEFINE v_aval2      CHAR(20);
DEFINE v_aval3      CHAR(20);
DEFINE v_aval4      CHAR(20);
DEFINE v_secuencia  INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET scod_ret     = "00000";
LET vsqlerr      = 0;

-- ****************************************************************************
-- *                        CONTROL DE ERRORES                                *
-- ****************************************************************************
BEGIN
ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET scod_ret=vsqlerr;
      RETURN scod_ret;
   END IF;
END EXCEPTION;


-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************

	FOREACH SELECT num_solicitud, desc1, NVL(desc2,""), NVL(desc3,""), 
			NVL(desc4,"")
		  INTO v_credito, v_aval1, v_aval2, v_aval3, v_aval4
		  FROM bdisolic:ss_bienes_deudas
		 WHERE cod_concepto ="063"
		   AND desc1 <> ""




		SELECT COUNT(*) INTO v_secuencia
		  FROM sg_aval
		 WHERE num_credito = v_credito;

		IF v_secuencia > 0 THEN
			CONTINUE FOREACH;
		END IF

		LET v_secuencia = v_secuencia + 1;

         	INSERT INTO sg_maegaran
                	(empresa, num_credito, id_garan, cod_garan, grupo_garan,
                 	divisa, val_garantot, statusgar)
        	VALUES
                	("001", v_credito, v_secuencia, "0001", "0007",
                 	"01", 0, "V");


		INSERT INTO sg_aval 
			(empresa, num_credito, id_garan, apellido_p)
		     VALUES
			("001", v_credito, v_secuencia, v_aval1);

		IF v_aval2 <> "" then
                	LET v_secuencia = v_secuencia + 1;

                	INSERT INTO sg_maegaran
                        	(empresa, num_credito, id_garan, cod_garan, 
				grupo_garan, divisa, val_garantot, statusgar)
                	VALUES
                        	("001", v_credito, v_secuencia, "0001", "0007",
                        	 "01", 0, "V");

                	INSERT INTO sg_aval
                        	(empresa, num_credito, id_garan, apellido_p)
                     	VALUES
                        	("001", v_credito, v_secuencia, v_aval2);
		END IF

                IF v_aval3 <> "" then
                	LET v_secuencia = v_secuencia + 1;

                        INSERT INTO sg_maegaran
                                (empresa, num_credito, id_garan, cod_garan,
                                grupo_garan, divisa, val_garantot, statusgar)
                        VALUES
                                ("001", v_credito, v_secuencia, "0001", "0007",
                                 "01", 0, "V");
                	INSERT INTO sg_aval
                        	(empresa, num_credito, id_garan, apellido_p)
                     	VALUES
                        	("001", v_credito, v_secuencia, v_aval3);
		 END IF

                 IF v_aval4 <> "" then
 	              LET v_secuencia = v_secuencia + 1;

                        INSERT INTO sg_maegaran
                                (empresa, num_credito, id_garan, cod_garan,
                                grupo_garan, divisa, val_garantot, statusgar)
                        VALUES
                                ("001", v_credito, v_secuencia, "0001", "0007",
                                 "01", 0, "V");
 	               INSERT INTO sg_aval
        	                (empresa, num_credito, id_garan, apellido_p)
                	     VALUES
                        	("001", v_credito, v_secuencia, v_aval4);

		 END IF

	END FOREACH



END
        RETURN scod_ret;


END PROCEDURE;