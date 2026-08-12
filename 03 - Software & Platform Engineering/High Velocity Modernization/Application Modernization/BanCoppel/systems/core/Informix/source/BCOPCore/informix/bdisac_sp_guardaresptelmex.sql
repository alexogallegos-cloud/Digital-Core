CREATE PROCEDURE "informix".sp_guardaresptelmex(idConsulta CHAR(20), idPago CHAR(20), numTel CHAR(10), usuario CHAR(8), sucursal CHAR(4), fecha CHAR(8), hora CHAR(6), folioSuc CHAR(16), formaPago CHAR(1), importe CHAR(18), numTc CHAR(20), gen1 CHAR(20), gen2 CHAR(20), gen3 CHAR(20))

RETURNING CHAR (5) AS cCodRet, CHAR (50) AS vMensaje;
   
	DEFINE cCodRet		CHAR (5);
	DEFINE vMensaje		CHAR (50);
	DEFINE iSqlErr		INTEGER;
	DEFINE iIsamError	INTEGER;
	DEFINE cCod_retorno	CHAR(5);
	
	LET cCodRet		= '00000';
	LET iSqlErr		= 0;
	LET iIsamError	= 0;
	LET vMensaje	='PROCESO EXITOSO';
	LET cCod_retorno = '';
	
   
   BEGIN
	ON EXCEPTION SET iSqlErr,iIsamError
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET vMensaje ='ERROR ' || cCodRet || ', al grabar el registro ';
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
			INTO cCod_retorno;

			RETURN cCodRet, 'ERROR AL GRABAR REGISTRO';
		END IF;
	END EXCEPTION;
	
	--SET DEBUG FILE TO '/informix/noe/sp_guardaresptelmex.out';
	--TRACE ON;	
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3; 

	if idPago::integer <= 0 then
		LET cCodRet = 01010;
		LET vMensaje ='ERROR ' || cCodRet || ', idPago Invalido (' || idPago || ')';

		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,'sp_guardaresptelmex', cCodRet, vMensaje, iSqlErr, iIsamError, 'tel: ' || trim(numTel) || ', idConsulta: ' || trim(idConsulta) || ', idPago: ' || trim(idPago) || ', suc: ' || trim(sucursal) || ', folsuc: ' || trim(folioSuc), usuario, fecha, hora)
		INTO cCod_retorno;

		RETURN cCodRet, vMensaje;
	end if;


	INSERT INTO "informix".sac_pagos_telmex(idconsulta, idpago, numtel, usuario, sucursal, fecha, hora, foliosuc, formapago, importe, numtc, gen1, gen2, gen3, fecha_insert) 
    VALUES(idConsulta, idPago, numTel, usuario, sucursal, fecha, hora, folioSuc, formaPago, importe, numTc, gen1, gen2, gen3, CURRENT);
			
	  
	RETURN cCodRet, vMensaje;

END;
END PROCEDURE
DOCUMENT
'AUTOR : 93440138 - Noe Medina R.',
'DESCRIPCION: Graba la respuesta de Pagos Telmex (BUS)',
'FOLIO: ',
'FECHA : 19-08-2021',
'VERSION: 20210819.1252',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_app_paymentrejection(pCompanyCode CHAR (3),
													pChannelId CHAR (3),
													pTokenId CHAR (80),
													pLanguage CHAR (5),
													pApiVersion CHAR (6),
													pClientSoftwareVersion CHAR (6),
													pUniqueReferenceNumber CHAR (16),
													pReferenceNumber CHAR (30),
													pProcessReasonTypeCode CHAR (4),
													pCodeRequest CHAR (3),
													pChannelIdRequest CHAR (3),
													pTaxIdentificationNumber CHAR (20),
													pLocationUnit CHAR (15),
													pNumberRequest CHAR (15),
													pTypeCode CHAR (3),
													pCountryCode CHAR (3),
													pStateCode CHAR (3),
													pUserId CHAR (20),
													pSupervisorId CHAR (20),
													pTerminalId CHAR (15),
													pProcessDateRequest CHAR (8),
													pProcessTimeRequest CHAR (6),
													pCode CHAR (4),
													pMessageResponse CHAR (255),
													pCodeDetail CHAR (4),
													pMessageDetail CHAR (255),
													pProcessDateResponse CHAR (8),
													pProcessTimeResponse CHAR (6),
													puniquereferencenumberrequest CHAR (16),
													pGlobalTrackingNumber CHAR (20),
													pOrderStatusCode CHAR (3),
													pOrderStatusDate CHAR (8),
													pOrderStatusTime CHAR (6))
												   
