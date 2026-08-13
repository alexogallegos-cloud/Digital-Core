CREATE PROCEDURE "informix".sp_soc_combomov_atm()

RETURNING char(6) as codret, char(30) as mensaje,char(15) as movimiento;

DEFINE  SQL_ERR      INTEGER;
DEFINE  ISAM_ERR     INTEGER;
DEFINE  ERROR_INFO   VARCHAR(80);
DEFINE  vcodret 	 CHAR(6);
DEFINE  mensaje 	 CHAR(30);
DEFINE  vmovimiento  CHAR(15);

LET vcodret='';
LET mensaje='';
LET vmovimiento='';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje, vmovimiento;
   END EXCEPTION;
 

set isolation to dirty read;

foreach
	select valor 
		INTO vmovimiento
	from bdisuc:"informix".ss_param_cajagen 
	where descripcion = 'Combo Movimiento Pantalla ATM'
	
	RETURN vcodret, mensaje, vmovimiento WITH RESUME;
	
end foreach;
	
end;						
END PROCEDURE;