CREATE PROCEDURE "informix".sp_catsucursal(
)

RETURNING INTEGER AS X, CHAR(5) AS clave_sucursal, CHAR(55) AS clave_nombre_sucursal;

--****************************************************************************************************
-- DESCRIPCION: Obtiene un catalogo de las sucursales y clave correspondiente que se encuentren en operacion
-- AUTOR : Rochin Rocha Edgar Ivan 
-- FECHA : 08/12/2008
-- BD: Intercard
-- SISTEMA : Reporte Inventario De Tarjetas
--****************************************************************************************************

DEFINE viSqlErr INTEGER ;
DEFINE vsCveSucursal CHAR(5);
DEFINE vsCveSucursalNomSucursal CHAR(55);

LET viSqlErr = 0;
LET vsCveSucursal = '';
LET vsCveSucursalNomSucursal = '';

BEGIN 

ON EXCEPTION SET viSqlErr          --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN viSqlErr,vsCveSucursal, vsCveSucursalNomSucursal;
	END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT '','TODAS LAS SUCURSALES'
		FROM intercard:sucursal UNION 
		SELECT clave_sucursal, clave_sucursal || ' ' || nombre_sucursal
		INTO vsCveSucursal, vsCveSucursalNomSucursal
		FROM intercard:sucursal
		WHERE enoperacion = 'V'
	
	RETURN viSqlErr, vsCveSucursal, vsCveSucursalNomSucursal WITH RESUME;
	
	END FOREACH
END
END PROCEDURE;