CREATE PROCEDURE "informix".sp_soc_combocc_mod_atm2(pregistros INTEGER, precuperacion INTEGER)
	RETURNING char(6) as codret, char(30) as mensaje,char(4) as cc;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret         CHAR(6);
DEFINE mensaje          CHAR(30);
DEFINE vsucursal    CHAR(4);

LET vcodret='';
LET mensaje='';
LET vsucursal='';

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje, vsucursal;
   END EXCEPTION;
 
 
set isolation to dirty read;

foreach

        SELECT SKIP pregistros FIRST precuperacion sucursal 
                INTO vsucursal 
        FROM bdinteg:"informix".si_sucursales 
        WHERE tpo_sucursal='C'
		order by sucursal

        RETURN vcodret, mensaje,vsucursal WITH RESUME;
        
end foreach;
        
end;                                            
END PROCEDURE
DOCUMENT 'AUTOR: Guadalupe Hernández Pérez',
'FECHA: 19/07/2016',
'DESCRIPCION: SPL que se modifica para agregar parametros de paginación',
'BD: bdisuc';

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