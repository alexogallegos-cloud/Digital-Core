CREATE PROCEDURE "informix".spconsultarerroresfaltantesarch(p_sNombreArchivo CHAR(20))

RETURNING CHAR(5) AS CodigoRetorno, CHAR(4) AS NumSucursal, CHAR(8) AS NumEmpleado, MONEY(10,0) AS SaldoInicial, DATE AS FechaRegistro, CHAR(1) AS v_sNumSucValida,
		  CHAR(1) AS v_sNumEmpValido, CHAR(1) AS v_sSaldoIniValido, CHAR(1) AS v_sFechaRegValida, CHAR(1) AS v_sNumAuxValido, CHAR(1) AS v_sRegistroValido;		
			
	DEFINE iSqlErr				INTEGER;	
	DEFINE v_sCodRet       		CHAR(5);	
	DEFINE v_sNumSucursal		CHAR(4);
	DEFINE v_sNumEmpleado		CHAR(8);
	DEFINE v_mSaldoInicial		MONEY(10,0);
	DEFINE v_dFechaRegistro		DATE;	
	DEFINE v_sNumSucValida		CHAR(1);
	DEFINE v_sNumEmpValido 		CHAR(1);
	DEFINE v_sSaldoIniValido	CHAR(1);
	DEFINE v_sFechaRegValida	CHAR(1);
	DEFINE v_sNumAuxValido		CHAR(1);
	DEFINE v_sRegistroValido	CHAR(1);
	
	-----------------------------------------------------------------------
	--SET DEBUG FILE TO "/dbexportb/Fabiola/spconsultarerroresfaltantesarch.out"; 
	--TRACE ON;
	-----------------------------------------------------------------------

    SET LOCK MODE TO WAIT 3;
    SET ISOLATION TO DIRTY READ;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET v_sCodRet = iSqlErr;
				RETURN v_sCodRet,'','','','','','','','','','';
			END IF;
		END EXCEPTION;
		
		LET v_sCodRet = '00000';						
		
		FOREACH
			SELECT numsucursal, numempleado, saldoinicial, fecharegistro, numsucvalida, 
			numempvalido, saldoinivalido, fecharegvalida, numauxvalido, registrovalido
			INTO v_sNumSucursal, v_sNumEmpleado, v_mSaldoInicial, v_dFechaRegistro, v_sNumSucValida, 
			v_sNumEmpValido, v_sSaldoIniValido, v_sFechaRegValida, v_sNumAuxValido, v_sRegistroValido
			FROM bdirech:rec_faltantesarch
			WHERE (numsucvalida = 0 OR numempvalido = 0 OR saldoinivalido = 0 OR fecharegvalida = 0 OR numauxvalido = 0 OR registrovalido = 0)
			AND nombrearchivo = p_sNombreArchivo
			
			RETURN v_sCodRet, v_sNumSucursal, v_sNumEmpleado, v_mSaldoInicial, v_dFechaRegistro, v_sNumSucValida, 
			v_sNumEmpValido, v_sSaldoIniValido, v_sFechaRegValida, v_sNumAuxValido, v_sRegistroValido WITH RESUME;
		END FOREACH
		
	END;
END PROCEDURE
