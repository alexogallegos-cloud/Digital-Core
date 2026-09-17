CREATE PROCEDURE "informix".mod_ipab_estrato2()
RETURNING CHAR (5);

DEFINE vcodret        VARCHAR(5);
DEFINE vsec            INTEGER;
DEFINE vrowid          INTEGER;

--BEGIN
--	ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
--		LET vcodret = SQL_ERR;
--		RETURN vcodret;
--	END EXCEPTION;

LET vcodret = "00000";
LET vsec    = 1;

FOREACH

  SELECT rowid
    INTO vrowid
    FROM ipab_estrato2

  UPDATE ipab_estrato2
     SET secuencia = vsec
   WHERE rowid = vrowid;

  LET vsec = vsec + 1;

END FOREACH

return vcodret;

END PROCEDURE;