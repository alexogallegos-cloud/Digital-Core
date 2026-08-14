CREATE PROCEDURE "informix".sp_app_mensajes
(
	pAgentTrans   CHAR (4),
	pCode		  CHAR (4),
	pDetailCode	  CHAR (4)
)
RETURNING CHAR (5) AS cCodRet, CHAR (255) AS cMesssage, CHAR (255) AS cDetailMesssage;

--Declaracion de variables 
		DEFINE cCodRet 		    CHAR(5);
		DEFINE iSqlErr			INTEGER;
		DEFINE cMesssage		CHAR (255);
		DEFINE cDetailMesssage	CHAR(255);
		
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
        LET cMesssage			= '';
        LET cDetailMesssage		= '';
		LET iSqlErr				= 0;
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMesssage, cDetailMesssage;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_app_mensajes.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(pAgentTrans, '') = '' OR NVL(pCode, '') = '' OR NVL(pDetailCode, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cMesssage, ''),  NVL(cDetailMesssage, '');
		ELSE
			--Obtenemos los mensajes 
			SELECT opcode_ds INTO   cMesssage FROM   bdisac: "informix".sac_app_cat_mensajes
			WHERE  agent_trans_type_code = pAgentTrans AND opcode = pCode;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				LET cCodRet = '00002';
			ELSE
				LET cCodRet = '00001';
			END IF;
			
			SELECT opcode_ds INTO cDetailMesssage FROM bdisac: "informix".sac_app_cat_mensajesdetail 
			where agent_trans_type_code = pAgentTrans AND opcode = pCode AND opcode_detail = pDetailCode;
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				IF cCodRet = '00001' THEN
					LET cCodRet = '00001';
				ELSE
					LET cCodRet = '00003';
				END IF;
			ELSE
				IF cCodRet = '00001' THEN
					LET cCodRet = '00000';
				ELSE
					LET cCodRet = '00002';
				END IF;
			END IF;
			
			RETURN cCodRet, NVL(cMesssage, ''),  NVL(cDetailMesssage, '') ;
			
		END IF;

		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: BuscarÃ¡ los mensajes de los CÃ³digos de respuesta recibidos para la remesa Aprizza, usara las tablas sac_app_cat_mensajes y sac_app_cat_mensajes_detail',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 17/03/2016',
'VERSION: 20160317.1505',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_queryorder
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
		pUsuario				CHAR  (8)
)
RETURNING CHAR (5) AS cCodRet,CHAR (255) AS cMensCode,CHAR (255) AS cMensajeD;

		--Declaracion de variables 
		DEFINE cCodRet 		    CHAR(5);
		DEFINE iSqlErr			INT;
		DEFINE cStatus			CHAR(1);
		DEFINE cMensCode		CHAR(255);
		DEFINE cMensajeD		CHAR(255);
		DEFINE cCodRetMessg		CHAR(5);
		
		LET cCodRet 			= '00000'; 
		LET iSqlErr				= 0;
		LET cStatus				= '';
		LET cMensCode			= '';
		LET cMensajeD			= '';
		LET cCodRetMessg		= '';

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cMensCode,cMensajeD;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/home/sysifx/JesusBueno/Appriza/sp_app_QueryOrderResponsev1.out';
	--TRACE ON;	
	
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
		
	RETURN cCodRet,cMensCode,cMensajeD;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95347143',
'Nombre : Jesus Isaias Bueno',
'DESCRIPCION: Genera trama para pago de remesas Appriza pay',
'FOLIO:',
'FECHA : ',
'VERSION: ',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_submitpayment
(
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	pterminalid			CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pcustomernumber		CHAR(20),
	pfirstname			CHAR(40),
	pmiddlename			CHAR(40),
	plastname			CHAR(40),
	pmommaidenname	 	CHAR(40),
	padress				CHAR(80),
	pcity				CHAR(40),
	pcountrycodeadr		CHAR(3),
	pstatecodeadr		CHAR(3),
	pzipcode			CHAR(10),
	pemail				CHAR(100),
	phomephonenum		CHAR(15),
	pnumbercel			CHAR(15),
	preceiveemail		CHAR(3),
	preceivesms			CHAR(3),
	ptypecodeci			CHAR(3),
	pnumberci			CHAR(20),
	pexpirationdate		CHAR(8),
	pissuercc			CHAR(3),
	pdateofbirth		CHAR(8),
	pcontrycode			CHAR(5),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_rule				CHAR(3),
	pr_value			CHAR(3),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_codesalecom		CHAR(3),
	pr_countrycode		CHAR(3),
	pr_statecodesale	CHAR(3),
	pr_saledate			CHAR(8),
	pr_saletime			CHAR(6),
	pr_countrycode_o	CHAR(3),
	pr_currencycode		CHAR(3),
	pr_servicecode		CHAR(3),
	pr_countrycode_d	CHAR(3),
	pr_currencycod_d	CHAR(3),
	pr_delimethodcod	CHAR(3),
	pr_playnwcode		CHAR(3),
	pr_paysubnwcode		CHAR(15),
	pr_branchnumber		CHAR(15),
	pr_accounttcod		CHAR(3),
	pr_accountnumber	CHAR(30),
	pr_originamount		CHAR(20),
	pr_destinamount		CHAR(20),
	pr_rexchangerate	CHAR(21),
	pr_wholesalerate	CHAR(21),
	pr_deexhangerate	CHAR(21),
	pr_servfeeamount	CHAR(20),
	pr_discountamoun	CHAR(20),
	pr_typecode			CHAR(3),
	pr_accountnum		CHAR(30),
	pr_biccode			CHAR(11),
	pr_refnumber		CHAR(30),
	pr_customernum		CHAR(20),
	pr_firstname		CHAR(40),
	pr_middlename		CHAR(40),
	pr_lastname			CHAR(40),
	pr_mommaidenname 	CHAR(40),
	pr_address			CHAR(80),
	pr_city				CHAR(40),
	pr_countrycode_a	CHAR(3),
	pr_statecode		CHAR(3),
	pr_zipcode			CHAR(10),
	pr_typecode_i		CHAR(3),
	pr_number			CHAR(20),
	pr_expirdate		CHAR(8),
	pr_isscontrycode	CHAR(3),
	pr_issstatecode		CHAR(3),
	pr_dateofbirth		CHAR(8),
	pr_customernum_b 	CHAR(20),
	pr_firstname_b		CHAR(40),
	pr_middlename_b		CHAR(40),
	pr_lastname_b		CHAR(40),
	pr_mommaidenna_b 	CHAR(40),
	pr_firstname_f		CHAR(40),
	pr_middlename_f		CHAR(40),
	pr_lastname_f		CHAR(40),
	pr_mommaidenna_f 	CHAR(40),
	pr_address_b		CHAR(80),
	pr_city_b			CHAR(40),
	pr_countrycode_b	CHAR(3),
	pr_statecode_b		CHAR(3),
	pr_zipcode_b		CHAR(10),
	pr_email			CHAR(100),
	pr_homephonenum 	CHAR(15),
	pr_workphonenum		CHAR(15),
	pr_number_cl		CHAR(15),
	pr_receiveemail		CHAR(3),
	pr_receivesms		CHAR(3),
	pr_typecode_ib		CHAR(3),
	pr_number_ib		CHAR(20),
	pr_expirdate_ib		CHAR(8),
	pr_issconcode_ib	CHAR(3),
	pr_issstacode_ib	CHAR(3),
	pr_reastypecode		CHAR(3),
	pr_refortransfer	CHAR(40),
	pr_sourceoffunds	CHAR(40),
	pr_securphrase		CHAR(40),
	pr_feemessage		CHAR(255),
	puser_insert		CHAR(8),
	pfecha				DATE
)
RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (255) AS cr_Message, --1.2
		  CHAR (255) AS cr_Message_Detail; --1.3.2
		  
	  
