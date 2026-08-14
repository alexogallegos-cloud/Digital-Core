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