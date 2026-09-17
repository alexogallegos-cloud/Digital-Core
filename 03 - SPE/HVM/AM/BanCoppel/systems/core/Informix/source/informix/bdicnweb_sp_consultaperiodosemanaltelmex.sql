CREATE PROCEDURE "informix".sp_consultaperiodosemanaltelmex(pUsuario CHAR(8), pIdFuncion CHAR(10))
RETURNING CHAR(5) AS codigoretorno,
    INTEGER AS keyx,
    DATE AS fec_iniperiodo,
    DATE AS fec_finperiodo;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE ikeyx INTEGER;
	DEFINE dfechaIniperiodo DATE;
	DEFINE dFechaFinPeriodo DATE;
	DEFINE iNumRows INTEGER;
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET ikeyx = 0;
	LET dfechaIniperiodo = NULL;
	LET dFechaFinPeriodo = NULL;
	LET iNumRows = 0;

	BEGIN
		ON EXCEPTION SET iSqlErr
		IF	iSqlErr <> 0 THEN
			LET cCodRet = iSqlErr;
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultaperiodosemanaltelmex.out';
		--TRACE ON;
		
		IF 	pUsuario = '' OR pIdFuncion = ''  THEN
			LET cCodRet = '00003';
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
		
		EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF	cCodRet <> '00000' THEN
			RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo;
		END IF;
			
		SELECT COUNT(*)
		INTO iNumRows
		FROM bdisac:sac_liquidacionestelmex;
		IF iNumRows < 1 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, 0, '', '';
		ELSE
			FOREACH
				SELECT keyx, fec_iniperiodo, fec_finperiodo
				INTO ikeyx, dfechaIniperiodo, dFechaFinPeriodo
				FROM bdisac:sac_liquidacionestelmex
				RETURN cCodRet, ikeyx, dfechaIniperiodo, dFechaFinPeriodo WITH RESUME;
			END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT 'AUTOR: Esparza Brenis Fernando Martin';

CREATE PROCEDURE "informix".sp_consultarctesporasignarcli(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), pNumCliente CHAR(20), pTipoCuenta CHAR(1), pTipoCampo CHAR(1), 
	pTipoDireccion CHAR(1), pFechaInicio DATE, pFechaFin DATE, pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
			CHAR(20) AS num_ciente,
			CHAR(107) AS nombre_cliente,
			DATE AS fecha_nacimiento,
			CHAR(30) AS estado,
			CHAR(60) AS ciudad,
			CHAR(30) AS calle,
			CHAR(5) AS codigo_postal,
			CHAR(10) AS tipo_domicilio,
			CHAR(4) AS sucursal,
			CHAR(27) AS municipio,
			INTEGER AS num_colonia,
			CHAR(32) AS zona,
			CHAR(80) AS observaciones;
	
	DEFINE cCodRet CHAR(5);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE iRegistros INTEGER;
	DEFINE iRecuperacion INTEGER;
	DEFINE iNoRegistros INTEGER;
	-- VARIBLES DE RETORNADAS POR EL PROCEDIMIENTO INTERNO
	DEFINE cNumCliente CHAR(20);
	DEFINE cNombreCliente CHAR(107);
	DEFINE dFechaNacimiento DATE;
	DEFINE cEstado CHAR(30);
	DEFINE cCiudad CHAR(60);
	DEFINE cCalle CHAR(30);
	DEFINE cCodigoPostal CHAR(5);
	DEFINE cTipoDomicilio CHAR(10);
	DEFINE cSucursal CHAR(4);
	DEFINE cMunicipio CHAR(27);
	DEFINE iNumColonia INTEGER;
	DEFINE cZona CHAR(32);
	DEFINE cObservaciones CHAR(80);
	
	LET cCodRet = '00000';
	LET cCodRetSp = '';
	LET iSqlErr = 0;
	LET iRegistros = 0;
	LET iRecuperacion = 0;
	LET iNoRegistros = 0;
	-- VARIBLES DE RETORNADAS POR EL PROCEDIMIENTO INTERNO
	LET cNumCliente = '';
	LET cNombreCliente = '';
	LET dFechaNacimiento = NULL;
	LET cEstado = '';
	LET cCiudad = '';
	LET cCalle = '';
	LET cCodigoPostal = '';
	LET cTipoDomicilio = '';
	LET cSucursal = '';
	LET cMunicipio = '';
	LET iNumColonia = 0;
	LET cZona = '';
	LET cObservaciones = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr	
			LET cCodRet = iSqlErr;
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarctesporasignarcli.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta = '' OR pRegistros IS NULL OR pRecuperacion IS NULL THEN
			LET cCodRet = '00003';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pTipoConsulta NOT IN ('1', '2') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pRegistros < 0 OR pRecuperacion < 0 THEN
			LET cCodRet = '00098';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
					cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
		IF pTipoConsulta = '1' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
						cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultarctesporasignar(pTipoConsulta, pNumCliente, pTipoCuenta, pTipoCampo, pTipoDireccion, pFechaInicio, pFechaFin)
				INTO cCodRetSp, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
						cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones
			
			IF cCodRetSp::INTEGER = 0 THEN
				IF iRegistros >= pRegistros THEN
					IF iRecuperacion < pRecuperacion THEN
						LET iRecuperacion = iRecuperacion + 1;
						RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
								cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones WITH RESUME;
						LET iNoRegistros = iNoRegistros + 1;
					END IF;
				END IF;
			ELSE
				LET cCodRet = '00017';
				RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
								cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
			END IF;
			LET iRegistros = iRegistros + 1;
			
		END FOREACH;
		
		IF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
							cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		ELIF iNoRegistros = 0 AND pRegistros = 0 THEN
			LET cCodRet = '1001';
			RETURN cCodRet, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
							cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones;
		END IF;
		
	END;
			
END PROCEDURE;