--DATOS A REGRESAR---
RETURNING CHAR(5)  AS cCodRetorno,
		  CHAR(80) AS cDesc_Error,
		  CHAR(16) As cRemesa,
		  CHAR(1)  AS cFlg_confirm_ctral,
		  CHAR(8)  AS cfecha_proceso,
		  CHAR(6)  AS cHora_proceso;

--DEFINICION DE VARIABLES--
DEFINE cCodRetorno 		  CHAR(5);
DEFINE cDesc_Error		  CHAR(80);
DEFINE cRemesa 			  CHAR(16);
DEFINE cFlg_confirm_ctral CHAR(1);
DEFINE cfecha_proceso     CHAR(8);
DEFINE cHora_proceso 	  CHAR(6);	
DEFINE cCnxn_status  		CHAR(1);
DEFINE cValor 				CHAR(200);
DEFINE iSqlErr 				INTEGER;
DEFINE cValCode 			CHAR(100);
DEFINE cValChannell			CHAR(100);
DEFINE cTermi 				CHAR(100);
DEFINE cValUsu 				CHAR(100);
DEFINE cVaLTer 				CHAR(200);
DEFINE cValocUni 			CHAR(100);
DEFINE cValTypCode 			CHAR(100);
DEFINE cValCouCode 			CHAR(100);
DEFINE cIdentNum 			CHAR(100);
define cStateCode 			CHAR(100);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cCadena_ent          CHAR(100);
DEFINE iFlg_insertaerrorws	INTEGER;
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cCodRet2             CHAR(5);
DEFINE cDescError			CHAR(80);
define iIsamErr 			INTEGER;
DEFINE cFechaInsert    		CHAR(8);
DEFINE iCod_param     		INTEGER;



--INICIALIZACION DE VARIABLES--		
LET cCodRetorno = '00000';	
LET cDesc_Error = '';
LET cRemesa  = '';			 
LET cfecha_proceso = '';
LET cHora_proceso = '';	 
LET cCnxn_status = 'C';
LET cValor = '';
LET iSqlErr = 0;
LET cValCode = '';
LET cValChannell ='';
LET cTermi = '';
LET cValUsu= '';
LET cVaLTer='';
LET cValocUni  = '';
LET cValTypCode ='';
LET cValCouCode  ='';
LET cIdentNum ='';
let cStateCode = '';
let cNombreSPL = 'sp_app_paymentRejection';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	iFlg_insertaerrorws	 = 1;
LET	cFlg_confirm_ctral	 = '0';
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCodRet2	 		 = '00000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET iIsamErr			 = 0;
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET iCod_param  = 0;


   --SET DEBUG FILE TO '/informix/EPG/sp_app_paymentRejection.out';
   --TRACE ON;

