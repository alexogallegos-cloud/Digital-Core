CREATE PROCEDURE  "informix".sp_guardarespuestabts(
        pUsuario CHAR(8),
        pIdFuncion CHAR(10),
        pSucursal CHAR (4),
        pTxn_Status CHAR(1),
        pConfirmation_nm CHAR (11),
        pUser_name CHAR (20),
        pTerminal CHAR(15),
        pAgent_Dt CHAR(8),
        pAgent_Tm CHAR(6),
        pOpCode CHAR(4),
        pProcess_Msg CHAR(255),
        pError_Param_Full_Name CHAR(255),
        pTrans_Status_Cd CHAR(3),
        pTrans_Status_Dt CHAR(8),
        pProcess_Dt CHAR(8),
        pProcess_Tm CHAR(6),
        pService_Cd CHAR(3),
        pPayment_Type_Cd CHAR(3),
        pOrig_Country_Cd CHAR(3),
        pOrig_Currency_Cd CHAR(3),
        pDest_Country_Cd CHAR(3),
        pDest_Currency_Cd CHAR(3),
        pOrigin_Am CHAR(20),
        pDestination_Am CHAR(20),
        pExch_Rate_Fx CHAR(21),
        pS_Agent_Cd CHAR(3),
        pS_Payment_Type_Cd CHAR(3),
        pS_Account_Type_Cd CHAR(3),
        pS_Account_Nm CHAR(30),
        pS_Bank_Cd CHAR(30),
        pS_Bank_Ref_Nm CHAR(20),
        pR_Account_Type_Cd CHAR(3),
        pR_Account_Nm CHAR(30),
        pR_Agent_Cd CHAR(3),
        pR_Agent_Region_Sd CHAR(15),
        pR_Agent_Branch_Sd CHAR(15),
        pS_First_Name CHAR(40),
        pS_Middle_Name CHAR(40),
        pS_Last_Name CHAR(40),
        pS_Mother_M_Name CHAR(40),
        pS_Address CHAR(80),
        pS_City CHAR(40),
        pS_State_Cd CHAR(3),
        pS_Country_Cd CHAR(3),
        pS_Zip_Code CHAR(10),
        pS_Phone CHAR(15),
        pR_First_Name CHAR(40),
        pR_Middle_Name CHAR(40),
        pR_Last_Name CHAR(40),
        pR_Mother_M_Name CHAR(40),
        pR_Identif_Type_Cd CHAR(3),
        pR_Identif_Nm CHAR(20),
        pF_First_Name CHAR(40),
        pF_Middle_Name CHAR(40),
        pF_Last_Name CHAR(40),
        pF_Mother_M_Name CHAR(40),
        pR_Address CHAR(80),
        pR_City CHAR(40),
        pR_State_Cd CHAR(3),
        pR_Country_Cd CHAR(3),
        pR_Zip_Code CHAR(10),
        pR_Phone CHAR(15),
        pR_Type_Cd CHAR(3),
        pR_Issuer_Cd CHAR(3),
        pR_Issuer_State_Cd CHAR(3),
        pR_Issuer_Country_Cd CHAR(3),
        pRi_Identif_Nm CHAR(20),
        pR_Expiration_Dt CHAR(8),
        pS_Type_Cd CHAR(3),
        pS_Issuer_Cd CHAR(3),
        pS_Issuer_State_Cd CHAR(3),
        pS_Issuer_Country_Cd CHAR(3),
        pS_Identif_Nm CHAR(20),
        pS_Expiration_Dt CHAR(8))

    RETURNING
    CHAR(5) AS cCodRet;   -- Codigo de Retorno

         --DEFINICION DE VARIABLES--
        DEFINE iSqlErr                            INT;
        DEFINE cCodRetSp                          CHAR(50);
    DEFINE sql_err                INT;
    DEFINE cCodRet                CHAR(5);
        DEFINE cAgent_Trans_Type_Code CHAR(4);
        DEFINE cAgent_Cd              CHAR(3);
        DEFINE cRegion_Sd             CHAR(15);
        DEFINE cBranch_Sd             CHAR(15);
        DEFINE cState_Cd              CHAR(3);
        DEFINE cCountry_Cd            CHAR(3);
    DEFINE cStatus                CHAR(1);

        --INICIALIZACION DE VARIABLES--
        LET iSqlErr                                = 0;
        LET cCodRetSp                      = '';
    LET sql_err                = 0;
    LET cCodRet                = '00000';
        LET cAgent_Trans_Type_Code = 'QRYI';
        LET cAgent_Cd              = '';
        LET cRegion_Sd             = '';
        LET cBranch_Sd             = '';
        LET cState_Cd              = '';
        LET cCountry_Cd            = '';
        LET cStatus = '';


        BEGIN
                ON EXCEPTION SET iSqlErr
                        IF iSqlErr <> 0 THEN
                                LET cCodret = iSqlErr;
                                RETURN cCodret;
                        END IF;
                END EXCEPTION;

                --SET DEBUG FILE TO '/tmp/mfinis/sp_guardarespuestabts.out';
                --TRACE ON;

                IF      pIdFuncion = '' OR pSucursal =  ''  OR  pTxn_Status = '' OR  pConfirmation_nm =  '' OR pUser_name =  '' OR pTerminal = '' OR pAgent_Dt = '' OR
                        pAgent_Tm = '' OR pUsuario = '' THEN
                        LET cCodRet = '00003';
                        RETURN cCodRet;
                END IF;

                --Validación del usuario.
                EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
                IF cCodRet <> '00000' THEN
                        RETURN cCodRet;
                END IF;

                SET ISOLATION TO DIRTY READ;
                EXECUTE PROCEDURE bdisac:sp_guardarespuestaqryi(pSucursal,pTxn_Status, pConfirmation_nm, pUser_name, pTerminal,pAgent_Dt, pAgent_Tm, pOpCode, pProcess_Msg,
                        pError_Param_Full_Name, pTrans_Status_Cd, pTrans_Status_Dt,     pProcess_Dt,
                        pProcess_Tm, pService_Cd, pPayment_Type_Cd, pOrig_Country_Cd, pOrig_Currency_Cd, pDest_Country_Cd, pDest_Currency_Cd, pOrigin_Am, pDestination_Am, pExch_Rate_Fx,
                        pS_Agent_Cd, pS_Payment_Type_Cd, pS_Account_Type_Cd, pS_Account_Nm, pS_Bank_Cd, pS_Bank_Ref_Nm, pR_Account_Type_Cd, pR_Account_Nm, pR_Agent_Cd, pR_Agent_Region_Sd,
                        pR_Agent_Branch_Sd, pS_First_Name, pS_Middle_Name,      pS_Last_Name, pS_Mother_M_Name, pS_Address, pS_City, pS_State_Cd, pS_Country_Cd, pS_Zip_Code, pS_Phone,
						pR_First_Name,
                        pR_Middle_Name, pR_Last_Name, pR_Mother_M_Name, pR_Identif_Type_Cd, pR_Identif_Nm, pF_First_Name, pF_Middle_Name, pF_Last_Name, pF_Mother_M_Name, pR_Address, pR_City,
                        pR_State_Cd, pR_Country_Cd, pR_Zip_Code, pR_Phone, pR_Type_Cd, pR_Issuer_Cd, pR_Issuer_State_Cd, pR_Issuer_Country_Cd, pRi_Identif_Nm, pR_Expiration_Dt, pS_Type_Cd,
                        pS_Issuer_Cd, pS_Issuer_State_Cd, pS_Issuer_Country_Cd, pS_Identif_Nm, pS_Expiration_Dt, pUsuario) INTO cCodRetSp;

						IF cCodRetSp = '00000' THEN
							RETURN cCodRet;
						ELIF cCodRetSp = '00756' THEN
							LET cCodRet = '00245';
							RETURN cCodRet;
						ELSE
							LET cCodRet = cCodRetSp;
							RETURN cCodRet;
						END IF;

        END;
