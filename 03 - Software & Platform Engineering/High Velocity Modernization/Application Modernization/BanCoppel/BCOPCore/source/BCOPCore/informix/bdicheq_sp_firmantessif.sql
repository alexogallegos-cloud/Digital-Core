CREATE PROCEDURE "informix".sp_firmantessif( pempresa       CHAR(3),
									   pcuenta        CHAR(20),
									   psecuencia     SMALLINT,
									   pnumcte        CHAR(20),
									   papellidos     CHAR(30),
									   pnombre        CHAR(30),
									   preg_firma     CHAR(1),
									   ptipo_firma    CHAR(1),
									   pcombinacion   CHAR(120),
									   pparentesco    CHAR(2))

RETURNING CHAR(5);

DEFINE cod_ret            CHAR(5);
DEFINE longitud           SMALLINT;
DEFINE vnum_cte           CHAR(20);
DEFINE vtipocte           CHAR(1);
DEFINE sql_err, isam_err  INTEGER;
DEFINE v_long_cta         CHAR(2);

LET vtipocte              = '';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- SET DEBUG FILE TO "/home/sysifx/vlv/sp_firmantesSIF.out";
-- TRACE ON;

BEGIN

   ON EXCEPTION SET sql_err, isam_err
      IF sql_err <> 0 OR isam_err <> 0 THEN
         LET cod_ret = sql_err;
         RETURN cod_ret;
      END IF;
   END EXCEPTION;
   
   LET cod_ret = '000';
   
   -- SE VALIDAN LOS PARAMETROS
   IF pcuenta IS NULL OR psecuencia IS NULL OR pnumcte IS NULL THEN
	  LET cod_ret = '110';
	  RETURN cod_ret;
   END IF
   
   -- SI LA SECUENCIA ES 1 SE DAN DE ALTA LOS FIRMANTES
   IF psecuencia = 1 THEN
      DELETE FROM bdicheq:"informix".sc_firmantes
      WHERE empresa = pempresa AND cuenta = pcuenta;
	  
    --Actualiza el Maenoc por las Firmas Registradas
      UPDATE bdicheq:"informix".sc_maenoc SET reg_firmas = preg_firma
      WHERE  empresa = pempresa AND cuenta = pcuenta;
	  
   END IF;
   
   -- SE EXTRAE EL NUMERO DE CLIENTE POSEEDOR DE LA CUENTA
   SELECT num_cte INTO vnum_cte
   FROM bdicheq:"informix".sc_maechq WHERE cuenta = pcuenta;
   
   -- SE VALIDA LA EXISTENCIA DE LA CUENTA
   IF NOT vnum_cte IS NULL THEN
      SELECT tipo_cliente INTO vtipocte
      FROM bdinteg:"informix".si_cliente
      WHERE numcte = vnum_cte;
   END IF
   
   --Registra los sp_firmantesSIF que se autorizaron para la cuenta.
   INSERT INTO bdicheq:"informix".sc_firmantes(empresa,cuenta,secuencia,numcte,apellidos,nombre,reg_firma,tipo_firma,combinacion,parentesco)
   VALUES                                     (pempresa,pcuenta,psecuencia,pnumcte,papellidos,pnombre,preg_firma,ptipo_firma,pcombinacion,pparentesco);
   
   -- SE CREA EL CLIENTE LA RELACION
   INSERT INTO bdinteg:"informix".si_cterelacionado(empresa,numcte,sistema,cuenta,tipo_relacion,parentesco,tipo_cliente_ori,user_insert,fecha_insert)
   VALUES                                          (pempresa,pnumcte,"SC",pcuenta,"02",pparentesco,vtipocte,USER,CURRENT);
   
   RETURN cod_ret;
END;
END PROCEDURE
DOCUMENT
'MODIFICO: Valentin Lopez',
'FECHA: 09 de Junio del 2011',
'DESCRIPCION: Registra un historial de sp_firmantesSIF que sean autorizados para la cuenta.',
'VERSION: 20110609.1146',
'BD: BDICHEQ';

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