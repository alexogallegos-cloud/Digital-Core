CREATE PROCEDURE "informix".sp_consulta_firmasregistradas(pNumCta CHAR(20))

--------------------------------------------------------------------
--DOCUMENTACIÓN
--Consulta por Instrucción de Autoridad / Firmas Registradas (Grid)
--Realizó: Nancy Sevilla Camacho
--Fecha: 20/05/2011                    
--------------------------------------------------------------------

--DATOS A REGRESAR---
RETURNING
CHAR(5),      -- Código de Retorno
CHAR(20),     -- Núm. Cliente(Grid)
CHAR(30),     -- Nombres
CHAR(30),     -- Apellidos
CHAR(1),      -- Nivel
CHAR(10); 	  -- Estatus
		
--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE cCodRet CHAR(5);	
---------------------------	
DEFINE cNumCte    CHAR(20);
DEFINE cNombre    CHAR(30);
DEFINE cApellidos CHAR(30);
DEFINE cNivel     CHAR(1);
DEFINE cEstatus   CHAR(10);

--INICIALIZACION DE VARIABLES--
LET iSqlErr = 0;
LET cCodRet = '00000';
LET cNumCte = '';
LET cNombre = '';
LET cApellidos = '';
LET cNivel = '';
LET cEstatus = '';
	
	--SET DEBUG FILE TO "/home/informix/sp_consulta_firmasregistradas.out";
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
					   cNumCte,
					   cNombre,
					   cApellidos, 
					   cNivel,
					   cEstatus;
			END IF;
		END EXCEPTION;	
		
		IF pNumCta IS NULL OR pNumCta = '' THEN
		
			LET cCodRet = "102"; -- Parámetro de entrada vacío
			
			RETURN cCodRet,
				   cNumCte,
				   cNombre,
				   cApellidos, 
				   cNivel,
				   cEstatus;				
		
		ELSE

			-- Se obtiene los datos del Grid de Firmas Registradas
			FOREACH
				SELECT numcte,
					   apellidos,
					   nombre,
					   tipo_firma,
					   DECODE(tipo_firma,'A','TITULAR','B','AUTORIZADO')
				  INTO cNumCte,
					   cApellidos,
					   cNombre,
					   cNivel,
					   cEstatus
				  FROM bdicheq:"informix".sc_firmantes 
				 WHERE cuenta = pNumCta
				   
				RETURN cCodRet,
					   cNumCte,
					   cNombre,
					   cApellidos, 
					   cNivel,
					   cEstatus
				  WITH RESUME;	
				  
		   END FOREACH;	
		   
			IF cNumCte IS NULL OR cNumCte = '' OR cApellidos IS NULL OR cApellidos = '' OR 
			   cNombre IS NULL OR cNombre = '' OR cNivel IS NULL OR cNivel = '' OR cEstatus IS NULL OR cEstatus = '' THEN

				LET cCodRet = "101"; -- No se encontraron datos referentes a las firmas registradas

				RETURN cCodRet,
					   cNumCte,
					   cNombre,
					   cApellidos, 
					   cNivel,
					   cEstatus;	
			  
			END IF;	

		END IF;		
		   
	END
END PROCEDURE;