--Declaracion de variables 
		DEFINE cCodRet 		    	CHAR(5);
		DEFINE iSqlErr				INTEGER;
		DEFINE imenscode			INTEGER;
		DEFINE cr_Message			CHAR (255);
		DEFINE cr_Message_Detail	CHAR (255);
		
		DEFINE crsp_CodRet			CHAR(5);
		DEFINE crsp_Message			CHAR (255);
		DEFINE crsp_Message_Detail	CHAR (255);
		DEFINE c_Mess_D				CHAR (255);
		
		
-----------------------------------------------------------------------------------------------------------------------------------
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				= 0;
		LET imenscode			= 0;
        LET cr_Message			= pr_message;
		LET cr_Message_Detail	= pr_message_d;
		
		LET crsp_CodRet			= '';
		LET crsp_Message		= '';
		LET crsp_Message_Detail	= '';
		LET c_Mess_D			= pr_message_d;
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cr_Message, cr_Message_Detail;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_app_submitpayment.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(puser_insert, '') = '' OR NVL(pfecha, '') = '' OR NVL(prefnum, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '');

		ELSE
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espaÃ±ol 
			EXECUTE PROCEDURE BDISAC: "informix".sp_app_mensajes ('PAYI', pr_code, pr_code_d)
			INTO crsp_CodRet, crsp_Message, crsp_Message_Detail;	
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				-- no trajo resultados del llamado al sp
				LET cCodRet = '00001';
			ELSE
				IF crsp_CodRet = '00000' THEN
					LET cr_Message = crsp_Message;
					LET imenscode = 1;
				ELSE
					IF crsp_CodRet = '00001' THEN
						LET cr_Message = crsp_Message;
					ELSE
						IF crsp_CodRet = '00002' THEN
							LET imenscode = 1;
						END IF;
					END IF;
				END IF;
			END IF;
			IF imenscode = 1 then
				IF pr_code_d = "D001" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D002" THEN
					LET imenscode = 28;
				ELIF  pr_code_d = "D003" THEN
					LET imenscode = 19;
				ELIF  pr_code_d = "D004" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D005" THEN
					LET imenscode = 20;
				END IF;
				-- corta parametro en mensaje ingles "Required Parameter: {0} Parameter Key"
				LET c_Mess_D = SUBSTR(c_Mess_D, imenscode);
				LET c_Mess_D = REPLACE(c_Mess_D, " Parameter Key","");
				-- concatenar parametro con el mensaje en espaÃ±ol "El parÃ¡metro requerido: {0} parÃ¡metro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			--Inserta registro
			IF (cCodRet = '00000')THEN
								
				INSERT INTO bdisac: "informix".sac_app_payi (txn_status,unirefnum,refnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,customernumber,firstname,middlename,lastname,mommaidenname,adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms,typecodeci,numberci,expirationdate,issuercc,dateofbirth,contrycode,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha) 
				VALUES (ptxn_status, punirefnum, prefnum, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, pterminalid, pprocessdate, pprocesstime, pcustomernumber, pfirstname, pmiddlename, plastname, pmommaidenname, padress, pcity, pcountrycodeadr, pstatecodeadr, pzipcode, pemail, phomephonenum, pnumbercel, preceiveemail, preceivesms, ptypecodeci, pnumberci, pexpirationdate, pissuercc, pdateofbirth, pcontrycode, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail,  pr_processdate, pr_processtime, pr_rule, pr_value, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, pr_uniquerefnum, pr_codesalecom, pr_countrycode, pr_statecodesale, pr_saledate, pr_saletime, pr_countrycode_o, pr_currencycode, pr_servicecode, pr_countrycode_d, pr_currencycod_d, pr_delimethodcod, pr_playnwcode, pr_paysubnwcode, pr_branchnumber, pr_accounttcod, pr_accountnumber, pr_originamount, pr_destinamount, pr_rexchangerate, pr_wholesalerate, pr_deexhangerate, pr_servfeeamount, pr_discountamoun, pr_typecode, pr_accountnum, pr_biccode, pr_refnumber, pr_customernum, pr_firstname, pr_middlename, pr_lastname, pr_mommaidenname, pr_address, pr_city, pr_countrycode_a, pr_statecode, pr_zipcode, pr_typecode_i, pr_number, pr_expirdate, pr_isscontrycode, pr_issstatecode, pr_dateofbirth, pr_customernum_b, pr_firstname_b, pr_middlename_b, pr_lastname_b, pr_mommaidenna_b, pr_firstname_f, pr_middlename_f, pr_lastname_f, pr_mommaidenna_f, pr_address_b, pr_city_b, pr_countrycode_b, pr_statecode_b, pr_zipcode_b, pr_email, pr_homephonenum, pr_workphonenum, pr_number_cl, pr_receiveemail, pr_receivesms, pr_typecode_ib, pr_number_ib, pr_expirdate_ib, pr_issconcode_ib, pr_issstacode_ib, pr_reastypecode, pr_refortransfer, pr_sourceoffunds, pr_securphrase, pr_feemessage, puser_insert, CURRENT);
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				END IF;
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;

		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: ServirÃ¡ para insertar en la tabla sac_app_payi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_submitpayreversal
