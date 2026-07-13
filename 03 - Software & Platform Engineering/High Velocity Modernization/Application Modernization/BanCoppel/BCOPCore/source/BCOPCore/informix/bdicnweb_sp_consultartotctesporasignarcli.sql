CREATE PROCEDURE "informix".sp_consultartotctesporasignarcli(pUsuario CHAR(8), pIdFuncion CHAR(10), pTipoConsulta CHAR(1), pNumCliente CHAR(20), pTipoCuenta CHAR(1), pTipoCampo CHAR(1), 
	pTipoDireccion CHAR(1), pFechaInicio DATE, pFechaFin DATE)
	RETURNING CHAR(5) AS codret,
			INTEGER AS total;
	
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
			RETURN cCodRet, iNoRegistros;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultartotctesporasignarcli.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoConsulta = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoConsulta NOT IN ('1', '2') THEN
			LET cCodRet = '00044';
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		-- VALIDACIÃN DE ACCESO A LA FUNCIONALIDAD
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo (pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet, iNoRegistros;
		END IF;
		
		IF pTipoConsulta = '1' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				RETURN cCodRet, iNoRegistros;
			END IF;
		END IF;
		
		SET ISOLATION TO DIRTY READ;
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultarctesporasignar(pTipoConsulta, pNumCliente, pTipoCuenta, pTipoCampo, pTipoDireccion, pFechaInicio, pFechaFin)
				INTO cCodRetSp, cNumCliente, cNombreCliente, dFechaNacimiento, cEstado, cCiudad, cCalle, cCodigoPostal, 
						cTipoDomicilio, cSucursal, cMunicipio, iNumColonia, cZona, cObservaciones
			
			IF cCodRetSp::INTEGER = 0 THEN
				LET iNoRegistros = iNoRegistros + 1;
			END IF;
			
		END FOREACH;
		
		RETURN cCodRet, iNoRegistros;
		
	END;
			
END PROCEDURE;