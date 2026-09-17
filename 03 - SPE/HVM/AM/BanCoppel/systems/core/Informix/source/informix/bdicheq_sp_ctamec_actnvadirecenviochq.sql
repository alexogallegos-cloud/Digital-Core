CREATE PROCEDURE "informix".sp_ctamec_actnvadirecenviochq(pEmpresa CHAR(3), pCuenta CHAR(20), pDireccEnvio CHAR(2))

RETURNING 
	CHAR(6)   AS CodRet,
	CHAR(60)  AS Mensaje;

-- ****************************************************************************
-- Declaracion de variables
-- ****************************************************************************
	
DEFINE vCodRet            CHAR(6);
DEFINE cMensaje           CHAR(60);
DEFINE sql_err, isam_err  INT;   

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
	
LET vCodRet        = "000";
LET cMensaje       = "Actualizacion Terminada";

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 --SET DEBUG FILE TO "/home/sysifx/vlv/sp_ctamec_actnvadirecenviochq.out";
 --TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err,isam_err
		IF sql_err <> 0 OR isam_err <> 0 THEN
			LET vCodRet = sql_err;
			
			RETURN vCodRet,cMensaje;
		END IF;
	END EXCEPTION;
	
	-- VALIDACION DE PARAMETROS
	IF pEmpresa = '' OR pCuenta = '' OR pDireccEnvio = '' THEN
	   LET vCodRet = '002';
	   LET cMensaje = 'Faltan parametros para su ejecucion.';
	   RETURN vCodRet,cMensaje;
	END IF;
	
	-- SE REALIZA FORMATEO DE LOS PARAMETROS
	LET pDireccEnvio = pDireccEnvio::SMALLINT;
	LET pCuenta = TRIM(pCuenta);
    
	IF EXISTS (SELECT direcc_envio FROM bdicheq:"informix".sc_maechq WHERE cuenta = pCuenta) THEN -- SE VALIDA QUE LA CUENTA SI EXISTE
	   
	   -- SE REALZIA LA ACTUALIZACION
	   UPDATE bdicheq:"informix".sc_maechq  SET direcc_envio = pDireccEnvio WHERE cuenta = pCuenta;
	   
	   RETURN vCodRet,cMensaje;
	   
	ELSE -- SE VALIDA QUE LA CUENTA NO EXISTE
	   
	   -- SE ASIGNA CODIGO DE ERROR Y MENSAJE DESCRIPTIVO
	   LET vCodRet = '001';
	   LET cMensaje = 'No se encuentra la cuenta que desea consultar.';
	   RETURN vCodRet,cMensaje;
	   
	END IF;

END;    
END PROCEDURE
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 14 de Junio del 2011',
'DESCRIPCION: Actualiza la nueva direccion de envio',
'VERSION: 20110614.0911',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_ctamec_obtienectactesxprod(pEmpresa CHAR(3), pNumCliente CHAR(20), pProducto CHAR(4))

RETURNING 
	CHAR(6)   AS CodRet,
	CHAR(20)  AS Cuenta,
	CHAR(4)   AS Producto;

-- ****************************************************************************
-- Declaracion de variables
-- ****************************************************************************
	
DEFINE vCodRet            CHAR(6);
DEFINE cCuenta            CHAR(20);
DEFINE cNumCte            CHAR(20);
DEFINE cProducto          CHAR(4);
DEFINE cContador          SMALLINT;

DEFINE sql_err, isam_err  INT;   

-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
	
LET vCodRet        = "000";
LET cCuenta        = "";
LET cNumCte        = "";
LET cProducto      = "";

SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

 -- SET DEBUG FILE TO "/home/sysifx/vlv/sp_ctamec_obtienectactesxprod.out";
 -- TRACE ON;