(
	ptxn_status			CHAR(1),
	punirefnum			CHAR(16),
	prefnum				CHAR(30),
	pprocretypecode		CHAR(3),
	pcode				CHAR(3),
	pchanneldid			CHAR(3),
	plocationunit		CHAR(15),
	pnnumber			CHAR(15),	
	ptypecode			CHAR(3),
	pcountrycode		CHAR(3),
	pstatecode			CHAR(3),
	terminalid				CHAR(15),
	pprocessdate		CHAR(8),
	pprocesstime		CHAR(6),
	pr_operacion		CHAR(5),
	pr_code				CHAR(4),
	pr_message			CHAR(255),
	pr_code_d			CHAR(4),
	pr_message_d		CHAR(255),
	pr_processdate		CHAR(8),
	pr_processtime		CHAR(6),
	pr_uniquerefnum		CHAR(16),
	pr_globtracknum		CHAR(20),
	pr_ordstatuscode	CHAR(3),
	pr_ordstatusdate	CHAR(8),
	pr_ordstatustime	CHAR(6),
	puser_insert		CHAR(8),
	pfecha				DATE
)
RETURNING CHAR (5)	 AS cCodRet, 
		  CHAR (255) AS cr_Message, --1.2
		  CHAR (255) AS cr_Message_Detail; --1.3.2
		  
	  

	  
--Declaracion de variables 
		DEFINE cCodRet 		    	CHAR(5);
		DEFINE iSqlErr				INTEGER;
		DEFINE imenscode			INTEGER;
		DEFINE cr_Message			CHAR (255);
		DEFINE cr_Message_Detail	CHAR (255);
		
		DEFINE crsp_CodRet			CHAR(5);
		DEFINE crsp_Message			CHAR (255);
		DEFINE crsp_Message_Detail	CHAR (255);
		DEFINE c_Mess_D				CHAR (255);
		
		
-----------------------------------------------------------------------------------------------------------------------------------
		LET cCodRet 			= '00000'; --Codigo 00000 = OK; 00001 = No hubo datos
		LET iSqlErr				= 0;
        LET cr_Message			= pr_message;
		LET cr_Message_Detail	= pr_message_d;
		
		LET crsp_CodRet			= '';
		LET crsp_Message		= '';
		LET crsp_Message_Detail	= '';
		LET c_Mess_D			= pr_message_d;
		LET imenscode			= 0;
		
BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cr_Message, cr_Message_Detail;
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/tmp/sp_app_submitpayreversal.out";
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;  
		
		IF NVL(punirefnum, '') = '' OR NVL(pnnumber, '') = '' OR NVL(puser_insert, '') = '' OR NVL(pfecha, '') = '' OR NVL(prefnum, '') = '' THEN
			 LET cCodRet = '00001';
			 --DATOS VACIOS, ERROR.
			 RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '');
		
		ELSE
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espaÃ±ol 
			EXECUTE PROCEDURE BDISAC: "informix".sp_app_mensajes ('REVI', pr_code, pr_code_d)
			INTO crsp_CodRet, crsp_Message, crsp_Message_Detail;	
			
			IF DBINFO("sqlca.sqlerrd2") = 0 THEN
				-- no trajo resultados del llamado al sp
				LET cCodRet = '00001';
			ELSE
				IF crsp_CodRet = '00000' THEN
					LET cr_Message = crsp_Message;
					LET imenscode = 1;
				ELSE
					IF crsp_CodRet = '00001' THEN
						LET cr_Message = crsp_Message;
					ELSE
						IF crsp_CodRet = '00002' THEN
							LET imenscode = 1;
						END IF;
					END IF;
				END IF;
			END IF;
			IF imenscode = 1 then
				IF pr_code_d = "D001" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D002" THEN
					LET imenscode = 28;
				ELIF  pr_code_d = "D003" THEN
					LET imenscode = 19;
				ELIF  pr_code_d = "D004" THEN
					LET imenscode = 20;
				ELIF  pr_code_d = "D005" THEN
					LET imenscode = 20;
				END IF;
				-- corta parametro en mensaje ingles "Required Parameter: {0} Parameter Key"
				LET c_Mess_D = SUBSTR(c_Mess_D, imenscode);
				LET c_Mess_D = REPLACE(c_Mess_D, " Parameter Key","");
				-- concatenar parametro con el mensaje en espaÃ±ol "El parÃ¡metro requerido: {0} parÃ¡metro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			--Inserta registro
			IF cCodRet = '00000'  THEN
			
				INSERT INTO bdisac: "informix".sac_app_revi (txn_status,unirefnum,refnum,procretypecode,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_uniquerefnum,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,user_insert,fecha) 
				VALUES (ptxn_status, punirefnum, prefnum, pprocretypecode, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, terminalid, pprocessdate, pprocesstime, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail, pr_processdate, pr_processtime, pr_uniquerefnum, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, puser_insert, CURRENT);
		
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				END IF;
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;

		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: ServirÃ¡ insertar en la tabla sac_app_revi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_consdatosticketapp (pFoli_suc CHAR(20))
