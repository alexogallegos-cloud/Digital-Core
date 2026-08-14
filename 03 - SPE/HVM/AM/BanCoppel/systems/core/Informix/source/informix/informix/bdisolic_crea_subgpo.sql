CREATE PROCEDURE "informix".crea_subgpo(o_numgpo      CHAR(20),
                          o_subgrupo    CHAR(20),
			  o_descripcion CHAR(40),
                          o_direccion   char(40),
                          o_colonia     char(40),
                          o_delegacion  char(40),
		          o_tpmov       CHAR(1))
RETURNING CHAR(5);
-- ############################################################################
-- #                        Definicion de Variables                           #
-- ############################################################################
DEFINE v_codret CHAR(5);
DEFINE sqlerr   INTEGER;
DEFINE v_grupo  SMALLINT;
DEFINE v_subgpo SMALLINT;
DEFINE v_existe MONEY(14,2);

-- ############################################################################
-- #                        Asignacion de Variables                           #
-- ############################################################################
LET v_codret = "000";
LET sqlerr   = 0;
LET v_grupo  = 0;
LET v_subgpo = 0;
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

SET DEBUG FILE TO "crea_subgpo.out";
TRACE ON;

-- ############################################################################
-- #                              Codigo Principal                            #
-- ############################################################################

IF o_tpmov = "A" THEN
	SELECT codigo_grupo,codigo_subgpo INTO v_grupo,v_subgpo
  	  FROM bdinteg:si_subgruposlin
 	 WHERE codigo_grupo = o_numgpo
         AND codigo_subgpo = o_subgrupo;

	IF v_grupo IS NULL OR v_grupo = 0 THEN
	   INSERT INTO bdinteg:si_subgruposlin
	    VALUES(o_numgpo, o_subgrupo, o_descripcion, o_direccion,o_colonia,o_delegacion);
	ELSE
		LET v_codret = "357"; -- EL GRUPO YA EXISTE EN EL CATALOGO.
		RETURN v_codret;
	END IF

END IF

IF o_tpmov = "B" THEN
		DELETE FROM bdinteg:si_subgruposlin WHERE codigo_grupo = o_numgpo
                AND codigo_subgpo = o_subgrupo;
END IF

IF o_tpmov = "C" THEN
		UPDATE bdinteg:si_subgruposlin
		   SET (nombre,direccion,nombre_repres,email) =
		       (o_descripcion, o_direccion,o_colonia,o_delegacion)
	 	 WHERE codigo_grupo = o_numgpo
                 AND codigo_subgpo = o_subgrupo;
END IF


END

RETURN v_codret;
END PROCEDURE;