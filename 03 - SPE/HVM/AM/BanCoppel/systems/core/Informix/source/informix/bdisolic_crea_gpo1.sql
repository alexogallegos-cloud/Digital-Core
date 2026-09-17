CREATE PROCEDURE "informix".crea_gpo1(o_numgpo      CHAR(20),
			  o_descripcion CHAR(40),
                          o_direccion   char(40),
                          o_colonia     char(40),
                          o_delegacion  char(40),
                          o_pais        smallint,
                          o_estado      smallint,
                          o_ciudad      smallint,
		          o_tpmov       CHAR(1))
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
	SELECT grupo INTO v_grupo
  	  FROM bdicent:si_grupos
 	 WHERE grupo = o_numgpo;
	IF v_grupo IS NULL OR v_grupo = 0 THEN
	   INSERT INTO bdicent:si_grupos
	    VALUES(o_numgpo, o_descripcion, o_direccion,o_colonia,o_delegacion,o_pais,o_estado,o_ciudad);
	ELSE
		LET v_codret = "357"; -- EL GRUPO YA EXISTE EN EL CATALOGO.
		RETURN v_codret;
	END IF

END IF

IF o_tpmov = "B" THEN
		DELETE FROM bdicent:si_grupos WHERE grupo = o_numgpo;
END IF

IF o_tpmov = "C" THEN
		UPDATE bdicent:si_grupos
		   SET (nombre,direccion,colonia,deleg_o_municipio,pais,estado,ciudad) =
		       (o_descripcion, o_direccion,o_colonia,o_delegacion,o_pais,o_estado,o_ciudad)
	 	 WHERE grupo = o_numgpo;
END IF


END

RETURN v_codret;
END PROCEDURE;