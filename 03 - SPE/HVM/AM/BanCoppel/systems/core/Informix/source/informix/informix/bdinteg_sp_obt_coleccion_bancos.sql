CREATE PROCEDURE "informix".sp_obt_coleccion_bancos()
RETURNING char(5), char(3), char(40);

	-- Realizo   : Javier Humberto Calderon Zazueta
	-- Actividad : Obetener coleccion de bancos
	-- Solicitó  : Mauricio Leon Ibarra
	-- Fecha     : 04/12/2008

	--Set debug file to '/tmp/ObtieneBancos.out';
	--trace on;


       	DEFINE vcodret   char(5);
       	DEFINE cveBanco  char(3);
       	DEFINE descBanco char(40);
	DEFINE sql_err   integer;

	ON EXCEPTION SET sql_err
       		IF sql_err <> 0 THEN
        		LET vcodret = sql_err;
			RETURN vcodret, cveBanco, descBanco;
	       	END IF;
	END EXCEPTION;

	LET vcodret = '000';
	LET cveBanco = '';
	LET descBanco = '';

set isolation to dirty read;

	BEGIN
		FOREACH
			SELECT banco, descripcion
			INTO cveBanco, descBanco
			FROM bdinteg:si_bancos
			ORDER BY descripcion

			RETURN vcodret, cveBanco, descBanco WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE;