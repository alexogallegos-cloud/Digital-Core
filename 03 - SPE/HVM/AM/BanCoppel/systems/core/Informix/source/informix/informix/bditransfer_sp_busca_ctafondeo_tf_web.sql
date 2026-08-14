CREATE PROCEDURE "informix".sp_busca_ctafondeo_tf_web
(
	pEmpresa 	CHAR(03),
	pNumCtaTf 	CHAR(20)
)

RETURNING
	CHAR(05) 	AS cCodRet,
	CHAR(20) 	AS cCtaBancoppel,
	CHAR(40) 	AS cNomProducto,
	CHAR(01) 	AS cBanCtaFondeo;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(05);

DEFINE cCtaBancoppel	CHAR(20);
DEFINE cNomProducto		CHAR(40);
DEFINE cBanCtaFondeo	CHAR(01);

DEFINE sSecuencia		SMALLINT;
DEFINE cStatus			CHAR(01);
DEFINE cCuenta			CHAR(20);
DEFINE cNumCteBanco		CHAR(20);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet			= '00000';
LET cCtaBancoppel	= '';
LET cNomProducto	= '';
LET cBanCtaFondeo 	= '0';

LET sSecuencia		= -1;
LET cStatus			= '';
LET cCuenta			= '';
LET cNumCteBanco	= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_error_trama_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cCtaBancoppel, cNomProducto, cBanCtaFondeo;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 4;

	--VALIDAR PARÃMETROS VACÃOS Y NULOS
	LET pEmpresa  = TRIM(pEmpresa);
	LET pNumCtaTf = TRIM(pNumCtaTf);
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCtaTf, '') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cCtaBancoppel, cNomProducto, cBanCtaFondeo;
	END IF;
	
	SELECT MAX(secuencia)
	INTO sSecuencia
	FROM bditransfer:"informix".tf_cta_fondeo
	WHERE cuenta_tf = pNumCtaTf AND empresa = pEmpresa;
	
	IF NVL(sSecuencia, -1) > 0 THEN
		SELECT status, cuenta
		INTO cStatus, cCuenta
		FROM bditransfer:"informix".tf_cta_fondeo
		WHERE cuenta_tf = pNumCtaTf AND secuencia = sSecuencia AND empresa = pEmpresa;
		
		LET cStatus = TRIM(cStatus);
		LET cCuenta = TRIM(cCuenta);
		
		IF cStatus <> 'A' THEN
			LET cCuenta = '';
		END IF
	END IF
	
	SELECT numcte
	INTO cNumCteBanco
	FROM bditransfer:"informix".tf_maecte
	WHERE cuenta_tf = pNumCtaTf AND empresa = pEmpresa;
	
	LET cNumCteBanco = TRIM(cNumCteBanco);
	
	FOREACH
		SELECT a.cuenta, b.nombre
		INTO cCtaBancoppel, cNomProducto
		FROM bdicheq:"informix".sc_maechq AS a, bdicheq:"informix".sc_producto AS b
		WHERE a.producto = b.producto AND a.status_cta = 1 AND b.asociar_transfer in(1,2) AND a.num_cte = cNumCteBanco AND a.empresa = pEmpresa AND b.empresa = pEmpresa
		
		IF NVL(TRIM(cCtaBancoppel), '') <> '' THEN
			IF cCuenta = TRIM(cCtaBancoppel) THEN
				LET cBanCtaFondeo = '1';
			ELSE 
				LET cBanCtaFondeo = '0';
			END IF
		END IF
		RETURN cCodRet, cCtaBancoppel, cNomProducto, cBanCtaFondeo WITH RESUME;
	END FOREACH
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00002';
		RETURN cCodRet, cCtaBancoppel, cNomProducto, cBanCtaFondeo;
	END IF

END;
END PROCEDURE

DOCUMENT
'Consulta la cuenta Banco, el nombre del producto mediante el nÃºmero de la cuenta transfer',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'BD    : bditransfer';