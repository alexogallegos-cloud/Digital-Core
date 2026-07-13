CREATE PROCEDURE "informix".sp_sucursal_coordenadas(pClaveBusqueda VARCHAR(18))

RETURNING CHAR(5), CHAR(10), CHAR(11);
-----Variables-----
DEFINE cSeccion 	CHAR(4);
DEFINE cSucursal 	CHAR(5);

DEFINE codret		CHAR(5);
DEFINE cLatitud		CHAR(10);
DEFINE cLongitud	CHAR(11);

DEFINE vsqlerr     	INTEGER;
DEFINE error_info   CHAR(40);
DEFINE isam_err     SMALLINT;

LET codret = '00000';
LET cLatitud = '';
LET cLongitud = '';

LET vsqlerr = 0;
LET error_info = 'Iniciando ejecucion';
LET isam_err = 0;
	
BEGIN
	--LET  latitud = '-15.434821248';
	--LET  longitud = '95.2646215';
	ON EXCEPTION SET vsqlerr, isam_err, error_info
		IF vsqlerr <> 0 THEN
			LET codret = vsqlerr;
			LET isam_err = isam_err;
			LET error_info = error_info;
			
			RETURN codret, '', '';
		END IF;
	END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
		
	LET cSeccion = LEFT(pClaveBusqueda, 4); --Toma los primeros 4 caracteres del lado izquierdo
	
	SELECT FIRST 1 sucursal INTO cSucursal FROM bdinteg:si_seccion_sucursal WHERE seccion = cSeccion;
	
	SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = cSucursal AND tipo='S';
	
	IF((cLatitud IS NULL OR cLatitud = '' OR cLatitud='Null') OR (cLongitud IS NULL OR cLongitud = '' OR cLongitud='Null')) THEN
		SELECT latitud, longitud INTO cLatitud, cLongitud FROM bdinteg:si_ptf WHERE id_ptf = '6700' AND tipo='S';
	END IF;
	

    RETURN codret, cLatitud, cLongitud;
	 
END;
END PROCEDURE;