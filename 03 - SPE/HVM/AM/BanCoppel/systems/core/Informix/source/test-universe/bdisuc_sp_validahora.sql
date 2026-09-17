CREATE PROCEDURE "informix".sp_validahora(pempresa char(3),psuc char(4))
RETURNING CHAR(5);

DEFINE vcodret 	CHAR(5);
DEFINE vsqlerr 	INTEGER;
DEFINE vhora 	CHAR(2);

LET vhora   = '';
LET vcodret = '00000';

--SET debug file to "/home/sysIFx/Ever/sp_cancelar_solicitud_dota.out";
--TRACE ON;

BEGIN
   ON EXCEPTION SET vsqlerr
      IF vsqlerr <> 0 THEN
         LET vcodret = vsqlerr;
         RETURN vcodret;
      END IF;
   END EXCEPTION;
   
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

    SELECT limit 1 TO_CHAR(EXTEND(CURRENT, HOUR TO SECOND),'%H') 
	INTO vhora FROM bdisuc:"informix".ss_operaciones;
	--WHERE folio_oper = pfolio;
	
	IF vhora >= 15 THEN
		LET vcodret= '00002';
	END IF;
    RETURN vcodret;
END 
END PROCEDURE;