RETURNING 
CHAR(6)  AS  Cod_Ret,
CHAR(16) AS Num_Ref,
CHAR(40) AS Nombre1,
CHAR(40) AS Nombre2,
CHAR(40) AS Apell_pat,
CHAR(40) AS Apell_mat,
CHAR(3)  AS  Ident,
CHAR(20) AS Num_ident,
CHAR(1)  AS  tp_pago;

--DECLARACIÓN DE VARIABLES
DEFINE cCod_Ret		CHAR(6) ;
DEFINE cNum_Ref     CHAR(16);
DEFINE cNombre1     CHAR(40);
DEFINE cNombre2     CHAR(40);
DEFINE cApell_pat   CHAR(40);
DEFINE cApell_mat   CHAR(40);
DEFINE cIdent       CHAR(3) ;
DEFINE cNum_ident   CHAR(20);
DEFINE ctp_pago     CHAR(1) ;
DEFINE cStatus     CHAR(1) ;
DEFINE iSqlErr     INTEGER;

--INICIALIZA VARIABLES
LET cCod_Ret	='000000';
LET cNum_Ref    ='';
LET cNombre1    ='';
LET cNombre2    ='';
LET cApell_pat  ='';
LET cApell_mat  ='';
LET cIdent      ='';
LET cNum_ident  ='';
LET ctp_pago    ='';
LET cStatus    ='';
LET iSqlErr     =0;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consdatosticketapp.out";
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCod_Ret = iSqlErr;
				RETURN cCod_Ret,TRIM(cNum_Ref),TRIM(cNombre1),TRIM(cNombre2),TRIM(cApell_pat),TRIM(cApell_mat),TRIM(cIdent),TRIM(cNum_ident),TRIM(ctp_pago);
			END IF
		END EXCEPTION;

		
		IF NVL(pFoli_suc,'')='' THEN
			LET cCod_Ret = '000001';
			RETURN cCod_Ret,TRIM(cNum_Ref),TRIM(cNombre1),TRIM(cNombre2),TRIM(cApell_pat),TRIM(cApell_mat),TRIM(cIdent),TRIM(cNum_ident),TRIM(ctp_pago);
		END IF
		
		SELECT  TRIM(payi.unirefnum),TRIM(payi.firstname),TRIM(payi.middlename),TRIM(payi.lastname),TRIM(payi.mommaidenname),TRIM(payi.typecodeci),TRIM(payi.numberci),mov.forma_pago,mov.status_cancelado
		INTO cNum_Ref,cNombre1,cNombre2,cApell_pat,cApell_mat,cIdent,cNum_ident,ctp_pago,cStatus
		FROM "informix".sac_app_payi as payi,
			"informix".sac_movimientos as mov
		WHERE mov.folio_suc = pFoli_suc
		AND payi.unirefnum = mov.referencia1
		AND payi.refnum = mov.folio_suc;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCod_Ret = '000002';
		ELIF cStatus = 'S' THEN
			LET cCod_Ret = '000003';
			LET cNum_Ref    ='';
			LET cNombre1    ='';
			LET cNombre2    ='';
			LET cApell_pat  ='';
			LET cApell_mat  ='';
			LET cIdent      ='';
			LET cNum_ident  ='';
			LET ctp_pago    ='';
		END IF
		
		RETURN cCod_Ret,NVL(TRIM(cNum_Ref),''),NVL(TRIM(cNombre1),''),NVL(TRIM(cNombre2),''),NVL(TRIM(cApell_pat),''),NVL(TRIM(cApell_mat),''),NVL(TRIM(cIdent),''),NVL(TRIM(cNum_ident),''),NVL(TRIM(ctp_pago),'');
		
	END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - Mario Olivo',
'FOLIO:230142-1542',
'DESCRIPCION: Su funcionalidad es para obtener los datos para la reimpresión del ticket',
'FECHA:2016/04/18',
'SOLICITA:Leonardo Hernandez',
'RQM: APPRIZA.DOC',
'VERSION:20160418.1050',
'BD:bdisac.';

CREATE PROCEDURE "informix".sp_dinya_pagaenvios
	(pNumeroControl CHAR(12),
	 pSucursal CHAR(4),
	 pFolioSuc CHAR(16),
	 pIdConvenio CHAR(5))

RETURNING  CHAR(5),CHAR(5), CHAR(16);

DEFINE cCodRet 			 		CHAR(5);
DEFINE iSqlErr			 		INTEGER;
DEFINE cCuentaPrestadora 		CHAR(20);
--DEFINE pImporte					MONEY (16,2); 	-- DSB-TH-20/06/2016- Variable sin utilizar
DEFINE cTransaccCargoPago 		CHAR(4);
DEFINE ctranret					CHAR(4);
DEFINE dfechoy					DATE;
DEFINE msdodisp					MONEY (14,2);
DEFINE mmontoret				MONEY (14,2);
DEFINE cEjecutivo				CHAR(11);
DEFINE mImportePago				MONEY(16,2);
DEFINE dFechaHoy				DATE;
DEFINE cTransaccSuc				CHAR(4);
DEFINE iCargo                   INTEGER;
DEFINE cCodRet2					CHAR(5);
DEFINE cMensaje					CHAR(200);
DEFINE isam_error				INTEGER;
--	2013.11.01 FRG-i
DEFINE iIsamErr    				INTEGER;
DEFINE cInfoErr    				CHAR(100);

