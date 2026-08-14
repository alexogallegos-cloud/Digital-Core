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