CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_search_web
(
pEmpresa				CHAR(3), 
pUsuario				CHAR(8),
pMarca					CHAR(2),
pForeignRsRefNumRq    	CHAR(16),
pMtcn              	    CHAR(10),
pFechaHoraRq       	    DATETIME YEAR TO SECOND,
pRetCode         		CHAR(5),
pEmisorNameType     	CHAR(1),
pEmisorNombre1          CHAR(40),
pEmisorNombre2          CHAR(40),
pEmisorApPaterno    	CHAR(40),
pEmisorApMaterno    	CHAR(40),
pEmisorCiudad       	CHAR(20),
pEmisorEdo          	CHAR(40), 
pEmisorCodPais      	CHAR(3),
pEmisorCodMoneda    	CHAR(3),
pEmisorCp           	CHAR(8), 
pEmisorCalle        	CHAR(30), 
pEmisorTel          	CHAR(15), 
pBenefNameType 			CHAR(1),
pBenefNombre1           CHAR(40),
pBenefNombre2           CHAR(40),
pBenefApaterno      	CHAR(40), 
pBenefAmaterno      	CHAR(40),
pBenefCiudad        	CHAR(20), 
pBenefEdo           	CHAR(40), 
pBenefCodPais       	CHAR(3),
pBenefCodMoneda     	CHAR(3), 
pBenefCp            	CHAR(8), 
pBenefCalle         	CHAR(30), 
pBenefTelPart       	CHAR(15),
pBenefTelCel       		CHAR(10), 
pMontoTotalOrigen  		CHAR(10),
pMontoToTDestino    	CHAR(10),
pMontoOrigen        	CHAR(10),
pMontoCargos        	CHAR(10), 
pCdOrigenPago       	CHAR(30), 
pTipoCambio         	CHAR(10),
pFechaAltaRemesa    	CHAR(8),
pHoraAltaRemesa     	CHAR(16), 
pMoneyTransKey      	CHAR(10),
pEstatusRemesa      	CHAR(4), 
pNewMtcn            	CHAR(16),
pFusionStatus       	CHAR(4),
pNoPaginas          	CHAR(2),
pPaginaActual       	CHAR(2), 
pNumCoincidencias   	CHAR(2), 
pForeignRsSystemIdRp  	CHAR(11), 
pForeignRsRefNumRp      CHAR(16), 
pForeingRsCantIdRp      CHAR(11),
pDescError              CHAR(250),
pPartnerIdErr           CHAR(10), 
pFechaHoraRp            DATETIME YEAR TO SECOND, 
pUserInsert             CHAR(8), 
pFechaInsert            DATETIME YEAR TO SECOND,
pSucursal				CHAR(4)
)

RETURNING CHAR(5) AS cod_err, CHAR(30) AS error_desc;

--DEFINICION DE VARIABLES--
    DEFINE	iSql_Err		INTEGER;
	DEFINE 	iIsamErr		INTEGER;
    DEFINE	cCodRet			CHAR(5);
	DEFINE  cRetCode		CHAR(5);
	DEFINE	cCodRetAux		CHAR(5);
	DEFINE	cTxnStatus		CHAR(1);
	DEFINE	cNombreSP		CHAR(45);
	DEFINE 	cCadena_ent		CHAR(100);
	DEFINE cError_Desc  	CHAR(30);
	DEFINE cChannelType 	CHAR(3);
    DEFINE cChannelName 	CHAR(3); 
    DEFINE cChannelVersion	CHAR(4);  
    DEFINE cForeignSystemId	CHAR(11); 
	DEFINE cForeignRsCntRq  CHAR(11);
	DEFINE cFechaProceso    DATETIME YEAR TO SECOND;
	DEFINE cSucursal		CHAR(4);
	
--VARIABLES PARA NOMBRES TIPO "D" Y "M"
	DEFINE cSenderFirstName 	CHAR(40);
	DEFINE cSenderMiddleName 	CHAR(40);
	DEFINE cSenderLastName 		CHAR(40);
	DEFINE cSenderGivenName 	CHAR(40);
	DEFINE cSenderPaternalName 	CHAR(40);
	DEFINE cSenderMaternalName 	CHAR(40);
	DEFINE cBenefFirstName		CHAR(40);
	DEFINE cBenefMiddleName 	CHAR(40);
	DEFINE cBenefLastName 		CHAR(40);
	DEFINE cBenefGivenName 		CHAR(40);
	DEFINE cBenefPaternalName 	CHAR(40);
	DEFINE cBenefMaternalName 	CHAR(40);
	
	DEFINE cMarcaWU				CHAR(2);
	DEFINE cMarcaVG				CHAR(2);
	DEFINE cMarcaOV				CHAR(2);
	
--INICIALIZACION DE VARIABLES--
    LET	iSql_Err		 	= 0;
	LET	iIsamErr 		 	= 0;
    LET cCodRet			 	= '00000';
	LET cRetCode		 	= '00000';
	LET cCodRetAux		 	= '00000';
	LET cTxnStatus		 	= 'C';
	LET	cNombreSP		 	= 'sp_sac_wu_guardarespuesta_search_web';
	LET cCadena_ent		 	=  TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pForeignRsSystemIdRp,'NULL'))||'|'||TRIM(NVL(pMtcn,'NULL'));
	LET cError_Desc	     	= "Error en el proceso";
	LET cChannelType 	 	="";	
    LET cChannelName 	 	="";	 
    LET cChannelVersion	 	="";  
    LET cForeignSystemId 	=""; 
	LET cForeignRsCntRq  	="" ;
	LET cFechaProceso	 	= CURRENT::DATETIME YEAR TO SECOND;
	LET cSucursal 			="";
	
	LET cSenderFirstName 	="";
	LET cSenderMiddleName 	="";
	LET cSenderLastName 	="";
	LET cSenderGivenName 	="";
	LET cSenderPaternalName ="";
	LET cSenderMaternalName ="";
	LET cBenefFirstName		="";
	LET cBenefMiddleName 	="";
	LET cBenefLastName 		="";
	LET cBenefGivenName 	="";
	LET cBenefPaternalName 	="";
	LET cBenefMaternalName 	="";
	
	LET cMarcaWU			= "";
	LET cMarcaVG			= "";
	LET cMarcaOV			= "";
	
--SET DEBUG FILE TO '/tmp/adrian/sp_sac_guardarespuesta_search.out';
--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
BEGIN
	ON EXCEPTION SET iSql_Err, iIsamErr
        IF iSql_Err <> 0 THEN
            LET cCodRet = iSql_Err;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_insertaerrorwu (1,cNombreSP,cCodRet,'',iSql_Err,iIsamErr,cCadena_ent,pUsuario,cFechaProceso) 
			INTO cCodRetAux;
			
			IF cCodRetAux <> '00000' THEN
			   LET cCodRet = cCodRetAux;
			END IF
--	2014.11.11 FRG-i	En caso de error No Controlado,  se asiga valor "C" a cTxnStatus:
			LET cTxnStatus		 = 'C';
