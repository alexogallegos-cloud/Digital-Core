CREATE PROCEDURE "informix".sp_rem_consultasacappqryi2(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumRem CHAR(12), pRCode CHAR(4)) 
    RETURNING CHAR(5) AS codRet,		
		CHAR(20) AS cCustomerNumber_b,
		CHAR(40) AS cFirstName_b,
		CHAR(40) AS cMiddleName_b,
		CHAR(40) AS cLastName_b,
		CHAR(40) AS cMotherMaidenName_b,
		CHAR(40) AS cFirstName_f,
		CHAR(40) AS cMiddleName_f,
		CHAR(40) AS cLastName_f,
		CHAR(40) AS cMotherMaidenName_f,
		CHAR(80) AS cAddress_b,
		CHAR(40) AS cCity_b,
		CHAR(3) AS  cCountryCode_b,
		CHAR(3) AS  cStateCode_b,
		CHAR(10) AS cZipCode_b,
		CHAR(100) AS cEmail,
		CHAR(15) AS cHomePhoneNumber,
		CHAR(15) AS cWorkPhoneNumber,
		CHAR(15) AS cNumber_cl,
		CHAR(3) AS  cReceiveEmail,
		CHAR(3) AS  cReceiveSMS,
		CHAR(3) AS  cTypeCode_ib,
		CHAR(20) AS cNumber_ib,
		CHAR(8) AS  cExpirationDate_ib,
		CHAR(3) AS  cIssuerCountryCode_ib,
		CHAR(3) AS  cIssuerStateCode_ib,
		CHAR(3) AS  cReasonTypeCode,
		CHAR(40) AS cReasonForTransfer,
		CHAR(40) AS cSourceOfFunds,
		CHAR(40) AS cSecurityPhrase,
		CHAR(255) AS cFreeMessage,
		CHAR(8) AS  cUsuarioInsert,
		CHAR(25) AS cFechaInser,
		CHAR(255) AS cDescription_osc,
		CHAR(16) AS cFolio_suc,
		CHAR(4) AS cId_sucursal,
		CHAR(40) AS cDesc_sucursal,
		CHAR(3) AS cR_typecode_i,
		CHAR(20) AS cR_number,
		CHAR(80) AS cR_address_b,
		CHAR(10) AS cR_zipcode_b,
		CHAR(40) AS cR_city_b,
		CHAR(3) AS cR_statecode_b,
		CHAR(3) AS cR_countrycode_b,
		CHAR(15) AS cR_homephonenum,
		CHAR(1) AS cForma_pago,
		CHAR(8) AS cDate_Birth,
		CHAR(3) AS cIss_Uercc,
		CHAR(5) AS cContry_Code;		
	
	DEFINE cCodRet 					CHAR(5);
	DEFINE iSqlErr 					INT;
	DEFINE cCodRetSp 				CHAR(6);
	DEFINE iCodRetSp 				INTEGER;
	DEFINE cDescCodRet 				CHAR(80);
	DEFINE cEmpresa 				CHAR(3);
	
	DEFINE cTxn_status				CHAR(1);
	DEFINE cUnirefnum				CHAR(16);
	DEFINE cCode_Company			CHAR(3);
	DEFINE cChanneldid				CHAR(3);
	DEFINE cLocationunit			CHAR(15);
	DEFINE cNnumber					CHAR(15);
	DEFINE cTypecode_Branch			CHAR(3);	
	DEFINE cCountrycode_Branch		CHAR(3);
	DEFINE cStatecode_Branch		CHAR(3);
	DEFINE cTerminalid				CHAR(15);
	DEFINE cProcessdate_Qry			CHAR(8);
	DEFINE cProcesstime_Qry			CHAR(6);
	DEFINE cCode_Operacion			CHAR(5);
	DEFINE cCode					CHAR(4);
	DEFINE cMensCode				CHAR(255);
	DEFINE cCode_d					CHAR(4);
	DEFINE cMensajeD				CHAR(255);
	DEFINE cProcessDate				CHAR(8);
	DEFINE cProcessTime				CHAR(6);
	DEFINE cRule					CHAR(3);
	DEFINE cValue					CHAR(3);
	DEFINE cGlobalTrackingNumber	CHAR(20);
	DEFINE cOrderStatusCode			CHAR(3);
	DEFINE cOrderStatusDate			CHAR(8);
	DEFINE cOrderStatusTime			CHAR(6);
	DEFINE cUniqueReferenceNumber	CHAR(16);
	DEFINE cCodesalecom				CHAR(3);
	DEFINE cCountryCode				CHAR(3);
	DEFINE cStateCodeSale			CHAR(3);
	DEFINE cSaleDate				CHAR(8);
	DEFINE cSaleTime				CHAR(6);
	DEFINE cCountryCode_o			CHAR(3);
	DEFINE cCurrencyCode			CHAR(3);
	DEFINE cServiceCode				CHAR(3);
	DEFINE cCountryCode_d			CHAR(3);
	DEFINE cCurrencyCode_d			CHAR(3);
	DEFINE cDeliveryMethodCode		CHAR(3);
	DEFINE cPayNetworkCode			CHAR(3);
	DEFINE cPaySubNetworkCode		CHAR(15);
	DEFINE cBranchNumber			CHAR(15);
	DEFINE cAccountTypeCode			CHAR(3);
	DEFINE cAccountNumber			CHAR(30);
	DEFINE cOriginAmount			CHAR(20);
	DEFINE cDestinationAmount		CHAR(20);
	DEFINE cRetailExchangeRate		CHAR(21);
	DEFINE cWholesaleExchangeRate	CHAR(21);
	DEFINE cDestinExchangeRate 		CHAR(21);
	DEFINE cServiceFeeAmount		CHAR(20);
	DEFINE cDiscountAmount			CHAR(20);
	DEFINE cTypeCode				CHAR(3);
	DEFINE cAccountNumber_c			CHAR(30);
	DEFINE cBicCode					CHAR(11);
	DEFINE cReferenceNumber			CHAR(30);
	DEFINE cCustomerNumber			CHAR(20);
	DEFINE cFirstName				CHAR(40);
	DEFINE cMiddleName				CHAR(40);
	DEFINE cLastName				CHAR(40);
	DEFINE cMotherMaidenName		CHAR(40);
	DEFINE cAddress					CHAR(80);
	DEFINE cCity					CHAR(40);
	DEFINE cCountryCode_a			CHAR(3);
	DEFINE cStateCode				CHAR(3);
	DEFINE cZipCode					CHAR(10);
	DEFINE cTypeCode_i				CHAR(3);
	DEFINE cNumber					CHAR(20);
	DEFINE cExpirationDate			CHAR(8);
	DEFINE cIssuerCountryCode		CHAR(3);
	DEFINE cIssuerStateCode			CHAR(3);
	DEFINE cDateOfBirth				CHAR(8);
	DEFINE cCustomerNumber_b		CHAR(20);
	DEFINE cFirstName_b				CHAR(40);
	DEFINE cMiddleName_b			CHAR(40);
	DEFINE cLastName_b				CHAR(40);
	DEFINE cMotherMaidenName_b		CHAR(40);
	DEFINE cFirstName_f				CHAR(40);
	DEFINE cMiddleName_f			CHAR(40);
	DEFINE cLastName_f				CHAR(40);
	DEFINE cMotherMaidenName_f		CHAR(40);
	DEFINE cAddress_b				CHAR(80);
	DEFINE cCity_b					CHAR(40);
	DEFINE cCountryCode_b			CHAR(3);
	DEFINE cStateCode_b				CHAR(3);
	DEFINE cZipCode_b				CHAR(10);
	DEFINE cEmail					CHAR(100);
	DEFINE cHomePhoneNumber			CHAR(15);
	DEFINE cWorkPhoneNumber			CHAR(15);
	DEFINE cNumber_cl				CHAR(15);
	DEFINE cReceiveEmail			CHAR(3);
	DEFINE cReceiveSMS				CHAR(3);
	DEFINE cTypeCode_ib				CHAR(3);
	DEFINE cNumber_ib				CHAR(20);
	DEFINE cExpirationDate_ib		CHAR(8);
	DEFINE cIssuerCountryCode_ib	CHAR(3);
	DEFINE cIssuerStateCode_ib		CHAR(3);
	DEFINE cReasonTypeCode			CHAR(3);
	DEFINE cReasonForTransfer		CHAR(40);
	DEFINE cSourceOfFunds			CHAR(40);
	DEFINE cSecurityPhrase			CHAR(40);
	DEFINE cFreeMessage				CHAR(255);
	DEFINE cUsuarioInsert			CHAR(8);
	DEFINE cFechaInser				DATETIME YEAR TO FRACTION(5);
	DEFINE cDescription_osc			CHAR(255);
	DEFINE cFolio_suc				CHAR(16);
	DEFINE cId_sucursal				CHAR(4);
	DEFINE cDesc_sucursal 			CHAR(40);
	DEFINE cR_typecode_i 			CHAR(3);
	DEFINE cR_number 				CHAR(20);
	DEFINE cR_address_b 			CHAR(80);
	DEFINE cR_zipcode_b 			CHAR(10);
	DEFINE cR_city_b 				CHAR(40);
	DEFINE cR_statecode_b 			CHAR(3);
	DEFINE cR_countrycode_b 		CHAR(3);
	DEFINE cR_homephonenum 			CHAR(15);
	DEFINE cForma_pago 			    CHAR(1);	
	DEFINE  cDateBirth				CHAR(8);
	DEFINE 	cIssuercc           	CHAR(3);
	DEFINE 	cContryCode         	CHAR(5);
	
	
	LET cCodRet 					= '00000';
	LET iSqlErr 					= 0;
	LET cCodRetSp 					= '';
	LET iCodRetSp 					= 0;
	LET cDescCodRet 				= '';
	LET cEmpresa 					= '001';
	
	LET cTxn_status					= '';
	LET cUnirefnum					= '';
	LET cCode_Company				= '';
	LET cChanneldid					= '';
	LET cLocationunit				= '';
	LET cNnumber					= '';
	LET cTypecode_Branch			= '';
	LET cCountrycode_Branch			= '';
	LET cStatecode_Branch			= '';
	LET cTerminalid					= '';
	LET cProcessdate_Qry			= '';
	LET cProcesstime_Qry			= '';
	LET cCode_Operacion				= '';
	LET cCode						= '';
	LET cMensCode					= '';
	LET cCode_d						= '';
	LET cMensajeD					= '';
	LET cProcessDate				= '';
	LET cProcessTime				= '';
	LET cRule						= '';
	LET cValue						= '';
	LET cGlobalTrackingNumber		= '';
	LET cOrderStatusCode			= '';
	LET cOrderStatusDate			= '';
	LET cOrderStatusTime			= '';
	LET cUniqueReferenceNumber		= '';
	LET cCodesalecom				= '';
	LET cCountryCode				= '';
	LET cStateCodeSale				= '';
	LET cSaleDate					= '';
	LET cSaleTime					= '';
	LET cCountryCode_o				= '';
	LET cCurrencyCode				= '';
	LET cServiceCode				= '';
	LET cCountryCode_d				= '';
	LET cCurrencyCode_d				= '';
	LET cDeliveryMethodCode			= '';
	LET cPayNetworkCode				= '';
	LET cPaySubNetworkCode			= '';
	LET cBranchNumber				= '';
	LET cAccountTypeCode			= '';
	LET cAccountNumber				= '';
	LET cOriginAmount				= '';
	LET cDestinationAmount			= '';
	LET cRetailExchangeRate			= '';
	LET cWholesaleExchangeRate		= '';
	LET cDestinExchangeRate 		= '';
	LET cServiceFeeAmount			= '';
	LET cDiscountAmount				= '';
	LET cTypeCode					= '';
	LET cAccountNumber_c			= '';
	LET cBicCode					= '';
	LET cReferenceNumber			= '';
	LET cCustomerNumber				= '';
	LET cFirstName					= '';
	LET cMiddleName					= '';
	LET cLastName					= '';
	LET cMotherMaidenName			= '';
	LET cAddress					= '';
	LET cCity						= '';
	LET cCountryCode_a				= '';
	LET cStateCode					= '';
	LET cZipCode					= '';
	LET cTypeCode_i					= '';
	LET cNumber						= '';
	LET cExpirationDate				= '';
	LET cIssuerCountryCode			= '';
	LET cIssuerStateCode			= '';
	LET cDateOfBirth				= '';
	LET cCustomerNumber_b			= '';
	LET cFirstName_b				= '';
	LET cMiddleName_b				= '';
	LET cLastName_b					= '';
	LET cMotherMaidenName_b			= '';
	LET cFirstName_f				= '';
	LET cMiddleName_f				= '';
	LET cLastName_f					= '';
	LET cMotherMaidenName_f			= '';
	LET cAddress_b					= '';
	LET cCity_b						= '';
	LET cCountryCode_b				= '';
	LET cStateCode_b				= '';
	LET cZipCode_b					= '';
	LET cEmail						= '';
	LET cHomePhoneNumber			= '';
	LET cWorkPhoneNumber			= '';
	LET cNumber_cl					= '';
	LET cReceiveEmail				= '';
	LET cReceiveSMS					= '';
	LET cTypeCode_ib				= '';
	LET cNumber_ib					= '';
	LET cExpirationDate_ib			= '';
	LET cIssuerCountryCode_ib		= '';
	LET cIssuerStateCode_ib			= '';
	LET cReasonTypeCode				= '';
	LET cReasonForTransfer			= '';
	LET cSourceOfFunds				= '';
	LET cSecurityPhrase				= '';
	LET cFreeMessage				= '';
	LET cUsuarioInsert				= '';
	LET cFechaInser					= '';
	LET cDescription_osc			= '';
	LET cFolio_suc					= '';
	LET cId_sucursal				= '';
	LET cDesc_sucursal 				= '';
	LET cR_typecode_i               = '';
	LET cR_number                   = '';
	LET cR_address_b                = '';
	LET cR_zipcode_b                = '';
	LET cR_city_b                   = '';
	LET cR_statecode_b              = '';
	LET cR_countrycode_b            = '';
	LET cR_homephonenum             = '';
	LET cForma_pago 	            = '';	
	LET cDateBirth					= '';
	LET cIssuercc           		= '';
	LET cContryCode         		= '';

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet,cCustomerNumber_b,
				cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
				cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
				cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
				NVL(cDescription_osc,''),NVL(cFolio_suc,''),NVL(cId_sucursal,''),NVL(cDesc_sucursal,''),
				NVL(cR_typecode_i,''),NVL(cR_number,''),NVL(cR_address_b,''),NVL(cR_zipcode_b,''),NVL(cR_city_b,''),NVL(cR_statecode_b,''),NVL(cR_countrycode_b,''),NVL(cR_homephonenum,''),NVL(cForma_pago,''),
				NVL(cDateBirth,''),NVL(cIssuercc,''), NVL(cContryCode,'');				
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_consultasacappqryi2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumRem = '' OR pRCode = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCustomerNumber_b,
			cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
			cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
			cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
			NVL(cDescription_osc,''),NVL(cFolio_suc,''),NVL(cId_sucursal,''),NVL(cDesc_sucursal,''),
			NVL(cR_typecode_i,''),NVL(cR_number,''),NVL(cR_address_b,''),NVL(cR_zipcode_b,''),NVL(cR_city_b,''),NVL(cR_statecode_b,''),NVL(cR_countrycode_b,''),NVL(cR_homephonenum,''),NVL(cForma_pago,''),
			NVL(cDateBirth,''),NVL(cIssuercc,''), NVL(cContryCode,'');
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCustomerNumber_b,
			cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
			cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
			cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
			NVL(cDescription_osc,''),NVL(cFolio_suc,''),NVL(cId_sucursal,''),NVL(cDesc_sucursal,''),
			NVL(cR_typecode_i,''),NVL(cR_number,''),NVL(cR_address_b,''),NVL(cR_zipcode_b,''),NVL(cR_city_b,''),NVL(cR_statecode_b,''),NVL(cR_countrycode_b,''),NVL(cR_homephonenum,''),NVL(cForma_pago,''),
			NVL(cDateBirth,''),NVL(cIssuercc,''), NVL(cContryCode,'');
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		SET LOCK MODE TO WAIT 3;
		
		SELECT txn_status,unirefnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,
		processdate,processtime,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,
		r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,
		r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,
		r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,
		r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,
		r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,
		r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,
		r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,
		r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha
		INTO cTxn_status,cUnirefnum,cCode_Company,cChanneldid,cLocationunit,cNnumber,cTypecode_Branch,cCountrycode_Branch,cStatecode_Branch,cTerminalid,
		cProcessdate_Qry,cProcesstime_Qry,cCode_Operacion,cCode,cMensCode,cCode_d,cMensajeD,cProcessDate,cProcessTime,cRule,
		cValue,cGlobalTrackingNumber,cOrderStatusCode,cOrderStatusDate,cOrderStatusTime,cUniqueReferenceNumber,cCodesalecom,cCountryCode,cStateCodeSale,cSaleDate,
		cSaleTime,cCountryCode_o,cCurrencyCode,cServiceCode,cCountryCode_d,cCurrencyCode_d,cDeliveryMethodCode,cPayNetworkCode,cPaySubNetworkCode,cBranchNumber,
		cAccountTypeCode,cAccountNumber,cOriginAmount,cDestinationAmount,cRetailExchangeRate,cWholesaleExchangeRate,cDestinExchangeRate,cServiceFeeAmount,cDiscountAmount,cTypeCode,
		cAccountNumber_c,cBicCode,cReferenceNumber,cCustomerNumber,cFirstName,cMiddleName,cLastName,cMotherMaidenName,cAddress,cCity,
		cCountryCode_a,cStateCode,cZipCode,cTypeCode_i,cNumber,cExpirationDate,cIssuerCountryCode,cIssuerStateCode,cDateOfBirth,cCustomerNumber_b,
		cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
		cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
		cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser
		FROM bdisac:"informix".sac_app_qryi
		WHERE unirefnum = pNumRem
		AND r_code = pRCode
		AND fecha IN (SELECT MAX(fecha) FROM bdisac:"informix".sac_app_qryi WHERE unirefnum = pNumRem AND r_code = pRCode);
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';
		ELSE
		
			SELECT description
			INTO cDescription_osc
			FROM bdisac:"informix".sac_app_estatusrem 
			WHERE status = cOrderStatusCode;
			
			IF DATE(cFechaInser) = (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
				
				SELECT folio_suc, id_sucursal, forma_pago
				INTO cFolio_suc, cId_sucursal, cForma_pago
				FROM bdisac:"informix".sac_movimientos
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND status_cancelado = 'N'
				AND	flag_confirmacion_sucursal = '1'
				AND	flag_confirmacion_central = '1'
				AND	fecha_insert IN (SELECT MAX(fecha_insert) 
									 FROM bdisac:"informix".sac_movimientos 
									 WHERE numcategoria = '07'
									 AND numconvenio = '009'
									 AND referencia1 = pNumRem
									 AND status_cancelado = 'N'
									 AND	flag_confirmacion_sucursal = '1'
									 AND	flag_confirmacion_central = '1'); 
				
			ELIF DATE(cFechaInser) < (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
				
				SELECT folio_suc, id_sucursal, forma_pago
				INTO cFolio_suc, cId_sucursal, cForma_pago
				FROM bdisac:"informix".sac_movimientoshistorial
				WHERE numcategoria = '07'
				AND numconvenio = '009'
				AND referencia1 = pNumRem
				AND status_cancelado = 'N'
				AND	flag_confirmacion_sucursal = '1'
				AND	flag_confirmacion_central = '1'
				AND	ROWID IN (SELECT MAX(ROWID) 
										   FROM bdisac:"informix".sac_movimientoshistorial 
										   WHERE numcategoria = '07'
										   AND numconvenio = '009'
										   AND referencia1 = pNumRem
										   AND status_cancelado = 'N'
										   AND	flag_confirmacion_sucursal = '1'
										   AND	flag_confirmacion_central = '1'); 
				
				IF NVL(cFolio_suc,'') = '' THEN
					
					SELECT folio_suc, id_sucursal, forma_pago
					INTO cFolio_suc, cId_sucursal, cForma_pago
					--FROM bdisac:"c92357113".sac_movimientoshistorial_old
					FROM bdisac:sac_movimientoshistorial_old
					WHERE numcategoria = '07'
					AND numconvenio = '009'
					AND referencia1 = pNumRem
					AND status_cancelado = 'N'
					AND	flag_confirmacion_sucursal = '1'
					AND	flag_confirmacion_central = '1'
					AND	fecha_insert IN (SELECT MAX(fecha_insert) 
											   --FROM bdisac:"c92357113".sac_movimientoshistorial_old 
											   FROM bdisac:sac_movimientoshistorial_old 
											   WHERE numcategoria = '07'
											   AND numconvenio = '009'
											   AND referencia1 = pNumRem
											   AND status_cancelado = 'N'
											   AND	flag_confirmacion_sucursal = '1'
											   AND	flag_confirmacion_central = '1');
					
				END IF;
				
			ELIF DATE(cFechaInser) > (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
				LET cCodRet = '00975'; --LA FECHA DE PAGO ES INVÃLIDA
			END IF;
			
			IF NVL(cId_sucursal,'') <> '' THEN
				SELECT nombre 
				INTO cDesc_sucursal
				FROM bdinteg:"informix".si_sucursales 
				WHERE sucursal = cId_sucursal;
			END IF;
			
			IF NVL(cFolio_suc,'') <> '' AND SUBSTR(cFolio_suc,1,7) <> 'sys_apz' THEN
			
				SELECT r_typecode_i,r_number,r_address_b,r_zipcode_b,r_city_b,r_statecode_b,r_countrycode_b,r_homephonenum,dateofbirth,issuercc,contrycode
				INTO cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cDateBirth	,cIssuercc, cContryCode 								
				FROM bdisac:"informix".sac_app_payi
				WHERE unirefnum = pNumRem
				AND r_code = '0000'
				AND fecha IN (SELECT MAX(fecha)
							  FROM bdisac:"informix".sac_app_payi
							  WHERE unirefnum = pNumRem
							  AND r_code = '0000'
							  AND DATE(fecha) IN (SELECT DATE(fecha)
							  					  FROM bdisac:"informix".sac_app_qryi
							  					  WHERE unirefnum = pNumRem
							  					  AND r_code = '0000'));
								   
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					SELECT r_typecode_i,r_number,r_address_b,r_zipcode_b,r_city_b,r_statecode_b,r_countrycode_b,r_homephonenum,dateofbirth,issuercc,contrycode
					INTO cR_typecode_i,cR_number,cR_address_b,cR_zipcode_b,cR_city_b,cR_statecode_b,cR_countrycode_b,cR_homephonenum,cDateBirth	,cIssuercc, cContryCode
					--FROM bdisac:"informix".sac_app_payi_old
					FROM bdisac:sac_app_payi_old
					WHERE unirefnum = pNumRem
					AND r_code = '00000'
					AND fecha IN (SELECT MAX(fecha) 
								 --FROM bdisac:"informix".sac_app_payi_old
								 FROM bdisac:sac_app_payi_old
								 WHERE unirefnum = pNumRem
								 AND r_code = '00000'); 
				END IF;
				
			END IF;
		
		END IF;
		
		RETURN cCodRet,cCustomerNumber_b,
		cFirstName_b,cMiddleName_b,cLastName_b,cMotherMaidenName_b,cFirstName_f,cMiddleName_f,cLastName_f,cMotherMaidenName_f,cAddress_b,cCity_b,
		cCountryCode_b,cStateCode_b,cZipCode_b,cEmail,cHomePhoneNumber,cWorkPhoneNumber,cNumber_cl,cReceiveEmail,cReceiveSMS,cTypeCode_ib,
		cNumber_ib,cExpirationDate_ib,cIssuerCountryCode_ib,cIssuerStateCode_ib,cReasonTypeCode,cReasonForTransfer,cSourceOfFunds,cSecurityPhrase,cFreeMessage,cUsuarioInsert,cFechaInser,
		NVL(cDescription_osc,''),NVL(cFolio_suc,''),NVL(cId_sucursal,''),NVL(cDesc_sucursal,''),
		NVL(cR_typecode_i,''),NVL(cR_number,''),NVL(cR_address_b,''),NVL(cR_zipcode_b,''),NVL(cR_city_b,''),NVL(cR_statecode_b,''),NVL(cR_countrycode_b,''),NVL(cR_homephonenum,''),NVL(cForma_pago,''),
		NVL(cDateBirth,''),NVL(cIssuercc,''), NVL(cContryCode,'');
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA 05/05/2017',
'MODULO: REMESAS',
'FUNCIONALIDAD: CAMBIO DE ESTATUS REMESAS BTS',
'DESCRIPCION: SPL encargado de consultar el detalle del pago de remesas Appriza Pay.',
'BD: bdicnweb',
'AUTOR: URIEL CAAMAÃO MEJIA',
'FECHA: 27/10/2017',
'DESCRIPCION: SE AGREGARON LOS SIGUIENTES CAMPOS DATEOFBIRTH,ISSUERCC,CONTRYCODE PARA EL RETORNO DE DATOS DE LAS TABLA',
'BDISAC:SAC_APP_PAYI Y BDISAC:SAC_APP_PAYI_OLD',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_rem_validaremesaapp(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaPago CHAR(10), pFolioSuc CHAR(16),pNoConfirmacion CHAR(12),pSucursal CHAR(4))
		RETURNING CHAR(5) AS codret,
		CHAR(16) AS  folio_suc,
		CHAR(80) AS  adress,
		CHAR(40) AS  city,
		CHAR(3)  AS  countrycodeadr,
		CHAR(3)  AS  statecodeadr,
		CHAR(10) AS  zipcode,
		CHAR(100) AS email,
		CHAR(15)  AS homephonenum,
		CHAR(15)  AS numbercel,
		CHAR(3)   AS receiveemail,
		CHAR(3)   AS receivesms;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	DEFINE cFolioSuc		CHAR(16);
	DEFINE cAdress			CHAR(80);
	DEFINE cCity            CHAR(40);
	DEFINE cCountrycodeadr  CHAR(3);
	DEFINE cStatecodeadr    CHAR(3);
	DEFINE cZipcode         CHAR(10);
	DEFINE cEmail           CHAR(100);
	DEFINE cHomephonenum    CHAR(15);
	DEFINE cNumbercel       CHAR(15);
	DEFINE cReceiveemail    CHAR(3);
	DEFINE cReceivesms      CHAR(3);
	
	LET cCodRet      = '00000';
	LET iSqlErr      = 0;
	LET iNoRegistros = 0;
	
	LET cFolioSuc		='';
	LET	cAdress			='';	
    LET cCity           ='';
    LET cCountrycodeadr ='';
    LET cStatecodeadr   ='';
    LET cZipcode        ='';
    LET cEmail          ='';
    LET cHomephonenum   ='';
    LET cNumbercel      ='';
    LET cReceiveemail   ='';
    LET cReceivesms     ='';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_rem_validaremesaapp.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaPago ='' OR  pFolioSuc='' OR pNoConfirmacion='' OR pSucursal='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
		END IF;
		 
		 
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
		END IF;
		
		SET ISOLATION TO DIRTY READ;            
        SET LOCK MODE TO WAIT 3;
		
		--FECHA PAGO = HOY
		IF DATE(pFechaPago) = (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
			
			SELECT FIRST 1 folio_suc INTO cFolioSuc FROM bdisac:sac_movimientos 
			WHERE fecha_pago =pFechaPago
			AND  numcategoria = '07'
			AND numconvenio = '009'
			AND referencia1 = pNoConfirmacion
			AND folio_suc =pFolioSuc;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		--FECHAS PAGO < HOY 
		ELIF DATE(pFechaPago) < (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
		
			SELECT FIRST 1 folio_suc INTO cFolioSuc FROM bdisac:sac_movimientoshistorial  
			WHERE	fecha_pago =pFechaPago 
			AND numcategoria = '07'
			AND numconvenio = '009'
			AND referencia1 = pNoConfirmacion
			AND folio_suc =pFolioSuc;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
		
		--FECHA PAGO INVALIDA		
		ELIF DATE(pFechaPago) > (SELECT fecha_hoy FROM bdisac:"informix".sac_fechas) THEN
               LET cCodRet = '00975'; 
			   RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
        END IF;
		
		--NO EXISTE FOLIO PAGO
		IF iNoRegistros = 0  THEN
		       LET cCodRet = '00963'; --FOLIO DE SUCURSAL NO ENCONTRADO, FAVOR DE VALIDAR
			   RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
        END IF;
		
		IF ((SELECT COUNT(unirefnum)  FROM bdisac:sac_app_payi WHERE unirefnum = pNoConfirmacion)>0) THEN

			SELECT  adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms 
			INTO cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms
			FROM bdisac:sac_app_payi 
			WHERE unirefnum = pNoConfirmacion
			AND fecha=(SELECT MAX(fecha) FROM  bdisac:sac_app_payi 
			WHERE unirefnum = pNoConfirmacion);

			
		ELSE
		
			SELECT suc.direccion1, cd.nombre, edo.cod_pais, edo.state_cd , suc.d_codigo ,'' AS email,telefono1,'' AS numbercel,'NOT' AS receiveemail,'NOT' AS receivesms
			INTO cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms
			FROM bdinteg:si_sucursales suc 
			LEFT JOIN bdinteg:si_ciudades cd ON suc.pais=cd.pais AND suc.ciudad=cd.ciudad AND suc.estado=cd.estado
			LEFT JOIN bdisac:sac_app_catestados  edo ON suc.estado=edo.cve_estado
			WHERE sucursal=pSucursal;

		END IF;
		
		
		RETURN cCodRet,cFolioSuc,cAdress,cCity,cCountrycodeadr,cStatecodeadr, cZipcode, cEmail, cHomephonenum, cNumbercel, cReceiveemail, cReceivesms;
		
END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 18/05/2017',
'MODULO: REMESAS ',
'FUNCIONALIDAD: Cambio de Estatus Remesa Appriza',
'DESCRIPCION: Valida datos del pago',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_remesasconsultapagowu(pUsuario CHAR(8),pIdFuncion CHAR(10),pMtcn  CHAR(10),pFecha CHAR(10))
RETURNING CHAR(5) AS codret,
	CHAR(1) AS txn_status,
	CHAR(3) AS channel_type,
	CHAR(3) AS channel_name,
	CHAR(4) AS channel_version,
	CHAR(1) AS benef_nametype,
	CHAR(40) AS benef_nombre1,
	CHAR(40) AS benef_nombre2,
	CHAR(40) AS benef_appaterno,
	CHAR(40) AS benef_apmaterno,
	CHAR(24) AS benef_ciudad,
	CHAR(40) AS benef_edo,
	CHAR(9) AS benef_cp,
	CHAR(10) AS template_id,
	CHAR(1) AS benef_id_type,
	CHAR(45) AS benef_id_pais_expedicion,
	CHAR(20) AS benef_id_number,
	CHAR(1) AS id_benef_tiene_fecha_venc,
	CHAR(8) AS benef_id_fecha_vencimiento,
	CHAR(8) AS benef_fecha_nac,
	CHAR(30) AS benef_ocupacion,
	CHAR(40) AS benef_calle_num,
	CHAR(40) AS benef_col_del_mncpo,
	CHAR(45) AS benef_pais,
	CHAR(20) AS benef_tel_particular,
	CHAR(20) AS benef_tel_celular,
	CHAR(40) AS benef_email,
	CHAR(2) AS benef_pais_nac,
	CHAR(15) AS benef_nacionalidad,
	CHAR(1) AS benef_sexo,
	CHAR(20) AS benef_ciudad_nac,
	CHAR(20) AS benef_edo_nac,
	CHAR(3) AS benef_cod_pais,
	CHAR(3) AS benef_cod_moneda,
	CHAR(10) AS monto_origen,
	CHAR(10) AS monto_destino,
	CHAR(10) AS money_transfer_key,
	CHAR(16) AS new_mtcn,
	CHAR(10) AS mtcn,
	CHAR(1) AS conf_pago,
	CHAR(11) AS foreign_rs_system_id_rq,
	CHAR(16) AS foreign_rs_refnum_rq,
	CHAR(11) AS foreign_rs_cntid_rq,
	CHAR(25) AS fecha_hora_rq,
	CHAR(5) AS retcode,
	CHAR(500) AS datos_buffer,
	CHAR(10) AS mtcn_rp,
	CHAR(4) AS puntos_ganados,
	CHAR(16) AS wu_fecha_pago,
	CHAR(11) AS foreign_rs_system_id_rp,
	CHAR(16) AS foreign_rs_refnum_rp,
	CHAR(11) AS foreign_rs_cntid_rp,
	CHAR(250) AS desc_error,
	CHAR(10) AS partnerid_err,
	CHAR(25) AS fecha_hora_rp,
	CHAR(8) AS user_insert,
	CHAR(25) AS fecha_insert,
	CHAR(1) AS benef_second_id_type,
	CHAR(44) AS benef_second_pais_exped,
	CHAR(30) AS benef_second_id_number,
	CHAR(20)  AS numcte;

DEFINE cCodRet 				        CHAR(5);
DEFINE iSqlErr 				        INTEGER;
DEFINE cCodRetSp 			        CHAR(5);
DEFINE iCodRetSp 			        INTEGER;
DEFINE iNoRegistros			        INTEGER;
DEFINE cTxnStatus                  	CHAR(1);
DEFINE cChannelType                	CHAR(3);
DEFINE cChannelName                	CHAR(3);
DEFINE cChannelVersion             	CHAR(4);
DEFINE cBenefNametype              	CHAR(1);
DEFINE cBenefNombre1               	CHAR(40);
DEFINE cBenefNombre2               	CHAR(40);
DEFINE cBenefAppaterno             	CHAR(40);
DEFINE cBenefApmaterno             	CHAR(40);
DEFINE cBenefCiudad                	CHAR(24);
DEFINE cBenefEdo                   	CHAR(40);
DEFINE cBenefCp                    	CHAR(9);
DEFINE cTemplateId                 	CHAR(10);
DEFINE cBenefIdType               	CHAR(1);
DEFINE cBenefIdPaisExpedicion    	CHAR(45);
DEFINE cBenefIdNumber             	CHAR(20);
DEFINE cIdBenefTieneFechaVenc   	CHAR(1);
DEFINE cBenefIdFechaVencimiento  	CHAR(8);
DEFINE cBenefFechaNac             	CHAR(8);
DEFINE cBenefOcupacion             	CHAR(30);
DEFINE cBenefCalleNum             	CHAR(40);
DEFINE cBenefColDelMncpo         	CHAR(40);
DEFINE cBenefPais                  	CHAR(45);
DEFINE cBenefTelParticular        	CHAR(20);
DEFINE cBenefTelCelular           	CHAR(20);
DEFINE cBenefEmail                 	CHAR(40);
DEFINE cBenefPaisNac              	CHAR(2);
DEFINE cBenefNacionalidad          	CHAR(15);
DEFINE cBenefSexo                  	CHAR(1);
DEFINE cBenefCiudadNac            	CHAR(20);
DEFINE cBenefEdoNac               	CHAR(20);
DEFINE cBenefCodPais                CHAR(3);
DEFINE cBenefCodMoneda            	CHAR(3);
DEFINE cMontoOrigen                	CHAR(10);
DEFINE cMontoDestino               	CHAR(10);
DEFINE cMoneyTransferKey          	CHAR(10);
DEFINE cNewMtcn                    	CHAR(16);
DEFINE cMtcn                        CHAR(10);
DEFINE cConfPago                   	CHAR(1);
DEFINE cForeignRsSystemIdRq     	CHAR(11);
DEFINE cForeignRsRefnumRq        	CHAR(16);
DEFINE cForeignRsCntidRq         	CHAR(11);
DEFINE cFechaHoraRq               	DATETIME YEAR to SECOND;
DEFINE cRetcode                     CHAR(5);
DEFINE cDatosBuffer                	CHAR(500);
DEFINE cMtcnRp                     	CHAR(10);
DEFINE cPuntosGanados              	CHAR(4);
DEFINE cWuFechaPago               	CHAR(16);
DEFINE cForeignRsSystemIdRp     	CHAR(11);
DEFINE cForeignRsRefnumRp           CHAR(16);
DEFINE cForeignRsCntidRp            CHAR(11);
DEFINE cDescError                   CHAR(250);
DEFINE cPartneridErr                CHAR(10);
DEFINE cFechaHoraRp                 DATETIME YEAR to SECOND;
DEFINE cUserInsert                  CHAR(8);
DEFINE cFechaInsert                 DATETIME YEAR to SECOND;
DEFINE cBenefSecondIdType           CHAR(1);
DEFINE cBenefSecondPaisExpedicion   CHAR(44);
DEFINE cBenefSecondIdNumber         CHAR(30);
DEFINE cNumcte                      CHAR(20);

LET cCodRet 						='00000';
LET iSqlErr 	            		=0;
LET cCodRetSp 			    		='';
LET iCodRetSp 			    		=0;
LET iNoRegistros            		=0;
LET cTxnStatus              		='';  
LET cChannelType            		='';  
LET cChannelName            		='';  
LET cChannelVersion         		='';  
LET cBenefNametype          		='';  
LET cBenefNombre1           		='';  
LET cBenefNombre2           		='';  
LET cBenefAppaterno         		='';  
LET cBenefApmaterno         		='';  
LET cBenefCiudad            		='';  
LET cBenefEdo               		='';  
LET cBenefCp                		='';  
LET cTemplateId             		='';  
LET cBenefIdType            		='';  
LET cBenefIdPaisExpedicion  		='';  
LET cBenefIdNumber          		='';  
LET cIdBenefTieneFechaVenc  		=''; 
LET cBenefIdFechaVencimiento		='';  
LET cBenefFechaNac          		='';  
LET cBenefOcupacion         		='';  
LET cBenefCalleNum          		='';  
LET cBenefColDelMncpo       		='';  
LET cBenefPais              		='';  
LET cBenefTelParticular     		='';  
LET cBenefTelCelular        		='';  
LET cBenefEmail             		='';  
LET cBenefPaisNac           		='';  
LET cBenefNacionalidad      		='';  
LET cBenefSexo              		='';  
LET cBenefCiudadNac         		='';  
LET cBenefEdoNac            		='';  
LET cBenefCodPais           		='';  
LET cBenefCodMoneda         		='';  
LET cMontoOrigen            		='';  
LET cMontoDestino           		='';  
LET cMoneyTransferKey       		='';  
LET cNewMtcn                		='';  
LET cMtcn                   		='';  
LET cConfPago               		='';  
LET cForeignRsSystemIdRq    		=''; 
LET cForeignRsRefnumRq      		='';  
LET cForeignRsCntidRq       		='';  
LET cFechaHoraRq            		=NULL;  
LET cRetcode                		='';  
LET cDatosBuffer            		='';  
LET cMtcnRp                 		='';  
LET cPuntosGanados          		='';  
LET cWuFechaPago            		='';  
LET cForeignRsSystemIdRp    		=''; 
LET cForeignRsRefnumRp      		='';  
LET cForeignRsCntidRp       		='';  
LET cDescError              		='';  
LET cPartneridErr           		='';  
LET cFechaHoraRp            		=NULL;  
LET cUserInsert             		='';  
LET cFechaInsert            		=NULL;  
LET cBenefSecondIdType      		='';  
LET cBenefSecondPaisExpedicion		='';
LET cBenefSecondIdNumber      		='';
LET cNumcte                   		='';

BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,
			cBenefCp,cTemplateId,cBenefIdType,cBenefIdPaisExpedicion,cBenefIdNumber,cIdBenefTieneFechaVenc,cBenefIdFechaVencimiento,cBenefFechaNac,cBenefOcupacion,cBenefCalleNum,
			cBenefColDelMncpo,cBenefPais,cBenefTelParticular,cBenefTelCelular,cBenefEmail,cBenefPaisNac,cBenefNacionalidad,cBenefSexo,cBenefCiudadNac,cBenefEdoNac,cBenefCodPais,cBenefCodMoneda,
			cMontoOrigen,cMontoDestino,cMoneyTransferKey,cNewMtcn,cMtcn,cConfPago,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cFechaHoraRq,cRetcode,cDatosBuffer,cMtcnRp,cPuntosGanados,
			cWuFechaPago,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cBenefSecondIdType,cBenefSecondPaisExpedicion,
			cBenefSecondIdNumber,cNumcte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_remesasconsultapagowu.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pMtcn='' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,
			cBenefCp,cTemplateId,cBenefIdType,cBenefIdPaisExpedicion,cBenefIdNumber,cIdBenefTieneFechaVenc,cBenefIdFechaVencimiento,cBenefFechaNac,cBenefOcupacion,cBenefCalleNum,
			cBenefColDelMncpo,cBenefPais,cBenefTelParticular,cBenefTelCelular,cBenefEmail,cBenefPaisNac,cBenefNacionalidad,cBenefSexo,cBenefCiudadNac,cBenefEdoNac,cBenefCodPais,cBenefCodMoneda,
			cMontoOrigen,cMontoDestino,cMoneyTransferKey,cNewMtcn,cMtcn,cConfPago,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cFechaHoraRq,cRetcode,cDatosBuffer,cMtcnRp,cPuntosGanados,
			cWuFechaPago,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cBenefSecondIdType,cBenefSecondPaisExpedicion,
			cBenefSecondIdNumber,cNumcte;
		END IF;
		
    	SET ISOLATION TO DIRTY READ;            
        SET LOCK MODE TO WAIT 3;
		
		IF EXISTS (SELECT mtcn FROM bdisac:sac_wu_pay WHERE retcode='00000' AND conf_pago = 'P' AND mtcn=pMtcn AND DATE(fecha_insert)=pFecha) THEN
		
			SELECT txn_status,channel_type,channel_name,channel_version,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_ciudad,benef_edo,benef_cp,template_id,benef_id_type,benef_id_pais_expedicion,
			benef_id_number,id_benef_tiene_fecha_venc,benef_id_fecha_vencimiento,benef_fecha_nac,benef_ocupacion,benef_calle_num,benef_col_del_mncpo,benef_pais,benef_tel_particular,benef_tel_celular,benef_email,benef_pais_nac,
			benef_nacionalidad,benef_sexo,benef_ciudad_nac,benef_edo_nac,benef_cod_pais,benef_cod_moneda,monto_origen,monto_destino,money_transfer_key,new_mtcn,mtcn,conf_pago,foreign_rs_system_id_rq,foreign_rs_refnum_rq,
			foreign_rs_cntid_rq,fecha_hora_rq,retcode,datos_buffer,mtcn_rp,puntos_ganados,wu_fecha_pago,foreign_rs_system_id_rp,foreign_rs_refnum_rp,foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,
			fecha_insert,benef_second_id_type,benef_second_pais_expedicion,benef_second_id_number,numcte
			INTO
			cTxnStatus,cChannelType,cChannelName,cChannelVersion,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,
			cBenefCp,cTemplateId,cBenefIdType,cBenefIdPaisExpedicion,cBenefIdNumber,cIdBenefTieneFechaVenc,cBenefIdFechaVencimiento,cBenefFechaNac,cBenefOcupacion,cBenefCalleNum,
			cBenefColDelMncpo,cBenefPais,cBenefTelParticular,cBenefTelCelular,cBenefEmail,cBenefPaisNac,cBenefNacionalidad,cBenefSexo,cBenefCiudadNac,cBenefEdoNac,cBenefCodPais,cBenefCodMoneda,
			cMontoOrigen,cMontoDestino,cMoneyTransferKey,cNewMtcn,cMtcn,cConfPago,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cFechaHoraRq,cRetcode,cDatosBuffer,cMtcnRp,cPuntosGanados,
			cWuFechaPago,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cBenefSecondIdType,cBenefSecondPaisExpedicion,
			cBenefSecondIdNumber,cNumcte
			FROM bdisac:sac_wu_pay
			WHERE retcode='00000'
			AND conf_pago = 'P' 
			AND mtcn=pMtcn
			AND DATE(fecha_insert)=pFecha;
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
        
			
		ELSE
		
			SELECT txn_status,channel_type,channel_name,channel_version,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,benef_ciudad,benef_edo,benef_cp,template_id,benef_id_type,benef_id_pais_expedicion,
			benef_id_number,id_benef_tiene_fecha_venc,benef_id_fecha_vencimiento,benef_fecha_nac,benef_ocupacion,benef_calle_num,benef_col_del_mncpo,benef_pais,benef_tel_particular,benef_tel_celular,benef_email,benef_pais_nac,
			benef_nacionalidad,benef_sexo,benef_ciudad_nac,benef_edo_nac,benef_cod_pais,benef_cod_moneda,monto_origen,monto_destino,money_transfer_key,new_mtcn,mtcn,conf_pago,foreign_rs_system_id_rq,foreign_rs_refnum_rq,
			foreign_rs_cntid_rq,fecha_hora_rq,retcode,datos_buffer,mtcn_rp,puntos_ganados,wu_fecha_pago,foreign_rs_system_id_rp,foreign_rs_refnum_rp,foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,
			fecha_insert,benef_second_id_type,benef_second_pais_expedicion,benef_second_id_number,''
			INTO
			cTxnStatus,cChannelType,cChannelName,cChannelVersion,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,
			cBenefCp,cTemplateId,cBenefIdType,cBenefIdPaisExpedicion,cBenefIdNumber,cIdBenefTieneFechaVenc,cBenefIdFechaVencimiento,cBenefFechaNac,cBenefOcupacion,cBenefCalleNum,
			cBenefColDelMncpo,cBenefPais,cBenefTelParticular,cBenefTelCelular,cBenefEmail,cBenefPaisNac,cBenefNacionalidad,cBenefSexo,cBenefCiudadNac,cBenefEdoNac,cBenefCodPais,cBenefCodMoneda,
			cMontoOrigen,cMontoDestino,cMoneyTransferKey,cNewMtcn,cMtcn,cConfPago,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cFechaHoraRq,cRetcode,cDatosBuffer,cMtcnRp,cPuntosGanados,
			cWuFechaPago,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cBenefSecondIdType,cBenefSecondPaisExpedicion,
			cBenefSecondIdNumber,cNumcte
			FROM bdisac:sac_wu_pay_old
			WHERE retcode='00000'
			AND conf_pago = 'P' 
			AND mtcn=pMtcn
			AND fecha_insert =(SELECT MAX(fecha_insert) FROM bdisac:sac_wu_pay_old
						WHERE retcode='00000'
						AND conf_pago = 'P' 
						AND mtcn=pMtcn);
			
			LET iNoRegistros = DBINFO('sqlca.sqlerrd2');
        	
		END IF;
		                
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
		END IF;
		
		RETURN cCodRet,cTxnStatus,cChannelType,cChannelName,cChannelVersion,cBenefNametype,cBenefNombre1,cBenefNombre2,cBenefAppaterno,cBenefApmaterno,cBenefCiudad,cBenefEdo,
			cBenefCp,cTemplateId,cBenefIdType,cBenefIdPaisExpedicion,cBenefIdNumber,cIdBenefTieneFechaVenc,cBenefIdFechaVencimiento,cBenefFechaNac,cBenefOcupacion,cBenefCalleNum,
			cBenefColDelMncpo,cBenefPais,cBenefTelParticular,cBenefTelCelular,cBenefEmail,cBenefPaisNac,cBenefNacionalidad,cBenefSexo,cBenefCiudadNac,cBenefEdoNac,cBenefCodPais,cBenefCodMoneda,
			cMontoOrigen,cMontoDestino,cMoneyTransferKey,cNewMtcn,cMtcn,cConfPago,cForeignRsSystemIdRq,cForeignRsRefnumRq,cForeignRsCntidRq,cFechaHoraRq,cRetcode,cDatosBuffer,cMtcnRp,cPuntosGanados,
			cWuFechaPago,cForeignRsSystemIdRp,cForeignRsRefnumRp,cForeignRsCntidRp,cDescError,cPartneridErr,cFechaHoraRp,cUserInsert,cFechaInsert,cBenefSecondIdType,cBenefSecondPaisExpedicion,
			cBenefSecondIdNumber,cNumcte;
			
END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 08/05/2017',
'MODULO: REMESAS ',
'FUNCIONALIDAD: Consulta Remesas WU',
'DESCRIPCION:SPL que consulta los datos del pago remesa WU',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genarchmovimientos_masivo(pUsuario CHAR(8), pIdFuncion CHAR(10),pRutaDescarga CHAR(100), pSistemaCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE,
                                                               pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2),pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60),pClaveMov CHAR(50))
    RETURNING   CHAR(5) AS codret,
                CHAR(45) AS reporte_generado;

        DEFINE cCodRet          CHAR(5);
        DEFINE iSqlErr          INTEGER;
        DEFINE cCodRetSp        CHAR(5);
        DEFINE iCodRetSp        INTEGER;
        DEFINE cNombreArchivo   CHAR(45);
        DEFINE iNumRegistros    INTEGER;
        DEFINE cEjecucion       CHAR(1);

        LET cCodRet             = '00000';
        LET iSqlErr             = 0;
        LET cCodRetSp           = '';
        LET iCodRetSp           = 0;
        LET cNombreArchivo      = '';
        LET iNumRegistros       = 0;
        LET cEjecucion          = '2';

          BEGIN

                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cNombreArchivo;
                END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_genarchmovimientos_masivo.out';
                --TRACE ON;

                IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pSistemaCuenta = '' OR
                pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' OR pClaveMov='' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cNombreArchivo;
                END IF;

                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
				IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cNombreArchivo;
                END IF;

                -- SP QUE LLENA TABLA TEMPORAL
                EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_consdetallemovimientos_totales(pUsuario , pIdFuncion , pSistemaCuenta ,
                pFechaInicial,pFechaFinal,pNumCuenta,pEjecutivo,pSucursal,pImporte, cEjecucion,pClaveMov) INTO cCodRetSp, iNumRegistros;
                LET iCodRetSp = cCodRetSp::INTEGER;
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cnsif_consdetallemovimientos_totales';
                ELIF iCodRetSp > 0 THEN
                        LET cCodRet = cCodRetSp;
                        RETURN cCodRet, cNombreArchivo;
                END IF;     

                --SP QUE GENERA ARCHIVO CON DATOS DE LA TABLA TEMPORAL ANTERIOR
                EXECUTE PROCEDURE bdicnweb:"informix".sp_cnsif_genarchmovimientos2(pUsuario,pIdFuncion,pRutaDescarga,pSistemaCuenta,
				pFechaInicial,pFechaFinal,pNumCuenta,pEjecutivo,pSucursal ,pImporte,pIdPlantilla,pTituloPlantilla,pClaveMov) INTO cCodRetSp, cNombreArchivo;
                LET iCodRetSp = cCodRetSp::INTEGER;
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicnweb:sp_cnsif_genarchmovimientos';
                ELIF iCodRetSp > 0 THEN
                        LET cCodRet = cCodRetSp;
                        RETURN cCodRet, cNombreArchivo;
                END IF;

                RETURN cCodRet, cNombreArchivo;

        END;
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA 08/01/2018',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIï¿½N/CRï¿½DITO/INVERSIONES',
'DESCRIPCION: SPL encargado generar los reportes en formato txt para alta volumen de informaciï¿½n',
'BD: bdicnweb',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA 27/07/2023',
'DESCRIPCION MODIFICACION: SPL encargado generar los reportes en formato txt para alta volumen de informaciï¿½n tomando en cuenta las cuentas NOSTRO',
'AUTOR: Uriel Amador Islas',
'FECHA 30/10/2024',
'DESCRIPCION MODIFICACION: Se quita la ejecuciÃ³n del SPL sp_cnsif_agrupar_movimientos, dado que este proceso se va a realizar desde el SPL sp_cnsif_consultamovtosdiarioscta3_2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_genarchmovimientos2(pUsuario CHAR(8), pIdFuncion CHAR(10), pRutaDescarga CHAR(100), pSistemaCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pNumCuenta CHAR(20), 
														 pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2),pIdPlantilla CHAR(10), pTituloPlantilla CHAR(60), pClaveMov CHAR(50))
    RETURNING 	CHAR(5) 	AS codret,
				CHAR(45) 	AS reporte_generado;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);	
	DEFINE cCmd1 CHAR(2000);
	DEFINE cSql CHAR(2500);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE cNombreArchivoHist CHAR(45);
	DEFINE cFechaHoraArchivo CHAR(15);
	DEFINE dFechaHoy DATE;
	DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dHoy DATETIME YEAR TO FRACTION(3);
	DEFINE cStr7 CHAR(60);
	DEFINE cStr8 CHAR(60);
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET cNombreArchivoHist = '';
	LET cFechaHoraArchivo = '';
	LET dFechaHoy = '';
	LET dHoraHoy = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dHoy = '';
	LET cStr7 = ''; 
	LET cStr8 = ''; 
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet, cNombreArchivo;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			LET bInTransaction = 't';
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_genarchmovimientos2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = '' OR pSistemaCuenta = '' OR 
		pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR pIdPlantilla = '' OR pTituloPlantilla = '' OR pClaveMov = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreArchivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreArchivo;
		END IF;	
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		
		LET dFechaInicial=LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
	    LET dFechaFinal  =LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;
		LET cFechaHoraArchivo = LPAD(DAY(dFechaHoy),2,0)||LPAD(MONTH(dFechaHoy),2,0)||YEAR(dFechaHoy)||'_'||LPAD(CAST(SUBSTR(dHoraHoy,1,2) AS CHAR(2)),2,0)||LPAD(CAST(SUBSTR(dHoraHoy,4,2) AS CHAR(2)),2,0);
		
		IF pSistemaCuenta = 'CAPTACION' THEN
			
			LET cStr8 = 'CAPTACION';
			LET cNombreArchivo = 'MOVIMIENTOS_CAPTACION_'||TRIM(cFechaHoraArchivo)||'.txt';
			
		ELIF pSistemaCuenta = 'CREDITO' THEN
			
			LET cStr8 = 'CREDITO';
			LET cNombreArchivo = 'MOVIMIENTOS_CREDITO_'||TRIM(cFechaHoraArchivo)||'.txt';
				
		ELIF pSistemaCuenta = 'INVERSIONES' THEN
			
			LET cStr8 = 'INVERSION';
			LET cNombreArchivo = 'MOVIMIENTOS_INVERSIONES_'||TRIM(cFechaHoraArchivo)||'.txt';
			
		END IF;
		
		-- CONSULTA PARA GENERAR EL ARCHIVO CON LOS MOVIMIENTOS
		LET cCmd1 ="";
		LET cCmd1 ="SELECT 'FECHA','HORA','TRANSACCION','DESCRIPCION DE TRANSACCION','MONTO','NATURALEZA','SALDO',";
		LET cCmd1 =""||TRIM(cCmd1)||"'REFERENCIA','REVERSOS','SUCURSAL','FOLIO','PROCEDENCIA','USUARIO','REFERENCIA A 23 POSICIONES','ORDENANTE', 'REFERENCIA CLIENTE','CONCEPTO' FROM systables WHERE tabid = 1 UNION ALL";
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT * FROM (SELECT NVL(TO_CHAR(fecha, '%d/%m/%Y'), ''),NVL(TO_CHAR(hora,'%H:%M:%S'), ''),cve_transaccion,desc_transaccion ,TRIM(NVL(TO_CHAR(monto), '')),naturaleza,TRIM(NVL(TO_CHAR(saldo), '')),UPPER(referencia),reversos,sucursal,folio,cve_procedencia,usuario_mov,referencia23,ordenante, TO_CHAR(refe), concepto ";
		LET cCmd1 =""||TRIM(cCmd1)||" FROM bdicnweb:""informix"".sw_cons_movimientos2";
		LET cCmd1 =""||TRIM(cCmd1)||" WHERE ";
		LET cCmd1 =""||TRIM(cCmd1)||" usuario = '"||TRIM(pUsuario)||"'";
		LET cCmd1 =""||TRIM(cCmd1)||" AND clave_mov = '"||TRIM(pClaveMov)||"'";
		LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_inicial = '"||dFechaInicial||"'";
		LET cCmd1 =""||TRIM(cCmd1)||" AND periodo_final = '"||dFechaFinal||"'";
		LET cCmd1 =""||TRIM(cCmd1)||" ORDER BY id_registro ASC)";

		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			LET cSql = '';
			--LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			LET cSql = '/usr/bin/echo "UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER ''|'' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			--Desarrollo
			--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			-- Produccion
			LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);


			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||'query.sql';
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de lï¿½nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el archivo original
			LET cSql = '';
			LET cSql = "rm -rf "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			-- Eliminamos el caracter delimitador ';' al final de la lï¿½nea
			LET cSql = '';
			LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- Se manipula el archivo para agregar el salto de lï¿½nea
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
								
			LET cSql = '';
			LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
							
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			LET cSql = '';
			LET cSql = 'chmod 777 '||TRIM(cRutaGral);
			SYSTEM TRIM(cSql);
			
			-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			FOREACH
			
				SELECT nombre_archivo
				INTO cNombreArchivoHist
				FROM bdicnweb:"informix".sw_cons_archivosgenerados
				WHERE usuario = pUsuario AND sis_cuenta = pSistemaCuenta 
				AND fecha < dFechaHoy
				
				LET cSql = '';
				LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreArchivoHist);
				SYSTEM TRIM(cSql);
				
				DELETE {+AVOID_FULL("informix".sw_cons_archivosgenerados)} FROM bdicnweb:"informix".sw_cons_archivosgenerados -- Se crea Ã­ndice para eliminar busqueda secuencial
				WHERE nombre_archivo = TRIM(cNombreArchivoHist);
			
			END FOREACH;
			
		COMMIT WORK;
		
		LET ven_transacc = 0;
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- SE ACTUALIZA TABLA HISTï¿½RICA
		INSERT INTO bdicnweb:"informix".sw_cons_archivosgenerados(usuario,nombre_archivo,sis_cuenta,fecha,hora) 
		VALUES(pUsuario,TRIM(cNombreArchivo),pSistemaCuenta,dFechaHoy,dHoraHoy);
		
		
		-- NOTIFICACIï¿½N Vï¿½A CORREO ELECTRï¿½NICO
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1','WEB_ARMOV','WEB_ARMOV',pUsuario,'','','1','','','','','','NOTIFICACION GENERACION ARCHIVO TXT',
        'GENERACION DEL ARCHIVO TXT','',pSistemaCuenta,'','','',1,0,0,0,0,current,current) INTO cCodRetSp;

		/*
		LET cStr7 = 'GENERACIï¿½N DEL ARCHIVO TXT';
		LET dHoy = CURRENT;
		
		EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento(
		'1', 
		TRIM(pIdPlantilla),
		TRIM(pIdPlantilla), 
		pUsuario, 
		'',
		'', 
		'1', 
		'',
		'',
		'',
		'',
		'',
		'',
		TRIM(cStr7),
		TRIM(cStr8),
		'',
		TRIM(pTituloPlantilla),
		'',
		'',
		'0',
		'0',
		'0',
		'0',
		'0',
		dHoy,
		dHoy) INTO cCodRetSp;*/
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdimnsj:sp_registra_evento';
		ELIF iCodRetSp > 0 THEN
			LET cCodRet = '01018'; --OCURRIO UN ERROR EN LA EJECUCIï¿½N DEL SP bdimnsj:"informix".sp_registra_evento, VERIFIQUE
		END IF;
		
		RETURN cCodRet, cNombreArchivo;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA 14/09/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIï¿½N/CRï¿½DITO/INVERSIONES',
'DESCRIPCION: SPL encargado generar los reportes en formato txt.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 04/10/2017',
'DESCRIPCION: Se agrega diagonal al final de la ruta de descarga del archivo.',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 24/10/2017',
'DESCRIPCION: Se agrega la notificaciï¿½n vï¿½a correo electrï¿½nico al momento de terminar la generaciï¿½n del reporte.',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION: Se agregan variables cFechaInicial y cFechaFinal, para tratar la fecha en formato MM/DD/YYYY',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION: Se cambian variables cFechaInicial y cFechaFinal a Date',
'MODIFICACION: L. Montserrat Leï¿½n Amador',
'FECHA MODIFICACION: 08/01/2018',
'DESCRIPCION MODIFICACION: Se implementa nuevo filtro de consulta pClaveMov.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina filtro usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Lic. Uriel Caamaï¿½o Mejia',
'FECHA MODIFICACION: 23/02/2018',
'DESCRIPCION MODIFICACION: Se realiza ordenamiento de informacion en generacion de los archivos txt.',
'BD: bdicnweb',
'AUTOR: JosÃ© Antonio RamÃ­rez',
'FECHA MODIFICACION: 27/07/2023',
'DESCRIPCION MODIFICACION: Se cambio el reporte para que imprima los campos para los movimientos de spei de las cuentras NOSTRO.',
'AUTOR: Uriel Amador Islas',
'FECHA MODIFICACION: 30/10/2024',
'DESCRIPCION MODIFICACION: Se simplifica la consulta a la tabla sw_cons_movimientos2, y se cambia el filtro sistema_cuenta por clave_mov.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_depurar_genarchmovtos_masivo()
	RETURNING CHAR(5) AS CodRet;

	DEFINE iSqlErr 	    						INTEGER;
	DEFINE cCodRet 	    						CHAR(5);
	DEFINE ven_transacc							SMALLINT;

	LET cCodRet 							= '00000';
	LET ven_transacc						= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;

			IF ven_transacc = 1 THEN
				ROLLBACK WORK;		
			END IF;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-668, -535, -255)
			COMMIT WORK;
			BEGIN WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/ifxsif01/uai/sp_depurar_genarchmovtos_masivo.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- Se depuran registros temporales de la tabla sw_cons_statusproceso
		TRUNCATE bdicnweb:"informix".sw_cons_statusproceso;
		
		-- Se depuran registros temporales de la tabla sw_cons_movimientos
		TRUNCATE bdicnweb:"informix".sw_cons_movimientos;
				
		-- Se depuran registros temporales de la tabla sw_cons_movimientos2
		TRUNCATE bdicnweb:"informix".sw_cons_movimientos2;
				
		-- Se depuran registros temporales de la tabla si_tempomovs_2
		EXECUTE PROCEDURE bdinteg:"informix".sp_depurar_tempomovs()
		INTO cCodRet;
		
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT
'SP para depurar las tablas "sw_cons_statusproceso" y "sw_cons_movimientos", que son llenadas durante el proceso del SP sp_cnsif_genarchmovimientos_masivo, ejecutado por el JOB 1109',
'AUTOR : Uriel Amador Islas',
'Area: Sitemas',
'Gerencia de Mtto y Soporte IV',
'Coordinador: Victor Sanchez',
'Fecha: 31/07/2023',
'Cambio: se agrega la depuraciÃ³n de las tablas sw_cons_movimientos, sw_cons_movimientos y ',
'Modifico: Uriel Amador Islas',
'Fecha: 30/10/2024',
'Version: 1.0.1',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_administradorespm_complementoinfo(pNumCteEmp CHAR(20))
RETURNING CHAR(5) AS cCodRet,
	CHAR(100) AS Mensaje,
	CHAR(3) AS pAdminTipo,
	CHAR(30) AS pIdAdmin,
	CHAR(30) AS pApellidoPater,
	CHAR(30) AS pApellidoMater,
	CHAR(30) AS pNombre1,
	CHAR(30) AS pNombre2,
	SMALLINT AS pTotal_Tokens,
	SMALLINT AS pTotal_admin,
	CHAR(12) AS pFolio_activa;

--****************************************************************************************************
-- Objetivo:Spl que obtiene informaciÃ³n complementaria de los administradores. Obtiene hasta 2 administradores 
-- por empresa segun corresponda.
-- Autor: Nadia Ordaz
-- FECHA : 10/10/2024
-- SOLICITO : Isaac Flores
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
    DEFINE iSql_Err                     INTEGER;
    DEFINE cCodRet                      CHAR(6);
    DEFINE cMensaje                     CHAR(50);
    DEFINE iContAdmin                   INTEGER;
    
    DEFINE pAdminTipo                   CHAR(3);
    DEFINE pIdAdmin                     CHAR(30);
    DEFINE pApellidoPater               CHAR(30);
    DEFINE pApellidoMater               CHAR(30);
    DEFINE pNombre1                     CHAR(30);
    DEFINE pNombre2                     CHAR(30);
    DEFINE pTotal_admin                 SMALLINT;
    DEFINE pTotal_oper                  SMALLINT;
    DEFINE pTotal_Tokens                SMALLINT;
    DEFINE pFolio_activa                CHAR(12);
    
--INICIALIZACIONES              
    LET iSql_Err            = 0;
    LET cCodRet             = '00000';
    LET cMensaje            = 'SE EJECUTO CORRECTAMENTE';
    LET iContAdmin          = 0;
    LET pAdminTipo          = '';
    LET pIdAdmin            = '';
    LET pApellidoPater      = '';
    LET pApellidoMater      = '';
    LET pNombre1            = '';
    LET pNombre2            = '';
    LET pTotal_admin        = 0;
    LET pTotal_oper         = 0;
    LET pTotal_Tokens       = 0;
    LET pFolio_activa       = '';
    
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
        RETURN cCodRet, cMensaje, pAdminTipo, pIdAdmin, pApellidoPater, pApellidoMater, pNombre1, pNombre2, pTotal_Tokens, pTotal_admin, pFolio_activa; 
    END EXCEPTION;
    
    --SET DEBUG FILE TO "/tmp/mfinis/sp_administradorespm_complementoinfo.out";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
    
    IF TRIM(NVL(pNumCteEmp,'')) = '' THEN
        LET cCodRet = '00001';
        LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
        RETURN cCodRet, cMensaje, pAdminTipo, pIdAdmin, pApellidoPater, pApellidoMater, pNombre1, pNombre2, pTotal_Tokens, pTotal_admin, pFolio_activa;
    END IF;
	
	SELECT COUNT(num_cliente) 
	INTO pTotal_admin
	FROM bdibei:bei_servicio 
	WHERE num_cliente = pNumCteEmp;
	
	SELECT oper_no_token
	INTO pTotal_oper
	FROM bdibei:bei_contratacion
	WHERE empresa = '001'
		AND num_cliente = pNumCteEmp;
    
	LET pTotal_Tokens = pTotal_admin + pTotal_oper;
	
	FOREACH cur for 
		SELECT TRIM(nombre1), TRIM(nombre2), TRIM(apell_paterno), TRIM(apell_materno), TRIM(codidentif),  TRIM(identificacion_admin), TRIM(folio_activa)
		INTO pNombre1, pNombre2, pApellidoPater, pApellidoMater, pAdminTipo, pIdAdmin, pFolio_activa 
		FROM bdibei:bei_servicio 
		WHERE num_cliente = pNumCteEmp
		
        RETURN cCodRet, cMensaje, pAdminTipo, pIdAdmin, pApellidoPater, pApellidoMater, pNombre1, pNombre2, pTotal_Tokens, pTotal_admin, pFolio_activa WITH RESUME;
    END FOREACH;
END;

END PROCEDURE

DOCUMENT
'DESCRIPCION: Se agrega campo folio_activa a la consulta de informaciÃ³n',
'MODIFICO: Isaac Flores Ruiz',
'FECHA: 09/10/2024';

CREATE PROCEDURE "informix".sp_portadactamec2_complementoinfo(pNumCtaEmp CHAR(20))

RETURNING CHAR(5) AS cCodRet,
		  CHAR(100) AS Mensaje,
		  CHAR(2) AS pproced_aperturacta,
		  CHAR(2) AS pproced_mantenercta,
		  CHAR(2) AS pmonto_mensual,
		  CHAR(2) AS pdepositos_cantidad,
		  CHAR(2) AS pdepositos_monto,
		  CHAR(2) AS pretiros_cantidad,
		  CHAR(2) AS pretiros_monto,
		  DATE    AS pfecha_alta;
		  
--****************************************************************************************************
-- Objetivo: Spl que obtiene informaciÃ³n complementaria almacenada en SOC para mostrar en generaPortadaCtaMEC2
-- Autor: Nadia Ordaz
-- FECHA : 10/10/2024
-- SOLICITO : Isaac Flores
-- BD: bdicnweb
--***************************************************************************************************

--DEFINICIONES
	DEFINE iSql_Err                     INTEGER;
	DEFINE cCodRet                      CHAR(5);
	DEFINE cMensaje                     CHAR(50);
    
	DEFINE pproced_aperturacta          CHAR(2);
	DEFINE pproced_mantenercta          CHAR(2);
	DEFINE pmonto_mensual               CHAR(2);
	DEFINE pdepositos_cantidad          CHAR(2);
	DEFINE pdepositos_monto             CHAR(2);
	DEFINE pretiros_cantidad            CHAR(2);
	DEFINE pretiros_monto               CHAR(2);
	DEFINE pfecha_alta                  DATE;
	
--INICIALIZACIONES			  
    LET iSql_Err           	= 0;
    LET cCodRet           	= '00000';
    LET cMensaje          	= 'SE EJECUTO CORRECTAMENTE';
    LET pproced_aperturacta = '';
    LET pproced_mantenercta = '';
    LET pmonto_mensual      = '';
    LET pdepositos_cantidad = '';
    LET pdepositos_monto    = '';
    LET pretiros_cantidad   = '';
    LET pretiros_monto      = '';
    LET pfecha_alta         = '';
	
BEGIN

    ON EXCEPTION SET iSql_Err
        LET cCodRet = iSql_Err;
        LET cMensaje = '';
		RETURN cCodRet, cMensaje, pproced_aperturacta, pproced_mantenercta, pmonto_mensual, pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pfecha_alta;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/mfinis/portadaCtaMEC2_complementoinfo.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	IF TRIM(NVL(pNumCtaEmp,'')) = '' THEN
		LET cCodRet = '00001';
		LET cMensaje = 'FALTAN PARAMETROS PARA SU EJECUCION';
		RETURN cCodRet, cMensaje, pproced_aperturacta, pproced_mantenercta, pmonto_mensual, pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pfecha_alta;
	END IF;
	
	--BUSCA INFORMACION COMPLEMENTARIA EN SOC, PARA PORTADA CTAMEC2, SE AÃADE FECHA ALTA SC_MAENOC
	SELECT A.proced_aperturacta, A.proced_mantenercta, A.depositos_cantidad, A.depositos_monto, A.retiros_cantidad, A.retiros_monto, A.monto_mensual, B.fecha_alta
	INTO pproced_aperturacta, pproced_mantenercta, pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pmonto_mensual, pfecha_alta
	FROM bdicheq:sc_maechq A
    INNER JOIN bdicheq:sc_maenoc AS B ON A.empresa = B. empresa
        AND A.cuenta = B.cuenta
	WHERE A.empresa = '001'
		AND B.cuenta = pNumCtaEmp;
		
	RETURN cCodRet, cMensaje, pproced_aperturacta, pproced_mantenercta, pmonto_mensual, pdepositos_cantidad, pdepositos_monto, pretiros_cantidad, pretiros_monto, pfecha_alta;

END
END PROCEDURE

DOCUMENT
'DESCRIPCION: Se agrega campo fecha_alta a la consulta de informaciÃ³n',
'MODIFICO: Isaac Flores Ruiz',
'FECHA: 09/10/2024';

CREATE PROCEDURE "informix".sp_cnsif_consdetallemovimientos2(pUsuario CHAR(8), pIdFuncion CHAR(10), pSistemaCuenta CHAR(20), pFechaInicial DATE, pFechaFinal DATE, 
															 pNumCuenta CHAR(20), pEjecutivo CHAR(8), pSucursal CHAR(4), pImporte MONEY(14,2), pClaveMov CHAR(50),
															 pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING 	CHAR(5) 		AS codret,
				DATE     		AS fecha,
				DATETIME HOUR TO FRACTION(3) AS hora,
				CHAR(4)  		AS cve_transaccion,
				CHAR(50) 		AS desc_transaccion,
				CHAR(16) 		AS folio,
				DATE     		AS periodo_inicial,
				MONEY(14,2) 	AS monto,
				DATE     		AS periodo_final,
				CHAR(20) 		AS sistema_cuenta,
				CHAR(1)  		AS naturaleza,
				CHAR(40) 		AS referencia,
				CHAR(1)  		AS reversos,
				CHAR(4)  		AS sucursal,
				CHAR(20) 		AS cve_procedencia,
				CHAR(50) 		AS desc_procedencia,
				MONEY(14,2) 	AS saldo,
				CHAR(20) 		AS numero_tarjeta,
				CHAR(1)  		AS reversados,
				CHAR(8)  		AS usuario,
				CHAR(23) 		AS referencia23,
				CHAR(40)  		AS ordenante,
				DECIMAL(7,0) 	AS ref,
				CHAR(210) 		AS concepto;
	
	--DECLARACIÃ?N DE VARIABLES
	DEFINE cCodRet 		CHAR(5);
	DEFINE iSqlErr 		INTEGER;
	DEFINE cCodRetSp 	CHAR(5);
	DEFINE iCodRetSp	INTEGER;
	DEFINE cEmpresa 	CHAR(3);	
	DEFINE cCmd1 		CHAR(2000);
	DEFINE cSql 		CHAR(2500);
	DEFINE cRutaGral 	CHAR(150);
	DEFINE cNombreArchivo CHAR(45);
	DEFINE iRecuperacion INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	
	DEFINE dFecha DATE;
	DEFINE dHora DATETIME HOUR TO FRACTION(3);
	DEFINE cCveTransacc CHAR(4);
	DEFINE cDescTransacc CHAR(50);
	DEFINE cFolio CHAR(16);
	DEFINE dPeriodoInicial DATE;
	DEFINE mMonto MONEY(14,2);
	DEFINE dPeriodoFinal DATE;
	DEFINE cSisCuenta CHAR(20);
	DEFINE cNaturaleza CHAR(1);
	DEFINE cReferencia CHAR(40);
	DEFINE cReversos CHAR(1);
	DEFINE cSucursal CHAR(4);
	DEFINE cCveProc CHAR(20);
	DEFINE cDescProc CHAR(50);
	DEFINE mSaldo MONEY(14,2);
	DEFINE cNumTarjeta CHAR(20);
	DEFINE cReversados CHAR(1);
	DEFINE cUsuario CHAR(8);
	DEFINE cReferencia23 CHAR(23);
	DEFINE iContReg INTEGER;
	DEFINE iNumRegistros INTEGER;
	DEFINE dFechaHora DATETIME YEAR TO FRACTION(5);
	DEFINE dFechaInicial  DATE;
	DEFINE dFechaFinal  DATE;

	DEFINE vOrdenante 		CHAR(40);
	DEFINE dRef 			DECIMAL(7,0);
	DEFINE vConcepto		CHAR(210);
	DEFINE iclienteNostro 	INTEGER;
	DEFINE iId_registro 	INTEGER;

	--INICIALIZACIÃ?N DE VARIABLES
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';	
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET iRecuperacion = 0;
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	
	LET dFecha = '';
	LET dHora = '';
	LET cCveTransacc = '';
	LET cDescTransacc = '';
	LET cFolio = '';
	LET dPeriodoInicial = '';
	LET mMonto = 0.00;
	LET dPeriodoFinal = '';
	LET cSisCuenta = '';
	LET cNaturaleza = '';
	LET cReferencia = '';
	LET cReversos = '';
	LET cSucursal = '';
	LET cCveProc = '';
	LET cDescProc = '';
	LET mSaldo = 0.00;
	LET cNumTarjeta = '';
	LET cReversados = '';
	LET cUsuario = '';
	LET cReferencia23 = '';
	LET iContReg = 0;
	LET iNumRegistros = 0;
	LET dFechaHora = CURRENT YEAR TO FRACTION(5);
	LET dFechaInicial =null;
	LET dFechaFinal   =null;
	LET vOrdenante 	  = '';	
	LET dRef 		  = '';
	LET vConcepto	  = '';
	LET iclienteNostro = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cnsif_consdetallemovimientos2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pSistemaCuenta = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL OR pNumCuenta = '' OR 
		pClaveMov = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		END IF;
		
		-- VALIDACIÃ?N DE LOS DATOS DE PAGINACIÃ?N
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		LET dFechaInicial=LPAD(MONTH(pFechaInicial),2,0)||'/'||LPAD(DAY(pFechaInicial),2,0)||'/'||YEAR(pFechaInicial);
		LET dFechaFinal  =LPAD(MONTH(pFechaFinal),2,0)||'/'||LPAD(DAY(pFechaFinal),2,0)||'/'||YEAR(pFechaFinal);

		LET iRecuperacion = 0;

		FOREACH
			SELECT SKIP pRegistros FIRST pRecuperacion id_registro, fecha,hora,cve_transacc,desc_transacc,folio,periodo_inicial,monto,periodo_final,sis_cuenta,naturaleza,referencia,reversos,sucursal,cve_proc,desc_proc,saldo,num_tarjeta,reversados,usuario,referencia23
			INTO iId_registro,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23
			FROM bdicnweb:"informix".sw_cons_movimientos
			WHERE clave_mov = TRIM(pClaveMov)
			AND sis_cuenta = TRIM(pSistemaCuenta)
			AND periodo_inicial = dFechaInicial
			AND periodo_final = dFechaFinal
			ORDER BY fecha DESC,hora DESC,folio,cve_transacc DESC

			--VALIDAMOS QUE SEAN CUENTA NOSTRO
			SELECT COUNT(cuenta_nostro) 
			INTO iclienteNostro
			FROM bdicred:sd_ce_ctas_nostro WHERE status = 1 AND TRIM(pNumCuenta) = TRIM(cuenta_nostro);

			IF iclienteNostro > 0 THEN
                SELECT vchrnombreord as ordenante, intrefnumerica as ref, vchrconceptopago as concepto
                INTO vOrdenante, dRef, vConcepto
                FROM bdispei:tblhistpago
                WHERE dtfechacaptura = dFecha
                AND vchrclaverastreo = cReferencia
                AND mnyimporte = mMonto;
			ELSE 
				LET vOrdenante = '';
				LET dRef 	   = "";
				LET vConcepto  = NULL;
			END IF

			LET iRecuperacion = iRecuperacion + 1;

			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, NVL(vConcepto, "") WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,dFecha,dHora,cCveTransacc,cDescTransacc,cFolio,dPeriodoInicial,mMonto,dPeriodoFinal,cSisCuenta,
			cNaturaleza,cReferencia,cReversos,cSucursal,cCveProc,cDescProc,mSaldo,cNumTarjeta,cReversados,cUsuario,cReferencia23, vOrdenante, dRef, vConcepto;
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA 24/10/2017',
'MODULO: CONSULTAS',
'FUNCIONALIDAD: CONSULTA DE MOVIMIENTOS DE CAPTACIï¿½N/CRï¿½DITO/INVERSIONES',
'DESCRIPCION: SPL encargado de consultar el detalle de los registros que regresarï¿½ la bï¿½squeda por sistema de cuenta ingresado (CAPTACION/CREDITO/INVERSIONES).',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 27/11/2017',
'DESCRIPCION MODIFICACION :  Se agregan variables cFechaInicial  y  cFechaFinal, para tratar la fecha como MM/DD/YYYY ',
'MODIFICACION: Martha Salgado',
'FECHA MODIFICACION: 30/11/2017',
'DESCRIPCION MODIFICACION :  Se cambian variables cFechaInicial  y  cFechaFinal a Date ',
'MODIFICACION: L. Montserrat Leï¿½n Amador',
'FECHA MODIFICACION: 08/01/2018',
'DESCRIPCION MODIFICACION :  Se implementa nuevo filtro de consulta pClaveMov.',
'AUTOR: Rodolfo Conde Flores',
'FECHA 06/02/2017',
'DESCRIPCION MODIFICACION: Se elimina filtro usuario_insert de la tabla bdicnweb:sw_cons_movimientos.',
'AUTOR: Daniel Reyes Guillen',
'FECHA 06/02/2022',
'DESCRIPCION MODIFICACION: Se actualiza order by de la consulta.',
'BD: bdicnweb',
'AUTOR: JosÃ© Antonio RamÃ­rez',
'FECHA MODIFICACION: 27/07/2023',
'DESCRIPCION MODIFICACION: Se agrego la busquedo de los campos ordenante, referencia cliente y concepto para las cuentas NOSTRO.',
'AUTOR: Uriel Amador Islas',
'FECHA MODIFICACION: 21/11/2024',
'DESCRIPCION MODIFICACION: Se quita linea que elimina registros de la tabla sw_cons_movimientos2, dado que la tabla se depura cada semana',
'AUTOR: Uriel Amador Islas',
'FECHA MODIFICACION: 29/11/2024',
'DESCRIPCION MODIFICACION: Se quita inserción de datos en la tabla sw_cons_movimientos2, dado que la tabla se llena desde el SP sp_cnsif_consultamovtosdiarioscta3_2',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_archdiariodepositoscoppelb2(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha DATE, pCuenta CHAR(15), pSucursal CHAR(4), pRutaDescarga CHAR(100))
	RETURNING 	CHAR(5) AS codret,
				CHAR(20) AS cuenta,
				DATE AS fecha_alta,
				CHAR(4) AS forma,
				CHAR(16) AS folio_suc,
				MONEY AS monto_ori,
				CHAR(4) AS sucursal,
				DATETIME HOUR TO MINUTE AS fech_hor,
				CHAR(40) AS descripcion,
				INTEGER AS num_chq,
				MONEY AS monto_tot,
				VARCHAR(100,0) AS nombreReporte;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(5);
	DEFINE cCuenta CHAR(20);
	DEFINE cFecha_alta DATE;
	DEFINE cForma CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE cMonto_ori MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFech_hor DATETIME HOUR TO MINUTE;
	DEFINE cDescripcion CHAR(40);
	DEFINE cNum_chq INTEGER;
	DEFINE cMonto_tot MONEY;
	DEFINE cNombreReporte CHAR(100);
	
	
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cCuenta = '';
	LET cFecha_alta = '';
	LET cForma = '';
	LET cFolio_suc = '';
	LET cMonto_ori = 0;
	LET cSucursal = '';
	LET cFech_hor = '';
	LET cDescripcion = '';
	LET cNum_chq = '';
	LET cMonto_tot = 0;
	LET cNombreReporte = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;			
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_archdiariodepositoscoppelb2.out';
        --TRACE ON;
		
		IF pBandera = '' AND pUsuario = '' AND pIdFuncion = '' THEN	
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
        INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		--LET pFecha = '09-30-2024';
		
		IF pBandera = '1' THEN
			FOREACH
				SELECT cuenta 
				INTO cCuenta
				FROM bdicheq:sc_maechq WHERE empresa = cEmpresa AND status_cta = '3' AND motivo = '99' AND colateral = 'S'
			
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte WITH RESUME;
		
		END FOREACH;

		ELIF pBandera = '2' THEN
		
			FOREACH
			SELECT fecha_alta, 'SBC' AS forma,  folio_suc, monto_ori, sucursal, cuenta, fech_hor, NVL(si.descripcion,'') AS descripcion, num_chq
			INTO cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cCuenta, cFech_hor, cDescripcion, cNum_chq
				FROM  bdinteg:"informix".si_bancos si, bdicheq:"informix".sc_docret d
					WHERE empresa = "001" AND cuenta = pCuenta 
					AND sucursal = (CASE WHEN pSucursal <> '0000' THEN pSucursal ELSE sucursal END) 
					AND fecha_alta =  pFecha
					AND transacc = '0250' AND si.banco = d.referencia[1,3] 
			UNION        
			SELECT fech_alt, 'EFECTIVO' AS forma, folio_suc, monto_tot, sucursal, cuenta, fech_hor,'', num_cheq
				FROM bdicheq:sc_movdia
					WHERE empresa = '001' AND cuenta = pCuenta AND sucursal = (CASE WHEN pSucursal <> '0000' THEN pSucursal ELSE sucursal END) 
					AND fech_alt = pFecha
					AND transacc = '0202'
					AND cancelad <> 'S'
				
				RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte WITH RESUME;
			END FOREACH;
			
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_cc_archdiariodepositoscoppel_repb2('1', pFecha, pCuenta,pSucursal,pRutaDescarga,cEmpresa)					
			INTO cCodRet, cNombreReporte;
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte WITH RESUME;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00017';
			RETURN cCodRet, cCuenta, cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cFech_hor, cDescripcion, cNum_chq, cMonto_tot, cNombreReporte;
			
		END IF;
	
END
END PROCEDURE
DOCUMENT
'AUTOR: Antonio Contreras Sanchez',
'FECHA: 17-11-2022',
'MODULO: CONTABILIDAD',
'FUNCIONALIDAD: Consulta Faltantes',
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos y consultas que ejecuta la funcionalidad',
'DB:bdicnweb';

CREATE PROCEDURE "informix".sp_cc_archdiariodepositoscoppel_repb2(pBandera CHAR(2), pFecha DATE, pCuenta CHAR(20), pSucursal CHAR(4), pRutaDescarga CHAR(100), pEmpresa CHAR(3))
RETURNING 	CHAR(5) AS codret,
			CHAR(45) AS reporte_csv;

DEFINE cCodRet CHAR(5);
DEFINE iSqlErr INTEGER;

DEFINE cNombreRep CHAR(45);
DEFINE cRutaGral CHAR(150);
DEFINE dFechaHoy DATE;
DEFINE dHoraHoy DATETIME HOUR TO MINUTE;
DEFINE dHoy DATE;
DEFINE cNombreReporteHist CHAR(100);
DEFINE ven_transacc SMALLINT;
DEFINE bInTransaction BOOLEAN;
DEFINE referencia CHAR(10);

DEFINE cEmpresa CHAR(5);
DEFINE cCuenta CHAR(20);
DEFINE cFecha_alta DATE;
DEFINE cForma CHAR(4);
DEFINE cFolio_suc CHAR(16);
DEFINE cMonto_ori DECIMAL(16,2);
DEFINE cSucursal CHAR(4);
DEFINE cFech_hor DATETIME HOUR TO MINUTE;
DEFINE cDescripcion CHAR(40);
DEFINE cNum_chq INTEGER;
DEFINE cMonto_tot MONEY;
DEFINE iContador INTEGER;

	
LET cCodRet = '00000';
LET iSqlErr = 0;

LET cNombreRep = '';
LET cRutaGral = '';
LET dFechaHoy = '';
LET dFechaHoy = '';
LET dHoraHoy = '';
LET cNombreReporteHist = '';
LET bInTransaction = 'f';
LET ven_transacc = 0;
LET referencia = "";

LET cCuenta = '';
LET cFecha_alta = '';
LET cForma = '';
LET cFolio_suc = '';
LET cMonto_ori = 0;
LET cSucursal = '';
LET cFech_hor = '';
LET cDescripcion = '';
LET cNum_chq = '';
LET cMonto_tot = 0;
LET iContador = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cNombreRep;
		END EXCEPTION;

		ON EXCEPTION IN (-668,-535,-255)

		END EXCEPTION WITH RESUME;
		
		IF  pBandera = '' OR pFecha = '' OR pCuenta = '' OR pSucursal = ''OR pRutaDescarga='' OR pFecha='' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cNombreRep;
		END IF;
		IF pBandera < '1' OR pBandera > 2 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNombreRep;
		
		END IF;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cc_archdiariodepositoscoppel_repb2.out';
		--TRACE ON;
			
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		LET cNombreRep = 'Depositocoppl'||"_"||TO_CHAR(CURRENT, '%d%m%Y')||'.txt';
		
		LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
		LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreRep);
		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;

		-- ESCRITURA DE LA CADENA DE TEXTO EN EL ARCHIVO
		SYSTEM "echo 'FECHA DEPOSITO|FORMA DEPOSITO|FOLIO SUC|MONTO DEPOSITO|SUCURSAL|CUENTA|FECHA HORA|DESCRIPCION|NO. CHEQUE|'" || " > " ||TRIM(pRutaDescarga)||TRIM(cNombreRep);

		FOREACH
			SELECT fecha_alta, 'SBC' AS forma,  folio_suc, monto_ori, sucursal, cuenta, fech_hor, NVL(si.descripcion,'') AS descripcion, num_chq
			INTO cFecha_alta, cForma, cFolio_suc, cMonto_ori, cSucursal, cCuenta, cFech_hor, cDescripcion, cNum_chq
				FROM  bdinteg:"informix".si_bancos si, bdicheq:"informix".sc_docret d
					WHERE empresa = "001" AND cuenta = pCuenta 
					AND sucursal = (CASE WHEN pSucursal <> '0000' THEN pSucursal ELSE sucursal END) 
					AND fecha_alta =  pFecha
					AND transacc = '0250' AND si.banco = d.referencia[1,3] 
			UNION        
			SELECT fech_alt, 'EFECTIVO' AS forma, folio_suc, monto_tot, sucursal, cuenta, fech_hor,'', num_cheq
				FROM bdicheq:sc_movdia
					WHERE empresa = '001' AND cuenta = pCuenta AND sucursal = (CASE WHEN pSucursal <> '0000' THEN pSucursal ELSE sucursal END) 
					AND fech_alt = pFecha
					AND transacc = '0202'
					AND cancelad <> 'S'

			LET iContador = iContador + 1;
			SYSTEM 'echo "'||cFecha_alta||'|'||TRIM(cForma)||'|'||TRIM(cFolio_suc)||'|'||TO_CHAR(cMonto_ori)||'|'||TRIM(cSucursal)||'|'||TRIM(cCuenta)||'|'||cFech_hor||'|'||TRIM(cDescripcion)||'|'||cNum_chq||'|" >> '||TRIM(pRutaDescarga)||TRIM(cNombreRep);

		END FOREACH

		IF iContador = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cNombreRep;
		END IF;

		SYSTEM "chmod 777 "||TRIM(pRutaDescarga)||TRIM(cNombreRep);
		
		
		RETURN cCodRet,cNombreRep;
	END
END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Avila Perez Tagle",
'MODULO: Contabilidad',
"FUNCIONAMIENTO:SP secundario para obtener la informacion para generar reporte de errores",
"FECHA : 17-02-2023",
"BD    : bdicnweb";

CREATE PROCEDURE "informix".sp_reporte_diario_devoluciones_deposito(pBandera CHAR(2), 
												pFechaDevo DATE, 
												pCuenta1 CHAR(20), 
												pCuenta2 CHAR(20), 
												pTranDev CHAR(4), 
												pTranCom CHAR(4), 
												pTranIva CHAR(4),
												pRegistros INTEGER,
												pRecuperacion INTEGER,
												pFecha DATE,
												pUsuario CHAR(8),
												pIdFuncion CHAR(10),
												pCodError CHAR(3)
												)
												
RETURNING
			char(5) AS codRet,       
            char(45) AS nom_sucursal,      
            char(100) AS banco,      
            char(7) AS nroCheque,       
            decimal(16,2) AS importe, 
            decimal(8,2) AS comision,  
            decimal(8,2) AS iva, 
			char(45) AS motivoDev,
			CHAR(20) AS numCuenta,
			DECIMAL(16,2) AS monto,
			CHAR(20) AS cuentaDeposito,
			CHAR(5) AS codRetDev, 
			CHAR(2) AS motivo,
			CHAR(35) AS desc_motivo,
			CHAR(4) AS sucursal, 
			CHAR (50) AS desc_error,
			CHAR(4) AS transacc_com, 
			CHAR(4) AS transacc_iva,
			CHAR(4) AS transacc_comision,
			CHAR(20) AS cta_col;
		
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
		
DEFINE v_codret      char(5);
DEFINE v_nom_sucursal    char(45);   
DEFINE v_banco       char(4);
DEFINE v_numcheque   char(7);
DEFINE v_importe     decimal(16,2);
DEFINE v_com         decimal(8,2);   
DEFINE v_iva         decimal(8,2);   
DEFINE v_folio       char(16);   
DEFINE v_motivodev   char(45);   
DEFINE iSqlErr 		 INT;
DEFINE isam_err      INT;  
DEFINE v_empresa 	CHAR(3);
DEFINE v_noregistros INTEGER;
DEFINE v_numcuenta 	CHAR(20);
DEFINE v_monto	DECIMAL(16,2);
DEFINE v_cuentadeposito CHAR(20);
DEFINE v_codretdev CHAR(5);
DEFINE v_desc_motivo CHAR(35);
DEFINE v_sucursal CHAR(4);
DEFINE v_desc_error CHAR(50);
DEFINE v_transacc_com CHAR(4);
DEFINE v_transacc_iva CHAR(4);
DEFINE v_transacc_comision CHAR(4);
DEFINE v_cta_col	CHAR(20);
DEFINE v_nom_banco CHAR(45);
DEFINE v_sucursal_comp CHAR(100);
-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
 let v_codret        = "00000";
 let v_sucursal      = " ";      
 let v_banco         = " ";
 let v_numcheque     = " ";        
 let v_importe       = 0;
 let v_com           = 0;   
 let v_iva           = 0;   
 let v_empresa		 = '001';
 let v_noregistros	 = 0;
 let v_numcuenta	 = '';
 let v_monto 		 = 0;
 let v_cuentadeposito = '';
 LET v_codretdev	 = '00000';
 LET v_motivodev	 = '';
 LET v_desc_motivo	 = '';
 LET v_sucursal		 = '';
 LET v_desc_error	 = '';
 LET v_transacc_com  = '';
 LET v_transacc_iva  = '';
 LET v_transacc_comision = '';
 LET v_cta_col		 = '';
 LET v_nom_sucursal = "";
 LET v_nom_banco = "";
 LET v_sucursal_comp = "";

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
	
		ON EXCEPTION SET iSqlErr
			LET v_codRet = iSqlErr;			
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporte_diario_devoluciones_deposito.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		
		IF pBandera = '1' THEN
			IF pFechaDevo = '' OR pCuenta1 = '' OR pCuenta2 = '' OR pTranDev = '' OR pTranCom = '' OR pTranIva = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '2' THEN
			IF pFechaDevo = '' OR pCuenta1 = '' OR pCuenta2 = '' OR pTranDev = '' OR pTranCom = '' OR pTranIva = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '3' THEN
			IF pFecha = '' OR pCuenta1 = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '4' THEN
			IF pFecha = '' OR pFecha = '' OR pCuenta1 = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		
		ELIF pBandera = '5' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pCodError = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '6' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pCuenta1 = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '7' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pCuenta1 = '' OR pFecha = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '8' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '9' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		ELIF pBandera = '10' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pFechaDevo = '' OR pCuenta1 = '' OR pCuenta2 = '' OR pTranDev = '' OR pTranCom = '' OR pTranIva = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET v_codret = '00003';
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
			END IF;
		END IF;


		IF pBandera = '1' THEN
			FOREACH
			EXECUTE PROCEDURE bditef:"informix".cons_dev_coppel2(v_empresa, pFechaDevo, pCuenta1, pCuenta2, pTranDev, pTranCom, pTranIva, pRegistros, pRecuperacion)
			INTO  v_codret,v_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev

			IF v_codret = '000' THEN
				LET v_codRet = '00000';
			END IF;

			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
			v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col WITH RESUME;
			END FOREACH;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bditef:"informix".cons_dev_coppel2_totales(v_empresa, pFechaDevo, pCuenta1, pCuenta2, pTranDev, pTranCom, pTranIva)
			INTO v_codret, v_cta_col;

				IF v_codret = '000' THEN
				LET v_codRet = '00000';
			END IF;
			
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
		ELIF pBandera = '3' THEN
			
			FOREACH
				EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_devcoppel2(v_empresa, pFecha, pCuenta1, pRegistros, pRecuperacion)
				INTO v_codret, v_banco, v_numcuenta, v_numcheque, v_monto, v_cuentadeposito, v_codretdev, v_motivodev, v_desc_motivo, v_sucursal, v_nom_sucursal
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col WITH RESUME;
			END FOREACH;
			
		ELIF pBandera = '4' THEN
			
			EXECUTE PROCEDURE bditef:'informix'.sp_cce_consultar_chequesdev_devcoppel2_totales(v_empresa, pFecha, pCuenta1)
			INTO v_codret, v_cta_col;
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;

		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE "informix".sp_ope_consdescripcionerror(pUsuario, pIdFuncion, pCodError)
			INTO v_codret, v_desc_error;
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
		
		ELIF pBandera = '6' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_constdevolucion(pUsuario, pIdFuncion, pFecha, pCuenta1, pRegistros, pRecuperacion)
				INTO v_codret,v_banco,v_numcuenta,v_numcheque,v_monto,v_cuentadeposito,v_codretdev,v_motivodev,v_desc_motivo,v_sucursal,v_nom_sucursal, v_nom_banco
				LET v_sucursal_comp = TRIM(v_sucursal)||' '||TRIM(v_nom_sucursal);
				RETURN  v_codret,v_nom_banco,v_sucursal_comp,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev,
				v_motivodev, v_desc_motivo, v_banco, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col WITH RESUME;	
			END FOREACH;
		ELIF pBandera = '7' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_constdevolucion_totales(pUsuario, pIdFuncion, pFecha, pCuenta1)	
			INTO v_codret, v_cta_col;
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;
		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE "informix".sp_ope_constransacioneschqs(pUsuario, pIdFuncion)
			INTO v_codret, v_transacc_com, v_transacc_iva, v_transacc_comision;
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col;

		ELIF pBandera = '9' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_consultactascoppelcolateral(pUsuario, pIdFuncion)
				INTO v_codret, v_cuentadeposito, v_cta_col
				RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 		
				v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col WITH RESUME;
			END FOREACH

		ELIF pBandera = '10' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_ope_genreportediariodev(pUsuario, pIdFuncion, pFechaDevo, pCuenta1, pCuenta2, pTranDev, pTranCom, pTranIva, pRegistros, 
			pRecuperacion)
			INTO v_codret, v_sucursal, v_banco, v_numcheque, v_importe, v_com, v_iva, v_motivodev
			RETURN  v_codret,v_nom_sucursal,v_banco,v_numcheque,v_importe,v_com,v_iva,v_motivodev, v_numcuenta, v_monto, v_cuentadeposito, v_codretdev, 
		v_motivodev, v_desc_motivo, v_sucursal, v_desc_error, v_transacc_com, v_transacc_iva, v_transacc_comision, v_cta_col WITH RESUME;
		END FOREACH;

	
		END IF;
	END;

END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - Reporte diario devoluciones diarias",
"FECHA : 03-03-2023",
"AUTOR: Veronica Sanchez",
"FECHA: 29/10/2024",
"DESCRIPCION: Se realizo ajuste a bandera 6 para recuperar la descripcion del banco de forma correcta",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_ope_consdescripcionerror(pUsuario CHAR(8), pIdFuncion CHAR(10),pCodError CHAR(3))
		RETURNING CHAR(5) AS codret,
		CHAR(50) AS des_error;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cDesError CHAR(50);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cDesError = '';
	LET iNoRegistros = 0;	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDesError;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consdescripcionerror.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCodError = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cDesError;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cDesError;
		END IF;
		
		SELECT descripcion 
		INTO cDesError
		FROM bdinteg:"informix".si_codret 
          WHERE codigo_retorno = pCodError
          AND sistema='01';		
		
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; --NO SE ENCONTRARON RESULTADOS
			RETURN cCodRet, UPPER(cDesError);
		END IF;
		
		RETURN cCodRet,cDesError;	
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que realizara la consulta de la descripciï¿½n del error generado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constdevolucion(pUsuario CHAR(8), pIdFuncion CHAR(10), pFecha CHAR(10), pCtaDev CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(3) 		AS banco,
		CHAR(20) 		AS num_cuenta,
		CHAR(7) 		AS num_cheque,
		DECIMAL(16,2) 	AS monto,
		CHAR(20) 		AS cta_deposito,
		CHAR(5) 		AS cod_ret_dev,
		CHAR(2) 		AS motivo,
		CHAR(35) 		AS desc_motivo,
		CHAR(4)			AS sucursal,
		CHAR(40)		AS nom_sucursal,		
		CHAR(40)		AS descripcion;		


	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cBanco			CHAR(3);
	DEFINE cNumCuenta		CHAR(20);
	DEFINE cNumCheque		CHAR(7);
    DEFINE dMonto			DECIMAL(16,2);
	DEFINE cCta_Deposito	CHAR(20);
	DEFINE cCodigoRetDev	CHAR(5);
    DEFINE cMotivo			CHAR(2);
	DEFINE cDescMotivo		CHAR(35);
    DEFINE cSucursal		CHAR(4);
	DEFINE cNomSucursal		CHAR(40);
	DEFINE cDescripcion		CHAR(40);
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cBanco				= '';
	LET cDescripcion		= '';
	LET cNumCuenta			= '';
	LET cNumCheque			= '';
    LET dMonto				= 0.0;
	LET cCta_Deposito		= '';
	LET cCodigoRetDev		= '';
    LET cMotivo				= '';
	LET cDescMotivo			= '';
    LET cSucursal			= '';
	LET cNomSucursal		= '';
	LET iRegistros = 0;
	LET iRecuperacion = 0; 
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constdevolucion.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pFecha = '' OR pCtaDev = '' OR  pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
		END IF;
				
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_devcoppel2(cEmpresa,pFecha, pCtaDev,pRegistros, pRecuperacion)
			INTO cCodRetSp,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bditef:sp_cce_consultar_chequesdev_devcoppel2';
		ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';
		END IF;			
		
		SELECT descripcion
			INTO cDescripcion
		FROM bdinteg:"informix".si_bancos
			WHERE banco = cBanco;
		
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,UPPER(TRIM(cDescripcion)) WITH RESUME;	
			
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN 
				LET cCodRet ='00017';
				RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
			ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
				LET cCodRet ='1001';
				RETURN cCodRet,cBanco,cNumCuenta,cNumCheque,dMonto,cCta_Deposito,cCodigoRetDev,cMotivo,cDescMotivo,cSucursal,cNomSucursal,cDescripcion;
			END IF;		
	END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que consulta el detalle de datos de la funcionalidad de Reporte Diario Devoluciones Depï¿½sitos Coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constdevolucion_totales(pUsuario CHAR(8), pIdFuncion CHAR(10),pFecha CHAR(10), pCtaDev CHAR(20))	
		RETURNING CHAR(5) AS codret,                           
			INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constdevolucion_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		--EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		EXECUTE PROCEDURE bditef:"informix".sp_cce_consultar_chequesdev_devcoppel2_totales('001',pFecha, pCtaDev)
		--EXECUTE PROCEDURE bdicont:"informix".sp_cce_consultar_chequesdev_devcoppel2_totales('001',pFecha, pCtaDev)		
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bditef:sp_cce_consultar_chequesdev_devcoppel2_totales';
			--RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bdicheq:sp_cce_consultar_chequesdev_devcoppel2_totales';
		ELIF cCodRetSp::INTEGER = 1  THEN
				LET cCodRet = '00003';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;		
		
		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que consulta el total de datos de la funcionalidad de Reporte Diario Devoluciones Depï¿½sitos Coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_constransacioneschqs(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(4) AS transacc_com, 
		CHAR(4) AS transacc_iva,
		CHAR(4) AS comision;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cTransacCom CHAR(4);
	DEFINE cTransacIva CHAR(4);
	DEFINE cComision CHAR(4);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cTransacCom = '';
	LET cTransacIva = '';
	LET cComision = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cTransacCom,cTransacIva,cComision;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_constransacioneschqs.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cTransacCom,cTransacIva,cComision;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cTransacCom,cTransacIva,cComision;
		END IF;
		
		SELECT transacc_com, transacc_iva,comision  
			INTO cTransacCom,cTransacIva,cComision
			FROM bdicheq:"informix".sc_comisiones 
			WHERE empresa = '001' 
			AND comision = (SELECT valor FROM bdicheq:"informix".sc_param WHERE codparam = 'trandevobco');
				
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet,cTransacCom,cTransacIva,cComision;	
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet,cTransacCom,cTransacIva,cComision;
		END IF;		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que realizara la consulta para obtener las transacciones de la comisiï¿½n de cheques devueltos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultactascoppelcolateral(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret,
		CHAR(20) AS cuenta, 
		CHAR(20) AS cta_col;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cCuenta  CHAR(20);
	DEFINE cCuentaCol CHAR(20);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cCuenta  = '';
	LET cCuentaCol = '';
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cCuenta ,cCuentaCol;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultactascoppelcolateral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cCuenta ,cCuentaCol;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cCuenta ,cCuentaCol;
		END IF;

		DROP TABLE IF EXISTS sc_colateral_tmp;

		CREATE TEMP TABLE sc_colateral_tmp(
			cuenta char(20),
			cta_col char(20)
		) WITH NO LOG;

		INSERT INTO sc_colateral_tmp 
		SELECT cuenta,cta_col 
				FROM bdicheq:"informix".sc_colateral 
				WHERE empresa = '001' 
				AND cuenta = ( SELECT DISTINCT cuenta 
							   FROM bdicheq:"informix".sc_maechq 
							   WHERE status_cta='3' AND colateral='S' AND motivo='99');
		
		FOREACH 		
		
			SELECT cuenta, cta_col
			INTO cCuenta ,cCuentaCol 
			FROM sc_colateral_tmp

			LET iNoRegistros = iNoRegistros + 1;

			RETURN cCodRet,cCuenta ,cCuentaCol WITH RESUME;	
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			DROP TABLE sc_colateral_tmp;
			RETURN cCodRet,cCuenta ,cCuentaCol ;
		END IF;		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 03/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que realizara la consulta de las cuenta Coppel y Colateral.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genreportediariodev(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaDev DATE,pCuenta1 CHAR(20), pCuenta2 CHAR(20), pTransDev CHAR(4), pTranCom CHAR(4),pTransIva CHAR(4),pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(45)		AS  sucursal,     
		CHAR(100)		AS  banco,    
		CHAR(7)			AS  num_cheque,      
		DECIMAL(16,2)	AS  importe,
		DECIMAL(8,2)	AS 	comision, 
		DECIMAL(8,2)	AS 	iva, 
		CHAR(45)		AS 	motivo_dev;	
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(45);   
	DEFINE cBanco CHAR(100);
	DEFINE cNumcheque CHAR(7);
	DEFINE dImporte DECIMAL(16,2);
	DEFINE dComision DECIMAL(8,2);   
	DEFINE dIva DECIMAL(8,2);   
	DEFINE cMotivodev CHAR(45);	
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cSucursal 	= '';  
	LET cBanco 		= '';
	LET cNumcheque 	= '';
	LET dImporte 	= 0.00;
	LET dComision 	= 0.00;  
	LET dIva 		= 0.00;  
	LET cMotivodev 	= '';	
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genreportediariodev.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaDev IS NULL  OR pCuenta1 = '' OR pCuenta2 = '' OR pTransDev = '' OR pTranCom = '' OR pTransIva = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		
		FOREACH
			EXECUTE PROCEDURE bditef:"informix".cons_dev_coppel2(cEmpresa, pFechaDev, pCuenta1, pCuenta2,pTransDev, pTranCom,pTransIva,pRegistros, pRecuperacion)
			INTO cCodRetSp,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev
			
			IF cCodRetSp::INTEGER < 0 THEN
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCION DEL SP bditef:cons_dev_coppel2';
			ELIF cCodRetSp::INTEGER = 110  THEN
				LET cCodRet = '00003';			
			END IF;			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet,UPPER(TRIM(cSucursal)),UPPER(TRIM(cBanco)),cNumcheque,dImporte,dComision,dIva,UPPER(TRIM(cMotivodev)) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet,cSucursal,cBanco,cNumcheque,dImporte,dComision,dIva,cMotivodev;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe Angelica Hernandez Perez',
'FECHA: 04/12/2015',
'MODULO: Cï¿½MARA COMPENSACIï¿½N',
'FUNCIONALIDAD: REPORTE DIARIO DEVOLUCIONES DEPï¿½SITOS COPPEL',
'DESCRIPCION: SPL que realiza el detalle de los datos para el llenado del reporte de la funcionalidad de Reporte Diario Devoluciones Depï¿½sitos Coppel.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_reporte_revision_imagenes_cheques(pBandera CHAR(2), 
																pUsuario CHAR(8), 	
																pIdFuncion CHAR(10), 
																pNumEjecut INTEGER, 
																pTipoReporte INTEGER,
																pFechaInicio DATE,
																pFechaFin DATE,
																pRegistros INTEGER,
																pRecuperacion INTEGER)


RETURNING CHAR(5) AS codret,
		INTEGER	AS id_ejecutivo,
        CHAR(100)	AS nombre_ejecut,
		CHAR(7) AS cheque,
		CHAR(8) AS tiempo_inicio,
		CHAR(8) AS tiempo_final,
		CHAR(1) AS indicador_revisado,
		CHAR(8) AS tiempo_total,
		DATE	 AS fecha_revision,
		INTEGER AS tiempo_total_revision,
		INTEGER AS tiempo_total_No_Revision,
		CHAR(8) AS no_revisados,
		CHAR(8) AS revisados,
		INTEGER AS total_cheques,
		INTEGER AS total_operadores;	

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIdEjecutivo INTEGER;
	DEFINE cNombreEjecutivo CHAR (100);
	DEFINE iNoRegistros INTEGER;


	DEFINE iNumEjecutivo INTEGER;
    DEFINE cCheque        CHAR(7);
    DEFINE dTiempoInicio  DATETIME HOUR TO SECOND;
    DEFINE dTiempoFinal   DATETIME HOUR TO SECOND;
    DEFINE dIndicadorRevisado      CHAR(1);
    DEFINE dTiempoTotal   DATETIME HOUR TO SECOND;
    DEFINE dFechaRevision DATE;
    DEFINE iRevisionTotal INTEGER;
    DEFINE iNoRevisionTotal INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNoRevisados DATETIME HOUR TO SECOND;
	DEFINE cRevisados DATETIME HOUR TO SECOND;
	DEFINE iTotalCheques	INTEGER;
	DEFINE iTotalOperadores INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNumEjecutivo = 0;
    LET cCheque = '';
    LET dTiempoInicio = DATE(1);
    LET dTiempoFinal = DATE(1);
    LET dIndicadorRevisado = '';
    LET dTiempoTotal = DATE(1);
    LET dFechaRevision = DATE(1);
    LET iRevisionTotal = 0;
    LET iNoRevisionTotal = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNoRevisados = DATE(1);
	LET cRevisados = DATE(1);
	LET iTotalCheques	= 0;
	LET iTotalOperadores = 0;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iIdEjecutivo = 0;
	LET cNombreEjecutivo = '';
	LET iNoRegistros = 0;

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, 
					iRevisionTotal, iNoRevisionTotal, cNoRevisados, cRevisados, iTotalCheques, iTotalOperadores;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************

		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pNumEjecut = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, 
					iRevisionTotal, iNoRevisionTotal, cNoRevisados, cRevisados, iTotalCheques, iTotalOperadores;
			END IF;
		ELIF pBandera = '2' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pTipoReporte = '' OR pFechaInicio = '' OR pFechaFin = '' OR pNumEjecut = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, 
					iRevisionTotal, iNoRevisionTotal, cNoRevisados, cRevisados, iTotalCheques, iTotalOperadores;
			END IF;
		END IF;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_reporte_revision_imagenes_cheques.out';
    	--TRACE ON;
		
		IF pBandera = '1' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_consultausuariosaut(pUsuario, pIdFuncion, pNumEjecut)
				INTO cCodRet,iIdEjecutivo,cNombreEjecutivo
				RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, 
						iRevisionTotal, iNoRevisionTotal, cNoRevisados, cRevisados, iTotalCheques, iTotalOperadores WITH RESUME;
			END FOREACH
		ELIF pBandera = '2' THEN

				IF pNumEjecut = 0 THEN 
					LET pNumEjecut = '';
				END IF;
				
			FOREACH
			
				EXECUTE PROCEDURE "informix".sp_ope_genreporteimagenchqs(pUsuario, pIdFuncion, pTipoReporte, pFechaInicio, pFechaFin, pNumEjecut, pRegistros, pRecuperacion)
				INTO cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, 
					iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores


				RETURN cCodRet,iNumEjecutivo,cNombreEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, 
					iRevisionTotal, iNoRevisionTotal, cNoRevisados, cRevisados, iTotalCheques, iTotalOperadores WITH RESUME;
			END FOREACH
		END IF;
	END;
END PROCEDURE
DOCUMENT
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - Reporte revisiÃ³n imagenes cheques",
"FECHA : 03-03-2023",
'AUTOR: Veronica Sanchez Tlacomulco',
'FECHA: 29/10/2024',
'DESCRIPCION: Se realiza modificacion a procedimiento para colocar los retornos de informacion de forma correcta, se omitieron los campos',
'cNoRevisados, cRevisados, iNumEjecutivo para bandera 2',
'DB: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultausuariosaut(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumEjecut INTEGER)
		RETURNING CHAR(5) AS codret,
		INTEGER	AS id_ejecutivo,
        CHAR(100)	AS nombre_ejecut;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iIdEjecutivo INTEGER;
	DEFINE cNombreEjecutivo CHAR (100);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iIdEjecutivo = 0;
	LET cNombreEjecutivo = '';
	LET iNoRegistros = 0;
		
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultausuariosaut.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
			EXECUTE PROCEDURE  bditef:"informix".sp_cce_consultausuariosaut(pNumEjecut)
			INTO  cCodRetSp, iIdEjecutivo,cNombreEjecutivo		
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, "ERROR EN LA EJECUCION DEL SP bditef:sp_cce_consultausuariosaut ";
			ELIF cCodRetSp::INTEGER = 1 THEN
					LET cCodRet = '00775'; --NO HAY USUARIOS REGISTRADOS PARA MOSTRAR.
			END IF;
			LET iNoRegistros = iNoRegistros + 1;
				RETURN cCodRet,iIdEjecutivo, UPPER(TRIM(cNombreEjecutivo)) WITH RESUME;		
		END FOREACH;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00775'; --NO HAY USUARIOS REGISTRADOS PARA MOSTRAR.
			RETURN cCodRet,iIdEjecutivo,cNombreEjecutivo;
		END IF;		
		END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 17/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DE REVISIï¿½N DE IMï¿½GENES DE CHEQUES',
'DESCRIPCION: SPL que valida si el usuario contiene los permisos necesarios para el reporte de revisiï¿½n de imagenes de cheques',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_genreporteimagenchqs(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoReporte INTEGER, pFechaInicio DATE,pFechaFin DATE, pNumEjecut CHAR(8), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
					INTEGER AS num_ejecut,
					CHAR(7) AS cheque,
					CHAR(8) AS tiempo_inicio,
					CHAR(8) AS tiempo_final,
					CHAR(1) AS indicador_revisado,
					CHAR(8) AS tiempo_total,
					DATE	 AS fecha_revision,
					INTEGER AS tiempo_total_revision,
					INTEGER AS tiempo_total_No_Revision,
					CHAR(8) AS no_revisados,
					CHAR(8) AS revisados,
					INTEGER AS total_cheques,
					INTEGER AS total_operadores;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumEjecutivo INTEGER;
    DEFINE cCheque        CHAR(7);
    DEFINE dTiempoInicio  DATETIME HOUR TO SECOND;
    DEFINE dTiempoFinal   DATETIME HOUR TO SECOND;
    DEFINE dIndicadorRevisado      CHAR(1);
    DEFINE dTiempoTotal   DATETIME HOUR TO SECOND;
    DEFINE dFechaRevision DATE;
    DEFINE iRevisionTotal INTEGER;
    DEFINE iNoRevisionTotal INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cNoRevisados DATETIME HOUR TO SECOND;
	DEFINE cRevisados DATETIME HOUR TO SECOND;
	DEFINE iTotalCheques	INTEGER;
	DEFINE iTotalOperadores INTEGER;	
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '00000';
	LET iCodRetSp = 0;
	LET iNumEjecutivo = 0;
    LET cCheque = '';
    LET dTiempoInicio = DATE(1);
    LET dTiempoFinal = DATE(1);
    LET dIndicadorRevisado = '';
    LET dTiempoTotal = DATE(1);
    LET dFechaRevision = DATE(1);
    LET iRevisionTotal = 0;
    LET iNoRevisionTotal = 0;
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET cNoRevisados = DATE(1);
	LET cRevisados = DATE(1);
	LET iTotalCheques	= 0;
	LET iTotalOperadores = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_genreporteimagenchqs.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pTipoReporte IS NULL  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		END IF;
		
		SET ISOLATION TO DIRTY READ;			
		FOREACH
			EXECUTE PROCEDURE bdicheq:"informix".sp_cce_reporterevimg2('001',pTipoReporte, pFechaInicio,pFechaFin, pNumEjecut, pRegistros, pRecuperacion)
			INTO cCodRetSp, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_reporterevimg2';
			END IF;	
			
			IF (dIndicadorRevisado = 0) THEN
				LET cNoRevisados = dTiempoTotal;
				LET cRevisados = '';
			ELIF (dIndicadorRevisado = 1) THEN
				LET cRevisados = dTiempoTotal;
				LET cNoRevisados = '';
			END IF;
			IF (pTipoReporte = 1 ) THEN 
				SELECT --{+INDEX (bditef:"informix".cce_cheques_revisados  idx_cce_cheques_revisados_ejecutivo)}
				count (distinct ejecutivo_reviso),count(ejecutivo_reviso)
				INTO iTotalOperadores, iTotalCheques
				FROM bditef:"informix".cce_cheques_revisados 
				WHERE fecha_revision BETWEEN  pFechaInicio  AND  pFechaFin
				AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut ELSE ejecutivo_reviso END
				AND revisado IN (1,0);
			
			ELIF (pTipoReporte = 2) THEN 
				SELECT --{+INDEX (bditef:"informix".cce_cheques_revisados  idx_cce_cheques_revisados_ejecutivo)}
				count (distinct ejecutivo_reviso), count(ejecutivo_reviso)
				INTO iTotalOperadores, iTotalCheques
				FROM bditef:"informix".cce_cheques_revisados 
				WHERE fecha_revision BETWEEN  pFechaInicio  AND  pFechaFin
				AND ejecutivo_reviso = CASE WHEN NVL(pNumEjecut,'') <> '' THEN pNumEjecut ELSE ejecutivo_reviso END
				AND revisado IN (1,0);
			END IF;		
			
			IF iRecuperacion = 0 AND pRegistros = 0 AND iCodRetSp = 1 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		ELIF iRecuperacion = 0 AND pRegistros > 0 AND iCodRetSp = 1 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores;
		END IF;
			LET iRecuperacion = iRecuperacion + 1;				
			RETURN cCodRet, iNumEjecutivo, cCheque, dTiempoInicio, dTiempoFinal, dIndicadorRevisado, dTiempoTotal, dFechaRevision, iRevisionTotal, iNoRevisionTotal,cNoRevisados,cRevisados, iTotalCheques,iTotalOperadores  WITH RESUME;
	END FOREACH; 
				 		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 09/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: REPORTES DE REVISION DE IMAGENES DE CHEQUES',
'DESCRIPCION: SPL que regresa los datos para el reporte de revision de imagenes de cheques',
'BD: bdicnweb',
'AUTOR: Veronica Sanchez',
'FECHA: 29/10/2024',
'DESCRIPCION: se realiza ajuste a consulta para recuperar de forma correcta el total de operadores y cheques - opcion general';

CREATE PROCEDURE "informix".sp_consulta_imagenes	(pBandera 				CHAR(2), 
													pClaveBanco         	CHAR(3), 
													pCuentaDeposito       	CHAR(20), 
													pNumeroCheque     		CHAR(7),
													pFechaPresenta 			DATE,
													pRegistros 				INTEGER,
													pRecuperacion 			INTEGER,
													pNumEjecut				INTEGER,
													pUsuario				CHAR(8),
													pIdFuncion 				CHAR(10), 
													pTipoOperacion 			CHAR(1), 
													pTipoSubOperacion 		CHAR(1), 
													pNumeroCuenta 			CHAR(20), 	
													pNumeroCliente 			CHAR(20),  
													pMonto 					DECIMAL(16,2), 
													pSucursal 				CHAR(4), 
													pMotivo 				CHAR(2), 
													pEjecutivoReviso 		CHAR(8), 
													pFechaRevision 			DATE, 
													pTiempoIniRev 			CHAR(10), 
													pTiempoFinRev 			CHAR(10), 
													pDevuelto 				CHAR(1), 
													pRevisado 				CHAR(1), 
													pMacAdress 				CHAR(18), 
													pDireccionIp 			CHAR(16)) 
													
													
				
	
RETURNING CHAR(5)   	AS cCodRet,
          CHAR(3)   	AS CveBanco,
          CHAR(150)  	AS Descripcion,
          CHAR(20)  	AS Cuenta,
          CHAR(7)   	AS NumCheque,
          DATE      	AS FechaALta,
          DATE      	AS FechaPresenta,
          CHAR(8)   	AS Usuario,
          CHAR(4)   	AS Producto,
          CHAR(20)  	AS Cliente,
          CHAR(104) 	AS NombreCliente,
          CHAR(40)  	AS NombreProducto,
          CHAR(20)  	AS CuentaDep,
		  CHAR(1)   	AS Revisado,
		  CHAR(8)   	AS EjecutivoReviso,
	      DECIMAL(16,2) AS Monto,
       	  CHAR(4) 		AS Sucursal,
		  INTEGER 		AS totalRegistrosRevisados,
		  INTEGER 		AS totalRegistros,
		  INTEGER		AS Ejecutivo,
          CHAR(100)		AS NombreEjecut,
          CHAR(2)    	AS Codigo,
          CHAR(35)   	AS B_Descripcion,
          CHAR(30) 		AS razonSocial,
          CHAR(45) 		AS nombreUsuario,                 
		  DATE			AS fechaHoy,
		  CHAR(100)		AS numeroBanco,		
		  VARCHAR(100) 	AS ip,  
		  VARCHAR(100)	AS puerto,
		  CHAR(3) 		AS imgFormato,
		  CHAR(9)   	AS revisadoStado,
		  INTEGER   	AS total_revisados,
		  CHAR(1)  		AS tipoBanco,
		  INTEGER  		AS clavesSIF, 
		  CHAR(20) 		AS nombreCorto,
		  CHAR(1)  		AS flagDomiR,
		  CHAR(1)  		AS flagDomiP;

-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
DEFINE cCodRet          CHAR(5);
DEFINE iSql_Err         INTEGER;
DEFINE cCveBanco        CHAR(3);  
DEFINE cDescripcion     CHAR(150);
DEFINE iCuenta		    INT8;
DEFINE iNumCheque       INT8;
DEFINE dFechaAlta		DATE;
DEFINE dFechaPresenta   DATE;
DEFINE cUsuarioAlta		CHAR(8);
DEFINE cProducto        CHAR(4);
DEFINE cCliente         CHAR(20);
DEFINE cNombreCte       CHAR(104);
DEFINE cNomProducto     CHAR(40);
DEFINE cCuentaDep       CHAR(20);  
DEFINE dMonto           DECIMAL(18,2);
DEFINE cRevisado        CHAR(1);  
DEFINE cEjecutivoReviso CHAR(8);  
DEFINE dMontoRet		DECIMAL(16,2);
DEFINE cSucursal		CHAR(4);
DEFINE pEmpresa			CHAR(3);
DEFINE iTotalRegistrosRevisados INTEGER;
DEFINE iTotalRegistros	INTEGER;
DEFINE iEjecutivo     	INTEGER;
DEFINE vNombreEjecut	VARCHAR(100);
DEFINE cCodigo			CHAR(2);
DEFINE cDescripcionb		CHAR(35);
DEFINE cIPInteract	 VARCHAR(100);
DEFINE cPuerto		 VARCHAR(100);
DEFINE cBanco		 CHAR(100);
DEFINE cFecha_hoy	 DATE;
DEFINE cNombre		 CHAR(45);
DEFINE cRazonSocial	 CHAR(30);
DEFINE cImgFormato CHAR(3);
DEFINE cRevisadoStado	CHAR(9);
DEFINE iTotalRegistrosRevisados2 INTEGER;
DEFINE cTipoBanco	CHAR(1);
DEFINE iClavesSIF	INTEGER;
DEFINE cNombreCorto	CHAR(20);
DEFINE cFflagDomiR	CHAR(1);
DEFINE cFlagDomiP	CHAR(1);

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
LET cCodRet         = '00000';
LET iSql_Err        = 0;
LET cCveBanco       = '';
LET cDescripcion    = '';
LET iCuenta         = 0; 
LET iNumCheque      = 0;
LET dFechaAlta      = '';
LET dFechaPresenta  = '';
LET cUsuarioAlta    = '';
LET cProducto       = '';
LET cCliente        = '';
LET cNombreCte      = '';
LET cNomProducto    = '';
LET cCuentaDep      = '';
LET dMonto          = 0.00;
LET cRevisado       = '';  
LET cEjecutivoReviso = '';  
LET dMontoRet 		= 0.00;
LET cSucursal		= '';
LET pEmpresa		= '001';
LET iTotalRegistrosRevisados = 0;
LET iTotalRegistros	= 0;
LET iEjecutivo     	= 0;
LET vNombreEjecut 	= '';
LET cCodigo			= '';
LET cDescripcionb	= '';
LET cIPInteract	 	= '';
LET cPuerto		 	= '';
LET cBanco		 	= '';
LET cFecha_hoy	 	= '';
LET cNombre			= '';
LET cRazonSocial	= '';
LET cImgFormato 	= '';
LET cRevisadoStado	= '';
LET iTotalRegistrosRevisados2 = 0;
LET cTipoBanco		= '';
LET iClavesSIF		= 0;
LET cNombreCorto	= '';
LET cFflagDomiR		= '';
LET cFlagDomiP		= '';

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSql_Err  
			LET cCodRet = iSql_Err  ;
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP ;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consulta_imagenes.out';
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		
		ELIF pBandera = '3' THEN
			IF pNumEjecut = '' THEN
				LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '5' THEN
			IF pUsuario = '' THEN
				LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '6' THEN

			IF pUsuario = '' OR pIdFuncion = '' OR NVL(pTipoOperacion,'0') NOT IN ('1','2','3')  THEN
				LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '7' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pClaveBanco = '' OR pCuentaDeposito = '' OR
				pNumeroCheque = ''  THEN
				LET cCodRet = '00003';
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '8' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '9' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;
		ELIF pBandera = '10' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			 END IF;	
		END IF;
		IF pBandera = '1' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_obtienecheques(pUsuario, pIdFuncion, pClaveBanco, pCuentaDeposito, pNumeroCheque, pFechaPresenta, pMacAdress, pDireccionIp, pRegistros, pRecuperacion)
				INTO cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
				cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep,
				cRevisado, cEjecutivoReviso, dMontoRet,cSucursal, cRevisadoStado, iTotalRegistrosRevisados 

				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
				cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
				iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
				cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP WITH RESUME;
			END FOREACH;
		ELIF pBandera = '2' THEN
				EXECUTE PROCEDURE "informix".sp_ope_obtienecheques_totales(pUsuario, pIdFuncion, pClaveBanco, pCuentaDeposito, pNumeroCheque, pFechaPresenta, pMacAdress, pDireccionIp)
				INTO cCodRet, iTotalRegistrosRevisados, iTotalRegistros;

				
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			   
		ELIF pBandera = '3' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_cce_consultausuariosaut(pNumEjecut)
			INTO cCodRet, iEjecutivo, vNombreEjecut
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP WITH RESUME;
			END FOREACH
		ELIF pBandera = '4' THEN
			FOREACH
			EXECUTE PROCEDURE "informix".sp_consultadevcam()
			INTO cCodRet, cCodigo, cDescripcion
			RETURN cCodRet, cCveBanco, TRIM(cDescripcion), iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP WITH RESUME;
			END FOREACH
		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE "informix".sp_obtenerparametroscce(pEmpresa ,pUsuario )
			INTO cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto;     
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE "informix".sp_ope_chequesrevisados(pUsuario, pIdFuncion, pTipoOperacion, pTipoSubOperacion, pClaveBanco,
					pNumeroCuenta, pNumeroCheque, pFechaPresenta, pNumeroCliente, pCuentaDeposito, pMonto, pSucursal, pMotivo, pEjecutivoReviso, pFechaRevision, 
					pTiempoIniRev, pTiempoFinRev, pDevuelto, pRevisado)
			INTO cCodRet;
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, 
			   iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		ELIF pBandera = '7' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_validaimagencheque(pUsuario, pIdFuncion, pClaveBanco, pCuentaDeposito, pNumeroCheque)
			INTO cCodRet, cImgFormato;
			
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcion), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		ELIF pBandera = '8' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_validapermisosusuario(pUsuario, pIdFuncion)
			INTO cCodRet;
			
			RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcion), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		ELIF pBandera = '9' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_catalogobanco(pUsuario, pIdFuncion,pClaveBanco)
				INTO cCodRet, cCveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP
			
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, 
			   cNombreCorto, cFflagDomiR, cFlagDomiP WITH RESUME;
			
			END FOREACH;
		ELIF pBandera = '10' THEN
			FOREACH
				EXECUTE PROCEDURE 'informix'.sp_validastatusproceso(pUsuario, pIdFuncion, pMacAdress, pDireccionIp)
				INTO cCodRet, cRevisado, cCliente
			
				RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcionb), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, cTipoBanco, iClavesSIF, 
			   cNombreCorto, cFflagDomiR, cFlagDomiP WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet= '00017';
		RETURN cCodRet, cCveBanco, cDescripcion, iCuenta, iNumCheque, dFechaAlta, dFechaPresenta, 
               cUsuarioAlta, cProducto, cCliente, cNombreCte,  cNomProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMontoRet, cSucursal,
			   iTotalRegistrosRevisados, iTotalRegistros, iEjecutivo, TRIM(vNombreEjecut), cCodigo, TRIM(cDescripcion), cRazonSocial, 
			   cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto, cImgFormato, cRevisadoStado, iTotalRegistrosRevisados2, 
			   cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
	
		END IF;
		
	END;
END PROCEDURE
DOCUMENT 
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de consulta de imagenes",
"FECHA : 03-03-2023";

CREATE PROCEDURE "informix".sp_actualizastatusmonitorproceso(pUsuario CHAR(8), pIdFuncion CHAR(10), pOpcion CHAR(1), pEstatusProceso CHAR(1), pCodError CHAR(5), pMac CHAR(18), pIp VARCHAR(16))
	RETURNING CHAR(5) AS codret;
        
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
				LET cCodRet = iSqlErr;
				RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_actualizastatusmonitorproceso.out';
		--TRACE ON;
		
		IF pOpcion = '1' THEN --- Inserta proceso
		
			SET LOCK MODE TO WAIT 3; 
			INSERT INTO bdicnweb:"informix".sw_monitoreostatusproceso(id_funcion,usuario,status,codigo_error,mac_adress,ip)
			VALUES(pIdFuncion, pUsuario, 'I', '', pMac, pIp); 
		
			RETURN cCodRet;
		
		ELIF pOpcion = '2' THEN --- Actualiza proceso
		
			IF pEstatusProceso = 'E' THEN 
			
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_monitoreostatusproceso
				SET status = 'E', codigo_error = TRIM(pCodError)
				WHERE id_funcion = TRIM(pIdFuncion)
				AND usuario = TRIM(pUsuario)
				AND mac_adress = TRIM(pMac)
				AND ip = TRIM(pIp);
				
				RETURN cCodRet;
					
			ELIF pEstatusProceso = 'T' THEN 
			
				SET LOCK MODE TO WAIT 3;
				UPDATE bdicnweb:"informix".sw_monitoreostatusproceso
				SET status = 'T', codigo_error = TRIM(pCodError)
				WHERE id_funcion = TRIM(pIdFuncion)
				AND usuario = TRIM(pUsuario)
				AND mac_adress = TRIM(pMac)
				AND ip = TRIM(pIp);
				
				RETURN cCodRet;
				
			END IF;
	
		ELIF pOpcion = '3' THEN -- Elimina proceso
	
			SET LOCK MODE TO WAIT 3;
			DELETE FROM bdicnweb:"informix".sw_monitoreostatusproceso
			WHERE id_funcion = TRIM(pIdFuncion)
			AND usuario = TRIM(pUsuario)
			AND mac_adress = TRIM(pMac)
			AND ip = TRIM(pIp);
			
			RETURN cCodRet;
		
		END IF;
	
	END;
        
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: RevisiÃ³n ImÃ¡genes Cheques',
'DESCRIPCION: SP que realiza la insercion, modificacion y eliminacion de estatus de proceso en ejecucion.',
'pOpcion = 1 Inserta proceso, pOpcion = 2 Modifica proceso, pOpcion = 3 Elimina proceso',
'pEstatusProceso = I Actualizacion de proceso iniciado, pEstatusProceso = E Actualizacion de proceso con error, pEstatusProceso = T Actualizacion de proceso terminado',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cce_consultausuariosaut(pNumEjecut INTEGER)
RETURNING CHAR(5)	AS CodigoRetorno,
          INTEGER	AS Ejecutivo,
          CHAR(100)	AS NombreEjecut;

	DEFINE cCodRet        	CHAR(5);
	DEFINE iSql_Err       	INTEGER;
	DEFINE iSam_Err       	INTEGER;
	DEFINE cDesc_Err      	CHAR(60);
	DEFINE iEjecutivo     	INTEGER;
	DEFINE vNombreEjecut	VARCHAR(100);

	LET cCodRet         = "00000";
	LET iSql_Err        = 0;
	LET iSam_Err        = 0;
	LET cDesc_Err      	= "";
	LET iEjecutivo		= 0;
	LET vNombreEjecut   = "";

	--SET DEBUG FILE TO "/respaldosbd/IrmaUreta/sp_cce_controlusuariosaut.out";
	--TRACE ON;

	--SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';

BEGIN

    ON EXCEPTION SET iSql_Err, iSam_Err, cDesc_Err
        IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
            LET cCodRet = iSql_Err;
            RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut);
        END IF;
    END EXCEPTION;

	SET ISOLATION DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Consulta los ejecutivos que se encuentran en la tabla cce_usuarios_revisiÃ³n.
	FOREACH
		SELECT {+AVOID_FULL(bditef:"informix".cce_usuarios_revision)} 
		ejecutivo, nombre INTO iEjecutivo, vNombreEjecut
		FROM bditef:"informix".cce_usuarios_revision
		WHERE ejecutivo = DECODE(pNumEjecut,0,ejecutivo,pNumEjecut)

		RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut) WITH RESUME;
	END FOREACH;

    -- Se verifica si la consulta no encontro informacion.
    IF DBINFO("sqlca.sqlerrd2") = 0 THEN
        LET cCodRet = "00001";
		RETURN cCodRet, iEjecutivo, TRIM(vNombreEjecut);
    END IF;

END;
END PROCEDURE
DOCUMENT
"AUTOR: Irma Ureta",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_consultadevcam()
RETURNING CHAR(5)    AS CodigoRetorno,
          CHAR(2)    AS Codigo,
          CHAR(35)   AS Descripcion;
	
    DEFINE cCodRet		CHAR(5);
	DEFINE iSql_Err		INTEGER;
	DEFINE iSam_Err		INTEGER;
	DEFINE cDesc_Err	CHAR(60);
    DEFINE cCodigo		CHAR(2);
    DEFINE cDescripcion	CHAR(35);
	
    LET cCodRet			= "00000";
	LET iSql_Err		= 0;
	LET iSam_Err		= 0;
	LET cDesc_Err		= "";
    LET cCodigo			= "";
    LET cDescripcion	= "";
	
	--SET DEBUG FILE TO "/respaldosbd/IrmaUreta/sp_consultadevcam.out";
	--TRACE ON;
		
	--SET ENVIRONMENT IFX_BATCHEDREAD_INDEX '1';
 
BEGIN
	ON EXCEPTION SET iSql_Err, iSam_Err, cDesc_Err
		IF iSql_Err <> 0 OR iSam_Err <> 0 THEN
				LET cCodRet = iSql_Err;
				RETURN cCodRet, cCodigo, TRIM(cDescripcion);
		END IF;
	END EXCEPTION;
	
	SET ISOLATION DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- 
 
	FOREACH
		SELECT codigo, descripcion INTO cCodigo, cDescripcion
		FROM bdinteg: "informix".si_coddevcam ORDER By codigo ASC
		
		RETURN cCodRet, cCodigo, TRIM(cDescripcion) WITH RESUME;
	END FOREACH;
	
	-- Se verifica si la consulta regreso informacion.
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = "00001";
		RETURN cCodRet, cCodigo, TRIM(cDescripcion);
	END IF;
END;
END PROCEDURE
DOCUMENT
"AUTOR: Irma Ureta",
"FECHA CREACION: 24 de Diciembre del 2014",
"DESCRIPCION: Consulta cÃ³digo y descripciÃ³n de devoluciÃ³n.",
"VERSION: 20141221.0317",
"BD: BDINTEG",
"AUTOR: Carolina Verdugo",
"FECHA MODIFICACION : 22/09/2015",
"DESCRIPCION: Se realiza cambiÃ³ en la consulta para que sea ordenada por el campo cÃ³digo.",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_obtenerparametroscce(pEmpresa CHAR(3),pUsuario CHAR(8))
            RETURNING 
			CHAR(5),		-- CODIGO RETORNO
            CHAR(30),       -- RAZON SOCIAL
            CHAR(45),       -- NOMBRE USUARIO                
			DATE,			-- FECHA HOY
			CHAR(100),		-- NUMERO BANCO
			VARCHAR(100),   -- IP INTERACT
			VARCHAR(100);   -- PUERTO
			
DEFINE iSqlErr       INT;
DEFINE cCodret       CHAR(5);  
DEFINE cDescripcion  CHAR(40);
DEFINE cIPInteract	 VARCHAR(100);
DEFINE cPuerto		 VARCHAR(100);
DEFINE cBanco		 CHAR(100);
DEFINE cFecha_hoy	 DATE;
DEFINE cNombre		 CHAR(45);
DEFINE cRazonSocial	 CHAR(30);

LET cCodret			= '00000';  
LET cDescripcion    ='';
LET cIPInteract	    ='';
LET cPuerto		    ='';
LET cBanco		    ='';
LET cFecha_hoy	    ='';
LET cNombre		    ='';
LET cRazonSocial	='';
LET iSqlErr         = 0;

BEGIN
   ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
            RETURN cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;     
        END IF;
   END EXCEPTION;
   
    --SET DEBUG FILE TO "/tmp/mfinis/sp_obtenerparametroscce.out";
    --TRACE ON;
    
    SET ISOLATION DIRTY READ ;
    SET LOCK MODE TO WAIT 3;   

	--EMPRESA
	SELECT razon_social 
	INTO cRazonSocial
	FROM bdinteg:si_empresas 	
	WHERE empresa= pEmpresa;

	--USUARIO
	SELECT nombre 
	INTO cNombre 
	FROM bdinteg:si_ejecut 	
	WHERE ejecutivo = pUsuario;

	--FECHA HOY
	SELECT fecha_hoy 
	INTO cFecha_hoy
	FROM bdinteg:si_fechas 	
	WHERE empresa = pEmpresa;

	--NUMERO BANCO PROPIO
	SELECT valor 
	INTO cBanco 
	FROM bdinteg:si_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='5';

	--CARGA INTERACT IP
	SELECT valor 
	INTO cIPInteract
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='3';

	--CARGA INTERACT PORT
	SELECT valor 
	INTO cPuerto
	FROM bditef:cce_param 	
	WHERE empresa = pEmpresa 
	AND cod_param='4';

	IF cPuerto = '' OR cPuerto IS NULL OR cIPInteract= '' OR cIPInteract IS NULL THEN
		LET cCodret= '10000';     
	END IF;
		
	RETURN  cCodRet,cRazonSocial, cNombre,cFecha_hoy,cBanco, cIPInteract, cPuerto ;

	    
END;    
END PROCEDURE
DOCUMENT
'AUTOR:ABIGAIL VASAVILBAZO CAÃEDO',
'DESCRIPCION:  PROCEDIMIENTO QUE OBTIENE LOS PARAMETROS PARA SISTEMA TEF ',
'FECHA : MARZO 2010',
'BD    : BDITEF',
'VERSION: 20100304.0943';

CREATE PROCEDURE "informix".sp_ope_catalogobanco(pUsuario CHAR(8), pIdFuncion CHAR(10), pBanco CHAR(3))
		RETURNING CHAR(5)  AS codret,
				  CHAR(3)  AS claveBanco,
				  CHAR(40) AS descripcion,
				  CHAR(1)  AS tipoBanco,
				  INTEGER  AS clavesSIF, 
				  CHAR(20) AS nombreCorto,
				  CHAR(1)  AS flagDomiR,
				  CHAR(1)  AS flagDomiP;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE cClaveBanco	CHAR(3);
	DEFINE cDescripcion	CHAR(40);
	DEFINE cTipoBanco	CHAR(1);
	DEFINE iClavesSIF	INTEGER;
	DEFINE cNombreCorto	CHAR(20);
	DEFINE cFflagDomiR	CHAR(1);
	DEFINE cFlagDomiP	CHAR(1);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iRecuperacion 	= 0;
	LET cClaveBanco		= '';
	LET cDescripcion	= '';
	LET cTipoBanco		= '';
	LET iClavesSIF		= 0;
	LET cNombreCorto	= '';
	LET cFflagDomiR		= '';
	LET cFlagDomiP		= '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_catalogobanco.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdinteg:'informix'.sp_obtienebancos(pBanco)
			INTO cCodRetSp, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtienebancos2';
			ELIF iCodRetSp = 2 THEN
				LET cCodRet = '00518'; --LA CLAVE DEL BANCO NO EXISTE
				RETURN cCodRet, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
			ELSE
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet, cClaveBanco, UPPER(cDescripcion), cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP  WITH RESUME;
			END IF;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cClaveBanco, cDescripcion, cTipoBanco, iClavesSIF, cNombreCorto, cFflagDomiR, cFlagDomiP;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: sp que realiza la consulta del catalogo de bancos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_chequesrevisados(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoOperacion CHAR(1), pTipoSubOperacion CHAR(1), pClaveBanco CHAR(3),
					pNumeroCuenta CHAR(20), pNumeroCheque CHAR(7), pFechaPresenta DATE, pNumeroCliente CHAR(20), pCuentaDeposito CHAR(20), 
					pMonto DECIMAL(16,2), pSucursal CHAR(4), pMotivo CHAR(2), pEjecutivoReviso CHAR(8), pFechaRevision DATE, 
					pTiempoIniRev DATETIME HOUR TO SECOND, pTiempoFinRev DATETIME HOUR TO SECOND, pDevuelto CHAR(1), pRevisado CHAR(1)) 
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_chequesrevisados.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR NVL(pTipoOperacion,'0') NOT IN ('1','2','3') THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		EXECUTE PROCEDURE bditef:"informix".sp_cce_chequesrevisados(pTipoOperacion, pTipoSubOperacion, cEmpresa, pClaveBanco, pNumeroCuenta, pNumeroCheque, pFechaPresenta, 
		pNumeroCliente, pCuentaDeposito, pMonto, pSucursal, pMotivo, pEjecutivoReviso, pFechaRevision, pTiempoIniRev, pTiempoFinRev, pDevuelto, pRevisado)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_cce_chequesrevisados';
		ELIF iCodRetSp = 3 THEN
			LET cCodRet = '00003';		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00724';		END IF;
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 22/02/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL el cual marca el cheque como revisado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_obtienecheques(pUsuario CHAR(8), pIdFuncion CHAR(10), pBanco CHAR(3),  pCuenta CHAR(20), pNumCheque CHAR(7), pFechaPresenta DATE, pMac CHAR(18), pIp VARCHAR(16), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				CHAR(3)   AS cveBanco,
				CHAR(40)  AS descripcion,
				CHAR(20)  AS cuenta,
				CHAR(7)   AS numCheque,
				DATE      AS fechaALta,
				DATE      AS fechaPresenta,
				CHAR(8)   AS usuario,
				CHAR(4)   AS producto,
				CHAR(20)  AS cliente,
				CHAR(104) AS nombreCliente,
				CHAR(40)  AS nombreProducto,
				CHAR(20)  AS cuentaDep,
				CHAR(1)   AS revisado,
				CHAR(8)   AS ejecutivoReviso,
				DECIMAL(16,2) AS monto,
				CHAR(4)   AS sucursal,
				CHAR(9)   AS revisadoStado,
				INTEGER   AS total_revisados;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cClaveBanco		CHAR(3);
	DEFINE cDescripcion		CHAR(40);
	DEFINE cCuenta			CHAR(20);
	DEFINE cNumCheque		CHAR(7);
	DEFINE dFechaALta		DATE;
	DEFINE dFechaPresenta	DATE;
	DEFINE cUsuario			CHAR(8);
	DEFINE cProducto		CHAR(4);
	DEFINE cCliente			CHAR(20);
	DEFINE cNombreCliente	CHAR(104);
	DEFINE cNombreProducto	CHAR(40);
	DEFINE cCuentaDep		CHAR(20);
	DEFINE cRevisado		CHAR(1);
	DEFINE cEjecutivoReviso	CHAR(8);
	DEFINE dMonto			DECIMAL(16,2);
	DEFINE cSucursal		CHAR(4);
	DEFINE cRevisadoStado	CHAR(9);
	DEFINE iRecuperacion	INTEGER;
	DEFINE iTotalRegistrosRevisados INTEGER;
	DEFINE iHayDatos INTEGER;
	DEFINE iIdConsecutivo INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cClaveBanco			= '';
	LET cDescripcion		= '';
	LET cCuenta				= '';
	LET cNumCheque			= '';
	LET dFechaALta			= '';
	LET dFechaPresenta		= '';
	LET cUsuario			= '';
	LET cProducto			= '';
	LET cCliente			= '';
	LET cNombreCliente		= '';
	LET cNombreProducto		= '';
	LET cCuentaDep			= '';
	LET cRevisado			= '';
	LET cEjecutivoReviso	= '';	
	LET dMonto				= 0;	
	LET cSucursal			= '';
	LET cRevisadoStado		= '';
	LET iRecuperacion 		= 0;
	LET iTotalRegistrosRevisados = 0;
	LET iHayDatos = 0;
	LET iIdConsecutivo = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'E', cCodRet, pMac, pIp) INTO cCodRetSp;
			RETURN cCodRet, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
			cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, cRevisadoStado, iTotalRegistrosRevisados;
		END EXCEPTION;
		
		--ON EXCEPTION IN (-958)
		--END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienecheques.out';
		--TRACE ON;
		
		--Se limpia tabla por usuario
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '3', '', '', pMac, pIp) INTO cCodRetSp;
		
		--Se inserta proceso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '1', '', '', pMac, pIp) INTO cCodRetSp;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienecheques.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMac = '' OR pIp = '' THEN
			LET cCodRet = '00003';
			
			--Actualiza proceso errï¿½neo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'E', cCodRet, pMac, pIp) INTO cCodRetSp;
		
			RETURN cCodRet, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
			cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, cRevisadoStado, iTotalRegistrosRevisados;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
		
			--Actualiza proceso errï¿½neo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'E', cCodRet, pMac, pIp) INTO cCodRetSp;
		
			RETURN cCodRet, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
			cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, cRevisadoStado, iTotalRegistrosRevisados;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
			
		IF pRegistros = 0 THEN
			DROP TABLE IF EXISTS "informix".sw_cp_obtienecheques;
			IF EXISTS (SELECT tabname FROM systables WHERE tabname = 'sw_cp_obtienecheques') THEN
				DROP TABLE IF EXISTS "informix".sw_cp_obtienecheques;
			END IF;
			
			-- CREACION DE TABLA TEMPORAL
			CREATE TABLE "informix".sw_cp_obtienecheques(
				id_consecutivo INTEGER PRIMARY KEY,
				us_insert_tmp CHAR(20),
				fecha_presenta DATE, 
				clavebanco_tmp CHAR(3),
				descripcion_tmp CHAR(40),
				cuenta_tmp CHAR(20),
				numcheque_tmp CHAR(7),
				fechaalta_tmp DATE,
				fechapresenta_tmp DATE, 
				usuario_tmp CHAR(8),
				producto_tmp CHAR(4),
				cliente_tmp CHAR(20),
				nombrecliente_tmp CHAR(104),
				nombreproducto_tmp CHAR(40),
				cuentadep_tmp CHAR(20), 
				revisado_tmp CHAR(1), 
				ejecutivoreviso_tmp CHAR(8),
				monto_tmp DECIMAL (16,2),
				sucursal_tmp CHAR(4),
				totalrevisados_tmp INTEGER);
			--DELETE FROM bdicnweb:"informix".sw_cp_obtienecheques WHERE us_insert_tmp = pUsuario;
			
			FOREACH
				EXECUTE PROCEDURE bditef:"informix".sp_obtienecheques2(cEmpresa, pBanco, pCuenta, pNumCheque, pFechaPresenta, pRegistros, pRecuperacion)
				INTO cCodRetSp, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
				cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal
			
				LET iCodRetSp = cCodRetSp::INTEGER;
				IF iCodRetSp < 0 THEN
					RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtienecheques2';
				ELIF iCodRetSp > 0 THEN

					IF iCodRetSp = 1 THEN
						LET cCodRet = '00003'; --FALTAN CAMPOS REQUERIDOS
					ELIF iCodRetSp = 2 THEN
						LET cCodRet = '00017'; --NO HAY REGISTROS
					END IF;
					
					--Actualiza proceso errï¿½neo
					EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'E', cCodRet, pMac, pIp) INTO cCodRetSp;
		
					RETURN cCodRet, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
					cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, cRevisadoStado, iTotalRegistrosRevisados;
					
				ELIF iCodRetSp = 0 THEN
					
					LET iIdConsecutivo = iIdConsecutivo + 1;
					INSERT INTO "informix".sw_cp_obtienecheques VALUES (iIdConsecutivo, pUsuario, pFechaPresenta,
					cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
					cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, iTotalRegistrosRevisados);
				END IF;
			END FOREACH;
		END IF;
		
		SELECT MAX(totalrevisados_tmp) INTO iTotalRegistrosRevisados
		FROM "informix".sw_cp_obtienecheques WHERE us_insert_tmp = pUsuario AND fecha_presenta = pFechaPresenta;
		
		FOREACH
			SELECT clavebanco_tmp, descripcion_tmp, cuenta_tmp, numcheque_tmp, fechaalta_tmp, fechapresenta_tmp, 
			usuario_tmp, producto_tmp, cliente_tmp, nombrecliente_tmp, nombreproducto_tmp, cuentadep_tmp, 
			revisado_tmp, ejecutivoreviso_tmp, monto_tmp, sucursal_tmp
			INTO cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
			cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal
			FROM "informix".sw_cp_obtienecheques 
			--WHERE us_insert_tmp = pUsuario AND fecha_presenta = pFechaPresenta 
			--ORDER BY id_consecutivo ASC
		
			IF cRevisado = '0' THEN 
				LET cRevisadoStado = 'NO';
				LET cEjecutivoReviso = '';
			ELIF cRevisado = '1' THEN
				LET cRevisadoStado = 'SI';
			ELIF cRevisado = '9' THEN
				LET cRevisadoStado = 'PENDIENTE';
				LET cEjecutivoReviso = '';
			ELSE
				LET cRevisadoStado = 'NO';
				LET cEjecutivoReviso = '';
			END IF;
		
			---Actualiza proceso exitoso
			--EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'T', '', pMac, pIp) INTO cCodRetSp;
			
			LET iRecuperacion = iRecuperacion + 1;
			RETURN cCodRet, cClaveBanco, cDescripcion, cCuenta, cNumCheque, dFechaALta, dFechaPresenta, cUsuario, cProducto, cCliente, cNombreCliente, 
			cNombreProducto, cCuentaDep, cRevisado, cEjecutivoReviso, dMonto, cSucursal, cRevisadoStado, NVL(iTotalRegistrosRevisados,0) WITH RESUME;
		END FOREACH;
		
		IF iRecuperacion = 0 THEN
			LET cCodRet = '00017';
			
			--Actualiza proceso errï¿½neo
			EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'E', cCodRet, pMac, pIp) INTO cCodRetSp;
	
			RETURN cCodRet, '', '', '', '', '', '', '', '', '', '', '', '', '', '', 0, '', '', 0;
		END IF;
		
		---Actualiza proceso exitoso
		EXECUTE PROCEDURE bdicnweb:"informix".sp_actualizastatusmonitorproceso(pUsuario, pIdFuncion, '2', 'T', cCodRet, pMac, pIp) INTO cCodRetSp;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: sp el cual obtiene los cheques a revisar',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 24/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Revisiï¿½n Imï¿½genes Cheques',
'DESCRIPCION: Se modifica spl para el tratado del monitoreo de volumetria que afecta al proceso.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_obtienecheques_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pBanco CHAR(3),  pCuenta CHAR(20), pNumCheque CHAR(7), pFechaPresenta DATE, pMacAdress CHAR(18), pDireccionIp CHAR(16))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistrosRevisados,
		          INTEGER AS totalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegistrosRevisados INTEGER;
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iTotalRegistrosRevisados = 0;
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_obtienecheques_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMacAdress = '' OR pDireccionIp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		END IF;
		
		EXECUTE PROCEDURE bditef:"informix".sp_obtienecheques2_totales(cEmpresa, pBanco, pCuenta, pNumCheque, pFechaPresenta)
		INTO cCodRetSp, iTotalRegistros, iTotalRegistrosRevisados;
	
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_obtienecheques2_totales';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003'; --FALTAN CAMPOS REQUERIDOS
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00017'; --NO HAY REGISTROS
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		ELSE
			RETURN cCodRet, iTotalRegistros, iTotalRegistrosRevisados;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: sp el cual obtiene el total de los cheques a revisar',
'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 24/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Revisiï¿½n Imï¿½genes Cheques',
'DESCRIPCION: Se agregan parametros de entrada para la validaciï¿½n de requeridos en el monitoreo de volumetria.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validapermisosusuario(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validapermisosusuario.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		IF EXISTS(SELECT ejecutivo FROM bditef:cce_usuarios_revision WHERE ejecutivo = pUsuario)THEN 
			LET cCodRet = "00000";
		ELSE
			LET cCodRet = "00017";
		END IF
		RETURN cCodRet;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 17/02/2016',
'DESCRIPCION: Spl que consulta si el cliente tiene permisos o no',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validastatusproceso(pUsuario CHAR(8), pIdFuncion CHAR(10), pMacAdress CHAR(18), pDireccionIp CHAR(16))
		RETURNING CHAR(5) AS codret,
			CHAR(1) AS status, 
			CHAR(5) AS codigo_error_sp;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(5);
	DEFINE iNoRegistros INTEGER;

	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cEmpresa = '001';
	LET cStatus = '';
	LET cErrorProceso = '';
	LET iNoRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_validastatusproceso.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pMacAdress = '' OR pDireccionIp = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cStatus, cErrorProceso;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH
		
			SELECT status, codigo_error
			INTO cStatus, cErrorProceso
			FROM bdicnweb:"informix".sw_monitoreostatusproceso
			WHERE usuario = TRIM(pUsuario) AND id_funcion = pIdFuncion 
			AND mac_adress = pMacAdress AND ip = pDireccionIp
			
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, cStatus, NVL(cErrorProceso,'') WITH RESUME;
			
		END FOREACH;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017'; 
			RETURN cCodRet, cStatus, cErrorProceso;
		END IF;
		
	END;	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat Leï¿½n Amador',
'FECHA: 24/08/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Revisiï¿½n Imï¿½genes Cheques',
'DESCRIPCION: SPL que realiza la validaciï¿½n del status de los procesos.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_actualizacion_cheques_presentar(	pBandera			CHAR(2),
																pRegistros 			INTEGER, 
																pRecuperacion 		INTEGER,
																pUsuario 			CHAR(8), 
																pIdFuncion 			CHAR(10), 
																pFechaPresentacion  CHAR(10),
																pCtaDelCheque 		CHAR(20),
																pNumCheque 			CHAR(7),
																pMonto 				DECIMAL(14,2))


RETURNING
	CHAR(5)         AS cod_ret,
    CHAR(80)        AS desc_ret,
	CHAR(4)         AS sucursal,
	CHAR(40)        AS desc_sucursal,
	CHAR(10)        AS fecha_presentacion,
	CHAR(20)        AS cuenta_deposito,
	CHAR(3)         AS cve_banco,
	CHAR(40)        AS desc_banco,
	CHAR(20)        AS cuenta_cheque,
	INTEGER        	AS numero_cheque,
	MONEY(14,2)     AS importe,
	CHAR(10)		AS fecha_hoy,
	INTEGER			AS no_registros,
	DATE 			AS dia_feriado, 
	CHAR(30) 		AS desc_dia_feriado,
	CHAR(1) 		AS laborable;
		

 	DEFINE iSqlErr          INTEGER;
    DEFINE cDescRet         CHAR(80);
    DEFINE cCodRet          CHAR(5);
	DEFINE pEmpresa			CHAR(3);
	DEFINE cSucursal		CHAR(4);
	DEFINE cDescSucursal	CHAR(40);
	DEFINE cFechaPres		CHAR(10);
	DEFINE cCtaDeposito		CHAR(20);
	DEFINE cBanco           CHAR(3);
	DEFINE cDescBanco       CHAR(40);
	DEFINE cCtaDelCheque    CHAR(20);
	DEFINE iNumCheque    	INTEGER;
	DEFINE mImporte         MONEY(14,2);
	DEFINE cFechaHoy		CHAR(10);
	DEFINE cDescDiaFeriado 	CHAR(30);
	DEFINE cLaborable 		CHAR(1);
	DEFINE iNoRegistros 	INTEGER;
	DEFINE dDiaFeriado		CHAR(30);
	DEFINE icontador 		INTEGER;
	
	---INICIALIZACIONES
	LET iSqlErr				= 0;
	LET pEmpresa			= '001';
    LET cDescRet		    = "PROCESO EXITOSO";
	LET cCodRet				= "00000";
	
	LET cSucursal			= "";
	LET cDescSucursal		= "";
	LET cFechaPres			= "";
	LET cCtaDeposito		= "";
	LET cBanco				= "";
	LET cDescBanco			= "";
	LET cCtaDelCheque		= "";
	LET iNumCheque    		= 0;
    LET mImporte		    = 0.0;
	LET cFechaHoy			= "";
	LET iNoRegistros		= 0;
	LET dDiaFeriado 		= '';
	LET cDescDiaFeriado 	= '';
	LET cLaborable 			= '';
	LET icontador 			= 0;
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END EXCEPTION;

		--SET DEBUG FILE TO '/tmp/mfinis/Antonio/Contabilidad/sp_actualizacion_cheques_presentar.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		IF pBandera = '' THEN
			LET cCodRet = '00003';
			LET cDescRet = 'BANDERA SE ENCUENTRA VACIA';
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;

		ELIF pBandera = '3' THEN
				IF pUsuario = '' OR pIdFuncion = '' OR pFechaPresentacion = '' OR pCtaDelCheque = ''  THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		ELIF pBandera = '4' THEN
				IF pUsuario = '' OR pIdFuncion = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		ELIF pBandera = '5' or pBandera = '6' THEN
				IF pUsuario = '' OR pIdFuncion = '' THEN
					LET cCodRet = '00003';
					RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
						dDiaFeriado, cDescDiaFeriado, cLaborable;
				END IF;
		END IF;
		
		IF pBandera = '1' THEN
			FOREACH
				EXECUTE PROCEDURE bdicheq:"informix".sp_cce_consultarchqsxpresentar2(pEmpresa, pRegistros, pRecuperacion)
				INTO cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy

				LET icontador = icontador + 1;

				RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable WITH RESUME;
			END FOREACH;

		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE bdicheq:"informix".sp_cce_consultarchqsxpresentar2_totales(pEmpresa)
			INTO cCodRet,iNoRegistros;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '3' THEN
			EXECUTE PROCEDURE "informix".sp_ope_actualizarfechacheques(pUsuario, pIdFuncion, pFechaPresentacion,pCtaDelCheque,pNumCheque,pMonto)
			INTO cCodRet;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '4' THEN
			FOREACH
				EXECUTE PROCEDURE "informix".sp_ope_consultacheqsxpresentar(pUsuario, pIdFuncion, pRegistros, pRecuperacion)
				INTO cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy

				LET icontador = icontador + 1;

				RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable with resume;
			END FOREACH
		ELIF pBandera = '5' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_consultacheqsxpresentar_totales(pUsuario, pIdFuncion)
			INTO cCodRet, iNoRegistros;
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		ELIF pBandera = '6' THEN
			EXECUTE PROCEDURE 'informix'.sp_ope_validadiaferiado(pUsuario, pIdFuncion)
			INTO cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;	
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0  THEN
			LET cCodRet= '00017';
			RETURN cCodRet,cDescRet,cSucursal,cDescSucursal,cFechaPres,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque,mImporte,cFechaHoy,iNoRegistros,
					dDiaFeriado, cDescDiaFeriado, cLaborable;
		END IF;
	END;

END PROCEDURE
DOCUMENT 'AUTOR: Eduardo Avila Perez Tagle',
'FECHA: 03/03/2023',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN DE CHEQUES SBC POR PRESENTAR', 
'DESCRIPCION: SPL principal de actualizacion de cheques por presentar',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_actualizarfechacheques(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaPresentacion  CHAR(10),pCtaDelCheque CHAR(20),pNumCheque CHAR(7),pMonto DECIMAL(14,2))
		RETURNING CHAR(5) AS codret;		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cDescRet   CHAR(80);
	DEFINE dtFechaHoy DATE;
	DEFINE iNumDia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cDescRet = '';
	LET dtFechaHoy = '';
	LET iNumDia = 0;
	 
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_actualizarfechacheques.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR cEmpresa = '' OR pFechaPresentacion = '' OR pCtaDelCheque = '' OR pNumCheque = '' OR  pMonto IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		SET ISOLATION TO DIRTY READ; 
		
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_fechas)} fecha_hoy
        INTO dtFechaHoy
        FROM bdicheq:'informix'.sc_fechas
        WHERE empresa = cEmpresa;
		
		IF pFechaPresentacion = dtFechaHoy THEN
			LET cCodRet = '00724';
			RETURN cCodRet;	
		END IF;
		
		SELECT {+AVOID_FULL(bdicheq:"informix".sc_fechas)} WEEKDAY(dtFechaHoy)
		INTO iNumDia
		FROM bdicheq:'informix'.sc_fechas  
		WHERE empresa = cEmpresa;
		
		IF (iNumDia = 6 OR iNumDia = 0) THEN
			LET cCodRet = '00723';
			RETURN cCodRet;	
		END IF;
		
		EXECUTE PROCEDURE bdicheq:"informix".sp_cce_actualizarfechacheques(cEmpresa,pFechaPresentacion,pCtaDelCheque,pNumCheque,pMonto)	
		INTO cCodRetSp, cDescRet;
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_actualizarfechacheques';
		ELIF iCodRetSp = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetSp = 2 THEN
			LET cCodRet = '00721';
		END IF;		
			RETURN cCodRet;	
		END ;
END PROCEDURE

DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL para la actualizacion de la fecha de presentacion del cheque para que sea tomado en cuenta por el proceso de la presentacion.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacheqsxpresentar(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
		CHAR(4)         AS sucursal,
		CHAR(40)        AS desc_sucursal,
		CHAR(10)        AS fecha_presentacion,
		CHAR(20)        AS cuenta_deposito,
		CHAR(3)         AS cve_banco,
		CHAR(40)        AS desc_banco,
		CHAR(20)        AS cuenta_cheque,
		INTEGER        	AS numero_cheque,
		MONEY(18,2)     AS importe,
		CHAR(10)		AS fecha_hoy;	
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(6);
	DEFINE iCodRetSp INTEGER;
	DEFINE cDescRet CHAR(80);
	DEFINE cEmpresa CHAR(3);
	DEFINE cSucursal CHAR(4);
	DEFINE cDescSucursal CHAR(40);
	DEFINE cFechaPres CHAR(10);
	DEFINE cCtaDeposito CHAR(20);
	DEFINE cBanco CHAR(3);
	DEFINE cDescBanco CHAR(40);
	DEFINE cCtaDelCheque CHAR(20);
	DEFINE iNumCheque INTEGER;
	DEFINE mImporte MONEY(14,2);
	DEFINE cFechaHoy CHAR(10);
	DEFINE iNoRegistros INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000000';
	LET iCodRetSp = 0;
	LET cDescRet = '';
	LET cEmpresa = '001';
	LET cSucursal = '';
	LET cDescSucursal = '';
	LET cFechaPres = '';
	LET cCtaDeposito = '';
	LET cBanco = '';
	LET cDescBanco = '';
	LET cCtaDelCheque = '';
	LET iNumCheque = 0;
    LET mImporte = 0.0;
	LET cFechaHoy = '';	
	LET iNoRegistros = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacheqsxpresentar.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		END IF;
		
		SET ISOLATION TO DIRTY READ;		
		FOREACH
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cce_consultarchqsxpresentar2(cEmpresa,pRegistros, pRecuperacion)
			INTO cCodRetSp,cDescRet,cSucursal,cDescSucursal,cFechaPres ,cCtaDeposito,cBanco,cDescBanco,cCtaDelCheque,iNumCheque ,mImporte,cFechaHoy		
		LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP bdicheq:sp_cce_consultarchqsxpresentar2';				
			ELIF iCodRetSp = 1 THEN
				LET cCodRet = '00003'; 
			END IF;
			IF  iRecuperacion = 0 AND pRegistros = 0 AND iCodRetSp = 2  THEN
				LET cCodRet = '00017';	
				RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
			ELIF  iRecuperacion = 0 AND pRegistros > 0  AND iCodRetSp = 2  THEN
				LET cCodRet = '1001';
				RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
			END IF;	
				LET iRecuperacion = iRecuperacion + 1;
				RETURN cCodRet,cSucursal, UPPER(TRIM(cDescSucursal)),cFechaPres ,cCtaDeposito ,cBanco ,UPPER(TRIM(cDescBanco)),cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy WITH RESUME;	
		END FOREACH;
		
		--IF iRecuperacion = 0 AND pRegistros = 0 THEN 
		--		LET cCodRet ='00017';
		--		RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		--	ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
		--		LET cCodRet ='1001';
		--		RETURN cCodRet,cSucursal,cDescSucursal ,cFechaPres ,cCtaDeposito ,cBanco ,cDescBanco ,cCtaDelCheque ,iNumCheque ,mImporte ,cFechaHoy;
		--	END IF;		
	END;		
END PROCEDURE
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL que consulta el detalle los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consultacheqsxpresentar_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))	
		RETURNING CHAR(5) AS codret,                           
			INTEGER AS num_registros;

	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(6);
	DEFINE cDescCodRet CHAR(100);
	DEFINE iCodRetSp INTEGER;
	DEFINE iSqlErr INTEGER;	
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET cCodRetSp = '000000';
	LET cDescCodRet = '';
	LET iCodRetSp = 0;
	LET iSqlErr = 0;
	LET iNumRegistros = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consultacheqsxpresentar_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumRegistros;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNumRegistros;
		END IF;	
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_cce_consultarchqsxpresentar2_totales('001')
		INTO cCodRetSp,iNumRegistros;
		
		IF cCodRetSp::INTEGER < 0 THEN 
			RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIï¿½N DEL SP bdicheq:sp_cce_consultarchqsxpresentar2_totales';
		END IF;
		
		IF iNumRegistros = 0 THEN
			LET cCodRet = '00017';		
		END IF;

		RETURN cCodRet, iNumRegistros;
		
	END;

END PROCEDURE 
DOCUMENT 'AUTOR: Ing. Guadalupe A. Hernandez Perez ',
'FECHA: 23/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIï¿½N DE CHEQUES',
'DESCRIPCION:SPL que consulta el total los cheques que no se encuentran presentados porque tienen fecha de presentacion anterior a la fecha de hoy del sistema.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validadiaferiado(pUsuario CHAR(8), pIdFuncion CHAR(10))
		
		RETURNING CHAR(5) AS codret,
			DATE AS dia_feriado, 
			CHAR(30) AS desc_dia_feriado,
			CHAR(1) AS laborable;
		 
		DEFINE cCodRet CHAR(5);
        DEFINE cCodRetSp CHAR(6);
		DEFINE iCodRetSp INTEGER;
        DEFINE iSqlErr INTEGER;
		DEFINE cEmpresa CHAR(3);
		DEFINE dFecha DATE;
		DEFINE dDiaFeriado DATE;
		DEFINE cDescDiaFeriado CHAR(30);
		DEFINE cLaborable CHAR(1);
		DEFINE iNoRegistros INTEGER;
		
		LET cCodRet = '00000';
        LET cCodRetSp = '';
		LET iCodRetSp = 0;
        LET iSqlErr = 0;
		LET cEmpresa = '001';
		LET dFecha = DATE(CURRENT);
		LET dDiaFeriado = '';
		LET cDescDiaFeriado = '';
		LET cLaborable = '';
		LET iNoRegistros = 0;
	
		BEGIN
		
			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
                RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
			END EXCEPTION;
            
            --SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validadiaferiado.out';
            --TRACE ON;
            
            IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
            END IF;
            
            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
			END IF;
			
			EXECUTE PROCEDURE bdinteg:'informix'.sp_validardiaferiado(cEmpresa, dFecha)
			INTO cCodRetSp, dDiaFeriado, cDescDiaFeriado, cLaborable;
			
			IF cCodRetSp::INTEGER < 0 THEN 
				RAISE EXCEPTION cCodRetSp::INTEGER, 0, 'ERROR EN LA EJECUCIÃN DEL SP bdinteg:sp_validardiaferiado';
			ELIF cCodRetSp::INTEGER = 1 THEN
				LET cCodRet = '00003';
			ELIF cCodRetSp::INTEGER = 2 THEN
				LET cCodRet = '00723'; --EL DÃA DE HOY NO ES UN DÃA LABORABLE
			END IF;
			
			RETURN cCodRet, dDiaFeriado, cDescDiaFeriado, cLaborable;
		
		END;
	
END PROCEDURE 
DOCUMENT 'AUTOR: L. Montserrat LeÃ³n Amador',
'FECHA: 24/11/2015',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: ACTUALIZACIÃN DE CHEQUES SBC POR PRESENTAR', 
'DESCRIPCION: SPL que se encarga de validar si la fecha del dÃ­a actual pertenece a un dÃ­a feriado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitor_envio_cheques(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5) AS codret,
                CHAR(3)                                                 AS banco,
                CHAR(40)                                                AS descripcionBanco,
                CHAR(40)                                                AS cuenta,
                INTEGER                                                 AS numeroCheque,
                DECIMAL(14,2)                                  		    AS montoOrigen,
                DATE                                                    AS fechaAlta,
                DATETIME HOUR TO FRACTION(3)    						AS hora,
                CHAR(44)                                                AS sucursal,
                SMALLINT                                                AS diasRetorno,
                CHAR(16)                                                AS folioSucursal,
                CHAR(4)                                                 AS transcc,
                CHAR(4)                                                 AS claveSucursal,
                CHAR(25)                                                AS digitalizado,
                CHAR(2)                                                 AS pre,
                CHAR(2)                                                 AS estatusColor,
                INTEGER 												AS totalchequesenvio,
                INTEGER 												AS iTotalOperados,
                INTEGER 												AS iTotalDigitalizados,
                INTEGER 												AS iTotalPresentados,
                INTEGER 												AS iTotalPorPresentar,
                INTEGER 												AS iTotalPorRecibir;


        
-- ****************************************************************************
-- *                        DEFINICION DE VARIABLES                           *
-- ****************************************************************************
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE cTieneMovto CHAR(1);
		DEFINE iTotalOperados      INTEGER;
        DEFINE iTotalDigitalizados INTEGER;
        DEFINE iTotalPresentados   INTEGER;
        DEFINE iTotalPorPresentar  INTEGER;
        DEFINE iTotalPorRecibir    INTEGER;
        DEFINE iTotalRegistros INTEGER;

-- ****************************************************************************
-- *                        ASIGNACION DE VARIABLES                           *
-- ****************************************************************************
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;        
        LET iCuenta = 0;        
        LET cTieneMovto = '';
		LET iTotalOperados      = 0;
        LET iTotalDigitalizados = 0;
        LET iTotalPresentados   = 0;
        LET iTotalPorPresentar  = 0;
        LET iTotalPorRecibir    = 0;
        LET iTotalRegistros = 0;

	BEGIN
		-- ****************************************************************************
		-- *                        CONTROL DE ERRORES                                *
		-- ****************************************************************************
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
		END EXCEPTION;
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        --SET DEBUG FILE TO "/tmp/mfinis/sp_monitor_envio_cheques.out";
	    --TRACE ON;

		-- ****************************************************************************
		-- *                   VALIDAR LOS PARAMETROS DE ENTRADA                      *
		-- ****************************************************************************
		IF pBandera = '1' THEN
			IF pUsuario = '' OR pIdFuncion = '' OR pRegistros = '' OR pRecuperacion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			END IF;
		ELIF pBandera = '2' THEN
			IF pUsuario = '' OR pIdFuncion = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			END IF;
		END IF;


		IF pBandera = '1' THEN
			FOREACH
            EXECUTE PROCEDURE "informix".sp_monitorenviochequesope(pUsuario, pIdFuncion, pRegistros, pRecuperacion)
			INTO cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir WITH RESUME;
            END FOREACH
		ELIF pBandera = '2' THEN
			EXECUTE PROCEDURE "informix".sp_monitorenviochequesope_totales(pUsuario, pIdFuncion)
            INTO cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
			RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor, iTotalRegistros, 
									iTotalOperados, iTotalDigitalizados, iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
		END IF;
	END;
END PROCEDURE
DOCUMENT 
"AUTOR : Eduardo Ãvila PÃ©rez Tagle",
'MODULO: CÃ¡maras de compensaciÃ³n',
"FUNCIONAMIENTO:SP padre de camaras de compensaciÃ³n - monitor envÃ­o de cheques",
"FECHA : 03-03-2023",
"DB: bdicnweb";

CREATE PROCEDURE "informix".sp_monitorenviochequesope(pUsuario CHAR(8), pIdFuncion CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
                RETURNING CHAR(5)             AS codret,
                CHAR(3)                       AS banco,
                CHAR(40)                      AS descripcionBanco,
                CHAR(40)                      AS cuenta,
                INTEGER                       AS numeroCheque,
                DECIMAL(14,2)                 AS montoOrigen,
                DATE                          AS fechaAlta,
                DATETIME HOUR TO FRACTION(3)  AS hora,
                CHAR(44)                      AS sucursal,
                SMALLINT                      AS diasRetorno,
                CHAR(16)                      AS folioSucursal,
                CHAR(4)                       AS transcc,
                CHAR(4)                       AS claveSucursal,
                CHAR(25)                      AS digitalizado,
                CHAR(2)                       AS pre,
                CHAR(2)                       AS estatusColor;
        
                
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE cTieneMovto CHAR(1);
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;     
        LET iCuenta = 0;        
        LET cTieneMovto = '';
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END EXCEPTION;
        
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_monitorenviochequesope.out';
                --TRACE ON;

                SET ISOLATION TO DIRTY READ;
                SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                -- VALIDACION DE LA PAGINACION
                IF pRegistros < 0 OR pRecuperacion < 0 THEN
                        LET cCodRet = '00098';
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;  
                END IF;
                
                FOREACH SELECT SKIP pRegistros FIRST pRecuperacion *
                                INTO cCodRetSp, cBanco, cDescripcionBanco, cReferencia, iNumeroCheque, dMontoOrigen, dFechaAlta, 
                                        dHora, cSucursal, sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cTieneMovto
                                FROM 
                                (SELECT a.cod_ret
                                        , a.banco
                                        , a.desc_banco
                                        , a.referencia
                                        , a.num_cheque
                                        , a.monto_orig
                                        , a.fecha_alta
                                        , a.hora
                                        , a.sucursal
                                        , a.dias_ret
                                        , a.folio_suc
                                        , a.transcc
                                        , a.cve_suc
                                        , DECODE(transcc, '0250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                        FROM bdicheq:"informix".sc_movdia WHERE empresa = '001' 
                                        AND folio_suc = a.folio_suc 
                                        AND sucursal = a.cve_suc 
                                        AND transacc IN (SELECT transacc FROM bditef:cce_mapeo_cecoban) 
                                        AND cancelad <> 'S'), '6250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                        FROM bdicred:"informix".sd_movdia WHERE empresa = '001' AND folio_suc = a.folio_suc 
                                        AND sucursal = a.cve_suc AND reversado = 'N')) AS tiene_movto
										
                                FROM (TABLE (PROCEDURE bdicheq:"informix".sp_cce_consultarchequesmovs(cEmpresa, dFechaIni)) AS
                                a(cod_ret, banco, desc_banco, referencia, num_cheque, monto_orig, fecha_alta, hora, sucursal, dias_ret, folio_suc, transcc, cve_suc)))
                                WHERE tiene_movto <> '0'
                                
                                LET cReferencia = TRIM(SUBSTR(cReferencia,6,20));
                                LET iCuenta = cReferencia ::BIGINT;
                                LET cCuenta = iCuenta;
                                
                                SELECT {+AVOID_FULL(bditef:"informix".cce_cheques_det)} presentado, fechahoracap INTO cPresentado, cFechahoracap FROM bditef:"informix".cce_cheques_det 
                                WHERE empresa = '001' AND cvebanco = cBanco AND numcuenta = cCuenta  
                                AND numcheque = iNumeroCheque AND fecha_alta = dFechaAlta;
                                
                                IF cPresentado == "1" THEN
                                        LET cPre = "SI";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "1";
                                ELIF cPresentado == "0" AND cFechahoracap <> "" THEN
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "2";
                                ELSE
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "0";
                                END IF;

                                RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, sDiasRetorno, 
                                        cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor WITH RESUME;
                END FOREACH
				
                IF DBINFO("sqlca.sqlerrd2") = 0 THEN
                        LET cCodRet = "00017";
                        RETURN cCodRet, cBanco, cDescripcionBanco, cCuenta, iNumeroCheque, dMontoOrigen, dFechaAlta, dHora, cSucursal, 
                                   sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cDigitalizado, cPre, cEstatusColor;                  
                END IF;         
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 29/10/2014',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor EnvÃ­o Cheques',
'DESCRIPCIÃN: SPL que consulta los cheques en transito',
'cEstatusColor: 0 -> Rojo, cEstatusColor: 1 --Verde, cEstatusColor: 2 --> Amarillo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_monitorenviochequesope_totales(pUsuario CHAR(8), pIdFuncion CHAR(10))
                RETURNING CHAR(5) AS codret,
                INTEGER AS totalchequesenvio,
                INTEGER AS iTotalOperados,
                INTEGER AS iTotalDigitalizados,
                INTEGER AS iTotalPresentados,
                INTEGER AS iTotalPorPresentar,
                INTEGER AS iTotalPorRecibir;

        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp INTEGER;
        DEFINE cEmpresa CHAR(3);
        DEFINE iNoRegistros INTEGER;
        DEFINE cBanco CHAR(3);
        DEFINE cDescripcionBanco CHAR(40);
        DEFINE cReferencia CHAR(40);
        DEFINE cCuenta CHAR(40);
        DEFINE iNumeroCheque INTEGER;
        DEFINE dMontoOrigen DECIMAL(14,2);
        DEFINE dFechaAlta DATE;
        DEFINE dHora DATETIME HOUR TO FRACTION(3);
        DEFINE cSucursal CHAR(44);
        DEFINE sDiasRetorno SMALLINT;
        DEFINE cFolioSucursal CHAR(16);
        DEFINE cTranscc CHAR(4);
        DEFINE cClaveSucursal CHAR(4);
        DEFINE cDigitalizado CHAR(25);
        DEFINE cPre CHAR(2);
        DEFINE cEstatusColor CHAR(2);
        DEFINE bBanderaMovimientoCheques BOOLEAN;
        DEFINE bBanderaMovimientoCredito BOOLEAN;
        DEFINE cPresentado CHAR(1);
        DEFINE cFechahoracap CHAR(25);
        DEFINE dFechaIni DATE;
        DEFINE iCuenta BIGINT;
        DEFINE iTotalOperados      INTEGER;
        DEFINE iTotalDigitalizados INTEGER;
        DEFINE iTotalPresentados   INTEGER;
        DEFINE iTotalPorPresentar  INTEGER;
        DEFINE iTotalPorRecibir    INTEGER;
        DEFINE cTieneMovto CHAR(1);
        DEFINE iTotalRegistros INTEGER;
                
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cEmpresa = '001';
        LET iNoRegistros = 0;
        LET cBanco = '';
        LET cDescripcionBanco = '';
        LET cReferencia = '';
        LET cCuenta = '';                                       
        LET iNumeroCheque = 0;
        LET dMontoOrigen = 0.0;
        LET dFechaAlta = '';
        LET dHora = '';
        LET cSucursal = '';
        LET sDiasRetorno = 0;
        LET cFolioSucursal = '';
        LET cTranscc = '';
        LET cClaveSucursal = '';
        LET cDigitalizado = "";
        LET cPre = "";
        LET cEstatusColor = "0";
        LET bBanderaMovimientoCheques = 'f';
        LET bBanderaMovimientoCredito = 'f';
        LET cPresentado = '';
        LET cFechahoracap = '';
        LET dFechaIni = CURRENT;     
        LET iCuenta = 0;        
        LET iTotalOperados      = 0;
        LET iTotalDigitalizados = 0;
        LET iTotalPresentados   = 0;
        LET iTotalPorPresentar  = 0;
        LET iTotalPorRecibir    = 0;
        LET cTieneMovto = '';
        LET iTotalRegistros = 0;
        
        
        BEGIN
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END EXCEPTION;
                
                ON EXCEPTION IN (-206)
                END EXCEPTION WITH RESUME;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_monitorenviochequesope_totales.out';
                --TRACE ON;

               SET ISOLATION TO DIRTY READ;
               SET LOCK MODE TO WAIT 3;
                
                IF pUsuario = '' OR pIdFuncion = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
                END IF;
                
                
                DROP TABLE cep_monitorcheques_tmp;
                
                -- CREACION DE TABLA TEMPORAL
                CREATE TEMP TABLE cep_monitorcheques_tmp(
                        diasRetorno SMALLINT,
                        digitalizado CHAR(25),
                        pre CHAR(2),
                        estatusColor CHAR(2),
                        presentado CHAR(1)) WITH NO LOG;
                
                
                --FOREACH SELECT COUNT(*) INTO iTotalRegistros
                  FOREACH SELECT * INTO cCodRetSp, cBanco, cDescripcionBanco, cReferencia, iNumeroCheque, dMontoOrigen, dFechaAlta, 
                                dHora, cSucursal, sDiasRetorno, cFolioSucursal, cTranscc, cClaveSucursal, cTieneMovto   
                        FROM            
                        (SELECT a.cod_ret
                                , a.banco
                                , a.desc_banco
                                , a.referencia
                                , a.num_cheque
                                , a.monto_orig
                                , a.fecha_alta
                                , a.hora
                                , a.sucursal
                                , a.dias_ret
                                , a.folio_suc
                                , a.transcc
                                , a.cve_suc
                                , DECODE(transcc, '0250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END
                                FROM bdicheq:"informix".sc_movdia WHERE empresa = cEmpresa AND folio_suc = a.folio_suc 
                                AND sucursal = a.cve_suc AND transacc IN (SELECT transacc FROM bditef:"informix".cce_mapeo_cecoban) 
                                AND cancelad <> 'S'), '6250', (SELECT CASE WHEN COUNT(folio_suc) > 0 THEN '1' ELSE '0' END 
                                FROM bdicred:"informix".sd_movdia WHERE empresa = cEmpresa AND folio_suc = a.folio_suc 
                                AND sucursal = a.cve_suc AND reversado = 'N')) AS tiene_movto
                                
                        FROM (TABLE (PROCEDURE bdicheq:"informix".sp_cce_consultarchequesmovs(cEmpresa, dFechaIni)) AS
                        a(cod_ret, banco, desc_banco, referencia, num_cheque, monto_orig, fecha_alta, hora, sucursal, dias_ret, folio_suc, transcc, cve_suc)))
                        WHERE tiene_movto <> '0'
                        
                        LET cReferencia = TRIM(SUBSTR(cReferencia,6,20));
                        LET iCuenta = cReferencia ::BIGINT;
                        LET cCuenta = iCuenta;
                        
                        SELECT {+AVOID_FULL(bditef:"informix".cce_cheques_det)} presentado, fechahoracap INTO cPresentado, cFechahoracap FROM bditef:"informix".cce_cheques_det 
                                                WHERE empresa = cEmpresa AND cvebanco = cBanco AND numcuenta = cCuenta  
                                                AND numcheque = iNumeroCheque AND fecha_alta = dFechaAlta;
                                                
                                IF cPresentado == "1" THEN
                                        LET cPre = "SI";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "1";
                                ELIF cPresentado == "0" AND cFechahoracap <> "" THEN
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "2";
                                ELSE
                                        LET cPre = "";
                                        LET cDigitalizado = cFechahoracap;
                                        LET cEstatusColor = "0";
                                END IF;
                        
                                INSERT INTO cep_monitorcheques_tmp(diasRetorno, digitalizado,  pre,  estatusColor, presentado)
                                VALUES (sDiasRetorno, cDigitalizado, cPre, cEstatusColor, cPresentado);
                        LET iTotalRegistros = iTotalRegistros + 1; 
                END FOREACH
                
                SELECT COUNT(*) INTO iTotalOperados FROM cep_monitorcheques_tmp;
                SELECT COUNT(digitalizado) INTO iTotalDigitalizados FROM cep_monitorcheques_tmp;
                SELECT COUNT(presentado) INTO iTotalPresentados FROM cep_monitorcheques_tmp WHERE presentado = '1';
                SELECT COUNT(*) INTO iTotalPorPresentar  FROM cep_monitorcheques_tmp WHERE pre = "" AND diasRetorno = '1';
                LET iTotalPorRecibir = iTotalOperados - iTotalDigitalizados;
                
                IF iTotalRegistros == 0 THEN 
                        LET cCodRet = '00017';
                END IF;

                RETURN cCodRet, iTotalRegistros, iTotalOperados, iTotalDigitalizados, 
                           iTotalPresentados, iTotalPorPresentar, iTotalPorRecibir;
        END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando MartÃ­n',
'FECHA: 29/10/2014',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Monitor EnvÃ­o Cheques',
'DESCRIPCIÃN: SPL que consulta los cheques en transito',
'cEstatusColor: 0 -> Rojo, cEstatusColor: 1 --Verde, cEstatusColor: 2 --> Amarillo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cc_libracionsalvobuencobro(pBandera CHAR(2), pUsuario CHAR(8), pIdFuncion CHAR(10), pDiaslib CHAR(6), pFechaReporte CHAR(10),  pPassword CHAR(40), pRegistros INTEGER, pRecuperacion INTEGER)
    RETURNING CHAR(6)       AS codRet,
              INTEGER       AS totalRegistros,
              CHAR(20)	    AS Cuenta,
			  CHAR(4)	    AS Sucursal,
			  DATE 		    AS FechaAlta,
			  CHAR(4)	    AS Transacc,
			  CHAR(40)	    AS Referencia,
			  INTEGER	    AS NumeroChque,
			  SMALLINT	    AS DiasOri,
			  MONEY(14,2)   AS MontoOri,
			  CHAR(2)	    AS Siglas,
			  CHAR (40)     AS Banco,
			  CHAR (10)     AS Fecharep;

-- DECLARACIÃN DE VARIABLES
    DEFINE iSqlErr          INTEGER;
    DEFINE cCodRet          CHAR(6);

    DEFINE iTotalRegistros  INTEGER;
    DEFINE cCuenta          CHAR(20);
    DEFINE cSucursal        CHAR(4);
    DEFINE dFechaAlta       DATE;
    DEFINE cTransaccion     CHAR(4);
    DEFINE cReferencia      CHAR(40);
    DEFINE iNumCheque       INTEGER;
    DEFINE sDiasOri         SMALLINT;
    DEFINE mMontoOri        MONEY(14,2);
    DEFINE cSiglas          CHAR (2);
    DEFINE cBanco           CHAR(40);
    DEFINE cFecharep        CHAR(10);
    DEFINE cStatus          CHAR(1);
    DEFINE cErrorProceso    CHAR(1);
    DEFINE cError           CHAR(5);

-- INICIALIZACIÃN DE VARIABLES
    LET iSqlErr = "";
    LET cCodRet = "00000";

    LET iTotalRegistros = 0;
    LET iTotalRegistros = 0;
    LET cCuenta         = "";
    LET cSucursal       = "";
    LET dFechaAlta      = "";
    LET cTransaccion    = "";
    LET cReferencia     = "";
    LET iNumCheque      = 0;
    LET sDiasOri        = 0;
    LET mMontoOri       = 0.0;
    LET cSiglas         = "";
    LET cBanco          = "";
    LET cFecharep       = "";
    LET cStatus         = '';
    LET cErrorProceso   = '';
    LET cError          = '';

    BEGIN
        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
		END EXCEPTION;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_cc_libracionsalvobuencobro.out';
		--TRACE ON;

        IF pBandera = '' OR pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003'; -- Bandera o usuario o id funcion vacia
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) 
        INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
		END IF;

        IF pBandera = '1' THEN
            EXECUTE PROCEDURE "informix".sp_ope_diasret(pUsuario , pIdFuncion, pDiaslib)
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '2' THEN
            EXECUTE PROCEDURE "informix".sp_ope_liberasalret(pUsuario , pIdFuncion)
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '3' THEN
            EXECUTE PROCEDURE "informix".sp_ope_reportesbc_totales(pUsuario, pIdFuncion , pFechaReporte )
            INTO cCodRet, iTotalRegistros;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF pBandera = '4' THEN
            FOREACH
                EXECUTE PROCEDURE "informix".sp_ope_reportesbc(pUsuario , pIdFuncion, pFechaReporte, pRegistros, pRecuperacion)
                INTO cCodRet, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep
                
                RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep WITH RESUME;
            END FOREACH
        END IF

        IF pBandera = '5' THEN
            EXECUTE PROCEDURE "informix".sp_ope_validapassword(pUsuario, pIdFuncion , pPassword )
            INTO cCodRet;
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF 
        
        IF pBandera = '6' THEN
            EXECUTE PROCEDURE "informix".sp_verificastatusliberaret(pUsuario)
            INTO cCodRet, cSucursal, cSiglas, cReferencia;
            
            RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , TRIM(cReferencia), iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, iTotalRegistros, cCuenta, cSucursal, dFechaAlta, cTransaccion , cReferencia, iNumCheque , sDiasOri, mMontoOri, cSiglas, cBanco, cFecharep;
        END IF

    END

END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 05/05/2023',
'MODULO: CAMARAS',
'FUNCIONALIDAD: SALDO BUEN COBRO', 
'DESCRIPCION: SPL Maestro encargado de ejecutar los procedimientos alamacenado de la funcionalidad de liberaciÃ³n saldo buen cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_diasret(pUsuario CHAR(8), pIdFuncion CHAR(10), pDiaslib CHAR(6))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE bInTransaccion BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET bInTransaccion = 'f';
	LET cEmpresa = '001';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;

		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_diasret.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		BEGIN WORK;
		
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.dias_ret(cEmpresa, pDiaslib)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP dias_ret';
		ELIF iCodRetSp = 4 THEN
			LET cCodRet = '00452'; --SISTEMA TEMPORALMENTE FUERA DE SERVICIO
		ELIF iCodRetSp = 971 THEN
			LET cCodRet = '00760'; --PROCESO DE LIBERACION DE RETENIDOS YA EFECTUADO
		ELIF iCodRetSp <> 0 THEN
			LET cCodRet = cCodRetSp;
		END IF;

		IF cCodRet::INT > 0 THEN
			LET bInTransaccion = 'f';
			BEGIN WORK;
		END IF;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl para realizar la liberaciÃÂ³n salvo buen cobro',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_liberasalret(pUsuario CHAR(8), pIdFuncion CHAR(10))
		RETURNING CHAR(5) AS codret;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE iCodRetSp INTEGER;
	DEFINE cIdDevolucion CHAR(2);
	DEFINE cDescipcionMotivo CHAR(70);
	DEFINE bInTransaccion BOOLEAN;
	DEFINE cEmpresa CHAR(3);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cIdDevolucion = '';
	LET cDescipcionMotivo = '';
	LET bInTransaccion = 'f';
	LET cEmpresa = '001';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;
			
			RETURN cCodRet;
		END EXCEPTION;
		
		ON EXCEPTION IN (-535)
			LET bInTransaccion = 't';
			COMMIT WORK;
		END EXCEPTION WITH RESUME;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_liberasalret.out';
		--TRACE ON;

		DELETE FROM "informix".sw_verificastatusliberaret WHERE usuario_insert = pUsuario;
		INSERT INTO "informix".sw_verificastatusliberaret VALUES (0,pUsuario,'I','N','');
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

			RETURN cCodRet;
		END IF;

		BEGIN WORK;
		
		IF bInTransaccion = 'f' THEN
			COMMIT WORK;
		END IF;


		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		EXECUTE PROCEDURE bdicheq:'informix'.liberasalret2(cEmpresa, pUsuario)
		INTO cCodRetSp;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP liberasalret';
		ELIF iCodRetSp = 962 THEN
			LET cCodRet = '00455'; --CIERRE NO EFECTUADO
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		ELIF iCodRetSp = 971 THEN
			LET cCodRet = '00760'; --PROCESO DE LIBERACION DE RETENIDOS YA EFECTUADO

			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		ELIF iCodRetSp = 110 THEN
			LET cCodRet = '00003'; --FALTAN PARAMETROS DE ENTRADA
			
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'E', error_proceso = 'S', error = cCodRet where usuario_insert = pUsuario;

		END IF;
		
		IF cCodRet::INT > 0 THEN
			LET bInTransaccion = 'f';
			BEGIN WORK;
		END IF;
		
		IF bInTransaccion = 't' THEN
			BEGIN WORK;
		END IF;

		IF cCodRet = '00000' THEN
			UPDATE bdicnweb:"informix".sw_verificastatusliberaret  
			SET status = 'T', error_proceso = 'N', error = cCodRet where usuario_insert = pUsuario;
		END IF;

		RETURN cCodRet;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl para realizar la liberaciÃÂ³n salvo buen cobro',
'FECHA: 20/11/2024',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'DESCRIPCION: Se aÃ±aden hilo de espera para la funcionalidad de liberaciÃ³n de saldo retenido',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_reportesbc(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaReporte CHAR(10), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING CHAR(5) AS codret,
				  CHAR(20)	AS Cuenta,
				  CHAR(4)	AS Sucursal,
				  DATE 		AS FechaAlta,
				  CHAR(4)	AS Transacc,
				  CHAR(40)	AS Referencia,
				  INTEGER	AS NumeroChque,
				  SMALLINT	AS DiasOri,
				  MONEY(14,2) AS MontoOri,
				  CHAR(2)	AS Siglas,
				  CHAR (40) AS Banco,
				  CHAR (10) AS Fecharep;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cCuenta         CHAR(20);
	DEFINE cSucursal       CHAR(4);
	DEFINE cFechaAlta      DATE;
	DEFINE cTransacc       CHAR(4);
	DEFINE cReferencia     CHAR(40);
	DEFINE iNumeroChque    INTEGER;
	DEFINE sDiasOri        SMALLINT;
	DEFINE mMontoOri       MONEY(14,2);
	DEFINE cSiglas         CHAR(2);
	DEFINE cBanco          CHAR (40);
	DEFINE cFecharep       CHAR (10);
	DEFINE iRecuperacion   INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cCuenta         = '';
	LET cSucursal       = '';
	LET cFechaAlta      = '';
	LET cTransacc       = '';
	LET cReferencia     = '';
	LET iNumeroChque    = '';
	LET sDiasOri        = '';
	LET mMontoOri       = 0;
	LET cSiglas         = '';
	LET cBanco          = '';
	LET cFecharep       = '';
	LET iRecuperacion   = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reportesbc.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep;
		END IF;
		
		FOREACH
			EXECUTE PROCEDURE bdicheq:'informix'.sp_reportesbc2(cEmpresa, pFechaReporte, pRegistros, pRecuperacion)
			INTO cCodRetSp, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
			cSiglas, cBanco, cFecharep
			
			LET iCodRetSp = cCodRetSp::INTEGER;
			IF iCodRetSp < 0 THEN
				RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_reportesbc';
			ELSE
				RETURN cCodRet, cCuenta, cSucursal, cFechaAlta, cTransacc, cReferencia, iNumeroChque, sDiasOri, mMontoOri,
				cSiglas, cBanco, cFecharep WITH RESUME;
			END IF;
		END FOREACH;
	END;
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet = '00017';
		RETURN cCodRet, '', '', '', '', '', 0, '', 0, '', '', '';
	ELIF iRecuperacion = 0 AND pRegistros > 0 THEN
		LET cCodRet = '01001';
		RETURN cCodRet, '', '', '', '', '', 0, '', 0, '', '', '';
	END IF;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/03/2016',
'DESCRIPCION: spl el cual regresa datos informaciÃÂ³n de los movimientos liberados SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_reportesbc_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pFechaReporte CHAR(10))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS TotalRegistros;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE iTotalRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET iTotalRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iTotalRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_reportesbc_totales.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iTotalRegistros;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iTotalRegistros;
		END IF;
		
		EXECUTE PROCEDURE bdicheq:'informix'.sp_reportesbc2_totales(cEmpresa, pFechaReporte)
		INTO cCodRetSp, iTotalRegistros;
		
		LET iCodRetSp = cCodRetSp::INTEGER;
		IF iCodRetSp < 0 THEN
			RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_reportesbc';
		ELSE
			IF iTotalRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, 0;
			ELSE 
				RETURN cCodRet, iTotalRegistros;
			END IF;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 04/03/2016',
'DESCRIPCION: spl el cual regresa datos informaciÃÂ³n de los movimientos liberados SBC',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_validapassword(pUsuario CHAR(8), pIdFuncion CHAR(10), pPassword CHAR(40))
		RETURNING CHAR(5) AS codret;
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iCodRetSp INTEGER;
	DEFINE cPassword CHAR(40);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iCodRetSp = 0;
	LET cPassword = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_validapassword.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pPassword = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		SELECT password INTO cPassword FROM bdinteg:si_ejecut WHERE ejecutivo = pUsuario;
		IF pPassword <> cPassword  THEN
			LET cCodRet = '00106'; --EL USUARIO NO TIENE REGISTRADA SU CONTRASEÃÂA O ES INCORRECTA
			RETURN cCodRet;
		ELSE
			RETURN cCodRet;
		END IF;
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin',
'FECHA: 03/03/2016',
'DESCRIPCION: spl que comprueba la constraseÃÂ±a del usuario',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_verificastatusliberaret(pUsuario CHAR(8))
	RETURNING CHAR(5) AS codret,
              CHAR(1)       AS Status,
              CHAR(1)       AS error_proceso,  
              CHAR(5)       AS error;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
    DEFINE cStatus CHAR(1);
    DEFINE cErrorProceso CHAR(1);
    DEFINE cError   CHAR(5);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
    LET cStatus = '';
    LET cErrorProceso = '';
    LET cError = '';
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cStatus, cErrorProceso, cError;
		END EXCEPTION;
		
		
		IF pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cStatus, cErrorProceso, cError;
		END IF;

        --SET DEBUG FILE TO '/tmp/mfinis/sp_verificastatusliberaret.out';
		--TRACE ON;

        SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

        IF (SELECT count(*) FROM "informix".sw_verificastatusliberaret WHERE usuario_insert = pUsuario) > 0 THEN

            SELECT status, error_proceso, error
            INTO cStatus, cErrorProceso, cError
            FROM "informix".sw_verificastatusliberaret
            WHERE usuario_insert = pUsuario;

        ELSE
            LET cCodRet = '00017';
            RETURN cCodRet, cStatus, cErrorProceso, cError;
        END IF;

		RETURN cCodRet, cStatus, cErrorProceso, cError;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 20/11/2024',
'DESCRIPCION: Se aÃ±aden hilo de espera para la funcionalidad de liberaciÃ³n de saldo retenido',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_sac_reportesdiario(pUsuario CHAR(8), pIdFuncion CHAR(10), pPeriodo DATE, pConvenio CHAR(5),pRutaDescarga CHAR(100),pIdPlantilla CHAR(25),pTituloPlantilla CHAR(255))
    RETURNING CHAR(5) AS codret,
    CHAR(100) AS reporte_generado;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	 
	DEFINE cCmd1 CHAR(4000);
	DEFINE cSql CHAR(4000);
	DEFINE cRutaGral CHAR(150);
	DEFINE cNombreArchivo CHAR(100);
	DEFINE bInTransaction BOOLEAN;
	DEFINE ven_transacc SMALLINT;
	DEFINE dFechaHoy DATE;
	DEFINE cFechaHoraArchivo CHAR(35);
	DEFINE cBanDetError CHAR(1); 
    DEFINE cCodRetSp CHAR(5);
	
	DEFINE cTipo CHAR(50);
	DEFINE dDia DATE;
	DEFINE cNum_confirmacion CHAR(16);
	DEFINE mImporte MONEY(16,2);
	DEFINE cForma_pago CHAR (20);
	DEFINE cFolio_op CHAR (16);
	DEFINE cSucursal CHAR (5);
	DEFINE cCajero CHAR (8);
	DEFINE cNom_benef CHAR (120);
	DEFINE iTotal INTEGER;
	DEFINE dHoraHoy DATETIME HOUR TO SECOND;
	DEFINE cNombre CHAR(30);	
	DEFINE pIdMensaje CHAR(10);
	DEFINE cCategoria CHAR(2);
	DEFINE cConvenio CHAR(3);
	DEFINE cNombreReporteHist CHAR(100);
	DEFINE cNombreReporteLey CHAR(100);
	
	--variable para commit consulta de REGISTROS
	DEFINE vCuenta INTEGER;

		
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCmd1 = '';
	LET cSql = '';
	LET cRutaGral = '';
	LET cNombreArchivo = '';
	LET bInTransaction = 'f';
	LET ven_transacc = 0;
	LET dFechaHoy = '';
	LET cFechaHoraArchivo = '';
	LET cBanDetError = 'f';
	LET cCodRetSp='00000';

	LET cTipo ='';
	LET dDia = NULL;
	LET cNum_confirmacion = '';
	LET mImporte = 0.0;
	LET cForma_pago = '';
	LET cFolio_op = '';
	LET cSucursal = '';
	LET cCajero = '';
	LET cNom_benef = '';	
	LET iTotal = 0;
	LET dHoraHoy = '';
	LET cNombre ='';
	LET pIdMensaje='WEB_PLAROF'; --VARIABLE MENSAJE NOTIFICACION 
	LET cCategoria = SUBSTRING(pConvenio FROM 1 FOR 2);
	LET cConvenio  = SUBSTRING(pConvenio FROM 3 FOR 3);
	LET cNombreReporteHist = '';
	LET cNombreReporteLey = '';
	
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr
            LET cCodRet = iSqlErr;
						
            IF ven_transacc = 1 THEN
                ROLLBACK WORK;
            END IF;
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
            RETURN cCodRet, cNombreArchivo;
        END EXCEPTION;

        ON EXCEPTION IN (-668, -535, -255)
            LET bInTransaction = 't';
           COMMIT WORK;
            BEGIN WORK;
        END EXCEPTION WITH RESUME;
		
		IF pConvenio ='07006' THEN 
		LET cTipo ='REPORTE DIARIO REMESAS WU';
		ELIF pConvenio ='07007' THEN 		
		LET cTipo ='REPORTE DIARIO REMESAS OV';
		ELIF pConvenio = '07008' THEN 
		LET cTipo='REPORTE DIARIO REMESAS VIGO';
		ELIF pConvenio = '07004' THEN 
		LET cTipo='REPORTE DIARIO REMESAS BTS';
		ELIF pConvenio = '07009' THEN 
		LET cTipo='REPORTE DIARIO REMESAS APPRIZA';
		END IF;

		--SET DEBUG FILE TO '/ifxsif01/emm/sp_reportediario.out';
		--TRACE ON;


		IF pUsuario = '' OR pIdFuncion = '' OR pRutaDescarga = ''  OR pPeriodo ='' OR pConvenio ='' OR  pIdPlantilla ='' OR pTituloPlantilla ='' THEN
			LET cCodRet = '00003';				
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
	       RETURN cCodRet, cNombreArchivo;
    	END IF;

		LET dFechaHoy = CURRENT;
		LET dHoraHoy = CURRENT;	
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN		
		    EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
			 RETURN cCodRet, cNombreArchivo;
		END IF;
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pConvenio ='07006' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariowutmp WHERE usuario = pUsuario;

		ELIF pConvenio ='07007' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiarioovtmp WHERE usuario = pUsuario;
	
		ELIF pConvenio = '07008' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariovgtmp WHERE usuario = pUsuario;
			
		ELIF pConvenio ='07004' THEN 
			-- SE LIMPIA TABLA POR USUARIO
			DELETE FROM "informix".sw_cb_reportesacdiariobtstmp WHERE usuario = pUsuario;
	
		ELIF pConvenio = '07009' THEN 
			-- SE LIMPIA TABLA POR USUARIO			
            DELETE FROM "informix".sw_cb_reportesacdiarioapptmp WHERE usuario = pUsuario;
		END IF;
		
		-- SE ELIMINAN TODOS LOS REGISTROS GENERADOS MENORES A LA FECHA HOY (T-1)
			
		FOREACH 
			
			SELECT nombre_reporte
			INTO cNombreReporteHist
			FROM bdicnweb:"informix".sw_ctrlgenreportesac 
			WHERE usuario_insert = pUsuario
			AND fecha_reporte <= TODAY-1
			
			
			LET cSql = '';
			LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cNombreReporteHist);
			SYSTEM TRIM(cSql);
			
			LET cNombreReporteHist = TRIM(cNombreReporteHist);
				
			---DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND nombre_reporte = TRIM(cNombreReporteHist);
		    DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND nombre_reporte =cNombreReporteHist;
		
		END FOREACH;
		
		
		IF pConvenio IN ('07006','07007','07008') THEN 
		
		-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		FOREACH WITH HOLD		   
			
		SELECT 
			DISTINCT fecha_pago,mtcn,importe_pago,forma_pago,folio_suc,id_sucursal,usuario,nom_benef 
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
		FROM(
			SELECT 
				--{+INDEX(bdisac:"informix".sac_movimientoshistorial idxsac_movhisfe)}
				--, +INDEX(bdisac:"informix".sac_wu_pay idx_sac_wu_pay_rep)} --STK 092024
				movhis.fecha_pago, wu.mtcn, movhis.importe_pago,
				(DECODE(movhis.origen, 'CPL', 'EFECTIVO-CLP', DECODE(movhis.forma_pago, '1', 'EFECTIVO', DECODE(movhis.forma_pago, '2', 'CARGO EN CUENTA', DECODE(movhis.forma_pago, '3', 'MIXTO', DECODE(movhis.forma_pago, '4', 'ABONO CTA', movhis.forma_pago)))))) AS forma_pago,
				--case when movhis.forma_pago='1' and movhis.origen ='CPL' then 'EFECTIVO-CPL' 
					--when movhis.forma_pago='1' and movhis.origen <>'CPL' then 'EFECTIVO'
					--when movhis.forma_pago='2' and movhis.origen <>'CPL' then 'CARGO EN CUENTA'
					--when movhis.forma_pago='3' and movhis.origen <>'CPL' then 'MIXTO'
					--when movhis.forma_pago='4' and movhis.origen <>'CPL' then 'ABONO CTA'
				--end forma_pago,
				movhis.folio_suc, movhis.id_sucursal, movhis.usuario,
				(TRIM(wu.benef_nombre1) || ' ' || TRIM(wu.benef_appaterno) || ' ' || TRIM(wu.benef_apmaterno)) nom_benef
			FROM 
				bdisac:"informix".sac_movimientoshistorial AS movhis
			INNER JOIN 
				bdisac:"informix".sac_wu_pay AS wu ON wu.mtcn = movhis.referencia1
			WHERE 
				movhis.fecha_pago = pPeriodo
				AND movhis.numcategoria = cCategoria 
				AND movhis.numconvenio = cConvenio 
				AND movhis.folio_suc IN (wu.foreign_rs_refnum_rq, wu.foreign_rs_refnum_rp)
				AND movhis.status_cancelado = 'N'
				AND wu.txn_status = 'A'
				AND wu.conf_pago='P' 
				AND wu.retcode = '00000'
				AND wu.fecha_insert::date = pPeriodo
			)
						
			
			IF pConvenio ='07006' THEN 
			
			INSERT INTO "informix".sw_cb_reportesacdiariowutmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
			ELIF pConvenio ='07007' THEN 
									
			INSERT INTO "informix".sw_cb_reportesacdiarioovtmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
			
			ELIF pConvenio = '07008' THEN 
			
			INSERT INTO "informix".sw_cb_reportesacdiariovgtmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
			END IF;
			
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
						
	
			END FOREACH; 
			
			
				--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;
			
			
	    ELIF pConvenio = '07004' THEN 
		
		-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		
			FOREACH WITH HOLD	
			
			SELECT --{+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhis235), --STK 092024
			--+INDEX(bdisac:"informix".Sac_BTS_Payi idx_sac_bts_pay_new)} --STK 092024
			MOV.Fecha_Pago AS DIA, 
			BTS.CONFIRMATION_NM AS Num_confirmacion,
			MOV.Importe_Pago AS Importe,
			(DECODE(MOV.origen, 'CPL', 'EFECTIVO-CLP', DECODE(MOV.Forma_Pago, '1', 'EFECTIVO', DECODE(MOV.Forma_Pago, '2', 'CARGO EN CUENTA', DECODE(MOV.Forma_Pago, '3', 'MIXTO', DECODE(MOV.Forma_Pago, '4', 'ABONO CTA', MOV.Forma_Pago)))))) AS Forma_pago, 
            --case when MOV.Forma_Pago='1' and MOV.origen ='CPL' then 'EFECTIVO-CPL' 
                 --when MOV.Forma_Pago='1' and MOV.origen <>'CPL' then 'EFECTIVO'
                 --when MOV.Forma_Pago='2' and MOV.origen <>'CPL' then 'CARGO EN CUENTA'
                 --when MOV.Forma_Pago='3' and MOV.origen <>'CPL' then 'MIXTO'
                 --when MOV.Forma_Pago='4' and MOV.origen <>'CPL' then 'ABONO CTA'
            --end Forma_pago,
			MOV.Folio_Suc AS Folio_op, 
			MOV.Id_Sucursal AS Sucursal,
			MOV.Usuario AS Cajero,
			(TRIM(BTS.R_First_Name) || ' ' || TRIM(BTS.R_Middle_Name) || ' ' || TRIM(BTS.R_Last_Name)) AS Nom_benef
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
			FROM BdiSac:Sac_MovimientosHistorial AS MOV INNER JOIN BdiSac:Sac_BTS_Payi AS BTS
			ON MOV.Fecha_Pago = pPeriodo
			AND MOV.Folio_Suc =  BTS.Bank_Ref_Nm
			AND MOV.Referencia1 = BTS.Confirmation_Nm
			AND MOV.status_cancelado = 'N'
			
		
			
			INSERT INTO "informix".sw_cb_reportesacdiariobtstmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
	
		
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
	
	
		END FOREACH;
		
			--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;

		ELIF pConvenio = '07009' THEN 
		
			-----consultar los registros  de remesas WU
		LET vCuenta = 0;
		
		BEGIN WORK;
		 
			FOREACH WITH HOLD	
			
			SELECT ---{+INDEX(bdisac:"informix".sac_movimientoshistorial  idxsac_movhis235)} 
			--+INDEX(bdisac:"informix".Sac_BTS_Payi idx_sac_bts_pay_new)} --STK 092024
			MOV.Fecha_Pago AS DIA, 
            APP.r_uniquerefnum AS Num_confirmacion,
            MOV.Importe_Pago AS Importe,
		   (DECODE(MOV.origen, 'CPL', 'EFECTIVO-CLP', DECODE(MOV.Forma_Pago, '1', 'EFECTIVO', DECODE(MOV.Forma_Pago, '2', 'CARGO EN CUENTA', DECODE(MOV.Forma_Pago, '3', 'MIXTO', DECODE(MOV.Forma_Pago, '4', 'ABONO CTA', MOV.Forma_Pago)))))) AS Forma_pago, 
            --case when MOV.Forma_Pago='1' and MOV.origen ='CPL' then 'EFECTIVO-CPL' 
                 --when MOV.Forma_Pago='1' and MOV.origen <>'CPL' then 'EFECTIVO'
                 --when MOV.Forma_Pago='2' and MOV.origen <>'CPL' then 'CARGO EN CUENTA'
                 --when MOV.Forma_Pago='3' and MOV.origen <>'CPL' then 'MIXTO'
                 --when MOV.Forma_Pago='4' and MOV.origen <>'CPL' then 'ABONO CTA'
            --end Forma_pago,
            MOV.Folio_Suc AS Folio_op, 
            MOV.Id_Sucursal AS Sucursal,
            MOV.Usuario AS Cajero,
			(TRIM(APP.firstname) || ' ' || TRIM(APP.middlename) || ' ' || TRIM(APP.lastname)) AS Nom_benef                     
			INTO dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef
			FROM BdiSac:Sac_MovimientosHistorial AS MOV INNER JOIN bdisac:sac_app_payi AS APP
			ON MOV.Fecha_Pago = pPeriodo
			AND MOV.Folio_Suc =  APP.refnum
            AND MOV.Referencia1 = APP.unirefnum
            AND MOV.status_cancelado = 'N'
			
		
			INSERT INTO "informix".sw_cb_reportesacdiarioapptmp(usuario, dia, num_confirmacion, importe, forma_pago, folio_op, sucursal, cajero,nom_benef) 
			VALUES(pUsuario,dDia, cNum_confirmacion, mImporte, cForma_pago, cFolio_op, cSucursal, cCajero, cNom_benef);
			
				--Hago commit y vuelvo a iniciar
				LET vCuenta = vCuenta + 1;
						
		        	IF vCuenta = 1000 THEN
							COMMIT WORK;
							LET vCuenta = 0;
							BEGIN WORK;
						END IF;
		
		END FOREACH;	
		
		--Hago commit work de ser necesario
					IF vCuenta < 1000 and vCuenta >= 0 THEN
						COMMIT WORK;
					END IF;
	
		END IF;	
			
		IF pConvenio ='07006' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariowutmp WHERE usuario = pUsuario;
		ELIF pConvenio ='07007' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiarioovtmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07008' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariovgtmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07004' THEN 
			SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiariobtstmp WHERE usuario = pUsuario;
		ELIF pConvenio = '07009' THEN 
            SELECT COUNT(*) INTO iTotal FROM "informix".sw_cb_reportesacdiarioapptmp WHERE usuario = pUsuario;
		END IF;		
	
		
		IF iTotal = 0 THEN			
			LET cCodRet ='00017';			
			EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','no exitoso','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
		END IF;
		
		
        IF cCodRet='00000' THEN 
		--GENERACION DE REPORTE	
		LET cCmd1 ="";
		LET cCmd1 ="SELECT ' ',' ','SISTEMA DE ADMINISTRACION DE CONVENIOS ',' ',' ',' ','FECHA:','"||TO_CHAR(dFechaHoy, '%d/%m/%Y') ||"' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
		IF pConvenio ='07006' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS WU DIARIO',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio ='07007' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS OV DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07008' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS VIGO DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07004' THEN 
			LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS BTS DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		ELIF pConvenio = '07009' THEN 
            LET cCmd1 =""||TRIM(cCmd1)||" SELECT ' ',' ','CONCILIACION DE PAGOS DE REMESAS APPRIZA DIARIO ',' ',' ',' ','HORA:','"||TO_CHAR(dHoraHoy, '%H:%M:%S')||"' FROM systables  WHERE tabid = 1 ";
		END IF;		
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'CONVENIO:','''"||pConvenio||"','SUCURSAL:TODAS',' ','RANGO DE FECHAS DEL:','"||TO_CHAR(pPeriodo, '%d/%m/%Y')||"','AL:','"||TO_CHAR(pPeriodo, '%d/%m/%Y')||"' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        LET cCmd1 =""||TRIM(cCmd1)||" SELECT 'DIA','NUMERO CONFIRMACION','IMPORTE','FORMA DE PAGO','FOLIO OPERACION','NUMERO SUCURSAL','CAJERO','NOMBRE BENEFICIARIO' FROM systables  WHERE tabid = 1 ";
        LET cCmd1 =""||TRIM(cCmd1)||" UNION ALL ";
        
     	IF pConvenio ='07006' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariowutmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio ='07007' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiarioovtmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07008' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariovgtmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07004' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiariobtstmp WHERE usuario ='"||pUsuario||"'"; 
		ELIF pConvenio = '07009' THEN 
		LET cCmd1 =""||TRIM(cCmd1)||" SELECT LPAD(DAY(dia),2,0)||'/'||LPAD(MONTH(dia),2,0)||'/'||YEAR(dia), num_confirmacion::CHAR(20),importe::CHAR(20),forma_pago::CHAR(20),folio_op::CHAR(20),''''||sucursal::CHAR(5),cajero::CHAR(8),nom_benef::CHAR(120) FROM ""informix"".sw_cb_reportesacdiarioapptmp WHERE usuario ='"||pUsuario||"'"; 
		END IF;
		
		LET cFechaHoraArchivo = TO_CHAR(dFechaHoy, '%d%m%Y')||"_"||TO_CHAR(dHoraHoy, '%H%M%S')||"_"||pUsuario;
		 
		-- SE DEFINE NOMENCLATURA DEL REPORTE A GENERAR	
		
		IF pConvenio ='07006' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_WU_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo ='REPORTE DIARIO REMESAS WU';
		ELIF pConvenio ='07007' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_OV_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo ='REPORTE DIARIO REMESAS OV';
		ELIF pConvenio = '07008' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_VIGO_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS VIGO';
		ELIF pConvenio = '07004' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_BTS_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS BTS';
		ELIF pConvenio = '07009' THEN 
		LET cNombreArchivo = 'REPORTE_DIARIO_REMESAS_APP_'||TRIM(cFechaHoraArchivo)||'.csv';
		LET cTipo='REPORTE DIARIO REMESAS APPRIZA';
		END IF;
		
        LET pRutaDescarga = TRIM(pRutaDescarga) || '/';
        LET cRutaGral = TRIM(pRutaDescarga)||TRIM(cNombreArchivo);


                BEGIN WORK;
                       LET ven_transacc = 1;

                        LET cSql = '';
                      
                        LET cSql = '/usr/bin/echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||TRIM(cRutaGral)||' DELIMITER '','' '||TRIM(cCmd1)||' " > '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/chmod 777 '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        --RUTA PRUEBAS
						--LET cSql = '/informix/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
						--RUTA PRODUCTIVA
						LET cSql = '/ifxsif01/bin/dbaccess bdicnweb '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(pRutaDescarga)||TRIM(cFechaHoraArchivo)||'.sql';
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de linea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el archivo original
                        LET cSql = '';
                        LET cSql = "rm -rf "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        -- Eliminamos el caracter delimitador ';' al final de la linea
                        LET cSql = '';
                        LET cSql =  "sed 's/..$//g' "||TRIM(cRutaGral)||".tmp > "||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        -- Se manipula el archivo para agregar el salto de linea
                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = "sed "||"'s/$'""/`echo \\\r`/"" "||TRIM(cRutaGral)||" > "||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral)||".tmp";
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = '/usr/bin/rm -rf '||TRIM(cRutaGral)||'; /usr/bin/mv '||TRIM(cRutaGral)||'.tmp '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);

                        LET cSql = '';
                        LET cSql = 'chmod 777 '||TRIM(cRutaGral);
                        SYSTEM TRIM(cSql);
						
						
			     IF pConvenio ='07006' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_WU_%');
		         ELIF pConvenio ='07007' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_OV_%');
		         ELIF pConvenio = '07008' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_VIGO_%');
		         ELIF pConvenio = '07004' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_BTS_%');
		         ELIF pConvenio = '07009' THEN 
		         LET cNombreReporteLey = TRIM('REPORTE_DIARIO_REMESAS_APP_%');
		         END IF;		
						
						
			    LET cNombreArchivo = TRIM(cNombreArchivo);
						
				IF pConvenio ='07006' THEN 				
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_WU_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS WU' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio ='07007' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_OV_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS OV' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07008' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_VIGO_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS VIGO' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07004' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_BTS_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS BTS' AND nombre_reporte LIKE cNombreReporteLey;
				ELIF pConvenio = '07009' THEN 
				--DELETE FROM "informix".sw_ctrlgenreportesac WHERE TRIM(tipo) = TRIM(cTipo) AND usuario_insert = pUsuario AND TRIM(nombre_reporte) LIKE TRIM('REPORTE_DIARIO_REMESAS_APP_%');
				DELETE FROM "informix".sw_ctrlgenreportesac WHERE usuario_insert = pUsuario AND tipo='REPORTE DIARIO REMESAS APPRIZA' AND nombre_reporte LIKE cNombreReporteLey;
				END IF;
			    
			  --INSERT INTO "informix".sw_ctrlgenreportesac(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			  --VALUES(TRIM(cNombreArchivo),dFechaHoy,dHoraHoy,pUsuario,cTipo);
			   	   
				INSERT INTO "informix".sw_ctrlgenreportesac(nombre_reporte,fecha_reporte,hr_reporte,usuario_insert,tipo)
			    VALUES(cNombreArchivo,dFechaHoy,dHoraHoy,pUsuario,cTipo);
                     
        LET cBanDetError = 't';

				COMMIT WORK;

               LET ven_transacc = 0;
               IF bInTransaction = 't' THEN
                       BEGIN WORK;
               END IF;
			   
			    
                
        -- SE ENVIA LA NOTIFICACION DE CORREO ELECTRONICO
        EXECUTE PROCEDURE bdimnsj:"informix".sp_registra_evento('1',TRIM(pIdMensaje),TRIM(pIdPlantilla),pUsuario,'','','1','con Ã©xito','','','','',cTipo,'','','','','','',1,0,0,0,0,CURRENT,'') INTO cCodRetSp;
	    END IF;
		RETURN cCodRet, cNombreArchivo;

	END;
END PROCEDURE
DOCUMENT  
'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/11/2021',
'DESCRIPCION: SPL que genera los reportes de conciliacion remesas',
'BD: bdicnweb',
'AUTOR: Zahide Tellez Ramirez',
'FECHA: 03/08/2023',
'DESCRIPCION: Se realizan optimizaciones a SPL para bajar los costos altos y sequential',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_validaestatuspoliza(pUsuario CHAR(8), pIdFuncion CHAR(10))
	RETURNING CHAR(5) AS codret,
		CHAR(1) AS status,
		INTEGER AS num_registros,
		CHAR(1) AS error_proceso,
		CHAR(5) AS error,
		INTEGER AS poliza;

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cStatus CHAR(1);
	DEFINE cErrorProceso CHAR(1);
	DEFINE cError  CHAR(5);
	DEFINE cPoliza INTEGER;
	DEFINE iNumRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	LET cStatus = '';
	LET cErrorProceso = '';
	LET cError = '';
	LET iNumRegistros = 0;
	LET cPoliza= '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END EXCEPTION;

		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END IF;
		
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_validaestatuspoliza.out';
		-- TRACE ON;
		
		IF pUsuario = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;	
		END IF;		
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT status,total_registros,error_proceso,error,poliza
		INTO cStatus,iNumRegistros,cErrorProceso,cError, cPoliza
		FROM bdicnweb:"informix".sw_verificastatuspoliza
        WHERE usuario_insert = pUsuario;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet = '00017';	
			RETURN cCodRet,'E','','','',''; 
		ELSE 			
			RETURN cCodRet,cStatus,iNumRegistros,cErrorProceso,cError,cPoliza;		
		END IF;	
		
	END;
END PROCEDURE
DOCUMENT 'AUTOR: JOSÃ ANTONIO RAMÃREZ FRANCO',
'FECHA: 08/01/2024',
'MODULO: OFI',
'DESCRIPCION: VERIFICA EL ESTATUS DEL PROCESO DE RECUPERACIÃN DE POLIZA',
'BD: bdicont';

CREATE PROCEDURE "informix".sp_ofi_generarpolizanomina(pUsuario CHAR(8), pIdFuncion CHAR(10),pFechaActual DATE, pFechaQuincena DATE, pUsuarioSistema CHAR(8))
		RETURNING CHAR(5) AS codret,
				  INTEGER AS NumeroPoliza
			;     
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(10);
	DEFINE iCodRetSp INTEGER;
	DEFINE iNumeroPoliza INTEGER;
	 
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET iCodRetSp = 0;
	LET iNumeroPoliza=0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 

			RETURN cCodRet,iNumeroPoliza;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/spgenerarpolizanomina.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pFechaActual ='' OR pFechaQuincena = '' OR pUsuarioSistema = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet,iNumeroPoliza;
		END IF;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;

		DELETE FROM "informix".sw_verificastatuspoliza WHERE usuario_insert = pUsuario; 
		INSERT INTO "informix".sw_verificastatuspoliza(usuario_insert, status, total_registros, error_proceso, error, poliza)
		VALUES (pUsuario, 'I', 0, '', '', 0);
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN

			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;
		END IF;

		EXECUTE PROCEDURE bdirech:"informix".spgenerarpolizanomina(pFechaActual,pFechaQuincena,pUsuarioSistema)
		INTO  cCodRet,iNumeroPoliza;
        
          IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00017';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;
		  END IF;

       IF cCodRet ='000' THEN
			LET cCodRet ='00000';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'T', error_proceso ='N', error = cCodRet, poliza = iNumeroPoliza
			WHERE usuario_insert = pUsuario; 		
		END IF;
        IF cCodRet ='00001' THEN
			LET cCodRet ='00003';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;		
		END IF;
        IF cCodRet ='00002' THEN
			LET cCodRet ='01245';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;         
		END IF;
        IF cCodRet ='00003' THEN
			LET cCodRet ='01246';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;		
		END IF;
        IF cCodRet ='00004' THEN
			LET cCodRet ='01241';
			UPDATE "informix".sw_verificastatuspoliza
			SET status = 'E', error_proceso ='S', error = cCodRet
			WHERE usuario_insert = pUsuario; 
			RETURN cCodRet,iNumeroPoliza;      
		END IF;
 
		RETURN cCodRet,iNumeroPoliza;
		
	
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 03/05/2021',
'MODULO: OFI',
'FUNCIONALIDAD: ',
'DESCRIPCION: SPL encargado de ejecutar el sp productivo spgenerarpolizanomina',
'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA MODIFICACIÃN: 21/11/2024',
'DESCRIPCION: Se anexa la secciÃ³n de hilo de espera para la actualizaciÃ³n de estatus a la estructuras sw_verificastatuspoliza.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_bitacoraerror(pUsuario CHAR(9), 
                                                        pIdFuncion CHAR(8), 
                                                        pBandera SMALLINT, 
                                                        pNombreHoja CHAR(120), 
                                                        pNombreCampo CHAR(50), 
                                                        pNumeroFila INTEGER, 
                                                        pDescripcion CHAR(250), 
                                                        pRegistros INTEGER, 
                                                        pRecuperacion INTEGER)
RETURNING CHAR(5)       AS codret,
          CHAR(120)     AS nombreHoja,
          CHAR(50)      AS nombreCampo,
          INTEGER       AS numerofila,
          CHAR(250)     AS descripcion, 
          CHAR(9)       AS usuario,    
          DATE          AS fecha_insert,
          INTEGER       AS total_registros;


    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr          INTEGER;
    DEFINE iRegistro        INTEGER; 
    DEFINE cNombreHoja      CHAR(120);
    DEFINE cNombreCampo     CHAR(50);
    DEFINE iNumerofila      INTEGER;
    DEFINE cDescripcion     CHAR(250);
    DEFINE cUsuario         CHAR(9);
    DEFINE cFecha_insert    DATE;

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET iRegistro        = 0; 
    LET cNombreHoja      = '';
    LET cnombreCampo     = '';
    LET iNumerofila      = 0;
    LET cDescripcion     = '';
    LET cUsuario         = '';
    LET cFecha_insert    = '';

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOSNEW/admintasas/Antonio/sp_admintasas_bitacoraerror.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pBandera = '' OR pBandera IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END IF;

         IF pBandera = '1' AND  (pNombreHoja = ''  OR pNombreCampo = '' OR pNumeroFila IS NULL OR pNumeroFila = '' OR pDescripcion = '') THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
        
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
		END IF;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

        IF pBandera = 1 THEN

            -- Se insertan los registros en la bitacora
            INSERT INTO bdinvers:"informix".sv_admintasas_bitacoraerror(nombreHoja, nombreCampo, numerofila, descripcion, usuario)
            VALUES (pNombreHoja, pNombreCampo, pNumeroFila, pDescripcion, pUsuario);

            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

        ELIF pBandera = 2 THEN
            FOREACH
                SELECT SKIP pRegistros FIRST pRecuperacion nombreHoja, nombreCampo, numerofila, descripcion, usuario, fecha_insert 
                INTO   cNombreHoja, cnombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert
                FROM bdinvers:"informix".sv_admintasas_bitacoraerror
                WHERE usuario= pUsuario
                ORDER BY nombreHoja, numerofila

                LET iRegistro = iRegistro + 1;
                 RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro WITH RESUME;
            END FOREACH

            IF iRegistro = 0 AND pRegistros = 0 THEN
                LET cCodRet = '00017';
                RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

            ELIF iRegistro = 0 AND pRegistros > 0 THEN
                LET cCodRet = '1001';
                RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
            END IF;

        ELIF pBandera = 3 THEN
            IF EXISTS (SELECT 1 FROM bdinvers:"informix".sv_admintasas_bitacoraerror WHERE usuario = pUsuario) THEN
                
                DELETE FROM bdinvers:"informix".sv_admintasas_bitacoraerror 
                WHERE usuario = pUsuario;
            END IF;

            LET cNombreHoja = 'Eliminacion Exitosa';
            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;

        ELIF pBandera = 4 THEN
            SELECT COUNT(*)
            INTO   iRegistro
            FROM bdinvers:"informix".sv_admintasas_bitacoraerror
            WHERE usuario= pUsuario;

            IF iRegistro = 0 THEN
                LET cCodRet = '00017';
            END IF;
            RETURN cCodRet, cNombreHoja, cNombreCampo, iNumerofila, cDescripcion, cUsuario, cFecha_insert, iRegistro;
        END IF;

    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: CARGA DE CAMPAÃAS',
'DESCRIPCION: Procedimiento que se encarga de realizar lo siguiente:', 
'             Bandera 1: Agrega un registro a la bitacora de errores bdinvers:sv_admintasas_bitacoraerror',
'             Bandera 2: consulta todos los registro a la bitacora de errores bdinvers:sv_admintasas_bitacoraerror por medio de un usuario',
'             Bandera 3: Se depura la bitacora de errores por medio de un usuario.',
'             Bandera 4: Consulta el total de registros de la bitacora de errores.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_admintasas_consultabitacora(pUsuario CHAR(9), pIdFuncion CHAR(8), pBandera INTEGER, pFuncionalidad CHAR(1), pFechaDel DATE, pFechaAl DATE, pUsuario_insert CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
RETURNING CHAR(5)                      AS codret,
          DATE                         AS fecha,
          CHAR(12)                     AS hora,
          CHAR(9)                      AS usuario_insert,
          CHAR(20)                     AS funcionalidad,
          CHAR(20)                     AS campo_anterior,
          CHAR(20)                     AS campo_nuevo,
          CHAR(200)                    AS descripcion,
          CHAR(4)                      AS producto,
          CHAR(9)                      AS usuario_modifica,
          INTEGER                      AS total_reg;



    
    DEFINE cCodRet       CHAR(5);
    DEFINE iSqlErr       INTEGER;
    DEFINE dFecha        DATE;
    DEFINE dHora         CHAR(12);
    DEFINE cUsuario      CHAR(9);
    DEFINE cFuncionalidad CHAR(20);
    DEFINE cCampAnterior  CHAR(20);
    DEFINE cCampNuevo    CHAR(20);
    DEFINE cDescripcion   CHAR(200);
    DEFINE cProducto      CHAR(4);
    DEFINE cUsuarioMod    CHAR(9);
    DEFINE iRegistro      INTEGER;

    LET cCodRet          = '00000';
    LET iSqlErr          = 0;
    LET dFecha           = '';
    LET dHora            = '';
    LET cUsuario         = '';
    LET cFuncionalidad   = '';
    LET cCampAnterior    = '';
    LET cCampNuevo       = '';
    LET cDescripcion     = '';
    LET cProducto        = '';
    LET cUsuarioMod      = '';
    LET iRegistro        = 0;

    BEGIN

        ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/RESPALDOSNEW/admintasas/Antonio/sp_admintasas_consultabitacora.out';
		--TRACE ON;

        IF pUsuario = '' OR pIdFuncion = '' OR pRecuperacion IS NULL OR pRegistros IS NULL OR pFechaAl = '' OR pFechaDel = '' OR pBandera = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END IF;

        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
		END IF;

        IF pBandera = 1 THEN
            
            FOREACH 

                SELECT {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)}
				SKIP pRegistros FIRST pRecuperacion fecha, TO_CHAR(hora, '%I:%M:%S %p'), usuario_insert, usuario_mod, funcionalidad, campoAnterior, campoNuevo, descripcion, producto
                INTO dFecha, dHora, cUsuario, cUsuarioMod, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto
                FROM bdinvers:"informix".sv_camp_bitacora
                WHERE fecha BETWEEN pFechaDel AND pFechaAl
                AND usuario_insert = (CASE WHEN pUsuario_insert = '' THEN TRIM(usuario_insert) ELSE TRIM(pUsuario_insert) END)
                AND tipOperacion = (CASE WHEN pFuncionalidad = '' THEN tipOperacion ELSE TRIM(pFuncionalidad) END)
                ORDER BY hora DESC
                
                LET iRegistro = iRegistro + 1;

                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro WITH RESUME;

            END FOREACH

            IF iRegistro = 0 AND pRegistros = 0 THEN
                LET cCodRet = '00017';
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;

            ELIF iRegistro = 0 AND pRegistros > 0 THEN
                LET cCodRet = '1001';
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
            END IF;
        ELIF pBandera = 2 THEN
            --Registrar la descarga del layout 
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAÃAS', 1, "SE HA REALIZADO LA DESCARGA DE LA PLANTILLA", 3000);

            RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;

        ELIF pBandera = 3 THEN
            --Registrar la cancelacion  
            INSERT INTO {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} bdinvers:"informix".sv_camp_bitacora(fecha, hora, usuario_insert, funcionalidad, tipOperacion, descripcion, producto)
            VALUES (TODAY, CURRENT, pUsuario, 'CARGA DE CAMPAÃAS', 1, "SE HA CANCELADO LA CARGA DE ARCHIVO", 3000);

            RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
        
        ELIF pBandera = 4 THEN

                SELECT {+INDEX (bdinvers:"informix".sv_camp_bitacora idx_sv_camp_bitacora)} 
				count(idRegistro)
                INTO iRegistro
                FROM bdinvers:"informix".sv_camp_bitacora
                WHERE fecha BETWEEN pFechaDel AND pFechaAl
                AND usuario_insert = (CASE WHEN pUsuario = '' THEN usuario_insert ELSE TRIM(pUsuario) END)
                AND tipOperacion = (CASE WHEN pFuncionalidad = '' THEN tipOperacion ELSE pFuncionalidad END);
                
                IF iRegistro = 0 THEN
                    LET cCodRet = '00017';
                END IF;
                RETURN cCodRet, dFecha, dHora, cUsuario, cFuncionalidad, cCampAnterior, cCampNuevo, cDescripcion, cProducto, cUsuarioMod, iRegistro;
        END IF;
    END
END PROCEDURE    
DOCUMENT 'AUTOR: JosÃ© Antonio RamÃ­rez Franco',
'FECHA: 02/09/2024',
'MODULO: DEBITO',
'FUNCIONALIDAD: BITACORA DE MOVIMIENTOS',
'DESCRIPCION: Procedimiento que se encarga de consultar los registros de la bitacora los cuales pueden ser por usuario, funcionalidad o un periodo de tiempo',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocalle_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocalle_2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catcalles;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF LENGTH(TRIM(pConsulta)) < 4 THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle = TRIM(pConsulta)
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		ELSE
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(pConsulta) || '%' 
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las calles",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_catalogozona_2(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona,
		CHAR(27) AS nombre_municipio_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	DEFINE cNombreMunicipio CHAR(27);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	LET cNombreMunicipio = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogozona_2.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catzonas;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
					 and nombrezona LIKE '%' || TRIM(pConsulta) || '%'
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedacalle(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedacalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iNumeroCalle, cNombreCalle;
        END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(UPPER(pDescripcion)) || '%' 
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
		END FOREACH;
			
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Se crea procedimiento almacenado para recuperar las calles de acuerdo a la descripcion",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedacalle_totales(pUsuario CHAR(8), pIdFuncion CHAR(10), pDescripcion CHAR(30))
	RETURNING CHAR(5) AS codret,
		INTEGER AS totalRegistros;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedacalle.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iRegistros;
		END IF;

		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iRegistros;
        END IF;
				
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		SELECT COUNT(*)
		INTO iRegistros
		FROM bdinteg:"informix".si_catcalles
		WHERE nombrecalle LIKE '%' || TRIM(UPPER(pDescripcion)) || '%';
			
		IF NVL(iRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iRegistros;
		END IF;
		
		RETURN cCodRet, iRegistros;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Se crea procedimiento almacenado para recuperar las calles de acuerdo a la descripcion",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedazona(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pDescripcion CHAR(30), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedazona.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iIdNumeroColonia, cNombreZona;
        END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		FOREACH					
			SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona
            INTO iIdNumeroColonia, cNombreZona
            FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
            WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
			and lpad(a.codigopostalzona,5,'0') = b.d_codigo
	        and nombrezona LIKE '%' || TRIM(UPPER(pDescripcion)) || '%'
            and TRIM(a.nomzona_spmx) = b.d_asenta
            and TRIM(a.mnpio_spmx) = b.d_mnpio
            GROUP BY  a.numerocolonia, a.nombrezona ORDER BY a.nombrezona ASC
				
			LET iNoRegistros = iNoRegistros + 1;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona WITH RESUME;
		END FOREACH;
			
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
		
		IF iNoRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Procedimiento almacenado encargado de recuperar las zonas",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_cli_busquedazona_totales(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pDescripcion CHAR(30))
	RETURNING CHAR(5) AS codret,
		SMALLINT AS totalRegistro;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iNoRegistros = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cli_busquedazona.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pDescripcion = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pIdUsuario, pIdFuncion) INTO cCodRet;
        IF cCodRet <> '00000' THEN
            RETURN cCodRet, iNoRegistros;
        END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
						
		SELECT COUNT(*) 
        INTO iNoRegistros
        FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
        WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
		and lpad(a.codigopostalzona,5,'0') = b.d_codigo
	    and nombrezona LIKE '%' || TRIM(UPPER(pDescripcion)) || '%'
        and TRIM(a.nomzona_spmx) = b.d_asenta
        and TRIM(a.mnpio_spmx) = b.d_mnpio;
			
		IF NVL(iNoRegistros,0) = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		RETURN cCodRet, iNoRegistros;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Veronica Sanchez",
"FECHA: 04/02/2025",
"DESCRIPCION: Procedimiento almacenado encargado de recuperar las zonas",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_totalesarqueosucucaja(pUsuario CHAR(8),
                                                     pIdFuncion CHAR(10),
                                                     pIdPlaza CHAR(3),
                                                     pIdSucursal CHAR(4),
													 pFechaInicial DATE,
                                                     pFechaFinal DATE)

		RETURNING CHAR(5) AS codret,
				  INTEGER AS totalRegistros;

		DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
		DEFINE iTotalRegistros INTEGER;
		DEFINE cSucursal CHAR(4);
		DEFINE cNombreSuc CHAR(40);
	    DEFINE cDescPlazaCajaGeneralArq CHAR(40); 
		DEFINE fCantidad_1 FLOAT;
		DEFINE fCantidad_2 FLOAT;
		DEFINE fCantidad_3 FLOAT;
		DEFINE fCantidad_4 FLOAT;
		DEFINE fCantidad_5 FLOAT;
		DEFINE fCantidad_6 FLOAT;
		DEFINE fCantidad_7 FLOAT;
		DEFINE mSaldoTotalArq MONEY(14,2); 
		DEFINE dFechaArq DATE; 
		DEFINE cIdCajeroPrincArq CHAR(8);	
		DEFINE iTotSucursales INTEGER;
		DEFINE iSucAbrieron INTEGER;
		DEFINE iSucNoAbrio INTEGER; 
		DEFINE iSucCerraron INTEGER;
		DEFINE iSucPenCerrar INTEGER; 	
		DEFINE mSaldoTotal MONEY(14,2);
		DEFINE mTotalDotaciones MONEY(14,2); 
		DEFINE cIdDivisaArq CHAR(2); 
		DEFINE cDescDivisaArq CHAR(30);	
		DEFINE cNombreCajeroArq CHAR(45);

		LET cCodRet = '00000';
        LET iSqlErr = 0;
		LET iTotalRegistros =0;	
		LET cSucursal = '';
		LET cNombreSuc = '';
		LET cDescPlazaCajaGeneralArq = '';
	    LET fCantidad_1 =0;
		LET fCantidad_2 =0;
		LET fCantidad_3 =0;
		LET fCantidad_4 =0;
		LET fCantidad_5 =0;
		LET fCantidad_6 =0;
		LET fCantidad_7 =0;
		LET mSaldoTotalArq = 0.00; 
		LET dFechaArq = ''; 
		LET cIdCajeroPrincArq = '';
		LET iTotSucursales = 0;
		LET iSucAbrieron = 0;
		LET iSucNoAbrio = 0; 
		LET iSucCerraron = 0;
		LET iSucPenCerrar = 0;
		LET iTotalRegistros = 0;
		LET	mSaldoTotal = 0.00; 
		LET mTotalDotaciones = 0.00;
		LET cIdDivisaArq='';
		LET cDescDivisaArq ='';
		LET cNombreCajeroArq ='';
		
		BEGIN

			ON EXCEPTION SET iSqlErr
                LET cCodRet = iSqlErr;
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
                RETURN cCodRet, iTotalRegistros;
			END EXCEPTION;

			--SET DEBUG FILE TO '/tmp/mfinis/sp_totalesarqueosucucaja.out';
            --TRACE ON;

            IF pUsuario = '' OR pIdFuncion = '' OR pIdPlaza = '' OR pFechaInicial IS NULL OR pFechaFinal IS NULL THEN
				LET cCodRet = '00003';
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotalRegistros;
            END IF;

            -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
            EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
            IF cCodRet <> '00000' THEN
				UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
				SET status = 'E', total_registros = iTotalRegistros, error_proceso = 'S', error = cCodRet WHERE usuario_insert = pUsuario;
				RETURN cCodRet, iTotalRegistros;
			END IF;
			
			SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
								
			-- TRATAMIENTO POR VOLUMETRIA 
			DELETE FROM bdicnweb:"informix".sw_verificastatusarqueosucaja WHERE usuario_insert = pUsuario;
			INSERT INTO bdicnweb:"informix".sw_verificastatusarqueosucaja(usuario_insert,total_registros,status,error_proceso,error)
			VALUES(pUsuario, iTotalRegistros,'I','', ''); 
			
			--BORRA DATOS TABLA TEMPORAL 
			DELETE FROM "informix".sw_cg_arqueosucajatmp WHERE usuario = pUsuario;
			
			-- OBTIENE TOTALES SUCURSALES
			SELECT COUNT(*) INTO iTotSucursales
			FROM bdinteg:'informix'.si_sucursales WHERE tpo_sucursal = 'S';	
			
			SELECT COUNT(*) INTO iSucAbrieron 
			FROM bdisuc:'informix'.ss_pase_sucursal WHERE suc_abrio = 1 AND fecha_pase BETWEEN pFechaInicial AND pFechaFinal;			
			
			SELECT COUNT(*) INTO iSucCerraron 
			FROM bdisuc:'informix'.ss_pase_sucursal WHERE suc_cerro = 1 AND fecha_pase BETWEEN pFechaInicial AND pFechaFinal;
			
			LET iSucNoAbrio = iTotSucursales - iSucAbrieron;
			LET iSucPenCerrar = iSucAbrieron - iSucCerraron;
			
			-- OBTIENE SALDOS (TOTAL Y DOTACIONES)
			IF pIdPlaza = '000' THEN
				SELECT NVL(SUM(saldo_total),0) AS saldo_total INTO mSaldoTotal
				FROM bdisuc:'informix'.ss_saldossuc WHERE fecha >= pFechaInicial AND fecha <= pFechaFinal;
			ELSE
				SELECT NVL(SUM(sal.saldo_total),0) AS saldo_total INTO mSaldoTotal
				FROM bdisuc:'informix'.ss_saldossuc AS sal INNER JOIN bdinteg:'informix'.si_sucursales AS suc ON suc.sucursal = sal.sucursal
				INNER JOIN bdinteg:'informix'.si_plazas_cajagen AS pla ON suc.plaza_cajagen = pla.codigo_plaza AND pla.codigo_plaza = pIdPlaza
				AND sal.sucursal = CASE WHEN pIdSucursal = '0000' OR pIdSucursal = '' THEN sal.sucursal ELSE pIdSucursal END
				AND sal.fecha BETWEEN pFechaInicial AND pFechaFinal;
			END IF;
			
			LET mTotalDotaciones = mTotalDotaciones + mSaldoTotal;
							
			-- DETALLE CONSULTA
			IF pIdPlaza <> '000' AND pIdPlaza <> ''  AND pIdSucursal <> '0000' AND pIdSucursal <> ''  THEN
		
                	FOREACH
						    SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'') 
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							WHERE a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S' AND plaza_cajagen =pIdPlaza ) AND a.sucursal = pIdSucursal AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal 
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
	 
                      END FOREACH;
            
			ELSE
				
				IF pIdPlaza <> '000' AND pIdPlaza <> ''  THEN
			 
                	FOREACH
							SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S'  AND plaza_cajagen =pIdPlaza ) AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
						    ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq); 
							
                      END FOREACH;
	
				ELSE 
    				IF pIdSucursal <> '0000' AND pIdSucursal <> '' THEN
				 
                	FOREACH
							SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S') AND a.sucursal = pIdSucursal AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
							
                      END FOREACH;

					ELSE
                          
					FOREACH
						    SELECT a.fecha,b.sucursal,b.nombre,c.descripcion,a.cantidad_1,a.cantidad_2, a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.saldo_total,NVL(a.cajero_principal,''),NVL(a.divisa,'')  
							INTO dFechaArq, cSucursal, cNombreSuc,cDescPlazaCajaGeneralArq, fCantidad_1,fCantidad_2,fCantidad_3,fCantidad_4,fCantidad_5,fCantidad_6, fCantidad_7,mSaldoTotalArq, cIdCajeroPrincArq,cIdDivisaArq
							FROM bdisuc:ss_saldossuc a
							INNER JOIN bdinteg:si_sucursales b ON a.sucursal = b.sucursal
							INNER JOIN bdinteg:si_plazas_cajagen c ON   b.plaza_cajagen = c.codigo_plaza
							AND a.sucursal IN (SELECT sucursal FROM bdinteg:'informix'.si_sucursales WHERE empresa = '001' AND tpo_sucursal = 'S') AND a.fecha >= pFechaInicial  AND a.fecha <= pFechaFinal
							ORDER BY a.fecha
							-- OBTIENE DESCRIPCIN DIVISA
							IF cIdDivisaArq IS NOT NULL OR cIdDivisaArq <> '' THEN
								SELECT NVL(descripcion,'') INTO cDescDivisaArq 
								FROM bdinteg:'informix'.si_divisas WHERE divisa = cIdDivisaArq;
							END IF;
					
							-- OBTIENE NOMBRE CAJERO
							IF cIdCajeroPrincArq IS NOT NULL OR cIdCajeroPrincArq <> '' THEN
								SELECT NVL(nombre,'') INTO cNombreCajeroArq 
								FROM bdinteg:'informix'.si_ejecut 
								WHERE ejecutivo = cIdCajeroPrincArq; 				
							END IF;	
							
							INSERT INTO informix.sw_cg_arqueosucajatmp(usuario, fecha, idsuc, nomsuc, descplazagen, cantidad_1, cantidad_2, cantidad_3, cantidad_4, cantidad_5, cantidad_6, cantidad_7, saldototal, idcajeroprinc,totsucursales, sucabrieron, sucnoabrio, succerraron, sucpencerrar,TotalDotaciones,SaldoTotalD,descdivisa,nomcajero)  
							VALUES(pUsuario, dFechaArq, cSucursal, cNombreSuc, cDescPlazaCajaGeneralArq, fCantidad_1, fCantidad_2, fCantidad_3, fCantidad_4, fCantidad_5, fCantidad_6, fCantidad_7, mSaldoTotalArq, cIdCajeroPrincArq, iTotSucursales, iSucAbrieron, iSucNoAbrio, iSucCerraron, iSucPenCerrar,mTotalDotaciones,mSaldoTotal,cDescDivisaArq,cNombreCajeroArq);
						    
                      END FOREACH;
					END IF;
				END IF;
			END IF;

			
		SELECT COUNT(*) 
		INTO iTotalRegistros
		FROM "informix".sw_cg_arqueosucajatmp
		WHERE usuario = pUsuario;
	
        
		IF NVL(iTotalRegistros,0) = 0 THEN
		LET cCodRet = '00017';
		UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
		SET status = 'T', total_registros = iTotalRegistros, error_proceso = 'N', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iTotalRegistros;
		END IF;
		
		UPDATE bdicnweb:"informix".sw_verificastatusarqueosucaja
        SET status = 'T', total_registros = iTotalRegistros, error_proceso = 'N', error = cCodRet WHERE usuario_insert = pUsuario;
		RETURN cCodRet, iTotalRegistros;
			

		END;

END PROCEDURE
DOCUMENT 'AUTOR: Daniel Reyes Guillen',
'FECHA: 05/02/2021',
'DESCRIPCION: SPL que consulta el no total de registros para el llenado del Listado Arqueo Sucursales.',
'MODULO: Caja General',
'FUNCIONALIDAD: Arqueo de Sucursales Caja General',
'AUTOR: Daniel Reyes Guillen',
'FECHA: 23/07/2021',
'DESCRIPCION: Se aplica tratamiento por volumetria y ajuste de campos',
'BD: bdicnweb',
'AUTOR: Gilberto Fco. Naranjo Valles',
'FECHA: 08/04/2025',
'DESCRIPCION: Se eliminan las directivas y se crean nuevos index en la bdisuc',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_desbloqueocuentacre(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pTipo SMALLINT, pAreaPersonaSolicita CHAR(150), pMotivoBloqueo CHAR(150))
        RETURNING CHAR(5) AS codret;
        
        DEFINE cCodRet CHAR(5);
        DEFINE iSqlErr INTEGER;
        DEFINE cCodRetSp CHAR(6);
        DEFINE iCodRetSp SMALLINT;
        DEFINE cMensajeRet CHAR(80);
        DEFINE cEmpresa CHAR(3);
        
        LET cCodRet = '00000';
        LET iSqlErr = 0;
        LET cCodRetSp = '';
        LET iCodRetSp = 0;
        LET cMensajeRet = '';
        LET cEmpresa = '001';
        
        BEGIN
        
                ON EXCEPTION SET iSqlErr
                        LET cCodRet = iSqlErr;
                        RETURN cCodRet;
                END EXCEPTION;
                
                --SET DEBUG FILE TO '/tmp/mfinis/sp_desbloqueocuentacre.out';
                --TRACE ON;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pTipo IS NULL OR pAreaPersonaSolicita = '' OR pMotivoBloqueo = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '06', '1') INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;
                
                IF pTipo NOT IN (1, 2) THEN
                        LET cCodRet = '00249';
                        RETURN cCodRet;
                END IF;
                
                --EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, pCuenta, pUsuario, pTipo) INTO cCodRetSp, cMensajeRet;
				EXECUTE PROCEDURE bdicred:'informix'.sp_desbloqueocuenta(cEmpresa, pCuenta, pUsuario, pTipo, pAreaPersonaSolicita, pMotivoBloqueo) INTO cCodRetSp, cMensajeRet;
                LET iCodRetSp = cCodRetSp::INTEGER;
                
                IF iCodRetSp < 0 THEN
                        RAISE EXCEPTION iCodRetSp, 0, 'ERROR EN LA EJECUCION DEL SP sp_desbloqueocuenta';
                ELIF iCodRetSp = 5 THEN -- EL CREDITO NO EXISTE EN LA BASE DE DATOS
                        LET cCodRet = '00009';
                ELIF iCodRetSp = 6 THEN -- LA CUENTA YA ESTA DESBLOQUEADA
                        LET cCodRet = '00032';
                ELIF iCodRetSp = 11 THEN -- LA CUENTA SE ENCUENTRA SALDADA
                        LET cCodRet = '00250';
                ELIF iCodRetSp = 7 THEN -- LA CUENTA SE ENCUENTRA EN CARTERA VENDIDA
                        LET cCodRet = '00033';
                ELIF iCodRetSp = 8 THEN -- CREDITO BLOQUEADO MANUALMENTE
                    LET cCodRet = '00018';
                ELIF iCodRetSp = 9 THEN -- 'NO ES POSIBLE DESBLOQUEAR, EL CRÃDITO HA SIDO BLOQUEADO MANUALMENTE'
                    LET cCodRet = '01128';
                ELIF iCodRetSp = 10 THEN -- BLOQUEO ACTUAL NO ES VALIDO, FAVOR DE VERIFICAR
                        LET cCodRet = '00251';
                END IF;
                
                RETURN cCodRet;
        
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 18/03/2014',
'DESCRIPCION: Desbloquea una cuenta de credito',
'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2015',
'DESCRIPCION: Se agregan los campos de area y justificacion',
'AUTOR: Carlos Macias',
'FECHA: 07/04/2025',
'DESCRIPCION: Se separan flags 8 y 9 con cÃ³digos diferentes, flag 9 ahora usa 01128',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cnsif_consultatotalmovtosdiarioscta_2(cID_USUARIOC char(8),cID_FUNCIONC CHAR(10),cNUMCUENTA CHAR(20),dPERIODOI DATE,dPERIODOF DATE, cSISTEMACUENTA CHAR(20),pUsuario CHAR(8),cSuc CHAR(4),mImporte MONEY(14,2))
				returning CHAR(5)  AS Cod_Retorno,
						  INTEGER AS numero_registros;

DEFINE iexiste                INT;
DEFINE cCodRet                CHAR(5);
DEFINE iSql_err           INT;                                  
--SISTEMA DE CUENTA 01 VARIABLES
DEFINE dFecha               DATE;
DEFINE dHora                DATETIME HOUR to FRACTION(3);
DEFINE cTransaccion          CHAR(4);
DEFINE cD_Transaccion     CHAR(50);
DEFINE mMonto               MONEY(14,2);
DEFINE cNaturaleza          CHAR(1);
DEFINE mSaldo                MONEY(14,2);
DEFINE cReferencia           CHAR(40);
DEFINE cReversos          CHAR(1);
DEFINE cReversados          CHAR(1);
DEFINE cSucursal           CHAR(4);
DEFINE cFolio                CHAR(16);
DEFINE cProcedencia          CHAR(20);
DEFINE cD_Procedencia     CHAR(50);
DEFINE dPeriodoI_1          DATE;
DEFINE dPeriodoF_1          DATE;
DEFINE sNUMSERIAL       INT8;
DEFINE sNumSecuencia    INT8;
DEFINE cUsuario         CHAR(8);
DEFINE cReferencia23    CHAR(23);
--SISTEMA DE CUENTA 06 VARIABLES
DEFINE cNumtarjeta          CHAR(20);
--VARIABLES PARA FECHAS HISTORICAS
DEFINE cconsmovhis      CHAR(10);
DEFINE cconsmovhisold   CHAR(10);
DEFINE cconsmovhisold2  CHAR(10);
DEFINE cconsmovhisold3  CHAR(10);
DEFINE cconsmovhisold4  CHAR(10);
--VARIABLES DE PAGINACION
DEFINE iCont            INT;
--VARIABLE PARA LA EMPRESA
DEFINE pEmpresa     CHAR(3);
DEFINE cCodfun          CHAR(3);
DEFINE cCodref          INTEGER;
DEFINE iExisteCta       INT;
DEFINE iKiosko			INT;
DEFINE iTotal INTEGER; 
DEFINE iResta1 INTEGER;
DEFINE iResta2 INTEGER;
DEFINE iRegTotal INTEGER;
DEFINE iRegResta INTEGER;

--inicializando variables
LET  iexiste = 0;
LET  iExisteCta = 0;
LET cCodRet = "00000";
LET iSql_err = 0 ;    
LET dFecha               = "";
LET dHora                = "";
LET cTransaccion     = "";
LET cD_Transaccion     = "";
LET mMonto               = 0;
LET cNaturaleza          = "";
LET mSaldo                = 0;
LET cReferencia          = "";
LET cReversos          = "";
LET cReversados          = "";
LET cSucursal           = "";
LET cFolio                = "";
LET cProcedencia     = "";
LET cD_Procedencia     = "";
LET dPeriodoI_1          = "";
LET dPeriodoF_1          = "";
LET sNUMSERIAL      =  0;
LET sNumSecuencia     =  0;
LET cUsuario        = "";
LET cReferencia23   = "";
--SISTEMA DE CUENTA 06 VARIABLES
LET cNumtarjeta     = "";
--VARIABLES PARA FECHAS HISTORICAS
LET cconsmovhis     = '';
LET cconsmovhisold  = '';
LET cconsmovhisold2 = '';
LET cconsmovhisold3 = '';
LET cconsmovhisold4 = '';
--VARIABLES DE PAGINACION
LET iCont       = 0;
LET pEmpresa   = '001';
LET cCodfun               ='';
LET cCodref               =0;
LET iKiosko               =0;
LET iTotal = 0; 
LET iResta1 = 0;
LET iResta2 = 0;
LET iRegTotal = 0;
LET iRegResta = 0;

BEGIN
     ON EXCEPTION SET iSql_err
          IF iSql_err <> 0 THEN
               LET cCodRet = iSql_err;
               RETURN cCodRet, iCont;
          END IF;
     END EXCEPTION;
                
	--SET DEBUG FILE TO "/tmp/mfinis/sp_cnsif_consultatotalmovtosdiarioscta_2.out";
	--TRACE ON;
                  
	IF cID_FUNCIONC = 'SKI002' THEN
		LET iKiosko = 1;
	END IF;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;	
	
	IF cSISTEMACUENTA = 'CAPTACION' THEN

		SELECT valor
		INTO cconsmovhis
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'fechcon_movhis';

		SELECT valor
		INTO cconsmovhisold
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechIniCon_movhis_ol';

		SELECT valor
		INTO cconsmovhisold2
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld2';

		SELECT valor
		INTO cconsmovhisold3
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'vfechconmovhisold3';

		SELECT valor
		INTO cconsmovhisold4
		FROM bdicheq:"informix".sc_param
		WHERE empresa = pEmpresa
		AND codparam = 'FechaIniMovhisOld4';
		
		IF dPERIODOF = TODAY THEN
			SELECT COUNT(MO.cuenta)
			INTO iexiste
			FROM bdicheq:"informix".sc_movdia MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt = dPERIODOF AND MO.empresa='001' AND MO.cuenta = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = NVL(iexiste,0);
		END IF;

		IF (dPERIODOI < TODAY AND dPERIODOF >= cconsmovhis) THEN
			SELECT COUNT(MO.cuenta) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhis AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
  
			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
		IF (dPERIODOI < cconsmovhis AND dPERIODOF >= cconsmovhisold) THEN
			SELECT COUNT(MO.cuenta) 
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.numero = MO.transacc
			AND TR.sistema = '01'
			AND TR.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TR.se_emite_edocta END
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhisold AND MO.fech_alt < cconsmovhis 
			AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		IF (dPERIODOI < cconsmovhisold AND dPERIODOF >= cconsmovhisold2) THEN
			SELECT {+INDEX (bdicheq:sc_movhis_old2 idx_movhis_old2)} COUNT(MO.cuenta)
			INTO iexiste
			FROM bdicheq:"informix".sc_movhis_old2 MO
			RIGHT JOIN bdinteg:si_transacc TR
			ON TR.empresa = '001'
			AND TR.numero = MO.transacc
			AND TR.sistema = '01'
			WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
			AND MO.fech_alt >= cconsmovhisold2
			AND MO.fech_alt < cconsmovhisold AND MO.empresa = '001' AND MO.cuenta  = cNUMCUENTA
			AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
			SELECT COUNT(cuenta)
			INTO iExisteCta
			FROM bdicheq:sc_maechq 
			WHERE cuenta  = cNUMCUENTA
			AND producto IN ('1200', '9901', '1600', '2200', '2600');
		IF iExisteCta = 0 OR cID_FUNCIONC = 'ROA200' THEN
			IF (dPERIODOI < cconsmovhisold2 AND dPERIODOF >= cconsmovhisold3) THEN
				SELECT {+INDEX (bdicheq:sc_movhis_old3 idx_movhis_old3)} COUNT(MO.cuenta) 
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old3 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
				AND MO.fech_alt >= cconsmovhisold3 AND MO.fech_alt < cconsmovhisold2 
				AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 

				LET iCont = iCont + NVL(iexiste,0);

			END IF;

			IF  (dPERIODOI < cconsmovhisold3 AND dPERIODOF >= cconsmovhisold4) THEN
				SELECT COUNT(MO.cuenta)
				INTO iexiste
				FROM bdicheq:"informix".sc_movhis_old4 MO
				RIGHT JOIN bdinteg:si_transacc TR
				ON TR.empresa = '001'
				AND TR.numero = MO.transacc
				AND TR.sistema = '01'
				WHERE MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF 
				AND MO.fech_alt >= cconsmovhisold4 AND MO.fech_alt < cconsmovhisold3
				AND MO.empresa='001' AND MO.cuenta  = cNUMCUENTA
				AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END; 
			
				LET iCont = iCont + NVL(iexiste,0);
			END IF;
		END IF;
		
		IF TRIM(SUBSTRING(cNUMCUENTA FROM 1 FOR 1)) = '8' THEN
			SELECT COUNT(cuenta)
			INTO iexiste
			FROM bditransfer:"informix".tf_success_transac
			WHERE fecha_alt < to_date('20/03/2015','%d/%m/%Y') 
			AND fecha_alt BETWEEN dPERIODOI AND dPERIODOF AND cuenta  = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END; 

			LET iCont = iCont + NVL(iexiste,0);
		END IF;
		
		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		IF (iCont>=1001 AND cID_FUNCIONC = 'ROA200')  THEN
			RETURN "00958", 0;
		ELSE 
			RETURN cCodRet, iCont;
		END IF;

	ELIF cSISTEMACUENTA = 'CREDITO' THEN
		SELECT COUNT(num_credito)
		INTO iExisteCta
		FROM bdicred:sd_maecred
		WHERE empresa = '001' AND num_credito = cNUMCUENTA;
		
		IF NVL(iExisteCta,0) > 0 THEN
			SELECT {+INDEX (bdicred:sd_movdia mov4)} COUNT(num_credito)
			INTO iexiste
			FROM bdicred:sd_movdia MO
			LEFT JOIN bdicred:sd_transfun TR
			ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
			RIGHT JOIN bdinteg:si_transacc TS
			ON TS.empresa = '001'
			AND TS.numero = TR.transacc
			AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
			WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
			AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
			AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
			AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			IF iexiste  = 0 THEN
				SELECT {+INDEX (bdicred:sd_movhis inx_movhis4)} COUNT(num_credito)
				INTO iexiste
				FROM bdicred:sd_movhis MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				IF NVL(iexiste,0)  = 0 THEN
					SELECT {+INDEX (bdicred:sd_movhis_new inx_movhis4_new)} COUNT(num_credito)
					INTO iexiste
					FROM bdicred:sd_movhis_new MO
					LEFT JOIN bdicred:sd_transfun TR
					ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
					RIGHT JOIN bdinteg:si_transacc TS
					ON TS.empresa = '001'
					AND TS.numero = TR.transacc
					AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
					WHERE MO.empresa='001' AND MO.num_credito = cNUMCUENTA AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF
					AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
					AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
					AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				END IF;
			END IF;
		ELSE
			SELECT COUNT(num_credito)
			INTO iexiste
			FROM bdicred:sd_movdiacrd
			WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
			AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
			AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
			AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;
			IF NVL(iexiste,0)  = 0 THEN
				SELECT COUNT(num_credito)
				INTO iexiste
				FROM bdicred:sd_movhiscrd
				WHERE empresa='001' AND fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND num_credito = cNUMCUENTA 
				AND monto = CASE WHEN mImporte = 0 THEN monto ELSE mImporte END
				AND sucursal = CASE WHEN cSuc = "" THEN sucursal ELSE cSuc END
				AND usuario = CASE WHEN pUsuario = "" THEN usuario ELSE pUsuario END;     
			END IF;
		END IF;
		
		IF NVL(iexiste,0)  = 0 THEN
		   LET cCodRet = "00039";
		   RETURN cCodRet, iCont;
		END IF;
		
		--LET iCont = iexiste;
		
		--RETURN cCodRet, iCont;
		
		/*-INICIO-*/
		
		IF NVL(iExisteCta,0) > 0 THEN
			--FOREACH
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movdia MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
				
			--UNION
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhis  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
				
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			--UNION 
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhis_new  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				RIGHT JOIN bdinteg:si_transacc TS
				ON TS.empresa = '001'
				AND TS.numero = TR.transacc
				AND TS.se_emite_edocta = CASE WHEN iKiosko = 1 THEN 'S' ELSE TS.se_emite_edocta END
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			
			--END FOREACH;

			LET iCont = iRegTotal - iRegResta;
			RETURN cCodRet, iCont;
			
			
		
		ELSE
			--FOREACH
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movdiacrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);				
			--UNION
				SELECT COUNT(*) AS total,
				SUM(CASE WHEN (MO.codigo_fun = '001' AND MO.codigo_ref IN (1,2,3)) THEN 1 ELSE 0 END) AS resta1,
				SUM(CASE WHEN (MO.codigo_fun = '002' AND MO.codigo_ref = 1) THEN 1 ELSE 0 END) AS resta2
				INTO iTotal, iResta1, iResta2
				FROM bdicred:sd_movhiscrd  MO
				LEFT JOIN bdicred:sd_transfun TR
				ON TR.empresa = '001' AND TR.codigo_fun = MO.codigo_fun AND TR.codigo_ref = MO.codigo_ref
				WHERE MO.empresa='001' AND MO.fecha_mov BETWEEN dPERIODOI AND dPERIODOF AND MO.num_credito = cNUMCUENTA 
				AND MO.monto = CASE WHEN mImporte = 0 THEN MO.monto ELSE mImporte END
				AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;

				LET iRegTotal = iRegTotal + NVL(iTotal,0); 
				LET iRegResta = iRegResta + NVL(iResta1,0) + NVL(iResta2,0);
			
			--END FOREACH;

			LET iCont = iRegTotal - iRegResta;
			RETURN cCodRet, iCont;
			
			
		END IF;
		
		/*-FIN-*/
		
	ELIF cSISTEMACUENTA = 'INVERSIONES' THEN
		
		  SELECT COUNT(*) INTO iexiste
			   FROM bdinvers:sv_maeinv MC
			   LEFT JOIN bdinvers:sv_movdia MO
					ON MC.cuenta = MO.cuenta
			   LEFT JOIN bdinteg:si_transacc TR
					ON MO.transacc = TR.numero 
			   WHERE MO.cuenta = cNUMCUENTA
				   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
				   AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				   AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				   AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;
			
			LET iCont = NVL(iexiste,0);				
			
			   SELECT COUNT(*) INTO iexiste
			   FROM bdinvers:sv_maeinv MC
			   LEFT JOIN bdinvers:sv_movhis MO
					ON MC.cuenta = MO.cuenta
			   LEFT JOIN bdinteg:si_transacc TR
					ON MO.transacc = TR.numero 
			   WHERE MO.cuenta = cNUMCUENTA
				   AND MO.fech_alt BETWEEN dPERIODOI AND dPERIODOF
				   AND MO.monto_tot = CASE WHEN mImporte = 0 THEN MO.monto_tot ELSE mImporte END
				   AND MO.sucursal = CASE WHEN cSuc = "" THEN MO.sucursal ELSE cSuc END
				   AND MO.usuario = CASE WHEN pUsuario = "" THEN MO.usuario ELSE pUsuario END;

			LET iCont = NVL(iCont,0) + NVL(iexiste,0);

		IF iCont  = 0 THEN
			LET cCodRet = "00039";
			RETURN cCodRet, iCont;
		END IF;

		RETURN cCodRet, iCont;
		
		
	END IF
END
END PROCEDURE
DOCUMENT
"AutOR : Oscar Flores Conde",
"FUNCIONAMIENTO: Este sp realizara la consulta de numero de registros que regresara la busqueda por tipo de cuenta, dependiendo de tipo de cuenta regresara los datos correspondientes, para captacion o cuenta de cheques, para cuentas tipo credito 06 que seran de credito y las cuentas tipo 03 que son de  tipo inversiones",
"FECHA : 0-0-2012",
"Autor : Martha Salgado Mendoza",
"Descripciï¿½n: Se agrega parametro de entrada pMaxNumeroRegistros, validaciï¿½n total de registros > pMaxNumeroRegistros, modificaciï¿½n al sql que obtiene el total de reg para inversiones",
"Fecha :24/10/2017",
"Autor : L. Montserrat Leï¿½n Amador",
"Descripciï¿½n: Se realiza clon de spl para eliminar variables pMaxNumeroRegistros y pReversado ya que dichos parï¿½metros no son necesarios para obtener el nï¿½mero total de registros.",
"Fecha : 11/12/2017",
"Autor : L. Montserrat Leï¿½n Amador",
"Descripciï¿½n: Se modifica spl para optimizar el cï¿½lculo del nï¿½mero total de registros.",
"Fecha : 08/01/2018",
"BD    : bdicnweb",
"VER   : 1.0";

CREATE PROCEDURE "informix".sp_catalogocalle_2(pUsuario CHAR(8), pIdFuncion CHAR(10), pConsulta CHAR(30), pCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		INTEGER AS numero_calle,
		CHAR(30) AS nombre_calle;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iNumeroCalle INTEGER;
	DEFINE cNombreCalle CHAR(30);
	DEFINE iTotalReg INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iRegistros = 0;
	LET iNumeroCalle = 0;
	LET cNombreCalle = '';
	LET iTotalReg = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocalle_2.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catcalles;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;	
		
		
		IF LENGTH(TRIM(pConsulta)) < 4 THEN
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle
			INTO iNumeroCalle, cNombreCalle
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle = TRIM(pConsulta)
			ORDER BY nombrecalle ASC
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		ELSE
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 3;
			FOREACH
			
			SELECT a.numerocalle, a.nombrecalle 
			INTO iNumeroCalle, cNombreCalle 
			FROM(
			SELECT numerocalle, nombrecalle
			FROM bdinteg:"informix".si_catcalles
			WHERE numerocalle = (SELECT numerocalle FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND secuencia = 
			                     (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND tipo_dir = '1'))
			ORDER BY nombrecalle ASC )a
			UNION ALL
			SELECT b.numerocalle, b.nombrecalle 
			FROM (
			SELECT SKIP pRegistros FIRST pRecuperacion numerocalle, nombrecalle 
			FROM bdinteg:"informix".si_catcalles
			WHERE nombrecalle LIKE '%' || TRIM(pConsulta) || '%' 
			ORDER BY nombrecalle ASC ) b
			
			LET iRegistros = iRegistros + 1;
			RETURN cCodRet, iNumeroCalle, cNombreCalle WITH RESUME;
			
			END FOREACH;
		END IF;
		
		IF iRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		ELIF iRegistros = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, iNumeroCalle, cNombreCalle;
		END IF;
		
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las calles",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_catalogozona_2(pIdUsuario CHAR(8), pIdFuncion CHAR(10), pIdCiudadCoppel SMALLINT, pTipoConsulta SMALLINT, pConsulta CHAR(30), pCliente CHAR(20), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		SMALLINT AS numero_colonia,
		CHAR(32) AS nombre_zona,
		CHAR(27) AS nombre_municipio_zona;
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iExiste INTEGER;
	DEFINE iNoRegistros INTEGER;
	DEFINE iIdNumeroColonia SMALLINT;
	DEFINE cNombreZona CHAR(32);
	DEFINE cNombreMunicipio CHAR(27);
	DEFINE iTotalReg INTEGER;
	DEFINE cCiudad INTEGER; 
	DEFINE cNumColonia INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET iExiste = 0;
	LET iNoRegistros = 0;
	LET iIdNumeroColonia = 0;
	LET cNombreZona = '';
	LET cNombreMunicipio = '';
	LET iTotalReg = 0;
	LET cCiudad = 0; 
	LET cNumColonia = 0;
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogozona_2.out';
		--TRACE ON;
		
		IF pIdUsuario = '' OR pIdFuncion = '' OR pIdCiudadCoppel IS NULL OR pTipoConsulta IS NULL OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		-- VALIDACIÃN DE LOS PARAMETROS DE PAGINACIÃN
		IF pRegistros < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta NOT IN (1,2) THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pTipoConsulta = 2 AND pConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		IF pRegistros >= 0 AND pRegistros < 100 THEN
			IF pRecuperacion = pRegistros THEN
				LET iTotalReg = 100 - pRecuperacion;
				IF iTotalReg < pRecuperacion THEN
					LET pRecuperacion = iTotalReg;
				END IF;
			END IF;
		ELSE
			LET cCodRet = '1001';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		-- VALIDAMOS QUE LA TABLA TENGA DATOS
		SELECT COUNT(*)
		INTO iExiste
		FROM bdinteg:"informix".si_catzonas;
		
		IF iExiste = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
		END IF;
		
		--CONSULTA CIUDAD Y COLONIA
		SELECT numerociudad, numerocolonia 
		INTO  cCiudad, cNumColonia
		FROM bdinteg:"informix".si_direcciones_actual
		WHERE numcte = pCliente
		AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:"informix".si_direcciones_actual WHERE numcte = pCliente AND tipo_dir = '1');
		
		IF pTipoConsulta = 1 THEN -- Tipo de consulta general
			FOREACH	
			
                    SELECT  a.numerocolonia, a.nombrezona,a.municipiozona 
                     INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                      FROM (
					   SELECT numerocolonia, nombrezona,municipiozona
                       FROM bdinteg:"informix".si_catzonas
                       WHERE numerociudad = cCiudad 
                       AND numerocolonia = cNumColonia) a
				     UNION ALL
					  SELECT   b.numerocolonia, b.nombrezona,b.municipiozona 
					  FROM (
					   SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                       FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                       WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					   and lpad(a.codigopostalzona,5,'0') = b.d_codigo
                       and TRIM(a.nomzona_spmx) = b.d_asenta
                       and TRIM(a.mnpio_spmx) = b.d_mnpio
                       GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC ) b
					
					LET iNoRegistros = iNoRegistros + 1;
					
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
		ELIF pTipoConsulta = 2 THEN
			FOREACH					
					SELECT SKIP pRegistros FIRST pRecuperacion  a.numerocolonia, a.nombrezona,a.municipiozona
                    INTO iIdNumeroColonia, cNombreZona, cNombreMunicipio
                    FROM bdinteg:"informix".si_catzonas a, bdinteg:SI_CATSEPOMEX b
                    WHERE a.numerociudad = pIdCiudadCoppel AND a.numerocolonia != 0 
					 and lpad(a.codigopostalzona,5,'0') = b.d_codigo
					 and nombrezona LIKE '%' || TRIM(pConsulta) || '%'
                     and TRIM(a.nomzona_spmx) = b.d_asenta
                     and TRIM(a.mnpio_spmx) = b.d_mnpio
                    GROUP BY  a.numerocolonia, a.nombrezona,a.municipiozona ORDER BY a.nombrezona ASC
					
					LET iNoRegistros = iNoRegistros + 1;
					RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio WITH RESUME;
			END FOREACH;
			
			IF iNoRegistros = 0 AND pRegistros = 0 THEN
				LET cCodRet = '00017';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
			
			IF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodRet, iIdNumeroColonia, cNombreZona, cNombreMunicipio;
			END IF;
		END IF;
	
	END;
		
END PROCEDURE
DOCUMENT "AUTOR: Oscar Flores Conde",
"FECHA: 30/10/2013",
"DESCRIPCION: Consulta el catalogo de las ciudades",
"FECHA: 04/02/2025",
"AUTOR: Veronica Sanchez",
"DESCRIPCION: Se clona procedimiento almacenado para limitar la consulta a 100 registros",
"BD: bdicnweb";

CREATE PROCEDURE "informix".sp_consaldodisp(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pSistemaCuenta CHAR(2))
        RETURNING 
                CHAR(5) AS codret,
                DECIMAL(14,2) AS saldo_disponible;
        
        DEFINE cCodRet CHAR(5);
        DEFINE dSaldoDisponible DECIMAL(14,2);
        DEFINE iSqlErr INTEGER;
        DEFINE cNumProductoCred CHAR(4);
        DEFINE cCodTipoCred CHAR(2);
        
        LET dSaldoDisponible = 0;
        LET iSqlErr = 0;
        LET cCodRet = '00000';
        LET cNumProductoCred = '';
        LET cCodTipoCred = '';
        
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
        BEGIN
                
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                
                                LET cCodRet = iSqlErr;
                                RETURN cCodRet, dSaldoDisponible;
                        
                        END IF;
                END EXCEPTION;
                
                -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pSistemaCuenta = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
                
                IF pSistemaCuenta NOT IN ('01', '03', '06') THEN
                        LET cCodRet = '00037';
                END IF;
                
                IF pSistemaCuenta = '01' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        --RQM 09 704. Se agrega el valor del campo saldo_sbc al calculo de saldo disponible. DHG
                        SELECT  sdo_actual - (sdo_retenido + sdo_cong + imp_sbg_ccc + saldo_sbc) AS saldo_disponible
                        INTO dSaldoDisponible
                        FROM  bdicheq:"informix".sc_maechq
                        WHERE cuenta = pCuenta AND empresa='001';
                        
                        RETURN cCodRet, dSaldoDisponible;
                        
                ELIF pSistemaCuenta = '03' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT NVL(mi.capital, 0)
                        INTO dSaldoDisponible
                        FROM bdinvers:sv_maeinv mi
                        WHERE mi.cuenta = pCuenta
                                AND mi.secuencia = (SELECT NVL(MAX(secuencia),0) FROM bdinvers:sv_maeinv WHERE empresa = mi.empresa and cuenta = mi.cuenta);
                
                        RETURN cCodRet, dSaldoDisponible;
                ELIF pSistemaCuenta = '06' THEN
                        
                        --SET ISOLATION TO DIRTY READ;
                        
                        SELECT d.num_producto, d.cod_tipcred
                        INTO cNumProductoCred, cCodTipoCred
                        FROM bdicred:"informix".sd_maecred c, bdicred:"informix".sd_definicion d
                        WHERE c.empresa ='001'  
								AND c.num_credito = pCuenta
                                AND d.empresa = c.empresa
                                AND d.num_producto = c.num_producto;
                                
                        
                        IF cNumProductoCred IN ('6001','8100','7000','8500', '5400') THEN -- Tarjeta de Credito Bancoppel Visa, ORO Y PLATINO , Se agrega TDC GC
                                --SET ISOLATION TO DIRTY READ;
                                
                                --SELECT (NVL(m2.monto_otorgado,0) - NVL(m2.sdo_cap_insoluto,0) - NVL(m2.sdo_retenido,0))
								SELECT NVL(m2.sdo_capital,0)
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdos m2
                                WHERE num_credito = pCuenta AND empresa='001';
                        ELIF cCodTipoCred = '05' THEN -- Prestamo Personal
                                --SET ISOLATION TO DIRTY READ;
                                
                                SELECT m2c.sdo_capital
                                INTO dSaldoDisponible
                                FROM bdicred:"informix".sd_maesdoscrd m2c
                                WHERE m2c.num_credito = pCuenta;
                        END IF;
                        
                        RETURN cCodRet, dSaldoDisponible;
                END IF;
        END;
        
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 14/04/2014',
'DESCRIPCION: Consulta el saldo disponible de una cuenta de captacion/inversion/credito',
'BD: bdicnweb',
'MODIFICO : Daniel Hernandez Garcia',
'FECHA : 05-06-2025',
'MODIFICACION  : Se agrega el valor del campo saldo_sbc en el calculo del saldo disponible',
'PROYECTO: RQM 09 704 Cobranza Automatica en cuentas de captacion',
'BD    : bdicnweb',
'VER   : 1.1';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonoapp_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pFolioSuc CHAR(16), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15);  
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoApp_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' OR pFolioSuc = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;

		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN

			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4'			 
			  AND a.status_cancelado <> 'S';

		ELSE
			--REMESAS DE MAS DE 3 MESES
			SELECT  FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal = '5011'
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte   
			INNER JOIN bdinteg:"informix".si_telefonos as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.folio_suc = pFolioSuc 
			  AND a.forma_pago = '4' 
			  AND a.status_cancelado <> 'S';
		END IF;

		IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
		END IF;
		
		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00029';
			LET cRetorno3 = 'B6 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		ELSE
			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN  

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00034';
					LET cRetorno3 = 'B6 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
						cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;
		
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;
			
			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
		
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
				
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
					
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta,cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informacion para formato Abono App',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketabonovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1), pNumCliente CHAR(20))
	RETURNING   CHAR(5) AS codret,
				CHAR(3) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc,
				CHAR(15) AS origen, 
				CHAR(20) AS numCuenta,
				CHAR(16) AS numTarjeta,
				CHAR(4) AS sucursal, 
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono, 
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
				
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(3);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cNumcuenta CHAR(20);
	DEFINE cNumTarjeta CHAR(16);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cRetorno2 CHAR(100); 
	DEFINE cRetorno3 CHAR(150);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 

	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cNumcuenta = '';
	LET cNumTarjeta = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cRetorno2 = '';  
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketAbonoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
		
		IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0 ) THEN

			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764') 
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte
			WHERE a.referencia1 = pReferencia 
			  AND a.forma_pago = '4';

		ELSE 
			--REMESAS DE MAS DE 3 MESES
			SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, 
			CASE WHEN c.sucursal = '5011' THEN a.sucursal_cpl ELSE a.id_sucursal END, 
			TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen, c.cuenta, c.num_tarjeta, f.numcte, g.telefono
			INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cNumcliente, cTelefono
			FROM bdisac:"informix".sac_movimientoshistorial_old AS a
			INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio AND  b.numcategoria = '07' 
			INNER JOIN bdicheq:"informix".sc_movhis_old AS c ON c.folio_suc =  a.folio_suc AND c.sucursal NOT IN ('9250','9764')
			INNER JOIN bdicheq:"informix".sc_maechq AS d ON d.cuenta = c.cuenta AND d.num_cte = pNumCliente
			INNER JOIN bdinteg:"informix".si_cliente AS f ON f.numcte = d.num_cte
			INNER JOIN bdinteg:"informix".si_telefonos_actual as g ON g.numcte = f.numcte 
			WHERE a.referencia1 = pReferencia 
			AND a.forma_pago = '4';
		END IF;

		IF LEN(cOrigen) = 0 THEN
			LET cOrigen = 'BCL';
		END IF;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodRet= '00021';
			LET cRetorno3 = 'B4 - No se encontro informacion del cliente';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		ELSE

			IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas WHERE num_confirmacion = pReferencia) <> 0) THEN 

				SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
				TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
				INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
				FROM bdisac:"informix".sac_pld_remesas
				WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
			ELSE
				IF ((SELECT COUNT(num_confirmacion) FROM bdisac:"informix".sac_pld_remesas_old WHERE num_confirmacion = pReferencia) <> 0 ) THEN 

					SELECT beneficiario_nombre1, beneficiario_nombre2, beneficiario_appaterno, beneficiario_apmaterno, num_id_benef, 
					TRIM(ordenante_nombre1) || ' ' || TRIM(ordenante_nombre2)  || ' ' || TRIM(ordenante_appaterno) || ' ' || TRIM(ordenante_apmaterno) 
					INTO cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cRetorno3
					FROM bdisac:"informix".sac_pld_remesas_old  
					WHERE fecha_proceso = dFechaPago AND num_confirmacion = pReferencia; 
				ELSE
					LET cCodRet= '00033';
					LET cRetorno3 = 'B4 - No se encontro informacion relacionada';
					RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
				END IF;			
			END IF;	
					
			SELECT MAX(secuencia) 
				INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella 
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
				INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
				
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCadenaTran = '';
			END IF;

			SELECT nombre, plaza 
				INTO cNomSucursal, cPlaza 
			FROM bdinteg:"informix".si_sucursales
			WHERE sucursal = cSucursal;
			
			SELECT nombre 
				INTO cNomPlaza 
			FROM bdinteg:"informix".si_plazas
			WHERE plaza = cPlaza;
		
			IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cNomPlaza = '';
			END IF;
				
			IF DBINFO('sqlca.sqlerrd2') > 0 THEN
				
				EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
				INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
				cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;
					
				LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							
			END IF;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cNumcuenta, cNumTarjeta, cSucursal, cNomSucursal, 
				   cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cRetorno2, cRetorno3;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'MODIFICACION: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Abono por Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_cons_ticketefectivovent_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pReferencia CHAR(40), pHuella CHAR(1))
	RETURNING CHAR(5) AS codret,
				CHAR(5) AS numConvenio, 
				CHAR(40) AS nomConvenio, 
				DATE AS fechaPago, 
				CHAR(40) AS referencia, 
				CHAR(1) AS formaPago, 
				MONEY AS importePago, 
				CHAR(10) AS fechaInsert, 
				CHAR(8) AS usuario, 
				CHAR(16) AS folioSuc, 
				CHAR(15) AS origen,  
				CHAR(4) AS sucursal,  
				CHAR(40) AS nomSucursal, 
				CHAR(40) AS nombre1Ben, 
				CHAR(40) AS nombre2Ben, 
				CHAR(40) AS apPaternoBen, 
				CHAR(40) AS apMaternoBen, 
				CHAR(20) AS numCteBen,
				CHAR(20) AS numcliente, 
				CHAR(10) AS telefono,  
				CHAR(942) AS cadenaTran, 
				CHAR(3) AS plaza, 
				CHAR(40) AS nomPlaza,
				VARCHAR(250) AS dirCompleta,
				CHAR(20) AS cuenta,
				CHAR(16) AS tarjeta,
				CHAR(100) AS retorno2,
				CHAR(150) AS retorno3;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumConvenio CHAR(5);
	DEFINE cNomConvenio CHAR(40);
	DEFINE dFechaPago DATE;
	DEFINE cReferencia CHAR(40);
	DEFINE cFormaPago CHAR(1);
	DEFINE mImportePago MONEY;
	DEFINE cSucursal CHAR(4);
	DEFINE cFechaInsert CHAR(10);
	DEFINE cUsuario CHAR(8);
	DEFINE cFolioSuc CHAR(16);
	DEFINE cOrigen CHAR(15); 
	DEFINE cNombre1Ben CHAR(40);
	DEFINE cNombre2Ben CHAR(40);
	DEFINE cApPaternoBen CHAR(40);
	DEFINE cApMaternoBen CHAR(40);
	DEFINE cNumCteBen CHAR(20);
	DEFINE cNumcliente CHAR(20);
	DEFINE cTelefono CHAR(10); 
	DEFINE cCadenaTran CHAR(942);
	DEFINE cNomSucursal CHAR(40);
	DEFINE cPlaza CHAR(3);
	DEFINE cNomPlaza CHAR(40);
	DEFINE cDirCompleta VARCHAR(250);
	DEFINE cSecuenciaMax 	CHAR(3);
	DEFINE cRetorno2 CHAR(100);
	DEFINE cRetorno3 CHAR(150);

	-- Consulta sucursales
	DEFINE cMensaje CHAR(50);
	DEFINE cId_ptf CHAR(5); 
	DEFINE cCve_pais CHAR(3);
	DEFINE cNompais CHAR(20);
	DEFINE cCalle VARCHAR(100); 
	DEFINE cNumExt VARCHAR(6); 
	DEFINE cNumInt VARCHAR(5); 
	DEFINE cCveCol CHAR(8);
	DEFINE cNomcol VARCHAR(100);
	DEFINE cCveMun CHAR(3);
	DEFINE cnommunicipio VARCHAR(60);
	DEFINE cCvelocalidad CHAR(14);
	DEFINE cNomlocalidad VARCHAR(60);
	DEFINE cCp CHAR(5); 
	DEFINE cCveCiudad CHAR(3);
	DEFINE cNomciudad VARCHAR(60);
	DEFINE cCve_estado CHAR(2); 
	DEFINE cNomestado VARCHAR(30);
	DEFINE cTel1 VARCHAR(14); 
	DEFINE cTel2 VARCHAR(14);
	DEFINE cTipo VARCHAR(5);
	DEFINE cCuenta VARCHAR(20);
	DEFINE cTarjeta VARCHAR(16);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumConvenio = '';
	LET cNomConvenio = '';
	LET dFechaPago = '';
	LET cReferencia = '';
	LET cFormaPago = '';
	LET mImportePago = 0;
	LET cSucursal = '';
	LET cFechaInsert = '';
	LET cUsuario = '';
	LET cFolioSuc = '';
	LET cOrigen = ''; 
	LET cNombre1Ben = '';
	LET cNombre2Ben = '';
	LET cApPaternoBen = '';
	LET cApMaternoBen = '';
	LET cNumCteBen = '';
	LET cNumcliente = '';
	LET cTelefono = ''; 
	LET cCadenaTran = '';
	LET cNomSucursal = '';
	LET cPlaza = '';
	LET cNomPlaza = '';
	LET cDirCompleta = '';
	LET cSecuenciaMax = '';
	
	-- Consulta sucursales
	LET cMensaje = '';
	LET cId_ptf = '';
	LET cCve_pais = '';
	LET cNompais = '';
	LET cCalle = '';
	LET cNumExt = '';
	LET cNumInt = '';
	LET cCveCol = '';
	LET cNomcol = '';
	LET cCveMun = '';
	LET cnommunicipio = '';
	LET cCvelocalidad = '';
	LET cNomlocalidad = '';
	LET cCp = '';
	LET cCveCiudad = '';
	LET cNomciudad = '';
	LET cCve_estado = '';
	LET cNomestado = '';
	LET cTel1 = ''; 
	LET cTel2 = '';
	LET cTipo = '';
	LET cCuenta = '';
	LET cTarjeta = '';
	LET cRetorno2 = '';
	LET cRetorno3 = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END EXCEPTION;
	 
		--SET DEBUG FILE TO '/tmp/mfinis/sp_ope_cons_ticketEfectivoVent_web.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pReferencia = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
		END IF;		

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
			
			IF cCodRet <> '00000' THEN
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			END IF;

			IF ((SELECT COUNT(referencia1) FROM bdisac:"informix".sac_movimientoshistorial WHERE referencia1 = pReferencia AND numconvenio IN ('004','006','007','008','009')) <> 0) THEN 

				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			ELSE 
				--REMESAS DE MAS DE 3 MESES
				SELECT FIRST 1 a.numconvenio, b.nomconvenio, a.fecha_pago, a.referencia1, a.forma_pago, a.importe_pago, a.id_sucursal, TO_CHAR(a.fecha_insert, "%H:%M:%S"), a.usuario, a.folio_suc, a.origen
				INTO cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cSucursal, cFechaInsert, cUsuario, cFolioSuc, cOrigen
				FROM bdisac:"informix".sac_movimientoshistorial_old AS a
				INNER JOIN bdisac:"informix".sac_convenios AS b ON b.numconvenio = a.numconvenio
				WHERE b.numcategoria = '07' 
				  AND a.referencia1 = pReferencia;

			END IF; 

			IF LEN(cOrigen) = 0 THEN
				LET cOrigen = 'BCL';
			END IF;

			IF DBINFO('sqlca.sqlerrd2') = 0 THEN 
				LET cCodRet= '00022';
				LET cRetorno3 = 'B5 - No se encontro informacion del cliente';
				RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
			ELSE
				--/////////WESTERN UNION/////////
				IF cNumConvenio = '006' OR cNumConvenio = '007' OR cNumConvenio = '008'  THEN 

					IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay WHERE mtcn = cReferencia) <> 0 ) THEN 

						SELECT
							wu.benef_nombre1,
							wu.benef_nombre2,
							wu.benef_appaterno,
							wu.benef_apmaterno,
							wu.benef_id_number,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
						FROM bdisac:"informix".sac_wu_pay AS wu 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal 
						WHERE wu.mtcn = cReferencia 
						  AND wu.foreign_rs_refnum_rp = cFolioSuc;

						--/////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
								
							SELECT
								wu.benef_nombre1,
								wu.benef_nombre2,
								wu.benef_appaterno,
								wu.benef_apmaterno,
								wu.benef_id_number,
								TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
								TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_wu_pay AS wu 
							INNER JOIN bdisac:"informix".sac_wu_search AS s ON wu.mtcn = s.mtcn 	
							WHERE s.mtcn = cReferencia 
							  AND s.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00023';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(mtcn) FROM bdisac:"informix".sac_wu_pay_old WHERE mtcn = cReferencia) <> 0 ) THEN
							
							SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
									TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON wu.mtcn = pld.num_confirmacion AND wu.foreign_rs_refnum_rp= pld.folio_sucursal  
								WHERE wu.mtcn = cReferencia 
								  AND wu.foreign_rs_refnum_rp = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
										
								SELECT
									wu.benef_nombre1,
									wu.benef_nombre2,
									wu.benef_appaterno,
									wu.benef_apmaterno,
									wu.benef_id_number,
									TRIM(s.emisor_nombre1) || ' ' || TRIM(s.emisor_nombre2) || ' ' || 
									TRIM(s.emisor_appaterno) || ' ' || TRIM(s.emisor_apmaterno)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_wu_pay_old AS wu 
								INNER JOIN bdisac:"informix".sac_wu_search_old AS s ON wu.mtcn = s.mtcn 
								WHERE s.mtcn = cReferencia 
								  AND s.foreign_rs_refnum_rp = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00024';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////BTS/////////
				ELIF cNumConvenio = '004' THEN

					IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi WHERE confirmation_nm = cReferencia) <>0) THEN

						SELECT
							bts.r_first_name,
							bts.r_middle_name,
							bts.r_last_name,
							bts.r_mother_m_name,
							bts.r_identif_nm,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_bts_payi AS bts 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
						WHERE bts.confirmation_nm = cReferencia 
						  AND bts.bank_ref_nm = cFolioSuc;

						-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
								TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_bts_payi AS bts 
							INNER JOIN bdisac:"informix".sac_bts_qryi AS s ON bts.confirmation_nm = s.confirmation_nm 	
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00025';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
						--REMESAS DE MAS DE 3 MESES
						IF ((SELECT COUNT(confirmation_nm) FROM bdisac:"informix".sac_bts_payi_old WHERE confirmation_nm = cReferencia) <>0) THEN

							SELECT
								bts.r_first_name,
								bts.r_middle_name,
								bts.r_last_name,
								bts.r_mother_m_name,
								bts.r_identif_nm,
								TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
								TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
							FROM bdisac:"informix".sac_bts_payi_old AS bts 
							INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON bts.confirmation_nm = pld.num_confirmacion AND bts.bank_ref_nm = pld.folio_sucursal 
							WHERE bts.confirmation_nm = cReferencia 
							  AND bts.bank_ref_nm = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
								SELECT
									bts.r_first_name,
									bts.r_middle_name,
									bts.r_last_name,
									bts.r_mother_m_name,
									bts.r_identif_nm,
									TRIM(s.s_first_name) || ' ' || TRIM(s.s_middle_name) || ' ' || 
									TRIM(s.s_last_name) || ' ' || TRIM(s.s_mother_m_name)
								INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
								FROM bdisac:"informix".sac_bts_payi_old AS bts 
								INNER JOIN bdisac:"informix".sac_bts_qryi_old AS s ON bts.confirmation_nm = s.confirmation_nm	
								WHERE bts.confirmation_nm = cReferencia 
								  AND bts.bank_ref_nm = cFolioSuc;

								IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
									TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

									LET cCodRet= '00026';
									LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
									RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
										cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
								END IF;
							END IF;
						END IF;
					END IF;

				--/////////APP/////////
				ELIF cNumConvenio = '009' THEN

					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi WHERE unirefnum = cReferencia) <> 0) THEN
	
						SELECT FIRST 1
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas AS pld 
						ON app.unirefnum = pld.num_confirmacion AND
						app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia AND
						app.refnum=cFolioSuc;

					-- /////////si los datos vienen vacios se consulta los datos en las tablas QRY--
						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
							
							SELECT FIRST 1
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00027';
								LET cRetorno3 = 'No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					ELSE 
					--REMESAS DE MAS DE 3 MESES
					IF ((SELECT COUNT(unirefnum) FROM bdisac:"informix".sac_app_payi_old WHERE unirefnum = cReferencia) <> 0) THEN

						SELECT
							app.firstname,
							app.middlename,
							app.lastname,
							app.mommaidenname,
							app.numberci,
							TRIM(pld.ordenante_nombre1) || ' ' || TRIM(pld.ordenante_nombre2) || ' ' || 
							TRIM(pld.ordenante_appaterno) || ' ' || TRIM(pld.ordenante_apmaterno) 
						INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3
						FROM bdisac:"informix".sac_app_payi_old AS app 
						INNER JOIN bdisac:"informix".sac_pld_remesas_old AS pld ON app.unirefnum = pld.num_confirmacion AND app.refnum = pld.folio_sucursal 
						WHERE app.unirefnum = cReferencia 
						  AND app.refnum = cFolioSuc;

						IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
							TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN
				
							SELECT
								app.firstname,
								app.middlename,
								app.lastname,
								app.mommaidenname,
								app.numberci,
								TRIM(s.r_firstname) || ' ' || TRIM(s.r_middlename) || ' ' || 
								TRIM(s.r_lastname) || ' ' || TRIM(s.r_mommaidenname)
							INTO cNombre1Ben,cNombre2Ben,cApPaternoBen,cApMaternoBen,cNumCteBen,cRetorno3  
							FROM bdisac:"informix".sac_app_payi_old AS app 
							INNER JOIN bdisac:"informix".sac_app_qryi_old AS s ON app.unirefnum = s.unirefnum 
							WHERE s.unirefnum = cReferencia 
							  AND app.refnum = cFolioSuc;

							IF 	TRIM(cNombre1Ben) 	IS NULL OR TRIM(cNombre2Ben) IS NULL OR TRIM(cApPaternoBen) IS NULL OR 
								TRIM(cApMaternoBen) IS NULL OR TRIM(cNumCteBen)  IS NULL OR TRIM(cRetorno3) 	IS NULL THEN

								LET cCodRet= '00028';
								LET cRetorno3 = 'B5 - No se encontraron datos del cliente';
								RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
									cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
							END IF;
						END IF;
					END IF;
				END IF; 
			END IF;  


			SELECT numcte
			INTO cNumcliente 
			FROM bdinteg:"informix".si_cliente 
			WHERE apell_paterno	= cApPaternoBen
			  AND apell_materno = cApMaternoBen
			  AND nombre1 = cNombre1Ben
			  AND nombre2 = cNombre2Ben;


			SELECT FIRST 1 telefono
			INTO cTelefono 
			FROM bdinteg:"informix".si_telefonos_actual
			WHERE numcte = cNumcliente
			  AND status_tel = 'A';
			

			SELECT MAX(secuencia) 
			INTO cSecuenciaMax 
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND estado = 'A';

			SELECT dmapa 
			INTO cCadenaTran
			FROM bdinteg:"informix".si_cte_huella
			WHERE numcte = cNumcliente
			AND secuencia = cSecuenciaMax;
						
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
						LET cCadenaTran = '';
					END IF;

						SELECT nombre, plaza 
						INTO cNomSucursal, cPlaza 
						FROM bdinteg:"informix".si_sucursales
						WHERE sucursal = cSucursal;
							
						SELECT nombre 
						INTO cNomPlaza 
						FROM bdinteg:"informix".si_plazas
						WHERE plaza = cPlaza;
				
						IF DBINFO('sqlca.sqlerrd2') = 0 THEN
							LET cNomPlaza = '';
						END IF;
					
							IF DBINFO('sqlca.sqlerrd2') > 0 THEN
								EXECUTE FUNCTION bdisac:"informix".sp_sac_consucursales(cSucursal) 
								INTO cCodRet, cMensaje, cId_ptf, cCve_pais, cNompais, cCalle, cNumExt, cNumInt, cCveCol, cNomcol, cCveMun, cnommunicipio, cCvelocalidad, cNomlocalidad, 
								cCp, cCveCiudad, cNomciudad, cCve_estado, cNomestado, cTel1, cTel2, cTipo;	
								LET cDirCompleta = cCalle ||' NO. '||cNumExt||', COL. '||cNomcol||' C.P. '||cCp;
							END IF;

							RETURN cCodRet, cNumConvenio, cNomConvenio, dFechaPago, cReferencia, cFormaPago, mImportePago, cFechaInsert, cUsuario, cFolioSuc, cOrigen, cSucursal, cNomSucursal, 
					               cNombre1Ben, cNombre2Ben, cApPaternoBen, cApMaternoBen, cNumCteBen, cNumcliente, cTelefono, cCadenaTran, cPlaza, cNomPlaza, cDirCompleta, cCuenta, cTarjeta, cRetorno2, cRetorno3;
				END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: FG',
'FECHA: 28/09/2025',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃ³n para el formato Efectivo Ventanilla',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_ope_consmovimientos_web(pUsuario CHAR(8), pIdFuncion CHAR(10), pRemesadora CHAR(10), pFechaInicio DATE, pFechaFin DATE, pCveRemesa CHAR(20),
													pNumCliente CHAR(9), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			  CHAR(3) AS numconvenio,
			  CHAR(40) AS nomconvenio,
			  CHAR(20) AS num_cte,
			  DATE AS fech_oper,
			  CHAR(4) AS sucursal,
			  CHAR(16) AS folio_suc,
			  CHAR(40) AS referencia1,
			  CHAR(100) AS nomCliente,
			  CHAR(150) AS retorno3,
			  CHAR(1) AS formaPago,
			  CHAR(8) AS usuario;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE cNumconvenio CHAR(3);
	DEFINE cNomconvenio CHAR(40);
	DEFINE cNum_cte CHAR(20);
	DEFINE dFech_oper DATE;
	DEFINE cSucursal CHAR(4);
	DEFINE cFolio_suc CHAR(16);
	DEFINE iTotRegistros INTEGER;
	DEFINE iTotRegistros2 INTEGER;
	DEFINE cReferencia1 CHAR(40);
	DEFINE cNomCliente CHAR(100);
	DEFINE cNombre1 CHAR(26);
	DEFINE cNombre2 CHAR(26);
	DEFINE cAppPaterno CHAR(26);
	DEFINE cAppMaterno CHAR(26);
	DEFINE cRetorno3 CHAR(150);
	DEFINE cFormaPago CHAR(1);
	DEFINE cUsuario CHAR(8);


	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cNumconvenio = '';
	LET cNomconvenio = '';
	LET cNum_cte = '';
	LET dFech_oper = '';
	LET cSucursal = '';
	LET cFolio_suc = '';
	LET iTotRegistros = 0;
	LET iTotRegistros2 = 0;
	LET cReferencia1 = '';
	LET cNomCliente = '';
	LET cNombre1 = '';
	LET cNombre2 = '';
	LET cAppPaterno = '';
	LET cAppMaterno = '';
	LET cRetorno3 = '';
	LET cFormaPago = '';
	LET cUsuario = '';


	BEGIN

		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END EXCEPTION;
	 
		-- SET DEBUG FILE TO '/tmp/mfinis/sp_ope_consmovimientos_web.out';
		-- TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCveRemesa = '' THEN
			LET cCodRet = '00003';
			LET cRetorno3 = 'Los parametros de busqueda estan incompletos';
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;		
		
		--VALIDACION DE ACCESO A LA FUNCIONALIDAD		
		EXECUTE PROCEDURE bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
		END IF;


		IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial WHERE referencia1 = pCveRemesa) <> 0) THEN   
								
			IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN 
									
				SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
				INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
				FROM bdisac:sac_movimientoshistorial AS a
				INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
				INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
				INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
				LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
				WHERE a.forma_pago IN (4 , 1) 
				AND b.sucursal NOT IN ('9250','9764','9251') 
				AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
				AND c.numcategoria = '07' 
				AND b.cancelad <> 'S' 
				AND a.status_cancelado <> 'S'
				AND a.numconvenio IN ('004','006','007','008','009') 
				AND a.referencia1 = pCveRemesa; 

					IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
						TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

							LET cCodRet= '00017';
							LET cRetorno3 = 'No se encontro informacion del cliente';
							RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF; 
				RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
			ELSE
				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN
			
					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial AS a
					INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 	
					LET cCodRet= '00018';
					LET cRetorno3 = 'No se encontro informacion relacionada';
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;			
				END IF;
			END IF;
		ELSE	
			IF ((SELECT COUNT(referencia1) FROM bdisac:sac_movimientoshistorial_old WHERE referencia1 = pCveRemesa) <> 0) THEN		

				IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

					SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
					INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
					FROM bdisac:sac_movimientoshistorial_old AS a
					INNER JOIN bdicheq:sc_movhis AS b ON a.folio_suc = b.folio_suc 
					INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
					INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
					LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
					WHERE a.forma_pago IN (4 , 1) 
					AND b.sucursal NOT IN ('9250','9764','9251') 
					AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
					AND c.numcategoria = '07' 
					AND b.cancelad <> 'S' 
					AND a.status_cancelado <> 'S'
					AND a.numconvenio IN ('004','006','007','008','009') 
					AND a.referencia1 = pCveRemesa; 

						IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
							TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

								LET cCodRet= '00017';
								LET cRetorno3 = 'No se encontro informacion del cliente';
								RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
						END IF; 	
					RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
				ELSE 
					IF ((SELECT COUNT(a.folio_suc) FROM bdisac:sac_movimientoshistorial_old AS a INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc where referencia1 = pCveRemesa) <> 0) THEN

						SELECT FIRST 1  a.numconvenio, c.nomconvenio, d.num_cte, b.fech_oper, b.sucursal, a.folio_suc, a.referencia1, TRIM(f.nombre1)||' '||TRIM(f.nombre2)||' '||TRIM(f.apell_paterno)||' '||TRIM(f.apell_materno), razon_social, a.forma_pago, a.usuario
						INTO  cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario
						FROM bdisac:sac_movimientoshistorial_old AS a
						INNER JOIN bdicheq:sc_movhis_old AS b ON a.folio_suc = b.folio_suc 
						INNER JOIN bdisac:sac_convenios AS c ON c.numconvenio = a.numconvenio 
						INNER JOIN bdicheq:sc_maechq AS d ON d.cuenta = b.cuenta
						LEFT JOIN bdinteg:si_cliente AS f ON f.numcte = d.num_cte
						WHERE a.forma_pago IN (4 , 1) 
						AND b.sucursal NOT IN ('9250','9764','9251') 
						AND b.transacc NOT IN ('1355','1140','1151', '1152','1153', '1525','1521', '1523', '1524', '1522')
						AND c.numcategoria = '07' 
						AND b.cancelad <> 'S' 
						AND a.status_cancelado <> 'S'
						AND a.numconvenio IN ('004','006','007','008','009') 
						AND a.referencia1 = pCveRemesa; 

							IF 	TRIM(cNum_cte) 	IS NULL OR TRIM(cFolio_suc) IS NULL OR TRIM(cReferencia1) IS NULL OR 
								TRIM(cNomCliente) IS NULL OR TRIM(cRetorno3)  IS NULL OR TRIM(cFormaPago) IS NULL  THEN

									LET cCodRet= '00017';
									LET cRetorno3 = 'No se encontro informacion del cliente';
									RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
							END IF; 	
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					ELSE 	
						LET cCodRet= '00018';
						LET cRetorno3 = 'No se encontro informacion relacionada';
						RETURN cCodRet, cNumconvenio, cNomconvenio, cNum_cte, dFech_oper, cSucursal, cFolio_suc, cReferencia1, cNomCliente, cRetorno3, cFormaPago, cUsuario;
					END IF;
				END IF;	
			END IF;
		END IF; 												
	END
END PROCEDURE
DOCUMENT 'AUTOR: FG ',
'FECHA: 29/07/2024',
'MODULO: OPERCIONES',
'FUNCIONALIDAD: CONSULTA DE COMPROBANTE',
'DESCRIPCION: SPL encargado de recuperar informaciÃÂ³n para grid de datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_catalogocajageneral(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipo CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
		RETURNING 	CHAR(5) AS codret,
					CHAR(4) AS cIdProvCaja,
            		CHAR(30) AS cDescCaja;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cIdProvCaja CHAR(4);
    DEFINE cDescCaja CHAR(30);
	DEFINE cPlazaCaja CHAR(3);
	DEFINE iNoRegistros INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cIdProvCaja = '';
	LET cDescCaja = '';
	LET cPlazaCaja = '';
	LET iNoRegistros = 0;
	
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_catalogocajageneral.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipo = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		-- VALIDACION DE LA PAGINACION
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
				LET cCodRet = '00098';
				RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;

		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cIdProvCaja, cDescCaja;
		END IF;
		
		--SET LOCK MODE TO WAIT 6;
		SET ISOLATION TO DIRTY READ;
		
		-- COMBOBOX CAJA GENERAL 
		IF pTipo = '1' THEN --Por codigo
		
			FOREACH		
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza 
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		ELIF pTipo = '2' THEN --Por descripcion
		
			FOREACH	 
				SELECT SKIP pRegistros FIRST pRecuperacion cod_proveedor, descripcion, plaza
				INTO cIdProvCaja, cDescCaja, cPlazaCaja FROM bdisuc:'informix'.ss_proveedores ORDER BY descripcion
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja) WITH RESUME;
				LET iNoRegistros = iNoRegistros + 1;
			END FOREACH;
		
		END IF;

		IF pRegistros = 0 AND iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);

		ELIF iNoRegistros = 0 AND pRegistros > 0 THEN
				LET cCodRet = '1001';
				RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
		IF iNoRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodret, cIdProvCaja, UPPER(cDescCaja);
		END IF;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: L. Montserrat LeÃ¯Â¿Â½n Amador',
'FECHA: 07/01/2015',
'DESCRIPCION: SPL, que hace la consulta para el llenado del combobox caja general, Monitor de Operaciones Caja General',
'AUTOR: Jose Antonio Ramirez Franco',
'FECHA MODIFICACION: 17/07/2023',
'DESCRIPCION: Se aÃÂ±adio paginado para cada una de las opciones del SP',
'AUTOR: Veronica Sanchez Tlacomulco TASF',
'FECHA MODIFICACION: 28/08/2025',
'DESCRIPCION: Se realizo un mantenimiento para aplicar de forma correcta el tratamiento del paginado.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_cargacod41_ccep(pUsuario CHAR(8), pIdFuncion CHAR(10),pnombrearchivo CHAR(30), pRutaArchivo CHAR(60), pDireccionMac CHAR(15))
		RETURNING CHAR(5) AS codret,
				  CHAR(1) AS bBanDetalle,
				  DECIMAL(20,2) AS	importeTotal; 
		
		
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(3);
	DEFINE iCodRetSp INTEGER;
	DEFINE cEmpresa CHAR(3);
	DEFINE cRenglon CHAR(400);
	DEFINE cNumSecuencia CHAR(7); 
	DEFINE cCodOperacion  CHAR(2);
	DEFINE cFechatrasnfer  CHAR(8);
	DEFINE cBancoCedente  CHAR(3);
	DEFINE cBancoLibrado  CHAR(3);
	DEFINE cImporte  CHAR(15);
	DEFINE cLoteEntrada  CHAR(7);
	DEFINE cSecEntrada  CHAR(4);
	DEFINE cLoteSAlida  CHAR(7);
	DEFINE cSecSalida  CHAR(4);
	DEFINE cTransaccion  CHAR(2);
	DEFINE cChqCompensacion CHAR(3);
	DEFINE cCuentaReferencia CHAR(13);
	DEFINE cNumCheque CHAR(10);
	DEFINE cChqDigVerInter CHAR(1);
	DEFINE cChqDigVerPre CHAR(1);
	DEFINE cChqCodSeguridad CHAR(3);
	DEFINE cUbicFis CHAR(8);
	DEFINE cTruncado CHAR(1);
	DEFINE cMotivoDevol CHAR(2);
	DEFINE cFechaInicial CHAR(8);
	DEFINE cPlazaIntercam CHAR(2);
	DEFINE cRfcCte CHAR(13);
	DEFINE cCurpCte CHAR(18);
	DEFINE cTipoCuentaDep CHAR(2);
	DEFINE cCuentaDeposito CHAR(20);
	DEFINE cNombreCte CHAR(40);
	DEFINE cCtaAlertamiento CHAR(2);
	DEFINE cFolioSeguro CHAR(12);
	DEFINE cUsoFuturo CHAR(120);	
	DEFINE dImporte DECIMAL(16,2);
	DEFINE dImporte2 DECIMAL(16,2);
	DEFINE cMonto CHAR(12);
	DEFINE cCents CHAR(2);
	DEFINE mImporte CHAR(15);
	DEFINE importeTotal DECIMAL(20,2);	
	DEFINE cDescbancoLibrado CHAR(30);
	DEFINE cMotivoDevolucion CHAR(30);
	DEFINE cObservaciones CHAR(50);
	DEFINE bBanderaError CHAR(1);
	DEFINE cMiBanco CHAR(4);
	DEFINE cprocesar CHAR(2);
	DEFINE cFechaformat CHAR(8);
	DEFINE cValidaPresentado CHAR(50);
	DEFINE cFechaDevol CHAR(10);
	DEFINE cFechaHoy CHAR(10);
	DEFINE iNoPresentado INTEGER;
	DEFINE cValidaProceso CHAR(30);
	DEFINE bBanDet CHAR(1);
	DEFINE ven_transacc SMALLINT;
	DEFINE cSqlerr INTEGER;
	DEFINE cIsamErr	INTEGER;
	DEFINE cDescErr	CHAR(50);
	DEFINE cSQL CHAR(250);
	DEFINE iNoProcesado INTEGER;
	DEFINE bInTransaction BOOLEAN;
	DEFINE cPathdbaccess CHAR(20);
	DEFINE cMotivoDevCompleto CHAR(100);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '000';
	LET iCodRetSp = 0;
	LET cEmpresa = '001';
	LET cRenglon = '';
	LET cNumSecuencia = '';
	LET cCodOperacion  = '';
	LET cFechatrasnfer  = '';
	LET cBancoCedente  = '';
	LET cBancoLibrado  = '';
	LET cImporte  = '';
	LET cLoteEntrada  = '';
	LET cSecEntrada  = '';
	LET cLoteSAlida  = '';
	LET cSecSalida  = '';
	LET cTransaccion  = '';
	LET cChqCompensacion = '';
	LET cCuentaReferencia = '';
	LET cNumCheque = '';
	LET cChqDigVerInter = '';
	LET cChqDigVerPre = '';
	LET cChqCodSeguridad = '';
	LET cUbicFis = '';
	LET cTruncado = '';
	LET cMotivoDevol = '';
	LET cFechaInicial = '';
	LET cPlazaIntercam = '';
	LET cRfcCte = '';
	LET cCurpCte = '';
	LET cTipoCuentaDep = '';
	LET cCuentaDeposito = '';
	LET cNombreCte = '';
	LET cCtaAlertamiento = '';
	LET cFolioSeguro = '';
	LET cUsoFuturo = '';
	LET dImporte= 0.00;
	LET dImporte2= 0.00;
	LET cMonto = '';
	LET cCents = '';
	LET mImporte = '';
	LET importeTotal = 0.00;
	LET cDescbancoLibrado = '';
	LET cMotivoDevolucion = '';
	LET cObservaciones = '';
	LET bBanderaError = 'f';
	LET cMiBanco = '';
	LET cprocesar = '';
	LET cFechaformat = '';
	LET cValidaPresentado = '';
	LET cFechaDevol = '';
	LET cFechaHoy ='';
	LET iNoPresentado = 0;
	LET cValidaProceso = '';
	LET bBanDet = '';
	LET ven_transacc = 0;
	LET cSqlerr = 0;
	LET cIsamErr = 0;
	LET cDescErr = '';	
	LET cSQL = '';
	LET iNoProcesado = '';
	LET bInTransaction = 'f';
	LET cPathdbaccess = '/ifxsif01/bin/';
	LET cMotivoDevCompleto = '';
	
	BEGIN
		
		ON EXCEPTION SET cSqlerr, cIsamErr, cDescErr
			IF cSqlerr <> 0 THEN
				Let cCodret = cSqlerr;      
				IF ven_transacc = 1 THEN
					ROLLBACK WORK;			
				END IF;
			   RETURN cCodRet,bBanDet,importeTotal; 
			END IF;
		END EXCEPTION;		
		ON EXCEPTION IN (-535,-255)
				LET bInTransaction = 't';
				COMMIT WORK;
				BEGIN WORK;
		END EXCEPTION WITH RESUME;	
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cargacod41_ccep.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR  pnombrearchivo = '' OR pRutaArchivo = '' OR pDireccionMac = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE PROCEDURE bdinteg:'informix'.sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet,bBanDet,importeTotal; 
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		BEGIN WORK;
			LET ven_transacc = 1;
			
			--- CREAR LA TABLA DE TEMPORAL
			DELETE FROM bdicnweb:"informix".ccep_generacioncod41_tmp;
			
			DELETE FROM bdicnweb:"informix".ccep_procesacod41detalle_tmp;																	
			
			LET cSQL = '';
			--- GUARDA EL QUERY DEL LOAD EN EL ARCHIVO   *.SQL
			LET cSQL = 'echo "SET ISOLATION TO DIRTY READ; LOAD FROM '  ||trim(pRutaArchivo) || pnombrearchivo || ' INSERT INTO bdicnweb:"informix".ccep_generacioncod41_tmp(linea)" > '|| trim(pRutaArchivo) || 'Temporal.sql';
			SYSTEM cSQL;

			LET cSQL = '';
			--- EJECUTA LAS INSTRUCCIONES QUE ESTAN DENTRO DEL ARCHIVO  *.SQL
			Let cSQL = TRIM(cPathdbaccess)||'dbaccess bdicnweb ' ||trim(pRutaArchivo)|| 'Temporal.sql'; --Se activa para desarrollo 
			COMMIT WORK;
			SYSTEM cSQL;
			BEGIN WORK;
			
			-- fecha habil actual
			SELECT fecha_hoy INTO cFechaHoy FROM bdicheq:sc_fechas WHERE empresa = cEmpresa;
			
			--03/04/2016 calcula fecha de devolucion habilm ant
			EXECUTE PROCEDURE bditef:cal_habil_ant(cFechaHoy) INTO cCodRetsp, cFechaDevol;
			LET iCodRetSp = cCodRetSp::INTEGER;
	
			IF  iCodRetSp <> '000' THEN													  
				ROLLBACK WORK;
				LET ven_transacc = 0;
				let cCodret = '666';
				RETURN cCodRet,bBanDet,importeTotal;
			END IF;
			
		COMMIT WORK;
		
		BEGIN WORK;
			--consulta banco propietario
			SELECT valor INTO cMiBanco FROM bdinteg:si_param WHERE empresa = cEmpresa AND cod_param = '5';
			
			FOREACH SELECT linea INTO cRenglon FROM bdicnweb:"informix".ccep_generacioncod41_tmp ORDER BY(id_serial)
				IF SUBSTR(cRenglon,1,2) = "02" THEN
					LET cNumSecuencia = SUBSTR(cRenglon,3,7);
					LET cCodOperacion = SUBSTR(cRenglon,10,2);
					LET cFechatrasnfer =SUBSTR(cRenglon,12,8); 
					LET cBancoCedente = SUBSTR(cRenglon,20,3);
					LET cBancoLibrado = SUBSTR(cRenglon,23,3);
					LET cImporte = SUBSTR(cRenglon,26,15);
					LET cLoteEntrada = SUBSTR(cRenglon,41,7);
					LET cSecEntrada = SUBSTR(cRenglon,48,4);
					LET cLoteSAlida = SUBSTR(cRenglon,52,7);
					LET cSecSalida = SUBSTR(cRenglon,59,4);
					LET cTransaccion = SUBSTR(cRenglon,63,2);
					LET cChqCompensacion = SUBSTR(cRenglon,65,3);
					LET cCuentaReferencia = SUBSTR(cRenglon,68,13);
					LET cNumCheque = SUBSTR(cRenglon,81,10);
					LET cChqDigVerInter = SUBSTR(cRenglon,91,1);
					LET cChqDigVerPre = SUBSTR(cRenglon,92,1);
					LET cChqCodSeguridad = SUBSTR(cRenglon,93,3);
					LET cUbicFis = SUBSTR(cRenglon,96,8);
					LET cTruncado = SUBSTR(cRenglon,104,1);
					LET cMotivoDevol = SUBSTR(cRenglon,105,2);
					LET cFechaInicial = SUBSTR(cRenglon,107,8);
					LET cPlazaIntercam = SUBSTR(cRenglon,115,2);
					LET cRfcCte = SUBSTR(cRenglon,117,13);
					LET cCurpCte = SUBSTR(cRenglon,130,18);
					LET cTipoCuentaDep = SUBSTR(cRenglon,148,2);
					LET cCuentaDeposito = SUBSTR(cRenglon,150,20);
					LET cNombreCte = SUBSTR(cRenglon,170,40);
					LEt cCtaAlertamiento = SUBSTR(cRenglon,210,2);
					LET cFolioSeguro = SUBSTR(cRenglon,212,12);
					LET cUsoFuturo = SUBSTR(cRenglon,224,120);
					LET mImporte = TO_CHAR(cImporte);
					LET mimporte = substr(mImporte, 1, 13) || '.' || substr(mImporte, 14, 2) ;
					LET dImporte = substr(cImporte, 1, 13) :: DECIMAL(16,2);
					LET dImporte2 = ('0.' || substr(cImporte, 14, 2)):: DECIMAL(16,2);
					LET dImporte = dImporte + dImporte2;
					LET importeTotal = importeTotal + dImporte;
					--obtiene descricion de banco
					LET cDescbancoLibrado = 'No Existe en el catalogo';						
					SELECT descripcion INTO cDescbancoLibrado FROM bdinteg:si_bancos WHERE banco = cBancoLibrado;
					
					LET cCuentaDeposito = LTRIM(cCuentaDeposito,'0');
					
					--obtiene motivo de devolucion
					LET cMotivoDevolucion = 'No Existe en el catalogo';
					SELECT descripcion INTO cMotivoDevolucion FROM bdinteg:si_coddevcam WHERE codigo = cMotivoDevol;
					LET cMotivoDevCompleto = TRIM(cMotivoDevol)||' '||TRIM(cMotivoDevolucion);
					LET cprocesar = 'f';
					
					--valida si existe alguna observacion a gregar
					LET cObservaciones = '';
					LET bBanderaError = 'f';
					
					IF cCodOperacion <> '41'THEN
						LET cObservaciones = 'Registro no en fase de devolucion';
						LET bBanderaError = 't';
					END IF;
					
					-- valida banco
					IF 	bBanderaError= 'f' THEN
						IF cBancoCedente <> cMiBanco THEN
								LET cObservaciones = 'Documento no compensado por el banco';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--03/07/2016 validacion de fecha habil
					IF 	bBanderaError= 'f' THEN							
						LET cFechaformat = SUBSTR(cFechaDevol, 7, 4) || SUBSTR(cFechaDevol, 1, 2) || SUBSTR(cFechaDevol, 4, 2);
						IF cFechaInicial <> cFechaformat THEN
								LET cObservaciones = 'La fecha de presentacion inicial no corresponde';
								LET bBanderaError = 't';
						END IF;
					END IF;
					
					--validacion si el cheque ya fue presentado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaPresentado = 'Este documento no esta registrado como presentado';
						
						SELECT COUNT(*) INTO iNoPresentado FROM bditef:cce_detalle	
						WHERE bco_receptor = cBancoLibrado AND
						LPAD(TRIM(num_cuenta) , 13, '0') = cCuentaReferencia AND
						num_cheque = cNumCheque AND
						importe = dImporte AND
						fecha_presini = cFechaInicial AND
						cod_operacion = '40';
						
						IF iNoPresentado <> 0 THEN
							LET cValidaPresentado = '';
						ELSE
							LET bBanderaError = 't';
						END IF;
					
						LET cObservaciones = cValidaPresentado;
						END IF;
					
					--valida si el cheque ya fue procesado
					IF 	bBanderaError= 'f' THEN	
						LET cValidaProceso = '';
						
						SELECT COUNT(*) INTO iNoProcesado from bditef:cce_cheques_dev
						where cvebanco = cBancoLibrado AND
						LPAD(TRIM(numcuenta) , 13, 0) = cCuentaReferencia AND
						LPAD(TRIM(numcheque) , 10, 0) = cNumCheque AND
						fechapresenta = cFechaDevol;
						
						IF iNoProcesado <> 0 THEN
							LET cValidaProceso = 'este documento ya fue procesado';
							LET bBanderaError = 't';
						END IF;
						
						LET cObservaciones = cValidaProceso;
					END IF;
					
					IF 	bBanderaError= 'f' THEN	
						LET cprocesar = 't'; --SI
					END IF;
					
					INSERT INTO bdicnweb:"informix".ccep_procesacod41detalle_tmp
					(usuario,direccionMac,bancoLibrado,descbancoLibrado,importe,cuentaReferencia,numCheque,CuentaDeposito,observaciones,motivoDevolucion,procesar)
					VALUES
					(pUsuario,pDireccionMac,cBancoLibrado,cDescbancoLibrado,mImporte,cCuentaReferencia,cNumCheque,cCuentaDeposito,cObservaciones,cMotivoDevCompleto,cprocesar);
					
				END IF;
			END FOREACH;	
			
		COMMIT WORK;
		
		LET bBanDet  = 't';
		LET ven_transacc = 0;
		
		IF bInTransaction = 't' THEN
			BEGIN WORK;
		END IF;
		
		RETURN cCodRet,bBanDet,importeTotal; 
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: SAUL ORTIZ BAEZA',
'FECHA: 07/03/2016',
'MODULO: OPERACIONES',
'FUNCIONALIDAD: Generador de Archivos',
'DESCRIPCION: Carga datos del archivo de devoluciones a tablas temporales  y se valida la informacion.',
'AUTOR: JOSÃ ANTONIO RAMIREZ FRANCO',
'FECHA MODIFICACION: 06/05/2024',
'MODIFICACION: Se ajusta el importe para los centavos y se aÃ±aden los ceros a las numeros de cuentas.',
'AUTOR: VERONICA SANCHEZ',
'FECHA MODIFICACION: 26/08/2025',
'MODIFICACION: Se ajusta SPS para contatenar el cdigo y descripcion de la devolucion, variable cMotivoDevCompleto.',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_valida_correo_ob(pRFC CHAR(13) 
                                    ,pCorreoElec CHAR(100))
RETURNING CHAR(5) AS vcodret1,
		  CHAR(100) AS vMensaje;
    
    DEFINE vcodret1 CHAR(5);
    DEFINE vcodret2 CHAR(5);
    DEFINE vcodret3 CHAR(50);
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
    
    DEFINE vExisteCte       INTEGER;
    DEFINE vExisteCorreo    SMALLINT;
	DEFINE vExisteCteCorreo INTEGER;
	DEFINE vCorreoNoValido  INTEGER;
	DEFINE vNumCte			CHAR(20);
	DEFINE vMensaje         CHAR(50);
	DEFINE vRfc		        CHAR(50);
    
    LET vcodret1 = '00000';
    LET vcodret2 = '00000';
    LET vcodret3 = '';
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';
    
    LET vExisteCte    = 0;
    LET vExisteCorreo = 0;
	LET vExisteCteCorreo = 0;
    LET vCorreoNoValido  = 0;
	LET vNumCte = '0';
    LET vMensaje = 'SE EJECUTO CORRECTAMENTE';
    LET vRfc = '';
	
	BEGIN
		
		-- // MANEJO DE EXCEPCIONES
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vcodret2 = isam_err;
				LET vcodret3 = desc_err;
				LET vMensaje = 'ERROR AL EJECUTAR EL SP';
				RETURN vcodret1, vMensaje;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/tmp/IFR/sp_valida_correo_ob.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- // VALIDA PARAMETROS DE ENTRADA
		IF (pRFC is null OR pRFC = '') OR
		   (pCorreoElec is null OR pCorreoElec = '') THEN
			LET vcodret1 = '00003';
			LET vMensaje = 'FALTAN PARÃMETROS DE ENTRADA.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA QUE EL CORREO POR INSERTAR NO SE ENCUENTRE EN LA LISTA DE CORREOS NO VALIDOS
		SELECT COUNT(id)
		  INTO vCorreoNoValido
		  FROM bdinteg:"informix".si_cat_correos_novalidos
		 WHERE correo = TRIM(pCorreoElec);
		
		IF vCorreoNoValido > 0 THEN
			LET vcodret1 = '00120';
			LET vMensaje = 'EL CORREO SE ENCUENTRA EN LA LISTA DE CORREOS NO VÃLIDOS';
			RETURN vcodret1, vMensaje;
		END IF;
		
		-- // VALIDA SI EL CORREO YA ESTA REGISTRADO		
		SELECT COUNT(*)
		  INTO vExisteCorreo
		  FROM bdinteg:"informix".si_correos
		 WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
		   AND status_correo = 'A';
		   
		IF vExisteCorreo > 1 THEN
			LET vcodret1 = '00999';
			LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 0 THEN
			RETURN vcodret1, vMensaje;
		END IF;
		
		IF vExisteCorreo = 1 THEN
			SELECT numcte
			INTO vNumCte
			FROM bdinteg:"informix".si_correos
			WHERE UPPER(correo_elec) = UPPER(pCorreoElec)
				AND status_correo = 'A';
		
			SELECT rfc
			INTO vRfc
			FROM bdinteg:"informix".si_cliente
			WHERE numcte = vNumCte;
			
			IF vRfc != pRFC THEN
				LET vcodret1 = '00999';
				LET vMensaje = 'EL CORREO YA EXISTE, VERIFIQUE.';
				RETURN vcodret1, vMensaje;
			END IF;
		END IF;
   END;

   RETURN vcodret1, vMensaje;
END PROCEDURE;