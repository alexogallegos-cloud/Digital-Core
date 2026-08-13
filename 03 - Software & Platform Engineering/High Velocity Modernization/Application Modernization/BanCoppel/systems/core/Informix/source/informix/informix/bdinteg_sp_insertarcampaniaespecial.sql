CREATE PROCEDURE "informix".sp_insertarcampaniaespecial (cEmpresa CHAR(3),cTipo CHAR(1))

--DATOS A REGRESAR---
RETURNING
CHAR(5)   AS cCodRet;

--DEFINICION DE VARIABLES--
DEFINE iSql_err       INTEGER;
DEFINE cCodRet        CHAR(5);
DEFINE cSql    		  CHAR(800);
DEFINE vRuta          VARCHAR (100);
DEFINE vNombreArchivo VARCHAR (100);

--INICIALIZACION DE VARIABLES--
LET iSql_err           = 0;
LET cCodRet           = '00000';
LET cSql              = '';
LET vRuta             = '';
LET vNombreArchivo    = '';

   --SET DEBUG FILE TO "/respaldosbd/Martha/sp_insertarcampaniaespecial.out";
   --TRACE ON;
  
BEGIN

	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet;
		END IF;
	END EXCEPTION;

	SET LOCK MODE TO WAIT 3;
	
	IF NVL(cEmpresa, '') = '' OR NVL(cTipo, '') = '' THEN
		
		LET cCodRet = '00001';
		
	ELSE
	
	SELECT valor 
	INTO   vRuta 
	FROM   bdinteg:"informix".si_param 
	WHERE  empresa = cEmpresa
	AND  cod_param = '155';
	
	IF NVL(vRuta,'') = '' THEN
		LET cCodRet = '00002';	--No existe el Parámetro
		RETURN cCodRet;
	END IF;
	
	SELECT valor 
	INTO   vNombreArchivo
	FROM   bdinteg:"informix".si_param 
	WHERE  empresa = cEmpresa
	AND  cod_param = '156';
		
	IF NVL(vNombreArchivo,'') = '' THEN
		LET cCodRet = '00002';	--No existe el Parámetro
		RETURN cCodRet;
	END IF;
	
	
		IF cTipo = "1" THEN
		
			IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_camp_especiales where empresa='001')THEN
				LET cCodRet = '00002'; --Ya existen datos en la tabla
			END IF;
		
		ELIF cTipo = "2" THEN
			
			--SE PASAN LOS DATOS A LA TABLA HISTÓRICA
			INSERT INTO bdinteg:"informix".si_camp_especiales_hist(empresa, numcte, numcta, mensaje, fecha)
			SELECT empresa, numcte, numcta, mensaje,CURRENT
			FROM bdinteg:"informix".si_camp_especiales where empresa='001';
			
			--SE ELIMINAN DE TABLA ORIGEN
			DELETE FROM bdinteg:"informix".si_camp_especiales where empresa='001';
					
			LET cTipo = "3";
			
		END IF;
						
		IF cTipo = "3" THEN
			
			--SE CARGAN DATOS LOS NUEVOS DATOS
			LET cSql = 'echo "LOAD FROM ' || TRIM(vRuta) || TRIM(vNombreArchivo)
			|| ' DELIMITER ' || ''';''' || 
			' INSERT INTO si_camp_especiales "' || ' > query.sql';
			system cSql;
			LET cSql = "dbaccess bdinteg query.sql";
			system cSql;
			
			--SE ELIMINA EL ARCHIVO DEL SERVIDOR
			LET cSql = 'rm -f ' || TRIM(vRuta) || TRIM (vNombreArchivo);
			SYSTEM cSql;
			
			
		END IF;
	
	END IF;
	
	RETURN cCodRet;
	
END
END PROCEDURE

DOCUMENT
"Autor : Martha Aguirre",
"FECHA : 23/04/2012",
"Descripcion: Realiza inserción de campañas especiales",
"cTipo=1: Consulta para saber si existen datos en la tabla",
"cTipo=2: Se pasan los datos a la historial, se eliminan",
"de la tabla si_camp_especiales y se insertan los registros nuevos",
"cTipo=3: Se insertan los registros",
"Ver.  : 1.0",
"BD    : bdinteg";

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