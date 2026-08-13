CREATE PROCEDURE "informix".sp_metodocaptura()

RETURNING INTEGER AS X, CHAR(2) AS metodocaptura, VARCHAR(30) AS descripcion_metodocaptura;

--****************************************************************************************************
-- DESCRIPCION: Obtiene el catálogo de médotos de captura
-- AUTOR : Rosa Atenea Becerra Burgos
-- FECHA : 29/11/2015
-- BD: Intercard
-- SISTEMA : Módulo de Puntos Compromiso
--****************************************************************************************************

DEFINE viSqlErr INTEGER ;
DEFINE vsMetodoCaptura CHAR(2);
DEFINE vsDescripcion_modocaptura CHAR(30);

LET viSqlErr = 0;
LET vsMetodoCaptura = '';
LET vsDescripcion_modocaptura = '';

BEGIN 

ON EXCEPTION SET viSqlErr     --cacha el error en caso de que exista y regresa un valor predeterminado
	IF viSqlErr <> 0 THEN
	RETURN viSqlErr, vsMetodoCaptura, vsDescripcion_modocaptura;
	END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ ;
	SET LOCK MODE TO WAIT 3;
	FOREACH
		SELECT '','<Seleccione tipo de Captura>'
		FROM intercard:cat_metodocaptura UNION 
		SELECT metodocaptura, metodocaptura || ' - ' ||descripcion_corta
		INTO vsMetodoCaptura, vsDescripcion_modocaptura
		FROM intercard:cat_metodocaptura
		WHERE vigente = 'V'	
		
	RETURN viSqlErr, vsMetodoCaptura, vsDescripcion_modocaptura WITH RESUME;	
	END FOREACH
END
END PROCEDURE;