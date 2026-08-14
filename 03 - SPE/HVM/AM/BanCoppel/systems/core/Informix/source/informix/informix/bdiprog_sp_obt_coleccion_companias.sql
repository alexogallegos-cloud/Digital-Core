CREATE PROCEDURE "informix".sp_obt_coleccion_companias()
        RETURNING char(5), char(2), char(30);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener coleccion de compañias de celulares
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 04/12/2008

       DEFINE vcodret   char(5);
       DEFINE cveCompania  char(2);
       DEFINE descCompania char(30);
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, cveCompania, descCompania;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET cveCompania = '';
LET descCompania = '';

BEGIN

	FOREACH
		SELECT cve_compania, descripcion
		INTO cveCompania, descCompania
		FROM bdiprog:pp_companias
		WHERE cve_compania <> '00'
		ORDER BY descripcion

		RETURN vcodret, cveCompania, descCompania WITH RESUME;
	END FOREACH;
END;

END PROCEDURE;