DEFINE CdRetVerSis 				CHAR (5);
DEFINE IndCrreCred 				CHAR (1);
DEFINE IndDispCred 				CHAR (1);
DEFINE IndCrreChqs 				CHAR (1);
DEFINE IndDispChqs 				CHAR (1);
DEFINE IndCrreInvs 				CHAR (1);
DEFINE IndDispInvs 				CHAR (1);
DEFINE IndCrreSrvs 				CHAR (1);
--	2013.11.01 FRG-f

	--SET DEBUG FILE TO "/home/sysifx/Trinidad/homo_APP/sp_dinya_pagaenvios.out";
	--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,isam_error,cMensaje
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			If iCargo = 1 THEN
				CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
				INSERT INTO bdisac:"informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
				VALUES (iSqlErr,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			END IF;
			RETURN '00000',cCodRet, pFolioSuc;
		END IF;
	END EXCEPTION;

	LET cCodRet 			   = '00000';
	LET iSqlErr			 	   = 0;
	LET cCuentaPrestadora 	   = '';
	LET cTransaccCargoPago	   = '';
	LET ctranret			   = '';
	LET dfechoy				   = '';
	LET msdodisp			   = '';
	LET mmontoret			   = '';
	LET mImportePago		   = '';
	LET dFechaHoy			   = '';
	LET cEjecutivo = SUBSTR(pFolioSuc,1,8);
	LET cTransaccSuc		   = '';
	LET iCargo                 = 0;
	LET cCodRet2			   = '';
	LET cMensaje			   = '';
	LET isam_error			   = '';

--	2013.11.01 FRG-i
     LET iIsamErr    		   = 0;
	 LET cInfoErr    		   = '';

	 LET CdRetVerSis		   = '';
	 LET IndCrreCred 		   = '';
	 LET IndDispCred 	       = '';
	 LET IndCrreChqs 	       = '';
	 LET IndDispChqs 	       = '';
	 LET IndCrreInvs 	       = '';
	 LET IndDispInvs 	       = '';
	 LET IndCrreSrvs 	       = '';
--	2013.11.01 FRG-f

	SET ISOLATION TO CURSOR STABILITY;
	SET LOCK MODE TO WAIT 10;

--	2013.11.01 FRG-i
	-- Validación Disponibilidad Servicio:
	EXECUTE FUNCTION bdinteg:  "informix".verifica_sistemas() -- Se validan cierres de los sistemas antes de iniciar proceso de PGPROG:
	INTO CdRetVerSis, IndCrreCred, IndDispCred, IndCrreChqs, IndDispChqs, IndCrreInvs, IndDispInvs, IndCrreSrvs;
		
		if IndCrreSrvs <> '1'
			then
				LET cCodRet = '00060';
				LET iSqlErr = 0;
				LET iIsamErr = 0;
				LET cInfoErr = 'Sistema Servicios No Disponible.';
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--				EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
				RETURN '00000',cCodRet, pFolioSuc;
			else
					if IndCrreChqs <> '1'
						then
							LET cCodRet = '00061';
							LET iSqlErr = 0;
							LET iIsamErr = 0;
							LET cInfoErr = 'Sistema Cheques No Disponible.';
							EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--							EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
							RETURN '00000',cCodRet, pFolioSuc;
						else
							if IndDispChqs <> '1'
								then
									LET cCodRet = '00062';
									LET iSqlErr = 0;
									LET iIsamErr = 0;
									LET cInfoErr = 'Sistema Cheques Temporalmente Fuera de Servicio.';
									EXECUTE PROCEDURE bdisac:"informix".sp_sac_GuardaMensajeerror (iSqlErr, iIsamErr, cInfoErr, "sp_dinya_pagaenvios");
--									EXECUTE PROCEDURE bdimnsj:sp_registra_evento ('Agregar parámetros con apoyo de MO/JG');
									RETURN '00000',cCodRet, pFolioSuc;
								else
							end if;
					end if;
		end if;
--	2013.11.01 FRG-f

	IF NOT EXISTS (SELECT {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} no_control FROM bdisac: "informix".sac_enviosdineroya WHERE no_control = pNumeroControl AND estatus = '01') THEN
		LET cCodRet = '00002';
		RETURN '00000',cCodRet, pFolioSuc;
	END IF;

	SELECT {+INDEX (bdisac:  "informix".sac_enviosdineroya idxsac_envdinya13_1)} importe_pago
	INTO mImportePago
	FROM Bdisac: "informix".sac_enviosdineroya
	WHERE no_control = pNumeroControl and estatus is not null;

	--Obtiene parametros
	SELECT valor INTO cCuentaPrestadora
	FROM Bdisac: "informix".sac_param
	WHERE cod_param='75';

	IF pIdConvenio = '07002' THEN

		SELECT valor INTO cTransaccCargoPago
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='41407002';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param = '807002';

		let pNumeroControl = pNumeroControl;
		
		--Cargo a la cuenta del cte por el monto cargo.
		CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoPago, cTransaccSuc, pFolioSuc,
		cCuentaPrestadora, 0, mImportePago,"01", pNumeroControl, '', cEjecutivo)
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00001'; --Error en el cargo para el pago del envio
			RETURN '00000',cCodRet,pFolioSuc;
		ELSE
			--Bandera para reversar en caso de que el procedimiento no se termine exitosamente
			LET iCargo = 1;
		END IF;

		SELECT fecha_hoy INTO dFechaHoy FROM sac_fechas;

		CALL bdisac: "informix".sp_grabapagoservicio (pSucursal,'07','002', pNumeroControl,
		SUBSTR(LPAD(pNumeroControl,12,'0'),12,1),'1', mImportePago,'0.00','0.00','0.00','0.00',
		cCuentaPrestadora,cEjecutivo,pFolioSuc, cTransaccSuc,dFechaHoy)
		RETURNING cCodRet;

		IF cCodRet <> '00000' THEN
			CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
			INSERT INTO sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cCodRet,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			RETURN '00000', cCodRet,pFolioSuc;
		END IF;

		UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)} bdisac: "informix".sac_enviosdineroya SET estatus = '04',suc_cobropago = pSucursal, fecha_pago = dFechaHoy,
				hora_pago = CURRENT HOUR TO SECOND, usua_pago = cEjecutivo WHERE no_control = pNumeroControl and estatus is not null;


	ELIF pIdConvenio = '07003' THEN

		SELECT valor INTO cTransaccCargoPago
		FROM Bdisac: "informix".sac_param
		WHERE cod_param='41507003';

		SELECT valor INTO cTransaccSuc
		FROM Bdisac: "informix".sac_param
		WHERE cod_param = '807003';

		--Cargo a la cuenta del cte por el monto cargo.
		CALL bdicheq: "informix".cargo_ref ("001", pSucursal, cEjecutivo, cTransaccCargoPago, cTransaccSuc, pFolioSuc,
		cCuentaPrestadora, 0, mImportePago,"01", pNumeroControl, '', cEjecutivo)
		Returning cCodRet,ctranret,dfechoy,msdodisp,mmontoret;

		IF cCodRet <> 0 THEN
			LET cCodRet = '00001'; --Error en el cargo para el pago del envio
			RETURN '00000', cCodRet,pFolioSuc;
		ELSE
			LET iCargo = 1;
		END IF;

		SELECT fecha_hoy INTO dFechaHoy FROM sac_fechas;

		CALL bdisac: "informix".sp_grabapagoservicio (pSucursal,'07','003', pNumeroControl,
		SUBSTR(LPAD(pNumeroControl,12,'0'),12,1),'1', mImportePago,'0.00','0.00','0.00','0.00',
		cCuentaPrestadora,cEjecutivo,pFolioSuc, cTransaccSuc,dFechaHoy)
		RETURNING cCodRet;

		IF cCodRet <> '00000' THEN
			CALL  bdicheq: "informix".reversion('001',pSucursal,cEjecutivo,pFolioSuc,'A') RETURNING cCodRet2;
			INSERT INTO bdisac: "informix".sac_mensajeerror (sql_error, isam_error, descripcion, origen_error, fecha, fecha_insert)
			VALUES (cCodRet,isam_error,cMensaje,'sp_dinya_pagaenvios',dfechoy,CURRENT );
			RETURN '00000', cCodRet,pFolioSuc;
		END IF;

		UPDATE {+INDEX (bdisac: "informix".sac_enviosdineroya idxsac_envdinya13_1)}  "informix".sac_enviosdineroya SET estatus = '02',suc_cance = pSucursal, fecha_cance = dFechaHoy,
			   hora_cance = CURRENT HOUR TO SECOND, usua_cance = cEjecutivo WHERE no_control = pNumeroControl and estatus is not null;

	END IF;

	RETURN '00000', cCodRet,pFolioSuc;

