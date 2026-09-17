CREATE PROCEDURE "informix".sp_pago_appriza_web(pSucursal   		CHAR (4),
												pCategoria      	CHAR (2),
												pConvenio      		CHAR (5),
												pRefUno        		CHAR (20),
												pRefDos        		CHAR (20),
												pFormaPago     		CHAR (1),
												pMontoTotal    		DECIMAL (10,2),
												pImpComConv     	DECIMAL (6,2),
												pIvaComConv    		DECIMAL (6,2),
												pImpComCte     		DECIMAL (6,2),
												pIvaComCte     		DECIMAL (6,2),
												pCuentaCargo    	CHAR (12),
												pCuentaAbono    	CHAR (12),
												pNumEmp        		CHAR (8),
												pFolsuc        		CHAR (16),
												pTransSuc      		CHAR (4),
												pFechaPag      		DATE,
												pEmpresa     		CHAR (3),
												pNombre1 			CHAR (40),
												pNombre2 			CHAR (40),
												pApellidoPat		CHAR (40),
												pApellidoMat		CHAR (40),
												pFechaNac			CHAR (8),
												pFechaHoy 			CHAR (8),
												pMontoAPagar 		CHAR (20),
												pMoneda 			CHAR (3),
												pMontoMoneda		MONEY (14,2),
												pTranEquivCargo		CHAR (4),
												pTransSucRef    	CHAR (4),
												pCheque				INTEGER,
												pMontoTotalRef  	MONEY (14,2),
												pDivisa      		CHAR (2),
												pReferenciaCargo  	CHAR (40),
												pReferenciaAbono  	CHAR (40),
												pNumTarjeta 		CHAR (16),
												pUsuAutoriza		CHAR (8),
												pTranEquivAbono		CHAR (4),
												pDocto       		INTEGER,
												pMontoFirme   		MONEY (14,2),
												pMtoSBC     		MONEY (14,2),
												pMtoRem     		MONEY (14,2),
												pDiasRet			SMALLINT,
												pTelefonoCasa 		CHAR (10),
												pTelefonoCel		CHAR (10),
												pAdress				VARCHAR(80),
												pCity				VARCHAR(40),
												pStateCodeAdr		VARCHAR(3),
												pZipCode 			VARCHAR(10))

	RETURNING CHAR (5) AS RetCode, CHAR (2) AS IdentificadorProceso, CHAR (5) AS RetCode2, CHAR(5) AS TransaccInt, CHAR(5) AS TransServicio, CHAR(2) AS NumIntentos, CHAR(3) AS ApprizaCode, CHAR(3) AS ChannelId, CHAR(15) AS LocationUnit, CHAR(3) AS TypeCode, CHAR(3) AS StateCode, CHAR(3) AS CountryCode;

	-- Definicion de variables --
	DEFINE cCodErr 				 CHAR (5);
	DEFINE cIdentificadorProceso CHAR (2);
	DEFINE cRetCode2			 CHAR (5);
	DEFINE cFlagTelCel			 CHAR (1);
	DEFINE cFlagTelCasa			 CHAR (1);
	DEFINE cFlagTelOficina		 CHAR (1);
	DEFINE cCuenta				 CHAR(20);
	DEFINE cNoCte				 CHAR(20);
	DEFINE cApellPaterno		 CHAR(26);
	DEFINE cApellMaterno		 CHAR(26);
	DEFINE cNombre1				 CHAR(26);
	DEFINE cNombre2				 CHAR(26);
	DEFINE cRazonSocial		 	 CHAR(60);
	DEFINE cStatusCuenta	 	 CHAR(1);
	DEFINE mSdoDisponible	 	 MONEY(14,2);
	DEFINE mSdoRetenido		 	 MONEY(14,2);
	DEFINE mSdoCCC			 	 MONEY(14,2);
	DEFINE mSdoCCCDisp		 	 MONEY(14,2);
	DEFINE mSdoCuenta		 	 MONEY(14,2);
	DEFINE cTipoLinea		 	 CHAR(1);
	DEFINE cDescripcion1	 	 CHAR(40);
	DEFINE cDescripcion2	 	 CHAR(40);
	DEFINE mSaldoT1			 	 MONEY(14,2);
	DEFINE mSdoCongelado	 	 MONEY(14,2);
	DEFINE mSdoSBC			 	 MONEY(14,2);
	DEFINE cUsuarioBloqueo	 	 CHAR(8);
	DEFINE dFechaBloqueo	 	 DATE;
	DEFINE cCuentaClave		 	 CHAR(18);
	DEFINE dFechaExpTarjeta	 	 DATE;
	DEFINE cNoCuentaAbono		 CHAR(11);
	DEFINE cTranret			 	 CHAR(4);
	DEFINE dFechahoy			 DATE;
	DEFINE mSdodisp				 MONEY(14,2);
	DEFINE mMontoret			 MONEY(14,2);
	DEFINE cDescripcion			 CHAR(200);
	DEFINE iSqlErr               INTEGER;
	DEFINE cNoTarjeta			 CHAR(16);
	DEFINE dFecha			 	 DATETIME YEAR to SECOND;
	DEFINE cTransaccInt			 CHAR(5);
	DEFINE cTransServicio		 CHAR(5);
	DEFINE cNumIntentos			 CHAR(2);
	DEFINE cApprizaCode			 CHAR(3);
	DEFINE cChannelId		     CHAR(3);
	DEFINE cLocationUnit	     CHAR(15);
	DEFINE cTypeCode			 CHAR(3);
	DEFINE cStateCode		     CHAR(3);
	DEFINE cCountryCode	         CHAR(3);
	DEFINE cFechaHoy			 CHAR(8);
	DEFINE cFechaNac			 CHAR(8);
	DEFINE vtransaccion			 SMALLINT;
	DEFINE v_fecha_nac 			 DATE;
	DEFINE vCuenta				 INTEGER;
	DEFINE cCodErrAux			 CHAR(6);
	DEFINE cContador			   SMALLINT;
	
	DEFINE cMes CHAR(2);
	DEFINE cDia CHAR(2);
	DEFINE cAnio CHAR(4);
	DEFINE cValidaPLDteldom INTEGER;
	
	DEFINE cPaisOrigen          CHAR(3);
	DEFINE iCodPais             CHAR(3);
	DEFINE iValPais             INTEGER;		
	DEFINE cDesc_error        	CHAR(150);
	DEFINE cCadena_ent        	CHAR(100);
	DEFINE cHora		      	CHAR(6);
	DEFINE cCod_err2          	CHAR(5);
	
	--SET DEBUG FILE TO '/informix/RPT/sp_pago_appriza_web.out';
	--TRACE ON;


	-- Inicializacion de variables --
	LET cPaisOrigen              = '';        
	LET iCodPais                 = '';    
	LET iValPais                 = 0;
	LET cCodErr 				 = "00000";
	LET cIdentificadorProceso 	 = "00";
    LET cRetCode2 				 = "00000";
	LET cFlagTelCel				 = "0";
	LET cFlagTelCasa			 = "0";
	LET cFlagTelOficina			 = "0";
	LET cNoCuentaAbono			 = "";
	LET cDescripcion  			 = "";
	LET iSqlErr					 = 0;
	LET cNoTarjeta 				 = "";
	LET cNoCte					 = "";
	LET	cTransaccInt			 = "";
	LET	cTransServicio	         = "";
	LET	cNumIntentos		     = "";
	LET	cApprizaCode		     = "";
	LET	cChannelId		         = "";
	LET	cLocationUnit	         = "";
	LET	cTypeCode		         = "";
	LET	cStateCode		         = "";
	LET	cCountryCode		     = "";
	LET cFechaHoy				 = "";
	LET cFechaNac				 = "";
	LET vtransaccion			 = 0;
	LET cCodErrAux				 = "000000";
	LET cCadena_ent 	  		 = TRIM(NVL(pNumEmp,'NULL'))||"|" 
								||TRIM(NVL(pRefUno,'NULL'))||"|" 
								||TRIM(NVL(pFechaHoy,'NULL'));
	LET cHora		    		 = REPLACE(CURRENT::DATETIME HOUR TO SECOND, ':', '');
	LET cDesc_error 			 = '';
	LET cCod_err2         		 = '00000';
	LET dFecha 					 = CURRENT;

	-- Validar que ningun parametro obligatorio este vacio --
	LET pSucursal   	 = NVL(pSucursal, "");
	LET pCategoria       = NVL(pCategoria, "");
	LET pConvenio      	 = NVL(pConvenio, "");
	LET pRefUno        	 = NVL(pRefUno, "");
	LET pRefDos        	 = NVL(pRefDos, "");
	LET pFormaPago     	 = NVL(pFormaPago, "");
	LET pMontoTotal    	 = NVL(pMontoTotal, 0);
	LET pImpComConv      = NVL(pImpComConv, 0);
	LET pIvaComConv    	 = NVL(pIvaComConv, 0);
	LET pImpComCte     	 = NVL(pImpComCte, 0);
	LET pIvaComCte     	 = NVL(pIvaComCte, 0);
	LET pCuentaCargo     = NVL(pCuentaCargo, "");
	LET pCuentaAbono     = NVL(pCuentaAbono, "");
	LET pNumEmp        	 = NVL(pNumEmp, "");
	LET pFolsuc        	 = NVL(pFolsuc, "");
	LET pTransSuc      	 = NVL(pTransSuc, "");
	LET pFechaPag      	 = NVL(pFechaPag, "");
	LET pEmpresa     	 = NVL(pEmpresa, "");
	LET pTranEquivCargo	 = NVL(pTranEquivCargo, "");
	LET pTransSucRef     = NVL(pTransSucRef, "");
	LET pCheque			 = NVL(pCheque, 0);
	LET pMontoTotalRef   = NVL(pMontoTotalRef, 0);
	LET pDivisa      	 = NVL(pDivisa, "");
	LET pReferenciaCargo = NVL(pReferenciaCargo, "");
	LET pReferenciaAbono = NVL(pReferenciaAbono, "");
	LET pNumTarjeta 	 = NVL(pNumTarjeta, "");
	LET pUsuAutoriza	 = NVL(pUsuAutoriza, "");
	LET pTranEquivAbono	 = NVL(pTranEquivAbono, "");
	LET pDocto       	 = NVL(pDocto, 0);
	LET pMontoFirme   	 = NVL(pMontoFirme, 0);
	LET pMtoSBC     	 = NVL(pMtoSBC, 0);
	LET pMtoRem     	 = NVL(pMtoRem, 0);
	LET pDiasRet		 = NVL(pDiasRet, 0);
	LET pNombre1 		 = NVL(pNombre1, "");
	LET pNombre2 		 = NVL(pNombre2, "");
	LET pApellidoPat	 = NVL(pApellidoPat, "");
	LET pApellidoMat	 = NVL(pApellidoMat, "");
	LET pFechaNac		 = NVL(pFechaNac, "");
	LET pFechaHoy 		 = NVL(pFechaHoy, "");
	LET pMontoAPagar 	 = NVL(pMontoAPagar, "");
	LET pMoneda 		 = NVL(pMoneda, "");
	LET pMontoMoneda	 = NVL(pMontoMoneda, 0);
	LET pTelefonoCasa 	 = NVL(pTelefonoCasa, "");
	LET pTelefonoCel 	 = NVL(pTelefonoCel, "");
	LET pAdress			 = NVL(pAdress, "");
	LET pCity			 = NVL(pCity, "");
	LET pStateCodeAdr	 = NVL(pStateCodeAdr, "");
	LET pZipCode 		 = NVL(pZipCode, "");
	
	LET cDia = '';
    LET cMes = '';
    LET cAnio = '';
	LET cValidaPLDteldom = 0;

	--SET DEBUG FILE TO "/informix/RPT/sp_pago_appriza_web.out";
    --TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION SET iSqlErr
		IF iSqlErr <> 0 THEN
			LET cCodErr = iSqlErr;
			LET cDesc_error = 'Error no controlado';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
			RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
		END IF;
	END EXCEPTION;

	on exception in (-535)
        let vtransaccion = 1;
    end exception with resume;
	if vtransaccion = 1 then
		COMMIT WORK;
		BEGIN WORK;
	else
		BEGIN WORK;
	end if;

	--Validacion Paises Permitidos
	SELECT LIMIT 1 r_countrycode INTO cPaisOrigen FROM sac_app_qryi WHERE fecha >= today AND txn_status = 'A' AND r_countrycode <> '' AND r_code = '0000' AND unirefnum = pRefUno; 
		
	IF cPaisOrigen = '' OR cPaisOrigen IS NULL THEN
		LET cCodErr = "00001";
		LET cIdentificadorProceso = "12";
		LET cRetCode2 = "00222";
		LET cDesc_error = 'No cuenta con registros en la sac_app_qryi';
		
		INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
		VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
		
		RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
	END IF;
	
	SELECT pais INTO iCodPais FROM sac_paises_permitidos WHERE appbts = cPaisOrigen;
	
	SELECT COUNT(*) INTO iValPais FROM bdinteg:si_paises_remesadoras WHERE id_remesadora = '1' AND id_pais = iCodPais;
	
	IF iValPais = 0 THEN
	
				LET cCodErr = "00001";
				LET cIdentificadorProceso = "10";
				LET cRetCode2 = "00222";
				LET cDesc_error = 'Pais restringido';
			
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
			
				RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
			
	END IF;

	--Se valida que ninguna variable de entrada este vacia
	IF pSucursal = "" OR pCategoria = "" OR pConvenio = "" OR pRefUno = "" OR pFormaPago = "" OR pMontoTotal = 0 OR pCuentaCargo = "" OR (pFormaPago <> "1" AND (pNumTarjeta = "" AND pCuentaAbono = "")) OR pNumEmp = "" OR pFolsuc = "" OR pTransSuc = "" OR pFechaPag = "" OR pEmpresa = "" OR pTranEquivCargo = "" OR (pFormaPago <> "1" AND pTranEquivAbono = "") OR pMontoTotalRef = 0 OR pDivisa = "" OR (pFormaPago <> "1" AND pReferenciaAbono = "") OR pReferenciaCargo = "" OR (pFormaPago <> "1" AND pDocto = 0) OR pMontoFirme = 0 OR pNombre1 = "" OR pApellidoPat = "" OR pFechaNac = "" OR pFechaHoy = "" OR pMontoAPagar = "" OR pMoneda = "" OR pMontoMoneda = 0 OR pTelefonoCasa = "" THEN
			LET cCodErr = "00001";
	ELSE
		--Se validan los numeros de telefono
		CALL bdinteg:"informix".sp_validatelefono(pEmpresa, pTelefonoCasa, pTelefonoCel, "")
		RETURNING cRetCode2, cFlagTelCasa, cFlagTelCel, cFlagTelOficina;
		--IF cRetCode2 <> "000" THEN
		IF cFlagTelCasa <> "1" THEN
			LET cRetCode2 = "00001";
			LET cIdentificadorProceso = "08";
			LET cDesc_error = 'Telefono de casa no valido';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
		ELIF cFlagTelCel <> "1" and pTelefonoCel <> "" THEN
			LET cRetCode2 = "00002";
			LET cIdentificadorProceso = "08";
			LET cDesc_error = 'Telefono movil no valido';
			INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
			VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
		ELSE
			--Validacion solicitada por PLD para limites de Direcciones y Telefonos ingresados en el cobro de remesas sp_sac_pldlim_teldom
			
			LET cDia = LPAD(SUBSTRING(pFechaHoy FROM 7 FOR 2), 2, '0');
			LET cMEs = LPAD(SUBSTRING(pFechaHoy FROM 5 FOR 2), 2, '0');
			LET cAnio = LPAD(SUBSTRING(pFechaHoy FROM 1 FOR 4), 4, '0');	
			

			EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'NORMAL') INTO cRetCode2;
							
			IF cRetCode2 <> '00000' THEN
				--MENSAJE EN CAJA "Remesa excede limite, 1245" REMESA EXCEDE LIMITE DE DOMICILIO O TELEFONO PLD
				--LET cRetCode2 = "00169";
				LET cRetCode2 = "01245";
				LET cIdentificadorProceso = "02";
				LET cCodErrAux = '999999';
				LET cDesc_error = 'Error en sp_sac_pldlim_teldom';
				INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
				VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
			ELSE
			
				--Llamado para obtener parametros para el servicio de pago
				CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal, "2") RETURNING cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
		
				LET cTransServicio = NVL(cTransServicio, "");
		
				IF cTransServicio <> "20068" THEN
					LET cIdentificadorProceso = "06";
					LET cDesc_error = 'Error en sp_consultasucursalAppriza';
					INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
					VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
				ELSE
					--Verificar si existe el registro en la tabla sac_movimientos
					SELECT COUNT(*)
					INTO cContador
					FROM bdisac:"informix".sac_movimientos
					WHERE id_sucursal = pSucursal 
					AND numcategoria = pCategoria 
					AND numconvenio = pConvenio
					AND referencia1 = pRefUno 
					AND referencia2 = pRefDos 
					--AND folio_suc = pFolsuc
					AND status_cancelado = 'N';
					
					IF cContador > 0 THEN
						LET cCodErr = '00000';
						LET cRetCode2 = "00138";		
						LET cIdentificadorProceso = "03";
						LET cDesc_error = 'Error en sp_consultasucursalAppriza';

					END IF;
					
					IF cContador = 0 THEN
					
						--cValidaPLDteldom es un flag qe comprueba si se ejecuto sp_sac_pldlim_teldom en caso de reversion de la operacion
						LET cValidaPLDteldom = 1;
						--Se validan los montos
						--LET pFechaHoy = pFechaHoy;
						LET pFechaHoy = SUBSTRING(pFechaHoy FROM 5 FOR 2)||SUBSTRING(pFechaHoy FROM 7 FOR 2)||SUBSTRING(pFechaHoy FROM 1 FOR 4);
						CALL bdisac:"informix".sp_app_valmonto(pEmpresa, pNombre1, pNombre2, pApellidoPat, pApellidoMat, pFechaNac, pFechaHoy, pMontoAPagar, pSucursal, pMoneda, pMontoMoneda, pRefUno)
						RETURNING cCodErrAux;
			
						IF cCodErrAux <> "00000" THEN
							LET cRetCode2 = SUBSTRING(cCodErrAux FROM 2 FOR 5);
						ELSE
							LET cRetCode2 = cCodErrAux;
						END IF;
			
						IF cRetCode2 <> "00000" THEN
							LET cIdentificadorProceso = "02";
							LET cDesc_error = 'Error en sp_app_valmonto';
							INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
							VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
						ELSE
							CALL bdisac:"informix".sp_grabapagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFormaPago, pMontoTotal, pImpComConv, pIvaComConv, pImpComCte, pIvaComCte, pCuentaAbono, pNumEmp, pFolsuc, pTransSuc, pFechaPag)
							RETURNING cRetCode2;
			
							if vtransaccion = 1 then
								COMMIT WORK;
								BEGIN WORK;
							else
								BEGIN WORK;
							end if;
			
							IF cRetCode2 <> "00000" THEN
								LET cIdentificadorProceso = "03";
								LET cDesc_error = 'Error en sp_grabapagoservicio';
								INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
								VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
							ELSE
								LET v_fecha_nac = MDY(SUBSTRING(pFechaNac FROM 5 FOR 2), SUBSTRING(pFechaNac FROM 7 FOR 2), SUBSTRING(pFechaNac FROM 1 FOR 4));
								--Llamado a sp para actualizar datos
								CALL bdisac:"informix".sp_actualizaremesa(pCategoria, pConvenio, pRefUno, pNombre1, pNombre2, pApellidoPat, pApellidoMat, v_fecha_nac, pMoneda, pMontoMoneda)
								RETURNING cRetCode2, vCuenta;
			
								IF cRetCode2 <> "00000" THEN
									LET cIdentificadorProceso = "09";
									LET cDesc_error = 'Error en sp_actualizaremesa';
									INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
									VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
								ELSE
									--Llamado a sp cargo_ref para aplicar el cargo
									CALL bdicheq:"informix".cargo_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivCargo, pTransSucRef, pFolsuc, pCuentaCargo, pCheque, pMontoTotalRef, pDivisa, pReferenciaCargo, pNumTarjeta, pUsuAutoriza)
									RETURNING cRetCode2, cTranret, dFechahoy, mSdodisp, mMontoret;
			
									IF cRetCode2 <> "000" THEN
										LET cIdentificadorProceso = "07";
										LET cDesc_error = 'Error en cargo_ref';
										INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
										VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
									ELSE
										--Se valida que la forma de pago fue en efectivo para evitar el llamado a el sp abono_ref
										IF pFormaPago <> "1" THEN
											--Llamado a sp abono_ref para el cargo a la cuenta
											CALL bdicheq:"informix".abono_ref(pEmpresa, pSucursal, pNumEmp, pTranEquivAbono, pTransSucRef, pFolsuc, pCuentaAbono, pDocto, pMontoTotalRef, pMontoFirme, pMtoSBC, pMtoRem, pDiasRet, pDivisa, pReferenciaAbono, pNumTarjeta, pUsuAutoriza)
											RETURNING cRetCode2;
										END IF;
										IF cRetCode2 <> "000" THEN
											LET cIdentificadorProceso = "05";
											LET cDesc_error = 'Error en abono_ref';
											INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
											VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
										ELSE
											CALL bdisac:"informix".sp_confpagoservicio(pSucursal, pCategoria, pConvenio, pRefUno, pRefDos, pFolsuc)
											RETURNING cRetCode2, cDescripcion;
			
											IF cRetCode2 <> "00000" THEN
												LET cIdentificadorProceso = "04";
												LET cDesc_error = 'Error en sp_confpagoservicio';
												INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
												VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
											ELSE
												--Llamado para obtener parametros para el servicio de pago
												CALL bdisac:"informix".sp_consultasucursalAppriza(pSucursal, "2")
												RETURNING cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
												LET cTransServicio = NVL(cTransServicio, "");
												IF cTransServicio <> "20068" THEN
													LET cIdentificadorProceso = "06";
													LET cDesc_error = 'Error en sp_consultasucursalAppriza';
													INSERT INTO bdisac:"informix".sac_bitacora_errores_remesas(marca, tipo_proceso, referencia, fecha_insert, ccoderr, retcode2, identificadorproceso, descripcion_error, sucursal, user_insert)
													VALUES('APP', 'Payi', pRefUno, dFecha, cCodErr, cRetCode2, cIdentificadorProceso, cDesc_error, pSucursal, pNumEmp);
												END IF;
											END IF;
										END IF;
									END IF;
								END IF;
							END IF;
						END IF;
					END IF;				END IF; --if consulta parametros sp_consultasucursalAppriza
			END IF;
		END IF;
	END IF;
	
	
	IF cIdentificadorProceso != '00' THEN
		IF cCodErrAux != '999999' THEN 
			IF cValidaPLDteldom = 1 THEN
				EXECUTE PROCEDURE bdisac:"informix".sp_sac_pldlim_teldom('APP',pAdress,pCity,pStateCodeAdr,pZipCode,cAnio||cMEs,pNumEmp,pTelefonoCasa,pTelefonoCel,pFolsuc,pSucursal,pRefUno,'REVERSO') INTO cCodErrAux;
			END IF;	
		END IF;
	END IF;

	RETURN cCodErr, cIdentificadorProceso, cRetCode2, cTransaccInt, cTransServicio, cNumIntentos, cApprizaCode, cChannelId, cLocationUnit, cTypeCode, cStateCode, cCountryCode;
END
END PROCEDURE;