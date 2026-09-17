CREATE PROCEDURE "informix".sp_cambioinstruccionespagare(pUsuario CHAR(8), pIdFuncion CHAR(10), pCuenta CHAR(20), pCuentaReferencia CHAR(20), pInstruccion SMALLINT, pFechaVencimiento DATE)
	RETURNING CHAR(5) AS codret;
	
	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;
	DEFINE cCodRetSp CHAR(5);
	DEFINE cEmpresa CHAR(3);
	DEFINE cCapital CHAR(2);
	DEFINE cInteres CHAR(2);
	
	LET cCodRet = '00000';
	LET iSqlErr = 0;
	LET cCodRetSp = '';
	LET cEmpresa = '001';
	LET cCapital = '';
	LET cInteres = '';
	
	BEGIN
		
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			RETURN cCodRet;
		END EXCEPTION;
		
		--SET DEBUG FILE TO '/tmp/mfinis/sp_cambioinstruccionespagare.out';
		--TRACE ON;
		
		IF pUsuario = '' OR pIdFuncion = '' OR pCuenta = '' OR pCuentaReferencia = '' OR pInstruccion = '' OR pFechaVencimiento = '' THEN
			LET cCodRet = '00003';
			RETURN cCodRet;
		END IF;
		
		--EXECUTE FUNCTION bdinteg:sp_cnsif_confirmaejecutivo(pUsuario, pIdFuncion) into cCodRet;
		EXECUTE PROCEDURE bdinteg:"informix".sp_cnsif_permisosejecutivo(pUsuario, pIdFuncion, pCuenta, '03', '1') INTO cCodRet;
		IF cCodRet <> '00000' THEN
			RETURN cCodRet;
		END IF;
		
		-- Se consulta el tipo de capital y de interes
		EXECUTE PROCEDURE bdinvers:"informix".sp_obtienevalorinstrucc(cEmpresa, pInstruccion) INTO cCodRetSp, cCapital, cInteres;
		
		EXECUTE PROCEDURE bdinvers:"informix".cambinstrucc(cEmpresa, pCuenta, cCapital, cInteres, 
				pCuentaReferencia, pCuentaReferencia, pFechaVencimiento, pUsuario, '1')
		INTO cCodRetSp;
		
		IF cCodRetSp = '000' THEN
			LET cCodRet = '00000';
		ELIF cCodRetSp = '361' THEN
			LET cCodRet = '00172';
		ELIF cCodRetSp = '362' THEN
			LET cCodRet = '00173';
		ELIF cCodRetSp = '363' THEN
			LET cCodRet = '00174';
		ELIF cCodRetSp = '154' THEN
			LET cCodRet = '00175';
		ELIF cCodRetSp = '155' THEN
			LET cCodRet = '00176';
		ELIF cCodRetSp = '156' THEN
			LET cCodRet = '00177';
		ELSE
			LET cCodRet = '00178';
		END IF;
		
		RETURN cCodRet;
		
	END;
	
	
END PROCEDURE;