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

CREATE PROCEDURE "informix".sp_ws_login(pcAgent_trans_type_code CHAR(10),pcAgent_cd CHAR(3),pcUsuario CHAR(8),pcPassword CHAR(8),
										pcIp_origen CHAR(15),pcFecha_peticion CHAR(8),pcHora_peticion CHAR(6))
	RETURNING CHAR(5),CHAR(4),CHAR(50),CHAR(30),CHAR(8),CHAR(6);

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(4);
DEFINE cOpcode 			CHAR(4);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE cDescr_completa_mensaje 	CHAR(80);
DEFINE cId_sesion 		CHAR(80);
DEFINE cFecha_proceso	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);

DEFINE cCadena_ent		CHAR(100);
DEFINE cAgent_cd		CHAR(3);
DEFINE cUsuario			CHAR(8);
DEFINE cPassword		CHAR(8);
DEFINE cIp_origen		CHAR(15);
DEFINE cTimeout_session	CHAR(15);
DEFINE cNombre_preceso	CHAR(11);
DEFINE cPass_encripta	CHAR(15);
DEFINE cCod_retorno		CHAR(5);
DEFINE cFecha_dia		CHAR(8);
DEFINE dtFecha_dia		DATE;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err = '0000';
LET cOpcode = '';
LET cDescr_mensaje = '';
LET cDescr_completa_mensaje = '';
LET cId_sesion = '';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');

LET cCadena_ent = TRIM(NVL(pcAgent_trans_type_code,'NULL')) || '|' || TRIM(NVL(pcAgent_cd,'NULL')) || '|' || TRIM(NVL(pcUsuario,'NULL')) || '|' || TRIM(NVL(pcIp_origen,'NULL'));
LET cAgent_cd = '';
LET cUsuario = '';
LET cPassword = '';
LET cIp_origen = '';
LET cTimeout_session = '';
LET cNombre_preceso = 'sp_ws_login';
LET cPass_encripta = '';
LET cCod_retorno = '';
LET cFecha_dia = '';
LET dtFecha_dia = CURRENT::DATE;

