CREATE PROCEDURE "informix".sp_valida_suc2(vsucursal char(4))

RETURNING char(4), char(50),char(30) ;

DEFINE  SQL_ERR          INTEGER;
DEFINE  ISAM_ERR         INTEGER;
DEFINE  ERROR_INFO       VARCHAR(80);
DEFINE  vcodret 		 CHAR(4);
DEFINE vmensaje 		 CHAR(50);
DEFINE vsucursal2  		 CHAR(4);
DEFINE cNombreSucursal   CHAR(30);
DEFINE iNoRegistros      INTEGER;

LET vcodret 		= '0000';
LET vsucursal2		= vsucursal;
LET vmensaje 		='';
LET cNombreSucursal	='';
LET iNoRegistros 	= 0;
 
BEGIN

   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET vmensaje  = ERROR_INFO;
      RETURN vcodret, vmensaje,cNombreSucursal;
   END EXCEPTION;
   
 -- set debug file to "valida.out";
 --TRACE ON;

SET ISOLATION TO dirty READ;

SELECT nom_suc 
INTO   cNombreSucursal
FROM bdisuc:"informix".ss_acceso_sucursales
WHERE sucursal = vsucursal2;

LET iNoRegistros = DBINFO('sqlca.sqlerrd2');

IF iNoRegistros = 0 THEN
	LET vcodret='0001';  --No existe   
	LET vmensaje = 'Sucursal no existe favor de validar';  
END IF;

RETURN vcodret, vmensaje,cNombreSucursal;
        
END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 23/06/2016',
'MODULO: CAJA GENERAL',
'FUNCIONALIDAD: HORARIO DOTACION SUCURSAL',
'DESCRIPCION: Se agrega parametro de salida nombre de sucursal',
'BD: bdisuc';

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