CREATE PROCEDURE "informix".sp_bitacora_atm(vbitacora char(15),  
											vsucursal char(4), 
											vidatm char(8), 
											vcajagen char(3), 
											vusuario char(8))

RETURNING char(6), char(50);

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret 	CHAR(6);
DEFINE  mensaje 	CHAR(50);
DEFINE  vfecha       Date;

LET vcodret='';
LET mensaje='';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje;
   END EXCEPTION;
 

set isolation to dirty read;

	SELECT fecha_hoy 
		into vfecha
	FROM bdinteg:si_fechas;
	

	INSERT INTO  bdisuc:"informix".ss_bitacora_atm
		(cc_atm, id_atm, accion, cc_cajageneral, fecha_movimiento, usuario)
	values
		(vsucursal, vidatm, vbitacora, vcajagen, current, vusuario);


	LET mensaje= 'Proceso Terminado Correctamente';
	
	RETURN vcodret, mensaje;
	
		
end;						
END PROCEDURE;