END PROCEDURE
DOCUMENT' AUTOR: Esparza Brenis Fernando Martín',
'DESCRIPCION: Se crea SP para guardar los datos de envio y recepción del mensaje QRYI de BTS',
'FECHA: 12/02/2014',
'DESCRIPCION: bdicnweb';

CREATE PROCEDURE "informix".sp_consrempagbts(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumConfirmacion CHAR(11), pFecha DATE)
	RETURNING CHAR(5) AS codret,
			CHAR(15) AS sucursal, 
			CHAR(15) AS terminal,
			CHAR(3) AS typecd,
			CHAR(20) AS identificacionnm,
			CHAR(50) AS nombrecalle,
			CHAR(5) AS numexterior,
			CHAR(5) AS numinterior,
			CHAR(10) AS departamento,
			CHAR(80) AS colonia,
			CHAR(5) AS codigopostal,
			CHAR(50) AS municipiodelegacion,
			CHAR(50) AS ciudad,
			CHAR(50) AS estado,
			CHAR(3) AS issuercountrycd,
			CHAR(15) AS telefono,
			CHAR(1) AS tipopago,
			DATE AS fechanacimiento,
			CHAR(20) AS nacionalidad,
			CHAR(50) AS paisnacimiento,
			CHAR(20) AS foliosucpayi;
			
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	-- VARIABLES DEL SP
	DEFINE cCodRetSp CHAR(5);
	DEFINE cSucursal CHAR(15); 
	DEFINE cTerminal CHAR(15); 
	DEFINE cRTypeCd CHAR(3);
	DEFINE cRIdentificacionNm CHAR(20); 
	DEFINE cRNombreCalle CHAR(50);
	DEFINE cRNumExterior CHAR(5);
	DEFINE cRNumInterior CHAR(5);
	DEFINE cRDepartamento CHAR(10);
	DEFINE cRColonia CHAR(80);
	DEFINE cRCodigoPostal CHAR(5);
	DEFINE cRMunicipioDelegacion CHAR(50);
	DEFINE cRCiudad CHAR(50);
	DEFINE cREstado CHAR(50);
	DEFINE cRIssuerCountryCd CHAR(3);
	DEFINE cRTelefono CHAR(15);
	DEFINE cTipoPago CHAR(1);
	DEFINE cRFechaNacimiento CHAR(8);
	DEFINE dRFechaNacimiento DATE; 
	DEFINE cRNacionalidad CHAR(20);
	DEFINE cRPaisNacimiento CHAR(50);
	DEFINE cFolioSucPayi CHAR(20);	 
	DEFINE iCodRetorno INTEGER;
		 

	LET cCodRet = '00000';
	LET iSqlErr = 0;	
	-- VARIABLES DEL SP
	LET cCodRetSp = '';
	LET cSucursal = ''; 
	LET cTerminal = ''; 
	LET cRTypeCd = '';
	LET cRIdentificacionNm = ''; 
	LET cRNombreCalle = '';
	LET cRNumExterior = '';
	LET cRNumInterior = '';
	LET cRDepartamento = '';
	LET cRColonia = '';
	LET cRCodigoPostal = '';
	LET cRMunicipioDelegacion = '';
	LET cRCiudad = '';
	LET cREstado = '';
	LET cRIssuerCountryCd = '';
	LET cRTelefono = '';
	LET cTipoPago = '';
	LET cRFechaNacimiento = '';
	LET dRFechaNacimiento = NULL; 
	LET cRNacionalidad = '';
	LET cRPaisNacimiento = '';
	LET cFolioSucPayi = '';	 	
	LET iCodRetorno = 0;

	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cSucursal, cTerminal, cRTypeCd, cRIdentificacionNm, cRNombreCalle, cRNumExterior, 
				cRNumInterior, cRDepartamento, cRColonia, cRCodigoPostal, cRMunicipioDelegacion, cRCiudad, cREstado, 
				cRIssuerCountryCd, cRTelefono, cTipoPago, dRFechaNacimiento, cRNacionalidad, cRPaisNacimiento, cFolioSucPayi;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consrempagbts.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pNumConfirmacion = '' OR pFecha IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cSucursal, cTerminal, cRTypeCd, cRIdentificacionNm, cRNombreCalle, cRNumExterior, 
				cRNumInterior, cRDepartamento, cRColonia, cRCodigoPostal, cRMunicipioDelegacion, cRCiudad, cREstado, 
				cRIssuerCountryCd, cRTelefono, cTipoPago, dRFechaNacimiento, cRNacionalidad, cRPaisNacimiento, cFolioSucPayi;
		END IF;
		
		-- VALIDACION DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cSucursal, cTerminal, cRTypeCd, cRIdentificacionNm, cRNombreCalle, cRNumExterior, 
				cRNumInterior, cRDepartamento, cRColonia, cRCodigoPostal, cRMunicipioDelegacion, cRCiudad, cREstado, 
				cRIssuerCountryCd, cRTelefono, cTipoPago, dRFechaNacimiento, cRNacionalidad, cRPaisNacimiento, cFolioSucPayi;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		EXECUTE PROCEDURE bdisac:"informix".sp_consrempag(pNumConfirmacion, pFecha)
			INTO cCodRetSp, cSucursal, cTerminal, cRTypeCd, cRIdentificacionNm, cRNombreCalle, cRNumExterior, 
				cRNumInterior, cRDepartamento, cRColonia, cRCodigoPostal, cRMunicipioDelegacion, cRCiudad, cREstado, 
				cRIssuerCountryCd, cRTelefono, cTipoPago, cRFechaNacimiento, cRNacionalidad, cRPaisNacimiento, cFolioSucPayi;
		
		LET iCodRetorno = cCodRetSp::INTEGER;
		IF iCodRetorno < 0 THEN
			RAISE EXCEPTION iCodRetorno, 0, 'ERROR EN LA EJECUCION DEL SP bdisac:sp_consrempag';
		ELIF iCodRetorno = 1 THEN
			LET cCodRet = '00003';
		ELIF iCodRetorno = 2 THEN -- NO SE ENCONTRARON DATOS ADICIONALES DEL BENEFICIARIO
			LET cCodRet = '00244';
		ELIF iCodRetorno = 3 THEN -- NO SE ENCONTRARON DATOS ADICIONALES DEL BENEFICIARIO
			LET cCodRet = '00244';
		ELIF iCodRetorno = 4 THEN -- NO SE ENCONTRARON DATOS ADICIONALES DEL BENEFICIARIO
			LET cCodRet = '00244';
		ELIF iCodRetorno = 0 THEN -- NO SE ENCONTRARON DATOS ADICIONALES DEL BENEFICIARIO
			IF cRFechaNacimiento <> '' THEN
				LET dRFechaNacimiento = TRIM(SUBSTRING(cRFechaNacimiento FROM 5 FOR 2)||'/'||SUBSTRING(cRFechaNacimiento FROM 7 FOR 2)||'/'||SUBSTRING(cRFechaNacimiento FROM 1 FOR 4));
			END IF;
		END IF;
		
		RETURN cCodRet, cSucursal, cTerminal, cRTypeCd, cRIdentificacionNm, cRNombreCalle, cRNumExterior, 
				cRNumInterior, cRDepartamento, cRColonia, cRCodigoPostal, cRMunicipioDelegacion, cRCiudad, cREstado, 
				cRIssuerCountryCd, cRTelefono, cTipoPago, dRFechaNacimiento, cRNacionalidad, cRPaisNacimiento, cFolioSucPayi;
		
	END;
	