END
END PROCEDURE
DOCUMENT
'DESCRIPCION: GENERA LA TRANSACCION DE PAGO DE UN ENVIO ACTIVO O CANCELACION Y CAMBIA EL ESTATUS DEL ENVIO A PAGADO O CANCELADO',
'AUTOR: ABIGAIL VASAVILBAZO CAÑEDO',
'FECHA: DICIEMBRE 2009',
'VERSION: 20091203.1153',
'AUTOR : FRG',
'DESCRIPCION: Se agrega validación de cierre procesos centrales por Proy. Indep. Sistemas',
'FECHA : Nov. 2013',
'VERSION: 20131105',
'BD: BDISAC',
'AUTOR : Viridiana PR',
'DESCRIPCION: se envia el valor del numero de control pNumeroControl al procedimiento cargo_ref en la parte del parámetro pReferencia',
'FECHA : MAYO 2015',
'VERSION: 20150528',
'BD    : bdisac',
'MODIFICACION',
'MODIFICO: Trinidad Hernández',
'folio: 73',
'DESCRIPCION: "Homologación de caja appriza con RQM 10-239-5 Y RQM 10-495 y cambio BTS_parametro sucursal"; Homologación con Vers. Prod., Pago de remesas Appriza',
'FECHA : 20/06/2016',
'VERSION: 20160620.1019',
'BD    : bdisac';

CREATE PROCEDURE "informix".sp_consflag_respuesta (pMensaje CHAR(5),pCod_interact CHAR(5),pCod_WS CHAR(4),pCod_detail CHAR(4))
RETURNING CHAR(6) AS Cod_ret, CHAR(1) AS flag

--	DECLARA VARIABLES
DEFINE cCod_ret CHAR(6);
DEFINE iSqlErr INTEGER;
DEFINE cFlag CHAR(1);
DEFINE cFlagint CHAR(1);
DEFINE cFlagrev CHAR(1);
--	INICIALIZA VARIABLES
LET iSqlErr = 0;
LET cCod_ret = '000000';
LET cFlag = '0';
LET cFlagint = '0';
LET cFlagrev = '0';

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_consflag_respuesta.out";
--TRACE ON; 
BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr
		LET cCod_ret = iSqlErr;
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END EXCEPTION;

	-- VALIDACIÓN DE PARÁMETROS
	
	IF NVL(pMensaje,'') = ''THEN
			LET cCod_ret = '000001';
			LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF ( NVL(pCod_interact,'') = ''  OR pCod_interact::INT= 0) AND NVL(pCod_WS,'') = '' OR NVL(pCod_detail,'') = ''  THEN
		LET cCod_ret = '000000';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	ELIF pCod_interact::INT <> 0 then
		LET cCod_ret = '000002';
		LET cFlag = '0';
		RETURN cCod_ret,cFlag;
	
	END IF
	
	LET pMensaje = UPPER(pMensaje);
	
	SELECT flag_rev,flag_intento
	INTO cFlagint,cFlagrev
	FROM bdisac:"informix".sac_app_cat_mensajesdetail
	WHERE agent_trans_type_code = TRIM(pMensaje)
	AND opcode= TRIM (pCod_WS)
	AND opcode_detail = TRIM (pCod_detail);
	
	IF dbinfo("sqlca.sqlerrd2") = 0 THEN
		LET cCod_ret = '000003';
		LET cFlag = '1';
		RETURN cCod_ret,cFlag;
	END IF
	
	IF cFlagint::INT = 1 or cFlagrev::INT = 1 THEN
		LET cFlag = '1';
	END IF
	
	RETURN cCod_ret,cFlag;
	
END
END PROCEDURE
DOCUMENT
'AUTOR:95358919 - MARIO OLIVO',
'FOLIO:95',
'DESCRIPCION: el SP regresa el flag ya sea para mandar a reversar o bien intentar el reverso.',
'FECHA:2016/07/26',
'SOLICITA:Leonardo Hernandez',
'RQM: Adendum',
'VERSION:20160726.1752',
'BD:bdisac';