BEGIN
--Erro informix
    ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRetorno = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment (cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
			VALUES(NVL(cCnxn_status,'C') ,'',pCompanyCode,pChannelId,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,pTaxIdentificationNumber,pLocationUnit,pNumberRequest,pTypeCode,pCountryCode,pStateCode,pUserId,'',pTerminalId,pProcessDateRequest,pProcessTimeRequest,pCode,pMessageResponse,pCodeDetail,pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,
			pOrderStatusDate,pOrderStatusTime,'',CURRENT);
			
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
			
			RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;
    END EXCEPTION;		

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--Se inserta el registro del proceso en curso
	INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
	VALUES(cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','', TRIM(pUserId), current::date, cHoraInsert);	
	
	IF TRIM(pUniqueReferenceNumber) = '' OR  TRIM(pReferenceNumber) = ''THEN
		LET cCodRetorno = '1100';		
	END IF;

	IF TRIM(pCompanyCode) = ''  THEN 
		
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pChannelId) = '' THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF
	END IF
	
	IF TRIM(pCode) = '' THEN
		LET cCodRetorno = '9999';
	END IF;
	
	
	IF cCodRetorno::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
		
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87102,87103,87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87102 THEN
				LET cValCode = TRIM(cValor);
			ELIF iCod_param=87103 THEN
				LET cValChannell = TRIM(cValor);
			ELIF iCod_param= 87104 THEN
				LET cValocUni = TRIM(cValor);
			ELIF iCod_param= 87105 THEN
				LET cValTypCode = TRIM(cValor);
			ELIF iCod_param= 87106 THEN
				LET cValCouCode = TRIM(cValor);
			ELIF iCod_param= 87112 THEN
				LET cTermi= TRIM(cValor);
			ELIF iCod_param= 87113 THEN
				LET cIdentNum= TRIM(cValor);
			ELIF iCod_param= 87114 THEN
				LET cStateCode= TRIM(cValor);
				END IF
		END FOREACH

		
		LET cVaLTer = TRIM(cTermi) || TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '06'
		WHERE estatus_getorder in ('04', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRetorno = '1100';
		END IF;
	END IF;
	
	IF cCodRetorno::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRetorno;


		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '04'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
				
		INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,Process_Type_Code,CompanyCode,ChannelId,TokenId,Language,ApiVersion,ClientSoftwareVersion,UniqueReferenceNumber,ReferenceNumber,ProcessReasonTypeCode,CodeRequest,ChannelIdrequest,TaxIdentificationNumber,LocationUnit,NumberRequest,TypeCode,CountryCode,StateCode,UserId,SupervisorId,TerminalId,ProcessDateRequest,ProcessTimeRequest,Code,MessageResponse,CodeDetail,MessageDetail,ProcessDateResponse,ProcessTimeResponse,uniquereferencenumberrequest,GlobalTrackingNumber,OrderStatusCode,OrderStatusDate,OrderStatusTime,user_insert,fecha_insert)
		 
		VALUES(cCnxn_status,'PMCO',pCompanyCode,cValChannell,pTokenId,pLanguage,pApiVersion,pClientSoftwareVersion,pUniqueReferenceNumber,		
		 pReferenceNumber,'PRMJ',pCodeRequest,pChannelIdrequest,cIdentNum,cValocUni,pNumberRequest,cValTypCode,cValCouCode,cStateCode,cValUsu,pSupervisorId,cVaLTer,pProcessDateRequest,pProcessTimeRequest,cValCode,pMessageResponse,pCodeDetail,	pMessageDetail,pProcessDateResponse,pProcessTimeResponse,puniquereferencenumberrequest,pGlobalTrackingNumber,pOrderStatusCode,pOrderStatusDate,pOrderStatusTime,cValUsu,CURRENT);
		
		 
		EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRetorno, '',iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
		INTO cCodRet2;

		RETURN cCodRetorno, cDescError, pUniqueReferenceNumber, cFlg_confirm_ctral, cFechaInsert,cHoraInsert;

END;
END PROCEDURE
DOCUMENT
'FOLIO: 230142-150, "RQM 10 809  Pago de Remesas Appriza con abono automático en cuentas de captación ',
'AUTOR : Viridiana Paredes Romero',
'FECHA : 15/11/2016',
'DESCRIPCION: Se crear stored procedure para guardar registros en la tabla sac_app_confirmpayment ',
'BD: bdisac ';

CREATE PROCEDURE "informix".sp_app_confirmpayment(  pCompanyCode				 CHAR (3),	
													pChannelId                   CHAR (3),
													pTokenId                     CHAR (80),
													pLanguage                    CHAR (5),
													pApiVersion                  CHAR (6),
													pClientSoftwareVersion       CHAR (6),
													pUniqueReferenceNumber       CHAR (16),
													pReferenceNumber             CHAR (30),
													pCodeRequest                 CHAR (3),
													pChannelIdRequest            CHAR (3),
													pTaxIdentificationNumber     CHAR (20),
													pLocationUnit                CHAR (15),
													pNumberRequest               CHAR (15),
													pTypeCode                    CHAR (3),
													pCountryCode                 CHAR (3),
													pStateCode                   CHAR (3),
													pUserId                      CHAR (20),
													pSupervisorId                CHAR (20),
													pTerminalId                  CHAR (15),
													pProcessDateRequest          CHAR (8),
													pProcessTimeRequest          CHAR (6),
													pCode                        CHAR (4),
													pMessageResponse             CHAR (255),
													pCodeDetail                  CHAR (4),
													pMessageDetail               CHAR (255),
													pProcessDateResponse         CHAR (8),
													pProcessTimeResponse         CHAR (6),
													pUniqueReferenceNumberReques CHAR (16),
													pGlobalTrackingNumber        CHAR (20),
													pOrderStatusCode             CHAR (3),
													pOrderStatusDate             CHAR (8),
													pOrderStatusTime             CHAR (6)
													)

RETURNING CHAR(5)  AS CodRetorno,
		  CHAR(80) AS Desc_Error,
		  CHAR(16) As Remesa,
		  CHAR(1)  AS Flg_confirm_ctral,
		  CHAR(8)  AS fecha_proceso,
		  CHAR(6)  AS Hora_proceso;

--SE DECLARAN VARIABLES.
DEFINE iSqlErr 				INTEGER;
DEFINE iIsamErr 			INTEGER;
DEFINE cCodRet 				CHAR(5);
DEFINE cCodRet2             CHAR(5);
DEFINE cOpCode				CHAR(4);
DEFINE cDescError			CHAR(80);
DEFINE cNombreSPL   		CHAR(30);
DEFINE cFechaInsert    		CHAR(8);
DEFINE cHoraInsert	   		CHAR(6);
DEFINE cValor       		CHAR(100);
DEFINE iCod_param     		INTEGER;
DEFINE cCadena_ent          CHAR(100);
DEFINE cCnxn_status			CHAR(1);
DEFINE cFlg_confirm_ctral	CHAR(1);
DEFINE iFlg_insertaerrorws	INTEGER;

--SET DEBUG FILE TO "/informix/EPG/sp_app_confirmpayment.out";
--TRACE ON; 
--Inicializacion de Variables
LET iSqlErr 			 = 0;
LET iIsamErr			 = 0;
LET cCodRet		 		 = '00000';
LET cCodRet2	 		 = '00000';
LET cOpCode				 = '0000';
LET cDescError	 		 = 'CONFIRMACION CFPA EXITOSA';
LET cNombreSPL   		 = 'sp_app_confirmpayment';
LET cFechaInsert    	 = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHoraInsert    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cValor       		 = '';
LET cCadena_ent			 =  TRIM(NVL(pUniqueReferenceNumber,'NULL'))||'|'||TRIM(NVL(pUserId,'NULL'))||'|'||TRIM(NVL(pProcessDateRequest,'NULL'))||'|'||TRIM(NVL(pProcessTimeRequest,'NULL'));
LET	cCnxn_status		 = 'C';
LET	cFlg_confirm_ctral	 = '0';
LET	iFlg_insertaerrorws	 = 1;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	

BEGIN
-- ERRORES DE INFORMIX
	ON EXCEPTION SET iSqlErr,iIsamErr
		IF iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			LET cDescError = 'Error de informix.';
			LET iFlg_insertaerrorws = 1;
			
			
			INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
			VALUES(NVL(cCnxn_status,'C'),'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
			INTO cCodRet2;
			
		END IF;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
	
		RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
	END EXCEPTION;
	
	SELECT valor 
	INTO pUserId
	FROM bdisac:"informix".sac_param
	WHERE cod_param = '87115';
	
	--INSERT INTO bdisac:"informix".sac_ws_procesos (proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert) 
	--VALUES (cNombreSPL,pProcessDateRequest,pProcessTimeRequest,'0','',TRIM(pUserId),current::date,cHoraInsert);
	
	IF TRIM(NVL(pUniqueReferenceNumber,'')) = '' OR TRIM(NVL(pReferenceNumber,''))='' THEN
		LET cCodRet = '1100';
		
	END IF
	IF TRIM(NVL(pCompanyCode,'')) = '' THEN
		SELECT valor 
		INTO pCompanyCode
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87102';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF
	IF TRIM(NVL(pChannelId,''))=''THEN
		SELECT valor 
		INTO pChannelId
		FROM bdisac:"informix".sac_param
		WHERE cod_param = '87103';
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF
	END IF

	IF TRIM(NVL(pCode,''))=''THEN
		LET cCodRet = '9999';
	END IF
	
	IF cCodRet::INTEGER = 0 AND pCode::INTEGER = 0 THEN
		FOREACH 
			SELECT cod_param,valor 
			INTO iCod_param,cValor
			FROM bdisac:"informix".sac_param 
			WHERE empresa = '001'
			AND cod_param IN (87104,87105,87106,87112,87113,87114)
			ORDER BY cod_param
			
			IF iCod_param=87104 THEN
				LET pLocationUnit = TRIM(cValor);
			ELIF iCod_param=87105 THEN
				LET pTypeCode = TRIM(cValor);
			ELIF iCod_param=87106 THEN
				LET pCountryCode = TRIM(cValor);
			ELIF iCod_param=87112 THEN
				LET pNumberRequest = TRIM(cValor);
			ELIF iCod_param=87113 THEN
				LET pTaxIdentificationNumber = TRIM(cValor);
			ELIF iCod_param=87114 THEN
				LET pStateCode = TRIM(cValor);
			END IF
		END FOREACH
	
		LET pTerminalId = TRIM(pNumberRequest)||TRIM(pUserId);
		LET cCnxn_status = 'A';
		LET pSupervisorId='';	
		LET cFlg_confirm_ctral = '1';
		LET iFlg_insertaerrorws = 2;
		
		--CONSULTAR Y ACTUALIZA LOS STATUS DE LAS REMESAS.
		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '05'
		WHERE estatus_getorder in ('03', '12')
		AND UniqueReferenceNumber = pUniqueReferenceNumber;
		
		IF dbinfo("sqlca.sqlerrd2") = 0 THEN 
			LET cCodRet = '1100';
		END IF;
	ELSE 
		LET cCodRet = '1100';
	END IF;
		
	IF cCodRet::INTEGER <> 0  THEN
		LET cCnxn_status = 'C';
		LET cFlg_confirm_ctral = '0';
		LET iFlg_insertaerrorws = 1;
		SELECT opcode_ds
		INTO cDescError
		FROM bdisac:'informix'.sac_app_cat_mensajes
		WHERE agent_trans_type_code = 'CFPA'
		AND opcode = cCodRet;

		UPDATE bdisac:"informix".sac_app_getorder
		SET estatus_getorder = '03'
		WHERE estatus_getorder = '12'
		AND UniqueReferenceNumber = pUniqueReferenceNumber;

	END IF
	
	INSERT INTO bdisac:"informix".sac_app_confirmpayment(cnxn_status,process_type_code,companycode,channelid,tokenid,language,apiversion,clientsoftwareversion,uniquereferencenumber,referencenumber,processreasontypecode,coderequest,channelidrequest,taxidentificationnumber,locationunit,numberrequest,typecode,countrycode,statecode,userid,supervisorid,terminalid,processdaterequest,processtimerequest,code,messageresponse,codedetail,messagedetail,processdateresponse,processtimeresponse,uniquereferencenumberrequest,globaltrackingnumber,orderstatuscode,orderstatusdate,orderstatustime,user_insert,fecha_insert)
	VALUES(cCnxn_status,'PMCO',NVL(pCompanyCode,''),NVL(pChannelId,''),NVL(pTokenId,''),NVL(pLanguage,''),NVL(pApiVersion,''),NVL(pClientSoftwareVersion,''),NVL(pUniqueReferenceNumber,''),NVL(pReferenceNumber,''),'',NVL(pCodeRequest,''),NVL(pChannelIdRequest,''),NVL(pTaxIdentificationNumber,''),NVL(pLocationUnit,''),NVL(pNumberRequest,''),NVL(pTypeCode,''),NVL(pCountryCode,''),NVL(pStateCode,''),NVL(pUserId,''),NVL(pSupervisorId,''),NVL(pTerminalId,''),NVL(pProcessDateRequest,''),NVL(pProcessTimeRequest,''),NVL(pCode,''),NVL(pMessageResponse,''),NVL(pCodeDetail,''),NVL(pMessageDetail,''),NVL(pProcessDateResponse,''),NVL(pProcessTimeResponse,''),NVL(pUniqueReferenceNumberReques,''),NVL(pGlobalTrackingNumber,''),NVL(pOrderStatusCode,''),NVL(pOrderStatusDate,''),NVL(pOrderStatusTime,''),pUserId,CURRENT YEAR to FRACTION(5));

	--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(iFlg_insertaerrorws,cNombreSPL, cCodRet, cFlg_confirm_ctral,iSqlErr,iIsamErr, cCadena_ent,pUserId,pProcessDateRequest,pProcessTimeRequest)
	--INTO cCodRet2;

	RETURN cCodRet,cDescError,pUniqueReferenceNumber,cFlg_confirm_ctral,cFechaInsert,cHoraInsert;
END
END PROCEDURE
DOCUMENT
'AUTOR: 95358919 - MARIO GAMALIEL OLIVO URIAS',
'CENTRO: 230142',
'FOLIO: 150',
'RQM: RQM 10 809 Â? Pago de Remesas Appriza con abono automÃ¡tico en cuentas de captaciÃ³n.doc',
'FECHA: 05/NOVIEMBRE/2016',
'SOLICITA: EDUARDO PINEDA',
'VERSION: 20161105.0936',
'DESCRIPCION: CONFIRMA TODAS LAS REMESAS QUE FUERON ABONADAS A LAS CUENTAS CORRECTAMENTE.',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_app_getorderstoreprocess (pcUsuario CHAR(15),
	pRegs_recup INTEGER,
	pFecha_peticion CHAR(8),
	pHora_peticion CHAR(6))

--Datos a regresar
RETURNING 	CHAR(12) AS numremesa,
            CHAR(5) AS channelId,
            CHAR(8) AS fec_proceso,
            CHAR(6) AS hora_proceso,
            CHAR (5) AS codret;

--Definicion de Variables
DEFINE iSqlErr 			INTEGER;
DEFINE iIsamError 		INTEGER;
DEFINE cCod_err 		CHAR(5);
DEFINE cCod_retorno 	CHAR(5); -- del procedimiento sp_insertaerrorws
DEFINE cCodigo		 	CHAR(4);
DEFINE cNombre_preceso	CHAR(19);
DEFINE cRemesa			CHAR(12);
DEFINE cCadena_ent		CHAR(100);
DEFINE cDescr_mensaje 	CHAR(50);
DEFINE iIntentos 		INTEGER;
DEFINE cFecha_proceso 	CHAR(8);
DEFINE cHora_proceso 	CHAR(6);
DEFINE iContadorIntentosenvio INTEGER;
DEFINE iIntentosenvio   INTEGER;
DEFINE cChannelId       CHAR(4);

	--SET DEBUG FILE TO '/informix/EPG/sp_app_confirmorder.out';
	--TRACE ON;

--Inicializacion de Variables
LET iSqlErr = 0;
LET iIsamError = 0;
LET cCod_err ='00000';
LET cCodigo ='';
LET cCod_retorno ='';	-- del procedimiento sp_insertaerrorws
LET cRemesa ='';
LET cNombre_preceso ='sp_app_getorderstoreprocess';
LET cFecha_proceso = YEAR(CURRENT::DATE) || LPAD(MONTH(CURRENT::DATE),2,'0') || LPAD(DAY(CURRENT::DATE),2,'0');
LET cHora_proceso = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
LET cCadena_ent = NVL(pRegs_recup,0) || '|' || TRIM(NVL(pFecha_peticion,'NULL')) || '|' || TRIM(NVL(pHora_peticion,'NULL'));
LET cDescr_mensaje ='';
LET iIntentos =0;
LET iContadorIntentosenvio = 0;
LET iIntentosenvio = 0;
LET cChannelId = '';


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;  	
--SET DEBUG FILE TO "/dbexportb/marioolivo/sp_app_confirmorder.out";                                           
--TRACE ON; 
	BEGIN
	-- ERRORES DE INFORMIX
		ON EXCEPTION SET iSqlErr,iIsamError
			IF iSqlErr <> 0 THEN
				LET cCod_err = iSqlErr;			
				LET cDescr_mensaje = 'ERROR DE INFORMIX.';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso, cCod_err, cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
				INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;
			END IF;
		END EXCEPTION;
		
		--Se inserta el registro del proceso en curso
		--INSERT INTO bdisac:"informix".sac_ws_procesos(proceso,fecha_proceso,hora_proceso,estatus,cod_ret,user_insert,fecha_insert,hora_insert)
		--VALUES(cNombre_preceso,pFecha_peticion,pHora_peticion,'0','',pcUsuario,current::date,cHora_proceso);

		LET pcUsuario  =  pcUsuario;
			
		IF NVL(pRegs_recup,0) > 0 THEN
			--OBTIENE EL NUMERO DE INTENTOS PERMITIDOS.
			SELECT valor
			INTO iIntentos
			FROM bdisac:"informix".sac_param
			WHERE empresa = '001'
			AND cod_param = '87109';
	
			FOREACH
				SELECT LIMIT pRegs_recup UniqueReferenceNumber,Code, intentos_envio, channelid
				INTO cRemesa,cCodigo,iIntentosenvio,cChannelId
				FROM bdisac:"informix".sac_app_getorder
				WHERE (estatus_getorder = '13')
				AND intentos_envio <= NVL(iIntentos,0)
			    AND UniqueReferenceNumber <>  ''
				--AND channelid = cChannelId
				ORDER BY fecha_insert desc

                UPDATE bdisac:"informix".sac_app_getorder SET estatus_getorder = '14' WHERE UniqueReferenceNumber = cRemesa 
				and estatus_getorder = '13'
				AND intentos_envio <= NVL(iIntentos,0);
				
                --Contador de intentos de confirmacion EPG 26/10/2020
                LET iContadorIntentosenvio = iIntentosenvio + 1;
                UPDATE bdisac:"informix".sac_app_getorder  SET intentos_envio = iContadorIntentosenvio WHERE UniqueReferenceNumber = cRemesa;
                LET iContadorIntentosenvio = 0;
                
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err WITH RESUME;
			END FOREACH
			--NO SE ENCONTRO INFORMACION.
			IF  dbinfo("sqlca.sqlerrd2") = 0 THEN
				LET cCod_err = '1100';
				LET cDescr_mensaje ='NO SE ENCONTRO INFORMACION EN SAC_APP_GETORDER';
				
				EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
					INTO cCod_retorno;
				
				RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,cCod_err;	
			END IF;
			
			SELECT opcode_ds 
			INTO cDescr_mensaje
			FROM bdisac:"informix".sac_app_cat_mensajes
			WHERE agent_trans_type_code = 'PAYI'
			AND opcode = LPAD(cCodigo,4,'0');
			
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(2,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			--INTO cCod_retorno;
			
		ELSE
			LET cCod_err = '1100';
			LET cDescr_mensaje ='EL PARAMETRO PREGS_RECUP VIENE VACIO CON VALOR 0.';
		END IF
		
		IF cCod_err::INTEGER <> 0 THEN
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorws(1,cNombre_preceso,lpad(cCod_err,5,'0'), cDescr_mensaje, iSqlErr, iIsamError, cCadena_ent, pcUsuario, pFecha_peticion, pHora_peticion)
			INTO cCod_retorno;
			
			RETURN cRemesa,cChannelId,cFecha_proceso,cHora_proceso,lpad(cCod_err,5,'0');
		END IF
	END
END PROCEDURE;