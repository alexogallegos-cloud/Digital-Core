CREATE PROCEDURE "informix".sp_soc_datonombresuc_atm(vsucursal char(4))

RETURNING char(4) as codret, char(40) as mensaje, char(70) as nombre_suc;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret 	CHAR(4);
DEFINE  mensaje 	CHAR(40);
DEFINE  vnombre     CHAR(70);

LET vcodret='';
LET mensaje='';
LET vnombre='';

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje, vnombre;
   END EXCEPTION;
 

set isolation to dirty read;

IF EXISTS (SELECT sucursal FROM bdinteg:"informix".si_sucursales WHERE sucursal = vsucursal) THEN
	
		SELECT nombre 
			INTO vnombre
		FROM bdinteg:"informix".si_sucursales 
		WHERE sucursal =vsucursal; 
		
		RETURN vcodret, mensaje, vnombre WITH RESUME;
		
	ELSE
		
		let vcodret='0000';
		let mensaje= 'La sucursal no existe favor de verificar';
		
		RETURN vcodret, mensaje, vnombre WITH RESUME;
		
END IF;


end;						
END PROCEDURE;