END PROCEDURE
DOCUMENT 'AUTOR: Oscar Flores Conde',
'FECHA: 12/02/2014',
'DESCRIPCION: Obtiene informacion del registro de una remesa pagada cuando se consulta desde plataforma',
'BD: bdicnweb',
'FECHA: 27/03/2014',
'DESCRIPCION: ModificaciÃ³n que revisa si la remesa estÃ¡ en la bitÃ¡cora de pagos BTS, se muestren los datos',
'BD: bdicnweb';

CREATE PROCEDURE "informix".sp_blqconcentractasinactivasexcluidas(cID_USUARIOC CHAR(8),
                                                     		  cID_FUNCIONC CHAR(10),
                                                     		  cNUMCUENTA CHAR(20),
								  cOPERACION CHAR(1))
       RETURNING CHAR(5) AS codRet,
		 DECIMAL(18,2) AS SdoDispCuenta;
--
DEFINE cCodRet 			CHAR(5);
DEFINE iSql_err 		INT;

DEFINE dFecha			DATE;
DEFINE cEmpresa			CHAR(3);
DEFINE vStatusCta           	CHAR(1);
DEFINE cCuenta              	CHAR(20);
DEFINE cResultado           	CHAR(1);
DEFINE iExiste           	INTEGER;

DEFINE vSdoActual           	DECIMAL(18,2);
DEFINE vSdoRetenido         	DECIMAL(18,2);
DEFINE vSdoCongelado        	DECIMAL(18,2);
DEFINE vSdoSobregirado      	DECIMAL(18,2);

