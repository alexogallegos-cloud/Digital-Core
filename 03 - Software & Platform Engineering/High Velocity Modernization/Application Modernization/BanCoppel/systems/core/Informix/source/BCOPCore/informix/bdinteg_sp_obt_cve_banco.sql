CREATE PROCEDURE "informix".sp_obt_cve_banco(pCveBanco char(3))
        RETURNING char(5), integer;

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener clave de 5 digitos de banco
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 18/03/2009

       DEFINE vcodret   char(5);
       DEFINE vCvecesif  integer;
	   DEFINE sql_err   integer;

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vCvecesif;
       END IF;
END EXCEPTION;

LET vcodret = '000';
LET vCvecesif = 0;

BEGIN

		SELECT cvecesif INTO vCvecesif FROM bdinteg:si_bancos WHERE banco = pCveBanco ;
        IF vCvecesif IS NULL THEN
			LET vCvecesif = 0;
        END IF;

		RETURN vcodret, vCvecesif;
END;

END PROCEDURE;