CREATE PROCEDURE "informix".sp_accesodot(vsucursal char(4))

RETURNING char(4), char(50) ;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  vcodret CHAR(4);
DEFINE mensaje CHAR(50);
DEFINE vsucursal2  CHAR(4);

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje;
   END EXCEPTION;
 
LET vcodret = "0000";
LET vsucursal2= vsucursal;

set isolation to dirty read;

update "informix".ss_acceso_sucursales
set acceso = 'V' 
where sucursal = vsucursal2;

LET mensaje='PROCESO EXITOSO';

RETURN vcodret, mensaje;
end;						
END PROCEDURE;