CREATE PROCEDURE "informix".sp_insertaconciliaciontotalporconvenio()
RETURNING
CHAR(5)         AS retorno;

    DEFINE iSqlErr              INTEGER;
    DEFINE iIsamErr             INTEGER;
    DEFINE cInfoErr             CHAR(100);
	DEFINE cCodRet              CHAR(5);
	DEFINE vconsmovhis          CHAR(10);
	DEFINE cTranCredPGDF   	    CHAR(5);	
	DEFINE cTranCredPEDOF   	    CHAR(5);	
	DEFINE cTranCredPCP   	    CHAR(5);
    DEFINE cNomConvenio         CHAR(40);	
	DEFINE cConvenio         	CHAR(5);
	DEFINE cConv 		        CHAR(3);
    DEFINE cCateg       	    CHAR(2);
	DEFINE cCuenta_contable     CHAR(30);
	DEFINE cCuenta_cheques      CHAR(30);
	DEFINE iProceso_automatico  INTEGER;
	DEFINE iTransCargoCuenta    INTEGER;
	DEFINE cNumTransaccEfec     CHAR(4);
    DEFINE cNumTransaccEfec_cpl CHAR(4);
	DEFINE cNumCargoClien		CHAR(4);
	DEFINE deImporte_archivo    DECIMAL(16,2);
	DEFINE dFecha_pago          DATE;
	DEFINE mCargoCuenta         MONEY(16,2);
	DEFINE deImporte_conta      DECIMAL(16,2);
	DEFINE cIdSucursal			CHAR(4);
	DEFINE iNumPagos            INTEGER;
	DEFINE mImpComisionConvenio    MONEY(16,2);
	DEFINE mIVAComisionConvenio    MONEY(16,2);
	DEFINE mImpComisionCte         MONEY(16,2);
	DEFINE mIVAComisionCte         MONEY(16,2);
	DEFINE iConfirmacionCentral     INTEGER;
	DEFINE iConfirmacionSucursal    INTEGER;
	DEFINE dFechaTransfer			DATE;
	DEFINE vmax_fechaold            DATE;	
	DEFINE cDescripcionSPJ	 CHAR(100);
	DEFINE cConvenTransfer	CHAR (120);
	DEFINE cConvenTransfer2 CHAR (120);
			
	LET cCodRet  =   "00000";	
	LET cTranCredPGDF       = '';
    LET cTranCredPEDOF      = '';
	LET cTranCredPCP		= '';
	LET cNomConvenio  = "";
	LET cConvenio  = "";
	LET cConv   = "";
    LET cCateg  = "";
	LET cCuenta_contable  = "";
	LET cCuenta_cheques   = "";
	LET iProceso_automatico  = 0;
	LET iTransCargoCuenta = 0;
	LET cNumTransaccEfec  = '';
	LET cNumTransaccEfec_cpl  = '';
	LET cNumCargoClien	  = '';
	LET deImporte_archivo = 0;	
	LET dFecha_pago  = "01-01-1990";	
	LET mCargoCuenta      = 0;
	LET deImporte_conta   = 0;
	LET cIdSucursal           = "";
	LET iNumPagos             = 0;
	LET mImpComisionConvenio = 0;
	LET mIVAComisionConvenio = 0;
	LET mImpComisionCte      = 0;
	LET mIVAComisionCte      = 0;
	LET iConfirmacionCentral  = 0;
	LET iConfirmacionSucursal = 0;
	LET dFechaTransfer		= '01-01-1990';
	LET vmax_fechaold    = '';	
	LET cDescripcionSPJ	 = 'Inserta totales para reporte de SOC conciliacion total por convenio';	
	LET cConvenTransfer = '';
	LET cConvenTransfer2 = '';

	--SET DEBUG FILE TO  '/informix/yuri/convenios/sp_insertaconciliaciontotalporconvenioyu.out';
	--TRACE ON;
		
    BEGIN
        ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_insertaconciliaciontotalporconvenio");
                RETURN cCodRet;
            END IF;
        END EXCEPTION;	

		SELECT fecha_hoy-1
		INTO dFecha_pago
		FROM bdisac:"informix".sac_fechas
		WHERE empresa = "001";			
		
		SELECT valor INTO vconsmovhis FROM bdicheq:"informix".sc_param WHERE codparam = 'fechcon_movhis' AND  empresa = '001';
		SELECT valor INTO cTranCredPGDF FROM bdisac:"informix".sac_param WHERE cod_param = '87040';
		SELECT valor INTO cTranCredPEDOF FROM bdisac:"informix".sac_param WHERE cod_param = '25';
		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'IND_CTC_S', dFecha_pago, '0', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);

		--HOMOLOGACION CLUB DE PROTECCION COPPEL
		SELECT valor INTO cTranCredPCP FROM bdisac:"informix".sac_param WHERE cod_param = 82;
        FOREACH			
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(cuenta_prestadora,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''),NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              INTO cNomConvenio, cConvenio, cConv, cCateg, cCuenta_contable, cCuenta_cheques, 
				   iProceso_automatico, iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl, cNumCargoClien 
              FROM bdisac:"informix".sac_convenios
             WHERE numcategoria || numconvenio <> '08002'
             UNION 
            SELECT nomconvenio, numcategoria || numconvenio, numconvenio, numcategoria, NVL(cuenta_contable,''),
                   NVL(valor,''), NVL(proceso_automatico,0), NVL(trans_cen_abono_convenio,''), 
                   NVL(trans_cen_efectivo_cliente,''), NVL(trans_cen_efectivo_cliente_cpl,''), NVL(trans_cen_cargo_cliente,'')
              FROM bdisac:"informix".sac_convenios, bdisac:sac_param
             WHERE numcategoria || numconvenio = '08002'
               AND cod_param IN ('30','31','32','33','34')
             ORDER BY nomconvenio	
				
								
				IF cCateg = '10' THEN				
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago-1
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
					
						SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
						FROM bdicheq:"informix".sc_movhis
						WHERE fech_alt = dFecha_pago-1
						AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec)
						AND cuenta = cCuenta_cheques
						AND usuario = 'systrans';
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago-1 and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago-1, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						END IF;	
					END FOREACH;
				ELSE			
					FOREACH
						--Se calcula el total de los movimientos por sucursal
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg 
						AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND flag_confirmacion_central = 1
						AND flag_confirmacion_sucursal = 1
						GROUP BY id_sucursal
						ORDER BY id_sucursal	

						IF cCateg = '08' AND cConv = '002' THEN
							LET deImporte_archivo = 0;
							LET deImporte_archivo = ( SELECT  SUM(importe_pago)
													  FROM bdisac:"informix".sac_movimientoshistorial a, bdisac:sac_edomex_cuentas b
													 WHERE a.fecha_pago = dFecha_pago
													   AND a.numcategoria = cCateg 
													   AND a.numconvenio = cConv			
													   AND a.status_cancelado = 'N'
													   AND a.flag_confirmacion_central = 1 
													   AND a.flag_confirmacion_sucursal = 1
													   AND substr(referencia1,1,6) = prefijo
													   AND cuenta = cCuenta_cheques
													   group by cuenta);                                       
												 
					   END IF;
						--Se calcula el Total de Cheques por sucursal
						--Pago de Remesas
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) 
									INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer									
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec, cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;								
								END IF;
							END IF;			
						END IF;			

					INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
					VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, deImporte_archivo, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte, iConfirmacionCentral, iConfirmacionSucursal);									
						
					END FOREACH;			
					--Sumar al total de cheques los que en movimientos tienen algun flag en 0
					FOREACH
						SELECT SUM(importe_pago), id_sucursal, COUNT(referencia1), SUM(importe_comision_convenio), SUM(iva_comision_convenio),
							SUM(importe_comision_cte), SUM(iva_comision_cte), SUM(flag_confirmacion_central), SUM(flag_confirmacion_sucursal)
						INTO deImporte_archivo, cIdSucursal, iNumPagos, mImpComisionConvenio, mIVAComisionConvenio, mImpComisionCte, mIVAComisionCte,
							iConfirmacionCentral, iConfirmacionSucursal
						FROM bdisac:"informix".sac_movimientoshistorial
						WHERE fecha_pago = dFecha_pago
						AND numcategoria = cCateg AND numconvenio = cConv			
						AND status_cancelado = 'N'
						AND (flag_confirmacion_central = 0
						OR flag_confirmacion_sucursal = 0)
						GROUP BY id_sucursal
						ORDER BY id_sucursal	
						IF(cConvenio = "07004" OR cConvenio = "07006" OR cConvenio = "07007" OR cConvenio = "07008")THEN
							SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
							FROM bdicheq:"informix".sc_movhis
							WHERE fech_alt = dFecha_pago
							AND cancelad <> 'S' AND transacc IN(cNumCargoClien, cNumTransaccEfec)
							AND cuenta = cCuenta_cheques
							AND sucursal = cIdSucursal;					
						ELSE --Club de Proteccion
							IF cConvenio = "01002" THEN
								SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
								FROM bdicheq:"informix".sc_movhis
								WHERE fech_alt = dFecha_pago
								AND cancelad <> 'S' AND transacc IN (cTranCredPCP, iTransCargoCuenta, cNumTransaccEfec)
								AND cuenta = cCuenta_cheques
								AND sucursal = cIdSucursal;					
							ELSE --GDF
								IF cConvenio = "08001" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' AND transacc IN(cTranCredPGDF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;	
								 ELIF cConvenio = "08002" THEN
									SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
									FROM bdicheq:"informix".sc_movhis
									WHERE fech_alt = dFecha_pago
									AND cancelad <> 'S' 
									AND transacc IN(cTranCredPEDOF, iTransCargoCuenta, cNumTransaccEfec)
									AND cuenta = cCuenta_cheques
									AND sucursal = cIdSucursal;								
								ELSE --Todos los demas convenios que no sean Orden de Pago y Transfer
									IF cConvenio NOT IN ("07001" ,"07002", "07003") AND cCateg <> '10' THEN
										SELECT NVL(SUM(monto_tot), 0) INTO mCargoCuenta
										FROM bdicheq:"informix".sc_movhis
										WHERE fech_alt = dFecha_pago
										AND cancelad <> 'S' AND transacc IN(iTransCargoCuenta, cNumTransaccEfec,cNumTransaccEfec_cpl)
										AND cuenta = cCuenta_cheques
										AND sucursal = cIdSucursal;
									ELSE --Es un Envio, Cobro o Cancelacion de Orden de Pago
										LET mCargoCuenta = 0;
									END IF;
								END IF;
							END IF;			
						END IF;
						
						IF NOT EXISTS (SELECT * FROM bdisac:"informix".sac_conciliaciontotalporconvenio where numcategoria=cCateg and numconvenio=cConv and fecha_pago=dFecha_pago and id_sucursal=cIdSucursal) THEN
							INSERT INTO bdisac:"informix".sac_conciliaciontotalporconvenio (retorno, numcategoria, numconvenio, nomconvenio, fecha_pago, importe_archivo, cuenta_cheques, importe_cheq, cuenta_contable, importe_conta, id_sucursal, numpagos, importe_comision_convenio, iva_comision_convenio, importe_comision_cte, iva_comision_cte, flag_confirmacion_central, flag_confirmacion_sucursal)
							VALUES (cCodRet, cCateg, cConv, cNomConvenio, dFecha_pago, 0, cCuenta_cheques, mCargoCuenta, cCuenta_contable, deImporte_conta, cIdSucursal, iNumPagos, 0, 0, 0, 0, iConfirmacionCentral, iConfirmacionSucursal);												
						END IF;					
					END FOREACH;
				END IF;
		END FOREACH;		
		--INSERTA EN BITACORA
		EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'IND_CTC_S', dFecha_pago, '1', 'informix', 'sp_insertaconciliaciontotalporconvenio', cDescripcionSPJ);
		RETURN cCodRet;
	END;		
END PROCEDURE;