--	2014.11.11 FRG-f

			INSERT INTO bdisac:"informix".sac_wu_search	 
					(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
					 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
					 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
					 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
					 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
					 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
					 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
					
			VALUES(cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,pRetCode,pEmisorNameType,
					 pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
					 pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
					 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
					 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
					 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
				
				
				
			RETURN cCodRet,cError_Desc;
        END IF;
		
    END EXCEPTION;

	IF TRIM(pRetCode) = ''  THEN		
		LET cRetCode = '99998';
		LET pDescError = 'Sin respuesta del aplicativo, validar';
	ELIF pRetCode <> '00000' THEN
		LET cRetCode = pRetCode;
	END IF
	
	SELECT valor INTO cMarcaWU FROM "informix".sac_param WHERE cod_param ='87054';
	SELECT valor INTO cMarcaOV FROM "informix".sac_param WHERE cod_param ='87055';
	SELECT valor INTO cMarcaVG FROM "informix".sac_param WHERE cod_param ='87056';
	
	IF cMarcaWU = pMarca OR cMarcaOV = pMarca OR cMarcaVG = pMarca THEN
		IF pUsuario = "sys_wu" THEN
			LET cSucursal = '9250';
		ELSE
			IF pUsuario = "sysbex" THEN
				LET cSucursal = '5011';
			ELSE
				SELECT sucursal
				INTO cSucursal
				FROM bdinteg:"informix".si_ejecut
				WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
			END IF;
		END IF;
		IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			SELECT fsid ,counter_id
			INTO cForeignSystemId ,cForeignRsCntRq
			FROM bdisac:"informix".sac_wu_identificadores
			WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

			IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
				LET cCodRet = '00027';
				LET cError_Desc	= 'Usuario no tiene Id. Asignado';						
			END IF;
		ELSE
			LET	cCodRet = '00026'; --- Usuario no se encuentra
			LET cError_Desc	= 'NO EXISTE USUARIO';
	   END IF;
	ELSE
		LET	cCodRet = '00003'; --- Marca Inv?lida
		LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';			
	END IF;

	SELECT valor
	INTO cChannelType
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87050';  
	 
	SELECT valor
	INTO cChannelName
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87051'; 
	 
	SELECT valor
	INTO cChannelVersion
	FROM bdisac:"informix".sac_param 
	WHERE cod_param = '87052'; 
																
--	2014.11.11 FRG-i	Se asigna el valor 'A' para el la variable "cTxnStatus".
	LET	cTxnStatus	= 'A';
--	2014.11.11 FRG-f
	
	--BITACORA EN BDISAC
	INSERT INTO bdisac:"informix".sac_wu_search	
						(txn_status,channel_type,channel_name,channel_version,foreign_rs_system_id_rq,foreign_rs_refnum_rq,foreign_rs_cntid_rq,mtcn,fecha_hora_rq,
						 retcode,emisor_nametype,emisor_nombre1,emisor_nombre2,emisor_appaterno,emisor_apmaterno,emisor_ciudad,emisor_edo,emisor_cod_pais,
						 emisor_cod_moneda,emisor_cp,emisor_calle,emisor_telefono,benef_nametype,benef_nombre1,benef_nombre2,benef_appaterno,benef_apmaterno,
						 benef_ciudad,benef_edo,benef_cod_pais,benef_cod_moneda,benef_cp,benef_calle,benef_tel_part,benef_tel_celular,monto_total_origen,
						 monto_total_destino,monto_origen,monto_cargos,cd_origen_pago,tipo_cambio,fecha_alta_remesa,hora_alta_remesa,money_transfer_key,
						 estatus_remesa,new_mtcn,fusion_status,no_paginas,pagina_actual,num_coincidencias,foreign_rs_system_id_rp,foreign_rs_refnum_rp,
						 foreign_rs_cntid_rp,desc_error,partnerid_err,fecha_hora_rp,user_insert,fecha_insert)
						 
				VALUES  (cTxnStatus,cChannelType,cChannelName,cChannelVersion,cForeignSystemId,pForeignRsRefNumRq,cForeignRsCntRq,pMtcn,pFechaHoraRq,cRetCode,pEmisorNameType,
						 pEmisorNombre1,pEmisorNombre2,pEmisorApPaterno,pEmisorApMaterno,pEmisorCiudad,pEmisorEdo,pEmisorCodPais,pEmisorCodMoneda,pEmisorCp,pEmisorCalle,
						 pEmisorTel,pBenefNameType,pBenefNombre1,pBenefNombre2,pBenefApaterno,pBenefAmaterno,pBenefCiudad,pBenefEdo,pBenefCodPais,pBenefCodMoneda,
						 pBenefCp,pBenefCalle,pBenefTelPart,pBenefTelCel,pMontoTotalOrigen,pMontoToTDestino,pMontoOrigen,pMontoCargos,pCdOrigenPago,pTipoCambio,
						 pFechaAltaRemesa,pHoraAltaRemesa,pMoneyTransKey,pEstatusRemesa,pNewMtcn,pFusionStatus,pNoPaginas,pPaginaActual,pNumCoincidencias,
						 pForeignRsSystemIdRp,pForeignRsRefNumRp,pForeingRsCantIdRp,pDescError,pPartnerIdErr,pFechaHoraRp,pUserInsert,current);
		
	--BITACORA EN INTERCARD
	IF pEmisorNameType = 'D' OR pEmisorNameType = 'C' THEN
		LET cSenderFirstName 	=	pEmisorNombre1;
		LET cSenderMiddleName 	=	pEmisorNombre2;
		LET cSenderLastName 	=	pEmisorApPaterno;
	ELIF pEmisorNameType = 'M' THEN
		LET cSenderGivenName 	=	pEmisorNombre1 || pEmisorNombre2;
		LET cSenderPaternalName =	pEmisorApPaterno;
		LET cSenderMaternalName =	pEmisorApMaterno;
	END IF;
	
	IF pBenefNameType = 'D' OR pBenefNameType = 'C' THEN
		LET cBenefFirstName		=	pBenefNombre1;
		LET cBenefMiddleName	=	pBenefNombre2;
		LET cBenefLastName 		=	pBenefApaterno;
	ELIF pBenefNameType = 'M' THEN
		LET cBenefGivenName 	=	pBenefNombre1 || pBenefNombre2;
		LET cBenefPaternalName 	=	pBenefApaterno;
		LET cBenefMaternalName 	=	pBenefAmaterno;
	END IF;
	INSERT INTO intercard:"informix".bitacorawumoneytransfersearch  (channel_type, channel_name, channel_version, frs_identifier, frs_reference, frs_counter_id, pt_mtcn, 
												sender_nametype, sender_firstname, sender_middlename, sender_last_name, sender_given_name, sender_paternalname, 
												sender_maternalname, sender_city, sender_state, sender_country_code, sender_currency_code, sender_state_zip, 
												sender_street, sender_local_delivery_area, sender_contact_phone, sender_mobile_country_code, 
												sender_mobile_details_number, receiver_nametype, receiver_firstname, receiver_middlename, receiver_last_name, 
												receiver_given_name, receiver_paternalname, receiver_maternalname, receiver_city, receiver_state, 
												receiver_country_code, receiver_currency_code, receiver_state_zip, receiver_street, receiver_local_delivery_area, 
												receiver_contact_phone, receiver_mobile_country_code, receiver_mobile_details_number, gross_total_amount, pay_amount, 
												principal_amount, charges, destination_country_code, destination_currency_code, originating_country_code, originating_currency_code, 
												originating_city, exchange_rate, original_destination_country_code, original_destination_currencycode, filing_date, filing_time, 
												money_transfer_key, pay_status_description, new_mtcn, fusion_status, account_number, current_page_number, last_page_number, 
												number_matches, retcode, fechahorainsercion, desc_retcode, originators_amount, destination_amount, error) 
										VALUES (cChannelType, cChannelName, cChannelVersion, cForeignSystemId, pForeignRsRefNumRq, cForeignRsCntRq, pMtcn, 
												pEmisorNameType, cSenderFirstName, cSenderMiddleName, cSenderLastName, cSenderGivenName, cSenderPaternalName, 
												cSenderMaternalName, pEmisorCiudad, pEmisorEdo, pEmisorCodPais, pEmisorCodMoneda, pEmisorCp, pEmisorCalle, '', pEmisorTel, 
												'', '', pBenefNameType, cBenefFirstName, cBenefMiddleName, cBenefLastName, cBenefGivenName, cBenefPaternalName, 
												cBenefMaternalName, pBenefCiudad, pBenefEdo, pBenefCodPais, pBenefCodMoneda, pBenefCp, pBenefCalle, '' , pBenefTelPart, 
												pBenefCodPais, pBenefTelCel, pMontoTotalOrigen, pMontoToTDestino, pMontoOrigen, pMontoCargos, pBenefCodPais, pBenefCodMoneda, 
												pEmisorCodPais, pEmisorCodMoneda, pEmisorCiudad, pTipoCambio, pBenefCodPais, pBenefCodMoneda, pFechaAltaRemesa, 
												pHoraAltaRemesa, pMoneyTransKey, pEstatusRemesa, pNewMtcn, pFusionStatus, '' , '1', '1', '1', cRetCode,  CURRENT, pDescError, 
												'' , '','');
	IF  cCodRet <> '00000' THEN	
		IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
			RETURN cCodRet,cError_Desc;	
		ELSE
			LET cCodRet = '00001';
		END IF;
		RETURN cCodRet,cError_Desc;
	END IF;
	RETURN cCodRet,cError_Desc;
END;
END PROCEDURE
DOCUMENT
'FOLIO.........: Iniciativa: Cobro Remesas Canales',
'AUTOR.........: Mario Gallardo cardenaz',
'FECHA.........: abril 2023',
'MODIFICACION..: ',
'SOLICITA......: Leonardo Henandez',
'BD............: bdisac';

CREATE PROCEDURE "informix".sp_sac_wu_guardarespuesta_pay_web 
(
	pEmpresa											CHAR(3), 
	pMarca             									CHAR(2),
	pUsuario											CHAR(8),  
	pBenefNameType 										CHAR(1), 
	pBenefNombreUno										CHAR(40), 
	pBenefNombreDos										CHAR(40), 
	pBenefApaterno										CHAR(40), 
	pBenefAmaterno										CHAR(40), 
	pBenefCiudad 										CHAR(24), 
	pBenefEdo  											CHAR(40), 
	pBeneCP												CHAR(9),
	pBenefIdType  										CHAR(1), 
	pBenefIdPaisExpedi									CHAR(45), 
	pBenefIdNumber  									CHAR(20), 
	pBenefTieneFechVenc									CHAR(1), 
	pBenefFechaVenc  									CHAR(8),
	pBenefFechNac  										CHAR(8), 
	pBenefOcupacion  									CHAR(30), 
	pBenefCalleNum  									CHAR(40), 
	pBenefColDelMun  									CHAR(40), 
	pBenefPais  										CHAR(45), 
	pBenefTelPart 										CHAR(20), 
	pBenefTelCel  										CHAR(20), 
	pBenefEmail  										CHAR(40), 
	pBenefPaisNac  										CHAR(2), 
	pBenefNacionalidad 									CHAR(15), 
	pBenefSexo  										CHAR(1), 
	pBenefCiudadNac										CHAR(20), 
	pBenefEdoNac										CHAR(20), 
	pBenefCodPais										CHAR(3), 
	pBenefCodMoneda										CHAR(3), 
	pMontoOrigen										CHAR(10), 
	pMontoDestino										CHAR(10), 
	pMoneyTransferKey									CHAR(10), 
	pNewMtcn											CHAR(16), 
	pMtcn												CHAR(10), 
	pConfPago											CHAR(1), 
	pForeignRefNumRq									CHAR(16), 
	pFechaHrRq											DATETIME YEAR TO SECOND, 
	pRetCode											CHAR(5), 
	pDatosBufer											CHAR(500), 
	pMtcnRp												CHAR(10), 
	pPuntosGanados										CHAR(4), 
	pWuFechaPago										CHAR(16), 
	pForeignSystemIdRp									CHAR(11), 
	pForeingRefNumRp									CHAR(16), 
	pForeignRsCantIdRp									CHAR(11), 
	pDesError											CHAR(250), 
	pPartnerIdErr										CHAR(10), 
	pFechaHoraRp										DATETIME YEAR TO SECOND, 
	pUserInsert											CHAR(8), 
	pFechaInsert										DATETIME YEAR TO SECOND,
	pSecondIdType										CHAR(1),  
	pSecondPaisExp										CHAR(44),
	pSecondIDNumber   									CHAR(30), 
	pNumCte												CHAR(20)	
)

RETURNING  CHAR(5) AS cod_err, CHAR(30) AS error_desc;

	--DEFINICION DE VARIABLES--
    DEFINE	iSqlErr				INTEGER;
	DEFINE 	iIsamErr			INTEGER;
    DEFINE	cCodRet				CHAR(5);
	DEFINE  cRetCode			CHAR(5);
	DEFINE	cCodRetAux			CHAR(5);
	DEFINE	cTxnStatus			CHAR(1);
	DEFINE	cNombreSP			CHAR(45);
	DEFINE 	cCadena_ent			CHAR(100);
	DEFINE cError_Desc  		CHAR(30);
	DEFINE dFechaProceso    	DATETIME YEAR TO SECOND;
	DEFINE cChannelType 		CHAR(3);
    DEFINE cChannelName 		CHAR(3); 
    DEFINE cChannelVersion		CHAR(4);
	DEFINE cForeignSystemId		CHAR(11); 
	DEFINE cForeignRsCntRq  	CHAR(11);
	DEFINE cTemplateId          CHAR(10);
	DEFINE cSucursal			CHAR(4);
	DEFINE vfec_nac				DATE;
	DEFINE cMarcaWU				CHAR(2);
	DEFINE cMarcaVG				CHAR(2);
	DEFINE cMarcaOV				CHAR(2);
	
	--INICIALIZACION DE VARIABLES--
    LET	iSqlErr				= 0;
	LET	iIsamErr 			= 0;
    LET cCodRet				= '00000';
	LET cRetCode			= '00000';
	LET cCodRetAux			= '00000';
	LET cTxnStatus			= 'C';
	LET	cNombreSP			= 'sp_sac_wu_guardarespuesta_pay';
	LET cCadena_ent			= TRIM(NVL(pUsuario,'NULL'))||'|'||TRIM(NVL(pMoneyTransferKey,'NULL'))||'|'||TRIM(NVL(pNewMtcn,'NULL'));
    LET cError_Desc 		= "Error en el proceso";
	LET dFechaProceso		=  CURRENT::DATETIME YEAR TO SECOND;
	LET cChannelType 	 	= "";	
    LET cChannelName 	 	= "";	 
    LET cChannelVersion	 	= "";
	LET cForeignSystemId 	= ""; 
	LET cForeignRsCntRq  	= "" ;
	LET cTemplateId			= "";
	LET cSucursal 			= "";
	LET cMarcaWU			= "";
	LET cMarcaVG			= "";
	LET cMarcaOV			= "";

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
					(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1,    benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type, benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago, foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp, puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err, fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number,numcte)
			
			VALUES
					(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun, pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac,  pBenefNacionalidad, pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey, pNewMtcn, pMtcn, pConfPago, cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, pRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago,pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp, pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber,pNumCte);

			RETURN cCodRet, cError_Desc;
		END IF;

	END EXCEPTION;

	--SET DEBUG FILE TO '/informix/ENP/sp_sac_guardarespuesta_pay.out';
	--TRACE ON;	
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF TRIM(pRetCode) = ''  THEN		
		LET cRetCode = '99998';
		LET pDesError = 'Sin respuesta del aplicativo, validar';
	ELIF pRetCode <> '00000' THEN
		LET cRetCode = pRetCode;
	END IF

	SELECT valor INTO cMarcaWU FROM "informix".sac_param WHERE cod_param ='87054';
	SELECT valor INTO cMarcaOV FROM "informix".sac_param WHERE cod_param ='87055';
	SELECT valor INTO cMarcaVG FROM "informix".sac_param WHERE cod_param ='87056';
	
	IF cMarcaWU = pMarca OR cMarcaOV = pMarca OR cMarcaVG = pMarca THEN
 
		IF pUsuario = "sys_wu" THEN
			LET cSucursal = '9250';
		ELSE
			IF pUsuario = "sysbex" THEN
				LET cSucursal = '5011';
			ELSE
			SELECT sucursal
			INTO cSucursal
			FROM bdinteg:"informix".si_ejecut
			WHERE empresa = pEmpresa AND ejecutivo = pUsuario;
		END IF;
		
	END IF;
		IF pUsuario = 'sys_wu' OR cSucursal <> '' THEN
			SELECT fsid ,counter_id
			INTO cForeignSystemId ,cForeignRsCntRq
			FROM bdisac:"informix".sac_wu_identificadores
			WHERE empresa = pEmpresa AND marca = pMarca AND sucursal = cSucursal;

			IF cForeignSystemId IS NULL OR cForeignSystemId = '' OR cForeignRsCntRq IS NULL OR cForeignRsCntRq = '' THEN
				LET cCodRet = '00027';
				LET cError_Desc	= 'Usuario no tiene Id. Asignado';
			END IF;
		ELSE
			LET	cCodRet = '00026'; --- Usuario no se encuentra
			LET cError_Desc	= 'NO EXISTE USUARIO';
	   END IF;
	ELSE
		LET	cCodRet = '00003'; --- Marca InvÃÂ?ÃÂ?ÃÂ?ÃÂÃÂ¡lida
		LET cError_Desc	= 'NO EXISTE MARCA EN SAC PARAM';
	END IF;
	
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
			(txn_status, channel_type, channel_name, channel_version, benef_nametype, benef_nombre1, benef_nombre2, benef_appaterno,benef_apmaterno, benef_ciudad, benef_edo, benef_cp, template_id, benef_id_type,benef_id_pais_expedicion, benef_id_number,id_benef_tiene_fecha_venc, benef_id_fecha_vencimiento, benef_fecha_nac, benef_ocupacion, benef_calle_num, benef_col_del_mncpo,benef_pais, benef_tel_particular, benef_tel_celular, benef_email, benef_pais_nac, benef_nacionalidad, benef_sexo, benef_ciudad_nac,benef_edo_nac, benef_cod_pais, benef_cod_moneda, monto_origen, monto_destino, money_transfer_key, new_mtcn, mtcn, conf_pago,foreign_rs_system_id_rq, foreign_rs_refnum_rq, foreign_rs_cntid_rq, fecha_hora_rq, retcode, datos_buffer, mtcn_rp,puntos_ganados, wu_fecha_pago, foreign_rs_system_id_rp, foreign_rs_refnum_rp, foreign_rs_cntid_rp, desc_error, partnerid_err,fecha_hora_rp, user_insert, fecha_insert, benef_second_id_type, benef_second_pais_expedicion, benef_second_id_number,numcte)
					
	VALUES
			(cTxnStatus, cChannelType, cChannelName, cChannelVersion, pBenefNameType, pBenefNombreUno, pBenefNombreDos,pBenefApaterno,pBenefAmaterno, pBenefCiudad, pBenefEdo, pBeneCP, cTemplateId, pBenefIdType, pBenefIdPaisExpedi, pBenefIdNumber,pBenefTieneFechVenc, pBenefFechaVenc, pBenefFechNac, pBenefOcupacion, pBenefCalleNum, pBenefColDelMun,pBenefPais,pBenefTelPart, pBenefTelCel, pBenefEmail, pBenefPaisNac, pBenefNacionalidad,pBenefSexo, pBenefCiudadNac, pBenefEdoNac, pBenefCodPais, pBenefCodMoneda, pMontoOrigen, pMontoDestino, pMoneyTransferKey,pNewMtcn, pMtcn, pConfPago,cForeignSystemId, pForeignRefNumRq, cForeignRsCntRq, pFechaHrRq, cRetCode, pDatosBufer, pMtcnRp, pPuntosGanados, pWuFechaPago, pForeignSystemIdRp, pForeingRefNumRp, pForeignRsCantIdRp,pDesError, pPartnerIdErr, pFechaHoraRp, pUserInsert, current, pSecondIdType, pSecondPaisExp, pSecondIDNumber,pNumCte);
				   
	IF  cCodRet <> '00000' THEN
		
		IF cCodRet =  '00027' OR cCodRet =  '00026'  THEN		
			RETURN cCodRet,cError_Desc;	
		END IF;
	  
		RETURN cCodRet,cError_Desc;		
	ELSE
        ---------------------------------------------------------------------------------
        IF
            cSucursal <> '' or cSucursal IS NOT NULL THEN
            IF EXISTS (SELECT * FROM bdinteg:"informix".si_sucursales WHERE sucursal NOT IN ('9250', '9251', '9764','5011','5003') AND sucursal = cSucursal) THEN
                EXECUTE PROCEDURE bdinteg: "informix".sp_inserta_msjafore(pNumcte,'',cSucursal,'') INTO cCodRet;
                IF 
                    cCodRet <> '00000' THEN
                    INSERT INTO bdisac:"informix".sac_procesos_jobs(proceso, fecha_proceso, status, user_insert, fecha_insert, numero_ejecuciones, nombre_sp, descripcion)
                    VALUES ('sp_pago_wu_web', CURRENT, '0', 'informix', CURRENT, NULL, 'sp_inserta_msjafore', 'Codigo retorno: '|| cCodRet);
                END IF;
            END IF;
        END IF;
        ----------------------------------------------------------------------------------
		LET cError_Desc = "Ejecucion SP exitosa";
		RETURN cCodRet,cError_Desc;
	END IF;	
END;
END PROCEDURE
DOCUMENT
'FOLIO.........: Iniciativa: Cobro Remesas Canales',
'Modifica.........: Mario Gallardo cardenaz',
'FECHA.........: abril 2023',
'MODIFICACION..: Se aÃ±ade bloque if para que las trasacciones de de cobro la sucursal 5011 "app" tambien se guarden en bitacora sac_wu_pay',
'SOLICITA......: Leonardo Henandez',
'BD............: bdisac';

CREATE PROCEDURE  "informix".sp_sac_pago_atm_infonavit ( 
pEmpresa                CHAR(3),				--- Id de la empresa (Coppel)
pCategoria              CHAR(2),				--- Identificador de la categoria del convenio
pConvenio               CHAR(5),				--- Identificador del convenio de la operacion.
pSucursal               CHAR(4),				--- Sucursal de la operacion
pUsuario                CHAR(8),				--- Numero de empleado con la que queda registrada la transaccion.
pFolio_suc              CHAR(16),				--- Folio_suc de la transaccion
pNum_tarjeta            CHAR(16),				--- Numero de tarjeta de debito del cliente
pNumReferencia          CHAR(10),				--- Numero de referencia infonavit a 10 digitos
dFechaPago              DATE, 					--- Fecha en la que se realiza el pago
pReferencia2            CHAR(40), 				--- Ultimo digito de la referencia infonavit
pFormaPago              CHAR(1),  				--- Forma de pago (cargo cuenta o efectivo)
pDivisa                 CHAR(2),				--- Divisa o tipo de moneda
pUsuautoriza            CHAR(8),				--- Usuario que autoriza el movimiento.
pTransacc_suc           CHAR(4),				--- Id de la transaccion para sac_movimientos.
deImportePago           DECIMAL,				--- Importe de la transaccion para sac_movimientos.
deImpComisionConvenio   DECIMAL,				--- Importe comision de convenio que se cobra a Infonavit
deIvaComisionConvenio   DECIMAL,				--- Iva de comision del convenio que se cobra a Infonavit
deImpComisionCliente    DECIMAL,				--- Importe comision del cliente
deIvaComisionCliente    DECIMAL,				--- Iva de comision cliente
pMto_tot                DECIMAL, 				--- Segundo monto de la transaccion
-- Parametros para el SP Cargo Ref
pTransacc_cargo         CHAR(4), 				--- Id del transacc para el cargo
pTransuc_cargo          CHAR(4), 				--- Id del transucc para el cargo
pCuenta_cargo           CHAR(20),				--- Numero de la cuenta de cheques del cliente
pCheque_cargo           INTEGER,				--- Si se paga con cheques (0)
pReferencia_cargo       CHAR(40),				--- Referencia descriptiva del cargo realizado
-- Parametros para el SP Abono Ref
pTransacc_abono         CHAR(4), 				--- Id del transacc para el abono
pTransuc_abono          CHAR(4), 				--- Id del transucc para el abono
pCuenta_abono           CHAR(20),				--- Numero de la cuenta de cheques de Infonavit
pDocto_abono            INTEGER, 				--- Determina el documento de la transaccion (1 -0)
pMto_firme_abono        DECIMAL, 				--- Importe de la transaccion para el abono.
pMto_sbc_abono          DECIMAL, 				--- Monto SBC al cliente (0)
pMto_rem_abono          DECIMAL,				--- Monto de remesas al cliente (0)
pDias_ret_abono         INTEGER, 				--- Dias de retencion del abono (0)
pReferencia_abono       CHAR(40), 				--- Referencia descriptiva del abono
--Parametros para el sp registra evento
pTipoMsj                CHAR(1), 				--- Tipo de mensaje (correo)
pIdMsj                  CHAR(10),				--- Id del mensaje a utilizar
pIdPlantilla            CHAR(12),				--- Id de la plantilla a utilizar
pTipoproc               CHAR(1), 				--- Tipo proceso para el correo (Online y Batch)
pStr1                   CHAR(30),				--- Mensajes de texto para el correo...
pStr2                   CHAR(30),
pStr3                   CHAR(30),
pStr4                   CHAR(30),
pStr5                   CHAR(150),
pStr6                   CHAR(100),
pStr7                   CHAR(60),
pStr8                   CHAR(60),
pStr9                   CHAR(15),
pStr10                  CHAR(100),
pcorreo_alterno         CHAR(100), 				--- Corre alterno del cliente
pcelular_alterno        CHAR(10),  				--- Celular alterno del cliente
pImporte1               INTEGER,				--- Importes a enviar en el correo...
pImporte2               INTEGER,
pImporte3               INTEGER,
pImporte4               INTEGER,
pImporte5               INTEGER,
pfecha1                 datetime year to fraction(3),	--- Fecha 1 de transaccion para el correo
pfecha2                 DATE,							--- Fecha 2 de transaccion para el correo
-- Valores genericos
pGenerico1              CHAR(100),				--- Valores genericos por utilizar...
pGenerico2              CHAR(200),
pGenerico3              CHAR(300))
                    
RETURNING
--- Datos a retornar
CHAR(5)     AS  cCodRet,         	--- Codigo de retorno del SP
CHAR(200)   AS  cDescripcion,		--- Descripcion del codigo retorno
--- RET CONSSALDOS
CHAR(20)    AS  vcuenta,         	--- Numero de cuenta de cheques del cliente
CHAR(20)    AS  vnum_cte,        	--- Numero del cliente Bancoppel
CHAR(26)    AS  vapell_pat,      	--- Apellido paterno del cliente
CHAR(26)    AS  vapell_mat,      	--- Apellido materno del cliente
CHAR(26)    AS  vnombre1,        	--- Primer nombre del cliente
CHAR(26)    AS  vnombre2,        	--- Segundo nombre del cliente
CHAR(60)    AS  vrazon_soc,      	--- Razon social del cliente
CHAR(1)     AS  vedo_cta,        	--- Estatus de la cuenta del cliente
MONEY(14,2) AS  vsdo_ret,        	--- Saldo retenido de la cuenta
MONEY(14,2) AS  vsdo_ccc,        	--- Saldo ccc de la cuenta del cliente
MONEY(14,2) AS  vsdo_disp_ccc,   	--- Saldo ccc disponible de la cuenta del cliente
MONEY(14,2) AS  vsdo_cta,        	--- Saldo de la cuenta antes de la transaccion
CHAR(1)     AS  vtipo_linea,     	--- Tipo de linea de la cuenta del cliente
CHAR(40)    AS  vdescrip1,       	--- Descripcion del tipo de cuenta que maneja la cuenta
CHAR(40)    AS  vdescrip2,       	--- Descripcion del tipo de moneda que maneja la cuenta
MONEY(14,2) AS  vsdo_t1,         	--- Saldo temporal de la cuenta del cliente
MONEY(14,2) AS  vsdo_cong,       	--- Saldo congelado de la cuenta del cliente
MONEY(14,2) AS  vimp_chq_sbc,    	--- Importe de cheques del SBC
CHAR(8)     AS  vusubloq,        	--- Determina si el usuario se encuentra bloqueado
DATE        AS  vfecbloq,        	--- Fecha del bloqueo de la cuenta del cliente
CHAR(16)    AS  vnum_tarjeta,    	--- Numero de la tarjeta del cliente
CHAR(18)    AS  vcta_clabe,      	--- Cuenta clave perteneciente al cliente
DATE        AS  sFecExp,         	--- Fecha expiracion de la tarjeta
--RET CARGO REF
CHAR(4)     AS  vtranret, 			---	Id del transacc realizado
DATE        AS  vfechoy, 			--- Fecha actual de la transaccion
MONEY(14,2) AS  vsdodisp,  			--- Saldo disponible despues de transaccion
MONEY(14,2) AS  vmontoret,			--- Monto abonado de la transaccion
CHAR(100)   AS vGenerico1, 			--- Valor generico 1
CHAR(200)   AS vGenerico2, 			--- Valor generico 2
CHAR(300)   AS vGenerico3; 			--- Valor generico 3


--Definicion de las variables del sp pago infonavit en ATM
DEFINE iSqlErr          INTEGER;		   --- Error SQL
DEFINE cDescripcion     CHAR(200);	       --- Descripcion del estado de la transaccion
DEFINE cCodRet          CHAR(5);	       --- Codigo de retorno de la transaccion
DEFINE vtransaccion		SMALLINT;	       --- Valor transaccion error
DEFINE vnumcte          CHAR(9); 	       --- Numero del cliente.
DEFINE vcuenta          CHAR(20);  	       --- Numero de cuenta de cheques del cliente
DEFINE vnum_cte         CHAR(20);   	   --- Numero de cliente para retornar
DEFINE vapell_pat       CHAR(26);   	   --- Apellido paterno del cliente
DEFINE vapell_mat       CHAR(26);   	   --- Apellido materno  del cliente
DEFINE vnombre1         CHAR(26);   	   --- Primer Nombre del cliente
DEFINE vnombre2         CHAR(26);   	   --- Segundo nombre del cliente
DEFINE vrazon_soc       CHAR(60);   	   --- Razon social del cliente
DEFINE vedo_cta         CHAR(1);   	       --- Estatus de la cuenta del cliente
DEFINE vsdo_ret         MONEY(14,2);	   --- Saldo retenido del cliente
DEFINE vsdo_ccc         MONEY(14,2);	   --- Saldo CCC de la cuenta del cliente
DEFINE vsdo_disp_ccc    MONEY(14,2);	   --- Saldo disponible CCC de la cuenta del cliente
DEFINE vsdo_cta         MONEY(14,2);	   --- Saldo de la cuenta antes de la transaccion
DEFINE vtipo_linea      CHAR(1) ;   	   --- Tipo de linea del cliente
DEFINE vdescrip1        CHAR(40);   	   --- Descripcion del tipo de moneda del cliente
DEFINE vdescrip2        CHAR(40);   	   --- Descripcion del tipo de cuenta del cliente
DEFINE vsdo_t1          MONEY(14,2);	   --- Saldo temporal de la cuenta del cliente
DEFINE vsdo_cong        MONEY(14,2);	   --- Saldo congelado del cliente
DEFINE vimp_chq_sbc     MONEY(14,2);	   --- Impuestos de cheques del SBC
DEFINE vusubloq         CHAR(8);	       --- Determina si el usuario se encuentra bloqueado
DEFINE vfecbloq         DATE;   	       --- Fecha del bloqueo de la cuenta del cliente
DEFINE vnum_tarjeta     CHAR(16); 	       --- Numero de tarjeta del cliente
DEFINE vcta_clabe       CHAR(18);  	       --- Cuenta clave del cliente
DEFINE sFecExp          DATE;	           --- Fecha expiracion de la tarjeta
DEFINE vtranret         CHAR(5);	       --- Id del transacc realizado
DEFINE vfechoy          DATE;	           --- Fecha de cuando se realizo el cargo
DEFINE vsdodisp         MONEY(14,2);	   --- Saldo disponible despues de transaccion
DEFINE vmontoret        MONEY(14,2);	   --- Monto retenido del cliente
DEFINE vServActivo      CHAR(1);	       --- Servicio disponible del convenio
DEFINE vGenerico1       CHAR(20); 	       --- Valor Generico 1
DEFINE vGenerico2       CHAR(20); 	       --- Valor Generico 2
DEFINE vGenerico3       CHAR(20);	       --- Valor Generico 3
DEFINE pMotivo 			CHAR(2);	       --- Motivo del estatus de la cuenta
DEFINE vExiste			CHAR(2);	       --- Si la cuenta existe en cuentas bloqueadas
DEFINE vAceptab 		CHAR(2);	       --- Si el Bloqueo acepta algun movimiento
DEFINE rCodRet			CHAR(5);	       --- Codigo de retorno reverso


--Inicializacion de variables
LET iSqlErr         = 0;					--- Error SQL
LET cDescripcion    = '';                   --- Descripcion del estado de la transaccion
LET cCodRet         = '00000';              --- Codigo de retorno de la transaccion
LET vtransaccion	= 0;                    --- Valor transaccion error
LET vnumcte         ='';                    --- Numero del cliente.
LET vcuenta         ='';                    --- Numero de cuenta de cheques del cliente
LET vnum_cte        ='';                    --- Numero de cliente para retornar
LET vapell_pat      ='';                    --- Apellido paterno del cliente
LET vapell_mat      ='';                    --- Apellido materno  del cliente
LET vnombre1        ='';                    --- Primer Nombre del cliente
LET vnombre2        ='';                    --- Segundo nombre del cliente
LET vrazon_soc      ='';                    --- Razon social del cliente
LET vedo_cta        ='';                    --- Estatus de la cuenta del cliente
LET vsdo_ret        =0;                     --- Saldo retenido del cliente
LET vsdo_ccc        =0;                     --- Saldo CCC del cliente
LET vsdo_disp_ccc   =0;                     --- Saldo disponible CCC del cliente
LET vsdo_cta        =0;                     --- Saldo de la cuenta antes de la transaccion
LET vtipo_linea     ='';                    --- Tipo de linea del cliente
LET vdescrip1       ='';                    --- Descripcion del tipo de moneda del cliente
LET vdescrip2       ='';                    --- Descripcion del tipo de cuenta del cliente
LET vsdo_t1         =0;                     --- Saldo temporal de la cuenta del cliente
LET vsdo_cong       =0;                     --- Saldo congelado del cliente
LET vimp_chq_sbc    =0;                     --- Impuestos de cheques del SBC
LET vusubloq        ='';                    --- Determina si el usuario se encuentra bloqueado
LET vfecbloq        ="";                    --- Fecha del bloqueo de la cuenta del cliente
LET vnum_tarjeta    ="";                    --- Numero de tarjeta del cliente
LET vcta_clabe      ='';                    --- Cuenta clave del cliente
LET sFecExp         ="";                    --- Fecha expiracion de la tarjeta
LET vtranret        ='';                    --- Id del transacc realizado
LET vfechoy         ="";                    --- Fecha de cuando se realizo el cargo
LET vsdodisp        =0;                     --- Saldo disponible despues de transaccion
LET vmontoret       =0;                     --- Monto retenido del cliente
LET vServActivo     ="";                    --- Servicio disponible del convenio
LET vGenerico1      ='';                    --- Valor Generico 1
LET vGenerico2      ='';                    --- Valor Generico 2
LET vGenerico3      ='';                    --- Valor Generico 3
LET pMotivo 		='';                    --- Motivo del estatus de la cuenta
LET vExiste			='';                    --- Si la cuenta existe en cuentas bloqueadas
LET vAceptab		='';                    --- Si el Bloqueo acepta algun movimiento
LET rCodRet			='';                    --- Codigo de retorno reverso


BEGIN
    -- Control de errores 'informix', excepciones no controladas
    ON EXCEPTION SET iSqlErr
        IF iSqlErr <> 0 THEN
            LET cCodRet = iSqlErr;
            RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
                    vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
        END IF;
    END EXCEPTION;
	
	--SET DEBUG FILE TO "/informix/ENP/Infonavit/out/sp_sac_pago_atm_infonavit.out";	
    --TRACE ON;
    
	SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
	-- Validacion de los parametros de entrada generales del spl 
    -- estas validaciones son para campos vacios o nulos en pago del servicio credito hipotecario infonavit tanto en cuenta cargo como en efectivo
	IF
        (TRIM(pEmpresa) = ''       OR TRIM(pEmpresa) IS NULL)              	OR
        (TRIM(pCategoria) = ''     OR TRIM(pCategoria) IS NULL)            	OR
        (TRIM(pConvenio) = ''      OR TRIM(pConvenio) IS NULL)             	OR    
        (TRIM(pSucursal) = ''      OR TRIM(pSucursal) IS NULL)             	OR  
        (TRIM(pUsuario) = ''       OR TRIM(pUsuario)  IS NULL)             	OR 
        (TRIM(pFolio_suc) = ''     OR TRIM(pFolio_suc) IS NULL)           	OR
        (TRIM(pNumReferencia) = '' OR TRIM(pNumReferencia) IS NULL)        	OR  
        (dFechaPago IS NULL)                                                OR
        (TRIM(pReferencia2) = ''   OR TRIM(pReferencia2) IS NULL)          	OR 
        (TRIM(pFormaPago) = ''     OR TRIM(pFormaPago)IS NULL)            	OR 
        (TRIM(pDivisa) = ''        OR TRIM(pDivisa)IS NULL)               	OR 
        (TRIM(pTransacc_suc) = ''  OR TRIM(pTransacc_suc)IS NULL)          	OR
        (deImportePago IS NULL)                                             OR
        (deImpComisionConvenio IS NULL)                                     OR
        (deIvaComisionConvenio IS NULL)                                     OR
        (deImpComisionCliente IS NULL)                                      OR
        (deIvaComisionCliente IS NULL)                                      OR
         pMto_tot IS NULL                                                   OR
        -------------------------------------------------- ABONO 
        (TRIM(pTransacc_abono) = '' 	OR TRIM(pTransacc_abono)IS NULL)    OR
        (TRIM(pTransuc_abono) = '' 		OR TRIM(pTransuc_abono)IS NULL)     OR
        (TRIM(pCuenta_abono) = '' 		OR TRIM(pCuenta_abono)IS NULL)      OR
        pDocto_abono IS NULL                                                OR
        pMto_firme_abono IS NULL                                            OR
        pMto_sbc_abono IS NULL                                              OR
        pMto_rem_abono IS NULL                                              OR
        pDias_ret_abono IS NULL                                             OR
        (TRIM(pReferencia_abono) = '' 	OR TRIM(pReferencia_abono)IS NULL)  OR
        (TRIM(pCuenta_abono) = ''     	OR TRIM(pReferencia_abono) = '')      

        THEN
		LET cCodRet = "00050";
        LET cDescripcion ='REVISE PARAMETROS VACIOS/INCOMPLETOS '; 
        RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
                vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
    END IF;
	
    ----- Pago con cargo a cuenta -----
    IF pFormaPago='2' THEN	
		--Validacion de los parametros de entrada para el cargo a cuenta.
        IF  ((TRIM(pTransacc_cargo) = '' 	OR TRIM(pTransacc_cargo) IS NULL)   OR
            (TRIM(pTransuc_cargo) = '' 		OR TRIM(pTransuc_cargo) IS NULL)    OR
            (TRIM(pCuenta_cargo) = '' 		OR TRIM(pCuenta_cargo) IS NULL)     OR
            pCheque_cargo IS NULL                                               OR 
            (TRIM(pReferencia_cargo) = '' 	OR TRIM(pReferencia_cargo)IS NULL)  OR
            (TRIM(pTipoMsj) = '' 			OR TRIM(pTipoMsj)IS NULL)           OR
            (TRIM(pIdMsj) = '' 				OR TRIM(pIdMsj)IS NULL)             OR
            (TRIM(pIdPlantilla) = '' 		OR TRIM(pIdPlantilla)IS NULL)       OR
            (TRIM(pNum_tarjeta) = '' 		OR TRIM(pNum_tarjeta)IS NULL)       OR
            (TRIM(pTipoproc) = '' 			OR TRIM(pTipoproc)IS NULL))

            THEN 
            LET cCodRet = "00050";
            LET cDescripcion ='REVISE PARAMETROS VACIOS/INCOMPLETOS ';
			
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
            vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3; 
        END IF;
		
        -- Obtiene los estados del cliente que realizara el pago y verfica si el sistema de cheques este disponible
		EXECUTE PROCEDURE bdicheq:"informix".cons_sdos2(pEmpresa , '00000000000' , pNum_tarjeta)
        INTO cCodRet,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdodisp,
                vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,
                vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp;
		
		-- Valida el codigo de retorno del sp cons_sdos2 y determina su descripcion en caso de fallar
        IF cCodRet != '000' THEN
			
            IF cCodRet= '004' THEN
                LET cDescripcion = 'SISTEMA CHEQUES NO DISPONIBLE.';
                
            ELIF sFecExp <= TODAY THEN
                LET cCodRet='111';
                LET cDescripcion = 'TARJETA EXPIRADA';
                
            ELIF cCodRet= '110' THEN
                LET cDescripcion = 'CUENTA/TARJETA INCORRECTA';
                
            ELIF cCodRet= '100' THEN
                LET cDescripcion = 'SOLO SE PERMITE PAGO CON DEBITO';
                
            ELIF cCodRet= '122' THEN
                LET cDescripcion = 'TARJETA BLOQUEADA/INACTIVA';
                
            ELIF cCodRet= '855' THEN
                LET cDescripcion = 'NO PERMITIDO PARA PRODUCTO 8000';
            
            ELSE
                LET cDescripcion = 'FALLO AL CONSULTAR SALDO CLIENTE';
                LET cCodRet= '019';
            END IF;
			
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
			vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;

		END IF;
            
		--Valida que el saldo de la cuenta del cliente sea suficiente par realizar el cargo
        IF vsdodisp < deImportePago THEN
            LET cCodRet = '00010';
            LET cDescripcion = 'SALDO INSUFICIENTE PARA REALIZAR PAGO';
            LET vcuenta        = '';
            LET vnum_cte       = '';
            LET vapell_pat     = '';
            LET vapell_mat     = '';
            LET vnombre1       = '';
            LET vnombre2       = '';
            LET vrazon_soc     = '';
            LET vedo_cta       = '';
            LET vsdo_ret       = 0;
            LET vsdo_ccc       = 0;
            LET vsdo_disp_ccc  = 0;
            LET vsdo_cta       = 0;
            LET vtipo_linea    = '';
            LET vdescrip1      = '';
            LET vdescrip2      = '';
            LET vsdo_t1        = 0;
            LET vsdo_cong      = 0;
            LET vimp_chq_sbc   = 0;
            LET vusubloq       = '';
            LET vfecbloq       = '';
            LET vnum_tarjeta   = '';
            LET vcta_clabe     = '';
            LET sFecExp        = '';
            LET vtranret       = '';
            LET vfechoy        = '';
            LET vsdodisp       = 0;
            LET vmontoret      = 0;
            LET vGenerico1     = '';
            LET vGenerico2     = '';
            LET vGenerico3     = '';

            RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
                    vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
					
        END IF; -- End saldo insuficiente
            
		-- Valida que los sistemas de servicios y de cheques esten disponibles.
        EXECUTE PROCEDURE "informix".sp_grabapgserv_dina(pSucursal ,pCategoria ,pConvenio ,pNumReferencia ,pReferencia2,
        pFormaPago ,deImportePago,deImpComisionConvenio ,deIvaComisionConvenio ,deImpComisionCliente ,deIvaComisionCliente ,
        pCuenta_cargo ,pUsuario ,pFolio_suc ,pTransacc_suc ,dFechaPago)
        INTO cCodRet;
			
		-- Valida el codigo de retorno del sp_grabapgserv_dina 
		IF cCodRet != '00000' THEN

			IF cCodRet ='01241' THEN
				LET cDescripcion = 'LA FECHA DEL SISTEMA Y DE CENTRAL SON DIFERENTES';

			ELIF cCodRet= '00060' THEN
				LET cDescripcion = 'SISTEMA SERVICIOS NO DISPONIBLE.';

			ELIF cCodRet= '00061' THEN
				LET cDescripcion = 'SISTEMA CHEQUES NO DISPONIBLE.';

			ELIF cCodRet= '00002' THEN
				LET cDescripcion = 'PAGO PREVIAMENTE APLICADO';
				
			ELSE
				LET cDescripcion = 'ERROR AL GUARDAR EL SERVICIO';
				LET cCodRet= '00019';
			END IF;
            
            LET vcuenta        = '';
            LET vnum_cte       = '';
            LET vapell_pat     = '';
            LET vapell_mat     = '';
            LET vnombre1       = '';
            LET vnombre2       = '';
            LET vrazon_soc     = '';
            LET vedo_cta       = '';
            LET vsdo_ret       = 0;
            LET vsdo_ccc       = 0;
            LET vsdo_disp_ccc  = 0;
            LET vsdo_cta       = 0;
            LET vtipo_linea    = '';
            LET vdescrip1      = '';
            LET vdescrip2      = '';
            LET vsdo_t1        = 0;
            LET vsdo_cong      = 0;
            LET vimp_chq_sbc   = 0;
            LET vusubloq       = '';
            LET vfecbloq       = '';
            LET vnum_tarjeta   = '';
            LET vcta_clabe     = '';
            LET sFecExp        = '';
            LET vtranret       = '';
            LET vfechoy        = '';
            LET vsdodisp       = 0;
            LET vmontoret      = 0;
            LET vGenerico1     = '';
            LET vGenerico2     = '';
            LET vGenerico3     = '';
			
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
					vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
		END IF;
			
		-- Se realiza el cargo a la cuenta del cliente
        EXECUTE PROCEDURE  bdicheq:"informix".cargo_ref( pEmpresa ,pSucursal ,pUsuario ,pTransacc_cargo ,pTransuc_cargo,
        pFolio_suc ,pCuenta_cargo ,pCheque_cargo,pMto_tot,pDivisa,pReferencia_cargo,pNum_tarjeta,pUsuautoriza)
        INTO cCodRet,vtranret,vfechoy,vsdodisp,vmontoret;
			
		-- Valida el codigo de retorno del cargo_ref y en caso de fallar asigna una descripcion
		IF cCodRet !='000' THEN
		
            IF cCodRet ='004' THEN
                LET cDescripcion = 'SISTEMA DE CHEQUES NO DISPONIBLE';
            
            ELIF cCodRet= '307' THEN
                LET cDescripcion = 'ERROR EN SP CARGO_VAL';

            ELIF cCodRet= "200" THEN
                LET cDescripcion = 'CUENTA CANCELADA';

            ELIF cCodRet= '549' THEN
                LET cDescripcion = 'FECHA PROC MENOR A FECHA ACTUAL';

            ELIF cCodRet= '550' THEN
                LET cDescripcion = 'ERROR EN TRANSACCION DE CARGO';

            ELIF cCodRet= '400' THEN
                LET cDescripcion = 'SALDO INSUFICIENTE';
				
			ELIF cCodRet= "300" THEN
				LET cDescripcion = 'CUENTA BLOQUEADA';
				
            ELSE
                LET cDescripcion = 'ERROR EN CARGO REF';
                LET cCodRet= '029';
            END IF;
			
			-- Reversamos los movimientos realizados si falla el cargo a cuenta
			EXECUTE PROCEDURE bdicheq:"informix".reversion_web(pEmpresa,pSucursal,pUsuario,pFolio_suc,'A') INTO rCodRet;
			
            LET vcuenta        = '';
            LET vnum_cte       = '';
            LET vapell_pat     = '';
            LET vapell_mat     = '';
            LET vnombre1       = '';
            LET vnombre2       = '';
            LET vrazon_soc     = '';
            LET vedo_cta       = '';
            LET vsdo_ret       = 0;
            LET vsdo_ccc       = 0;
            LET vsdo_disp_ccc  = 0;
            LET vsdo_cta       = 0;
            LET vtipo_linea    = '';
            LET vdescrip1      = '';
            LET vdescrip2      = '';
            LET vsdo_t1        = 0;
            LET vsdo_cong      = 0;
            LET vimp_chq_sbc   = 0;
            LET vusubloq       = '';
            LET vfecbloq       = '';
            LET vnum_tarjeta   = '';
            LET vcta_clabe     = '';
            LET sFecExp        = '';
            LET vtranret       = '';
            LET vfechoy        = '';
            LET vsdodisp       = 0;
            LET vmontoret      = 0;
            LET vGenerico1     = '';
            LET vGenerico2     = '';
            LET vGenerico3     = '';
			
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
			vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
		
		END IF; -- End fallo en cargo a cuenta.
			
		-- Se realiza el abono a la cuenta de cheques de infonavit si el cargo al cliente se realizo correctamente
        EXECUTE PROCEDURE  bdicheq:"informix".abono_ref(pEmpresa ,pSucursal ,pUsuario ,pTransacc_abono ,pTransuc_abono ,pFolio_suc,pCuenta_abono,pDocto_abono,
        pMto_tot ,pMto_firme_abono ,pMto_sbc_abono,pMto_rem_abono ,pDias_ret_abono,pDivisa  ,pReferencia_abono,'' ,pUsuautoriza )
        INTO cCodRet;
			
		-- Validamos que el abono ref se ejecuto correctamente y en caso de fallara se asignara una descripcion correspondiente
		IF cCodRet !='000' THEN
			
            IF cCodRet ='004' THEN
                LET cDescripcion = 'SISTEMA CHEQUES NO DISPONIBLE';

            ELIF cCodRet= "200" THEN
                LET cDescripcion = 'CUENTA CANCELADA';

            ELIF cCodRet= '552' THEN
                LET cDescripcion = 'ERROR EN TRANSACCION DE ABONO';

            ELIF cCodRet= '152' OR cCodRet = '397' OR cCodRet= '371' THEN
                LET cDescripcion = 'LIMITE DE DEPOSITO EXCEDIDO';
                
            ELSE
                LET cDescripcion = 'ERROR EN ABONO REF';
                LET cCodRet = '039';
            END IF;
			
			-- Se reversa los movimientos realizados si no se realizo el abono a la cuenta de cheques de infonavit correctamente
			EXECUTE PROCEDURE  bdicheq:"informix".reversion_web(pEmpresa,pSucursal,pUsuario,pFolio_suc,'A') INTO rCodRet;

            LET vcuenta        = '';
            LET vnum_cte       = '';
            LET vapell_pat     = '';
            LET vapell_mat     = '';
            LET vnombre1       = '';
            LET vnombre2       = '';
            LET vrazon_soc     = '';
            LET vedo_cta       = '';
            LET vsdo_ret       = 0;
            LET vsdo_ccc       = 0;
            LET vsdo_disp_ccc  = 0;
            LET vsdo_cta       = 0;
            LET vtipo_linea    = '';
            LET vdescrip1      = '';
            LET vdescrip2      = '';
            LET vsdo_t1        = 0;
            LET vsdo_cong      = 0;
            LET vimp_chq_sbc   = 0;
            LET vusubloq       = '';
            LET vfecbloq       = '';
            LET vnum_tarjeta   = '';
            LET vcta_clabe     = '';
            LET sFecExp        = '';
            LET vtranret       = '';
            LET vfechoy        = '';
            LET vsdodisp       = 0;
            LET vmontoret      = 0;
            LET vGenerico1     = '';
            LET vGenerico2     = '';
            LET vGenerico3     = '';
			
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
			vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;

		END IF;
			
		-- Validamos que el pago de credito hipotecario infonavit se realizo correctamente
		
        LET cDescripcion = 'PAGO EXITOSO';
        LET cCodRet= '00000';

        -- Mandamos un correo de notificacion al cliente sobre el pago realizado a infonavit
        EXECUTE PROCEDURE  bdimnsj:"informix".sp_registra_evento (pTipoMsj,pIdMsj,pIdPlantilla,vnum_cte,pCuenta_cargo,'',pTipoProc,
                            pStr1,pStr2,pStr3,pStr4,pStr5,pStr6,pStr7,pStr8,pStr9,pStr10,pcorreo_alterno,pcelular_alterno,
                                pImporte1,pImporte2,pImporte3,pImporte4,pImporte5,pfecha1,pfecha2) INTO rCodRet;

        RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
        vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
		
	

    ----- Pago en efectivo -----
    ELSE IF  pFormaPago='1' THEN
			
		-- Valida que los sistemas de servicios y de cheques esten disponibles.		
        EXECUTE PROCEDURE  "informix".sp_grabapgserv_dina(pSucursal ,pCategoria ,pConvenio ,pNumReferencia ,pReferencia2,
		pFormaPago ,deImportePago,deImpComisionConvenio ,deIvaComisionConvenio ,deImpComisionCliente ,deIvaComisionCliente ,
		pCuenta_cargo ,pUsuario ,pFolio_suc ,pTransacc_suc ,dFechaPago)
		INTO cCodRet;
				
        -- Valida el codigo de retorno del sp_grabapgserv_dina y en caso de fallara se asignara una descripcion correspondiente
		IF cCodRet != '00000' THEN
			IF cCodRet ='01241' THEN
				LET cDescripcion = 'LA FECHA DEL SISTEMA Y DE CENTRAL SON DIFERENTES';

			ELIF cCodRet= '00060' THEN
				LET cDescripcion = 'SISTEMA SERVICIOS NO DISPONIBLE.';

			ELIF cCodRet= '00061' THEN
				LET cDescripcion = 'SISTEMA CHEQUES NO DISPONIBLE.';

			ELIF cCodRet= '00002' THEN
				LET cDescripcion = 'PAGO PREVIAMENTE APLICADO';
				
			ELSE
				LET cDescripcion = 'ERROR AL GUARDAR EL SERVICIO';
				LET cCodRet= '00019';
			END IF;
			
			-- Se retorna el resultado de la transaccion y los datos del cliente
			RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
					vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
            END IF;
				
            -- Se ejecuta el SP abono_ref el cual abona a la cuenta de cheques de infonavit
            EXECUTE PROCEDURE  bdicheq:"informix".abono_ref(pEmpresa ,pSucursal ,pUsuario ,pTransacc_abono ,pTransuc_abono ,pFolio_suc,pCuenta_abono,pDocto_abono,
            pMto_tot ,pMto_firme_abono ,pMto_sbc_abono,pMto_rem_abono ,pDias_ret_abono,pDivisa  ,pReferencia_abono,'' ,pUsuautoriza )
            INTO cCodRet;
                    
            -- Validamos que el codigo de retorno del sp abono_ref y en caso de fallara se asignara una descripcion correspondiente
            IF cCodRet !='000' THEN
                
				IF cCodRet ='004' THEN
					LET cDescripcion = 'SISTEMA CHEQUES NO DISPONIBLE';

				ELIF cCodRet= "200" THEN
					LET cDescripcion = 'CUENTA CANCELADA';

				ELIF cCodRet= '552' THEN
					LET cDescripcion = 'ERROR EN TRANSACCION DE ABONO';

				ELIF cCodRet= '152' OR cCodRet = '397' OR cCodRet= '371' THEN
					LET cDescripcion = 'LIMITE DE DEPOSITO EXCEDIDO';
					
				ELSE
					LET cDescripcion = 'ERROR EN ABONO REF';
					LET cCodRet = '039';
				END IF;
                
                -- Se reversa los movimientos realizados si no se realizo el abono correctamente
                EXECUTE PROCEDURE bdicheq:"informix".reversion_web(pEmpresa,pSucursal,pUsuario,pFolio_suc,'A') INTO rCodRet;
                
                RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
                vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;

            END IF;

            -- Validamos que el pago del credito hipotecario infonavit se realizo correctamente
            LET cDescripcion = 'PAGO EXITOSO';
            LET cCodRet= '00000';
        
            RETURN  cCodRet,cDescripcion,vcuenta,vnum_cte,vapell_pat,vapell_mat,vnombre1,vnombre2,vrazon_soc,vedo_cta,vsdo_ret,vsdo_ccc,vsdo_disp_ccc,vsdo_cta,
            vtipo_linea,vdescrip1,vdescrip2,vsdo_t1,vsdo_cong,vimp_chq_sbc,vusubloq,vfecbloq,vnum_tarjeta,vcta_clabe,sFecExp,vtranret,vfechoy,vsdodisp,vmontoret,vGenerico1,vGenerico2,vGenerico3;
            
        END IF;
    END IF;
END
END PROCEDURE

DOCUMENT 'AUTOR: Ezequiel Moreno, Osiel  Alfredo Camacho Mendoza',
'FECHA 31/07/2023',
'MODULO: Cheques',
'FUNCIONALIDAD: Pago del credito hipotecario infonavit en ATM',
'DESCRIPCION: SPL encargado de orquestar los SPL correspondientes para realizar el pago del credito hipotecario infonavit atravez del ATM',
'BD: bdisac',
'Modificacion: Paso de un nuevo parametro (numero cliente) en el SP anidado sp_registra_evento'
;

CREATE PROCEDURE "informix".sp_bitacorawstae( pNumCategoria CHAR(2), pNumConvenio CHAR(3), pId_Sucursal CHAR (4), pFolioSucursal CHAR (16), pFechaPago DATE, pCodigoRespuesta CHAR(40), pConceptoRespuesta CHAR(80), pReferencia CHAR (27), pNumTrama INTEGER)
   RETURNING CHAR(5) as CodRet;

	-- DeclaraciÃ³n de variables 
	DEFINE cCodRet 			CHAR(5);
	DEFINE iSqlErr         	INTEGER;
	DEFINE iFormaPago		INTEGER;
	DEFINE cFormaPago		CHAR (2);
	DEFINE iImporte			INTEGER;
	DEFINE cUser			CHAR (8);
	DEFINE iInserta			INTEGER;
	DEFINE cCompania		CHAR (10);
	DEFINE cNum_Clave		CHAR (2);

	LET cCodRet 		  = '00000';
	LET iSqlErr 		  = 0;
	LET iFormaPago		  = 0;
	LET cFormaPago		  = '';
	LET iImporte		  = 0;
	LET cUser			  = 'Informix';
	LET iInserta		  = 0;
	LET cCompania		  = '';
	LET cNum_Clave		  = '';
	  
	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;				
				IF iInserta = 0 THEN
					LET iInserta = 1;
					IF iSqlErr <> -268 THEN
						INSERT INTO bdisac: "informix".sac_pagostae (id_sucursal, fechapago, folio_suc, num_trama, no_telefono, codRet, cod_resp, conceptorespuesta, user_insert, fecha_insert) VALUES (pId_Sucursal, pFechaPago, pFolioSucursal, pNumTrama,pReferencia,cCodRet,pCodigoRespuesta,pConceptoRespuesta,'informix', current);
					end if;
				END IF;
				RETURN cCodRet;
			END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/respaldosbd/Trinidad/sp_bitacorawstae.out";
		--TRACE ON;
			
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;  	
		
		IF NVL (pNumCategoria, '') = '' OR NVL (pNumConvenio, '') = '' OR NVL (pId_Sucursal, '') = '' OR NVL (pFolioSucursal, '') = '' 
		  OR NVL (pFechaPago, '') = ''   OR NVL (pCodigoRespuesta, '') = ''  OR NVL (pConceptoRespuesta, '') = ''    OR  NVL (pReferencia, '') = ''   OR  NVL (pNumTrama, '') = ''  THEN
			LET cCodRet = '00002';
			--DATOS VACIOS, ERROR.
			RETURN cCodRet;
		END IF;
						
		--Solicita y guarda el valor de usuario de bdisac: sac_movimientos 
		SELECT importe_pago, forma_pago, referencia2, usuario INTO iImporte, iFormaPago, cCompania, cUser  FROM bdisac: "informix".sac_movimientos where id_sucursal = pId_Sucursal AND folio_suc = pFolioSucursal AND numcategoria = pNumCategoria AND numconvenio = pNumConvenio AND fecha_pago=pFechaPago;
		
		IF DBINFO("sqlca.sqlerrd2") = 0 THEN
			LET cCodRet = '00001';
		END IF;	
		
		--Verificamos y guardamos la clave de la compaÃ±ia telefonica en cNum_Clave		
		IF TRIM(UPPER(cCompania)) = 'TELCEL' THEN
			SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 83;
		ELSE
			IF TRIM(UPPER(cCompania)) = 'MOVISTAR' THEN
				SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 84;
			ELSE
				IF TRIM(UPPER(cCompania)) = 'AT&T' THEN
					SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 85;
				ELSE 
					IF TRIM(UPPER(cCompania)) = 'UNEFON' THEN
						SELECT TRIM(valor) INTO cNum_Clave FROM  bdisac:"informix".sac_param  where cod_param = 86;
					END IF;
				END IF;
			END IF;
		END IF;
		
		IF iFormaPago = 1 Then -- E-Efectivo
			SELECT TRIM(valor) INTO cFormaPago FROM  bdisac:"informix".sac_param  where cod_param = 87;
		Else
			IF iFormaPago = 2 Then -- CC-Cargo a cuenta
				SELECT TRIM(valor) INTO cFormaPago FROM  bdisac:"informix".sac_param  where cod_param = 88;
			Else
				IF iFormaPago = 5 Then -- TC-Tarjeta de credito
					SELECT TRIM(valor) INTO cFormaPago FROM  bdisac:"informix".sac_param  where cod_param = 89;
				END IF;
			END IF;
		END IF;
		
		-- Insertar bitacora en bdisac: sac_pagostae 
		INSERT INTO bdisac: "informix".sac_pagostae (id_sucursal, fechapago, folio_suc, num_trama, no_telefono, compania, cve_compania, forma_pago, importe, codRet, cod_resp, conceptorespuesta, user_insert, fecha_insert) VALUES (pId_Sucursal, pFechaPago, pFolioSucursal, pNumTrama, pReferencia, cCompania, cNum_Clave, cFormaPago, NVL(iImporte,0), cCodRet, pCodigoRespuesta, pConceptoRespuesta, NVL(cUser,'Informix'),current );


		RETURN cCodRet;
	END;   
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION:  SP para la bitacora de TAE que se insertarÃ¡ en la tabla bdisac: sac_pagostae ',
'FOLIO: 1468 - ModificacionVtaTiempoAireDobleConsulta',
'FECHA : 19/05/2015',
'VERSION: 20150219.2052',
'BD: bdisac',
'AUTOR : 90232799 - Christopher Siverio',
'Modificacion:  SE ajusta el nombre de iusasel a AT&T',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 14/10/2022',
'BD: bdisac',
'AUTOR : 90034397 - BRANDO GARCIA. / 90155378 - JORGE RIVAS.',
'MODIFICACION:  Se agregÃ³ control de nulos en variables [iImporte] y [cUser] al momento de insertar en la tabla sac_pagostae.',
'EJECUTADO O LLAMADO POR: Procesos - Pago de servicios TAECOPPEL',
'FECHA : 25/04/2023',
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_inicremesas()
RETURNING CHAR(5), CHAR(80);

	--Definicion de Variables
    DEFINE cCodRet          CHAR(5);
    DEFINE iSqlErr			INTEGER;
	DEFINE iIsamErr 		INTEGER;
    DEFINE cInfoErr         CHAR(100);
	DEFINE cMensaje			CHAR(150);
	DEFINE vCuenta			INTEGER;
	DEFINE vFechaInicio		DATE;
	DEFINE vFechaFinal		DATE;
	DEFINE vFechaHoy		DATE;
	DEFINE cSql				CHAR(1000);
	DEFINE cRutaArch 		CHAR(100);
	DEFINE iV_old 			INTEGER;
	DEFINE iV_sre 			INTEGER;
	DEFINE iV_tot 			INTEGER;
	DEFINE iV_fin 			INTEGER;
	DEFINE vStatus			INTEGER;
	
	--Registro de sac_remesas_estadistica
	DEFINE v_numcategoria	CHAR(2);
	DEFINE v_numconvenio	CHAR(5);
	DEFINE v_id_sucursal	CHAR(4);
	DEFINE v_referencia     CHAR(40);
	DEFINE v_importe_pago   MONEY;
	DEFINE v_usuario        CHAR(8);
	DEFINE v_folio_suc      CHAR(16);
	DEFINE v_fecha_pago     DATE;
	DEFINE v_origen         VARCHAR(2);
	DEFINE v_nombre1        VARCHAR(40);
	DEFINE v_nombre2        VARCHAR(40);
	DEFINE v_appaterno      VARCHAR(40);
	DEFINE v_apmaterno      VARCHAR(40);
	DEFINE v_fecha_nac      DATE;
	DEFINE v_rfc            VARCHAR(13);
	DEFINE v_moneda_origen  VARCHAR(3);
	DEFINE v_cuenta_benef   VARCHAR(30);
	DEFINE v_importe_origen MONEY;
	DEFINE v_status_cancelado	CHAR(1);

	-- Inicializa variables
	LET cCodRet            	= "00000";
	LET cMensaje			= 'PROCESO EXITOSO';
	
	--SET DEBUG FILE TO '/informix/RPT/inicremesas/exec_sp_inicremesas.out';
	--TRACE ON;

    BEGIN
	
		ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
			--Manejo de errores, en caso de error, envÃ­o codigo de error y guarda evidencia
            IF iSqlErr <> 0 THEN
                LET cCodRet = iSqlErr;
                EXECUTE PROCEDURE bdisac:"informix".sp_sac_guardamensajeerror(iSqlErr, iIsamErr, cInfoErr, "sp_inicremesas");
				
				LET cMensaje = "ERROR EN LA EJECUCION DEL SP";
                RETURN cCodRet, cMensaje;
            END IF;
        END EXCEPTION;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ;
		
		LET vFechaHoy = TODAY;
		LET cRutaArch = '/RESPALDOSNEW/remesas_estadisticas';
		
		--Determino periodos
		
		IF MONTH(vFechaHoy) != 1 THEN
			LET vFechaInicio		= MDY(MONTH(vFechaHoy)-1,1,YEAR(vFechaHoy));
			LET vFechaFinal			= MDY(MONTH(vFechaHoy),1,YEAR(vFechaHoy))-1;
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl SELECT numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado FROM	bdisac:"informix".sac_remesas_estadistica WHERE	fecha_pago >= MDY(MONTH(today)-1,1,YEAR(today)) AND fecha_pago <= MDY(MONTH(today),1,YEAR(today))-1 ORDER BY fecha_pago ASC;" > ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
		ELSE
			LET vFechaInicio		= MDY(12,1,YEAR(vFechaHoy)-1);
			LET vFechaFinal			= MDY(12,31,YEAR(vFechaHoy)-1);
			LET cSql = '';
			LET cSql = 'echo "UNLOAD TO ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl SELECT numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado FROM	bdisac:"informix".sac_remesas_estadistica WHERE	fecha_pago >= MDY(12,1,YEAR(today)-1) AND fecha_pago <= MDY(12,31,YEAR(today)-1) ORDER BY fecha_pago ASC;" > ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
		END IF;
		
		LET vStatus = 0;
		
		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P1' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
			--Paso 1--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P1', today, '0', 'informix', 'sp_inicremesas', 'Descarga los datos de sac_remesas_estadisticas');
			
			--Obtengo datos para bajarlos en un UNL desde la tabla sac_remesas_estadistica
			LET cSql = '';
			LET cSql = 'chmod 777 ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
			LET cSql = '';
			LET cSql = 'dbaccess bdisac ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;
			LET cSql = "";
			LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
			SYSTEM cSql;

			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj(1, 'INS_REMEST_OLD_P1', today, '1', 'informix', 'sp_inicremesas', 'Descarga los datos de sac_remesas_estadisticas');	
			--Paso 1 fin------------------------------------------------------------------------------------------------------------------------------------------------------------------------------			
		END IF;
		
		LET vStatus = 0;

		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P2' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
			--Comienza la carga de datos a la tabla sac_remesas_estadistica_old
			
			--Aqui va la validacion de si el proceso es 0 (buscar con un count un resultado con status 0) eliminar todo de la old con rangos de fechas, si no, nada
			LET vStatus = 0;
			
			SELECT COUNT(*)
			INTO vStatus 
			FROM sac_procesos_jobs 
			WHERE proceso = 'INS_REMEST_OLD_P2' 
			AND status = 0
			AND fecha_proceso >= vFechaFinal;
			
			IF vStatus <> 0 THEN
			
				--Eliminamos el proceso con status 0 para que siga flujo normal
				DELETE
				FROM sac_procesos_jobs 
				WHERE proceso = 'INS_REMEST_OLD_P2' 
				AND status = 0
				AND fecha_proceso >= vFechaFinal;
			
				LET vCuenta = 0;
		
				BEGIN WORK;
					FOREACH WITH HOLD
						SELECT 	numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,
								appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado
						INTO	v_numcategoria, v_numconvenio, v_id_sucursal, v_referencia, v_importe_pago, v_usuario, v_folio_suc, v_fecha_pago, v_origen, v_nombre1, v_nombre2,
								v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cuenta_benef, v_importe_origen, v_status_cancelado
						FROM	bdisac:"informix".sac_remesas_estadistica_old
						WHERE	fecha_pago                 >= vFechaInicio
						AND		fecha_pago                 <= vFechaFinal
						ORDER BY fecha_pago
									
						DELETE FROM bdisac:"informix".sac_remesas_estadistica_old
						WHERE  numcategoria = v_numcategoria
						AND    numconvenio  = v_numconvenio
						AND    id_sucursal  = v_id_sucursal
						AND    referencia   = v_referencia
						AND    folio_suc    = v_folio_suc;
									
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
			-----------------------------------------------------------------------------------------
			SELECT COUNT(*)
			INTO iV_old
			FROM sac_remesas_estadistica_old;
			
			SELECT COUNT(*) 
			INTO iV_sre
			FROM sac_remesas_estadistica 
			WHERE	fecha_pago >= vFechaInicio
			AND fecha_pago <= vFechaFinal;
			
			LET iV_tot = iV_old + iV_sre;
			--LET iV_tot = iV_tot - 1;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P2', today, '0', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
			
			LET cSql = ''; 
			LET cSql = ' echo "FILE ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl DELIMITER '|| "'" || '|' || "'" || ' 19;' || '">' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;

			LET cSql = ''; 
			LET cSql = ' echo "INSERT INTO "informix".sac_remesas_estadistica_old;' || '">> ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;
			
			LET cSql = ''; 
			LET cSql = 'chmod 777 ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql'; 
			SYSTEM cSql;
			
			LET cSql = ''; 
			LET cSql = 'dbload -d bdisac -c ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql' || ' -l ' || TRIM(cRutaArch) || '/remesas_estadisticas.log' || ' -n 1000 -r'; 
			SYSTEM cSql;
			
			--EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P2', today, '1', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
			
			SELECT COUNT(*)
			INTO iV_fin
			FROM sac_remesas_estadistica_old;
			
			
			IF iV_tot = iV_fin THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P2', today, '1', 'informix', 'sp_inicremesas', 'Carga los datos a sac_remesas_estadisticas_old');
				LET cSql = "";
				LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.sql';
				SYSTEM cSql;
				
				LET cSql = "";
				LET cSql = 'rm -f ' || TRIM(cRutaArch) || '/remesas_estadisticas.unl';
				SYSTEM cSql;
				
			ELSE 
				LET cCodRet            	= "00001";
				LET cMensaje			= 'Error en la carga de datos.';
				RETURN cCodRet, cMensaje;
			END IF; 
			
			
		END IF;
		
		--Eliminamos los datos de la tabla sac_remesas_estadistica
		
		LET vStatus = 0;

		SELECT COUNT(*)
		INTO vStatus 
		FROM sac_procesos_jobs 
		WHERE proceso = 'INS_REMEST_OLD_P3' 
		AND status = 1
		AND fecha_proceso >= vFechaFinal;
		
		IF vStatus = 0 THEN
		
			LET vStatus = 0;

			SELECT COUNT(*)
			INTO vStatus 
			FROM sac_procesos_jobs 
			WHERE proceso = 'INS_REMEST_OLD_P3' 
			AND status = 0
			AND fecha_proceso >= vFechaFinal;
		
			IF vStatus <> 0 THEN
		
				DELETE
				FROM sac_procesos_jobs 
				WHERE proceso = 'INS_REMEST_OLD_P3' 
				AND status = 0
				AND fecha_proceso >= vFechaFinal;
		
			END IF;
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (0, 'INS_REMEST_OLD_P3', today, '0', 'informix', 'sp_inicremesas', 'Depuracion de la tabla sac_remesas_estadisticas');
			LET vCuenta = 0;
			
			BEGIN WORK;
				FOREACH WITH HOLD
					SELECT 	numcategoria, numconvenio, id_sucursal, referencia, importe_pago, usuario, folio_suc, fecha_pago, origen, nombre1, nombre2,
							appaterno, apmaterno, fecha_nac, rfc, moneda_origen, cuenta_benef, importe_origen, status_cancelado
					INTO	v_numcategoria, v_numconvenio, v_id_sucursal, v_referencia, v_importe_pago, v_usuario, v_folio_suc, v_fecha_pago, v_origen, v_nombre1, v_nombre2,
							v_appaterno, v_apmaterno, v_fecha_nac, v_rfc, v_moneda_origen, v_cuenta_benef, v_importe_origen, v_status_cancelado
					FROM	bdisac:"informix".sac_remesas_estadistica
					WHERE	fecha_pago                 >= vFechaInicio
					AND		fecha_pago                 <= vFechaFinal
					ORDER BY fecha_pago
								
					DELETE FROM bdisac:"informix".sac_remesas_estadistica
					WHERE  numcategoria = v_numcategoria
					AND    numconvenio  = v_numconvenio
					AND    id_sucursal  = v_id_sucursal
					AND    referencia   = v_referencia
					AND    folio_suc    = v_folio_suc;
								
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
			
			EXECUTE PROCEDURE bdisac:"informix".sp_bitacoraspj (1, 'INS_REMEST_OLD_P3', today, '1', 'informix', 'sp_inicremesas', 'Depuracion de la tabla sac_remesas_estadisticas');
		END IF;
	--Actualizo estadisticas para la tabla sac_remesas_estadistica
		UPDATE STATISTICS MEDIUM FOR TABLE bdisac:"informix".sac_remesas_estadistica;

		RETURN cCodRet, cMensaje;
		
    END;
END PROCEDURE
DOCUMENT
'AUTOR          : Luis Felipe Prieto',
'DESCRIPCION    : Se encarga de guardar informaciÃ³n al historico, asimismo truncar la tabla sac_remesas_estadistica',
'FECHA CREACION : 15 de Junio de 2018',
'BD             : bdisac';

CREATE PROCEDURE "informix".sp_sac_valida_ctesremesas(pNumCte CHAR(20), pNombre1 CHAR(26), pNombre2 CHAR(26), pApell_paterno CHAR(26), pApell_materno CHAR(26), pFecha_nac CHAR(20), pNumIdentificacion CHAR(30))
RETURNING  
            CHAR(5) AS cCodRet,
            CHAR(20) AS cNumcte,
            CHAR(1) AS iTipoCliente,
            CHAR(5) AS cValIne,
            CHAR(5) AS cListaNegra,
            CHAR(5) AS cSespecial,
            CHAR(13) AS cRfc;

            DEFINE cCodRet CHAR(5);
            DEFINE cNumcte CHAR(20);
            DEFINE iTipoCliente CHAR(1);
            DEFINE cValIne CHAR(5);
            DEFINE cResultINE CHAR(50);
            DEFINE cListaNegra CHAR(5);
            DEFINE cSespecial CHAR(5);
            DEFINE cStatuscte CHAR(1);
            DEFINE cRfc CHAR(13);
            DEFINE cCodRetRfc CHAR(5);

            DEFINE iSqlErr INTEGER;
            DEFINE iIsamErr INTEGER;
            DEFINE cInfoErr CHAR(10);

            DEFINE icontEsp INTEGER;
            DEFINE iContList INTEGER;

            DEFINE cSituacion CHAR(5);
            DEFINE cCausa CHAR(5);
            DEFINE iContListRfc INTEGER;
            DEFINE cRfcCte CHAR(13);
            DEFINE pNombre3 CHAR(40);

            LET cCodRet = "00000";
            LET cNumcte = "";
            LET iTipoCliente = "";
            LET cValIne = "";
            LET cListaNegra = "";
            LET cSespecial = "";
            LET cStatuscte = "";
            LET cRfc = "";

            LET icontEsp = 0;
            LET iContList = 0;

            LET pNumIdentificacion = TRIM(pNumIdentificacion);

            LET cSituacion = '';
            LET cCausa = '';
            LET cRfc = '';
            LET iContListRfc = 0;
            LET cRfcCte = "";
            LET pNombre3 = "";

          --SET DEBUG FILE TO '/informix/ENP/spHuellas/out/sp_sac_valida_ctesremesas.out';
          --TRACE ON;

BEGIN 
            ON EXCEPTION SET iSqlErr, iIsamErr, cInfoErr
                IF iSqlErr <> 0 THEN
                    LET cCodRet = iSqlErr::CHAR(5);
                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                END IF;
	        END EXCEPTION;	

            SET ISOLATION TO DIRTY READ;
            SET LOCK MODE TO WAIT 3;
          ----------------------------BUSEQUEDA POR NUM CTE-----------------------------------
        IF  NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = ""AND NVL(pFecha_nac::DATE, "") = "" and NVL(pNumIdentificacion, "") = ""  THEN

            SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
            FROM bdinteg :"informix".si_cliente cte
                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
            WHERE cte.numcte = pNumCte;
                
                IF NVL(cNumcte, "") = "" THEN
                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                    FROM bdinteg :"informix".si_cliente cte
                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                    WHERE cte.numcte = pNumCte
                    AND cte.tipo_cliente in("1", "2");
                            
                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                        LET iTipoCliente = "3";
                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                    END IF;
                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                        END IF;
                END IF;
                    ----------------------------BUSEQUEDA POR NUM DE IDENTIFICACION----------------------------
                        ELSE 
                            IF NVL(pNumCte, "") = ""AND NVL(pNombre1, "") = ""AND NVL(pNombre2, "") = ""AND NVL(pApell_paterno, "") = ""AND NVL(pApell_materno, "") = "" AND NVL(pFecha_nac::DATE, "") = "" THEN
                                SELECT cterem.numcte,"1",cterem.status_cte,cte.rfc INTO cNumcte,iTipoCliente,cStatuscte,cRfc
                                FROM bdinteg :"informix".si_cliente cte
                                INNER JOIN bdinteg :"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                INNER JOIN bdisac :"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                WHERE ctepf.numidentifi = pNumIdentificacion;

                                IF NVL(cNumcte, "") = "" THEN
                                    SELECT cte.numcte,"2",cte.rfc INTO cNumcte,iTipoCliente,cRfc
                                    FROM bdinteg :"informix".si_cliente cte
                                    INNER JOIN bdinteg :"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte
                                    WHERE ctepf.numidentifi = pNumIdentificacion
                                    AND cte.tipo_cliente in("1", "2");

                                    IF NVL(cNumcte, "") = "" THEN LET cNumcte = "000000000";
                                        LET iTipoCliente = "3";
                                        RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                    END IF;
                                        ELSE IF TRIM(cStatuscte) <> "A" THEN LET cCodRet = "00003";
                                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                END IF;
                            END IF;
                            -----------------------------------BUSEQUEDA POR NUM nombre y fecha de nacimiento-----------------------------------
                                ELSE 
                                    IF  NVL(pNumCte, "") = "" AND NVL(pNumIdentificacion, "") = "" THEN 
                                        LET pNombre3 = TRIM(pNombre1)||' '||TRIM(pNombre2);
                                        LET pNombre1 = TRIM(pNombre1);
                                        LET pNombre2 = TRIM(pNombre2);
                                        LET pApell_paterno = TRIM(pApell_paterno);
                                        LET pApell_materno = TRIM(pApell_materno);	
                                        EXECUTE PROCEDURE bdinteg:sp_calcularrfc(pApell_paterno,pApell_materno,pNombre3,pFecha_nac::DATE) INTO cCodRetRfc, cRfc;
                                        IF NVL(cCodRetRfc,'') <> '00000' THEN
                                            LET cCodRet = cCodRetRfc;
                                        END IF;
                                        
                                        SELECT     cterem.numcte, "1", cterem.status_cte
                                        INTO       cNumcte, iTipoCliente, cStatuscte
                                            FROM       bdinteg:"informix".si_cliente cte 
                                        INNER JOIN bdinteg:"informix".si_ctepf ctepf ON cte.numcte = ctepf.numcte
                                        INNER JOIN bdisac:"informix".sac_cte_remesas cterem ON cterem.numcte = cte.numcte
                                            WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                        AND		   TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                        AND        TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                        AND        TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                        AND        TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                        OR         cte.rfc = cRfc ;

                                            IF NVL(cNumcte,"") = "" THEN
                                                SELECT      cte.numcte, "2"
                                                INTO        cNumcte, iTipoCliente
                                                FROM        bdinteg:"informix".si_cliente cte 
                                                INNER JOIN  bdinteg:"informix".si_ctepf ctepf on cte.numcte = ctepf.numcte 
                                                WHERE      	ctepf.fecha_nac = pFecha_nac::DATE 
                                                AND			TRIM(cte.Nombre1)=  TRIM(pNombre1)
                                                AND         TRIM(cte.Nombre2) =  TRIM(pNombre2)
                                                AND        	TRIM(cte.apell_paterno) =  TRIM(pApell_paterno)
                                                AND        	TRIM(cte.apell_materno) =  TRIM(pApell_materno)
                                                OR          cte.rfc = cRfc  
                                                AND         cte.tipo_cliente in("1","2");

                                                IF NVL(cNumcte,"") = "" THEN
                                                    LET cNumcte = "000000000";
                                                    LET iTipoCliente = "3";
                                                    SELECT COUNT(*) INTO iContListRfc FROM bdiauditor:"informix".tbl_listainterna  WHERE rfc = cRfc;
                                                    LET iContList = iContList + iContListRfc;
                                                    IF iContList > 0 THEN
                                                        LET cListaNegra = "True";
                                                        LET iTipoCliente = "2";
                                                        LET cNumcte = "000000001";
                                                    END IF;
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;

                                            ELSE
                                                IF TRIM(cStatuscte) <> "A" THEN
                                                    LET cCodRet = "00003";
                                                    RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
                                                END IF;
                                END IF;
                         END IF;
                END IF;
        END IF;
                -----------------------------------Validacion de INE -----------------------------------
                    SELECT resultado INTO cResultINE
                    FROM bdinteg :"informix".si_bitacora_ife
                    WHERE numcte = cNumcte
                    AND fecha = (SELECT MAX(fecha)FROM bdinteg :"informix".si_bitacora_ife WHERE numcte = cNumcte);
                    IF ((TRIM(NVL(cResultINE, "")) = "") AND (iTipoCliente = 1 OR iTipoCliente = 2))
                        OR (UPPER(TRIM(cResultINE)) = "VERDADERO")
                        OR (UPPER(TRIM(cResultINE)) = "TRUE") THEN LET cValIne = "True";
                        ELIF (TRIM(NVL(cResultINE, "")) = "") AND iTipoCliente = 3 THEN 
                        LET cValIne = "";
                            ELIF (UPPER(TRIM(cResultINE)) = "FALSO")
                            OR (UPPER(TRIM(cResultINE)) = "FALSE") THEN LET cValIne = "False";
                    END IF;
                    ----------------------------------Validacion LISTA NEGRA  -----------------------------------
                        SELECT COUNT(*) INTO iContList
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE numcte = cNumCte;

                        SELECT COUNT(*) INTO iContListRfc
                        FROM bdiauditor :"informix".tbl_listainterna
                        WHERE rfc = cRfc;
                        LET iContList = iContList + iContListRfc;

                        IF iContList > 0 THEN LET cListaNegra = "True";
                            ELSE LET cListaNegra = "False";
                        END IF;
                        -----------------------------------Validacion SITUACION ESPECIAL -----------------------------------
                            SELECT COUNT(*) INTO icontEsp
                            FROM bdisitesp :"informix".se_ctessitespcte
                            where numcte = cNumCte;

                            IF icontEsp > 0 THEN
                                SELECT situacion,causa INTO cSituacion,cCausa
                                FROM bdisitesp :"informix".se_ctessitespcte
                                where numcte = cNumCte;
                                LET cSituacion = TRIM(cSituacion) || TRIM(cCausa);

                                IF cSituacion IN ('F42', 'P72', 'P108', 'U60') THEN LET cSespecial = "True";
                                    ELSE LET cSespecial = "False";
                                END IF;
        
                                ELSE LET cSespecial = "False";
                            END IF;
                            RETURN cCodRet,cNumcte,iTipoCliente,cValIne,cListaNegra,cSespecial,cRfc;
END;
END PROCEDURE

DOCUMENT
'DESCRIPCION: Valida datos cliente (INE, Lista negra y Situacion especial) por numero de clietne , numero de identificacion o nombre ',
'AUTOR: Edgar Navarro',
'SUSTENTO: RQM 10 1534 Envio de remesas outbound',
'FECHA DE MOFICACION: 01/08/2022',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC',
'------------------------------------------------------------------------------------------------------------------------',
'FOLIO: 433',
'DESCRIPCION: Actualiza informacion de usuario de remesas',
'AUTOR: MARCO RIVERA',
'SUSTENTO: 433 REQ. Base de datos para el alta de usuarios de remesas',
'FECHA DE CREACION: 21/08/2018',
'SOLICITA: LEONARDO HERNANDEZ',
'BD: BDISAC';

CREATE PROCEDURE "informix".sp_valida_ctehuella_comp(pNumCte CHAR(20))
    --DATOS A REGRESAR---
    RETURNING CHAR(5),CHAR(942),CHAR(942);
    
    --DEFINICION DE VARIABLES--
    DEFINE iSql_err INTEGER;
    DEFINE cCodRet  CHAR(5);
    DEFINE cHuellaD CHAR(942);
    DEFINE cHuellaI CHAR(942);
   	DEFINE existe INTEGER;
    
    --SET DEBUG FILE TO "/informix/jfponce/gabriel/err/sp_generahuellalinea.out";
    --TRACE ON;

    --INICIALIZACION DE VARIABLES--
    LET iSql_err = 0;
    LET cCodRet  = '00000';
    LET cHuellaD = "";
    LET cHuellaI = "";
   	let existe = 0;

BEGIN
    ON EXCEPTION SET iSql_err
        IF iSql_err    <> 0 THEN
            LET cCodRet = iSql_err;
            RETURN cCodRet, cHuellaD,cHuellaI;
        END IF;
    END EXCEPTION;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO WAIT 3;
    
    SELECT 1, dmapa, imapa
    INTO existe, cHuellaD, cHuellaI
    FROM bdinteg:"informix".si_cte_huella
    WHERE numcte = pNumcte AND estado ="A";

    IF existe IS NULL THEN
        LET cCodRet="00001";
        RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
    END IF;
   
    RETURN cCodRet, TRIM(cHuellaD),TRIM(cHuellaI);
END;
END PROCEDURE;