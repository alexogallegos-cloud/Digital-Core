CREATE PROCEDURE "informix".sp_eliminatemp ()	
	RETURNING CHAR(5) AS CodRet;
                			
	-- Declaracion de variables
	DEFINE iSqlErr          			INTEGER;
	DEFINE cCodRet           			CHAR(5);

	-- Asignacion variables
	LET iSqlErr             		= 0;
	LET cCodRet              		= '00000';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
	
		--SET DEBUG FILE TO "/informix/Stored_Procedures/SP/sp_eliminatemp.out"; 
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		DELETE FROM "informix".tmp_sd_definicion;
		DELETE FROM "informix".tmp_sd_frectipopago;
		DELETE FROM "informix".tmp_tasas_diferenciadas;
		DELETE FROM "informix".tmp_convivenciaProductos;
		DELETE FROM "informix".tmp_documentos_digitalizar;
		DELETE FROM "informix".tmp_doctos_imprimir;
		DELETE FROM "informix".tmp_operaciones_canal;
		DELETE FROM "informix".tmp_activacionmsj;
		DELETE FROM "informix".tmp_politicacreditoprod;
		DELETE FROM "informix".tmp_tipofacturacion;
		DELETE FROM "informix".tmp_ctasmedioacceso;
		DELETE FROM "informix".tmp_caracteristicas_complementarias;
		 
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'Se crea el procedimiento almacenado "sp_eliminatemp" Para el Eliminado de Tablas temporales de taller de productos en sistema "SOC"',
'Base de datos: BDICRED';

CREATE PROCEDURE "informix".sp_consulta_frecpago()

RETURNING CHAR(5) AS CodRet,
          CHAR(2) AS Valor,
		  VARCHAR(20) AS TipoPago;
    
DEFINE cCodRet CHAR(5);
DEFINE cValor CHAR(2);
DEFINE cTipoPago VARCHAR(20);
DEFINE iSqlErr  INTEGER;

LET cCodRet = '00000';
LET cValor = '';
LET cTipoPago = '';
LET iSqlErr = 0;
    
	BEGIN
		-- // MANEJO DE EXCEPCIONES   
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cValor,cTipoPago;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/ifxsif01/home/e_efierro/sp_consulta_frecpago.out";
		--TRACE ON;
	
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
			SELECT valor,tipo_pago
			INTO cValor,cTipoPago
			FROM "informix".sd_cattipopago
		
			RETURN cCodRet, cValor,cTipoPago WITH RESUME;
		END FOREACH;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet= '00001';  --No hay informacion
			RETURN cCodRet, TRIM(cValor), TRIM(cTipoPago);
		END IF;
	END
END PROCEDURE           ;