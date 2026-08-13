CREATE PROCEDURE "informix".crea_gpo(o_numgpo      CHAR(20),
			  o_descripcion CHAR(60),
			  o_tpmov       CHAR(1),
			  o_contabiliza CHAR(1))
RETURNING CHAR(5);
-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE v_codret CHAR(5);
DEFINE sqlerr   INTEGER;
DEFINE v_grupo  SMALLINT;
DEFINE v_existe MONEY(14,2);

-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################
LET v_codret = "000";
LET sqlerr   = 0;
LET v_grupo  = 0;
LET v_existe = 0;

-- ############################################################################
-- #                    Control de Errores para INFORMIX                      #
-- ############################################################################
BEGIN
 ON EXCEPTION
      SET sqlerr
      LET v_codret = sqlerr;
      RETURN v_codret;
 END EXCEPTION;


-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

IF o_tpmov = "A" THEN
	SELECT num_gpo INTO v_grupo
  	  FROM lineas:sl_catgrupos
 	 WHERE num_gpo = o_numgpo;
	IF v_grupo IS NULL OR v_grupo = 0 THEN

	   INSERT INTO lineas:sl_catgrupos 
	    VALUES(o_numgpo, o_descripcion, o_contabiliza);

	ELSE
		LET v_codret = "357"; -- EL GRUPO YA EXISTE EN EL CATALOGO.
		RETURN v_codret;
	END IF

END IF

IF o_tpmov = "B" THEN
	SELECT linea_util INTO v_existe
	  FROM lineas:sl_grupos
	 WHERE num_gpo = o_numgpo;
	IF v_existe > 0 THEN
		LET v_codret = "334";
		RETURN v_codret;
	ELSE
		DELETE FROM lineas:sl_catgrupos WHERE num_gpo = o_numgpo;
	END IF
END IF

IF o_tpmov = "C" THEN
	SELECT linea_util INTO v_existe
	  FROM lineas:sl_grupos
	 WHERE num_gpo = o_numgpo;
	IF v_existe > 0 THEN
		LET v_codret = "334";
		RETURN v_codret;
	ELSE
		UPDATE lineas:sl_catgrupos 
		   SET (nombre_grupo, contabiliza) = 
		       (o_descripcion, o_contabiliza)
	 	 WHERE num_gpo = o_numgpo;
	END IF
END IF


END

RETURN v_codret;
END PROCEDURE;