DEFINE vSdoConcentrado      	DECIMAL(18,2);
DEFINE vIntSdoConcentrado      	DECIMAL(18,2);

DEFINE vSdoDispCuenta       	DECIMAL(18,2);

--inicializando variables
LET cCodRet 		= "00000";
LET iSql_err 		= 0 ;

LET dFecha		= '';
LET cEmpresa		= '001';
LET vStatusCta		= '';
LET cCuenta		= '';
LET cResultado		= '';
LET iExiste		= 0;

LET vSdoActual          = 0;
LET vSdoRetenido        = 0;
LET vSdoCongelado       = 0;
LET vSdoSobregirado     = 0;

LET vSdoConcentrado     = 0;
LET vIntSdoConcentrado  = 0;

LET vSdoDispCuenta      = 0;

SET ISOLATION TO DIRTY READ;

BEGIN
	ON EXCEPTION SET iSql_err
		IF iSql_err <> 0 THEN
			LET cCodRet = iSql_err;
			RETURN cCodRet, vSdoDispCuenta;
		END IF;
	END EXCEPTION;
	
	
	IF 	cID_USUARIOC = '' 	OR
		cID_FUNCIONC = '' 	OR
		cOPERACION = '' 	OR
		cNUMCUENTA  = ''	THEN
		LET cCodRet = "00036";
		RETURN cCodRet, vSdoDispCuenta;
	ELSE
		IF cOPERACION = '1'
		OR cOPERACION = '0' THEN
			LET cCodRet = "00000";
		ELSE
			LET cCodRet = "00049";
			RETURN cCodRet, vSdoDispCuenta;
		END IF;
	END IF;

        -- VALIDACION DE ACCESO A LA FUNCIONALIDAD
        EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(cID_USUARIOC,
                                                                       cID_FUNCIONC)
                INTO cCodRet;
        IF cCodRet <> '00000' THEN
                RETURN cCodRet, vSdoDispCuenta;
        END IF;
