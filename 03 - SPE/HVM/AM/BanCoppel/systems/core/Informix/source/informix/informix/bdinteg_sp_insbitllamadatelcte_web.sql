CREATE PROCEDURE "informix".sp_insbitllamadatelcte_web(pEmpresa char(3),pNumCte char(20),pNumTel char(13),pEjecutivo char(8),pSucursal char(4),pFolio char(4))

	RETURNING	CHAR(5) AS CodRet;
			
	DEFINE 	cCodRet		 CHAR(5);
	DEFINE	iSqlErr	 	 INTEGER;
	DEFINE	iContSMS	 SMALLINT;
	DEFINE	iContLlamada SMALLINT;
	DEFINE 	dFechaMov	DATETIME YEAR TO FRACTION(3);

	LET	cCodRet		 = '00000';
	LET iSqlErr		 = 0;
	LET iContSMS	 = 0;
	LET iContLlamada = 0;
	LET 	dFechaMov	= '';
	
	--SET DEBUG FILE TO '/tmp/sp_insbitllamadatelcte.out';
	--TRACE ON; 

	BEGIN
		
		--CONTROL DE ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 4;
		
		--VALIDA ERRORES DE LOS PARAMETROS
		IF NVL(pEmpresa,'') = '' OR NVL(pNumCte,'') = '' OR NVL(pNumTel,'') = '' OR NVL(pEjecutivo,'') = '' OR NVL(pSucursal,'') = '' OR NVL(pFolio,'') = '' THEN
			LET cCodRet='00001';
		ELSE
		
			SELECT	cont_llamada, cont_sms, fecha_mov
			INTO iContLlamada, iContSMS, dFechaMov
			FROM "informix".si_bit_intentos_ivr
			WHERE empresa = pEmpresa 
			AND numcte = pNumCte
			AND numtel = pNumTel;
		
			INSERT INTO "informix".si_bitllamada_ivr (empresa,numcte,numtel,ejecutivo,sucursal,folio,cont_llamada,cont_sms,fecha_insert,fecha_mov) VALUES (pEmpresa,pNumCte,pNumTel,pEjecutivo,pSucursal,pFolio,NVL(iContLlamada,0),NVL(iContSMS,0),CURRENT,NVL(dFechaMov,''));
			
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT
'AUTOR:	ERNESTO AGUILERA',
'FOLIO: 1777',
'FECHA:	17/DIC/2015',
'DESCRIPCION: Control de registros de llamada en la bitacora',
'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_insertavalidaadiccop_web(pEmpresa CHAR(3), pNumCteCop CHAR(20), pNumCteAdic CHAR(20), pParentesco CHAR(1), pTipo CHAR(1), pUserInsert CHAR(8))
RETURNING CHAR(5), SMALLINT;
--------------------------------------------------------------------------------------------------------------------------------
--30/12/2008
--Rodolfo Tortolero Varela
--Inserta y valida adicionales coppel
--------------------------------------------------------------------------------------------------------------------------------
--27/09/2011
--Rodolfo Tortolero Varela
--Valida cuantos adiccionales tiene el cliente, se agrega un parametro mas de salida para obtener el dato.
--------------------------------------------------------------------------------------------------------------------------------

--DEFINICION DE VARIABLES--
DEFINE iSqlErr INTEGER;
DEFINE vCodRet CHAR(5);
DEFINE dFechaMov DATE;
DEFINE iSecuencia SMALLINT;
DEFINE iTotalAdic SMALLINT;
DEFINE iSecuAdic SMALLINT;
DEFINE cSucursal CHAR(4);

--INICIALIZACION DE VARIABLES--
LET vCodRet = '00003';
LET iSecuencia = 0;
LET iTotalAdic = 0;
LET iSecuAdic = 0;
LET cSucursal = '';

--SET debug FILE TO '/tmp/sp_InsertaValidaAdicCop.out';
--TRACE ON;

SET LOCK MODE TO WAIT 10;

BEGIN
	ON EXCEPTION
		SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET vCodRet = iSqlErr;
			RETURN vCodRet, iSecuAdic;
		END IF;
	END EXCEPTION;
	
	--SELECCIONA EL NUMERO DE ADICIONALES PERMITIDOS
	SELECT totadicional 
	INTO iTotalAdic 
	FROM "informix".si_catvalidaprod 
	WHERE producto = '6500';
	
	--SELECCIONA LA SECUENCIA MAXIMA DE ADICIONALES PERMITIDOS
	SELECT NVL(MAX(secuencia),0) 
	INTO iSecuencia
	FROM "informix".si_adiccoppel 
	WHERE numctecoppel = pNumCteCop; 
	
	-- SELECCIONA LA FECHA HOY
	SELECT fecha_hoy 
	INTO dFechaMov 
	FROM "informix".si_fechas;
	
	--Obtiene la Sucursal
	SELECT sucursal
	INTO cSucursal
	FROM bdinteg:"informix".si_adiccoppel
	WHERE numctecoppel = pNumCteCop 
	AND secuencia = 1;
	
	SELECT COUNT(*) INTO iSecuAdic FROM "informix".si_adiccoppel WHERE numctecoppel = pNumCteCop AND tipotar <> 1;
	
	IF pTipo = 1 THEN
		IF EXISTS (SELECT 1 FROM "informix".si_adiccoppel WHERE numctecoppel = pNumCteCop AND numcte = pNumCteAdic AND secuencia <> 1) THEN 
			LET vCodRet = '00001';	--"El cliente ya existe como adicional de la cuenta"
		ELSE
			IF iSecuencia >= iTotalAdic THEN
				LET vCodRet = '00002';	--"La cuenta ya cuenta con los adicionales permitidos"
			END IF;
		END IF;
	ELIF pTipo = 2 THEN
		LET iSecuencia = iSecuencia + 1; 
		INSERT INTO "informix".si_adiccoppel (empresa, numctecoppel, secuencia, sucursal, numtarcoppel, numcte, tipotar, status, parentesco, fechamov, user_insert)
		VALUES (pEmpresa, pNumCteCop, iSecuencia, cSucursal, pNumCteCop, pNumCteAdic, "2", "S", pParentesco, dFechaMov, pUserInsert);
		LET vCodRet = '00000';
	END IF;
	
	RETURN vCodRet, iSecuAdic;
END;

END PROCEDURE;