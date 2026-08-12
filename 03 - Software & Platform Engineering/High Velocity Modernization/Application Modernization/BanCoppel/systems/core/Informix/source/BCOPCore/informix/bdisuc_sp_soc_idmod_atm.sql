CREATE PROCEDURE "informix".sp_soc_idmod_atm(vsucursal char(4))

RETURNING char(6) as codret, char(50) as mensaje,char(8) as vidatm;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret 	CHAR(6);
DEFINE mensaje 		CHAR(50);
DEFINE vidatm    CHAR(8);

LET vcodret='';
LET mensaje='';
LET vidatm='';

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje, vidatm;
   END EXCEPTION;
 
 
set isolation to dirty read;

IF EXISTS (select sucursal from bdinteg:"informix".si_sucursales where sucursal=vsucursal) THEN

		select id 
			into vidatm
		from bdisuc:"informix".ss_relacionccid 
		where cc=vsucursal;

	RETURN vcodret, mensaje, vidatm WITH RESUME;
	
ELSE

	LET mensaje='Sucursal no existe favor de validar';
	
	RETURN vcodret, mensaje, vidatm WITH RESUME;

END IF;	

end;						
END PROCEDURE;