--
    -- // OBTINENE LA FECHA DE HOY
	SELECT fecha_hoy
	INTO dFecha
	FROM bdicheq:"informix".sc_fechas
	WHERE empresa = cEmpresa;
--
	IF cOPERACION = 1 THEN
--
        	-- VALIDA LA CUENTA EN sc_cuenta_concentradas
        	SELECT COUNT(*)
            INTO iExiste
        	FROM bdicheq:sc_ctasinactinfor3anios3meses cc
        	WHERE cc.cuenta = cNUMCUENTA
          	AND cc.status_cta = '5';
		IF iExiste = 0 THEN
	   		LET cCodRet = "00143";
			RETURN cCodRet, vSdoDispCuenta;
		ELSE
        		LET cCuenta = "";
        		SELECT cc.cuenta, 0, sdo_actual, sdo_actual
        		INTO cCuenta, cResultado, vSdoConcentrado, vIntSdoConcentrado
        		FROM bdicheq:"informix".sc_ctasinactinfor3anios3meses cc
        		WHERE cc.cuenta = cNUMCUENTA
          		AND cc.status_cta = '5';
        	IF NVL(cCuenta,"") = "" THEN
				LET vSdoDispCuenta = 0;
	   			LET cCodRet = "00000";
			ELSE
				LET vSdoDispCuenta = vSdoConcentrado;   -- + vIntSdoConcentrado;
				IF cResultado = '1' THEN
	   				LET cCodRet = "00145";
					RETURN cCodRet, vSdoDispCuenta;
				END IF;
			END IF;
		END IF;
		-- Si se va a insertar entonces se busca primero en la tabla de cuentas concentradas excluidas
		select count(*)
		into iExiste
		from bdicnweb:"informix".sc_cuentas_concentradas_excluidas
		where cuenta = cNUMCUENTA;

		if iExiste = 1 then  -- Si la cuenta ya existe, es decir, ya se había exlcuido antes, entonces regresamos un cod de retorno
			LET cCodRet = "00144";
			RETURN cCodRet, vSdoDispCuenta;
		end if;

		-- Si no existe, entonces insertamos el registro en la tabla
		INSERT INTO bdicnweb:"informix".sc_cuentas_concentradas_excluidas
			(usuario, num_archivo, cuenta, fecha_concentra)
		VALUES
			(cID_USUARIOC, 0, cNUMCUENTA, dFecha);

		RETURN cCodRet, vSdoDispCuenta;

	ELIF cOPERACION = 0 THEN -- Se quitara el registro de la taba sc_cuentas_concentradas excluidas

		select count(*)
		into iExiste
		from bdicnweb:"informix".sc_cuentas_concentradas_excluidas
		where cuenta = cNUMCUENTA;

		if iExiste = 0 then -- La cuenta no existe en la tabnla de sc_cuentas_concentradas_excluidas
			LET cCodRet = "00146";
			RETURN cCodRet, vSdoDispCuenta;
		end if;

		DELETE FROM bdicnweb:"informix".sc_cuentas_concentradas_excluidas
        	WHERE cuenta = cNUMCUENTA;
--
        	-- VALIDA LA CUENTA EN sc_cuenta_concentradas
        	SELECT COUNT(*)
            INTO iExiste
        	FROM bdicheq:sc_ctasinactinfor3anios3meses cc
        	WHERE cc.cuenta = cNUMCUENTA
          	AND cc.status_cta = '5';
		IF iExiste = 0 THEN
			LET vSdoDispCuenta = 0;
	   		LET cCodRet = "00000";
		ELSE
        		LET cCuenta = "";
        		SELECT cc.cuenta, 0, sdo_actual, sdo_actual
        		INTO cCuenta, cResultado, vSdoConcentrado, vIntSdoConcentrado
        		FROM bdicheq:"informix".sc_ctasinactinfor3anios3meses cc
        		WHERE cc.cuenta = cNUMCUENTA
          		AND cc.status_cta = '5';
        	IF NVL(cCuenta,"") = "" THEN
				LET vSdoDispCuenta = 0;
	   			LET cCodRet = "00000";
			ELSE
				LET vSdoDispCuenta = vSdoConcentrado;   -- + vIntSdoConcentrado;
			END IF;
		END IF;
	END IF;

	RETURN cCodRet, vSdoDispCuenta;
END;
END PROCEDURE;