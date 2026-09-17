CREATE PROCEDURE "informix".sp_obtentipofactura ()	
	RETURNING 	CHAR(5) AS CodRet,
				CHAR(3) AS Id_Tpofacturacion,
				CHAR(40) AS Desc_Facturacion;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);
	DEFINE cIdTpofacturacion			CHAR(3);
	DEFINE cDescFacturacion 			CHAR(40);
	
	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	LET cIdTpofacturacion			= '';
	LET cDescFacturacion			= '';
	
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/tmp/anj/sp_obtentipofactura.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--Obtiene los tipos de facturacion disponibles.
		FOREACH
			SELECT id_tpofacturacion, desc_facturacion 
			INTO cIdTpofacturacion, cDescFacturacion
			FROM bdicred:"informix".sd_tipo_facturacion 
			ORDER BY id_tpofacturacion
			
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
			RETURN cCodRet, cIdTpofacturacion, cDescFacturacion;
		END IF;

	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_obtentipofactura" para obtener los tipos de facturacion',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consultatgarantia()

RETURNING CHAR(5) AS CodRet,
		INTEGER AS idGarantia,
		VARCHAR(20) AS tipoGarantia,
		VARCHAR(30) AS descGarantias,
		DECIMAL(16) AS porcentajeAforo;

    
DEFINE cCodRet 			CHAR(5);
DEFINE iSqlErr  		INTEGER;
DEFINE iIdGarantia     	INTEGER;
DEFINE cTipoGarantia   	VARCHAR(20);
DEFINE cDescGarantias  	VARCHAR(30);
DEFINE dPorcentajeAforo DECIMAL(16);

LET cCodRet 			= '00000';
LET iSqlErr 			= 0;
LET iIdGarantia     	= 0;
LET cTipoGarantia   	= '';
LET cDescGarantias  	= '';
LET dPorcentajeAforo 	= 0.0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consultatgarantia.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT id_garantia, tipo_garantia, desc_garantias, porcentaje_aforo 
			INTO iIdGarantia, cTipoGarantia, cDescGarantias, dPorcentajeAforo
			FROM "informix".sd_tipo_garantia
		
			RETURN cCodRet, iIdGarantia, TRIM(cTipoGarantia), TRIM(cDescGarantias), dPorcentajeAforo WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			RETURN cCodRet, iIdGarantia, TRIM(cTipoGarantia), TRIM(cDescGarantias), dPorcentajeAforo;
		END IF;
	END
END PROCEDURE;