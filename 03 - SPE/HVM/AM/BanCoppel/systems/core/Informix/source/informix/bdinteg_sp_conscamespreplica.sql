CREATE PROCEDURE "informix".sp_conscamespreplica (cEmpresaParam CHAR(5), iNumRegistros INTEGER)


--DATOS A REGRESAR---
RETURNING
CHAR(5)  AS codigo_retorno,
CHAR(5)  AS codigo_retorno2,
CHAR(5)  AS empresa,
CHAR(11)  AS numcte,
CHAR(12)  AS numcta,
CHAR(80)  AS mensaje;

--DEFINICION DE VARIABLES--
DEFINE iSqlErr  INTEGER;
DEFINE cCodRet  CHAR(5);	
DEFINE cCodRet2 CHAR(5);
DEFINE iRows    INTEGER;
---------------------------
DEFINE cEmpresa  CHAR(5);
DEFINE cNumCte   CHAR(11);
DEFINE cNumCta   CHAR(12);
DEFINE cMensaje  CHAR(80);
DEFINE iContador INTEGER;

--INICIALIZACION DE VARIABLES--
LET iSqlErr   = 0;
LET cCodRet   = '00000';
LET cCodRet2  = '00000';
LET iRows     = 0;
-------------------------------
LET cEmpresa  = '';
LET cNumCte   = '';
LET cNumCta   = '';
LET cMensaje  = '';
LET iContador = 0;

	--SET DEBUG FILE TO "/respaldosbd/christian/sp_conscamespreplica.out";
	--TRACE ON;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	-- INICIO DEL PROCEDIMIENTO
	BEGIN
	-- MANEJADOR DE ERRORES
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
			   RETURN cCodRet,
				      cCodRet2,			   
					  cEmpresa,     
					  cNumCte,    
					  cNumCta,
					  cMensaje;
			END IF;
		END EXCEPTION;	


		LET cCodRet2 = '00002';		

       		RETURN cCodRet,
              	cCodRet2,			   
              	cEmpresa,     
              	cNumCte,    
              	cNumCta,
              	cMensaje;

		
		--Valida parámetros de entrada
		IF NVL(cEmpresaParam,'') = '' OR iNumRegistros IS NULL THEN	
		
			--Parámetro de entrada vacío
			LET cCodRet2 = '00001';	

			   RETURN cCodRet,
					  cCodRet2,			   
					  cEmpresa,     
					  cNumCte,    
					  cNumCta,
					  cMensaje
				 WITH RESUME;	

		ELSE				 
		
			FOREACH
				--Se seleccionan los datos de central
				SELECT  empresa,
						numcte, 
						numcta, 
						mensaje
				   INTO cEmpresa,     
						cNumCte,    
						cNumCta,
						cMensaje     		   
				   FROM bdinteg:"informix".si_camp_especiales
				  WHERE empresa = cEmpresaParam		  
				  
				IF cEmpresa <> '' AND cNumCte <> '' AND cMensaje <> '' THEN

					LET iContador = iContador + 1;

					IF iContador <= iNumRegistros THEN --DSB 11/10/2013 Christian Echavarria se agrega =
						CONTINUE FOREACH;
					END IF; 				

				   RETURN cCodRet,
						  cCodRet2,			   
						  cEmpresa,     
						  cNumCte,    
						  cNumCta,
						  cMensaje
					 WITH RESUME;	
					 
				ELSE
				
					LET cCodRet2 = '00002';		

				   RETURN cCodRet,
						  cCodRet2,			   
						  cEmpresa,     
						  cNumCte,    
						  cNumCta,
						  cMensaje
					 WITH RESUME;					
				 
				END IF;					 

			END FOREACH; 
			
			IF NVL(cEmpresa,"") = "" OR NVL(cNumCte,"") = "" THEN		
				LET cCodRet2 = '00003';

				   RETURN cCodRet,
						  cCodRet2,			   
						  cEmpresa,     
						  cNumCte,    
						  cNumCta,
						  cMensaje;
			END IF;					
			  
		END IF;
		
	END
END PROCEDURE
DOCUMENT
'Se consultan los datos de la tabla si_camp_especiales para replicarlos en sucursal',
'Realizó: Nancy Sevilla Camacho',
'Fecha: 03/05/2012  ',
'Se modifica el foreach para la paginación',
'Realizó: Christian Echavarria',
'Fecha: 11/10/2013',
'BD    : bdinteg';

CREATE PROCEDURE "informix".sp_valida_numserie(pNumCte char(9), pNumSerie char(10))
		RETURNING char(5);

-----------------------------------------------------------------------------------------------
-- Realizó: Pedro Gaspar Jimenez Guzman
-- Actividad: Valida en numero de serie de token renovado
-- Solicitó: Walber Castro
-- Fecha de Solicitud: 23/12/2013
------------------------------------------------------------------------------------------------
		
	--Define variables
	define sql_err integer;
	define cod_ret char (5);

	--Inicializa Variables
	LET sql_err = 0;
	LET cod_ret = '00000';

	BEGIN
	 ON EXCEPTION SET sql_err
		IF sql_err <> 0 THEN
			LET cod_ret = sql_err;
			RETURN cod_ret;
		END IF;
	 END EXCEPTION;

	--SET DEBUG FILE TO "/home/informix/bibiana/sp_valida_numserie.out";
	--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
	 
	 IF NOT EXISTS(SELECT num_cliente FROM bdinteg:"informix".si_bpitoken WHERE num_cliente = pNumCte AND ns_token = pNumSerie) THEN
		RETURN '00001';
	 END IF;
	 
	 RETURN cod_ret;

	END;

END PROCEDURE;