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