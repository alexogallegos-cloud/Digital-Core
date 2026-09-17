CREATE PROCEDURE "informix".sp_obtieneescolaridad(cnumcte CHAR(20),cStatusSolicitud CHAR(2))
		RETURNING CHAR(6),CHAR(1);
	
--DEFINICION DE VARIABLES 
DEFINE  cCodRet 					CHAR(5);
DEFINE  iSqlErr 					INTEGER;
DEFINE  cNumerosolicituddecredito 	CHAR(20);
DEFINE  iElementoScoring 			INTEGER;
DEFINE  cDescripElemento 			CHAR(50);
DEFINE  cEscolaridad 				CHAR(1);

--INICIALIZACION DE VARIABLES
LET cCodRet = '000000';
LET cNumerosolicituddecredito = '';
LET iElementoScoring = 0;
LET cDescripElemento = '';
LET cEscolaridad = '';
	
--SET DEBUG FILE TO "/tmp/sp_ObtieneEscolaridad.out";
--TRACE ON;
BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet,'';
		END IF;
	END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;
	
	IF cnumcte IS NOT NULL OR cnumcte <> "" THEN
		--OBTENER FECHA Y NUMERO DE SOLICITUD
		SELECT	num_solicitud
		INTO	cNumerosolicituddecredito
		FROM	bdisolic:"informix".ss_solicitudes
		WHERE	numcte = cnumcte AND num_producto = '6500';
		
		--Para obtener elemento
		SELECT	elemento  
		INTO	iElementoScoring 
		FROM	bdisolic:"informix".ss_detalle_scoring 
		WHERE	grupo = '21' AND num_solicitud = cNumerosolicituddecredito;
		
		--Para buscar descripcion de elemento 
		SELECT	descripcion
		INTO	cDescripElemento  
		FROM	bdisolic:"informix".ss_scoring_element 
		WHERE	elemento = iElementoScoring AND	grupo = '21' AND activa = 1;
		
		IF cDescripElemento = "No Estudió" THEN
			LET cEscolaridad = '1';
		END IF;
		
		IF cDescripElemento = "Primaria" THEN
			LET  cEscolaridad = '2';
		END IF;
		
		IF cDescripElemento = "Secundaria" THEN
			LET cEscolaridad = '3';
		END IF;
		
		IF cDescripElemento = "Carrera Técnica" THEN
			LET cEscolaridad = '4';
		END IF;
		
		IF cDescripElemento = "Preparatoria" THEN
			LET cEscolaridad = '5';
		END IF;
		
		IF cDescripElemento = "Licenciatura o Superior" THEN
			LET cEscolaridad = '6'; 
		END IF;
	ELSE
		RETURN '000001',NVL(cEscolaridad,'2');
	END IF;
	RETURN cCodRet, NVL(cEscolaridad,'2');
END;
--*************************************************************************
--| Procedimiento   : sp_ObtieneEscolaridad
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Noviembre de 2008
--| Descripción     : Obtiene la escolaridad del cliente 
--*************************************************************************
--| Modificado por  : Adrian Lara
--| Fecha creacion  : Octubre de 2011
--| Descripción     : Se quita la contulsa de la solicitud de credito por el estatus.
--*************************************************************************
END PROCEDURE;