BEGIN

	ON EXCEPTION SET sql_err,isam_err
		IF sql_err <> 0 OR isam_err <> 0 THEN
			
   		    LET vCodRet = sql_err;
			RETURN vCodRet,cCuenta,cProducto;
		END IF;
	END EXCEPTION;
	
	IF pEmpresa = '' OR pNumCliente = '' OR pProducto = '' THEN
	-- Falta parametros para su ejecucion.
	   LET vCodRet = '002';
	   RETURN vCodRet,cCuenta,cProducto;
	END IF;
	
	IF EXISTS (SELECT cuenta FROM bdicheq:"informix".sc_maechq WHERE num_cte = pNumCliente) THEN 
	   LET cContador = 0;
	
	   --Consulta todas la cuentas que pertenecen a este cliente y ese producto.
	   FOREACH
		 
			SELECT cuenta, num_cte, producto 
			INTO cCuenta, cNumCte, cProducto
			FROM bdicheq:"informix".sc_maechq
			WHERE producto = pProducto
			AND num_cte = pNumCliente
			AND empresa = pEmpresa
			ORDER BY num_cte, cuenta
		    
			LET cContador = cContador + 1;
		 
		RETURN vCodRet,cCuenta,cProducto WITH RESUME; 
		
	   END FOREACH;
	 
	 IF cContador = 0 THEN 
	 -- No existen registros de esa cuenta
	    LET vCodRet = '003';
		RETURN vCodRet,cCuenta,cProducto;
	 END IF;
	   
	ELSE
	 --El cliente no tiene cuentas.
	   LET vCodRet = '001';
	   RETURN vCodRet,cCuenta,cProducto;
	   
	END IF;

END;    
END PROCEDURE
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 15 de Junio del 2011',
'DESCRIPCION: Consulta todas la cuentas que pertenecen a este cliente y el producto',
'VERSION: 20110615.1011',
'BD: BDICHEQ';

CREATE PROCEDURE "informix".sp_consulta_instruccionautoridad(pNumCta CHAR(20))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consulta por Instrucción de Autoridad
--Realizó: Nancy Sevilla Camacho
--Fecha: 18/05/2011                    
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5),      -- Código de Retorno
CHAR(20),     -- Cuenta
CHAR(60),     -- Denominación o Razón Social
CHAR(20),     -- Número de Cliente
CHAR(60);     -- Nombre del titular

--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);	
---------------------------	
DEFINE cCuenta CHAR(20);
DEFINE cRazonSoc CHAR(60);
DEFINE cNumCte CHAR(20);
DEFINE cNomTitular CHAR(60);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cCuenta  = '';
LET cRazonSoc = '';
LET cNumCte = '';
LET cNomTitular = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_consulta_instruccionautoridad.out";
	--TRACE ON;

    set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,
					   cCuenta,
					   cRazonSoc,
					   cNumCte,
					   cNomTitular;
			END IF;
		END EXCEPTION;	
		
		IF pNumCta IS NULL OR pNumCta = '' THEN
		
			LET cCodRet = "102"; -- Parámetro de entrada vacío
		
		ELSE

			-- Obtiene Número de cuenta, Denominación o Razón Social, Número de cliente y Titular			   
			SELECT a.cuenta,
				   b.numcte,
				   b.razon_social,
				   TRIM(c.nombre) || ' ' || TRIM(c.apellidos)
			  INTO cCuenta,
				   cNumCte,
				   cRazonSoc,
				   cNomTitular
			  FROM bdicheq:"informix".sc_maechq a,
				   bdinteg:"informix".si_cliente b,
				   bdicheq:"informix".sc_firmantes c
			 WHERE a.cuenta = pNumCta
			   AND a.num_cte = b.numcte
			   AND a.cuenta = c.cuenta
			   AND c.tipo_firma = 'A';			   
			   
			 IF cCuenta IS NULL OR cCuenta = '' OR cNumCte IS NULL OR cNumCte = '' OR 
			    cRazonSoc IS NULL OR cRazonSoc = '' OR cNomTitular IS NULL OR cNomTitular = '' THEN
				LET cCodRet = "101"; -- No se encontró información relacionada a la cuenta			  
			END IF;		
			
		   
		END IF;

		RETURN cCodRet,
			   cCuenta,
			   cRazonSoc,
			   cNumCte,
			   cNomTitular;									
	END
END PROCEDURE;