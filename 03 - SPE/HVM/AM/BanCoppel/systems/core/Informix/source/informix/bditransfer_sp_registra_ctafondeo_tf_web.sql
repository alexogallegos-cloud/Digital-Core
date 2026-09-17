CREATE PROCEDURE "informix".sp_registra_ctafondeo_tf_web
(
	pEmpresa 		CHAR(03),
	pNumCte 		CHAR(20),
	pCtaTransfer	CHAR(20),
	pCuenta			CHAR(20),
	pPromotor		CHAR(08),
	pBanTipoReg		CHAR(01),
    pFolio          CHAR(12),
    pMpsTran        CHAR(12)    
)

RETURNING
	CHAR(05) 	AS CodRet,
	CHAR(25)	AS CtaTF;

--DECLARACIÃN DE VARIABLES
DEFINE iSql_err		INTEGER;
DEFINE sSecuencia	SMALLINT;
DEFINE cStatus		CHAR(1);
DEFINE dFecha		DATETIME YEAR TO FRACTION;

--RETORNOS
DEFINE cCodRet		CHAR(05);
DEFINE cCtaTF		CHAR(25);

--INICIALIZACIÃN DE VARIABLES
LET cCodRet		= '00000';
LET cCtaTF		= '';
LET sSecuencia	= 0;
LET dFecha		= CURRENT;

--SET DEBUG FILE TO '/respaldosbd/Ernesto/sp_registra_ctafondeo_tf.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, cCtaTF;
		END IF;
END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--VALIDAR PARÃMETROS VACÃOS Y NULOS
	
	IF NVL(pEmpresa,'') = '' OR NVL(pNumCte, '') = '' OR NVL(pCtaTransfer, '') = '' OR NVL(pCuenta, '') = ''OR NVL(pBanTipoReg, '') = '' THEN
		LET cCodRet = '00001';
		RETURN cCodRet, cCtaTF;
	END IF;
	
	LET pEmpresa 		= TRIM(pEmpresa);
	LET pNumCte 		= TRIM(pNumCte);
	LET pCtaTransfer	= TRIM(pCtaTransfer);
	LET pCuenta			= TRIM(pCuenta);
	LET pPromotor		= TRIM(pPromotor);
	LET pBanTipoReg		= TRIM(pBanTipoReg);
    LET pFolio		    = TRIM(pFolio);
	LET pMpsTran	= TRIM(pMpsTran);
	
	IF pBanTipoReg = '1' THEN -- Indica que es un Alta
		IF NVL(pPromotor, '') <> '' THEN
			LET cStatus = 'A';
			SELECT MAX(secuencia)
			INTO sSecuencia
			FROM bditransfer:"informix".tf_cta_fondeo
			WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer;
			
			IF NVL(sSecuencia, -1) > 0 THEN
				LET sSecuencia = sSecuencia + 1;
			ELSE
				LET sSecuencia = 1;
			END IF
			
			INSERT INTO bditransfer:"informix".tf_cta_fondeo(empresa, numcte, cuenta_tf, cuenta, secuencia, status, fecha_alta, ejecutivo, folio_alta, mps_tran_alta, folio_cancela, mps_tran_cancela )
			VALUES(pEmpresa, pNumCte, pCtaTransfer, pCuenta, sSecuencia, cStatus, dFecha, pPromotor, pFolio, pMpsTran, null, null);
			LET cCtaTF = TRIM(pCtaTransfer) || sSecuencia;
			RETURN cCodRet, cCtaTF;
		ELSE
			LET cCodRet = '00001';
			RETURN cCodRet, cCtaTF;
		END IF;
	ELIF pBanTipoReg = '2' THEN -- Indica que es una Baja
		SELECT MAX(secuencia)
		INTO sSecuencia
		FROM bditransfer:"informix".tf_cta_fondeo
		WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer AND status = 'A';
		
		IF NVL(sSecuencia, -1) > 0 THEN
		LET cStatus = 'C';
			UPDATE bditransfer:"informix".tf_cta_fondeo SET status = cStatus, fecha_baja = dFecha, folio_cancela=pFolio, mps_tran_cancela=pMpsTran
			WHERE empresa = pEmpresa AND numcte = pNumCte AND cuenta_tf = pCtaTransfer AND cuenta = pCuenta AND secuencia = sSecuencia AND status = 'A';
			LET cCtaTF = TRIM(pCtaTransfer) || sSecuencia || '1';
			RETURN cCodRet, cCtaTF;
		ELSE
			LET cCodRet = '00003';
			RETURN cCodRet, cCtaTF;
		END IF
	ELSE
		LET cCodRet = '00002';
		RETURN cCodRet, cCtaTF;
	END IF
END;
END PROCEDURE

DOCUMENT
'Mediante la bandera que se obtiene de un parÃ¡metro determina si es un INSERT o un UPDATE, en el INSERT registra nuevos datos que se obtienen de los parametros a la',
'tabla bditransfer:"informix".tf_cta_fondeo, primero se checa cual ha sido la Ãºltima secuencia para registrarlo con +1.',
'AUTOR : 95579737 - JosÃ© Ernesto Raygoza Villa',
'FECHA : 16/Abril/2014',
'BD    : bditransfer';