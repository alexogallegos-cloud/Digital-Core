CREATE PROCEDURE "informix".sp_tokenizacion_deliverotp( pconsumer_id CHAR(64),pissuer_id CHAR(10), px_correlation_id CHAR(64),pvalue_otp CHAR(10),
							pexpiration_date CHAR(32), preason CHAR(50), pdelivery_channel CHAR(5), id_card_requestor CHAR(11),
							pwallet_id  CHAR(32), pname LVARCHAR, ptspi_id CHAR(11),poriginal_digitalcard_requestorid CHAR(11),
							precommendation CHAR(20), pdigital_card_storagetype CHAR(32), pphone_number CHAR(20), pdevice_name CHAR(128),
							ppan_suuffix CHAR(4))
	RETURNING  CHAR(5) AS codretorno,  CHAR(150) AS descodretorno;

--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codigoRetorno				CHAR (05);
DEFINE desCodRetorno 				CHAR (80);
DEFINE outNumTel					CHAR(14);
DEFINE inNumCliente					CHAR(13);
DEFINE outNumCliente				CHAR(13);
DEFINE codRetornoNotif 				CHAR(5);
DEFINE contrato 					CHAR(12);
DEFINE plantillaSMS 				CHAR(12);
DEFINE inOTP						CHAR(10);
DEFINE inNombreWallet				LVARCHAR;
DEFINE outCorreo					CHAR(100);	
DEFINE contraroEMAIL				CHAR(12);
DEFINE plantillaEMAIL				CHAR(12);	

--Inicializacion de Variables
LET isqlerr 						= 0;
LET codigoRetorno 					= '00000';
LET desCodRetorno 					= 'OTP Enviado';
LET outNumTel		     			=  '';
LET inNumCliente			 		=  '';
LET outNumCliente			 		=  '';
LET codRetornoNotif			 		=  '';
LET plantillaSMS			 		=  'TOKEN_SMS';
LET contrato				 		=  'OFI_AVSMS';
LET inOTP					 		=  pvalue_otp;
LET inNombreWallet			 		=  pname;
LET outCorreo				 		=  '';
LET plantillaEMAIL		 			=  'TOKEN_MAIL';
LET contraroEMAIL		 			=  'OFI_ATC';

	BEGIN
		ON EXCEPTION SET isqlerr
			IF isqlerr <> 0 THEN		
				LET codigoRetorno = isqlerr;
				LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_deliverotp. Validar.';
			END IF;
			RETURN codigoRetorno, desCodRetorno;
		END EXCEPTION;
		
		--SET DEBUG FILE TO "/home/c90313380/sp_tokenizacion_deliverotp.out";
        --TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 10;
		
		LET inNumCliente = TRIM(pconsumer_id);
		
		-- Obtiene informaciÃ³n del cliente	
		SELECT cte.numcte, tel.telefono , cor.correo_elec
			INTO outNumCliente, outNumTel , outCorreo
		FROM bdinteg:"informix".si_cliente cte 
		INNER JOIN bdinteg:"informix".si_telefonos_actual tel
			ON tel.numcte = cte.numcte
		 INNER JOIN bdinteg:"informix".si_correos cor
			ON cor.numcte = cte.numcte
		WHERE cte.numcte = inNumCliente
			AND cor.tipo_correo = '1' 
			AND cor.status_correo = 'A'
			AND tel.tipo_tel = '2' 
			AND tel.status_tel = 'A';
			
		-- Valida cliente	
		IF outNumCliente IS NULL OR outNumCliente = '' THEN
			LET codigoRetorno = '00404';
			LET desCodRetorno =  'Cliente no existe';
			RETURN codigoRetorno, desCodRetorno;
		END IF	
			
		-- Envia OTP por SMS
		IF outNumTel IS NOT NULL AND outNumTel <> '' THEN
			CALL bdimnsj:"informix".sp_registra_evento('2', contrato, plantillaSMS , outNumCliente ,'','','1',inOTP ,'','','',inNombreWallet ,'','','','','','','',0,0,0,0,0,'','') RETURNING codRetornoNotif;	
							--let codRetornoNotif = "55555";
		END IF;
		
		-- Envia OTP por MAIL
		IF outCorreo IS NOT NULL AND outCorreo <> '' THEN
			CALL bdimnsj:"informix".sp_registra_evento('1',contraroEMAIL ,plantillaEMAIL ,outNumCliente ,'','','1',inOTP,'','','',inNombreWallet,'','','','','','','',0,0,0,0,0,CURRENT,'') RETURNING codRetornoNotif;
		                    --let codRetornoNotif = "55555";
		END IF;
		
		-- Valida codigo de retorno del llamado al evento
		IF 	codRetornoNotif <> '00000' THEN
			LET codigoRetorno = codRetornoNotif;
			LET desCodRetorno = 'OTP No Enviado';
		END IF;
		
		-- Guarda en bitacora
		INSERT INTO "informix".bitacora_tokenizacion_otp(consumer_id, issuer_id, x_correlation_id, value_otp, expiration_date, reason, delivery_channel, id_card_requestor, wallet_id, name, 
					tsp_id, original_digitalcard_requestorid, recommendation, digital_card_storagetype, phone_number, device_name, pan_suffix, cod_retorno, des_codret, fecha_insert)  	
		VALUES (outNumCliente, pissuer_id, px_correlation_id, pvalue_otp,pexpiration_date, preason, pdelivery_channel, id_card_requestor, pwallet_id, pname, 
					ptspi_id, poriginal_digitalcard_requestorid, precommendation, pdigital_card_storagetype, pphone_number, pdevice_name, ppan_suuffix, codigoRetorno, desCodRetorno, CURRENT);
		
		RETURN codigoRetorno, desCodRetorno;
		
	END;
END PROCEDURE
;