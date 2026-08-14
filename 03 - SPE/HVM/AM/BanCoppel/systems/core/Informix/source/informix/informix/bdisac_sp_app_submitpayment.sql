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
	pfecha				DATE,
	pNumCte			    CHAR(20)
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
		DEFINE vfec_nac				DATE;
		
		DEFINE vCodRet				CHAR(5);
		DEFINE vcuenta				INTEGER;
		DEFINE vCategoria			CHAR(2);
		DEFINE vConvenio			CHAR(5);
		
		
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
		
		LET vcuenta				= 0;
		LET vCodRet				= '00000';
		LET vCategoria			= '07';
		LET vConvenio			= '009';
		
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
		
			-- verifica si los mensajes de regreso estan en el catalado para regresarlos en espaÃ?ÃÂ±ol 
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
				-- concatenar parametro con el mensaje en espaÃ?ÃÂ±ol "El parÃ?ÃÂ¡metro requerido: {0} parÃ?ÃÂ¡metro clave."
				LET crsp_Message_Detail = REPLACE(crsp_Message_Detail,"{0}", trim(c_Mess_D));
				-- asigna mensaje que devera retornar
				LET cr_Message_Detail = crsp_Message_Detail;
			END IF;
			--Inserta registro
			IF (cCodRet = '00000')THEN
								
				INSERT INTO bdisac: "informix".sac_app_payi (txn_status,unirefnum,refnum,code,channeldid,locationunit,nnumber,typecode,countrycode,statecode,terminalid,processdate,processtime,customernumber,firstname,middlename,lastname,mommaidenname,adress,city,countrycodeadr,statecodeadr,zipcode,email,homephonenum,numbercel,receiveemail,receivesms,typecodeci,numberci,expirationdate,issuercc,dateofbirth,contrycode,r_operacion,r_code,r_message,r_code_d,r_message_d,r_processdate,r_processtime,r_rule,r_value,r_globtracknum,r_ordstatuscode,r_ordstatusdate,r_ordstatustime,r_uniquerefnum,r_codesalecom,r_countrycode,r_statecodesale,r_saledate,r_saletime,r_countrycode_o,r_currencycode,r_servicecode,r_countrycode_d,r_currencycod_d,r_delimethodcod,r_playnwcode,r_paysubnwcode,r_branchnumber,r_accounttcod,r_accountnumber,r_originamount,r_destinamount,r_rexchangerate,r_wholesalerate,r_deexhangerate,r_servfeeamount,r_discountamoun,r_typecode,r_accountnum,r_biccode,r_refnumber,r_customernum,r_firstname,r_middlename,r_lastname,r_mommaidenname,r_address,r_city,r_countrycode_a,r_statecode,r_zipcode,r_typecode_i,r_number,r_expirdate,r_isscontrycode,r_issstatecode,r_dateofbirth,r_customernum_b,r_firstname_b,r_middlename_b,r_lastname_b,r_mommaidenna_b,r_firstname_f,r_middlename_f,r_lastname_f,r_mommaidenna_f,r_address_b,r_city_b,r_countrycode_b,r_statecode_b,r_zipcode_b,r_email,r_homephonenum,r_workphonenum,r_number_cl,r_receiveemail,r_receivesms,r_typecode_ib,r_number_ib,r_expirdate_ib,r_issconcode_ib,r_issstacode_ib,r_reastypecode,r_refortransfer,r_sourceoffunds,r_securphrase,r_feemessage,user_insert,fecha,numcte) 
				VALUES (ptxn_status, punirefnum, prefnum, pcode, pchanneldid, plocationunit, pnnumber, ptypecode, pcountrycode, pstatecode, pterminalid, pprocessdate, pprocesstime, pcustomernumber, pfirstname, pmiddlename, plastname, pmommaidenname, padress, pcity, pcountrycodeadr, pstatecodeadr, pzipcode, pemail, phomephonenum, pnumbercel, preceiveemail, preceivesms, ptypecodeci, pnumberci, pexpirationdate, pissuercc, pdateofbirth, pcontrycode, pr_operacion, pr_code, cr_Message, pr_code_d, cr_Message_Detail,  pr_processdate, pr_processtime, pr_rule, pr_value, pr_globtracknum, pr_ordstatuscode, pr_ordstatusdate, pr_ordstatustime, pr_uniquerefnum, pr_codesalecom, pr_countrycode, pr_statecodesale, pr_saledate, pr_saletime, pr_countrycode_o, pr_currencycode, pr_servicecode, pr_countrycode_d, pr_currencycod_d, pr_delimethodcod, pr_playnwcode, pr_paysubnwcode, pr_branchnumber, pr_accounttcod, pr_accountnumber, pr_originamount, pr_destinamount, pr_rexchangerate, pr_wholesalerate, pr_deexhangerate, pr_servfeeamount, pr_discountamoun, pr_typecode, pr_accountnum, pr_biccode, pr_refnumber, pr_customernum, pr_firstname, pr_middlename, pr_lastname, pr_mommaidenname, pr_address, pr_city, pr_countrycode_a, pr_statecode, pr_zipcode, pr_typecode_i, pr_number, pr_expirdate, pr_isscontrycode, pr_issstatecode, pr_dateofbirth, pr_customernum_b, pr_firstname_b, pr_middlename_b, pr_lastname_b, pr_mommaidenna_b, pr_firstname_f, pr_middlename_f, pr_lastname_f, pr_mommaidenna_f, pr_address_b, pr_city_b, pr_countrycode_b, pr_statecode_b, pr_zipcode_b, pr_email, pr_homephonenum, pr_workphonenum, pr_number_cl, pr_receiveemail, pr_receivesms, pr_typecode_ib, pr_number_ib, pr_expirdate_ib, pr_issconcode_ib, pr_issstacode_ib, pr_reastypecode, pr_refortransfer, pr_sourceoffunds, pr_securphrase, pr_feemessage, puser_insert, CURRENT,pNumCte);
				IF DBINFO("sqlca.sqlerrd2") = 0 THEN
					LET cCodRet = '00001';
				ELSE
					LET vfec_nac = MDY(SUBSTRING(pdateofbirth FROM 5 FOR 2), SUBSTRING(pdateofbirth FROM 7 FOR 2), SUBSTRING(pdateofbirth FROM 1 FOR 4));
					EXECUTE PROCEDURE bdisac:"informix".sp_actualizaremesa(vCategoria, vConvenio, punirefnum, pfirstname, pmiddlename, plastname, pmommaidenname, vfec_nac, pr_currencycode, pr_originamount)
					INTO vCodRet, vcuenta;
				END IF;
			END IF;

			RETURN cCodRet, NVL(cr_Message, ''),  NVL(cr_Message_Detail, '') ;
			
		END IF;

		

