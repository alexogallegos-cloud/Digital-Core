CREATE PROCEDURE "informix".sp_obt_coleccion_bancos_portabilidad()
RETURNING char(5), char(3), char(40);
	
	-- Autor: Christian Yair Rojas Velazquez
	-- Fecha: 18/06/2018;


	-- SET DEBUG FILE TO '/tmp/sp_obt_coleccion_bancos_portabilidad.out';
	-- TRACE ON;

    DEFINE vcodret   CHAR(5);
    DEFINE cveBanco  CHAR(3);
    DEFINE descBanco CHAR(40);
	DEFINE sql_err   INTEGER;

	ON EXCEPTION SET sql_err
       		IF sql_err <> 0 THEN
        		LET vcodret = sql_err;
			RETURN vcodret, cveBanco, descBanco;
	       	END IF;
	END EXCEPTION;

	LET vcodret		= '000';
	LET cveBanco	= '';
	LET descBanco	= '';

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		FOREACH

			SELECT banco, descripcion
			INTO cveBanco, descBanco
			FROM bdinteg:si_bancos
			WHERE flg_nomi = '1'
			ORDER BY descripcion

			RETURN vcodret, cveBanco, descBanco WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;