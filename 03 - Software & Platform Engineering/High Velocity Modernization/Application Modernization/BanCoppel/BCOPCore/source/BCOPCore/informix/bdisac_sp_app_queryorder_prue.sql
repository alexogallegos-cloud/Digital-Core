CREATE PROCEDURE "informix".sp_app_queryorder_prue
(		
		pTxn_status				CHAR  (1),
		pUnirefnum				CHAR  (16),
		pCode_Company			CHAR  (3),
		pChanneldid				CHAR  (3),
		pLocationunit			CHAR  (15),
		pNnumber				CHAR  (15),
		pTypecode_Branch		CHAR  (3),	
		pCountrycode_Branch		CHAR  (3),
		pStatecode_Branch		CHAR  (3),
		pTerminalid				CHAR  (15),
		pProcessdate_Qry		CHAR  (8),
		pProcesstime_Qry		CHAR  (6),
		pCode_Operacion			CHAR  (5),
		pCode					CHAR  (4),
		pMessage				CHAR  (255),
		pCode_d					CHAR  (4),
		pMessage_d				CHAR  (255),
		pProcessDate			CHAR  (8),
		pProcessTime			CHAR  (6),
		pRule					CHAR  (3),
		pValue					CHAR  (3),
		pGlobalTrackingNumber	CHAR  (20),
		pOrderStatusCode		CHAR  (3),
		pOrderStatusDate		CHAR  (8),
		pOrderStatusTime		CHAR  (6),
		pUniqueReferenceNumber	CHAR  (16),
		pCodesalecom			CHAR  (3),
		pCountryCode			CHAR  (3),
		pStateCodeSale			CHAR  (3),
		pSaleDate				CHAR  (8),
		pSaleTime				CHAR  (6),
		pCountryCode_o			CHAR  (3),
		pCurrencyCode			CHAR  (3),
		pServiceCode			CHAR  (3),
		pCountryCode_d			CHAR  (3),
		pCurrencyCode_d			CHAR  (3),
		pDeliveryMethodCode		CHAR  (3),
		pPayNetworkCode			CHAR  (3),
		pPaySubNetworkCode		CHAR  (15),
		pBranchNumber			CHAR  (15),
		pAccountTypeCode		CHAR  (3),
		pAccountNumber			CHAR  (30),
		pOriginAmount			CHAR  (20),
		pDestinationAmount		CHAR  (20),
		pRetailExchangeRate		CHAR  (21),
		pWholesaleExchangeRate	CHAR  (21),
		pDestinExchangeRate 	CHAR  (21),
		pServiceFeeAmount		CHAR  (20),
		pDiscountAmount			CHAR  (20),
		pTypeCode				CHAR  (3),
		pAccountNumber_c		CHAR  (30),
		pBicCode				CHAR  (11),
		pReferenceNumber		CHAR  (30),
		pCustomerNumber			CHAR  (20),
		pFirstName				CHAR  (40),
		pMiddleName				CHAR  (40),
		pLastName				CHAR  (40),
		pMotherMaidenName		CHAR  (40),
		pAddress				CHAR  (80),
		pCity					CHAR  (40),
		pCountryCode_a			CHAR  (3),
		pStateCode				CHAR  (3),
		pZipCode				CHAR  (10),
		pTypeCode_i				CHAR  (3),
		pNumber					CHAR  (20),
		pExpirationDate			CHAR  (8),
		pIssuerCountryCode		CHAR  (3),
		pIssuerStateCode		CHAR  (3),
		pDateOfBirth			CHAR  (8),
		pCustomerNumber_b		CHAR  (20),
		pFirstName_b			CHAR  (40),
		pMiddleName_b			CHAR  (40),
		pLastName_b				CHAR  (40),
		pMotherMaidenName_b		CHAR  (40),
		pFirstName_f			CHAR  (40),
		pMiddleName_f			CHAR  (40),
		pLastName_f				CHAR  (40),
		pMotherMaidenName_f		CHAR  (40),
		pAddress_b				CHAR  (80),
		pCity_b					CHAR  (40),
		pCountryCode_b			CHAR  (3),
		pStateCode_b			CHAR  (3),
		pZipCode_b				CHAR  (10),
		pEmail					CHAR  (100),
		pHomePhoneNumber		CHAR  (15),
		pWorkPhoneNumber		CHAR  (15),
		pNumber_cl				CHAR  (15),
		pReceiveEmail			CHAR  (3),
		pReceiveSMS				CHAR  (3),
		pTypeCode_ib			CHAR  (3),
		pNumber_ib				CHAR  (20),
		pExpirationDate_ib		CHAR  (8),
		pIssuerCountryCode_ib	CHAR  (3),
		pIssuerStateCode_ib		CHAR  (3),
		pReasonTypeCode			CHAR  (3),
		pReasonForTransfer		CHAR  (40),
		pSourceOfFunds			CHAR  (40),
		pSecurityPhrase			CHAR  (40),
		pFreeMessage			CHAR  (255),
		pUsuario				CHAR  (8),
		pModo					SmallInt
)
RETURNING CHAR (5) AS cCodRet,CHAR (255) AS cMensCode,CHAR (255) AS cMensajeD;

		--Declaracion de variables 
		DEFINE cCodRet 		    CHAR(5);
		DEFINE iSqlErr			INT;
		DEFINE cStatus			CHAR(1);
		DEFINE cMensCode		CHAR(255);
		DEFINE cMensajeD		CHAR(255);
		DEFINE cCodRetMessg		CHAR(5);
		DEFINE cCod_estado_sucursal CHAR(2);
		DEFINE cCod_estado_remesa		CHAR(2);
	
		
		LET cCodRet 			= '00000'; 
		LET iSqlErr				= 0;
		LET cStatus				= '';
		LET cMensCode			= '';
		LET cMensajeD			= '';
		LET cCodRetMessg		= '';
		LET cCod_estado_sucursal = '';
		LET cCod_estado_remesa = '';

		--SET DEBUG FILE TO '/tmp/adrian/sp_app_queryorder.out';
		--TRACE ON;	
		

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensCode,cMensajeD;
		END IF;
	END EXCEPTION;
	
	
	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
	
	IF pTxn_status = '' OR pUnirefnum = '' OR  pCode_Company = '' OR  pChanneldid = '' OR pLocationunit = '' OR  pNnumber = '' OR  pTypecode_Branch = '' OR pCountrycode_Branch = '' OR 
		pStatecode_Branch = '' OR  pTerminalid	= '' THEN
		LET cCodRet = '00001';
	
	ELSE 
		EXECUTE PROCEDURE bdisac:"informix".sp_app_mensajes ('QRYI', pCode,pCode_d) INTO cCodRetMessg,cMensCode,cMensajeD;
		IF cCodRetMessg <> '00000' THEN
			LET cMensCode = pMessage;
			LET cMensajeD = pMessage_d;
		END IF ;
		
		--Almacenar datos en bdisac: sac_app_qryi
		INSERT INTO bdisac:"informix".sac_app_qryi (txn_status,unirefnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,r_operacion,r_code,
		r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,
		r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,
		r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,
		r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,
		r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,
		r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,
		r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,
		r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha)
		VALUES (pTxn_status,pUnirefnum,pCode_Company,pChanneldid,pLocationunit,pNnumber,pTypecode_Branch,pCountrycode_Branch,pStatecode_Branch,pTerminalid,pProcessdate_Qry,pProcesstime_Qry,
		pCode_Operacion,pCode,cMensCode,pCode_d,cMensajeD,pProcessDate,pProcessTime,pRule,pValue,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,pUniqueReferenceNumber,
		pCodesalecom,pCountryCode,pStateCodeSale,pSaleDate,pSaleTime,pCountryCode_o,pCurrencyCode,pServiceCode,pCountryCode_d,pCurrencyCode_d,pDeliveryMethodCode,pPayNetworkCode,pPaySubNetworkCode,
		pBranchNumber,pAccountTypeCode,pAccountNumber,pOriginAmount,pDestinationAmount,pRetailExchangeRate,pWholesaleExchangeRate,pDestinExchangeRate ,pServiceFeeAmount,pDiscountAmount,pTypeCode,
		pAccountNumber_c,pBicCode,pReferenceNumber,pCustomerNumber,pFirstName,pMiddleName,pLastName,pMotherMaidenName,pAddress,pCity,pCountryCode_a,pStateCode,pZipCode,
		pTypeCode_i,pNumber,pExpirationDate,pIssuerCountryCode,pIssuerStateCode,pDateOfBirth,pCustomerNumber_b,pFirstName_b,pMiddleName_b,pLastName_b,pMotherMaidenName_b,pFirstName_f,
		pMiddleName_f,pLastName_f,pMotherMaidenName_f,pAddress_b,pCity_b,pCountryCode_b,pStateCode_b,pZipCode_b,pEmail,pHomePhoneNumber,pWorkPhoneNumber,pNumber_cl,
		pReceiveEmail,pReceiveSMS,pTypeCode_ib,pNumber_ib,pExpirationDate_ib,pIssuerCountryCode_ib,pIssuerStateCode_ib,pReasonTypeCode,pReasonForTransfer,pSourceOfFunds,
		pSecurityPhrase,pFreeMessage,pUsuario,CURRENT);
		
	END IF;
	/*
	IF pCode_Operacion = '00000' AND pCode = '0000' AND TRIM(pOrderStatusCode) = 'NPD' THEN
		SELECT estado INTO cCod_estado_sucursal FROM bdinteg:"informix".si_sucursales where sucursal=pNnumber;
		SELECT cod_estado INTO  cCod_estado_remesa FROM "informix".sac_estaremesasorig where cve_prov_estado=pStateCode_b AND remesadora='APP';
		
		IF EXISTS (Select cod_estado,nom_estado,cve_prov_estado from "informix".sac_estaremesasorig where cve_prov_estado = pStateCode_b  and remesadora='APP') THEN
				IF cCod_estado_sucursal = cCod_estado_remesa THEN
					RETURN cCodRet,cMensCode,cMensajeD;
				ELSE	
					IF EXISTS (SELECT cod_estado,nom_estado,cod_excep,tipo_excep,remesadora FROM "informix".sac_edosremorigexcep WHERE cod_estado = cCod_estado_remesa) THEN 
						IF EXISTS (SELECT cod_estado,nom_estado,cod_excep,tipo_excep,remesadora FROM "informix".sac_edosremorigexcep WHERE remesadora ='APP' and cod_estado = cCod_estado_remesa and ((cod_excep = TO_CHAR(pNnumber) AND tipo_excep = 'S') OR (cod_excep = cCod_estado_sucursal AND tipo_excep = 'E'))) THEN
								RETURN cCodRet,cMensCode,cMensajeD;
						ELSE
								INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'001',pUnirefnum,'APP',CURRENT);
								LET cCodRet = '00005';								
								RETURN cCodRet,cMensCode,cMensajeD;
						END IF;
					ELSE
						INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'001',pUnirefnum,'APP',CURRENT);
						LET cCodRet = '00005';
						RETURN cCodRet,cMensCode,cMensajeD;
					
					END IF;			
				END IF;

		ELSE
			--INSERT INTO "informix".sac_edosremorig_bitacora (sucursal,cod_estado_suc,cve_estado_prov,cod_estado_prov,cod_validacion,num_remesa,remesadora,fecha_insert) VALUES (pNnumber,cCod_estado_sucursal,pStateCode_b,cCod_estado_remesa,'002',pUnirefnum,'APP',CURRENT);
			--LET cCodRet = '00004';			
			RETURN cCodRet,cMensCode,cMensajeD;			
		END IF;
	ELSE*/	
		RETURN cCodRet,cMensCode,cMensajeD;
	--END IF;
	
	
		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 97498531',
