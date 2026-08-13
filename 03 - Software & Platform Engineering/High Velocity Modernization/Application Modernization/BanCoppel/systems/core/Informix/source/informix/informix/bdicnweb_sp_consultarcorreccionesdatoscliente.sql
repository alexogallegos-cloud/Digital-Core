CREATE PROCEDURE "informix".sp_consultarcorreccionesdatoscliente(pUsuario CHAR(8), pIdFuncion CHAR(10), pNumCliente CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pTipoReporte CHAR(1), pRegistros INTEGER, pRecuperacion INTEGER)
	RETURNING CHAR(5) AS codret,
		CHAR(20) AS numcte,
		CHAR(20) AS fecha,
		CHAR(13) AS rfc_anterior,
		CHAR(100) AS nombre_anterior,
		CHAR(13) AS rfc_actual,
		CHAR(100) AS nombre_actual,
		CHAR(8) AS usuario_insrercion;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cFecha CHAR(20);
	DEFINE cRfcAnterior CHAR(13);
	DEFINE cNombreAnterior CHAR(100);
	DEFINE cRfcActual CHAR(13);
	DEFINE cNombreActual CHAR(100);
	DEFINE cUsuarioInsert CHAR(8);
	DEFINE cCodRetSp CHAR(5);
	DEFINE iNoRegs INTEGER;
	DEFINE iSkip INTEGER;
	DEFINE iFirst INTEGER;
	DEFINE pFechaInicialSp CHAR(10);
	DEFINE pFechaFinalSp CHAR(10);
	
	LET cCodRet = '';
	LET iSqlErr = 0;
	LET cFecha = '';
	LET cRfcAnterior = '';
	LET cNombreAnterior = '';
	LET cRfcActual = '';
	LET cNombreActual = '';
	LET cUsuarioInsert = '';
	LET cCodRetSp = '';
	LET iNoRegs = 0;
	LET iSkip = 0;
	LET iFirst = 0;
	LET pFechaInicialSp = '';
	LET pFechaFinalSp = '';
	
	BEGIN
	
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_consultarcorreccionesdatoscliente.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pTipoReporte = '' OR pRecuperacion = '' OR pRegistros = '' THEN
			LET cCodRet = '00003';
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END IF;
		
		IF pTipoReporte NOT IN ('1', '2') THEN
			LET cCodRet = '00044';
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END IF;
		
		IF pTipoReporte = '1' THEN
			IF pNumCliente = '' THEN
				LET cCodRet = '00003';
				LET pNumCliente = '';
				RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
			END IF;
		ELIF pTipoReporte = '2' THEN
			IF pFechaInicial = '' OR pFechaFinal = '' THEN
				LET cCodRet = '00003';
				LET pNumCliente = '';
				RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
			END IF;
			
			LET pFechaInicialSp = TO_CHAR(pFechaInicial, '%m-%d-%Y');
			LET pFechaFinalSp = TO_CHAR(pFechaFinal, '%m-%d-%Y');
		END IF;
		
		-- ValidaciÃ³n de acceso a la funcionalidad
		EXECUTE FUNCTION bdinteg:"informix".sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) INTO cCodRet;
		IF cCodRet <> '00000' THEN
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END IF;
		
		FOREACH EXECUTE PROCEDURE bdinteg:"informix".sp_consultarcorreccionesdatoscte(pFechaInicial, pFechaFinal, pNumCliente, pTipoReporte)
			INTO cCodRetSp, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert
			
			IF cCodRetSp IN ('00001', '0001') THEN
				LET cCodRet = '00003';
				LET pNumCliente = '';
				RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
			END IF;
			
			IF iSkip = pRegistros THEN
				IF iFirst < pRecuperacion THEN
					LET iNoRegs = iNoRegs + 1;
					RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert WITH RESUME;
					LET iFirst = iFirst + 1;
				END IF;
			ELSE
				LET iSkip = iSkip + 1;
			END IF;
			
		END FOREACH;
		
		IF iNoRegs = 0 AND pRegistros = 0 THEN
			LET cCodRet = '00017';
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END IF;
		
		IF iNoRegs = 0 AND pRegistros > 0 THEN
			LET cCodRet = '1001';
			LET pNumCliente = '';
			RETURN cCodRet, pNumCliente, cFecha, cRfcAnterior, cNombreAnterior, cRfcActual, cNombreActual, cUsuarioInsert;
		END IF;
	
	END;

END PROCEDURE;