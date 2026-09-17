CREATE PROCEDURE "informix".sp_obt_mensajesportanom(pIdMsj CHAR(5))
RETURNING 
	CHAR(5)		AS 	CodRet,
	CHAR(150) 	AS 	Mensaje;
	
	-- Creador: Moisés Soriano
	-- Objetivo: Obtiene mensajes de tabla bdibpi:"informix".bpi_catmensajesportanom
	-- Solicitó: Alejandro Vazquez
	-- Fecha: 03/03/2016
	
	--DECLARACIN DE VARIABLES
	DEFINE cCodRet				CHAR(5);
	DEFINE cSqlErr				INT;
	DEFINE vcMensaje			CHAR(150);
	
	--INICIALIZACION DE VARIABLES
	LET cCodRet					= '00000';
	LET cSqlErr					= 0;
	LET vcMensaje				= '';
	
	BEGIN	
		ON EXCEPTION SET cSqlErr
			IF cSqlErr <> 0 THEN
				LET cCodRet = cSqlErr;
				RETURN cCodRet,vcMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/sysifx/moises/bpi/bdibpi/sp_obt_mensajesportanom.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT desc_mensaje INTO vcMensaje 
		FROM bdibpi:"informix".bpi_catmensajesportanom
		WHERE id_mensaje= pIdMsj;

		IF(NVL(vcMensaje,'')='')THEN
			LET cCodRet = '00001'; --no se encontró información
		END IF;
		
		RETURN cCodRet,NVL(vcMensaje,'');
		
	END;
END PROCEDURE;