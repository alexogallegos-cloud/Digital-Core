CREATE PROCEDURE "informix".sp_obt_valoriva(pCodParametro smallint)
        RETURNING char(5), money(14,2);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener valor de IVA
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 14/12/2009

       DEFINE vcodret   char(5);
       DEFINE valorIVA  money(14,2);
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, valorIVA;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vcodret = '000';
LET valorIVA = 0;

BEGIN

		SELECT valor
		INTO valorIVA
		FROM bdinteg:si_param
		WHERE cod_param = pCodParametro;
		

		RETURN vcodret, valorIVA;
END;

END PROCEDURE;