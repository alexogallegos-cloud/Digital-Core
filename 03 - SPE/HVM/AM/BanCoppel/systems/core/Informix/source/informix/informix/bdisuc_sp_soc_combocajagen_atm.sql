CREATE PROCEDURE "informix".sp_soc_combocajagen_atm()
							
RETURNING CHAR(6) as codret,CHAR(30) as mensaje,CHAR(3) as codigo_plaza, CHAR(40) as descripcion;

DEFINE SQL_ERR     		INTEGER;
DEFINE ISAM_ERR    		INTEGER;
DEFINE ERROR_INFO  		VARCHAR(80);
DEFINE vcodret 			CHAR(6);
DEFINE mensaje 			CHAR(30);
DEFINE vcodigo_plaza  	 CHAR(3);
DEFINE vdescripcion     CHAR(40);

LET vcodret='';
LET mensaje='';
LET vcodigo_plaza='';
LET vdescripcion='';

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje,vcodigo_plaza, vdescripcion;
   END EXCEPTION;
 

set isolation to dirty read;

foreach
	SELECT codigo_plaza, descripcion 
		INTO vcodigo_plaza, vdescripcion
	FROM bdinteg:"informix".si_plazas_cajagen

	RETURN vcodret, mensaje,vcodigo_plaza, vdescripcion WITH RESUME;
end foreach;
	
end;						
END PROCEDURE;