--SET DEBUG FILE TO '/tmp/sp_ws_login.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCod_err = iSqlErr;
			LET cOpcode = cCod_err;

			LET cDescr_mensaje = '';
			LET cDescr_completa_mensaje = '';

			--Se inserta el registro con el estado de la conexion hecha, con los dato0s generado0s en el proceso0 en curso, en caso de error de informix.
			INSERT INTO bdisac:"informix".sac_ws_login(cnxn_status,agent_trans_type_code,agent_cd,usuario,password,ip_origen,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,session_id,timeout_session,user_insert,fecha_insert)
			VALUES('C',pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cId_sesion::CHAR(30),cTimeout_session,pcUsuario,CURRENT::DATE);

			--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
			INTO cCod_retorno;

			RETURN cCod_err,cOpcode,cDescr_mensaje,cId_sesion::CHAR(30),cFecha_proceso,cHora_proceso;
		END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombre_preceso,pcFecha_peticion,pcHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

	--Se valida que alguno de los parametros de entrada no venga nulo
	IF NVL(pcAgent_trans_type_code, '') = '' OR NVL(pcAgent_cd, '') = '' OR NVL(pcUsuario, '') = '' OR NVL(pcPassword, '') = '' OR NVL(pcIp_origen, '') = '' OR NVL(pcFecha_peticion, '') = '' OR NVL(pcHora_peticion, '') = '' THEN
		LET cCod_err = '9996';
	ELSE
		--Se valida que existan los parametros de entrada en las tablas
		IF EXISTS (SELECT transaccion FROM bdisac:"informix".sac_ws_transacc_ctes
				  WHERE agent_cd = pcAgent_cd AND usuario = pcUsuario AND transaccion = pcAgent_trans_type_code AND activa = 'S') THEN

			--Se obtienen lo0s valores de lo0s campo0s, para la validacio0n de lo0s parametro0s de entrada
			SELECT agent_cd,usuario,password,ip_origen
			INTO cAgent_cd,cUsuario,cPassword,cIp_origen
			FROM bdisac:"informix".sac_ws_clientes WHERE agent_cd = pcAgent_cd AND usuario = pcUsuario AND password = pcPassword AND ip_origen = pcIp_origen;

			--Se valida que sean los mismo0s valores de los parametro0s de entrada
			IF cAgent_cd = pcAgent_cd THEN
				IF cUsuario = pcUsuario THEN
					IF cPassword = pcPassword THEN
						IF cIp_origen = pcIp_origen THEN

							--Se saca la fecha del dia
							--	2013.01.24 I. Se comenta la fecha SAC para considerar la fecha del día (Sistema).
							--	SELECT fecha_hoy INTO dtFecha_dia FROM bdisac:"informix".sac_fechas;
							--	2013.01.24 F.
							LET cFecha_dia = YEAR(dtFecha_dia) || LPAD(MONTH(dtFecha_dia),2,'0') || LPAD(DAY(dtFecha_dia),2,'0');

							--Se valida que la fecha sea correcta la del servidor
							IF pcFecha_peticion = cFecha_dia THEN
								--Se crea el nuevo id sesion para el proceso0
								LET cId_sesion = TRIM(pcUsuario) || TRIM(pcPassword) || TRIM(pcFecha_peticion) || TRIM(pcHora_peticion);

								SELECT valor INTO cPass_encripta
								FROM bdisac:"informix".sac_param WHERE cod_param = 87017;

								--Se encripta el valor del id de la sesion
								EXECUTE FUNCTION "informix".ENCRYPT_TDES(TRIM(cId_sesion), TRIM(cPass_encripta))
								INTO cId_sesion;

								--Se insertan en la tabla sac_ws_bitacsesiones los mismo0s valores de sac_ws_clientes a excepcion del id sesion, el cual ira encriptado
								INSERT INTO bdisac:"informix".sac_ws_bitacsesiones(agent_cd,usuario,password,ip_origen,id_sesion,fecha_insert,hora_insert)
								SELECT agent_cd,usuario,password,ip_origen,cId_sesion, CURRENT::DATE, cHora_proceso
								FROM bdisac:"informix".sac_ws_clientes
								WHERE agent_cd = pcAgent_cd AND usuario = pcUsuario AND password = pcPassword AND ip_origen = pcIp_origen;

								--Se actualiza el id secion activa de sac_ws_clientes con id sesion encriptado
								UPDATE bdisac:"informix".sac_ws_clientes SET id_sesion_act = cId_sesion, fecha_insert = CURRENT::DATE, hora_insert = cHora_proceso
								WHERE agent_cd = pcAgent_cd AND usuario = pcUsuario AND password = pcPassword AND ip_origen = pcIp_origen;

								--Se actualiza la tabla sac_ws_procesos con el estatus y el codigo de retorno del sp, para saber que fue exitoso0
								EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
								INTO cCod_retorno;

								--Se inserta el registro con el estado de la conexion hecha, con los dato0s generado0s en el proceso0
								SELECT valor INTO cTimeout_session
								FROM bdisac:"informix".sac_param WHERE cod_param = 87015;

								SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
								INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
								FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCod_err;
								IF cOpcode IS NULL THEN
									LET cOpcode = cCod_err;
									LET cDescr_mensaje = 'Código no registrado en catálogo.';
									LET cDescr_completa_mensaje = 'Código no registrado en catálogo.';
								END IF;

								INSERT INTO bdisac:"informix".sac_ws_login(cnxn_status,agent_trans_type_code,agent_cd,usuario,password,ip_origen,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,session_id,timeout_session,user_insert,fecha_insert)
								VALUES('A',pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cId_sesion::CHAR(30),cTimeout_session,pcUsuario,CURRENT::DATE);

							ELSE
								LET cCod_err = '9978';
							END IF;
						ELSE
							LET cCod_err = '9997';
						END IF;
					ELSE
						LET cCod_err = '9979';
					END IF;
				ELSE
					LET cCod_err = '9980';
				END IF;
			ELSE
				LET cCod_err = '9998';
			END IF;
		ELSE
			LET cCod_err = '9999';
		END IF;
	END IF;
	IF cCod_err <> '0000' THEN

		--Se obtienen los mensajes de error asi como el codigo del mensaje
		SELECT NVL(opcode, ''),NVL(opcode_sd, ''),NVL(opcode_ds, '')
		INTO cOpcode,cDescr_mensaje,cDescr_completa_mensaje
		FROM bdisac:"informix".sac_ws_catmensajes WHERE agent_trans_type_code = pcAgent_trans_type_code AND opcode = cCod_err;

		--En caso de que no exista el codigo del mensaje se les asigna otros valores
		IF cOpcode IS NULL THEN
			LET cOpcode = cCod_err;
			LET cDescr_mensaje = 'Código no registrado en catálogo.';
			LET cDescr_completa_mensaje = 'Código no registrado en catálogo.';
		END IF;

		--Se inserta el registro con el estado de la conexion hecha, con los dato0s del erro0r generado0 en el proceso0
		INSERT INTO bdisac:"informix".sac_ws_login(cnxn_status,agent_trans_type_code,agent_cd,usuario,password,ip_origen,fecha_peticion,hora_peticion,opcode,descr_mensaje,descr_completa_mensaje,fecha_proceso,hora_proceso,session_id,timeout_session,user_insert,fecha_insert)
		VALUES('C',pcAgent_trans_type_code,pcAgent_cd,pcUsuario,pcPassword,pcIp_origen,pcFecha_peticion,pcHora_peticion,cOpcode,cDescr_mensaje,cDescr_completa_mensaje,cFecha_proceso,cHora_proceso,cId_sesion::CHAR(30),cTimeout_session,pcUsuario,CURRENT::DATE);

		--Se inserta el error generado en la tabla sac_ws_errores Y Se actualiza la tabla sac_ws_procesos con el codigo de error generado
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, LPAD(cCod_err,5,'0'), cDescr_mensaje, '', '', cCadena_ent, pcUsuario, pcFecha_peticion, pcHora_peticion)
		INTO cCod_retorno;
	END IF;

	RETURN LPAD(cCod_err,5,'0'),cOpcode,cDescr_mensaje,cId_sesion::CHAR(30),cFecha_proceso,cHora_proceso;
