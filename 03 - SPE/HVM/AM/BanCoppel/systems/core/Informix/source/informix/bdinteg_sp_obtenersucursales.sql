CREATE PROCEDURE "informix".sp_obtenersucursales(iTipoCatalogo INT)

--DATOS A REGRESAR---
RETURNING
CHAR(5),      -- Código de Retorno
CHAR(4),      -- Clave de la Sucursal
CHAR(40);     -- Nombre de la Sucursal
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);	
---------------------------	
DEFINE cClave  CHAR(4);
DEFINE cNombre CHAR(40);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '000';
LET cClave  = '';
LET cNombre = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_ObtenerSucursales.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,
					   cClave,
					   cNombre;
			END IF;
		END EXCEPTION;	  
		
-- Se realiza la consulta por Sucursales		
		IF iTipoCatalogo = 1 THEN
		
			-- Se realiza la búsqueda en la tabla de todas las sucursales de tipo "S" (Activas)	
			FOREACH		
				SELECT {+INDEX(si_sucursales idx_sucursal2)} sucursal, nombre
				  INTO cClave, cNombre		  
				  FROM bdinteg:si_sucursales
				 WHERE empresa = '001'
				   AND sucursal != '0000'				   
				   AND tpo_sucursal = 'S'
				 --ORDER BY sucursal	
				 
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;		
				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF cClave = '' AND cNombre = '' THEN
			
				LET cCodRet = '001';  -- No se encontró información
			
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;
				  
			END IF;		

-- Se realiza la consulta por Tiendas Matriz
		ELSE
		
			-- Se realiza la búsqueda en la tabla de las tiendas matriz
			FOREACH		
				SELECT sucursal, nombre
				  INTO cClave, cNombre		  
				  FROM bdinteg:si_sucursales
				 WHERE tpo_sucursal = 'S'
				   AND tienda_matriz != 0
				 ORDER BY sucursal	
				 
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;		
				  
			END FOREACH;	 
							
			-- Se valida que se haya obtenido información
			IF cClave = '' AND cNombre = '' THEN
			
				LET cCodRet = '001';  -- No se encontró información
			
				RETURN cCodRet,
					   cClave,
					   cNombre	
				  WITH RESUME;
				  
			END IF;			
		
		END IF;
					
	END
END PROCEDURE
DOCUMENT
'Se obtiene listado de Sucursales y Tiendas Matriz',
'FECHA: 20/Abril/2011',
'BD   : bdinteg',
'VER  : 1.0';

CREATE PROCEDURE "informix".sp_insert_autor_privacidad(pempresa CHAR(3), pnumcte CHAR(20), psucursal CHAR(4), 
                                                       prespuesta char(1), pmensaje VARCHAR(200))
   returning char(5);

DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);
DEFINE cNumCte CHAR(20);

LET iSqlErr = 0;
LET cCodRet = "00000";
LET cNumCte = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

BEGIN

    ON EXCEPTION SET iSqlErr   --cacha el error en caso de que exista y regresa un valor predeterminado
        IF iSqlErr <> 0 THEN
            RETURN iSqlErr;
        END IF;
    END EXCEPTION;

    IF pempresa = '' OR pempresa IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pnumcte = '' OR pnumcte IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF psucursal = '' OR psucursal IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF prespuesta = '' OR prespuesta IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    IF pmensaje = '' OR pmensaje IS NULL THEN
       LET cCodRet = '00001';
       RETURN cCodRet;
    END IF;

    INSERT INTO si_autorizacion_privacidad(empresa,numcte,sucursal,respuesta,mensaje,fecha)
    VALUES (pempresa,pnumcte,psucursal,prespuesta,pmensaje,current);

RETURN cCodRet;

END
END PROCEDURE;