CREATE PROCEDURE "informix".sp_consulta_nombre_tf_web
(
	pEmpresa 	CHAR(03),
	pNombre1 	CHAR(20),
	pNombre2 	CHAR(20),
    pPaterno 	CHAR(20),
    pMaterno 	CHAR(20),
	pFechaNac 	DATE,
    pSecuencia 	SMALLINT
)

RETURNING
	CHAR(5) 	AS cCodRet,
	CHAR(50) 	AS cNombre1,
	CHAR(26) 	AS cNombre2,
	CHAR(26) 	AS cApPaterno,
	CHAR(26) 	AS cApMaterno,
	DATE 		AS dFechaNac,
	CHAR(20) 	AS cNumCteTf,
	CHAR(13) 	AS cRFC,
	CHAR(20) 	AS cCuentaTf;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE cCodRet		CHAR(06);
DEFINE cNombre1		CHAR(50);
DEFINE cNombre2		CHAR(26);
DEFINE cAPaterno	CHAR(26);
DEFINE cAMaterno	CHAR(26);
DEFINE dFN			DATE;
DEFINE cNumcteTf 	CHAR(20);
DEFINE cRfc 		CHAR(13);
DEFINE cCuentaTf	CHAR(20);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet			= '00000';
LET cNombre1		= '';
LET cNombre2		= '';
LET cAPaterno		= '';
LET cAMaterno		= '';
LET cNumcteTf		= '0000000000';
LET cRfc			= '';
LET dFN				= '';
LET cCuentaTf		= '';

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_consulta_nombre_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARÃMETROS VACÃOS Y NULOS
	IF NVL(TRIM(pEmpresa),'') = ''  THEN
		LET cCodRet = '00001';
		LET cNombre1 = 'Debe proporcionar el cÃ³digo de empresa';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	END IF;

	IF NVL(TRIM(pPaterno), '') = '' THEN
		LET cCodRet = '00002';
		LET cNombre1 = 'Debe proporcionar el apellido paterno';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	ELSE
		LET pPaterno = TRIM(pPaterno);
	END IF;

	IF NVL(TRIM(pNombre1), '') = '' THEN
		LET cCodRet = '00003';
		LET cNombre1 = 'Debe proporcionar el primer nombre';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	ELSE
		LET pNombre1 = TRIM(pNombre1)||'*';
	END IF;

	IF NVL(TRIM(pNombre2), '') = '' THEN
		LET pNombre2 = '';
	ELSE
		LET pNombre2 = TRIM(pNombre2)||'*';
	END IF;  
	
	IF NVL(pFechaNac, '') = '' THEN
		FOREACH
			SELECT SKIP pSecuencia LIMIT 21
			nombre1, nombre2, apell_paterno, apell_materno, fecha_nac, numcte_tf, rfc, cuenta_tf
			INTO cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF
			FROM bditransfer:"informix".tf_maecte
			WHERE nombre1 MATCHES pNombre1 AND nombre2 MATCHES pNombre2 AND apell_paterno = pPaterno AND apell_materno = pMaterno AND status_cta = '1'

			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF WITH RESUME;
		END FOREACH;
	ELSE
	
		FOREACH
			SELECT SKIP pSecuencia LIMIT 21
			nombre1, nombre2, apell_paterno, apell_materno, fecha_nac, numcte_tf, rfc, cuenta_tf
			INTO cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF
			FROM bditransfer:"informix".tf_maecte
			WHERE nombre1 MATCHES pNombre1 AND nombre2 MATCHES pNombre2 AND apell_paterno = pPaterno AND apell_materno = pMaterno AND fecha_nac = pFechaNac AND status_cta = '1'

			RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF WITH RESUME;
		END FOREACH;
	
	END IF
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00004';
		LET cNombre1 = 'No se encontrÃ³ coincidencia';
		RETURN cCodRet, cNombre1, cNombre2, cAPaterno, cAMaterno, dFN, cNumcteTf, cRfc, cCuentaTF;
	END IF

END;
END PROCEDURE

DOCUMENT
'Consulta clientes transfer por medio de los parÃ¡metros nombre(s) y apellido(s) y por fecha de nacimiento',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'MODIFICO: Leslie RendÃ³n',
'DESCRIPCIÃN: Se modifica para evitar forzar la consulta por fecha de nacimiento.',
'BD    : bditransfer';