END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se crea sp para validar una solicitud de loggeo',
'AUTOR : José Luís Polanco B.',
'FECHA : 31 de Octubre 2012',
'VERSION: 1.0',
'BD: BDISAC',
'SISTEMA : Sistema Administrador de Convenios';

CREATE PROCEDURE "informix".sp_consulta_linea_base_principal(pCaptura CHAR(20),
												pImporte CHAR(20), pNumCuenta CHAR(20), pLlaveGDF INTEGER)
	RETURNING CHAR(5) AS CodRetorno,
	CHAR AS LlevaDatosAdicionales,
	CHAR(700)  AS RespuestaAMostrar,
	CHAR(2000)  AS RespuestaDecodificada;


	--Definicion de Variables
	DEFINE iSqlErr 					INTEGER;
	DEFINE cCodRet 					CHAR(5);
	DEFINE cCodRet2     			CHAR(5);
	DEFINE i						INTEGER;
	DEFINE k 						CHAR(1);
	DEFINE cCadena 					CHAR(20);
	DEFINE cConcepto    			CHAR(250);
	DEFINE cLeyenda     			CHAR(20);
	DEFINE cTipoLicencia 			CHAR(1);
	DEFINE cTipoReferencia 			CHAR(10);
	DEFINE cDescripcionConcepto		CHAR(300);

	DEFINE cPeriodo					CHAR(300);
	DEFINE cPlaca 					CHAR(20);	--*
	DEFINE cModelo 					CHAR(15);
	DEFINE cFolio 					CHAR(25);	--*
	DEFINE cModeloFolio				CHAR(15);
	DEFINE cCantidad 				CHAR(15);
	DEFINE cFolioInfraccion 		CHAR(15);
	DEFINE cAnioInfraccion  		CHAR(10);
	DEFINE cTipoHolograma  			CHAR(150);
	DEFINE cMarca 					CHAR(50);
	DEFINE cVerificentro  			CHAR(10);

	DEFINE cReferencia 				CHAR(50);	--*
	DEFINE cEjercicioFiscal 		CHAR(4);

	DEFINE cRFC 					CHAR(12);
	DEFINE cMES						CHAR(50);
	DEFINE cPredial 				CHAR(25);	--*
	DEFINE cTipoOperacion  			CHAR(50);
	DEFINE cTramite 	  			CHAR(300);
	DEFINE cSubconcepto   			CHAR(300);
	DEFINE cTipoDeclaracion			CHAR(300);
	DEFINE cVigencia 				CHAR(30);

	DEFINE cRespuestaMostrar 		CHAR(700);
	DEFINE cRespuestaDecodificada	CHAR(2000);

	DEFINE cOrigen					CHAR(40);
	DEFINE cPrecio					CHAR(40);
	DEFINE cAdmonTributaria			CHAR(55);
	DEFINE cEjercicio				CHAR(100);
	DEFINE cBimestre				CHAR(20);
	DEFINE cLlevaDatosAdicionales	CHAR;

	--Inicializacion de Variables
	LET iSqlErr 				= 0;
	LET cCodRet 				= '00000';
	LET cCodRet2   				= '';
	LET i       				= 0;
	LET cCadena 				= '';
	LET k						= '';
	LET cConcepto 				= '';
	LET cLeyenda    			= '';
	LET cTipoLicencia			= '';
	LET cTipoReferencia			= '';
	LET cDescripcionConcepto 	= '';
	LET cPeriodo				= '';
	LET cFolio					= '';

	LET cPeriodo				= '';
	LET cPlaca 					= '';
	LET cModeloFolio			= '';
	LET cCantidad 				= '';
	LET cFolioInfraccion 		= '';
	LET cAnioInfraccion 		= '';
	LET cTipoHolograma 			= '';
	LET cMarca 					= '';
	LET cVerificentro 			= '';

	LET cReferencia 			= '';
	LET cEjercicioFiscal 		= '';

	LET cRFC 					= '';
	LET cMES 			   		= '';
	LET cPredial 				= '';
	LET cTipoOperacion  		= '';
	LET cTramite 	  			= '';
	LET cSubconcepto 			= '';
	LET cTipoDeclaracion		= '';
	LET cVigencia 				= '';

	LET cRespuestaMostrar		= '';
	LET cRespuestaDecodificada	= '';

	LET cOrigen					= '';
	LET cPrecio					= '';
	LET cAdmonTributaria		= '';
	LET cEjercicio				= '';
	LET cBimestre				= '';
	LET cLlevaDatosAdicionales	= '0';

	--SET DEBUG FILE TO '/home/informix/bibiana/sp_decodifica_linea_base_principal.out';
	--TRACE ON;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET  cCodRet = iSqlErr;
				RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
			END IF;
		END EXCEPTION;

		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;

		IF (pImporte::INTEGER < 1) THEN --10
			--EL IMPORTE DEL PAGO ES MENOR A 10 PESOS
			LET cCodRet = '00001';

		ELSE

			IF(LENGTH(TRIM(NVL(pCaptura,'')))==20) THEN
				IF(pCaptura[1,2] IN ('01','03','05','07','09','11','13','14'))THEN
				--TRANSITO, VIALIDAD Y MEDIO AMBIENTE LICENCIAS
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_licencias(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cTipoLicencia, cPeriodo, cTipoReferencia, cDescripcionConcepto;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Tipo='||TRIM(NVL(cTipoLicencia,''))||'|Periodo='||TRIM(NVL(cPeriodo,''))||'|Referencia='||TRIM(NVL(cTipoReferencia,''))||'|';
				ELIF(pCaptura[1,2] IN ('20','21'))THEN 
				--PERMISOS ADMINISTRATIVOS TEMPORALES REVOCABLES 
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificadatospermisosadmintemrevo(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Folio='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('36','37','38','39','40','41','42','43','44','45','46'))THEN --- Se quita el concepto 48 BGV
				--TRAMITES DE VEHICULOS PARTICULARES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosTramitesVehiculares(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cOrigen, cReferencia, cMarca, cModelo, cPlaca;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cOrigen,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cMarca,'')) || '|' || TRIM(NVL(cModelo,'')) || '|' || TRIM(NVL(cPlaca,'')) || '|';
				ELIF(pCaptura[1,2] IN ('49'))THEN
				--MULTAS DE TRANSITO
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_multas(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Folio Infracción='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('50','51','52'))THEN
				--MEDIO AMBIENTE
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_medio(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPlaca, cModelo, cMarca, cFolioInfraccion, cAnioInfraccion, cVerificentro, cTipoHolograma, cCantidad,cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Placa='||TRIM(NVL(cPlaca,''))||'|Modelo='||TRIM(NVL(cModelo,''))||'|Marca='||TRIM(NVL(cMarca,''))||'|Folio Infracción='||TRIM(NVL(cFolioInfraccion,''))||'|Año Infracción='||TRIM(NVL(cAnioInfraccion,''))||'|Clave Verificentro='||TRIM(NVL(cVerificentro,''))||'|Tipo Holograma='||TRIM(NVL(cTipoHolograma,''))||'|Cantidad='||TRIM(NVL(cCantidad,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|';
				ELIF(pCaptura[1,2] IN ('54','57','58','59','60','61','62','63','64','65','66','67','68','69','70','71','72','73','74','75','76','77'))THEN
				--TRAMITES DEL REGISTRO CIVIL
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosRegistroCivil(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio, cCantidad, cPrecio, cReferencia, cAdmonTributaria, cConcepto;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					IF(pCaptura[1,2] == ('77')) THEN
					--SE OMITE '|' || TRIM(NVL(cAdmonTributaria,'')) || VIENE EN EL PDF PERO NO EN EL RECIBO OFICIAL
						LET cRespuestaDecodificada = '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
					ELSE
						LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|' || TRIM(NVL(cCantidad,'')) || '|' || TRIM(NVL(cPrecio,'')) || '|' || TRIM(NVL(cReferencia,'')) || '|' || TRIM(NVL(cAdmonTributaria,'')) || '|' || TRIM(NVL(cConcepto,'')) || '|';
					END IF;

				ELIF(pCaptura[1,2] IN ('78','79'))THEN
				--SERVICIOS DE LA POLICIA
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioPolicia(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cFolio;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cFolio,'')) || '|';
				ELIF(pCaptura[1,2] IN ('80','81'))THEN
				--IMPUESTO PREDIAL
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosImpuestoPredial(pCaptura, pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cPredial, cEjercicio, cBimestre;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cPredial,'')) || '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
				ELIF(pCaptura[1,2] IN ('82','83'))THEN
				--DERECHOS POR SUMINISTRO DE AGUA
					EXECUTE PROCEDURE bdisac:"informix".sp_decodificaDatosServicioAgua(pCaptura, pImporte, pNumCuenta, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cEjercicio, cBimestre;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|' || TRIM(NVL(cDescripcionConcepto,'')) || '|';
					LET cRespuestaDecodificada = '|' || TRIM(NVL(cEjercicio,'')) || '|' || TRIM(NVL(cBimestre,'')) || '|';
					LET cLlevaDatosAdicionales = '1';
				ELIF(pCaptura[1,2] IN ('84','85','86','87'))THEN
				--TENENCIA Y DERECHOS VEHICULARES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_vehicular(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto,  cReferencia, cModeloFolio, cEjercicioFiscal;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|';
					LET cRespuestaDecodificada = '|Referencia='||TRIM(NVL(cReferencia,''))||'|Modelo o Folio='||TRIM(NVL(cModeloFolio,''))||'|Ejercicio Fiscal='||TRIM(NVL(cEjercicioFiscal,''))||'|';
					LET cLlevaDatosAdicionales = '1';
				ELIF(pCaptura[1,2] IN ('88','96','89','90','91','92','93','94','97','98'))THEN --- Se quita el concepto 94 y 95 ya que no son permitidos en el portal. BGV
				--OTRAS CONTRIBUCIONES
					EXECUTE PROCEDURE bdisac:"informix".sp_decodifica_linea_base_otras(pCaptura ,pImporte, pLlaveGDF) INTO cCodRet2, cDescripcionConcepto, cRFC, cEjercicioFiscal, cMes, cPredial, cTipoOperacion, cFolio, cTramite,cSubconcepto,cReferencia,   cTipoDeclaracion, cVigencia, cLlevaDatosAdicionales;
					LET cCodRet = cCodRet2;
					LET cRespuestaMostrar = '|Concepto='||TRIM(NVL(cDescripcionConcepto,''))||'|Subconcepto='||TRIM(NVL(cSubconcepto,''))||'|';
					LET cRespuestaDecodificada = '|RFC='||TRIM(NVL(cRFC,''))||'|Ejercicio='||TRIM(NVL(cEjercicioFiscal,''))||'|Mes='||TRIM(NVL(cMes,''))||'|Cuenta Predial='||TRIM(NVL(cPredial,''))||'|Tipo de Operación='||TRIM(NVL(cTipoOperacion,''))||'|Folio='||TRIM(NVL(cFolio,''))||'|Trámite='||TRIM(NVL(cTramite,''))||'|Referencia='||TRIM(NVL(cReferencia,''))||'|Tipo de Declaración='||TRIM(NVL(cTipoDeclaracion,''))||'|Vigencia='||TRIM(NVL(cVigencia,''))||'|';
					IF(pCaptura[1,2] IN('91','94','95','97','98')AND(cLlevaDatosAdicionales='0'))THEN
						LET cLlevaDatosAdicionales = '0';
					ELSE
						LET cLlevaDatosAdicionales = '1';
					END IF;
				ELSE
					--LA CLAVE DE PAGO NO CORRESPONDE A LAS OPERACIONES VALIDAS
					LET cCodRet = '00002';
				END IF;
			ELSE
				--LA LONGITUD DE LA LINEA DE CAPTURA ES DIFERENTE A 20 CARACTERES
				LET cCodRet = '00001';
			END IF;

		END IF;
		--LET cCodRet = '00000';
		RETURN cCodRet, cLlevaDatosAdicionales, cRespuestaMostrar,cRespuestaDecodificada;
	END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: DECODIFICA LA LINEA BASE Y LISTA LOS CAMPOS A MOSTRAR',
'AUTOR : Liliana Perez',
'FECHA : 27-04-2018',
'VERSION: ',
'BD: bdisac',
'Folio: ';

CREATE PROCEDURE "informix".sp_guardasoldespagosky(pImporteTransaccion money(10,2), pFolioSuc char(16), pNumCuenta char(12), pUsuario char(8)) 
	--RETORNOS
	RETURNING
	CHAR(5) AS cCodigoRet;
	
	--Definicion de Variables
	DEFINE cCodigoRet  CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cEnteId CHAR(3);
	DEFINE cMpelId CHAR(15);
	DEFINE cFolio_pago CHAR(10);
	DEFINE cAutorizacion CHAR(10);
	
	--Inicializacion de variables
	LET cCodigoRet = '00000';
	LET iSqlErr = 0;
	LET cEnteId = '0';
	LET cMpelId = '0';
	LET cFolio_pago ='';
	LET cAutorizacion = '';

	--SET DEBUG FILE TO '/home/sysifx/JesusAlbertoLI';
	--TRACE ON;
	
	BEGIN 
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodigoRet = iSqlErr;
				RETURN  TRIM(NVL(cCodigoRet,""));
			END IF;
		END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO dirty READ;
		
		 --Validamos parámetros para que no sean nulos
		 IF NVL(pImporteTransaccion,'') = '' OR NVL(pFolioSuc,'') = '' OR NVL(pNumCuenta,'') = '' OR NVL(pUsuario,'') = '' THEN
		 LET cCodigoRet = '00001';		 RETURN NVL(cCodigoRet,"");
         ELSE	
		 
		 SELECT mpel_id INTO cMpelId FROM sac_sky_wsgpago where folio_suc = pFolioSuc;
		 SELECT autorizacion INTO cAutorizacion FROM sac_sky_wsgpago where folio_suc = pFolioSuc; 
		 SELECT valor into cEnteId FROM sac_param WHERE cod_param = '114';

		 
		 LET cFolio_pago = SUBSTR(pFolioSuc, 7,  10);	
		 
		 INSERT INTO "informix".sac_sky_wsgreverso(txn_status,ente_id,numcuenta,fechadepbanco,importetrans,folio_pago,autorizacion_s,mpel_id_s,uso_futuro1,uso_futuro2,uso_futuro3,folio_suc,usuario_insert,fecha_insert) 
		 VALUES('C',cEnteId,pNumCuenta,today,pImporteTransaccion,cFolio_pago,cAutorizacion,cMpelId,null,null,null,pFolioSuc,pUsuario,today);
		  	
	 	
		 IF dbinfo('sqlca.sqlerrd2') = 0 THEN
			LET cCodigoRet= '00002';
		 END IF;	
	END IF;
	
	RETURN  TRIM(NVL(cCodigoRet,""));
	
	END;
END PROCEDURE;