END;
END PROCEDURE
DOCUMENT
'AUTOR : 95992243 - Trinidad Hernandez',
'DESCRIPCION: ServirÃ?ÃÂ¡ para insertar en la tabla sac_app_payi',
'FOLIO: 1543 - PagosApprizaDLL',
'FECHA : 22/03/2016',
'VERSION: 20160318.0921',	
'BD: bdisac',
'-----------------------------------------------------------------------------------------------------------------------',
'DescripciÃÂ³n: Se insertan campo numcte para Trabajar en remesas',
'Autor      : Geovani Garcia Ochoa',
'FECHA DE CREACION    : 28/02/2017',
'BD         : bdisac ',
'FOLIO: 198 - RQM 10 784 B ASE DE DATOS PARA EL ALTA DE USUARIOS DE REMESAS',
'-----------------------------------------------------------------------------------------------------';

CREATE PROCEDURE "informix".sp_confpago_remesa 
(
	cReferencia1 		CHAR (20),
	cCategoria 			CHAR (2), 
	cConvenio 			CHAR(5),
	cFolio_suc 			CHAR (16),
	pNewMtcn 			CHAR(16), 
	pMtcn 				CHAR(10), 
	pBenefCiudad 		CHAR(24), 
	pBenefEdo 			CHAR(40),
	pRetCode 			CHAR(5), 	
	pDesError 			CHAR(250), 
	pFechaHoraRp 		DATETIME YEAR TO SECOND, 
	pFechaInsert 		DATETIME YEAR TO SECOND,
	pFechaNac 			CHAR(8),
	pUsuario			CHAR(8),  
	pBenefNameType 		CHAR(1), 
	pBenefNombreUno		CHAR(40), 
	pBenefNombreDos		CHAR(40), 
	pBenefApaterno		CHAR(40), 
	pBenefAmaterno		CHAR(40), 
	pMoneyTransferKey	CHAR(10),  
	pForeignRefNumRq	CHAR(16), 
	pForeingRefNumRp	CHAR(16), 
	pUserInsert			CHAR(8),
	pConfPago           CHAR(1),
	pNumClienteRemesa   CHAR(20)
)
RETURNING
CHAR(5);

    -- Definicion de Variables
    DEFINE cCodRet CHAR(5);
    DEFINE iSql_err INTEGER;
	DEFINE iIsamErr INTEGER;
	DEFINE cDescripcion CHAR (200);
	DEFINE cConf_pago CHAR(1);
	DEFINE cTxn_status CHAR(1);
	DEFINE dMaxFexha DATETIME YEAR TO SECOND;
	DEFINE cod_errPayWU CHAR(5);
	DEFINE error_descPayWU CHAR(30);
	DEFINE cMarca CHAR(2);
	
	
	LET cCodRet = '00000';
	LET iSql_err = 0;
	LET iIsamErr = 0;
	LET cDescripcion = '';
	LET cConf_pago = '';
	LET cTxn_status = '';
	LET dMaxFexha = '1900-01-01 00:00:00';
	LET cod_errPayWU= '';
	LET error_descPayWU = '';
	
	-- SET DEBUG FILE TO '/tmp/isaac/trace.sql';
	-- TRACE ON;
	 

    BEGIN
		ON EXCEPTION SET iSql_err, iIsamErr, cDescripcion
		   IF iSql_err <> 0 THEN
			  LET cCodRet = iSql_err;
			  RETURN cCodRet;
		   END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		


		IF  NVL(cReferencia1,'') <> ''THEN		
		
				
				IF cCategoria = '07' AND ( cConvenio = '006') THEN LET cMarca = 'WU'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '007') THEN LET cMarca = 'OV'; END IF;
				IF cCategoria = '07' AND ( cConvenio = '008') THEN LET cMarca = 'VI'; END IF;								
				
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_wu_guardarespuesta_pay(pUsuario,pBenefNameType,pBenefNombreUno,pBenefNombreDos,pBenefApaterno,pBenefAmaterno,pFechaNac,pMoneyTransferKey,pNewMtcn,pMtcn,pForeignRefNumRq,pRetCode,pForeingRefNumRp,pDesError,pUserInsert,pConfPago,pNumClienteRemesa)
			    INTO cod_errPayWU, error_descPayWU;
				
				SELECT MAX(fecha_insert)
				INTO dMaxFexha
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE mtcn = cReferencia1
				AND TO_CHAR(fecha_insert::DATE) = TODAY;									
									
				SELECT conf_pago, txn_status 
				INTO cConf_pago, cTxn_status 
				FROM bdisac:'informix'.sac_wu_pay 
				WHERE  mtcn = cReferencia1 
				AND fecha_insert = dMaxFexha;	

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '00002';
				ELSE
					IF NVL(cConf_pago,'') <> '' AND NVL(cTxn_status,'') <> '' THEN
						IF TRIM(cConf_pago) <> 'P' AND TRIM(cTxn_status) <>'A' THEN
							LET cCodRet = '00004';
						END IF;
					ELSE
						LET cCodRet = '00003';
					END IF;
				END IF;

		ELSE
			LET cCodRet = '00001';
		END IF;	

		RETURN cCodRet;
    END;
END PROCEDURE;