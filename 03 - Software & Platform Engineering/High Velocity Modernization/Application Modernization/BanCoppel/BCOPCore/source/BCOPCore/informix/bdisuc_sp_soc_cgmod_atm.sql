CREATE PROCEDURE "informix".sp_soc_cgmod_atm(vsucursal char(4))

RETURNING char(6) as codret, char(50) as mensaje, char(3) as plaza, char(80) as descripcion;

DEFINE  SQL_ERR     INTEGER;
DEFINE  ISAM_ERR    INTEGER;
DEFINE  ERROR_INFO  VARCHAR(80);
DEFINE  vcodret 	CHAR(6);
DEFINE mensaje 		CHAR(50);
DEFINE vplaza_caja   CHAR(3);
DEFINE vdescripcion 	 char(80);


LET vcodret='';
LET mensaje='';
LET vplaza_caja='';
LET vdescripcion='';

BEGIN
   ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
      LET vcodret    = SQL_ERR;
      LET mensaje  = ERROR_INFO;
      RETURN vcodret, mensaje, vplaza_caja, vdescripcion;
   END EXCEPTION;
 
 
set isolation to dirty read;

IF EXISTS (select sucursal from bdinteg:"informix".si_sucursales where sucursal=vsucursal) THEN

		select suc.plaza_cajagen, pl.descripcion 
			into vplaza_caja, vdescripcion
		from bdinteg:"informix".si_sucursales suc, bdinteg:"informix".si_plazas_cajagen pl
		where sucursal=vsucursal
		and suc.plaza_cajagen=pl.codigo_plaza;

	RETURN vcodret, mensaje, vplaza_caja, vdescripcion WITH RESUME;

ELSE 
	 
	 LET mensaje='Sucursal no existe favor de validar';
	 
	 RETURN vcodret, mensaje, vplaza_caja, vdescripcion WITH RESUME;
	
END IF;	
	
end;						
END PROCEDURE;