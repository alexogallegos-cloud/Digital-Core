CREATE PROCEDURE "informix".sp_obt_comision(pCveComision char(274))
        RETURNING char(5), money(14,2);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener comision
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 17/12/2008

       DEFINE vcodret   char(5);
       DEFINE comision  money(14,2);
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, comision;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vcodret = '000';
LET comision = 0;

BEGIN

		SELECT mnycomision
		INTO comision
		FROM bdispei:tblcomision
		WHERE vchrcvecomision = pCveComision;
		
		LET comision = 0;
		

		RETURN vcodret, comision;
END;

END PROCEDURE;