CREATE PROCEDURE "informix".sp_validatelefono(cEmpresa CHAR(3), cTelefonoCasa CHAR(10), cTelefonoCelular CHAR(10), cTelefonoOficina CHAR(10))
RETURNING CHAR(5), CHAR(1), CHAR(1), CHAR(1);

-- **************************************************************************
--  variables
-- **************************************************************************
DEFINE cCodRet CHAR(5);
DEFINE cValCasa CHAR(1);
DEFINE cValCelular CHAR(1);
DEFINE cValOficina CHAR(1);
DEFINE iSqlErr INTEGER;
DEFINE cNirCasa CHAR(3);
DEFINE cSerieCasa CHAR(3);
DEFINE cNumeracionCasa CHAR(4);
DEFINE cNirCelular CHAR(3);
DEFINE cSerieCelular CHAR(3);
DEFINE cNumeracionCelular CHAR(4);
DEFINE cNirOficina CHAR(3);
DEFINE cSerieOficina CHAR(3);
DEFINE cNumeracionOficina CHAR(4);
DEFINE cTelefonoNirCasa CHAR(2);
DEFINE cTelefonoNirCel CHAR(2);
DEFINE cTelefonoNirOfi CHAR(2);
DEFINE cBanValidaTelefonos CHAR(1);
-- **************************************************************************
-- inicializa variables
-- **************************************************************************
LET cCodRet  = '001';
LET cValCasa = '0';
LET cValCelular = '0';
LET cValOficina = '0';
LET iSqlErr = 0;
LET cNirCasa = '';
LET cSerieCasa = '';
LET cNumeracionCasa = '';
LET cNirCelular = '';
LET cSerieCelular = '';
LET cNumeracionCelular = '';
LET cNirOficina = '';
LET cSerieOficina = '';
LET cNumeracionOficina = '';
LET cTelefonoNirCasa = '';
LET cTelefonoNirCel = '';
LET cTelefonoNirOfi = '';
LET cBanValidaTelefonos = '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr !=0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cValCasa, cValCelular, cValOficina;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/tmp/sp_validatelefono.out';
	--TRACE ON;
	-----------------------------------------
	--CREACION: Hector Bojorquez
	--FECHA: 2009-02-18
	--FUNCIONALIDAD: Verfifca si el telefono proporcionado en el alta de la direcciÃ³n es un telefono validado por la COFETEL
	----------------------------------------
	-- Se modifica sp inicializando codigo de retorno a 001 y el valor de retorno de telefonos a 1. *Martha
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	SELECT valor INTO cBanValidaTelefonos FROM "informix".si_param WHERE empresa = cEmpresa AND cod_param = '309'; -- BCPL 17/06/2014

	IF cTelefonoCasa <> "" THEN
		LET cTelefonoNirCasa = SUBSTR(cTelefonoCasa, 1, 2);
		IF cTelefonoNirCasa IN ('55', '33', '81','56') THEN
			LET cNirCasa = SUBSTR(cTelefonoCasa, 1, 2);
			LET cSerieCasa = SUBSTR(cTelefonoCasa, 3, 3);
			LET cNumeracionCasa = SUBSTR(cTelefonoCasa, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirCasa AND serie = cSerieCasa AND numeracion_inicial <= cNumeracionCasa AND numeracion_final >= cNumeracionCasa) THEN
				LET cValCasa = '1';
				LET cCodRet = '000';
			END IF;
		ELSE
			LET cNirCasa = SUBSTR(cTelefonoCasa, 1, 3);
			LET cSerieCasa = SUBSTR(cTelefonoCasa, 4, 3);
			LET cNumeracionCasa = SUBSTR(cTelefonoCasa, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirCasa AND serie = cSerieCasa AND numeracion_inicial <= cNumeracionCasa AND numeracion_final >= cNumeracionCasa) THEN
				LET cValCasa = '1';
				LET cCodRet = '000';
			END IF;
		END IF;
		-- BCPL 17/06/2014
		IF cBanValidaTelefonos = '1' THEN
			IF EXISTS (SELECT 1 FROM "informix".si_tels_invalidos WHERE telefono = cTelefonoCasa) THEN
				LET cValCasa = '0';
				LET cCodRet = '000';
			END IF;
		END IF;
	END IF;

	IF cTelefonoCelular <> "" THEN
		LET cTelefonoNirCel = SUBSTR(cTelefonoCelular, 1, 2);
		IF cTelefonoNirCel IN ('55', '33', '81','56') THEN
			LET cNirCelular = SUBSTR(cTelefonoCelular, 1, 2);
			LET cSerieCelular = SUBSTR(cTelefonoCelular, 3, 3);
			LET cNumeracionCelular = SUBSTR(cTelefonoCelular, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirCelular  AND serie = cSerieCelular AND numeracion_inicial <= cNumeracionCelular AND numeracion_final >= cNumeracionCelular AND tipored = 'MOVIL') THEN
				LET cValCelular = '1';
				LET cCodRet = '000';
			END IF;
		ELSE
			LET cNirCelular = SUBSTR(cTelefonoCelular, 1, 3);
			LET cSerieCelular = SUBSTR(cTelefonoCelular, 4, 3);
			LET cNumeracionCelular = SUBSTR(cTelefonoCelular, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirCelular  AND serie = cSerieCelular AND numeracion_inicial <= cNumeracionCelular AND numeracion_final >= cNumeracionCelular AND tipored = 'MOVIL') THEN
				LET cValCelular = '1';
				LET cCodRet = '000';
			END IF;
		END IF;
		-- BCPL 17/06/2014
		IF cBanValidaTelefonos = '1' THEN
			IF EXISTS (SELECT 1 FROM "informix".si_tels_invalidos WHERE telefono = cTelefonoCelular) THEN
				LET cValCelular = '0';
				LET cCodRet = '000';
			END IF;
		END IF;
	END IF;

	IF cTelefonoOficina <> "" THEN
		LET cTelefonoNirOfi = SUBSTR(cTelefonoOficina, 1, 2);
		IF cTelefonoNirOfi IN ('55', '33', '81','56') THEN
			LET cNirOficina = SUBSTR(cTelefonoOficina, 1, 2);
			LET cSerieOficina = SUBSTR(cTelefonoOficina, 3, 3);
			LET cNumeracionOficina = SUBSTR(cTelefonoOficina, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirOficina  AND serie = cSerieOficina AND numeracion_inicial <= cNumeracionOficina AND numeracion_final >= cNumeracionOficina) THEN
				LET cValOficina = '1';
				LET cCodRet = '000';
			END IF;
		ELSE
			LET cNirOficina = SUBSTR(cTelefonoOficina, 1, 3);
			LET cSerieOficina = SUBSTR(cTelefonoOficina, 4, 3);
			LET cNumeracionOficina = SUBSTR(cTelefonoOficina, 7, 4);
			IF EXISTS (SELECT 1 FROM "informix".si_cattelefono WHERE nir = cNirOficina  AND serie = cSerieOficina AND numeracion_inicial <= cNumeracionOficina AND numeracion_final >= cNumeracionOficina) THEN
				LET cValOficina = '1';
				
				LET cCodRet = '000';
			END IF;
		END IF;
		-- BCPL 17/06/2014
        --SE QUITA LA VALIDACION EN LA LISTA NEGRA DEL TELEFONO DE LA OFICINA
        /*
		IF cBanValidaTelefonos = '1' THEN
			IF EXISTS (SELECT 1 FROM "informix".si_tels_invalidos WHERE telefono = cTelefonoOficina) THEN
				LET cValOficina = '0';
				LET cCodRet = '000';
			END IF;
		END IF;
        */
	END IF;

	RETURN cCodRet, cValCasa, cValCelular, cValOficina;
END
END PROCEDURE;