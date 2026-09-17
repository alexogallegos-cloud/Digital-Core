CREATE PROCEDURE "informix".sp_traeatms(pempresa   CHAR(3),
                                    psucursal  CHAR(4),
                                    pregistro  SMALLINT)

RETURNING CHAR(5),CHAR(4),CHAR(40);

DEFINE vcodret          CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
DEFINE vnumatm          CHAR(4);
DEFINE vnombreatm       CHAR(40);
 
LET vcodret    = "000";
LET vnumatm    = "";
LET vnombreatm = "";

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

BEGIN

ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
      RETURN vcodret,vnumatm,vnombreatm;
   END IF;
END EXCEPTION;

--SET debug file to "/tmp/sp_atms.out";
--trace on;

    IF pempresa = '0' or pempresa = '' or  psucursal = '0' or psucursal = '' then
          LET vcodret = "110";
    END IF;
	
	
	
	if pregistro=1 then 
    FOREACH
        SELECT s.sucursal, substr(s.nombre, 4)
        INTO vnumatm, vnombreatm
        FROM bdisuc:"informix".ss_atms_sucursal a, bdinteg:"informix".si_sucursales s
        WHERE s.sucursal = a.cod_atm  
          AND s.empresa = pempresa
		  and trim(s.plaza_cajagen) = trim(psucursal) 
          and s.sucursal in (select trim(cc) from bdisuc:ss_relacionccid)
        ORDER BY s.nombre

        RETURN vCodRet,vnumatm,vnombreatm  WITH resume;

    END FOREACH;
	elif pregistro=0 THEN
	FOREACH 
		SELECT codigo_plaza,     descripcion  
		INTO vnumatm, vnombreatm	
		FROM bdinteg:si_plazas_cajagen 
		order by 2
				
        RETURN vCodRet,vnumatm,vnombreatm  WITH resume;

    END FOREACH;
	
	
	end if 
	
END;
END PROCEDURE;