'Nombre : Oscar Millan Rivas',
'DESCRIPCION: Genera trama para pago de remesas Appriza pay, valida el estado de origen con el estado al que pertenece sucursal',
'FOLIO:330',
'FECHA :16 nov 17 ',
'VERSION: ',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE  "informix".sp_valida_hipinfonavitdv(pNumReferencia CHAR(10))
	RETURNING 
		CHAR(5) AS CodigoRetorno;

	--DEFINICION DE LAS VARIABLES
	DEFINE iCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE isumapares INTEGER;
	DEFINE isumanones INTEGER;
	DEFINE iresiduo INTEGER;
	DEFINE idv INTEGER;
	DEFINE idvcapturado INTEGER;
	DEFINE icont INTEGER;
	DEFINE icos DECIMAL;

	--INICIALIZACION DE LAS VARIABLES
	LET iCodRet= '00000';
	LET iSqlErr= 0;
	LET isumapares= 0;
	LET isumanones= 0;
	LET iresiduo= 0;
	LET idv= 0;
	LET idvcapturado=0;
	LET icont = 1;
	LET icos = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
		IF (iSqlErr != 0) THEN
			LET iCodRet = iSqlErr;
			RETURN iCodRet;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/informix/HMLG/sp_hipdv.out';
		--TRACE ON;	

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF TRIM(pNumReferencia) = '' THEN
			LET iCodRet = '00080';
		ELIF LENGTH(pNumReferencia) <> 10 THEN
			LET iCodRet = '00047';
		ELIF pNumReferencia = '0000000000' THEN 
			LET iCodRet = '00109';
		ELSE
			--PASO 1 SUMAR POSICIONES NONES Y PARES DE LA REFERENCIA EXCLUYENDO POSICION 10
			WHILE icont <= 10
				IF icont = 10 THEN 
					LET idvcapturado = SUBSTR(pNumReferencia,icont,1)::INTEGER;
				ELSE
					IF MOD(icont,2) = 0 THEN
						LET isumapares = isumapares + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					ELSE
						LET isumanones = isumanones + SUBSTR(pNumReferencia,icont,1)::INTEGER;
					END IF;
				END IF;
				LET icont = icont + 1;
			END WHILE;
			
			--PASO 2 EL RESULADO DE LA SUMATORIA DE LOS NONES SE DIVIDE ENTRE 10
			LET iresiduo = MOD(isumanones,10);
			
			--PASO 3 EL RESIDUO DE LA ADIVISION ANTERIOR SE DIVIDE ENTRE 5, TAMBIEN SE GUARDA EL COSIENTE DE LA DIVISION
			--LET iresiduo = MOD(iresiduo,5);
			LET icos = iresiduo / 5;
			
			--PASO 4 EL RESULTADO DE LA SUMA DE LOS NONES DEL PASO 1 SE MULTIPLICA POR 2, Se vuelve a inicializar la variable icont para reciclarla
			LET icont = 0;  
			LET icont = isumanones * 2;
			
			-- PASO 5 AL RESULTADO DEL PUNTO 4 SE LE SUMA EL RESULTADO DE LA SUMA DE LOS PARES DEL PASO 1
			LET icont = icont + isumapares;
			
			-- PASO 6 AL RESULTADO DEL PASO 5 SE LE SUMA EL COSIENTE DE LA DIVISION DEL PASO 3
			LET icont = icont + icos;
			
			-- PASO 7 AL RESULTADO DEL PASO 6 SE DIVIDE ENTRE 10
			LET icont = MOD(icont,10);
			
			-- PASO 8 EL DV ES EL RESIDUO DEL PASO 7
			LET iresiduo = icont;
			
			-- SI EL DV CAPTURADO ES EL MISMO QUE EL CALCULADO EL CODIGO DE RETORNO ES CORRECTO (00000).
			IF iresiduo <> idvcapturado AND  iCodRet = '00000' then
				LET iCodRet = '00109';
			END IF
			
		END IF;
		
		RETURN iCodRet;
		
	END;
END PROCEDURE;