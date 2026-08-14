CREATE PROCEDURE "informix".sp_obt_rfccte(pNumCte char(20))
        RETURNING char(5), char(13);

    -- Realizo   : Javier Humberto Calderon Zazueta
    -- Actividad : Obetener rfc del cliente
    -- Solicitó  : Mauricio Leon Ibarra
    -- Fecha     : 20/12/2008

       DEFINE vcodret   char(5);
       DEFINE vRfc  char(13);
	   DEFINE sql_err   integer;
	   DEFINE vRfc_alterno char(13);

ON EXCEPTION SET sql_err
       IF sql_err <> 0 THEN
        LET vcodret = sql_err;
        RETURN vcodret, vRfc;
       END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

LET vcodret = '000';
LET vRfc = '';
LET vRfc_alterno = '';

BEGIN

		SELECT rfc, rfc_alterno
		INTO vRfc, vRfc_alterno
		FROM bdinteg:si_cliente
		WHERE numcte = pNumCte;

		IF vRfc_alterno is not null and vRfc_alterno <> "" THEN
           LET vRfc = vRfc_alterno;
        END IF;	

		RETURN vcodret, vRfc;
END;

END PROCEDURE;