CREATE PROCEDURE "informix".sp_soc_combocc_atm()

RETURNING char(6) as codret,char(30) as mensaje,char(4) as cc;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret 	CHAR(6);
DEFINE mensaje 		CHAR(30);
DEFINE vsucursal    CHAR(4);

LET vcodret= '0';
LET mensaje='';
LET vsucursal='';


BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje,vsucursal;
   END EXCEPTION;
 
 
set isolation to dirty read;

foreach

	SELECT sucursal 
		INTO vsucursal 
	FROM bdinteg:"informix".si_sucursales 
	WHERE tpo_sucursal='N' 
	AND sucursal >='5009' AND sucursal <'8000'

	RETURN vcodret, mensaje, vsucursal WITH RESUME;
	
end foreach;

end;						
END PROCEDURE;