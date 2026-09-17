CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay 
(
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pBenefFechNac  		CHAR(8), 
	pMoneyTransferKey	CHAR(10), 
	pNewMtcn			CHAR(16), 
	pMtcn				CHAR(10), 
	pForeignRefNumRq	CHAR(16), 
	pRetCode			CHAR(5), 
	pForeingRefNumRp	CHAR(16), 
	pDesError			CHAR(250), 
	pUserInsert			CHAR(8),
	pConf_pago          CHAR(1),
	pNumClienteRemesa   CHAR(20)
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE  cDesc_Error         CHAR(250);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE dFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cTemplateId          CHAR(10);
	DEFINE vfec_nac				DATE;
	DEFINE vCodRet				CHAR(5);
	DEFINE vcuenta				INTEGER;
	DEFINE p_moneda_origen 		CHAR(3);
	DEFINE p_importe_origen 	MONEY;
	DEFINE vCategoria			CHAR(2);
	DEFINE vConvenio			CHAR(5);

	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cDesc_Error			= "";
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET dFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cTemplateId			= "";
	LET vcuenta				= 0;
	LET vCodRet				= '00000';
	LET p_moneda_origen		= '';
	LET p_importe_origen	= 0;
	LET vCategoria			= '07';
	LET vConvenio			= '';
	

BEGIN
	ON EXCEPTION SET iSqlErr, iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;

			EXECUTE PROCEDURE "informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSqlErr,iIsamErr,cCadena_ent,pUsuario,dFechaProceso) 
			INTO cCodRetAux;

			IF cCodRetAux <> '00000' THEN
				LET cCodRet = cCodRetAux;
			END IF
			--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
				LET cTxnStatus		 = 'C';
			--	2014.11.11 FRG-f

			INSERT INTO "informix".sac_wu_pay	
				(txn_status, benef_nametype, money_transfer_key, new_mtcn, mtcn, foreign_rs_refnum_rq, retcode, foreign_rs_refnum_rp, desc_error, user_insert, fecha_insert,conf_pago,numcte)			
			VALUES
				(cTxnStatus, pBenefNameType, pMoneyTransferKey,pNewMtcn, pMtcn, pForeignRefNumRq, cRetCode, pForeingRefNumRp, pDesError, pUserInsert, current,pConf_pago,pNumClienteRemesa);
			
			RETURN cCodRet, cError_Desc;
		END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/christian/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pRetCode = '504' THEN
	    LET cRetCode = '99999';
		LET pDesError = 'Aplicativo WU no activo, validar';
	END  IF;

	IF pRetCode <>  '504' AND pRetCode <> '00000' AND pRetCode <> '66666' THEN		
        IF pRetCode <> '20001' then
            LET cRetCode = '99998';
            LET pDesError = 'Sin respuesta del aplicativo, validar';
        ELIF pRetCode = '20001' then
            LET cRetCode = '20001';
            LET pDesError = 'Caracter invalido en la cadena';
        END IF;
	END IF;

	IF pRetCode = '66666' THEN
		LET cDesc_Error = pDesError;
		LET cRetCode = pRetCode;
	END IF
		
	SELECT valor
	INTO cChannelType
	FROM "informix".sac_param 
	WHERE cod_param = '87050';  
	 
	SELECT valor
	INTO cChannelName
	FROM "informix".sac_param 
	WHERE cod_param = '87051'; 
	 
	SELECT valor
	INTO cChannelVersion
	FROM "informix".sac_param 
	WHERE cod_param = '87052'; 
	
	SELECT valor
	INTO cTemplateId
	FROM "informix".sac_param 
	WHERE cod_param = '87063';

	--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
		LET	cTxnStatus	= 'A';
	--	2014.11.11 FRG-f

	INSERT INTO "informix".sac_wu_pay	
	(txn_status, benef_nametype, money_transfer_key, new_mtcn, mtcn, foreign_rs_refnum_rq, retcode, foreign_rs_refnum_rp, desc_error, user_insert, fecha_insert,conf_pago,numcte)			
	VALUES
	(cTxnStatus, pBenefNameType, pMoneyTransferKey,pNewMtcn, pMtcn, pForeignRefNumRq, cRetCode, pForeingRefNumRp, pDesError, pUserInsert, current,pConf_pago,pNumClienteRemesa);
	
	IF  cCodRet <> '00000' THEN
		IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
			RETURN cCodRet,cError_Desc;	
		END IF;
		
		RETURN cCodRet,cError_Desc;		
	ELSE
		--Busco datos de query
		EXECUTE PROCEDURE bdisac:"informix".sp_obtieneremadic(vCategoria, '999', pMtcn)
		INTO vCodRet, p_moneda_origen, p_importe_origen;
		
		--Obtengo el convenio de la familia de WU
		SELECT FIRST 1 numconvenio
		INTO   vConvenio
		FROM   sac_remesas_estadistica
		WHERE  referencia   = pMtcn
		AND    numcategoria = vCategoria;
		
		--Actualizo tabla de datos para limites de remesas mensuales
		LET vfec_nac = MDY(SUBSTRING(pBenefFechNac FROM 3 FOR 2), SUBSTRING(pBenefFechNac FROM 1 FOR 2), SUBSTRING(pBenefFechNac FROM 5 FOR 4));
		EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, pMtcn, pBenefNombreUno, pBenefNombreDos, pBenefApaterno, pBenefAmaterno, vfec_nac, p_moneda_origen, p_importe_origen)
		INTO vCodRet, vcuenta;
		
		IF cCodRet = '00000' THEN
			LET cError_Desc = "Ejecucion SP exitosa";
		END IF;	
		
	   RETURN cCodRet,cError_Desc;
	END IF;	
END;
END PROCEDURE;