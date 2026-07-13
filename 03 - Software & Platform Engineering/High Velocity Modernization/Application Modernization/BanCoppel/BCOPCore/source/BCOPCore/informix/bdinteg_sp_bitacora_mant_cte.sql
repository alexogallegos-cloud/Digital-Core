CREATE PROCEDURE "informix".sp_bitacora_mant_cte (pSuc CHAR(4), pGte CHAR(8), pUsuario CHAR(8), pNumcte CHAR(9), pFecha DATE, pIp CHAR(16))
       RETURNING CHAR(5) as codret;

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;


LET vcodret = '00000';
LET vsqlerr = 0;

BEGIN
        ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
	
	if pNumcte <>'' then
	   INSERT INTO informix.bitacora_mantenimiento(sucursal, gerente, usuario_modifica, numcte, fecha_modifica, ip_maquina) 
              VALUES(pSuc, pGte, pUsuario, pNumcte, CURRENT, pIp);

	   LET vcodret='00000';
       RETURN vcodret;
	else
	  LET vcodret='00001';
      RETURN vcodret;
	end if;
END;
END PROCEDURE;