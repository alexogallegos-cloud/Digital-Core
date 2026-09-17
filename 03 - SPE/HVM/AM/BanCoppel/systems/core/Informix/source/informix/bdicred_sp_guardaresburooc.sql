CREATE PROCEDURE "informix".sp_guardaresburooc(pNumcte CHAR(20), pNumsol CHAR(20), pTipo CHAR(2))
returning CHAR(5) AS CodigoRetorno;

--DECLARACION DE VARIABLES
DEFINE cCodret  CHAR(5);
DEFINE iSqlErr 	INTEGER;
DEFINE cDescripcion CHAR(50);

--INICIALIZACION DE VARIABLES
LET cCodret = '00000';
LET iSqlErr = 0;
LET cDescripcion = ''; 

	--SET DEBUG FILE TO '/tmp/bernardo/prueba/sp_guardaresburooc.out';
	--TRACE ON;


BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
            LET cCodret = iSqlErr;
			RETURN cCodret;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  

	IF nvl(pNumcte,'') = '' OR LEN(TRIM(pNumcte)) > 9 THEN 
		LET cCodret = '00001'; --Parametro pNumcte vacio o numero de solicitud mayor 9.
	ELIF NVL(pNumsol,'') = '' OR LEN(TRIM(pNumsol)) > 14 THEN
		LET cCodret = '00002'; --Parametro pNumsol vacio o numero de solicitud mayor a 14.
	ELIF NVL(pTipo,'') = '' OR LEN(TRIM(pTipo)) > 1 THEN
		LET cCodret = '00003'; --Parametro pTipo vacio o tipo de error mayor a 1.
	ELSE  
		IF pTipo = '0' THEN
			LET cDescripcion = 'Normal';
		ELIF pTipo = '1' THEN
			LET cDescripcion = 'Malos antecedentes en SIC';
		ELIF pTipo = '2' THEN
			LET cDescripcion = 'Capacidad de Pago Saturada (CPS)';
		ELIF pTipo = '3' THEN
			LET cDescripcion = 'Atraso en Coppel';
		ELIF pTipo = '4' THEN
			LET cDescripcion = 'Biometricos';
		ELIF pTipo = '5' THEN
			LET cDescripcion = 'Otro';
		END IF;
		
		INSERT INTO bdicred:catalogo_errores_buro_oc (empresa, numcte, numsol, tipo_respuesta, descripcion) 
		VALUES ('001', pNumcte, pNumsol, pTipo, cDescripcion);
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN
			LET cCodret = '00004'; --No inserto en la tabla.
		END IF;
	END IF;
	
	return cCodret;
END;
END PROCEDURE;